# Story 009: ap_consumed → game-time +60min (SceneFlow Integration)

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-006`
**ADR**: ADR-0001 + GDD Rule 9 + SceneFlow Story 011(协作 Rule 9 game-time tick)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: ap_consumed signal → SceneFlow `_on_ap_consumed` → game-time +60min(Rule 9 离散事件驱动)
- Required: weekend_rest_day signal subscriber = #7,energy +30

## Acceptance Criteria

- [ ] AP epic 内 emit `ap_consumed(amount)` → SceneFlow Story 011 订阅 → `_game_time_minutes += amount * 60`
- [ ] `_on_weekend_rest_day()` 订阅 SceneFlow `weekend_rest_day` signal → `current_energy = mini(100, current_energy + 30)` + emit energy_changed
- [ ] cross-system 时序:ap_consumed 在 try_consume_ap 同帧 emit;SceneFlow 同帧 update game-time

## Implementation Notes

```gdscript
# ap_economy_system.gd
func _ready() -> void:
    SceneDayFlowController.weekend_rest_day.connect(_on_weekend_rest_day)

func _on_weekend_rest_day() -> void:
    current_energy = mini(100, current_energy + 30)
    emit_signal(&"energy_changed", current_energy, 100)
```

## QA Test Cases

- try_consume_ap(2) → emit ap_consumed(2) → SceneFlow `_game_time_minutes += 120`
- weekend_rest_day → energy +30(cap 100)

## Test Evidence

`tests/integration/ap/scene_flow_coord_test.gd`(协作 SceneFlow Story 011)

## Dependencies

- Depends on: Story 001 + SceneFlow Story 011(weekend_rest_day signal)
- Unlocks: SceneFlow Story 011 完整 game-time tick

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 5 test 函数 (`tests/integration/ap/scene_flow_coord_test.gd`)
**Test Evidence**: `tests/integration/ap/scene_flow_coord_test.gd` (~115 行 / 5 tests / GdUnit4) — BLOCKING gate PASS;含 ap_consumed(amount) emit + weekend_recover energy +30 + cap @100 + bind_scene_flow signal-present-vs-absent graceful 验证
**Code Review**: APPROVED (lean-mode autopilot inline);ap_consumed 信号 single emit owner 在 try_consume_ap (ADR-0001) + bind_scene_flow 通过 has_signal 检查 weekend_rest_day 后 connect — 完美 cross-epic seam (SceneDayFlowController.weekend_rest_day 已实现 + scene-day-flow-controller story 11 已 land);weekend_recover() 公开测试入口 + _on_weekend_rest_day(month, day) 默认参数兼容 0/2-arg signature
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. SceneFlow Story 011 已 done (autopilot 历史 batch 完成) — 跨 epic seam 直接 wire,无 graceful fallback 必要;但保留 has_signal check 防 stub flow
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: signal ap_consumed/energy_changed + bind_scene_flow() + weekend_recover() + const WEEKEND_REST_ENERGY_BONUS
