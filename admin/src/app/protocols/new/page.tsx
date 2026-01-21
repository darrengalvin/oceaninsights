'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'

export default function NewProtocolPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [category, setCategory] = useState('communication')
  const [whenToUse, setWhenToUse] = useState('')
  const [whenNotToUse, setWhenNotToUse] = useState('')
  const [commonFailures, setCommonFailures] = useState('')
  const [published, setPublished] = useState(false)

  const [steps, setSteps] = useState([
    { step: 1, title: '', description: '' },
  ])

  const addStep = () => {
    setSteps([
      ...steps,
      { step: steps.length + 1, title: '', description: '' },
    ])
  }

  const removeStep = (index: number) => {
    const updated = steps.filter((_, i) => i !== index)
    // Renumber steps
    updated.forEach((step, i) => {
      step.step = i + 1
    })
    setSteps(updated)
  }

  const updateStep = (index: number, field: string, value: string) => {
    const updated = [...steps]
    updated[index] = { ...updated[index], [field]: value }
    setSteps(updated)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const { error: insertError } = await supabase
        .from('protocols')
        .insert({
          title,
          description,
          category,
          steps,
          when_to_use: whenToUse || null,
          when_not_to_use: whenNotToUse || null,
          common_failures: commonFailures
            .split('\n')
            .map(s => s.trim())
            .filter(Boolean),
          published,
        })

      if (insertError) throw insertError

      router.push('/protocols')
    } catch (err: any) {
      setError(err.message)
      setLoading(false)
    }
  }

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Create New Protocol</h1>
        <p className="text-gray-600 mt-1">Build a step-by-step communication guide</p>
      </div>

      {error && (
        <div className="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Basic Info */}
        <div className="bg-white rounded-lg shadow p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Basic Information</h2>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Title *
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="e.g., Raising Concerns Up the Chain"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={2}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Brief overview of the protocol..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Category *
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="communication">Communication</option>
                <option value="conflict">Conflict Management</option>
                <option value="self-regulation">Self-Regulation</option>
                <option value="trust">Trust Building</option>
                <option value="recovery">Recovery & Repair</option>
              </select>
            </div>

            <div className="flex items-end">
              <label className="flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={published}
                  onChange={(e) => setPublished(e.target.checked)}
                  className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                />
                <span className="ml-2 text-sm font-medium text-gray-700">Publish immediately</span>
              </label>
            </div>
          </div>
        </div>

        {/* Steps */}
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Protocol Steps</h2>
            <button
              type="button"
              onClick={addStep}
              className="text-blue-600 hover:text-blue-700 font-medium text-sm"
            >
              + Add Step
            </button>
          </div>

          {steps.map((step, index) => (
            <div key={index} className="bg-white rounded-lg shadow p-6 space-y-4">
              <div className="flex justify-between items-start">
                <h3 className="text-lg font-medium text-gray-900">Step {step.step}</h3>
                {steps.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeStep(index)}
                    className="text-red-600 hover:text-red-700 text-sm font-medium"
                  >
                    Remove
                  </button>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Step Title *
                </label>
                <input
                  type="text"
                  value={step.title}
                  onChange={(e) => updateStep(index, 'title', e.target.value)}
                  required
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="e.g., Prepare"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Step Description *
                </label>
                <textarea
                  value={step.description}
                  onChange={(e) => updateStep(index, 'description', e.target.value)}
                  required
                  rows={2}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Explain what to do in this step..."
                />
              </div>
            </div>
          ))}
        </div>

        {/* Usage Guidelines */}
        <div className="bg-white rounded-lg shadow p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Usage Guidelines</h2>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              When to Use
            </label>
            <textarea
              value={whenToUse}
              onChange={(e) => setWhenToUse(e.target.value)}
              rows={2}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Describe situations where this protocol is appropriate..."
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              When NOT to Use
            </label>
            <textarea
              value={whenNotToUse}
              onChange={(e) => setWhenNotToUse(e.target.value)}
              rows={2}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Describe situations where this protocol should be avoided..."
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Common Failures (one per line)
            </label>
            <textarea
              value={commonFailures}
              onChange={(e) => setCommonFailures(e.target.value)}
              rows={3}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="List common mistakes or pitfalls..."
            />
          </div>
        </div>

        {/* Submit */}
        <div className="flex justify-end gap-3">
          <button
            type="button"
            onClick={() => router.back()}
            className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 font-medium transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors disabled:opacity-50"
          >
            {loading ? 'Creating...' : 'Create Protocol'}
          </button>
        </div>
      </form>
    </div>
  )
}

