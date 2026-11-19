// Text rules for the deterministic evidence checks.
//
// Two kinds of rule:
//
//   detector   a general check that finds a whole class of problem anywhere
//              in the app (a US healthcare term, an unsourced "research
//              shows", a diagnostic-sounding result).
//   watchlist  a specific claim that has been reviewed against trusted
//              sources and found wrong or unsupported (the R-numbered items in
//              the content source pack). Watchlist rules stop a corrected
//              claim from creeping back in. They are reported separately, so
//              the detectors' own detection rate is never overstated.
//
// Severity follows the audit's traffic lights: critical, red, amber, info.
// `review_ref` links a rule to the source pack item that motivated it.

/**
 * @typedef {{
 *   id: string, kind: 'detector'|'watchlist', title: string,
 *   category: 'trusted_source'|'uk_applicability'|'client_rule'|'safety'|'clinical_boundary'|'currency',
 *   severity: 'critical'|'red'|'amber'|'info',
 *   pattern: string, flags?: string, unless?: string,  // flags default to 'i'
 *   why: string, fix: string,
 *   source_name?: string, source_url?: string, review_ref?: string
 * }} TextRule
 */

const NHS_URGENT = 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/';
const NHS_VETS = 'https://www.nhs.uk/nhs-services/armed-forces-and-veterans-healthcare/veterans-nhs-mental-health-services/';

