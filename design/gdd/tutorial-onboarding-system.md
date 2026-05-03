# Tutorial / Onboarding System

> **Status**: Designed (pending review)
> **Author**: huanghaibin + game-designer (Section C 10 Rules 主笔)+ systems-designer (Section C 状态机 + Section E 边界)+ narrative-director (Section B 叙事锚 + NPC 台词定性)+ qa-lead (Section H 14 AC)
> **Authoring autonomy mode**: v2 no-prompt(0 widget)
> **Last Updated**: 2026-04-28
> **Layer**: Meta | **Order**: #18 | **Size**: M | **Tier**: Vertical Slice
> **Implements Pillar**: P2 主(叙事即机制 — 引导本身是事件,不是说明书)+ P5 守(隐形引导不打断 90s 一天节奏)+ P4 守(老 NPC 不说"加油",说"我也是这么过来的")
> **Anti-P2 红线**: 禁任何 popup/tooltip/"按 X 键"/"你已解锁新功能" 教学语义

---

## Section A — Overview

### 双重身份

**技术层**: Tutorial / Onboarding System 是一个**隐形 onboarding state machine** —— `TutorialState`(Autoload 单例 sub-node 挂载于 `SceneDayFlowController`)跟踪 Day 1-3 sub-mode 触发序列和 M1 月末结算后老 NPC 评论触发协议。本系统 **owns**:
- Day 1-3 期间的预置固定手牌集(`fixed_hand_day_1/2/3: Array[StringName]` 覆写 `#11 Action Card` 默认抽牌)
- Day 1-3 期间绑定 `#10 Event Script Engine` 触发的 onboarding tier 额外 hint 事件(继承 `#10 Rule 17` 4 档预言台词池)
- M1 月末结算后 `kpi_threshold_changed` 信号触发的老 NPC "活化石"评论事件
- `tutorial_completed` flag 写入 Save(`#1 Rule 22` content-only unlock 协议)

**叙事层**: 玩家进入游戏没有任何教学菜单。Day 1 早上,手牌只有 3 张,老油条 NPC 下午路过说了句"第一天别加班"。玩家不知道这是教学,只知道这是老员工在说话。到 M1 月末结算,KPI 涨了 3%,老油条路过工位:"我第一年也是这么过来的。" 游戏从未解释 AP / KPI / 反向阈值 —— 玩家在做中学,老 NPC 给的是共情,不是说明书。

### Pillar 服务

- **P2 主 叙事即机制**: 引导事件本身就是 `#10 Event Script` 的合法事件 —— 不是特殊 tutorial 代码路径,是玩家入职第一天的叙事体验。事件文案里不出现"教学"二字
- **P5 守 地铁可玩性**: Day 1-3 固定手牌简化决策量,但不打断 90s 一天节奏。M1 月末老 NPC 评论不增加额外等待时间(在 KPI Review 结算流程内 inline 触发)
- **P4 守 黑色幽默**: 老 NPC 台词语气是"我也是这么过来的"(认命的共情),不是"你一定行"(励志支持),不是"注意这个机制"(说明书语气)

### 5 NOT 边界(scope creep 防护)

- **NOT** popup 教学弹窗 / tooltip(违反 Anti-P2 红线;本系统不 own 任何 Modal UI)
- **NOT** 高亮 + 教学箭头 / 遮罩聚焦(归 `#14 Card Play UI` 和 `#13 HUD` 的视觉层,本系统不注入"请点这里"类视觉引导)
- **NOT** 强制 tutorial 流程(玩家可通过 `tutorial_skip_flag` 完整跳过 Day 1-3 固定手牌;见 Rule 2)
- **NOT** 教学 button 提示 / "按 X 键"类文案(本系统所有引导文本通过 `#10` 事件 + Localization 传递,tone 守门同 `#10 Rule 19`)
- **NOT** 励志支持型语义(`#4 Audio` / `#5 Lighting` / `#3 Localization` 三轨 tone 守门共同适用;本系统新增 NPC 台词全部经 `#10 Rule 19` 主语翻转 lint)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 任何 `TutorialManager.show_popup(text)` / `show_tooltip()` / `highlight_node()` 类 API(违反隐形引导原则 — R-TUT-1)
- **NOT** 老 NPC 台词出现 "好好学" / "加油" / "这个功能很重要" 语义(违反 Anti-P2 — R-TUT-2)
- **NOT** Day 1-3 期间锁定玩家选择(固定手牌是"只发这几张牌",不是"禁止打其他牌";玩家主体权保持)
- **NOT** M1 月末老 NPC 评论比 KPI 结算数值更显眼(引导层不抢叙事 spotlight,KPI Review 结算仍是主轴)
- **NOT** `tutorial_completed = true` 解锁任何数值优势(违反 `#1 Save Rule 22` content-only unlock 协议 — flag 仅解锁叙事内容/NPC 对话路径,不解锁 stat)

### Source 引用

