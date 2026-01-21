'use client'

import { useEffect, useState } from 'react'
import { useRouter, useParams } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Save, Trash2, Plus, X, MoveUp, MoveDown } from 'lucide-react'

interface ProtocolStep {
  step_number: number
  title: string
  instruction: string
  example: string
  why_it_works: string
}

interface Protocol {
  id: string
  title: string
  category: string
  description: string
  when_to_use: string
  when_not_to_use: string
  common_failures: string[]
  steps: ProtocolStep[]
  published: boolean
}

export default function EditProtocolPage() {
  const router = useRouter()
  const params = useParams()
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [protocol, setProtocol] = useState<Protocol | null>(null)

  useEffect(() => {
    if (params.id) {
      fetchProtocol(params.id as string)
    }
  }, [params.id])

  const fetchProtocol = async (id: string) => {
    try {
      const res = await fetch(`/api/protocols/${id}`)
      const data = await res.json()
      setProtocol(data)
    } catch (error) {
      console.error('Failed to fetch protocol:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    if (!protocol) return
    setSaving(true)

    try {
      const res = await fetch(`/api/protocols/${params.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(protocol)
      })

      if (res.ok) {
        router.push('/protocols')
      }
    } catch (error) {
      console.error('Failed to save protocol:', error)
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this protocol?')) return

    try {
      const res = await fetch(`/api/protocols/${params.id}`, {
        method: 'DELETE'
      })

      if (res.ok) {
        router.push('/protocols')
      }
    } catch (error) {
      console.error('Failed to delete protocol:', error)
    }
  }

  const addStep = () => {
    if (!protocol) return
    const newStepNumber = protocol.steps.length + 1
    setProtocol({
      ...protocol,
      steps: [
        ...protocol.steps,
        {
          step_number: newStepNumber,
          title: '',
          instruction: '',
          example: '',
          why_it_works: ''
        }
      ]
    })
  }

  const removeStep = (index: number) => {
    if (!protocol) return
    const newSteps = protocol.steps.filter((_, i) => i !== index)
    // Renumber steps
    newSteps.forEach((step, i) => step.step_number = i + 1)
    setProtocol({ ...protocol, steps: newSteps })
  }

  const moveStep = (index: number, direction: 'up' | 'down') => {
    if (!protocol) return
    const newSteps = [...protocol.steps]
    const targetIndex = direction === 'up' ? index - 1 : index + 1
    
    if (targetIndex < 0 || targetIndex >= newSteps.length) return
    
    [newSteps[index], newSteps[targetIndex]] = [newSteps[targetIndex], newSteps[index]]
    // Renumber steps
    newSteps.forEach((step, i) => step.step_number = i + 1)
    setProtocol({ ...protocol, steps: newSteps })
  }

  const updateStep = (index: number, field: keyof ProtocolStep, value: any) => {
    if (!protocol) return
    const newSteps = [...protocol.steps]
    newSteps[index] = { ...newSteps[index], [field]: value }
    setProtocol({ ...protocol, steps: newSteps })
  }

  if (loading) {
    return (
      <div className="flex-1 p-8">
        <p className="text-gray-500">Loading protocol...</p>
      </div>
    )
  }

  if (!protocol) {
    return (
      <div className="flex-1 p-8">
        <p className="text-red-600">Protocol not found</p>
      </div>
    )
  }

  return (
    <div className="flex-1 p-8 max-w-5xl mx-auto">
      <div className="mb-6">
        <Link href="/protocols" className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4">
          <ArrowLeft className="w-4 h-4" />
          Back to Protocols
        </Link>
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold text-gray-900">Edit Protocol</h1>
          <div className="flex gap-3">
            <button
              onClick={handleDelete}
              className="flex items-center gap-2 px-4 py-2 text-red-600 bg-red-50 rounded-lg hover:bg-red-100"
            >
              <Trash2 className="w-4 h-4" />
              Delete
            </button>
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
            value={protocol.title}
            onChange={(e) => setProtocol({ ...protocol, title: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
          <textarea
            value={protocol.description}
            onChange={(e) => setProtocol({ ...protocol, description: e.target.value })}
            rows={2}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
            <select
              value={protocol.category}
              onChange={(e) => setProtocol({ ...protocol, category: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="conflict">Conflict</option>
              <option value="feedback">Feedback</option>
              <option value="boundary">Boundary</option>
              <option value="clarification">Clarification</option>
              <option value="difficult_conversation">Difficult Conversation</option>
              <option value="communication">Communication</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <label className="flex items-center gap-2 cursor-pointer mt-2">
              <input
                type="checkbox"
                checked={protocol.published}
                onChange={(e) => setProtocol({ ...protocol, published: e.target.checked })}
                className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
              />
              <span className="text-sm text-gray-700">Published</span>
            </label>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">When to Use</label>
            <textarea
              value={protocol.when_to_use}
              onChange={(e) => setProtocol({ ...protocol, when_to_use: e.target.value })}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              placeholder="Use this when you need to..."
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">When NOT to Use</label>
            <textarea
              value={protocol.when_not_to_use}
              onChange={(e) => setProtocol({ ...protocol, when_not_to_use: e.target.value })}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              placeholder="Don't use this if..."
            />
          </div>
        </div>

        {/* Steps */}
        <div className="border-t pt-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Protocol Steps</h2>
            <button
              onClick={addStep}
              className="flex items-center gap-2 px-3 py-1.5 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              <Plus className="w-4 h-4" />
              Add Step
            </button>
          </div>

          <div className="space-y-4">
            {protocol.steps.map((step, index) => (
              <div key={index} className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="font-medium text-gray-900">Step {step.step_number}</h3>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => moveStep(index, 'up')}
                      disabled={index === 0}
                      className="p-1 text-gray-600 hover:text-gray-900 disabled:opacity-30"
                    >
                      <MoveUp className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => moveStep(index, 'down')}
                      disabled={index === protocol.steps.length - 1}
                      className="p-1 text-gray-600 hover:text-gray-900 disabled:opacity-30"
                    >
                      <MoveDown className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => removeStep(index)}
                      className="p-1 text-red-600 hover:text-red-800"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                <div className="space-y-3">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Step Title</label>
                    <input
                      type="text"
                      value={step.title}
                      onChange={(e) => updateStep(index, 'title', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      placeholder="Name this step..."
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Instruction</label>
                    <textarea
                      value={step.instruction}
                      onChange={(e) => updateStep(index, 'instruction', e.target.value)}
                      rows={2}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      placeholder="What to do..."
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Example</label>
                    <textarea
                      value={step.example}
                      onChange={(e) => updateStep(index, 'example', e.target.value)}
                      rows={2}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      placeholder="Example of what to say..."
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Why It Works</label>
                    <textarea
                      value={step.why_it_works}
                      onChange={(e) => updateStep(index, 'why_it_works', e.target.value)}
                      rows={2}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                      placeholder="Explanation of the psychology/benefit..."
                    />
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

