// ============================================================================
// Episode 4 · Week 4 · 「第一次 KPI Review」 (Season 1 Finale)
// ============================================================================
//
// Status: 第 1 版 (分身 CC session 翻译稿 - 从 episode-4.md 翻译 + 应用修 2 / 修 3)
// Author: 分身 CC session (Round 2)
// Last Updated: 2026-05-05
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
//
// 设计目标 (摘要):
//   1. 集内高峰 = 周日 9:30 KPI Review 浮层揭晓 5 路径 (anti-Pillar 1 第一次咬人)
//   2. D Finale 集中触发 - 9 NPC (除林姐) 每人有 D finale beat
//   3. 5:5 笑泪比 - 上半周笑, 下半周扎到底
//   4. Series cliffhanger 至 S2: 周日晚 Lisa 微信"下个月开始我可能加班多一点"
//
// 应用 designer Round 1 修改:
//   - 修 1 (Q2.2): daily_recap 不显示李阿姨
//   - 修 2 (Q2.4): KPI Review 浮层去掉数学公式, 改 qualitative 描述 + 离散
//                  lookup 表
//   - 修 3 (Q3.2): 周三 24.2 王总监 1v1 找 Lisa lighten - "下午 3 点对一对" →
//                  "Lisa 下周方案给我看下" (manager-style push, 去 PIP-feel)
//
// ============================================================================

INCLUDE episode-1.ink

// E4 entry
-> episode_4


// ============================================================================
// Episode 4 主入口
// ============================================================================

=== episode_4 ===
# scene: home
# time: monday_morning_week_4
# pagebreak
-> day_22_morning_briefing


// ============================================================================
// Day 22 · 周一 · 第 15 周第 1 天 · 月末倒数最后一周
// ============================================================================

= day_22_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:11

闹钟 1 次。

_周末睡饱了。但今天周一是月末倒数最后一周——心里不轻松。_

_我周日晚 21:30 在准备"如果王总监 cue 我"。_

_Lisa 4 周前周日晚 21:30 在准备同一件事。_

_我成了 Lisa。_

# scene: office_entrance
# time: 9:11

9:11 到公司。

* [开始今日]
    -> day_22_event_1_vivian_year_end_notice


// ----------------------------------------------------------------------------
// Event 22.1 · Vivian 打卡台的"年终福利预告" · 9:13 (Vivian D Finale)
// ----------------------------------------------------------------------------
// 触发: 刷工牌
// 速度: 标准 (~5 行)
// 同框: Vivian
// NPC archetype: Vivian D Finale + S12 endgame 锚定
// ----------------------------------------------------------------------------

= day_22_event_1_vivian_year_end_notice
# scene: reception
# time: 9:13
# npc: vivian_at_reception
# prop: a4_year_end_announcement_posted

你刷工牌过门禁。

前台 Vivian 抬头："嗨～来啦～"

但今天 Vivian 工位旁边贴了一张新告示, A4 纸打印的：

> **年终福利预告**
> 今年公司财务紧张, 年终奖发放时间待定。
> 我们将在 12 月底前给出明确通知。
> —— 公司行政部

你看了 3 秒。

_今年公司财务紧张。_

_发放时间待定。_

_12 月底前。_

// 没有选项 - Vivian D Finale + S12 endgame 锚定

_Vivian 永远先知道。她现在贴出来 = 老板让贴。_

_或者老板本来不让贴, HR 部门 push 必须公示。_

_不管谁让贴的, 结果都是: _

_我下个月以为有的年终奖, 可能没有。_

// hidden flag: 年终福利预告 D22 - series-level setup, S12 finale beat 锚定

~ check_state_after_choice()
-> day_22_event_2_wang_stops_to_ask


// ----------------------------------------------------------------------------
// Event 22.2 · 王总监经过工位 · 中午 12:18
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~4 行)
// 同框: 王总监
// 设计意图: 前 3 周他叫"加油啊"就走, 今天他停 - 月末数所有人 KPI
// ----------------------------------------------------------------------------

= day_22_event_2_wang_stops_to_ask
# scene: workstation_pantry_corner
# time: 12:18
# npc: wang_stopping_this_time

12:18。你刚泡好面, 王总监经过工位区。

"小笑啊。"

0.5 秒。

"陈天啊。"

0.5 秒。

"差不多差不多。**今天月末倒数 4 天了。你的 KPI 怎么样？**"

他这次**停下来等你回答**。

* [应该差不多]
    # speaker: wang_director
    王总监："嗯。"
    _他没再说, 走了。_
    ~ wang_score = wang_score + 0

* [还行]
    # speaker: wang_director
    王总监："还行的意思是达标了？"
    _你不知道怎么回答。_
    "好好做。"
    _他走了。_
    ~ wang_score = wang_score + 0
    // hidden flag: 你被王总监二次问 1 次

* [有点紧张]
    # speaker: wang_director
    王总监："紧张啥。我们一起想办法。"
    _他笑了一下, 但你看不出是真心还是 PUA 的标准动作。_
    ~ wang_score = wang_score + 0
    // hidden flag: 王总监"我们一起想办法" D22 - S2-S3 push 你的种子

- _他这次停下来等了。_
- _前 3 周他叫"加油啊"就走。_
- _今天他停。_
- _他在月末数所有人的 KPI 进度。我也在他的清单上。_

~ check_state_after_choice()
-> day_22_after_work


= day_22_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    你回到工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_22_daily_recap


= day_22_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Vivian D Finale** (年终福利预告)_
_  - 王总监停下来问 KPI_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_23_morning_briefing


// ============================================================================
// Day 23 · 周二
// ============================================================================

