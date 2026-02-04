'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Plus, Search, Eye, EyeOff, Edit, Trash2 } from 'lucide-react'

interface LearnArticle {
  id: string
  slug: string
  title: string
  summary: string
  category: 'brain_science' | 'psychology' | 'life_situation'
  read_time_minutes: number
  is_published: boolean
  created_at: string
}

const categoryLabels = {
  brain_science: 'Brain Science',
  psychology: 'Psychology',
  life_situation: 'Life Situations'
}

const categoryColors = {
  brain_science: 'bg-blue-100 text-blue-700',
  psychology: 'bg-purple-100 text-purple-700',
  life_situation: 'bg-green-100 text-green-700'
}

export default function LearnPage() {
  const [articles, setArticles] = useState<LearnArticle[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [categoryFilter, setCategoryFilter] = useState<string>('all')

  useEffect(() => {
    fetchArticles()
  }, [])

  const fetchArticles = async () => {
    try {
      const res = await fetch('/api/learn')
      const data = await res.json()
      setArticles(data)
    } catch (error) {
      console.error('Failed to fetch articles:', error)
    } finally {
      setLoading(false)
    }
  }

  const deleteArticle = async (id: string) => {
    if (!confirm('Are you sure you want to delete this article?')) return
    
    try {
      await fetch(`/api/learn/${id}`, { method: 'DELETE' })
      fetchArticles()
    } catch (error) {
      console.error('Failed to delete:', error)
    }
  }

  const togglePublish = async (id: string, currentStatus: boolean) => {
    try {
      await fetch(`/api/learn/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_published: !currentStatus })
      })
      fetchArticles()
    } catch (error) {
      console.error('Failed to toggle publish:', error)
    }
  }

  const filteredArticles = articles.filter(article => {
    const matchesSearch = article.title.toLowerCase().includes(search.toLowerCase()) ||
                         article.summary.toLowerCase().includes(search.toLowerCase())
    const matchesCategory = categoryFilter === 'all' || article.category === categoryFilter
    return matchesSearch && matchesCategory
  })

  const stats = {
    total: articles.length,
    published: articles.filter(a => a.is_published).length,
    draft: articles.filter(a => !a.is_published).length,
    brainScience: articles.filter(a => a.category === 'brain_science').length,
    psychology: articles.filter(a => a.category === 'psychology').length,
    lifeSituation: articles.filter(a => a.category === 'life_situation').length
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="w-8 h-8 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-6 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Learn Articles</h1>
              <p className="text-sm text-gray-500 mt-1">Educational content management</p>
            </div>
            <Link
              href="/learn/new"
              className="flex items-center gap-2 px-4 py-2 bg-ocean-600 text-white rounded-lg hover:bg-ocean-700"
            >
              <Plus className="w-4 h-4" />
              New Article
            </Link>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-2 md:grid-cols-6 gap-4 mt-6">
            <div className="bg-gray-50 rounded-lg p-4">
              <div className="text-2xl font-bold text-gray-900">{stats.total}</div>
              <div className="text-xs text-gray-500">Total</div>
            </div>
            <div className="bg-green-50 rounded-lg p-4">
              <div className="text-2xl font-bold text-green-700">{stats.published}</div>
              <div className="text-xs text-green-600">Published</div>
            </div>
            <div className="bg-amber-50 rounded-lg p-4">
              <div className="text-2xl font-bold text-amber-700">{stats.draft}</div>
              <div className="text-xs text-amber-600">Draft</div>
            </div>
            <div className="bg-blue-50 rounded-lg p-4">
              <div className="text-2xl font-bold text-blue-700">{stats.brainScience}</div>
              <div className="text-xs text-blue-600">Brain Sci</div>
            </div>
            <div className="bg-purple-50 rounded-lg p-4">
              <div className="text-2xl font-bold text-purple-700">{stats.psychology}</div>
              <div className="text-xs text-purple-600">Psychology</div>
            </div>
            <div className="bg-green-50 rounded-lg p-4">
              <div className="text-2xl font-bold text-green-700">{stats.lifeSituation}</div>
              <div className="text-xs text-green-600">Life</div>
            </div>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="max-w-7xl mx-auto px-6 py-6">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search articles..."
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
            />
          </div>
          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
          >
            <option value="all">All Categories</option>
            <option value="brain_science">Brain Science</option>
            <option value="psychology">Psychology</option>
            <option value="life_situation">Life Situations</option>
          </select>
        </div>
      </div>

      {/* Articles List */}
      <div className="max-w-7xl mx-auto px-6 pb-12">
        {filteredArticles.length === 0 ? (
          <div className="bg-white rounded-xl border border-gray-200 p-12 text-center">
            <div className="text-gray-400 mb-2">📚</div>
            <h3 className="text-lg font-semibold text-gray-900 mb-1">No articles found</h3>
            <p className="text-gray-500 text-sm">
              {search || categoryFilter !== 'all' 
                ? 'Try adjusting your filters'
                : 'Create your first article to get started'}
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredArticles.map((article) => (
              <div
                key={article.id}
                className="bg-white rounded-xl border border-gray-200 p-4 hover:border-ocean-300 transition-colors"
              >
                <div className="flex items-start gap-4">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-2">
                      <span className={`text-xs font-medium px-2 py-1 rounded ${categoryColors[article.category]}`}>
                        {categoryLabels[article.category]}
                      </span>
                      {!article.is_published && (
                        <span className="text-xs font-medium px-2 py-1 rounded bg-gray-100 text-gray-600">
                          Draft
                        </span>
                      )}
                      <span className="text-xs text-gray-400">
                        {article.read_time_minutes} min read
                      </span>
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">
                      {article.title}
                    </h3>
                    <p className="text-sm text-gray-600 line-clamp-2">
                      {article.summary}
                    </p>
                    <p className="text-xs text-gray-400 mt-2">
                      {article.slug}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => togglePublish(article.id, article.is_published)}
                      className={`p-2 rounded-lg transition-colors ${
                        article.is_published
                          ? 'bg-green-50 text-green-600 hover:bg-green-100'
                          : 'bg-gray-50 text-gray-400 hover:bg-gray-100'
                      }`}
                      title={article.is_published ? 'Unpublish' : 'Publish'}
                    >
                      {article.is_published ? (
                        <Eye className="w-4 h-4" />
                      ) : (
                        <EyeOff className="w-4 h-4" />
                      )}
                    </button>
                    <Link
                      href={`/learn/${article.id}`}
                      className="p-2 rounded-lg bg-ocean-50 text-ocean-600 hover:bg-ocean-100 transition-colors"
                    >
                      <Edit className="w-4 h-4" />
                    </Link>
                    <button
                      onClick={() => deleteArticle(article.id)}
                      className="p-2 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}



