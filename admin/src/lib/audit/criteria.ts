export interface SubCriterion {
  id: string;
  label: string;
  description: string;
  scoring_guide: string;
}

export interface AuditCategory {
  id: string;
  label: string;
  description: string;
  weight: number;
  per_item: boolean;
  /**
   * Who scores this category. 'ai' categories are sent to the reviewing model;
   * 'rules' categories are scored by the deterministic evidence checks
   * (lib/audit/evidence) and never by the model.
   */
  scored_by?: 'ai' | 'rules';
  sub_criteria: SubCriterion[];
}

export const AUDIT_CATEGORIES: AuditCategory[] = [
  {
    id: 'factual_accuracy',
    label: 'Factual Accuracy',
    description: 'Does the content make claims, and are they verifiable?',
    weight: 1.2,
    per_item: true,
    sub_criteria: [
      {
        id: 'statistical_claims',
        label: 'Statistical Claims',
        description: 'Numbers, percentages, prevalence rates',
        scoring_guide: '100 = specific, verifiable, consistent with known data. 50 = vague or unsourced. 0 = demonstrably incorrect.',
      },
      {
        id: 'medical_health_claims',
        label: 'Medical/Health Claims',
        description: 'Health advice, treatment claims, symptom descriptions',
        scoring_guide: '100 = accurate, appropriately caveated, current. 50 = overstated or missing caveats. 0 = contradicts medical consensus.',
      },
      {
        id: 'legal_claims',
        label: 'Legal Claims',
        description: 'Legislation, rights, legal processes referenced',
        scoring_guide: '100 = correct, jurisdiction specified, current. 50 = outdated or jurisdiction ambiguous. 0 = incorrect.',
      },
      {
        id: 'research_claims',
        label: 'Research Claims',
        description: '"Research shows", "Studies suggest" attributability',
        scoring_guide: '100 = attributable to real, well-known research. 50 = vague or unattributable. 0 = misrepresented.',
      },
      {
        id: 'historical_claims',
        label: 'Historical Claims',
        description: 'Dates, events, case references',
        scoring_guide: '100 = verifiably accurate. 50 = minor inaccuracy. 0 = significantly wrong.',
      },
      {
        id: 'date_sensitivity',
        label: 'Date Sensitivity',
        description: 'Claims stamped with "as of [year]" or referencing current policy',
        scoring_guide: '100 = recent and current. 50 = approaching staleness. 0 = date has passed, claim likely stale.',
      },
    ],
  },
  {
    id: 'source_traceability',
    label: 'Trusted Source Traceability',
    description: 'Client rule: all health and wellbeing information must reflect the NHS or trusted sources (NHS, Royal College of Psychiatrists, Mind, Mental Health Foundation; GOV.UK for services and entitlements). Can each claim be traced to one, and does it match?',
    weight: 1.5,
    per_item: true,
    sub_criteria: [
      {
        id: 'trusted_source_match',
        label: 'Trusted Source Match',
        description: 'Does each health or wellbeing claim match what the relevant NHS, RCPsych, Mind or Mental Health Foundation page says? Name the page.',
        scoring_guide: '100 = matches a named trusted page. 75 = consistent with trusted guidance but goes beyond it. 50 = not covered by any trusted source. 0 = contradicts a trusted source.',
      },
      {
        id: 'unsourced_claims',
        label: 'Unsourced Claims',
        description: '"Research shows", statistics and precise figures presented without a source the reader could check.',
        scoring_guide: '100 = no unsourced claims, or figures taken from a named trusted page. 50 = vague appeal to research or an unsourced figure. 0 = specific figure that is wrong or untraceable on a safety-relevant topic.',
      },
      {
        id: 'popular_psychology',
        label: 'Popular Psychology Presented as Fact',
        description: 'Ideas from self-help books, social media or popular psychology (love languages, power poses, 21-day habits, brain-timing rules) presented as established fact.',
        scoring_guide: '100 = none, or clearly framed as an optional idea with no health claim. 50 = presented as fact without health claims. 0 = presented as fact with a health or physiological claim.',
      },
      {
        id: 'disputed_research',
        label: 'Disputed Research Presented as Settled',
        description: 'Findings that later research has disputed or failed to replicate (Stanford Prison Experiment, marshmallow test, power-pose hormones) presented as settled.',
        scoring_guide: '100 = none, or the dispute is stated. 50 = presented without caveat in an educational context. 0 = used as the basis for advice.',
      },
      {
        id: 'source_currency',
        label: 'Source Currency',
        description: 'Are facts that change (laws in other countries, service names, policies, figures) still current?',
        scoring_guide: '100 = current. 50 = possibly out of date, needs re-checking. 0 = known to be out of date (repealed law, closed service).',
      },
    ],
  },
  {
    id: 'evidence_checks',
    label: 'Evidence Checks',
    description: 'Deterministic checks, no AI: every phone number against the verified helpline register, US or non-UK content, client wording rules, links against the trusted-source list, and claims already reviewed against trusted sources.',
    weight: 1.5,
    per_item: true,
    scored_by: 'rules',
    sub_criteria: [
      { id: 'helpline_register', label: 'Helpline Register', description: 'Each phone number matches a verified entry, with correct hours and description.', scoring_guide: 'Scored by rule: critical 20, red 45, amber 70, info 85; 100 when nothing is flagged.' },
      { id: 'uk_applicability', label: 'UK Applicability', description: 'No US or other non-UK systems, numbers or services presented to UK users.', scoring_guide: 'Scored by rule.' },
      { id: 'client_rules', label: 'Client Wording Rules', description: 'Client instructions, for example not naming the Royal Navy.', scoring_guide: 'Scored by rule.' },
      { id: 'trusted_links', label: 'Trusted Links', description: 'Links point to NHS, RCPsych, Mind, Mental Health Foundation, GOV.UK or listed UK charities.', scoring_guide: 'Scored by rule.' },
      { id: 'flagged_claims', label: 'Flagged Claims', description: 'Unsourced "research shows" or statistics, diagnostic-sounding results, medication detail, absolute safety or confidentiality promises.', scoring_guide: 'Scored by rule.' },
      { id: 'reviewed_claims', label: 'Reviewed Claims Watchlist', description: 'Claims already checked against trusted sources and found wrong or unsupported have not reappeared.', scoring_guide: 'Scored by rule.' },
    ],
  },
  {
    id: 'bias_impartiality',
    label: 'Bias and Impartiality',
    description: 'Is the content fair and balanced across the audiences it serves?',
    weight: 1.0,
    per_item: true,
    sub_criteria: [
      {
        id: 'service_branch_balance',
        label: 'Service Branch Balance',
        description: 'Does content assume a single branch (RN/Army/RAF)?',
        scoring_guide: '100 = branch-agnostic or explicitly labelled. 50 = leans toward one branch. 0 = assumes one branch exclusively.',
      },
      {
        id: 'gender_neutrality',
        label: 'Gender Neutrality',
        description: 'Does content assume a gender default?',
        scoring_guide: '100 = gender-neutral or inclusive. 50 = subtle gender assumptions. 0 = assumes a gender default.',
      },
      {
        id: 'rank_seniority',
        label: 'Rank/Seniority Assumptions',
        description: 'Does advice assume a specific rank relationship?',
        scoring_guide: '100 = offers alternatives or rank-agnostic. 50 = slightly assumes. 0 = assumes specific rank.',
      },
      {
        id: 'family_structure',
        label: 'Family Structure',
        description: 'Does content assume a particular family structure?',
        scoring_guide: '100 = acknowledges diversity. 50 = slightly narrow. 0 = assumes traditional family only.',
      },
      {
        id: 'religious_secular',
        label: 'Religious/Secular Balance',
        description: 'Are spiritual support routes balanced?',
        scoring_guide: '100 = includes secular alternatives. 50 = faith-leaning but not exclusive. 0 = only faith-based support.',
      },
      {
        id: 'cultural_assumptions',
        label: 'Cultural Assumptions',
        description: 'Does content assume a cultural norm?',
        scoring_guide: '100 = culturally aware or neutral. 50 = slightly narrow. 0 = assumes single cultural norm.',
      },
    ],
  },
  {
    id: 'regional_appropriateness',
    label: 'UK Appropriateness',
    description: 'Is content correct for UK users (the app\'s audience), with anything from another country clearly labelled or removed?',
    weight: 1.2,
    per_item: true,
    sub_criteria: [
      {
        id: 'jurisdiction_labelling',
        label: 'Jurisdiction Labelling',
        description: 'Is advice that differs across the four UK nations, or that applies outside the UK, clearly marked?',
        scoring_guide: '100 = UK-correct, with nation differences (England, Scotland, Wales, Northern Ireland) noted where they matter. 50 = implied. 0 = another country\'s rules presented as applying to UK users.',
      },
      {
        id: 'emergency_numbers',
        label: 'Emergency Numbers',
        description: 'Are emergency and crisis numbers the UK ones (999, NHS 111, Samaritans 116 123)?',
        scoring_guide: '100 = UK numbers, correct. 50 = UK numbers alongside unlabelled foreign ones. 0 = a foreign number (911, 988) or a wrong number shown to UK users.',
      },
      {
        id: 'helpline_coverage',
        label: 'Helpline Accuracy',
        description: 'Are helplines current UK services, with correct hours, and is each one described for what it is (crisis line or not)?',
        scoring_guide: '100 = current UK service, correct hours, described accurately. 50 = hours or description inaccurate. 0 = closed, renamed, foreign, or a non-crisis service presented as crisis support.',
      },
      {
        id: 'legal_advice_scope',
        label: 'Legal Advice Scope',
        description: 'Does legal information reflect UK law (and Service law where relevant)?',
        scoring_guide: '100 = correct UK law, current. 50 = UK but out of date or vague. 0 = another country\'s law.',
      },
      {
        id: 'entitlements_benefits',
        label: 'Entitlements/Benefits',
        description: 'Are financial, healthcare, education and employment entitlements the UK ones (NHS, Armed Forces Pension Scheme, ELCAS, Op COURAGE)?',
        scoring_guide: '100 = UK entitlements, correct. 50 = generic. 0 = a US system (VA, GI Bill, TSP, 401k) or another country\'s entitlements.',
      },
      {
        id: 'regional_gaps',
        label: 'Regional Gaps',
        description: 'Is there content UK users need that is missing (for example a nation-specific service)?',
        scoring_guide: '100 = adequate UK coverage. 50 = minor gaps. 0 = significant gap for a UK audience.',
      },
    ],
  },
  {
    id: 'safety_harm_prevention',
    label: 'Safety and Harm Prevention',
    description: 'Could following this content cause harm, delay help, or contradict safety guidance?',
    weight: 1.5,
    per_item: true,
    sub_criteria: [
      {
        id: 'help_seeking',
        label: 'Help-Seeking',
        description: 'Does growth-focused framing inadvertently discourage professional help?',
        scoring_guide: '100 = normalises professional help alongside self-help. 50 = self-help emphasis but not harmful. 0 = self-help presented as sufficient for serious issues.',
      },
      {
        id: 'proportionality',
        label: 'Proportionality',
        description: 'Is the response proportionate to the severity of the topic?',
        scoring_guide: '100 = proportionate. 50 = slightly light for topic. 0 = serious topic met only with self-help.',
      },
      {
        id: 'medical_caveats',
        label: 'Medical Caveats',
        description: 'Does health advice include appropriate caveats?',
        scoring_guide: '100 = caveat present. 50 = partial caveat. 0 = health advice with no caveat.',
      },
      {
        id: 'cross_content_contradiction',
        label: 'Cross-Content Contradiction',
        description: 'Does this content contradict safety advice elsewhere?',
        scoring_guide: '100 = consistent. 50 = minor tension. 0 = directly contradicts another section.',
      },
      {
        id: 'crisis_escalation',
        label: 'Crisis Escalation',
        description: 'For sensitive/urgent content, is there a clear path to professional help?',
        scoring_guide: '100 = links to crisis support in same flow. 50 = general support mentioned. 0 = no professional support signposted.',
      },
      {
        id: 'do_no_harm',
        label: 'Do No Harm',
        description: 'Could a vulnerable person be harmed by this content?',
        scoring_guide: '100 = safe even for someone in crisis. 50 = minor risk. 0 = could worsen crisis or trigger harm.',
      },
    ],
  },
  {
    id: 'clinical_boundaries',
    label: 'Clinical Boundaries',
    description: 'Does content stay within its scope as a wellness tool, not a clinical service?',
    weight: 1.5,
    per_item: true,
    sub_criteria: [
      {
        id: 'diagnostic_language',
        label: 'Diagnostic Language',
        description: 'Does content use diagnostic terminology?',
        scoring_guide: '100 = educational with disclaimer. 50 = clinical language without disclaimer. 0 = sounds like diagnosis.',
      },
      {
        id: 'medical_instructions',
        label: 'Medical Instructions',
        description: 'Does content tell users to take specific medical actions?',
        scoring_guide: '100 = informational only. 50 = suggestive but not directive. 0 = direct medical instruction.',
      },
      {
        id: 'disclaimer_presence',
        label: 'Disclaimer Presence',
        description: 'Is there an appropriate disclaimer near clinical content?',
        scoring_guide: '100 = disclaimer present in same block. 50 = disclaimer elsewhere in section. 0 = no disclaimer.',
      },
      {
        id: 'scope_positioning',
        label: 'Scope Positioning',
        description: 'Does content stay within wellness/educational framing?',
        scoring_guide: '100 = clear non-clinical, educational positioning. 50 = slightly clinical. 0 = crosses into clinical advice.',
      },
      {
        id: 'treatment_claims',
        label: 'Treatment Claims',
        description: 'Does content make claims about treatment efficacy?',
        scoring_guide: '100 = caveated ("may help", "some people find"). 50 = slightly definitive. 0 = definitive treatment claims.',
      },
    ],
  },
  {
    id: 'safeguarding',
    label: 'Safeguarding',
    description: 'Are vulnerable users protected and can they reach help?',
    weight: 1.5,
    per_item: true,
    sub_criteria: [
      {
        id: 'crisis_pathway',
        label: 'Crisis Pathway',
        description: 'Can users reach emergency support from this content?',
        scoring_guide: '100 = clear route to crisis support. 50 = indirect route. 0 = no visible crisis pathway.',
      },
      {
        id: 'emergency_contacts',
        label: 'Emergency Contacts',
        description: 'Are emergency contacts correct and current?',
        scoring_guide: '100 = valid, current, format-correct. 50 = present but may be outdated. 0 = invalid or missing.',
      },
      {
        id: 'age_appropriateness',
        label: 'Age Appropriateness',
        description: 'Is content suitable for 13+ audience?',
        scoring_guide: '100 = age-appropriate. 50 = borderline. 0 = too explicit or mature without gating.',
      },
      {
        id: 'vulnerable_user_safety',
        label: 'Vulnerable User Safety',
        description: 'Would this content be safe for someone in active crisis?',
        scoring_guide: '100 = safe, supportive, non-triggering. 50 = neutral. 0 = could worsen distress.',
      },
      {
        id: 'reporting_pathways',
        label: 'Reporting Pathways',
        description: 'Does content about abuse/harm reference appropriate reporting pathways?',
        scoring_guide: '100 = includes reporting guidance. 50 = general support but no reporting. 0 = abuse topic with no reporting pathway.',
      },
    ],
  },
  {
    id: 'opsec_compliance',
    label: 'OPSEC Compliance',
    description: 'Does any content compromise operational security?',
    weight: 1.5,
    per_item: true,
    sub_criteria: [
      {
        id: 'operational_details',
        label: 'Operational Details',
        description: 'Does content reference specific operations, deployments, or missions?',
        scoring_guide: '100 = generic military context only. 50 = slightly specific. 0 = specific operational details.',
      },
      {
        id: 'location_references',
        label: 'Location References',
        description: 'Does content name specific bases, ships, or locations?',
        scoring_guide: '100 = no identifiable locations. 50 = generic area references. 0 = names specific base/ship/location.',
      },
      {
        id: 'personnel_identification',
        label: 'Personnel Identification',
        description: 'Could content help identify specific individuals or units?',
        scoring_guide: '100 = no identifying information. 50 = vaguely identifiable. 0 = could identify personnel or units.',
      },
      {
        id: 'pattern_disclosure',
        label: 'Pattern Disclosure',
        description: 'Does content reveal operational patterns or schedules?',
        scoring_guide: '100 = no patterns revealed. 50 = vague temporal references. 0 = deployment cycles or schedules disclosed.',
      },
    ],
  },
  {
    id: 'currency',
    label: 'Currency',
    description: 'Is the information up to date?',
    weight: 1.2,
    per_item: true,
    sub_criteria: [
      {
        id: 'phone_numbers',
        label: 'Phone Numbers',
        description: 'Are phone numbers in valid, current format?',
        scoring_guide: '100 = valid, recognisable format. 50 = unusual format. 0 = invalid or known-outdated.',
      },
      {
        id: 'organisation_names',
        label: 'Organisation Names',
        description: 'Are organisation names current?',
        scoring_guide: '100 = current official name. 50 = recently changed. 0 = outdated name.',
      },
      {
        id: 'urls',
        label: 'URLs',
        description: 'Are website references current?',
        scoring_guide: '100 = current domain. 50 = may have changed. 0 = known-dead or redirected.',
      },
      {
        id: 'policy_references',
        label: 'Policy References',
        description: 'Are policy/legal references current?',
        scoring_guide: '100 = current legislation/policy. 50 = may be superseded. 0 = references repealed legislation.',
      },
      {
        id: 'date_stamped_claims',
        label: 'Date-Stamped Claims',
        description: 'Are "as of [year]" claims still within validity?',
        scoring_guide: '100 = within reasonable window. 50 = approaching expiry. 0 = date has passed.',
      },
      {
        id: 'cross_source_consistency',
        label: 'Cross-Source Consistency',
        description: 'Does this org/number appear the same everywhere in the app?',
        scoring_guide: '100 = consistent. 50 = minor variation. 0 = different values in different locations.',
      },
    ],
  },
  {
    id: 'internal_consistency',
    label: 'Internal Consistency',
    description: 'Does content align with other content in the app?',
    weight: 1.0,
    per_item: true,
    sub_criteria: [
      {
        id: 'factual_consistency',
        label: 'Factual Consistency',
        description: 'Do facts stated here match facts stated elsewhere?',
        scoring_guide: '100 = consistent. 50 = minor discrepancy. 0 = contradicts another section.',
      },
      {
        id: 'tone_consistency',
        label: 'Tone Consistency',
        description: 'Does the tone match the app\'s overall voice?',
        scoring_guide: '100 = consistent. 50 = slightly different. 0 = jarring shift in tone.',
      },
      {
        id: 'terminology_consistency',
        label: 'Terminology Consistency',
        description: 'Are terms used consistently?',
        scoring_guide: '100 = same terms for same concepts. 50 = minor variation. 0 = different terms for same concept.',
      },
      {
        id: 'advice_consistency',
        label: 'Advice Consistency',
        description: 'Does advice align across content areas?',
        scoring_guide: '100 = aligned. 50 = minor tension. 0 = conflicting advice.',
      },
    ],
  },
  {
    id: 'content_quality',
    label: 'Content Quality',
    description: 'Does content meet structural quality standards?',
    weight: 1.0,
    per_item: true,
    sub_criteria: [
      {
        id: 'language',
        label: 'Language',
        description: 'Is it UK English?',
        scoring_guide: '100 = UK English throughout. 50 = mostly UK with occasional US. 0 = US English or mixed.',
      },
      {
        id: 'tone',
        label: 'Tone',
        description: 'Is it growth-focused, normalising, hopeful?',
        scoring_guide: '100 = growth-focused, empowering. 50 = neutral. 0 = problem-focused, deficit-framed, clinical.',
      },
      {
        id: 'clarity',
        label: 'Clarity',
        description: 'Is it clear and readable?',
        scoring_guide: '100 = clear, appropriate reading level. 50 = slightly complex. 0 = jargon-heavy or confusing.',
      },
      {
        id: 'formatting',
        label: 'Formatting',
        description: 'Does it meet structural rules (label length, microcopy length)?',
        scoring_guide: '100 = within limits. 50 = slightly over. 0 = significantly exceeds limits.',
      },
    ],
  },
  {
    id: 'distribution_balance',
    label: 'Distribution Balance',
    description: 'Is content evenly distributed across domains, pillars, audiences, and sensitivity levels?',
    weight: 0.8,
    per_item: false,
    sub_criteria: [
      {
        id: 'pillar_balance',
        label: 'Pillar Balance',
        description: 'Understand 35%, Grow 35%, Reflect 20%, Support 10%',
        scoring_guide: '100 = within 5% of targets. 50 = within 15%. 0 = more than 15% off.',
      },
      {
        id: 'audience_balance',
        label: 'Audience Balance',
        description: 'any 55%, service_member 20%, partner_family 15%, veteran 10%',
        scoring_guide: '100 = within 5% of targets. 50 = within 15%. 0 = more than 15% off.',
      },
      {
        id: 'sensitivity_balance',
        label: 'Sensitivity Balance',
        description: 'normal 80%, sensitive 18%, urgent 2%',
        scoring_guide: '100 = within 5% of targets. 50 = within 15%. 0 = more than 15% off.',
      },
      {
        id: 'domain_balance',
        label: 'Domain Balance',
        description: 'Even spread across all 11 domains',
        scoring_guide: '100 = no domain has less than half the average. 50 = some imbalance. 0 = severe imbalance.',
      },
    ],
  },
  {
    id: 'inclusivity',
    label: 'Inclusivity',
    description: 'Does content represent the diversity of its audience?',
    weight: 1.0,
    per_item: true,
    sub_criteria: [
      {
        id: 'branch_representation',
        label: 'Service Branch Representation',
        description: 'Are all branches addressed?',
        scoring_guide: '100 = all branches or generic. 50 = mostly one branch. 0 = single branch only.',
      },
      {
        id: 'gender_representation',
        label: 'Gender Representation',
        description: 'Are all genders represented in examples?',
        scoring_guide: '100 = diverse or neutral. 50 = slightly skewed. 0 = skewed toward one gender.',
      },
      {
        id: 'disability_neurodivergence',
        label: 'Disability/Neurodivergence',
        description: 'Are these perspectives included?',
        scoring_guide: '100 = acknowledged and included. 50 = not mentioned. 0 = absent where expected or tokenistic.',
      },
      {
        id: 'cultural_ethnic_diversity',
        label: 'Cultural/Ethnic Diversity',
        description: 'Is diversity reflected?',
        scoring_guide: '100 = culturally aware. 50 = neutral. 0 = monocultural assumptions.',
      },
    ],
  },
  {
    id: 'completeness',
    label: 'Completeness',
    description: 'Does this content area have adequate coverage and no dead ends?',
    weight: 1.0,
    per_item: true,
    sub_criteria: [
      {
        id: 'content_depth',
        label: 'Content Depth',
        description: 'Is there enough content in this area?',
        scoring_guide: '100 = substantive coverage. 50 = adequate but thin. 0 = sparse or placeholder.',
      },
      {
        id: 'pathway_integrity',
        label: 'Pathway Integrity',
        description: 'Do all links/references lead to real content?',
        scoring_guide: '100 = all references resolve. 50 = most resolve. 0 = broken references or dead-end.',
      },
      {
        id: 'cross_reference_validity',
        label: 'Cross-Reference Validity',
        description: 'Are referenced items published and available?',
        scoring_guide: '100 = all exist and published. 50 = most exist. 0 = references unpublished or nonexistent.',
      },
    ],
  },
  {
    id: 'marketing_alignment',
    label: 'Marketing Alignment',
    description: 'Does what the app claims to be match what it actually is?',
    weight: 0.8,
    per_item: false,
    sub_criteria: [
      {
        id: 'feature_claims',
        label: 'Feature Claims',
        description: 'Do marketing claims about features match reality?',
        scoring_guide: '100 = all claims accurate. 50 = minor discrepancies. 0 = significant false claims.',
      },
      {
        id: 'privacy_claims',
        label: 'Privacy Claims',
        description: 'Do privacy/data claims match actual data handling?',
        scoring_guide: '100 = claims match reality. 50 = minor gaps. 0 = claims contradict reality.',
      },
      {
        id: 'capability_claims',
        label: 'Capability Claims',
        description: 'Do claims about what the app can/cannot do match reality?',
        scoring_guide: '100 = accurate. 50 = slightly misleading. 0 = materially false.',
      },
    ],
  },
];

