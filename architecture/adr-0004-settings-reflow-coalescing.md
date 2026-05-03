# ADR-0004: Settings Reflow Coalescing

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | UI / Localization / Core |
| **Knowledge Risk** | LOW(NOTIFICATION_TRANSLATION_CHANGED 4.0+ 稳定) |
| **References Consulted** | `docs/engine-reference/godot/modules/ui.md` / `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(Signal Ownership Matrix — `narrative_density_changed` owner = `#17`)+ ADR-0002(Autoload — `#6` Settings 防抖单 timer 持有方) |
| **Enables** | `#17 Settings UI` 实施 + `#3 Loc` reflow 实现 + `#20 Accessibility` 字体切换 |
| **Blocks** | Settings 子屏 coding(防抖窗内多信号合流策略未定) |
| **Ordering Note** | P0 优先级第四 |

## Context

### Problem Statement

`/review-all-gdds` 2026-04-29 surface **B-SCN4-2 BLOCKING**:settings 防抖窗内多信号 reflow 合流策略未跨 GDD 锁定。

具体场景:玩家在 `#17` Settings 子屏快速依次切多控件 → 6 信号(`bus_volume_changed` × 4 + `locale_changed` + `keymap_changed` + `narrative_density_changed` + `font_size_changed` + `colorblind_mode_changed`)在 `#6 Rule 7` 500ms debounce 窗内同帧到达。

**关键冲突**:
- `font_size_changed` + `locale_changed` 同帧 → `#3 Loc` `NOTIFICATION_TRANSLATION_CHANGED` 广播两次 vs 合并一次?
- `narrative_density_changed` 在 `#10 EVENT_ACTIVE` 态切档行为未定义(当前事件用旧密度还是新密度?)
- `#3 Loc R-LOC-3` 30s watchdog `process_mode = PAUSE_INHERIT` 在 PAUSE 中改 locale 是否触发 reflow 未明
- `#5 Lighting R-LVS-5` `notice_board_age` Array(已渲染 24 元素)在二次 reflow 中可能 fallback 字体缺失

### Constraints

- `meta_settings_debounce_ms = 500` registry 锁(Save Rule 14)
- `#6 Rule 7` settings 防抖单 timer 共享(per-signal-key 独立防抖被禁)
- `#3 Loc Rule 5` reflow 端到端 ≤ 500ms / dispatch ≤ 1 帧
- `#20 Accessibility` 字体大小 4 档 + 色盲 3 档需即时反馈
- 玩家可在 PAUSE 子屏内打开 Settings(SceneTree.paused = true 期间)

### Requirements

- 多 settings 信号同帧 → reflow 广播单次
- EVENT_ACTIVE 态切 narrative_density 行为定义
- PAUSE 中 locale_changed reflow 行为定义
- R-LVS-5 + R-A11Y-2 二次 reflow 防 fallback 缺失

## Decision

### 1. Settings 防抖窗合流协议(`#6 Rule 7` 实施细节)

```gdscript
# scene_day_flow_controller.gd Rule 7
var _settings_debounce_timer: Timer
var _pending_settings_changes: Dictionary = {}  # signal_name → latest payload
var _reflow_required: bool = false  # 任意 reflow 影响信号触发

func _on_setting_signal_received(signal_name: String, payload: Variant) -> void:
    _pending_settings_changes[signal_name] = payload
    # reflow 影响信号清单
    if signal_name in [&"locale_changed", &"font_size_changed", &"colorblind_mode_changed"]:
        _reflow_required = true
    # reset timer
    _settings_debounce_timer.start(0.5)  # 500ms

func _on_settings_debounce_timeout() -> void:
    # 合并 payload 单次落盘
    SaveSystem.save_settings_payload(_pending_settings_changes)
    # **单次** NOTIFICATION_TRANSLATION_CHANGED 广播(若 reflow_required)
    if _reflow_required:
        LocalizationHooks.broadcast_translation_changed_once()
    _pending_settings_changes.clear()
    _reflow_required = false
```

### 2. `LocalizationHooks.broadcast_translation_changed_once()` 实现

