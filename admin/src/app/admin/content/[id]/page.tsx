'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Save, Eye, Plus, X, Trash2 } from 'lucide-react'

interface ContentItem {
  id: string
  slug: string
  domain_id: string
  pillar: string
  label: string
  microcopy: string | null
  audience: string
  sensitivity: string
  disclosure_level: number
  keywords: string[]
  is_published: boolean
  domains: {
    id: string
    name: string
  }
  content_details: {
      understand_title: string | null
      understand_body: string | null
      understand_examples: string | null
      understand_insights: string[]
      reflect_prompts: string[]
      grow_title: string | null
      grow_steps: Array<{ action: string; detail: string }>
      grow_obstacles: string | null
      support_intro: string | null
      support_resources: Array<{ name: string; description: string; contact?: string }>
      when_to_seek_help: string | null
      affirmation: string | null
  }
}

interface Domain {
  id: string
  slug: string
  name: string
}

export default function EditContentPage({ params }: { params: { id: string } }) {
  const router = useRouter()
  const [domains, setDomains] = useState<Domain[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [content, setContent] = useState<ContentItem | null>(null)
  
  // Form state
  const [formData, setFormData] = useState({
    domain_id: '',
    pillar: 'understand',
    label: '',
    microcopy: '',
    audience: 'any',
    sensitivity: 'normal',
    disclosure_level: 1,
    keywords: [] as string[],
    is_published: false,
    understand_title: '',
    understand_body: '',
    understand_examples: '',
    understand_insights: [] as string[],
    reflect_prompts: [] as string[],
    grow_title: '',
    grow_steps: [] as Array<{ action: string; detail: string }>,
    grow_obstacles: '',
    support_intro: '',
    support_resources: [] as Array<{ name: string; description: string; contact?: string }>,
    when_to_seek_help: '',
    affirmation: '',
  })

  const [newKeyword, setNewKeyword] = useState('')
  const [newInsight, setNewInsight] = useState('')
  const [newPrompt, setNewPrompt] = useState('')
  const [newStep, setNewStep] = useState({ action: '', detail: '' })

  useEffect(() => {
    fetchDomains()
    fetchContent()
  }, [params.id])

  const fetchDomains = async () => {
    try {
      const res = await fetch('/api/domains')
      const data = await res.json()
      setDomains(data)
    } catch (error) {
      console.error('Failed to fetch domains:', error)
    }
  }

  const fetchContent = async () => {
    try {
      setLoading(true)
      const res = await fetch(`/api/content/${params.id}`)
      if (!res.ok) throw new Error('Failed to fetch content')
      
      const data: ContentItem = await res.json()
      setContent(data)
      
      const details = data.content_details || {}
      
      setFormData({
        domain_id: data.domain_id,
        pillar: data.pillar,
        label: data.label,
        microcopy: data.microcopy || '',
        audience: data.audience,
        sensitivity: data.sensitivity,
        disclosure_level: data.disclosure_level,
        keywords: data.keywords || [],
        is_published: data.is_published,
        understand_title: details.understand_title || '',
        understand_body: details.understand_body || '',
        understand_examples: details.understand_examples || '',
        understand_insights: details.understand_insights || [],
        reflect_prompts: details.reflect_prompts || [],
        grow_title: details.grow_title || '',
        grow_steps: details.grow_steps || [],
        grow_obstacles: details.grow_obstacles || '',
        support_intro: details.support_intro || '',
        support_resources: details.support_resources || [],
        when_to_seek_help: details.when_to_seek_help || '',
        affirmation: details.affirmation || '',
      })
    } catch (err) {
      setError('Failed to load content')
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent, publish = false) => {
    e.preventDefault()
    setError('')
    setSaving(true)

    try {
      const res = await fetch(`/api/content/${params.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...formData,
          is_published: publish,
        }),
      })

      if (!res.ok) {
        throw new Error('Failed to save content')
      }

      router.push('/content')
    } catch (err) {
      setError('Failed to save content. Please try again.')
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this content? This cannot be undone.')) return
    
    try {
      await fetch(`/api/content/${params.id}`, { method: 'DELETE' })
      router.push('/content')
    } catch (error) {
      setError('Failed to delete content')
    }
  }

  const addKeyword = () => {
    if (newKeyword.trim()) {
      setFormData(prev => ({
        ...prev,
        keywords: [...prev.keywords, newKeyword.trim().toLowerCase()],
      }))
      setNewKeyword('')
    }
  }

  const removeKeyword = (index: number) => {
    setFormData(prev => ({
      ...prev,
      keywords: prev.keywords.filter((_, i) => i !== index),
    }))
  }

  const addInsight = () => {
    if (newInsight.trim()) {
      setFormData(prev => ({
        ...prev,
        understand_insights: [...prev.understand_insights, newInsight.trim()],
      }))
      setNewInsight('')
    }
  }

  const addPrompt = () => {
    if (newPrompt.trim()) {
      setFormData(prev => ({
        ...prev,
        reflect_prompts: [...prev.reflect_prompts, newPrompt.trim()],
      }))
      setNewPrompt('')
    }
  }

  const addStep = () => {
    if (newStep.action.trim()) {
      setFormData(prev => ({
        ...prev,
        grow_steps: [...prev.grow_steps, newStep],
      }))
      setNewStep({ action: '', detail: '' })
    }
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
      <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-6 py-4">
          <div className="flex items-center gap-4">
            <Link href="/admin/content" className="p-2 hover:bg-gray-100 rounded-lg">
              <ArrowLeft className="w-5 h-5 text-gray-600" />
            </Link>
            <div className="flex-1">
              <h1 className="text-xl font-bold text-gray-900">Edit Content</h1>
              <p className="text-sm text-gray-500">{content?.domains?.name}</p>
            </div>
            <button
              onClick={handleDelete}
              className="flex items-center gap-2 px-4 py-2 text-sm text-red-600 border border-red-200 rounded-lg hover:bg-red-50"
            >
              <Trash2 className="w-4 h-4" />
              Delete
            </button>
            <button
              onClick={(e) => handleSubmit(e, false)}
              disabled={saving}
              className="flex items-center gap-2 px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50"
            >
              <Save className="w-4 h-4" />
              Save Draft
            </button>
            <button
              onClick={(e) => handleSubmit(e, true)}
              disabled={saving}
              className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 rounded-lg hover:bg-ocean-700 disabled:opacity-50"
            >
              <Eye className="w-4 h-4" />
              Publish
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-6 py-8">
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg">
            {error}
          </div>
        )}

        <form className="space-y-8">
          {/* Basic Info */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h2>
            
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Domain</label>
                <select
                  value={formData.domain_id}
                  onChange={(e) => setFormData(prev => ({ ...prev, domain_id: e.target.value }))}
                  className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                >
                  {domains.map(domain => (
                    <option key={domain.id} value={domain.id}>{domain.name}</option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Pillar</label>
                <select
                  value={formData.pillar}
                  onChange={(e) => setFormData(prev => ({ ...prev, pillar: e.target.value }))}
                  className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                >
                  <option value="understand">Understand</option>
                  <option value="reflect">Reflect</option>
                  <option value="grow">Grow</option>
                  <option value="support">Support</option>
                </select>
              </div>
            </div>

            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Label</label>
              <input
                type="text"
                value={formData.label}
                onChange={(e) => setFormData(prev => ({ ...prev, label: e.target.value }))}
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Microcopy</label>
              <textarea
                value={formData.microcopy}
                onChange={(e) => setFormData(prev => ({ ...prev, microcopy: e.target.value }))}
                rows={2}
                maxLength={240}
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
              <p className="text-xs text-gray-400 mt-1">{formData.microcopy.length}/240</p>
            </div>

            <div className="grid grid-cols-3 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Audience</label>
                <select
                  value={formData.audience}
                  onChange={(e) => setFormData(prev => ({ ...prev, audience: e.target.value }))}
                  className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                >
                  <option value="any">Anyone</option>
                  <option value="service_member">Service Members</option>
                  <option value="veteran">Veterans</option>
                  <option value="partner_family">Partners/Family</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Sensitivity</label>
                <select
                  value={formData.sensitivity}
                  onChange={(e) => setFormData(prev => ({ ...prev, sensitivity: e.target.value }))}
                  className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                >
                  <option value="normal">Normal</option>
                  <option value="sensitive">Sensitive</option>
                  <option value="urgent">Urgent</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Disclosure Level</label>
                <select
                  value={formData.disclosure_level}
                  onChange={(e) => setFormData(prev => ({ ...prev, disclosure_level: parseInt(e.target.value) }))}
                  className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                >
                  <option value={1}>1 - General</option>
                  <option value={2}>2 - Personal</option>
                  <option value={3}>3 - Sensitive</option>
                </select>
              </div>
            </div>

            {/* Keywords */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Keywords</label>
              <div className="flex gap-2 mb-2">
                <input
                  type="text"
                  value={newKeyword}
                  onChange={(e) => setNewKeyword(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addKeyword())}
                  placeholder="Add keyword..."
                  className="flex-1 px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                />
                <button
                  type="button"
                  onClick={addKeyword}
                  className="px-4 py-2 text-ocean-600 border border-ocean-200 rounded-lg hover:bg-ocean-50"
                >
                  <Plus className="w-4 h-4" />
                </button>
              </div>
              <div className="flex flex-wrap gap-2">
                {formData.keywords.map((keyword, i) => (
                  <span key={i} className="inline-flex items-center gap-1 px-2 py-1 bg-gray-100 rounded-full text-sm">
                    {keyword}
                    <button type="button" onClick={() => removeKeyword(i)} className="text-gray-400 hover:text-gray-600">
                      <X className="w-3 h-3" />
                    </button>
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Understand Section */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              <span className="inline-flex items-center gap-2">
                <span className="w-3 h-3 bg-blue-500 rounded-full" />
                Understand Content
              </span>
            </h2>
            
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
              <input
                type="text"
                value={formData.understand_title}
                onChange={(e) => setFormData(prev => ({ ...prev, understand_title: e.target.value }))}
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Body</label>
              <textarea
                value={formData.understand_body}
                onChange={(e) => setFormData(prev => ({ ...prev, understand_body: e.target.value }))}
                rows={6}
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Real-World Examples</label>
              <textarea
                value={formData.understand_examples}
                onChange={(e) => setFormData(prev => ({ ...prev, understand_examples: e.target.value }))}
                placeholder="Concrete examples people can relate to. Use military context when appropriate."
                rows={3}
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Key Insights</label>
              <div className="flex gap-2 mb-2">
                <input
                  type="text"
                  value={newInsight}
                  onChange={(e) => setNewInsight(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addInsight())}
                  placeholder="Add an insight..."
                  className="flex-1 px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                />
                <button type="button" onClick={addInsight} className="px-4 py-2 text-ocean-600 border border-ocean-200 rounded-lg hover:bg-ocean-50">
                  <Plus className="w-4 h-4" />
                </button>
              </div>
              <ul className="space-y-1">
                {formData.understand_insights.map((insight, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm text-gray-600">
                    <span className="mt-1.5 w-1.5 h-1.5 bg-blue-400 rounded-full flex-shrink-0" />
                    {insight}
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {/* Reflect Section */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              <span className="inline-flex items-center gap-2">
                <span className="w-3 h-3 bg-purple-500 rounded-full" />
                Reflect Prompts
              </span>
            </h2>
            
            <div className="flex gap-2 mb-2">
              <input
                type="text"
                value={newPrompt}
                onChange={(e) => setNewPrompt(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addPrompt())}
                placeholder="Add a reflection question..."
                className="flex-1 px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
              <button type="button" onClick={addPrompt} className="px-4 py-2 text-ocean-600 border border-ocean-200 rounded-lg hover:bg-ocean-50">
                <Plus className="w-4 h-4" />
              </button>
            </div>
            <ul className="space-y-2">
              {formData.reflect_prompts.map((prompt, i) => (
                <li key={i} className="text-sm text-gray-600 italic">"{prompt}"</li>
              ))}
            </ul>
          </div>

          {/* Grow Section */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              <span className="inline-flex items-center gap-2">
                <span className="w-3 h-3 bg-green-500 rounded-full" />
                Grow Steps
              </span>
            </h2>
            
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Section Title</label>
              <input
                type="text"
                value={formData.grow_title}
                onChange={(e) => setFormData(prev => ({ ...prev, grow_title: e.target.value }))}
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>

            <div className="space-y-2 mb-4">
              <input
                type="text"
                value={newStep.action}
                onChange={(e) => setNewStep(prev => ({ ...prev, action: e.target.value }))}
                placeholder="Action (e.g., Start with small promises)"
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
              <div className="flex gap-2">
                <textarea
                  value={newStep.detail}
                  onChange={(e) => setNewStep(prev => ({ ...prev, detail: e.target.value }))}
                  placeholder="Detail (optional)"
                  rows={2}
                  className="flex-1 px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                />
                <button type="button" onClick={addStep} className="px-4 py-2 text-ocean-600 border border-ocean-200 rounded-lg hover:bg-ocean-50 self-start">
                  <Plus className="w-4 h-4" />
                </button>
              </div>
            </div>

            <ul className="space-y-3 mb-4">
              {formData.grow_steps.map((step, i) => (
                <li key={i} className="p-3 bg-green-50 rounded-lg">
                  <p className="font-medium text-gray-900">{step.action}</p>
                  {step.detail && <p className="text-sm text-gray-600 mt-1">{step.detail}</p>}
                </li>
              ))}
            </ul>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Common Obstacles</label>
              <textarea
                value={formData.grow_obstacles}
                onChange={(e) => setFormData(prev => ({ ...prev, grow_obstacles: e.target.value }))}
                placeholder="What challenges might people face? Be honest but frame hopefully."
                rows={3}
                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
              />
            </div>
          </div>

          {/* When to Seek Help */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              <span className="inline-flex items-center gap-2">
                <span className="w-3 h-3 bg-red-500 rounded-full" />
                When to Seek Help (optional, for sensitive items)
              </span>
            </h2>
            <textarea
              value={formData.when_to_seek_help}
              onChange={(e) => setFormData(prev => ({ ...prev, when_to_seek_help: e.target.value }))}
              placeholder="When is professional help needed? Leave empty if not applicable."
              rows={3}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
            />
          </div>

          {/* Affirmation */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Closing Affirmation</h2>
            <input
              type="text"
              value={formData.affirmation}
              onChange={(e) => setFormData(prev => ({ ...prev, affirmation: e.target.value }))}
              placeholder="e.g., You deserve relationships where you feel safe."
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
            />
          </div>
        </form>
      </div>
    </div>
  )
}