`design/gdd/game-concept.md` Pillars §P2/P4/P5 + MVP Definition(Tutorial VS tier)。`design/gdd/event-script-engine.md` Rule 17(老 NPC 预言 4 档台词池)+ Rule 19(主语翻转 lint)。`design/gdd/ap-economy-system.md` Rule 1(8 AP 基础)+ F4(effort_norm)。`design/gdd/kpi-reverse-threshold-system.md` Rule 6(M1 新手保护 γ_effective=0 + 涨幅 ≤3%)+ Rule 11(老 NPC 预言机制 kpi_prediction_hint)。`design/gdd/action-card-system.md` Rule 5(unlock 条件 + card_unlocked 信号)。`design/gdd/scene-day-flow-controller.md` Rule 4(启动序列 + 5 秒进入)+ Rule 2(SubMode enum)。`design/gdd/save-system.md` Rule 22(content-only unlock)。`design/gdd/localization-hooks.md` Rule 11(tone 三层执法)。

---

## Section B — Player Fantasy

### 主锚: "你不是来玩游戏的,你是入职的"(隐形引导)

**场景**:

Day 1,`MORNING_BRIEFING`。手牌只有三张:「整理工位」「签到打卡」「认识新同事」。你没看到任何"教程"字样,只是手牌比平时少,每张都写着入职第一天会做的事。中午,老油条路过:"第一天,别加班。AP 花完就走。"

玩家不知道这是教学事件。玩家只知道一个在这公司待了 6 年的人刚才说了这句话。他打完 3 张卡,下班。

**Pillar 服务**:
- **主 P2 叙事即机制**: "教学"是事件,事件是机制,机制即叙事。入职引导不在游戏界面外部,在游戏内部的第一天。玩家学到 AP 的存在方式不是通过弹窗,是通过行为后果(花完就走)
- **守 P5 地铁可玩性**: Day 1 手牌 3 张,AP 共 3,天然短于正常一天。玩家 Day 1 入门时间 ≤ 60 秒
- **守 P4 黑色幽默**: 老油条是认命者,不是导师。"别加班"不是建议,是经验教训的疲惫输出

**跨 GDD negative space 联动**:
- **AP Economy** "今天又只有 8 格,凑合用吧" 共振: Day 1 只有 3 格,更直白的"被发的预算"感,不解释却在做
- **Scene & Day Flow** "周一 9:17 你已经在工位上了" 共振: 引导和正式 gameplay 没有边界,入职第一天本来就是正式 gameplay

**❌ Tone 风险(必避)**:
- "新手引导" / "按 A 键打卡" / "教程完成" 等任何元层级语义
- 老油条台词:"这个系统的核心是……" / "你需要注意……"(说明书语气)
- "欢迎来到职场！" / "相信你一定能做到" 类励志开场

**✅ Tone 守护(推荐)**:
- 老油条台词语气参考: "反正就这样。" / "头几天别装" / "AP 花完就走,不用等"
- 固定手牌卡名:职场日常动词(打卡/整理/问候),不出现"学习 X 技能"类游戏化词汇

### 副锚: "老油条说'我第一年也是这么过来的'"(M1 KPI 结算后 NPC 点评)

**场景**:

M1 月末结算。`KPI_REVIEW` sub-mode 里,老油条的 NPC 事件在结算数值刷出后 1.5 秒 inline 触发。屏幕上 KPI 涨了 3%,老油条 flash 事件:"第一年都是这样。" 没有解释为什么涨,没有说"这是正常的",只是一句话——然后画面回到 KPI Review 数据面板。

Lisa(如果关系分 ≥ 20)可能在同一结算期 flash: "你看着吧。"

**Pillar 服务**:
- **P4 守 黑色幽默**: "我第一年也是这么过来的"的语义是"这没有解法",不是"但你可以做到"。这是 P4 最纯粹的 tone — 共情里包着无解
- **P2 守 叙事即机制**: NPC 月末评论是 `#10` 合法事件,有自己的 `cooldown: once_per_run` + `scene_id: KPI_REVIEW`。不是特殊渲染代码,是正式事件管线

**跨 GDD negative space 联动**:
- **KPI System** "你完成了 102%,所以下个月给你 105" 共振: NPC 评论不取代数字,只在数字之后轻轻补一刀
- **Run Meta #12** HR 评语词条 共振: 月末评语词条与老 NPC 评论同时存在,两个层面都在做"记录员语气",不是"评判者语气"

**❌ Tone 风险(必避)**:
- "小心下个月更难" / "你得改策略了"(策略建议 = 说明书 = Anti-P2)
- "但是你可以的 / 别担心"(励志 = Anti-P2 红线 R-TUT-2)
- 老油条台词超过 1 行 long 事件(M1 结算时 flash 档即可,不占过多 KPI Review 时间)

**✅ Tone 守护(推荐)**:
- "第一年都是这样。" (无主语,事务性)
- "我在的时候也是 +3%。" (具体化、无情绪)
- Lisa 版本: "你看着吧。" (预告但拒绝解释)

---

## Section C — Detailed Design

> **本节分三部分**: **10 Core Rules** + **States and Transitions** + **Interactions**
> **所有权边界**: 本 GDD owns onboarding state machine + 固定手牌集 + M1 KPI 结算 NPC 触发协议 + `tutorial_completed` flag。**UI own by `#14`**。**NPC 台词 own by `#10`**。**AP/KPI 数学 own by `#7`/`#9`**。

