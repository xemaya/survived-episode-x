# Asset Specs — System: Main Menu, Pause & Settings UI

> **Source**: design/gdd/main-menu-pause-settings-ui.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 14 assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Coverage: Main Menu (4 入口 + 档案柜满 tooltip) + Pause "摸鱼中" 浮层 + Settings 子屏 (4 分组: 声音环境/工作语言/操作习惯/阅读密度) + Remap 子屏. Pillar 4 守门: 零 SFX, settings 不影响 AP/KPI.

---

## ASSET-093 — Main Menu Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px |
| Format | PNG |
| Naming | `ui_mainmenu_bg_1920x1080.png` |

**Visual Description**:
Static background — empty office before 9 AM (per art-bible §2.1: 清晨 6:58, fluorescent half-on, no people, single coffee cup on desk). Color palette: `#C8C4B8` (cold white CanvasModulate base from Lighting GDD Rule 1 MAIN_MENU). Composition: 2.5D side view of player workstation in foreground, blurred cubicles receding. Title text "活过第 X 集" rendered in 站酷快乐体 (HR 公文宋 alternative) at 32 px in `#2A1F14`. Subtitle in 14 px caption.

**Art Bible Anchors**:
- §2.1 主菜单清晨 6:58
- §4.1 World palette
- §7.2 字体层级 32 px 标题

**Generation Prompt**:
`1920x1080 pixel art main menu background, empty office at 6:58 AM, cold-white tone #C8C4B8 base, 2.5D side view player workstation foreground, blurred cubicles receding, single coffee cup detail on desk, fluorescent ceiling tubes half-lit, SFC pixel art subdued NOT epic, no characters present`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-094 — Main Menu Button (4 entries — 继续上班 / 入职新员工 / 查阅人事档案 / 下班)

| Field | Value |
|-------|-------|
| Category | UI |
| Source | ASSET-049 (cross-reference, scaled) |

**Visual Description**:
Reuses ASSET-049 button states scaled to 200×40 px. 4 buttons vertically stacked at center-right of main menu.
- "继续上班" (Continue Run): standard / disabled if no save
- "入职新员工" (New Run): standard / disabled if archive cap reached
- "查阅人事档案" (Archive)
- "下班" (Quit)

Each carries focus ring per art-bible §7.5 老板金 `#C8963C` 2 px outer.

**Status**: Cross-reference (use ASSET-049 scaled)
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-095 — Pause Overlay Background ("摸鱼中" frame)

| Field | Value |
|-------|-------|
| Category | UI (modal) |
| Dimensions | 480×320 px (centered) |
| Format | PNG (9-slice) |
| Naming | `ui_pause_overlay_bg_480x320.png` |

**Visual Description**:
Pause overlay frame. Background `#1A2A38` 90% alpha (per art-bible §4.4 系统提示). 2 px outer border `#2A1F14`. Title region top 48 px `#5A4838` archive brown with title "摸鱼中" (站酷快乐体 24 px, `#E8E0CC`). Below: 3 vertical buttons (ASSET-049 cross-ref). Bottom 16 px reserved for hotkey hints (8 px font).

Background blur of underlying scene (OQ-MM-1 — Godot `BackBufferCopy + ShaderMaterial`) handled programmatically, not as an asset here.

**Art Bible Anchors**:
- §4.4 系统提示 `#1A2A38`
- §3.3 UI 0 圆角 1 px 边框
- Pillar 4: "摸鱼中" 反讽: 不写"暂停"

**Generation Prompt**:
`480x320 pixel art pause overlay frame, dark blue-gray #1A2A38 base 90% alpha, 2px dark border #2A1F14, archive brown title strip top "摸鱼中" in pixel chinese title font, 3 button slots vertical center, hotkey hint zone bottom, SFC pixel art understated bureaucratic`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-096 — Settings Screen Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px |
| Format | PNG |
| Naming | `ui_settings_bg_1920x1080.png` |

**Visual Description**:
Per Rule 4: 固定中性灰浮层. Solid `#3A3050` deep blue-gray (matches KPI Review for visual consistency between system screens). 4 group panel zones laid out in 2×2 grid centered. Each group panel uses ASSET-097 frame.

**Art Bible Anchors**:
- §4.4 系统提示 derivative
- §7.1 系统屏 = screen-space, 不属于世界

**Generation Prompt**:
`1920x1080 pixel art settings screen background, solid deep blue-gray #3A3050 field, 2x2 grid layout zones centered for group panels, SFC pixel art system-screen feel`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-097 — Settings Group Panel Frame (4 groups: 声音环境/工作语言/操作习惯/阅读密度)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×400 px (each) |
| Format | PNG (9-slice) |
| Naming | `ui_settings_group_panel_800x400.png` |

