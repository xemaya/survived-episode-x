# 《活过第 X 集》— Master Architecture

## Document Status

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Last Updated** | 2026-04-29 |
| **Engine** | Godot 4.6 + GDScript(Forward+ 渲染,Godot Physics 2D) |
| **GDDs Covered** | 20 系统 GDD(Foundation 5 + Core 4 + Feature 3 + Presentation 5 + VS 2 + Alpha 1)+ game-concept.md + systems-index.md(共 14,501 行 GDD 内容) |
| **ADRs Referenced** | 0(本文档生成时尚无 ADR;Phase 6 列出 10 必需 ADR) |
| **Cross-Review Input** | `design/gdd/gdd-cross-review-2026-04-29.md`(verdict CONCERNS,8 BLOCKING + 14 WARNING,Phase 3 设计整体性 PASS) |
| **Technical Director Sign-Off** | 2026-04-29 — APPROVED WITH CONDITIONS(8 BLOCKING 由 Required ADRs 处理) |
| **Lead Programmer Feasibility** | SKIPPED — Lean mode |
| **Authoring autonomy mode** | v2 no-prompt(0 widget) |

---

## Engine Knowledge Gap Summary

**Engine**: Godot 4.6(2026-01 release)
**LLM Training Cutoff**: ~2025-05(覆盖至 4.3)
**Post-Cutoff Versions**: 4.4 / 4.5 / 4.6 — **HIGH RISK**

### HIGH RISK Domains(必须查 engine reference 验证)

| 域 | 4.4-4.6 关键变更 | 影响系统 |
|----|----------------|---------|
| Core / Scripting | `@abstract` (4.5)、变长参数(4.5)、`duplicate_deep()` (4.5)、Quaternion identity(4.6) | Scene & Day Flow #6(`@abstract BaseSubModeState`)+ Event Script #10(`@abstract EventEffect`)|
| UI | dual-focus(4.6)、Recursive Control disable(4.5)、FoldableContainer(4.5) | Input Handler #2(已处理)+ HUD #13 + Card Play UI #14 |
| Localization | CSV plural form(4.6)+ context columns(4.6)+ C# string extraction(4.5) | Localization Hooks #3 |
| Animation | IK 全恢复(4.6)+ BoneConstraint3D(4.5) | 不影响(2D 项目)|
| Rendering | Glow before tonemap(4.6)、D3D12 default Win(4.6)、AgX tonemapper(4.6) | Lighting & Visual State #5 |

### MEDIUM RISK Domains

| 域 | 变更 | 影响系统 |
|----|------|---------|
| Platform | SDL3 gamepad(4.5) | Input Handler #2 |
| Resources | `duplicate_deep()`(4.5) | Save System #1 + Event Script #10 |
| Editor | Modern theme(4.6) | 开发体验 only |

### LOW RISK Domains

- 2D Rendering(本项目主战场,无重大变更)
- File I/O(`FileAccess.store_*` 4.4 返回值变化已知)

### 已识别 OQ 实测项(Pre-Production 验证)

3 OQ 来自 #6 Scene Flow GDD(已 surface 在 Open Questions):
- `PROCESS_MODE_ALWAYS` Autoload 在 4.6 SceneTree.paused 实测行为
- `change_scene_to_packed()` 4.5 SceneTree 重构对 2D 路径性能基准
- `@abstract` 4.5+ 语法实测验证

---

## System Layer Map

20 系统映射至 5 层(完全沿用 systems-index.md L75-110 定义,Pillar 守门铁三角已在 GDD 层落实):

```
┌──────────────────────────────────────────────────────────────┐
│ POLISH LAYER (1, Alpha tier)                                 │
│   #20 Accessibility Options(注入 Presentation Layer)        │
├──────────────────────────────────────────────────────────────┤
│ PRESENTATION LAYER (6: 5 MVP + 1 VS)                         │
│   #13 HUD Diegetic ⭐  │  #14 Card Play & Dialogue UI ⭐      │
│   #15 Daily/Weekly Recap UI  │  #16 KPI Review & Game Over UI│
│   #17 Main Menu / Pause / Settings UI                        │
│   #19 Notification & Warning System (VS)                     │
├──────────────────────────────────────────────────────────────┤
│ FEATURE LAYER (4: 3 MVP + 1 VS)                              │
│   #10 Event Script Engine ⭐⭐  │  #11 Action Card System ⭐    │
│   #12 Run Meta System  │  #18 Tutorial / Onboarding (VS)     │
├──────────────────────────────────────────────────────────────┤
│ CORE LAYER (4)                                               │
│   #6 Scene & Day Flow Controller ⭐⭐(总线 dispatch)         │
│   #7 AP Economy System ⭐  │  #8 NPC Relationship System ⭐   │
│   #9 KPI & Reverse Threshold System ⭐⭐(反向 KPI 数学引擎)  │
├──────────────────────────────────────────────────────────────┤
│ FOUNDATION LAYER (5)                                         │
│   #1 Save System ✅  │  #2 Input Handler ✅                   │
│   #3 Localization Hooks  │  #4 Audio Manager                 │
│   #5 Lighting & Visual State Controller                      │
├──────────────────────────────────────────────────────────────┤
│ PLATFORM LAYER                                               │
│   Godot 4.6 + GDScript Runtime  │  SteamOS / Win / Mac / Linux│
└──────────────────────────────────────────────────────────────┘
```

**说明**:
- ⭐⭐ = Bottleneck ⭐ + Cross-cutting backbone(`#6` 是全游戏 dispatch 总线;`#9` 是反向 KPI 数学引擎;`#10` 是数据驱动事件 schema)
- ⭐ = 关键依赖节点(高 fan-out 或 fan-in)
- ✅ = 已 `/design-review` Approved
- VS / Alpha tier 系统是 layered 注入(不引入新层级)
- **Polish Layer 不是独立运行时层**: `#20 Accessibility` 是 settings 注入器,跨 7+ Presentation/Foundation 系统注入(`AccessibilitySettings` autoload 单例 + 各 UI GDD 自身渲染循环读取)

