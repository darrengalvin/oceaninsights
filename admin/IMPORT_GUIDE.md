# Content Import Guide

## 🤖 Generate Content with GPT

### Step 1: Use the Prompt

1. Open `gpt-content-generator.md`
2. Copy the entire prompt
3. Paste into ChatGPT (GPT-4) or Claude
4. Set your parameters at the bottom:
   ```json
   {
     "BATCH_SIZE": 50,
     "BATCH_INDEX": 1,
     "SEED": "run-001",
     "EXCLUDE_IDS": [],
     "EXCLUDE_LABELS": []
   }
   ```

### Step 2: Save the Output

1. GPT will return pure JSON
2. Save it as `content-batch-1.json` (or similar)
3. DO NOT edit the JSON manually

### Step 3: Import to Database

**Option A: Using the helper script (recommended)**
```bash
cd admin
node scripts/import-content.js content-batch-1.json
```

The script will:
- Import the content
- Track what's been imported
- Show you what to exclude on the next run

**Option B: Using curl**
```bash
curl -X POST http://localhost:3002/api/import \
  -H "Content-Type: application/json" \
  -d @content-batch-1.json
```

## 🔄 Generate More Batches

### For Batch 2:

The helper script will tell you what to exclude:

```json
{
  "BATCH_SIZE": 50,
  "BATCH_INDEX": 2,
  "SEED": "run-001",
  "EXCLUDE_IDS": ["relationships.understand.building-trust", "..."],
  "EXCLUDE_LABELS": ["Building Trust in Relationships", "..."]
}
```

Then repeat:
1. Generate with GPT
2. Save as `content-batch-2.json`
3. Import: `node scripts/import-content.js content-batch-2.json`

## 📊 How Duplicate Prevention Works

### In the Import API:
1. Checks if content with same **label + domain** exists
2. If yes: **Skips** the item
3. If no: **Imports** as draft

### In the GPT Prompt:
1. You pass `EXCLUDE_IDS` and `EXCLUDE_LABELS`
2. GPT knows not to generate those again
3. Ensures variety and no waste

### In the Helper Script:
1. Tracks all imported IDs and labels in `.import-tracking.json`
2. Tells you what to exclude next time
3. Prevents accidental duplicates

## 🎯 Recommended Workflow

### Phase 1: Initial Content (Days 1-2)
Generate 5 batches of 50 items each = 250 items
- Batch 1: Focus on Relationships & Family
- Batch 2: Focus on Identity & Grief
- Batch 3: Focus on Calm & Sleep
- Batch 4: Focus on Health & Money
- Batch 5: Focus on Work, Leadership & Transition

### Phase 2: Review & Publish (Day 3)
- Go to admin panel
- Review drafts
- Add missing details (Understand/Reflect/Grow sections)
- Publish the good ones

### Phase 3: Expand (Ongoing)
- Generate more batches as needed
- Focus on underrepresented areas
- Add seasonal/topical content

## 🏗️ Domain Distribution Target

With 11 domains, aim for roughly equal distribution:

| Domain | Target Items | Notes |
|--------|--------------|-------|
| Relationships & Connection | 100+ | High demand |
| Family, Parenting & Home Life | 80+ | Core topic |
| Identity, Belonging & Inclusion | 70+ | Important for diversity |
| Grief, Change & Life Events | 70+ | Universal experiences |
| Calm, Confidence & Emotional Skills | 100+ | High demand |
| Sleep, Energy & Recovery | 60+ | Practical topic |
| Health, Injury & Physical Wellbeing | 80+ | Relevant to military |
| Money, Housing & Practical Life | 70+ | Common stressor |
| Work, Purpose & Service Culture | 80+ | Military-specific |
| Leadership, Boundaries & Communication | 80+ | Professional skills |
| Transition, Resettlement & Civilian Life | 80+ | Military-specific |

**Total Target:** 900-1000 items

## 📝 Quality Checklist

Before importing, check the GPT output has:

✅ All items have valid domain names (exact match to the 11 domains)
✅ Labels are positive and growth-focused (not problem-focused)
✅ Microcopy is normalising and hopeful
✅ Keywords are relevant and searchable
✅ IDs are unique and stable
✅ Pillar distribution roughly: Understand 35%, Grow 35%, Reflect 20%, Support 10%
✅ Audience distribution roughly: any 55%, service_member 20%, partner_family 15%, veteran 10%

## 🐛 Troubleshooting

### "Unknown domain" errors
- Check domain name is EXACTLY one of the 11 in the list
- Case-sensitive! Must match exactly

### "Duplicate" messages
- This is normal! It means that label already exists
- The item is skipped (not imported)
- Move on to next batch

### Import script fails
- Make sure admin panel is running on port 3002
- Check `.env.local` is configured
- Try the curl command instead

## 💡 Pro Tips

1. **Generate in batches** - Don't try to do 1000 at once. Do 50-100 at a time.
2. **Review as you go** - Publish some content between batches to test quality
3. **Track your progress** - Keep the import tracking file safe
4. **Focus on quality** - Better to have 300 great items than 1000 mediocre ones
5. **Use the helper script** - It saves time and prevents mistakes

## 🔐 Security Note

The import API uses the service_role key (full access) on the server side. The Flutter app only ever reads published content with the anon key (read-only).



