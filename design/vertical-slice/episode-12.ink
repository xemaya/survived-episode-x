// ============================================================================
// Episode 12 · Week 12 · 「下周三签字」(Season 3 Finale — Series 第一个扎点 finale)
// ============================================================================
//
// Status: 第 1 版 (S3 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S3 Round 1)
// Last Updated: 2026-05-06
//
// 配套 reference: 同 episode-1.ink
// 主 spec: design/vertical-slice/season-3-arc.md §5 + §6 5 路径表
//        + season-3-arc-round-2-reply.md §1 priority logic + §2 6-flag count
//
// 设计目标 (摘要):
//   1. ★ S3 高潮 — Lisa 走/留全揭晓 ★
//   2. 5 路径都"扎"——只是扎法不同 (anti-Pillar 1 + Pillar 3 + Pillar 4 集中爆发)
//   3. 路径 A 救了 Lisa = 你下月 threshold +18% (anti-Pillar 1 极致)
//   4. ★ 林姐 First Impression (路径 A 专属) ★ — series 第一次"另一种活法" 显形
//   5. 2:8 整集情感最重
//   6. Series Cliffhanger 到 S4: 5 路径每条都有不同 Lisa 微信结局
//
// 红线 (S3 不能做):
//   - Lisa 走/留必须由 cumulative_hero_count + lisa_score + sick_count 决定 (不是 D84 当天玩家选)
//   - 玩家不能 "赢" — 路径 A "救 Lisa" = +18% threshold (更大处刑)
//   - 路径 A 不能给 happy ending UI / BGM / 庆祝过场
//   - 路径 B-E Lisa 都走 (不能 E12 周日反转"算了我不走了")
//   - 林姐 deliberate restraint — 仅路径 A 14:00 第一次出现, 她**不要笑天**
//   - HR-speak / PUA 话术直接抄, 不加情绪 (路径 A reward 文案)
//
// Verbatim quotes 必保留 (per season-3-arc.md §6):
//   - D84 8:30 妈妈 "**那个谁的女儿离职了, 回老家考公务员了**"
//   - D84 11:00 林姐 (路径 A, 王总监 phone 场外) "**让她过来吧**"
//   - D84 14:00 林姐 (路径 A) "**Lisa, 是吧? 跟我去那边坐**"
//   - D84 KPI Review 后 (路径 A) 王总监 "**小笑啊…陈天啊…你最近表现不错。下个月看你的**"
//   - D84 KPI Review 浮层 (路径 A) "**您本月协助同事完成关键交付。公司认可您的团队精神。下月将给予您更高的责任。**"
//
// Path A Decision (D80): lisa_referred_external — 路径 A 第 4 关键 hero flag
//
// ============================================================================

INCLUDE episode-1.ink

// E12 entry
-> episode_12


// ============================================================================
// Helper function — compute_cumulative_hero_count (per round-2 reply §2)
// ============================================================================

=== function compute_cumulative_hero_count() ===
// Ink: true = 1, false = 0 in arithmetic context — direct sum 6 booleans
~ return lisa_helped_pps + lisa_helped_after_hr + lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive + lisa_referred_external


// ============================================================================
// Episode 12 主入口
// ============================================================================

=== episode_12 ===
# scene: home
# time: monday_morning_week_12
# pagebreak
-> day_78_morning_briefing


// ============================================================================
// Day 78 · 周一 · ★ Vivian 草莓周 (ironic mirror) + Lisa 中午去食堂 ★
// ============================================================================
// 关键 beat:
//   - Vivian 水果盘草莓 — 老板心情好的同一周 Lisa 要走 (Pillar 4 极致黑色幽默)
//   - Lisa 桌上文件夹今天没在桌面 (她可能放包里了, ready)
//   - Lisa 中午去食堂 (仅路径 A 玩家可见 - lisa_weekend_company 玩家能 narratively reach)
//   - 食堂阿姨给 Lisa 多打一勺 — 她不知道 Lisa 要走 / 留, 但她看到 Lisa 瘦了

= day_78_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared

闹钟响了 1 次。

_S3 第 12 周第 1 天。Lisa 周日 21:30 微信"不管怎样, 谢谢你"(路径 A/B) 或者她没发 (路径 C/E) 或者笑天没看 (路径 D)。_

_今天周一 6/21。HR 周三 6/23 签字 (per W总监 D74 phone)。_

_2 天后 Lisa 离开。_

_或者周一 starting 客户成功部 (路径 A: lisa_referred_external?)。_

_或者她没 referral 直接 walk。_

_我不知道。Lisa 也不知道。_

_今天 + 周二 + 周三 = 3 天 high-stakes。_

# scene: subway_carriage
# time: 8:30

地铁。今天人正常。

_我刷地铁电视。"本月 A 股下跌 1.8%。" "全市新房成交 2456 套, 同比下降 16.2%。"_

_2456 套——比 D29 (3214 套) 少 758 套。_

_市场 9 周持续下跌。_

_老板的 D 轮还没过会。但 Vivian 今天可能换草莓——为什么?_

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_strawberry

9:14 到公司。

# speaker: vivian
Vivian: "嗨～来啦～"

水果盘——

**草莓**。

12 周连续苹果之后, 今天**草莓**。

~ fruit_bowl = "strawberry"

_她换了。_

_S1 E2 草莓周 (D8) — 老板演融资。_

_S3 E12 草莓周 (D78) — 老板**心情好**? 还是**真融资过会**?_

_或者老板老婆这周买了草莓。_

_或者 Lisa 走的同一周 — visual ironic mirror。_

_3 种都对。_

_但 Vivian 没说"D 轮过会"——她"嗨～来啦～" 标准长度。_

_她在 selective leak。她今天**没破"嗨"**。_

_她在 protect 自己——这周不是好 leak 时机。_

* [开始今日]
    -> day_78_event_1_lisa_no_folder_visible


// ----------------------------------------------------------------------------
// Event 78.1 · Lisa 桌上文件夹今天没在桌面 · 9:18
// ----------------------------------------------------------------------------
// 触发: 进入工位区
// 速度: 标准 (~6 行)
// 同框: Lisa (前景) + 笑天
// 设计意图: quiet sign — Lisa 文件夹放包里, ready to walk
// ----------------------------------------------------------------------------

= day_78_event_1_lisa_no_folder_visible
# scene: workstation_entry_with_lisa
# time: 9:18
# npc: lisa_in_suit_jacket_fifteenth_day
# prop: lisa_workstation_clean

你走到工位区。

A 区——Lisa 工位斜对角。

Lisa 在工位——第 15 天穿正装外套。

她桌上——

**牛皮纸文件夹不在桌面上**。

她平时把文件夹放键盘右边——今天**没看见**。

她**包很满**——她带的包比平时鼓 — 文件夹可能在包里。

她在敲 Word — self_review V12 (如果你 D67 帮过) 或者她自己改的 V N。

她**把文件夹 ready** 在包里——她可以**随时 walk away**。

她从来不把工作 doc 放包里——她平时桌上摆着, polish 公司电脑。

今天她**移走了**——她在 prep walk。

_她周一 starting state: ready to leave。_

_她 today 不必带 doc 在桌面 — 周三签字时她带包去 HR。_

_周一她在桌面 polish, 周三 walk away with the polished doc。_

_她已经接受。_

// 没有选项 - quiet sign

// hidden flag: Lisa D78 文件夹移走 - prep walk

~ check_state_after_choice()
-> day_78_event_2_lisa_canteen


// ----------------------------------------------------------------------------
// Event 78.2 · 中午 Lisa 去食堂 · 12:30 (仅路径 A 玩家 narratively reach)
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 标准 (~7 行)
// 同框: Lisa + 食堂阿姨 + 笑天 (仅 lisa_weekend_company 触发, 笑天能 narratively reach 食堂)
// 设计意图: 食堂阿姨给 Lisa 多打一勺 (她不知道 Lisa 要走, 她看到 Lisa 瘦了)
// 食堂阿姨 ambient flavor — 她不说话, 笑了一下
// ----------------------------------------------------------------------------

= day_78_event_2_lisa_canteen
# scene: workstation_lunchtime
# time: 12:30
# npc: lisa_walking_to_canteen

12:30。

