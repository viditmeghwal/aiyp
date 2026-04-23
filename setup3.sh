# ── directory structure ───────────────────────────────────────────────────────
mkdir -p "app/(auth)/login" "app/(auth)/signup" "app/(auth)/forgot-password" "app/(auth)/callback"
mkdir -p "app/(marketing)/about" "app/(marketing)/pricing" "app/(marketing)/blog/[slug]"
mkdir -p "app/(marketing)/verticals/[vertical]"
mkdir -p "app/(marketing)/free-audit/analyzing" "app/(marketing)/free-audit/result/[id]"
mkdir -p "app/api/free-audit/start" "app/api/free-audit/[id]"
mkdir -p "app/api/checkout" "app/api/portal" "app/api/inngest" "app/api/webhooks/stripe"
mkdir -p content/blog

# ── app/layout.tsx ────────────────────────────────────────────────────────────
cat > app/layout.tsx << 'HEREDOC'
import type { Metadata } from "next";
import localFont from "next/font/local";
import { Fraunces } from "next/font/google";
import { PostHogProvider } from "@/components/providers/PostHogProvider";
import "./globals.css";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});
const fraunces = Fraunces({
  subsets: ["latin"],
  style: "italic",
  weight: ["400", "600", "700"],
  variable: "--font-fraunces",
  display: "swap",
});

