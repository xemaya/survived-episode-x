# Story 005: try_play_card 7-Step Chain (Cross-System Backbone)

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-001` + `TR-card-004`
**ADR**: architecture.md L177-191 单卡完整链
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 7 步链 — (1) 守门 (2) AP consume (3) game-time tick (4) NPC update (5) KPI report (6) event trigger (7) UI render
- Guardrail: 7 步同帧 16.6ms 预算分摊;重负载 call_deferred(R-SDF-3)

## Acceptance Criteria

- [ ] `try_play_card(card_id: StringName) -> bool` API:7 步顺序执行
- [ ] **Step 1** 守门:Card.lifecycle_allowed / cooldown / mutex / AP 不足 → 失败 false
- [ ] **Step 2** APEconomy.try_consume_ap(amount) → 失败 false
- [ ] **Step 3** emit ap_consumed → SceneFlow Story 011 game_time +60min(基于 AP cost × 60min)
- [ ] **Step 4** NPCRelationshipSystem.update_relationship(npc, delta, reason)(若 target_npc)
- [ ] **Step 5** emit kpi_contribution_reported → KPI Story 013 actual_kpi 累加
- [ ] **Step 6** EventScriptEngine.trigger_card_event(card_id) → emit event_started(card_id, narrative_tier)
- [ ] **Step 7** #14 Card Play UI 接 event_started → 渲染对应 density

## Implementation Notes

```gdscript
func try_play_card(card_id: StringName) -> bool:
    var card := _get_card(card_id)
    if card == null:
        return false
    # Step 1: guard
    if not _can_play(card):
        return false
    # Step 2: AP consume
    if not APEconomy.try_consume_ap(card.ap_cost):
        return false
    # Step 3 & 4 & 5 & 6:
    emit_signal(&"card_played", card_id)
    if card.target_npc != &"":
        NPCRelationshipSystem.update_relationship(card.target_npc, _calc_delta(card), "card:" + str(card_id))
    if card.kpi_delta != 0.0:
        emit_signal(&"kpi_contribution_reported", card.kpi_delta)
    EventScriptEngine.trigger_card_event(card_id)
    # Step 7: UI render(由 #14 订阅 event_started 自处理)
    _on_card_played(card)  # Story 004 mutex / hero counter
    return true
```

## QA Test Cases

- 7 步顺序日志(自动化 perf test 验证 16.6ms 内完成)
- Step 1 失败(LEFT NPC / mutex locked)→ 后续 step 不执行

## Test Evidence

`tests/integration/card/try_play_card_chain_test.gd`(协作 AP / NPC / KPI / Event Script / UI stories)

## Dependencies

- Depends on: Story 001-004 + AP Story 001/010 + NPC Story 005 + KPI Story 013 + Event Script Story 007
- Unlocks: 整个游戏 gameplay loop

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 7/7 COVERED via 7 test 函数
**Test Evidence**: `tests/integration/card/try_play_card_chain_test.gd` (215 行 / 7 tests / GdUnit4) — 覆盖全链成功 / Step 2 AP 失败短路 / Step 1 NPC LEFT 守门 / 无 target_npc 跳 Step 4 / kpi=0 跳 Step 5 / Step 6 emit_event_started 锁定密度 / 未注册 card_id 拒绝 — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);try_play_card 主线程同步 7-step,守门先于副作用,失败无副作用;Step 6 复用 EventScriptEngine.emit_event_started(card) — Card 派生 EventResource 直接传;Step 7 mutex/hero 记账后 emit card_played → hero_card_played (顺序固定);无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. Step 3 SceneFlow game_time tick 由 AP system 内部 emit ap_consumed 驱动,本 epic 不直接 emit — 与 architecture.md L177-191 协议一致
**Tech debt**: None new
**API surface**: `try_play_card(card_id: StringName) -> bool` + `bind_ap_economy / bind_npc_system / bind_event_engine` + `register_card / index_cards / get_card` + signal `card_play_rejected(card_id, reason)`
