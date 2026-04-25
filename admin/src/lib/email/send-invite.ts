import { Resend } from 'resend'
import { renderInviteEmail } from './invite-template'

interface SendInviteOptions {
  toEmail: string
  recipientName: string | null
  identifier: string
  organizationName: string
  organizationType: string
  contactEmail: string | null
  code: string
}

interface SendInviteResult {
  ok: boolean
  skipped?: boolean
  reason?: string
  resendId?: string
}

const SITE_URL_FALLBACK = 'https://admin-pi-eosin-53.vercel.app'

export async function sendInviteEmail(opts: SendInviteOptions): Promise<SendInviteResult> {
  const apiKey = process.env.RESEND_API_KEY
  if (!apiKey || apiKey === 're_...') {
    return {
      ok: false,
      skipped: true,
      reason: 'RESEND_API_KEY not configured. Email skipped - codes are still generated and visible in the admin.',
    }
  }

  const fromEmail = process.env.RESEND_FROM_EMAIL || 'invites@belowthesurface.app'
  const fromName = process.env.RESEND_FROM_NAME || 'Below the Surface'
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || SITE_URL_FALLBACK
  const magicLinkUrl = `${siteUrl}/r/${encodeURIComponent(opts.code)}`

  const { subject, html, text } = renderInviteEmail({
    recipientName: opts.recipientName,
    identifier: opts.identifier,
    organizationName: opts.organizationName,
    organizationType: opts.organizationType,
    magicLinkUrl,
    fallbackCode: opts.code,
    contactEmail: opts.contactEmail,
  })

  try {
    const resend = new Resend(apiKey)
    const { data, error } = await resend.emails.send({
      from: `${fromName} <${fromEmail}>`,
      to: [opts.toEmail],
      subject,
      html,
      text,
    })
    if (error) {
      return { ok: false, reason: error.message || 'Resend rejected the message' }
    }
    return { ok: true, resendId: data?.id }
  } catch (err) {
    return {
      ok: false,
      reason: err instanceof Error ? err.message : String(err),
    }
  }
}
