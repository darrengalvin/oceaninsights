#!/usr/bin/env node

/**
 * Run rituals schema and seed data migration
 * Usage: node scripts/run-rituals-migration.js
 */

const fs = require('fs')
const path = require('path')
const https = require('https')

require('dotenv').config({ path: '.env.local' })

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY

// Extract project ref from URL
const projectRef = SUPABASE_URL.replace('https://', '').split('.')[0]

async function executeSql(sql, description) {
  console.log(`\n📝 ${description}...`)
  
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ query: sql })
    
    const options = {
      hostname: `${projectRef}.supabase.co`,
      port: 443,
      path: '/rest/v1/rpc/exec_sql',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Length': Buffer.byteLength(postData)
      }
    }

    const req = https.request(options, (res) => {
      let data = ''
      res.on('data', (chunk) => data += chunk)
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log(`   ✅ Success`)
          resolve(data)
        } else {
          // If RPC doesn't exist, we'll need to run via dashboard
          console.log(`   ⚠️  Status: ${res.statusCode}`)
          resolve(null)
        }
      })
    })

    req.on('error', (e) => {
      console.log(`   ❌ Error: ${e.message}`)
      resolve(null)
    })

    req.write(postData)
    req.end()
  })
}

async function runMigrations() {
  console.log('🚀 Running Rituals Schema Migration')
  console.log('===================================')
  console.log(`Project: ${projectRef}`)
  
  // Read SQL files
  const schemaPath = path.join(__dirname, '../../supabase/rituals-schema.sql')
  const seedPath = path.join(__dirname, '../../supabase/rituals-seed-data.sql')
  
  if (!fs.existsSync(schemaPath)) {
    console.error('❌ Schema file not found:', schemaPath)
    process.exit(1)
  }
  
  if (!fs.existsSync(seedPath)) {
    console.error('❌ Seed file not found:', seedPath)
    process.exit(1)
  }
  
  const schemaSql = fs.readFileSync(schemaPath, 'utf8')
  const seedSql = fs.readFileSync(seedPath, 'utf8')
  
  console.log(`\n📄 Schema SQL: ${schemaSql.length} characters`)
  console.log(`📄 Seed SQL: ${seedSql.length} characters`)
  
  // Try to execute via RPC (may not work if exec_sql doesn't exist)
  const schemaResult = await executeSql(schemaSql, 'Running schema migration')
  
  if (schemaResult === null) {
    console.log('\n' + '='.repeat(60))
    console.log('⚠️  MANUAL MIGRATION REQUIRED')
    console.log('='.repeat(60))
    console.log('\nThe automatic migration could not run. Please run the SQL')
    console.log('manually in the Supabase Dashboard SQL Editor:\n')
    console.log('1. Go to: https://supabase.com/dashboard/project/' + projectRef + '/sql')
    console.log('2. First, paste and run the SCHEMA file:')
    console.log('   supabase/rituals-schema.sql')
    console.log('3. Then, paste and run the SEED DATA file:')
    console.log('   supabase/rituals-seed-data.sql')
    console.log('\n' + '='.repeat(60))
    
    // Output a combined file for easy copy-paste
    const combinedPath = path.join(__dirname, '../../supabase/rituals-FULL-MIGRATION.sql')
    const combined = `-- RITUALS FULL MIGRATION
-- Run this in Supabase SQL Editor
-- Generated: ${new Date().toISOString()}
-- ===========================================

${schemaSql}

-- ===========================================
-- SEED DATA
-- ===========================================

${seedSql}
`
    fs.writeFileSync(combinedPath, combined)
    console.log(`\n✅ Combined SQL file created: supabase/rituals-FULL-MIGRATION.sql`)
    console.log('   Copy the contents of this file to the Supabase SQL Editor.')
    
    return
  }
  
  // If schema worked, run seed
  await executeSql(seedSql, 'Running seed data')
  
  console.log('\n✅ Migration complete!')
}

runMigrations().catch(console.error)
