#!/usr/bin/env bash
# ============================================================================
#  EZL Films — Cloudflare Pages Deploy (v2 — fixes macOS npm EACCES)
# ============================================================================

set -e

REPO="ezlau8-cmyk/ezlfilms-site"
PROJECT_NAME="ezlfilms-site"

echo ""
echo "  EZL Films — Cloudflare Pages Deploy"
echo "  ===================================="
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

# Install wrangler to a user-owned prefix (no sudo required, no EACCES)
NPM_PREFIX="$HOME/.npm-global"
mkdir -p "$NPM_PREFIX"
npm config set prefix "$NPM_PREFIX"
export PATH="$NPM_PREFIX/bin:$PATH"

# Persist PATH for future shells
if ! grep -q "$NPM_PREFIX/bin" "$HOME/.zshrc" 2>/dev/null; then
  echo "" >> "$HOME/.zshrc"
  echo "# npm global (added by EZL Films deploy script)" >> "$HOME/.zshrc"
  echo "export PATH=\"$NPM_PREFIX/bin:\$PATH\"" >> "$HOME/.zshrc"
  echo "  ✓ Added $NPM_PREFIX/bin to ~/.zshrc PATH"
fi

if ! command -v wrangler >/dev/null 2>&1; then
  echo "  → Installing wrangler to $NPM_PREFIX (no sudo needed)..."
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

wrangler pages project create "$PROJECT_NAME" \
  --production-branch=main \
  --compatibility-date=2024-01-01 2>&1 | tail -5 || true

echo ""
echo "  Step 4/4: Triggering the first deploy"
echo ""

wrangler pages deploy . \
  --project-name="$PROJECT_NAME" \
  --branch=main \
  --commit-dirty=true 2>&1 | tail -10

echo ""
echo "  ===================================="
echo "  ✓ Done."
echo ""
echo "  Your live site is at:"
echo "    https://${PROJECT_NAME}.pages.dev"
echo ""
echo "  (Cloudflare assigns the exact URL in the dashboard.)"
echo ""
