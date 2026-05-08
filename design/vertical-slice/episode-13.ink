// ============================================================================
// Episode 13 · Week 13 · 「新工位主人」
// ============================================================================
//
// Status: 第 1 版 (S4 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S4 Round 1)
// Last Updated: 2026-05-07
//
// 配套 reference:
//   - season-4-arc.md §5 E13 beat sheet (主 spec)
//   - season-4-arc-round-1-reply.md GM 6 Q decisions
//   - episode-12.ink (S3 finale ink syntax sample, 5 路径 stitch chains)
//
// 设计目标 (摘要):
//   1. S3→S4 cliffhanger 兑现 — Lisa 工位 5 路径 visual differentiation
//   2. David quiet sign 0 (baseline 抬高 — 周一 8:30 已在工位)
//   3. 王总监 +2/集 cue 起步 (路径 A)
//   4. 老周 D85 速度变慢 0.5 秒经过 Lisa 原工位 (silent witness)
//   5. 6:4 笑稍多 — Lisa 走后第一周 quiet 不偏扎
//   6. Cliffhanger 至 E14: 妈妈 verbatim "清明你姨他们要去你爸坟上"
//
// Verbatim quotes 必保留:
//   - 妈妈 D91 "**清明你姨他们要去你爸坟上 — 你今年回不回来**" (per Q5 strict constraint)
//
// ============================================================================

INCLUDE episode-1.ink

// E13 entry
-> episode_13


// ============================================================================
// Episode 13 主入口 + 路径 cache refresh
// ============================================================================

=== episode_13 ===
# scene: home
# time: monday_morning_week_13
# pagebreak

// Recompute cumulative_hero_count (E12 D84 已 cache, 此处保险 refresh)
~ cumulative_hero_count = lisa_helped_pps + lisa_helped_after_hr + lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive + lisa_referred_external

-> day_85_morning_briefing


// ============================================================================
// Day 85 · 周一 · ★ 5 路径 Lisa 工位变化兑现 ★
// ============================================================================

= day_85_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared
# speaker: protagonist

闹钟响了 1 次。

_新月份。第 13 周。_

_S3 finale 周日 KPI Review 已过。下月 threshold 又涨。_

_Lisa 走了。或者她没走。或者她没走但她不在我这边了。_

_我不知道我哪条路径。_

# scene: subway_carriage
# time: 8:30
# speaker: protagonist

地铁。今天人不多——4 月初, 春天。

你看一眼地铁电视。"全市新房成交 2231 套, 同比下降 19.4%。"

_市场连续 13 周下跌。但老板水果盘可能 4 月底变草莓——Vivian S3 末说"D 轮可能过会"。_

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:14 到公司。打卡机响一下。

# speaker: vivian
Vivian: "嗨～来啦～ 嗨～新月份。"

水果盘**仍是苹果**——苹果周第 13 周。

~ fruit_bowl = "apple"

# speaker: protagonist

_S3 末她预告"D 轮可能过会"——这周仍 apple。融资还没到位。_

* [开始今日]
    -> day_85_event_1_lisa_workstation_branch


// ----------------------------------------------------------------------------
// Event 85.1 · ★ Lisa 工位 5 路径 router ★ · 9:18
// ----------------------------------------------------------------------------

= day_85_event_1_lisa_workstation_branch
# scene: workstation_entry
# time: 9:18
# speaker: protagonist

你走到工位区。

A 区——Lisa 工位斜对角。

你抬头看——

{
    - sick_count >= 4:
        -> day_85_path_d_lisa_workstation
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        -> day_85_path_a_lisa_workstation
    - cumulative_hero_count >= 3:
        -> day_85_path_b_lisa_workstation
    - cumulative_hero_count >= 1:
        -> day_85_path_c_lisa_workstation
    - else:
        -> day_85_path_e_lisa_workstation
}


// ----------------------------------------------------------------------------
// 路径 A — 张磊
// ----------------------------------------------------------------------------

= day_85_path_a_lisa_workstation
# scene: workstation_entry_path_a
# time: 9:18
# npc: zhanglei_new_hire
# speaker: protagonist

Lisa 工位**坐着一个新人**。

24 岁男生。比你小 8 岁。

他穿白衬衫——不挽袖子, 也不松扣子——他还没决定他要做 David 还是做笑天。

桌上摆 1 本他自己带的笔记本——封面贴着大学校徽。

他正在拆 USB 鼠标的包装——他刚到 5 分钟。

# speaker: zhanglei
"哥早。"

# speaker: protagonist

_他叫我哥。_

_我入职第 12 周时, David 叫我"天哥"——暗讽。_

_这小伙子 24 岁, 比我小 8 岁, 他默认我是哥。_

_我成了 12 周前的 David——但他不暗讽, 他是默认。_

# speaker: protagonist
你: "早。"

# speaker: zhanglei
他: "我叫张磊。"

# speaker: protagonist
你回头看了一眼自己的工位——

_我 12 周前的第一天。桌上前任员工留下的小绿萝, 桌面便利贴"活到周五"。_

_今天他刚到 5 分钟, 桌上是他大学笔记本。_

_12 周后他的桌上会贴什么便利贴。_

_不会是"活到周五"——这是我的便利贴。_

~ check_state_after_choice()
-> day_85_event_2_wang_cue_xiaotian


// ----------------------------------------------------------------------------
// 路径 B — Lisa 工位空 + 朋友圈"开启新阶段"
// ----------------------------------------------------------------------------

