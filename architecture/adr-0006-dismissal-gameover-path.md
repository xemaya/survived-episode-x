# ADR-0006: Dismissal / GAMEOVER Path Resolution

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core / Scripting(state machine + signal cascade) |
| **Knowledge Risk** | LOW(state machine + signal pattern 4.0+ 稳定) |
| **References Consulted** | `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(`dismissal_triggered` + `game_over_triggered` ownership)+ ADR-0003(meta.run_ended 原子写时序) |
| **Enables** | `#9 KPI` Rule 11 + `#10 Event Script` GAMEOVER 剧本 + `#16 KPI Review UI` GAMEOVER transition |
| **Blocks** | GAMEOVER 路径 coding(双路径不矛盾) |
| **Ordering Note** | P0 优先级第六 |

## Context

### Problem Statement

`/review-all-gdds` 2026-04-29 surface **B-RULE-1 BLOCKING**:`dismissal_triggered → GAMEOVER` 路径双 GDD 描述矛盾。

具体冲突:
- `#9 KPI` Rule 11:连续 3 次 KPI fail → `dismissal_triggered` emit + 自身 emit `game_over_triggered`(双 emit)
- `#10 Event Script` Rule 17:`dismissal_triggered` 触发 `EVENT.KPI.FIRED_DISMISSAL` 剧本 → 剧本 effect 触发 `game_over_triggered`(剧本中转)
- `#16 KPI Review UI`:监听 `game_over_triggered` 启动 1500ms 离职证明 transition

**矛盾**:`game_over_triggered` 由 `#9` 直接 emit 还是经 `#10` 剧本中转 emit?如果两者都 emit → `#16` 收到 2 次 transition 启动 → 卡死。

### Constraints

- `final_transition_duration_ms = 1500ms` registry 锁(linear easing=NONE 守门)
- `meta.run_ended = true` 原子 fsync **先于** 1500ms transition(R-AP-2 + R-KPI-2 守门)
- `#10 Event Script` 剧本必须能 inject 戏谑 HR 离职证明文本(P3 + P4 主轨)
- `#16` 1500ms transition 必须 idempotent(重入 detection)
- 双路径(直接 / 剧本中转)各自服务的 BUSINESS 区分 — KPI 三连败 vs 月末叙事性 GAME OVER

### Requirements

- 单 `game_over_triggered` 触发源(消除双 emit race)
- `dismissal_triggered` 经 `#10` 剧本路径(P3 戏谑文本 inject)
- `meta.run_ended` 原子 fsync 时序明确

## Decision

### 双路径合并:`game_over_triggered` 唯一 emit 源 = `#9 KPI`

```
┌────────────────────────────────────────────────────────────┐
│  Path A (KPI 直接路径,无叙事 inject)                          │
│                                                            │
│  #9 KPI Rule 11 (连续 3 fail) →                              │
│     SaveSystem.save_meta_sync(meta.run_ended=true) →         │
│     #9 emit game_over_triggered("kpi_fail_3", month) →       │
│     #16 KPI Review UI: 1500ms transition                    │
│                                                            │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  Path B (剧本叙事路径,P3+P4 戏谑 HR 文本)                      │
│                                                            │
│  #9 KPI 触发条件 (e.g. 月末 KPI 浮动溢出) →                     │
│     #9 emit dismissal_triggered("kpi_overflow") →            │
│     #10 Event Script: 检索 EVENT.KPI.FIRED_DISMISSAL 剧本 →    │
│     #10 剧本 effect:                                         │
│       1. UI inject 戏谑 HR 文本                               │
│       2. emit dismissal_finalized                            │
│     #9 监听 dismissal_finalized →                            │
│       SaveSystem.save_meta_sync(meta.run_ended=true) →       │
│       #9 emit game_over_triggered("dismissal_<reason>", month) │
│     #16 KPI Review UI: 1500ms transition                    │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 信号流(更新 ADR-0001 matrix 细节)

| Signal | Owner | Subscribers | 协议 |
|--------|-------|-------------|------|
| `dismissal_triggered(reason)` | `#9 KPI` | `#10 Event Script`(单 sub)| `#10` 检索 `EVENT.KPI.FIRED_DISMISSAL.[reason]` 剧本 |
| `dismissal_finalized` | `#10 Event Script` | `#9 KPI`(单 sub)| 剧本演完后回调 `#9` |
| `game_over_triggered(reason, month)` | `#9 KPI`(**唯一 emit**) | `#10 / #12 / #16` | 1500ms linear easing=NONE transition |