= day_23_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:09

# scene: office_workstation
# time: 9:09
# npc: lisa_with_paper_box

9:09 到公司。

Lisa 在工位——她今天**桌上多了一个纸箱**。

_纸箱。_

_她在收拾东西。_

_但她没告诉我。_

* [开始今日]
    -> day_23_event_1_lisa_drawer_rehearsal


// ----------------------------------------------------------------------------
// Event 23.1 · Lisa 收抽屉 · 上午 11:30
// ----------------------------------------------------------------------------
// 触发: 第 3 个 event
// 速度: 标准 (~7 行)
// 同框: Lisa (不直接互动)
// 注意 (per spec 红线): 未指明她要走 / 留 - 留白 (Lisa 走/留是 S3 finale = E12)
// ----------------------------------------------------------------------------

= day_23_event_1_lisa_drawer_rehearsal
# scene: workstation_with_lisa_packing
# time: 11:30
# npc: lisa_taking_items_out_then_in
# prop: empty_paper_box_on_desk
# prop: doll_lipstick_thermos_headphones

11:30。Lisa 在收抽屉。

她把抽屉里的私人物品一件件拿出来——

- 那个玩偶 (每天位置不一样的那个)
- 一包没拆的良品铺子话梅
- 一个保温杯 (你之前没见过)
- 一支唇膏
- 一副耳机

她看了一会儿, 然后**又把它们放回去了**。

纸箱空着。

_她在试。_

_她在演练"如果我要走"。_

_但她还没决定。_

_或者她决定了但还没行动。_

_或者她在跟自己确认"我可以放下这些"。_

她抬头看到我在看她。

她笑了一下。

"换季, 整理一下。"

她坐回工位。

// 没有选项 - 留白 (未指明走/留)
// hidden flag: Lisa 演练收纸箱 D23 - S2-S3 cue back

~ check_state_after_choice()
-> day_23_event_2_david_q3_planning


// ----------------------------------------------------------------------------
// Event 23.2 · David 写"周一计划" · 16:00
// ----------------------------------------------------------------------------
// 触发: 第 6 个 event
// 速度: 标准 (~6 行)
// 同框: David (远端 visible)
// 设计意图: David 卷得越来越远 - S6 燃尽 root cause
// ----------------------------------------------------------------------------

= day_23_event_2_david_q3_planning
# scene: workstation_facing_david
# time: 16:00
# npc: david_writing_q3_week1_okr
# prop: word_doc_q3_week1_okr_with_12_deliverables

16:00。你回头瞥到 David 工位。

他屏幕开着 Word, 标题: **Q3 第一周个人 OKR 规划**。

_Q3 第一周。_

_今天是 Q2 倒数第 4 天。_

_他已经在做 Q3 的事。_

_他比所有人都早进入 Q3。_

_他的 Q3 第一周计划上写了 12 项 deliverable。_

_他下周一周一就要执行 12 项 deliverable。_

// 笑点 + setup - David 卷得很累 (S6 燃尽 root cause)

_他每周加班 + 周末自拍工位 + 周二早上 @所有人感谢自己加班 + 现在周二写 Q3 第一周。_

_他没在做"工作"。他在维持"我在工作"这个状态。_

_维持这个状态的成本是他的精力 + 他的家庭 + 他的睡眠 + 他的"潜力"。_

_他不会停。直到他停的那天他就燃尽了。_

// hidden flag: David Q3 第一周 12 项 deliverable D23 - S4 燃尽前兆 setup

~ check_state_after_choice()
-> day_23_after_work


= day_23_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    你回到工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_23_daily_recap


= day_23_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Lisa 演练收纸箱** (不指明走 / 留 - S3 finale 才决定)_
_  - **David 周二就在写 Q3 第一周** (S6 燃尽 root cause)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_24_morning_briefing


// ============================================================================
// Day 24 · 周三 · 晨会日
// ============================================================================

= day_24_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:25

周三是晨会日。

# scene: meeting_room
# time: 9:25
# npc: lisa_arriving_with_you
# npc: david_with_q3_sticky
# npc: lao_zhou_in_back

9:25 你到会议室。

Lisa 在了——但今天她**没有提前 5 分钟**。她跟你一起 9:25 到。

_她的"提前 5 分钟"原来是她周一周二独家。_

_周三本来是她的 sweat 日。_

_今天她不 sweat 了。_

_她在保留体力。_

David 已经在了——他笔记本封面贴着"**Q3 第一周冲刺计划**"。

老周 9:00 准点到。

* [开始今日]
    -> day_24_event_1_wang_praises_david


// ----------------------------------------------------------------------------
// Event 24.1 · 晨会 · 王总监表扬 David · 9:32 (David D Finale)
// ----------------------------------------------------------------------------
// 触发: morning_briefing 后
// 速度: 长 (~10 行)
// 同框: 王总监 + David + Lisa + 老周 (背景) + 笑天
// NPC archetype: David D Finale - 系统认证他的"卷"
// ----------------------------------------------------------------------------

= day_24_event_1_wang_praises_david
# scene: meeting_room
# time: 9:32
# npc: wang_with_q2_month_end_ppt
# npc: david_smiling_nodding
# npc: lisa_pretending_to_take_notes

9:32 王总监推门进来。今天 PPT 第一页: **Q2 月末冲刺**。

"上午好啊各位。这个月还有 4 天。我先表扬一下——"

他停顿了 0.5 秒。

"**David。本月 KPI 最先到位。各位向 David 学习。**"

David 笑了。**他点了一下头**。

_他下午 4 点已经在写"周一计划"。我看到他屏幕了。_

