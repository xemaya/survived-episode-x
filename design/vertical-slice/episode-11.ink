// ============================================================================
// Episode 11 · Week 11 · 「我自己一个人有点慌」
// ============================================================================
//
// Status: 第 1 版 (S3 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S3 Round 1)
// Last Updated: 2026-05-06
//
// 配套 reference: 同 episode-1.ink
// 主 spec: design/vertical-slice/season-3-arc.md §5 E11 beat sheet
//        + season-3-arc-round-2-reply.md addenda
//
// 设计目标 (摘要):
//   1. 路径分叉点 — Decision Moment 2 决定 E12 finale 落在哪条路径
//   2. Decision 1 (D72): Zoe 协作反馈 (路径 A 第 3 关键 hero flag lisa_zoe_feedback_positive)
//   3. Decision 2 (D75): 周末加班陪不陪 (路径 A 第 2 关键 hero flag lisa_weekend_company)
//   4. 王总监 C Vulnerability layer 3 — D74 19:30 偷听"你跟 Zoe 说一下吧, 下周三签字"
//   5. Lisa S1 motif "加油" 复活 (D71)
//   6. Lisa 第一次主动晨会发言 — 失败 (David 截胡, 王总监没接)
//   7. 3:7 笑变少 — 周末路径分叉
//
// 红线 (S3 不能做):
//   - Lisa 不能决定走/留 (E12 finale)
//   - 王总监不能直接对 Lisa "你不适合" (Zoe 工作)
//   - 老周 S3 0 dialog
//   - 林姐 S3 不出场
//   - David S3 不燃尽
//   - 玩家不能在 S3 finale 之前"赢"
//
// Verbatim quotes 必保留:
//   - E11 周四: 王总监"**你跟 Zoe 说一下吧, 下周三签字**" (笑天偷听)
//   - E11 周五: Lisa "**明天来公司加班吗? 我自己一个人有点慌**" (路径分叉点)
//   - E11 周日 cliffhanger: Lisa "**笑天, 下周可能就出结果了。不管怎样, 谢谢你**" (S3 第 1 次"谢谢你")
//
// ============================================================================

INCLUDE episode-1.ink

// E11 entry
-> episode_11


// ============================================================================
// Episode 11 主入口
// ============================================================================

=== episode_11 ===
# scene: home
# time: monday_morning_week_11
# pagebreak
-> day_71_morning_briefing


// ============================================================================
// Day 71 · 周一 · ★ Lisa S1 motif "加油" 复活 + Lisa 第一次主动晨会发言失败 ★
// ============================================================================
// 关键 beat:
//   - Lisa 左手手心又开始写"加油" (S1 motif 复活, 比 S1 频繁)
//   - 周一晨会 Lisa 第一次主动发言"我这个 PPT 还差一些数据, 下周交"
//   - 王总监没接 → David 立即接话"我这周可以帮 cover" 王总监："好"

= day_71_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared

闹钟响了 1 次。

_S3 第 3 周。Lisa 周日发"你别担心 + 我自己想想看怎么办"。_

_她在 walking away — 但她还没走。_

_HR 6/10 周三签字 = 今天周一 6/14? 错——今天周一 6/14 = E11 第 11 周第 1 天。_

_Wait, 6/10 周三签字 — 那是 6/10 = 上周三 = E10 D66。但 D66 outline 没说签字 happened。_

_我可能 misremember 时间表。_

_我听到 Zoe D60 (E9 周四) 说"下周三签字" = 6/10 周三 = E10 D66 周三。_

_E10 D66 周三晨会王总监 cue Lisa "PPT 怎么样" Lisa "在赶" — Lisa 那天还没去 HR signed。_

_所以"签字" delayed。 HR 流程在 reschedule。_

_或者 Zoe 说的"下周三" 是 from D60 的 reference frame, 而 D60 是周四, "下周三" 不是 6/10 而是 6/16 (1 周后) 或更晚。_

_我不知道时间表 exactly。_

_但 Lisa 不知道, 她只知道周四 14:00 90 分钟面谈是已发生事件。_

_她在 prep 第二次面谈或者 contracting walk。_

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:14 到公司。

# speaker: vivian
Vivian: "嗨～来啦～"

水果盘**苹果** — 苹果周连续 11 周。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_71_event_1_lisa_jiayou_revived


// ----------------------------------------------------------------------------
// Event 71.1 · Lisa 左手手心又开始写"加油" · 9:25 (★ S1 motif 复活 ★)
// ----------------------------------------------------------------------------
// 触发: 进入工位区
// 速度: 长 (~10 行)
// 同框: Lisa (前景, 写"加油") + 笑天
// NPC archetype: Lisa motif 复活 — 但比 S1 更频繁 (开会前都写)
// ----------------------------------------------------------------------------

= day_71_event_1_lisa_jiayou_revived
# scene: workstation_entry_with_lisa_writing
# time: 9:25
# npc: lisa_writing_in_left_palm

你走到工位区。

A 区——Lisa 工位斜对角。

你看了一眼——

Lisa 在工位。她**穿正装外套** (第 11 天连续, 但这周她带帽子 every day, 不只周四)。

她的**左手在桌下**——你瞥到她拿笔。

她**在左手手心写字**。

她写完, 把笔放下, 把左手攥起。

_S1 E2 D10 周三晨会王总监讲"潜力" 时, Lisa 桌下手心写"加油"——她的小自我激励。_

_S2 全 8 周她不写。S3 D59 也不写。_

_S3 D71 第 11 周第 1 天 周一**早上 9:25** 她写——**晨会前 5 分钟**。_

_她不再是"晨会前写"——她是"工作日开始前写"。_

_她的写"加油" 频率从 S1 的"被 push 时" 升级到 S3 的"open 工位时"。_

_她需要每天 baseline 写 1 次"加油"。_

_她在 self-fortify。_

# scene: workstation_xiaotian_observes

她抬头看你 — 0.5 秒。

她**没笑**——她以前看你会笑。今天她直接低头继续敲键盘。

_她的笑也不再 default。_

_她在 save energy。_

// 没有选项 - quiet sign 升级 (motif 复活)

// hidden flag: Lisa D71 motif "加油" 复活 - S3 第 1 次, 比 S1 频繁

~ check_state_after_choice()
-> day_71_event_2_morning_meeting_lisa_initiative


// ----------------------------------------------------------------------------
// Event 71.2 · 晨会 Lisa 第一次主动发言失败 · 9:35
// ----------------------------------------------------------------------------
// 触发: 周一晨会 (S3 第 3 周月初的 1 场)
// 速度: 长 (~14 行)
// 同框: 王总监 + David + Lisa + 老周 + 笑天
// 设计意图: Lisa 最后一搏的尝试 — 失败
// ----------------------------------------------------------------------------