### Core Rules

**Rule 1 — 引导触发协议(Day 1-3 sub-mode + M1 结算后)**

`TutorialState` 维护两个引导窗口:

| 引导窗口 | 触发条件 | 退出条件 |
|---------|---------|---------|
| **Day 1-3 引导期** | `day_index ∈ {1, 2, 3}` + `tutorial_completed == false` | `day_index == 4` 时自动退出;或 `tutorial_skip_flag == true` 立即退出 |
| **M1 KPI 结算点评** | `month_index == 1` + `scene_state_changed(→KPI_REVIEW)` + `tutorial_completed == false` | M1 结算 NPC 事件 emit 完毕后,写 `tutorial_completed = true`;一次性 |

`tutorial_completed` 持久化至 Save(`#1 Rule 22` content-only unlock 协议)。Run 结束 GAME OVER 后新 Run 起点 `tutorial_completed` 继承上一 Run 值(VS 多入职路径扩展时重置,但 MVP 不重置)。

---

**Rule 2 — Day 1-3 固定手牌协议(覆写 `#11 Action Card` 默认抽牌)**

Day 1-3 引导期内,`TutorialState` 向 `#11 Action Card` 注入 `fixed_hand_override`:

| 日期 | 固定手牌卡 ID | AP 总量 | 设计意图 |
|-----|------------|---------|---------|
| Day 1 | `[FIRST_DAY_CHECKIN, SETTLE_WORKSTATION, GREET_NEIGHBOR]` | 1+1+1 = 3 AP | 最简单: 3 张 1-AP 卡,无决策压力,入职仪式感 |
| Day 2 | `[DAILY_REPORT_SIMPLE, ATTEND_MEETING, COFFEE_BREAK]` | 1+2+1 = 4 AP(8 中用 4) | 引入 2-AP 卡;有 4 AP 盈余供玩家体验早退/加班决策 |
| Day 3 | `[CROSS_DEPT_QUICK, DAILY_REPORT_SIMPLE, PRETEND_BUSY, ASK_LISA_PROGRESS]` | 2+1+1+2 = 6 AP | 引入多卡决策 + Lisa 卡(NPC 关系概念初次出现);盈余 2 AP 可加班 |

固定手牌以**追加方式**注入:Day 1-3 结束后(`day_index == 4`)时 `fixed_hand_override` 清空,回归 `#11` 默认抽牌逻辑。固定手牌卡须已 unlock(`unlock_condition = null`)。

`tutorial_skip_flag = true` 时跳过全部 Day 1-3 覆写,立即使用正常手牌池(见 Rule 9 Save 协议)。

---

**Rule 3 — Day 1-3 onboarding tier 额外事件(继承 `#10 Rule 17` 4 档预言 + 新增 `ONBOARDING` 档)**

`#10 Rule 17` 定义 4 档预言台词池:`HINT_EFFORT_HIGH` / `HINT_POTENTIAL_HIGH` / `HINT_TENURE_LONG` / `HINT_TENURE_VETERAN`。

本 GDD 新增第 5 档: **`HINT_ONBOARDING_DAY{1/2/3}`**,由 `TutorialState` 在 Day 1-3 `ACTION_DAY` sub-mode 的特定时机 emit 至 `#10 EventScriptEngine.inject_onboarding_hint(day_index)`:

| 档位 | 触发时机 | 老油条台词示例(Localization key) |
|------|---------|-------------------------------|
| `HINT_ONBOARDING_DAY1` | Day 1,≥ 1 张卡打出 + 当日 effort_norm ≤ 0.1 | `NPC.OLD_OIL.ONBOARDING_D1` — "第一天,别加班。AP 花完就走。" |
| `HINT_ONBOARDING_DAY2` | Day 2,≥ 1 张 2-AP 卡打出 | `NPC.OLD_OIL.ONBOARDING_D2` — "2 AP 的卡不一定比 1 AP 更值。" |
| `HINT_ONBOARDING_DAY3` | Day 3,手牌出现 NPC 关联卡(Lisa 卡) | `NPC.OLD_OIL.ONBOARDING_D3` — "Lisa 那张卡,打不打都有数。" |

台词均为 `flash` 档(< 3s,单行 overlay),不触发 `long` 事件。事件 `cooldown: once_per_run`。**台词不解释机制,只给行为参照**。

`#10 Rule 19` 主语翻转 lint 同样适用于所有 `NPC.OLD_OIL.ONBOARDING_*` key。

---

**Rule 4 — M1 KPI 结算 NPC 点评(老油条"活化石"评论 + Lisa "你看着吧")**

触发时机: `#9 scene_state_changed(→KPI_REVIEW)` + `month_index == 1` + `tutorial_completed == false`。

结算流程中,在 `#16 KPI Review UI` 刷出 `kpi_threshold_changed` 数值后延迟 `M1_REVIEW_NPC_DELAY_MS = 1500`ms,`TutorialState` emit `inject_m1_npc_comment()` 给 `#10`:

