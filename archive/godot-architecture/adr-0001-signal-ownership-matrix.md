# ADR-0001: Signal Ownership Matrix

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core / Scripting(Signal architecture, cross-cutting) |
| **Knowledge Risk** | MEDIUM(GDScript signal API 4.0+ 稳定;`@abstract` 4.5 引入但 signal 无关) |
| **References Consulted** | `docs/engine-reference/godot/breaking-changes.md` / `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | None — 信号系统使用 `signal` 关键字 + `connect()` API,4.0+ 稳定 |
| **Verification Required** | None(标准 Godot signal,无版本特定行为) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None(Foundation 层 ADR,无上游) |
| **Enables** | ADR-0002(Autoload Init Order)+ ADR-0009(Event Schema)+ ADR-0010(Subject Inversion Lint)+ 全 Presentation 层 UI ADR |
| **Blocks** | 任何 Presentation 层 GDD 实施(`#13 HUD` / `#14 Card Play UI` / `#15 Recap UI` / `#16 KPI Review UI`)— 信号订阅契约未锁定不可 build |
| **Ordering Note** | P0 优先级最高;必须在任何 system coding 启动前 Accepted |

## Context

### Problem Statement

`/review-all-gdds` 2026-04-29 cross-review 报告 surface **3 个跨 GDD 信号 ownership BLOCKING**(B-DEP-1/2/3),20 GDD 全套缺乏 cross-system 信号 owner + subscriber 完整 matrix:

1. **B-DEP-1**: `narrative_density_changed` 由 `#17 Settings` Rule 5 emit,但下游 `#10 Event Script` + `#15 Recap UI` 均未在 Section 信号订阅清单中声明 subscriber 契约 → 三档密度切换运行时 broken
2. **B-DEP-2**: 离别事件强制 numeric_only 契约只在 `#10` Rule 11 + `#14` Rule 4 双声明,但下游 `#13 HUD` / `#15 Recap UI` / `#4 Audio` / `#5 Lighting` 均未声明"LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF 时禁特殊 UI / 禁 BGM 切换"
3. **B-DEP-3**: `accumulation_event` 信号 ownership 三方混乱(`#5` 自 emit / `#5 Section F` 说 `#6` emit / `#6 Section H` 也写 emit / `#13` 订阅"`#5` 的 accumulation_event")

20 GDD 共 30+ cross-system 信号无统一 ownership matrix → architecture 层无法 enforce,coding 层将各自实现致 wiring 错误。

### Constraints

- 必须兼容已撰写的 20 GDD 中各自 Section C Rule "信号架构" 段
- 不允许重写任何 GDD 的核心机制(Pillar 守门 / Rule 编号不变)
- Godot 4.6 signal API 限制(`emit_signal()` 同步 / `connect()` flag 选项)
- 性能契约:`scene_state_changed` 同帧主线程预算 ≤ 16.6ms(`#6 Rule 3`)

### Requirements

- 每个 cross-system signal 必须 single-source(单 owner emit)
- 每个 signal 必须列出 subscriber 完整 GDD list + AC 守门 GDD
- 离别事件 enum 白名单(LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF / GRIND_KING_PROMOTED_LEAVE / FISH_MONK_LAID_OFF / OLD_OIL_OPTIMIZED_OUT)在 `#10` own,4 下游 GDD 各自 AC 验证守门
- `subject_inversion_lint.py` master domain list 锁定(8 域)
- `accumulation_event` 单 owner = `#5 Lighting`(消除三方歧义)

## Decision

### Signal Ownership Matrix(20 GDD 全套 cross-system signal)

