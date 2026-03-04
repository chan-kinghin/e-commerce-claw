#!/usr/bin/env bash
# =============================================================================
# install-skills.sh - OpenClaw Skills Installer for Cross-Border E-Commerce AI
# =============================================================================
#
# Installs all OpenClaw Skills needed by the 5-agent platform.
# Skills are organized by scope: global (shared) vs workspace-specific.
#
# Usage: ./install-skills.sh [--dry-run]
#
# Prerequisites:
#   - openclaw or clawhub CLI installed and on PATH
#   - node >= 18, python3 >= 3.11
#   - Network access to GitHub, ClawHub, and npm registries

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
OPENCLAW_DIR="$HOME/.openclaw"
GLOBAL_SKILLS_DIR="$OPENCLAW_DIR/skills"
TIKTOK_WORKSPACE="workspace-tiktok"
DRY_RUN=false
FAILED_INSTALLS=()
SKIPPED_INSTALLS=()
SUCCESSFUL_INSTALLS=()

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[DRY RUN] No skills will actually be installed."
    echo ""
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log_info()    { echo -e "\033[0;34m[INFO]\033[0m  $*"; }
log_ok()      { echo -e "\033[0;32m[OK]\033[0m    $*"; }
log_warn()    { echo -e "\033[0;33m[WARN]\033[0m  $*"; }
log_err()     { echo -e "\033[0;31m[FAIL]\033[0m  $*"; }
log_section() { echo ""; echo "========================================"; echo " $*"; echo "========================================"; }

# Check if a command exists
require_cmd() {
    if ! command -v "$1" &>/dev/null; then
        log_err "Required command not found: $1"
        echo "  Install it before running this script."
        exit 1
    fi
}

# Install a global skill (to ~/.openclaw/skills/)
install_global_skill() {
    local skill_name="$1"
    local install_cmd="$2"
    local description="$3"

    log_info "Installing global skill: $skill_name ($description)"

    # Check if already installed
    if [[ -d "$GLOBAL_SKILLS_DIR/$skill_name" ]]; then
        log_warn "  Already installed at $GLOBAL_SKILLS_DIR/$skill_name -- skipping"
        SKIPPED_INSTALLS+=("$skill_name (global, already exists)")
        return 0
    fi

    if $DRY_RUN; then
        log_info "  [DRY RUN] Would run: $install_cmd"
        return 0
    fi

    if eval "$install_cmd" 2>&1; then
        log_ok "  Installed: $skill_name"
        SUCCESSFUL_INSTALLS+=("$skill_name (global)")
    else
        log_err "  Failed to install: $skill_name"
        FAILED_INSTALLS+=("$skill_name (global): $install_cmd")
    fi
}

# Install a workspace-specific skill
install_workspace_skill() {
    local skill_name="$1"
    local workspace="$2"
    local install_cmd="$3"
    local description="$4"
    local workspace_skills_dir="$OPENCLAW_DIR/$workspace/skills"

    log_info "Installing workspace skill: $skill_name -> $workspace ($description)"

    # Check if already installed
    if [[ -d "$workspace_skills_dir/$skill_name" ]]; then
        log_warn "  Already installed at $workspace_skills_dir/$skill_name -- skipping"
        SKIPPED_INSTALLS+=("$skill_name ($workspace, already exists)")
        return 0
    fi

    if $DRY_RUN; then
        log_info "  [DRY RUN] Would run: $install_cmd"
        return 0
    fi

    if eval "$install_cmd" 2>&1; then
        log_ok "  Installed: $skill_name -> $workspace"
        SUCCESSFUL_INSTALLS+=("$skill_name ($workspace)")
    else
        log_err "  Failed to install: $skill_name -> $workspace"
        FAILED_INSTALLS+=("$skill_name ($workspace): $install_cmd")
    fi
}

# ---------------------------------------------------------------------------
# Pre-flight Checks
# ---------------------------------------------------------------------------
log_section "Pre-flight Checks"

# Check for clawhub/openclaw CLI
if command -v clawhub &>/dev/null; then
    CLI_CMD="clawhub"
    log_ok "Found CLI: clawhub ($(clawhub --version 2>/dev/null || echo 'version unknown'))"
elif command -v openclaw &>/dev/null; then
    CLI_CMD="openclaw"
    log_ok "Found CLI: openclaw ($(openclaw --version 2>/dev/null || echo 'version unknown'))"
else
    log_err "Neither 'clawhub' nor 'openclaw' CLI found on PATH."
    echo "  Install one of them first:"
    echo "    npm install -g @openclaw/cli"
    echo "    # or"
    echo "    brew install openclaw"
    exit 1
fi

require_cmd node
require_cmd python3
require_cmd git
require_cmd pip3

