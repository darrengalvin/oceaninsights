import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { getActiveCodeForRecipient } from '@/lib/sponsorship-server'
import { sendInviteEmail } from '@/lib/email/send-invite'

export const dynamic = 'force-dynamic'

export async function POST(_req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { data: recipient, error } = await supabaseAdmin
      .from('recipients')
      .select('id, organization_id, identifier, display_name, email')
      .eq('id', params.id)
      .single()

    if (error || !recipient) {
      return NextResponse.json({ error: 'Recipient not found' }, { status: 404 })
    }
    if (!recipient.email) {
      return NextResponse.json(
        { error: 'No email address on file for this recipient' },
        { status: 400 }
      )
    }

    const { data: org } = await supabaseAdmin
      .from('organizations')
      .select('name, type, contact_email')
      .eq('id', recipient.organization_id)
      .single()
    if (!org) {
      return NextResponse.json({ error: 'Organisation not found' }, { status: 404 })
    }

    const code = await getActiveCodeForRecipient(recipient.id)
    if (!code) {
      return NextResponse.json({ error: 'No active code to resend - try reissuing instead' }, { status: 400 })
    }

    const result = await sendInviteEmail({
      toEmail: recipient.email,
      recipientName: recipient.display_name,
      identifier: recipient.identifier,
      organizationName: org.name,
      organizationType: org.type,
      contactEmail: org.contact_email,
      code,
    })

    if (result.ok) {
      await supabaseAdmin
        .from('recipients')
        .update({ email_sent_at: new Date().toISOString() })
        .eq('id', recipient.id)
      return NextResponse.json({ ok: true })
    }
    return NextResponse.json(
      { error: result.reason || 'Failed to send email', skipped: result.skipped },
      { status: result.skipped ? 400 : 500 }
    )
  } catch (error) {
    console.error('Failed to resend invite:', error)
    return NextResponse.json({ error: 'Failed to resend invite' }, { status: 500 })
  }
}
