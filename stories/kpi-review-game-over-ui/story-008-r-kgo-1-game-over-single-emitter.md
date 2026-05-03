# Story 008: R-KGO-1 game_over_triggered 唯一启动 + breakdown 一帧守门

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: AC-ROBUST-01 [BLOCKING] + ADR-0006

**ADR Governing Implementation**: ADR-0006 Dismissal/GAMEOVER Path
**ADR Decision Summary**: `game_over_triggered` 由 `#9 KPI` 单点 emit;`#16` 收到后须先 render breakdown 一帧再淡入 cert(R-KGO-1 守门:"先看见数字,再看见证书";避免玩家来不及看清楚阈值就被切走)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 同帧多信号顺序由 GDScript 单线程保证 = 调用顺序;`call_deferred` 用于推 1 帧。

**Control Manifest Rules (Presentation)**:
- Required: 信号双路径(threshold + game_over)由 state 机 + flag 串联,不能并行执行
- Forbidden: state 直接从 `KPI_REVIEW_WAITING` 跳 `GAMEOVER_TRANSITION`(必经 ACTIVE 一帧)
- Guardrail: breakdown 一帧后切 GAMEOVER 累计 ≤ 2 帧

---

## Acceptance Criteria

- [ ] AC-ROBUST-01 [BLOCKING]: `game_over_triggered` 在 `kpi_threshold_changed` 未渲染时到达,`#16` 处理:`_breakdown_rendered` flag 强制先渲染 breakdown 一帧,再淡入离职证明;**不跳过** breakdown
- [ ] state 转移须经过 KPI_REVIEW_ACTIVE(至少 1 帧)— 不允许 WAITING 直跳 GAMEOVER_TRANSITION
- [ ] 同帧 emit 顺序:`#9` 内 emit 顺序 = `kpi_threshold_changed` first → `game_over_triggered` second(由 `#9` Story 010 守门保证;本 story 消费端验证)
- [ ] `_breakdown_rendered` flag 在 `_render_breakdown()` 末尾置 true;在 state 重置时清零

---

## Implementation Notes

*Derived from ADR-0006 + R-KGO-1:*

- 双信号 handler:
  ```gdscript
  var _breakdown_rendered := false

  func _on_kpi_threshold_changed(breakdown: Dictionary) -> void:
      if state != KPI_REVIEW_ACTIVE:
          push_warning("breakdown 信号到达但 state 错")
          return
      _render_breakdown(breakdown)  # Story 003
      _breakdown_rendered = true

  func _on_game_over_triggered(reason: String, month: int) -> void:
      if not _breakdown_rendered:
          push_error("R-KGO-1 守门:game_over 在 breakdown 之前到达 — 强制 defer 1 帧")
          call_deferred("_on_game_over_triggered", reason, month)
          return
      _enter_gameover_transition(reason)  # Story 005 + 006
  ```
- state 重置(返 Main Menu 等)时 `_breakdown_rendered = false`
- defer 路径 1 帧后再次进入 handler;若 breakdown 仍未渲染(信号丢失),走第二次 push_error + 直接强制渲染兜底 breakdown(降级体验,优于 cert 直接淡入)

---

## Out of Scope

- Story 005/006/007: GAMEOVER Tween / cert 嵌入 / skip
- `#9 KPI` Story 010 emit 顺序守门(上游守门,本 story 不实施)
- 失败重试上限 / 兜底 breakdown 内容(降级实施可在 Story 008.5 future revision 做,MVP 内 push_error + defer 1 次足够)

---

## QA Test Cases

- **AC-ROBUST-01 [BLOCKING]**: 守门核心
  - Given: state == KPI_REVIEW_ACTIVE,`_breakdown_rendered = false`
  - When: `game_over_triggered` 先到达(模拟 race)
  - Then: 第一次调用走 push_error + call_deferred 路径;1 帧后 `kpi_threshold_changed` 触发 → `_breakdown_rendered = true` → defer 的 `_on_game_over_triggered` 再次执行 → state 切 GAMEOVER_TRANSITION
  - Edge cases: 双信号同帧到达(顺序 normal)走正常路径;breakdown 永不到达(信号丢失)走第二次 push_error 兜底

- **AC-2**: state 路径强制
  - Given: state == KPI_REVIEW_WAITING
  - When: `game_over_triggered` 直达(异常路径)
  - Then: push_error("state 错"),不切 GAMEOVER_TRANSITION;等待 KPI_REVIEW_ACTIVE 进入

- **AC-3**: flag 重置
  - Given: state 重置至 KPI_REVIEW_WAITING(返 Main Menu)
  - When: 重新进入 KPI Review
  - Then: `_breakdown_rendered == false`

---

## Test Evidence

**Required evidence**: `tests/integration/kpi_ui/r_kgo_1_game_over_single_emitter_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 003(breakdown 渲染);Story 005(GAMEOVER Tween);`#9 KPI` Story 010(emit 顺序守门)
- Unlocks: 无(BLOCKING 验证完成 → epic 进入 Polish)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数 in `tests/integration/kpi_ui/r_kgo_1_game_over_single_emitter_test.gd`
**Test Evidence**: `tests/integration/kpi_ui/r_kgo_1_game_over_single_emitter_test.gd` (115 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
- AC-ROBUST-01 [BLOCKING] R-KGO-1 守门 (defer + replay) → `test_game_over_before_breakdown_defers` + `test_breakdown_then_replays_pending_game_over`
- 正常顺序路径 → `test_breakdown_first_then_game_over_normal_path`
- AC-2 state 路径强制(WAITING 直跳禁止)→ `test_waiting_to_gameover_direct_rejected`
- AC-3 flag 重置 → `test_reset_for_new_run_clears_flag`
- 降级兜底(breakdown 永不到达)→ `test_degraded_fallback_when_breakdown_never_arrives`

**Code Review**: APPROVED;`_breakdown_rendered` flag + `_pending_game_over` Dictionary + `_game_over_deferred_once` 防无限 defer;两次失败后强制渲染 empty breakdown 兜底;无 BLOCKING
**Deviations** (无):
**Tech debt**: None new
**API surface**: `breakdown_rendered` signal + `_pending_game_over: Dictionary` + `reset_breakdown_flag_for_test()` 测试钩子
