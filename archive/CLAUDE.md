# archive/ — Historical artifacts (DO NOT auto-read)

> **指令给未来 CC session**：本目录是历史归档。**默认不读取本目录内任何文件**——除非用户明确要求"读 archive/" 或问到归档前的旧实现。
>
> 本目录的文件**只是历史 reference**，不是 source of truth。**不要根据本目录推断当前项目状态**——当前状态以 `/CLAUDE.md` + `/design/vertical-slice/` 为准。

---

## 归档时间线

**2026-05-05**：design pivot 完成（card → AVG）+ 引擎选择完成（TS+PixiJS+Tauri+Ink）后，整理项目目录。把 3 类历史 artifacts 归档：

### 1. Godot 时代（pre-2026-05-03）

项目原本是 Godot 4.6 + GDScript 实现。2026-05-03 决定迁移到 TS+Tauri 后，这些 Godot artifacts 不再 active：

- **`godot-architecture/`**（396KB，17 ADRs + architecture.md + control-manifest.md + tr-registry.yaml + architecture-review-report）— 描述 Godot scene 树、autoload 顺序、信号 ownership 等 Godot-specific 决策。**TS+Ink 栈不适用任何 ADR**（除了 ADR-0017 NPC 关系 schema 部分思路保留）
- **`godot-stories/`**（1.5MB，20 epics × 234 stories）— 旧 framework 的 epic/story 跟踪体系。design pivot 后大部分故事跟新设计不一致

**这些 docs 唯一保留价值**：5 NPC 的早期 GDD 思路 / KPI 公式推导 / 设计原则——但这些已经被 `design/gdd/` + `design/vertical-slice/` superseded。

### 2. Pre-engine-switch handoff

- **`HANDOFF-2026-05-03.md`**（12KB）— 2026-05-03 引擎切换那天写的 handoff。当时 TS 项目刚启动 P0，Godot 文件被物理删除。**纯历史快照，不再有 actionable 信息**

### 3. Opening video（pre-design-pivot）

design pivot 之前我们做过一个 opening video（pixel-art 主角通勤场景）。pivot 之后这个 opening 不一定贴合最终游戏 tone：

- **`opening-video-output/`**（102MB，含 opening_v01.mp4 + clips + composed_frames + titles + .video_runs）— 视频生成 output
- **`early-ts-superpowers/specs/2026-05-03-opening-video-design.md`** — 视频设计 spec
- **`early-ts-superpowers/plans/2026-05-03-opening-video.md`** — 视频生成 plan

### 4. Pre-design-pivot 早期 TS 设计

- **`early-ts-superpowers/specs/2026-05-04-game-design-proposal.md`** — 2026-05-04 早期 TS 阶段的游戏设计提案。**已被 `/design/vertical-slice/` 完全 superseded**

### 5. Pre-design-pivot sprites

- **`sprites-cards-deprecated/`**（3MB）— "Defense card" / "Offense card" 卡牌系统的卡片 art。design pivot 把"cards" → "daily choices"，**卡牌作为视觉元素已废弃**。如果未来 daily choices 要 visual representation，重新生成符合 AVG vibe 的 sprite，不要 reuse 这套
- **`sprites-test-outputs/`**（46MB）— sprite 切图工作流的 test output dump。**临时文件**，无 long-term value

---

## 关键还在 active 的引用

如果未来要从 archive 中 mining 旧设计，**这些是仍然有效的**：

| Archive 文件 | 仍然有效的内容 | 已被什么替代 |
|---|---|---|
| `godot-architecture/architecture.md` §Architecture Principles | "5 红线"原则——NPC 算计 / 反向 KPI / Diegetic UI / 单 dispatch / 数据驱动 | `design/vertical-slice/tone-bible.md` v2 + `series-structure.md` |
| `godot-architecture/adr-0017-npc-relationship-schema-formulas.md` | NPC score 公式数学推导 | `design/vertical-slice/npcs.md` v2 + `daily-choices.md` |
| `godot-architecture/adr-0007-kpi-review-three-track-anchor.md` | KPI Review 浮层 3-track UI 思路 | `design/vertical-slice/season-1-arc.md` §6 (5 路径 + 浮层 spec) |
| `godot-stories/save-system/` | 单 slot ironman + Archive 200 cap 的实现细节 | `game/src/save/` (TS 实现) |

如果你正在写新的 design doc 觉得"这个我之前在 Godot 时代讨论过"——可以快速翻 archive，但**任何引用都要交叉验证 `/design/vertical-slice/` 是否已经超越或修改了那条决策**。

---

## ❌ 不要做的事

- **不要把 archive/ 里的 ADR 当 binding rule**——ADR 是 Godot 时代的，TS+Ink 栈无关
- **不要 reference archive 中的 spec 数字**（如 P4 的 MONTH_DAYS=30）——这些已经被 design slice 覆盖
- **不要恢复 archive 文件到 active 区**——除非用户明确说"恢复"
- **不要在新 doc 里写"详见 archive/..."**——active docs 应该 self-contained