### `#9 KPI Rule 11` 状态机(实施细节)

```gdscript
# kpi_system.gd Rule 11
enum KPIFailState { NORMAL, FAIL_1, FAIL_2, AWAITING_DISMISSAL_FINALIZE }

var fail_state: KPIFailState = KPIFailState.NORMAL
var settlement_locked: bool = false  # R-KPI-2

func _on_monthly_kpi_settled(actual: float, threshold: float) -> void:
    if settlement_locked:
        return  # R-KPI-2 守门:已进入 GAMEOVER transition,忽略后续 settle
    
    if actual < threshold:
        match fail_state:
            KPIFailState.NORMAL: fail_state = KPIFailState.FAIL_1
            KPIFailState.FAIL_1: fail_state = KPIFailState.FAIL_2
            KPIFailState.FAIL_2: _trigger_path_b_dismissal("kpi_fail_3")
    else:
        fail_state = KPIFailState.NORMAL  # reset

func _trigger_path_b_dismissal(reason: String) -> void:
    # 双路径合并 — 都走剧本路径(获取戏谑 HR 文本)
    settlement_locked = true
    fail_state = KPIFailState.AWAITING_DISMISSAL_FINALIZE
    emit_signal(&"dismissal_triggered", reason)
    # 等待 #10 剧本回调 dismissal_finalized

func _on_dismissal_finalized() -> void:
    if fail_state != KPIFailState.AWAITING_DISMISSAL_FINALIZE:
        push_warning("dismissal_finalized received without prior trigger — ignoring")
        return
    # ARCHIVING 时序 (ADR-0003)
    SaveSystem.save_meta_sync(meta_with_run_ended=true)
    var current_month := SceneDayFlowController.month_index
    emit_signal(&"game_over_triggered", current_reason, current_month)
```

### 双路径区分

**Path A 已废弃** — 实际所有 GAMEOVER 都走 Path B(剧本路径):
- 即使"无叙事"的 KPI 三连败,也通过 `EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3` 剧本走戏谑 HR 文本
- 统一路径消除双 emit race
- `#10` 剧本编排者(writer)有机会为各 reason 编写不同戏谑文本

```
EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3.TITLE = "员工绩效连续三月不达标 — 优化通知"
EVENT.KPI.FIRED_DISMISSAL.kpi_overflow.TITLE = "员工 KPI 浮动达 200% 预警 — 防泡沫机制启动"
EVENT.KPI.FIRED_DISMISSAL.relationship_collapse.TITLE = "员工人际关系评估 D 级 — 团队协作风险解除"
```

### `meta.run_ended` 原子写时序(ADR-0003 细化)

```
T+0ms     #9 emit dismissal_triggered (settlement_locked=true)
T+~50ms   #10 检索剧本 → 演出戏谑 HR 文本(玩家阅读期 ~3-5 秒)
T+5000ms  #10 剧本 effect emit dismissal_finalized
T+5000ms  #9 _on_dismissal_finalized:
            ├─ SaveSystem.save_meta_sync(meta.run_ended=true) [<50ms 主线程同步 fsync]
            ├─ emit game_over_triggered(reason, month)
T+5050ms  #16 KPI Review UI 启动 1500ms linear easing=NONE transition
T+6550ms  ARCHIVING 5 步事务(主线程 <50ms)→ MAIN_MENU
```

防 Alt+F4 续命:`meta.run_ended` 在 `dismissal_triggered` emit 后**最终落盘**于 transition 启动**前** 50ms 内(主线程同步 fsync)。

## Alternatives Considered

### Alternative 1: `#9` 直接 emit `game_over_triggered`(原始 Path A)

