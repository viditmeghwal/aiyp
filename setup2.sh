# ── lib/ structure ─────────────────────────────────────────────────────────────
mkdir -p lib/analytics lib/emails lib/integrations/anthropic lib/integrations/ideogram \
  lib/integrations/inngest lib/integrations/openai lib/integrations/resend \
  lib/prompts/shared lib/prompts/cafe lib/prompts/jewellery lib/prompts/hotel \
  lib/prompts/marble lib/prompts/artefacts lib/prompts/clothing lib/prompts/general \
  lib/stripe lib/supabase lib/verticals lib/workflows

# ── lib/utils.ts ──────────────────────────────────────────────────────────────
cat > lib/utils.ts << 'HEREDOC'
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
HEREDOC

# ── lib/analytics/posthog.ts ──────────────────────────────────────────────────
cat > lib/analytics/posthog.ts << 'HEREDOC'
import { PostHog } from "posthog-node";

let _posthogServer: PostHog | null = null;

export function getPostHogServer(): PostHog | null {
  if (!process.env.NEXT_PUBLIC_POSTHOG_KEY) return null;
  if (!_posthogServer) {
    _posthogServer = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY, {
      host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://app.posthog.com",
      flushAt: 1,
      flushInterval: 0,
    });
  }
  return _posthogServer;
}

export function track(userId: string, event: string, properties?: Record<string, unknown>) {
  const ph = getPostHogServer();
  if (!ph) return;
  ph.capture({ distinctId: userId, event, properties });
}
HEREDOC

# ── lib/supabase/client.ts ────────────────────────────────────────────────────
cat > lib/supabase/client.ts << 'HEREDOC'
import { createBrowserClient } from "@supabase/ssr";
import type { Database } from "./types";

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
HEREDOC

# ── lib/supabase/server.ts ────────────────────────────────────────────────────
cat > lib/supabase/server.ts << 'HEREDOC'
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { Database } from "./types";

export function createClient() {
  const cookieStore = cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll(); },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch { /* Server Component — ignore */ }
        },
      },
    }
  );
}

export function createServiceRoleClient() {
  const cookieStore = cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll(); },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch { /* ignore */ }
        },
      },
    }
  );
}
HEREDOC

# ── lib/supabase/middleware.ts ────────────────────────────────────────────────
cat > lib/supabase/middleware.ts << 'HEREDOC'
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();
  return { supabaseResponse, user };
}
HEREDOC

# ── lib/stripe/client.ts ──────────────────────────────────────────────────────
cat > lib/stripe/client.ts << 'HEREDOC'
import Stripe from "stripe";

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY ?? "", {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  apiVersion: "2025-01-27.acacia" as any,
});
HEREDOC

# ── lib/stripe/plans.ts ───────────────────────────────────────────────────────
cat > lib/stripe/plans.ts << 'HEREDOC'
export interface PlanDefinition {
  name: string;
  price: number;
  priceId: string;
  features: string[];
  limits: { workflowsPerMonth: number; deliverables: number; businesses: number };
}

export const PLANS: Record<string, PlanDefinition> = {
  free: {
    name: "Free", price: 0, priceId: "",
    features: ["1 brand audit per month", "Brand Starter Kit", "30-day content calendar", "Basic analytics"],
    limits: { workflowsPerMonth: 3, deliverables: 5, businesses: 1 },
  },
  starter: {
    name: "Starter", price: 29, priceId: process.env.STRIPE_PRICE_STARTER ?? "",
    features: ["10 AI workflow runs/month", "All deliverable types", "Instagram + Google integrations", "Email support", "PDF exports"],
    limits: { workflowsPerMonth: 10, deliverables: 50, businesses: 1 },
  },
  growth: {
    name: "Growth", price: 59, priceId: process.env.STRIPE_PRICE_GROWTH ?? "",
    features: ["Unlimited AI workflow runs", "Priority processing", "Advanced analytics", "White-label deliverables", "Priority support", "3 businesses"],
    limits: { workflowsPerMonth: -1, deliverables: -1, businesses: 3 },
  },
  agency: {
    name: "Agency", price: 129, priceId: process.env.STRIPE_PRICE_AGENCY ?? "",
    features: ["Everything in Growth", "10 businesses", "Team access (3 seats)", "Custom workflow builder", "Dedicated account manager", "API access"],
    limits: { workflowsPerMonth: -1, deliverables: -1, businesses: 10 },
  },
};
HEREDOC

