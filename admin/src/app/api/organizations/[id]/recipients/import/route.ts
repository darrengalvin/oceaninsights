import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { issueCodeForRecipient } from '@/lib/sponsorship-server'
import { sendInviteEmail } from '@/lib/email/send-invite'

export const dynamic = 'force-dynamic'
export const maxDuration = 60

interface ImportRow {
  identifier: string
  email?: string | null
  display_name?: string | null
}

interface ImportResultEntry {
  identifier: string
  status: 'created' | 'skipped' | 'error'
  reason?: string
  code?: string
  email_sent?: boolean
  email_error?: string
}

const MAX_ROWS = 1000

export async function POST(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const body = await req.json()
    const rows = Array.isArray(body.rows) ? (body.rows as ImportRow[]) : []
    const sendEmail = body.send_email !== false

    if (rows.length === 0) {
      return NextResponse.json({ error: 'No rows provided' }, { status: 400 })
    }
    if (rows.length > MAX_ROWS) {
      return NextResponse.json(
        { error: `Maximum ${MAX_ROWS} recipients per import` },
        { status: 400 }
      )
    }

    const { data: org, error: orgErr } = await supabaseAdmin
      .from('organizations')
      .select('id, name, type, contact_email')
      .eq('id', params.id)
      .single()

    if (orgErr || !org) {
      return NextResponse.json({ error: 'Organisation not found' }, { status: 404 })
    }

    const results: ImportResultEntry[] = []
    let createdCount = 0
    let emailSentCount = 0
    let emailErrorCount = 0

    for (const raw of rows) {
      const identifier = (raw.identifier ?? '').toString().trim()
      const email = raw.email ? raw.email.toString().trim() : null
      const display_name = raw.display_name ? raw.display_name.toString().trim() : null

      if (!identifier) {
        results.push({ identifier: '', status: 'error', reason: 'Missing identifier' })
        continue
      }

      const { data: existing } = await supabaseAdmin
        .from('recipients')
        .select('id')
        .eq('organization_id', params.id)
        .eq('identifier', identifier)
        .maybeSingle()

      if (existing) {
        results.push({ identifier, status: 'skipped', reason: 'Already exists' })
        continue
      }

      try {
        const { data: recipient, error: insErr } = await supabaseAdmin
          .from('recipients')
          .insert({
            organization_id: params.id,
            identifier,
            email,
            display_name,
            status: 'invited',
            invited_at: new Date().toISOString(),
          })
          .select('id')
          .single()
        if (insErr) throw insErr

        const code = await issueCodeForRecipient({
          recipientId: recipient.id,
          organizationId: params.id,
        })
        createdCount++

        let emailSent = false
        let emailError: string | undefined
        if (email && sendEmail) {
          const result = await sendInviteEmail({
            toEmail: email,
            recipientName: display_name,
            identifier,
            organizationName: org.name,
            organizationType: org.type,
            contactEmail: org.contact_email,
            code: code.code,
          })
          if (result.ok) {
            emailSent = true
            emailSentCount++
            await supabaseAdmin
              .from('recipients')
              .update({ email_sent_at: new Date().toISOString() })
              .eq('id', recipient.id)
          } else {
            emailErrorCount++
            emailError = result.reason
          }
        }

        results.push({
          identifier,
          status: 'created',
          code: code.code,
          email_sent: emailSent,
          email_error: emailError,
        })
      } catch (e) {
        results.push({
          identifier,
          status: 'error',
          reason: e instanceof Error ? e.message : String(e),
        })
      }
    }

    return NextResponse.json({
      summary: {
        total: rows.length,
        created: createdCount,
        skipped: results.filter((r) => r.status === 'skipped').length,
        errors: results.filter((r) => r.status === 'error').length,
        emails_sent: emailSentCount,
        emails_failed: emailErrorCount,
      },
      results,
    })
  } catch (error) {
    console.error('Failed to import recipients:', error)
    return NextResponse.json({ error: 'Failed to import recipients' }, { status: 500 })
  }
}
