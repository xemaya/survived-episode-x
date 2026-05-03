# Architecture Review Report — 2026-04-28

| Field | Value |
|-------|-------|
| **Date** | 2026-04-28 |
| **Mode** | full(Phase 1-9 全跑;`rtm` 模式 deferred 至 stories 存在后)|
| **Engine** | Godot 4.6 + GDScript |
| **Review Mode** | lean(`production/review-mode.txt`)|
| **GDDs Reviewed** | 20(Foundation 5 + Core 4 + Feature 3 + Presentation 5 + VS 2 + Alpha 1)|
| **ADRs Reviewed** | 14(adr-0001..0014,全 Proposed,lean mode 等同 Accepted)|
| **Inputs Loaded** | 14 ADRs / 20 GDDs(L0 summary + L1 关键系统 full read)/ engine reference 全套(VERSION + breaking-changes + deprecated-apis + current-best-practices)/ `architecture.yaml` (41 entries) / `entities.yaml` (13 constants) / `architecture.md` (590 行)/ `tr-registry.yaml` (空 — 本次首次 populate)|
| **Reviewer Independence** | ✓ Fresh session(handoff `production/handoffs/2026-04-28-architecture-review.md`)|

---

## Verdict: **CONCERNS**

**核心结论**:14 ADRs 间无 ADR-vs-ADR 冲突,全 8 BLOCKING(B-DEP-1/2/3 + B-RULE-1 + B-SCN4-1/2/3 + B-AC-1)由 ADR-0001/0004/0005/0006/0007/0008 完整仲裁,依赖图无循环,topological sort PASS,engine compat 一致(3 OQ HIGH risk 实测项 deferred 至 Pre-Production / prototype)。但发现 **4 项 non-blocking finding** 需 Pre-Production 启动前清理:2 项 ADR-vs-GDD 文本不一致 + 2 项 architecture.md doc-internal stale text。

**对 Pre-Production 进入的影响**:CONCERNS verdict 不阻塞 `/create-control-manifest` + `/create-epics` + `/create-stories` 启动;4 项微修可在 stories 创建之前批量清(微修级,< 30 min 工作量)。

---

## Phase 3 Traceability Summary

总 TR(技术需求)抽取 = **139 项**,基于 architecture-level 决策粒度(单系统内部 GDD rule 不进 TR matrix,只提取 cross-system contract / state ownership / engine API choice / serialization / persistence / cross-cutting interface)。

| Status | 数量 | % |
|--------|------|---|
| ✅ **Covered**(ADR 显式 cover) | 95 | 68% |
| ⚠️ **Partial**(architecture.md / yaml 引用,无独立 ADR;多为 GDD-internal stable contract) | 25 | 18% |
| 📋 **GDD-internal**(formula / VS-tier 推迟,可不创独立 ADR) | 13 | 9% |
| ❌ **Gap**(无任何 architecture coverage) | 6 | 5% |

**6 项真 Gap 全部为 VS/Alpha tier 推迟项**(`TR-tutorial-002/004` Day 1-3 onboarding hint API + `TR-a11y-007/008` reduce_motion + TTS 野心版 + `TR-event-012` Lisa 跳槽线必发 playtest 验证 + `TR-run-meta-003` HR 评语词条收集词库 — 全为内容/playtest 验证项,非 architecture critical)。

**全 Foundation/Core 层 cross-cutting TR 100% 由 ADR-0001..0008 覆盖** ✓

详细 TR 矩阵见 §Per-System Traceability Matrix。

---

## Phase 4 Cross-ADR Conflict Detection

### 14 ADRs Pairwise Audit:**0 conflicts**

| 冲突类型 | 检测结果 | 验证依据 |
|---------|---------|---------|
| **State ownership** | 0 conflict | `architecture.yaml` state_ownership 6 项 single-owner 清晰(meta_save_run_ended / accumulation_dimensions_4 / farewell_event_ids / narrative_density / archive_index / scene_sub_mode);`referenced_by` 链一致 |
| **Integration contracts** | 0 conflict | `architecture.yaml` interfaces 6 项(scene_state_changed / accumulation_event / game_over_chain / kpi_review_three_track / settings_signals_debounced / foundation_mark_ready)与 ADR-0001 信号 matrix 完全一致 |
| **Performance budgets** | 0 conflict | 60fps × 16.6ms / startup 5000ms / hud 70 draw call / save 50ms / kpi_review 800ms / gameover 1500ms 各自独立锚,无 budget 冲突;ADR-0006 时序(transition 5050ms-6550ms)与 ADR-0003 ARCHIVING(transition 期间 < 50ms)一致 |
| **Dependency cycles** | 0 cycle | 14 ADR Depends On 链 acyclic(详 §Dependency Order)|
| **Architecture pattern** | 0 conflict | `@abstract` 基类 ADR-0002 + ADR-0009 同模式;WorkerThreadPool ADR-0003 单 owner;single-CanvasLayer ADR-0011 单层 |
| **State management** | 0 conflict | game_over_triggered 唯一 emit owner = #9 KPI(ADR-0006);accumulation_event 唯一 emit owner = #5 Lighting(ADR-0005);narrative_density owner = #17(ADR-0001) |

### Dependency Order(Topological Sort, Acyclic ✓)

```
Layer 0 (Foundation root, no deps):
  ADR-0001 Signal Ownership Matrix

Layer 1 (deps Layer 0):
  ADR-0002 Autoload Init Order + Scene Tree (deps 0001)
  ADR-0005 Lighting Accumulation 4 Dimensions (deps 0001)
  ADR-0008 Visual Boundary Pillar 4 vs Mute Parity (deps 0001)
  ADR-0010 Subject Inversion Lint Master Domain List (deps 0001)

Layer 2 (deps Layer 0/1):
  ADR-0003 Save Format + WorkerThreadPool (deps 0002)
  ADR-0004 Settings Reflow Coalescing (deps 0001 + 0002)

Layer 3 (deps Layer 0/1/2):
  ADR-0006 Dismissal/GAMEOVER Path (deps 0001 + 0003)
  ADR-0009 Event Schema Format (deps 0002 + 0003)
  ADR-0011 HUD Diegetic Render (deps 0001 + 0005)
  ADR-0013 Archive 200 Virtual Scroll (deps 0003)
  ADR-0014 Accessibility Settings Injection (deps 0001 + 0004)

Layer 4 (deps Layer 0/1/2/3):
  ADR-0007 KPI Review Three-Track Anchor (deps 0001 + 0006)
  ADR-0012 Three-Density Rendering (deps 0001 + 0004 + 0009)
```

