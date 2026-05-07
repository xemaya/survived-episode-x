# Story 003: effort 三维度 HR 渲染

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-002`(effort 三维度展示部分)

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master 8 Domain List(HR 戏谑口吻锁)+ ADR-0001(数据 source 锁)
**ADR Decision Summary**: effort 三维度 schema source = `#7 effort_*_incremented` 周累计(非月末周)+ `#7 monthly_effort_summary`(月末周);**不**消费 `#9 Rule 10 breakdown`(由 `#16` own,本 GDD revision 已修正 schema 误引)。HR 口吻锁继承 `#9 Rule 14`。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: Label 渲染 4.6 标准;`tr()` 同步。

**Control Manifest Rules (Presentation)**:
- Required: schema source 严格走 `#7` 信号族
- Forbidden: 消费 `#9 kpi_threshold_changed.breakdown`(由 `#16` own,违反 layer 边界)
- Guardrail: 三行渲染 ≤ 1ms

---

## Acceptance Criteria

- [ ] AC-FUNC-04: 周五 Weekly Recap 触发,`effort_*_incremented` 本周累计非零;Weekly Recap 三行数字与 `#7` 信号累计一致(加班次数 / Hero 卡张数 / 超预期次数);HR 口吻标注正确(`_BUREAUCRATIC` 后缀 key)
- [ ] 三行格式(per Rule 3 revised):
  ```
  - 加班记录:    [N 次] — 积极性已登记
  - Hero 卡打出: [N 张] — 超额贡献已归档
  - 超预期事件:  [N 次] — 产出记录存档
  ```
- [ ] 数据 source:`APEconomy.weekly_overtime_count` / `weekly_hero_count` / `weekly_overage_count`(由 `effort_*_incremented` 信号累计)
- [ ] **禁**进度条 / 百分比 / "完成度" — 三行展示绝对数字(per Rule 5)

---

## Implementation Notes

*From GDD Rule 3(revised):*

```gdscript
func _render_effort_three_dimensions(current_day: int) -> void:
    var overtime_count: int = APEconomy.weekly_overtime_count()
    var hero_count: int = APEconomy.weekly_hero_count()
    var overage_count: int = APEconomy.weekly_overage_count()

    overtime_label.text = "%s [%d 次] — %s" % [
        tr("RECAP.EFFORT.OVERTIME_LABEL"),
        overtime_count,
        tr("RECAP.EFFORT.OVERTIME_REGISTERED_BUREAUCRATIC")
    ]
    hero_label.text = "%s [%d 张] — %s" % [
        tr("RECAP.EFFORT.HERO_LABEL"),
        hero_count,
        tr("RECAP.EFFORT.HERO_OVERCONTRIB_BUREAUCRATIC")
    ]
    overage_label.text = "%s [%d 次] — %s" % [
        tr("RECAP.EFFORT.OVERAGE_LABEL"),
        overage_count,
        tr("RECAP.EFFORT.OVERAGE_RECORDED_BUREAUCRATIC")
    ]
```

注:`weekly_*_count()` API 由 `#7 AP Economy` Story 005 / 008 实施。

---

## Out of Scope

- Story 005: 进度条 lint(本 story 仅渲染)
- Story 006: HR 口吻 lint(主语翻转独立守门)
- `#7 AP Economy` Story 005(F4 effort 三维度计算)
- `#16 KPI Review UI` Story 003(`#9 breakdown` 三因子渲染 — 不同 schema)

---

## QA Test Cases

- **AC-FUNC-04**: 三行数字一致
  - Given: APEconomy.weekly_overtime_count() == 2, weekly_hero_count() == 3, weekly_overage_count() == 1
  - When: `_render_effort_three_dimensions()`
  - Then: 三 Label 文本含 "2 次" / "3 张" / "1 次";含 _BUREAUCRATIC tr() 文案
  - Edge cases: 全为 0(完全摸鱼周)→ 三行展示 "0",不崩溃,不替换为 "无"

- **AC-2**: 无进度条 / 百分比
  - Given: 三 Label 渲染完成
  - When: 反射节点类型 + grep 文本
  - Then: 0 ProgressBar / 0 "%" 字符 / 0 "完成度" 字面量

- **AC-3**: schema source 锁
  - Given: 静态分析 effort 三行实施代码
  - When: grep `kpi_threshold_changed` / `breakdown`
  - Then: 0 命中(不消费 `#9` schema)

---

## Test Evidence

**Required evidence**: `tests/unit/recap_ui/effort_three_dimension_hr_render_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 002(Weekly view 入口);`#7 AP Economy` Story 005(F4 effort 三维度);`#3 Localization` Story 001(tr API)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 ACs COVERED via 5 test 函数 (effort_three_dimension_hr_render_test.gd)
**Test Evidence**: `tests/unit/recap/effort_three_dimension_hr_render_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);`render_effort_three_dimensions()` 严格走 `weekly_*_count` Callable seam,源码 grep `kpi_threshold_changed` / `.breakdown` 均 0 命中(AC-3 schema lock);unit suffix 通过 tr() (LOC_KEY_UNIT_TIMES / LOC_KEY_UNIT_CARDS) — 与 Story 009 AC-FUNC-10 协同;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0010 Status=Proposed — lean-mode-equivalent
2. .tscn 资产 OUT-OF-SCOPE (UI team Phase 4)
3. APEconomy.weekly_*_count() API 由 #7 Story 005/008 实施 — Callable seam 已 ready,production .tscn wiring Phase 4
**Tech debt**: None new
**API surface**: `RecapViewController.render_effort_three_dimensions()` + 6 `LOC_KEY_*` const + 3 Callable seams (`weekly_overtime_provider` / `weekly_hero_provider` / `weekly_overage_provider`)
