import Link from 'next/link'
import { SECTIONS } from '@/lib/content-sections'

export const metadata = { title: 'Help and guide · Below the Surface admin' }

const LIVE_ELSEWHERE = [
  { label: 'Navigate articles', href: '/admin/content', where: 'Articles inside each topic on the Navigate screen. Drafts stay hidden until you publish them.' },
  { label: 'Ritual topics', href: '/admin/rituals', where: 'Ritual packs people can follow day by day. Only published topics appear.' },
  { label: 'Scenarios', href: '/admin/scenarios', where: 'Decision training: a situation, choices and what happens next. Only published scenarios appear.' },
  { label: 'Protocols', href: '/admin/protocols', where: 'Step-by-step communication guides. Only published protocols appear.' },
]

export default function HelpPage() {
  return (
    <div className="p-4 sm:p-8">
      <article className="max-w-3xl mx-auto space-y-10 text-gray-800">
        <header>
          <h1 className="text-3xl font-bold text-gray-900">Help and guide</h1>
          <p className="text-gray-600 mt-2">How to add and change what people see in the Below the Surface app.</p>
        </header>

        <section className="space-y-3">
          <h2 className="text-xl font-semibold text-gray-900">The rules for all content</h2>
          <ul className="list-disc pl-5 space-y-2">
            <li>
              <strong>Use the NHS or a trusted source.</strong> Health and mental health information must reflect the NHS, the Royal College of Psychiatrists, Mind or
              the Mental Health Foundation. Keep a note of the web page you took it from, so it can go in the source pack.
            </li>
            <li>The editor warns you when a link is not from one of those sites. Links to a helpline such as Samaritans are fine; health facts are not.</li>
            <li>Do not suggest that any armed service or organisation endorses the app.</li>
            <li>Write in plain, kind, UK English. If something could worry a reader, point them to a helpline.</li>
          </ul>
        </section>

        <section className="space-y-3">
          <h2 className="text-xl font-semibold text-gray-900">Changing wording</h2>
          <ol className="list-decimal pl-5 space-y-2">
            <li>Open <Link href="/admin/content-manager" className="text-ocean-700 underline">Content Manager</Link> and choose the section, or search for it.</li>
            <li>At the top of every section there is a <strong>Fix wording in</strong> row. Pick the list you want, for example &ldquo;Tips&rdquo;.</li>
            <li>Click <strong>Edit</strong> next to the item, change the text, and press <strong>Save changes</strong>. A green message confirms it saved; a red one explains what went wrong.</li>
            <li>Use the arrows to change the order, and the eye button to hide something without deleting it.</li>
          </ol>
          <p className="text-sm text-gray-600">
            There is no separate publish step for these lists. People see the change the next time their app opens with an internet connection.
          </p>
        </section>

        <section className="space-y-3">
          <h2 className="text-xl font-semibold text-gray-900">Where each section shows in the app</h2>
          <div className="bg-white border border-gray-200 rounded-xl divide-y divide-gray-100">
            {LIVE_ELSEWHERE.map((s) => (
              <div key={s.href} className="p-4">
                <Link href={s.href} className="font-medium text-ocean-700 hover:underline">{s.label}</Link>
                <p className="text-sm text-gray-600">{s.where}</p>
              </div>
            ))}
            {SECTIONS.map((s) => (
              <div key={s.slug} className="p-4">
                <Link href={s.href} className="font-medium text-ocean-700 hover:underline">{s.label}</Link>
                <p className="text-sm text-gray-600">{s.appLocation}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="space-y-3">
          <h2 className="text-xl font-semibold text-gray-900">Things the admin cannot change yet</h2>
          <ul className="list-disc pl-5 space-y-2">
            <li>
              <strong>Learn articles</strong> (Brain Science, Psychology, Life Situations) are built into the app. The Learn Articles page here stores drafts, but the app
              does not read them yet. Send new wording and its source to the developer.
            </li>
            <li><strong>Journeys</strong> are not shown in the app yet.</li>
            <li>A few lists inside Sex education and Bullying support are marked &ldquo;not in app yet&rdquo; for the same reason.</li>
          </ul>
        </section>

        <section className="space-y-3">
          <h2 className="text-xl font-semibold text-gray-900">Checking content</h2>
          <p>
            The <Link href="/admin/audit" className="text-ocean-700 underline">Content audit</Link> reviews everything against safety, clinical and source rules
            and gives each item a traffic-light score. Run it after a big change, and work through anything red first.
          </p>
        </section>

        <section className="space-y-3">
          <h2 className="text-xl font-semibold text-gray-900">If something goes wrong</h2>
          <ul className="list-disc pl-5 space-y-2">
            <li>If a save fails, the red message says why. Copy it and send it to the developer.</li>
            <li>If you are signed out, sign in again; unsaved changes in an open edit panel will be lost, so save often.</li>
          </ul>
        </section>
      </article>
    </div>
  )
}
