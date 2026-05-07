# Asset Specs — System: Daily/Weekly Recap UI

> **Source**: design/gdd/daily-weekly-recap-ui.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 12 assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Coverage: Daily Recap 屏 (顶部 HR 标头 / AP 用度 + 精力 + 加班 / 今日事件列表) + Weekly Recap 屏 (周标 / effort 三维度 / KPI 参考区间 / 一周事件列表) + effort 三维度 visualization. **零庆祝动画 / 单色冷调蓝灰** per Rule.

---

## ASSET-113 — Daily Recap Screen Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px |
| Format | PNG |
| Naming | `ui_daily_recap_bg_1920x1080.png` |

**Visual Description**:
Daily Recap full-screen. Background `#1A2A3A` 数据屏蓝灰 (locked by Lighting GDD Rule 1 for DAILY_RECAP sub-mode). Subtle 16 px grid pattern overlay (1 px `#2A1F14` lines, alpha 20%). Top: HR header strip 64 px tall, `#5A4838` archive brown, with date label. Body area takes remaining space. Bottom: skip hint strip 32 px.

**Art Bible Anchors**:
- §2.5 今日 / 周五总结
- §4.4 系统提示 derivative
- §7.1 Daily Recap 是 screen-space (系统级)

**Generation Prompt**:
`1920x1080 pixel art daily recap screen background, blue-gray data-screen tone #1A2A3A, subtle 16px grid pattern overlay 20% alpha, archive brown HR header strip top 64px with date label area, body area below, skip hint strip bottom 32px, SFC pixel art bureaucratic ledger feel NOT celebratory`

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-114 — Weekly Recap Screen Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px |
| Format | PNG |
| Naming | `ui_weekly_recap_bg_1920x1080.png` |

**Visual Description**:
Same overall structure as ASSET-113, but with subtle calendar visual hint top-left (8×8 px calendar icon and "第 X 周" label). Body area pre-divided into 4 zones: effort 三维度 / KPI 参考 / 一周事件列表 / skip hint.

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-115 — HR Header Strip (date / week label)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 1920×64 px |
| Format | PNG (9-slice) |
| Naming | `ui_recap_hr_header_1920x64.png` |

**Visual Description**:
Top header strip used by both daily and weekly recap. `#5A4838` archive brown background with 1 px `#2A1F14` bottom border. Text rendered in 公文宋 (HR 官方感) at 18 px. Format examples: "第 12 天 / 周三 - 月报后第 5 个工作日" or "第 W3 周 / 月 2 - 摘要".

**Art Bible Anchors**:
- §7.2 字体层级 公文宋 18 px
- §4.1 档案棕

**Generation Prompt**:
`1920x64 pixel art HR header strip, archive brown #5A4838 base, 1px dark border bottom, designed for chinese 公文宋 18px date label text overlay, SFC pixel art bureaucratic`

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-116 — Effort Three-Dimension Visualization Component

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×120 px (3 stacked rows × 40 px) |
| Format | PNG (9-slice frame + label sprites) |
| Naming | `ui_recap_effort_threedim_800x120.png` |

**Visual Description**:
Three rows, each visualizing one effort dimension (overtime / hero / overage):
- Row 1: "本周加班记录" + numeric value (right-aligned)
- Row 2: "潜力贡献" + numeric value
- Row 3: "工龄系数" + numeric value (or "—" if M1)

NO progress bar, NO chart, NO percentage gauge. Pure number-with-label rows. Background `#1A2A38`, 1 px `#5A4838` row dividers.

**Art Bible Anchors**:
- Pillar 1: 数字克制 — 禁 ProgressBar
- §4.4 系统提示

**Generation Prompt**:
`800x120 pixel art effort 3-dimension visualization frame, dark blue-gray #1A2A38 base, 3 horizontal rows each 40px tall with archive brown dividers, NO progress bars NO charts, designed for HR-tone label left + numeric value right, SFC pixel art bureaucratic ledger`

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-117 — Event List Row (single event entry, ≤ 8 per recap)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×32 px |
| Format | PNG (9-slice) |
| Naming | `ui_recap_event_row_800x32.png` |

**Visual Description**:
Single event entry in event list. Format `"[date] · [event title]"` for weekly, `"[event title] · [numeric outcome]"` for daily. All text gray `#999999` (no color encoding). 1 px `#5A4838` bottom divider. Hover: subtle `#2A3A48` tint. NO icons, NO badges.

**Art Bible Anchors**:
- §4.5 色盲: gray-only encoding
- Rule 5 数字克制

