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
