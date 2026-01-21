'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Sparkles, CheckCircle, AlertCircle, RefreshCw } from 'lucide-react'

export default function ScenariosPage() {
  const [scenarios, setScenarios] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)
  const [generationResult, setGenerationResult] = useState<{ success: boolean; message: string } | null>(null)

  useEffect(() => {
    fetchScenarios()
  }, [])

  const fetchScenarios = async () => {
    try {
      const res = await fetch('/api/scenarios')
      const data = await res.json()
      setScenarios(data)
    } catch (error) {
      console.error('Failed to fetch scenarios:', error)
    } finally {
      setLoading(false)
    }
  }

  const generateWithGPT = async () => {
    setGenerating(true)
    setGenerationResult(null)

    try {
      const res = await fetch('/api/scenarios/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ count: 3 })
      })

      if (!res.ok) throw new Error('Generation failed')

      const data = await res.json()
      setGenerationResult({
        success: true,
        message: `✅ Generated ${data.scenarios?.length || 0} scenarios! Review and publish them below.`
      })
      
      // Refresh the list
      setTimeout(() => {
        fetchScenarios()
        setGenerationResult(null)
      }, 3000)
    } catch (error) {
      console.error('Generation error:', error)
      setGenerationResult({
        success: false,
        message: '❌ Failed to generate scenarios. Check API key and try again.'
      })
    } finally {
      setGenerating(false)
    }
  }

  const contextBadgeColor = (context: string) => {
    const colors: Record<string, string> = {
      hierarchy: 'bg-purple-100 text-purple-700',
      peer: 'bg-blue-100 text-blue-700',
      'high-pressure': 'bg-orange-100 text-orange-700',
      'close-quarters': 'bg-teal-100 text-teal-700',
      leadership: 'bg-indigo-100 text-indigo-700',
      military_workplace: 'bg-purple-100 text-purple-700',
      civilian_workplace: 'bg-blue-100 text-blue-700',
      family: 'bg-green-100 text-green-700',
      social: 'bg-pink-100 text-pink-700',
    }
    return colors[context] || 'bg-gray-100 text-gray-700'
  }

  const difficultyStars = (difficulty: number) => {
    return '★'.repeat(difficulty) + '☆'.repeat(3 - difficulty)
  }

  if (loading) {
    return (
      <div className="p-6 max-w-7xl mx-auto">
        <p className="text-gray-500">Loading scenarios...</p>
      </div>
    )
  }

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Decision Training Scenarios</h1>
          <p className="text-gray-600 mt-1">Manage workplace scenario training content</p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={generateWithGPT}
            disabled={generating}
            className="flex items-center gap-2 bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {generating ? (
              <>
                <RefreshCw className="w-4 h-4 animate-spin" />
                Generating...
              </>
            ) : (
              <>
                <Sparkles className="w-4 h-4" />
                Generate with GPT
              </>
            )}
          </button>
          <Link
            href="/scenarios/new"
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
          >
            + New Scenario
          </Link>
        </div>
      </div>

      {generationResult && (
        <div className={`mb-6 p-4 rounded-lg flex items-center gap-3 ${
          generationResult.success 
            ? 'bg-green-50 border border-green-200 text-green-800' 
            : 'bg-red-50 border border-red-200 text-red-800'
        }`}>
          {generationResult.success ? (
            <CheckCircle className="w-5 h-5" />
          ) : (
            <AlertCircle className="w-5 h-5" />
          )}
          <span>{generationResult.message}</span>
        </div>
      )}

      {scenarios && scenarios.length === 0 ? (
        <div className="bg-gray-50 border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
          <div className="text-gray-400 mb-4">
            <svg className="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No scenarios yet</h3>
          <p className="text-gray-500 mb-6">Get started by creating your first scenario or generate some with GPT.</p>
          <div className="flex gap-3 justify-center">
            <button
              onClick={generateWithGPT}
              disabled={generating}
              className="inline-flex items-center gap-2 bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors"
            >
              <Sparkles className="w-4 h-4" />
              Generate with GPT
            </button>
            <Link
              href="/scenarios/new"
              className="inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors"
            >
              Create Manually
            </Link>
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Scenario
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Context
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Difficulty
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Options
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {scenarios?.map((scenario: any) => (
                <tr key={scenario.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="text-sm font-medium text-gray-900">{scenario.title}</div>
                    <div className="text-sm text-gray-500 truncate max-w-md">{scenario.situation}</div>
                    {scenario.content_pack && (
                      <div className="text-xs text-gray-400 mt-1">
                        📦 {scenario.content_pack.name}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${contextBadgeColor(scenario.context)}`}>
                      {scenario.context.replace(/_/g, ' ').replace('-', ' ')}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-sm text-gray-900">{difficultyStars(scenario.difficulty)}</span>
                    <div className="text-xs text-gray-500">Level {scenario.difficulty}</div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-900">
                    {scenario.options?.length || 0} options
                  </td>
                  <td className="px-6 py-4">
                    {scenario.published ? (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                        Published
                      </span>
                    ) : (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">
                        Draft
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 text-right text-sm font-medium">
                    <Link
                      href={`/scenarios/${scenario.id}`}
                      className="text-blue-600 hover:text-blue-900 mr-4"
                    >
                      Edit
                    </Link>
                    <Link
                      href={`/scenarios/${scenario.id}/preview`}
                      className="text-gray-600 hover:text-gray-900"
                    >
                      Preview
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <div className="mt-6 flex items-center justify-between text-sm text-gray-600">
        <div>
          Showing {scenarios?.length || 0} scenario{scenarios?.length !== 1 ? 's' : ''}
        </div>
        <Link href="/protocols" className="text-blue-600 hover:text-blue-900">
          Manage Protocols →
        </Link>
      </div>
    </div>
  )
}
