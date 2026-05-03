# Story 007: skippable + 月末倒数 2 周 1500ms 守门 + R-RCP-2

> **Epic**: Daily / Weekly Recap UI
> **Status**: Blocked — 依赖 propagation flag #7(`#2 Input Rule 6` `register_skippable` 拓展 `min_display_ms` 参数)
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: AC-ROBUST-01 + AC-ROBUST-04 + Rule 7 + Rule 9 + R-RCP-2

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix(skippable token 协议)
**ADR Decision Summary**: Recap skippable token 注册 + 退出无条件 unregister(R-RCP-2 跨 R-SDF-5 守门);**B3 仲裁** — 月末倒数 2 周(M3+ W3/W4)Weekly Recap 守门最小展示 1500ms(`min_display_ms` 参数);M1/M2 + M3+ W1/W2 即时 skip。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 同 `#16 Story 007` skippable 协议。

**Control Manifest Rules (Presentation)**:
- Required: skippable token 通过 `#2 InputHandler.register_skippable()` API
- Forbidden: 直接订阅 `act_skip` Action — 必须经 token 注册路径
- Guardrail: skip 触发 → 退出 ≤ 1 帧(except 月末 W3/W4 守门 1500ms)

---

## BLOCKED Reason

`#2 input-handler` GDD next revision 须实施 propagation flag #7:`register_skippable(token_id, on_skip, min_display_ms: int = 0)` API 拓展。在此之前**月末守门**实施挂起,但**即时 skip 路径**(M1/M2 全月 + M3+ W1/W2)不受影响,可先实施基础 skippable 注册。

**如何解封**:`#2` GDD revision Approved + `#2` Story 004(skippable token registry)实施 `min_display_ms` 参数。

---

## Acceptance Criteria

- [ ] AC-ROBUST-01: 退出路径(skip / 超时 / `GAMEOVER` 强制中断)无条件调用 `unregister_skippable(&"daily_recap_skip")`(集成测试 force-transition 至 MORNING_BRIEFING 断言 has_skippable == false)
- [ ] AC-ROBUST-04: `ctx.is_weekly == true` AND `_is_late_month_week(ctx) == true`(M3+ W3/W4)+ Weekly Recap 渲染中,玩家在 t < 1500 ms 时按 skip,`recap_skipped` 信号被 `#2 InputHandler` `min_display_ms` 守门挂起,直至 t == 1500 ms 才 emit;玩家在挂起期间继续可见 effort 三维度数字
- [ ] M1/M2 全月 + M3+ W1/W2 不守门(即时 skip 生效)
- [ ] `_is_late_month_week(ctx)` 判定:MVP `ctx.current_day ∈ [15, 31]`;野心版按月动态计算

---

## Implementation Notes

*From GDD Rule 7(revised):*

```gdscript
func _enter_recap(ctx: Dictionary) -> void:
    var min_display_ms := 1500 if (ctx.is_weekly and _is_late_month_week(ctx)) else 0
    InputHandler.register_skippable(
        token_id = &"daily_recap_skip",
        on_skip = _on_recap_skipped,
        min_display_ms = min_display_ms  # propagation flag #7
    )

func _is_late_month_week(ctx: Dictionary) -> bool:
    # MVP 简化:每月固定 4 周,W3/W4 = day ∈ [15, 31]
    # M3+ 启用(M1/M2 不守):
    if ctx.current_month < 3: return false
    return ctx.current_day >= 15

func _exit_recap() -> void:
    InputHandler.unregister_skippable(&"daily_recap_skip")
    # _exit_tree() 钩子也调 unregister(双保险)

func _exit_tree() -> void:
    if InputHandler.has_skippable(&"daily_recap_skip"):
        InputHandler.unregister_skippable(&"daily_recap_skip")
        push_warning("R-RCP-2: skippable leaked, recovered in _exit_tree")
```

`#6 scene_state_changed` handler 收任何非 DAILY_RECAP 目标 → 无条件 unregister(R-RCP-2):
```gdscript
func _on_scene_state_changed(from: SubMode, to: SubMode, ctx: Dictionary) -> void:
    if from == SubMode.DAILY_RECAP and to != SubMode.DAILY_RECAP:
        if InputHandler.has_skippable(&"daily_recap_skip"):
            InputHandler.unregister_skippable(&"daily_recap_skip")
```

---

## Out of Scope

- `#2 Input Handler` Story 004(skippable token registry **min_display_ms 参数实施**)
- Story 008: 帧预算 + dispatch ≤ 1 帧(本 story 仅 skip 路径)
- 月末守门具体 ctx.current_month 字段(由 propagation flag #6 同步)

---

## QA Test Cases

- **AC-ROBUST-01**: token 不泄漏
  - Given: 进入 DAILY_RECAP + 注册 token
  - When: 强制切 MORNING_BRIEFING(任意路径:skip / 超时 / GAMEOVER)
  - Then: `InputHandler.has_skippable(&"daily_recap_skip") == false`
  - Edge cases: _exit_tree 双保险 — 节点 queue_free 时 token 也被释放

- **AC-ROBUST-04**: 月末 W3/W4 守门
  - Given: ctx = `{is_weekly: true, current_month: 3, current_day: 22}`(W4),`min_display_ms = 1500`
  - When: t = 500ms 按 skip
  - Then: `recap_skipped` 信号挂起;t = 1500ms 时才 emit;玩家在挂起期间 effort 三行可见
  - Edge cases: ctx.current_month == 1(M1)→ min_display_ms = 0,即时 skip;ctx.current_day == 14(W2)→ 即时

- **AC-3**: M1/M2 全月即时
  - Given: ctx.current_month == 2,ctx.current_day == 28(虽然 day ≥ 15 但 month < 3)
  - When: 注册 skippable
  - Then: `min_display_ms == 0`

---

## Test Evidence

**Required evidence**: `tests/integration/recap_ui/skippable_late_month_1500ms_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001 + 002(Recap 触发);`#2 Input Handler` Story 004(skippable token registry **+ min_display_ms 实施**);`#6 Scene Flow` Story 002(scene_state_changed)
- Unlocks: epic 验收 — propagation flag #7 落地后此 story 全 AC 通过
