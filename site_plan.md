# 超低内存站点方案

## 目标
在超低内存（≤256MB）或“零常驻进程”的约束下稳定提供发布站点，成本低、运维简单、可扩展。

---

## 方案对比

### 1) 静态站（SSG/纯静态）
**特点**：构建时生成 HTML/CSS/JS，线上仅静态文件托管。

**优点**
- 运行时几乎零内存占用（CDN/对象存储托管）
- 成本最低、稳定性最高
- 无需维护后端进程

**缺点**
- 动态功能有限（需借助第三方服务或 Serverless）
- 需要构建流程（CI/CD）

**适用场景**
- 发布公告、文档、博客、营销页
- 变更频率不高但可通过自动部署更新

**推荐技术栈**
- SSG：Hugo / Astro / Next.js（纯静态导出）
- 部署：Cloudflare Pages / GitHub Pages / Netlify

---

### 2) 轻量后端（极小实例/Serverless）
**特点**：保留动态能力，后端使用超小容器或函数计算。

**优点**
- 支持动态内容、API、后台管理
- 可逐步扩展功能

**缺点**
- 常驻实例仍需内存（哪怕很小）
- 成本和运维复杂度高于纯静态

**适用场景**
- 需要动态登录/管理后台
- 需要数据写入或实时 API

**推荐技术栈**
- 轻量后端：Cloudflare Workers / Deno Deploy / AWS Lambda
- 低配容器：Fly.io / Render（最小实例）
- 数据：Cloudflare D1 / Supabase（外置数据库）

---

## 推荐方案
**首选：静态站 + Serverless 辅助**
- 核心页面使用静态站（Hugo/Astro）
- 如需动态功能（表单、评论、轻量 API），通过 Cloudflare Workers 或第三方服务补足

### 推荐部署平台
**Cloudflare Pages + Workers（首选）**
- Pages 托管静态站（全球 CDN，免费额度大）
- Workers 提供轻量 API（按请求计费，不常驻内存）
- 配置简单，维护成本极低

**备选**
- GitHub Pages（最省事，但动态扩展有限）
- Netlify（功能完整，免费额度有限）

---

## 结论
在“超低内存”约束下，**纯静态或静态 + Serverless** 是最稳妥的选择。推荐使用 **Cloudflare Pages + Workers**：兼顾零内存常驻和动态扩展能力，成本最低、稳定性最高。