// ============================================================================
// Episode 3 · Week 3 · 「过完今天」
// ============================================================================
//
// Status: 第 1 版 (分身 CC session 翻译稿 - 从 episode-3.md 翻译)
//          + W3 patch (2026-05-05): Lisa 剪短发 migrated to S2 E7 (per
//          season-2-arc.md §8 Option A); D15 morning quiet sign 改为眼药水
// Author: 分身 CC session (Round 2) + W3 cleanup
// Last Updated: 2026-05-05
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
//
// 设计目标 (摘要):
//   1. NPC C Vulnerability 集中爆发集 - 9 个 NPC (除林姐) 每人在 E3 各有一次
//      "露馅", 但没有一个直接对玩家露 - 全部是被偷看 / 偷听 / 意外撞见
//   2. 老周"过完今天" - E3 周四笑天主动找老周对话 - S1 全季唯一一次 (集内最锋利)
//   3. Lisa 桌上眼药水 (兑现 E2 cliffhanger) - quiet sign 用眼过度 / 加班失眠
//      (注: 剪短发是 S2 E7, S1 不能 spoil)
//   4. 6:4 笑泪比 - 笑减少, HR 暗线 + 王总监工位灯还亮 + 李阿姨"这周又走了仨"
//      + 妈妈视频上海买房 = 4 个扎点
//   5. 红线: HR 找 Lisa 谈话 / Lisa 走 / 留 - 全 S1 不能出现
//   6. Cliffhanger - 下周一就是月末 KPI Review (E4 finale 5 路径)
//
// ============================================================================

INCLUDE episode-1.ink

// E3 entry
-> episode_3


// ============================================================================
// Episode 3 主入口
// ============================================================================

=== episode_3 ===
# scene: home
# time: monday_morning_week_3
# pagebreak
-> day_15_morning_briefing


// ============================================================================
// Day 15 · 周一 · 第 14 周第 1 天
// ============================================================================

= day_15_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:11

闹钟 1 次。

_周末睡饱了。_

# scene: office_entrance
# time: 9:11
# npc: vivian_with_shorter_tail
# prop: fruit_bowl_apple

9:11 到公司。Vivian "嗨～来啦～"——今天她的尾巴没拖那么长。

_她今天累。或者她在 standby 别人。_

水果盘**苹果**。

~ fruit_bowl = "apple"

_上周草莓只 4 天就退潮。这周从苹果开始。融资可能没真的过。_

_或者过了一半。或者老板老婆只买了一盒草莓。_

_我不再 over-read 了。_

* [开始今日]
    -> day_15_event_1_lisa_eye_drops


// ----------------------------------------------------------------------------
// Event 15.1 · Lisa 桌上的眼药水 · 9:18 (Lisa C 兑现 E2 cliffhanger)
// ----------------------------------------------------------------------------
// 触发: 进入工位
// 速度: 长 (~10 行)
// 同框: Lisa
// NPC archetype: Lisa C Vulnerability - quiet sign (用眼过度 / 加班失眠)
// 注: S2 E7 才是 Lisa 剪短发 — S1 不 spoil (W3 patch per season-2-arc.md §8)
// ----------------------------------------------------------------------------

= day_15_event_1_lisa_eye_drops
# scene: workstation_corner
# time: 9:18
# npc: lisa_at_desk
# prop: lisa_eye_drops_bottle
# prop: lisa_workstation_with_charm

你 9:14 走到工位区。

你的工位在 A 区——Lisa 工位斜对角。

你看了一眼——

她在工位。她还低头敲键盘。她没看你。

你坐下来, 假装你正在看自己电脑屏幕。

9:18, 她抬头——她可能注意到你来了。

你回头——她笑了一下。

她桌上**多了一瓶眼药水**。蓝色, 小支, 摆在键盘右边。

"**眼睛干了。**" 她说, 拧开瓶盖。

她仰头滴了一滴。

她又滴了一滴。

她眨了 3 下眼。

_她周日朋友圈那张图——PPT 屏幕。"看花了。"_

_她改 PPT 改到几点我不知道。_

_但眼药水周一就上桌了。_

_她在熬。_

* [辛苦了]
    # speaker: lisa
    Lisa："嗯, 没事。盯久了而已。"
    _她拧紧瓶盖, 转回工位。_
    ~ lisa_score = lisa_score + 3

* [嗯]
    Lisa 没说什么。
    _她转回工位继续敲键盘。_
    ~ lisa_score = lisa_score + 0

* [改到几点]
    # speaker: lisa
    Lisa："啊……就……到 1 点。"
    _她笑了一下, "也没事, 习惯了。"_
    _她把眼药水推到电脑后面, 看不见的位置。_
    ~ lisa_score = lisa_score - 2

- _不论选什么。_
- _眼药水周一就上桌。_
- _下周可能更多。_
- _她不会告诉我她改到几点。_
- _她也可能告诉我但我装没听懂。_

