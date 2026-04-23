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
