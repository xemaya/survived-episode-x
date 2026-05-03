# Asset Specs — System: Lighting & Visual State

> **Source**: design/gdd/lighting-visual-state.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 18 assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Coverage: 8 sub-mode CanvasModulate palette presets (Rule 1) + palette swap shader + dither overlay shader + 累积视觉 sprites (Rule 5: desk_stain / notice_board / break_room_cracks / anniversary_year) + 环境叙事 4 元素 (Rule 7).

---

## ASSET-023 — CanvasModulate Sub-Mode Palette Config (8 sub-mode presets)

| Field | Value |
|-------|-------|
| Category | Configuration |
| Dimensions | N/A (Color values) |
| Format | `.tres` Resource (LightingPaletteConfig) |
| Naming | `assets/data/lighting_canvas_modulate.tres` |

**Visual Description**:
Resource holding 8 sub-mode `CanvasModulate.color` values from Lighting GDD Rule 1:
- MAIN_MENU: `#C8C4B8` (cold white)
- MORNING_BRIEFING: `#D4D0C8` (uniform cool white)
- ACTION_DAY: `#D0C8A8` (打工人黄)
- ACTION_OVERTIME: `#8090B4` (蓝光降饱和)
- AFTER_WORK_DAY: `#B05A28` (地铁座椅橙)
- AFTER_WORK_OVERTIME: `#6878A0` (蓝光黄昏)
- DAILY_RECAP: `#C8A060` (地铁暖黄)
- KPI_REVIEW / GAMEOVER: `#3A3050` (深蓝灰)

**Art Bible Anchors**:
- §2.1-2.6 6 mood references
- §4.3 区域色温规则
- §8.6 CanvasModulate + Tween 0.3s 锁

**Generation Prompt**:
N/A — color resource config.

**Status**: Needed (config task)
**Referenced by**: lighting-visual-state, scene-day-flow-controller

---

## ASSET-024 — Palette Swap Shader (palette_swap.gdshader)

| Field | Value |
|-------|-------|
| Category | Shader |
| Dimensions | N/A |
| Format | `.gdshader` |
| Naming | `assets/shaders/palette_swap.gdshader` |

**Visual Description**:
Single ubershader. R-channel of source pixel acts as palette index (0-7). Samples LUT atlas at `(palette_index + 0.5) / 8.0` column to remap source color → target color. 8 rows × 8 cols PNG LUT. `palette_index: int` uniform [0, 7], default 0 (`_day`). Lighting Controller is the ONLY caller of `set_shader_parameter("palette_index", N)` (CI lint enforced).

**Art Bible Anchors**:
- §8.4 Palette 管理 — shader palette swap
- §8.8 Shader 管理 — 1 ubershader, ≤ 10 active shaders

**Generation Prompt**:
N/A — GDShader code asset.

**Status**: Needed
**Referenced by**: lighting-visual-state, all NPC + environment sprites

---

## ASSET-025 — Palette LUT Atlas (8 cols × N rows, PNG)

| Field | Value |
|-------|-------|
| Category | LUT |
| Dimensions | 8 × N px (N = palette row count, MVP N=2: day + overtime) |
| Format | PNG (sRGB OFF, filter=Nearest) |
| Naming | `assets/palettes/pal_lut_office_8xN.png` |

**Visual Description**:
8-column lookup texture. Column 0 = `_day` palette (16-color subset). Column 1 = `_overtime` palette (蓝光降饱和 mapping). Future cols 2-7 reserved for VS sub-modes. Each row maps an indexed source color to target color; row N = source palette entry N.

**Art Bible Anchors**:
- §8.4 Palette 管理 LUT 8×1 PNG
- §8.3 sRGB=off, filter=Nearest

**Generation Prompt**:
`8x16 pixel LUT texture, column 0 daytime palette warm yellows and grays, column 1 overtime palette desaturated blues #8090B4 base, indexed PNG no anti-aliasing, sRGB disabled`

**Status**: Needed
**Referenced by**: lighting-visual-state, ASSET-024 (palette_swap.gdshader)

---

## ASSET-026 — Dither Overlay Shader (dither_overlay.gdshader)

| Field | Value |
|-------|-------|
| Category | Shader |
| Dimensions | N/A |
| Format | `.gdshader` |
| Naming | `assets/shaders/dither_overlay.gdshader` |

