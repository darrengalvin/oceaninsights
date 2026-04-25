import { supabaseAdmin } from '@/lib/supabase'
import Link from 'next/link'
import RedemptionLanding from './RedemptionLanding'

export const dynamic = 'force-dynamic'

interface PageProps {
  params: { code: string }
}

const APP_STORE_URL = 'https://apps.apple.com/app/below-the-surface/id6747486577'
const APP_SCHEME_URL = (code: string) => `belowthesurface://r/${encodeURIComponent(code)}`

export default async function RedemptionPage({ params }: PageProps) {
  const code = decodeURIComponent(params.code).toUpperCase().trim()

  let organizationName: string | null = null
  let recipientIdentifier: string | null = null
  let recipientName: string | null = null
  let isValid = false
  let alreadyRedeemed = false

  if (code) {
    const { data: codeRow } = await supabaseAdmin
      .from('access_codes')
      .select('id, code, organization_id, recipient_id, redeemed_at, is_active, expires_at')
      .eq('code', code)
      .maybeSingle()

    if (codeRow && codeRow.is_active) {
      const { data: org } = await supabaseAdmin
        .from('organizations')
        .select('name, is_active, contract_ends_on')
        .eq('id', codeRow.organization_id)
        .single()

      if (org && org.is_active) {
        organizationName = org.name
        isValid = true
        alreadyRedeemed = !!codeRow.redeemed_at

        if (codeRow.recipient_id) {
          const { data: recipient } = await supabaseAdmin
            .from('recipients')
            .select('identifier, display_name')
            .eq('id', codeRow.recipient_id)
            .single()
          if (recipient) {
            recipientIdentifier = recipient.identifier
            recipientName = recipient.display_name
          }
        }
      }
    }
  }

  if (!isValid) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 flex items-center justify-center p-6">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8 text-center">
          <div className="w-16 h-16 bg-red-50 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#dc2626" strokeWidth="2">
              <circle cx="12" cy="12" r="10" />
              <line x1="15" y1="9" x2="9" y2="15" />
              <line x1="9" y1="9" x2="15" y2="15" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-slate-900 mb-2">Code not recognised</h1>
          <p className="text-slate-600 mb-6">
            This invite link is invalid or has been deactivated. If you believe this is a
            mistake, please contact your welfare officer or sponsor.
          </p>
          <code className="inline-block px-3 py-1.5 bg-slate-100 rounded-md text-sm font-mono text-slate-500">
            {code || 'No code provided'}
          </code>
          <div className="mt-8 pt-6 border-t border-slate-100 text-sm text-slate-500">
            <Link href="/" className="text-ocean-600 hover:underline">
              Below the Surface home
            </Link>
          </div>
        </div>
      </main>
    )
  }

  return (
    <RedemptionLanding
      code={code}
      organizationName={organizationName!}
      recipientIdentifier={recipientIdentifier}
      recipientName={recipientName}
      alreadyRedeemed={alreadyRedeemed}
      appStoreUrl={APP_STORE_URL}
      appSchemeUrl={APP_SCHEME_URL(code)}
    />
  )
}
