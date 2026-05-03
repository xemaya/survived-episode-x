# ADR-0016: KPI Reverse Threshold Formulas + RNG Seed

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

KPI System(#9 GDD)的反向门槛模型由"单调递增 monthly_threshold + F1-F4 capacity 衰减公式 + deterministic RNG seed"三块组成。其中 monthly_threshold 单调递增是 Anti-P1 红线(玩家死循环防护),F1-F4 capacity 衰减与 ADR-0015 共享 α/β/γ 参数,RNG seed 决定月末复算 / 跨 Run replay 一致性。本 ADR 锁定已实施模型,使 RTM 3 个 TR(TR-kpi-001/002/010)取得显式 ADR coverage。

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core(Gameplay 经济计算 / RandomNumberGenerator 实例化) |
| **Knowledge Risk** | LOW(`RandomNumberGenerator` API 自 Godot 3.x 稳定;无 post-cutoff 行为) |
| **References Consulted** | `design/gdd/kpi-reverse-threshold-system.md` / `design/research/kpi-research.md` / ADR-0015(capacity 共享) |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | F1-F4 单元测试 + monotonic threshold 边界测试 + RNG save/load round-trip 测试 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(`game_over_triggered` / `kpi_review_started` 单 owner = #9)+ ADR-0006(dismissal_pending → game_over Path B 唯一)+ ADR-0007(KPI Review 三轨 800ms 同步锚)+ ADR-0015(capacity_factor 衰减模型 α/β/γ 共享) |
| **Enables** | architecture-review RTM 3 TR cover(TR-kpi-001/002/010)+ RNG seed 可控 → tooling speedrun replay / QA 月末复算自动化 |
| **Blocks** | None — 模型已 deployed |
| **Ordering Note** | Sprint N+2 P0 fix。实施先于 ADR — 本 ADR 是对 `src/autoload/kpi_system.gd`(752 行)的追溯文档化。 |

## Context

### Problem Statement

architecture-review-report-2026-04-28 RTM 阶段识别 KPI System(#9 GDD)有 3 个 TR 缺失 ADR coverage:

- **TR-kpi-001**:monthly_threshold 单调递增(Anti-P1 红线 — 防"门槛突然降低让月末通过太容易"破坏 reverse threshold 体验)
- **TR-kpi-002**:F1-F4 公式(乘性复合 + capacity_factor 衰减,与 ADR-0015 α=0.04 / β=0.18 / γ=0.012 共享)
- **TR-kpi-010**:deterministic RNG seed(public seed + 月末复算 — 跨 Save 一致性 + speedrun replay)

代码 `src/autoload/kpi_system.gd` 已落地 752 行实施(包括 update_threshold 主动拒绝违规递减 + _run_monthly_settlement strict-greater 守 + RandomNumberGenerator instance + save/load round-trip),但缺乏架构层面 ADR 锁定。

### Current State

- F1-F4 公式 + monthly_threshold 计算:已实施(kpi_system.gd)
- 单调递增红线双层守(`update_threshold` 主动拒绝 + `_run_monthly_settlement` strict-greater):已实施
- RandomNumberGenerator instance + public seed + save/load:已实施
- Anti-P1 KPI lint Python 工具(`tools/anti_p1_kpi_lint.py`):缺失 — Sprint N+2 P0 引入
- ADR coverage:缺(本 ADR 补)

### Constraints

- 实施先行:不得改动 `src/autoload/kpi_system.gd` 数值参数或算法行为
- 必须与 ADR-0015 capacity 模型 α/β/γ 参数严格一致(共享字典 / 共同来源)
- F1-F4 公式与 GDD `design/gdd/kpi-reverse-threshold-system.md` §F 一一对应
- Anti-P1 红线必须 PR-blocking(`tools/anti_p1_kpi_lint.py` 静态 + 运行时双层)
- RNG 必须 RandomNumberGenerator **instance**(非 global `randi()`,防止跨系统污染)

### Requirements

- monthly_threshold 单调递增(`threshold[m+1] > threshold[m]` strict)— Anti-P1 红线
- F1-F4 公式 in-line 定义(monthly_threshold / capacity_now / actual_kpi / pass_check)
- α / β / γ 参数源自 ADR-0015(capacity 共享模型)
- public RNG seed 暴露给 QA tools / speedrun mode
- 月末复算 deterministic — 同 seed + 同 inputs → 同 outputs(单元测试 round-trip)
- save/load RNG state round-trip 持久化于 `subsystems.kpi_system.rng_state`

## Decision

### 1. F1-F4 公式定义

```
F1  monthly_threshold(m) = base_threshold × (1 + growth_rate)^m × capacity_factor(m)
                          subject to monotonic constraint:
                          threshold(m) > threshold(m-1) strictly  ← Anti-P1 红线

F2  capacity_now(m)      = capacity_factor(m) × max_effort_per_month(m)
                          (capacity_factor 共享 ADR-0015 α/β/γ)

F3  actual_kpi(m)        = Σ over days d in month m: Σ effort_per_card(d)
                          (effort_per_card 来自 ADR-0015 F3 三维度权重)

F4  pass_check(m)        = (actual_kpi(m) >= monthly_threshold(m))
                          ? KPI_PASS
                          : (capacity_now(m) >= monthly_threshold(m))
                            ? KPI_FAIL_CAPACITY_OK   # 玩家失误,继续游戏
                            : KPI_FAIL_DISMISSAL     # 容量已不足,触发解雇剧本
```

参数(基线值,与 ADR-0015 共享):
- `base_threshold = 100`(M1)
- `growth_rate = 0.18`(月度复利;与 ADR-0015 β 同名巧合,语义不同)
- `capacity_factor`:见 ADR-0015 F5,α=0.04 / β=0.18 / γ=0.012 / capacity_floor=0.55
- `max_effort_per_month`:由 #7 AP 系统 `monthly_effort_summary` 喂入

公式实现位于 `src/autoload/kpi_system.gd`:
- `_compute_monthly_threshold()` → F1
- `_compute_capacity_now()` → F2
- `_aggregate_actual_kpi()` → F3
- `_run_monthly_settlement()` → F4 + emit `kpi_review_started` / `dismissal_triggered`

### 2. Monotonic Threshold 双层守门(Anti-P1 红线)

**Anti-P1 红线**:monthly_threshold 必须**严格单调递增**(`threshold(m+1) > threshold(m)`)。

#### 2.1 主动拒绝 — `update_threshold(m, new_value)`

```gdscript
func update_threshold(month: int, new_value: float) -> void:
    if month > 1:
        var prev: float = monthly_threshold[month - 1]
        if new_value <= prev:
            push_error("ANTI_P1_THRESHOLD_MONOTONIC violated: m=%d, new=%f <= prev=%f"
                       % [month, new_value, prev])
            return  # 拒绝写入,保留旧值
    monthly_threshold[month] = new_value
```

#### 2.2 月末结算 strict-greater 守 — `_run_monthly_settlement()`

```gdscript
func _run_monthly_settlement(month: int) -> void:
    if month > 1:
        assert(monthly_threshold[month] > monthly_threshold[month - 1],
               "ANTI_P1_THRESHOLD_MONOTONIC: m=%d threshold not strict-greater" % month)
    # ... 后续结算逻辑
```

#### 2.3 Python 静态 lint PR-blocking — `tools/anti_p1_kpi_lint.py`

CI 中扫描:
- 所有 monthly_threshold 写路径无 negative growth
- F1 公式参数 `growth_rate > 0`
- `capacity_factor` 引用 ADR-0015 共享参数(无 hardcode 不一致值)

任一违反 → PR-blocking。

### 3. Deterministic RNG Seed

#### 3.1 RandomNumberGenerator instance(非 global)

```gdscript
class_name KPISystem
extends Node

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var public_seed: int = 0  # exposed to QA / speedrun tools

func _ready() -> void:
    if public_seed == 0:
        public_seed = randi()  # 一次性 fallback
    _rng.seed = public_seed
    _rng.state = 0  # 显式初始化
```

#### 3.2 月末复算 deterministic

`_run_monthly_settlement()` 在月末读取 `_rng.state`,计算所有 randomized variation(如 NPC reaction multipliers),再写回 state。同 seed + 同 inputs(包括上一月 state)→ 同 outputs。

#### 3.3 Save/Load Round-Trip

`subsystems.kpi_system` sub-schema 增加字段:

```json
{
  "monthly_threshold": [100, 142, 168, ...],
  "actual_kpi_history": [102, 118, 130, ...],
  "settlement_locked": false,
  "rng_seed": 1234567,
  "rng_state": "9876543210"
}
```

跨 Save/Load:`_rng.seed` + `_rng.state` 字段保留 → load 后下一次 `_rng.randf()` 与 save 前 next call 输出一致(单元测试 round-trip 验证)。

#### 3.4 Public Seed 暴露(QA / Speedrun)

`KPISystem.public_seed` 为 `var`(非 `_var`),允许 QA tools 直接读 / 写。Speedrun mode `--seed=N` CLI flag 在 SaveSystem 启动时注入。

### 4. game_over_triggered emit 路径(共享 ADR-0006)

KPI #9 是 `game_over_triggered` 唯一 emit 源(见 ADR-0001 + ADR-0006)。本 ADR 不重复定义,仅引用:

- `KPI_FAIL_DISMISSAL` → emit `dismissal_triggered` → #10 EVENT.KPI.FIRED_DISMISSAL → emit `dismissal_finalized` → #9 emit `game_over_triggered`(Path B 唯一)
- `KPI_PASS` / `KPI_FAIL_CAPACITY_OK` → 不 emit,继续下月

### 5. Save Sub-schema(`subsystems.kpi_system`)

跨 ADR 持久化责任:由 ADR-0003 cover。本 ADR 锁定字段:

- `monthly_threshold: Array[float]`(每月一项,append-only)
- `actual_kpi_history: Array[float]`
- `settlement_locked: bool`(R-KPI-2 月末重入屏蔽)
- `rng_seed: int`(public)
- `rng_state: String`(`_rng.state` String 化以兼容 JSON)

## Alternatives Considered

### Alternative 1: monthly_threshold 用线性递增(无 capacity_factor 调制)

- **描述**:`threshold(m) = base + step × m`,不乘 capacity_factor
- **Pros**:公式最简单
- **Cons**:capacity 跌至 floor 后 threshold 仍线性增,玩家陷入永久不可达 → Anti-P1 破裂
- **Rejection**:F1 必须乘 `capacity_factor` 让 threshold 与 capacity 同步衰减,保证 `threshold ≤ capacity_now` 在合理玩法下可达

### Alternative 2: Global `randi()`(非 RandomNumberGenerator instance)

- **描述**:KPI 月末用 `randi()` / `randf()` 全局 RNG
- **Pros**:实施最简单
- **Cons**:跨系统污染 — #10 Event Engine、#8 NPC reaction 也用 global RNG,KPI 月末输出依赖 frame ordering;无法 deterministic replay
- **Rejection**:每个有 randomized 决策的系统必须 own RandomNumberGenerator instance(architecture standard)

### Alternative 3: Threshold monotonic 单层守(只 runtime assert)

- **描述**:不引入 `update_threshold` 主动拒绝,只靠月末 strict-greater assert
- **Pros**:代码少 ~10 行
- **Cons**:bug 在月末才暴露(可能跨 sprint),回归数据 难;主动拒绝在写入瞬间报错更易定位
- **Rejection**:Anti-P1 红线值得双层守

## Consequences

### Positive

- 3 个 TR 取得显式 ADR coverage(TR-kpi-001/002/010)
- Anti-P1 红线 PR-blocking 双层(主动拒绝 + 月末 strict-greater + Python lint)
- F1-F4 公式集中文档化,与 ADR-0015 共享 α/β/γ 参数
- RNG instance + public seed → QA / speedrun replay 可行
- save/load round-trip 持久化保证跨 session 一致性

### Negative

- Python lint 工具增加 CI 维护(`tools/anti_p1_kpi_lint.py`)
- public seed 字段暴露 → 玩家可能"刷种子"找最弱 threshold 月份(Mitigation:public seed 可选 `--seed=random` opt-out;主流程仍用启动 randi() fallback)

### Neutral

- monthly_threshold 改为 Array[float](从 Dict 改),append-only — Sprint N+2 仅添加测试不影响数据兼容

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| α / β / γ 参数 ADR-0015 / 0016 双源漂移 | MEDIUM | HIGH | 单一 source — `design/registry/entities.yaml` constants;两 ADR 引用同 key |
| RNG seed save/load round-trip 失败 | LOW | HIGH | tests/unit/kpi/test_rng_round_trip.gd 强制覆盖 |
| Python lint 误报 monotonic violation | MEDIUM | LOW | manual override comment `# anti-p1-lint: skip reason=tutorial month` |
| public seed 玩家滥用 "刷种子" 影响游戏体验 | LOW | LOW | seed 可选 opt-out,默认 random fallback |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU(月末结算 _run_monthly_settlement)| ~1.2ms | ~1.2ms | ≤ 5ms |
| Memory(monthly_threshold + actual_kpi_history,24 月)| ~500B | ~500B | ≤ 4KB |
| Load Time(rng_state 反序列化)| ~0.1ms | ~0.1ms | ≤ 1ms |

## Migration Plan

无迁移 — 实施已 deployed。本 ADR 仅追溯文档化:

1. ✅ F1-F4 公式已实施
2. ✅ Monotonic 双层守已实施(update_threshold 主动拒绝 + _run_monthly_settlement strict-greater)
3. ✅ RandomNumberGenerator instance + public seed 已实施
4. ✅ save/load round-trip 已实施
5. 🟡 `tools/anti_p1_kpi_lint.py` Sprint N+2 引入(P0)
6. 🟡 tr-registry.yaml 3 TR `adr_coverage` append [adr-0016](本 ADR 同 commit)

**Rollback plan**:文档级 ADR,无 rollback 风险。

## Validation Criteria

- [ ] tr-registry.yaml 3 TR(kpi-001/002/010)`adr_coverage` 含 `adr-0016`
- [ ] `tools/anti_p1_kpi_lint.py` 在 CI 跑通(所有现有 path PASS)
- [ ] 单元测试 `tests/unit/kpi/test_threshold_monotonic.gd` 覆盖边界(违规 update 被拒,月末 assert 触发)
- [ ] 单元测试 `tests/unit/kpi/test_rng_round_trip.gd` save/load round-trip pass
- [ ] `/architecture-review` 重跑 RTM,#9 GDD 3 TR 0 gap

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/kpi-reverse-threshold-system.md` §F1 | KPI | "monthly_threshold 单调递增" | 双层守(update_threshold 主动拒绝 + _run_monthly_settlement strict-greater)+ Python lint PR-blocking |
| `design/gdd/kpi-reverse-threshold-system.md` §F | KPI | "F1-F4 公式定义" | F1-F4 in-line 定义 + capacity 共享 ADR-0015 |
| `design/gdd/kpi-reverse-threshold-system.md` §6 | KPI | "deterministic RNG seed(public seed + 月末复算)" | RandomNumberGenerator instance + public_seed 字段 + save/load round-trip |
| `design/research/kpi-research.md` §3 | KPI | "capacity_factor 衰减模型 α/β/γ" | 引用 ADR-0015 共享参数(单一来源 entities.yaml) |

## Related

- ADR-0001 Signal Ownership Matrix(`game_over_triggered` / `kpi_review_started` 单 owner = #9)
- ADR-0006 Dismissal/GAMEOVER Path(Path B 唯一:dismissal_triggered → EVENT → dismissal_finalized → game_over_triggered)
- ADR-0007 KPI Review Three-Track Anchor(800ms 三轨同步)
- ADR-0015 AP Economy State + Formulas(capacity 共享 α/β/γ)
- ADR-0003 Save Format(`subsystems.kpi_system` 持久化包含 rng_state)
- `src/autoload/kpi_system.gd`(752 行实施)
- `tools/anti_p1_kpi_lint.py`(Sprint N+2 引入)
- `design/gdd/kpi-reverse-threshold-system.md`(Approved)
- `design/research/kpi-research.md`(三维度权重 + capacity 衰减仲裁)