**实施顺序建议**(从 Layer 0 顺次推进):ADR-0001 → ADR-0002/0005/0008/0010 并行 → ADR-0003/0004 → ADR-0006/0009/0011/0013/0014 并行 → ADR-0007/0012。

**Lean mode 等同 Accepted**:全 14 ADR Proposed status 已经过 lean mode 协议视为 Accepted(无需 TD Phase Gate)。

---

## Phase 5 Engine Compatibility Audit

### Version Consistency: ✓ 一致

14 ADRs 全部 Engine = **Godot 4.6**。无 stale version reference。

### Engine Compatibility Section 覆盖率: **14 / 14 = 100%** ✓

每 ADR 均含 Engine / Domain / Knowledge Risk / References Consulted / Post-Cutoff APIs Used / Verification Required 6 字段。

### Post-Cutoff APIs 一致性

| API | Godot Version | 引用 ADR | 一致性 | OQ 实测项 |
|-----|--------------|---------|--------|-----------|
| `@abstract` 装饰器 | 4.5 | ADR-0002 + ADR-0009 | ✓ 一致(BaseSubModeState + EventEffect 同模式)| OQ-SDF-ENG-03 + OQ-EVT-ENG-01(共测)|
| `change_scene_to_packed()` 4.5 重构 | 4.5 | ADR-0002 | ✓ 单引 | OQ-SDF-ENG-02(2D 路径性能基准)|
| `PROCESS_MODE_ALWAYS` 4.6 SceneTree.paused | 4.6 | ADR-0002 | ✓ 单引 | OQ-SDF-ENG-01(实测验证)|
| `FileAccess.store_*` 返回 bool | 4.4 | ADR-0003 | ✓ 单引(主线程 fsync 路径)| 无 OQ(已知行为)|
| `AccessKit Window.use_accessibility` | 4.5 | ADR-0014 | ✓ 单引 | OQ-A14-ENG-01(屏幕阅读器实测)|
| `dual-focus mode` | 4.6 | ADR-0014 | ✓ 单引 | OQ-A14-ENG-02(键盘+gamepad 同时 focus 实测)|
| `duplicate_deep()` | 4.5 | ADR-0003(提到不依赖)| ✓ 不实际使用 | 无 |

**关键观察**:`@abstract` 4.5+ 跨 ADR-0002 + ADR-0009 一致使用,共享 OQ 实测项(降本)。

### Deprecated API 检查: ✓ 0 引用

`grep -E "TileMap[^L]|VisibilityNotifier[23]D|YSort|Navigation[23]D[^S]|yield\(|connect\(\".*\".*,|\.instance\(\)|get_world\(\)|OS\.get_ticks_msec|method_call_mode|playback_active"` 14 ADRs 文件:**0 hit**。无 deprecated API 误用。

### HIGH Risk 域汇总

3 个 HIGH risk ADR + 1 MEDIUM:
- **ADR-0002**(HIGH): `PROCESS_MODE_ALWAYS` + `change_scene_to_packed()` + `@abstract` + SceneTree 4.5 重构 — 3 OQ 实测延 Pre-Production
- **ADR-0009**(HIGH): `@abstract EventEffect` Resource 子类 — 与 ADR-0002 共享 OQ-SDF-ENG-03
- **ADR-0014**(HIGH): AccessKit 4.5+ + dual-focus 4.6 — 2 OQ 延 Pre-Production
- **ADR-0001**(MEDIUM): 31 信号 × 65 subscribers 性能(OQ-SDF-ENG-02 共测)

### Engine Specialist Consultation

**Skipped — lean mode + autonomy v2 决策**。

理由:
1. 14 ADRs 各自由 godot-specialist / godot-gdscript-specialist / godot-shader-specialist 经 `/architecture-decision` 协议撰写(`architecture.md` Phase 7b sign-off 记录)
2. 全部 HIGH risk 已显式标记 Verification Required + OQ 实测项延 Pre-Production / prototype
3. 二次 specialist 审计边际价值低(lean mode 优先速度)

**未 spawn**:`godot-specialist` 二次 review。如 stories 实施阶段发现 engine assumption 失准,可在 `/dev-story` 时 specialist 触达。

---

## Phase 5b GDD Revision Flags

### Flag #1: `#10 Event Script Engine` Rule 18 vs ADR-0009 — Writer 工作流冲突

| 字段 | 内容 |
|------|------|
| **GDD** | `design/gdd/event-script-engine.md` Rule 1 (L156-160) + Rule 18 (L232-237) |
| **GDD 主张** | `JSON-primary + tres runtime`(writer 用纯文本编辑器编辑 JSON,运行时构造 `EventDefinition extends Resource`)|
| **ADR-0009 主张** | `EventResource (.tres single file per event)` — writer 用 Godot Inspector 直接编辑 `.tres`(`@export var event_id` / `@export var trigger: EventTrigger` 等类型化字段)|
| **冲突本质** | Writer 工作流路径不同:GDD 路径需 JSON → tres 转换工具(EditorPlugin),ADR-0009 路径直接 Inspector 编辑 |
| **Impact** | 实施层混淆:写 EditorPlugin EventLinter 时面向 JSON 还是 .tres 不明;writer 培训成本不同 |
| **Action** | **Fix Required**:仲裁两种路径之一,GDD Rule 18 或 ADR-0009 修订对齐。**推荐**:保留 ADR-0009 `.tres single file`(Godot 主流 + Inspector 友好)+ 让 GDD Rule 18 retrofit 为"writer 用 Inspector,可选 JSON 副本作为 git diff 友好"或简化为 "Inspector 主路径,JSON git-friendly 不强制" |

### Flag #2: `#9 KPI System` Edge 1.4 vs ADR-0006 — M1 开除路径

