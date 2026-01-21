'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'

export default function NewScenarioPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [title, setTitle] = useState('')
  const [situation, setSituation] = useState('')
  const [context, setContext] = useState('peer')
  const [difficulty, setDifficulty] = useState(1)
  const [published, setPublished] = useState(false)

  const [options, setOptions] = useState([
    {
      text: '',
      tags: '',
      immediateOutcome: '',
      longtermOutcome: '',
      riskLevel: 'medium',
      perspectives: [
        { viewpoint: 'command', interpretation: '' },
        { viewpoint: 'peer', interpretation: '' },
      ],
    },
  ])

  const addOption = () => {
    setOptions([
      ...options,
      {
        text: '',
        tags: '',
        immediateOutcome: '',
        longtermOutcome: '',
        riskLevel: 'medium',
        perspectives: [
          { viewpoint: 'command', interpretation: '' },
          { viewpoint: 'peer', interpretation: '' },
        ],
      },
    ])
  }

  const removeOption = (index: number) => {
    setOptions(options.filter((_, i) => i !== index))
  }

  const updateOption = (index: number, field: string, value: any) => {
    const updated = [...options]
    updated[index] = { ...updated[index], [field]: value }
    setOptions(updated)
  }

  const updatePerspective = (optionIndex: number, perspectiveIndex: number, field: string, value: string) => {
    const updated = [...options]
    updated[optionIndex].perspectives[perspectiveIndex] = {
      ...updated[optionIndex].perspectives[perspectiveIndex],
      [field]: value,
    }
    setOptions(updated)
  }

  const addPerspective = (optionIndex: number) => {
    const updated = [...options]
    updated[optionIndex].perspectives.push({
      viewpoint: 'subordinate',
      interpretation: '',
    })
    setOptions(updated)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const supabase = createClient()

      // Create scenario
      const { data: scenario, error: scenarioError } = await supabase
        .from('scenarios')
        .insert({
          title,
          situation,
          context,
          difficulty,
          published,
          tags: [],
        })
        .select()
        .single()

      if (scenarioError) throw scenarioError

      // Create options and perspectives
      for (let i = 0; i < options.length; i++) {
        const option = options[i]

        const { data: optionData, error: optionError } = await supabase
          .from('scenario_options')
          .insert({
            scenario_id: scenario.id,
            text: option.text,
            tags: option.tags.split(',').map(t => t.trim()).filter(Boolean),
            immediate_outcome: option.immediateOutcome,
            longterm_outcome: option.longtermOutcome,
            risk_level: option.riskLevel,
            sort_order: i,
          })
          .select()
          .single()

        if (optionError) throw optionError

        // Create perspectives
        for (const perspective of option.perspectives) {
          if (perspective.interpretation.trim()) {
            const { error: perspectiveError } = await supabase
              .from('perspective_shifts')
              .insert({
                option_id: optionData.id,
                viewpoint: perspective.viewpoint,
                interpretation: perspective.interpretation,
              })

            if (perspectiveError) throw perspectiveError
          }
        }
      }

      router.push('/scenarios')
    } catch (err: any) {
      setError(err.message)
      setLoading(false)
    }
  }

  return (
    <div className="p-6 max-w-5xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Create New Scenario</h1>
        <p className="text-gray-600 mt-1">Build a decision training scenario with multiple response options</p>
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
              placeholder="e.g., Interrupted in Briefing"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Situation (2-3 sentences) *
            </label>
            <textarea
              value={situation}
              onChange={(e) => setSituation(e.target.value)}
              required
              rows={4}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Describe the scenario situation..."
            />
          </div>

          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Context *
              </label>
              <select
                value={context}
                onChange={(e) => setContext(e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="hierarchy">Hierarchy & Authority</option>
                <option value="peer">Peer Dynamics</option>
                <option value="high-pressure">High Pressure</option>
                <option value="close-quarters">Close Quarters</option>
                <option value="leadership">Leadership</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Difficulty *
              </label>
              <select
                value={difficulty}
                onChange={(e) => setDifficulty(Number(e.target.value))}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value={1}>1 - Foundational</option>
                <option value={2}>2 - Intermediate</option>
                <option value={3}>3 - Advanced</option>
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

        {/* Response Options */}
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Response Options</h2>
            <button
              type="button"
              onClick={addOption}
              className="text-blue-600 hover:text-blue-700 font-medium text-sm"
            >
              + Add Option
            </button>
          </div>

          {options.map((option, optionIndex) => (
            <div key={optionIndex} className="bg-white rounded-lg shadow p-6 space-y-4">
              <div className="flex justify-between items-start">
                <h3 className="text-lg font-medium text-gray-900">Option {optionIndex + 1}</h3>
                {options.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeOption(optionIndex)}
                    className="text-red-600 hover:text-red-700 text-sm font-medium"
                  >
                    Remove
                  </button>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Response Text *
                </label>
                <textarea
                  value={option.text}
                  onChange={(e) => updateOption(optionIndex, 'text', e.target.value)}
                  required
                  rows={2}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="What the user can choose to say/do..."
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Tags (comma-separated)
                  </label>
                  <input
                    type="text"
                    value={option.tags}
                    onChange={(e) => updateOption(optionIndex, 'tags', e.target.value)}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="e.g., direct, assertive, delayed"
                  />
                  <p className="text-xs text-gray-500 mt-1">Used for response profiling</p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Risk Level *
                  </label>
                  <select
                    value={option.riskLevel}
                    onChange={(e) => updateOption(optionIndex, 'riskLevel', e.target.value)}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="low">Low Risk</option>
                    <option value="medium">Medium Risk</option>
                    <option value="high">High Risk</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Immediate Outcome *
                </label>
                <textarea
                  value={option.immediateOutcome}
                  onChange={(e) => updateOption(optionIndex, 'immediateOutcome', e.target.value)}
                  required
                  rows={2}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="What happens right away..."
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Long-term Consideration *
                </label>
                <textarea
                  value={option.longtermOutcome}
                  onChange={(e) => updateOption(optionIndex, 'longtermOutcome', e.target.value)}
                  required
                  rows={2}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Potential long-term effects..."
                />
              </div>

              {/* Perspectives */}
              <div className="pt-4 border-t border-gray-200">
                <div className="flex justify-between items-center mb-3">
                  <h4 className="text-sm font-medium text-gray-700">Perspective Shifts</h4>
                  <button
                    type="button"
                    onClick={() => addPerspective(optionIndex)}
                    className="text-blue-600 hover:text-blue-700 text-xs font-medium"
                  >
                    + Add Perspective
                  </button>
                </div>

                {option.perspectives.map((perspective, perspectiveIndex) => (
                  <div key={perspectiveIndex} className="grid grid-cols-4 gap-3 mb-3">
                    <select
                      value={perspective.viewpoint}
                      onChange={(e) => updatePerspective(optionIndex, perspectiveIndex, 'viewpoint', e.target.value)}
                      className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value="command">From Command</option>
                      <option value="peer">From Peer</option>
                      <option value="subordinate">From Subordinate</option>
                      <option value="external">External Observer</option>
                    </select>
                    <textarea
                      value={perspective.interpretation}
                      onChange={(e) => updatePerspective(optionIndex, perspectiveIndex, 'interpretation', e.target.value)}
                      rows={1}
                      className="col-span-3 border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      placeholder="How this choice is interpreted from this viewpoint..."
                    />
                  </div>
                ))}
              </div>
            </div>
          ))}
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
            {loading ? 'Creating...' : 'Create Scenario'}
          </button>
        </div>
      </form>
    </div>
  )
}

