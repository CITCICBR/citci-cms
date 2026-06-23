#!/usr/bin/env bash
set -euo pipefail

CMS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITE_DIR="$CMS_DIR/../citci-website"

# Swap config.local.yml → config.yml for local proxy backend
cp "$CMS_DIR/public/admin/config.local.yml" "$CMS_DIR/public/admin/config.yml"

echo "=== Starting local CMS dev servers ==="
echo "CMS site:  http://localhost:5173/admin/"
echo "Main site: http://localhost:3000"

# Start Decap CMS proxy in background
npx decap-server &
DECAP_PID=$!
trap "kill $DECAP_PID 2>/dev/null; exit" EXIT

# Start a static file server for the CMS site
npx serve "$CMS_DIR/public" -l 5173 &
SERVE_PID=$!
trap "kill $DECAP_PID $SERVE_PID 2>/dev/null; exit" EXIT

# Start the Next.js dev server from the main site
(cd "$SITE_DIR" && npm run dev) &
NEXT_PID=$!
trap "kill $DECAP_PID $SERVE_PID $NEXT_PID 2>/dev/null; exit" EXIT

wait
