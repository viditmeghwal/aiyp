export interface PlanDefinition {
  name: string;
  price: number;
  priceId: string;
  features: string[];
  limits: { workflowsPerMonth: number; deliverables: number; businesses: number };
}

export const PLANS: Record<string, PlanDefinition> = {
  free: {
    name: "Free", price: 0, priceId: "",
    features: ["1 brand audit per month", "Brand Starter Kit", "30-day content calendar", "Basic analytics"],
    limits: { workflowsPerMonth: 3, deliverables: 5, businesses: 1 },
  },
  starter: {
    name: "Starter", price: 29, priceId: process.env.STRIPE_PRICE_STARTER ?? "",
    features: ["10 AI workflow runs/month", "All deliverable types", "Instagram + Google integrations", "Email support", "PDF exports"],
    limits: { workflowsPerMonth: 10, deliverables: 50, businesses: 1 },
  },
  growth: {
    name: "Growth", price: 59, priceId: process.env.STRIPE_PRICE_GROWTH ?? "",
    features: ["Unlimited AI workflow runs", "Priority processing", "Advanced analytics", "White-label deliverables", "Priority support", "3 businesses"],
    limits: { workflowsPerMonth: -1, deliverables: -1, businesses: 3 },
  },
  agency: {
    name: "Agency", price: 129, priceId: process.env.STRIPE_PRICE_AGENCY ?? "",
    features: ["Everything in Growth", "10 businesses", "Team access (3 seats)", "Custom workflow builder", "Dedicated account manager", "API access"],
    limits: { workflowsPerMonth: -1, deliverables: -1, businesses: 10 },
  },
};
