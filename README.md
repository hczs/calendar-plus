# CalendarPlus

<p align="center">
  <img src="Brand/logo-prepared.png" alt="CalendarPlus" width="120" />
</p>

**macOS 菜单栏日历 · 点开三秒看清今天**

[![Build DMG](https://github.com/hczs/calendar-plus/actions/workflows/build-dmg.yml/badge.svg)](https://github.com/hczs/calendar-plus/actions/workflows/build-dmg.yml)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](https://swift.org)

[官网](https://calendar.caiden.asia) · [下载 DMG](https://github.com/hczs/calendar-plus/releases/latest) · [报告问题](https://github.com/hczs/calendar-plus/issues)

---

CalendarPlus 是一款基于 **AppKit** 的 macOS 菜单栏日历工具（无 Dock 图标）。点击菜单栏图标即可弹出月历，展示公历、农历、中外节日，以及中国法定节假日与补班信息。不做日程管理、待办或同步——适合工作间隙快速确认「今天是几号、是否放假」。

## 功能特性

| 能力 | 说明 |
|------|------|
| **今天优先** | 月历格内描边环与加粗公历突出今天；切换月份时仍可定位当前日期 |
| **休班语义** | 法定节假日与补班用整格淡色底区分，副文案展示节日 / 农历 |
| **主题** | 设置页支持跟随系统、浅色、深色 |
| **轻量常驻** | 低内存、快冷启动；节假日数据联网拉取后本地缓存，支持手动刷新 |

## 截图

| 菜单栏弹窗（深色） | 菜单栏弹窗（浅色） | 设置 |
|:---:|:---:|:---:|
| ![深色主题](docs/dark.png) | ![浅色主题](docs/light.png) | ![设置页](docs/settings.png) |

## 下载与安装

在 [Releases](https://github.com/hczs/calendar-plus/releases/latest) 按 Mac 芯片选择对应 DMG：

| Mac 类型 | 文件名（示例） | 直链（Release 发布后可用） |
|----------|------------------|----------------------------|
| Apple 芯片（M 系列等） | `CalendarPlus-<version>-arm64.dmg` | [`CalendarPlus-arm64.dmg`](https://github.com/hczs/calendar-plus/releases/latest/download/CalendarPlus-arm64.dmg) |
| Intel 芯片 | `CalendarPlus-<version>-x86_64.dmg` | [`CalendarPlus-x86_64.dmg`](https://github.com/hczs/calendar-plus/releases/latest/download/CalendarPlus-x86_64.dmg) |

不确定芯片类型：左上角  → **关于本机** → **芯片**（Apple / Intel）。

安装步骤：

1. 下载与你 Mac 匹配的 DMG
2. 打开 DMG，将 **CalendarPlus** 拖入「应用程序」
3. 首次启动若被 Gatekeeper 拦截：系统设置 → 隐私与安全性 → 仍要打开

> CI 会分别构建 **arm64** 与 **x86_64** 两个 DMG（非 Universal Binary）。打 `v*` 标签发布时，Release 中会附带固定文件名的 `CalendarPlus-arm64.dmg` 与 `CalendarPlus-x86_64.dmg`，便于 `releases/latest/download/...` 直链。

## 系统要求

- macOS **14** 或更高版本（与 `Package.swift` 中平台声明一致）
- Apple Silicon 或 Intel Mac

## 从源码运行

**环境：** Xcode 16+（或带 Swift 6 工具链的 Command Line Tools）

```bash
git clone https://github.com/hczs/calendar-plus.git
cd calendar-plus
./start.sh
```

`start.sh` 会构建 `CalendarPlusApp` 可执行文件并启动；若已有实例在运行会先结束旧进程。

等价手动命令：

```bash
swift build --product CalendarPlusApp
swift run CalendarPlusApp
```

## 开发

### 项目结构

```
calendar-plus/
├── CalendarPlus/          # 应用核心库（UI、节假日、设置等）
├── CalendarPlusApp/       # 可执行入口
├── CalendarPlusTests/     # 单元 / UI 测试
├── Brand/                 # 品牌 logo 源文件
├── scripts/build-dmg.sh   # 分架构（arm64 / x86_64）DMG 打包脚本
├── website/               # 官网（Astro + React + Tailwind）
├── docs/                  # 设计说明、截图、手工验收清单
└── .github/workflows/     # CI：构建并发布 DMG
```

### 图标

- **应用图标**：优先使用 `Brand/AppIcon.appiconset`（各尺寸 PNG）生成 `CalendarPlus/Resources/AppIcon.icns` 并打入 DMG；若该目录不完整，则回退到 `Brand/logo.jpeg`（脚本会自动裁掉留白、按 macOS squircle 铺满），预览图见 `Brand/logo-prepared.png`。
- **菜单栏图标**：SF Symbol `calendar`（单色 template，随系统深浅色反色）。设置里「今日日期」模式显示当天数字。

更新应用图标：

```bash
swiftc scripts/generate-icons.swift -o /tmp/generate-icons -framework AppKit
/tmp/generate-icons "$(pwd)"
```

### 测试

```bash
# 全部测试
swift test

# 常用子集
swift test --filter SettingsFlowTests
swift test --filter MonthGridViewRenderTests
```

### 本地构建 DMG

```bash
./scripts/build-dmg.sh
# 产物：
#   dist/CalendarPlus-<version>-arm64.dmg
#   dist/CalendarPlus-<version>-x86_64.dmg
```

可通过环境变量覆盖版本号等，例如 `VERSION=v1.0.0 ./scripts/build-dmg.sh`。

## 官网

静态营销站点位于 [`website/`](website/)，部署在 [Cloudflare Pages](https://calendar.caiden.asia)。本地开发：

```bash
cd website
pnpm install
pnpm dev    # http://localhost:4321
```

详见 [`website/README.md`](website/README.md)。

## 文档

| 文档 | 说明 |
|------|------|
| [`PRODUCT.md`](PRODUCT.md) | 产品定位、用户与反例 |
| [`DESIGN.md`](DESIGN.md) | 视觉与交互设计约定 |
| [`docs/testing/manual-qa-menubar-calendar.md`](docs/testing/manual-qa-menubar-calendar.md) | 菜单栏日历手工验收清单 |

## 参与贡献

欢迎 Issue 与 Pull Request。建议流程：

1. Fork 本仓库并基于 `main` 创建分支
2. 修改后运行 `swift test`，涉及 UI 时参考手工验收清单
3. 提交 PR 并简要说明变更与测试情况

功能讨论或较大改动可先开 Issue 对齐预期。

## 相关链接

- **仓库：** https://github.com/hczs/calendar-plus
- **官网：** https://calendar.caiden.asia
- **Actions：** [Build DMG workflow](https://github.com/hczs/calendar-plus/actions/workflows/build-dmg.yml)
