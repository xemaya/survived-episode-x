# ADR-0005: Lighting Accumulation 4 Dimensions

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Rendering / Core(2D CanvasModulate + Texture state)|
| **Knowledge Risk** | LOW(2D CanvasModulate / TextureRect 4.0+ 稳定;4.6 D3D12 default Win 不影响 2D 路径) |
| **References Consulted** | `docs/engine-reference/godot/modules/rendering.md` / `current-best-practices.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(Signal Ownership Matrix — `accumulation_event` owner = `#5`) |
| **Enables** | `#5 Lighting` 实施 + `#13 HUD Diegetic` 视觉变体订阅 |
| **Blocks** | `#5` Lighting coding(4 维度未锁定) |
| **Ordering Note** | P0 优先级第五 |

## Context

### Problem Statement

`/review-all-gdds` 2026-04-29 surface **B-SCN4-3 BLOCKING**:`#5 Lighting` Section F "累积视觉元素" 仅定义 3 维度(yellowing_level / sticky_note_count / steam_density),`#6 Scene Flow` Section H 提到 4 维度但无完整列表;`npc_empty_chairs` 维度归属未定(`#5` 还是 `#6`)。

`accumulation_event` 信号 ownership 经 ADR-0001 仲裁为 `#5` 单 emit,但**第 4 维度内容**未锁定。

### Constraints

- `#5 Lighting` Pillar 4 主轨(视觉负空间)— 不能引入"快进 / 跳关 / 即时缓解"逃逸阀
- `#13 HUD Diegetic` 订阅 `accumulation_event` 用于 8 个 diegetic 元素的 visual variant
- `#8 NPC` `npc_lifecycle_changed(state=LEFT)` 触发椅子空置(R-NPC-2 守门:已 LEFT 视觉屏蔽)
- 四维度必须自然、不可逆 + 与 P3 死亡叙事呼应(累积只增不减)

### Requirements

- 4 维度名称 + schema 锁定
- 第 4 维度归属 `#5` 单 owner(消除 B-DEP-3 ambiguity 残留)
- `accumulation_event(type, delta_units)` payload 4 type 枚举
- 各维度增长 trigger / 视觉表现 / 上限定义

## Decision

### 4 累积维度(`#5` 单 owner)

| Dimension | Type Enum | Trigger | 视觉表现 | 上限 |
|-----------|-----------|---------|---------|------|
| **泛黄等级** | `yellowing_level` | 月份推进(`scene_state_changed → MONTH_END`)+ 1 unit | CanvasModulate `(0.95, 0.92, 0.85, 1.0)` 渐变(每级 -0.02 RGB) | 6 级(M6 上限);MVP 不重置 |
| **便利贴堆叠** | `sticky_note_count` | 老 NPC 离别事件触发(`npc_left_company` from `#8`)+ 1 unit | 工位墙便利贴 TextureRect Array(每元素 random rotation ± 8°)| 12 张(MVP cap) |
| **蒸汽浓度** | `steam_density` | 加班卡(`#11` `report_overage`)+ 1 unit / 月末 cap reset | 蒸汽 TextureRect `modulate.a`(每级 +0.03,M0=0.0 / M6=0.18)| 6 级 / 月,月末重置 cap(累积保留 saved level)|
| **空椅子** | `npc_empty_chairs` | `npc_left_company` from `#8`(B-DEP-2 离别事件链)+ 1 unit | 椅子节点 visibility = false + dust TextureRect 渐显 | NPC pool size(MVP 8) |

### `accumulation_event` Schema(`#5` emit)

```gdscript
# lighting_controller.gd Rule X
signal accumulation_event(type: StringName, delta_units: int)

# 4 type 枚举常量
const ACCUMULATION_TYPE_YELLOWING := &"yellowing_level"
const ACCUMULATION_TYPE_STICKY_NOTE := &"sticky_note_count"
const ACCUMULATION_TYPE_STEAM := &"steam_density"
const ACCUMULATION_TYPE_EMPTY_CHAIRS := &"npc_empty_chairs"

# 触发器(`#5` 内部 + 订阅上游):
func _on_scene_state_changed(from, to) -> void:
    if to == &"MONTH_END":
        _yellowing_level += 1
        emit_signal(&"accumulation_event", ACCUMULATION_TYPE_YELLOWING, 1)
        _persist_to_save()

func _on_npc_left_company(npc_id, reason) -> void:
    # B-DEP-2 离别事件链
    if reason in [&"FAREWELL", &"DISMISSAL", &"PROMOTED_LEAVE", &"OPTIMIZED_OUT"]:
        _sticky_note_count = min(_sticky_note_count + 1, 12)
        _empty_chairs[npc_id] = true
        emit_signal(&"accumulation_event", ACCUMULATION_TYPE_STICKY_NOTE, 1)
        emit_signal(&"accumulation_event", ACCUMULATION_TYPE_EMPTY_CHAIRS, 1)
        _persist_to_save()

func _on_overage_card_played(card_id) -> void:
    _steam_density = min(_steam_density + 1, 6)
    emit_signal(&"accumulation_event", ACCUMULATION_TYPE_STEAM, 1)
    _persist_to_save()
```

### `#13 HUD` 订阅契约

`#13` 8 diegetic 元素订阅 `accumulation_event` 用于视觉变体:

