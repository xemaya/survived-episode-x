# Control Manifest

> **Engine**: Godot 4.6 + GDScript(Forward+ 渲染,Godot Physics 2D)
> **Last Updated**: 2026-04-28
> **Manifest Version**: 2026-04-28
> **ADRs Covered**: ADR-0001..0017(全 Accepted — Sprint N+1 P1 fix DEBT-002 2026-05-02 升级;Sprint N+2 P0 fix 2026-05-02 ADR-0015/0016 cover RTM 8 TR gap;ADR-0017 cover TR-npc-001/002 NPC schema + F3 per-NPC 参数)
> **Status**: Active — regenerate with `/create-control-manifest update` when ADRs change

`Manifest Version` is the date this manifest was generated. Story files embed this date when created. `/story-readiness` compares a story's embedded version to this field to detect stories written against stale rules.

This manifest is a programmer's quick-reference extracted from all 14 Accepted ADRs, `.claude/docs/technical-preferences.md`, `.claude/docs/coding-standards.md`, `docs/registry/architecture.yaml` (41 entries), `design/registry/entities.yaml` (13 constants), and `docs/engine-reference/godot/` (deprecated-apis + breaking-changes + current-best-practices). For the reasoning behind each rule, see the referenced ADR.

**审稿模式**: TD-MANIFEST gate skipped — Lean mode(`production/review-mode.txt = lean`)。

---

## Foundation Layer Rules

*Applies to: Save System #1 / Input Handler #2 / Localization Hooks #3 / Audio Manager #4 / Lighting & Visual State #5 / Scene & Day Flow Controller #6 (Foundation 部分)*

### Required Patterns

#### Autoload + Scene Tree
- **`SceneDayFlowController` 必须为 `[autoload]` 列表末位声明** + `process_mode = PROCESS_MODE_ALWAYS`(C-ENG-02)— ADR-0002
- **6 Autoload 顺序**(`project.godot`):`SaveSystem → LocalizationHooks → AudioManager → LightingController → InputHandler → SceneDayFlowController`(末位);后置 `TutorialState → AccessibilitySettings`(VS / Alpha tier)— ADR-0002
- **Autoload `_init()` 中禁 `get_tree()` 调用**(返 null);依赖在 `_ready()` 处理 — ADR-0002
- **启动序列必须 bool ready 检查 + `await _mark_ready` signal**(R1 mitigation,避免重复 await race) — ADR-0002
- **`@abstract BaseSubModeState` 4.5+ 基类**;具体 State 必须 `extends BaseSubModeState` 并 override `on_enter()` / `on_exit()` / `tick(delta_units: int)` — ADR-0002
- **场景切换走 `ResourceLoader.load_threaded_request()` 预加载 + `change_scene_to_packed()`**(C-ENG-05) — ADR-0002
- **Watchdog Timer 节点 `process_mode = PAUSE_INHERIT`**(pause 期间挂起);Audio fade Tween / Lighting palette swap Tween `process_mode = PROCESS_MODE_ALWAYS`(R3 跨 pause 边界继续) — ADR-0002

#### Save / Persistence
- **三槽位 Save 文件结构**:`user://save/meta.save`(全局)+ `user://save/current_run.save`(当前 Run)+ `user://save/archive/[run_id].save`(历代)— ADR-0003
- **autosave + `current_run.save` 周期写盘走 `WorkerThreadPool.add_task()`**(主线程 0ms 影响) — ADR-0003
- **`meta.save` 启动期同步加载**(主线程阻塞,HDD+AV p99 ≤ 50ms ceiling) — ADR-0003
- **`meta.run_ended = true` 必须主线程同步 fsync,**先于** GAMEOVER 1500ms transition 启动**(R-AP-2 + R-KPI-2 守门,防 Alt+F4 续命) — ADR-0003 + ADR-0006
- **ARCHIVING 5 步事务主线程同步**(< 50ms;在 1500ms transition 演出**期间**执行,玩家无感) — ADR-0003
- **`current_schema_version: int` 单调递增**;每 schema 字段变更 +1;MVP 不支持迁移 — ADR-0003
- **Save 写盘格式 = JSON(`JSON.stringify`)**;运行时 `SaveStateLoader.load_*()` 构造 `SaveState extends Resource` strong-typed wrapper — ADR-0003
- **`FileAccess.store_*` 4.4+ 返回 `bool`**,必须 `assert(ok)` 校验返回值 — ADR-0003
- **Save Rule 18 retry backoff**;3 次失败通知玩家"存档失败" — ADR-0003
- **`meta.dismissal_pending = true` fsync** 在 `dismissal_triggered` emit 同步设置(R-A6-1 启动恢复 flag) — ADR-0006

#### Settings / Reflow
- **Localization broadcast 唯一 API**:`broadcast_translation_changed_once()`(单次 `propagate_notification(NOTIFICATION_TRANSLATION_CHANGED)`) — ADR-0004
- **`get_tree().paused = true` 期间 locale 切换挂起**;`request_soft_resume()` 时调用 `broadcast_translation_changed_once()` 单次 emit — ADR-0004
- **24 个 `notice_board` Label reflow 守 30 帧 watchdog**;超时 `push_warning` + force flush — ADR-0004
- **Settings 防抖单 timer 共享**(`#6` 持 `_settings_debounce_timer`,500ms);6 信号合流单次广播(节流 6×) — ADR-0004
- **`_pending_density_for_next_event` 缓冲**:`#10 EventScriptEngine` 在 `EVENT_ACTIVE` 态收 `narrative_density_changed` 缓冲到下个 `event_started` 应用 — ADR-0004
- **字体 fallback 链**(`#3 Loc Rule 9`):Step 0 直接渲染 → Step 1 Compact variant → Step 2 auto_fit floor 11 → Step 3 截断 + push_warning — ADR-0004 + ADR-0014

