// ============================================================================
// Episode 14 · Week 14 · 「调休来加班」
// ============================================================================
//
// Status: 第 1 版 (S4 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S4 Round 1)
// Last Updated: 2026-05-07
//
// 配套 reference: season-4-arc.md §5 E14 beat sheet + round-1-reply.md
//
// 设计目标 (摘要):
//   1. 清明调休 seasonal beat — 办公室空一半 + David 卷王 + 王总监 mandatory + 老周准点
//   2. ★ David quiet sign 1: 朋友圈 0 条 (S2 起每周 5 条 → 这周 0 条) ★
//   3. ★ David 茶水间问 IT 小马第三次不耐烦 (S2 D40 / S3 D66 / S4 D93 累积) ★
//   4. ★ E14 Decision: 揭穿 David 抢功 (路径 A 玩家 cc 王总监 = promotion 缓速 -1) ★
//   5. 5:5 笑泪持平
//   6. Cliffhanger: 笑天意识 David 朋友圈 0 条 但不知为什么
//
// 红线:
//   - David 不能 E14 失态 (E16 才显形)
//   - 妈妈不 expose 爸爸 emotional anchor (清明 1 mention 不形成 spiral, per Q5)
//   - 老周 0 dialog
//   - 林姐不出场
//
// ============================================================================

INCLUDE episode-1.ink

-> episode_14


=== episode_14 ===
# scene: home
# time: monday_morning_week_14
# pagebreak

~ cumulative_hero_count = lisa_helped_pps + lisa_helped_after_hr + lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive + lisa_referred_external

-> day_92_morning_briefing


// ============================================================================
// Day 92 · 周一 (清明调休) · ★ 办公室空一半 + David 来加班 ★
// ============================================================================

= day_92_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:11
# weather: cleared
# speaker: protagonist

闹钟响 1 次。

_周一。清明节调休。_

_今天放 1 天补 1 天——意思是大部分人请假回家上坟, 周二补班。_

_我没回家。_

_公司不强制到岗, 但调休日 KPI 系数 1.2x — "奖励" 加班。_

_反向 KPI 极致——你休假被惩罚, 你加班被奖励。_

# scene: subway_carriage
# time: 8:30
# speaker: protagonist

地铁。今天人**比平时少 70%**——大家清明都走了。

地铁电视滚动: "清明假期高速免费, 全国主要城市出行 6.2 亿人次。"

_6.2 亿人次。_

_我不在那 6.2 亿里。_

_我在地铁 6 号线。从一个空荡的工位区到另一个空荡的工位区。_

# scene: office_entrance
# time: 9:11
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:11 到公司。

# speaker: vivian
Vivian: "嗨～来啦～"

# speaker: vivian
"今天小调休啊——"

# speaker: vivian
"嗨～你也来啊。"

# speaker: protagonist

她**也来**——她作为前台 mandatory。

水果盘**仍是苹果**。

~ fruit_bowl = "apple"

# prop: poster_qingming_schedule

打卡台贴**新海报**:

> "清明假期安排"
> "周一调休休 1 天 / 周二补班"
> "*周二补班 KPI 不计 1.2x"

_周二补班——KPI 1.2x 系数被取消。_

_只有今天加班才有 1.2x。_

_HR 系统精确控制 — 给你"放" 1 天但不让你真的少干。_

* [开始今日]
    -> day_92_event_1_qingming_workstation


= day_92_event_1_qingming_workstation
# scene: workstation_entry_qingming
# time: 9:18
# speaker: protagonist

你走到工位区。

工位区**空一半**。

A 区 (你工位 + 张磊或赵丽)、B 区 (David 工位 + 老周工位)、远端 王总监独立办公室。

