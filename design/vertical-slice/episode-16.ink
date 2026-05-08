// ============================================================================
// Episode 16 · Week 16 · 「保温杯」(Season 4 Finale)
// ============================================================================
//
// Status: 第 1 版 (S4 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S4 Round 1)
// Last Updated: 2026-05-07
//
// 配套 reference: season-4-arc.md §5 + §6 + round-1-reply.md
//
// 设计目标 (摘要):
//   1. ★ S4 finale — David 第一次失态 (quiet sign 3+4 = 迟到 + 不举手 + 摔保温杯) ★
//   2. ★ 食堂阿姨 verbatim "今天早" + 笑天 "嗯, 今天早" (series 内她唯一 visible recognition) ★
//   3. ★ KPI Review 5 路径 router + 路径 A "高潜力人才储备池" backdoor ★
//   4. promotion_candidate_count += 1 if 月末 KPI ≥ 150 (per Q1 reply, 不是 130)
//   5. ★ 妈妈 verbatim "我下个月想去你那看看你" (S2 finale callback, spiral pattern S4 起步) ★
//   6. Vivian 草莓周 (D 轮过会 = ironic mirror)
//   7. 4:6 笑泪反转
//   8. Series Cliffhanger 至 S5 (5 路径不同)
//
// Verbatim 必保:
//   - 食堂阿姨 D106 "**今天早**" + 笑天 "**嗯, 今天早**"
//   - 王总监 (路径 A) D112 "**你做得不错。下个月再看看**"
//   - KPI Review 浮层 (路径 A) "**您本月持续表现稳定。公司认可您的团队协作度。下月将给予您更高的责任。**"
//   - 季度协作反馈附件 "**陈笑天同志在 Q1 期间表现稳定，与同事协作度高，建议进入下季度高潜力人才储备池。**"
//   - 妈妈 D112 "**我下个月想去你那看看你**"
//
// 红线:
//   - David 不能 S4 燃尽 (S6 finale)
//   - 玩家不能"救" David — 路径 C 帮 David 让他撑得更久 = 撑得更崩 (anti-Pillar 1)
//   - 路径 A 不能给 happy ending UI / promotion celebration
//   - 老周 0 dialog
//   - 林姐 E16 不出场 (E15 唯一 路径 A 茶水间)
//   - 妈妈不 expose 爸爸 emotional anchor
//
// ============================================================================

INCLUDE episode-1.ink

-> episode_16


=== episode_16 ===
# scene: home
# time: monday_morning_week_16
# pagebreak

~ cumulative_hero_count = lisa_helped_pps + lisa_helped_after_hr + lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive + lisa_referred_external

-> day_106_morning_briefing


// ============================================================================
// Day 106 · 周一 · ★ Vivian 草莓周 + David 迟到 + 食堂阿姨 verbatim "今天早" ★
// ============================================================================

= day_106_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared
# speaker: protagonist

闹钟响 1 次。

_S4 第 4 周。Finale 周。_

_周日 4/30 KPI Review + S4 finale 5 路径揭晓。_

_今天周一 4 月底。_

_David 朋友圈累积 16 天 0 条。他撑不住了。但他可能还没意识到。_

# scene: subway_carriage
# time: 8:30
# speaker: protagonist

地铁。今天人正常。

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception

9:14 到公司。

# speaker: vivian
Vivian: "嗨～来啦～"

# speaker: vivian
她**笑得露齿**。

# prop: fruit_bowl_strawberry

水果盘**草莓**。

~ fruit_bowl = "strawberry"

# speaker: vivian
Vivian: "嗨～你看到了吗。**草莓哦**。"

# speaker: vivian
她压低声音: "**昨天 D 轮过会了**。"

# speaker: protagonist

_15 周连续苹果之后, 今天草莓。_

_S1 草莓周是老板演融资 (per S2 D29 Vivian C Vulnerability)。_

_S4 D106 草莓周是真融资过会。_

_老板心情好 = 草莓 sticker。_

_我心情**也是草莓**? 不是。我下周 KPI Review threshold +N% 看路径。_

_Pillar 4 ironic mirror — 草莓周 (老板 OK) vs 季度评估周 (David 失态 + 笑天 KPI Review) 同周触发。_

_他高兴他的, 我们扎我们的。_

# prop: poster_q1_review
她工位贴新海报: "**季度协作反馈截止 4/30**"。

* [开始今日]
    -> day_106_event_1_david_late


// ----------------------------------------------------------------------------
// Event 106.1 · ★ David 迟到 8 分钟 (quiet sign 3) ★ · 9:38
// ----------------------------------------------------------------------------

= day_106_event_1_david_late
# scene: workstation_with_david_arriving
# time: 9:38
# npc: david_arriving_late_first_time
# speaker: protagonist

9:30 — David **没在工位**。

9:35 — 仍空。

9:38 — David 走进来。

他**穿衬衫但扣子没扣全**——他平时衬衫不挽袖子但扣子全扣。今天最上面 2 颗没扣。

他**没看任何人**——他直接坐到工位。

他打开电脑, 用 30 秒登录。

他喝了一口保温杯里的茶——保温杯出现了 (他周末换回保温杯, S3 末他用过一次性杯子)。

# speaker: protagonist

_他迟到 8 分钟。_

_他 6 个月没迟到过。_

_S2 起他 8:30 到 baseline。S4 D85 8:30。S4 D99 8:00。S4 D106 9:38 — 比 D99 晚 1 小时 38 分钟。_

_他 spiral up 11 周后, 第一次 spiral down。_

_quiet sign 3 起步。_

_王总监经过工位区——他**没 cue David**。_

_王总监**也 register 了**——他 know David 迟到。但他**不点破**。_

_他给 David 留 face。_

_或者他对 David 已经 disengage 到不值得 cue。_

_第 2 种 reading 更对。_

_S2 D38 王总监对 Lisa "加把劲" — push。_
_S2 D52 不再 push (backstage 减压)。_
_S3 D66 完全 disengage Lisa (PPT review 直接 skip)。_

_S4 王总监对 David trajectory mirror — D101 公开打断 → D106 disengage。_

_他不再 push David。_