_他周二写的是 Q3 第一周。_

_他比王总监表扬的"本月 KPI 最先到位"还多走了一步。_

_但王总监不知道。或者王总监知道。但王总监在表扬"行为", 不是"成果"。_

王总监继续："我们这个团队啊, 是有未来的。"

他眼神扫过 Lisa 那边。

Lisa 低着头记笔记。

_她的笔今天没墨——你瞥到她在用同一个角度反复写。_

_她在记笔记的姿态, 不是真的记。_

// 没有选项 - David D Finale + Lisa quiet vulnerability
// 这是 S1 anti-Pillar 1 的 mini-mirror - 你卷了, 你被表扬, 但下月 threshold 还是会涨
~ david_score = david_score + 0   // 他自己 +1 自我感动, 但 score 不变
~ lisa_score = lisa_score - 3     // quiet, 她不知道你看到了她假记笔记

~ check_state_after_choice()
-> day_24_event_2_wang_to_lisa


// ----------------------------------------------------------------------------
// Event 24.2 · 散会后 · 王总监经过 · 9:55 (修 3 应用)
// ----------------------------------------------------------------------------
// 触发: 散会后
// 速度: 闪 (~4 行)
// 同框: 王总监 + Lisa + 笑天 (看到)
// 修 3 应用 (per Q3.2 designer CHANGE):
//   旧: "Lisa, 下午 3 点跟我对一下。"  (PIP-feel 太重)
//   新: "Lisa, 下周方案给我看下。"     (manager-style push 去 PIP-feel)
// ----------------------------------------------------------------------------

= day_24_event_2_wang_to_lisa
# scene: hallway_back_to_workstation
# time: 9:55
# npc: wang_walking_toward_lisa_workstation
# npc: lisa_at_her_desk

散会, 9:55。你回工位。

王总监走在你前面, 他没回独立办公室——他走向 Lisa 工位。

他停在 Lisa 工位旁。

你听到他: "Lisa, **下周方案给我看下**。"

# speaker: lisa
Lisa："嗯, 王总监。"

王总监走了。

// 修 3 应用: 从原"下午 3 点跟我对一下" lighten 为 manager-style push
// 同样达到"S2 王总监 push Lisa 频率上升"的 setup, 去 PIP-feel

_下周方案。_

_他单独叫她。_

_4 周前晨会他公开 cue 她"潜力"。_

_今天他单独叫她。_

_S2 他可能更频繁单独叫她。_

_或者今天就是普通的 push——我在 over-read。_

// hidden flag: 王总监单独叫 Lisa "下周方案" D24 - S2 王总监 push Lisa 频率 +1 setup

~ check_state_after_choice()
-> day_24_after_work


= day_24_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    你回到工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_24_daily_recap


= day_24_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **David D Finale** (晨会被表扬"KPI 最先到位")_
_  - Lisa 假记笔记_
_  - 王总监单独 push Lisa "下周方案给我看下" (S2 push 频率 setup)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_25_morning_briefing


// ============================================================================
// Day 25 · 周四
// ============================================================================

= day_25_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:13

# scene: office_workstation
# time: 9:13
# npc: lisa_arriving_at_9_11

9:13 到公司。Lisa 9:11 已经在——今天她又比你早了。

_她周三王总监单独叫她之后, 她周四早上来得比平时早。_

_她在"做姿态"。_

* [开始今日]
    -> day_25_event_1_david_lunch_invite


// ----------------------------------------------------------------------------
// Event 25.1 · David 请笑天吃饭 · 中午 12:00
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 长 (~10 行)
// 同框: David + 笑天
// 设计意图: David Q3 借力 setup
// ----------------------------------------------------------------------------

= day_25_event_1_david_lunch_invite
# scene: workstation_with_david_approaching
# time: 12:00
# npc: david_with_thermos_back_clean

12:00。David 走过来。他保温杯回来了——洗干净了, 今天泡的不是枸杞茶, 是普通绿茶。

"兄弟, 中午一起吃饭吧。"

_他主动请。_

_他周一说话还在试探。今天他直接请。_

_他在做什么。_

_可能是 KPI 最先到位之后他想"庆祝"。_

_或者他想看我对他的态度。_

_或者他想要我下个月继续帮他改 PPT。_

_或者三者都是。_

* [一起]
    你跟 David 下楼吃了一份小炒。
    David 主动付了钱 (**168 元**——他点了 4 个菜 2 杯啤酒)。
    吃饭的时候 David 说了 3 段话：
    1. "下月 Q3 大家都要冲, 咱们部门 KPI 阈值肯定涨。"
    2. "我手上有 3 个项目, 到时候帮人也是常事。"
    3. "你看这次 KPI 最先到位的是我, 但你 Q3 也可以的。"
    你听他说话, 没怎么接。
    _他在 setup 下个月。_
    _他在告诉我"我会继续吸你的血"。_
    _但他不直接说, 他用"帮人是常事"包装。_
    ~ david_score = david_score + 5
    ~ state = state + 3
    // hidden flag: David 设 Q3 借力 setup - S2 周一他第一条消息会是"5 分钟的事"

* [我有别的约]
    # speaker: david
    David："好, 下次。"
    _他自己下楼。回来时手里没多任何东西。_
    ~ david_score = david_score - 3

* [我吃便当]
    # speaker: david
    David："好。"
    _他自己下楼。回来时跟你说"哎那个小炒店今天小炒黄牛肉特价不错。"_
    _他笑了一下走了。_
    ~ david_score = david_score + 0
    // hidden flag: David 没生气你拒绝

