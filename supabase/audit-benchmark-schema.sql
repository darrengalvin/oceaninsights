-- Audit Fix Benchmark Schema
-- Stores multi-model "fix bake-off" runs: which models proposed which fix
-- for which finding, how peer models scored those fixes, and which fix was
-- ultimately applied to the source content.
--
-- Conceptually mirrors the audit pipeline:
--   1. benchmark_runs       — one row per "compare these models on these findings" job
--   2. benchmark_fixes      — one row per (finding × candidate model) proposed rewrite
--   3. benchmark_judgments  — one row per (fix × judge model) cross-grading
--   4. benchmark_applies    — audit trail of which fix was written back to which source row

CREATE TABLE IF NOT EXISTS benchmark_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  audit_run_id UUID REFERENCES audit_runs(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'created'
    CHECK (status IN ('created', 'proposing', 'judging', 'completed', 'failed')),
  finding_ids UUID[] NOT NULL DEFAULT '{}',
  candidate_models JSONB NOT NULL DEFAULT '[]',
  judge_models JSONB NOT NULL DEFAULT '[]',
  rubric_axes JSONB NOT NULL DEFAULT '["resolves","safety","tone","conciseness","faithfulness"]',
  total_cost_usd NUMERIC(10,4) DEFAULT 0,
  total_latency_ms INT DEFAULT 0,
  winner_model_id TEXT,
  notes TEXT,
  error_message TEXT,
  triggered_by TEXT DEFAULT 'admin',
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_benchmark_runs_status ON benchmark_runs(status);
CREATE INDEX IF NOT EXISTS idx_benchmark_runs_audit_run ON benchmark_runs(audit_run_id);

-- One row per (finding, candidate model) — what the model proposed as a fix.
CREATE TABLE IF NOT EXISTS benchmark_fixes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  benchmark_run_id UUID NOT NULL REFERENCES benchmark_runs(id) ON DELETE CASCADE,
  finding_id UUID NOT NULL REFERENCES audit_findings(id) ON DELETE CASCADE,
  model_id TEXT NOT NULL,
  model_label TEXT NOT NULL,
  thinking_mode TEXT,
  -- Anonymised slug shown to judges (e.g. "fix_a", "fix_b", randomised per run)
  anonymous_label TEXT NOT NULL,
  original_text TEXT,
  proposed_text TEXT NOT NULL,
  rationale TEXT,
  source_field TEXT,
  raw_response JSONB,
  status TEXT NOT NULL DEFAULT 'completed'
    CHECK (status IN ('pending', 'completed', 'failed')),
  error_message TEXT,
  latency_ms INT,
  input_tokens INT,
  output_tokens INT,
  reasoning_tokens INT,
  cost_usd NUMERIC(10,4) DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_benchmark_fixes_run ON benchmark_fixes(benchmark_run_id);
CREATE INDEX IF NOT EXISTS idx_benchmark_fixes_finding ON benchmark_fixes(finding_id);
CREATE INDEX IF NOT EXISTS idx_benchmark_fixes_model ON benchmark_fixes(model_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_benchmark_fixes_run_finding_model
  ON benchmark_fixes(benchmark_run_id, finding_id, model_id);

-- One row per (fix, judge model). Each judge scores every candidate's fix on
-- the multi-axis rubric. Self-judgments are stored but excluded from the
-- aggregate winner score (tracked via is_self_vote).
CREATE TABLE IF NOT EXISTS benchmark_judgments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  benchmark_run_id UUID NOT NULL REFERENCES benchmark_runs(id) ON DELETE CASCADE,
  fix_id UUID NOT NULL REFERENCES benchmark_fixes(id) ON DELETE CASCADE,
  finding_id UUID NOT NULL REFERENCES audit_findings(id) ON DELETE CASCADE,
  judge_model_id TEXT NOT NULL,
  judge_model_label TEXT NOT NULL,
  is_self_vote BOOLEAN NOT NULL DEFAULT false,
  -- Per-axis scores, 0-100. Kept as discrete columns so we can sort/aggregate
  -- in SQL without unpacking JSONB on every read.
  score_resolves NUMERIC(5,2),
  score_safety NUMERIC(5,2),
  score_tone NUMERIC(5,2),
  score_conciseness NUMERIC(5,2),
  score_faithfulness NUMERIC(5,2),
  overall_score NUMERIC(5,2),
  ranking INT,
  justification TEXT,
  raw_response JSONB,
  status TEXT NOT NULL DEFAULT 'completed'
    CHECK (status IN ('pending', 'completed', 'failed')),
  error_message TEXT,
  latency_ms INT,
  input_tokens INT,
  output_tokens INT,
  cost_usd NUMERIC(10,4) DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_benchmark_judgments_run ON benchmark_judgments(benchmark_run_id);
CREATE INDEX IF NOT EXISTS idx_benchmark_judgments_fix ON benchmark_judgments(fix_id);
CREATE INDEX IF NOT EXISTS idx_benchmark_judgments_judge ON benchmark_judgments(judge_model_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_benchmark_judgments_fix_judge
  ON benchmark_judgments(fix_id, judge_model_id);

-- Audit trail: when an admin clicks "Apply this fix", record what was changed.
-- We store both the old and new value so we can revert if needed.
CREATE TABLE IF NOT EXISTS benchmark_applies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  benchmark_run_id UUID NOT NULL REFERENCES benchmark_runs(id) ON DELETE CASCADE,
  fix_id UUID NOT NULL REFERENCES benchmark_fixes(id) ON DELETE CASCADE,
  finding_id UUID NOT NULL REFERENCES audit_findings(id) ON DELETE CASCADE,
  source_table TEXT NOT NULL,
  source_row_id TEXT NOT NULL,
  source_field TEXT NOT NULL,
  old_value TEXT,
  new_value TEXT NOT NULL,
  applied_by TEXT DEFAULT 'admin',
  reverted_at TIMESTAMPTZ,
  reverted_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_benchmark_applies_run ON benchmark_applies(benchmark_run_id);
CREATE INDEX IF NOT EXISTS idx_benchmark_applies_finding ON benchmark_applies(finding_id);
CREATE INDEX IF NOT EXISTS idx_benchmark_applies_source ON benchmark_applies(source_table, source_row_id);

-- RLS — same pattern as the rest of the audit system.
ALTER TABLE benchmark_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE benchmark_fixes ENABLE ROW LEVEL SECURITY;
ALTER TABLE benchmark_judgments ENABLE ROW LEVEL SECURITY;
ALTER TABLE benchmark_applies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read benchmark_runs" ON benchmark_runs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert benchmark_runs" ON benchmark_runs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update benchmark_runs" ON benchmark_runs FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Authenticated read benchmark_fixes" ON benchmark_fixes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert benchmark_fixes" ON benchmark_fixes FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update benchmark_fixes" ON benchmark_fixes FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Authenticated read benchmark_judgments" ON benchmark_judgments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert benchmark_judgments" ON benchmark_judgments FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update benchmark_judgments" ON benchmark_judgments FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Authenticated read benchmark_applies" ON benchmark_applies FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert benchmark_applies" ON benchmark_applies FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update benchmark_applies" ON benchmark_applies FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Service role benchmark_runs" ON benchmark_runs FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service role benchmark_fixes" ON benchmark_fixes FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service role benchmark_judgments" ON benchmark_judgments FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service role benchmark_applies" ON benchmark_applies FOR ALL TO service_role USING (true) WITH CHECK (true);
