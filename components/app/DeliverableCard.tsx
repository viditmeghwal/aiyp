import Link from "next/link";
import { Download, FileText, Image, Calendar, BarChart3, Type, Package } from "lucide-react";
import { Badge } from "@/components/ui/badge";

type DeliverableType = "audit" | "brand_kit" | "content_calendar" | "reel_scripts" | "website_copy" | "other";
interface DeliverableCardProps { id: string; title: string; type: DeliverableType; file_url: string | null; created_at: string; }

const TYPE_CONFIG: Record<DeliverableType, { label: string; icon: React.ComponentType<{ className?: string }>; color: string }> = {
  audit: { label: "Brand Audit", icon: BarChart3, color: "bg-blue-50 text-blue-700" },
  brand_kit: { label: "Brand Kit", icon: Package, color: "bg-pocket-peach text-pocket-orange" },
  content_calendar: { label: "Content Calendar", icon: Calendar, color: "bg-emerald-50 text-emerald-700" },
  reel_scripts: { label: "Reel Scripts", icon: Image, color: "bg-purple-50 text-purple-700" },
  website_copy: { label: "Website Copy", icon: Type, color: "bg-amber-50 text-amber-700" },
  other: { label: "Document", icon: FileText, color: "bg-ink-100 text-ink-700" },
};

export function DeliverableCard({ id, title, type, file_url, created_at }: DeliverableCardProps) {
  const config = TYPE_CONFIG[type] ?? TYPE_CONFIG.other;
  const Icon = config.icon;
  const date = new Date(created_at).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" });
  return (
    <Link href={`/deliverables/${id}`}>
      <div className="bg-white rounded-xl border border-ink-200 p-4 hover:shadow-sm hover:border-ink-300 transition-all flex flex-col gap-3">
        <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${config.color}`}><Icon className="w-5 h-5" /></div>
        <div className="flex-1"><p className="text-sm font-semibold text-ink-900 leading-snug">{title}</p><p className="text-xs text-ink-400 mt-0.5">{date}</p></div>
        <div className="flex items-center justify-between">
          <Badge variant="secondary" className="text-[10px]">{config.label}</Badge>
          {file_url && <a href={file_url} download onClick={(e) => e.stopPropagation()} className="p-1.5 rounded-lg hover:bg-ink-100 transition-colors"><Download className="w-3.5 h-3.5 text-ink-400" /></a>}
        </div>
      </div>
    </Link>
  );
}