| 字段 | 内容 |
|------|------|
| **GDD** | `design/gdd/kpi-reverse-threshold-system.md` Edge 1.4 (L442) |
| **GDD 主张** | "M1 `actual_kpi_m=0` → `dismissal_triggered`。M1 开除走剧本路径,**不触发 GAME OVER**" |
| **ADR-0006 主张** | 双路径合并 — 所有 GAMEOVER 走 Path B(剧本路径):`#9 dismissal_triggered → #10 EVENT.KPI.FIRED_DISMISSAL → dismissal_finalized → #9 emit game_over_triggered` |
| **冲突本质** | Edge 1.4 是 ADR-0006 仲裁前的 stale text;ADR-0006 后 M1 开除"经过剧本但最终仍 GAME OVER" |
| **Impact** | 微修级:`#10` GDD L295-303 已对齐 ADR-0006(L295: `dismissal_triggered → 剧本 → dismissal_finalized → game_over_triggered`),仅 `#9` Edge 1.4 留 stale text,不影响实施(`#9` Rule 11 状态机已正确) |
| **Action** | **Fix Required**:Edge 1.4 行尾"不触发 GAME OVER"删除,改为"M1 开除经过 `EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3` 剧本,5 秒玩家阅读期后 emit `dismissal_finalized` → `#9` emit `game_over_triggered(kpi_fail_3, 1)`"对齐 ADR-0006 |

**两 Flag 均为 GDD micro-edit**(单行 / 单段修改),不阻塞 architecture decisions。建议 fresh session 跑 `/design-system` 微修(或 batch edit)在 `/create-stories` 启动前完成。

---

## Phase 6 Architecture Document Coverage

`docs/architecture/architecture.md` v1.0(2026-04-29 → 2026-04-28 lean accepted):

### System Coverage: ✓ 20/20 完整

20 系统全部映射至 5 层 + Polish 注入器(L57-89);Module Ownership 表 20 系统逐项列(L102-148);API Boundaries 4 layer 全 cover(L286-385)。

### Data Flow: ✓ 5 关键场景全 cover

L155-281:启动序列 / 单卡完整链 / KPI Review 三轨 + GAMEOVER / NPC 离职 lifecycle / Settings 同帧 6 信号防抖。

### Architecture Principles: ✓ 5 原则锁定

L390-396:Pillar 4 反英雄红线 / Anti-P1 单调红线 / Diegetic UI 锁 / `#6` 单点 dispatch / 数据驱动 + 引擎契约锁。

### ADR Audit: ✓ 14 ADRs 锁定

L401-432 ADR Audit table 14 项;`architecture.yaml` 41 entries(6 state / 6 interfaces / 9 budgets / 10 API decisions / 10 forbidden patterns)。

### ⚠️ Doc-Internal Stale Text — 2 项

| 行号 | 现有文本 | 实际决策 | 来源验证 |
|-----|---------|---------|---------|
| **L498-501** | "锁定 `kpi_review_intro_duration_ms = 1000ms`(三轨共用 anchor)+ `#5 Lighting` palette swap Tween 0.3s → 改 1.0s linear + `#4 Audio` Music Bus fade-in 1.5s → 改 1.0s + `#16 KPI Review UI` breakdown 三行渲染 ≤ 1帧 + 1.0s 后 fade-in 完成" | **800ms** | ADR-0007 L62 + entities.yaml L300 + architecture.yaml L328 全部 800ms |
| **L519** | "ADR-0009 Event Schema Format **关键决策**: JSON-primary(writer 用纯文本编辑器)+ runtime `EventDefinition extends Resource` 强类型构造" | `.tres` 单文件 per event | ADR-0009 §1 L57-80 + architecture.yaml L407-422 api_decision purpose=event_authoring |

**分析**:两处 stale text 是 architecture.md 撰写时基于"Required ADRs"早期 sketch 的 placeholder 文本,撰写 ADR-0007 + ADR-0009 时实际决策已 evolve(800ms / .tres),architecture.md 未同步刷新。**Action**:`architecture.md` `Required ADRs` 段(L437-540)retrofit 与 14 ADRs 实际决策一致,或者删除 `Required ADRs` 段(因为 ADRs 已撰写,该段为 historical 留念)。

### ✓ 无 Orphaned Architecture

`architecture.md` 提及的 20 系统全部有 GDD 文件。Polish Layer `#20` Accessibility 注入器虽不是独立运行时层,但 architecture.md L96 已显式说明。

---

## Per-System Traceability Matrix

详细 TR-ID 表(已写入 `tr-registry.yaml` Phase 8;此处摘要,完整表见 registry):

### Foundation Layer