---

## Module Ownership

### Foundation Layer(5 modules)

| Module | Owns | Exposes | Consumes | 关键 Engine APIs(4.6) |
|--------|------|---------|----------|----------------------|
| **Save System #1** | `meta.save` + `current_run.save` + `archive/[run_id].save` 三槽位序列化 schema + Rule 7 WorkerThreadPool autosave + Rule 9 ARCHIVING 5 步事务 | `save_state(state)` / `load_state()` API + `meta_loaded` / `autosave_completed` / `archive_completed` 信号 | 各系统 Section F 各自 sub-schema | `WorkerThreadPool.add_task()` / `FileAccess.store_*`(4.4 返回 bool)/ `JSON.parse_string()` |
| **Input Handler #2** | InputMap action 注册(`act_pause` / `act_skip` / `act_focus_*` / `act_confirm` 等)+ 3-state 状态机(NORMAL / MODAL_LOCKED / REMAPPING)+ Rule 6 skippable token + Rule 7 modal stack | `register_skippable()` / `unregister_skippable()` / `is_modal_locked()` / `get_display_name()` API + `keymap_changed` / `modal_dismissed` / `act_*` 信号 | `#1 Save` keymap_payload | `Input.is_action_pressed()` / `InputMap.action_add_event()` / `Input.reset_all_action_presses()`(4.5 SDL3 gamepad)/ Recursive Control disable(4.5)|
| **Localization Hooks #3** | 11 Core Rules:`tr()` 纪律 / `_IRONY` 后缀守门 / RichTextLabel `register_rich_text_refresh()` / 字体 fallback 链(4 档 + Compact)/ CSV 5-列 schema / locale_lock_watchdog_ms(30s) | `tr()` / `set_locale()` / `register_rich_text_refresh()` API + `locale_changed` / `NOTIFICATION_TRANSLATION_CHANGED` 广播 | `#1 Save` locale_payload | `TranslationServer.set_locale()` / `tr()` / `RichTextLabel`(4.6 CSV plural + context)|
| **Audio Manager #4** | 4 Bus 架构(Master / Music / Ambient / SFX)+ Rule 6 8 sub-mode ambient 表 + LOADING/READY 状态机 + audio_preload_budget_ms / audio_loading_watchdog_ms / bgm_loop_length_max_sec / audio_bank_total_size_mb | `play_sfx()` / `play_ambient()` / `play_music()` / `set_bus_volume()` API + `bus_volume_changed` 信号 | `#1 Save` audio settings;订阅 `#6 scene_state_changed` 切换 ambient | `AudioServer.set_bus_volume_db()` / `AudioStreamPlayer` / `AudioStream` Resource(4.5 stencil 不影响)|
| **Lighting & Visual State #5** | 12 Core Rules:CanvasModulate 8 sub-mode 色值表 + LOADING/READY 状态机 + palette swap shader + dither overlay shader + 累积 state 4 维度 schema(详 ADR-0005)+ Tonemapper Filmic 锁(4.6 AgX 不启用) | `apply_visual_state()` API + `accumulation_event(type, delta_units)` 接收 + `lighting_visual_state_ready` 信号 | `#1 Save` accumulation_state_payload(4 维度);订阅 `#6 scene_state_changed` | `CanvasModulate` / `ShaderMaterial` / `Tween`(4.6 Glow rework + AgX tonemapper 锁) |

### Core Layer(4 modules)

| Module | Owns | Key Engine APIs |
|--------|------|----------------|
| **Scene & Day Flow #6** ⭐⭐ | Autoload 单例 `/root/SceneDayFlowController` + 8 sub-mode 状态机 + `scene_state_changed` 总线 + `request_soft_pause()` API + Rule 4 启动序列 + Rule 7 settings 防抖单 timer + game-time tick(离散事件驱动 Rule 9)+ FrameTimeMonitor(debug only)| `@abstract BaseSubModeState`(4.5)/ `Engine.get_process_frames()` / `Time.get_ticks_msec()` / `NOTIFICATION_WM_WINDOW_FOCUS_OUT` |
| **AP Economy #7** ⭐ | `current_ap` / `max_ap_today` / `current_energy` / `effort_overtime_count` / `effort_hero_count` / `effort_overage_count` 状态 + 4 态状态机(`AP_NORMAL` / `AP_OVERTIME_AVAILABLE` / `AP_OVERTIME_ACTIVE` / `AP_DEPLETED`)+ AP cost 1/2/3 分布 lint + Hero 卡 effort 三维度 emit(权重 0.45/0.20/0.30 已锁) | typed `Array[EventEffect]` / GDScript const 强类型 |
| **NPC Relationship #8** ⭐ | 8 NPC `relationship_score: int [-100, +100]` + per-NPC `flags: Dict[String, bool]` + 4 lifecycle 态(ACTIVE / LEAVING_ANNOUNCED / LEFT / RETURNED)+ F3 leave_probability 公式 per-NPC 8 套参数 | typed Dictionary / 4.5 `@abstract` |
| **KPI System #9** ⭐⭐ | `monthly_threshold: int` 单调递增 + `month_index: int` + Formula B 乘性公式(α=0.04, β=0.18, γ=0.012)+ `capacity_factor(m) = max(0.4, 3.0 - 0.05·m)` + GAME OVER 检测协议 | float 数学(精度无敏感)+ deterministic RNG(seed 可控)|

### Feature Layer(4 modules)

