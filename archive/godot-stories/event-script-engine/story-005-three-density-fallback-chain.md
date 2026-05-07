# Story 005: Three-Density Effects + Dialogue Fallback Chain

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` | **Requirement**: `TR-event-003`
**ADR**: ADR-0009 三档 effects + ADR-0012 fallback 链(brief→standard→verbose,standard 必填)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 三档密度 — brief 1-2 / standard 2-4 必填 / verbose 4-8
- Required: fallback 链 — brief 缺 → standard;verbose 缺 → standard;standard 必填 assert

## Acceptance Criteria

- [ ] EventResource 三档:`effects_brief: Array[EventEffect]` / `effects_standard` / `effects_verbose`
- [ ] dialogue_keys 三档:`dialogue_keys_brief` / `dialogue_keys_standard` / `dialogue_keys_verbose: PackedStringArray`
- [ ] CI lint:`tools/event_schema_lint.py` 验证 standard 必填(空 → CI FAIL);brief 1-2 / standard 2-4 / verbose 4-8 数量范围
- [ ] runtime fallback:`select_effects_by_density(event, density) -> Array[EventEffect]`(协作 #14 Card Play UI Story)

## Implementation Notes

```gdscript
func select_effects_by_density(event: EventResource, density: StringName) -> Array[EventEffect]:
    match density:
        &"brief":
            if not event.effects_brief.is_empty(): return event.effects_brief
            return event.effects_standard  # fallback
        &"standard":
            assert(not event.effects_standard.is_empty(), "event %s missing required standard" % event.event_id)
            return event.effects_standard
        &"verbose":
            if not event.effects_verbose.is_empty(): return event.effects_verbose
            return event.effects_standard  # fallback
    return event.effects_standard
```

```python
# tools/event_schema_lint.py — standard 必填
def lint_standard_required(events_dir: str) -> list[str]:
    errors = []
    for tres in glob_tres(events_dir):
        event = parse_tres(tres)
        if not event.effects_standard or not event.dialogue_keys_standard:
            errors.append(f"ERR_STANDARD_REQUIRED: {tres} missing standard tier")
    return errors
```

## QA Test Cases

- brief 缺 → fallback standard;verbose 缺 → standard;standard 缺 → assert 失败 + lint FAIL
- 数量范围:brief 1-2 / standard 2-4 / verbose 4-8 lint 守

## Test Evidence

`tests/unit/event/density_fallback_test.gd` + `tests/unit/event/event_schema_lint_test.py`

## Dependencies

- Depends on: Story 001 + Story 003
- Unlocks: Story 008(narrative_density_changed)+ #14 Card Play UI Story

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 14 test 函数 (8 GdUnit4 + 6 Python unittest 适用)
**Test Evidence**: `tests/unit/event/density_fallback_test.gd` (~135 行 / 9 tests / GdUnit4) + `tests/unit/event/event_schema_lint_test.py` (11 tests / Python unittest — 全 PASS) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);runtime fallback `select_effects_by_density` + `select_dialogue_keys_by_density` 三档语义,brief/verbose 缺 → standard,standard 缺 → push_error + 返空 array 防崩,unknown tier 防御性 fallback;`tools/event_schema_lint.py` regex-based 解析 .tres,5 lint 函数 (standard required / density count / dialogue density count / farewell numeric_only / id uniqueness),CI < 5s 已满足 (200 events 估约 ms 级);无 BLOCKING / 无 inline fix
**Engine API Verification**: GDScript `match` + `is_empty()` + Array.duplicate() — 无 4.5+ 新 API
**Deviations** (1 项 ADVISORY):
1. ADR-0009 / ADR-0012 Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `EventScriptEngine.select_effects_by_density(event, density) -> Array` + `select_dialogue_keys_by_density(event, density) -> PackedStringArray` + `tools/event_schema_lint.py` (`lint_standard_required` / `lint_density_count` / `lint_dialogue_density_count` / `lint_farewell_numeric_only` / `lint_event_id_uniqueness` / `lint_all` / CLI main)
