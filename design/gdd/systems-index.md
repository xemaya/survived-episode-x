# Systems Index: 《活过第 X 集》

> **Status**: Draft
> **Created**: 2026-04-22
> **Last Updated**: 2026-04-26
> **Source Concept**: design/gdd/game-concept.md
> **Source Art Bible**: design/art/art-bible.md
> **Review Mode**: Lean (TD-SYSTEM-BOUNDARY / PR-SCOPE / CD-SYSTEMS 跳过)

---

## Overview

《活过第 X 集》是一款单人像素 2.5D 办公室生存策略模拟游戏，玩家通过每日分配 8 AP（行动点）打行动卡，在**反向 KPI**（维持平庸的博弈）的核心循环中努力"活得久"。机制层面需要 5 个核心 Gameplay 系统协同 —— **AP 经济 + 行动卡 + 事件剧本引擎 + NPC 关系网 + KPI/反向阈值** —— 这五者之间有明确的数据流（AP 驱动卡、卡触发事件、事件改 NPC 关系和 KPI）。围绕这五个核心，还需要 Foundation 基础设施（存档 / 输入 / 本地化 / 音频 / 光照）、Presentation UI（diegetic HUD + 卡 UI + 周/月结算 UI + 主菜单 + Game Over）、以及 Meta（跑局元数据 / 教学 / Accessibility）。总计 **20 个系统**，**MVP 阶段需要 17 个**（单人 3 个月，每个尽量短设计），VS 阶段扩 2 个（Tutorial + 增强警告），Alpha 阶段扩 1 个（Accessibility 设置屏）。

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Save System | Persistence | MVP | Designed | [save-system.md](save-system.md) | — |
| 2 | Input Handler | Core | MVP | Approved | [input-handler.md](input-handler.md) | — |
| 3 | Localization Hooks | Core | MVP | Designed | [localization-hooks.md](localization-hooks.md) | — |
| 4 | Audio Manager | Audio | MVP | Designed | [audio-manager.md](audio-manager.md) | — |
| 5 | Lighting & Visual State Controller | Core | MVP | Designed | [lighting-visual-state.md](lighting-visual-state.md) | — |
| 6 | Scene & Day Flow Controller *(inferred)* ⭐ | Core | MVP | Designed | [scene-day-flow-controller.md](scene-day-flow-controller.md) | Save, Input |
| 7 | AP Economy System | Gameplay | MVP | Designed | [ap-economy-system.md](ap-economy-system.md) | Scene & Day Flow |
| 8 | NPC Relationship System | Gameplay | MVP | Designed | [npc-relationship-system.md](npc-relationship-system.md) | Save |
| 9 | KPI & Reverse Threshold System ⭐ | Gameplay | MVP | Designed | [kpi-reverse-threshold-system.md](kpi-reverse-threshold-system.md) | Scene & Day Flow, Save |
| 10 | Event Script Engine ⭐ | Narrative | MVP | Designed | [event-script-engine.md](event-script-engine.md) | NPC Relationship, Save |
| 11 | Action Card System | Gameplay | MVP | Designed | [action-card-system.md](action-card-system.md) | AP Economy, NPC Relationship, Event Script |
| 12 | Run Meta System (MVP simple) | Progression | MVP | Designed | [run-meta-system.md](run-meta-system.md) | KPI, Save, Event Script |
| 13 | HUD System (Diegetic) | UI | MVP | Designed | [hud-diegetic.md](hud-diegetic.md) | AP Economy, NPC Relationship, Scene & Day Flow, Lighting, Localization |
| 14 | Card Play & Dialogue UI *(inferred)* | UI | MVP | Designed | [card-play-dialogue-ui.md](card-play-dialogue-ui.md) | Action Card, Event Script, Localization |
| 15 | Daily / Weekly Recap UI | UI | MVP | Designed (revised 2026-04-29) | [daily-weekly-recap-ui.md](daily-weekly-recap-ui.md) | AP Economy, KPI, Event Script, Localization, **Scene Flow ctx payload** (flag #6), **Input min_display_ms** (flag #7) |
| 16 | KPI Review & Game Over UI | UI | MVP | Designed | [kpi-review-game-over-ui.md](kpi-review-game-over-ui.md) | KPI, Run Meta, Localization |
| 17 | Main Menu / Pause / Settings UI (basic) *(inferred)* | UI | MVP | Designed | [main-menu-pause-settings-ui.md](main-menu-pause-settings-ui.md) | Save, Localization, Input, Audio, Lighting, Scene & Day Flow |
| 18 | Tutorial / Onboarding System *(inferred)* | Meta | Vertical Slice | Designed | [tutorial-onboarding-system.md](tutorial-onboarding-system.md) | AP Economy, Action Card, Event Script, Scene & Day Flow, KPI System, Save |
| 19 | Notification & Warning System (enhanced) *(inferred)* | UI | Vertical Slice | Designed | [notification-warning-system.md](notification-warning-system.md) | Scene & Day Flow, AP Economy, NPC Relationship, KPI System, HUD Diegetic |
| 20 | Accessibility Options *(inferred)* | Meta | Alpha | Designed | [accessibility-options.md](accessibility-options.md) | All Presentation systems |

⭐ = Bottleneck 系统（多系统依赖，高风险，早固化）

---

## Categories

| Category | Description | Systems in this game |
|----------|-------------|---------------------|
| **Core** | 基础框架 / 跨系统骨架 | Input, Localization, Lighting, Scene & Day Flow |
| **Gameplay** | 核心玩法机制 | AP Economy, NPC Relationship, KPI & Reverse Threshold, Action Card |
| **Progression** | 玩家跨时间的成长 | Run Meta |
| **Persistence** | 存档与延续 | Save System |
| **UI** | 玩家面对的信息呈现 | HUD (Diegetic), Card Play UI, Recap UI, KPI Review/GO UI, Main Menu, Notification |
| **Audio** | 声音系统 | Audio Manager |
| **Narrative** | 剧情与事件 | Event Script Engine |
| **Meta** | 跳出核心循环的系统 | Tutorial, Accessibility |

> 不适用类别已删除：**Economy**（本作的"经济"就是 AP，放在 Gameplay 已经合理）

---

## Priority Tiers

| Tier | Definition | Target Milestone | Count | Design Urgency |
|------|-----------|------------------|-------|----------------|
| **MVP** | 核心循环成立的最小集合 | 3 个月单人 demo | 17 | 全部设计 FIRST |
| **Vertical Slice** | 完整 1 年内容 + 关键叙事设施 | 5-6 个月 | 2 | 设计 SECOND |
| **Alpha** | 全功能齐 + Accessibility 设置屏 | 9-12 个月 | 1 | 设计 THIRD |
| **Full Vision** | 英文本地化 / Switch 移植 / 多公司类型 | 18+ 个月 | 0（新系统）| — |

---

## Dependency Map

### Foundation Layer（5 — 无依赖，可并行设计）

1. **Save System** — 所有需要持久化的系统都经此接口；定义序列化 schema 是早期关键决策
2. **Input Handler** — KB/Mouse + Gamepad 包装，所有 UI 和玩家动作通过此入口
3. **Localization Hooks** — 字符串 / 字体 / 多语言 hooks；**日 1 搭好**避免后期重写
4. **Audio Manager** — Godot AudioStreamPlayer wrapper；SFX + ambient + 音乐 bus
5. **Lighting & Visual State Controller** — CanvasModulate 色调切换 + palette swap shader + 累积环境 sprite state

### Core Layer（4 — 依赖 Foundation）

1. **Scene & Day Flow Controller ⭐** — depends on: Save, Input — 游戏心跳 / 状态机
2. **AP Economy System** — depends on: Scene & Day Flow — 每日 8 AP + 早退/加班规则
3. **NPC Relationship System** — depends on: Save — 8-10 NPC 好感度 + flag
4. **KPI & Reverse Threshold System ⭐** — depends on: Scene & Day Flow, Save — 周/月/季结算 + 三维惩罚公式

### Feature Layer（4 — 依赖 Core）

1. **Event Script Engine ⭐** — depends on: NPC Relationship, Save — 数据驱动的事件池 + 触发条件
2. **Action Card System** — depends on: AP Economy, NPC Relationship, Event Script — 30-40 张卡库 + 打出规则
3. **Run Meta System** — depends on: KPI, Save — "活过第 X 集"分数 + demo end
4. **Tutorial / Onboarding System** — depends on: AP Economy, Action Card, Event Script, Scene & Day Flow（[VS tier]）

### Presentation Layer（6 — 依赖 Feature/Core）

1. **HUD System (Diegetic)** — depends on: AP Economy, NPC Relationship, Scene & Day Flow, Lighting, Localization
2. **Card Play & Dialogue UI** — depends on: Action Card, Event Script, Localization
3. **Daily / Weekly Recap UI** — depends on: AP Economy, KPI, Event Script, Localization
4. **KPI Review & Game Over UI** — depends on: KPI, Run Meta, Localization
5. **Main Menu / Pause / Settings UI** — depends on: Save, Localization, Input
6. **Notification & Warning System (enhanced)** — depends on: Scene & Day Flow（[VS tier]）

### Polish Layer（1 — 跨切关注）

1. **Accessibility Options** — depends on: 所有 Presentation Layer systems（[Alpha tier]）

---

## Recommended Design Order

按 **依赖层 × 优先级 × 风险**综合排序。每个 GDD 完成并 review 后才开始下一个；同层独立系统可并行。

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Save System | MVP | Foundation | godot-specialist + systems-designer | S |
| 2 | Input Handler | MVP | Foundation | godot-specialist | S |
| 3 | Localization Hooks | MVP | Foundation | localization-lead | S |
| 4 | Audio Manager | MVP | Foundation | audio-director + sound-designer | S |
| 5 | Lighting & Visual State Controller | MVP | Foundation | godot-shader-specialist + technical-artist | S |
| 6 | **Scene & Day Flow Controller ⭐** | MVP | Core | game-designer + godot-gdscript-specialist | M |
| 7 | **AP Economy System** | MVP | Core | game-designer + systems-designer | M |
| 8 | NPC Relationship System | MVP | Core | game-designer + narrative-director | M |
| 9 | **KPI & Reverse Threshold System ⭐** | MVP | Core | systems-designer（数学主笔）+ game-designer | **L** |
| 10 | **Event Script Engine ⭐** | MVP | Feature | systems-designer（数据架构主笔）+ narrative-director | **L** |
| 11 | Action Card System | MVP | Feature | game-designer + systems-designer | M |
| 12 | Run Meta System (MVP simple) | MVP | Feature | game-designer | S |
| 13 | HUD System (Diegetic) | MVP | Presentation | ux-designer + art-director | M |
| 14 | Card Play & Dialogue UI | MVP | Presentation | ux-designer + writer | M |
| 15 | Daily / Weekly Recap UI | MVP | Presentation | ux-designer + writer | M |
| 16 | KPI Review & Game Over UI | MVP | Presentation | ux-designer + narrative-director | M |
| 17 | Main Menu / Pause / Settings UI (basic) | MVP | Presentation | ux-designer | S |
| 18 | Tutorial / Onboarding System | VS | Feature | game-designer + ux-designer | M |
| 19 | Notification & Warning System (enhanced) | VS | Presentation | ux-designer | M |
| 20 | Accessibility Options | Alpha | Polish | accessibility-specialist + ux-designer | M |

**Effort 说明**：
- **S** = 1 session（~1 次聚焦设计会话，多为基础设施）
- **M** = 2-3 sessions（中等复杂度玩法 / UI）
- **L** = 4+ sessions（重数学 / 重数据架构 / 重内容）

**MVP 总 effort 估算**：7×S + 8×M + 2×L ≈ 7 + 20 + 10 = **37 sessions**。单人 3 个月约 12 周，每周 3-4 GDD session 强度可行；若效率低，按 Scope Tier 可裁剪。

---

## Circular Dependencies

**None found.** ✅

乍看存在张力：Action Card ↔ Event Script —— "卡触发事件、事件改 NPC、NPC 又被卡作用"。但这是**单向数据流而非结构依赖**：
- Action Card 调 Event Script（知道后者的接口）
- Event Script 不需要知道 Action Card（它还可以被时间流逝、关系阈值等触发）
- 因此只是 Action Card → Event Script 的单向依赖。

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| **Event Script Engine** | Scope | 80-120 事件剧本对单人产量是巨大工作量；数据架构错了全部重做 | 30-40 关键事件手写，其余**模板化 + 变量注入**；架构先做原型验证 |
| **KPI & Reverse Threshold System** | Design | 三维度涨阈值公式错 → 黑色幽默主题崩坏（变"励志"或"绝望"）；新手第一次被涨 KPI 可能感觉被坑 | **playtest 重点观察**第一次月末玩家情绪反应（笑 vs 骂 = 生死问题）；前 2-3 天 Event Script 脚本式隐形引导 |
| **AP Economy System** | Design | 8 AP 分配可能沦为机械重复而非真决策 | /prototype 阶段重点验证决策感 |
| **HUD System (Diegetic)** | Design | ux 要求完整 diegetic + gamepad 焦点链；diegetic UI 实现复杂度高于 screen-space | Switch 移植时可退为 screen-space 摘要面板（已在 art bible §7.5 定好退路） |
| **Event Script Engine** | Technical | 事件 + NPC 关系 + 环境累积 state 交互矩阵复杂 | 系统 GDD 阶段**先定 schema**，所有事件 / 卡片 / 关系变化都必须符合该 schema |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 20 |
| Design docs started | 5 |
| Design docs reviewed | 2 (Save: 3rd lean → **APPROVED** / Input: 2nd lean → **APPROVED**) |
| Design docs approved | 2 (Save + Input Handler) |
| MVP systems designed | **15 / 17** (Foundation 5/5 + Core 4/4 + Feature 3/4 + Presentation 3/6: #13 HUD + #15 Recap + #16 KPI Review Designed + #17 Main Menu Designed) — 剩 Presentation 2 屏(#14 Card Play UI + 待确认) + #11 Action Card |
| Vertical Slice systems designed | **2 / 2** (#18 Tutorial + #19 Notification Warning Designed — VS 全部完成!) |
| Alpha systems designed | **1 / 1** (#20 Accessibility Options Designed — Alpha 全部完成!)

---

## Next Steps

- [ ] 依次运行 `/design-system [system-name]` 按 **Recommended Design Order** 排序
- [ ] 推荐先做 `/design-system save-system`（Order #1，基础设施的基础）
- [ ] 每个 GDD 完成后运行 `/design-review design/gdd/[system].md`（新 session 中）
- [ ] 所有 MVP GDD 写完后运行 `/review-all-gdds`（跨 GDD 一致性检查）
- [ ] 跑 `/gate-check pre-production` 验证进入原型阶段
- [ ] 最高风险系统（Event Script Engine）完成 GDD 后**优先 /prototype**，不等 MVP 全部设计完

---

## Notes & Decisions Log

- **2026-04-22**: 系统索引创建，20 个系统识别（17 MVP + 2 VS + 1 Alpha）
- **2026-04-22**: Scope risk 确认 —— 17 MVP 系统单人 3 月偏重，采用"每个系统尽量短设计"策略
- **2026-04-22**: 依赖循环审计通过（Action Card ↔ Event Script 为单向）
- **2026-04-22**: KPI/Event Script/AP Economy 标记为高风险，需要原型验证
- **2026-04-22**: 3 个开放问题由并行 agent 研究（结果落 `design/research/`）—— AP 决策空间分析 / KPI 反向阈值候选公式 / Event Script 候选 schema
- **2026-04-22**: Save System GDD 完成（Order #1）—— 19 Core Rules / 6-state 状态机 / 39 edge cases / 36 AC / 7 open questions；注册 3 个 constants 至 entities.yaml（autosave_perf_hard_ceiling_ms=50, archive_hard_cap_count=200, current_schema_version=1）
- **2026-04-23**: Save System `/design-review` 验证结果 `NEEDS REVISION`（8 blocking themes）；同日完成 revision — 补 4 条 Core Rules（20/21/22/23 Steam Cloud 排除 / 离职证明 timing / 跨局解锁 content-only / archive 200 cap block）；补 7 条 AC-FUNC（08-14）；JSON.stringify 移至 WorkerThreadPool + snapshot_id 单调序列；修 `@export const` 无效语法 + `NOTIFICATION_APPLICATION_PAUSED` 桌面 no-op 路径；OQ-01 + OQ-06 决议并标 RESOLVED；注册 `final_transition_duration_ms=1500` 至 entities.yaml。待再跑 `/design-review --depth lean`
- **2026-04-23** (2nd lean review): Save System 第 2 轮 `/design-review --depth lean` 结果 `NEEDS REVISION (minor)` — 8 首轮 blocker themes **全部系统性闭环**;发现 1 新 blocker(`settings.cfg` vs `meta.save` 设置归属矛盾,3 处 edit 即可闭环)+ 5 recommended + 3 nice-to-have。用户选**下个 session 修 blocker**;本 session 不解锁 Foundation #2-5。详见 `design/gdd/reviews/save-system-review-log.md`
- **2026-04-23** (Revision minor + 3rd lean review): 用户选 **Option A 扩展版(5 处 edit)** 清理 `settings.cfg` 矛盾 — Rule 20 filter + Engine Constraints + 外部依赖 + AC-COMPAT-04/05 统一声明"设置存于 meta.save 内,无独立 settings.cfg 文件";OQ-06 RESOLVED 历史快照保留原文(标记 nice-to-have)。同 session 跑第 3 轮 `/design-review --depth lean` 结果 **APPROVED**(0 blocker / 5 recommended 延后 ADR-0001 / 4 nice-to-have 延后)。**解锁 Foundation #2-5 (Input Handler / Localization Hooks / Audio Manager / Lighting Controller) 并行 design**。Scope signal: L。
- **2026-04-24**: Input Handler GDD 完成(Order #2, Foundation S size, lean mode)— 10 Core Rules / 3-state 状态机 + 11 事件映射 / 5 Interaction 契约 / 3 Formulas(deadzone 3-zone + D-Pad repeat + path arbitration)/ 30+ edge cases 9 分类 / 25 AC 5 类(23 MVP / 2 Beta,4 [RISK GUARD])/ 7 OQ-INP。spawn 历: creative-director(B framing)/ systems-designer × 3(C/D/E)/ gameplay-programmer(C feasibility)/ engine-programmer(C engine spec)/ qa-lead(H AC)。注册 1 新 constant `meta_settings_debounce_ms = 500 ms`(Save 源,Input 引用)+ 更新 `final_transition_duration_ms` referenced_by 添 input-handler.md。**📌 UX Flag**: Phase 4 须 `/ux-design design/ux/remap-screen.md` 配 #17 Main Menu UI 一并产出。**📌 同轮发现 + 修**: Section C Rule 1 缺 `act_focus_left/right`(diegetic 2D 导航必需),已同 session edit 补齐 12 actions。
- **2026-04-24** (1st lean review + same-session revision): Input Handler `/design-review --depth lean` 首轮结果 **NEEDS REVISION**(3 blocker / 5 recommended / 2 nice-to-have,scope signal M,修正为 systems-index S→M)。同 session 完成 revision — 3 blocker 全修(F3 enum `KB_PAD`→`KB_GAMEPAD` 全局统一 / Rule 6 skip 比较目标改为 F1 post-deadzone `joystick_effective_axis` / `remap_cancelled` 统一为 2-arg `(action_name, reason)` + 3 reason enum 定义);4 recommended 修(AC count 20→23 / Rule 10 "活跃"→"已连接" / Rule 7 加 call-site 零 gap 约束指向 Edge 8.2 / F3 第三 case 重写 lockout 过期不自动切);1 recommended 推迟(Save Rule 14 textual loop "keymap" 命名延至下次 Save 触碰,entities.yaml 已锁 contract);2 nice-to-have 修(Edge 1 deadzone_outer=1.0 措辞 / Section C 章节名 "Detailed Design" → "Detailed Rules" 合规)。Status 转 **In Review**,**下个 fresh session 跑 `/design-review design/gdd/input-handler.md --depth lean` 再审**。详见 `design/gdd/reviews/input-handler-review-log.md`。
- **2026-04-24** (2nd lean review, fresh session): Input Handler `/design-review --depth lean` 第 2 轮结果 **APPROVED**(0 blocker / 5 recommended / 2 nice-to-have,scope signal M 与首轮一致)。首轮 3 blocker 全部系统性闭环(enum 统一 / Rule 6 post-deadzone / `remap_cancelled` 2-arg);新扫描发现的 5 Recommended 皆为信号 firing rule 局部澄清类(`input_method_changed` trigger 规则缺失 / FocusPath vs InputMethod enum 语义重叠 / `focused_node_changed` emission rule 缺失 / Edge 9.1 Input↔Save notification 时序未定契约 / Save Rule 14 textual "keymap" 命名延续首轮推迟),2 Nice-to-have(AC-COMPAT-05 visual sign-off 拆分建议 / Rule 4 F2 "passive hold-repeat" 豁免澄清)。**Input Handler Status 转 Approved,解锁 Foundation #3-5 (Localization Hooks / Audio Manager / Lighting & Visual State Controller) 并行 design**。5 Recommended 不阻塞下游,可在 ADR-XXXX dual-focus 阶段 / 后续 Save 触碰 / Scene & Day Flow #6 GDD 协调时顺手清。详见 `design/gdd/reviews/input-handler-review-log.md`。
- **2026-04-24~25** (Localization Hooks /design-system 完成,Order #3,Foundation S→M size,lean mode)—— 13 sections 609 行:11 Core Rules(key naming + `_IRONY` 后缀 / `tr()` 纪律 / 程序化 + RichTextLabel `register_rich_text_refresh` API / 缺 key 双轨 / locale switch 协议 dispatch ≤1帧 + reflow ≤500ms + 演出排队 + watchdog 30s / CSV 5 列 schema / 复数 explicit variants / 启动全量加载 <100ms / 字体 fallback 链 + diegetic Compact variant 合约 / key 稳定性 + deprecated 流程 / tone 守护三层执法 lint+context+writer review)+ 无状态机 + 6 Interactions + 2 Formulas(F1 reflow latency 线性分解 + F2 coverage ratio)+ 43 Edge Cases(10 分类 / 5 [RISK GUARD] R-LOC-1..5 对齐 Input R1/R2/R3 结构)+ 9 Dependents + 28 AC(5 分类 含新增 AC-TONE Pillar 4 守护类)+ 12 OQ-LOC。Spawn 历: creative-director(B framing 3 候选 B+C)/ localization-lead(C 主)/ godot-specialist(C 4.6 footgun)/ ui-programmer(C 可行性 + F1 实测基线)/ systems-designer × 3(D 公式 F1/F2 + E edges + G 部分)/ qa-lead(H AC)。注册 1 新 constant `locale_lock_watchdog_ms = 30000 ms`(Localization source → Scene Flow #6 consumer)+ `meta_settings_debounce_ms` referenced_by 添 localization-hooks.md。**📌 UX Flag**: Phase 4 须 `/ux-design design/ux/settings-screen.md` 配 #17 Main Menu UI 一并产出。**📌 同 session 修 1 art-bible 冲突**: SD 原 `AUTO_FIT_FLOOR_PX = 10` 违反 art-bible §7.2 "禁用 10 px 因 CJK 笔画粘连",Phase 5b scan 捕获后改为 11 px(4 处同步)。**下个 fresh session 跑 `/design-review design/gdd/localization-hooks.md --depth lean` 审稿**。
- **2026-04-25** (Lighting & Visual State Controller /design-system 完成,Order #5,Foundation S→M size,lean mode,**autonomy v2 no-prompt 模式实战**)—— 13 sections / 12 Core Rules(CanvasModulate 8 sub-mode 色值表 + LOADING/READY 状态机 + palette swap shader + dither overlay shader + 累积 state 4 维度 schema + Pillar 1+4 反讽红线 + 环境叙事 §6.4 4 元素 + audio-visual 对偶 + 信号架构 + 性能契约 + Godot 4.6 集成 Tonemapper Filmic 锁 + 异常几何 §3.2 留扩展点)+ Section D = N/A(同 Save/Audio 同质)+ 32 Edge Cases(10 categories / 5 [RISK GUARD] R-LVS-1..5)+ 9 Dependents + 27 AC(5 categories 沿用 AC-TONE)+ 8 OQ-LVS。Spawn 历:CD(B 3 framings)+ art-director(C 11 Rules)+ technical-artist(C 9 性能契约)+ godot-shader-specialist(C 8 shader 规约 + 3 ADR-locked OQ)+ systems-designer × 2(C 状态机 + E 32 edges)+ qa-lead(H 27 AC,**flag 1 minor wording autopilot 自修**)。**注册 2 新 constants**: `lighting_loading_watchdog_ms = 10000`(同 audio 同模式同值)+ `notice_board_max_entries = 24`(art-bible §6.5 + R-LVS-5 守门,跨 art-bible 引用)。**新 autonomy v2 no-prompt 实战**:全程 widget 仅 1 次(framing)— Audio 4 次的 25%,Localization 12 次的 8%。**下个 fresh session 跑 `/design-review design/gdd/lighting-visual-state.md --depth lean` 审稿**。**Foundation Layer 5/5 全部 Designed 收官**,Core Layer #6 Scene & Day Flow Controller(M size, Bottleneck ⭐)解锁(待 3 pending Foundation reviews 转 Approved)。
- **2026-04-26** (AP Economy System /design-system 完成,Order #7,Core Layer M size,**Gameplay 高风险**,lean mode,**autonomy v2 no-prompt 0 widget 续 #6 模式**)—— 11 sections 1244 行: 15 Core Rules(包含 Pillar 1 反向 KPI 核心 + Anti-Pillar 1 红线 BLOCKING)+ 4 态状态机(`AP_NORMAL` / `AP_OVERTIME_AVAILABLE` / `AP_OVERTIME_ACTIVE` / `AP_DEPLETED`)+ 7 Interactions + **5 公式 F1-F5**(F1 加班 + F2 早退 + F3 capacity + F4 effort + F5 decision_space)+ 32 Edge Cases / 10 categories / 5 [RISK GUARD] R-AP-1..5 + 13 Dependents + 25 AC(5 categories,Research H1-H5 假设整合,5 [RISK GUARD] 全对应 AC-ROBUST-01..05)+ 10 OQ-AP + 5 cross-GDD propagation flags。Spawn 历:creative-director(B framings 2 candidates 主+副)+ game-designer(C 15 Core Rules 主笔)+ systems-designer × 2(C SC-1..7 状态机 + 曲线 / E 32 edges)+ economy-designer(C 经济平衡 6 节 + Hero 等价加班漏洞 deviation 推导)+ qa-lead(H 25 AC + W-CONS-1 自检无命中)。**KPI research deviation 自决修订**: effort 三维权重 0.40/0.35/0.25 → **0.45/0.20/0.30**(防 Hero 等价加班漏洞,待 #9 GDD 仲裁)。**注册 0 新 constants**(本 GDD 与 12 registry constants 无引用关系;新 constant 候选标记 `pending_consumer_gdd` 等待 #9/#10/#11/#13 撰写时再注册)。**📌 5 propagation flags**:#9 effort 权重 + #9 CAPACITY_FLOOR + #11 AP cost 分布 + #10 PREDICTION blacklist + #13 主语翻转 lint。**autonomy v2 实战 0 widget**(继承 #6 模式),全部 routine autopilot,1 KPI research deviation 自主决策(economy-designer 推荐采纳),1 文件结构错位(Open Questions 重复)同 session autopilot 修。**Research H1-H5 假设整合**: H1 决策熵(AC-FUNC-08 Beta)/ H2 后悔感 + H5 玩家聚类(AC-FUNC-09 Beta)/ H3 非占优 C1 存亡级(AC-FUNC-10 VS)/ H4 地铁 90s(AC-PERF-01 MVP)。**下个 fresh session 跑 `/design-review design/gdd/ap-economy-system.md --depth lean` 审稿**。Core Layer 进度 2/4(#6 + #7 Designed),#8 NPC + #9 KPI + #10 Event Script 解锁待 #6/#7 Approved。

- **2026-04-26** (Scene & Day Flow Controller /design-system 完成,Order #6,Core Layer M size Bottleneck ⭐,lean mode,**autonomy v2 no-prompt 模式 0 widget 实战**)—— 11 sections 1079 行: 14 Core Rules + 10 Engine Integration Rules (C-ENG-01..10) + 8x8 转移矩阵 + 7 Interactions + Section D N/A(同 Save/Audio/Lighting 同质)+ 32 Edge Cases / 10 categories / 5 [RISK GUARD] R-SDF-1..5 + 9 Dependents + 27 AC(5 categories,5 [RISK GUARD] 全对应 AC-ROBUST-01..05)+ 8 OQ-SDF + 3 OQ-SDF-ENG。Spawn 历: creative-director(B framings 3 候选 C1 主+C2 副 + C3 internal design test)+ systems-designer × 2(C 14 Rules + States + Interactions + E 32 edges)+ gameplay-programmer(C 7 Top Risks 整合为 R1-R7 mitigation 嵌 Rules)+ engine-programmer(C Engine Integration 10 条 Godot 4.6 API 锁)+ qa-lead(H 27 AC,W-CONS-1 检查无命中无错引)。**本 session 仲裁 6 项 cross-system BLOCKING**(/review-all-gdds 报告路径 A): 启动序列(Rule 4 + C-ENG-01/04/05)/ WM_FOCUS_OUT 三方语义(Rule 5 + C-ENG-03,翻译为 `soft_pause_requested` 信号)/ Pause game-time vs wall-clock(Rule 6 + C-ENG-02/07)/ Settings 防抖单 timer(Rule 7)/ 同帧主线程预算(Rule 3 + Rule 8 + R2/R5)/ 8 sub-mode enum 锁(Rule 2 + States 矩阵)。**注册 0 新 constants** + `referenced_by` 添 9 个跨 GDD constants(Save/Loc/Audio/Lighting source 全套)。**📌 UX Flag**: Phase 4 须为 main-menu / pause-screen / loading-screen / gameover-screen 4 屏跑 `/ux-design`(settings-screen 已由 Loc + Audio 引用)。**autonomy v2 实战**: 全程 widget 数 = **0**(Lighting v2 仅 1 widget, Audio v1 4 widgets, Loc v0 ~12 widgets);全部 routine autopilot,5 specialist 输出整合 + 推荐组合自动采纳 + 文件错位自修。**下个 fresh session 跑 `/design-review design/gdd/scene-day-flow-controller.md --depth lean` 审稿**。**Core Layer #6 Designed 解锁 #7 AP Economy + #8 NPC Relationship + #9 KPI & Reverse Threshold + #10 Event Script Engine 4 系统并行设计**(待 #6 Approved)。

- **2026-04-28** (Tutorial / Onboarding System /design-system 完成,Order #18,Meta Layer M size,VS tier,**autonomy v2 no-prompt 0 widget**)—— 11 sections 全填,0 placeholder: Section A(双重身份 隐形 onboarding state machine + 老员工指路叙事 + Pillar P2 主+P5+P4 守 + Anti-P2 红线 + 5 NOT 边界 + 5 NOT 红线 + Source 引用 6 GDD cross-system 契约锁)/ Section B(主锚"你不是来玩游戏的,你是入职的" + 副锚"老油条说'我第一年也是这么过来的'" + ❌/✅ tone 守门)/ Section C(10 Core Rules: 引导触发协议 + Day 1-3 固定手牌 + onboarding tier 额外事件 `HINT_ONBOARDING_DAY{1/2/3}` + M1 KPI 结算 NPC 点评 + 隐形三原则 + P5 AP 约束 + P4 tone 双测 + 信号架构 + Save content-only unlock + Scope Tier)+ 4 态状态机 + 6 Interactions / Section D(N/A)/ Section E(12 edges / 4 categories / 2 [RISK GUARD] R-TUT-1 popup 漏入 + R-TUT-2 励志台词漏入)/ Section F(5 Upstream + 零 Downstream + 📌 UX Flag)/ Section G(6 Tuning Knobs)/ Section H(14 AC: 8 AC-FUNC + 2 AC-RULE + 2 AC-PERF + 2 AC-TONE)/ 6 OQ-TUT。**Cross-system 契约全落地**: `#10 Rule 17` 4 档预言 + 新增 ONBOARDING 第 5 档 / `#7 Rule 1` Day 1-3 引导期 effort_norm / `#9 Rule 6` M1 γ_effective=0 + 涨幅 ≤3% / `#11 Rule 5` card_unlocked / `#6 Rule 4` 启动序列 / `#1 Rule 22` content-only unlock。**注册 0 新 constants**(M1_REVIEW_NPC_DELAY_MS + M1_REVIEW_SEQUENTIAL_GAP_MS 为 Tuning Knobs,待 entities.yaml 注册于实现阶段)。**📌 UX Flag**: `/ux-design design/ux/onboarding-day1-day3.md` Phase 4 产出。**Vertical Slice 进度 1/2**。**下个 fresh session 跑 `/design-review design/gdd/tutorial-onboarding-system.md --depth lean` 审稿**。

- **2026-04-29** (Daily / Weekly Recap UI /design-review lean batch-revise 完成,Order #15,verdict NEEDS REVISION → resolved 同 session,**autonomy v2 batch-revise 0 widget**)—— 3 BLOCKING + 6 RECOMMENDED + 4 NICE-TO-HAVE 全清:**B1 #6 信号契约扩展 ctx payload**(`scene_state_changed(from, to, ctx: Dictionary)`含 `is_weekly` / `is_weekend` / `is_last_day_of_month` / `current_day` / `current_weekday` 五字段 → propagation flag #6 同步 `#6` GDD)/ **B2 schema 误引修正**(`#9 Rule 10 breakdown` 三因子拆解 ≠ effort 三维度,Section A + Rule 3 + Section F 全重写;effort 三维度 source 锁 `#7 effort_*_incremented` + `#7 monthly_effort_summary`)/ **B3 P2 vs P5 tension 仲裁**(月末倒数 2 周 M3+ W3/W4 守门最小展示 1500ms,继承 `#6 GAMEOVER` 1500ms 同构 + 与 `#9 kpi_prediction_hint` 月末 D-2/D-1 emit 锚耦合;补 AC-ROBUST-04 守门 → propagation flag #7 同步 `#2 register_skippable` 拓展 `min_display_ms` 参数)。**OQ-RCP-01 / OQ-RCP-04 RESOLVED**。Section H AC count 20 → 23(实际)。Status: **Designed (revised, pending re-review)**。Review log: `design/gdd/reviews/daily-weekly-recap-ui-review-log.md`。**下个 fresh session 跑 `/design-review` 第二轮 lean re-review 验证 BLOCKING 真清**(等同 save-system 多轮 review 路径)。

- **2026-04-29** (KPI Review & Game Over UI /design-system 完成,Order #16,Presentation Layer M size,lean mode,**autonomy v2 no-prompt 0 widget**)—— 11 sections 全填,0 placeholder:Section A(双重身份 月末结算渲染层 + 离职证明过渡屏 + Archive 列表 UI + P3 主+P1 守+P4 主 + 5 NOT 边界 + 5 NOT 红线 + Source 引用 9 GDD cross-system 契约锁)/ Section B(主锚"恭喜晋升"反讽屏 + 副锚"工号 #0011 · 死于 M11"档案条 + ❌/✅ tone 守门 + 四轨 negative space 完整：数学+听觉+视觉+文字)/ Section C(14 Core Rules: KPI_REVIEW 触发协议 + breakdown 三行渲染 + M1 破折号新人豁免 + capacity 数字对比预警 + GAMEOVER 1500ms linear + CERTIFICATE.[reason] 文本嵌入 + Archive 列表逐条删除 + HR 词条收集 UI + skippable 守门 + P1/Anti-P2 红线守门 + 主语翻转 lint 域扩展 + 帧预算 ≤ 4ms + dispatch ≤ 1 帧 + Scope Tier)+ 3 态状态机(KPI_REVIEW_WAITING / KPI_REVIEW_ACTIVE / GAMEOVER_TRANSITION / ARCHIVE_VIEW)+ 7 Interactions / Section D(D1 三行数字格式化 + Worked Example M11 标准 profile + D2 Localization key 模板)/ Section E(18 edges / 6 categories / 3 [RISK GUARD] R-KGO-1 race UI 不一致 + R-KGO-2 CERTIFICATE key 缺失 + R-KGO-3 LEFT NPC 数据 leak)/ Section F(9 Upstream + 1 Downstream + 5 双向 cross-check + 4 propagation flags)/ Section G(5 Tuning Knobs + HR 词条分组表 30 条)/ Visual/Audio(4 轨 negative space 完整 + 📌 3 UX Flags)/ UI Requirements(KPI Review + GAMEOVER + Archive 三屏 own 节点树)/ 6 OQ-KGO / Section H(22 AC: 12 AC-FUNC + 4 AC-PERF + 3 AC-ROBUST + 2 AC-COMPAT + 1 AC-TONE)。**Cross-system 契约全落地**: `#9 Rule 10` breakdown 三行渲染 + `#9 Rule 17` 三轨 + `#12 Rule 2` RunSummary + `#1 Rule 21` 1500ms linear easing=NONE + `#10 Rule 17` GAMEOVER.CERTIFICATE.[reason] + `#3 Loc Rule 4` tr() + `#2 Rule 6` skip 最后 1 帧 + `#5 Rule 1` KPI_REVIEW 紫+GAMEOVER 灰 + `#4 Rule 7` 月末 BGM+stinger。**注册 0 新 constants**（全部引用已注册常量；`archive_soft_warning_threshold=180` 与 Save OQ-01 resolved 约定一致，不单独注册）。**📌 3 UX Flags**: `design/ux/kpi-review-screen.md` + `design/ux/gameover-screen.md` + `design/ux/archive-list-screen.md` Phase 4 产出。**下个 fresh session 跑 `/design-review design/gdd/kpi-review-game-over-ui.md --depth lean` 审稿**。Progress Tracker: **15/17 MVP Designed**。

- **2026-04-28** (Daily / Weekly Recap UI /design-system 完成,Order #15,Presentation Layer M size,lean mode,**autonomy v2 no-prompt 0 widget**)—— 11 sections 全填: Section A(双重身份 + P2 主+P5+P4 守 + 5 NOT 边界 + 5 NOT 红线 + Source 引用 6 GDD cross-system 契约锁)/ Section B(主锚"周五下午 5 点的周报"47 张卡/3 Hero/2 次 Lisa 对话 + 副锚"今天打了 8 张卡第 3 张给王总" + ❌/✅ tone 守门)/ Section C(12 Core Rules: Daily Recap 触发协议 + Weekly Recap 升级协议 + effort 3 维度 HR 口吻 + 事件 numeric_only 列表 + 数字克制 + lint 域扩展 + skippable 协议 + 帧预算 + dispatch 时序 + Save 无持久化 + 主语翻转 + Scope Tier)+ 3 态状态机 + 8 Interactions / Section D(D1 事件密度截断公式 + Worked Example)/ Section E(15 edges / 5 categories / 2 [RISK GUARD] R-RCP-1 进度条禁 + R-RCP-2 skip token leak 跨 R-SDF-5)/ Section F(7 Upstream + 1 Downstream + 5 propagation flags)/ Section G(3 Tuning Knobs + HR 口吻词条池 5 触发规则)/ Visual/Audio(数据屏蓝光 context + 📌 2 UX Flags)/ UI Requirements(日报 + 周报双屏 own)/ 5 OQ-RCP / Section H(20 AC: 12 AC-FUNC + 3 AC-PERF + 3 AC-ROBUST + 1 AC-COMPAT + 1 AC-TONE)。**Cross-system 契约全落地**: `#6 Rule 12` skippable + `#7 Rule 14` effort 信号 + `#9 Rule 10` breakdown + `#10 Rule 19` numeric_only + `#3 Loc Rule 4` + `#5 Rule 1` 蓝光 context。**注册 0 新 constants**(全部引用已注册常量)。**📌 2 UX Flag**: `/ux-design design/ux/daily-recap-screen.md` + `/ux-design design/ux/weekly-recap-screen.md` Phase 4 产出。**下个 fresh session 跑 `/design-review design/gdd/daily-weekly-recap-ui.md --depth lean` 审稿**。Progress Tracker: **12/17 MVP Designed**。

- **2026-04-27** (Run Meta System /design-system 完成,Order #12,Feature Layer S size,lean mode,**autonomy v2 no-prompt 0 widget**)—— 11 sections 全填,0 placeholder:Section A(双重身份 + P3 主 + P1/P4 守 + Anti-Pillar 1+2 红线 + 5 NOT 边界 + 5 NOT 红线 + Source 引用)/ Section B(主锚 1 "我活过了第 11 集" P3 自豪感 + 主锚 2 "中规中矩的牺牲品" P1/P4 守 + 跨 GDD 共振 + ❌/✅ tone 各 4 行)/ Section C(12 Core Rules: Run Meta schema + RunSummary schema + GAME OVER 接收协议 + content-only unlock 白名单校验 + HR 评语三轴选词 + demo end 协议 + FIFO 驱逐 + run_meta_unlock 注入 + Pillar 1 红线扫描 + 信号架构 + Save 持久化 + Scope Tier)+ States 3 态(`RUN_ACTIVE / RUN_ENDED / META_VIEW`)+ 6 Interactions / Section D(F1 三轴交叉选词 + F2 FIFO 驱逐)/ Section E(15 edges / 5 categories / 3 [RISK GUARD] R-RM-1 stat buff + R-RM-2 archive cap 越界 + R-RM-3 词条 tone 违规)/ Section F(3 Upstream + 4 Downstream + 4 双向一致性 cross-check)/ Section G(3 Tuning Knobs + HR 评语 30 词条分布表)/ Visual/Audio(零 ownership)/ UI(接口合约 → #16)/ 7 OQ-RM / Section H(15 AC 框架：9 AC-FUNC + 3 AC-RULE + 2 AC-PERF + qa-lead 补充标注)。**Cross-system 契约 3 条全落地**: Save Rule 22 content-only + Rule 23 200 cap / `#9 game_over_triggered(reason, month)` / `#10 run_meta_unlock(content_id)`。**注册 0 新 constants**(DEMO_END_MONTH + archive_hard_cap_count 均已在 Save Rule 23 + entities.yaml 存在,无新注册需要)。**下个 fresh session 跑 `/design-review design/gdd/run-meta-system.md --depth lean` 审稿**。Progress Tracker: **11/17 MVP Designed**。

- **2026-04-28** (Accessibility Options /design-system 完成,Order #20,Polish Layer M size,Alpha tier,lean mode,**autonomy v2 no-prompt 0 widget**)—— 11 sections 全填,0 placeholder: Section A(双重身份 技术层设置注入器 + 叙事层 P5 人群包容性扩展 + P5 主+P4 守+Anti-P1 红线守门 + 5 NOT 边界 + 5 NOT 红线 + Source 引用 6 GDD cross-system 契约锁)/ Section B(主锚"字体大一点也是这游戏" P5 tone 守门 + 副锚"色盲模式不让你赢得更轻松,只让你看得清" Anti-P1 + ❌/✅ tone 守门)/ Section C(10 Core Rules: 字体 4 档 fallback 链 + 色盲 3 档 palette swap + 高对比度描边 + 输入辅助长按/hit extend/误触保护 + TTS scope 占位 + 静音双重编码 R-LVS-4/R-AUD-5 跨守 + NPC fallback 文字标签 + Anti-P1 PR-blocking lint + tone 守门 + Settings UI 注入 #17 + Scope Tier 三档)+ 无状态机(纯设置 schema)+ 7 Interactions / Section D(N/A,纯注入层无公式)/ Section E(12 edges / 4 categories / 2 [RISK GUARD] R-A11Y-1 Anti-P1 数值漏入 + R-A11Y-2 色盲 NPC fallback 缺失)/ Section F(8 Upstream + 零 Downstream + 5 双向一致性 cross-check + 4 propagation flags)/ Section G(6 feel knobs + 2 curve knobs + 3 gate knobs + 色盲 LUT 表)/ Visual/Audio(零 ownership + 📌 2 UX Flags)/ UI Requirements(注入 #17 Settings 子屏,非 own 屏)/ 4 OQ-A11Y / Section H(14 AC: 11 AC-FUNC + 3 AC-PERF + 3 AC-ROBUST + 2 AC-TONE)。**Cross-system 契约全落地**: `#3 Rule 9` `AUTO_FIT_FLOOR_PX=11` + `#5 Rule 11` mute_visual_parity + `#13 HUD` NPC fallback + `#17 Settings` 子屏注入 + `#2 Input Rule 4` anti-QTE + Save Rule 14 `meta_settings_debounce_ms=500`。**注册 0 新 constants**(所有 Tuning Knobs 存于 `assets/data/accessibility/a11y_config.tres`，未跨 GDD 共享,无需 entities.yaml 注册)。**Anti-P1 lint + Pillar 4 tone 守门从 MVP 即上线**（防护性守门，不依赖功能实装）。**📌 2 UX Flags**: `design/ux/accessibility-screen.md` + `design/ux/colorblind-hud-fallback.md` Phase 4 Alpha 产出。**Alpha 系统 1/1 全部 Designed — 全部 20 个系统识别完毕,设计完成 19/20**（剩 #16 KPI Review & Game Over UI Not Started）。**下个 fresh session 跑 `/design-review design/gdd/accessibility-options.md --depth lean` 审稿**。

- **2026-04-25** (Audio Manager /design-system 完成,Order #4,Foundation S size,lean mode,**新 autonomy 协议实战**)—— 13 sections 628 行:11 Core Rules(4 Bus 架构 Master 锁 + 信号边界 / Audio event `BUS.DOMAIN.IDENTIFIER[_BUREAUCRATIC]` 命名 / Pillar 4 红线 8 SFX + 4 BGM 切换禁止类型 / preload <200ms LOADING 守门 / 6 场景 ambient layer schema 配 art-bible §2 时钟光语 / BGM 仅月末 + GO 白名单 / dispatch ≤1 帧 + SFX 池 8 LRU + CRITICAL 豁免 / 静音功能完整性 + 信号物理音频解耦 / tone 三层执法 lint+brief+audio-director review / 零音频契约 Input + Loc 双解耦)+ 主状态机 LOADING/READY 2 态 + Music sub-mode enum(IDLE/KPIREVIEW/GAMEOVER)+ 6 Interactions + Section D = N/A(音频数学嵌 Rules,无独立 formula)+ 35 Edge Cases(10 分类 / 5 [RISK GUARD] R-AUD-1..5: 锚点 key 缺失 / MUSIC 蔓延 / LOADING watchdog 10s / SFX 池 CRITICAL 驱逐豁免 / 静音双重编码)+ 9 Dependents + 26 AC(5 分类 沿用 Localization AC-TONE)+ 6 OQ-AUD。Spawn 历: creative-director(B 3 framings A "日光灯嗡的不是 BGM" + B "月末打卡机不是胜利音" 选)/ audio-director(C 11 Rules)/ sound-designer(G 29 资产清单 SFX/Ambient/Music)/ systems-designer × 2(C signals + E 35 edges)/ qa-lead(H 26 AC,**flag 1 真冲突 act_pause vs WM_FOCUS_OUT 不对称 fade,统一 act_pause 公版**)。**注册 4 新 constants**: `audio_preload_budget_ms = 200` / `audio_loading_watchdog_ms = 10000`(对比 Loc 30000)/ `audio_bank_total_size_mb = 30`(art-bible §8.5 跨引)/ `bgm_loop_length_max_sec = 120`;`meta_settings_debounce_ms` 添 audio-manager.md(第 4 消费者,4 GDD: Save+Input+Loc+Audio)。**📌 UX Flag**: 音量设置子屏与 Localization 共用 `design/ux/settings-screen.md`。**新 autonomy 协议实战**:全程 widget 仅 framing × 1 + Section B candidates × 1 + qa-lead 真冲突 × 1 + 下一步 × 1 共 4 次 widget(Localization 全程 ~12 次),其余 routine 全 batch autopilot。**下个 fresh session 跑 `/design-review design/gdd/audio-manager.md --depth lean` 审稿**。