export const metadata: Metadata = {
  title: { default: "Agency in Your Pocket", template: "%s | Agency in Your Pocket" },
  description: "Everything a real agency does — right in your pocket. Audits, branding, content, social media, SEO. All done for you by AI.",
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000"),
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${geistSans.variable} ${geistMono.variable} ${fraunces.variable}`}>
      <body className="antialiased">
        <PostHogProvider>{children}</PostHogProvider>
      </body>
    </html>
  );
}
HEREDOC

# ── app/not-found.tsx ─────────────────────────────────────────────────────────
cat > app/not-found.tsx << 'HEREDOC'
import Link from "next/link";
import { Logo } from "@/components/brand/Logo";
import { Button } from "@/components/ui/button";

export default function NotFound() {
  return (
    <div className="min-h-screen bg-pocket-cream flex flex-col items-center justify-center px-4 text-center">
      <div className="mb-8"><Logo size="md" /></div>
      <p className="text-7xl font-bold text-pocket-orange mb-4">404</p>
      <h1 className="text-2xl font-bold text-ink-900 mb-2">Page not found</h1>
      <p className="text-ink-500 text-sm mb-8 max-w-xs">
        The page you&apos;re looking for doesn&apos;t exist or has been moved.
      </p>
      <div className="flex gap-3">
        <Button asChild className="bg-pocket-orange hover:bg-pocket-orange-dark text-white">
          <Link href="/">Go home</Link>
        </Button>
        <Button asChild variant="outline">
          <Link href="/dashboard">Dashboard</Link>
        </Button>
      </div>
    </div>
  );
}
HEREDOC

# ── app/page.tsx (dev placeholder) ────────────────────────────────────────────
cat > app/page.tsx << 'HEREDOC'
import { Button } from "@/components/ui/button";
import { Logo } from "@/components/brand/Logo";

export default function Home() {
  return (
    <main className="min-h-screen bg-pocket-cream flex flex-col items-center justify-center gap-8 p-8">
      <Logo size="lg" />
      <h1 className="text-4xl md:text-5xl font-bold text-center max-w-2xl">
        <span className="text-ink-900">Agency in </span>
        <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>
          Your Pocket
        </span>
      </h1>
      <p className="text-lg text-ink-700 text-center max-w-xl">
        Everything a real agency does — right in your pocket.
      </p>
      <Button className="bg-pocket-orange hover:bg-pocket-orange-dark text-white px-8 py-3 text-base h-auto">
        Get my free audit
      </Button>
    </main>
  );
}
HEREDOC

# ── app/(auth)/layout.tsx ─────────────────────────────────────────────────────
cat > "app/(auth)/layout.tsx" << 'HEREDOC'
import Link from "next/link";
import { Logo } from "@/components/brand/Logo";

export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-pocket-cream flex flex-col">
      <header className="py-6 px-6 flex justify-center">
        <Link href="/"><Logo size="md" /></Link>
      </header>
      <main className="flex-1 flex items-center justify-center px-4 pb-16">{children}</main>
    </div>
  );
}
HEREDOC

# ── app/(auth)/login/page.tsx ─────────────────────────────────────────────────
cat > "app/(auth)/login/page.tsx" << 'HEREDOC'
"use client";
import * as React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";

export default function LoginPage() {
  const router = useRouter();
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    const form = e.currentTarget;
    const email = (form.elements.namedItem("email") as HTMLInputElement).value;
    const password = (form.elements.namedItem("password") as HTMLInputElement).value;
    setLoading(true);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) { setError(error.message); setLoading(false); }
    else { router.push("/dashboard"); router.refresh(); }
  }

  async function handleGoogleLogin() {
    const supabase = createClient();
    await supabase.auth.signInWithOAuth({ provider: "google", options: { redirectTo: `${window.location.origin}/auth/callback` } });
  }

  return (
    <div className="w-full max-w-sm">
      <h1 className="text-2xl font-bold text-ink-900 text-center mb-2">Welcome back</h1>
      <p className="text-sm text-ink-500 text-center mb-8">
        Don&apos;t have an account?{" "}
        <Link href="/signup" className="text-pocket-orange hover:underline">Sign up free</Link>
      </p>
      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="email">Email</Label>
          <Input id="email" name="email" type="email" required autoComplete="email" />
        </div>
        <div className="flex flex-col gap-1.5">
          <div className="flex justify-between items-center">
            <Label htmlFor="password">Password</Label>
            <Link href="/forgot-password" className="text-xs text-ink-500 hover:text-pocket-orange">Forgot password?</Link>
          </div>
          <Input id="password" name="password" type="password" required autoComplete="current-password" />
        </div>
        {error && <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>}
        <Button type="submit" disabled={loading} className="bg-pocket-orange hover:bg-pocket-orange-dark text-white h-10 gap-2 mt-2">
          {loading && <Loader2 className="h-4 w-4 animate-spin" />}Sign in
        </Button>
      </form>
      <div className="relative my-6">
        <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-ink-300" /></div>
        <div className="relative flex justify-center text-xs"><span className="bg-pocket-cream px-2 text-ink-500">or</span></div>
      </div>
      <Button variant="outline" className="w-full" onClick={handleGoogleLogin}>
        <svg className="h-4 w-4 mr-2" viewBox="0 0 24 24" fill="none">
          <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
          <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
          <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
          <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
        </svg>
        Sign in with Google
      </Button>
    </div>
  );
}
HEREDOC

# ── app/(auth)/signup/page.tsx ────────────────────────────────────────────────
cat > "app/(auth)/signup/page.tsx" << 'HEREDOC'
"use client";
import * as React from "react";
import Link from "next/link";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";

export default function SignupPage() {
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);
  const [success, setSuccess] = React.useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    const form = e.currentTarget;
    const fullName = (form.elements.namedItem("fullName") as HTMLInputElement).value;
    const email = (form.elements.namedItem("email") as HTMLInputElement).value;
    const password = (form.elements.namedItem("password") as HTMLInputElement).value;
    if (password.length < 8) { setError("Password must be at least 8 characters."); return; }
    setLoading(true);
    const supabase = createClient();
    const { error } = await supabase.auth.signUp({
      email, password,
      options: { data: { full_name: fullName }, emailRedirectTo: `${window.location.origin}/auth/callback` },
    });
    if (error) { setError(error.message); setLoading(false); } else { setSuccess(true); }
  }

  async function handleGoogleSignup() {
    const supabase = createClient();
    await supabase.auth.signInWithOAuth({ provider: "google", options: { redirectTo: `${window.location.origin}/auth/callback` } });
  }

  if (success) {
    return (
      <div className="w-full max-w-sm text-center">
        <span className="text-5xl mb-4 block">📬</span>
        <h2 className="text-xl font-bold text-ink-900 mb-2">Check your email</h2>
        <p className="text-ink-500 text-sm">We sent a confirmation link. Click it to activate your account.</p>
      </div>
    );
  }

  return (
    <div className="w-full max-w-sm">
      <h1 className="text-2xl font-bold text-ink-900 text-center mb-2">Start for free</h1>
      <p className="text-sm text-ink-500 text-center mb-8">
        Already have an account?{" "}
        <Link href="/login" className="text-pocket-orange hover:underline">Log in</Link>
      </p>
      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="fullName">Full name</Label>
          <Input id="fullName" name="fullName" type="text" required autoComplete="name" placeholder="Jane Doe" />
        </div>
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="email">Email</Label>
          <Input id="email" name="email" type="email" required autoComplete="email" />
        </div>
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="password">Password</Label>
          <Input id="password" name="password" type="password" required autoComplete="new-password" placeholder="8+ characters" />
        </div>
        {error && <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>}
        <Button type="submit" disabled={loading} className="bg-pocket-orange hover:bg-pocket-orange-dark text-white h-10 gap-2 mt-2">
          {loading && <Loader2 className="h-4 w-4 animate-spin" />}Create account
        </Button>
      </form>
      <div className="relative my-6">
        <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-ink-300" /></div>
        <div className="relative flex justify-center text-xs"><span className="bg-pocket-cream px-2 text-ink-500">or</span></div>
      </div>
      <Button variant="outline" className="w-full" onClick={handleGoogleSignup}>
        <svg className="h-4 w-4 mr-2" viewBox="0 0 24 24" fill="none">
          <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
          <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
          <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
          <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
        </svg>
        Sign up with Google
      </Button>
      <p className="mt-6 text-center text-xs text-ink-500">
        By signing up you agree to our <Link href="/terms" className="underline">Terms</Link> and{" "}
        <Link href="/privacy" className="underline">Privacy Policy</Link>.
      </p>
    </div>
  );
}
HEREDOC

# ── app/(auth)/forgot-password/page.tsx ───────────────────────────────────────
cat > "app/(auth)/forgot-password/page.tsx" << 'HEREDOC'
"use client";
import * as React from "react";
import Link from "next/link";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";

export default function ForgotPasswordPage() {
  const [loading, setLoading] = React.useState(false);
  const [sent, setSent] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    const email = (e.currentTarget.elements.namedItem("email") as HTMLInputElement).value;
    setLoading(true);
    const supabase = createClient();
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth/callback?type=recovery`,
    });
    if (error) { setError(error.message); } else { setSent(true); }
    setLoading(false);
  }

  if (sent) {
    return (
      <div className="w-full max-w-sm text-center">
        <span className="text-5xl mb-4 block">📧</span>
        <h2 className="text-xl font-bold text-ink-900 mb-2">Check your email</h2>
        <p className="text-sm text-ink-500">We sent a password reset link. It expires in 1 hour.</p>
        <Link href="/login" className="inline-block mt-4 text-pocket-orange text-sm hover:underline">Back to login</Link>
      </div>
    );
  }

  return (
    <div className="w-full max-w-sm">
      <h1 className="text-2xl font-bold text-ink-900 text-center mb-2">Reset your password</h1>
      <p className="text-sm text-ink-500 text-center mb-8">Enter your email and we&apos;ll send a reset link.</p>
      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="email">Email</Label>
          <Input id="email" name="email" type="email" required />
        </div>
        {error && <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>}
        <Button type="submit" disabled={loading} className="bg-pocket-orange hover:bg-pocket-orange-dark text-white h-10 gap-2">
          {loading && <Loader2 className="h-4 w-4 animate-spin" />}Send reset link
        </Button>
      </form>
      <p className="mt-4 text-center text-sm">
        <Link href="/login" className="text-pocket-orange hover:underline">Back to login</Link>
      </p>
    </div>
  );
}
HEREDOC

