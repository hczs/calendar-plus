---
name: CalendarPlus
description: 暖中性 macOS 菜单栏月历，今日优先、中文日历语义
colors:
  surface: "#F6F4F0"
  elevated: "#FDFCFA"
  text-primary: "#2C2824"
  text-secondary: "#6B6560"
  accent: "#D44B4F"
  accent-muted: "#E8A0A2"
  workday: "#4A7FD4"
  holiday-tint: "#F3E4E4"
  workday-tint: "#E4ECF8"
  divider: "#E5E0D8"
  surface-dark: "#1C1B19"
  elevated-dark: "#262422"
  text-primary-dark: "#F2EDE6"
  text-secondary-dark: "#9C958C"
typography:
  display:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Display, system-ui, sans-serif"
    fontSize: "30px"
    fontWeight: 600
    lineHeight: 1.1
  title:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Text, system-ui, sans-serif"
    fontSize: "17px"
    fontWeight: 600
    lineHeight: 1.2
  body:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Text, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.2
  caption:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Text, system-ui, sans-serif"
    fontSize: "10px"
    fontWeight: 400
    lineHeight: 1.3
  label:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Text, system-ui, sans-serif"
    fontSize: "11px"
    fontWeight: 400
    lineHeight: 1.3
rounded:
  popover: "12px"
  cell: "10px"
  pill: "6px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  hero: "56px"
components:
  icon-button:
    backgroundColor: "transparent"
    textColor: "{colors.text-secondary}"
    size: "28px"
  day-cell-today:
    backgroundColor: "transparent"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.cell}"
  status-pill:
    backgroundColor: "{colors.holiday-tint}"
    textColor: "{colors.accent}"
    rounded: "{rounded.pill}"
    padding: "2px 8px"
---

# Design System: CalendarPlus

## Overview

**Creative North Star: "办公桌边的黄历"**

CalendarPlus 是菜单栏里一块安静、信息足的日期玻璃：用户点开不是为了浏览界面，而是为了确认今天。视觉像熟稔的纸质月历被数字化，暖米白底、朱砂红点缀、SF Pro 字号阶梯清晰。弹窗本身是单层表面，不靠卡片套卡片制造层次。

系统明确拒绝：网页 SaaS 套壳、Windows 克隆、霓虹深色工具风、渐变字与玻璃模糊。深度靠暖色分层与 1px 分隔线，不靠阴影堆叠。

**Key Characteristics:**

- 顶部今日条：大号公历 + 星期 + 农历/节日 + 休班 pill
- 暖中性浅色为精致默认态；深色为同色相的暖炭，非冷蓝灰
- 月历格：公历 + 一行副文案；休/班用整格淡色底
- 今天：描边环强调，格内不铺整块红底
- 工具栏图标无边框，macOS accessoryBar 气质

## Colors

暖沙表面承载信息，朱砂只出现在语义位。

### Primary

- **朱砂 Accent** (`#D44B4F` / oklch(58% 0.18 25)): 周末列头、节日副文案、今日条关键信息、休班 pill 文字。禁止铺满大面。

### Secondary

- **暖蓝 Workday** (`#4A7FD4` / oklch(58% 0.12 250)): 补班日淡底与 pill，与休班红区分。

### Tertiary

- **休班底 Holiday Tint** (`#F3E4E4`): 法定节假日格子背景，约 8–10% 视觉重量。
- **补班底 Workday Tint** (`#E4ECF8`): 补班日格子背景。

### Neutral

- **暖沙 Surface** (`#F6F4F0`): 弹窗根背景。
- **米白 Elevated** (`#FDFCFA`): 今日条底、极 subtle 抬升。
- **炭笔 Text Primary** (`#2C2824`): 公历数字、标题。
- **暖灰 Text Secondary** (`#6B6560`): 农历、状态行、图标默认色。
- **分隔 Divider** (`#E5E0D8`): 区域 1px 线。

深色对：Surface `#1C1B19`，Elevated `#262422`，Text Primary `#F2EDE6`，Accent 略降饱和仍偏暖。

