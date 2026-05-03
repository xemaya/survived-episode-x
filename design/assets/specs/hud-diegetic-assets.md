# Asset Specs — System: HUD Diegetic

> **Source**: design/gdd/hud-diegetic.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 22 assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Asset coverage: 8 diegetic 元素的 sprite variants（Rule 1 of GDD Section C），对应 8 sub-mode 布局（Rule 2）。AP/Energy/KPI 视觉 variant 数量直接来自 GDD 表格。

---

## ASSET-001 — Sticky Note Default (空白便利贴)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 16×16 px (单格), 1 frame |
| Format | PNG (RGBA, indexed PNG-8 export) |
| Naming | `ui_diegetic_sticky_note_blank_16x16.png` |
| Texture Res | 16 px — Art Bible §8.2 道具尺寸 |

**Visual Description**:
A blank yellow-cream sticky note (`#E8E0CC` 白炽灯白底), 1 px `#2A1F14` border on bottom-right corner suggesting paper curl. Pinned-to-desk look, no decoration. Represents an unused AP slot ("today's allowance not yet spent").

**Art Bible Anchors**:
- §3.3 UI Shape Language: 0 圆角, 1 px 边框
- §4.1 World Palette: 白炽灯白 `#E8E0CC` (paper)
- §7.1 Diegetic Lock: 工位物理元素

**Generation Prompt**:
`16x16 pixel art sticky note, blank cream paper #E8E0CC, single dark coffee-brown shadow line bottom-right at 1px width, no text, no decorations, top-down desk perspective, SFC pixel style, no anti-aliasing, indexed palette 4 colors max, transparent background`

**Status**: Needed
**Referenced by**: hud-diegetic, lighting-visual-state (workplace 累积视觉)

---

## ASSET-002 — Sticky Note Crossed-Out (斜线便利贴)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 16×16 px |
| Format | PNG |
| Naming | `ui_diegetic_sticky_note_crossed_16x16.png` |

**Visual Description**:
ASSET-001 with a single 1 px `#2A1F14` (咖啡渍棕黑) diagonal slash from top-left to bottom-right. Represents an AP slot that has been spent — bureaucratic crossing-off, not "achievement".

**Art Bible Anchors**:
- §4.1 咖啡渍棕黑 `#2A1F14` for the slash
- §7.4 UI Animation Feel: 官僚式迟钝 — 斜线 visual is bureaucratic strike-through, never a "completed checkmark"

**Generation Prompt**:
`16x16 pixel art sticky note with single diagonal pencil slash, cream paper #E8E0CC base, dark slash color #2A1F14 at exactly 1px width, no checkmark, no celebration glow, SFC pixel art, no anti-aliasing, transparent background`

**Status**: Needed
**Referenced by**: hud-diegetic

---

## ASSET-003 — Sticky Note Overtime (加班浅灰格)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 16×16 px |
| Format | PNG |
| Naming | `ui_diegetic_sticky_note_overtime_16x16.png` |

**Visual Description**:
A grey-tinted sticky note (`#BBBBBB` base) with no slash. Represents AP slots 9-10 (overtime borrowed slots). Visually washed-out and slightly desaturated — "borrowed, not earned".

**Art Bible Anchors**:
- §4.5 色盲安全（reduced saturation distinguishes from base 8 slots without relying on hue）
- Anti-Pillar 1 守门: NO highlight, NO glow — overtime 不被视为 achievement

**Generation Prompt**:
`16x16 pixel art sticky note, washed-out gray paper #BBBBBB, dim 1px shadow, NO highlight, NO glow, NO sparkle, deliberately desaturated, SFC pixel art, transparent background`

**Status**: Needed
**Referenced by**: hud-diegetic

---

## ASSET-004 — Sticky Note Folded Corner (早退折角 variant)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 16×16 px |
| Format | PNG |
| Naming | `ui_diegetic_sticky_note_folded_16x16.png` |

**Visual Description**:
ASSET-001 with the top-right corner visibly folded down (3×3 px triangle of slightly darker `#D4C8B0` showing the underside). Represents an AP slot left over after early-leave — "not spent today".

**Art Bible Anchors**:
- §3.3 UI 形状语法: 几何明确，零亚像素
- §7.1 Diegetic: 折角是物理动作残留，不是 UI badge

**Generation Prompt**:
`16x16 pixel art sticky note with folded top-right corner, base paper #E8E0CC, fold underside #D4C8B0, exactly 3x3 pixel triangular fold, no text, SFC pixel style, transparent background`

