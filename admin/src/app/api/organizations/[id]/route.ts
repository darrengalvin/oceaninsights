import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export async function GET(_req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { data: org, error } = await supabaseAdmin
      .from('organizations')
      .select('*')
      .eq('id', params.id)
      .single()

    if (error) throw error

    const { data: codes, error: codesErr } = await supabaseAdmin
      .from('access_codes')
      .select('*')
      .eq('organization_id', params.id)
      .order('created_at', { ascending: false })

    if (codesErr) throw codesErr

    const stats = {
      total: codes?.length ?? 0,
      redeemed: codes?.filter((c) => c.redeemed_at).length ?? 0,
      active_unredeemed: codes?.filter((c) => !c.redeemed_at && c.is_active).length ?? 0,
    }

    return NextResponse.json({ ...org, codes, stats })
  } catch (error) {
    console.error('Failed to fetch organisation:', error)
    return NextResponse.json({ error: 'Failed to fetch organisation' }, { status: 500 })
  }
}

export async function PATCH(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const body = await req.json()

    const updates: Record<string, unknown> = {}
    const allowed = [
      'name',
      'type',
      'contact_name',
      'contact_email',
      'contact_phone',
      'notes',
      'contract_starts_on',
      'contract_ends_on',
      'seats_purchased',
      'is_active',
      'billing_mode',
      'billing_batch_size',
      'allow_reissue',
      'max_reissues_per_recipient',
      'privacy_promise_enabled',
    ]
    for (const key of allowed) {
      if (key in body) updates[key] = body[key]
    }

    const { data, error } = await supabaseAdmin
      .from('organizations')
      .update(updates)
      .eq('id', params.id)
      .select()
      .single()

    if (error) throw error
    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to update organisation:', error)
    return NextResponse.json({ error: 'Failed to update organisation' }, { status: 500 })
  }
}

export async function DELETE(_req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { error } = await supabaseAdmin.from('organizations').delete().eq('id', params.id)
    if (error) throw error
    return NextResponse.json({ ok: true })
  } catch (error) {
    console.error('Failed to delete organisation:', error)
    return NextResponse.json({ error: 'Failed to delete organisation' }, { status: 500 })
  }
}
