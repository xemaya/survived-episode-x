// ============================================================================
// Episode 15 · Week 15 · 「他在打高尔夫」
// ============================================================================
//
// Status: 第 1 版 (S4 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S4 Round 1)
// Last Updated: 2026-05-07
//
// 配套 reference: season-4-arc.md §5 E15 beat sheet + round-1-reply.md
//
// 设计目标 (摘要):
//   1. ★ David quiet sign 2: 晨会被王总监打断 verbatim "好了 David 我明白了" ★
//   2. ★ 王总监 puppet form 4: 周四晚独立办公室打高尔夫 (S2 灯亮 / S3 打电话 / S4 打高尔夫 递进) ★
//   3. ★ 林姐路径 A 茶水间偶遇 0 句话 + 0.3 秒看笑天工位方向 (per Q6 strict) ★
//   4. E15 Decision: 周二提前 cc 王总监 deliverable (路径 A 玩家 promotion 加速)
//   5. E15 Decision: Zoe 季度协作反馈 (路径 A 玩家 promotion 隐藏 source)
//   6. 5:5 笑泪持平
//   7. Cliffhanger: David 朋友圈仍 0 条 → S6 离职 朋友圈 ironic foreshadow
//
// Verbatim 必保:
//   - 王总监 D101 "**好了 David 我明白了**"
//
// 红线:
//   - David 不能 E15 失态 (E16 才显形)
//   - 老周 0 dialog
//   - 林姐 路径 A E15 仅 0 句话 (per Q6 strict)
//
// ============================================================================

INCLUDE episode-1.ink

-> episode_15


=== episode_15 ===
# scene: home
# time: monday_morning_week_15
# pagebreak

~ cumulative_hero_count = lisa_helped_pps + lisa_helped_after_hr + lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive + lisa_referred_external

-> day_99_morning_briefing


// ============================================================================
// Day 99 · 周一 · ★ David baseline 又抬高 (8:00 已到) + Lisa 微信 (路径 A) ★
// ============================================================================

= day_99_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared
# speaker: protagonist

闹钟响 1 次。

_S4 第 3 周。David 朋友圈累积 9 天 0 条。Lisa motif 路径 specific。_

_今天周一 4 月中。_

# scene: subway_carriage
# time: 8:30
# speaker: protagonist

地铁。今天人正常。

地铁电视: "本月 A 股反弹 0.4% — 有传闻互联网公司 D 轮融资活动回暖。"

_'有传闻'。Vivian 上周说"老板这周二三跟投资人吃饭"——可能融资真的回暖了。_

_市场 + 老板 vs 笑天 + David 仍是平行 universe。_

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:14 到公司。

# speaker: vivian
Vivian: "嗨～来啦～"

# speaker: vivian
她**压低声音**:

# speaker: vivian
"嗨～听说老板这周二三跟投资人吃饭。回来要不就草莓周了。"

水果盘**仍是苹果** — 但 Vivian leak signal 升级。

~ fruit_bowl = "apple"

# speaker: protagonist

_她在 selective leak — 她对我用 1 句, 对其他人不一定。_

_她做 6 年前台, 她 know whose ear is safe._

# diegetic_ui: phone_wechat_check
# speaker: lisa

{cumulative_hero_count >= 5 and lisa_score >= 25:
    9:18 你坐到工位。微信 1 条。

    # speaker: lisa
    Lisa: "笑天, 新部门正在做 Q1 复盘。"

    # speaker: protagonist
    你: "嗯。"

    # speaker: lisa
    Lisa: "我跟林姐 review。"

    # speaker: protagonist
    你: "好。"

    _4 句模式 — 路径 A standard。_
    ~ lisa_score = lisa_score + 1
}

# scene: workstation_with_david
# npc: david_at_desk_8am

David 工位——

他**8:00 已到** (你 9:14 看到他屏幕上 PPT 已 modified 第 6 次)。

_S3 末他周二 16:00 写下下周计划。S4 D85 他周一 8:30 已到。S4 D99 他周一 8:00 已到。_

_他每周一比上周一**早 30 分钟**。_

_他 baseline spiral up — 加速。_

