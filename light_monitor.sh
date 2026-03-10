#!/usr/bin/env bash
set -euo pipefail

# ========= 基础配置 =========
SITE_URL=${SITE_URL:-"https://example.com"}
CHECK_URLS=${CHECK_URLS:-"/ /sitemap.xml"}
EXPECTED_TEXT=${EXPECTED_TEXT:-""}
MAX_CONTENT_AGE_HOURS=${MAX_CONTENT_AGE_HOURS:-48}
TIMEOUT=${TIMEOUT:-10}

# 告警 Webhook（Slack/企业微信/自建网关）
ALERT_WEBHOOK=${ALERT_WEBHOOK:-""}
ALERT_TITLE=${ALERT_TITLE:-"OpenClaw 发布站监控告警"}

# 发布链路（可选）：GitHub Actions
GITHUB_REPO=${GITHUB_REPO:-""}           # 例如：openclaw/site
GITHUB_BRANCH=${GITHUB_BRANCH:-"main"}
GITHUB_TOKEN=${GITHUB_TOKEN:-""}

# 发布链路（可选）：Cloudflare Pages
CF_ACCOUNT_ID=${CF_ACCOUNT_ID:-""}
CF_PROJECT=${CF_PROJECT:-""}
CF_API_TOKEN=${CF_API_TOKEN:-""}

# ========= 工具函数 =========
now_ts() { date -u +%s; }
log() { echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"; }
fail() { ERRORS+=("$*"); log "FAIL: $*"; }

send_alert() {
  local msg="$1"
  if [[ -z "$ALERT_WEBHOOK" ]]; then
    log "ALERT_WEBHOOK 未设置，跳过发送告警"; return 0
  fi
  curl -sS -X POST -H 'Content-Type: application/json' \
    -d "{\"title\":\"${ALERT_TITLE}\",\"text\":\"${msg}\"}" \
    "$ALERT_WEBHOOK" >/dev/null || true
}

# ========= 1) 可用性 =========
ERRORS=()
TOTAL_CHECKS=0

for path in $CHECK_URLS; do
  TOTAL_CHECKS=$((TOTAL_CHECKS+1))
  url="${SITE_URL%/}${path}"
  read -r code time_total < <(curl -sS -o /dev/null -w "%{http_code} %{time_total}" --max-time "$TIMEOUT" "$url" || echo "000 99")
  if [[ "$code" != "200" ]]; then
    fail "可用性失败：$url 返回 $code"
  fi
  if (( $(echo "$time_total > 2" | bc -l) )); then
    fail "响应过慢：$url ${time_total}s"
  fi
  if [[ -n "$EXPECTED_TEXT" && "$path" == "/" ]]; then
    body=$(curl -sS --max-time "$TIMEOUT" "$url" || true)
    if ! grep -q "$EXPECTED_TEXT" <<< "$body"; then
      fail "首页缺少关键文本：$EXPECTED_TEXT"
    fi
  fi
  log "OK: $url ($code, ${time_total}s)"
 done

# ========= 2) 内容生成 =========
# 尝试从 sitemap.xml 或 feed.xml 获取最新更新时间
latest_ts=""
for p in "/sitemap.xml" "/feed.xml" "/atom.xml"; do
  url="${SITE_URL%/}$p"
  xml=$(curl -sS --max-time "$TIMEOUT" "$url" || true)
  if [[ -n "$xml" ]]; then
    # 优先取最后一个 <lastmod> / <updated>
    lastmod=$(grep -o "<lastmod>[^<]*" <<< "$xml" | tail -n 1 | sed 's/<lastmod>//' || true)
    updated=$(grep -o "<updated>[^<]*" <<< "$xml" | tail -n 1 | sed 's/<updated>//' || true)
    ts_str=${lastmod:-$updated}
    if [[ -n "$ts_str" ]]; then
      latest_ts=$(date -u -d "$ts_str" +%s 2>/dev/null || true)
      break
    fi
  fi
 done

if [[ -n "$latest_ts" ]]; then
  age_hours=$(( ( $(now_ts) - latest_ts ) / 3600 ))
  if (( age_hours > MAX_CONTENT_AGE_HOURS )); then
    fail "内容过旧：最新更新距今 ${age_hours} 小时"
  else
    log "OK: 内容新鲜度 ${age_hours} 小时"
  fi
else
  log "INFO: 未解析到内容更新时间（sitemap/feed 缺失或无 lastmod）"
fi

# ========= 3) 发布链路 =========
# GitHub Actions 最近一次 workflow
if [[ -n "$GITHUB_REPO" && -n "$GITHUB_TOKEN" ]]; then
  api="https://api.github.com/repos/${GITHUB_REPO}/actions/runs?branch=${GITHUB_BRANCH}&per_page=1"
  resp=$(curl -sS -H "Authorization: Bearer ${GITHUB_TOKEN}" "$api" || true)
  conclusion=$(grep -o '"conclusion"[^"]*"[^"]*"' <<< "$resp" | head -n 1 | sed 's/.*"conclusion"[^"]*"\([^"]*\)"/\1/' )
  status=$(grep -o '"status"[^"]*"[^"]*"' <<< "$resp" | head -n 1 | sed 's/.*"status"[^"]*"\([^"]*\)"/\1/' )
  if [[ "$conclusion" != "success" && "$status" != "completed" ]]; then
    fail "发布链路失败：GitHub Actions 状态 ${status}/${conclusion}"
  else
    log "OK: GitHub Actions 最近一次成功"
  fi
else
  log "INFO: GitHub 发布检查未配置"
fi

# Cloudflare Pages 最近一次部署
if [[ -n "$CF_ACCOUNT_ID" && -n "$CF_PROJECT" && -n "$CF_API_TOKEN" ]]; then
  api="https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/pages/projects/${CF_PROJECT}/deployments"
  resp=$(curl -sS -H "Authorization: Bearer ${CF_API_TOKEN}" "$api" || true)
  state=$(grep -o '"latest_stage"[^"]*"[^"]*"' <<< "$resp" | head -n 1 | sed 's/.*"latest_stage"[^"]*"\([^"]*\)"/\1/' )
  if [[ "$state" != "success" ]]; then
    fail "发布链路失败：Cloudflare Pages 部署状态 $state"
  else
    log "OK: Cloudflare Pages 最近一次部署成功"
  fi
else
  log "INFO: Cloudflare Pages 发布检查未配置"
fi

# ========= 告警输出 =========
if (( ${#ERRORS[@]} > 0 )); then
  msg=$(printf '%s\n' "${ERRORS[@]}")
  send_alert "$msg"
  log "SUMMARY: FAIL (${#ERRORS[@]} 项)"
  exit 1
else
  log "SUMMARY: OK (共检查 ${TOTAL_CHECKS} 项)"
fi
