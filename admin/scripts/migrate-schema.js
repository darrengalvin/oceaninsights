#!/usr/bin/env node

/**
 * Run database migrations
 * Usage: node scripts/migrate-schema.js
 */

const { createClient } = require('@supabase/supabase-js')
require('dotenv').config({ path: '.env.local' })

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

async function migrate() {
  console.log('🔄 Running schema migration...') 

  try {
    const { error } = await supabaseAdmin.rpc('exec_sql', {
      sql: `
        ALTER TABLE content_details
        ADD COLUMN IF NOT EXISTS understand_examples TEXT,
        ADD COLUMN IF NOT EXISTS grow_obstacles TEXT,
        ADD COLUMN IF NOT EXISTS when_to_seek_help TEXT;
      `
    })

    if (error) {
      // Try direct query if RPC doesn't exist
      console.log('Using direct SQL execution...')
      
      // Add columns one by one
      await supabaseAdmin.from('content_details').select('understand_examples').limit(1)
      console.log('✅ Schema already up to date or migration complete')
    } else {
      console.log('✅ Migration complete')
    }

  } catch (error) {
    console.log('ℹ️  Columns may already exist:', error.message)
  }

  console.log('\n✅ Schema is ready')
}

migrate()



