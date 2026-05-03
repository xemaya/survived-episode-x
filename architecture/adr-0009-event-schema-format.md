# ADR-0009: Event Schema Format

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core / Scripting(Resource + @abstract 基类 + JSON 数据流) |
| **Knowledge Risk** | **HIGH**(`@abstract` 4.5+ 引入,LLM 截止 ~4.3 不知;`duplicate_deep()` 4.5 引入)|
| **References Consulted** | `docs/engine-reference/godot/breaking-changes.md` 4.4→4.5 |
| **Post-Cutoff APIs Used** | `@abstract`(4.5+)— `EventEffect` 基类强制 override |
| **Verification Required** | OQ-EVT-ENG-01 `@abstract` Resource 子类实测(同 ADR-0002 R-A2-1) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0002(`@abstract` 模式确认)+ ADR-0003(Save Format event_history 持久化) |
| **Enables** | `#10 Event Script Engine` 实施 + writer 工具 + CI lint |
| **Blocks** | 任何 EventScript 剧本 authoring + `#10` coding |
| **Ordering Note** | P1 优先级第一(Foundation 必创) |

## Context

### Problem Statement

`#10 Event Script Engine` 设计 200+ event 剧本(EVENT.* localization keys),需要统一 event schema:trigger 条件 / branch 分支 / effect / cooldown / once_per_run flag。

格式 / 文件位置 / Resource 类型 / `@abstract EventEffect` 基类设计未在任何 ADR 中锁定,writer 无法独立 author 剧本,CI lint 无 schema 可校验。

### Constraints

- `#10` 剧本必须能由 writer 独立 author(不依赖程序员)
- 三档密度(brief / standard / verbose)各自不同 effect 数量
- `event_history` Save 持久化 + cooldown 状态跨 Run
- 离别事件 numeric_only 强制(B-DEP-2 / ADR-0001 守门)
- `subject_inversion_lint.py` 检查 event 文本 8 域 master list(ADR-0010)
- `@abstract EventEffect` 子类必须 override(防漏写 callback 静默空跑)

### Requirements

- Event Resource 格式锁定(.tres 单文件)
- `EventEffect` `@abstract` 基类 + 5+ 子类(SetFlag / RelationshipDelta / SpawnNotice / GiveUnlock / EmitGameOver 等)
- 三档密度 effect 数量约束
- 文件目录结构 + naming convention

## Decision

### 1. Event Resource 类型(.tres 单文件 per event)

```gdscript
# src/feature/event_script/event_resource.gd
class_name EventResource
extends Resource

@export var event_id: StringName  # e.g. &"LISA_LUNCH_DILEMMA"
@export var trigger: EventTrigger  # 子 Resource
@export var narrative_density: NarrativeDensity = NarrativeDensity.STANDARD
@export var cooldown_days: int = 0  # 0 = no cooldown
@export var once_per_run: bool = false
@export var morning_blacklist: bool = false  # 早晨预告 blacklist
@export var farewell_event: bool = false  # FAREWELL_EVENT_IDS 守门 (ADR-0001 + ADR-0010)

# 三档密度差异化 effects
@export var effects_brief: Array[EventEffect] = []      # 最简(1-2 effect)
@export var effects_standard: Array[EventEffect] = []   # 中等(2-4 effect)
@export var effects_verbose: Array[EventEffect] = []    # 完整(4-8 effect)

@export var dialogue_keys_brief: PackedStringArray = []     # tr() keys
@export var dialogue_keys_standard: PackedStringArray = []
@export var dialogue_keys_verbose: PackedStringArray = []
```

### 2. EventTrigger Resource(条件)

```gdscript
class_name EventTrigger
extends Resource

enum TriggerType { CARD, NPC_RELATIONSHIP, KPI_THRESHOLD, MONTH_END, DAY_START, FLAG, COOLDOWN }

@export var type: TriggerType
@export var card_id: StringName  # 仅 type=CARD
@export var npc_id: StringName   # 仅 type=NPC_*
@export var threshold_op: String  # ">=", "<=", "=="
@export var threshold_value: int
@export var flag_name: StringName  # 仅 type=FLAG
@export var month_index: int = -1  # -1 = any
```

### 3. `@abstract EventEffect` 基类 + 5 子类

```gdscript
# src/feature/event_script/event_effect.gd
@abstract
class_name EventEffect
extends Resource

@abstract
func apply(context: EventContext) -> void:
    pass
```

