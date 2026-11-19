// Known issues used to measure the audit's own detection rate.
//
// These are the items found by the manual content source pack review of
// 19 November 2026 (R1 to R23). Each case lists one or more locators: a
// pattern that finds the specific problem text in the app, written
// independently of the audit rules. `npm run audit:recall` scans the app and
// reports, for each case, whether the deterministic checks flagged that text,
// and whether it was flagged by a general detector or only by the watchlist.
//
// R24 (content that could not be reviewed) is a coverage gap, not a text
// issue; the app content snapshot addresses it.

/** @typedef {{ id: string, summary: string, locators: { label: string, pattern: string }[], needs_judgement?: boolean }} RecallCase */

/** @type {RecallCase[]} */
export const RECALL_CASES = [
  { id: 'R1', summary: 'Closed, renamed, wrong-hours, non-crisis or US helplines', locators: [
    { label: 'Veterans Gateway (closed)', pattern: 'Veterans Gateway|0808 802 1212' },
    { label: 'Big White Wall (renamed Togetherall)', pattern: 'Big White Wall|bigwhitewall' },
    { label: '"Confidential Support Line" 24/7', pattern: 'Confidential Support Line' },
    { label: 'Veterans UK welfare line shown as crisis support', pattern: 'Veterans UK: 0808 1914 218' },
    { label: 'Royal Navy & Royal Marines Charity number', pattern: '023 9387 1520' },
    { label: 'US crisis numbers (911, 988, 1-800)', pattern: '1-800-273-8255|\\b988\\b' },
  ] },
  { id: 'R2', summary: 'US content on military, veteran and young person screens', locators: [
    { label: 'VA healthcare', pattern: '\\bVA\\b' },
    { label: 'TSP / 401k', pattern: '\\bTSP\\b|401k' },
    { label: 'Vet Centers', pattern: 'Vet Centers' },
    { label: 'DFAC meals', pattern: 'DFAC' },
    { label: 'Family Readiness Groups', pattern: 'Family Readiness Groups' },
    { label: 'Library of Congress', pattern: 'Library of Congress' },
    { label: '"9th grade"', pattern: '9th grade' },
  ] },
  { id: 'R3', summary: 'Military perks: priority NHS treatment, UK leave average', locators: [
    { label: 'Priority NHS treatment', pattern: 'priority NHS treatment' },
    { label: 'UK average of 28 days', pattern: 'UK average of 28' },
  ] },
  { id: 'R4', summary: 'Royal Navy mentions', locators: [
    { label: 'Royal Navy named', pattern: 'Royal Navy' },
  ] },
  { id: 'R5', summary: 'Phase-by-phase cycle mood and training claims', locators: [
    { label: '"great time for big decisions" / ACL', pattern: 'big decisions|\\bACL\\b' },
  ] },
  { id: 'R6', summary: 'PMDD prevalence and luteal-only SSRI dosing', locators: [
    { label: '5-8% of women', pattern: '5-8% of women' },
    { label: 'Luteal-only SSRIs', pattern: 'only during the luteal phase' },
  ] },
  { id: 'R7', summary: 'Endometriosis figures', locators: [
    { label: '1 in 10 / 7.5 years', pattern: '7\\.5 years|1 in 10 women' },
  ] },
  { id: 'R8', summary: 'Magnesium-rich foods stabilise mood', locators: [
    { label: 'Magnesium claim', pattern: 'magnesium-rich foods' },
  ] },
  { id: 'R9', summary: 'Symptom checker results sound like diagnoses', locators: [
    { label: '"strongly consistent with PMDD"', pattern: 'strongly consistent with PMDD' },
  ] },
  { id: 'R10', summary: 'Ferritin test instruction; "HRT is safe for most women"', locators: [
    { label: 'Ferritin test', pattern: 'ferritin test' },
    { label: 'HRT safe for most', pattern: 'HRT[^.]{0,60}safe for most' },
  ] },
  { id: 'R11', summary: 'The 9-second rule', locators: [
    { label: '6-9 seconds amygdala claim', pattern: '6-9 seconds' },
  ] },
  { id: 'R12', summary: '"21 days builds a habit" contradicts 66 days', locators: [
    { label: '21-day habit claim', pattern: '21 days[^.]{0,40}habit|habit[^.]{0,40}21 days' },
  ] },
  { id: 'R13', summary: 'Sleep and stress-cycle claims', locators: [
    { label: '"up to 60%"', pattern: 'up to 60%' },
    { label: '"complete the stress cycle"', pattern: 'complete the stress cycle' },
  ] },
  { id: 'R14', summary: 'Love languages; 20-minute "flooded" break', needs_judgement: true, locators: [
    { label: 'Love languages', pattern: 'Words of Affirmation|love language' },
    { label: '"flooded"', pattern: '"flooded"' },
  ] },
  { id: 'R15', summary: '"Research shows men often want…" unsourced', locators: [
    { label: 'Research shows men often want', pattern: 'Research shows men often want' },
  ] },
  { id: 'R16', summary: 'Box breathing "Navy SEALs" and cortisol claims', locators: [
    { label: 'Navy SEALs', pattern: 'Used by Navy SEALs' },
    { label: 'Reduces cortisol', pattern: 'reducing cortisol' },
  ] },
  { id: 'R17', summary: 'Disputed experiments and antidepressant comparison', locators: [
    { label: 'Stanford Prison Experiment', pattern: 'Stanford Prison' },
    { label: 'Marshmallow test', pattern: 'Marshmallow Test' },
    { label: 'As effective as antidepressants', pattern: 'as effective as antidepressants' },
  ] },
  { id: 'R18', summary: 'Power pose hormones; cold water for anxiety', locators: [
    { label: 'Power pose', pattern: '[Pp]ower pos' },
  ] },
  { id: 'R19', summary: 'Puberty "8 and 16"; acne peak ages', locators: [
    { label: 'Puberty 8 and 16', pattern: 'between ages 8 and 16' },
    { label: 'Acne 15–17', pattern: 'Acne typically peaks' },
  ] },
  { id: 'R20', summary: 'Grey rock; projections; "everything is confidential"', locators: [
    { label: 'Grey rock', pattern: 'grey rock' },
    { label: 'Projections', pattern: 'projections of their own' },
    { label: 'Everything is confidential', pattern: 'Everything is confidential' },
  ] },
  { id: 'R21', summary: 'Unsourced contraception and first-experience claims', locators: [
    { label: 'Popular in the military', pattern: 'popular in the military' },
  ] },
  { id: 'R22', summary: 'Seven-phase deployment model is US research', needs_judgement: true, locators: [
    { label: 'Deployment phases', pattern: "Pre-Deployment" },
  ] },
  { id: 'R23', summary: 'Singapore listed as criminalising; 1.7% intersex', locators: [
    { label: 'Singapore', pattern: 'Singapore' },
    { label: '1.7%', pattern: '1\\.7%' },
  ] },
];

