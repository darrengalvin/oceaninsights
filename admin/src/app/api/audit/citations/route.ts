import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const claimType = searchParams.get('type');
    const verificationStatus = searchParams.get('status');
    const area = searchParams.get('area');
    const limit = parseInt(searchParams.get('limit') || '100', 10);
    const offset = parseInt(searchParams.get('offset') || '0', 10);

    let query = supabaseAdmin
      .from('audit_citations')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (claimType) query = query.eq('claim_type', claimType);
    if (verificationStatus) query = query.eq('verification_status', verificationStatus);
    if (area) query = query.eq('content_area', area);

    const { data: citations, count, error } = await query;
    if (error) throw error;

    return NextResponse.json({
      citations: citations || [],
      total: count || 0,
    });
  } catch (error) {
    console.error('Failed to fetch citations:', error);
    return NextResponse.json(
      { error: 'Failed to fetch citations' },
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, verification_status, source_url, verified_by, notes } = body;

    if (!id) {
      return NextResponse.json(
        { error: 'id is required' },
        { status: 400 }
      );
    }

    const update: Record<string, unknown> = { updated_at: new Date().toISOString() };
    if (verification_status) update.verification_status = verification_status;
    if (source_url !== undefined) update.source_url = source_url;
    if (verified_by !== undefined) update.verified_by = verified_by;
    if (notes !== undefined) update.notes = notes;

    if (verification_status === 'verified') {
      update.verified_at = new Date().toISOString();
    }

    const { data, error } = await supabaseAdmin
      .from('audit_citations')
      .update(update)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json(data);
  } catch (error) {
    console.error('Failed to update citation:', error);
    return NextResponse.json(
      { error: 'Failed to update citation' },
      { status: 500 }
    );
  }
}
