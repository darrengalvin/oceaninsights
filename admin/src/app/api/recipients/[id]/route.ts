import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export async function PATCH(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const body = await req.json()
    const updates: Record<string, unknown> = {}
    if ('display_name' in body) updates.display_name = body.display_name || null
    if ('email' in body) updates.email = body.email || null
    if ('pseudonym' in body) updates.pseudonym = body.pseudonym || null
    if ('notes' in body) updates.notes = body.notes || null
    if ('status' in body) updates.status = body.status

    const { data, error } = await supabaseAdmin
      .from('recipients')
      .update(updates)
      .eq('id', params.id)
      .select()
      .single()

    if (error) throw error
    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to update recipient:', error)
    return NextResponse.json({ error: 'Failed to update recipient' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await supabaseAdmin
      .from('access_codes')
      .update({ is_active: false })
      .eq('recipient_id', params.id)

    const { error } = await supabaseAdmin
      .from('recipients')
      .update({ status: 'revoked' })
      .eq('id', params.id)

    if (error) throw error
    return NextResponse.json({ ok: true })
  } catch (error) {
    console.error('Failed to revoke recipient:', error)
    return NextResponse.json({ error: 'Failed to revoke recipient' }, { status: 500 })
  }
}
