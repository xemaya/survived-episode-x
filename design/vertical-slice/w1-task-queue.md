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

## 🆕 P0 — Post batch-24 playtest sweep (5 bugs from GM 2026-05-07)

GM playtest after batch 24 (W1 ship 6 commits + Q-T已 ship). 5 处 visible issue. 派 W1 batch (5 task ~3-4h total) + 1 子项 W5.

### Q-Z · Bug #39 — NPC sprite 位置太挤 + 太小 (T-2 follow-up)

**Why**: image 37 显示 NPC 立绘 ~30 px 高 dump 在 panel header 区. T-2 NPC_TABLE scale 0.3 for 64×96 portrait = 19×29 px tiny. Anchors inherited from old npc-anchors stub (was bubble tail tip, not 立绘 stand point).

**Fix**:
- NPC_TABLE scale 0.3 → **0.6-0.8** (per-sprite tune; verify 实际渲染 size)
- 重 tune positions per workstation visual logic, **不**在 panel area (panel y=240-336):
  - lisa: 右近隔壁工位 (x=520, y=200) — 同 row 同事
  - david: 左近隔壁工位 (x=160, y=200)
  - wang_director: 顶部 (x=320, y=120) — 站工位旁 push 的位置
  - vivian: 顶部偏右 (x=560, y=130) — 远景前台
  - zoe: 顶部偏左 (x=260, y=130) — HR 远端
  - lao_zhou: 右远 (x=580, y=200)
  - li_ayi: 左下 (x=80, y=270) — 拖地经过 (panel 下方但稍偏)
  - mama: 中部居中 (x=320, y=180) — 视频 phone scene
  - lin_jie: 顶部偏左 (x=200, y=130) — 隔壁部门
  - it_xiaoma: 左中 (x=140, y=200) — IT 角落
  - cafeteria_auntie: 中下 (x=320, y=270)

**File**: `game/src/render/npc/npc-registry.ts` NPC_TABLE
**Test**: dev 到 Day 1 Event 1.1 (Vivian) → 验证 Vivian sprite 在右上 visible 且不撞 panel
**Estimate**: 30 min

**Status**: ✅ done in commit `ca90261` (batch 25, 2026-05-07). Scale 0.3 → 0.6 across all 11 entries; positions retuned per spec (no NPC overlaps panel y=240+ or sticky band 170-240).

### Q-AA · Bug #40 — Status HUD redesign 3 bar + 3 icon (no numbers)

**Why**: image 37 现 HUD 是 "KPI 100/200 / 钱 ¥5,503 / 状态 83/100" 数字 readout. User: "右上角的状态栏很丑. 不显示数字, 显示三个柱状图. 注意不要报表. KPI/钱/状态三个词用三个一样大的 icon 替代."

**Spec**: HUD 改 visual bar + icon (no numbers, no labels):
- Container at (canvas.W - 84, 16), 80×56 (smaller than current)
- 3 horizontal bars stacked vertically (3 px gap):
  - Bar 1 KPI: ratio `actualKpi / monthlyThreshold` clamped 0-1.4 (handle 处刑 zone). 颜色 `#C8A85A` 打工人黄. 红色 highlight when >1.0 (over threshold).
  - Bar 2 钱: ratio `(money - LOW_THRESHOLD) / (HIGH_THRESHOLD - LOW_THRESHOLD)` (LOW=2000 房贷扣款下限, HIGH=15000 充裕). 颜色 `#E0B050` 老板金.
  - Bar 3 状态: `state / 100`. 颜色 `#5A7080` 灰蓝. 红色 highlight when <0.2 (即将病倒).
- Each bar: 12 px tall × 60 px wide, 1 px border `#2A1F14`, BG empty 灰白
- Above each bar: 12×12 icon (procedural Pixi Graphics):
  - KPI icon: 表格 (3 horizontal stacked lines)
  - 钱 icon: ¥ symbol (Graphics line drawing)
  - 状态 icon: heart (or simple human bust silhouette via 3 ovals)
- 3 icons SAME size 12×12 (per user spec — symmetry)
- 选择 effect: bar tween value (500ms ease) + 300ms color brief flash

**File**: `game/src/render/hud/status-hud.ts` rebuild

**Estimate**: 1-2h

