// ============================================================================
// Episode 2 · Week 2 · 「潜力一般」
// ============================================================================
//
// Status: 第 1 版 (分身 CC session 翻译稿 - 从 episode-2.md 翻译)
// Author: 分身 CC session (Round 2)
// Last Updated: 2026-05-05
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
//
// 设计目标 (摘要):
//   1. 集内高峰 = 周三晨会王总监讲反向 KPI 真相 ("潜力 = 你今天的最好成绩是
//      明天的最低标准") 直接 hit E1 周日晚 Lisa cliffhanger
//   2. Lisa 桌下手心写"加油" = 8:2 那个"2"的轻扎 (Lisa C Vulnerability per §5)
//   3. David B Decision Moment - "5 分钟的事" PPT 3 选 1 (承接 E1 周二 Chekhov gun)
//   4. Zoe 第一次出场 = E2 周四 (A First Impression + B Decision 合并 per Q2.1)
//   5. Vivian 草莓周对照 E1 苹果周 (融资信号反转的笑点)
//   6. Cliffhanger = 周日晚 Lisa "明天可能要加班" 是假, 她去剪头发
//
// ============================================================================

INCLUDE episode-1.ink

// E2 entry - 跳过 episode_1 的 -> day_1_morning_briefing
// 跑 E2 standalone 时, runtime 直接从此处开始
-> episode_2


// ============================================================================
// Episode 2 主入口
// ============================================================================

=== episode_2 ===
# scene: home
# time: monday_morning_week_2
# pagebreak
-> day_8_morning_briefing


// ============================================================================
// Day 8 · 周一 · 第 13 周第 1 天
// ============================================================================

= day_8_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:11

闹钟响了 2 次, 今天少 1 次。

_周末睡饱了。_

你出门, 地铁。10 号线今天不挤——你以为是周一所有人都迟到了, **其实是因为 5 号线在隔壁站故障, 10 号线分流了人**。

# scene: office_entrance
# time: 9:11
# npc: vivian_smiling_again
# prop: fruit_bowl_strawberry

9:11 到公司, 比上周一早 3 分钟。Vivian 抬头："嗨～来啦～"

你看了一眼她工位的水果盘。

**草莓**。

~ fruit_bowl = "strawberry"

_上周还是苹果。_

_草莓。融资到位的信号。_

* [开始今日]
    -> day_8_event_1_vivian_strawberry


// ----------------------------------------------------------------------------
// Event 8.1 · Vivian 的"嗨～今天草莓哦～" · 9:13 (Vivian B Decision)
// ----------------------------------------------------------------------------
// 触发: 刷工牌后
// 速度: 闪 (~4 行)
// 同框: Vivian
// NPC archetype: Vivian B (信号转换 + D 轮过会传闻)
// ----------------------------------------------------------------------------

= day_8_event_1_vivian_strawberry
# scene: reception_after
# time: 9:13
# npc: vivian_lowering_voice
# prop: fruit_bowl_strawberry_full

你刚要走过前台, Vivian 突然从后面追了一句。

"嗨～今天草莓哦～"

她压低声音："**融资群里说 D 轮过会了。**"

你回头看了她一眼, 她眨了一下眼。

_她跟所有人都说"草莓哦"。但只跟个别人加"D 轮过会了"。_

_我可能算她小信任名单上的人。_

_或者她对每个新员工都这么说, 她在帮老板做"员工归属感"工作。_

// 没有选项 - Vivian B 是信号传递, 不是决策
// hidden flag: S1 D 轮 mention - series-level setup, S2-S3 会有 callback
~ vivian_score = vivian_score + 0

~ check_state_after_choice()
-> day_8_event_2_lisa_check_in


// ----------------------------------------------------------------------------
// Event 8.2 · Lisa 的"周日回我消息了吗?" · 9:30
// ----------------------------------------------------------------------------
// 触发: 进入工位后第 1 个 event 前
// 速度: 标准 (~6 行)
// 同框: Lisa
// 设计意图: 兑现 E1 周日晚 21:30 cliffhanger
// ----------------------------------------------------------------------------

= day_8_event_2_lisa_check_in
# scene: workstation_lisa_turn
# time: 9:30
# npc: lisa_with_kpi_self_eval_word

你刚坐下, Lisa 转过来。

"笑天, 你周日回我消息了吗？"

_她是说我那个工单催 IT 的微信。_

_不是。她是说昨晚 21:30 那条"明天王总监会问 KPI 吧"。_

你看了一眼手机——你回过的 (如果选 A/B) / 你没回 (如果选 C)。

* [回了, 我说他每周三都问]
    # speaker: lisa
    Lisa："对哦, 谢谢。我准备了下。"
    _她打开 Word 给你看——她列了 3 条 KPI 自评要点。_
    ~ lisa_score = lisa_score + 2

* [回了, 我说不一定]
    # speaker: lisa
    Lisa："哦……那我也不太确定。要不今天先赶赶。"
    _她转回工位继续敲键盘。_
    ~ lisa_score = lisa_score + 1

* [没回, 对不起]
    # speaker: lisa
    Lisa："哦没事。"
    _她笑了一下, 转回工位。她列的那 3 条要点你后来路过看到了。_
    ~ lisa_score = lisa_score - 1

- _她周日 21:30 提的问题, 今天周一 9:30 还在 mind 里。_
- _她真的把这件事当事。_

~ check_state_after_choice()
-> day_8_event_3_david_5_min_thing


// ----------------------------------------------------------------------------
// Event 8.3 · David 的"5 分钟的事" · 上午 10:45 (David B Decision Moment - core)
// ----------------------------------------------------------------------------
// 触发: 第 2 个 event
// 速度: 长 (~12 行)
// 同框: David (微信)
// NPC archetype: David B Decision Moment - 承接 E1 周二 Chekhov gun
// ----------------------------------------------------------------------------