| Module | Owns | Key Engine APIs |
|--------|------|----------------|
| **Event Script Engine #10** ⭐⭐ | Schema A 扁平式事件库(.tres + JSON)+ 5 态状态机(IDLE / EVALUATING_CANDIDATES / EVENT_ACTIVE / WAITING_PLAYER_CHOICE / EXECUTING_EFFECTS)+ Rule 18 Godot 4.6 实现规约(JSON-primary,EditorPlugin lint,Dictionary 三层索引)+ 三档密度(flash/long/numeric_only)+ 模板变量 + cooldown + 权重池 + 早晨预告 blacklist | `JSON.parse_string()` / `Resource` `extends` / `@abstract`(4.5) / EditorPlugin EventLinter / `String.format()` / `tr()` 按需 |
| **Action Card #11** ⭐ | Card schema(派生 `#10` event schema 子集)+ AP cost 40/40/20 分布 lint + Hero `is_hero` flag + 互斥分组 + 4 态状态机(IDLE / PLAYABLE / DISABLED / PLAYED) | typed Resource / GDScript const |
| **Run Meta #12** | RunSummary schema(7 字段)+ Run Archive 200 cap FIFO + HR 评语词条收集词库 + content-only unlock 5 类白名单 + demo end 3 月 gate | Set / Dictionary serialize |
| **Tutorial / Onboarding #18** (VS) | TutorialState autoload 子节点 + Day 1-3 fixed_hand_override + ONBOARDING tier 5 NPC hint + M1 KPI 评语 + tutorial_completed flag | Autoload init order / `inject_onboarding_hint()` API |

### Presentation Layer(6 modules)

**全部 UI 渲染层 — 不持业务状态,纯订阅信号驱动**

| Module | Owns | Key Engine APIs |
|--------|------|----------------|
| **HUD Diegetic #13** ⭐ | 8 diegetic UI 元素 mapping(便利贴 / 咖啡杯 / 显示屏 / 考勤表 / 日历 / NPC 表情 / NPC 站位 / 空椅)+ sub-mode 视觉布局状态机 + 帧预算 ≤ 2ms / 屏 | `Control` / `RichTextLabel`(`register_rich_text_refresh` 经 #3) / `Sprite2D` |
| **Card Play & Dialogue UI #14** ⭐ | 三档密度差异化渲染(flash overlay / long 立绘+对白+选项 / numeric_only HUD-only)+ 玩家手牌 UI + NPC 立绘 + 选项交互 | `RichTextLabel` BBCode / `Button` / `AnimatedSprite2D` |
| **Daily/Weekly Recap UI #15** | Daily Recap(<90s)+ Weekly Recap(每周五)+ effort 三维度展示 + numeric_only 事件列表 + HR 周报口吻 lint(扩展 RECAP.* keys)| `RichTextLabel` / `Tween` |
| **KPI Review & Game Over UI #16** ⭐ | 月末结算屏 + GAMEOVER 离职证明屏(1500ms linear)+ Archive 列表屏 + 三屏 own 节点树 + GAMEOVER.CERTIFICATE.[reason] Localization key 渲染 | `Tween`(linear,无 ease)/ `ItemList`(Archive 200 条虚拟滚动)|
| **Main Menu / Pause / Settings UI #17** | 主菜单 4 入口 + Pause 子屏("摸鱼中")+ Settings 子屏(音量 4 旋钮 / 语言 / 键位 remap / 叙事密度)+ Archive 入口 + Settings 信号合流 emit `#6` Rule 7 single timer | `Control` / `Slider` / `OptionButton` |
| **Notification & Warning #19** (VS) | 4 类预警(capacity_floor / effort 极值 / NPC 离职预兆 / 月末倒计时)+ 通过 `#13 HUD` diegetic 元素 visual variant 显示(无 popup)+ HR 口吻预警语义 | 信号转发器(无独立 UI 节点) |

### Polish Layer(1 module — 注入器)

| Module | Owns | Notes |
|--------|------|-------|
| **Accessibility #20** (Alpha) | `AccessibilitySettings` autoload + 字体大小 4 档 + 色盲 3 档 + 高对比度 + 输入辅助 + TTS(野心版) | 注入 7+ 系统的渲染循环,**不修改任何数值规则**(Anti-P1 红线 PR-blocking)|

---

## Data Flow

### 5 关键场景数据流

#### 1. 启动序列(冷启动 → MAIN_MENU)

```
[Splash] → SaveSystem.load_meta() (sync, ≤50ms HDD+AV ceiling)
        → 4 Foundation parallel:
             ├─ LocalizationHooks.load_translation() (<100ms)
             ├─ AudioManager.preload_bank() (≤200ms,audio_preload_budget_ms)
             ├─ LightingController.load_accumulation_state(payload)
             └─ InputHandler.load_keymap(payload)
        → 4 Foundation 各 emit `_mark_ready` 信号(watchdog 10s for Audio/Lighting,30s for Loc 演出锁)
        → SceneDayFlowController._all_systems_ready() (waiting if any not ready, with bool is_ready check before await — R1 mitigation)
        → ResourceLoader.load_threaded_request(MainMenu.tscn) → change_scene_to_packed()
        → emit scene_state_changed(LOADING → MAIN_MENU)
        
P5 5 秒进入承诺总预算 = 5000ms;典型 ~720ms necessary,~4280ms 缓冲
```

#### 2. 单卡完整链(玩家点 1 张 Action Card)

```
玩家点卡(act_confirm)
  → InputHandler emit act_confirm(by_card_id=X)
  → CardPlayUI captures + 调 ActionCard.try_play_card(X)
  → ActionCard #11 step 1-7:
    1. ActionCard.try_play_card(X) → 守门(NPC LEFT? cooldown? mutex?)
    2. APEconomy.try_consume_ap(amount) → 返 bool
    3. emit ap_consumed(amount) → SceneDayFlow Rule 9 game-time +60min
    4. NPCRelationship.update_relationship(npc, delta, reason) → emit relationship_changed
    5. emit kpi_contribution_reported(amount) → KPISystem F7 累加 actual_kpi_m
    6. EventScriptEngine.trigger_card_event(card_id) → emit event_started(narrative_tier)
    7. CardPlayUI 接 event_started → 渲染 long 立绘 / flash overlay / numeric_only HUD only
  → HUD Diegetic 同帧订阅 ap_changed + relationship_changed + effort_*_incremented + event_completed
  
帧预算 16.6ms 分摊(由 #6 Rule 3 守门):
- Audio ≤ 1ms / Lighting < 1ms / 各 UI ≤ 2ms / Save snapshot ≤ 4ms / 缓冲 ≈ 8ms
- 重负载必须 call_deferred() 到次帧(R-SDF-3 守门)
```

