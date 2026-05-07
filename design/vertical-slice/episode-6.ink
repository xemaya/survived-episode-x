// ============================================================================
// Episode 6 · Week 6 · 「她不喝奶茶了」
// ============================================================================
//
// Status: 第 1 版 (W3 写, S2 Round 1)
// Author: 分身 CC session (W3 = S2 Round 1)
// Last Updated: 2026-05-05
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
// 主 spec: design/vertical-slice/season-2-arc.md §5 E6 beat sheet
//
// 设计目标 (摘要):
//   1. Lisa 状态下滑的 quiet sign 集中爆发 — 她的微小习惯一个个变
//   2. 周一 8:00 已在工位 (从 8:50 提前 50 分钟)
//   3. 周一 9:30 Lisa 桌上是 7-11 美式 — 第一次喝咖啡
//   4. 王总监周一**没等**笑天 — 笑天反而觉得空虚 (他习惯了被 push)
//   5. Zoe 偷听: "本月度面谈名单已经出来了" — 笑天不知 Lisa 在名单上 (隐藏 setup)
//   6. 周三晨会 王总监 cue Lisa: "那加把劲。"
//   7. 周日 妈妈"那个王二家儿子上海买房了" + "那个谁结婚了" — 升级 (S1 callback)
//   8. 6:4 笑泪比 — 笑减少
//   9. Cliffhanger 至 E7: Lisa 朋友圈"这周辛苦了" — 她从来没发过的 self-acknowledge
//
// 红线 (S2 不能做):
//   - Lisa 不能 决定走/留 (E12)
//   - HR 月度面谈不能在 E6 (E8)
//   - 王总监不能直接对 Lisa 讲"潜力一般" (Zoe / E8)
//   - 林姐 S2 仍不出场 (E5 mention only)
//   - Lisa 剪短发不在 E6 (E7 周一)
//   - David 不能燃尽 (E24 = S6 finale)
//   - 老周 S2 对话 = 0
//
// Verbatim quotes 必保留 (per season-2-arc.md §7):
//   - E6: 妈妈视频 "**那个王二家儿子上海买房了**" (callback + escalate from S1 E3 D21)
//
// ============================================================================

INCLUDE episode-1.ink

// E6 entry
-> episode_6


// ============================================================================
// Episode 6 主入口
// ============================================================================

=== episode_6 ===
# scene: home
# time: monday_morning_week_6
# pagebreak
-> day_36_morning_briefing


// ============================================================================
// Day 36 · 周一 · 第 6 周第 1 天 · 王总监没等笑天
// ============================================================================
// 关键 beat:
//   - 笑天 8:50 到 (努力提早 24 分钟回应 Lisa "8:00 见")
//   - Lisa 8:00 已在工位 — 比上周再提前 50 分钟
//   - 王总监**没等**笑天 (笑天反而空虚 — 他习惯了被 push)
//   - 9:30 Lisa 桌上 7-11 美式 — 第一次喝咖啡 (集内高峰)

= day_36_morning_briefing
# scene: home_then_subway_then_office
# time: 6:50_to_8:50
# weather: cleared

闹钟响了 1 次。**6:50。**

_我以前 7:30 闹。_

_今天 6:50 ——为了她周日"明天 8:00 见"那句话。_

_或者为了我自己想看她到底几点到。_

_或者两者都有。_

# scene: subway_carriage
# time: 7:50

地铁 6 号线——你今天比平时早 1 班车, 人少一半。

_早 1 班车的人是另一种生物——西装、保温杯、无表情。_

_我跟他们融得不好。_

_他们看起来比我熟练。_

# scene: office_entrance
# time: 8:50
# npc: vivian_at_reception
# prop: fruit_bowl_apple

8:50 到公司。

Vivian 抬头："嗨——"

她**愣了 1 秒**——她不习惯看到我这个时间。

"…来啦～" 她接上。

_她的"嗨"是 9:00 之后才形成肌肉记忆。8:50 时她还在 system loading。_

_她的微笑也是。_

水果盘**苹果**。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_36_event_1_lisa_at_8


// ----------------------------------------------------------------------------
// Event 36.1 · Lisa 8:00 已在工位 · 8:52
// ----------------------------------------------------------------------------
// 触发: 进入工位区
// 速度: 标准 (~6 行)
// 同框: Lisa (前景, 已在工位)
// 设计意图: 上周 8:50 → 这周 8:00 = quiet sign 加速
// ----------------------------------------------------------------------------

= day_36_event_1_lisa_at_8
# scene: workstation_entry
# time: 8:52
# npc: lisa_at_desk_shoulders_tense
# prop: lisa_mug_already_empty
# prop: lisa_eye_drops_now_third_empty

你走到工位区。

Lisa **已经在**——她屏幕上开着 PPT。

她奶茶杯**完全空了**——玻璃杯壁挂着干掉的奶。

她桌上眼药水**比上周 1/4 又少了 1/8**。

_她今天 8:00 真的到了。_

_她周日改了几版我没数。_

_她周日全天加班, 周一 8:00 + 早。_

_她说了"明天 8:00 见", 她兑现了。_

她抬头看了你一眼——

她说："你今天**也**早。"

_"也"。_

_她以为我每周一都 9:14 到。她以为我今天破例。_

_其实我也是为她破例。_

_但她以为我跟她一样在 push。_

* [我尽量到]
    # speaker: lisa
    Lisa："嗯。"
    _她转回工位。_
    ~ lisa_score = lisa_score + 2

* [呵呵]
    Lisa 笑了一下。"我今天 8 点到的, 改了 2 版。"
    _她跟我汇报。_
    ~ lisa_score = lisa_score + 0