// hidden flag: David D106 迟到 8 分钟 — quiet sign 3 visible

~ check_state_after_choice()
-> day_106_event_2_canteen_recognition


// ----------------------------------------------------------------------------
// Event 106.2 · ★ 食堂阿姨 verbatim "今天早" ★ · 12:30
// ----------------------------------------------------------------------------

= day_106_event_2_canteen_recognition
# scene: canteen_with_food_court_auntie
# time: 12:30
# npc: food_court_auntie_looking_up
# speaker: protagonist

12:30。你去食堂吃饭。

你 12:00 来过 — 周一 + 周三 你固定去食堂 (不是周五, 周五你回家途中买煎饼)。

今天周一你 12:30 — 比平时晚 30 分钟。

排队取餐。前面 3 个人。

你点 — 西红柿炒蛋 + 米饭 (你每次的固定)。

# speaker: food_court_auntie

食堂阿姨打饭。

她**抬头看了你 0.5 秒**。

# speaker: protagonist

_她从来不抬头。_

_S1-S3 她不抬头, 不说话, 给我多打半勺西红柿炒蛋。_

_S4 D106 她抬头 0.5 秒看我。_

她**多打了一勺豆腐**——比平时多。

# speaker: food_court_auntie

她说: "**今天早。**"

# speaker: protagonist

3 个字。

# speaker: protagonist
你: "**嗯, 今天早。**"

# speaker: protagonist

她**没说**别的。

她笑了一下——0.3 秒——她转向下一个员工。

_她说"今天早"。_

_我 12:30 来比平时 12:00 晚 — 但她说"今天早"。_

_她不知道我平时几点来。或者她知道但她说反话 — 她在 reframe my late as early。_

_不管怎样, 她 register 了我。_

_她不知道我名字。但她记得"每周一 + 每周三都来 + 总点西红柿炒蛋的"。_

_这是 series 内她**唯一**一次 visible recognition。_

_她不是李阿姨 (silent witness 通过多拖 1 遍)。_

_她不是老周 (silent witness 通过 0.5 秒慢)。_

_她是**recognition through quiet generosity** — 多打一勺豆腐 + 3 个字 + 0.3 秒笑。_

_她比李阿姨 + 老周更直接。_

_她也是 silent witness 第 4 个。_

_我不知道她为什么今天 break silence。_

_可能她想我下班别再加班。_

_可能她想我吃饱。_

_可能她单纯多打了一勺。_

_3 种 reading 都对。_

// hidden flag: 食堂阿姨 D106 verbatim "今天早" — series 内唯一 visible recognition

~ check_state_after_choice()
-> day_106_after_work


= day_106_after_work
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
-> day_106_daily_recap


= day_106_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today (D106 finale week 周一):_

_  - Vivian 水果盘**草莓** (D 轮过会 — Pillar 4 ironic mirror, 老板 OK + 笑天/David 扎)_

_  - ★ David 迟到 8 分钟 (quiet sign 3 起步) — 王总监 disengage 不 cue ★_

_  - ★ 食堂阿姨 verbatim "今天早" + 笑天 "嗨, 今天早" — series 内她唯一 visible recognition ★_

# pagebreak
-> day_107_morning_briefing


// ============================================================================
// Day 107 · 周二 · David 周报敷衍 + 没自我激励
// ============================================================================

= day_107_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周二。

# scene: office_workstation
# time: 9:11

9:11 到公司。

# npc: david_at_desk_dispirited
# speaker: protagonist

David 在工位 (今天 9:00 准时, 不再迟到)。

但他**没在敲键盘**——他在**滑手机**。

S2-S3 他每天 9:11 之前已经在工位 typing 30 分钟。

S4 D107 他 9:11 在滑手机。

_他还在公司, 但他不"做事"。_

_他在 going through motions。_

* [开始今日]
    -> day_107_event_1_david_no_self_motivation


= day_107_event_1_david_no_self_motivation
# scene: break_room_doorway_quiet
# time: 14:30
# npc: david_at_water_cooler
# speaker: protagonist

14:30。你去茶水间接水。

David **也在**——他在喝水。

你看了一眼——

# speaker: protagonist

_他平时**自言自语**——"加油 David" / "下周客户对接" / "Q2 OKR" / etc。S1-S3 他每天 14:00-15:00 茶水间必有 1 次自我激励, 哪怕只是 muttering。_

_今天 D107 他**没自言自语**。_

_他喝水, 沉默 5 秒, 走回工位。_

_S2 D40 他第 1 次不耐烦 IT 小马时还有 PUA 自语"加把劲" (per outline, 但 Implicit)。_

_S3 D66 他第 2 次 reframe "要再问一下吗" 那时仍有 internal mantra。_

_S4 D106 他第 3 次直接 frustration "什么时候修好啊"——这是他 PUA 自语停的那 1 秒。_

_今天 D107 他完全停了 — 茶水间 5 秒沉默。_

_quiet sign 4 prelude。_

# speaker: protagonist

_他的 self-deception machinery — fully broken。_

// hidden flag: David D107 茶水间没自我激励 (S1-S3 每天必有, S4 D107 first absence)

~ check_state_after_choice()
-> day_107_after_work


= day_107_after_work
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
-> day_107_daily_recap


= day_107_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

_  - David 9:11 在工位但**滑手机** — 不再 typing baseline_

_  - ★ David 茶水间**没自我激励**(S1-S3 每天必有) — quiet sign 4 prelude ★_

_  - 周报敷衍 (笑天看过 David 周报截图通过 group, 字数减半)_

# pagebreak
-> day_108_morning_briefing


// ============================================================================
// Day 108 · 周三 · ★ 晨会 David 不举手 (quiet sign 4) ★
// ============================================================================

= day_108_morning_briefing
# scene: meeting_room
# time: 9:25
# weather: cleared
# speaker: protagonist

周三。晨会日。

# scene: meeting_room
# time: 9:25
# npc: david_with_minimal_planner
# npc: lao_zhou_in_back

9:25 到会议室。

David 笔记本——

只贴 **1 张便利贴** (上周 5 张 / 这周 1 张)。便利贴上写: "**Q2 OKR**"——空 4 个字, 没有具体数字 / item / deadline。