| NPC | 触发条件 | 台词示例(Localization key) | 事件档 |
|-----|---------|--------------------------|-------|
| 老油条(`OLD_OIL`) | 无条件(M1 必触发) | `NPC.OLD_OIL.M1_REVIEW` — "第一年都是这样。" | `flash` |
| Lisa(`LISA`) | `lisa.relationship_score >= 20` | `NPC.LISA.M1_REVIEW` — "你看着吧。" | `flash` |

两条 flash 事件按序触发(老油条先,Lisa 后,间隔 `M1_REVIEW_SEQUENTIAL_GAP_MS = 800`ms)。触发完毕后写 `tutorial_completed = true`。

**设计意图**: 两条台词合计 < 3 秒,不打断 KPI Review 主流程。**不解释反向 KPI 的数学机制** — 玩家在 M2/M3 自己发现(KPI Section B C2 觉醒弧)。

---

**Rule 5 — 隐形 vs 显式: 禁 popup / 高亮 / "按 X 键"**

本系统的全部引导行为必须满足**隐形引导三原则**:

1. **无 Modal**: 任何引导信息只能通过 `#10` flash 事件传递。禁止调用任何 Modal / overlay / dialog / tooltip 类 API
2. **无聚焦高亮**: 禁止在引导期间向 `#14 Card Play UI` / `#13 HUD` 注入"请点这里"类视觉焦点提示(箭头/脉冲高亮/遮罩)
3. **无按键提示**: 固定手牌卡文案不出现"按 [A]"/"点击 [X]" 类操作说明

违反任何一条 = R-TUT-1(popup 提示框漏入)阻断 PR。

---

**Rule 6 — P5 守: 引导期不打断 90s 一天节奏**

Day 1-3 固定手牌的 AP 总量设计约束:

| 天 | AP 总量 | 目标完成时间 |
|---|--------|------------|
| Day 1 | 3 AP | ≤ 60 秒 |
| Day 2 | 4 AP(8 AP 基础中使用 4) | ≤ 75 秒 |
| Day 3 | 6 AP(8 AP 基础中使用 6) | ≤ 90 秒 |

`flash` 事件 < 3 秒,不计入一天操作时间。M1 月末老 NPC 评论合计 ≤ 3 秒,不延长 KPI Review 结算感知时长。

---

**Rule 7 — P4 守: 老 NPC tone 原则(认命共情,不励志)**

所有 `NPC.OLD_OIL.ONBOARDING_*` 和 `NPC.OLD_OIL.M1_REVIEW` 台词文案审校时必须通过以下 tone 双测:

**测试 A — 不励志测试**: "这句话读完,玩家会想'加油打拼'吗?"
- 如果会 → 改写
- 如果不会 → 继续

**测试 B — 不说明书测试**: "这句话读完,玩家会想'哦原来这是一个机制说明'吗?"
- 如果会 → 改写
- 如果不会 → 通过

**正例**: "AP 花完就走。" ✓(行为参照,不解释机制,不励志)
**反例**: "你要合理分配 AP 以避免加班消耗精力!" ✗(说明书语气,违反 Rule 5 + R-TUT-2)
**反例**: "第一年再难也能过!" ✗(励志,违反 Anti-P2 + R-TUT-2)

CI `subject_inversion_lint.py --domain TUTORIAL_NPC` 扩展此规则(继承 `#10 Rule 19` lint 路径)。

---

**Rule 8 — 信号架构**

**TutorialState 订阅**:
- `#6 scene_state_changed(from, to)` — 监听 `MORNING_BRIEFING`(Day 1-3 手牌注入时机)+ `KPI_REVIEW`(M1 月末触发窗口)
- `#9 game_over_triggered(reason, month)` — 若 GAME OVER 在 M1 前发生,终止引导流程

**TutorialState emit**:
- `inject_fixed_hand(day_index, card_ids)` → `#11 Action Card`(固定手牌覆写)
- `inject_onboarding_hint(day_index)` → `#10 Event Script Engine`(Day 1-3 老油条 hint)
- `inject_m1_npc_comment()` → `#10 Event Script Engine`(M1 月末 NPC 点评)
- `tutorial_completed_changed(val: bool)` → 全局(供 `#1 Save` 持久化侦听)

**下游不订阅 TutorialState**: 教学系统不被其他系统订阅(单向注入)。`#11`/`#10` 接收注入后按正常事件管线处理。

---

**Rule 9 — Save Rule 22 unlock: `tutorial_completed` flag 仅 content-only**

`tutorial_completed = true` 触发以下 **content-only** unlocks(符合 `#1 Rule 22`):
- `#10` 候选池解锁 `ONBOARDING_COMPLETE_EVENT` 一次性事件(老油条 Run 内不再出现 onboarding 台词)
- `#11` 解锁 Day 4+ 标准卡库抽牌(固定手牌覆写撤销)

`tutorial_completed` **不解锁**:
- 任何 AP 上限变化 / KPI 系数变化 / 关系分加成
- 任何 HUD 新元素 / UI 新屏幕
- 违反此原则 = Anti-Pillar 1 + R-TUT-1 阻断 PR

