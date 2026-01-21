'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Route, Plus, Eye, EyeOff, Pencil, Trash2, Users } from 'lucide-react'

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

  if (loading) {
    return (
      <div className="flex-1 p-8">
        <div className="max-w-6xl mx-auto">
          <p className="text-gray-500">Loading journeys...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex-1 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Content Journeys</h1>
            <p className="text-gray-500 mt-1">Curated pathways through content (e.g. "7-Day Sleep Recovery")</p>
          </div>
          <Link 
            href="/journeys/new"
            className="flex items-center gap-2 bg-ocean-600 text-white px-4 py-2 rounded-lg hover:bg-ocean-700"
          >
            <Plus className="w-4 h-4" />
            New Journey
          </Link>
        </div>

        {journeys.length === 0 ? (
          <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
            <Route className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No journeys yet</h3>
            <p className="text-gray-500 mb-6">Create your first curated content pathway</p>
            <Link
              href="/journeys/new"
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
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">
                      {journey.title}
                    </h3>
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
                    href={`/journeys/${journey.id}`}
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
      </div>
    </div>
  )
}

