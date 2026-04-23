import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Logo } from "@/components/brand/Logo";
import { OnboardingWizard } from "@/components/app/OnboardingWizard";

export const metadata = { title: "Set up your account | Agency in Your Pocket" };

export default async function OnboardingPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login?returnTo=/onboarding");

  const { data: business } = await supabase.from("businesses").select("onboarding_completed").eq("user_id", user.id).eq("onboarding_completed", true).maybeSingle();
  if (business) redirect("/dashboard");

  return (
    <div className="min-h-screen bg-pocket-cream flex flex-col items-center px-4 py-10">
      <div className="mb-10"><Logo size="md" /></div>
      <OnboardingWizard userEmail={user.email ?? ""} />
    </div>
  );
}