# ── lib/integrations/inngest/client.ts ────────────────────────────────────────
cat > lib/integrations/inngest/client.ts << 'HEREDOC'
import { Inngest } from "inngest";

export const inngest = new Inngest({ id: "aiyp" });
HEREDOC

# ── lib/integrations/resend/client.ts ────────────────────────────────────────
cat > lib/integrations/resend/client.ts << 'HEREDOC'
import { Resend } from "resend";

export const resend = new Resend(process.env.RESEND_API_KEY!);
export const FROM_EMAIL = process.env.FROM_EMAIL ?? "hello@agencyinyourpocket.com";
HEREDOC

# ── lib/integrations/anthropic/client.ts ─────────────────────────────────────
cat > lib/integrations/anthropic/client.ts << 'HEREDOC'
export const anthropic = {
  messages: {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    create: async (_params: unknown): Promise<never> => {
      throw new Error("Install @anthropic-ai/sdk and set ANTHROPIC_API_KEY");
    },
  },
};
HEREDOC

# ── lib/integrations/openai/client.ts ────────────────────────────────────────
cat > lib/integrations/openai/client.ts << 'HEREDOC'
export const openai = {
  chat: {
    completions: {
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      create: async (_params: unknown): Promise<never> => {
        throw new Error("Install openai package and set OPENAI_API_KEY");
      },
    },
  },
};
HEREDOC

# ── lib/integrations/ideogram/client.ts ──────────────────────────────────────
cat > lib/integrations/ideogram/client.ts << 'HEREDOC'
const IDEOGRAM_API_URL = "https://api.ideogram.ai";

interface IdeogramGenerateParams {
  prompt: string;
  model?: "V_2" | "V_2_TURBO";
  resolution?: string;
  style_type?: "REALISTIC" | "DESIGN" | "GENERAL" | "RENDER_3D" | "ANIME";
}

export async function generateImage(params: IdeogramGenerateParams): Promise<{ url: string }[]> {
  const response = await fetch(`${IDEOGRAM_API_URL}/generate`, {
    method: "POST",
    headers: { "Api-Key": process.env.IDEOGRAM_API_KEY!, "Content-Type": "application/json" },
    body: JSON.stringify({
      image_request: {
        prompt: params.prompt,
        model: params.model ?? "V_2",
        resolution: params.resolution ?? "RESOLUTION_1024_1024",
        style_type: params.style_type ?? "DESIGN",
      },
    }),
  });
  if (!response.ok) throw new Error(`Ideogram API error: ${response.statusText}`);
  const data = await response.json() as { data: { url: string }[] };
  return data.data;
}
HEREDOC

# ── lib/workflows/types.ts ────────────────────────────────────────────────────
cat > lib/workflows/types.ts << 'HEREDOC'
import type { VerticalSlug } from "@/lib/verticals/config";

export interface WorkflowContext {
  businessId: string;
  userId: string;
  vertical: VerticalSlug;
  businessName: string;
  taskId?: string;
  runId: string;
  inputs: Record<string, unknown>;
}

export interface WorkflowResult {
  deliverableId?: string;
  summary?: string;
  outputs?: Record<string, unknown>;
  error?: string;
}
HEREDOC

# ── lib/workflows/registry.ts ─────────────────────────────────────────────────
cat > lib/workflows/registry.ts << 'HEREDOC'
export interface WorkflowDefinition {
  ref: string;
  name: string;
  description: string;
  estimatedMinutes: number;
  steps: string[];
  deliverableType: "audit" | "brand_kit" | "content_calendar" | "reel_scripts" | "website_copy" | "other";
}

