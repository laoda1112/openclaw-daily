#!/usr/bin/env bash
set -euo pipefail

# Hourly publish pipeline for OpenClaw release site
# Usage:
#   ./publish_hourly.sh [--dry-run]
#
# Environment variables (optional):
#   GENERATE_CMD  - command to generate content (default: ./generate.sh)
#   DEPLOY_CMD    - command to deploy/publish (default: ./deploy.sh)
#   WORKDIR       - working directory (default: script dir)

DRY_RUN=false
if [[ ${1:-} == "--dry-run" ]]; then
  DRY_RUN=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${WORKDIR:-$SCRIPT_DIR}"
GENERATE_CMD="${GENERATE_CMD:-./generate.sh}"
DEPLOY_CMD="${DEPLOY_CMD:-./deploy.sh}"

run_cmd() {
  if $DRY_RUN; then
    echo "[dry-run] $*"
  else
    echo "[run] $*"
    eval "$@"
  fi
}

cd "$WORKDIR"

# 1) Generate latest content
run_cmd "$GENERATE_CMD"

# 2) Publish/deploy
run_cmd "$DEPLOY_CMD"

# 3) Optional health check (placeholder)
# run_cmd "./health_check.sh"

echo "Done."