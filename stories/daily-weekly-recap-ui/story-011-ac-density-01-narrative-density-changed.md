# Story 011: AC-DENSITY-01 narrative_density_changed 切档 + fallback 链

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-004` + AC-DENSITY-01 + I-9

**ADR Governing Implementation**: ADR-0001 + ADR-0004 + ADR-0012(B-DEP-1 守门)
**ADR Decision Summary**: `#15` 订阅 `#17 Settings narrative_density_changed(tier)` 信号;EVENT_ACTIVE 态(若适用)当前事件用旧密度完成,新密度从下次 `event_started` / `daily_recap_started` 起生效(per `#14` `_select_*_by_density()` fallback 链 + `#10 Rule 25` 延后语义);周报 summary 三档 fallback 链 brief → standard → verbose(standard 必填);PAUSE 中改 locale → resume 后单次 reflow(ADR-0004)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `narrative_density_changed` signal owner = `#17 Main Menu` Story 006(单点 emit)。

**Control Manifest Rules (Presentation)**:
- Required: 共享 `#14` `_select_*_by_density()` fallback 链
- Forbidden: 切档立即生效(必须等下次 `daily_recap_started`)
- Guardrail: 切档延后单次 reflow ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-DENSITY-01: Daily Recap 屏渲染中,`narrative_density_changed(tier)` 信号到达,EVENT_ACTIVE 态(若适用)当前事件用旧密度完成,新密度从下次 `event_started` / `daily_recap_started` 起生效;周报 summary 三档 fallback 链 brief → standard → verbose(standard 必填)
- [ ] 共享 `#14` `_select_summary_by_density(event, density)` 函数 — brief 1 行 / standard 3 行 / verbose 6 行 per event
- [ ] PAUSE 中改 locale → resume 后单次 reflow(ADR-0004 协议)
- [ ] `_pending_density_for_next_event` 变量(per `#10 Rule 25` 同步)— 切档延后到下次 daily_recap_started

---

## Implementation Notes

*From GDD I-9 + AC-DENSITY-01(revised):*

```gdscript
var _current_density: NarrativeDensity = NarrativeDensity.STANDARD
var _pending_density: Variant = null  # null when no pending

func _ready() -> void:
    SettingsScreen.narrative_density_changed.connect(_on_narrative_density_changed)

func _on_narrative_density_changed(tier: NarrativeDensity) -> void:
    if SceneTree.paused or _current_state == RECAP_ACTIVE:
        # PAUSE 中或正在渲染中 → 推 pending,resume 时再生效
        _pending_density = tier
        return
    _apply_density(tier)

func _apply_density(tier: NarrativeDensity) -> void:
    _current_density = tier
    _pending_density = null
    # 下次 daily_recap_started 时触发新密度生效

func _enter_recap(ctx: Dictionary) -> void:
    # 切档延后:进入 recap 时检查 pending
    if _pending_density != null:
        _apply_density(_pending_density)
    _render_recap_with_density(_current_density)

# 共享 #14 fallback 链
func _select_summary_by_density(event: Dictionary, density: NarrativeDensity) -> String:
    # standard 必填,brief / verbose fallback 到 standard
    var keys_by_density := {
        NarrativeDensity.BRIEF: "EVENT.%s.SUMMARY_BRIEF" % event.event_id,
        NarrativeDensity.STANDARD: "EVENT.%s.SUMMARY_STANDARD" % event.event_id,
        NarrativeDensity.VERBOSE: "EVENT.%s.SUMMARY_VERBOSE" % event.event_id,
    }
    var preferred_key: String = keys_by_density[density]
    if TranslationServer.has_key(preferred_key):
        return tr(preferred_key)
    # fallback 到 standard
    var fallback_key: String = keys_by_density[NarrativeDensity.STANDARD]
    return tr(fallback_key)  # standard 必填,本身缺失视为 csv bug
```

