# Notification & Warning System (Enhanced)

> **Status**: Designed (pending review)
> **Author**: huanghaibin + game-designer (Section A-H 主笔)
> **Authoring autonomy mode**: v2 no-prompt(0 widget)
> **Last Updated**: 2026-04-28
> **Layer**: Presentation | **Order**: #19 | **Size**: M | **Tier**: Vertical Slice
> **Implements Pillar**: P5 守(玩家 agency 守门 — capacity_floor 预警 R-AP-5 + R-KPI-3 落地)+ P4 守(HR 口吻预警语义 — 老员工"看着吧",不戏剧化)+ P1 守(反向 KPI 可教学 C5 — 预警是"机制自我解释"而非 tutorial popup)

---

## Section A — Overview

**Notification & Warning System (Enhanced)** 是《活过第 X 集》的**玩家 agency 预警协议层** —— 以 diegetic 形式把四类机制临界状态翻译成工位场景内的自然迹象,让玩家在数学上还有选择空间时"隐约感到不对",而不是在 GAME OVER 时才明白规则。

### 双重身份

**技术层**: Notification System 是**纯信号中继层** —— 无自身状态,无自身业务逻辑。订阅 `#6 scene_state_changed`(月末倒计时触发)+ `#7 energy_changed` / `burnout_status_changed`(burnout 预警)+ `#8 npc_lifecycle_changed`(LEAVING_ANNOUNCED 预兆)+ `#9 kpi_threshold_changed` / `capacity_warning_emitted`(capacity_floor 预警)+ `#7 effort_dimension_changed`(effort 极值预警),归一化为 `warning_*` 信号族 emit 给 `#13 HUD Diegetic` 渲染层。**自身不持有任何 diegetic 元素** —— 渲染由 `#13` own。

**叙事层**: 玩家感受到的不是"⚠ 警告:KPI 危险",而是"老油条拿着杯子靠过来说'你这个月的 KPI 嗯……你看着吧'"——这句话是 HR 口吻的人情世故,不是系统广播。`#13` 显示器数据屏出现红色分隔线,不是"进度条超限"警告框。Lisa 开始上午 10 点才来,眼神不往你这边看 —— 预兆嵌在工位物理叙事里,不脱离场景存在。

### Pillar 服务

- **P5 守 地铁可玩性**: 预警必须 dispatch ≤ 1 帧(Rule 8)。agency 窗口足够让玩家在下一日有调整空间,不在 GAME OVER 瞬间首次感知危险。与 R-AP-5 + R-KPI-3 共同守门:capacity_floor 场景 + effort 极值场景必须有可读预警。
- **P4 守 苦中作乐黑色幽默**: 预警语义的一切 HR 口吻词条 —— "看着吧" / "我也是这么过来的" / "最近辛苦了啊" —— 都经由 `#10 Event Script` 落地为 NPC 台词,不直接 emit 文案。预警本身只 emit 语义信号,文案由 writer + narrative-director own。**禁** 戏剧化 tone —— 预警不是审判预告,是老同事不经意的一句话。
- **P1 守 平庸是艺术**: KPI research C5 "可教学性" — 预警是 capacity_floor / effort 极值机制自我披露的最后一道环节。玩家通过工位迹象"自己想明白",不通过 popup 被告知。

### 5 NOT 边界(scope creep 防护)

- **NOT** diegetic 元素自渲染(`#13 HUD Diegetic` own 所有工位 sprite / visual variant / 红线显示器;本 GDD 仅 emit `warning_*` 信号给 `#13`)
- **NOT** NPC 离职决策逻辑(`#8 NPC` own `LEAVING_ANNOUNCED` 状态转移和离职 finalization;本 GDD 仅订阅 `#8` emit 的 lifecycle 信号作预兆展示)
- **NOT** KPI 数学 / capacity_factor 公式计算(`#9 KPI System` own;本 GDD 仅消费 `#9` emit 的预警信号 payload)
- **NOT** popup / 提示框 / 弹层 / overlay HUD(`#19` 是纯预警协议,所有信息载体在 `#13` diegetic 物理空间内;**任何 popup 形式一律 PR-blocking**)
- **NOT** 月末倒计时 UI 渲染由 `#16 KPI Review & Game Over UI` own(月末切换至 `KPI_REVIEW` sub-mode 后的屏幕由 `#16` 接管;本 GDD 仅 own 月末前 -3 天的倒计时预兆信号)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 任何 popup / 提示框 / 系统通知弹层(违反 art-bible §7.1 diegetic 锁 + P4 HR 口吻原则)
- **NOT** "警告!" / "危险!" / "KPI 即将超限!" 语义文案(违反 P4 戏谑 HR 口吻 — 系统不对玩家喊话)
- **NOT** 预警触发 UI 庆祝 / 提示音 / 欢庆语义(违反 Anti-Pillar 1 + P4 苦中作乐)
- **NOT** 预警在 GAME OVER 之后继续 emit(LEFT NPC 预兆残留 bug — R-NW-2 守门)
- **NOT** 帧延迟预警(dispatch > 1 帧 = P5 守门失效 — 玩家 agency 窗口丢失)

### Source 引用

`#9 KPI System` Rule 8 `capacity_factor` 衰减 + AC-ROBUST-03/05 agency 守门(本 GDD 落地 HUD 预警层)。`#7 AP Economy` Rule 6 effort 三维度 + R-AP-3 burnout 预警 + R-AP-5 capacity_floor 守门。`#8 NPC Relationship System` Rule 7 NPC 生命周期状态机 + `LEAVING_ANNOUNCED` 预兆事件触发。`#6 Scene & Day Flow Controller` Rule 10 月末触发协议 + 8 sub-mode enum。`#13 HUD Diegetic` Section C Rule 5 NPC 表情/站位协议 + Rule 6 显示器数据屏协议 + Section A diegetic 锁。`design/art/art-bible.md` §7.1 Diegetic UI 锁 + §4.1 色彩警戒语义。`game-concept.md` Pillar 1(平庸艺术 C5 可教学)+ Pillar 4(HR 口吻原则)+ Pillar 5(地铁可玩性 agency 守门)。

