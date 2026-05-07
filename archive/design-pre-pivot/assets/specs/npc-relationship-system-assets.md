# Asset Specs — System: NPC Relationship System

> **Source**: design/gdd/npc-relationship-system.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 12 assets specced / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Coverage: 8 NPCs × 4 lifecycle states (ACTIVE / LEAVING_ANNOUNCED / LEFT / RETURNED-VS) + per-NPC clothing palette swap + visual cues per lifecycle. Reuses ASSET-010/011/012 from hud-diegetic for active state visuals.

---

## ASSET-065 — NPC Sprite Atlas — ACTIVE State Lifecycle (cross-reference)

| Field | Value |
|-------|-------|
| Source | ASSET-011 (specced in hud-diegetic-assets.md) |

**Visual Description**:
ACTIVE state body sprites are already specced as ASSET-011 (32×48 px, 8 NPCs × 4 position phases). NPC Relationship System subscribes to `relationship_changed` to trigger phase position changes; HUD owns rendering.

**Status**: Cross-reference (use ASSET-011)
**Referenced by**: npc-relationship-system, hud-diegetic, card-play-dialogue-ui

---

## ASSET-066 — NPC LEAVING_ANNOUNCED Visual Overlay (收纸箱 layer, 8 NPCs)

| Field | Value |
|-------|-------|
| Category | Sprite (overlay) |
| Dimensions | 32×48 px × 8 NPCs |
| Format | PNG (atlas) |
| Naming | `npc_leaving_overlay_atlas_32x48.png` |

**Visual Description**:
Per art-bible §6.3 individual props + GDD R-NPC C5 Rule 8: NPC in LEAVING_ANNOUNCED state has a small cardboard box (8×8 px, archive brown `#7A5838`) on their desk, plus a few personal items being collected (4×4 px frame photo, 4×4 px coffee mug). Overlay applied on top of ACTIVE sprite. Each NPC keeps overlay variant matching their archetype (e.g., 卷王 has more papers piled, 摸鱼族 has snack wrappers).

**Art Bible Anchors**:
- §6.3 工位道具 8×8 中道具
- §3.1 silhouette: box on desk shifts visual mass

**Generation Prompt**:
`32x48 pixel art NPC leaving-announced overlay atlas 8 archetypes, small cardboard box #7A5838 8x8px on desk, personal items 4x4 frame photo and mug being packed, archetype-specific variants (overworker: stacks of papers; slacker: snack wrappers; sycophant: name cards bundle; HR: filed folders), SFC pixel art, transparent background, designed to overlay on ASSET-011 ACTIVE sprite`

**Status**: Needed
**Referenced by**: npc-relationship-system, hud-diegetic

---

## ASSET-067 — NPC LEFT Empty Chair (cross-reference)

| Field | Value |
|-------|-------|
| Source | ASSET-012 (specced in hud-diegetic-assets.md) |

**Status**: Cross-reference (use ASSET-012)
**Referenced by**: npc-relationship-system, hud-diegetic, lighting-visual-state

---

## ASSET-068 — NPC RETURNED Visual Marker (VS scope, MVP placeholder)

| Field | Value |
|-------|-------|
| Category | Sprite (VS scope) |
| Dimensions | 32×48 px × 8 NPCs |
| Format | PNG |
| Naming | `npc_returned_marker_atlas_32x48.png` |

**Visual Description**:
**VS-only.** NPC who returned after leaving. Same as ACTIVE base + 1 px age marker (subtle wrinkle line on face) showing time has passed. MVP scope does NOT implement RETURNED state — visual placeholder only.

**Status**: Deferred (VS scope)
**Referenced by**: npc-relationship-system

---

## ASSET-069 — NPC Clothing Color Palette Variants (8 NPCs × 1 variant each)

| Field | Value |
|-------|-------|
| Category | LUT entries (palette swap) |
| Dimensions | 8 entries in palette LUT atlas (ASSET-025) |
| Format | LUT row data |
| Naming | (additional rows in `assets/palettes/pal_lut_office_8xN.png`) |