**Status**: Needed
**Referenced by**: hud-diegetic

---

## ASSET-005 — Coffee Cup Liquid States (咖啡杯液位 5 variant sprite sheet)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 16×16 px × 5 frames (horizontal sprite sheet 80×16) |
| Format | PNG |
| Naming | `ui_diegetic_coffee_cup_levels_16x16_sheet.png` |

**Visual Description**:
A ceramic mug viewed at 3/4 angle, single 16×16 sprite per state. 5 frames: full (深咖啡棕 `#7A5838` 占杯口下 2 px), 3/4 (中咖啡占 4 px), half (浅咖啡 `#A88858` 占 8 px), 1/4 (极淡 `#D4C0A8` 残留底部), empty (`#2A1F14` 干渍底). Cup outline `#2A1F14` 1 px throughout. Mug body `#E8E0CC`.

**Art Bible Anchors**:
- §4.1 咖啡渍棕黑 `#2A1F14` (deepest), 档案室棕 `#7A5838` (mid)
- §6.3 工位道具尺寸锁定 (中道具 8×8，杯子作为 16×16 桌面元素属于"中等道具放大版")
- §3.2 环境几何: 几何明确，圆杯口 + 直杯身

**Generation Prompt**:
`16x16 pixel art coffee mug sprite sheet 5 frames horizontal, 3/4 perspective, cream ceramic body #E8E0CC, dark brown rim outline #2A1F14, liquid levels: full dark brown #7A5838, three-quarter mid brown, half lighter, quarter very pale #D4C0A8 dregs only, empty with dried stain residue #2A1F14, SFC pixel art, no anti-aliasing, indexed palette 6 colors`

**Status**: Needed
**Referenced by**: hud-diegetic, lighting-visual-state (desk_stain_count cumulative variant)

---

## ASSET-006 — Coffee Cup Burnout Stain Ring (干渍环)

| Field | Value |
|-------|-------|
| Category | Sprite (overlay) |
| Dimensions | 24×8 px (extends beneath cup) |
| Format | PNG (transparent overlay) |
| Naming | `ui_diegetic_coffee_stain_ring_24x8.png` |

**Visual Description**:
A 2 px wide concentric stain ring beneath ASSET-005 frame 5 (empty state). Color `#2A1F14` with 50% alpha falloff at outer edge. Represents burnout state — physical evidence of the cup having sat empty.

**Art Bible Anchors**:
- §4.1 咖啡渍棕黑 `#2A1F14`
- §6.5 累积视觉 (永久痕迹哲学)

**Generation Prompt**:
`24x8 pixel art coffee stain ring, dark brown #2A1F14 with semi-transparent edges, 2px outer ring, no inner detail, SFC pixel art, transparent center, no anti-aliasing`

**Status**: Needed
**Referenced by**: hud-diegetic (burnout state)

---

## ASSET-007 — Monitor Data Display Variants (5 KPI 状态数据屏)

| Field | Value |
|-------|-------|
| Category | Sprite (UI 嵌于环境) |
| Dimensions | 64×48 px × 5 frames (sheet 320×48) |
| Format | PNG |
| Naming | `ui_diegetic_monitor_kpi_64x48_sheet.png` |

**Visual Description**:
Computer monitor screen content. 5 frames: (1) Normal — Excel-style grey-blue `#5A7080` table with thin lines, small 4 px font. (2) Warning — table same but progress line thickens to 2 px in `#F5C400` UI 警告黄. (3) Over — 1 px red `#C83428` border around full screen + warning yellow line. (4) GameOver-Pre — same as (3) but 1-frame flicker between bright/dim. (5) GameOver — desaturated to `#999999` greyscale.

**Art Bible Anchors**:
- §4.4 UI 警告黄 `#F5C400`, 世界警告红 `#C83428`
- §4.1 格子间灰蓝 `#5A7080` (table base)
- §7.1 Diegetic: 显示器是世界中物理屏，非 UI overlay

**Generation Prompt**:
`64x48 pixel art computer monitor display sprite sheet 5 frames horizontal, Excel-style spreadsheet, grey-blue table #5A7080 normal state, thicker yellow #F5C400 progress line warning state, red 1px border #C83428 over-budget state, flickering bright/dim variant, fully desaturated grey #999999 gameover state, no decorative icons, SFC pixel art, indexed palette`

**Status**: Needed
**Referenced by**: hud-diegetic, kpi-review-game-over-ui (full-screen variant 衍生)

---