# ── app/(auth)/callback/route.ts ──────────────────────────────────────────────
cat > "app/(auth)/callback/route.ts" << 'HEREDOC'
import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/onboarding";
  if (code) {
    const supabase = createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(`${origin}${next}`);
  }
  return NextResponse.redirect(`${origin}/login?error=auth_failed`);
}
HEREDOC

# ── app/(marketing)/layout.tsx ────────────────────────────────────────────────
cat > "app/(marketing)/layout.tsx" << 'HEREDOC'
import { Nav } from "@/components/marketing/Nav";
import { Footer } from "@/components/marketing/Footer";
import { PageTransition } from "@/components/common/PageTransition";
import { Toaster } from "@/components/ui/toaster";

export default function MarketingLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Nav />
      <PageTransition>
        <div className="min-h-screen">{children}</div>
      </PageTransition>
      <Footer />
      <Toaster />
    </>
  );
}
HEREDOC

# ── app/(marketing)/page.tsx ──────────────────────────────────────────────────
cat > "app/(marketing)/page.tsx" << 'HEREDOC'
import { Hero } from "@/components/marketing/Hero";
import { HowItWorks } from "@/components/marketing/HowItWorks";
import { VerticalGrid } from "@/components/marketing/VerticalGrid";
import { PoweredByBar } from "@/components/brand/PoweredByBar";
import { PricingTiers } from "@/components/marketing/PricingTiers";
import { FAQ } from "@/components/marketing/FAQ";
import { FinalCTA } from "@/components/marketing/FinalCTA";

