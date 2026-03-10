#!/usr/bin/env bash
set -euo pipefail

# For GitHub Pages using /docs, we only need to rebuild index listing
POSTS_DIR="docs/posts"
INDEX="docs/index.html"

mkdir -p "$POSTS_DIR"

{
  echo '<!doctype html>'
  echo '<html lang="zh-CN">'
  echo '<head>'
  echo '  <meta charset="utf-8" />'
  echo '  <meta name="viewport" content="width=device-width, initial-scale=1" />'
  echo '  <title>OpenClaw Daily</title>'
  echo '  <link rel="stylesheet" href="style.css" />'
  echo '</head>'
  echo '<body>'
  echo '  <main class="container">'
  echo '    <h1>OpenClaw Daily</h1>'
  echo '    <p class="muted">每 2 小时一篇 · 自动发布</p>'
  echo '    <ul>'

  # list posts newest first
  ls -1 "$POSTS_DIR"/*.html 2>/dev/null | sort -r | while read -r f; do
    name=$(basename "$f")
    title=$(grep -m1 -o '<title>.*</title>' "$f" | sed 's/<\/\?title>//g')
    echo "      <li><a href=\"posts/${name}\">${title}</a></li>"
  done

  echo '    </ul>'
  echo '  </main>'
  echo '</body>'
  echo '</html>'
} > "$INDEX"

echo "Updated ${INDEX}"
