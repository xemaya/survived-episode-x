# AVG-time Architecture — Dialog UI + Daily Pressure (post-pivot canonical spec)

> Status: 第 1 版 authoritative
> Author: Game Designer (GM)
> Last Updated: 2026-05-06
> Supersedes:
> - `archive/design-pre-pivot/gdd/card-play-dialogue-ui.md` (entire)
> - `archive/design-pre-pivot/gdd/hud-diegetic.md` (entire)
> - `archive/design-pre-pivot/gdd/kpi-review-game-over-ui.md` (rewritten via Bug #31 cinematic)
> - `archive/design-pre-pivot/gdd/daily-weekly-recap-ui.md` (entire)
> - `archive/design-pre-pivot/gdd/event-script-engine.md` (replaced by Ink + inkjs)
> - `archive/design-pre-pivot/gdd/scene-day-flow-controller.md` (FSM redesigned)
> - `archive/design-pre-pivot/gdd/tutorial-onboarding-system.md` (rewritten via Bug #23)
> - `design/art/art-bible.md` §7.1 "Diegetic vs Screen-Space"（仅 UI/UX 部分; 视觉层仍 authoritative）
> - `design/art/art-bible.md` §7.4 "卡片动画"（全部）
> - `design/art/art-bible.md` §2.4 "下班抉择节点 三张选项卡"（卡片实现部分；情绪/光线 spec 仍 authoritative）

> 本 doc 是 AVG pivot (2026-05-05) 之后 dialog UI + daily pressure 设计的**新 source of truth**。worker clone 写代码时 reference 本 doc, 不再 reference archived GDDs 或 art-bible §7.1/§7.4。

---

## 0. 设计基线（重读 confirmed 不变）

引自 CLAUDE.md + `tone-bible.md` + `protagonist.md` + `npcs.md` + `series-structure.md`:

- **5 红线** (反主角口吻 / NPC 算计 / 主语翻转 / 写真不写好 / 朋友圈测试) — intact
- **笑/泪 8:2** — intact
- **主角"清醒共谋者" voice** — narration "你" / 内心独白 italic _我_
- **不可能三角** — KPI / 钱 / 状态 + 双端 GO + 病倒 cap = 6
- **52 集 finite** — Lisa 跨 S1-S3 走/留 E12, 5 路径 finale, 6 happy ending variants
- **Ink 是叙事 DSL** — 所有 events + daily choices 写在 .ink

**已 deprecated 的设计构件**:
- AP = 8 时间槽 / 天 — 删除（user calibration 2026-05-06）
- "卡片驱动" / "Defense card" / "Offense card" — 删除（design pivot 2026-05-05）
- Godot scene tree / autoload / signal ownership — 删除（engine pivot 2026-05-03）

---

## 1. Dialog UI Architecture — 公文报告框 (per Shift 2 Option C)

### 1.1 设计 spirit

**art-bible §3.3 UI 母题：公司内刊 + 打卡机界面** —— 所有面板使用 0 圆角直角矩形, 边框线 1 px, 模拟复印机打出的表格质感。

**对话框无气泡, 改"报告格式框"** —— 顶部 8 px 灰色标题栏 (公文抬头风); 与环境几何同族, 不跳出世界观。

→ 这条 spirit 在 AVG 时代仍 100% authoritative。本 doc 把它实例化成 dialog rendering spec。

### 1.2 layer 简化决策（核心架构）

**3 layer total, 不再有 5 layer**:

| Layer | 内容 | 位置 | 字号 / 样式 | 是否 always visible |
|---|---|---|---|---|
| **Panel (报告格式框)** | narration + 内心独白 + NPC speech, 全部 inline | 底部, y=240-336 (96 px) | 12 pt 思源黑体 Regular | 永远 visible (除 ended phase) |
| **Sticky rack** | 玩家选项 (3 sticky notes) | 桌面上方, y=175-238 | 10 pt sticky-fit | 仅 choice phase |
| **▼ Continue affordance** | pagebreak 翻页提示 | panel 右下角, 16x16 | 三角符号 | pagebreak 时 visible |

**3 layer 之外删除的**:
- ~~Bubble (NPC speech)~~ — DELETED, 改 inline 在 panel
- ~~Monologue 顶部独立 layer~~ — DELETED, 改 inline 在 panel
- ~~Header band 短 prompt~~ — DELETED, 短 prompt 也走 panel

### 1.3 Panel "报告格式框" detail spec

> **v3 (2026-05-07)**: header bar 全删 (per user playtest 反馈). 所有 source 通过 body 字体/字色 + inline NPC prefix 区分.

Panel 是核心载体。所有文字（narration / 内心独白 / NPC speech）都进 panel。无 header bar — 仅 body 字体/字色区分 source。

**Panel 结构**（per art-bible §3.3 spirit）:

```
┌─────────────────────────────────────────────┐
│  [<source label>]                           │ ← 8 px 灰色 header bar (公文抬头风)
├─────────────────────────────────────────────┤
│                                             │
│  正文内容 (12 pt 思源黑体 Regular)           │ ← inner padding 4 px
│                                             │
│                                          ▼  │ ← 16x16 continue affordance (右下)
└─────────────────────────────────────────────┘
   y=240-336, full width, 1 px border #2A1F14
   panel BG #5A7080 (cubicle navy) + alpha 0.85
```

**v3 Calibration (2026-05-07 user playtest)**: panel header bar **全删** (per "都没有" 决定). 所有 source 通过 body 字体/字色 + inline NPC prefix 区分, 不再用 header label. 详 §1.3a 下面 v3 表。

**v3 表 — 永远无 header**:

| 内容类型 | Header | Body 字色 | Body 样式 | Body 内容样例 |
|---|---|---|---|---|
| narration ("你...") | (永远无 header) | #E8E0CC cream | upright 12pt | "你 9:14 走到工位区。A 区——Lisa 工位斜对角。" |
| 内心独白 (italic _..._) | `[ 笑天 ]` | #A8B0C0 cool gray | italic 12pt | "_她还相信。我也相信过。_" → 渲染时去掉 `_..._` markdown |
| NPC speech | `[ <NPC name> ]` (例: `[ Lisa ]` / `[ 王总监 ]` / `[ 妈妈 ]`) | #E8E0CC cream | upright 12pt with "" punctuation | "Lisa："你看下这个行不行……"" |
| Hybrid 段（同一 step 含多个 source） | (engine 自动分 step) | — | — | 见 §1.4 |

**关键**: Panel 永远只显示**1 个 source 的内容**。如果 ink step blob 含多 source（narration + Lisa speech + 内心独白），engine 自动 split 成多 step paint, 每 step 单 source, 单 paint, 玩家点 ▼ 推进。

### 1.4 Engine auto-split policy（Bug #24 close）

`runtime.ts step()` 累积 chunk 时检测每 chunk 的 source:

```
detect_source(chunk_text, chunk_tags):
  if chunk_tags includes "speaker" tag → source = NPC name
  elif chunk_text starts with "Lisa：" / "David：" / etc (no tag) → source = NPC name (legacy fallback)
  elif chunk_text wrapped in italic _..._ → source = monologue
  else → source = narration
```

**Auto-split rule**: 当 chunk N 的 source ≠ 已累积的 source, 插入 virtual pagebreak —— 当前累积成为 step 1 paint, chunk N 开始 step 2 paint。

**结果**:
- "你 9:14 到工位。A 区——Lisa 工位斜对角。" (narration) → 1 paint, header `[视角]`
- ▼
- "_她还相信。我也相信过。_" (monologue) → 1 paint, header `[笑天]`
- ▼
- "Lisa："新剪的。想换个心情。"" (NPC) → 1 paint, header `[Lisa]`
- ▼
- "你回头看了她一眼。" (narration again) → 1 paint, header `[视角]`

每 step 单 source, ▼ 推进, **永远不会同 panel 塞两人对话或多个 source**。

### 1.5 Choice phase

**Sticky rack 浮在 panel 上方** (panel 仍可见):

```
┌─────────┐  ┌─────────┐  ┌─────────┐
│ 选项 1  │  │ 选项 2  │  │ 选项 3  │   ← y=175-238 desk surface
└─────────┘  └─────────┘  └─────────┘

┌─────────────────────────────────────────────┐
│  [ <last source> ]                          │   ← panel 仍显示选项前最后一段
├─────────────────────────────────────────────┤
│  正文 (玩家做选择前看到的最后内容)              │
│                                          ▼  │
└─────────────────────────────────────────────┘
   y=240-336
```

**关键**: 选项出现时 panel **不 hide**。玩家可以同时看选项 + 看上一段 context。点选项 → 选项触发 effect → 下一 step paint → panel 内容更新。

### 1.6 ▼ Continue affordance 触发场景

| 触发场景 | 行为 |
|---|---|
| Ink emit `# pagebreak` tag | ▼ 显示, 等点击, 点击后 step() 推进 |
| Engine auto-split (1.4) 边界 | 同上 |
| step.text 长 > 6 行 (panel 装不下) | ▼ 显示, 点击翻页 |
| step 末尾 + 含 choices | ▼ 显示, 点击后 sticky rack mount, panel 保留显示 step.text |
| step 末尾 + 无 choices + 有下一 step | ▼ 显示, 点击 step() 推进 |
| step 末尾 + ink ended | ▼ **不**显示, 直接 transit 到 gameover (Bug #21 fix) |

### 1.7 Stateless paint discipline

**每次 paintStep() 顶部 unconditional teardown 所有 layer**:
```ts
function paintStep(step) {
  clearPanel();      // remove all panel children
  clearStickyRack(); // remove all sticky
  clearContinue();   // remove ▼
  // then mount fresh based on step + phase
  ...
}
```

**没有 shared mutable state 跨 paint**。每 paint 完整 self-contained。

→ 解 Bug #18 / #18-regression / #29 (panel 不再 stale leak 跨 step)。

### 1.8 实现影响（指导 W1 重构）

**Files to rewrite**:
- `game/src/render/dialog/dialog-phase.ts` — 简化 7 phase → 3 phase (`narration` / `choice` / `ended`)
- `game/src/render/dialog/ink-dialog.ts` — paintStep 重写 (stateless + header bar + 3 layer)
- 删除 `game/src/render/dialog/speech-bubble.ts` + `speech-bubble-layout.ts` + `speaker-parser.ts` + `npc-anchors.ts` (bubble 不再需要)
- 删除 `game/src/render/dialog/internal-monologue.ts` (合并入 panel)
- `game/src/render/choice/sticky-notes.ts` + `sticky-notes-layout.ts` — 保留, 仅调位置 y=175-238

**Files affected by source detection**:
- `game/src/ink/runtime.ts` — `step()` 加 auto-split logic
- `game/src/render/dialog/source-detector.ts` (NEW) — `detect_source(text, tags)` 纯 helper

**Bug close 副作用**:
- Bug #13 / #18 / #18-regression / #19 / #20 / #24 / #25 — 全副作用 close
- 因为它们都是当前多 layer 架构的副作用, 简化到 3 layer 后失去 trigger condition

---

## 2. Daily Pressure Visualization (per Shift 3 Option 2+3 mix)

### 2.1 设计 spirit

CLAUDE.md "AVG（剧情驱动）+ 王权式日常选择平衡" —— AP 删除后王权式 pressure 需要新载体。

User calibration: "删 AP, KPI Review 处刑感, 不要那么 AVG 化"。

→ Daily-level pressure 通过 **2 种 explicit mechanism** 实现:

### 2.2 Weekly Meter (周一 / 周五出现)

**Trigger**: 周一 morning (Day 1, 8, 15, 22, 29) + 周五 evening (Day 5, 12, 19, 26)

**形式**: 单次 modal Preact overlay, 半屏覆盖, 不阻断 narrative 太久 (~3 秒 + 玩家可点击 dismiss)

**Layout**:

```
┌──────────────────────────────────────────┐
│  [ 第 1 月 · 第 1 周 · 周一 morning ]    │  ← 公文抬头
├──────────────────────────────────────────┤
│                                          │
│  本月 KPI 累积:    ▓▓▓▓░░░░░░  45/100   │  ← 横向进度表格 (art-bible §3.3)
│  本月阈值:                    100        │
│  钱:               ▓▓▓▓▓▓░░░  ¥6,400    │
│  状态:             ▓▓▓▓▓▓▓░░  72/100    │
│  病倒次数:         ░ ░ ░ ░ ░ ░  0/6     │  ← 6 cell 格子
│                                          │
│  [ 上周 / 本月 趋势 ]                    │
│  KPI:    +18 (上周) +18 (本月)          │
│  钱:     +160 (上周) +1,200 (本月)      │
│  状态:   -8 (上周) -28 (本月)           │
│                                          │
│           [ 开始本周 ]                    │
└──────────────────────────────────────────┘
```

**视觉 spec**:
- BG: `#1A2A38` (art-bible §4.4 "系统提示背景, 屏幕蓝光加深 = 囚禁") + alpha 0.95
- Border: 1 px `#2A1F14`
- Bar fill 色: KPI = `#C8A85A` (打工人黄) / 钱 = `#C8963C` (老板金, 但 ≤3% pixel) / 状态 = `#5A7080` (灰蓝)
- 病倒格: 红色 `#C83428` 当前格 + 灰色未来格 (color blind safe per art-bible §4.5: 加 1 px 斜线纹理)
- 字体: 公文宋 12 pt
- Tone: HR-speak 风 (anti-Pillar 1)

**实现 file**: 新建 `game/src/render/menu/weekly-meter.tsx` (Preact overlay)

**Trigger logic** (in `game/src/flow/day-cycle.ts`):
```ts
if (calendar.currentDay % 7 === 1 && calendar.timeOfDay === 'morning') {
  flow.showWeeklyMeter('week_start');
} else if (calendar.currentDay % 7 === 5 && calendar.timeOfDay === 'evening') {
  flow.showWeeklyMeter('week_end');
}
```

### 2.3 Weekly Tradeoff Choice (周五 weekly_report)

**Trigger**: 周五 evening, day_5/12/19/26 daily_recap 之前

**形式**: 一个 explicit 选项 sticky rack, 3 选 1, "我这周牺牲什么换什么" 决策

**Tradeoff template**:
- A: KPI ↑ vs 状态 ↓ (加班拼一拼)
- B: 钱 ↑ vs KPI ↓ (拒绝 David 抢功 = 自己写, 更慢但归你)
- C: 状态 ↑ vs KPI ↓ (装病 / 早走 / 摸鱼)

**主语翻转 原则下 sticky 标签不显式数值**, 而是 NPC / 物 / 时间陈述:

| Sticky 标签 (≤6 字) | 隐藏 effect |
|---|---|
| `[加班 V11]` | KPI +5, 状态 -10 |
| `[自己改]` | KPI -3, 钱 +50 (overtime allowance) |
| `[6 点准时走]` | KPI -5, 状态 +5 |

3 sticky 选 1, 选完 ink 自动 advance, 数值 effect 通过 ink VAR 写入。

**实现**: ink content 层 (W3 / S3 ink writer) 在 episode 内 day_5/12/19/26 加 `weekly_tradeoff` stitch with 3 choices。**不需要 engine 改动**。

### 2.4 Status HUD (always-visible top-right + choice flash)

**Calibration 2026-05-06 (post-playtest reverse)**: User 试玩看到 daily_recap stitch 把 "今日 KPI: +105 / 今日 钱: 5502 / 今日 状态: 72" 当 monologue 渲染到 panel, 反馈"这个状态不应该显示给用户, 而是在右上角对 KPI、钱、自我状态的变化"。

→ Spec **flip back to always-visible right-top HUD**. Diegetic prop (mug/monitor/calendar/phone/fruit_bowl) 仍保留作 ambient flavor, 但**数字 visualization 走 explicit HUD**, 玩家随时能看到三要素当前值.

**Spec**:

A. **Always-visible top-right HUD**:
- Pixi Container at `(canvas.W - 100, 16)` — 80×72 size, top-right corner
- 3 行:
  - `KPI: 105 / 200` (current actual / monthly threshold)
  - `钱: ¥5,502`
  - `状态: 72 / 100`
- BG: `#1A2A38` (屏幕蓝光加深 per art-bible §4.4) + alpha 0.85
- Border: 1 px `#2A1F14`
- Font: 思源黑体 Regular 10 pt cream `#E8E0CC`
- 实时绑 `kpi.onChanged` / `money.onChanged` / `state.onChanged` (state 是不可能三角"离家近" 的代名 ≈ energy module)

B. **Choice effect flash**:
- 玩家点 sticky 选完 → 对应 HUD 行 trigger flash:
  - 文字临时变 `+N` / `-N` 红色/绿色 0.8s, 然后 fade 回正常显示
  - 数值同步 500ms tween 从旧值 → 新值
- 如多个属性同时变, 多行同时 flash

C. **Daily_recap stitch 内 stat 数字 block 删除** (per Bug #35 below):
- ink 不再 emit "今日 KPI: +105 / 今日 钱: 5502 / 今日 状态: 72/100" 这种 stat readout
- daily_recap 仅保留 "关键时刻 today: ..." narrative summary (笑天 voice)
- 数字始终在 HUD 可见, 不需要 stitch 内重复

D. **Diegetic prop 仍保留** (overlap concession):
- monitor 4-frame swap / mug 5-frame swap / bank app push / fruit_bowl 仍按 ink `# prop:` tag 切换
- 它们是 ambient atmosphere, 不是数值 source-of-truth (HUD 才是)
- 玩家通过 prop 感知 mood, 通过 HUD 感知 number

E. **Emergency modal** 保留为 critical alerts:
- KPI > monthlyThreshold * 1.4 → 王总监 cue
- 状态 < 20 → bank app push
- 病倒 5/6 → scene tag 切走廊刺眼

→ 这些是 high-friction 显示, HUD 是 low-friction always-on。

**Files**:
- 新建 `game/src/render/hud/status-hud.ts` (~80 lines, Pixi Container + 3 Text + listeners + tween)
- `mountWorkstation` 加 mount status-hud
- `ink-dialog.ts advanceChoice` 后 trigger HUD flash (kpi/money/state delta from before/after choice)

**Test**:
- dev 跑 Day 1 Event 1.2 → 选 `[让 Lisa 先]` (lisa_score +3, state +0) → 验证 HUD "状态: 80 → 80" + lisa_score 不在 HUD (那不是三要素)
- dev 跑到 daily_recap → 验证 panel 不再有数字 block
- HUD 永远 visible 在右上角

**Estimate**: 2-3h W1 + 30min W3 (ink sweep daily_recap stitch 删除 stat lines)

### 2.5 KPI Monthly Review Cinematic (Bug #31 spec, simulation 心跳)

详 `p5-qa-bug-reports.md` Bug #31 + W1 task queue Q-Q。**这一节是 simulation 主轴**, 已经在 task queue 内 spec'd, 本 doc 不重复。

---

## 3. art-bible 关系（Shift 1 同意条款）

### 3.1 art-bible 仍 authoritative 的部分

视觉层全部 authoritative:
- §1 Visual Identity Statement (第一眼认同 / 第二眼刺破 / 格子压人 / 时钟光语 / 喜丧美学)
- §2 Mood & Atmosphere (6 个状态情绪光线 spec)
- §3 Shape Language (角色剪影 / 环境几何 / UI 形状 / Hero vs Supporting)
- §4 Color System (主调色板 + 语义色词典 + 区域色温 + UI 子板 + 色盲安全 + 点缀色)
- §5 Character Design (玩家剪影 + 9 NPC 原型 + LOD)
- §6 Environment Design (建筑 / 质感 / 道具密度 / 环境叙事 / 时间累积)
- §9 Reference Direction (5 个 reference 锚)

### 3.2 art-bible deprecated 的部分

仅 UI/UX/Engine 部分:

- **§7.1 Diegetic vs Screen-Space** — 整段 deprecated for AVG; 本 doc §1 + §2 supersede
- **§7.4 UI 动画 feel** "卡片抽起 喜丧式夸张 2 帧 overshooting" — 整段 deprecated (no cards)
- **§7.5 Gamepad / Focus 态 (Switch 预留)** — 整段 deprecated (focus 环 for Godot Diegetic, AVG 时代不需要)
- **§7.6 自动存档 + 地铁 5 秒进入** — 部分 (主菜单焦点 / Continue ≤ 2 次交互 / 地铁 5 分钟场景) 仍 valid; "AP 消耗后自动保存" 改 "ink choice 后自动保存"
- **§2.4 下班抉择节点 三张选项卡** — 视觉 spec (光线 / 情绪 / 描述词) 仍 authoritative; "三张选项卡 / 加班选项卡边框发光" 实现部分 deprecated, 改 sticky rack
- **§8 Asset Standards (Godot 4.6 specific)** — TextureImporter / project.godot / AnimationPlayer / CanvasModulate / Light2D / NodeTree 等 Godot-specific 全部 deprecated; **Asset 命名 + Palette 管理 + 像素尺寸层级** 仍 authoritative (W5 sprite 生产仍按这些)

### 3.3 处理方式

**不重写 art-bible**（成本大）。本 doc (`avg-architecture.md`) 通过 §3.2 的 list 显式 deprecation。任何 worker 看到 art-bible §7.1 应该来本 doc check 是否 deprecated。

未来如果 art-bible 写第 2 版, 应整合本 doc。

---

## 4. Migration / Implementation 优先级

详 `w1-task-queue.md`。本 doc 是 spec, queue 是 dispatch list。

简要 mapping:

| 本 doc 节 | W1 task | 估时 |
|---|---|---|
| §1 Dialog 重构 (报告格式框 + 3 layer + auto-split + stateless) | Q-R (NEW, 替代 Q-L)| 6-8h |
| §2.2 Weekly meter | Q-S (NEW, 替代 Q-N)| 2-3h |
| §2.3 Weekly tradeoff (ink 内容) | W3 round-4 (NEW, ink sweep) | 2h |
| §2.5 KPI Review cinematic (Bug #31) | Q-Q (existing) | 4-6h |
| §3.2 art-bible amendments doc | (本 doc 自带, no separate task) | done |
| Move design/gdd → archive/design-pre-pivot | (already done by GM 2026-05-06) | done |

**总 W1 估时**: 12-17h (3 batch). W3 单次 2h sweep.

---

## 5. 关于 user calibration "我们最终肯定不是 AVG" 的承接

本 doc §2 把 daily-level pressure 通过 weekly meter + weekly tradeoff + emergency modal + KPI Review cinematic 带回。这些都是 **sim hooks**, 不是 AVG-only patterns:

- Weekly meter = explicit numerical readout (sim feel)
- Weekly tradeoff = explicit player decision with quantifiable cost (王权式)
- KPI Review cinematic = monthly 处刑 (sim heart)
- Emergency modal = 紧急 sim feedback

→ AVG presentation + sim 担当。如果 user 后续想推更 sim 方向 (e.g. 加 Status HUD always-visible / 加每日 ap-like 资源), 本 doc §2 是 extension point。

---

## END
