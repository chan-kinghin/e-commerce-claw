# Test T-001: Agent-to-Agent Communication via sessions_send

> **Purpose**: Validate that all 5 agents can communicate via `sessions_send` and that the routing whitelist in `openclaw.json` is correctly enforced.
> **Agents involved**: lead, voc-analyst, geo-optimizer, reddit-spec, tiktok-director
> **Estimated time**: 2-3 minutes
> **Prerequisites**: All 5 agent workspaces scaffolded, openclaw.json configured

---

## Test Description

The Lead agent sends a simple ping message to each of the 4 executor agents via `sessions_send`. Each agent receives the ping, processes it, and responds with a structured pong message containing its agent ID and operational status. This validates:

1. The `sessions_send` protocol is functional
2. The routing whitelist (`tools.agentToAgent.routing`) correctly allows Lead to reach all executors
3. Each executor can reply back to Lead
4. All agents are alive and responsive

---

## Test Execution Prompt

Feed this prompt to the **Lead agent** (`~/.openclaw/workspace-lead`):

```
You are executing a connectivity test for the multi-agent platform. Your task is to send a ping message to each of the 4 executor agents via sessions_send and collect their responses.

For each agent, send the following payload via sessions_send:

### Step 1: Ping voc-analyst

sessions_send to agent "voc-analyst":
{
  "task_type": "ping",
  "request_id": "test-ping-voc-001",
  "message": "Connectivity test. Please respond with your agent_id and status.",
  "expected_response_format": {
    "agent_id": "your-agent-id",
    "status": "ok",
    "request_id": "test-ping-voc-001",
    "workspace": "your-workspace-path",
    "model": "your-model-name",
    "timestamp": "ISO8601"
  }
}

### Step 2: Ping geo-optimizer

sessions_send to agent "geo-optimizer":
{
  "task_type": "ping",
  "request_id": "test-ping-geo-001",
  "message": "Connectivity test. Please respond with your agent_id and status.",
  "expected_response_format": {
    "agent_id": "your-agent-id",
    "status": "ok",
    "request_id": "test-ping-geo-001",
    "workspace": "your-workspace-path",
    "model": "your-model-name",
    "timestamp": "ISO8601"
  }
}

### Step 3: Ping reddit-spec

sessions_send to agent "reddit-spec":
{
  "task_type": "ping",
  "request_id": "test-ping-reddit-001",
  "message": "Connectivity test. Please respond with your agent_id and status.",
  "expected_response_format": {
    "agent_id": "your-agent-id",
    "status": "ok",
    "request_id": "test-ping-reddit-001",
    "workspace": "your-workspace-path",
    "model": "your-model-name",
    "timestamp": "ISO8601"
  }
}

### Step 4: Ping tiktok-director

sessions_send to agent "tiktok-director":
{
  "task_type": "ping",
  "request_id": "test-ping-tiktok-001",
  "message": "Connectivity test. Please respond with your agent_id and status.",
  "expected_response_format": {
    "agent_id": "your-agent-id",
    "status": "ok",
    "request_id": "test-ping-tiktok-001",
    "workspace": "your-workspace-path",
    "model": "your-model-name",
    "timestamp": "ISO8601"
  }
}

### Step 5: Collect and summarize results

After sending all 4 pings, wait for responses (timeout: 60 seconds per agent).

Compile a summary report in this format:

{
  "test_id": "T-001",
  "test_name": "sessions_send connectivity",
  "executed_at": "ISO8601 timestamp",
  "results": [
    {
      "agent_id": "voc-analyst",
      "ping_sent": true,
      "pong_received": true/false,
      "response_time_ms": NNN,
      "status": "ok/error/timeout",
      "error_message": null or "description"
    },
    ... (repeat for all 4 agents)
  ],
  "summary": {
    "total_agents": 4,
    "successful": N,
    "failed": N,
    "overall_status": "PASS/FAIL"
  }
}

The test PASSES if and only if all 4 agents respond with status "ok" within 60 seconds.
```

---

## Expected Ping Payload (exact format)

```json
{
  "task_type": "ping",
  "request_id": "test-ping-{agent-slug}-001",
  "message": "Connectivity test. Please respond with your agent_id and status.",
  "expected_response_format": {
    "agent_id": "your-agent-id",
    "status": "ok",
    "request_id": "test-ping-{agent-slug}-001",
    "workspace": "your-workspace-path",
    "model": "your-model-name",
    "timestamp": "ISO8601"
  }
}
```

## Expected Pong Response (from each executor agent)

Each executor agent's SOUL.md should instruct it to handle `task_type: "ping"` by responding:

