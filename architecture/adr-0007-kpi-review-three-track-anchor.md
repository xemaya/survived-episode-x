# ADR-0007: KPI Review Three-Track Anchor

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | UI / Audio / Rendering(三轨同步:UI + Audio + Lighting) |
| **Knowledge Risk** | LOW(Tween + AnimationPlayer + AudioStreamPlayer 4.0+ 稳定) |
| **References Consulted** | `docs/engine-reference/godot/modules/ui.md` / `audio.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(`kpi_review_started` signal owner = `#9`)+ ADR-0006(GAMEOVER transition 触发 owner) |
| **Enables** | `#16 KPI Review UI` 实施 + `#5 Lighting` KPI_REVIEW palette + `#4 Audio` 月末 stinger |
| **Blocks** | `#16` KPI Review screen coding(三轨锚 + 时长未定) |
| **Ordering Note** | P0 优先级第七 |

## Context

### Problem Statement

`/review-all-gdds` 2026-04-29 surface **B-SCN4-1 BLOCKING**:`kpi_review_intro_duration_ms` 三轨(UI fade-in + Audio BGM 切换 + Lighting palette swap)anchor 未跨 GDD 锁定。

具体未明:
- `#16 KPI Review UI` Section C: "intro fade-in"(无具体 duration)
- `#5 Lighting` Rule 1 KPI_REVIEW palette: 紫色 CanvasModulate(无切换 duration)
- `#4 Audio` Rule 7 月末 BGM 切换 + stinger:无 cross-fade 时长 / 启动锚

如三轨各自独立时序 → 视觉先紫 / 音频还旧 BGM / UI 还在工位 — 玩家感受到错位。

### Constraints

- `kpi_review_started` 信号是唯一启动锚(`#9` emit on monthly_kpi_settled at MONTH_END)
- `#16` 月末仪式感是 P3+P4 主轨(玩家"接受审判"的 ritual)
- `#5` palette swap 不可瞬间(违和)— 需 fade transition
- `#4` BGM 切换不可断 — 需 cross-fade
- 整体 intro 节奏不能太慢(P5 玩家在 90s/天 budget,月末快进 ritual)
- 不可与 GAMEOVER 1500ms transition 时长冲突(GAMEOVER 是另一锚)

### Requirements

- 三轨同步启动 + 同时长完成
- `kpi_review_intro_duration_ms` registry 注册
- 三轨各自 fade curve 协调

## Decision

### `kpi_review_intro_duration_ms = 800ms` 三轨同步锚

```
T+0ms        #9 KPI emit kpi_review_started
             ┃ (subscribers receive in same frame, ADR-0001 single dispatch)
             ┃
             ├─→ #16 KPI Review UI:
             ┃     - alpha 0 → 1 fade-in 800ms (Tween, ease=EASE_IN_OUT)
             ┃     - HR 戏谑标题文本 typewriter 800ms (与 fade 同时)
             ┃
             ├─→ #5 Lighting:
             ┃     - CanvasModulate (1.0,1.0,1.0) → (0.85,0.80,1.05) 紫色 800ms
             ┃     - Tween ease=EASE_IN_OUT
             ┃
             └─→ #4 Audio:
                   - 当前 BGM cross-fade out 800ms (linear)
                   - "月末 stinger" SFX play at T+0ms (可重叠 BGM tail)
                   - 月末 BGM (KPI_REVIEW theme) cross-fade in T+800ms+ (后续帧启动)

T+800ms      三轨完成同步 → KPI Review 主屏开始展示 breakdown 三行
```

### 信号订阅模式(`#9` emit + 三方 same-frame react)

```gdscript
# kpi_system.gd
signal kpi_review_started

# subscribers (ADR-0001 single dispatch):
# #16 KPI Review UI _on_kpi_review_started → tween 800ms
# #5 Lighting _on_kpi_review_started → palette swap 800ms
# #4 Audio _on_kpi_review_started → cross-fade + stinger
```

```gdscript
# #16 kpi_review_screen.gd
const INTRO_DURATION_MS := 800  # registry: kpi_review_intro_duration_ms

func _on_kpi_review_started() -> void:
    visible = true
    modulate.a = 0
    var tween := create_tween()
    tween.tween_property(self, "modulate:a", 1.0, INTRO_DURATION_MS / 1000.0)\
        .set_ease(Tween.EASE_IN_OUT)
    _typewriter_intro_title(INTRO_DURATION_MS)
    await tween.finished
    _start_breakdown_three_lines()  # 主屏内容
```

```gdscript
# #5 lighting_controller.gd
func _on_kpi_review_started() -> void:
    var tween := create_tween()
    tween.tween_property(canvas_modulate, "color", KPI_REVIEW_PURPLE_COLOR, 0.8)\
        .set_ease(Tween.EASE_IN_OUT)
```

```gdscript
# #4 audio_manager.gd
func _on_kpi_review_started() -> void:
    # cross-fade out current BGM
    cross_fade_bgm(null, 0.8)  # to silence
    # stinger 同帧 play
    play_sfx(&"sfx_month_end_stinger", bus=SFX)
    # 800ms 后 KPI_REVIEW theme cross-fade in (process loop 调度)
    await get_tree().create_timer(0.8).timeout
    play_bgm(&"bgm_kpi_review", cross_fade_seconds=0.5)
```

