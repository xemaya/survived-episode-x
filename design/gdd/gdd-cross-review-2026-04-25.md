# Cross-GDD Review Report — Foundation Layer 5/5

**Date**: 2026-04-25
**Reviewed By**: `/review-all-gdds` (full mode, 3 parallel subagents)
**GDDs Reviewed**: 5 (Foundation Layer 全套)
**Systems Covered**: Save System / Input Handler / Localization Hooks / Audio Manager / Lighting & Visual State Controller

---

## 概述

5 个 Foundation Layer GDD 同步评审 — 4 项 consistency + 6 项 design theory + 4 个 cross-system scenario walkthrough。`design/registry/entities.yaml` 12 constants 作为 baseline 预读。

**Pillar/Anti-Pillar 来源**: `design/gdd/game-concept.md` L162-199(无独立 `game-pillars.md`)。
**Pillars**: P1 平庸是一种艺术 / P2 叙事即机制 / P3 死亡是注定的 / P4 苦中作乐 / P5 地铁可玩性。
**Anti-Pillars**: NOT 升职打怪 / NOT 励志叙事 / NOT 反应/动作类 / NOT 多人 / NOT 付费解锁。

---

## 总评: **CONCERNS**

| Phase | Verdict | Blocking | Warning | Info |
|-------|---------|----------|---------|------|
| 2 — Consistency | CONCERNS | 1 | 4 | 5 |
| 3 — Design Theory | PASS | 0 | 1 | 2 |
| 4 — Scenario Walkthrough | CONCERNS | 4 | 7 | 4 |
| **合计** | **CONCERNS** | **5** | **12** | **11** |

