'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, Save, Eye, Trash2, Plus, X } from 'lucide-react'
import Link from 'next/link'

interface ArticleSection {
  heading: string | null
  content: string
  tip: string | null
}

interface ArticleData {
  id: string
  slug: string
  title: string
  summary: string
  category: 'brain_science' | 'psychology' | 'life_situation'
  read_time_minutes: number
  age_brackets: string[] | null
  audience: string
  is_published: boolean
  content: {
    sections: ArticleSection[]
    key_takeaways: string[]
  }
}

export default function EditLearnArticlePage({ params }: { params: { id: string } }) {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [data, setData] = useState<ArticleData | null>(null)

  useEffect(() => {
    fetchArticle()
  }, [params.id])

  const fetchArticle = async () => {
    try {
      const res = await fetch(`/api/learn/${params.id}`)
      const articleData = await res.json()
      setData(articleData)
    } catch (error) {
      console.error('Failed to fetch article:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async (publish: boolean = false) => {
    if (!data) return
    
    setSaving(true)
    try {
      await fetch(`/api/learn/${params.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...data,
          sections: data.content.sections,
          key_takeaways: data.content.key_takeaways,
          is_published: publish ? true : data.is_published
        })
      })
      
      if (publish) {
        router.push('/learn')
      } else {
        alert('Saved successfully!')
      }
    } catch (error) {
      console.error('Failed to save:', error)
      alert('Failed to save')
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this article?')) return
    
    try {
      await fetch(`/api/learn/${params.id}`, { method: 'DELETE' })
      router.push('/learn')
    } catch (error) {
      console.error('Failed to delete:', error)
    }
  }

  const addSection = () => {
    if (!data) return
    setData({
      ...data,
      content: {
        ...data.content,
        sections: [
          ...data.content.sections,
          { heading: '', content: '', tip: null }
        ]
      }
    })
  }

  const removeSection = (index: number) => {
    if (!data) return
    setData({
      ...data,
      content: {
        ...data.content,
        sections: data.content.sections.filter((_, i) => i !== index)
      }
    })
  }

  const updateSection = (index: number, field: keyof ArticleSection, value: string | null) => {
    if (!data) return
    const newSections = [...data.content.sections]
    newSections[index] = { ...newSections[index], [field]: value }
    setData({
      ...data,
      content: {
        ...data.content,
        sections: newSections
      }
    })
  }

  const addTakeaway = () => {
    if (!data) return
    setData({
      ...data,
      content: {
        ...data.content,
        key_takeaways: [...data.content.key_takeaways, '']
      }
    })
  }

  const removeTakeaway = (index: number) => {
    if (!data) return
    setData({
      ...data,
      content: {
        ...data.content,
        key_takeaways: data.content.key_takeaways.filter((_, i) => i !== index)
      }
    })
  }

  const updateTakeaway = (index: number, value: string) => {
    if (!data) return
    const newTakeaways = [...data.content.key_takeaways]
    newTakeaways[index] = value
    setData({
      ...data,
      content: {
        ...data.content,
        key_takeaways: newTakeaways
      }
    })
  }

  if (loading || !data) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="w-8 h-8 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-5xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Link href="/learn" className="p-2 hover:bg-gray-100 rounded-lg">
                <ArrowLeft className="w-5 h-5" />
              </Link>
              <div>
                <h1 className="text-xl font-bold text-gray-900">{data.title || 'Edit Article'}</h1>
                <p className="text-sm text-gray-500">Learn Article</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={handleDelete}
                className="px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
              >
                <Trash2 className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleSave(false)}
                disabled={saving}
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors disabled:opacity-50"
              >
                <Save className="w-4 h-4 inline mr-2" />
                Save Draft
              </button>
              <button
                onClick={() => handleSave(true)}
                disabled={saving}
                className="px-4 py-2 bg-ocean-600 text-white rounded-lg hover:bg-ocean-700 transition-colors disabled:opacity-50"
              >
                <Eye className="w-4 h-4 inline mr-2" />
                Publish
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-5xl mx-auto px-6 py-8 space-y-6">
        {/* Basic Information */}
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
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
              <label className="block text-sm font-medium text-gray-700 mb-1">Slug</label>
              <input
                type="text"
                value={data.slug}
                onChange={(e) => setData({ ...data, slug: e.target.value })}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
              <input
                type="text"
                value={data.title}
                onChange={(e) => setData({ ...data, title: e.target.value })}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Summary</label>
              <textarea
                value={data.summary}
                onChange={(e) => setData({ ...data, summary: e.target.value })}
                rows={3}
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
                  className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Sections */}
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Content Sections</h2>
            <button
              onClick={addSection}
              className="flex items-center gap-2 px-3 py-1.5 text-sm bg-ocean-50 text-ocean-600 rounded-lg hover:bg-ocean-100"
            >
              <Plus className="w-4 h-4" />
              Add Section
            </button>
          </div>

          <div className="space-y-6">
            {data.content.sections.map((section, index) => (
              <div key={index} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-medium text-gray-500">Section {index + 1}</span>
                  <button
                    onClick={() => removeSection(index)}
                    className="p-1 text-red-600 hover:bg-red-50 rounded"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>

                <div className="space-y-3">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Heading (optional)</label>
                    <input
                      type="text"
                      value={section.heading || ''}
                      onChange={(e) => updateSection(index, 'heading', e.target.value || null)}
                      placeholder="Leave empty for no heading"
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Content</label>
                    <textarea
                      value={section.content}
                      onChange={(e) => updateSection(index, 'content', e.target.value)}
                      rows={5}
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Tip (optional)</label>
                    <textarea
                      value={section.tip || ''}
                      onChange={(e) => updateSection(index, 'tip', e.target.value || null)}
                      rows={2}
                      placeholder="Leave empty for no tip"
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Key Takeaways */}
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Key Takeaways</h2>
            <button
              onClick={addTakeaway}
              className="flex items-center gap-2 px-3 py-1.5 text-sm bg-ocean-50 text-ocean-600 rounded-lg hover:bg-ocean-100"
            >
              <Plus className="w-4 h-4" />
              Add Takeaway
            </button>
          </div>

          <div className="space-y-3">
            {data.content.key_takeaways.map((takeaway, index) => (
              <div key={index} className="flex items-start gap-2">
                <input
                  type="text"
                  value={takeaway}
                  onChange={(e) => updateTakeaway(index, e.target.value)}
                  placeholder="Enter a key takeaway..."
                  className="flex-1 px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                />
                <button
                  onClick={() => removeTakeaway(index)}
                  className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