- _不论选什么。_
- _David 在做什么的"开始"。_
- _他 Q3 会再来。_
- _他到 S6 finale 都不会停。_

~ check_state_after_choice()
-> day_25_event_2_lisa_leaves_early


// ----------------------------------------------------------------------------
// Event 25.2 · 下午 16:30 · Lisa 准点走 · 下午
// ----------------------------------------------------------------------------
// 触发: 第 6 个 event
// 速度: 闪 (~3 行)
// ----------------------------------------------------------------------------

= day_25_event_2_lisa_leaves_early
# scene: workstation_with_lisa_standing_to_leave
# time: 16:30
# npc: lisa_packing_early

16:30。Lisa 站起来。

她收东西比平时早。

她抬头看你: "今天我有事, 先走。"

你: "嗯。"

她走了。

// 没有选项 - Lisa "有事"留白 (面试 / 体检 / 造型 / 真的有事)
// hidden flag: Lisa 周四 16:30 提早走

~ check_state_after_choice()
-> day_25_after_work


= day_25_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    你回到工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_25_daily_recap


= day_25_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - David 主动请笑天吃饭 (试探 / 庆祝 / Q3 setup)_
_  - Lisa 16:30 提前走_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_26_morning_briefing


// ============================================================================
// Day 26 · 周五 weekly_recap day · S1 finale 前置
// ============================================================================

= day_26_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:08

# scene: office_entrance
# time: 9:08
# npc: vivian_smiling_low_voice
# prop: a4_year_end_announcement_REMOVED

9:08 到公司。

Vivian 工位旁——**"年终福利预告" 告示已经撤掉了**。

_周一贴的, 周五撤的。撑了 4 天。_

_可能 HR 部门或老板临时改主意。_

_或者老板老婆看到了。_

你看了 Vivian 一眼——她笑了一下: "**老板说先撤, 再观察。**"

她压低声音: "我跟你说啊, **HR 部门有不同意见**。"

// Vivian 撤销福利预告 = S12 setup 加深 + Zoe S6 升级"高级 HR" setup
// "HR 部门有不同意见" = HR 有自主决策权 (Zoe S6 升级 root cause)

* [开始今日]
    -> day_26_event_1_weekly_recap_overlay


// ----------------------------------------------------------------------------
// Event 26.1 · weekly_recap 浮层 · 16:50
// ----------------------------------------------------------------------------

= day_26_event_1_weekly_recap_overlay
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出 weekly_recap 浮层。

- 出勤率: 100%
- 主动产出条目: N 项 (取决于本周选择)
- 协作记录: N 项

浮层底部: "**本月度 KPI 还有 2 天。月度考核浮层将于周日 9:30 启动, 请关注个人邮箱。**"

_周日 9:30。月度考核浮层。_

_Lisa 4 周前周日晚 21:30 准备的就是这个时刻。_

_我现在准备的也是这个时刻。_

_但准备没用——浮层会告诉我答案, 不管我准备什么。_

// hidden flag: 周五 weekly_recap 月度考核倒数 2 天

~ check_state_after_choice()
-> day_26_after_work


= day_26_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    你回到工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_26_daily_recap


= day_26_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Vivian 撤销福利预告** ("HR 部门有不同意见"——S12 + Zoe S6 升级 setup)_
_  - HR 系统提示周日 9:30 月度考核浮层_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_27_weekend_morning


// ============================================================================
// Day 27 · 周六 (周末)
// ============================================================================

= day_27_weekend_morning
# scene: bedroom
# time: 11:42
# music: weekend_silence

你睡到 11:42 醒。

_今天比上周晚 10 分钟。我加速退步在继续。_

# diegetic_ui: phone_wechat_moments

朋友圈：

- David 发了一张图: "**Q2 收官, Q3 更上一层楼。** 配自拍 + 工位"——他周六还在公司
- Lisa 没发
- 你以前的同事发了一张"度假"——他在西藏

你点了外卖: 粥 + 油条 + 卤蛋 + 一杯豆浆。42 块。
~ money = money - 42

_周末该花钱。这周花得有点多。_

# diegetic_ui: phone_wechat_message
# npc: mom_via_phone

12:34, 妈妈微信: "**天天, 明天 8:30 视频。**"

_她每周六提醒我一次。她每周日都视频。她从来没失约。_

_4 周了。她从来没失约。_

* [开始今日]
    -> day_27_event_1_passing_office_one_light


// ----------------------------------------------------------------------------
// Event 27.1 · 14:00 · 路过公司
// ----------------------------------------------------------------------------

= day_27_event_1_passing_office_one_light
# scene: street_passing_office_building
# time: 14:00

14:00 你出门吃饭, 又路过公司大楼。

你抬头——16 楼**有 1 个工位灯亮**。

_可能是 David。_

_可能是王总监 (他自己在加班 since E3 周三晚)。_

_不管是谁, 明天都会很累。_

// 没有选项 - flavor
~ state = state + 30   // regenForRestDay

~ check_state_after_choice()
# pagebreak
-> day_27_daily_recap


= day_27_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - David Q2 收官朋友圈_
_  - Lisa 整周未发朋友圈_
_  - 16 楼 1 个工位灯亮_

# pagebreak
-> day_28_weekend_morning


// ============================================================================
// Day 28 · 周日 · ★ S1 Finale ★
// ============================================================================

= day_28_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

# diegetic_ui: phone_video_call_incoming
# npc: mom_calling

8:30:00 整。微信视频铃响。

* [接通]
    -> day_28_event_1_mom_video_d