#### Lighting / Accumulation
- **`accumulation_event(type: StringName, delta_units: int)` signal 唯一 emit owner = `#5 Lighting`**;`#13 HUD` / 任何系统禁 emit — ADR-0001 + ADR-0005
- **4 累积维度 type 枚举**(StringName 常量):`yellowing_level` / `sticky_note_count` / `steam_density` / `npc_empty_chairs` — ADR-0005
- **触发链**:`scene_state_changed → MONTH_END` → +yellowing / `npc_left_company` → +sticky_note + +npc_empty_chairs / overage card → +steam_density — ADR-0005

#### Input
- **InputMap 12 actions 注册**:`act_pause / act_skip / act_focus_up/down/left/right / act_focus_prev/next / act_confirm / act_cancel / act_menu / act_remap` — `#2` GDD + ADR-0001
- **`input/dual_focus_mode = true`**(`project.godot`,Godot 4.6,键鼠+gamepad 同时 focus 独立) — ADR-0014
- **3-state Input 状态机**(NORMAL / MODAL_LOCKED / REMAPPING)+ skippable token 注册 API(`register_skippable(token_id, on_skip)` / `unregister_skippable(token_id)`) — `#2` GDD

### Forbidden Approaches

- **禁同步 `change_scene_to_file()`**(80-200ms 卡顿,违反 P5 5 秒进入承诺)— ADR-0002 + forbidden_pattern `sync_change_scene_to_file`
- **禁 per-signal-key 独立防抖**(Settings 6 信号同帧致 6 次 reflow 性能爆炸)— ADR-0004 + forbidden_pattern `per_signal_key_debounce`
- **禁 `accumulation_event` 多 owner emit**(`#6 / #13` 任何其他系统不可 emit) — ADR-0005 + forbidden_pattern `accumulation_event_multiple_emitters`
- **禁 `scene_state_changed` 多 owner emit**(`#6` 唯一 owner;下游禁自驱动 sub-mode 切换) — ADR-0001
- **禁 tres + ResourceSaver 全二进制 Save**(git diff 不友好,writer 不能直接看;用 JSON-primary)— ADR-0003
- **禁 SQLite 嵌入式数据库**(单机游戏 overkill,200 cap archive 用 JSON 已足够)— ADR-0003
- **禁全主线程同步 autosave**(50ms 主线程影响破 P5 + 60fps;必须 WorkerThreadPool)— ADR-0003
- **禁 PAUSE 中即时 reflow**(SceneTree.paused 期间游戏 UI 不渲染;必须挂起到 resume)— ADR-0004
- **禁 `EVENT_ACTIVE` 态中途切 narrative_density**(破坏当前事件叙事节奏;延后到下个 `event_started`)— ADR-0004
- **禁 4 个独立 accumulation signal**(yellowing_event / sticky_note_event 各自;用单 signal + 4 type 枚举)— ADR-0005
- **禁累积维度可重置 / 衰减**(违反 P3 死亡叙事 + Pillar 4 累积只增不减)— ADR-0005
- **禁 EventBus 全局信号总线 autoload**(违反 `#6 Rule 1` 单 owner;增加 indirection + 性能 hop)— ADR-0001
- **禁信号类型化 Resource (.tres signal 定义)**(过度工程;Godot 4.6 signal 已类型化参数)— ADR-0001
- **禁运行时 `assert(self.has_method('on_enter'))` 替代 `@abstract`**(用编辑器报错 + 运行时强制 override 的 `@abstract` 4.5+)— ADR-0002
- **禁 `SceneDayFlow` 不是 Autoload (改用 Scene Root Node)**(跨 scene 持久化困难;违反 Rule 1 单 owner)— ADR-0002
- **禁 WorkerThreadPool 任务内调用 SceneTree / Node API**(Godot 4.x 限制) — ADR-0003

### Performance Guardrails

- **autosave 主线程影响 ≤ 0ms**(WorkerThreadPool 异步) — ADR-0003
- **`meta.save` 启动期 load ≤ 50ms p99**(`autosave_perf_hard_ceiling_ms` HDD+AV ceiling) — ADR-0003 + entities.yaml
- **ARCHIVING 5 步事务主线程 < 50ms** — ADR-0003
- **启动期 P5 5 秒进入承诺**(MAIN_MENU 端到端 ≤ 5000ms p95;~720ms 必要 + ~4280ms 缓冲) — ADR-0002
- **6 Autoload init 完成 + `_mark_ready` ≤ 250ms 必要时间** — ADR-0002
- **`change_scene_to_packed()` 切换 ≤ 200ms p95**(若 4.5 性能 PASS;OQ-SDF-ENG-02 实测) — ADR-0002
- **`scene_state_changed` 同帧 dispatch ≤ 1 帧 + 16.6ms 总预算**(15 subscribers lightweight handler) — ADR-0001
- **`audio_preload_budget_ms = 200ms`** Audio bank preload — entities.yaml
- **`audio_loading_watchdog_ms = 10000ms`** Audio LOADING watchdog — entities.yaml
- **`bgm_loop_length_max_sec = 120s`** Music Bus loop 上限 — entities.yaml
- **`audio_bank_total_size_mb = 30MB`** `assets/audio/` CI lint 上限(`tools/audio_lint.gd` PR 阻塞)— entities.yaml
- **`lighting_loading_watchdog_ms = 10000ms`** Lighting LOADING watchdog — entities.yaml
- **`locale_lock_watchdog_ms = 30000ms`** locale 切换演出锁兜底 — entities.yaml
- **`meta_settings_debounce_ms = 500ms`** 防抖窗(5 GDD 消费者:Input/Loc/Audio/MainMenu/SceneFlow)— entities.yaml
- **`notice_board_max_entries = 24`** 累积视觉 cap(2 年月数 FIFO 驱逐)— entities.yaml
- **`AUTO_FIT_FLOOR_PX = 11`** 字体 fallback Step 2 下限(art-bible §7.2 禁用 10 px 笔画粘连) — `#3 Loc GDD`
- **`MAX_VISIBLE_REFLOWING_LABELS = 117`** 同帧 reflow 上限 — `#3 Loc GDD`
- **6 settings 信号同帧 → NOTIFICATION_TRANSLATION_CHANGED 仅 1 次广播**(节流 6×) — ADR-0004