## ASSET-008 — Attendance Board (墙上考勤表 8 sub-mode variant)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 48×32 px × 8 frames (sheet 384×32) |
| Format | PNG |
| Naming | `ui_diegetic_attendance_board_48x32_sheet.png` |

**Visual Description**:
A wall-mounted attendance grid. 8 frames matching 8 sub-modes:
1. MAIN_MENU — hidden (transparent placeholder)
2. MORNING_BRIEFING — full week visible, current week row highlighted with subtle yellow `#C8A85A` underline
3. ACTION_DAY — same as morning, current day cell darkened
4. ACTION_OVERTIME — overtime row added, blue-shifted `#5A7080`
5. AFTER_WORK — week row visible, no highlight
6. DAILY_RECAP — current day cell with 1 px ✓ stamp
7. KPI_REVIEW — month-end, full month visible, red `#C83428` outline on month total cell
8. GAMEOVER — fully desaturated, single `#999999` pass

**Art Bible Anchors**:
- §6.5 时间流逝视觉 — 考勤表是时间锚点
- §4.4 UI palette derived from world

**Generation Prompt**:
`48x32 pixel art office attendance board sprite sheet 8 frames horizontal, gridded paper schedule mounted on wall, beige paper background #E8E0CC, dark thin grid lines #2A1F14, varying highlight states per frame: yellow underline current week, dark current day, blue overtime extension, checkmark, red month total outline, full grayscale gameover, SFC pixel art`

**Status**: Needed
**Referenced by**: hud-diegetic, lighting-visual-state (notice_board_age 累积褪色), notification-warning-system

---

## ASSET-009 — Desk Calendar (桌面日历, 31 day × month variants)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 24×24 px × 31 frames per month (sheet 31 × N months) |
| Format | PNG |
| Naming | `ui_diegetic_desk_calendar_24x24_sheet.png` |

**Visual Description**:
A small desk-flip calendar. Top half shows current month name (3-char abbreviation in `#2A1F14` 4 px font), bottom half shows day number (8 px font). Backing card is `#E8E0CC` paper with 1 px `#7A5838` (档案棕) torn-edge top. 31 frames cycle through day numbers 1-31. Month layer is separate, swappable via `self_modulate` or atlas region.

**Art Bible Anchors**:
- §6.3 工位道具 8×16 大道具 (放大变体)
- §6.5 时间流逝视觉

**Generation Prompt**:
`24x24 pixel art desk flip calendar, tear-edge top in archive brown #7A5838, paper background #E8E0CC, large day number bottom half dark brown #2A1F14, small month abbreviation top, no decorations, SFC pixel art clean line, indexed palette`

**Status**: Needed
**Referenced by**: hud-diegetic, daily-weekly-recap-ui

---

## ASSET-010 — NPC Expression Variants (8 NPC × 4 Phase = 32 portraits)

| Field | Value |
|-------|-------|
| Category | Sprite (face overlay) |
| Dimensions | 16×16 px (face region) × 32 |
| Format | PNG (atlas) |
| Naming | `npc_face_phase_atlas_16x16.png` (single atlas, 8×4 grid) |

**Visual Description**:
Per-NPC facial expression overlay layered on body sprite. 4 expressions per NPC (HOSTILE / NEUTRAL / WARM / CLOSE). Each NPC archetype keeps its 喜丧触发 hint per art-bible §5.2:
- HOSTILE: averted gaze, mouth flat, no eye contact (1 px pupil shifted away)
- NEUTRAL: working face, eyes on screen
- WARM: subtle 0.5 squint toward player direction (eye 2 px shifted)
- CLOSE: 1 px nod-tilt, mouth slight curl (≤ 1 px upward)

**Art Bible Anchors**:
- §5.2 NPC 9 原型 (player 不算 NPC, MVP 8 NPCs)
- §5.3 帧数上限 3 帧/姿态, expression overlay 仅 1 frame each
- §4.5 色盲补偿: phase distinguished by silhouette (head tilt) not just color

**Generation Prompt**:
`32-frame pixel art atlas, 16x16 each face, 8 office worker NPC archetypes vertically (overworker, slacker, sycophant, newbie, oldhand, cleaner, boss, HR), 4 emotional phases horizontally (hostile averted, neutral working, warm subtle squint, close subtle nod), 16-color SFC palette, no exaggerated cartoon expressions, "喜丧" understated dark humor aesthetic`

**Status**: Needed
**Referenced by**: hud-diegetic, npc-relationship-system, card-play-dialogue-ui (small portrait), kpi-review-game-over-ui

---

