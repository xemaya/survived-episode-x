# W1 Engine Dev Task Queue (for /loop pickup)

> Status: live queue — refreshed 2026-05-06 19:40 after design re-alignment + AVG architecture spec
> Author: GM
> 收件人: W1 (P5 Phase 2 engine dev clone)
>
> **核心 reference**: `design/vertical-slice/avg-architecture.md` 是 AVG 时代 dialog UI + daily pressure 的 source of truth. 当前所有 P0 task 都基于该 doc.
>
> **使用方法**: 每轮 /loop pick 1 个 task (按 P0 → P1 → P2 顺序)。完成 → commit → append `p5-phase2-engine-progress.md` + 在本文件 task 末加 `**Status**: ✅ done in commit <sha>`。Queue empty 时输出 "queue empty, idle"。

---

## ✅ Done (W1 batches 8-21, 2026-05-06)

| ID | Task | Commit |
|---|---|---|
| Q-A → Q-J | Bug #11/#13/#14/#16/#18/#19/#20/#21/#22/Q-4 (early UX fixes) | various |
| Q-K (1st half) | Bug #23 morning_briefing card kill | `89c8a29` |
| Q-M | Bug #27 AP system delete | `51580f4` |
| Q-L (Bug #25 only) | panel + sticky coexist | `44f0b7a` |
| (extra) | Bug #1+#2/#15/#12/#20 doc-only closes | various |

Tests 179 → 289 (+110 net), 0 regression.

---

## 🔥 P0 — IMMEDIATE NEXT PICK (architecture reset)

GM playtest revealed that incremental fixes to the existing 5-layer dialog rendering kept surfacing new bugs (Bug #19→#20→#18→#18-regression cascade). **Decision (per `avg-architecture.md` §1)**: 重构 dialog rendering 为 3-layer (panel + sticky + ▼) **公文报告框** with per-source header bar.

This **supersedes** outstanding Q-L Bug #24 (speaker auto-split), which becomes a built-in feature of the new architecture.

### Q-R · Dialog 重构 — 3 layer 公文报告框 (per avg-architecture.md §1)

**Why**: 当前 5-layer (panel + bubble + monologue + sticky + header band) 累积架构债 → 6 个 fix 后仍漏 state 跨 step。重构成 3 layer + stateless paint + auto-split-on-source 一次性解决。

**Spec source**: `design/vertical-slice/avg-architecture.md` §1.1 - §1.7

**简要**:
1. 删除 `speech-bubble.ts` + `speech-bubble-layout.ts` + `npc-anchors.ts` + `speaker-parser.ts` + `internal-monologue.ts`
2. Rewrite `ink-dialog.ts paintStep` — stateless (顶部 unconditional teardown 所有 layer, 然后按 phase 一致性 mount)
3. 简化 `dialog-phase.ts` — 7 phase → 3 phase (`narration` / `choice` / `ended`)
4. 新建 `source-detector.ts` (NEW, ~50 lines) — 纯 helper 决定 chunk source = NPC name / monologue / narration
5. 修改 `runtime.ts step()` — 累积 chunk 时检测 source 边界, source 切换时插入 virtual pagebreak (auto-split)
6. Panel 重构 — 8 px 顶部 header bar 标 source `[视角] / [笑天] / [Lisa] / [王总监] / [妈妈]` etc; body 12 pt 思源黑体; cubicle navy `#5A7080` BG + 1 px border
7. Monologue 改 inline 在 panel (italic + cool gray `#A8B0C0` + header `[ 笑天 ]`)
8. NPC speech 改 inline 在 panel (upright + header `[ <NPC> ]`)
9. Sticky rack 保留 (Q-L Bug #25 panel + sticky 共存继续)
10. ▼ continue affordance 保留 (panel 右下)

**Bugs auto-close (副作用)**:
- Bug #18 / #18-regression (bubble lingers) → bubble 删了, 没有 lingering 可能
- Bug #19 / #20 (monologue Z-overlap + 区分) → monologue 进 panel + header 标 source
- Bug #24 (auto-split on speaker) → 重构核心 feature
- 用户试玩 image 28-30 那批 layout 混乱 → stateless paint 解决

**测试**:
- vitest: source-detector pure helper unit test (10 case+)
- vitest: dialog-phase 简化后 3 phase boundary test
- dev: Day 2 Lisa 茶水间 (典型 multi-source step) → 验证每个 source 单 paint, 玩家 ▼ 推进, panel header 准确显示当前 speaker
- dev: Day 4 Lisa lunch invite + Day 4 weekly_report 跨 event → 验证 panel 不留 stale 内容

**Files** (estimate):
- 删除: 4-5 个 dialog/render-related .ts file (~400 lines deleted)
- 改写: `ink-dialog.ts` paintStep + `dialog-phase.ts` + `runtime.ts step()` + `sticky-notes.ts` (调位置)
- 新建: `source-detector.ts` + tests

**Estimate**: 6-8h

**Status**: ✅ done in commit `0f7aa6f` (batch 22, 2026-05-06). 5 dialog files (speech-bubble + speech-bubble-layout + npc-anchors + speaker-parser + internal-monologue + internal-monologue-parser) + 2 tests deleted; new `source-detector.ts` + 29 cases + 7 source-split runtime cases; runtime.ts step() does source-boundary auto-split via the existing pendingChunk machinery; ink-dialog.ts paintStep is stateless 3-layer with header-bar source label; dialog-phase 7→3. Bug #18 / #18-regression / #19 / #20 / #24 副作用 closed. 288/288 tests passing.

---

## 🆕 P0 — Post Q-R playtest fixes (small W1 tasks)

### Q-T · Bug #33 — narration 段 panel header `[视角]` 不必要

**Why**: GM playtest 2026-05-06 post Q-R: user confused "[视角] 不明所以". narration 是默认旁白, 无需 source label.

**Fix**: `ink-dialog.ts` paintStep 内 `mountPanelHeader(source)` — narration source → return early (无 header). monologue → header `[ 笑天 ]`. NPC → `[ <NPC name> ]`.

**File**: `game/src/render/dialog/ink-dialog.ts`

**Test**: Day 1 morning_briefing (mostly narration) → panel 无 header. Day 1 Event 1.2 茶水间 Lisa speech → header `[ Lisa ]`. Italic monologue step → `[ 笑天 ]`.

**Estimate**: 10 min

**Note**: `avg-architecture.md` §1.3 表已同步 update — narration 无 header.

**Status**: ✅ done in commit `9446295` (batch 23, 2026-05-06). drawPanel now skips header bar entirely for narration; body region shifts up to fill full panel rect. Monologue + NPC keep header.

### Q-U · Bug #26 PRIORITY BUMP — calendar Pixi Graphics widget

**Why bump**: GM playtest 2026-05-06 reiterate "左上角的日历没改, 还是破烂的贴图". 从 P2 polish bump 到 P0 (在 Q-T 之后).

**Spec**: 详下面 P2 Q-O 段 (现 alias Q-U)。Pixi Container + Graphics 程序绘制台历, 绑 `calendar.onDateChanged` auto-redraw.

**Estimate**: 1-2h

**Status**: ✅ done in commit `<pending>` (batch 23, 2026-05-06). New `calendar-widget.ts` with 80×80 desk-calendar visual: paper BG + 装订红 banner with month label + 7×5 date grid (past gray / current red ring / weekend red / weekday ink); self-binds to onDateChanged. workstation.ts swapped from sprite path to `mountCalendarWidget()`.

---

## P0 — KPI Review cinematic (simulation 心跳)

### Q-Q · Bug #31 — KPI 月末 Review cinematic (per avg-architecture.md §2.5)

**Why**: simulation 担当压在月末 review。详 Bug #31 spec + `avg-architecture.md` §2.5。

**Spec brief** (full detail in `p5-qa-bug-reports.md` Bug #31):
- Pre-reveal: 王总监 NPC cue + scene transit + 1.5s 静音
- Reveal pacing: 数字 tick-up 1 行 1 行渐次出 (KPI / 阈值 / ratio / 下月 bar)
- HR-speak 5 路径文案 ink-driven via `# kpi_review_path_a/b/c/d/e` tag
- "——这是您的 reward" attribution line
- KPI < 50 → gameover; 累积 > 150 → promotion 警告

**Files**: rebuild `kpi-review.tsx` + 新建 `kpi-review-cinematic.ts` + `runtime.ts` 加 tag listener + `episode-1.ink` D7 末 + `episode-12.ink` D84 path A 加 `# kpi_review_path_X` tag

**Estimate**: 4-6h

**Dependencies**: T-1 T04 落地后 `# scene: monitor_modal` 才能切场。可与 T-1 并行实现, 落地时 wire 通。

---

## P0 — Daily pressure mechanism

### Q-S · Weekly meter modal (per avg-architecture.md §2.2)

**Why**: 删 AP 之后 daily-level pressure 由 weekly meter (周一/周五) 承担。

**Spec brief**:
- Trigger: 周一 morning (Day 1, 8, 15, 22) + 周五 evening (Day 5, 12, 19, 26)
- Modal Preact overlay (~3 秒 + 玩家可 dismiss)
- 内容: 本月 KPI 累积/阈值 + 钱 + 状态 + 病倒次数 (横向进度表格 per art-bible §3.3) + 上周/本月 趋势
- 视觉: BG `#1A2A38` (屏幕蓝光加深) + 1 px 边框 + 12 pt 公文宋
- Body bar: KPI 黄 / 钱 老板金 (≤3% pixel) / 状态 灰蓝 / 病倒红色格子 (color-blind safe)

**Files**: 新建 `game/src/render/menu/weekly-meter.tsx` + `day-cycle.ts` 加 trigger logic

**Spec source**: `avg-architecture.md` §2.2

**Estimate**: 2-3h

### Q-K-2nd · First-time tutorial modal (Bug #23 second half + Bug #30)

**Spec brief**:
- 1 次性 modal, 仅 `localStorage` 没 `survived:tutorial_seen` flag 时弹出
- 内容: 游戏 = 反向 KPI 中国职场生存模拟 + 三种 voice (`视角/笑天/选项`) + 不可能三角 + 52 集目标 + 病倒 cap
- 关掉后写 flag

**Files**: 新建 `game/src/render/onboarding/first-time-tutorial.tsx` + `main.ts` boot path mount

**Estimate**: 1-2h

**Bug #30 close**: tutorial 解释 voice convention → Bug #30 同 close。

**注**: Q-R 重构后 voice 通过 panel header 显式标识 (`[视角]/[笑天]/[Lisa]`), tutorial 主要解释三要素 + 52 集目标 + 病倒 cap, voice 解释成为辅助。

---

## P1 — 主要 feature

### T-1 · T04 scene registry + transitions

**Why now**: 剧本 emit `# scene: break_room` 但工位 BG 不变。Episode 2-8 demo 关键路径。

**Spec**:
- 新建 `game/src/render/scene/scene-registry.ts` (~80 lines)
- 已有 mount: `mountWorkstation()` → 注册为 `workstation`
- 新建 stub mounts: `break_room`, `home_phone`, `cafeteria`, `meeting_room`, `elevator`, `reception`, `monitor_modal`, `endgame`
- `sceneState.on('scene', id => sceneRegistry.transitionTo(id))` listener
- 200ms fade Graphics 过渡

**Estimate**: 3-5h

### T-2 · T05/T06 NPC sprite slots

**Why now**: bubble 删除后, NPC visual identity 需要 sprite mount 支持 (W5 已有 lin_jie + cafeteria_auntie 立绘).

**Spec**:
- 新建 `game/src/render/npc/npc-registry.ts`
- `sceneState.on('npc', tagValue => npcRegistry.handleTag(tagValue))` parse + mount
- scene 切换时 NPC 自动 unmount (scene scope, 同 prop)

**Files**: 新 `npc-registry.ts` + 调 npc-anchors.ts (Q-R 后已删除 — 重新评估)

**Estimate**: 2-3h

---

## P2 — Polish

### Q-O · Bug #26 — calendar Pixi Graphics widget

**Spec**: 新建 `game/src/render/diegetic/calendar-widget.ts`. Pixi Container + Graphics 程序绘制台历, 绑 `calendar.onDateChanged` auto-redraw. 删 sprite-based mount.

**Estimate**: 1-2h

---

## /loop 工作流

```
1. 读本文件 + p5-phase2-engine-questions.md + p5-qa-bug-reports.md (skim 新 bug)
   核心 reference: design/vertical-slice/avg-architecture.md (AVG 时代 spec)
2. 优先级:
   a) p5-qa-bug-reports.md 有新 block bug → pick
   b) 否则按本文件 P0 上至下 → P1 → P2 顺序 pick 第一条未 ✅ done
3. else 输出 "queue empty, idle"
4. 实现 + tests + commit + 写 progress log + 在本文件 task 末加 `**Status**: ✅ done in commit <sha>`
```

---

## END