**Visual Description**:
Settings group panel frame. Background `#1A2A38` 80% alpha. 1 px border `#2A1F14`. Title strip top 32 px `#5A4838` archive brown with group label (公文宋 18 px, `#E8E0CC`). Body area below for controls. 4 panels labeled: 声音环境 / 工作语言 / 操作习惯 / 阅读密度.

**Art Bible Anchors**:
- §4.4 系统提示
- §3.3 UI 0 圆角

**Generation Prompt**:
`800x400 pixel art settings group panel 9-slice frame, dark blue-gray #1A2A38 base 80% alpha, 1px dark border, archive brown title strip top with chinese pixel font label, body area for controls, SFC pixel art 4 instances will share this frame`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-098 — Volume Knob/Slider Sprite (audio settings)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 240×32 px (slider) |
| Format | PNG (3-piece: track / fill / handle) |
| Naming | `ui_settings_volume_slider_240x32.png` |

**Visual Description**:
Horizontal slider for volume control. Track: 240×4 px `#5A4838`. Fill: variable width `#7A6858`. Handle: 16×16 px `#C8963C` (老板金 — focus / interaction is "power") with 1 px `#2A1F14` border. Step indicator: optional 24 dB tick marks `#5A4838` 1 px lines.

3 sliders per Audio Manager GDD (SFX / Music / Ambient — Master not exposed).

**Art Bible Anchors**:
- §4.4 老板金 focus
- §3.3 UI 0 圆角 1 px 边框
- §7.5 Gamepad navigable: handle is focusable

**Generation Prompt**:
`240x32 pixel art horizontal volume slider, 4px track archive brown #5A4838, variable fill #7A6858, 16x16 handle gold-amber #C8963C with 1px dark border, optional tick marks SFC pixel art clean, transparent background`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui, audio-manager (settings UI integration)

---

## ASSET-099 — Locale Selector Dropdown (zh_CN / en, MVP zh_CN only)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 240×32 px |
| Format | PNG (closed + dropdown extension 240×96 px) |
| Naming | `ui_settings_locale_selector_240x32.png` |

**Visual Description**:
Locale dropdown. Closed state: 240×32 button-style with current locale label and ▼ glyph. Open state: drops down 64 px below showing 2 entries (zh_CN selected highlighted `#5A7080`, en grayed for VS scope). NO flag icons (per art-bible — flags can leak political tone).

**Art Bible Anchors**:
- §3.3 UI 0 圆角
- §4.5 色盲: highlight via fill not color hue alone

**Generation Prompt**:
`240x32 pixel art locale selector dropdown, slate blue button #5A7080 with chinese label and down arrow glyph, dropdown extension 240x64 below shows 2 entries, currently-selected highlighted, secondary entry grayed, NO flag icons, SFC pixel art`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-100 — Narrative Density Toggle (long / flash / numeric_only)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 240×32 px (3-state toggle bar) |
| Format | PNG |
| Naming | `ui_settings_density_toggle_240x32.png` |

**Visual Description**:
3-segment toggle bar for narrative density. Each segment 80×32 px. Selected segment: `#5A7080` fill + 1 px `#C8963C` outline. Unselected: `#3A3050` fill. Labels: "完整" / "简短" / "数字" (Localization keys, not hardcoded). NO "Best" / "Recommended" indicator.

**Art Bible Anchors**:
- §4.4 UI palette
- Pillar 1: 不评判玩家选择

**Generation Prompt**:
`240x32 pixel art 3-segment narrative density toggle bar, slate blue selected segment with gold outline, deep blue-gray unselected segments, chinese labels "完整 简短 数字", NO best-marker NO recommended-star, SFC pixel art`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui, event-script-engine

---

## ASSET-101 — Remap Screen Background

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px |
| Format | PNG |
| Naming | `ui_remap_bg_1920x1080.png` |

**Visual Description**:
Sub-screen of Settings 操作习惯 group, expanded to full-screen list. Background reuses ASSET-096. Center area shows scrollable list of `act_*` keymap rows.

**Status**: Reuse ASSET-096
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-102 — Keymap Row Sprite (single mapping row)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×40 px |
| Format | PNG (9-slice) |
| Naming | `ui_remap_row_800x40.png` |