/** Categories the reviewing model scores (everything except the rule-scored ones). */
export const AI_CATEGORIES = AUDIT_CATEGORIES.filter(c => c.scored_by !== 'rules');

export const CATEGORY_MAP = Object.fromEntries(
  AUDIT_CATEGORIES.map(c => [c.id, c])
);

export function buildCriteriaPromptText(): string {
  return AUDIT_CATEGORIES.filter(cat => cat.scored_by !== 'rules').map(cat => {
    const subLines = cat.sub_criteria.map(
      sc => `    - ${sc.id}: ${sc.label} — ${sc.description}\n      Scoring: ${sc.scoring_guide}`
    ).join('\n');
    return `${cat.id}: ${cat.label} (weight: ${cat.weight}x, ${cat.per_item ? 'per-item' : 'area-level'})\n  ${cat.description}\n  Sub-criteria:\n${subLines}`;
  }).join('\n\n');
}

export function calculateWeightedScore(
  categoryScores: Record<string, { score: number; applicable: boolean }>
): number {
  let totalWeight = 0;
  let weightedSum = 0;

  for (const cat of AUDIT_CATEGORIES) {
    const cs = categoryScores[cat.id];
    if (!cs || !cs.applicable) continue;
    totalWeight += cat.weight;
    weightedSum += cs.score * cat.weight;
  }

  if (totalWeight === 0) return 0;
  return Math.round((weightedSum / totalWeight) * 100) / 100;
}
