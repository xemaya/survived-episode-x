# Story 002: Day 1-3 fixed_hand_override 协议

> **Epic**: Tutorial / Onboarding System
> **Status**: Blocked — VS tier ADR pending(`tutorial-day-1-3-hint-api`)
> **Layer**: Feature
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: `TR-tutorial-002`

**ADR Governing Implementation**: 待撰写 — `tutorial-day-1-3-hint-api`(VS milestone 启动前)
**ADR Decision Summary**: `#11 Action Card` Day 1-3 抽牌逻辑被 `TutorialState.fixed_hand_override` 覆写,Day 1-3 各自固定 3 张卡;Day 4+ 回归 `#11` 默认抽牌。`DAY1_FIXED_HAND` / `DAY2_FIXED_HAND` / `DAY3_FIXED_HAND` 由 Tuning Knobs 配置。

**Engine**: Godot 4.6 | **Risk**: LOW(基础 Dictionary lookup)
**Engine Notes**: 无引擎风险。

**Control Manifest Rules (Feature Layer)**:
- Required: `#11` 抽牌入口检查 TutorialState.fixed_hand_override();覆写仅 Day 1-3 + tutorial_completed == false
- Forbidden: 直接修改 `#11` 卡池常量(违反层边界,#11 own 默认池)
- Guardrail: 抽牌路径 < 0.5ms

---

## BLOCKED Reason

VS milestone 启动前须撰写 ADR `tutorial-day-1-3-hint-api`,定义 fixed_hand_override + inject_onboarding_hint() API 详细实施方案。

---

## Acceptance Criteria

- [ ] AC-FUNC-01: Day 1 启动后,手牌池仅包含 `DAY1_FIXED_HAND` 定义的 3 张卡,不含任何其他卡
- [ ] AC-FUNC-02: Day 3 结束后(`day_index == 4`),手牌池回归 `#11` 正常抽牌逻辑,不再包含任何 Day 1-3 固定手牌 card ID
- [ ] AC-FUNC-08(部分): `tutorial_completed = true` 的 Run,Day 1-3 不注入固定手牌
- [ ] DAY1/2/3_FIXED_HAND 由 entities.yaml Tuning Knobs(VS milestone 注册)配置

---

## Implementation Notes

*From GDD Rule 2(VS):*

```gdscript
# TutorialState.gd
const DAY1_FIXED_HAND := ["CARD_REPLY_EMAIL", "CARD_OFFICE_GOSSIP", "CARD_SLACK_OFF"]
const DAY2_FIXED_HAND := ["CARD_REPLY_EMAIL", "CARD_OVERTIME_BAIT_2AP", "CARD_LUNCH_LISA"]
const DAY3_FIXED_HAND := ["CARD_REPLY_EMAIL", "CARD_OVERTIME_BAIT_2AP", "CARD_LISA_FACEOFF"]

func fixed_hand_override(day_index: int) -> Array[String]:
    if _state != State.TUT_ACTIVE_DAY13: return []
    match day_index:
        1: return DAY1_FIXED_HAND.duplicate()
        2: return DAY2_FIXED_HAND.duplicate()
        3: return DAY3_FIXED_HAND.duplicate()
        _: return []

# #11 Action Card 抽牌入口
func get_today_hand(day_index: int) -> Array[String]:
    var override := TutorialState.fixed_hand_override(day_index)
    if not override.is_empty():
        return override
    return _draw_default_hand()  # 默认逻辑
```

VS milestone ADR 须明确:
- DAY1/2/3 卡 ID 与 narrative-director 协同定义
- 玩家在 Day 1-3 之间换 Run,fixed_hand_override 仍生效
- Day 1-3 内的"复用"防呆(每天 3 张全部新发,不基于上日)

---

## Out of Scope

- Story 001: TutorialState 状态机
- Story 003: ONBOARDING NPC hint
- `#11 Action Card` Story 001/004(默认卡池主体)

---

## QA Test Cases

- **AC-FUNC-01**: Day 1 fixed
  - Given: TutorialState._state == TUT_ACTIVE_DAY13,day_index == 1
  - When: ActionCard.get_today_hand(1)
  - Then: 返回的 Array 等于 DAY1_FIXED_HAND(3 张全匹配)
  - Edge cases: day_index 越界(0 或 4)→ 走默认抽牌

- **AC-FUNC-02**: Day 4 回归默认
  - Given: day_index == 4
  - When: get_today_hand(4)
  - Then: 不含 DAY1/2/3 固定手牌任意 card ID(grep 测试断言)

- **AC-FUNC-08**: tutorial_completed 路径
  - Given: TutorialState._state == TUT_COMPLETED(per Story 001)
  - When: ActionCard.get_today_hand(1)
  - Then: 走默认抽牌,不返回 DAY1_FIXED_HAND

---

## Test Evidence

**Required evidence**: `tests/integration/tutorial/day_1_3_fixed_hand_override_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(TutorialState autoload + 状态机);`#11 Action Card` Story 001(card_schema_derived)+ Story 005(try_play_card 七步);**VS tier ADR `tutorial-day-1-3-hint-api`**
- Unlocks: 无
