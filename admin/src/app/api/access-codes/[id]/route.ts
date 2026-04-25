import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export async function PATCH(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const body = await req.json()
    const updates: Record<string, unknown> = {}
    if ('is_active' in body) updates.is_active = !!body.is_active
    if ('expires_at' in body) updates.expires_at = body.expires_at || null

    const { data, error } = await supabaseAdmin
      .from('access_codes')
      .update(updates)
      .eq('id', params.id)
      .select()
      .single()

    if (error) throw error
    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to update access code:', error)
    return NextResponse.json({ error: 'Failed to update access code' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { error } = await supabaseAdmin.from('access_codes').delete().eq('id', params.id)
    if (error) throw error
    return NextResponse.json({ ok: true })
  } catch (error) {
    console.error('Failed to delete access code:', error)
    return NextResponse.json({ error: 'Failed to delete access code' }, { status: 500 })
  }
}
