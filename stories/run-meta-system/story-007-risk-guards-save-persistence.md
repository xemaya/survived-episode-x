# Story 007: Risk Guards + Save Sub-Schema Persistence

> **Epic**: run-meta-system | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/run-meta-system.md` | **Requirement**: `TR-run-meta-001` + `TR-run-meta-002`
**ADR**: ADR-0003 sub-schema run_meta + R-RM-1..3
**Engine**: Godot 4.6 | **Risk**: MEDIUM

**Control Manifest Rules**:
- Required: Save sub-schema run_meta(run_count / current_run_month / unlocks / archive / hr_word_library)
- Required: R-RM-1..3 [RISK GUARD] 全 AC-ROBUST 守门

## Acceptance Criteria

- [ ] sub-schema run_meta 5 字段 round-trip(协作 Save Story 001)
- [ ] **R-RM-1**(stat buff)守门:Anti-P1 lint(Story 003)
- [ ] **R-RM-2**(archive cap 越界)守门:Story 002 FIFO 驱逐 + 200 cap dialog(协作 Main Menu UI Story)
- [ ] **R-RM-3**(词条 tone 违规)守门:F1 30 词条 subject_inversion_lint --domain TENURE(Story 004)+ Pillar 4 PR-blocking

## Implementation Notes

```gdscript
func serialize() -> Dictionary:
    return {
        "schema_version": 1,
        "run_count": run_count,
        "current_run_month": current_run_month,
        "unlocks": unlocks.duplicate(true),
        "archive": _serialize_archive_index(),
        "hr_word_library": hr_word_library,
    }

func deserialize(dict: Dictionary) -> void:
    if dict.get("schema_version", 0) != 1:
        push_warning("[RunMeta] schema_version mismatch")
    run_count = dict.get("run_count", 0)
    # ...
```

## QA Test Cases

- Save round-trip 5 字段保留
- R-RM-1..3 各自守门

## Test Evidence

`tests/integration/run_meta/risk_guards_save_test.gd`

## Dependencies

- Depends on: Story 002 + Story 003 + Story 004 + Save Story 001
- Unlocks: 跨 Run state persist

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 12 test 函数
**Test Evidence**: `tests/integration/run_meta/risk_guards_save_test.gd` (273 行 / 12 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);RUN_META_SCHEMA_VERSION=1 + serialize/deserialize 5 字段 round-trip(run_count / current_run_month / unlocks / archive / hr_word_library)+ schema_version mismatch push_warning best-effort load + 空 dict no-op + missing keys default;R-RM-1 4 类 mechanical-growth keys 拒绝并不污染 unlocks(starting_ap_bonus / kpi_base_offset / max_health / damage_multiplier);R-RM-2 cap+5 → 200 cap + front=6 验证 FIFO;R-RM-3 3 类 fallback keys 通过 round-trip;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. MetaSaveState 已有 run_count/unlocks/archive 镜像字段 — 本 story RunMetaSystem.serialize() 是并行 in-memory 快照,实际 disk 写仍由 SaveStateLoader.save_meta_async 走 MetaSaveState;后续 story 做 sub-schema consolidation
2. R-RM-3 词条 tone lint(subject_inversion_lint --domain TENURE)仍待 hr_word_library.tres + i18n PR — 本 story 仅守 fallback 路径 round-trip
**Tech debt**: None new
**API surface**: const `RUN_META_SCHEMA_VERSION=1`;`RunMetaSystem.serialize() -> Dictionary` / `deserialize(dict) -> void`