export const WORKFLOW_REGISTRY: Record<string, WorkflowDefinition> = {
  "brand-audit": {
    ref: "brand-audit",
    name: "Brand Audit",
    description: "A full audit of your brand — website, social, SEO, and visual consistency.",
    estimatedMinutes: 3,
    deliverableType: "audit",
    steps: [
      "Scanning your digital footprint…",
      "Analysing website structure and copy…",
      "Reviewing social media presence…",
      "Checking SEO fundamentals…",
      "Evaluating visual consistency…",
      "Generating audit report…",
      "Finalising your Brand Audit…",
    ],
  },
  "brand-starter-kit": {
    ref: "brand-starter-kit",
    name: "Brand Starter Kit",
    description: "Your brand identity — logo concepts, colour palette, typography, and voice guide.",
    estimatedMinutes: 4,
    deliverableType: "brand_kit",
    steps: [
      "Researching your vertical and competitors…",
      "Generating logo concepts…",
      "Building colour palette…",
      "Selecting typography…",
      "Writing brand voice guide…",
      "Assembling your Brand Starter Kit…",
      "Finalising deliverable…",
    ],
  },
  "content-calendar": {
    ref: "content-calendar",
    name: "30-Day Content Calendar",
    description: "30 Instagram post ideas, 5 reel scripts, and optimal posting times for your vertical.",
    estimatedMinutes: 3,
    deliverableType: "content_calendar",
    steps: [
      "Analysing trending content in your vertical…",
      "Researching optimal posting times…",
      "Writing post ideas for Week 1…",
      "Writing post ideas for Weeks 2–3…",
      "Crafting reel scripts…",
      "Building posting schedule…",
      "Finalising your Content Calendar…",
    ],
  },
};
HEREDOC

# ── lib/workflows/free-audit.ts ───────────────────────────────────────────────
cat > lib/workflows/free-audit.ts << 'HEREDOC'
import type { VerticalSlug } from "@/lib/verticals/config";

interface TeaserAudit {
  businessName: string;
  vertical: string;
  overallScore: number;
  scores: { brand: number; content: number; seo: number; social: number };
  working: Array<{ area: string; observation: string }>;
  broken: Array<{ area: string; issue: string; severity: "high" | "medium" }>;
}

const verticalData: Record<VerticalSlug | "general", { working: string[]; broken: string[] }> = {
  cafe: {
    working: ["Google Business Profile is claimed", "Instagram account is active", "Menu is listed on your website"],
    broken: ["No consistent brand colors across platforms", "Google Maps listing missing opening hours", "Last Instagram post was 18 days ago", "Menu images are low resolution", "No Google Posts in the last 30 days"],
  },
  jewellery: {
    working: ["Instagram grid has consistent product photos", "Website has an About page", "Product descriptions are written"],
    broken: ["No brand story or founder narrative visible", "Product images lack lifestyle context", "Instagram bio doesn't include a clear CTA", "No email capture on website", "Collection pages missing SEO titles"],
  },
  hotel: {
    working: ["Google Business Profile verified", "TripAdvisor listing is active", "Website shows room photos"],
    broken: ["No direct booking incentive vs. OTAs", "Unanswered Google reviews (last 3 weeks)", "Instagram last posted 24 days ago", "No seasonal promotions visible", "Website mobile experience is slow (5.2s load)"],
  },
  marble: {
    working: ["Product catalog PDF exists", "Website lists product specifications", "Business email is professional"],
    broken: ["No LinkedIn company page found", "Catalog not optimized for architects", "No case studies or project gallery", "Website not indexed well for B2B search terms", "No lead capture form for trade inquiries"],
  },
  artefacts: {
    working: ["Product photography quality is strong", "Heritage story is mentioned on homepage", "Export market listed on website"],
    broken: ["Brand story not told consistently across pages", "No English-language export positioning page", "Instagram captions don't mention story/heritage", "No international buyer inquiry form", "Missing structured data for product schema"],
  },
  clothing: {
    working: ["Instagram profile is complete", "Collection photos are high quality", "Website is mobile-friendly"],
    broken: ["No drop campaign or launch strategy visible", "Email list signup not prominently featured", "Brand voice inconsistent across captions", "Lookbook not linked from website", "No user-generated content featured"],
  },
  general: {
    working: ["Website is live and accessible", "Contact information is visible", "Social media accounts exist"],
    broken: ["Brand colors and fonts are inconsistent", "Homepage doesn't clearly state what you do", "No blog or content strategy visible", "Google Business Profile incomplete", "Social media posting is irregular"],
  },
};