`tutorial_skip_flag` 的 Save 写入时机: `MORNING_BRIEFING` sub-mode 触发时,若玩家通过 Settings 设置跳过(Save flag `tutorial_skip = true`),`TutorialState` 立即写 `tutorial_completed = true` + 清空固定手牌覆写。

---

**Rule 10 — Scope Tier(VS 完整 / 野心版 多入职路径)**

| Tier | 引导内容 | 要求 |
|------|---------|------|
| **VS(本 GDD)** | Day 1-3 固定手牌 + 老油条 3 天 flash hint + M1 月末老油条/Lisa 评论 | 默认实现 |
| **野心版** | 多公司类型 → 多套 Day 1-3 固定手牌池(不同行业不同"入职卡") | VS 扩展,需要 `#10` 事件库扩容 + `#11` 多套手牌 schema |
| **MVP 退路** | 若 VS tier 未能在 demo 前完成,Day 1-3 使用正常手牌池(不影响核心循环) | Tutorial 是 VS tier,不阻塞 MVP demo |

---

### States and Transitions(4 态)

| 状态 | 进入条件 | 退出条件 |
|------|---------|---------|
| `TUT_INACTIVE` | 初始(`tutorial_completed == true`) / M1 NPC 评论完毕后 | — |
| `TUT_DAY_ONBOARDING` | `day_index ∈ {1, 2, 3}` + `tutorial_completed == false` | `day_index == 4` 或 `tutorial_skip_flag == true` → `TUT_M1_KPI_PENDING` |
| `TUT_M1_KPI_PENDING` | `TUT_DAY_ONBOARDING` 退出后 + `month_index == 1` + `KPI_REVIEW` 未到 | `scene_state_changed(→KPI_REVIEW)` → `TUT_M1_KPI_ACTIVE`;或 `game_over_triggered` → `TUT_INACTIVE` |
| `TUT_M1_KPI_ACTIVE` | `scene_state_changed(→KPI_REVIEW)` + `month_index == 1` + `tutorial_completed == false` | NPC 评论序列完成 → 写 `tutorial_completed = true` → `TUT_INACTIVE` |

**特殊路径**: 若 GAME OVER 在 `TUT_M1_KPI_PENDING` 期间触发 → `#9 game_over_triggered` → `TUT_INACTIVE`(不触发 M1 NPC 评论;视为"入职即离职"叙事弧,无需补引导)。

---

### Interactions with Other Systems(6 contracts)

| # | 对端 | 方向 | 主接口 |
|---|------|------|--------|
| I-1 | `#6 Scene & Day Flow` | 订阅 | `scene_state_changed` → 驱动状态机转移 |
| I-2 | `#7 AP Economy` | 读 | `day_index` 状态判断引导期(不写 AP) |
| I-3 | `#9 KPI System` | 订阅 | `game_over_triggered` + `kpi_threshold_changed` → M1 NPC 评论触发窗口 |
| I-4 | `#10 Event Script Engine` | emit | `inject_onboarding_hint(day_index)` / `inject_m1_npc_comment()` 单向注入 |
| I-5 | `#11 Action Card` | emit | `inject_fixed_hand_override(day, card_ids)` 覆写手牌 |
| I-6 | `#1 Save System` | 写 | `tutorial_completed` / `tutorial_skip` flag 持久化 |

**下游无订阅者**: `TutorialState` 是单向注入系统,不被其他系统依赖。

---

## Section D — Formulas

**N/A**

本系统无独立数学公式。引导期行为由以下已有数学驱动:
- `M1_REVIEW_NPC_DELAY_MS = 1500`(固定延迟常量,Tuning Knob)
- `M1_REVIEW_SEQUENTIAL_GAP_MS = 800`(固定间隔常量,Tuning Knob)
- Day 1-3 AP 总量约束为设计约束常量,非动态公式
- M1 `γ_effective = 0` + 涨幅 ≤ 3% 的数学保证由 `#9 Rule 6` own;本 GDD 不重复定义

---

## Section E — Edge Cases

12 edges / 4 categories / 2 RISK GUARD

### Cat 1: Day 1-3 边界

**E-1.1 — Day 1 玩家选择加班**
场景: Day 1 固定手牌 3 AP 用尽 → `AFTER_WORK` sub-mode 触发 → 玩家尝试选择加班。
处理: `TutorialState` 不干预加班决策(Rule 2 仅注入固定手牌,不锁玩家选择)。玩家可加班,加班提供的额外手牌来自 `#11` 正常加班手牌池(非 Day 1 固定手牌)。老油条 `HINT_ONBOARDING_DAY1` 台词"别加班"是**建议而非锁定**。

**E-1.2 — Day 3 Lisa NPC 关联卡因 Lisa LEFT 灰显**
场景: `ASK_LISA_PROGRESS` 需要 `LISA.lifecycle_state != LEFT`。Day 3 概率极低出现 Lisa 离职(F3 第 1 月 ≤ 5%)。
处理: 若 Lisa 已 LEFT(极端 edge),`ASK_LISA_PROGRESS` 卡自动灰显(`#11 Rule 8` NPC LEFT 守门)。`HINT_ONBOARDING_DAY3` 不触发(hint 触发条件"手牌出现 NPC 关联卡"未满足)。引导降级,不阻断游戏。

