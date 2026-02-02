'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Sparkles, CheckCircle, AlertCircle, RefreshCw, X } from 'lucide-react'

export default function ScenariosPage() {
  const [scenarios, setScenarios] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)
  const [showGenerateDialog, setShowGenerateDialog] = useState(false)
  const [generateCount, setGenerateCount] = useState(3)
  const [generationResult, setGenerationResult] = useState<{ success: boolean; message: string } | null>(null)
  const [filter, setFilter] = useState<'all' | 'new' | 'published' | 'draft'>('all')
  const [bulkPublishing, setBulkPublishing] = useState(false)
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set())

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

  const handleGenerate = async () => {
    setGenerating(true)
    setGenerationResult(null)
    setShowGenerateDialog(false)

    try {
      const res = await fetch('/api/scenarios/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ count: generateCount })
      })

      if (!res.ok) {
        const error = await res.json()
        throw new Error(error.error || 'Generation failed')
      }

      const data = await res.json()
      setGenerationResult({
        success: true,
        message: `Generated ${data.scenarios?.length || 0} scenarios! Review and publish them below.`
      })
      
      setTimeout(() => {
        fetchScenarios()
        setGenerationResult(null)
      }, 3000)
    } catch (error: any) {
      console.error('Generation error:', error)
      setGenerationResult({
        success: false,
        message: error.message || 'Failed to generate scenarios. Check API key in Vercel settings.'
      })
    } finally {
      setGenerating(false)
    }
  }

  const handleBulkPublish = async () => {
    const draftScenarios = scenarios.filter(s => !s.published)
    if (draftScenarios.length === 0) {
      alert('No draft scenarios to publish!')
      return
    }

    if (!confirm(`Publish all ${draftScenarios.length} draft scenarios?`)) {
      return
    }

    setBulkPublishing(true)

    try {
      await Promise.all(
        draftScenarios.map(scenario =>
          fetch(`/api/scenarios/${scenario.id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ published: true })
          })
        )
      )

      alert(`Published ${draftScenarios.length} scenarios!`)
      setSelectedIds(new Set())
      fetchScenarios()
    } catch (error) {
      console.error('Bulk publish error:', error)
      alert('Failed to publish some scenarios')
    } finally {
      setBulkPublishing(false)
    }
  }

  const toggleSelect = (id: string) => {
    const newSelected = new Set(selectedIds)
    if (newSelected.has(id)) {
      newSelected.delete(id)
    } else {
      newSelected.add(id)
    }
    setSelectedIds(newSelected)
  }

  const togglePublished = async (id: string, currentStatus: boolean) => {
    try {
      const res = await fetch(`/api/scenarios/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ published: !currentStatus })
      })

      if (!res.ok) throw new Error('Failed to update')
      fetchScenarios()
    } catch (error) {
      console.error('Toggle publish error:', error)
      alert('Failed to update scenario')
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

  const isNew = (createdAt: string) => {
    const created = new Date(createdAt)
    const hourAgo = new Date(Date.now() - 60 * 60 * 1000)
    return created > hourAgo
  }

  const filteredScenarios = scenarios.filter(scenario => {
    if (filter === 'all') return true
    if (filter === 'new') return isNew(scenario.created_at)
    if (filter === 'published') return scenario.published
    if (filter === 'draft') return !scenario.published
    return true
  })

  const newCount = scenarios.filter(s => isNew(s.created_at)).length

  if (loading) {
    return (
      <div className="p-8">
        <p className="text-gray-500">Loading scenarios...</p>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Decision Training Scenarios</h1>
            <p className="text-gray-500 mt-1">Manage workplace scenario training content</p>
          </div>
          <div className="flex gap-3 flex-wrap">
            {scenarios.filter(s => !s.published).length > 0 && (
              <button
                onClick={handleBulkPublish}
                disabled={bulkPublishing}
                className="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50"
              >
                {bulkPublishing ? (
                  <>
                    <RefreshCw className="w-4 h-4 animate-spin" />
                    Publishing...
                  </>
                ) : (
                  <>
                    <CheckCircle className="w-4 h-4" />
                    Publish All ({scenarios.filter(s => !s.published).length})
                  </>
                )}
              </button>
            )}
            <button
              onClick={() => setShowGenerateDialog(true)}
              disabled={generating}
              className="flex items-center gap-2 bg-ocean-600 hover:bg-ocean-700 text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50"
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
              href="/admin/scenarios/new"
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
            >
              + New Scenario
            </Link>
          </div>
        </div>

        {/* Generation Dialog */}
        {showGenerateDialog && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg shadow-xl p-6 max-w-md w-full mx-4">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-bold text-gray-900">Generate Scenarios</h2>
                <button onClick={() => setShowGenerateDialog(false)} className="text-gray-400 hover:text-gray-600">
                  <X className="w-5 h-5" />
                </button>
              </div>
              
              <p className="text-gray-600 mb-4">
                AI will generate realistic workplace decision-training scenarios.
              </p>

              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  How many scenarios?
                </label>
                <select
                  value={generateCount}
                  onChange={(e) => setGenerateCount(parseInt(e.target.value))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500"
                >
                  {[1, 2, 3, 5, 10, 25, 50].map(n => (
                    <option key={n} value={n}>{n} scenario{n > 1 ? 's' : ''}</option>
                  ))}
                </select>
              </div>

              <div className="flex gap-3">
                <button onClick={() => setShowGenerateDialog(false)} className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50">
                  Cancel
                </button>
                <button onClick={handleGenerate} className="flex-1 px-4 py-2 bg-ocean-600 text-white rounded-lg hover:bg-ocean-700 flex items-center justify-center gap-2">
                  <Sparkles className="w-4 h-4" />
                  Generate
                </button>
              </div>
            </div>
          </div>
        )}

        {generationResult && (
          <div className={`mb-6 p-4 rounded-lg flex items-center gap-3 ${
            generationResult.success 
              ? 'bg-green-50 border border-green-200 text-green-800' 
              : 'bg-red-50 border border-red-200 text-red-800'
          }`}>
            {generationResult.success ? <CheckCircle className="w-5 h-5" /> : <AlertCircle className="w-5 h-5" />}
            <span>{generationResult.message}</span>
          </div>
        )}

        {/* Filter Tabs */}
        {scenarios.length > 0 && (
          <div className="mb-6 border-b border-gray-200">
            <nav className="flex gap-6">
              {['all', 'new', 'published', 'draft'].map(tab => (
                <button
                  key={tab}
                  onClick={() => setFilter(tab as any)}
                  className={`pb-3 px-1 border-b-2 font-medium text-sm transition-colors ${
                    filter === tab
                      ? 'border-ocean-600 text-ocean-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700'
                  }`}
                >
                  {tab === 'all' && `All (${scenarios.length})`}
                  {tab === 'new' && newCount > 0 && `New (${newCount})`}
                  {tab === 'published' && `Published (${scenarios.filter(s => s.published).length})`}
                  {tab === 'draft' && `Drafts (${scenarios.filter(s => !s.published).length})`}
                </button>
              ))}
            </nav>
          </div>
        )}

        {scenarios.length === 0 ? (
          <div className="bg-white border-2 border-dashed border-gray-200 rounded-lg p-12 text-center">
            <h3 className="text-lg font-medium text-gray-900 mb-2">No scenarios yet</h3>
            <p className="text-gray-500 mb-6">Get started by creating your first scenario or generate some with AI.</p>
            <div className="flex gap-3 justify-center">
              <button onClick={() => setShowGenerateDialog(true)} className="inline-flex items-center gap-2 bg-ocean-600 text-white px-6 py-2 rounded-lg font-medium">
                <Sparkles className="w-4 h-4" />
                Generate with AI
              </button>
              <Link href="/admin/scenarios/new" className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg font-medium">
                Create Manually
              </Link>
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Scenario</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Context</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Difficulty</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Options</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredScenarios.map((scenario: any) => (
                  <tr key={scenario.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <div className="text-sm font-medium text-gray-900">{scenario.title}</div>
                        {isNew(scenario.created_at) && (
                          <span className="px-2 py-0.5 text-xs font-bold rounded-full bg-green-100 text-green-700 animate-pulse">NEW</span>
                        )}
                      </div>
                      <div className="text-sm text-gray-500 truncate max-w-md">{scenario.situation}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${contextBadgeColor(scenario.context)}`}>
                        {scenario.context?.replace(/_/g, ' ')}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-sm text-gray-900">{difficultyStars(scenario.difficulty)}</span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      {scenario.options?.length || 0} options
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => togglePublished(scenario.id, scenario.published)}
                        className={`inline-flex items-center gap-1 px-2 py-1 text-xs font-medium rounded-full ${
                          scenario.published
                            ? 'bg-green-100 text-green-700 hover:bg-green-200'
                            : 'bg-yellow-100 text-yellow-700 hover:bg-yellow-200'
                        }`}
                      >
                        {scenario.published ? <><CheckCircle className="w-3 h-3" /> Published</> : <><AlertCircle className="w-3 h-3" /> Draft</>}
                      </button>
                    </td>
                    <td className="px-6 py-4 text-right text-sm font-medium">
                      <Link href={`/admin/scenarios/${scenario.id}`} className="text-blue-600 hover:text-blue-900 mr-4">Edit</Link>
                      <Link href={`/admin/scenarios/${scenario.id}/preview`} className="text-gray-600 hover:text-gray-900">Preview</Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <div className="mt-6 flex items-center justify-between text-sm text-gray-600">
          <div>Showing {filteredScenarios.length} of {scenarios.length} scenarios</div>
          <Link href="/admin/protocols" className="text-blue-600 hover:text-blue-900">Manage Protocols →</Link>
        </div>
      </div>
    </div>
  )
}