* [不回答, 坐下]
    Lisa 不再说话, 转回工位。
    ~ lisa_score = lisa_score - 1

- _不论选什么。_
- _她周一 8:00 到。_
- _下周一可能 7:30。_
- _再下下周可能 7:00。_
- _她加速比我快。_

~ check_state_after_choice()
-> day_36_event_2_wang_no_show


// ----------------------------------------------------------------------------
// Event 36.2 · 王总监没等笑天 · 9:25 (笑天空虚)
// ----------------------------------------------------------------------------
// 触发: 进入工位 5 分钟后
// 速度: 长 (~10 行)
// 同框: 笑天 + 王总监独立办公室门关 (背景)
// 设计意图: S1 路径 A/D 玩家上周一被 cue, 这周一**没被 cue** = 笑天反而空虚
// ----------------------------------------------------------------------------

= day_36_event_2_wang_no_show
# scene: workstation_corner_with_wang_office_in_background
# time: 9:25
# npc: wang_office_door_closed
# prop: wang_office_no_light_visible

9:25。你抬头看王总监独立办公室方向。

**门关着。**

**没光。**

他**没出独立办公室**。

_上周一 9:25 他站在我工位旁。_

_这周一 9:25 他不在。_

_他是不是请假? 是不是去客户那边? 还是他单纯今天忙?_

_他没群里通报。_

你刷了一下企业微信——他的状态是"在线"。

_他在公司, 但他不来 cue 我。_

_我反而**觉得空了一块**。_

_我意识到这一点的时候我吓了一跳。_

_他周一不 cue 我, 我反而焦虑。_

_我已经被他驯化了。_

_S1 我反 cue, S2 第 1 周他 cue 我我抵抗, 第 2 周他不 cue 我我反而想被 cue。_

_这就是 PUA 链条——你最焦虑的是"还没被 push"。_

// 没有选项 - 笑天 PUA 链条 awareness

// hidden flag: 王总监 D36 没 cue 笑天 - 笑天空虚 (PUA 链条 self-awareness)

~ check_state_after_choice()
-> day_36_event_3_lisa_coffee_first_time


// ----------------------------------------------------------------------------
// Event 36.3 · Lisa 桌上 7-11 美式 · 9:30 (E6 集内高峰)
// ----------------------------------------------------------------------------
// 触发: 第 1 个 event 后
// 速度: 长 (~10 行)
// 同框: Lisa + 笑天
// 设计意图: Lisa 第一次喝咖啡 = E6 集内最深 quiet sign
// ----------------------------------------------------------------------------

= day_36_event_3_lisa_coffee_first_time
# scene: workstation_with_lisa
# time: 9:30
# npc: lisa_holding_711_americano_cup
# prop: convenience_store_americano_paper_cup

9:30。Lisa 站起来去茶水间。

她回来时手里——

不是奶茶。
不是保温杯。

是**一个 7-11 美式咖啡的纸杯**。

她从早 6 点开门的 7-11 在她家楼下买的。

她手里捧着, 走得慢一点——咖啡热。

她走过你工位时, 你闻到了——

**美式。**

_她从来不喝咖啡。_

_她奶茶 30 减 8 起送的 brand loyalty 持续了 5 个月。_

_今天她**第一次喝咖啡**。_

_而且是美式。不是拿铁。不是焦糖玛奇朵。是美式。_

_美式 = 咖啡因含量最高的低调款。_

_她要的是咖啡因, 不是味道。_

她坐回工位, 喝了一口——**她皱了一下眉**。

她喝不惯。但她还是喝。

_她也开始**装醒着**了。_

_S1 末她奶茶 + 良品铺子话梅 + 她的小零食抽屉。_

_S2 第 6 周她美式 + 加班 + 没拼奶茶 + 没零食。_

_她以前在补充能量。_

_现在她在抑制困倦。_

// 没有选项 - Lisa C Vulnerability quiet sign 高峰

// hidden flag: Lisa D36 第一次喝咖啡 (S2 第 6 周关键 quiet sign)

~ check_state_after_choice()
-> day_36_event_4_zhang_xiu_lao_zhou


// ----------------------------------------------------------------------------
// Event 36.4 · 经过老周工位 · 11:30 (laoZhou silent S2 baseline)
// ----------------------------------------------------------------------------
// 触发: 上午 11:30
// 速度: 闪 (~3 行)
// 同框: 老周 (背景)
// 设计意图: S2 老周对话 = 0 (per npcs.md §8) — 笑天主动看, 老周不抬头
// ----------------------------------------------------------------------------

= day_36_event_4_zhang_xiu_lao_zhou
# scene: corner_workstation_lao_zhou
# time: 11:30
# npc: lao_zhou_facing_window
# prop: three_tea_cups_arranged

11:30。你去打印机取一份纸。

老周工位旁边。

他还面对窗户。他在看 Excel——同 5 周前一致。

桌上 3 个茶杯——同 5 周前一致。

便利贴"过完今天"——同 5 周前一致。

_他 12 周前在这个位置。S1 第 1 周也是这样。今天还是。_

_"过完今天" 他过完 5 个今天, 又一个 5 个今天, 没换便利贴。_

_便利贴上的字开始模糊——但他没换, 因为他**记得字**, 字模糊不影响他。_

_我每周看一遍这张便利贴。_

_我也**记得字**了。_

_这是 S1 唯一对话的余响——他没说第二次, 但那 1 句永远在我脑子里。_

// 没有选项 - 老周 silent baseline