= day_85_path_b_lisa_workstation
# scene: workstation_entry_path_b_empty
# time: 9:18
# prop: lisa_workstation_empty_b
# speaker: protagonist

Lisa 工位**空着**。

她小玩偶不在了。她奶茶杯不在了。她空眼药水瓶不在了——李阿姨周末清理过。

椅子推到桌下, 像样品间的工位。

# diegetic_ui: phone_wechat_moments

你打开朋友圈——

# speaker: lisa
Lisa 朋友圈最新 1 条: 周日 23:00 发的。

# speaker: lisa
配文: "**开启新阶段**。"

配图: 她在新公司楼下的照片——黑色西装外套 (S2-S3 那件) + 棕色咖啡杯 + 远端办公楼。

# speaker: protagonist

_她在新公司。她没说哪家。朋友圈定位关了。_

_"开启新阶段"是离职高峰期最 popular 的 4 字 — 太 generic。_

_她跟我用同款话术。_

~ check_state_after_choice()
-> day_85_event_2_wang_cue_xiaotian


// ----------------------------------------------------------------------------
// 路径 C — Lisa 工位空 + 笑天发现被屏蔽
// ----------------------------------------------------------------------------

= day_85_path_c_lisa_workstation
# scene: workstation_entry_path_c_blocked
# time: 9:18
# prop: lisa_workstation_empty_c
# speaker: protagonist

Lisa 工位**空着**。

她小玩偶 / 奶茶杯 / 眼药水 全没了——李阿姨清理过。

你坐回自己工位。

# diegetic_ui: phone_wechat_check

你点开 Lisa 朋友圈——

页面显示一条横线: **"该用户最近没有更新"**。

她**没发**朋友圈——或者她发了但你看不到。

你点开她的微信对话框 → 你能发消息, 但她**头像旁边的小 status 圆点是空的**。

# speaker: protagonist

_她屏蔽了我的朋友圈。_

_她给我留了对话框。_

_但她不让我看她的生活。_

_S2 D49 她 mute 了"忙"状态。S3 D63 她头像换纯白。S4 D85 她朋友圈分组屏蔽。_

_她每一步都比上一步深一档。_

~ check_state_after_choice()
-> day_85_event_2_wang_cue_xiaotian


// ----------------------------------------------------------------------------
// 路径 D — 笑天周一仍请病假 (S3 装病延续)
// ----------------------------------------------------------------------------

= day_85_path_d_lisa_workstation
# scene: bedroom_sick_continuation
# time: 9:18
# music: bedroom_silence
# speaker: protagonist

你不在工位。

你在床上——周日装病的延续。

你周一 9:00 给王总监发的请假: "王总, 38.3 度, 今天请病假。"

# speaker: wang_director
王总监: "嗯, 你休息。注意身体。"

# speaker: protagonist

_他知道我没真发烧。或者他不知道。或者他知道但他不在乎。_

_我躺在床上, 体温 36.7 度, 微信刷了 1 小时。_

# diegetic_ui: phone_wechat_check_lisa

你点开 Lisa 微信对话框——

# speaker: lisa
最后一条仍是 S3 finale 周日: "**不管怎样, 谢谢你。**"

# speaker: protagonist

她没发新的。你也没发。

_她可能走了。或者她在新部门。或者她屏蔽了我。_

_我躺床上不知道。周三我回公司就知道了。或者周三我也起不来。_

~ sick_count = sick_count + 1

~ check_state_after_choice()
-> day_85_event_2_wang_cue_xiaotian


// ----------------------------------------------------------------------------
// 路径 E — Lisa 工位空 + 笑天问 Vivian
// ----------------------------------------------------------------------------

= day_85_path_e_lisa_workstation
# scene: workstation_entry_path_e_empty
# time: 9:18
# prop: lisa_workstation_empty_e
# speaker: protagonist

Lisa 工位**空着**。

她小玩偶 / 奶茶杯 / 眼药水 全没了。

你坐回自己工位。你**没点开**朋友圈, **没点开**微信对话框。

S2-S3 你 lisa_score < 0 累积——她 mute 你, 你也 mute 她。

# scene: corridor_late_morning
# time: 11:00
# npc: vivian_at_reception_brief

11:00。你去打印机取纸, 路过前台。

# speaker: protagonist
你停下来, 半秒。

# speaker: protagonist
你: "Vivian, Lisa 呢?"

# speaker: vivian
Vivian 抬头: "嗨～"

# speaker: vivian
"她上周走了。"

5 个字。

# speaker: vivian
她 0.5 秒看你脸。

你没 reaction。

# speaker: vivian
她: "嗨～来啦～" 转向下一个员工。

# speaker: protagonist

_她上周走了。_

_我 12 周前后桌斜对角同期入职。今天她走了, 我后知后觉。_

_S3 我累积选择 mute 她, 她也 mute 我。_

_我们俩这 12 周从没真的对话过。_

_她不在了。我也没什么变化。_

_Pillar 3 极致——她不存在的版本。_

~ check_state_after_choice()
-> day_85_event_2_wang_cue_xiaotian


// ----------------------------------------------------------------------------
// Event 85.2 · 王总监 cue 笑天 (路径 D 跳过, 其他路径共享)
// ----------------------------------------------------------------------------

= day_85_event_2_wang_cue_xiaotian
# scene: workstation_with_wang_passing
# time: 9:25

{sick_count >= 4: -> day_85_skip_to_david | -> day_85_wang_cue_present }


