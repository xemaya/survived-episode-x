# AP Economy System

> **Status**: Designed (pending review)
> **Author**: huanghaibin + creative-director (Section B framings)+ game-designer (Section C 主笔 15 Core Rules)+ systems-designer × 2 (Section C SC-1..7 状态机/曲线 + Section E 32 edges)+ economy-designer (Section C 经济平衡 + 6 节参数评估)+ qa-lead (Section H 25 AC)
> **Last Updated**: 2026-04-26
> **Layer**: Core | **Order**: #7 | **Size**: M | **Bottleneck**: 高风险系统(per systems-index)
> **Implements Pillar**: P1 主(平庸是一种艺术 — 反向 KPI 核心载体)+ P2 守(每个 AP 包剧本)+ P5 守(地铁可玩性 90s 一天)+ P3 守(产能天花板 → GAME OVER 必然性)+ Anti-P1 红线(NOT 升职打怪)+ Anti-P2 红线(NOT 励志叙事)
> **Authoring autonomy mode**: v2 no-prompt(总 widget 数: 0,routine autopilot + 4 specialist 整合 + 1 KPI research deviation 自决修订 + 1 文件结构错位自修)
> **KPI Research deviation**: effort 三维权重 0.45/0.20/0.30(原 research 草稿 0.40/0.35/0.25,economy-designer 评估 Hero 等价加班漏洞修订;待 #9 GDD 仲裁)

## Overview

**AP Economy System** 是《活过第 X 集》的**核心机制载体** —— Pillar 1 "平庸是一种艺术" 的数学具象。每一天玩家有 **8 AP(行动点)**作为基础预算,可选择 **加班**(消耗精力换 +2 AP,单日上限 10 AP)、**准点下班**(8 AP 用尽即走)、或 **早退**(留 1-2 AP 换精力 + 风险漏事件,单日下限 6 AP)。每张行动卡消耗 1/2/3 AP,AP 在每日 `ACTION_DAY` / `ACTION_OVERTIME` sub-mode 期间被消耗,月末未必"用满"也未必"刚好" —— 玩家学会的不是"打满 8 AP",而是"在 6-10 AP 区间找当天的甜点"。

### 双重身份

**技术层**: AP Economy 是日内资源管理系统 —— 维护 `current_ap` / `current_energy` / `overtime_used_today` / `early_leave_taken_today` / `effort_accumulator_month` 5 个状态变量,emit `ap_consumed(amount)` 信号给 Scene & Day Flow #6 驱动 game-time tick(`#6 Rule 9`),emit `effort_dimension_changed(potential, hero_count, overage_count)` 信号给 KPI System #9 累积 effort 三维度(KPI Formula consumer)。**自身不计算 KPI 公式**(那是 #9 own),只供给输入信号。

**叙事层**: AP 是玩家最直接感受到的"时间稀缺" —— 每张卡选择都是"放弃了什么"(机会成本),每次加班都是"今天值得多熬两小时吗"(未来代价),每次早退都是"漏掉的事件值不值这点精力"。8 AP 不是数学游戏 —— 是 *打工人对自己每一天的核算*。

### Pillar 服务

- **P1 主 平庸是一种艺术**: AP Economy 是反向 KPI 的具体接口 —— 玩家越用力(加班 + Hero 卡),`effort_dimension` 累积越大,下月 KPI 阈值涨得越快(由 #9 公式消费)。"打满 10 AP 全都要"是甜头即毒药的具象。**Anti-Pillar 1(NOT 升职打怪)** 在此系统的红线:**禁**任何"AP 上限永久增长"路径(违反平庸艺术 — 角色变强意味着玩家预期能战胜 KPI)。
- **P5 守 地铁可玩性**: 90 秒打完一天的设计预算(早晨 15s + 4 张卡 60s + 结算 15s),由 AP 总量(默认 8)+ 平均卡耗 2 AP = 4 张卡的数学 buff 守门。AP 任意时刻可暂存 → Save Rule 7 autosave 守门。
- **P3 守 死亡是注定的**: AP Economy 提供"产能天花板"假设(`capacity(m) = base * max(1.0, 3.0 - 0.05·m)`,见 KPI research)— 工龄越长 AP 总产出能力越衰减(疲劳累积 + 信息不完全度增加),KPI 数学上必走 GAME OVER。**Anti-Pillar 2(NOT 励志叙事)** 在此红线:**禁**任何"老员工 AP 上限增加"路径。
- **P2 守 叙事即机制**: 每张卡的 AP 消耗必须包剧本(由 #11 Action Card own 文本,#7 仅 owns AP 数值);AP 用尽时 sub-mode 自动转移由 #6 emit `scene_state_changed`(由 Lighting/Audio 同步 negative space tone)。

### 5 NOT 边界(scope creep 防护)

- **NOT** 行动卡内容 / 卡剧本 / 卡互斥规则(由 #11 Action Card own,AP Economy 仅 expose `try_consume_ap(amount): bool` API)
- **NOT** KPI 阈值数学 / 反向 KPI 三维度公式(由 #9 KPI System own,AP Economy 仅 emit effort 输入信号)
- **NOT** NPC 关系数值 / flag 累积(由 #8 NPC Relationship own,AP Economy 仅在卡触发 NPC 事件时 dispatch 信号给 #8)
- **NOT** UI rendering / HUD AP 计数显示(由 #13 HUD Diegetic own,AP Economy 仅 emit `ap_changed(current, max)` / `energy_changed(current, max)` 信号)
- **NOT** sub-mode 状态机(由 #6 Scene & Day Flow own,AP Economy 仅 emit `ap_consumed` 给 #6 + 订阅 #6 `scene_state_changed` 决定 AP 是否累加)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 让 AP 充裕到玩家"每天能全都要"(违反 P1 平庸 + research C2 机会成本可见;research A1 "8 = 4×2 AP 魔方" 反模式)
- **NOT** 让加班无代价(违反 P1 反向 KPI;加班 → 精力 -X + effort_dimension 增加 → 下月 KPI 涨更快)
- **NOT** 让早退无代价(违反 P1 + P2;早退 → 留精力 + 漏事件 + flag 错过 NPC 关系)
- **NOT** 让 AP 上限永久增长(违反 Anti-Pillar 1 + P3 — 角色变强意味玩家预期能战胜 KPI)
- **NOT** 让卡选择能"回避"反向 KPI 涨阈值(research A2 "最优卡闭包" 反模式;违反 P1 + P3)

### Source 引用

`design/gdd/game-concept.md` Core Mechanics §L82-88(AP 经济系统定义)+ Pillars §L162-191(P1 平庸 + P3 死亡 + P5 地铁可玩性)+ MVP Definition §L283-292。`design/research/ap-decision-space-analysis.md` 5 判据 C1-C5 / 10 杠杆 L1-L10 / 7 反模式 A1-A7 / 5 假设 H1-H5。`design/research/kpi-reverse-threshold-formula-proposal.md` effort 三维度组成(加班 0.4 + Hero 0.35 + 超预期 0.25)+ 产能天花板模型 + GAME OVER 数学定义。`design/gdd/scene-day-flow-controller.md` Rule 9 game-time tick + Rule 10 月末触发 + 8 sub-mode enum。

## Player Fantasy

### 主锚: "今天又只有 8 格,凑合用吧"

**场景**(玩家时刻):
打开 DayTimeline,左上角刷出 8 个灰格子。你盯着今天的卡堆 — 一张 3 AP 的"对接跨部门",两张 2 AP 的"日报",一张 1 AP 的"假装在工位"。手指悬在加班按钮上,想了三秒,松开。明天还要上班。

**Pillar 服务**:
- **主 P1 平庸是一种艺术**: AP 不是英雄能力,是被发的预算 — 玩家从第一秒就被产权剥夺。8 AP 是公司的,不是玩家的
- **守 P5 地铁可玩性**: 8 个格子一眼看完(90 秒一天入场即决策)
- **守 P3 死亡是注定的**: AP 是有限的,工龄到头会衰减(产能天花板)
- **守 P2 叙事即机制**: 预算这件事本身就是叙事 — 不是数字,是日常的算计

**跨 GDD negative space 联动**:
- **Save** "下班打卡机一声嘀,锁屏下车" 共振 — 8 AP 用尽即下班,**AP 用尽 = Save 触发**,机制层与音轨层同一拍落地
- **Scene & Day Flow** "周一 9:17,你已经在工位上了" 共振 — 你不是来赚 AP 的,是来花 AP 的;AP 在你打开游戏前就已经发好

**❌ Tone 风险(必避)**:
- "你的行动力 / 你的能量 / 你的资源"(产权用词,违反"被发的"基调)
- "战略部署 8 AP / 高效利用每一格"(英雄叙事)
- "解锁更多 AP / AP 上限提升"(**违反 Anti-Pillar 1 红线** — 永远不能作为奖励)
- "充满活力 / 满血出击"(违反 P3 + P1)

**✅ Tone 守护(推荐)**:
- "今天发了 8 格"、"凑合用"、"省着点花"、"花完就走"
- "够用就行"、"剩两格就别开新坑了"
- "公司的 AP" / "今天的额度"(强调外部所有权)

### 副锚: "我怎么又把自己用空了"

**场景**(玩家时刻):
晚上 7:43,最后 1 AP 你犹豫了一下,点了"再回一个微信群"。AP 归零的那一刻没有金光,没有"今日完美"提示 — 只有打卡机那声嘀。明天 effort 槽多了一格,下个月 KPI 会涨。你看着空 timeline,想:我图什么?

**Pillar 服务**:
- **主 P1 平庸是一种艺术**: "用尽全力 = 自损" 的 felt sense — 玩家被训练出"不用满才是赢"的反英雄直觉
- **守 P4 苦中作乐黑色幽默**: 用满的瞬间没有奖励音,只有空虚
- **守 P2 叙事即机制**: 用满 → effort 累积 → 下月涨阈值,机制 = 叙事 = 黑色幽默

**跨 GDD negative space 联动**(本锚是 *铁三角第五轨机制基底*):
- **Audio** "月末打卡机不是胜利音" 机制基底直连 — Audio 拒绝庆祝,AP 让玩家**物理上**没东西可庆祝。AP 用满 = 第四轨拒绝庆祝的源头
- **Localization** `GAMEOVER.TITLE_IRONY` "恭喜晋升" 共振 — "把 8 AP 用满"在系统反馈层得到的不是"勤奋认证"而是 effort+1 的暗扣分
- **Lighting** "再苟一天" 共振 — "苟"的反义不是"赢",是"用满"
- **Scene & Day Flow** "月末像降温" 共振 — 月末降温的"成因"就是这个月连续把 AP 用满的累积

**❌ Tone 风险(必避)**:
- "完美 run / 零浪费"(违反反英雄基调,**用满恰恰是 punish**)
- "极限挑战 / 满血通关"(英雄叙事死区)
- "高效完成所有任务"(把"病"包装成美德)
- "卷王进度条 / 努力指数"(把惩罚包装成奖励 UI)

**✅ Tone 守护(推荐)**:
- "用空了 / 榨干了 / 透支"
- "图什么"、"图个啥"、"白搭"
- "明明可以早走的 / 留两格不丢人"

### Internal Design Test: 反英雄红线(每张卡每个 UI 反馈审校)

每张行动卡的 AP 消耗反馈、HUD AP 计数动画、月末 effort 累积反馈审校时,问一个问题:**"这是奖励玩家用满 AP,还是反讽玩家用满 AP?"**

- 如果反馈让玩家觉得"我打满了!好棒!"(主语 = 玩家英雄)→ 改写
- 如果反馈让玩家觉得"又把自己用空了"(主语 = 反讽自损)→ 通过

**正例**: AP 归零时无金光、无 "今日完美" 文案,只有打卡机声 + 数据屏蓝光转场(Lighting `DAILY_RECAP`)
**反例**: AP 归零时弹"高效完成今日任务!"+ effort 进度条金色动画(违反 Anti-Pillar 1 红线)

**Design test 的隐含 Pillar 服务**:这条原则是 **Anti-Pillar 1(NOT 升职打怪)的玩家 felt sense 守门** — 与 Scene & Day Flow Section B 的"主语翻转"原则同源,两条 design test 在 #7 + #6 共同 enforce Pillar 1 + P3 + P4 反英雄叙事。所有下游 GDD(#11 Action Card 卡反馈 / #15 Recap UI 数值 / #16 KPI Review 月末反馈)审校时援引此原则 + Scene Flow 主语翻转双轨守门。

### 红线:AP 上限永久增长 = 立即 PR-blocking

加班的 +2 AP 是 **债**(下次精力扣回 + effort 累积),不是 **恩**(永久解锁)。任何"AP 上限永久 +1" / "解锁第 9 AP" / "打满 100 天送一个 AP 槽" 类设计直接违反 Anti-Pillar 1 + Pillar 1 红线,Code Review 阶段 BLOCKING,GDD 审校阶段 BLOCKING。

### Source 引用

`creative-director` Section B consultation(2026-04-26)+ `design/gdd/game-concept.md` Pillar 1 + Anti-Pillar 1 + 6 GDD Player Fantasy negative space 铁三角延续 + `design/research/ap-decision-space-analysis.md` C2 机会成本可见 + L1 AP 成本分布 + A1 "8 = 4×2 AP 魔方" 反模式作为反 anchor。

## Detailed Design

本节分三部分:**15 Core Rules**(玩法行为)+ **States and Transitions**(4 态 + sub-mode 协议)+ **Interactions**(7 跨系统契约)。所有 Rule 编号被下游 GDD 引用时使用本节字面值(`Rule N`)。

### Core Rules

**Rule 1 — AP 基础配给与每日重置**

每个 `MORNING_BRIEFING → ACTION_DAY` sub-mode 转移时(由 `#6 Rule 9` dispatch),`APEconomy` 在同帧 reset:`current_ap = max_ap_today = BASE_AP_PER_DAY = 8`,清 `overtime_used_today = false` / `early_leave_taken_today = false`。`current_ap` 始终为非负整数。**精力 `current_energy` 不日重置**(跨日承接,见 Rule 7)。

**反 Anti-Pillar 1 锚**: `BASE_AP_PER_DAY` 是常量,**不是 Tuning Knob**(Rule 11 红线)。

**Rule 2 — AP cost 离散性与消耗原子操作**

行动卡 cost 为 `{1, 2, 3}` 整数集合。`#11 Action Card` 在玩家打卡时调用 `APEconomy.try_consume_ap(amount: int): bool`(Rule 9 API 契约)。成功消耗后 emit `ap_consumed(amount)` 给 `#6 Rule 9` 驱动 game-time 离散步 + emit `ap_changed(current_ap, max_ap_today)` 给 `#13 HUD`。失败时返回 `false`,UI 反馈由 `#11` 处理(AP Economy 不持有 UI 状态)。

**A1 反模式防护**(8 = 4×2 AP 魔方):AP cost 推荐分布 **40% 1-AP / 40% 2-AP / 20% 3-AP**(`#11` 卡库强制),平均 `avg_cost = 1×0.40 + 2×0.40 + 3×0.20 = 1.80 AP/卡` → 标准 8 AP 天打 ~4.4 张卡;3-AP 卡是决策锚点,迫使非均匀打牌。

**Rule 3 — 加班机制**

玩家在 `AFTER_WORK` sub-mode 期间可选"继续加班":

- **守门**: `current_energy >= ENERGY_OVERTIME_MIN = 15`(否则提示精力不足,留 `AP_OVERTIME_AVAILABLE` 态)
- 申报成功后: `max_ap_today = 10`,`current_ap += OVERTIME_BONUS_AP = 2`,精力扣减 `current_energy -= ENERGY_OT_BASE = 15`
- 月累计 `overtime_used_this_month += 1`(用于 Rule 6 effort_overtime emit)
- sub-mode 由 `#6` dispatch `AFTER_WORK → ACTION_OVERTIME`(AP Economy 不主动调 `request_transition`)
- **单日上限 10 AP**: 第二次加班申请返回 `false`(MVP 单次机制,野心版扩展 `ENERGY_OT_SLOPE` 二次项)

**P1 守 + A3 反模式防护**(加班-早退二元陷阱): 加班永远扣精力 + effort_overtime 累积代价(下月 KPI 阈值上浮),非线性递增曲线在野心版扩展时 `energy_cost_overtime = 15 + ENERGY_OT_SLOPE * (count)^2` 自动单调。

**Rule 4 — 早退机制**

玩家在 `ACTION_DAY` 期间 `current_ap` 在 [`EARLY_LEAVE_MIN_AP = 1`, `EARLY_LEAVE_REMAIN_AP_MAX = 2`] 区间时可主动申请早退(单日下限 6 AP):

- `early_leave_taken_today = true` flag 置位
- 精力 `current_energy = min(current_energy + ENERGY_EL_BASE * leave_ap_saved, MAX_ENERGY)`,其中 `ENERGY_EL_BASE = 8`,`leave_ap_saved ∈ {1, 2}` → 早退 1 AP 回 8 精力 / 早退 2 AP 回 16 精力
- **事件漏触发 flag**: emit `ap_early_leave_taken()` 信号给 `#10 Event Script`,#10 计算当日剩余事件以概率 `EARLY_LEAVE_EVENT_MISS_RATE` 标记为未触发(AP Economy 不算事件,只 emit)
- sub-mode 由 `#6` dispatch `ACTION_DAY → AFTER_WORK → DAILY_RECAP`

**A3 反模式防护补充**: 每月第 3+ 次早退收益 ×0.7 折扣(`ENERGY_EL_DECAY_AFTER_N = 3`,economy-designer 推荐),防"前 6 月攒精力第 7-12 月加班 push" dominant strategy(VS scope tier)。

**Rule 5 — AP 用尽 / 阈值 → sub-mode 转移信号**

`APEconomy` 监视 `current_ap`,在以下条件 emit 信号(**不直接调用 `#6.request_transition()`** — `#6 Rule 1` 单点 dispatch):

| 条件 | emit 信号 | `#6` 处理 |
|------|----------|----------|
| `current_ap == 0` 且 sub-mode = `ACTION_DAY` | `ap_depleted()` | 转 `AFTER_WORK`(Rule 10 准点下班) |
| `current_ap == 0` 且 sub-mode = `ACTION_OVERTIME` | `ap_depleted()` | 转 `AFTER_WORK`(已加班完毕) |
| 玩家申请早退且 `can_early_leave() == true` | `ap_early_leave_taken()` | 转 `AFTER_WORK` |

**Rule 6 — effort 三维度信号 emit 协议(反向 KPI 接口)**

AP Economy 是 `#9 KPI System` effort 维度的**唯一**数据源。effort_potential 公式(本 GDD 锁定):

```
effort_potential = 0.45 × normalize(overtime_count, MAX_MONTH_OVERTIME=20)
                 + 0.20 × normalize(hero_count,     MAX_MONTH_HERO=10)
                 + 0.30 × normalize(overage_count,  MAX_MONTH_OVERAGE=10)
```

其中 `normalize(x, max) = min(x/max, 1.0)`,加权和归一化至 `[0, 0.95]`(权重和 0.95)。

**📌 KPI Research 草稿 deviation flag**: `design/research/kpi-reverse-threshold-formula-proposal.md` §2.1 effort 推荐组成为 `0.40 / 0.35 / 0.25`(权重和 1.0)。本 GDD 修订为 `0.45 / 0.20 / 0.30`,理由:economy-designer 评估发现原权重下"4 张 Hero 卡(不加班)≈ 一次加班"(Hero 等价加班漏洞,玩家可规避精力代价),违反 P1 + Anti-Pillar 1。新权重拉开"加班是 effort 主驱动"差距,同时强化"超预期"信息博弈回报。`#9 KPI System` GDD 撰写时须复审此修订(若 #9 拒绝,本 GDD Rule 6 + Tuning Knobs 同步 revise)。

**emit 时机**(双轨):

| 信号 | 触发时机 | 接收者 |
|------|---------|--------|
| `effort_overtime_incremented(day, total)` | 加班申报成功后立即 | `#13 HUD` 实时显示;`#9` 月末拉取 |
| `effort_hero_incremented(card_id, day, total)` | `#11` 调 `report_hero_card_played(card_id)` 回调后立即 | 同上 |
| `effort_overage_incremented(card_id, day, total)` | `#9` 通过 `report_overage(card_id, kpi_delta)` 回调判断 `kpi_delta > threshold * 0.10` 后通知 AP Economy,AP Economy emit | 同上 |
| `monthly_effort_summary(month_index, effort_potential, overtime_count, hero_count, overage_count, days_worked)` | `#6 scene_state_changed(→KPI_REVIEW)` 时一次性 push | `#9 KPI System` 月末公式输入 |

**月末 reset 协议**: push `monthly_effort_summary` **之后**清零三计数器(`overtime_used_this_month` / `hero_card_played_this_month` / `overage_card_played_this_month`)。**禁止提前清零**。

**A5 反模式防护**(KPI 脱钩): AP Economy 不计算 KPI 分数,只 emit 原始计数 + 加权 potential — 公式责任完全隔离在 `#9`。

**Rule 7 — 精力(energy)管理**

`current_energy ∈ [0, MAX_ENERGY = 100]`。**跨日承接**,只受四条规则更新:

| 事件 | 变化 | Cite |
|------|------|------|
| 加班申报 | `-ENERGY_OT_BASE = 15` | Rule 3 |
| 早退申请成功 | `+ENERGY_EL_BASE × leave_ap_saved = 8 × {1,2}` | Rule 4 |
| 周末休息日(`#6` emit `weekend_rest_day`,周末两天 `ACTION_DAY` 不发生) | `+ENERGY_REGEN_PER_DAY = 30` | Rule 7 |
| `current_energy <= 0` | 强制 `burnout_flag = true`,禁加班(Rule 3 前置检查) | Rule 7 |

**Energy 月度软 cap**(VS scope tier 防御): 月末超过 `ENERGY_MONTHLY_CAP = 80` 的 Energy **不进位**到下月(截断,economy-designer 推荐),防"前 6 月攒精力" dominant strategy。MVP 阶段不实现(3 月关卡上限不需要)。

精力 emit: `energy_changed(current_energy, MAX_ENERGY)` 与 `ap_changed` 同帧 batch 给 `#13 HUD`。

**Rule 8 — AP 数值生命周期与月末重置**

| 变量 | reset 时机 | 来源 |
|------|-----------|------|
| `current_ap` / `max_ap_today` | 每日 `MORNING_BRIEFING → ACTION_DAY` | `#6 Rule 9` |
| `overtime_used_today` / `early_leave_taken_today` | 每日同上 | Rule 8 |
| `overtime_used_this_month` / `hero_card_played_this_month` / `overage_card_played_this_month` | 月末 `KPI_REVIEW` 时 push 后 | Rule 6 |
| `current_energy` | **不日重置**,跨日承接 | Rule 7 |

月末 reset **不重置精力**(A4 冷启动防护 — 玩家不能"月末花光精力,新月满血重来")。

**Rule 9 — `try_consume_ap(amount)` API 契约**

`#11 Action Card` 与本系统的**唯一消耗入口**:

```gdscript
APEconomy.try_consume_ap(amount: int) -> bool:
    # 前提检查顺序:
    # 1. amount > 0(else push_error + return false)
    # 2. current sub-mode ∈ {ACTION_DAY, ACTION_OVERTIME}(else return false)
    # 3. current_ap >= amount(else return false)
    # 成功:
    current_ap -= amount
    emit ap_consumed(amount)       # → #6 Rule 9 game-time tick
    emit ap_changed(current_ap, max_ap_today)  # → #13 HUD
    # 检查 Rule 5 条件 → 触发 ap_depleted() / ap_early_leave_taken()
    return true
```

失败时 UI 反馈由 `#11` 负责(AP Economy 仅返回 `false`,不持有 UI 状态)。

**Rule 10 — 信息不完全度(早晨预告 vs 实际)**

`MORNING_BRIEFING` sub-mode 展示当日预告(由 `#10 Event Script Engine` 提供 preview),AP Economy 在此阶段维护 `predicted_ap_demand_today: int`(由 `#10` 回调 `inject_predicted_ap_demand(int)` 注入,AP Economy 不计算预告)。

**信息命中率**: 实际 ≈ 预告 60-80%(`PREDICTION_ACCURACY_BASE = 0.70`)。命中率实现由 `#10` 负责(伪随机 + blacklist 防重 — 连续 5 天预告全准则强制第 6 天 `is_accurate = false`,保证"每周至少 1 次明显差异")。AP Economy 仅存储注入的 `predicted_ap_demand_today` 供 `#13 HUD` 展示预测格数。

**A7 反模式防护**(模板固化): 信息不完全使每日决策不可完全依赖固定模板。**A5 防护**(KPI 脱钩): 玩家在每周差异中感知自己行为对 KPI 的影响。

**Rule 11 — Pillar 1 红线: AP 上限永久增长禁令**

以下路径在 GDD 审校 + Code Review 阶段均为 **BLOCKING**:

- 任何"解锁第 9/10 AP 槽"的永久 upgrade
- 任何"打满 N 天奖励 AP 上限 +1"的成就奖励
- 任何"装备 / 道具 / buff 使 `BASE_AP_PER_DAY` 永久变为 9+"

`BASE_AP_PER_DAY = 8` 是游戏常量,**不是调参 Knob**。加班 +2 AP 是临时债不是永久上限变化。违反此规则 → 违反 Anti-Pillar 1(NOT 升职打怪)+ P3(角色变强 → 玩家预期能战胜 KPI → 必然性破坏)。

UI 文案 + `#13 HUD` AP 格视觉 + `#15 Recap` 反馈均**不得**以"解锁了更多 AP"语义呈现(配合 Section B Internal Design Test 反英雄红线 + `#6 Rule 14` 主语翻转)。

**Rule 12 — 产能天花板信号(工龄衰减)**

AP Economy 维护 `month_index: int`(每月 `KPI_REVIEW` 后 +1)。每月向 `#9` push `monthly_effort_summary` 时附带 `capacity_factor`:

```
capacity_factor(m) = max(CAPACITY_FLOOR=0.4, 3.0 - 0.05 × m)
```

`capacity_factor` 是 `#9` KPI 公式的修正输入。**AP Economy 自身不限制物理 AP 数量** — 玩家每天仍收到 8 AP,但 `#9` 的 KPI 阈值随 `capacity_factor` 衰减加速(工龄越长越难维持平庸)。

**📌 跨 GDD flag**: `CAPACITY_FLOOR = 0.4` 防止第 9-12 月双重惩罚雪球进入数学不可达域(economy-designer 评估)。`#9 KPI System` GDD 必须显式锁此 floor(若 `#9` 设计意图为 12 月必然 GAME OVER 且接受不可达,可 floor=0,但需 HUD 预警信号给玩家 agency)。

**A2 反模式防护**(最优卡闭包): 产能衰减使"找到最优打法一直复用"路径在 m 增大后失效 — 相同卡组的 KPI 对抗能力按 capacity_factor 衰减,玩家必须持续调整。

**Rule 13 — 主语翻转原则在 AP feedback 的执法**

配合 `#6 Rule 14` 主语翻转,AP Economy 所有 emit 信号 + API 返回值在语义上必须表达"AP 被用掉了"而非"玩家用了 AP":

- `ap_consumed(amount)`: 被动语态 — "被消耗了 N AP"
- `ap_depleted()`: 中性事件 — "AP 用完了"
- `ap_early_leave_taken()`: 被动事件 — "早退了"

**`#13 HUD` 审校红线**: HUD 消费上述信号后的 UI 文案,禁表达"你完成了今天的任务 / 你高效利用了所有 AP"。
- 正例: "今天的格子用完了。"(时间主语)
- 反例: "完美规划!零浪费!"(玩家英雄主语,违反 Anti-Pillar 1)

CI lint 工具 `tools/subject_inversion_lint.py` 扩展扫描 `AP.*` / `ENERGY.*` Localization key(配合 `#6 Rule 14` 层 2 lint)。

**Rule 14 — 信号架构清单**

**Emit(AP Economy → 外部)**:

| 信号 | 参数 | 订阅者 | 触发时机 |
|------|------|--------|---------|
| `ap_consumed(amount)` | `int` | `#6` (game-time tick) | 每次成功消耗 |
| `ap_changed(current, max)` | `int, int` | `#13 HUD` | 同上 |
| `energy_changed(current, max)` | `int, int` | `#13 HUD` | 精力任意变化 |
| `ap_depleted()` | — | `#6` (sub-mode 转移) | AP 归零 |
| `ap_early_leave_taken()` | — | `#6` + `#10` (事件漏触) | 早退申请成功 |
| `effort_overtime_incremented(day, total)` | `int, int` | `#13` | 加班成功 |
| `effort_hero_incremented(card_id, day, total)` | `String, int, int` | `#13` | Hero 卡打出 |
| `effort_overage_incremented(card_id, day, total)` | `String, int, int` | `#13` | 超预期判定 |
| `monthly_effort_summary(month, potential, ot, hero, ovr, days)` | 6 args | `#9 KPI System` | `KPI_REVIEW` 进入 |

**订阅(AP Economy ← 外部)**:

| 信号源 | 信号 | 处理 |
|-------|------|------|
| `#6` | `scene_state_changed(from, to)` | sub-mode 判定 + 月末 reset 触发 |
| `#6` | `weekend_rest_day` | 精力 +30 |
| `#11` | `report_hero_card_played(card_id)` API | `hero_card_played_this_month += 1` + emit |
| `#9` | `report_overage(card_id, kpi_delta)` API | 判定 + emit `effort_overage_incremented` |

**Rule 15 — Scope Tier 守门**

| Tier | AP 系统特性 |
|------|-----------|
| **MVP** | Rules 1-14 全实现 + energy 跨日承接 + 三维度 emit + 产能天花板 capacity_factor 信号 |
| **Vertical Slice** | + Energy 月度软 cap (80) + 早退月内 ×0.7 衰减 + 事件漏触发可视化提示(预告格变色)+ burnout 视觉效果 |
| **Full Vision (野心版)** | + 工龄衰减曲线可视化(capacity_factor 展示)+ 加班非线性 `ENERGY_OT_SLOPE` 二次项 + 周期性外部冲击事件破稳态(#10 own) |

MVP 必须实现 `try_consume_ap` / `ap_depleted` / `monthly_effort_summary` 全部信号协议,否则 `#9` 无法初始化。

---

### States and Transitions

AP Economy 维护 4 个内部状态(systems-designer 锁,与 `#6` sub-mode 1:1 对应):

| AP State | 含义 | `#6` sub-mode | 进入条件 | 退出条件 |
|----------|------|---------------|---------|---------|
| `AP_NORMAL` | `current_ap > 0`,`overtime_used_today = false` | `ACTION_DAY` | 日初 reset | `current_ap == 0` → `AP_OVERTIME_AVAILABLE` |
| `AP_OVERTIME_AVAILABLE` | `current_ap == 0`,`overtime_used_today = false`,玩家在 `AFTER_WORK` 决策窗口 | `AFTER_WORK`(决策悬浮) | `current_ap` 归零 | 玩家选加班 → `AP_OVERTIME_ACTIVE`;玩家放弃 → `AP_DEPLETED` |
| `AP_OVERTIME_ACTIVE` | `current_ap > 0`,`overtime_used_today = true` | `ACTION_OVERTIME` | 加班申报成功 + 精力 ≥ 15 | `current_ap == 0` → `AP_DEPLETED` |
| `AP_DEPLETED` | `current_ap == 0`,无论是否用过加班 | 触发 `#6` → `AFTER_WORK` | AP 用尽且不加班 / 加班完毕 | 次日 `ACTION_DAY` reset → `AP_NORMAL` |

**转移矩阵**(单方向,不可逆覆盖):

```
AP_NORMAL              → AP_OVERTIME_AVAILABLE  : current_ap == 0 AND overtime_used_today == false
AP_NORMAL              → AP_DEPLETED            : 非法(AP_NORMAL 时 current_ap > 0)
AP_OVERTIME_AVAILABLE  → AP_OVERTIME_ACTIVE     : try_overtime() 成功 AND energy >= 15
AP_OVERTIME_AVAILABLE  → AP_DEPLETED            : 玩家在 AFTER_WORK 选"就这样"
AP_OVERTIME_ACTIVE     → AP_DEPLETED            : current_ap == 0(加班 AP 也用尽)
AP_DEPLETED            → 任意                   : 禁止(唯一出路是次日 MORNING_BRIEFING reset)
GAMEOVER 期间           → 永久锁定               : 整体 locked = true,所有 API 返回 false
```

**状态 × sub-mode 约束矩阵**(consume API 守门):

| `#6` sub-mode | 允许 `try_consume_ap` | AP state 可达 |
|--------------|----------------------|--------------|
| `MAIN_MENU` / `MORNING_BRIEFING` / `DAILY_RECAP` / `KPI_REVIEW` / `GAMEOVER` | ❌ 禁止 | 锁定 |
| `ACTION_DAY` | ✅(`AP_NORMAL`) | → `AP_OVERTIME_AVAILABLE`(归零) |
| `AFTER_WORK` | ❌ 禁止(决策窗口) | `AP_OVERTIME_AVAILABLE` 待定 |
| `ACTION_OVERTIME` | ✅(`AP_OVERTIME_ACTIVE`) | → `AP_DEPLETED`(归零) |

---

### Interactions with Other Systems

7 跨系统契约:

| # | 对端 GDD | 信号 / API | 数据流向 | Owner |
|---|---------|-----------|---------|-------|
| I-1 | `#6 Scene & Day Flow`(Rule 9) | `ap_consumed(amount)` → game-time 离散 tick | AP Economy → `#6` | AP Economy emit |
| I-2 | `#6 Scene & Day Flow`(Rule 10) | `#6` emit `request_transition(KPI_REVIEW)` 月末触发,AP Economy 订阅 `scene_state_changed(→KPI_REVIEW)` 执行 effort 月末 push + reset | `#6` → AP Economy | `#6` own |
| I-3 | `#9 KPI System` | `monthly_effort_summary(...)` 月末 push + 实时 `effort_*_incremented` HUD 推送;`#9` 通过 `report_overage(card_id, kpi_delta)` 回调 AP Economy 累积 overage 计数 | 双向 | AP Economy emit + `#9` 回调 |
| I-4 | `#11 Action Card` | `try_consume_ap(amount): bool`(`#11` 调用);`report_hero_card_played(card_id)` API(`#11` 回调) | 双向 | `#11` 调用 / AP Economy 维护 |
| I-5 | `#13 HUD` | `ap_changed` / `energy_changed` / `ap_depleted` / `ap_early_leave_taken` / 三 `effort_*_incremented` 信号供 HUD 订阅 | AP Economy → `#13` | AP Economy emit / `#13` UI |
| I-6 | `#10 Event Script Engine` | `ap_early_leave_taken()` → `#10` 计算事件漏触发;`#10` 回调 `inject_predicted_ap_demand(int)` 注入早晨预告 | 双向 | AP Economy emit / `#10` 处理 |
| I-7 | `#8 NPC Relationship` | **零直接交互** — AP Economy 不调 `#8` API;NPC 事件由 `#11` 卡牌触发后 `#11` 调 `#8`,AP Economy 不感知 NPC 状态 | — | `#11` 桥接 |

---

### 5 项跨 GDD propagation flags(待 #9 / #10 / #11 / #13 GDD 撰写时复审)

1. **`#9 KPI System`**: effort 三维度权重 `0.45 / 0.20 / 0.30` 修订(deviation from KPI research draft `0.40 / 0.35 / 0.25`),理由 economy-designer Hero 卡等价漏洞分析。`#9` GDD 撰写时须确认采纳或反驳。
2. **`#9 KPI System`**: `CAPACITY_FLOOR = 0.4` 守门(防 9-12 月双重惩罚雪球进入不可达域)。`#9` GDD 必须显式锁此 floor 或明确"接受不可达 + HUD 预警"的设计选择。
3. **`#11 Action Card`**: 卡库须强制 AP cost 分布 40%/40%/20%(1/2/3 AP)± 5% 容忍度,违反触发 lint。Hero 卡须携带 `is_hero: true` flag,Overage 判定走 `#9` 回调。
4. **`#10 Event Script Engine`**: 早晨预告命中率 `PREDICTION_ACCURACY_BASE = 0.70`,blacklist 防重保证"每周至少 1 次明显差异",由 `#10` 负责实现。
5. **`#13 HUD`**: 主语翻转原则在 AP/Energy UI 文案的执法(Rule 13);`subject_inversion_lint.py` 扫描扩展至 `AP.*` / `ENERGY.*` Localization key。

## Formulas

5 公式 formalize(F1-F5)。所有变量 + range + worked example 完整。

### F1 — `energy_cost_overtime` 加班精力代价

```
energy_cost_overtime = ENERGY_OT_BASE + ENERGY_OT_SLOPE × (overtime_used_today_count)²
```

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `ENERGY_OT_BASE` | E_b | int | 10–25(Tuning Knob,推荐 15) | 第 1 次加班扣除精力基础值 |
| `ENERGY_OT_SLOPE` | E_s | int | 0–5(MVP 推荐 0,野心版扩展) | 二次项斜率,多次加班扩展时启用 |
| `overtime_used_today_count` | n | int | 0–1(MVP)/ 0–N(野心版) | 当日已用加班次数 |

**Output Range**: MVP 固定 **15**(单次加班);野心版 N=2 时 = 15 + 5×4 = 35 精力扣;N=3 时 = 15 + 5×9 = 60 精力扣 → 几乎单日不可三次加班(自动单调防 A3 二元陷阱)。

**Worked Example**:
- MVP: `cost = 15 + 0 × 1² = 15`。energy: 80 → 65。
- 野心版 N=2 with slope=5: `cost = 15 + 5 × 4 = 35`。能量 80 → 45 → 第二次加班代价显著高于第一次。

**Edge**: `current_energy < 15` 时 Rule 3 守门拒绝加班申请,公式不计算。

### F2 — `energy_gain_early` 早退精力收益

```
energy_gain_early = ENERGY_EL_BASE × leave_ap_saved × decay_factor(month_count)
```

其中 `decay_factor(month_count)` 月内衰减(VS scope tier):

```
decay_factor(month_count) = 1.0 if month_count <= 2 else 0.7
```

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `ENERGY_EL_BASE` | E_el | int | 5–12(Tuning Knob,推荐 8) | 每省 1 AP 回精力基础值 |
| `leave_ap_saved` | k | int | 1 或 2 | 早退留下 AP 数 |
| `month_count` | mc | int | 0–N | 本月已用早退次数 |
| `decay_factor` | δ | float | 1.0 或 0.7 | 月内累积衰减系数(MVP=1.0 always,VS 起启用衰减) |

**Output Range**: MVP `[8, 16]` 精力;VS 第 3+ 次早退 `[5.6, 11.2]`(衰减后)。

**Worked Example**:
- MVP 早退 2 AP: `gain = 8 × 2 × 1.0 = 16`。energy: 40 → 56。
- VS 月内第 4 次早退 1 AP: `gain = 8 × 1 × 0.7 = 5.6`(取整 5)。

**Edge**: `current_ap` 已 `< EARLY_LEAVE_MIN_AP = 1` 或 `> EARLY_LEAVE_REMAIN_AP_MAX = 2` 时 Rule 4 守门拒绝,公式不计算。

### F3 — `capacity_factor(m)` 工龄衰减系数

```
capacity_factor(m) = max(CAPACITY_FLOOR, BASE_CAPACITY - DECAY_RATE × m)
```

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `m` | m | int | 0–N | 当前月份 index(每 KPI_REVIEW 后 +1) |
| `CAPACITY_FLOOR` | f | float | 0.0 或 0.4(Tuning Knob,推荐 0.4) | 衰减下限,防数学不可达域 |
| `BASE_CAPACITY` | C₀ | float | 3.0(锁定,research kpi-reverse-threshold §1.4) | 月 0 时基准 |
| `DECAY_RATE` | r | float | 0.05(锁定,research §1.4) | 每月衰减斜率 |

**Output Range**: `[CAPACITY_FLOOR, 3.0]`。

| Month m | capacity_factor | 玩家感知 |
|---------|-----------------|---------|
| 0(新人) | 3.0 | 满血 — 标准玩家 KPI 输出可超 3 倍阈值 |
| 10 | 2.5 | 老员工初期 — 多自相矛盾目标显现 |
| 20 | 2.0 | 老员工 — 加班也无法显著超额 |
| 40 | 1.0 | 极限工龄 — 即使刚好达标也靠不住 |
| 52(若 floor=0.4) | 0.4 | floor — 数学保护下限 |
| 60(若 floor=0.0) | 0 | 数学不可达 — 任何 effort 无法达标 |

**Worked Example**(`#9 KPI System` 公式输入,本 GDD 仅 emit):
- m=10: `capacity_factor = max(0.4, 3.0 - 0.5) = 2.5`
- m=60 with floor=0.4: `capacity_factor = max(0.4, 3.0 - 3.0) = 0.4`(floor 守门)
- m=60 with floor=0.0: `capacity_factor = max(0.0, 0.0) = 0`(玩家 GAME OVER 必然性)

**📌 Cross-GDD Edge**: `CAPACITY_FLOOR` 决策由 `#9 KPI System` GDD 仲裁(本 GDD propagation flag #2)。MVP 推荐 `floor=0.4` + HUD 预警;野心版 12 月终局意图可设 floor=0,但需配合 HUD 预警信号给玩家 agency。

### F4 — `effort_potential` 三维度加权归一化

```
effort_potential = 0.45 × min(overtime_count / 20, 1.0)
                 + 0.20 × min(hero_count / 10, 1.0)
                 + 0.30 × min(overage_count / 10, 1.0)
```

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `overtime_count` | n_ot | int | 0–20 | 月内加班次数 |
| `hero_count` | n_h | int | 0–10 | 月内 Hero 卡打出次数 |
| `overage_count` | n_ov | int | 0–10 | 月内超预期(单卡 KPI > 阈值 10%)次数 |
| `effort_potential` | E | float | 0.0–0.95 | 月度 effort 输出(`#9` KPI 公式输入) |

**Output Range**: `[0.0, 0.95]`(权重和 0.95,故意不到 1.0 — 留 0.05 给"叙事 effort"如 NPC 关系投入,在野心版扩展)。

**Worked Examples**(典型玩家 profile):

| Profile | n_ot | n_h | n_ov | E |
|---------|------|-----|------|---|
| 躺平玩家 | 0 | 0 | 0 | 0.00 |
| 标准刚达标 | 4 | 2 | 2 | 0.45×0.20 + 0.20×0.20 + 0.30×0.20 = 0.19 |
| 卷王 | 12 | 6 | 4 | 0.45×0.60 + 0.20×0.60 + 0.30×0.40 = 0.51 |
| 用力过猛(猝死边缘) | 18 | 9 | 8 | 0.45×0.90 + 0.20×0.90 + 0.30×0.80 = 0.825 |
| 极限劳模(数学上限) | 20 | 10 | 10 | 0.95 |

**Cross-GDD Reference**: `#9 KPI System` 接收 `monthly_effort_summary` 时使用此 `E` 作为 KPI 公式输入(具体 KPI 阈值变化公式由 `#9` own — 非本 GDD 范围)。

**📌 Deviation flag**: 与 `design/research/kpi-reverse-threshold-formula-proposal.md` §2.1 草稿权重 `0.40 / 0.35 / 0.25`(和 = 1.0)不同。修订理由 economy-designer 评估(Hero 等价加班漏洞)。`#9` GDD 须复审。

### F5 — `decision_space(ap, handsize)` 决策空间组合估计

```
decision_space(ap, handsize) = C(handsize, floor(ap / avg_cost))
```

其中 `avg_cost = 1×0.40 + 2×0.40 + 3×0.20 = 1.80 AP/卡`(Rule 2 锁定分布)。

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `ap` | ap | int | 6–10 | 当日总 AP(早退 6-7 / 标准 8 / 加班 10) |
| `handsize` | h | int | 8–12 | 当日手牌数(L2 锁定,#11 Action Card own) |
| `avg_cost` | μ | float | 1.80(锁定) | 加权平均 AP/卡 |
| `floor(ap / avg_cost)` | k | int | 3–5 | 当日典型出牌数 |

**Output Range**: `[C(8,3)=56, C(12,5)=792]`,典型值 `[70, 252]` (Day 1-3 vs Day 7-14)。

**Worked Examples**(三阶段决策空间曲线,research §2.2 中段高峰):

| 阶段 | h | ap | k | C(h,k) | 说明 |
|------|---|-----|---|--------|------|
| Day 1-3(新手 flag 锁卡 30%) | 8(实际 5-6) | 8 | 4 | C(5,4)=5 ~ C(6,4)=15 | 入场低张力 |
| Day 7+(中段 flag 解锁) | 10 | 8-10 | 4-5 | **C(10,4)=210 ~ C(10,5)=252** | 核心决策窗口 |
| Day 21+(后期 + capacity 衰减) | 12 | 6-8(精力衰退) | 3-4 | C(12,3)=220 ~ C(12,4)=495 | 信息噪音 +25%,实际有效选择数下降 |

**Pillar 验证**(`#9` + `#11` GDD 撰写时复审):
- C1 非占优(research): C(10,4)=210 组合中 top-1 状态覆盖率应 < 60%
- C5 风险投射(research): 玩家 profile 在 `decision_space` 中能聚类出 ≥ 2 簇(激进 / 保守)

**Edge**: 实际可走路径数 < `C(h, k)`(因为存在卡互斥 / 前置 flag),但本公式估算上界,`#11 Action Card` GDD own 实际可达组合数。

---

### 公式与 Section C Rules 对应表

| Formula | Owner Rule | Cross-GDD consumer |
|---------|-----------|--------------------|
| F1 energy_cost_overtime | Rule 3 加班机制 | `#13 HUD` 显示精力扣减 |
| F2 energy_gain_early | Rule 4 早退机制 | `#13 HUD` 显示精力收益 |
| F3 capacity_factor(m) | Rule 12 产能天花板 | `#9 KPI System` 公式输入(monthly_effort_summary) |
| F4 effort_potential | Rule 6 effort 信号 | `#9 KPI System` 公式输入(monthly_effort_summary) |
| F5 decision_space | Rule 2 AP cost 分布 + Rule 10 信息不完全 | `#11 Action Card` GDD 卡库设计校验 + `/prototype` H1 决策熵假设 |

## Edge Cases

32 edges / 10 categories / 5 [RISK GUARD] R-AP-1..5(系统性 / 跨 GDD / 玩家可触发)。

### Cat 1: AP 边界(0 / 8 / 10 / 11+ / 负数 / 6-7 早退区间)

**1.1**: `current_ap == 0` 且 `overtime_used_today == true` → 状态必须为 `AP_DEPLETED`,`try_consume_ap` 返回 `false`。禁止通过 `AP_OVERTIME_AVAILABLE` 再次申请加班。
- Cite: Rule 3 / 状态机转移矩阵

**1.2**: `try_consume_ap(amount)` 其中 `amount <= 0` → `push_error("AP consume amount must be > 0")` + 返回 `false`。不扣 AP、不 emit 任何信号、不改变状态机。
- Cite: Rule 9 前提检查第 1 条

**1.3**: `try_consume_ap(amount)` 其中 `amount > current_ap` 且 `amount < max_ap_today` → 返回 `false`(AP 不足),不做部分扣减。
- Cite: Rule 9 前提检查第 3 条 / Rule 2

**1.4 [RISK GUARD R-AP-1]**: 任何外部路径(成就、道具、buff、debug 工具)试图将 `BASE_AP_PER_DAY` 或 `max_ap_today` 永久修改为 > 8(且 `overtime_used_today == false`) → `APEconomy` 不持有此修改权限;若因 bug 写入,`try_consume_ap` 在每日 reset 时强制 `max_ap_today = BASE_AP_PER_DAY = 8`(加班后临时 10 除外)。GDD 审校 + CI 阶段 BLOCKING。
- Cite: Rule 11 Pillar 1 红线 / Anti-Pillar 1

**1.5**: `current_ap == 7` 时玩家申请早退 → `can_early_leave()` 返回 `false`(7 不在 [1, 2] 区间)。需等到 `current_ap` 降至 1 或 2 才可触发早退。
- Cite: Rule 4

**1.6**: `current_ap == 1` 申请早退成功,同帧另一信号触发 `try_consume_ap(1)` → 若 `#6` 已 dispatch `ACTION_DAY → AFTER_WORK`,sub-mode 不在允许集 → 返回 `false`,消耗被阻断。
- Cite: Rule 9 前提检查第 2 条 / Rule 5

### Cat 2: Energy 边界

**2.1**: 加班申请时 `current_energy == 15`(恰好等于 `ENERGY_OVERTIME_MIN`) → 守门通过,扣减后 `current_energy == 0`。同帧设置 `burnout_flag = true`,后续加班申请被拒绝。当日已申请加班成功不回退。
- Cite: Rule 3 / Rule 7

**2.2**: 早退精力收益 `energy_gain_early = 16` 且 `current_energy == 90` → `min(106, 100) = 100`,截断。emit `energy_changed(100, 100)`(不溢出)。
- Cite: Rule 4 / F2 / Rule 7 `MAX_ENERGY = 100`

**2.3**: `current_energy == 0` 时尝试加班 → `burnout_flag == true`,Rule 3 守门拒绝,`#11` 渲染"精力耗尽无法加班"UI。AP 状态停在 `AP_OVERTIME_AVAILABLE`。
- Cite: Rule 3 / Rule 7

**2.4**: VS scope tier 月末 `current_energy > ENERGY_MONTHLY_CAP = 80` → 月末 `KPI_REVIEW` 时截断 `current_energy = min(current_energy, 80)`,**该截断在 `monthly_effort_summary` push 之后执行**,防影响当月 KPI 计算输入。
- Cite: Rule 7 / Rule 15 Scope Tier(VS)

**2.5**: 周末 `weekend_rest_day` emit 且 `current_energy == 75` → `min(105, 100) = 100`,截断。VS 当月早退衰减 `δ = 0.7` 仅作用于早退,不影响周末恢复。
- Cite: Rule 7 / F2

### Cat 3: 状态机 race

**3.1**: 同帧两次 `try_consume_ap(2)` 且 `current_ap == 2` → 第一次成功扣减 `current_ap = 0`,emit `ap_depleted()`;第二次检查 `current_ap >= 2` 为 `false` → 返回 `false`。GDScript 单线程逐帧串行,不存在真并发。
- Cite: Rule 9 / Rule 5

**3.2**: `ACTION_OVERTIME` sub-mode 下 `try_consume_ap(2)` 使 `current_ap` 归零同帧,且 `DAILY_RECAP` 转移信号已在队列 → `ap_depleted()` 先 emit 给 `#6`,`#6` dispatch `AFTER_WORK`;随后 `DAILY_RECAP` 不直接替换。`APEconomy` 不主动调 `request_transition`,`#6` 单点 dispatch 顺序决定。
- Cite: Rule 5 / I-1 / `#6 Rule 1`

**3.3**: `GAMEOVER` 期间(整体 `locked = true`)收到 `try_consume_ap` 调用 → 前提检查第 2 条 sub-mode 不在允许集 → 立即返回 `false`,不 emit 任何信号。
- Cite: 状态机 `GAMEOVER → 永久锁定` / Rule 9

### Cat 4: 加班 / 早退交互

**4.1**: 玩家在 `AFTER_WORK` 决策窗口精力不足(`current_energy < 15`)却选加班 → `try_overtime()` 守门返回 `false`,`AP_OVERTIME_AVAILABLE` 状态**不变**,玩家须主动选"就这样"才转 `AP_DEPLETED`。不自动触发 DAILY_RECAP。
- Cite: Rule 3 / 状态机

**4.2**: `early_leave_taken_today == true` 当日,`AFTER_WORK` 期间玩家再次触发早退申请 → `can_early_leave()` 返回 `false`。单日仅允许一次早退。
- Cite: Rule 4 / Rule 8

**4.3**: VS scope tier 月内第 2 次早退:`decay_factor = 1.0`(月内次数 ≤ 2)。第 3 次:`decay_factor = 0.7`。**`month_count` 计数器须在早退成功置位 `early_leave_taken_today` 后才 +1**,不在申请时 +1,防拒绝但计数增加的 bug。
- Cite: Rule 4 A3 防护 / F2 / `ENERGY_EL_DECAY_AFTER_N = 3`

### Cat 5: effort emit 时序 race

**5.1 [RISK GUARD R-AP-2]**: 月末 `KPI_REVIEW` 进入时序错误:若 `overtime_used_this_month` 等三计数器在 `monthly_effort_summary` push **之前**被清零 → `#9` 收到全零 effort 输入,KPI 公式计算结果错误(等同"躺平玩家")。**正确顺序: 先 push,再清零**。任何 reset 提前必须视为 P1-blocking bug。
- Cite: Rule 6 月末 reset 协议 / Rule 8 / I-3

**5.2**: `#9` 通过 `report_overage(card_id, kpi_delta)` 回调时机晚于当日 `DAILY_RECAP` → `overage_count` 累积照常处理,但 HUD 实时显示延迟至次日 `MORNING_BRIEFING` 后才更新。
- Cite: Rule 6 / I-3 / I-5

**5.3**: `capacity_factor(m)` 计算时机:须在 `monthly_effort_summary` push 时使用**当月 `month_index`**,而非 push 后的新值。`month_index` 递增须在 push **之后**。
- Cite: Rule 12 / F3 / `month_index` 更新顺序

### Cat 6: 跨 sub-mode 边界

**6.1**: `KPI_REVIEW` sub-mode 期间 `try_consume_ap` 调用 → 前提检查第 2 条拒绝,返回 `false`。月末计算期间 AP 状态冻结,三计数器已被 push 后清零,不可再累积。
- Cite: Rule 9 / 状态机 × sub-mode 约束

**6.2**: 月末 `KPI_REVIEW` reset 与次日 `MORNING_BRIEFING → ACTION_DAY` reset 同帧触发 → `APEconomy` 订阅 `scene_state_changed(→KPI_REVIEW)` 先执行月末 push + 计数器 reset;订阅 `scene_state_changed(→ACTION_DAY)` 后执行日 reset `current_ap = 8`。两次 reset 顺序由 `#6` dispatch 顺序决定,以"先收到先处理"执行。
- Cite: Rule 8 / I-2 / `#6 Rule 9` / `#6 Rule 10`

### Cat 7: 反模式具体 edge 触发点

**7.1 — A1 "8 = 4×2 AP 魔方"**: 若 `#11` 卡库实际分布偏离 40/40/20 超过 ±5%(如 60% 2-AP 卡) → `avg_cost` 偏离 1.80,`decision_space(8, handsize)` 中 `k = floor(8/avg_cost)` 变为均匀,张力坍缩。`#11` GDD lint 须覆盖此边界。
- Cite: Rule 2 A1 防护 / F5 / propagation flag #3

**7.2 — A2 "最优卡闭包"**: 月份 `m >= 20` 时 `capacity_factor = 2.0`,固定 Hero 卡组的 `effort_potential` 贡献衰减。若 `#9` 未正确使用 `capacity_factor` 修正 KPI 阈值,玩家固定卡组仍有效 → A2 未被 F3 实际防护。须在 `#9 KPI System` GDD 明确 `capacity_factor` 作用位置。
- Cite: Rule 12 / F3 / F4 / propagation flag #2

**7.3 — A4 "前置冷启动"**: Day 1-3 `#11` flag 锁卡 30% → `handsize` 实际 5-6,`decision_space(8, 5) = C(5,4) = 5`。若同日 `MORNING_BRIEFING` 预告命中率 100%(blacklist 防重未触发) → A4 + A7 双反模式叠加。`#10` blacklist 防重须从第 1 天起生效。
- Cite: Rule 10 / F5 / propagation flag #4

**7.4 — A6 "叙事装饰化"**: 玩家跳过 `MORNING_BRIEFING` 剧本直接进 `ACTION_DAY` → `predicted_ap_demand_today` 已由 `#10` 注入,HUD 显示预测格不依赖剧本展示。AP Economy 不感知玩家是否观看剧本(A6 在 `#11` / `#10` GDD 处理)。
- Cite: Rule 10 / I-6 / 5 NOT 边界

### Cat 8: 跨 GDD race

**8.1**: `#11` 调 `try_consume_ap(amount)` 与 `#9` 同帧 `report_overage(card_id, kpi_delta)` 回调 → `try_consume_ap` 先执行(AP 减少 + emit `ap_consumed`),`report_overage` 后执行。两者不共享同一状态变量,无竞争冲突。但 HUD `#13` 须在同帧内处理两个不同信号更新,须验证信号 batch 不丢失。
- Cite: I-3 / I-4 / I-5 / Rule 14

**8.2**: `#10` 早退漏事件计算与 `#13` HUD AP 格动画同帧响应 `ap_early_leave_taken()` → Godot 信号多播按连接注册顺序。若 `#10` 漏触发计算耗时 > 1 frame,可能导致 HUD 在事件计算未完成时已显示早退结果。须确认 `#10` 漏触发计算在 `AFTER_WORK` 内同步完成或 HUD 展示延迟至 `DAILY_RECAP`。
- Cite: Rule 4 / Rule 14 / I-5 / I-6

### Cat 9: Pillar 1 红线触发场景

**9.1**: Godot 编辑器 Inspector 直接修改 `APEconomy.BASE_AP_PER_DAY = 9` → 该变量须声明为 GDScript `const` 而非 `var`,编辑器无法修改 `const`。若实现为 `@export var` 则违反 Rule 11 红线。
- Cite: Rule 11 / Rule 1

**9.2**: 成就系统或外部事件尝试调用假设的 `APEconomy.unlock_ap_slot()` API → 该 API 不存在于 `APEconomy` 公开接口。任何 PR 引入此签名触发 Code Review BLOCKING。GDScript 接口须 lint 断言文档化禁止 API 列表。
- Cite: Rule 11 / 5 NOT 红线第 4 条

### Cat 10: 玩家行为 edge

**10.1**: 玩家在 `ACTION_DAY` 强制 Alt+F4 / 进程 kill → Save Rule 7 autosave 以 AP 消耗为触发点,最后一次 `ap_consumed` 后的 save 包含最新 `current_ap`。次日 load 时 `#6` 次日 `MORNING_BRIEFING → ACTION_DAY` reset 覆盖 `current_ap = 8`,日内 AP 无持久化问题。**`current_energy` 跨日承接须在 autosave 中持久化**。
- Cite: Rule 7 / Rule 8 / Save Rule 7

**10.2 [RISK GUARD R-AP-3]**: 玩家在 `current_ap = 1` 时申请早退成功(emit `ap_early_leave_taken()`,`early_leave_taken_today = true`),同帧另一路径(如 `#11` 缓冲队列卡触发)调用 `try_consume_ap(1)` → 若 `#6` 已在同帧完成 `ACTION_DAY → AFTER_WORK` dispatch,sub-mode 判定失败 → 返回 `false`。若 `#6` dispatch 延迟一帧,sub-mode 仍为 `ACTION_DAY`,`current_ap = 1 >= 1` 成功扣减 → `current_ap = 0`,AP 状态进入 `AP_DEPLETED`,早退已置 flag 但 AP 又归零。**需明确 `ap_early_leave_taken()` emit 与 `#6` sub-mode 切换的帧内顺序保证**(同帧同步 `call_deferred` 链)。
- Cite: Rule 4 / Rule 5 / Rule 9 / I-1

**10.3 [RISK GUARD R-AP-4]**: `#10` blacklist 防重失效场景:游戏 save load 后 `blacklist` 未从 save 恢复(遗漏序列化) → 已命中的预告条目重新进入候选池,连续 5 天预告全准概率大幅上升,"每周至少 1 次差异"目标失败 → A7 模板固化 + A5 KPI 脱钩感知丢失。`#10 Event Script Engine` GDD 须将 `blacklist` 列入持久化字段。
- Cite: Rule 10 / propagation flag #4 / A7 / A5

**10.4 [RISK GUARD R-AP-5]**: `capacity_factor` floor 失效场景:若 `#9 KPI System` GDD 未显式锁定 `CAPACITY_FLOOR = 0.4`(采用 floor=0) → m≥60 时 `capacity_factor = 0`,任何 `effort_potential` 乘以 0 导致 KPI 输出 0 或不可达,玩家无论任何操作均 GAME OVER(双重惩罚雪球进入数学不可达域)。AP Economy emit 的 `capacity_factor` 须附带 HUD 预警信号给玩家 agency。**propagation flag #2 未 resolved 期间以 `floor=0.4` 为实现默认值**。
- Cite: Rule 12 / F3 / propagation flag #2 / A3

---

### 5 [RISK GUARD] 索引

| ID | 位置 | 风险类型 | 守 Pillar | Section H 守门 |
|----|------|---------|---------|---------------|
| R-AP-1 | Edge 1.4 | AP 上限永久增长 → 违反 Pillar 1 红线 + Anti-Pillar 1 | P1 主 / Anti-P1 | AC-ROBUST-01 |
| R-AP-2 | Edge 5.1 | 月末计数器提前清零 → KPI 公式输入全零 | P3 / 数学正确性 | AC-ROBUST-02 |
| R-AP-3 | Edge 10.2 | 早退 + 同帧消耗 race → AP 状态不一致 | P1 / 一致性 | AC-ROBUST-03 |
| R-AP-4 | Edge 10.3 | `#10` blacklist 未持久化 → 模板固化 + KPI 因果感知丢失 | P1 / P2 | AC-ROBUST-04 |
| R-AP-5 | Edge 10.4 | `capacity_factor` floor 失效 → 玩家丧失 agency | P3 / 玩家信任 | AC-ROBUST-05 |

## Dependencies

### Upstream Dependencies

| GDD | 关系 | 状态 | 提供 |
|-----|------|------|------|
| `#6 Scene & Day Flow Controller` | Hard | Designed pending review | sub-mode 状态机 + `scene_state_changed` dispatch + `weekend_rest_day` 信号 + 月末 `KPI_REVIEW` 触发 + GAMEOVER 锁定;AP Economy 全部 sub-mode-dependent 行为依赖此 |

**注**: AP Economy *自身不直接 emit 给 #1 Save System*,但 AP / Energy / 三计数器 / month_index 全部数据由 Save Rule 7 autosave 持久化(Save 是 transitive 依赖,通过 `#6` 间接调度)。本 GDD 不显式列 Save 为 upstream — 持久化是 Save 主动 snapshot 模式,AP Economy 是被动 owner。

### Soft Dependencies(双向 — `#7` emit + 接收方回调)

| GDD | 关系 | 状态 | 双向接口 |
|-----|------|------|---------|
| `#9 KPI & Reverse Threshold System ⭐` | Hard | Not Started | **#7 → #9**: `monthly_effort_summary(month, potential, ot, hero, ovr, days, capacity_factor)` 月末 push;`effort_*_incremented` 实时 HUD 推送。**#9 → #7**: `report_overage(card_id, kpi_delta)` 回调判定超预期 |
| `#11 Action Card System` | Hard | Not Started | **#11 → #7**: `try_consume_ap(amount): bool` API 调用 + `report_hero_card_played(card_id)` 回调。**#7 → #11**: 仅返回 bool,无主动 emit |
| `#10 Event Script Engine ⭐` | Hard | Not Started | **#7 → #10**: `ap_early_leave_taken()` emit。**#10 → #7**: `inject_predicted_ap_demand(int)` 注入早晨预告 |

### Downstream Dependents(13 系统,本 GDD 接口被消费)

| # | System | 关系 | 主要接口 |
|---|--------|------|---------|
| 8 | NPC Relationship System | **零直接** | `#7` 不调 `#8` API;NPC 事件由 `#11` 卡牌触发后 `#11` 调 `#8`,`#7` 不感知 NPC 状态 |
| 9 | KPI & Reverse Threshold System ⭐ | Hard 双向 | `monthly_effort_summary` 月末 push 是 KPI 公式唯一 effort 输入;`#9` 通过 `report_overage` 回调累积 |
| 10 | Event Script Engine ⭐ | Hard 双向 | `ap_early_leave_taken` 漏事件触发 + `inject_predicted_ap_demand` 早晨预告注入 |
| 11 | Action Card System | Hard 双向 | `try_consume_ap` 主入口 + Hero 卡回调 |
| 12 | Run Meta System | Soft | `monthly_effort_summary` 间接 — Run 摘要展示历史 effort 累积值(Run Meta own 跨局存储) |
| 13 | HUD System (Diegetic) | Hard | 订阅 `ap_changed` / `energy_changed` / `ap_depleted` / `ap_early_leave_taken` / 三 `effort_*_incremented` 共 7 信号 |
| 14 | Card Play & Dialogue UI | Soft | 间接通过 `#11` —— Card UI 显示 AP cost,玩家点卡触发 `#11` 调 `try_consume_ap` |
| 15 | Daily / Weekly Recap UI | Hard | 订阅 `ap_changed` / `energy_changed` 显示当日 AP 用度;周报展示 effort 三维度累积 |
| 16 | KPI Review & Game Over UI | Hard | 间接 — 由 `#9` 公式输出驱动 KPI 阈值显示,但 effort 输入来自 `#7` 的 `monthly_effort_summary` |
| 17 | Main Menu / Pause / Settings UI | **零直接** | Settings 不暴露 AP/Energy/effort 调整(防玩家篡改 Pillar 1 红线);`#7` 状态在 Main Menu 显示由 `#13` 间接 |
| 18 | Tutorial / Onboarding System (VS) | Hard | 订阅 `ap_consumed` / `effort_*_incremented` 用于教学时机触发(Day 1-3 隐形引导) |
| 19 | Notification & Warning System (VS) | Hard | 订阅 `effort_overtime_incremented` 在月末 effort > 1.5x 时触发 KPI 预警 HUD 信号(R-AP-5 玩家 agency 守门) |
| 20 | Accessibility Options (Alpha) | Soft | 通过 `#13` HUD 订阅;Accessibility 选项 *不可* 修改 AP/Energy 数值规则(Pillar 1 红线) |

### 双向一致性 cross-check(本 GDD 须在 #6 Approved 后复审)

| `#6 Scene & Day Flow` 内反向声明 | 本 GDD Section C Rule | 一致性 |
|----------------------------------|----------------------|--------|
| #6 Rule 9 game-time tick 由 `ap_consumed` 离散事件驱动 | Rule 9 emit `ap_consumed` | ✓ |
| #6 Rule 10 月末 `KPI_REVIEW` 触发 + `action_lockout_started` | Rule 6 月末 push + Rule 5 `ap_depleted` | ✓ |
| #6 Section A 8 sub-mode enum | Rule 1 + Rule 9 sub-mode 守门 + 状态机 × sub-mode 矩阵 | ✓ |
| #6 Rule 13 Modal stack 协调 | 间接 — `try_consume_ap` 在 modal 期间由 `#11` 阻塞,`#7` 不感知 modal | ✓ |
| #6 Rule 5 `soft_pause_requested` | 间接 — `#7` 不订阅(精力跨日承接,pause 期间无 AP 消耗) | ✓ |
| #6 Section A `#7 AP Economy` 列为 dependents | systems-index #7 → #6 列依赖 | ✓ |

### 5 条未设计 GDD propagation 要求(已在 Section C 末尾,本 Section F 重述)

详见 Section C "5 项跨 GDD propagation flags" 段。撰写下游 GDD 时**必查**:

1. `#9 KPI System`: effort 三维权重 `0.45/0.20/0.30` 复审 + `CAPACITY_FLOOR = 0.4` 锁
2. `#11 Action Card`: AP cost 分布 40/40/20 ± 5% lint + `is_hero` flag
3. `#10 Event Script`: 早晨预告命中率 70% + blacklist 防重 + `inject_predicted_ap_demand` API
4. `#13 HUD`: 主语翻转 lint 扩展至 `AP.*` / `ENERGY.*` Localization key
5. `#16 KPI Review UI`: 显示 effort 三维 + capacity_factor 当月值(玩家 agency 信号 R-AP-5 守门)

### 6 条跨 GDD revise 影响清单

本 GDD 锁定后,若任一下列条目修订,须 propagate 至 #7:

1. `#6 Rule 9` game-time tick 协议变更 → Rule 9 emit `ap_consumed` 同步
2. `#6 Rule 10` 月末触发条件变更 → Rule 6 月末 push 时机同步
3. `#6 Section A` 8 sub-mode enum 变更 → Rule 1 + 状态机 × sub-mode 矩阵同步
4. `#9 KPI System` `CAPACITY_FLOOR` 决策(0 vs 0.4) → F3 默认值 + Rule 12 同步
5. `#9 KPI System` effort 权重决策(采纳 vs 反驳 0.45/0.20/0.30) → Rule 6 + F4 同步
6. `#11 Action Card` AP cost 分布修订 → Rule 2 + F5 `avg_cost` 同步

### Registry referenced_by 应增更新(Phase 5b)

本 GDD 须 add 至以下 constants 的 `referenced_by`:
- `meta_settings_debounce_ms` (Save source) — 不消费(Settings 不暴露 AP knob,Pillar 1 红线)
- `final_transition_duration_ms` (Save source) — 不消费(GAMEOVER 时 AP 永久锁定,无 transition timing 依赖)

**实际无 registry referenced_by 添加** — AP Economy 与现有 12 constants 无引用关系。**新注册候选**(Phase 5b decision):

| 候选常量 | 值 | 跨系统消费? | 是否 registry 注册 |
|---------|-----|------------|-------------------|
| `BASE_AP_PER_DAY = 8` | 8 | ❌ 仅 #7 own,Pillar 1 红线锁,常量非 knob | **不注册**(internal) |
| `OVERTIME_BONUS_AP = 2` | 2 | ❌ 仅 #7 own | 不注册 |
| `MAX_AP_DAILY = 10` | 10 | ❌ 仅 #7 own | 不注册 |
| `EARLY_LEAVE_MIN_AP = 1` / `EARLY_LEAVE_REMAIN_AP_MAX = 2` | 1, 2 | ❌ 仅 #7 own | 不注册 |
| `MAX_ENERGY = 100` | 100 | ✅ #13 HUD 显示,#15 Recap | **注册**(候选 — 待 Phase 5b 与 #13 GDD 协调时) |
| `ENERGY_OT_BASE = 15` / `ENERGY_EL_BASE = 8` / `ENERGY_REGEN_PER_DAY = 30` | — | ❌ 仅 #7 own(Tuning Knob) | 不注册 |
| `CAPACITY_FLOOR = 0.4` | 0.4 | ✅ `#9 KPI System` 必读 | **注册**(候选 — 待 #9 GDD 撰写时) |
| `effort 三维权重 0.45/0.20/0.30` | — | ✅ `#9 KPI System` 必读 | **注册**(候选 — 待 #9 GDD 撰写时;若 `#9` 反驳则 revise) |
| `MAX_MONTH_OVERTIME = 20` / `MAX_MONTH_HERO = 10` / `MAX_MONTH_OVERAGE = 10` | — | ✅ `#9` + `#11` + `#13` 跨系统消费 | **注册**(候选,Phase 5b) |
| `PREDICTION_ACCURACY_BASE = 0.70` | 0.70 | ✅ `#10 Event Script` 必读 | **注册**(候选,Phase 5b) |

Phase 5b 实际 register 决策延至 #9 / #10 / #11 / #13 GDD 撰写时(避免过早注册导致引用方未确定)。**MVP 阶段 Phase 5b 仅注册 0 新 constant**(本 GDD 无现成跨系统强一致常量),所有 candidates 标记 `pending_consumer_gdd`。

## Tuning Knobs

### 锁定常量(Pillar 1 红线,**不是 knob**)

| 常量 | 值 | 单位 | 红线锁定理由 |
|------|-----|------|-------------|
| `BASE_AP_PER_DAY` | 8 | int | Pillar 1 + Anti-Pillar 1 — 永远不可作为奖励增长(Rule 11) |
| `OVERTIME_BONUS_AP` | 2 | int | 加班是临时债不是永久 — 单日封顶 10 AP(Rule 3) |
| `MAX_AP_DAILY` | 10 | int | 单日 AP 物理硬上限(基础 8 + 加班 2) |

### Internal Numeric Knobs(本 GDD own)

| Knob | 默认值 | 单位 | 安全范围 | 影响 / 行为 | Cite |
|------|-------|------|---------|------------|------|
| `ENERGY_OT_BASE` | 15 | 精力 | 10-25 | 第 1 次加班扣除精力基础值;低于 10 加班无痛(违反 A6),高于 25 强迫早退(违反 L5 可选) | F1 / Rule 3 |
| `ENERGY_OT_SLOPE` | 0(MVP)/ 5(野心版) | 精力 | 0-5 | 二次项斜率,多次加班扩展时启用 | F1 / 野心版 |
| `ENERGY_EL_BASE` | 8 | 精力/AP | 5-12 | 早退每省 1 AP 回精力;低于 5 无诱惑,高于 12 早退必选(违反 C2) | F2 / Rule 4 |
| `ENERGY_REGEN_PER_DAY` | 30 | 精力/天 | 20-40 | 周末单日自然回精;低于 20 长期枯竭,高于 40 周末单日满(削弱攒精决策) | Rule 7 |
| `MAX_ENERGY` | 100 | 精力 | 80-120 | 精力上限;低于 80 老员工长期不足,高于 120 攒精无意义 | Rule 7 |
| `ENERGY_OVERTIME_MIN` | 15 | 精力 | 10-20 | 加班守门精力下限;低于 10 burnout 误触,高于 20 过紧 | Rule 3 |
| `ENERGY_EL_DECAY_AFTER_N` | 3 | 月内次数 | 2-5 | 月内第 N+1 次早退收益 ×0.7(VS scope);仅 VS 启用 | Rule 4 / F2 |
| `ENERGY_MONTHLY_CAP` | 80(VS only)/ 无(MVP) | 精力 | 70-90 | 月末精力软 cap,超额不进位下月;仅 VS 启用 | Rule 7 / Rule 15 |

### AP Cost 分布 Knob(Rule 2 + F5)

| Knob | 默认值 | 容忍度 | 影响 | Cite |
|------|-------|-------|------|------|
| `AP_COST_DIST_1` | 0.40 | ±0.05 | 1-AP 卡占比;低于 0.35 → 缺碎片化,高于 0.45 → 太多小卡 | Rule 2 / F5 / `#11` lint |
| `AP_COST_DIST_2` | 0.40 | ±0.05 | 2-AP 卡占比 | 同上 |
| `AP_COST_DIST_3` | 0.20 | ±0.05 | 3-AP 卡占比;低于 0.15 → 缺决策锚点,高于 0.30 → 玩家僵硬 | Rule 2 / A1 防护 |
| `avg_cost`(衍生) | 1.80 AP/卡 | ±0.10 | 由分布加权计算,守门 4.4 张/天 | F5 锁 |

### 信息不完全 Knob(Rule 10)

| Knob | 默认值 | 安全范围 | 影响 | Cite |
|------|-------|---------|------|------|
| `PREDICTION_ACCURACY_BASE` | 0.70 | 0.60-0.80 | 早晨预告命中率;0.40 以下纯随机失效 / 1.0 完全规划 | Rule 10 / `#10` 实现 |
| `WEEKLY_DIFFERENCE_GUARANTEE` | 5 days | 4-7 | blacklist 防重保证 — 连续 N 天预告全准则强制差异;< 4 太密集,> 7 失去保证 | Rule 10 / R-AP-4 |

### Effort 三维权重 Knob(Rule 6 + F4 — KPI Research deviation)

| Knob | 默认值 | 安全范围 | 影响 | Cite |
|------|-------|---------|------|------|
| `EFFORT_WEIGHT_OVERTIME` | 0.45 | 0.40-0.50 | 加班占 effort 主驱动;低于 0.40 加班失主导,高于 0.50 其他维度失意义 | F4 / R Research deviation |
| `EFFORT_WEIGHT_HERO` | 0.20 | 0.15-0.25 | Hero 卡占次驱动;高于 0.30 → Hero 等价加班漏洞 | F4 / propagation flag #1 |
| `EFFORT_WEIGHT_OVERAGE` | 0.30 | 0.25-0.35 | 超预期占信息博弈回报 | F4 |
| `EFFORT_WEIGHT_SUM`(衍生) | 0.95 | 0.90-1.00 | 三权重和(留 0.05 给野心版"叙事 effort")| F4 |
| `MAX_MONTH_OVERTIME` | 20 | 15-25 | 月内加班次数归一化分母 | F4 |
| `MAX_MONTH_HERO` | 10 | 8-12 | 月内 Hero 卡归一化分母 | F4 |
| `MAX_MONTH_OVERAGE` | 10 | 8-12 | 月内超预期归一化分母 | F4 |

### 产能天花板 Knob(Rule 12 + F3 — 跨 GDD 协调)

| Knob | 默认值 | 安全范围 | 影响 | Cite |
|------|-------|---------|------|------|
| `BASE_CAPACITY` | 3.0 | 2.5-3.5 | 月 0 时 capacity_factor 起点 | F3 / KPI research §1.4 锁 |
| `DECAY_RATE` | 0.05 | 0.04-0.07 | 每月衰减斜率 | F3 / KPI research §1.4 锁 |
| `CAPACITY_FLOOR` | **0.4(MVP)/ 0(野心版)** | 0.0-0.6 | 衰减下限;0 = 老员工必死(数学不可达),0.4 = 玩家 agency + HUD 预警 | F3 / R-AP-5 / propagation flag #2 |

### 决策空间 Knob(F5 — 间接由 `#11` Action Card own,本 GDD 仅校验)

| Knob | 默认值 | 安全范围 | 影响 | Cite |
|------|-------|---------|------|------|
| `HANDSIZE_DEFAULT` | 10 | 8-12 | 当日手牌数(`#11` own);< 6 无选择,> 15 认知过载违反 P5 | F5 / Rule 10 / research L2 |
| `EARLY_GAME_HANDSIZE_EFFECTIVE` | 5-6 | 4-7 | Day 1-3 实际可用手牌(flag 锁 30%);Section H AC-FUNC 验证 | F5 / Rule 10 / A4 |

### 跨 GDD Reference Knobs(本 GDD 消费,registry 候选注册)

| Knob | Source | 消费位置 | 备注 |
|------|--------|---------|------|
| (无 — 本 GDD 不消费 现有 12 registry constants) | — | — | AP Economy 状态变量与 Save Rule 7 autosave 间接持久化,但不直接引用 Save Rule 14/19/21 等 |

### Energy 跨日承接表(Rule 7 + F2)

| 玩家 profile(月内) | overtime 次 | early leave 次(MVP) | 周末天 | 月末精力变化 |
|-------------------|------------|---------------------|--------|------------|
| 躺平 | 0 | 4(每周一次) | 8 天 | +0 - 0 + 32 + 240 = +272(超 cap 100 截断) |
| 标准 | 4 | 2 | 8 天 | -60 + 24 + 240 = +204 |
| 卷王 | 12 | 0 | 8 天 | -180 + 0 + 240 = +60 |
| 用力过猛 | 18 | 0 | 8 天 | -270 + 0 + 240 = -30(burnout 触发,后续加班守门拒绝) |

(假设 30 天月份;周末按 8 天计算 4 周末)

### Scope Tier 守门表

| Tier | 启用 Knob 子集 |
|------|--------------|
| **MVP** | 全部 internal knobs + 锁定常量 + AP cost 分布 + 信息不完全 + effort 三维权重 + capacity_factor (FLOOR=0.4) |
| **Vertical Slice** | + `ENERGY_EL_DECAY_AFTER_N` + `ENERGY_MONTHLY_CAP` + 事件漏触可视化 + burnout 视觉 |
| **Full Vision** | + `ENERGY_OT_SLOPE` 二次项加班 + `CAPACITY_FLOOR=0` 老员工必死(配 HUD 预警) + 工龄衰减曲线可视化 + 周期性外部冲击事件(`#10` own) |

### Tuning Knob 修订传播规则

任一 knob 值变更须复审:
- `BASE_AP_PER_DAY` / `OVERTIME_BONUS_AP` / `MAX_AP_DAILY`: **PR-blocking**(违反 Pillar 1 红线)
- 精力 6 knobs(`ENERGY_*`): 由 economy-designer 评估安全范围 + Section H AC-FUNC 重测
- AP cost 分布: 由 `#11 Action Card` lint test 强制
- effort 三权重: 由 `#9 KPI System` GDD 仲裁(propagation flag #1)
- `CAPACITY_FLOOR`: 由 `#9` GDD 仲裁(propagation flag #2)
- `PREDICTION_ACCURACY_BASE`: 由 `#10 Event Script` GDD 实现(propagation flag #4)

## Visual/Audio Requirements

### 零 Asset Ownership

AP Economy System **不直接 own 任何 visual / audio asset**。所有 AP / Energy / effort 视听表达由其他 GDD own,#7 仅 emit 信号供其订阅:

| Asset 类型 | Owner GDD | #7 角色 |
|-----------|----------|---------|
| AP 格视觉(8 格 / 加班 +2 格 / 早退缩格) | #13 HUD Diegetic | emit `ap_changed(current, max)` |
| Energy bar 视觉 | #13 HUD Diegetic | emit `energy_changed(current, max)` |
| AP 消耗 SFX(打卡机声 / 鼠标点击 / 键盘嘀嗒)| #4 Audio Manager | emit `ap_consumed(amount)` |
| AP 归零 BGM 切换 / Ambient duck | #4 Audio Manager | emit `ap_depleted()` |
| 早退视觉过场 | #5 Lighting & Visual State + #13 HUD | emit `ap_early_leave_taken()` |
| 加班 ambient 嗡声加重 | #4 Audio Manager(audio-visual 对偶 to #5)| 无直接 — Audio 订阅 `scene_state_changed(→ACTION_OVERTIME)` 经 #6 |
| effort 累积视觉(月内卷王化 visual feedback)| #5 Lighting Rule 5 累积 state 4 维度 | emit `effort_*_incremented` 经 #13 间接 |

### 跨系统视听 dispatch 契约(本 GDD 守门)

- **`ap_consumed` 信号同帧主线程预算**: ≤ 1ms 主线程(由 #6 Rule 3 帧预算 16.6ms 分摊守门)
- **`ap_depleted` 触发链**: AP Economy emit → `#6` dispatch `scene_state_changed(→AFTER_WORK)` → Audio + Lighting + HUD 各自响应。同帧 dispatch ≤ 1帧(`#6 Rule 3`)
- **三轨 negative space 共振**: AP 用满时刻必须无金光 / 无庆祝音 / 无英雄文案(Pillar 4 红线 + Section B 副锚 + Rule 13 主语翻转 + AC-TONE-02)
- **early_leave 视听共振**: 早退触发时 #4 Audio 不播励志音 / #5 Lighting 不渲染奖励金光 / #15 Recap 不展示"今日完美"(避免违反 P1)

### 📌 Asset Spec Flag

本 GDD 不需要 `/asset-spec` — 零 visual/audio ownership。所有 asset spec 由 owner GDD 各自产出:
- `/asset-spec system:hud-diegetic`(AP/Energy 视觉 owner)
- `/asset-spec system:audio-manager`(AP SFX owner)
- `/asset-spec system:lighting-visual-state`(累积视觉 4 维度 owner)

## UI Requirements

### 零 UI Screen Ownership

AP Economy System **不直接 own 任何 UI screen**。所有玩家可见 UI 由其他 GDD own。本 GDD 仅作为 backend 信号 owner:

| UI GDD | 订阅信号 / 依赖数据 | 备注 |
|--------|-------------------|------|
| #13 HUD Diegetic | `ap_changed` / `energy_changed` / `ap_depleted` / `ap_early_leave_taken` / 三 `effort_*_incremented` / `monthly_effort_summary` | AP/Energy/effort 主显示者;主语翻转 lint 守门 |
| #14 Card Play & Dialogue UI | 间接 — 通过 `#11` 调 `try_consume_ap`;Card UI 显示 AP cost | 卡 UI 不直接订阅 #7 信号 |
| #15 Daily / Weekly Recap UI | `ap_changed` / `energy_changed` / `effort_*_incremented` | 周报展示 effort 三维度累积条 + AP/Energy 当日用度 |
| #16 KPI Review & Game Over UI | `monthly_effort_summary`(经 #9 KPI 公式输出) | 月末结算屏显示 effort 三维度 + capacity_factor 当月值(R-AP-5 玩家 agency 守门)|
| #17 Main Menu / Pause / Settings UI | **零交互** — Settings 不暴露 AP/Energy 调节 | Pillar 1 红线: 玩家不可调 AP 数学规则 |

### Settings UI 红线(Pillar 1 + Anti-Pillar 1 守门)

`#17 Main Menu / Settings` 子屏 **禁** 暴露以下选项:
- "调整每日 AP" / "解锁更多 AP 槽" / "禁用反向 KPI" / "调整加班代价"
- 任何让玩家"绕过"或"调弱"AP 经济压力的设置项

允许的相关设置:
- 叙事密度(短/中/长 sub-mode 演出)— 由 #15 Recap + #16 KPI Review own,不影响 #7 数学
- 字体大小 / Locale — Loc + Audio own,不影响 #7

### 📌 UX Flag — Phase 4

本 GDD **不**触发 UX Flag(零 UI screen ownership)。但下游 UI GDD(`#13` / `#15` / `#16`)各自 UX Flag 时,主语翻转原则 + 反英雄红线作为 cross-cutting concern 须传递至每屏 UX spec。

## Acceptance Criteria

25 AC / 5 categories(AC-FUNC 10 / AC-PERF 5 / AC-COMPAT 5 / AC-ROBUST 5 / AC-TONE 5)。5 [RISK GUARD] R-AP-1..5 全对应 AC-ROBUST-01..05。Research H1-H5 假设整合至 AC-FUNC-08(H1)/ AC-FUNC-09(H2+H5)/ AC-FUNC-10(H3 存亡级)/ AC-PERF-01(H4)。

### AC-FUNC — 功能性验证

**AC-FUNC-01** `MVP` 单元测试
**GIVEN** `APEconomy` 在 `MORNING_BRIEFING → ACTION_DAY` 转移帧完成初始化
**WHEN** `scene_state_changed(→ACTION_DAY)` 信号被接收
**THEN** `current_ap == 8`,`max_ap_today == 8`,`overtime_used_today == false`,`early_leave_taken_today == false`;`current_energy` 保持前日末尾值不变(跨日承接)
*Cite: Rule 1 / Rule 8 / Rule 7*

**AC-FUNC-02** `MVP` 单元测试
**GIVEN** 状态机处于 `AP_NORMAL`,`current_ap == 3`,`current_energy == 50`
**WHEN** `#11` 调 `try_consume_ap(3)`
**THEN** 返回 `true`;`current_ap == 0`;emit `ap_consumed(3)` 给 `#6`;emit `ap_changed(0, 8)` 给 `#13`;AP 状态切至 `AP_OVERTIME_AVAILABLE`;同帧不 emit `ap_depleted()`(由 Rule 5 信号触发,但不直接调 `#6.request_transition`)
*Cite: Rule 9 / Rule 5 / Rule 2 / 状态机转移矩阵*

**AC-FUNC-03** `MVP` 单元测试
**GIVEN** 状态机处于 `AP_OVERTIME_AVAILABLE`,`current_energy == 15`(恰等 `ENERGY_OVERTIME_MIN`)
**WHEN** 玩家申请加班
**THEN** `try_overtime()` 通过守门;`max_ap_today == 10`;`current_ap == 2`;`current_energy == 0`;`overtime_used_today == true`;`burnout_flag == true`;emit `effort_overtime_incremented(day, 1)`;AP 状态切至 `AP_OVERTIME_ACTIVE`
*Cite: Rule 3 / Edge 2.1 / F1(MVP cost=15)/ 状态机*

**AC-FUNC-04** `MVP` 单元测试
**GIVEN** 状态机处于 `AP_NORMAL`,`current_ap == 2`,`early_leave_taken_today == false`,`current_energy == 40`
**WHEN** 玩家申请早退(`leave_ap_saved == 2`)
**THEN** `early_leave_taken_today == true`;`current_energy == min(40 + 8×2, 100) == 56`;emit `ap_early_leave_taken()` 给 `#6` 和 `#10`;`current_ap` 不变(剩余 AP 不归零)
*Cite: Rule 4 / F2(MVP decay_factor=1.0)/ Rule 5*

**AC-FUNC-05** `MVP` 集成测试
**GIVEN** 月末 `scene_state_changed(→KPI_REVIEW)` 信号到达时,`overtime_used_this_month == 6`,`hero_card_played_this_month == 3`,`overage_card_played_this_month == 2`,`month_index == 4`
**WHEN** AP Economy 执行月末 push
**THEN** 先 emit `monthly_effort_summary(4, E, 6, 3, 2, days_worked, capacity_factor(4))`,其中 `E = 0.45×(6/20) + 0.20×(3/10) + 0.30×(2/10) = 0.135+0.060+0.060 = 0.255`,`capacity_factor(4) = max(0.4, 3.0-0.20) = 2.8`;**之后**三计数器归零;`month_index` 递增至 5
*Cite: Rule 6(月末 reset 协议)/ F4 / F3 / Edge 5.3 / Edge 5.1*

**AC-FUNC-06** `MVP` 单元测试
**GIVEN** `try_consume_ap` 被调用时:(a) `amount == 0`,(b) sub-mode 为 `KPI_REVIEW`,(c) `current_ap == 1` 但 `amount == 2`
**WHEN** 任一条件成立
**THEN** 各自返回 `false`;不修改 `current_ap`;不 emit 任何信号;场景(a)额外触发 `push_error`
*Cite: Rule 9 三前提检查 / Edge 1.2 / Edge 1.3 / Edge 6.1*

**AC-FUNC-07** `MVP` 集成测试
**GIVEN** `current_energy == 0`(`burnout_flag == true`),AP 状态为 `AP_OVERTIME_AVAILABLE`
**WHEN** 玩家尝试申请加班
**THEN** `try_overtime()` 返回 `false`;AP 状态保持 `AP_OVERTIME_AVAILABLE`(不自动转 `AP_DEPLETED`);玩家须主动选"就这样"才完成转移;`current_energy` 不变
*Cite: Rule 3 / Edge 2.3 / Edge 4.1 / 状态机*

**AC-FUNC-08** `Beta` Playtest — H1 决策熵
**GIVEN** 8-12 名测试玩家完成 Day 1-3(flag 锁卡 30%,实际手牌 5-6)
**WHEN** 记录每位玩家每日打出的 AP 序列(卡顺序),计算每日卡组选择的 Shannon entropy
**THEN** 至少 6/8 玩家 Day 1-3 卡序列 Shannon entropy 均值 ≥ 1.5 bits(防 A4 冷启动模板固化)。使用决策熵分析工具
*Cite: Research H1 / F5(Day 1-3 decision_space C(5,4)=5~15)/ Rule 10 / Edge 7.3*

**AC-FUNC-09** `Beta` Playtest — H2 后悔感 + H5 玩家聚类
**GIVEN** 8-12 名测试玩家完成首次月末 KPI Review
**WHEN** 进行 30 秒短访谈(后悔访谈协议),问"本月哪一天你觉得早该/不该这样做?"
**THEN** ≥70% 玩家能具体指出某日的 AP 决策(加班/早退/打某张卡)导致了月末 KPI 结果(H2 后悔感,防 A5 KPI 脱钩)。同批次用玩家聚类工具按打牌风格分组,silhouette score ≥ 0.3,聚类 ≥ 2 簇(激进 / 保守 / 叙事,H5 验证)
*Cite: Research H2 / H5 / Rule 6 / F4 / Edge 7.2*

**AC-FUNC-10** `VS` Playtest — H3 非占优(存亡级)
**GIVEN** 使用非占优枚举工具,程序化枚举 ≤4 张卡的全组合 × 4 种 AP 初态(6/8/10/早退)
**WHEN** 评估每种组合跨月 1-3 月份的状态覆盖率(`AP_NORMAL` / `AP_OVERTIME_ACTIVE` / `AP_DEPLETED` 三态出现频率)
**THEN** 覆盖率最高的 Top-1 卡组合在三态分布中的状态覆盖率 < 60%;即不存在单一组合能在 60% 以上场景保持最优(防 A2 最优卡闭包)。**此为存亡级 AC,失败则 H3 C1 判据不满足,游戏核心 P1 破立**
*Cite: Research H3 C1 判据 / Rule 2 / F5 / F4 / Edge 7.2 / Rule 12*

### AC-PERF — 性能验证

**AC-PERF-01** `MVP` 自动化计时 — H4 地铁 90 秒
**GIVEN** 测试玩家在标准 PC 配置(Steam 目标机)上执行完整"一天"流程
**WHEN** 使用 90 秒计时器在 8-12 名玩家自然操作下各计时一次
**THEN** 中位时长 ≤ 90 秒,p90 ≤ 120 秒(H4 P5 验证)。计时从玩家触碰首张卡开始,至 `DAILY_RECAP` save 完成提示出现止
*Cite: Research H4 / Rule 15 P5 / Pillar 5*

**AC-PERF-02** `MVP` 自动化帧率测试
**GIVEN** 在 `ACTION_DAY` sub-mode 下同帧触发:`try_consume_ap(2)`(emit `ap_consumed` + `ap_changed`)+ `energy_changed` + `effort_overtime_incremented`
**THEN** 上述 5 个信号 batch 后 `#13 HUD` 在同一帧内完成更新,帧耗时不超过 16.6ms;Godot Profiler 在连续 60 帧测量中无任何单帧超过 20ms(10% 容忍上限)
*Cite: Rule 7 / Rule 14 / Rule 2*

**AC-PERF-03** `MVP` 自动化状态机 fixture
**GIVEN** 使用状态机 fixture 连续执行 4 态完整切换序列:`AP_NORMAL → AP_OVERTIME_AVAILABLE → AP_OVERTIME_ACTIVE → AP_DEPLETED → AP_NORMAL`(次日 reset)
**WHEN** 100 次循环(模拟 100 个游戏日)
**THEN** 每次切换均在 1 帧内完成(≤16.6ms);内存占用增量为 0(无泄漏);第 100 次与第 1 次的 `current_ap` / `current_energy` 状态差异完全可由 Rule 1-8 解释
*Cite: 状态机转移矩阵 / Rule 1 / Rule 8 / Edge 3.1*

**AC-PERF-04** `MVP` 集成测试
**GIVEN** 模拟"用力过猛"玩家 profile:月内 18 次加班、9 张 Hero 卡、8 次超预期,`current_energy` 跨日承接至月末为负(经 Rule 7 burnout 截断后 = 0)
**WHEN** 月末 emit `monthly_effort_summary`
**THEN** `effort_potential = 0.45×(18/20) + 0.20×(9/10) + 0.30×(8/10) = 0.825`;`capacity_factor` 计算耗时 < 1ms;`monthly_effort_summary` 信号从 emit 到 `#9` 接收确认耗时 < 1 帧;`burnout_flag == true` 已在月末前正确置位
*Cite: F3 / F4 / Rule 12 / Rule 7*

**AC-PERF-05** `MVP` Energy 跨日 fixture
**GIVEN** Energy 跨日 fixture,设 `current_energy = 0` / `100` / `50`
**WHEN** 分别触发:加班申请(守门检查)/ 早退精力收益(溢出截断)/ 周末恢复 +30
**THEN** (a) `current_energy=0` 时加班守门拒绝,`burnout_flag == true`;(b) `current_energy=90 + gain=16` 截断至 100;(c) `current_energy=75 + 30 = 100`(截断);三种路径各自 emit `energy_changed` 恰好 1 次,不重复
*Cite: Rule 7 / Edge 2.1/2.2/2.5 / F2*

### AC-COMPAT — 跨系统兼容性

**AC-COMPAT-01** `MVP` 集成测试 — `#6/#7` 双向契约
**GIVEN** `#6` emit `scene_state_changed(→ACTION_DAY)`
**WHEN** AP Economy 接收信号
**THEN** 同帧完成日 reset(Rule 1);随后 `#11` 调 `try_consume_ap(2)` 成功后,AP Economy emit `ap_consumed(2)`,`#6 Rule 9` 在同帧驱动 game-time 离散 tick。完整链路 `#6→#7→#6` 无信号丢失,sub-mode 未因 AP Economy 内部操作主动调用 `request_transition`
*Cite: I-1 / I-2 / Rule 9 / Rule 5 / `#6 Rule 1`*

**AC-COMPAT-02** `MVP` 集成测试 — `#9/#7` 双向契约
**GIVEN** 月末 `monthly_effort_summary` 已 emit(三维度 `ot=4, hero=2, ovr=2`),且 `#9` 随后回调 `report_overage(card_id, kpi_delta=0.15)`(>阈值 10%)
**WHEN** AP Economy 处理 `report_overage` 回调
**THEN** `overage_card_played_this_month` **不**再累积(因已进入 `KPI_REVIEW`,月末计数器已清零);emit `effort_overage_incremented` 推送至 `#13 HUD` 显示"延迟至次日更新";下月 `overage_count` 从 1 开始
*Cite: I-3 / Rule 6 emit 时序 / Edge 5.2 / Edge 6.1*

**AC-COMPAT-03** `MVP` 集成测试 — `#11/#7` 双向契约
**GIVEN** `#11` 打出一张 `is_hero: true` 的 3-AP 卡,`current_ap == 4`
**WHEN** `#11` 先调 `try_consume_ap(3)` → 成功后调 `report_hero_card_played(card_id)`
**THEN** `current_ap == 1`;`hero_card_played_this_month += 1`;emit `effort_hero_incremented(card_id, day, total)`;emit `ap_changed(1, 8)`;两个 emit 均在同帧完成;`#11` 不持有 AP 状态,AP Economy 不持有卡内容
*Cite: I-4 / Rule 6 / Rule 14 / Rule 9*

**AC-COMPAT-04** `MVP` 集成测试 — `#10/#7` 双向契约
**GIVEN** `#10` 在 `MORNING_BRIEFING` 调 `inject_predicted_ap_demand(6)`,随后玩家早退触发 `ap_early_leave_taken()`
**WHEN** `#10` 接收 `ap_early_leave_taken()` 信号
**THEN** `predicted_ap_demand_today == 6`;`#10` 以 `EARLY_LEAVE_EVENT_MISS_RATE` 计算漏触发事件(AP Economy 不参与计算);AP Economy emit `ap_early_leave_taken()` 恰好 1 次,无重复;`#13 HUD` 可从 `predicted_ap_demand_today` 展示预测格数
*Cite: I-6 / Rule 4 / Rule 10 / Edge 8.2*

**AC-COMPAT-05** `MVP` 集成测试 — `#13/#7` 单向契约
**GIVEN** 在同一个 `ACTION_DAY` 帧内依次发生:`try_consume_ap(2)` 成功 + 加班申报 + 早退被拒
**WHEN** `#13 HUD` 订阅 `ap_changed` / `energy_changed` / `effort_overtime_incremented` 三信号
**THEN** HUD 接收且处理全部 3 个信号,无丢失;信号参数值与 AP Economy 内部状态一致;HUD 不持有任何 AP 状态副本;HUD 文案不含"你高效完成了任务"类主语翻转违规词汇(由 `subject_inversion_lint.py` 扫描通过)
*Cite: I-5 / Rule 13 / Rule 14 / propagation flag #5*

### AC-ROBUST — 风险守门(对应 R-AP-1..5)

**AC-ROBUST-01** `MVP` `R-AP-1` AP 上限永久增长禁令
**GIVEN** 任何外部路径(debug 工具 / 成就系统 / `@export var` Inspector 修改 / 假设 API `unlock_ap_slot()`)尝试将 `max_ap_today` 永久设为 > 8
**WHEN** 次日 `MORNING_BRIEFING → ACTION_DAY` reset 执行
**THEN** `max_ap_today` 强制恢复 `== BASE_AP_PER_DAY == 8`;`BASE_AP_PER_DAY` 须声明为 GDScript `const`(编辑器 Inspector 不可写);CI lint 断言 `APEconomy` 公开接口不含 `unlock_ap_slot` 签名;违反则 Code Review BLOCKING
*Cite: R-AP-1 / Edge 1.4 / Rule 11 / Edge 9.1 / Edge 9.2 / Anti-Pillar 1*

**AC-ROBUST-02** `MVP` `R-AP-2` 月末计数器 reset 顺序(P1-blocking)
**GIVEN** effort emit 时序 fixture 注入故障场景:在 `monthly_effort_summary` push 之前人为清零 `overtime_used_this_month`(模拟 reset 顺序倒置 bug)
**WHEN** `#9 KPI System` 接收 `monthly_effort_summary`
**THEN** 正确实现下:三计数器在 push 信号回调确认后才清零,`#9` 收到的 `ot/hero/ovr` 均为本月实际累积值(≠0);若注入故障,测试框架检测到 `monthly_effort_summary` 内 `ot==0`(实际 ot≥1 场景)并标记 **FAIL**(等同"躺平 KPI 输入"P1-blocking bug)
*Cite: R-AP-2 / Edge 5.1 / Rule 6 / Rule 8*

**AC-ROBUST-03** `MVP` `R-AP-3` 早退 + 同帧消耗 race
**GIVEN** 状态机 fixture 构造:`current_ap == 1`,玩家在同帧 emit `ap_early_leave_taken()` 并有 `#11` 缓冲队列 `try_consume_ap(1)` 等待
**WHEN** 帧内两个调用按 GDScript 单线程顺序串行执行
**THEN** `#6 dispatch ACTION_DAY→AFTER_WORK` 须在 `ap_early_leave_taken()` emit 同帧内完成(`call_deferred` 链保证);后续 `try_consume_ap(1)` 因 sub-mode 不在允许集 → 返回 `false`;`current_ap` 最终 == 1;AP 状态不进入不一致的 `AP_DEPLETED + early_leave_taken=true` 并存态
*Cite: R-AP-3 / Edge 10.2 / Rule 9 / Edge 1.6*

**AC-ROBUST-04** `MVP` `R-AP-4` `#10` blacklist 持久化
**GIVEN** crash recovery fixture:save 一局(`blacklist` 含已命中预告条目),kill 进程,load 存档
**WHEN** 次日 `MORNING_BRIEFING` 执行
**THEN** `#10 Event Script Engine` 读取的 `blacklist` 与存档前一致;`PREDICTION_ACCURACY_BASE = 0.70` 不受 load 影响;`WEEKLY_DIFFERENCE_GUARANTEE` 在 load 后继续按剩余计数触发。同时验证 `current_energy` 跨日承接在 save/load 后完整性
*Cite: R-AP-4 / Edge 10.3 / Rule 10 / propagation flag #4 / Edge 10.1*

**AC-ROBUST-05** `MVP` `R-AP-5` capacity_factor floor 守门
**GIVEN** capacity_factor floor 守门 fixture:设 `month_index = 60`,`CAPACITY_FLOOR = 0.4`(MVP 默认)
**WHEN** 执行 `capacity_factor(60) = max(0.4, 3.0 - 0.05×60) = max(0.4, 0.0) = 0.4`
**THEN** 计算结果 == 0.4(floor 生效,不为 0);`monthly_effort_summary` 附带 `capacity_factor == 0.4`;`#13 HUD` 通过 `#19 Notification` 订阅收到 agency 预警信号;若 `CAPACITY_FLOOR` 被错误设为 0.0 且 `month_index ≥ 60`,fixture 检测 `capacity_factor == 0` 并标记 **FAIL**
*Cite: R-AP-5 / Edge 10.4 / F3 / Rule 12 / Tuning Knob CAPACITY_FLOOR / propagation flag #2*

### AC-TONE — 叙事基调验证

**AC-TONE-01** `MVP` CI Lint — Pillar 1 + Anti-Pillar 1 守门
**GIVEN** `subject_inversion_lint.py` 扩展版扫描全部 `AP.*` / `ENERGY.*` Localization key
**WHEN** CI 在每次 push to main 时运行
**THEN** 无任何 key 的文案值含以下词汇:`解锁更多 AP` / `AP 上限提升` / `高效利用所有 AP` / `完美规划` / `零浪费` / `卷王进度条` / `满血出击`;违反任意一项 → CI **FAIL**(BLOCKING);若 HUD 反馈触发 AP 归零时出现"今日完美"语义 → 同样 FAIL
*Cite: Rule 13 / Rule 11 / Section B Internal Design Test / Anti-Pillar 1 / propagation flag #5*

**AC-TONE-02** `MVP` 手动审校 — Pillar 1 主锚 + Pillar 4 苦中作乐
**GIVEN** QA tester 完整游玩一日(8 AP 用尽),观察 AP 归零时的全屏反馈
**WHEN** `ap_depleted()` 触发 `DAILY_RECAP` 转移
**THEN** 反馈层无金光特效 / 无庆祝音效 / 无"今日完美"文案;只呈现打卡机声(Audio)+ 数据屏蓝光转场(Lighting `DAILY_RECAP`);HUD AP 格显示为"用完"而非"满分达成";tester 在验收表记录"感受到空虚/用完了"而非"成就感"(主观评分 < 3/5 的"满足感"量表)
*Cite: Section B 副锚 / Rule 13 / Player Fantasy*

**AC-TONE-03** `MVP` 手动审校 — Section B Internal Design Test 反英雄红线
**GIVEN** QA tester 对 `#11` 全部卡反馈 UI、`#13 HUD` AP 计数动画、`#15 Recap` 月末 effort 累积反馈逐项审校
**WHEN** 对每项反馈问:"这是奖励玩家用满 AP,还是反讽玩家用满 AP?"
**THEN** 所有审校项判定为"反讽/自损"语义通过;任何一项被判定为"英雄主语/奖励语义"→ 该卡/UI **不得**通过 Done 审核,标注 Advisory 缺陷并退回 `#11`/`#13`/`#15` 责任方修改
*Cite: Section B Internal Design Test / Rule 13 / Anti-Pillar 2*

**AC-TONE-04** `MVP` CI Lint — Anti-Pillar 1 红线 PR-blocking
**GIVEN** Code Review 阶段对任何含 `BASE_AP_PER_DAY` / `MAX_AP_DAILY` / `OVERTIME_BONUS_AP` 的 PR diff
**WHEN** PR 提交或 CI 扫描运行
**THEN** 若 diff 修改上述三常量为非预设值(8 / 10 / 2)→ CI **FAIL** + PR-blocking comment 自动标注"违反 Pillar 1 红线 Rule 11";若 PR 新增任何返回类型为 `void` 且名含 `unlock_ap` / `add_ap_slot` 的函数签名 → 同样 FAIL
*Cite: Rule 11 / Edge 9.2 / Section A 5 NOT 红线第 4 条 / Anti-Pillar 1*

**AC-TONE-05** `MVP` 手动审校 — P1 主锚"被发的预算"语义
**GIVEN** `#13 HUD` 展示 AP 格时,QA tester 查看日初 AP 格出现动画及 tooltip/文案
**WHEN** `ACTION_DAY` 开始时 AP 格刷出
**THEN** 文案必须使用外部所有权语义("今天发了 8 格" / "今天的额度" / "公司的 AP"),禁止出现"你的行动力" / "你的能量" / "你的资源";任何出现产权错误用词 → 标注 Advisory 缺陷,退回 `#13` 修改
*Cite: Section B Player Fantasy 主锚 / P1 主 / Rule 13*

---

### Tier 分级汇总

| Tier | 数量 | AC IDs |
|------|------|--------|
| MVP 必测 | 22 | AC-FUNC-01..07(7)+ AC-PERF-01..05(5)+ AC-COMPAT-01..05(5)+ AC-ROBUST-01..05(5)+ AC-TONE-01..05(5)= 27,但 AC-FUNC-08..10 是 Beta/VS,故 MVP = 22 |
| Beta(playtest 类) | 2 | AC-FUNC-08(H1)+ AC-FUNC-09(H2+H5) |
| VS(存亡级 playtest) | 1 | AC-FUNC-10(H3,游戏核心 P1 验证) |

**总 25 AC**(实际 7+5+5+5+5+3 = 25, 其中 AC-FUNC 共 10 条但 3 条延 Beta/VS)。

### Research H1-H5 假设覆盖

| H 假设 | AC 覆盖 | Tier |
|-------|--------|------|
| H1 决策熵 | AC-FUNC-08 | Beta |
| H2 后悔感 | AC-FUNC-09 | Beta |
| H3 非占优(C1 存亡级) | AC-FUNC-10 | VS |
| H4 地铁 90 秒 | AC-PERF-01 | MVP |
| H5 风险投射 | AC-FUNC-09(同 H2)| Beta |

### W-CONS-1 检查结果

本 GDD `ap-economy-system.md` 全文检索 "Save Rule 20" **无命中**。Section F 明确标注 Save 为 transitive 依赖。**无需修复**。

### KPI Research deviation flag(已 surface,AC 锁定本 GDD 值)

effort 三维权重 `0.45/0.20/0.30` 与 research 草稿 `0.40/0.35/0.25` 不一致。AC-FUNC-05 / AC-PERF-04 worked example 使用本 GDD 值。`#9 KPI System` GDD 撰写时须复审(propagation flag #1),反驳则 AC 同步 revise。

### QA 工具需求清单

| 工具 / Fixture | 守门 AC | Tier | 技术实现 |
|---------------|---------|------|---------|
| AP cost 分布 lint(40/40/20 ±5%) | AC-COMPAT-03 / Edge 7.1 | MVP | `#11` 卡库 lint test |
| effort 三维权重 lint | AC-FUNC-05 / AC-PERF-04 | MVP | GDScript const 校验 |
| 状态机 fixture(4 态切换桩) | AC-FUNC-02/03/07 / AC-ROBUST-03 / AC-PERF-03 | MVP | GUT signal stub + state injection |
| Energy 跨日 fixture | AC-FUNC-03 / AC-PERF-05 / AC-ROBUST-04 | MVP | `current_energy` 边界注入 |
| effort emit 时序 fixture | AC-ROBUST-02 / AC-FUNC-05 | MVP | 信号回调顺序 mock |
| 决策熵分析工具 | AC-FUNC-08(H1) | Beta | 卡 log → Shannon entropy |
| 后悔访谈协议(30s) | AC-FUNC-09(H2) | Beta | playtest 短问卷模板 |
| 非占优枚举工具 | AC-FUNC-10(H3,存亡级) | VS | ≤4 张卡组合 × 状态枚举 |
| 90 秒计时器 | AC-PERF-01(H4) | MVP | 自然操作下计时 |
| 玩家聚类工具 | AC-FUNC-09(H5) | Beta | Big-Five + silhouette score |
| `subject_inversion_lint.py`(扩展 AP.*/ENERGY.*) | AC-TONE-01 / AC-COMPAT-05 | MVP | Python 正则 lint(扩展自 #6 Rule 14)|
| crash recovery fixture | AC-ROBUST-04 / AC-PERF-05 | MVP | save/load + `current_energy` + `blacklist` 持久化 |
| capacity_factor floor 守门 fixture | AC-ROBUST-05(R-AP-5) | MVP | `month_index = 60` + floor 注入 |

## Open Questions

10 OQ 整理(延 ADR / Sprint / Polish / Alpha + 5 cross-GDD propagation flags)。

**OQ-AP-01 (待 #9 KPI System GDD 仲裁)**: effort 三维权重修订(`0.45/0.20/0.30` vs research 草稿 `0.40/0.35/0.25`)。Owner: game-designer + #9 主笔 + economy-designer。Target: `/design-system kpi-reverse-threshold-system` 撰写阶段。
- Hero 卡等价加班漏洞 economy-designer 评估
- 若 #9 反驳,本 GDD Rule 6 + F4 + AC-FUNC-05 / AC-PERF-04 worked example 同步 revise

**OQ-AP-02 (待 #9 KPI System GDD 仲裁)**: `CAPACITY_FLOOR` 决策(0.4 vs 0)。Owner: #9 主笔 + producer + game-designer。Target: `/design-system kpi-reverse-threshold-system` 撰写阶段。
- 0.4 = 玩家有 agency + HUD 预警(MVP 推荐)
- 0 = 第 60 月数学不可达,老员工必死(野心版完整版意图)
- 影响 R-AP-5 守门 + AC-ROBUST-05 实现

**OQ-AP-03 (Pre-Production playtest)**: 加班单次 Energy cost 实测(`ENERGY_OT_BASE = 15` 是否合适)。Owner: economy-designer + qa-tester。Target: Pre-Production /prototype 阶段。
- 太低(< 10)→ 加班无痛(违反 A6)
- 太高(> 25)→ 强迫早退(违反 L5 可选性)
- 实测 8-12 名玩家在 12 周关卡内的 burnout 触发频率,目标 15-30% 玩家在第 6+ 月触发

**OQ-AP-04 (Pre-Production playtest — H3 存亡级)**: 非占优 C1 判据实证。Owner: systems-designer + game-designer。Target: `/prototype core-loop` 阶段(必测项,research 优先级 P1)。
- 原型期使用非占优枚举工具,程序化评估 ≤4 张卡组合 × 状态覆盖率
- 失败则 H3 C1 判据不满足,游戏核心 P1 破立 — 此情况须立即调整 L1/L3/L10 再测
- AC-FUNC-10(VS tier)的 prototype 提前版本

**OQ-AP-05 (Polish playtest)**: AP cost 分布 40/40/20 是否需要进一步调整。Owner: game-designer + `#11 Action Card` 主笔。Target: Polish 阶段。
- 实测 8-12 名玩家在 12 周关卡内的卡使用频率长尾分布
- 若 top-3 卡占用 > 60% 则触发 A2 反模式,L1 分布需重做

**OQ-AP-06 (Pre-Production playtest)**: 信息不完全度 70% 命中率是否最佳。Owner: `#10 Event Script` 主笔 + qa-tester。Target: `/prototype core-loop` 阶段。
- 实测玩家"被坑"频次 — 太少(< 1 次/周)→ A4 + A7 叠加;太多(> 3 次/周)→ 玩家觉得"算法在坑我"
- `WEEKLY_DIFFERENCE_GUARANTEE` blacklist 防重的 5 天阈值实证

**OQ-AP-07 (VS playtest — H5 风险投射)**: 玩家聚类轮廓系数实证。Owner: qa-tester + game-designer。Target: VS playtest 阶段。
- 8-12 名 Big-Five 分组玩家跑完 5 天原型
- silhouette score ≥ 0.3 + 至少 2 簇可辨识
- 失败则 L5(精力-AP 可选性)+ L7(反向 KPI 灵敏度)需调整

**OQ-AP-08 (野心版 ADR-XXXX 候选)**: 跨局 Run Meta 是否注入"不同起始 NPC 人格 / 部门 / 初始 Boss" 打破 A7 模板固化。Owner: game-designer + `#12 Run Meta` 主笔。Target: 野心版 ADR 阶段。
- research §4 A7 对策 — Run 4+ 的卡序列熵值低于 Run 1-2 时触发
- 引入跑间变量是反 A7 唯一非数学手段

**OQ-AP-09 (野心版 ADR-XXXX 候选)**: 加班 `ENERGY_OT_SLOPE` 二次项启用与否。Owner: economy-designer + game-designer。Target: 野心版 12+ 月关卡阶段。
- MVP 单次加班机制不需要(slope = 0)
- 野心版若引入"单日多次加班"扩展,slope = 5 自动单调防 A3

**OQ-AP-10 (Pre-Production)**: 周末 Energy 恢复机制是否要求"玩家选择活动"(读书 / 看电视 / 见朋友 → 不同回精力差异)。Owner: game-designer + narrative-director。Target: Pre-Production 设计探索阶段。
- 当前 MVP 简化为 `+30 / 天` 固定值
- 若引入选择,周末本身成为微观决策窗口(Pillar 5 守门验证)

### OQ-impacted AC 标注

| OQ | 影响 AC | 修订路径 |
|----|--------|---------|
| OQ-AP-01 | AC-FUNC-05 / AC-PERF-04 | 若 #9 反驳 0.45/0.20/0.30,worked example 重算 |
| OQ-AP-02 | AC-ROBUST-05 | 若选 floor=0,AC 改为"老员工必死 + HUD 预警"模式 |
| OQ-AP-03 | AC-PERF-05 / AC-FUNC-03 | 若 ENERGY_OT_BASE 调整,AC worked example 同步 |
| OQ-AP-04 | AC-FUNC-10(VS) | prototype 提前验证后回调本 AC tier |
| OQ-AP-05 | AC-COMPAT-03 / Edge 7.1 | 若 AP cost 分布调整,#11 lint 重写 |
| OQ-AP-06 | AC-COMPAT-04 | 若 70% 调整,`#10` 实现重写 |
| OQ-AP-07 | AC-FUNC-09(H5) | 玩家聚类阈值调整 |
| OQ-AP-08 | AC-FUNC-10(野心版) | 若引入跑间变量,A7 防护方式改变 |
| OQ-AP-09 | F1 / Tuning Knob `ENERGY_OT_SLOPE` | 野心版启用时 F1 公式重新生效 |
| OQ-AP-10 | F2(Energy 跨日恢复) | 若引入选择,F2 增 modifier 项 |

### 5 propagation flags 状态(Section C / F 已 surface)

| Flag # | 待 GDD | Status | OQ 关联 |
|--------|--------|--------|---------|
| #1 effort 权重 | #9 KPI System | 待 `/design-system #9` 撰写 | OQ-AP-01 |
| #2 CAPACITY_FLOOR | #9 KPI System | 待 `/design-system #9` 撰写 | OQ-AP-02 |
| #3 AP cost 分布 lint | #11 Action Card | 待 `/design-system #11` 撰写 | OQ-AP-05 |
| #4 PREDICTION_ACCURACY blacklist | #10 Event Script | 待 `/design-system #10` 撰写 | OQ-AP-06 |
| #5 主语翻转 lint AP/ENERGY key | #13 HUD Diegetic | 待 `/design-system #13` 撰写 | — |