// hidden flag: Lisa 桌上眼药水 D15 周一 - quiet sign 累积起点
//              (S2 累积升级: 早到 → 咖啡 → 剪短发 → HR)

~ check_state_after_choice()
-> day_15_event_2_wang_xiaoxiao_chenxiantian


// ----------------------------------------------------------------------------
// Event 15.2 · 王总监的"小笑啊…陈天啊" · 中午 12:18
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~3 行)
// 同框: 王总监
// 设计意图: Running gag 第 N 次 callback - 这次加"月底了"
// ----------------------------------------------------------------------------

= day_15_event_2_wang_xiaoxiao_chenxiantian
# scene: workstation_pantry_corner
# time: 12:18
# npc: wang_walking_by_again

12:18。你刚泡好面, 王总监经过工位区。

"小笑啊。"

0.5 秒。

"陈天啊。"

0.5 秒。

"差不多差不多。**月底了, 加把劲。**"

他没看你眼睛, 已经走过去了。

// Running gag - 这次他加了"月底了"
// E3 KPI 倒数 3 天的 system 提示在他这里也出现了

_他还是叫不准。_

_但他记住了"月底"。_

_他的 KPI 计时器和 HR 系统的浮层是同步的。_

~ check_state_after_choice()
-> day_15_event_3_lisa_drink_coffee


// ----------------------------------------------------------------------------
// Event 15.3 · 下午的 Lisa · 16:30
// ----------------------------------------------------------------------------
// 触发: 第 6 个 event
// 速度: 闪 (~3 行)
// 同框: Lisa (背景)
// 设计意图: Lisa 状态变化 quiet sign - 奶茶 → 咖啡 = S2 状态下滑 setup
// ----------------------------------------------------------------------------

= day_15_event_3_lisa_drink_coffee
# scene: workstation_with_lisa
# time: 16:30
# npc: lisa_drinking_convenience_coffee
# prop: convenience_store_coffee_cup

16:30。Lisa 在工位敲键盘。

她今天没买奶茶——便利店咖啡。她从来没喝过咖啡。

她左手手心还有上周三的"加油"印——但已经淡了。

_上周三的"加油"撑了 5 天。_

_今天她在喝咖啡。_

_她的"换"不只是头发。_

// 没有选项 - Lisa quiet sign

// hidden flag: Lisa 改喝咖啡 D15

~ check_state_after_choice()
-> day_15_after_work


= day_15_after_work
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
-> day_15_daily_recap


= day_15_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Lisa 桌上眼药水** (E2 cliffhanger 兑现 + Lisa C Vulnerability quiet sign)_
_  - 王总监 cue 月底加油_
_  - Lisa 改喝咖啡_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_16_morning_briefing


// ============================================================================
// Day 16 · 周二
// ============================================================================

= day_16_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:09

# scene: office_workstation
# time: 9:09
# diegetic_ui: phone_show_kpi_countdown_overlay

9:09 到公司。

你 morning_briefing 屏幕弹出 1 条系统消息：

"**本月度 KPI 还有 6 天。请关注个人考核进度。**"

_周五是 3 天。今天是 6 天？_

_哦——HR 系统按工作日算。月末是下下周一。_

_我跟 HR 系统的时间感不同。_

* [开始今日]
    -> day_16_event_1_vivian_phone_call


// ----------------------------------------------------------------------------
// Event 16.1 · Vivian 接电话 · 9:25 (Vivian C Vulnerability)
// ----------------------------------------------------------------------------
// 触发: 进入工位
// 速度: 标准 (~6 行)
// 同框: Vivian + 笑天 (远端听到)
// NPC archetype: Vivian C Vulnerability
// 注意 (per Q3.1): "她"模糊 - 不指向 Lisa, 避免破"HR 介入 Lisa 不能 S1"红线
// ----------------------------------------------------------------------------

= day_16_event_1_vivian_phone_call
# scene: workstation_with_corridor_audio
# time: 9:25
# npc: vivian_on_phone_lowering_voice

你刚坐到工位, 准备打卡——你听到走廊那边 Vivian 接电话。

她平时讲电话很大声。今天**压低了声音**。

"是是是, 老板。"

"嗯, 我了解。"

"**我马上让她去您办公室。**"

她挂了电话。

你回头瞥了一眼——Vivian 表情是平静的"职业微笑", 但她没笑。

_"她"是谁？_

_"她"可能是 Lisa。或者是 Zoe。或者是 HR 部门别的人。_

_Vivian 永远先知道。_

_我不会知道。_

// 没有选项 - Vivian C Vulnerability
// "她"故意模糊 - per Q3.1 designer KEEP

// hidden flag: Vivian 接老板电话 D16 - series-level setup, 不指向 Lisa

~ check_state_after_choice()
-> day_16_event_2_david_pry_potential