= day_85_wang_cue_present
# scene: workstation_with_wang_passing
# time: 9:25
# npc: wang_passing_then_pausing
# speaker: protagonist

9:25。你回到自己工位。

# speaker: wang_director
王总监经过工位区, 站在你工位旁。

# speaker: wang_director
"小笑啊。"

0.5 秒。

# speaker: wang_director
"陈天啊。"

0.5 秒。

# speaker: wang_director
"差不多差不多。**新月份了, 你的 KPI 怎么样？**"

# speaker: protagonist

running gag callback (S1 D15 + S2 D29 + S3 D57 都是这一句, 4 次 connection)。

他没等你回答, 走开了。

_他每个新月份都来一次。_

_S1 D15 我以为是普通 cue。_

_S2 D29 我意识到是 push pattern。_

_S3 D57 我意识到 S1 finale 路径 A 的 reward 是 +2/集 cue 频率。_

_S4 D85 我已经 numbed——他来 cue, 我背景里默认。_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _但今天他来得比平时早 5 分钟——9:25 不是 9:30。_

    _S3 finale 路径 A reward 兑现——promotion candidate prelude 起步。_

    _我还不知道 promotion = 处刑。我会知道——但不是今天。_
}

~ check_state_after_choice()
-> day_85_event_3_david_baseline


= day_85_skip_to_david
# speaker: protagonist
_王总监今天没 cue 我——他不在我家床上。_

_他可能在公司站在我空工位旁等了 1 秒, 然后看到 Outlook 里我的请假 notification。_

~ check_state_after_choice()
-> day_85_event_3_david_baseline


// ----------------------------------------------------------------------------
// Event 85.3 · David 8:30 已在工位 (★ quiet sign 0 ★)
// ----------------------------------------------------------------------------

= day_85_event_3_david_baseline
# scene: workstation_with_david_visible
# time: 9:30

{sick_count >= 4: -> day_85_david_imagined | -> day_85_david_present }


= day_85_david_present
# scene: workstation_with_david_visible
# time: 9:30
# npc: david_already_at_desk_typing
# speaker: protagonist

9:30。你余光看 David 工位——

他**已经在敲键盘**。

他来得比 9:00 早 30 分钟以上——8:30 已到工位。

他正在改 PPT V3 (本周 deliverable)。他用同事的不同字体改 4 个版本——他在 stress test PPT。

_S1 末他周五 17:30 准时走 + 周一前预备好下周计划。_

_S2 末他周二写下下周计划。_

_S3 末他周二上午 9:00 已经交周报 + 周日加班。_

_S4 D85 他周一 8:30 已经在工位——周末加班 + 周一早到 30 分钟。_

_他每个 milestone 比上个 milestone 早 30 分钟 / 1 天 / 1 周。_

_他在 spiral up baseline——但他自己不知道这是 spiral, 他以为是"正常职业精进"。_

_他第 0 个 quiet sign——baseline 抬高。_

_我看着没说什么。_

~ check_state_after_choice()
-> day_85_event_4_lao_zhou_pass


= day_85_david_imagined
# speaker: protagonist
_我躺床上 — 我猜 David 今天 8:30 已经在工位。_

_他从 S3 末已经升级到周末加班。_

_S4 第 1 天他可能 8:00 到的——我没 cross-check。_

~ check_state_after_choice()
-> day_85_event_4_lao_zhou_pass


// ----------------------------------------------------------------------------
// Event 85.4 · 老周经过 Lisa 原工位速度变慢 0.5 秒
// ----------------------------------------------------------------------------

= day_85_event_4_lao_zhou_pass
# scene: corner_workstation_lao_zhou
# time: 11:30

{sick_count >= 4: -> day_85_event_5_decision | -> day_85_lao_zhou_present }


= day_85_lao_zhou_present
# scene: corner_workstation_lao_zhou
# time: 11:30
# npc: lao_zhou_passing_lisa_old_workstation
# speaker: protagonist

11:30。你站起来去打印机。

老周端着茶——他平时 11:30 是回工位喝茶 timing。

他从茶水间走回他工位——必经过 Lisa 原工位。

他经过 Lisa 工位时——

他**速度变慢 0.5 秒**。

他**没看**Lisa 工位 (路径 A 张磊在 / 路径 B/C/E 空)。

他低头看自己茶杯。

但他的速度慢了 0.5 秒——他平时不会慢, 他每天 11:30 走的同一条路线 12 年 0.5 秒不差。

今天他慢了。

_S2 finale 周日 12:30 Lisa 走出 HR 时, 老周端茶经过, 速度慢 0.5 秒。_

_S3 finale 周日 12:30 路径 B-E 同样的 motif。_

_S4 D85 — Lisa 已经走 / 转岗了, 老周仍然在 11:30 经过 Lisa 工位时慢 0.5 秒。_

_他在 fixed 这个动作。_

_他不是为 Lisa 慢——他为这个位置本身慢。_

_上一个坐这位置的也走了。前一个坐这位置的也走了。前前一个也走了。_

_他在这 12 年看过所有的 0.5 秒。_

~ check_state_after_choice()
-> day_85_event_5_decision


// ----------------------------------------------------------------------------
// Event 85.5 · ★ E13 Decision: David 朋友圈点赞 ★ (路径 A/B/C 玩家)
// ----------------------------------------------------------------------------

= day_85_event_5_decision
# scene: home_evening
# time: 21:00
# diegetic_ui: phone_wechat_moments