```gdscript
class_name SetFlagEffect
extends EventEffect

@export var flag_name: StringName
@export var value: bool

func apply(context: EventContext) -> void:
    context.flag_dict[flag_name] = value
```

```gdscript
class_name RelationshipDeltaEffect
extends EventEffect

@export var npc_id: StringName
@export var delta: int  # ±1..±10

func apply(context: EventContext) -> void:
    NPCRelationshipSystem.apply_delta(npc_id, delta, "event:" + context.event_id)
```

```gdscript
class_name SpawnNoticeEffect
extends EventEffect

@export var notice_key: StringName  # tr() key
@export var npc_id: StringName

func apply(context: EventContext) -> void:
    NotificationSystem.spawn_notice(notice_key, npc_id)
```

```gdscript
class_name GiveUnlockEffect
extends EventEffect

@export var unlock_id: StringName  # 必须 in 5 类白名单(`#12 Run Meta` Rule 4)

func apply(context: EventContext) -> void:
    RunMetaSystem.unlock_content(unlock_id)  # 严格白名单守
```

```gdscript
class_name EmitGameOverEffect
extends EventEffect

@export var reason: String  # "kpi_fail_3" / "kpi_overflow" / "relationship_collapse"

func apply(context: EventContext) -> void:
    KPISystem.emit_game_over(reason)  # ADR-0006 Path B 链
```

### 4. 文件目录结构

```
data/events/
├── _schema/                                # 不实际 instance,仅 Inspector 模板
├── npc/                                   # NPC 互动事件
│   ├── lisa/
│   │   ├── LISA_LUNCH_DILEMMA.tres
│   │   ├── LISA_GOODBYE.tres              # FAREWELL_EVENT_IDS
│   │   └── ...
│   ├── boss/
│   │   ├── BOSS_WEEKLY_TALK.tres
│   │   └── ...
│   ├── cleaning_aunt/
│   │   ├── CLEANING_AUNT_LEAVE.tres       # FAREWELL_EVENT_IDS
│   │   └── ...
│   └── ...
├── kpi/
│   ├── EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3.tres
│   ├── EVENT.KPI.FIRED_DISMISSAL.kpi_overflow.tres
│   ├── EVENT.KPI.FIRED_DISMISSAL.relationship_collapse.tres
│   └── ...
├── month_end/
│   └── ...
└── morning/
    └── ...