~ check_state_after_choice()
-> day_36_after_work


= day_36_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_still_at_desk_v14
# npc: david_already_packed_with_planner

17:30。

Lisa 在工位, 屏幕开着 PPT。

David 17:30 准时关电脑——他这周一也准点走。

_他可能在准备周二早起。_

_他抄我的 calibration——周日他问我"4 项 deliverable", 这周他抄数字 + 抄节奏。_

* [申报加班]
    你回工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    Lisa 没回头。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_36_daily_recap


= day_36_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Lisa 8:00 已在工位** (上周 8:50 → 这周 8:00)_
_  - 王总监**没等**笑天 — 笑天空虚 (PUA 链条 awareness)_
_  - **Lisa 第一次喝咖啡** — 7-11 美式 (E6 集内高峰 quiet sign)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_37_morning_briefing


// ============================================================================
// Day 37 · 周二 · Zoe 偷听 "本月度面谈名单"
// ============================================================================
// 关键 beat:
//   - 周二笑天经过 HR 工位听到 Zoe 跟另一个 HR: "本月度面谈名单已经出来了"
//   - 笑天听到, 但他不知道 Lisa 在名单上 (隐藏 setup)

= day_37_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_entrance
# time: 9:11
# npc: lisa_already_at_desk
# prop: fruit_bowl_apple_again

9:11 到公司——你周一 6:50 闹钟之后, 你今天回到 9:11 baseline。

_我没法每天 6:50。_

_我不是 Lisa。_

水果盘**仍是苹果**。

~ fruit_bowl = "apple"

# scene: office_workstation
# npc: lisa_at_desk_typing_slowly_today

Lisa 已经在工位——她屏幕开着 PPT。她**敲键盘速度比昨天慢**。

她桌上**第二杯 7-11 美式**已经空了一半。

_她今天又喝。_

_第 2 天连续。_

_她可能从今天起每天美式。_

* [开始今日]
    -> day_37_event_1_zoe_eavesdrop


// ----------------------------------------------------------------------------
// Event 37.1 · Zoe 偷听"月度面谈名单" · 11:30 (Zoe B Decision setup)
// ----------------------------------------------------------------------------
// 触发: 第 3 个 event
// 速度: 标准 (~7 行)
// 同框: Zoe + 另一个 HR + 笑天 (远端听到)
// NPC archetype: Zoe 隐藏 setup — 笑天不知 Lisa 在名单上
// ----------------------------------------------------------------------------

= day_37_event_1_zoe_eavesdrop
# scene: hr_workstation_corridor
# time: 11:30
# npc: zoe_at_water_dispenser
# npc: another_hr_with_clipboard

11:30。你去茶水间接水。

你经过 HR 工位区——Zoe 跟另一个 HR 站在饮水机旁。

她们没看你。她们低声在说。

但你接水的位置离她们 3 米。

你听到——

# speaker: zoe
Zoe："**本月度面谈名单已经出来了。**"

# speaker: zoe
另一个 HR："周几开始?"

# speaker: zoe
Zoe："周四。"

# speaker: zoe
另一个 HR："好的, 我下午发邮件给王总监 cc 一份。"

# speaker: zoe
Zoe："**记得 cc 林姐**。"

_本月度面谈名单。_

_S1 我没听过这个词。_

_S2 这是新的——HR "月度面谈" = 新的流程?_

_或者一直有, 我之前没听到。_

_名单。_

_周四开始。今天周二。_

_cc 林姐——林姐又出现了。第 3 次。_

_S1 E1 周四王总监打电话提林姐。_

_S2 E5 周三晨会王总监让 Lisa 去林姐那。_

_S2 E6 周二 Zoe 跟另一个 HR 提 cc 林姐。_

_林姐每次都"被提到"但从不出场。_

_她可能是"决策中心" — 她不在场, 但所有事都跟她有关。_

# scene: workstation_back

你接完水回工位。

* [今天没事]
    你没多想——HR 月度面谈, 跟你没关系。
    _你以为没关系。_
    ~ zoe_score = zoe_score + 0

* [谁的名单?]
    你想问 Zoe, 但她已经走开了。
    _你也没去 chase。_
    ~ zoe_score = zoe_score + 0

- _不论选什么。_
- _你听到了"月度面谈名单"。_
- _你不知道 Lisa 在名单上。_
- _这周四 Zoe 会找 Lisa。但你不知道。_
- _S2 隐藏 setup 完成。_

// hidden flag: 笑天偷听到 月度面谈名单 + 周四开始 + cc 林姐
// hidden flag: 笑天不知 Lisa 在名单上 - E8 才显形

~ check_state_after_choice()
-> day_37_event_2_lisa_no_lunch_again


// ----------------------------------------------------------------------------
// Event 37.2 · Lisa 中午仍接热水 · 11:55
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~3 行)
// 同框: Lisa (前景)
// ----------------------------------------------------------------------------

= day_37_event_2_lisa_no_lunch_again
# scene: workstation_lunchtime_quiet
# time: 11:55
# npc: lisa_with_thermos_again

11:55。Lisa 站起来——她去茶水间。

她带的是**保温杯**——不是奶茶杯。

她接热水。

她没去楼下 7-11 买午餐。

她从抽屉里拿出一袋**自热米饭**。

_她带饭了。_

_S1 她从来没带过饭。_

_她省了 25 块 (午饭外卖 + 奶茶 14 + 11)。_

_或者她单纯想自己带。_

_或者她在攒——不知道为什么要攒。_

// 没有选项 - quiet sign 累积

// hidden flag: Lisa 周二带饭 D37 (省钱 quiet sign)

