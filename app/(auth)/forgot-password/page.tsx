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
