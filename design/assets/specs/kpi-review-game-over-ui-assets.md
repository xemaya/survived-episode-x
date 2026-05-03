# Asset Specs — System: KPI Review & Game Over UI

> **Source**: design/gdd/kpi-review-game-over-ui.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 16 assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Coverage: KPI Review screen (绩效面板 + breakdown 三行 + capacity_now 数字对比) + GAMEOVER 离职证明 transition (1500ms linear) + Archive 列表屏 (200 cap) + 三屏 共用 frame.

---

## ASSET-077 — KPI Review Screen Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px (covers full screen) |
| Format | PNG (9-slice or solid base + ornament sprites) |
| Naming | `ui_kpi_review_bg_1920x1080.png` |

**Visual Description**:
Full-screen background for KPI Review. Base color `#3A3050` (深蓝灰, art-bible §2.6). Subtle 8 px office-cubicle grid pattern overlay (1 px `#2A1F14` lines, alpha 30%). At top center: 16×8 px "公司 logo" stamp `#5A4838` (suggesting a corporate insignia, never a hero brand). At bottom: 4 px wide red `#E03020` (片尾曲红) hairline — only visible if game-over imminent.

**Art Bible Anchors**:
- §2.6 月末考核 → GAME OVER 仪式感尘埃落定
- §4.1 深蓝灰 `#3A3050`
- §4.6 片尾曲红 `#E03020` ≤ 8% (仅 GAME OVER 显)
- §6.4 环境叙事: corporate insignia 第一眼可见

**Generation Prompt**:
`1920x1080 pixel art KPI review screen background, deep blue-gray #3A3050 base, subtle 8px office cubicle grid pattern overlay 30% alpha dark lines, small corporate logo stamp top center 16x8px archive brown #5A4838, optional thin red hairline #E03020 at bottom only when gameover imminent, SFC pixel art ceremonial somber tone NOT celebratory`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-078 — KPI Breakdown Three-Row Panel Frame

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×240 px (centered, 3 rows × 80 px) |
| Format | PNG (9-slice) |
| Naming | `ui_kpi_breakdown_panel_800x240.png` |

**Visual Description**:
Panel containing the 3 HR-breakdown lines (effort_contrib_pct / potential_contrib_pct / tenure_contrib_pct). Row separator 1 px `#5A4838` lines. Each row: left half = HR-tone label (中文 14 px font); right half = number (思源黑体 18 px in `#E8E0CC`). Background `#1A2A38` (系统提示背景 — emphasises bureaucratic判决). 1 px outer border `#2A1F14`.

**Art Bible Anchors**:
- §4.4 系统提示 `#1A2A38`
- §7.2 字体层级: 标题 14 / 正文 18 px
- §7.4 官僚式迟钝: 行间距宽，无装饰

**Generation Prompt**:
`800x240 pixel art KPI breakdown panel 9-slice, dark blue-gray #1A2A38 background, 1px dark border #2A1F14, 3 horizontal row dividers archive brown #5A4838, designed for 3 rows of HR-breakdown text rendering, SFC pixel art bureaucratic feel`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-079 — KPI Capacity vs Threshold Number Display

| Field | Value |
|-------|-------|
| Category | UI (text frame) |
| Dimensions | 480×48 px |
| Format | PNG (background frame) |
| Naming | `ui_kpi_capacity_compare_480x48.png` |

**Visual Description**:
Bottom panel showing `产能余量: 212 → 240` style comparison. Background `#1A2A38` slightly more transparent (alpha 80%). Single line of text, all gray `#999999` (per Rule 4: never red). Arrow `→` is 8×8 px sprite or font glyph. NO progress bar. NO "warning" pill.

**Art Bible Anchors**:
- §4.5 色盲安全: gray-only (no red), rely on numeric position
- Pillar 1 守门: 数字克制，不评判

**Generation Prompt**:
`480x48 pixel art capacity-vs-threshold comparison panel, semi-transparent dark frame, gray text only #999999, simple arrow glyph, NO red, NO progress bar, NO warning icon, SFC pixel art understated`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-080 — GAMEOVER Termination Certificate Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px |
| Format | PNG (composite layered) |
| Naming | `ui_gameover_certificate_bg_1920x1080.png` |