| Signal | Owner | Subscribers | 协议 |
|--------|-------|-------------|------|
| `scene_state_changed(from, to)` | `#6 Scene & Day Flow` | `#4 Audio` / `#5 Lighting` / `#7 AP` / `#8 NPC` / `#9 KPI` / `#10 Event` / `#11 Action Card` / `#13 HUD` / `#14 Card Play UI` / `#15 Recap UI` / `#16 KPI Review UI` / `#17 Main Menu` / `#18 Tutorial` / `#19 Notification` / `#20 Accessibility` (15 subs) | 同帧主线程预算 16.6ms 分摊;dispatch ≤ 1 帧;subscribers 须 lightweight handler(R-SDF-3 守门) |
| `soft_pause_requested(source)` | `#6` | `#1 Save` / `#4 Audio` / `#5 Lighting` / `#2 Input` (4 subs) | 各自自决 fade / pause / debounced save |
| `ap_changed(current, max)` | `#7 AP Economy` | `#13 HUD` / `#14 Card Play UI` / `#15 Recap UI` / `#20 Accessibility` (4 subs) | 主语翻转 lint AP.* keys 守门 |
| `ap_consumed(amount)` | `#7` | `#6 Scene Flow`(Rule 9 game-time tick)(1 sub) | 离散整数事件驱动 |
| `monthly_effort_summary(month, potential, ot, hero, ovr, days, capacity_factor)` | `#7` | `#9 KPI`(F1 输入)(1 sub) | 月末 push;权重 0.45/0.20/0.30(已锁) |
| `relationship_changed(npc, delta, new_score, reason)` | `#8 NPC` | `#10 Event Script` / `#13 HUD` / `#15 Recap UI` (3 subs) | per-NPC,Pillar 4 lint NPC.* keys |
| `npc_lifecycle_changed(npc, old_state, new_state, reason)` | `#8` | `#10 Event Script` / `#13 HUD` / `#19 Notification` (3 subs) | LEAVING_ANNOUNCED → LEFT 触发离别事件链 |
| `npc_left_company(npc, reason)` | `#8` | `#10` / `#13` / `#16 KPI Review UI` / `#19` (4 subs) | LEFT 视觉屏蔽 R-NPC-2 守门 |
| `kpi_threshold_changed(old, new, delta_pct, breakdown)` | `#9 KPI System` | `#13 HUD` / `#15 Recap UI` / `#16 KPI Review UI` (3 subs) | breakdown 三行 HR 戏谑口吻渲染 |
| `kpi_review_started` | `#9` | `#16` / `#15` / `#5 Lighting` (3 subs) | 月末 transition 启动锚 |
| `game_over_triggered(reason, month)` | `#9` | `#10` / `#12 Run Meta` / `#16` (3 subs) | 1500ms linear easing=NONE 守门 |
| `dismissal_triggered(reason)` | `#9` | `#10`(EVENT.KPI.FIRED_DISMISSAL 触发)(1 sub) | 经 `#10` 剧本 → `#9` emit `game_over_triggered`(ADR-0006 双路径合并) |
| `kpi_prediction_hint(npc_id, hint_type)` | `#9` | `#10`(老 NPC 预言 4 档台词)(1 sub) | 月末 -2 天触发 |
| `event_started(event_id, narrative_tier)` | `#10 Event Script` | `#14 Card Play UI`(三档密度差异化渲染主消费者)+ `#13` flash overlay (2 subs) | 三档密度 fallback by `#14` |
| `event_completed(event_id)` | `#10` | `#6` / `#13` / `#15` (3 subs) | 时间推进 + HUD 更新 + 周报回顾 |
| `card_played(card_id)` | `#11 Action Card` | `#10`(trigger.type=card 检索)+ `#13` (2 subs) | 卡完整 step 1-7 链 |
| `accumulation_event(type, delta_units)` | **`#5 Lighting`(单 owner)** | `#13 HUD`(订阅显示便利贴堆叠等 visual variant)(1 sub) | **B-DEP-3 仲裁:`#5` 唯一 emit,`#6` 不 own;`#13` 仅订阅** |
| `narrative_density_changed(tier)` | **`#17 Main Menu / Settings`** | `#10 Event Script` / `#14 Card Play UI` / `#15 Recap UI` (3 subs) | **B-DEP-1 仲裁:三 subscriber 必须在自身 Section C Rule 信号架构补订阅契约**;EVENT_ACTIVE 态切档行为 by ADR-0004 |
| `bus_volume_changed(bus, db)` / `locale_changed(new_locale)` / `keymap_changed` / `font_size_changed` / `colorblind_mode_changed` (5 信号) | `#17` | `#1 Save`(防抖单 timer 合流,`#6 Rule 7`)(全 subs 各自合流后落盘) | settings 防抖 single timer ADR-0004 |
| `_mark_ready` (4 个 — 各 Foundation emit) | `#3 / #4 / #5` 各自 | `#6 Scene Flow`(Rule 4 启动序列)(1 sub each) | watchdog 10s for #4/#5,30s for #3 |
| `weekend_rest_day` | `#6` | `#7`(精力 +30) | game-time 驱动 |
| `inject_predicted_ap_demand(int)` | `#10` | `#7`(早晨预告)| 注入接口 |
| `kpi_contribution_reported(amount)` | `#11` | `#9 F7 actual_kpi_m`(累加)(1 sub) | 单卡贡献回调 |
| `report_overage(card_id, kpi_delta)` / `report_hero_card_played(card_id)` | `#9` / `#11` 互调 | `#7`(累积 effort_overage / hero_count) | 双向回调 |
| `run_meta_unlock(content_id)` | `#10` effect | `#12 Run Meta`(content-only 5 类白名单)| Anti-P1 红线守门 |
| `run_started` / `run_ended(run_id, month, reason)` | `#12` | `#10`(once_per_run cooldown reset)/ `#6`(Run 边界)| 跨 Run 状态管理 |
| `archive_completed(run_id)` | `#1 Save` | `#12` / `#6 → MAIN_MENU` (2 subs) | ARCHIVING 5 步事务完成 |

