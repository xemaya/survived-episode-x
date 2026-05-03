# Asset Specs — System: Card Play & Dialogue UI

> **Source**: design/gdd/card-play-dialogue-ui.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 24 assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Coverage: NPC 立绘 (8 NPCs × 2 emotions = 16 CG @ 128×192 + 8 互动特写 @ 64×96) + 卡片底版/正面/选中态 + 对白 frame + AP 格子 + 选项按钮四态. **OQ-CPU-01 风险**: art-bible §5.5 single-dev 3-month limit is 16 张/NPC; this system needs 2-3 高规格 portraits/NPC. Producer must validate scope.

---

## ASSET-041 — NPC Event CG Portrait (8 NPCs × 2 emotions = 16 portraits)

| Field | Value |
|-------|-------|
| Category | Sprite (CG) |
| Dimensions | 128×192 px each |
| Format | PNG (independent files, NOT atlas — too large per art-bible §8.1) |
| Naming | `npc_[npcid]_cg_[emotion]_128x192.png` |
| Texture Res | LOD 2 (full detail) per art-bible §5.4 |

**Visual Description**:
Full-body 半身特写 used during `long` event dialogue. 8 NPCs (overworker / slacker / sycophant / newbie / oldhand / cleaner / boss / HR — see art-bible §5.2) × 2 emotional states each = 16 unique CGs. Each must preserve the NPC's silhouette signature (boss tall +8 px, cleaner short+wide, etc.) AND render the 喜丧触发 visual cue (e.g. boss's "笑容残影留 2 帧" anchor). Background is transparent — composites over dialogue scene.

