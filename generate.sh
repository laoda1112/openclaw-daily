#!/usr/bin/env bash
set -euo pipefail

# Simple content generator: creates an HTML post under docs/posts
POSTS_DIR="docs/posts"
mkdir -p "$POSTS_DIR"

TS="$(date -u +%Y%m%d-%H%M)"
TITLE="OpenClaw 新玩法速览 · ${TS} UTC"
FILENAME="${TS}.html"
FILEPATH="${POSTS_DIR}/${FILENAME}"

cat > "$FILEPATH" <<HTML
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${TITLE}</title>
  <link rel="stylesheet" href="../style.css" />
</head>
<body>
  <main class="container">
    <h1>${TITLE}</h1>
    <p>这是一篇自动生成的 OpenClaw 小技巧短文，用于演示每 2 小时自动发布流程。</p>
    <h2>要点</h2>
    <ul>
      <li>新技能：快速集成任务系统拆分与巡检提示。</li>
      <li>最佳实践：将模板、脚本与监控清单放入仓库，便于持续发布。</li>
      <li>下一步：结合真实业务内容替换此模板，形成稳定栏目。</li>
    </ul>
    <p class="muted">发布时间：${TS} UTC</p>
    <p><a href="../index.html">返回首页</a></p>
  </main>
</body>
</html>
HTML

echo "Generated ${FILEPATH}"