{
    - sick_count >= 4:
        -> day_85_decision_skip
    - cumulative_hero_count == 0:
        -> day_85_decision_e_skip
    - else:
        -> day_85_decision_choose
}


= day_85_decision_skip
# speaker: protagonist
_David 周日 18:00 发了一条朋友圈"全部门最先交周报。下个月继续干"——是 S3 finale 周日 18:00 发的。_

_我周一在床上, 没看。或者我看了, 没 reaction, 滑过去了。_

_S4 D85 我 disengage from David。_

~ check_state_after_choice()
-> day_85_after_work


= day_85_decision_e_skip
# speaker: protagonist
_David 朋友圈我 mute 了——S3 末我已经 mute。_

_今天我不点开。_

~ check_state_after_choice()
-> day_85_after_work


= day_85_decision_choose
# scene: home_evening_decision
# time: 21:00
# diegetic_ui: phone_wechat_moments
# speaker: protagonist

21:00。你刚洗完澡。刷朋友圈。

# speaker: david
David 周日 18:00 发的:

# speaker: david
配文: "**全部门最先交周报。下个月继续干。**"

配图: 他工位的电脑屏幕——周报已 submitted 截图。

18 个赞 + 4 条评论。

# speaker: protagonist

他朋友圈每条都 18-25 赞——他的同事 / 老板都点赞 (Vivian / Zoe / 王总监 都在他朋友圈)。

_他周日 18:00 — Lisa 走的同一晚 + David 卷王 self-celebrate。_

_Pillar 4 ironic mirror: Lisa walking, David celebrating。_

* [点赞]
    你点了赞。
    ~ david_score = david_score + 1
    _你成第 19 个赞。_
    _他 30 秒后给你回了一个赞 (你某条朋友圈, 你忘了哪条)。_
    _他在 reciprocate。你买了他 30 秒 attention。_

* [不点赞]
    你看了, 没 reaction, 滑过去。
    ~ david_score = david_score + 0
    _中性。_

* [评论"早"]
    你评论 "早"。
    ~ david_score = david_score - 1
    5 分钟后 David 没回你。
    10 分钟后他**删掉了你的评论** — 你不知道他删了, 但通知已经撤回。
    _他听出来"早" 是阴阳。他在维持朋友圈 PR——你的 1 字 negative comment 破坏 PR。_

- _decision logged。_

~ check_state_after_choice()
-> day_85_after_work


// ----------------------------------------------------------------------------
// after_work · Day 85
// ----------------------------------------------------------------------------

= day_85_after_work
# scene: workstation_evening_or_home
# time: 17:30

{sick_count >= 4: -> day_85_recap_route | -> day_85_after_work_present }


= day_85_after_work_present
# scene: workstation_evening
# time: 17:30
# speaker: protagonist

17:30。

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

- _下班 logged。_

~ check_state_after_choice()
-> day_85_recap_route


= day_85_recap_route
# pagebreak
-> day_85_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 85
// ----------------------------------------------------------------------------

= day_85_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_今日 状态: {state}/100_

_关键时刻 today (D85):_

{sick_count >= 4:
    _  - 路径 D: 笑天周一请病假 — Lisa 工位 / 王总监 / David / 老周 全 imagined_
}

{cumulative_hero_count >= 5 and lisa_score >= 25 and not (sick_count >= 4):
    _  - ★ 路径 A: Lisa 工位换人 张磊 24 岁男生 "哥早" (笑天意识"我成了 12 周前的 David")_

    _  - 王总监 9:25 cue (S3 finale 路径 A reward — 比 standard 早 5 分钟)_
}

{cumulative_hero_count >= 3 and not (cumulative_hero_count >= 5 and lisa_score >= 25) and not (sick_count >= 4):
    _  - 路径 B: Lisa 工位空 + 朋友圈"开启新阶段"_
}

{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 3) and not (sick_count >= 4):
    _  - 路径 C: Lisa 工位空 + 笑天发现被屏蔽朋友圈_
}

{cumulative_hero_count == 0 and not (sick_count >= 4):
    _  - 路径 E: Lisa 工位空 + 笑天问 Vivian "她上周走了"_
}

_  - David quiet sign 0: baseline 抬高 (周一 8:30 已到)_

_  - 老周经过 Lisa 原工位速度慢 0.5 秒 (silent witness)_

# pagebreak
-> day_86_morning_briefing


// ============================================================================
// Day 86 · 周二 · David 抢功 + Lisa 微信 (路径 A)
// ============================================================================

= day_86_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周二。

{sick_count >= 4: -> day_86_path_d_continuation | -> day_86_normal_morning }


= day_86_path_d_continuation
# scene: bedroom_sick_day_2
# speaker: protagonist
_你周二 9:00 给王总监发: "王总, 还在发烧, 今天还请。"_

_王总监: "嗯。"_

_你看 Lisa 微信对话框 — 仍是 S3 finale 那条"不管怎样, 谢谢你"。_

_你没回。_

~ sick_count = sick_count + 1

~ check_state_after_choice()
# pagebreak
-> day_86_daily_recap


= day_86_normal_morning
# scene: office_workstation
# time: 9:11
# speaker: protagonist

9:11 到公司。

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # speaker: zhanglei
    张磊已经在工位 (8:50 到, 比你早)。
    # speaker: zhanglei
    "哥早。"
    # speaker: protagonist
    你: "早。"
}
{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
    # speaker: protagonist
    Lisa 原工位仍然空 (D88 周三新人入职)。
}
{cumulative_hero_count == 0:
    # speaker: protagonist
    Lisa 原工位空。今天没 sign。
}

