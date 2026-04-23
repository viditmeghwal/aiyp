#!/bin/bash
set -e
echo "=== Part 6: Final files ==="

# ── components.json ──────────────────────────────────────────────────────────
cat > components.json << 'HEREDOC'
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
HEREDOC

# ── ProblemSection ────────────────────────────────────────────────────────────
mkdir -p components/marketing
cat > components/marketing/ProblemSection.tsx << 'HEREDOC'
export default function ProblemSection() {
  return (
    <section className="bg-pocket-peach py-24">
      <div className="mx-auto max-w-4xl px-6">
        <h2 className="font-display text-3xl font-bold italic text-ink-900 md:text-4xl">
          You started a business, not a marketing agency.
        </h2>
        <div className="mt-8 grid gap-8 md:grid-cols-2">
          <div>
            <p className="text-lg text-ink-700">
              Solo founders spend 60% of their week on brand tasks they didn&apos;t sign up
              for — writing captions, designing graphics, managing Google profiles,
              chasing reviews.
            </p>
            <p className="mt-4 text-lg text-ink-700">
              The result? Inconsistent presence, missed opportunities, and burnout
              before you even get to the work you love.
            </p>
          </div>
          <div className="space-y-4">
            {[
              "No brand voice or visual consistency",
              "Instagram goes quiet for weeks",
              "Google Business Profile full of unanswered reviews",
              "No time to create content that actually converts",
              "Agency quotes are $3k–$10k/month minimum",
            ].map((pain) => (
              <div key={pain} className="flex items-start gap-3">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-pocket-orange" />
                <span className="text-ink-700">{pain}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── PricingPreview ────────────────────────────────────────────────────────────
cat > components/marketing/PricingPreview.tsx << 'HEREDOC'
import Link from "next/link";
import { Button } from "@/components/ui/button";

const tiers = [
  { name: "Starter", price: "$29", highlight: false },
  { name: "Growth", price: "$59", highlight: true },
  { name: "Agency", price: "$129", highlight: false },
];

export default function PricingPreview() {
  return (
    <section className="py-24 bg-white">
      <div className="mx-auto max-w-5xl px-6 text-center">
        <h2 className="font-display text-3xl font-bold italic text-ink-900 md:text-4xl">
          Simple, transparent pricing
        </h2>
        <p className="mt-4 text-ink-500">Start free. Upgrade when you&apos;re ready.</p>
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {tiers.map((tier) => (
            <div
              key={tier.name}
              className={`rounded-2xl border p-8 transition-transform ${
                tier.highlight
                  ? "border-pocket-orange bg-pocket-orange text-white shadow-xl scale-105"
                  : "border-ink-300 bg-pocket-cream"
              }`}
            >
              <p className="text-sm font-semibold uppercase tracking-widest opacity-70">
                {tier.name}
              </p>
              <p className="mt-2 text-4xl font-bold">
                {tier.price}
                <span className="text-base font-normal opacity-60">/mo</span>
              </p>
            </div>
          ))}
        </div>
        <div className="mt-10">
          <Button asChild size="lg" variant="default">
            <Link href="/pricing">See full pricing →</Link>
          </Button>
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── lib/workflows/free-audit.ts (overwrite with proper Inngest function) ──────
mkdir -p lib/workflows
cat > lib/workflows/free-audit.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

function generateTeaserAudit(vertical: string, businessName: string) {
  const verticalData: Record<string, { working: string[]; broken: string[] }> = {
    cafe: {
      working: [
        "Google Business Profile is claimed and verified",
        "Menu is visible on Google Maps",
        "Has customer photos on Google",
      ],
      broken: [
        "Instagram posts have low engagement (under 2%)",
        "No response to 12 Google reviews in last 3 months",
        "Website missing mobile-optimised menu page",
        "No seasonal promotions content in last 60 days",
        "Google posts section completely empty",
      ],
    },
    jewellery: {
      working: [
        "Product photography is consistent and high quality",
        "Instagram feed has cohesive aesthetic",
        "Has a working online store",
      ],
      broken: [
        "Product descriptions missing key search terms",
        "No Instagram Reels in last 30 days",
        "Google Shopping feed not set up",
        "No customer testimonials on website",
        "Pinterest presence missing entirely",
      ],
    },
    hotel: {
      working: [
        "TripAdvisor profile is active with responses",
        "Google Business Profile has 50+ photos",
        "Direct booking link prominent on website",
      ],
      broken: [
        "OTA response rate below 80%",
        "No email capture for repeat guests",
        "Instagram stories highlights not set up",
        "No local experience content in social posts",
        "Website load time over 4 seconds on mobile",
      ],
    },
    marble: {
      working: [
        "Project portfolio visible on website",
        "Google Business Profile has before/after photos",
        "LinkedIn company page active",
      ],
      broken: [
        "No video testimonials from clients",
        "Instagram lacks process/installation reels",
        "No Google Ads for high-intent search terms",
        "Website missing trust signals (years in business, client logos)",
        "No follow-up sequence after quote is sent",
      ],
    },
    artefacts: {
      working: [
        "Marketplace presence established",
        "Product stories and provenance documented",
        "Email list exists",
      ],
      broken: [
        "No certificates of authenticity visible on listings",
        "Instagram engagement under 1.5% average",
        "No blog or educational content about artefacts",
        "Video content completely absent",
        "No retargeting for website visitors",
      ],
    },
    clothing: {
      working: [
        "Lookbook photography is strong",
        "Instagram has consistent posting schedule",
        "Size guide visible on product pages",
      ],
      broken: [
        "No UGC (user-generated content) strategy",
        "Cart abandonment emails not configured",
        "TikTok presence missing",
        "No influencer or gifting programme",
        "Product pages missing review counts",
      ],
    },
    general: {
      working: [
        "Google Business Profile is claimed",
        "Website is mobile-responsive",
        "Social profiles are complete",
      ],
      broken: [
        "Inconsistent brand voice across channels",
        "No content calendar or posting schedule",
        "Google reviews not being responded to",
        "Website missing clear call-to-action above fold",
        "No email nurture sequence for leads",
      ],
    },
  };

  const data = verticalData[vertical] ?? verticalData.general;
  const overallScore = Math.floor(Math.random() * 26) + 40;

  return {
    businessName,
    vertical,
    overallScore,
    categories: [
      { name: "Online Presence", score: Math.floor(Math.random() * 30) + 35 },
      { name: "Social Media", score: Math.floor(Math.random() * 30) + 30 },
      { name: "Content Strategy", score: Math.floor(Math.random() * 25) + 25 },
      { name: "Reputation & Reviews", score: Math.floor(Math.random() * 30) + 40 },
    ],
    working: data.working,
    broken: data.broken,
  };
}

export const freeAuditWorkflow = inngest.createFunction(
  { id: "free-audit", name: "Free Audit Workflow" },
  { event: "free-audit/started" },
  async ({ event, step }) => {
    const { auditId, vertical, businessName } = event.data as {
      auditId: string;
      vertical: string;
      businessName: string;
    };

    const supabase = createServiceRoleClient();

    await step.run("mark-analyzing", async () => {
      await supabase
        .from("free_audits")
        .update({ status: "analyzing" })
        .eq("id", auditId);
    });

    await step.sleep("processing-delay", "8s");

    await step.run("complete-audit", async () => {
      const result = generateTeaserAudit(vertical, businessName);
      await supabase
        .from("free_audits")
        .update({ status: "complete", result })
        .eq("id", auditId);
    });
  }
);
HEREDOC

# ── lib/workflows/brand-audit.ts ─────────────────────────────────────────────
cat > lib/workflows/brand-audit.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

export const brandAuditWorkflow = inngest.createFunction(
  { id: "brand-audit", name: "Brand Audit Workflow" },
  { event: "workflow/brand-audit.started" },
  async ({ event, step }) => {
    const { runId } = event.data as { runId: string };
    const supabase = createServiceRoleClient();

    await step.run("mark-running", async () => {
      await supabase
        .from("workflow_runs")
        .update({ status: "running", started_at: new Date().toISOString() })
        .eq("id", runId);
    });

    await step.sleep("processing", "15s");

    await step.run("create-deliverable", async () => {
      const { data: run } = await supabase
        .from("workflow_runs")
        .select("user_id, business_id")
        .eq("id", runId)
        .single();
      if (!run) return;

      await supabase.from("deliverables").insert({
        user_id: run.user_id,
        business_id: run.business_id,
        workflow_run_id: runId,
        title: "Brand Audit Report",
        type: "document",
        category: "Brand Strategy",
        content: {
          placeholder: true,
          message: "Full AI-generated audit coming soon",
        },
      });

      await supabase
        .from("workflow_runs")
        .update({ status: "succeeded", completed_at: new Date().toISOString() })
        .eq("id", runId);
    });
  }
);
HEREDOC

# ── lib/workflows/brand-starter-kit.ts ──────────────────────────────────────
cat > lib/workflows/brand-starter-kit.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

export const brandStarterKitWorkflow = inngest.createFunction(
  { id: "brand-starter-kit", name: "Brand Starter Kit Workflow" },
  { event: "workflow/brand-starter-kit.started" },
  async ({ event, step }) => {
    const { runId } = event.data as { runId: string };
    const supabase = createServiceRoleClient();

    await step.run("mark-running", async () => {
      await supabase
        .from("workflow_runs")
        .update({ status: "running", started_at: new Date().toISOString() })
        .eq("id", runId);
    });

    await step.sleep("processing", "15s");

    await step.run("create-deliverable", async () => {
      const { data: run } = await supabase
        .from("workflow_runs")
        .select("user_id, business_id")
        .eq("id", runId)
        .single();
      if (!run) return;

      await supabase.from("deliverables").insert({
        user_id: run.user_id,
        business_id: run.business_id,
        workflow_run_id: runId,
        title: "Brand Starter Kit",
        type: "document",
        category: "Brand Identity",
        content: {
          placeholder: true,
          message: "Colours, fonts, voice guide, and logo concepts coming soon",
        },
      });

      await supabase
        .from("workflow_runs")
        .update({ status: "succeeded", completed_at: new Date().toISOString() })
        .eq("id", runId);
    });
  }
);
HEREDOC

# ── lib/workflows/content-calendar.ts ────────────────────────────────────────
cat > lib/workflows/content-calendar.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

export const contentCalendarWorkflow = inngest.createFunction(
  { id: "content-calendar", name: "Content Calendar Workflow" },
  { event: "workflow/content-calendar.started" },
  async ({ event, step }) => {
    const { runId } = event.data as { runId: string };
    const supabase = createServiceRoleClient();

    await step.run("mark-running", async () => {
      await supabase
        .from("workflow_runs")
        .update({ status: "running", started_at: new Date().toISOString() })
        .eq("id", runId);
    });

    await step.sleep("processing", "15s");

    await step.run("create-deliverable", async () => {
      const { data: run } = await supabase
        .from("workflow_runs")
        .select("user_id, business_id")
        .eq("id", runId)
        .single();
      if (!run) return;

      await supabase.from("deliverables").insert({
        user_id: run.user_id,
        business_id: run.business_id,
        workflow_run_id: runId,
        title: "30-Day Content Calendar",
        type: "document",
        category: "Content Strategy",
        content: {
          placeholder: true,
          message: "AI-generated 30-day content plan coming soon",
        },
      });

      await supabase
        .from("workflow_runs")
        .update({ status: "succeeded", completed_at: new Date().toISOString() })
        .eq("id", runId);
    });
  }
);
HEREDOC

# ── app/api/free-audit/start/route.ts (overwrite to fix event name) ───────────
mkdir -p app/api/free-audit/start
cat > app/api/free-audit/start/route.ts << 'HEREDOC'
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createServiceRoleClient } from "@/lib/supabase/server";
import { inngest } from "@/lib/integrations/inngest/client";

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  businessName: z.string().min(1),
  vertical: z.enum(["cafe", "jewellery", "hotel", "marble", "artefacts", "clothing", "general"]),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const data = schema.parse(body);
    const supabase = createServiceRoleClient();

    const { data: audit, error } = await supabase
      .from("free_audits")
      .insert({
        name: data.name,
        email: data.email,
        business_name: data.businessName,
        vertical: data.vertical,
        status: "pending",
      })
      .select("id")
      .single();

    if (error || !audit) {
      return NextResponse.json({ error: "Failed to create audit" }, { status: 500 });
    }

    await inngest.send({
      name: "free-audit/started",
      data: {
        auditId: audit.id,
        vertical: data.vertical,
        businessName: data.businessName,
      },
    });

    return NextResponse.json({ auditId: audit.id });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ error: err.errors }, { status: 400 });
    }
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
HEREDOC

# ── app/api/inngest/route.ts (overwrite with all 4 workflows) ─────────────────
mkdir -p app/api/inngest
cat > app/api/inngest/route.ts << 'HEREDOC'
import { serve } from "inngest/next";
import { inngest } from "@/lib/integrations/inngest/client";
import { freeAuditWorkflow } from "@/lib/workflows/free-audit";
import { brandAuditWorkflow } from "@/lib/workflows/brand-audit";
import { brandStarterKitWorkflow } from "@/lib/workflows/brand-starter-kit";
import { contentCalendarWorkflow } from "@/lib/workflows/content-calendar";

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    freeAuditWorkflow,
    brandAuditWorkflow,
    brandStarterKitWorkflow,
    contentCalendarWorkflow,
  ],
});
HEREDOC

