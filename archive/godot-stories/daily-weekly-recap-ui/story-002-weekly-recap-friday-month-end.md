# Story 002: Weekly Recap 周五升级协议 + 月末特例

> **Epic**: Daily / Weekly Recap UI
> **Status**: Blocked — 依赖 propagation flag #6(同 Story 001)
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-001`(Weekly Recap 部分)+ Rule 2

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix
**ADR Decision Summary**: 周五 `ctx.is_weekly == true` 时升级 Weekly 视图;月末最后周五 `ctx.is_last_day_of_month == true` 时由 `#6 Rule 10` 触发 KPI_REVIEW dispatch,`#15` 不展示月末结算(由 `#16` own)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 同 Story 001。

**Control Manifest Rules (Presentation)**:
- Required: 月末 Weekly Recap 展示完毕后无条件转 `#16`(`#6 Rule 10` 仲裁)
- Forbidden: `#15` 自行展示月末 KPI 结算(违反 layer 边界)
- Guardrail: 周末两天 sub-mode handler ≤ 0.5ms

---

## BLOCKED Reason

同 Story 001 — 依赖 `#6` propagation flag #6 实施。

---

## Acceptance Criteria

- [ ] AC-FUNC-02: `ctx.is_weekly == true`(周五),`#15` 渲染 Weekly 视图(effort 三行 + 事件列表 + KPI 区块);非 Daily 视图
- [ ] AC-FUNC-07: `ctx.is_weekend == true`(day 6/7),`#15` 展示精简 Daily Recap(Energy 恢复记录,无事件列表);`is_weekly == false`;不展示 KPI 周摘要
- [ ] AC-FUNC-06: 月末周五(`ctx.is_weekly == true` AND `ctx.is_last_day_of_month == true`),Weekly Recap 展示结束后 `#6 Rule 10` 触发 `request_transition(KPI_REVIEW)`;`#15` 收到 `scene_state_changed(DAILY_RECAP → KPI_REVIEW)` 时立即注销 skippable + 退出
- [ ] `#15` 月末周五**不**展示月末结算内容(严格停于 effort + 事件 + KPI 区间预测)

---

## Implementation Notes

*From GDD Rule 2(revised):*

```gdscript
func _perform_recap_layout() -> void:
    var ctx := _cached_ctx
    if ctx.is_weekend:
        _render_simplified_weekend_view()
        return
    if ctx.is_weekly:
        _render_weekly_view(ctx)
    else:
        _render_daily_view(ctx)

func _render_weekly_view(ctx: Dictionary) -> void:
    _render_effort_three_dimensions(ctx.current_day)  # Story 003
    _render_event_list_weekly(ctx.current_day)  # Story 004
    if not ctx.is_last_day_of_month:
        _render_kpi_pending_settlement()  # E-4.3
    # 月末:`#6 Rule 10` 在 Weekly Recap 后 dispatch KPI_REVIEW,`#15` 自动退出
```

转 `#16` 退出路径:
```gdscript
func _on_scene_state_changed(from: SubMode, to: SubMode, ctx: Dictionary) -> void:
    if from == SubMode.DAILY_RECAP and to == SubMode.KPI_REVIEW:
        _exit_recap()  # 注销 skippable token + 隐藏 panel
```

---

## Out of Scope

- Story 003: effort 三维度具体渲染
- Story 004: 事件列表
- `#16 KPI Review UI`: 月末结算屏(下游)
- `#6 Story 010`: 月末 dispatch KPI_REVIEW(上游)

---

## QA Test Cases

- **AC-FUNC-02**: 周五 Weekly 视图
  - Given: ctx = `{is_weekly: true, is_weekend: false, is_last_day_of_month: false, current_day: 5, current_weekday: 5}`
  - When: `_perform_recap_layout()`
  - Then: WeeklyView 节点 visible == true AND DailyView visible == false;effort 三行可见 + 事件列表 + KPI 区块预测
  - Edge cases: 周一 `is_weekly == false` → DailyView 显示,WeeklyView 不显示

- **AC-FUNC-07**: 周末精简
  - Given: ctx.is_weekend == true(day 6 / 7)
  - When: layout
  - Then: SimplifiedWeekendView 显示 Energy 恢复记录;事件列表为空;KPI 区块不展示

- **AC-FUNC-06**: 月末周五 → KPI_REVIEW
  - Given: ctx.is_last_day_of_month == true,Weekly Recap 展示中
  - When: emit `scene_state_changed(DAILY_RECAP, KPI_REVIEW, _)`
  - Then: skippable token 注销;Recap panel 隐藏;`#16` 接管(由 `#16` 处理)
  - Edge cases: skip 触发 → 同样退出

---

## Test Evidence

**Required evidence**: `tests/unit/recap_ui/weekly_recap_friday_month_end_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(基础触发 + ctx 消费);`#6 Scene Flow` Story 010(月末 KPI_REVIEW dispatch);`#16 KPI Review UI` Story 001(KPI_REVIEW state 接管)
- Unlocks: Story 003, 004