**Status**: ✅ done in commit `ec09b42` (batch 25, 2026-05-07). status-hud.ts rebuilt as 80×56 container with 3 rows = `[12×12 icon] [60×12 bar]`. Icons: KPI 表格 (3 horizontal lines) + 钱 ¥ + 状态 heart silhouette. Bar fills with 处刑/病倒 red highlight zones. Per-row tween + 300ms color brighten flash on change. HUD position (556, 16).

### Q-BB · Bug #41 — Calendar advance system (per ink stitch path)

**Why**: image 37 calendar widget 显示 "1月1日" 不变. Day 不 advance 因为 engine 不知道当前是几号.

**Fix (engine-only)**: 在 paintStep 顶部 parse `story.state.currentPathString` → match `day_(\d+)_` → call `calendar.set(N)`. ink content 已有 `day_N_*` stitch name, 不需 ink change.

```ts
function syncCalendarFromInk(ink: Story) {
  const path = ink.state.currentPathString;
  const m = path?.match(/day_(\d+)_/);
  if (m) {
    const day = parseInt(m[1], 10);
    if (calendar.currentDay !== day) calendar.set(day);
  }
}
```

调用点: `ink-dialog.ts paintStep` 顶部 (every paint).

**File**: `game/src/render/dialog/ink-dialog.ts` paintStep + `game/src/flow/calendar.ts` (verify `set(day: number)` API; 如无 add)

**Estimate**: 30 min

**注**: month 同样 derivable — episode-N.ink 对应 month-N. parse current ink story title or stitch knot name. 但 month advance 实际只发生 episode 切换, 周期跨度大, 暂时不动 calendar widget banner (1 月 JAN). 后续可加 episode 切换 listener → calendar.setMonth(N).

**Status**: ✅ done in commit `b949969` (batch 25, 2026-05-07). New `calendar.setDay(day)` API rederives weekday + fires listeners. New `ink.currentPathString` getter on InkRuntime. New `syncCalendarFromInkPath()` helper called at top of paintStep parses `day_(\d+)_` and applies. 4 new vitest cases.

### Q-CC · Bug #42 — HR portal mini-monitor 看起来重复

**Why**: image 37 显示 2 个 monitor-like — 中间大显示器 (program mount swap target) + 它下方 desk 上小 "HR" 牌 mini-monitor. 后者是 `workstation_closeup.png` BG **艺术品烘焙**, 不是 program mount.

**Decision**: GM 选 **W5 re-prompt** workstation_closeup.png 删除 mini HR 牌. 一次性 $0.13.

**Fix path**:
- W5 round-N: re-prompt workstation_closeup.png with explicit "no HR portal mini-monitor / second screen on desk; main monitor only, centered top"
- Re-cut + sync to `game/public/sprites/backgrounds/workstation_closeup.png`
- (No engine code change)

**Owner**: W5 single-shot dispatch, 不入 W1 queue

**Estimate**: 15 min W5 + assets:sync

### Q-DD · Bug #43 — Kill all panel headers (per user "都没有")

**Why**: image 36 + image 37 显示 inconsistent header (narration 无, monologue/NPC 有). User: "对话栏还是有问题, 纯旁白的时候标题栏就消失, 体验不一致. 我建议都没有, 比如类似这种 [image 38]". Image 38 reference shows panel **without any header**, with NPC quote inline as part of narration prose.

**Spec change** (`avg-architecture.md` §1.3 v3):
- Panel **never** shows source label header bar — ALL paints just panel BG + body text
- Source distinction 通过 body 字体/字色 区分:
  - narration: upright cream text (your/你...)
  - monologue: italic cool gray text (我...)
  - NPC speech: upright cream + inline `Name："..."` prefix kept (revert Q-X strip)
- Source-detector 仍 useful: routing for body style (italic vs upright) + auto-split (▼ pacing per source boundary). 仅 mountPanelHeader() 退化为 no-op.

**Fix**:
1. `ink-dialog.ts` mountPanelHeader → 永远 return (no-op).
2. drawPanel → remove `stripSpeakerPrefix` call. NPC body keeps `Lisa：` inline prefix.
3. avg-architecture.md §1.3 表 update: header column → "无" for all sources.

**File**: `game/src/render/dialog/ink-dialog.ts` + spec update

**Test**: dev 跑 Day 1 morning_briefing → panel 永远无 header. NPC speech step → body 显示 `Lisa："诶, 你先用吧。"` inline (跟 image 38 reference 一致). italic monologue → 字色变 cool gray italic 但无 header.

**Estimate**: 15 min

