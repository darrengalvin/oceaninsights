'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Folders, Plus, Eye, EyeOff, Pencil, Trash2 } from 'lucide-react'

interface Domain {
  id: string
  slug: string
  name: string
  description: string | null
  icon: string
  display_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export default function DomainsPage() {
  const [domains, setDomains] = useState<Domain[]>([])
  const [loading, setLoading] = useState(true)

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
    } finally {
      setLoading(false)
    }
  }

  const toggleActive = async (domain: Domain) => {
    try {
      await fetch(`/api/domains/${domain.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_active: !domain.is_active })
      })
      fetchDomains()
    } catch (error) {
      console.error('Failed to toggle domain:', error)
    }
  }

  if (loading) {
    return (
      <div className="flex-1 p-8">
        <div className="max-w-6xl mx-auto">
          <p className="text-gray-500">Loading domains...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex-1 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Life Area Domains</h1>
            <p className="text-gray-500 mt-1">Manage the 11 core life areas for content organisation</p>
          </div>
          <Link 
            href="/domains/new"
            className="flex items-center gap-2 bg-ocean-600 text-white px-4 py-2 rounded-lg hover:bg-ocean-700"
          >
            <Plus className="w-4 h-4" />
            New Domain
          </Link>
        </div>

        <div className="bg-white rounded-lg border border-gray-200">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Order
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Icon
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Description
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
              {domains.map((domain) => (
                <tr key={domain.id} className={!domain.is_active ? 'opacity-50' : ''}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {domain.display_order}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-2xl">
                    {domain.icon}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{domain.name}</div>
                    <div className="text-sm text-gray-500">{domain.slug}</div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500 max-w-md">
                    {domain.description || '—'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <button
                      onClick={() => toggleActive(domain)}
                      className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        domain.is_active
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {domain.is_active ? (
                        <>
                          <Eye className="w-3 h-3" />
                          Active
                        </>
                      ) : (
                        <>
                          <EyeOff className="w-3 h-3" />
                          Inactive
                        </>
                      )}
                    </button>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <Link
                      href={`/domains/${domain.id}`}
                      className="text-ocean-600 hover:text-ocean-900 mr-4"
                    >
                      <Pencil className="w-4 h-4 inline" />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