= day_8_event_3_david_5_min_thing
# scene: workstation_phone_buzz
# time: 10:45
# diegetic_prop: phone_wechat_david
# npc: david_via_wechat

10:45。企业微信弹出消息。

# speaker: david
David："兄弟, 上次跟你提过那个 PPT 模板还记得吗？现在比较急了, 下午 5 点要给王总监。28 页。"

_他上周二说"5 分钟的事"。今天是 28 页。_

_他上周说的"下周"。今天就是下周。_

_他什么都对, 但他骗了我"5 分钟"。_

5 分钟后他又发："**5 分钟的事啊。**"

_他还在用这 4 个字。_

* [接过来]
    你打开 PPT, 里面有 5 处明显错误。你改完发回。
    David 私聊："牛逼啊兄弟。"
    5 分钟后, 企业微信群弹出一条消息：
    # speaker: david
    David：@所有人 感谢 David 一晚加班, 把这个 PPT 修复了。
    _那是我改的。_
    群里 4 个人秒回："David 牛逼"、"@David 太厉害了"、"加班辛苦"、"❤️"。
    你点了一个 👍。
    _不点也行。但点了至少别人觉得我在群里活着。_
    ~ david_score = david_score + 2
    ~ kpi = kpi - 3
    ~ david_blood_drawn = david_blood_drawn + 1
    // hidden flag: 你被吸过血了 1 次 - E2 周二 David 群里假感谢戏码兑现

* [我也忙]
    你回："最近赶其他事, 5 分钟可能不够。"
    # speaker: david
    David："好吧, 我自己搞。"
    _他没说什么, 但你知道他记住了。_
    ~ david_score = david_score - 3
    // hidden flag: David 觉得你不上道

* [假装没看见]
    你不回。15 分钟后 David 私聊："在不在？"
    你回："在加班, 待会回你。"
    # speaker: david
    David："好。"
    _之后他没再发。_
    ~ david_score = david_score - 5
    // hidden flag: David 觉得你装 - E2 周二午饭他会"试探性"找你

-

~ check_state_after_choice()
-> day_8_event_4_vivian_corridor


// ----------------------------------------------------------------------------
// Event 8.4 · Vivian 的"草莓走廊" · 中午 12:15
// ----------------------------------------------------------------------------
// 触发: 午餐时间路过前台
// 速度: 闪 (~3 行)
// 同框: Vivian
// 设计意图: Pillar 4 灰幽默 - 草莓 = 客户来访 PR 道具 (笑天 over-read 被打脸)
// ----------------------------------------------------------------------------

= day_8_event_4_vivian_corridor
# scene: reception_passing
# time: 12:15
# npc: vivian_at_reception
# prop: strawberry_bowl_half_empty

12:15。你下楼吃饭, 路过前台。

Vivian 工位上的草莓盘已经空了一半。

她看见你："**草莓盘下午会再补一次**——老板说今天午后客户来访。"

_客户来访 = 草莓盘要看着满。_

_草莓周不是给员工的。是给客户的。_

_但客户还没到。_

_我拿了 2 颗。_

// 没有选项 - Pillar 4 灰幽默
// E1 笑天对苹果/草莓的解读今天被打脸 - 但温和的打脸

~ check_state_after_choice()
-> day_8_after_work


// ----------------------------------------------------------------------------
// after_work · Day 8 下班 · 17:30
// ----------------------------------------------------------------------------

= day_8_after_work
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
-> day_8_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 8 (per Q2.2 不列李阿姨)
// ----------------------------------------------------------------------------

= day_8_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi} (累积 {kpi}/200)_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - Vivian 草莓周 + D 轮过会信号_
_  - Lisa 还在 mind 周日的问题_
_  - David"5 分钟"PPT 兑现_
_  - 草莓真相打脸_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_9_morning_briefing


// ============================================================================
// Day 9 · 周二
// ============================================================================

= day_9_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14

# scene: office_entrance
# time: 9:14
# npc: vivian_no_extra_tail
# prop: fruit_bowl_strawberry_emptier
# npc: lao_zhou_with_tea_lighter_color

9:14 到公司。Vivian "嗨～来啦～", 今天她没加压低声的尾巴。

草莓盘**空了一大半**——下午客户走了, 没人补。

Lisa 已经在工位敲键盘——她周一晚上加班到 19:30 (你周日没回她, 她可能没睡好; 你回了她, 她睡前在改 KPI 自评)。

老周也在了——9:00:00 整。他桌上 3 个茶杯, 今天最右那杯泡的颜色比上周浅。

_他换茶叶了。_

_或者他今天泡得淡。_

* [开始今日]
    -> day_9_event_1_david_group_thanks


// ----------------------------------------------------------------------------
// Event 9.1 · David 群里的"@所有人" · 上午 10:20
// ----------------------------------------------------------------------------
// 触发: 第 2 个 event
// 速度: 标准 (~7 行)
// 同框: David (远端, 群消息)
// 注意: 内容根据 day_8_event_3 (David B) 选项分情况
// ----------------------------------------------------------------------------

= day_9_event_1_david_group_thanks
# scene: workstation_phone_buzz
# time: 10:20
# diegetic_prop: phone_wechat_group_message

10:20。企业微信群弹出消息。