~ check_state_after_choice()
-> day_37_after_work


= day_37_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_at_v15

17:30。Lisa 还在改 PPT。

* [申报加班]
    你回工位多干一会。
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
-> day_37_daily_recap


= day_37_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Zoe 偷听: "本月度面谈名单已经出来了"** (隐藏 setup, 笑天不知 Lisa 在名单)_
_  - 笑天第 3 次听到林姐名字 ("记得 cc 林姐")_
_  - Lisa 周二带饭 — 省钱 quiet sign_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_38_morning_briefing


// ============================================================================
// Day 38 · 周三 · 晨会 王总监 cue Lisa "那加把劲"
// ============================================================================
// 关键 beat:
//   - 晨会 王总监 cue Lisa "你这边 PPT 怎么样" → Lisa "还在赶" → 王总监"那加把劲"

= day_38_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:25
# weather: cleared

周三。

# scene: meeting_room
# time: 9:25
# npc: lisa_in_first_row_again
# npc: david_with_3_sticky_notes
# npc: lao_zhou_in_back

9:25 到会议室。

Lisa 提前 5 分钟到——同周二的固定。

David 笔记本贴**3 张便利贴**: "月度冲刺" / "deliverable list" / "本周 KPI"。

老周在最后一排。

9:32 王总监推门。

* [开始今日]
    -> day_38_event_1_morning_meeting_cue


// ----------------------------------------------------------------------------
// Event 38.1 · 晨会 王总监 cue Lisa "那加把劲" · 9:35
// ----------------------------------------------------------------------------
// 触发: 晨会进行中
// 速度: 长 (~12 行)
// 同框: 王总监 + David + Lisa + 老周 (背景) + 笑天
// NPC archetype: 王总监 standard cue + Lisa 反应
// 设计意图: 王总监第一次直接 push Lisa "加把劲" — S2 升级 S1 (S1 是 mass cue)
// ----------------------------------------------------------------------------

= day_38_event_1_morning_meeting_cue
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium
# npc: lisa_first_row_typing_notes
# npc: david_taking_notes_too

王总监打开 PPT——今天是"**月度 KPI 进度回顾**"。

"上午好啊各位。"

"我们这个团队啊, 月度过半了。"

"上周 deliverable 整体推进 OK, 但有几个项目我想个别 cue 一下。"

_个别 cue。S1 我以为我清醒, S2 第 6 周王总监第一次"个别 cue"。_

_他在升级 PUA 频率——从 mass 到 individual。_

王总监看 Lisa："**Lisa, 你这边 PPT 怎么样?**"

Lisa 抬头："**还在赶。下周一交林姐。**"

王总监 0.5 秒。

"**那加把劲。**"

3 个字。

无表情。

下一句他就转过去看 David。

"David, pps demo V3 推进怎么样?"

_他对 Lisa "加把劲"。_

_他对 David 用 deliverable 编号。_

_他对 Lisa 的语气是 management style "push"。对 David 是 collaborative "确认"。_

_差别极小, 但极清楚。_

_Lisa 的脸——半秒钟僵硬, 然后笑了一下。_

_她笑给我看的不是给王总监。_

_她可能在跟自己说"没事, 加把劲就行"。_

# speaker: david
David: "推进 OK, 周五前出 V4。"

# speaker: wang_director
王总监："好。"

# speaker: wang_director
王总监："散会。"

8 分钟。

_8 分钟散会, 但那 3 个字"加把劲"会跟着 Lisa 走 5 天。_

// 没有选项 - 王总监 cue Lisa 关键 beat

// hidden flag: 王总监 D38 cue Lisa "加把劲" (3 字 weight)

~ check_state_after_choice()
-> day_38_event_2_lisa_continued_typing


// ----------------------------------------------------------------------------
// Event 38.2 · 散会回工位 · 9:42
// ----------------------------------------------------------------------------
// 触发: 散会后
// 速度: 闪 (~4 行)
// 同框: Lisa + 笑天
// ----------------------------------------------------------------------------

= day_38_event_2_lisa_continued_typing
# scene: workstation_back_quiet
# time: 9:42
# npc: lisa_typing_immediately

9:42 回工位。

Lisa **直接坐下来**, 没拿水, 没看手机, 没换姿势。

她屏幕开 PPT, 立刻继续敲。

她的左手——

_她左手手心**没写"加油"**。_

_S1 E2 她桌下手心写"加油"——那是她的小自我激励。_

_S2 第 6 周她不写了。_

_她不需要写——她整个人都"加把劲" 了。_

// 没有选项 - Lisa quiet sign deepen

// hidden flag: Lisa S2 不再写"加油" — 她的自我激励 ritual 消失

~ check_state_after_choice()
-> day_38_event_3_lisa_eye_drops_again


// ----------------------------------------------------------------------------
// Event 38.3 · 下午 Lisa 滴眼药水 · 14:30
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 闪 (~3 行)
// 同框: Lisa (前景)
// ----------------------------------------------------------------------------

= day_38_event_3_lisa_eye_drops_again
# scene: workstation_with_lisa
# time: 14:30
# npc: lisa_dropping_eye_drops

14:30。你回头看——

Lisa 正在**滴眼药水**。

她仰头, 滴一滴, 又一滴, 第 3 滴。

她眨了 5 下眼。

她又滴了一次——**第 2 轮 3 滴**。

_S1 E3 周一她滴 2 滴。_

_S2 第 6 周她滴 6 滴。_

_她每次的剂量在加。_

_或者眼药水本身效用在递减——眼睛干到一定程度, 1-2 滴不够。_

