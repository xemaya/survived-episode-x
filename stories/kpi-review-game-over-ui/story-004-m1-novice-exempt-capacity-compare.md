# Story 004: M1 新人豁免破折号 + capacity 数字对比预警

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: TR-kpiui-006(部分,边界条件)

**ADR Governing Implementation**: ADR-0007(三轨锚 + breakdown 渲染范围)
**ADR Decision Summary**: M1(`month_index == 1`)γ_effective=0,工龄项消去 — UI 行 3 显示 "—"(破折号)+ "新人豁免" 文案,**不显示**数字百分比(per `#9 Rule 6` 新手保护)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 无引擎风险;纯 UI 逻辑分支。

**Control Manifest Rules (Presentation)**:
- Required: 所有数据驱动分支(M1 vs M2+)由上游 `#9 breakdown.novice_protection_active` 字段判定,UI 不复算
- Forbidden: UI 内硬编码 `if month == 1`(违反 layer 边界,KPI 逻辑由 `#9` own)
- Guardrail: 单条件分支 < 0.1ms

---

## Acceptance Criteria

- [ ] AC-FUNC-03: M1 结算(`novice_protection_active = true`),行 3 显示 `—` + `tr("KPI.BREAKDOWN.TENURE_NOVICE_EXEMPT")`;**不显示**数字百分比
- [ ] capacity_now 对比行展示数字 + 趋势文案(降低 → "下个月起 capacity 将降至 X");**禁止**红色警告 + 闪烁
- [ ] M2+ 时行 3 走 Story 003 的 format_contrib_pct 正常路径
- [ ] `novice_protection_active` 字段从 `kpi_threshold_changed.breakdown` 直接读取,UI 不计算 month

---

## Implementation Notes

*From GDD Rule 3 + Rule 4:*

- 渲染分支(在 Story 003 的 `_render_breakdown` 内):
  ```gdscript
  if breakdown.novice_protection_active:
      tenure_label.text = "%s %s" % [tr("KPI.BREAKDOWN.TENURE_LABEL"), "—"]
      tenure_note.text = tr("KPI.BREAKDOWN.TENURE_NOVICE_EXEMPT")
  else:
      tenure_label.text = "%s %s" % [tr("KPI.BREAKDOWN.TENURE_LABEL"), format_contrib_pct(breakdown.tenure_contrib_pct)]
  ```
- capacity 对比预警:
  - 数字对比 `"%.2f → %.2f" % [old, new]`
  - 趋势文案 key:`KPI.CAPACITY.TREND_DOWN` / `TREND_FLAT`(无 TREND_UP — capacity 单调降,per `#9 Rule 7`)
  - **禁**红色背景 / 闪烁 / `Tween.set_trans(Tween.TRANS_ELASTIC)`(违反 Rule 5 数字克制 + Anti-P2)

---

## Out of Scope

- Story 003: 三行 HR 渲染主体(本 story 仅 M1 边界 + capacity 对比)
- Story 013: M1 文案 lint(确保 "新人豁免" 不含励志词族)

---

## QA Test Cases

- **AC-FUNC-03**: M1 破折号
  - Given: `breakdown = {novice_protection_active: true, tenure_contrib_pct: 0.0}`
  - When: `_render_breakdown(breakdown)`
  - Then: tenure_label 文本含 "—" AND 不含 "%" 字符
  - Edge cases: M2 同时 `tenure_contrib_pct == 0.0` → 显示 "+0.0%"(非破折号)

- **AC-2**: capacity 对比无红色
  - Given: capacity_old=0.95, capacity_new=0.85
  - When: 渲染 capacity 对比行
  - Then: Label 节点 `modulate == Color.WHITE`(或冷调灰),不含 `Color.RED` / `Color.ORANGE`
  - Edge cases: capacity 大幅降(0.95 → 0.50)仍冷调

- **AC-3**: 单调降守门
  - Given: capacity_new > capacity_old(理论不应发生)
  - When: 渲染
  - Then: push_warning("capacity 应单调降"),fallback 走 TREND_FLAT key

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/m1_novice_capacity_compare_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 003(breakdown 三行渲染主体);`#9 KPI` Story 003(F2 + Story 004 F3 capacity 字段)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数 in `tests/unit/kpi_ui/m1_novice_capacity_compare_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/m1_novice_capacity_compare_test.gd` (95 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-03 M1 破折号 + TENURE_NOVICE_EXEMPT → `test_m1_novice_tenure_shows_em_dash` + `test_m1_novice_note_uses_exempt_key` + `test_m1_novice_path_has_no_percent`
- M2+ 行 3 走 format_contrib_pct → `test_m2_zero_tenure_renders_plus_zero`
- capacity 冷调灰非红 → `test_capacity_compare_label_not_red`
- 单调降守门 fallback FLAT → `test_capacity_invariant_violation_falls_back_flat`

**Code Review**: APPROVED;novice_protection_active 直读 breakdown(不复算 month);无 BLOCKING
**Deviations** (无):
**Tech debt**: None new
**API surface**: `_render_breakdown` novice 分支 + capacity 趋势 key (TREND_DOWN / TREND_FLAT)
