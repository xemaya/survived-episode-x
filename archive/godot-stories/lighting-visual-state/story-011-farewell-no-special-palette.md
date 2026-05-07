# Story 011: Farewell Event No Special Palette + accumulation_event Single Owner Guard

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-012`
**ADR**: ADR-0001 FAREWELL_EVENT_IDS + ADR-0005 accumulation_event 单 owner
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Forbidden: farewell event 触发时启动 farewell-specific palette swap Tween
- Forbidden: accumulation_event 由其他系统 emit(forbidden_pattern `accumulation_event_multiple_emitters`)

## Acceptance Criteria

- [ ] **AC-FAREWELL-01** (`#10 Rule 23` FAREWELL_EVENT_IDS 禁特殊 palette 契约):AudioManager READY + debug 钩子拦截非 sub-mode 切换源对 CanvasModulate.color Tween 启动 → `event_started(event_id, narrative_tier)` 且 `event_id ∈ FAREWELL_EVENT_IDS` → 不启动任何 farewell-specific palette swap;若发生 → push_error `ERR_LVS_FAREWELL: special palette forbidden during farewell event` + CI FAIL
- [ ] **AC-FAREWELL-02** (`#5` accumulation_event 单 owner 契约,ADR-0005):LightingManager 持 4 累积维度 state → `npc_left_company(npc_id, reason)` + `reason ∈ [FAREWELL/DISMISSAL/PROMOTED_LEAVE/OPTIMIZED_OUT]` → `accumulation_event(sticky_note_count, +1)` + `accumulation_event(npc_empty_chairs, +1)` 同帧 emit;`accumulation_event` 不允许 `#6 / #13 / 任何系统` emit(debug 钩子全程监控,违反 → CI FAIL);`#13 HUD` 仅订阅 visual variant 响应,不回调写 `#5` state

## Implementation Notes

```gdscript
func _on_event_started(event_id: StringName, _tier: StringName) -> void:
    if event_id in EventScriptEngine.FAREWELL_EVENT_IDS:
        _farewell_active = true
        return  # 禁启动特殊 palette;continue current sub-mode

func apply_visual_state(sub_mode: StringName) -> void:
    if _farewell_active:
        push_error("ERR_LVS_FAREWELL: special palette forbidden during farewell event")
        return
    # ... 正常 palette swap
```

```python
# tools/signal_ownership_lint.py — accumulation_event 单 owner 守
def lint_accumulation_emitters(codebase_dir: str) -> list[str]:
    errors = []
    for path in glob_gd_files(codebase_dir):
        with open(path) as f:
            content = f.read()
        if "emit_signal(&\"accumulation_event\"" in content or "accumulation_event.emit" in content:
            if "lighting_controller.gd" not in path:
                errors.append(f"ERR_ACCUMULATION_OWNER: {path} emits accumulation_event — only #5 Lighting allowed")
    return errors
```

## QA Test Cases

- AC-FAREWELL-01:5 farewell event_id 各发 `event_started` → 不启动特殊 palette;故意调 → push_error
- AC-FAREWELL-02:`npc_left_company` 4 reason 各发 → emit 2 次 accumulation_event;故意从 #6/#13 emit → CI FAIL

## Test Evidence

`tests/integration/lighting/farewell_no_palette_test.gd` + `tools/signal_ownership_lint.py` accumulation_event check

## Dependencies

- Depends on: Story 003 + Story 004 + Event Script Story(FAREWELL_EVENT_IDS)
- Unlocks: HUD/Audio/Recap farewell 守门 stories

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: AC-FAREWELL-01 + AC-FAREWELL-02 = 2/2 COVERED via 4 test 函数(farewell_active 拒绝异 palette / event_ended 释放 guard / npc_left_company 同帧 2 emit / `signal_ownership_lint --signal accumulation_event` PASS)
**Test Evidence**: `tests/integration/lighting/farewell_no_palette_test.gd`(108 行 / 4 tests / GdUnit4)+ `tools/signal_ownership_lint.py` registry 注册 `accumulation_event → lighting_controller.gd` 单 owner — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);`apply_visual_state` 顶部 `farewell_active` guard 提前 push_error;`set_farewell_event_ids(ids)` 暴露 Event Script 注入入口,默认 `DEFAULT_FAREWELL_EVENT_IDS` 列出 5 farewell event_id placeholder;同帧 2 emit 通过顺序 `accumulation_event.emit(STICKY)` + `accumulation_event.emit(EMPTY_CHAIRS)` 保证;无 BLOCKING
**Engine API Verification**: signal `.emit()` 同步分发 4.0+ 稳定(同帧 listener 顺序处理);`Array.duplicate()` 4.0+
**Deviations**(2 项 ADVISORY):
1. `FAREWELL_EVENT_IDS` 默认值 placeholder — Event Script epic 真值通过 `set_farewell_event_ids` 注入(cross-epic OUT-OF-SCOPE 不动 Event Script)
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `farewell_active` 公有读 + `set_farewell_event_ids(ids)` + `_on_event_started(event_id, tier)` + `_on_event_ended(event_id)` + `DEFAULT_FAREWELL_EVENT_IDS` const + `signal_ownership_lint.py` 通用 signal owner registry
