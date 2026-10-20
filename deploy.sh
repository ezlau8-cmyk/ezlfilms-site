#!/usr/bin/env bash
# ============================================================================
#  EZL Films — Cloudflare Pages Deploy (v3 — token path, works unattended)
#
#  WHY THIS FILE EXISTS:
#    The GitHub → Cloudflare auto-deploy integration is disconnected, so a
#    `git push` does NOT redeploy. Every deploy must be an explicit wrangler
#    call. This script wraps that call so it is one command on this box.
#
#  CREDENTIALS (both required):
#    CLOUDFLARE_API_TOKEN  — read from /root/.config/.wrangler/.cf_token (chmod 600)
#                            Token permission MUST be: Account → Cloudflare Pages → Edit
#                            (NOT "Access: Custom Pages" — that is login-page branding
#                             and produces "Authentication error 10000")
#    CLOUDFLARE_ACCOUNT_ID — bf78ecd984f8b4d34fdb41af2f999add
#
#  USAGE:
#    ./deploy.sh
#
#  VERIFICATION (content-verification required, not just HTTP 200):
#    curl -s https://ezlfilms-site.pages.dev/ | grep "LIVE_WORK_UPDATE"
#    If that prints nothing, the deploy did NOT pick up the latest commit.
#    NOTE: web_extract returns a STALE cached copy — use curl or a browser fetch.
# ============================================================================

set -euo pipefail

PROJECT_NAME="ezlfilms-site"
ACCOUNT_ID="bf78ecd984f8b4d34fdb41af2f999add"
TOKEN_FILE="/root/.config/.wrangler/.cf_token"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  EZL Films — Cloudflare Pages Deploy"
echo "  ===================================="
echo ""

# ── Preflight ──────────────────────────────────────────────────────────────
if ! command -v wrangler >/dev/null 2>&1; then
  echo "  ✗ wrangler not found."
  echo "    Install: npm install -g wrangler"
  exit 1
fi
echo "  ✓ wrangler $(wrangler --version 2>&1 | head -1)"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "  ✗ No API token at $TOKEN_FILE"
  echo "    Create one at https://dash.cloudflare.com/profile/api-tokens"
  echo "    with permission: Account → Cloudflare Pages → Edit"
  echo "    and Account Resources → All accounts."
  exit 1
fi
chmod 600 "$TOKEN_FILE"
export CLOUDFLARE_API_TOKEN="$(cat "$TOKEN_FILE")"
export CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID"
echo "  ✓ Token loaded (chmod 600) · account $ACCOUNT_ID"

# Confirm the token can actually SEE the project before deploying.
if ! curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME" \
     | grep -q '"name"'; then
  echo "  ✗ Token cannot access project '$PROJECT_NAME' on account $ACCOUNT_ID."
  echo "    Check the token's Permissions dropdown says 'Cloudflare Pages'"
  echo "    (not 'Access: Custom Pages') and Account Resources says 'All accounts'."
  exit 1
fi
echo "  ✓ Project '$PROJECT_NAME' accessible"

# ── Commit anything outstanding, then deploy ──────────────────────────────
cd "$SCRIPT_DIR"
if [ -n "$(git status --porcelain)" ]; then
  echo "  → Committing outstanding changes"
  git add -A
  git commit -m "Deploy $(date +%Y-%m-%d\ %H:%M)" || true
  git push origin main || true
fi

echo ""
echo "  Deploying..."
wrangler pages deploy . \
  --project-name="$PROJECT_NAME" \
  --branch=main \
  --commit-dirty=true 2>&1 | tail -8

echo ""
echo "  ===================================="
echo "  ✓ Done. Live at: https://${PROJECT_NAME}.pages.dev"
echo ""
echo "  Verify with:"
echo "    curl -s https://${PROJECT_NAME}.pages.dev/ | grep 'LIVE_WORK_UPDATE'"
echo ""
