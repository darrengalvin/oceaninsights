'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { 
  LayoutDashboard, 
  BookOpen, 
  Folders, 
  Route, 
  Settings,
  Plus,
  FileText,
} from 'lucide-react'

export default function Sidebar() {
  const pathname = usePathname()
  
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

  return (
    <aside className="w-64 bg-white border-r border-gray-200 p-6 flex-shrink-0">
      <div className="mb-8">
        <Link href="/">
          <h1 className="text-xl font-bold text-ocean-700 cursor-pointer">Ocean Insight</h1>
          <p className="text-sm text-gray-500">Admin Panel</p>
        </Link>
      </div>
      
      <nav className="space-y-1">
        <Link href="/" className={linkClass('/')}>
          <LayoutDashboard className="w-5 h-5" />
          Dashboard
        </Link>
        
        <Link href="/content" className={linkClass('/content')}>
          <BookOpen className="w-5 h-5" />
          Navigate Content
        </Link>
        
        <Link href="/learn" className={linkClass('/learn')}>
          <FileText className="w-5 h-5" />
          Learn Articles
        </Link>
        
        <Link href="/domains" className={linkClass('/domains')}>
          <Folders className="w-5 h-5" />
          Domains
        </Link>
        
        <Link href="/journeys" className={linkClass('/journeys')}>
          <Route className="w-5 h-5" />
          Journeys
        </Link>
        
        <div className="my-2 border-t border-gray-200" />
        
        <Link href="/scenarios" className={linkClass('/scenarios')}>
          <BookOpen className="w-5 h-5" />
          Scenarios
        </Link>
        
        <Link href="/protocols" className={linkClass('/protocols')}>
          <FileText className="w-5 h-5" />
          Protocols
        </Link>
        
        <div className="my-2 border-t border-gray-200" />
        
        <Link href="/import" className={linkClass('/import')}>
          <Plus className="w-5 h-5" />
          Import from GPT
        </Link>
        
        <Link href="/settings" className={linkClass('/settings')}>
          <Settings className="w-5 h-5" />
          Settings
        </Link>
      </nav>
    </aside>
  )
}