{lisa_weekend_company:
    -> day_78_event_2_canteen_path_a
- else:
    -> day_78_event_2_canteen_invisible
}


= day_78_event_2_canteen_path_a
# scene: workstation_lunchtime_path_a
# time: 12:30
# npc: lisa_walking_to_canteen_path_a

Lisa 站起来——她拿包准备去食堂。

她**没拿外套**——她只穿衬衫。

_她换了 routine。她周末跟我对了——她周末跟我说她想换 ritual。_

_她周一**主动**去食堂 (这周第 1 天 — 不是 stretch, 是 reset)。_

# speaker: lisa
"笑天, 你去吃饭吗?"

她**主动 ask**——这是**series 第 1 次** Lisa 主动 ask 笑天去吃饭 (S1-S3 都是 Lisa 等笑天 / 拼奶茶被动)。

* [一起]
    # speaker: protagonist
    你: "好。"
    你跟她下楼。
    电梯里你没说话。她没说话。
    食堂——你点西红柿炒蛋 + 米饭。Lisa 点白菜豆腐 + 米饭 (素)。
    她**比平时点得清淡**——她省胃口, 因为她周三签字会紧张。

    # scene: canteen_with_food_court_auntie
    # npc: food_court_auntie_smiling
    # speaker: food_court_auntie

    食堂阿姨给 Lisa 打饭——她**多打了一勺**米饭。

    她**没说话**——她从来不说话。

    她**笑了一下**——她不知道 Lisa 要走 / 留, 但她看到 Lisa 瘦了。

    她对**所有瘦下去的人**都多打一勺。

    她是这家公司里 silent witness 第 4 个 (李阿姨 + 老周 + 我 + 食堂阿姨)。

    Lisa 看了食堂阿姨一眼——她**没说"谢谢"**。她直接拿盘子走。

    _她没说谢谢。她也不能说——说了食堂阿姨的"多打一勺" 就成了 transactional, 食堂阿姨的 silent acknowledgment 就破了。_

    _她 silently 接受。_

    12 分钟午餐。她吃了大概 70%。

    13:00 你和她回工位。
    ~ lisa_score = lisa_score + 3
    ~ state = state + 2

* [我自己吃]
    # speaker: protagonist
    你: "我今天吃便当, 你去吧。"
    # speaker: lisa
    Lisa: "嗯, 好。"
    她笑了一下 — 不深。
    她自己下楼去食堂。
    ~ lisa_score = lisa_score + 0

-

~ check_state_after_choice()
-> day_78_after_work


= day_78_event_2_canteen_invisible
# scene: workstation_lunchtime_invisible
# time: 12:30

Lisa 站起来——她去食堂吃饭 (但这条只在路径 A/B narratively visible — 路径 C/D/E 玩家没 D75 lisa_weekend_company 触发, 笑天平时不去食堂 + Lisa 不主动 ask, 笑天看不见这场)。

你**没看见 Lisa 主动 ask** — 你看见她 12:30 站起来拿包走 (你以为她去 Zoe 那)。

实际她去食堂 — 食堂阿姨给她多打一勺 (但你不在场)。

13:00 她回工位 — 你看见她回来, 你不知道她去哪。

_食堂阿姨 silent 见证只能被 lisa_weekend_company 玩家 unlock 看见。_

_其他玩家 just see Lisa 走 + 回, 没看见 silent moment。_

~ check_state_after_choice()
-> day_78_after_work


= day_78_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在 Word doc。

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
-> day_78_daily_recap


= day_78_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **Vivian 水果盘草莓** (12 周连续苹果之后第 1 次草莓 — Pillar 4 ironic mirror)_
_  - Lisa 桌上文件夹**移走** (放包里, ready to walk)_
{lisa_weekend_company:
    _  - 路径 A: Lisa 主动 ask 笑天去食堂 (series 第 1 次主动)_
    _  - 食堂阿姨给 Lisa **多打一勺** (silent witness 第 4 个)_
}

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_79_morning_briefing


// ============================================================================
// Day 79 · 周二 · David 周报已经交了 + 王总监没 cue Lisa
// ============================================================================
// 关键 beat:
//   - David 周报已经交了——他从来没这么早交过
//   - 晨会王总监讲"我们这个团队啊, 是有未来的"——他**没 cue Lisa** (系统已经在处理她)

= day_79_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_workstation
# time: 9:11
# npc: lisa_in_suit_jacket_sixteenth_day

9:11 到公司。Lisa 第 16 天穿正装。

# diegetic_ui: phone_email_check

你打开企业邮箱——

**David 已经交周报**——周二上午 9:00, 他比 deadline 早 27 小时。

他从来不周二上午交周报 — 他平时周三下午交。

_他在 prep 接 Lisa 位置 — 他想 demonstrate efficiency 让王总监 register。_

_他在 audition for the empty seat。_

* [开始今日]
    -> day_79_event_1_morning_meeting_no_lisa_cue


// ----------------------------------------------------------------------------
// Event 79.1 · 晨会 王总监没 cue Lisa · 9:35
// ----------------------------------------------------------------------------
// 触发: 周二晨会 (S3 第 12 周)
// 速度: 长 (~10 行)
// 同框: 王总监 + David + Lisa + 老周 + 笑天
// 设计意图: 王总监 disengage 升级 — 系统已在处理 Lisa, 不需要他 cue
// ----------------------------------------------------------------------------

= day_79_event_1_morning_meeting_no_lisa_cue
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium

9:35 王总监推门。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"**我们这个团队啊, 是有未来的。**"

13 个字。

_第 4 次。_

_他 every 月一次。_

# speaker: wang_director
"David 今天周二上午就交了周报——非常好。"

# speaker: david
David: "嗯。"

# speaker: wang_director
王总监: "我们继续 Q3 启动 plan。"

王总监 **没 cue Lisa**。

他**眼神不扫 Lisa 工位方向**。

他**完全不看 Lisa**——他低头看 PPT。

Lisa 在第一排——她**也没抬头**, 她在记笔记。

_两人 mutual disengage。_

_王总监知道周三签字。今天周二 — 1 天后她不在他的 team。_

_他不需要 cue 她——她已经 mentally 离开他的 OKR list。_

_她也接受了——她在 quiet 收尾。_

# speaker: wang_director
"散会。"

5 分钟。

_5 分钟。S3 末散会 baseline 已经 stable 在 5 分钟。_

// 没有选项 - 王总监 disengage final

~ check_state_after_choice()
-> day_79_after_work


= day_79_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 在 polish self_review。

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
-> day_79_daily_recap


= day_79_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - David 周二上午**早 27 小时交周报** (audition 接位置)_
_  - 晨会**王总监没 cue Lisa** + Lisa 没抬头 (mutual disengage)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_80_morning_briefing


// ============================================================================
// Day 80 · 周三 · ★ 路径 A 玩家专属 Decision Moment 4 ★ + David 主动表扬自己
// ============================================================================
// 关键 beat:
//   - 晨会 David 主动表扬自己"上次那个客户对接 PPT 我做得还可以"——王总监："嗯。"
//   - 路径 A 玩家专属 Decision Moment: 笑天主动跟 Lisa 提"我前公司客户成功部还在招人"
//   - 路径 A 第 4 关键 hero flag (lisa_referred_external)

= day_80_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:25
# weather: cleared

周三。

# scene: meeting_room
# time: 9:25
# npc: lisa_first_row_in_suit_seventeenth_day
# npc: david_with_8_sticky_notes
# npc: lao_zhou_in_back

9:25 到会议室。

Lisa 第一排——第 17 天穿正装。

David 笔记本贴 8 张便利贴 (S3 高峰)。

老周后排。

9:32 王总监推门。

* [开始今日]
    -> day_80_event_1_david_self_praise


// ----------------------------------------------------------------------------
// Event 80.1 · 晨会 David 主动表扬自己 · 9:35
// ----------------------------------------------------------------------------
// 触发: 周三晨会
// 速度: 长 (~10 行)
// 同框: 王总监 + David + Lisa + 老周 + 笑天
// 设计意图: David S6 燃尽 setup 加深 — 他对自己的 KPI burn out, 转向 self-praise
// ----------------------------------------------------------------------------

= day_80_event_1_david_self_praise
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"我们这个月 — 还有 1 周。"