// ----------------------------------------------------------------------------
// Event 28.1 · 8:30 妈妈视频 (妈妈 D Finale)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~12 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 D Finale - "妈给你留的" 是她在 escalate 想念
// ----------------------------------------------------------------------------

= day_28_event_1_mom_video_d
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen
# prop: kitchen_fridge_with_food

你接了。

# speaker: mama
妈妈："**天天, 吃了吗？**"

# speaker: protagonist
你："吃了。"

_我没吃。我刚醒。_

# speaker: mama
妈妈："**工资发了吗？**"

# speaker: protagonist
你："发了。"

_发了。但下个月年终奖可能没了。_

# speaker: mama
妈妈："**那个谁的儿子, 那个谁的女儿, 前几天我又听人说咯。**"

# speaker: protagonist
你："嗯。"

_她今天没具体说哪个谁。她在打"我说了"卡。_

# speaker: mama
妈妈："**你呢？**"

# speaker: protagonist
你："**再等等。**"

妈妈停了 1 秒。

"天天, 你妈给你看冰箱里——"

她把镜头对准冰箱。冰箱里是一碗汤 + 一盒水饺 + 一盘菜 (看起来是青椒炒肉)。

"**这是妈给你留的。**"

她又转回镜头："你下次回来吃。"

* [妈我月底回去]
    # speaker: mama
    妈妈："好好好。"
    _她笑了一下, 眼睛亮了。_
    ~ mom_score = mom_score + 5

* [嗯, 谢谢妈]
    # speaker: mama
    妈妈："没事, 你忙。"
    _她挂了。_
    ~ mom_score = mom_score + 1

* [妈我可能还要再过段时间]
    # speaker: mama
    妈妈："好的。"
    _她声音平稳, 但眼睛低了。_
    ~ mom_score = mom_score - 2

- _不论选什么。_
- _她给你看冰箱。_
- _她每周日都做同样的事。她每周都问"你呢"。_
- _今天她加了"妈给你留的"。_
- _她在加。_
- _她在每周加 1 个东西。_
- _4 周前是"你那边冷不冷"。3 周前是"我寄毛衣"。2 周前是"那个王二家儿子上海买房了"。今天是"妈给你留的"。_
- _她在 escalate 想念。_
- _她不会承认。她说"你忙"。但她每周加 1 句让我知道。_

// hidden flag: 妈妈 D28 D Finale - series-level, 每集周日妈妈都会 escalate 1 句新的

~ check_state_after_choice()
-> day_28_event_2_kpi_review_overlay


// ----------------------------------------------------------------------------
// Event 28.2 · ★ 9:30 KPI Review 浮层揭晓 ★ (集内高峰 + S1 Finale Core)
// ----------------------------------------------------------------------------
// 触发: 周日 9:30 自动
// 速度: 长 (~25 行 - verbose)
// 同框: (无 NPC——浮层 only)
//
// 修 2 应用 (per Q2.4 designer CHANGE):
//   旧: 数学公式 next_threshold = max(本月达标值, 上月阈值) × (1 + 本月超额比例)
//   新: 去 expose 数学公式, 改用 qualitative 描述 + 离散 lookup 表 +
//       系统注释"每个员工都将根据自己的最佳表现承担更高责任。"
// ----------------------------------------------------------------------------

= day_28_event_2_kpi_review_overlay
# scene: bedroom_phone_email
# time: 9:30
# diegetic_ui: phone_show_kpi_review_overlay
# music: system_sterile_silence

9:30:00 整。

你的手机邮箱响了一声。**HR 系统**: 「Q2 月度考核结果通知」。

你点开。

浮层：

═══════════════════════════════════════════
            **Q2 月度考核结果**
═══════════════════════════════════════════

陈笑天先生 (产品助理 / 王总监团队)

考核期间: 2026-04-30 至 2026-05-26
本期 KPI 阈值: 100
您的本月 KPI 完成度: {kpi}
判定结果: [系统根据玩家累积自动判路径 A-E]

═══════════════════════════════════════════
                **考核详情**
═══════════════════════════════════════════

· 出勤率: 100%
· 主动产出条目: [N]
· 协作记录: [N]
· 加班申报次数: {effort_overage}
· 周报按时提交率: 100%

═══════════════════════════════════════════
                **下月预告**
═══════════════════════════════════════════

· 系统评估: 你本月的"付出度" 被记录为 [卷王模式 / 标准达标 / 险过 / 装病摸鱼 / 全程摸鱼] (按累积自动判)
· 下月 KPI 阈值调整: 100 → [110 / 105 / 105 / 103 / 101] (路径 A-E 离散 lookup)
· 下月 KPI 周期: 2026-05-27 至 2026-06-23

· **系统注释**: "每个员工都将根据自己的最佳表现承担更高责任。"

═══════════════════════════════════════════
              **王总监评语**
═══════════════════════════════════════════

[根据路径不同 - 见下方 5 路径条件块]

═══════════════════════════════════════════

// 修 2 应用: 去 expose 数学公式, 改用 qualitative 描述 + 离散 lookup
// 公式真相被隐藏 ("每个员工都将根据自己的最佳表现承担更高责任" 是 PUA 包装的真相)

// ============================================================================
// 5 路径揭晓 - 根据 effort_overage / lisa_helped_pps / david_blood_drawn / sick_count
// 系统判路径 A-E (具体阈值 per round-1 reply §1.3 hard rule)
// ============================================================================

