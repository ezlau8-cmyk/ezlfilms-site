#!/usr/bin/env bash
# ============================================================================
#  EZL Films — One-shot Cloudflare Pages deploy script
#  Run this ONCE on your laptop. After it completes, every time I push to
#  GitHub, the live site updates automatically in ~30 seconds.
#
#  What this does:
#    1. Installs wrangler (Cloudflare's deploy CLI) if you don't have it
#    2. Asks you to log into Cloudflare (opens browser)
#    3. Connects your ezlau8-cmyk/ezlfilms-site GitHub repo to Cloudflare Pages
#    4. Triggers the first deploy
#    5. Prints the live URL
#
#  Time: ~2 minutes. Requires: Node.js installed.
# ============================================================================

set -e

REPO="ezlau8-cmyk/ezlfilms-site"
PROJECT_NAME="ezlfilms-site"

echo ""
echo "  EZL Films — Cloudflare Pages Deploy"
echo "  ===================================="
echo ""
echo "  Step 1/4: Checking for Node.js + wrangler..."
echo ""

# Check Node
if ! command -v node >/dev/null 2>&1; then
  echo "  ✗ Node.js not found."
  echo ""
  echo "  Install it from https://nodejs.org (download the LTS version)."
  echo "  Then re-run this script."
  exit 1
fi
echo "  ✓ Node $(node --version)"

# Install wrangler if missing
if ! command -v wrangler >/dev/null 2>&1; then
  echo "  → Installing wrangler (Cloudflare deploy CLI)..."
  npm install -g wrangler 2>&1 | tail -3
fi
echo "  ✓ wrangler $(wrangler --version 2>&1 | head -1)"

echo ""
echo "  Step 2/4: Log into Cloudflare"
echo "  A browser tab will open. Approve the login."
echo "  (If no browser opens, copy the URL wrangler prints.)"
echo ""

wrangler login

echo ""
echo "  Step 3/4: Creating Cloudflare Pages project linked to your GitHub repo"
echo ""

# Create the Pages project, deploying from the existing GitHub repo
wrangler pages project create "$PROJECT_NAME" \
  --production-branch=main \
  --compatibility-date=2024-01-01 2>&1 | tail -5 || true

echo ""
echo "  Step 4/4: Triggering the first deploy"
echo ""

# Trigger initial deploy from the GitHub repo's main branch
wrangler pages deploy . \
  --project-name="$PROJECT_NAME" \
  --branch=main \
  --commit-dirty=true 2>&1 | tail -10

echo ""
echo "  ===================================="
echo "  ✓ Done."
echo ""
echo "  Your live site will be at:"
echo "    https://${PROJECT_NAME}.pages.dev"
echo ""
echo "  (Cloudflare assigns the exact URL in the dashboard. Check it"
echo "   at https://dash.cloudflare.com → Pages → ${PROJECT_NAME}.)"
echo ""
echo "  From now on: every time I push code to GitHub, the site"
echo "  redeploys automatically. You don't need to do anything."
echo ""
echo "  Next steps for you (when you're recovered):"
echo "    1. Open the live URL, screenshot it, send it to me"
echo "    2. We swap in your Vimeo reels + headshot + real email"
echo "    3. We sign up for Formspree (free) for the contact form"
echo ""