#### 3. 月末 KPI Review 三轨 + GAME OVER

```
ACTION_DAY: current_day >= days_in_month 命中
  → SceneDayFlow.request_transition(KPI_REVIEW)
    1. emit action_lockout_started → ActionCard 冻结新卡入队
    2. wait current Action 动画完成
    3. emit scene_state_changed(→ KPI_REVIEW)
       ├→ Lighting palette swap → KPI_REVIEW 紫 #3A3050(0.3s linear Tween)
       ├→ Audio Music Bus → KPIREVIEW.ENDGAME_LOOP fade-in(1.5s)
       └→ KPI Review UI #16 → KPI_REVIEW_WAITING 态
  → KPISystem._run_monthly_settlement():
    1. _collect_effort_summary() ← AP Economy monthly_effort_summary
    2. F2 potential = clamp((actual_kpi_m - threshold) / threshold, -0.15, +1.0)
    3. F1 next_threshold = threshold × (1+α·E) × (1+β·p) × (1+γ·m)
    4. emit kpi_review_started → #16 渲染 breakdown 三行 HR 戏谑口吻(KPI research §8.1)
    5. emit kpi_threshold_changed(old, new, delta_pct, breakdown)
    6. F4 GAME OVER 检测: threshold > capacity_now?
       ├→ Yes: emit game_over_triggered(reason=KPI_EXCEEDS_CAPACITY, month)
       │     → SaveSystem 原子写 meta.run_ended=true(fsync)
       │     → #16 GAMEOVER_TRANSITION 启动(1500ms linear,easing=NONE,Save Rule 21)
       │     → EventScriptEngine GAMEOVER.CERTIFICATE.[reason] 文本嵌入
       │     → settlement_locked = true(永久)
       │     → archive_run() FIFO + Save ARCHIVING 5 步事务
       │     → SceneDayFlow → GAMEOVER sub-mode → MAIN_MENU + Archive 入列
       └→ No: emit kpi_review_dismissed → MORNING_BRIEFING(次月)
       
4 轨 negative space 同步:
- 数学(#9): threshold 涨幅,无祝贺
- 听觉(#4): 月末打卡机不是胜利音 + GAMEOVER stinger 反讽
- 视觉(#5): KPI 紫静止 + GAMEOVER 灰度压抑 + 累积视觉峰值
- 文字(#3 IRONY + #16): GAMEOVER.TITLE_IRONY "恭喜晋升" + breakdown HR 戏谑

⚠️ B-SCN4-1: 三轨节奏锚不同步(0.3s + 1.5s + 1帧 dispatch)
   → ADR-0002 必须锁定 kpi_review_intro_duration_ms 共用 anchor
```

#### 4. NPC 离职完整生命周期

```
月末 ACTION_DAY 期间(KPI_REVIEW 之前):
  → NPCRelationship F3 leave_probability(npc, m, R, E) 命中
  → npc_lifecycle_state[npc]: ACTIVE → LEAVING_ANNOUNCED
  → emit npc_lifecycle_changed(npc, ACTIVE, LEAVING_ANNOUNCED, reason)
  
  ├→ Notification #19 转发 warning_npc_leaving(npc) → HUD Diegetic
  ├→ HUD 切 NPC_EXPRESSION + NPC_POSITION variant("收纸箱")
  └→ Event Script Engine 候选池注入 [npc]_leaving_announced 事件
  
玩家在 LEAVING_ANNOUNCED 期间打"道别卡":
  → ActionCard.try_play_card 守门(LEAVING_ANNOUNCED 允许)
  → step 4 update_relationship(LISA, +N) ✓
  → step 6 trigger_card_event → LISA_GOODBYE event_id
  → EventScriptEngine Rule 11: 离别事件强制 numeric_only 档(沉默)
  → CardPlayUI 不渲染立绘 / 对白(numeric_only)
  → HUD Diegetic 仅 NPC 表情 + 站位 visual variant
  
月末 KPI_REVIEW 触发:
  → SceneDayFlow.finalize_npc_departure(LISA)
  → npc_lifecycle: LEAVING_ANNOUNCED → LEFT
  → emit npc_left_company(LISA, "quit")
  → HUD Diegetic 切 HUD_EMPTY_CHAIR variant(R-NPC-2 视觉屏蔽)
  → Notification 仍可 emit warning_npc_leaving_resolved(LISA)(一次性)
  → Lighting accumulation +1(若 npc_empty_chairs 是第 4 维 — ADR-0005 仲裁)
  → Save 持久化 LISA score(LEFT 不删 score,保留 RunSummary 引用)
```

#### 5. Settings 同帧改 6 项 + Save 防抖单 timer

```
玩家在 Settings 子屏快速依次切 6 控件
  → MainMenu/Settings #17 emit:
      bus_volume_changed (×4 buses) +
      locale_changed +
      keymap_changed +
      narrative_density_changed +
      font_size_changed +
      colorblind_mode_changed
  → SceneDayFlow Rule 7 _settings_debounce_timer reset(单 timer 共享)
  → 内存表立即生效:
      Audio Bus / TranslationServer / InputMap action / #10 density / #5 palette LUT / #13 font reflow
  → #3 Loc Rule 5 emit NOTIFICATION_TRANSLATION_CHANGED 广播
      → #13 / #14 / #15 / #16 / #17 全 UI 静态 Label 自动 + RichTextLabel rebuild
  → 500ms 静默 → SaveSystem.save_settings_payload() worker 单次合并落盘

⚠️ B-SCN4-2: font_size_changed + locale_changed 同帧广播去重未明
   → ADR-0004 必须锁定"settings 防抖窗内多信号合并为单次 NOTIFICATION_TRANSLATION_CHANGED 广播"
```