# speaker: protagonist

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # npc: zhanglei_qingming_at_desk
    张磊**也来加班**——他 8:00 已到。

    他穿白衬衫 + 深蓝色西装裤——他 dressed up 比平时还正式。

    _他第 1 周清明也加班。他在 try。_

    _12 周后他可能 8:00 + 西装裤变 polo + 改 PPT 第 8 版。_

    _12 周后他可能不在了。_
}

{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
    # speaker: protagonist
    赵丽**没来**——她请假了。

    _赵丽周三 onboarding 才 1 周, 第一个 long weekend 她回家了。_

    _她可能下周回来。或者下下周。或者她直接走 — 像 12 周前的 small 李 (我不知道是谁)。_
}

{cumulative_hero_count == 0:
    # speaker: protagonist
    Lisa 原工位仍空。赵丽请假回家。
}

# speaker: protagonist

David 工位——

# npc: david_at_desk_qingming

David **已经在**。

他 7:50 到的——比平时早 40 分钟。

他在改 PPT — 不是 deliverable, 是**他自己写的"Q2 OKR 自我激励 ppt"**——他给自己做的。

_他清明都没回家。他老婆刚生孩子他不回家。_

_或者他老婆去外婆家了, 他自己在公司。_

_或者他老婆叫他回, 他没回。_

_3 种可能。我不会问。_

老周工位——

# npc: lao_zhou_qingming_present

老周**也在**——9:00 准点到。

他不调休——他每天都"调休"。他每天 8:00 到, 18:00 走。

# speaker: protagonist

_他不知道清明是哪天。_

_或者他知道, 但他**对所有节日 indifferent** — 他只 know 工作日 vs 周末。_

_他每天都是清明。_

# scene: wang_solo_office_door

王总监独立办公室——**门开着**。

# npc: wang_in_solo_office_qingming

# speaker: wang_director
王总监经过工位区 9:30:

# speaker: wang_director
"今天小调休啊。"

# speaker: wang_director
"大家辛苦。"

# speaker: protagonist

他 mandatory 到岗。他作为部门总监不能不在。

他到 19:00 才关门——办公室空一半但他不空。

_调休他比谁都累。这是他自己定的规则。_

~ check_state_after_choice()
-> day_92_after_work


= day_92_after_work
# scene: workstation_evening_qingming
# time: 17:30

* [申报加班 (KPI 1.2x)]
    你回工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 6
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你 17:30 走人。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

- _logged。_

~ check_state_after_choice()
# pagebreak
-> day_92_daily_recap


= day_92_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today (D92 清明):_

_  - 工位区**空一半** — 大部分请假上坟_

_  - David 7:50 到加班 (清明也来 = 第 1 个 visible quiet sign 起步)_

_  - 老周 9:00 准点 (他每天都"调休")_

_  - 王总监 mandatory 到岗 (他比谁都累)_

_  - 调休 KPI 1.2x — 你休假被惩罚, 加班被奖励_

# pagebreak
-> day_93_morning_briefing


// ============================================================================
// Day 93 · 周二 (补班) · ★ David 茶水间不耐烦第 3 次 ★
// ============================================================================

= day_93_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周二。补班日。

# scene: office_entrance
# time: 9:11
# npc: vivian_at_reception

9:11 到公司。

# speaker: vivian
Vivian: "嗨～来啦～ 嗨～补班大家收心。"

# speaker: protagonist

她念群通知——清明前一天她已经发过群: "**清明假期已结束, 大家收心**"。

水果盘**苹果**。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_93_event_1_david_irritated_at_it_3rd


// ----------------------------------------------------------------------------
// Event 93.1 · ★ David 茶水间问 IT 小马 第 3 次不耐烦 ★ · 14:30
// ----------------------------------------------------------------------------

= day_93_event_1_david_irritated_at_it_3rd
# scene: break_room_doorway
# time: 14:30
# npc: david_with_disposable_cup
# npc: it_xiaoma_at_coffee_machine
# speaker: protagonist

14:30。你下班路过茶水间——detour。

David 在茶水间。

