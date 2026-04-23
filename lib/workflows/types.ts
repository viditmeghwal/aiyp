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
