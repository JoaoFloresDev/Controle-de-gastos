#!/bin/bash
# cron_pull_search_terms.sh — daily backstop that pulls ASC search terms once
# the ONE_TIME_SNAPSHOT finishes processing, then removes its own crontab entry.
#
# Installed crontab line (tagged for self-removal):
#   53 21 * * * /…/aso-pipeline/scripts/cron_pull_search_terms.sh # meus_gastos_search_terms
#
# Runs independently of Claude. Logs to reports/_cron_pull.log.

set -uo pipefail
DIR="/Users/joaoflores/Documents/GambitStudio/Apps/recovery/flutter/Controle-de-gastos/aso-pipeline"
export APP_STORE_CONNECT_KEY_PATH="$HOME/Documents/GambitStudio/_GambitStudio/keys/asc_api_key.p8"
LOG="$DIR/reports/_cron_pull.log"

cd "$DIR" || exit 1
echo "=== run $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG"
OUT="$(/usr/bin/python3 scripts/pull_analytics.py 2>&1)"
echo "$OUT" >> "$LOG"

# Success = a search_terms CSV was produced this run.
if echo "$OUT" | grep -q "Top search terms"; then
    echo "[cron] search terms obtained — removing crontab entry" >> "$LOG"
    crontab -l 2>/dev/null | grep -v 'meus_gastos_search_terms' | crontab - 2>>"$LOG"
else
    echo "[cron] still PENDING — will retry tomorrow 21:53" >> "$LOG"
fi