function ProblemSection() {
  return (
    <section className="py-20 bg-pocket-peach">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 className="text-3xl md:text-4xl font-bold text-ink-900 mb-8">
          Real agencies cost too much. Tools are too many.
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 text-left max-w-4xl mx-auto">
          <p className="text-ink-700 text-base leading-relaxed">
            You know you need branding, content, and SEO. But real agencies start at $2,000/month.
            Learning Canva + Buffer + Ahrefs + ChatGPT takes months you don&apos;t have.
          </p>
          <p className="text-ink-700 text-base leading-relaxed">
            Generic AI tools give you output that sounds like everyone else. So you keep putting it off.{" "}
            <strong className="text-ink-900">We fixed that.</strong>
          </p>
        </div>
      </div>
    </section>
  );
}

function PricingPreview() {
  return (
    <section className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-ink-900">Pocket-size pricing. Real agency work.</h2>
          <p className="mt-4 text-lg text-ink-700">Start free. Upgrade when you&apos;re ready. Cancel anytime.</p>
        </div>
        <PricingTiers />
      </div>
    </section>
  );
}

export default function HomePage() {
  return (
    <>
      <Hero />
      <PoweredByBar />
      <HowItWorks />
      <ProblemSection />
      <VerticalGrid />
      <PricingPreview />
      <FAQ />
      <FinalCTA />
    </>
  );
}
HEREDOC

# ── app/(marketing)/pricing/page.tsx ─────────────────────────────────────────
cat > "app/(marketing)/pricing/page.tsx" << 'HEREDOC'
import type { Metadata } from "next";
import { PricingTiers } from "@/components/marketing/PricingTiers";
import { FAQ } from "@/components/marketing/FAQ";
import { FinalCTA } from "@/components/marketing/FinalCTA";

export const metadata: Metadata = {
  title: "Pricing",
  description: "Pocket-size pricing for real agency work. Start free, upgrade when ready.",
};