**E-1.3 — `tutorial_completed = true` 时进入 Day 1-3**
场景: 新 Run 起点 `tutorial_completed == true`(已完成过引导)。
处理: `TutorialState` 初始化时检查 `tutorial_completed`;若为 `true`,直接进入 `TUT_INACTIVE`,不注入任何固定手牌/hint。

**E-1.4 — Day 4+ 固定手牌 cleanup 信号漏接**
场景: `day_index == 4` 时 `fixed_hand_override` 清空指令丢失。
处理: `#11 Action Card` 每次 `MORNING_BRIEFING` 时主动查询 `TutorialState.get_fixed_hand_for_day(day_index)`,若当前 `day_index > 3` 返回 `null` → 清除覆写。防御性双重检查,不依赖 emit 单一路径。

### Cat 2: 玩家跳过引导

**E-2.1 — 跳过 flag 在 Day 1 中途触发**
场景: 玩家 Day 1 进行中途在 Pause/Settings 中设置跳过引导。
处理: `tutorial_skip = true` 写入 Save → 下一个 `MORNING_BRIEFING` 时 `TutorialState` 检查 flag → 清空固定手牌覆写 + 写 `tutorial_completed = true`。当日已分发的固定手牌本次日末有效;次日起正常手牌池。老油条当日未触发的 hint 不再触发。

**E-2.2 — `tutorial_skip` flag 写入但游戏在 Day 1 崩溃重启**
场景: 玩家设置跳过后,游戏崩溃;重启时 Save 的 `tutorial_skip = true` 已持久化。
处理: 重启后 `TutorialState` 读 Save flag `tutorial_skip == true` → 初始化时直接写 `tutorial_completed = true` → 正常手牌池。与 E-1.3 路径合并处理。

### Cat 3: M1 KPI 结算 NPC 评论 race

**E-3.1 — M1 月末 GAME OVER 与 NPC 评论竞争**
场景: M1 月末结算 `potential < -0.15`(开除剧本触发)或 `threshold > capacity`(极端)。
处理: `#9 game_over_triggered` 先于 `kpi_threshold_changed` emit → `TutorialState` 订阅 `game_over_triggered` → 立即设 `m1_npc_pending = false` → `TUT_INACTIVE`。M1 NPC 评论不触发(GAME OVER 叙事接管)。此路径是"入职即离职"叙事弧。

**E-3.2 — M1 KPI Review 被玩家快速 skip**
场景: `#6 Rule 12` 允许部分结算屏 skippable;玩家快速 skip KPI Review 面板。
处理: M1 NPC 评论触发时机在 `scene_state_changed(→KPI_REVIEW)` + `1500ms` 延迟之后。若玩家 skip 触发 `scene_state_changed(KPI_REVIEW→MORNING_BRIEFING)` 时 NPC 序列尚未完成 → `TutorialState` 强制 inline 触发并立即完成(不再延迟)。保证老油条台词不被 skip 跳过。

**E-3.3 — Lisa 关系分不足 20,Lisa 评论缺失**
场景: M1 月末 `lisa.relationship_score < 20`。
处理: 仅老油条 flash 触发,Lisa 评论静默跳过。`tutorial_completed = true` 在老油条评论触发后写入。整体引导仍完整(老油条是主评论,Lisa 是可选补充)。

### Cat 4: Anti-P2 lint

**E-4.1 — ONBOARDING key 被励志台词污染**
场景: writer 提交 `NPC.OLD_OIL.ONBOARDING_D1` 含"加油,你一定行"类文案。
处理: `subject_inversion_lint.py --domain TUTORIAL_NPC` 扫描 `ONBOARDING_*` + `M1_REVIEW` key 域,命中励志词表 → CI **BLOCK PR**(R-TUT-2 守门)。writer review 第二层执法。creative-director sign-off 第三层。

**E-4.2 — 固定手牌卡文案出现元语言**
场景: Day 1-3 固定手牌卡 `text_key` 对应文案含"这是你的入门任务"/"教程中"类游戏元层级语义。
处理: `#3 Localization Rule 11` tone 三层执法 + 额外 lint 扩展 `--domain TUTORIAL_CARD_TEXT` 扫描 Day 1-3 固定手牌 card ID 列表对应 `text_key`。命中"任务/"教程/"引导/"新手"等词 → CI BLOCK PR(R-TUT-1 变体守门)。

---

### RISK GUARD

**[RISK GUARD] R-TUT-1 — popup 提示框漏入(违反隐形引导原则)**
风险: `TutorialState` 的信号触发导致任何下游 UI 系统渲染 Modal / tooltip / "请点这里"高亮覆层。
守门:
- `TutorialState` API 仅包含 `inject_fixed_hand()` / `inject_onboarding_hint()` / `inject_m1_npc_comment()` 三类,无任何 `show_ui()` / `highlight()` / `show_tooltip()` 接口
- PR review 静态检查 `TutorialState.gd` 文件内任何 UI 节点引用(禁 `$Label` / `get_node("Tooltip")` 等)
- AC-FUNC-03 专项验证:Day 1-3 全程 + M1 KPI Review 无 Modal 弹出