{ effort_overage >= 4 and lisa_helped_pps and david_blood_drawn >= 1:
    // 路径 A · 卷王模式
    系统评估: 卷王模式

    本月 KPI 完成度: 远超 +30%
    判定结果: 「优秀」
    下月 KPI 阈值: 100 → 110 (+10%)
    王总监评语: "你做得真好。下个月看你的。"

    _你做得最好。下月最难。_

    _王总监说"看你的"。意思是 S2 起他每周会单独 cue 你 deliverable。_

    _你的"效率"被系统记录为 baseline。_

    _你的下月最好成绩 = 你下下月的最低标准。_

    ~ wang_score = wang_score + 10
    // hidden flag: 你被王总监 mark 为 high performer - S2 起 cue 频率 +2 / 集
}
{ lisa_helped_pps and david_blood_drawn == 0 and effort_overage < 4:
    // 路径 B · 标准达标 + 帮 Lisa
    系统评估: 标准达标

    本月 KPI 完成度: 微超 +5%
    判定结果: 「达标」
    下月 KPI 阈值: 100 → 105 (+5%)
    王总监评语: "嗯, 及格。继续。"

    _一切正常。下月还是更难。_

    _Lisa 在 S2 状态下滑你看着——你帮她改了一次 PPT, 但 S2 王总监单独 cue 她 4 次, 你帮不到那种程度。_

    ~ wang_score = wang_score + 0
    // hidden flag: Lisa S2 仍可能向你 reach out 1-2 次 (她记得你帮过她)
}
{ david_blood_drawn >= 1 and not lisa_helped_pps:
    // 路径 C · 险过 + 帮 David
    系统评估: 险过

    本月 KPI 完成度: 险过 +1%
    判定结果: 「合格」
    下月 KPI 阈值: 100 → 105 (+5%)
    王总监评语: "勉勉强强。"

    _你帮了 David。他下月会更卷——他周二就在写 Q3 第一周 12 项 deliverable。_

    _Lisa 没靠近你。S2 你想救她也来不及。_

    _S2 她状态下滑那段, 她不会向你 reach out。_

    // hidden flag: David S2 主动联系你 +5 次 (他记住"你能用") ; Lisa S2 不主动联系你
}
{ sick_count >= 1 and effort_overage < 2:
    // 路径 D · 装病请假 1 次 + 摸鱼
    系统评估: 装病摸鱼

    本月 KPI 完成度: 险过 -1%
    判定结果: 「合格」
    下月 KPI 阈值: 100 → 103 (+3%)
    王总监评语: "你看起来不太对。"

    _你看起来不太对。_

    _王总监说这话的意思是——他开始关注你"潜力"。_

    _他下个月会单独 cue 你的频率会增。_

    _不是 push 你做事, 是 push 你"显得在做事"。_

    ~ wang_score = wang_score + 5
    // hidden flag: 王总监开始 monitor 你 - S2 单独 cue 你 +3 / 集
}
{ effort_overage <= 0 and not lisa_helped_pps and david_blood_drawn == 0:
    // 路径 E · 全程摸鱼 + 不帮任何人
    系统评估: 全程摸鱼

    本月 KPI 完成度: 险过 -3%
    判定结果: 「合格 (边界)」
    下月 KPI 阈值: 100 → 101 (+1%)
    王总监评语: (无评语 / 只勾选了"达标")

    _你最轻松。_

    _但你的 effort_history 第 1 条记录是"什么都没做"。_

    _S2-S3 你想帮 Lisa 也帮不了——你没在 S1 建立任何关系。_

    _你 S2 进会议室, Lisa 抬头看你 0.5 秒, 然后低头继续工作。_

    _你 S3 听到她要走, 你想说"我帮你", 但她已经把你 mute 了。_

    _你最轻松。也最空。_

    // hidden flag: 所有 NPC S2 起冷处理你 - S1 关系全空
    // S3 finale 路径 A "救 Lisa" 不可能触发
}

// 5 路径共同点 (anti-Pillar 1 教学瞬间)

═══════════════════════════════════════════
              **系统提示**
═══════════════════════════════════════════

· 您的本月 KPI 已达标 (5 条路径全过)
· 您的下月 KPI 阈值已根据本月表现调整 (见上)

· **系统注释**: "每个员工都将根据自己的最佳表现承担更高责任。"

═══════════════════════════════════════════

_系统注释。_

_翻译过来就是: 你做得越好, 下月越难。_

_**你今天的最好成绩, 是你明天的最低标准。**_

_王总监 4 周前晨会讲的那句话。_

_今天 9:30 浮层验证了。_

_他不是在 PUA。他在讲事实。_

_他自己可能也不知道这是事实。或者他知道。_

_不管哪种。我现在知道了。_

_你今天的最好成绩, 是你明天的最低标准。_

// 这是 S1 anti-Pillar 1 的核心教学瞬间
// 没有 Game Over - 教学集 - 5 路径全过, 痛在下月

~ check_state_after_choice()
-> day_28_event_3_zoe_kpi_notice


// ----------------------------------------------------------------------------
// Event 28.3 · 11:00 · Zoe 群里发 KPI 通报 (Zoe D Finale)
// ----------------------------------------------------------------------------
// 触发: 浮层揭晓后 1.5 小时
// 速度: 标准 (~7 行)
// 同框: Zoe (群消息)
// NPC archetype: Zoe D Finale - cool execution + 1 个字"哈"的 quiet warmth
// ----------------------------------------------------------------------------

= day_28_event_3_zoe_kpi_notice
# scene: home_phone_messages
# time: 11:00
# diegetic_ui: phone_wechat_group_message
# npc: zoe_via_group_message

11:00。HR 部门企业微信群弹出消息。

> **Zoe (HR)**: 本月度 KPI 通报已下发, 请各位收件箱查收。如对结果有疑问, 请联系直属上级。

