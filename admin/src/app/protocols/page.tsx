'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Sparkles, CheckCircle, AlertCircle, RefreshCw } from 'lucide-react'

export default function ProtocolsPage() {
  const [protocols, setProtocols] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)
  const [generationResult, setGenerationResult] = useState<{ success: boolean; message: string } | null>(null)

  useEffect(() => {
    fetchProtocols()
  }, [])

  const fetchProtocols = async () => {
    try {
      const res = await fetch('/api/protocols')
      const data = await res.json()
      setProtocols(data)
    } catch (error) {
      console.error('Failed to fetch protocols:', error)
    } finally {
      setLoading(false)
    }
  }

  const generateWithGPT = async () => {
    setGenerating(true)
    setGenerationResult(null)

    try {
      const res = await fetch('/api/protocols/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ count: 3 })
      })

      if (!res.ok) throw new Error('Generation failed')

      const data = await res.json()
      setGenerationResult({
        success: true,
        message: `✅ Generated ${data.protocols?.length || 0} protocols! Review and publish them below.`
      })
      
      // Refresh the list
      setTimeout(() => {
        fetchProtocols()
        setGenerationResult(null)
      }, 3000)
    } catch (error) {
      console.error('Generation error:', error)
      setGenerationResult({
        success: false,
        message: '❌ Failed to generate protocols. Check API key and try again.'
      })
    } finally {
      setGenerating(false)
    }
  }

  const categoryBadgeColor = (category: string) => {
    const colors: Record<string, string> = {
      communication: 'bg-blue-100 text-blue-700',
      conflict: 'bg-orange-100 text-orange-700',
      'self-regulation': 'bg-green-100 text-green-700',
      trust: 'bg-purple-100 text-purple-700',
      recovery: 'bg-teal-100 text-teal-700',
      feedback: 'bg-indigo-100 text-indigo-700',
      boundary: 'bg-pink-100 text-pink-700',
      clarification: 'bg-cyan-100 text-cyan-700',
      difficult_conversation: 'bg-red-100 text-red-700',
    }
    return colors[category] || 'bg-gray-100 text-gray-700'
  }

  if (loading) {
    return (
      <div className="p-6 max-w-7xl mx-auto">
        <p className="text-gray-500">Loading protocols...</p>
      </div>
    )
  }

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Communication Protocols</h1>
          <p className="text-gray-600 mt-1">Manage step-by-step communication guides</p>
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
            href="/protocols/new"
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
          >
            + New Protocol
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

      {protocols && protocols.length === 0 ? (
        <div className="bg-gray-50 border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
          <div className="text-gray-400 mb-4">
            <svg className="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No protocols yet</h3>
          <p className="text-gray-500 mb-6">Create your first protocol or generate some with GPT.</p>
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
              href="/protocols/new"
              className="inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors"
            >
              Create Manually
            </Link>
          </div>
        </div>
      ) : (
        <div className="grid gap-4">
          {protocols?.map((protocol: any) => (
            <div key={protocol.id} className="bg-white rounded-lg shadow p-6 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="text-lg font-semibold text-gray-900">{protocol.title}</h3>
                    <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${categoryBadgeColor(protocol.category)}`}>
                      {protocol.category.replace(/_/g, ' ').replace('-', ' ')}
                    </span>
                    {protocol.published ? (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                        Published
                      </span>
                    ) : (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">
                        Draft
                      </span>
                    )}
                  </div>
                  
                  {protocol.description && (
                    <p className="text-sm text-gray-600 mb-3">{protocol.description}</p>
                  )}

                  <div className="flex items-center gap-4 text-sm text-gray-500">
                    <span>📋 {Array.isArray(protocol.steps) ? protocol.steps.length : 0} steps</span>
                    {protocol.when_to_use && <span>✅ When to use defined</span>}
                    {protocol.when_not_to_use && <span>⚠️ When NOT to use defined</span>}
                  </div>
                </div>

                <div className="flex gap-2">
                  <Link
                    href={`/protocols/${protocol.id}`}
                    className="px-4 py-2 text-blue-600 hover:bg-blue-50 rounded-lg font-medium transition-colors"
                  >
                    Edit
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="mt-6 flex items-center justify-between text-sm text-gray-600">
        <div>
          Showing {protocols?.length || 0} protocol{protocols?.length !== 1 ? 's' : ''}
        </div>
        <Link href="/scenarios" className="text-blue-600 hover:text-blue-900">
          ← Back to Scenarios
        </Link>
      </div>
    </div>
  )
}
