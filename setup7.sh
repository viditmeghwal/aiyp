#!/bin/bash
set -e
echo "=== Part 7: Missing files ==="

mkdir -p lib/verticals hooks

# ── lib/verticals/config.ts ─────────────────────────────────────────────────
cat > lib/verticals/config.ts << 'EOF_CFG'
export type VerticalSlug = "cafe" | "jewellery" | "hotel" | "marble" | "artefacts" | "clothing" | "general";

export interface VerticalDefinition {
  id: VerticalSlug;
  label: string;
  emoji: string;
  color: string;
  shortDescription: string;
  heroHeadline: string;
  heroSubline: string;
  painPoints: readonly string[];
  goals: readonly string[];
}

export const VERTICALS: Record<VerticalSlug, VerticalDefinition> = {
  cafe: { id: "cafe", label: "Café / Restaurant", emoji: "☕", color: "#10B981",
    shortDescription: "Local cafés, restaurants, and food spots.",
    heroHeadline: "Fill more tables. Build a local following.",
    heroSubline: "AI-crafted brand, menus, and social for local food businesses.",
    painPoints: ["Instagram goes quiet for weeks", "Menu photos look amateur", "Google reviews sit unanswered", "No seasonal promotions running"],
    goals: ["Get more foot traffic", "Build Instagram following", "Increase repeat customers", "Launch seasonal menus", "Better Google reviews"] },
  jewellery: { id: "jewellery", label: "Jewellery", emoji: "💎", color: "#FACC15",
    shortDescription: "Independent jewellery brands and designers.",
    heroHeadline: "Tell your story. Sell your craft.",
    heroSubline: "Brand, content, and SEO for independent jewellery makers.",
    painPoints: ["Product photos lack lifestyle", "No brand story told consistently", "Instagram bio is weak", "No email list capturing visitors"],
    goals: ["Build brand narrative", "Grow online store", "Increase Instagram engagement", "Launch email list", "Improve SEO"] },
  hotel: { id: "hotel", label: "Hotel / Stay", emoji: "🏨", color: "#0EA5E9",
    shortDescription: "Boutique hotels, homestays, and guest houses.",
    heroHeadline: "Book direct. Build loyalty.",
    heroSubline: "AI brand and marketing for boutique hotels and stays.",
    painPoints: ["Dependent on OTAs (high commission)", "Reviews not being answered", "Website load time is slow", "No seasonal campaigns"],
    goals: ["Increase direct bookings", "Improve TripAdvisor rank", "Build email list", "Launch seasonal offers", "Respond to all reviews"] },
  marble: { id: "marble", label: "Marble / Stone", emoji: "🪨", color: "#64748B",
    shortDescription: "Marble, stone, and building material businesses.",
    heroHeadline: "Win architect briefs. Close more quotes.",
    heroSubline: "B2B positioning for stone, marble, and material suppliers.",
    painPoints: ["No LinkedIn company presence", "Catalog is not architect-friendly", "No case studies published", "Weak SEO for trade terms"],
    goals: ["Generate architect leads", "Publish case studies", "Build LinkedIn presence", "Optimise catalog PDF", "Improve trade SEO"] },
  artefacts: { id: "artefacts", label: "Artefacts / Heritage", emoji: "🏺", color: "#A855F7",
    shortDescription: "Heritage artefacts, crafts, and collector pieces.",
    heroHeadline: "Tell the story buyers pay for.",
    heroSubline: "Brand and content for heritage artefact and craft sellers.",
    painPoints: ["Brand story is inconsistent", "No English export page", "Captions miss the heritage story", "No international enquiry form"],
    goals: ["Attract international buyers", "Tell heritage story clearly", "Improve product schema SEO", "Build newsletter", "Add export enquiry form"] },
  clothing: { id: "clothing", label: "Clothing / Apparel", emoji: "👗", color: "#F43F5E",
    shortDescription: "Independent clothing and apparel brands.",
    heroHeadline: "Drop better. Sell more.",
    heroSubline: "Brand, launch campaigns, and UGC strategy for apparel.",
    painPoints: ["No drop campaign strategy", "Brand voice inconsistent", "No UGC featured", "Email signup not prominent"],
    goals: ["Launch better drops", "Grow Instagram organically", "Build email list", "Feature UGC", "Improve lookbook reach"] },
  general: { id: "general", label: "Something else", emoji: "✨", color: "#F97316",
    shortDescription: "Any other small business building a brand.",
    heroHeadline: "Agency-quality brand. Pocket-sized price.",
    heroSubline: "AI brand building for any small business.",
    painPoints: ["Colors and fonts inconsistent", "Homepage unclear", "No blog or content plan", "Social posting is irregular"],
    goals: ["Clarify brand message", "Build content calendar", "Grow social presence", "Improve Google Business", "Launch blog"] },
};
EOF_CFG

# ── lib/verticals/questions.ts ──────────────────────────────────────────────
cat > lib/verticals/questions.ts << 'EOF_Q'
import type { VerticalSlug } from "./config";

export interface TaskTemplate {
  title: string;
  description: string;
  workflow_ref: string | null;
  phase: "week-1" | "week-2" | "weeks-3-4" | "month-2" | "month-3" | "ongoing";
  order_index: number;
}

