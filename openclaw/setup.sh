#!/usr/bin/env bash
# =============================================================================
# setup.sh - Master Setup Script for OpenClaw Cross-Border E-Commerce AI
# =============================================================================
#
# This script validates the environment, installs skills, configures
# credentials, and verifies the platform is ready to run.
#
# Usage:
#   ./setup.sh              # Full setup
#   ./setup.sh --check      # Validation only (no installs or modifications)
#
# Prerequisites:
#   - macOS with Homebrew
#   - Git repository cloned at ~/e-commerce-claw/
#   - This script run from ~/.openclaw/

set -euo pipefail

OPENCLAW_DIR="$HOME/.openclaw"
CHECK_ONLY=false
ERRORS=()
WARNINGS=()

if [[ "${1:-}" == "--check" ]]; then
    CHECK_ONLY=true
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log_info()    { echo -e "\033[0;34m[INFO]\033[0m  $*"; }
log_ok()      { echo -e "\033[0;32m[ OK ]\033[0m  $*"; }
log_warn()    { echo -e "\033[0;33m[WARN]\033[0m  $*"; WARNINGS+=("$*"); }
log_err()     { echo -e "\033[0;31m[FAIL]\033[0m  $*"; ERRORS+=("$*"); }
log_section() { echo ""; echo "========================================"; echo " $*"; echo "========================================"; }

check_cmd() {
    local cmd="$1"
    local install_hint="${2:-}"
    if command -v "$cmd" &>/dev/null; then
        local version
        version=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
        log_ok "$cmd: $version"
        return 0
    else
        log_err "$cmd: not found${install_hint:+ -- $install_hint}"
        return 1
    fi
}

check_env_var() {
    local var_name="$1"
    local severity="${2:-REQUIRED}"
    local description="${3:-}"
    local val="${!var_name:-}"

    if [[ -z "$val" ]]; then
        if [[ "$severity" == "REQUIRED" ]]; then
            log_err "$var_name is not set${description:+ ($description)}"
        else
            log_warn "$var_name is not set${description:+ ($description)}"
        fi
        return 1
    else
        # Mask the value for display
        local masked="${val:0:4}***${val: -2}"
        log_ok "$var_name = $masked"
        return 0
    fi
}


# ===========================================================================
#  STEP 1: Check System Prerequisites
# ===========================================================================
log_section "Step 1: System Prerequisites"

# Check for Homebrew
check_cmd brew "Install: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

# Check core tools
check_cmd node "brew install node"
check_cmd python3 "brew install python3"
check_cmd git "brew install git"
check_cmd pip3 "Should come with python3"

# Check recommended tools
check_cmd jq "brew install jq" || true
check_cmd gh "brew install gh (optional, for GitHub operations)" || true

# Check Node.js version (need 18+)
if command -v node &>/dev/null; then
    node_major=$(node -v | sed 's/v//' | cut -d. -f1)
    if [[ "$node_major" -lt 18 ]]; then
        log_err "Node.js version too old (v$(node -v)). Need v18+."
    else
        log_ok "Node.js version: v$(node -v | sed 's/v//') (>= 18 required)"
    fi
fi

# Check Python version (need 3.11+)
if command -v python3 &>/dev/null; then
    py_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    py_minor=$(python3 -c "import sys; print(sys.version_info.minor)")
    if [[ "$py_minor" -lt 11 ]]; then
        log_warn "Python version $py_version detected. 3.11+ recommended."
    else
        log_ok "Python version: $py_version (>= 3.11 recommended)"
    fi
fi

# Check OpenClaw/ClawHub CLI
if command -v clawhub &>/dev/null; then
    log_ok "clawhub CLI available"
    CLI_CMD="clawhub"
elif command -v openclaw &>/dev/null; then
    log_ok "openclaw CLI available"
    CLI_CMD="openclaw"
else
    log_err "No OpenClaw CLI found. Install: npm install -g @openclaw/cli"
    CLI_CMD=""
fi


# ===========================================================================
#  STEP 2: Environment Variables Setup
# ===========================================================================
log_section "Step 2: Environment Variables"

ENV_FILE="$OPENCLAW_DIR/.env"
ENV_TEMPLATE="$OPENCLAW_DIR/.env.template"