IT 小马在咖啡机旁——他**还在修**。机修包打开, 零件散一地。

# speaker: david
David: "**修咖啡机** —"

# speaker: david
"**你那个**——"

# speaker: david
"什么时候修好啊?"

# speaker: protagonist

10 个字 + 句号。

_S2 D40 第 1 次他问"修咖啡机还要多久" — manager-style push。_

_S3 D66 第 2 次他用"要再问一下吗" — reframed manager-style。_

_S4 D93 第 3 次他直接 "什么时候修好啊" — 不再 reframe, 不再 manager-style, 直接 frustration 出来。_

_他每次 push, IT 小马 OKR 状态升级 1 次 (v1 → v2 → v3 → v4)。_

_David 第 3 次不耐烦 — 朝向 attenuation 的递进 (vs 前 2 次的 reframe attempt)。_

# speaker: it_xiaoma
IT 小马: "已派单, 等零件 v4。"

# speaker: it_xiaoma
"厂家说下周。"

# speaker: protagonist

David 0.5 秒——他**没说话**。

他端着一次性杯子, 转身走了。

他**没回敬, 没追问, 没 push 升级**。

他**accept 了 IT 小马的 v4 告示**。

_他放弃 push IT 小马了。_

_这是 David S4 的 micro signal: 他对 unwinnable 的事不再 push。_

_S2-S3 他 push, 因为他相信 "push 能让事情发生"。_

_S4 他停 push — 因为他自己也撑不住, 没 energy 再 push 别人。_

_这是 quiet sign 1 的 prelude。_

// hidden flag: David D93 第 3 次问 IT 不耐烦 + accept v4 告示

~ check_state_after_choice()
-> day_93_event_2_weekly_recap_early


= day_93_event_2_weekly_recap_early
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay
# speaker: protagonist

16:50。HR 系统提前周二弹出周报浮层 (clarify: 清明 4 天周末后 weekly_recap 提前)。

- 出勤率: 100%

- 主动产出条目: 取决于 D 92-93 选择

- 协作记录: standard

浮层底部: "**本月度 KPI 还有 16 天 (周日 4/30 推送月末通报)**"。

_16 天。_

_S4 第 2 周末 = 4/30 月末 KPI Review。_

~ check_state_after_choice()
-> day_93_after_work


= day_93_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    ~ lisa_score = lisa_score + 0

* [提前下班]
    ~ effort_overage = effort_overage - 1

- _logged。_

~ check_state_after_choice()
# pagebreak
-> day_93_daily_recap


= day_93_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_本月度 KPI 还有 16 天_

_关键时刻 today:_

_  - ★ David 茶水间问 IT 小马 "什么时候修好啊" 第 3 次不耐烦 + **accept v4 告示** (S2 D40 / S3 D66 累积升级 → S4 D93 attenuation prelude)_

_  - HR 周报 weekly_recap 提前到周二_

# pagebreak
-> day_94_morning_briefing


// ============================================================================
// Day 94 · 周三 · 晨会 + ★ E14 Decision: 揭穿 David 抢功 ★
// ============================================================================

= day_94_morning_briefing
# scene: meeting_room
# time: 9:25
# weather: cleared
# speaker: protagonist

周三。晨会日。

# scene: meeting_room
# time: 9:25
# npc: david_with_4_sticky_notes
# npc: lao_zhou_in_back

9:25 到会议室。

David 笔记本贴 4 张便利贴 — 清明加班的 "Q2 OKR 自我激励 ppt" 也在他便利贴 list 里。

老周后排, 中间那杯茶。

9:32 王总监推门。

* [开始今日]
    -> day_94_event_1_morning_meeting_qingming


= day_94_event_1_morning_meeting_qingming
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium
# speaker: wang_director

王总监打开 PPT。今天封面 "**S4 第 2 周 + Q1 closeout**"。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"我们这个团队啊, **清明大家辛苦**。"

# speaker: protagonist

