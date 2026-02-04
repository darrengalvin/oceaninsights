'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, Save } from 'lucide-react'
import Link from 'next/link'

export default function NewLearnArticlePage() {
  const router = useRouter()
  const [saving, setSaving] = useState(false)
  const [data, setData] = useState({
    slug: '',
    title: '',
    summary: '',
    category: 'brain_science' as 'brain_science' | 'psychology' | 'life_situation',
    read_time_minutes: 5,
    audience: 'any',
    sections: [],
    key_takeaways: []
  })

  const handleCreate = async () => {
    if (!data.slug || !data.title || !data.summary) {
      alert('Please fill in slug, title, and summary')
      return
    }

    setSaving(true)
    try {
      const res = await fetch('/api/learn', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      })
      
      const article = await res.json()
      router.push(`/learn/${article.id}`)
    } catch (error) {
      console.error('Failed to create:', error)
      alert('Failed to create article')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-5xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Link href="/learn" className="p-2 hover:bg-gray-100 rounded-lg">
                <ArrowLeft className="w-5 h-5" />
              </Link>
              <div>
                <h1 className="text-xl font-bold text-gray-900">New Article</h1>
                <p className="text-sm text-gray-500">Create a new Learn article</p>
              </div>
            </div>
            <button
              onClick={handleCreate}
              disabled={saving}
              className="px-4 py-2 bg-ocean-600 text-white rounded-lg hover:bg-ocean-700 transition-colors disabled:opacity-50"
            >
              <Save className="w-4 h-4 inline mr-2" />
              Create Article
            </button>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-5xl mx-auto px-6 py-8">
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Category *</label>
              <select
                value={data.category}
                onChange={(e) => setData({ ...data, category: e.target.value as any })}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              >
                <option value="brain_science">Brain Science</option>
                <option value="psychology">Psychology</option>
                <option value="life_situation">Life Situations</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Slug * (URL-friendly)</label>
              <input
                type="text"
                value={data.slug}
                onChange={(e) => setData({ ...data, slug: e.target.value.toLowerCase().replace(/\s+/g, '-') })}
                placeholder="e.g., understanding-stress"
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title *</label>
              <input
                type="text"
                value={data.title}
                onChange={(e) => setData({ ...data, title: e.target.value })}
                placeholder="e.g., Understanding Stress and Your Brain"
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Summary *</label>
              <textarea
                value={data.summary}
                onChange={(e) => setData({ ...data, summary: e.target.value })}
                rows={3}
                placeholder="A brief overview of what this article covers..."
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Read Time (minutes)</label>
                <input
                  type="number"
                  value={data.read_time_minutes}
                  onChange={(e) => setData({ ...data, read_time_minutes: parseInt(e.target.value) })}
                  className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Audience</label>
                <input
                  type="text"
                  value={data.audience}
                  onChange={(e) => setData({ ...data, audience: e.target.value })}
                  placeholder="e.g., any, young-adult, professional"
                  className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                />
              </div>
            </div>
          </div>

          <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-sm text-blue-800">
              💡 <strong>Tip:</strong> After creating the article, you'll be able to add sections, content, and key takeaways on the edit page.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}