log_ok "All required commands available."

# Ensure directories exist
mkdir -p "$GLOBAL_SKILLS_DIR"
log_ok "Global skills directory: $GLOBAL_SKILLS_DIR"

# ===========================================================================
#  SECTION 1: Global Skills (shared by multiple agents)
# ===========================================================================
log_section "Global Skills (shared across agents)"

# --- Decodo Skill (P0) ---
# Used by: voc-analyst, geo-optimizer, reddit-spec
# Provides: amazon_search, amazon, reddit_post, reddit_subreddit, youtube_subtitles
install_global_skill \
    "decodo" \
    "$CLI_CMD install decodo --global" \
    "Web scraping API: Amazon, Reddit, YouTube subtitles"
# Alternative: git clone https://github.com/Decodo/decodo-openclaw-skill "$GLOBAL_SKILLS_DIR/decodo"

# --- reddit-readonly (P0) ---
# Used by: voc-analyst, reddit-spec
# Provides: Free Reddit browsing (old.reddit.com JSON endpoints)
install_global_skill \
    "reddit-readonly" \
    "$CLI_CMD install reddit-readonly --global" \
    "Free Reddit browsing via old.reddit.com JSON"
# Alternative (ClawHub): clawhub install buksan1950/reddit-readonly --global
# Alternative (LobeHub): curl https://lobehub.com/skills/openclaw-skills-reddit-scraper/skill.md

# --- Brave Search (P0) ---
# Used by: voc-analyst, geo-optimizer, reddit-spec
# Requires: BRAVE_API_KEY
install_global_skill \
    "brave-search" \
    "$CLI_CMD install brave-search --global" \
    "High-quality overseas web search"
# Alternative: clawhub install steipete/brave-search --global

# --- Tavily Search (P2) ---
# Used by: voc-analyst, geo-optimizer, reddit-spec
# Requires: TAVILY_API_KEY
install_global_skill \
    "tavily" \
    "$CLI_CMD install tavily --global" \
    "China-domestic search, no VPN needed"
# Alternative: openclaw skills install @anthropic/tavily

# --- Exa Search (P2) ---
# Used by: voc-analyst, geo-optimizer, reddit-spec
# Requires: EXA_API_KEY
install_global_skill \
    "exa" \
    "$CLI_CMD install exa --global" \
    "Intent-based semantic search"
# Alternative: openclaw skills install @anthropic/exa

# --- Firecrawl (P3) ---
# Used by: voc-analyst, geo-optimizer
# Requires: FIRECRAWL_API_KEY (500 free/month)
install_global_skill \
    "firecrawl" \
    "$CLI_CMD install firecrawl --global" \
    "Remote sandbox web scraping, 500 free/month"
# Alternative: openclaw skills install @anthropic/firecrawl

# --- Playwright-npx (P2) ---
# Used by: voc-analyst, geo-optimizer, reddit-spec
# No API key required
install_global_skill \
    "playwright-npx" \
    "$CLI_CMD install playwright-npx --global" \
    "Dynamic SPA page scraping via headless browser"
# Alternative: Install from https://playbooks.com/skills/openclaw/skills/playwright-npx

# --- stealth-browser (P3) ---
# Used by: voc-analyst
# No API key required
install_global_skill \
    "stealth-browser" \
    "$CLI_CMD install stealth-browser --global" \
    "Cloudflare bypass for protected sites"

# --- Agent-Reach (P1) ---
# Used by: voc-analyst, reddit-spec
# Provides: yt-dlp (YouTube/TikTok), xreach (Twitter), Jina Reader
install_global_skill \
    "agent-reach" \
    "$CLI_CMD install agent-reach --global" \
    "yt-dlp, xreach, Jina Reader multi-tool"
# Alternative: Follow https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md

# --- nano-banana-pro (P0 for TikTok) ---
# Used by: tiktok-director
# High-fidelity image generation for storyboard frames
install_global_skill \
    "nano-banana-pro" \
    "$CLI_CMD install nano-banana-pro --global" \
    "High-fidelity image generation (storyboard frames)"

# --- seedance-video (P0 for TikTok) ---
# Used by: tiktok-director
# Video generation: text-to-video, image-to-video with Seedance 1.5 Pro audio
install_global_skill \
    "seedance-video" \
    "$CLI_CMD install canghe-seedance-video --global" \
    "Video generation via Seedance 1.5 Pro with audio"

# --- canghe-image-gen (P0 for TikTok) ---
# Used by: tiktok-director
# Character image generation (manga-drama pipeline)
install_global_skill \
    "canghe-image-gen" \
    "$CLI_CMD install canghe-image-gen --global" \
    "Character image generation for manga drama"


