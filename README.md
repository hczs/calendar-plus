# CalendarPlus

<p align="center">
  <img src="Brand/logo.jpeg" alt="CalendarPlus" width="120" />
</p>

一个基于 AppKit 的 macOS 菜单栏日历应用，支持：

- 月历弹窗（节假日 / 补班角标）
- 农历与中外节日显示
- 设置页主题切换（系统 / 浅色 / 深色）

## 效果预览
![菜单栏弹窗-深色](docs/dark.png)
![菜单栏弹窗-浅色](docs/light.png)
![设置页](docs/settings.png)

## 本地运行

```bash
./start.sh
```

## 图标

- **应用图标**：品牌源文件 `Brand/logo.jpeg`。更新后运行下方命令重新生成 `AppIcon.icns`。
- **菜单栏图标**：使用 SF Symbol `calendar`（单色 template，随系统深浅色反色）。设置里「今日日期」模式会显示当天数字，类似系统日历。

更新应用图标：

```bash
swiftc scripts/generate-icons.swift -o /tmp/generate-icons -framework AppKit
/tmp/generate-icons "$(pwd)"
```

## 测试

```bash
swift test --filter SettingsFlowTests
swift test --filter MonthGridViewRenderTests
```

## 自动构建 DMG

- GitHub Actions: `.github/workflows/build-dmg.yml`
- 触发条件：
  - 推送到 `main`
  - 推送 `v*` 标签
  - 手动触发 `workflow_dispatch`
- 产物：
  - `CalendarPlus-<version>.dmg`
  - 内含 `arm64 + x86_64` 通用二进制

## 手工验收

- `/Users/powercheng/code/projects/calendar-plus/.worktrees/codex-mac-menubar-calendar/docs/testing/manual-qa-menubar-calendar.md`