{ david_blood_drawn > 0:
    # speaker: david
    David：@所有人 感谢 David 一晚加班, 把客户对接 PPT 修复完。下午 5 点过给王总监。
    _他周二早上 10:20 在 @所有人 感谢自己。_
    _他周一是没加班的。我帮他改的。我下午 17:30 走的, 他 17:35 在工位。_
    _他刷的是"加班姿态"。_
    群里 4 人秒回："牛逼"、"加班辛苦"、"❤️"、"David 永远在打基础"。
    你点了 👍。
    _不点也行。点了我在群里活着。_
}
{ david_blood_drawn == 0 and david_score < 0:
    # speaker: david
    David：@所有人 PPT 凑合搞完了, 下午 5 点给王总监。如果有时间帮看看的兄弟我请奶茶。
    _他在群里假装"求助"。其实他已经搞完了。_
    _他在做"我不抢功"的姿态——但他这条消息实质就是抢功。_
    群里没人回。
    _也没人请奶茶。_
}
{ david_blood_drawn == 0 and david_score >= 0:
    # speaker: david
    David：@所有人 这次客户对接 PPT 我自己赶出来了, 下午 5 点给王总监。
    _他自己赶的。可能他真的赶了一晚上。_
    _或者他找了别人改。_
    群里 3 人回："牛"、"辛苦"、"David 永远 reliable"。
    你没点 👍。
}

// 没有选项 - 笑天观察
// hidden flag: D 群消息已观察 - 情绪基线设定

~ check_state_after_choice()
-> day_9_event_2_david_seeks_lao_zhou


// ----------------------------------------------------------------------------
// Event 9.2 · David 跑去找老周"请教" · 上午 11:30
// ----------------------------------------------------------------------------
// 触发: 第 3 个 event
// 速度: 标准 (~7 行)
// 同框: David + 老周 + 笑天 (经过看到)
// 设计意图: cross-NPC 同框最锋利的一次 - 卷王找沉默 elder 求建议
// ----------------------------------------------------------------------------

= day_9_event_2_david_seeks_lao_zhou
# scene: corner_workstation_lao_zhou
# time: 11:30
# npc: david_bending_to_lao_zhou
# npc: lao_zhou_slowly_looking_up
# prop: a4_paper_ppt_screenshot

11:30。你去打印机取纸——打印机在老周工位旁边。

你走过去的时候看到 David 已经在老周工位边上了。

David 弯着腰："**周哥, 请教您一下, 您看下这个数据格式是不是这样合规？**"

他递过去一张 A4 纸——你瞥了一眼, 是 PPT 第 14 页的截图。

老周慢慢抬头, 看了 0.5 秒。

"嗯。"

他低下头继续看 Excel。

David 站直："好, 那就这么定。"
_他离开的时候表情是"我请教过老周了"。_

_他可能真的相信老周看了。_

_老周根本没看。老周说"嗯"是他的全部社交。_

_卷王找沉默 elder 求建议。_

_老周从未思考。但 David 解读出"老周在思考"。_

_完美闭环。_

// 没有选项 - cross-NPC 笑点观察
// 老周 +0 (他完全 unaware) ; David +0 (他自我感动 +1, 但 score 不变)

~ check_state_after_choice()
-> day_9_event_3_it_xiaoma_gaming


// ----------------------------------------------------------------------------
// Event 9.3 · IT 小马的"打游戏" · 下午 14:30 (IT 小马 C Vulnerability)
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 标准 (~6 行)
// 同框: IT 小马 (远端, 未察觉笑天)
// NPC archetype: IT 小马 C Vulnerability - 被偷看到, 笑天没揭穿
// ----------------------------------------------------------------------------

= day_9_event_3_it_xiaoma_gaming
# scene: it_corner_deepest
# time: 14:30
# npc: it_xiaoma_gaming_with_headphones
# prop: phone_with_wangzhe_rongyao
# prop: backup_printer_idle

14:30。你去 IT 角落问打印机的事——昨天打印机有点卡。

IT 小马的工位在角落最深处。你走到他工位前, 他不在椅子上。

你刚要走, 听到隔板后面有键盘咔嗒声。

你绕过去——IT 小马窝在备用打印机旁边的小凳子上, **戴着耳机**, 手机横屏。

屏幕上是**王者荣耀**。他正在团战。

你站着看了 5 秒。他没发现你。

他这一把团战赢了, 他默默 fist pump (小动作, 不发声)。

你后退两步, **没出声**, 回了自己工位。

_他装忙的间隙在打游戏。_

_他比我装得专业。_

_或者他比我活得明白。_

// 没有选项 - C vulnerability 是被偷看到, 笑天没揭穿
// hidden flag: 你看到 IT 小马打游戏 1 次 - E3 + S2-S3 IT 小马"已派单"running gag 玩家会有 prepared awareness
~ it_xiaoma_score = it_xiaoma_score + 0

~ check_state_after_choice()
-> day_9_event_4_lisa_v3


// ----------------------------------------------------------------------------
// Event 9.4 · 下午的工位 (Lisa V3) · 16:00
// ----------------------------------------------------------------------------
// 触发: 第 6 个 event
// 速度: 闪 (~3 行)
// 同框: Lisa (背景)
// ----------------------------------------------------------------------------

= day_9_event_4_lisa_v3
# scene: workstation_with_lisa_typing
# time: 16:00
# npc: lisa_typing_kpi_self_eval

16:00。Lisa 在工位敲键盘。她今天没买奶茶。

你回头看一眼——她屏幕上是 Word, 标题"个人月度 KPI 自评 (V3)"。

_V3。她改了 3 版了。_

_今天周二, 月底还有 10 天。_

_她不是在自评。她在反复确认这件事很重要。_

// 没有选项 - Lisa 在自我准备 - 为周三晨会做铺垫

~ check_state_after_choice()
-> day_9_after_work


= day_9_after_work
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
-> day_9_daily_recap