// ----------------------------------------------------------------------------
// Event 16.2 · David 茶水间试探 · 14:30 (David C Vulnerability)
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 长 (~10 行)
// 同框: David + 笑天
// NPC archetype: David C Vulnerability - 唯一一次接近"露馅"
// ----------------------------------------------------------------------------

= day_16_event_2_david_pry_potential
# scene: break_room
# time: 14:30
# npc: david_with_disposable_cup
# prop: thermos_cup_absent

14:30。茶水间。David 在泡枸杞茶——他今天没用保温杯, 他用了**一个一次性杯子**。

_他保温杯不在了。或者他懒得洗。_

_他周一抢功后, 他可能没那么"养生"了。_

"兄弟, 问你个事。"

他压低声音："上个月王总监跟你说过你'**潜力一般**'吗？"

你看着他。

_他周一笑得很大声。今天他在试探。_

_上个月王总监说他"潜力一般"。这件事在他心里还没过。_

_他周一周五的"加班"姿态、群里"@所有人感谢"、找老周"请教"——所有这些都是这件事的回响。_

* [没有过]
    # speaker: david
    David："哦, 那我多虑了。"
    _他眼神里有一丝失落。但马上恢复。_
    "我那是上个月被说了, 最近没事, 就……瞎想。"
    他笑了一下, 但是**0.3 秒的露馅**。
    ~ david_score = david_score + 5
    // hidden flag: David 唯一一次接近露馅 - Pillar 4 灰幽默

* [你被说过？]
    # speaker: david
    David："啊没……我就是问问。"
    _他赶紧岔开话题, "哎你那个保温杯哪买的？"_
    _他保温杯不在了, 他还问别人哪买的。_
    _他在转移话题。_
    ~ david_score = david_score - 3
    // hidden flag: David 后悔多嘴

* [不知道]
    # speaker: david
    David："行行, 没事。"
    _他端着一次性杯子走了。_
    ~ david_score = david_score + 0

- _不论选什么。_
- _这是 David 唯一一次接近"露馅"的瞬间。_
- _他到死都觉得是别人的错。_
- _但今天他短暂怀疑了一下。_

~ check_state_after_choice()
-> day_16_event_3_coffee_machine_upgrade2


// ----------------------------------------------------------------------------
// Event 16.3 · 下午的 IT 工单 · 15:45
// ----------------------------------------------------------------------------
// 触发: 第 5 个 event
// 速度: 闪 (~3 行)
// 设计意图: Running gag 加深
// ----------------------------------------------------------------------------

= day_16_event_3_coffee_machine_upgrade2
# scene: break_room
# time: 15:45
# prop: coffee_machine_with_new_sticky

15:45。咖啡机告示又换了。

~ coffee_machine_broken_days = coffee_machine_broken_days + 7   // 又过了 1 周

现在的告示是: "**零件已到货, 本周修复**"。落款"IT 部"。

你看了一下——这是上周四"零件待到货"的升级版。

_上周四"待到货" → 这周二"已到货"。_

_IT 小马 OKR 推进了。_

_但咖啡机还是不能用。_

// 没有选项 - running gag 加深

~ check_state_after_choice()
-> day_16_after_work


= day_16_after_work
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
-> day_16_daily_recap


= day_16_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Vivian C Vulnerability** (接老板电话压低声音)_
_  - **David C Vulnerability** (试探"潜力一般")_
_  - IT 小马 running gag (告示升级"已到货, 本周修复")_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_17_morning_briefing


// ============================================================================
// Day 17 · 周三 (王总监 C Vulnerability - power signal + layer 2)
// ============================================================================

= day_17_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:25

周三是晨会日。

# scene: meeting_room
# time: 9:25
# npc: lisa_normal_arrival
# npc: lao_zhou_in_back
# npc: david_with_new_sticky_note

9:25。Lisa 已经在会议室——她今天**没有提前 5 分钟**。她正常 9:28 到。

_她不再提前了。_

老周也来了——9:00 准点。

David 在斜对面, 他的笔记本封面贴着新便利贴: "**月底冲刺**"。

9:30 整。会议室门没开。

* [开始今日]
    -> day_17_event_1_wang_absent_meeting


// ----------------------------------------------------------------------------
// Event 17.1 · 王总监没出现 · 9:30-9:40 (王总监 C Vulnerability - power signal)
// ----------------------------------------------------------------------------
// 触发: morning_briefing 后
// 速度: 标准 (~7 行)
// 同框: David + Lisa + 老周 + 笑天 (无王总监)
// NPC archetype: 王总监 C Vulnerability - 缺席 = power signal
// ----------------------------------------------------------------------------

= day_17_event_1_wang_absent_meeting
# scene: meeting_room
# time: 9:30_to_9:40
# npc: wang_office_door_closed
# diegetic_ui: phone_wechat_assistant_message

9:30 整。王总监没来。

9:35。还没来。

David 看了一眼手机: 群里王总监的助理发了消息: "**王总今天临时去客户成功部对接, 晨会取消。**"