export default function PricingPage() {
  return (
    <>
      <section className="py-24 bg-pocket-cream text-center">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-5xl font-bold text-ink-900">
            Pocket-size pricing.{" "}
            <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>
              Real agency work.
            </span>
          </h1>
          <p className="mt-6 text-lg text-ink-700">Start free. Upgrade when you&apos;re ready. Cancel anytime.</p>
        </div>
      </section>
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <PricingTiers />
          <div className="mt-8 max-w-2xl mx-auto text-center p-8 rounded-2xl bg-ink-900 text-white">
            <p className="text-lg font-semibold">Custom / DFY — from $500/mo</p>
            <p className="mt-2 text-ink-300 text-sm">Platform plus our team executing everything.</p>
            <a href="mailto:hello@agencyinyourpocket.com" className="inline-block mt-4 text-pocket-orange font-semibold hover:underline">
              Book a call →
            </a>
          </div>
        </div>
      </section>
      <FAQ />
      <FinalCTA />
    </>
  );
}
HEREDOC

# ── app/(marketing)/about/page.tsx ────────────────────────────────────────────
cat > "app/(marketing)/about/page.tsx" << 'HEREDOC'
import type { Metadata } from "next";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { PoweredByBar } from "@/components/brand/PoweredByBar";

export const metadata: Metadata = {
  title: "About",
  description: "We built Agency in Your Pocket because we got tired of watching good businesses fail at branding.",
};

export default function AboutPage() {
  return (
    <>
      <section className="py-24 bg-pocket-cream">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-5xl font-bold text-ink-900 mb-8">
            We built this because we got tired of watching good businesses fail at{" "}
            <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>
              branding.
            </span>
          </h1>
          <div className="prose prose-lg max-w-none text-ink-700 space-y-6">
            <p>Ten years running an agency. Cafes, jewellery brands, hotels, factories. Same story every time: great product, terrible brand presence.</p>
            <p>Real agencies cost $2,000+/month. Tools overwhelm. Generic AI produces generic output. So we built what we wished existed.</p>
            <p className="font-semibold text-ink-900">Every founder deserves agency-quality work. That&apos;s why we exist.</p>
          </div>
          <div className="mt-12 flex gap-4">
            <Button className="bg-pocket-orange hover:bg-pocket-orange-dark text-white" asChild>
              <Link href="/free-audit">Get my free audit →</Link>
            </Button>
            <Button variant="outline" asChild><Link href="/pricing">See pricing</Link></Button>
          </div>
        </div>
      </section>
      <PoweredByBar />
    </>
  );
}
HEREDOC

