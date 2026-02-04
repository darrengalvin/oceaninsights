'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Save } from 'lucide-react'

const AUDIENCE_OPTIONS = [
  { value: 'any', label: 'Everyone' },
  { value: 'service_member', label: 'Service Members' },
  { value: 'veteran', label: 'Veterans' },
  { value: 'partner_family', label: 'Partners & Family' }
]

export default function NewJourneyPage() {
  const router = useRouter()
  const [saving, setSaving] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    slug: '',
    description: '',
    audience: 'any'
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)

    try {
      const res = await fetch('/api/journeys', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...formData,
          item_sequence: [],
          is_published: false
        })
      })

      if (!res.ok) throw new Error('Failed to create journey')

      router.push('/journeys')
    } catch (error) {
      console.error('Failed to create journey:', error)
      alert('Failed to create journey')
    } finally {
      setSaving(false)
    }
  }

  const generateSlug = (title: string) => {
    return title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '')
  }

  const handleTitleChange = (title: string) => {
    setFormData({
      ...formData,
      title,
      slug: generateSlug(title)
    })
  }

  return (
    <div className="flex-1 p-8">
      <div className="max-w-3xl mx-auto">
        <div className="mb-6">
          <Link 
            href="/journeys"
            className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Journeys
          </Link>
          <h1 className="text-2xl font-bold text-gray-900">Create New Journey</h1>
          <p className="text-gray-500 mt-1">Design a curated content pathway</p>
        </div>

        <form onSubmit={handleSubmit} className="bg-white rounded-lg border border-gray-200 p-6 space-y-6">
          <div>
            <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
              Journey Title *
            </label>
            <input
              type="text"
              id="title"
              required
              value={formData.title}
              onChange={(e) => handleTitleChange(e.target.value)}
              placeholder="e.g. 7-Day Sleep Recovery"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500"
            />
          </div>

          <div>
            <label htmlFor="slug" className="block text-sm font-medium text-gray-700 mb-2">
              URL Slug *
            </label>
            <input
              type="text"
              id="slug"
              required
              value={formData.slug}
              onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
              placeholder="7-day-sleep-recovery"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 font-mono text-sm"
            />
            <p className="text-xs text-gray-500 mt-1">Auto-generated from title, but you can customize it</p>
          </div>

          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
              Description
            </label>
            <textarea
              id="description"
              rows={4}
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="A guided pathway to help you..."
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500"
            />
          </div>

          <div>
            <label htmlFor="audience" className="block text-sm font-medium text-gray-700 mb-2">
              Target Audience
            </label>
            <select
              id="audience"
              value={formData.audience}
              onChange={(e) => setFormData({ ...formData, audience: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500"
            >
              {AUDIENCE_OPTIONS.map(option => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>

          <div className="flex gap-3 pt-4">
            <button
              type="submit"
              disabled={saving}
              className="flex items-center gap-2 bg-ocean-600 text-white px-4 py-2 rounded-lg hover:bg-ocean-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Save className="w-4 h-4" />
              {saving ? 'Creating...' : 'Create Journey'}
            </button>
            <Link
              href="/journeys"
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </Link>
          </div>

          <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 mt-6">
            <p className="text-sm text-amber-800">
              <strong>Note:</strong> After creating the journey, you'll be able to add and order content items in the edit view.
            </p>
          </div>
        </form>
      </div>
    </div>
  )
}