```gdscript
# localization_hooks.gd Rule 5 + B-SCN4-2 仲裁
func broadcast_translation_changed_once() -> void:
    # 单次广播,所有订阅者(#13 / #14 / #15 / #16 / #17 等)同帧响应
    get_tree().root.propagate_notification(NOTIFICATION_TRANSLATION_CHANGED)
    # 等待 1 帧让所有 RichTextLabel rebuild
    await get_tree().process_frame
    # R-LVS-5 守:notice_board_age Array 24 元素若已渲染,reflow watchdog 30 帧守门
    LightingController.flush_pending_reflow()  # 累积视觉元素 reflow 守
```

### 3. EVENT_ACTIVE 态切 `narrative_density_changed` 行为(W-SCN4-5 仲裁)

**决策**:**当前 long 事件用旧密度完成,新密度从下次 `event_started` 起生效**。

理由:
- 玩家在 long 事件中途切密度极少(玩家专注于读对白)
- 中途切档破坏叙事节奏(P5 90s 一天 budget 失序)
- 实施简单(`#10` `EventScriptEngine` 在 `event_started` 时读取当前 `narrative_density` 锁定到事件结束)

```gdscript
# event_script_engine.gd state machine EVENT_ACTIVE
func _on_narrative_density_changed(new_tier: NarrativeTier) -> void:
    if state == EventState.EVENT_ACTIVE:
        # 当前事件不切,下个事件起生效
        _pending_density_for_next_event = new_tier
    else:
        _current_density = new_tier
```

### 4. PAUSE 中 `locale_changed` reflow 行为(W-SCN4-6 仲裁)

**决策**:reflow 在 PAUSE 期间**挂起**,resume 后单次 emit。

理由:
- 玩家在 PAUSE 子屏(Settings UI)改 locale,但游戏世界静止 — UI rebuild 立即可见(Settings UI 自身)
- 游戏世界 UI(`#13 HUD` 在工位场景)在 PAUSE 后台已不渲染主帧,等 resume 自然 reflow
- `#3 Loc R-LOC-3` 30s watchdog `PAUSE_INHERIT` 已挂起 — 与本决策一致

```gdscript
# localization_hooks.gd Rule 5 PAUSE 边界
func broadcast_translation_changed_once() -> void:
    if get_tree().paused:
        # PAUSE 期间挂起,标记待 resume 后广播
        _pending_translation_change = true
        return
    # 正常路径
    get_tree().root.propagate_notification(NOTIFICATION_TRANSLATION_CHANGED)

# scene_day_flow_controller.gd
func request_soft_resume() -> void:
    SceneTree.paused = false
    if LocalizationHooks._pending_translation_change:
        LocalizationHooks.broadcast_translation_changed_once()  # resume 后单次 emit
```

### 5. R-LVS-5 + R-A11Y-2 二次 reflow 守门

`#5 Lighting` `notice_board_age` Array(24 元素 Label)在 reflow 时 fallback 路径:

```gdscript
# lighting_controller.gd Rule 11 mute_visual_parity + R-LVS-5 fallback
func flush_pending_reflow() -> void:
    # 24 个 notice_board Label 全部触发 RichTextLabel.parse_bbcode()
    for label in notice_board_labels:
        label.parse_bbcode(tr(label.localization_key))
        # 字体 fallback 链(`#3 Rule 9`):
        # Step 0: 直接渲染 → Step 1: Compact variant → Step 2: auto_fit (floor 11) → Step 3: 截断 + push_warning
    # 30 帧守门(`#3 R-LOC-3` 同质):若 reflow 超 30 帧,push_warning + force flush
```

## Alternatives Considered

### Alternative 1: per-signal-key 独立防抖

- **Pros**: 精细化每个 setting 各自时序
- **Cons**: 违反 `#6 Rule 7`(已禁);6 信号同帧致 6 次 reflow 广播性能爆炸
- **Rejection**: 已在 W-SCN-3 仲裁拒绝

### Alternative 2: EVENT_ACTIVE 态中途切密度

