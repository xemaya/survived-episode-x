# Story 009: EVENT.KPI.FIRED_DISMISSAL Path B Script

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` Rule 17 | **Requirement**: `TR-event-010` + `TR-event-011`
**ADR**: ADR-0006 Path B 唯一路径 + dismissal_finalized signal owner = #10
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: dismissal_triggered 订阅 → 检索 EVENT.KPI.FIRED_DISMISSAL.[reason] 剧本
- Required: 剧本演出 5 秒玩家阅读期 → emit dismissal_finalized
- Forbidden: #10 emit game_over_triggered(违反 Path B 单 owner)

## Acceptance Criteria

- [ ] `_on_dismissal_triggered(reason)` 订阅 #9 KPI emit
- [ ] 检索 `EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3 / kpi_overflow / relationship_collapse` 3 剧本(基于 reason)
- [ ] 剧本含 `EmitDismissalFinalizedEffect` — 5 秒玩家阅读期后自动 emit `dismissal_finalized`
- [ ] **AC-COMPAT** dismissal_triggered → game_over_triggered 链 ≤ 30s(剧本时长上限)

## Implementation Notes

```gdscript
signal dismissal_finalized

func _on_dismissal_triggered(reason: StringName) -> void:
    var event_id := StringName("EVENT.KPI.FIRED_DISMISSAL." + str(reason))
    var event := _get_event_by_id(event_id)
    if event == null:
        push_error("Missing dismissal script: %s" % event_id)
        emit_signal(&"dismissal_finalized")  # fallback
        return
    _trigger_event(event)
    # 5 秒玩家阅读期 — 通过 EmitDismissalFinalizedEffect 自动 emit
```

```gdscript
class_name EmitDismissalFinalizedEffect extends EventEffect
@export var delay_sec: float = 5.0

func apply(context: EventContext) -> void:
    await context.tree.create_timer(delay_sec).timeout
    EventScriptEngine.dismissal_finalized.emit()
```

## QA Test Cases

- dismissal_triggered → 检索剧本 → 5s 阅读期 → emit dismissal_finalized
- 缺剧本 → fallback emit + push_error
- 链 ≤ 30s 上限

## Test Evidence

`tests/integration/event/path_b_dismissal_test.gd`(协作 #9 KPI Story 008)

## Dependencies

- Depends on: Story 003 + KPI Story 008(dismissal_triggered)
- Unlocks: KPI Story 008 完整 Path B

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数
**Test Evidence**: `tests/integration/event/path_b_dismissal_test.gd` (~115 行 / 6 tests / GdUnit4 + SignalCapture) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`on_dismissal_triggered(reason)` 检索 `EVENT.KPI.FIRED_DISMISSAL.[reason]` event_id (StringName 拼接),缺剧本 fallback emit `dismissal_finalized` + push_error,正常路径 dispatch 通过 emit_event_started — 由 EmitDismissalFinalizedEffect 5s 后 emit dismissal_finalized,delay_sec=0 时同步 (单测确定性);`#10` 不直接 emit `game_over_triggered` — 仅 emit `dismissal_finalized` (ADR-0001 forbidden_pattern dual_emit 守门 — KPI 现有 hook `_on_dismissal_finalized` 已等待此 signal);无 BLOCKING / 无 inline fix
**Engine API Verification**: `await tree.create_timer(delay).timeout` — 标准 4.x;Callable.is_valid() — 4.x 标准
**Deviations** (1 项 ADVISORY):
1. ADR-0001 / 0006 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new (实际 Path B 5 reason 剧本 .tres 由 narrative writer 后续 author;Engine 端守门齐备)
**API surface**: `signal dismissal_finalized(reason)` (owner = #10) + `on_dismissal_triggered(reason)` 订阅入口 + `emit_dismissal_finalized(reason)` + `EmitDismissalFinalizedEffect` 子类 (delay_sec / reason / dismissal_emitter Callable seam)