# ── Email templates ───────────────────────────────────────────────────────────
mkdir -p lib/emails

cat > lib/emails/WelcomeEmail.tsx << 'HEREDOC'
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface WelcomeEmailProps {
  name: string;
  appUrl: string;
}

export function WelcomeEmail({ name, appUrl }: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Welcome to Agency in Your Pocket — your brand-building co-pilot</Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Welcome! Your brand-building co-pilot is ready. Head to your dashboard
            to see your personalised growth plan — 30+ tasks tailored to your business.
          </Text>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={`${appUrl}/dashboard`}
              style={{
                backgroundColor: "#F97316",
                color: "#ffffff",
                padding: "14px 28px",
                borderRadius: "8px",
                fontWeight: 600,
                fontSize: 16,
                textDecoration: "none",
              }}
            >
              Go to your dashboard →
            </Button>
          </Section>
          <Text style={{ color: "#64748B", fontSize: 14 }}>
            — The Agency in Your Pocket team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}
HEREDOC

cat > lib/emails/FreeAuditReadyEmail.tsx << 'HEREDOC'
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface FreeAuditReadyEmailProps {
  name: string;
  businessName: string;
  score: number;
  auditUrl: string;
}

export function FreeAuditReadyEmail({
  name,
  businessName,
  score,
  auditUrl,
}: FreeAuditReadyEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Your free brand audit for {businessName} is ready</Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Your free brand audit for <strong>{businessName}</strong> is ready.
          </Text>
          <div
            style={{
              backgroundColor: "#FFE4D6",
              borderRadius: 12,
              padding: "24px",
              textAlign: "center",
              margin: "24px 0",
            }}
          >
            <Text
              style={{
                color: "#0F172A",
                fontSize: 48,
                fontWeight: 700,
                margin: "0",
                lineHeight: "1",
              }}
            >
              {score}/100
            </Text>
            <Text style={{ color: "#334155", margin: "8px 0 0" }}>
              Overall Brand Score
            </Text>
          </div>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={auditUrl}
              style={{
                backgroundColor: "#F97316",
                color: "#ffffff",
                padding: "14px 28px",
                borderRadius: "8px",
                fontWeight: 600,
                fontSize: 16,
                textDecoration: "none",
              }}
            >
              View your full audit →
            </Button>
          </Section>
          <Text style={{ color: "#64748B", fontSize: 14 }}>
            — The Agency in Your Pocket team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}
