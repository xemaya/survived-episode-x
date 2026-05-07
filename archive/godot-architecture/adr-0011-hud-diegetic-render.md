# ADR-0011: HUD Diegetic Render Architecture

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | UI / Rendering(Control + 2D Node 二分;CanvasLayer 边界)|
| **Knowledge Risk** | LOW(2D + Control 4.0+ 稳定)|
| **References Consulted** | `docs/engine-reference/godot/modules/ui.md` / `rendering.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(8 信号订阅 ownership)+ ADR-0005(accumulation_event 4 维度) |
| **Enables** | `#13 HUD Diegetic` 实施 + `art-bible §7.1` no overlay 主轨 |
| **Blocks** | HUD coding(diegetic vs Control 边界未定) |
| **Ordering Note** | P2 优先级第一(system-build sync) |

## Context

### Problem Statement

`art-bible §7.1` Pillar 4 主轨锁定:HUD 必须 diegetic(融入工位场景),不准 screen-overlay。但实施层面有 4 类元素混合存在:
1. 工位场景 2D Node(咖啡杯 / 文件 stack / 椅子 / 便利贴 / NPC 表情 / 蒸汽)
2. CanvasLayer 上的"伪 overlay"信息(KPI 进度条放在墙上日历?)
3. 真 Control 节点(月末 KPI Review 进入时的 UI)
4. 通知(`#19`)文本气泡(短暂浮现,该 diegetic 还是 overlay?)

边界不明 → coding 时各组件随手用 Control 致 P4 红线被破。

### Constraints

- art-bible §7.1 no overlay 主轨严
- `#13 HUD` 8 元素全 diegetic(2D Node 在 SubViewport)
- KPI Review 月末 transitio 是"sub-mode 切换"(`#6` ACTION_DAY → KPI_REVIEW)— Control 允许
- `#19 Notification` 文本气泡是工位 diegetic 元素(便利贴 / 屏幕弹窗)— 不是 overlay
- 性能预算 100 draw call(2D 像素)

### Requirements

- diegetic 工位场景 vs Control UI 边界明确
- CanvasLayer 使用规约(深度 + 可见性)
- `#13 HUD` 8 元素节点树 + 信号订阅

## Decision

### 节点树架构

```
/root/
├── SceneDayFlowController (Autoload)
│
└── World (CurrentScene):
    │
    ├── DiegeticHUD (Node2D)               # diegetic 主层 — 8 元素全在此
    │   ├── DeskCoffeeMug (Node2D)
    │   │   ├── CoffeeIcon (Sprite2D)
    │   │   └── SteamParticle (CPUParticles2D)  # ADR-0008 hero card 反馈
    │   ├── DeskDocumentStack (Node2D)
    │   │   ├── DocStackIcon (Sprite2D)
    │   │   └── PageFlipAnim (AnimationPlayer)
    │   ├── DeskStickyNotes (Node2D)
    │   │   └── [12 sticky_note 节点 dynamic spawn] (ADR-0005)
    │   ├── NoticeBoard (Node2D)            # 24 元素 fading paper
    │   │   └── [24 NoticeBoardEntry] (RichTextLabel — 局部 Control 渲染文本)
    │   ├── OfficeSteam (Node2D)
    │   │   └── SteamLayer (TextureRect with modulate.a)  # ADR-0005 dimensions
    │   ├── NPCExpression (Node2D)          # per-NPC 节点 cluster
    │   ├── NPCPosition (Node2D)            # 椅子 + dust + visibility
    │   └── CalendarKPIIndicator (Node2D)   # 墙上日历 = "diegetic KPI 进度条"
    │
    ├── DiegeticNotifications (Node2D)      # `#19` Notification — 短暂浮现 sticky note 元素
    │
    └── CanvasLayer (layer=1):              # 真正 UI Control 仅此一层
        ├── PauseMenu (Control) [hidden by default]
        ├── KPIReviewScreen (Control) [hidden by default]    # `#16` 月末进入显示
        ├── GameOverScreen (Control) [hidden by default]     # `#16` 1500ms transition
        └── SettingsScreen (Control) [hidden by default]