---

## Section B — Player Fantasy

### 主锚: "老员工的'你看着吧'"

**场景**:
周三下午,老油条拿着保温杯晃到你工位旁,随口问"这个月 KPI 怎么样啊",你还没回答,他自己点点头:"嗯……你看着吧。" 然后走开了。你看着他的背影,突然想起上个月自己加班的三个晚上,看一眼显示器上的数据表,第 13 行那条线微微红了一点点 —— 不是红色警告框,是那条分隔线的颜色和以往有一点不一样。

没有 UI 提示。只有老油条离开时的那句话,和你自己多看了一眼的那条线。

**Pillar 服务**:
- **主 P1 守 可教学机制**: 预警是"机制自我披露"而非 tutorial —— 玩家从老油条的话和显示器的线"自己想明白",不被系统告知。KPI research C5 在此具象化
- **守 P4 苦中作乐**: HR 口吻的极致表达是无主语的旁观 —— "你看着吧"不是威胁,是经历过的人用经验说话。老油条的语气里没有怜悯,也没有幸灾乐祸
- **守 P5 地铁可玩性**: 这个预警让玩家"还有时间",不是在 GAME OVER 瞬间的首次感知

**跨 GDD negative space 联动**:
- **#9 KPI 主锚 C2 觉察拐点** 共振: "我加班了他涨了" 的觉察过程,#19 是这个过程最后的 felt sense 前奏 — 预兆先于拐点
- **#13 HUD 便利贴工位** 基底: 显示器红线不是新增 UI 元素,是 `HUD_MONITOR_DATA` 既有 5 态 variant 被预警信号激活到"预警黄/超标红"态

**❌ Tone 风险(必避)**:
- "⚠ KPI 危险!系统通知你…"(主语 = 系统评判玩家 — 违反 HR 口吻 + P4)
- 老油条台词出现"你要努力一点" / "加油能过"(励志语义 — 违反 Anti-Pillar 2)
- 预警出现感叹号 / 红色弹出框 / 全屏遮罩(违反 art-bible §7.1 diegetic 锁)

**✅ Tone 守护(推荐)**:
- "你看着吧" / "我也是这么过来的" / "最近辛苦了啊"(无主语的经历感叹)
- "这个月差不多了" / "嗯……"(留白、省略号,工位口语)

---

### 副锚: "Lisa 上周开始不看你了"

**场景**:
你不确定具体是哪天开始的 —— 但某天早上你抬头,发现 Lisa 侧身的方向变了。她以前偶尔会往你这边看,现在背对着坐着。她没有说什么,工位上多了一个装东西的纸箱 —— 还没开始装,就那么放着。

你意识到那是跳槽前整理桌子的人才会提前带来的箱子。

**Pillar 服务**:
- **守 P2 叙事即机制**: Lisa 的背影 + 纸箱不是 UI 提示 — 它们是 `#13 HUD_NPC_EXPRESSION` / `HUD_NPC_POSITION` visual variant 被 `warning_npc_leaving(LISA)` 信号激活,信息就长在工位世界里
- **守 P4 苦中作乐**: diegetic 反讽预警 — 你通过"她不看你"读出"她要走了",而不是系统弹出"Lisa 离职预告"
- **守 P3 死亡是注定的**: 离职不可逆性在发生之前就有迹可循,但"有迹可循"不等于"可以阻止"

**❌/✅ Tone 守门对应 #8 Section B NPC 算计原则**:
- Lisa 纸箱 = `HUD_LEAVING_ARTIFACT` visual variant(由 `#13` own 渲染),不是浮动文字"Lisa 要走了"
- NPC 背对工位 = `HUD_NPC_POSITION` `HOSTILE` stance,被 `LEAVING_ANNOUNCED` lifecycle 激活

---

## Section C — Detailed Rules

10 Core Rules + States + Interactions。

---

### Core Rules

**Rule 1 — capacity_floor 预警(R-AP-5 + R-KPI-3 agency 守门)**

触发条件:`#9` 内部 `capacity_factor(m) <= CAPACITY_WARNING_THRESHOLD`(Tuning Knob,推荐 0.7)且 `monthly_threshold / capacity_now >= THRESHOLD_CAPACITY_RATIO_WARN`(推荐 1.2)时,`#9` emit `capacity_warning_emitted(month_index, capacity_now, threshold_now)`。

`#19` 订阅此信号,转发 `warning_capacity_critical(severity: int [1,3], month_index)` 给 `#13 HUD Diegetic`。

**#13 渲染层响应**(由 `#13` own,`#19` 不自渲染):
- `HUD_MONITOR_DATA` variant 激活 "预警黄" 或 "超标红" 态(对应 severity 1/2/3)
- 月份 `m >= 9` 时启用"老 NPC 预言 hint":emit `warning_npc_prediction_hint(npc_id, severity)` → `#10 Event Script` 触发 NPC 预言台词事件入队(如老油条"你看着吧")

**老 NPC 预言 hint 协议**:
- `warning_npc_prediction_hint` 由 `#19` emit,`#10 Event Script` 订阅并注入 `MORNING_BRIEFING` 事件队列
- 文案 key 由 `#10` + writer own,`#19` 只传 `(npc_id: NpcId, severity: int)` payload
- 每月最多触发 1 次 hint(防 hint 泛滥 — Rule 7 HR 口吻克制原则)