老周后排, 中间那杯茶。

9:32 王总监推门。

* [开始今日]
    -> day_108_event_1_morning_meeting_no_hand_up


= day_108_event_1_morning_meeting_no_hand_up
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium
# speaker: wang_director

王总监打开 PPT。今天封面 "**Q1 closeout 总结**"。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"我们这个团队啊, **Q1 大家辛苦**。"

# speaker: protagonist

PUA 模板 — "辛苦" 替代 "凝聚力"。

# speaker: wang_director
王总监: "**David 你这边怎么样?**"

# speaker: protagonist

_他 cue David。_

_S1-S3 standard pattern: 王总监 cue David → David 立即抢话 + spike 报告。_

_S4 D108 — 王总监 cue, David **0.5 秒 sleep 0.5 秒 wake up**。_

# speaker: david
David: "我..."

0.5 秒。

# speaker: david
"这周还在补上周的。"

# speaker: protagonist

8 个字。

David **没主动报数字**。

David **没主动 spike**。

David **没举手**。

他直接 deflect。

王总监**没说什么**——他点头, 换 PPT 下一张。

# speaker: wang_director
王总监: "嗯。Q2 第 1 周 deliverable 我下午发邮件。"

# speaker: wang_director
"散会。"

6 分钟。

# speaker: protagonist

_quiet sign 4 visible。_

_他终于不举手。_

_S2-S3 他每次晨会**主动**报告 + 抢话 + spike 数字。S4 D108 第 1 次他**deflect**。_

_他在收 — 不再 try。_

_王总监 register 了 — 但他没 push。_

_他对 David disengage 到 fully accept David's diminishing。_

_他可能在等 David 自己 walk。_

_或者他在 prep S6 finale David 离职 announcement (per series macro, 我不知道 S6)。_

_反正他现在不 push。_

老周喝茶。

我看着 David。

_他没看我。_

_他可能在想"什么时候能走"——但他不 ask 自己这个问题。_

_他 still 在 KPI 系统里 going through motions。_

_直到摔保温杯 (周日 12:00 那一刻, 但 D108 我不知道周日)。_

// hidden flag: David D108 晨会不举手 — quiet sign 4 visible

~ check_state_after_choice()
-> day_108_after_work


= day_108_after_work
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
-> day_108_daily_recap


= day_108_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

_  - ★ 晨会王总监 cue David — David **不举手 / 不 spike / 不主动报** (quiet sign 4 visible) ★_

_  - David 笔记本 1 张便利贴 (上周 5 张 / 这周 1 张, 内容空"Q2 OKR")_

_  - 王总监不再 push David — disengage 到 fully accept_

# pagebreak
-> day_109_morning_briefing


// ============================================================================
// Day 109 · 周四 · Lisa 微信(路径 A) "周日加油" / silence
// ============================================================================

= day_109_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周四。

# scene: office_workstation
# time: 9:11

9:11 到公司。

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # diegetic_ui: phone_wechat_message
    # speaker: lisa
    Lisa 微信:

    # speaker: lisa
    "笑天, 周日 KPI Review 加油。"

    # speaker: protagonist
    你: "嗯。你呢?"

    # speaker: lisa
    Lisa: "我们这边新部门 Q2 starting 下周。"

    # speaker: lisa
    "我可能要 lead 1 个 sub-project."

    # speaker: protagonist
    你: "好。"

    _4 句以内, 路径 A standard。_

    _她在新部门 lead sub-project — promotion track。_

    _我下周 +10% threshold (路径 A 假设)。_

    _Pillar 4 — 她升, 我处刑。_

    ~ lisa_score = lisa_score + 1
}

* [开始今日]
    -> day_109_event_1_workstation_quiet


= day_109_event_1_workstation_quiet
# scene: workstation_quiet_thursday
# time: 14:00
# speaker: protagonist

14:00。

David 在工位——他在敲键盘 (慢节奏)。

他改 PPT V1 (周日 KPI Review prep) — 但他**没改 V2**。

S1-S3 他 1 周内改 PPT 5-8 版。今天周四他还在 V1。

_他不再 stress test layouts。_

_他在 minimal mode。_

~ check_state_after_choice()
-> day_109_after_work


= day_109_after_work
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
-> day_109_daily_recap


= day_109_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 路径 A: Lisa 微信"周日 KPI Review 加油" + "Q2 starting 我可能 lead sub-project"_
}

_  - David 周四仍在 PPT V1 (S1-S3 他 1 周 5-8 版, S4 D109 仍 V1) — minimal mode_

# pagebreak
-> day_110_morning_briefing


// ============================================================================
// Day 110 · 周五 · weekly_recap + ★ Lisa 朋友圈 (路径 B "开启新阶段满 1 个月") ★
// ============================================================================

= day_110_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared
# prop: fruit_bowl_strawberry
# speaker: protagonist

周五。

9:08 到公司。

# speaker: vivian
Vivian: "嗨～来啦～"

水果盘**仍是草莓** — 4 月底 D 轮过会的庆祝持续。

~ fruit_bowl = "strawberry"

# speaker: protagonist

_老板心情好持续。_

_季度评估 deadline 4/30 周日 — 草莓周 vs 季度评估周同周触发, ironic mirror peak。_

* [开始今日]
    -> day_110_event_1_weekly_recap


= day_110_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay
# speaker: protagonist

16:50。HR 系统周报浮层。

浮层底部: "**本月度 KPI 还有 2 天 (周日 4/30 推送月末通报 + S4 finale)**"。

~ check_state_after_choice()
-> day_110_event_2_lisa_circle_path_b


= day_110_event_2_lisa_circle_path_b
# scene: workstation_phone_check
# time: 17:00
# diegetic_ui: phone_wechat_moments

{
    - cumulative_hero_count >= 3 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
        -> day_110_lisa_circle_b_visible
    - else:
        -> day_110_no_circle
}


= day_110_lisa_circle_b_visible
# diegetic_ui: phone_wechat_moments_lisa
# speaker: lisa

# speaker: lisa
Lisa 朋友圈新 1 条:

# speaker: lisa
"开启新阶段满 1 个月。"