* [开始今日]
    -> day_86_event_1_david_pps_demo


= day_86_event_1_david_pps_demo
# scene: workstation_with_phone_wechat
# time: 10:30
# diegetic_ui: phone_wechat_chat
# speaker: protagonist

10:30。微信弹出 1 条。

# speaker: david
David: "兄弟! 5 分钟的事啊。我下午 3 点要给王总监看 pps demo, 你帮我看下结论页?"

# speaker: protagonist

S2 D30 第一次。S3 reframe 过. S4 D86 又一次。

_他每月固定 1 次 pps demo "5 分钟" 求助 — running gag, 跨 S2-S4。_

_我成了他的 ghostwriter pool 员工编号 #1。_

* [接过来]
    # speaker: protagonist
    你回: "好的, 发我。"
    David 立刻发了 OneNote 链接。你看了 20 分钟改了 5 个字。
    下午 3 点 David 群里"@所有人 感谢 笑天 帮 demo 结论页"——standard。
    ~ david_score = david_score + 1
    ~ kpi = kpi - 2

* [我也忙]
    # speaker: protagonist
    你: "我也忙, 你自己看吧。"
    # speaker: david
    David: "好的好的。"
    _他 30 分钟后再发: "兄弟在不在?"_
    _你不回。_
    ~ david_score = david_score - 1

* [假装没看见]
    你没回。
    20 分钟后 David: "在不?"
    你没回。
    ~ david_score = david_score - 2

- _decision logged。_

~ check_state_after_choice()
-> day_86_event_2_lisa_motif


= day_86_event_2_lisa_motif
# scene: workstation_afternoon
# time: 15:00
# diegetic_ui: phone_wechat_check

{
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        -> day_86_lisa_message_path_a
    - cumulative_hero_count >= 3:
        -> day_86_lisa_silence_path_b
    - cumulative_hero_count >= 1:
        -> day_86_lisa_silence_path_c
    - else:
        -> day_86_lisa_silence_path_e
}


= day_86_lisa_message_path_a
# scene: workstation_afternoon
# time: 15:00
# diegetic_ui: phone_wechat_chat
# speaker: lisa

15:00。微信 1 条。

# speaker: lisa
Lisa: "笑天, 新部门第一天还行, 谢谢笑天。"

12 个字 + 1 emoji 😊。

# speaker: protagonist

_S3 末她 dialog 频率↓——4 句以内。_

_S4 D86 她主动报"新部门第一天" — 这是她 S3 末"谢谢笑天" verbatim 之后第一次主动联系。_

_她跟我"transactional friendly" — 她不会再"你别担心" 那套 vulnerability 给我了。_

_她在 build 新关系。我在 product team 看着她转岗的 ambient signal。_

* [挺好的]
    # speaker: protagonist
    你: "挺好的。"
    ~ lisa_score = lisa_score + 1
    # speaker: lisa
    Lisa 回: "嗯。"

* [辛苦了]
    # speaker: protagonist
    你: "辛苦了。"
    ~ lisa_score = lisa_score + 1
    # speaker: lisa
    Lisa 回: "嗯。还好。"

* [不回]
    # speaker: protagonist
    你看了, 没回。
    ~ lisa_score = lisa_score - 1

- _logged。_

~ check_state_after_choice()
-> day_86_after_work


= day_86_lisa_silence_path_b
# speaker: protagonist
_Lisa 没微信我。_

_她朋友圈昨晚那条"开启新阶段"是 final. 她不会再 1v1 私聊我。_

_她在 protect both of us 的 face._

~ check_state_after_choice()
-> day_86_after_work


= day_86_lisa_silence_path_c
# speaker: protagonist
_你点开 Lisa 微信对话框 — 仍是 S3 finale "不管怎样, 谢谢你"。_

_她头像旁的 status 圆点空白。_

_她没发, 你没发。沉默累积。_

~ check_state_after_choice()
-> day_86_after_work


= day_86_lisa_silence_path_e
# speaker: protagonist
_Lisa 走了。我不在她朋友圈分组里 (我没朋友圈)。_

_我们俩从 S2 起就是 mute 双向。今天没什么变化。_

~ check_state_after_choice()
-> day_86_after_work


= day_86_after_work
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
-> day_86_daily_recap


= day_86_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

{sick_count >= 4:
    _  - 路径 D 病假 day 2 — 王总监"嗯"_
}

{not (sick_count >= 4):
    _  - David pps demo 又来一次 (S2 D30 callback, S4 第 N 次)_

    {cumulative_hero_count >= 5 and lisa_score >= 25:
        _  - 路径 A: Lisa 微信"新部门第一天还行"_
    }

    {cumulative_hero_count >= 3 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
        _  - 路径 B: silence (Lisa 朋友圈 final)_
    }

    {cumulative_hero_count >= 1 and not (cumulative_hero_count >= 3):
        _  - 路径 C: 笑天看对话框 (屏蔽态)_
    }

    {cumulative_hero_count == 0:
        _  - 路径 E: silence (mute 双向 baseline)_
    }
}

# pagebreak
-> day_87_morning_briefing


// ============================================================================
// Day 87 · 周三 · 晨会 + David 152% + 新人首次入会
// ============================================================================

= day_87_morning_briefing
# scene: meeting_room
# time: 9:25
# weather: cleared
# speaker: protagonist

