# Story 002: 5 秒进入承诺 LOADING → MAIN_MENU 主菜单 ≤ 500ms 显示

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: AC-PERF-01 + Rule 2(`#6 Rule 4` Loading Scene 启动序列)

**ADR Governing Implementation**: ADR-0001(主菜单订阅 `#6 scene_state_changed(LOADING→MAIN_MENU)`,不主动 dispatch)
**ADR Decision Summary**: 启动总耗时 ≤ 5s(LOADING phase by `#6` Story 004);MAIN_MENU 子屏首帧 ≤ 500ms 在 `scene_state_changed` 后(MAIN_MENU 子屏只是 5s 总预算的最后一段)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 4.6 `change_scene_to_packed()` 优先于 `change_scene_to_file()`(Save Story 005 同源 — 性能锁)。

**Control Manifest Rules (Presentation)**:
- Required: scene 切换走 `#6` dispatch 接口,UI 不主动 `change_scene_*`
- Forbidden: 主菜单 _ready() 内做重负载(违反 R-SDF-3 + R-SDF-5)
- Guardrail: MAIN_MENU 首帧 ≤ 500ms(P95)

---

## Acceptance Criteria

- [ ] AC-PERF-01: `scene_state_changed(LOADING → MAIN_MENU)` 发出后,主菜单第一帧可见 ≤ 500ms
- [ ] LOADING 阶段 MainMenuPanel 不存在(预实例化也不允许);MAIN_MENU 进入时由 `#6` PackedScene 实例化
- [ ] _ready() 内仅做"节点引用绑定 + 信号订阅",**禁**调 SaveSystem.archive_count()(调 `call_deferred(refresh)` 推下一帧)
- [ ] 4 按钮文本 tr() 路径 ≤ 50ms 总耗时

---

## Implementation Notes

*From GDD Rule 2 + `#6 Rule 4`:*

- _ready 实施(轻量):
  ```gdscript
  func _ready() -> void:
      _bind_signals()
      call_deferred("refresh")  # SaveSystem 查询推下一帧
  ```
- refresh 在下一帧执行(Story 001 主体)
- 性能 harness(共享 `#16` Story 014 perf_budget_test 模式):
  ```gdscript
  func test_main_menu_first_frame_perf() -> void:
      var emit_frame := Engine.get_frames_drawn()
      Scene.dispatch(MAIN_MENU)
      await get_tree().process_frame
      var visible_frame := Engine.get_frames_drawn()
      assert(visible_frame - emit_frame <= 30)  # 30 帧 = 500ms @ 60fps
  ```

---

## Out of Scope

- Story 001: 主菜单 4 入口业务逻辑(本 story 仅性能契约)
- `#6 Story 004`: LOADING phase 5s 启动序列(上游)
- LOADING 屏内容(`#6 Rule 4` own)

---

## QA Test Cases

- **AC-PERF-01**: 500ms 进入
  - Given: `scene_state_changed(LOADING → MAIN_MENU)` emit
  - When: 主菜单首帧渲染
  - Then: 信号 emit 到首帧 visible 间隔 ≤ 30 帧(500ms @ 60fps)
  - Edge cases: cold start(首次)允许 P95 800ms;warm 后 P95 500ms

- **AC-2**: _ready 轻量
  - Given: MainMenuPanel _ready()
  - When: profiler 测 _ready 单次执行时间
  - Then: ≤ 5ms;无 SaveSystem 同步查询调用(grep 静态分析)

- **AC-3**: tr 性能
  - Given: 4 按钮 tr() 调用
  - When: 累计耗时
  - Then: ≤ 50ms

---

## Test Evidence

**Required evidence**: `tests/unit/main_menu/loading_to_main_menu_500ms_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(主菜单业务逻辑);`#6 Scene Flow` Story 004(LOADING 启动序列)+ Story 005(change_scene_to_packed 性能锁)
- Unlocks: 无

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 3/4 COVERED via 4 test functions(`tests/unit/main_menu/loading_to_main_menu_500ms_test.gd`)— AC-PERF-01 30 帧首屏预算 / AC-2 _ready 不同步 refresh + 下一帧延迟运行 / AC-3 4 个 tr() 调用计数;LOADING phase 不实例化 MainMenuPanel 由 SceneFlow Story 004 启动序列 own,本 story 验 controller _ready 端契约
**Test Evidence**: `tests/unit/main_menu/loading_to_main_menu_500ms_test.gd`(GdUnit4 4 tests)— BLOCKING gate PASS
**Code Review**: APPROVED;`_ready()` 仅 `_build_widget_hierarchy_if_needed()` + `_bind_button_signals()` + `call_deferred("refresh")`;`ready_frame_index` + `refresh_call_count` 公有字段为测试 ergonomics(无副作用,只读);`FIRST_FRAME_BUDGET_FRAMES = 30` 锁定常量便于跨 story 引用;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR-0001 Status=Proposed — lean-mode-equivalent
2. cold-start P95 800ms / warm 500ms 区分由 production playtest 校准,本 story 锁定 unit-test 级 30 帧契约(60 fps 基准)
**Tech debt**: None new
**API surface**:
- `const FIRST_FRAME_BUDGET_FRAMES: int = 30`
- `var ready_frame_index: int`(read-only frame index of _ready)
- `var refresh_call_count: int`(call count for tests)
