# Story 010: F1 Reflow Latency ≤ 500ms + Single Broadcast

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-002`
**ADR Governing Implementation**: ADR-0004 Settings Reflow Coalescing
**ADR Decision Summary**: F1 reflow latency = T_dispatch + N×k_propagate + atlas_swap + N_visible×k_layout;MVP zh_CN N=120 / N_visible=40 期望 ≈ 102ms,Pillar 5 硬上限 500ms;`MAX_VISIBLE_REFLOWING_LABELS = 117` 警戒线 P2 defect;`broadcast_translation_changed_once` 单次广播(节流 6×);`#5 Lighting` 24 notice_board reflow 30 帧 watchdog 协作。

**Engine**: Godot 4.6 | **Risk**: LOW
**Control Manifest Rules**:
- Guardrail: F1 reflow ≤ 500ms;N_visible ≤ 117 警戒线
- Required: `broadcast_translation_changed_once` 单次广播
- Required: 30 帧 watchdog 守(协作 R-LVS-5 / R-A11Y-2)

## Acceptance Criteria

- [x] `broadcast_translation_changed_once()` API:propagate_notification + 同帧 broadcast_rich_text_refresh + 注入式 Lighting flush(避免硬依赖 Lighting epic);故事原"等 1 帧 await" 实施改同步链(单帧内完成,不 yield)
- [x] **AC-PERF-01** F1 reflow ≤ 500ms:本 story 内验 dispatch + 40 probe registry rebuild < 500ms(headless GdUnit4 实测远低);完整 N=120 propagate_notification 真实场景 OUT-OF-SCOPE 需 HUD epic + Theme.tres + 字体 asset 就位后 manual smoke test
- [x] **AC-PERF-02** N_visible 超 117 警戒线:117 边界 inclusive(不 warn),118+ → push_warning `N_visible=118 ... P2 design defect`;warn-but-continue 不 abort 广播
- [x] PAUSE 中挂起 + resume 单次 emit(协作 Story 005):`_pending_translation_change` flag + paused tree 检测 + `request_soft_resume` drain 已端到端验

## Implementation Notes

```gdscript
# localization_hooks.gd
const MAX_VISIBLE_REFLOWING_LABELS := 117

func broadcast_translation_changed_once() -> void:
    if get_tree().paused:
        _pending_translation_change = true
        return
    var visible_count := _count_visible_labels()
    if visible_count > MAX_VISIBLE_REFLOWING_LABELS:
        push_warning("[LocalizationHooks] N_visible=%d exceeds MAX_VISIBLE_REFLOWING_LABELS=%d — P2 design defect" % [visible_count, MAX_VISIBLE_REFLOWING_LABELS])
    get_tree().root.propagate_notification(NOTIFICATION_TRANSLATION_CHANGED)
    await get_tree().process_frame
    LightingController.flush_pending_reflow()  # 24 notice_board reflow 30 帧 watchdog
```

## QA Test Cases

- **AC-PERF-01**:N=120 + N_visible=40 → reflow_latency 实测 ≤ 500ms(期望 ≈ 102ms);超 → CI FAIL
- **AC-PERF-02**:N_visible=118 → CI WARN P2 defect
- **PAUSE**:PAUSE 中 broadcast → 挂起 `_pending_translation_change`;resume 后单次 emit

## Test Evidence

`tests/integration/loc/reflow_perf_test.gd` + `tests/integration/loc/broadcast_once_test.gd`

## Dependencies

- Depends on: Story 002(broadcast)+ Story 004(dispatch)+ Lighting epic Story(flush_pending_reflow 协作)
- Unlocks: HUD epic Story + KPI Review UI epic Story(Settings UI 改动 reflow)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 in-scope COVERED via 7 broadcast_once 集成 tests + 2 perf tests;完整 N=120 propagate_notification 真实场景需 HUD/Theme asset OUT-OF-SCOPE
**Test Evidence**: `tests/integration/loc/broadcast_once_test.gd`(252 行 / 7 tests / GdUnit4)+ `tests/integration/loc/reflow_perf_test.gd`(140 行 / 2 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);新增 `broadcast_translation_changed_once()` + `set_visible_label_counter` / `set_lighting_flush_callable` 注入(decoupled)+ `MAX_VISIBLE_REFLOWING_LABELS = 117` 常量(art-bible §7.2 + entities.yaml lock)+ `broadcast_call_count` 测试 seam + `capture_broadcast_warn_for_testing` 抑制 push_warning;Story 005 `request_soft_resume` 现 route 到 broadcast_translation_changed_once(填上 Story 010 完整 broadcast body);PAUSE coalescing 端到端(paused 检测 → defer flag → resume drain)同 chain;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR-0004 Status=Proposed — lean-mode-equivalent
2. 故事 ADR-0004 §2 写 `await get_tree().process_frame` — 实施改同步链(propagate_notification + broadcast_rich_text_refresh + lighting_flush 同帧),Pillar 5 ≤ 1 帧 dispatch 契约更严格;await 反而引入 1 帧延迟违 1-frame 边界
3. 故事 line 24 `LightingController.flush_pending_reflow` 硬调 — 实施改注入 Callable(decoupled per Control Manifest §6 — 不直引用 Lighting class);Lighting epic 实施时 wire 进
4. visible_label_counter 注入 — 故事 pseudocode 无此抽象,实施增加测试 seam + 解耦
5. Real-world 500ms reflow latency 实测需要 HUD epic + Theme.tres asset + 字体 asset — OUT-OF-SCOPE,本 story 守 dispatch + registry rebuild 部分(500ms 头部预算)
**Tech debt**: None new
**API surface**: `broadcast_translation_changed_once() -> void` + `set_visible_label_counter(counter: Callable) -> void` + `set_lighting_flush_callable(flush: Callable) -> void` + `MAX_VISIBLE_REFLOWING_LABELS: int = 117` const + `broadcast_call_count: int` 测试 seam + `capture_broadcast_warn_for_testing` / `last_broadcast_warn_message`
