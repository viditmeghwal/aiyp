"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { VERTICALS } from "@/lib/verticals/config";

export function FreeAuditForm() {
  const router = useRouter();
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault(); setError(null);
    const data = new FormData(e.currentTarget);
    const email = data.get("email") as string;
    const businessName = data.get("businessName") as string;
    const websiteUrl = data.get("websiteUrl") as string;
    const vertical = data.get("vertical") as string;
    if (!email || !businessName || !vertical) { setError("Please fill in all required fields."); return; }
    setLoading(true);
    try {
      const res = await fetch("/api/free-audit/start", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ email, businessName, websiteUrl, vertical }) });
      if (!res.ok) throw new Error("Failed to start audit");
      const { auditId } = (await res.json()) as { auditId: string };
      router.push(`/free-audit/analyzing?id=${auditId}`);
    } catch { setError("Something went wrong. Please try again."); setLoading(false); }
  }

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-2xl shadow-sm border border-ink-200 p-8 flex flex-col gap-5">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="email">Your email <span className="text-pocket-orange">*</span></Label>
        <Input id="email" name="email" type="email" placeholder="you@yourbusiness.com" required />
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="businessName">Business name <span className="text-pocket-orange">*</span></Label>
        <Input id="businessName" name="businessName" type="text" placeholder="Sunrise Cafe" required />
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="websiteUrl">Website URL or Instagram handle</Label>
        <Input id="websiteUrl" name="websiteUrl" type="text" placeholder="https://yourbusiness.com or @yourhandle" />
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="vertical">What do you do? <span className="text-pocket-orange">*</span></Label>
        <Select name="vertical" required>
          <SelectTrigger id="vertical"><SelectValue placeholder="Select your business type" /></SelectTrigger>
          <SelectContent>{Object.values(VERTICALS).map((v) => <SelectItem key={v.id} value={v.id}>{v.emoji} {v.label}</SelectItem>)}</SelectContent>
        </Select>
      </div>
      {error && <p className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3">{error}</p>}
      <Button type="submit" disabled={loading} className="bg-pocket-orange hover:bg-pocket-orange-dark text-white h-12 text-base gap-2 mt-2">
        {loading ? <><Loader2 className="h-4 w-4 animate-spin" />Starting…</> : <>Analyze my brand<ArrowRight className="h-4 w-4" /></>}
      </Button>
    </form>
  );
}
