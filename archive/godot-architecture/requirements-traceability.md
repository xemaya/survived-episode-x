# Requirements Traceability Matrix (RTM)

> Generated: 2026-05-02 (Sprint N+1 P1 fix 后)
> Mode: `/architecture-review rtm`
> Engine: Godot 4.6 (pinned 2026-02-12)
> Coverage Verdict: **CONCERNS** (无 BLOCKING gap;35 TR ADR 空 + 14 test 路径漂移)
> Total TRs: 139 | TR→ADR Covered: 104 | TR→ADR Gaps: 35 | Story Implemented: 139/139 | Test (basename match): 220+/244

## How to Read This Matrix

| Column | Meaning |
|--------|---------|
| TR-ID | Stable requirement ID from `tr-registry.yaml`(永不重编号)|
| System | GDD 子系统 slug |
| ADR | 治理该需求的 ADR 列表(空 = 该需求未由 ADR 锁定决策)|
| Story Count | 引用此 TR-ID 的 story 数(stories live under `production/epics/{system}/`)|
| Test Status | COVERED(test exists) / RENAMED(test renamed/extension drift) / MISSING(故事 reference 但实际不存在) / BLOCKED(故事 Blocked,test 未创建)|

## Phase 1 — ADR 状态全景

| ADR | Title | Status | Post-Cutoff API |
|---|---|---|---|
| ADR-0001 | Signal Ownership Matrix | Accepted | None |
| ADR-0002 | Autoload Init Order + Boot Sequence | Accepted | `@abstract` (4.5+) / `change_scene_to_packed` (4.5+) / `EditorDock` (4.6) |
| ADR-0003 | Save Format + WorkerThreadPool Strategy | Accepted | `FileAccess.store_*` 返 bool (4.4) |
| ADR-0004 | Settings Reflow + Coalescing | Accepted | None |
| ADR-0005 | Lighting Accumulation 4 Dimensions | Accepted | None |
| ADR-0006 | Dismissal/GAMEOVER Path Resolution | Accepted | None |
| ADR-0007 | KPI Review Three-Track Anchor | Accepted | None |
| ADR-0008 | Visual Boundary Pillar4 / Mute Parity | Accepted | None |
| ADR-0009 | Event Schema Format | Accepted | `@abstract` (4.5+) |
| ADR-0010 | Subject Inversion Lint Domains | Accepted | None (Python lint) |
| ADR-0011 | HUD Diegetic Render | Accepted | None |
| ADR-0012 | Three-Density Rendering | Accepted | None |
| ADR-0013 | Archive 200 Virtual Scroll | Accepted | None |
| ADR-0014 | Accessibility Settings Injection | Accepted | AccessKit (4.5) / dual-focus (4.6) |

**全 14 ADR 处于 Accepted 状态(2026-05-02 升级 from Proposed)。**

## Phase 2 — TR ↔ ADR Coverage Summary

| System | TR 总数 | 有 ADR Cover | 无 ADR Cover (Gap) |
|---|---|---|---|
| save | 10 | 10 | 0 |
| input | 7 | 3 | 4(TR-input-002 / 003 / 006 / 007)|
| loc | 6 | 5 | 1(TR-loc-005)|
| audio | 7 | 4 | 3(TR-audio-001 / 004 / 007)|
| lighting | 13 | 10 | 3(TR-lighting-001 / 010 / 011)|
| sceneflow | 10 | 9 | 1(TR-sceneflow-009)|
| ap | 8 | 3 | 5(TR-ap-001 / 002 / 003 / 007 / 008)|
| npc | 5 | 3 | 2(TR-npc-001 / 002)|
| kpi | 10 | 7 | 3(TR-kpi-001 / 002 / 010)|
| event | 12 | 11 | 1(TR-event-012)|
| card | 5 | 3 | 2(TR-card-002 / 003)|
| run-meta | 5 | 3 | 2(TR-run-meta-003 / 004)|
| hud | 6 | 6 | 0 |
| cardui | 4 | 3 | 1(TR-cardui-002)|
| recap | 5 | 4 | 1(TR-recap-001)|
| kpiui | 6 | 6 | 0 |
| mainmenu | 5 | 4 | 1(TR-mainmenu-001)|
| notification | 3 | 2 | 1(TR-notification-001)|
| tutorial | 4 | 2 | 2(TR-tutorial-002 / 004)|
| a11y | 8 | 6 | 2(TR-a11y-007 / 008,均为 VS / 野心版)|
| **TOTAL** | **139** | **104(75%)** | **35(25%)** |

