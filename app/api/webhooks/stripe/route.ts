import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe/client";
import { createServiceRoleClient } from "@/lib/supabase/server";
import type Stripe from "stripe";

const TIER_MAP: Record<string, "starter" | "growth" | "agency"> = {
  [process.env.STRIPE_PRICE_STARTER ?? ""]: "starter",
  [process.env.STRIPE_PRICE_GROWTH ?? ""]: "growth",
  [process.env.STRIPE_PRICE_AGENCY ?? ""]: "agency",
};

export async function POST(request: Request) {
  const body = await request.text();
  const sig = request.headers.get("stripe-signature");
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!sig || !webhookSecret) return NextResponse.json({ error: "Missing signature" }, { status: 400 });

  let event: Stripe.Event;
  try { event = stripe.webhooks.constructEvent(body, sig, webhookSecret); }
  catch { return NextResponse.json({ error: "Invalid signature" }, { status: 400 }); }

  const supabase = createServiceRoleClient();

  if (event.type === "checkout.session.completed") {
    const session = event.data.object as Stripe.Checkout.Session;
    const userId = session.metadata?.supabase_user_id;
    if (userId && session.subscription) {
      const sub = await stripe.subscriptions.retrieve(session.subscription as string);
      const priceId = sub.items.data[0]?.price.id ?? "";
      const tier = TIER_MAP[priceId] ?? "starter";
      await supabase.from("profiles").update({ plan_tier: tier }).eq("id", userId);
    }
  }
  if (event.type === "customer.subscription.updated") {
    const sub = event.data.object as Stripe.Subscription;
    const customer = await stripe.customers.retrieve(sub.customer as string);
    if (!("deleted" in customer)) {
      const userId = customer.metadata?.supabase_user_id;
      const priceId = sub.items.data[0]?.price.id ?? "";
      const tier = TIER_MAP[priceId] ?? "free";
      if (userId) await supabase.from("profiles").update({ plan_tier: tier }).eq("id", userId);
    }
  }
  if (event.type === "customer.subscription.deleted") {
    const sub = event.data.object as Stripe.Subscription;
    const customer = await stripe.customers.retrieve(sub.customer as string);
    if (!("deleted" in customer)) {
      const userId = customer.metadata?.supabase_user_id;
      if (userId) await supabase.from("profiles").update({ plan_tier: "free" }).eq("id", userId);
    }
  }
  return NextResponse.json({ received: true });
}