* [开始今日]
    -> day_99_event_1_lao_zhou_baseline


= day_99_event_1_lao_zhou_baseline
# scene: corner_workstation_lao_zhou
# time: 11:30
# npc: lao_zhou_facing_window
# speaker: protagonist

11:30。你去打印机。

老周——

他**面对窗户**, 中间那杯茶。

他**8:00 到** — baseline 不变。

# speaker: protagonist

_S3 D45 周三 9:00 我到, 看到老周 8:00 已在工位。_

_S4 D99 也是。他 12 年 8:00 到。_

_他每天**8:00 - 18:00**。_

_他的"过完今天"是从 8:00 到 18:00 — 不是从 0:00 到 24:00。_

_他每天都"调休"。_

_他每天都过完今天。_

_他不 spiral up。他不 spiral down。他 horizontal._

_David 在 spiral up — 8:30 → 8:00 → 可能 7:30 → 7:00。_

_老周从来不 spiral。_

_他比 David 长寿 12 年。_

~ check_state_after_choice()
-> day_99_after_work


= day_99_after_work
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
-> day_99_daily_recap


= day_99_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

_  - Vivian leak "老板这周二三跟投资人吃饭, 回来要不就草莓周"_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 路径 A: Lisa 微信"新部门 Q1 复盘 + 跟林姐 review" 4 句_
}

_  - David 8:00 已到 (baseline 比 D85 又早 30 分钟 — spiral up 加速)_

_  - 老周 8:00 baseline 12 年 horizontal (vs David spiral up)_

# pagebreak
-> day_100_morning_briefing


// ============================================================================
// Day 100 · 周二 · ★ E15 Decision 1: 王总监 deliverable 提前 2 天 ★
// ============================================================================

= day_100_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周二。

# scene: office_workstation
# time: 9:11

9:11 到公司。

* [开始今日]
    -> day_100_event_1_wang_passing


= day_100_event_1_wang_passing
# scene: workstation_with_wang_arriving
# time: 9:30
# npc: wang_passing_then_pausing
# speaker: wang_director

9:30。

# speaker: wang_director
王总监经过笑天工位:

# speaker: wang_director
"小笑啊。"

0.5 秒。

# speaker: wang_director
"陈天啊。"

0.5 秒。

# speaker: wang_director
"差不多差不多。**这周 deliverable 我看一下吧。**"

# speaker: protagonist

_今天周二。这周 deliverable 我周五交是 standard。_

_他周二来要看 — 比 standard **提前 3 天**。_

_S3 D52 他对 Lisa "Lisa 这边月度 KPI 怎么样" 周三晨会问。今天他对我提前 3 天问。_

_他 cue 我频率从 S1 D15 (新月份) → S4 D100 (周二) — frequency increase from monthly cue 升级到 weekly proactive cue。_

_路径 A 玩家 reward 兑现: cue 频率 +2/集。_

_我 3 选 1。_

* [好的王总, 今天发您]
    # speaker: protagonist
    你: "好的王总, 今天发您。"
    # speaker: wang_director
    王总监: "**嗯。你比 David 跟得紧。**"

    8 个字。

    # speaker: protagonist
    _他比较了 — David vs 笑天。_
    _他公开**对比**——他对 David 烦, 对我 register positive。_
    _路径 A reward 加速: promotion candidate prelude 直接强化。_

    你今天加班把 deliverable doc 发完。
    ~ kpi = kpi + 1
    ~ state = state - 5
    ~ david_score = david_score - 3
    {cumulative_hero_count >= 5 and lisa_score >= 25:
        ~ promotion_candidate_count = promotion_candidate_count + 0
    }

* [周五准时发您]
    # speaker: protagonist
    你: "周五准时发您。"
    # speaker: wang_director
    王总监: "嗯。"
    王总监走开。
    _standard。他 register 但不强化。_
    ~ kpi = kpi + 0

* [今天没赶完, 周一行吗]
    # speaker: protagonist
    你: "王总, 今天没赶完, 周一行吗?"
    # speaker: wang_director
    王总监 0.5 秒。
    # speaker: wang_director
    "嗯, 周一吧。"
    王总监走开 — 他**没说什么**, 但他走得比平时慢 0.5 秒。
    _他记 1 笔 — 跟 cc 邮件 D94 那 1 笔类似 但更轻一档。_
    ~ kpi = kpi - 2

