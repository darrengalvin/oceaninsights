-- Content Audit System Schema
-- Stores audit runs, per-item scores, findings, and factual claim citations

-- Audit runs: one row per audit execution
CREATE TABLE IF NOT EXISTS audit_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed')),
  areas_total INT NOT NULL DEFAULT 0,
  areas_completed INT NOT NULL DEFAULT 0,
  system_score NUMERIC(5,2),
  total_items_scored INT DEFAULT 0,
  total_findings INT DEFAULT 0,
  findings_critical INT DEFAULT 0,
  findings_red INT DEFAULT 0,
  findings_amber INT DEFAULT 0,
  findings_green INT DEFAULT 0,
  triggered_by TEXT DEFAULT 'manual',
  error_message TEXT,
  current_area TEXT,
  current_area_label TEXT,
  current_phase TEXT DEFAULT 'starting',
  current_item_count INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Per-item scores: one row per content item per audit run
CREATE TABLE IF NOT EXISTS audit_item_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id UUID NOT NULL REFERENCES audit_runs(id) ON DELETE CASCADE,
  content_area TEXT NOT NULL,
  item_id TEXT NOT NULL,
  item_label TEXT NOT NULL,
  source_table TEXT NOT NULL,
  overall_score NUMERIC(5,2) NOT NULL,
  category_scores JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_item_scores_run ON audit_item_scores(run_id);
CREATE INDEX IF NOT EXISTS idx_audit_item_scores_area ON audit_item_scores(content_area);
CREATE INDEX IF NOT EXISTS idx_audit_item_scores_item ON audit_item_scores(item_id);

-- Findings: individual issues with lifecycle tracking
CREATE TABLE IF NOT EXISTS audit_findings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id UUID NOT NULL REFERENCES audit_runs(id) ON DELETE CASCADE,
  item_score_id UUID REFERENCES audit_item_scores(id) ON DELETE CASCADE,
  content_area TEXT NOT NULL,
  item_id TEXT,
  item_label TEXT,
  category_id TEXT NOT NULL,
  sub_criterion TEXT NOT NULL,
  score NUMERIC(5,2) NOT NULL,
  description TEXT NOT NULL,
  evidence TEXT,
  suggested_action TEXT,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'acknowledged', 'resolved', 'wont_fix')),
  resolved_at TIMESTAMPTZ,
  resolved_by TEXT,
  resolution_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_findings_run ON audit_findings(run_id);
CREATE INDEX IF NOT EXISTS idx_audit_findings_status ON audit_findings(status);
CREATE INDEX IF NOT EXISTS idx_audit_findings_category ON audit_findings(category_id);
CREATE INDEX IF NOT EXISTS idx_audit_findings_area ON audit_findings(content_area);

-- Citations: factual claims registry, persists across runs
CREATE TABLE IF NOT EXISTS audit_citations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_text TEXT NOT NULL,
  claim_type TEXT NOT NULL CHECK (claim_type IN ('medical', 'legal', 'statistical', 'research', 'historical')),
  content_area TEXT NOT NULL,
  source_table TEXT NOT NULL,
  source_field TEXT,
  source_row_id TEXT,
  verification_status TEXT NOT NULL DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'verified', 'disputed', 'stale')),
  source_url TEXT,
  verified_by TEXT,
  verified_at TIMESTAMPTZ,
  notes TEXT,
  first_detected_run_id UUID REFERENCES audit_runs(id) ON DELETE SET NULL,
  last_seen_run_id UUID REFERENCES audit_runs(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_citations_status ON audit_citations(verification_status);
CREATE INDEX IF NOT EXISTS idx_audit_citations_type ON audit_citations(claim_type);
CREATE INDEX IF NOT EXISTS idx_audit_citations_area ON audit_citations(content_area);

-- RLS policies: only authenticated users (admin) can access audit data
ALTER TABLE audit_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_item_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_findings ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_citations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read audit_runs" ON audit_runs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert audit_runs" ON audit_runs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can update audit_runs" ON audit_runs FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Authenticated users can read audit_item_scores" ON audit_item_scores FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert audit_item_scores" ON audit_item_scores FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can read audit_findings" ON audit_findings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert audit_findings" ON audit_findings FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can update audit_findings" ON audit_findings FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Authenticated users can read audit_citations" ON audit_citations FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert audit_citations" ON audit_citations FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can update audit_citations" ON audit_citations FOR UPDATE TO authenticated USING (true);

-- Service role has full access for the pipeline
CREATE POLICY "Service role full access audit_runs" ON audit_runs FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access audit_item_scores" ON audit_item_scores FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access audit_findings" ON audit_findings FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service role full access audit_citations" ON audit_citations FOR ALL TO service_role USING (true) WITH CHECK (true);
