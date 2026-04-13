import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const runId = searchParams.get('run_id');
    const area = searchParams.get('area');
    const categoryId = searchParams.get('category');
    const status = searchParams.get('status');
    const limit = parseInt(searchParams.get('limit') || '100', 10);
    const offset = parseInt(searchParams.get('offset') || '0', 10);

    let targetRunId = runId;
    if (!targetRunId) {
      const { data: latestRun } = await supabaseAdmin
        .from('audit_runs')
        .select('id')
        .eq('status', 'completed')
        .order('completed_at', { ascending: false })
        .limit(1)
        .single();
      targetRunId = latestRun?.id;
    }

    if (!targetRunId) {
      return NextResponse.json({ findings: [], total: 0 });
    }

    let query = supabaseAdmin
      .from('audit_findings')
      .select('*', { count: 'exact' })
      .eq('run_id', targetRunId)
      .order('score', { ascending: true })
      .range(offset, offset + limit - 1);

    if (area) query = query.eq('content_area', area);
    if (categoryId) query = query.eq('category_id', categoryId);
    if (status) query = query.eq('status', status);

    const { data: findings, count, error } = await query;
    if (error) throw error;

    return NextResponse.json({
      findings: findings || [],
      total: count || 0,
      run_id: targetRunId,
    });
  } catch (error) {
    console.error('Failed to fetch findings:', error);
    return NextResponse.json(
      { error: 'Failed to fetch findings' },
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, status, resolution_note } = body;

    if (!id || !status) {
      return NextResponse.json(
        { error: 'id and status are required' },
        { status: 400 }
      );
    }

    const validStatuses = ['open', 'acknowledged', 'resolved', 'wont_fix'];
    if (!validStatuses.includes(status)) {
      return NextResponse.json(
        { error: `Invalid status. Must be one of: ${validStatuses.join(', ')}` },
        { status: 400 }
      );
    }

    const update: Record<string, unknown> = { status };
    if (status === 'resolved' || status === 'wont_fix') {
      update.resolved_at = new Date().toISOString();
      update.resolved_by = 'admin';
      if (resolution_note) update.resolution_note = resolution_note;
    }

    const { data, error } = await supabaseAdmin
      .from('audit_findings')
      .update(update)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json(data);
  } catch (error) {
    console.error('Failed to update finding:', error);
    return NextResponse.json(
      { error: 'Failed to update finding' },
      { status: 500 }
    );
  }
}