PUA 模板复用 — "辛苦" 替代 "凝聚力"。

# speaker: wang_director
王总监: "S4 第 2 周 — Q1 closeout 这周。"

# speaker: david
David **抢话**:

# speaker: david
"王总, 我**主动报一下** — 清明那天我加班完成的 PPT 我已经发您了。"

# speaker: wang_director
王总监: "嗯。"

# speaker: protagonist

1 个字。王总监没接。

但他接着说:

# speaker: wang_director
王总监: "那个 PPT 嗯——挺好的, 不过有几个数据要 cross-check 一下。"

# speaker: wang_director
"小笑啊——你周一也来加班, 那个 PPT 你看过吗?"

# speaker: protagonist

_他在 cue 我评估 David 的 PPT。_

_S3 D65 王总监已经 try 过 1 次 "Lisa PPT 你看过没"——那时候他把笑天工具化第 1 次。_

_S4 D94 第 2 次 — 他对 David 同样工具化笑天。_

_他想让我评估 David 的 PPT — 但他真正想问的是 "这 PPT 是 David 写的还是抄的?"_

_David 周一 7:50 到, "改" 那 PPT 8 小时。但 David 改的是 PPT layout, 实际数据来源是我周日加班准备的 deliverable doc (路径 A 玩家)。_

_David 在 frame "他清明加班的成果"——但成果来源是我周日加班的 doc。_

_他在 mild 抢功。_

_笑天 3 选 1 — 这是 D94 Decision Moment。_

* [沉默 (你点头, 没说话)]
    # speaker: protagonist
    你: "嗯, 我看过。"
    # speaker: wang_director
    王总监: "好。"

    王总监换 PPT 下一张, 不再 follow。

    _你 protect David 的 narrative。但你也保留了自己的 sanity — 你没 cc 王总监 邮件证明这是你的 doc。_

    _中性。_

    ~ david_score = david_score + 0

* [会后私下 cc 王总监邮件 "附上原 draft"]
    # speaker: protagonist
    你: "嗯, 我看过。"

    会议结束后, 你回工位发了一封邮件 cc 王总监 + David: "附上 周一原 draft (你 D90 周日加班准备的 doc)。"

    王总监 5 分钟后回复: "**嗯, 收到。**"

    David 群里: "**@所有人** 笑天周日 prep doc, 我清明加班整合, 感谢笑天!"

    _他立刻 reframe 成 collaboration._

    _王总监 0 reaction 在群里。_

    _但你 cc 他 = 他 register 1 笔 "陈天会算计同事"。_

    _路径 A 玩家此选 promotion_candidate_count 缓速 -1 (王总监对你 "前途无量" 度 -1)。_

    ~ david_score = david_score - 5
    ~ kpi = kpi + 1
    ~ promotion_candidate_count = promotion_candidate_count + 0   // 缓速: 不增, 但记 1 笔
    // hidden flag: 王总监 D94 register 笑天会算计同事

* [会上当场说"那个 PPT 初稿是我做的"]
    # speaker: protagonist
    你: "**那个 PPT 初稿是我周日做的。**"
    # speaker: wang_director
    王总监 0.5 秒。
    # speaker: wang_director
    王总监: "**小笑啊…陈天啊…我们这边不分这个。**"

    晨会停 0.5 秒。

    # speaker: david
    David 0.3 秒——他没看你, 看王总监。

    # speaker: david
    David: "嗯, 笑天周日帮看了一版。"

    会议室 awkward。王总监换 PPT 下一张。

    _你当场说出来 — 你 burn the bridge with David。_

    _王总监对你"会拆台同事" 印象 +1 — 路径 A 玩家此选 promotion_candidate_count 缓速 -2 (比 cc 邮件还重)。_

    ~ david_score = david_score - 8
    ~ promotion_candidate_count = promotion_candidate_count + 0   // 缓速更重
    // hidden flag: xiaotian_callout_in_meeting = true

