import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { AppNav } from "@/components/app/AppNav";
import { Sidebar } from "@/components/app/Sidebar";
import { Toaster } from "@/components/ui/toaster";
import type { VerticalSlug } from "@/lib/verticals/config";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const [{ data: profile }, { data: business }] = await Promise.all([
    supabase.from("profiles").select("full_name, plan_tier, is_admin").eq("id", user.id).single(),
    supabase.from("businesses").select("name, vertical, onboarding_completed").eq("user_id", user.id).eq("onboarding_completed", true).maybeSingle(),
  ]);

  if (!business) redirect("/onboarding");

  return (
    <div className="flex flex-col min-h-screen bg-ink-100">
      <AppNav fullName={profile?.full_name ?? null} email={user.email ?? ""} isAdmin={profile?.is_admin ?? false} />
      <div className="flex flex-1 min-h-0">
        <Sidebar businessName={business.name} vertical={business.vertical as VerticalSlug} planTier={profile?.plan_tier ?? "free"} />
        <main className="flex-1 overflow-auto">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 py-6">{children}</div>
        </main>
      </div>
      <Toaster />
    </div>
  );
}
