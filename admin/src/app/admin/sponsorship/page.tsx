'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import {
  Building2,
  Plus,
  Search,
  KeyRound,
  CheckCircle2,
  Clock,
  Users,
  RefreshCw,
} from 'lucide-react'
import {
  type OrganizationWithStats,
  ORG_TYPE_LABELS,
  ORG_TYPE_COLORS,
} from '@/lib/sponsorship'

export default function SponsorshipPage() {
  const [orgs, setOrgs] = useState<OrganizationWithStats[]>([])
  const [loading, setLoading] = useState(true)
  const [query, setQuery] = useState('')

  useEffect(() => {
    fetchOrgs()
  }, [])

  async function fetchOrgs() {
    setLoading(true)
    try {
      const res = await fetch('/api/organizations')
      const data = await res.json()
      setOrgs(Array.isArray(data) ? data : [])
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const totals = orgs.reduce(
    (acc, o) => {
      acc.orgs += 1
      acc.recipients += o.recipients_total ?? 0
      acc.redeemed += o.recipients_redeemed ?? 0
      acc.seats += o.seats_purchased
      return acc
    },
    { orgs: 0, recipients: 0, redeemed: 0, seats: 0 }
  )

  const filtered = orgs.filter((o) => {
    if (!query) return true
    const q = query.toLowerCase()
    return (
      o.name.toLowerCase().includes(q) ||
      o.contact_email?.toLowerCase().includes(q) ||
      o.contact_name?.toLowerCase().includes(q)
    )
  })

  return (
    <div className="p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Sponsorship</h2>
            <p className="text-gray-500">Organisations sponsoring free access for their members</p>
          </div>

          <div className="flex gap-3">
            <button
              onClick={fetchOrgs}
              className="flex items-center gap-2 px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
            >
              <RefreshCw className="w-4 h-4" />
              Refresh
            </button>
            <Link
              href="/admin/sponsorship/new"
              className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 rounded-lg hover:bg-ocean-700"
            >
              <Plus className="w-4 h-4" />
              New Organisation
            </Link>
          </div>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <StatCard icon={Building2} label="Sponsors" value={totals.orgs} tint="ocean" />
          <StatCard icon={KeyRound} label="Seats Purchased" value={totals.seats} tint="emerald" />
          <StatCard icon={Users} label="People Invited" value={totals.recipients} tint="blue" />
          <StatCard icon={CheckCircle2} label="People Active" value={totals.redeemed} tint="purple" />
        </div>

        <div className="mb-4">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search by name, contact, email..."
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none"
            />
          </div>
        </div>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="w-8 h-8 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
          </div>
        ) : filtered.length === 0 ? (
          <EmptyState hasQuery={!!query} />
        ) : (
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                    Organisation
                  </th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                    Type
                  </th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                    Contract
                  </th>
                  <th className="text-right px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                    People
                  </th>
                  <th className="text-right px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                    Billing
                  </th>
                  <th className="text-right px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                    Status
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filtered.map((o) => (
                  <tr key={o.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3">
                      <Link
                        href={`/admin/sponsorship/${o.id}`}
                        className="font-medium text-gray-900 hover:text-ocean-700"
                      >
                        {o.name}
                      </Link>
                      {o.contact_email && (
                        <div className="text-xs text-gray-500">{o.contact_email}</div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={`inline-block px-2 py-1 rounded-md text-xs font-medium border ${
                          ORG_TYPE_COLORS[o.type]
                        }`}
                      >
                        {ORG_TYPE_LABELS[o.type]}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      {o.contract_ends_on ? (
                        <span className="flex items-center gap-1.5">
                          <Clock className="w-3.5 h-3.5 text-gray-400" />
                          Ends {formatDate(o.contract_ends_on)}
                        </span>
                      ) : (
                        <span className="text-gray-400">No end date</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right text-sm">
                      <div className="font-medium text-gray-900">
                        {o.recipients_redeemed} / {o.recipients_total}
                      </div>
                      <div className="text-xs text-gray-500">
                        {Math.max(0, (o.recipients_total ?? 0) - (o.recipients_redeemed ?? 0))} pending
                      </div>
                    </td>
                    <td className="px-4 py-3 text-right text-sm">
                      <div className="text-xs text-gray-700">
                        {o.billing_mode === 'prepaid' ? 'Prepaid' : 'Postpaid'}
                      </div>
                      <div className="text-xs text-gray-500">
                        {o.seats_redeemed} / {o.seats_purchased} seats
                      </div>
                    </td>
                    <td className="px-4 py-3 text-right">
                      {o.is_active ? (
                        <span className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium bg-green-50 text-green-700 border border-green-200">
                          Active
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium bg-gray-100 text-gray-600 border border-gray-200">
                          Inactive
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}

function StatCard({
  icon: Icon,
  label,
  value,
  tint,
}: {
  icon: React.ElementType
  label: string
  value: number
  tint: 'ocean' | 'emerald' | 'blue' | 'purple'
}) {
  const tints: Record<string, string> = {
    ocean: 'bg-ocean-50 text-ocean-700',
    emerald: 'bg-emerald-50 text-emerald-700',
    blue: 'bg-blue-50 text-blue-700',
    purple: 'bg-purple-50 text-purple-700',
  }
  return (
    <div className="bg-white border border-gray-200 rounded-xl p-4">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-2xl font-bold text-gray-900">{value}</div>
          <div className="text-xs text-gray-500 uppercase tracking-wider mt-1">{label}</div>
        </div>
        <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${tints[tint]}`}>
          <Icon className="w-5 h-5" />
        </div>
      </div>
    </div>
  )
}

function EmptyState({ hasQuery }: { hasQuery: boolean }) {
  return (
    <div className="bg-white border border-gray-200 rounded-xl p-12 text-center">
      <Building2 className="w-12 h-12 text-gray-300 mx-auto mb-4" />
      <h3 className="text-lg font-semibold text-gray-900 mb-1">
        {hasQuery ? 'No matches' : 'No sponsoring organisations yet'}
      </h3>
      <p className="text-gray-500 mb-6">
        {hasQuery
          ? 'Try a different search term.'
          : 'Add a sponsor (military unit, school, charity) to start generating access codes.'}
      </p>
      {!hasQuery && (
        <Link
          href="/admin/sponsorship/new"
          className="inline-flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 rounded-lg hover:bg-ocean-700"
        >
          <Plus className="w-4 h-4" />
          Add First Organisation
        </Link>
      )}
    </div>
  )
}

function formatDate(iso: string): string {
  try {
    return new Date(iso).toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    })
  } catch {
    return iso
  }
}