- _logged。_

~ check_state_after_choice()
-> day_100_event_2_vivian_chat


= day_100_event_2_vivian_chat
# scene: corridor_passing_reception
# time: 14:00
# npc: vivian_at_reception
# speaker: vivian

14:00。你路过前台。

# speaker: vivian
Vivian: "嗨～你猜老板昨晚跟投资人吃饭怎么样?"

# speaker: protagonist
你: "不知道。"

# speaker: vivian
Vivian: "我也不知道, 明天看水果盘。"

她笑了一下。

# speaker: protagonist

_她和我每天 cross-checking 老板心情 — 通过水果盘。_

_老板自己也通过水果盘 broadcast 心情 — 这是双向 ironic mirror。_

_他用 4 个 苹果 / 草莓 sticker 跟我们沟通。我们用 staring at 水果盘 sticker 跟他沟通。_

~ check_state_after_choice()
-> day_100_after_work


= day_100_after_work
# scene: workstation_evening
# time: 17:30

* [申报加班 (D100 选 A 已申报)]
    ~ state = state - 0   // 已计入 D100 event_1

* [按时下班]
    ~ lisa_score = lisa_score + 0

* [提前下班]
    ~ effort_overage = effort_overage - 1

- _logged。_

~ check_state_after_choice()
# pagebreak
-> day_100_daily_recap


= day_100_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

_  - ★ 王总监 9:30 cue "deliverable 我看一下吧" 比 standard 提前 3 天 (Decision 3 选 1)_

_  - 路径 A 玩家选 A: 王总监 "你比 David 跟得紧" — 路径 A reward 加速_

_  - Vivian 跟笑天 cross-checking 老板心情 (水果盘 ironic mirror)_

# pagebreak
-> day_101_morning_briefing


// ============================================================================
// Day 101 · 周三 · ★ 晨会高峰 — David quiet sign 2 verbatim "好了 David 我明白了" ★
// ============================================================================

= day_101_morning_briefing
# scene: meeting_room
# time: 9:25
# weather: cleared
# speaker: protagonist

周三。晨会日。

# scene: meeting_room
# time: 9:25
# npc: david_with_planner_5_sticky
# npc: lao_zhou_in_back

9:25 到会议室。

David 笔记本贴 5 张便利贴 (本周新增"客户对接 PPT")。

老周后排, 中间那杯茶。

9:32 王总监推门。

* [开始今日]
    -> day_101_event_1_morning_meeting_158


= day_101_event_1_morning_meeting_158
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium
# speaker: wang_director

王总监打开 PPT。今天封面 "**S4 第 3 周 + Q1 closeout review**"。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"我们这个团队啊, 是有未来的。"

# speaker: protagonist

baseline。

# speaker: wang_director
王总监: "Q1 closeout 这周 — 大家 deliverable 整体进度?"

# speaker: david
David **抢话** — 他这次 pre-loaded:

# speaker: david
"王总, 我**主动报一下** —"

# speaker: david
"**上周 KPI 完成 158%。**"

# speaker: david
"+ 我给的 PPT 客户反馈不错, 我打算这周给王总看一下完整 client scorecard。"

# speaker: protagonist

3 个 statement — 比 D87 报"152%" 多 2 句。他 escalate。

王总监 0.5 秒——

# speaker: wang_director
**"好了 David 我明白了。"**

8 个字。

# speaker: protagonist

verbatim — per outline §3.1 quiet sign 2 trigger。

# speaker: david
David **0.3 秒愣住**——

# speaker: david
他笑了一下: "嗯, 那我先说到这。"

# speaker: protagonist

整个晨会 0.5 秒 awkward。

_他被打断。_

_S1-S3 王总监对 David 用"嗯" 给他下台阶。_

_S4 D101 他第一次**公开打断**——这是 visible signal: 王总监对 David 厌烦升级到 cut off。_

_David 自己感觉到了 0.3 秒 — 他 0.3 秒愣。_