# speaker: wang_director
"deliverable 整体——"

# speaker: david
David **抢话**:

# speaker: david
"王总, 我**自己 evaluate**——上次那个客户对接 PPT 我做得**还可以**。"

15 个字。

他**第一次主动 self-praise 在晨会**。

S2 末他 4 大冲刺 boast。S3 D64 他 145% report。S3 D80 他**直接说自己"做得还可以"**——他从 fact-based 转 evaluation-based。

王总监 0.5 秒。

# speaker: wang_director
"嗯。"

1 个字。

王总监换 PPT 下一张——他**不接 David 的 self-praise**。

David 0.3 秒——他**眼神 fall**——他需要 validation, 王总监没给。

他笑了一下, 回工位。

_David 在 self-evaluate 因为他 burn out evaluating from external sources。_

_他 know 王总监不会再 promote him this 月——王总监 mentally 在 Q3 Lisa 离开后 reorganize。_

_David 在 fill the silence 自己。_

_他在 prep S6 燃尽——他从需要 external validation → 给自己 validation → 然后 burn out。_

_typical S4 燃尽 trajectory。_

# speaker: wang_director
"散会。"

5 分钟。

// 没有选项 - David S6 燃尽 setup 加深

~ check_state_after_choice()
-> day_80_event_2_path_a_referral


// ----------------------------------------------------------------------------
// Event 80.2 · ★ 路径 A 玩家专属 Decision Moment 4 — 跟 Lisa 提前同事跳槽机会 ★
// ----------------------------------------------------------------------------
// 触发: 第 5 个 event (路径 A 玩家专属 = lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive 累计 hero count ≥ 3)
// 速度: 长 (~14 行)
// 同框: Lisa + 笑天
// 设计意图: 路径 A 第 4 关键 hero flag (lisa_referred_external)
// ----------------------------------------------------------------------------

= day_80_event_2_path_a_referral
# scene: workstation_with_lisa_path_a
# time: 16:00
# npc: lisa_at_self_review_v_high

16:00。

{lisa_helped_self_review or lisa_weekend_company or lisa_zoe_feedback_positive:
    -> day_80_path_a_decision
- else:
    -> day_80_no_decision
}


= day_80_path_a_decision
# scene: workstation_path_a
# time: 16:00

如果你 D67 帮过 self_review + D72 给 Zoe 全 5 分 + D75-76 周末陪 — 你 already 是路径 A 玩家。

你 D80 周三 16:00 看 Lisa 在工位敲 self_review。

她周三 6/23 签字 — 如果路径 A, 她周一 starting 客户成功部 (per W总监 D74 phone 透露)。

但她不知道——她不知道 referral 内部已经定。她以为她在 walk 流程。

你想跟她**提**——

# speaker: protagonist
你: "Lisa——"

# speaker: lisa
Lisa 抬头: "嗯?"

* [我前公司客户成功部还在招人]
    # speaker: protagonist
    你: "我**前公司的客户成功部**还在招人, 要不**我帮你 ping 一下**?"
    # speaker: lisa
    Lisa 0.5 秒。
    "诶? 你前公司 — 大厂吗?"
    # speaker: protagonist
    你: "嗯。被裁那家。但他们客户成功部 leader 我还有联系。"
    # speaker: lisa
    Lisa: "**谢谢笑天。**"
    "**我先 try 这边。**"
    # speaker: protagonist
    你: "好。如果不顺利, 你跟我说。"
    # speaker: lisa
    Lisa: "嗯。"
    _她说"我先 try 这边" — 她在 protect referral as backup, 不直接 take。_
    _她 know 你想帮她 — 她接受 your offer, 但她 want internal first 路径 A 转岗成功的 sense of agency。_
    _路径 A 第 4 关键 hero flag locked: lisa_referred_external = true。_
    _S3 hero count + 1 — 这条 flag 不强求 Lisa take 外部 referral, 它表示笑天 effort to help。_
    ~ lisa_referred_external = true
    ~ lisa_score = lisa_score + 5

* [不主动提]
    你站起来去打印机——你没说话。
    Lisa 看你一眼, 回 self_review。
    _你想了想没说——你怕 Lisa 觉得你"觉得她 won't make it 内部"。_
    _你 protect 她 self-confidence。_
    _但路径 A 第 4 hero flag 不 locked。_
    _S3 hero count 仍可以 ≥ 5, 但少 1 个 buffer。_
    ~ lisa_score = lisa_score + 1   // 你 protect 她 self-confidence 仍 +1

* [假装不知道有这种机会]
    # speaker: lisa
    Lisa: "嗯, 怎么了?"
    # speaker: protagonist
    你: "啊没事, 我看你忙。"
    # speaker: lisa
    Lisa: "嗯。"
    _你 detour——你不愿 mention referral。_
    _你担心 Lisa 觉得你已经 give up on her。_
    _或者你不想 commit。_
    ~ lisa_score = lisa_score - 3

-

- _不论选什么。_
- _路径 A 玩家在 D80 16:00 有最后 1 次 hero flag 机会。_
- _即使没 trigger 这个 flag, 路径 A 仍可能 (cumulative hero count ≥ 5)。_
- _但 lisa_referred_external 是 buffer — 让 path A 触发更 resilient。_

// hidden flag: 路径 A Decision 4 - lisa_referred_external = {lisa_referred_external}

~ check_state_after_choice()
-> day_80_after_work


= day_80_no_decision
# scene: workstation_no_path_a_today
# time: 16:00

16:00。你在工位写周报。

你**没**主动跟 Lisa 提任何事。

你 D67 / D72 / D75 没 trigger 足够 hero flag — 你不在路径 A trajectory。

Lisa 周三周四 follow 流程。你也 follow 你的。

_你跟她在同一个工位区, 但 mentally 你们俩已经在不同 trajectory。_

~ check_state_after_choice()
-> day_80_after_work


= day_80_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 在 polish self_review (路径 A polish), 在 改 Word (其他路径 still polish self_review V N).

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
-> day_80_daily_recap


= day_80_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 晨会 **David 主动 self-praise "我做得还可以" 王总监没接** (S6 燃尽 setup 加深)_
{lisa_helped_self_review or lisa_weekend_company or lisa_zoe_feedback_positive:
    _  - ★ 路径 A Decision 4: lisa_referred_external = {lisa_referred_external} ★_
}

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_81_morning_briefing


// ============================================================================
// Day 81 · 周四 · Lisa 工位空了一下午 — 她去 Zoe 那签字了
// ============================================================================
// 关键 beat:
//   - Lisa 工位空了一下午 — 14:00 走出工位 area, 没回来
//   - 笑天看着空工位 4 小时

= day_81_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周四 6/24。**HR 签字日** (per W总监 D74 phone)。

# scene: office_workstation
# time: 9:11
# npc: lisa_at_desk_in_full_suit

9:11 到公司。Lisa **第 18 天穿正装**——今天她**正装外套 + 衬衫 + 黑色裤装** 全套。

她**戴帽子**——黑色棒球帽 (面谈 armor)。

她**桌面摆得整齐**——杯子放整齐, 没奶茶杯, 没文件夹 (在包里)。

她**电脑屏幕开着 self_review final version**。

她**眼睛红**——周二 / 周三晚她可能在哭。今天她戴帽子帽檐压得低。

* [开始今日]
    -> day_81_event_1_lisa_walks_to_zoe_signing


// ----------------------------------------------------------------------------
// Event 81.1 · Lisa 14:00 走出工位 area · 14:00
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 长 (~10 行)
// 同框: Lisa + Zoe (背景, 远端) + 笑天 (看着 Lisa 走)
// ----------------------------------------------------------------------------

= day_81_event_1_lisa_walks_to_zoe_signing
# scene: workstation_with_lisa_packing
# time: 14:00
# npc: lisa_packing_to_walk_out

14:00。

# speaker: zoe
Zoe **没**走过来 cue Lisa。

但 Lisa 自己**站起来**。

她**戴帽子**, **背包 (装 self_review V final)**。

她**没看你**。

她**走出工位 area**——往 HR 走廊方向。

她经过你工位 1 米——

她**说 "笑天, 我先去 Zoe 那签字"**。

11 个字。

她**第一次明确说**——"我先去 Zoe 那签字"。

