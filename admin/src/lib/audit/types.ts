export type AuditStatus = 'running' | 'completed' | 'failed';
export type FindingStatus = 'open' | 'acknowledged' | 'resolved' | 'wont_fix';
export type ClaimType = 'medical' | 'legal' | 'statistical' | 'research' | 'historical';
export type VerificationStatus = 'unverified' | 'verified' | 'disputed' | 'stale';
export type TrafficLight = 'green' | 'amber' | 'red' | 'critical';

export interface AuditRun {
  id: string;
  started_at: string;
  completed_at: string | null;
  status: AuditStatus;
  areas_total: number;
  areas_completed: number;
  system_score: number | null;
  total_items_scored: number;
  total_findings: number;
  findings_critical: number;
  findings_red: number;
  findings_amber: number;
  findings_green: number;
  triggered_by: string;
  error_message: string | null;
  created_at: string;
}

export interface AuditItemScore {
  id: string;
  run_id: string;
  content_area: string;
  item_id: string;
  item_label: string;
  source_table: string;
  overall_score: number;
  category_scores: Record<string, CategoryScore>;
  created_at: string;
}

export interface CategoryScore {
  score: number;
  applicable: boolean;
  reasoning: string;
  sub_scores: SubScore[];
}

export interface SubScore {
  sub_criterion: string;
  score: number;
  evidence: string;
  finding: string | null;
  suggested_action: string | null;
}

export interface AuditFinding {
  id: string;
  run_id: string;
  item_score_id: string | null;
  content_area: string;
  item_id: string | null;
  item_label: string | null;
  category_id: string;
  sub_criterion: string;
  score: number;
  description: string;
  evidence: string | null;
  suggested_action: string | null;
  status: FindingStatus;
  resolved_at: string | null;
  resolved_by: string | null;
  resolution_note: string | null;
  created_at: string;
}

export interface AuditCitation {
  id: string;
  claim_text: string;
  claim_type: ClaimType;
  content_area: string;
  source_table: string;
  source_field: string | null;
  source_row_id: string | null;
  verification_status: VerificationStatus;
  source_url: string | null;
  verified_by: string | null;
  verified_at: string | null;
  notes: string | null;
  first_detected_run_id: string | null;
  last_seen_run_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface ClaudeSubScore {
  sub_criterion: string;
  score: number;
  evidence: string;
  finding: string | null;
  suggested_action: string | null;
}

export interface ClaudeCitation {
  claim_text: string;
  claim_type: ClaimType;
  needs_verification: boolean;
  suggested_source: string | null;
}

export interface ClaudeCategoryScore {
  category_id: string;
  applicable: boolean;
  score: number;
  reasoning: string;
  sub_scores: ClaudeSubScore[];
  citations: ClaudeCitation[];
}

export interface ClaudeItemResult {
  item_id: string;
  item_label: string;
  source_table: string;
  overall_score: number;
  category_scores: ClaudeCategoryScore[];
}

export interface ClaudeAreaNote {
  category_id: string;
  observation: string;
  score: number;
}

export interface ClaudeAuditResponse {
  content_area: string;
  items: ClaudeItemResult[];
  area_level_notes: ClaudeAreaNote[];
}

export interface ContentAreaDefinition {
  id: string;
  label: string;
  tables: string[];
  extractQuery: string;
}

export interface ExtractedContentItem {
  id: string;
  label: string;
  source_table: string;
  content_area: string;
  data: Record<string, unknown>;
}

export interface ExtractedContentArea {
  id: string;
  label: string;
  items: ExtractedContentItem[];
}

export function scoreToTrafficLight(score: number): TrafficLight {
  if (score >= 90) return 'green';
  if (score >= 70) return 'amber';
  if (score >= 50) return 'red';
  return 'critical';
}

export function trafficLightColor(light: TrafficLight): string {
  switch (light) {
    case 'green': return '#22c55e';
    case 'amber': return '#f59e0b';
    case 'red': return '#ef4444';
    case 'critical': return '#dc2626';
  }
}

export function trafficLightLabel(light: TrafficLight): string {
  switch (light) {
    case 'green': return 'Meets Standard';
    case 'amber': return 'Review Recommended';
    case 'red': return 'Action Required';
    case 'critical': return 'Immediate Action Required';
  }
}
