import { NextRequest, NextResponse } from 'next/server'
import { getSupabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET single protocol
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    
    const { data, error } = await supabaseAdmin
      .from('protocols')
      .select('*')
      .eq('id', params.id)
      .single()

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Failed to fetch protocol:', error)
    return NextResponse.json(
      { error: 'Failed to fetch protocol' },
      { status: 500 }
    )
  }
}

// PATCH update protocol
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    const body = await request.json()
    
    const { error } = await supabaseAdmin
      .from('protocols')
      .update(body)
      .eq('id', params.id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to update protocol:', error)
    return NextResponse.json(
      { error: 'Failed to update protocol' },
      { status: 500 }
    )
  }
}

// DELETE protocol
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    
    const { error } = await supabaseAdmin
      .from('protocols')
      .delete()
      .eq('id', params.id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to delete protocol:', error)
    return NextResponse.json(
      { error: 'Failed to delete protocol' },
      { status: 500 }
    )
  }
}



