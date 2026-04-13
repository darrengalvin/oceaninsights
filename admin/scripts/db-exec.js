const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const PROJECT_REF = 'vecclmzkzrwsrtokkclr';
const DB_PASSWORD = process.env.DB_PASSWORD;

if (!DB_PASSWORD) {
  console.error('DB_PASSWORD env var required.');
  console.error('PowerShell:  $env:DB_PASSWORD="yourpass"; node scripts/db-exec.js [sql-file]');
  process.exit(1);
}

const CONN = `postgresql://postgres:${encodeURIComponent(DB_PASSWORD)}@db.${PROJECT_REF}.supabase.co:5432/postgres`;

async function main() {
  const sqlFile = process.argv[2];
  const sql = sqlFile
    ? fs.readFileSync(path.resolve(sqlFile), 'utf8')
    : process.argv[3] || 'SELECT 1 as test';

  const client = new Client({ connectionString: CONN, ssl: { rejectUnauthorized: false } });
  await client.connect();
  console.log('Connected.');

  const statements = sql.split(';').map(s => s.trim()).filter(s => s.length > 0 && !s.startsWith('--'));

  for (const stmt of statements) {
    try {
      const res = await client.query(stmt);
      const preview = stmt.replace(/\s+/g, ' ').substring(0, 80);
      console.log(`OK: ${preview}${stmt.length > 80 ? '...' : ''}`);
      if (res.rows && res.rows.length > 0 && res.rows.length <= 10) {
        console.log('   ', JSON.stringify(res.rows));
      }
    } catch (err) {
      console.log(`ERR: ${err.message}`);
    }
  }

  await client.end();
  console.log('Done.');
}

main().catch(console.error);