- _decision logged。_

# speaker: wang_director
王总监: "散会。"

8 分钟。

~ check_state_after_choice()
-> day_94_after_work


= day_94_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    ~ lisa_score = lisa_score + 0

* [提前下班]
    ~ effort_overage = effort_overage - 1

- _logged。_

~ check_state_after_choice()
# pagebreak
-> day_94_daily_recap


= day_94_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

_  - 晨会王总监 "清明大家辛苦" + David 主动报 "清明加班 PPT"_

_  - ★ E14 Decision: 揭穿 David 抢功 (3 选 1) — 路径 A 玩家 cc 邮件 promotion 缓速 -1_

# pagebreak
-> day_95_morning_briefing


// ============================================================================
// Day 95 · 周四 · Lisa 朋友圈 (路径 B 截图保存) / 微信 (路径 A)
// ============================================================================

= day_95_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周四。

# scene: office_workstation
# time: 9:11

9:11 到公司。

# diegetic_ui: phone_wechat_check
{
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        -> day_95_lisa_message_path_a
    - cumulative_hero_count >= 3:
        -> day_95_lisa_circle_path_b
    - cumulative_hero_count >= 1:
        -> day_95_lisa_silence_path_c
    - else:
        -> day_95_lisa_silence_path_e
}


= day_95_lisa_message_path_a
# diegetic_ui: phone_wechat_chat
# speaker: lisa

# speaker: lisa
Lisa 微信:

# speaker: lisa
"笑天, 清明回家了"

# speaker: lisa
"配图: 老家的菜花地"

# speaker: protagonist
你: "嗯, 不回。"

# speaker: lisa
Lisa: "好。"

# speaker: protagonist

4 句以内 closed。

_她在老家。她回家了。_

_我没回。我妈在我没回。_

_3 个人 3 个城市 3 个状态。_

~ lisa_score = lisa_score + 0

* [开始今日]
    -> day_95_event_1_workstation_quiet


= day_95_lisa_circle_path_b
# diegetic_ui: phone_wechat_moments_lisa
# speaker: lisa

# speaker: lisa
Lisa 朋友圈新 1 条 (今晨 7:00 发):

# speaker: lisa
"清明回家了"

配图: 老家照片 — 菜花地 + 远端山 + 妈妈的背影 (从远端拍, 看不清脸)。

# speaker: protagonist

_她回家了。_

_她朋友圈 7:00 发的——她可能 6:00 起来去坟上, 7:00 回来发朋友圈。_

_或者她 6:30 跟妈妈在菜花地拍照, 7:00 编辑发出。_

# diegetic_ui: phone_screenshot_save_action

你**截图保存**。

_我第一次保存 Lisa 朋友圈。_

_S2 末她"看花了" 我没保存。S3 中"也好我自己也想换换" 我没保存。_

_今天她"清明回家了" 配菜花地——我保存了。_

_我不知道为什么。可能是因为 这是她第一条不带 office 元素的朋友圈。_

_或者是因为 她在新公司的第 2 周, 我意识到她正在离开 office 文化。_

_或者是因为 我没回家, 她回了。_

// hidden flag: 笑天 D95 截图保存 Lisa 朋友圈

* [开始今日]
    -> day_95_event_1_workstation_quiet


= day_95_lisa_silence_path_c
# speaker: protagonist

_Lisa 朋友圈仍 muted。_

_今天清明 — 她可能回家了, 也可能没。我不知道。_

_我也回不去。_

* [开始今日]
    -> day_95_event_1_workstation_quiet


= day_95_lisa_silence_path_e
# speaker: protagonist

_Lisa silence。我也 silence。今天清明。_

* [开始今日]
    -> day_95_event_1_workstation_quiet


= day_95_event_1_workstation_quiet
# scene: workstation_quiet_thursday
# time: 14:00
# speaker: protagonist

14:00。

