'use client'

import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useState } from 'react'
import { ArrowLeft, Save, AlertCircle } from 'lucide-react'
import { ORG_TYPE_LABELS, type OrganizationType } from '@/lib/sponsorship'

export default function NewOrganizationPage() {
  const router = useRouter()
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [form, setForm] = useState({
    name: '',
    type: 'military' as OrganizationType,
    contact_name: '',
    contact_email: '',
    contact_phone: '',
    contract_starts_on: '',
    contract_ends_on: '',
    seats_purchased: 0,
    notes: '',
  })

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }))
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)
    setSaving(true)
    try {
      const res = await fetch('/api/organizations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to create')
      router.push(`/admin/sponsorship/${data.id}`)
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err))
      setSaving(false)
    }
  }

  return (
    <div className="p-8">
      <div className="max-w-2xl mx-auto">
        <Link
          href="/admin/sponsorship"
          className="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700 mb-4"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to sponsors
        </Link>

        <h2 className="text-2xl font-bold text-gray-900 mb-1">New Organisation</h2>
        <p className="text-gray-500 mb-6">Add a sponsor that's purchasing bulk access.</p>

        <form onSubmit={handleSubmit} className="bg-white border border-gray-200 rounded-xl p-6 space-y-5">
          <Field label="Organisation name" required>
            <input
              required
              value={form.name}
              onChange={(e) => set('name', e.target.value)}
              className={inputClass}
              placeholder="e.g. HMS Vanguard, Plymouth College"
            />
          </Field>

          <Field label="Type" required>
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
          </Field>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Contact name">
              <input
                value={form.contact_name}
                onChange={(e) => set('contact_name', e.target.value)}
                className={inputClass}
                placeholder="Jane Smith"
              />
            </Field>
            <Field label="Contact email">
              <input
                type="email"
                value={form.contact_email}
                onChange={(e) => set('contact_email', e.target.value)}
                className={inputClass}
                placeholder="welfare@example.com"
              />
            </Field>
          </div>

          <Field label="Contact phone">
            <input
              value={form.contact_phone}
              onChange={(e) => set('contact_phone', e.target.value)}
              className={inputClass}
              placeholder="+44 ..."
            />
          </Field>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Contract starts">
              <input
                type="date"
                value={form.contract_starts_on}
                onChange={(e) => set('contract_starts_on', e.target.value)}
                className={inputClass}
              />
            </Field>
            <Field label="Contract ends">
              <input
                type="date"
                value={form.contract_ends_on}
                onChange={(e) => set('contract_ends_on', e.target.value)}
                className={inputClass}
              />
            </Field>
          </div>

          <Field label="Seats purchased" hint="Used for tracking - doesn't limit code generation">
            <input
              type="number"
              min={0}
              value={form.seats_purchased}
              onChange={(e) => set('seats_purchased', parseInt(e.target.value || '0', 10))}
              className={inputClass}
            />
          </Field>

          <Field label="Notes">
            <textarea
              value={form.notes}
              onChange={(e) => set('notes', e.target.value)}
              className={`${inputClass} min-h-[80px]`}
              placeholder="Internal notes, contract reference, etc."
            />
          </Field>

          {error && (
            <div className="flex items-start gap-2 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
              <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <button
              type="submit"
              disabled={saving}
              className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-ocean-600 hover:bg-ocean-700 disabled:bg-ocean-400 rounded-lg"
            >
              <Save className="w-4 h-4" />
              {saving ? 'Saving...' : 'Create Organisation'}
            </button>
            <Link
              href="/admin/sponsorship"
              className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </Link>
          </div>
        </form>
      </div>
    </div>
  )
}

const inputClass =
  'w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-ocean-500 focus:border-ocean-500 outline-none'

function Field({
  label,
  required,
  hint,
  children,
}: {
  label: string
  required?: boolean
  hint?: string
  children: React.ReactNode
}) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">
        {label} {required && <span className="text-red-500">*</span>}
      </label>
      {children}
      {hint && <p className="text-xs text-gray-500 mt-1">{hint}</p>}
    </div>
  )
}
