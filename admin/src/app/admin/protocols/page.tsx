'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Sparkles, CheckCircle, AlertCircle, RefreshCw, X } from 'lucide-react'

export default function ProtocolsPage() {
  const [protocols, setProtocols] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)
  const [showGenerateDialog, setShowGenerateDialog] = useState(false)
  const [generateCount, setGenerateCount] = useState(3)
  const [generationResult, setGenerationResult] = useState<{ success: boolean; message: string } | null>(null)
  const [filter, setFilter] = useState<'all' | 'new' | 'published' | 'draft'>('all')
  const [bulkPublishing, setBulkPublishing] = useState(false)
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set())

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

  const handleGenerate = async () => {
    setGenerating(true)
    setGenerationResult(null)
    setShowGenerateDialog(false)

    try {
      const res = await fetch('/api/protocols/generate', {
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
        message: `Generated ${data.protocols?.length || 0} protocols! Review and publish them below.`
      })
      
      setTimeout(() => {
        fetchProtocols()
        setGenerationResult(null)
      }, 3000)
    } catch (error: any) {
      console.error('Generation error:', error)
      setGenerationResult({
        success: false,
        message: error.message || 'Failed to generate protocols.'
      })
    } finally {
      setGenerating(false)
    }
  }

  const handleBulkPublish = async () => {
    const draftProtocols = protocols.filter(p => !p.published)
    if (draftProtocols.length === 0) {
      alert('No draft protocols to publish!')
      return
    }

    if (!confirm(`Publish all ${draftProtocols.length} draft protocols?`)) {
      return
    }

    setBulkPublishing(true)

    try {
      await Promise.all(
        draftProtocols.map(protocol =>
          fetch(`/api/protocols/${protocol.id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ published: true })
          })
        )
      )

      alert(`Published ${draftProtocols.length} protocols!`)
      setSelectedIds(new Set())
      fetchProtocols()
    } catch (error) {
      console.error('Bulk publish error:', error)
      alert('Failed to publish some protocols')
    } finally {
      setBulkPublishing(false)
    }
  }

  const togglePublished = async (id: string, currentStatus: boolean) => {
    try {
      const res = await fetch(`/api/protocols/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ published: !currentStatus })
      })

      if (!res.ok) throw new Error('Failed to update')
      fetchProtocols()
    } catch (error) {
      console.error('Toggle publish error:', error)
      alert('Failed to update protocol')
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

  const isNew = (createdAt: string) => {
    const created = new Date(createdAt)
    const hourAgo = new Date(Date.now() - 60 * 60 * 1000)
    return created > hourAgo
  }

  const filteredProtocols = protocols.filter(protocol => {
    if (filter === 'all') return true
    if (filter === 'new') return isNew(protocol.created_at)
    if (filter === 'published') return protocol.published
    if (filter === 'draft') return !protocol.published
    return true
  })

  const newCount = protocols.filter(p => isNew(p.created_at)).length

  if (loading) {
    return (
      <div className="p-8">
        <p className="text-gray-500">Loading protocols...</p>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Communication Protocols</h1>
            <p className="text-gray-500 mt-1">Manage step-by-step communication guides</p>
          </div>
          <div className="flex gap-3 flex-wrap">
            {protocols.filter(p => !p.published).length > 0 && (
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
                    Publish All ({protocols.filter(p => !p.published).length})
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
              href="/admin/protocols/new"
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
            >
              + New Protocol
            </Link>
          </div>
        </div>

        {/* Generation Dialog */}
        {showGenerateDialog && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg shadow-xl p-6 max-w-md w-full mx-4">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-bold text-gray-900">Generate Protocols</h2>
                <button onClick={() => setShowGenerateDialog(false)} className="text-gray-400 hover:text-gray-600">
                  <X className="w-5 h-5" />
                </button>
              </div>
              
              <p className="text-gray-600 mb-4">
                AI will generate communication protocols with step-by-step instructions.
              </p>

              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  How many protocols?
                </label>
                <select
                  value={generateCount}
                  onChange={(e) => setGenerateCount(parseInt(e.target.value))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-ocean-500"
                >
                  {[1, 2, 3, 5, 10, 25, 50].map(n => (
                    <option key={n} value={n}>{n} protocol{n > 1 ? 's' : ''}</option>
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
        {protocols.length > 0 && (
          <div className="mb-6 border-b border-gray-200">
            <nav className="flex gap-6">
              <button
                onClick={() => setFilter('all')}
                className={`pb-3 px-1 border-b-2 font-medium text-sm transition-colors ${
                  filter === 'all' ? 'border-ocean-600 text-ocean-600' : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                All ({protocols.length})
              </button>
              {newCount > 0 && (
                <button
                  onClick={() => setFilter('new')}
                  className={`pb-3 px-1 border-b-2 font-medium text-sm transition-colors flex items-center gap-2 ${
                    filter === 'new' ? 'border-ocean-600 text-ocean-600' : 'border-transparent text-gray-500 hover:text-gray-700'
                  }`}
                >
                  New ({newCount})
                  <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
                </button>
              )}
              <button
                onClick={() => setFilter('published')}
                className={`pb-3 px-1 border-b-2 font-medium text-sm transition-colors ${
                  filter === 'published' ? 'border-ocean-600 text-ocean-600' : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Published ({protocols.filter(p => p.published).length})
              </button>
              <button
                onClick={() => setFilter('draft')}
                className={`pb-3 px-1 border-b-2 font-medium text-sm transition-colors ${
                  filter === 'draft' ? 'border-ocean-600 text-ocean-600' : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Drafts ({protocols.filter(p => !p.published).length})
              </button>
            </nav>
          </div>
        )}

        {protocols.length === 0 ? (
          <div className="bg-white border-2 border-dashed border-gray-200 rounded-lg p-12 text-center">
            <h3 className="text-lg font-medium text-gray-900 mb-2">No protocols yet</h3>
            <p className="text-gray-500 mb-6">Create your first protocol or generate some with AI.</p>
            <div className="flex gap-3 justify-center">
              <button onClick={() => setShowGenerateDialog(true)} className="inline-flex items-center gap-2 bg-ocean-600 text-white px-6 py-2 rounded-lg font-medium">
                <Sparkles className="w-4 h-4" />
                Generate with AI
              </button>
              <Link href="/admin/protocols/new" className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg font-medium">
                Create Manually
              </Link>
            </div>
          </div>
        ) : (
          <div className="grid gap-4 grid-cols-1">
            {filteredProtocols.map((protocol: any) => (
              <div key={protocol.id} className="bg-white rounded-lg border border-gray-200 p-6 hover:border-ocean-300 transition-colors">
                <div className="flex items-start gap-4">
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex items-center gap-3">
                        <h3 className="text-lg font-semibold text-gray-900">{protocol.title}</h3>
                        {isNew(protocol.created_at) && (
                          <span className="px-2 py-1 text-xs font-bold rounded-full bg-green-100 text-green-700 animate-pulse">NEW</span>
                        )}
                        <span className={`px-2 py-1 text-xs font-medium rounded-full ${categoryBadgeColor(protocol.category)}`}>
                          {protocol.category?.replace(/_/g, ' ')}
                        </span>
                        <button
                          onClick={() => togglePublished(protocol.id, protocol.published)}
                          className={`px-2 py-1 text-xs font-medium rounded-full transition-colors ${
                            protocol.published
                              ? 'bg-green-100 text-green-700 hover:bg-green-200'
                              : 'bg-yellow-100 text-yellow-700 hover:bg-yellow-200'
                          }`}
                        >
                          {protocol.published ? <><CheckCircle className="w-3 h-3 inline mr-1" />Published</> : <><AlertCircle className="w-3 h-3 inline mr-1" />Draft</>}
                        </button>
                      </div>
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
                      href={`/admin/protocols/${protocol.id}`}
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
          <div>Showing {filteredProtocols.length} of {protocols.length} protocols</div>
          <Link href="/admin/scenarios" className="text-blue-600 hover:text-blue-900">← Back to Scenarios</Link>
        </div>
      </div>
    </div>
  )
}
