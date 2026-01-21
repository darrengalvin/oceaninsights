'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { 
  LayoutDashboard, 
  BookOpen, 
  Folders, 
  Route, 
  Settings,
  Plus,
  FileText,
  Eye,
  EyeOff,
  RefreshCw
} from 'lucide-react'

interface Stats {
  totalContent: number
  publishedContent: number
  draftContent: number
  domains: number
  journeys: number
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const res = await fetch('/api/stats')
      const data = await res.json()
      setStats(data)
    } catch (error) {
      console.error('Failed to fetch stats:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-8">
        <div className="max-w-6xl mx-auto">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">Dashboard</h2>
              <p className="text-gray-500">Overview of your content</p>
            </div>
            
            <div className="flex gap-3">
              <button 
                onClick={fetchStats}
                className="flex items-center gap-2 px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
              >
                <RefreshCw className="w-4 h-4" />
                Refresh
              </button>
              
              <Link 
                href="/content/new"
                className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 rounded-lg hover:bg-ocean-700"
              >
                <Plus className="w-4 h-4" />
                Add Content
              </Link>
            </div>
          </div>

          {loading ? (
            <div className="flex items-center justify-center h-64">
              <div className="w-8 h-8 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
            </div>
          ) : stats ? (
            <>
              {/* Stats Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div className="bg-white p-6 rounded-xl border border-gray-200">
                  <div className="flex items-center gap-4">
                    <div className="p-3 bg-ocean-50 rounded-lg">
                      <FileText className="w-6 h-6 text-ocean-600" />
                    </div>
                    <div>
                      <p className="text-2xl font-bold text-gray-900">{stats.totalContent}</p>
                      <p className="text-sm text-gray-500">Total Content</p>
                    </div>
                  </div>
                </div>

                <div className="bg-white p-6 rounded-xl border border-gray-200">
                  <div className="flex items-center gap-4">
                    <div className="p-3 bg-green-50 rounded-lg">
                      <Eye className="w-6 h-6 text-green-600" />
                    </div>
                    <div>
                      <p className="text-2xl font-bold text-gray-900">{stats.publishedContent}</p>
                      <p className="text-sm text-gray-500">Published</p>
                    </div>
                  </div>
                </div>

                <div className="bg-white p-6 rounded-xl border border-gray-200">
                  <div className="flex items-center gap-4">
                    <div className="p-3 bg-yellow-50 rounded-lg">
                      <EyeOff className="w-6 h-6 text-yellow-600" />
                    </div>
                    <div>
                      <p className="text-2xl font-bold text-gray-900">{stats.draftContent}</p>
                      <p className="text-sm text-gray-500">Drafts</p>
                    </div>
                  </div>
                </div>

                <div className="bg-white p-6 rounded-xl border border-gray-200">
                  <div className="flex items-center gap-4">
                    <div className="p-3 bg-purple-50 rounded-lg">
                      <Folders className="w-6 h-6 text-purple-600" />
                    </div>
                    <div>
                      <p className="text-2xl font-bold text-gray-900">{stats.domains}</p>
                      <p className="text-sm text-gray-500">Domains</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Quick Actions */}
              <div className="bg-white rounded-xl border border-gray-200 p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <Link
                    href="/content/new"
                    className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <div className="p-2 bg-ocean-50 rounded-lg">
                      <Plus className="w-5 h-5 text-ocean-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">Add New Content</p>
                      <p className="text-sm text-gray-500">Create a new guidance item</p>
                    </div>
                  </Link>

                  <Link
                    href="/scenarios/new"
                    className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <div className="p-2 bg-blue-50 rounded-lg">
                      <BookOpen className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">New Scenario</p>
                      <p className="text-sm text-gray-500">Create decision training</p>
                    </div>
                  </Link>

                  <Link
                    href="/protocols/new"
                    className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <div className="p-2 bg-green-50 rounded-lg">
                      <FileText className="w-5 h-5 text-green-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">New Protocol</p>
                      <p className="text-sm text-gray-500">Build communication guide</p>
                    </div>
                  </Link>

                  <Link
                    href="/content?filter=draft"
                    className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <div className="p-2 bg-yellow-50 rounded-lg">
                      <EyeOff className="w-5 h-5 text-yellow-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">Review Drafts</p>
                      <p className="text-sm text-gray-500">Publish pending content</p>
                    </div>
                  </Link>

                  <Link
                    href="/journeys/new"
                    className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <div className="p-2 bg-purple-50 rounded-lg">
                      <Route className="w-5 h-5 text-purple-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">Create Journey</p>
                      <p className="text-sm text-gray-500">Build a guided pathway</p>
                    </div>
                  </Link>

                  <Link
                    href="/import"
                    className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <div className="p-2 bg-teal-50 rounded-lg">
                      <Plus className="w-5 h-5 text-teal-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">Import from GPT</p>
                      <p className="text-sm text-gray-500">Bulk import generated content</p>
                    </div>
                  </Link>
                </div>
              </div>
            </>
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-500">Unable to load stats. Check your connection.</p>
            </div>
          )}
        </div>
    </div>
  )
}