# Copy template if .env doesn't exist
if [[ ! -f "$ENV_FILE" ]]; then
    if [[ -f "$ENV_TEMPLATE" ]]; then
        if $CHECK_ONLY; then
            log_warn ".env file does not exist. Run without --check to create from template."
        else
            cp "$ENV_TEMPLATE" "$ENV_FILE"
            chmod 600 "$ENV_FILE"
            log_ok "Created .env from template (permissions set to 600)"
            log_warn "Edit $ENV_FILE and fill in your API keys before proceeding."
        fi
    else
        log_err ".env.template not found at $ENV_TEMPLATE"
    fi
else
    log_ok ".env file exists"
    # Ensure restrictive permissions
    current_perms=$(stat -f "%Lp" "$ENV_FILE" 2>/dev/null || stat -c "%a" "$ENV_FILE" 2>/dev/null)
    if [[ "$current_perms" != "600" ]]; then
        if ! $CHECK_ONLY; then
            chmod 600 "$ENV_FILE"
            log_ok "Fixed .env permissions to 600"
        else
            log_warn ".env permissions are $current_perms (should be 600)"
        fi
    fi
fi

# Source .env if it exists
if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
    log_ok "Sourced $ENV_FILE"
fi

# Validate REQUIRED variables
log_info "Checking required environment variables..."
check_env_var DECODO_AUTH_TOKEN REQUIRED "Decodo web scraping API"
check_env_var BRAVE_API_KEY REQUIRED "Brave Search API"
check_env_var APIFY_TOKEN REQUIRED "Apify cloud scraping"

# Validate OPTIONAL variables
log_info "Checking optional environment variables..."
check_env_var TAVILY_API_KEY OPTIONAL "Tavily search (China-direct)"
check_env_var EXA_API_KEY OPTIONAL "Exa semantic search"
check_env_var FIRECRAWL_API_KEY OPTIONAL "Firecrawl remote browser"

# Validate PRODUCTION variables
log_info "Checking production environment variables..."
check_env_var FEISHU_LEAD_APP_ID OPTIONAL "Lead agent Feishu app"
check_env_var FEISHU_LEAD_APP_SECRET OPTIONAL "Lead agent Feishu secret"
check_env_var FEISHU_GEO_APP_ID OPTIONAL "GEO optimizer Feishu app"
check_env_var FEISHU_GEO_APP_SECRET OPTIONAL "GEO optimizer Feishu secret"
check_env_var FEISHU_REDDIT_APP_ID OPTIONAL "Reddit specialist Feishu app"
check_env_var FEISHU_REDDIT_APP_SECRET OPTIONAL "Reddit specialist Feishu secret"
check_env_var FEISHU_TIKTOK_APP_ID OPTIONAL "TikTok director Feishu app"
check_env_var FEISHU_TIKTOK_APP_SECRET OPTIONAL "TikTok director Feishu secret"

# Model provider keys
log_info "Checking model provider keys..."
check_env_var VOLCENGINE_MODEL_API_KEY OPTIONAL "Volcengine (doubao models)"
check_env_var MOONSHOT_API_KEY OPTIONAL "Moonshot AI (Kimi K2.5)"


# ===========================================================================
#  STEP 3: Install Skills
# ===========================================================================
log_section "Step 3: Skills Installation"

INSTALL_SCRIPT="$OPENCLAW_DIR/install-skills.sh"

if [[ -f "$INSTALL_SCRIPT" ]]; then
    if $CHECK_ONLY; then
        log_info "Skipping skills installation (--check mode)"
        log_info "  Run: bash $INSTALL_SCRIPT"
    else
        log_info "Running install-skills.sh..."
        chmod +x "$INSTALL_SCRIPT"
        if bash "$INSTALL_SCRIPT"; then
            log_ok "Skills installation completed"
        else
            log_warn "Skills installation had errors. Check output above."
        fi
    fi
else
    log_err "install-skills.sh not found at $INSTALL_SCRIPT"
fi


# ===========================================================================
#  STEP 4: Validate Workspace Structure
# ===========================================================================
log_section "Step 4: Workspace Validation"

