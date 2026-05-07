# ADR-0015: AP Economy State Machine + Formulas

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

AP 经济是 #7 GDD 的核心计算枢纽,涉及 4 态状态机 / cost 分布 lint / 三维度 effort 权重 / F1-F5 公式 / capacity_factor 单调红线 5 块技术决策。本 ADR 锁定已实施的 AP 经济模型,使 RTM 5 个 TR(TR-ap-001/002/003/007/008)取得显式 ADR coverage,并把 Anti-P1(capacity 单调)红线明确化为 PR-blocking 守门。

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core(Gameplay 经济计算 / Pure GDScript 算法层) |
| **Knowledge Risk** | LOW(纯算法 + Dictionary / int / float 基础类型,无 post-cutoff API) |
| **References Consulted** | `design/gdd/ap-economy-system.md` / `design/gdd/kpi-reverse-threshold-system.md`(capacity 共享模型) |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | F1-F5 单元测试 + capacity_factor 单调性 unit test + cost 1/2/3 分布 lint Python 静态扫描 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(signal owner — `monthly_effort_summary` / `ap_changed` 单 owner = #7)+ ADR-0003(meta.run_ended 持久化串联 R-AP-2)+ ADR-0006(dismissal_pending → game_over 路径 — AP DEPLETED 不直接 GAMEOVER) |
| **Enables** | architecture-review RTM 5 TR cover(TR-ap-001/002/003/007/008)+ ADR-0016(KPI capacity 衰减模型共享 α/β/γ 参数) |
| **Blocks** | None — 模型已 deployed |
| **Ordering Note** | Sprint N+2 P0 fix。实施先于 ADR — 本 ADR 是对 `src/ap_economy/ap_economy_system.gd`(710 行)的追溯文档化。 |

## Context

### Problem Statement

architecture-review-report-2026-04-28 RTM 阶段识别 AP 经济系统(#7 GDD)有 5 个 TR 缺失 ADR coverage(TR-ap-001 状态机 / TR-ap-002 cost 分布 / TR-ap-003 effort 三维度 / TR-ap-007 F1-F5 公式 / TR-ap-008 capacity 单调红线)。代码 `src/ap_economy/ap_economy_system.gd` 已落地约 710 行实施,但缺乏架构层面 ADR 锁定,导致:

1. 后续 sprint 改 effort 权重 / capacity 衰减系数时无 ADR refresher review
2. Anti-P1 红线(capacity_factor / capacity_floor 单调递减)无 PR-blocking 文档,容易 regress
3. F1-F5 公式定义散落在 GDD,跨 #7 / #9 / #11 多处引用未集中

### Current State

- 状态机:`enum APState { NORMAL, OVERTIME_AVAILABLE, OVERTIME_ACTIVE, DEPLETED }` 已 4 态 + transition 表已实施(ap_economy_system.gd)
- F1-F5 公式:已实施;`monthly_effort_summary` signal 已 emit
- capacity_factor 衰减:`α = 0.04 / β = 0.18 / γ = 0.012` 已落地
- Cost 1/2/3 分布:Python 静态 lint 工具尚缺 — 仅 GDD §4.2 写明 40/40/20 比例
- Anti-P1 红线:运行时 `assert(capacity_factor_next <= capacity_factor_curr)` 已守,但未文档化为 PR-blocking

### Constraints

- 实施先行:不得改动 `src/ap_economy/ap_economy_system.gd` 数值参数或算法行为
- 必须兼容 #9 KPI 月末结算 capacity 共享模型(ADR-0016 同时落地)
- F1-F5 公式与 GDD `design/gdd/ap-economy-system.md` §F 一一对应,不重定义
- Anti-P1 红线必须升级为 PR-blocking(双层守:运行时 assert + Python 静态 lint)

### Requirements

- 4 态状态机 transition 表完整记录(NORMAL ↔ OVERTIME_AVAILABLE ↔ OVERTIME_ACTIVE → DEPLETED)
- F1-F5 公式 in-line 定义(daily_ap_cap / overtime_pool / effort_per_card / monthly_effort / capacity_factor)
- 三维度 effort 权重锁定 0.45 / 0.20 / 0.30(KPI research deviation 已仲裁)
- capacity 衰减参数 α=0.04 / β=0.18 / γ=0.012(基线;tutorial month γ_effective=0)
- Anti-P1 红线 PR-blocking — Python lint `tools/anti_p1_capacity_lint.py` 静态守门 + 运行时 assert 双层

## Decision

### 1. AP 4 态状态机

```
                 │ start day
                 ▼
        ┌────────────────┐
        │     NORMAL     │  current_ap > overtime_threshold
        └───────┬────────┘
                │ current_ap == overtime_threshold(默认 2)
                ▼
        ┌────────────────────┐
        │ OVERTIME_AVAILABLE │  玩家可主动选择加班
        └───────┬────────────┘
                │ confirm_overtime() 或自动越线
                ▼
        ┌────────────────────┐
        │  OVERTIME_ACTIVE   │  energy 扣除 + 当日不可回退
        └───────┬────────────┘
                │ current_ap == 0 + 加班池耗尽
                ▼
        ┌────────────────┐
        │    DEPLETED    │  当日强制 end_of_day(不直接 GAMEOVER)
        └────────────────┘

每日 reset:NORMAL ← (任意态) when day_started signal 触发
weekend_rest_day:energy +30(直达 NORMAL,跳过 OVERTIME)
```

DEPLETED **不**直接触发 GAMEOVER(GAMEOVER Path B 走 ADR-0006 dismissal_pending → KPI #9 emit `game_over_triggered`)。DEPLETED 仅强制当日 `end_of_day` 转 NIGHT sub-mode。

### 2. F1-F5 公式定义

```
F1  monthly_effort_total = Σ(card_effort × hero_multiplier × capacity_factor)
F2  daily_ap_cap         = base_ap(8) - tenure_penalty(F4)
F3  effort_per_card      = e_focused × 0.45 + e_breadth × 0.20 + e_finesse × 0.30
F4  tenure_penalty       = floor(month_index × γ_effective)  # γ=0.012
F5  capacity_factor(t+1) = capacity_factor(t) × (1 - α × overtime_count(t))
                         × (1 - β × hero_streak(t))
                         clamped to [capacity_floor, 1.0]
```

参数(已锁,基线值):
- `α = 0.04`(overtime 衰减)
- `β = 0.18`(hero streak 衰减)
- `γ = 0.012`(tenure penalty 月度系数)
- `capacity_floor = 0.55`(下界,防 capacity 跌穿致永久不可逆)
- `tutorial_months: γ_effective = 0`(M1 tutorial 不计 tenure penalty,见 ADR-0003 sub-schema)

公式实现位于 `src/ap_economy/ap_economy_system.gd`:
- `_compute_effort_per_card()` → F3
- `_compute_daily_ap_cap()` → F2 + F4
- `_apply_capacity_decay()` → F5
- `_aggregate_monthly_effort()` → F1
- 月末 emit `monthly_effort_summary(effort_total: float, breakdown: Dictionary)` 给 #9 KPI 系统消费

### 3. AP Cost 1/2/3 分布 Lint

每个 ActionCard `cost` ∈ {1, 2, 3}。设计目标分布:
- cost = 1:40% ± 5%
- cost = 2:40% ± 5%
- cost = 3:20% ± 5%

**实施**:
- 运行时 cost 校验:`assert(card.cost in [1, 2, 3])` 在 `ActionCardLoader._validate()` 中
- Python 静态 lint(`tools/anti_p1_card_cost_lint.py`):扫描 `assets/data/cards/*.tres` 统计分布,偏离 ±5% 阈值 PR-blocking

### 4. 三维度 Hero Card Effort 权重

Hero Card 的 effort 由 3 个维度合成(GDD §F3 + KPI research deviation §3 仲裁后已锁):

| 维度 | 权重 | 含义 |
|------|------|------|
| `e_focused` | **0.45** | 专注度 — 单点深度产出 |
| `e_breadth` | **0.20** | 广度 — 跨任务覆盖 |
| `e_finesse` | **0.30** | 精度 — 减少返工 |

权重和 = 0.95(剩余 0.05 留给 future variant 扩展空间;**不 normalize 到 1.0**,这是与 KPI research §3 仲裁后保留的 5% buffer,对应 hero card "novelty bonus"))。

### 5. capacity_factor / capacity_floor 单调红线(Anti-P1 守门)

**Anti-P1 红线**(P1 = 玩家死循环 / 永久不可逆惩罚):capacity_factor 必须**单调非递增**且**有下界 capacity_floor**。

**双层守门**:

#### 5.1 运行时 assert(`ap_economy_system.gd::_apply_capacity_decay()`)

```gdscript
func _apply_capacity_decay(prev: float, overtime: int, streak: int) -> float:
    var next_value: float = prev * (1.0 - alpha * overtime) * (1.0 - beta * streak)
    next_value = max(next_value, capacity_floor)  # floor clamp
    assert(next_value <= prev + 1e-6, "ANTI_P1_CAPACITY_MONOTONIC violated: %f > %f" % [next_value, prev])
    return next_value
```

#### 5.2 Python 静态 lint PR-blocking(`tools/anti_p1_capacity_lint.py`)

CI 中扫描所有 capacity 计算路径,验证:
- α / β / γ 都为正(decay 项 ≥ 0)
- capacity_floor < 1.0(下界严格小于初始值)
- 没有任何 code path 让 capacity_factor 直接 += 或 *= positive multiplier

任一违反 → PR-blocking。

### 6. Save Sub-schema 字段(`subsystems.ap_economy`)

```json
{
  "current_ap": 5,
  "max_ap_today": 8,
  "current_energy": 65,
  "overtime_used_this_month": 4,
  "hero_card_played_this_month": 2,
  "overage_card_played_this_month": 1,
  "capacity_factor": 0.87,
  "ap_state": "NORMAL"
}
```

跨 ADR 持久化责任:由 ADR-0003 Save schema cover。

## Alternatives Considered

### Alternative 1: 单一 effort 维度(简单加权)

- **描述**:Hero card effort 用单一标量 `effort_value`,不分三维度
- **Pros**:实施简单 / 公式短
- **Cons**:Hero card 无法表达 "focused vs breadth" tradeoff;KPI research §3 已论证三维度对玩家心智模型的关键作用
- **Rejection**:GDD §3.2 已 Approved 三维度,本 ADR 仅追溯文档化

### Alternative 2: capacity_factor 无下界(允许跌至 0)

- **描述**:`capacity_floor = 0`,任由 hero streak / overtime 把 capacity 推至 0
- **Pros**:数学最干净
- **Cons**:Anti-P1 红线破裂 — 玩家陷入永久不可逆惩罚循环,KPI threshold 永远不达成
- **Rejection**:`capacity_floor = 0.55` 是 GDD §F5 已锁的下界

### Alternative 3: cost 分布无 lint(纯人工 review)

- **描述**:不引入 Python 静态 lint,依靠设计师手工统计
- **Pros**:无工具维护成本
- **Cons**:跨 60+ ActionCard 配置漂移 inevitable;Sprint N 已实测人工 review 失误率 ~15%
- **Rejection**:lint 工具 1 次实施,长期收益

## Consequences

### Positive

- 5 个 TR 取得显式 ADR coverage(TR-ap-001/002/003/007/008)
- F1-F5 公式集中文档化,跨 GDD #7 / #9 / #11 引用一致
- Anti-P1 红线双层守(runtime + lint),capacity 单调性 PR-blocking
- α / β / γ 参数集中于本 ADR + GDD §F5,tuning 时一处改动

### Negative

- 实施先行 → ADR 与代码若漂移,文档版本需手动同步(Mitigation:`/architecture-review` 阶段对照 grep)
- Python lint 工具增加 CI 维护(每 sprint <30 分钟)

### Neutral

- 三维度权重 0.45/0.20/0.30 总和 0.95(非 1.0)是 design 决策 — 文档中明确解释,避免后续 sprint "修 bug" 误改

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| α / β / γ 参数 tuning 改动后 Anti-P1 测试失效 | LOW | HIGH | tests/unit/ap_economy/ 包含参数边界 test;CI 强制跑 |
| Python lint 工具误报 | MEDIUM | LOW | lint allow-list config + manual override 注释 `# anti-p1-lint: skip reason=...` |
| 实施代码与 ADR 漂移 | MEDIUM | MEDIUM | `/propagate-design-change` 在 GDD #7 改动时强制 ADR refresh |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU(月末 monthly_effort_summary 计算)| ~0.3ms | ~0.3ms | ≤ 1ms |
| Memory(AP state Dictionary)| ~2KB | ~2KB | ≤ 4KB |
| Load Time | N/A(纯算法,无 IO)| N/A | N/A |

## Migration Plan

无迁移 — 实施已 deployed。本 ADR 仅追溯文档化:

1. ✅ 4 态状态机已实施
2. ✅ F1-F5 公式已实施
3. ✅ 三维度权重已锁
4. ✅ capacity 衰减已实施
5. 🟡 Python lint 工具(`tools/anti_p1_capacity_lint.py` + `tools/anti_p1_card_cost_lint.py`)Sprint N+2 引入(P0)
6. 🟡 tr-registry.yaml 5 TR adr_coverage append [adr-0015](本 ADR 同 commit)

**Rollback plan**:文档级 ADR,无可 rollback 风险。如发现公式错误,issue 单独 ADR 修订(deprecate 0015 → 新 ADR)。

## Validation Criteria

- [ ] tr-registry.yaml 5 TR(ap-001/002/003/007/008)`adr_coverage` 含 `adr-0015`
- [ ] `tools/anti_p1_capacity_lint.py` 在 CI 跑通(所有现有 path PASS)
- [ ] `tools/anti_p1_card_cost_lint.py` 在 CI 跑通(40/40/20 ±5% 当前数据 PASS)
- [ ] 单元测试 `tests/unit/ap_economy/test_capacity_monotonic.gd` 覆盖 α/β/γ 边界
- [ ] `/architecture-review` 重跑 RTM,#7 GDD 5 TR 0 gap

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/ap-economy-system.md` §3 | AP Economy | "AP 4 态状态机" | 状态机 transition 表 + DEPLETED 不直 GAMEOVER 锁定 |
| `design/gdd/ap-economy-system.md` §F | AP Economy | "F1-F5 公式定义" | 5 公式 in-line 定义 + 实施引用 |
| `design/gdd/ap-economy-system.md` §3.2 | AP Economy | "Hero card effort 三维度权重 0.45/0.20/0.30" | 权重表 + 总和 0.95 设计决策说明 |
| `design/gdd/action-card-system.md` §4.2 | Action Card | "AP cost 40/40/20 分布" | Python lint PR-blocking 守门 |
| `design/gdd/ap-economy-system.md` §F5 | AP Economy | "capacity_factor 单调 + capacity_floor 下界(Anti-P1)" | 双层守(runtime assert + Python lint) |

## Related

- ADR-0001 Signal Ownership Matrix(`monthly_effort_summary` / `ap_changed` 单 owner = #7)
- ADR-0003 Save Format(`subsystems.ap_economy` sub-schema 持久化)
- ADR-0006 Dismissal/GAMEOVER Path(DEPLETED 不直 GAMEOVER,走 #9 KPI emit)
- ADR-0007 KPI Review Three-Track Anchor(`monthly_effort_summary` 喂入 KPI 月末计算)
- ADR-0016 KPI Reverse Threshold Formulas + RNG(capacity_factor 共享 α/β/γ 参数)
- `src/ap_economy/ap_economy_system.gd`(710 行实施)
- `tools/anti_p1_capacity_lint.py`(Sprint N+2 引入)
- `tools/anti_p1_card_cost_lint.py`(Sprint N+2 引入)
