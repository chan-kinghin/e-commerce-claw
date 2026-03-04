#!/bin/bash
# pre-flight-check.sh -- Pre-flight checks before openclaw gateway restart
# Validates config, workspace directories, SOUL.md files, skills, env vars, and cron prompts.
# Usage: ./pre-flight-check.sh

set -uo pipefail

echo "=== OpenClaw Pre-Flight Checks ==="
ERRORS=0
WARNINGS=0

# 1. openclaw.json exists and is valid JSON
echo -n "1. Config file syntax... "
if python3 -c "import json; json.load(open('$HOME/.openclaw/openclaw.json'))" 2>/dev/null; then
    echo "PASS"
else
    echo "FAIL: Invalid JSON or file not found"
    ERRORS=$((ERRORS+1))
fi

# 2. All workspace directories exist
echo -n "2. Workspace directories... "
WS_PASS=true
WORKSPACES="workspace-lead workspace-voc workspace-geo workspace-reddit workspace-tiktok"
for ws in $WORKSPACES; do
    if [ ! -d "$HOME/.openclaw/$ws" ]; then
        echo ""
        echo "   FAIL: Missing $ws"
        ERRORS=$((ERRORS+1))
        WS_PASS=false
    fi
done
if $WS_PASS; then
    echo "PASS"
fi

# 3. SOUL.md exists in each workspace
echo -n "3. SOUL.md files... "
SOUL_PASS=true
for ws in $WORKSPACES; do
    if [ ! -f "$HOME/.openclaw/$ws/SOUL.md" ]; then
        echo ""
        echo "   FAIL: Missing SOUL.md in $ws"
        ERRORS=$((ERRORS+1))
        SOUL_PASS=false
    fi
done
if $SOUL_PASS; then
    echo "PASS"
fi

# 4. AGENTS.md exists in lead workspace
echo -n "4. AGENTS.md in lead... "
if [ -f "$HOME/.openclaw/workspace-lead/AGENTS.md" ]; then
    echo "PASS"
else
    echo "FAIL: Missing AGENTS.md"
    ERRORS=$((ERRORS+1))
fi

# 5. Global skills directory exists
echo -n "5. Global skills directory... "
if [ -d "$HOME/.openclaw/skills" ]; then
    SKILL_COUNT=$(ls "$HOME/.openclaw/skills" 2>/dev/null | wc -l | tr -d ' ')
    echo "PASS ($SKILL_COUNT skills installed)"
else
    echo "FAIL: Missing skills directory"
    ERRORS=$((ERRORS+1))
fi

# 6. Required environment variables
echo -n "6. Environment variables... "
REQUIRED_VARS="VOLCENGINE_API_KEY MOONSHOT_API_KEY DECODO_AUTH_TOKEN BRAVE_API_KEY"
ENV_PASS=true
for var in $REQUIRED_VARS; do
    if [ -z "${!var:-}" ]; then
        echo ""
        echo "   WARN: $var not set"
        WARNINGS=$((WARNINGS+1))
        ENV_PASS=false
    fi
done
if $ENV_PASS; then
    echo "PASS"
else
    echo "   CHECKED (with warnings)"
fi

# 7. Cron prompt files exist
echo -n "7. Cron prompt files... "
CRON_PASS=true
CRON_FILES=(
    "$HOME/.openclaw/workspace-voc/templates/prompt_templates/price_monitor.md"
    "$HOME/.openclaw/workspace-voc/templates/prompt_templates/weekly_digest.md"
    "$HOME/.openclaw/workspace-voc/templates/prompt_templates/weekly_market_scan.md"
    "$HOME/.openclaw/workspace-reddit/data/monitoring/shadowban-check-prompt.md"
    "$HOME/.openclaw/workspace-reddit/data/nurturing/sop-compliance-prompt.md"
)
for f in "${CRON_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo ""
        echo "   WARN: Missing cron prompt: $(basename "$f")"
        WARNINGS=$((WARNINGS+1))
        CRON_PASS=false
    fi
done
if $CRON_PASS; then
    echo "PASS"
else
    echo "   CHECKED (with warnings)"
fi

# Summary
echo ""
echo "---"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "=== ALL CHECKS PASSED ==="
    echo "Run: openclaw gateway restart"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "=== PASSED with $WARNINGS warnings ==="
    echo "Warnings are non-blocking. You may proceed with: openclaw gateway restart"
    exit 0
else
    echo "=== $ERRORS ERRORS, $WARNINGS WARNINGS ==="
    echo "Fix errors before starting the gateway."
    exit 1
fi