AGENTS=("lead" "voc" "geo" "reddit" "tiktok")
AGENT_NAMES=("lead" "voc-analyst" "geo-optimizer" "reddit-spec" "tiktok-director")

for i in "${!AGENTS[@]}"; do
    agent="${AGENTS[$i]}"
    agent_name="${AGENT_NAMES[$i]}"
    ws_dir="$OPENCLAW_DIR/workspace-$agent"

    if [[ -d "$ws_dir" ]]; then
        log_ok "Workspace: workspace-$agent/"

        # Check SOUL.md
        if [[ -f "$ws_dir/SOUL.md" ]]; then
            soul_size=$(wc -c < "$ws_dir/SOUL.md" | tr -d ' ')
            if [[ "$soul_size" -gt 100 ]]; then
                log_ok "  SOUL.md exists (${soul_size} bytes)"
            else
                log_warn "  SOUL.md exists but seems too small (${soul_size} bytes)"
            fi
        else
            if [[ "$agent" != "lead" ]]; then
                log_err "  SOUL.md missing in workspace-$agent"
            else
                log_info "  SOUL.md not required for lead agent"
            fi
        fi

        # Check data directory
        if [[ -d "$ws_dir/data" ]]; then
            log_ok "  data/ directory exists"
        else
            log_warn "  data/ directory missing"
        fi
    else
        log_err "Workspace missing: workspace-$agent/"
    fi
done

# Check openclaw.json
if [[ -f "$OPENCLAW_DIR/openclaw.json" ]]; then
    if command -v jq &>/dev/null; then
        if jq . "$OPENCLAW_DIR/openclaw.json" >/dev/null 2>&1; then
            agent_count=$(jq '.agents.list | length' "$OPENCLAW_DIR/openclaw.json")
            log_ok "openclaw.json is valid JSON ($agent_count agents configured)"
        else
            log_err "openclaw.json is not valid JSON"
        fi
    else
        log_ok "openclaw.json exists (install jq for validation)"
    fi
else
    log_err "openclaw.json not found"
fi


# ===========================================================================
#  STEP 5: Update Feishu Credentials in openclaw.json
# ===========================================================================
log_section "Step 5: Feishu Credential Injection"

CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"

