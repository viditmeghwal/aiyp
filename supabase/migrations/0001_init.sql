-- Agency in Your Pocket — initial schema

create extension if not exists "uuid-ossp";

-- profiles (extends auth.users)
create table public.profiles (
  id                   uuid references auth.users(id) on delete cascade primary key,
  full_name            text,
  avatar_url           text,
  plan_tier            text not null default 'free'
                         check (plan_tier in ('free','starter','growth','agency','dfy')),
  stripe_customer_id   text,
  is_admin             boolean not null default false,
  onboarding_completed boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- businesses
create table public.businesses (
  id                   uuid default uuid_generate_v4() primary key,
  user_id              uuid references public.profiles(id) on delete cascade not null,
  name                 text not null,
  vertical             text not null
                         check (vertical in ('cafe','jewellery','hotel','marble','artefacts','clothing','general')),
  location             text,
  website              text,
  instagram_handle     text,
  stage                text,
  goals                text[],
  hours_per_week       integer,
  biggest_frustration  text,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- growth_plans
create table public.growth_plans (
  id          uuid default uuid_generate_v4() primary key,
  business_id uuid references public.businesses(id) on delete cascade not null,
  user_id     uuid references public.profiles(id) on delete cascade not null,
  title       text not null,
  created_at  timestamptz not null default now()
);

-- tasks
create table public.tasks (
  id             uuid default uuid_generate_v4() primary key,
  growth_plan_id uuid references public.growth_plans(id) on delete cascade not null,
  user_id        uuid references public.profiles(id) on delete cascade not null,
  title          text not null,
  description    text,
  phase          text not null,
  workflow_ref   text,
  order_index    integer not null default 0,
  status         text not null default 'not_started'
                   check (status in ('not_started','in_progress','review','complete')),
  completed_at   timestamptz,
  created_at     timestamptz not null default now()
);

-- workflow_runs
create table public.workflow_runs (
  id               uuid default uuid_generate_v4() primary key,
  user_id          uuid references public.profiles(id) on delete cascade not null,
  business_id      uuid references public.businesses(id) on delete cascade,
  workflow_ref     text not null,
  status           text not null default 'queued'
                     check (status in ('queued','running','succeeded','failed')),
  inngest_event_id text,
  error_message    text,
  started_at       timestamptz,
  completed_at     timestamptz,
  created_at       timestamptz not null default now()
);

-- deliverables
create table public.deliverables (
  id              uuid default uuid_generate_v4() primary key,
  user_id         uuid references public.profiles(id) on delete cascade not null,
  business_id     uuid references public.businesses(id) on delete cascade,
  workflow_run_id uuid references public.workflow_runs(id) on delete set null,
  title           text not null,
  type            text not null default 'document',
  category        text,
  content         jsonb,
  file_url        text,
  created_at      timestamptz not null default now()
);

-- free_audits
create table public.free_audits (
  id            uuid default uuid_generate_v4() primary key,
  name          text not null,
  email         text not null,
  business_name text not null,
  vertical      text not null,
  status        text not null default 'pending'
                  check (status in ('pending','analyzing','complete','failed')),
  result        jsonb,
  inngest_event_id text,
  created_at    timestamptz not null default now()
);

-- waitlist
create table public.waitlist (
  id         uuid default uuid_generate_v4() primary key,
  email      text not null unique,
  name       text,
  vertical   text,
  created_at timestamptz not null default now()
);

-- integrations
create table public.integrations (
  id            uuid default uuid_generate_v4() primary key,
  user_id       uuid references public.profiles(id) on delete cascade not null,
  provider      text not null,
  access_token  text,
  refresh_token text,
  expires_at    timestamptz,
  metadata      jsonb,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- RLS
alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.growth_plans enable row level security;
alter table public.tasks enable row level security;
alter table public.workflow_runs enable row level security;
alter table public.deliverables enable row level security;
alter table public.free_audits enable row level security;
alter table public.waitlist enable row level security;
alter table public.integrations enable row level security;

create policy "own profile"       on public.profiles       for all using (auth.uid() = id);
create policy "own businesses"    on public.businesses     for all using (auth.uid() = user_id);
create policy "own growth_plans"  on public.growth_plans   for all using (auth.uid() = user_id);
create policy "own tasks"         on public.tasks          for all using (auth.uid() = user_id);
create policy "own workflow_runs" on public.workflow_runs  for all using (auth.uid() = user_id);
create policy "own deliverables"  on public.deliverables   for all using (auth.uid() = user_id);
create policy "own integrations"  on public.integrations   for all using (auth.uid() = user_id);

create policy "public insert free_audits"   on public.free_audits for insert with check (true);
create policy "public select free_audits"   on public.free_audits for select using (true);
create policy "public insert waitlist"      on public.waitlist     for insert with check (true);

-- Trigger: auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- updated_at helper
create or replace function public.handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.handle_updated_at();

create trigger set_businesses_updated_at
  before update on public.businesses
  for each row execute procedure public.handle_updated_at();

create trigger set_integrations_updated_at
  before update on public.integrations
  for each row execute procedure public.handle_updated_at();