| TR-ID | GDD | Requirement | ADR Coverage | Status |
|-------|-----|-------------|--------------|--------|
| TR-save-001 | save-system.md | 三槽位 Save 文件结构 | ADR-0003 | ✅ |
| TR-save-002 | save-system.md | WorkerThreadPool 异步 autosave + 主线程 ARCHIVING 边界 | ADR-0003 | ✅ |
| TR-save-003 | save-system.md | meta.run_ended 原子 fsync 先于 GAMEOVER 1500ms | ADR-0003 + ADR-0006 | ✅ |
| TR-save-004 | save-system.md | archive 200 cap FIFO 驱逐 | ADR-0003 + ADR-0013 | ✅ |
| TR-save-005 | save-system.md | current_schema_version 单调递增 + MVP 不迁移 | ADR-0003 | ✅ |
| TR-save-006 | save-system.md | JSON-primary 格式 + Resource lazy parse | ADR-0003 | ✅ |
| TR-save-007 | save-system.md | meta_settings_debounce_ms = 500ms 防抖窗 | ADR-0004 | ✅ |
| TR-save-008 | save-system.md | autosave_perf_hard_ceiling_ms = 50ms HDD+AV p99 | ADR-0003 | ✅ |
| TR-save-009 | save-system.md | content-only unlocks(5 类白名单) | ADR-0001 forbidden + ADR-0006 | ✅ |
| TR-save-010 | save-system.md | final_transition_duration_ms = 1500ms linear | ADR-0006 | ✅ |
| TR-input-001 | input-handler.md | InputMap 12 actions(act_pause/act_skip/act_focus_*) | ADR-0001 + ADR-0002(信号 + autoload) | ⚠️ Partial(无独立 Input ADR;cross-cutting 已 cover) |
| TR-input-002 | input-handler.md | 3-state 状态机(NORMAL / MODAL_LOCKED / REMAPPING) | — | ⚠️ Partial(GDD-internal,可不独立 ADR) |
| TR-input-003 | input-handler.md | skippable token 注册 API | — | ⚠️ Partial(GDD-internal) |
| TR-input-004 | input-handler.md | keymap_changed 防抖 500ms | ADR-0004 | ✅ |
| TR-input-005 | input-handler.md | dual-focus mode 4.6 启用 | ADR-0014 | ✅ |
| TR-input-006 | input-handler.md | SDL3 gamepad 4.5 兼容 | — | ⚠️ Partial(LOW risk,引擎自动)|
| TR-input-007 | input-handler.md | Recursive Control disable 4.5 modal stack | — | ⚠️ Partial(GDD-internal)|
| TR-loc-001 | localization-hooks.md | tr() 纪律 + key naming(_IRONY / _BUREAUCRATIC) | ADR-0010 | ✅ |
| TR-loc-002 | localization-hooks.md | locale_changed reflow ≤ 30 帧单次广播 | ADR-0004 | ✅ |
| TR-loc-003 | localization-hooks.md | 字体 fallback 链 + autofit floor 11 | ADR-0014 + ADR-0004 | ✅ |
| TR-loc-004 | localization-hooks.md | locale_lock_watchdog_ms = 30000 | ADR-0004 + entities.yaml | ✅ |
| TR-loc-005 | localization-hooks.md | CSV 5 列 schema + plural form 4.6 + context column | — | 📋 GDD-internal(4.6 引擎特性)|
| TR-loc-006 | localization-hooks.md | PAUSE 中 locale 切换挂起 + resume 后单次 emit | ADR-0004 | ✅ |
| TR-audio-001 | audio-manager.md | 4 Bus 架构(Master / Music / Ambient / SFX) | architecture.md L109 | ⚠️ Partial(GDD-internal,无独立 ADR)|
| TR-audio-002 | audio-manager.md | LOADING/READY 状态机 + _mark_ready signal | ADR-0001 + ADR-0002 | ✅ |
| TR-audio-003 | audio-manager.md | audio_preload_budget_ms 200ms / watchdog 10000ms | ADR-0002 + entities.yaml | ✅ |
| TR-audio-004 | audio-manager.md | bgm_loop_length_max_sec = 120s | entities.yaml | ⚠️ Partial(无独立 ADR,registry constant) |
| TR-audio-005 | audio-manager.md | 月末 KPI Review 三轨 800ms cross-fade | ADR-0007 | ✅ |
| TR-audio-006 | audio-manager.md | farewell event 禁切 BGM(numeric_only AC 守门) | ADR-0001 + ADR-0009 | ✅ |
| TR-audio-007 | audio-manager.md | act_pause + WM_FOCUS_OUT fade 公版统一 | — | ⚠️ Partial(GDD 内部 lock,#6 GDD `act_pause` 公版)|
| TR-lighting-001 | lighting-visual-state.md | 8 sub-mode CanvasModulate 色值表 | architecture.md L110 | ⚠️ Partial(GDD-internal)|
| TR-lighting-002 | lighting-visual-state.md | LOADING/READY + lighting_loading_watchdog_ms 10000ms | ADR-0002 + entities.yaml | ✅ |
| TR-lighting-003 | lighting-visual-state.md | 累积 4 维度 schema | ADR-0005 | ✅ |
| TR-lighting-004 | lighting-visual-state.md | accumulation_event signal 单 owner = #5 | ADR-0001 + ADR-0005 | ✅ |
| TR-lighting-005 | lighting-visual-state.md | KPI_REVIEW 紫色 palette 800ms swap | ADR-0007 | ✅ |
| TR-lighting-006 | lighting-visual-state.md | GAMEOVER 灰度 1500ms palette | ADR-0006 + ADR-0008 | ✅ |
| TR-lighting-007 | lighting-visual-state.md | 5 类禁视觉 + 4 例外白名单 | ADR-0008 | ✅ |
| TR-lighting-008 | lighting-visual-state.md | Hero card brightness lift +0.05 0.5s | ADR-0008 | ✅ |
| TR-lighting-009 | lighting-visual-state.md | notice_board_max_entries = 24 | entities.yaml | ✅ |
| TR-lighting-010 | lighting-visual-state.md | Tonemapper Filmic 锁(4.6 AgX 不启用) | architecture.md L34 | ⚠️ Partial(architecture.md 提及无独立 ADR)|
| TR-lighting-011 | lighting-visual-state.md | palette swap shader + dither overlay shader | — | ⚠️ Partial(GDD-internal)|
| TR-lighting-012 | lighting-visual-state.md | farewell event 禁特殊 palette swap | ADR-0001 + ADR-0008 | ✅ |
| TR-lighting-013 | lighting-visual-state.md | 色盲 CanvasLayer post-process Shader 整屏适配 | ADR-0014 | ✅ |

### Core Layer

| TR-ID | GDD | Requirement | ADR Coverage | Status |
|-------|-----|-------------|--------------|--------|
| TR-sceneflow-001 | scene-day-flow-controller.md | Autoload /root/SceneDayFlowController PROCESS_MODE_ALWAYS | ADR-0002 | ✅ |
| TR-sceneflow-002 | scene-day-flow-controller.md | 8 sub-mode 状态机 + scene_state_changed 单 owner | ADR-0001 + ADR-0002 | ✅ |
| TR-sceneflow-003 | scene-day-flow-controller.md | request_transition() 唯一合法入口 + 主语翻转 dispatch | ADR-0001 + ADR-0002 | ✅ |
| TR-sceneflow-004 | scene-day-flow-controller.md | 启动序列 P5 5000ms 总预算 | ADR-0002 | ✅ |
| TR-sceneflow-005 | scene-day-flow-controller.md | settings 防抖单 timer 共享 + 6 信号合流 | ADR-0004 | ✅ |
| TR-sceneflow-006 | scene-day-flow-controller.md | pause game-time vs wall-clock 边界 | ADR-0002(PAUSE_INHERIT vs PROCESS_MODE_ALWAYS)| ✅ |
| TR-sceneflow-007 | scene-day-flow-controller.md | change_scene_to_packed() 预加载守门 | ADR-0002 | ✅ |
| TR-sceneflow-008 | scene-day-flow-controller.md | @abstract BaseSubModeState 4.5+ | ADR-0002 | ✅ |
| TR-sceneflow-009 | scene-day-flow-controller.md | NOTIFICATION_WM_WINDOW_FOCUS_OUT 三方语义(act_pause 公版)| — | ⚠️ Partial(GDD 内部 lock)|
| TR-sceneflow-010 | scene-day-flow-controller.md | 6 项 cross-system BLOCKING 仲裁责任 | ADR-0001..0008 | ✅ |
| TR-ap-001 | ap-economy-system.md | AP 4 态状态机 | architecture.md L117 | ⚠️ Partial(GDD-internal)|
| TR-ap-002 | ap-economy-system.md | AP cost 1/2/3 分布 lint(40/40/20) | — | 📋 GDD-internal(numeric formula)|
| TR-ap-003 | ap-economy-system.md | Hero card effort 三维度权重 0.45/0.20/0.30 | architecture.md L117 | ⚠️ Partial(KPI research deviation 已 lock,无独立 ADR)|
| TR-ap-004 | ap-economy-system.md | monthly_effort_summary signal owner = #7 | ADR-0001 | ✅ |
| TR-ap-005 | ap-economy-system.md | meta.run_ended 优先持久化 R-AP-2 | ADR-0003 + ADR-0006 | ✅ |
| TR-ap-006 | ap-economy-system.md | weekend_rest_day → energy +30 | ADR-0001 | ✅ |
| TR-ap-007 | ap-economy-system.md | F1-F5 公式定义 | — | 📋 GDD-internal |
| TR-ap-008 | ap-economy-system.md | capacity_factor / capacity_floor 单调红线 | architecture.md principle 2 | ⚠️ Partial(原则级,无独立 ADR)|
| TR-npc-001 | npc-relationship-system.md | 8 NPC schema + 4 lifecycle 态 | architecture.md L118 | ⚠️ Partial(GDD-internal)|
| TR-npc-002 | npc-relationship-system.md | F3 leave_probability per-NPC 8 套参数 | — | 📋 GDD-internal(numeric formula)|
| TR-npc-003 | npc-relationship-system.md | relationship_changed / npc_lifecycle_changed / npc_left_company 信号 | ADR-0001 | ✅ |
| TR-npc-004 | npc-relationship-system.md | LEFT 视觉屏蔽 R-NPC-2 | ADR-0005 + ADR-0011 | ✅ |
| TR-npc-005 | npc-relationship-system.md | LEAVING_ANNOUNCED 期间道别卡 numeric_only | ADR-0009 farewell flag + ADR-0001 | ✅ |
| TR-kpi-001 | kpi-reverse-threshold-system.md | monthly_threshold 单调递增 + month_index | architecture.md principle 2 | ⚠️ Partial(原则级)|
| TR-kpi-002 | kpi-reverse-threshold-system.md | F1-F4 公式(乘性 + capacity_factor)| — | 📋 GDD-internal |
| TR-kpi-003 | kpi-reverse-threshold-system.md | GAME OVER 检测协议(threshold > capacity_now) | ADR-0006 | ✅ |
| TR-kpi-004 | kpi-reverse-threshold-system.md | kpi_review_started signal owner = #9 | ADR-0001 + ADR-0007 | ✅ |
| TR-kpi-005 | kpi-reverse-threshold-system.md | game_over_triggered 唯一 emit 源 = #9 | ADR-0006 + ADR-0001 forbidden_pattern dual_emit | ✅ |
| TR-kpi-006 | kpi-reverse-threshold-system.md | dismissal_triggered → #10 → game_over_triggered Path B | ADR-0006 | ✅ |
| TR-kpi-007 | kpi-reverse-threshold-system.md | settlement_locked R-KPI-2 守门 | ADR-0006 | ✅ |
| TR-kpi-008 | kpi-reverse-threshold-system.md | KPI Review 三轨 800ms 同步锚 | ADR-0007 | ✅ |
| TR-kpi-009 | kpi-reverse-threshold-system.md | kpi_prediction_hint 4 档(老 NPC 预言) | ADR-0001 | ✅ |
| TR-kpi-010 | kpi-reverse-threshold-system.md | deterministic RNG seed 可控 | — | 📋 GDD-internal(numeric)|

### Feature Layer

| TR-ID | GDD | Requirement | ADR Coverage | Status |
|-------|-----|-------------|--------------|--------|
| TR-event-001 | event-script-engine.md | Schema A 扁平 event 库 | ADR-0009 | ✅ |
| TR-event-002 | event-script-engine.md | @abstract EventEffect 4.5+ 5 子类 | ADR-0002 + ADR-0009 | ✅ |
| TR-event-003 | event-script-engine.md | 三档密度(brief / standard / verbose) effects + dialogue | ADR-0009 + ADR-0012 | ✅ |
| TR-event-004 | event-script-engine.md | FAREWELL_EVENT_IDS enum + 5 离别事件 numeric_only | ADR-0001 + ADR-0009 | ✅ |
| TR-event-005 | event-script-engine.md | cooldown + once_per_run + morning_blacklist 7 天滑动 | ADR-0009 | ✅ |
| TR-event-006 | event-script-engine.md | Dictionary 三层索引(by_trigger / by_chapter / by_npc) | ADR-0009 | ✅ |
| TR-event-007 | event-script-engine.md | EditorPlugin EventLinter + Python CI lint | ADR-0009 + ADR-0010 | ✅ |
| TR-event-008 | event-script-engine.md | subject_inversion_lint 8 master domain | ADR-0010 | ✅ |
| TR-event-009 | event-script-engine.md | narrative_density_changed 订阅契约 | ADR-0001 + ADR-0004 + ADR-0012 | ✅ |
| TR-event-010 | event-script-engine.md | EVENT.KPI.FIRED_DISMISSAL 剧本 GAMEOVER 中转 | ADR-0006 + ADR-0009 | ✅ |
| TR-event-011 | event-script-engine.md | dismissal_finalized signal own = #10 | ADR-0006 | ✅ |
| TR-event-012 | event-script-engine.md | Lisa 跳槽线必发 | — | ❌ Gap(playtest 实测,Beta 推迟可接受)|
| TR-card-001 | action-card-system.md | Card schema(派生 #10 schema 子集) | ADR-0009 | ✅ |
| TR-card-002 | action-card-system.md | AP cost 40/40/20 分布 lint | — | 📋 GDD-internal(numeric)|
| TR-card-003 | action-card-system.md | Hero is_hero flag + 互斥分组 | architecture.md L122 | ⚠️ Partial |
| TR-card-004 | action-card-system.md | card_played + kpi_contribution_reported + report_overage | ADR-0001 | ✅ |
| TR-card-005 | action-card-system.md | hero_card_played 三 element 反馈 | ADR-0008 + ADR-0011 | ✅ |
| TR-run-meta-001 | run-meta-system.md | RunSummary schema(7 字段)| ADR-0003 sub-schema | ⚠️ Partial(architecture.md L126)|
| TR-run-meta-002 | run-meta-system.md | archive_index 200 cap FIFO + content-only unlocks | ADR-0003 + ADR-0013 | ✅ |
| TR-run-meta-003 | run-meta-system.md | HR 评语词条收集词库 | — | ❌ Gap(content-only,VS 推迟)|
| TR-run-meta-004 | run-meta-system.md | demo end 3 月 gate(DEMO_END_MONTH=3)| entities.yaml | ⚠️ Partial(registry constant)|
| TR-run-meta-005 | run-meta-system.md | run_meta_unlock 5 类白名单(content-only)| ADR-0001 forbidden + ADR-0003 | ✅ |

### Presentation Layer

| TR-ID | GDD | Requirement | ADR Coverage | Status |
|-------|-----|-------------|--------------|--------|
| TR-hud-001 | hud-diegetic.md | 8 diegetic 元素 mapping | ADR-0011 | ✅ |
| TR-hud-002 | hud-diegetic.md | sub-mode 视觉布局状态机 + 帧预算 ≤ 2ms / 屏 | ADR-0011 | ✅ |
| TR-hud-003 | hud-diegetic.md | 8 信号订阅 | ADR-0001 + ADR-0011 | ✅ |
| TR-hud-004 | hud-diegetic.md | art-bible §7.1 no overlay 锁(CanvasLayer 仅 sub-mode 切换屏)| ADR-0011 | ✅ |
| TR-hud-005 | hud-diegetic.md | farewell event 禁渲染 flash overlay | ADR-0001 + ADR-0011 | ✅ |
| TR-hud-006 | hud-diegetic.md | 总 draw call ≤ 70 / 100 budget | ADR-0011 | ✅ |
| TR-cardui-001 | card-play-dialogue-ui.md | 三档密度差异化渲染主消费 layer | ADR-0012 | ✅ |
| TR-cardui-002 | card-play-dialogue-ui.md | 玩家手牌 UI + NPC 立绘 + 选项交互 | architecture.md L137 | ⚠️ Partial(GDD-internal)|
| TR-cardui-003 | card-play-dialogue-ui.md | I-8 narrative_density_changed 订阅 | ADR-0001 + ADR-0012 | ✅ |
| TR-cardui-004 | card-play-dialogue-ui.md | 三档 fallback 链(brief→standard→verbose)| ADR-0012 | ✅ |
| TR-recap-001 | daily-weekly-recap-ui.md | Daily Recap (<90s) + Weekly Recap (周五)| architecture.md L138 | ⚠️ Partial(GDD-internal)|
| TR-recap-002 | daily-weekly-recap-ui.md | effort 三维度展示 + numeric_only 事件列表 | ADR-0012 | ✅ |
| TR-recap-003 | daily-weekly-recap-ui.md | HR 周报口吻 lint(扩展 RECAP.* keys)| ADR-0010 | ✅ |
| TR-recap-004 | daily-weekly-recap-ui.md | I-9 narrative_density_changed 订阅 | ADR-0001 + ADR-0012 | ✅ |
| TR-recap-005 | daily-weekly-recap-ui.md | AC-FAREWELL-01 + AC-DENSITY-01 守门 | ADR-0001 | ✅ |
| TR-kpiui-001 | kpi-review-game-over-ui.md | 月末结算屏 + GAMEOVER 离职证明屏 + Archive 列表屏 | ADR-0006 + ADR-0007 + ADR-0013 | ✅ |
| TR-kpiui-002 | kpi-review-game-over-ui.md | 三屏 own 节点树 + GAMEOVER.CERTIFICATE.[reason] | ADR-0009 + ADR-0011 | ✅ |
| TR-kpiui-003 | kpi-review-game-over-ui.md | KPI Review 三轨 800ms intro fade-in EASE_IN_OUT | ADR-0007 | ✅ |
| TR-kpiui-004 | kpi-review-game-over-ui.md | GAMEOVER 1500ms linear easing=NONE | ADR-0006 | ✅ |
| TR-kpiui-005 | kpi-review-game-over-ui.md | Archive 200 元素 ScrollContainer 自动 culling + 懒加载 | ADR-0013 | ✅ |
| TR-kpiui-006 | kpi-review-game-over-ui.md | breakdown 三行 HR 戏谑口吻 | ADR-0010 | ✅ |
| TR-mainmenu-001 | main-menu-pause-settings-ui.md | 主菜单 4 入口 + Pause + Settings 子屏 | architecture.md L140 | ⚠️ Partial(GDD-internal)|
| TR-mainmenu-002 | main-menu-pause-settings-ui.md | Settings 信号合流 6 类 | ADR-0001 + ADR-0004 + ADR-0014 | ✅ |
| TR-mainmenu-003 | main-menu-pause-settings-ui.md | narrative_density 选项 + 三档心理模型 | ADR-0012 | ✅ |
| TR-mainmenu-004 | main-menu-pause-settings-ui.md | Archive 入口 | ADR-0013 | ✅ |
| TR-mainmenu-005 | main-menu-pause-settings-ui.md | 4 类 settings 信号合流至 #6 单 timer | ADR-0004 | ✅ |
| TR-notification-001 | notification-warning-system.md | 4 类预警 schema | architecture.md L141 | ⚠️ Partial(VS tier)|
| TR-notification-002 | notification-warning-system.md | 通过 #13 HUD diegetic 元素 visual variant 显示 | ADR-0011 | ✅ |
| TR-notification-003 | notification-warning-system.md | HR 口吻预警语义 | ADR-0010 | ✅ |

### VS / Alpha Tier

| TR-ID | GDD | Requirement | ADR Coverage | Status |
|-------|-----|-------------|--------------|--------|
| TR-tutorial-001 | tutorial-onboarding-system.md | TutorialState autoload 子节点 | ADR-0002(autoload 顺序)| ✅ |
| TR-tutorial-002 | tutorial-onboarding-system.md | Day 1-3 fixed_hand_override + ONBOARDING tier | — | ❌ Gap(VS tier 推迟可接受)|
| TR-tutorial-003 | tutorial-onboarding-system.md | M1 KPI 评语 + tutorial_completed flag | ADR-0003 sub-schema | ✅ |
| TR-tutorial-004 | tutorial-onboarding-system.md | inject_onboarding_hint() API | — | ❌ Gap(VS tier 推迟)|
| TR-a11y-001 | accessibility-options.md | AccessibilitySettings autoload + 字体 4 档 + 色盲 3 档 | ADR-0014 | ✅ |
| TR-a11y-002 | accessibility-options.md | 注入 7+ 系统的渲染循环(Anti-P1 红线 PR-blocking)| ADR-0014 | ✅ |
| TR-a11y-003 | accessibility-options.md | AccessKit 4.5+ 屏幕阅读器适配 | ADR-0014 | ✅ |
| TR-a11y-004 | accessibility-options.md | dual-focus mode 4.6 | ADR-0014 | ✅ |
| TR-a11y-005 | accessibility-options.md | mute_visual_parity(Hero card 三 element 反馈)| ADR-0008 | ✅ |
| TR-a11y-006 | accessibility-options.md | 字体 fallback 链 + AUTO_FIT_FLOOR_PX=11 | ADR-0014 + ADR-0004 | ✅ |
| TR-a11y-007 | accessibility-options.md | reduce_motion(VS 起,MVP 不实施)| — | ❌ Gap(VS 推迟,可接受)|
| TR-a11y-008 | accessibility-options.md | TTS(野心版)| — | ❌ Gap(野心版,推迟)|

---

## Coverage Gaps Summary

### ❌ True Gaps (no ADR / no architecture coverage): **6 项**

全部为 VS / Alpha tier 推迟项,**不阻塞 MVP architecture**:

| TR-ID | Gap 描述 | Engine Risk | Recommended Action |
|-------|---------|-------------|--------------------|
| TR-event-012 | Lisa 跳槽线必发 playtest 验证 | LOW(playtest)| Beta playtest 实测;无需独立 ADR |
| TR-run-meta-003 | HR 评语词条收集词库 | LOW(content)| writer 创作清单;无需独立 ADR |
| TR-tutorial-002 | Day 1-3 fixed_hand_override + ONBOARDING tier | LOW | VS tier `/architecture-decision tutorial-day-1-3` 推迟 |
| TR-tutorial-004 | inject_onboarding_hint() API | LOW | VS tier ADR 推迟 |
| TR-a11y-007 | reduce_motion 实施 | LOW | VS tier ADR 推迟 |
| TR-a11y-008 | TTS 实施 | LOW | 野心版 ADR(超出 Alpha tier scope)|

### 📋 GDD-Internal (numeric formula / single-system rule): **13 项**

不需要 cross-system ADR(GDD 自身已 lock):
- TR-loc-005(CSV plural form 4.6)
- TR-ap-002(AP cost 分布 lint)/ TR-ap-007(F1-F5 公式)
- TR-card-002(AP cost 40/40/20)
- TR-npc-002(F3 leave_probability 8 NPC 参数)
- TR-kpi-002(F1-F4 公式)/ TR-kpi-010(deterministic RNG)

### ⚠️ Partial Coverage: **25 项**

GDD-internal architecture decisions(单系统内部 stable contract,architecture.md 摘要级覆盖,不需独立 ADR):
- Audio 4 Bus / Lighting 8 sub-mode 色值 / Input 状态机 / NPC schema / 等

**评估**:Partial 项均为 `architecture.md` Module Ownership 表覆盖,实施层 GDD 自身已锁定,无 cross-system ambiguity。**不影响 PASS verdict**。

---

## GDD Revision Flags(Action Items)

| GDD | 行号 | 现有文本 | 建议修正 | Priority |
|-----|------|---------|---------|---------|
| `event-script-engine.md` | L156, L232-237 | "JSON-primary + tres runtime" | 与 ADR-0009 仲裁:保留 ADR-0009 ".tres 单文件 per event"(Inspector 主路径),GDD Rule 18 retrofit 为"writer 用 Godot Inspector 编辑 EventResource;.tres 是 git-friendly 格式;JSON 仅作为可选导出工具(非 authoring 主路径)" | **MUST FIX**(blocking writer 工作流)|
| `kpi-reverse-threshold-system.md` | L442 | "M1 开除走剧本路径,**不触发 GAME OVER**" | 改为"M1 开除经过 `EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3` 剧本,5 秒玩家阅读期后 emit `dismissal_finalized` → `#9` emit `game_over_triggered(kpi_fail_3, 1)`(ADR-0006 双路径合并)" | **MUST FIX**(对齐 ADR-0006)|

---

## Architecture.md Revision Flags(Action Items)

| 文件 | 行号 | 现有文本 | 建议修正 | Priority |
|------|------|---------|---------|---------|
| `architecture.md` | L498-501 | `kpi_review_intro_duration_ms = 1000ms` + `#5` 1.0s + `#4` 1.0s + `#16` 1.0s | 改为 800ms 三轨 cross-fade(对齐 ADR-0007)| **SHOULD FIX**(stale text 误导后续 ADR 撰写)|
| `architecture.md` | L519 | ADR-0009 "JSON-primary + EventDefinition extends Resource" | 改为 ADR-0009 ".tres 单文件 per event + EventResource extends Resource + Inspector 编辑 + EditorPlugin EventLinter 实时反馈"(对齐 ADR-0009 Decision §1)| **SHOULD FIX** |

或者:删除 `Required ADRs` 段(L437-540)— ADRs 已撰写,该段为 historical 留念。

---

## Performance Budget Verification

✓ 全部 budget 与 architecture.yaml 一致:

```
60fps × 16.6ms 总预算
├─ Audio ≤ 1ms
├─ Lighting < 1ms
├─ 各 UI ≤ 2ms × ~3 = 6ms
├─ Save snapshot ≤ 4ms
└─ 缓冲 ≈ 8ms

启动 5000ms = 720ms 必要 + 4280ms 缓冲 ✓
HUD draw call 70 / 100 ✓
save meta load 50ms ≤ autosave_perf_hard_ceiling_ms ✓
ARCHIVING 50ms 主线程 在 1500ms transition 演出期间执行 ✓
KPI Review intro 800ms vs GAMEOVER 1500ms 区分清晰 ✓
```

---

## Open Questions(deferred,non-blocking)

| OQ | 来源 | Target |
|----|------|--------|
| OQ-SDF-ENG-01 | ADR-0002 | `PROCESS_MODE_ALWAYS` 4.6 实测 / Pre-Production prototype |
| OQ-SDF-ENG-02 | ADR-0002 | `change_scene_to_packed()` 4.5 性能基准 / Pre-Production prototype |
| OQ-SDF-ENG-03 + OQ-EVT-ENG-01 | ADR-0002 + ADR-0009 | `@abstract` 4.5+ 实测(共享) / Pre-Production prototype |
| OQ-A14-ENG-01 | ADR-0014 | AccessKit 4.5+ 屏幕阅读器实测 / Pre-Production |
| OQ-A14-ENG-02 | ADR-0014 | dual-focus mode 4.6 实测 / Pre-Production |
| OQ-03 | ADR-0003 | HDD+AV p99 ≤ 50ms 实测 / Polish |
| OQ-KPI-01 | architecture.md | 标准玩家 M11 ± 2 GAME OVER 实证 / `/prototype core-loop` |
| OQ-EVT-03 | architecture.md | F1-F4 公式 RNG fairness / `/prototype core-loop` |
| 18 fresh session GDD reviews | — | 与 architecture 并行 |

---

## Required ADRs(Optional, post-CONCERNS)

**当前状态**:14 ADRs 完整覆盖 Foundation/Core/Feature/Presentation/Polish 层 cross-cutting decisions。

**No critical ADRs missing for MVP architecture**.

**Optional Future ADRs**(可在 stories 实施时按需创):
1. **ADR-0015 Tonemapper Filmic Lock**(优先级 LOW):明确 Godot 4.6 AgX tonemapper 不启用,强制 Filmic — `#5 Lighting` Tonemapper 锁
2. **ADR-0016 Audio Bus Architecture**(优先级 LOW):4 Bus(Master/Music/Ambient/SFX)正式化(目前 architecture.md L109 摘要级覆盖)
3. **VS Tier ADRs**:Tutorial Day 1-3 hint API + reduce_motion + TTS(VS / 野心版 推迟)

---

## Verdict 详解

### CONCERNS Verdict 触发原因

**非 BLOCKING**,但需在 Pre-Production 进入前清理:

| Finding | 类型 | 阻塞级别 |
|---------|------|---------|
| #10 Rule 18 vs ADR-0009 | ADR-vs-GDD writer 工作流冲突 | MUST FIX(GDD 微修)|
| #9 Edge 1.4 vs ADR-0006 | ADR-vs-GDD stale text | MUST FIX(GDD 微修)|
| architecture.md L498-501 | Doc-internal stale text(800ms vs 1000ms)| SHOULD FIX(architecture.md 微修)|
| architecture.md L519 | Doc-internal stale text(JSON vs .tres)| SHOULD FIX(architecture.md 微修)|

### PASS 不被赋予的原因

严格 PASS 要求"All requirements covered, no conflicts, engine consistent"— 我们有 0 ADR-vs-ADR conflicts + engine consistent ✓,但 2 项 ADR-vs-GDD 文本不一致 + 2 项 doc-internal stale text → CONCERNS 是合适 verdict。

### FAIL 不被赋予的原因

无 critical Foundation/Core 层 gaps + 无 blocking cross-ADR conflicts + 全 8 BLOCKING 已仲裁 → 远未达 FAIL。

---

## Recommended Next Steps(Pre-Production 进入路径)

### Immediate(完成 architecture-review CONCERNS 清理)

1. **GDD micro-edit batch**(可在 fresh session 跑):
   - `event-script-engine.md` Rule 18 retrofit 为 ".tres 单文件 + Inspector 主路径"
   - `kpi-reverse-threshold-system.md` Edge 1.4 retrofit 为 "M1 开除经过剧本最终 GAME OVER"

2. **architecture.md micro-edit**(本 session 可跑或 deferred):
   - L498-501 三轨锚 1000ms → 800ms 修正
   - L519 ADR-0009 "JSON-primary" → ".tres 单文件" 修正

### Subsequent(`/architecture-review` CONCERNS 清理后)

3. **`/create-control-manifest`** — 产出 layer rules manifest(programmer 编码 do/don't 清单)— 已在 work queue Task #4
4. **`/test-setup`** — GUT 测试框架 + GitHub Actions CI — Task #5(并行 #4)
5. **`/create-epics`** — 14 ADRs 各 epic + GDD requirement 锁定 — Task #6(blocked by #4)
6. **`/create-stories`** — 每 epic 拆 stories — Task #7(blocked by #6)

### Parallel(non-blocking)

7. **18 fresh session `/design-review`** — Save + Input 已 Approved,其余 18 GDD lean review(并行 architecture pipeline)— Task #3 [FRESH]

### Pre-Production Gate

执行 `/gate-check pre-production` 在以下条件全 PASS 时:
- 14 ADRs 全 Accepted ✓(lean mode 已等同)
- GDD micro-edits 落地(2 项 GDD revision flag)
- Control manifest 创建(Task #4 输出)
- Test framework setup 完成(Task #5 输出)
- 关键 GDD reviews 通过(Foundation 5 中至少 #6 / #7 / #9 / #10 Approved)

---

## TR Registry Update Summary

`docs/architecture/tr-registry.yaml` 在 Phase 8 写入 **139 个 TR-ID**(20 系统全套),全部 status: active。

后续 `/architecture-review` 重跑可基于本 registry 增量比对 — TR-ID 永不重号。

---

## Reflexion Log

`docs/consistency-failures.md` 不存在 — 跳过 append(skill 协议:不创建,仅 append 已存在文件)。

---

**End of Report.**