## Phase 3 — TR → Story 实施 Coverage

**139/139 TR 全部至少被 1 个 story 引用(100% 实施覆盖率)**。
- 总 stories: 234 个 across 20 epics
- Status 分布:Complete=77 / Done=20+ / Ready=12+ / **Blocked=6**(3 tutorial + 3 recap)
- Blocked stories 均挂在 VS tier ADR pending(`tutorial-day-1-3-hint-api`)或 propagation flag #6/#7(`scene_state_changed` ctx 扩展 + `register_skippable` `min_display_ms` 扩展)上

## Phase 4 — Story → Test 验证 Coverage

| 状态 | 数量 | 说明 |
|---|---|---|
| Test 存在(确认路径)| 220+ | 故事引用与实际文件路径一致 |
| Test RENAMED / 扩展名漂移 | ~10 | `tests/unit/recap_ui/*` → 实际在 `tests/unit/recap/`;`*_test.gd` → 实际为 `*_test.py`(7 例 lint 类 Python tests);`disk_full_test.gd` → `disk_full_retry_test.gd`(语义保留)|
| Test BLOCKED(随 story Blocked) | 6 | 3 tutorial + 3 recap,Blocked 故事的 test 路径占位但未创建 |
| Test 真缺失 | ~8 | `crash_recovery_test.gd` / `archive_200_full_dialog_test.gd` / `exit_timeout_test.gd` / `retry_backoff_test.gd` / `gameover_transition_linear_easing_test.gd` / `audio_bank_size_lint_test.gd` / `ui_no_sfx_test.gd` / `theme_validation_test.gd` 等 — 故事均 Complete 状态,但引用的具体文件名缺失(语义可能由相邻 test 覆盖,需手工 audit)|

测试目录已建齐:`tests/{unit,integration}/{a11y,ap,audio,card,card_ui,event,hud,input,kpi,kpi_ui,lighting,loc,main_menu,notification,npc,recap,run_meta,save,scene_flow,tutorial}/` 全 20 系统覆盖。

## Phase 5 — Cross-ADR Consistency

| 检查项 | 结果 |
|---|---|
| Signal ownership 单一性(ADR-0001 vs ADR-0005 / 0006 / 0007 / 0009)| ✅ 一致 — `accumulation_event` owner=#5;`game_over_triggered` 单 emit 源=#9;`kpi_review_started` owner=#9;`dismissal_finalized` owner=#10 |
| Init order 与 PROCESS_MODE(ADR-0002 vs 全员)| ✅ 一致 — `SceneDayFlowController` `PROCESS_MODE_ALWAYS`(末位 autoload),其余 `PAUSE_INHERIT` |
| 防抖 500ms 单 timer(ADR-0004 vs ADR-0001 / mainmenu)| ✅ 一致 — 单 timer 在 #6;6 信号合流(meta_settings_debounce_ms 5 GDD 消费者锁定)|
| GAMEOVER 1500ms linear easing(ADR-0006 vs ADR-0008 vs ADR-0011)| ✅ 一致 — meta.run_ended fsync 先 → palette 灰度 1500ms → HUD 不渲 flash overlay |
| KPI Review 三轨 800ms anchor(ADR-0007 vs ADR-0005 vs Audio TR-audio-005)| ✅ 一致 — `kpi_review_started` 同步锚 |
| 三档密度 fallback 链(ADR-0009 vs ADR-0012)| ✅ 一致 — brief→standard→verbose,standard 必填 |
| Anti-P1 红线(ADR-0001 vs ADR-0006 vs ADR-0010)| ✅ 一致 — content-only unlocks 5 类白名单 + lint 8 master domain |

