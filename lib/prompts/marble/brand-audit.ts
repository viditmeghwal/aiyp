import { BASE_SYSTEM_PROMPT } from "@/lib/prompts/shared/system";

export function getBrandAuditPrompt(businessName: string): string {
  return `${BASE_SYSTEM_PROMPT}

Perform a comprehensive brand audit for "${businessName}", a marble business. Analyse: brand identity, digital presence, social media, SEO, and content strategy. Return a structured JSON report.`;
}
