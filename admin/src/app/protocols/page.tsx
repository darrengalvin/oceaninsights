import { supabase } from '@/lib/supabase'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function ProtocolsPage() {
  const { data: protocols, error } = await supabase
    .from('protocols')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          Error loading protocols: {error.message}
        </div>
      </div>
    )
  }

  const categoryBadgeColor = (category: string) => {
    const colors: Record<string, string> = {
      communication: 'bg-blue-100 text-blue-700',
      conflict: 'bg-orange-100 text-orange-700',
      'self-regulation': 'bg-green-100 text-green-700',
      trust: 'bg-purple-100 text-purple-700',
      recovery: 'bg-teal-100 text-teal-700',
    }
    return colors[category] || 'bg-gray-100 text-gray-700'
  }

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Communication Protocols</h1>
          <p className="text-gray-600 mt-1">Manage step-by-step communication guides</p>
        </div>
        <Link
          href="/protocols/new"
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
        >
          + New Protocol
        </Link>
      </div>

      {protocols && protocols.length === 0 ? (
        <div className="bg-gray-50 border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
          <div className="text-gray-400 mb-4">
            <svg className="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No protocols yet</h3>
          <p className="text-gray-500 mb-6">Create your first communication protocol.</p>
          <Link
            href="/protocols/new"
            className="inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors"
          >
            Create First Protocol
          </Link>
        </div>
      ) : (
        <div className="grid gap-4">
          {protocols?.map((protocol: any) => (
            <div key={protocol.id} className="bg-white rounded-lg shadow p-6 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="text-lg font-semibold text-gray-900">{protocol.title}</h3>
                    <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${categoryBadgeColor(protocol.category)}`}>
                      {protocol.category.replace('-', ' ')}
                    </span>
                    {protocol.published ? (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                        Published
                      </span>
                    ) : (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">
                        Draft
                      </span>
                    )}
                  </div>
                  
                  {protocol.description && (
                    <p className="text-sm text-gray-600 mb-3">{protocol.description}</p>
                  )}

                  <div className="flex items-center gap-4 text-sm text-gray-500">
                    <span>📋 {Array.isArray(protocol.steps) ? protocol.steps.length : 0} steps</span>
                    {protocol.when_to_use && <span>✅ When to use defined</span>}
                    {protocol.when_not_to_use && <span>⚠️ When NOT to use defined</span>}
                  </div>
                </div>

                <div className="flex gap-2">
                  <Link
                    href={`/protocols/${protocol.id}`}
                    className="px-4 py-2 text-blue-600 hover:bg-blue-50 rounded-lg font-medium transition-colors"
                  >
                    Edit
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="mt-6 flex items-center justify-between text-sm text-gray-600">
        <div>
          Showing {protocols?.length || 0} protocol{protocols?.length !== 1 ? 's' : ''}
        </div>
        <Link href="/scenarios" className="text-blue-600 hover:text-blue-900">
          ← Back to Scenarios
        </Link>
      </div>
    </div>
  )
}