= day_71_event_2_morning_meeting_lisa_initiative
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium
# npc: lisa_first_row_in_suit_with_hat
# npc: david_with_6_sticky_notes
# npc: lao_zhou_in_back

9:35 王总监推门。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"S3 第 3 周——离月底 13 天。"

# speaker: wang_director
"David 这边 deliverable 100% 完成。"

# speaker: david
David: "嗯。"

# speaker: wang_director
王总监: "Lisa——"

王总监 0.3 秒——他要 say "你这边怎么样" 吗?

但 Lisa **抢话**——

# speaker: lisa
Lisa: "**我这个 PPT 还差一些数据。下周交。**"

13 个字。

她**第一次主动晨会发言**。

S1 4 周她从不主动。S2 8 周她从不主动。

S3 D71 第 11 周周一她**主动**——她在 try 重启 KPI 工作的 visibility。

王总监 0.5 秒。

他**没接**。

他没说"好" / "嗯" / "下周哪天" / "需要 cover 吗"。

他**沉默 0.5 秒**。

然后——

# speaker: david
David: "**王总, 我这周可以帮 cover Lisa 那边的数据收集。**"

David **截胡**——他在王总监 register Lisa 之前接话。

# speaker: wang_director
王总监: "**好。**"

1 个字。

王总监换 PPT 下一张。

会议室里——

Lisa **没看 David**。她**直接低头**记笔记。

她没说"谢谢 David" / "不用了" / "我自己来"。

她**接受了**——她的主动发言被 silent + David 截胡 cover 替代了。

_她最后一搏的尝试。_

_失败。_

_她想用主动发言 reset 她在 KPI 工作的位置——但王总监 silent 0.5 秒, David 截胡, 王总监"好" 1 字 confirm David 截胡。_

_3 步 within 1.5 秒 把 Lisa 的初始 push 转成 "David help Lisa"。_

_这个会议不再关于 Lisa 的 PPT, 它关于 David 的"帮人"。_

_Lisa 的主动 silence 等于她接受这个 reframe。_

_David 的"帮 cover" 是 power move——他在 prep 接 Lisa 的位置 (when she leaves)。_

# speaker: wang_director
王总监: "散会。"

5 分钟。

5 分钟散会比 D66 还快。

_他在 efficiency. 他要 save 时间给 backstage 1v1 prep。_

// 没有选项 - Lisa 最后一搏失败

// hidden flag: Lisa D71 第一次主动晨会发言被 David 截胡 - 最后一搏失败

~ check_state_after_choice()
-> day_71_after_work


= day_71_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_at_word_doc

17:30。Lisa 在工位敲 Word — 不是 PPT。

她"PPT 还差数据下周交" 是给 David 的 cover story — 她真的在改 self_review V3 / V4。

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
-> day_71_daily_recap


= day_71_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **Lisa 左手手心又开始写"加油"** (S1 motif 复活, 比 S1 频繁)_
_  - ★ **晨会 Lisa 第一次主动发言**"我这个 PPT 还差一些数据, 下周交" — **王总监没接 + David 截胡 cover**_
_  - Lisa 最后一搏失败_
_  - 5 分钟散会 (王总监在 save 时间给 backstage)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_72_morning_briefing


// ============================================================================
// Day 72 · 周二 · ★ Decision Moment 1 — Zoe 协作反馈 (路径 A 第 3 关键 hero flag) ★
// ============================================================================
// 关键 beat:
//   - Zoe 路过笑天工位"陈笑天先生，关于上次月度面谈的协作反馈，您方便补充一下吗？"
//   - Decision Moment 3 选 1: A 帮 Lisa 美化 / B 中性 / C 客观差
//   - 路径 A → flag lisa_zoe_feedback_positive = true (S3 hero count +1)

= day_72_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_workstation
# time: 9:11
# npc: lisa_at_desk_in_suit_again

9:11 到公司。Lisa **第 12 天穿正装**, 在 Word doc。

* [开始今日]
    -> day_72_event_1_zoe_feedback_request


// ----------------------------------------------------------------------------
// Event 72.1 · Zoe 找笑天补充协作反馈 · 14:00 (★ Decision Moment 1 ★)
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 长 (~12 行)
// 同框: Zoe + 笑天
// 设计意图: 路径 A 第 3 关键 hero flag - Zoe 给笑天 last chance 影响 Lisa 评估
// ----------------------------------------------------------------------------

= day_72_event_1_zoe_feedback_request
# scene: workstation_with_zoe_arriving_at_xiaotian
# time: 14:00
# npc: zoe_in_black_jacket_with_clipboard

14:00。

# speaker: zoe
Zoe 走过来——她走到**你**工位旁, 不是 Lisa 工位。

# speaker: zoe
"陈笑天先生, 关于上次月度面谈的协作反馈, 您方便补充一下吗?"

_她说"补充" — 不是新做。_

_Zoe S2 D44 已经找过我 5 分钟收集了 1 次。_

_今天她 follow up — 她在 finalize HR review file。_

_这次她要的是 last-touch input。_

# speaker: protagonist
你: "嗯, 现在?"

# speaker: zoe
Zoe: "嗯, 5 分钟够了。"

她拿出文件夹, 翻到 Lisa 那一页。

# speaker: zoe
Zoe: "我这边有 Lisa 同学过去 12 周的协作记录。您觉得在以下几个 dimension 上她的表现如何——"

# speaker: zoe
"**主动产出 / 协作意愿 / 抗压能力 / 学习速度**。"

4 个 HR 标准 dimension。

她递给你**评分表**——5 分制, 1 = 不达标, 3 = 标准, 5 = 卓越。

她用笔等你说数字。

* [全 5 分 (路径 A 第 3 关键 flag)]
    # speaker: protagonist
    你: "她全 5 分。"
    # speaker: zoe
    Zoe 0.5 秒。
    "**真的吗? 这是高分。**"
    # speaker: protagonist
    你: "Lisa 主动 / 协作 / 抗压 / 学习速度都很好——她是我合作过最 reliable 的同事。"
    # speaker: zoe
    Zoe: "好的。" 她记下来 5/5/5/5。
    "我会 reflect 在 review file 上。"
    _她的语气是 neutral, 但她"真的吗" 的 0.5 秒 pause 是 signal——她知道你在 advocacy。_
    _但她记下了。_
    _Zoe 不会改 HR 流程, 但她会在 review file 加 1 行 "协作伙伴评 5/5/5/5"。_
    _这进 Lisa 的 file. 这影响下周 HR 高层 review when 评估"是否给客户成功部 referral"。_
    _路径 A 第 3 关键 hero flag locked。_
    ~ lisa_zoe_feedback_positive = true
    ~ lisa_score = lisa_score + 5
    ~ zoe_score = zoe_score + 1
    // S3 hero count +1

