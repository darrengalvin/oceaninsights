'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import {
  LayoutDashboard,
  BookOpen,
  Folders,
  Route,
  Upload,
  FileText,
  Menu,
  X,
  Sparkles,
  BarChart3,
  CreditCard,
  Globe,
  Target,
  Settings2,
  LogOut,
  ShieldCheck,
  Building2,
  LifeBuoy,
  PenLine,
  Compass,
  MessagesSquare,
  type LucideIcon,
} from 'lucide-react'

interface NavItem { href: string; label: string; icon: LucideIcon; hint?: string; badge?: string }

// Grouped by what the person is trying to do, in plain English.
const NAV: { heading: string; items: NavItem[] }[] = [
  {
    heading: 'Start here',
    items: [
      { href: '/admin', label: 'Dashboard', icon: LayoutDashboard },
      { href: '/admin/help', label: 'Help and guide', icon: LifeBuoy, hint: 'How to add and change content' },
    ],
  },
  {
    heading: 'App content',
    items: [
      { href: '/admin/content-manager', label: 'Content Manager', icon: PenLine, hint: 'Every tool and topic in the app' },
      { href: '/admin/content', label: 'Navigate articles', icon: Compass, hint: 'Articles on the Navigate screen' },
      { href: '/admin/domains', label: 'Navigate topics', icon: Folders },
      { href: '/admin/rituals', label: 'Ritual topics', icon: Sparkles },
      { href: '/admin/scenarios', label: 'Scenarios', icon: MessagesSquare, hint: 'Decision training scenarios' },
      { href: '/admin/protocols', label: 'Protocols', icon: FileText, hint: 'Communication guides' },
      { href: '/admin/objectives', label: 'Mission objectives', icon: Target },
    ],
  },
  {
    heading: 'Checks',
    items: [
      { href: '/admin/audit', label: 'Content audit', icon: ShieldCheck, hint: 'Safety and source checks' },
    ],
  },
  {
    heading: 'Not in the app yet',
    items: [
      { href: '/admin/learn', label: 'Learn articles', icon: BookOpen, badge: 'Not live', hint: 'The app shows its own built-in Learn articles, not these' },
      { href: '/admin/journeys', label: 'Journeys', icon: Route, badge: 'Not live', hint: 'The app does not show journeys yet' },
    ],
  },
  {
    heading: 'Business',
    items: [
      { href: '/admin/analytics', label: 'Analytics', icon: BarChart3 },
      { href: '/admin/sponsorship', label: 'Sponsorship', icon: Building2 },
      { href: '/admin/subscriptions', label: 'Subscriptions', icon: CreditCard },
    ],
  },
  {
    heading: 'Tools',
    items: [
      { href: '/admin/import', label: 'Bulk import', icon: Upload, hint: 'Import AI-drafted Navigate content' },
      { href: '/admin/settings', label: 'App settings', icon: Settings2 },
    ],
  },
]

export default function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  async function handleSignOut() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }
  
  const isActive = (path: string) => {
    if (path === '/admin') {
      return pathname === '/admin'
    }
    // Match whole path segments, so /admin/content does not also light up for /admin/content-manager.
    return pathname === path || pathname.startsWith(path + '/')
  }
  
  const linkClass = (path: string) => {
    return isActive(path)
      ? "flex items-center gap-3 px-3 py-2 text-sm font-medium text-ocean-700 bg-ocean-50 rounded-lg"
      : "flex items-center gap-3 px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 rounded-lg"
  }

  const closeMobileMenu = () => setIsMobileMenuOpen(false)

  const SidebarContent = () => (
    <>
      <div className="mb-6">
        <Link href="/admin" onClick={closeMobileMenu}>
          <h1 className="text-xl font-bold text-ocean-700 cursor-pointer">Below the Surface</h1>
          <p className="text-sm text-gray-500">Content admin</p>
        </Link>
      </div>
      
      <nav className="space-y-5">
        {NAV.map((group) => (
          <div key={group.heading}>
            <p className="px-3 mb-1 text-[11px] font-semibold uppercase tracking-wider text-gray-400">{group.heading}</p>
            <div className="space-y-0.5">
              {group.items.map((item) => (
                <Link key={item.href} href={item.href} className={linkClass(item.href)} onClick={closeMobileMenu} title={item.hint}>
                  <item.icon className="w-5 h-5 flex-shrink-0" />
                  <span className="flex-1">{item.label}</span>
                  {item.badge && (
                    <span className="text-[10px] font-medium px-1.5 py-0.5 rounded bg-amber-100 text-amber-800">{item.badge}</span>
                  )}
                </Link>
              ))}
            </div>
          </div>
        ))}

        <div className="pt-2 border-t border-gray-200 space-y-0.5">
          <Link href="/" className="flex items-center gap-3 px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 rounded-lg" onClick={closeMobileMenu}>
            <Globe className="w-5 h-5" />
            Public website
          </Link>
          <button
            onClick={handleSignOut}
            className="flex items-center gap-3 px-3 py-2 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg w-full"
          >
            <LogOut className="w-5 h-5" />
            Sign out
          </button>
        </div>
      </nav>
    </>
  )

  return (
    <>
      {/* Mobile Header */}
      <div className="lg:hidden fixed top-0 left-0 right-0 z-50 bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
        <Link href="/admin">
          <h1 className="text-lg font-bold text-ocean-700">Below the Surface</h1>
        </Link>
        <button
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          className="p-2 text-gray-600 hover:bg-gray-100 rounded-lg"
          aria-label="Toggle menu"
        >
          {isMobileMenuOpen ? (
            <X className="w-6 h-6" />
          ) : (
            <Menu className="w-6 h-6" />
          )}
        </button>
      </div>

      {/* Mobile Sidebar Overlay */}
      {isMobileMenuOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-black bg-opacity-50 z-40"
          onClick={closeMobileMenu}
        />
      )}

      {/* Mobile Sidebar Drawer */}
      <aside
        className={`lg:hidden fixed top-0 left-0 bottom-0 z-50 w-64 bg-white border-r border-gray-200 p-6 overflow-y-auto transform transition-transform duration-300 ease-in-out ${
          isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <SidebarContent />
      </aside>

      {/* Desktop Sidebar */}
      <aside className="hidden lg:block w-64 bg-white border-r border-gray-200 p-6 flex-shrink-0 sticky top-0 h-screen overflow-y-auto">
        <SidebarContent />
      </aside>

      {/* Spacer for mobile header */}
      <div className="lg:hidden h-14" />
    </>
  )
}
