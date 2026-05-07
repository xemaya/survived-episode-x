# ADR-0017: NPC Relationship Schema + Formulas

## Status

Accepted

## Date

2026-05-02

## Last Verified

2026-05-02

## Decision Makers

technical-director / systems-designer / godot-gdscript-specialist
（实施先行,本 ADR 在 Sprint N+2 P0 fix 阶段对已落地代码追溯文档化）

## Summary

NPC Relationship 系统是 #8 GDD 的人际关系枢纽,涉及 8 NPC schema / 4 lifecycle 态状态机 / 5-tier RelationshipPhase 分类 / F3 leave_probability per-NPC 8 套参数 / 4 signal 单 owner / R-NPC-1..5 风险守 5 块技术决策。本 ADR 锁定已实施的 NPC 关系模型,使 RTM 2 个 TR(TR-npc-001/002)取得显式 ADR coverage,并把 LEFT 视觉屏蔽 / LEAVING_ANNOUNCED numeric_only / BOSS 永不离职 等红线明确化为 PR-blocking 守门。

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core(Gameplay 关系系统 / Pure GDScript 状态机 + Resource 配置层) |
| **Knowledge Risk** | LOW(int / Dictionary / StringName / Resource .tres 基础类型,无 post-cutoff API) |
| **References Consulted** | `design/gdd/npc-relationship-system.md` / `design/gdd/event-script-engine.md`(farewell flag) / `design/gdd/hud-diegetic.md`(LEFT 视觉屏蔽) |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | F3 leave_probability per-NPC 8 套参数单元测试 + 4 lifecycle transition test + R-NPC-1..5 守门测试 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(signal owner — `relationship_changed` / `relationship_phase_changed` / `npc_lifecycle_changed` / `npc_left_company` 4 signal 单 owner = #8)+ ADR-0003(`subsystems.npc_relationship` sub-schema 持久化)+ ADR-0005(`npc_empty_chairs` accumulation_event)+ ADR-0009(farewell_event flag 强制 numeric_only)+ ADR-0011(HUD R-NPC-2 视觉屏蔽 HUD_EMPTY_CHAIR variant) |
| **Enables** | architecture-review RTM 2 TR cover(TR-npc-001/002) |
| **Blocks** | None — 模型已 deployed |
| **Ordering Note** | Sprint N+2 P0 fix。实施先于 ADR — 本 ADR 是对 `src/npc/npc_relationship_system.gd`(~600 行)+ 8 personality `.tres`(`assets/data/npc_personalities/`)的追溯文档化。 |

## Context

### Problem Statement

architecture-review-report-2026-04-28 RTM 阶段识别 NPC Relationship 系统(#8 GDD)有 2 个 TR 缺失 ADR coverage(TR-npc-001 schema + lifecycle / TR-npc-002 F3 leave_probability per-NPC 8 套参数)。代码 `src/npc/npc_relationship_system.gd` 已落地约 600 行实施 + 8 personality `.tres` 配置已就位,但缺乏架构层面 ADR 锁定,导致:

1. 后续 sprint 改 leave_probability 参数 / 新增 NPC 时无 ADR refresher review
2. R-NPC-1..5 风险守门(LEFT-NPC reject / 状态可观察 / deterministic seed / BOSS 永不离职 / corruption 默认 ACTIVE)散落在代码注释,未文档化
3. LEFT 视觉屏蔽链 / LEAVING_ANNOUNCED numeric_only 强制 跨 #5 / #11 / #13 多处引用未集中

### Current State

- 8 NPC personality `.tres` 已落地:`lisa.tres / boss.tres / cleaning_aunt.tres / fish_monk.tres / grind_king.tres / old_oil.tres / newbie.tres / flatterer.tres`
- 4 lifecycle 状态机:`enum NPCLifecycle { ACTIVE, LEAVING_ANNOUNCED, LEFT, RETURNED }` 已实施 transition 表
- relationship_score 范围 [-100, +100] + per-NPC `flags: Dictionary[StringName, bool]` 已实施
- F3 leave_probability per-NPC 8 套参数已配置在各 `.tres` Resource(`leave_threshold_score / leave_probability_weight / leave_protected_until_month`)
- 4 signal 已 emit:`relationship_changed / relationship_phase_changed / npc_lifecycle_changed / npc_left_company`
- R-NPC-1..5 守门已运行时实施(assert + signal_ownership_lint),但未文档化为 PR-blocking

### Constraints

- 实施先行:不得改动 `src/npc/npc_relationship_system.gd` 或 8 personality `.tres` 数值参数
- 必须兼容 ADR-0001 4 signal 单 owner = #8 + signal_ownership_lint PR-blocking
- F3 leave_probability per-NPC 参数与 GDD `design/gdd/npc-relationship-system.md` §F3 一一对应
- LEFT 视觉屏蔽链(R-NPC-2)必须维持 ADR-0005(`npc_empty_chairs` 累积)+ ADR-0011(HUD_EMPTY_CHAIR variant)双 ADR 协同
- LEAVING_ANNOUNCED numeric_only 强制必须维持 ADR-0009 farewell_event flag 路径

### Requirements

- 8 NPC schema 完整记录(relationship_score + flags Dict + lifecycle_state + 5-tier RelationshipPhase)
- 4 lifecycle transition 表(ACTIVE → LEAVING_ANNOUNCED → LEFT;LEFT → RETURNED 仅 boss 例外)
- F3 leave_probability per-NPC 8 套参数 in-line 文档化 + 各 `.tres` Resource 引用
- 4 signal owner = #8 显式锁定(grep 验证 src/npc/ 内唯一 emit)
- R-NPC-1..5 风险守门 PR-blocking 双层守(运行时 assert + signal_ownership_lint + farewell_lint)
- Save sub-schema `subsystems.npc_relationship` 字段定义

## Decision

### 1. NPC Schema(8 NPC)

每个 NPC 由如下 schema 锁定:

```
NPCProfile (Resource extends Resource):
    npc_id: StringName              # LISA / BOSS / CLEANING_AUNT / FISH_MONK / GRIND_KING / OLD_OIL / NEWBIE / FLATTERER
    relationship_score: int          # [-100, +100], 初始值 0(BOSS = -10 默认敌意)
    flags: Dictionary[StringName, bool]  # per-NPC event-driven flags(如 lisa_lunch_attended / boss_overtime_complained)
    lifecycle_state: NPCLifecycle    # ACTIVE / LEAVING_ANNOUNCED / LEFT / RETURNED
    relationship_phase: RelationshipPhase  # 5-tier 派生 enum
    leave_threshold_score: int       # F3 阈值参数 per-NPC
    leave_probability_weight: float  # F3 权重参数 per-NPC
    leave_protected_until_month: int # F3 保护期 per-NPC(BOSS = INT_MAX 永不离职)
```

8 NPC `.tres` 文件位置:`assets/data/npc_personalities/{lisa, boss, cleaning_aunt, fish_monk, grind_king, old_oil, newbie, flatterer}.tres`。

### 2. 4 Lifecycle 状态机

```
                  │ run_started + corruption 默认 ACTIVE(R-NPC-5)
                  ▼
         ┌────────────────┐
         │     ACTIVE     │  正常工作态;relationship_changed 自由 emit
         └───────┬────────┘
                 │ F3 leave_probability 触发 + announce_leave_event 演完
                 ▼
         ┌────────────────────┐
         │ LEAVING_ANNOUNCED  │  道别期(1-3 天);farewell_event flag 强制 numeric_only
         └───────┬────────────┘
                 │ farewell_event 演完
                 ▼
         ┌────────────────┐         ┌────────────────┐
         │      LEFT      │ ──────► │    RETURNED    │  仅 boss 例外可回归
         └────────────────┘         └────────────────┘

每月 reset:仅 score 复算,lifecycle 不重置
LEFT 不可逆(除 boss → RETURNED 单一例外路径)
```

**R-NPC-4 守:BOSS 永不离职** — `leave_protected_until_month = INT_MAX`,F3 leave_probability 计算前先短路返回 0。

**R-NPC-5 守:corruption 默认 ACTIVE** — Save `subsystems.npc_relationship[npc].lifecycle_state` 反序列化失败时,fallback 到 ACTIVE(避免 LEFT 误持久化致玩家永久缺失 NPC)。

### 3. 5-tier RelationshipPhase 分类

`relationship_score` → `RelationshipPhase` 派生 enum(纯函数):

| Phase | Score 区间 | 含义 |
|-------|----------|------|
| `DEEP_FRIEND` | `[+60, +100]` | 深友 — Lisa 跳槽线触发条件之一 |
| `FRIEND` | `[+20, +59]` | 朋友 — 多数 event 善意分支 |
| `NEUTRAL` | `[-19, +19]` | 中性 — 默认起始 |
| `UNHAPPY` | `[-59, -20]` | 不快 — F3 leave_probability 开始计算 |
| `HOSTILE` | `[-100, -60]` | 敌对 — F3 高权重触发离职 |

`relationship_phase_changed(npc, old_phase, new_phase)` signal 在 phase 跨档时 emit(score 变化但同档不 emit,节流)。

### 4. F3 leave_probability per-NPC 8 套参数

```
F3  leave_probability(npc, month) =
        if month < npc.leave_protected_until_month:
            return 0.0
        if npc.relationship_score >= npc.leave_threshold_score:
            return 0.0
        score_gap = npc.leave_threshold_score - npc.relationship_score
        return clamp(score_gap × npc.leave_probability_weight × 0.01, 0.0, 0.95)
```

8 NPC 参数(已锁,基线值,定义在各 `.tres`):

| NPC | `leave_threshold_score` | `leave_probability_weight` | `leave_protected_until_month` | 备注 |
|-----|------------------------|---------------------------|-------------------------------|------|
| LISA | -20 | 1.5 | 3 | M3 后 Beta 必发跳槽线 |
| BOSS | -100 | 0.0 | INT_MAX | **R-NPC-4 永不离职**(短路返 0) |
| CLEANING_AUNT | -40 | 1.0 | 6 | 半年保护(默默奉献型) |
| FISH_MONK | -60 | 0.8 | 4 | 高阈值 + 低权重(摸鱼但难走) |
| GRIND_KING | -10 | 2.5 | 2 | 低阈值 + 高权重(易升职跳槽) |
| OLD_OIL | -50 | 1.2 | 5 | 中阈值(被优化路径) |
| NEWBIE | -30 | 1.8 | 2 | 短保护期(易劝退) |
| FLATTERER | -25 | 1.3 | 4 | 中等阈值(失宠后离开) |

公式实现位于 `src/npc/npc_relationship_system.gd::_compute_leave_probability(npc, month)`。

**R-NPC-3 守:deterministic seed** — leave_probability roll 用 `RandomNumberGenerator` 实例 seed = `month_index * 1000 + npc.npc_id.hash() % 1000`,保证月末复算一致(同 ADR-0016 KPI RNG 协议)。

### 5. 4 Signal Owner = #8 NPC(单 emitter 守)

| Signal | Owner | Subscribers | 触发条件 |
|--------|-------|-------------|---------|
| `relationship_changed(npc, delta, new_score, reason)` | #8 | #5 / #10 / #13 / #16 | score 变化 |
| `relationship_phase_changed(npc, old_phase, new_phase)` | #8 | #10 / #13 | phase 跨档 |
| `npc_lifecycle_changed(npc, old_state, new_state, reason)` | #8 | #5 / #10 / #11 / #13 / #15 / #19 | lifecycle 转移 |
| `npc_left_company(npc, reason)` | #8 | #5 / #10 / #13 / #16 / #19 | 进 LEFT 态 |

**ADR-0001 single-emitter 守门**:`tools/signal_ownership_lint.py` PR 阶段 grep `src/` 验证 4 signal 仅在 `src/npc/npc_relationship_system.gd` 内 `emit_signal()`,任何其他文件 emit → PR-blocking。

### 6. R-NPC-1..5 风险守门表

| Risk ID | 风险 | 守门 | 实施 |
|---------|------|------|------|
| **R-NPC-1** | LEFT-NPC 仍被 event 引用(reject) | `EventScriptEngine._validate_npc_target()` reject + push_warning;CI lint 静态扫描 event `.tres` 中 npc_id 与 LEFT 状态契合 | `tools/event_npc_lifecycle_lint.py` |
| **R-NPC-2** | LEFT 状态视觉不可观察 | HUD `NPCPosition` 切 `HUD_EMPTY_CHAIR` variant + emit `accumulation_event("npc_empty_chairs", +1)`(单 owner = #5)| ADR-0005 + ADR-0011 协同 |
| **R-NPC-3** | leave_probability 月末重算结果不一致 | RNG seed = `month * 1000 + npc_id.hash() % 1000`(deterministic) | `_compute_leave_probability()` 内 |
| **R-NPC-4** | BOSS 误触离职 | `leave_protected_until_month = INT_MAX` 短路返 0 | `boss.tres` |
| **R-NPC-5** | Save corruption 致 LEFT 持久化错误 | 反序列化失败 fallback `ACTIVE`(默认值)+ push_warning | `_load_subsystem()` 内 |

### 7. LEAVING_ANNOUNCED 期间 farewell_event 强制 numeric_only

LEAVING_ANNOUNCED 状态触发 `announce_leave_event` 后,该事件必须满足 ADR-0009 farewell_event flag 协议:

- `event.farewell_event = true`
- `dialogue_keys_*` 仅 1 个 = `EVENT.[event_id].TITLE_NUMERIC`
- 下游 4 GDD 守门:#13 禁 flash overlay / #15 仅一行 numeric_only key / #4 禁切 BGM / #5 禁特殊 palette swap

**FAREWELL_EVENT_IDS** 包含:`LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF / GRIND_KING_PROMOTED_LEAVE / OLD_OIL_OPTIMIZED_OUT`(VS 起 + `NEWBIE_LEAVE / FLATTERER_LEAVE`)。

`tools/farewell_lint.gd` PR 阶段比对 `#10 FAREWELL_EVENT_IDS` 与 `#8` LEAVING_ANNOUNCED transition 触发 event 一致。

### 8. Save Sub-schema 字段(`subsystems.npc_relationship`)

```json
{
  "LISA": {
    "score": 28,
    "flags": {"lisa_lunch_attended": true, "lisa_promo_overheard": false},
    "lifecycle_state": "ACTIVE"
  },
  "BOSS": {
    "score": -10,
    "flags": {},
    "lifecycle_state": "ACTIVE"
  },
  "CLEANING_AUNT": { ... },
  "FISH_MONK":     { ... },
  "GRIND_KING":    { ... },
  "OLD_OIL":       { ... },
  "NEWBIE":        { ... },
  "FLATTERER":     { ... }
}
```

跨 ADR 持久化责任:由 ADR-0003 Save schema cover。`relationship_phase` 不持久化(运行时纯函数派生)。

## Alternatives Considered

### Alternative 1: 单一全局 leave_probability(无 per-NPC 参数)

- **描述**:F3 公式只用一组参数(α / β / threshold),所有 NPC 共享
- **Pros**:实施简单 / 公式短
- **Cons**:无法表达 8 NPC 个性差异(GRIND_KING 低阈值高权重 vs FISH_MONK 高阈值低权重);Lisa 跳槽线 vs Boss 永不离职 无差异化通道
- **Rejection**:GDD §F3 + NPC profile §3 已 Approved per-NPC 8 套参数,本 ADR 仅追溯文档化

### Alternative 2: lifecycle 3 态(无 RETURNED)

- **描述**:仅 ACTIVE / LEAVING_ANNOUNCED / LEFT,不支持回归
- **Pros**:状态机更简单,LEFT 真正不可逆
- **Cons**:Boss 特殊路径(被解雇后剧情触发回归)无法表达;VS 阶段扩展 NPC 回归剧情困难
- **Rejection**:RETURNED 仅 boss 例外路径,代码已实施;保留 transition 通道

### Alternative 3: relationship_score 范围 [0, 100]

- **描述**:不允许负分,关系仅累加正面
- **Pros**:范围更直观
- **Cons**:无法表达敌对态(HOSTILE phase);Pillar 4 反英雄 tone 要求负面关系真实存在(被讨厌 ≠ 中性)
- **Rejection**:[-100, +100] 已 Approved 在 GDD §3.1

### Alternative 4: 4 signal 合并为 1 个 npc_event 总线

- **描述**:`npc_event(npc, event_type, payload)` 单 signal 替代 4 个
- **Pros**:订阅端少 1 个 connect 调用
- **Cons**:类型化 payload 弱化(Dictionary)、违反 ADR-0001 单 owner 一信号一意图原则、subscribers 需 if/else 分支增加 boilerplate
- **Rejection**:ADR-0001 已锁 signal 拆分原则

## Consequences

### Positive

- 2 个 TR 取得显式 ADR coverage(TR-npc-001/002)
- 8 NPC schema + F3 per-NPC 参数集中文档化,跨 GDD #8 / #10 / #11 引用一致
- R-NPC-1..5 风险守门 PR-blocking 双层守(runtime + lint)
- LEFT 视觉屏蔽链(ADR-0005 + ADR-0011)+ farewell_event 链(ADR-0009)显式 cross-ADR 引用,后续 sprint 改动有 refresher 入口

### Negative

- 实施先行 → ADR 与 8 personality `.tres` 数值若漂移,文档版本需手动同步(Mitigation:`/architecture-review` 阶段对照 grep 各 `.tres`)
- F3 per-NPC 参数 tuning 改动后需更新本 ADR §4 表格 + GDD §F3,2 处同步

### Neutral

- BOSS `leave_protected_until_month = INT_MAX` 是 R-NPC-4 红线 — 文档中明确解释,避免后续 sprint "为剧情灵活性放开"误改
- `relationship_phase` 不持久化(派生)是 design 决策 — Save 体积节约,代码运行 phase 跨档 emit 在反序列化后由 score → phase 派生触发

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| F3 per-NPC 参数 tuning 改动后 deterministic seed test 失效 | LOW | MEDIUM | tests/unit/npc/ 包含 leave_probability 边界 test;CI 强制跑 |
| 新增 NPC(VS 阶段)未补 personality `.tres` | MEDIUM | LOW | `tools/npc_registry_lint.py` 验证 8 NPC `.tres` 完整(按 NPC_REGISTRY enum) |
| LEFT 状态 corruption 致永久 NPC 缺失 | LOW | HIGH | R-NPC-5 反序列化 fallback ACTIVE + push_warning(已实施) |
| 实施代码与 ADR 漂移 | MEDIUM | MEDIUM | `/propagate-design-change` 在 GDD #8 改动时强制 ADR refresh |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU(月末 leave_probability 8 NPC roll)| ~0.1ms | ~0.1ms | ≤ 0.5ms |
| Memory(8 NPC state Dictionary)| ~3KB | ~3KB | ≤ 8KB |
| Load Time(8 personality `.tres` 启动加载)| ~2ms | ~2ms | ≤ 10ms |

## Migration Plan

无迁移 — 实施已 deployed。本 ADR 仅追溯文档化:

1. 已实施:8 NPC personality `.tres`
2. 已实施:4 lifecycle 状态机
3. 已实施:F3 per-NPC leave_probability
4. 已实施:5-tier RelationshipPhase 派生
5. 已实施:4 signal emit + ADR-0001 single-emitter 守
6. 待引入(Sprint N+2):`tools/event_npc_lifecycle_lint.py` + `tools/npc_registry_lint.py`
7. 待更新(本 ADR 同 commit):`tr-registry.yaml` 2 TR adr_coverage append `[adr-0017]`

**Rollback plan**:文档级 ADR,无可 rollback 风险。如发现 F3 公式错误,issue 单独 ADR 修订(deprecate 0017 → 新 ADR)。

## Validation Criteria

- [ ] `tr-registry.yaml` 2 TR(npc-001/002)`adr_coverage` 含 `adr-0017`
- [ ] `tools/signal_ownership_lint.py` 验证 4 signal 仅 `src/npc/npc_relationship_system.gd` emit(PASS)
- [ ] `tools/farewell_lint.gd` 验证 LEAVING_ANNOUNCED transition event_id ⊂ FAREWELL_EVENT_IDS(PASS)
- [ ] 单元测试 `tests/unit/npc/test_leave_probability_per_npc.gd` 覆盖 8 NPC F3 边界
- [ ] 单元测试 `tests/unit/npc/test_lifecycle_transitions.gd` 覆盖 R-NPC-4(BOSS)+ R-NPC-5(corruption fallback)
- [ ] `/architecture-review` 重跑 RTM,#8 GDD 5 TR 0 gap

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/npc-relationship-system.md` §3.1 | NPC Relationship | "8 NPC relationship_score [-100, +100] + per-NPC flags Dict" | NPCProfile schema 锁定 + 8 `.tres` 引用 |
| `design/gdd/npc-relationship-system.md` §3.2 | NPC Relationship | "4 lifecycle 态(ACTIVE/LEAVING_ANNOUNCED/LEFT/RETURNED)" | 状态机 transition 表 + R-NPC-4/5 守 |
| `design/gdd/npc-relationship-system.md` §3.3 | NPC Relationship | "5-tier RelationshipPhase 分类" | DEEP_FRIEND/FRIEND/NEUTRAL/UNHAPPY/HOSTILE 区间表 |
| `design/gdd/npc-relationship-system.md` §F3 | NPC Relationship | "F3 leave_probability per-NPC 8 套参数" | 8 NPC 参数表 + deterministic seed 协议 |
| `design/gdd/npc-relationship-system.md` §4 | NPC Relationship | "LEFT 视觉屏蔽 R-NPC-2" | ADR-0005 npc_empty_chairs + ADR-0011 HUD_EMPTY_CHAIR 协同引用 |

## Related

- ADR-0001 Signal Ownership Matrix(4 NPC signal 单 owner = #8)
- ADR-0003 Save Format(`subsystems.npc_relationship` sub-schema 持久化)
- ADR-0005 Lighting Accumulation Dimensions(`npc_empty_chairs` 累积维度)
- ADR-0006 Dismissal/GAMEOVER Path(LEAVING_ANNOUNCED 不直 GAMEOVER)
- ADR-0009 Event Schema Format(farewell_event flag 强制 numeric_only)
- ADR-0011 HUD Diegetic Render(HUD_EMPTY_CHAIR variant + R-NPC-2 视觉屏蔽)
- ADR-0015 AP Economy State + Formulas(同期实施 P0 fix)
- ADR-0016 KPI Reverse Threshold Formulas + RNG(deterministic seed 协议共享)
- `src/npc/npc_relationship_system.gd`(~600 行实施)
- `src/npc/npc_profile.gd`(NPCProfile Resource 定义)
- `assets/data/npc_personalities/{lisa, boss, cleaning_aunt, fish_monk, grind_king, old_oil, newbie, flatterer}.tres`(8 personality)
- `tools/event_npc_lifecycle_lint.py`(Sprint N+2 引入)
- `tools/npc_registry_lint.py`(Sprint N+2 引入)
