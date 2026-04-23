import { PostHog } from "posthog-node";

let _posthogServer: PostHog | null = null;

export function getPostHogServer(): PostHog | null {
  if (!process.env.NEXT_PUBLIC_POSTHOG_KEY) return null;
  if (!_posthogServer) {
    _posthogServer = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY, {
      host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://app.posthog.com",
      flushAt: 1,
      flushInterval: 0,
    });
  }
  return _posthogServer;
}

export function track(userId: string, event: string, properties?: Record<string, unknown>) {
  const ph = getPostHogServer();
  if (!ph) return;
  ph.capture({ distinctId: userId, event, properties });
}
