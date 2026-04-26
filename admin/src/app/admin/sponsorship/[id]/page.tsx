'use client'

import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import {
  ArrowLeft,
  Building2,
  Users,
  Plus,
  Save,
  Download,
  Trash2,
  CheckCircle2,
  XCircle,
  Mail,
  Phone,
  AlertCircle,
  Copy,
  RefreshCw,
  Send,
  Activity,
  Upload,
  KeyRound,
  ShieldAlert,
  Lock,
} from 'lucide-react'
import {
  type Organization,
  type Recipient,
  type RedemptionEvent,
  type OrganizationType,
  ORG_TYPE_LABELS,
  ORG_TYPE_COLORS,
  RECIPIENT_STATUS_COLORS,
  RECIPIENT_STATUS_LABELS,
} from '@/lib/sponsorship'

type Tab = 'people' | 'activity' | 'profile'

export default function OrganizationDetailPage() {
  const params = useParams<{ id: string }>()
  const id = params?.id

  const [org, setOrg] = useState<Organization | null>(null)
  const [recipients, setRecipients] = useState<Recipient[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [tab, setTab] = useState<Tab>('people')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (id) loadAll()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id])

  async function loadAll() {
    setLoading(true)
    try {
      const [orgRes, recipRes] = await Promise.all([
        fetch(`/api/organizations/${id}`),
        fetch(`/api/organizations/${id}/recipients`),
      ])
      const orgData = await orgRes.json()
      const recipData = await recipRes.json()
      if (!orgRes.ok) throw new Error(orgData.error || 'Failed to load organisation')
      setOrg(orgData)
      setRecipients(Array.isArray(recipData) ? recipData : [])
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
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
      setOrg((p) => (p ? { ...p, ...data } : p))
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setSaving(false)
    }
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

  const stats = {
    total: recipients.length,
    redeemed: recipients.filter((r) => r.status === 'redeemed').length,
    invited: recipients.filter((r) => r.status === 'invited').length,
    revoked: recipients.filter((r) => r.status === 'revoked').length,
  }

  const seatsRemaining = Math.max(0, org.seats_purchased - org.seats_redeemed)
  const seatsExhausted = org.seats_purchased > 0 && seatsRemaining === 0

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

        <div className="flex items-start justify-between mb-6 gap-4 flex-wrap">
          <div className="flex items-start gap-4">
            <div className="w-14 h-14 rounded-xl bg-ocean-50 flex items-center justify-center">
              <Building2 className="w-7 h-7 text-ocean-700" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900">{org.name}</h2>
              <div className="flex items-center gap-2 mt-1.5 flex-wrap">
                <span className={`inline-block px-2 py-0.5 rounded-md text-xs font-medium border ${ORG_TYPE_COLORS[org.type]}`}>
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
                    Paused
                  </span>
                )}
              </div>
            </div>
          </div>
          <Link
            href={`/admin/sponsorship/${org.id}/billing`}
            className="flex items-center gap-2 px-3 py-1.5 text-sm text-amber-800 border border-amber-300 bg-amber-50 hover:bg-amber-100 rounded-lg"
            title="Owner-only commercial settings"
          >
            <Lock className="w-4 h-4" />
            Owner Console
          </Link>
        </div>

        {seatsExhausted && (
          <div className="mb-6 flex items-start gap-3 p-4 bg-amber-50 border border-amber-200 rounded-xl">
            <ShieldAlert className="w-5 h-5 text-amber-700 mt-0.5 flex-shrink-0" />
            <div>
              <div className="font-semibold text-amber-900">All allocated spots are in use</div>
              <div className="text-sm text-amber-800 mt-0.5">
                {org.seats_redeemed} of {org.seats_purchased} spots have been used. New
                redemptions will be blocked until your administrator allocates more spots.
              </div>
            </div>
          </div>
        )}

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <StatBox label="People Invited" value={stats.total} icon={Users} tint="bg-blue-50 text-blue-700" />
          <StatBox label="Active" value={stats.redeemed} icon={CheckCircle2} tint="bg-emerald-50 text-emerald-700" />
          <StatBox label="Awaiting" value={stats.invited} icon={Send} tint="bg-amber-50 text-amber-700" />
          <StatBox
            label="Spots Available"
            value={org.seats_purchased > 0 ? seatsRemaining : '∞'}
            icon={KeyRound}
            tint="bg-purple-50 text-purple-700"
          />
        </div>

        <div className="border-b border-gray-200 mb-6">
          <div className="flex gap-6 overflow-x-auto">
            <TabButton active={tab === 'people'} onClick={() => setTab('people')} icon={Users}>
              People ({recipients.length})
            </TabButton>
            <TabButton active={tab === 'activity'} onClick={() => setTab('activity')} icon={Activity}>
              Activity
            </TabButton>
            <TabButton active={tab === 'profile'} onClick={() => setTab('profile')} icon={Building2}>
              Profile
            </TabButton>
          </div>
        </div>

        {error && (
          <div className="mb-4 flex items-start gap-2 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
            <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {tab === 'people' && (
          <PeopleTab
            org={org}
            recipients={recipients}
            onChange={loadAll}
          />
        )}
        {tab === 'activity' && <ActivityTab orgId={org.id} />}
        {tab === 'profile' && <ProfileTab org={org} onSave={saveOrg} saving={saving} />}
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
  value: number | string
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
  icon: Icon,
  children,
}: {
  active: boolean
  onClick: () => void
  icon: React.ElementType
  children: React.ReactNode
}) {
  return (
    <button
      onClick={onClick}
      className={`pb-3 text-sm font-medium border-b-2 transition-colors flex items-center gap-2 whitespace-nowrap ${
        active ? 'text-ocean-700 border-ocean-600' : 'text-gray-500 border-transparent hover:text-gray-700'
      }`}
    >
      <Icon className="w-4 h-4" />
      {children}
    </button>
  )
}

