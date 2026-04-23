import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { DeliverableCard } from "@/components/app/DeliverableCard";
import { EmptyState } from "@/components/common/EmptyState";
import { PageTransition } from "@/components/common/PageTransition";
import { FolderOpen } from "lucide-react";

export const metadata = { title: "Deliverables | Agency in Your Pocket" };
type DeliverableType = "audit" | "brand_kit" | "content_calendar" | "reel_scripts" | "website_copy" | "other";

export default async function DeliverablesPage({ searchParams }: { searchParams: { type?: string } }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: business } = await supabase.from("businesses").select("id").eq("user_id", user.id).eq("onboarding_completed", true).single();
  if (!business) redirect("/onboarding");

  let query = supabase.from("deliverables").select("id, title, type, file_url, created_at").eq("business_id", business.id).order("created_at", { ascending: false });
  const validTypes = ["audit", "brand_kit", "content_calendar", "reel_scripts", "website_copy", "other"];
  if (searchParams.type && searchParams.type !== "all" && validTypes.includes(searchParams.type)) {
    query = query.eq("type", searchParams.type as DeliverableType);
  }

  const { data: deliverables } = await query;
  const items = deliverables ?? [];

  return (
    <PageTransition>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-ink-900">Deliverables</h1>
        <p className="text-sm text-ink-500 mt-0.5">Everything your AI agency has produced for you.</p>
      </div>
      {items.length === 0 ? (
        <EmptyState icon={FolderOpen} title="No deliverables yet" description="Complete a task with an AI workflow to generate your first deliverable." action={{ label: "Go to dashboard", href: "/dashboard" }} />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {items.map((d) => <DeliverableCard key={d.id} {...d} type={d.type as DeliverableType} />)}
        </div>
      )}
    </PageTransition>
  );
}