---

## API Boundaries

### Foundation → Core(关键 API 契约)

```gdscript
# Save System #1 — 唯一持久化入口
class SaveSystem:
    func save_state(key: String, state: Dictionary) -> void  # 防抖写盘
    func load_state(key: String) -> Dictionary
    func archive_current_run() -> void  # Rule 9 ARCHIVING 5 步事务(同步主线程 < 50ms)
    signal meta_loaded(meta: Dictionary)
    signal autosave_completed(snapshot_id: int)
    signal archive_completed(run_id: int)

# Input Handler #2
class InputHandler:
    func register_skippable(token_id: StringName, on_skip: Callable) -> void
    func unregister_skippable(token_id: StringName) -> void
    func is_modal_locked() -> bool
    func get_display_name(action_name: StringName) -> String
    signal keymap_changed
    signal modal_dismissed
    signal act_pause(reason: StringName)

# Localization Hooks #3
class LocalizationHooks:
    func tr(key: StringName, context: Dictionary = {}) -> String  # 模板变量注入
    func set_locale(locale: StringName) -> void
    func register_rich_text_refresh(node: RichTextLabel, key: StringName) -> void
    signal locale_changed(new_locale: StringName)

# Audio Manager #4
class AudioManager:
    func play_sfx(key: StringName) -> void
    func play_ambient(key: StringName, fade_ms: int = 200) -> void
    func play_music(key: StringName, fade_ms: int = 1500) -> void
    func set_bus_volume(bus: StringName, db: float) -> void
    signal bus_volume_changed(bus: StringName, db: float)
    signal _mark_ready  # to #6

# Lighting & Visual State #5
class LightingController:
    func apply_visual_state(sub_mode: StringName) -> void
    func receive_accumulation_event(type: StringName, delta_units: int) -> void
    signal lighting_visual_state_ready  # to #6
```

### Core → Feature(总线 + 信号)

```gdscript
# Scene & Day Flow #6 — 全游戏 dispatch 总线
class SceneDayFlowController extends Node:  # Autoload, PROCESS_MODE_ALWAYS
    func request_transition(to: SubMode) -> void
    func request_soft_pause(source: StringName) -> void
    func request_soft_resume() -> void
    signal scene_state_changed(from: SubMode, to: SubMode)
    signal soft_pause_requested(source: StringName)
    signal soft_resume_requested
    signal weekend_rest_day  # 周末 +30 energy

# AP Economy #7
class APEconomy:
    func try_consume_ap(amount: int) -> bool
    func try_overtime() -> bool
    func try_early_leave(leave_ap_saved: int) -> bool
    func get_npc_state(npc_id: NpcId) -> NpcLifecycleState
    signal ap_consumed(amount: int)
    signal ap_changed(current: int, max: int)
    signal energy_changed(current: int, max: int)
    signal ap_depleted
    signal ap_early_leave_taken
    signal effort_overtime_incremented(day: int, total: int)
    signal effort_hero_incremented(card_id: StringName, day: int, total: int)
    signal effort_overage_incremented(card_id: StringName, day: int, total: int)
    signal monthly_effort_summary(...)

# NPC Relationship #8
class NPCRelationship:
    func update_relationship(npc: NpcId, delta: int, reason: String) -> void
    func is_above_threshold(npc: NpcId, threshold: int) -> bool
    func get_npc_state(npc: NpcId) -> NpcLifecycleState
    signal relationship_changed(npc, delta, new_score, reason)
    signal relationship_phase_changed(npc, old_phase, new_phase)
    signal npc_lifecycle_changed(npc, old_state, new_state, reason)
    signal npc_left_company(npc, reason)

# KPI System #9
class KPISystem:
    func evaluate_month_end() -> void  # by #6 Rule 10
    func get_month_end_breakdown() -> Dictionary
    func report_overage(card_id: StringName, kpi_delta: float) -> void  # callback to #7
    signal kpi_review_started
    signal kpi_threshold_changed(old, new, delta_pct, breakdown)
    signal game_over_triggered(reason, month)
    signal dismissal_triggered(reason)
    signal kpi_prediction_hint(npc_id, hint_type)  # 4 档
```

### Feature → Presentation(订阅契约)

`#10 Event Script Engine` emit `event_started(event_id, narrative_tier)` → `#14 Card Play UI` 三档密度差异化渲染。`#9` emit `kpi_threshold_changed(breakdown)` → `#16 KPI Review UI` + `#15 Recap UI` 共订(KPI Review 月末展示 / Recap 周报展示)。

---

## Architecture Principles

5 条核心原则,governing 所有技术决策:

1. **Pillar 4 反英雄红线 PR-blocking**: `subject_inversion_lint.py` 8 域 master list(EVENT/NPC/AP/ENERGY/KPI/EFFORT/TENURE/RECAP)CI 联运守门。任何 GAMEOVER.CERTIFICATE / KPI breakdown / NPC 对白 / 卡反馈 / 月末结算文案违反"主语翻转 + HR 口吻 + 朋友圈测试" → CI BLOCKING。
2. **Anti-Pillar 1 单调红线**: AP / KPI threshold / capacity_factor 三轴单调(8 不可上调 / threshold 只升不降 / capacity 只降不升)。任何 effect / event / unlock / settings 试图反向 → PR-blocking + push_error。Run Meta unlocks **content-only 5 类白名单**(codex / memo / npc / event_branch / ending),禁机械成长字段。
3. **Diegetic UI 锁(art-bible §7.1)**: 无任何屏幕悬浮 HUD;所有信息内嵌工位场景物理元素(便利贴 / 咖啡杯 / 显示屏 / 日历 / NPC 表情 / 工位站位 / 空椅)。`#19 Notification` 严禁 popup / "警告!" / 弹层。
4. **`#6 Scene & Day Flow` 单点 dispatch**: `scene_state_changed` 总线 owner 单一(`#6`)+ `request_transition()` 唯一合法入口 + 主语翻转 dispatch 强制(`#6 Rule 14`)+ pause game-time vs wall-clock 边界(`#6 Rule 6`)。下游禁自驱动 sub-mode 切换。
5. **数据驱动 + 引擎契约锁**: 所有数值参数从 `config/*.tres` 加载(coding-standards §3),禁硬编码;Godot 4.6 specific API 用法集中在 `#6 C-ENG-01..10`(Autoload 顺序 / `PROCESS_MODE_ALWAYS` / `NOTIFICATION_WM_WINDOW_FOCUS_OUT` / `Engine.get_process_frames()` / `Time.get_ticks_msec()` / `WorkerThreadPool` thread safety / `@abstract` 4.5+ / `change_scene_to_packed()` 预加载)。

