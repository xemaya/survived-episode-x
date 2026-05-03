# Story 004: 事件 numeric_only 列表 + D1 截断 8 条

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-002`(事件列表部分)+ Rule 4 + D1 公式

**ADR Governing Implementation**: ADR-0012 Three-Density Rendering
**ADR Decision Summary**: Recap 事件列表使用 `numeric_only` 风格(继承 `#10 Rule 19`),每条仅 `EVENT.[event_id].TITLE_NUMERIC` localization key;**禁**重放 `long` 档叙事内容。`RECAP_EVENT_LIST_MAX = 8`;超过按 D1 公式 priority 降序选 top k。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: Sort + slice 4.6 标准。

**Control Manifest Rules (Presentation)**:
- Required: 事件列表使用 numeric_only 渲染规则(单行 TITLE_NUMERIC);列表上限 8 条
- Forbidden: long 档叙事 / flash overlay / 重放对白(违反 P5 budget)
- Guardrail: 8 条事件渲染 ≤ 1.5ms

---

## Acceptance Criteria

- [ ] AC-FUNC-03: 当日或当周 `event_completed` history ≥ 9 条,Recap 渲染展示 top 8 条(按 D1 公式);剩余条目不展示;不展示"还有 N 条"提示;不崩溃
- [ ] D1 公式实施:
  ```
  显示事件集 = top_k(completed_events, k=RECAP_EVENT_LIST_MAX, key=λe: e.priority)
  其中 e.priority 来自 #10 F1 effective_weight,范围 [0.01, 150]
  同 priority 按 day 倒序;同 day 同 priority 按 event_completed 时间戳降序
  ```
- [ ] 每条事件渲染:`tr("EVENT.[event_id].TITLE_NUMERIC")` 单行(无对白 / 无 flash overlay)
- [ ] Daily 同样上限 8 条;Weekly scope = monday..friday

---

## Implementation Notes

*From GDD Rule 4 + D1:*

```gdscript
const RECAP_EVENT_LIST_MAX: int = 8

func _render_event_list_weekly(current_day: int) -> void:
    var scope := _get_week_day_range(current_day)  # [monday..friday]
    var events := EventScript.get_completed_events(scope)
    var top_k := _select_top_k(events, RECAP_EVENT_LIST_MAX)
    for ev in top_k:
        var card := preload("res://scenes/ui/recap/event_line.tscn").instantiate()
        card.label.text = "%s: %s" % [_format_day_label(ev.day), tr("EVENT.%s.TITLE_NUMERIC" % ev.event_id)]
        event_list_vbox.add_child(card)

func _select_top_k(events: Array, k: int) -> Array:
    events.sort_custom(func(a, b):
        if a.priority != b.priority: return a.priority > b.priority
        if a.day != b.day: return a.day > b.day  # 倒序
        return a.completed_at_usec > b.completed_at_usec
    )
    return events.slice(0, min(k, events.size()))
```

---

## Out of Scope

- Story 010: AC-FAREWELL-01 守门(farewell 事件特例守 numeric_only,本 story 已默认 numeric_only,Story 010 加 lint 守门)
- Story 011: narrative_density_changed 切档(本 story 假设 standard 密度)
- `#10 Event Script` Story 007(event_started signal)+ Story 012(history 持久化)

---

## QA Test Cases

- **AC-FUNC-03**: 8 条截断
  - Given: completed_events 含 12 条,priority 分布 50/40/35/35/20/20/20/20/15/10/10/10
  - When: `_render_event_list_weekly(5)`
  - Then: VBoxContainer 含 8 个 EventLine child;前 8 priority 升序选取
  - Edge cases: 12 条全 priority == 20 → 按 day 倒序选 top 8;全 priority == 0.01 同;0 条 → vbox 空(不崩溃,fallback 由 E-1.3 处理)

- **AC-2**: numeric_only 渲染
  - Given: top 8 events 渲染
  - When: 反射 EventLine label 文本
  - Then: 每条文本含 "EVENT.[event_id].TITLE_NUMERIC" tr 结果(非 long 对白);无 ChoiceButton 子节点;无 flash overlay 节点
  - Edge cases: 故意注入 `EVENT.[id].TITLE_LONG` → 应被替换为 TITLE_NUMERIC(由 numeric_only 渲染规则锁)

- **AC-3**: 同 priority tiebreaker
  - Given: 3 events 同 priority == 20,day 分布 [1, 3, 2]
  - When: sort
  - Then: 顺序 day=3 / day=2 / day=1(倒序最新优先)

---

## Test Evidence

**Required evidence**: `tests/unit/recap_ui/event_list_numeric_only_truncate_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001 + 002(Daily / Weekly view);`#10 Event Script` Story 007 + 012(event_completed history);`#3 Localization` Story 001(tr API)
- Unlocks: Story 010(AC-FAREWELL-01 在此基础上守门)

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 ACs COVERED via 7 test 函数 (event_list_numeric_only_truncate_test.gd)
**Test Evidence**: `tests/unit/recap/event_list_numeric_only_truncate_test.gd` (7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED;`select_top_k()` 静态方法纯函数 — D1 公式 priority desc → day desc → completed_at desc;`RECAP_EVENT_LIST_MAX = 8` const;`render_event_list()` clear + slice 8;0 events 不崩溃;同 priority tiebreaker 测;无 ChoiceButton / flash overlay 节点
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0012 Status=Proposed — lean-mode-equivalent
2. event_line.tscn 资产 OUT-OF-SCOPE (Phase 4 UX) — `_instantiate_event_line()` 用 Control + Label 骨架兜底,production wiring 替换为 .tscn
3. EventScript Story 007/012 history API 待并行 epic 落地 — Callable seam (`completed_events_provider`) ready
**Tech debt**: None new
**API surface**: `RecapViewController.RECAP_EVENT_LIST_MAX` + `select_top_k(events, k) -> Array` (静态) + `render_event_list(day_range, current_day) -> Array` + `completed_events_provider` Callable
