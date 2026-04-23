import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { PageTransition } from "@/components/common/PageTransition";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Download, ArrowLeft } from "lucide-react";
import Link from "next/link";

export default async function DeliverablePage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: deliverable } = await supabase.from("deliverables").select("*, businesses!inner(user_id)").eq("id", params.id).single();
  if (!deliverable) notFound();

  const date = new Date(deliverable.created_at).toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" });
  const metadata = deliverable.metadata as Record<string, unknown>;

  return (
    <PageTransition>
      <div className="mb-6">
        <Link href="/deliverables" className="flex items-center gap-1.5 text-sm text-ink-500 hover:text-pocket-orange mb-4">
          <ArrowLeft className="w-4 h-4" />Deliverables
        </Link>
        <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-ink-900">{deliverable.title}</h1>
            <div className="flex items-center gap-2 mt-1">
              <Badge variant="secondary" className="capitalize">{deliverable.type.replace("_", " ")}</Badge>
              <span className="text-sm text-ink-400">{date}</span>
            </div>
          </div>
          {deliverable.file_url && (
            <Button asChild className="bg-pocket-orange hover:bg-pocket-orange-dark text-white gap-2 shrink-0">
              <a href={deliverable.file_url} download><Download className="w-4 h-4" />Download</a>
            </Button>
          )}
        </div>
      </div>
      <div className="bg-white rounded-xl border border-ink-200 p-6">
        {metadata?.summary ? (
          <pre className="whitespace-pre-wrap font-sans text-sm leading-relaxed text-ink-700">{String(metadata.summary)}</pre>
        ) : (
          <p className="text-sm text-ink-500">Download the file to view the full content.</p>
        )}
      </div>
    </PageTransition>
  );
}