**Generation Prompt**:
`800x32 pixel art event list row 9-slice, dark blue-gray base, gray text #999999, archive brown 1px bottom divider, hover tint state, NO icons NO badges, SFC pixel art ledger entry`

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-118 — KPI Prediction Reference Strip

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×32 px |
| Format | PNG |
| Naming | `ui_recap_kpi_pred_strip_800x32.png` |

**Visual Description**:
Single line showing KPI reference: `"本周 KPI 参考区间: 195 - 225"` (numeric range). Text in 11 px (art-bible §7.2 minimum CJK readable). Gray text on `#1A2A38` base. Visible only on weekly recap if `kpi_prediction_hint` available; else "待月末结算" placeholder.

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-119 — Skip Hint Strip ("按任意键继续" — 主语翻转守门)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 1920×32 px |
| Format | PNG |
| Naming | `ui_recap_skip_hint_1920x32.png` |

**Visual Description**:
Bottom skip hint strip. Background `#1A2A38` 50% alpha. Text 12 px `#999999`. Per Rule G-549 守门: 不写"跳过"二字 — phrasing is "按任意键继续" (Localization key handles this). Subtle 1 px top border `#5A4838`.

**Art Bible Anchors**:
- §7.4 UI feel: 不弹性

**Generation Prompt**:
`1920x32 pixel art bottom skip hint strip, semi-transparent dark blue-gray base 50% alpha, gray text #999999 12px chinese pixel font area, 1px archive brown top border, SFC pixel art subtle`

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui, kpi-review-game-over-ui

---

## ASSET-120 — Daily Recap Body Container Frame

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 1024×800 px |
| Format | PNG (9-slice) |
| Naming | `ui_daily_recap_body_1024x800.png` |

**Visual Description**:
Body container for Daily Recap. Background `#1A2A38` 80% alpha, 1 px `#2A1F14` border. Internal padding 16 px. 4 vertical zones with 1 px `#5A4838` dividers: header + AP/energy + event list + footer.

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-121 — Weekly Recap Body Container Frame

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 1024×800 px |
| Format | PNG (9-slice) |
| Naming | `ui_weekly_recap_body_1024x800.png` |

**Visual Description**:
Same dimensions as ASSET-120 but pre-divided into 5 zones (header / effort 三维度 / KPI 预测 / event list / footer).

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-122 — Recap Fade-In Animation Frames

| Field | Value |
|-------|-------|
| Category | UI (animation) |
| Dimensions | overlay alpha tween (no asset, programmatic) |
| Format | tween config |
| Naming | (constant in `daily_weekly_recap_ui.gd`) |

**Visual Description**:
Per Rule 5 视觉 Context: 文字 fade-in ≤ 200 ms; 逐行延迟 30 ms 呈现. Programmatic, no static asset.

**Status**: Needed (programmatic)
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-123 — AP/Energy Daily Summary Row Sprite

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×40 px |
| Format | PNG |
| Naming | `ui_daily_apenergy_row_800x40.png` |

**Visual Description**:
Daily summary row showing AP usage and energy levels. Format: "今日额度: 8 / 8 (+2 加班)" + "咖啡剩余: 3/4 杯". 16 px font HR-tone labels. NO progress bars, NO icons.

**Art Bible Anchors**:
- Pillar 1 + 主语翻转: "额度" not "你的 AP"; "咖啡" not "精力"

**Generation Prompt**:
`800x40 pixel art AP and energy daily summary row, dark blue-gray base, gray text label area, NO progress bar NO icon, designed for chinese pixel font HR-tone label rendering, SFC pixel art bureaucratic`

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui

---

## ASSET-124 — Recap Calendar Mini Glyph (week indicator)

| Field | Value |
|-------|-------|
| Category | UI Icon |
| Dimensions | 8×8 px |
| Format | PNG |
| Naming | `ui_recap_calendar_glyph_8x8.png` |

**Visual Description**:
Tiny calendar pixel-stamp used in weekly recap header. `#5A4838` archive brown 4×4 grid pattern with 1 px outline. Subtle, decoration only.

**Art Bible Anchors**:
- §7.3 像素图章
- §6.3 道具尺寸 4×4 / 8×8

**Generation Prompt**:
`8x8 pixel art tiny calendar icon, archive brown #5A4838 4x4 grid pattern with 1px outline, SFC pixel stamp style, transparent background`

**Status**: Needed
**Referenced by**: daily-weekly-recap-ui
