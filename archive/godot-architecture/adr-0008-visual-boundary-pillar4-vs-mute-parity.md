# ADR-0008: Visual Boundary — Pillar 4 vs Mute Visual Parity

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Rendering / Accessibility(VFX + Audio Mute parity) |
| **Knowledge Risk** | LOW(2D 视觉效果 4.0+ 稳定) |
| **References Consulted** | `docs/engine-reference/godot/modules/rendering.md` / `current-best-practices.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(Signal Ownership Matrix)|
| **Enables** | `#5 Lighting` Rule 11 + `#13 HUD Diegetic` Hero card UI feedback + `#20 Accessibility` mute visual parity |
| **Blocks** | Hero card 视觉反馈 coding(金光禁与 mute parity 守门间冲突) |
| **Ordering Note** | P0 优先级第八(末位 P0) |

## Context

### Problem Statement

`/review-all-gdds` 2026-04-29 surface **B-AC-1 BLOCKING**:Pillar 4(NOT 励志叙事 — 不准放金光特效)与 `#20 Accessibility` mute_visual_parity(关 BGM 后所有"重要 ludic event"必须有视觉反馈替代)矛盾。

具体场景:Hero card 玩出后(P5 偶尔的"高光时刻"卡):
- Pillar 4 红线:**禁金光 / 禁 sparkle / 禁庆祝粒子效果**(避免商业鸡汤)
- mute_visual_parity 红线:**关 BGM 玩家须有视觉反馈"我做对了"**(无障碍 P1)

如何在不引入金光的前提下,提供 mute parity?

### Constraints

- Pillar 4 黑色幽默禁 5 类视觉(金光 / sparkle / 烟花 / 彩虹 / 鸡汤 caption)
- `#20 Accessibility` Rule 3 mute_visual_parity:关 BGM(`bus_volume_changed BGM=-80db`)时,所有"reward 信号"必须有视觉等价
- `#11 Action Card` Hero card 是 reward signal(玩家"做对了高光时刻")
- `#5 Lighting` Pillar 4 主轨 — 不能引入逃逸阀
- 不可在 mute 模式下用"另一套视觉"(违反 a11y "无差别" 原则)

### Requirements

- Hero card 玩出后视觉反馈方案不引入 5 禁视觉
- mute / 非 mute 模式视觉反馈一致(不分裂)
- 与 P3 死亡叙事 + P4 黑色幽默呼应

## Decision

### Hero card 视觉反馈 = "克制 dignified 的 desk vignette"

**取代金光的方案**:Hero card 玩出后,**桌面元素发生 1 帧的 negative space 反馈**:

| Element | 反馈 | Pillar 守 |
|---------|------|-----------|
| **HUD_DESK_COFFEE_MUG** | 杯口蒸汽弹出 1 个粒子 → 0.5s 渐隐 | 黑色幽默(咖啡是日常工具,不是庆祝) |
| **HUD_DESK_DOCUMENT_STACK** | 文件 stack 顶部 1 张纸"翻页" 0.3s 动画 | 工作完成的 negative gesture(P4 苦中作乐) |
| **HUD_NPC_EXPRESSION** | 邻座 NPC 表情 0.5s flash "raised eyebrow" 反应 + return | 同事的"哦"反应(P4 黑色幽默) |
| **HUD_OFFICE_AMBIENT_LIGHT** | CanvasModulate 极轻微 +0.05 brightness 0.5s,然后 return | **不是金光,是"窗外阴天偶尔透光"的瞬间** |

### mute_visual_parity 守

非 mute 模式:三视觉反馈 + Hero card SFX(`sfx_hero_card_played`,bus=SFX,音量 +3db)
mute 模式:三视觉反馈 + Hero card SFX(因 SFX bus 不在 mute 列表,继续播放;**或** `bus_volume_changed BGM=-80db` 单独 mute BGM 时)

**关键**:mute 列表只 mute BGM bus,不 mute SFX bus(`#20` Rule 4)。Hero card SFX 继续可听 → 视觉反馈是"加强"不是"替代"。

但若玩家**全 mute**(BGM + SFX 全 -80db),则视觉反馈是唯一 channel — 三 element 1 帧 negative space gesture 已能传达"做对了"。

### 与 5 禁视觉对照

| Pillar 4 5 禁视觉 | 本 ADR 反馈 | 是否冲突 |
|------------------|------------|---------|
| 金光 | 仅 +0.05 brightness 0.5s(不是 +0.5)| ✅ 不冲突(微调而非辉煌) |
| Sparkle | 1 个咖啡蒸汽粒子(物理而非魔法)| ✅ 不冲突 |
| 烟花 | 文件翻页(工作而非庆祝)| ✅ 不冲突 |
| 彩虹 | 无 | ✅ 不冲突 |
| 鸡汤 caption | NPC raised eyebrow(沉默 gesture 而非台词)| ✅ 不冲突 |

### `#5 Lighting` Rule 11 实施

```gdscript
# lighting_controller.gd Rule 11 (Hero card 反馈)
func _on_hero_card_played(card_id: StringName) -> void:
    # 微调 ambient 0.05 brightness 0.5s
    var current := canvas_modulate.color
    var lifted := current + Color(0.05, 0.05, 0.05, 0.0)
    var tween := create_tween()
    tween.tween_property(canvas_modulate, "color", lifted, 0.25)\
        .set_ease(Tween.EASE_OUT)
    tween.tween_property(canvas_modulate, "color", current, 0.25)\
        .set_ease(Tween.EASE_IN)
```