5 分钟后, Zoe 单独 @ 你：

> **Zoe (HR)**: **陈笑天先生**, 请到 HR 处签收 KPI 通报正本。本周内即可。

{ zoe_score >= 5:
    // E2 周四 Zoe B 选了"对她笑一下" - layer-2 callback 触发
    > **Zoe (HR)**: 哈, 不急。

    _陈笑天先生。_

    _4 周了。她还是叫这个。_

    _但今天结尾加了 1 个字——"哈"。_

    _"本周内即可哈"——她加了"哈"。_

    _她周四 17:25 担心"我们要是被裁了"。_

    _今天她在群里 cool execution。但她单独 @ 我加"哈"。_

    _可能是 E2 周四我对她"笑了一下"那个 B 选项的 callback。_

    _或者不是。她对所有人都加"哈"。_

    _我不会知道。_
}
{ zoe_score < 5:
    // 普通 cool execution - 没有"哈"
    _陈笑天先生。_

    _4 周了。她还是叫这个。_

    _今天的语气和往常一样。_

    _她在 cool execution。_

    _我对她笑一下也不会得到她的回应。_

    _或者她有"哈", 但只对她信任的人加。_
}

// Zoe D Finale - "哈" 是 E2 周四 B 路径的 callback (zoe_score >= 5)

~ check_state_after_choice()
-> day_28_event_4_anti_climax_4_npc_d_finale


// ----------------------------------------------------------------------------
// Event 28.4 · 11:30 · 笑天回工位看反高潮 4 NPC D Finale
// ----------------------------------------------------------------------------
// 触发: 去 HR 签字回来路上
// 速度: 长 (~14 行)
// 同框: 老周 + 李阿姨 + IT 小马 + David + 笑天
// NPC archetype: 老周 D + 李阿姨 D + IT 小马 D + David visible
// 设计意图: 反高潮 S1 finale - 世界没改变, 改变的只有笑天的内在认知
// ----------------------------------------------------------------------------

= day_28_event_4_anti_climax_4_npc_d_finale
# scene: office_sunday_afternoon
# time: 11:30
# npc: lao_zhou_packing_up_at_18
# npc: david_eating_lunch_at_workstation
# npc: li_ayi_mopping_david_workstation_more_carefully
# prop: it_xiaoma_new_sticky_swap

11:30。你去 HR 工位区签字 (如果你接受 Zoe 的安排)。

你回工位的路上经过 ——

# scene: corner_workstation_lao_zhou
# npc: lao_zhou_packing_up_quietly

老周工位: 他在收拾东西。**他不参加 KPI Review**——他级别太老, 不在月度 KPI 体系里。他的 3 个茶杯今天还在桌上, 他没收。他抬头看你 0.5 秒, 没说话。准点 18:00 他会离开。

_他不参加 KPI Review。_

_S1-S8 他每月都不参加。_

_他不被审。_

_或者他被审了 12 年, 不需要再审了。_

你继续走。

# scene: david_workstation_passing
# npc: david_eating_self_packed_lunch

David 工位 (David 周六加班, 今天周日他在): 他在吃午饭——盒饭, 自带的。他笑了一下, 对你说"**KPI 出来啦？怎么样？**" 你看了他一眼, 没说话。

_他知道我的 KPI 路径。_

_他不知道, 但他想知道。_

# scene: david_workstation_being_cleaned
# npc: li_ayi_mopping_thrice

李阿姨在拖 David 工位: David 周六加班把工位弄脏了——咖啡渍 + 便利贴撕掉的胶印 + 几张纸屑。李阿姨在拖, **比平时仔细**——她拖了 3 遍。

她抬头看了你 0.5 秒, 没说话。

_她拖 David 工位比平时仔细。_

_她可能因为他周六加班把工位弄脏了。_

_或者她因为别的。_

_她不会说。_

# scene: break_room_passing
# prop: coffee_machine_with_third_swap_sign

**茶水间咖啡机** —— 你顺路看了一下。

咖啡机告示**已经撤了**。咖啡机本身**还故障**——你按了启动按钮, 它响了一秒, 又咯咯了一秒, 停了。

旁边贴了**新通知**: "**零件已到, 本周修复**"——和上周二的告示一字不差。

_IT 小马撕了"已到货, 本周修复"贴新的"零件已到, 本周修复"。_

_他换了语序。_

_他的 OKR 推进了。_

_咖啡机还是不能用。_

// 老周 D + 李阿姨 D + IT 小马 D + David visible 在 ~10 分钟内连续触发
// 反高潮 S1 finale - 世界没改变, 改变的只有笑天的内在认知

~ check_state_after_choice()
-> day_28_event_5_lisa_passed_too


// ----------------------------------------------------------------------------
// Event 28.5 · 12:30 · 工位的 Lisa (Lisa D Finale 的轻量版)
// ----------------------------------------------------------------------------
// 触发: 回工位
// 速度: 标准 (~6 行)
// 同框: Lisa
// NPC archetype: Lisa D Finale (light) - "我又过了" 但 quiet sign 显现
// 注意 (per spec 红线): Lisa 在 S1 末状态 OK - 不是 finale 走 / 留 (那是 S3 = E12)
// ----------------------------------------------------------------------------

= day_28_event_5_lisa_passed_too
# scene: workstation_with_lisa_at_her_desk
# time: 12:30
# npc: lisa_with_kpi_pdf_open_then_closed

12:30。你回工位。Lisa 在工位——她周日也来了。

她在自己 KPI 通报。她打开 PDF 看了一会儿, 关掉。

她抬头看你。

"**笑天, 你也过了？**"