// 没有选项 - quiet sign progression

// hidden flag: Lisa D38 滴眼药水 6 滴 (2x剂量)

~ check_state_after_choice()
-> day_38_after_work


= day_38_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_at_v16

17:30。Lisa 还在改。

* [申报加班]
    你回工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    Lisa 没回头。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_38_daily_recap


= day_38_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 晨会 王总监 cue Lisa "**那加把劲**" (3 字)_
_  - Lisa 散会后 0 间隔继续敲键盘 — 不再写"加油"_
_  - Lisa 下午滴眼药水 6 滴 (剂量翻倍)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_39_morning_briefing


// ============================================================================
// Day 39 · 周四 · Lisa 中午去 HR 工位办手续
// ============================================================================
// 关键 beat:
//   - Lisa 周四中午 12:30 去 HR 工位 — 笑天没看到她在那干嘛 (E8 的 setup)

= day_39_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周四。

# scene: office_workstation
# time: 9:11
# npc: lisa_at_desk_v17

9:11 到公司。

Lisa 在工位敲键盘。

她桌上又是 7-11 美式纸杯——**第 4 天连续**。

她已经"美式"了。

_今天王总监周四会不会来 cue 我?_

_或者他周三 cue 完 Lisa "加把劲" 已经满足。_

_我希望他来。_

_我希望他不来。_

_我两边都希望。_

* [开始今日]
    -> day_39_event_1_lisa_to_hr


// ----------------------------------------------------------------------------
// Event 39.1 · Lisa 中午去 HR 工位 · 12:30
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 标准 (~6 行)
// 同框: Lisa (背景, 离开)
// 设计意图: E8 finale Zoe 找 Lisa 谈话 — D39 周四 12:30 是预演 / 报名?
// ----------------------------------------------------------------------------

= day_39_event_1_lisa_to_hr
# scene: workstation_lunchtime
# time: 12:30
# npc: lisa_walking_to_hr_corridor

12:30。Lisa 站起来。

她**没拿保温杯**。

她**直接去 HR 工位方向**。

_她不是去茶水间。_

_她过了茶水间, 转左, 进 HR 走廊。_

_她去找 Zoe?_

_或者她去办什么手续?_

_或者她去签什么。_

_她离开工位前没跟我打招呼。_

她 12:48 回来——**18 分钟**。

她回来时**手里有一张 A4 纸**——折着, 看不清是什么。

她坐下, 把纸塞进抽屉。

她没看你。

_她去 HR 工位了 18 分钟。_

_她拿了 1 张 A4 纸。_

_我不知道是什么。_

_S2 E6 周四 Lisa 去 HR — 这是 E8 finale 月度面谈的前置 (Zoe 在做 Lisa 协作伙伴反馈采集)。_

_我不知道。她不知道。_

// 没有选项 - 隐藏 setup

// hidden flag: Lisa D39 中午去 HR 工位 18 分钟 - E8 setup
// hidden flag: Lisa 拿 A4 纸 (Zoe 给的反馈表? 月度面谈预约表?)

~ check_state_after_choice()
-> day_39_event_2_afternoon_quiet


// ----------------------------------------------------------------------------
// Event 39.2 · 下午工位 quiet · 15:00
// ----------------------------------------------------------------------------
// 触发: 第 5 个 event
// 速度: 闪 (~3 行)
// ----------------------------------------------------------------------------

= day_39_event_2_afternoon_quiet
# scene: workstation_afternoon
# time: 15:00
# npc: lisa_typing_steadily

15:00。

工位区静默。

Lisa 在敲键盘。

David 不在——他可能去 IT 角落了。

王总监独立办公室门关着, **有光**——他在里面。

_他在改自己的 PPT 还是在看名单?_

_或者他在看下属周报。_

_或者他在偷刷 Twitter。_

_独立办公室的好处是没人能看到他在做什么。_

// 没有选项 - flavor

~ check_state_after_choice()
-> day_39_after_work


= day_39_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在敲。David 17:30 准时关电脑。

* [申报加班]
    你回工位多干一会。
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
-> day_39_daily_recap


= day_39_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Lisa 12:30 去 HR 工位 18 分钟** (隐藏 E8 setup)_
_  - Lisa 拿 A4 纸塞进抽屉 (内容不明)_
_  - Lisa 美式第 4 天连续_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_40_morning_briefing


// ============================================================================
// Day 40 · 周五 · weekly_recap day · David 不耐烦
// ============================================================================
// 关键 beat:
//   - weekly_recap overlay
//   - David 茶水间问 IT 小马"修咖啡机还要多久" — 第一次不耐烦 (David 燃尽前兆)

= day_40_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared

周五。

# scene: office_workstation
# time: 9:08
# npc: lisa_at_desk_in_dark_shirt
# prop: fruit_bowl_apple

9:08 到公司。

Lisa **没穿浅色衬衫**——她今天还是深色。

_S1 第 1 周周五她浅色。S2 第 6 周周五深色。_

_她不再"周五的 spike" ritual。_

_她周五晚上没约。_

_或者她周五晚上有约但她不再"换 image"。_

水果盘——**仍是苹果**。

~ fruit_bowl = "apple"

_S1 第 5 周周五是 mixed (一半苹果一半草莓)。S2 第 6 周仍 apple。_

_老板的"演融资" 戏停了——没人需要看了。_

* [开始今日]
    -> day_40_event_1_weekly_recap


// ----------------------------------------------------------------------------
// Event 40.1 · weekly_recap · 16:50
// ----------------------------------------------------------------------------
// 触发: 周五下班前自动
// 速度: 标准 (~5 行)
// ----------------------------------------------------------------------------