配图: 她新公司楼下的咖啡店 — 比 D85 那张少 30 度阴, 这次阳光。

# speaker: protagonist

_她周日发的, 我周五看到 (她朋友圈不进我推送 priority, 我延迟 5 天看到)。_

_"满 1 个月" — 1 个月前她**离开**。_

_她在新公司 1 个月。_

_她朋友圈定期 anchor — 她在 build 新身份, 通过 milestone tagging。_

# diegetic_ui: phone_screenshot_save_action

你**截图保存**。

_第 2 次保存 Lisa 朋友圈 (D95 第 1 次)。_

_D95 + D110 — 这是路径 B 玩家的 ritual: 我截图保存 Lisa 在新公司的 milestone。_

_我不发她。_

_我只是 archive。_

// hidden flag: 笑天 D110 第 2 次截图保存 Lisa 朋友圈

~ check_state_after_choice()
-> day_110_after_work


= day_110_no_circle
# speaker: protagonist
{cumulative_hero_count >= 5 and lisa_score >= 25:
    Lisa 微信仍是 D109 那 4 句模式 closed。她周五 D110 没 follow up。
}
{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 3):
    Lisa 仍 silence。屏蔽态 4 周累积。
}
{cumulative_hero_count == 0:
    Lisa silence。整 S4 0 接触。
}

~ check_state_after_choice()
-> day_110_after_work


= day_110_after_work
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
-> day_110_daily_recap


= day_110_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_本月度 KPI 还有 2 天_

_关键时刻 today:_

{cumulative_hero_count >= 3 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
    _  - 路径 B: Lisa 朋友圈"**开启新阶段满 1 个月**" + 笑天**截图保存** (第 2 次)_
}

_  - HR 浮层 + S4 finale countdown 2 天_

# pagebreak
-> day_111_weekend_morning


// ============================================================================
// Day 111 · 周六 · 周末
// ============================================================================

= day_111_weekend_morning
# scene: bedroom
# time: 12:00
# music: weekend_silence
# speaker: protagonist

你睡到 12:00 醒。

# diegetic_ui: phone_wechat_moments

朋友圈:

# speaker: david
David 仍 0 条 (累积 22 天)。

11:34 → 12:34。点外卖 35 元。
~ money = money - 35

* [开始今日]
    -> day_111_event_1_afternoon


= day_111_event_1_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence
# speaker: protagonist

下午 2 点。你在床上。

你打开购物车——浅色衬衫**还在**。

_20 周。_

_明天 KPI Review。_

_我先睡。_

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_111_daily_recap


= day_111_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# speaker: protagonist

_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_

_  - 12:00 起床_

_  - David 朋友圈 0 条 (累积 22 天)_

# pagebreak
-> day_112_weekend_morning


// ============================================================================
// Day 112 · 周日 · ★★★ S4 FINALE ★★★
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈 verbatim "我下个月想去你那看看你" (S2 finale callback, spiral 起步)
//   - 9:30 KPI Review 浮层 + 5 路径 router (路径 A 含 promotion warning prelude)
//   - 11:00 路径 A 王总监单独 "你做得不错。下个月再看看" + Zoe 协作反馈附件
//   - 12:00 茶水间 David 摔保温杯 + 笑天 Decision (3 选 1)
//   - 18:00 5 路径 cliffhanger to S5

= day_112_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet
# speaker: protagonist

周日 4/30。

S4 finale 日。

你 8:23 醒。

_今天 9:30 KPI Review 浮层。12:00 茶水间。18:00 cliffhanger to S5。_

_我不知道哪条路径 — system 判。_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_112_event_1_mom_video_finale


// ----------------------------------------------------------------------------
// Event 112.1 · ★ 妈妈 verbatim "我下个月想去你那看看你" (S2 finale callback) ★
// ----------------------------------------------------------------------------

= day_112_event_1_mom_video_finale
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
妈妈: "**工资发了吗?**"

# speaker: protagonist
你: "发了。"

# speaker: mama
妈妈停了一下。她**眯眼**。

# speaker: mama
妈妈: "**我下个月想去你那看看你。**"

# speaker: protagonist

15 个字 verbatim。

_S2 finale D56 她**第一次**说"我下个月想去你那边看看你"。_

_S3 D63 她"我下个月可能不去了, 你姨家有事"——backtrack。_

_S4 D112 她又说"想去看看你"——**spiral 起步**。_

_她"想去-不去" 第一次 closed loop:_
_S2 想去 → S3 不去 → S4 想去_

_她在 oscillating。她每次 push 一档, 然后 backtrack, 然后再 push。_

_她不会真的来。或者她会, 但不是这个月。_

_她在 5 月 push, 6 月 backtrack, 7 月再 push, 8 月 backtrack, etc._

_这是 S5+ 的 spiral pattern 起步 (per outline §3.10)。_

_我会在 S5 / S6 / S7 / etc 看到她每隔 2-3 集说一次"想去"。_

_她每次都不来。_

_直到她真的来 — 那一刻是 series 后期的 visit event, 但 S4 我不知道。_

* [好啊妈]
    # speaker: protagonist
    你: "好啊妈, 你哪天?"
    # speaker: mama
    妈妈: "妈想想哈, 妈先看看高铁票。"
    _她说"先看看" — 她在 prep backtrack._
    ~ mom_score = mom_score + 5
    ~ mom_visit_pending = true

* [下个月不行妈我太忙了]
    # speaker: protagonist
    你: "下个月不行妈, 我太忙了。"
    # speaker: mama
    妈妈 0.5 秒。
    # speaker: mama
    "嗯, 那妈下下个月再说。"
    _她"下下个月再说" — 她已经 prep S5 finale 同样的 spiral._
    ~ mom_score = mom_score - 1
    ~ mom_visit_postponed = true

* [转移话题]
    # speaker: protagonist
    你: "妈, 你身体怎么样?"
    # speaker: mama
    妈妈: "好多了。"
    # speaker: mama
    "你 KPI 怎么样? 9:30 不是要看吗?"
    _她记得 9:30 — 她在跟踪我的 schedule._
    # speaker: protagonist
    你: "嗯, 9:30 看。"
    ~ mom_score = mom_score + 2