* [3 分 (中性)]
    # speaker: protagonist
    你: "嗯, 中等吧。3 分。"
    # speaker: zoe
    Zoe: "全 3 分?"
    # speaker: protagonist
    你: "嗯。她做得 OK, 没有 outstanding 也没问题。"
    # speaker: zoe
    Zoe: "好的。" 她记下来 3/3/3/3。
    _她记 baseline。Lisa 不会因为你 boost 也不会因为你 hurt。_
    ~ lisa_score = lisa_score + 0
    ~ zoe_score = zoe_score + 0

* [客观评 (有低分)]
    # speaker: protagonist
    你: "她主动 4 分, 协作 4 分, 抗压**3 分**, 学习速度 4 分。"
    # speaker: zoe
    Zoe: "为什么抗压 3 分?"
    # speaker: protagonist
    你: "她最近 PPT 改太多版, 我观察到她有点 overworked。"
    # speaker: zoe
    Zoe 0.5 秒沉默。
    "好。" 她记下来 4/4/3/4。
    _她记的"抗压 3 分" 在 HR file 是 negative signal。_
    _你"客观评" — 但 HR 不需要 truth, HR 需要 file 里有"reason to deny" 的句柄。_
    _你给了她。_
    _Lisa 的 file 现在有"协作伙伴 flag her 抗压 3 分"——这是 HR 内部 escalate 的"reason"。_
    _你想客观, 你伤了她。_
    ~ lisa_score = lisa_score - 3
    ~ zoe_score = zoe_score + 2   // Zoe 喜欢"客观" 的 reviewer

-

- _不论选什么。_
- _Zoe 走开后你 stare 屏幕 30 秒。_
- _你给她 5/5/5/5 — 你 advocacy。_
- _你给她 3/3/3/3 — 你 neutral。_
- _你给她 4/4/3/4 — 你 honest 但是给 HR 弹药。_
- _3 种都对。3 种都有 cost。_
- _HR 系统不在乎 truth, 在乎 file 上的 line items。你 line item 怎么填决定 Lisa 的下一步。_

// hidden flag: Decision Moment 1 D72 - Zoe 协作反馈 lisa_zoe_feedback_positive = {lisa_zoe_feedback_positive}

~ check_state_after_choice()
-> day_72_event_2_lisa_doesnt_know


// ----------------------------------------------------------------------------
// Event 72.2 · Lisa 不知道 Zoe 找过笑天 · 16:00
// ----------------------------------------------------------------------------
// 触发: 第 6 个 event
// 速度: 闪 (~3 行)
// 同框: Lisa (背景) + 笑天
// ----------------------------------------------------------------------------

= day_72_event_2_lisa_doesnt_know
# scene: workstation_with_lisa_typing
# time: 16:00
# npc: lisa_typing_unaware

16:00。Lisa 在工位敲 Word。

她**不知道** Zoe 中午找过你给她评分。

她不会问。

_她在 process 自己的事 - 她每天 hold 自己, 没 capacity follow 他人对她的影响。_

_今天我 affect 她的 file, 她不知道。_

_我们俩在 silent collaboration——但她不知道我在 collaborate。_

// 没有选项

~ check_state_after_choice()
-> day_72_after_work


= day_72_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在 Word。

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
-> day_72_daily_recap


= day_72_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **Decision Moment 1: Zoe 协作反馈** lisa_zoe_feedback_positive = {lisa_zoe_feedback_positive}_
_  - 笑天 affect Lisa 的 HR file (她不知道)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_73_morning_briefing


// ============================================================================
// Day 73 · 周三 · 晨会"我们这个团队啊" + David 周四晚加班看 Lisa 工位
// ============================================================================
// 关键 beat:
//   - 晨会王总监讲"我们这个团队啊, 是有未来的"
//   - David 周四晚加班到 22:00, 离开前回头看 Lisa 工位一眼

= day_73_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:25
# weather: cleared

周三。

# scene: meeting_room
# time: 9:25
# npc: lisa_first_row_in_suit_with_hat
# npc: david_with_7_sticky_notes
# npc: lao_zhou_in_back

9:25 到会议室。

Lisa 第一排, 正装外套, 戴帽子。

David 笔记本贴 7 张便利贴 ("Q3 启动 plan" / "客户对接 V5" / "月底冲刺" / "本周 deliverable" / "Lisa cover 数据" / "晨会发言要点" / "下周 prep")。

7 张是他 record 高峰。

老周后排, 中间那杯茶。

9:32 王总监推门。

* [开始今日]
    -> day_73_event_1_morning_meeting_unity


// ----------------------------------------------------------------------------
// Event 73.1 · 晨会"我们这个团队啊, 是有未来的" · 9:35
// ----------------------------------------------------------------------------

= day_73_event_1_morning_meeting_unity
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"**我们这个团队啊, 是有未来的。**"

13 个字。

_他每月 1 次开场。_

_S1 4 次。S2 4 次。S3 第 3 次。_

_今天他换了——不是"命运共同体" 也不是"团队凝聚力", 是"是有未来的"。_

_"是有未来的" 比"命运共同体" 加 1 度未来感, 但**省略**了"我们"。_

_S2 末他 reframe "我们这个月辛苦了"——drop "团队"。_

_S3 D73 他 reframe "团队是有未来的"——drop "我们"。_

_他在 reduce his own commitment to the team—— 他知道 9 月他被换的可能性 (per series macro S9)。_

_他在 prep 自己 walk away 的话术。_

# speaker: wang_director
"David cover 数据顺利吗?"

# speaker: david
David: "顺利。"

# speaker: wang_director
"Lisa 这边 PPT 下周交吧?"

# speaker: lisa
Lisa: "嗯。"

王总监**没看 Lisa**——他低头看 PPT。

# speaker: wang_director
"散会。"

5 分钟。

_5 分钟。第 3 周连续 ≤ 6 分钟。_

_王总监在 efficiency 加速。_

// 没有选项 - 王总监 escapism

~ check_state_after_choice()
-> day_73_event_2_david_22_evening


// ----------------------------------------------------------------------------
// Event 73.2 · David 周四晚 22:00 加班 + 回头看 Lisa 工位 · 22:00
// ----------------------------------------------------------------------------
// 触发: 申报加班 (周三延伸到周四晚, 笑天看到)
// 速度: 标准 (~7 行)
// 同框: David + Lisa (背景, 工位空) + 笑天 (远端)
// 设计意图: David 在 prep "Lisa 走 = 我位置调整" 的 mental contingency
// ----------------------------------------------------------------------------

= day_73_event_2_david_22_evening
# scene: office_after_hours_22h
# time: 22:00
# npc: david_packing_late

如果你今天申报了加班——

~ state = state - 10
~ kpi = kpi + 5
~ effort_overage = effort_overage + 1

