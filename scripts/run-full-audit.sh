#!/usr/bin/env bash
# Drive a full audit from the shell, mirroring what the dashboard does
# client-side. Uses the service-role bearer to bypass session auth.
#
# Output: streamed progress to stdout. Each area takes 30-110s; full run
# of 32 areas typically takes 30-60 minutes.
#
# Usage: ./scripts/run-full-audit.sh

set -euo pipefail

BASE="https://admin-pi-eosin-53.vercel.app"
KEY="${SUPABASE_SERVICE_ROLE_KEY:-}"

if [[ -z "$KEY" ]]; then
  KEY=$(grep -E "^SUPABASE_SERVICE_ROLE_KEY=" admin/.env.local 2>/dev/null | head -1 | sed 's/^[^=]*=//' | tr -d '"' | tr -d "'" | tr -d '\r' | tr -d '\n')
fi

if [[ -z "$KEY" ]]; then
  echo "ERROR: SUPABASE_SERVICE_ROLE_KEY not set and not found in admin/.env.local"
  exit 1
fi

AUTH="Authorization: Bearer ${KEY}"
START_TIME=$(date +%s)

echo "===================================================="
echo " Full audit orchestration"
echo " Started: $(date)"
echo "===================================================="
echo ""

# Step 1: Create the run
echo "[1/3] Creating audit run..."
CREATE=$(curl -sS -X POST "${BASE}/api/audit/run" \
  -H "$AUTH" -H "Content-Type: application/json" -d '{}')

RUN_ID=$(echo "$CREATE" | python3 -c "import json,sys; print(json.load(sys.stdin)['run_id'])")
AREAS=$(echo "$CREATE" | python3 -c "import json,sys; print(' '.join(json.load(sys.stdin)['areas']))")
AREAS_TOTAL=$(echo "$AREAS" | wc -w | tr -d ' ')

echo "  Run ID: $RUN_ID"
echo "  Areas to audit: $AREAS_TOTAL"
echo ""

# Step 2: Audit each area sequentially
echo "[2/3] Auditing areas (sequential, ~30-110s each)..."
echo ""

I=0
TOTAL_ITEMS=0
TOTAL_FINDINGS=0
TOTAL_CRITICAL=0

for AREA in $AREAS; do
  AREA_START=$(date +%s)
  printf "  [%2d/%2d] %-32s " "$((I+1))" "$AREAS_TOTAL" "$AREA"

  RESP=$(curl -sS -X POST "${BASE}/api/audit/run-area" \
    -H "$AUTH" -H "Content-Type: application/json" \
    --max-time 130 \
    -d "{\"run_id\":\"${RUN_ID}\",\"area_id\":\"${AREA}\",\"area_index\":${I},\"areas_total\":${AREAS_TOTAL}}" \
    || echo '{"error":"timeout"}')

  AREA_DUR=$(($(date +%s) - AREA_START))

  STATUS=$(echo "$RESP" | python3 -c "import json,sys
try:
  d=json.load(sys.stdin); print(d.get('status') or d.get('error','unknown'))
except: print('parse_error')")

  ITEMS=$(echo "$RESP" | python3 -c "import json,sys
try: print(json.load(sys.stdin).get('items',0))
except: print(0)")

  FINDINGS=$(echo "$RESP" | python3 -c "import json,sys
try: print(json.load(sys.stdin).get('findings',0))
except: print(0)")

  SCORE=$(echo "$RESP" | python3 -c "import json,sys
try:
  s=json.load(sys.stdin).get('score'); print('-' if s is None else f'{s:.0f}%')
except: print('-')")

  TOTAL_ITEMS=$((TOTAL_ITEMS + ITEMS))
  TOTAL_FINDINGS=$((TOTAL_FINDINGS + FINDINGS))
  printf "%-10s items=%-3s findings=%-3s score=%-5s (%ds)\n" \
    "$STATUS" "$ITEMS" "$FINDINGS" "$SCORE" "$AREA_DUR"

  I=$((I + 1))
done

echo ""
echo "[3/3] Finalising run..."

# Compute system score from area averages stored on items in DB
PATCH_RESP=$(curl -sS -X PATCH "${BASE}/api/audit/run" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"run_id\":\"${RUN_ID}\",\"status\":\"completed\"}")

TOTAL_DUR=$(( $(date +%s) - START_TIME ))
echo ""
echo "===================================================="
echo " DONE in $((TOTAL_DUR/60))m $((TOTAL_DUR%60))s"
echo " Run ID: $RUN_ID"
echo " Total items scored: $TOTAL_ITEMS"
echo " Total findings: $TOTAL_FINDINGS"
echo "===================================================="