**Status**: ✅ done in commit `0e53b60` (batch 25, 2026-05-07). drawPanel always paints panel BG + body only (no header bar). Body region restored to full panel. Removed stripSpeakerPrefix call. headerBarBg / headerLabel / HEADER_BAR_H / PANEL_BODY_Y / etc constants + state deleted. body styling preserves italic cool gray for monologue, upright cream for narration / NPC.

---

## P0 — Bug #38 已完成 — pause / back-to-main 按钮缺失

### Q-Y · Bug #38 — 游戏过程中无法回主菜单 / 重新开始

**Why**: GM playtest 2026-05-06 — 玩家进入 gameplay 后无 pause 按钮 / 主菜单按钮. 唯一退出路径 = ink end → gameover Archive screen 才出现 [新游戏] / [回主菜单]. 其他时刻只能硬清 localStorage 重启.

**Fix**: 加 always-visible **菜单按钮** 在 canvas 右下角 (或左上角 — 跟 calendar widget 不冲突的地方):
- 16×16 px 三横线 hamburger icon (公文印章风, 1 px stroke `#2A1F14` on cream `#E8E0CC`)
- Click → mount Preact pause overlay:
  - `[继续]` → close overlay
  - `[回主菜单]` → trigger same `triggerNewGame()` logic that gameover-end fix uses (clearCurrentRun + reload)
  - `[新游戏]` (alias of 回主菜单) — 当前没区分新游戏 vs 回主菜单, 一个按钮即可
- Esc 键也 trigger overlay (keyboard accessibility)

**Files**:
- 新建 `game/src/render/menu/pause-menu.tsx` (Preact overlay, ~50 lines)
- `game/src/render/scene/workstation.ts` — mount hamburger button at canvas corner
- `game/src/main.ts` — listen Esc key to toggle pause overlay

**Test**:
- dev 跑 Day 1 → 点右下角菜单按钮 → overlay 弹出 → 点 [回主菜单] → reload → 进 main_menu (no save) → 干净开始
- Esc 键同样 trigger overlay

**Estimate**: 30 min

**Status**: ✅ done in commit `ed16579` (batch 24, 2026-05-07). Hamburger button at workstation top-right (516, 8 — shifted from 614 to clear Q-N HUD); click triggers `flow.request({ kind: 'pause', resumeTo: cur })`. PauseMenu's [回主菜单] reworked to hard-restart (clearCurrentRun + dialogState.reset + reload), label clarified to "回主菜单（清存档）".

---

## 🆕 P0 — Bug #37 — NPC speech body 跟 header 重复 (10 min fix)

### Q-X · Bug #37 — strip NPC name prefix from body when header already shows it

**Why**: GM playtest 2026-05-06 image 36 — panel header 显示 `[ Lisa ]` + body 显示 `Lisa："好的。我准备一下。"`. 名字 visible 2 次. 跟 Q-T 改 narration 无 header / NPC 有 header 后, body 里旧的 `Name：` prefix 成为冗余.

**Fix**: paintStep 内当 source.kind === 'npc' 时, 从 body text 移除 leading `<displayName>：` (或 `**<displayName>**：`) prefix:

```ts
function stripSpeakerPrefix(body: string, npcDisplayName: string): string {
  // matches "**Lisa**：..." or "Lisa：..." at start
  const re = new RegExp(`^\\s*\\*?\\*?${escapeRegex(npcDisplayName)}\\*?\\*?[：:]\\s*`);
  return body.replace(re, '');
}
```

调用点: paintStep 内 mountPanelBody 之前, if source NPC → body = stripSpeakerPrefix(body, source.npcName).

**Also**: 同 strip alias (大伟 / 周哥 / etc per source-detector LEGACY_ALIAS_NORMALIZE).

**File**: `game/src/render/dialog/ink-dialog.ts` paintStep + `source-detector.ts` (export stripSpeakerPrefix or add helper)

**Test**:
- vitest: `stripSpeakerPrefix("Lisa：'好的'", "Lisa")` → `"'好的'"`
- vitest: `stripSpeakerPrefix("**David**：'兄弟'", "David")` → `"'兄弟'"`
- dev: Day 1 Event 1.2 茶水间 → Lisa 说话 step → header `[ Lisa ]` + body 仅 `"诶, 你先用吧。"` 不含 `Lisa：` prefix

**Estimate**: 10 min

