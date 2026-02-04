import { NextRequest, NextResponse } from 'next/server'
import { getSupabaseAdmin } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET single scenario with options
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    
    // Fetch scenario with options
    const { data: scenario, error: scenarioError } = await supabaseAdmin
      .from('scenarios')
      .select(`
        *,
        content_pack:content_packs(id, name)
      `)
      .eq('id', params.id)
      .single()

    if (scenarioError) throw scenarioError

    // Fetch options separately
    const { data: options, error: optionsError } = await supabaseAdmin
      .from('scenario_options')
      .select('*')
      .eq('scenario_id', params.id)
      .order('created_at', { ascending: true })

    if (optionsError) throw optionsError

    return NextResponse.json({
      ...scenario,
      options: options || []
    })
  } catch (error) {
    console.error('Failed to fetch scenario:', error)
    return NextResponse.json(
      { error: 'Failed to fetch scenario' },
      { status: 500 }
    )
  }
}

// PATCH update scenario
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    const body = await request.json()
    
    const { options, ...scenarioData } = body

    // Update scenario
    const { error: scenarioError } = await supabaseAdmin
      .from('scenarios')
      .update(scenarioData)
      .eq('id', params.id)

    if (scenarioError) throw scenarioError

    // If options are provided, update them
    if (options && Array.isArray(options)) {
      // Delete existing options
      await supabaseAdmin
        .from('scenario_options')
        .delete()
        .eq('scenario_id', params.id)

      // Insert new options
      const optionsToInsert = options.map(opt => ({
        ...opt,
        scenario_id: params.id
      }))

      const { error: optionsError } = await supabaseAdmin
        .from('scenario_options')
        .insert(optionsToInsert)

      if (optionsError) throw optionsError
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to update scenario:', error)
    return NextResponse.json(
      { error: 'Failed to update scenario' },
      { status: 500 }
    )
  }
}

// DELETE scenario
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabaseAdmin = getSupabaseAdmin()
    
    // Delete options first (cascade should handle this, but being explicit)
    await supabaseAdmin
      .from('scenario_options')
      .delete()
      .eq('scenario_id', params.id)

    // Delete scenario
    const { error } = await supabaseAdmin
      .from('scenarios')
      .delete()
      .eq('id', params.id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Failed to delete scenario:', error)
    return NextResponse.json(
      { error: 'Failed to delete scenario' },
      { status: 500 }
    )
  }
}