**Visual Description**:
Per art-bible §5.5 复用策略, body sprite skin uses `pal_skin_base.gpl`. Each NPC has 1 distinguishing clothing color drawn into base sprite, swapped via LUT. Suggested per archetype:
- 卷王: `#5A6878` (深蓝衬衫, 严肃)
- 摸鱼族: `#7A6A48` (米色 hoodie, 散漫)
- 谄媚族: `#5A7A60` (绿衬衫, 主动)
- 新人: `#A88858` (浅卡其, 新人)
- 老油条同行: `#6A5848` (棕色西装, 老练)
- 清洁阿姨: `#A04848` (红围裙)
- Boss: `#3A3050` (深紫西装, art-bible §4.2 紫色权力)
- HR: `#E8E0CC` (米白衬衫, "中立")

**Art Bible Anchors**:
- §5.5 palette swap 复用 (节省产量)
- §5.2 NPC 9 prototypes (player not counted)

**Generation Prompt**:
N/A — LUT data, not standalone image. Generated via Aseprite palette tool.

**Status**: Needed (LUT extension)
**Referenced by**: npc-relationship-system, lighting-visual-state (palette swap shader)

---

## ASSET-070 — NPC Walking Cycle Sprites (4-frame side view, shared lower body)

| Field | Value |
|-------|-------|
| Category | Sprite (animation) |
| Dimensions | 32×48 px × 4 frames per NPC × 8 NPCs |
| Format | PNG (atlas) |
| Naming | `npc_walk_cycle_atlas_32x48.png` |

**Visual Description**:
4-frame walk cycle (art-bible §5.3). Per art-bible §5.5: 下半身（腿部 16 px 走路循环）所有人类共用. Upper body 16 px varies per archetype (silhouette signature preserved). MVP: 8 NPCs × 4 walk frames = 32 frames; lower body 4 frames shared.

**Art Bible Anchors**:
- §5.3 走·侧面 4 帧
- §5.5 下半身共用

**Generation Prompt**:
`32x48 pixel art NPC walking cycle atlas 8 archetypes x 4 frames side view, lower body 16px shared (legs in step cycle), upper body 16px archetype-distinct preserving silhouette signature (boss tall, cleaner short+wide, etc.), SFC pixel art, indexed palette per NPC clothing variant, transparent background`

**Status**: Needed
**Referenced by**: npc-relationship-system

---

## ASSET-071 — NPC Idle Sit/Stand Variants (sit + stand 2 base poses per NPC)

| Field | Value |
|-------|-------|
| Category | Sprite |
| Dimensions | 32×48 px × 2 poses × 8 NPCs |
| Format | PNG (atlas) |
| Naming | `npc_idle_pose_atlas_32x48.png` |

**Visual Description**:
art-bible §5.5 budget: 坐姿 (3 frames × 2 emotions = 6) + 站姿 (正/背 = 2) = 8 frames base per NPC. MVP simplified: 1 sit-default + 1 stand-default per NPC (use HUD position variants ASSET-011 for 4-phase positions). 8 NPC × 2 poses = 16 frames.

**Art Bible Anchors**:
- §5.3 姿态库 sit/stand
- §5.5 16 张/NPC 上限

**Generation Prompt**:
`32x48 pixel art NPC idle pose atlas 8 archetypes x 2 poses (sitting at desk default, standing facing screen default), preserve silhouette signatures, SFC pixel style, indexed palette, transparent background`

**Status**: Needed
**Referenced by**: npc-relationship-system

---

## ASSET-072 — NPC 喜丧 Trigger Frames (per archetype, 2 frames each = 16 frames total)

| Field | Value |
|-------|-------|
| Category | Sprite (animation) |
| Dimensions | 32×48 px × 2 frames × 8 NPCs |
| Format | PNG (atlas) |
| Naming | `npc_xisang_trigger_atlas_32x48.png` |

**Visual Description**:
art-bible §5.5 "绝对不能省" — 喜丧触发 frames per archetype. 2 专属 frames per NPC (transition + held state). Examples:
- 卷王: 嘴角上扬 + 眼睛不动 (2 frames: working face → hollow smile)
- 摸鱼族: 抓到时起身过快 (2 frames: lounging → sudden upright with 1 frame gap)
- 清洁阿姨: 见人晕倒继续擦地嘴角上扬 (2 frames: mopping → mopping with subtle smile)
- Boss: 笑容残影留 2 帧 (2 frames: criticism face → praising face)

**Art Bible Anchors**:
- §5.2 喜丧触发 (核心美学载体)
- §5.5 至少 2 帧专属/NPC

**Generation Prompt**:
`32x48 pixel art NPC "喜丧" dark-humor trigger animation atlas 8 archetypes x 2 frames each, archetype-specific micro-expression betraying inner truth (see archetype list in art bible §5.2), SFC pixel art understated NOT cartoon-exaggerated, indexed palette, transparent background`

