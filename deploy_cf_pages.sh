#!/usr/bin/env bash
set -euo pipefail

# Deploy to Cloudflare Pages using Wrangler
# Prereqs:
#   npm install -g wrangler
#   export CF_ACCOUNT_ID=xxxx
#   export CF_API_TOKEN=xxxx
#   export PROJECT_NAME=my-pages-project

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"

if [ ! -d "$DIST_DIR" ]; then
  echo "dist/ not found. Run ./build_site.sh first."
  exit 1
fi

: "${CF_ACCOUNT_ID:?Need CF_ACCOUNT_ID}"
: "${CF_API_TOKEN:?Need CF_API_TOKEN}"
: "${PROJECT_NAME:?Need PROJECT_NAME}"

wrangler pages deploy "$DIST_DIR" --project-name "$PROJECT_NAME" --account-id "$CF_ACCOUNT_ID"

echo "Deploy complete."