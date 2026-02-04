import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET single journey
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { data, error } = await supabaseAdmin
      .from('journeys')
      .select('*')
      .eq('id', params.id)
      .single()

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to fetch journey:', error)
    return NextResponse.json(
      { error: 'Failed to fetch journey' },
      { status: 500 }
    )
  }
}

// PATCH update journey
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json()
    
    const { data, error } = await supabaseAdmin
      .from('journeys')
      .update(body)
      .eq('id', params.id)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to update journey:', error)
    return NextResponse.json(
      { error: 'Failed to update journey' },
      { status: 500 }
    )
  }
}

// DELETE journey
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { error } = await supabaseAdmin
      .from('journeys')
      .delete()
      .eq('id', params.id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to delete journey:', error)
    return NextResponse.json(
      { error: 'Failed to delete journey' },
      { status: 500 }
    )
  }
}