HEREDOC

cat > lib/emails/CheckoutSuccessEmail.tsx << 'HEREDOC'
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface CheckoutSuccessEmailProps {
  name: string;
  planName: string;
  appUrl: string;
}

export function CheckoutSuccessEmail({
  name,
  planName,
  appUrl,
}: CheckoutSuccessEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>
        You&apos;re now on the {planName} plan — welcome to the full experience
      </Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            You&apos;re now on the <strong>{planName}</strong> plan. Your full workflow
            library is unlocked — go build something brilliant.
          </Text>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={`${appUrl}/dashboard`}
              style={{
                backgroundColor: "#F97316",
                color: "#ffffff",
                padding: "14px 28px",
                borderRadius: "8px",
                fontWeight: 600,
                fontSize: 16,
                textDecoration: "none",
              }}
            >
              Go to your dashboard →
            </Button>
          </Section>
          <Text style={{ color: "#64748B", fontSize: 14 }}>
            — The Agency in Your Pocket team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}
HEREDOC

# ── Database migration ────────────────────────────────────────────────────────
mkdir -p supabase/migrations
cat > supabase/migrations/0001_init.sql << 'HEREDOC'
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
HEREDOC

# ── Favicon ───────────────────────────────────────────────────────────────────
cat > public/favicon.svg << 'HEREDOC'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <rect width="64" height="64" rx="12" fill="#FFF8F1"/>
  <text x="50%" y="55%" dominant-baseline="middle" text-anchor="middle"
        font-family="system-ui,sans-serif" font-weight="700" font-size="20"
        fill="#F97316">aiyp</text>
