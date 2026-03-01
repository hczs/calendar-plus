# CalendarPlus

一个基于 AppKit 的 macOS 菜单栏日历应用，支持：

- 月历弹窗（节假日 / 补班角标）
- 农历与中外节日显示
- 设置页主题切换（系统 / 浅色 / 深色）

## 效果预览（占位符）

> 后续把下面路径替换成实际截图文件即可。

![菜单栏弹窗-深色](docs/images/preview-dark-placeholder.png)
![菜单栏弹窗-浅色](docs/images/preview-light-placeholder.png)
![设置页](docs/images/preview-settings-placeholder.png)

## 本地运行

```bash
./start.sh
```

## 测试

```bash
swift test --filter SettingsFlowTests
swift test --filter MonthGridViewRenderTests
```

## 手工验收

- `/Users/powercheng/code/projects/calendar-plus/.worktrees/codex-mac-menubar-calendar/docs/testing/manual-qa-menubar-calendar.md`