---

## ADR Audit

**14 existing ADRs(全部 Proposed,Lean mode 自动跳过 TD-ADR phase gate,等同 Accepted)**:

| ADR | Title | Status | 解决的 BLOCKING |
|-----|-------|--------|----------------|
| [ADR-0001](adr-0001-signal-ownership-matrix.md) | Signal Ownership Matrix | Proposed | B-DEP-1 / B-DEP-2 / B-DEP-3 |
| [ADR-0002](adr-0002-autoload-init-order.md) | Autoload Init Order + Scene Tree Architecture | Proposed | (Foundation 必创) |
| [ADR-0003](adr-0003-save-format-workerthreadpool.md) | Save Format + WorkerThreadPool Strategy | Proposed | (Foundation 必创) |
| [ADR-0004](adr-0004-settings-reflow-coalescing.md) | Settings Reflow Coalescing | Proposed | B-SCN4-2 |
| [ADR-0005](adr-0005-lighting-accumulation-dimensions.md) | Lighting Accumulation 4 Dimensions | Proposed | B-SCN4-3 |
| [ADR-0006](adr-0006-dismissal-gameover-path.md) | Dismissal/GAMEOVER Path Resolution | Proposed | B-RULE-1 |
| [ADR-0007](adr-0007-kpi-review-three-track-anchor.md) | KPI Review Three-Track Anchor | Proposed | B-SCN4-1 |
| [ADR-0008](adr-0008-visual-boundary-pillar4-vs-mute-parity.md) | Visual Boundary Pillar 4 vs Mute Parity | Proposed | B-AC-1 |
| [ADR-0009](adr-0009-event-schema-format.md) | Event Schema Format | Proposed | (Foundation 必创) |
| [ADR-0010](adr-0010-subject-inversion-lint-domains.md) | Subject Inversion Lint Master Domain List | Proposed | (Foundation 必创) |
| [ADR-0011](adr-0011-hud-diegetic-render.md) | HUD Diegetic Render Architecture | Proposed | (system-build sync) |
| [ADR-0012](adr-0012-three-density-rendering.md) | Three-Density Event Rendering Strategy | Proposed | (system-build sync) |
| [ADR-0013](adr-0013-archive-200-virtual-scroll.md) | Archive 200 Cap Virtual Scroll | Proposed | (system-build sync) |
| [ADR-0014](adr-0014-accessibility-settings-injection.md) | Accessibility Settings Injection Architecture | Proposed | (system-build sync) |

**全部 8 BLOCKING(B-DEP-1/2/3 + B-RULE-1 + B-SCN4-1/2/3 + B-AC-1)经 ADR 仲裁解决** ✅

Architecture Registry(`docs/registry/architecture.yaml`)已注册:
- 6 state ownership(meta_run_ended / accumulation_dimensions_4 / FAREWELL_EVENT_IDS / narrative_density / archive_index / scene_sub_mode)
- 6 interface contracts(scene_state_changed / accumulation_event / game_over_chain / kpi_review_three_track / settings_signals_debounced / foundation_mark_ready)
- 9 performance budgets(60fps / save 系列 / startup / hud / loc-reflow / kpi-review / gameover)
- 10 API decisions(JSON+Resource / WorkerThreadPool / scene switching / @abstract / EventResource / Theme font / CanvasLayer Shader / AccessKit / dual-focus / ScrollContainer)
- 10 forbidden patterns(Pillar 4 5 禁视觉 / per-signal-key debounce / ACTION_DAY CanvasLayer / batch delete archives / sync change_scene / dual emit game_over / farewell extra UI / per-Label font / per-Sprite material / accumulation_event multi-emit)

`design/registry/entities.yaml` 新增 1 constant:
- `kpi_review_intro_duration_ms = 800ms`(ADR-0007 三轨同步锚)

---

## Required ADRs

按优先级 + 依赖关系排序。**Foundation/Core 层 ADR 必须在 coding 启动前完成**。

### P0 — Foundation 层(coding 启动前必创)

#### ADR-0001 Signal Ownership Matrix(Cross-cutting BLOCKING 仲裁)
**解决**: B-DEP-1(narrative_density_changed 订阅缺失)+ B-DEP-2(离别事件 numeric_only 下游守门缺失)+ B-DEP-3(`accumulation_event` 3 GDD ownership 冲突)
**Owners**: technical-director + game-designer
**输出**: 跨 GDD 信号 owner + subscriber 完整 matrix(每信号:source GDD + 订阅者 GDD list + 协议契约 + AC 守门 GDD)
**关键决策**:
- `narrative_density_changed`:owner `#17 Settings`,subscriber `#10 Event Script` + `#14 Card Play UI` + `#15 Recap UI`
- 离别事件 numeric_only 强制:`#10` own enum 白名单 + `#13/#14/#15/#4/#5` 各自 AC 守门契约
- `accumulation_event`:owner `#5 Lighting`(单点 emit + 4 维度 schema)— `#6/#13` 仅订阅
- `subject_inversion_lint.py --domain` master list:8 域 EVENT/NPC/AP/ENERGY/KPI/EFFORT/TENURE/RECAP

