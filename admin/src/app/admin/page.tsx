'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import {
  Compass,
  PenLine,
  ShieldCheck,
  RefreshCw,
  Clock,
  ArrowRight,
  BarChart3,
  Info,
} from 'lucide-react'

interface Stats {
  totalContent: number
  publishedContent: number
  draftContent: number
  domains: number
  journeys: number
}

interface Recent {
  table: string
  id: string
  title: string
  at: string
  section: string
  list: string
}

interface LastAudit {
  completed_at: string
  system_score: number | null
  findings_critical: number | null
  findings_red: number | null
}

const TASKS = [
  {
    href: '/admin/content-manager',
    icon: PenLine,
    title: 'Change wording in the app',
    body: 'Tips, helplines, quizzes, checklists and every other tool.',
  },
  {
    href: '/admin/content/new',
    icon: Compass,
    title: 'Write a Navigate article',
    body: 'Add guidance to a topic such as Relationships or Family.',
  },
  {
    href: '/admin/audit',
    icon: ShieldCheck,
    title: 'Check content is safe and sourced',
    body: 'Run the content audit and review anything flagged.',
  },
  {
    href: '/admin/analytics',
    icon: BarChart3,
    title: 'See what people use',
    body: 'Anonymous usage across the app.',
  },
]

function ago(iso: string): string {
  const mins = Math.round((Date.now() - new Date(iso).getTime()) / 60000)
  if (mins < 60) return mins <= 1 ? 'just now' : `${mins} minutes ago`
  const hours = Math.round(mins / 60)
  if (hours < 24) return hours === 1 ? '1 hour ago' : `${hours} hours ago`
  const days = Math.round(hours / 24)
  if (days < 60) return days === 1 ? 'yesterday' : `${days} days ago`
  return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [recent, setRecent] = useState<Recent[] | null>(null)
  const [lastAudit, setLastAudit] = useState<LastAudit | null | undefined>(undefined)
  const [loading, setLoading] = useState(true)

  const load = async () => {
    setLoading(true)
    const [s, r] = await Promise.allSettled([
      fetch('/api/stats').then((res) => (res.ok ? res.json() : null)),
      fetch('/api/recent-changes').then((res) => (res.ok ? res.json() : null)),
    ])
    setStats(s.status === 'fulfilled' ? s.value : null)
    if (r.status === 'fulfilled' && r.value) {
      setRecent(r.value.recent)
      setLastAudit(r.value.lastAudit)
    } else {
      setRecent(null)
      setLastAudit(null)
    }
    setLoading(false)
  }

  useEffect(() => {
    load()
  }, [])

  const auditDays = lastAudit ? Math.round((Date.now() - new Date(lastAudit.completed_at).getTime()) / 86400000) : null

  return (
    <div className="p-4 sm:p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-start justify-between gap-4 mb-8">
          <div>
            <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">Welcome back</h1>
            <p className="text-gray-600 mt-1">What would you like to do today?</p>
          </div>
          <button
            onClick={load}
            className="flex items-center gap-2 px-3 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-100 bg-white"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          {TASKS.map((t) => (
            <Link key={t.href} href={t.href} className="group bg-white border border-gray-200 rounded-xl p-5 hover:shadow-md hover:border-ocean-200 transition">
              <div className="w-10 h-10 rounded-lg bg-ocean-50 text-ocean-700 flex items-center justify-center mb-3">
                <t.icon className="w-5 h-5" />
              </div>
              <p className="font-semibold text-gray-900 group-hover:text-ocean-700">{t.title}</p>
              <p className="text-sm text-gray-600 mt-1">{t.body}</p>
            </Link>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 bg-white border border-gray-200 rounded-xl p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-1">Recently changed</h2>
            <p className="text-sm text-gray-500 mb-4">The latest additions and edits across the app&apos;s content.</p>
            {recent === null && !loading ? (
              <p className="text-sm text-gray-500">Could not load recent changes.</p>
            ) : !recent ? (
              <div className="space-y-3">{[0, 1, 2].map((i) => <div key={i} className="h-10 bg-gray-100 rounded animate-pulse" />)}</div>
            ) : recent.length === 0 ? (
              <p className="text-sm text-gray-500">Nothing yet.</p>
            ) : (
              <ul className="divide-y divide-gray-100">
                {recent.map((r) => (
                  <li key={`${r.table}-${r.id}`}>
                    <Link href={`/admin/content-manager/edit/${r.table}?id=${r.id}`} className="flex items-center gap-3 py-3 hover:bg-gray-50 -mx-2 px-2 rounded-lg">
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-gray-900 truncate">{r.title || '(untitled)'}</p>
                        <p className="text-xs text-gray-500">{r.section} · {r.list}</p>
                      </div>
                      <span className="flex items-center gap-1 text-xs text-gray-500 flex-shrink-0">
                        <Clock className="w-3.5 h-3.5" /> {ago(r.at)}
                      </span>
                    </Link>
                  </li>
                ))}
              </ul>
            )}
          </div>

          <div className="space-y-6">
            <div className="bg-white border border-gray-200 rounded-xl p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-3">Content checks</h2>
              {lastAudit === undefined ? (
                <div className="h-12 bg-gray-100 rounded animate-pulse" />
              ) : lastAudit ? (
                <>
                  <p className="text-sm text-gray-700">
                    Last full audit {ago(lastAudit.completed_at)}
                    {lastAudit.system_score != null && <>, scoring <strong>{Math.round(lastAudit.system_score)}%</strong></>}.
                  </p>
                  {(lastAudit.findings_critical || 0) + (lastAudit.findings_red || 0) > 0 && (
                    <p className="text-sm text-red-700 mt-1">
                      {(lastAudit.findings_critical || 0) + (lastAudit.findings_red || 0)} serious findings to review.
                    </p>
                  )}
                  {auditDays != null && auditDays > 30 && (
                    <p className="text-sm text-amber-800 mt-1">It has been over a month. Run a fresh audit after any big content change.</p>
                  )}
                </>
              ) : (
                <p className="text-sm text-gray-700">No completed audit yet.</p>
              )}
              <Link href="/admin/audit" className="inline-flex items-center gap-1 mt-3 text-sm font-medium text-ocean-700 hover:text-ocean-900">
                Open content audit <ArrowRight className="w-4 h-4" />
              </Link>
            </div>

            <div className="bg-white border border-gray-200 rounded-xl p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-3">Navigate articles</h2>
              {stats ? (
                <dl className="grid grid-cols-3 gap-2 text-center">
                  <div><dt className="text-xs text-gray-500">Published</dt><dd className="text-xl font-bold text-gray-900">{stats.publishedContent}</dd></div>
                  <div><dt className="text-xs text-gray-500">Drafts</dt><dd className="text-xl font-bold text-gray-900">{stats.draftContent}</dd></div>
                  <div><dt className="text-xs text-gray-500">Topics</dt><dd className="text-xl font-bold text-gray-900">{stats.domains}</dd></div>
                </dl>
              ) : (
                <p className="text-sm text-gray-500">{loading ? 'Loading…' : 'Could not load.'}</p>
              )}
              {stats && stats.draftContent > 0 && (
                <Link href="/admin/content?filter=draft" className="inline-flex items-center gap-1 mt-3 text-sm font-medium text-ocean-700 hover:text-ocean-900">
                  Review drafts <ArrowRight className="w-4 h-4" />
                </Link>
              )}
            </div>
          </div>
        </div>

        <div className="mt-6 flex gap-3 p-5 rounded-xl border border-ocean-100 bg-ocean-50/60 text-sm text-ocean-900">
          <Info className="w-5 h-5 flex-shrink-0" />
          <div className="space-y-1">
            <p><strong>Good to know.</strong> Changes reach people the next time their app opens with an internet connection, so there is no publish step for most lists. Use &ldquo;Hide&rdquo; rather than delete if you might want something back.</p>
            <p>All health information must come from the NHS or a trusted source (Royal College of Psychiatrists, Mind, Mental Health Foundation). <Link href="/admin/help" className="underline font-medium">Read the guide</Link>.</p>
          </div>
        </div>
      </div>
    </div>
  )
}
