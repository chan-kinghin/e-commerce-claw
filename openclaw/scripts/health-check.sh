#!/bin/bash
# health-check.sh -- Agent health check for cron (runs every 2 minutes)
# Pings each of 5 agents, outputs JSONL status, sends Feishu webhook alert on failure.
# Crontab: */2 * * * * ~/.openclaw/scripts/health-check.sh >> ~/.openclaw/logs/health-check.log 2>&1

set -uo pipefail

TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S%z)
AGENTS="lead voc-analyst geo-optimizer reddit-spec tiktok-director"
FAILURES=0

for agent in $AGENTS; do
    STATUS=$(openclaw agent ping "$agent" --timeout 5 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"alive\"}"
    else
        echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"dead\"}"
        FAILURES=$((FAILURES+1))

        # Send Feishu webhook alert if URL is configured
        if [ -n "${FEISHU_WEBHOOK_URL:-}" ]; then
            curl -s -X POST "$FEISHU_WEBHOOK_URL" \
                -H "Content-Type: application/json" \
                -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"ALERT: Agent $agent is DOWN at $TIMESTAMP\"}}" \
                >/dev/null 2>&1
        fi
    fi
done

# Summary line
echo "{\"timestamp\":\"$TIMESTAMP\",\"type\":\"health_summary\",\"total\":5,\"alive\":$((5-FAILURES)),\"dead\":$FAILURES}"