= day_40_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出周报浮层。

- 出勤率: 100%
- 主动产出条目: 取决于你的 D 36-39 选择
- 协作记录: 取决于你的 David PPS / 王总监 deliverable / Lisa 加班选择

浮层底部："**本月度 KPI 还有 2 天 (周日 9:30 推送月末通报)**"。

_本月度 KPI 还有 2 天。_

_S1 末是 5/2, S2 第 1 个 5/9, S2 第 2 个 5/16 (这周日)。_

_5/16。妈妈周日 8:30 视频, 9:30 我手机弹浮层。_

_她不知道我在等浮层。_

// hidden flag: D40 周五 HR 浮层 + 周日月末通报 setup

~ check_state_after_choice()
-> day_40_event_2_david_irritated_at_it


// ----------------------------------------------------------------------------
// Event 40.2 · David 茶水间问 IT 小马 · 17:25 (David 燃尽前兆)
// ----------------------------------------------------------------------------
// 触发: 下班路上经过茶水间
// 速度: 长 (~10 行)
// 同框: David + IT 小马 + 笑天 (经过)
// NPC archetype: David S4 燃尽前兆 setup (S2 早期暗示)
// ----------------------------------------------------------------------------

= day_40_event_2_david_irritated_at_it
# scene: break_room_doorway
# time: 17:25
# npc: david_with_disposable_cup
# npc: it_xiaoma_at_coffee_machine

17:25。你下班, 路过茶水间。

David 在茶水间。

IT 小马在咖啡机旁边——他**真的在修**。机修包打开, 有零件。

David 拿一次性杯子, 站着。

# speaker: david
David: "兄弟, **修咖啡机还要多久?**"

IT 小马没回头: "已派单, 零件已到货, 这周内修复。"

# speaker: david
David: "你说了 6 周'这周内'。"

IT 小马 0.5 秒没说话。

"零件到货了。这周内是真的。"

# speaker: david
David: "**多久?**"

David 的语气**第一次不耐烦**。

S1 他从不直接问 IT 小马。

S1 他用群里"咖啡机什么时候能修好啊"问 IT 小马——避免直接对话。

S2 第 6 周他直接问。

_他不耐烦了。_

_他周一对群里"@所有人感谢" 戏码, 他周五对 IT 直接 push。_

_他在收紧。_

_他给自己的 deliverable 押 deadline, 顺便给 IT 押 deadline。_

_这是 David 燃尽前兆的第一个 visible sign。_

_S6 finale 他会燃尽。_

_S2 第 6 周是他**第一次显不耐烦**。_

IT 小马站起来——他比 David 矮 5 厘米。

# speaker: it_xiaoma
IT 小马: "**周一**。周一修好。"

# speaker: david
David: "好。"

David 端着一次性杯子走了。

IT 小马蹲回去继续修。

# scene: corridor_passing
# npc: lisa_unaware_in_workstation_background

你走出茶水间, 经过 Lisa 工位区——她还在敲。她没注意到 David / IT 小马的对峙。

// 没有选项 - David 燃尽前兆 setup

// hidden flag: David D40 第一次直接 push IT 小马 - S4 燃尽前兆 setup
// hidden flag: 笑天看到 David 不耐烦 1 次

~ check_state_after_choice()
-> day_40_event_3_lisa_friday_late


// ----------------------------------------------------------------------------
// Event 40.3 · Lisa 周五 19:00 走 · 19:00
// ----------------------------------------------------------------------------
// 触发: 申报加班后回工位
// 速度: 闪 (~3 行)
// 同框: Lisa
// ----------------------------------------------------------------------------

= day_40_event_3_lisa_friday_late
# scene: workstation_after_friday
# time: 19:00
# npc: lisa_finally_packing

19:00。

如果你今天 17:30 走的——你不会看到这一段。

如果你今天申报加班——

~ state = state - 5

19:00 Lisa **终于站起来**。

她收东西的速度比 S1 慢——她每个动作都慢半拍。

她离开时——

她**没回头**。

她**没说"明天见"**。

_她周五 19:00 走。_

_S1 末她周五 18:30 走过 1 次, 19:00 走过 1 次。_

_S2 第 6 周周五 19:00 = 她在加班 baseline 上稳定了。_

_或者她在加。_

// 没有选项 - Lisa quiet sign

~ check_state_after_choice()
-> day_40_after_work


= day_40_after_work
# scene: workstation_evening
# time: 19:30

19:30。你也走人。

* [自己回家]
    你买了一份煎饼, 12 块。
    ~ money = money - 12
    ~ state = state + 2

-

~ check_state_after_choice()
# pagebreak
-> day_40_daily_recap


= day_40_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 2 天 (周日 9:30 推送)_

_关键时刻 today:_
_  - HR 浮层 + 周日 5/16 月末通报 setup_
_  - **David 茶水间第一次不耐烦** (S4 燃尽前兆 setup)_
_  - Lisa 周五 19:00 走 (S2 第 6 周 baseline)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_41_weekend_morning


// ============================================================================
// Day 41 · 周六 · 周末
// ============================================================================

= day_41_weekend_morning
# scene: bedroom
# time: 11:32
# music: weekend_silence

你睡到 11:32 醒。

_这周比上周晚 18 分钟。_

_我也在加速退步。_

# diegetic_ui: phone_wechat_moments

朋友圈：

David 发了"**周末加班 + 周一冲刺 + 月末打榜 = 我的三连击**"。