大家收东西离开。

_他临时去客户成功部对接 = 他去找林姐。_

_他之前打电话提过"下午去客户成功部跟林姐对一下"——上周四。_

_他周三上午 9:30 临时跑过去 = 这件事比晨会重要。_

_或者他不想 cue Lisa 第二次。_

_或者别的。_

你回工位。

// 没有选项 - 王总监 C Vulnerability layer 1 (缺席 = power signal)

_散会的"散会"——其实没开。_

_但所有人按"散会"那样收东西。_

_这就是会议的本质——你来不来不重要, 重要的是流程走完。_

~ check_state_after_choice()
-> day_17_event_2_morning_silence


// ----------------------------------------------------------------------------
// Event 17.2 · 上午回工位的余韵 · 9:50
// ----------------------------------------------------------------------------
// 触发: 散会回工位后
// 速度: 闪 (~4 行)
// 设计意图: 缺席感的余韵
// ----------------------------------------------------------------------------

= day_17_event_2_morning_silence
# scene: workstation_morning_quiet
# time: 9:50
# npc: lisa_back_to_typing
# npc: lao_zhou_back_at_excel

回工位。

Lisa 已经坐回去开始打字。

老周在自己工位, 还是看 Excel。

David 在斜对面, 他打开 Word 改"月底冲刺"计划。

_他比所有人都先调整状态。_

_我还在想"晨会取消"这件事。_

_他已经在写下一项 deliverable。_

// 没有选项 - 余韵 flavor

~ check_state_after_choice()
-> day_17_event_3_wang_office_light_late


// ----------------------------------------------------------------------------
// (REMOVED by designer Round 2 patch) Event 17.2b · 中午老周柠檬片
// ----------------------------------------------------------------------------
// Reason: 违反 npcs.md §8 老周禁忌 "不要让笑天和老周成为忘年交"。
// 笑天观察老周喝柠檬茶 + "明天我可能主动跟他说话" = mentor 关系铺垫，
// 跟 §8 "笑天主动找他 ≤ 3 次/季" + designer-locked "S1 唯一对话 = E3 周四 '过完今天'"
// 冲突。Round 2 worker 的 bonus stitch cut。
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Event 17.3 · 笑天加班 19:30 · 看到王总监工位灯还亮 (王总监 C Vulnerability - Layer 2)
// ----------------------------------------------------------------------------
// 触发: 申报加班后下午延伸
// 速度: 长 (~10 行)
// 同框: 王总监 (远端, 未察觉笑天)
// NPC archetype: 王总监 C Vulnerability layer 2 - 笑天第一次"看到他也是 puppet"
// ----------------------------------------------------------------------------

= day_17_event_3_wang_office_light_late
# scene: office_after_hours
# time: 19:30
# npc: wang_in_solo_office_typing
# prop: wang_office_door_closed_with_light_underneath

你今天申报了加班——王总监散会缺席, HR 系统提示月底 6 天, 你心里有点不安, 决定多干一会。

~ state = state - 10
~ kpi = kpi + 5
~ effort_overage = effort_overage + 1

19:30。大部分人都走了。Lisa 19:00 走的——她今天**第一次准点**走。

你去 16 楼茶水间接水——咖啡机告示还是"已到货, 本周修复"。

你接完水回来的路上经过王总监的独立办公室——

门关着。但**门缝下面有光**。

你停下来听了一秒。

你听到键盘声——**他在自己改 PPT**。

不规律的敲击声。慢慢的。

_他自己也在加班。_

_他没让助理改。_

_他在改一份他自己的东西。_

_他不是"系统的化身"。他也是被 push 的人。_

_他的工位灯还亮着 = 他自己也焦虑。_

_45 岁面临公司年轻化。他比我焦虑。_

你回工位。

// 没有选项 - 王总监 C Vulnerability core
// 必须克制 - 不能让笑天"同情"或"理解", 只能"观察"
// hidden flag: 看到王总监工位灯还亮 - series-level setup (S7-S8 王总监 KPI 也悬, S9 finale 被换)

~ check_state_after_choice()
-> day_17_after_work


= day_17_after_work
# scene: workstation_late_night_evening
# time: 20:00

// 已经申报加班了 - 直接走

你 20:00 关电脑走人。

你出门前回头看——王总监独立办公室门缝还有光。

_他可能要改到 21:00。_

* [继续走]
    ~ lisa_score = lisa_score + 0

-

~ check_state_after_choice()
# pagebreak
-> day_17_daily_recap


= day_17_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **王总监 C Vulnerability** (晨会缺席 power signal + 19:30 工位灯还亮 layer 2)_
_  - Lisa 第一次准点走_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_18_morning_briefing


// ============================================================================
// Day 18 · 周四 · ★ 老周"过完今天" 集内最锋利一句 ★
// ============================================================================

= day_18_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:11

