import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { issueCodeForRecipient } from '@/lib/sponsorship-server'
import { sendInviteEmail } from '@/lib/email/send-invite'

export const dynamic = 'force-dynamic'

interface RecipientRow {
  id: string
  organization_id: string
  unit_id: string | null
  identifier: string
  display_name: string | null
  email: string | null
  pseudonym: string | null
  status: string
  invited_at: string | null
  email_sent_at: string | null
  redeemed_at: string | null
  reissue_count: number
  notes: string | null
  created_at: string
  updated_at: string
}

interface AccessCodeRow {
  recipient_id: string | null
  code: string
  is_active: boolean
  redeemed_at: string | null
  created_at: string
}

export async function GET(_req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { data: recipients, error } = await supabaseAdmin
      .from('recipients')
      .select('*')
      .eq('organization_id', params.id)
      .order('created_at', { ascending: false })

    if (error) throw error

    const ids = (recipients ?? []).map((r: RecipientRow) => r.id)
    const codeMap = new Map<string, string>()

    if (ids.length > 0) {
      const { data: codes } = await supabaseAdmin
        .from('access_codes')
        .select('recipient_id, code, is_active, redeemed_at, created_at')
        .in('recipient_id', ids)
        .eq('is_active', true)
        .order('created_at', { ascending: false })

      for (const c of (codes ?? []) as AccessCodeRow[]) {
        if (c.recipient_id && !codeMap.has(c.recipient_id)) {
          codeMap.set(c.recipient_id, c.code)
        }
      }
    }

    const enriched = (recipients ?? []).map((r: RecipientRow) => ({
      ...r,
      active_code: codeMap.get(r.id) ?? null,
    }))

    return NextResponse.json(enriched)
  } catch (error) {
    console.error('Failed to fetch recipients:', error)
    return NextResponse.json({ error: 'Failed to fetch recipients' }, { status: 500 })
  }
}

export async function POST(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const body = await req.json()
    const identifier = String(body.identifier ?? '').trim()
    const email = body.email ? String(body.email).trim() : null
    const display_name = body.display_name ? String(body.display_name).trim() : null

    if (!identifier) {
      return NextResponse.json({ error: 'Identifier is required' }, { status: 400 })
    }

    const { data: org, error: orgErr } = await supabaseAdmin
      .from('organizations')
      .select('id, name, type, contact_email')
      .eq('id', params.id)
      .single()

    if (orgErr || !org) {
      return NextResponse.json({ error: 'Organisation not found' }, { status: 404 })
    }

    const { data: recipient, error: insertErr } = await supabaseAdmin
      .from('recipients')
      .insert({
        organization_id: params.id,
        identifier,
        email,
        display_name,
        status: 'invited',
        invited_at: new Date().toISOString(),
      })
      .select('*')
      .single()

    if (insertErr) {
      if (insertErr.code === '23505') {
        return NextResponse.json(
          { error: `A recipient with identifier "${identifier}" already exists` },
          { status: 409 }
        )
      }
      throw insertErr
    }

    const code = await issueCodeForRecipient({
      recipientId: recipient.id,
      organizationId: params.id,
    })

    let emailResult: { ok: boolean; reason?: string; skipped?: boolean } = { ok: true }
    if (email && body.send_email !== false) {
      emailResult = await sendInviteEmail({
        toEmail: email,
        recipientName: display_name,
        identifier,
        organizationName: org.name,
        organizationType: org.type,
        contactEmail: org.contact_email,
        code: code.code,
      })
      if (emailResult.ok) {
        await supabaseAdmin
          .from('recipients')
          .update({ email_sent_at: new Date().toISOString() })
          .eq('id', recipient.id)
      }
    }

    return NextResponse.json(
      {
        recipient: { ...recipient, active_code: code.code },
        code,
        email_status: emailResult,
      },
      { status: 201 }
    )
  } catch (error) {
    console.error('Failed to create recipient:', error)
    return NextResponse.json({ error: 'Failed to create recipient' }, { status: 500 })
  }
}