注:farewell event 渲染走 Story 010(强制 numeric_only),不走 fallback 链。

---

## Out of Scope

- Story 010: farewell event 强制 numeric_only(优先级高于密度)
- `#17 Main Menu` Story 006(narrative_density_changed signal owner)
- `#14 Card Play UI` Story 003(密度 fallback 主消费 layer)
- `#10 Event Script` Story 008(narrative_density_changed_deferred)

---

## QA Test Cases

- **AC-DENSITY-01**: 切档延后
  - Given: _current_density == VERBOSE,Recap 正在渲染
  - When: emit narrative_density_changed(BRIEF)
  - Then: _pending_density == BRIEF;当前 Recap 仍 verbose 渲染;下次进入 Recap 时切 BRIEF
  - Edge cases: PAUSE 中改密度 → 同样推 pending;resume 后下次 Recap 进入时生效

- **AC-2**: fallback 链
  - Given: csv 缺 `EVENT.X.SUMMARY_BRIEF` key,但 `SUMMARY_STANDARD` 存在
  - When: `_select_summary_by_density(X, BRIEF)`
  - Then: 返回 `tr("EVENT.X.SUMMARY_STANDARD")`(fallback 到 standard)
  - Edge cases: standard 也缺 → tr("EVENT.X.SUMMARY_STANDARD") 走 P5 Loc raw key 兜底

- **AC-3**: 周报 summary 三档行数
  - Given: density == BRIEF / STANDARD / VERBOSE
  - When: 渲染周报 summary
  - Then: BRIEF 1 行 / STANDARD 3 行 / VERBOSE 6 行 per event

---

## Test Evidence

**Required evidence**: `tests/integration/recap_ui/ac_density_01_narrative_density_changed_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 004(事件列表);`#17 Main Menu` Story 006(narrative_density_changed signal);`#14 Card Play UI` Story 003(_select_*_by_density framework);`#10 Event Script` Story 008(narrative_density_changed deferred)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 ACs COVERED via 7 test 函数 (ac_density_01_narrative_density_changed_test.gd)
**Test Evidence**: `tests/integration/recap/ac_density_01_narrative_density_changed_test.gd` (7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED;`handle_narrative_density_changed(tier)` 检查 `is_paused_provider` + `is_recap_active` — 真则推 `pending_density`,假则立即 `_apply_density()`;`enter_recap()` 在进入 recap 前 consume pending — `daily_recap_started` 时机生效 (per #10 Rule 25);`_select_event_text_by_density()` fallback chain — preferred 缺失时 `has_translation_callable` 返回 false 走 STANDARD 兜底 (`fallback_to_standard_count` 计数);farewell event 优先级 > 密度 (Story 010);`DENSITY_LINE_COUNT` 三档 [BRIEF=1 / STANDARD=3 / VERBOSE=6] const 测
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0001 / ADR-0004 / ADR-0012 Status=Proposed — lean-mode-equivalent
2. `narrative_density_changed` signal 由 `#17 Main Menu` Story 006 own (cross-epic) — Main Menu 已完成,signal 落地;controller 通过 `handle_narrative_density_changed(tier)` 公共入口接收 (production wiring `Settings.narrative_density_changed.connect(controller.handle_narrative_density_changed)`)
3. event-script-engine 并行跑中 — `narrative_density_changed_deferred` (#10 Story 008) graceful no-op:本 controller 用 `has_translation_callable` Callable seam (而非直接 TranslationServer.has_translation) — production wiring 注入即可;无 has_signal check 兜底需求 (信号订阅由 `.tscn` Phase 4 wiring 处理)
**Tech debt**: None new
**API surface**: `handle_narrative_density_changed(tier: int)` + `enter_recap()` / `exit_recap()` + `current_density` / `pending_density` / `fallback_to_standard_count` introspection + 2 signals (`density_change_deferred(tier)` / `density_change_applied(tier)`) + `is_paused_provider` / `has_translation_callable` Callable seams
