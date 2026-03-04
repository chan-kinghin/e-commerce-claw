#!/bin/bash
# collect-test-results.sh -- Collects test results into a dated directory
# Copies agent logs, GEO scores, TikTok performance, VOC scrape logs.
# Generates SUMMARY.md with an overview of results.
# Usage: ./collect-test-results.sh [optional-label]

set -uo pipefail

LABEL="${1:-}"
DATESTAMP=$(date +%Y%m%d-%H%M%S)
if [ -n "$LABEL" ]; then
    RESULTS_DIR="$HOME/.openclaw/test-results/${DATESTAMP}-${LABEL}"
else
    RESULTS_DIR="$HOME/.openclaw/test-results/${DATESTAMP}"
fi

echo "=== Collecting Test Results ==="
echo "Output directory: $RESULTS_DIR"
echo ""

mkdir -p "$RESULTS_DIR"

# Copy agent logs from each workspace
WORKSPACES=("workspace-lead" "workspace-voc" "workspace-geo" "workspace-reddit" "workspace-tiktok")
for ws in "${WORKSPACES[@]}"; do
    WS_DIR="$HOME/.openclaw/$ws"
    DEST="$RESULTS_DIR/$ws"
    mkdir -p "$DEST"

    # Copy logs directory
    if [ -d "$WS_DIR/logs" ]; then
        cp -r "$WS_DIR/logs/"* "$DEST/" 2>/dev/null && echo "  Copied logs from $ws" || true
    fi
done

# Copy GEO quality score history
if [ -f "$HOME/.openclaw/workspace-geo/data/quality-logs/score-history.jsonl" ]; then
    cp "$HOME/.openclaw/workspace-geo/data/quality-logs/score-history.jsonl" "$RESULTS_DIR/geo-scores.jsonl"
    echo "  Copied GEO score history"
fi

# Copy TikTok performance log
if [ -f "$HOME/.openclaw/workspace-tiktok/data/performance-log.json" ]; then
    cp "$HOME/.openclaw/workspace-tiktok/data/performance-log.json" "$RESULTS_DIR/tiktok-performance.json"
    echo "  Copied TikTok performance log"
fi

# Copy VOC scrape log
for scrape_log in "$HOME/.openclaw/workspace-voc/logs/scrape_log.jsonl" \
                  "$HOME/.openclaw/workspace-voc/data/logs/scrape_log.jsonl"; do
    if [ -f "$scrape_log" ]; then
        cp "$scrape_log" "$RESULTS_DIR/voc-scrape-log.jsonl"
        echo "  Copied VOC scrape log"
        break
    fi
done

# Copy Reddit monitoring data
if [ -d "$HOME/.openclaw/workspace-reddit/data/monitoring" ]; then
    mkdir -p "$RESULTS_DIR/reddit-monitoring"
    cp "$HOME/.openclaw/workspace-reddit/data/monitoring/"*.jsonl "$RESULTS_DIR/reddit-monitoring/" 2>/dev/null && echo "  Copied Reddit monitoring data" || true
fi

# Copy aggregated central log if it exists
if [ -f "$HOME/.openclaw/logs/aggregated.jsonl" ]; then
    cp "$HOME/.openclaw/logs/aggregated.jsonl" "$RESULTS_DIR/aggregated.jsonl"
    echo "  Copied aggregated log"
fi

# Generate SUMMARY.md
echo ""
echo "Generating SUMMARY.md..."

cat > "$RESULTS_DIR/SUMMARY.md" << EOF
# Test Results Summary

**Date**: $(date '+%Y-%m-%d %H:%M:%S %Z')
**Label**: ${LABEL:-none}
**Results Directory**: $RESULTS_DIR

## Files Collected

EOF

# List collected files with sizes
find "$RESULTS_DIR" -type f -not -name "SUMMARY.md" | sort | while read -r f; do
    SIZE=$(wc -c < "$f" | tr -d ' ')
    REL_PATH="${f#$RESULTS_DIR/}"
    echo "- \`$REL_PATH\` (${SIZE} bytes)" >> "$RESULTS_DIR/SUMMARY.md"
done

# Count log entries per agent
cat >> "$RESULTS_DIR/SUMMARY.md" << 'EOF'

## Log Entry Counts

EOF

for ws in "${WORKSPACES[@]}"; do
    AGENT_ID="${ws#workspace-}"
    TOTAL_LINES=0
    ERROR_LINES=0
    for logfile in "$RESULTS_DIR/$ws/"*; do
        if [ -f "$logfile" ]; then
            LINES=$(wc -l < "$logfile" | tr -d ' ')
            TOTAL_LINES=$((TOTAL_LINES + LINES))
            ERRS=$(grep -ci '"error"\|"level":"error"' "$logfile" 2>/dev/null || echo "0")
            ERROR_LINES=$((ERROR_LINES + ERRS))
        fi
    done
    echo "| $AGENT_ID | $TOTAL_LINES entries | $ERROR_LINES errors |" >> "$RESULTS_DIR/SUMMARY.md"
done

# GEO score summary
if [ -f "$RESULTS_DIR/geo-scores.jsonl" ]; then
    cat >> "$RESULTS_DIR/SUMMARY.md" << 'EOF'

## GEO Score Summary

EOF
    python3 -c "
import json, sys
scores = []
with open('$RESULTS_DIR/geo-scores.jsonl') as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try:
            entry = json.loads(line)
            score = entry.get('geo_score') or entry.get('score')
            if score is not None:
                scores.append(float(score))
        except (json.JSONDecodeError, ValueError):
            pass
if scores:
    print(f'- Total scored outputs: {len(scores)}')
    print(f'- Average score: {sum(scores)/len(scores):.1f}')
    print(f'- Min: {min(scores):.1f}, Max: {max(scores):.1f}')
    passing = sum(1 for s in scores if s >= 80)
    print(f'- Passing (>= 80): {passing}/{len(scores)}')
else:
    print('No GEO scores found in log.')
" >> "$RESULTS_DIR/SUMMARY.md" 2>/dev/null
fi

# TikTok QA summary
if [ -f "$RESULTS_DIR/tiktok-performance.json" ]; then
    cat >> "$RESULTS_DIR/SUMMARY.md" << 'EOF'

## TikTok QA Summary

EOF
    python3 -c "
import json
with open('$RESULTS_DIR/tiktok-performance.json') as f:
    data = json.load(f)
entries = data if isinstance(data, list) else data.get('entries', data.get('videos', []))
if isinstance(entries, list):
    scores = []
    for e in entries:
        qa = e.get('qa_composite') or e.get('qa_score')
        if qa is not None:
            scores.append(float(qa))
    if scores:
        print(f'- Total videos: {len(scores)}')
        print(f'- Average QA composite: {sum(scores)/len(scores):.1f}')
        print(f'- Min: {min(scores):.1f}, Max: {max(scores):.1f}')
        passing = sum(1 for s in scores if s >= 7.0)
        print(f'- Passing (>= 7.0): {passing}/{len(scores)}')
    else:
        print('No QA scores found.')
else:
    print('Unexpected format in performance log.')
" >> "$RESULTS_DIR/SUMMARY.md" 2>/dev/null
fi

echo ""
echo "=== Collection Complete ==="
echo "Results: $RESULTS_DIR"
echo "Summary: $RESULTS_DIR/SUMMARY.md"