22:00。你打算走了。

David 也在收东西——他**周四晚加班到 22:00**。

S2 末他 17:30 准点走 (他周一对 Q3 prep)。S3 D73 周三他 22:00 — 他在 try 给王总监看"我比 Lisa 努力"。

他把 Lisa 工位上的"David cover 数据" 那张表 deliverable 发出去——他用了 8 分钟。

他**站起来**, 拿包, 转身——

走到工位 area 边缘, 他**回头**。

他**看了 Lisa 工位一眼**。

Lisa 工位空——她 21:00 走的。

他**0.5 秒**——他在 visualize Lisa 工位空 long term。

他没说话, 转身走了。

_他在 prep 接 Lisa 位置的 mental contingency。_

_他想知道她什么时候走。_

_他不在乎她 emotionally。_

_他在 logistics。_

// 没有选项 - David S6 燃尽 setup deepening

// hidden flag: David D73 22:00 加班离开前回头看 Lisa 工位 - 接位置 prep

~ check_state_after_choice()
-> day_73_after_work


= day_73_after_work
# scene: workstation_evening
# time: 22:05

22:05。你也走人。

* [继续走]
    工位区灯还亮着 1 个 (你的) — 关掉灯走。
    ~ state = state - 0   // 已计入 22:00 决策

-

~ check_state_after_choice()
# pagebreak
-> day_73_daily_recap


= day_73_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 晨会"**我们这个团队啊, 是有未来的**" (王总监 reframe escapism)_
_  - David 22:00 加班 + 回头看 Lisa 工位 (接位置 prep)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_74_morning_briefing


// ============================================================================
// Day 74 · 周四 · ★ 王总监 C Vulnerability layer 3 — 19:30 偷听 ★
// ============================================================================
// 关键 beat:
//   - 19:30 笑天加班路过王总监独立办公室
//   - 听到他打电话 verbatim "你跟 Zoe 说一下吧, 下周三签字"
//   - 王总监 C Vulnerability layer 3 — 他在执行命令, 自己也是 puppet

= day_74_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周四。

# scene: office_workstation
# time: 9:11
# npc: lisa_in_suit_jacket_thirteenth_day

9:11 到公司。Lisa 第 13 天穿正装。

她**自评 V5** 屏幕开着——她在 polish (如果你 D67 帮她改, 她在 polish your version; 否则她在自己改第 N 版)。

* [开始今日]
    -> day_74_event_1_wang_phone_call


// ----------------------------------------------------------------------------
// Event 74.1 · 19:30 王总监独立办公室电话 verbatim · 19:30 (★ 王总监 C Vulnerability layer 3 ★)
// ----------------------------------------------------------------------------
// 触发: 申报加班后晚上
// 速度: 长 (~14 行)
// 同框: 王总监 (独立办公室门关, 笑天偷听)
// Verbatim: "你跟 Zoe 说一下吧, 下周三签字" 必保留
// ----------------------------------------------------------------------------

= day_74_event_1_wang_phone_call
# scene: office_after_hours_corridor
# time: 19:30
# npc: wang_in_solo_office_on_phone

如果你今天申报了加班——

~ state = state - 10
~ kpi = kpi + 5
~ effort_overage = effort_overage + 1

19:30。大部分人都走了。

你去 16 楼茶水间接水。

你接完水回来的路上经过王总监独立办公室——

门关着。但**有声音从门缝漏出来**。

你停下来听了 5 秒。

# speaker: wang_director
王总监在打电话——不是大声, 是商务电话的中音量。

# speaker: wang_director
"…对……对……"

# speaker: wang_director
"…那边的话……我了解……嗯。"

5 秒间隔。他在听对方说话。

然后:

# speaker: wang_director
"嗯, 我看下。"

# speaker: wang_director
"**你跟 Zoe 说一下吧, 下周三签字。**"

13 个字。

# speaker: wang_director
"客户成功部那边？嗯, 林姐已经 OK 了, 周一 starting。"

电话挂了。

你听到他放手机的声音。

你**赶紧走开**——你不能让他知道你听到了。

_"你跟 Zoe 说一下吧, 下周三签字"。_

_S2 末王总监电话"让她做好心理准备"。_

_S3 D74 王总监电话"下周三签字"。_

_S2 是 prep心理。S3 是 schedule confirmed。_

_"客户成功部 + 林姐 OK 周一 starting" — 这是路径 A 转岗预案 (per S3 outline)。_

_但**只有 cumulative_hero_count ≥ 5 + lisa_score ≥ 25** 触发——其他路径王总监不会 push 这个安排。_

_这次电话里他 push 了——意味着 HR 已经 prep 路径 A 这个 option。_

_周一 starting = 下下周一 = 6/21。_

_今天 6/17 周四。 4 天后 Lisa 可能去客户成功部 starting。_

_或者她 walk 流程, 6/21 离职。_

_这取决于路径 (cumulative_hero_count)。_

_我不能告诉 Lisa。_

_告诉她 = 她可能 try 影响, 可能崩, 可能 escalate。_

_无论怎样, 我吃亏。_

_我成了 silent witness 第 3 个 (李阿姨 + 老周 + 我) 第 2 周 confirm。_

_他也只是在打电话。_

_但他打的是 Lisa 的电话。_

// 没有选项 - 王总监 C Vulnerability layer 3 verbatim

// hidden flag: 王总监 D74 verbatim "你跟 Zoe 说一下吧, 下周三签字" + 林姐 OK 周一 starting

~ check_state_after_choice()
-> day_74_after_work


= day_74_after_work
# scene: workstation_evening
# time: 19:35

19:35。你回工位拿包。

Lisa 工位空——她 19:00 已经走 (周四她带帽子走)。

* [继续走]
    你出公司大门。
    ~ lisa_score = lisa_score + 0

-

~ check_state_after_choice()
# pagebreak
-> day_74_daily_recap


= day_74_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **19:30 王总监电话 verbatim "你跟 Zoe 说一下吧, 下周三签字"** (王总监 C Vulnerability layer 3)_
_  - 王总监透露 "客户成功部 + 林姐 OK 周一 starting" (路径 A setup)_
_  - 笑天确认时间表: 6/24 周三签字 + 6/28 周一 Lisa starting (路径 A) / 离职 (其他路径)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_75_morning_briefing


// ============================================================================
// Day 75 · 周五 · weekly_recap + ★ Decision Moment 2 — 周末加班陪不陪 (路径分叉点) ★
// ============================================================================
// 关键 beat:
//   - weekly_recap overlay
//   - Lisa 19:30 还在工位
//   - 21:00 Lisa 微信 verbatim "明天来公司加班吗? 我自己一个人有点慌"
//   - Decision Moment 2 — 这是路径分叉点 (路径 A 第 2 关键 hero flag)

