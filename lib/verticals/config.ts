export type VerticalSlug = "cafe" | "jewellery" | "hotel" | "marble" | "artefacts" | "clothing" | "general";

export interface VerticalDefinition {
  id: VerticalSlug;
  label: string;
  emoji: string;
  color: string;
  shortDescription: string;
  heroHeadline: string;
  heroSubline: string;
  painPoints: readonly string[];
  goals: readonly string[];
}

export const VERTICALS: Record<VerticalSlug, VerticalDefinition> = {
  cafe: { id: "cafe", label: "Café / Restaurant", emoji: "☕", color: "#10B981",
    shortDescription: "Local cafés, restaurants, and food spots.",
    heroHeadline: "Fill more tables. Build a local following.",
    heroSubline: "AI-crafted brand, menus, and social for local food businesses.",
    painPoints: ["Instagram goes quiet for weeks", "Menu photos look amateur", "Google reviews sit unanswered", "No seasonal promotions running"],
    goals: ["Get more foot traffic", "Build Instagram following", "Increase repeat customers", "Launch seasonal menus", "Better Google reviews"] },
  jewellery: { id: "jewellery", label: "Jewellery", emoji: "💎", color: "#FACC15",
    shortDescription: "Independent jewellery brands and designers.",
    heroHeadline: "Tell your story. Sell your craft.",
    heroSubline: "Brand, content, and SEO for independent jewellery makers.",
    painPoints: ["Product photos lack lifestyle", "No brand story told consistently", "Instagram bio is weak", "No email list capturing visitors"],
    goals: ["Build brand narrative", "Grow online store", "Increase Instagram engagement", "Launch email list", "Improve SEO"] },
  hotel: { id: "hotel", label: "Hotel / Stay", emoji: "🏨", color: "#0EA5E9",
    shortDescription: "Boutique hotels, homestays, and guest houses.",
    heroHeadline: "Book direct. Build loyalty.",
    heroSubline: "AI brand and marketing for boutique hotels and stays.",
    painPoints: ["Dependent on OTAs (high commission)", "Reviews not being answered", "Website load time is slow", "No seasonal campaigns"],
    goals: ["Increase direct bookings", "Improve TripAdvisor rank", "Build email list", "Launch seasonal offers", "Respond to all reviews"] },
  marble: { id: "marble", label: "Marble / Stone", emoji: "🪨", color: "#64748B",
    shortDescription: "Marble, stone, and building material businesses.",
    heroHeadline: "Win architect briefs. Close more quotes.",
    heroSubline: "B2B positioning for stone, marble, and material suppliers.",
    painPoints: ["No LinkedIn company presence", "Catalog is not architect-friendly", "No case studies published", "Weak SEO for trade terms"],
    goals: ["Generate architect leads", "Publish case studies", "Build LinkedIn presence", "Optimise catalog PDF", "Improve trade SEO"] },
  artefacts: { id: "artefacts", label: "Artefacts / Heritage", emoji: "🏺", color: "#A855F7",
    shortDescription: "Heritage artefacts, crafts, and collector pieces.",
    heroHeadline: "Tell the story buyers pay for.",
    heroSubline: "Brand and content for heritage artefact and craft sellers.",
    painPoints: ["Brand story is inconsistent", "No English export page", "Captions miss the heritage story", "No international enquiry form"],
    goals: ["Attract international buyers", "Tell heritage story clearly", "Improve product schema SEO", "Build newsletter", "Add export enquiry form"] },
  clothing: { id: "clothing", label: "Clothing / Apparel", emoji: "👗", color: "#F43F5E",
    shortDescription: "Independent clothing and apparel brands.",
    heroHeadline: "Drop better. Sell more.",
    heroSubline: "Brand, launch campaigns, and UGC strategy for apparel.",
    painPoints: ["No drop campaign strategy", "Brand voice inconsistent", "No UGC featured", "Email signup not prominent"],
    goals: ["Launch better drops", "Grow Instagram organically", "Build email list", "Feature UGC", "Improve lookbook reach"] },
  general: { id: "general", label: "Something else", emoji: "✨", color: "#F97316",
    shortDescription: "Any other small business building a brand.",
    heroHeadline: "Agency-quality brand. Pocket-sized price.",
    heroSubline: "AI brand building for any small business.",
    painPoints: ["Colors and fonts inconsistent", "Homepage unclear", "No blog or content plan", "Social posting is irregular"],
    goals: ["Clarify brand message", "Build content calendar", "Grow social presence", "Improve Google Business", "Launch blog"] },
};
