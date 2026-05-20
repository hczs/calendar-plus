# CalendarPlus 官网

Astro 5 + React islands + Tailwind CSS 4。构建产物为静态文件，部署在 Cloudflare Pages。

**正式地址：** https://calendar.caiden.asia

## 本地开发

```bash
cd website
npm install
npm run dev
```

浏览器打开 http://localhost:4321

## 构建

```bash
npm run build
npm run preview   # 预览 dist/
```

## 截图

将应用截图放入 `public/screenshots/`（与仓库根 `docs/` 中命名一致即可）：

- `dark.png` — 菜单栏弹窗深色
- `light.png` — 菜单栏弹窗浅色
- `settings.png` — 设置页

```bash
# 若截图在仓库 docs/ 目录
cp ../docs/dark.png ../docs/light.png ../docs/settings.png public/screenshots/
```

## Cloudflare Pages 配置

在 Cloudflare Dashboard → Workers & Pages → 连接本仓库：

| 设置 | 值 |
|------|-----|
| Root directory | `website` |
| Build command | `npm run build` |
| Build output | `dist` |
| Production branch | `main` |

### 自定义域名

1. Pages 项目 → **Custom domains** → 添加 `calendar.caiden.asia`
2. 若 `caiden.asia` 已在同一 Cloudflare 账号，DNS 通常会自动创建 `CNAME calendar → *.pages.dev`
3. 等待 SSL 证书生效

推送 `website/**` 到 `main` 后自动构建部署，与 macOS DMG 的 GitHub Actions 互不影响。
