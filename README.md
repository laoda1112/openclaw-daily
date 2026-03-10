# openclaw-daily

OpenClaw 玩法与技能自动发布站（2小时一篇）。

## 目录说明
- `site/`：静态站点产物（GitHub Pages 可直接用）
- `src/`：站点源码
- `build_site.sh`：构建脚本
- `serve_local.sh`：本地预览
- `deploy_cf_pages.sh`：Cloudflare Pages 部署脚本
- `publish_hourly.sh`：定时发布脚本
- `article_template.md`：文章模板
- `rules_checklist.md`：发布规则检查表
- `sample_article.md`：示例文章
- `health_checklist.md` / `light_monitor.sh` / `alert_plan.md`：轻量监控与告警
- `site_plan.md`：超低内存站点方案说明

## 快速开始
```bash
bash build_site.sh
bash serve_local.sh
```