_但他**马上**笑了一下"嗯, 那我先说到这"——他在 cover, 在 reset。_

_他在演 "我没事" 给会议室看。_

_但他自己心里 register 了。_

_David quiet sign 2 — visible 在会议室所有人面前。_

_老周喝茶。_

_我看着没说话。_

_笑天 → David 关系: 我 register 这是 David 失态的开始。_

# speaker: wang_director
王总监换 PPT 下一张:

# speaker: wang_director
"Q1 closeout 周五 deadline。下周 Q2 第 1 周开始。"

# speaker: wang_director
"散会。"

7 分钟。

// hidden flag: 王总监 D101 verbatim "好了 David 我明白了" — David quiet sign 2 visible

~ check_state_after_choice()
-> day_101_event_2_lin_jie_or_no


// ----------------------------------------------------------------------------
// Event 101.2 · 路径 A 茶水间偶遇林姐 (0 句话, per Q6 strict)
// ----------------------------------------------------------------------------

= day_101_event_2_lin_jie_or_no
# scene: workstation_or_break_room
# time: 14:00

{cumulative_hero_count >= 5 and lisa_score >= 25:
    -> day_101_lin_jie_passes
    - else:
    -> day_101_no_lin_jie
}


= day_101_lin_jie_passes
# scene: break_room_with_lin_jie
# time: 14:00
# npc: lin_jie_at_water_dispenser
# speaker: protagonist

14:00。你去茶水间倒水。

# speaker: protagonist

茶水间——

林姐**也在**。

她**穿黑色西装外套 + 运动鞋** (她标准 visual)。

她拿一个杯子 — 她**也在倒水**。

她看到你——

# speaker: protagonist

她**点头**。

# speaker: protagonist

_她没说话。_

_她不说"笑天哦, 上次客户成功部那边项目还行吗"。_

_她不说"Lisa 在我们这边表现挺好"。_

_她什么都没说。_

_她**点头**。_

她拿了水。

她转身离开茶水间——

她走到门口, **0.3 秒**——

她**看了笑天工位方向**。

不是看笑天本人 — 笑天就在她 1 米开外。

她看的是**笑天工位 + 张磊新工位** — 那个 area 整体。

# speaker: protagonist

_她经过这边。但她不来这边。_

_S3 finale 她 0.3 秒看笑天 — series 第 1 次。_

_S4 D101 她点头 + 0.3 秒看工位方向 — 第 2 次 visual 接触, 仍 0 句话。_

_per npcs.md §10 林姐对笑天 0 主动 dialog 跨整 series._

_她 know 笑天最近 deliverable 紧 — 信息从王总监 / Lisa 那里传到她 (她跟 Lisa 一起做 Q1 复盘 — Lisa D99 微信提到了)。_

_她**有信息**, 但她**没行动**。_

_因为她 budget 是 0 (she doesn't extend to me)._

_这是 Pillar 4 极致 evidence: 另一种活法存在 — 林姐部门更 sustainable, 但**她不要笑天**。_

_我看着她离开 — 我感觉 5 米的距离就是 5 个 universe 的距离。_

林姐 walking out。

// hidden flag: 林姐 D101 茶水间偶遇 — 点头 + 0.3 秒看工位方向 + 0 句话

~ check_state_after_choice()
-> day_101_after_work


= day_101_no_lin_jie
# speaker: protagonist
14:00 standard 工位。林姐 S4 不出场 (路径 B-E)。

~ check_state_after_choice()
-> day_101_after_work


= day_101_after_work
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
-> day_101_daily_recap


= day_101_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today (D101):_

_  - ★ 晨会 David 报 "158%" + client scorecard, 王总监 verbatim "**好了 David 我明白了**" (David quiet sign 2 visible) ★_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - ★ 路径 A: 林姐茶水间偶遇 — 点头 + 0.3 秒看工位方向 + 0 句话 (Pillar 4 极致) ★_
}

# pagebreak
-> day_102_morning_briefing


// ============================================================================
// Day 102 · 周四 · ★ 王总监独立办公室打高尔夫 (puppet form 4) + Zoe 季度评估 ★
// ============================================================================

= day_102_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周四。