---

## Core Layer Rules

*Applies to: Scene & Day Flow Controller #6(总线 dispatch)/ AP Economy #7 / NPC Relationship #8 / KPI Reverse Threshold #9*

### Required Patterns

#### Scene Flow Dispatch
- **`scene_state_changed(from: StringName, to: StringName)` signal 唯一 emit owner = `#6`** — ADR-0001
- **`request_transition(to: SubMode)` 唯一合法入口**(下游禁自驱动 sub-mode 切换;`#6` Rule 1 单 owner) — ADR-0002
- **8 sub-mode enum**:`MAIN_MENU` / `LOADING` / `ACTION_DAY` / `EVENT_ACTIVE` / `WEEKEND` / `KPI_REVIEW` / `GAMEOVER` / `PAUSE` / `SETTINGS` — `#6` GDD
- **主语翻转 dispatch 强制**(`#6` Rule 14):sub-mode 转移文本必须用反向主语(公司 → 员工)— `subject_inversion_lint.py` 守门 — ADR-0010
- **Game-time tick 离散事件驱动**:`ap_consumed → game-time +60min`(`#6` Rule 9) — ADR-0001 + `#7` GDD
- **`request_soft_pause(source) / request_soft_resume()` 仅 `#6` API**(各 Foundation 自决 fade / pause / debounced save) — ADR-0001

#### AP / Effort
- **`monthly_effort_summary(month, potential, ot, hero, ovr, days, capacity_factor)` signal owner = `#7 AP`**;subscriber `#9 KPI`(F1 输入) — ADR-0001
- **Hero card effort 三维度权重**(锁定值,KPI research deviation):`overtime: 0.45 / hero: 0.20 / overage: 0.30` — `#7` GDD
- **`weekend_rest_day` signal owner = `#6`**;subscriber `#7`(精力 +30) — ADR-0001
- **`ap_changed(current, max)` / `ap_consumed(amount)` signal owner = `#7`** — ADR-0001
- **AP cost 1/2/3 分布 lint**(40/40/20 比例;`#7` Rule 9) — `#7 + #11` GDD
- **AP 4 态状态机**:`AP_NORMAL` / `AP_OVERTIME_AVAILABLE` / `AP_OVERTIME_ACTIVE` / `AP_DEPLETED` — `#7` GDD

#### NPC
- **NPC 4 lifecycle 态**:`ACTIVE` / `LEAVING_ANNOUNCED` / `LEFT` / `RETURNED`;`npc_lifecycle_changed(npc, old_state, new_state, reason)` signal owner = `#8` — ADR-0001
- **`relationship_changed(npc, delta, new_score, reason)` signal owner = `#8`** — ADR-0001
- **`npc_left_company(npc, reason)` signal owner = `#8`**;subscriber `#10 / #13 / #16 / #19`(4 subs) — ADR-0001
- **NPC LEFT 视觉屏蔽 R-NPC-2**:`HUD_EMPTY_CHAIR` variant + `accumulation_event("npc_empty_chairs", +1)`(单 owner = `#5`) — ADR-0005 + ADR-0011
- **LEAVING_ANNOUNCED 期间道别卡走 farewell event 路径**(numeric_only,`farewell_event = true` flag)— ADR-0009
- **NPC `relationship_score: int [-100, +100]`** + `flags: Dict[String, bool]` — `#8` GDD

#### KPI / GAMEOVER
- **`game_over_triggered(reason, month)` signal 唯一 emit owner = `#9 KPI`**(`#10 / #6` 等任何系统禁 emit) — ADR-0006 + ADR-0001
- **Path B 双路径合并**:所有 GAMEOVER 走 `#9 dismissal_triggered → #10 EVENT.KPI.FIRED_DISMISSAL → #10 dismissal_finalized → #9 game_over_triggered → #16 1500ms transition` — ADR-0006
- **`settlement_locked` 在 `_trigger_path_b_dismissal` 同帧设 true**(R-KPI-2 守门,防月末重入) — ADR-0006
- **`settlement_locked` 写盘后 crash 恢复时 KPI Review 重新执行 GAME OVER 检测**(Pillar 3 不可逃) — `#9` Edge 8.1 + 10.3
- **dismissal watchdog 30s timer**(在 `#9 _trigger_path_b_dismissal` 启动;超时 fallback emit `dismissal_finalized` 自身) — ADR-0006
- **`kpi_review_started` signal 三轨 same-frame react**:`#16` Tween 800ms `EASE_IN_OUT` + `#5` palette 800ms `EASE_IN_OUT` + `#4` cross-fade 800ms — ADR-0007
- **`kpi_threshold_changed(old, new, delta_pct, breakdown)` emit 早于 `game_over_triggered`**(UI 先展示阈值再被覆盖,GDScript 单线程保证) — `#9` Edge 4.1
- **`kpi_prediction_hint(npc_id, hint_type)` signal owner = `#9`**;月末 -2 天触发 4 档台词 — ADR-0001
- **monthly_threshold 单调递增**(Anti-P1 红线;只升不降) — architecture.md principle 2

