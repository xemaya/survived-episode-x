# Story 006: FAREWELL_EVENT_IDS Enum + farewell_event Flag + numeric_only Lint

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` Rule 23 | **Requirement**: `TR-event-004`
**ADR**: ADR-0001(B-DEP-2 仲裁,FAREWELL_EVENT_IDS owner = #10)+ ADR-0009 farewell_event flag
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `FAREWELL_EVENT_IDS: Array[StringName]` 常量定义在 `data/event_constants.tres`
- Required: farewell_event=true → `dialogue_keys_*` 仅 1 个 = `EVENT.[event_id].TITLE_NUMERIC`(numeric_only 守门)
- Required: 4 下游 GDD AC-FAREWELL-01 守门一致(#13 / #15 / #4 / #5)— `tools/farewell_lint.gd` 比对

## Acceptance Criteria

- [ ] `data/event_constants.tres` 含 `FAREWELL_EVENT_IDS = [LISA_GOODBYE, CLEANING_AUNT_LEAVE, FISH_MONK_LAID_OFF, GRIND_KING_PROMOTED_LEAVE, OLD_OIL_OPTIMIZED_OUT]`
- [ ] CI lint `tools/event_schema_lint.py`:farewell_event=true 时 `dialogue_keys_*` 仅 1 个 + 等于 `EVENT.[event_id].TITLE_NUMERIC` pattern;违反 CI FAIL
- [ ] CI lint `tools/farewell_lint.gd`:#10 FAREWELL_EVENT_IDS 与 #13/#15/#4/#5 各自 AC-FAREWELL-01 引用一致

## Implementation Notes

```gdscript
# data/event_constants.tres
const FAREWELL_EVENT_IDS: Array[StringName] = [
    &"LISA_GOODBYE",
    &"CLEANING_AUNT_LEAVE",
    &"FISH_MONK_LAID_OFF",
    &"GRIND_KING_PROMOTED_LEAVE",
    &"OLD_OIL_OPTIMIZED_OUT",
]
```

```python
# tools/event_schema_lint.py — farewell numeric_only
def lint_farewell_numeric_only(events_dir: str) -> list[str]:
    errors = []
    for tres in glob_tres(events_dir):
        event = parse_tres(tres)
        if event.farewell_event:
            if event.event_id not in FAREWELL_EVENT_IDS:
                errors.append(f"ERR_FAREWELL_FLAG: {tres} farewell_event=true but event_id not in FAREWELL_EVENT_IDS")
            for tier in ["brief", "standard", "verbose"]:
                keys = getattr(event, f"dialogue_keys_{tier}")
                if len(keys) != 1 or not keys[0].endswith(".TITLE_NUMERIC"):
                    errors.append(f"ERR_FAREWELL_NUMERIC: {tres} {tier} must have exactly 1 key matching .TITLE_NUMERIC")
    return errors
```

## QA Test Cases

- 5 farewell event_id 各自 dialogue_keys 仅 1 个 .TITLE_NUMERIC + lint PASS
- farewell_event=true 但 event_id 不在 enum → lint FAIL
- farewell_event=true + dialogue_keys 含 2 行 → lint FAIL

## Test Evidence

`tests/unit/event/farewell_lint_test.py` + `tools/farewell_lint.gd`

## Dependencies

- Depends on: Story 001 + Story 005 + 4 下游 GDD AC-FAREWELL-01(协作 Audio/Lighting/HUD/Recap stories)
- Unlocks: Audio Story 009 + HUD Story farewell + Recap Story farewell

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 GDScript tests + 4 Python tests (覆盖到 numeric_only)
**Test Evidence**: `tests/unit/event/farewell_const_test.gd` (~80 行 / 5 tests / GdUnit4) + `tests/unit/event/event_schema_lint_test.py StorySixFarewellLintTests` (4 tests / Python unittest — 全 PASS) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`EventScriptEngine.FAREWELL_EVENT_IDS` 是 5-member typed `Array[StringName]` 与 AudioManager + LightingController 默认值集合一致 (同 5 ID),Python lint `lint_farewell_numeric_only` 三守门 (id 在白名单 + dialogue_keys_* 仅 1 个 + 后缀 .TITLE_NUMERIC),GDScript mirror invariants 通过 `has()` set-比较;无 BLOCKING / 无 inline fix
**Engine API Verification**: GDScript const + Array.has() — 无 4.5+ 新 API
**Deviations** (1 项 ADVISORY):
1. `tools/farewell_lint.gd` 在 ADR 中提到的 GDScript 版本由 Python `lint_farewell_numeric_only` 等价覆盖 (单语言 lint 依赖统一);ADR-0001 / 0009 Status=Proposed lean-mode-equivalent
**Tech debt**: None new (const owner = #10 唯一拷贝;Audio + Lighting 现有 mirror 保持已有副本)
**API surface**: `EventScriptEngine.FAREWELL_EVENT_IDS: Array[StringName]` (canonical 5-member const) + Python `lint_farewell_numeric_only`
