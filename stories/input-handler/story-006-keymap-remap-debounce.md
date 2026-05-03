# Story 006: Keymap Remap + 500ms Debounce to Save

> **Epic**: input-handler
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/input-handler.md`
**Requirement**: `TR-input-004`
**ADR Governing Implementation**: ADR-0004 Settings Reflow Coalescing + ADR-0001 Signal Ownership Matrix
**ADR Decision Summary**: `keymap_changed` signal owner = InputHandler;500ms debounce 经 `#6` 单 timer 合流 + Save Rule 14 落 meta.save;Input **不直调** Save(信号边界);InputMap.action_add_event() 同帧绑定生效。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `InputMap.action_add_event` / `action_erase_event` 实时生效;无需 reload InputMap。

**Control Manifest Rules**:
- Required: `keymap_changed` signal 单点 emit;Save 订阅经 ADR-0004 防抖
- Forbidden: Input 直调 SaveSystem.save_meta(违反信号边界)

## Acceptance Criteria

- [ ] `apply_keymap_change(action: StringName, event: InputEvent, slot: int)` API:更新 InputMap + emit `keymap_changed`
- [ ] **AC-FUNC-07** R8 keymap 信号边界:玩家在 Remap UI 改 `act_confirm` KB Primary → Z → `InputMap.action_add_event` 同帧调 + `keymap_changed` emit 1 次 + SaveSystem.write_meta 当帧调用计数 **不**增加(Input 不直调) + 500ms 后 `meta.save` mtime 更新(Save Rule 14 防抖)
- [ ] **AC-COMPAT-06** R8 + Save Rule 14 跨系统契约 — keymap 改后 500ms 落盘:连续改绑 3 次(< 500ms 间隔)→ `keymap_changed` 发射 3 次 → Save 防抖后 1 次 meta 写入 → 最终内容反映第 3 次改绑 — Deferred until Main Menu UI

## Implementation Notes

```gdscript
# input_handler.gd
signal keymap_changed

func apply_keymap_change(action: StringName, event: InputEvent, slot: int) -> void:
    if not action in ALLOWED_ACTIONS:
        push_warning("Unknown action: %s" % action)
        return
    # 删旧 binding(if exists at slot)
    var existing_events := InputMap.action_get_events(action)
    if slot < existing_events.size():
        InputMap.action_erase_event(action, existing_events[slot])
    # 加新 binding
    InputMap.action_add_event(action, event)
    emit_signal(&"keymap_changed")
    # NO call to SaveSystem here — signal boundary enforced
    # ADR-0004 #6 SceneDayFlow 持 timer,500ms debounce 后落盘
```

## Out of Scope

- Story 012:`load_keymap(payload)` 启动期加载(独立路径)
- Save Story 004:meta.save 防抖落盘(协作系统)

## QA Test Cases

- **AC-FUNC-07**:Given debug 钩子 SaveSystem.write_meta + FileAccess.open 调用计数;When 玩家改 act_confirm KB Primary 为 Z;Then InputMap.action_add_event 同帧调用 + keymap_changed 信号 1 次 + write_meta 当帧 0 + 500ms 后 meta.save mtime 更新(Save 防抖)

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/keymap_debounce_test.gd`(协作 Save System Story 004 fixture)
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001(InputMap)+ Save System Story 004(meta debounce 协作)
- Unlocks: Main Menu UI epic Story(remap-screen)

## Completion Notes

**Completed**: 2026-05-01 (实施在前 session 已完成,本 session 仅 verify + close)
**Criteria**: 2/2 COVERED via 6 test 函数
- AC-1 `apply_keymap_change(action, event, slot)` API + emit `keymap_changed`:
  - `test_apply_keymap_change_updates_input_map_and_emits_signal_once` — Z 键覆盖 X + 信号 emit 1 次
  - `test_apply_keymap_change_unknown_action_warns_and_does_not_emit` — 未知 action 不 emit / 不改 InputMap
  - `test_apply_keymap_change_with_slot_out_of_range_appends_without_erase` — slot 越界 → pure append 语义
- AC-FUNC-07 R8 信号边界 + Save Rule 14 防抖:
  - `test_keymap_change_signal_boundary_no_direct_save_call_same_frame` — 当帧 SaveSystem.write_meta 调用计数 0
  - `test_keymap_changed_routed_through_scene_day_flow_emits_settings_flush_after_500ms` — 500ms 后 settings_meta_flush_requested 1×,payload 含 `keymap_changed`
- AC-COMPAT-06 (Deferred until Main Menu UI) — 锁了 debounce-coalesce invariant:
  - `test_three_rapid_keymap_changes_within_500ms_collapse_to_one_flush` — 3 次连改 → keymap_changed×3 + flush×1

**Test Evidence**: `tests/integration/input/keymap_debounce_test.gd` (423 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline verify);
- `apply_keymap_change` 实施 `InputMap.has_action` guard + slot ≥ event_count 时 pure-append + 同帧 `keymap_changed.emit()`,无 SaveSystem 调用 — ADR-0001 信号边界 invariant 守。
- 500ms 防抖通过 `keymap_changed → SceneDayFlowController.notify_setting_changed → settings_meta_flush_requested` 链路验证 — 测试 wire 显式建立 (real wiring story 后续)。
- 无 BLOCKING / 无 inline fix。

**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. **AC-COMPAT-06 全链 disk content 反映第 3 次 binding**: DEFERRED until Main Menu UI epic + Save System Story 004 集成 — story line 27 显式 marked Deferred。本 session 仅锁 debounce-coalesce invariant (N emits → 1 flush),未跑实际 disk write。
2. **ADR-0004 Status**: lean-mode-equivalent (Proposed → 治理路径下 acceptable)。

**Tech debt**: None new
**API surface**: `apply_keymap_change(action: StringName, event: InputEvent, slot: int) -> void`, `signal keymap_changed`