= day_9_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - David 群里"@所有人感谢" (按情况 A/B/C 不同剧本)_
_  - David 找老周"请教"笑点_
_  - IT 小马打游戏 vulnerability_
_  - Lisa V3 自评_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_10_morning_briefing


// ============================================================================
// Day 10 · 周三 · 晨会日 (★ 集内高峰 ★)
// ============================================================================

= day_10_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:25

# scene: meeting_room
# time: 9:25
# npc: lisa_with_pink_notebook_new
# npc: david_in_seat_facing
# npc: lao_zhou_in_back

9:25。Lisa 已经在会议室——还是提前 5 分钟。

_她今天比平时早 2 分钟。_

_她紧张。_

她带了一个新的笔记本——封面是粉色的, 看起来是新买的。

你坐到她旁边。她小声："笑天, 王总监今天会问 KPI 吧？"

_她还在问周日晚的同一个问题。_

* [开始今日]
    -> day_10_event_1_morning_meeting_kpi_truth


// ----------------------------------------------------------------------------
// Event 10.1 · 晨会 · 王总监讲反向 KPI 真相 · 9:32 (集内高峰 - Verbose)
// ----------------------------------------------------------------------------
// 触发: morning_briefing 后自动
// 速度: 长 (~14 行)
// 同框: 王总监 + David + Lisa + 老周 (背景) + 笑天
// 设计意图: S1 黑色幽默最浓段 - 反向 KPI 真相直接讲出来
// ----------------------------------------------------------------------------

= day_10_event_1_morning_meeting_kpi_truth
# scene: meeting_room
# time: 9:32
# npc: wang_with_blueprint_arrow_ppt
# npc: lisa_writing_jiayou_under_table
# prop: ppt_blueprint_one_arrow

9:32 王总监推门进来。今天 PPT 第一页标题: **Q2 团队 BLUEPRINT**。

页面正中央——一个箭头。

没了。

_一个箭头。_

_上周三聚餐 PPT 至少有图片。这周回归他的极简主义。_

"上午好啊各位。我先简单跟大家拉齐一下。这个月我们部门的 KPI 还有 10 天。我相信大家的潜力。"

他停了一下, 环顾全桌。

"潜力这个词啊, 你们听 100 遍可能也不在意。但其实它的意思是 ——"

他放慢语速。

"**你今天的最好成绩, 是你明天的最低标准。**"

屋里安静了一秒。

_他是不是把这话当励志了。_

_他自己讲的时候眼睛里没有一丝怀疑。_

_他真的相信。_

"我跟你们说啊, 要相信这个公司, 是命运共同体。"

你低头看到桌子下面——**Lisa 在自己手心里写了"加油"两个字**。蓝笔。她写完合上手。

// 没有选项 - 集内高峰整段是观察
// hidden flag: 听到反向 KPI 真相 1 次 + 看到 Lisa 桌下手心写"加油" 1 次

~ check_state_after_choice()
-> day_10_event_2_wang_cue_lisa


// ----------------------------------------------------------------------------
// Event 10.2 · 晨会 · 王总监 cue Lisa · 9:38
// ----------------------------------------------------------------------------
// 触发: 紧接 10.1
// 速度: 标准 (~5 行)
// 同框: 王总监 + Lisa + 笑天
// 设计意图: 王总监第一次单独 cue Lisa - S2 状态下滑的起手式
// ----------------------------------------------------------------------------

= day_10_event_2_wang_cue_lisa
# scene: meeting_room
# time: 9:38
# npc: wang_turning_to_lisa
# npc: lisa_lifting_head

王总监继续："Lisa。"

Lisa 抬头："嗯, 王总监。"

# speaker: wang_director
王总监："你这个月 KPI 怎么样？"

# speaker: lisa
Lisa："**还在赶。**"

王总监看了她 1 秒。

"嗯。再加点劲。**你的潜力我看好。**"

# speaker: lisa
Lisa："好的。"

_"你的潜力我看好"——他对 Lisa 说和对我说"加油啊" 是同一个 token。_

_他不在乎她真的能不能加上劲。他在乎"我提醒过她了"。_

// 没有选项 - 王总监第一次单独 cue Lisa
~ lisa_score = lisa_score - 3
// hidden flag: Lisa 被王总监 cue 1 次 - S2 王总监 cue 频率上升

~ check_state_after_choice()
-> day_10_event_3_wang_cue_xiaotian


// ----------------------------------------------------------------------------
// Event 10.3 · 晨会 · 王总监 cue 笑天 · 9:42 (王总监 B Decision)
// ----------------------------------------------------------------------------
// 触发: 紧接 10.2
// 速度: 标准 (~7 行)
// 同框: 王总监 + David + Lisa + 笑天
// NPC archetype: 王总监 B Decision Moment
// ----------------------------------------------------------------------------

= day_10_event_3_wang_cue_xiaotian
# scene: meeting_room
# time: 9:42
# npc: wang_turning_to_you
# npc: david_watching_you

王总监转向你。

"**小笑你怎么看？**"

你不知道他问的是哪句——"潜力"那段, 还是 Lisa 那段。

_他可能也不知道。他在 cue 我让我"参与"。_

_我答什么都"对", 因为他要的是"我答了"。_

David 在斜对面, 眼睛看向你——他想看你怎么应。

* [您说得对]
    # speaker: wang_director
    王总监："嗯, 挺好。"
    _他转回 PPT。_
    _我接住了。但他记住了我"接得快"——这不是好事。_
    ~ wang_score = wang_score + 5
    // hidden flag: 王总监开始把你当 yes-man - S2+ 频繁 cue 你 deliverable

