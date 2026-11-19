'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Info, Pencil } from 'lucide-react'
import { findSectionByPath } from '@/lib/content-sections'

// Shown at the top of every content section: where it appears in the app,
// and a link to edit the wording of any item in each of its lists.
export default function SectionBar() {
  const pathname = usePathname()
  const section = findSectionByPath(pathname)
  if (!section) return null

  return (
    <div className="mx-4 sm:mx-8 mt-4 sm:mt-6 max-w-6xl xl:mx-auto p-4 rounded-xl border border-ocean-100 bg-ocean-50/60">
      <div className="flex gap-2 text-sm text-ocean-900">
        <Info className="w-4 h-4 flex-shrink-0 mt-0.5" />
        <p>
          <strong>In the app:</strong> {section.appLocation} Changes reach people the next time their app opens with an internet connection.
        </p>
      </div>
      <div className="flex flex-wrap items-center gap-2 mt-3">
        <span className="text-xs font-medium text-gray-600">Fix wording in:</span>
        {section.tables.map((t) => (
          <Link
            key={t.table}
            href={`/admin/content-manager/edit/${t.table}`}
            className="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-medium rounded-full bg-white border border-ocean-200 text-ocean-800 hover:bg-ocean-100"
          >
            <Pencil className="w-3 h-3" /> {t.label}
            {t.notInApp && <span className="text-amber-700">(not in app yet)</span>}
          </Link>
        ))}
      </div>
    </div>
  )
}
