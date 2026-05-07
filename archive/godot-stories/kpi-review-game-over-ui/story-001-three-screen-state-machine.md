# Story 001: 三屏节点树 + 4 态状态机

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: `TR-kpiui-001`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0007 KPI Review Three-Track Anchor
**ADR Decision Summary**: KPI Review intro 800ms `EASE_IN_OUT` 三轨同步锚(audio/visual/UI 同帧 emit `kpi_review_started`)。状态机由 `#16` own,sub-mode dispatch 由 `#6` 仲裁。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Tween.set_trans(Tween.TRANS_LINEAR)` + `set_ease(Tween.EASE_IN_OUT)` 4.5+ 已稳。`StateMachine` 用 GDScript enum + match 实施,不依赖 `@abstract`(后者 4.5+,本 epic 不需要)。

**Control Manifest Rules (Presentation)**:
- Required: 单点 emit `scene_state_changed` 由 `#6` own;`#16` 仅订阅,不 dispatch sub-mode
- Forbidden: `await` 跨帧拆 transition 步骤(R-KGO-1 守门要求同帧切态)
- Guardrail: dispatch ≤ 1 帧(信号到达到首帧 UI 可见)

---

## Acceptance Criteria

*From GDD `design/gdd/kpi-review-game-over-ui.md` Section H,scoped to this story:*

- [ ] AC-FUNC-01: Given `#6 scene_state_changed(→KPI_REVIEW)`,When `#9 kpi_review_started` 到达,Then `KPIReviewPanel` 首帧可见(`KPI_REVIEW_WAITING → KPI_REVIEW_ACTIVE`,dispatch ≤ 1 帧)
- [ ] 4 态枚举: `KPI_REVIEW_WAITING / KPI_REVIEW_ACTIVE / GAMEOVER_TRANSITION / ARCHIVE_VIEW` 全部定义
- [ ] 三屏节点树 own:`KPIReviewPanel` / `GameOverCertPanel` / `ArchiveListPanel` 各自 Control 树独立
- [ ] 同帧状态切换无 `await`(R-KGO-1 守门前置)

---

## Implementation Notes

*Derived from ADR-0007 Implementation Guidelines:*

- 状态机定义:`enum KPIUIState { KPI_REVIEW_WAITING, KPI_REVIEW_ACTIVE, GAMEOVER_TRANSITION, ARCHIVE_VIEW }`
- 状态转移 matrix(单向 — 不允许回退):
  - `KPI_REVIEW_WAITING → KPI_REVIEW_ACTIVE`(收 `kpi_review_started`)
  - `KPI_REVIEW_ACTIVE → GAMEOVER_TRANSITION`(收 `game_over_triggered`,同帧无 await)
  - `GAMEOVER_TRANSITION → ARCHIVE_VIEW`(transition 完成 + Main Menu 进入)
  - `*  → KPI_REVIEW_WAITING`(初始化)
- 三屏 Control 树 own scenes 路径(待 Phase 4 `/ux-design` 产出):
  - `scenes/ui/kpi_review/kpi_review_panel.tscn`
  - `scenes/ui/gameover/gameover_cert_panel.tscn`
  - `scenes/ui/archive/archive_list_panel.tscn`
- 订阅 `#6 scene_state_changed` 只读 to/from,**不**主动调 `#6.request_transition()`(违反 Presentation Layer Forbidden #1)

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002: KPI Review 800ms intro fade-in 动画
- Story 005: GAMEOVER 1500ms transition 动画
- Story 010: Archive 列表 ScrollContainer 实例化逻辑

---

## QA Test Cases

*Lean mode — qa-lead test specs 在 `/story-readiness` + `/dev-story` 阶段补全。*

- **AC-1 (AC-FUNC-01)**: 状态机 dispatch ≤ 1 帧
  - Given: `KPIUIState == KPI_REVIEW_WAITING`,`#6 scene_state_changed(→KPI_REVIEW)` emit
  - When: 同帧 `#9 kpi_review_started` emit
  - Then: 下一帧 `KPIReviewPanel.visible == true` AND `state == KPI_REVIEW_ACTIVE`
  - Edge cases: `kpi_review_started` 在 `scene_state_changed` 之前到达(早帧序);信号双发 idempotent

- **AC-2**: 4 态枚举完整性
  - Given: `KPIUIState` enum
  - When: 反射枚举全部值
  - Then: 4 个值精确(WAITING/ACTIVE/GO_TRANSITION/ARCHIVE_VIEW),无多余无缺失

- **AC-3**: 同帧切态无 await
  - Given: 在 `_on_game_over_triggered` 内
  - When: 调用 `_transition_to(GAMEOVER_TRANSITION)`
  - Then: 函数同步返回(无 `await`)+ 下一帧 state == GAMEOVER_TRANSITION
  - Edge cases: 在 await 内 emit 信号(应 push_error,违反 R-KGO-1)

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/kpi_ui/three_screen_state_machine_test.gd` — must exist and pass
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `#6 Scene & Day Flow` Story 001(8 sub-mode enum)+ Story 002(scene_state_changed 信号);`#9 KPI` Story 006(kpi_review_started emit)
- Unlocks: Story 002, 005, 010

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 7 test 函数 in `tests/unit/kpi_ui/three_screen_state_machine_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/three_screen_state_machine_test.gd` (115 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-01 dispatch ≤ 1 帧 → `test_kpi_review_started_transitions_to_active` + `test_kpi_review_panel_visible_on_active`
- 4 态枚举 → `test_kpi_ui_state_enum_has_four_entries`
- 三屏节点树 own → `test_three_panel_hierarchy_independent`
- 同帧切态无 await → `test_transition_to_returns_synchronously` + `test_waiting_to_gameover_direct_rejected`
- reset → `test_reset_for_new_run_clears_state`

**Code Review**: APPROVED (lean autopilot inline);state machine + 4 enum + 3 panel ownership + same-frame transitions + R-KGO-1 guard wired;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. .tscn 资产 OUT-OF-SCOPE (UI team Phase 4) — controller 实施 widget hierarchy + signal wiring,Phase 4 对接真实 .tscn
**Tech debt**: None new
**API surface**: `KPIReviewScreenController` (class_name) + `KPIUIState` enum + `_transition_to()` + `handle_kpi_review_started()` + `reset_for_new_run()` + `dismissal_finalized` / `breakdown_rendered` / `archive_entry_deleted` / `intro_fade_finished` signals
