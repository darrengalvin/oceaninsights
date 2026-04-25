import { NextRequest, NextResponse } from 'next/server'
import { randomUUID } from 'crypto'
import { supabaseAdmin } from '@/lib/supabase'
import { generateAccessCode } from '@/lib/sponsorship'

export const dynamic = 'force-dynamic'

const MAX_PER_BATCH = 1000

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const organization_id = String(body.organization_id ?? '')
    const quantity = Number(body.quantity ?? 0)
    const batch_label = body.batch_label?.toString().trim() || null
    const expires_at = body.expires_at || null
    const prefix = (body.prefix?.toString().trim() || 'BTS').toUpperCase().slice(0, 8)

    if (!organization_id) {
      return NextResponse.json({ error: 'organization_id is required' }, { status: 400 })
    }
    if (!Number.isInteger(quantity) || quantity < 1 || quantity > MAX_PER_BATCH) {
      return NextResponse.json(
        { error: `Quantity must be between 1 and ${MAX_PER_BATCH}` },
        { status: 400 }
      )
    }

    const { data: org, error: orgErr } = await supabaseAdmin
      .from('organizations')
      .select('id, is_active')
      .eq('id', organization_id)
      .single()

    if (orgErr || !org) {
      return NextResponse.json({ error: 'Organisation not found' }, { status: 404 })
    }

    const batch_id = randomUUID()

    // Generate codes; retry on collision (vanishingly unlikely with 32^8 space).
    const codes = new Set<string>()
    let attempts = 0
    while (codes.size < quantity && attempts < quantity * 5) {
      codes.add(generateAccessCode(prefix))
      attempts++
    }
    if (codes.size < quantity) {
      return NextResponse.json({ error: 'Failed to generate unique codes' }, { status: 500 })
    }

    const rows = Array.from(codes).map((code) => ({
      code,
      organization_id,
      batch_id,
      batch_label,
      expires_at,
      is_active: true,
    }))

    // Insert in chunks of 200
    const inserted: { id: string; code: string }[] = []
    const CHUNK = 200
    for (let i = 0; i < rows.length; i += CHUNK) {
      const chunk = rows.slice(i, i + CHUNK)
      const { data, error } = await supabaseAdmin
        .from('access_codes')
        .insert(chunk)
        .select('id, code')
      if (error) throw error
      if (data) inserted.push(...data)
    }

    return NextResponse.json(
      { batch_id, batch_label, count: inserted.length, codes: inserted },
      { status: 201 }
    )
  } catch (error) {
    console.error('Failed to generate access codes:', error)
    return NextResponse.json({ error: 'Failed to generate access codes' }, { status: 500 })
  }
}