= day_75_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared

周五。

# scene: office_workstation
# time: 9:08
# npc: lisa_in_suit_jacket_fourteenth_day

9:08 到公司。Lisa 第 14 天穿正装。

她**没戴帽子**——周五她头发自然下垂。她精心 pre-curl 过——为了周末。

_周末她可能去面试。或者 prep 客户成功部。_

* [开始今日]
    -> day_75_event_1_weekly_recap


// ----------------------------------------------------------------------------
// Event 75.1 · weekly_recap · 16:50
// ----------------------------------------------------------------------------

= day_75_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出周报浮层。

- 出勤率: 100%
- 主动产出条目: 取决于 D 71-74 选择
- 协作记录: 取决于本周 Lisa / David 选择

浮层底部："**本月度 KPI 还有 12 天 (周日 6/27 推送月末通报)**"。

_本月度 KPI 还有 12 天。_

_周日 6/27 月末 + S3 finale = 下下周日 (E12 D84)。_

_今天 6/18 周五。 9 天后 Lisa 离开。_

// hidden flag: D75 周五 HR 浮层 + 6/27 月末通报 setup

~ check_state_after_choice()
-> day_75_event_2_lisa_19_30_again


// ----------------------------------------------------------------------------
// Event 75.2 · Lisa 19:30 还在工位 · 19:30
// ----------------------------------------------------------------------------

= day_75_event_2_lisa_19_30_again
# scene: workstation_late_friday
# time: 19:30
# npc: lisa_at_self_review

如果你今天申报加班——

~ state = state - 5

19:30。Lisa **还在**。

她屏幕开着——self_review V8 (路径 A: 你帮她改的 V1 → V2 → V3 → V8 polish; 其他路径: 她自己改的 V8)。

她在 polish 同一份——她已经 12 天每天加班改这份 self_review。

_她不再改 PPT。_

_她改的是给 HR 高层 review 的 self_review。_

_她 prep 6/24 周三签字时给 HR 高层一份 polished self_review。_

_这是她最后的 fight — 她想在 review file 留下 best impression。_

# speaker: lisa
她抬头看你 — 0.5 秒。

她**没说"明天见"** —— 她平时周五会说。

她转回工位。

_她在 save energy。_

// 没有选项 - quiet sign

~ check_state_after_choice()
-> day_75_event_3_lisa_message_helpless


// ----------------------------------------------------------------------------
// Event 75.3 · ★ 21:00 Lisa 微信 verbatim "明天来公司加班吗? 我自己一个人有点慌" ★ (★ Decision Moment 2 ★)
// ----------------------------------------------------------------------------
// 触发: 晚 21:00 自动
// 速度: 长 (~14 行)
// 同框: Lisa (微信)
// 设计意图: 路径分叉点 — 这是 E12 finale 路径 A 第 2 关键 hero flag (lisa_weekend_company)
// Verbatim: "明天来公司加班吗? 我自己一个人有点慌" 必保留
// ----------------------------------------------------------------------------

= day_75_event_3_lisa_message_helpless
# scene: home_evening
# time: 21:00
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:00。你刚回家。

微信消息 1 条。

# speaker: lisa
Lisa：

# speaker: lisa
"笑天"

# speaker: lisa
"**明天来公司加班吗? 我自己一个人有点慌。**"

13 个字。

_她从来不主动说"慌"。_

_她平时用"忙" / "在赶" / "改 PPT" — 都是 task-language。_

_今天她说"慌" — 这是 emotion-language。_

_她终于直接 expose emotion。_

_她说"我自己一个人有点慌" — 她在请求 company。_

_她不要"帮改 PPT" / "帮看 self_review"。_

_她要"陪她"——physically 在旁边。_

_这是 series 第一次她对我用 emotion-language ask。_

_S1 她说"我感觉我可能不太适合"——self-deprecate emotion。_

_S2 她说"我可能要走"——decision emotion。_

_S3 她说"有点慌"——vulnerable emotion。_

_她在 walking down emotional ladder。_

_她在 prep walk away 同时在 max ask 一次"陪"。_

# scene: phone_decision_screen

* [好啊我也去 (路径 A 第 2 关键 hero flag)]
    # speaker: protagonist
    你回: "好啊我也去。明天几点?"
    # speaker: lisa
    Lisa 1 分钟没回。
    然后: "9 点？"
    # speaker: protagonist
    你: "好。"
    # speaker: lisa
    Lisa: "嗯。**谢谢笑天。**"
    _她说"谢谢笑天" — 第一次。_
    _S1-S3 共 12 周她从未说过"谢谢笑天"——只说过"嗯" / "明天见" / "辛苦"。_
    _今天她说"谢谢"。_
    _你周六 9:00 去公司——你陪她改 self_review V9 / 看着她 walk through HR file 一次。_
    _你周末状态 -10。_
    _路径 A 第 2 关键 hero flag locked: lisa_weekend_company = true。_
    ~ lisa_score = lisa_score + 12
    ~ effort_overage = effort_overage + 1
    ~ state = state - 10
    ~ lisa_weekend_company = true
    // S3 hero count +1

* [我那天有点事]
    # speaker: protagonist
    你回: "明天我那天有点事, 不行哈。"
    # speaker: lisa
    Lisa 1 分钟没回。
    然后: "嗯没事, 你忙你的。"
    _她说"没事" 但她在 disappoint。她不会 push 你。_
    _你周六待在家 — state +30 baseline。_
    _Lisa 周六一个人在公司。_
    _S3 hero count 不 +1。_
    ~ lisa_score = lisa_score - 3

* [不回]
    你看了消息, 没回。
    # speaker: lisa
    Lisa 没追问。
    _她可能 11:00 还在等你回, 但你睡着。_
    _周六 9:00 她一个人去公司, 她在工位 8 小时, 没等你 — 她已经知道。_
    _S3 hero count 不 +1。**lisa_abandoned_at_weekend flag locked**——影响 E12 路径 C/E 推力。_
    ~ lisa_score = lisa_score - 8
    ~ lisa_abandoned_at_weekend = true

-

- _不论选什么。_
- _她说"我自己一个人有点慌" 是 series-wide emotion 高峰。_
- _她不再 ask for "改 PPT" — 她 ask for "company"。_
- _你给或不给 company, 决定 E12 finale 的路径分叉权重。_
- _路径 A 第 2 关键 hero flag in this Decision。_

// hidden flag: ★ Decision Moment 2 ★ - lisa_weekend_company = {lisa_weekend_company}
// hidden flag: lisa_abandoned_at_weekend = {lisa_abandoned_at_weekend}

~ check_state_after_choice()
# pagebreak
-> day_75_daily_recap


= day_75_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 12 天 (周日 6/27 推送)_

