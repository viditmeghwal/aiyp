"use client";
import { useEffect } from "react";
import { useToast } from "@/hooks/use-toast";

export function BillingSuccessNotifier() {
  const { toast } = useToast();
  useEffect(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      if (params.get("success") === "1") {
        toast({ title: "Plan upgraded!", description: "Your subscription is now active. Welcome to the next level." });
        const url = new URL(window.location.href);
        url.searchParams.delete("success");
        window.history.replaceState({}, "", url.toString());
      }
    }
  }, [toast]);
  return null;
}
