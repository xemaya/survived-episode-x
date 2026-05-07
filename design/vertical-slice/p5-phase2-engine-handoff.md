# P5 Phase 2 · Engine Dev Handoff Brief

> Status: 第 1 版
> Author: Game Designer (原 CC session)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——新启动的 Claude Code session，承接全部 design + engine context

---

## 0. 你的身份

你是 P5 Phase 2 的 **engine developer**。Game Designer (我，原 session) 已经完成 P5 Phase 1 minimal demo（ink runtime 跑通 + 主屏 BG + placeholder 文本面板），现在 move on 到 design 工作。你的活是把 demo 升级到生产级 visual + 完整功能。

跟你并行还有一个 **QA clone** 在测当前 demo——他会找 bug，你修。

---

## 1. 必读 reference（按顺序）

1. **`design/vertical-slice/p5-engine-architecture.md`** — P5 完整架构 spec（19 sections）。**§13 P5 Task 拆解 20 项是你的 backlog**
2. **`design/vertical-slice/p5-closure.md`** — Phase 1 closure：什么 done / 什么 deferred / 详细 file listing
3. **`design/concepts/p5-ui/`** — 5 张 visual concept 图。**这是视觉北极星**——speech bubble / sticky note 选项 / phone overlay / 邮件 modal / endgame 厨房，全部锚定
4. `game/CLAUDE.md` (无)；用 `/CLAUDE.md` 顶层 + `game/README.md`
5. `design/vertical-slice/tone-bible.md` v2 — 5 写作原则，用于审 ink 内容时识别 tone 偏离
6. `design/vertical-slice/series-structure.md` — 52 集 macro，便于理解 scene type 边界
7. `design/vertical-slice/season-1-arc.md` — S1 outline，理解 episode 结构

---

## 2. 当前状态（Phase 1 done）

```
game/src/ink/
├── runtime.ts              ✓ inkjs Story 包装 + state serialize + tag stream
├── tag-interceptors.ts     ✓ # tag dispatch + parseTag
└── loader.ts               ✓ episode JSON fetch
game/src/render/dialog/
└── ink-dialog.ts           ⚠ PLACEHOLDER 半透明文本面板 + 按钮 — 待替换为真 speech bubble + sticky note
game/src/render/scene/
└── workstation.ts          ✓ BG sprite + props + ink-dialog mount; SHOW_LEGACY_HUD=false 隐藏 P0-P4 AP/KPI/下班按钮
game/scripts/
├── ink-build.mjs           ✓ inkjs/compiler → JSON, 无 .NET 依赖
├── ink-vite-plugin.mjs     ✓ Vite HMR plugin
└── setup-inklecate.mjs     (placeholder)
game/src/save/
├── browser-fs.ts           ✓ localStorage fallback when no Tauri
└── system.ts               ⚠ ink_state_json 字段未加 — T16 待
game/public/ink/             ✓ 5 .json 编译输出 (gitignored)
game/tests/ink/runtime.smoke.test.ts  ✓ 6 tests
```

**Working in browser at `pnpm dev` → http://localhost:1420**：
- Boot → main_menu → 「新游戏」
- → intro 4 屏（笑天 voice 自介 + 游戏机制 + 不可能三角 + 输赢）
- → episode_1 → day_1_morning_briefing (笑天名字段子 + 工位 BG)
- → 各 event + 选项
- 点选项 → next event 渲染（Day 1 → Day 7 cliffhanger 到 E2）
- save: localStorage fallback（plain browser），Tauri host 时切到 AppData