**Visual Description**:
Full-screen 2-bit Bayer 4×4 ordered dither using `step(threshold, dither_intensity * edge_alpha_mask)`. Tints output with `#071A47` overlay color. Active only during ACTION_OVERTIME sub-mode. `dither_intensity: float` uniform tweens 0 → 0.35 over 0.5 s on enter, 0.35 → 0 over 0.3 s on exit. ColorRect host stays in scene tree (visible=false off-state) for Shader Baker pre-compile.

**Art Bible Anchors**:
- §6.2 2bit dithering 仅 overtime
- §8.6 零 Light2D + CanvasModulate
- §8.8 Shader Baker 启用

**Generation Prompt**:
N/A — GDShader code asset.

**Status**: Needed
**Referenced by**: lighting-visual-state

---

## ASSET-027 — Desk Stain Count Variants (already specced as ASSET-020 in hud-diegetic; cross-ref)

| Field | Value |
|-------|-------|
| Category | Sprite (cross-reference) |
| Source | ASSET-020 (specced in hud-diegetic-assets.md) |

**Visual Description**:
Reference to ASSET-020. Lighting & Visual State owns `desk_stain_count` state (Rule 5); HUD Diegetic subscribes the cumulative event signal and renders ASSET-020. Lighting writes the state via signal and persists to save.

**Status**: Cross-reference (use ASSET-020)
**Referenced by**: lighting-visual-state, hud-diegetic

---

## ASSET-028 — Notice Board Aging Variants (already specced as ASSET-017; cross-ref)

| Field | Value |
|-------|-------|
| Category | Sprite (cross-reference) |
| Source | ASSET-017 (specced in hud-diegetic-assets.md) |

**Visual Description**:
Reference to ASSET-017. Lighting owns `notice_board_age[]` array (Rule 5), each entry maps to a level using ASSET-017 sprite via `self_modulate`.

**Status**: Cross-reference (use ASSET-017)
**Referenced by**: lighting-visual-state, hud-diegetic

---

## ASSET-029 — Break Room Crack Sprites (4 progressive levels)

| Field | Value |
|-------|-------|
| Category | Sprite (累积) |
| Dimensions | 64×32 px × 4 frames (sheet 256×32) |
| Format | PNG (overlay layer) |
| Naming | `env_breakroom_crack_64x32_sheet.png` |

**Visual Description**:
Progressive wall crack on tea-break-room wall. Lighting GDD Rule 5 mapping (`break_room_cracks: int [0, 16]`):
- 0 (clean): no overlay (transparent frame)
- 1-4: thin 4 px hairline `#7A5838` (档案棕)
- 5-8: visible 8 px branching crack
- 9-12: severe multi-branch with paint chip
- 13-16: collapse-state with debris drift particle hint

**Art Bible Anchors**:
- §6.5 break_room_cracks 累积
- §6.4 环境叙事 #1 "茶水间是逃逸锚点" (so cracks read as quiet decay, not action)
- §4.1 档案棕 + 咖啡渍棕黑

**Generation Prompt**:
`64x32 pixel art office wall crack sprite sheet 4 progressive levels, transparent base, hairline crack archive brown #7A5838 level 1, branching crack level 2, severe with paint chip level 3, collapse with debris #2A1F14 max level, SFC pixel art, no anti-aliasing, transparent background`

**Status**: Needed
**Referenced by**: lighting-visual-state

---

## ASSET-030 — Anniversary Banner Cross-Ref (already specced as ASSET-016)

| Field | Value |
|-------|-------|
| Source | ASSET-016 (specced in hud-diegetic-assets.md) |

**Status**: Cross-reference (use ASSET-016)
**Referenced by**: lighting-visual-state (Rule 5 anniversary_year), hud-diegetic

---

## ASSET-031 — Boss Office Fake Plant Sprite

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 16×24 px |
| Format | PNG |
| Naming | `env_boss_fake_plant_16x24.png` |

**Visual Description**:
A potted plant in boss's office. Per art-bible §6.4 #2: leaves drawn with **4×4 px no-gradient flat color blocks** to clearly distinguish from real plants. Pot is `#7A5838` archive brown ceramic. Leaves `#4A7840` (达标绿). In overtime, `self_modulate` shifts to `#8090B4` blue tint.

**Art Bible Anchors**:
- §6.4 #2 老板办公室假绿植 — 4×4 px 无渐变纯平色块
- §4.2 绿色语义: "被允许存在" not "natural/healing"

**Generation Prompt**:
`16x24 pixel art fake potted plant for boss office, archive brown ceramic pot #7A5838, leaves drawn as 4x4 pixel flat green blocks #4A7840 with NO gradient NO shading deliberately fake-looking, SFC pixel art, transparent background, indexed palette 4 colors`

