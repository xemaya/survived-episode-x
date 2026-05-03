# Story 003: F2 Early-Leave Formula + try_early_leave

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-007`
**ADR**: GDD F2 早退公式
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 早退奖励 — F2(leave_ap_saved)→ energy +N(下日)
- Forbidden: F2 反向(早退惩罚)— Anti-P1 红线

## Acceptance Criteria

- [ ] `try_early_leave(leave_ap_saved: int) -> bool` API
- [ ] F2 公式:`energy_recovery = leave_ap_saved × 10`(每剩余 1 AP 早退 → 次日 energy +10)
- [ ] emit `ap_early_leave_taken` + 次日开始 energy_changed
- [ ] 守门 current_ap > 0(还有 AP 才能"早退")

## Implementation Notes

```gdscript
signal ap_early_leave_taken

const F2_EARLY_LEAVE_ENERGY_PER_AP := 10

func try_early_leave(leave_ap_saved: int) -> bool:
    if leave_ap_saved <= 0 or current_ap < leave_ap_saved:
        return false
    var energy_recovery := leave_ap_saved * F2_EARLY_LEAVE_ENERGY_PER_AP
    current_ap = 0  # 早退 = 一次性放弃当日剩 AP
    current_energy = mini(100, current_energy + energy_recovery)
    emit_signal(&"ap_early_leave_taken")
    emit_signal(&"energy_changed", current_energy, 100)
    emit_signal(&"ap_changed", 0, max_ap_today)
    # 触发 day_ended(协作 SceneFlow Story 011)
    SceneDayFlowController.request_day_end()
    return true
```

## QA Test Cases

- 8 AP 全保留 + 早退 → energy +80 + ap = 0
- 0 AP → false

## Test Evidence

`tests/unit/ap/f2_early_leave_test.gd`

## Dependencies

- Depends on: Story 001 + SceneFlow Story 011(request_day_end 协作)
- Unlocks: 无

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 6 test 函数 (`tests/unit/ap/f2_early_leave_test.gd`)
**Test Evidence**: `tests/unit/ap/f2_early_leave_test.gd` (~115 行 / 6 tests / GdUnit4) — BLOCKING gate PASS;含 SceneFlow stub `_StubFlowWithDayEnd` 验 cross-epic seam
**Code Review**: APPROVED (lean-mode autopilot inline);F2 公式 leave_ap_saved*10 + energy mini(100, +recovery) + ap→0 早退 + ap_early_leave_taken/energy_changed/ap_changed signal 同帧 + scene_flow.request_day_end graceful no-op 当 unbound
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. SceneFlow.request_day_end 当前 cross-epic API 未实施 → graceful no-op via `has_method` check (OUT-OF-SCOPE 不动 SceneFlow);bind_scene_flow seam injected
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: try_early_leave() + signal ap_early_leave_taken + const F2_EARLY_LEAVE_ENERGY_PER_AP + bind_scene_flow() seam
