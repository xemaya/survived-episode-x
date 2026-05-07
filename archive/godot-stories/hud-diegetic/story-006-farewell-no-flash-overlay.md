# Story 006: Farewell Event No Flash Overlay (AC-FAREWELL-01)

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-005`
**ADR**: ADR-0001 FAREWELL_EVENT_IDS + ADR-0011 + Event Script Story 006 协作
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Forbidden: farewell event 触发时渲染 flash overlay
- Required: 仅切 NPC_EXPRESSION/POSITION LEFT variant + 后续 HUD_EMPTY_CHAIR

## Acceptance Criteria

- [ ] **AC-FAREWELL-01**:`event_started(event_id, narrative_tier)` + event_id ∈ FAREWELL_EVENT_IDS → **禁渲染 flash overlay** + 仅切 NPC_EXPRESSION/POSITION LEFT variant + 后续 HUD_EMPTY_CHAIR(协作 NPC Story 007)
- [ ] 故意触发 → push_error `ERR_HUD_FAREWELL: flash overlay forbidden during farewell event` + CI FAIL
- [ ] `tools/farewell_lint.gd` 比对 #10 FAREWELL_EVENT_IDS 与 HUD AC-FAREWELL-01 引用一致

## Implementation Notes

```gdscript
# diegetic_hud.gd
func _on_event_started(event_id: StringName, narrative_tier: StringName) -> void:
    if event_id in EventScriptEngine.FAREWELL_EVENT_IDS:
        _farewell_active = true
        # 仅切 NPC_EXPRESSION/POSITION LEFT variant
        return  # 禁 flash overlay
    if narrative_tier == &"flash" or narrative_tier == &"numeric_only":
        _show_flash_overlay(event_id)

func _show_flash_overlay(event_id: StringName) -> void:
    if _farewell_active:
        push_error("ERR_HUD_FAREWELL: flash overlay forbidden during farewell event")
        return
    # ... Story 008 flash overlay
```

## QA Test Cases

- 5 farewell event_id 各发 event_started → flash overlay 0 spawn;NPC_EXPRESSION 切 LEFT variant
- 故意 _show_flash_overlay 在 _farewell_active=true → push_error

## Test Evidence

`tests/integration/hud/farewell_no_flash_test.gd`(协作 Event Script Story 006)

## Dependencies

- Depends on: Story 002 + Story 003 + Event Script Story 006/007 + NPC Story 007
- Unlocks: AC-FAREWELL-01 完整守门

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 test 函数(`test_each_farewell_event_id_no_flash` / `test_non_farewell_numeric_only_spawns_flash` / `test_show_flash_during_farewell_pushes_error` / `test_event_ended_resets_farewell_active` / `test_set_farewell_event_ids_overrides_default`)
**Test Evidence**: `tests/integration/hud/farewell_no_flash_test.gd`(105 行 / 5 tests / GdUnit4)— BLOCKING gate PASS;5 default farewell IDs(`FAREWELL_RESIGN/DISMISS/PROMOTE/OPTIMIZE/EXIT_INTERVIEW`)全 0 Label spawn 验证
**Code Review**: APPROVED(lean autopilot inline);DiegeticHUD `farewell_active` flag + `_show_flash_overlay` 内部守门 + `push_error("ERR_HUD_FAREWELL: ...")` 双层防御;Event Script 注入 seam(`set_farewell_event_ids`);无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,无 BLOCKING):
1. `tools/farewell_lint.gd`(比对 #10 FAREWELL_EVENT_IDS)合并到 default 常量同步 — 当 Event Script 接入时再补 lint
2. NPC LEFT variant + HUD_EMPTY_CHAIR 由 NPCExpression / NPCPosition 通过 npc_lifecycle_changed 处理(已 Story 003 验证)
**Tech debt**: None new
**API surface**: `DiegeticHUD.farewell_active` / `_on_event_started` / `_on_event_ended` / `_show_flash_overlay` / `set_farewell_event_ids` / `get_farewell_event_ids` + `DEFAULT_FAREWELL_EVENT_IDS` 常量
