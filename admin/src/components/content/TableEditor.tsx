'use client'

import { useCallback, useEffect, useMemo, useState } from 'react'
import Link from 'next/link'
import { useSearchParams } from 'next/navigation'
import {
  AlertTriangle,
  ArrowDown,
  ArrowLeft,
  ArrowUp,
  Eye,
  EyeOff,
  Loader2,
  Pencil,
  Plus,
  Search,
  Trash2,
} from 'lucide-react'
import { createClient } from '@/lib/supabase/client'
import {
  ColumnDef,
  SYSTEM_FIELDS,
  TableDef,
  findTable,
} from '@/lib/content-sections'
import { TABLE_COLUMNS } from '@/lib/content-schema'
import RecordForm, { blankRecord, columnsFor } from './RecordForm'
import { useToast } from './Toast'

type Row = Record<string, any>

const ORDER_FIELDS = ['sort_order', 'display_order', 'step_number', 'option_index']

function orderField(cols: ColumnDef[]): string | null {
  return ORDER_FIELDS.find((f) => cols.some((c) => c.name === f)) ?? null
}

function activeField(cols: ColumnDef[]): string | null {
  if (cols.some((c) => c.name === 'is_active')) return 'is_active'
  if (cols.some((c) => c.name === 'is_published')) return 'is_published'
  return null
}

function preview(row: Row, def: TableDef, cols: ColumnDef[]): string {
  const other = cols.find(
    (c) => c.type === 'text' && !c.array && c.name !== def.titleField && !SYSTEM_FIELDS.has(c.name) && typeof row[c.name] === 'string' && row[c.name].length > 20
  )
  return other ? String(row[other.name]) : ''
}

