import { cn } from "@/lib/utils";

const sizeMap = { sm: "text-lg", md: "text-2xl", lg: "text-4xl" } as const;

interface LogoProps { size?: keyof typeof sizeMap; withMark?: boolean; className?: string; }

export function Logo({ size = "md", withMark = true, className }: LogoProps) {
  return (
    <span className={cn("inline-flex items-center gap-2", className)}>
      {withMark && (
        <span className="inline-block rounded-md bg-pocket-orange flex-shrink-0"
          style={{ width: size === "lg" ? 24 : size === "md" ? 18 : 14, height: size === "lg" ? 24 : size === "md" ? 18 : 14 }}
          aria-hidden="true" />
      )}
      <span className={cn("font-bold tracking-tight", sizeMap[size])}>
        <span className="text-ink-900 font-sans">Agency in </span>
        <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>Your Pocket</span>
      </span>
    </span>
  );
}