她没说"去 HR 那边" / "上楼一下"——她说"签字"。

她在 ack 自己 walk away。

她在 prep 我也 ack。

_她在 say goodbye。_

_这是 series 第 1 次 Lisa 直接说"签字"——她以前用"流程" / "review" / "面谈"。_

_今天她直接 explicit。_

* [一会见]
    # speaker: protagonist
    你: "嗯, 一会见。"
    # speaker: lisa
    Lisa: "嗯。"
    她转身走了。
    _你说"一会见" — 你在 protect 她 face。她可能 14:30 回 / 16:00 回 / 永远不回。_
    ~ lisa_score = lisa_score + 1

* [辛苦]
    # speaker: protagonist
    你: "辛苦。"
    # speaker: lisa
    Lisa: "嗯。"
    她转身。
    ~ lisa_score = lisa_score + 0

* [不说话]
    Lisa 没等你 reply, 转身走。
    ~ lisa_score = lisa_score + 0

-

# scene: workstation_lisa_walking_out_again

她走到工位 area 边缘——

她**回头看你 0.5 秒**。

不是 Pillar 4 那种"她不要笑天" 的 0.3 秒。

是**告别**式的 0.5 秒。

她**没笑**——她 hold 不住笑。

她转身, 出了工位 area。

# scene: workstation_lisa_outside_zone

# speaker: zoe
Zoe 在 HR 工位等她。

你看不见她们了。

# scene: xiaotian_alone_4_hours

14:00 → 18:00。

**4 小时**。

Lisa **没回来**。

D67 90 分钟面谈她回了——today 4 小时她没回。

她在 Zoe 那签字 + 走流程 + 接受 transition (路径 A) 或者 walk out (其他路径)。

David 在工位——他**看了 Lisa 工位方向 5 次**。

老周喝茶——他**抬头看 Lisa 工位方向 1 次** (S3 第 3 次抬头)。

_他们都 register 了。_

# scene: workstation_lisa_workstation_empty

18:00 — Lisa **没回**。

她**今天不会回了**。

她包带走 — 她周三留的最后 polish 已经在 self_review final 版。

她现在**在 Zoe 那签完字了**——她**直接走出大楼**。

她**没回工位**说告别——

_她跟我说过"辛苦"了——D81 14:00 那个回头 0.5 秒就是告别。_

_我也 register 了。_

// 没有选项 - 集内最沉默 Lisa 走出工位

// hidden flag: Lisa D81 14:00 走出工位签字 - 没回来

~ state = state - 8

~ check_state_after_choice()
-> day_81_after_work


= day_81_after_work
# scene: workstation_evening
# time: 18:00
# npc: lisa_workstation_empty_today

18:00。Lisa 工位**空着**。

她**带走电脑** (在包里)。

她**带走外套** (今天她穿来的没回工位脱)。

她**没带走小玩偶** —— 还在桌上。

她**没带走奶茶杯** —— 还在桌上。

_她带走 work-essentials, 留下 personal-items。_

_她在让 personal-items remain — 跟工位 keep 一些 connection。_

_或者她周一回来 starting 客户成功部 (路径 A) 时她带走玩偶。_

_或者她不回了 (其他路径), personal-items 由李阿姨周末清理。_

_周日我会知道。_

* [自己回家]
    你出公司大门——18:30。
    ~ state = state + 0

-

~ check_state_after_choice()
# pagebreak
-> day_81_daily_recap


= day_81_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **Lisa 14:00 走出工位 area 去 Zoe 那签字** (4 小时没回) ★_
_  - Lisa 回头看笑天 0.5 秒 (告别式)_
_  - David 看 Lisa 工位方向 5 次 / 老周抬头 1 次_
_  - Lisa 工位**空着** (今天不会回了)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_82_morning_briefing


// ============================================================================
// Day 82 · 周五 · weekly_recap + Lisa 工位空了一整天 — 请假
// ============================================================================
// 关键 beat:
//   - weekly_recap overlay
//   - Lisa 工位空了一整天 — 她请假了

= day_82_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: rainy

周五。下小雨。

~ weather = "rainy"

# scene: office_workstation
# time: 9:08
# npc: lisa_workstation_still_empty

9:08 到公司。

Lisa 工位——

**空着**。

她周四走出去就没回, 周五**也没来**。

她**请假**了——王总监 + Zoe 都 sign-off 了。

她在家——准备周一。

_周一 starting 客户成功部 (路径 A — 跟 W总监 D74 透露的"林姐 OK 周一 starting" 一致) 或者她在家 wrap up 一切 (其他路径)。_

* [开始今日]
    -> day_82_event_1_weekly_recap


// ----------------------------------------------------------------------------
// Event 82.1 · weekly_recap · 16:50
// ----------------------------------------------------------------------------

= day_82_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出周报浮层。

- 出勤率: 100% (你的)
- 主动产出条目: 取决于 D 78-81 选择
- 协作记录: 取决于本周 Lisa 选择

浮层底部："**本月度 KPI 还有 2 天 (周日 6/27 推送月末通报 + S3 finale 5 路径)**"。

_本月度 KPI 还有 2 天。_

_周日 6/27 = E12 D84 = S3 finale + Lisa 走/留 finale。_

// hidden flag: D82 周五 HR 浮层 + 6/27 月末通报 + finale setup

~ check_state_after_choice()
-> day_82_event_2_xiaotian_at_empty_lisa_desk


// ----------------------------------------------------------------------------
// Event 82.2 · 笑天看 Lisa 空工位 · 17:00
// ----------------------------------------------------------------------------
// 触发: 周五下班前
// 速度: 长 (~10 行)
// 同框: Lisa (空工位) + 笑天
// ----------------------------------------------------------------------------

= day_82_event_2_xiaotian_at_empty_lisa_desk
# scene: workstation_with_lisa_empty_friday
# time: 17:00
# npc: lisa_workstation_empty_2nd_day

17:00。你站起来——你想走到 Lisa 工位旁边看看。

她小玩偶**还在** —— 桌上 same place。

她奶茶杯**还在** —— same place, 干掉的奶。

她空眼药水瓶**还在桌角** —— D54 那个。

她椅子**对窗户** —— D54 转过来后她没转回。

_她周四走时把椅子留在"对窗户"——她在 telegraphing 周一她不在屏幕前。_

_她**留下** personal-items + 椅子角度——她在 leaves visual signature。_

_这些 signature 是给 silent witnesses (李阿姨 + 老周 + 我) 的告别。_

_她**没**直接说告别——但工位告别。_

_我看了 1 分钟。_

_我没碰她小玩偶——她可能周一回来 (路径 A) 或者周一李阿姨清理 (其他路径)。_

_我 leave it as it is。_

_silent witness。_

// 没有选项 - 笑天 silent witness moment

~ state = state - 5

~ check_state_after_choice()
-> day_82_after_work


= day_82_after_work
# scene: workstation_evening
# time: 17:30

17:30。你也走人。

* [自己回家]
    你出公司大门。
    ~ state = state + 0

-

~ check_state_after_choice()
# pagebreak
-> day_82_daily_recap


= day_82_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 2 天 (周日 6/27 推送)_

_关键时刻 today:_
_  - HR 浮层 + 6/27 finale setup_
_  - **Lisa 周五请假** (工位空了一整天 — 她在家 prep 周一)_
_  - 笑天看 Lisa 空工位 1 分钟 (silent witness)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_83_weekend_morning


// ============================================================================
// Day 83 · 周六 · 周末
// ============================================================================

= day_83_weekend_morning
# scene: bedroom
# time: 12:00
# music: weekend_silence

你睡到 12:00 醒。

# diegetic_ui: phone_wechat_moments

朋友圈：

David 发"**6 月 final week — 4 大冲刺 final**"。

# speaker: lisa
Lisa **发了 1 条** —— S3 第 3 条 (D42 / D63 之后)。

配图: **空白**。

配文：
**"明天再说。"**

4 个字。

_她周六发"明天再说"。_

_这是 telegraph — 周日 9:30 KPI Review + 12:30 走 / 留揭晓。_

_她在 prep 周日 finale。_

_你 know 周日 finale。她也 know。_

11:34 → 12:34。点外卖 35 块。
~ money = money - 35

