import { supabase } from '@/lib/supabase'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function ScenariosPage() {
  // Fetch scenarios with their content pack
  const { data: scenarios, error } = await supabase
    .from('scenarios')
    .select(`
      *,
      content_pack:content_packs(id, name),
      options:scenario_options(id)
    `)
    .order('created_at', { ascending: false })

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          Error loading scenarios: {error.message}
        </div>
      </div>
    )
  }

  const contextBadgeColor = (context: string) => {
    const colors: Record<string, string> = {
      hierarchy: 'bg-purple-100 text-purple-700',
      peer: 'bg-blue-100 text-blue-700',
      'high-pressure': 'bg-orange-100 text-orange-700',
      'close-quarters': 'bg-teal-100 text-teal-700',
      leadership: 'bg-indigo-100 text-indigo-700',
    }
    return colors[context] || 'bg-gray-100 text-gray-700'
  }

  const difficultyStars = (difficulty: number) => {
    return '★'.repeat(difficulty) + '☆'.repeat(3 - difficulty)
  }

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Decision Training Scenarios</h1>
          <p className="text-gray-600 mt-1">Manage workplace scenario training content</p>
        </div>
        <Link
          href="/scenarios/new"
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
        >
          + New Scenario
        </Link>
      </div>

      {scenarios && scenarios.length === 0 ? (
        <div className="bg-gray-50 border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
          <div className="text-gray-400 mb-4">
            <svg className="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No scenarios yet</h3>
          <p className="text-gray-500 mb-6">Get started by creating your first decision training scenario.</p>
          <Link
            href="/scenarios/new"
            className="inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors"
          >
            Create First Scenario
          </Link>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Scenario
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Context
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Difficulty
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Options
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {scenarios?.map((scenario: any) => (
                <tr key={scenario.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="text-sm font-medium text-gray-900">{scenario.title}</div>
                    <div className="text-sm text-gray-500 truncate max-w-md">{scenario.situation}</div>
                    {scenario.content_pack && (
                      <div className="text-xs text-gray-400 mt-1">
                        📦 {scenario.content_pack.name}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${contextBadgeColor(scenario.context)}`}>
                      {scenario.context.replace('-', ' ')}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-sm text-gray-900">{difficultyStars(scenario.difficulty)}</span>
                    <div className="text-xs text-gray-500">Level {scenario.difficulty}</div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-900">
                    {scenario.options?.length || 0} options
                  </td>
                  <td className="px-6 py-4">
                    {scenario.published ? (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                        Published
                      </span>
                    ) : (
                      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">
                        Draft
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 text-right text-sm font-medium">
                    <Link
                      href={`/scenarios/${scenario.id}`}
                      className="text-blue-600 hover:text-blue-900 mr-4"
                    >
                      Edit
                    </Link>
                    <Link
                      href={`/scenarios/${scenario.id}/preview`}
                      className="text-gray-600 hover:text-gray-900"
                    >
                      Preview
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <div className="mt-6 flex items-center justify-between text-sm text-gray-600">
        <div>
          Showing {scenarios?.length || 0} scenario{scenarios?.length !== 1 ? 's' : ''}
        </div>
        <Link href="/protocols" className="text-blue-600 hover:text-blue-900">
          Manage Protocols →
        </Link>
      </div>
    </div>
  )
}