export default function TableEditor({ table }: { table: string }) {
  const found = findTable(table)
  const supabase = useMemo(() => createClient(), [])
  const toast = useToast()

  const [rows, setRows] = useState<Row[]>([])
  const [loading, setLoading] = useState(true)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [parents, setParents] = useState<Row[]>([])
  const [parentFilter, setParentFilter] = useState<string>('')
  const [query, setQuery] = useState('')
  const [editing, setEditing] = useState<Row | null>(null)
  const [isNew, setIsNew] = useState(false)
  const [busyId, setBusyId] = useState<string | null>(null)
  const params = useSearchParams()
  const [openedFromLink, setOpenedFromLink] = useState(false)

  const def = found?.def
  const section = found?.section
  const parentCol = def?.parentField ? (TABLE_COLUMNS[table] || []).find((c) => c.name === def.parentField) : undefined
  const parentDef = parentCol?.ref ? findTable(parentCol.ref)?.def : undefined

  const cols = useMemo(() => columnsFor(table, rows), [table, rows])
  const order = orderField(cols)
  const active = activeField(cols)

  const load = useCallback(async () => {
    setLoading(true)
    setLoadError(null)
    let q = supabase.from(table).select('*')
    const schemaCols = TABLE_COLUMNS[table] || []
    const of = orderField(schemaCols)
    q = of ? q.order(of, { ascending: true }) : q.order('created_at', { ascending: true })
    const { data, error } = await q
    if (error) {
      setLoadError(error.message)
      setRows([])
    } else {
      setRows(data || [])
    }
    if (parentCol?.ref && parentDef) {
      const p = await supabase.from(parentCol.ref).select(`id, ${parentDef.titleField}`)
      if (!p.error) setParents(p.data || [])
    }
    setLoading(false)
  }, [supabase, table, parentCol?.ref, parentDef])

  useEffect(() => {
    load()
  }, [load])

  // Links such as ?id=<row> or ?new=1 open that item straight away.
  useEffect(() => {
    if (loading || openedFromLink) return
    const id = params.get('id')
    if (id) {
      const row = rows.find((r) => String(r.id) === id)
      if (row) { setIsNew(false); setEditing(row) }
    } else if (params.get('new') === '1') {
      startNew()
    }
    setOpenedFromLink(true)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [loading, rows, params, openedFromLink])

  if (!found || !def || !section) {
    return (
      <div className="p-8">
        <p className="text-gray-700">This list cannot be edited here.</p>
        <Link href="/admin/content-manager" className="text-ocean-700 underline">Back to Content Manager</Link>
      </div>
    )
  }

  const parentName = (id: string) => {
    const p = parents.find((x) => x.id === id)
    return p && parentDef ? String(p[parentDef.titleField] ?? '') : ''
  }

  // Keep children grouped under their parent, in the parent's order.
  const parentRank = (id: any) => {
    const i = parents.findIndex((p) => p.id === id)
    return i === -1 ? Number.MAX_SAFE_INTEGER : i
  }
  const sorted = def.parentField
    ? [...rows].sort((a, b) => parentRank(a[def.parentField!]) - parentRank(b[def.parentField!]) || (order ? Number(a[order] ?? 0) - Number(b[order] ?? 0) : 0))
    : rows
  const siblings = (row: Row) => (def.parentField ? visible.filter((r) => r[def.parentField!] === row[def.parentField!]) : visible)

  const visible = sorted.filter((r) => {
    if (parentFilter && r[def.parentField!] !== parentFilter) return false
    if (!query.trim()) return true
    const q = query.toLowerCase()
    return Object.values(r).some((v) => (Array.isArray(v) ? v.join(' ') : String(v ?? '')).toLowerCase().includes(q))
  })

  const canReorder = !!order && !query.trim()

  async function save(record: Row) {
    const clean: Row = {}
    for (const [k, v] of Object.entries(record)) {
      if (SYSTEM_FIELDS.has(k)) continue
      clean[k] = v
    }
    if (cols.some((c) => c.name === 'updated_at')) clean.updated_at = new Date().toISOString()

    const res = isNew
      ? await supabase.from(table).insert(clean).select().single()
      : await supabase.from(table).update(clean).eq('id', record.id).select().single()

    if (res.error) {
      toast.error(`Not saved: ${res.error.message}`)
      return false
    }
    toast.success(isNew ? 'Added. It will appear in the app next time it syncs.' : 'Saved. The app picks this up next time it syncs.')
    setEditing(null)
    await load()
    return true
  }

  async function toggleActive(row: Row) {
    if (!active) return
    setBusyId(row.id)
    const { error } = await supabase.from(table).update({ [active]: !row[active] }).eq('id', row.id)
    setBusyId(null)
    if (error) return toast.error(`Could not change visibility: ${error.message}`)
    toast.success(row[active] ? 'Hidden from the app.' : 'Shown in the app.')
    load()
  }

  async function remove(row: Row) {
    const name = String(row[def!.titleField] ?? 'this item').slice(0, 80)
    const hint = active ? '\n\nTip: you can hide it instead, which keeps it for later.' : ''
    if (!window.confirm(`Delete "${name}" permanently?${hint}`)) return
    setBusyId(row.id)
    const { error } = await supabase.from(table).delete().eq('id', row.id)
    setBusyId(null)
    if (error) return toast.error(`Not deleted: ${error.message}`)
    toast.success('Deleted.')
    load()
  }

  async function move(row: Row, dir: -1 | 1) {
    if (!order) return
    const list = siblings(row)
    const i = list.findIndex((r) => r.id === row.id)
    const other = list[i + dir]
    if (!other) return
    setBusyId(row.id)
    // Give the pair distinct positions even if they currently share a number.
    const a = Number(row[order] ?? i)
    const b = Number(other[order] ?? i + dir)
    const [na, nb] = a === b ? [b + dir, a] : [b, a]
    const r1 = await supabase.from(table).update({ [order]: na }).eq('id', row.id)
    const r2 = await supabase.from(table).update({ [order]: nb }).eq('id', other.id)
    setBusyId(null)
    if (r1.error || r2.error) return toast.error(`Could not reorder: ${(r1.error || r2.error)!.message}`)
    load()
  }

  function startNew() {
    const rec = blankRecord(cols)
    if (order) rec[order] = rows.reduce((m, r) => Math.max(m, Number(r[order]) || 0), 0) + 1
    if (def!.parentField && parentFilter) rec[def!.parentField] = parentFilter
    setIsNew(true)
    setEditing(rec)
  }

  return (
    <div className="p-4 sm:p-8 max-w-5xl mx-auto">
      <Link href={section.href} className="inline-flex items-center gap-1 text-sm text-ocean-700 hover:text-ocean-900 mb-4">
        <ArrowLeft className="w-4 h-4" /> Back to {section.label}
      </Link>

      <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-6">
        <div>
          <p className="text-sm font-medium text-gray-500">{section.label}</p>
          <h1 className="text-2xl font-bold text-gray-900">{def.label}</h1>
          <p className="text-gray-600 mt-1 max-w-2xl">{section.appLocation}</p>
        </div>
        <button
          onClick={startNew}
          className="inline-flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium text-white bg-ocean-700 rounded-lg hover:bg-ocean-800"
        >
          <Plus className="w-4 h-4" /> Add new
        </button>
      </div>

      {def.notInApp && (
        <div className="flex gap-3 p-4 mb-6 rounded-xl border border-amber-300 bg-amber-50 text-amber-900">
          <AlertTriangle className="w-5 h-5 flex-shrink-0 mt-0.5" />
          <p className="text-sm">
            <strong>The app does not show this list yet.</strong> You can prepare wording here, but people using the app will not see it until a developer connects it.
          </p>
        </div>
      )}

      <div className="flex flex-col sm:flex-row gap-3 mb-4">
        <label className="relative flex-1">
          <span className="sr-only">Search</span>
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={`Search ${def.label.toLowerCase()}`}
            className="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-ocean-500"
          />
        </label>
        {def.parentField && parentDef && (
          <select
            value={parentFilter}
            onChange={(e) => setParentFilter(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg bg-white"
            aria-label={`Filter by ${parentDef.label}`}
          >
            <option value="">All {parentDef.label.toLowerCase()}</option>
            {parents.map((p) => (
              <option key={p.id} value={p.id}>{String(p[parentDef.titleField] ?? p.id)}</option>
            ))}
          </select>
        )}
      </div>

      {loading ? (
        <div className="flex items-center gap-2 text-gray-500 py-12 justify-center">
          <Loader2 className="w-5 h-5 animate-spin" /> Loading…
        </div>
      ) : loadError ? (
        <div className="p-4 rounded-xl border border-red-200 bg-red-50 text-red-800 text-sm">
          Could not load this list: {loadError}
        </div>
      ) : visible.length === 0 ? (
        <div className="text-center py-12 bg-white border border-dashed border-gray-300 rounded-xl">
          <p className="text-gray-600">{rows.length === 0 ? 'Nothing here yet.' : 'Nothing matches your search.'}</p>
          {rows.length === 0 && (
            <button onClick={startNew} className="mt-3 text-ocean-700 font-medium underline">Add the first one</button>
          )}
        </div>
      ) : (
        <>
          <p className="text-sm text-gray-500 mb-2">
            {visible.length} of {rows.length} {rows.length === 1 ? 'item' : 'items'}
            {canReorder ? '. Use the arrows to change the order people see.' : ''}
          </p>
          <ul className="bg-white border border-gray-200 rounded-xl divide-y divide-gray-100">
            {visible.map((row, i) => {
              const hidden = active ? row[active] === false : false
              const sub = preview(row, def, cols)
              return (
                <li key={row.id} className={`flex items-start gap-3 p-4 ${hidden ? 'bg-gray-50' : ''}`}>
                  {canReorder && (
                    <div className="flex flex-col">
                      <button onClick={() => move(row, -1)} disabled={siblings(row)[0]?.id === row.id || busyId === row.id} className="p-1 text-gray-400 hover:text-gray-700 disabled:opacity-30" aria-label="Move up"><ArrowUp className="w-4 h-4" /></button>
                      <button onClick={() => move(row, 1)} disabled={siblings(row).at(-1)?.id === row.id || busyId === row.id} className="p-1 text-gray-400 hover:text-gray-700 disabled:opacity-30" aria-label="Move down"><ArrowDown className="w-4 h-4" /></button>
                    </div>
                  )}
                  <button onClick={() => { setIsNew(false); setEditing(row) }} className="flex-1 min-w-0 text-left">
                    <p className={`font-medium ${hidden ? 'text-gray-500' : 'text-gray-900'}`}>
                      {row.emoji ? `${row.emoji} ` : ''}{String(row[def.titleField] ?? '(untitled)')}
                    </p>
                    {sub && <p className="text-sm text-gray-500 line-clamp-2">{sub}</p>}
                    <div className="flex flex-wrap gap-2 mt-1">
                      {def.parentField && parentName(row[def.parentField]) && (
                        <span className="text-xs px-2 py-0.5 rounded bg-ocean-50 text-ocean-800">{parentName(row[def.parentField])}</span>
                      )}
                      {hidden && <span className="text-xs px-2 py-0.5 rounded bg-gray-200 text-gray-700">Hidden from app</span>}
                    </div>
                  </button>
                  <div className="flex items-center gap-1 flex-shrink-0">
                    <button onClick={() => { setIsNew(false); setEditing(row) }} className="inline-flex items-center gap-1 px-3 py-1.5 text-sm font-medium text-ocean-800 bg-ocean-50 rounded-lg hover:bg-ocean-100">
                      <Pencil className="w-4 h-4" /> Edit
                    </button>
                    {active && (
                      <button onClick={() => toggleActive(row)} disabled={busyId === row.id} className="p-2 text-gray-500 hover:text-gray-800 rounded-lg hover:bg-gray-100" title={hidden ? 'Show in the app' : 'Hide from the app'} aria-label={hidden ? 'Show in the app' : 'Hide from the app'}>
                        {hidden ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    )}
                    <button onClick={() => remove(row)} disabled={busyId === row.id} className="p-2 text-red-500 hover:text-red-700 rounded-lg hover:bg-red-50" title="Delete" aria-label="Delete">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </li>
              )
            })}
          </ul>
        </>
      )}

      {editing && (
        <RecordForm
          title={isNew ? `Add to ${def.label.toLowerCase()}` : `Edit ${String(editing[def.titleField] ?? '').slice(0, 60) || 'item'}`}
          table={table}
          columns={cols}
          initial={editing}
          isNew={isNew}
          titleField={def.titleField}
          parentOptions={def.parentField && parentDef ? { field: def.parentField, label: parentDef.label, titleField: parentDef.titleField, rows: parents } : undefined}
          rows={rows}
          onCancel={() => setEditing(null)}
          onSave={save}
        />
      )}
    </div>
  )
}