### 离别事件 Enum 白名单(B-DEP-2 仲裁)

`#10 Event Script Engine` Rule 11 own 离别事件 enum 白名单(常量定义在 `data/event_constants.tres`):

```gdscript
const FAREWELL_EVENT_IDS: Array[StringName] = [
    &"LISA_GOODBYE",
    &"CLEANING_AUNT_LEAVE",
    &"FISH_MONK_LAID_OFF",
    &"GRIND_KING_PROMOTED_LEAVE",
    &"OLD_OIL_OPTIMIZED_OUT",
    # VS 起追加: NEWBIE_LEAVE / FLATTERER_LEAVE
]
```

下游 GDD AC 守门契约(必须在各自 Section H 增 AC):
- **`#13 HUD Diegetic`**: AC-FUNC 验证 `event_started(event_id, narrative_tier)` 中 `event_id ∈ FAREWELL_EVENT_IDS` 时**禁渲染 flash overlay** + 仅切 `HUD_NPC_EXPRESSION/POSITION` LEFT variant + 后续 `HUD_EMPTY_CHAIR`
- **`#15 Daily/Weekly Recap UI`**: AC-FUNC 验证 farewell event 在周报 numeric_only 列表中**仅一行 `EVENT.[event_id].TITLE_NUMERIC` key**,无情感词
- **`#4 Audio Manager`**: AC-FUNC 验证 farewell event 触发时**禁切 BGM**(继续当前 ambient,Pillar 4 红线)
- **`#5 Lighting`**: AC-FUNC 验证 farewell event **禁特殊 palette swap**(继续当前 sub-mode CanvasModulate)+ `accumulation_event("npc_empty_chairs", +1)` 仅在 `npc_left_company` 触发(see ADR-0005)

### `subject_inversion_lint.py` Master Domain List(扩展自 ADR-0010 范围)