```gdscript
# #13 HUD diegetic_hud.gd Rule N (Hero card 三 element 反馈)
func _on_hero_card_played(card_id: StringName) -> void:
    desk_coffee_mug.play_steam_particle()  # 1 粒子,0.5s
    desk_document_stack.play_page_flip()    # 0.3s
    npc_expression_node.flash_raised_eyebrow()  # 0.5s
```

### 与 KPI_REVIEW palette 区分

| Trigger | Lighting 反馈 | Duration |
|---------|--------------|----------|
| `hero_card_played` | +0.05 brightness 微调 0.5s,return | 0.5s |
| `kpi_review_started` | 紫色 palette swap 0.85,0.80,1.05 | 800ms(ADR-0007) |
| `game_over_triggered` | 灰色 palette `(0.6, 0.6, 0.6, 1.0)` | 1500ms |

### Hero card 频次约束(防麻木)

`#7 AP Rule 12`:Hero card 月内最多 4 次(`hero_card_played_this_month` 上限)+ `#9 capacity_factor` 月底接近 cap 时 Hero card 加成 ↓ → 视觉反馈也"克制"(不每次都 0.05 brightness,M3+ 月份可降到 0.03)。

## Alternatives Considered

### Alternative 1: 完全无视觉反馈(只 SFX)

- **Pros**: 完美符合 Pillar 4 红线
- **Cons**: 违反 mute_visual_parity(全 mute 玩家无反馈 → a11y P1 fail)
- **Rejection**: a11y 不可妥协

### Alternative 2: 金光 + a11y 模式下替换为其他视觉

- **Pros**: 商业 polish 符合普通玩家期望
- **Cons**: 违反 Pillar 4 + 违反 a11y "无差别" 原则
- **Rejection**: 双红线

### Alternative 3: 屏幕震动(screen shake)替代金光

- **Pros**: 不属于 5 禁
- **Cons**: 与 Hero card 的"夸夸"语义不符(震动是冲击);a11y 视觉敏感玩家(VS 起 reduce_motion)需排除
- **Rejection**: 语义错位

### Alternative 4: UI 文本框 "+1 hero card played"

- **Pros**: 明确反馈
- **Cons**: 违反 `#13 HUD Diegetic` 主轨(no overlay UI);P3 黑色幽默不需要"成就解锁"风格
- **Rejection**: 违反 diegetic 主轨

## Consequences

### Positive

- B-AC-1 BLOCKING 仲裁:Pillar 4 + mute_visual_parity 双红线兼顾
- 视觉反馈"克制 dignified" — 与 P3+P4 主轨呼应
- mute 模式三视觉 element 反馈足够独立传达"做对了"
- `#5 Lighting` Rule 11 + `#13` 三 element 反馈实施明确

### Negative

- 反馈较克制 — 玩家可能不立即注意到 Hero card 玩出(尤其首次 Run)
  - **Mitigation**: `#18 Tutorial` Onboarding 阶段提示"Hero card 视觉反馈是 dignified gesture,不是金光"
- 三 element 反馈实施分散在 3 节点(咖啡 / 文件 / NPC)— 微 maintenance cost

### Risks

- **R-A8-1**: 玩家测试反馈"反馈不明显"
  - **Mitigation**: registry tuning(`hero_card_brightness_lift = 0.05`)可单点调到 0.07;但绝不超 0.10
- **R-A8-2**: 全 mute 玩家(VS 起 deaf 模式)在不看屏幕时仍漏掉
  - **Mitigation**: VS 起 `#20 Rule 8` 手柄震动(rumble)替代;MVP 不实施

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#5 Lighting` Rule 11 | Hero card brightness lift | +0.05 0.5s |
| `#13 HUD Diegetic` Rule N | 三 element 反馈 | 咖啡 + 文件 + NPC expression |
| `#20 Accessibility` Rule 3 | mute_visual_parity | 全 mute 时三视觉 element 独立传达 |
| Pillar 4 (NOT 励志叙事) | 5 禁视觉守 | 微调而非金光 |
| Pillar 3 (死亡叙事) | dignified gesture | 不庆祝,只承认 |

## Performance Implications

- **CPU**: 3 element 反馈同帧 ~µs 级 + 0.5s Tween 更新可忽略
- **Memory**: 3 Tween 实例 + 1 粒子 ~ 1KB
- **Load Time**: N/A
- **Network**: N/A

## Migration Plan

无现有代码:
1. `#5 Lighting` Rule 11 实施 brightness lift Tween
2. `#13 HUD` 3 element 反馈节点(咖啡蒸汽 / 文件翻页 / NPC raised eyebrow)
3. `#11 Action Card` `hero_card_played` 信号 emit
4. 玩家测试反馈如不明显,registry tuning 调到 0.07(但不超 0.10)

## Validation Criteria

- Hero card 玩出后 0.5s 内,3 视觉 element 全部触发反馈(集成测试)
- 全 mute 模式下,3 element 反馈仍触发(无障碍测试 fixture)
- brightness lift ≤ 0.07(自动化 visual diff 测试)
- 5 禁视觉(金光 / sparkle / 烟花 / 彩虹 / 鸡汤)全 0 出现(visual lint)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(`hero_card_played` 信号)
- ADR-0007 KPI Review Three-Track Anchor(KPI_REVIEW palette 800ms 区别)
- `#5 Lighting` Rule 11
- `#13 HUD Diegetic` 三 element 反馈
- `#20 Accessibility` Rule 3 mute_visual_parity
- `#11 Action Card` Hero card 频次约束
- `#7 AP Rule 12` 月内 4 次上限