* [开始今日]
    -> day_83_event_1_afternoon


= day_83_event_1_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你想给 Lisa 发"明天 9:30 见" — 但你没发。

_她 know 你 know。_

_我们都在 prep silence。_

你又躺了 30 分钟。

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_83_daily_recap


= day_83_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 12:00 起床_
_  - David 朋友圈"6 月 final week"_
_  - **Lisa 朋友圈 "明天再说" + 配图空白** (S3 第 3 条 — telegraph finale)_

# pagebreak
-> day_84_weekend_morning


// ============================================================================
// Day 84 · 周日 · ★ S3 FINALE ★
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈视频 verbatim "那个谁的女儿离职了, 回老家考公务员了" + 笑天关掉视频
//   - 9:30 KPI Review 浮层 + 5 路径 router
//   - 11:00 路径 A 王总监跟林姐 phone "让她过来吧"
//   - 12:30 Lisa 出 HR 工位 (路径 A vs B-E 分叉)
//   - 14:00 路径 A 林姐第一次出现 verbatim "Lisa, 是吧? 跟我去那边坐"
//   - 16:00 路径 B-E Lisa 工位最后一镜
//   - 18:00 笑天回家路上 + Lisa 微信 cliffhanger (5 路径)

= day_84_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日 6/27。

你 8:23 醒。

_S3 finale 日。_

_今天 9:30 KPI Review 浮层。12:30 Lisa 走 / 留揭晓。_

_我不知道我哪条路径 — cumulative_hero_count + lisa_score + sick_count 由系统判。_

_我 know 王总监 D74 phone 透露"林姐 OK 周一 starting" — 但那是路径 A 的 setup，触发 condition 还要看 cumulative 。_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_84_event_1_mom_video_finale


// ----------------------------------------------------------------------------
// Event 84.1 · 妈妈视频 verbatim "那个谁的女儿离职了, 回老家考公务员了" · 8:30
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~14 行)
// 同框: 妈妈 (视频)
// Verbatim: "那个谁的女儿离职了, 回老家考公务员了" 必保留
// 设计意图: thematic mirror — 妈妈不知情说出 Lisa 故事另一版本
// ----------------------------------------------------------------------------

= day_84_event_1_mom_video_finale
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen

屏幕里是妈妈。

# speaker: mama
妈妈："**天天, 吃了吗?**"

# speaker: protagonist
你: "吃了。"

# speaker: mama
妈妈: "**工资发了吗?**"

# speaker: protagonist
你: "发了。"

# speaker: mama
妈妈: "**那个谁的儿子结婚了。**"

# speaker: protagonist
你: "嗯。"

妈妈停了一下。

# speaker: mama
"**那个谁的女儿离职了, 回老家考公务员了。**"

13 个字。

verbatim。

_她**第一次**说"离职"。_

_S2 全季她说"那个谁结婚 / 买房 / 升职" — 都是 milestone 上行。_

_S3 D70 她说"那个谁年薪 60 万" — 还是上行 milestone。_

_S3 D84 她**第一次**说"离职" + "回老家考公务员"——下行 milestone。_

_她不知道 Lisa 今天走 / 留。她不知道 Lisa 这个人。_

_但她说出了 Lisa 故事的另一版本——离开公司, 考公务员, 回老家。_

_这是 thematic mirror。_

_她在 unknowingly narrate Lisa 走 (路径 B-E 的版本)。_

_或者 narrate 笑天 future 的可能性 (S4+ if 我离职)。_

* [嗯, 挺好的]
    # speaker: mama
    妈妈: "嗯。她妈说她在家考了 1 年。"
    "那女孩 28 岁吧?"
    # speaker: protagonist
    你: "嗯。"
    ~ mom_score = mom_score + 0

* [我没那个机会]
    # speaker: mama
    妈妈: "天天, 你也可以回老家啊。"
    "妈这边帮你看着, 不急的。"
    _她直接 invite 你回老家——她第一次 explicit。_
    # speaker: protagonist
    你: "嗯。"
    ~ mom_score = mom_score + 3

* [转移话题]
    # speaker: protagonist
    你: "妈, 你身体怎么样?"
    # speaker: mama
    妈妈: "好多了。"
    "你那边怎么样?"
    # speaker: protagonist
    你: "还行。"
    _你和她都不展开。_
    ~ mom_score = mom_score + 0

-

- _不论选什么。_
- _妈妈"那个谁离职考公务员" — Lisa 故事的另一版本。_
- _Lisa 今天揭晓走/留。但路径 B/C/E 走的话, 她没 公务员 plan, 她可能 just walk。_

# diegetic_ui: phone_video_end_button

视频 6 分钟——比 S1/S2 都短 1-2 分钟。

你**关掉视频**——

# speaker: mama
妈妈: "天天, 妈先——"

你已经按了挂断。

_我比平时挂得早。_

_我今天没心情。_

// hidden flag: 妈妈 D84 verbatim "那个谁的女儿离职了, 回老家考公务员了" + 笑天 6 分钟挂

~ check_state_after_choice()
-> day_84_event_2_kpi_review_overlay


// ----------------------------------------------------------------------------
// Event 84.2 · 9:30 KPI Review 浮层 + 5 路径 router · 9:30 (★ S3 finale 高峰 ★)
// ----------------------------------------------------------------------------
// 触发: 8:30 视频后自动
// 速度: 长 (~16 行)
// 设计意图: cumulative_hero_count 计算 + 路径 router (per round-2 reply §1)
// ----------------------------------------------------------------------------

= day_84_event_2_kpi_review_overlay
# scene: home_phone_kpi_review
# time: 9:30
# diegetic_ui: phone_kpi_review_overlay

9:30。HR 系统浮层弹出。

~ cumulative_hero_count = compute_cumulative_hero_count()

KPI Review 浮层 base layer 如下 (具体路径 specific 文案 router 后 stitches 内补):

- 本月 KPI 累积: {kpi}
- 出勤率: 100%
- 主动产出条目: (取决于累积)
- 加班申报次数: {effort_overage}
- 病倒次数: {sick_count}
- 累积 hero count: {cumulative_hero_count}

system 进入 router——

{
    - sick_count >= 4:
        // 路径 D — 装病摸鱼累积玩家
        # pagebreak
        -> day_84_path_d_sick_finale
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        // 路径 A — 救 Lisa
        # pagebreak
        -> day_84_path_a_lin_jie_save
    - cumulative_hero_count >= 3:
        // 路径 B — 救得不彻底
        # pagebreak
        -> day_84_path_b_lisa_thanks
    - cumulative_hero_count >= 1:
        // 路径 C — 路径分裂
        # pagebreak
        -> day_84_path_c_lisa_silent_walk
    - else:
        // 路径 E — 全程冷处理
        # pagebreak
        -> day_84_path_e_no_one_tells_xiaotian
}


// ============================================================================
// 路径 A — 救 Lisa (转岗客户成功部林姐处)
// ============================================================================
// 触发: cumulative_hero_count ≥ 5 + lisa_score ≥ 25
// 时间链: 11:00 王总监+林姐 phone → 12:30 Lisa 出 HR → 14:00 林姐第一次出现 → 18:00 cliffhanger

= day_84_path_a_lin_jie_save
# scene: home_path_a_morning
# time: 9:30

KPI Review 浮层切到路径 A specific 文案——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}
· 系统评估您的付出度为: 英雄模式
· 下月阈值调整: 100 → **118** (+18%)

· 系统注释:
  "**您本月协助同事完成关键交付。**"
  "**公司认可您的团队精神。**"
  "**下月将给予您更高的责任。**"
  ——这是您的 reward。

═══════════════════════════════════════════

_+18%。_

_3 句"您…公司…下月将…" 都是 HR-speak。_

_"协助同事完成关键交付" — 翻译过来是: 你帮 Lisa 改 self_review + 周末陪 + 给 Zoe 全 5 分 + 提前同事 referral。_

_"公司认可您的团队精神" — 翻译过来是: 公司知道你 sacrifice 自己时间帮 Lisa。_

_"下月将给予您更高的责任" — 翻译过来是: 下月 KPI threshold +18%——你帮 Lisa 的 reward 是更大的处刑。_

_anti-Pillar 1 极致。_

_我救了 Lisa, 系统给我 +18%。_

