import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { reissueCodeForRecipient } from '@/lib/sponsorship-server'
import { sendInviteEmail } from '@/lib/email/send-invite'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const body = await req.json().catch(() => ({}))

    const { data: recipient, error: rErr } = await supabaseAdmin
      .from('recipients')
      .select('id, organization_id, identifier, display_name, email, reissue_count')
      .eq('id', params.id)
      .single()
    if (rErr || !recipient) {
      return NextResponse.json({ error: 'Recipient not found' }, { status: 404 })
    }

    const { data: org, error: oErr } = await supabaseAdmin
      .from('organizations')
      .select('name, type, contact_email, allow_reissue, max_reissues_per_recipient')
      .eq('id', recipient.organization_id)
      .single()
    if (oErr || !org) {
      return NextResponse.json({ error: 'Organisation not found' }, { status: 404 })
    }

    if (!org.allow_reissue) {
      return NextResponse.json(
        { error: 'Reissuing codes is disabled for this organisation' },
        { status: 403 }
      )
    }

    if (recipient.reissue_count >= org.max_reissues_per_recipient) {
      return NextResponse.json(
        {
          error: `Maximum reissue limit (${org.max_reissues_per_recipient}) reached for this recipient. Increase the limit in Billing settings or revoke and re-add them.`,
        },
        { status: 403 }
      )
    }

    const code = await reissueCodeForRecipient({
      recipientId: recipient.id,
      organizationId: recipient.organization_id,
    })

    let emailSent = false
    let emailError: string | undefined
    if (recipient.email && body.send_email !== false) {
      const result = await sendInviteEmail({
        toEmail: recipient.email,
        recipientName: recipient.display_name,
        identifier: recipient.identifier,
        organizationName: org.name,
        organizationType: org.type,
        contactEmail: org.contact_email,
        code: code.code,
      })
      if (result.ok) {
        emailSent = true
        await supabaseAdmin
          .from('recipients')
          .update({ email_sent_at: new Date().toISOString() })
          .eq('id', recipient.id)
      } else {
        emailError = result.reason
      }
    }

    return NextResponse.json({ code, email_sent: emailSent, email_error: emailError })
  } catch (error) {
    console.error('Failed to reissue code:', error)
    return NextResponse.json({ error: 'Failed to reissue code' }, { status: 500 })
  }
}