const BASE: TaskTemplate[] = [
  { title: "Run your brand audit", description: "Full audit of your website, social, and SEO.", workflow_ref: "brand-audit", phase: "week-1", order_index: 1 },
  { title: "Build your Brand Starter Kit", description: "Logo concepts, palette, typography, voice.", workflow_ref: "brand-starter-kit", phase: "week-1", order_index: 2 },
  { title: "Generate your 30-day content calendar", description: "Posts, reel scripts, and schedule.", workflow_ref: "content-calendar", phase: "week-2", order_index: 3 },
  { title: "Clean up your Google Business Profile", description: "Hours, photos, posts, and reviews.", workflow_ref: null, phase: "week-2", order_index: 4 },
  { title: "Post your first 5 pieces of content", description: "Execute the first week of the calendar.", workflow_ref: null, phase: "weeks-3-4", order_index: 5 },
  { title: "Review analytics and adjust", description: "Check what is working and iterate.", workflow_ref: null, phase: "month-2", order_index: 6 },
  { title: "Plan month 3 campaigns", description: "Set next month's goals and content.", workflow_ref: null, phase: "month-3", order_index: 7 },
];

export function getTasksForVertical(_v: VerticalSlug): TaskTemplate[] { return BASE; }
EOF_Q

# ── lib/supabase/types.ts ───────────────────────────────────────────────────
cat > lib/supabase/types.ts << 'EOF_T'
export type Json = string | number | boolean | null | { [k: string]: Json | undefined } | Json[];

export type Database = {
  public: {
    Tables: {
      [table: string]: {
        Row: Record<string, unknown>;
        Insert: Record<string, unknown>;
        Update: Record<string, unknown>;
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
};
EOF_T

# ── hooks/use-toast.ts (shadcn copy) ────────────────────────────────────────
cat > hooks/use-toast.ts << 'EOF_TOAST'
"use client";
import * as React from "react";
import type { ToastActionElement, ToastProps } from "@/components/ui/toast";

const TOAST_LIMIT = 1;
const TOAST_REMOVE_DELAY = 1000000;

type ToasterToast = ToastProps & {
  id: string;
  title?: React.ReactNode;
  description?: React.ReactNode;
  action?: ToastActionElement;
};

let count = 0;
function genId() { count = (count + 1) % Number.MAX_SAFE_INTEGER; return count.toString(); }

type Action =
  | { type: "ADD_TOAST"; toast: ToasterToast }
  | { type: "UPDATE_TOAST"; toast: Partial<ToasterToast> & { id: string } }
  | { type: "DISMISS_TOAST"; toastId?: string }
  | { type: "REMOVE_TOAST"; toastId?: string };

interface State { toasts: ToasterToast[]; }

const toastTimeouts = new Map<string, ReturnType<typeof setTimeout>>();
const listeners: Array<(s: State) => void> = [];
let memoryState: State = { toasts: [] };

function dispatch(action: Action) {
  memoryState = reducer(memoryState, action);
  listeners.forEach((l) => l(memoryState));
}

function addToRemoveQueue(id: string) {
  if (toastTimeouts.has(id)) return;
  const t = setTimeout(() => { toastTimeouts.delete(id); dispatch({ type: "REMOVE_TOAST", toastId: id }); }, TOAST_REMOVE_DELAY);
  toastTimeouts.set(id, t);
}

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "ADD_TOAST": return { ...state, toasts: [action.toast, ...state.toasts].slice(0, TOAST_LIMIT) };
    case "UPDATE_TOAST": return { ...state, toasts: state.toasts.map((t) => t.id === action.toast.id ? { ...t, ...action.toast } : t) };
    case "DISMISS_TOAST": {
      const { toastId } = action;
      if (toastId) addToRemoveQueue(toastId); else state.toasts.forEach((t) => addToRemoveQueue(t.id));
      return { ...state, toasts: state.toasts.map((t) => (t.id === toastId || toastId === undefined) ? { ...t, open: false } : t) };
    }
    case "REMOVE_TOAST":
      if (action.toastId === undefined) return { ...state, toasts: [] };
      return { ...state, toasts: state.toasts.filter((t) => t.id !== action.toastId) };
  }
}

type ToastInput = Omit<ToasterToast, "id">;

function toast(props: ToastInput) {
  const id = genId();
  const dismiss = () => dispatch({ type: "DISMISS_TOAST", toastId: id });
  dispatch({ type: "ADD_TOAST", toast: { ...props, id, open: true, onOpenChange: (open) => { if (!open) dismiss(); } } });
  return { id, dismiss, update: (p: Partial<ToasterToast>) => dispatch({ type: "UPDATE_TOAST", toast: { ...p, id } }) };
}

function useToast() {
  const [state, setState] = React.useState<State>(memoryState);
  React.useEffect(() => {
    listeners.push(setState);
    return () => { const i = listeners.indexOf(setState); if (i > -1) listeners.splice(i, 1); };
  }, [state]);
  return { ...state, toast, dismiss: (toastId?: string) => dispatch({ type: "DISMISS_TOAST", toastId }) };
}

export { useToast, toast };
EOF_TOAST

# ── app/layout.tsx (overwrite to remove missing local fonts) ────────────────
cat > app/layout.tsx << 'EOF_LAYOUT'
import type { Metadata } from "next";
import { Inter, Fraunces } from "next/font/google";
import { PostHogProvider } from "@/components/providers/PostHogProvider";
import "./globals.css";

const inter = Inter({ subsets: ["latin"], variable: "--font-geist-sans", display: "swap" });
const fraunces = Fraunces({ subsets: ["latin"], style: "italic", weight: ["400", "600", "700"], variable: "--font-fraunces", display: "swap" });

export const metadata: Metadata = {
  title: { default: "Agency in Your Pocket", template: "%s | Agency in Your Pocket" },
  description: "Everything a real agency does — right in your pocket.",
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000"),
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${fraunces.variable}`}>
      <body className="antialiased"><PostHogProvider>{children}</PostHogProvider></body>
    </html>
  );
}
EOF_LAYOUT

echo "=== Part 7 done ✓ ==="
echo ""
echo "Next: pnpm install, then pnpm dlx shadcn@latest add (long list from README)"
