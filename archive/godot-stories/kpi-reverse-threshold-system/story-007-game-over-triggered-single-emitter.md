# Story 007: game_over_triggered Single Emitter Guard

> **Epic**: kpi-reverse-threshold-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-reverse-threshold-system.md` | **Requirement**: `TR-kpi-005`
**ADR**: ADR-0001 forbidden_pattern `dual_emit_game_over` + ADR-0006 Path B
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: game_over_triggered 唯一 emit 源 = #9(3 subs:#10 / #12 / #16)
- Forbidden: 任何其他系统 emit game_over_triggered(forbidden_pattern `dual_emit_game_over`)

## Acceptance Criteria

- [ ] `signal game_over_triggered(reason: StringName, month: int)` owner = #9
- [ ] `_trigger_game_over(reason)` 私有 API — 调用顺序:settlement_locked = true → SaveSystem.save_meta_sync(meta.run_ended=true) → emit game_over_triggered
- [ ] forbidden_pattern signal_ownership_lint:`grep "emit_signal.*game_over_triggered"` 全 codebase 仅 kpi_system.gd 1 文件 hit;其他 → CI FAIL

## Implementation Notes

```gdscript
signal game_over_triggered(reason: StringName, month: int)

var settlement_locked: bool = false

func _trigger_game_over(reason: StringName) -> void:
    if settlement_locked:
        return  # R-KPI-2 守门
    settlement_locked = true
    SaveSystem.save_meta_sync_run_ended(reason)
    emit_signal(&"game_over_triggered", reason, month_index)
```

```python
# tools/signal_ownership_lint.py — game_over_triggered 单 owner 守
def lint_game_over_emitters(codebase_dir: str) -> list[str]:
    errors = []
    for path in glob_gd_files(codebase_dir):
        with open(path) as f:
            content = f.read()
        if "emit_signal" in content and "game_over_triggered" in content:
            if "kpi_system.gd" not in path:
                errors.append(f"ERR_DUAL_EMIT: {path} emits game_over_triggered — only #9 KPI allowed")
    return errors
```

## QA Test Cases

- _trigger_game_over → emit signal × 1
- 故意从 #10 emit → CI FAIL(signal_ownership_lint)

## Test Evidence

`tests/unit/kpi/game_over_emit_test.gd` + `tools/signal_ownership_lint.py`

## Dependencies

- Depends on: Story 001 + Save Story 009(meta.run_ended fsync)
- Unlocks: Story 008(Path B 完整链)
