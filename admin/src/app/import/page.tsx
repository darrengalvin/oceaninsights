'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { ArrowLeft, Sparkles, Upload, CheckCircle, AlertCircle, RefreshCw } from 'lucide-react'

const GPT_PROMPT = `You are GPT-5.2. Act as a content architect for a **growth-focused "wellness library"** designed for **military personnel, veterans, and partner/family members**.

## GOAL
Generate a large catalogue of tappable options for predictive text that feels **positive, educational, and empowering** — NOT like a symptom checker. Avoid planting negative ideas. Use **UK English**.

## OUTPUT FORMAT (STRICT JSON)
Return ONLY valid JSON (no markdown, no commentary). Schema:

{
  "meta": {
    "batch_size": 50,
    "batch_index": 1,
    "seed": "run-001",
    "notes": "Description of this batch",
    "next_cursor": "seed=run-001;batch=2;salt=abc123"
  },
  "items": [
    {
      "id": "relationships.understand.building-trust",
      "domain": "Relationships & Connection",
      "pillar": "Understand",
      "label": "Building Trust in Relationships",
      "microcopy": "Trust takes time to build through consistent small actions. You deserve relationships where you feel safe.",
      "audience": "any",
      "disclosure_level": 1,
      "sensitivity": "normal",
      "keywords": ["trust", "safety", "relationships", "partnership", "honesty"]
    }
  ]
}

## DOMAIN LIST (MUST USE EXACT NAMES)

1. "Relationships & Connection"
2. "Family, Parenting & Home Life"
3. "Identity, Belonging & Inclusion"
4. "Grief, Change & Life Events"
5. "Calm, Confidence & Emotional Skills"
6. "Sleep, Energy & Recovery"
7. "Health, Injury & Physical Wellbeing"
8. "Money, Housing & Practical Life"
9. "Work, Purpose & Service Culture"
10. "Leadership, Boundaries & Communication"
11. "Transition, Resettlement & Civilian Life"

## PILLARS
- Understand (35%) - Educational, "how it works"
- Grow (35%) - Practical skills
- Reflect (20%) - Self-discovery questions
- Support (10%) - Crisis resources

## AUDIENCE
- any (55%) - Everyone
- service_member (20%) - Currently serving
- veteran (10%) - Former military
- partner_family (15%) - Partners/family

## THE REFRAME
✅ GOOD: "Building confidence", "Finding calm", "Understanding healthy relationships"
❌ BAD: "I'm anxious", "My partner doesn't listen", "I feel like a failure"

Write as LEARNING INTENTIONS and GROWTH AREAS, not problems.

## RUN PARAMETERS
Set these before generating:

{
  "BATCH_SIZE": 50,
  "BATCH_INDEX": 1,
  "SEED": "batch-001",
  "EXCLUDE_IDS": [],
  "EXCLUDE_LABELS": []
}

Generate exactly BATCH_SIZE items following all rules. Return ONLY the JSON object.`;

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
      // Generate via AI
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

      // Display generated JSON
      setJsonInput(JSON.stringify(generated, null, 2))

      // Auto-import
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

  const copyPrompt = () => {
    navigator.clipboard.writeText(GPT_PROMPT)
    alert('Prompt copied! Paste into ChatGPT or Claude.')
  }

  const downloadPrompt = () => {
    const blob = new Blob([GPT_PROMPT], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'gpt-content-prompt.txt'
    a.click()
  }

  const handleImport = async () => {
    setError('')
    setResult(null)
    setImporting(true)

    try {
      // Parse JSON
      let data
      try {
        data = JSON.parse(jsonInput)
      } catch (e) {
        throw new Error('Invalid JSON. Please check your input.')
      }

      // Validate format
      if (!data.items || !Array.isArray(data.items)) {
        throw new Error('Invalid format. Expected { items: [...] }')
      }

      // Import
      const res = await fetch('/api/import', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })

      const result = await res.json()
      setResult(result)

      if (result.success > 0) {
        // Clear input on success
        setJsonInput('')
      }
    } catch (err: any) {
      setError(err.message || 'Import failed')
    } finally {
      setImporting(false)
    }
  }

  const loadSample = () => {
    const sample = {
      meta: {
        batch_size: 2,
        batch_index: 1,
        seed: "sample-001",
        notes: "Sample content for testing",
        next_cursor: "seed=sample-001;batch=2"
      },
      items: [
        {
          id: "relationships.understand.communication-styles",
          domain: "Relationships & Connection",
          pillar: "Understand",
          label: "Understanding Different Communication Styles",
          microcopy: "Everyone communicates differently. Learning to recognise these patterns helps you connect better.",
          audience: "any",
          disclosure_level: 1,
          sensitivity: "normal",
          keywords: ["communication", "relationships", "understanding", "connection", "styles", "patterns", "listening", "expressing"]
        },
        {
          id: "calm.grow.breathing-techniques",
          domain: "Calm, Confidence & Emotional Skills",
          pillar: "Grow",
          label: "Simple Breathing Techniques",
          microcopy: "Your breath is a powerful tool for finding calm. These techniques work anywhere, anytime.",
          audience: "any",
          disclosure_level: 1,
          sensitivity: "normal",
          keywords: ["breathing", "calm", "anxiety", "stress", "techniques", "relaxation", "mindfulness", "tools"]
        }
      ]
    }
    setJsonInput(JSON.stringify(sample, null, 2))
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-6xl mx-auto px-6 py-4">
          <div className="flex items-center gap-4">
            <Link href="/" className="p-2 hover:bg-gray-100 rounded-lg">
              <ArrowLeft className="w-5 h-5 text-gray-600" />
            </Link>
            <div className="flex-1">
              <h1 className="text-xl font-bold text-gray-900">Import Content</h1>
              <p className="text-sm text-gray-500">Generate with GPT, paste, and import</p>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-6 py-8">
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
                Click the button below to automatically generate content using OpenAI. The AI will create positive, growth-focused guidance across all domains.
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
                  <p className="text-xs text-gray-500 mt-1">
                    How many items to generate in this batch
                  </p>
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
                  <p className="text-xs text-gray-500 mt-1">
                    Leave blank for balanced distribution across all domains
                  </p>
                </div>

                <button
                  onClick={generateContent}
                  disabled={generating}
                  className="w-full flex items-center justify-center gap-2 px-6 py-3 text-white bg-gradient-to-r from-ocean-600 to-ocean-700 rounded-lg hover:from-ocean-700 hover:to-ocean-800 disabled:opacity-50 disabled:cursor-not-allowed shadow-sm"
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

                <p className="text-xs text-gray-500 text-center">
                  AI will generate content, then automatically import as drafts
                </p>
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
                    
                    {result.errors && result.errors.length > 0 && (
                      <details className="mt-3">
                        <summary className="text-sm font-medium text-green-900 cursor-pointer">
                          View Details ({result.errors.length} items)
                        </summary>
                        <div className="mt-2 max-h-48 overflow-auto bg-white rounded p-3 text-xs text-gray-600 space-y-1">
                          {result.errors.map((err: string, i: number) => (
                            <p key={i}>• {err}</p>
                          ))}
                        </div>
                      </details>
                    )}

                    <div className="mt-4">
                      <Link
                        href="/content?filter=draft"
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