**📌 R-AP-5 + R-KPI-3 跨 GDD 守门**: 本 Rule 是 `#7 R-AP-5` 和 `#9 R-KPI-3` 共同声明的 agency 守门在 HUD 层的**唯一落地点**。缺少此 Rule 的实现 = 两个 [RISK GUARD] 均未闭环。

---

**Rule 2 — effort 极值预警**

触发条件:`#7 effort_dimension_changed(potential, hero_count, overage_count)` 中,当月累计 `effort_norm >= EFFORT_EXTREME_THRESHOLD`(Tuning Knob,推荐 0.75)时。

`#19` 转发 `warning_effort_extreme(effort_norm: float)` 给 `#13 HUD Diegetic`。

**#13 渲染层响应**:
- `HUD_STICKY_NOTES` 额外渲染"加班便利贴堆叠" visual variant(非新元素,是既有便利贴 variant 的"密集态")
- `HUD_DESK_SURFACE` 桌面 visual variant 激活"文件堆叠" state(由 art-bible §6.4 累积叙事 — `#13` own 渲染实现)

**每月重置**: `effort_norm` 由 `#7 monthly_effort_summary` 月末推送后清零;对应 `warning_effort_extreme_cleared` 由 `#19` emit 给 `#13` 解除 variant。

---

**Rule 3 — NPC 离职预兆(LEAVING_ANNOUNCED lifecycle 期间)**

触发条件:`#8` emit `npc_lifecycle_changed(npc_id, ACTIVE, LEAVING_ANNOUNCED, reason)`。

`#19` 转发 `warning_npc_leaving(npc_id: NpcId)` 给 `#13 HUD Diegetic`。

**#13 渲染层响应**:
- `HUD_NPC_EXPRESSION` 对应 NPC → "冷淡" variant(介于 `NEUTRAL` 和 `HOSTILE` 之间的 sub-variant —— 不等于 HOSTILE,是"开始疏远"感知,由 art-director 定义)
- `HUD_NPC_POSITION` 对应 NPC → "偶尔背对" variant(非持续背对 —— 区分于 `HOSTILE` 全时背对)
- `HUD_LEAVING_ARTIFACT`(VS scope 扩展 diegetic 元素):LEAVING_ANNOUNCED 期间在该 NPC 工位区域渲染"纸箱未装" visual detail

**解除条件**: `#8 npc_lifecycle_changed(npc_id, LEAVING_ANNOUNCED, LEFT)` 时 `#19` emit `warning_npc_leaving_resolved(npc_id)` → `#13` 切换为空椅(`HUD_EMPTY_CHAIR`)。

**R-NW-2 守门**: `lifecycle_state == LEFT` 后,`#19` 永不再 emit `warning_npc_leaving(npc_id)` for the same NPC。任何从已 LEFT NPC 路径来的 `npc_lifecycle_changed` 信号必须被 `#19` 静默丢弃(防预兆残留)。跨守 `#8 R-NPC-2`(LEFT 视觉屏蔽守门)。

---

**Rule 4 — 月末倒计时预兆(月末 -3 天)**

触发条件:`#6 scene_state_changed` payload 中 `days_remaining_in_month <= 3`。`#6 Rule 9` 离散 tick 驱动 `current_day` 更新后,由 `#6` 通过 `monthly_countdown_warning(days_left)` 信号通知,或由 `#19` 自行从 `scene_state_changed` payload 计算 `days_left`(OQ-NW-02)。

`#19` emit `warning_month_end_countdown(days_left: int [1,3])` 给 `#13 HUD Diegetic`。

**#13 渲染层响应**:
- `HUD_DESK_CALENDAR` 当日格子 → "红边" variant(对应剩余天数 3/2/1,边框厚度渐增)
- `HUD_ATTENDANCE_BOARD` 月末高亮区域 → 激活 variant(月内 highlight)

**老 NPC 预言 4 档**(配合 Rule 1 老 NPC 预言 hint 协议,`days_left` 驱动档位):

| `days_left` | NPC 台词 hint 档位 | 语气参考 |
|-------------|------------------|---------|
| 3 | 档位 1 | "这个月不多了啊"(轻描淡写) |
| 2 | 档位 2 | "明天后天了"(平调提示) |
| 1 | 档位 3 | "嗯,最后一天。"(反讽留白) |

无 `days_left = 0` 档位:Day 0 已进入 `KPI_REVIEW` sub-mode,`#16` 接管,倒计时预兆自动解除。

**月末倒计时清除**: `scene_state_changed(→KPI_REVIEW)` 时 emit `warning_month_end_cleared` → `#13` 回到正常日历态(倒计时进入结算屏,倒计时 HUD 不延续至 `#16` 结算屏)。

---

**Rule 5 — burnout 预警(Energy ≤ 15)**

触发条件:`#7 energy_changed(current_energy, max_energy)` 且 `current_energy <= BURNOUT_WARNING_ENERGY`(Tuning Knob,推荐 15)。

`#19` emit `warning_burnout_approaching(current_energy: int)` 给 `#13 HUD Diegetic`。

**#13 渲染层响应**:
- `HUD_COFFEE_CUP` → 激活"近黑咖啡渍 / 极少残量" visual variant(area = [1, 19] 区间最深色阶,近乎见底;参考 `#13 Rule 4` 液位阶段表末行)
- Energy = 0(`burnout` state):咖啡杯已在 `#13 Rule 4` 中独立处理("空杯 + 干渍底"),`#19` 在 energy=0 时再 emit `warning_burnout_active`,驱动 `#13` 确认空杯态锁定(防两个系统对同一信号各自计算 race)