### Forbidden Approaches

- **禁双 emit `game_over_triggered`**(`#9` 唯一,`#10 / #6` 等禁 emit) — ADR-0006 + forbidden_pattern `dual_emit_game_over`
- **禁 Path A 直接路径**(`#9` 直接 emit `game_over_triggered` 无叙事 inject)— 已废弃,所有 GAMEOVER 走 Path B 戏谑 HR 文本 — ADR-0006
- **禁 KPI threshold 反向调低**(`monthly_threshold` 单调递增 — Anti-P1 红线) — `#9 GDD` + architecture.md principle 2
- **禁 `capacity_factor` 反向调高**(单调红线 — Anti-P1 红线) — architecture.md principle 2
- **禁 `#10` own `game_over_triggered`**(剧本中转,但 ownership 是 `#9` KPI 系统;`#10` 仅 emit `dismissal_finalized`) — ADR-0006
- **禁 `#9 settlement_locked = true` 时 emit kpi_review_started**(防月末重入) — `#9` Rule 11 R-KPI-2
- **禁 NPC LEFT 仍渲染原 NPC sprite / 表情**(R-NPC-2 视觉屏蔽守门) — ADR-0005 + ADR-0011
- **禁 AP / KPI / capacity 反向调整 effect / event / unlock / settings**(Anti-P1 红线 PR-blocking + push_error) — architecture.md principle 2

### Performance Guardrails

- **`scene_state_changed` 总线分摊 16.6ms 帧预算**(15 subscribers lightweight handler) — ADR-0001
- **`dismissal_triggered → game_over_triggered` 链 ≤ 30s 上限**(剧本时长上限) — ADR-0006
- **`kpi_review_intro_duration_ms = 800ms`** 三轨同步锚 — ADR-0007 + entities.yaml
- **`final_transition_duration_ms = 1500ms`** GAMEOVER linear easing=NONE — ADR-0006 + entities.yaml
- **三轨同步完成时间偏差 ≤ 1 帧** — ADR-0007
- **单卡完整链 16.6ms 帧预算分摊**:Audio ≤ 1ms / Lighting < 1ms / 各 UI ≤ 2ms / Save snapshot ≤ 4ms / 缓冲 ≈ 8ms — architecture.md
- **重负载必须 `call_deferred()` 到次帧**(R-SDF-3 守门) — `#6` GDD

---

## Feature Layer Rules

*Applies to: Event Script Engine #10 / Action Card #11 / Run Meta #12 / Tutorial #18 (VS)*

### Required Patterns

#### Event Schema
- **`EventResource` `.tres` 单文件 per event**(writer 用 Godot Inspector 编辑) — ADR-0009
- **`EventTrigger` Resource**(`TriggerType` enum:`CARD / NPC_RELATIONSHIP / KPI_THRESHOLD / MONTH_END / DAY_START / FLAG / COOLDOWN`) — ADR-0009
- **`@abstract EventEffect` 基类(4.5+)** + 5 子类:`SetFlagEffect` / `RelationshipDeltaEffect` / `SpawnNoticeEffect` / `GiveUnlockEffect` / `EmitGameOverEffect`(子类必须 override `apply(context)`) — ADR-0009
- **三档密度 effects 数量约束**:`brief 1-2` / `standard 2-4` (必填) / `verbose 4-8` — ADR-0009 + ADR-0012
- **三档密度 dialogue 数量约束**:`brief 1-3` / `standard 3-6` (必填) / `verbose 6-12` — ADR-0009 + ADR-0012
- **三档 fallback 链**:`brief` 缺 → `standard`,`verbose` 缺 → `standard`,**`standard` 必填**(实例化 assert) — ADR-0012
- **`#14 Card Play Dialogue UI` 是 density 主消费 layer**(`_select_*_by_density()` + fallback) — ADR-0012
- **`narrative_density` 在 `event_started` emit 时锁定到事件结束**(EVENT_ACTIVE 中途切档延后下个 event) — ADR-0004 + ADR-0012
- **`Dictionary` 三层索引**:`by_trigger / by_chapter / by_npc` — ADR-0009
- **`_triggered_history: Dictionary[StringName, bool]`** + `_cooldown_until: Dictionary[StringName, float]` + `_morning_blacklist: Dictionary[StringName, int]`(7 天滑动) — ADR-0009

#### Farewell Events
- **`FAREWELL_EVENT_IDS: Array[StringName]` 常量定义在 `data/event_constants.tres`**:`LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF / GRIND_KING_PROMOTED_LEAVE / OLD_OIL_OPTIMIZED_OUT`(VS 起 +`NEWBIE_LEAVE / FLATTERER_LEAVE`) — ADR-0001 + ADR-0009
- **`farewell_event = true` flag 时,`dialogue_keys_*` 仅 1 个 = `EVENT.[event_id].TITLE_NUMERIC`**(numeric_only 守门) — ADR-0009
- **下游 4 GDD farewell AC 守门**:`#13` 禁 flash overlay / `#15` 仅一行 numeric_only key / `#4` 禁切 BGM / `#5` 禁特殊 palette swap — ADR-0001 + forbidden_pattern `farewell_event_extra_ui`
- **`tools/farewell_lint.gd` PR 阶段比对 `#10 FAREWELL_EVENT_IDS` 与下游 GDD AC 引用一致** — ADR-0001