_关键时刻 today:_
_  - HR 浮层 + 6/27 月末通报 setup_
_  - Lisa 19:30 还在改 self_review V8_
_  - ★ **21:00 Lisa 微信 verbatim "明天来公司加班吗? 我自己一个人有点慌"** ★_
_  - ★ **Decision Moment 2 (路径分叉点)**: lisa_weekend_company = {lisa_weekend_company} / lisa_abandoned_at_weekend = {lisa_abandoned_at_weekend} ★_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_76_weekend_morning


// ============================================================================
// Day 76 · 周六 · 周末 (路径 A 玩家去公司 / 其他路径在家)
// ============================================================================

= day_76_weekend_morning
# scene: bedroom
# time: morning
# music: weekend_silence

{lisa_weekend_company:
    -> day_76_path_a_company
    - else:
    -> day_76_other_paths_home
}


// ----------------------------------------------------------------------------
// 路径 A: 周六去公司陪 Lisa
// ----------------------------------------------------------------------------

= day_76_path_a_company
# scene: bedroom_alarm
# time: 7:00
# music: monday_drone

7:00 闹钟响——你比平时周六早 5 小时。

_我答应 9 点到公司。我要 7:30 出门。_

你刷牙, 出门, 地铁——周六早晨 8 点的地铁人**比工作日少 60%**。

# scene: subway_carriage_weekend
# time: 8:00

地铁电视播"本月经济运行情况" — 你不听。

你在想 Lisa 周六的状态。

_她 D75 21:00 发"我自己一个人有点慌"——她周六会怎样? 焦躁 / 平静 / 沉默?_

# scene: office_entrance_weekend
# time: 8:55
# prop: office_entrance_quiet

8:55 到公司。

Vivian 不在 (周六前台不上班)。

你刷工牌进——大堂 quiet。

# scene: workstation_weekend
# npc: lisa_already_at_desk_in_polo
# prop: lisa_workstation_with_two_phones

Lisa **已经在工位**——她**8:30 就到了**。

她**穿 polo** (灰色 polo) — 她**不再穿正装外套**。

_她周六不演给王总监看。她回 baseline polo。_

她桌上**摆着两台手机** —— 她自己的 + 一台你不认识的 (可能是工作手机, 或者朋友的备用机)。

她在改 self_review。

# speaker: lisa
Lisa 抬头: "诶, 笑天。"

# speaker: protagonist
你: "诶, 早。"

# speaker: lisa
Lisa: "你坐这。"

她指了 旁边那个空工位 (是 IT 小马的, 周末他不在)。

你坐下。

她 **没继续说话** — 她转回 self_review。

但她的 body language 松了一档——她肩膀不像周一-周五那么 tight。

_她需要 company, 不需要对话。_

_她 isolated 太久了 — 周末有人坐旁边, 她可以喘。_

# scene: workstation_weekend_long_session
# time: 9:00_to_18:30

9:00 — 18:30。

你跟她在工位 9.5 小时。

期间——

10:30 你给她接了 1 杯水。

12:00 你点外卖 — 你给她也点了一份 (¥35)。
~ money = money - 35

14:00 她抬头说 "笑天, 你帮我看下这一段?" — 她主动请你 review 一段 self_review。

你看了, 给了 1 个 suggestion。她改了。

15:30 她说 "笑天, 我想睡 5 分钟"——她趴在桌上睡了 7 分钟。

你 silent 守着——没人会进来 (周六公司没人)。

17:00 她醒了, 继续敲。

18:30 她说 "笑天, 你回吧, 我再改 1 小时。"

# speaker: protagonist
你: "嗯, 那你别太晚。"

# speaker: lisa
Lisa: "嗯。**谢谢你今天**。"

8 个字。

她 0.5 秒沉默。

# speaker: lisa
"我自己一个人撑不过这周末的。"

10 个字。

_她直接 ack。_

_她周六过来 = save 自己 — 跟"陪"等同。_

_你周六 9.5 小时 = 路径 A 第 2 关键 hero flag locked。_

_她对你的 trust gradient 在 max。_

# scene: corridor_back

你出公司大门——18:35。

街上有点风。

_S3 第 11 周第 6 天的周六我陪 Lisa 9.5 小时。_

_她不会走 the 路径 B-E 了 — 她已经决定 try save herself, 我已经决定陪。_

_E12 finale 5 路径里我们走 A。_

_但 A 的 reward 是 +18% threshold — 我下个月最累。_

_我没赢。我陪了。_

~ state = state - 10

~ check_state_after_choice()
-> day_76_event_after_company


// ----------------------------------------------------------------------------
// 其他路径: 周六在家
// ----------------------------------------------------------------------------

= day_76_other_paths_home
# scene: bedroom
# time: 12:08
# music: weekend_silence

你睡到 12:08 醒。

# diegetic_ui: phone_wechat_check

你看微信——

# speaker: lisa
Lisa **没消息**。

她周五 21:00 发"我自己一个人有点慌" 后 没再发。

如果 你 D75 选 "我那天有点事" — 她已经 register 你不去, 她周六自己去公司。

如果你不回 — 她周六 9:00 自己去公司, 她不再 chase 你。

你留在床上。

朋友圈：

David 发"**6 月第 3 周 + 4 大冲刺**"——他还在 spinning。

Lisa 没发新的。

你点外卖 35 块。
~ money = money - 35

你下午躺床上 4 小时。

~ state = state + 30   // regenForRestDay

~ check_state_after_choice()
-> day_76_event_after_home


= day_76_event_after_company
~ check_state_after_choice()
# pagebreak
-> day_76_daily_recap


= day_76_event_after_home
~ check_state_after_choice()
# pagebreak
-> day_76_daily_recap


= day_76_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100_

_关键时刻 today:_
{lisa_weekend_company:
    _  - ★ 路径 A: 周六去公司陪 Lisa 9.5 小时 (lisa_weekend_company = true) ★_
    _  - Lisa "我自己一个人撑不过这周末的" (trust gradient max)_
    - else:
    _  - 周末在家 11/12:00 起床 (D75 选项决定 lisa_score 推力)_
    _  - Lisa 周六自己去公司 (你不知道她在 doing what)_
}

# pagebreak
-> day_77_weekend_morning


// ============================================================================
// Day 77 · 周日 · 妈妈视频 + ★ E11→E12 cliffhanger Lisa "不管怎样, 谢谢你" ★
// ============================================================================
// 路径分支 (按 lisa_score / lisa_weekend_company / sick_count):
//   - 路径 A/B (lisa_weekend_company OR lisa_score ≥ +5): Lisa 周日加班 / 笑天周日加班 → 8:30 妈妈"我累" → cliffhanger
//   - 路径 C (lisa_score 0-+5 + cumulative hero ≤ 2): 11 点起床 → 妈妈普通 → 笑天 21:00 Lisa 没消息
//   - 路径 D (sick_count >= 2): 11 点起床 → 装病前兆 → 妈妈视频关摄像头
//   - 路径 E (lisa_score < -5 OR lisa_abandoned_at_weekend): 11 点起床 → 笑天没在意