**R-AP-3 对齐**: `#7 R-AP-3` 守门要求 burnout 时加班申请被拒绝。`#19` 的 burnout 预警是玩家"感知层"保证,技术层守门由 `#7 Rule 3` 独立执行,两者不互相依赖。`#19` 不做业务守门判断。

---

**Rule 6 — 禁 popup / 提示框 / "警告!" 音效**

**这是 Pillar 4 + art-bible §7.1 的双重红线,无任何豁免。**

- `#19` emit 的所有 `warning_*` 信号**只能**驱动 `#13 HUD Diegetic` 内的 diegetic 元素 visual variant 切换
- `#19` **不能** emit 任何让 UI 层弹出悬浮提示框、半透明遮罩、toast notification、系统通知栏的信号
- `#19` **不能** emit 任何触发"警告音效"的信号(警告音 = 奖励/惩罚语义音效 = Pillar 4 红线)
- 任何实现路径在 Code Review 中若出现 `popup` / `show_message` / `notification_overlay` 函数调用 = PR-blocking
- CI lint: `grep -r "popup\|overlay\|show_notification\|warning_sound" src/systems/notification/` 必须 0 命中

---

**Rule 7 — HR 口吻预警语义守门**

所有由 `#19` `warning_npc_prediction_hint` 触发的 NPC 台词事件,文案必须通过 `#9 Section B` "HR 口吻原则"设计测试:

**问**: "这是审判 boss 的语气,还是老同事无意说的话?"
- 如果文案让玩家觉得"系统/NPC 在警告我 / 在威胁我" → 改写
- 如果文案让玩家觉得"老同事在分享经历 / 无意提到" → 通过

| 正例 ✅ | 反例 ❌ |
|--------|--------|
| "你这个月…… 你看着吧。"(老油条) | "你的 KPI 快到阈值了,需要注意!" |
| "我也是这么过来的。"(老油条) | "你要努力啊,还有机会!"(励志 Anti-P2) |
| "最近辛苦了啊。"(任意 NPC) | "你快完蛋了!"(戏剧化) |
| "这个月差不多了。"(模糊评价) | "再坚持一下,你能过的！"(Anti-P2) |

每条 NPC 台词文案须附具体触发 `(npc_id, severity)` 组合注记,由 `#10 Event Script` writer 团队审校。`warning_npc_prediction_hint` 每月最多触发 1 次(防台词泛滥 — 淡化惊喜感)。

---

**Rule 8 — dispatch ≤ 1 帧**

所有 `warning_*` 信号从订阅上游信号到 emit 给 `#13` 的延迟 **≤ 1 帧(16.6 ms)**。

实现约束:
- `#19` 内部不做异步计算,不持有 Timer 节点;信号回调(synchronous GDScript)直接 emit 下游信号
- `warning_npc_prediction_hint` → `#10` 注入台词事件:注入操作本身为同帧调用,但 NPC 台词展示可能延迟至下一个 `MORNING_BRIEFING` sub-mode(UI 渲染延迟合理,注入本身不延迟)
- CI 监视: debug build 中,`#19` 信号回调用 `Time.get_ticks_usec()` 首尾打点,若超出 `16600 µs` 则 `push_warning("[NW#19] warning dispatch exceeded frame budget: %.1f ms")`

---

**Rule 9 — 信号架构**

`#19` 订阅上游信号:

| 上游信号 | 来源 GDD | 触发 Rule |
|---------|---------|----------|
| `capacity_warning_emitted(month_index, capacity_now, threshold_now)` | `#9 KPI System` | Rule 1 |
| `effort_dimension_changed(potential, hero_count, overage_count)` | `#7 AP Economy` | Rule 2 |
| `npc_lifecycle_changed(npc_id, old_state, new_state, reason)` | `#8 NPC Relationship` | Rule 3 |
| `scene_state_changed(old_mode, new_mode)` | `#6 Scene & Day Flow` | Rule 4 + 全局 sub-mode 判断 |
| `energy_changed(current_energy, max_energy)` | `#7 AP Economy` | Rule 5 |

`#19` emit 下游信号:

| 信号 | 参数 | 主消费者 |
|------|------|---------|
| `warning_capacity_critical(severity, month_index)` | severity: int [1,3] | `#13 HUD Diegetic` |
| `warning_npc_prediction_hint(npc_id, severity)` | NpcId + int | `#10 Event Script`(二次消费;注入台词事件) |
| `warning_effort_extreme(effort_norm)` | float [0.0, 1.0] | `#13 HUD Diegetic` |
| `warning_effort_extreme_cleared()` | — | `#13 HUD Diegetic` |
| `warning_npc_leaving(npc_id)` | NpcId | `#13 HUD Diegetic` |
| `warning_npc_leaving_resolved(npc_id)` | NpcId | `#13 HUD Diegetic` |
| `warning_month_end_countdown(days_left)` | int [1, 3] | `#13 HUD Diegetic` |
| `warning_month_end_cleared()` | — | `#13 HUD Diegetic` |
| `warning_burnout_approaching(current_energy)` | int [1, 15] | `#13 HUD Diegetic` |
| `warning_burnout_active()` | — | `#13 HUD Diegetic` |

**双向协议注记**:
- `#13 HUD Diegetic` Section C Rule 2 sub-mode layout 表未列出 `#19` 专项 layout 节点 —— `#19` 的信号通过 `#13` 的 existing diegetic 元素 visual variant 机制消费(不新增 HUD 节点)
- `#10 Event Script` 订阅 `warning_npc_prediction_hint`:文案注入协议由 `#10` own,`#19` 不负责文案内容

---

**Rule 10 — Scope Tier**

