'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import {
  ArrowLeft,
  Save,
  Trash2,
  AlertCircle,
  ShieldAlert,
  Lock,
  Calendar,
  KeyRound,
  RefreshCw,
  Power,
} from 'lucide-react'
import type { Organization } from '@/lib/sponsorship'

export default function BillingConsolePage() {
  const params = useParams<{ id: string }>()
  const router = useRouter()
  const id = params?.id

  const [org, setOrg] = useState<Organization | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [savedAt, setSavedAt] = useState<number | null>(null)

  const [form, setForm] = useState({
    billing_mode: 'prepaid' as 'prepaid' | 'postpaid_quarterly',
    billing_batch_size: 100,
    seats_purchased: 0,
    contract_starts_on: '',
    contract_ends_on: '',
    allow_reissue: true,
    max_reissues_per_recipient: 4,
    is_active: true,
  })

  useEffect(() => {
    if (id) load()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id])

  async function load() {
    setLoading(true)
    try {
      const res = await fetch(`/api/organizations/${id}`)
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to load')
      setOrg(data)
      setForm({
        billing_mode: data.billing_mode,
        billing_batch_size: data.billing_batch_size,
        seats_purchased: data.seats_purchased,
        contract_starts_on: data.contract_starts_on || '',
        contract_ends_on: data.contract_ends_on || '',
        allow_reissue: data.allow_reissue,
        max_reissues_per_recipient: data.max_reissues_per_recipient,
        is_active: data.is_active,
      })
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setLoading(false)
    }
  }

  async function save() {
    if (!org) return
    setSaving(true)
    setError(null)
    try {
      const res = await fetch(`/api/organizations/${org.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Save failed')
      setOrg((p) => (p ? { ...p, ...data } : p))
      setSavedAt(Date.now())
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setSaving(false)
    }
  }

  async function deleteOrg() {
    if (!org) return
    const typed = prompt(
      `This permanently deletes "${org.name}", all their recipients, codes, and event logs. This CANNOT be undone.\n\nType the sponsor name to confirm:`
    )
    if (typed !== org.name) {
      if (typed !== null) alert('Name did not match. Deletion cancelled.')
      return
    }
    const res = await fetch(`/api/organizations/${org.id}`, { method: 'DELETE' })
    if (res.ok) router.push('/admin/sponsorship')
  }

  function set<K extends keyof typeof form>(k: K, v: (typeof form)[K]) {
    setForm((f) => ({ ...f, [k]: v }))
  }

  if (loading)
    return (
      <div className="flex items-center justify-center h-96">
        <div className="w-8 h-8 border-4 border-ocean-200 border-t-ocean-600 rounded-full animate-spin" />
      </div>
    )

  if (!org)
    return (
      <div className="p-8 max-w-3xl mx-auto">
        <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-red-700">
          {error || 'Sponsor not found'}
        </div>
      </div>
    )

  const seatsRemaining = Math.max(0, org.seats_purchased - org.seats_redeemed)

  return (
    <div className="p-8">
      <div className="max-w-4xl mx-auto">
        <Link
          href={`/admin/sponsorship/${id}`}
          className="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700 mb-4"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to {org.name}
        </Link>

        <div className="flex items-center gap-3 mb-2">
          <div className="w-10 h-10 rounded-xl bg-amber-100 border border-amber-300 flex items-center justify-center">
            <Lock className="w-5 h-5 text-amber-700" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Owner Console</h1>
            <p className="text-sm text-gray-500">Commercial settings for {org.name}</p>
          </div>
        </div>

        <div className="bg-amber-50 border border-amber-300 rounded-xl p-4 mb-6 mt-4">
          <div className="flex items-start gap-3">
            <ShieldAlert className="w-5 h-5 text-amber-700 mt-0.5 flex-shrink-0" />
            <div className="text-sm text-amber-900">
              <strong>This page is for the app owner only.</strong> Welfare officers and unit
              admins should never see these settings. Only you control the commercial
              relationship — billing model, seat counts, and contract terms — for each sponsor.
            </div>
          </div>
        </div>

        {error && (
          <div className="mb-4 flex items-start gap-2 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
            <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {savedAt && Date.now() - savedAt < 3000 && (
          <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 rounded-lg text-sm text-emerald-700">
            Settings saved
          </div>
        )}

        {/* Billing Model */}
        <Section icon={KeyRound} title="Billing model" description="How this sponsor pays for access.">
          <div className="grid grid-cols-2 gap-3 mb-4">
            <BillingOption
              active={form.billing_mode === 'prepaid'}
              onClick={() => set('billing_mode', 'prepaid')}
              title="Prepaid"
              recommended
              description="Sponsor pays upfront for a fixed number of seats. Redemptions are blocked once seats are exhausted, so you never deliver value you haven't been paid for."
            />
            <BillingOption
              active={form.billing_mode === 'postpaid_quarterly'}
              onClick={() => set('billing_mode', 'postpaid_quarterly')}
              title="Postpaid Quarterly"
              description="No upfront payment. Redemptions are never blocked. You invoice the sponsor at the end of each quarter based on actual redemptions logged in the Activity tab."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                {form.billing_mode === 'prepaid' ? 'Seats purchased' : 'Quarterly cap (display only)'}
              </label>
              <input
                type="number"
                min={0}
                value={form.seats_purchased}
                onChange={(e) => set('seats_purchased', parseInt(e.target.value || '0', 10))}
                className={inputClass}
              />
              <p className="text-xs text-gray-500 mt-1">
                {form.billing_mode === 'prepaid'
                  ? `Currently used: ${org.seats_redeemed} / ${form.seats_purchased} (${seatsRemaining} available)`
                  : `Used this period: ${org.seats_redeemed}`}
              </p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Billing batch size
              </label>
              <input
                type="number"
                min={1}
                value={form.billing_batch_size}
                onChange={(e) => set('billing_batch_size', parseInt(e.target.value || '1', 10))}
                className={inputClass}
              />
              <p className="text-xs text-gray-500 mt-1">
                Contract pricing unit shown on invoices, e.g. "billed per 50". Display only.
              </p>
            </div>
          </div>
        </Section>

        {/* Contract */}
        <Section
          icon={Calendar}
          title="Contract dates"
          description="When this sponsor's commitment runs from and until."
        >
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Contract starts</label>
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
              <p className="text-xs text-gray-500 mt-1">
                After this date, all codes for this sponsor stop working.
              </p>
            </div>
          </div>
        </Section>

        {/* Reissue policy */}
        <Section
          icon={RefreshCw}
          title="Reissue policy"
          description="Whether welfare officers can revoke and reissue codes themselves."
        >
          <label className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50">
            <input
              type="checkbox"
              checked={form.allow_reissue}
              onChange={(e) => set('allow_reissue', e.target.checked)}
              className="mt-0.5 rounded border-gray-300 text-ocean-600 focus:ring-ocean-500"
            />
            <div>
              <div className="text-sm font-medium text-gray-900">
                Allow welfare officers to reissue codes
              </div>
              <div className="text-xs text-gray-500 mt-0.5">
                When enabled, the unit's admin can revoke a recipient's code and issue a new one
                (e.g. someone changed phone). Each reissue is counted per recipient.
              </div>
            </div>
          </label>
          {form.allow_reissue && (
            <div className="mt-3 ml-7">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Max reissues per recipient
              </label>
              <input
                type="number"
                min={0}
                value={form.max_reissues_per_recipient}
                onChange={(e) => set('max_reissues_per_recipient', parseInt(e.target.value || '0', 10))}
                className={`${inputClass} w-32`}
              />
              <p className="text-xs text-gray-500 mt-1">
                Anti-abuse cap. After this many reissues, further requests are blocked.
              </p>
            </div>
          )}
        </Section>

        {/* Save */}
        <div className="flex items-center gap-3 mb-8">
          <button
            onClick={save}
            disabled={saving}
            className="flex items-center gap-2 px-5 py-2.5 text-sm text-white bg-ocean-600 hover:bg-ocean-700 disabled:bg-ocean-400 rounded-lg"
          >
            <Save className="w-4 h-4" />
            {saving ? 'Saving...' : 'Save Owner Settings'}
          </button>
          <Link
            href={`/admin/sponsorship/${id}`}
            className="text-sm text-gray-500 hover:text-gray-700"
          >
            Cancel
          </Link>
        </div>

        {/* Danger Zone */}
        <Section
          icon={Power}
          title="Danger zone"
          description="One-click controls that affect every recipient under this sponsor."
          danger
        >
          <div className="space-y-3">
            <div className="flex items-center justify-between p-4 border border-amber-200 rounded-lg bg-amber-50">
              <div>
                <div className="text-sm font-semibold text-amber-900">
                  {form.is_active ? 'Sponsor is active' : 'Sponsor is paused'}
                </div>
                <div className="text-xs text-amber-800 mt-0.5">
                  {form.is_active
                    ? 'All codes for this sponsor are working. Toggle to instantly pause every code (e.g. contract dispute, payment overdue).'
                    : 'All codes are blocked. Recipients will see "Sponsor is no longer active" when they try to use the app.'}
                </div>
              </div>
              <button
                onClick={() => {
                  set('is_active', !form.is_active)
                  setTimeout(save, 50)
                }}
                className={`px-3 py-1.5 text-sm font-medium rounded-lg ${
                  form.is_active
                    ? 'bg-amber-600 hover:bg-amber-700 text-white'
                    : 'bg-emerald-600 hover:bg-emerald-700 text-white'
                }`}
              >
                {form.is_active ? 'Pause sponsor' : 'Reactivate sponsor'}
              </button>
            </div>

            <div className="flex items-center justify-between p-4 border border-red-200 rounded-lg bg-red-50">
              <div>
                <div className="text-sm font-semibold text-red-900">Delete sponsor permanently</div>
                <div className="text-xs text-red-800 mt-0.5">
                  Removes the sponsor, all their recipients, all codes, and audit history. The
                  redemption_events log is preserved (for billing reconciliation) but
                  disconnected.
                </div>
              </div>
              <button
                onClick={deleteOrg}
                className="flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-lg"
              >
                <Trash2 className="w-4 h-4" />
                Delete
              </button>
            </div>
          </div>
        </Section>
      </div>
    </div>
  )
}

function Section({
  icon: Icon,
  title,
  description,
  children,
  danger,
}: {
  icon: React.ElementType
  title: string
  description: string
  children: React.ReactNode
  danger?: boolean
}) {
  return (
    <section
      className={`rounded-xl border p-5 mb-5 ${
        danger ? 'bg-white border-red-200' : 'bg-white border-gray-200'
      }`}
    >
      <header className="flex items-start gap-3 mb-4">
        <div
          className={`w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 ${
            danger ? 'bg-red-50 text-red-700' : 'bg-ocean-50 text-ocean-700'
          }`}
        >
          <Icon className="w-5 h-5" />
        </div>
        <div>
          <h2 className="font-semibold text-gray-900">{title}</h2>
          <p className="text-xs text-gray-500 mt-0.5">{description}</p>
        </div>
      </header>
      {children}
    </section>
  )
}

function BillingOption({
  active,
  onClick,
  title,
  description,
  recommended,
}: {
  active: boolean
  onClick: () => void
  title: string
  description: string
  recommended?: boolean
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`text-left p-4 border-2 rounded-lg transition ${
        active ? 'border-ocean-600 bg-ocean-50' : 'border-gray-200 hover:border-gray-300'
      }`}
    >
      <div className="flex items-center justify-between mb-2">
        <div className="font-semibold text-gray-900">{title}</div>
        {recommended && (
          <span className="px-2 py-0.5 bg-emerald-100 text-emerald-700 text-xs rounded font-medium">
            Recommended
          </span>
        )}
      </div>
      <div className="text-xs text-gray-600 leading-relaxed">{description}</div>
    </button>
  )
}

const inputClass =
  'w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none'
