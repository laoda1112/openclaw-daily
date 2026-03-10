#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
PORT="${PORT:-8080}"

if [ ! -d "$DIST_DIR" ]; then
  echo "dist/ not found. Run ./build_site.sh first."
  exit 1
fi

echo "Serving $DIST_DIR on http://localhost:$PORT"
python -m http.server "$PORT" --directory "$DIST_DIR"