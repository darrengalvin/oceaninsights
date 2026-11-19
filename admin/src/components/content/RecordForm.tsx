'use client'

import { useEffect, useMemo, useState } from 'react'
import { AlertTriangle, Loader2, X } from 'lucide-react'
import {
  ADVANCED_FIELDS,
  ColumnDef,
  SYSTEM_FIELDS,
  TRUSTED_DOMAINS,
  fieldLabel,
  isLongText,
  untrustedLinks,
} from '@/lib/content-sections'
import { TABLE_COLUMNS } from '@/lib/content-schema'

type Row = Record<string, any>

/** Columns from the SQL files, plus any extra the live table turns out to have. */
export function columnsFor(table: string, rows: Row[]): ColumnDef[] {
  const known = TABLE_COLUMNS[table] || []
  const names = new Set(known.map((c) => c.name))
  const extra: ColumnDef[] = []
  for (const r of rows.slice(0, 20)) {
    for (const [k, v] of Object.entries(r)) {
      if (names.has(k)) continue
      names.add(k)
      if (typeof v === 'boolean') extra.push({ name: k, type: 'boolean' })
      else if (typeof v === 'number') extra.push({ name: k, type: 'number' })
      else if (Array.isArray(v)) extra.push({ name: k, type: 'text', array: true })
      else if (v && typeof v === 'object') extra.push({ name: k, type: 'json' })
      else extra.push({ name: k, type: 'text' })
    }
  }
  return [...known, ...extra]
}

export function blankRecord(cols: ColumnDef[]): Row {
  const r: Row = {}
  for (const c of cols) {
    if (SYSTEM_FIELDS.has(c.name)) continue
    if (c.name === 'is_active') r[c.name] = true
    else if (c.type === 'boolean') r[c.name] = false
    else if (c.array) r[c.name] = []
    else if (c.options?.length) r[c.name] = c.options[0]
    else r[c.name] = null
  }
  return r
}

const slugify = (s: string) =>
  s.toLowerCase().normalize('NFKD').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 60)

const isColour = (n: string) => /^(colou?r|accent_color|color_hex)$/.test(n)

interface ParentOptions {
  field: string
  label: string
  titleField: string
  rows: Row[]
}

interface Props {
  title: string
  table: string
  columns: ColumnDef[]
  initial: Row
  isNew: boolean
  titleField: string
  parentOptions?: ParentOptions
  rows: Row[]
  onCancel: () => void
  onSave: (record: Row) => Promise<boolean>
}