#### Lint Chain
- **EditorPlugin EventLinter 实时反馈** + Python CI lint `tools/event_schema_lint.py`(强制门:三档密度数量 + farewell numeric_only + dialogue_keys 存在 + scene_id ⊂ `#6` sub-mode + npc_id ⊂ `#8` 注册表 + flag_key ⊂ flag 注册表 + 嵌套 ≤ 2 层)— ADR-0009 + ADR-0010
- **`subject_inversion_lint.py` 8 master domain**:`EVENT / NPC / AP / KPI / EFFORT / TENURE / RECAP / TUTORIAL` — ADR-0010
- **`tools/lint_config.toml` 单点 lint 配置文件** — ADR-0010
- **白名单后缀**:`_IRONY`(KPI / GAMEOVER 反讽)+ `_BUREAUCRATIC`(KPI HR 口吻 + Audio anchor key) — ADR-0010
- **CI PR-blocking lint chain**:`subject_inversion_lint.py` + `event_schema_lint.py` + `signal_ownership_lint.py` + `farewell_lint.gd` + `audio_lint.gd`(asset size)+ `art-bible §7.1 lint`(CanvasLayer ACTION_DAY) — ADR-0001/0009/0010/0011

#### Localization Key 命名
- `EVENT.[CATEGORY].[EVENT_ID].DIALOGUE.[INDEX]_[DENSITY]`(brief/standard/verbose)
- `EVENT.[CATEGORY].[EVENT_ID].TITLE_NUMERIC`(farewell numeric_only)
- `EVENT.[CATEGORY].[EVENT_ID].EFFECT_TEXT.[INDEX]`
- `EVENT.KPI.FIRED_DISMISSAL.[reason]`(`kpi_fail_3 / kpi_overflow / relationship_collapse`)— ADR-0006 + ADR-0009

#### Run Meta / Archive
- **`run_meta_unlock(content_id)` 严格 5 类白名单**(content-only):`codex / memo / npc / event_branch / ending` — ADR-0001 forbidden_pattern + #12 GDD
- **`run_started / run_ended(run_id, month, reason)` signal owner = `#12`** — ADR-0001
- **`archive_completed(run_id)` signal owner = `#1 Save`**;subscriber `#12 / #6 → MAIN_MENU` — ADR-0001
- **archive 200 cap FIFO 自动驱逐**(`archive_hard_cap_count = 200`) — ADR-0013 + entities.yaml
- **`archive_index: Array[ArchiveIndexEntry]`** 启动期已加载(~5KB 在 `meta.save`);archive 详情懒加载 — ADR-0013
- **`archive_detail_cache` LRU 20 entry cap (~100KB)** — ADR-0013

### Forbidden Approaches

- **禁 `events.json` 集中文件**(merge conflict 频发,200+ events 难维护;用单 `.tres` per event) — ADR-0009
- **禁 GDScript func 直接定义事件**(`func event_lisa_lunch():`,writer 无法独立 author) — ADR-0009
- **禁单档密度 / 五档密度**(三档 Goldilocks zone) — ADR-0012
- **禁自动密度算法**(根据玩家 session 长度选择;玩家失去控制感) — ADR-0012
- **禁 `#10` 主消费 layer**(数据层职责越界,UI 细节污染数据流;`#14` 主消费) — ADR-0012
- **禁 13 子域全列(无 master 简化)**(writer 难记,lint 配置爆炸) — ADR-0010
- **禁 master 域更细(15+)**(writer 选择困难,lint 模板爆炸) — ADR-0010
- **禁 `delete_archive(run_id)` / `clear_all_archives()`**(P3 仪式感;Archive 是墓园,不可被"管理") — ADR-0013 + forbidden_pattern `archive_batch_delete`
- **禁 archive 搜索 / 筛选 / 重命名**(同上 P3 仪式感) — ADR-0013
- **禁 archive cap 升至 1000**(200 已 super-player 容量) — ADR-0013
- **禁全加载 200 archive 详情**(启动期 1MB I/O 影响 P5;懒加载详情) — ADR-0013
- **禁 Run Meta unlocks 含机械成长字段**(content-only 5 类白名单 — Anti-P1 红线 PR-blocking + push_error) — ADR-0001
- **禁 farewell event 含 `choices`**(numeric_only 语义不含 UI;运行时丢弃 + push_warning) — `#10` Edge 11.3
- **禁 EventEffect 子类未注册到白名单运行**(实例化 assert) — ADR-0009

### Performance Guardrails

- **EventResource load 每个 < 1ms**;200 events 总 ~200ms 启动期(分批加载缓解) — ADR-0009
- **200 events 加载内存 < 5MB** — ADR-0009
- **lint CI 运行 < 5s**(200 events × 14 master/sub-domain 检查) — ADR-0010
- **Archive 屏进入 ~500ms 内显示 200 list**(ScrollContainer 自动 culling) — ADR-0013
- **单 archive 详情 ~100ms 显示**(懒加载) — ADR-0013

---

## Presentation Layer Rules

*Applies to: HUD Diegetic #13 / Card Play Dialogue UI #14 / Daily/Weekly Recap UI #15 / KPI Review & Game Over UI #16 / Main Menu / Pause / Settings UI #17 / Notification & Warning #19 (VS) / Accessibility Options #20 (Alpha 注入)*

### Required Patterns