周三。晨会日。

{sick_count >= 4: -> day_87_back_from_sick | -> day_87_meeting_normal }


= day_87_back_from_sick
# speaker: protagonist
_你周三回公司——38.3 度退到 36.7。_

_你看 Lisa 工位 — 空着。_

_你 9:00 到 — 不去打卡, 直接进会议室。_

-> day_87_meeting_normal


= day_87_meeting_normal
# scene: meeting_room
# time: 9:25
# npc: david_with_okr_planner
# npc: lao_zhou_in_back
# speaker: protagonist

9:25 到会议室。

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # npc: zhanglei_first_meeting
    # speaker: protagonist
    张磊也在——他坐在 David 对面。他**不发言**, 他听。
}

David 笔记本贴 4 张便利贴 ("Q2 第 1 周 OKR")。

老周后排, 中间那杯茶。

9:32 王总监推门。

* [开始今日]
    -> day_87_event_1_morning_meeting_152


= day_87_event_1_morning_meeting_152
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium
# speaker: wang_director

王总监打开 PPT。今天封面是"**Q2 启动会**"。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"**我们这个团队啊, 是有未来的。**"

# speaker: protagonist

13 个字。每月 1 次 baseline。

# speaker: wang_director
王总监: "S4 第 1 周 — 大家一起 Q2 开局。"

# speaker: david
David 抢话:

# speaker: david
"王总, 我**主动报一下** — **上周 KPI 完成 152%。**"

# speaker: protagonist

会议室静了。

# speaker: wang_director
王总监: "**嗯。**"

# speaker: protagonist

1 个字。王总监换 PPT 下一张——他**没接**。

David 0.3 秒——他笑了一下, 没说话。

_David S3 D64 报"145%" 王总监 0.5 秒后"嗯"。_

_S4 D87 他报"152%" 王总监 0.3 秒后"嗯"。_

_他每次 spike 7 个 percentage point, 王总监响应时间 -0.2 秒。_

_他的 spike 在 attenuate. 王总监对他的关注在 decline._

_他自己感觉不到。他还以为自己在精进。_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # speaker: wang_director
    王总监: "**张磊啊, 上周 onboarding 怎么样?**"
    # speaker: zhanglei
    张磊: "还行, 哥们都帮我看着。"
    # speaker: wang_director
    王总监: "嗯。**加油啊。**"

    # speaker: protagonist
    _他对张磊"加油啊" — 跟 S1 D1 他对我"加油啊"完全一样。_

    _他记不住张磊名字 (像他记不住我), 但他能 mass-produce "加油啊"。_

    _12 周后他对张磊会"小磊啊…磊啊…差不多差不多"。_
}

# speaker: wang_director
王总监: "散会。"

8 分钟。

~ check_state_after_choice()
-> day_87_after_work


= day_87_after_work
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
-> day_87_daily_recap


= day_87_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

_  - 晨会王总监"我们这个团队啊, 是有未来的" (跨 S1-S4 第 N 次 baseline)_

_  - **David 主动报 "152%" 王总监 0.3 秒后 "嗯"** (响应时间 -0.2s vs S3 D64)_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 张磊首次入会, 王总监对他"加油啊" (running gag callback S1 D1)_
}

# pagebreak
-> day_88_morning_briefing


// ============================================================================
// Day 88 · 周四 · 加班路过李阿姨 + Lisa 工位状态 path-specific
// ============================================================================

= day_88_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared
# speaker: protagonist

周四。

# scene: office_workstation
# time: 9:11

9:11 到公司。

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # speaker: protagonist
    张磊在工位 — 他在贴 vinyl 贴纸 (公司发的 Q2 OKR 海报 mini 版) 到隔板上。

    他动作慢, 每张贴纸他对齐 3 次。
}

{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
    # speaker: protagonist
    Lisa 原工位 — 现在是赵丽 (周三下午 onboarding 后她周四第一天) — 25 岁女生, 黑色 polo, 戴眼镜。

    她正在 setup 新邮箱 — 她 confused 看 IT setup guide。

    她不主动跟笑天说话。
}

{cumulative_hero_count == 0:
    # speaker: protagonist
    Lisa 原工位 — 现在是赵丽。她 setup 邮箱。silent。
}

* [开始今日]
    -> day_88_event_1_evening_li_ayi


= day_88_event_1_evening_li_ayi
# scene: workstation_late_evening
# time: 19:00
# npc: li_ayi_mopping_silent
# speaker: protagonist

19:00 (申报加班玩家)。

李阿姨在工位区拖地。

她推着拖把车 — 她孙女照片仍贴在车上 + 她儿子准考证仍贴在车上。

她经过你工位 — 她**没看你**。

她经过 Lisa 原工位 (路径 A 张磊 / B-E 赵丽) — 她**多拖了 1 遍**。

_她不跟新人说话。她不跟笑天说话。她拖地。_

_她每个工位都拖。Lisa 原工位她多拖 1 遍——她记得这个工位上一个人。_

_老周也记得。但老周用 0.5 秒慢, 李阿姨用 1 遍多。_

_两种 silent witness。_

~ check_state_after_choice()
-> day_88_after_work


= day_88_after_work
# scene: workstation_evening
# time: 19:30

* [自己回家]
    ~ state = state + 0

~ check_state_after_choice()
# pagebreak
-> day_88_daily_recap


= day_88_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_关键时刻 today:_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 张磊在 Lisa 原工位贴 OKR vinyl 海报 (3 次对齐, 慢)_
}