export function generateTeaserAudit(vertical: string, businessName: string): TeaserAudit {
  const data = verticalData[vertical as VerticalSlug] ?? verticalData.general;
  const seed = businessName.length % 20;
  const base = 38 + seed;
  return {
    businessName,
    vertical,
    overallScore: base + 5,
    scores: {
      brand: Math.min(base + 2, 65),
      content: Math.min(base + 8, 70),
      seo: Math.min(base - 5, 55),
      social: Math.min(base + 12, 72),
    },
    working: data.working.map((obs, i) => ({ area: ["Brand", "Content", "SEO"][i % 3], observation: obs })),
    broken: data.broken.map((issue, i) => ({
      area: ["SEO", "Social", "Brand", "Content", "Technical"][i % 5],
      issue,
      severity: (i < 2 ? "high" : "medium") as "high" | "medium",
    })),
  };
}
HEREDOC

# ── lib/prompts/shared/system.ts ──────────────────────────────────────────────
cat > lib/prompts/shared/system.ts << 'HEREDOC'
export const BASE_SYSTEM_PROMPT = `You are an expert brand strategist and marketing consultant for Agency in Your Pocket. You help solo founders and small business owners build professional, high-converting brands without agency fees. Always be specific, actionable, and vertical-aware in your recommendations.`;
HEREDOC

# ── lib/prompts — one stub per vertical ──────────────────────────────────────
for v in cafe jewellery hotel marble artefacts clothing general; do
cat > lib/prompts/$v/brand-audit.ts << HEREDOC
import { BASE_SYSTEM_PROMPT } from "@/lib/prompts/shared/system";

