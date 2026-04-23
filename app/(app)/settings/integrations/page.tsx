import { PageTransition } from "@/components/common/PageTransition";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Camera, Globe } from "lucide-react";

export const metadata = { title: "Integrations | Agency in Your Pocket" };

const INTEGRATIONS = [
  { id: "instagram", name: "Instagram", description: "Connect your Instagram account to auto-post content and read insights.", icon: Camera, color: "text-pink-600", bg: "bg-pink-50", available: false },
  { id: "google-business", name: "Google Business Profile", description: "Sync your Google Business listing to manage posts, reviews, and Q&A.", icon: Globe, color: "text-blue-600", bg: "bg-blue-50", available: false },
];

export default function IntegrationsPage() {
  return (
    <PageTransition>
      <div className="max-w-lg">
        <h1 className="text-2xl font-bold text-ink-900 mb-1">Integrations</h1>
        <p className="text-sm text-ink-500 mb-6">Connect your social and business accounts.</p>
        <div className="flex flex-col gap-4">
          {INTEGRATIONS.map((integration) => {
            const Icon = integration.icon;
            return (
              <div key={integration.id} className="bg-white rounded-xl border border-ink-200 p-5">
                <div className="flex items-start gap-4">
                  <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${integration.bg}`}>
                    <Icon className={`w-5 h-5 ${integration.color}`} />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="text-sm font-semibold text-ink-900">{integration.name}</h3>
                      {!integration.available && <Badge variant="secondary" className="text-[10px]">Coming soon</Badge>}
                    </div>
                    <p className="text-xs text-ink-500 mt-0.5">{integration.description}</p>
                  </div>
                  <Button size="sm" variant="outline" disabled={!integration.available}>Connect</Button>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </PageTransition>
  );
}