- **Pros**: 简单
- **Cons**: 失去 P3+P4 戏谑 HR 文本 inject 机会;违反 `#10 Event Script` 主轨"叙事即机制"
- **Rejection**: P3+P4 是核心 Pillar,Path A 路径放弃 = 主轨破

### Alternative 2: 双 emit 都保留(`#9` + `#10` 都 emit `game_over_triggered`)

- **Pros**: 双路径独立
- **Cons**: `#16` 收到 2 次 → race;实施复杂度爆炸
- **Rejection**: B-RULE-1 BLOCKING 必须消除

### Alternative 3: `#10` own `game_over_triggered`

- **Pros**: 剧本路径作为唯一来源
- **Cons**: `#9` KPI 是机械触发源;`#10` 仅是叙事中转;ownership 不应在 middleware
- **Rejection**: violates ADR-0001 — `#9` 是 KPI 系统 owner

## Consequences

### Positive

- 单 `game_over_triggered` emit 源(`#9`)消除双 emit race
- 所有 GAMEOVER 走戏谑 HR 文本路径(P3+P4 主轨守)
- `dismissal_triggered → dismissal_finalized → game_over_triggered` 链路明确
- `settlement_locked` 守门 R-KPI-2(防月末重入)

### Negative

- 路径稍长(`#9 → #10 → #9 → #16`),增加一跳
- `#10 Event Script` 必须支持"无 NPC 参与"的 GAMEOVER 剧本(纯 HR 文本场景)— 微 schema 变化

### Risks

- **R-A6-1**: `#10` 剧本演出 5 秒期间,玩家 Alt+F4 → `dismissal_finalized` 未 emit → `meta.run_ended` 未落盘 → 续命可能
  - **Mitigation**: `#9` 在 `dismissal_triggered` emit 同步 fsync `meta.dismissal_pending=true`(预备 flag);启动检测到该 flag 直接进入 `#10` GAMEOVER 剧本(从中断点恢复)
- **R-A6-2**: `#10` 剧本崩溃(AssertionError)致 `dismissal_finalized` 永不 emit → `#9` 卡 AWAITING 状态
  - **Mitigation**: watchdog 30s timer 在 `#9 _trigger_path_b_dismissal` 启动;超时 fallback emit `dismissal_finalized` 自身(degraded GAMEOVER 文本)

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#9 KPI` Rule 11 | 三连败触发 dismissal | Path B 唯一路径 |
| `#9 R-KPI-2` | settlement_locked | `_trigger_path_b_dismissal` 锁 |
| `#10 Event Script` Rule 17 | EVENT.KPI.FIRED_DISMISSAL 剧本 | 剧本中转 |
| `#16 KPI Review UI` Section H AC | 1500ms linear easing=NONE | game_over_triggered 唯一启动 |
| `#1 Save` Rule 21 | final_transition_duration_ms 守门 | meta.run_ended 先于 transition |

## Performance Implications

- **CPU**: 单链路 ~50ms 主线程同步 fsync + 5s 剧本演出(异步)
- **Memory**: settlement_locked + AWAITING_DISMISSAL_FINALIZE state < 1KB
- **Load Time**: N/A
- **Network**: N/A

## Migration Plan

无现有代码:
1. `#9 KPI` Rule 11 + state machine 实施
2. `#10 Event Script` 支持纯 HR 文本剧本(无 NPC choice)
3. `#9 _on_dismissal_finalized` 实施 + watchdog 30s
4. `meta.dismissal_pending` 启动恢复 flag(R-A6-1 mitigation)

## Validation Criteria

- `dismissal_triggered → dismissal_finalized → game_over_triggered` 链路单元测试覆盖
- `settlement_locked` 重入测试(月末重入 settle 不再 emit)
- watchdog 30s 超时 fallback 测试
- `meta.dismissal_pending` 启动恢复测试(crash recovery fixture)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(dismissal_triggered + dismissal_finalized + game_over_triggered)
- ADR-0003 Save Format(meta.run_ended + dismissal_pending fsync)
- ADR-0007 KPI Review Three-Track Anchor(transition 三轨锚)
- `#9 KPI` Rule 11 + R-KPI-2
- `#10 Event Script` Rule 17
- `#16 KPI Review UI` Section H AC