**Status**: Needed
**Referenced by**: lighting-visual-state (Rule 7 #2)

---

## ASSET-032 — Tea Room Water Sign-In Sprite

| Field | Value |
|-------|-------|
| Category | Sprite (text) |
| Dimensions | 32×16 px |
| Format | PNG |
| Naming | `env_breakroom_water_signin_32x16.png` |

**Visual Description**:
A sign-in clipboard hanging on water dispenser. Multiple lines all signed by the same hand (4-5 entries, all identical chinese-character squiggle pixel-pattern). Default `self_modulate #888888` (faded). In overtime, tween to `#C83428` (世界警告红) over 2 s. Returns to gray on overtime exit.

**Art Bible Anchors**:
- §6.4 #3 茶水间饮水机签名同一人
- §4.2 红 = KPI 警告 / 喜丧 (此处叙事讽刺)

**Generation Prompt**:
`32x16 pixel art tea room water dispenser sign-in clipboard, 4 lines of identical chinese pixel font scribbles signed by same person, default gray text #888888, SFC pixel art, transparent background, indexed palette 3 colors`

**Status**: Needed
**Referenced by**: lighting-visual-state (Rule 7 #3)

---

## ASSET-033 — Hallway Delivery Box Variants (clean / stepped)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 16×16 px × 2 |
| Format | PNG |
| Naming | `env_hallway_delivery_box_16x16_sheet.png` |

**Visual Description**:
A cardboard delivery box in hallway. Two variants:
- clean: pristine cardboard `#A88858` with `#7A5838` flap shadow
- stepped: cardboard with 1-2 footprint impressions in `#5A3A20`, slightly crumpled top

Triggers: `accumulation_event("delivery_footprint", toggle)` from Scene Flow when `npc_traffic_count >= 3`. Resets to clean each daily summary.

**Art Bible Anchors**:
- §6.4 #4 走道快递盒脚印
- §6.3 走道道具密度: 1 个被遗忘的快递盒

**Generation Prompt**:
`16x16 pixel art cardboard delivery box sprite sheet 2 variants, clean state cardboard #A88858 with darker flap #7A5838, stepped state with footprint impressions #5A3A20 slightly crumpled, SFC pixel art, transparent background, indexed palette 4 colors`

**Status**: Needed
**Referenced by**: lighting-visual-state (Rule 7 #4)

---

## ASSET-034 — Meeting Room Whiteboard Layered Strokes

| Field | Value |
|-------|-------|
| Category | Sprite (累积叠加) |
| Dimensions | 96×48 px × 4 alpha layers |
| Format | PNG (4 separate layers, designed for alpha stacking) |
| Naming | `env_meetingroom_whiteboard_strokes_96x48_layer[1-4].png` |

**Visual Description**:
Conference room whiteboard accumulated diagrams. Each layer = one meeting's strokes. 4 layers stack with alpha 1.0 (newest), 0.6, 0.36, 0.22 (older). Strokes are pixel chinese characters + crude pixel diagram shapes (arrows, boxes) in `#2A1F14` ink. Layers are visually distinct (different stroke patterns) so accumulation is readable.

**Art Bible Anchors**:
- §6.4 #5 会议室白板历史笔迹
- §6.5 累积视觉哲学

**Generation Prompt**:
`96x48 pixel art whiteboard scribble layer, dark ink #2A1F14, mix of chinese pixel font notes and crude diagram shapes (arrows, boxes), 4 distinct stroke patterns total to be exported as 4 separate layers, transparent base, SFC pixel art`

**Status**: Needed (4 separate sprites)
**Referenced by**: lighting-visual-state (Rule 7 #5)

---

## ASSET-035 — CanvasModulate Tween Easing Configuration

| Field | Value |
|-------|-------|
| Category | Configuration |
| Dimensions | N/A |
| Format | constants in `lighting_manager.gd` |
| Naming | (code constants) |

**Visual Description**:
Tween config: `TRANS_LINEAR / EASE_IN_OUT`, duration 0.3 s. Locked per art-bible §8.6 — no other easing curves allowed. Cross-fade applies on `scene_state_changed` signal.

**Status**: Needed (code config)
**Referenced by**: lighting-visual-state

---

## ASSET-036 — Tonemapper Configuration (lock to Filmic)

| Field | Value |
|-------|-------|
| Category | Configuration |
| Format | `project.godot` WorldEnvironment setting |

**Visual Description**:
Lock Tonemapper to `Filmic` (NOT AgX — would shift palette hex values). Documented per Lighting GDD Rule 11. Runtime tonemapper switching forbidden.

**Status**: Needed (project setting)
**Referenced by**: lighting-visual-state, art-bible §4.1

---

## ASSET-037 — Steam Particle (蒸汽 / 茶水间逃逸氛围 — VS scope)

| Field | Value |
|-------|-------|
| Category | VFX |
| Dimensions | 8×16 px particle texture |
| Format | PNG (alpha) |
| Naming | `vfx_steam_particle_8x16.png` |

**Visual Description**:
Single steam wisp for tea-break room ambient particles. White-cream `#E8E0CC` with vertical fade-out. Particle count low (≤ 4 simultaneous), lifetime 1.5 s, drift upward. Reads as gentle ambient, not action VFX.

**Art Bible Anchors**:
- §6.3 茶水间道具密度 中等
- §4.1 白炽灯白
- §8.5 软上限 200 sprites/screen

**Generation Prompt**:
`8x16 pixel art single steam wisp particle, cream-white #E8E0CC top fading to fully transparent at bottom, simple wavy column shape, SFC pixel art, transparent background, particle texture for upward drift`

**Status**: Needed (VS scope but specced for completeness)
**Referenced by**: lighting-visual-state

---

## ASSET-038 — Dust Mote Particle (overtime ambient detail)

| Field | Value |
|-------|-------|
| Category | VFX |
| Dimensions | 4×4 px particle |
| Format | PNG |
| Naming | `vfx_dust_particle_4x4.png` |

**Visual Description**:
Single dust mote for overtime ambient. Color `#5A4838` slightly desaturated archive brown. Drifts slowly down through fluorescent light beams. Lifetime 3 s, particle count ≤ 8 simultaneous (per art-bible §8.5 budget). Activates on overtime entry, fades on exit.

**Art Bible Anchors**:
- §2.3 ACTION_DAY 拥挤钝感
- §8.5 sprite 软上限 200

**Generation Prompt**:
`4x4 pixel art dust mote particle, dim archive brown #5A4838 single pixel center with 1px alpha falloff, SFC pixel art, transparent background, for slow downward drift in light beam`

**Status**: Needed (VS scope, lighting accumulation visual)
**Referenced by**: lighting-visual-state

---

## ASSET-039 — Fluorescent Light Tube Sprite (ceiling fixture)

| Field | Value |
|-------|-------|
| Category | Environment |
| Dimensions | 32×8 px × 2 frames (on / flicker-off) |
| Format | PNG |
| Naming | `env_fluorescent_tube_32x8_sheet.png` |

**Visual Description**:
Ceiling fluorescent tube. Frame 1: lit (`#E8E0CC` core, `#FFFFEE` 1 px highlight inside). Frame 2: off / mid-flicker (`#5A6878` cool gray with 1 px black tube outline). In overtime, tube flicker frequency doubles (handled by Scene Flow timer, not asset).

**Art Bible Anchors**:
- §6.1 白炽灯管 (不是筒灯), 部分轻微闪烁
- §4.1 白炽灯白 `#E8E0CC`

**Generation Prompt**:
`32x8 pixel art ceiling fluorescent light tube sprite sheet 2 frames, lit state warm-cream #E8E0CC center, flickering off state cool gray #5A6878 with 1px outline, SFC pixel art clean line, transparent background`

**Status**: Needed
**Referenced by**: lighting-visual-state, environment systems

---

## ASSET-040 — Boss Office Purple Edge Light Overlay

| Field | Value |
|-------|-------|
| Category | Sprite (overlay) |
| Dimensions | 64×64 px |
| Format | PNG (alpha gradient) |
| Naming | `env_boss_office_purple_edge_64x64.png` |

**Visual Description**:
A subtle purple `#5A3A60` edge-light overlay applied as `self_modulate` over boss office walls. Per art-bible §4.3, boss office maintains `_day` and `_overtime` color uniformly — no time variant. Purple is the "缺席的颜色" (absence color), used sparingly.

**Art Bible Anchors**:
- §4.2 紫 = 缺席的颜色; 老板位椅背偶尔一抹
- §4.3 老板办公室色温 3000K + 紫边光

**Generation Prompt**:
`64x64 pixel art purple edge light overlay, deep desaturated purple #5A3A60 with alpha gradient from edges to transparent center, subtle vignette feel, SFC pixel art, transparent center`

**Status**: Needed
**Referenced by**: lighting-visual-state
