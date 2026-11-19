// Evidence registers for the content audit.
//
// These are the reference lists the audit checks the app against. They are
// data, kept in one reviewable file, so the evidence behind every check can be
// read, challenged and updated without touching the audit code. Each entry
// records where it was checked and when.
//
// Plain JavaScript (ESM) so both the Next.js admin and the Node CLI scripts
// can import it.
//
// Updating: when an organisation changes a number or a page moves, edit the
// entry, set `checked_on` to the date you checked, and re-run
// `npm run audit:evidence` to see what in the app is affected.

/** Date the registers below were last reviewed in full. */
export const REGISTER_REVIEWED_ON = '2026-11-19';

// ---------------------------------------------------------------------------
// Trusted sources
// ---------------------------------------------------------------------------
//
// Client rule (19 Nov 2026): all app information must reflect the NHS or
// trusted sources only. Tier 1 is the client's named list. Tier 2 is official
// UK government, NHS bodies and statutory regulators. Tier 3 is established
// UK charities that the NHS itself signposts to; whether these count as
// "trusted" for health claims is the client's decision, so the audit reports
// them separately rather than treating them as Tier 1.

/** @typedef {{ domain: string, name: string, tier: 1|2|3, note?: string }} TrustedSource */

/** @type {TrustedSource[]} */
export const TRUSTED_SOURCES = [
  // Tier 1: named by the client
  { domain: 'nhs.uk', name: 'NHS (including NHS trusts and Every Mind Matters)', tier: 1 },
  { domain: 'rcpsych.ac.uk', name: 'Royal College of Psychiatrists', tier: 1 },
  { domain: 'mind.org.uk', name: 'Mind', tier: 1 },
  { domain: 'mentalhealth.org.uk', name: 'Mental Health Foundation', tier: 1 },

  // Tier 2: official UK government, NHS bodies, clinical guidance, regulators
  { domain: 'gov.uk', name: 'GOV.UK and UK government departments', tier: 2 },
  { domain: 'mod.uk', name: 'Ministry of Defence', tier: 2 },
  { domain: 'nice.org.uk', name: 'NICE', tier: 2 },
  { domain: 'nhsinform.scot', name: 'NHS inform (Scotland)', tier: 2 },
  { domain: 'nhs.wales', name: 'NHS Wales', tier: 2 },
  { domain: 'valour.campaign.gov.uk', name: 'VALOUR (MOD veterans support)', tier: 2 },
  { domain: 'hscni.net', name: 'Health and Social Care Northern Ireland', tier: 2 },
  { domain: 'nidirect.gov.uk', name: 'nidirect (Northern Ireland)', tier: 2 },
  { domain: 'legislation.gov.uk', name: 'UK legislation', tier: 2 },
  { domain: 'scoaf.org.uk', name: 'Service Complaints Ombudsman for the Armed Forces', tier: 2 },

  // Tier 3: established UK charities signposted by the NHS (client to confirm)
  { domain: 'samaritans.org', name: 'Samaritans', tier: 3 },
  { domain: 'giveusashout.org', name: 'Shout', tier: 3 },
  { domain: 'thecalmzone.net', name: 'CALM', tier: 3 },
  { domain: 'papyrus-uk.org', name: 'Papyrus', tier: 3 },
  { domain: 'childline.org.uk', name: 'Childline', tier: 3 },
  { domain: 'nspcc.org.uk', name: 'NSPCC', tier: 3 },
  { domain: 'youngminds.org.uk', name: 'YoungMinds', tier: 3 },
  { domain: 'brook.org.uk', name: 'Brook', tier: 3 },
  { domain: 'combatstress.org.uk', name: 'Combat Stress', tier: 3 },
  { domain: 'cruse.org.uk', name: 'Cruse Bereavement Support', tier: 3 },
  { domain: 'ssafa.org.uk', name: 'SSAFA', tier: 3 },
  { domain: 'helpforheroes.org.uk', name: 'Help for Heroes', tier: 3 },
  { domain: 'britishlegion.org.uk', name: 'Royal British Legion', tier: 3 },
  { domain: 'togetherall.com', name: 'Togetherall', tier: 3 },
  { domain: 'rapecrisis.org.uk', name: 'Rape Crisis England & Wales', tier: 3 },
  { domain: 'nationaldahelpline.org.uk', name: 'National Domestic Abuse Helpline (Refuge)', tier: 3 },
  { domain: 'refuge.org.uk', name: 'Refuge', tier: 3 },
  { domain: 'mensadviceline.org.uk', name: "Men's Advice Line", tier: 3 },
  { domain: 'fightingwithpride.org.uk', name: 'Fighting With Pride', tier: 3 },
  { domain: 'switchboard.lgbt', name: 'Switchboard LGBT+', tier: 3 },
  { domain: 'switchboard.org.uk', name: 'Switchboard LGBT+', tier: 3 },
  { domain: 'mermaidsuk.org.uk', name: 'Mermaids', tier: 3 },
  { domain: 'ditchthelabel.org', name: 'Ditch the Label', tier: 3 },
  { domain: 'relate.org.uk', name: 'Relate', tier: 3 },
  { domain: 'family-action.org.uk', name: 'Family Action', tier: 3 },
  { domain: 'actionforchildren.org.uk', name: 'Action for Children', tier: 3 },
  { domain: 'tommys.org', name: "Tommy's", tier: 3 },
  { domain: 'miscarriageassociation.org.uk', name: 'Miscarriage Association', tier: 3 },
  { domain: 'endometriosis-uk.org', name: 'Endometriosis UK', tier: 3 },
  { domain: 'bdadyslexia.org.uk', name: 'British Dyslexia Association', tier: 3 },
  { domain: 'adhduk.co.uk', name: 'ADHD UK', tier: 3 },
  { domain: 'nff.org.uk', name: 'Naval Families Federation', tier: 3 },
  { domain: 'aff.org.uk', name: 'Army Families Federation', tier: 3 },
  { domain: 'raf-ff.org.uk', name: 'RAF Families Federation', tier: 3 },
];