工位区静默。

# npc: david_at_desk_typing
David 在工位敲键盘。他**没发朋友圈** — S2 起每周 5 条, 这周 0 条。

_他 D90 周六发"反思 / 复盘 / 充电" 之后 0 条。_

_4 天累积 0 条 — pattern 形成。_

_quiet sign 1 visible 边缘。_

_S4 第 2 周末他可能 break silence，也可能 silence 持续。_

~ check_state_after_choice()
-> day_95_after_work


= day_95_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    ~ lisa_score = lisa_score + 0

* [提前下班]
    ~ effort_overage = effort_overage - 1

- _logged。_

~ check_state_after_choice()
# pagebreak
-> day_95_daily_recap


= day_95_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 路径 A: Lisa 微信"清明回家了" + 菜花地照片_
}

{cumulative_hero_count >= 3 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
    _  - 路径 B: Lisa 朋友圈"清明回家了" + 菜花地照 (笑天**截图保存**)_
}

_  - David 朋友圈本周连续 4 天 0 条 (quiet sign 1 visible 边缘)_

# pagebreak
-> day_96_morning_briefing


// ============================================================================
// Day 96 · 周五 · weekly_recap + ★ David 朋友圈 0 条 visible ★
// ============================================================================

= day_96_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared
# speaker: protagonist

周五。

9:08 到公司。

# scene: office_entrance
# prop: fruit_bowl_apple

水果盘**苹果** — 13 周连续。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_96_event_1_weekly_recap


= day_96_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay
# speaker: protagonist

16:50。HR 系统周报浮层。

浮层底部: "**本月度 KPI 还有 9 天**"。

~ check_state_after_choice()
-> day_96_event_2_david_friend_circle_zero


// ----------------------------------------------------------------------------
// Event 96.2 · ★ David 朋友圈 0 条 visible (quiet sign 1) ★
// ----------------------------------------------------------------------------

= day_96_event_2_david_friend_circle_zero
# scene: workstation_phone_check
# time: 17:00
# diegetic_ui: phone_wechat_moments
# speaker: protagonist

17:00。你刷朋友圈。

# speaker: david

David 朋友圈最新一条仍是 D85 周六"反思 / 复盘 / 充电"。

整周 — D90 周六到 D96 周五——**0 条新发**。

_他从 S2 起每周 5 条 (自拍 + 工位 + 自我激励 + Q2 OKR + 周末加班晒图)。_

_S3 末他 spinning words 升级 ("4 大冲刺" / "Q2 完美收官" / "6 月 4 大")。_

_S4 D90 他 spinning 到 "反思 / 复盘 / 充电" 三词组合——这是 spinning 的 ceiling。_

_然后**0 条**。_

_他撑到 spinning ceiling 之后, **不再 spin**。_

_他没有更高 register。_

_quiet sign 1 visible — 朋友圈 0 条整周。_

_我看着他朋友圈空。我不会问他怎么了。_

_他自己可能不知道他停了。_

// hidden flag: David D96 朋友圈 0 条整周 (quiet sign 1 visible 形成)

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # diegetic_ui: phone_wechat_message
    # speaker: lisa
    Lisa 微信 1 条:

    # speaker: lisa
    "周五加油。"

    # speaker: protagonist
    你: "嗯。"

    _4 句以内 — 但今天她只 1 句。她也没多。_
    ~ lisa_score = lisa_score + 1
}

~ check_state_after_choice()
-> day_96_after_work


= day_96_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班]
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    ~ lisa_score = lisa_score + 0

* [提前下班]
    ~ effort_overage = effort_overage - 1

- _logged。_

~ check_state_after_choice()
# pagebreak
-> day_96_daily_recap


= day_96_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_本月度 KPI 还有 9 天_

_关键时刻 today:_

_  - ★ **David 朋友圈本周 0 条** (quiet sign 1 visible 形成)_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - Lisa 微信"周五加油" 1 句_
}