## ASSET-011 — NPC Position Variants (4 站位/NPC, 8 NPC = 32 frames)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 32×48 px × 32 frames (atlas 256×96 grid 8×4) |
| Format | PNG |
| Naming | `npc_position_phase_atlas_32x48.png` |

**Visual Description**:
NPC body posture by relationship phase:
- HOSTILE: back to player (rear silhouette, 4 px shoulder facing away)
- NEUTRAL: standard side-view at desk (default)
- WARM: subtle 1.5° body torque toward player direction
- CLOSE: noticeable 3° lean toward player but feet still anchored at own desk (距离守门)

Each NPC carries its silhouette signature (茶杯/领带/眼袋 from art-bible §5.2).

**Art Bible Anchors**:
- §5.4 LOD 0 32×48 px base
- §5.2 silhouette signatures preserved across all 4 positions

**Generation Prompt**:
`32x48 pixel art NPC body sprite atlas, 8 office worker archetypes x 4 postures: back turned, standard side, slight lean, more lean toward player; preserve silhouette signatures (boss tall+8px, cleaner short+wide, HR neat, etc.), SFC palette, 16 colors per sprite, no excessive animation, idle frame only`

**Status**: Needed
**Referenced by**: hud-diegetic, npc-relationship-system, card-play-dialogue-ui

---

## ASSET-012 — Empty Chair (LEFT NPC 空椅)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 32×48 px |
| Format | PNG |
| Naming | `env_npc_empty_chair_32x48.png` |

**Visual Description**:
A workstation chair empty, slightly pushed back from desk. Desk surface beneath is bare except for a single 4×4 px discarded paper cup (`#E8E0CC`) and a thin layer of dust (1 px stipple `#BBBBBB`). No name plaque (R-NPC-2 守门 — no name leak). Chair color is `#7A5838` (档案棕). The vacancy reads as "this person is gone" without literal text.

**Art Bible Anchors**:
- §6.3 工位道具密度 (空椅区域: 1 大 + 1 小道具，传达"被弃")
- §3.1 角色剪影哲学反向应用 (无人 = 椅子轮廓即叙事)
- R-NPC-2 守门: 无名字标签

**Generation Prompt**:
`32x48 pixel art empty office chair pushed back from desk, archive brown #7A5838 chair, beige paper cup #E8E0CC on desk surface, faint gray dust speckles #BBBBBB at 1px stipple, NO name plaque, NO label, NO text, SFC pixel art, transparent background, somber but understated`

**Status**: Needed
**Referenced by**: hud-diegetic, npc-relationship-system, lighting-visual-state

---

## ASSET-013 — Sticky Note Lifecycle Sprite Set (00-08 fill states + overtime 09-10)

| Field | Value |
|-------|-------|
| Category | Sprite (composite) |
| Dimensions | 144×16 px (8 cells horizontal sequence at 16 px each + 2 overtime) |
| Format | PNG (atlas, derived from ASSET-001/002/003) |
| Naming | `ui_diegetic_sticky_row_atlas_144x16.png` |

**Visual Description**:
Composite atlas combining ASSET-001 (blank), ASSET-002 (crossed), ASSET-003 (overtime gray), ASSET-004 (folded). 8 base cells + 2 overtime cells = 10 total, plus blank rest state. Used by HUD to render the entire AP row in one draw call.

**Art Bible Anchors**:
- §8.5 Batching 优先 (single atlas 减少 draw call)

**Generation Prompt**:
N/A — composite from ASSET-001/002/003/004; produced via Aseprite tag export.

**Status**: Needed (assembly task)
**Referenced by**: hud-diegetic

---

## ASSET-014 — HUD Numeric-Only Flash Overlay Frame (8 px font Caption Label)

| Field | Value |
|-------|-------|
| Category | UI (font + frame) |
| Dimensions | dynamic width × 12 px height |
| Format | Theme resource (.tres) referencing 8 px pixel font |
| Naming | `ui_diegetic_flash_overlay_caption.tres` |