/** @type {TextRule[]} */
export const TEXT_RULES = [
  // -------------------------------------------------------------------------
  // Detectors: UK applicability
  // -------------------------------------------------------------------------
  { id: 'us-veterans-system', kind: 'detector', title: 'US veterans or military system', category: 'uk_applicability', severity: 'red', flags: '',
    pattern: String.raw`\bVA\b|Veterans Affairs|GI Bill|\bVet Centers?\b|\bDFAC\b|Family Readiness Groups?|\bTRICARE\b|Tricare|Military OneSource|\bcommissary\b`,
    why: 'Describes a US system that UK service personnel and veterans cannot use.',
    fix: 'Replace with the UK equivalent (NHS armed forces healthcare, Op COURAGE, VALOUR, GOV.UK veterans support) or remove.',
    source_name: "NHS: veterans' mental health services", source_url: NHS_VETS, review_ref: 'R2' },
  { id: 'us-finance-education', kind: 'detector', title: 'US finance or education term', category: 'uk_applicability', severity: 'amber', flags: '',
    pattern: String.raw`\b(?:TSP|401\(?k\)?|Roth|IRA|Social Security|Medicare|Medicaid|\d{1,2}(?:st|nd|rd|th) grade|freshman|sophomore|high school diploma|Library of Congress|SAT scores?)\b`,
    why: 'US-specific term that does not apply to UK users.',
    fix: 'Use the UK term (Armed Forces Pension Scheme, ISA, Year 10, GCSE, A level) or remove.',
    review_ref: 'R2' },
  { id: 'non-uk-emergency-number', kind: 'detector', title: 'Non-UK emergency or crisis number', category: 'uk_applicability', severity: 'critical',
    pattern: String.raw`(?:\b(?:call|dial|text|ring)\s+(?:911|988)\b|\b911\b|\b988\b|1-800-273-8255|Veterans Crisis Line|Crisis Text Line)`,
    why: 'A person in crisis in the UK could dial a number that does not work here.',
    fix: 'Use 999, NHS 111 (mental health option) and Samaritans 116 123.',
    source_name: 'NHS: urgent help for mental health', source_url: NHS_URGENT, review_ref: 'R1' },
  { id: 'non-uk-resource', kind: 'detector', title: 'Resource marked as US or non-UK', category: 'uk_applicability', severity: 'amber', flags: '',
    pattern: String.raw`🇺🇸|\bUS[- ]only\b|\bU\.S\. (?:military|veterans|service members)|\bDoD\b|Military\.com|Modern Military`,
    why: 'Points UK users to a service or audience in another country.',
    fix: 'Replace with a UK service (for LGBTQ+ veterans, Fighting With Pride) or label it clearly as overseas.',
    review_ref: 'R2' },

  // -------------------------------------------------------------------------
  // Detectors: client wording rules
  // -------------------------------------------------------------------------
  { id: 'client-royal-navy', kind: 'detector', title: 'Names the Royal Navy or Royal Marines', category: 'client_rule', severity: 'red',
    pattern: String.raw`\bRoyal Navy\b|\bRoyal Marines?\b|\bRNRMC\b`,
    why: 'Client rule: do not mention the Royal Navy, or imply its endorsement, until it endorses the app.',
    fix: 'Use neutral wording (for example "Naval Service" or "the Armed Forces") or remove.',
    review_ref: 'R4' },

  // -------------------------------------------------------------------------
  // Detectors: trusted-source traceability
  // -------------------------------------------------------------------------
  { id: 'unsourced-research-claim', kind: 'detector', title: '"Research shows" with no source', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`\b(?:research|studies|science|evidence|scientists|experts)\s+(?:has\s+|have\s+)?(?:shows?|shown|suggests?|finds?|found|proves?|proven|confirms?)\b|\bstudies have (?:shown|found)\b|\b(?:multiple|many|several) studies\b|\bresearch (?:from|by|at) [A-Z]`,
    unless: String.raw`nhs\.uk|NHS|Royal College of Psychiatrists|Mind\b|Mental Health Foundation|NICE`,
    why: 'Appeals to research without naming it, so the claim cannot be traced to a trusted source.',
    fix: 'Cite the NHS, RCPsych, Mind or Mental Health Foundation page the claim comes from, or remove the claim.' },
  { id: 'unsourced-statistic', kind: 'detector', title: 'Health statistic with no source', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`\b\d+(?:\.\d+)?\s?(?:-|–|to)?\s?\d*(?:\.\d+)?\s?%|\b(?:1|one) in \d+\b|\b\d+(?:\.\d+)? (?:times|x) (?:more|less|higher|lower|likely)\b`,
    unless: String.raw`nhs\.uk|NHS|ONS|Office for National Statistics|Royal College|Mind\b|Mental Health Foundation|[Ss]ave \d|[Dd]iscount|\boff\b|APR|[Ii]nterest|[Pp]ay rise|[Ss]alary|[Ss]avings|[Pp]ension|accountability`,
    why: 'A number presented as fact needs a trusted source the reader could check.',
    fix: 'Use the figure the NHS page gives (and link it), or reword without the number.' },
  { id: 'diagnostic-result', kind: 'detector', title: 'Result reads like a diagnosis', category: 'clinical_boundary', severity: 'red',
    pattern: String.raw`\b(?:strongly |highly )?consistent with (?:PMDD|depression|ADHD|autism|PTSD|an? (?:anxiety|eating|mood) disorder|endometriosis|perimenopause|anaemia)|\byou (?:likely |probably |may )?have (?:PMDD|depression|ADHD|PTSD|endometriosis|anaemia)\b|\bthis (?:suggests|indicates|means) you (?:have|are suffering)`,
    why: 'Only a GP or Medical Officer can diagnose. A self-check result that sounds like a diagnosis is outside a wellbeing app\'s scope.',
    fix: 'Reword to "These symptoms are worth discussing with your GP or Medical Officer."',
    source_name: 'NHS: PMDD', source_url: 'https://www.nhs.uk/conditions/pmdd-premenstrual-dysphoric-disorder/', review_ref: 'R9' },
  { id: 'medication-detail', kind: 'detector', title: 'Medication or dosing detail', category: 'clinical_boundary', severity: 'amber',
    pattern: String.raw`\b(?:SSRIs?|SNRIs?|antidepressants?|beta[- ]blockers?|benzodiazepines?|HRT|hormone replacement|ibuprofen|paracetamol|melatonin)\b[^.]{0,80}\b(?:taken|take|dose|dosage|mg|only during|safe|effective|works?)\b`,
    why: 'Medication statements must match NHS wording and be framed as something to discuss with a doctor.',
    fix: 'Use the NHS page\'s wording for this medicine and add "talk to your GP or Medical Officer".' },
  { id: 'absolute-safety-claim', kind: 'detector', title: 'Absolute safety or cure claim', category: 'clinical_boundary', severity: 'amber',
    pattern: String.raw`\b(?:is|are) (?:completely |totally |perfectly |100% )?safe for (?:most|everyone|all)\b|\bguaranteed? to\b|\b(?:best|the|a) cure (?:is|for)\b|\bcures? (?:anxiety|depression|stress|PTSD|insomnia|loneliness)\b|\bproven to (?:cure|fix|treat)\b`,
    why: 'Overstates certainty. NHS pages frame treatments as benefits and risks to discuss with a doctor.',
    fix: 'Reword to the NHS framing.' },
  { id: 'absolute-confidentiality', kind: 'detector', title: 'Promises total confidentiality', category: 'safety', severity: 'red',
    pattern: String.raw`\beverything (?:you say |you share )?is (?:completely |totally |100% )?confidential\b|\b100% confidential\b|\bwill never (?:tell|share) anyone\b`,
    why: 'Counsellors, teachers and welfare staff must share information if someone is at risk. A young person told otherwise may be misled at a critical moment.',
    fix: 'Say it is confidential unless they are worried you or someone else is at risk.',
    source_name: 'Childline', source_url: 'https://www.childline.org.uk/', review_ref: 'R20' },
  { id: 'crisis-non-crisis-service', kind: 'detector', title: 'Non-crisis service presented as crisis support', category: 'safety', severity: 'amber',
    pattern: String.raw`(?:crisis|emergency|immediate danger|urgent)[^.]{0,120}(?:Combat Stress|0800 138 1619|Veterans UK|0808 1914 218|VALOUR|Forcesline)`,
    why: 'Combat Stress and VALOUR say they are not crisis services.',
    fix: 'In crisis sections list 999, NHS 111 (mental health option) and Samaritans 116 123; move these services to general support.',
    source_name: 'NHS: urgent help for mental health', source_url: NHS_URGENT, review_ref: 'R1' },

  // -------------------------------------------------------------------------
  // Watchlist: claims reviewed against trusted sources (source pack R items)
  // -------------------------------------------------------------------------
  { id: 'wl-priority-nhs', kind: 'watchlist', title: 'Claims priority NHS treatment', category: 'trusted_source', severity: 'red',
    pattern: String.raw`priority (?:NHS )?treatment`,
    why: "The NHS veterans' page does not describe priority treatment for serving personnel.",
    fix: 'Reword to the NHS description of armed forces healthcare.', source_name: "NHS: veterans' mental health services", source_url: NHS_VETS, review_ref: 'R3' },
  { id: 'wl-uk-leave-average', kind: 'watchlist', title: '"UK average of 28 days" leave', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`UK average of 28`,
    why: '28 days is the legal minimum, not the average.', fix: 'Say "the legal minimum of 28 days".',
    source_name: 'GOV.UK: holiday entitlement', source_url: 'https://www.gov.uk/holiday-entitlement-rights', review_ref: 'R3' },
  { id: 'wl-cycle-phase-claims', kind: 'watchlist', title: 'Phase-by-phase cycle mood or training claims', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`great time for big decisions|\bACL\b|(?:Follicular|Luteal|Ovulat\w+) (?:Phase|phase)[^.]{0,80}(?:training|performance|decisions|confidence)`,
    why: 'NHS pages on periods and PMS give no phase-by-phase mood or training guidance.',
    fix: 'Keep general symptom content; remove the phase-by-phase claims.',
    source_name: 'NHS: PMS', source_url: 'https://www.nhs.uk/conditions/pre-menstrual-syndrome/', review_ref: 'R5' },
  { id: 'wl-pmdd-figures', kind: 'watchlist', title: 'PMDD prevalence or luteal-only dosing', category: 'trusted_source', severity: 'red',
    pattern: String.raw`5\s?(?:-|–|to)\s?8\s?% of women|only during the luteal phase`,
    why: 'The NHS PMDD page gives no prevalence figure and does not mention luteal-only dosing.',
    fix: 'Remove the figure and dosing detail, or cite RCPsych or NICE.',
    source_name: 'NHS: PMDD', source_url: 'https://www.nhs.uk/conditions/pmdd-premenstrual-dysphoric-disorder/', review_ref: 'R6' },
  { id: 'wl-endometriosis-figures', kind: 'watchlist', title: 'Endometriosis figures', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`7\.5 years|(?:1|one) in 10 women`,
    why: 'Not on the NHS page; Endometriosis UK (2024) puts diagnosis at almost 9 years.',
    fix: 'Cite Endometriosis UK with the current figure, or remove the numbers.',
    source_name: 'NHS: endometriosis', source_url: 'https://www.nhs.uk/conditions/endometriosis/', review_ref: 'R7' },
  { id: 'wl-magnesium-mood', kind: 'watchlist', title: 'Magnesium-rich foods stabilise mood', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`magnesium[^.]{0,60}(?:mood|stabilis|stabiliz)`,
    why: 'NHS PMS page: eat a balanced diet; "not much evidence" that supplements such as magnesium work.',
    fix: 'Reword to the NHS advice.', source_name: 'NHS: PMS', source_url: 'https://www.nhs.uk/conditions/pre-menstrual-syndrome/', review_ref: 'R8' },
  { id: 'wl-ferritin-hrt', kind: 'watchlist', title: 'Ferritin test instruction or "HRT is safe for most"', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`ferritin (?:blood )?test|HRT[^.]{0,60}safe for most`,
    why: 'NHS mentions a full blood count, and frames HRT as benefits and risks to discuss with a doctor.',
    fix: 'Reword both to the NHS wording.', source_name: 'NHS: iron deficiency anaemia', source_url: 'https://www.nhs.uk/conditions/iron-deficiency-anaemia/', review_ref: 'R10' },
  { id: 'wl-nine-second-rule', kind: 'watchlist', title: '"9-second rule" amygdala claim', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`\b(?:6\s?(?:-|–|to)\s?)?9[- ]seconds?\b`,
    why: 'Not on NHS, RCPsych or Mind; comes from popular psychology.',
    fix: 'Replace with the NHS anger advice.', source_name: 'NHS: get help with anger', source_url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/anger/', review_ref: 'R11' },
  { id: 'wl-21-day-habit', kind: 'watchlist', title: '"21 days builds a habit"', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`21 days[^.]{0,40}habit|habit[^.]{0,40}21 days`,
    why: 'A myth, and the app elsewhere says about 66 days.', fix: 'Remove the 21-day claim.', review_ref: 'R12' },
  { id: 'wl-sleep-stress-claims', kind: 'watchlist', title: 'Sleep and stress-cycle claims', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`up to 60\s?%|complete (?:the|a) stress cycle|timing is more important than duration`,
    why: 'Not on NHS sleep or stress pages; the stress cycle idea comes from a popular book.',
    fix: 'Re-source to NHS Every Mind Matters sleep and stress advice.',
    source_name: 'NHS Every Mind Matters', source_url: 'https://www.nhs.uk/every-mind-matters/', review_ref: 'R13' },
  { id: 'wl-love-languages', kind: 'watchlist', title: '"Love languages" and "flooded" break', category: 'trusted_source', severity: 'info',
    pattern: String.raw`love languages?|Words of Affirmation|Acts of Service|"flooded"|20[- ]minute break`,
    why: 'From popular relationship books, not trusted sources.',
    fix: 'Keep as optional ideas with no health claim, or remove.', review_ref: 'R14' },
  { id: 'wl-gender-generalisations', kind: 'watchlist', title: 'What men or women "often need"', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`(?:men|women) often (?:want|need)|What (?:Men|Women) Often Need`,
    why: 'No source given for the generalisation.', fix: 'Remove "research shows" or cite the Mental Health Foundation.', review_ref: 'R15' },
  { id: 'wl-breathing-claims', kind: 'watchlist', title: 'Box breathing "Navy SEALs" and physiological claims', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`Navy SEALs|(?:reduc|lower)\w* cortisol|lowers? blood pressure|energi[sz]ing breath`,
    why: 'NHS breathing exercise is in for 5, out for 5, no holds; the medical claims are not on NHS pages and fast breathing can cause light-headedness.',
    fix: 'Put the NHS exercise first; remove the SEALs and medical claims.',
    source_name: 'NHS: breathing exercises for stress', source_url: 'https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/breathing-exercises-for-stress/', review_ref: 'R16' },
  { id: 'wl-disputed-experiments', kind: 'watchlist', title: 'Disputed experiments presented as proof', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`Stanford Prison|[Mm]arshmallow (?:test|experiment)|as effective as antidepressants`,
    why: 'Both experiments are disputed by later research; the NHS recommends exercise for mild depression but does not compare it with medication.',
    fix: 'Say the findings are disputed, or remove; reword the exercise claim.', review_ref: 'R17' },
  { id: 'wl-power-pose-cold-water', kind: 'watchlist', title: 'Power pose hormones or cold water for anxiety', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`power pos\w*|testosterone[^.]{0,40}cortisol|cold water[^.]{0,60}(?:face|anxiety|panic)`,
    why: 'The hormone claim failed later studies; cold water is not on NHS pages.',
    fix: 'Remove the hormone claim; keep or remove the cold-water tip.', review_ref: 'R18' },
  { id: 'wl-puberty-acne-ages', kind: 'watchlist', title: 'Puberty "8 and 16" or acne peak ages', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`between (?:the )?ages? 8 and 16|8\s?(?:-|–|to)\s?16|acne[^.]{0,40}15\s?(?:-|–|to)\s?17`,
    why: 'NHS puberty page: normal start between 8 and 14; no acne age on the NHS acne page.',
    fix: 'Change to 8 to 14; remove the acne ages.', source_name: 'NHS: puberty', source_url: 'https://www.nhs.uk/conditions/puberty/', review_ref: 'R19' },
  { id: 'wl-bullying-claims', kind: 'watchlist', title: '"Grey rock" and "projections" claims', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`gr[ae]y rock|projections? of their own insecurit`,
    why: 'No trusted source.', fix: 'Remove both.', review_ref: 'R20' },
  { id: 'wl-unsourced-sexual-health', kind: 'watchlist', title: 'Unsourced contraception or first-experience claims', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`popular in the military|people who wait[^.]{0,40}(?:report|more positive)`,
    why: 'No source given.', fix: 'Remove both claims.', review_ref: 'R21' },
  { id: 'wl-country-law-singapore', kind: 'watchlist', title: 'Singapore listed as criminalising same-sex activity', category: 'currency', severity: 'critical',
    pattern: String.raw`Singapore`,
    unless: String.raw`repeal`,
    why: 'Singapore repealed section 377A in 2022. Out-of-date country safety lists can mislead personnel deploying abroad.',
    fix: 'Remove Singapore and base the country list on FCDO travel advice, with a date checked.',
    source_name: 'FCDO travel advice', source_url: 'https://www.gov.uk/foreign-travel-advice', review_ref: 'R23' },
  { id: 'wl-intersex-figure', kind: 'watchlist', title: '"1.7%" intersex figure', category: 'trusted_source', severity: 'amber',
    pattern: String.raw`1\.7\s?%`,
    why: 'The figure is disputed.', fix: 'Reword without the number.', review_ref: 'R23' },
];