# scene: office_workstation
# time: 9:11
# npc: lisa_arriving_earlier
# npc: lao_zhou_with_lemon_slice_in_tea
# prop: lemon_slice_in_third_cup

9:11 到公司。

Lisa 已经在工位。她今天又准点——她比周三晚了 14 分钟, 所以是周三早晨往后挪。

老周也在了——他的 3 个茶杯, 今天最右那杯里**有半个柠檬片**。

_他在自己泡。他变了。_

_或者他柠檬是别人送的。_

_12 年没换过茶杯顺序的人, 今天放了一片柠檬。_

* [开始今日]
    -> day_18_event_1_lao_zhou_pass_today


// ----------------------------------------------------------------------------
// Event 18.1 · 笑天主动找老周 · 11:30 (老周 C Vulnerability + S1 唯一对话)
// ----------------------------------------------------------------------------
// 触发: 第 3 个 event
// 速度: 长 (~14 行)
// 同框: 老周 + 笑天
// NPC archetype: 老周 C Vulnerability + S1 唯一一次对话
// 设计禁忌: 不能让笑天和老周成为"忘年交" - 加 self-aware moment 处理
// ----------------------------------------------------------------------------

= day_18_event_1_lao_zhou_pass_today
# scene: corner_workstation_lao_zhou
# time: 11:30
# npc: lao_zhou_looking_at_phone
# prop: old_iphone_in_hand

11:30。你想去打印机取一份纸。

你站在打印机前等。打印机响。

你回头——老周在他工位, 对着窗户。他面前的 Excel 关掉了。他在看手机。

_他在看手机。他的手机不是公司发的——是他自己的, 5-6 年的旧 iPhone。_

你的纸出来了。但你没拿。

你走到老周工位旁边。

你之前跟他说过 1 次话——E1 周二偷喝凉茶后 (如果你选 C 主动跟他说"对不起, 您那杯茶我喝了")。这是你跟他第二次说话。

"周哥。"

他抬头。

"您怎么坚持这么久的？"

你听到自己说出这句话的时候, **你已经后悔了**——这是一个直接的问题, 太直接了, 老周不喜欢被这样问。

老周看了你 0.5 秒。

他放下手机。

"**过完今天。**"

他低下头。

* [点头默默走开]
    你点了一下头, 回工位。
    _他的便利贴也是"过完今天"。他没说"过完今年" / "过完这个 KPI" / "过完这个项目"。_
    _他只过今天。_
    _他比我克制 10 年。_
    ~ lao_zhou_score = lao_zhou_score + 0
    // hidden flag: 你和老周对话 1 次 (S1 唯一)

* [嗯, 谢谢周哥]
    # speaker: protagonist
    你："嗯。谢谢周哥。"
    老周不抬头。
    你回工位。
    ~ lao_zhou_score = lao_zhou_score + 0
    // hidden flag: 你跟老周说了"谢谢" - 他不在乎, 但你内部有 1 笔

- _不论选什么。_
- _这是 S1 全季笑天和老周的唯一对话。_
- _不会再有了。_
- _S2-S3 你想再问, 他还是会"嗯"。_
- _你知道他能给的, 他已经给了。_

// hidden flag: S1 老周对话已耗尽 - S2-S3 老周不会再说话

~ check_state_after_choice()
-> day_18_event_2_zoe_eavesdropping


// ----------------------------------------------------------------------------
// (REMOVED by designer Round 2 patch) Event 18.1b · 老周对话余韵
// ----------------------------------------------------------------------------
// Reason: 8 行内心独白把"过完今天"3 字 expanded 成对老周哲学的 explication，
// 违反 npcs.md §8 老周禁忌 "不要让老周给笑天'人生哲理'——他只说 1 句话"。
// 设计意图是让 1 句话停在那里，玩家自己消化。worker 的 余韵 = 越俎代庖。
// "过完今天" 的余韵应该在玩家心里发酵，不在 .ink 里说出来。Cut。
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Event 18.2 · 偷听 Zoe · 17:25 (Zoe C Vulnerability)
// ----------------------------------------------------------------------------
// 触发: 下班路上
// 速度: 标准 (~7 行)
// 同框: Zoe + 另一个 HR + 笑天 (远端听到)
// NPC archetype: Zoe C Vulnerability - layer 2 of E2 周四偷刷小红书
// ----------------------------------------------------------------------------

= day_18_event_2_zoe_eavesdropping
# scene: hr_workstation_corridor_water_dispenser
# time: 17:25
# npc: zoe_at_water_dispenser
# npc: another_hr_chatting_low_voice

17:25。你下班, 路过 HR 工位区。

Zoe 跟另一个 HR 站在饮水机旁低声说话——你听不全。

但你听到 Zoe 那句：

"你说我们要是被裁了, **会不会也走这流程**？"

另一个 HR："哈哈, 我们也是员工啊。"

# speaker: zoe
Zoe："但 HR 自己被裁——他们让别的 HR 来执行？"

另一个 HR："嗯。或者就直接是老板找你谈。"