**[RISK GUARD] R-TUT-2 — 励志台词漏入(违反 Anti-P2)**
风险: `NPC.OLD_OIL.ONBOARDING_*` / `*M1_REVIEW` 台词含励志、正能量、策略建议语义。
守门:
- `subject_inversion_lint.py --domain TUTORIAL_NPC` CI 阻塞(第一层)
- writer review(第二层)
- creative-director sign-off(第三层,继承 `#10 Rule 19` 三层执法结构)
- AC-TONE-01 专项验证:所有 ONBOARDING key 通过 Rule 7 双测

---

## Section F — Dependencies

### Upstream(本系统的输入)

| # | 系统 | 依赖内容 | 方向 |
|---|------|---------|------|
| F-1 | `#6 Scene & Day Flow` | `scene_state_changed` 信号(MORNING_BRIEFING / KPI_REVIEW sub-mode 驱动) | 订阅 |
| F-2 | `#7 AP Economy` | `day_index` 状态(引导期判断) | 读 |
| F-3 | `#9 KPI System` | `game_over_triggered` / `kpi_threshold_changed` 信号 | 订阅 |
| F-4 | `#10 Event Script Engine` | `inject_onboarding_hint` / `inject_m1_npc_comment` 注入 API | emit→ |
| F-5 | `#11 Action Card` | `inject_fixed_hand_override` 注入 API | emit→ |

### Downstream(本系统的输出)

**无下游订阅者**。`TutorialState` 是单向注入系统,不被任何其他系统订阅或依赖。所有引导行为通过 `#10`/`#11` 的正常事件管线传递到玩家,隔离于核心循环系统。

### Visual / Audio Ownership

- **零 Visual/Audio ownership**: 本系统不持有任何视觉或音频资产
- 引导事件视觉渲染 own by `#14 Card Play UI`(flash 事件 overlay)
- 音频 own by `#4 Audio Manager`
- 所有 Localization key own by `#3 Localization Hooks`

**📌 UX Flag**: Phase 4 须 `/ux-design design/ux/onboarding-day1-day3.md` — Day 1-3 手牌呈现方式 + M1 KPI Review 内 NPC 评论 inline 位置(设计约束:不改变 KPI Review 屏结构,NPC 评论是 overlay inline 于现有屏幕,不新增专属屏幕)。

---

## Section G — Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 调优类别 | 理由 |
|------|------|-------|------|---------|------|
| `DAY1_FIXED_HAND` | Array[StringName] | `[FIRST_DAY_CHECKIN, SETTLE_WORKSTATION, GREET_NEIGHBOR]` | 1-4 张,AP 总量 ≤ 4 | Gate | Day 1 手牌组合决定"入职第一印象";过多 → 决策压力违反 P5;卡需全部 unlock_condition=null |
| `DAY2_FIXED_HAND` | Array[StringName] | `[DAILY_REPORT_SIMPLE, ATTEND_MEETING, COFFEE_BREAK]` | 2-4 张,含 ≥1 张 2-AP 卡 | Gate | Day 2 需引入 2-AP 卡概念;保持手牌总 AP ≤ 6 |
| `DAY3_FIXED_HAND` | Array[StringName] | `[CROSS_DEPT_QUICK, DAILY_REPORT_SIMPLE, PRETEND_BUSY, ASK_LISA_PROGRESS]` | 3-5 张,含 ≥1 张 NPC 关联卡 | Gate | Day 3 需包含 Lisa 卡(NPC 关系概念);保持手牌总 AP ≤ 7 |
| `M1_REVIEW_NPC_DELAY_MS` | int | 1500 | [800, 3000] | Feel | KPI 数值刷出后 NPC 评论的等待感;过短 → 叙事感丧失;过长 → 玩家等待焦虑 |
| `M1_REVIEW_SEQUENTIAL_GAP_MS` | int | 800 | [500, 1500] | Feel | 老油条→Lisa 两条 flash 的间隔感;过短 → 语义挤压;过长 → 拖拉 |
| `ONBOARDING_D1_HINT_MIN_CARDS_PLAYED` | int | 1 | [1, 2] | Gate | Day 1 老油条 hint 触发的"已打卡数"下限;= 1 表示打出第一张卡即可触发 |

---

## Section H — Acceptance Criteria

14 AC / 5 categories

### AC-FUNC(功能验证)