#### ADR-0002 Autoload Init Order + Scene Tree Architecture
**Owners**: engine-programmer + technical-director
**关键决策**:
- `[autoload]` 列表声明顺序:Save → Localization → Audio → Lighting → Input → SceneDayFlow(末位)
- `#6 SceneDayFlow process_mode = PROCESS_MODE_ALWAYS`(C-ENG-02)
- watchdog Timer 节点 `process_mode = PAUSE_INHERIT`(`#6 Rule 6` pause game-time)
- `change_scene_to_packed()` + `ResourceLoader.load_threaded_request()` 预加载守门(C-ENG-05)
- `@abstract BaseSubModeState` + `@abstract EventEffect` 基类(4.5+ 实测验证 `#6 OQ-SDF-ENG-03` + `#10 Rule 18`)

#### ADR-0003 Save Format + WorkerThreadPool Strategy
**Owners**: lead-programmer + engine-programmer
**关键决策**:
- 三槽位序列化:`meta.save`(全局)/ `current_run.save`(当前 Run)/ `archive/[run_id].save`(历代)
- JSON-primary + Resource lazy parse(`#10` event_script 同模式)
- WorkerThreadPool autosave + 主线程 ARCHIVING 同步(主线程阻塞 ≤ 50ms)
- `current_schema_version = 1` 单调递增 + MVP 不支持迁移(VS 起 `_migrate_vN_to_vN+1` 链)
- `meta.run_ended = true` 原子 fsync 先于 1500ms transition(R-AP-2 + R-KPI-2 守门)

#### ADR-0004 Settings Reflow Coalescing(Cross-cutting BLOCKING 仲裁)
**解决**: B-SCN4-2(settings 防抖窗内多信号 reflow 合流策略未跨 GDD 锁定)
**Owners**: lead-programmer + ux-designer
**关键决策**:
- `font_size_changed` + `locale_changed` 同帧 → `#3 NOTIFICATION_TRANSLATION_CHANGED` 广播**合并为单次**
- `narrative_density_changed` 在 `#10 EVENT_ACTIVE` 态切档行为:**当前事件用旧密度完成,新密度从下次 `event_started` 起生效**(W-SCN4-5)
- PAUSE 中改 locale:reflow 在 PAUSE 期间挂起,resume 后单次 emit(W-SCN4-6)

### P0 — Core 层 BLOCKING 仲裁

#### ADR-0005 Lighting Accumulation 4 Dimensions(BLOCKING 仲裁)
**解决**: B-SCN4-3(`#5` accumulation 第 4 维定义 + `npc_empty_chairs` 归属)
**Owners**: art-director + game-designer + lighting-specialist
**关键决策**:
- `#5 Lighting` accumulation 4 维度锁定:`break_room_cracks` / `desk_stain_count` / `notice_board_age` / **`npc_empty_chairs`(由 `#8 npc_left_company` 驱动)**
- `#13 HUD_EMPTY_CHAIR` variant 由 `#8 npc_left_company` 直接驱动,**与 `#5 accumulation_event` 并行**(双源:HUD diegetic 元素 + Lighting 累积视觉)
- `notice_board_max_entries = 24` registry constant 引用一致

#### ADR-0006 Dismissal/GAMEOVER Path Resolution(BLOCKING 仲裁)
**解决**: B-RULE-1(`dismissal_triggered → GAMEOVER` 路径自相矛盾)
**Owners**: game-designer + qa-lead
**关键决策**:
- `#9 Edge 1.4` "M1 开除走剧本路径,不触发 GAME OVER" 与 `#9 Edge 2.1` "`#10` 接管 + `#6` dispatch GAMEOVER" 仲裁:
  - `dismissal_triggered(potential < -0.15)` → `#10` EVENT.KPI.FIRED_DISMISSAL 剧本 → 剧本结尾 `#9` emit `game_over_triggered(reason=DISMISSAL_SEVERE)`
  - 即"开除经过剧本但最终仍 GAME OVER"(双路径合并为单一最终路径)
- `#16 KPI Review UI` 仅订阅 `game_over_triggered`(已正确)
- AC-COMPAT 验证 `dismissal_triggered → game_over_triggered` 链 ≤ 30s(剧本时长上限)

#### ADR-0007 KPI Review Three-Track Anchor(BLOCKING 仲裁)
**解决**: B-SCN4-1(三轨节奏锚不同步)
**Owners**: game-designer + audio-director + art-director
**关键决策**:
- 锁定 `kpi_review_intro_duration_ms = 800ms`(三轨共用 anchor;entities.yaml + architecture.yaml 同值)
- `#5 Lighting` palette swap Tween 800ms `EASE_IN_OUT`(CanvasModulate → KPI_REVIEW 紫)
- `#4 Audio` Music Bus cross-fade out 800ms + 月末 stinger 同帧 + KPI_REVIEW BGM cross-fade in 800ms 后续启动
- `#16 KPI Review UI` 800ms intro fade-in `EASE_IN_OUT` + breakdown 三行渲染 ≤ 1 帧
- `final_transition_duration_ms = 1500ms` 仅锁 GAMEOVER 离职证明 `linear easing=NONE`,与 800ms KPI_REVIEW intro 区分清晰

#### ADR-0008 Visual Boundary Pillar 4 vs Mute Parity(BLOCKING 仲裁)
**解决**: B-AC-1("禁金光庆祝" vs `mute_visual_parity` 三方仲裁)
**Owners**: art-director + audio-director + qa-lead
**关键决策**:
- "收据热敏视觉动画"(mute_visual_parity 守门)≠ "金光庆祝动画"(Pillar 4 红线)
  - 收据热敏 = 灰度 / 单色 / 数据屏蓝光 ✓ 允许
  - 金光 / 金色光晕 / 庆祝粒子 / 闪光 = ❌ 禁止