8 域 master list 锁定(本 ADR 为 ADR-0010 提前下定义):
```
EVENT / NPC / AP / ENERGY / KPI / EFFORT / TENURE / RECAP / GAMEOVER / EVAL / ARCHIVE / TUTORIAL_NPC / CHOICE
```
(13 子域,可由 master 8 域包含)。CI lint 工具读 master list 配置而非各 GDD 各自声明。

### Architecture Diagram

```
                     ┌────────────────────────────┐
                     │   #6 Scene & Day Flow      │
                     │   (Autoload, single source │
                     │    of scene_state_changed) │
                     └─────────┬──────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ Foundation   │  │ Core         │  │ Feature      │
    │ #4 #5 (subs) │  │ #7 #8 #9     │  │ #10 #11 #12  │
    │              │  │ (cross emit) │  │ (event chain)│
    └──────────────┘  └──────────────┘  └──────────────┘
                               │
                               ▼
                     ┌──────────────────┐
                     │ Presentation     │
                     │ #13 #14 #15 #16  │
                     │ #17 #19          │
                     │ (subscribers)    │
                     └──────────────────┘
                               │
                               ▼
                     ┌──────────────────┐
                     │ Polish (#20)     │
                     │ injection only   │
                     └──────────────────┘

`accumulation_event` source = #5 Lighting (B-DEP-3 仲裁)
`narrative_density_changed` source = #17 (B-DEP-1 仲裁)
`FAREWELL_EVENT_IDS` enum owner = #10 (B-DEP-2 仲裁)
```

## Alternatives Considered

### Alternative 1: EventBus Pattern(全局信号总线)

- **Description**: 引入 `EventBus` autoload 单例,所有 cross-system 信号经此中转;`#6` Scene Flow 不持总线
- **Pros**: 测试性好(单点 mock);系统间完全解耦
- **Cons**: 增加一层间接;违反 `#6 Rule 1` "全游戏唯一 sub-mode 调度权归属此节点";性能多 1 hop
- **Rejection Reason**: `#6` 已设计为 Autoload 单点 dispatch(Rule 14 主语翻转 dispatch 强制),增设总线是冗余;OQ-SDF-02 已选直接 emit

### Alternative 2: 各 GDD 自治(无 master matrix)

- **Description**: 每 GDD 自己写信号清单,不强制 master matrix;依赖 reviewer 跨 GDD 检查
- **Pros**: 灵活
- **Cons**: 已在 /review-all-gdds 暴露 — 8 BLOCKING 之 3 来自这种自治模式
- **Rejection Reason**: 已经 fail 过一次,reviewer 抓不全 cross-cutting

### Alternative 3: 信号类型化 Resource(.tres signal 定义)

- **Description**: 每信号是一个 SignalDefinition Resource,带 schema 验证
- **Pros**: 强类型 + 编辑器可视化
- **Cons**: 过度工程;Godot 4.6 signal 已有类型化参数;增加 maintenance 成本
- **Rejection Reason**: 收益不抵成本

## Consequences

### Positive

- 20 GDD 信号 wiring 唯一 source of truth(本 ADR 表)
- 3 BLOCKING(B-DEP-1/2/3)全部仲裁完毕
- 各 GDD AC 验证清单明确(FAREWELL_EVENT_IDS 守门 4 GDD 列出)
- `subject_inversion_lint.py` master domain list 集中管理(避免各 GDD 各自声明分裂 — 上次 cross-review 发现 11 套不一致)

### Negative

- 4 个下游 GDD(`#13/#15/#4/#5`)需补 farewell event AC 守门(微修级,不阻塞 architecture)
- `#10 Event Script Engine` GDD 需补 FAREWELL_EVENT_IDS enum 常量声明(微修)
- `#17 Main Menu Settings` 已 emit 5 settings 信号 + 1 `narrative_density_changed`,3 下游 GDD 需补订阅 wiring(`#10/#14/#15` GDD Section C 微修)

### Risks