_他从"双轮驱动" 升级到"三连击"。_

_他每周给自己加一个新词。_

_下周可能是"四象限" / "五能力模型"。_

_他在自我洗脑——给自己造概念让自己觉得"在精进"。_

Lisa 朋友圈最新一条**还是 5/2 的 PPT 屏幕"看花了"**。

她整 14 天没发新的。

_她 14 天 silent。_

_她以前 1 周必发 1 条小确幸——"奶茶到了" / "今天好天气"。_

_现在她不发。_

11:34, 你点外卖：粥 + 油条 + 蛋。35 块。
~ money = money - 35

12:08, 外卖到了。

* [开始今日]
    -> day_41_event_1_afternoon_silence


// ----------------------------------------------------------------------------
// Event 41.1 · 周六下午 · 14:00
// ----------------------------------------------------------------------------
// 触发: 午饭后
// 速度: 闪 (~3 行)
// ----------------------------------------------------------------------------

= day_41_event_1_afternoon_silence
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你在床上。

你打开购物车——浅色衬衫还在。

_S1 加的, 6 周没买。_

_我可能下个月发工资买。_

_或者我下下个月。_

_或者永远不买。_

你又躺了 30 分钟。

~ state = state + 30   // regenForRestDay

~ check_state_after_choice()
# pagebreak
-> day_41_daily_recap


= day_41_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 11:32 起床 (比上周晚 18 分钟)_
_  - David 朋友圈"三连击"_
_  - Lisa 14 天 silent_

# pagebreak
-> day_42_weekend_morning


// ============================================================================
// Day 42 · 周日 · 妈妈视频"那个王二家儿子上海买房了" + Lisa 朋友圈"这周辛苦了"
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈视频 "天天, 那个王二家儿子上海买房了" + "那个谁结婚了" (S1 callback + escalate)
//   - 21:00 Lisa 朋友圈 工位照 + 配文 "这周辛苦了" (E6 → E7 cliffhanger)

= day_42_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

你 8:23 醒。

_8:30 妈妈视频。_

_今天她会说什么。_

_她每周加 1 句新的。_

_上周是"你是不是瘦了"。_

_这周?_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_42_event_1_mom_video_wang_er


// ----------------------------------------------------------------------------
// Event 42.1 · 妈妈视频"那个王二家儿子上海买房了" · 8:30
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~14 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 升级 — S1 E3 D21 第 1 次, S2 E6 D42 第 2 次 (callback + add)
// Verbatim: "那个王二家儿子上海买房了" 必保留 (per §6 锚)
// ----------------------------------------------------------------------------

= day_42_event_1_mom_video_wang_er
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen

屏幕里是妈妈。

她戴着老花眼镜, 眼镜距离屏幕很近。

# speaker: mama
妈妈："**天天, 吃了吗?**"

# speaker: protagonist
你："吃了。"

_我没吃。_

# speaker: mama
妈妈："**工资发了吗?**"

# speaker: protagonist
你："发了。"

_发了。但工资 11000 - 房贷 4500 - 给你的 1000 - 房租 1500 - 吃饭 2000 = 我自己只剩 2000 了。_

_我还要交医保社保。_

_我自己花 800 块/月。_

_我没让你知道。_

# speaker: mama
妈妈："**那个王二家儿子上海买房了。**"

_她又说了。_

_S1 E3 D21 她说过 1 次。_

_她复读这一句的时候我以为她是 forgetting。_

_她不是 forgetting——她在 reinforcing。_

_她在让我 register 这件事。_

她接着说："**那个谁结婚了。**"

_2 件事一起说。_

_S1 是 1 件, S2 是 2 件。_

_她在 build inventory——王二买房 + 谁结婚 = 同龄人 milestones。_

_我没有 milestone。_

_我有"撑过去"。_

_她没问我"你呢"——她**没问**, 因为问了我会"再等等" 她已经听过 12 次。_

你保持沉默。

**3 秒沉默。**

视频里能听到妈妈厨房油烟机的声音。

# diegetic_ui: video_3_seconds_silence

# speaker: mama
妈妈："**没事, 慢慢来。**"

她笑了一下——是疲倦的微笑。

_她替我说"慢慢来"。_

_她不再问"你呢", 她直接给我 cushion。_

_她比我先放下"再等等"。_

_她在适应我没有答案。_

* [转移话题: 妈你这周身体怎么样]
    # speaker: mama
    妈妈："还行。前几天去广场跳了一会儿。"
    _她笑了一下, 不深。_
    "你呢? 注意休息。"
    # speaker: protagonist
    你："好。"
    ~ mom_score = mom_score + 3

* [嗯]
    # speaker: mama
    妈妈："嗯。" (她也"嗯"。)
    _2 个"嗯"打平。_
    ~ mom_score = mom_score + 0

* [我也在想]
    # speaker: mama
    妈妈："想就行。妈不催。"
    _她说"不催"实际上是在催。但她是用最软的方式。_
    ~ mom_score = mom_score + 1

- _挂掉视频后你坐在床上 1 分钟。_
- _她每周加 1 句。_
- _上周"瘦了"是关心。_
- _这周"王二买房 + 谁结婚"是参照系扩展。_
- _下周可能是"去你那看看你"。_
- _或者她这周已经在 setup 下周。_

// hidden flag: 妈妈 D42 "王二+谁" + 3 秒沉默 + "慢慢来" - S2 escalation

~ check_state_after_choice()
-> day_42_event_2_lisa_circle_post