</svg>
HEREDOC

# ── README.md ──────────────────────────────────────────────────────────────────
cat > README.md << 'HEREDOC'
set -e
echo "=== Part 6: Final files ==="

# ── components.json ──────────────────────────────────────────────────────────
cat > components.json << 'HEREDOC'
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
HEREDOC

# ── ProblemSection ────────────────────────────────────────────────────────────
mkdir -p components/marketing
cat > components/marketing/ProblemSection.tsx << 'HEREDOC'
export default function ProblemSection() {
  return (
    <section className="bg-pocket-peach py-24">
      <div className="mx-auto max-w-4xl px-6">
        <h2 className="font-display text-3xl font-bold italic text-ink-900 md:text-4xl">
          You started a business, not a marketing agency.
        </h2>
        <div className="mt-8 grid gap-8 md:grid-cols-2">
          <div>
            <p className="text-lg text-ink-700">
              Solo founders spend 60% of their week on brand tasks they didn&apos;t sign up
              for — writing captions, designing graphics, managing Google profiles,
              chasing reviews.
            </p>
            <p className="mt-4 text-lg text-ink-700">
              The result? Inconsistent presence, missed opportunities, and burnout
              before you even get to the work you love.
            </p>
          </div>
          <div className="space-y-4">
            {[
              "No brand voice or visual consistency",
              "Instagram goes quiet for weeks",
              "Google Business Profile full of unanswered reviews",
              "No time to create content that actually converts",
              "Agency quotes are $3k–$10k/month minimum",
            ].map((pain) => (
              <div key={pain} className="flex items-start gap-3">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-pocket-orange" />
                <span className="text-ink-700">{pain}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── PricingPreview ────────────────────────────────────────────────────────────
cat > components/marketing/PricingPreview.tsx << 'HEREDOC'
import Link from "next/link";
import { Button } from "@/components/ui/button";

const tiers = [
  { name: "Starter", price: "$29", highlight: false },
  { name: "Growth", price: "$59", highlight: true },
  { name: "Agency", price: "$129", highlight: false },
];

export default function PricingPreview() {
  return (
    <section className="py-24 bg-white">
      <div className="mx-auto max-w-5xl px-6 text-center">
        <h2 className="font-display text-3xl font-bold italic text-ink-900 md:text-4xl">
          Simple, transparent pricing
        </h2>
        <p className="mt-4 text-ink-500">Start free. Upgrade when you&apos;re ready.</p>
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {tiers.map((tier) => (
            <div
              key={tier.name}
              className={`rounded-2xl border p-8 transition-transform ${
                tier.highlight
                  ? "border-pocket-orange bg-pocket-orange text-white shadow-xl scale-105"
                  : "border-ink-300 bg-pocket-cream"
              }`}
            >
              <p className="text-sm font-semibold uppercase tracking-widest opacity-70">
                {tier.name}
              </p>
              <p className="mt-2 text-4xl font-bold">
                {tier.price}
                <span className="text-base font-normal opacity-60">/mo</span>
              </p>
            </div>
          ))}
        </div>
        <div className="mt-10">
          <Button asChild size="lg" variant="default">
            <Link href="/pricing">See full pricing →</Link>
          </Button>
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── lib/workflows/free-audit.ts (overwrite with proper Inngest function) ──────
mkdir -p lib/workflows
cat > lib/workflows/free-audit.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

function generateTeaserAudit(vertical: string, businessName: string) {
  const verticalData: Record<string, { working: string[]; broken: string[] }> = {
    cafe: {
      working: [
        "Google Business Profile is claimed and verified",
        "Menu is visible on Google Maps",
        "Has customer photos on Google",
      ],
      broken: [
        "Instagram posts have low engagement (under 2%)",
        "No response to 12 Google reviews in last 3 months",
        "Website missing mobile-optimised menu page",
        "No seasonal promotions content in last 60 days",
        "Google posts section completely empty",
      ],
    },
    jewellery: {
      working: [
        "Product photography is consistent and high quality",
        "Instagram feed has cohesive aesthetic",
        "Has a working online store",
      ],
      broken: [
        "Product descriptions missing key search terms",
        "No Instagram Reels in last 30 days",
        "Google Shopping feed not set up",
        "No customer testimonials on website",
        "Pinterest presence missing entirely",
      ],
    },
    hotel: {
      working: [
        "TripAdvisor profile is active with responses",
        "Google Business Profile has 50+ photos",
        "Direct booking link prominent on website",
      ],
      broken: [
        "OTA response rate below 80%",
        "No email capture for repeat guests",
        "Instagram stories highlights not set up",
        "No local experience content in social posts",
        "Website load time over 4 seconds on mobile",
      ],
    },
    marble: {
      working: [
        "Project portfolio visible on website",
        "Google Business Profile has before/after photos",
        "LinkedIn company page active",
      ],
      broken: [
        "No video testimonials from clients",
        "Instagram lacks process/installation reels",
        "No Google Ads for high-intent search terms",
        "Website missing trust signals (years in business, client logos)",
        "No follow-up sequence after quote is sent",
      ],
    },
    artefacts: {
      working: [
        "Marketplace presence established",
        "Product stories and provenance documented",
        "Email list exists",
      ],
      broken: [
        "No certificates of authenticity visible on listings",
        "Instagram engagement under 1.5% average",
        "No blog or educational content about artefacts",
        "Video content completely absent",
        "No retargeting for website visitors",
      ],
    },
    clothing: {
      working: [
        "Lookbook photography is strong",
        "Instagram has consistent posting schedule",
        "Size guide visible on product pages",
      ],
      broken: [
        "No UGC (user-generated content) strategy",
        "Cart abandonment emails not configured",
        "TikTok presence missing",
        "No influencer or gifting programme",
        "Product pages missing review counts",
      ],
    },
    general: {
      working: [
        "Google Business Profile is claimed",
        "Website is mobile-responsive",
        "Social profiles are complete",
      ],
      broken: [
        "Inconsistent brand voice across channels",
        "No content calendar or posting schedule",
        "Google reviews not being responded to",
        "Website missing clear call-to-action above fold",
        "No email nurture sequence for leads",
      ],
    },
  };

  const data = verticalData[vertical] ?? verticalData.general;
  const overallScore = Math.floor(Math.random() * 26) + 40;

  return {
    businessName,
    vertical,
    overallScore,
    categories: [
      { name: "Online Presence", score: Math.floor(Math.random() * 30) + 35 },
      { name: "Social Media", score: Math.floor(Math.random() * 30) + 30 },
      { name: "Content Strategy", score: Math.floor(Math.random() * 25) + 25 },
      { name: "Reputation & Reviews", score: Math.floor(Math.random() * 30) + 40 },
    ],
    working: data.working,
    broken: data.broken,
  };
}

export const freeAuditWorkflow = inngest.createFunction(
  { id: "free-audit", name: "Free Audit Workflow" },
  { event: "free-audit/started" },
  async ({ event, step }) => {
    const { auditId, vertical, businessName } = event.data as {
      auditId: string;
      vertical: string;
      businessName: string;
    };

    const supabase = createServiceRoleClient();

    await step.run("mark-analyzing", async () => {
      await supabase
        .from("free_audits")
        .update({ status: "analyzing" })
        .eq("id", auditId);
    });

    await step.sleep("processing-delay", "8s");

    await step.run("complete-audit", async () => {
      const result = generateTeaserAudit(vertical, businessName);
      await supabase
        .from("free_audits")
        .update({ status: "complete", result })
        .eq("id", auditId);
    });
  }
);
HEREDOC

# ── lib/workflows/brand-audit.ts ─────────────────────────────────────────────
cat > lib/workflows/brand-audit.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

export const brandAuditWorkflow = inngest.createFunction(
  { id: "brand-audit", name: "Brand Audit Workflow" },
  { event: "workflow/brand-audit.started" },
  async ({ event, step }) => {
    const { runId } = event.data as { runId: string };
    const supabase = createServiceRoleClient();

    await step.run("mark-running", async () => {
      await supabase
        .from("workflow_runs")
        .update({ status: "running", started_at: new Date().toISOString() })
        .eq("id", runId);
    });

    await step.sleep("processing", "15s");

    await step.run("create-deliverable", async () => {
      const { data: run } = await supabase
        .from("workflow_runs")
        .select("user_id, business_id")
        .eq("id", runId)
        .single();
      if (!run) return;

      await supabase.from("deliverables").insert({
        user_id: run.user_id,
        business_id: run.business_id,
        workflow_run_id: runId,
        title: "Brand Audit Report",
        type: "document",
        category: "Brand Strategy",
        content: {
          placeholder: true,
          message: "Full AI-generated audit coming soon",
        },
      });

      await supabase
        .from("workflow_runs")
        .update({ status: "succeeded", completed_at: new Date().toISOString() })
        .eq("id", runId);
    });
  }
);
HEREDOC

# ── lib/workflows/brand-starter-kit.ts ──────────────────────────────────────
cat > lib/workflows/brand-starter-kit.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

export const brandStarterKitWorkflow = inngest.createFunction(
  { id: "brand-starter-kit", name: "Brand Starter Kit Workflow" },
  { event: "workflow/brand-starter-kit.started" },
  async ({ event, step }) => {
    const { runId } = event.data as { runId: string };
    const supabase = createServiceRoleClient();

    await step.run("mark-running", async () => {
      await supabase
        .from("workflow_runs")
        .update({ status: "running", started_at: new Date().toISOString() })
        .eq("id", runId);
    });

    await step.sleep("processing", "15s");

    await step.run("create-deliverable", async () => {
      const { data: run } = await supabase
        .from("workflow_runs")
        .select("user_id, business_id")
        .eq("id", runId)
        .single();
      if (!run) return;

      await supabase.from("deliverables").insert({
        user_id: run.user_id,
        business_id: run.business_id,
        workflow_run_id: runId,
        title: "Brand Starter Kit",
        type: "document",
        category: "Brand Identity",
        content: {
          placeholder: true,
          message: "Colours, fonts, voice guide, and logo concepts coming soon",
        },
      });

      await supabase
        .from("workflow_runs")
        .update({ status: "succeeded", completed_at: new Date().toISOString() })
        .eq("id", runId);
    });
  }
);
HEREDOC

# ── lib/workflows/content-calendar.ts ────────────────────────────────────────
cat > lib/workflows/content-calendar.ts << 'HEREDOC'
import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

export const contentCalendarWorkflow = inngest.createFunction(
  { id: "content-calendar", name: "Content Calendar Workflow" },
  { event: "workflow/content-calendar.started" },
  async ({ event, step }) => {
    const { runId } = event.data as { runId: string };
    const supabase = createServiceRoleClient();

    await step.run("mark-running", async () => {
      await supabase
        .from("workflow_runs")
        .update({ status: "running", started_at: new Date().toISOString() })
        .eq("id", runId);
    });

    await step.sleep("processing", "15s");

    await step.run("create-deliverable", async () => {
      const { data: run } = await supabase
        .from("workflow_runs")
        .select("user_id, business_id")
        .eq("id", runId)
        .single();
      if (!run) return;

      await supabase.from("deliverables").insert({
        user_id: run.user_id,
        business_id: run.business_id,
        workflow_run_id: runId,
        title: "30-Day Content Calendar",
        type: "document",
        category: "Content Strategy",
        content: {
          placeholder: true,
          message: "AI-generated 30-day content plan coming soon",
        },
      });

      await supabase
        .from("workflow_runs")
        .update({ status: "succeeded", completed_at: new Date().toISOString() })
        .eq("id", runId);
    });
  }
);
HEREDOC

# ── app/api/free-audit/start/route.ts (overwrite to fix event name) ───────────
mkdir -p app/api/free-audit/start
cat > app/api/free-audit/start/route.ts << 'HEREDOC'
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createServiceRoleClient } from "@/lib/supabase/server";
import { inngest } from "@/lib/integrations/inngest/client";

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  businessName: z.string().min(1),
  vertical: z.enum(["cafe", "jewellery", "hotel", "marble", "artefacts", "clothing", "general"]),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const data = schema.parse(body);
    const supabase = createServiceRoleClient();

    const { data: audit, error } = await supabase
      .from("free_audits")
      .insert({
        name: data.name,
        email: data.email,
        business_name: data.businessName,
        vertical: data.vertical,
        status: "pending",
      })
      .select("id")
      .single();

    if (error || !audit) {
      return NextResponse.json({ error: "Failed to create audit" }, { status: 500 });
    }

    await inngest.send({
      name: "free-audit/started",
      data: {
        auditId: audit.id,
        vertical: data.vertical,
        businessName: data.businessName,
      },
    });

    return NextResponse.json({ auditId: audit.id });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ error: err.errors }, { status: 400 });
    }
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
HEREDOC

# ── app/api/inngest/route.ts (overwrite with all 4 workflows) ─────────────────
mkdir -p app/api/inngest
cat > app/api/inngest/route.ts << 'HEREDOC'
import { serve } from "inngest/next";
import { inngest } from "@/lib/integrations/inngest/client";
import { freeAuditWorkflow } from "@/lib/workflows/free-audit";
import { brandAuditWorkflow } from "@/lib/workflows/brand-audit";
import { brandStarterKitWorkflow } from "@/lib/workflows/brand-starter-kit";
import { contentCalendarWorkflow } from "@/lib/workflows/content-calendar";

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    freeAuditWorkflow,
    brandAuditWorkflow,
    brandStarterKitWorkflow,
    contentCalendarWorkflow,
  ],
});
HEREDOC

