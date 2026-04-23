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
