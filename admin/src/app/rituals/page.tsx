'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { CheckCircle, AlertCircle, RefreshCw, Sparkles, Users, Star, Clock } from 'lucide-react'

interface Category {
  id: string
  slug: string
  name: string
  icon: string
  color: string
}

interface Topic {
  id: string
  slug: string
  name: string
  tagline: string
  description: string
  icon: string
  difficulty: string
  estimated_days: number
  is_featured: boolean
  is_published: boolean
  subscriber_count: number
  category: Category
  ritual_items: { count: number }[]
  ritual_affirmations: { count: number }[]
}

export default function RitualsPage() {
  const [topics, setTopics] = useState<Topic[]>([])
  const [categories, setCategories] = useState<Category[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'published' | 'draft' | 'featured'>('all')
  const [categoryFilter, setCategoryFilter] = useState<string>('all')
  const [bulkPublishing, setBulkPublishing] = useState(false)

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    try {
      const [topicsRes, categoriesRes] = await Promise.all([
        fetch('/api/rituals/topics'),
        fetch('/api/rituals/categories')
      ])
      
      const topicsData = await topicsRes.json()
      const categoriesData = await categoriesRes.json()
      
      setTopics(topicsData)
      setCategories(categoriesData)
    } catch (error) {
      console.error('Failed to fetch data:', error)
    } finally {
      setLoading(false)
    }
  }

  const togglePublished = async (id: string, currentStatus: boolean) => {
    try {
      const res = await fetch(`/api/rituals/topics/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_published: !currentStatus })
      })

      if (!res.ok) throw new Error('Failed to update')
      fetchData()
    } catch (error) {
      console.error('Toggle publish error:', error)
      alert('Failed to update topic')
    }
  }

  const toggleFeatured = async (id: string, currentStatus: boolean) => {
    try {
      const res = await fetch(`/api/rituals/topics/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_featured: !currentStatus })
      })

      if (!res.ok) throw new Error('Failed to update')
      fetchData()
    } catch (error) {
      console.error('Toggle featured error:', error)
      alert('Failed to update topic')
    }
  }

  const handleBulkPublish = async () => {
    const draftTopics = topics.filter(t => !t.is_published)
    if (draftTopics.length === 0) {
      alert('No draft topics to publish!')
      return
    }

    if (!confirm(`Publish all ${draftTopics.length} draft topics?`)) {
      return
    }

    setBulkPublishing(true)

    try {
      await Promise.all(
        draftTopics.map(topic =>
          fetch(`/api/rituals/topics/${topic.id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ is_published: true })
          })
        )
      )

      alert(`Published ${draftTopics.length} topics!`)
      fetchData()
    } catch (error) {
      console.error('Bulk publish error:', error)
      alert('Failed to publish some topics')
    } finally {
      setBulkPublishing(false)
    }
  }

  const difficultyBadge = (difficulty: string) => {
    const colors: Record<string, string> = {
      beginner: 'bg-green-100 text-green-700',
      intermediate: 'bg-yellow-100 text-yellow-700',
      advanced: 'bg-red-100 text-red-700'
    }
    return colors[difficulty] || 'bg-gray-100 text-gray-700'
  }

  const filteredTopics = topics.filter(topic => {
    if (filter === 'published' && !topic.is_published) return false
    if (filter === 'draft' && topic.is_published) return false
    if (filter === 'featured' && !topic.is_featured) return false
    if (categoryFilter !== 'all' && topic.category?.slug !== categoryFilter) return false
    return true
  })

  // Group topics by category
  const topicsByCategory = categories.map(cat => ({
    category: cat,
    topics: filteredTopics.filter(t => t.category?.id === cat.id)
  })).filter(group => group.topics.length > 0)

  if (loading) {
    return (
      <div className="p-6 max-w-7xl mx-auto">
        <p className="text-gray-500">Loading ritual topics...</p>
      </div>
    )
  }

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Ritual Topics</h1>
          <p className="text-gray-600 mt-1">Manage ritual packs and daily practices</p>
        </div>
        <div className="flex gap-3 flex-wrap">
          {topics.filter(t => !t.is_published).length > 0 && (
            <button
              onClick={handleBulkPublish}
              disabled={bulkPublishing}
              className="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed shadow-sm"
            >
              {bulkPublishing ? (
                <>
                  <RefreshCw className="w-4 h-4 animate-spin" />
                  Publishing...
                </>
              ) : (
                <>
                  <CheckCircle className="w-4 h-4" />
                  Publish All Drafts ({topics.filter(t => !t.is_published).length})
                </>
              )}
            </button>
          )}
          <Link
            href="/rituals/new"
            className="bg-ocean-600 hover:bg-ocean-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm"
          >
            + New Topic
          </Link>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-2xl font-bold text-gray-900">{topics.length}</div>
          <div className="text-sm text-gray-500">Total Topics</div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-2xl font-bold text-green-600">{topics.filter(t => t.is_published).length}</div>
          <div className="text-sm text-gray-500">Published</div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-2xl font-bold text-yellow-600">{topics.filter(t => !t.is_published).length}</div>
          <div className="text-sm text-gray-500">Drafts</div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-2xl font-bold text-ocean-600">{topics.filter(t => t.is_featured).length}</div>
          <div className="text-sm text-gray-500">Featured</div>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4 mb-6">
        {/* Status Filter */}
        <div className="border-b border-gray-200 flex-1">
          <nav className="flex gap-6">
            {[
              { key: 'all', label: 'All' },
              { key: 'published', label: 'Published' },
              { key: 'draft', label: 'Drafts' },
              { key: 'featured', label: 'Featured' }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setFilter(tab.key as any)}
                className={`pb-3 px-1 border-b-2 font-medium text-sm transition-colors ${
                  filter === tab.key
                    ? 'border-ocean-600 text-ocean-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </nav>
        </div>

        {/* Category Filter */}
        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
        >
          <option value="all">All Categories</option>
          {categories.map(cat => (
            <option key={cat.id} value={cat.slug}>{cat.name}</option>
          ))}
        </select>
      </div>

      {/* Topics by Category */}
      {topicsByCategory.length === 0 ? (
        <div className="bg-gray-50 border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
          <div className="text-gray-400 mb-4">
            <Sparkles className="mx-auto h-12 w-12" />
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No ritual topics found</h3>
          <p className="text-gray-500 mb-6">Get started by creating your first ritual topic.</p>
          <Link
            href="/rituals/new"
            className="inline-block bg-ocean-600 hover:bg-ocean-700 text-white px-6 py-2 rounded-lg font-medium transition-colors shadow-sm"
          >
            Create Topic
          </Link>
        </div>
      ) : (
        <div className="space-y-8">
          {topicsByCategory.map(({ category, topics: categoryTopics }) => (
            <div key={category.id}>
              <div className="flex items-center gap-3 mb-4">
                <div 
                  className="w-8 h-8 rounded-lg flex items-center justify-center text-white text-lg"
                  style={{ backgroundColor: category.color }}
                >
                  {category.icon === 'favorite' && '❤️'}
                  {category.icon === 'work_outline' && '💼'}
                  {category.icon === 'psychology' && '🧠'}
                  {category.icon === 'fitness_center' && '💪'}
                  {category.icon === 'autorenew' && '🔄'}
                  {category.icon === 'spa' && '🧘'}
                  {category.icon === 'groups' && '👥'}
                </div>
                <h2 className="text-xl font-semibold text-gray-900">{category.name}</h2>
                <span className="text-sm text-gray-500">({categoryTopics.length} topics)</span>
              </div>

              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                {categoryTopics.map(topic => (
                  <div key={topic.id} className="bg-white rounded-lg shadow hover:shadow-md transition-shadow p-5">
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="font-semibold text-gray-900">{topic.name}</h3>
                          {topic.is_featured && (
                            <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                          )}
                        </div>
                        <p className="text-sm text-gray-500 italic">{topic.tagline}</p>
                      </div>
                      <button
                        onClick={() => togglePublished(topic.id, topic.is_published)}
                        className={`px-2 py-1 text-xs font-medium rounded-full transition-colors ${
                          topic.is_published
                            ? 'bg-green-100 text-green-700 hover:bg-green-200'
                            : 'bg-yellow-100 text-yellow-700 hover:bg-yellow-200'
                        }`}
                      >
                        {topic.is_published ? (
                          <span className="flex items-center gap-1">
                            <CheckCircle className="w-3 h-3" /> Live
                          </span>
                        ) : (
                          <span className="flex items-center gap-1">
                            <AlertCircle className="w-3 h-3" /> Draft
                          </span>
                        )}
                      </button>
                    </div>

                    <p className="text-sm text-gray-600 mb-4 line-clamp-2">{topic.description}</p>

                    <div className="flex flex-wrap gap-2 mb-4">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${difficultyBadge(topic.difficulty)}`}>
                        {topic.difficulty}
                      </span>
                      <span className="px-2 py-1 text-xs font-medium rounded-full bg-blue-100 text-blue-700 flex items-center gap-1">
                        <Clock className="w-3 h-3" /> {topic.estimated_days} days
                      </span>
                      <span className="px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-700">
                        {topic.ritual_items?.[0]?.count || 0} rituals
                      </span>
                      <span className="px-2 py-1 text-xs font-medium rounded-full bg-purple-100 text-purple-700">
                        {topic.ritual_affirmations?.[0]?.count || 0} affirmations
                      </span>
                    </div>

                    <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                      <div className="flex items-center gap-1 text-sm text-gray-500">
                        <Users className="w-4 h-4" />
                        <span>{topic.subscriber_count} subscribers</span>
                      </div>
                      <div className="flex gap-2">
                        <button
                          onClick={() => toggleFeatured(topic.id, topic.is_featured)}
                          className={`p-2 rounded hover:bg-gray-100 ${topic.is_featured ? 'text-yellow-500' : 'text-gray-400'}`}
                          title={topic.is_featured ? 'Remove from featured' : 'Add to featured'}
                        >
                          <Star className={`w-4 h-4 ${topic.is_featured ? 'fill-yellow-500' : ''}`} />
                        </button>
                        <Link
                          href={`/rituals/${topic.id}`}
                          className="text-sm font-medium text-ocean-600 hover:text-ocean-700"
                        >
                          Edit →
                        </Link>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="mt-6 text-sm text-gray-600">
        Showing {filteredTopics.length} of {topics.length} topics
      </div>
    </div>
  )
}
