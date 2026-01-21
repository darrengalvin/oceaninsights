'use client'

import { useEffect, useState } from 'react'
import { useRouter, useParams } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Save, Trash2, Plus, X } from 'lucide-react'

interface PerspectiveShift {
  perspective: string
  interpretation: string
}

interface ScenarioOption {
  id?: string
  text: string
  tags: string[]
  immediate_outcome: string
  longterm_outcome: string
  risk_level: 'low' | 'medium' | 'high'
  perspective_shifts: PerspectiveShift[]
}

interface Scenario {
  id: string
  title: string
  situation: string
  context: string
  difficulty: number
  tags: string[]
  published: boolean
  content_pack_id?: string
  options: ScenarioOption[]
}

export default function EditScenarioPage() {
  const router = useRouter()
  const params = useParams()
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [scenario, setScenario] = useState<Scenario | null>(null)

  useEffect(() => {
    if (params.id) {
      fetchScenario(params.id as string)
    }
  }, [params.id])

  const fetchScenario = async (id: string) => {
    try {
      const res = await fetch(`/api/scenarios/${id}`)
      const data = await res.json()
      setScenario(data)
    } catch (error) {
      console.error('Failed to fetch scenario:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    if (!scenario) return
    setSaving(true)

    try {
      const res = await fetch(`/api/scenarios/${params.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(scenario)
      })

      if (res.ok) {
        router.push('/scenarios')
      }
    } catch (error) {
      console.error('Failed to save scenario:', error)
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this scenario?')) return

    try {
      const res = await fetch(`/api/scenarios/${params.id}`, {
        method: 'DELETE'
      })

      if (res.ok) {
        router.push('/scenarios')
      }
    } catch (error) {
      console.error('Failed to delete scenario:', error)
    }
  }

  const addOption = () => {
    if (!scenario) return
    setScenario({
      ...scenario,
      options: [
        ...scenario.options,
        {
          text: '',
          tags: [],
          immediate_outcome: '',
          longterm_outcome: '',
          risk_level: 'medium',
          perspective_shifts: []
        }
      ]
    })
  }

  const removeOption = (index: number) => {
    if (!scenario) return
    setScenario({
      ...scenario,
      options: scenario.options.filter((_, i) => i !== index)
    })
  }

  const updateOption = (index: number, field: keyof ScenarioOption, value: any) => {
    if (!scenario) return
    const newOptions = [...scenario.options]
    newOptions[index] = { ...newOptions[index], [field]: value }
    setScenario({ ...scenario, options: newOptions })
  }

  if (loading) {
    return (
      <div className="flex-1 p-8">
        <p className="text-gray-500">Loading scenario...</p>
      </div>
    )
  }

  if (!scenario) {
    return (
      <div className="flex-1 p-8">
        <p className="text-red-600">Scenario not found</p>
      </div>
    )
  }

  return (
    <div className="flex-1 p-8 max-w-5xl mx-auto">
      <div className="mb-6">
        <Link href="/scenarios" className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4">
          <ArrowLeft className="w-4 h-4" />
          Back to Scenarios
        </Link>
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold text-gray-900">Edit Scenario</h1>
          <div className="flex gap-3">
            <button
              onClick={handleDelete}
              className="flex items-center gap-2 px-4 py-2 text-red-600 bg-red-50 rounded-lg hover:bg-red-100"
            >
              <Trash2 className="w-4 h-4" />
              Delete
            </button>
            <Link
              href={`/scenarios/${params.id}/preview`}
              className="px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200"
            >
              Preview
            </Link>
            <button
              onClick={handleSave}
              disabled={saving}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              <Save className="w-4 h-4" />
              {saving ? 'Saving...' : 'Save Changes'}
            </button>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6 space-y-6">
        {/* Basic Info */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Title</label>
          <input
            type="text"
            value={scenario.title}
            onChange={(e) => setScenario({ ...scenario, title: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Situation</label>
          <textarea
            value={scenario.situation}
            onChange={(e) => setScenario({ ...scenario, situation: e.target.value })}
            rows={4}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div className="grid grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Context</label>
            <select
              value={scenario.context}
              onChange={(e) => setScenario({ ...scenario, context: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="military_workplace">Military Workplace</option>
              <option value="civilian_workplace">Civilian Workplace</option>
              <option value="family">Family</option>
              <option value="social">Social</option>
              <option value="hierarchy">Hierarchy</option>
              <option value="peer">Peer</option>
              <option value="high-pressure">High Pressure</option>
              <option value="close-quarters">Close Quarters</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Difficulty (1-3)</label>
            <input
              type="number"
              min="1"
              max="3"
              value={scenario.difficulty}
              onChange={(e) => setScenario({ ...scenario, difficulty: parseInt(e.target.value) })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={scenario.published}
                onChange={(e) => setScenario({ ...scenario, published: e.target.checked })}
                className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
              />
              <span className="text-sm text-gray-700">Published</span>
            </label>
          </div>
        </div>

        {/* Options */}
        <div className="border-t pt-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Response Options</h2>
            <button
              onClick={addOption}
              className="flex items-center gap-2 px-3 py-1.5 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              <Plus className="w-4 h-4" />
              Add Option
            </button>
          </div>

          <div className="space-y-6">
            {scenario.options.map((option, index) => (
              <div key={index} className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="font-medium text-gray-900">Option {index + 1}</h3>
                  <button
                    onClick={() => removeOption(index)}
                    className="text-red-600 hover:text-red-800"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>

                <div className="space-y-3">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Response Text</label>
                    <textarea
                      value={option.text}
                      onChange={(e) => updateOption(index, 'text', e.target.value)}
                      rows={2}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      placeholder="What the user might say or do..."
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Immediate Outcome</label>
                      <textarea
                        value={option.immediate_outcome}
                        onChange={(e) => updateOption(index, 'immediate_outcome', e.target.value)}
                        rows={2}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Long-term Outcome</label>
                      <textarea
                        value={option.longterm_outcome}
                        onChange={(e) => updateOption(index, 'longterm_outcome', e.target.value)}
                        rows={2}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Risk Level</label>
                      <select
                        value={option.risk_level}
                        onChange={(e) => updateOption(index, 'risk_level', e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      >
                        <option value="low">Low</option>
                        <option value="medium">Medium</option>
                        <option value="high">High</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Tags (comma-separated)</label>
                      <input
                        type="text"
                        value={option.tags.join(', ')}
                        onChange={(e) => updateOption(index, 'tags', e.target.value.split(',').map(t => t.trim()))}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                        placeholder="direct, assertive"
                      />
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