# scene: office_workstation
# time: 9:11

9:11 到公司。

* [开始今日]
    -> day_102_event_1_zoe_quarter_feedback


// ----------------------------------------------------------------------------
// Event 102.1 · ★ E15 Decision 2: Zoe 季度协作反馈 ★
// ----------------------------------------------------------------------------

= day_102_event_1_zoe_quarter_feedback
# scene: workstation_with_zoe_arriving
# time: 14:30
# npc: zoe_in_black_jacket_with_clipboard
# speaker: zoe

14:30。

Zoe 路过笑天工位。

# speaker: zoe
"陈笑天先生, 下周我们这边要做季度协作反馈, 您方便的话 —"

# speaker: protagonist

_S3 D72 她做 monthly 月度面谈反馈 — 那是**协作反馈**第一次出现。_

_S4 D102 季度协作反馈 — Q1 closeout 配套流程。_

_路径 A 玩家此选 hidden 影响: "协作反馈" 是 promotion_candidate_count 累积 source 之一 (per outline §3.4)_

* [好的]
    # speaker: protagonist
    你: "好的。"
    # speaker: zoe
    Zoe: "嗯, 我下周一发邮件给您, 您回复就行。"
    {cumulative_hero_count >= 5 and lisa_score >= 25:
        ~ lisa_zoe_feedback_positive = true   // S3 hero flag re-trigger / S4 confirm
    }
    ~ zoe_score = zoe_score + 1

* [我看下排期]
    # speaker: protagonist
    你: "我看下排期。"
    # speaker: zoe
    Zoe: "好的, 您方便就行。"
    ~ zoe_score = zoe_score + 0

* [上次月度面谈我已经说过了]
    # speaker: protagonist
    你: "上次月度面谈我已经说过了。"
    # speaker: zoe
    Zoe 0.5 秒。
    # speaker: zoe
    "嗯。这次是季度 review — Q1 closeout 全员都做。"
    # speaker: protagonist
    你: "好。"
    ~ zoe_score = zoe_score - 1

- _logged。_

~ check_state_after_choice()
-> day_102_event_2_wang_golf


// ----------------------------------------------------------------------------
// Event 102.2 · ★ 王总监独立办公室打高尔夫 (puppet form 4) ★
// ----------------------------------------------------------------------------

= day_102_event_2_wang_golf
# scene: office_after_hours_corridor
# time: 19:30
# speaker: protagonist

如果你今天申报加班——

~ state = state - 10
~ kpi = kpi + 5
~ effort_overage = effort_overage + 1

19:30。大部分人都走了。

你去 16 楼茶水间接水。

回来路上经过王总监独立办公室——

门关着。

但**门缝下面有光**——

你听到——

**啪。**

# speaker: protagonist

一个**软的、闷的**击球声。

不是键盘。不是电话。

是**高尔夫球**。

接着——

**啪。**

第 2 下。

接着——

**啪。**

第 3 下。

# speaker: protagonist

你停下来 5 秒。

你听到 — 王总监**没接电话**, **没敲键盘**, **没看 PPT**。

他在**地毯上推杆**。

3 个**啪**。

_他在玩。_

_S2 E7 D45 笑天加班 19:30 看王总监独立办公室门关 + 灯亮 — puppet form 1 (他自己也加班)。_

_S3 E11 D74 王总监打电话"你跟 Zoe 说一下吧, 下周三签字" — puppet form 2 (执行命令)。_

_S4 D102 王总监打高尔夫 — puppet form 3。_

_他从"加班" → "执行命令" → "玩"。他的焦虑形态在**变形** — 从 push 自己 to push 别人 to escape。_

_他自己也撑不住了。_

_他在公司里玩高尔夫推杆 — 他在 escape, 但他还在**公司**escape。_

_他无处可去。_

_他比 David 还可怜。_

_至少 David 撑到 finale 摔保温杯。王总监连 finale 的 visible meltdown 都不会有 — 他到 S9 finale 被换走的那天, 还会笑笑跟笑天"小陈啊…我可能要去其他部门 take 一下新方向"。_

_他到走的那天还会演。_

你**赶紧走开**——你不能让他知道你听到了。