// ----------------------------------------------------------------------------
// Event 42.2 · Lisa 朋友圈 "这周辛苦了" · 21:00 (E6 → E7 cliffhanger)
// ----------------------------------------------------------------------------
// 触发: 晚 21:00 自动
// 速度: 长 (~10 行)
// 同框: Lisa (朋友圈)
// 设计意图: Lisa 14 天 silent → 周日晚发"这周辛苦了" — 她从来没发过的 self-acknowledge
// ----------------------------------------------------------------------------

= day_42_event_2_lisa_circle_post
# scene: home_evening
# time: 21:00
# diegetic_ui: phone_wechat_moments_alert
# npc: lisa_via_moments

21:00。你刚洗完澡。

朋友圈推送 1 条。

# diegetic_ui: phone_wechat_moments_lisa_post

Lisa 发了 1 张图。

**工位照——她自己工位, 屏幕开着 PPT, 桌面有眼药水 + 7-11 美式空杯**。

配文：

"**这周辛苦了。**"

3 个字。

_这是 Lisa 14 天来第一条朋友圈。_

_S1 她每周必发 1 条小确幸。_

_S2 第 1-5 周她不发。_

_S2 第 6 周周日晚 21:00 她发"这周辛苦了"。_

_Self-acknowledge。_

_她以前不需要 self-acknowledge——她有奶茶 / 话梅 / 浅色衬衫 / 雨伞小玩偶 / 桌下手心"加油" 这些 ritual。_

_她现在需要她自己说"辛苦了"——因为没人对她说。_

_王总监说"加把劲"。_

_David 说"加感谢"。_

_我不说。_

_她妈不知道。_

_她对自己说。_

* [给 Lisa 点赞]
    你点了赞。
    _10 分钟后她又点了一个 emoji 给自己——👍。_
    _她给自己点了 1 次。_
    ~ lisa_score = lisa_score + 2

* [评论"辛苦"]
    你评论"辛苦"。
    Lisa 5 分钟回复"嗯"。
    _嗯。_
    ~ lisa_score = lisa_score + 3

* [私信关心]
    你私信她："辛苦了。"
    Lisa 没立即回。
    20 分钟后她回："嗯。"
    _她不愿意展开。_
    ~ lisa_score = lisa_score + 1

* [不回应]
    你看了, 没点赞, 没评论, 没私信。
    _她朋友圈这条到 22:00 共 8 个赞。_
    _你不在那 8 个里。_
    ~ lisa_score = lisa_score - 2

- _不论选什么。_
- _她周日晚 21:00 在床上发了"这周辛苦了"。_
- _她公司里 14 天没发新的——但她周日晚发。_
- _周日是她的 vulnerability moment——一周抱着 KPI 撑过去, 周日晚她自己 collapse 一下。_
- _下周一她又会站起来 8:00 到。_
- _她自己拉自己起来。_

// hidden flag: E6 → E7 cliffhanger - Lisa 周日晚 21:00 朋友圈 "这周辛苦了"

~ check_state_after_choice()
# pagebreak
-> day_42_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 42 周日日报 (E6 末)
// ----------------------------------------------------------------------------

= day_42_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +12)_

_关键时刻 today:_
_  - 8:30 妈妈视频"那个王二家儿子上海买房了" + "那个谁结婚了" + 3 秒沉默 + 妈妈"慢慢来"_
_  - 21:00 Lisa 朋友圈"这周辛苦了" (E6 → E7 cliffhanger - 14 天来第 1 条)_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 7 周 — Lisa 剪短发_

// E6 结束 - cliffhanger 到 E7 周一 Lisa 剪短发到公司

-> END

// ============================================================================
// EOF episode-6.ink
// ============================================================================
//
// 分身 task summary (W3 = S2 Round 1):
//   - Day 36-42 全 7 天 stitches 完整
//   - Lisa 第一次喝咖啡 (D36) = E6 集内高峰
//   - 王总监没等笑天 (D36) = 笑天空虚 PUA 链条 awareness
//   - 王总监 cue Lisa "那加把劲" (D38)
//   - Zoe 偷听"月度面谈名单" (D37) = E8 隐藏 setup
//   - David 第一次不耐烦 (D40) = S4 燃尽前兆 setup
//   - 妈妈"那个王二家儿子上海买房了" + "那个谁结婚了" (D42) = S1 callback escalate
//   - Lisa 朋友圈"这周辛苦了" (D42) = E6 → E7 cliffhanger
//
// 笑/泪比 = 6:4 (per season-2-arc.md §1):
//   - 笑点: D36 王总监没等笑天 (PUA 链条 awareness 笑) / D38 王总监 BLUEPRINT V2 (callback)
//          / D38 8 分钟散会 / D40 David 三连击 / Vivian "嗨" 8:50 loading
//   - 扎点: D36 Lisa 第一次咖啡 / D38 王总监"加把劲" / D39 Lisa 去 HR 18 分钟 / D40 David 不耐烦
//          / D42 妈妈"王二+谁结婚" + 3 秒沉默 / D42 Lisa 朋友圈"辛苦了"
//
// 红线 (S2 不能做):
//   - Lisa 不决定走/留 ✓
//   - HR 月度面谈不在 E6 ✓ (D37 仅听到名单, 笑天不知 Lisa 在名单)
//   - 王总监不直接对 Lisa "潜力一般" ✓ (仅"加把劲")
//   - 林姐 S2 仍不出场 ✓ (D31 mention)
//   - Lisa 不剪短发 ✓ (E7 周一)
//   - David 不燃尽 ✓ (仅"第一次不耐烦"前兆)
//   - 老周 S2 对话 = 0 ✓ (D36 silent)
//
// END