```json
{
  "agent_id": "voc-analyst",
  "status": "ok",
  "request_id": "test-ping-voc-001",
  "workspace": "~/.openclaw/workspace-voc",
  "model": "moonshot/kimi-k2.5",
  "timestamp": "2026-03-05T10:00:00+08:00",
  "skills_loaded": ["decodo", "reddit-readonly", "brave-search"],
  "workspace_health": {
    "soul_md_exists": true,
    "data_dir_exists": true,
    "templates_dir_exists": true
  }
}
```

---

## Routing Whitelist Validation

According to `openclaw.json`, the routing rules are:

```json
{
  "routing": {
    "lead": ["voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"],
    "voc-analyst": ["lead"],
    "geo-optimizer": ["lead"],
    "reddit-spec": ["lead"],
    "tiktok-director": ["lead"]
  }
}
```

### Positive Tests (should succeed)

| From | To | Expected |
|------|----|----------|
| lead | voc-analyst | Delivered |
| lead | geo-optimizer | Delivered |
| lead | reddit-spec | Delivered |
| lead | tiktok-director | Delivered |
| voc-analyst | lead | Delivered (response path) |
| geo-optimizer | lead | Delivered (response path) |
| reddit-spec | lead | Delivered (response path) |
| tiktok-director | lead | Delivered (response path) |

### Negative Tests (should be denied)

To validate routing restrictions, the Lead agent should also attempt these invalid routes and confirm they are blocked:

| From | To | Expected |
|------|----|----------|
| voc-analyst | geo-optimizer | DENIED - not in routing whitelist |
| reddit-spec | tiktok-director | DENIED - not in routing whitelist |
| geo-optimizer | reddit-spec | DENIED - not in routing whitelist |
| tiktok-director | voc-analyst | DENIED - not in routing whitelist |

### Negative Test Prompt (append to Lead agent prompt):

```
After the positive ping tests complete, attempt the following cross-agent sends to verify routing restrictions:

Step 6: Instruct voc-analyst to send a ping to geo-optimizer
- Send to voc-analyst: { "task_type": "test_cross_send", "target": "geo-optimizer", "message": "attempt cross-agent ping" }
- voc-analyst should attempt sessions_send to geo-optimizer
- Expected: sessions_send FAILS with a routing denied error

Step 7: Instruct reddit-spec to send a ping to tiktok-director
- Send to reddit-spec: { "task_type": "test_cross_send", "target": "tiktok-director", "message": "attempt cross-agent ping" }
- Expected: sessions_send FAILS with a routing denied error

Log the error messages from the failed cross-sends to verify the whitelist is enforced.
```

---

## Pass/Fail Criteria

### PASS conditions (ALL must be true):

- [ ] Lead successfully sends ping to voc-analyst and receives pong within 60s
- [ ] Lead successfully sends ping to geo-optimizer and receives pong within 60s
- [ ] Lead successfully sends ping to reddit-spec and receives pong within 60s
- [ ] Lead successfully sends ping to tiktok-director and receives pong within 60s
- [ ] Each pong contains correct `agent_id` matching the expected agent
- [ ] Each pong contains `status: "ok"`
- [ ] Each pong contains the correct `request_id` echoed back
- [ ] Cross-agent sends (voc->geo, reddit->tiktok) are denied by the routing whitelist

### FAIL conditions (ANY triggers FAIL):

- [ ] Any agent does not respond within 60 seconds (timeout)
- [ ] Any agent responds with `status` other than "ok"
- [ ] Any agent returns an incorrect `agent_id` (routing mismatch)
- [ ] Cross-agent sends succeed when they should be denied
- [ ] sessions_send call itself throws an error (protocol failure)

---

## Failure Diagnosis

| Failure Mode | Diagnosis Steps |
|-------------|----------------|
| Agent does not respond (timeout) | 1. Check if agent workspace exists: `ls ~/.openclaw/workspace-{agent}/` 2. Check if agent is in openclaw.json agents list 3. Check SOUL.md exists and has ping handler instructions 4. Check OpenClaw runtime logs for agent startup errors |
| Agent responds with wrong agent_id | 1. Check SOUL.md has correct agent ID configured 2. Check openclaw.json `agents.list[].id` matches 3. Possible routing misconfiguration - message delivered to wrong agent |
| Cross-agent send succeeds (should fail) | 1. Check `tools.agentToAgent.routing` in openclaw.json 2. The whitelist is not being enforced - possible OpenClaw version issue 3. Verify the `allow` array does not have wildcards |
| sessions_send protocol error | 1. Check `tools.agentToAgent.enabled` is `true` 2. Check `tools.agentToAgent.protocol` is `"sessions_send"` 3. Check OpenClaw runtime version supports sessions_send |