**Not working / Phase 2 target**：
- Speech bubble 不是 NPC-anchored（用中央文本 panel）
- 选项不是 sticky note 也不是 phone reply（用普通按钮）
- Phone scene / monitor modal scene / endgame scene 没单独 mount
- Diegetic prop tags (# scene / # npc / # prop) 被 dispatch 但没 listener
- Ink VAR (kpi/money/state) 没有 visible UI
- Day scheduler 8 时间槽没实装（story 线性跑）
- Daily-choices 没 integrate（pool filter 缺）
- Save 没持久化 ink runtime state（每次 boot 重置）
- KPI Review 月末浮层没 trigger
- TS-side game-over check 没实装（病倒 6 次 / KPI 双端 / 钱<4500 都不会触发 GO）

---

## 3. Phase 2 任务 backlog（按优先级）

参考 `p5-engine-architecture.md` §13。**优先做 visual polish（P0 用户体验）**，再做 scope expansion（P1 完整 loop）：

### P0 — visual polish（用户最在意的）

| Task | 文件 | 内容 |
|---|---|---|
| **T10a** speech bubble | `game/src/render/dialog/speech-bubble.ts` | NPC-anchored 圆角对话框（参考 concept 02），从 NPC sprite 头顶冒出，9-slice 边框 |
| **T10b** internal monologue | `game/src/render/dialog/internal-monologue.ts` | italic 半透明文字，浮在主角位置（无 bubble） |
| **T11** sticky note choices | `game/src/render/choice/sticky-notes.ts` | 3 个 sticky note 浮在桌面（参考 concept 02），点击选择，subtle bob 动画 |
| **替换** ink-dialog.ts | 同上 | 用上述新组件，根据当前 scene type 选 dialog 形态（workstation = bubble + sticky / phone = phone UI / monitor = email UI） |

### P1 — 完整 loop（让游戏可玩）

| Task | 文件 | 内容 |
|---|---|---|
| **T05** prop entity + 12 prop registry | `game/src/render/diegetic/prop-entity.ts` + `prop-registry.ts` | mug / phone / banking app / sticky / monitor / 水果盘 等 12 prop 状态机 |
| **T03 实现** tag interceptor listeners | 现有 `tag-interceptors.ts` | 把 # scene / # npc / # prop 真正接到 PixiJS render 层 |
| **T04** scene registry + transitions | `game/src/scene/registry.ts` + `transitions.ts` | 5 scene type 注册 + crossfade / camera zoom |
| **T07** phone scene | `game/src/render/scene/phone.ts` | concept 03 fullscreen phone 视图（凌晨 leader 微信 / 妈妈视频 / 银行 app push） |
| **T08** monitor modal scene | `game/src/render/scene/monitor.ts` | concept 04 KPI Review email 全屏 |
| **T09** endgame scene | `game/src/render/scene/endgame.ts` | concept 05 春节回家厨房（warm palette） |

### P2 — gameplay loop

| Task | 文件 | 内容 |
|---|---|---|
| **T13** day scheduler | `game/src/scheduler/day-scheduler.ts` | 8 时间槽 / 天，剧情 event 优先，提前下班 button |
| **T14** daily choice pool | `game/src/scheduler/daily-choice-pool.ts` | filter algorithm (per p5-engine-architecture.md §5.1) |
| **T15** flag mirror | `game/src/flag/mirror.ts` | TS readonly cache of ink VAR + onChange events |
| **TS GO check** | new module | poll state/money/sick_count after each step → divert to game_over_* knot |
| **T16** save extension | `game/src/save/system.ts` + schema.ts | 加 ink_state_json field，autosave 包含 |
| **T19** state extensions | `game/src/flow/states/*.ts` | morning_briefing / kpi_review / recap 状态接 ink runtime |

---

## 4. 工作流（每个 task）

1. **挑一个 task**（推荐从 T10a speech bubble 开始——视觉冲击最大）
2. **读** p5-engine-architecture.md 对应 section
3. **看** concept image 作视觉参考
4. **写** 实现 + 加 vitest 单元测试 (game/tests/...)
5. **跑** `pnpm tsc && pnpm test && pnpm ink:build` 全绿
6. **手动 verify** `pnpm dev` 浏览器看效果
7. **commit** message format: `feat(p5-T0X): <one-line summary>`
8. **next task** 或 fix QA bugs（QA clone 会写 bug 报告到 `design/vertical-slice/p5-qa-bug-reports.md`）

---

## 5. 关键约束（不能违反）

- **Red Line 4**: `flow.request()` 是 scene state 唯一入口，不要绕开
- **Red Line 3**: `CanvasLayer.visible` overlay 仅在 PAUSE / KPI_REVIEW / GAMEOVER / SETTINGS 允许（其他全 diegetic）
- **art-bible §7.1**: 工位 prop 是 game state 的视觉表达——不要回到 overlay HUD
- **Red Line 1 / tone-bible**: 不要在 TS 代码 string literal 里写"成长 / 突破 / 完美 / 努力" 这种主角励志语料（这些只能在 ink 内容里以 NPC 嘴讽刺出现）
- **保留 SHOW_LEGACY_HUD = false**: 不要打开 P0-P4 AP indicator / 下班按钮（P6 重做 diegetic 等价物）
- **不要改 design/vertical-slice/*.ink 内容**: 那是 designer 范围。若发现 ink 内容 bug，写到 QA bug 报告里让 designer fix

---

## 6. 跟 QA 协作

QA clone 会把 bug 报告写到：
- `design/vertical-slice/p5-qa-bug-reports.md`

每个 bug：severity（block / major / minor）+ 重现步骤 + 期望 vs 实际 + 涉及文件。

你优先级：**block > 当前 P0 task > major > P1 > minor > P2**。修完 bug 在 commit message 标注 `fix(qa-bug-N): <one-line>`，并在 `p5-qa-bug-reports.md` 把那条标 ✓ resolved。

---

## 7. 给 designer 的请求格式

如果你发现：
- 设计 spec 矛盾（e.g. p5-engine-architecture.md 跟 concept image 不一致）
- 关键决策缺失（e.g. "phone reply button 颜色没定")
- 内容 bug（ink 内容写得 ink 编译警告 loose end）

**不要自己脑补**。写到：
- `design/vertical-slice/p5-phase2-engine-questions.md`（你 append-only 的提问 log）

Designer 会定期看这个文件回答。同步阻塞别等——把 question parked 后做下一个不依赖那个 spec 的 task。

---

## 8. 提交格式（每完成 1-3 task batch）

写 progress 报告到：
- `design/vertical-slice/p5-phase2-engine-progress.md`（append-only）

格式：
```
## 2026-05-XX batch N
- T10a speech bubble: ✓ done — game/src/render/dialog/speech-bubble.ts (~120 lines)
  - 实测 episode_1 morning_briefing 看到 NPC 头顶冒 bubble
  - QA bug #3 (markdown残留) 已 fix in 同 commit
- T10b internal monologue: ✓ done
- (next: T11 sticky note choices)

Open questions: 见 p5-phase2-engine-questions.md
```

---

## 9. 验收标准

每个 task 完成 = 4 条全 ✓：
1. `pnpm verify` exits 0 (assets + ink + tsc + lint + test)
2. `pnpm dev` 浏览器手动 walkthrough 看到效果
3. 至少 1 个 vitest 单元测试 cover 该 task
4. 概念图视觉锚 honored（speech bubble 形态 / sticky note 浮在桌面 / 凌晨 leader 微信 fullscreen 等）

---

## 10. 不要做的事

- 不要 fork P5-Plan 框架（scene type 5 个就 5 个，不要扩到 6）
- 不要重写 ink runtime（runtime.ts 已 stable，加新方法 OK，重命名/重构必须先 designer ack）
- 不要在 game/src/ 写大量 mock 数据 → 数据从 ink 来
- 不要回去复活 game/src/card/（已删，永远不要）
- 不要修 design/vertical-slice/*.ink（designer 范围）
- 不要修 design/concepts/p5-ui/*.png（这些是只读视觉锚）

---

## 11. 第 1 个 task 建议：T10a speech bubble

**为什么先做这个**：
- 视觉冲击最大，开发完玩家立刻感受到改进
- 输入小（NPC sprite 位置 + ink text），输出明确（PixiJS Container with bubble）
- 不依赖其他 P5 task

**spec**：
- 看 `design/concepts/p5-ui/p5_ui_02_event_lisa_ppt.png` 第 2 张图
- bubble 9-slice 圆角矩形，从 NPC 头顶冒出来，pointer 指向 NPC mouth 方向
- text auto-fit，长文换行
- 颜色：bg `#E8E0CC` (白炽灯白 per art-bible), border `#5A7080` (格子间灰蓝)
- 替换 ink-dialog.ts 的 text panel 部分（先共存，加 toggle，最后 ink-dialog.ts 只做 routing）

完成后写到 `p5-phase2-engine-progress.md`，QA 会 verify。
