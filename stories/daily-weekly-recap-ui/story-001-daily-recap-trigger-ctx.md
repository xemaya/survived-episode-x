# Story 001: Daily Recap 触发协议 + ctx payload 消费

> **Epic**: Daily / Weekly Recap UI
> **Status**: Blocked — 依赖 propagation flag #6(`#6 Rule 3` `scene_state_changed` 扩展 ctx: Dictionary)
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-001`(Daily Recap 部分)

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix
**ADR Decision Summary**: `#15` 订阅 `#6 scene_state_changed(from, to, ctx: Dictionary)`,ctx 含 `is_weekly` / `is_weekend` / `is_last_day_of_month` / `current_day` / `current_weekday` 五字段(B1 仲裁 — propagation flag #6)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `Dictionary` 信号参数 4.6 标准。

**Control Manifest Rules (Presentation)**:
- Required: ctx payload 消费,信号 handler ≤ 0.5ms
- Forbidden: 轮询查询 `#6` 公开属性(违反 ADR-0001 单点信号源)
- Guardrail: dispatch ≤ 1 帧

---

## BLOCKED Reason

`#6 scene-day-flow-controller` GDD next revision 须实施 propagation flag #6:`scene_state_changed` 信号扩展为 `(from, to, ctx: Dictionary)`,ctx 含 5 字段。在此之前本 story 实施挂起。**如何解封**:`#6` GDD revision Approved + `#6` Story 002 实施 ctx payload。

---

## Acceptance Criteria

- [ ] AC-FUNC-01: `#6 scene_state_changed(AFTER_WORK, DAILY_RECAP, ctx)` emit,`#15` 收到信号 ≤ 1 帧内完成渲染准备(handler ≤ 0.5ms,layout 推 call_deferred)
- [ ] ctx payload 字段消费:`ctx.is_weekly` / `ctx.is_weekend` / `ctx.current_day` / `ctx.current_weekday` 全字段读取
- [ ] Daily 视图展示内容:今日 AP / 精力 / 加班 / 早退 / 今日事件列表(从 `#7` / `#10` 信号缓存读取)
- [ ] handler 内仅"状态登记 + 数据引用缓存",节点 layout 推 `call_deferred()` 入下一帧

---

## Implementation Notes

*From GDD Rule 1(revised):*

```gdscript
func _on_scene_state_changed(from: SubMode, to: SubMode, ctx: Dictionary) -> void:
    if to != SubMode.DAILY_RECAP: return
    _cached_ctx = ctx
    _cached_data = {
        "ap_used": APEconomy.current_max_ap - APEconomy.current_ap,
        "energy": APEconomy.current_energy,
        "events_today": EventScript.get_events_for_day(ctx.current_day),
        # ...
    }
    call_deferred("_perform_recap_layout")  # 推下一帧 layout

func _perform_recap_layout() -> void:
    if _cached_ctx.is_weekly:
        _render_weekly_view()  # Story 002
    elif _cached_ctx.is_weekend:
        _render_simplified_weekend_view()  # E-1.2
    else:
        _render_daily_view()
```

---

## Out of Scope

- Story 002: Weekly Recap 周五升级路径
- Story 003: effort 三维度渲染
- Story 004: 事件列表渲染

---

## QA Test Cases

- **AC-FUNC-01**: handler ≤ 0.5ms
  - Given: emit `scene_state_changed(AFTER_WORK, DAILY_RECAP, valid_ctx)`
  - When: handler 同步执行
  - Then: `Time.get_ticks_usec()` 测 ≤ 500us;layout 在下一帧完成
  - Edge cases: ctx 字段缺失 → push_error + fallback;ctx == null → 同上

- **AC-2**: ctx 全字段
  - Given: ctx = `{is_weekly: false, is_weekend: false, current_day: 5, current_weekday: 3, is_last_day_of_month: false}`
  - When: handler 读取
  - Then: `_cached_ctx` 含 5 字段且值匹配

---

## Test Evidence

**Required evidence**: `tests/unit/recap_ui/daily_recap_trigger_ctx_test.gd` — must exist and pass

---

## Dependencies

- Depends on: `#6 Scene Flow` Story 002(scene_state_changed signal **ctx 扩展实施**);`#7 AP Economy` Story 008(monthly_effort_summary signal);`#10 Event Script` Story 007(event_started signal)
- Unlocks: Story 002, 003, 004