// hidden flag: 王总监 D102 19:30 独立办公室打高尔夫 (puppet form 4 / S2-S4 form 1→2→3 递进)

~ check_state_after_choice()
-> day_102_after_work


= day_102_after_work
# scene: workstation_evening
# time: 19:35

19:35。你出公司。

* [自己回家]
    ~ state = state + 0

~ check_state_after_choice()
# pagebreak
-> day_102_daily_recap


= day_102_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today (D102):_

_  - ★ E15 Decision 2: Zoe 季度协作反馈 (3 选 1) — 路径 A 玩家 promotion 隐藏 source ★_

_  - ★★★ 19:30 王总监独立办公室**打高尔夫** (puppet form 4: S2 灯亮 / S3 打电话 / S4 打高尔夫 递进) ★★★_

_  - 笑天意识 王总监 escape 到公司里 — 他无处可去_

# pagebreak
-> day_103_morning_briefing


// ============================================================================
// Day 103 · 周五 · weekly_recap + David 朋友圈仍 0 条 (Day 14 累积)
// ============================================================================

= day_103_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared
# prop: fruit_bowl_apple
# speaker: protagonist

周五。

9:08 到公司。Vivian standard "嗨～来啦～"。

水果盘**仍是苹果**——苹果周第 15 周。

~ fruit_bowl = "apple"

# speaker: protagonist

_老板昨晚跟投资人吃饭后 — Vivian 周二预测"水果盘可能换草莓"——但今天**仍 apple**。_

_老板要么没融到, 要么融到但还没释放 signal。_

* [开始今日]
    -> day_103_event_1_weekly_recap


= day_103_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay
# speaker: protagonist

16:50。HR 系统周报浮层。

浮层底部: "**本月度 KPI 还有 2 天 (周日 4/30 推送月末通报 + S4 finale 5 路径)**"。

_2 天后 KPI Review。_

_4 月底。_

~ check_state_after_choice()
-> day_103_event_2_david_circle_still_zero


= day_103_event_2_david_circle_still_zero
# scene: workstation_phone_check
# time: 17:00
# diegetic_ui: phone_wechat_moments
# speaker: protagonist

17:00。你刷朋友圈。

# speaker: david

David 朋友圈最新一条仍是 D85 周六 "反思 / 复盘 / 充电"。

整 14 天 0 条。

_S2 D29 起每周 5 条 (累积 ~16 周 = 80 条)。_

_S4 D85 后 0 条 — 14 天 0 条。_

_David S4 quiet sign 1 + 2 — 朋友圈 silence 升级到 visible 14 天。_

_他的 spinning ceiling 已 reach。 0 条之后, 他不会再 spike up。_

_S6 finale 他朋友圈最后一条会是"开启人生新篇章"。 (per series-structure §3 David 长弧光) _

_S4 D103 我不知道他 S6 finale。_

_我只知道他 14 天 0 条朋友圈。_

_他 spinning 0 条的状态比 spinning 5 条的状态扎心。_

_因为 spinning 5 条有 self-deception 在 — 他相信自己在精进。_

_spinning 0 条 — self-deception machinery broken。_

_他 reach 自己的 ceiling 了。_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # diegetic_ui: phone_wechat_message
    # speaker: lisa

    Lisa 微信 1 条:

    # speaker: lisa
    "周五加油。"

    # speaker: protagonist
    你: "嗯。你呢?"

    # speaker: lisa
    Lisa: "新部门 Q1 复盘下周一 review。我准备好了。"

    # speaker: lisa
    "嗯, 跟林姐 review 之后我应该就 Q2 starting 自己 lead 1 个 sub-project。"

    # speaker: protagonist
    你: "好。"

    _4 句模式 closed。_

    _Lisa "Q2 starting 自己 lead 1 个 sub-project" — 她在新部门 promotion track。_

    _我在 product team Q2 starting +10% threshold。_

    _Pillar 4 ironic mirror — 她路径 A 救成了 = 她在新部门 promote。我路径 A 救她 = 我下月 +10% (still anti-Pillar 1)。_

    ~ lisa_score = lisa_score + 1
}

~ check_state_after_choice()
-> day_103_after_work


