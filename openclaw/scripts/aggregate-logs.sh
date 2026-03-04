#!/bin/bash
# aggregate-logs.sh -- Aggregates log entries from all 5 workspace log directories
# Tags entries with agent_id and writes to central ~/.openclaw/logs/aggregated.jsonl
# Crontab: */5 * * * * ~/.openclaw/scripts/aggregate-logs.sh >> /dev/null 2>&1

set -uo pipefail

CENTRAL_LOG_DIR="$HOME/.openclaw/logs"
CENTRAL_LOG="$CENTRAL_LOG_DIR/aggregated.jsonl"
STATE_DIR="$CENTRAL_LOG_DIR/.aggregate-state"

mkdir -p "$CENTRAL_LOG_DIR" "$STATE_DIR"

# Agent log source mappings (agent_id:log_file)
declare -a LOG_SOURCES=(
    "lead:$HOME/.openclaw/workspace-lead/logs/agent-activity.log"
    "voc-analyst:$HOME/.openclaw/workspace-voc/logs/scrape_log.jsonl"
    "geo-optimizer:$HOME/.openclaw/workspace-geo/data/quality-logs/score-history.jsonl"
    "reddit-spec:$HOME/.openclaw/workspace-reddit/logs/agent-activity.log"
    "reddit-spec-alerts:$HOME/.openclaw/workspace-reddit/data/monitoring/alerts.jsonl"
    "tiktok-director:$HOME/.openclaw/workspace-tiktok/data/performance-log.json"
)

TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S%z)

for source in "${LOG_SOURCES[@]}"; do
    AGENT_ID="${source%%:*}"
    LOG_FILE="${source#*:}"

    # Skip if log file does not exist
    if [ ! -f "$LOG_FILE" ]; then
        continue
    fi

    # State file tracks the byte offset we last read from
    STATE_FILE="$STATE_DIR/$(echo "$LOG_FILE" | tr '/' '_').offset"
    LAST_OFFSET=0
    if [ -f "$STATE_FILE" ]; then
        LAST_OFFSET=$(cat "$STATE_FILE")
    fi

    CURRENT_SIZE=$(wc -c < "$LOG_FILE" | tr -d ' ')

    # Skip if file hasn't grown
    if [ "$CURRENT_SIZE" -le "$LAST_OFFSET" ]; then
        # File may have been rotated (smaller than last offset) -- reset
        if [ "$CURRENT_SIZE" -lt "$LAST_OFFSET" ]; then
            LAST_OFFSET=0
        else
            continue
        fi
    fi

    # Read new bytes and tag each line with agent_id
    tail -c +"$((LAST_OFFSET+1))" "$LOG_FILE" | while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue

        # If the line is valid JSON, inject agent_id field
        if echo "$line" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
            echo "$line" | python3 -c "
import sys, json
obj = json.loads(sys.stdin.read().strip())
obj['agent_id'] = '$AGENT_ID'
if 'aggregated_at' not in obj:
    obj['aggregated_at'] = '$TIMESTAMP'
print(json.dumps(obj, ensure_ascii=False))
" >> "$CENTRAL_LOG"
        else
            # Non-JSON line: wrap it
            echo "{\"agent_id\":\"$AGENT_ID\",\"aggregated_at\":\"$TIMESTAMP\",\"raw\":$(python3 -c "import json; print(json.dumps('''$line'''[:500]))")}" >> "$CENTRAL_LOG" 2>/dev/null
        fi
    done

    # Update offset
    echo "$CURRENT_SIZE" > "$STATE_FILE"
done