{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
    _  - 赵丽 周四第一天 setup 邮箱, 不主动 chat_
}

_  - 李阿姨 19:00 拖地经过 Lisa 原工位**多拖 1 遍** (silent witness)_

# pagebreak
-> day_89_morning_briefing


// ============================================================================
// Day 89 · 周五 · weekly_recap + 张磊问 Wi-Fi (路径 A) / 赵丽 silent
// ============================================================================

= day_89_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared
# prop: fruit_bowl_apple
# speaker: protagonist

周五。

9:08 到公司。Vivian standard "嗨～来啦～"。

水果盘**仍是苹果**——苹果周第 13 周。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_89_event_1_weekly_recap


= day_89_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay
# speaker: protagonist

16:50。HR 系统弹出周报浮层。

- 出勤率: standard

- 主动产出条目: 取决于 D 85-88 选择

- 协作记录: 取决于本周 David / Lisa 选择

浮层底部: "**本月度 KPI 还有 23 天 (周日推送月末通报)**"。

_本月度 KPI 还有 23 天。_

_S4 第 1 月末倒数 setup。_

~ check_state_after_choice()
-> day_89_event_2_zhanglei_or_zhaoli


= day_89_event_2_zhanglei_or_zhaoli
# scene: workstation_with_new_hire
# time: 18:30

{
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        -> day_89_zhanglei_wifi_path_a
    - else:
        -> day_89_zhaoli_silent
}


= day_89_zhanglei_wifi_path_a
# scene: workstation_evening_path_a
# time: 18:30
# npc: zhanglei_at_desk
# speaker: protagonist

18:30。你收东西。

# speaker: zhanglei
张磊转过来: "**哥, 那个 Wi-Fi 密码是?**"

# speaker: protagonist
你: "Wi-Fi5G@Companyxxxxx — 大写 C, 后面 5 位数字。"

# speaker: zhanglei
张磊: "**谢谢哥。**"

# speaker: protagonist

他笑了一下 — 他对我笑得比对 David 真心。

_S1 D5 我 12 周前问过 Vivian "Wi-Fi 密码"。_

_Vivian 说: "Wi-Fi5G@Companyxxxxx" — 同样的 12 位密码。_

_12 周后我对张磊重复了一遍。_

_我成了我入职时遇到的 老员工。_

_安静的、不主动的、回 Wi-Fi 密码就走的。_

_但比 David 那种"挽袖子的衬衫" 安静一档。_

~ check_state_after_choice()
-> day_89_after_work


= day_89_zhaoli_silent
# scene: workstation_evening_silent
# time: 18:30
# npc: zhaoli_at_desk
# speaker: protagonist

18:30。

赵丽**没主动跟笑天说话**。

她周五 19:00 走 — 她比 Lisa S2 末还早。

_她 S4 第 1 周很 standard。她可能 S5 才开始问 Wi-Fi。_

_或者她不问 — 她自己 Google。_

_S5 可能她也开始穿正装了。_

~ check_state_after_choice()
-> day_89_after_work


= day_89_after_work
# scene: workstation_evening
# time: 19:30

* [自己回家]
    ~ state = state + 0

~ check_state_after_choice()
# pagebreak
-> day_89_daily_recap


= day_89_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap
# speaker: protagonist

_今日 KPI: +{kpi}_

_本月度 KPI 还有 23 天_

_关键时刻 today:_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 张磊问 Wi-Fi 密码 (S1 D5 callback — 笑天意识"我成了 12 周前的老员工")_
}

{not (cumulative_hero_count >= 5 and lisa_score >= 25):
    _  - 周五新人 silent / 路径 D 仍 imagined_
}

# pagebreak
-> day_90_weekend_morning


// ============================================================================
// Day 90 · 周六 · 周末
// ============================================================================

= day_90_weekend_morning
# scene: bedroom
# time: 12:00
# music: weekend_silence
# speaker: protagonist

你睡到 12:00 醒。

# diegetic_ui: phone_wechat_moments

朋友圈:

# speaker: david
David 发"**周末 = 反思周, 复盘周, 充电周**"——他从 spinning words 升级到"反思 / 复盘 / 充电"3 词组合。

# speaker: protagonist

_他也开始 self-coach。_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    # speaker: protagonist
    Lisa 朋友圈仍是 D85 周日"开启新阶段"。她周末没发新的。
}

11:34 → 12:34。点外卖 35 元。
~ money = money - 35

* [开始今日]
    -> day_90_event_1_afternoon


= day_90_event_1_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence
# speaker: protagonist

下午 2 点。你在床上。

你打开购物车 — 浅色衬衫**还在**。S3 加的, 已经 17 周没买。¥259。

_我可能下周买。或者下下周。或者永远不买。_

你又躺了 30 分钟。

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_90_daily_recap


= day_90_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# speaker: protagonist

_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_

_  - 12:00 起床 (S4 第 1 周 baseline)_

_  - David 朋友圈"反思 / 复盘 / 充电" 3 词组合 (spinning 升级)_

# pagebreak
-> day_91_weekend_morning


// ============================================================================
// Day 91 · 周日 · ★ 妈妈 verbatim "你姨他们要去你爸坟上" ★
// ============================================================================

= day_91_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet
# speaker: protagonist

周日。

你 8:23 醒。

_S3 D63 她说"我下个月可能不去你那" backtrack。_

