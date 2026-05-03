# Story 007: keymap remap 正流程 + cancel 回滚 + 无绑定红色标记

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: AC-FUNC-10/11 + AC-ROBUST-04

**ADR Governing Implementation**: ADR-0001(keymap_changed signal owner = #2 Input Handler;#17 仅 UI 触发)
**ADR Decision Summary**: keymap remap 子屏走 `#2 InputHandler.start_remap(action_name)` API;remap 完成 emit `keymap_changed` → Story 005 合流落盘;cancel(ESC)→ InputMap 恢复原键 + `keymap_changed` 不 emit;空绑定 → 红色"未绑定"标记 + 游戏继续(R-INP-3 守门)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `InputMap.action_get_events()` / `action_add_event()` 4.6 已稳;`InputEvent` 序列化 4.6 标准。

**Control Manifest Rules (Presentation)**:
- Required: remap 经 `#2 InputHandler` API,UI 不直接改 `InputMap`
- Forbidden: remap 期间允许其他玩家输入(必经 modal lock)
- Guardrail: remap 子屏首帧 ≤ 4ms

---

## Acceptance Criteria

- [ ] AC-FUNC-10: remap 子屏打开 → 点 `act_confirm` 行 → 按 `F` 键确认 → `InputMap.action_get_events("act_confirm")` 包含 `F` key + `keymap_changed` 已 emit
- [ ] AC-FUNC-11: 进入等待按键状态 → `act_cancel`(ESC)→ `InputMap` 恢复原键(在等待按键之前的快照),`keymap_changed` **未** emit
- [ ] AC-ROBUST-04: 玩家 remap 使某 act_* 无绑定 → 该行红色"未绑定"标记;游戏功能正常继续
- [ ] remap 期间 modal lock(其他输入被 InputHandler MODAL_LOCKED 屏蔽)

---

## Implementation Notes

*From GDD Rule 4(键位 remap)+ AC-FUNC-10/11:*

- 节点树:
  ```
  RemapScreen (Control)
  └─ ScrollContainer
     └─ VBoxContainer
        └─ RemapRow (Container × N for each act_*)
           ├─ ActionLabel (Label "确认")
           ├─ KeyBindingLabel (Label "F" / "[未绑定]")
           └─ ChangeButton (Button "更改")
  ```
- remap 流程:
  ```gdscript
  func _on_change_button_pressed(action_name: String) -> void:
      var snapshot := InputMap.action_get_events(action_name).duplicate()
      InputHandler.push_modal_lock(&"remap_modal")
      _show_waiting_overlay()  # "请按键..."
      var result = await InputHandler.start_remap(action_name)  # awaits next InputEvent
      if result.cancelled:
          # ESC pressed or timeout
          InputMap.action_erase_events(action_name)
          for ev in snapshot: InputMap.action_add_event(action_name, ev)  # 回滚
          # 不 emit keymap_changed
      else:
          # 新 key 已写入 InputMap by InputHandler.start_remap
          InputHandler.keymap_changed.emit(action_name, result.event)
          SceneFlow.notify_settings_changed("keymap_%s" % action_name, result.event)
      _hide_waiting_overlay()
      InputHandler.pop_modal_lock(&"remap_modal")
      _refresh_row(action_name)
  ```
- 红色无绑定标记:
  ```gdscript
  func _refresh_row(action_name: String) -> void:
      var events := InputMap.action_get_events(action_name)
      if events.is_empty():
          key_label.text = tr("REMAP.UNBOUND_LABEL")
          key_label.modulate = Color(0.9, 0.3, 0.3)  # 红色
      else:
          key_label.text = events[0].as_text()
          key_label.modulate = Color.WHITE
  ```

---

## Out of Scope

- `#2 Input Handler` Story 006(keymap remap debounce 实施)
- Story 005: 6 信号合流(本 story 通过 notify_settings_changed 复用)

---

## QA Test Cases

- **AC-FUNC-10**: remap 正流程
  - Given: act_confirm 当前绑定 SPACE
  - When: 点更改 → 按 F → 等待 InputHandler.start_remap 完成
  - Then: InputMap.action_get_events("act_confirm") 含 F key AND keymap_changed emit 1 次
  - Edge cases: 重复按 F(同键)→ idempotent;按修饰键(Shift+F)→ 复合事件保存

- **AC-FUNC-11**: cancel 回滚
  - Given: act_confirm 原绑定 [SPACE],remap 子屏等待按键
  - When: 按 ESC(act_cancel)
  - Then: InputMap 恢复 [SPACE] + keymap_changed 未 emit(0 次)
  - Edge cases: ESC 期间另一键先到达 → ESC 优先(InputHandler 内部仲裁)

- **AC-ROBUST-04**: 空绑定红色
  - Given: 玩家 remap act_focus_left 为某键 → 然后 remap 同键给 act_focus_right(冲突)
  - When: 冲突解决策略 = erase 旧 binding(act_focus_left → 空)
  - Then: act_focus_left row 显示红色"未绑定"标记 + 游戏正常运行(可继续 D-Pad,左移失效但不崩溃)

---

## Test Evidence

**Required evidence**: `tests/integration/main_menu/keymap_remap_cancel_rollback_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 004(Settings KeymapGroup 入口);Story 005(notify_settings_changed 合流入口);`#2 Input Handler` Story 005(modal lock)+ Story 006(keymap remap API)
- Unlocks: 无

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 test 函数(`tests/integration/main_menu/keymap_remap_cancel_rollback_test.gd`)— AC-FUNC-10 success path 改写 InputMap + emit_keymap_changed + notify_setting_changed prefix `keymap_*` / AC-FUNC-11 cancel path snapshot 回滚 + 0 emit + 0 notify / AC-ROBUST-04 无绑定红色 marker(modulate 0.9, 0.3, 0.3)+ UNBOUND 文案 / Modal lock acquire(blocking=true)+ release 配对
**Test Evidence**: `tests/integration/main_menu/keymap_remap_cancel_rollback_test.gd`(GdUnit4 5 tests,真实 InputMap)— BLOCKING gate PASS
**Code Review**: APPROVED;`handle_remap_request` 流程 6 步(snapshot → modal lock → start_remap await → erase + add OR rollback → release modal → emit result);snapshot 用 `event.duplicate()` 防引用泄露;empty event 防御性回滚(避免空 InputMap);`resolve_row_state` 拆分纯渲染逻辑供 unit 测试无 .tscn 即可断言;`COLOR_UNBOUND = Color(0.9, 0.3, 0.3)` 锁定守门;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0001 Status=Proposed — lean-mode-equivalent
2. `InputHandler.start_remap` API 未在 input-handler epic 13 stories 中实施(仅 register_skippable / modal lock / dual_focus);本 story 通过 `start_remap_callable` DI seam 占位,production wiring 时 connect 真实 API
3. `keymap_changed` signal 真实 owner = `#2 InputHandler`(ADR-0001),本 controller 通过 `emit_keymap_changed_callable` seam 调用 InputHandler.keymap_changed.emit — production wiring 接 InputHandler.keymap_changed
**Tech debt**: None new
**API surface**:
- `class_name RemapController extends Control`
- `signal remap_result_dispatched(action_name: StringName, applied: bool)`
- `const COLOR_UNBOUND` / `COLOR_BOUND`
- `func handle_remap_request(action_name: StringName) -> bool`
- `func resolve_row_state(action_name: StringName) -> Dictionary`
- 6 个 Callable DI seams(start_remap / acquire/release_modal_lock / emit_keymap_changed / notify_setting_changed / tr)