# ── app/(marketing)/verticals/[vertical]/page.tsx ────────────────────────────
cat > "app/(marketing)/verticals/[vertical]/page.tsx" << 'HEREDOC'
import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { CheckCircle, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { VERTICALS, type VerticalSlug } from "@/lib/verticals/config";

export function generateStaticParams() {
  return Object.keys(VERTICALS).map((vertical) => ({ vertical }));
}

export function generateMetadata({ params }: { params: { vertical: string } }): Metadata {
  const v = VERTICALS[params.vertical as VerticalSlug];
  if (!v) return {};
  return { title: `${v.label} — Agency in Your Pocket`, description: v.shortDescription };
}

export default function VerticalPage({ params }: { params: { vertical: string } }) {
  const v = VERTICALS[params.vertical as VerticalSlug];
  if (!v) notFound();
  return (
    <>
      <section className="py-24" style={{ backgroundColor: `${v.color}18` }}>
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <span className="text-6xl mb-6 block">{v.emoji}</span>
          <h1 className="text-4xl md:text-5xl font-bold text-ink-900">{v.heroHeadline}</h1>
          <p className="mt-6 text-lg md:text-xl text-ink-700">{v.heroSubline}</p>
          <div className="mt-10">
            <Button size="lg" className="text-white px-8 h-12 text-base gap-2" style={{ backgroundColor: v.color }} asChild>
              <Link href="/free-audit">Get my free audit <ArrowRight className="h-4 w-4" /></Link>
            </Button>
          </div>
        </div>
      </section>
      <section className="py-20 bg-white">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-ink-900 text-center mb-12">Sound familiar?</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {v.painPoints.map((pain) => (
              <div key={pain} className="flex items-start gap-3 p-5 rounded-xl bg-pocket-cream border border-ink-200">
                <span className="text-xl mt-0.5">😤</span>
                <p className="text-ink-700">{pain}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
      <section className="py-20" style={{ backgroundColor: `${v.color}10` }}>
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-ink-900 text-center mb-12">What you&apos;ll build</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {v.goals.map((goal) => (
              <div key={goal} className="flex items-start gap-3 p-4 bg-white rounded-xl shadow-sm">
                <CheckCircle className="h-5 w-5 mt-0.5 flex-shrink-0" style={{ color: v.color }} />
                <p className="text-sm text-ink-700">{goal}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
      <section className="py-20 text-white" style={{ backgroundColor: v.color }}>
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl md:text-4xl font-bold">Ready to build your {v.label} brand?</h2>
          <div className="mt-8">
            <Button size="lg" className="bg-white text-ink-900 hover:bg-white/90 px-8 h-12 text-base" asChild>
              <Link href="/free-audit">Get free audit →</Link>
            </Button>
          </div>
        </div>
      </section>
    </>
  );
}
HEREDOC

# ── app/(marketing)/blog/page.tsx ─────────────────────────────────────────────
cat > "app/(marketing)/blog/page.tsx" << 'HEREDOC'
import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = { title: "Blog", description: "Insights on brand building, AI, and growth for solo founders." };

const posts = [{ slug: "why-we-built-aiyp", title: "Why we built Agency in Your Pocket", date: "April 2025", excerpt: "10 years of running an agency taught us the same lesson every time: great products deserve great branding, and most founders can't afford it.", readTime: "5 min read" }];

export default function BlogPage() {
  return (
    <section className="py-24 bg-pocket-cream min-h-screen">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h1 className="text-4xl font-bold text-ink-900 mb-12">Blog</h1>
        <div className="flex flex-col gap-6">
          {posts.map((post) => (
            <Link key={post.slug} href={`/blog/${post.slug}`} className="group block bg-white rounded-2xl p-8 border border-ink-200 hover:border-pocket-orange/40 hover:shadow-md transition-all">
              <div className="flex items-center gap-3 mb-3">
                <span className="text-xs text-ink-500">{post.date}</span>
                <span className="text-xs text-ink-300">·</span>
                <span className="text-xs text-ink-500">{post.readTime}</span>
              </div>
              <h2 className="text-xl font-semibold text-ink-900 group-hover:text-pocket-orange transition-colors mb-2">{post.title}</h2>
              <p className="text-ink-700 text-sm leading-relaxed">{post.excerpt}</p>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── app/(marketing)/blog/[slug]/page.tsx ─────────────────────────────────────
cat > "app/(marketing)/blog/[slug]/page.tsx" << 'HEREDOC'
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { MDXRemote } from "next-mdx-remote/rsc";
import fs from "fs";
import path from "path";
import matter from "gray-matter";

function getPost(slug: string) {
  const filePath = path.join(process.cwd(), "content/blog", `${slug}.mdx`);
  if (!fs.existsSync(filePath)) return null;
  const { data, content } = matter(fs.readFileSync(filePath, "utf-8"));
  return { frontmatter: data, content };
}

export function generateStaticParams() {
  const dir = path.join(process.cwd(), "content/blog");
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir).filter((f) => f.endsWith(".mdx")).map((f) => ({ slug: f.replace(".mdx", "") }));
}

export function generateMetadata({ params }: { params: { slug: string } }): Metadata {
  const post = getPost(params.slug);
  if (!post) return {};
  return { title: post.frontmatter.title, description: post.frontmatter.excerpt };
}

export default function BlogPostPage({ params }: { params: { slug: string } }) {
  const post = getPost(params.slug);
  if (!post) notFound();
  return (
    <article className="py-24 bg-pocket-cream min-h-screen">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="prose prose-neutral prose-lg max-w-none [&_h1]:text-4xl [&_h1]:font-bold [&_h1]:text-ink-900 [&_p]:text-ink-700">
          <MDXRemote source={post.content} />
        </div>
      </div>
    </article>
  );
}
HEREDOC

# ── app/(marketing)/free-audit/page.tsx ──────────────────────────────────────
cat > "app/(marketing)/free-audit/page.tsx" << 'HEREDOC'
import type { Metadata } from "next";
import { FreeAuditForm } from "@/components/audit/FreeAuditForm";

export const metadata: Metadata = {
  title: "Free Brand Audit",
  description: "See what an agency would charge $2,000 to tell you. Give us 3 things. We'll show you what's working, what's broken, and exactly what to fix.",
};

export default function FreeAuditPage() {
  return (
    <section className="py-24 bg-pocket-cream min-h-screen">
      <div className="max-w-xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-10">
          <span className="text-4xl mb-4 block">🔍</span>
          <h1 className="text-4xl font-bold text-ink-900">
            See what an agency would charge{" "}
            <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>$2,000</span>{" "}
            to tell you.
          </h1>
          <p className="mt-4 text-lg text-ink-700">Give us three things. We&apos;ll show you what&apos;s working, what&apos;s broken, and exactly what to fix.</p>
        </div>
        <FreeAuditForm />
        <p className="mt-6 text-center text-sm text-ink-500">We&apos;ll email you the full audit. Takes 90 seconds. No spam.</p>
      </div>
    </section>
  );
}
HEREDOC

# ── app/(marketing)/free-audit/analyzing/page.tsx ────────────────────────────
cat > "app/(marketing)/free-audit/analyzing/page.tsx" << 'HEREDOC'
import { Suspense } from "react";
import { AnalyzingScreen } from "@/components/audit/AnalyzingScreen";

export default function AnalyzingPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-pocket-cream flex items-center justify-center"><div className="w-8 h-8 rounded-full border-2 border-pocket-orange border-t-transparent animate-spin" /></div>}>
      <AnalyzingScreen />
    </Suspense>
  );
}
HEREDOC

# ── app/(marketing)/free-audit/result/[id]/page.tsx ──────────────────────────
cat > "app/(marketing)/free-audit/result/[id]/page.tsx" << 'HEREDOC'
import { notFound } from "next/navigation";
import { TeaserResult } from "@/components/audit/TeaserResult";
import { auditStore } from "@/app/api/free-audit/start/route";

export default function AuditResultPage({ params }: { params: { id: string } }) {
  const audit = auditStore.get(params.id);
  if (!audit || audit.status !== "complete" || !audit.result) notFound();
  return (
    <div className="bg-pocket-cream min-h-screen">
      <TeaserResult result={audit.result} />
    </div>
  );
}
HEREDOC

# ── app/api/free-audit/start/route.ts ────────────────────────────────────────
cat > "app/api/free-audit/start/route.ts" << 'HEREDOC'
import { z } from "zod";
import { generateTeaserAudit } from "@/lib/workflows/free-audit";
import { track } from "@/lib/analytics/posthog";

const schema = z.object({
  email: z.string().email(),
  businessName: z.string().min(1),
  websiteUrl: z.string().optional(),
  vertical: z.string().min(1),
});

export const auditStore = new Map<string, { status: "analyzing" | "complete"; result: ReturnType<typeof generateTeaserAudit> | null }>();

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const data = schema.parse(body);
    const auditId = crypto.randomUUID();
    auditStore.set(auditId, { status: "analyzing", result: null });
    track(data.email, "free_audit_started", { vertical: data.vertical, business_name: data.businessName });
    setTimeout(() => {
      const result = generateTeaserAudit(data.vertical, data.businessName);
      auditStore.set(auditId, { status: "complete", result });
      track(data.email, "free_audit_completed", { vertical: data.vertical, score: result.overallScore });
    }, 8000);
    return Response.json({ auditId });
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }
}
HEREDOC

# ── app/api/free-audit/[id]/route.ts ─────────────────────────────────────────
cat > "app/api/free-audit/[id]/route.ts" << 'HEREDOC'
import { auditStore } from "@/app/api/free-audit/start/route";

export async function GET(_request: Request, { params }: { params: { id: string } }) {
  const audit = auditStore.get(params.id);
  if (!audit) return Response.json({ error: "Audit not found" }, { status: 404 });
  return Response.json(audit);
}
HEREDOC

# ── app/api/inngest/route.ts ──────────────────────────────────────────────────
cat > "app/api/inngest/route.ts" << 'HEREDOC'
import { serve } from "inngest/next";
import { inngest } from "@/lib/integrations/inngest/client";

export const { GET, POST, PUT } = serve({ client: inngest, functions: [] });
HEREDOC

# ── app/api/checkout/route.ts ─────────────────────────────────────────────────
cat > "app/api/checkout/route.ts" << 'HEREDOC'
import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { stripe } from "@/lib/stripe/client";

export async function POST(request: Request) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { priceId } = await request.json() as { priceId: string };
  const { data: profile } = await supabase.from("profiles").select("stripe_customer_id").eq("id", user.id).single();

  let customerId = profile?.stripe_customer_id;
  if (!customerId) {
    const customer = await stripe.customers.create({ email: user.email!, metadata: { supabase_user_id: user.id } });
    customerId = customer.id;
    await supabase.from("profiles").update({ stripe_customer_id: customerId }).eq("id", user.id);
  }

  const appUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";
  const session = await stripe.checkout.sessions.create({
    customer: customerId,
    mode: "subscription",
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${appUrl}/settings/billing?success=1`,
    cancel_url: `${appUrl}/pricing`,
    metadata: { supabase_user_id: user.id },
  });

  return NextResponse.json({ url: session.url });
}
HEREDOC

# ── app/api/portal/route.ts ───────────────────────────────────────────────────
cat > "app/api/portal/route.ts" << 'HEREDOC'
import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { stripe } from "@/lib/stripe/client";

export async function POST() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { data: profile } = await supabase.from("profiles").select("stripe_customer_id").eq("id", user.id).single();
  if (!profile?.stripe_customer_id) return NextResponse.json({ error: "No subscription found" }, { status: 404 });

  const appUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";
  const session = await stripe.billingPortal.sessions.create({ customer: profile.stripe_customer_id, return_url: `${appUrl}/settings/billing` });
  return NextResponse.redirect(session.url, { status: 303 });
}
HEREDOC

# ── app/api/webhooks/stripe/route.ts ─────────────────────────────────────────
cat > "app/api/webhooks/stripe/route.ts" << 'HEREDOC'
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
HEREDOC

# ── content/blog/why-we-built-aiyp.mdx ───────────────────────────────────────
cat > content/blog/why-we-built-aiyp.mdx << 'HEREDOC'
---
title: "Why we built Agency in Your Pocket"
date: "2025-04-01"
excerpt: "10 years of running an agency taught us the same lesson every time."
---

# Why we built Agency in Your Pocket

Ten years running an agency. Cafes, jewellery brands, hotels, factories. Same story every time: great product, terrible brand presence.

The cafe with the best coffee in the city — invisible on Google Maps. The jewellery founder with a gorgeous collection — posting inconsistently with no strategy. The hotel paying 18% OTA commission when they could have been booking direct.

**Real agencies cost $2,000+/month.** Most founders can't afford that. So we built the next best thing: an AI that knows exactly what to do, for every vertical, from day one.

Agency in Your Pocket isn't magic. It's the same work we've done for 10 years — orchestrated by AI, guided by expertise, priced so anyone can start.

Every founder deserves agency-quality work. That's why we exist.
HEREDOC

echo "Part 3 done ✓"