### Registry 注册

`design/registry/entities.yaml` 增 1 constant:

```yaml
- name: kpi_review_intro_duration_ms
  type: constant
  value: 800
  unit: ms
  source: docs/architecture/adr-0007-kpi-review-three-track-anchor.md
  referenced_by:
    - design/gdd/kpi-review-game-over-ui.md  # #16
    - design/gdd/lighting-visual-state.md     # #5
    - design/gdd/audio-manager.md             # #4
  rationale: "三轨同步锚:UI fade-in + Lighting palette swap + Audio cross-fade 同时长。月末仪式感节奏(慢于 200ms 瞬切,快于 1500ms GAMEOVER)。"
```

### 与 GAMEOVER transition 区分

| 锚 | Duration | Trigger | Purpose |
|----|----------|---------|---------|
| `kpi_review_intro_duration_ms` | 800ms | `kpi_review_started`(月末 entrance) | KPI Review 主屏 intro,可继续游玩 |
| `final_transition_duration_ms` | 1500ms | `game_over_triggered`(玩家被解雇,不可逆) | GAMEOVER 离职证明 transition,linear easing=NONE,接 ARCHIVING |

## Alternatives Considered

### Alternative 1: 三轨各自独立 duration(UI 600 / Lighting 1000 / Audio 800)

- **Pros**: 各 GDD 自治
- **Cons**: 玩家感受到三轨错位
- **Rejection**: B-SCN4-1 BLOCKING — 必须同步

### Alternative 2: 200ms 瞬切

- **Pros**: 节奏快
- **Cons**: 月末 ritual 仪式感弱;palette swap 200ms 违和
- **Rejection**: P3+P4 月末仪式感优先

### Alternative 3: 1500ms 长切

- **Pros**: 仪式感强
- **Cons**: 与 GAMEOVER 1500ms 撞车;P5 90s/天 budget 月末过慢
- **Rejection**: 必须区别于 GAMEOVER

### Alternative 4: 600ms

- **Pros**: 比 800ms 略快
- **Cons**: palette swap 600ms 仍偏快(实测延 OQ)
- **Rejection**: 800ms 平衡(实测如有问题可调)

## Consequences

### Positive

- 三轨同步锚 800ms 锁定,B-SCN4-1 BLOCKING 仲裁
- 与 GAMEOVER 1500ms 区别清晰(短 ritual vs 长 final)
- registry 注册 + 3 GDD 引用统一

### Negative

- 800ms 是 hardcoded judgment call — 实测可能调到 600/1000(预留 OQ)
- 三轨 dispatch 同帧 — `kpi_review_started` 性能预算 16.6ms(应充足)

### Risks

- **R-A7-1**: 三轨 Tween 同帧启动,Tween 内部时序差异致最终完成时间不一致(±1 帧)
  - **Mitigation**: 800ms 远大于 16.6ms 帧长,误差可忽略;若需精确同步,改用 AnimationPlayer 单 track
- **R-A7-2**: 800ms 用户测试反馈过慢/过快
  - **Mitigation**: registry 单点修改 + 3 GDD 同步;tuning 阶段调整

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#16 KPI Review UI` Section C | intro fade-in | 800ms Tween EASE_IN_OUT |
| `#5 Lighting` Rule 1 | KPI_REVIEW palette swap | 800ms CanvasModulate Tween |
| `#4 Audio` Rule 7 | 月末 BGM 切换 + stinger | 800ms cross-fade + same-frame stinger |
| `#9 KPI` Rule 17 | kpi_review_started 三轨同步 | ADR 锚定 |

## Performance Implications

- **CPU**: 三轨 Tween 同帧启动 ~µs 级 dispatch + 800ms 持续 Tween update ~负担可忽略
- **Memory**: Tween 实例 < 1KB
- **Load Time**: N/A
- **Network**: N/A

## Migration Plan

无现有代码:
1. registry `kpi_review_intro_duration_ms = 800` 注册
2. `#16 / #5 / #4` GDD Section C 引用 const
3. 三系统各自 `_on_kpi_review_started` 实现 800ms Tween
4. 实测调整(若 600 / 1000 更佳,改 registry 单点)

## Validation Criteria

- 三轨同步完成时间偏差 ≤ 1 帧(集成测试 fixture)
- `kpi_review_intro_duration_ms` registry 引用与三 GDD 一致(consistency-check)
- 与 `final_transition_duration_ms = 1500ms` 不冲突(单元测试覆盖两路径)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(`kpi_review_started` owner = `#9`)
- ADR-0006 Dismissal/GAMEOVER Path(1500ms transition vs 800ms ritual 区分)
- entities.yaml(`kpi_review_intro_duration_ms` 注册)
- `#16 KPI Review UI` Section C
- `#5 Lighting` Rule 1
- `#4 Audio` Rule 7
- `#9 KPI` Rule 17
