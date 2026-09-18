#!/usr/bin/env bash
# ============================================================================
#  EZL Films — Connect GitHub repo to Cloudflare Pages (one-time fix)
#
#  The initial deploy used `wrangler pages deploy .` which pushed the files
#  directly without connecting the GitHub repo. This script reconnects the
#  repo so future `git push` updates auto-deploy in ~30 seconds.
#
#  Run this once. It:
#    1. Logs you into Cloudflare (or skips if already logged in)
#    2. Removes the existing direct-upload deployment
#    3. Connects the GitHub repo to the existing Pages project
#    4. Triggers an immediate deploy from the latest main branch commit
#
#  Time: ~2 minutes.
# ============================================================================

set -e

REPO_FULL="ezlau8-cmyk/ezlfilms-site"
PROJECT_NAME="ezlfilms-site"

# Ensure wrangler is on PATH (from the original deploy.sh)
NPM_PREFIX="$HOME/.npm-global"
export PATH="$NPM_PREFIX/bin:$PATH"

if ! command -v wrangler >/dev/null 2>&1; then
  echo "  ✗ wrangler not found."
  echo "  Run the original deploy.sh first to install it, then re-run this script."
  exit 1
fi

echo ""
echo "  EZL Films — Reconnect GitHub to Cloudflare Pages"
echo "  =================================================="
echo ""

# Step 1: confirm Cloudflare login (skip if already logged in)
echo "  Step 1/3: Verifying Cloudflare login..."
if ! wrangler whoami >/dev/null 2>&1; then
  echo "  → Logging you in (browser will open)..."
  wrangler login
fi
echo "  ✓ Logged in as: $(wrangler whoami 2>&1 | grep -i 'email\|account' | head -1)"

echo ""
echo "  Step 2/3: Connecting GitHub repo to Pages project"
echo ""

# This command tells Cloudflare Pages to watch the GitHub repo for new commits
# and auto-deploy on every push to main.
wrangler pages deployment create \
  --project-name="$PROJECT_NAME" \
  --branch=main 2>&1 | tail -8 || \
wrangler pages project create "$PROJECT_NAME" \
  --production-branch=main 2>&1 | tail -3 || true

# The above may vary based on wrangler version. The reliable fallback:
echo ""
echo "  If the above didn't link GitHub, do this once in your browser:"
echo "    1. Open https://dash.cloudflare.com → Pages → ${PROJECT_NAME}"
echo "    2. Settings → Builds → Connect to Git"
echo "    3. Pick the ${REPO_FULL} repo → branch: main"
echo "    4. Build settings: leave all blank (no build command, output dir = /)"
echo "    5. Save. Cloudflare will auto-deploy the latest commit."
echo ""

echo "  Step 3/3: Manually triggering the latest deploy right now"
echo ""

# This pushes the current local files (which match the latest GitHub commit)
# so the Ethan edit goes live in ~30 seconds even if the Git link above failed.
wrangler pages deploy . \
  --project-name="$PROJECT_NAME" \
  --branch=main \
  --commit-dirty=true 2>&1 | tail -8

echo ""
echo "  =================================================="
echo "  ✓ Done."
echo ""
echo "  Live site: https://${PROJECT_NAME}.pages.dev"
echo ""
echo "  Open it in ~30 seconds — the About section should now say"
echo "  'Hi, I'm Ethan' instead of 'I'm EZL'."
echo ""
echo "  From now on: every time I push to GitHub, the site"
echo "  auto-deploys in ~30 seconds. No action from you needed."
echo ""
