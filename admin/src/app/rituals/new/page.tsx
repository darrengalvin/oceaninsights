'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Save } from 'lucide-react'

interface Category {
  id: string
  slug: string
  name: string
  icon: string
  color: string
}

export default function NewRitualPage() {
  const router = useRouter()
  const [categories, setCategories] = useState<Category[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  // Form state
  const [name, setName] = useState('')
  const [tagline, setTagline] = useState('')
  const [description, setDescription] = useState('')
  const [categoryId, setCategoryId] = useState('')
  const [difficulty, setDifficulty] = useState('beginner')
  const [estimatedDays, setEstimatedDays] = useState(21)
  const [isFeatured, setIsFeatured] = useState(false)

  useEffect(() => {
    fetchCategories()
  }, [])

  const fetchCategories = async () => {
    try {
      const res = await fetch('/api/rituals/categories')
      const data = await res.json()
      setCategories(data)
      if (data.length > 0) {
        setCategoryId(data[0].id)
      }
    } catch (error) {
      console.error('Failed to fetch categories:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCreate = async () => {
    if (!name.trim()) {
      alert('Please enter a topic name')
      return
    }

    if (!categoryId) {
      alert('Please select a category')
      return
    }

    setSaving(true)
    try {
      const res = await fetch('/api/rituals/topics', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name,
          tagline,
          description,
          category_id: categoryId,
          difficulty,
          estimated_days: estimatedDays,
          is_featured: isFeatured,
          is_published: false
        })
      })

      if (!res.ok) throw new Error('Failed to create')

      const data = await res.json()
      router.push(`/rituals/${data.id}`)
    } catch (error) {
      console.error('Create error:', error)
      alert('Failed to create topic')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="p-6 max-w-3xl mx-auto">
        <p className="text-gray-500">Loading...</p>
      </div>
    )
  }

  return (
    <div className="p-6 max-w-3xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <Link href="/rituals" className="text-gray-500 hover:text-gray-700">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Create Ritual Topic</h1>
            <p className="text-gray-500 text-sm">Add a new ritual pack for users</p>
          </div>
        </div>
        <button
          onClick={handleCreate}
          disabled={saving}
          className="flex items-center gap-2 bg-ocean-600 hover:bg-ocean-700 text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50"
        >
          <Save className="w-4 h-4" />
          {saving ? 'Creating...' : 'Create Topic'}
        </button>
      </div>

      {/* Form */}
      <div className="bg-white rounded-lg shadow p-6 space-y-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Topic Name <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g., Finding Love, Better Sleep, Confidence Building"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Tagline</label>
          <input
            type="text"
            value={tagline}
            onChange={(e) => setTagline(e.target.value)}
            placeholder="A short motivational phrase..."
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
          />
          <p className="text-sm text-gray-500 mt-1">A brief, inspiring phrase that captures the essence</p>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={4}
            placeholder="Describe what this ritual pack helps users achieve..."
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
          />
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Category <span className="text-red-500">*</span>
            </label>
            <select
              value={categoryId}
              onChange={(e) => setCategoryId(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
            >
              {categories.map(cat => (
                <option key={cat.id} value={cat.id}>{cat.name}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Difficulty</label>
            <select
              value={difficulty}
              onChange={(e) => setDifficulty(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
            >
              <option value="beginner">Beginner - Easy to start</option>
              <option value="intermediate">Intermediate - Some commitment</option>
              <option value="advanced">Advanced - Significant effort</option>
            </select>
          </div>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Estimated Duration (days)</label>
            <input
              type="number"
              value={estimatedDays}
              onChange={(e) => setEstimatedDays(parseInt(e.target.value) || 21)}
              min={1}
              max={365}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
            />
            <p className="text-sm text-gray-500 mt-1">How many days should users follow this program?</p>
          </div>

          <div className="flex items-center pt-8">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={isFeatured}
                onChange={(e) => setIsFeatured(e.target.checked)}
                className="w-4 h-4 text-ocean-600 rounded focus:ring-ocean-500"
              />
              <span className="text-sm text-gray-700">Featured topic</span>
            </label>
            <p className="text-sm text-gray-500 ml-2">(Shows prominently in the app)</p>
          </div>
        </div>

        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <p className="text-sm text-blue-800">
            <strong>Next steps:</strong> After creating this topic, you&apos;ll be able to add:
          </p>
          <ul className="text-sm text-blue-700 mt-2 ml-4 list-disc">
            <li>Daily rituals and practices</li>
            <li>Affirmations specific to this topic</li>
            <li>Milestones and achievements</li>
            <li>Tips and insights</li>
          </ul>
        </div>
      </div>
    </div>
  )
}
