#!/bin/bash
# validate-config.sh -- Validates openclaw.json syntax and required fields
# Usage: ./validate-config.sh [path-to-openclaw.json]

set -euo pipefail

CONFIG_FILE="${1:-$HOME/.openclaw/openclaw.json}"

echo "=== OpenClaw Config Validation ==="
echo "Config: $CONFIG_FILE"
echo ""

# Step 1: Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL: Config file not found at $CONFIG_FILE"
  exit 1
fi

# Step 2: JSON syntax validation
echo -n "1. JSON syntax... "
if python3 -c "import json; json.load(open('$CONFIG_FILE')); print('PASS')"; then
  :
else
  echo "FAIL: Invalid JSON syntax"
  exit 1
fi

# Step 3: Structural validation
echo ""
echo "2. Structural validation..."
python3 << PYEOF
import json, sys

with open("$CONFIG_FILE") as f:
    config = json.load(f)

errors = []

# Check agents
if "agents" not in config or "list" not in config["agents"]:
    errors.append("Missing agents.list")
else:
    agent_ids = [a["id"] for a in config["agents"]["list"]]
    required_agents = ["lead", "voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"]
    for req in required_agents:
        if req not in agent_ids:
            errors.append(f"Missing agent: {req}")

    # Check default agent
    defaults = [a for a in config["agents"]["list"] if a.get("default")]
    if len(defaults) != 1:
        errors.append(f"Expected 1 default agent, found {len(defaults)}")
    elif defaults[0]["id"] != "lead":
        errors.append(f"Default agent should be 'lead', found '{defaults[0]['id']}'")

    # Check defaultAgent field
    if config["agents"].get("defaultAgent") != "lead":
        errors.append("agents.defaultAgent should be 'lead'")

# Check channels
if "channels" not in config or "feishu" not in config["channels"]:
    errors.append("Missing channels.feishu")
elif not config["channels"]["feishu"].get("enabled"):
    errors.append("Feishu channel not enabled")

# Check bindings
if "bindings" not in config:
    errors.append("Missing bindings array")
else:
    bound_agents = [b["agentId"] for b in config["bindings"]]
    required_bindings = ["lead", "voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"]
    for req in required_bindings:
        if req not in bound_agents:
            errors.append(f"Missing binding for agent: {req}")

# Check tools.agentToAgent
if "tools" not in config or "agentToAgent" not in config["tools"]:
    errors.append("Missing tools.agentToAgent")
elif not config["tools"]["agentToAgent"].get("enabled"):
    errors.append("agentToAgent not enabled")

# Check cron
if "cron" not in config or "jobs" not in config["cron"]:
    errors.append("Missing cron.jobs")
else:
    cron_ids = [j["id"] for j in config["cron"]["jobs"]]
    required_crons = ["price-monitor", "weekly-trend-digest", "shadowban-check"]
    for req in required_crons:
        if req not in cron_ids:
            errors.append(f"Missing cron job: {req}")

if errors:
    print(f"VALIDATION FAILED: {len(errors)} errors")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)
else:
    print("VALIDATION PASS: All required fields present")
PYEOF
