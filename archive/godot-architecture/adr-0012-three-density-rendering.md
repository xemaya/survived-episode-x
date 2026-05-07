# ADR-0012: Three-Density Event Rendering Strategy

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | UI / Scripting(Control + RichTextLabel + 数据驱动渲染)|
| **Knowledge Risk** | LOW(RichTextLabel 4.0+ 稳定;`@abstract` 不直接使用)|
| **References Consulted** | `docs/engine-reference/godot/modules/ui.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(`narrative_density_changed` owner = `#17`)+ ADR-0004(EVENT_ACTIVE 切档行为)+ ADR-0009(EventResource 三档 effects/dialogue) |
| **Enables** | `#14 Card Play Dialogue UI` 实施 + `#15 Recap UI` 三档密度文本 |
| **Blocks** | `#14` 主消费 layer coding(三档密度 fallback 策略未定) |
| **Ordering Note** | P2 优先级第二 |

## Context

### Problem Statement

`#10 Event Script Engine` Rule 6 + `#17 Settings` 三档叙事密度(brief / standard / verbose)选项,影响:
- `#14 Card Play Dialogue UI`:对白渲染(主消费者)
- `#15 Recap UI`:周报 / 月报文本量
- `#10` EventResource:effects 数量(brief 1-2 / standard 2-4 / verbose 4-8)

未定义:
- 主消费 layer = `#14` 还是 `#10`?(谁负责"读 density 选 effects/dialogue")
- 三档之间 fallback 策略(brief 缺失 → standard fallback?)
- EVENT_ACTIVE 中途切密度行为(已 ADR-0004 仲裁:当前事件用旧密度)

### Constraints

- ADR-0004 已锁:EVENT_ACTIVE 切档延后到下个 event_started
- ADR-0009 已锁:EventResource 三档 effects + dialogue_keys
- ADR-0001 已锁:`narrative_density_changed` owner = `#17`,subscriber = `#10/#14/#15`
- writer 不希望为每个 event × 3 密度 × 3+ dialogue = 9+ tr() keys(工作量爆炸)
- P5 90s/天 budget 不允许 verbose 超 30 秒事件

### Requirements

- 主消费 layer 锁定(`#14` or `#10`)
- 三档 fallback 策略(brief 缺 → standard / verbose 缺 → standard)
- writer 工作量约束(每 event 必填 standard,brief/verbose 可选)
- 性能契约(单 event 渲染 ≤ 50ms 主线程)

## Decision

### 主消费 layer = `#14 Card Play Dialogue UI`

**理由**:
- `#10 Event Script Engine` 是数据层(load EventResource + dispatch effects),不应承担 UI 渲染细节
- `#14` 是对白 UI 主屏 — 已有 RichTextLabel + Choice button 渲染逻辑
- `#15 Recap UI` 周报 / 月报是 `#14` 的"轻量化版本",共享 `#14` 的密度选择逻辑

```gdscript
# #14 card_play_dialogue_ui.gd Section C Rule N
const NARRATIVE_DENSITY_KEY := &"narrative_density"

func _on_event_started(event: EventResource, density: NarrativeDensity) -> void:
    # density 由 #10 在 emit event_started 时 push,EVENT_ACTIVE 锁定
    var dialogue_keys := _select_dialogue_keys_by_density(event, density)
    var effects := _select_effects_by_density(event, density)
    # 渲染流程
    for key in dialogue_keys:
        await _render_dialogue_line(tr(key))
    for effect in effects:
        effect.apply(event_context)
```

### 三档 fallback 策略

```gdscript
func _select_dialogue_keys_by_density(event: EventResource, density: NarrativeDensity) -> PackedStringArray:
    match density:
        NarrativeDensity.BRIEF:
            # 优先 brief,缺失 fallback standard,再缺失 fallback verbose
            if not event.dialogue_keys_brief.is_empty():
                return event.dialogue_keys_brief
            elif not event.dialogue_keys_standard.is_empty():
                push_warning("event %s missing brief, fallback standard" % event.event_id)
                return event.dialogue_keys_standard
            else:
                push_warning("event %s missing brief+standard, fallback verbose" % event.event_id)
                return event.dialogue_keys_verbose
        NarrativeDensity.STANDARD:
            # standard 必填(writer 工作量约束),无 fallback
            assert(not event.dialogue_keys_standard.is_empty(), 
                   "event %s missing required standard dialogue" % event.event_id)
            return event.dialogue_keys_standard
        NarrativeDensity.VERBOSE:
            # verbose 优先,缺失 fallback standard
            if not event.dialogue_keys_verbose.is_empty():
                return event.dialogue_keys_verbose
            else:
                return event.dialogue_keys_standard

func _select_effects_by_density(event: EventResource, density: NarrativeDensity) -> Array[EventEffect]:
    # 同样 fallback 链
    ...
```

### writer 工作量约束(ADR-0009 amendment)

| Density | Required? | 工作量 |
|---------|-----------|-------|
| brief | optional | 1-3 dialogue + 1-2 effect |
| **standard** | **required** | 3-6 dialogue + 2-4 effect |
| verbose | optional | 6-12 dialogue + 4-8 effect |

writer 默认只写 standard;有时间/兴趣时增 brief/verbose。
缺 brief → fallback standard;缺 verbose → fallback standard。

CI lint(`tools/event_schema_lint.py`)校验 standard 必填:
```python
if not event.dialogue_keys_standard:
    errors.append(f"{path}: standard dialogue required")
```

### 三档密度对应"玩家心理模型"

