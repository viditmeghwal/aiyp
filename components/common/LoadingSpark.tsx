"use client";
import { motion } from "framer-motion";

const sizes = { sm: "w-4 h-4", md: "w-8 h-8", lg: "w-12 h-12" };

export function LoadingSpark({ size = "md", label }: { size?: "sm" | "md" | "lg"; label?: string }) {
  return (
    <div className="flex flex-col items-center gap-3">
      <motion.div className={`${sizes[size]} rounded-full bg-pocket-orange`}
        animate={{ scale: [1, 1.3, 1], opacity: [1, 0.6, 1] }}
        transition={{ duration: 1.2, repeat: Infinity, ease: "easeInOut" }} />
      {label && <p className="text-sm text-ink-500">{label}</p>}
    </div>
  );
}

export function LoadingSparkPage({ label = "Loading…" }: { label?: string }) {
  return (
    <div className="flex items-center justify-center min-h-[40vh]">
      <LoadingSpark size="lg" label={label} />
    </div>
  );
}
