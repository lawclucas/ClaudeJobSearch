#!/usr/bin/env bash
# Installs career-ops (https://github.com/santifer/career-ops) into this repo.
# Pinned to v1.34.0, commit fe289aa2c99fa8f66faf3bf91d9b2bd8f14e9cd8.
set -euo pipefail

REPO_URL="https://github.com/santifer/career-ops.git"
COMMIT="fe289aa2c99fa8f66faf3bf91d9b2bd8f14e9cd8"
DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v git  >/dev/null || { echo "git is required";  exit 1; }
command -v node >/dev/null || { echo "Node.js >=18 is required"; exit 1; }
command -v npm  >/dev/null || { echo "npm is required";  exit 1; }

echo "==> Fetching career-ops at $COMMIT"
git clone --quiet "$REPO_URL" "$TMP/career-ops"
git -C "$TMP/career-ops" checkout --quiet "$COMMIT"

echo "==> Copying files into $DEST (excluding .git)"
tar -C "$TMP/career-ops" --exclude=.git -cf - . | tar -C "$DEST" -xf -

cd "$DEST"

echo "==> Installing npm dependencies"
# The postinstall hook downloads Chromium via Playwright. Skip it when a
# browser is already provided (e.g. PLAYWRIGHT_BROWSERS_PATH is set).
if [[ -n "${PLAYWRIGHT_BROWSERS_PATH:-}" ]]; then
  npm install --ignore-scripts
else
  npm install
fi

echo "==> Running setup check"
npm run doctor || echo "doctor reported issues; setup completes on first launch of your AI CLI"

echo "==> Done. Start with: cd \"$DEST\" && claude"