- _logged。_

# speaker: protagonist

视频 5 分钟 (比 S3 D84 短 1 分钟)。

她说"再见"挂掉。

_她记得 9:30 KPI Review。_

_她不知道反向 KPI。但她知道我每月这一天紧张。_

// hidden flag: 妈妈 D112 verbatim "我下个月想去你那看看你" — S4 spiral 起步 (S2 finale callback)

~ check_state_after_choice()
-> day_112_event_2_kpi_review


// ----------------------------------------------------------------------------
// Event 112.2 · ★★ 9:30 KPI Review 浮层 + 5 路径 router ★★
// ----------------------------------------------------------------------------

= day_112_event_2_kpi_review
# scene: home_phone_kpi_review
# time: 9:30
# diegetic_ui: phone_kpi_review_overlay
# speaker: protagonist

9:30。HR 系统浮层弹出。

~ cumulative_hero_count = lisa_helped_pps + lisa_helped_after_hr + lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive + lisa_referred_external

KPI Review 浮层 base layer:

- 本月 KPI 累积: {kpi}

- 出勤率: standard

- 主动产出条目: (取决于累积)

- 加班申报次数: {effort_overage}

- 病倒次数: {sick_count}

system 进入 router——

{
    - sick_count >= 4:
        # kpi_review_path_d_s4
        # pagebreak
        -> day_112_path_d_finale
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        # kpi_review_path_a_s4
        # pagebreak
        -> day_112_path_a_finale
    - cumulative_hero_count >= 3:
        # kpi_review_path_b_s4
        # pagebreak
        -> day_112_path_b_finale
    - cumulative_hero_count >= 1:
        # kpi_review_path_c_s4
        # pagebreak
        -> day_112_path_c_finale
    - else:
        # kpi_review_path_e_s4
        # pagebreak
        -> day_112_path_e_finale
}


// ----------------------------------------------------------------------------
// 路径 A — 持续高表现 + promotion warning prelude
// ----------------------------------------------------------------------------

= day_112_path_a_finale
# scene: home_path_a_morning_kpi
# time: 9:30
# speaker: protagonist

KPI Review 浮层路径 A specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}

· 系统评估您的付出度为: 稳定模式

· 下月阈值调整: 100 → **110** (+10%)

· 系统注释:
  "**您本月持续表现稳定。**"
  "**公司认可您的团队协作度。**"
  "**下月将给予您更高的责任。**"
  ——这是您的 reward。

· 季度协作反馈 (附件):
  "**陈笑天同志在 Q1 期间表现稳定，**"
  "**与同事协作度高，**"
  "**建议进入下季度高潜力人才储备池。**"

═══════════════════════════════════════════

# speaker: protagonist

_+10%。_

_3 句"您…公司…下月将…" 跟 S3 路径 A 文案**几乎一样**。_

_S3 路径 A "团队精神 / 更高的责任 / 关键交付"。_

_S4 路径 A "团队协作度 / 更高的责任 / 持续表现稳定"。_

_系统的 reward 模板**从未变过**——每个 milestone 都是同一句话。_

_anti-Pillar 1 累积升级。_

_+18% S3 → +10% S4 (S4 是 setup 不是 climax)。但**新增"季度协作反馈附件"** — 路径 A specific 显形。_

_附件文案——_

_"陈笑天同志在 Q1 期间表现稳定" — Q1 closeout 标准。_

_"与同事协作度高" — 我帮过 David PPT (D86) + 接 Zoe 协作反馈 (D102)。_

_"建议进入下季度高潜力人才储备池" — **关键 line**。_

_"高潜力人才储备池" — 这是 promotion warning 的**backdoor signal**。_

_HR 在内部 list 我作为 "高潜力人才储备池" 第 1 周——但我还不能 confirm 我被列入 promotion candidate。_

_attentive 玩家可以推断:_
_"高潜力人才储备池" → S5/S6/S7+ promotion 流程预热 → S10.X event_

_但今天 D112 我只是看到附件文案。我不能 confirm。我**应该 confirm**。_

# diegetic_ui: phone_kpi_review_attachment_view

_我 click 附件——它打开的是 PDF, 标题: "陈笑天 Q1 协作反馈"。_

_PDF 第 2 页底部小字: "本附件作为下季度高潜力人才储备评估依据。"_

_关键句。_

_我 register。_

# speaker: protagonist

_我下月 +10% threshold + 我被列入 high potential list。_

_这是 promotion track 起步。_

_我不知道 promotion = 处刑 (per S10.X)。_

_我会在 S5-S10 慢慢知道。_

_今天我只 register "高潜力人才储备池" 7 个字。_

_这 7 个字在我心里 stay 1 周, 然后我 forget — 但 system 不 forget。_

// promotion_candidate_count += 1 only if KPI 累积 ≥ 150 (per Q1 reply)

{kpi >= 150:
    ~ promotion_candidate_count = promotion_candidate_count + 1
    _我月末 KPI ≥ 150 — 系统 register 我作为 promotion candidate (counter += 1)._
- else:
    _我月末 KPI < 150 — 系统 register "高潜力" 但 counter 不 +1 (per Q1 reply 阈值)。_
}

~ check_state_after_choice()
-> day_112_path_a_wang_followup


= day_112_path_a_wang_followup
# scene: home_path_a_11h
# time: 11:00
# diegetic_ui: phone_wechat_message
# speaker: wang_director

11:00。微信 1 条。

# speaker: wang_director
王总监 (1v1):

# speaker: wang_director
"小笑啊。"

# speaker: wang_director
"陈天啊。"

# speaker: wang_director
"差不多差不多。"

# speaker: wang_director
"**你做得不错。下个月再看看。**"

# speaker: protagonist

12 个字 verbatim。

_这是 series-structure §4.5 Event S10.X promotion 警告 setup 的**预热 dialogue**。_

_他还**没**说"提你做主管"——那是 S10 才说。_

_他说"看看" — 他在 evaluate process。_

_我 register: 我在 promotion track。_

_我应该 happy 吗? Anti-Pillar 1 says no. 我下月 +10% + 我被 evaluate = 更累 + 更被监视。_