* [沉默 / 看 PPT]
    # speaker: wang_director
    王总监："嗯？小……陈天。"
    _你抬头："您再说一下问题？"_
    # speaker: wang_director
    王总监："算了, 看下面。"
    _他转回 PPT, 没追究。_
    _我没接住。但他没记住——这是中性。_
    ~ wang_score = wang_score - 3

* [我觉得 deliverable 这周可以交]
    # speaker: wang_director
    王总监："**OK。Deliverable 这周交。**"
    _他记了 1 笔。_
    散会后 11:30 你企业微信收到他："小……陈天, 记得周五交那个 deliverable。"
    _他没说哪个 deliverable。你也没问。_
    ~ wang_score = wang_score + 0
    // hidden flag: 王总监开始记你 deliverable - E3-E4 反复出现

- _不论选什么, 你都"应"了。_
- _不应也是应——Pillar 2。_

~ check_state_after_choice()
-> day_10_event_4_lisa_jiayou_layer2


// ----------------------------------------------------------------------------
// Event 10.4 · 散会后看到 Lisa 桌下手心 · 9:55 (Lisa C Vulnerability layer-2)
// ----------------------------------------------------------------------------
// 触发: 散会后回工位路上
// 速度: 闪 (~4 行)
// 同框: Lisa
// 设计意图: vulnerability 加深 - layer-2 reveal
// ----------------------------------------------------------------------------

= day_10_event_4_lisa_jiayou_layer2
# scene: hallway_back_to_workstation
# time: 9:55
# npc: lisa_with_palm_still_writing
# prop: blue_ink_palm

散会, 9:55。你跟 Lisa 一起出会议室。

路上你瞥到她左手——刚才桌下写的"加油"两个字还在手心, 没擦。

她回工位的时候看了一下手心, 用右手食指搓了搓——蓝笔水还在。

她没去洗手间。她直接坐回工位敲键盘。

_她可能是不想去洗手间, 因为去了别人会问她"晨会怎么样"。_

// 没有选项 - Lisa C vulnerability 加深 (短延迟 reveal)

~ check_state_after_choice()
-> day_10_after_work


= day_10_after_work
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
-> day_10_daily_recap


= day_10_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today (★ 集内高峰整段 ★):_
_  - 晨会王总监讲"潜力 = 你今天的最好成绩是明天的最低标准"_
_  - 王总监 cue Lisa "你的潜力我看好"_
_  - Lisa 桌下手心"加油"_
_  - 王总监 cue 笑天 B Decision_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_11_morning_briefing


// ============================================================================
// Day 11 · 周四 (Zoe 第一次出场)
// ============================================================================

= day_11_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:13

# scene: office_workstation
# time: 9:13
# npc: lisa_with_blue_ink_remnants
# npc: lisa_typing_silently

9:13 到公司。Lisa 已经在工位——她今天来得比周一早 5 分钟。

她左手手心还有一点蓝笔印——洗手液没洗干净。

她没看你。她直接打字。

_她今天不会主动跟我说话。_

_她在自己的世界里。_

* [开始今日]
    -> day_11_event_1_li_ayi_morning_clean


// ----------------------------------------------------------------------------
// Event 11.1 · 早晨擦工位的李阿姨 · 9:08 (李阿姨 B Decision)
// ----------------------------------------------------------------------------
// 触发: 进入工位前
// 速度: 标准 (~6 行)
// 同框: 李阿姨
// NPC archetype: 李阿姨 B Decision
// 注意: 时间线上这场戏在 11.2 (Zoe 午餐) 之前发生
// 注意: 李阿姨 score 不影响机制 (per npcs.md §5)
// ----------------------------------------------------------------------------

= day_11_event_1_li_ayi_morning_clean
# scene: workstation_morning
# time: 9:08
# npc: li_ayi_wiping_desk
# prop: bread_crumbs_in_keyboard

你 9:08 到工位 (插叙: 实际在 morning_briefing 之前, 跟着叙事流我把它放在第一个 event)。

李阿姨在你工位上。她在用一块抹布擦你的桌面。

你停下来。

她抬头看了你 0.5 秒。

"**昨天有人在这吃东西啊。**"

你看了一眼桌面——一小块面包屑在键盘缝里。

_周二中午我没在工位吃。_

_周三晨会回来后我在工位吃了三明治。_

_那是我。_

* [是 David 来这写过 PPT 吧]
    李阿姨没回应, 继续擦。
    _她擦完走了。_
    // hidden flag: 你撒了一次小谎

* [啊, 可能是我, 对不起]
    李阿姨抬头看你 0.5 秒。
    _"小伙子, 慢点。"_
    // hidden flag: 你承认了 - 李阿姨记住你 1 次

* [不回应, 去看 morning_briefing 屏幕]
    _李阿姨擦完走了。_

- _不论选什么。_
- _她说"昨天有人在这吃东西"。她不在乎是不是我。_
- _她在打"我说了"那个卡。她的 KPI 是"提醒过"。_
- _我们俩都在被某个 KPI 系统驱动。我们俩 KPI 系统不一样而已。_

~ check_state_after_choice()
-> day_11_event_2_zoe_first_meeting


// ----------------------------------------------------------------------------
// Event 11.2 · 午餐 · HR 工位偷看 · 12:35 (Zoe A First Impression + B Decision)
// ----------------------------------------------------------------------------
// 触发: 午饭后回工位路上
// 速度: 长 (~12 行)
// 同框: Zoe + 笑天
// NPC archetype: Zoe A + B 合并 (per Q2.1 designer KEEP)
// ----------------------------------------------------------------------------

= day_11_event_2_zoe_first_meeting
# scene: hr_workstation_corridor
# time: 12:35
# npc: zoe_in_black_suit
# prop: zoe_screen_xiaohongshu
# prop: zoe_workstation_sticky_work_happily

