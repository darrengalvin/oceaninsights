import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { slugify, type OrganizationType } from '@/lib/sponsorship'

export const dynamic = 'force-dynamic'

const VALID_TYPES: OrganizationType[] = ['military', 'school', 'charity', 'corporate', 'other']

export async function GET() {
  try {
    const { data: orgs, error } = await supabaseAdmin
      .from('organizations')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    const ids = (orgs ?? []).map((o) => o.id)
    let codeStats: Record<string, { total: number; redeemed: number; active_unredeemed: number }> = {}

    if (ids.length > 0) {
      const { data: codes, error: codesErr } = await supabaseAdmin
        .from('access_codes')
        .select('organization_id, redeemed_at, is_active')
        .in('organization_id', ids)

      if (codesErr) throw codesErr

      for (const id of ids) codeStats[id] = { total: 0, redeemed: 0, active_unredeemed: 0 }
      for (const c of codes ?? []) {
        const s = codeStats[c.organization_id]
        if (!s) continue
        s.total += 1
        if (c.redeemed_at) s.redeemed += 1
        else if (c.is_active) s.active_unredeemed += 1
      }
    }

    const enriched = (orgs ?? []).map((o) => ({
      ...o,
      codes_total: codeStats[o.id]?.total ?? 0,
      codes_redeemed: codeStats[o.id]?.redeemed ?? 0,
      codes_active_unredeemed: codeStats[o.id]?.active_unredeemed ?? 0,
    }))

    return NextResponse.json(enriched)
  } catch (error) {
    console.error('Failed to fetch organizations:', error)
    return NextResponse.json({ error: 'Failed to fetch organizations' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const name = String(body.name ?? '').trim()
    const type = String(body.type ?? '') as OrganizationType

    if (!name) return NextResponse.json({ error: 'Name is required' }, { status: 400 })
    if (!VALID_TYPES.includes(type)) {
      return NextResponse.json({ error: 'Invalid organisation type' }, { status: 400 })
    }

    const baseSlug = slugify(body.slug || name)
    let slug = baseSlug || `org-${Date.now().toString(36)}`

    // Ensure unique slug
    for (let i = 1; i < 25; i++) {
      const { data: existing } = await supabaseAdmin
        .from('organizations')
        .select('id')
        .eq('slug', slug)
        .maybeSingle()
      if (!existing) break
      slug = `${baseSlug}-${i + 1}`
    }

    const insert = {
      name,
      slug,
      type,
      contact_name: body.contact_name?.trim() || null,
      contact_email: body.contact_email?.trim() || null,
      contact_phone: body.contact_phone?.trim() || null,
      notes: body.notes?.trim() || null,
      contract_starts_on: body.contract_starts_on || null,
      contract_ends_on: body.contract_ends_on || null,
      seats_purchased: Number.isFinite(body.seats_purchased) ? body.seats_purchased : 0,
      is_active: body.is_active !== false,
    }

    const { data, error } = await supabaseAdmin
      .from('organizations')
      .insert(insert)
      .select()
      .single()

    if (error) throw error
    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    console.error('Failed to create organisation:', error)
    return NextResponse.json({ error: 'Failed to create organisation' }, { status: 500 })
  }
}
