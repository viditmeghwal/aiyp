import { auditStore } from "@/app/api/free-audit/start/route";

export async function GET(_request: Request, { params }: { params: { id: string } }) {
  const audit = auditStore.get(params.id);
  if (!audit) return Response.json({ error: "Audit not found" }, { status: 404 });
  return Response.json(audit);
}