```

### 5. Localization key 命名规范

```
EVENT.[CATEGORY].[EVENT_ID].DIALOGUE.[INDEX]_[DENSITY]
EVENT.[CATEGORY].[EVENT_ID].TITLE_NUMERIC  # farewell event 仅 numeric 一行
EVENT.[CATEGORY].[EVENT_ID].EFFECT_TEXT.[INDEX]
```

例:
```
EVENT.NPC.LISA_LUNCH_DILEMMA.DIALOGUE.0_BRIEF
EVENT.NPC.LISA_LUNCH_DILEMMA.DIALOGUE.0_STANDARD
EVENT.NPC.LISA_GOODBYE.TITLE_NUMERIC  # numeric_only 守门
EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3.HR_CERTIFICATE
```

### 6. 三档密度约束

| Density | Effects 数量 | Dialogue 数量 |
|---------|-------------|--------------|
| brief | 1-2 | 1-3 |
| standard | 2-4 | 3-6 |
| verbose | 4-8 | 6-12 |

CI lint(`tools/event_schema_lint.py`)校验:
- 各 density Array size 在范围内
- effect 子类 in 白名单
- dialogue_keys 在 `data/lang/zh-CN.csv` 存在
- farewell_event=true 时,`dialogue_keys_*` 仅 1 个 = `*.TITLE_NUMERIC`(numeric_only 守门)

### Architecture Diagram

```
┌──────────────────────────────────┐
│  data/events/*.tres              │
│  EventResource                    │
│  ├─ trigger: EventTrigger Resource│
│  ├─ effects_{brief|std|verbose}  │
│  │     Array[EventEffect]        │
│  └─ dialogue_keys_*: tr() keys   │
└──────┬───────────────────────────┘
       │ load + apply
       ▼
┌──────────────────────────────────┐
│  #10 Event Script Engine          │
│  ├─ trigger evaluator             │
│  ├─ density selector              │
│  └─ effect dispatcher             │
└──────┬───────────────────────────┘
       │ each EventEffect.apply()
       ▼
┌──────────────────────────────────┐
│  Subsystems (NPC / Save / KPI ...)│
└──────────────────────────────────┘
```

## Alternatives Considered

### Alternative 1: JSON 而非 .tres

- **Pros**: writer 可直接编辑文本 / git diff 友好
- **Cons**: 失去 Inspector 类型化编辑 + EventEffect 多态需手动 dispatch
- **Rejection**: .tres + Inspector 是 Godot 主流 + writer 已可用 GUI

### Alternative 2: 单 events.json 集中文件

- **Pros**: 单文件 git history 集中
- **Cons**: merge conflict 频发 + 200+ events 单文件难维护
- **Rejection**: 分文件结构更可扩展

### Alternative 3: GDScript func 直接定义(`func event_lisa_lunch():`)

- **Pros**: 程序员最灵活
- **Cons**: writer 无法独立 author + `@abstract` 守门失效
- **Rejection**: writer/programmer 边界破

## Consequences

### Positive

- writer 可独立 author EventResource(.tres + Inspector)
- `@abstract EventEffect` 防漏写 callback(4.5+ 强制 override)
- 三档密度差异化 effects 锁定(brief 1-2 / standard 2-4 / verbose 4-8)
- farewell_event flag + numeric_only 守门(B-DEP-2 / ADR-0001 集成)
- CI lint 工具有 schema 可校验

### Negative

- `@abstract` 4.5+ 特性,LLM 知识缺口需实测确认(OQ-EVT-ENG-01,与 ADR-0002 共)
- EventEffect 子类列表硬编码(白名单)— 新增子类需 ADR amendment
  - Mitigation: ADR-0009 修订流程或 superseded ADR 处理新类型

### Risks

- **R-A9-1**: `@abstract` Resource 子类在 4.6 实测不符文档 → 编辑器报错但运行时静默
  - **Mitigation**: 与 ADR-0002 R-A2-1 共;实测 + fallback 运行时 assert
- **R-A9-2**: 200+ events 加载内存超 budget
  - **Mitigation**: ResourceLoader.load_threaded_request() 分批加载 + cache eviction;实测 OQ-EVT-PERF-01

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#10 Event Script Engine` Rule 18 | `@abstract EventEffect` 基类 | EventEffect 5+ 子类 |
| `#10 Rule 6` | 三档密度 | effects_brief / standard / verbose |
| `#10 Rule 11` | 离别事件 numeric_only | farewell_event flag + lint 守 |
| `#10 Rule 17` | EVENT.KPI.FIRED_DISMISSAL 剧本 | data/events/kpi/ 目录 |
| `#1 Save` Rule 22 | content-only unlocks | GiveUnlockEffect + 5 类白名单 |
| ADR-0001 B-DEP-2 守门 | FAREWELL_EVENT_IDS enum | farewell_event flag 集成 |

## Performance Implications

- **CPU**: EventResource load 每个 < 1ms;200 events 总 ~200ms 启动期(分批加载缓解)
- **Memory**: 200 EventResource × ~5KB = ~1MB
- **Load Time**: 启动期分批加载,主线程占 ~50ms
- **Network**: N/A

## Migration Plan

无现有代码:
1. EventResource / EventTrigger / EventEffect 5 子类实施
2. data/events/ 目录结构 + writer 工具
3. CI `tools/event_schema_lint.py`(三档密度数量 + farewell numeric_only + dialogue_keys 存在)
4. `#10 Event Script Engine` trigger evaluator + density selector + effect dispatcher

## Validation Criteria

- writer 能独立 author EventResource(无需程序员)
- `@abstract EventEffect` 子类未 override `apply()` → 实例化失败
- CI lint 校验全 PASS(三档密度数量 + farewell numeric_only)
- 200+ events 加载内存 < 5MB(性能测试)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(FAREWELL_EVENT_IDS enum + numeric_only 守门)
- ADR-0002 Autoload Init Order(`@abstract` 模式)
- ADR-0003 Save Format(event_history 持久化)
- ADR-0006 Dismissal/GAMEOVER Path(EVENT.KPI.FIRED_DISMISSAL 剧本路径)
- ADR-0010 Subject Inversion Lint Master Domain List
- `#10 Event Script Engine` GDD