```

### diegetic vs Control 二分规约

| 类别 | 节点类型 | layer | 何时使用 |
|------|---------|-------|---------|
| **diegetic 工位场景** | Node2D + Sprite2D + Sprite2D 子节点 | 0(World)| 默认所有 HUD 信息 |
| **diegetic 文本** | Node2D + Sprite2D bg + Label 子节点(局部 Control 仅文本)| 0 | 文本必要时(便利贴上的字)|
| **diegetic 通知** | Node2D 浮现 + Tween 渐显渐隐 | 0 | `#19` Notification |
| **真 UI Control** | CanvasLayer + Control | 1 | sub-mode 切换屏(月末 KPI / GAMEOVER / Pause / Settings)|

### CanvasLayer 使用规约

```gdscript
# CanvasLayer layer 仅 = 1(单一 UI 层)
# 严禁:
# - 在 ACTION_DAY sub-mode 期间显示 CanvasLayer 内容(违反 P4)
# - 多 CanvasLayer 嵌套
# - CanvasLayer.visible = true 在 ACTION_DAY 期间(除 Pause / Settings 玩家主动)

func _on_scene_state_changed(from, to) -> void:
    canvas_layer.visible = to in [&"PAUSE", &"SETTINGS", &"KPI_REVIEW", &"GAMEOVER"]
    # ACTION_DAY / EVENT_ACTIVE / WEEKEND / MAIN_MENU → CanvasLayer hidden
```

### 8 元素信号订阅(ADR-0001 + ADR-0005)

| HUD 元素 | 订阅信号 | 视觉响应 |
|---------|---------|---------|
| DeskCoffeeMug | `hero_card_played`(ADR-0008) | SteamParticle.emit |
| DeskDocumentStack | `event_completed` + `hero_card_played` | PageFlipAnim |
| DeskStickyNotes | `accumulation_event(sticky_note_count)` | dynamic spawn 1 节点 |
| NoticeBoard | `npc_left_company`(R-NPC-2)+ `event_completed` | RichTextLabel.parse_bbcode + age fade |
| OfficeSteam | `accumulation_event(steam_density)` | TextureRect.modulate.a Tween |
| NPCExpression | `relationship_changed` + `npc_lifecycle_changed` | 表情 frame 切换 |
| NPCPosition | `accumulation_event(npc_empty_chairs)` + `npc_lifecycle_changed` | 椅子 visibility + dust 渐显 |
| CalendarKPIIndicator | `kpi_threshold_changed` | 日历角图标渐变(diegetic KPI 进度条)|

### 性能预算守门

```gdscript
# DiegeticHUD performance contract:
# - 8 元素静态节点 ~24 draw call
# - 12 sticky_note dynamic + 24 NoticeBoardEntry + ~10 dust → ~46 dynamic draw call
# - 总 ≤ 70 draw call 预算(留余给场景背景 + lighting)
# - Godot 4.6 自动 batching 应将 draw call 进一步聚合
```

### Architecture Diagram

```
World (Node2D, layer=0)
├── Background (TileMap) - 工位背景静态 ~10 draw call
├── DiegeticHUD (Node2D) - 8 elements, ~46 draw call
│   ├── 8 elements 各自 subscribe ADR-0001 signals
│   └── art-bible §7.1: no overlay 守门
├── DiegeticNotifications (Node2D) - `#19` 短暂浮现
└── PlayerWorkstation (Node2D) - 玩家工位中心