= day_103_after_work
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
-> day_103_daily_recap


= day_103_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_本月度 KPI 还有 2 天_

_关键时刻 today:_

_  - HR 浮层 + S4 finale setup_

_  - **David 朋友圈 14 天 0 条** (spinning ceiling reach — self-deception machinery broken)_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 路径 A: Lisa 微信"Q2 starting 自己 lead sub-project" — Pillar 4 ironic mirror (她升, 你 +10% threshold)_
}

# pagebreak
-> day_104_weekend_morning


// ============================================================================
// Day 104 · 周六 · 周末
// ============================================================================

= day_104_weekend_morning
# scene: bedroom
# time: 12:00
# music: weekend_silence
# speaker: protagonist

你睡到 12:00 醒。

# diegetic_ui: phone_wechat_moments

朋友圈:

# speaker: david
David 仍 0 条。

11:34 → 12:34。点外卖 35 元。
~ money = money - 35

* [开始今日]
    -> day_104_event_1_afternoon


= day_104_event_1_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence
# speaker: protagonist

下午 2 点。你在床上。

你打开购物车 — 浅色衬衫**仍**在。¥259。

_19 周没买。_

你又躺了 30 分钟。

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_104_daily_recap


= day_104_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# speaker: protagonist

_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_

_  - 12:00 起床_

_  - David 朋友圈仍 0 条 (累积 15 天)_

# pagebreak
-> day_105_weekend_morning


// ============================================================================
// Day 105 · 周日 · 妈妈"那个谁的儿子相亲" + cliffhanger to E16
// ============================================================================

= day_105_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet
# speaker: protagonist

周日。

你 8:23 醒。

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_105_event_1_mom_video


= day_105_event_1_mom_video
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen
# speaker: mama

屏幕里是妈妈。

# speaker: mama
妈妈: "**天天, 吃了吗?**"

# speaker: protagonist
你: "吃了。"

# speaker: mama
妈妈: "**那个谁的儿子最近回来相亲了。**"

# speaker: protagonist

standard S3 callback 模式。

* [嗯]
    # speaker: mama
    妈妈: "嗯。" 她也"嗯"。
    ~ mom_score = mom_score + 0

* [我也快了]
    # speaker: mama
    妈妈: "好好好, 妈等你。"
    # speaker: mama
    "妈不催你。"
    _她"不催"在催。_
    ~ mom_score = mom_score + 0

* [转移话题]
    # speaker: protagonist
    你: "妈, 你身体怎么样?"
    # speaker: mama
    妈妈: "好多了。"
    ~ mom_score = mom_score + 1

- _logged。_

视频 6 分钟挂。

~ check_state_after_choice()
-> day_105_event_2_evening_cliffhanger


= day_105_event_2_evening_cliffhanger
# scene: home_evening
# time: 21:00
# diegetic_ui: phone_wechat_moments
# speaker: protagonist

21:00。你刷朋友圈。

# speaker: david

David 朋友圈仍 0 条。**整 16 天**。

_他从 spinning ceiling reach 到 0 条 — 16 天 silence。_

_他的"开启人生新篇章" 该提前了。_

_S6 finale David 离职朋友圈 — 那是 ironic foreshadow。_

_但 S4 D105 我不知道 S6。_

_我只知道他 16 天 0 条。_

_明天 KPI Review。_

_明天 S4 finale。_

_明天他可能继续 0 条, 也可能 break silence。_

_我赌他继续 0 条。_

_他的 spinning machinery broken。_

# pagebreak
-> day_105_daily_recap


= day_105_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# speaker: protagonist

_今日 状态: {state}/100_

_关键时刻 today (E15 末):_

_  - 8:30 妈妈"那个谁的儿子相亲" standard callback_

_  - 21:00 David 朋友圈仍 0 条 (累积 16 天 — S6 finale 离职 ironic foreshadow)_

_NPC scores 末:_

_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / 妈妈 {mom_score}_

_下周一开始: 第 16 周 — Season Finale 「保温杯」(David 摔保温杯 + 5 路径 finale)_

-> END

// ============================================================================
// EOF episode-15.ink
// ============================================================================