**0 cross-ADR 冲突。** 已知 cross-epic 链(ADR-0001↔0006↔0007↔0009)经 ADR Dependency Graph 顺序拓扑排序后 0 cycle。

## Phase 6 — Engine Compatibility

| Post-cutoff API | ADR(s) | Verification |
|---|---|---|
| `@abstract` 4.5+ | ADR-0002 + ADR-0009 | ✅ Verified at `breaking-changes.md` 4.4→4.5 row;OQ-SDF-ENG-03 实测项已建立 |
| `change_scene_to_packed()` 4.5+ | ADR-0002 | ✅ Verified;OQ-SDF-ENG-02 性能基准实测待 |
| `PROCESS_MODE_ALWAYS` | ADR-0002 | ✅ 4.0+ stable;OQ-SDF-ENG-01 实测项已建立 |
| `FileAccess.store_*` 返 bool 4.4+ | ADR-0003 | ✅ Verified;assert(ok) 校验 enforced |
| `accumulation_event` signal | ADR-0005(单 owner = #5)| ✅ 与 ADR-0001 仲裁一致 |
| AccessKit `Window.use_accessibility` 4.5+ | ADR-0014 | ✅ Verified |
| dual-focus 4.6 | ADR-0014 | ✅ Verified |

**0 deprecated API references。0 stale version。** 全 ADR 在 Engine Compatibility 章节声明 Risk Level + References Consulted。

## Phase 7 — Gaps Top 10(按 ROI 排序)

### Foundation Layer Gaps(优先级 P0,Logic 类 BLOCKING)

| # | TR-ID | Gap 类型 | 推荐补救 | ROI |
|---|---|---|---|---|
| 1 | TR-ap-001 / 002 / 003 / 007 / 008 | AP 经济核心公式 + 状态机 + 红线无 ADR cover(5 TR)| `/architecture-decision ap-economy-state-formulas`(F1-F5 公式 + 4 态状态机 + capacity_floor 单调红线)| 高 — 核心 gameplay 数值锚 |
| 2 | TR-kpi-001 / 002 / 010 | KPI monthly_threshold 单调 + F1-F4 公式 + RNG seed 无 ADR cover | `/architecture-decision kpi-formulas-rng`(α/β/γ 衰减 + deterministic seed)| 高 — Anti-P1 红线 |
| 3 | TR-npc-001 / 002 | NPC 8 套 relationship_score schema + F3 leave_probability 无 ADR cover | `/architecture-decision npc-relationship-schema-formulas` | 中 — gameplay 内核 |
| 4 | TR-input-002 / 003 / 006 / 007 | Input 3 态状态机 + skippable token API + SDL3 gamepad + Recursive Control 无 ADR cover(4 TR)| `/architecture-decision input-state-machine-and-skippable-stack` | 中 — 玩家体验关键 |

### Core Layer Gaps(优先级 P1)

| # | TR-ID | Gap 类型 | 推荐补救 | ROI |
|---|---|---|---|---|
| 5 | TR-card-002 / 003 | AP cost 40/40/20 lint + Hero is_hero 互斥分组 + 4 态状态机无 ADR cover | `/architecture-decision card-state-and-hero-exclusivity` | 中 |
| 6 | TR-tutorial-002 / 004 | Day 1-3 fixed_hand + ONBOARDING tier 5 NPC hint + inject_onboarding_hint API 无 ADR | VS tier ADR `tutorial-day-1-3-hint-api`(已 known blocker)| 低(VS tier 推迟 OK)|
| 7 | TR-audio-001 / 004 / 007 | 4 Bus 架构 + 30MB total + act_pause fade 公版统一无 ADR | 可融入既有 ADR-0002(autoload init)+ ADR-0007(三轨 anchor)的 Audio 子节;或新建 `/architecture-decision audio-bus-architecture` | 中 |
| 8 | TR-lighting-001 / 010 / 011 | 8 sub-mode 色值表 + Filmic tonemapper + palette swap shader 无 ADR | 可融入 ADR-0005 的扩展表格(sub-mode color matrix)| 低(数据驱动,可走 design 文档)|

### Test Path Drift(优先级 P1,补救成本极低)

| # | 漂移 | 推荐补救 | ROI |
|---|---|---|---|
| 9 | `tests/unit/recap_ui/*` (7 例)→ 实际 `tests/unit/recap/`;故事 references 用 `recap_ui` 命名 | 单批 sed: 同步 story Test Evidence 路径,或重命名 dir 至 `recap_ui/` | 高 — 5 分钟修复全 CI |
| 10 | `*_test.gd` 故事引用 → 实际 `*_test.py`(7 例 lint 工具)| 同步 story Test Evidence 后缀(.py 是 implementation truth — story doc 错)| 高 — 5 分钟修复全 CI |

### Test 真缺失(BLOCKING per Logic/Integration story type)

需逐项 audit 是否真缺失 vs 已被相邻 test 覆盖:
- `tests/integration/save/{crash_recovery,exit_timeout,retry_backoff,disk_full,gameover_transition_linear_easing,archive_200_full_dialog}_test.gd`(6 例,save Story 011/013/015/009 Complete 状态)
- `tests/unit/audio/audio_bank_size_lint_test.gd`(audio Story 008 Complete)
- `tests/integration/audio/ui_no_sfx_test.gd`(audio Story 012 Complete)

**注**:audit 结果可能多数转为 RENAMED 类(如 `disk_full_test.gd` 已确认是 `disk_full_retry_test.gd`)。建议运行 `/test-evidence-review save-system audio-manager` 单独闭环。

## Phase 8 — Blocked Stories(已知,非 RTM gap)

| Epic | Story | Blocker | 解锁时机 |
|---|---|---|---|
| tutorial | 002 / 003 / 004 | VS tier ADR `tutorial-day-1-3-hint-api` 待 | VS milestone |
| daily-weekly-recap-ui | 001 / 002 | propagation flag #6(`scene_state_changed` ctx 扩展)| VS milestone |
| daily-weekly-recap-ui | 007 | propagation flag #7(`register_skippable` `min_display_ms` 扩展)| VS milestone |

这 6 stories 不计入 BLOCKING — 已有上游 RFC blocker 跟踪。

## Verdict: **CONCERNS**

- ✅ 0 BLOCKING:无 cross-ADR 冲突 / 无 dependency cycle / 无 deprecated API / 0 stale engine version
- ⚠️ 35 TR(25%)无 ADR cover — 但全部为 Foundation/Core 层数值/算法/状态机决策,可由后续 ADR 增量补齐;不阻塞当前 Sprint N+1 已 Complete stories
- ⚠️ ~8 test 真缺失 + ~10 test 路径漂移 — 建议下一 sprint 用 `/test-evidence-review` 闭环
- ✅ 100% TR → Story 实施覆盖率(139/139)
- ✅ 全 14 ADR Accepted 状态(P1 升级 2026-05-02 完成)

## History

| Date | Coverage | Notes |
|---|---|---|
| 2026-05-02 | 75% TR→ADR / 100% TR→Story / ~90% Story→Test(含 RENAMED)| Initial RTM(rtm mode);14 ADR 全 Accepted;6 stories Blocked VS tier;Sprint N+1 P1 fix 后 |

## Recommended Next Steps(ranked by ROI)

1. **优先级 P0 — `/architecture-decision ap-economy-state-formulas`**:覆盖 TR-ap-001/002/003/007/008(5 TR 一次解决)
2. **优先级 P0 — `/architecture-decision kpi-formulas-rng`**:覆盖 TR-kpi-001/002/010(Anti-P1 红线)
3. **优先级 P1 — `/test-evidence-review save-system audio-manager`**:8 个真缺失 test audit + 路径漂移修复
4. **优先级 P1 — `/architecture-decision npc-relationship-schema-formulas`**:覆盖 TR-npc-001/002
5. **优先级 P2 — `/architecture-decision input-state-machine-and-skippable-stack`**:覆盖 TR-input-002/003/006/007
6. **优先级 P3(可推迟 VS tier)— `tutorial-day-1-3-hint-api` ADR**:解锁 6 Blocked stories 中 3 tutorial 项
