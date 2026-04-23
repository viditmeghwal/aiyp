import type { Metadata } from "next";
import { Inter, Fraunces } from "next/font/google";
import { PostHogProvider } from "@/components/providers/PostHogProvider";
import "./globals.css";

const inter = Inter({ subsets: ["latin"], variable: "--font-geist-sans", display: "swap" });
const fraunces = Fraunces({ subsets: ["latin"], style: "italic", weight: ["400", "600", "700"], variable: "--font-fraunces", display: "swap" });

export const metadata: Metadata = {
  title: { default: "Agency in Your Pocket", template: "%s | Agency in Your Pocket" },
  description: "Everything a real agency does — right in your pocket.",
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000"),
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${fraunces.variable}`}>
      <body className="antialiased"><PostHogProvider>{children}</PostHogProvider></body>
    </html>
  );
}