_但我 internal first reaction is "他终于 register 我了" — 我喜欢这种 visibility, 即使我 know it 是 trap。_

_这是 anti-Pillar 1 极致——你**第一次 visibly happy** 在 promotion track 起步, 而不是 in 普通月份。_

* [谢谢王总]
    # speaker: protagonist
    你回: "谢谢王总。"
    # speaker: wang_director
    王总监: "嗯。"
    ~ wang_score = wang_score + 1

* [嗯]
    # speaker: protagonist
    你回: "嗯。"
    # speaker: wang_director
    王总监: "好。"
    ~ wang_score = wang_score + 0

- _logged。_

~ check_state_after_choice()
-> day_112_path_a_zoe_email


= day_112_path_a_zoe_email
# scene: home_path_a_zoe_email
# time: 11:30
# diegetic_ui: phone_email_inbox
# speaker: zoe

11:30。邮件 1 条。

# speaker: zoe
Zoe (1v1 邮件):

# speaker: zoe
"陈笑天先生,"

# speaker: zoe
"本季度协作反馈整理好了 (附件)。"

# speaker: zoe
"您方便明天看一下，有问题随时联系。"

# speaker: zoe
"祝周末愉快。"

# speaker: zoe
"Zoe / HR"

# speaker: protagonist

附件就是 KPI Review 浮层那份附件 (Q1 协作反馈 PDF)。

她 1v1 给我发——这是 series 内 Zoe 第一次 1v1 给笑天发邮件。

S1-S3 她都是群消息 + 路过工位 + 偶尔 1v1 5 分钟面对面。

S4 D112 她 1v1 邮件 — formality 升级。

_我意识到这是某种"准 promotion 流程"。_

_她在 setup paper trail。_

_S5/S6/S7 她可能继续给我邮件 — 越来越正式 + paper trail 累积 → S10.X event。_

# speaker: protagonist

_我应该回复吗? 我应该 ack 收到吗?_

_我 0.5 秒 hover._

_然后我**没回**——我 forward 邮件到我个人 Gmail (备份 paper trail)。_

_我也在 setup 我自己的 paper trail。_

_HR vs me in paper trail war。_

// hidden flag: 路径 A finale - "高潜力人才储备池" backdoor + 王总监 verbatim 预热 + Zoe paper trail

~ check_state_after_choice()
-> day_112_path_a_canteen


= day_112_path_a_canteen
-> day_112_event_3_canteen_meltdown


// ----------------------------------------------------------------------------
// 路径 B — 救得不彻底
// ----------------------------------------------------------------------------

= day_112_path_b_finale
# scene: home_path_b_morning_kpi
# time: 9:30
# speaker: protagonist

KPI Review 浮层路径 B specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}

· 系统评估您的付出度为: 标准达标

· 下月阈值调整: 100 → **105** (+5%)

· 系统注释: "继续保持。"

═══════════════════════════════════════════

# speaker: protagonist

_+5%。Standard. 我不在"高潜力人才储备池"。_

_我帮了一些 hero behavior 但不够 5 个 flag。_

_Lisa 走了 — 我没 keep 住她。David 失态 — 我看着。_

_+5% 不算多, 不算少。_

~ check_state_after_choice()
-> day_112_event_3_canteen_meltdown


// ----------------------------------------------------------------------------
// 路径 C — 路径分裂 (帮 David 累积)
// ----------------------------------------------------------------------------

= day_112_path_c_finale
# scene: home_path_c_morning_kpi
# time: 9:30
# speaker: protagonist

KPI Review 浮层路径 C specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}

· 系统评估您的付出度为: 险过

· 下月阈值调整: 100 → **105** (+5%)

· 系统注释: "勉勉强强。"

═══════════════════════════════════════════

# speaker: protagonist

_+5%。_

_4 字"勉勉强强"——比路径 B "继续保持" 还短 1 字。_

_S3 路径 C 同样的"勉勉强强"。S4 路径 C 同样。_

_系统的"勉勉强强"模板从未变过。_

_我帮过 David 但他还是要崩。_

_anti-Pillar 1 — 你帮 David 反而让他撑得更久 = 撑得更崩。_

~ check_state_after_choice()
-> day_112_event_3_canteen_meltdown


// ----------------------------------------------------------------------------
// 路径 D — 装病 + 摸鱼累积 (sick_count >= 4)
// ----------------------------------------------------------------------------

= day_112_path_d_finale
# scene: home_path_d_morning_kpi
# time: 9:30
# speaker: protagonist

KPI Review 浮层路径 D specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}

· 系统评估您的付出度为: 装病摸鱼

· 下月阈值调整: 100 → **103** (+3%)

· 系统注释: "您看起来不太对。"

═══════════════════════════════════════════

# speaker: protagonist

_+3%。"您看起来不太对" — HR 委婉 medical leave 累积 cap warning。_

_S3 路径 D 同样的"您看起来不太对"。_

_我装病变成 David 真病的镜像。_

_S5 王总监可能 cue 我 "小笑啊你这病假怎么这么频繁"。_

# speaker: protagonist

_我今天周日仍然在床上 — 38.3 度退到 36.7 度 (S3 finale 路径 D 同 trajectory)。_

_我不去茶水间。_

_我看 KPI Review 浮层后 close phone。_

_我 12:00 不知道 David 摔保温杯。_

_周一回公司我可能从 Vivian 或同事处 indirectly 听到 — 可能不听到。_

# speaker: protagonist

_S5 第 1 集开局: 我装病 day 8 累积 — 王总监开始 cue 我 "小笑啊…陈天啊…你这病假怎么这么频繁啊"_

_我不知道 David 摔保温杯 — 跟 S3 路径 D 一样我不知道 Lisa 走 day。_

# pagebreak

-> day_112_finale_recap


// ----------------------------------------------------------------------------
// 路径 E — 全程冷处理 (cumulative_hero_count = 0)
// ----------------------------------------------------------------------------

= day_112_path_e_finale
# scene: home_path_e_morning_kpi
# time: 9:30
# speaker: protagonist

KPI Review 浮层路径 E specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}

· 系统评估您的付出度为: 全程摸鱼

