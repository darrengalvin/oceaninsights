import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET all journeys
export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('journeys')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to fetch journeys:', error)
    return NextResponse.json(
      { error: 'Failed to fetch journeys' },
      { status: 500 }
    )
  }
}

// POST create new journey
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    const { data, error } = await supabaseAdmin
      .from('journeys')
      .insert(body)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    console.error('Failed to create journey:', error)
    return NextResponse.json(
      { error: 'Failed to create journey' },
      { status: 500 }
    )
  }
}



