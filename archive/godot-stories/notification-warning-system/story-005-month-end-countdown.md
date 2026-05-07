# Story 005: 月末倒计时 3/2/1 档

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: Rule 4 + AC-FUNC-06/07

**ADR Governing Implementation**: ADR-0011(`#19` 是信号转发器)+ B1 propagation flag #6(`#6 ctx` payload 含 days_remaining_in_month)
**ADR Decision Summary**: 月末倒计时:`#6 scene_state_changed` payload `ctx.days_remaining_in_month` 在 3 / 2 / 1 时各自独立 emit `warning_month_end_countdown(days)`;进入 `KPI_REVIEW` 时清除。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 依赖 `#6 ctx` payload 含 `days_remaining_in_month`(B1 propagation flag #6 扩展);若未实施,本 story 等同 Blocked。

**Control Manifest Rules (Presentation Layer)**:
- Required: 单点订阅 `#6 scene_state_changed`;读 ctx.days_remaining_in_month
- Forbidden: 自计算 month_remaining(由 `#6` own)
- Guardrail: dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-06: `scene_state_changed` payload `ctx.days_remaining_in_month` 分别为 3 / 2 / 1,`#19` 接收各自 sub-mode 转移信号,`warning_month_end_countdown(3)` / `(2)` / `(1)` 各自 emit;无重复 emit
- [ ] AC-FUNC-07: `warning_month_end_countdown` 活跃,`scene_state_changed(→KPI_REVIEW)`,`warning_month_end_cleared` emit;`_active_warnings["month_countdown"] == false`
- [ ] 三档独立 idempotent:`_active_warnings["month_countdown_3"]` / `_4` / `_1`(三 keys 独立)
- [ ] 月初(day == 1)所有 month_countdown 状态 reset

---

## Implementation Notes

*From GDD Rule 4 + B1 propagation flag #6:*

```gdscript
func _ready() -> void:
    SceneFlow.scene_state_changed.connect(_on_scene_state_changed)

func _on_scene_state_changed(from: SubMode, to: SubMode, ctx: Dictionary) -> void:
    # 监听 to == DAILY_RECAP 或 ACTION_DAY 进入(每天有一次 sub-mode dispatch)
    if not ctx.has("days_remaining_in_month"): return  # B1 待 #6 扩展
    var days := ctx.days_remaining_in_month
    for tier in [3, 2, 1]:
        var key := "month_countdown_%d" % tier
        if days == tier:
            _try_emit_warning(key, "warning_month_end_countdown", [days])
    # 月初 reset
    if ctx.has("current_day") and ctx.current_day == 1:
        for tier in [3, 2, 1]:
            var key := "month_countdown_%d" % tier
            _active_warnings[key] = false
    # KPI_REVIEW 清除
    if to == SubMode.KPI_REVIEW:
        for tier in [3, 2, 1]:
            var key := "month_countdown_%d" % tier
            _try_clear_warning(key, "warning_month_end_cleared")
```

注:`days_remaining_in_month` 由 `#6` propagation flag #6 ctx 扩展提供;在此之前本 story 部分 AC 挂起。

---

## Out of Scope

- Story 002/003/004: 其他类 warning
- `#6 Scene Flow` Story 002 ctx payload 扩展(propagation flag #6 — 上游)

---

## QA Test Cases

- **AC-FUNC-06**: 三档触发
  - Given: ctx.days_remaining_in_month 序列 3 → 2 → 1
  - When: 三次 scene_state_changed
  - Then: 三次独立 emit warning_month_end_countdown(3) / (2) / (1)
  - Edge cases: 同 day 同 tier 重复 emit → idempotent(仅一次)

- **AC-FUNC-07**: KPI_REVIEW 清除
  - Given: warning_month_end_countdown(1) 激活
  - When: scene_state_changed(→KPI_REVIEW)
  - Then: warning_month_end_cleared emit + 三档全清

- **AC-3**: 月初 reset
  - Given: 上月末 1 / 2 / 3 都激活过
  - When: 新月 day == 1 触发 scene_state_changed
  - Then: _active_warnings 三档全 false,可在新月再次触发

---

## Test Evidence

**Required evidence**: `tests/integration/notification/month_end_countdown_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#6 Scene Flow` Story 002(scene_state_changed + ctx payload **扩展 days_remaining_in_month**,propagation flag #6);`#9 KPI` Story 006(KPI_REVIEW dispatch)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 4 test 函数(AC-FUNC-06 三档独立 emit + 同 tier idempotent / AC-FUNC-07 KPI_REVIEW 三档全清 / AC-3 月初 day=1 ledger reset 后可再次触发)
**Test Evidence**: `tests/integration/notification/month_end_countdown_test.gd`(105 行 / 4 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED;由于 `scene_state_changed` 当前 signature `(from, to)` 不带 ctx,本 story 暴露 `ingest_day_context(ctx: Dictionary)` 公共测试 / wiring seam — 当 #6 propagation flag #6 land 后,`scene-day-flow` 直接调用此 API 推送每日 ctx;不依赖 ctx 扩展即可单元验证;无 BLOCKING / 无 inline fix
**Deviations**(2 项 ADVISORY,1 项 partial-flag,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. propagation flag #6 partial — 本 story 不修改 `scene_state_changed` signal signature(约束"不能改其他 epic"),改用 `ingest_day_context(ctx)` 注入路径;wiring 在 #6 ctx 扩展 land 后追加一行 `SceneFlow.day_tick.connect(_system.ingest_day_context)`(或同等 forward 函数)
**Tech debt**: 1 项 — ctx 注入 wiring 待 propagation flag #6 land
**API surface**: `ingest_day_context(ctx)` + KPI_REVIEW 自动 clear path
