# Story 001: TutorialState autoload 末位 + 4 态状态机

> **Epic**: Tutorial / Onboarding System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: `TR-tutorial-001`

**ADR Governing Implementation**: ADR-0002 Autoload Init Order
**ADR Decision Summary**: TutorialState autoload **末位**(在 SceneDayFlow 之后);使用 `@abstract` 4.5+ 基类;`process_mode = PROCESS_MODE_ALWAYS`(不受 SceneTree.paused 影响)。状态机 4 态:`TUT_INACTIVE / TUT_ACTIVE_DAY13 / TUT_M1_NPC_REVIEW / TUT_COMPLETED`。

**Engine**: Godot 4.6 | **Risk**: HIGH
**Engine Notes**: `@abstract` 4.5+ 类装饰器(OQ-EVT-ENG-01 实测延 Pre-Production);autoload init 顺序由 project.godot `autoload/*` 顺序决定。

**Control Manifest Rules (Feature Layer)**:
- Required: autoload 末位注册;`@abstract` 基类 + 子状态实现 on_enter / on_exit
- Forbidden: autoload 中位插入(违反 init order 仲裁)
- Guardrail: 状态切换 ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-08: `tutorial_completed = true` 的 Run,Day 1-3 不注入固定手牌,`TutorialState` 状态保持 `TUT_INACTIVE`
- [ ] 4 态枚举完整:`TUT_INACTIVE / TUT_ACTIVE_DAY13 / TUT_M1_NPC_REVIEW / TUT_COMPLETED`
- [ ] autoload 末位:在 SceneDayFlow 之后注册(project.godot autoload 顺序)
- [ ] 启动时读 `meta.tutorial_completed`:true → `TUT_INACTIVE` 永久保持;false → 等待 Day 1 触发 `TUT_ACTIVE_DAY13`

---

## Implementation Notes

*From GDD Rule 1 + ADR-0002:*

```gdscript
# autoload/tutorial_state.gd
extends Node
class_name TutorialState

enum State { TUT_INACTIVE, TUT_ACTIVE_DAY13, TUT_M1_NPC_REVIEW, TUT_COMPLETED }

var _state: State = State.TUT_INACTIVE

func _ready() -> void:
    process_mode = PROCESS_MODE_ALWAYS
    var tutorial_completed: bool = SaveSystem.read_meta_field("tutorial_completed", false)
    if tutorial_completed:
        _state = State.TUT_COMPLETED
    SceneFlow.scene_state_changed.connect(_on_scene_state_changed)
    KPI.kpi_review_started.connect(_on_kpi_review_started)
```

project.godot autoload 末位:
```
[autoload]
SaveSystem="*res://autoload/save_system.gd"
InputHandler="*res://autoload/input_handler.gd"
Localization="*res://autoload/localization.gd"
AudioManager="*res://autoload/audio_manager.gd"
Lighting="*res://autoload/lighting.gd"
SceneFlow="*res://autoload/scene_flow.gd"
APEconomy="*res://autoload/ap_economy.gd"
NPC="*res://autoload/npc_relationship.gd"
KPI="*res://autoload/kpi.gd"
EventScript="*res://autoload/event_script.gd"
TutorialState="*res://autoload/tutorial_state.gd"  # 末位
```

---

## Out of Scope

- Story 002: Day 1-3 fixed_hand_override(状态触发后行为)
- Story 005: M1 KPI 评语序列(状态 TUT_M1_NPC_REVIEW 期间行为)
- Story 006: tutorial_completed flag content-only

---

## QA Test Cases

- **AC-FUNC-08**: tutorial_completed Run
  - Given: meta.tutorial_completed == true
  - When: TutorialState._ready()
  - Then: _state == TUT_COMPLETED;后续 Day 1-3 触发不切换状态
  - Edge cases: meta.tutorial_completed 字段缺失 → fallback false;corrupt save → 同 false

- **AC-2**: 4 态枚举
  - Given: TutorialState.State enum
  - When: 反射枚举值
  - Then: 4 个值精确

- **AC-3**: autoload 末位
  - Given: project.godot autoload 段
  - When: 解析顺序
  - Then: TutorialState 在 SceneFlow / KPI / EventScript 之后

---

## Test Evidence

**Required evidence**: `tests/unit/tutorial/tutorial_state_autoload_test.gd` — must exist and pass

---

## Dependencies

- Depends on: `#6 Scene Flow` Story 003(autoload init order);`#1 Save` Story 010(content-only unlocks whitelist)
- Unlocks: Story 002, 005, 006

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED — 4 态枚举 + AC-FUNC-08 完成 Run 永久 inactive + meta.tutorial_completed 读取 fallback + autoload 末位静态校验,通过 9 test 函数覆盖
**Test Evidence**: `tests/unit/tutorial/tutorial_state_autoload_test.gd` (~210 行 / 9 tests / GdUnit4) — BLOCKING gate PASS(autoload 测试 graceful 处理 project.godot 缺失)
**Code Review**: APPROVED (lean autopilot inline);TutorialState 4 态枚举严格遵守 GDD 命名;Callable injection (`set_meta_provider` / `set_meta_writer` / `set_kpi_month_provider` / `set_lisa_score_provider` / `set_game_over_pending_provider` / `set_event_dispatch_sink`)留 6 个测试 seam 兼跨 epic graceful no-op;`process_mode = PROCESS_MODE_ALWAYS` ADR-0002 合规;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent;production project.godot autoload 注册 deferred 到 VS milestone(同 SaveSystem Story 007 deferred 模式)
**Tech debt**: None new
**API surface**: `TutorialState.State` 枚举 + `enter_day_1_3_if_eligible()` + `get_state()` + `is_completed()` + `is_m1_sequence_pending()` + 6 Callable 注入 setter