Default emotion variants:
- Calm/working (default for ACTIVE phase)
- 喜丧触发 (per archetype's specific trigger from §5.2)

**Art Bible Anchors**:
- §5.2 NPC 9 prototypes (player excluded → 8 NPCs)
- §5.4 LOD 2 — 128×192 px CG hard cap
- §5.5 单人 3 月产量上限 16 张/NPC — **OQ-CPU-01 RISK**: 2 emotions × 8 NPC = 16 portraits is 1 张/NPC budget, leaves no room for poses
- §3.1 silhouette philosophy
- §4.5 色盲安全: rely on shape + tonal contrast not just hue

**Generation Prompt**:
`128x192 pixel art half-body portrait of [archetype] office worker, SFC retro pixel style, [emotion] expression preserving "喜丧触发" cue: [boss's lingering smile after criticizing subordinate / cleaner continuing to mop while seeing collapse / HR's neutral while announcing layoffs / etc], 16-color indexed palette derived from world office palette (打工人黄 #C8A85A, 格子间灰蓝 #5A7080, 档案棕 #7A5838), transparent background, no anti-aliasing, dark humor understated tone NOT cartoon-exaggerated`

**Status**: Needed — **OQ-CPU-01 BLOCKING for asset production scope**
**Referenced by**: card-play-dialogue-ui, kpi-review-game-over-ui (KPI Review uses these CGs for monthly summary)

---

## ASSET-042 — NPC Interactive Portrait (8 NPCs × 1 state = 8 portraits)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 64×96 px |
| Format | PNG |
| Naming | `npc_[npcid]_portrait_active_64x96.png` |
| Texture Res | LOD 1 per art-bible §5.4 |

**Visual Description**:
Smaller 64×96 portrait for speaker zone (upper-left) of dialogue UI. Half-body, neutral working pose. Used as the speaker indicator during `flash` and `long` events. 1 portrait per active NPC; LEFT NPCs do not appear (R-NPC-2 守门).

**Art Bible Anchors**:
- §5.4 LOD 1 互动特写 64×96
- §5.2 silhouette signatures preserved at smaller scale

**Generation Prompt**:
`64x96 pixel art half-body NPC portrait neutral working pose, [archetype identifier], SFC pixel style, 16-color palette, transparent background, slightly more detail than overhead view, suitable for dialogue UI speaker indicator`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui, hud-diegetic (potential VS upgrade for hover detail)

---

## ASSET-043 — Card Background (3 AP cost variants)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 64×96 px × 3 |
| Format | PNG |
| Naming | `ui_card_bg_[1ap/2ap/3ap]_64x96.png` |

**Visual Description**:
Action card backing (handheld card sprite). Three variants for 1-AP / 2-AP / 3-AP cards. Base color `#5A7080` (格子间灰蓝, art-bible §4.4 主按钮底色). 1 px `#2A1F14` border. Top-right corner shows AP cost as filled `#C8A028` PUA 鸡汤金圈 dots (1/2/3 dots). Card body has a subtle `#7A5838` paper texture inset 4 px from edge — like a manila folder. NO sparkle, NO glow.

**Art Bible Anchors**:
- §4.4 UI 调色板 主按钮底色 `#5A7080`
- §3.3 UI 形状语法 0 圆角 1 px 边框
- §4.6 PUA 鸡汤金 ≤ 2% (only for 3 small AP dots)
- Pillar 1 守门: NO highlight on cards regardless of AP cost

**Generation Prompt**:
`64x96 pixel art office action card sprite sheet 3 variants for 1AP 2AP 3AP cost, slate-blue base #5A7080 with 1px dark border #2A1F14, manila folder texture inset, AP cost shown as 1/2/3 small gold-amber dots #C8A028 in top-right, NO highlight NO sparkle NO glow, SFC pixel art, indexed palette 6 colors, transparent background outside card boundary`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-044 — Card Front Face (action card type variants — N from action-card system)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 56×80 px (inset on card background) |
| Format | PNG (atlas) |
| Naming | `ui_card_face_atlas_56x80.png` |

**Visual Description**:
Card face content drawn within ASSET-043. Each card has: card name (16 px font, top), small icon (32×32 px center, art-bible §7.3 像素图章 style), brief description (8 px font, bottom 16 px). NO `kpi_contribution` large numeric display (Pillar 1 G-10=false). MVP card count from action-card-system GDD; specific list and icons are owned by that GDD's Phase 4 spec.

**Art Bible Anchors**:
- §7.3 图标像素图章风格
- §7.2 字体层级
- Pillar 1 G-10: hide numeric KPI contribution from card face

**Generation Prompt**:
`56x80 pixel art card face content layout, top region 16x16 card title in chinese pixel font dark ink #2A1F14, center 32x32 simple icon "stamp" style, bottom region 8px description text, NO numeric values displayed prominently, SFC pixel art, transparent background`

**Status**: Needed (per-card content owned by action-card-system spec)
**Referenced by**: card-play-dialogue-ui, action-card-system

---

## ASSET-045 — Card Selected/Hover State Overlay

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 64×96 px |
| Format | PNG (overlay) |
| Naming | `ui_card_state_focus_64x96.png` |

**Visual Description**:
1 px brighter border (`#7A96A8` per art-bible §4.4 button hover) + 2 px upward translation. NO yellow glow / NO scale animation / NO particle. Hover state lifts the card slightly, focus state adds 1 px outer border (gamepad focus ring).

**Art Bible Anchors**:
- §4.4 hover `#7A96A8`
- §7.5 Gamepad / Focus 态: 1px outer ring
- §7.4 UI 动画 feel: 不要弹性，1-2 帧切换

**Generation Prompt**:
`64x96 pixel art card hover/focus state overlay, 1px brighter slate blue border #7A96A8, optional 1px outer ring for gamepad focus, NO glow effects, NO scale change, NO particles, SFC pixel art, transparent center`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-046 — Card Disabled State Overlay (insufficient AP)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 64×96 px |
| Format | PNG (overlay) |
| Naming | `ui_card_state_disabled_64x96.png` |

**Visual Description**:
50% opacity overlay in `#5A4838` (desaturated archive brown) over ASSET-043. NO tooltip-arrow, NO "insufficient AP" text — just visually muted. Per Pillar 4 守门: card simply reads "not now" through tonality, not error message.

**Art Bible Anchors**:
- §4.5 色盲安全: visual disability via desaturation + position not red overlay

**Generation Prompt**:
`64x96 pixel art card disabled state overlay, 50% opacity desaturated brown #5A4838, NO X mark, NO error icon, NO tooltip arrow, just visually muted card, SFC pixel art, transparent base`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-047 — Dialogue Background Frame (9-slice)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 32×32 px source for 9-slice |
| Format | PNG (`.tres` 9-slice config) |
| Naming | `ui_dialogue_bg_9slice.png` + `ui_dialogue_bg_9slice.tres` |

**Visual Description**:
Dialogue box frame. Background `#1A2A38` (art-bible §4.4 系统提示背景, "屏幕蓝光加深 = 系统 = 囚禁"). Border 1 px `#2A1F14`. Inner padding 4 px. 9-slice corners are 6×6 px, edges stretch. Multiplies world below by 0.85 alpha for "diegetic system" feel.

**Art Bible Anchors**:
- §4.4 系统提示背景 `#1A2A38`
- §3.3 UI 形状: 0 圆角, 1 px 边框
- §7.1 混合 screen-space: multiply 压世界底层

**Generation Prompt**:
`32x32 pixel art dialogue box 9-slice source image, dark blue #1A2A38 background, 1px dark border #2A1F14, designed for tile/stretch in middle, no decorations, SFC pixel art, indexed palette 3 colors`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui, event-script-engine (long event display)

---

## ASSET-048 — Dialogue Speaker Name Plate

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 96×16 px |
| Format | PNG (9-slice extension or fixed) |
| Naming | `ui_dialogue_nameplate_96x16.png` |

**Visual Description**:
Small banner above dialogue box showing speaker name. Background `#5A7080`, 1 px `#2A1F14` border, 12 px font in `#E8E0CC`. Sits attached to top-left of dialogue frame. NO portrait inside this plate (portrait is separate via ASSET-042).

**Art Bible Anchors**:
- §7.2 字体层级
- §4.4 主按钮底色 `#5A7080`

**Generation Prompt**:
`96x16 pixel art dialogue name plate banner, slate blue #5A7080 background, 1px border #2A1F14, cream text color #E8E0CC, simple horizontal banner, SFC pixel art`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-049 — Choice Button Sprites (4 states × 1 button = 4 sprites)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 48×24 px × 4 |
| Format | PNG |
| Naming | `ui_btn_choice_[normal/hover/disabled/focus]_48x24.png` |

**Visual Description**:
Dialogue option button. 4 states per art-bible §3.3 + §7.5:
- normal: `#5A7080` fill, `#2A1F14` border, `#E8E0CC` text
- hover: `#7A96A8` fill (proportionally brighter)
- disabled: `#5A4838` 50% opacity, no text effect
- focus: normal + 1 px outer `#C8963C` (老板金 — focus is power) ring

NO label "Best" / "Recommended" / star icon (Pillar 1 守门).

**Art Bible Anchors**:
- §4.4 UI palette
- §7.5 Gamepad focus 老板金 outer ring
- §3.3 UI 0 圆角

**Generation Prompt**:
`48x24 pixel art dialogue option button sprite sheet 4 states: normal slate blue #5A7080, hover brighter #7A96A8, disabled muted brown #5A4838 with 50% opacity, focus same as normal + 1px gold-amber outer ring #C8963C, 1px dark border, SFC pixel art, indexed palette`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui, event-script-engine, kpi-review-game-over-ui (settings screen)

---

## ASSET-050 — AP Slot Icons (filled / empty 2 variants)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 16×16 px × 2 |
| Format | PNG |
| Naming | `ui_icon_ap_filled_16x16.png` / `ui_icon_ap_empty_16x16.png` |

**Visual Description**:
Small AP marker for card cost display.
- Filled: `#C8A028` PUA 鸡汤暖金圈 dot in 16×16 frame
- Empty: hollow ring of same color, transparent center

NO glow. NO pulse animation. Used both on cards (top-right cost) and as supplementary HUD overlay if needed.

**Art Bible Anchors**:
- §4.6 PUA 鸡汤金 `#C8A028` ≤ 2% budget
- §7.3 像素图章风格 16×16

**Generation Prompt**:
`16x16 pixel art AP slot icon sprite sheet 2 variants, filled gold-amber dot #C8A028, empty hollow ring same color, SFC pixel art clean edges, transparent background`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-051 — Card Hand Layout Sprite (8-card hand backdrop)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 800×112 px (8 cards × ~100 px stride) |
| Format | PNG (transparent) — config sprite |
| Naming | `ui_card_hand_layout_800x112.png` |

**Visual Description**:
Defines the card hand strip at the bottom of screen. 8-card slots each 64 px wide with 16 px stride. Background completely transparent (cards layer on top). This is a layout reference, not a visual asset — represented as guide in scene file.

**Art Bible Anchors**:
- §7.1 Diegetic 哲学 (cards 是手中物理对象)
- §8.5 batching (same Z + same atlas)

**Generation Prompt**:
N/A — scene layout config.

**Status**: Needed (scene config)
**Referenced by**: card-play-dialogue-ui

---

## ASSET-052 — Long Event Background Cinematic Frame

| Field | Value |
|-------|-------|
| Category | UI (full-screen) |
| Dimensions | 1920×1080 px (vector base, 9-slice) |
| Format | PNG |
| Naming | `ui_longevent_letterbox_frame_1920x1080.png` |

**Visual Description**:
Optional letterbox darkening (top + bottom 64 px each, `#1A2A38` 80% alpha) used during `long` event to focus attention on NPC CG. Fades in 0.3 s on event entry, out on exit. NOT a scene change — overlay only. Pure rectangles, not artistic.

**Art Bible Anchors**:
- §4.4 系统提示 `#1A2A38`
- §7.4 不要弹性

**Generation Prompt**:
N/A — solid color rect, programmatic.

**Status**: Needed (programmatic rect)
**Referenced by**: card-play-dialogue-ui

---

## ASSET-053 — Choice Indicator Bullet (for option list)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 8×8 px |
| Format | PNG |
| Naming | `ui_choice_bullet_8x8.png` |

**Visual Description**:
Small `#5A7080` triangle pointing right, used as bullet to the left of each choice button. On focus, recolor to `#C8963C` (老板金). NO animation.

**Art Bible Anchors**:
- §7.3 像素图章 16×16 (此处 8×8 sub-tier)
- §4.4 老板金 focus 色

**Generation Prompt**:
`8x8 pixel art simple triangle bullet pointing right, slate blue #5A7080 default, gold-amber #C8963C focus state, SFC pixel art, transparent background`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui, main-menu-pause-settings-ui (menu list)

---

## ASSET-054 — Card Played Animation Frame Sprites (4 frames)

| Field | Value |
|-------|-------|
| Category | UI (animation) |
| Dimensions | 64×96 px × 4 frames |
| Format | PNG |
| Naming | `ui_card_played_anim_64x96_sheet.png` |

**Visual Description**:
Card-being-played animation. 4 frames totaling 0.2 s:
1. Card lifts 4 px (translation only)
2. Card lifts 8 px + 1 px right tilt
3. Card mid-air fade-out 50% alpha
4. Card vanished

NO sparkle, NO swirl, NO whoosh. Bureaucratic "filing" feel — the card simply leaves.

**Art Bible Anchors**:
- §7.4 UI Animation 不弹性
- Pillar 1 反英雄: no celebratory effects on card play

**Generation Prompt**:
`64x96 pixel art card play animation 4 frames horizontal sprite sheet, simple lift translate then fade, NO sparkle NO motion lines NO particles, SFC pixel art, indexed palette inherited from card base`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-055 — Long Event Background Wash (subtle CanvasModulate hint)

| Field | Value |
|-------|-------|
| Category | Color/Modulate |
| Dimensions | N/A |
| Format | Color value in scene config |
| Naming | (constant in card_play_dialogue_ui.gd) |

**Visual Description**:
During `long` event, scene CanvasModulate is unchanged (Lighting Controller controls). Card UI optionally adds 0.95 self_modulate to suggest "focused on conversation" without changing world tint. NO color shift to gold/blue.

**Status**: Needed (config)
**Referenced by**: card-play-dialogue-ui

---

## ASSET-056 — Card Empty Slot Placeholder

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 64×96 px |
| Format | PNG |
| Naming | `ui_card_empty_slot_64x96.png` |

**Visual Description**:
Empty card slot for hand display when fewer than 8 cards held. Appears as faint dashed-outline rectangle (1 px `#5A4838` dashed pattern). Subtle, not distracting.

**Art Bible Anchors**:
- §3.3 UI shape

**Generation Prompt**:
`64x96 pixel art empty card slot placeholder, faint dashed rectangle outline #5A4838 1px stroke 2px gap pattern, transparent center, SFC pixel art`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-057 — Dialogue Continue Indicator (▼ arrow, blink)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 8×8 px × 2 frames |
| Format | PNG |
| Naming | `ui_dialogue_continue_8x8_sheet.png` |

**Visual Description**:
Small downward triangle in dialogue box bottom-right indicating "press to continue". 2-frame blink (visible / 50% alpha) at 1 Hz. Color `#E8E0CC`.

**Art Bible Anchors**:
- §7.4 UI 帧 ≤ 2 帧

**Generation Prompt**:
`8x8 pixel art downward triangle arrow continue indicator sprite sheet 2 frames, cream color #E8E0CC, simple solid triangle, SFC pixel art, transparent background, suitable for slow blink`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-058 — Speaker Portrait Frame (rounded rectangle)

| Field | Value |
|-------|-------|
| Category | UI |
| Dimensions | 72×104 px (frames a 64×96 portrait) |
| Format | PNG (9-slice) |
| Naming | `ui_speaker_frame_72x104.png` |

**Visual Description**:
Frame around ASSET-042. 4 px border `#2A1F14` + 4 px inner padding `#7A5838`. Sits at upper-left of dialogue box. Portrait visible inside. NO drop shadow.

**Art Bible Anchors**:
- §3.3 UI 0 圆角
- §4.1 档案棕

**Generation Prompt**:
`72x104 pixel art portrait frame border 9-slice, 4px dark border #2A1F14, 4px archive brown inner #7A5838, hollow center for portrait, SFC pixel art`

**Status**: Needed
**Referenced by**: card-play-dialogue-ui

---

## ASSET-059 — NPC LEFT Lifecycle CG Variant (LEAVING_ANNOUNCED — OQ-CPU-05)

| Field | Value |
|-------|-------|
| Category | Sprite (CG) |
| Dimensions | 128×192 px × 8 NPCs (potentially) |
| Format | PNG |
| Naming | `npc_[npcid]_cg_leaving_128x192.png` |
| Texture Res | LOD 2 |

**Visual Description**:
**OQ-CPU-05 deferred — pending art-director + narrative-director decision.** If implemented: each NPC has a distinct LEAVING_ANNOUNCED CG showing them packing belongings, slumped posture, neutral-resigned expression. If NOT implemented: reuse default ASSET-041 with `self_modulate #BBBBBB` for visual differentiation.

**Status**: Deferred (decision pending OQ-CPU-05)
**Referenced by**: card-play-dialogue-ui, npc-relationship-system

---

## ASSET-060 — Subject-Inversion Lint Reference Strings (Localization, not visual)

| Field | Value |
|-------|-------|
| Category | Localization (info only — no asset) |

**Visual Description**:
Reminder: Card title strings, choice button strings, and dialogue strings ALL must pass `subject_inversion_lint.py --domain AP,ENERGY,NPC,EVENT`. No "你的 X" framing. The Localization GDD owns this lint; this asset spec only flags the dependency.

**Status**: N/A (cross-system lint dependency)
**Referenced by**: card-play-dialogue-ui (CI gate dependency)

---

## ASSET-061 — Card Hand Disabled Background (no AP scenario)

| Field | Value |
|-------|-------|
| Category | UI (modulate) |
| Dimensions | N/A — modulate 800×112 zone |
| Format | Config |
| Naming | (constant) |

**Visual Description**:
When AP = 0, all hand cards apply ASSET-046 disabled overlay, plus the entire hand strip has `self_modulate #B0B0B0` 50% saturation reduction. No banner "OUT OF AP" — visual desaturation alone communicates state.

**Art Bible Anchors**:
- §4.5 色盲: rely on desaturation, not color

**Status**: Needed (config)
**Referenced by**: card-play-dialogue-ui

---

## ASSET-062 — Numeric Only Flash Cross-Reference

Cross-ref to ASSET-014 (HUD numeric-only flash overlay caption). Card UI forwards `numeric_only` density events to HUD #13 — no per-card asset.

**Status**: Cross-reference (use ASSET-014)

---

## ASSET-063 — Card Front Generic Icon Set (8-12 icon stamps)

| Field | Value |
|-------|-------|
| Category | UI Icon |
| Dimensions | 32×32 px × N |
| Format | PNG (atlas) |
| Naming | `ui_card_icons_atlas_32x32.png` |

**Visual Description**:
Generic icon library for card faces — typed by action category (talk / cooperate / observe / decline / etc.). Pixel-stamp style per art-bible §7.3. ~10 icons MVP (final count owned by action-card-system GDD).

**Art Bible Anchors**:
- §7.3 像素图章风格
- §4.4 UI palette derivation

**Generation Prompt**:
`32x32 pixel art office action icon stamp set atlas 10 icons (talk speech bubble, handshake, eye observe, hand wave decline, document, coffee cup, phone, calendar, briefcase, thumb-no-up), SFC pixel style stamp aesthetic, indexed palette derived from world office, transparent background`

**Status**: Needed (action-card-system owns final list)
**Referenced by**: card-play-dialogue-ui, action-card-system

---

## ASSET-064 — Hand Card Container Theme

| Field | Value |
|-------|-------|
| Category | Theme resource |
| Format | `.tres` |
| Naming | `ui_card_hand_container.tres` |

**Visual Description**:
Container theme for HBoxContainer holding cards. Padding 8 px, separation 16 px. No background. Z-index ordered above HUD diegetic but below dialogue box (Z-layer 50, HUD 30, dialogue 100).

**Status**: Needed (theme config)
**Referenced by**: card-play-dialogue-ui
