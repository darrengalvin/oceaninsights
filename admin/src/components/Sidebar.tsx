'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import { 
  LayoutDashboard, 
  BookOpen, 
  Folders, 
  Route, 
  Plus,
  FileText,
  Menu,
  X,
} from 'lucide-react'

export default function Sidebar() {
  const pathname = usePathname()
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  
  const isActive = (path: string) => {
    if (path === '/') {
      return pathname === '/'
    }
    return pathname.startsWith(path)
  }
  
  const linkClass = (path: string) => {
    return isActive(path)
      ? "flex items-center gap-3 px-3 py-2 text-sm font-medium text-ocean-700 bg-ocean-50 rounded-lg"
      : "flex items-center gap-3 px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 rounded-lg"
  }

  const closeMobileMenu = () => setIsMobileMenuOpen(false)

  const SidebarContent = () => (
    <>
      <div className="mb-8">
        <Link href="/" onClick={closeMobileMenu}>
          <h1 className="text-xl font-bold text-ocean-700 cursor-pointer">Ocean Insight</h1>
          <p className="text-sm text-gray-500">Admin Panel</p>
        </Link>
      </div>
      
      <nav className="space-y-1">
        <Link href="/" className={linkClass('/')} onClick={closeMobileMenu}>
          <LayoutDashboard className="w-5 h-5" />
          Dashboard
        </Link>
        
        <Link href="/content" className={linkClass('/content')} onClick={closeMobileMenu}>
          <BookOpen className="w-5 h-5" />
          Navigate Content
        </Link>
        
        <Link href="/learn" className={linkClass('/learn')} onClick={closeMobileMenu}>
          <FileText className="w-5 h-5" />
          Learn Articles
        </Link>
        
        <Link href="/domains" className={linkClass('/domains')} onClick={closeMobileMenu}>
          <Folders className="w-5 h-5" />
          Domains
        </Link>
        
        <Link href="/journeys" className={linkClass('/journeys')} onClick={closeMobileMenu}>
          <Route className="w-5 h-5" />
          Journeys
        </Link>
        
        <div className="my-2 border-t border-gray-200" />
        
        <Link href="/scenarios" className={linkClass('/scenarios')} onClick={closeMobileMenu}>
          <BookOpen className="w-5 h-5" />
          Scenarios
        </Link>
        
        <Link href="/protocols" className={linkClass('/protocols')} onClick={closeMobileMenu}>
          <FileText className="w-5 h-5" />
          Protocols
        </Link>
        
        <div className="my-2 border-t border-gray-200" />
        
        <Link href="/import" className={linkClass('/import')} onClick={closeMobileMenu}>
          <Plus className="w-5 h-5" />
          Import from GPT
        </Link>
      </nav>
    </>
  )

  return (
    <>
      {/* Mobile Header */}
      <div className="lg:hidden fixed top-0 left-0 right-0 z-50 bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
        <Link href="/">
          <h1 className="text-lg font-bold text-ocean-700">Ocean Insight</h1>
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
        className={`lg:hidden fixed top-0 left-0 bottom-0 z-50 w-64 bg-white border-r border-gray-200 p-6 transform transition-transform duration-300 ease-in-out ${
          isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <SidebarContent />
      </aside>

      {/* Desktop Sidebar */}
      <aside className="hidden lg:block w-64 bg-white border-r border-gray-200 p-6 flex-shrink-0">
        <SidebarContent />
      </aside>

      {/* Spacer for mobile header */}
      <div className="lg:hidden h-14" />
    </>
  )
}