Zoe 没回。

你已经走过去了。

// 没有选项 - Zoe C Vulnerability
// 比 E2 周四 (她偷刷小红书) 深一层 - 她今天说出来了

_她在问"我会不会也走这流程"。_

_她比我想得更远。_

_我只想活到周五。她已经在想"被裁那天"。_

// hidden flag: Zoe 也在担心被裁 D18

~ check_state_after_choice()
-> day_18_after_work


= day_18_after_work
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
-> day_18_daily_recap


= day_18_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **老周 C Vulnerability + S1 唯一对话"过完今天"** (集内最锋利一句) ★_
_  - **Zoe C Vulnerability** (饮水机偷听"我们要是被裁了会不会也走这流程")_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_19_morning_briefing


// ============================================================================
// Day 19 · 周五 weekly_recap day
// ============================================================================

= day_19_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:08

# scene: office_workstation
# time: 9:08
# npc: lisa_with_new_glasses
# prop: black_frame_glasses

9:08 到公司。

Lisa 在工位。她今天**戴了一副新眼镜**——黑框, 不是她平时戴的那种。

_眼镜也换了。_

_但她不是近视——她平时不戴。_

_可能是平光。可能是她在熬——眼药水 + 喝咖啡 + 换眼镜, 这周她"换"了 3 个。_

_或者她真的需要——她 PPT 改太多了眼睛累。_

* [开始今日]
    -> day_19_event_1_lisa_no_reach_out


// ----------------------------------------------------------------------------
// Event 19.1 · Lisa 改 PPT 不 reach out · 上午 10:30
// ----------------------------------------------------------------------------
// 触发: 第 2 个 event
// 速度: 闪 (~4 行)
// 设计意图: E2 求笑天 → E3 不再求 = 状态变化
// ----------------------------------------------------------------------------

= day_19_event_1_lisa_no_reach_out
# scene: workstation_with_lisa_typing
# time: 10:30
# npc: lisa_typing_in_solitary

10:30。你回头看——Lisa 在改 PPT。

她戴着新眼镜, 盯着屏幕。她屏幕上是周三早被王总监 cue 之后她又改了的版本。

她没找你看。

她改了 30 分钟, 发出去了。

11:05。王总监回："收到。"

Lisa 转过来——她的脸是空白的。**她没笑**。

// 没有选项 - Lisa 状态变化
~ lisa_score = lisa_score - 3
// hidden flag: Lisa 不再求助你 D19 - 她已放弃"靠外人帮"

~ check_state_after_choice()
-> day_19_event_2_li_ayi_three_left


// ----------------------------------------------------------------------------
// Event 19.2 · 李阿姨"这周又走了仨" · 17:35 (李阿姨 C Vulnerability)
// ----------------------------------------------------------------------------
// 触发: 下班路上
// 速度: 标准 (~7 行)
// 同框: 李阿姨 + 另一个清洁阿姨 + 笑天 (远端听到)
// NPC archetype: 李阿姨 C Vulnerability
// 注意: 李阿姨 score 不影响机制 (per npcs.md §5)
// ----------------------------------------------------------------------------

= day_19_event_2_li_ayi_three_left
# scene: break_room_doorway
# time: 17:35
# npc: li_ayi_collecting_trash
# npc: another_li_ayi_chatting
# prop: granddaughter_to_son_exam_photo_swap

17:35。你下班, 路过茶水间。

李阿姨在收垃圾。她在跟另一个清洁阿姨低声说话：

"**这周又走了仨。**"

另一个："唉。"

# speaker: li_ayi
李阿姨："5 楼一个, 6 楼一个, 咱们这层一个。"

_咱们这层。_

_谁？_

_不是 Lisa——她还在。_

_不是 David——他还在群里 @所有人。_

_不是王总监——他在自己加班。_

_可能是别的部门的某个我不熟的人。_

_或者她算错了。_

_但李阿姨从不算错。她在这扫了 8 年。_

李阿姨没看到你。

// 没有选项 - 李阿姨 C Vulnerability

_她拖把车上贴的孙女照片, 最近换了——上周还是孙女小学生照片, 这周换成了"儿子高考准考证"。_

_她在准备她儿子的考试。她不在准备这家公司。_

// hidden flag: 李阿姨儿子高考准考证 D19 - series-level setup (S7 拖把车贴变化, S8 finale 退休)

~ check_state_after_choice()
-> day_19_event_3_lisa_19_00


// ----------------------------------------------------------------------------
// Event 19.3 · 19:00 的 Lisa · 下班前
// ----------------------------------------------------------------------------
// 触发: 下班前回工位看
// 速度: 闪 (~3 行)
// ----------------------------------------------------------------------------

= day_19_event_3_lisa_19_00
# scene: workstation_evening_returning_for_bag
# time: 19:00
# npc: lisa_still_at_desk_revising_v8

你回工位拿包。