# pagebreak
-> day_97_weekend_morning


// ============================================================================
// Day 97 · 周六 · 周末
// ============================================================================

= day_97_weekend_morning
# scene: bedroom
# time: 12:00
# music: weekend_silence
# speaker: protagonist

你睡到 12:00 醒。

# diegetic_ui: phone_wechat_moments

朋友圈:

David 仍 0 条——他的 D90 那条还在那, 没新的。

11:34 → 12:34。点外卖 35 元。
~ money = money - 35

* [开始今日]
    -> day_97_event_1_afternoon


= day_97_event_1_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence
# speaker: protagonist

下午 2 点。你在床上。

你打开购物车——浅色衬衫**还在**, ¥259。

_18 周没买。_

_可能下周。_

你又躺了 30 分钟。

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_97_daily_recap


= day_97_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# speaker: protagonist

_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_

_  - 12:00 起床_

_  - David 朋友圈 vs 周末 仍 0 条 (累积 6 天)_

# pagebreak
-> day_98_weekend_morning


// ============================================================================
// Day 98 · 周日 · 妈妈 callback "清明节你回了吗"
// ============================================================================

= day_98_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet
# speaker: protagonist

周日。

你 8:23 醒。

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_98_event_1_mom_video


= day_98_event_1_mom_video
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen
# speaker: mama

屏幕里是妈妈。

# speaker: mama
妈妈: "**天天, 清明节你回了吗?**"

# speaker: protagonist
你: "(根据 D91 选择 — 回 / 没回)"

{
    - mom_score >= 5:
        // 玩家 D91 选 "回"
        # speaker: mama
        妈妈: "嗯, 你姨他们都看到你了。说你瘦了。"
        # speaker: protagonist
        你: "嗯。"
        ~ mom_score = mom_score + 1
    - else:
        // 玩家 D91 选 "今年请不到假" 或 "再说"
        # speaker: mama
        妈妈: "**你姨他们说你不回, 我说你工作忙。**"
        # speaker: protagonist
        # speaker: protagonist
        # speaker: protagonist
        _她替我跟亲戚解释了。又一次。_

        _S1-S4 她每次替我 wrap up。_
        ~ mom_score = mom_score + 0
}

# speaker: mama

妈妈停顿 0.5 秒。

# speaker: mama
"那个谁的儿子最近回来相亲了。"

# speaker: protagonist

_她标准 S3 callback 模式 ("那个谁的 X 做了 Y")。_

_她不强求我对相亲表态——她只 deliver 信息。_

视频 6 分钟挂。

~ check_state_after_choice()
-> day_98_event_2_evening_cliffhanger


= day_98_event_2_evening_cliffhanger
# scene: home_evening
# time: 21:00
# diegetic_ui: phone_wechat_moments
# speaker: protagonist

21:00。你刷朋友圈。

# speaker: david

David 朋友圈仍 0 条。

D90 → D98 — 整 9 天 0 条。

_他从 S2 起每周 5 条 (累积 32 周 = 160 条)。_

_他这周 0 条。_

_这是 spike 还是 trend?_

_我不知道。但**1 周 0 条**已经够 visible 了——这是 quiet sign 1 完成的证据。_

# pagebreak

-> day_98_daily_recap


= day_98_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# speaker: protagonist

_今日 状态: {state}/100_

_关键时刻 today (E14 末):_

_  - 8:30 妈妈"清明节你回了吗" — D91 选回 / 没回 callback_

_  - 21:00 David 朋友圈仍 0 条 (累积 9 天)_

_NPC scores 末:_

_  Lisa {lisa_score} / David {david_score} / 妈妈 {mom_score}_

_下周一开始: 第 15 周 — 「他在打高尔夫」(David quiet sign 2 + 王总监 puppet form 4)_

-> END

// ============================================================================
// EOF episode-14.ink
// ============================================================================
