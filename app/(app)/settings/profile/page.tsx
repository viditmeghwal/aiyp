"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";
import { PageTransition } from "@/components/common/PageTransition";
import { useToast } from "@/hooks/use-toast";

export default function ProfileSettingsPage() {
  const router = useRouter();
  const { toast } = useToast();
  const [loading, setLoading] = React.useState(true);
  const [saving, setSaving] = React.useState(false);
  const [fullName, setFullName] = React.useState("");
  const [email, setEmail] = React.useState("");
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    const supabase = createClient();
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) { router.push("/login"); return; }
      setEmail(user.email ?? "");
      supabase.from("profiles").select("full_name").eq("id", user.id).single().then(({ data }) => {
        setFullName(data?.full_name ?? "");
        setLoading(false);
      });
    });
  }, [router]);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true); setError(null);
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;
    const { error } = await supabase.from("profiles").update({ full_name: fullName, updated_at: new Date().toISOString() }).eq("id", user.id);
    if (error) { setError(error.message); } else { toast({ title: "Profile saved", description: "Your changes have been saved successfully." }); }
    setSaving(false);
  }

  if (loading) return null;

  return (
    <PageTransition>
      <div className="max-w-lg">
        <h1 className="text-2xl font-bold text-ink-900 mb-1">Profile</h1>
        <p className="text-sm text-ink-500 mb-6">Update your account details.</p>
        <div className="bg-white rounded-xl border border-ink-200 p-6">
          <form onSubmit={handleSave} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="name">Full name</Label>
              <Input id="name" value={fullName} onChange={(e) => setFullName(e.target.value)} />
            </div>
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="email">Email</Label>
              <Input id="email" value={email} disabled className="bg-ink-50 text-ink-500" />
              <p className="text-xs text-ink-400">Email cannot be changed here.</p>
            </div>
            {error && <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>}
            <Button type="submit" disabled={saving} className="self-start bg-pocket-orange hover:bg-pocket-orange-dark text-white gap-2">
              {saving && <Loader2 className="w-4 h-4 animate-spin" />}Save changes
            </Button>
          </form>
        </div>
      </div>
    </PageTransition>
  );
}