| 功能 | VS(当前 GDD 目标) | 野心版 |
|------|-----------------|-------|
| capacity_floor 预警 Rule 1 | 完整(显示器红线 + NPC hint) | 自定义阈值配置 |
| effort 极值预警 Rule 2 | 完整(便利贴密集态 + 桌面 variant) | effort 多阶预警(3 档) |
| NPC 离职预兆 Rule 3 | 完整(表情/站位/纸箱 variant) | 纸箱装填进度 diegetic animation |
| 月末倒计时 Rule 4 | 完整(日历红边 + NPC 预言 4 档) | 日历格子数字颜色渐变 |
| burnout 预警 Rule 5 | 完整(咖啡杯极深色阶) | 咖啡杯微震 sprite animation |
| 禁 popup Rule 6 | 硬性红线,不分 scope | — |
| HR 口吻 Rule 7 | 完整 | 词条库扩展至 40+ 条 |

---

### States and Transitions

`#19` 自身为**无状态中继**(Stateless Relay)—— 无独立状态机。所有状态由上游信号驱动、由 `#13` HUD 持有视觉状态。

`#19` 维护唯一内部状态 dict:

```gdscript
var _active_warnings: Dictionary = {}
# key: "capacity_critical" | "effort_extreme" | "npc_leaving_LISA" | "month_countdown" | "burnout"
# value: true = 当前活跃预警
```

此 dict 用于 Rule 3 R-NW-2 守门(防 LEFT NPC 预兆 leak)+ Rule 5 burnout 去重 + Rule 4 月末倒计时幂等。`_active_warnings` **不持久化至 Save**(预警状态从上游信号重建,非 Run 关键状态)。

---

### Interactions

| # | 对端 | 方向 | 协议 |
|---|------|------|------|
| I-1 | `#6 Scene & Day Flow` | `#6` → `#19` | `scene_state_changed` → 月末倒计时(Rule 4)+ GAMEOVER 全清钩子 |
| I-2 | `#7 AP Economy` | `#7` → `#19` | `effort_dimension_changed` + `energy_changed` → effort 极值 + burnout 预警 |
| I-3 | `#8 NPC Relationship` | `#8` → `#19` | `npc_lifecycle_changed` → NPC 离职预兆信号 |
| I-4 | `#9 KPI System` | `#9` → `#19` | `capacity_warning_emitted` → capacity_floor 预警 |
| I-5 | `#13 HUD Diegetic` | `#19` → `#13` | 全量 `warning_*` 信号驱动 visual variant(主消费者) |
| I-6 | `#10 Event Script Engine` | `#19` → `#10` | `warning_npc_prediction_hint` 注入 NPC 台词事件(二次消费) |
| I-7 | `#20 Accessibility` | `#19` → `#20` | `warning_*` 信号供 Accessibility 追加可选视觉/文字辅助替代方案(Alpha scope) |

---

## Section D — Formulas

**N/A** —— `#19` 是纯信号中继层,无独立公式。所有预警触发阈值均引用上游 GDD 公式:

- capacity_factor 衰减:`#9 F3` + `#7 F3`(共享公式,`CAPACITY_FLOOR` 常量)
- effort_norm 计算:`#7 F4`(0.45/0.20/0.30 三维加权归一化)
- burnout 能量边界:`#7 Rule 3` `ENERGY_OVERTIME_MIN = 15`(加班门槛)

预警触发阈值是 Tuning Knobs(见 Section G),不是独立公式。本 GDD Section D 无需补充数学,沿用各上游公式结果。

---

## Section E — Edge Cases

12 edges / 4 categories / 2 [RISK GUARD]。

### Cat 1: 预警边界 edge

**1.1**: `capacity_warning_emitted` 在同月被多次 emit(`#9` 内部每日 capacity 评估)→ `#19` 检查 `_active_warnings["capacity_critical"]` 是否已激活;已激活则**不重复 emit** `warning_capacity_critical`,防 `#13` 重复触发 visual variant 切换。severity 若升级(1→2→3)则强制 re-emit。
- Cite: Rule 1 / Rule 8

**1.2**: `effort_norm` 在月内多次超过 `EFFORT_EXTREME_THRESHOLD`(每日累计)→ `warning_effort_extreme` 只在首次超阈值时 emit;`_active_warnings["effort_extreme"]` 置 true 后不重复。月末 `warning_effort_extreme_cleared` 重置。
- Cite: Rule 2

**1.3**: `current_energy` 在 burnout 预警区间内反复上下穿越 15(早退回精力 → 加班扣精力 → 早退回精力)→ `warning_burnout_approaching` 在每次**下穿 15**时 emit,上穿后不自动 emit "警告解除"(burnout 解除无显式 warning)。咖啡杯液位由 `#13` 自行跟随 `energy_changed` 实时更新。
- Cite: Rule 5 / `#13 Rule 4`

**1.4**: `days_remaining_in_month` 在 `AFTER_WORK` → `DAILY_RECAP` 转移帧下降到 2 → `#19` 需在同帧 emit `warning_month_end_countdown(2)`,不等下一个 `scene_state_changed` 再重新算。`days_left` 从 `scene_state_changed` payload 中直接读取(需 `#6` 在 payload 中包含 `days_remaining` 字段 —— 见 OQ-NW-02)。
- Cite: Rule 4 / `#6 Rule 9`

### Cat 2: 多预警同帧

**2.1**: capacity_floor 预警 + burnout 预警 + NPC 离职预兆在同一帧触发(月末最后一天加班到精力 15,同时 `capacity_warning_emitted`)→ `#19` 依序 emit 三类 `warning_*` 信号,`#13` 按信号注册顺序处理。三类信号操作不同的 diegetic 元素(显示器 / 咖啡杯 / NPC),无冲突。
- Cite: Rule 8 / `#13 Rule 1` 元素独立

