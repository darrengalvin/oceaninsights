'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useSearchParams } from 'next/navigation'
import { 
  ArrowLeft,
  Plus, 
  Search, 
  Filter,
  Eye,
  EyeOff,
  Edit,
  Trash2,
  MoreVertical
} from 'lucide-react'

interface ContentItem {
  id: string
  slug: string
  label: string
  microcopy: string | null
  pillar: string
  audience: string
  sensitivity: string
  is_published: boolean
  created_at: string
  domains: {
    slug: string
    name: string
    icon: string
  }
}

export default function ContentPage() {
  const searchParams = useSearchParams()
  const [content, setContent] = useState<ContentItem[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filterPillar, setFilterPillar] = useState('')
  const [filterPublished, setFilterPublished] = useState(searchParams.get('filter') === 'draft' ? 'false' : '')
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set())
  const [bulkProcessing, setBulkProcessing] = useState(false)

  useEffect(() => {
    fetchContent()
  }, [filterPillar, filterPublished])

  const fetchContent = async () => {
    try {
      setLoading(true)
      const params = new URLSearchParams()
      if (filterPillar) params.set('pillar', filterPillar)
      if (filterPublished) params.set('published', filterPublished)
      if (search) params.set('search', search)

      const res = await fetch(`/api/content?${params}`)
      const data = await res.json()
      setContent(data)
    } catch (error) {
      console.error('Failed to fetch content:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    fetchContent()
  }

  const togglePublished = async (id: string, currentState: boolean) => {
    try {
      await fetch(`/api/content/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_published: !currentState }),
      })
      fetchContent()
    } catch (error) {
      console.error('Failed to toggle published:', error)
    }
  }

  const deleteContent = async (id: string) => {
    if (!confirm('Are you sure you want to delete this content?')) return
    
    try {
      await fetch(`/api/content/${id}`, { method: 'DELETE' })
      fetchContent()
    } catch (error) {
      console.error('Failed to delete:', error)
    }
  }

  const toggleSelect = (id: string) => {
    const newSelected = new Set(selectedIds)
    if (newSelected.has(id)) {
      newSelected.delete(id)
    } else {
      newSelected.add(id)
    }
    setSelectedIds(newSelected)
  }

  const toggleSelectAll = () => {
    if (selectedIds.size === content.length) {
      setSelectedIds(new Set())
    } else {
      setSelectedIds(new Set(content.map(c => c.id)))
    }
  }

  const bulkPublish = async () => {
    if (selectedIds.size === 0) return
    if (!confirm(`Publish ${selectedIds.size} items?`)) return

    setBulkProcessing(true)
    try {
      await Promise.all(
        Array.from(selectedIds).map(id =>
          fetch(`/api/content/${id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ is_published: true }),
          })
        )
      )
      setSelectedIds(new Set())
      fetchContent()
    } catch (error) {
      console.error('Bulk publish failed:', error)
    } finally {
      setBulkProcessing(false)
    }
  }

  const bulkUnpublish = async () => {
    if (selectedIds.size === 0) return
    if (!confirm(`Unpublish ${selectedIds.size} items?`)) return

    setBulkProcessing(true)
    try {
      await Promise.all(
        Array.from(selectedIds).map(id =>
          fetch(`/api/content/${id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ is_published: false }),
          })
        )
      )
      setSelectedIds(new Set())
      fetchContent()
    } catch (error) {
      console.error('Bulk unpublish failed:', error)
    } finally {
      setBulkProcessing(false)
    }
  }

  const bulkDelete = async () => {
    if (selectedIds.size === 0) return
    if (!confirm(`Delete ${selectedIds.size} items? This cannot be undone.`)) return

    setBulkProcessing(true)
    try {
      await Promise.all(
        Array.from(selectedIds).map(id =>
          fetch(`/api/content/${id}`, { method: 'DELETE' })
        )
      )
      setSelectedIds(new Set())
      fetchContent()
    } catch (error) {
      console.error('Bulk delete failed:', error)
    } finally {
      setBulkProcessing(false)
    }
  }

  const pillarColour = (pillar: string) => {
    switch (pillar) {
      case 'understand': return 'bg-blue-100 text-blue-700'
      case 'reflect': return 'bg-purple-100 text-purple-700'
      case 'grow': return 'bg-green-100 text-green-700'
      case 'support': return 'bg-red-100 text-red-700'
      default: return 'bg-gray-100 text-gray-700'
    }
  }

  return (
    <div className="p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Content</h1>
            <p className="text-sm text-gray-500">
              {content.length} items
              {selectedIds.size > 0 && ` • ${selectedIds.size} selected`}
            </p>
          </div>
          
          {selectedIds.size > 0 ? (
            <div className="flex items-center gap-2">
              <button
                onClick={bulkPublish}
                disabled={bulkProcessing}
                className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-green-600 rounded-lg hover:bg-green-700 disabled:opacity-50"
              >
                <Eye className="w-4 h-4" />
                Publish ({selectedIds.size})
              </button>
              <button
                onClick={bulkUnpublish}
                disabled={bulkProcessing}
                className="flex items-center gap-2 px-4 py-2 text-sm text-gray-700 border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50"
              >
                <EyeOff className="w-4 h-4" />
                Unpublish
              </button>
              <button
                onClick={bulkDelete}
                disabled={bulkProcessing}
                className="flex items-center gap-2 px-4 py-2 text-sm text-red-600 border border-red-200 rounded-lg hover:bg-red-50 disabled:opacity-50"
              >
                <Trash2 className="w-4 h-4" />
                Delete
              </button>
            </div>
          ) : (
            <Link
              href="/admin/content/new"
              className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 rounded-lg hover:bg-ocean-700"
            >
              <Plus className="w-4 h-4" />
              Add Content
            </Link>
          )}
        </div>

        {/* Filters */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 mb-6">
          <div className="flex flex-wrap gap-4">
            <form onSubmit={handleSearch} className="flex-1 min-w-64">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search content..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                />
              </div>
            </form>

            <select
              value={filterPillar}
              onChange={(e) => setFilterPillar(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
            >
              <option value="">All Pillars</option>
              <option value="understand">Understand</option>
              <option value="reflect">Reflect</option>
              <option value="grow">Grow</option>
              <option value="support">Support</option>
            </select>

            <select
              value={filterPublished}
              onChange={(e) => setFilterPublished(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
            >
              <option value="">All Status</option>
              <option value="true">Published</option>
              <option value="false">Draft</option>
            </select>
          </div>
        </div>

        {/* Content List */}
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="w-8 h-8 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
          </div>
        ) : content.length === 0 ? (
          <div className="text-center py-12 bg-white rounded-xl border border-gray-200">
            <p className="text-gray-500">No content found</p>
            <Link
              href="/admin/content/new"
              className="inline-flex items-center gap-2 mt-4 px-4 py-2 text-sm text-ocean-600 hover:text-ocean-700"
            >
              <Plus className="w-4 h-4" />
              Add your first content
            </Link>
          </div>
        ) : (
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="w-12 px-6 py-3">
                    <input
                      type="checkbox"
                      checked={selectedIds.size === content.length && content.length > 0}
                      onChange={toggleSelectAll}
                      className="w-4 h-4 text-ocean-600 border-gray-300 rounded focus:ring-ocean-500"
                    />
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Label</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Domain</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pillar</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {content.map((item) => (
                  <tr 
                    key={item.id} 
                    className={`hover:bg-gray-50 ${selectedIds.has(item.id) ? 'bg-ocean-50' : ''}`}
                  >
                    <td className="px-6 py-4">
                      <input
                        type="checkbox"
                        checked={selectedIds.has(item.id)}
                        onChange={() => toggleSelect(item.id)}
                        className="w-4 h-4 text-ocean-600 border-gray-300 rounded focus:ring-ocean-500"
                      />
                    </td>
                    <td className="px-6 py-4">
                      <div>
                        <p className="font-medium text-gray-900">{item.label}</p>
                        {item.microcopy && (
                          <p className="text-sm text-gray-500 truncate max-w-md">{item.microcopy}</p>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {item.domains?.name || 'Unknown'}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full capitalize ${pillarColour(item.pillar)}`}>
                        {item.pillar}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => togglePublished(item.id, item.is_published)}
                        className={`inline-flex items-center gap-1 px-2 py-1 text-xs font-medium rounded-full ${
                          item.is_published 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-yellow-100 text-yellow-700'
                        }`}
                      >
                        {item.is_published ? (
                          <>
                            <Eye className="w-3 h-3" />
                            Published
                          </>
                        ) : (
                          <>
                            <EyeOff className="w-3 h-3" />
                            Draft
                          </>
                        )}
                      </button>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Link
                          href={`/admin/content/${item.id}`}
                          className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg"
                        >
                          <Edit className="w-4 h-4" />
                        </Link>
                        <button
                          onClick={() => deleteContent(item.id)}
                          className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