# ===========================================================================
#  SECTION 2: Apify Skill
# ===========================================================================
log_section "Apify Skill (industrial-grade cloud scraping)"

# --- Apify (P1) ---
# Used by: voc-analyst
# Requires: APIFY_TOKEN
# Provides: Google Maps Actor, TikTok Actor, Instagram Actor
install_global_skill \
    "apify" \
    "$CLI_CMD install apify --global" \
    "Cloud scraping: Google Maps, TikTok, Instagram batch"
# Alternative: Install from https://github.com/apify/agent-skills


# ===========================================================================
#  SECTION 3: TikTok Director Workspace-Specific Skills
# ===========================================================================
log_section "TikTok Director Workspace Skills"

# --- manga-style-video ---
# 8 manga style presets with built-in professional prompts
install_workspace_skill \
    "manga-style-video" \
    "$TIKTOK_WORKSPACE" \
    "$CLI_CMD install manga-style-video --workspace $TIKTOK_WORKSPACE" \
    "8 manga style presets (japanese, ghibli, chinese, etc.)"

# --- manga-drama ---
# Storyboard-to-video pipeline: single character image to multi-scene drama
install_workspace_skill \
    "manga-drama" \
    "$TIKTOK_WORKSPACE" \
    "$CLI_CMD install manga-drama --workspace $TIKTOK_WORKSPACE" \
    "Storyboard-to-video: character image -> multi-scene drama"

# --- volcengine-video-understanding ---
# Video content analysis, QA, emotion detection, scene recognition
install_workspace_skill \
    "volcengine-video-understanding" \
    "$TIKTOK_WORKSPACE" \
    "$CLI_CMD install volcengine-video-understanding --workspace $TIKTOK_WORKSPACE" \
    "Video QA: quality scoring, emotion detection, scene analysis"


# ===========================================================================
#  SECTION 4: Python Dependencies (for Agent-Reach)
# ===========================================================================
log_section "Python Dependencies"

log_info "Installing yt-dlp (YouTube/TikTok/Bilibili metadata extraction)"
if $DRY_RUN; then
    log_info "  [DRY RUN] Would run: pip3 install --quiet yt-dlp feedparser"
else
    if pip3 install --quiet yt-dlp feedparser 2>&1; then
        log_ok "  Installed: yt-dlp, feedparser"
    else
        log_err "  Failed to install Python dependencies"
        FAILED_INSTALLS+=("python: yt-dlp feedparser")
    fi
fi


# ===========================================================================
#  SECTION 5: Verification
# ===========================================================================
log_section "Installation Verification"

log_info "Checking global skills directory..."
if [[ -d "$GLOBAL_SKILLS_DIR" ]]; then
    global_count=$(find "$GLOBAL_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    log_info "  Global skills found: $global_count"
    for dir in "$GLOBAL_SKILLS_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            log_info "    - $(basename "$dir")"
        fi
    done
fi

log_info "Checking TikTok workspace skills..."
tiktok_skills_dir="$OPENCLAW_DIR/$TIKTOK_WORKSPACE/skills"
if [[ -d "$tiktok_skills_dir" ]]; then
    tiktok_count=$(find "$tiktok_skills_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    log_info "  TikTok workspace skills found: $tiktok_count"
    for dir in "$tiktok_skills_dir"/*/; do
        if [[ -d "$dir" ]]; then
            log_info "    - $(basename "$dir")"
        fi
    done
fi

log_info "Checking Python tools..."
if command -v yt-dlp &>/dev/null; then
    log_ok "  yt-dlp: $(yt-dlp --version 2>/dev/null || echo 'installed')"
else
    log_warn "  yt-dlp: not found on PATH"
fi


# ===========================================================================
#  SECTION 6: Summary Report
# ===========================================================================
log_section "Installation Summary"

echo ""
echo "Successful: ${#SUCCESSFUL_INSTALLS[@]}"
for item in "${SUCCESSFUL_INSTALLS[@]:-}"; do
    [[ -n "$item" ]] && echo "  + $item"
done

echo ""
echo "Skipped (already installed): ${#SKIPPED_INSTALLS[@]}"
for item in "${SKIPPED_INSTALLS[@]:-}"; do
    [[ -n "$item" ]] && echo "  ~ $item"
done

echo ""
if [[ ${#FAILED_INSTALLS[@]} -gt 0 ]]; then
    log_err "Failed: ${#FAILED_INSTALLS[@]}"
    for item in "${FAILED_INSTALLS[@]}"; do
        echo "  ! $item"
    done
    echo ""
    log_err "Some skills failed to install. Fix the errors above and re-run this script."
    echo "  The script is idempotent -- already-installed skills will be skipped."
    exit 1
else
    echo "Failed: 0"
    echo ""
    log_ok "All skills installed successfully."
fi