= day_77_weekend_morning
# scene: bedroom
# time: morning_branch
# music: sunday_morning_quiet

{lisa_weekend_company or (lisa_score >= 5):
    -> day_77_path_ab_morning
    - else:
    {lisa_abandoned_at_weekend:
        -> day_77_path_e_morning
        - else:
        {sick_count >= 2:
            -> day_77_path_d_morning
            - else:
            -> day_77_path_c_morning
        }
    }
}


// ----------------------------------------------------------------------------
// 路径 A/B: 周日加班 + 妈妈"我累" + 8:30 视频后 21:30 cliffhanger
// ----------------------------------------------------------------------------

= day_77_path_ab_morning
# scene: bedroom_morning_quiet
# time: 8:23
# music: sunday_morning_quiet

周日。你 8:23 醒。

_周六我陪 Lisa 9.5 小时 (路径 A) 或者周六我没去但 Lisa 还想我 (路径 B)。_

_今天 8:30 妈妈视频。_

8:30:00 整, 微信视频铃响。

# speaker: mama
妈妈："**天天, 妈这周身体有点不舒服, 没事就是有点累。**"

# speaker: protagonist
你 0.5 秒——

_妈最近老说"累"。她从来不说"我累" 是因为有事——她说"累" 是因为想拉我回去。_

# speaker: mama
妈妈接着说: "**没事不用回来啊我自己能照顾自己。**"

11 个字。

_她说"没事不用回来" 是反话——她是 hope 我回。_

_但她不会直接 ask。_

_她在 build 第 2 个 ladder——上周"年薪 60 万", 这周"我累"。_

_她每周加 1 个 pressure point。_

_我不能回——我答应 Lisa 周末陪 (路径 A) 或者我已经 emotionally exhausted (路径 B)。_

* [回家看你妈]
    # speaker: protagonist
    你: "妈, 下个月端午我回。"
    # speaker: mama
    妈妈: "嗯, 端午是吧, 6 月底。"
    "好, 妈包粽子等你。"
    _她的语气松了。_
    ~ mom_score = mom_score + 5

* [我下个月端午回]
    # speaker: mama
    妈妈: "好好好。"
    _她"好好好" 3 次——她 register 但她在 doubt 你会真回。_
    "你工作忙的话不回也可以哈。"
    ~ mom_score = mom_score + 2

* [我下周也忙]
    # speaker: mama
    妈妈: "嗯, 妈知道。"
    _她"嗯" 0.5 秒 — fragile。_
    ~ mom_score = mom_score - 2

-

# scene: workstation_path_ab
# time: 12:00

12:00 — 路径 A 玩家: 你周六去过公司, 周日继续在家 rest。
路径 B 玩家: 你也在家, 但你周六没去。

你点外卖 35 块。
~ money = money - 35

# diegetic_ui: phone_wechat_lisa_status

下午 14:00 你看 Lisa 微信状态——

# speaker: lisa
Lisa 状态: "在公司"。

_路径 A: 她周六我陪了, 她周日还在 prep。_
_路径 B: 她周日还在 try, 但她没让我去。_

_她在 prep 6/24 周三签字。_

_她最后 prep 也救不回 trajectory — 时间表已定。但她在 try。_

~ state = state + 20

~ check_state_after_choice()
-> day_77_path_ab_evening


= day_77_path_ab_evening
# scene: home_evening
# time: 21:30
# diegetic_ui: phone_wechat_notification

21:30。你刚洗完澡。

微信消息 1 条。

# speaker: lisa
Lisa：

# speaker: lisa
"**笑天, 下周可能就出结果了。**"

# speaker: lisa
"**不管怎样, 谢谢你。**"

13 个字 + 8 个字。

_她说"不管怎样"。_

_她在 prep walking away——她 already know 结果可能两种 (路径 A 转岗 / 路径 B 走), 但她对我"谢谢你"。_

_这是 series 第 1 次 Lisa 用"谢谢你"。_

_S1-S3 共 12 周, 她对笑天用过 "嗯" / "明天见" / "辛苦" / "你别担心"。_

_今天她**告别**式地用"谢谢你"。_

_这是 anti-Pillar 4: 她在 say goodbye。_

* [我也谢谢你]
    # speaker: protagonist
    你回: "我也谢谢你。"
    # speaker: lisa
    Lisa: "嗯。"
    _她"嗯" 0.5 秒——她 receive 你的"谢谢"。_
    "晚安。"
    ~ lisa_score = lisa_score + 3

* [还没出结果别说谢]
    # speaker: protagonist
    你回: "还没出结果, 你别这么说。"
    # speaker: lisa
    Lisa: "嗯。"
    "好。晚安。"
    _她接了你的 reframe — 她 cheer up 0.3 度。_
    ~ lisa_score = lisa_score + 1

* [嗯]
    # speaker: lisa
    Lisa: "嗯。"
    "晚安。"
    _你的"嗯" 跟她"嗯" pair off。_
    ~ lisa_score = lisa_score + 0

-

- _不论选什么。_
- _她周日 21:30 用"谢谢你" 告别。_
- _她下周一去 HR 那边, 周三签字。_
- _她已经 ack 自己要走。_

// hidden flag: E11 → E12 cliffhanger - Lisa verbatim "笑天, 下周可能就出结果了。不管怎样, 谢谢你"

~ check_state_after_choice()
# pagebreak
-> day_77_daily_recap


// ----------------------------------------------------------------------------
// 路径 C: lisa_score 中等 + 周末没陪 — Lisa 没主动联系笑天
// ----------------------------------------------------------------------------

= day_77_path_c_morning
# scene: bedroom_morning_normal
# time: 11:00
# music: weekend_silence

你睡到 11:00 醒。

8:30 妈妈视频——你接了。

# speaker: mama
妈妈普通版 "天天吃了吗" / "工资发了吗" / "那个谁结婚了"。

# speaker: mama
"那个谁的儿子升职加薪了。"

# speaker: protagonist
你: "嗯。"

视频 8 分钟结束。

下午你点外卖 35 块。
~ money = money - 35

你下午刷手机——

# diegetic_ui: phone_wechat_lisa_status

下午 21:00 你看 Lisa 微信状态——

# speaker: lisa
Lisa 状态: 空白 (跟周三一致, 没变)。

她**没发微信**给你。

# speaker: lisa
她朋友圈也没发新的。

_她周六我没去陪她。_

_她周日没主动找我。_

_我们俩**互相 distance** 了。_

_她可能去过公司, 可能没去, 我不知道。_

