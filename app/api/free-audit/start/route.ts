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