- 三方联合 AC sign-off:`#16/#4/#5` 共评 mute 时 KPI 通过路径视觉静止度
- `#5 Lighting Rule 11` 8 类视觉禁止清单 + 4 例外白名单(收据热敏 / 数据屏蓝光 / 工位日落橙 / KPI 紫静止)

### P1 — Feature 层(系统 build 前必创)

#### ADR-0009 Event Schema Format(`#10 Rule 18` 已锁定)
**Owners**: godot-gdscript-specialist + lead-programmer
**关键决策**:
- `EventResource` `.tres` 单文件 per event(writer 用 Godot Inspector 编辑)+ `EventTrigger` 子 Resource + `@abstract EventEffect` 5 子类(SetFlag / RelationshipDelta / SpawnNotice / GiveUnlock / EmitGameOver)
- EditorPlugin EventLinter(实时反馈)+ Python CI lint `tools/event_schema_lint.py`(强制门:三档密度数量 + farewell numeric_only + dialogue_keys 存在)
- `Dictionary` 三层索引(by_trigger / by_chapter / by_npc)
- `_triggered_history: Dictionary[StringName, bool]` + `_cooldown_until: Dictionary[StringName, float]` + `_morning_blacklist: Dictionary[StringName, int]`(7 天滑动)
- 三档密度差异化 `effects_brief` (1-2) / `effects_standard` (2-4 必填) / `effects_verbose` (4-8) + 对应 `dialogue_keys_*` PackedStringArray

#### ADR-0010 Subject Inversion Lint Master Domain List
**Owners**: lead-programmer + writer + creative-director
**关键决策**:
- `subject_inversion_lint.py --domain` 8 域 master list 锁定:`AP / ENERGY / NPC / EVENT / KPI / EFFORT / TENURE / RECAP / GAMEOVER / EVAL / ARCHIVE / TUTORIAL_NPC / CHOICE`(11 子域,可由 master 8 域包含)
- 禁用词典:`友谊 / 喜欢 / 讨厌 / 加油 / 你能做到 / 励志 / 完美 / 高效 / 战略 / 大师 / 丝滑 / 跟手` 等
- 白名单后缀:`_IRONY`(KPI / GAMEOVER 反讽)+ `_BUREAUCRATIC`(KPI HR 口吻 + Audio anchor key)
- CI PR-blocking + writer review 第三层执法

### P2 — Presentation / VS / Alpha 层(可在系统 build 时同步创)

- ADR-0011 HUD Diegetic Render Pipeline(8 元素 sprite + variant 切换性能契约)
- ADR-0012 Three-Density Rendering Contract(`#14` flash overlay / long 立绘+对白 / numeric_only HUD-only 三档差异化)
- ADR-0013 Archive 200 List Virtual Scroll(`#16` Archive 列表使用 ItemList 虚拟滚动 — W-SCN4-11 修)
- ADR-0014 Accessibility Settings Injection(`#20` 跨 7+ Presentation 系统注入,Anti-P1 红线守门)

---

## Open Questions(deferred to Pre-Production / Polish)

继承 20 GDD 各自 OQ:

| OQ | 来源 GDD | Target |
|----|---------|--------|
| Save HDD+AV p99 实测 | #1 Save OQ-03 | Polish |
| `change_scene_to_packed()` 4.5 SceneTree 重构性能基准 | #6 OQ-SDF-ENG-02 | ADR-0002 实测 |
| `@abstract` 4.5+ 语法实测 | #6 OQ-SDF-ENG-03 | ADR-0002 实测 |
| 标准玩家 M11 ± 2 GAME OVER 实证 | #9 OQ-KPI-01 | /prototype core-loop |
| F1-F4 公式 RNG fairness 实测 | #10 OQ-EVT-03 | /prototype core-loop |
| Lisa 跳槽线必发 playtest | #10 OQ-EVT-08 + AC-FUNC-08 | Beta playtest |
| 三档密度切换 fallback 实测 | #10 R-EVT-5 + #14 | Polish |
| effort 三维度参数 8 NPC 实测 | #8 OQ-NPC-01 | Pre-Production /prototype |
| capacity_floor=0 vs 0.4 决策 | #9 OQ-KPI-02 | 野心版 ADR |
| 18 fresh session GDD reviews | 全 18 待 review GDD | 与 architecture 并行 |

---

## Phase 7b Sign-Off

**Technical Director Self-Review (TD-ARCHITECTURE)**: APPROVED WITH CONDITIONS
- ✓ 20 GDD 全套技术契约一致(/review-all-gdds Phase 3 PASS)
- ✓ Engine 知识缺口已识别 + 3 OQ 实测列项延 ADR-0002
- ✓ 8 BLOCKING 已映射到 6 ADR(ADR-0001/0004/0005/0006/0007/0008)
- ⚠ Conditions: 8 BLOCKING 必须在 ADR-0001..0008 落地后方可启动 coding;ADR-0011..0014 可与 system build 同步

**Lead Programmer Feasibility**: SKIPPED — Lean mode

---

## Recommended Next Steps

1. **`/architecture-decision` × 8 P0 ADRs**(强烈推荐立即启动): ADR-0001..0008,Foundation/Core 层 BLOCKING 全部仲裁
2. **`/architecture-decision` × 2 P1 ADRs**: ADR-0009/0010(系统 build 前必创)
3. **`/create-control-manifest`**(P0 ADR Accepted 后):产出 layer rules manifest(programmer 编码 do/don't 清单)
4. **`/architecture-review`**: 跑 traceability matrix 验证 GDD 需求 → ADR 覆盖率
5. **`/gate-check pre-production`**(全 ADR Accepted 后):Technical Setup → Pre-Production 门禁
6. **18 fresh session `/design-review` 排队**(与 architecture 并行,不阻塞)

**Architecture 准入 Pre-Production 门槛**:
- 8 P0 ADR + 2 P1 ADR 全部 Accepted
- `/create-control-manifest` 完成
- `/architecture-review` 报告无 Foundation 层 gap
- Test framework setup 完成
- Master architecture document(本文件)v1.0 + sign-off ✓