**Status**: ✅ done in commit `7d3f29c` (batch 24, 2026-05-07). New `stripSpeakerPrefix(body)` pure helper in source-detector.ts; strips known NPC names + aliases from leading `Name：` / `**Name**：`. Called by drawPanel only when source.kind === 'npc'. 9 new vitest cases.

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

**Status**: ✅ done in commit `70a4b95` (batch 23, 2026-05-06). New `calendar-widget.ts` with 80×80 desk-calendar visual: paper BG + 装订红 banner with month label + 7×5 date grid (past gray / current red ring / weekend red / weekday ink); self-binds to onDateChanged. workstation.ts swapped from sprite path to `mountCalendarWidget()`.

---

## 🆕 P0 — Bug #29 (REVIVED) Status HUD always-visible top-right

### Q-N · Status HUD top-right + choice flash (per avg-architecture.md §2.4 v2 calibration)

**Why**: GM playtest 2026-05-06 看到 daily_recap 把 "今日 KPI: +105 / 今日 钱: 5502 / 今日 状态: 72/100" 渲到 panel 当 monologue, 反馈"这种状态不应该显示给用户, 而是在右上角对 KPI、钱、自我状态的变化". → **revert 之前 §2.4 'no always-visible HUD' 决定**, 改 always-visible HUD.

**Spec source**: `design/vertical-slice/avg-architecture.md` §2.4 v2 (just updated).

**Spec brief**:
- Pixi Container at `(canvas.W - 100, 16)`, 80×72
- 3 行 cream `#E8E0CC` 10pt: `KPI: 105 / 200` + `钱: ¥5,502` + `状态: 72 / 100`
- BG `#1A2A38` + alpha 0.85 + 1px border `#2A1F14`
- 实时绑 `kpi.onChanged` / `money.onChanged` / `state.onChanged` (or energy module if state-name diff)
- 选完 sticky → 对应行 flash `+N`/`-N` 0.8s + 数值 500ms tween

**Files**: 新建 `game/src/render/hud/status-hud.ts` + `mountWorkstation` 加 mount + `ink-dialog.ts advanceChoice` 后 trigger HUD flash

**Test**:
- dev 跑 Day 1 Event 1.2 → 选 [让 Lisa 先] → HUD "状态" 行 flash + tween
- HUD 永远 visible 右上角 (不 auto-hide)

**Estimate**: 2-3h

**Status**: ✅ done in commit `93bc3c7` (batch 24, 2026-05-07). New `src/render/hud/status-hud.ts` — 80×72 panel at (540, 16) reading ink VARs kpi/money/state with per-row +N/-N flash badge (打工人黄/红 800ms fade) + value tween. mountInkDialog now accepts `onAfterAdvance` callback; workstation wires statusHud.refresh. Hamburger button shifted left (614→516) for clearance.

---

## 🆕 P0 — Bug #36 — 小物品贴图 position + 透明 BG

### Q-W · Bug #36 — phone / fruit_bowl 等 prop 位置撞 panel + 含 cream BG 矩形

**Why**: GM playtest 2026-05-06 image 35: phone prop mounted at desk-center y≈220, 跟 panel (y=240-336) + sticky (y=175-238) 重叠. 且 phone PNG 含 cream `#E8E0CC` 背景矩形 (W5 源图未透明), 不协调.

**Fix 2 子项**:

**A. Position 移到 off-panel 区**:
- `workstation.ts` 内 transient prop mount 位置改:
  - `phone` → `(580, 130)` (top-right corner, 不撞 panel + 不撞 HUD)
  - `fruit_bowl` → `(60, 220)` (left-mid edge, 不撞 panel + 不撞 calendar widget)
  - 大小调小: scale 0.06 (or matching pixel art smaller)
- 其他 transient prop 同 review (mug 在 desk-bottom-left 不动 — 不冲突 panel)

**B. 透明 BG (chroma-key remove cream)**:
- Pixi-side approach: `applyChromaKey(sprite, color: 0xE8E0CC, tolerance: 8)` — 替换 cream pixel 为 alpha 0 (custom shader 或 canvas 2D pixel manipulation 后 wrap as Texture)
- 或 `prop-entity.ts` `cropEdges` 字段加 `bgColor` removal mode
- 备选: W5 round-N regenerate phone / fruit_bowl with explicit `transparent_bg` flag in prompt + re-cut

**Recommend**: A + B Pixi-side chroma-key (跟现 cropEdges 同 module). Round-N W5 regenerate 是 backup if chroma-key 看着不干净.