// ─── People Tab ─────────────────────────────────────────────────────────────

function PeopleTab({
  org,
  recipients,
  onChange,
}: {
  org: Organization
  recipients: Recipient[]
  onChange: () => void
}) {
  const [showInvite, setShowInvite] = useState(false)
  const [showImport, setShowImport] = useState(false)
  const [filter, setFilter] = useState<'all' | 'invited' | 'redeemed' | 'revoked'>('all')
  const [query, setQuery] = useState('')

  const filtered = recipients.filter((r) => {
    if (filter !== 'all' && r.status !== filter) return false
    if (query) {
      const q = query.toLowerCase()
      return (
        r.identifier.toLowerCase().includes(q) ||
        r.display_name?.toLowerCase().includes(q) ||
        r.email?.toLowerCase().includes(q)
      )
    }
    return true
  })

  function exportCsv() {
    const header = 'Identifier,Name,Email,Status,Code,Invited At,Redeemed At,Reissue Count\n'
    const rows = recipients
      .map((r) =>
        [
          r.identifier,
          r.display_name || '',
          r.email || '',
          r.status,
          r.active_code || '',
          r.invited_at?.slice(0, 19).replace('T', ' ') || '',
          r.redeemed_at?.slice(0, 19).replace('T', ' ') || '',
          r.reissue_count,
        ]
          .map((v) => `"${String(v).replace(/"/g, '""')}"`)
          .join(',')
      )
      .join('\n')
    download(`${org.slug}-recipients-${new Date().toISOString().slice(0, 10)}.csv`, header + rows)
  }

  return (
    <div>
      <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
        <div className="flex items-center gap-2 flex-wrap">
          <button
            onClick={() => {
              setShowInvite(true)
              setShowImport(false)
            }}
            className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 rounded-lg"
          >
            <Plus className="w-4 h-4" />
            Invite Person
          </button>
          <button
            onClick={() => {
              setShowImport(true)
              setShowInvite(false)
            }}
            className="flex items-center gap-2 px-4 py-2 text-sm text-ocean-700 border border-ocean-200 bg-ocean-50 hover:bg-ocean-100 rounded-lg"
          >
            <Upload className="w-4 h-4" />
            Bulk Import
          </button>
        </div>
        <div className="flex items-center gap-2">
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search by ID, name, email..."
            className="px-3 py-1.5 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none"
          />
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value as 'all' | 'invited' | 'redeemed' | 'revoked')}
            className="px-3 py-1.5 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 outline-none"
          >
            <option value="all">All ({recipients.length})</option>
            <option value="invited">Invited</option>
            <option value="redeemed">Redeemed</option>
            <option value="revoked">Revoked</option>
          </select>
          {recipients.length > 0 && (
            <button
              onClick={exportCsv}
              className="flex items-center gap-2 px-3 py-1.5 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
            >
              <Download className="w-4 h-4" />
              CSV
            </button>
          )}
        </div>
      </div>

      {showInvite && (
        <InviteForm
          orgId={org.id}
          onClose={() => setShowInvite(false)}
          onComplete={() => {
            setShowInvite(false)
            onChange()
          }}
        />
      )}

      {showImport && (
        <BulkImportForm
          orgId={org.id}
          onClose={() => setShowImport(false)}
          onComplete={() => {
            setShowImport(false)
            onChange()
          }}
        />
      )}

      {filtered.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-xl p-12 text-center">
          <Users className="w-12 h-12 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 mb-1">
            {recipients.length === 0 ? 'No recipients yet' : 'No matches'}
          </h3>
          <p className="text-gray-500">
            {recipients.length === 0
              ? 'Invite the first person or upload a CSV of your team to get started.'
              : 'Try a different filter or search.'}
          </p>
        </div>
      ) : (
        <div className="bg-white border border-gray-200 rounded-xl overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">Identifier</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">Name / Email</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">Code</th>
                <th className="text-right px-4 py-3" />
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.map((r) => (
                <RecipientRow key={r.id} recipient={r} allowReissue={org.allow_reissue} onChange={onChange} />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

function RecipientRow({
  recipient,
  allowReissue,
  onChange,
}: {
  recipient: Recipient
  allowReissue: boolean
  onChange: () => void
}) {
  const [busy, setBusy] = useState(false)
  const [copied, setCopied] = useState(false)

  async function handleResend() {
    setBusy(true)
    try {
      const res = await fetch(`/api/recipients/${recipient.id}/resend`, { method: 'POST' })
      const data = await res.json()
      if (!res.ok) alert(data.error || 'Failed to resend')
      else alert('Invite email sent')
      onChange()
    } finally {
      setBusy(false)
    }
  }

  async function handleReissue() {
    if (!confirm(`Reissue code for ${recipient.identifier}? The previous code will be deactivated.`)) return
    setBusy(true)
    try {
      const res = await fetch(`/api/recipients/${recipient.id}/reissue`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })
      const data = await res.json()
      if (!res.ok) alert(data.error || 'Failed to reissue')
      else if (data.email_error) alert(`Code reissued (${data.code.code}) but email failed: ${data.email_error}`)
      onChange()
    } finally {
      setBusy(false)
    }
  }

  async function handleRevoke() {
    if (!confirm(`Revoke access for ${recipient.identifier}? Their code will stop working.`)) return
    setBusy(true)
    try {
      await fetch(`/api/recipients/${recipient.id}`, { method: 'DELETE' })
      onChange()
    } finally {
      setBusy(false)
    }
  }

  async function handleCopy() {
    if (!recipient.active_code) return
    await navigator.clipboard.writeText(recipient.active_code)
    setCopied(true)
    setTimeout(() => setCopied(false), 1500)
  }

  return (
    <tr className="hover:bg-gray-50">
      <td className="px-4 py-3">
        <code className="font-mono text-sm font-medium text-gray-900">{recipient.identifier}</code>
        {recipient.reissue_count > 0 && (
          <div className="text-xs text-amber-600 mt-0.5">Reissued {recipient.reissue_count}x</div>
        )}
      </td>
      <td className="px-4 py-3 text-sm">
        {recipient.display_name && <div className="text-gray-900">{recipient.display_name}</div>}
        {recipient.email && <div className="text-gray-500 text-xs">{recipient.email}</div>}
      </td>
      <td className="px-4 py-3">
        <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium border ${RECIPIENT_STATUS_COLORS[recipient.status]}`}>
          {RECIPIENT_STATUS_LABELS[recipient.status]}
        </span>
        {recipient.email_sent_at && recipient.status === 'invited' && (
          <div className="text-xs text-gray-500 mt-0.5">Sent {timeAgo(recipient.email_sent_at)}</div>
        )}
        {recipient.redeemed_at && (
          <div className="text-xs text-gray-500 mt-0.5">{timeAgo(recipient.redeemed_at)}</div>
        )}
      </td>
      <td className="px-4 py-3 text-sm">
        {recipient.active_code ? (
          <div className="flex items-center gap-1.5">
            <code className="font-mono text-xs text-gray-700">{recipient.active_code}</code>
            <button onClick={handleCopy} className="text-gray-400 hover:text-gray-700">
              {copied ? <CheckCircle2 className="w-3 h-3 text-green-600" /> : <Copy className="w-3 h-3" />}
            </button>
          </div>
        ) : (
          <span className="text-xs text-gray-400">No active code</span>
        )}
      </td>
      <td className="px-4 py-3 text-right">
        <div className="flex items-center justify-end gap-1">
          {recipient.email && recipient.status === 'invited' && (
            <button
              onClick={handleResend}
              disabled={busy}
              className="px-2 py-1 text-xs text-gray-600 border border-gray-200 rounded hover:bg-gray-50 disabled:opacity-50"
              title="Resend invite email"
            >
              <Send className="w-3.5 h-3.5" />
            </button>
          )}
          {allowReissue && recipient.status !== 'revoked' && (
            <button
              onClick={handleReissue}
              disabled={busy}
              className="px-2 py-1 text-xs text-gray-600 border border-gray-200 rounded hover:bg-gray-50 disabled:opacity-50"
              title="Reissue code (revoke and replace)"
            >
              <RefreshCw className="w-3.5 h-3.5" />
            </button>
          )}
          {recipient.status !== 'revoked' && (
            <button
              onClick={handleRevoke}
              disabled={busy}
              className="px-2 py-1 text-xs text-red-600 border border-red-200 rounded hover:bg-red-50 disabled:opacity-50"
              title="Revoke access"
            >
              <Trash2 className="w-3.5 h-3.5" />
            </button>
          )}
        </div>
      </td>
    </tr>
  )
}

function InviteForm({
  orgId,
  onClose,
  onComplete,
}: {
  orgId: string
  onClose: () => void
  onComplete: () => void
}) {
  const [identifier, setIdentifier] = useState('')
  const [displayName, setDisplayName] = useState('')
  const [email, setEmail] = useState('')
  const [sendEmail, setSendEmail] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [created, setCreated] = useState<{ code: string; emailNote?: string } | null>(null)

  async function submit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)
    setSubmitting(true)
    try {
      const res = await fetch(`/api/organizations/${orgId}/recipients`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          identifier,
          display_name: displayName || null,
          email: email || null,
          send_email: sendEmail,
        }),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to create')
      setCreated({
        code: data.code.code,
        emailNote: data.email_status?.skipped
          ? data.email_status.reason
          : data.email_status?.ok === false
            ? `Email send failed: ${data.email_status.reason}`
            : undefined,
      })
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setSubmitting(false)
    }
  }

  if (created) {
    return (
      <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-5 mb-4">
        <div className="flex items-center gap-2 mb-2">
          <CheckCircle2 className="w-5 h-5 text-emerald-700" />
          <h3 className="font-semibold text-emerald-900">Recipient invited</h3>
        </div>
        <div className="bg-white border border-emerald-200 rounded-lg p-3 mb-3">
          <div className="text-xs text-emerald-700 mb-1">Their code:</div>
          <code className="font-mono text-lg font-bold text-emerald-900">{created.code}</code>
        </div>
        {created.emailNote && (
          <div className="text-sm text-amber-700 bg-amber-50 border border-amber-200 rounded p-2 mb-3">
            {created.emailNote}
          </div>
        )}
        <div className="flex gap-2">
          <button
            onClick={() => {
              setCreated(null)
              setIdentifier('')
              setDisplayName('')
              setEmail('')
            }}
            className="px-3 py-1.5 text-sm text-emerald-800 border border-emerald-300 rounded-lg hover:bg-emerald-100"
          >
            Invite Another
          </button>
          <button
            onClick={onComplete}
            className="px-3 py-1.5 text-sm text-white bg-emerald-700 hover:bg-emerald-800 rounded-lg"
          >
            Done
          </button>
        </div>
      </div>
    )
  }

  return (
    <form onSubmit={submit} className="bg-white border border-gray-200 rounded-xl p-5 mb-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-semibold text-gray-900">Invite a person</h3>
        <button type="button" onClick={onClose} className="text-gray-400 hover:text-gray-700">
          <XCircle className="w-5 h-5" />
        </button>
      </div>
      <div className="grid grid-cols-2 gap-3 mb-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Identifier <span className="text-red-500">*</span>
          </label>
          <input
            required
            value={identifier}
            onChange={(e) => setIdentifier(e.target.value)}
            placeholder="e.g. service number"
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 outline-none font-mono"
          />
          <p className="text-xs text-gray-500 mt-1">Sponsor-side ID. Service number, employee ID, etc.</p>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Name (optional)</label>
          <input
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            placeholder="e.g. J. Smith"
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 outline-none"
          />
        </div>
      </div>
      <div className="mb-4">
        <label className="block text-sm font-medium text-gray-700 mb-1">Email (optional)</label>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="person@example.com"
          className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 outline-none"
        />
        <label className="flex items-center gap-2 mt-2 text-sm text-gray-600">
          <input
            type="checkbox"
            checked={sendEmail}
            onChange={(e) => setSendEmail(e.target.checked)}
            className="rounded border-gray-300 text-ocean-600 focus:ring-ocean-500"
            disabled={!email}
          />
          Send invite email automatically
        </label>
      </div>
      {error && (
        <div className="flex items-start gap-2 p-3 mb-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}
      <button
        type="submit"
        disabled={submitting || !identifier}
        className="px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 disabled:bg-ocean-400 rounded-lg"
      >
        {submitting ? 'Inviting...' : 'Invite'}
      </button>
    </form>
  )
}

function BulkImportForm({
  orgId,
  onClose,
  onComplete,
}: {
  orgId: string
  onClose: () => void
  onComplete: () => void
}) {
  const [pasted, setPasted] = useState('')
  const [sendEmail, setSendEmail] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [result, setResult] = useState<{
    summary: { total: number; created: number; skipped: number; errors: number; emails_sent: number; emails_failed: number }
    results: { identifier: string; status: string; reason?: string; code?: string; email_sent?: boolean; email_error?: string }[]
  } | null>(null)
  const [error, setError] = useState<string | null>(null)

  function parseRows(text: string): { identifier: string; email?: string; display_name?: string }[] {
    const lines = text.split(/\r?\n/).map((l) => l.trim()).filter(Boolean)
    if (lines.length === 0) return []

    const first = lines[0].toLowerCase()
    const hasHeader = first.includes('identifier') || first.includes('email') || first.includes('id')
    const data = hasHeader ? lines.slice(1) : lines

    return data.map((line) => {
      const cells = line.split(/[,\t]/).map((c) => c.trim().replace(/^"|"$/g, ''))
      return {
        identifier: cells[0] || '',
        display_name: cells[1] || undefined,
        email: cells[2] || undefined,
      }
    }).filter((r) => r.identifier)
  }

  async function submit() {
    const rows = parseRows(pasted)
    if (rows.length === 0) {
      setError('No valid rows found. Paste CSV with columns: identifier, name, email')
      return
    }
    setError(null)
    setSubmitting(true)
    try {
      const res = await fetch(`/api/organizations/${orgId}/recipients/import`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rows, send_email: sendEmail }),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Import failed')
      setResult(data)
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setSubmitting(false)
    }
  }

  if (result) {
    return (
      <div className="bg-white border border-gray-200 rounded-xl p-5 mb-4">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-gray-900">Import complete</h3>
          <button onClick={onComplete} className="text-gray-400 hover:text-gray-700">
            <XCircle className="w-5 h-5" />
          </button>
        </div>
        <div className="grid grid-cols-3 gap-3 mb-4">
          <div className="bg-emerald-50 border border-emerald-200 rounded-lg p-3 text-center">
            <div className="text-2xl font-bold text-emerald-700">{result.summary.created}</div>
            <div className="text-xs text-emerald-700 uppercase tracking-wider">Created</div>
          </div>
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-3 text-center">
            <div className="text-2xl font-bold text-amber-700">{result.summary.skipped}</div>
            <div className="text-xs text-amber-700 uppercase tracking-wider">Skipped</div>
          </div>
          <div className="bg-red-50 border border-red-200 rounded-lg p-3 text-center">
            <div className="text-2xl font-bold text-red-700">{result.summary.errors}</div>
            <div className="text-xs text-red-700 uppercase tracking-wider">Errors</div>
          </div>
        </div>
        {(result.summary.emails_sent > 0 || result.summary.emails_failed > 0) && (
          <div className="text-sm text-gray-600 mb-4">
            Emails: <strong>{result.summary.emails_sent}</strong> sent
            {result.summary.emails_failed > 0 && (
              <span className="text-red-600">, {result.summary.emails_failed} failed</span>
            )}
          </div>
        )}
        {result.results.some((r) => r.status !== 'created') && (
          <details className="text-sm text-gray-600">
            <summary className="cursor-pointer">Show issues</summary>
            <div className="mt-2 max-h-48 overflow-y-auto bg-gray-50 rounded p-2 font-mono text-xs">
              {result.results
                .filter((r) => r.status !== 'created')
                .map((r, i) => (
                  <div key={i}>
                    {r.identifier}: {r.status} {r.reason ? `- ${r.reason}` : ''}
                  </div>
                ))}
            </div>
          </details>
        )}
        <div className="mt-4 flex gap-2">
          <button
            onClick={onComplete}
            className="px-3 py-1.5 text-sm text-white bg-ocean-600 hover:bg-ocean-700 rounded-lg"
          >
            Done
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-white border border-gray-200 rounded-xl p-5 mb-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-semibold text-gray-900">Bulk Import Recipients</h3>
        <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
          <XCircle className="w-5 h-5" />
        </button>
      </div>

      <div className="bg-gray-50 border border-gray-200 rounded-lg p-3 mb-4 text-xs text-gray-600 font-mono">
        identifier,name,email<br />
        SVC123456,J. Smith,jsmith@example.com<br />
        SVC123457,K. Jones,kjones@example.com
      </div>
      <p className="text-sm text-gray-600 mb-2">
        Paste a CSV (or just IDs one per line). First column is the identifier (required).
        Name and email are optional. Header row is optional.
      </p>
      <textarea
        value={pasted}
        onChange={(e) => setPasted(e.target.value)}
        placeholder="Paste your CSV here..."
        className="w-full min-h-[160px] px-3 py-2 border border-gray-200 rounded-lg text-sm font-mono focus:ring-2 focus:ring-ocean-500 outline-none"
      />
      <label className="flex items-center gap-2 mt-3 text-sm text-gray-600">
        <input
          type="checkbox"
          checked={sendEmail}
          onChange={(e) => setSendEmail(e.target.checked)}
          className="rounded border-gray-300 text-ocean-600 focus:ring-ocean-500"
        />
        Send invite email to recipients with email addresses
      </label>
      {error && (
        <div className="flex items-start gap-2 p-3 mt-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}
      <button
        onClick={submit}
        disabled={submitting || !pasted.trim()}
        className="mt-4 px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 disabled:bg-ocean-400 rounded-lg"
      >
        {submitting ? 'Importing...' : 'Import & Generate Codes'}
      </button>
    </div>
  )
}

// ─── Activity Tab ───────────────────────────────────────────────────────────

interface ActivityResponse {
  events: RedemptionEvent[]
  stats: { total: number; successful: number; failed: number }
  alerts: { window_start: string; window_end: string; count: number }[]
}

function ActivityTab({ orgId }: { orgId: string }) {
  const [data, setData] = useState<ActivityResponse | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    load()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [orgId])

  async function load() {
    setLoading(true)
    try {
      const res = await fetch(`/api/organizations/${orgId}/redemption-events`)
      const json = await res.json()
      setData(json)
    } finally {
      setLoading(false)
    }
  }

  function exportCsv() {
    if (!data) return
    const header = 'Occurred At,Code,Succeeded,Failure Reason,Device ID\n'
    const rows = data.events
      .map((e) =>
        [
          e.occurred_at,
          e.code_text || '',
          e.succeeded ? 'yes' : 'no',
          e.failure_reason || '',
          e.device_id || '',
        ]
          .map((v) => `"${String(v).replace(/"/g, '""')}"`)
          .join(',')
      )
      .join('\n')
    download(`redemption-events-${new Date().toISOString().slice(0, 10)}.csv`, header + rows)
  }

  if (loading)
    return (
      <div className="flex items-center justify-center h-48">
        <div className="w-6 h-6 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
      </div>
    )

  if (!data || data.events.length === 0)
    return (
      <div className="bg-white border border-gray-200 rounded-xl p-12 text-center">
        <Activity className="w-12 h-12 text-gray-300 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-gray-900 mb-1">No activity yet</h3>
        <p className="text-gray-500">Redemption attempts will appear here as they happen.</p>
      </div>
    )

  return (
    <div className="space-y-4">
      {data.alerts.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4">
          <div className="flex items-start gap-3">
            <ShieldAlert className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
            <div>
              <div className="font-semibold text-red-900 mb-1">Burst redemption detected</div>
              <div className="text-sm text-red-700">
                {data.alerts.length} suspicious window{data.alerts.length !== 1 ? 's' : ''} found
                (10+ redemptions in 60 seconds). Investigate possible code sharing.
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-3 gap-4">
        <div className="bg-white border border-gray-200 rounded-xl p-4">
          <div className="text-2xl font-bold text-gray-900">{data.stats.total}</div>
          <div className="text-xs text-gray-500 uppercase tracking-wider mt-1">Total Events</div>
        </div>
        <div className="bg-white border border-gray-200 rounded-xl p-4">
          <div className="text-2xl font-bold text-emerald-700">{data.stats.successful}</div>
          <div className="text-xs text-gray-500 uppercase tracking-wider mt-1">Successful</div>
        </div>
        <div className="bg-white border border-gray-200 rounded-xl p-4">
          <div className="text-2xl font-bold text-red-600">{data.stats.failed}</div>
          <div className="text-xs text-gray-500 uppercase tracking-wider mt-1">Failed</div>
        </div>
      </div>

      <div className="flex justify-end">
        <button
          onClick={exportCsv}
          className="flex items-center gap-2 px-3 py-1.5 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
        >
          <Download className="w-4 h-4" />
          Export Events CSV
        </button>
      </div>

      <div className="bg-white border border-gray-200 rounded-xl overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">When</th>
              <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">Code</th>
              <th className="text-left px-4 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider">Result</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {data.events.slice(0, 100).map((e) => (
              <tr key={e.id} className="hover:bg-gray-50">
                <td className="px-4 py-2 text-sm text-gray-600">
                  {new Date(e.occurred_at).toLocaleString('en-GB')}
                </td>
                <td className="px-4 py-2 text-sm">
                  <code className="font-mono text-xs text-gray-700">{e.code_text || '-'}</code>
                </td>
                <td className="px-4 py-2 text-sm">
                  {e.succeeded ? (
                    <span className="inline-flex items-center gap-1 text-emerald-700">
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      Redeemed
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 text-red-600">
                      <XCircle className="w-3.5 h-3.5" />
                      {e.failure_reason || 'Failed'}
                    </span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

// ─── Profile Tab ────────────────────────────────────────────────────────────
//
// Identity and contact info only. Commercial fields (billing, contract dates,
// seats purchased, reissue policy, deactivate, delete) live in the Owner
// Console at /admin/sponsorship/[id]/billing - see header link.

function ProfileTab({
  org,
  onSave,
  saving,
}: {
  org: Organization
  onSave: (updates: Partial<Organization>) => Promise<void>
  saving: boolean
}) {
  const [form, setForm] = useState({
    name: org.name,
    type: org.type,
    contact_name: org.contact_name || '',
    contact_email: org.contact_email || '',
    contact_phone: org.contact_phone || '',
    notes: org.notes || '',
  })

  function set<K extends keyof typeof form>(k: K, v: (typeof form)[K]) {
    setForm((f) => ({ ...f, [k]: v }))
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
          <input value={form.name} onChange={(e) => set('name', e.target.value)} className={inputClass} />
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
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Contact name</label>
        <input value={form.contact_name} onChange={(e) => set('contact_name', e.target.value)} className={inputClass} />
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
        <label className="block text-sm font-medium text-gray-700 mb-1">Notes</label>
        <textarea
          value={form.notes}
          onChange={(e) => set('notes', e.target.value)}
          className={`${inputClass} min-h-[80px]`}
        />
      </div>

      <div className="text-xs text-gray-500 border-t border-gray-100 pt-4">
        Looking for billing, contract dates, or sponsor activation?{' '}
        <Link href={`/admin/sponsorship/${org.id}/billing`} className="text-amber-700 hover:text-amber-800 inline-flex items-center gap-1">
          <Lock className="w-3 h-3" />
          Owner Console
        </Link>
      </div>

      <button
        type="submit"
        disabled={saving}
        className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 disabled:bg-ocean-400 rounded-lg"
      >
        <Save className="w-4 h-4" />
        {saving ? 'Saving...' : 'Save Profile'}
      </button>
    </form>
  )
}

// ─── Helpers ────────────────────────────────────────────────────────────────

const inputClass =
  'w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none'

function timeAgo(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1) return 'just now'
  if (m < 60) return `${m}m ago`
  const h = Math.floor(m / 60)
  if (h < 24) return `${h}h ago`
  const d = Math.floor(h / 24)
  return `${d}d ago`
}

function download(filename: string, content: string) {
  const blob = new Blob([content], { type: 'text/csv' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  a.click()
  URL.revokeObjectURL(url)
}
