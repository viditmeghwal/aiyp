import { notFound } from "next/navigation";
import { TeaserResult } from "@/components/audit/TeaserResult";
import { auditStore } from "@/app/api/free-audit/start/route";

export default function AuditResultPage({ params }: { params: { id: string } }) {
  const audit = auditStore.get(params.id);
  if (!audit || audit.status !== "complete" || !audit.result) notFound();
  return (
    <div className="bg-pocket-cream min-h-screen">
      <TeaserResult result={audit.result} />
    </div>
  );
}