CanvasLayer (layer=1) - **仅** sub-mode 切换屏 (PAUSE / KPI_REVIEW / GAMEOVER / SETTINGS)
├── PauseMenu (Control)
├── KPIReviewScreen (Control)
├── GameOverScreen (Control)
└── SettingsScreen (Control)
```

## Alternatives Considered

### Alternative 1: 全 Control + Theme 模拟 diegetic

- **Pros**: UI 工具链统一
- **Cons**: Control 是 screen-space,违反 art-bible §7.1 主轨;无法与 World 元素自然 occlusion
- **Rejection**: 主轨破

### Alternative 2: 多 CanvasLayer 分层(HUD layer=0 / UI layer=1 / Notifications layer=2)

- **Pros**: 视觉层清晰
- **Cons**: 违反 diegetic 主轨(任何 CanvasLayer overlay 都是 UI overlay 风格)
- **Rejection**: 单 CanvasLayer 才能守 art-bible

### Alternative 3: SubViewport 嵌套(diegetic 在 SubViewport 内)

- **Pros**: 完全隔离 diegetic vs UI
- **Cons**: SubViewport 性能开销 + 输入事件路由复杂
- **Rejection**: 简单 Node2D 架构已够用

## Consequences

### Positive

- diegetic 工位场景 vs Control UI 二分明确
- CanvasLayer 仅 1 层,严禁 ACTION_DAY 期间使用
- 8 元素全 Node2D + 信号订阅链明确
- 性能预算 70 draw call < 100 budget(P5 守)

### Negative

- diegetic 文本(便利贴上的字)Label 子节点在 Node2D — 需手动管理 z-index;未来若有大量文本可能性能问题
  - Mitigation: NoticeBoard 24 元素 cap + RichTextLabel 自动 batching
- KPI 进度信息只能用日历角图标 — 玩家可能初次看不懂
  - Mitigation: `#18 Tutorial` Onboarding 阶段提示 + 日历附近 NPC 对白引导

### Risks

- **R-A11-1**: 8 元素 + 12 sticky + 24 notice + steam Tween 同帧绘制超 70 draw call
  - **Mitigation**: 实测 OQ-HUD-PERF-01 + 静态 Texture batching + 减 sticky/notice cap
- **R-A11-2**: 玩家"找不到 UI"(diegetic 信息隐藏太深)
  - **Mitigation**: 玩家测试 + Tutorial 强引导

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#13 HUD Diegetic` Rule 1 | 8 diegetic 元素 | 8 Node2D in DiegeticHUD |
| art-bible §7.1 | no overlay 主轨 | CanvasLayer 仅 sub-mode 切换屏 |
| `#5 Lighting` ADR-0005 | accumulation_event 4 维度 | 4 元素订阅 |
| `#19 Notification` | diegetic 通知 | DiegeticNotifications Node2D |
| `#16 KPI Review UI` | sub-mode 切换屏 | CanvasLayer KPIReviewScreen |

## Performance Implications

- **CPU**: 8 静态元素 + dynamic spawn 微开销;CanvasLayer 仅 sub-mode 时显示
- **Memory**: 节点树 < 5MB;Texture ~20MB
- **Load Time**: 工位场景加载 ~50ms
- **Network**: N/A

## Migration Plan

无现有代码:
1. World scene 创建 + DiegeticHUD 节点树
2. CanvasLayer 创建 + 4 sub-mode screen
3. 8 元素各自实施(节点 + 信号订阅)
4. 工位 Background TileMap 实施
5. CI lint 工具检查 — `art-bible §7.1` lint:任何 ACTION_DAY 期间 CanvasLayer.visible = true 阻断 PR

## Validation Criteria

- 8 HUD 元素全部在 DiegeticHUD Node2D 下(节点树验证)
- CanvasLayer 仅 sub-mode 切换屏使用(自动化测试 fixture)
- 总 draw call ≤ 100(性能测试)
- `art-bible §7.1` lint 通过

## Related Decisions

- ADR-0001 Signal Ownership Matrix(8 元素订阅信号)
- ADR-0005 Lighting Accumulation 4 Dimensions(4 元素订阅 accumulation_event)
- ADR-0008 Visual Boundary Pillar 4(hero card 反馈三 element)
- `#13 HUD Diegetic` GDD
- art-bible §7.1 no overlay 主轨
- `#19 Notification` 通知系统
