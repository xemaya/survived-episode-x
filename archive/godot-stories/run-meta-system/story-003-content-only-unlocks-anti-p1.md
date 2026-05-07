# Story 003: Content-Only Unlocks 5 Whitelist (Anti-P1 Red Line)

> **Epic**: run-meta-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/run-meta-system.md` | **Requirement**: `TR-run-meta-005`
**ADR**: ADR-0001 forbidden_pattern + Save Story 010 协作
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 5 类白名单(codex / memo / npc / event_branch / ending)
- Forbidden: 任何机械成长字段(starting_ap_bonus / kpi_base_offset 等)— Anti-P1 PR-blocking + push_error

## Acceptance Criteria

- [ ] `unlock_content(content_id)` API 协作 Save Story 010(SaveSystem.unlock_content)
- [ ] R-RM-1 守门测试:effect 试图 unlock_content("starting_ap_bonus.bonus_2") → push_error + ERR_INVALID_PARAMETER
- [ ] CI lint `tools/anti_p1_lint.py` 扫 effect/event 引用 → 命中机械成长 keyword → CI FAIL

## Implementation Notes

```gdscript
func unlock_content(content_id: StringName) -> Error:
    return SaveSystem.unlock_content(content_id)  # 协作 Save Story 010

# Anti-P1 lint 见 AP Story 012
```

## QA Test Cases

- unlock_content("codex.hr_manual_page_3") → OK
- unlock_content("starting_ap_bonus.bonus_2") → ERR + push_error

## Test Evidence

`tests/integration/run_meta/content_unlocks_test.gd`(协作 Save Story 010)

## Dependencies

- Depends on: Save Story 010
- Unlocks: Event Script Story 003(GiveUnlockEffect 调用)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 12 test 函数
**Test Evidence**: `tests/integration/run_meta/content_unlocks_test.gd` (177 行 / 12 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);unlock_content() 转发 SaveSystem(Story 010 既有 5-class regex 守门)+ 本地 unlocks cache 镜像 + run_meta_unlock signal emit;injection seam (`save_system_callable: Callable`) 让测试用 mock regex 不需起 SaveSystem autoload + filesystem;5 类白名单各 1 happy + 2 mechanical-growth ERR + signal/cache 不污染 4 项 R-RM-1 守门;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. `tools/anti_p1_lint.py` CI lint 在 AP Story 012 范畴(本 epic 外)— 本 story 仅守 runtime 路径
**Tech debt**: None new
**API surface**: `RunMetaSystem.unlock_content(content_id: StringName) -> Error` / `is_content_unlocked(content_id) -> bool` / `save_system_callable: Callable` (test injection seam) / signal `run_meta_unlock(content_id)`
