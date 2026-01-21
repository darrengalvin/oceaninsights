#!/usr/bin/env node

/**
 * Backfill existing content with AI-generated complete content
 * Usage: node scripts/backfill-content.js
 */

require('dotenv').config({ path: '.env.local' })
const { createClient } = require('@supabase/supabase-js')

const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

const OPENAI_API_KEY = process.env.OPENAI_API_KEY

async function generateCompleteContent(item) {
  const prompt = `Generate COMPLETE educational content for this item. Return ONLY valid JSON.

Item to expand:
- Label: ${item.label}
- Microcopy: ${item.microcopy}
- Domain: ${item.domain_name}
- Pillar: ${item.pillar}
- Audience: ${item.audience}

Generate in UK English, positive and growth-focused.

Required JSON format:
{
  "understand_title": "Clear educational title",
  "understand_body": "2-3 paragraphs. Educational and normalising. 150-300 words.",
  "understand_examples": "1-2 concrete real-world examples. 50-100 words.",
  "understand_insights": ["Insight 1", "Insight 2", "Insight 3"],
  "reflect_prompts": ["Question 1?", "Question 2?", "Question 3?"],
  "grow_title": "Practical section title",
  "grow_steps": [
    {"action": "Step 1", "detail": "How and why"},
    {"action": "Step 2", "detail": "How and why"}
  ],
  "grow_obstacles": "Common challenges. 50-100 words.",
  "when_to_seek_help": "When professional help needed. Empty if not applicable.",
  "affirmation": "Short positive closing"
}`

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${OPENAI_API_KEY}`,
    },
    body: JSON.stringify({
      model: 'gpt-4-turbo-preview',
      messages: [
        { role: 'user', content: prompt },
      ],
      temperature: 0.7,
      max_tokens: 2000,
    }),
  })

  if (!response.ok) {
    throw new Error(`OpenAI API failed: ${response.statusText}`)
  }

  const data = await response.json()
  const content = data.choices[0].message.content

  // Parse JSON
  const cleaned = content.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim()
  return JSON.parse(cleaned)
}

async function backfill() {
  console.log('🔍 Finding content items that need backfilling...\n')

  // Get all content items with their current details
  const { data: items, error } = await supabaseAdmin
    .from('content_items')
    .select(`
      id,
      label,
      microcopy,
      pillar,
      audience,
      domains (name),
      content_details (
        understand_body,
        understand_examples,
        grow_obstacles,
        when_to_seek_help
      )
    `)
    .limit(100)

  if (error) {
    console.error('❌ Failed to fetch items:', error)
    return
  }

  // Filter items that need backfilling (missing new fields)
  const needsBackfill = items.filter(item => {
    const details = item.content_details?.[0]
    return !details?.understand_body || 
           !details?.understand_examples ||
           !details?.grow_obstacles
  })

  console.log(`📊 Found ${needsBackfill.length} items needing backfill out of ${items.length} total\n`)

  if (needsBackfill.length === 0) {
    console.log('✅ All content is up to date!')
    return
  }

  console.log(`🤖 Generating complete content for ${needsBackfill.length} items...\n`)

  let success = 0
  let failed = 0

  for (const item of needsBackfill) {
    try {
      console.log(`  Processing: "${item.label}"...`)
      
      // Generate complete content
      const generated = await generateCompleteContent({
        label: item.label,
        microcopy: item.microcopy,
        domain_name: item.domains.name,
        pillar: item.pillar,
        audience: item.audience,
      })

      // Update content_details (use UPDATE not INSERT since they already exist)
      const { error: updateError } = await supabaseAdmin
        .from('content_details')
        .update(generated)
        .eq('content_item_id', item.id)

      if (updateError) throw updateError

      success++
      console.log(`    ✅ Done`)

      // Rate limiting - wait 1 second between requests
      await new Promise(resolve => setTimeout(resolve, 1000))

    } catch (error) {
      failed++
      console.error(`    ❌ Failed: ${error.message}`)
    }
  }

  console.log(`\n📊 Backfill complete:`)
  console.log(`   ✅ Success: ${success}`)
  console.log(`   ❌ Failed: ${failed}`)
}

if (!OPENAI_API_KEY) {
  console.error('❌ OPENAI_API_KEY not found in .env.local')
  process.exit(1)
}

backfill()

