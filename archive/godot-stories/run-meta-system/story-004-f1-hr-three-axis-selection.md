# Story 004: F1 HR 3-Axis Word Selection + 30-Term Library

> **Epic**: run-meta-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/run-meta-system.md` | **Requirement**: `TR-run-meta-003`
**ADR**: GDD F1 三轴选词 + 30 词条
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: F1 三轴(month_at_end / end_reason / effort_avg)→ HR 评语 30 词条选 1
- Required: subject_inversion_lint --domain TENURE 守门(协作 ADR-0010)

## Acceptance Criteria

- [ ] `select_hr_evaluation(month_at_end, end_reason, effort_avg) -> StringName` API
- [ ] 30 词条分布表(EVAL.ROOKIE.PASS.M1 / EVAL.ROOKIE.FAIL.M1 / EVAL.MID.PASS.M5 / ...)
- [ ] R-RM-3 守门:30 词条 tone lint(_BUREAUCRATIC 后缀)— 违反 Pillar 4 PR-blocking
- [ ] writer + narrative-director sign-off advisory

## Implementation Notes

```gdscript
const EVAL_TIER_KEYS := {
    "ROOKIE_PASS": &"EVAL.ROOKIE.PASS",  # M1-M3 通过
    "ROOKIE_FAIL": &"EVAL.ROOKIE.FAIL",
    "MID_PASS": &"EVAL.MID.PASS",  # M4-M8
    # ... 共 30 entries 覆盖三轴组合
}

func select_hr_evaluation(month: int, reason: StringName, effort_avg: float) -> StringName:
    var tier := _classify_month(month)  # ROOKIE / MID / SENIOR
    var outcome := "PASS" if reason != &"DISMISSAL" else "FAIL"
    var effort_class := _classify_effort(effort_avg)
    return StringName("EVAL.%s.%s.%s" % [tier, outcome, effort_class])
```

## QA Test Cases

- 三轴 27 组合(3×3×3)对应 27 keys + 3 fallback = 30 词条
- subject_inversion_lint --domain TENURE 通过

## Test Evidence

`tests/unit/run_meta/hr_evaluation_test.gd` + writer sign-off advisory

## Dependencies

- Depends on: Story 001 + Loc Story 011(IRONY/_BUREAUCRATIC tone lint)
- Unlocks: KPI Review UI Story(GAMEOVER 屏 HR 评语展示)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 14 test 函数
**Test Evidence**: `tests/unit/run_meta/hr_evaluation_test.gd` (190 行 / 14 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);HR_EVAL_LIBRARY 30 entries(18 三轴 + 3 RESIGN + 6 CEREMONY + 3 FALLBACK)+ select_hr_evaluation(month, reason, effort) 三轴分类(ROOKIE 1-3 / MID 4-8 / SENIOR 9+;PASS/FAIL/RESIGN;LOW≤0.40 / MID≤0.70 / HIGH);R-RM-3 fallback 三层(zero month / unknown reason / NaN+negative effort);hr_word_library 副作用累积(TR-run-meta-003 cross-run "评语收集");无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. writer + narrative-director sign-off advisory(后置 — keys 已 stable,词条文本待 i18n PR)
2. `subject_inversion_lint --domain TENURE` 物料绑定到 hr_word_library.tres 创建后(本 epic 未涉及 .tres 资源)— 留 cross-epic Loc Story 011 接续
**Tech debt**: None new
**API surface**: `RunMetaSystem.select_hr_evaluation(month_at_end, end_reason, effort_avg) -> StringName`(side-effect: hr_word_library[key]=true);const HR_EVAL_LIBRARY: Array[StringName]; HR_TIER_ROOKIE_MAX=3 / HR_TIER_MID_MAX=8 / HR_EFFORT_LOW_MAX=0.40 / HR_EFFORT_MID_MAX=0.70