_这是 series 第一次 anti-Pillar 1 完整 cycle 显形——做对了 = 下月更难 = 反 KPI 系统咬人。_

# scene: home_path_a_kpi_review_then_zoe_announcement
# time: 11:00

11:00。你打开 work groupchat——

# speaker: zoe
Zoe 群里发: "@所有人 本月度 KPI 通报已发各位邮箱, 详情请查阅。"

# speaker: zoe
"另: **Lisa 同学下周一起调岗至客户成功部, 跟林姐继续合作**。Lisa 同学辛苦了 12 周, 感谢她对 product team 的贡献。"

5 分钟后—— 群里 1 条新消息。

# speaker: wang_director
王总监: "**林姐**, 让 Lisa 周一 9:00 直接到您那。"

3 秒后王总监补 1 条:

# speaker: lin_jie
**林姐**: "**让她过来吧。**"

verbatim。

5 个字。

林姐 first appearance—— 群里, 不在场 visible。

她直接 confirm。

_这是 series 第一次林姐 dialog——但是在场外, 通过群消息。_

_她 5 字 — efficient。她跟 Zoe 的"陈笑天先生" 形成对照。_

_她不需要 ceremony。_

_S3 outline §3.6 林姐"让她过来吧" verbatim — 必保留。_

# scene: home_path_a_xiaotian_observes
# time: 12:30
# diegetic_ui: phone_path_a_lisa_message

12:30。Lisa 微信 1 条。

# speaker: lisa
Lisa: "笑天, 我刚走出 HR 工位。Zoe 跟我谈完了。"

# speaker: lisa
"林姐 14:00 来接我去她那边坐。"

# speaker: lisa
"**谢谢笑天**。"

# speaker: lisa
"我下午 2 点见到她, 我跟你说她什么样。"

3 个 statements + 1 个 sentiment + 1 个 promise。

她**主动 share**。

她**没说**"我留下了" / "成功了" / "万岁"——她说"林姐来接我"——pure logistics。

她在 maintain understatement。

她**没庆祝**——她接受 transition 是 walking from one mode to another, not a "win"。

* [恭喜]
    # speaker: protagonist
    你: "恭喜!"
    # speaker: lisa
    Lisa: "嗯。还没 confirm 全程, 周一才 starting。"
    # speaker: protagonist
    你: "嗯, 别 jinx。"
    # speaker: lisa
    Lisa: "哈哈。"
    _她笑了——不深, 但是真心。_
    ~ lisa_score = lisa_score + 5

* [辛苦了]
    # speaker: protagonist
    你: "辛苦了 12 周。"
    # speaker: lisa
    Lisa: "嗯。**真的谢谢你**。"
    _她"真的谢谢你" — series 第 2 次"谢谢笑天" (D75 第 1 次)。_
    ~ lisa_score = lisa_score + 8

* [挺好的]
    # speaker: protagonist
    你: "挺好的。"
    # speaker: lisa
    Lisa: "嗯。"
    ~ lisa_score = lisa_score + 1

-

# scene: home_path_a_14h
# time: 14:00
# diegetic_ui: phone_lisa_video_call_or_chat

14:00。

# speaker: lisa
Lisa **没视频**你——她没 picture 直接 share 林姐——但她**发了 1 张照片**。

# diegetic_ui: phone_path_a_lin_jie_distant_photo

照片: **从 Lisa 工位看出去** — 隔壁部门区域, **林姐站在那** — 黑色西装 + 运动鞋, 红色文件夹在她手里。

她没看 camera。她在跟另一个客户成功部同事说话。

_这是 series 第一次林姐 visible 在 屏幕上 (虽然只是远端照片)——她 deliberate restraint 12 周后第 1 次。_

_她身上 visual 全 match npcs.md §10——黑色西装 + 运动鞋 + 红色文件夹。_

_她确实"另一种活法"——她不在 product team 那种"穿正装 + 戴帽子" pattern。她 office wear + comfortable shoes。_

_她不卷, 她 efficient。_

# speaker: lisa
Lisa: "笑天, 我马上跟她去她那边坐。"

# speaker: lisa
Lisa: "她跟我说'**Lisa, 是吧? 跟我去那边坐**'——她**叫我不带姓**。"

11 个字 verbatim。

她转述的是林姐的话——但她加了一句"她叫我不带姓"。

_这是 Pillar 4 关键 evidence——林姐叫"Lisa"不带姓, 跟 Zoe 的"陈笑天先生" / "Lisa 同学" 形成对照。_

_"另一种活法存在"——但她这条人才 reach。_

_我没 reach。_

_我留在 product team。_

_我下月 +18% threshold。_

_我看着 Lisa 走到 林姐那边。_

# scene: home_path_a_18h
# time: 18:00
# diegetic_ui: phone_path_a_xiaotian_returning_home

18:00。你出门——你周日今天没出门 (除了去公司的 D76 周六, 路径 A 玩家可能也 D77 没出门)。你今天 18:00 出门买饭。

街上有点风。

_S3 finale 第 1 个 path complete。_

_我帮 Lisa 走了路径 A。_

_她周一 starting 客户成功部跟林姐。_

_她不会再 in product team。_

_我下月 +18% threshold。_

_我没 happy。但我也不"扎心" 那种 collapsed 程度——_

_我做了我能做的。她接受了。她 live 了。_

_我下月 carry +18%。_

_这是 anti-Pillar 1 + Pillar 3 + Pillar 4 的合奏:_

_anti-Pillar 1 — 救了 Lisa = +18% 处刑。_

_Pillar 3 — 没有"赢"。_

_Pillar 4 — 林姐"另一种活法" 存在 但她不要笑天。_

# scene: home_path_a_evening
# time: 19:00
# diegetic_ui: phone_path_a_wang_kpi_review_message

19:00。你回家。

王总监微信 1 条 (跨 group 的 1 对 1)。

# speaker: wang_director
王总监: "**小笑啊…陈天啊…你最近表现不错。下个月看你的。**"

15 个字 verbatim。

(per S3 outline §3.3 verbatim — 必保留)

_他用 muscle memory "小笑啊…陈天啊"——他到 12 周末还叫不准。_

_"你最近表现不错"——这是 anti-Pillar 1 perfect setup: 我帮 Lisa 改 self_review 的 KPI 是 -5 (per D67), 我从 KPI 角度其实表现不"不错"。_

_他评价"不错" 是因为 cumulative hero behavior 让他 register "可 promote candidate"——_

_"下个月看你的"——series-structure §4.5 promotion 警告 setup 启动。_

_我下月 KPI threshold +18% + 我可能进 promotion candidate list。_

_promotion = 处刑 (per series-structure §6 终极 GO)。_

_我现在的 trajectory:_

_+18% 这个月 → 也许 cumulative > 150 → 进 promotion 候选 → 月度面谈 → "你做得真好下个月看你的" → S10 promotion 警告 → S12 终极 GO。_

_我救 Lisa 把自己 set 在 GO trajectory。_

_anti-Pillar 1 完整 expose。_

# scene: home_path_a_lisa_final_message
# time: 21:00
# diegetic_ui: phone_path_a_lisa_message_sunday_evening

21:00。Lisa 微信 1 条 (S3→S4 cliffhanger):

# speaker: lisa
"**笑天, 我下个月开始去隔壁部门了。我妈说挺好。**"

# speaker: protagonist
你: "好。"

# speaker: lisa
Lisa: "嗯。"

# speaker: lisa
"周一公司见。"

3 个 statement + 1 个 confirmation + 1 个 logistics。

她**没说"再见"** 也**没说"谢谢"**——她说"周一见"。

她**回到 baseline 工作日** language。

_她在 transition 完成——她不需要再"谢谢"。她 starting on Monday。_

_我**留在 product team**——下个月 +18%。_

_她在隔壁部门——她不再 reportable 给王总监 / Zoe。她在林姐那边。_

_我们俩**仍同公司**——但不同 trajectory。_

_S4 第 1 集 Lisa 工位换人——新人是个 24 岁男生。_

_笑天看着新人坐下时, 回想 12 周前自己的第一天。_