export const TIER_LABELS = {
  1: 'Client-named trusted source',
  2: 'Official UK government or NHS body',
  3: 'UK charity signposted by the NHS',
  0: 'Not on the trusted list',
};

// ---------------------------------------------------------------------------
// Helpline register
// ---------------------------------------------------------------------------
//
// Every phone number the app shows should be on this list with status
// `verified`. Any number the audit finds that is not listed is reported as
// unregistered, so a new number cannot reach users unchecked.
//
// status:
//   verified    number and hours match the organisation's own page
//   caution     number is real but the app must describe it correctly (see note)
//   to_confirm  awaiting confirmation from the organisation
//   closed      service closed or number withdrawn: must not appear
//   non_uk      not a UK service: must not appear in a UK app
//   client_rule breaks a client wording rule: must not appear

/**
 * @typedef {{
 *   numbers: string[], service: string, status: 'verified'|'caution'|'to_confirm'|'closed'|'non_uk'|'client_rule',
 *   hours?: string, crisis_line?: boolean, note?: string,
 *   source_name: string, source_url: string, checked_on: string
 * }} HelplineEntry
 */

/** @type {HelplineEntry[]} */
export const HELPLINES = [
  { numbers: ['999'], service: 'Emergency services', status: 'verified', hours: '24/7', crisis_line: true,
    source_name: 'NHS: urgent help for mental health', source_url: 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/', checked_on: '2026-11-19' },
  { numbers: ['111'], service: 'NHS 111 (mental health option)', status: 'verified', hours: '24/7', crisis_line: true,
    source_name: 'NHS: urgent help for mental health', source_url: 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/', checked_on: '2026-11-19' },
  { numbers: ['116123'], service: 'Samaritans', status: 'verified', hours: '24/7', crisis_line: true,
    source_name: 'NHS: urgent help for mental health', source_url: 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/', checked_on: '2026-11-19' },
  { numbers: ['85258'], service: 'Shout (text SHOUT; YoungMinds text YM)', status: 'verified', hours: '24/7', crisis_line: true,
    source_name: 'NHS: help for suicidal thoughts', source_url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/behaviours/help-for-suicidal-thoughts/', checked_on: '2026-11-19' },
  { numbers: ['0800585858'], service: 'CALM', status: 'verified', hours: '5pm to midnight daily', crisis_line: true,
    source_name: 'NHS: help for suicidal thoughts', source_url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/behaviours/help-for-suicidal-thoughts/', checked_on: '2026-11-19' },
  { numbers: ['08000684141'], service: 'Papyrus HOPELINE247', status: 'verified', hours: '24/7', crisis_line: true,
    source_name: 'NHS: help for suicidal thoughts', source_url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/behaviours/help-for-suicidal-thoughts/', checked_on: '2026-11-19' },
  { numbers: ['08001111'], service: 'Childline', status: 'verified', hours: '24/7', crisis_line: true,
    source_name: 'NHS: help for suicidal thoughts', source_url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/behaviours/help-for-suicidal-thoughts/', checked_on: '2026-11-19' },
  { numbers: ['08001381619'], service: 'Combat Stress', status: 'caution', hours: '24/7', crisis_line: false,
    note: 'Combat Stress states it is not a crisis service. Do not list it under "If you\'re in crisis".',
    source_name: 'Combat Stress: contact us', source_url: 'https://combatstress.org.uk/contact-us', checked_on: '2026-11-19' },
  { numbers: ['03001233393'], service: 'Mind Infoline', status: 'verified', hours: 'Mon to Fri 9am to 6pm', crisis_line: false,
    source_name: 'Mind: helplines', source_url: 'https://www.mind.org.uk/helplines', checked_on: '2026-11-19' },
  { numbers: ['08082000247'], service: 'National Domestic Abuse Helpline', status: 'verified', hours: '24/7',
    source_name: 'Army: ask for help', source_url: 'https://www.army.mod.uk/support-and-training/health-performance-and-wellbeing/ask-for-help/', checked_on: '2026-11-19' },
  { numbers: ['08088010327'], service: "Men's Advice Line", status: 'verified',
    source_name: 'Army: ask for help', source_url: 'https://www.army.mod.uk/support-and-training/health-performance-and-wellbeing/ask-for-help/', checked_on: '2026-11-19' },
  { numbers: ['08088024040'], service: 'Respect Phoneline', status: 'verified',
    source_name: 'NHS: getting help for domestic violence and abuse', source_url: 'https://www.nhs.uk/live-well/getting-help-for-domestic-violence/', checked_on: '2026-11-19' },
  { numbers: ['08009995428'], service: 'Galop (LGBT+ domestic abuse)', status: 'verified',
    source_name: 'NHS: getting help for domestic violence and abuse', source_url: 'https://www.nhs.uk/live-well/getting-help-for-domestic-violence/', checked_on: '2026-11-19' },
  { numbers: ['08081640123'], service: 'Samaritans Welsh language line', status: 'verified', crisis_line: true,
    source_name: 'Mind: treatment and support for suicidal thoughts', source_url: 'https://www.mind.org.uk/information-support/suicidal-thoughts-and-suicide-prevention/treatment-and-support/', checked_on: '2026-11-19' },
  { numbers: ['08085002222'], service: 'Rape Crisis', status: 'verified', hours: '24/7',
    source_name: 'Rape Crisis England & Wales', source_url: 'https://rapecrisis.org.uk', checked_on: '2026-11-19' },
  { numbers: ['02039813810'], service: 'Fighting With Pride', status: 'verified',
    source_name: 'Fighting With Pride: get support', source_url: 'https://www.fightingwithpride.org.uk/support/get-support/', checked_on: '2026-11-19' },
  { numbers: ['08000119100'], service: 'Switchboard LGBT+', status: 'verified',
    source_name: 'Switchboard: helpline', source_url: 'https://www.switchboard.org.uk/projects/helpline', checked_on: '2026-11-19' },
  { numbers: ['08088010400'], service: 'Mermaids', status: 'verified',
    source_name: 'Mermaids: support line', source_url: 'https://www.mermaidsuk.org.uk/support-line', checked_on: '2026-11-19' },
  { numbers: ['03003039888'], service: 'Help for Heroes', status: 'verified', hours: 'Mon to Fri 9am to 5pm',
    source_name: 'Help for Heroes: ask for help', source_url: 'https://helpforheroes.org.uk/ask-for-help', checked_on: '2026-11-19' },
  { numbers: ['08002606767', '08002606780'], service: 'SSAFA Forcesline', status: 'verified', hours: 'Mon to Thu 9am to 5pm, Fri 9am to 4pm', crisis_line: false,
    note: 'Not 24/7. Check any hours shown next to the number.',
    source_name: 'SSAFA: Forcesline', source_url: 'https://www.ssafa.org.uk/get-help/forcesline/', checked_on: '2026-11-19' },
  { numbers: ['08007314880'], service: 'SSAFA Forcesline (number shown on the Army site)', status: 'to_confirm', hours: 'Not 24/7', crisis_line: false,
    note: 'SSAFA\'s own page shows 0800 260 6767, not this number. It is not 24/7 and it is not a "Confidential Support Line". Confirm with SSAFA, then use one number throughout.',
    source_name: 'SSAFA: Forcesline', source_url: 'https://www.ssafa.org.uk/get-help/forcesline/', checked_on: '2026-11-19' },
  { numbers: ['02078773450'], service: 'Service Complaints Ombudsman', status: 'to_confirm',
    note: 'Website confirmed; the number is not shown on the Ombudsman\'s page.',
    source_name: 'SCOAF', source_url: 'https://www.scoaf.org.uk', checked_on: '2026-11-19' },
  { numbers: ['08088028080', '02033768080'], service: 'Royal British Legion', status: 'verified', hours: '8am to 8pm, 7 days a week', crisis_line: false,
    note: 'UK 0808 802 8080; from overseas +44 (0)20 3376 8080 (charges apply).',
    source_name: 'Royal British Legion: get in touch', source_url: 'https://www.britishlegion.org.uk/about-us/who-we-are/get-in-touch', checked_on: '2026-11-19' },
  { numbers: ['08081914218'], service: 'VALOUR / Veterans Welfare Service (MOD)', status: 'caution', crisis_line: false,
    note: 'A welfare line, not a crisis line. Do not present it as crisis support.',
    source_name: 'VALOUR: get in touch', source_url: 'https://valour.campaign.gov.uk/support-for-veterans/get-in-touch-contact-valour/', checked_on: '2026-11-19' },
  { numbers: ['08088021212'], service: 'Veterans Gateway', status: 'closed',
    note: 'Closed on 30 September 2024. Replaced by GOV.UK\'s support for veterans directory and VALOUR.',
    source_name: 'GOV.UK: support for veterans', source_url: 'https://www.gov.uk/support-for-veterans', checked_on: '2026-11-19' },
  { numbers: ['02393871520'], service: 'Royal Navy and Royal Marines Charity', status: 'client_rule',
    note: 'Names the Royal Navy, which the client has asked not to mention until it endorses the app.',
    source_name: 'Client instruction, 19 Nov 2026', source_url: '', checked_on: '2026-11-19' },
  { numbers: ['911'], service: 'US emergency number', status: 'non_uk',
    note: 'US number. UK users need 999 (or 112).',
    source_name: 'NHS: urgent help for mental health', source_url: 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/', checked_on: '2026-11-19' },
  { numbers: ['988', '18002738255'], service: 'US 988 Suicide & Crisis Lifeline / Veterans Crisis Line', status: 'non_uk',
    note: 'US services. The 1-800 number has also been replaced by 988 in the US. Use Samaritans 116 123 and NHS 111.',
    source_name: 'NHS: urgent help for mental health', source_url: 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/', checked_on: '2026-11-19' },
];

// ---------------------------------------------------------------------------
// Renamed or closed services named in text (not by number)
// ---------------------------------------------------------------------------

export const RETIRED_SERVICES = [
  { pattern: 'Big ?White ?Wall|bigwhitewall', status: 'renamed', replacement: 'Togetherall (togetherall.com)',
    source_name: 'Togetherall', source_url: 'https://togetherall.com/en-gb/', checked_on: '2026-11-19' },
  { pattern: 'Veterans Gateway', status: 'closed', replacement: 'GOV.UK support for veterans, or VALOUR 0808 1914 218 (welfare, not crisis)',
    source_name: 'GOV.UK: support for veterans', source_url: 'https://www.gov.uk/support-for-veterans', checked_on: '2026-11-19' },
  { pattern: 'Confidential Support Line', status: 'not_a_service', replacement: 'SSAFA Forcesline by its own name and hours',
    note: 'No service by this name is listed by SSAFA or the MOD; the number the app gives is SSAFA Forcesline, which is not 24/7.',
    source_name: 'SSAFA: Forcesline', source_url: 'https://www.ssafa.org.uk/get-help/forcesline/', checked_on: '2026-11-19' },
];