| HUD 元素 | 订阅维度 | 视觉响应 |
|---------|---------|---------|
| `HUD_NOTICEBOARD` | yellowing_level | 边缘逐级泛黄 |
| `HUD_DESK_STICKY_NOTES` | sticky_note_count | 节点 visibility 累计加 |
| `HUD_OFFICE_STEAM` | steam_density | TextureRect alpha 渐变 |
| `HUD_NPC_POSITION` | npc_empty_chairs | 椅子 visibility / dust 渐显 |
| 其他 4 元素 | (订阅 scene_state_changed) | — |

### Architecture Diagram

```
┌──────────────────────────────────┐
│  #5 Lighting Controller          │
│  (single owner of accumulation_event) │
│                                  │
│  Internal state:                 │
│  ├─ yellowing_level: int (0..6)  │
│  ├─ sticky_note_count: int (0..12)│
│  ├─ steam_density: int (0..6)    │
│  └─ npc_empty_chairs: Dict[npc_id]→bool │
└──────────────┬───────────────────┘
               │ accumulation_event(type, delta)
               ▼
       ┌───────────────────┐
       │  #13 HUD Diegetic │
       │  8 elements visual variant │
       └───────────────────┘
```

## Alternatives Considered

### Alternative 1: `npc_empty_chairs` 由 `#6 Scene Flow` own

- **Pros**: `#6` 持 game-time;能精准判断 NPC 离开时间
- **Cons**: 违反 `#5` 视觉负空间主轨;`#6` 已是 dispatcher 不应承担视觉细节
- **Rejection**: `#6` 越权;ADR-0001 已仲裁 `accumulation_event` owner = `#5`

### Alternative 2: 4 个独立 signal(yellowing_event / sticky_note_event / steam_event / empty_chair_event)

- **Pros**: 类型安全(每 signal 各自 payload schema)
- **Cons**: 4 信号增加 wiring;`#13` 8 元素 × 4 信号 = 32 connect 调用
- **Rejection**: 单 signal + type 枚举更精简

### Alternative 3: 累积维度可重置 / 衰减

- **Pros**: 玩家有"环境改善"的喘息感
- **Cons**: 违反 P3 死亡叙事 + Pillar 4(累积只增不减是叙事核心)
- **Rejection**: 已在 `#5` Pillar 守门拒绝

## Consequences

### Positive

- 4 维度 schema 完整定义,B-SCN4-3 BLOCKING 仲裁
- `npc_empty_chairs` 单 owner = `#5`(消除 B-DEP-3 残余 ambiguity)
- `accumulation_event(type, delta_units)` 统一 schema(单 signal + 4 type 枚举)
- 与 `#8 NPC` `npc_left_company` 链路自然(离别事件 → 椅子空 + 便利贴 + dust)
- Save Schema 4 字段持久化(yellowing_level / sticky_note_count / steam_density / empty_chairs Dict)

### Negative

- `#5` Save Schema 略增(4 字段)— 微 maintenance cost
- 4 维度增长无衰减 — 长 Run(M6+)视觉极度压抑;但这是 P3 设计目标(可接受)

### Risks

- **R-A5-1**: 12 个便利贴 + 8 椅子 + 6 级蒸汽 + 6 级泛黄同时渲染时 draw call 超 100 budget
  - **Mitigation**: 静态 Texture batching + Godot 4.6 自动 batching;实测 OQ-LVS-PERF
- **R-A5-2**: Save schema 4 字段在 schema_version=1 → 2 迁移时缺失
  - **Mitigation**: MVP `current_schema_version=1` 不支持迁移;VS 起 `_migrate_v1_to_v2` 链补默认值

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#5 Lighting` Section F | 4 累积维度 | yellowing / sticky / steam / empty_chairs |
| `#5 R-LVS-2` | 累积只增不减 | 各维度无衰减 |
| `#6 Scene Flow Section H` | accumulation_event ownership | `#5` 单 owner(B-DEP-3 仲裁) |
| `#8 NPC R-NPC-2` | LEFT 视觉屏蔽 | `npc_empty_chairs` Dict 渲染 visibility |
| `#13 HUD Rule 1` | 8 diegetic 元素 visual variant | 4 元素订阅 accumulation_event |

## Performance Implications

- **CPU**: 4 维度更新 µs 级;`#13` 8 元素 visual update 帧内 ms 级
- **Memory**: 4 字段 < 1KB / Run
- **Load Time**: N/A
- **Network**: N/A

## Migration Plan

无现有代码:
1. `#5 LightingController` 4 字段实现 + 4 trigger handler
2. `#13 HUD` 4 元素订阅 + visual variant 渲染
3. Save Schema sub-schema `lighting` 段 4 字段
4. `current_schema_version=1` 锁;VS 起迁移链

## Validation Criteria

- 4 维度独立累积(单元测试覆盖每维度 trigger)
- `accumulation_event` payload type 枚举 = 4 const 常量(单元测试覆盖)
- `#13` 8 元素 visual variant 与维度变化同步(集成测试)
- Save Schema 4 字段 round-trip 保留(单元测试)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(`accumulation_event` owner = `#5`)
- ADR-0003 Save Format(sub-schema `lighting` 4 字段持久化)
- `#5 Lighting` GDD Section F
- `#8 NPC` `npc_left_company` 链路
- `#13 HUD` 8 元素 visual variant
