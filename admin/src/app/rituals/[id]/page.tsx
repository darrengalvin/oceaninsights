'use client'

import { useEffect, useState } from 'react'
import { useRouter, useParams } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Save, Trash2, Plus, X, GripVertical } from 'lucide-react'

interface Category {
  id: string
  slug: string
  name: string
  icon: string
  color: string
}

interface RitualItem {
  id?: string
  title: string
  description: string
  why_it_helps: string
  how_to: string
  duration_minutes: number
  time_of_day: string
  frequency: string
  display_order: number
  is_core: boolean
  is_active: boolean
}

interface Affirmation {
  id?: string
  text: string
  attribution?: string
  display_order: number
}

interface Milestone {
  id?: string
  title: string
  description: string
  day_threshold: number
  celebration_message: string
  icon: string
}

interface Tip {
  id?: string
  title: string
  content: string
  day_to_show?: number
  icon: string
}

interface Topic {
  id: string
  slug: string
  name: string
  tagline: string
  description: string
  icon: string
  category_id: string
  difficulty: string
  estimated_days: number
  is_featured: boolean
  is_published: boolean
  category?: Category
  items: RitualItem[]
  affirmations: Affirmation[]
  milestones: Milestone[]
  tips: Tip[]
}

export default function EditRitualPage() {
  const router = useRouter()
  const params = useParams()
  const topicId = params.id as string

  const [categories, setCategories] = useState<Category[]>([])
  const [topic, setTopic] = useState<Topic | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [activeTab, setActiveTab] = useState<'details' | 'rituals' | 'affirmations' | 'milestones' | 'tips'>('details')

  // Form state
  const [name, setName] = useState('')
  const [slug, setSlug] = useState('')
  const [tagline, setTagline] = useState('')
  const [description, setDescription] = useState('')
  const [categoryId, setCategoryId] = useState('')
  const [difficulty, setDifficulty] = useState('beginner')
  const [estimatedDays, setEstimatedDays] = useState(21)
  const [isFeatured, setIsFeatured] = useState(false)
  const [isPublished, setIsPublished] = useState(false)
  const [items, setItems] = useState<RitualItem[]>([])
  const [affirmations, setAffirmations] = useState<Affirmation[]>([])
  const [milestones, setMilestones] = useState<Milestone[]>([])
  const [tips, setTips] = useState<Tip[]>([])

  useEffect(() => {
    fetchData()
  }, [topicId])

  const fetchData = async () => {
    try {
      const [topicRes, categoriesRes] = await Promise.all([
        fetch(`/api/rituals/topics/${topicId}`),
        fetch('/api/rituals/categories')
      ])

      const topicData = await topicRes.json()
      const categoriesData = await categoriesRes.json()

      setTopic(topicData)
      setCategories(categoriesData)

      // Set form state
      setName(topicData.name)
      setSlug(topicData.slug)
      setTagline(topicData.tagline || '')
      setDescription(topicData.description || '')
      setCategoryId(topicData.category_id)
      setDifficulty(topicData.difficulty)
      setEstimatedDays(topicData.estimated_days)
      setIsFeatured(topicData.is_featured)
      setIsPublished(topicData.is_published)
      setItems(topicData.items || [])
      setAffirmations(topicData.affirmations || [])
      setMilestones(topicData.milestones || [])
      setTips(topicData.tips || [])
    } catch (error) {
      console.error('Failed to fetch data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      const res = await fetch(`/api/rituals/topics/${topicId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name,
          slug,
          tagline,
          description,
          category_id: categoryId,
          difficulty,
          estimated_days: estimatedDays,
          is_featured: isFeatured,
          is_published: isPublished,
          items,
          affirmations,
          milestones,
          tips
        })
      })

      if (!res.ok) throw new Error('Failed to save')

      alert('Saved successfully!')
      fetchData()
    } catch (error) {
      console.error('Save error:', error)
      alert('Failed to save changes')
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this topic? This cannot be undone.')) {
      return
    }

    try {
      const res = await fetch(`/api/rituals/topics/${topicId}`, {
        method: 'DELETE'
      })

      if (!res.ok) throw new Error('Failed to delete')

      router.push('/rituals')
    } catch (error) {
      console.error('Delete error:', error)
      alert('Failed to delete topic')
    }
  }

  // Item management
  const addItem = () => {
    setItems([...items, {
      title: '',
      description: '',
      why_it_helps: '',
      how_to: '',
      duration_minutes: 5,
      time_of_day: 'anytime',
      frequency: 'daily',
      display_order: items.length,
      is_core: true,
      is_active: true
    }])
  }

  const updateItem = (index: number, field: keyof RitualItem, value: any) => {
    const newItems = [...items]
    newItems[index] = { ...newItems[index], [field]: value }
    setItems(newItems)
  }

  const removeItem = (index: number) => {
    setItems(items.filter((_, i) => i !== index))
  }

  // Affirmation management
  const addAffirmation = () => {
    setAffirmations([...affirmations, {
      text: '',
      display_order: affirmations.length
    }])
  }

  const updateAffirmation = (index: number, field: keyof Affirmation, value: any) => {
    const newAffirmations = [...affirmations]
    newAffirmations[index] = { ...newAffirmations[index], [field]: value }
    setAffirmations(newAffirmations)
  }

  const removeAffirmation = (index: number) => {
    setAffirmations(affirmations.filter((_, i) => i !== index))
  }

  // Milestone management
  const addMilestone = () => {
    setMilestones([...milestones, {
      title: '',
      description: '',
      day_threshold: 7,
      celebration_message: '',
      icon: 'emoji_events'
    }])
  }

  const updateMilestone = (index: number, field: keyof Milestone, value: any) => {
    const newMilestones = [...milestones]
    newMilestones[index] = { ...newMilestones[index], [field]: value }
    setMilestones(newMilestones)
  }

  const removeMilestone = (index: number) => {
    setMilestones(milestones.filter((_, i) => i !== index))
  }

  // Tip management
  const addTip = () => {
    setTips([...tips, {
      title: '',
      content: '',
      icon: 'lightbulb_outline'
    }])
  }

  const updateTip = (index: number, field: keyof Tip, value: any) => {
    const newTips = [...tips]
    newTips[index] = { ...newTips[index], [field]: value }
    setTips(newTips)
  }

  const removeTip = (index: number) => {
    setTips(tips.filter((_, i) => i !== index))
  }

  if (loading) {
    return (
      <div className="p-6 max-w-5xl mx-auto">
        <p className="text-gray-500">Loading topic...</p>
      </div>
    )
  }

  if (!topic) {
    return (
      <div className="p-6 max-w-5xl mx-auto">
        <p className="text-red-500">Topic not found</p>
        <Link href="/rituals" className="text-ocean-600 hover:underline">Back to topics</Link>
      </div>
    )
  }

  return (
    <div className="p-6 max-w-5xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <Link href="/rituals" className="text-gray-500 hover:text-gray-700">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Edit: {topic.name}</h1>
            <p className="text-gray-500 text-sm">
              {items.length} rituals · {affirmations.length} affirmations
            </p>
          </div>
        </div>
        <div className="flex gap-3">
          <button
            onClick={handleDelete}
            className="flex items-center gap-2 px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
          >
            <Trash2 className="w-4 h-4" />
            Delete
          </button>
          <button
            onClick={handleSave}
            disabled={saving}
            className="flex items-center gap-2 bg-ocean-600 hover:bg-ocean-700 text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50"
          >
            <Save className="w-4 h-4" />
            {saving ? 'Saving...' : 'Save Changes'}
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200 mb-6">
        <nav className="flex gap-6">
          {[
            { key: 'details', label: 'Details' },
            { key: 'rituals', label: `Rituals (${items.length})` },
            { key: 'affirmations', label: `Affirmations (${affirmations.length})` },
            { key: 'milestones', label: `Milestones (${milestones.length})` },
            { key: 'tips', label: `Tips (${tips.length})` }
          ].map(tab => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`pb-3 px-1 border-b-2 font-medium text-sm transition-colors ${
                activeTab === tab.key
                  ? 'border-ocean-600 text-ocean-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>

      {/* Details Tab */}
      {activeTab === 'details' && (
        <div className="bg-white rounded-lg shadow p-6 space-y-6">
          <div className="grid md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Name</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Slug</label>
              <input
                type="text"
                value={slug}
                onChange={(e) => setSlug(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
              />
            </div>
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
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
            />
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
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
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="advanced">Advanced</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Estimated Days</label>
              <input
                type="number"
                value={estimatedDays}
                onChange={(e) => setEstimatedDays(parseInt(e.target.value) || 21)}
                min={1}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
              />
            </div>
          </div>

          <div className="flex gap-6">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={isFeatured}
                onChange={(e) => setIsFeatured(e.target.checked)}
                className="w-4 h-4 text-ocean-600 rounded focus:ring-ocean-500"
              />
              <span className="text-sm text-gray-700">Featured</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={isPublished}
                onChange={(e) => setIsPublished(e.target.checked)}
                className="w-4 h-4 text-ocean-600 rounded focus:ring-ocean-500"
              />
              <span className="text-sm text-gray-700">Published</span>
            </label>
          </div>
        </div>
      )}

      {/* Rituals Tab */}
      {activeTab === 'rituals' && (
        <div className="space-y-4">
          {items.map((item, index) => (
            <div key={index} className="bg-white rounded-lg shadow p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-2">
                  <GripVertical className="w-4 h-4 text-gray-400" />
                  <span className="text-sm font-medium text-gray-500">Ritual {index + 1}</span>
                  {item.is_core && (
                    <span className="px-2 py-0.5 text-xs font-medium bg-ocean-100 text-ocean-700 rounded-full">Core</span>
                  )}
                </div>
                <button
                  onClick={() => removeItem(index)}
                  className="text-gray-400 hover:text-red-500"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                  <input
                    type="text"
                    value={item.title}
                    onChange={(e) => updateItem(index, 'title', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    value={item.description}
                    onChange={(e) => updateItem(index, 'description', e.target.value)}
                    rows={2}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Why It Helps</label>
                  <textarea
                    value={item.why_it_helps}
                    onChange={(e) => updateItem(index, 'why_it_helps', e.target.value)}
                    rows={2}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">How To</label>
                  <textarea
                    value={item.how_to}
                    onChange={(e) => updateItem(index, 'how_to', e.target.value)}
                    rows={2}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Duration (min)</label>
                    <input
                      type="number"
                      value={item.duration_minutes}
                      onChange={(e) => updateItem(index, 'duration_minutes', parseInt(e.target.value) || 5)}
                      min={1}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Time of Day</label>
                    <select
                      value={item.time_of_day}
                      onChange={(e) => updateItem(index, 'time_of_day', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                    >
                      <option value="morning">Morning</option>
                      <option value="afternoon">Afternoon</option>
                      <option value="evening">Evening</option>
                      <option value="anytime">Anytime</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Frequency</label>
                    <select
                      value={item.frequency}
                      onChange={(e) => updateItem(index, 'frequency', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                    >
                      <option value="daily">Daily</option>
                      <option value="weekdays">Weekdays</option>
                      <option value="weekends">Weekends</option>
                      <option value="weekly">Weekly</option>
                      <option value="as_needed">As Needed</option>
                    </select>
                  </div>
                  <div className="flex items-end gap-4">
                    <label className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={item.is_core}
                        onChange={(e) => updateItem(index, 'is_core', e.target.checked)}
                        className="w-4 h-4 text-ocean-600 rounded focus:ring-ocean-500"
                      />
                      <span className="text-sm text-gray-700">Core</span>
                    </label>
                  </div>
                </div>
              </div>
            </div>
          ))}

          <button
            onClick={addItem}
            className="w-full py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-500 hover:border-ocean-400 hover:text-ocean-600 transition-colors flex items-center justify-center gap-2"
          >
            <Plus className="w-4 h-4" />
            Add Ritual
          </button>
        </div>
      )}

      {/* Affirmations Tab */}
      {activeTab === 'affirmations' && (
        <div className="space-y-4">
          {affirmations.map((affirmation, index) => (
            <div key={index} className="bg-white rounded-lg shadow p-4 flex items-start gap-4">
              <span className="text-sm font-medium text-gray-400 mt-2">{index + 1}.</span>
              <div className="flex-1">
                <input
                  type="text"
                  value={affirmation.text}
                  onChange={(e) => updateAffirmation(index, 'text', e.target.value)}
                  placeholder="Enter affirmation text..."
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                />
              </div>
              <button
                onClick={() => removeAffirmation(index)}
                className="text-gray-400 hover:text-red-500 mt-2"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
          ))}

          <button
            onClick={addAffirmation}
            className="w-full py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-500 hover:border-ocean-400 hover:text-ocean-600 transition-colors flex items-center justify-center gap-2"
          >
            <Plus className="w-4 h-4" />
            Add Affirmation
          </button>
        </div>
      )}

      {/* Milestones Tab */}
      {activeTab === 'milestones' && (
        <div className="space-y-4">
          {milestones.map((milestone, index) => (
            <div key={index} className="bg-white rounded-lg shadow p-6">
              <div className="flex items-start justify-between mb-4">
                <span className="text-sm font-medium text-gray-500">Milestone {index + 1}</span>
                <button
                  onClick={() => removeMilestone(index)}
                  className="text-gray-400 hover:text-red-500"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                  <input
                    type="text"
                    value={milestone.title}
                    onChange={(e) => updateMilestone(index, 'title', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Day Threshold</label>
                  <input
                    type="number"
                    value={milestone.day_threshold}
                    onChange={(e) => updateMilestone(index, 'day_threshold', parseInt(e.target.value) || 7)}
                    min={1}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>
              </div>

              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <input
                  type="text"
                  value={milestone.description}
                  onChange={(e) => updateMilestone(index, 'description', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                />
              </div>

              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">Celebration Message</label>
                <textarea
                  value={milestone.celebration_message}
                  onChange={(e) => updateMilestone(index, 'celebration_message', e.target.value)}
                  rows={2}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                />
              </div>
            </div>
          ))}

          <button
            onClick={addMilestone}
            className="w-full py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-500 hover:border-ocean-400 hover:text-ocean-600 transition-colors flex items-center justify-center gap-2"
          >
            <Plus className="w-4 h-4" />
            Add Milestone
          </button>
        </div>
      )}

      {/* Tips Tab */}
      {activeTab === 'tips' && (
        <div className="space-y-4">
          {tips.map((tip, index) => (
            <div key={index} className="bg-white rounded-lg shadow p-6">
              <div className="flex items-start justify-between mb-4">
                <span className="text-sm font-medium text-gray-500">Tip {index + 1}</span>
                <button
                  onClick={() => removeTip(index)}
                  className="text-gray-400 hover:text-red-500"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                  <input
                    type="text"
                    value={tip.title}
                    onChange={(e) => updateTip(index, 'title', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Show on Day (optional)</label>
                  <input
                    type="number"
                    value={tip.day_to_show || ''}
                    onChange={(e) => updateTip(index, 'day_to_show', e.target.value ? parseInt(e.target.value) : null)}
                    min={1}
                    placeholder="Random if empty"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                  />
                </div>
              </div>

              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">Content</label>
                <textarea
                  value={tip.content}
                  onChange={(e) => updateTip(index, 'content', e.target.value)}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500 focus:border-transparent"
                />
              </div>
            </div>
          ))}

          <button
            onClick={addTip}
            className="w-full py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-500 hover:border-ocean-400 hover:text-ocean-600 transition-colors flex items-center justify-center gap-2"
          >
            <Plus className="w-4 h-4" />
            Add Tip
          </button>
        </div>
      )}
    </div>
  )
}