**Files**:
- `game/src/render/scene/workstation.ts` — 改 phone / fruit_bowl mount position + scale
- `game/src/render/diegetic/prop-entity.ts` — 加 chroma-key utility (~30 lines pure helper + apply at texture load)

**Test**:
- dev 跑 Day 2 Event 2.2 (David PPT) → ink emit `# prop: phone_with_badge` → phone 出现在右上角 (180, 130)，不撞 panel + 不含 cream BG 矩形

**Estimate**: 1-2h (A: 5 min, B: 1h chroma-key)

**Status**: ✅ done in commit `0cfea3e` (batch 24, 2026-05-07). A: phone (380,252)→(580,130) scale 0.1→0.06; fruit_bowl (510,250)→(60,220) scale 0.12→0.06. B: new `chroma-key.ts` with canvas2D `loadChromaKeyedTexture(url, {color, tolerance})`; PropEntitySpec `chromaKey?` field threads through `createPropEntity` + `setState`. Wired both phone + fruit_bowl with `{ color: 0xe8e0cc, tolerance: 8 }`.

---

## 🆕 P0 — Bug #34 — panel text overflow auto-paginate

### Q-V · Bug #34 — long narration 段被 panel 96px 截断, 需 auto-paginate ▼

**Why**: GM playtest 2026-05-06 post Q-T+Q-U: Day 1 Event 1.2 茶水间 narration 5+ 段 prose 装不下 96px panel, 末尾被 mask clip 截断 (e.g. "你跌坐..." 切掉).

**Root cause**: Q-L Bug #25 reverse 让 panel 缩到 96px (sticky 占 desk surface 不能 overlap). Long narration step 装不下.

**Fix (Option A — engine auto-paginate)**:
- paintStep 内 mount panel body Text 后, measure `text.height`
- if `text.height > panel inner height` (140-2*4 padding = 132? — depends on actual size; calculate from PANEL_H - HEADER_H - 2*PADDING):
  1. Find natural break point (paragraph boundary / sentence boundary) such that rendered chunk fits within capacity
  2. Render chunk, mount ▼ continue affordance
  3. Stash remaining text on `pendingPanelText` (intra-paint state)
  4. Click ▼ → drain stash, next paint shows next chunk + ▼ if still overflow, etc.
  5. Last chunk: ▼ behavior reverts to existing (推进 step / show choices)

**Or simpler (sub-option A')**: Use existing `# pagebreak` pendingChunk machinery. When measure overflow detected, engine inserts virtual `# pagebreak` at split point, treats as if ink emit'd it. Then existing ▼ continue affordance + step() pendingChunk drain handles the rest.

A' 更 clean — reuse existing mechanism, no new state. Recommended.

**File**: `game/src/render/dialog/ink-dialog.ts` paintStep + 新 helper `panel-paginate.ts` (~30 lines pure measure + split helper)

**Test**:
- vitest: `paginate` pure helper unit (input long text + maxLines=N → output chunks array)
- dev: Day 1 Event 1.2 茶水间 → 验证 5+ 段 prose 分 2 paint, ▼ click 推进 → 第 2 paint 显示 "你跌坐..." 完整

**Estimate**: 1-2h

**Status**: ✅ done in commit `f027a6d` (batch 24, 2026-05-07). Sub-option A' chosen — runtime auto-inserts virtual pagebreak via existing pendingChunk machinery. New `panel-paginate.ts` with pure `paginateAtSentenceBoundary(text, budget)` (CJK 。？！ → ASCII ?! → newline → forced cut); default budget 130 chars. runtime.ts step() splits when text > BUDGET, stashes tail. ink-dialog choice case shows ▼ first when paused (paginated head with choices) and mounts sticky on last page. 11 new vitest cases.

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

**Status**: ✅ done in commit `bab24ca` (batch 24, 2026-05-07). New `src/render/npc/npc-registry.ts` (~145 LOC). `parseNpcId(tagValue)` longest-prefix match (lao_zhou_drinking_tea → lao_zhou; food_court_auntie → cafeteria_auntie alias; lao_li → li_ayi alias). NPC_TABLE covers all 11 named NPCs with workstation anchors (sprite anchor 0.5/1 = bottom-center). Workstation listens on `sceneState.on('npc')` to mount + `on('scene')` to clearAll. Idempotent — repeat tags are no-ops. 19 new vitest cases.

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