export default function RecordForm({ title, columns, initial, isNew, titleField, parentOptions, rows, onCancel, onSave }: Props) {
  const [rec, setRec] = useState<Row>(() => ({ ...initial }))
  const [jsonText, setJsonText] = useState<Record<string, string>>(() => {
    const out: Record<string, string> = {}
    for (const c of columns) if (c.type === 'json') out[c.name] = initial[c.name] == null ? '' : JSON.stringify(initial[c.name], null, 2)
    return out
  })
  const [saving, setSaving] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  const dirty =
    JSON.stringify(rec) !== JSON.stringify(initial) ||
    columns.some((c) => c.type === 'json' && (jsonText[c.name] ?? '') !== (initial[c.name] == null ? '' : JSON.stringify(initial[c.name], null, 2)))

  useEffect(() => {
    const warn = (e: BeforeUnloadEvent) => {
      if (!dirty) return
      e.preventDefault()
      e.returnValue = ''
    }
    window.addEventListener('beforeunload', warn)
    return () => window.removeEventListener('beforeunload', warn)
  }, [dirty])

  const editable = columns.filter((c) => !SYSTEM_FIELDS.has(c.name))
  const main = editable.filter((c) => !ADVANCED_FIELDS.has(c.name) && !(c.ref && c.name !== parentOptions?.field) && c.type !== 'json')
  const advanced = editable.filter((c) => !main.includes(c))

  // Offer existing values as suggestions for short "category" style fields.
  const suggestions = useMemo(() => {
    const out: Record<string, string[]> = {}
    for (const c of editable) {
      if (c.type !== 'text' || c.array || c.options || c.name === titleField || isLongText(c.name) || isColour(c.name)) continue
      const vals = Array.from(new Set(rows.map((r) => r[c.name]).filter((v) => typeof v === 'string' && v && v.length < 40)))
      if (vals.length > 0 && vals.length <= 15 && vals.length < rows.length) out[c.name] = vals as string[]
    }
    return out
  }, [editable, rows, titleField])

  function set(name: string, value: any) {
    setRec((r) => {
      const next = { ...r, [name]: value }
      // Fill in the short web name from the title for new items.
      if (isNew && name === titleField && 'slug' in r && (!r.slug || r.slug === slugify(String(r[titleField] ?? '')))) {
        next.slug = slugify(String(value ?? ''))
      }
      return next
    })
  }

  function cancel() {
    if (dirty && !window.confirm('You have unsaved changes. Discard them?')) return
    onCancel()
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault()
    const errs: Record<string, string> = {}
    const out = { ...rec }
    for (const c of editable) {
      if (c.type === 'json') {
        const t = (jsonText[c.name] ?? '').trim()
        if (!t) out[c.name] = null
        else {
          try { out[c.name] = JSON.parse(t) } catch { errs[c.name] = 'This must be valid JSON.' }
        }
      }
      const v = out[c.name]
      const empty = v == null || v === '' || (Array.isArray(v) && v.length === 0)
      if (c.required && empty && c.type !== 'boolean') errs[c.name] = 'Required.'
    }
    setErrors(errs)
    if (Object.keys(errs).length) return
    setSaving(true)
    await onSave(out)
    setSaving(false)
  }

  const linkWarnings = (value: any): string[] => {
    const text = Array.isArray(value) ? value.join('\n') : typeof value === 'string' ? value : ''
    return text ? untrustedLinks(text) : []
  }

  function field(c: ColumnDef) {
    const id = `f-${c.name}`
    const label = fieldLabel(c.name) + (c.required ? ' *' : '')
    const v = rec[c.name]
    const base = 'w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500 ' + (errors[c.name] ? 'border-red-400' : 'border-gray-300')

    let input: React.ReactNode
    if (parentOptions && c.name === parentOptions.field) {
      input = (
        <select id={id} value={v ?? ''} onChange={(e) => set(c.name, e.target.value || null)} className={base + ' bg-white'}>
          <option value="">Choose…</option>
          {parentOptions.rows.map((p) => (
            <option key={p.id} value={p.id}>{String(p[parentOptions.titleField] ?? p.id)}</option>
          ))}
        </select>
      )
    } else if (c.type === 'boolean') {
      return (
        <label key={c.name} className="flex items-center gap-3 py-1 cursor-pointer">
          <input type="checkbox" checked={!!v} onChange={(e) => set(c.name, e.target.checked)} className="w-5 h-5 rounded border-gray-300 text-ocean-600 focus:ring-ocean-500" />
          <span className="text-sm font-medium text-gray-800">{fieldLabel(c.name)}</span>
        </label>
      )
    } else if (c.options?.length) {
      input = (
        <select id={id} value={v ?? ''} onChange={(e) => set(c.name, e.target.value)} className={base + ' bg-white'}>
          {c.options.map((o) => <option key={o} value={o}>{o.replace(/_/g, ' ')}</option>)}
        </select>
      )
    } else if (c.type === 'number') {
      input = <input id={id} type="number" value={v ?? ''} onChange={(e) => set(c.name, e.target.value === '' ? null : Number(e.target.value))} className={base + ' max-w-[10rem]'} />
    } else if (c.type === 'json') {
      input = (
        <textarea id={id} rows={5} value={jsonText[c.name] ?? ''} onChange={(e) => setJsonText((j) => ({ ...j, [c.name]: e.target.value }))} className={base + ' font-mono text-xs'} />
      )
    } else if (c.array) {
      input = (
        <>
          <textarea
            id={id}
            rows={Math.min(10, Math.max(3, (v?.length || 0) + 1))}
            value={Array.isArray(v) ? v.join('\n') : ''}
            onChange={(e) => set(c.name, e.target.value.split('\n').map((x) => x.trimEnd()).filter((x, i, a) => x || i < a.length - 1))}
            className={base}
          />
          <p className="text-xs text-gray-500 mt-1">One per line.</p>
        </>
      )
    } else if (c.type === 'date' || c.type === 'timestamp') {
      input = <input id={id} type="date" value={v ? String(v).slice(0, 10) : ''} onChange={(e) => set(c.name, e.target.value || null)} className={base + ' max-w-[12rem]'} />
    } else if (isColour(c.name)) {
      input = (
        <div className="flex items-center gap-2">
          <input type="color" value={/^#[0-9a-f]{6}$/i.test(v || '') ? v : '#00D9C4'} onChange={(e) => set(c.name, e.target.value)} className="h-10 w-14 rounded border border-gray-300" aria-label={`${fieldLabel(c.name)} picker`} />
          <input id={id} value={v ?? ''} onChange={(e) => set(c.name, e.target.value)} className={base + ' max-w-[10rem] font-mono'} />
        </div>
      )
    } else if (isLongText(c.name) || (typeof v === 'string' && v.length > 90)) {
      input = <textarea id={id} rows={Math.min(12, Math.max(3, Math.ceil(String(v ?? '').length / 80)))} value={v ?? ''} onChange={(e) => set(c.name, e.target.value)} className={base} />
    } else {
      input = (
        <>
          <input id={id} value={v ?? ''} onChange={(e) => set(c.name, e.target.value)} className={base} list={suggestions[c.name] ? `${id}-list` : undefined} />
          {suggestions[c.name] && (
            <datalist id={`${id}-list`}>{suggestions[c.name].map((s) => <option key={s} value={s} />)}</datalist>
          )}
        </>
      )
    }

    const warn = linkWarnings(v)
    return (
      <div key={c.name}>
        <label htmlFor={id} className="block text-sm font-medium text-gray-800 mb-1">{label}</label>
        {input}
        {errors[c.name] && <p className="text-xs text-red-600 mt-1">{errors[c.name]}</p>}
        {warn.length > 0 && (
          <p className="flex gap-1 text-xs text-amber-800 mt-1">
            <AlertTriangle className="w-3.5 h-3.5 flex-shrink-0 mt-0.5" />
            <span>
              {warn.length === 1 ? 'This link is' : 'These links are'} not from the NHS, Royal College of Psychiatrists, Mind or the Mental Health Foundation. That is fine for pointing people to a helpline, but health information should come from one of those sources.
            </span>
          </p>
        )}
      </div>
    )
  }

  return (
    <div className="fixed inset-0 z-50 flex justify-end bg-black/40" onClick={cancel}>
      <form
        onSubmit={submit}
        onClick={(e) => e.stopPropagation()}
        className="w-full max-w-xl h-full bg-white shadow-xl flex flex-col"
        aria-label={title}
      >
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 truncate pr-4">{title}</h2>
          <button type="button" onClick={cancel} className="p-2 text-gray-500 hover:text-gray-800 rounded-lg hover:bg-gray-100" aria-label="Close"><X className="w-5 h-5" /></button>
        </div>

        <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5">
          {main.map(field)}
          {advanced.length > 0 && (
            <details className="border border-gray-200 rounded-lg">
              <summary className="cursor-pointer px-4 py-2 text-sm font-medium text-gray-600">Advanced settings (rarely needed)</summary>
              <div className="px-4 pb-4 pt-2 space-y-4">{advanced.map(field)}</div>
            </details>
          )}
          <p className="text-xs text-gray-500 border-t border-gray-100 pt-4">
            House rule: health information must come from the NHS or a trusted source ({TRUSTED_DOMAINS.join(', ')}). Keep a note of where any new wording came from.
          </p>
        </div>

        <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-gray-200 bg-gray-50">
          <button type="button" onClick={cancel} className="px-4 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-200">Cancel</button>
          <button type="submit" disabled={saving || (!isNew && !dirty)} className="inline-flex items-center gap-2 px-5 py-2 text-sm font-medium text-white bg-ocean-700 rounded-lg hover:bg-ocean-800 disabled:opacity-50">
            {saving && <Loader2 className="w-4 h-4 animate-spin" />}
            {isNew ? 'Add' : dirty ? 'Save changes' : 'No changes'}
          </button>
        </div>
      </form>
    </div>
  )
}
