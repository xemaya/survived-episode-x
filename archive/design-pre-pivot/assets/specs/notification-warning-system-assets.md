# Asset Specs — System: Notification & Warning System

> **Source**: design/gdd/notification-warning-system.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-05-01
> **Status**: 5 assets specced (mostly cross-references) / 0 in production / 0 done / 0 approved
> **Mode**: solo (art-director + technical-artist not consulted; verify against art bible before production)

> Coverage: per task brief, Notification & Warning System "通过 #13 HUD diegetic 元素 visual variants 显示". Most assets are cross-references to hud-diegetic. This spec only adds notification-specific augmentations.

---

## ASSET-108 — Sticky Note Notification Variant (HUD_STICKY_NOTES augmentation)

| Field | Value |
|-------|-------|
| Category | Sprite (variant) |
| Dimensions | 16×16 px × 3 frames (gentle blink) |
| Format | PNG (atlas) |
| Naming | `ui_diegetic_sticky_note_notification_16x16_sheet.png` |

**Visual Description**:
Variant of ASSET-001 with subtle 3-frame blink (slow alpha pulse: 100% → 80% → 100% over 1.5 s). Used when an event/notification needs the player's attention via a specific sticky note slot. NO red overlay, NO bell icon — diegetic only.

**Art Bible Anchors**:
- §7.4 UI 帧 ≤ 2 帧 (此处 3 帧 fade pulse 是 alpha tween, 不是 sprite frame swap)
- Pillar 1 守门: NO "ALERT" badge

**Generation Prompt**:
`16x16 pixel art sticky note notification variant 3-frame slow alpha pulse, base cream #E8E0CC paper, 1px shadow line, NO red overlay NO bell icon, alpha tween only, SFC pixel art subtle`

**Status**: Needed
**Referenced by**: notification-warning-system, hud-diegetic

---

## ASSET-109 — Monitor Data Display Warning Variant (cross-reference)

| Field | Value |
|-------|-------|
| Source | ASSET-007 (specced in hud-diegetic-assets.md) |

**Visual Description**:
Reference to ASSET-007 frame 2 (warning state with `#F5C400` thicker progress line). Notification system uses this variant for KPI threshold warnings.

**Status**: Cross-reference (use ASSET-007 frame 2)
**Referenced by**: notification-warning-system, hud-diegetic

---

## ASSET-110 — Attendance Board KPI_REVIEW Variant (cross-reference)

| Field | Value |
|-------|-------|
| Source | ASSET-008 frame 7 (specced in hud-diegetic-assets.md) |

**Visual Description**:
Reference to ASSET-008 frame 7 (KPI_REVIEW state with red `#C83428` outline on month total). Notification system uses for month-end warnings.

**Status**: Cross-reference (use ASSET-008 frame 7)
**Referenced by**: notification-warning-system, hud-diegetic

---

## ASSET-111 — Numeric-Only Flash Caption (cross-reference)

| Field | Value |
|-------|-------|
| Source | ASSET-014 (specced in hud-diegetic-assets.md) |

**Visual Description**:
Reference to ASSET-014 caption Label theme. Notification system forwards events to this same overlay zone.

**Status**: Cross-reference (use ASSET-014)
**Referenced by**: notification-warning-system, hud-diegetic, event-script-engine

---

## ASSET-112 — NPC Expression Notification Cue (cross-reference)

| Field | Value |
|-------|-------|
| Source | ASSET-010 (specced in hud-diegetic-assets.md) |

**Visual Description**:
Reference to ASSET-010. When an NPC-related notification fires, NPC expression overlay updates via `relationship_changed` signal — no separate notification asset.

**Status**: Cross-reference (use ASSET-010)
**Referenced by**: notification-warning-system, hud-diegetic, npc-relationship-system