**核心结论**: 5 GDD 之间**不存在硬冲突**(没有"GDD-A 写 X 而 GDD-B 写 ¬X"类型的内部矛盾)。所有 BLOCKING 项的根本症结是**两类悬空契约**:
1. **Scene & Day Flow Controller (#6) 未设计**,但 5 GDD 全部把启动序列调度、`scene_state_changed` 总线编排、watchdog 编排、accumulation_event game-time 触发节奏责任甩给 #6
2. **三轨 negative space 节奏锚未跨 GDD 共用**(Audio 1.5s + Lighting 0.3s + Loc dispatch ≤1帧 在 KPI Review 演出收尾不同步)

**Pillar 4 黑色幽默守护跨 GDD 铁三角是项目目前最严密的工程**:`_IRONY` / `_BUREAUCRATIC` 双后缀命名约定 + 3 工具 CI 联合 lint(audio_lint / lighting_lint / i18n_lint) + AC-TONE 类别从 Localization 引入并被 Audio + Lighting 完整继承。**Phase 3 PASS,设计基建已 ship**,后续 gameplay GDD(#7-#16)可放心叠 mechanic。

---

## Phase 2 — Consistency Issues

### BLOCKING

🔴 **B-CONS-1**: `WM_WINDOW_FOCUS_OUT` 三系统语义不一致
- `save-system.md` L86 (Rule 19): 视为"轻量 debounced 异步 autosave",**与 `WM_CLOSE_REQUEST` 显式分离**
- `audio-manager.md` L297 (Edge 7) + L549 (AC-FUNC-11): 视为 `act_pause` 等价 — Music→-∞ 200ms / Ambient→-24dB 300ms fade
- `lighting-visual-state.md` L176 (Rule 9): 视为暂停语义 — `pause_tween()` 即时停
- `input-handler.md` L285 (Edge 9.1): `Input.reset_all_action_presses()` + reset held-direction timers
- **冲突**: 玩家短暂 Alt-Tab(<1 秒)检查微信时,Save 写一次防抖、Audio 把 BGM 完全 fade 至 -∞、Lighting 暂停所有 Tween — 玩家切回时 BGM 恢复 200ms + Tween 续行,**可感知 UX feel**
- **修复路径**(三选一,需 authoritative 决策):
  - (a) Audio/Lighting 仅响应 `act_pause`,`WM_FOCUS_OUT` 走更轻策略(如不淡出 Music 只静音 -24dB)
  - (b) Save GDD 添加"FOCUS_OUT 触发暂停语义,Audio/Lighting 同步"标注
  - (c) Scene & Day Flow #6 GDD 接管协调,把 FOCUS_OUT 翻译成内部"软暂停"信号

### WARNING

⚠️ **W-CONS-1**: 4 个下游 GDD 错引 "Save Rule 20"
- 错引位置: `localization-hooks.md` L121 + L353-354 / `audio-manager.md` Rule 2 L67 / `lighting-visual-state.md` Section F L231 + Rule 5 implicit
- Save Rule 20 实际是 Steam Cloud 同步策略,**非"禁直调 FileAccess"**
- 修复: 4 个下游 GDD 改为引用 Save "Engine Constraints" 段或新增 Save Rule 24 显式声明"下游禁直调 FileAccess"

⚠️ **W-CONS-2**: Audio Rule 6 sub-mode 表无英文 enum 锁定
- `audio-manager.md` L107-117 用中文表头("白天行动(day)" 等)
- `lighting-visual-state.md` L66-75 用 UPPER_SNAKE enum (`ACTION_DAY` 等)
- 1:1 映射依赖 #6 GDD 锁定 enum 字面值;若 Scene Flow #6 撰写时拼写歧义(`OFFICE_DAY` vs `ACTION_DAY`),三系统并发响应同一 `scene_state_changed` 时可能 silently miss
- 修复: Audio Rule 6 表追加英文 enum 列与 Lighting 完全对齐

⚠️ **W-CONS-3**: Scene Flow `scene_state_changed` 同帧主线程预算未跨 GDD 分摊
- 全 5 GDD 都声明 dispatch ≤1帧(16.6ms),但同帧多系统并发响应同一信号(Audio + Lighting + 各 UI 订阅)主线程预算合计未显式分摊
- Audio: ≤1帧 + AudioServer 异步
- Lighting: CanvasModulate Tween 0.2ms + dither 0.3ms + sprite swap 0.4ms ≈ <1ms
- 各 UI: 自定 budget
- 修复: Scene & Day Flow #6 GDD 撰写时锁定 budget 总和不破 16.6ms

⚠️ **W-CONS-4**: `notice_board_max_entries` 命名风格不统一
- registry L255: `notice_board_max_entries`(全小写)
- `lighting-visual-state.md` Rule 5 + Section G: `NOTICE_BOARD_MAX_ENTRIES`(大写常量)
- 修复: 统一为大写常量风格(同 `MAX_CONCURRENT_SFX` / `AUTO_FIT_FLOOR_PX`)

### INFO (5 条)

ℹ️ I-CONS-1: `audio_bank_total_size_mb` registry 含 art-bible referenced_by(本 review 未读 art-bible 不可验)
ℹ️ I-CONS-2: `final_transition_duration_ms` 在 Input GDD 已正确引用,Audio 间接遵守(无 own ✓)
ℹ️ I-CONS-3: Localization `GAMEOVER.TITLE_IRONY` `max_chars = 5` 在野心版 en 上线时可能受限(已由 OQ-LOC-10 标注)
ℹ️ I-CONS-4: Audio AC-FUNC-11 fade 时长(200/300ms)vs Lighting AC-FUNC-11 即时 pause_tween 是设计差异非矛盾,但 #16 联测 AC 应文档
ℹ️ I-CONS-5: Loc F1 reflow ≤500ms + Lighting watchdog 10000ms 不同事件路径,无时序竞争 ✓

---

## Phase 3 — Design Theory Issues

### 3a/3c/3d/3e
**N/A** — 5 GDD 全部为 Foundation Layer 基础设施,零 gameplay 资源、零进度变量、零经济输入产出。需配合 #11 Action Card / #8 NPC Relationship / #12 Run Meta / #16 KPI Review 等 gameplay GDD 才有意义。

### 3b/3f/3g/Negative Space/Pillar 4 红线

**支柱对齐总评 ✓ PASS**: 5 GDD pillar 锚定全部明确,**零 anti-pillar 违反**:

| GDD | Primary | Guard | Anti-Pillar 违反 |
|---|---|---|---|
| save-system | P5 + P3 | P1 (Rule 22 content-only unlocks) | 无 |
| input-handler | P5 | P4 (anti-QTE 守门 Rule 4) | 无 |
| localization-hooks | P5 | P4 (`_IRONY` 锚点) | 无 |
| audio-manager | P5 | P4 (`_BUREAUCRATIC` 锚 + 8 SFX 红线) | 无 |
| lighting-visual-state | P2 | P1 + P4 | 无 |

**玩家幻想一致性 ✓ PASS**: 跨 GDD 互引参照清单(零矛盾):
- Audio L41 互引 "Save 下班打卡机 / Input 工位隔间键盘 / Localization 老家亲戚的中文"
- Lighting L49 互引 "Save 下班打卡机 / Input 工位隔间键盘 / Audio 日光灯嗡 / Localization 老家亲戚的中文"
- Localization L37 互引 "Save 下班打卡机 / Input 工位隔间键盘"
- Input L37-38 互引 "Save 下班打卡机"
- Save L31 反参照 "不是 Stardew Valley 温柔睡觉动画"
- 5 Section B 拼出的人设: **被工位驯化、对庆祝不再期待、把丑陋日常视为常态的中年打工人**。零信号矛盾

### WARNING

⚠️ **W-DT-1**: Localization 自身未对称引用 Lighting 三轨伙伴
- Audio L37 / L101 / L123 / L451-462 显式提及 `GAMEOVER.TITLE_IRONY` 同质
- Lighting L15 / L45 / L573 三处显式声明"audio-visual 对偶 + 三轨守门铁三角"
- **`localization-hooks.md` Section B + Tone 守护章节未显式提及 Lighting 视觉静止守门作为同源伙伴** — 铁三角文档层不对称
- AC-TONE-03 (Lighting L643) 已在 CI 层把三轨绑死(lighting_lint + audio_lint + i18n_lint 联运),**执行层 PASS**,仅文档叙事一致性微瑕
- 修复: Localization Section B 或 Rule 11 增一句"三轨守门铁三角:文字反讽 + Audio `_BUREAUCRATIC` 行政音 + Lighting `KPI_REVIEW` 视觉静止"

### INFO (2 条)

ℹ️ I-DT-1: 设置面板累加复杂度(Audio 4 旋钮 + Loc + Input keybind + Save 档案柜),需在 #17 Main Menu GDD 阶段强制规划"首次启动跳过设置默认 commit"路径
ℹ️ I-DT-2: Lighting primary pillar = P2(其余 4 GDD primary = P5)分布合理,但需在 systems-index.md cross-check 一致

### Pillar 4 红线覆盖度 ✓ 互补、零漏洞、零冗余

| GDD | 禁止清单 | 覆盖语义 |
|---|---|---|
| Audio | 8 SFX (成就 / 升级 fanfare / 完美 timing / 鼓掌 / 升职加薪 / 胜利曲切换 / 大气结局 / 励志 stinger) + 4 BGM 切换 | 听觉胜利 / 励志 |
| Lighting | 8 视觉禁 (金光 / 升职金光 / 励志光环 / 优秀员工高光 / 周年庆奖励金 / 加班努力光环 / KPI 通过金线 / 加班奖励光圈) + 4 例外白名单 | 视觉胜利 / 励志 |
| Localization | `_IRONY` 后缀强制 + `GAMEOVER.TITLE_IRONY` 硬锁 + 译者 review gate(禁 "晋升失败 / Game Over / You Got Promoted" 回译) | 文字胜利 / 励志中性化 |
| Save | Rule 22 `meta.unlocks` content-only(禁机械成长字段)+ Rule 21 离职证明 transition `easing = NONE` | 持久化层胜利感 |
| Input | Rule 4 Anti-Pillar 3 守门(禁 QTE / combo / 蓄力 / 节奏窗口)+ Section G 零音频 | 操作丝滑 / 反应英雄 |

3 GDD 都有 CI lint 自动执法(audio_lint.gd / lighting_lint.gd / i18n_lint.py)+ AC-TONE-03 联合 lint。

---

## Phase 4 — Cross-System Scenario Issues

### 场景 1: 应用冷启动 / Loading Scene 序列

🔴 **B-SCN-1**: Scene & Day Flow Controller (#6) 共同悬空 — 5 GDD 全部依赖 #6 调度
- `audio-manager.md` L149 / L188: `mark_ready()` "由 Scene & Day Flow 调"
- `lighting-visual-state.md` L84 / L174: `_mark_ready()` "Scene Flow #6 only"
- `localization-hooks.md` L75: "Scene & Day Flow Controller 初始化序列最早步"
- `input-handler.md` L65: "由 Scene & Day Flow Controller 协调,调 InputHandler.load_keymap(payload)"
- Save Section F 同样把启动注入责任甩给 #6
- **5 系统全部 ready 的串行 / 并行顺序、累积 state payload 路径、payload 失败回滚路径无人定义**
- 修复: #6 GDD 或独立 ADR 锁定 5 系统启动调度协议

⚠️ W-SCN-1: Audio LOADING watchdog 10s + Lighting LOADING watchdog 10s 在同一冷启动事件下同时计时,Localization 30s 锁走另一路径。若 #6 序列卡 9s,两 watchdog 可能同帧 push_error,debug 噪声叠加。建议跨 GDD 统一 watchdog 编排(escalation order)
⚠️ W-SCN-2: Save Rule 7 autosave off-main-thread,但冷启动期 meta load 是同步的(Section D 未明锁 worker)。建议 #6 GDD 锁定:Save meta load → 4 系统 payload 注入 → 4 _mark_ready()
ℹ️ I-SCN-1: Loc Rule 8 <100ms parse 与 Audio Rule 5 ≤200ms preload 可并行(两 GDD 都不互依赖)✓

### 场景 2: Settings UI 同帧改音量 + 语言 + 键位

⚠️ W-SCN-3: Save Rule 14 防抖 500ms,**但 Save GDD 未明确 3 个并发信号(`bus_volume_changed` / `locale_changed` / `keymap_changed`)是否合并到同一 debounce 计时器**。若 per-signal-key debounce 触发 3 次写盘,违背 Rule 14 节流意图。建议 Save Rule 14 在 Tuning Knobs 旁加一句"所有 settings 信号共享单一 500ms 计时器,最后一个信号到达后 500ms 落盘合并 payload"
⚠️ W-SCN-4: 若 #17 Settings UI 内有按键提示文本 `"按 %s 跳过"`(Loc Section F L125),按键 display name 由 Input `get_display_name(action_name)` 注入。Input remap 同帧 + Loc rebuild 同帧 query Input 内存表 — **顺序未定义**。若 Input 信号在 Loc rebuild 之后 emit,提示文本仍显示旧键位。建议显式锁: `keymap_changed` → Input 已写内存 → Loc rebuild 读到的是新值
ℹ️ I-SCN-2: Input/Audio/Loc 各自 Rule 锁"内存表更新即时生效",**不**等 Save 防抖 — 玩家改键即时生效,运行时行为正确解耦 ✓

### 场景 3: 月末 KPI Review 三轨 negative space 演出

🔴 **B-SCN-2**: Save Rule 21 `final_transition_duration_ms ≤ 1500` 锁的是**离职证明 transition**(GAME OVER 后 archive 完成才播),但**月末 KPI Review** 是逐月演出
- Audio Rule 6 (L116) 写 "Music fade in **1.5 s**" — 正好等于 1500ms 上限
- 若 KPI Review 演出复用 Save Rule 21 锁,Audio 1.5s fade-in 撞上限边界 + Lighting 0.3s Tween 早结束(0.3s),三轨**不同步收尾**
- Save Rule 21 措辞("GAME OVER ARCHIVING 事务完成后")指仅 GAME OVER,**但 #16 KPI Review GDD 撰写时是否复用 Save Rule 21 锁未定义**
- 修复: 明确 Save Rule 21 是否覆盖月末 KPI Review,或独立锁 `kpi_review_transition_duration_ms`

⚠️ W-SCN-5: 三轨 negative space "同时拒绝庆祝" tone 锚 — 视觉 0.3s 收尾 vs 听觉 1.5s 还在 fade,玩家看到"已经变成 KPI 紫色 + 1.2s 后才听到打卡机 BGM" — negative space 同步性破裂。建议三轨共用同一节奏 anchor(0.5s 或 1.0s),或显式文档"视觉先到位、听觉滞后是设计意图"
⚠️ W-SCN-6: Input Rule 6 + Save Rule 21 联合 `act_skip` 守门 — 但 Audio 1.5s fade-in 期间玩家按 skip,Audio 没声明"skip 后立即跳到 fade 终点 vs 立即停止 vs 继续 fade"。Lighting Rule 9 `pause_tween()` 是 `WM_FOCUS_OUT` 路径,不覆盖 skip。建议 Audio + Lighting 各加一条"skip 期间 Tween/fade 行为"
ℹ️ I-SCN-3: Input Rule 7 blocking modal 吞 act_skip,KPI Review 用 non-blocking skippable 注册 ✓

### 场景 4: 应用 pause / focus loss

🔴 **B-SCN-3**: Localization R-LOC-3 watchdog 30s `LOCALE_LOCK_WATCHDOG_MS` 在 `locale_switch_locked = true` 时计时
- **Loc GDD 未声明该 watchdog 是否随 `get_tree().paused` 暂停**(wall-clock vs game-time)
- Lighting Rule 9 显式 `pause_tween()`,Audio 显式 fade,但 Loc 30s watchdog 路径未明
- **风险**: 玩家正常 Alt-Tab 32 秒 → Loc watchdog 误触 push_error + 强制 flush pending locale → 演出中视觉文字突变
- 修复: Loc Rule 5 / Edge 4 补一句"watchdog 在 `WM_WINDOW_FOCUS_OUT` 期间挂起,与 Lighting Rule 9 同公版"

🔴 **B-SCN-4**: Lighting 累积 state(`break_room_cracks` / `desk_stain_count` / `notice_board_age` 等)的时间累加触发由 Scene Flow `accumulation_event(type, delta)` 驱动
- **Lighting GDD 未明示 pause 期间是否暂停 month_age 累加** — 但 GDD L238 声明"Scene Flow owns accumulation_event 触发节奏" — 责任甩给 #6
- 风险: 若 #6 用 wall-clock 计时,玩家 Alt-Tab 一夜回来桌子脏了 4 级
- 修复: Lighting GDD Edge 6 显式声明"累积 state 由 #6 game-time 驱动,与 wall-clock 解耦",或 #6 GDD 锁定

⚠️ W-SCN-7: Save Rule 19 WM_WINDOW_FOCUS_OUT 触发 500ms debounced autosave(走 worker)。若玩家 Alt-Tab 时 Audio 200ms Music fade 还在 Tween,Save 500ms debounced autosave 在 fade 完成后落盘 — Audio bus 状态(已 fade 至 -∞)被 snapshot,**重启后玩家看到音量旋钮位置正常但实际播放音量 -∞**。Audio Rule 2 (a) 锁内存表,Save Rule 7 调 `get_state()` 应返回内存表值 — 但 Audio Section F **未明文锁 `get_state()` 返回内存表 vs AudioServer 实时值**
ℹ️ I-SCN-4: Save Rule 19 明确 `WM_WINDOW_FOCUS_OUT` ≠ `WM_CLOSE_REQUEST`,Audio + Lighting `act_pause` / WM_FOCUS_OUT 公版一致 ✓

---

## GDDs Flagged for Revision

无 GDD 需要 Status 转 "Needs Revision"。所有 BLOCKING 都属"跨系统协议悬空 — 待 #6 GDD 或 ADR 仲裁",非 5 GDD 内部已写错的内容。

可选微修(non-blocking,可在下次 GDD review pass 顺手清):

| GDD | 微修建议 | 优先级 |
|-----|--------|------|
| `localization-hooks.md` | Section B 或 Rule 11 增一句"三轨守门铁三角"(W-DT-1) | Warning |
| `localization-hooks.md` | L121 + L353-354 改 "Save Rule 20 承约" → "Save Engine Constraints"(W-CONS-1 之一) | Warning |
| `audio-manager.md` | Rule 2 L67 改 "Save Rule 20 承约" 引用(W-CONS-1 之一) | Warning |
| `audio-manager.md` | Rule 6 表追加英文 enum 列(W-CONS-2) | Warning |
| `lighting-visual-state.md` | Section F L231 + Rule 5 改 "Save Rule 20 承约" 引用(W-CONS-1 之一) | Warning |
| `lighting-visual-state.md` | registry/GDD 命名统一(W-CONS-4) | Warning |

---

## 必须在 Architecture / #6 GDD 撰写前解决的项目

5 BLOCKING 项,按解决路径分组:

### 路径 A: 由 Scene & Day Flow #6 GDD 仲裁(推荐)

1. **B-SCN-1** + **W-SCN-1** + **W-SCN-2**: 5 系统冷启动调度协议、watchdog 编排顺序、Save meta load → 4 系统 payload 注入 → 4 _mark_ready() 序列
2. **B-CONS-1** + **场景 4 各项**: `WM_WINDOW_FOCUS_OUT` 跨系统语义共识(Save vs Audio vs Lighting 三方 authoritative 决策)
3. **B-SCN-3** + **B-SCN-4**: pause 期间 game-time vs wall-clock 边界(Loc watchdog / Lighting 累积 state 节奏)
4. **W-SCN-3**: Save Rule 14 防抖计时器粒度(per-signal vs global)
5. **W-CONS-3**: Scene Flow `scene_state_changed` 同帧主线程预算分摊

### 路径 B: 独立 ADR

6. **B-SCN-2**: `final_transition_duration_ms` 是否覆盖月末 KPI Review,或独立锁 `kpi_review_transition_duration_ms`(影响 Save GDD + Audio GDD + #16 KPI Review GDD 三方契约)

### 路径 C: GDD 微修(在 review pass 期间清理)

7. **W-CONS-1**(4 处错引)+ **W-CONS-2**(Audio Rule 6 enum)+ **W-CONS-4**(命名风格)+ **W-DT-1**(Loc 三轨对称)+ **W-SCN-4**(Settings UI 顺序)+ **W-SCN-5**(三轨节奏 anchor)+ **W-SCN-6**(skip 期间 Tween/fade 行为)+ **W-SCN-7**(Audio `get_state()` 语义)

---

## 推荐下一步

按依赖与风险综合排序:

1. **Foundation 3 GDD fresh session reviews** 不阻塞,可继续按计划走(Localization / Audio / Lighting `/design-review --depth lean`)
2. **Scene & Day Flow #6 GDD `/design-system`** 是路径 A 全部 6 项 BLOCKING 的唯一仲裁场,**强烈推荐 #6 在 Architecture 之前撰写**(systems-index 已锁 Order #6,M size,Bottleneck ⭐)
3. **路径 C 微修**(8 项 Warning)可批量在下一次 GDD review pass 期间清理,或同 session 顺手修 — 不阻塞 #6 / Architecture
4. **路径 B ADR**(B-SCN-2)可在 #16 KPI Review GDD 撰写前独立解决,不阻塞 #6

**Architecture 准入门槛建议**:
- 路径 A 6 项必须在 #6 GDD 完成
- 路径 B 1 项必须在 ADR 落地或在 #16 GDD 中明确
- 路径 C 8 项可推迟到 architecture 完成后 GDD revise 阶段(批量清理)

---

## Appendix — 评审统计

- **GDD 总行数**: 5 GDD ≈ 3009 行 (Save 594 + Input 492 + Loc 609 + Audio 628 + Lighting 686)
- **AC 总数**: ~149 (Save 43 + Input 25 + Loc 28 + Audio 26 + Lighting 27)
- **Registry constants**: 12(Save 4 + Loc 1 + Audio 4 + Lighting 2 + 1 共享 Save Rule 14)
- **Subagent 评审耗时**: Phase 2 (165 s) + Phase 3 (100 s) + Phase 4 (127 s) = 392 s 并行执行