12:35。你吃完饭回 16 楼。

你的工位在 A 区。HR 工位区在 B 区——你回工位最近的路要经过 B 区。

经过 HR 工位区——

你第一次注意到 Zoe 在哪——倒数第二个工位。她穿黑色西装外套 (HR 制服), 头发盘起来。脸上还有一点学生气。

她工牌上挂着公司吉祥物钥匙圈。

她工位隔板上贴一张小标语："**工作快乐**"——手写, 圆体字。

_工作快乐。_

_4 个字写在 HR 工位上。_

_像一个被困的人写"我没事"。_

她电脑屏幕开着小红书——你扫了一眼标题: 「**离开大厂的第 100 天, 我后悔了吗**」。

_她也在看这种攻略。_

她抬头看见你, 瞳孔放大 0.3 秒。她的右手已经在按 Tab 切换标签页了——但她没按完。

"**陈笑天先生。**"

她笑了一下, 那个 0.3 秒的慌张被职业微笑覆盖了。

* [假装没看见, 飞速走开]
    你"嗯"了一声, 加快脚步走过去了。
    你回工位的路上, 听到她切换标签页的"嗒"。
    _她以为你没看到。她不会知道。_
    ~ zoe_score = zoe_score + 0
    // hidden flag: Zoe 不知道你看到她了

* [跟她笑一下 (眼神交流)]
    你跟她对了 0.5 秒眼神, 然后笑了一下。
    Zoe 也笑了——这次是**真笑**, 0.3 秒的自嘲。
    "陈笑天先生, 午餐愉快。"
    _她切换了标签页, 但慢了 1 秒。_
    你回工位的路上想: 她可能记住了。
    ~ zoe_score = zoe_score + 5
    // hidden flag: Zoe 知道你看到她了 - E4 Zoe D 会有 callback ("哈" 加在结尾)

* [你也在看这个？]
    你停下来, 问了一句。
    Zoe 慌张："我朋友发的链接, 刚点开。"
    _她切换了标签页, 速度比平时快。她接着: "陈笑天先生, 您回工位吧。"_
    你回工位的路上想: 她记住了。但记住的是"被你揭穿"那种记法。
    ~ zoe_score = zoe_score - 3
    // hidden flag: Zoe 警觉 - S2-S3 她对你叫"陈笑天先生" 的频率会更高

- _不论选什么, 你看到了。_
- _HR 自己也在攒裸辞攻略收藏夹。_
- _我每次她叫我"陈笑天先生", 我就觉得我已经被裁了。_
- _但今天, 我也看到她"已经准备好被裁了"。_

~ check_state_after_choice()
-> day_11_after_work


= day_11_after_work
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
-> day_11_daily_recap


= day_11_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - Zoe 第一次出场 (A+B 同场)_
_  - 早晨工位被擦干净 (有人在这吃东西的痕迹被清理)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_12_morning_briefing


// ============================================================================
// Day 12 · 周五 weekly_recap day
// ============================================================================

= day_12_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:09

# scene: office_entrance
# time: 9:09
# npc: vivian_at_reception
# prop: fruit_bowl_apple_again

9:09 到公司。

Vivian 前台的水果盘今天又是**苹果**。

~ fruit_bowl = "apple"

_草莓周只持续了 4 天。D 轮过会的"信号"撑了周一周二, 周三周四就没了。_

_可能融资其实没过。Vivian 的"过会了"是听传闻。_

_或者过会了但只过了一半 (一半草莓 + 一半苹果中间日)。_

_我不知道。我也不重要。_

* [开始今日]
    -> day_12_event_1_lisa_ppt_help


// ----------------------------------------------------------------------------
// Event 12.1 · Lisa 的求救 · 下午 17:25 (Lisa B Decision Moment - core)
// ----------------------------------------------------------------------------
// 触发: 第 7 个 event, 下班前
// 速度: 长 (~12 行)
// 同框: Lisa
// NPC archetype: Lisa B Decision Moment - core 选择
// ----------------------------------------------------------------------------

= day_12_event_1_lisa_ppt_help
# scene: workstation_lisa_lean_over
# time: 17:25
# npc: lisa_handing_laptop_with_ppt

17:25。大部分人下班了。Lisa 还在工位。

她转过来。

"笑天, 你能帮我看下这个 PPT 吗？我做了一下午了一直觉得哪里不对, 王总监说让我下午 5 点之前发——我已经晚了 25 分钟。"

她递过来电脑——屏幕上是一个 PPT, 封面是"Q2 用户增长方案"。

_这个 PPT 周二 David 找老周"请教" 的就是同一份。_

_David 周一交了一版, 王总监说"再修改" 把任务下发给 Lisa。_

_这件事 David 不知道。Lisa 也不知道。我知道, 我什么都没说。_

* [接过来 帮她改]
    你接过来, 10 分钟扫一遍。
    内容是 OK 的, 但**第 4 页有 1 个错别字** ("用户行为留存" 写成了"用户行未留存") + 第 7 页**数据表格列错位** + 结论页**4 条被压缩成 3 条**。
    你改完, 发回。
    # speaker: lisa
    Lisa："谢谢谢谢, 我自己看到第 4 页 5 遍了都没看出来。"
    她发出去了。
    18:00 王总监回："收到。"
    Lisa 转过来对你笑了一下。
    她左手手心还有"加油"印——你今天第二次注意到。
    ~ lisa_score = lisa_score + 10
    ~ kpi = kpi - 3
    ~ lisa_helped_pps = true
    // hidden flag: Lisa 第一次靠近你 = +10

