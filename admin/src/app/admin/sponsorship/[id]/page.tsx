'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import {
  ArrowLeft,
  Building2,
  KeyRound,
  Plus,
  Save,
  Download,
  Trash2,
  CheckCircle2,
  XCircle,
  Mail,
  Phone,
  Calendar,
  AlertCircle,
  Copy,
} from 'lucide-react'
import {
  type Organization,
  type AccessCode,
  type OrganizationType,
  ORG_TYPE_LABELS,
  ORG_TYPE_COLORS,
} from '@/lib/sponsorship'

interface OrgDetail extends Organization {
  codes: AccessCode[]
  stats: { total: number; redeemed: number; active_unredeemed: number }
}

export default function OrganizationDetailPage() {
  const params = useParams<{ id: string }>()
  const router = useRouter()
  const id = params?.id

  const [org, setOrg] = useState<OrgDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [tab, setTab] = useState<'codes' | 'details'>('codes')
  const [showGenerator, setShowGenerator] = useState(false)
  const [showOnlyUnredeemed, setShowOnlyUnredeemed] = useState(false)

  useEffect(() => {
    if (id) load()
  }, [id])

  async function load() {
    setLoading(true)
    try {
      const res = await fetch(`/api/organizations/${id}`)
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to load')
      setOrg(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err))
    } finally {
      setLoading(false)
    }
  }

  async function saveOrg(updates: Partial<Organization>) {
    if (!org) return
    setSaving(true)
    setError(null)
    try {
      const res = await fetch(`/api/organizations/${org.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Save failed')
      setOrg((prev) => (prev ? { ...prev, ...data } : prev))
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err))
    } finally {
      setSaving(false)
    }
  }

  async function deleteOrg() {
    if (!org) return
    if (
      !confirm(
        `Delete "${org.name}"? This will permanently delete all ${org.codes.length} of their codes.`
      )
    )
      return
    const res = await fetch(`/api/organizations/${org.id}`, { method: 'DELETE' })
    if (res.ok) router.push('/admin/sponsorship')
  }

  if (loading)
    return (
      <div className="flex items-center justify-center h-96">
        <div className="w-8 h-8 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
      </div>
    )

  if (!org)
    return (
      <div className="p-8">
        <div className="max-w-3xl mx-auto bg-red-50 border border-red-200 rounded-xl p-6">
          <p className="text-red-700">{error || 'Organisation not found'}</p>
          <Link href="/admin/sponsorship" className="text-ocean-600 underline mt-2 inline-block">
            Back to sponsors
          </Link>
        </div>
      </div>
    )

  const visibleCodes = showOnlyUnredeemed
    ? org.codes.filter((c) => !c.redeemed_at)
    : org.codes

  return (
    <div className="p-8">
      <div className="max-w-6xl mx-auto">
        <Link
          href="/admin/sponsorship"
          className="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700 mb-4"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to sponsors
        </Link>

        <div className="flex items-start justify-between mb-6">
          <div className="flex items-start gap-4">
            <div className="w-14 h-14 rounded-xl bg-ocean-50 flex items-center justify-center">
              <Building2 className="w-7 h-7 text-ocean-700" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900">{org.name}</h2>
              <div className="flex items-center gap-2 mt-1.5">
                <span
                  className={`inline-block px-2 py-0.5 rounded-md text-xs font-medium border ${ORG_TYPE_COLORS[org.type]}`}
                >
                  {ORG_TYPE_LABELS[org.type]}
                </span>
                {org.is_active ? (
                  <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-medium bg-green-50 text-green-700 border border-green-200">
                    <CheckCircle2 className="w-3 h-3" />
                    Active
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-medium bg-gray-100 text-gray-600 border border-gray-200">
                    <XCircle className="w-3 h-3" />
                    Inactive
                  </span>
                )}
              </div>
            </div>
          </div>
          <button
            onClick={deleteOrg}
            className="flex items-center gap-2 px-3 py-1.5 text-sm text-red-600 border border-red-200 rounded-lg hover:bg-red-50"
          >
            <Trash2 className="w-4 h-4" />
            Delete
          </button>
        </div>

        <div className="grid grid-cols-3 gap-4 mb-6">
          <StatBox
            label="Codes Generated"
            value={org.stats.total}
            icon={KeyRound}
            tint="bg-blue-50 text-blue-700"
          />
          <StatBox
            label="Redeemed"
            value={org.stats.redeemed}
            icon={CheckCircle2}
            tint="bg-emerald-50 text-emerald-700"
          />
          <StatBox
            label="Available"
            value={org.stats.active_unredeemed}
            icon={Plus}
            tint="bg-amber-50 text-amber-700"
          />
        </div>

        <div className="border-b border-gray-200 mb-6">
          <div className="flex gap-6">
            <TabButton active={tab === 'codes'} onClick={() => setTab('codes')}>
              Access Codes ({org.codes.length})
            </TabButton>
            <TabButton active={tab === 'details'} onClick={() => setTab('details')}>
              Details
            </TabButton>
          </div>
        </div>

        {error && (
          <div className="mb-4 flex items-start gap-2 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
            <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {tab === 'codes' ? (
          <CodesPanel
            org={org}
            codes={visibleCodes}
            onReload={load}
            showGenerator={showGenerator}
            setShowGenerator={setShowGenerator}
            showOnlyUnredeemed={showOnlyUnredeemed}
            setShowOnlyUnredeemed={setShowOnlyUnredeemed}
          />
        ) : (
          <DetailsPanel org={org} onSave={saveOrg} saving={saving} />
        )}
      </div>
    </div>
  )
}

function StatBox({
  label,
  value,
  icon: Icon,
  tint,
}: {
  label: string
  value: number
  icon: React.ElementType
  tint: string
}) {
  return (
    <div className="bg-white border border-gray-200 rounded-xl p-4 flex items-center justify-between">
      <div>
        <div className="text-2xl font-bold text-gray-900">{value}</div>
        <div className="text-xs text-gray-500 uppercase tracking-wider mt-1">{label}</div>
      </div>
      <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${tint}`}>
        <Icon className="w-5 h-5" />
      </div>
    </div>
  )
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean
  onClick: () => void
  children: React.ReactNode
}) {
  return (
    <button
      onClick={onClick}
      className={`pb-3 text-sm font-medium border-b-2 transition-colors ${
        active
          ? 'text-ocean-700 border-ocean-600'
          : 'text-gray-500 border-transparent hover:text-gray-700'
      }`}
    >
      {children}
    </button>
  )
}

