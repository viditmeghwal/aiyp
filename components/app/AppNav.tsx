"use client";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Bell, LogOut, Settings, User, ShieldCheck } from "lucide-react";
import { Logo } from "@/components/brand/Logo";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { createClient } from "@/lib/supabase/client";

interface AppNavProps { fullName: string | null; email: string; isAdmin: boolean; }

export function AppNav({ fullName, email, isAdmin }: AppNavProps) {
  const router = useRouter();
  async function handleLogout() { const supabase = createClient(); await supabase.auth.signOut(); router.push("/login"); router.refresh(); }
  const initials = fullName ? fullName.split(" ").map((p) => p[0]).join("").toUpperCase().slice(0, 2) : email.slice(0, 2).toUpperCase();
  return (
    <header className="sticky top-0 z-40 h-14 border-b border-ink-200 bg-white/90 backdrop-blur-sm">
      <div className="flex h-full items-center justify-between px-4 max-w-screen-2xl mx-auto">
        <Link href="/dashboard"><Logo size="sm" /></Link>
        <div className="flex items-center gap-2">
          <button className="relative p-2 rounded-lg hover:bg-ink-100 transition-colors"><Bell className="w-4 h-4 text-ink-500" /></button>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-ink-100 transition-colors">
                <Avatar className="w-7 h-7"><AvatarFallback className="bg-pocket-orange text-white text-xs font-semibold">{initials}</AvatarFallback></Avatar>
                <span className="hidden sm:block text-sm font-medium text-ink-700 max-w-[140px] truncate">{fullName ?? email}</span>
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-52">
              <div className="px-3 py-2"><p className="text-sm font-medium text-ink-900 truncate">{fullName ?? "Account"}</p><p className="text-xs text-ink-500 truncate">{email}</p></div>
              <DropdownMenuSeparator />
              <DropdownMenuItem asChild><Link href="/settings/profile" className="flex items-center gap-2"><User className="w-4 h-4" />Profile</Link></DropdownMenuItem>
              <DropdownMenuItem asChild><Link href="/settings/billing" className="flex items-center gap-2"><Settings className="w-4 h-4" />Billing</Link></DropdownMenuItem>
              {isAdmin && (<><DropdownMenuSeparator /><DropdownMenuItem asChild><Link href="/admin" className="flex items-center gap-2 text-pocket-orange"><ShieldCheck className="w-4 h-4" />Admin</Link></DropdownMenuItem></>)}
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleLogout} className="flex items-center gap-2 text-red-600 focus:text-red-600"><LogOut className="w-4 h-4" />Log out</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}