_S3 D70 她"那个谁的儿子年薪 60 万"。_

_S3 D84 她"那个谁的女儿离职了, 回老家考公务员了"。_

_今天 S4 D91 4 月初 — 接近清明。她可能会 mention 清明。_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_91_event_1_mom_video_qingming


= day_91_event_1_mom_video_qingming
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen
# speaker: mama

屏幕里是妈妈。

她戴老花眼镜, 厨房油烟机背景。

# speaker: mama
妈妈："**天天, 吃了吗?**"

# speaker: protagonist
你: "吃了。"

# speaker: mama
妈妈: "**工资发了吗?**"

# speaker: protagonist
你: "发了。"

# speaker: mama
妈妈停了一下。她**眯眼**。

# speaker: mama
妈妈: "**清明你姨他们要去你爸坟上 — 你今年回不回来?**"

# speaker: protagonist

15 个字 verbatim。

她说**"你姨他们"** — 她不直接说"你爸"。

她说**"清明" + "上坟"** — 流程性词。

她说"**你今年回不回来**" — 她在 ask 你的行动 plan, 不是 ask 你的 emotion。

你 0.5 秒。

* [回]
    # speaker: protagonist
    你: "回。我请假。"
    # speaker: mama
    妈妈: "好。妈给你买高铁票?"
    # speaker: protagonist
    你: "我自己买。"
    # speaker: mama
    妈妈: "嗯。"
    ~ mom_score = mom_score + 5

* [今年请不到假]
    # speaker: protagonist
    你: "今年请不到假。"
    # speaker: mama
    妈妈: "嗯, 那妈跟你姨说一声。"
    # speaker: protagonist
    你: "嗯。"
    ~ mom_score = mom_score + 0

* [再说]
    # speaker: protagonist
    你: "再说吧。"
    # speaker: mama
    妈妈: "好。"
    _她说"好" 0.5 秒。她不催。_
    ~ mom_score = mom_score + 1

- _logged。_

# speaker: protagonist

视频 6 分钟挂。

~ check_state_after_choice()
-> day_91_event_2_lisa_motif_or_quiet


= day_91_event_2_lisa_motif_or_quiet
# scene: home_evening
# time: 21:00

{
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        -> day_91_lisa_message_qingming
    - cumulative_hero_count >= 3:
        -> day_91_lisa_silence_path_b
    - cumulative_hero_count >= 1:
        -> day_91_lisa_silence_path_c
    - sick_count >= 4:
        -> day_91_path_d_evening
    - else:
        -> day_91_path_e_evening
}


= day_91_lisa_message_qingming
# scene: home_evening_path_a
# time: 21:00
# diegetic_ui: phone_wechat_message
# speaker: lisa

21:00。

# speaker: lisa
Lisa 微信:

# speaker: lisa
"笑天, 清明回家了吗?"

# speaker: protagonist
你: "不回。"

# speaker: lisa
Lisa: "嗯。"

# speaker: lisa
"**周一新部门正式开始 deliverable**。"

# speaker: protagonist

4 句模式 closed。

_她不在隔壁工位了。但她还在隔壁微信。_

~ lisa_score = lisa_score + 1

# pagebreak
-> day_91_daily_recap


= day_91_lisa_silence_path_b
# speaker: protagonist
Lisa 朋友圈仍是 D85 那条 "开启新阶段"。

她**没发新的**。她**没微信**笑天。

# pagebreak
-> day_91_daily_recap


= day_91_lisa_silence_path_c
# speaker: protagonist
你点开 Lisa 微信对话框。仍是 S3 finale "不管怎样, 谢谢你"。

你**没发**。屏蔽态 1 周累积。

# pagebreak
-> day_91_daily_recap


= day_91_path_d_evening
# speaker: protagonist
你周日仍在床上。

你 27.6 度退到 36.7 度。

你刷手机, Lisa 微信 0 update。

# pagebreak
-> day_91_daily_recap


= day_91_path_e_evening
# speaker: protagonist
silence。

你 mute Lisa 已经 7 个月。她 mute 你也是。

E13 末没有任何 Lisa signal。

# pagebreak
-> day_91_daily_recap


= day_91_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# speaker: protagonist

_今日 状态: {state}/100_

_关键时刻 today (E13 末):_

_  - 8:30 妈妈 verbatim "清明你姨他们要去你爸坟上 — 你今年回不回来" + 笑天 3 选 1_

{cumulative_hero_count >= 5 and lisa_score >= 25:
    _  - 21:00 路径 A: Lisa 微信"清明回家了吗?" + 4 句 closed (E13→E14 cliffhanger)_
}

{cumulative_hero_count >= 3 and not (cumulative_hero_count >= 5 and lisa_score >= 25):
    _  - 路径 B: silence (Lisa 朋友圈 D85 final, 不发新的)_
}

{cumulative_hero_count >= 1 and not (cumulative_hero_count >= 3):
    _  - 路径 C: silence (屏蔽态 1 周累积)_
}

{sick_count >= 4:
    _  - 路径 D: 病假 day 6 — 笑天周日仍在床上_
}

{cumulative_hero_count == 0 and not (sick_count >= 4):
    _  - 路径 E: silence — 7 个月双向 mute_
}

_NPC scores 末:_

_  Lisa {lisa_score} / David {david_score} / 妈妈 {mom_score}_

_下周一开始: 第 14 周 — 清明调休 「调休来加班」_

-> END

// ============================================================================
// EOF episode-13.ink
// ============================================================================
