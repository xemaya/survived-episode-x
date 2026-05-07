# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目状态（2026-05-05）

**《活过第 X 集》(Survived Episode X)** — 像素风反向 KPI 中国职场生存模拟。

经历过两次重大 pivot：
1. **2026-05-03 引擎切换**：Godot 4.6 / GDScript → TypeScript + Vite + PixiJS + Tauri + Preact
2. **2026-05-05 设计 pivot + 引擎选定**：从"卡牌驱动" 改为 "AVG（剧情驱动）+ 王权式日常选择平衡"，叙事层用 **Ink** (https://www.inklestudios.com/ink/) DSL

当前 phase: **P5 准备启动** —— 引擎层（inkjs runtime + Ink → JSON build pipeline + diegetic UI 升级）。Design slice (10 NPC + 60 daily choices + 4 episodes outline) 已 ready。

---

## 当前栈（active）

| 层 | 技术 | 路径 |
|---|---|---|
| **桌面打包** | Tauri 2 | `game/src-tauri/` |
| **构建工具** | Vite 6 | `game/vite.config.ts` |
| **UI 框架** | Preact + TypeScript 5 strict | `game/src/render/` |
| **渲染** | PixiJS v8 | `game/src/render/` |
| **叙事 DSL** | Ink + inkjs runtime | `design/vertical-slice/*.ink` (内容) + `game/src/ink/` (runtime, 待写) |
| **测试** | Vitest | `game/tests/` |
| **格式 / Lint** | Biome + lefthook | `game/biome.json` + `game/lefthook.yml` |
| **Schema 验证** | zod | `game/src/save/` |

---

## Active 目录（这些是 source of truth）

| 目录 | 用途 |
|---|---|
| **`design/vertical-slice/`** | **设计 slice 主战场**——series structure / 10 NPC / 主角 / tone bible / S1-S3 arcs / 12 episode .ink + daily choices / **avg-architecture.md AVG 时代 UI + pressure spec** / worker briefs + bug reports |
| `design/registry/entities.yaml` | 数值常量注册表 |
| `design/art/art-bible.md` | 美术风格规范（视觉层 authoritative；§7.1/§7.4/§7.5/§8 已 deprecated, 见 `art-bible-avg-amendments.md`）|
| `design/concepts/` | W5 visual reference (prompts + p5_ui samples) |
| **`game/`** | **TS 工程** —— P0-P5 已实现 Save / FSM / KPI / Effort / Energy / Archive / mug 5-frame / Ink runtime / dialog rendering / scene-state mirror / prop registry / sticky-note choices / KPI Review overlay |
| `assets/sprites/` | NPC + 工位 + UI sprite assets |
| `tools/` | Python 工具（cut_sprites / gen_image / asset_map）+ `ink-speaker-migrate.mjs` |

---

## Archived 目录（默认不读取）

**`archive/`** 包含 Godot 时代 + opening-video 时代 + 早期 TS 设计 artifacts + **2026-05-06 移过来的 design pivot 前 GDD + asset specs (`archive/design-pre-pivot/`)**。**默认不要读取本目录**——除非用户明确说"读 archive/" 或问到归档前的旧实现。

详见 `archive/CLAUDE.md` + `archive/design-pre-pivot/README.md`。

---

## Design Slice 当前状态（P5 启动前的 baseline）

`design/vertical-slice/` 内容（11 个文件 + 2 个 round-1 reply）：

```
design/vertical-slice/
├── series-structure.md            52 集 macro + 12 季主题 + endgame + 6 happy ending variants + 5 GO 类
├── npcs.md                        10 NPC (5 深 + 5 龙套) + 食堂阿姨 ambient + cross-NPC 矩阵
├── protagonist.md                 陈笑天 + 全 series 弧光 + 6 ending hooks
├── tone-bible.md                  5 原则 (去禁词化) + 笑/泪 8:2 比 + corpus
├── season-1-arc.md                Per-NPC 4-archetype scaffolding + S1 5 路径 lookup table + Quality Rubric
├── episode-1.md                   markdown 素材库（Round 1 分身写）
├── episode-2.md / 3.md / 4.md     markdown 内容（Round 1 分身写，待 Round 2 翻译 .ink）
├── episode-1.ink                  designer Day 1 + Day 2 morning 样例
├── episode-generation-brief.md    剧情分身 handoff (v2 .ink)
├── episode-generation-handoff-response.md   分身 Round 1 提交报告
├── episode-generation-round-1-reply.md      designer Round 1 回复 + Round 2 任务
├── daily-choices.md               60 个 daily choice markdown 内容（Round 1 分身写）
├── daily-choices.ink              designer 3 sample stitches + Session B 已开始翻译
├── daily-choices-handoff.md       日常选择分身 handoff (v2 .ink) + 分身 progress 回写
└── daily-choices-round-1-reply.md designer Round 1 回复 + Round 2 任务
```

### 关键设计决策（不要 redebate）

- **52 集 = 12 个月 × 4 集 + 4 集 endgame**——series finite，活过 E52 = happy ending
- **3 核心属性 = 不可能三角 mapping**：KPI（事多）/ 钱（钱多）/ 状态（离家近 = 个人自由 + 身心健康）
- **KPI 双端 GO**：< 50 被裁 / 累积 > 150 触发"晋升 = 处刑"
- **病倒次数 cap = 6**：第 7 次直接 game over
- **Lisa 弧光跨 S1-S3** (8-12 集)，**E12 才走/留**——不是 S1 finale
- **S1 finale = 笑天第一次 KPI Review 教学**（5 路径全过但都涨 threshold）
- **Diegetic prop**：mug 5-frame / 银行 app push / 水果盘 / phone / monitor / calendar — 都走 `# prop:` ink tag 触发 sprite swap (per `design/vertical-slice/avg-architecture.md` §2.4)
- **AP 已删除（2026-05-06 user calibration）**——王权式日常 pressure 由 weekly meter (周一/周五) + weekly tradeoff (周五 ink choice) + KPI Review cinematic (月末) 承载, 详 `design/vertical-slice/avg-architecture.md` §2
- **Ink 是叙事 DSL**——所有 events + daily choices 写在 .ink，编译到 JSON，inkjs 解释，TS 监听 state change 更新 PixiJS
- **Dialog UI = 公文报告框 + sticky 选项** (per `design/vertical-slice/avg-architecture.md` §1)——3 layer (panel + sticky + ▼), engine auto-split on speaker source, panel header bar 标 source `[视角]/[笑天]/[Lisa]/etc`

### 5 红线（vertical-slice 必守）

1. **反主角口吻**：主角永远不"励志 / 突破 / 完美 / 努力"——他"撑过去"、"麻木了"、"还在"
2. **NPC 算计原则**：NPC 永远为自己活，不为玩家服务
3. **主语翻转**：数值变化用 NPC / 物 / 时间陈述，不用"你"或"系统"
4. **写真不写好**：HR-speak / PUA / 周报体直接抄现实
5. **朋友圈测试**：真正中文打工人会截图发朋友圈吗？

详见 `design/vertical-slice/tone-bible.md` v2。

---

## P5 当前状态（2026-05-06）

P5 已 ship (Phase 1 + 大部分 Phase 2):
- ✅ Ink runtime + Vite 集成 + JSON build pipeline (W1)
- ✅ S1+S2+S3 全 12 集 ink 内容 (W3, ~14k+ lines)
- ✅ Sticky-note choices + speech bubble (即将合并入 panel) + monologue overlay (即将合并入 panel)
- ✅ # speaker / # scene / # npc / # prop / # pagebreak / # checkpoint tag 系统
- ✅ Save schema migration (apCurrent now optional, backward compat)
- ✅ Path interceptor for finale (`game/src/ink/path-interceptor.ts`)
- ✅ AP system 已删除 (2026-05-06)
- ✅ Status HUD top-right (gating 重新评估—— per avg-architecture.md §2.4 改 diegetic-first)

P5 待办 (per `design/vertical-slice/w1-task-queue.md`):
- **Dialog 重构** (per `avg-architecture.md` §1) — 3 layer 简化 + 公文报告框 + 头标识 + auto-split + stateless paint (Q-R)
- **Weekly meter** (per `avg-architecture.md` §2.2) — 周一/周五 modal (Q-S)
- **Weekly tradeoff ink content** (per `avg-architecture.md` §2.3) — W3 round-4 sweep
- **KPI Review cinematic** (Bug #31 per `avg-architecture.md` §2.5) — Q-Q
- **First-time tutorial** (Bug #23 second half) — Q-K-2nd
- **T04 scene registry** + **T05/T06 NPC sprite slots** — 工位 BG 切换 + NPC 立绘 mount

**Flag system** + **跨 episode / 跨 season hidden flag 累积** (病倒次数 / cumulative_hero_count / lisa_score / etc) ✅ 已实装 in ink VAR + episode-1.ink 顶部 declare。

---

## Common Commands

```bash
# Dev server
cd game && pnpm dev

# Type check
cd game && pnpm typecheck

# Tests
cd game && pnpm test

# Tauri dev
cd game && pnpm tauri dev

# Tauri build (macOS native bundle)
cd game && pnpm tauri build
```

详见 `game/README.md`。

---

## 工作风格

- 这是 indie 单人项目（你 + 你 + 我 = designer + worker clones + engineer me）
- **不要重建 framework ceremony**——no autopilot loops / no `Status: Complete` markers / no ADR governance gates
- **设计文档是 source of truth + worker clone 的 reference**——不要把决策 inline 散落在代码里
- **clones 写 .ink + .md，designer (我) 写 design + engine code + reviews**
- 见 `design/CLAUDE.md` 关于 design 写作风格

---

## 引擎决策路径（如果你 confused）

如果你看到代码里有"Defense card" / "Offense card" / "card hand" / "card play" 抽象——**这些是 P0-P4 早期 TS 阶段的产物，待 P5 重写**。设计 pivot 后核心是 events + choices，不是 cards。

如果你看到 markdown spec 里有"Day 1-7" 跨整月的剧情压缩 —— 这是 pre-arc draft（episode-1.md），已被 season-1-arc.md v2 + 4 个 episode-N.ink superseded。

如果你看到 archive/ 里的 ADR / story 文档 —— **这些是 Godot 时代的**，跟当前 TS+Ink 栈无关。