**Visual Description**:
Single-line caption appearing inside ASSET-007 monitor display zone. 8 px pixel font, `#E8E0CC` text, no border, no background tint (uses monitor's existing screen color). Auto-fades after 1.5 s. Bureaucratic phrasing only ("系统记录了您的协作积极性"风格).

**Art Bible Anchors**:
- §7.2 字体层级 Caption 8 px
- §4.4 UI palette: `#E8E0CC` text (白炽灯白 derivative)
- Pillar 1 主语翻转: text uses system-subject only

**Generation Prompt**:
N/A — theme/font resource, no generation needed. Uses existing `Press Start 2P` 8 px or equivalent SFC pixel font in project asset pipeline.

**Status**: Needed (theme config task)
**Referenced by**: hud-diegetic, notification-warning-system, event-script-engine (numeric_only event display)

---

## ASSET-015 — Workstation Desk Surface (base sprite for HUD elements layer)

| Field | Value |
|-------|-------|
| Category | Environment |
| Dimensions | 32×16 px (single workstation desk, doubles to 64×16 in 2-cell layout) |
| Format | PNG |
| Naming | `env_workstation_desk_32x16.png` |

**Visual Description**:
Top-down 3/4 view of a worker's desk surface. Wood grain `#7A5838` 档案棕 with 1 px darker `#5A3A20` grain lines. 16×16 px middle zone is the "tools area" where ASSET-001..006 sprites layer on top. Desk edge has 1 px shadow line.

**Art Bible Anchors**:
- §6.3 工位密度 3-5 道具/格
- §4.1 档案室棕 `#7A5838` 桌面

**Generation Prompt**:
`32x16 pixel art office desk surface top-down 3/4 view, archive brown wood #7A5838 base, dark brown grain lines #5A3A20 1px width, 16x16 pixel central work area kept clean for prop layering, single 1px bottom shadow, SFC pixel art, transparent above desk surface, indexed palette 4 colors`

**Status**: Needed
**Referenced by**: hud-diegetic (base layer beneath ASSET-001..006)

---

## ASSET-016 — Anniversary Banner Variant (周年俗艳粉横幅)

| Field | Value |
|-------|-------|
| Category | Sprite (overlay) |
| Dimensions | 96×16 px |
| Format | PNG |
| Naming | `env_anniversary_banner_96x16.png` |

**Visual Description**:
Cheap office anniversary banner. Bright vulgar pink `#E8609A` (art-bible §4.6 周年庆俗艳粉) with 2 px black `#2A1F14` border framing it (mandatory border per §4.6). Text reads "奋斗 [N] 周年" in Chinese pixel font (PUA 鸡汤暖金圈 `#C8A028` outline). When in overtime sub-mode, banner shifts to coffee-stain brown `#2A1F14` (per art-bible §6.5).

**Art Bible Anchors**:
- §4.6 俗艳粉 ≤ 5% + 必须 2px 黑框压住
- §6.5 anniversary_year 累积视觉
- §4.6 PUA 鸡汤暖金圈 `#C8A028` for text outline (≤ 2% budget, 必配讽刺文本)

**Generation Prompt**:
`96x16 pixel art office anniversary banner, vulgar bright pink #E8609A background MANDATORY 2px black border #2A1F14, Chinese characters "奋斗 X 周年" in pixel font, gold-amber outline text #C8A028, deliberately cheap aesthetic, "PUA motivational poster" feel, SFC pixel style, indexed palette 6 colors`

**Status**: Needed
**Referenced by**: hud-diegetic (HUD_ATTENDANCE_BOARD anniversary overlay), lighting-visual-state

---

## ASSET-017 — Notice Board Aging Variants (4 fade levels)

| Field | Value |
|-------|-------|
| Category | Sprite (modulate variant) |
| Dimensions | 16×16 px × 4 |
| Format | PNG |
| Naming | `env_notice_paper_age_16x16_sheet.png` |

**Visual Description**:
Single notice sheet on bulletin board, 4 age-based modulate variants:
- Age [0-2]: full color `#E8E0CC` paper, `#2A1F14` text
- Age [3-5]: `self_modulate #BBBBBB` (faded)
- Age [6-11]: `self_modulate #999999`
- Age [12+]: `self_modulate #777777` ghost-state, edges curl 1 px (separate sprite)

**Art Bible Anchors**:
- §6.5 notice_board_age 4 级渐变
- §4.5 色盲安全: 通过 lightness 区分而非色相

**Generation Prompt**:
`16x16 pixel art office notice paper sprite sheet 4 fade levels, beige paper #E8E0CC fresh, then progressively desaturated gray #BBBBBB #999999 #777777, last frame has slightly curled corners 1px, SFC pixel art, transparent background`

**Status**: Needed
**Referenced by**: hud-diegetic (HUD_ATTENDANCE_BOARD aging), lighting-visual-state

---

## ASSET-018 — HUD Element Z-Layer Configuration (technical doc, not visual)

| Field | Value |
|-------|-------|
| Category | Configuration |
| Dimensions | N/A |
| Format | `.gd` constants file |
| Naming | `src/gameplay/hud/hud_z_layers.gd` |

**Visual Description**:
Z-layer ordering configuration for HUD diegetic elements. Documented to ensure batching is preserved (art-bible §8.5 same Z + same atlas + same shader).

**Art Bible Anchors**:
- §8.5 Z 序中断破坏 batch (技术约束)

**Generation Prompt**:
N/A — code config asset.

**Status**: Needed (implementation task, not art)
**Referenced by**: hud-diegetic

---

## ASSET-019 — Empty Workstation Chair Pushed-In (active NPC chair)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 32×48 px |
| Format | PNG |
| Naming | `env_workstation_chair_active_32x48.png` |

**Visual Description**:
NPC's active workstation chair pushed in to desk (the inverse of ASSET-012 LEFT state). Same color/shape as ASSET-012 but tucked under desk and positioned for body sprite layering. Used as base when NPC body is rendered on top.

**Art Bible Anchors**:
- §6.3 工位密度

**Generation Prompt**:
`32x48 pixel art office chair tucked under desk, archive brown #7A5838 backrest visible above desk edge, SFC pixel art, transparent background, ready for NPC body sprite overlay`

**Status**: Needed
**Referenced by**: hud-diegetic, npc-relationship-system

---

## ASSET-020 — Coffee Cup Stain Trail Variant (desk_stain_count 累积)

| Field | Value |
|-------|-------|
| Category | Sprite (累积) |
| Dimensions | 16×16 px × 5 levels |
| Format | PNG |
| Naming | `env_desk_stain_16x16_sheet.png` |

**Visual Description**:
Cumulative coffee ring residue on desk. 5 levels (clamped per Lighting GDD Rule 5):
- 0: clean desk (no stain)
- 1: single faint ring `#5A3A20` 30% alpha
- 2: 2 overlapping rings
- 3: 3 rings + small splash
- 4+: 3 rings + splash + dried droplets (visual saturation cap)

**Art Bible Anchors**:
- §6.5 累积视觉 desk_stain_count
- §4.1 咖啡渍棕黑 `#2A1F14` accent / `#7A5838` ring color

**Generation Prompt**:
`16x16 pixel art coffee stain accumulation sprite sheet 5 levels, transparent base, single faint ring level 1 archive brown #7A5838 with semi-alpha, additional overlapping rings level 2-3, splash and droplets max level 4, SFC pixel art, transparent background`

**Status**: Needed
**Referenced by**: hud-diegetic (subscribes #5 accumulation_event), lighting-visual-state

---

## ASSET-021 — Monitor Bezel Frame (background of ASSET-007)

| Field | Value |
|-------|-------|
| Category | Environment |
| Dimensions | 80×64 px |
| Format | PNG |
| Naming | `env_monitor_bezel_80x64.png` |

**Visual Description**:
Old CRT-thick monitor bezel surrounding the data display screen (ASSET-007). Bezel color `#5A4838` (slightly grayer archive brown), 4 px thick frame, with 2 px highlight on top edge `#7A5838` (suggests fluorescent ceiling reflection). Stand visible at bottom 8 px. The 64×48 px center cutout is where ASSET-007 displays.

**Art Bible Anchors**:
- §6.1 老写字楼 (CRT 老监视器风格)
- §4.1 档案室棕 derivative

**Generation Prompt**:
`80x64 pixel art old CRT computer monitor bezel, dark gray-brown frame #5A4838, 4px thick, 2px highlight on top edge from fluorescent ceiling reflection, 8px stand at bottom, central 64x48 cutout for screen content, SFC pixel art, transparent background, indexed palette 4 colors`

**Status**: Needed
**Referenced by**: hud-diegetic (HUD_MONITOR_DATA host frame)

---

## ASSET-022 — HUD Element Boundary Marker (debug visual, dev-only)

| Field | Value |
|-------|-------|
| Category | Sprite (debug) |
| Dimensions | 16×16 px outline |
| Format | PNG |
| Naming | `dev_hud_boundary_16x16.png` |

**Visual Description**:
1 px magenta `#FF00FF` debug outline used in editor only to mark each HUD diegetic element's clickable / hover region. Strip from production build via `OS.is_debug_build()`.

**Art Bible Anchors**:
- N/A (debug-only)

**Generation Prompt**:
`16x16 pixel debug outline, single 1px magenta #FF00FF border, transparent center, no other content`

**Status**: Needed (debug)
**Referenced by**: hud-diegetic (debug builds)