// hidden flag: 路径 A finale - lisa_helped_after_hr / lisa_helped_self_review / lisa_weekend_company / lisa_zoe_feedback_positive / lisa_referred_external 累积成 hero ≥ 5
// hidden flag: 王总监 promotion candidate setup 启动 (D84 19:00 verbatim)

~ promotion_candidate_count = promotion_candidate_count + 1

~ check_state_after_choice()
# pagebreak
-> day_84_finale_recap


// ============================================================================
// 路径 B — 救得不彻底 (cumulative_hero_count 3-4)
// ============================================================================

= day_84_path_b_lisa_thanks
# scene: home_path_b_morning
# time: 9:30

KPI Review 浮层路径 B specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}
· 系统评估您的付出度为: 标准达标
· 下月阈值调整: 100 → **105** (+5%)

· 系统注释: "继续保持。"

═══════════════════════════════════════════

_+5%——standard 3 month rate, S1 / S2 finale 同档。_

_我帮了一些 hero behavior 但不够 5 个 flag。_

_Lisa 走 — 我没 keep 住 her。_

# scene: home_path_b_groupchat
# time: 11:00
# diegetic_ui: phone_path_b_zoe_announcement

11:00。Zoe 群里:

# speaker: zoe
Zoe: "@所有人 本月度 KPI 通报已发各位邮箱。"

# speaker: zoe
"另: **Lisa 同学今日离职**, 感谢她过去 12 周的工作。我们祝她未来工作顺利。"

无林姐 mention。

无客户成功部 mention。

Lisa **走**了——没 referral, 没转岗, 直接离职。

# scene: home_path_b_lisa_message
# time: 12:30

12:30。Lisa 微信 1 条:

# speaker: lisa
"**笑天, 谢谢你这两个月。**"

7 个字。

# speaker: protagonist

* [对不起]
    你回: "对不起, 我没帮上更多。"
    # speaker: lisa
    Lisa: "嗯, 没事。"
    "你已经做得很好了。"
    _她在 protect you — 你 already did "enough" by her measure._
    ~ lisa_score = lisa_score + 1

* [辛苦了]
    你回: "辛苦了 12 周。"
    # speaker: lisa
    Lisa: "嗯。"
    ~ lisa_score = lisa_score + 0

* [保重]
    你回: "保重。"
    # speaker: lisa
    Lisa: "嗯。"
    "你也是。"
    ~ lisa_score = lisa_score + 0

-

# scene: home_path_b_lisa_circle_post
# time: 18:00
# diegetic_ui: phone_path_b_lisa_circle

18:00。Lisa 朋友圈最后一条:

# speaker: lisa
配文: "**开启新阶段。**"

配图: 一杯咖啡 (在某个 cafe)。

_4 个字。1 张图。_

_她在新公司发的——或者她 search 中。_

_她在 prep 自己的 transition 给外人看——不是给 product team 看的。_

_S4 第 1 集 Lisa 朋友圈最后一条"开启新阶段"——她在新公司发——这一条会是 S5+ 朋友圈偶尔出现的 last anchor。_

# scene: home_path_b_evening_quiet
# time: 21:00

21:00。

你刷手机——

# diegetic_ui: phone_path_b_quiet_evening

朋友圈无新消息。

Lisa 状态: 空白 (跟过去 8 周一致)。

_她 transitioning。_

_我下月 +5%。_

_我没赢。_

_她也没赢。_

_我们俩 part ways——standard 3 月走 1 茬 baseline (per 李阿姨 D68 verbatim)。_

// hidden flag: 路径 B finale - 救得不彻底

~ check_state_after_choice()
# pagebreak
-> day_84_finale_recap


// ============================================================================
// 路径 C — 路径分裂 (cumulative_hero_count 1-2)
// ============================================================================

= day_84_path_c_lisa_silent_walk
# scene: home_path_c_morning
# time: 9:30

KPI Review 浮层路径 C specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}
· 系统评估您的付出度为: 险过
· 下月阈值调整: 100 → **105** (+5%)

· 系统注释: "勉勉强强。"

═══════════════════════════════════════════

_系统注释 4 个字。比路径 B "继续保持" 还短 1 字。_

_+5% 仍涨。_

_Lisa 走 — 你没接到她的告别。_

# scene: home_path_c_quiet
# time: 12:30

12:30。

# speaker: zoe
Zoe 群里 announcement: "Lisa 同学今日离职, 感谢她过去 12 周的工作。"

你刷微信——

# speaker: lisa
Lisa **没微信**你。

她**没朋友圈**告别。

她**没主动 contact** 你。

12 周累积 — D77 你 not 周末陪 + D80 你 not 提前同事 — 她已经 mute 你。

她周日不发——直接 walk。

# scene: home_path_c_xiaotian_message_attempt
# time: 18:00

18:00。

* [发"保重"]
    你发: "Lisa, 保重。"
    20 分钟后 Lisa 回: "嗯。"
    1 个字。
    _她接收了你的"保重"——但她没展开。_
    ~ lisa_score = lisa_score + 0

* [不发]
    你**没发** anything 给 Lisa。
    Lisa 也没发给你。
    ~ lisa_score = lisa_score + 0

-

# scene: home_path_c_evening_silence
# time: 21:00

21:00。

# speaker: lisa
Lisa 朋友圈最后一条仍是 D63 "也好我自己也想换换"——

她**没发新的告别**朋友圈。

或者她发了**仅你不可见**——她已经分组屏蔽你。

S4 第 1 集你刷 Lisa 朋友圈分组——**你被屏蔽了**。

// hidden flag: 路径 C finale - Lisa 没说再见 + S4 笑天发现被屏蔽

~ check_state_after_choice()
# pagebreak
-> day_84_finale_recap


// ============================================================================
// 路径 D — 装病 + 摸鱼 (sick_count >= 4)
// ============================================================================

= day_84_path_d_sick_finale
# scene: home_path_d_morning
# time: 9:30

KPI Review 浮层路径 D specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}
· 系统评估您的付出度为: 装病摸鱼
· 下月阈值调整: 100 → **103** (+3%)

· 系统注释: "您看起来不太对。"

═══════════════════════════════════════════

_系统说"您看起来不太对"——HR-speak euphemism, 委婉提示 medical leave 累积超 cap warning。_

_+3%——你最 mild 涨。_

_但你 D70 周日 4 次 sick_count 累积——你身体 burn down。_

_今天周日你**头疼 + 发烧** — 你**真的病了**。_

_Lisa 走 — 但你**没看到**。_

# scene: home_path_d_bed
# time: 12:30
# music: silence

12:30。你在床上——头疼。

你**没刷微信**。

你**不知道**今天是周日。

你**不知道** Lisa 走了。

你**不知道** Zoe 群里 announcement。

你 just **sleep**。

# scene: home_path_d_late_evening
# time: 21:00

21:00。

你终于醒——你 fever 退了。

你刷手机——

# speaker: zoe
Zoe 群里 announcement: "Lisa 同学今日离职。"

# speaker: lisa
Lisa 微信也有 1 条 (10:00 发的, 你没看):

# speaker: lisa
"笑天?"

# speaker: lisa
"你在吗?"

# speaker: lisa
"我下午走啊。"

她**等了 1 小时** — 你没回。

11:00 她又发: "嗯, 你忙吧。"

12:00 — Lisa 走了。

你 21:00 看到 — **9 小时延迟**。

你回:

* [Lisa, 对不起, 我今天发烧]
    # speaker: protagonist
    你: "Lisa, 对不起, 我今天发烧。"
    20 分钟后 Lisa 回: "嗯, 你好好养病。"
    ~ lisa_score = lisa_score + 1

* [不回 (continue sleep)]
    你**没回** Lisa。
    你又睡了。
    ~ lisa_score = lisa_score - 3

-

_S4 第 1 集你周一回公司发现 Lisa 工位空了——你**不知道她哪天走的**。_

_你 missed the goodbye。_

// hidden flag: 路径 D finale - 笑天发烧 + 9 小时延迟回 Lisa
// 注: sick_count 在 routing 时已经 ≥ 4 — 不需在 finale 内增

~ check_state_after_choice()
# pagebreak
-> day_84_finale_recap


// ============================================================================
// 路径 E — 全程冷处理 (cumulative_hero_count = 0)
// ============================================================================

= day_84_path_e_no_one_tells_xiaotian
# scene: home_path_e_morning
# time: 9:30

