'use client'

import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, AlertTriangle } from 'lucide-react'

interface PerspectiveShift {
  perspective: string
  interpretation: string
}

interface ScenarioOption {
  id?: string
  text: string
  tags: string[]
  immediate_outcome: string
  longterm_outcome: string
  risk_level: 'low' | 'medium' | 'high'
  perspective_shifts: PerspectiveShift[]
}

interface Scenario {
  id: string
  title: string
  situation: string
  context: string
  difficulty: number
  tags: string[]
  published: boolean
  options: ScenarioOption[]
}

export default function PreviewScenarioPage() {
  const params = useParams()
  const [loading, setLoading] = useState(true)
  const [scenario, setScenario] = useState<Scenario | null>(null)
  const [selectedOption, setSelectedOption] = useState<number | null>(null)
  const [showFeedback, setShowFeedback] = useState(false)

  useEffect(() => {
    if (params.id) {
      fetchScenario(params.id as string)
    }
  }, [params.id])

  const fetchScenario = async (id: string) => {
    try {
      const res = await fetch(`/api/scenarios/${id}`)
      const data = await res.json()
      setScenario(data)
    } catch (error) {
      console.error('Failed to fetch scenario:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleOptionSelect = (index: number) => {
    setSelectedOption(index)
    setShowFeedback(true)
  }

  const resetScenario = () => {
    setSelectedOption(null)
    setShowFeedback(false)
  }

  const getRiskColor = (level: string) => {
    switch (level) {
      case 'low': return 'text-green-700 bg-green-100'
      case 'medium': return 'text-yellow-700 bg-yellow-100'
      case 'high': return 'text-red-700 bg-red-100'
      default: return 'text-gray-700 bg-gray-100'
    }
  }

  if (loading) {
    return (
      <div className="flex-1 p-8">
        <p className="text-gray-500">Loading preview...</p>
      </div>
    )
  }

  if (!scenario) {
    return (
      <div className="flex-1 p-8">
        <p className="text-red-600">Scenario not found</p>
      </div>
    )
  }

  return (
    <div className="flex-1 p-8 max-w-4xl mx-auto">
      <div className="mb-6">
        <Link href={`/scenarios/${params.id}`} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4">
          <ArrowLeft className="w-4 h-4" />
          Back to Edit
        </Link>
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
          <p className="text-sm text-blue-800">
            <strong>Preview Mode:</strong> This is how the scenario will appear to users in the app.
          </p>
        </div>
      </div>

      {/* Scenario Display */}
      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-ocean-600 to-ocean-700 p-6 text-white">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-sm opacity-80">Decision Training</span>
            <span className="text-sm opacity-60">•</span>
            <span className="text-sm opacity-80">Difficulty: {'★'.repeat(scenario.difficulty)}{'☆'.repeat(3 - scenario.difficulty)}</span>
          </div>
          <h1 className="text-2xl font-bold">{scenario.title}</h1>
        </div>

        {/* Situation */}
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-sm font-semibold text-gray-500 uppercase mb-2">Situation</h2>
          <p className="text-gray-800 leading-relaxed">{scenario.situation}</p>
        </div>

        {/* Options */}
        {!showFeedback && (
          <div className="p-6">
            <h2 className="text-sm font-semibold text-gray-500 uppercase mb-4">How would you respond?</h2>
            <div className="space-y-3">
              {scenario.options.map((option, index) => (
                <button
                  key={index}
                  onClick={() => handleOptionSelect(index)}
                  className="w-full text-left p-4 border-2 border-gray-200 rounded-lg hover:border-ocean-500 hover:bg-ocean-50 transition-all"
                >
                  <p className="text-gray-800">{option.text}</p>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Feedback */}
        {showFeedback && selectedOption !== null && (
          <div className="p-6 space-y-6">
            <div>
              <h2 className="text-sm font-semibold text-gray-500 uppercase mb-2">Your Choice</h2>
              <div className="bg-ocean-50 border border-ocean-200 rounded-lg p-4">
                <p className="text-gray-800">{scenario.options[selectedOption].text}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-2">⚡ Immediate Outcome</h3>
                <p className="text-gray-600 text-sm">{scenario.options[selectedOption].immediate_outcome}</p>
              </div>
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-2">🔮 Long-term Outcome</h3>
                <p className="text-gray-600 text-sm">{scenario.options[selectedOption].longterm_outcome}</p>
              </div>
            </div>

            <div>
              <div className="flex items-center gap-2 mb-3">
                <AlertTriangle className="w-4 h-4 text-gray-500" />
                <h3 className="text-sm font-semibold text-gray-700">Risk Assessment</h3>
              </div>
              <span className={`inline-flex px-3 py-1 text-sm font-medium rounded-full ${getRiskColor(scenario.options[selectedOption].risk_level)}`}>
                {scenario.options[selectedOption].risk_level.toUpperCase()} RISK
              </span>
            </div>

            {scenario.options[selectedOption].perspective_shifts?.length > 0 && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3">👁️ How Others Might See This</h3>
                <div className="space-y-3">
                  {scenario.options[selectedOption].perspective_shifts.map((shift, idx) => (
                    <div key={idx} className="bg-gray-50 border border-gray-200 rounded-lg p-3">
                      <p className="text-sm font-medium text-gray-900 mb-1">{shift.perspective}</p>
                      <p className="text-sm text-gray-600">{shift.interpretation}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="flex gap-3 pt-4 border-t border-gray-200">
              <button
                onClick={resetScenario}
                className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
              >
                Try Different Response
              </button>
              <Link
                href={`/scenarios/${params.id}`}
                className="flex-1 px-4 py-2 bg-ocean-600 text-white rounded-lg hover:bg-ocean-700 text-center"
              >
                Back to Edit
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