export function getBrandAuditPrompt(businessName: string): string {
  return \`\${BASE_SYSTEM_PROMPT}

Perform a comprehensive brand audit for "\${businessName}", a $v business. Analyse: brand identity, digital presence, social media, SEO, and content strategy. Return a structured JSON report.\`;
}
HEREDOC
done

echo "Part 2 done ✓"

cd ~/aiyp
bash setup2.sh# ── lib/ structure ─────────────────────────────────────────────────────────────
mkdir -p lib/analytics lib/emails lib/integrations/anthropic lib/integrations/ideogram \
  lib/integrations/inngest lib/integrations/openai lib/integrations/resend \
  lib/prompts/shared lib/prompts/cafe lib/prompts/jewellery lib/prompts/hotel \
  lib/prompts/marble lib/prompts/artefacts lib/prompts/clothing lib/prompts/general \
  lib/stripe lib/supabase lib/verticals lib/workflows

# ── lib/utils.ts ──────────────────────────────────────────────────────────────
cat > lib/utils.ts << 'HEREDOC'
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
HEREDOC

# ── lib/analytics/posthog.ts ──────────────────────────────────────────────────
cat > lib/analytics/posthog.ts << 'HEREDOC'
import { PostHog } from "posthog-node";

let _posthogServer: PostHog | null = null;

export function getPostHogServer(): PostHog | null {
  if (!process.env.NEXT_PUBLIC_POSTHOG_KEY) return null;
  if (!_posthogServer) {
    _posthogServer = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY, {
      host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://app.posthog.com",
      flushAt: 1,
      flushInterval: 0,
    });
  }
  return _posthogServer;
}

export function track(userId: string, event: string, properties?: Record<string, unknown>) {
  const ph = getPostHogServer();
  if (!ph) return;
  ph.capture({ distinctId: userId, event, properties });
}
HEREDOC

# ── lib/supabase/client.ts ────────────────────────────────────────────────────
cat > lib/supabase/client.ts << 'HEREDOC'
import { createBrowserClient } from "@supabase/ssr";
import type { Database } from "./types";

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
HEREDOC

# ── lib/supabase/server.ts ────────────────────────────────────────────────────
cat > lib/supabase/server.ts << 'HEREDOC'
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { Database } from "./types";

export function createClient() {
  const cookieStore = cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll(); },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch { /* Server Component — ignore */ }
        },
      },
    }
  );
}

export function createServiceRoleClient() {
  const cookieStore = cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll(); },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch { /* ignore */ }
        },
      },
    }
  );
}
HEREDOC

# ── lib/supabase/middleware.ts ────────────────────────────────────────────────
cat > lib/supabase/middleware.ts << 'HEREDOC'
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();
  return { supabaseResponse, user };
}
HEREDOC

# ── lib/stripe/client.ts ──────────────────────────────────────────────────────
cat > lib/stripe/client.ts << 'HEREDOC'
import Stripe from "stripe";

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY ?? "", {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  apiVersion: "2025-01-27.acacia" as any,
});
HEREDOC

# ── lib/stripe/plans.ts ───────────────────────────────────────────────────────
cat > lib/stripe/plans.ts << 'HEREDOC'
export interface PlanDefinition {
  name: string;
  price: number;
  priceId: string;
  features: string[];
  limits: { workflowsPerMonth: number; deliverables: number; businesses: number };
}

export const PLANS: Record<string, PlanDefinition> = {
  free: {
    name: "Free", price: 0, priceId: "",
    features: ["1 brand audit per month", "Brand Starter Kit", "30-day content calendar", "Basic analytics"],
    limits: { workflowsPerMonth: 3, deliverables: 5, businesses: 1 },
  },
  starter: {
    name: "Starter", price: 29, priceId: process.env.STRIPE_PRICE_STARTER ?? "",
    features: ["10 AI workflow runs/month", "All deliverable types", "Instagram + Google integrations", "Email support", "PDF exports"],
    limits: { workflowsPerMonth: 10, deliverables: 50, businesses: 1 },
  },
  growth: {
    name: "Growth", price: 59, priceId: process.env.STRIPE_PRICE_GROWTH ?? "",
    features: ["Unlimited AI workflow runs", "Priority processing", "Advanced analytics", "White-label deliverables", "Priority support", "3 businesses"],
    limits: { workflowsPerMonth: -1, deliverables: -1, businesses: 3 },
  },
  agency: {
    name: "Agency", price: 129, priceId: process.env.STRIPE_PRICE_AGENCY ?? "",
    features: ["Everything in Growth", "10 businesses", "Team access (3 seats)", "Custom workflow builder", "Dedicated account manager", "API access"],
    limits: { workflowsPerMonth: -1, deliverables: -1, businesses: 10 },
  },
};
HEREDOC

# ── lib/integrations/inngest/client.ts ────────────────────────────────────────
cat > lib/integrations/inngest/client.ts << 'HEREDOC'
import { Inngest } from "inngest";

export const inngest = new Inngest({ id: "aiyp" });
HEREDOC

# ── lib/integrations/resend/client.ts ────────────────────────────────────────
cat > lib/integrations/resend/client.ts << 'HEREDOC'
import { Resend } from "resend";

export const resend = new Resend(process.env.RESEND_API_KEY!);
export const FROM_EMAIL = process.env.FROM_EMAIL ?? "hello@agencyinyourpocket.com";
HEREDOC

# ── lib/integrations/anthropic/client.ts ─────────────────────────────────────
cat > lib/integrations/anthropic/client.ts << 'HEREDOC'
export const anthropic = {
  messages: {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    create: async (_params: unknown): Promise<never> => {
      throw new Error("Install @anthropic-ai/sdk and set ANTHROPIC_API_KEY");
    },
  },
};
HEREDOC

# ── lib/integrations/openai/client.ts ────────────────────────────────────────
cat > lib/integrations/openai/client.ts << 'HEREDOC'
export const openai = {
  chat: {
    completions: {
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      create: async (_params: unknown): Promise<never> => {
        throw new Error("Install openai package and set OPENAI_API_KEY");
      },
    },
  },
};
HEREDOC

# ── lib/integrations/ideogram/client.ts ──────────────────────────────────────
cat > lib/integrations/ideogram/client.ts << 'HEREDOC'
const IDEOGRAM_API_URL = "https://api.ideogram.ai";

interface IdeogramGenerateParams {
  prompt: string;
  model?: "V_2" | "V_2_TURBO";
  resolution?: string;
  style_type?: "REALISTIC" | "DESIGN" | "GENERAL" | "RENDER_3D" | "ANIME";
}

export async function generateImage(params: IdeogramGenerateParams): Promise<{ url: string }[]> {
  const response = await fetch(`${IDEOGRAM_API_URL}/generate`, {
    method: "POST",
    headers: { "Api-Key": process.env.IDEOGRAM_API_KEY!, "Content-Type": "application/json" },
    body: JSON.stringify({
      image_request: {
        prompt: params.prompt,
        model: params.model ?? "V_2",
        resolution: params.resolution ?? "RESOLUTION_1024_1024",
        style_type: params.style_type ?? "DESIGN",
      },
    }),
  });
  if (!response.ok) throw new Error(`Ideogram API error: ${response.statusText}`);
  const data = await response.json() as { data: { url: string }[] };
  return data.data;
}
HEREDOC

# ── lib/workflows/types.ts ────────────────────────────────────────────────────
cat > lib/workflows/types.ts << 'HEREDOC'
import type { VerticalSlug } from "@/lib/verticals/config";

export interface WorkflowContext {
  businessId: string;
  userId: string;
  vertical: VerticalSlug;
  businessName: string;
  taskId?: string;
  runId: string;
  inputs: Record<string, unknown>;
}

export interface WorkflowResult {
  deliverableId?: string;
  summary?: string;
  outputs?: Record<string, unknown>;
  error?: string;
}
HEREDOC

# ── lib/workflows/registry.ts ─────────────────────────────────────────────────
cat > lib/workflows/registry.ts << 'HEREDOC'
export interface WorkflowDefinition {
  ref: string;
  name: string;
  description: string;
  estimatedMinutes: number;
  steps: string[];
  deliverableType: "audit" | "brand_kit" | "content_calendar" | "reel_scripts" | "website_copy" | "other";
}

export const WORKFLOW_REGISTRY: Record<string, WorkflowDefinition> = {
  "brand-audit": {
    ref: "brand-audit",
    name: "Brand Audit",
    description: "A full audit of your brand — website, social, SEO, and visual consistency.",
    estimatedMinutes: 3,
    deliverableType: "audit",
    steps: [
      "Scanning your digital footprint…",
      "Analysing website structure and copy…",
      "Reviewing social media presence…",
      "Checking SEO fundamentals…",
      "Evaluating visual consistency…",
      "Generating audit report…",
      "Finalising your Brand Audit…",
    ],
  },
  "brand-starter-kit": {
    ref: "brand-starter-kit",
    name: "Brand Starter Kit",
    description: "Your brand identity — logo concepts, colour palette, typography, and voice guide.",
    estimatedMinutes: 4,
    deliverableType: "brand_kit",
    steps: [
      "Researching your vertical and competitors…",
      "Generating logo concepts…",
      "Building colour palette…",
      "Selecting typography…",
      "Writing brand voice guide…",
      "Assembling your Brand Starter Kit…",
      "Finalising deliverable…",
    ],
  },
  "content-calendar": {
    ref: "content-calendar",
    name: "30-Day Content Calendar",
    description: "30 Instagram post ideas, 5 reel scripts, and optimal posting times for your vertical.",
    estimatedMinutes: 3,
    deliverableType: "content_calendar",
    steps: [
      "Analysing trending content in your vertical…",
      "Researching optimal posting times…",
      "Writing post ideas for Week 1…",
      "Writing post ideas for Weeks 2–3…",
      "Crafting reel scripts…",
      "Building posting schedule…",
      "Finalising your Content Calendar…",
    ],
  },
};
HEREDOC

# ── lib/workflows/free-audit.ts ───────────────────────────────────────────────
cat > lib/workflows/free-audit.ts << 'HEREDOC'
import type { VerticalSlug } from "@/lib/verticals/config";

interface TeaserAudit {
  businessName: string;
  vertical: string;
  overallScore: number;
  scores: { brand: number; content: number; seo: number; social: number };
  working: Array<{ area: string; observation: string }>;
  broken: Array<{ area: string; issue: string; severity: "high" | "medium" }>;
}

const verticalData: Record<VerticalSlug | "general", { working: string[]; broken: string[] }> = {
  cafe: {
    working: ["Google Business Profile is claimed", "Instagram account is active", "Menu is listed on your website"],
    broken: ["No consistent brand colors across platforms", "Google Maps listing missing opening hours", "Last Instagram post was 18 days ago", "Menu images are low resolution", "No Google Posts in the last 30 days"],
  },
  jewellery: {
    working: ["Instagram grid has consistent product photos", "Website has an About page", "Product descriptions are written"],
    broken: ["No brand story or founder narrative visible", "Product images lack lifestyle context", "Instagram bio doesn't include a clear CTA", "No email capture on website", "Collection pages missing SEO titles"],
  },
  hotel: {
    working: ["Google Business Profile verified", "TripAdvisor listing is active", "Website shows room photos"],
    broken: ["No direct booking incentive vs. OTAs", "Unanswered Google reviews (last 3 weeks)", "Instagram last posted 24 days ago", "No seasonal promotions visible", "Website mobile experience is slow (5.2s load)"],
  },
  marble: {
    working: ["Product catalog PDF exists", "Website lists product specifications", "Business email is professional"],
    broken: ["No LinkedIn company page found", "Catalog not optimized for architects", "No case studies or project gallery", "Website not indexed well for B2B search terms", "No lead capture form for trade inquiries"],
  },
  artefacts: {
    working: ["Product photography quality is strong", "Heritage story is mentioned on homepage", "Export market listed on website"],
    broken: ["Brand story not told consistently across pages", "No English-language export positioning page", "Instagram captions don't mention story/heritage", "No international buyer inquiry form", "Missing structured data for product schema"],
  },
  clothing: {
    working: ["Instagram profile is complete", "Collection photos are high quality", "Website is mobile-friendly"],
    broken: ["No drop campaign or launch strategy visible", "Email list signup not prominently featured", "Brand voice inconsistent across captions", "Lookbook not linked from website", "No user-generated content featured"],
  },
  general: {
    working: ["Website is live and accessible", "Contact information is visible", "Social media accounts exist"],
    broken: ["Brand colors and fonts are inconsistent", "Homepage doesn't clearly state what you do", "No blog or content strategy visible", "Google Business Profile incomplete", "Social media posting is irregular"],
  },
};

export function generateTeaserAudit(vertical: string, businessName: string): TeaserAudit {
  const data = verticalData[vertical as VerticalSlug] ?? verticalData.general;
  const seed = businessName.length % 20;
  const base = 38 + seed;
  return {
    businessName,
    vertical,
    overallScore: base + 5,
    scores: {
      brand: Math.min(base + 2, 65),
      content: Math.min(base + 8, 70),
      seo: Math.min(base - 5, 55),
      social: Math.min(base + 12, 72),
    },
    working: data.working.map((obs, i) => ({ area: ["Brand", "Content", "SEO"][i % 3], observation: obs })),
    broken: data.broken.map((issue, i) => ({
      area: ["SEO", "Social", "Brand", "Content", "Technical"][i % 5],
      issue,
      severity: (i < 2 ? "high" : "medium") as "high" | "medium",
    })),
  };
}
HEREDOC

# ── lib/prompts/shared/system.ts ──────────────────────────────────────────────
cat > lib/prompts/shared/system.ts << 'HEREDOC'
export const BASE_SYSTEM_PROMPT = `You are an expert brand strategist and marketing consultant for Agency in Your Pocket. You help solo founders and small business owners build professional, high-converting brands without agency fees. Always be specific, actionable, and vertical-aware in your recommendations.`;
HEREDOC

# ── lib/prompts — one stub per vertical ──────────────────────────────────────
for v in cafe jewellery hotel marble artefacts clothing general; do
cat > lib/prompts/$v/brand-audit.ts << HEREDOC
import { BASE_SYSTEM_PROMPT } from "@/lib/prompts/shared/system";

export function getBrandAuditPrompt(businessName: string): string {
  return \`\${BASE_SYSTEM_PROMPT}

Perform a comprehensive brand audit for "\${businessName}", a $v business. Analyse: brand identity, digital presence, social media, SEO, and content strategy. Return a structured JSON report.\`;
}
HEREDOC
done

echo "Part 2 done ✓"