- **Pros**: 玩家"立即生效"反馈
- **Cons**: 破坏当前事件叙事节奏 + 实施复杂(event 立绘 / 对白渲染需切换)
- **Rejection**: P5 90s budget 优先

### Alternative 3: PAUSE 中即时 reflow(不挂起)

- **Pros**: 玩家立即看到反馈
- **Cons**: SceneTree.paused = true 期间游戏 UI 不渲染,reflow 浪费;`#3 R-LOC-3` watchdog `PAUSE_INHERIT` 不一致
- **Rejection**: PAUSE 应静止

## Consequences

### Positive

- 6 信号同帧 → 单次 NOTIFICATION_TRANSLATION_CHANGED 广播(性能优化 6×)
- EVENT_ACTIVE 态 narrative_density 中途切档行为明确(P5 节奏守)
- PAUSE 中 locale reflow 行为与 R-LOC-3 watchdog 一致
- R-LVS-5 + R-A11Y-2 二次 reflow fallback 链明确

### Negative

- 玩家在 PAUSE 改 locale 后,resume 时 1 帧 reflow burst — 可能瞬间卡顿(实测延 OQ)
- `#10 EventScriptEngine` 多一变量 `_pending_density_for_next_event`(微 maintenance cost)

### Risks

- **R-A4-1**: 24 个 notice_board Label 全 reflow 超 30 帧
  - **Mitigation**: 实测 OQ-LOC-09 + AC-PERF-04;若超 30 帧,降级渲染分批 + push_warning
- **R-A4-2**: PAUSE → resume 时 1 帧 reflow burst 可见
  - **Mitigation**: resume 时 fade-in 0.2s 掩盖 reflow 帧;profiler 实测延 Pre-Production

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#6 Rule 7` | settings 防抖单 timer + 信号合流 | `_pending_settings_changes` Dictionary |
| `#3 Loc Rule 5` | reflow 端到端 ≤ 500ms / dispatch ≤ 1 帧 | broadcast_translation_changed_once() 单次广播 |
| `#10 Rule 6` | 三档密度切换 | EVENT_ACTIVE 态延后生效 |
| `#5 R-LVS-5` | notice_board reflow fallback | 24 元素分批 + 30 帧守门 |
| `#20 R-A11Y-2` | 字体 + 色盲二次 reflow | 5 节流 fallback 链 |

## Performance Implications

- **CPU**: 6 信号同帧 → 1 次广播(节流 6×);单次 reflow ≤ 30 帧
- **Memory**: `_pending_settings_changes` Dictionary < 1KB
- **Load Time**: N/A(运行时操作)
- **Network**: N/A

## Migration Plan

无现有代码:
1. `#6 SceneDayFlow` Rule 7 实现 `_settings_debounce_timer` + `_reflow_required` flag
2. `#3 LocalizationHooks` 实现 `broadcast_translation_changed_once()` + PAUSE 挂起
3. `#10 EventScriptEngine` 实现 `_pending_density_for_next_event`
4. `#5 LightingController` 实现 `flush_pending_reflow()` 24 元素分批
5. CI 单元测试覆盖 6 信号同帧 race + PAUSE → resume reflow burst

## Validation Criteria

- 6 settings 信号同帧 → NOTIFICATION_TRANSLATION_CHANGED 仅 1 次广播(单元测试 fixture)
- EVENT_ACTIVE 态切 narrative_density → 当前事件用旧密度 + 下个事件用新密度(集成测试)
- PAUSE 中改 locale → SceneTree.paused = false 后单次 emit(集成测试)
- 24 notice_board reflow ≤ 30 帧(性能测试)

## Related Decisions

- ADR-0001 Signal Ownership(`narrative_density_changed` owner = `#17`)
- ADR-0002 Autoload(`#6` 持 settings 防抖 timer)
- `#6 Rule 7` settings 防抖单 timer
- `#3 Loc Rule 5` reflow 协议
- `#5 R-LVS-5` notice_board fallback
- `#20 R-A11Y-2` 字体 + 色盲 reflow