function CodesPanel({
  org,
  codes,
  onReload,
  showGenerator,
  setShowGenerator,
  showOnlyUnredeemed,
  setShowOnlyUnredeemed,
}: {
  org: OrgDetail
  codes: AccessCode[]
  onReload: () => void
  showGenerator: boolean
  setShowGenerator: (b: boolean) => void
  showOnlyUnredeemed: boolean
  setShowOnlyUnredeemed: (b: boolean) => void
}) {
  function downloadCsv() {
    const header = 'Code,Status,Batch,Created,Expires\n'
    const rows = codes
      .map((c) => {
        const status = c.redeemed_at ? 'Redeemed' : c.is_active ? 'Available' : 'Deactivated'
        return [
          c.code,
          status,
          c.batch_label || '',
          c.created_at?.slice(0, 10) || '',
          c.expires_at?.slice(0, 10) || '',
        ].join(',')
      })
      .join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${org.slug}-codes-${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
    URL.revokeObjectURL(url)
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
          <button
            onClick={() => setShowGenerator(!showGenerator)}
            className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 rounded-lg"
          >
            <Plus className="w-4 h-4" />
            Generate Codes
          </button>
          <label className="flex items-center gap-2 text-sm text-gray-600">
            <input
              type="checkbox"
              checked={showOnlyUnredeemed}
              onChange={(e) => setShowOnlyUnredeemed(e.target.checked)}
              className="rounded border-gray-300 text-ocean-600 focus:ring-ocean-500"
            />
            Only show unredeemed
          </label>
        </div>
        {codes.length > 0 && (
          <button
            onClick={downloadCsv}
            className="flex items-center gap-2 px-3 py-1.5 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
          >
            <Download className="w-4 h-4" />
            Export CSV
          </button>
        )}
      </div>

      {showGenerator && (
        <CodeGenerator
          orgId={org.id}
          onComplete={() => {
            setShowGenerator(false)
            onReload()
          }}
        />
      )}

      {codes.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-xl p-12 text-center">
          <KeyRound className="w-12 h-12 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 mb-1">No codes yet</h3>
          <p className="text-gray-500">Generate a batch of codes to share with this sponsor.</p>
        </div>
      ) : (
        <div className="bg-white border border-gray-200 rounded-xl overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Code
                </th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Batch
                </th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Status
                </th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Created
                </th>
                <th />
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {codes.map((c) => (
                <CodeRow key={c.id} code={c} onChange={onReload} />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

function CodeRow({ code, onChange }: { code: AccessCode; onChange: () => void }) {
  const [copied, setCopied] = useState(false)

  async function copy() {
    await navigator.clipboard.writeText(code.code)
    setCopied(true)
    setTimeout(() => setCopied(false), 1500)
  }

  async function toggleActive() {
    await fetch(`/api/access-codes/${code.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_active: !code.is_active }),
    })
    onChange()
  }

  async function remove() {
    if (!confirm(`Delete code ${code.code}?`)) return
    await fetch(`/api/access-codes/${code.id}`, { method: 'DELETE' })
    onChange()
  }

  return (
    <tr className="hover:bg-gray-50">
      <td className="px-4 py-3">
        <div className="flex items-center gap-2">
          <code className="font-mono text-sm font-medium text-gray-900">{code.code}</code>
          <button
            onClick={copy}
            className="text-gray-400 hover:text-gray-700"
            title="Copy code"
          >
            {copied ? (
              <CheckCircle2 className="w-3.5 h-3.5 text-green-600" />
            ) : (
              <Copy className="w-3.5 h-3.5" />
            )}
          </button>
        </div>
      </td>
      <td className="px-4 py-3 text-sm text-gray-600">{code.batch_label || '-'}</td>
      <td className="px-4 py-3">
        {code.redeemed_at ? (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-200">
            Redeemed
          </span>
        ) : code.is_active ? (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200">
            Available
          </span>
        ) : (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-medium bg-gray-100 text-gray-600 border border-gray-200">
            Deactivated
          </span>
        )}
        {code.redeemed_at && (
          <div className="text-xs text-gray-500 mt-0.5">
            {new Date(code.redeemed_at).toLocaleDateString('en-GB')}
          </div>
        )}
      </td>
      <td className="px-4 py-3 text-sm text-gray-600">
        {code.created_at ? new Date(code.created_at).toLocaleDateString('en-GB') : '-'}
      </td>
      <td className="px-4 py-3 text-right">
        <div className="flex items-center justify-end gap-2">
          {!code.redeemed_at && (
            <button
              onClick={toggleActive}
              className="px-2 py-1 text-xs text-gray-600 border border-gray-200 rounded hover:bg-gray-50"
            >
              {code.is_active ? 'Deactivate' : 'Activate'}
            </button>
          )}
          <button onClick={remove} className="p-1 text-gray-400 hover:text-red-600">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </td>
    </tr>
  )
}

function CodeGenerator({ orgId, onComplete }: { orgId: string; onComplete: () => void }) {
  const [quantity, setQuantity] = useState(50)
  const [batchLabel, setBatchLabel] = useState('')
  const [expiresAt, setExpiresAt] = useState('')
  const [prefix, setPrefix] = useState('BTS')
  const [generating, setGenerating] = useState(false)
  const [generated, setGenerated] = useState<{ code: string }[] | null>(null)
  const [error, setError] = useState<string | null>(null)

  async function generate() {
    setError(null)
    setGenerating(true)
    try {
      const res = await fetch('/api/access-codes/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          organization_id: orgId,
          quantity,
          batch_label: batchLabel.trim() || null,
          expires_at: expiresAt || null,
          prefix,
        }),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Generation failed')
      setGenerated(data.codes)
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err))
    } finally {
      setGenerating(false)
    }
  }

  function downloadGenerated() {
    if (!generated) return
    const csv = 'Code\n' + generated.map((c) => c.code).join('\n')
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `codes-${batchLabel || 'batch'}-${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
    URL.revokeObjectURL(url)
  }

  if (generated) {
    return (
      <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-5 mb-4">
        <div className="flex items-center gap-2 mb-3">
          <CheckCircle2 className="w-5 h-5 text-emerald-700" />
          <h3 className="font-semibold text-emerald-900">
            Generated {generated.length} codes
          </h3>
        </div>
        <div className="bg-white border border-emerald-200 rounded-lg p-3 max-h-48 overflow-y-auto font-mono text-xs">
          {generated.map((c) => (
            <div key={c.code}>{c.code}</div>
          ))}
        </div>
        <div className="flex gap-2 mt-3">
          <button
            onClick={downloadGenerated}
            className="flex items-center gap-2 px-3 py-1.5 text-sm text-white bg-emerald-700 hover:bg-emerald-800 rounded-lg"
          >
            <Download className="w-4 h-4" />
            Download CSV
          </button>
          <button
            onClick={onComplete}
            className="px-3 py-1.5 text-sm text-emerald-800 border border-emerald-300 rounded-lg hover:bg-emerald-100"
          >
            Done
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-white border border-gray-200 rounded-xl p-5 mb-4">
      <h3 className="font-semibold text-gray-900 mb-4">Generate Code Batch</h3>
      <div className="grid grid-cols-2 gap-4 mb-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Quantity</label>
          <input
            type="number"
            min={1}
            max={1000}
            value={quantity}
            onChange={(e) => setQuantity(parseInt(e.target.value || '0', 10))}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Code prefix</label>
          <input
            value={prefix}
            onChange={(e) => setPrefix(e.target.value.toUpperCase().slice(0, 8))}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none font-mono"
            placeholder="BTS"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Batch label</label>
          <input
            value={batchLabel}
            onChange={(e) => setBatchLabel(e.target.value)}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none"
            placeholder="e.g. Q2 2026"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Codes expire on</label>
          <input
            type="date"
            value={expiresAt}
            onChange={(e) => setExpiresAt(e.target.value)}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none"
          />
        </div>
      </div>

      {error && (
        <div className="flex items-start gap-2 p-3 mb-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}

      <button
        onClick={generate}
        disabled={generating || quantity < 1}
        className="px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 disabled:bg-ocean-400 rounded-lg"
      >
        {generating ? 'Generating...' : `Generate ${quantity} codes`}
      </button>
    </div>
  )
}

function DetailsPanel({
  org,
  onSave,
  saving,
}: {
  org: OrgDetail
  onSave: (updates: Partial<Organization>) => Promise<void>
  saving: boolean
}) {
  const [form, setForm] = useState({
    name: org.name,
    type: org.type,
    contact_name: org.contact_name || '',
    contact_email: org.contact_email || '',
    contact_phone: org.contact_phone || '',
    contract_starts_on: org.contract_starts_on || '',
    contract_ends_on: org.contract_ends_on || '',
    seats_purchased: org.seats_purchased,
    notes: org.notes || '',
    is_active: org.is_active,
  })

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }))
  }

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        onSave(form)
      }}
      className="bg-white border border-gray-200 rounded-xl p-6 space-y-5"
    >
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
          <input
            value={form.name}
            onChange={(e) => set('name', e.target.value)}
            className={inputClass}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
          <select
            value={form.type}
            onChange={(e) => set('type', e.target.value as OrganizationType)}
            className={inputClass}
          >
            {(Object.keys(ORG_TYPE_LABELS) as OrganizationType[]).map((t) => (
              <option key={t} value={t}>
                {ORG_TYPE_LABELS[t]}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            <Mail className="w-3.5 h-3.5 inline mr-1" /> Contact email
          </label>
          <input
            type="email"
            value={form.contact_email}
            onChange={(e) => set('contact_email', e.target.value)}
            className={inputClass}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            <Phone className="w-3.5 h-3.5 inline mr-1" /> Contact phone
          </label>
          <input
            value={form.contact_phone}
            onChange={(e) => set('contact_phone', e.target.value)}
            className={inputClass}
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Contact name</label>
        <input
          value={form.contact_name}
          onChange={(e) => set('contact_name', e.target.value)}
          className={inputClass}
        />
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            <Calendar className="w-3.5 h-3.5 inline mr-1" /> Contract starts
          </label>
          <input
            type="date"
            value={form.contract_starts_on}
            onChange={(e) => set('contract_starts_on', e.target.value)}
            className={inputClass}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Contract ends</label>
          <input
            type="date"
            value={form.contract_ends_on}
            onChange={(e) => set('contract_ends_on', e.target.value)}
            className={inputClass}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Seats purchased</label>
          <input
            type="number"
            min={0}
            value={form.seats_purchased}
            onChange={(e) => set('seats_purchased', parseInt(e.target.value || '0', 10))}
            className={inputClass}
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Notes</label>
        <textarea
          value={form.notes}
          onChange={(e) => set('notes', e.target.value)}
          className={`${inputClass} min-h-[80px]`}
        />
      </div>

      <label className="flex items-center gap-2 text-sm text-gray-700">
        <input
          type="checkbox"
          checked={form.is_active}
          onChange={(e) => set('is_active', e.target.checked)}
          className="rounded border-gray-300 text-ocean-600 focus:ring-ocean-500"
        />
        Sponsor is active (uncheck to revoke all codes for this org)
      </label>

      <button
        type="submit"
        disabled={saving}
        className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 disabled:bg-ocean-400 rounded-lg"
      >
        <Save className="w-4 h-4" />
        {saving ? 'Saving...' : 'Save Changes'}
      </button>
    </form>
  )
}

const inputClass =
  'w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none'
