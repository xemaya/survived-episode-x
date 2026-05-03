# Epics Index

Last Updated: 2026-04-29
Engine: Godot 4.6 + GDScript
Manifest Version: `docs/architecture/control-manifest.md` 2026-04-28
Stories Total: **234 created**(20/20 epics — Foundation 66 + Core 50 + Feature 40 + Presentation 66 + Polish 12;VS/Alpha 32 stories 2026-04-29 batch)

Generated from `design/gdd/systems-index.md` × 14 ADRs(adr-0001..0014)× `tr-registry.yaml`(139 TR-IDs)。

---

## Foundation Layer(5 — 无依赖,可并行实施)

| Epic | System | GDD | Governing ADRs | Engine Risk | Stories | Status |
|------|--------|-----|----------------|-------------|---------|--------|
| [save-system](save-system/EPIC.md) | #1 Save System | [save-system.md](../../design/gdd/save-system.md) | ADR-0003, ADR-0006, ADR-0013 | MEDIUM | **16 created** | Ready |
| [input-handler](input-handler/EPIC.md) | #2 Input Handler | [input-handler.md](../../design/gdd/input-handler.md) | ADR-0001, ADR-0002, ADR-0014 | HIGH | **13 created** | Ready |
| [localization-hooks](localization-hooks/EPIC.md) | #3 Localization Hooks | [localization-hooks.md](../../design/gdd/localization-hooks.md) | ADR-0004, ADR-0010, ADR-0014 | LOW | **12 created** | Ready |
| [audio-manager](audio-manager/EPIC.md) | #4 Audio Manager | [audio-manager.md](../../design/gdd/audio-manager.md) | ADR-0001, ADR-0002, ADR-0007 | HIGH | **12 created** | Ready |
| [lighting-visual-state](lighting-visual-state/EPIC.md) | #5 Lighting & Visual State Controller | [lighting-visual-state.md](../../design/gdd/lighting-visual-state.md) | ADR-0001, ADR-0005, ADR-0007, ADR-0008 | LOW | **13 created** | Ready |

## Core Layer(4 — 依赖 Foundation)

| Epic | System | GDD | Governing ADRs | Engine Risk | Stories | Status |
|------|--------|-----|----------------|-------------|---------|--------|
| [scene-day-flow-controller](scene-day-flow-controller/EPIC.md) | #6 Scene & Day Flow Controller ⭐⭐ | [scene-day-flow-controller.md](../../design/gdd/scene-day-flow-controller.md) | ADR-0001, ADR-0002, ADR-0004 | HIGH | **15 created** | Ready |
| [ap-economy-system](ap-economy-system/EPIC.md) | #7 AP Economy System ⭐ | [ap-economy-system.md](../../design/gdd/ap-economy-system.md) | ADR-0001, ADR-0003 | MEDIUM | **12 created** | Ready |
| [npc-relationship-system](npc-relationship-system/EPIC.md) | #8 NPC Relationship System ⭐ | [npc-relationship-system.md](../../design/gdd/npc-relationship-system.md) | ADR-0001, ADR-0005, ADR-0009 | MEDIUM | **10 created** | Ready |
| [kpi-reverse-threshold-system](kpi-reverse-threshold-system/EPIC.md) | #9 KPI & Reverse Threshold ⭐⭐ | [kpi-reverse-threshold-system.md](../../design/gdd/kpi-reverse-threshold-system.md) | ADR-0001, ADR-0006, ADR-0007 | LOW | **13 created** | Ready |

## Feature Layer(4 — 依赖 Core)

| Epic | System | GDD | Governing ADRs | Engine Risk | Stories | Status |
|------|--------|-----|----------------|-------------|---------|--------|
| [event-script-engine](event-script-engine/EPIC.md) | #10 Event Script Engine ⭐⭐ | [event-script-engine.md](../../design/gdd/event-script-engine.md) | ADR-0001, ADR-0006, ADR-0009, ADR-0010 | HIGH | **14 created** | Ready |
| [action-card-system](action-card-system/EPIC.md) | #11 Action Card System ⭐ | [action-card-system.md](../../design/gdd/action-card-system.md) | ADR-0001, ADR-0008, ADR-0009 | HIGH | **9 created** | Ready |
| [run-meta-system](run-meta-system/EPIC.md) | #12 Run Meta System | [run-meta-system.md](../../design/gdd/run-meta-system.md) | ADR-0001, ADR-0003, ADR-0013 | MEDIUM | **7 created** | Ready |
| [tutorial-onboarding-system](tutorial-onboarding-system/EPIC.md) | #18 Tutorial / Onboarding(VS) | [tutorial-onboarding-system.md](../../design/gdd/tutorial-onboarding-system.md) | ADR-0002, ADR-0003 | HIGH | **10 created**(3 Blocked by VS ADR) | Ready(VS tier)|