· 下月阈值调整: 100 → **101** (+1%)

· 系统注释: ()

═══════════════════════════════════════════

# speaker: protagonist

_+1%。_

_系统注释空白——你最 invisible。_

_S3 路径 E 同样 +1% + 空白。_

_我 mute Lisa。我 mute David。我 mute 王总监 cue。我 mute 整个 office system。_

_我下月 +1% 是 reward 还是 punishment? Both. 我在 Pillar 3 极致 — invisible state。_

_我今天周日 12:00 不会路过茶水间 (路径 E 玩家直接回家)。_

_我不会知道 David 摔保温杯。_

_我 S5 第 1 集 standard - no cliffhanger 兑现 (per outline §6 路径 E)。_

# pagebreak

-> day_112_finale_recap


// ----------------------------------------------------------------------------
// 茶水间 David 摔保温杯 (路径 A/B/C 才路过, D/E 不路过)
// ----------------------------------------------------------------------------

= day_112_event_3_canteen_meltdown
# scene: corridor_passing_break_room
# time: 12:00
# speaker: protagonist

12:00。

你 KPI Review 浮层结束 (9:30) → 王总监微信 (路径 A 11:00) → Zoe 邮件 (路径 A 11:30) → 你 11:55 出门去公司收东西 (KPI Review 后惯例)。

公司大堂周日 12:00 没人。

你坐电梯 16 楼。

走廊空。

经过茶水间——

# scene: break_room_with_david_meltdown
# npc: david_at_coffee_machine_meltdown
# prop: broken_thermos_on_floor

David **站在咖啡机前**。

他**保温杯**——

地上是**他摔碎的保温杯**。

碎片散开 — 杯身玻璃 + 杯盖塑料 + 茶叶撒地。

# speaker: protagonist

他没说话。

他**蹲下捡碎片**。

他**没回头看你**——他不知道你来了。

# speaker: protagonist

_他周日 12:00 在公司茶水间。_

_他周日来——他妻子刚生孩子他不回家。_

_他**摔了保温杯**——quiet sign 4 visible。_

_整 S4 16 周累积:_
_  D85 baseline 抬高 (8:30 已到)_
_  D93 第 3 次不耐烦 IT (accept v4 告示)_
_  D101 晨会被王总监打断 "好了 David 我明白了"_
_  D106 迟到 8 分钟_
_  D107 茶水间没自我激励_
_  D108 晨会不举手_
_  D112 摔保温杯_

_他 spiral down 7 个 quiet sign 后 — 第 1 次 visible meltdown。_

_他没大喊, 没骂人, 没 punch wall。他**蹲下**捡碎片。_

_他在 contain meltdown, 即使 meltdown 已 happened。_

_S6 finale 他离职 — 他朋友圈"开启人生新篇章"。S4 D112 他**还没**到那个 line。_

_今天他还是要 clean up。_

# scene: break_room_li_ayi_far_corner
# npc: li_ayi_collecting_trash_far

# speaker: protagonist

_茶水间另一头 —_

_李阿姨在收垃圾。_

_她经过 David 时**速度变慢 0.5 秒**。_

_她看到。_

_她不 help — 她 know 这是公司的事, 不是清洁的事。_

_她不抬头。_

_她 silent witness 第 N 次 (S2 Lisa 走 / S3 finale Lisa 走 / S4 finale David 摔保温杯)。_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # scene: break_room_with_zhanglei_far
    # npc: zhanglei_at_far_corner_silent
    # speaker: protagonist

    _张磊也在茶水间另一边 (路径 A 玩家 only)。_

    _他刚到 16 楼 — 他周日加班 (他 S5 第 1 集开局会 PUA 起步, 但 D112 他还在 try learn from David)。_

    _他**看到 David 摔保温杯**。_

    _他**没动**。_

    _他在 register: "Q1 closeout 周末 David 崩了"。_

    _他 12 周后可能也会摔。_

    _他不知道。_
}

* [过去帮捡碎片]
    # speaker: protagonist
    你过去, 蹲下, 帮 David 捡。
    # speaker: david
    David 0.5 秒看你: "**谢谢。**"
    1 个字。
    # speaker: david
    然后他自动 reset, 用 S1 D1 那个开场白模式: "你周末过得怎样?"
    # speaker: protagonist
    你: "嗯, 还行。"
    # speaker: david
    David: "我啊, 我家娃晚上不睡。"
    # speaker: protagonist
    _他第一次跟我说他家娃 — 但他用 small talk 包装。_
    _他 contain 自己的 collapse。_
    ~ david_score = david_score + 3
    // hidden flag: helped_david_meltdown

* [没过去, 绕开茶水间]
    # speaker: protagonist
    你绕开茶水间, 走另一条路去自己工位。
    你**没让 David 看到你**。
    _他蹲下捡碎片 5 分钟。然后他端 1 杯一次性杯子的水回工位。_
    _他周日下午仍在 office。_
    ~ david_score = david_score + 0
    // hidden flag: witnessed_david_meltdown = true

* [假装没看见, 从茶水间另一边走]
    # speaker: protagonist
    你从茶水间另一边走, David 视野里只看到你的背影。
    _他可能没意识到你看到他。_
    _或者他知道。_
    ~ david_score = david_score - 2
    // hidden flag: avoided_david_meltdown = true

- _logged。_

# pagebreak
-> day_112_event_4_evening_cliffhanger


// ----------------------------------------------------------------------------
// Event 112.4 · ★ 18:00 series cliffhanger to S5 (5 路径) ★
// ----------------------------------------------------------------------------

= day_112_event_4_evening_cliffhanger
# scene: home_evening
# time: 18:00
# speaker: protagonist

18:00。你回家路上。

街上有点风。

_S4 finale 完。_

_今天我看到 David 摔保温杯。_

_我做了 3 选 1: A 帮捡 / B 绕开 / C 假装。_

_无论选什么, 他都还要继续上班 — 直到 S6 finale 他离职。_

_我下月 threshold +10% (路径 A) / +5% (路径 B/C) — anti-Pillar 1 standard。_

# diegetic_ui: phone_wechat_check
# speaker: protagonist

