# Story 003: ONBOARDING tier 5 NPC hint(`#10 Rule 17` 第 5 档)

> **Epic**: Tutorial / Onboarding System
> **Status**: Blocked — VS tier ADR pending(同 Story 002)
> **Layer**: Feature
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: `TR-tutorial-002`(NPC hint 部分)

**ADR Governing Implementation**: 待撰写 — `tutorial-day-1-3-hint-api`(VS milestone)+ ADR-0001(信号架构)
**ADR Decision Summary**: ONBOARDING tier 5 NPC hint 继承 `#10 Rule 17` 4 档预言(EFFORT_HIGH / POTENTIAL_HIGH / TENURE_LONG / TENURE_VETERAN)+ 新增第 5 档 `ONBOARDING`(老油条对新人 Day 1-3 的入职指路)。`#10` `kpi_prediction_hint` 信号被复用,`hint_type = ONBOARDING` 触发 NPC 台词池。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 同 `#10` Story 011 主语翻转。

**Control Manifest Rules (Feature Layer)**:
- Required: 复用 `#10 Rule 17` hint_type 枚举扩展 + `kpi_prediction_hint(ONBOARDING)` 触发
- Forbidden: 创建独立 onboarding 信号(违反 `#10` own 信号源)
- Guardrail: hint emit 到 NPC flash overlay 显示 ≤ 100ms

---

## BLOCKED Reason

同 Story 002 — VS milestone ADR pending。

---

## Acceptance Criteria

- [ ] AC-FUNC-04: Day 2,玩家打出第 1 张 2-AP 卡后,老油条 `HINT_ONBOARDING_DAY2` flash 事件在 ≤ 500ms 内触发
- [ ] `#10` HintType enum 扩展第 5 档 `ONBOARDING`(原 4 档:EFFORT_HIGH / POTENTIAL_HIGH / TENURE_LONG / TENURE_VETERAN)
- [ ] ONBOARDING 台词池:`NPC.OLD_OIL.ONBOARDING_DAY1` / `_DAY2` / `_DAY3`(Day 1-3 各 1 条入职指路)
- [ ] hint 触发条件:Day 1 启动 / Day 2 第 1 张 2-AP 卡 / Day 3 手牌出现 Lisa 卡(详细条件由 OQ-TUT-03 决定)

---

## Implementation Notes

*From GDD Rule 3(VS):*

`#10` HintType enum 扩展(VS milestone 在 `#10` GDD revision 同步):
```gdscript
enum HintType { EFFORT_HIGH, POTENTIAL_HIGH, TENURE_LONG, TENURE_VETERAN, ONBOARDING }
```

TutorialState 触发逻辑:
```gdscript
func _on_action_card_played(card_id: String, day_index: int) -> void:
    if _state != State.TUT_ACTIVE_DAY13: return
    if day_index == 2 and not _day2_hint_emitted:
        if APEconomy.last_card_cost == 2:
            _emit_onboarding_hint("HINT_ONBOARDING_DAY2")
            _day2_hint_emitted = true

func _emit_onboarding_hint(hint_id: String) -> void:
    KPI.emit_signal("kpi_prediction_hint", "old_oil_npc", HintType.ONBOARDING, hint_id)
    # `#10 Event Script` 监听 → flash event → `#14 Card Play UI` 渲染 ≤ 100ms
```

VS milestone ADR 须明确:
- Day 1 / Day 2 / Day 3 各自具体 trigger 条件
- HINT_ONBOARDING_DAY2 是否绑定特定 card ID 或 cost
- `#10 Rule 17` 4 档 + 1 档 ONBOARDING 的优先级(同帧多触发器仲裁)

---

## Out of Scope

- Story 002: fixed_hand_override(本 story 假设 day 1-3 已注入)
- Story 004: inject_onboarding_hint API(本 story 用直接 emit kpi_prediction_hint)
- `#10 Event Script` Story 003(abstract event effect)+ `#14 Card Play UI`(flash overlay 渲染)

---

## QA Test Cases

- **AC-FUNC-04**: Day 2 hint timing
  - Given: TutorialState._state == TUT_ACTIVE_DAY13,day_index == 2,_day2_hint_emitted == false
  - When: ActionCard 打出 2-AP 卡(emit card_played 信号)
  - Then: ≤ 500ms 内 KPI 触发 kpi_prediction_hint(ONBOARDING) → `#14 Card Play UI` flash overlay 显示
  - Edge cases: 1-AP / 3-AP 卡 → 不触发(只测 2-AP);连续打 2-AP 卡 → 仅第一次触发(_day2_hint_emitted idempotent)

- **AC-2**: HintType enum 扩展
  - Given: `#10 KPI` HintType enum
  - When: 反射
  - Then: 5 个值(原 4 + ONBOARDING)

---

## Test Evidence

**Required evidence**: `tests/integration/tutorial/onboarding_tier_5_npc_hint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001;`#10 Event Script` Story 011(主语翻转 8 master);`#9 KPI` Story 011(kpi_prediction_hint 4 档框架);`#11 Action Card` Story 006(card_played signal);**VS tier ADR**
- Unlocks: Story 004