# ── Email templates ───────────────────────────────────────────────────────────
mkdir -p lib/emails

cat > lib/emails/WelcomeEmail.tsx << 'HEREDOC'
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface WelcomeEmailProps {
  name: string;
  appUrl: string;
}

export function WelcomeEmail({ name, appUrl }: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Welcome to Agency in Your Pocket — your brand-building co-pilot</Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Welcome! Your brand-building co-pilot is ready. Head to your dashboard
            to see your personalised growth plan — 30+ tasks tailored to your business.
          </Text>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={`${appUrl}/dashboard`}
              style={{
                backgroundColor: "#F97316",
                color: "#ffffff",
                padding: "14px 28px",
                borderRadius: "8px",
                fontWeight: 600,
                fontSize: 16,
                textDecoration: "none",
              }}
            >
              Go to your dashboard →
            </Button>
          </Section>
          <Text style={{ color: "#64748B", fontSize: 14 }}>
            — The Agency in Your Pocket team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}
HEREDOC

cat > lib/emails/FreeAuditReadyEmail.tsx << 'HEREDOC'
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface FreeAuditReadyEmailProps {
  name: string;
  businessName: string;
  score: number;
  auditUrl: string;
}

export function FreeAuditReadyEmail({
  name,
  businessName,
  score,
  auditUrl,
}: FreeAuditReadyEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Your free brand audit for {businessName} is ready</Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Your free brand audit for <strong>{businessName}</strong> is ready.
          </Text>
          <div
            style={{
              backgroundColor: "#FFE4D6",
              borderRadius: 12,
              padding: "24px",
              textAlign: "center",
              margin: "24px 0",
            }}
          >
            <Text
              style={{
                color: "#0F172A",
                fontSize: 48,
                fontWeight: 700,
                margin: "0",
                lineHeight: "1",
              }}
            >
              {score}/100
            </Text>
            <Text style={{ color: "#334155", margin: "8px 0 0" }}>
              Overall Brand Score
            </Text>
          </div>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={auditUrl}
              style={{
                backgroundColor: "#F97316",
                color: "#ffffff",
                padding: "14px 28px",
                borderRadius: "8px",
                fontWeight: 600,
                fontSize: 16,
                textDecoration: "none",
              }}
            >
              View your full audit →
            </Button>
          </Section>
          <Text style={{ color: "#64748B", fontSize: 14 }}>
            — The Agency in Your Pocket team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}
