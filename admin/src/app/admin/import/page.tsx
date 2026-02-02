'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { ArrowLeft, Sparkles, Upload, CheckCircle, AlertCircle, RefreshCw } from 'lucide-react'

export default function ImportPage() {
  const [jsonInput, setJsonInput] = useState('')
  const [importing, setImporting] = useState(false)
  const [generating, setGenerating] = useState(false)
  const [result, setResult] = useState<any>(null)
  const [error, setError] = useState('')
  const [batchSize, setBatchSize] = useState(20)
  const [focusDomain, setFocusDomain] = useState('')
  const [domains, setDomains] = useState<any[]>([])

  useEffect(() => {
    fetchDomains()
  }, [])

  const fetchDomains = async () => {
    try {
      const res = await fetch('/api/domains')
      const data = await res.json()
      setDomains(data)
    } catch (error) {
      console.error('Failed to fetch domains:', error)
    }
  }

  const generateContent = async () => {
    setError('')
    setResult(null)
    setGenerating(true)

    try {
      const genRes = await fetch('/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          batchSize,
          focusDomain,
        }),
      })

      if (!genRes.ok) {
        const errData = await genRes.json()
        throw new Error(errData.error || 'Generation failed')
      }

      const generated = await genRes.json()
      
      if (!generated.items || !Array.isArray(generated.items)) {
        throw new Error('Invalid response from AI')
      }

      setJsonInput(JSON.stringify(generated, null, 2))

      const importRes = await fetch('/api/import', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(generated),
      })

      const importResult = await importRes.json()
      setResult(importResult)

    } catch (err: any) {
      setError(err.message || 'Generation failed')
    } finally {
      setGenerating(false)
    }
  }

  const handleImport = async () => {
    setError('')
    setResult(null)
    setImporting(true)

    try {
      let data
      try {
        data = JSON.parse(jsonInput)
      } catch (e) {
        throw new Error('Invalid JSON. Please check your input.')
      }

      if (!data.items || !Array.isArray(data.items)) {
        throw new Error('Invalid format. Expected { items: [...] }')
      }

      const res = await fetch('/api/import', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })

      const result = await res.json()
      setResult(result)

      if (result.success > 0) {
        setJsonInput('')
      }
    } catch (err: any) {
      setError(err.message || 'Import failed')
    } finally {
      setImporting(false)
    }
  }

  return (
    <div className="p-8">
      <div className="max-w-6xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Import Content</h1>
          <p className="text-sm text-gray-500">Generate with AI or paste JSON to import</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Left: AI Generation */}
          <div className="space-y-6">
            <div className="bg-white rounded-xl border border-gray-200 p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                <span className="flex items-center gap-2">
                  <Sparkles className="w-5 h-5 text-ocean-600" />
                  AI Content Generator
                </span>
              </h2>
              
              <p className="text-sm text-gray-600 mb-4">
                Generate positive, growth-focused guidance using AI across all domains.
              </p>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Batch Size
                  </label>
                  <select
                    value={batchSize}
                    onChange={(e) => setBatchSize(parseInt(e.target.value))}
                    className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                  >
                    <option value={10}>10 items</option>
                    <option value={20}>20 items (recommended)</option>
                    <option value={30}>30 items</option>
                    <option value={50}>50 items</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Focus Domain (Optional)
                  </label>
                  <select
                    value={focusDomain}
                    onChange={(e) => setFocusDomain(e.target.value)}
                    className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
                  >
                    <option value="">All Domains (Balanced)</option>
                    {domains.map(domain => (
                      <option key={domain.id} value={domain.name}>
                        {domain.name}
                      </option>
                    ))}
                  </select>
                </div>

                <button
                  onClick={generateContent}
                  disabled={generating}
                  className="w-full flex items-center justify-center gap-2 px-6 py-3 text-white bg-ocean-600 rounded-lg hover:bg-ocean-700 disabled:opacity-50"
                >
                  {generating ? (
                    <>
                      <RefreshCw className="w-5 h-5 animate-spin" />
                      Generating {batchSize} items...
                    </>
                  ) : (
                    <>
                      <Sparkles className="w-5 h-5" />
                      Generate & Import
                    </>
                  )}
                </button>
              </div>
            </div>

            {/* Domain Reference */}
            <div className="bg-white rounded-xl border border-gray-200 p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">11 Domains</h2>
              <div className="space-y-1 text-sm text-gray-600">
                <p>✓ Relationships & Connection</p>
                <p>✓ Family, Parenting & Home Life</p>
                <p>✓ Identity, Belonging & Inclusion</p>
                <p>✓ Grief, Change & Life Events</p>
                <p>✓ Calm, Confidence & Emotional Skills</p>
                <p>✓ Sleep, Energy & Recovery</p>
                <p>✓ Health, Injury & Physical Wellbeing</p>
                <p>✓ Money, Housing & Practical Life</p>
                <p>✓ Work, Purpose & Service Culture</p>
                <p>✓ Leadership, Boundaries & Communication</p>
                <p>✓ Transition, Resettlement & Civilian Life</p>
              </div>
            </div>
          </div>

          {/* Right: Preview & Results */}
          <div className="space-y-6">
            <div className="bg-white rounded-xl border border-gray-200 p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Generated Content</h2>
              
              {jsonInput ? (
                <textarea
                  value={jsonInput}
                  onChange={(e) => setJsonInput(e.target.value)}
                  rows={16}
                  className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500 font-mono text-sm bg-gray-50"
                  readOnly
                />
              ) : (
                <div className="flex items-center justify-center h-64 border-2 border-dashed border-gray-200 rounded-lg">
                  <p className="text-gray-400 text-sm">
                    Generated content will appear here
                  </p>
                </div>
              )}
            </div>

            {/* Results */}
            {error && (
              <div className="bg-red-50 border border-red-200 rounded-xl p-4">
                <div className="flex items-start gap-3">
                  <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="font-medium text-red-900">Import Failed</p>
                    <p className="text-sm text-red-700 mt-1">{error}</p>
                  </div>
                </div>
              </div>
            )}

            {result && (
              <div className="bg-green-50 border border-green-200 rounded-xl p-4">
                <div className="flex items-start gap-3">
                  <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
                  <div className="flex-1">
                    <p className="font-medium text-green-900">Import Complete!</p>
                    <div className="mt-2 space-y-1 text-sm text-green-700">
                      <p>✓ Imported: {result.success} items</p>
                      <p>→ Skipped: {result.skipped} items (already exist)</p>
                      {result.failed > 0 && <p>✗ Failed: {result.failed} items</p>}
                    </div>
                    
                    <div className="mt-4">
                      <Link
                        href="/admin/content?filter=draft"
                        className="inline-flex items-center gap-2 text-sm text-green-700 hover:text-green-800 font-medium"
                      >
                        Review Drafts →
                      </Link>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
