#!/usr/bin/env node

/**
 * Import Content Helper Script
 * 
 * Usage:
 *   node scripts/import-content.js path/to/content.json
 * 
 * This script:
 * 1. Reads the JSON file
 * 2. Posts to the import API
 * 3. Saves used IDs and labels to prevent duplicates on next run
 * 4. Shows summary of results
 */

const fs = require('fs');
const path = require('path');

const API_URL = process.env.API_URL || 'http://localhost:3002';
const TRACKING_FILE = path.join(__dirname, '../.import-tracking.json');

async function main() {
  const filePath = process.argv[2];
  
  if (!filePath) {
    console.error('Usage: node scripts/import-content.js <path-to-json>');
    process.exit(1);
  }

  // Read the JSON file
  console.log(`📖 Reading ${filePath}...`);
  const content = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  
  if (!content.items || !Array.isArray(content.items)) {
    console.error('❌ Invalid format. Expected { items: [...] }');
    process.exit(1);
  }

  console.log(`📦 Found ${content.items.length} items`);

  // Load tracking data
  let tracking = { ids: [], labels: [] };
  if (fs.existsSync(TRACKING_FILE)) {
    tracking = JSON.parse(fs.readFileSync(TRACKING_FILE, 'utf8'));
    console.log(`📋 Already imported: ${tracking.ids.length} IDs, ${tracking.labels.length} labels`);
  }

  // Post to API
  console.log(`\n⬆️  Importing to ${API_URL}/api/import...`);
  
  try {
    const response = await fetch(`${API_URL}/api/import`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(content),
    });

    const result = await response.json();
    
    console.log(`\n✅ Import complete!`);
    console.log(`   - Imported: ${result.success}`);
    console.log(`   - Skipped: ${result.skipped}`);
    console.log(`   - Failed: ${result.failed}`);
    
    if (result.errors && result.errors.length > 0) {
      console.log(`\n⚠️  Errors/Skips:`);
      result.errors.slice(0, 10).forEach(err => console.log(`   - ${err}`));
      if (result.errors.length > 10) {
        console.log(`   ... and ${result.errors.length - 10} more`);
      }
    }

    // Update tracking
    content.items.forEach(item => {
      if (item.id && !tracking.ids.includes(item.id)) {
        tracking.ids.push(item.id);
      }
      if (item.label && !tracking.labels.includes(item.label)) {
        tracking.labels.push(item.label);
      }
    });

    fs.writeFileSync(TRACKING_FILE, JSON.stringify(tracking, null, 2));
    console.log(`\n💾 Tracking file updated: ${tracking.ids.length} total IDs`);

    // Generate exclusion lists for next GPT run
    console.log(`\n📋 For your NEXT GPT run, use:`);
    console.log(`   EXCLUDE_IDS: ${JSON.stringify(tracking.ids.slice(-20))}`);
    console.log(`   EXCLUDE_LABELS: ${JSON.stringify(tracking.labels.slice(-20))}`);
    console.log(`\n   (Showing last 20 for brevity - full list saved)`);

  } catch (error) {
    console.error('❌ Import failed:', error.message);
    process.exit(1);
  }
}

main();