**Visual Description**:
Full-screen "离职证明" (termination certificate). Paper background centered (800×600 px) on `#3A3050` deep blue-gray field. Paper itself is `#E8E0CC` 白炽灯白 with 4 px archive brown `#7A5838` border. Top: corporate header (8 px font, archive brown). Center: "离职证明" title (站酷快乐体 18 px, `#2A1F14`). Below: termination reason text area (16 px font, `#2A1F14`). Bottom: red `#E03020` ironic stamp "恭喜晋升" (片尾曲红, 24 px font tilted 5°). The stamp has 1 px border within the stamp boundary (per art-bible §4.5 #2 stamps need double-border).

**Art Bible Anchors**:
- §2.6 GAME OVER 片尾曲
- §4.6 片尾曲红 ≤ 8% (≤ stamp size)
- §4.5 印章双线描边
- §5.1 GAMEOVER.TITLE_IRONY 反讽 anchor

**Generation Prompt**:
`1920x1080 pixel art termination certificate full-screen background, deep blue-gray field #3A3050, central paper certificate 800x600 cream-white #E8E0CC with 4px archive brown border #7A5838, corporate header text top, "离职证明" title center, body text area, red ironic stamp "恭喜晋升" bottom-right tilted 5deg with 1px inner border per art bible double-line stamp rule, SFC pixel art ceremonial bureaucratic somber NOT celebratory`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui (GAMEOVER_TRANSITION state)

---

## ASSET-081 — Termination Stamp Sprite (red ironic stamp "恭喜晋升")

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 96×48 px |
| Format | PNG |
| Naming | `ui_gameover_irony_stamp_96x48.png` |

**Visual Description**:
The red corporate stamp. `#E03020` (片尾曲红) text "恭喜晋升" with 2 px double-line border (art-bible §4.5 #2). Stamp shape is rounded-corner rectangle (slight irregularity per stamp aesthetic). Tilted 5° as part of the certificate (separate from background to enable single-frame appearance animation).

**Art Bible Anchors**:
- §4.5 印章双线描边 + 汉字图案
- §4.6 片尾曲红 GAME OVER only
- §3.2 几何明确，零亚像素

**Generation Prompt**:
`96x48 pixel art ironic red corporate stamp "恭喜晋升", #E03020 background, 2px double-line border per art bible §4.5, slight tilt 5deg, SFC pixel art with deliberate stamp imperfection (slight smudge), indexed palette 3 colors, transparent background`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-082 — KPI Review Confirm Button (Skip / Continue)

| Field | Value |
|-------|-------|
| Category | UI |
| Source | ASSET-049 (cross-reference) |

**Visual Description**:
Reference to ASSET-049 (Choice button 4 states). KPI Review screen confirm/dismiss button reuses standard choice button.

**Status**: Cross-reference (use ASSET-049)
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-083 — Archive List Row Sprite Frame

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 1024×48 px |
| Format | PNG (9-slice) |
| Naming | `ui_archive_row_1024x48.png` |

**Visual Description**:
Single row in archive list. Format: `"#0011 · M11 · 资深员工的责任 · (KPI 超限)"`. Background `#1A2A38` 80% alpha base, 1 px `#5A4838` divider bottom edge. On hover: `#2A3A48` (slightly brighter). On focus: 1 px `#C8963C` (老板金) outer border. Selected state: `#3A2030` (subtle red-ish tint).

**Art Bible Anchors**:
- §3.3 UI 0 圆角
- §4.4 hover/focus palette
- §7.5 Gamepad focus 老板金

**Generation Prompt**:
`1024x48 pixel art archive list row 9-slice, dark blue-gray #1A2A38 base, 1px archive brown divider #5A4838 bottom, hover state #2A3A48 brighter, focus state with 1px gold-amber #C8963C outer border, selected state subtle red-tint #3A2030, SFC pixel art`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui (Archive screen)

---

## ASSET-084 — Archive Screen Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px |
| Format | PNG |
| Naming | `ui_archive_bg_1920x1080.png` |

**Visual Description**:
Filing cabinet aesthetic. Background `#3A3050` deep blue-gray. Top header strip 64 px tall, `#5A4838` archive brown, with title "人事档案" (站酷快乐体 24 px, `#E8E0CC`). Below: list scrollable area takes remaining height. Right edge: subtle drop shadow suggesting filing cabinet depth (4 px gradient `#2A1F14` 30% alpha).

**Art Bible Anchors**:
- §6.4 #1 卷王干净 ↔ §3.1 反讽哲学
- §4.1 档案棕

**Generation Prompt**:
`1920x1080 pixel art archive screen background filing cabinet aesthetic, deep blue-gray field #3A3050, archive-brown top header strip #5A4838 with title text "人事档案", subtle drop shadow right edge, SFC pixel art bureaucratic`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-085 — Archive Cap-Reached Notice Banner (200 cap)

| Field | Value |
|-------|-------|
| Category | UI (banner) |
| Dimensions | 800×24 px |
| Format | PNG |
| Naming | `ui_archive_cap_banner_800x24.png` |

**Visual Description**:
Top-pinned notice when `archive_count >= 200`. Background `#5A4838` archive brown, text gray `#999999` (NOT red — per Rule 7 守门). 1 px `#2A1F14` border. Single line: "档案柜已满" (site uses Localization key `ARCHIVE.CAP_REACHED`).

**Art Bible Anchors**:
- §4.5 色盲安全: gray notice not red
- Pillar 1: 数字克制不评判

**Generation Prompt**:
`800x24 pixel art top-pinned archive-full notice banner, archive brown #5A4838 background, gray text #999999, 1px dark border #2A1F14, deliberately not-red, SFC pixel art subtle`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-086 — Archive Delete Confirm Dialog

| Field | Value |
|-------|-------|
| Category | UI (modal) |
| Dimensions | 480×200 px |
| Format | PNG (9-slice + sprite) |
| Naming | `ui_archive_delete_dialog_480x200.png` |

**Visual Description**:
Modal confirm dialog for archive entry deletion. Background `#1A2A38` 90% alpha, 2 px border `#2A1F14`. Title strip top 32 px `#5A4838`. Two buttons (cancel left, confirm right) using ASSET-049. Confirm button uses red modulate `#C83428` for delete safety (this is one place where world-warning red is acceptable per Rule 7 destructive action).

**Art Bible Anchors**:
- §4.4 系统提示 dark
- §4.2 红 = 警告 / 行动 destructive

**Generation Prompt**:
`480x200 pixel art archive delete confirmation modal dialog, dark blue-gray #1A2A38 90% opacity, 2px dark border, archive brown title strip top, two buttons (cancel and confirm) layout, confirm button red-tinted #C83428, SFC pixel art bureaucratic destructive-safe pattern`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-087 — KPI Review Transition Fade Overlay

| Field | Value |
|-------|-------|
| Category | UI (overlay) |
| Dimensions | 1920×1080 px |
| Format | PNG |
| Naming | `ui_kpi_transition_fade_1920x1080.png` |

**Visual Description**:
Linear fade overlay used during 1500 ms GAMEOVER transition (Rule 5). Fades from `#3A3050` 0% alpha to `#3A3050` 100% alpha over duration. NO ease — strictly `TRANS_LINEAR`. Single solid color rect.

**Art Bible Anchors**:
- §8.6 CanvasModulate Tween (此处 ColorRect alpha tween 同原则 linear-only)

**Generation Prompt**:
N/A — solid color rect, programmatic.

**Status**: Needed (programmatic)
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-088 — Settlement Locked State Indicator (visual cue)

| Field | Value |
|-------|-------|
| Category | UI (icon) |
| Dimensions | 16×16 px |
| Format | PNG |
| Naming | `ui_settlement_locked_16x16.png` |

**Visual Description**:
Tiny lock icon shown when `settlement_locked == true` (Rule 5). `#5A4838` archive brown padlock pixel-stamp style. Indicates "no further input accepted". Appears in corner of GAMEOVER UI.

**Art Bible Anchors**:
- §7.3 像素图章
- §3.3 UI 0 圆角

**Generation Prompt**:
`16x16 pixel art tiny padlock icon, archive brown #5A4838, simple pixel stamp style, SFC pixel art, transparent background, indexed palette 2 colors`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-089 — Run Summary Detail Panel (VS expansion)

| Field | Value |
|-------|-------|
| Category | UI (VS scope) |
| Dimensions | 1024×600 px |
| Format | PNG (9-slice frame) |
| Naming | `ui_archive_runsummary_detail_1024x600.png` |

**Visual Description**:
**VS scope.** Expanded detail view of a RunSummary entry, showing `actual_kpi_history` line graph + 8 NPC final scores + `unlocks_earned_this_run`. MVP: spec only, not implemented. Layout: 4 panels (KPI history top-left, NPC scores top-right, unlocks bottom-left, run metadata bottom-right).

**Status**: Deferred (VS scope)
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-090 — KPI Review Skippable Indicator

| Field | Value |
|-------|-------|
| Category | UI (icon) |
| Dimensions | 24×24 px |
| Format | PNG |
| Naming | `ui_kpi_skippable_24x24.png` |

**Visual Description**:
Bottom-corner "按任意键继续" indicator. ASSET-057 cross-ref idea. New larger sprite specifically for KPI Review (not card dialogue). 2-frame slow blink.

**Art Bible Anchors**:
- §7.4 1-2 帧 UI 切换

**Generation Prompt**:
`24x24 pixel art skippable continue indicator 2 frames slow blink, cream-white #E8E0CC text glyph (right arrow), SFC pixel art subtle, transparent background`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-091 — HR Word Library Submenu Frame

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×600 px |
| Format | PNG (9-slice) |
| Naming | `ui_archive_hr_wordlib_800x600.png` |

**Visual Description**:
Submenu in Archive showing collected HR phrases (Rule 8). 4-column grid layout for phrase tags. Each tag is 80×24 px capsule with collected/locked states. Background `#1A2A38`. Locked tags show as gray `#5A4838` outline only.

**Art Bible Anchors**:
- §3.3 UI 0 圆角
- §4.5 色盲: locked vs collected via outline + saturation

**Generation Prompt**:
`800x600 pixel art HR phrase word library submenu frame, dark blue-gray #1A2A38 base, 4-column grid of 80x24 phrase tags, collected tags filled archive brown, locked tags outline-only gray, SFC pixel art bureaucratic catalog feel`

**Status**: Needed
**Referenced by**: kpi-review-game-over-ui

---

## ASSET-092 — KPI Review Three-Track Anchor SFX (cross-reference)

| Field | Value |
|-------|-------|
| Source | scene-day-flow-controller-assets.md (specced separately) |

**Status**: Cross-reference (specced in scene-day-flow-controller spec)
**Referenced by**: kpi-review-game-over-ui (Rule 5 三轨 race)