**2.2**: 月末倒计时(Rule 4)和 NPC 离职预兆(Rule 3)同时活跃 → `#13 HUD_DESK_CALENDAR` 红边 + `HUD_NPC_POSITION` 冷淡 variant 独立渲染,互不干扰。`_active_warnings` dict 各自独立 key。
- Cite: Rule 3 + Rule 4 / `#13 Rule 2` sub-mode layout

**2.3**: GAMEOVER 触发时所有活跃预警应被清除 → `#6 scene_state_changed(→GAMEOVER)` 时 `#19` 执行 `_clear_all_warnings()`:遍历 `_active_warnings` 全清,依次 emit 相应 `*_cleared` 信号。`#13` 在 `GAMEOVER` sub-mode 下隐藏所有 diegetic 元素(`#13 Rule 2` GAMEOVER layout)—— 预警清除信号在此 sub-mode 下为幂等操作。
- Cite: Rule 9 / `#13 Rule 2`

### Cat 3: LEFT NPC 预警 leak

**3.1 [RISK GUARD R-NW-2]**: `#8` 在 NPC 已 LEFT 后,若因 bug 补发 `npc_lifecycle_changed(npc_id, LEAVING_ANNOUNCED, ...)` → `#19` 检查 `_active_warnings["npc_leaving_{npc_id}"]` + `#8 is_npc_active(npc_id)` 双重守门:任一为 false 时**静默丢弃**信号,不 emit `warning_npc_leaving`。`push_warning("[NW#19] ignoring lifecycle signal for LEFT npc: {npc_id}")`。
- Cite: Rule 3 R-NW-2 / `#8 Rule 7` lifecycle state

**3.2**: `npc_lifecycle_changed(LEAVING_ANNOUNCED → LEFT)` 与 `npc_lifecycle_changed(LEAVING_ANNOUNCED → ...)` 同帧双重触发(`#8` bug)→ `#19` 在处理 LEFT 信号时先执行 `warning_npc_leaving_resolved`,再清除 `_active_warnings`;第二个信号到达时 `_active_warnings` 已清,幂等操作,不重复 emit resolved。
- Cite: Rule 3 / R-NW-2

**3.3**: 同帧 3 个 NPC 同时进入 `LEAVING_ANNOUNCED`(极端 edge)→ `#19` 依序处理三个 `npc_lifecycle_changed` 信号,依序 emit 三个 `warning_npc_leaving(npc_id)`;`#13` 依序更新三个 NPC 的 visual variant。GDScript 单线程串行,无竞争。
- Cite: Rule 3 / Rule 8

### Cat 4: popup 红线触发场景

**4.1 [RISK GUARD R-NW-1]**: 实现阶段若有 `warning_capacity_critical` 被误接到 UI Overlay 系统(如将 `#19` 信号连接到一个弹出控制节点)→ CI lint(`grep -r "popup\|overlay" src/systems/notification/`)必须 0 命中;Code Review 阶段 `#19` 信号订阅方白名单:仅允许 `#13 HUD Diegetic` + `#10 Event Script` + `#20 Accessibility` 三个系统。其他系统订阅 `warning_*` = PR-blocking。
- Cite: Rule 6 / art-bible §7.1

**4.2**: Debug 模式下开发者在 Godot 编辑器直接调试 `#19.emit_signal("warning_capacity_critical")` → Godot Inspector 本身不订阅 GDScript 用户自定义信号;debug 工具层的弹窗不属于游戏层 popup。此 edge 不违反 Rule 6(Rule 6 约束的是游戏运行时 UI 路径,不是编辑器调试工具)。
- Cite: Rule 6 scope 限定

---

### 2 [RISK GUARD] 索引

| ID | 守 Pillar | 位置 | Section H 守门 |
|----|---------|------|---------------|
| **R-NW-1** | popup 提示框漏入(违反 art-bible §7.1 + P4) | Cat 4.1 | AC-ROBUST-01 |
| **R-NW-2** | LEFT NPC 预警残留(跨守 `#8 R-NPC-2`) | Cat 3.1 | AC-ROBUST-02 |

---

## Section F — Dependencies

### Upstream

| GDD | 关系 | 状态 | 提供 |
|-----|------|------|------|
| `#6 Scene & Day Flow Controller` | Hard | Designed | `scene_state_changed` 月末倒计时触发 + GAMEOVER 全清钩子 |
| `#7 AP Economy System` | Hard | Designed | `energy_changed` + `effort_dimension_changed` |
| `#8 NPC Relationship System` | Hard | Designed | `npc_lifecycle_changed` LEAVING_ANNOUNCED 预兆信号 |
| `#9 KPI & Reverse Threshold System` | Hard | Designed | `capacity_warning_emitted(month, capacity_now, threshold_now)` |

### Downstream

| # | System | 关系 | 主接口 |
|---|--------|------|--------|
| 13 | HUD Diegetic | Hard | 全量 `warning_*` 信号驱动 visual variant(主消费者) |
| 10 | Event Script Engine | Soft | `warning_npc_prediction_hint` 注入 NPC 台词事件 |
| 20 | Accessibility Options | Soft(Alpha) | `warning_*` 信号供辅助功能追加文字替代标注 |

### 双向一致性 cross-check

| 上游声明 | 本 GDD Rule | 状态 |
|---------|------------|------|
| `#7 R-AP-3` burnout 加班拒绝守门 | Rule 5(感知层 only,不做业务守门) | ✓ |
| `#7 R-AP-5` capacity_floor agency 守门 | Rule 1 + AC-ROBUST-03(待 `#9` 确认 capacity_warning_emitted 信号) | 待 OQ-NW-01 |
| `#8 R-NPC-2` LEFT 视觉屏蔽守门 | Rule 3 R-NW-2 + Cat 3.1 | ✓ |
| `#9 R-KPI-3` capacity_floor=0 agency | Rule 1 AC-ROBUST-03 落地 | 待 OQ-NW-01 |
| `#13 Rule 1` diegetic 元素清单 | Rule 1-5 所有渲染均委托 `#13`;`HUD_LEAVING_ARTIFACT` 待 VS scope 补充 | 待 OQ-NW-03 |
| `#6 Rule 10` 月末 KPI_REVIEW 转移 | Rule 4 倒计时清除 + I-1 | ✓ |

