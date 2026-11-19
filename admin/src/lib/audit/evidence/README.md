# Evidence checks

The content audit has two layers:

1. **AI review** (`../reviewer.ts`): Claude Opus 5.5 scores every item against the rubric in `../criteria.ts`, including *Trusted Source Traceability* (does each claim match a named NHS, RCPsych, Mind, Mental Health Foundation or GOV.UK page?). Every factual claim is logged in the citation register with the trusted page it was checked against and whether it matches, differs, or has no trusted source.
2. **Evidence checks** (this folder): fixed rules, no AI. The same content always gives the same result, and every flag names the rule, the reason and the source it was checked against. They are scored as the *Evidence Checks* category (weight 1.5) on every item in every audit run, and shown live on **Content Audit → Evidence** (`/admin/audit/evidence`, CSV at `/api/audit/evidence?format=csv`).

## Files

| File | What it holds |
|---|---|
| `registry.mjs` | Trusted-source list (tiers 1 to 3), verified helpline register (number, status, hours, page checked, date checked), closed and renamed services. |
| `rules.mjs` | Text rules. *Detectors* find a whole class of problem (US systems, unsourced "research shows", diagnostic-sounding results, Royal Navy naming). The *watchlist* holds specific claims already reviewed against trusted sources, so a corrected claim cannot creep back. |
| `scan.mjs` | Runs the registers and rules over any text. |
| `recall-cases.mjs` | The 23 issues from the 19 November 2026 source pack review, used to measure the checks' own detection rate. |
| `app-content-snapshot.json` | The text built into the Flutter app (`lib/`), so the audit covers the app as shipped, not only the database. Generated, do not edit. |

These are plain JavaScript so the Node scripts below and the Next.js admin share one copy.

## Commands (run in `admin/`)

```bash
npm run audit:snapshot   # refresh the app content snapshot after app text changes
npm run audit:evidence   # run the checks over the app text and Supabase seed files
npm run audit:recall     # detection rate against the source pack issues
npm run audit:evidence -- --md report.md --json report.json
```

Refresh the snapshot whenever the app's text changes, so the deployed admin audits what the app actually shows. The Evidence page shows the snapshot's commit and date.

## Keeping the registers current

When an organisation changes a number or page, edit its entry in `registry.mjs`, set `checked_on` to the date you checked, and run `npm run audit:evidence` to see what in the app is affected. A phone number found in the app that is not in the register is flagged as unregistered, so a new number cannot reach users unchecked.