* [委婉拒绝]
    你回："我也不知道你的 KPI 标准是什么。"
    # speaker: lisa
    Lisa："哦哦……好。"
    _她回工位, 自己又改了 30 分钟。最后 18:15 发出去。王总监 18:25 才回: "Lisa 你这个表格列错位了, 再改一下。"_
    _Lisa 19:00 才下班。_
    ~ lisa_score = lisa_score - 3
    // hidden flag: Lisa 第一次被王总监 push 改 PPT

* [我也忙]
    # speaker: lisa
    Lisa："嗯, 那我自己看。"
    _她回工位, 没再说话。她 18:00 准时把那份没改的 PPT 发了出去。王总监 18:30 回: "Lisa 你这表格列对一下, 明早重发。"_
    _Lisa 看到回复时已经在地铁上。她周末要补这个 PPT。_
    ~ lisa_score = lisa_score - 8
    // hidden flag: Lisa 周末加班 - E2 周日晚她可能编"明天加班"是真的

- _不论选什么。_
- _她真的把这件事当事。_
- _她周一晨会前在准备, 周三晨会被 cue, 周五还在被王总监 push。_
- _她在跑一场没有终点的考试。_

~ check_state_after_choice()
-> day_12_event_2_weekly_recap_overlay


// ----------------------------------------------------------------------------
// Event 12.2 · weekly_recap 浮层 · 16:50
// ----------------------------------------------------------------------------
// 触发: 周五下班前
// 速度: 标准 (~5 行)
// ----------------------------------------------------------------------------

= day_12_event_2_weekly_recap_overlay
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出。

- 出勤率: 100%
- 主动产出条目: 1 项 (周报) / 2 项 (如果你帮 Lisa)
- 协作记录: N 项

浮层底部: "**本月度 KPI 还有 3 天, 请关注个人考核进度**"。

_3 天。下周一就是月末。_

_王总监周三晨会"还有 10 天" → 周五"3 天"。_

_时间在加速。或者我感受到了 KPI 截止的引力。_

~ check_state_after_choice()
-> day_12_after_work


= day_12_after_work
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
-> day_12_daily_recap


= day_12_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - Lisa B Decision (核心选择)_
_  - HR 系统提示 KPI 倒数 3 天_
_  - 周五晚 Lisa 状态 (取决于 12.1)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_13_weekend_morning


// ============================================================================
// Day 13 · 周六 (周末)
// ============================================================================

= day_13_weekend_morning
# scene: bedroom
# time: 11:08
# music: weekend_silence

你睡到 11:08 醒。

_今天比上周早 6 分钟。我在退步。_

# diegetic_ui: phone_wechat_moments

朋友圈: David 又发了"周末来加班的都是兄弟" 配自拍——**还是工位**, 但今天背景能看到 Lisa 工位**没人** (如果周五选 A/B) / **有人** (如果选 C, Lisa 周末加班)。

_他每周六都在公司。_

_他可能其实不工作, 他只是要"在公司"这个姿态。_

_或者他真的工作。我不知道。_

你点了外卖: 粥 + 油条。32 块。
~ money = money - 32

# diegetic_ui: phone_wechat_message
# npc: mom_via_phone

12:34, 妈妈微信消息: "**天天, 明天 8:30 视频。**"

_她每周日都视频, 她还是每周六下午提醒我一次。_

_她怕我忘。_

* [开始今日]
    -> day_13_event_1_passing_office


// ----------------------------------------------------------------------------
// Event 13.1 · 下午 14:00 · 周末空段
// ----------------------------------------------------------------------------

= day_13_event_1_passing_office
# scene: street_passing_office_building
# time: 14:00

你下午 14:00 出门吃饭, 路过你公司楼下。

你看了一眼公司大楼——16 楼有 1 个工位灯亮着。

_可能是 David。可能是 Lisa (周五选 C)。可能是清洁阿姨在加班。_

_我不上去看。_

你转身去吃了一份兰州拉面 + 凉菜, 35 块。
~ money = money - 35

// 没有选项 - 周末 flavor
~ state = state + 15   // 上午 regen 一半

~ check_state_after_choice()
-> day_13_event_2_afternoon_couch


// ----------------------------------------------------------------------------
// Event 13.2 · 下午 16:00 · 沙发上的什么都不做
// ----------------------------------------------------------------------------
// 触发: 周六下午
// 速度: 闪 (~6 行)
// 设计意图: 周末白噪音第二段 - 与 E1 Day 6 形成节奏对照
// ----------------------------------------------------------------------------

= day_13_event_2_afternoon_couch
# scene: bedroom_afternoon_couch
# time: 16:00
# music: silence

下午 4 点。

你回到家。

你在沙发上躺了一会。

你开了空调——27 度。

你想看个电影。你打开了某个流媒体 App, 滚了 5 分钟没找到想看的, 关了。

_周末看什么都不对。_

_周一到周五"想"看电影是因为没时间。周末有时间, 反而没"想看的"。_

_或者我只是累。_

_或者我在跟自己说"我累"——这样我就不用真的看电影。_

你又躺了 30 分钟。手机响——你看了一眼, 不是 Lisa, 是某个 App 推送。

你关了通知。

# diegetic_ui: phone_wechat_check

你又打开微信看了一眼, Lisa 没发新消息——她可能在改 PPT (周五选 C) / 在看电影 / 在睡觉。

_她周日才会发消息。_

_我也周日才会回。_

_我们俩都在节省周末的"互动 budget"。_

// 没有选项 - 周末白噪音第二段
~ state = state + 15   // 下半 regen +15 (合计 +30 一天)

~ check_state_after_choice()
# pagebreak
-> day_13_daily_recap


= day_13_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - David 朋友圈_
_  - 公司楼下 16 楼灯亮_
_  - 妈妈微信提醒视频_

