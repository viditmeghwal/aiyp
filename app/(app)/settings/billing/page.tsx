import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { PageTransition } from "@/components/common/PageTransition";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Zap, Check } from "lucide-react";
import { PLANS } from "@/lib/stripe/plans";
import { BillingSuccessNotifier } from "@/components/app/BillingSuccessNotifier";

export const metadata = { title: "Billing | Agency in Your Pocket" };

export default async function BillingPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase.from("profiles").select("plan_tier, stripe_customer_id").eq("id", user.id).single();
  const currentTier = profile?.plan_tier ?? "free";

  return (
    <PageTransition>
      <BillingSuccessNotifier />
      <div className="max-w-lg">
        <h1 className="text-2xl font-bold text-ink-900 mb-1">Billing</h1>
        <p className="text-sm text-ink-500 mb-6">Manage your plan and subscription.</p>
        <div className="bg-white rounded-xl border border-ink-200 p-6 mb-6">
          <div className="flex items-center justify-between mb-1">
            <h2 className="text-sm font-semibold text-ink-700">Current plan</h2>
            <Badge className="capitalize bg-pocket-orange text-white">{currentTier}</Badge>
          </div>
          <p className="text-2xl font-bold text-ink-900">
            {currentTier === "free" ? "Free" : `$${PLANS[currentTier as keyof typeof PLANS]?.price ?? 0}/mo`}
          </p>
          {profile?.stripe_customer_id && (
            <form action="/api/portal" method="POST" className="mt-4">
              <Button type="submit" variant="outline">Manage subscription</Button>
            </form>
          )}
        </div>
        {currentTier === "free" && (
          <div className="flex flex-col gap-3">
            {Object.entries(PLANS).filter(([key]) => key !== "free").map(([key, plan]) => (
              <div key={key} className="bg-white rounded-xl border border-ink-200 p-5">
                <div className="flex items-start justify-between">
                  <div>
                    <h3 className="font-semibold text-ink-900 capitalize">{plan.name}</h3>
                    <p className="text-2xl font-bold text-ink-900 mt-0.5">${plan.price}<span className="text-sm font-normal text-ink-500">/mo</span></p>
                  </div>
                  <form action="/api/checkout" method="POST">
                    <input type="hidden" name="priceId" value={plan.priceId} />
                    <Button type="submit" size="sm" className="bg-pocket-orange hover:bg-pocket-orange-dark text-white gap-1">
                      <Zap className="w-3.5 h-3.5" />Upgrade
                    </Button>
                  </form>
                </div>
                <ul className="mt-3 flex flex-col gap-1">
                  {plan.features.slice(0, 3).map((f) => (
                    <li key={f} className="flex items-start gap-2 text-sm text-ink-600">
                      <Check className="w-3.5 h-3.5 text-emerald-500 shrink-0 mt-0.5" />{f}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        )}
      </div>
    </PageTransition>
  );
}