/**
 * Measure detection against the cases above.
 *
 * @param {{ location: string, text: string, hits: { kind: string, rule_id: string }[] }[]} units
 *   every scanned piece of text with its evidence hits
 */
export function computeRecall(units) {
  const rows = RECALL_CASES.map(c => {
    const locators = c.locators.map(l => {
      const re = new RegExp(l.pattern);
      const matching = units.filter(u => re.test(u.text));
      const hits = matching.flatMap(u => u.hits);
      return {
        label: l.label,
        found: matching.length > 0,
        where: matching[0]?.location ?? null,
        detector: hits.some(h => h.kind !== 'watchlist' && h.rule_id !== 'link-tier3'),
        watchlist: hits.some(h => h.kind === 'watchlist'),
      };
    });
    const present = locators.filter(l => l.found);
    const status = present.length === 0 ? 'not_found'
      : present.every(l => l.detector) ? 'detector'
      : present.every(l => l.detector || l.watchlist) ? (present.some(l => l.detector) ? 'detector_and_watchlist' : 'watchlist')
      : 'missed';
    return { id: c.id, summary: c.summary, needs_judgement: !!c.needs_judgement, status, locators };
  });
  const present = rows.filter(r => r.status !== 'not_found');
  return {
    rows,
    total: rows.length,
    present: present.length,
    by_detectors: present.filter(r => r.status === 'detector').length,
    by_detectors_or_watchlist: present.filter(r => r.status !== 'missed').length,
    missed: present.filter(r => r.status === 'missed').map(r => r.id),
    needs_judgement: rows.filter(r => r.needs_judgement).map(r => r.id),
  };
}
