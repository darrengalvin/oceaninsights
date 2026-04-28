// POST /api/audit/benchmark/apply
//
// Writes a chosen fix back to the source content row, marks the underlying
// audit_finding as resolved, and logs the change in benchmark_applies for
// audit-trail purposes.
//
// Body: { fix_id: string, source_field?: string, dry_run?: boolean }
// Returns: { applied: boolean, change: { table, row_id, field, before, after } }
//
// IMPORTANT: We require the caller to confirm the source_field. The fix
// proposal *suggests* a field name, but it's the model's guess — we don't
// blindly trust it. The UI presents the suggestion and the admin confirms
// or overrides before this endpoint runs.

import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export const dynamic = 'force-dynamic';

interface FixRow {
  id: string;
  benchmark_run_id: string;
  finding_id: string;
  model_id: string;
  model_label: string;
  proposed_text: string;
  source_field: string | null;
  status: string;
}

interface FindingRow {
  id: string;
  item_id: string | null;
  status: string;
}

interface ItemScoreRow {
  source_table: string | null;
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { fix_id, source_field, dry_run } = body as {
      fix_id?: string;
      source_field?: string;
      dry_run?: boolean;
    };

    if (!fix_id) {
      return NextResponse.json({ error: 'fix_id required' }, { status: 400 });
    }

    const { data: fix, error: fixErr } = await supabaseAdmin
      .from('benchmark_fixes')
      .select('*')
      .eq('id', fix_id)
      .single();
    if (fixErr || !fix) {
      return NextResponse.json({ error: 'Fix not found' }, { status: 404 });
    }
    const fixRow = fix as FixRow;
    if (fixRow.status !== 'completed' || !fixRow.proposed_text) {
      return NextResponse.json({ error: 'Fix is not in a completed state' }, { status: 400 });
    }

    const { data: finding, error: findingErr } = await supabaseAdmin
      .from('audit_findings')
      .select('id, item_id, status, item_score_id')
      .eq('id', fixRow.finding_id)
      .single();
    if (findingErr || !finding) {
      return NextResponse.json({ error: 'Underlying finding not found' }, { status: 404 });
    }
    const findingRow = finding as FindingRow & { item_score_id: string | null };

    if (!findingRow.item_id) {
      return NextResponse.json({ error: 'Finding has no item_id — cannot locate source row' }, { status: 400 });
    }

    // Look up which DB table the original content lives in via the audit
    // pipeline's item_score row (it stored source_table when the finding
    // was first written).
    let sourceTable: string | null = null;
    if (findingRow.item_score_id) {
      const { data: itemScore } = await supabaseAdmin
        .from('audit_item_scores')
        .select('source_table')
        .eq('id', findingRow.item_score_id)
        .single();
      sourceTable = (itemScore as ItemScoreRow | null)?.source_table || null;
    }
    if (!sourceTable) {
      return NextResponse.json({ error: 'Could not determine source_table for this finding' }, { status: 400 });
    }

    const fieldToUpdate = source_field || fixRow.source_field;
    if (!fieldToUpdate) {
      return NextResponse.json(
        { error: 'source_field not specified and fix did not suggest one' },
        { status: 400 }
      );
    }

    // Read current value (the "before" half of the diff).
    // Supabase types `select(column)` against a known schema; here the
    // table + field are both dynamic so we route through `unknown` to read
    // the column generically without faking a typed schema.
    const { data: currentRow, error: readErr } = await supabaseAdmin
      .from(sourceTable)
      .select(fieldToUpdate)
      .eq('id', findingRow.item_id)
      .single();
    if (readErr) {
      return NextResponse.json(
        { error: `Failed to read ${sourceTable}.${fieldToUpdate}: ${readErr.message}` },
        { status: 400 }
      );
    }
    const beforeValue = (currentRow as unknown as Record<string, unknown> | null)?.[fieldToUpdate];

    if (dry_run) {
      return NextResponse.json({
        applied: false,
        dry_run: true,
        change: {
          table: sourceTable,
          row_id: findingRow.item_id,
          field: fieldToUpdate,
          before: beforeValue,
          after: fixRow.proposed_text,
        },
      });
    }

    // Apply.
    const { error: updateErr } = await supabaseAdmin
      .from(sourceTable)
      .update({ [fieldToUpdate]: fixRow.proposed_text })
      .eq('id', findingRow.item_id);
    if (updateErr) {
      return NextResponse.json(
        { error: `Failed to update ${sourceTable}.${fieldToUpdate}: ${updateErr.message}` },
        { status: 500 }
      );
    }

    // Log the apply for audit trail.
    await supabaseAdmin.from('benchmark_applies').insert({
      benchmark_run_id: fixRow.benchmark_run_id,
      fix_id: fixRow.id,
      finding_id: findingRow.id,
      source_table: sourceTable,
      source_row_id: findingRow.item_id,
      source_field: fieldToUpdate,
      old_value: beforeValue ? String(beforeValue) : null,
      new_value: fixRow.proposed_text,
      applied_by: 'admin',
    });

    // Resolve the finding so it disappears from the open queue.
    await supabaseAdmin
      .from('audit_findings')
      .update({
        status: 'resolved',
        resolved_at: new Date().toISOString(),
        resolved_by: 'admin',
        resolution_note: `Applied fix from ${fixRow.model_label} (benchmark_fix ${fixRow.id})`,
      })
      .eq('id', findingRow.id);

    return NextResponse.json({
      applied: true,
      change: {
        table: sourceTable,
        row_id: findingRow.item_id,
        field: fieldToUpdate,
        before: beforeValue,
        after: fixRow.proposed_text,
      },
    });
  } catch (error) {
    console.error('Failed to apply fix:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
