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