Lisa 工位灯还亮着——19:00 了, 她还在改 PPT。

你站在你工位旁, 看了她 3 秒。

她在敲键盘。她屏幕上是 V8。

_V8。_

_周二是 V3。今天是 V8。_

// 没有选项 - Lisa 状态深化

_她周一桌上眼药水, 周二喝咖啡, 周三准点走, 周四不主动说话, 周五独自改 PPT。_

_她这周每天都"换"了一个东西。_

_她在"换" 的可能不只是头发。_

~ check_state_after_choice()
-> day_19_after_work


= day_19_after_work
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
-> day_19_daily_recap


= day_19_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_weekly_recap_overlay

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 3 天 (HR 系统提示)_

_关键时刻 today:_
_  - Lisa 不再求助_
_  - Lisa 戴新眼镜_
_  - 茶水间偷听到清洁工"这周又走了仨"_
_  - Lisa 19:00 改到 V8_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_20_weekend_morning


// ============================================================================
// Day 20 · 周六 (周末)
// ============================================================================

= day_20_weekend_morning
# scene: bedroom
# time: 11:32
# music: weekend_silence

你睡到 11:32 醒。

_今天比上周晚 24 分钟。我在加速退步。_

# diegetic_ui: phone_wechat_moments

朋友圈——

David 没发"周末加班的都是兄弟"——**他周六没去公司**。

_他周三晨会王总监没来。他可能也焦虑。_

_或者他单纯今天累了。_

Lisa 朋友圈最新一条还是上周日"换个发型试试"——她整周没发新的。

你点了外卖: 粥 + 油条 + 卤蛋。35 块。
~ money = money - 35

_周末该花钱。_

_这周没小确幸。_

_或者小确幸是"我活到周五了"。这是我的 baseline。_

* [开始今日]
    -> day_20_event_1_passing_office_dark


// ----------------------------------------------------------------------------
// Event 20.1 · 14:00 · 路过公司 · 全黑
// ----------------------------------------------------------------------------
// 触发: 午饭后
// 速度: 闪 (~3 行)
// 设计意图: 跟 E2 周六对照 - E2 有 1 工位灯亮, E3 全黑
// ----------------------------------------------------------------------------

= day_20_event_1_passing_office_dark
# scene: street_passing_office_building
# time: 14:00

14:00 你出门吃饭, 又路过公司大楼。

你抬头看 16 楼——**所有工位灯都关着**。

_今天没人加班。_

_或者大家都在补觉。_

你转身去吃了一份兰州拉面 + 凉菜, 35 块。
~ money = money - 35

// 没有选项 - flavor 对照 E2 周六

~ check_state_after_choice()
-> day_20_event_2_couch_again


// ----------------------------------------------------------------------------
// Event 20.2 · 周六下午 · 又是沙发
// ----------------------------------------------------------------------------

= day_20_event_2_couch_again
# scene: bedroom_couch
# time: 16:00
# music: silence

下午 4 点。

你回到家。

你在沙发上躺了一会。

_这是 4 周以来第 4 个相同的周六下午。_

_粥 + 油条 + 拉面 + 沙发 + 不刷视频不刷购物 App。_

_我以为周末是奖励, 现在我意识到它是康复。_

_身体康复完了, 但脑子还在加班。_

你又躺了 30 分钟。

// 没有选项 - 周末白噪音
~ state = state + 30   // regenForRestDay 自动

~ check_state_after_choice()
# pagebreak
-> day_20_daily_recap


= day_20_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - David 周六没发朋友圈_
_  - Lisa 整周没发新朋友圈_
_  - 16 楼全黑_

# pagebreak
-> day_21_weekend_morning


// ============================================================================
// Day 21 · 周日
// ============================================================================

= day_21_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

# diegetic_ui: phone_video_call_incoming
# npc: mom_calling

8:30:00 整。微信视频铃响。

* [接通]
    -> day_21_event_1_mom_video_c


// ----------------------------------------------------------------------------
// Event 21.1 · 妈妈视频 · 8:30 (妈妈 C Vulnerability)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~12 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 C Vulnerability - "那个王二家儿子上海买房了"+ 笑天 3 秒沉默
// ----------------------------------------------------------------------------

= day_21_event_1_mom_video_c
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen

你接了。

# speaker: mama
妈妈："**天天, 吃了吗？**"

# speaker: protagonist
你："吃了。"

# speaker: mama
妈妈："**工资发了吗？**"

# speaker: protagonist
你："发了。"

# speaker: mama
妈妈："**那个王二家儿子上海买房了。**"

# speaker: protagonist
你："……"

_王二家儿子。我记得他——小学同学。_

_上海买房。_

_在上海。_

_3 秒沉默。_

妈妈: (她可能感觉到你的沉默) "没事, 你慢慢来。"

# speaker: protagonist
你："嗯。"