if [[ -f "$CONFIG_FILE" ]] && command -v jq &>/dev/null; then
    needs_update=false

    # Check if any Feishu credentials are available and need injection
    if [[ -n "${FEISHU_LEAD_APP_ID:-}" && "${FEISHU_LEAD_APP_ID:-}" != "cli_lead_placeholder" ]]; then
        needs_update=true
    fi
    if [[ -n "${FEISHU_GEO_APP_ID:-}" && "${FEISHU_GEO_APP_ID:-}" != "cli_geo_placeholder" ]]; then
        needs_update=true
    fi
    if [[ -n "${FEISHU_REDDIT_APP_ID:-}" && "${FEISHU_REDDIT_APP_ID:-}" != "cli_reddit_placeholder" ]]; then
        needs_update=true
    fi
    if [[ -n "${FEISHU_TIKTOK_APP_ID:-}" && "${FEISHU_TIKTOK_APP_ID:-}" != "cli_tiktok_placeholder" ]]; then
        needs_update=true
    fi

    if $needs_update && ! $CHECK_ONLY; then
        log_info "Injecting Feishu credentials into openclaw.json..."

        # Build jq update expression dynamically
        jq_expr="."
        if [[ -n "${FEISHU_LEAD_APP_ID:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.lead.appId = \"$FEISHU_LEAD_APP_ID\""
        fi
        if [[ -n "${FEISHU_LEAD_APP_SECRET:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.lead.appSecret = \"$FEISHU_LEAD_APP_SECRET\""
        fi
        if [[ -n "${FEISHU_GEO_APP_ID:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.geo.appId = \"$FEISHU_GEO_APP_ID\""
        fi
        if [[ -n "${FEISHU_GEO_APP_SECRET:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.geo.appSecret = \"$FEISHU_GEO_APP_SECRET\""
        fi
        if [[ -n "${FEISHU_REDDIT_APP_ID:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.reddit.appId = \"$FEISHU_REDDIT_APP_ID\""
        fi
        if [[ -n "${FEISHU_REDDIT_APP_SECRET:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.reddit.appSecret = \"$FEISHU_REDDIT_APP_SECRET\""
        fi
        if [[ -n "${FEISHU_TIKTOK_APP_ID:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.tiktok.appId = \"$FEISHU_TIKTOK_APP_ID\""
        fi
        if [[ -n "${FEISHU_TIKTOK_APP_SECRET:-}" ]]; then
            jq_expr="$jq_expr | .channels.feishu.accounts.tiktok.appSecret = \"$FEISHU_TIKTOK_APP_SECRET\""
        fi

        # Create backup before modifying
        cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

        # Apply changes
        jq "$jq_expr" "$CONFIG_FILE.bak" > "$CONFIG_FILE"
        log_ok "Feishu credentials injected (backup at openclaw.json.bak)"
    elif $CHECK_ONLY; then
        if $needs_update; then
            log_info "Feishu credentials available in env, would inject in non-check mode"
        else
            log_warn "Feishu credentials still have placeholder values"
        fi
    else
        log_warn "No real Feishu credentials found in environment. Using placeholders."
        log_info "  Set FEISHU_LEAD_APP_ID, FEISHU_LEAD_APP_SECRET, etc. in .env"
    fi
elif ! command -v jq &>/dev/null; then
    log_warn "jq not installed. Cannot inject Feishu credentials into openclaw.json."
    log_info "  Install: brew install jq"
fi


# ===========================================================================
#  STEP 6: TikTok Workspace Skills Check
# ===========================================================================
log_section "Step 6: TikTok Workspace Skills Verification"

TIKTOK_SKILLS=("manga-style-video" "manga-drama" "volcengine-video-understanding")
TIKTOK_SKILLS_DIR="$OPENCLAW_DIR/workspace-tiktok/skills"

for skill in "${TIKTOK_SKILLS[@]}"; do
    if [[ -d "$TIKTOK_SKILLS_DIR/$skill" ]]; then
        log_ok "TikTok skill: $skill"
    else
        log_warn "TikTok skill missing: $skill (run install-skills.sh)"
    fi
done


# ===========================================================================
#  FINAL: Summary Report
# ===========================================================================
log_section "Setup Summary"

echo ""
echo "Platform:    OpenClaw Cross-Border E-Commerce AI"
echo "Location:    $OPENCLAW_DIR"
echo "Config:      $OPENCLAW_DIR/openclaw.json"
echo "Environment: $OPENCLAW_DIR/.env"
echo ""

# Count workspaces
ws_count=$(find "$OPENCLAW_DIR" -maxdepth 1 -type d -name "workspace-*" | wc -l | tr -d ' ')
echo "Workspaces:  $ws_count / 5"

# Count SOUL.md files
soul_count=$(find "$OPENCLAW_DIR"/workspace-*/SOUL.md -maxdepth 0 2>/dev/null | wc -l | tr -d ' ')
echo "SOUL.md:     $soul_count / 4 (lead excluded)"

# Count skills
global_skills=$(find "$OPENCLAW_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
tiktok_skills=$(find "$OPENCLAW_DIR/workspace-tiktok/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
echo "Skills:      $global_skills global + $tiktok_skills tiktok-specific"

echo ""
echo "Warnings:    ${#WARNINGS[@]}"
for w in "${WARNINGS[@]:-}"; do
    [[ -n "$w" ]] && echo "  ! $w"
done

echo ""
echo "Errors:      ${#ERRORS[@]}"
for e in "${ERRORS[@]:-}"; do
    [[ -n "$e" ]] && echo "  X $e"
done

echo ""
if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo -e "\033[0;31mSetup completed with ${#ERRORS[@]} error(s). Fix the issues above before running the platform.\033[0m"
    exit 1
else
    echo -e "\033[0;32mSetup completed successfully. The platform is ready.\033[0m"
    echo ""
    echo "Next steps:"
    echo "  1. Fill in API keys in $OPENCLAW_DIR/.env"
    echo "  2. Run: source $OPENCLAW_DIR/.env"
    echo "  3. Start the platform: openclaw start"
fi
