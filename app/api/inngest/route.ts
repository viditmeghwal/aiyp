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