{
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        -> day_112_path_a_evening
    - cumulative_hero_count >= 3:
        -> day_112_path_b_evening
    - cumulative_hero_count >= 1:
        -> day_112_path_c_evening
    - else:
        -> day_112_path_e_evening_default
}


= day_112_path_a_evening
# diegetic_ui: phone_wechat_message
# speaker: lisa

# speaker: lisa
Lisa 微信 1 条:

# speaker: lisa
"清明假期顺利吗?"

# speaker: protagonist

_她还以为 cli明 是 1 周前的事 — 她记错了 (清明实际 D92 周一 ≈ 3 周前)。_

_她在新部门 1 个月, 她对 product team 时间感开始 drift。_

_她跟我"transactional friendly" — 但 friendliness 在 erode。_

_S5 / S6 她可能渐渐不发了。_

# speaker: protagonist
你: "顺利。"

# speaker: lisa
Lisa: "嗯。"

# speaker: protagonist

_4 句以内。_

_她 transition 完成。S5 第 1 集 (E17) 张磊 PUA 张磊起步——笑天意识自己的工位即将变成 David 的工位。_

# pagebreak
-> day_112_finale_recap


= day_112_path_b_evening
# diegetic_ui: phone_wechat_moments_lisa
# speaker: lisa

# speaker: lisa
Lisa 朋友圈 (你 D110 截图保存的 "开启新阶段满 1 个月" 仍是最新)。

她**没发新的**。

# speaker: protagonist

_她在新公司 1 个月 + 1 周 — 她下次 milestone 可能是"满 2 个月" / "Q2 开始"。_

_我会继续截图保存。_

_我在 archive Lisa 的新生活 trajectory — 但我不发她, 不评论, 不互动。_

# pagebreak
-> day_112_finale_recap


= day_112_path_c_evening
# diegetic_ui: phone_wechat_check
# speaker: protagonist

# speaker: protagonist

你点开 Lisa 朋友圈。

仍是横线"该用户最近没有更新"。

她屏蔽 5 周。

S5 你可能仍点开看 — 仍 nothing。

或者你停 — 你不再 check。

_S5 我可能 stop check Lisa 朋友圈。_

_这是 silent acceptance — 我接受她不让我看。_

# pagebreak
-> day_112_finale_recap


= day_112_path_e_evening_default
# speaker: protagonist

silence。

你 mute Lisa 8 个月。

她 mute 你 8 个月。

S5 第 1 集 standard。

# pagebreak
-> day_112_finale_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 112 周日日报 (E16 末 / S4 finale 末)
// ----------------------------------------------------------------------------

= day_112_finale_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_finale_recap
# speaker: protagonist

_今日 状态: {state}/100_

_关键时刻 today (E16 finale):_

_  - 8:30 妈妈 verbatim "**我下个月想去你那看看你**" — S2 finale callback, S4 spiral 起步_

_  - 9:30 KPI Review 浮层 + 5 路径 router_

{sick_count >= 4:
    _  - 路径 D: 笑天周日仍发烧, 没去公司, 不知 David 摔保温杯_
    _  - 系统评估"装病摸鱼" + 下月 +3%_
}

{cumulative_hero_count >= 5 and lisa_score >= 25 and not (sick_count >= 4):
    _  - ★ 路径 A: KPI Review 浮层 verbatim "**您本月持续表现稳定...更高的责任**"_
    _  - ★ 季度协作反馈附件 verbatim "**...高潜力人才储备池**" (promotion warning prelude)_
    _  - 11:00 王总监微信 verbatim "**你做得不错。下个月再看看**"_
    _  - 11:30 Zoe 邮件 1v1 (paper trail 起步)_
    _  - 12:00 茶水间 David 摔保温杯 + 笑天 Decision (3 选 1) + 张磊在场 silent_
    _  - 18:00 Lisa 微信"清明假期顺利吗" (4 句模式)_
    _  - 系统评估"稳定模式" + 下月 +10% + promotion candidate prelude_
}

{cumulative_hero_count >= 3 and not (cumulative_hero_count >= 5 and lisa_score >= 25) and not (sick_count >= 4):
    _  - 路径 B: 系统评估"标准达标" + 下月 +5%_
    _  - 12:00 茶水间 David 摔保温杯 + 笑天 Decision (3 选 1)_
    _  - Lisa 朋友圈"开启新阶段满 1 个月" (笑天 D110 截图保存)_
}

{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 3) and not (sick_count >= 4):
    _  - 路径 C: 系统评估"险过" + 下月 +5%_
    _  - 12:00 茶水间 David 摔保温杯 + 笑天 Decision (3 选 1)_
    _  - Lisa 朋友圈仍屏蔽态_
}

{cumulative_hero_count == 0 and not (sick_count >= 4):
    _  - 路径 E: 系统评估"全程摸鱼" + 下月 +1%_
    _  - 笑天 12:00 直接回家, 不知 David 摔保温杯_
    _  - Lisa silence (8 个月 mute 双向)_
}

_NPC scores 末:_

_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_

_  Vivian {vivian_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_S4 末 累积 flags:_

_  - cumulative_hero_count: {cumulative_hero_count} / 6_

_  - 病倒次数: {sick_count}_

_  - effort_overage: {effort_overage}_

_  - promotion_candidate_count: {promotion_candidate_count} (路径 A KPI ≥ 150 += 1)_

// ----------------------------------------------------------------------------
// Series Cliffhanger 至 S5
// ----------------------------------------------------------------------------
// S5 第 1 集 (E17) 开局 (per outline §6 5 路径 cliffhanger):
//   - 路径 A: 笑天周一进公司发现张磊 周末加班 — 他真的开始 PUA 起步
//   - 路径 B: 笑天周一进公司发现 David 没来 — 他第一次请病假
//   - 路径 C: David 中午饭叫笑天"一起吃啊" — 但他没自我激励 (S5 quiet sign 2)
//   - 路径 D: 笑天又装病 1 次 → David 私聊问"兄弟最近怎么样"
//   - 路径 E: standard
//
// S5 主题: 新人入场 (per series-structure §2 S5 row "笑天第一次被叫'陈哥'")

-> END

// ============================================================================
// EOF episode-16.ink
// ============================================================================