- **R1**: GDD 微修可能延迟到 ADR Accepted 后才执行 — 实施层先 wiring 错误代码 → CI lint 不能立即 catch(因为 lint 工具尚未实现)
  - **Mitigation**: 本 ADR Accepted 同时,创建 `tools/signal_ownership_lint.py` 静态 lint 工具(Phase 2 实施);CI 阻塞 PR 当 wiring 不符合本 matrix
- **R2**: 31 信号 × 65 subscribers 可能超过 Godot signal performance budget(每帧 dispatch)
  - **Mitigation**: 性能契约 `scene_state_changed` 同帧 ≤ 16.6ms 已锁(`#6 Rule 3`);profiler 实测延 OQ-SDF-ENG-02

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|-----------|-------------|--------------------------|
| `#6 Scene Flow` Rule 14 | 主语翻转 dispatch 强制 — sub-mode 转移单点 | `scene_state_changed` 单 owner = `#6` |
| `#7 AP` Rule 14 | 信号架构清单 9 emit | 全部列入 matrix + subscriber 完整 |
| `#8 NPC` Rule 10 | 信号架构 5 emit | 全部列入 matrix |
| `#9 KPI` Rule 13 | 信号架构 5 emit | 全部列入 matrix + dismissal 路径见 ADR-0006 |
| `#10 Event Script` Rule 19 | 信号架构 4 emit + 9 sub | 全部列入 matrix + FAREWELL enum |
| `#13 HUD` Rule 1 | 8 diegetic 元素订阅 7 信号 | matrix 列 15 sub for `scene_state_changed` 含 `#13` |
| `#17 Main Menu` Rule 4 | 5 settings 信号 + narrative_density_changed | B-DEP-1 仲裁: `#17` own |
| `/review-all-gdds 2026-04-29` B-DEP-1/2/3 | 3 cross-cutting BLOCKING | 全部仲裁 |

## Performance Implications

- **CPU**: signal dispatch overhead ~ µs / signal × 65 subscribers = ~65µs / dispatch frame
- **Memory**: matrix 是设计契约,不进运行时(无 runtime cost)
- **Load Time**: 无影响
- **Network**: N/A(单机游戏)

## Migration Plan

1. ADR Accepted → `tools/signal_ownership_lint.py` 实现(Phase 2)
2. 4 下游 GDD(`#13/#15/#4/#5`)补 FAREWELL_EVENT_IDS AC 守门(微修级)
3. `#10` GDD 补 FAREWELL_EVENT_IDS enum 常量声明(微修)
4. `#10/#14/#15` GDD 补 `narrative_density_changed` 订阅 wiring(Section C 信号架构段)
5. CI 集成 lint 工具阻塞 PR 当信号 wiring 违反 matrix

## Validation Criteria

- 每 cross-system signal 在 `signal_ownership_lint.py` 报告中有且仅有一个 emit owner
- 每 GDD Section C 信号架构段与本 matrix 一致(lint 自动比对)
- 8 域 `subject_inversion_lint.py` master list 单一来源(`tools/lint_config.toml`)
- FAREWELL_EVENT_IDS 4 下游 GDD 各自 AC 验证全 PASS

## Related Decisions

- ADR-0002 Autoload Init Order + Scene Tree Architecture(`scene_state_changed` dispatcher = `#6` 单 owner 实现)
- ADR-0004 Settings Reflow Coalescing(`narrative_density_changed` 在 EVENT_ACTIVE 态切档行为)
- ADR-0005 Lighting Accumulation 4 Dimensions(`accumulation_event` 第 4 维 `npc_empty_chairs` 归属)
- ADR-0006 Dismissal/GAMEOVER Path Resolution(`dismissal_triggered → game_over_triggered` 链)
- ADR-0010 Subject Inversion Lint Master Domain List(本 ADR 提前 sketch 8 域 master list,ADR-0010 形式化)
- `design/gdd/gdd-cross-review-2026-04-29.md`(Source of B-DEP-1/2/3)
- `docs/architecture/architecture.md`(Required ADRs §)