* [真的吗, 他在哪个区]
    # speaker: mama
    妈妈："好像是浦东。我不太懂。"
    _她笑了一下, "反正他妈妈在小区里跟人念叨, 我都听到第三遍了。"_
    ~ mom_score = mom_score + 1
    // hidden flag: 你听到了王二买房 + 妈妈炫耀

* [哦]
    # speaker: mama
    妈妈："嗯, 你忙。"
    _她换话题。"你那边天气怎么样？"_
    ~ mom_score = mom_score + 0

* [妈我有事先挂了]
    # speaker: mama
    妈妈："好好好不耽误你。"
    _她挂了。_
    ~ mom_score = mom_score - 2

- _不论选什么。_
- _王二买房。_
- _我小学同学。_
- _我妈不是想炫耀王二。她想问我"你呢"。_
- _但她没直接问。_
- _她每次都用别人的名字问我。_
- _"那个谁的儿子结婚了"——你呢。_
- _"那个王二家儿子上海买房了"——你呢。_
- _妈妈的"你呢" 永远是"那个谁"开头的。_
- _我每次都"再等等"。_

// hidden flag: 妈妈 D21 第一次具体提到对比 - series-level escalation

~ check_state_after_choice()
-> day_21_event_2_no_plant_today


// ----------------------------------------------------------------------------
// Event 21.2 · 周日下午 · 不去浇绿萝
// ----------------------------------------------------------------------------
// 触发: 周日下午
// 速度: 闪 (~3 行)
// 设计意图: 跟 E1 Day 7 对照 - 上周浇绿萝是小确幸, 这周不去是小确丧
// ----------------------------------------------------------------------------

= day_21_event_2_no_plant_today
# scene: home_afternoon_couch
# time: 14:00

你下午没去公司浇绿萝。

_上周日去了。这周我累了。_

你点了一份外卖咖啡。
~ money = money - 18

_绿萝周一会怎么样？我周一浇 5 滴弥补。_

// 没有选项 - Pillar 4 灰幽默 - 笑天没明说"小确丧"

~ check_state_after_choice()
-> day_21_event_3_thinking_next_monday


// ----------------------------------------------------------------------------
// Event 21.3 · 21:30 · 思考下周一 (Cliffhanger 至 E4)
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 标准 (~6 行)
// 设计意图: 笑天成了 Lisa - E1 周日晚 Lisa 备考的镜像
// ----------------------------------------------------------------------------

= day_21_event_3_thinking_next_monday
# scene: home_evening_after_shower
# time: 21:30
# diegetic_ui: phone_calendar

21:30。你刚洗完澡。

你看了一下日历。

_下周一。_

_下周一是**月末**。_

_下周一 9:30 KPI Review。_

_我这个月做了什么？_

你掰着手指算——

1. E1 帮 / 没帮 Lisa (茶水间让水、午饭、奶茶)
2. E2 帮 / 没帮 David PPT (周一选 A/B/C)
3. E2 帮 / 没帮 Lisa PPT (周五选 A/B/C)
4. 周三晨会"小笑你怎么看？" (王总监 B Decision)
5. 周报 1 次
6. 加班 N 次 (取决于 after_work 选择)
7. 老周对话 1 次"过完今天"
8. ……

_我做的事都是 NPC 的事。_

_我自己的 KPI 是什么？_

_我不知道。_

_王总监会知道。_

_他会 cue 我吗？_

_Lisa 周一晨会前问的就是这个。_

_她周一晨会前 21:30 准备的就是"如果王总监 cue 我我怎么答"。_

_今天 21:30 我也在准备同样的事。_

_我成了 Lisa。_

你关掉日历, 打开微信。

Lisa 没发消息。

David 朋友圈最新一条是周五 18:00 "Q2 收官冲刺最后一周, 加油！" 配自拍。

_他在朋友圈给自己加油。_

_我在床上。_

_我们俩都在准备同一件事。_

_他用朋友圈准备。我用床。_

_明天见分晓。_

你把手机放回床头, 但你没睡——你又拿起来再刷了一遍。

_我以为 22:00 之前能睡。_

_今天可能 23:30 才能睡。_

_然后明天 6:50 闹钟。_

_这 7 个小时不够补这 4 周累积的 KPI 焦虑。_

_但反正明天 9:30 就揭晓了。_

// 没有选项 - E3 → E4 cliffhanger

// hidden flag: E3 → E4 cliffhanger: 笑天 21:30 焦虑下周月末

~ check_state_after_choice()
# pagebreak
-> day_21_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 21 周日日报 (E3 末)
// ----------------------------------------------------------------------------

= day_21_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - **妈妈 C Vulnerability** ("那个王二家儿子上海买房了"+ 笑天 3 秒沉默)_
_  - 21:30 思考下周一月末 (笑天成了 Lisa)_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 15 周——月末倒数最后一周_

// E3 结束 - cliffhanger 到 E4 周一 月末倒数

-> END

// ============================================================================
// EOF episode-3.ink
// ============================================================================
