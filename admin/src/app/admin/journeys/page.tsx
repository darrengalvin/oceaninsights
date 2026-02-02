'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Route, Plus, Eye, EyeOff, Pencil, Trash2, Users, Sparkles, CheckCircle, AlertCircle, RefreshCw, X } from 'lucide-react'

interface Journey {
  id: string
  slug: string
  title: string
  description: string | null
  audience: 'any' | 'service_member' | 'veteran' | 'partner_family'
  item_sequence: string[]
  is_published: boolean
  created_at: string
  updated_at: string
}

const AUDIENCE_LABELS = {
  any: 'Everyone',
  service_member: 'Service Members',
  veteran: 'Veterans',
  partner_family: 'Partners & Family'
}

export default function JourneysPage() {
  const [journeys, setJourneys] = useState<Journey[]>([])
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)
  const [showGenerateDialog, setShowGenerateDialog] = useState(false)
  const [generateCount, setGenerateCount] = useState(3)
  const [generationResult, setGenerationResult] = useState<{ success: boolean; message: string } | null>(null)

  useEffect(() => {
    fetchJourneys()
  }, [])

  const fetchJourneys = async () => {
    try {
      const res = await fetch('/api/journeys')
      const data = await res.json()
      setJourneys(data)
    } catch (error) {
      console.error('Failed to fetch journeys:', error)
    } finally {
      setLoading(false)
    }
  }

  const togglePublish = async (journey: Journey) => {
    try {
      await fetch(`/api/journeys/${journey.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_published: !journey.is_published })
      })
      fetchJourneys()
    } catch (error) {
      console.error('Failed to toggle journey:', error)
    }
  }

  const deleteJourney = async (id: string) => {
    if (!confirm('Are you sure you want to delete this journey?')) return
    
    try {
      await fetch(`/api/journeys/${id}`, { method: 'DELETE' })
      fetchJourneys()
    } catch (error) {
      console.error('Failed to delete journey:', error)
    }
  }

  const handleGenerate = async () => {
    if (generateCount >= 10 && !confirm(`Generating ${generateCount} journeys may take 30-60 seconds. Continue?`)) {
      return
    }

    setGenerating(true)
    setGenerationResult(null)
    setShowGenerateDialog(false)

    try {
      const res = await fetch('/api/journeys/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ count: generateCount })
      })

      const data = await res.json()

      if (!res.ok) {
        throw new Error(data.error || 'Generation failed')
      }

      setGenerationResult({
        success: true,
        message: data.message || `Generated ${data.inserted} journeys`
      })

      fetchJourneys()
    } catch (error: any) {
      console.error('Generation error:', error)
      setGenerationResult({
        success: false,
        message: error.message || 'Failed to generate journeys'
      })
    } finally {
      setGenerating(false)
    }
  }

  const isNew = (createdAt: string) => {
    const created = new Date(createdAt)
    const hourAgo = new Date(Date.now() - 60 * 60 * 1000)
    return created > hourAgo
  }

  if (loading) {
    return (
      <div className="p-8">
        <div className="max-w-6xl mx-auto">
          <p className="text-gray-500">Loading journeys...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Content Journeys</h1>
            <p className="text-gray-500 mt-1">Curated pathways through content (e.g. "7-Day Sleep Recovery")</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={() => setShowGenerateDialog(true)}
              disabled={generating}
              className="flex items-center gap-2 bg-ocean-600 text-white px-4 py-2 rounded-lg hover:bg-ocean-700 disabled:opacity-50 disabled:cursor-not-allowed font-medium transition-colors shadow-sm"
            >
              {generating ? (
                <>
                  <RefreshCw className="w-4 h-4 animate-spin" />
                  Generating...
                </>
              ) : (
                <>
                  <Sparkles className="w-4 h-4" />
                  Generate with AI
                </>
              )}
            </button>
            <Link 
              href="/admin/journeys/new"
              className="flex items-center gap-2 bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 font-medium transition-colors"
            >
              <Plus className="w-4 h-4" />
              New Journey
            </Link>
          </div>
        </div>

        {journeys.length === 0 ? (
          <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
            <Route className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No journeys yet</h3>
            <p className="text-gray-500 mb-6">Create your first curated content pathway</p>
            <Link
              href="/admin/journeys/new"
              className="inline-flex items-center gap-2 bg-ocean-600 text-white px-4 py-2 rounded-lg hover:bg-ocean-700"
            >
              <Plus className="w-4 h-4" />
              Create Journey
            </Link>
          </div>
        ) : (
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {journeys.map((journey) => (
              <div
                key={journey.id}
                className={`bg-white rounded-lg border border-gray-200 p-6 ${
                  !journey.is_published ? 'opacity-60' : ''
                }`}
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="text-lg font-semibold text-gray-900">
                        {journey.title}
                      </h3>
                      {isNew(journey.created_at) && (
                        <span className="px-2 py-0.5 text-xs font-bold text-green-700 bg-green-100 rounded animate-pulse">
                          NEW
                        </span>
                      )}
                    </div>
                    <p className="text-sm text-gray-500 mb-2">{journey.slug}</p>
                  </div>
                  <button
                    onClick={() => togglePublish(journey)}
                    className={`ml-2 px-2 py-1 rounded text-xs font-medium ${
                      journey.is_published
                        ? 'bg-green-100 text-green-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}
                  >
                    {journey.is_published ? (
                      <Eye className="w-3 h-3" />
                    ) : (
                      <EyeOff className="w-3 h-3" />
                    )}
                  </button>
                </div>

                {journey.description && (
                  <p className="text-sm text-gray-600 mb-4 line-clamp-2">
                    {journey.description}
                  </p>
                )}

                <div className="flex items-center gap-4 text-sm text-gray-500 mb-4">
                  <div className="flex items-center gap-1">
                    <Users className="w-4 h-4" />
                    {AUDIENCE_LABELS[journey.audience]}
                  </div>
                  <div className="flex items-center gap-1">
                    <Route className="w-4 h-4" />
                    {journey.item_sequence.length} items
                  </div>
                </div>

                <div className="flex items-center gap-2 pt-4 border-t border-gray-100">
                  <Link
                    href={`/admin/journeys/${journey.id}`}
                    className="flex-1 text-center px-3 py-2 text-sm font-medium text-ocean-600 bg-ocean-50 rounded hover:bg-ocean-100"
                  >
                    <Pencil className="w-4 h-4 inline mr-1" />
                    Edit
                  </Link>
                  <button
                    onClick={() => deleteJourney(journey.id)}
                    className="px-3 py-2 text-sm font-medium text-red-600 bg-red-50 rounded hover:bg-red-100"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Generation Dialog */}
        {showGenerateDialog && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4 shadow-xl">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Generate Journeys</h3>
                <button
                  onClick={() => setShowGenerateDialog(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
              <p className="text-gray-600 text-sm mb-4">
                AI will generate curated content pathway ideas for military personnel, veterans, and families.
              </p>
              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  How many journeys to generate?
                </label>
                <div className="grid grid-cols-4 gap-2">
                  {[1, 2, 3, 5, 10, 25, 50].map((num) => (
                    <button
                      key={num}
                      onClick={() => setGenerateCount(num)}
                      className={`px-3 py-2 rounded text-sm font-medium transition-colors ${
                        generateCount === num
                          ? 'bg-ocean-600 text-white'
                          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      }`}
                    >
                      {num}
                    </button>
                  ))}
                </div>
              </div>
              {generateCount >= 10 && (
                <div className="mb-4 p-3 bg-amber-50 border border-amber-200 rounded-lg">
                  <p className="text-sm text-amber-800">
                    Generating {generateCount} journeys may take 30-60 seconds.
                  </p>
                </div>
              )}
              <div className="flex gap-3">
                <button
                  onClick={handleGenerate}
                  className="flex-1 bg-ocean-600 text-white px-4 py-2 rounded-lg hover:bg-ocean-700 font-medium transition-colors"
                >
                  Generate
                </button>
                <button
                  onClick={() => setShowGenerateDialog(false)}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Generation Result Notification */}
        {generationResult && (
          <div className="fixed bottom-4 right-4 max-w-sm bg-white rounded-lg shadow-lg border border-gray-200 p-4 z-50">
            <div className="flex items-start gap-3">
              {generationResult.success ? (
                <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
              ) : (
                <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
              )}
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">
                  {generationResult.success ? 'Success!' : 'Error'}
                </p>
                <p className="text-sm text-gray-600 mt-1">
                  {generationResult.message}
                </p>
              </div>
              <button
                onClick={() => setGenerationResult(null)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
