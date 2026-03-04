#!/bin/bash
# daily-cost-report.sh -- Daily API cost aggregation
# Reads cost_tracking metadata from workspace logs and generates per-agent breakdown.
# Crontab: 59 23 * * * ~/.openclaw/scripts/daily-cost-report.sh >> ~/.openclaw/logs/cost-reports.log 2>&1

set -uo pipefail

TODAY=$(date +%Y-%m-%d)
REPORT_DIR="$HOME/.openclaw/logs/cost-reports"
REPORT_FILE="$REPORT_DIR/cost-report-$TODAY.md"
mkdir -p "$REPORT_DIR"

echo "=== Daily Cost Report: $TODAY ===" | tee "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Workspace log locations to scan for cost_tracking entries
declare -A WORKSPACE_LOGS=(
    ["lead"]="$HOME/.openclaw/workspace-lead/logs"
    ["voc-analyst"]="$HOME/.openclaw/workspace-voc/logs"
    ["geo-optimizer"]="$HOME/.openclaw/workspace-geo/data/quality-logs"
    ["reddit-spec"]="$HOME/.openclaw/workspace-reddit/logs"
    ["tiktok-director"]="$HOME/.openclaw/workspace-tiktok/data"
)

# Use python3 to aggregate cost data from all log files
python3 << PYEOF | tee -a "$REPORT_FILE"
import json, os, glob
from collections import defaultdict
from datetime import datetime

today = "$TODAY"
agents = ["lead", "voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"]
workspace_base = os.path.expanduser("~/.openclaw")

# Cost accumulators
agent_costs = defaultdict(float)
type_costs = defaultdict(float)
total_tasks = 0
entries_found = 0

# Scan all workspace log directories for JSONL files containing cost_tracking
for agent in agents:
    ws_dir = os.path.join(workspace_base, f"workspace-{agent.split('-')[0] if '-' not in agent else agent.replace('-', '-', 0)}")

    # Map agent IDs to workspace directory names
    ws_map = {
        "lead": "workspace-lead",
        "voc-analyst": "workspace-voc",
        "geo-optimizer": "workspace-geo",
        "reddit-spec": "workspace-reddit",
        "tiktok-director": "workspace-tiktok",
    }
    ws_dir = os.path.join(workspace_base, ws_map[agent])

    # Find all jsonl/json log files in the workspace
    log_patterns = [
        os.path.join(ws_dir, "logs", "*.jsonl"),
        os.path.join(ws_dir, "logs", "*.log"),
        os.path.join(ws_dir, "data", "**", "*.jsonl"),
        os.path.join(ws_dir, "data", "*.json"),
    ]

    for pattern in log_patterns:
        for log_file in glob.glob(pattern, recursive=True):
            try:
                with open(log_file, "r") as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            entry = json.loads(line)
                        except json.JSONDecodeError:
                            continue

                        # Filter by today's date
                        ts = entry.get("timestamp", "")
                        if today not in ts:
                            continue

                        # Look for cost_tracking data
                        cost_data = entry.get("cost_tracking") or entry.get("metadata", {}).get("cost_tracking")
                        if not cost_data:
                            continue

                        entries_found += 1
                        total_tasks += 1
                        task_agent = cost_data.get("agent", agent)

                        # Sum model costs
                        for mc in cost_data.get("model_costs", []):
                            cost = mc.get("cost_rmb", 0)
                            agent_costs[task_agent] += cost
                            model = mc.get("model", "unknown")
                            if "image" in model or "banana" in model or "image-gen" in model:
                                type_costs["Image Gen"] += cost
                            elif "video" in model or "seedance" in model:
                                type_costs["Video Gen"] += cost
                            else:
                                type_costs["Model API"] += cost

                        # Sum skill costs (convert USD to RMB at ~7.2 rate)
                        for sc in cost_data.get("skill_costs", []):
                            cost_usd = sc.get("cost_usd", 0)
                            cost_rmb = cost_usd * 7.2
                            agent_costs[task_agent] += cost_rmb
                            skill = sc.get("skill", "unknown")
                            if skill in ("decodo", "apify", "firecrawl", "playwright-npx"):
                                type_costs["Scraping APIs"] += cost_rmb
                            else:
                                type_costs["Search APIs"] += cost_rmb

            except (IOError, OSError):
                continue

# Output report
total_rmb = sum(agent_costs.values())
total_usd = total_rmb / 7.2

print(f"Date: {today}")
print(f"Total Tasks: {total_tasks}")
print(f"Cost Entries Found: {entries_found}")
print(f"Total Cost: {total_rmb:.2f} RMB (\${total_usd:.2f} USD)")
print()

if agent_costs:
    print("By Agent:")
    for agent in agents:
        cost = agent_costs.get(agent, 0)
        print(f"  {agent:<20s} {cost:>8.2f} RMB")
    print()

    print("By Cost Type:")
    for ctype in ["Model API", "Image Gen", "Video Gen", "Search APIs", "Scraping APIs"]:
        cost = type_costs.get(ctype, 0)
        print(f"  {ctype:<20s} {cost:>8.2f} RMB")
else:
    print("No cost tracking entries found for today.")
    print("Agents may not have run any tasks, or cost_tracking metadata is not being logged.")

PYEOF

echo "" | tee -a "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE"
