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
