# Story 004: inject_onboarding_hint() API

> **Epic**: Tutorial / Onboarding System
> **Status**: Blocked — VS tier ADR pending
> **Layer**: Feature
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: `TR-tutorial-004`

**ADR Governing Implementation**: 待撰写 — `tutorial-day-1-3-hint-api`(VS milestone)
**ADR Decision Summary**: `inject_onboarding_hint(hint_id: String)` API 由 TutorialState own,统一封装 `kpi_prediction_hint(ONBOARDING)` emit + 防重(同 hint_id idempotent)+ AC-PERF-02 ≤100ms 守门。Story 003 直接 emit 是简化路径,本 story 是封装 API 的正式实施。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Feature Layer)**:
- Required: 统一 API 入口;防重 + 性能守门
- Forbidden: 多处 emit kpi_prediction_hint(ONBOARDING)(违反单点封装)
- Guardrail: API 调用到 overlay 显示 ≤ 100ms

---

## BLOCKED Reason

VS milestone ADR pending(同 Story 002/003)。

---

## Acceptance Criteria

- [ ] AC-PERF-02: 老油条 flash 事件从 `inject_onboarding_hint()` 调用到 overlay 显示的延迟 ≤ 100ms(继承 `#10 Rule 20` 候选池查询 < 1ms + `#14` 渲染预算)
- [ ] API 签名:`func inject_onboarding_hint(hint_id: String, npc_id: String = "old_oil_npc") -> void`
- [ ] 防重:同 hint_id 在同一 Run 内仅触发 1 次(idempotent);Story 003 直接 emit 路径迁移到本 API
- [ ] 内部 emit `kpi_prediction_hint(npc_id, HintType.ONBOARDING, hint_id)`

---

## Implementation Notes

*From GDD Rule 8(VS):*

```gdscript
# TutorialState.gd
var _emitted_hints: Dictionary = {}  # hint_id -> bool

func inject_onboarding_hint(hint_id: String, npc_id: String = "old_oil_npc") -> void:
    if _emitted_hints.get(hint_id, false): return  # idempotent
    _emitted_hints[hint_id] = true
    var t0 := Time.get_ticks_usec()
    KPI.kpi_prediction_hint.emit(npc_id, HintType.ONBOARDING, hint_id)
    # `#10 Event Script` 监听 → flash event → `#14 Card Play UI` 渲染
    # AC-PERF-02 守门:用 EventScript signals 链路追踪 100ms

# Story 003 路径迁移:
func _on_action_card_played(card_id: String, day_index: int) -> void:
    if _state != State.TUT_ACTIVE_DAY13: return
    if day_index == 1: inject_onboarding_hint("HINT_ONBOARDING_DAY1")
    elif day_index == 2 and APEconomy.last_card_cost == 2:
        inject_onboarding_hint("HINT_ONBOARDING_DAY2")
    elif day_index == 3 and "CARD_LISA_FACEOFF" in ActionCard.current_hand:
        inject_onboarding_hint("HINT_ONBOARDING_DAY3")
```

性能 harness(共享 `#14 Card Play UI` perf framework):
```gdscript
func test_inject_onboarding_hint_perf() -> void:
    var samples := []
    for i in 50:
        var t0 := Time.get_ticks_usec()
        TutorialState.inject_onboarding_hint("HINT_TEST_%d" % i)
        await wait_for_overlay_visible()  # CardPlayUI flash overlay
        var elapsed := Time.get_ticks_usec() - t0
        samples.append(elapsed)
    samples.sort()
    var p95 := samples[int(50 * 0.95)]
    assert(p95 <= 100_000, "P95 %dus > 100ms" % p95)
```

---

## Out of Scope

- Story 003: NPC hint 触发条件(本 story 仅封装 API)
- Story 010: 信号架构总集
- `#14 Card Play UI` flash overlay 渲染主体

---

## QA Test Cases

- **AC-PERF-02**: 100ms 守门
  - Given: TutorialState 状态 TUT_ACTIVE_DAY13
  - When: inject_onboarding_hint("HINT_ONBOARDING_DAY1")
  - Then: ≤ 100ms 内 `#14 Card Play UI` flash overlay 可见(profiler 50 次 P95)
  - Edge cases: 同帧多次调用 → 防重(仅第一次 emit)

- **AC-2**: idempotent
  - Given: inject_onboarding_hint("HINT_X") 已调用 1 次
  - When: 再次调用 inject_onboarding_hint("HINT_X")
  - Then: kpi_prediction_hint emit 仅 1 次(_emitted_hints["HINT_X"] == true 守门)

---

## Test Evidence

**Required evidence**: `tests/unit/tutorial/inject_onboarding_hint_api_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;Story 003(消费 emit 接口);**VS tier ADR**
- Unlocks: 无