### 5 propagation flags

1. **`#9 KPI System`**: 需确认 `capacity_warning_emitted` 信号已在 `#9` GDD Rule 13 信号架构中定义(OQ-NW-01);同时确认 `CAPACITY_WARNING_THRESHOLD` 常量 owner 归属(`#9` or `#19`)
2. **`#13 HUD Diegetic`**: 需确认 `HUD_LEAVING_ARTIFACT`(VS scope 纸箱 diegetic 元素)在 `#13 Rule 1` VS scope 清单中预留(OQ-NW-03)
3. **`#10 Event Script`**: `warning_npc_prediction_hint` 订阅协议须在 `#10` GDD 明确注册 `inject_event_hint` API 或信号订阅路径(OQ-NW-04)
4. **`#6 Scene & Day Flow`**: `scene_state_changed` payload schema 中需包含 `days_remaining_in_month` 字段(OQ-NW-02)

---

## Section G — Tuning Knobs

### 4 类预警阈值

| Knob | 类别 | 推荐值 | 安全范围 | 影响 |
|------|------|--------|---------|------|
| `CAPACITY_WARNING_THRESHOLD` | gate | 0.7 | [0.5, 0.85] | capacity_floor 预警触发时机;越高玩家越早感知危险,越低预警越晚(接近实际 GAME OVER) |
| `THRESHOLD_CAPACITY_RATIO_WARN` | gate | 1.2 | [1.1, 1.5] | 阈值/产能比超多少时触发;配合 `CAPACITY_WARNING_THRESHOLD` 双重过滤,防过早预警 |
| `EFFORT_EXTREME_THRESHOLD` | gate | 0.75 | [0.6, 0.9] | effort_norm 超此值触发便利贴密集 variant;越低玩家看到预兆越频繁(fatigue risk) |
| `BURNOUT_WARNING_ENERGY` | gate | 15 | [10, 25] | 与 `#7 ENERGY_OVERTIME_MIN = 15` 对齐(建议保持一致);可独立调至 20 给玩家更早视觉提醒 |
| `MONTH_COUNTDOWN_START_DAYS` | gate | 3 | [2, 5] | 月末倒计时起始天数;越大玩家准备窗口越长,但日历红边出现太早失去张力 |
| `MAX_PREDICTION_HINTS_PER_MONTH` | feel | 1 | [1, 2] | 每月最多 NPC 预言 hint 次数;推荐锁死为 1 防 hint 泛滥削弱惊喜感 |

### Visual/Audio Ownership

**零 Visual/Audio ownership** —— `#19` 是纯信号中继层。所有视觉资产(显示器红线 variant / 便利贴密集态 / NPC 冷淡 variant / 日历红边 / 咖啡杯深色阶)由 `#13 HUD Diegetic` + art-director own。所有音频资产由 `#4 Audio Manager` own(预警触发的 ambient 微调如有,走 `#4 Rule 6` 场景 ambient schema,不由 `#19` 直接触发)。

**📌 UX Flag**: Phase 4 须运行 `/ux-design design/ux/warning-system.md` —— 指定 4 类预警的 diegetic 视觉规格(色阶 / variant 阈值 / NPC 冷淡 sub-variant 定义 / 日历红边粗细渐变),与 art-bible §4.1 色彩警戒语义对齐。

---

## Open Questions

**OQ-NW-01**: `#9 KPI System` 当前 GDD 中 `capacity_warning_emitted` 信号是否已声明?若 `#9 Rule 13` 信号架构未定义此信号,本 GDD Rule 1 的 hard dependency 断裂。建议选项:(a) `#9` 下次 review 时补充此信号至 `#9 Rule 13`;(b) 改为 `#19` 直接轮询 `#9` query API(`get_capacity_now()` + `get_threshold_now()`)而非信号推送。推荐方案 (a)。Owner: `#9` GDD author。

**OQ-NW-02**: `#6 scene_state_changed` payload 是否包含 `days_remaining_in_month` 字段?当前 `#6 Rule 9` 描述 payload 未显式列出此字段。方案:(a) `#6` 补充字段至 payload schema —— 最简洁;(b) `#19` 自行维护 `current_day_counter` 订阅 `#6` game-time tick —— 更独立但多了状态维护。推荐方案 (a)。Owner: `#6` GDD author 确认 payload schema。

**OQ-NW-03**: `HUD_LEAVING_ARTIFACT`(NPC 离职预兆纸箱 diegetic 元素)是否在 `#13 Rule 1` diegetic 元素清单 VS scope 中预留?当前 `#13 Rule 1` 仅列 8 个 MVP 元素,VS 扩展为"12+ 元素"未具体列出。建议在 `#13` 下次 review 时将 `HUD_LEAVING_ARTIFACT` 加入 VS scope 清单,确保 art-director 资产规格同步。Owner: `#13` GDD author + art-director。

**OQ-NW-04**: `warning_npc_prediction_hint` → `#10 Event Script` 注入协议的具体 API 形态?当前 `#10 GDD` 未定义接受预警 hint 注入的 API。选项:(a) `#10` 暴露 `inject_event_hint(hint_type: StringName, npc_id: NpcId, priority: int)` API;(b) `#19` emit 信号,`#10` 订阅并内部判断。推荐方案 (b)(保持 `#19` 无外部 API 调用的纯信号架构)。Owner: `#10` GDD author 确认信号订阅协议。

