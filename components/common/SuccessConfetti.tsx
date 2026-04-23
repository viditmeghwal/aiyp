"use client";
import { useEffect } from "react";
import confetti from "canvas-confetti";

export function SuccessConfetti({ trigger = true }: { trigger?: boolean }) {
  useEffect(() => {
    if (!trigger) return;
    confetti({ particleCount: 120, spread: 70, origin: { y: 0.6 }, colors: ["#F97316", "#FFE4D6", "#C2410C", "#FFF8F1", "#0F172A"] });
  }, [trigger]);
  return null;
}
