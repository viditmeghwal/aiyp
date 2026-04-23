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