#### Diegetic Architecture
- **8 diegetic 元素 mapping**(全 Node2D):便利贴 / 咖啡杯 / 显示屏 / 考勤表 / 日历 / NPC 表情 / NPC 站位 / 空椅 — ADR-0011
- **节点树架构**:
  ```
  World (Node2D, layer=0)
  ├── Background (TileMap)
  ├── DiegeticHUD (Node2D)               # 8 元素全在此
  ├── DiegeticNotifications (Node2D)     # `#19` 通知通过 diegetic 元素 variant
  └── CanvasLayer (layer=1)              # 唯一 UI 层
      ├── PauseMenu (Control) [hidden by default]
      ├── KPIReviewScreen (Control) [hidden]
      ├── GameOverScreen (Control) [hidden]
      └── SettingsScreen (Control) [hidden]
  ```
  — ADR-0011
- **CanvasLayer 仅 4 sub-mode 切换屏使用**:`PAUSE / KPI_REVIEW / GAMEOVER / SETTINGS` — ADR-0011
- **`_on_scene_state_changed` 切换 CanvasLayer.visible**:仅 `to in [&"PAUSE", &"SETTINGS", &"KPI_REVIEW", &"GAMEOVER"]` — ADR-0011
- **diegetic 文本** = Node2D + Sprite2D bg + Label 子节点(局部 Control 仅文本)— ADR-0011

#### Signal Subscriptions
- **8 元素信号订阅**(参 ADR-0011 + ADR-0001):
  | HUD 元素 | 订阅信号 |
  |---------|---------|
  | DeskCoffeeMug | `hero_card_played` |
  | DeskDocumentStack | `event_completed` + `hero_card_played` |
  | DeskStickyNotes | `accumulation_event(sticky_note_count)` |
  | NoticeBoard | `npc_left_company` + `event_completed` |
  | OfficeSteam | `accumulation_event(steam_density)` |
  | NPCExpression | `relationship_changed` + `npc_lifecycle_changed` |
  | NPCPosition | `accumulation_event(npc_empty_chairs)` + `npc_lifecycle_changed` |
  | CalendarKPIIndicator | `kpi_threshold_changed` |

#### Three-Density Rendering
- **三档密度差异化渲染**(`#14` 主消费):
  | Density | 渲染 |
  |---------|------|
  | brief | flash overlay(`#13` 单行 Label,1.5s timer + queue_free)|
  | standard | long 立绘 + 对白 + 选项(`#14` Control)|
  | verbose | 完整 long 立绘 + 4-8 effects + 6-12 dialogue |
  | numeric_only | HUD-only(`#13` 数字变化无 UI 事件)|
  — ADR-0012
- **`_select_dialogue_keys_by_density(event, density)` + `_select_effects_by_density(event, density)` fallback 链**(在 `#14`)— ADR-0012

#### KPI Review / GAMEOVER UI
- **KPI Review 800ms intro fade-in `EASE_IN_OUT`** + breakdown 三行渲染 ≤ 1 帧 — ADR-0007
- **GAMEOVER 1500ms `linear easing=NONE` Tween**(skippable 但禁推翻 transition tone) — ADR-0006 + #1 final_transition
- **GAMEOVER.CERTIFICATE.[reason] Localization key 渲染**(`#10` EVENT.KPI.FIRED_DISMISSAL.[reason] 文本嵌入) — ADR-0006 + ADR-0009
- **三屏 `#16` own 节点树**:KPIReviewScreen + GameOverScreen + ArchiveScreen — ADR-0006/0007/0013

#### Archive UI
- **ScrollContainer + ArchiveCard 全实例**(Godot 自动 culling)— ADR-0013
- **默认排序最新 → 最旧**(timestamp desc)+ 无搜索 + 无筛选(P3 仪式感)— ADR-0013

#### Hero Card Reaction
- **三 element 反馈**:
  - `HUD_DESK_COFFEE_MUG` 蒸汽粒子(0.5s 渐隐)
  - `HUD_DESK_DOCUMENT_STACK` 翻页 0.3s 动画
  - `HUD_NPC_EXPRESSION` raised eyebrow 0.5s flash + return
  - `#5 Lighting` brightness lift +0.05 0.5s(EASE_OUT 0.25s + EASE_IN 0.25s)
  - `sfx_hero_card_played` Bus=SFX
  — ADR-0008 + ADR-0011

#### HR / Recap Tone
- **breakdown 三行 HR 戏谑口吻**(KPI research §8.1 三行格式;`subject_inversion_lint.py --domain KPI` 守门) — ADR-0010
- **HR 周报口吻 lint**(`subject_inversion_lint.py --domain RECAP`;扩展 RECAP.* keys) — ADR-0010
- **AC-FAREWELL-01 在 `#13/#15/#4/#5` 各自 Section H** + AC-DENSITY-01 在 `#15` Section H — ADR-0001

#### Settings / Accessibility Injection
- **Settings 6 信号合流**:`bus_volume_changed × 4` + `locale_changed` + `keymap_changed` + `font_size_changed` + `colorblind_mode_changed` + `narrative_density_changed`(经 `#6` 单 timer 500ms debounce)— ADR-0001 + ADR-0004
- **字体大小注入**:`Theme.set_default_font_size()` 单点 override(主 Theme `res://themes/main_theme.tres`)— ADR-0014
- **色盲注入**:`CanvasLayer` post-process Shader (canvas_item shader_type)整屏(Control + Node2D 同时适配)— ADR-0014
- **AccessKit 启用**:`get_window().use_accessibility = true`(4.5+) — ADR-0014
- **Control aria_label / aria_role 标注**(关键 UI 节点 .tscn 配置)— ADR-0014
- **Notification `#19` 通过 `#13 HUD` diegetic 元素 visual variant 显示**(无 popup) — ADR-0011

### Forbidden Approaches