**Visual Description**:
Single keymap row. Layout:
- Left 50%: HR-tone label of `act_*` action (e.g., "确认" rather than "act_confirm")
- Right 50%: current key binding shown as keyboard-key sprite (boxed with key name)
- On hover: row tint `#2A3A48`
- On focus: 1 px `#C8963C` outer ring (per §7.5)
- Waiting-input state: 1 px `#F5C400` (UI 警告黄) outline + animated dot indicator
- Unbound state: red `#C83428` "未绑定" tag in right column

**Art Bible Anchors**:
- §4.4 UI palette + 警告黄
- §4.5 色盲: red `#C83428` reserved for destructive/critical states; here used for unbound (semantically "broken" not "warning")

**Generation Prompt**:
`800x40 pixel art keymap row 9-slice, dark blue-gray base, left half chinese HR-tone action label, right half boxed key binding indicator, hover tint, focus gold-amber outer ring, waiting-input warning yellow #F5C400 outline, unbound state red #C83428 "未绑定" tag, SFC pixel art`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-103 — Keyboard Key Sprite Atlas (small key glyph sprites)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 32×24 px × ~50 keys atlas |
| Format | PNG |
| Naming | `ui_keyboard_keys_atlas_32x24.png` |

**Visual Description**:
Atlas of keyboard key visualizations. Each key: rounded-corner-FREE rectangle (per §3.3 0 圆角) with 1 px `#2A1F14` border, body `#5A7080`, key label centered (8 px font). Includes alpha keys, numbers, modifiers (Ctrl/Shift/Alt), arrows, function keys, special (Esc/Tab/Space/Enter).

**Art Bible Anchors**:
- §3.3 UI 0 圆角

**Generation Prompt**:
`32x24 pixel art keyboard key sprite atlas approximately 50 keys, rounded-corner-FREE rectangle SFC style, slate blue body #5A7080, 1px dark border, 8px font key labels, includes alpha digits modifiers arrows function-keys special-keys, SFC pixel art clean readable`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-104 — Reset to Defaults Button

| Field | Value |
|-------|-------|
| Category | UI |
| Source | ASSET-049 (cross-reference) |

**Visual Description**:
Standard choice button labeled "恢复默认". Reuses ASSET-049 4-state.

**Status**: Cross-reference (use ASSET-049)
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-105 — Confirm Quit Dialog (下班 / 退出确认)

| Field | Value |
|-------|-------|
| Category | UI (modal) |
| Dimensions | 480×200 px |
| Format | PNG (9-slice) |
| Naming | `ui_confirm_quit_dialog_480x200.png` |

**Visual Description**:
Quit confirmation modal. Same frame as ASSET-086 archive-delete dialog. Title: "确认下班?" (HR 口吻). 2 buttons (cancel / confirm). NO red on confirm (this is benign exit, not destructive).

**Status**: Reuse ASSET-086 frame, different button modulate
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-106 — Tooltip Sprite (Archive cap tooltip + locked button hint)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 240×40 px (auto-fit) |
| Format | PNG (9-slice) |
| Naming | `ui_tooltip_240x40.png` |

**Visual Description**:
Standard tooltip frame appearing near disabled buttons. Background `#1A2A38` 90% alpha, 1 px `#2A1F14` border, 4 px tail pointing toward host element. Text 12 px `#E8E0CC`.

**Art Bible Anchors**:
- §4.4 系统提示
- §7.4 不弹性 (instant fade-in 1 frame)

**Generation Prompt**:
`240x40 pixel art tooltip 9-slice, dark blue-gray #1A2A38 base 90% alpha, 1px dark border, 4px directional tail bottom, 12px text area cream #E8E0CC, SFC pixel art subtle`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui

---

## ASSET-107 — Settings Group Icon Stamps (4 icons: speaker / globe / keyboard / book)

| Field | Value |
|-------|-------|
| Category | UI Icon |
| Dimensions | 24×24 px × 4 |
| Format | PNG (atlas) |
| Naming | `ui_settings_group_icons_atlas_24x24.png` |

**Visual Description**:
Pixel-stamp icons for 4 settings groups (per art-bible §7.3):
- 声音环境: speaker glyph
- 工作语言: simple globe / "文" character
- 操作习惯: keyboard glyph
- 阅读密度: book / paper glyph

All `#5A4838` archive brown stamps, no color decorations.

**Art Bible Anchors**:
- §7.3 像素图章 24×24

**Generation Prompt**:
`24x24 pixel art settings group icon atlas 4 icons, archive brown #5A4838 pixel stamp style, speaker, globe (or chinese 文 character), keyboard, book paper, SFC pixel art clean stamps, transparent background, indexed palette 2 colors`

**Status**: Needed
**Referenced by**: main-menu-pause-settings-ui
