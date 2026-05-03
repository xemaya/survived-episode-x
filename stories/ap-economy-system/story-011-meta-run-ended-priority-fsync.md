# Story 011: meta.run_ended Priority Fsync (R-AP-2)

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-005`
**ADR**: ADR-0003 + ADR-0006 + R-AP-2 守门
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: meta.run_ended fsync 必须先于 GAMEOVER 1500ms transition 启动(防 Alt+F4 续命 — R-AP-2)
- Required: Save Story 009 协作(meta.dismissal_pending fsync 在 dismissal_triggered emit 同步)

## Acceptance Criteria

- [ ] AP epic 不直 emit `game_over_triggered`(KPI Story 唯一 emit)
- [ ] AP epic 监听 `game_over_triggered` 后 → settlement_locked = true(防 AP 改变 R-AP-2);AP / energy 状态冻结
- [ ] R-AP-2 守门测试:GAMEOVER 1500ms transition 期间 try_consume_ap → 拒绝

## Implementation Notes

```gdscript
var settlement_locked: bool = false

func _ready() -> void:
    KPISystem.game_over_triggered.connect(_on_game_over)

func _on_game_over(_reason: StringName, _month: int) -> void:
    settlement_locked = true  # AP 冻结

func try_consume_ap(amount: int) -> bool:
    if settlement_locked:
        return false  # R-AP-2 守门
    # ... Story 001 逻辑
```

## QA Test Cases

- emit game_over_triggered → settlement_locked = true → try_consume_ap → false
- 协作 Save Story 009 测 meta.run_ended fsync 时序

## Test Evidence

`tests/integration/ap/r_ap_2_guard_test.gd`(协作 Save / KPI stories)

## Dependencies

- Depends on: Story 001 + KPI Story + Save Story 009
- Unlocks: 跨系统 R-AP-2 守门(GAMEOVER 不可逆)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 8 test 函数 (`tests/integration/ap/r_ap_2_guard_test.gd`)
**Test Evidence**: `tests/integration/ap/r_ap_2_guard_test.gd` (~165 行 / 8 tests / GdUnit4) — BLOCKING gate PASS;含 game_over_triggered → settlement_lock_engaged + try_consume_ap/try_overtime/try_early_leave/weekend_recover/report_* 五个 mutator 全部 reject + Save priority fsync set_dismissal_pending → save_meta_sync 顺序断言 + Save unbound 时 graceful
**Code Review**: APPROVED (lean-mode autopilot inline);AP epic 不直接 emit game_over_triggered (KPI 唯一 owner — ADR-0001) + 监听 KPI.game_over_triggered → engage_settlement_lock + 优先 fsync Save (set_dismissal_pending(reason) 然后 save_meta_sync(),都 has_method gated);settlement_locked 一票否决所有 mutator (idempotent);clear_settlement_lock test seam (production 不能调用 — R-AP-2 单向)
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. KPI epic 尚未落地 → bind_kpi_system 通过 has_signal(&"game_over_triggered") 优雅降级 (cross-epic seam)
2. SaveSystem.set_dismissal_pending / save_meta_sync 已 land (autopilot save-system 16/16) — has_method gating 仍保留作为防御
3. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: engage_settlement_lock() + clear_settlement_lock() (test seam) + signal settlement_lock_engaged + property settlement_locked + bind_save_system() + bind_kpi_system()