- **禁 ACTION_DAY / EVENT_ACTIVE / WEEKEND / MAIN_MENU sub-mode 期间 `CanvasLayer.visible = true`**(违反 art-bible §7.1)— ADR-0011 + forbidden_pattern `action_day_canvaslayer_visible`(`art-bible §7.1 lint` PR-blocking)
- **禁多 CanvasLayer 嵌套**(单 CanvasLayer 守 art-bible)— ADR-0011
- **禁全 Control + Theme 模拟 diegetic**(违反 art-bible §7.1 主轨;Control 是 screen-space)— ADR-0011
- **禁 SubViewport 嵌套(diegetic 在 SubViewport 内)**(性能开销 + 输入路由复杂;Node2D 已够)— ADR-0011
- **禁 farewell event 渲染 flash overlay** / 禁特殊 palette / 禁 BGM 切换 / 禁特殊 UI(`#13/#5/#4` 共守) — ADR-0001 + forbidden_pattern `farewell_event_extra_ui`
- **禁 5 类 Pillar 4 视觉**(全游戏全场景禁):金光 / sparkle / 烟花 / 彩虹 / 鸡汤 caption — ADR-0008 + forbidden_pattern `pillar4_celebration_visuals`
- **禁 per-Label `font_size` override**(必须 `Theme.set_default_font_size()` 单点) — ADR-0014 + forbidden_pattern `per_label_font_override`
- **禁 per-Sprite2D `ColorBlindMaterial` override**(必须 CanvasLayer post-process Shader) — ADR-0014 + forbidden_pattern `per_sprite_colorblind_material`
- **禁 Texture swap(不同色盲模式不同 texture set)**(内存 ×4 + 资源管理复杂) — ADR-0014
- **禁 Notification popup / "警告!"弹层**(diegetic 主轨;`#19` 通过 `#13` 元素 variant) — `#19` GDD + ADR-0011
- **禁 mute 模式下用"另一套视觉"**(违反 a11y "无差别" 原则) — ADR-0008
- **禁屏幕震动 (screen shake) 替代金光**(语义错位) — ADR-0008
- **禁 UI 文本框 "+1 hero card played"**(违反 diegetic 主轨;P3 黑色幽默不"成就解锁"风格) — ADR-0008
- **禁 Virtual scroll 自实现 culling + recycle**(过度工程;Godot ScrollContainer 自动 culling 已够) — ADR-0013
- **禁 reduce_motion / TTS in MVP**(VS / 野心版 推迟) — ADR-0014
- **禁 `#20 Accessibility` 修改任何数值规则**(Anti-P1 红线 PR-blocking;仅注入字体 / 色盲 / a11y)— ADR-0014

### Performance Guardrails

- **`#13 HUD` 帧预算 ≤ 2ms / 屏** — ADR-0011 + #13 GDD
- **总 draw call ≤ 70 / 100 budget**(8 静态 + 12 sticky + 24 notice + ~10 dust;Godot 自动 batching 应聚合更多) — ADR-0011 + architecture.yaml
- **flash overlay 渲染 ≤ 0.2ms**(单行 Label + 1.5s timer + queue_free) — `#13` GDD
- **Localization reflow ≤ 30 帧端到端** — ADR-0004 + entities.yaml
- **单 verbose event 渲染 ≤ 30s**(writer 守 verbose 12 dialogue cap;CI lint 字数检查) — ADR-0012
- **AccessKit init ≤ 50ms 启动期开销** — ADR-0014
- **brightness lift ≤ 0.07**(自动化 visual diff 测试;默认 0.05) — ADR-0008

---

## Global Rules (All Layers)

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `PlayerController`, `CardScript`, `NpcRelationship` |
| Variables / Functions | snake_case | `move_speed`, `take_damage()`, `spend_action_point()` |
| Signals | snake_case 过去式 | `health_changed`, `card_played`, `day_ended`, `kpi_evaluated` |
| Files | snake_case 与类同名 | `player_controller.gd`, `card_script.gd` |
| Scenes | PascalCase 与根节点同名 | `PlayerController.tscn`, `DayTimeline.tscn` |
| Constants | UPPER_SNAKE_CASE | `MAX_AP_PER_DAY`, `KPI_TENURE_PENALTY_RATE` |

### Performance Budgets

| Target | Value |
|--------|-------|
| Framerate | 60 FPS 稳定 |
| Frame budget | 16.6 ms |
| Draw calls | < 100(像素 2D 宽裕,Godot 自动 batching) |
| Memory ceiling | < 500 MB(MVP 规模) |
| Startup → MAIN_MENU | ≤ 5000 ms p95 |
| Save autosave 主线程 | ≤ 0 ms(WorkerThreadPool) |
| `meta.save` load | ≤ 50 ms p99(HDD+AV) |
| ARCHIVING 5 步事务 | < 50 ms 主线程 |
| `scene_state_changed` 同帧 dispatch | ≤ 1 帧(15 subs)|
| `kpi_review_intro_duration_ms` | 800 ms 三轨锚 |
| `final_transition_duration_ms` | 1500 ms GAMEOVER |
| HUD draw call | ≤ 70 / 100 budget |
| Localization reflow | ≤ 30 帧 |

### Approved Libraries / Addons

- **GUT (Godot Unit Test)** — 测试框架(`/test-setup` 安装)
- 无第三方 addon(MVP)
- Godot 4.6 内置 stdlib 全可用

### Forbidden APIs (Godot 4.6)

These APIs are deprecated or unverified for Godot 4.6:

| Deprecated | Use Instead | Since |
|------------|-------------|-------|
| `TileMap` | `TileMapLayer` | 4.3 |
| `VisibilityNotifier2D` / `VisibilityNotifier3D` | `VisibleOnScreenNotifier2D` / `VisibleOnScreenNotifier3D` | 4.0 |
| `YSort` | `Node2D.y_sort_enabled` | 4.0 |
| `Navigation2D` / `Navigation3D` | `NavigationServer2D` / `NavigationServer3D` | 4.0 |
| `EditorSceneFormatImporterFBX` | `EditorSceneFormatImporterFBX2GLTF` | 4.3 |
| `yield()` | `await signal` | 4.0 |
| `connect("signal", obj, "method")` | `signal.connect(callable)` | 4.0 |
| `instance()` / `PackedScene.instance()` | `instantiate()` | 4.0 |
| `get_world()` | `get_world_3d()` | 4.0 |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | 4.0 |
| `duplicate()` for nested resources | `duplicate_deep()` | 4.5 |
| `Skeleton3D.bone_pose_updated` signal | `skeleton_updated` | 4.3 |
| `AnimationPlayer.method_call_mode` | `AnimationMixer.callback_mode_method` | 4.3 |
| `AnimationPlayer.playback_active` | `AnimationMixer.active` | 4.3 |

Source: `docs/engine-reference/godot/deprecated-apis.md`

### Forbidden Patterns

| Deprecated Pattern | Use Instead | Why |
|--------------------|-------------|-----|
| String-based `connect()` | Typed signal connections (`signal.connect(callable)`) | Type-safe, refactor-friendly |
| `$NodePath` in `_process()` | `@onready var` cached reference | Performance: path lookup every frame |
| Untyped `Array` / `Dictionary` | `Array[Type]`, typed variables | GDScript compiler optimizations |
| `Texture2D` in shader parameters | `Texture` 基类 | Changed in 4.4 |
| 手动 post-process viewport chains | `Compositor` + `CompositorEffect` | Structured post-processing (4.3+) |

### Cross-Cutting Constraints

- **Pillar 4 反英雄红线 PR-blocking**:`subject_inversion_lint.py` 8 域 master list(EVENT/NPC/AP/KPI/EFFORT/TENURE/RECAP/TUTORIAL)CI 联运守门 — architecture.md principle 1
- **Anti-Pillar 1 单调红线**:AP / KPI threshold / capacity_factor 三轴单调(8 不可上调 / threshold 只升不降 / capacity 只降不升);任何 effect / event / unlock / settings 反向 → PR-blocking + push_error — architecture.md principle 2
- **Diegetic UI 锁(art-bible §7.1)**:无屏幕悬浮 HUD;所有信息内嵌工位场景物理元素 — architecture.md principle 3 + ADR-0011
- **`#6` 单点 dispatch**:`scene_state_changed` 总线 owner 单一(`#6`)+ `request_transition()` 唯一合法入口 + 主语翻转 dispatch 强制(Rule 14)+ pause game-time vs wall-clock 边界(Rule 6)— architecture.md principle 4
- **数据驱动 + 引擎契约锁**:数值参数从 `config/*.tres` 加载,禁硬编码;Godot 4.6 specific API 集中在 `#6 C-ENG-01..10` — architecture.md principle 5

### Verification-Driven Development(coding-standards)

- **Write tests first** 添加 gameplay 系统(KPI 公式 / AP 计算 / 涨阈值算法必测)
- **UI 改动 verify with screenshots**;Compare expected output to actual output before marking work complete
- **Public APIs 必须含 doc comments**
- **Every system 必须含 ADR**(`docs/architecture/`)
- **Gameplay 数值必须 data-driven**(`config/*.tres`),禁硬编码
- **Public methods 必须 unit-testable**(dependency injection over singletons)
- **Commits 必须 reference 设计文档或 task ID**

### Test Evidence Requirements

| Story Type | Required Evidence | Location | Gate Level |
|---|---|---|---|
| **Logic**(formulas, AI, state machines)| Automated unit test — must pass | `tests/unit/[system]/` | BLOCKING |
| **Integration**(multi-system)| Integration test OR documented playtest | `tests/integration/[system]/` | BLOCKING |
| **Visual/Feel**(animation, VFX, feel)| Screenshot + lead sign-off | `production/qa/evidence/` | ADVISORY |
| **UI**(menus, HUD, screens)| Manual walkthrough doc OR interaction test | `production/qa/evidence/` | ADVISORY |
| **Config/Data**(balance tuning)| Smoke check pass | `production/qa/smoke-[date].md` | ADVISORY |

### Automated Test Rules

- **Naming**: `[system]_[feature]_test.gd` 文件;`test_[scenario]_[expected]` 函数
- **Determinism**: 同结果每次跑 — 无 random seeds(除非 RNG seed 可控测试)、无 time-dependent assertions
- **Isolation**: 各 test 自 setup + teardown;tests 不依赖执行顺序
- **No hardcoded data**: Test fixtures 用 constant files / factory functions(boundary value tests 例外)
- **Independence**: Unit tests 不调外部 API / DB / file I/O(用 dependency injection)

### CI/CD

- **Test runner**: `godot --headless --script tests/gdunit4_runner.gd`(`/test-setup` 配置)
- **Test failure = blocking gate**(no merge if tests fail)
- **Never disable / skip failing tests**(fix underlying issue)
- **Lint chain**: `subject_inversion_lint.py` + `event_schema_lint.py` + `signal_ownership_lint.py` + `farewell_lint.gd` + `audio_lint.gd` + `art-bible §7.1 lint` 全 PR-blocking

---

## Manifest Maintenance

- **Re-generate** 每次新 ADR Accepted 或现有 ADR Revised — `/create-control-manifest update`
- **`Manifest Version`** 字段是 stories 的 staleness reference — `/story-readiness` 比对 story 嵌入版本与本 field
- **Source 验证**:每条 rule 必须 trace to ADR / technical-preference / engine reference;无源 rule 拒绝添加

---

**End of Control Manifest.**