# pagebreak
-> day_14_weekend_morning


// ============================================================================
// Day 14 · 周日
// ============================================================================

= day_14_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

# diegetic_ui: phone_video_call_incoming
# npc: mom_calling

8:30:00 整。微信视频铃响。

* [接通]
    -> day_14_event_1_mom_video_b


// ----------------------------------------------------------------------------
// Event 14.1 · 妈妈视频 · 8:30 (妈妈 B Decision)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~10 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 B Decision Moment - "你那边冷不冷"
// ----------------------------------------------------------------------------

= day_14_event_1_mom_video_b
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses

8:30:00 整。微信视频铃响。

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
妈妈："**那个谁的儿子结婚了。**"

# speaker: protagonist
你："嗯。"

她停了 1 秒。

"**你那边冷不冷？**"

* [不冷]
    # speaker: protagonist
    你："不冷, 挺好的。"
    # speaker: mama
    妈妈："好好好。"
    _她把镜头转向窗外。"我们这边昨天下雨。"_
    _她又拉回镜头。"你妈给你做了点辣椒酱, 下个月你回来拿。"_
    _我下个月没说要回去。_
    _但她说"下个月你回来拿" = "你下个月该回来了"。_
    _她从来不说"你回来", 她说"你回来拿东西"。_
    ~ mom_score = mom_score + 2

* [有点冷]
    # speaker: protagonist
    你："最近降温了。"
    # speaker: mama
    妈妈："**我给你寄个毛衣。**"
    _她声音突然有目标。"我下午就去快递点。"_
    # speaker: protagonist
    你："不用, 妈, 我有。"
    # speaker: mama
    妈妈："你有几件？"
    # speaker: protagonist
    你："5 件。"
    _我有 10 件灰 + 10 件黑 polo。但毛衣就 1 件。_
    # speaker: mama
    妈妈："不够。我寄。"
    ~ mom_score = mom_score + 3
    // hidden flag: 妈妈下周寄毛衣 - E3 周一/周二可能到货 mention

* [转移话题: 妈你呢]
    # speaker: mama
    妈妈："我啊, 挺好的。"
    _她笑了一下。_ "前天去广场跳了一会儿。"
    # speaker: protagonist
    你："好。"
    # speaker: mama
    妈妈："你呢？"
    # speaker: protagonist
    你："**再等等。**"
    _她沉默了 2 秒。_ "好。"
    ~ mom_score = mom_score + 0

- _挂掉视频后你坐在床上 30 秒。_
- _她每周都一样的剧本。但她每周都加 1 句新的——"那个谁的儿子" / "你那边冷不冷"——她在试探我的生活。_
- _她试探不出什么。我都说"好"。_

~ check_state_after_choice()
-> day_14_event_2_lisa_overtime_msg


// ----------------------------------------------------------------------------
// Event 14.2 · Lisa 的"明天加班"消息 · 21:30 (Cliffhanger 至 E3)
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 标准 (~6 行)
// 同框: Lisa (微信)
// 设计意图: E2 → E3 cliffhanger - Lisa 朋友圈 PPT V8 + "看花了" 暗示眼药水 setup
//          (W3 patch: 剪短发 motif 留给 S2 E7 — per season-2-arc.md §8 Option A)
// ----------------------------------------------------------------------------

= day_14_event_2_lisa_overtime_msg
# scene: home_evening
# time: 21:30
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:30。你刚洗完澡。

微信消息 1 条。

# speaker: lisa
Lisa：

"笑天, **明天我可能要加班, 先溜了。**"

_"先溜了"是什么意思。她周日晚 21:30 在床上发"明天我先溜了"。_

_她不是说"明天到公司"。她是说"明天她要做什么"。_

_"先溜了" = "我可能不去早班" / "我请假晚到"。_

# diegetic_ui: phone_wechat_moments
# prop: lisa_ppt_screen_photo

你打开手机看了一下她朋友圈——她发了一张图, **PPT 屏幕**, 截图右上角时间是 23:47。配文: "看花了。"

_她改 PPT 改到 23:47。_

_她现在 21:30 还在改。_

_或者 23:47 是她周六的, 她现在已经躺平。_

_我不会问。_

* [哦哦明天见]
    # speaker: lisa
    Lisa："嗯。"
    _没了下文。_
    ~ lisa_score = lisa_score + 0

* [你还好吧]
    # speaker: lisa
    Lisa："还好啦。**就……改了 8 版了。**"
    _没了下文。_
    ~ lisa_score = lisa_score + 1
    // hidden flag: 你听到 Lisa 说"改了 8 版"

* [不回]
    _她没追问。_
    ~ lisa_score = lisa_score - 1

- _不论选什么。_
- _她周日晚朋友圈是 PPT 屏幕。_
- _"看花了" —— 这是 Lisa 第一次说"看花"。_
- _她平时不抱怨眼睛。_
- _今天她抱怨了。_
- _8:30 妈妈视频 + 21:30 Lisa 微信。我今天做了 2 个 NPC 的 small talk。_
- _不多。但算我赢一次。_

// hidden flag: E2 → E3 cliffhanger: Lisa 明天桌上眼药水

~ check_state_after_choice()
# pagebreak
-> day_14_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 14 周日日报 (E2 末)
// ----------------------------------------------------------------------------

= day_14_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 8:30 妈妈视频"你那边冷不冷？" (妈妈 B Decision)_
_  - 21:30 Lisa 朋友圈"看花了" (E2 → E3 cliffhanger)_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 14 周——月末倒数 2 天_

// E2 结束 - cliffhanger 到 E3 周一 Lisa 桌上眼药水

-> END

// ============================================================================
// EOF episode-2.ink
// ============================================================================