你: "嗯。"

Lisa: "我也过了。**我感觉我可能不太适合**——但我又过了。"

她笑了一下。

// Lisa D Finale (light) - 她过了, 但她的"感觉不适合"还在
// S1 末状态 OK 但 quiet sign 显现 - S2 状态下滑的 prologue
// 不能让 Lisa 在 E4 finale 走 / 留 - 那是 S3 finale = E12

_她过了。_

_她说"我可能不太适合"。_

_4 周前她说同样的话。今天她又说一次。_

_4 周里她说了 4 次"我可能不太适合"。_

_她每周说一次。_

_她还在说, 意味着她还在留。_

_但她每周都说, 意味着她可能在准备走。_

// hidden flag: Lisa S1 末状态 OK 但 quiet sign 显现 - S2 状态下滑 root cause

~ check_state_after_choice()
-> day_28_event_6_lisa_overtime_msg


// ----------------------------------------------------------------------------
// Event 28.6 · 21:30 · Lisa 微信 (Series Cliffhanger 至 S2)
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 标准 (~5 行)
// 同框: Lisa (微信)
// 设计意图: Series cliffhanger 至 S2 - S2 第 1 集 (E5) 开局兑现
// ----------------------------------------------------------------------------

= day_28_event_6_lisa_overtime_msg
# scene: home_evening_after_shower
# time: 21:30
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:30。你刚洗完澡。

微信消息 1 条。

# speaker: lisa
Lisa：

"笑天, **下个月开始我可能加班多一点。**"

_下个月开始我可能加班多一点。_

_她没说为什么。_

_可能是 KPI 通报让她意识到要加。_

_可能是王总监周三下午对完之后给她加了任务。_

_可能是她自己决定。_

_可能是别的。_

_她没说。我没问。_

* [嗯, 加油]
    Lisa: "好。"
    _没了下文。_
    ~ lisa_score = lisa_score + 0

* [你还好吧]
    Lisa: "**还好啦。下个月再说吧。**"
    _没了下文。_
    ~ lisa_score = lisa_score + 1
    // hidden flag: Lisa 说"下个月再说"

* [不回]
    _她没追问。_
    ~ lisa_score = lisa_score - 1

- _不论选什么。_
- _她周日晚 21:30 发了这条消息。_
- _4 周前她周日晚 21:30 在准备"如果王总监 cue 我我怎么答"。_
- _今天她周日晚 21:30 在告诉我"下个月加班多一点"。_
- _她从"备考"变成"自己执行"。_
- _她不再问。她在做。_

// Series cliffhanger 至 S2 - S2 第 1 集 (E5) 开局兑现:
//   王总监第一次单独 cue 她 (不是在晨会公开 cue), 她周一来公司就开始加班
// hidden flag: S1 → S2 cliffhanger - Lisa 下个月加班多一点

~ check_state_after_choice()
-> day_28_e1_finale_recap


// ----------------------------------------------------------------------------
// Event 28.7 · 22:00 · 周日日报 + S1 末
// ----------------------------------------------------------------------------
// 触发: 21:30 之后自动
// 速度: 长 (~10 行)
// ----------------------------------------------------------------------------

= day_28_e1_finale_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_and_s1_finale

═══════════════════════════════════════════
            **周日 (Day 28) 日报**
            **★ Season 1 末 ★**
═══════════════════════════════════════════


· 今日 KPI: 考核结果——[路径 A-E]
· 关键时刻：
  - 8:30 妈妈视频"妈给你留的"
  - 9:30 KPI Review 浮层揭晓 5 路径
  - 11:30 反高潮: 老周收东西 / 李阿姨拖 David 工位 / IT 小马新告示 / David 笑问"KPI 怎么样"
  - 12:30 Lisa "我感觉我可能不太适合"
  - 21:30 Lisa 微信"下个月开始我可能加班多一点"

· 本月 (Q2) 累积：
  - Lisa score 总: {lisa_score}
  - David score 总: {david_score}
  - 王总监关注度: {wang_score}
  - 老周对话: 1 次"过完今天" (S1 唯一)
  - 妈妈视频: 4 次 (每周日)
  - Vivian 出场: 4 次 (4 个周一)

· **下月预告**:
  - KPI 阈值: 100 → [100+X] (路径 A-E 离散)
  - Lisa 状态: S2 王总监单独 push + 加班增加
  - David: Q3 第一周 12 项 deliverable
  - 王总监: (根据 S1 路径 A/D 不同) 单独 cue 你的频率会增

═══════════════════════════════════════════
            **★ Season 1 末 ★**
═══════════════════════════════════════════

· 你完成了入职第 12-15 周。
· 你过了第一次 KPI Review。
· 下个月会更难。
· 下下月会更更难。

· **下个月又是周一。**

═══════════════════════════════════════════

_下个月又是周一。_

_我以为 KPI Review 揭晓那一刻是高潮。_

_但其实高潮已经过了——周三晨会王总监讲那句话的时候。_

_今天的浮层只是验证。_

_我已经"知道了"。_

_但知道不让我"赢"。_

_知道只让我"准备好下个月输得更明白"。_

_Lisa 4 周前周日晚 21:30 在准备"如果王总监 cue 我"。_

_我现在准备的是"下个月又是周一"。_

_我成了 Lisa。_

_但 Lisa 在 21:30 给我发"下个月加班多一点"——_

_**她已经超过了我**。_

_她不再准备, 她在做。_

_我还在准备。_

_下个月又是周一。_

// E4 / S1 结束

-> END

// ============================================================================
// EOF episode-4.ink
// ============================================================================