_E11→E12 cliffhanger 路径 C: Lisa 没微信告别。_

~ state = state + 20

// hidden flag: 路径 C - Lisa 没主动 cliffhanger 微信

~ check_state_after_choice()
# pagebreak
-> day_77_daily_recap


// ----------------------------------------------------------------------------
// 路径 D: sick_count 高 — 笑天周日装病前兆萌芽
// ----------------------------------------------------------------------------

= day_77_path_d_morning
# scene: bedroom_morning_unwell
# time: 11:00
# music: weekend_silence

你睡到 11:00 醒。

但你**头疼**——你 S3 累计 sick_count >= 2, 你身体在崩。

_我可能周一装病。_

_或者我周一真的起不来。_

_2 种都对。_

8:30 妈妈视频铃响——

# diegetic_ui: phone_video_call_camera_off

你接通**关掉摄像头**说"信号不好"。

# speaker: mama
妈妈: "天天, 看不见你脸。"

# speaker: protagonist
你: "妈我这边网不好。"

# speaker: mama
妈妈: "你还好吧?"

# speaker: protagonist
你: "嗯, 没事。"

视频 4 分钟结束 (比平时短)。

你躺在床上——你**没看 Lisa 微信**。

下午你头疼加深, 你决定**周一装病**——you set 闹钟在周一 8:30 用于发病假短信。

~ state = state + 20

// hidden flag: 路径 D - 笑天周日装病前兆 + 关妈妈视频摄像头

~ check_state_after_choice()
# pagebreak
-> day_77_daily_recap


// ----------------------------------------------------------------------------
// 路径 E: lisa_score < -5 / lisa_abandoned_at_weekend — Lisa mute 笑天
// ----------------------------------------------------------------------------

= day_77_path_e_morning
# scene: bedroom_morning_normal
# time: 11:00
# music: weekend_silence

你睡到 11:00 醒。

8:30 妈妈视频接了 — 普通版。

下午你点外卖 35 块。
~ money = money - 35

你下午刷手机——

# diegetic_ui: phone_wechat_check_mute

你查 Lisa 微信——

# speaker: lisa
Lisa 状态: 空白。

她**没发微信**给你。

她**朋友圈分组**——你不知道, 但她可能已经把你 mute 或者 partially block。

_S2 D75 我没回 Lisa "我自己一个人有点慌" 微信 (lisa_abandoned_at_weekend)。_

_S3 D77 她不主动找我。_

_我们俩**互相 mute**——但她比我先 register。_

_E11→E12 cliffhanger 路径 E: 没消息。_

~ state = state + 20

// hidden flag: 路径 E - Lisa mute 笑天 (lisa_abandoned_at_weekend)

~ check_state_after_choice()
# pagebreak
-> day_77_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 77 周日日报 (E11 末) — 跨路径 collector
// ----------------------------------------------------------------------------

= day_77_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +12)_

_关键时刻 today (E11 末):_
{lisa_weekend_company or (lisa_score >= 5):
    _  - 8:30 妈妈视频 verbatim "我累" + "没事不用回来"_
    _  - ★ **21:30 Lisa 微信 verbatim "笑天, 下周可能就出结果了。不管怎样, 谢谢你"** ★ (E11 → E12 cliffhanger)_
    _  - Lisa S3 第 1 次用"谢谢你" — 她在 say goodbye_
    - else:
    {lisa_abandoned_at_weekend:
        _  - 路径 E: Lisa mute 笑天 — 没消息_
        - else:
        {sick_count >= 2:
            _  - 路径 D: 笑天装病前兆萌芽 + 关妈妈视频摄像头_
            - else:
            _  - 路径 C: Lisa 没主动 cliffhanger 微信_
        }
    }
}

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_S3 hero flag 累积:_
_  - lisa_helped_self_review: {lisa_helped_self_review}_
_  - lisa_zoe_feedback_positive: {lisa_zoe_feedback_positive}_
_  - lisa_weekend_company: {lisa_weekend_company}_
_  - lisa_abandoned_at_weekend: {lisa_abandoned_at_weekend}_

_下周一开始: 第 12 周 — Season Finale "下周三签字"_

// E11 结束 - cliffhanger 到 E12 (5 路径 finale)

-> END

// ============================================================================
// EOF episode-11.ink
// ============================================================================
//
// 分身 task summary (S3 ink writer R1):
//   - Day 71-77 全 7 天 stitches 完整 + 周末 4 路径分支
//   - ★ D71 Lisa S1 motif "加油" 复活 (比 S1 频繁) ★
//   - ★ D71 晨会 Lisa 第一次主动发言 → 失败 (David 截胡 + 王总监没接) ★
//   - ★ D72 Decision Moment 1: Zoe 协作反馈 (路径 A 第 3 关键 hero flag lisa_zoe_feedback_positive) ★
//   - D73 David 22:00 加班 + 回头看 Lisa 工位 (S6 燃尽 setup deepening)
//   - ★ D74 19:30 王总监电话 verbatim "你跟 Zoe 说一下吧, 下周三签字" + 林姐 OK 周一 starting ★
//   - ★ D75 21:00 Lisa 微信 verbatim "明天来公司加班吗? 我自己一个人有点慌" ★
//   - ★ D75 Decision Moment 2 (路径分叉点): lisa_weekend_company / lisa_abandoned_at_weekend ★
//   - D76 周末 4 路径分支 (路径 A 周六去公司 9.5 小时陪 Lisa / 其他路径在家)
//   - D77 周日 4 路径分支 (路径 A/B + C + D + E)
//   - ★ D77 路径 A/B Lisa verbatim "笑天, 下周可能就出结果了。不管怎样, 谢谢你" (E11 → E12 cliffhanger) ★
//
// 笑/泪比 = 3:7 (per season-3-arc.md §1):
//   - 笑点: D71 5 分钟散会 / D73 David 7 张便利贴高峰 / D77 妈妈"年薪 60 万" callback
//   - 扎点: D71 Lisa motif "加油" 复活 + 主动发言失败 / D72 Zoe 协作反馈 (笑天工具化) /
//          D73 David 22:00 visualize 接位置 / D74 王总监电话 verbatim / D75 Lisa "我自己一个人有点慌" /
//          D76 路径 A 9.5 小时陪 / D77 Lisa "不管怎样, 谢谢你" (S3 第 1 次)
//
// 红线 (S3 不能做):
//   - Lisa 不决定走/留 ✓ (E12 finale)
//   - 王总监不直接对 Lisa "你不适合" ✓ (D74 backstage 电话)
//   - 老周 S3 0 dialog ✓
//   - 林姐不出场 ✓ (D74 mention only "林姐 OK 周一 starting")
//   - David 不燃尽 ✓ (D73 仅 visualize 接位置)
//
// END