| Density | 玩家心理模型 | 推荐场景 |
|---------|------------|---------|
| brief | "我赶时间,只想知道结果" | 通勤地铁玩(P5 主轨) |
| standard | "我想看完整剧情" | 正常游玩(default) |
| verbose | "我是 narrative 死忠,愿意读细节" | 在家专注玩 |

UI 提示(`#17 Settings`):"叙事密度 — 决定事件中你能看到多少对白"。

### `#15 Recap UI` 共享逻辑

```gdscript
# #15 recap_ui.gd
func _render_weekly_recap(events_this_week: Array[EventResource], density: NarrativeDensity) -> void:
    for event in events_this_week:
        var summary_keys := _select_summary_by_density(event, density)
        # 周报 summary 只取 dialogue_keys_*[0](首句)
        await _render_summary_line(tr(summary_keys[0]) if not summary_keys.is_empty() else "")
```

### Architecture Diagram

```
#17 Settings → narrative_density_changed signal
                    │
                    ▼
        ┌──────────────────────┐
        │ #6 SceneDayFlow      │
        │ ADR-0004 防抖 + 合流  │
        └──────────────────────┘
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
    #10 Event    #14 Card     #15 Recap
    Script       Play UI       UI
    Engine       (主消费)
    (数据层)      ↓             ↓
    EventResource │             │
    .effects_*   │             │
    .dialogue_   │             │
    keys_*       │             │
                 ▼             ▼
        _select_*_by_density() (fallback 链)
                 │             │
                 ▼             ▼
            渲染对白/效果    渲染 summary
```

## Alternatives Considered

### Alternative 1: 主消费 = `#10 Event Script`

- **Pros**: 数据 + 渲染统一
- **Cons**: `#10` 是数据层职责越界 + UI 细节污染数据流;`#15 Recap` 重复实现
- **Rejection**: 违反 SoC

### Alternative 2: 单档密度(无三档,只 standard)

- **Pros**: 简单
- **Cons**: 失去地铁玩(P5 主轨)brief / 失去 narrative 死忠 verbose
- **Rejection**: P5 + a11y 失分

### Alternative 3: 五档密度(more / verbose / standard / brief / minimal)

- **Pros**: 更细化
- **Cons**: writer 工作量爆炸 / Settings UI 复杂
- **Rejection**: 三档 Goldilocks zone

### Alternative 4: 自动密度(根据玩家 session 长度选择)

- **Pros**: 玩家无需选择
- **Cons**: 玩家失去控制感 + 算法复杂 + 与玩家心理模型不符(P5 玩家可能在家也想 brief)
- **Rejection**: 显式选择更符合 narrative 玩家偏好

## Consequences

### Positive

- 主消费 layer 锁定 = `#14`(SoC 守)
- writer 工作量约束 + 必填 standard(workload 可控)
- 三档 fallback 链明确(brief → standard → verbose)
- `#15 Recap` 共享逻辑(代码复用)
- ADR-0004 EVENT_ACTIVE 中途切档行为 + ADR-0009 schema 兼容

### Negative

- `#14` 实施稍复杂(`_select_*_by_density()` + fallback 链)
- writer 若全填三档,工作量 ×3(可选 brief/verbose 缓解)

### Risks

- **R-A12-1**: writer 不填 brief → 大部分 event 在 brief 模式 fallback 到 standard → P5 地铁玩节奏失序
  - **Mitigation**: 玩家测试反馈;若 brief fallback 频繁,优先补关键事件 brief
- **R-A12-2**: verbose 模式单 event 渲染 > 30 秒,违反 P5 90s/天 budget
  - **Mitigation**: writer 守 verbose 12 dialogue cap;CI lint 检查 dialogue 字数

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#10 Event Script` Rule 6 | 三档密度 effects | `_select_effects_by_density()` |
| `#14 Card Play UI` Rule 4 | 主消费 layer | `_on_event_started` 接收 density |
| `#15 Recap UI` Rule 5 | 周报三档 summary | 共享 fallback 逻辑 |
| `#17 Settings` Rule 5 | narrative_density 选项 | UI 提示 + 玩家心理模型 |
| ADR-0004 EVENT_ACTIVE 切档 | 当前事件用旧密度 | density 在 event_started 锁定 |
| ADR-0009 EventResource | 三档 effects + dialogue | fallback 链 + standard 必填 |

## Performance Implications

- **CPU**: density 选择 µs 级 + RichTextLabel 渲染 ms 级
- **Memory**: 三档 dialogue + effects ~ EventResource 增 5-10KB(工作量可控)
- **Load Time**: 200 events × ~10KB = ~2MB(可接受)
- **Network**: N/A

## Migration Plan

无现有代码:
1. `#14 Card Play UI` `_select_*_by_density()` + fallback 链实施
2. `#15 Recap UI` 共享 fallback 逻辑
3. CI lint `tools/event_schema_lint.py` 增 standard 必填检查
4. writer 工具(VS Code snippet)默认填 standard

## Validation Criteria

- 三档密度切换 → `#14` UI 渲染对应 dialogue/effects(集成测试)
- brief 缺失 fallback standard(单元测试 fixture)
- standard 缺失 → 实例化失败(CI lint 阻断)
- 单 verbose event 渲染 ≤ 30s(性能测试 + writer 守门)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(narrative_density_changed)
- ADR-0004 Settings Reflow Coalescing(EVENT_ACTIVE 切档行为)
- ADR-0009 Event Schema Format(三档 effects + dialogue)
- `#10 Event Script Engine` Rule 6
- `#14 Card Play Dialogue UI` Rule 4
- `#15 Recap UI` Rule 5
- `#17 Settings` Rule 5
