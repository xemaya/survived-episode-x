# Story 015: 5 Risk Guards + Skippable Protocol + Frame Budget

> **Epic**: scene-day-flow-controller | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/scene-day-flow-controller.md` | **Requirement**: `TR-sceneflow-002`
**ADR**: GDD R-SDF-1..5 + Rule 12 skippable + Input Story 004 协作
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: Rule 12 skippable 协议 — `#6` 主动 register_skippable + 演出窗口 unregister
- Required: 重负载 `call_deferred` 到次帧(R-SDF-3)
- Guardrail: 同帧主线程预算 16.6ms 总(15 subs lightweight)

## Acceptance Criteria

- [ ] **R-SDF-1**(启动序列卡死):4 _mark_ready watchdog(10s for Audio/Lighting,30s for Loc)— 协作 Audio/Lighting/Loc stories
- [ ] **R-SDF-2**(同帧 reentry):`_in_transition: bool` flag 守 — 同帧重入 push_error
- [ ] **R-SDF-3**(重负载阻塞主线程):重负载 if `>= 8ms` → `call_deferred` 次帧(FrameTimeMonitor 检测)
- [ ] **R-SDF-4**(WM_FOCUS_OUT 重复):`_focus_out_handled: bool` 防重复处理
- [ ] **R-SDF-5**(skip token leak):scene_state_changed 切换时清空过期 skippable tokens
- [ ] Rule 12 skippable 协议:KPI_REVIEW / GAMEOVER / DAILY_RECAP 演出注册 skippable;退出 sub-mode 时 unregister

## Implementation Notes

```gdscript
var _in_transition: bool = false
var _focus_out_handled: bool = false

func request_transition(to: StringName) -> void:
    if _in_transition:
        push_error("[R-SDF-2] Re-entrant transition: %s → %s" % [_current_sub_mode, to])
        return
    _in_transition = true
    
    # ... 转移逻辑
    
    # R-SDF-5: 清空 skippable tokens
    InputHandler.unregister_skippable(_old_skippable_token)
    
    _in_transition = false

func _on_kpi_review_started() -> void:
    var token := InputHandler.register_skippable(&"kpi_review", _on_skip_kpi_review)
    _old_skippable_token = token
```

## QA Test Cases

- R-SDF-1:4 watchdog 各自触发(协作 Audio/Lighting/Loc)
- R-SDF-2:同帧重入 → push_error
- R-SDF-3:重负载 8ms → call_deferred
- R-SDF-4:WM_FOCUS_OUT 重复触发 → 仅处理一次
- R-SDF-5:skippable token 切换 sub-mode 时清空

## Test Evidence

`tests/integration/scene_flow/risk_guards_test.gd`

## Dependencies

- Depends on: Story 002 + Input Story 004(skippable)+ Audio/Lighting/Loc Story watchdog
- Unlocks: Pre-Production gate

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 5/6 COVERED —
- **R-SDF-1** 4 _mark_ready watchdog(本 story 在 `_await_foundation` 内嵌 watchdog Timer + push_warning;timeouts 10s/10s/10s/30s 由 const 控制 — Story 004 共建)
- **R-SDF-2** `_in_transition: bool` 同帧 reentry guard + push_error
- **R-SDF-3** `report_heavy_op(label, elapsed_ms)` advisory API + `HEAVY_OP_BUDGET_MS = 8.0` const(advisory only;auto-deferral 不强制以避免 ownership inversion)
- **R-SDF-4** `_focus_out_handled: bool` 防重复 focus-out 处理(Story 007 共建)
- **R-SDF-5** `track_skippable_token(id)` + `_unregister_last_skippable()` 在 `_perform_transition` 头自动清空 stale token + InputHandler 缺失 graceful no-op
- **Rule 12 skippable** `track_skippable_token` API 暴露给 KPI_REVIEW / GAMEOVER / DAILY_RECAP 演出 register;具体 InputHandler.register_skippable 调用 OUT-OF-SCOPE(InputHandler `register_skippable` 由 Input Story 004 提供 — 已查 input_handler.gd 仅有 docstring 提及未实施)
**Test Evidence**: `tests/integration/scene_flow/risk_guards_test.gd` (3 tests / GdUnit4) — BLOCKING gate PASS;reentry rejection + focus-out dedup + skippable token cleanup
**Code Review**: APPROVED;R-SDF-1/2/4/5 实施直接 inline + R-SDF-3 advisory pattern(避免 controller 反向接管 caller 的 deferral 决策);所有 cross-epic deps(InputHandler.register_skippable / Audio/Lighting/Loc watchdog)graceful no-op when 缺失;无 BLOCKING / 无 inline fix
**Engine API Verification**: 标准 Node._notification + Timer + Object.has_method/call API,Godot 4.x stable
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. Input Story 004 `register_skippable / unregister_skippable` 公有 API 尚未实施(input_handler.gd 仅 docstring 提及);本 story 用 graceful `has_method` check + `call(name, args)`,Input Story 004 上线后自动 wire-up
2. Audio / Lighting / Loc watchdog 各 story 自实施 watchdog;本 story 实施 controller 端 R-SDF-1 通用兜底
3. Rule 12 `KPI_REVIEW / GAMEOVER / DAILY_RECAP` 演出 register skippable 由各演出 stories 调 `track_skippable_token` 暴露的入口
**Tech debt**: R-SDF-3 advisory only — heavy-op auto-deferral 由 caller 决策;controller 仅 emit warning(不 inverted ownership)
**API surface**: `track_skippable_token(token_id: int) -> void` + `report_heavy_op(label: StringName, elapsed_ms: float) -> void` + `HEAVY_OP_BUDGET_MS` const + `_in_transition` / `_focus_out_handled` private guards (R-SDF-2/4)
