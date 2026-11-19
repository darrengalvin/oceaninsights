'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { ChevronRight, Search } from 'lucide-react';
import { createClient } from '@/lib/supabase/client';
import { SECTIONS, SectionDef } from '@/lib/content-sections';

const GROUP_ORDER: SectionDef['group'][] = ['Everyday tools', 'Support topics', 'Young people', 'Service life', 'App-wide'];

export default function ContentManagerPage() {
  const supabase = useMemo(() => createClient(), []);
  const [counts, setCounts] = useState<Record<string, number | null>>({});
  const [query, setQuery] = useState('');

  useEffect(() => {
    // Count the items in each section's lists, all at once.
    Promise.all(
      SECTIONS.map(async (s) => {
        const results = await Promise.all(
          s.tables.filter((t) => !t.notInApp).map((t) => supabase.from(t.table).select('*', { count: 'exact', head: true }))
        );
        const failed = results.some((r) => r.error);
        return [s.slug, failed ? null : results.reduce((sum, r) => sum + (r.count || 0), 0)] as const;
      })
    ).then((pairs) => setCounts(Object.fromEntries(pairs)));
  }, [supabase]);

  const q = query.trim().toLowerCase();
  const matches = (s: SectionDef) =>
    !q || s.label.toLowerCase().includes(q) || s.appLocation.toLowerCase().includes(q) || s.tables.some((t) => t.label.toLowerCase().includes(q));

  return (
    <div className="p-4 sm:p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Content Manager</h1>
        <p className="text-gray-600 mt-1 max-w-2xl">
          Every tool and topic in the app that you can change. Open a section to add items, or use <strong>Fix wording</strong> to edit any existing item.
          Changes reach people the next time their app opens with an internet connection.
        </p>
      </div>

      <label className="relative block mb-8 max-w-md">
        <span className="sr-only">Find a section</span>
        <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Find a section, for example helplines or quiz"
          className="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-ocean-500"
        />
      </label>

      {GROUP_ORDER.map((group) => {
        const sections = SECTIONS.filter((s) => s.group === group && matches(s));
        if (!sections.length) return null;
        return (
          <section key={group} className="mb-10">
            <h2 className="text-sm font-semibold uppercase tracking-wider text-gray-500 mb-3">{group}</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {sections.map((s) => {
                const count = counts[s.slug];
                return (
                  <div key={s.slug} className="bg-white border border-gray-200 rounded-xl p-5 flex flex-col hover:shadow-md transition">
                    <Link href={s.href} className="group flex-1">
                      <div className="flex items-start justify-between gap-2">
                        <h3 className="font-semibold text-gray-900 group-hover:text-ocean-700">{s.label}</h3>
                        <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-ocean-600 flex-shrink-0" />
                      </div>
                      <p className="text-sm text-gray-600 mt-1">{s.appLocation}</p>
                    </Link>
                    <div className="flex items-center justify-between mt-4 pt-3 border-t border-gray-100 text-sm">
                      <span className="text-gray-500">
                        {count === undefined ? 'Counting…' : count === null ? 'Could not count' : `${count} ${count === 1 ? 'item' : 'items'}`}
                      </span>
                      <Link href={`/admin/content-manager/edit/${s.tables[0].table}`} className="font-medium text-ocean-700 hover:text-ocean-900">
                        Fix wording
                      </Link>
                    </div>
                  </div>
                );
              })}
            </div>
          </section>
        );
      })}

      {q && SECTIONS.every((s) => !matches(s)) && (
        <p className="text-gray-600">No section matches &ldquo;{query}&rdquo;. Try a different word, or look in the sidebar for Navigate articles, Rituals, Scenarios and Protocols.</p>
      )}
    </div>
  );
}