HEREDOC

cat > lib/emails/CheckoutSuccessEmail.tsx << 'HEREDOC'
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface CheckoutSuccessEmailProps {
  name: string;
  planName: string;
  appUrl: string;
}

export function CheckoutSuccessEmail({
  name,
  planName,
  appUrl,
}: CheckoutSuccessEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>
        You&apos;re now on the {planName} plan — welcome to the full experience
      </Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            You&apos;re now on the <strong>{planName}</strong> plan. Your full workflow
            library is unlocked — go build something brilliant.
          </Text>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={`${appUrl}/dashboard`}
              style={{
                backgroundColor: "#F97316",
                color: "#ffffff",
                padding: "14px 28px",
                borderRadius: "8px",
                fontWeight: 600,
                fontSize: 16,
                textDecoration: "none",
              }}
            >
              Go to your dashboard →
            </Button>
          </Section>
          <Text style={{ color: "#64748B", fontSize: 14 }}>
            — The Agency in Your Pocket team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}
HEREDOC

# ── Database migration ────────────────────────────────────────────────────────
mkdir -p supabase/migrations
cat > supabase/migrations/0001_init.sql << 'HEREDOC'
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
HEREDOC

# ── Favicon ───────────────────────────────────────────────────────────────────
cat > public/favicon.svg << 'HEREDOC'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <rect width="64" height="64" rx="12" fill="#FFF8F1"/>
  <text x="50%" y="55%" dominant-baseline="middle" text-anchor="middle"
        font-family="system-ui,sans-serif" font-weight="700" font-size="20"
        fill="#F97316">aiyp</text>
</svg>
HEREDOC

# ── README.md ──────────────────────────────────────────────────────────────────
cat > README.md << 'HEREDOC'
#!/bin/bash
set -e
echo "=== Part 6: Final files ==="