---

## Section H — Acceptance Criteria

14 AC / 4 categories + 2 [RISK GUARD]。

### AC-FUNC — 功能正确性

**AC-FUNC-01**: capacity_floor 预警触发
- Given: `#9` emit `capacity_warning_emitted(month_index=9, capacity_now=0.65, threshold_now=200)`
- When: `#19` 接收信号
- Then: `warning_capacity_critical(severity=1, month_index=9)` 在 ≤ 1 帧内 emit 给 `#13`

**AC-FUNC-02**: capacity_floor 预警不重复 emit
- Given: `_active_warnings["capacity_critical"] == true`(已激活)
- When: `#9` 同月再次 emit `capacity_warning_emitted(severity=1)`
- Then: `#19` 不重复 emit `warning_capacity_critical`;`#13` visual variant 不重复触发

**AC-FUNC-03**: effort 极值预警触发与清除
- Given: `#7 effort_norm` 月内累计达 0.76(超 `EFFORT_EXTREME_THRESHOLD=0.75`)
- When: `effort_dimension_changed` 被 `#19` 接收
- Then: `warning_effort_extreme(0.76)` emit ≤ 1 帧;月末 summary push 后 `warning_effort_extreme_cleared` emit

**AC-FUNC-04**: NPC 离职预兆触发
- Given: `#8` emit `npc_lifecycle_changed(LISA, ACTIVE, LEAVING_ANNOUNCED, "lisa_quit_better_offer")`
- When: `#19` 接收
- Then: `warning_npc_leaving(LISA)` emit ≤ 1 帧;`_active_warnings["npc_leaving_LISA"] == true`

**AC-FUNC-05**: NPC 离职预兆解除
- Given: `warning_npc_leaving(LISA)` 已激活
- When: `#8` emit `npc_lifecycle_changed(LISA, LEAVING_ANNOUNCED, LEFT, ...)`
- Then: `warning_npc_leaving_resolved(LISA)` emit;`_active_warnings["npc_leaving_LISA"] == false`

**AC-FUNC-06**: 月末倒计时 3/2/1 档各自独立触发
- Given: `scene_state_changed` payload `days_remaining_in_month` 分别为 3 / 2 / 1
- When: `#19` 接收各自 sub-mode 转移信号
- Then: `warning_month_end_countdown(3)` / `(2)` / `(1)` 各自 emit;无重复 emit

**AC-FUNC-07**: 月末倒计时进入 KPI_REVIEW 时清除
- Given: `warning_month_end_countdown` 活跃
- When: `scene_state_changed(→KPI_REVIEW)`
- Then: `warning_month_end_cleared` emit;`_active_warnings["month_countdown"] == false`

**AC-FUNC-08**: burnout 预警触发
- Given: `#7` emit `energy_changed(14, 100)`
- When: `#19` 接收
- Then: `warning_burnout_approaching(14)` emit ≤ 1 帧

**AC-FUNC-09**: GAMEOVER 时全预警清除
- Given: `warning_capacity_critical` + `warning_npc_leaving(LISA)` + `warning_month_end_countdown(1)` 同时活跃
- When: `scene_state_changed(→GAMEOVER)`
- Then: `_clear_all_warnings()` 执行;`_active_warnings` 全空;对应 `*_cleared` 信号全部 emit

### AC-ROBUST — 系统健壮性 [RISK GUARD]

**AC-ROBUST-01 [R-NW-1]**: popup 红线 CI 守门
- Given: 代码库 `src/systems/notification/` 目录
- When: CI lint 运行 `grep -r "popup\|overlay\|show_notification\|warning_sound"`
- Then: 0 命中;任何命中 = CI FAILURE,PR-blocking

**AC-ROBUST-02 [R-NW-2]**: LEFT NPC 预警 leak 防护
- Given: `#8` NPC LISA 已 `lifecycle_state == LEFT`
- When: `npc_lifecycle_changed(LISA, LEAVING_ANNOUNCED, ...)` 因 bug 重复 emit
- Then: `#19` 静默丢弃,不 emit `warning_npc_leaving(LISA)`;debug log 出现 `push_warning("[NW#19] ignoring lifecycle signal for LEFT npc: LISA")`

### AC-PERF — 性能

**AC-PERF-01**: dispatch ≤ 1 帧(16.6 ms)
- Given: 任意 `warning_*` 信号触发路径
- When: debug build `Time.get_ticks_usec()` 首尾打点
- Then: 延迟 ≤ 16600 µs;超出则 `push_warning` 出现在 debug log

### AC-TONE — Tone 守门

**AC-TONE-01**: HR 口吻词条审校通过
- Given: `#10 Event Script` 中 `warning_npc_prediction_hint` 触发的全部 NPC 台词文案(含 capacity_floor hint + 月末倒计时 3 档)
- When: writer team + narrative-director 对照 Rule 7 正例/反例表审校
- Then: 0 条文案触发"审判语气"/ "励志语义"判定;全部通过"老同事无意说的话"测试

**AC-TONE-02**: 禁 "警告!" 语义全 Run 验证
- Given: 游戏完整 Run(任意月数)
- When: QA playtest 观察所有 `warning_*` 触发路径
- Then: 无任何弹出文字包含"警告" / "危险" / "注意" / "!" 语义;diegetic 元素变化是唯一信息载体

**AC-TONE-03**: 预警无庆祝/胜利音效
- Given: 全 Run 内所有 4 类预警触发事件
- When: Audio 系统监听
- Then: 无任何 SFX/BGM 触发与 `warning_*` 信号相关联;Audio 层无 `warning_*` 信号订阅

---

*GDD End.*