### Named Rules

**The Warm Neutral Rule.** 中性色向暖沙色相偏，禁止冷蓝灰 SaaS 背景。

**The Semantic Red Rule.** 红色只表达今天语义、周末、节日、休班；禁止装饰性大面积铺红。

## Typography

**Display Font:** SF Pro Display / 系统无衬线  
**Body Font:** SF Pro Text / 系统无衬线  

**Character:** 原生、紧凑、层级靠字号与字重，不用展示字体。

### Hierarchy

- **Display** (semibold, 30px, 1.1): 今日条公历数字。
- **Title** (semibold, 17px, 1.2): 月份标题 `yyyy年M月`。
- **Body** (semibold, 15px, 1.2): 月历格公历数字。
- **Caption** (regular, 10px, 1.3): 格内农历/节日副行，最多 6 字截断。
- **Label** (regular, 11px, 1.3): 星期行、状态提示、图例。

### Named Rules

**The One Line Detail Rule.** 每个日期格最多一行副文案：有节日显示节日，否则农历。

## Elevation

扁平优先。弹窗依赖 macOS `NSPopover` 系统阴影；内容区不用卡片阴影。深度用 `surface` / `elevated` 色差和 `divider` 表达，不用多层 box-shadow。

### Named Rules

**The Flat Popover Rule.** 禁止内容区 card-in-card 双边框；圆角 12px 只用于弹窗外轮廓与日期格。

## Components

工具型、克制、状态可读。

### Buttons

- **Shape:** 28px 正方形触区，无圆角底板。
- **Icon (Toolbar):** `accessoryBar`、无边框、仅 SF Symbol；hover 用 `contentTintColor` 略深。
- **Primary 文本:** 设置页 `rounded` bezels 保留；月历页不设主按钮。

### Today Hero（今日条）

- **Height:** 56–64px。
- **Layout:** 左大号日期 + 星期；下行农历/节日；右或下行 pill「休息日」「补班」。
- **Background:** `elevated`；底部分隔 `divider`。
- **Behavior:** 始终显示系统今天，不随浏览月份变化。

### Month Toolbar

- **Layout:** 左 `‹` `月份` `›`；右刷新、设置。
- **Typography:** Title 级月份；图标 Label 色。

### Day Cells

- **Shape:** 10px 圆角，最小约 36×36pt。
- **Default:** 透明底，公历 `body`，副行 `caption` 次要色。
- **Weekend:** 公历/副行 accent，不铺底。
- **Today:** 2px accent 描边环，字重 bold，无整块红底。
- **Holiday / Workday:** `holiday-tint` / `workday-tint` 整格底。
- **Festival:** 副行 accent 色。

### Status Message

- **Style:** 工具栏下或今日条下，11px `text-secondary`，单行截断；空文案时高度为 0。

### Settings（现有）

- **Style:** 与月历同宽 popover；分段控件 `rounded`；返回按钮 `rounded` bezel。

## Do's and Don'ts

### Do:

- **Do** 用暖沙 `surface` 作弹窗根，今日条用 `elevated` 微抬升。
- **Do** 让今日条在 1 秒内回答「今天几号、是否放假」。
- **Do** 休班用淡色整格底区分，可选 10px「休」「班」小字。
- **Do** 跟随系统浅/深色，深色保持暖炭色相。
- **Do** 使用 SF Pro 与 macOS 原生控件样式。

### Don't:

- **Don't** 做网页风卡片套壳（双边框、大圆角套娃），PRODUCT.md 明确禁止。
- **Don't** 生硬照搬 Windows 11 任务栏日历布局。
- **Don't** 做成臃肿日程 App 的信息密度与交互。
- **Don't** 使用霓虹深色、紫色渐变、玻璃模糊、渐变字、侧边色条。
- **Don't** 用三角角标作为休班主标识；禁止 hero 大数字模板。
- **Don't** 在格内用整块红底表示今天（今日条已承担主叙事）。
- **Don't** 每个格子堆三行文字造成糊墙。
