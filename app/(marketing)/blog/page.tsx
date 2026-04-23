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