KPI Review 浮层路径 E specific——

═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积: {kpi}
· 系统评估您的付出度为: 全程摸鱼
· 下月阈值调整: 100 → **101** (+1%)

· 系统注释: ()

═══════════════════════════════════════════

_系统注释空白——你最 invisible。_

_+1% — 你最轻松, 但 Lisa 你也最 invisible to。_

# scene: home_path_e_quiet_morning
# time: 11:00

11:00。

# speaker: zoe
Zoe 群里: "@所有人 Lisa 同学今日离职。"

你看了——

你**没 react**——你 12 周已经 mute 自己 emotionally。

# scene: home_path_e_no_messages
# time: 18:00

18:00。

# speaker: lisa
Lisa **没微信**你——她已经 mute 你 6 周。

她**没朋友圈**——她屏蔽你或者她没发。

S4 第 1 集你回公司——

# speaker: vivian
Vivian 在打卡台。你过去打卡。

# speaker: protagonist
你: "Lisa 呢?"

# speaker: vivian
Vivian: "嗨～**她上周走了。**"

7 个字。

她**笑了一下**——她平时的"嗨～" 笑。

她**continue 跟下一个员工**: "嗨～来啦～"

_她说"上周走了"——你 register 了 Lisa 离开。_

_你回工位——Lisa 工位换了人。_

_24 岁男生 — 跟 D77 的 cliffhanger 一致 (per S3 outline §3.1 path E)。_

_你看着新人坐下 — 你 12 周前的 stand-in。_

_你 12 周 mute Lisa——她 mute 你——你 mute 自己——series 内 no one 注意到 mutuality_。

# scene: home_path_e_evening
# time: 21:00

21:00。

你刷手机——

朋友圈无新消息。

你设了 Lisa 状态查询——状态: **空白**。

她**仍是空白**。

她可能仍是 active 微信 user, 可能不是。你不会 follow up。

S4 第 1 集你看 Vivian 告诉你"她上周走了"。

// hidden flag: 路径 E finale - 笑天后知后觉 + Pillar 3 极致 (Lisa 不存在的版本)

~ check_state_after_choice()
# pagebreak
-> day_84_finale_recap


// ============================================================================
// daily_recap · Day 84 周日日报 (E12 末 / S3 finale 末) — 跨路径 collector
// ============================================================================

= day_84_finale_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_finale_recap


_今日 KPI: +0_
_今日 状态: {state}/100_

_关键时刻 today (E12 finale):_
_  - 8:30 妈妈视频 verbatim "**那个谁的女儿离职了, 回老家考公务员了**" (thematic mirror)_
_  - 9:30 KPI Review 浮层 + 5 路径 router_

{
    - sick_count >= 4:
        _  - 路径 D: 笑天周日发烧 — Lisa 走没看到 (9 小时延迟回)_
        _  - 系统评估"装病摸鱼" + 下月 +3%_
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        _  - ★ 路径 A: Lisa 转岗客户成功部林姐处 ★_
        _  - 11:00 群里 王总监 + 林姐 verbatim "让她过来吧"_
        _  - 14:00 林姐第一次出现 (远端照片) verbatim "Lisa, 是吧? 跟我去那边坐"_
        _  - 19:00 王总监 verbatim "小笑啊…陈天啊…你最近表现不错。下个月看你的"_
        _  - 系统评估"英雄模式" + 下月 +18% (anti-Pillar 1 极致)_
        _  - promotion candidate setup 启动 (S10 promotion 警告 trajectory)_
    - cumulative_hero_count >= 3:
        _  - 路径 B: Lisa 走 + 朋友圈"开启新阶段"_
        _  - 系统评估"标准达标" + 下月 +5%_
    - cumulative_hero_count >= 1:
        _  - 路径 C: Lisa 没微信告别 (S4 笑天发现被屏蔽)_
        _  - 系统评估"险过" + 下月 +5%_
    - else:
        _  - 路径 E: Vivian "嗨～她上周走了" (笑天后知后觉)_
        _  - 系统评估"全程摸鱼" + 下月 +1%_
}

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_S3 hero flag 累积:_
_  - lisa_helped_pps (S1): {lisa_helped_pps}_
_  - lisa_helped_after_hr (S2): {lisa_helped_after_hr}_
_  - lisa_helped_self_review (S3 D67): {lisa_helped_self_review}_
_  - lisa_weekend_company (S3 D75-76): {lisa_weekend_company}_
_  - lisa_zoe_feedback_positive (S3 D72): {lisa_zoe_feedback_positive}_
_  - lisa_referred_external (S3 D80): {lisa_referred_external}_
_  - cumulative_hero_count: {cumulative_hero_count} / 6_

_S3 末 累积 flags:_
_  - 病倒次数: {sick_count}_
_  - effort_overage: {effort_overage}_
_  - promotion_candidate_count: {promotion_candidate_count}_

// ----------------------------------------------------------------------------
// Series Cliffhanger 至 S4
// ----------------------------------------------------------------------------
// S4 第 1 集 (E13) 开局:
//   - 路径 A: Lisa 工位换人 (24 岁男生) - 笑天看着新人坐下回想 12 周前自己第一天
//   - 路径 B: Lisa 朋友圈"开启新阶段" - S5+ 偶尔出现
//   - 路径 C: 笑天发现被 Lisa 朋友圈屏蔽
//   - 路径 D: 笑天周一回公司发现 Lisa 工位空 - 不知她哪天走
//   - 路径 E: 笑天问 Vivian "Lisa 呢" Vivian "嗨～她上周走了"
//
// S4 主题: David 燃尽前兆 (per series-structure §2)
// S4 ink writer 写 episode-13/14/15/16.ink

// E12 / S3 结束

-> END

// ============================================================================
// EOF episode-12.ink
// ============================================================================
//
// 分身 task summary (S3 ink writer R1 - finale):
//   - Day 78-83 normal beats (D78 草莓周 / D78 食堂 / D79 王总监 disengage / D80 路径 A Decision /
//     D81 Lisa 14:00 走出 / D82 Lisa 周五请假 / D83 Lisa 朋友圈"明天再说")
//   - Day 84 5 路径 router (cumulative_hero_count + sick_count + lisa_score 决定)
//   - 5 path stitch chains (A 最长, B-E 短)
//   - compute_cumulative_hero_count() function defined
//   - 5 verbatim quotes:
//     - 妈妈"那个谁的女儿离职了, 回老家考公务员了" (D84 8:30)
//     - 林姐"让她过来吧" (D84 11:00 群消息, 路径 A)
//     - 林姐"Lisa, 是吧? 跟我去那边坐" (D84 14:00 转述, 路径 A)
//     - 王总监"小笑啊…陈天啊…你最近表现不错。下个月看你的" (D84 19:00, 路径 A)
//     - KPI Review 浮层 路径 A "您本月协助同事完成关键交付。公司认可您的团队精神。下月将给予您更高的责任。"
//
// 笑/泪比 = 2:8 (per season-3-arc.md §1):
//   - 笑点: D78 草莓周 ironic mirror / D79 王总监 disengage 反讽 / D84 妈妈"那个谁离职考公务员"
//   - 扎点: D78 Lisa 文件夹移走 / D81 Lisa 14:00 走出 4 小时没回 / D82 Lisa 请假 +
//          D84 KPI Review 5 路径都"扎" (A=+18% 处刑 / B=Lisa 走 / C=分裂 / D=missed / E=后知后觉)
//
// 红线 (S3 不能做):
//   - Lisa 走/留必须由 累积 决定 ✓ (compute_cumulative_hero_count + sick_count router)
//   - 玩家不能 "赢" ✓ (路径 A +18% threshold = 处刑)
//   - 路径 A 没 happy ending UI ✓ (Lisa 微信 transition language, 没庆祝)
//   - 路径 B-E Lisa 都走 ✓
//   - 林姐 deliberate restraint ✓ (D84 11:00 群消息 + 14:00 远端照片, 全程不直接对笑天说话)
//   - 林姐"不要笑天" ✓ (没看 camera, 没跟笑天 message)
//   - HR-speak / PUA 直接抄 ✓ (KPI Review 浮层 verbatim "团队精神 / 更高的责任")
//
// END