**Status**: Needed (CRITICAL — game core aesthetic)
**Referenced by**: npc-relationship-system, card-play-dialogue-ui

---

## ASSET-073 — NPC LEFT Lifecycle Workplace Cleanup Variant

| Field | Value |
|-------|-------|
| Category | Sprite (overlay) |
| Dimensions | 32×16 px (workstation desk variant) |
| Format | PNG |
| Naming | `env_workstation_left_cleared_32x16.png` |

**Visual Description**:
Variant of ASSET-015 (desk surface) for LEFT NPC workstation. Desk is fully cleared — no props, just clean wood `#7A5838` with a single 1 px dust film (`#999999` stipple). The chair (ASSET-012) is the primary visual cue; this is the desk supplement.

**Art Bible Anchors**:
- §6.3 工位道具密度 (空: 0 道具违反"最低 3" → use lone dust as semantic cue)
- R-NPC-2 守门: 不显示名字标签

**Generation Prompt**:
`32x16 pixel art cleared desk surface variant, archive brown wood #7A5838 base, faint gray dust stipple #999999 1px scattered, NO props NO labels NO name plate, SFC pixel art, transparent above desk surface`

**Status**: Needed
**Referenced by**: npc-relationship-system (LEFT state), hud-diegetic

---

## ASSET-074 — NPC Lifecycle State Visual Marker Mapping

| Field | Value |
|-------|-------|
| Category | Configuration |
| Format | `.tres` Resource |
| Naming | `assets/data/npc_lifecycle_visual_map.tres` |

**Visual Description**:
Resource mapping each `lifecycle_state` enum to visual asset references:
- ACTIVE → ASSET-011 (position by phase) + ASSET-010 (face by phase)
- LEAVING_ANNOUNCED → above + ASSET-066 (overlay)
- LEFT → ASSET-012 (empty chair) + ASSET-073 (cleared desk)
- RETURNED → ASSET-068 (VS placeholder, MVP unused)

**Status**: Needed (config)
**Referenced by**: npc-relationship-system, hud-diegetic

---

## ASSET-075 — NPC Talk Animation (mouth open/close 2 frames)

| Field | Value |
|-------|-------|
| Category | Sprite (animation overlay) |
| Dimensions | 8×8 px × 2 frames × 8 NPCs |
| Format | PNG (atlas) |
| Naming | `npc_mouth_talk_atlas_8x8.png` |

**Visual Description**:
Tiny mouth overlay for dialogue. 2 frames per NPC (closed / open-slight). Each archetype keeps mouth shape from §5.2 silhouette (HR `空框无镜片` mouth same; 谄媚族 `'哦哦哦'` rounded mouth). Used during `long` event dialog rendering.

**Art Bible Anchors**:
- §5.3 帧数上限 3 frames (此处 2 frames sufficient)
- §5.2 archetype mouth shapes

**Generation Prompt**:
`8x8 pixel art NPC mouth talk animation overlay atlas 8 archetypes x 2 frames closed/open, archetype-distinct mouth shapes per art bible NPC archetypes, SFC pixel art, transparent background, designed to overlay on portrait ASSET-042`

**Status**: Needed
**Referenced by**: npc-relationship-system, card-play-dialogue-ui

---

## ASSET-076 — NPC Skin Palette Base LUT (pal_skin_base.gpl source)

| Field | Value |
|-------|-------|
| Category | Palette source |
| Dimensions | 8 colors |
| Format | `.gpl` (GIMP Palette) + `.aseprite` source |
| Naming | `assets/palettes/pal_skin_base.gpl` |

**Visual Description**:
art-bible §8.4 锁定: 8 颜色 NPC 皮肤共用基础。Suggested ramp:
- shadow1: `#3A2818`
- shadow2: `#5A3A20`
- mid1: `#A07050`
- mid2: `#C0906A`
- highlight1: `#D8B098`
- highlight2: `#E8C8B0`
- specular: `#F8E8D8`
- transparent: `#000000` (index 0, alpha=0)

Skin overtime variant via shader palette swap (to LUT row 1 in ASSET-025).

**Art Bible Anchors**:
- §8.4 pal_skin_base 8 色
- §8.4 overtime shader palette swap

**Generation Prompt**:
N/A — palette source file.

**Status**: Needed
**Referenced by**: npc-relationship-system, all NPC sprites