## Presentation Layer(6 — 依赖 Feature/Core)

| Epic | System | GDD | Governing ADRs | Engine Risk | Stories | Status |
|------|--------|-----|----------------|-------------|---------|--------|
| [hud-diegetic](hud-diegetic/EPIC.md) | #13 HUD Diegetic ⭐ | [hud-diegetic.md](../../design/gdd/hud-diegetic.md) | ADR-0001, ADR-0005, ADR-0008, ADR-0011 | LOW | **10 created** | Ready |
| [card-play-dialogue-ui](card-play-dialogue-ui/EPIC.md) | #14 Card Play & Dialogue UI ⭐ | [card-play-dialogue-ui.md](../../design/gdd/card-play-dialogue-ui.md) | ADR-0001, ADR-0009, ADR-0012 | HIGH | **8 created** | Ready |
| [daily-weekly-recap-ui](daily-weekly-recap-ui/EPIC.md) | #15 Daily/Weekly Recap UI | [daily-weekly-recap-ui.md](../../design/gdd/daily-weekly-recap-ui.md) | ADR-0001, ADR-0010, ADR-0012 | LOW | Not yet created | Ready |
| [kpi-review-game-over-ui](kpi-review-game-over-ui/EPIC.md) | #16 KPI Review & Game Over UI ⭐ | [kpi-review-game-over-ui.md](../../design/gdd/kpi-review-game-over-ui.md) | ADR-0006, ADR-0007, ADR-0009, ADR-0013 | HIGH | Not yet created | Ready |
| [main-menu-pause-settings-ui](main-menu-pause-settings-ui/EPIC.md) | #17 Main Menu / Pause / Settings UI | [main-menu-pause-settings-ui.md](../../design/gdd/main-menu-pause-settings-ui.md) | ADR-0001, ADR-0004, ADR-0013, ADR-0014 | HIGH | Not yet created | Ready |
| [notification-warning-system](notification-warning-system/EPIC.md) | #19 Notification & Warning(VS) | [notification-warning-system.md](../../design/gdd/notification-warning-system.md) | ADR-0010, ADR-0011 | LOW | **10 created**(Story 005 partial flag #6) | Ready(VS tier)|

## Polish Layer(1 — 跨切关注,Alpha tier)

| Epic | System | GDD | Governing ADRs | Engine Risk | Stories | Status |
|------|--------|-----|----------------|-------------|---------|--------|
| [accessibility-options](accessibility-options/EPIC.md) | #20 Accessibility Options(Alpha) | [accessibility-options.md](../../design/gdd/accessibility-options.md) | ADR-0004, ADR-0008, ADR-0014 | HIGH | **12 created**(Story 009/010 MVP 即上线) | Ready(Alpha tier)|

---

## Implementation Order(by ADR dependency + layer)

Foundation → Core → Feature → Presentation → Polish

### MVP critical path(17 epics)
1. `save-system`(blocks 8+ 系统持久化)
2. `input-handler`(blocks 全 UI 系统)
3. `localization-hooks`(blocks 全 UI 文本)
4. `audio-manager`(blocks 月末仪式 + diegetic 工位)
5. `lighting-visual-state`(blocks 累积视觉 + sub-mode palette)
6. `scene-day-flow-controller`(总线 dispatch — Bottleneck ⭐⭐)
7. `ap-economy-system`(核心 gameplay)
8. `npc-relationship-system`
9. `kpi-reverse-threshold-system`(反向 KPI 数学引擎 ⭐⭐)
10. `event-script-engine`(数据驱动事件 schema ⭐⭐)
11. `action-card-system`
12. `run-meta-system`
13. `hud-diegetic`
14. `card-play-dialogue-ui`
15. `daily-weekly-recap-ui`
16. `kpi-review-game-over-ui`
17. `main-menu-pause-settings-ui`

### VS tier(2 epics)
18. `tutorial-onboarding-system`
19. `notification-warning-system`

### Alpha tier(1 epic)
20. `accessibility-options`

---

## Architecture Coverage Stats(from `/architecture-review` 2026-04-28)

- **TR Registry**:139 TR-IDs(20 系统全套)
- **Coverage**:✅ 95 covered + ⚠️ 25 partial + 📋 13 GDD-internal + ❌ 6 真 gap(全为 VS/Alpha 推迟项)
- **8 BLOCKING 全仲裁** ✓(ADR-0001..0008)
- **0 ADR-vs-ADR conflict** ✓
- **2 GDD micro-edits 待 fresh session 修**:`#10 Rule 18`(JSON-primary → .tres + Inspector)+ `#9 Edge 1.4`(M1 开除路径对齐 ADR-0006)

---

## Next Step

`/create-stories [epic-slug]` per epic to break into implementable stories. Foundation 5 epics 可并行 stories 编写;Core layer 等 Foundation Approved 后启动。