**AC-FUNC-01**: Day 1 启动后,手牌池仅包含 `DAY1_FIXED_HAND` 定义的 3 张卡,不含任何其他卡。
**AC-FUNC-02**: Day 3 结束后(`day_index == 4`),手牌池回归 `#11` 正常抽牌逻辑,不再包含任何 Day 1-3 固定手牌 card ID。
**AC-FUNC-03**: Day 1-3 全程及 M1 KPI Review 期间,不触发任何 Modal 弹窗 / tooltip 显示 / HUD 高亮覆层。[R-TUT-1 守门]
**AC-FUNC-04**: Day 2,玩家打出第 1 张 2-AP 卡后,老油条 `HINT_ONBOARDING_DAY2` flash 事件在 ≤ 500ms 内触发。
**AC-FUNC-05**: M1 月末 `kpi_threshold_changed` emit 后 `1500 ± 200ms`,老油条 `NPC.OLD_OIL.M1_REVIEW` flash 事件触发。
**AC-FUNC-06**: M1 月末 `lisa.relationship_score >= 20` 时,老油条 flash 后 `800 ± 200ms`,Lisa flash 触发。`lisa.relationship_score < 20` 时,Lisa flash 不触发,`tutorial_completed = true` 仍在老油条 flash 后写入。
**AC-FUNC-07**: M1 NPC 评论序列完成后,`tutorial_completed = true` 写入 Save;新 Run 重读 Save 时 `tutorial_completed` 持久化为 `true`。
**AC-FUNC-08**: `tutorial_completed = true` 的 Run,Day 1-3 不注入固定手牌,`TutorialState` 状态保持 `TUT_INACTIVE`。

### AC-RULE(规则验证)

**AC-RULE-01**: `tutorial_completed = true` 写入后,AP 上限 / KPI 系数 / NPC 关系分 无任何变化(通过 `#1 Save Rule 22` content-only 验证脚本确认 flag 仅触发白名单 content 解锁)。
**AC-RULE-02**: M1 月末 `game_over_triggered` 在 `kpi_threshold_changed` 之前 emit 时,M1 NPC 评论不触发。`TutorialState` 状态转为 `TUT_INACTIVE`。[R-TUT-1 GAME OVER 路径守门]

### AC-PERF(性能验证)

**AC-PERF-01**: 10 次 playtest 样本,Day 1 平均完成时间 ≤ 75 秒(含新手读卡文案时间;时钟从 `MORNING_BRIEFING` 起算,至 `AFTER_WORK` 止)。
**AC-PERF-02**: 老油条 flash 事件从 `inject_onboarding_hint()` 调用到 overlay 显示的延迟 ≤ 100ms(继承 `#10 Rule 20` 候选池查询 < 1ms + `#14` 渲染预算)。

### AC-TONE(体验验证)

**AC-TONE-01**: 所有 `NPC.OLD_OIL.ONBOARDING_*` + `NPC.OLD_OIL.M1_REVIEW` + `NPC.LISA.M1_REVIEW` key 台词通过 Rule 7 双测(不励志测试 + 不说明书测试)。`subject_inversion_lint.py --domain TUTORIAL_NPC` CI 通过无告警。[R-TUT-2 守门]
**AC-TONE-02**: Day 1-3 固定手牌所有 card ID 对应的 `text_key` 文案不含"教程/任务/引导/新手"等元语言词汇。`--domain TUTORIAL_CARD_TEXT` lint CI 通过。[R-TUT-1 变体守门]

---

## Open Questions

**OQ-TUT-01** — `tutorial_skip_flag` 的触发界面: Settings 屏 vs Day 1 开始前 confirm? owner: `ux-designer`, target: Phase 4 `/ux-design design/ux/onboarding-day1-day3.md`。影响: E-2.1 edge case 时序处理 + Rule 9 skip 写入时机。

**OQ-TUT-02** — 野心版多公司类型路径时,不同公司 Day 1 卡不同,是否预留 `company_type` 参数于 Rule 2 schema? owner: `systems-designer`, target: VS kickoff。影响: Rule 2 schema 扩展性 + `DAY1_FIXED_HAND` Tuning Knob 结构。

**OQ-TUT-03** — `HINT_ONBOARDING_DAY3` 触发条件"手牌出现 Lisa 卡"是基于"卡存在于手牌"还是"玩家悬停/查看 Lisa 卡"? owner: `ux-designer`, target: Phase 4 playtest。影响: E-1.2 edge case + AC-FUNC-04 前置条件精确定义。

**OQ-TUT-04** — M1 月末 NPC 评论应在 `DAILY_RECAP` sub-mode 还是 `KPI_REVIEW` sub-mode 触发? 当前设计在 `KPI_REVIEW`;但 `DAILY_RECAP` 在前,语义上"先日报,再月报"更自然。owner: `game-designer` + `ux-designer`, target: Phase 4 `/ux-design design/ux/onboarding-day1-day3.md`。影响: Rule 4 + Rule 8 信号时序 + E-3.2 skip 处理。

**OQ-TUT-05** — 若玩家第一局 M1 前被开除(R3.1 路径),下一 Run 的 `tutorial_completed` 应继承 `false`(没看到 M1 NPC 评论,引导未完整)还是写为 `true`(避免无限 Day 1-3 固定手牌循环)? owner: `game-designer`, target: pre-launch playtest。影响: Rule 1 + E-3.1 边界定义。

**OQ-TUT-06** — Day 1-3 期间 Pause 屏是否需要"(入职引导中)"小注? 当前设计: 完全无提示(隐形引导原则)。若 playtesting 发现玩家困惑("为什么今天只有 3 张牌"),是否允许 Pause 屏 passive 提示? owner: `ux-designer` + `game-designer`, target: Phase 4 playtest。影响: Rule 5 + R-TUT-1 边界定义。
