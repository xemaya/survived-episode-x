// ============================================================================
// Episode 10 · Week 10 · 「90 分钟」
// ============================================================================
//
// Status: 第 1 版 (S3 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S3 Round 1)
// Last Updated: 2026-05-06
//
// 配套 reference: 同 episode-1.ink
// 主 spec: design/vertical-slice/season-3-arc.md §5 E10 beat sheet
//        + season-3-arc-round-2-reply.md addenda
//
// 设计目标 (摘要):
//   1. HR 试用期评估面谈周 — Zoe 把 Lisa 叫去 HR 工位 90 分钟 (HR 处刑形态显形)
//   2. Decision Moment 1: 帮 Lisa 改自评 (路径 A 第 1 关键 hero flag)
//   3. Lisa quiet sign 升级: 没吃饭 + 偷哭 + "地铁延误" 撒谎
//   4. Zoe C Vulnerability: 周五早晨笑天看到 Zoe 桌上快餐盒 + 小红书《我做 HR 第 3 年我也想走》
//   5. 4:6 笑泪反转 — 笑减少
//   6. Cliffhanger 至 E11: Lisa 微信"笑天，谢谢你这周。下周一我可能要再去 HR 那边。你别担心"
//      ("你别担心" verbatim repeat S2 — 但这次后面跟着"我自己想想看怎么办")
//
// 红线 (S3 不能做):
//   - Lisa 不能决定走/留 (E12 finale)
//   - 王总监不能直接对 Lisa "你不适合" (Zoe 工作)
//   - 老周 S3 0 dialog
//   - 林姐 S3 不出场
//   - David S3 不燃尽
//
// Verbatim quotes 必保留:
//   - E10 周三晨会: Lisa "**在赶**" (S3 末她 dialog 频率↓)
//   - E10 周五: 李阿姨 "**这家公司的人每两个月走一茬**" (S2 verbatim 升级)
//   - E10 周日: Lisa 微信 "**你别担心**" (S2 verbatim repeat)
//
// ============================================================================

INCLUDE episode-1.ink

// E10 entry
-> episode_10


// ============================================================================
// Episode 10 主入口
// ============================================================================

=== episode_10 ===
# scene: home
# time: monday_morning_week_10
# pagebreak
-> day_64_morning_briefing


// ============================================================================
// Day 64 · 周一 · David 主动报 "上周 KPI 完成 145%" + Lisa 桌上文件夹换新
// ============================================================================
// 关键 beat:
//   - David 周一晨会主动报"上周 KPI 145%"——王总监没接, 眼神扫过 Lisa 那边
//   - Lisa 桌上文件夹换新 — 多了几张打印纸 (笑天没看清是什么)

= day_64_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared

闹钟响了 1 次。

_S3 第 2 周。Lisa 周日朋友圈"也好, 我自己也想换换" 配图文件夹特写。_

_她在 self-rationalize. 她在准备走的同时, 在准备 tell herself 她想走。_

_今天我 6/7 周一, 6/10 周三签字。她还有 3 天。_

_她不知道她还有 3 天。_

_我知道。_

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:14 到公司。

# speaker: vivian
Vivian: "嗨～来啦～"

水果盘**苹果** — 苹果周连续 10 周。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_64_event_1_morning_meeting_david_145


// ----------------------------------------------------------------------------
// Event 64.1 · 晨会 David 主动报 "上周 KPI 145%" · 9:35
// ----------------------------------------------------------------------------
// 触发: 周一晨会 (S3 第 2 周月初再加一场, 类似 S2 D50)
// 速度: 长 (~12 行)
// 同框: 王总监 + David + Lisa + 老周 + 笑天
// NPC archetype: David 加倍施压 + 王总监没接 (David S4 燃尽前兆 setup 加深)
// ----------------------------------------------------------------------------

= day_64_event_1_morning_meeting_david_145
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium
# npc: lisa_in_first_row_in_suit_again
# npc: david_with_4_sticky_notes
# npc: lao_zhou_in_back_with_tea

9:35 王总监推门。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"**S3 月度 KPI 启动会**第 2 周。"

# speaker: wang_director
"上周 deliverable 整体进度——"

David **抢话**——他平时是王总监讲完一段后才举手, 今天他**直接打断**:

# speaker: david
David: "王总, 我**主动报一下**——上周 KPI 完成 145%, 我这边超额 45 个 percentage point。"

会议室静了。

王总监**没接**。

他没说"好" / "棒" / "继续" / "嗯"。

他**眼神扫过 Lisa 工位方向** (扫过 Lisa 本人, 1 秒)——这次不是 visualize "她离开后那里空", 是直接看 Lisa 的脸。

# speaker: lisa
Lisa **抬头**——她跟王总监 0.5 秒对视。

她**没说话**。

她又低头记笔记。

王总监换 PPT 下一张。

# speaker: wang_director
"Lisa 这边——下周一对接 HR 那个 review, 你 prep 好就行。"

# speaker: lisa
Lisa: "好的。"

王总监**没问 PPT**。

S2 末他每周三晨会都问"PPT 怎么样" — 今天他**直接 skip 了 PPT 部分**, 说"prep HR review"。

_他在 reframe。_

_S2 他用 "PPT" 替代 review evaluation。S3 他直接说"HR review"。_

_他不再演"她做的是产品工作"。他公开说"她做的是 review"。_

_Lisa 也 register 了 — 她说"好的", 没多 1 个字。_

_她和王总监都接受了 reframe。_

# speaker: wang_director
"散会。"

7 分钟。

_David 145% 没人接。Lisa 直接 prep HR review。_

_老周喝茶。我没说话。_

_这场晨会 4 个 statements——3 个是单方独白 (David / 王总监 / Lisa), 1 个是 silence (老周 + 我)。_

// 没有选项 - 王总监 reframe + David 145% 没人接

// hidden flag: David D64 主动报 145% 没人接 - S4 燃尽 setup 加深
// hidden flag: 王总监 D64 公开 reframe Lisa "PPT" → "HR review"

~ check_state_after_choice()
-> day_64_event_2_lisa_kraft_folder_new


// ----------------------------------------------------------------------------
// Event 64.2 · Lisa 桌上文件夹换新 · 14:00
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 闪 (~5 行)
// 同框: Lisa (背景) + 笑天
// 设计意图: quiet sign 升级 — 文件夹内容增加 (打印纸)
// ----------------------------------------------------------------------------

= day_64_event_2_lisa_kraft_folder_new
# scene: workstation_with_lisa_folder_visible
# time: 14:00
# npc: lisa_typing_with_folder_visible

14:00。你回工位拿手机。

经过 Lisa 工位——

她桌上的牛皮纸文件夹**换了一个新的**。

旧的文件夹昨天还在桌角磨损了一点。今天**这个文件夹是全新的**——边缘锐利, 没磨损。

文件夹**鼓起来**——里面装了**几张打印纸**, 比上周多。

你没看清打印纸内容——她坐在那, 你不能凑近。

但你瞥到一个角——**像简历 layout** (姓名 / 地址 / 职位 / etc.)。

或者像试用期评估表的标准 form。

或者像离职申请书。

3 种可能。

她坐在工位敲键盘——她**没改 PPT**, 她在改 Word 文档。

_她在改简历 / 评估表 / 离职书。_

_3 种都是"准备走"。_

_她周一开始的 prep 加速了——文件夹换新 + 内容增加。_

_HR 6/10 周三签字 — 她要在 6/10 之前把 doc 准备好。_

// 没有选项 - quiet sign 升级

// hidden flag: Lisa D64 文件夹换新 + 多打印纸 - prep 加速

~ check_state_after_choice()
-> day_64_after_work


= day_64_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在敲。她还穿正装外套——第 8 天连续。

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
-> day_64_daily_recap


= day_64_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 周一晨会 **David 主动报 "上周 KPI 145%" 王总监没接** (S4 燃尽 setup 加深)_
_  - 王总监**公开 reframe Lisa "PPT" → "HR review"**_
_  - Lisa 桌上**文件夹换新 + 多打印纸** (prep 加速)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_65_morning_briefing


// ============================================================================
// Day 65 · 周二 · 王总监独立办公室门口 cue 笑天 + Lisa 中午没吃饭
// ============================================================================
// 关键 beat:
//   - 早晨王总监单独叫笑天到他独立办公室门口"Lisa 那边的 PPT 你看过没有？" → 3 选 1
//   - Lisa 中午**没吃饭**(盒饭碗筷没动 1 个小时)

= day_65_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_workstation
# time: 9:11
# npc: lisa_in_suit_jacket_eighth_day

9:11 到公司。Lisa **第 8 天穿正装**, 在工位敲 Word。

* [开始今日]
    -> day_65_event_1_wang_office_door


// ----------------------------------------------------------------------------
// Event 65.1 · 王总监独立办公室门口 cue 笑天 · 10:00 (Decision Moment)
// ----------------------------------------------------------------------------
// 触发: 第 2 个 event
// 速度: 长 (~10 行)
// 同框: 王总监 + 笑天
// 设计意图: 王总监第一次主动用笑天评估同事 - 笑天意识到自己也在被工具化
// ----------------------------------------------------------------------------

= day_65_event_1_wang_office_door
# scene: wang_solo_office_doorway
# time: 10:00
# npc: wang_at_doorway_with_phone

10:00。你正在改周报。

王总监走到你工位旁——他不在远端独立办公室, 他直接来工位区。

# speaker: wang_director
王总监: "小笑啊…"

0.5 秒。

# speaker: wang_director
"陈天啊…"

0.5 秒。

# speaker: wang_director
"差不多差不多。**Lisa 那边的 PPT 你看过没有？**"

_Lisa 那边的 PPT。_

_他周一公开 reframe "PPT" → "HR review"。_

_今天周二他来问我"PPT 看过没"——他在私下还是用"PPT"。_

_他在 hedge: 公开场合用"HR review", 私下用"PPT"。_

_他也不知道自己 reframe 到位没。_

_或者他在 fish info——我对 Lisa PPT 的认知 = 我对 Lisa 状态的 indirect 评估。_

_这是 S3 王总监第一次主动用笑天评估同事——anti-Pillar 4 的工具化。_

* [看过, 挺好的]
    # speaker: wang_director
    王总监: "嗯。她在赶吗?"
    # speaker: protagonist
    你: "在赶。"
    # speaker: wang_director
    王总监: "好。你别让她太赶哈。"
    _他说"别让她太赶" — 他在 protect 自己, 不是 Lisa。_
    _万一 Lisa 周四面谈崩, 他可以说"我让小笑提醒她别太赶, 但小笑没传话"。_
    _我成了他的 documentation 链上的 1 个节点。_
    ~ wang_score = wang_score + 0
    ~ lisa_score = lisa_score + 1   // 笑天对 Lisa 说"在赶" = sympathetic framing
    // hidden flag: 笑天 D65 给王总监 sympathetic framing for Lisa

* [我没看]
    # speaker: wang_director
    王总监: "啊好。那你看下哈。"
    # speaker: protagonist
    你: "好的。"
    王总监转身走了。
    _他没逼我看, 但他 register 了"小笑没看 Lisa PPT"。_
    _下次 Lisa 出问题, 他可以说"Lisa 协作伙伴小笑都没参与 PPT"。_
    _我又成了 documentation 链 节点, 但是 negative 节点。_
    ~ wang_score = wang_score - 1

* [她在赶]
    # speaker: wang_director
    王总监: "嗯。"
    王总监 0.5 秒。
    # speaker: wang_director
    "下周一我们一起看吧。" → 然后他走了。
    _下周一 6/14 — Lisa 已经签字 (6/10 周三签字)。下周一她 maybe 已经在客户成功部 / 已经走。_
    _他说"下周一我们一起看" 是 perfunctory — 他知道下周一 review 不会发生。_
    _他在演"还在 normal track"。_
    ~ wang_score = wang_score + 0

-

- _不论选什么。_
- _王总监第一次主动用笑天评估同事。_
- _我从 outsider → documentation 节点。_
- _我也被工具化了。_

// hidden flag: 王总监 D65 主动用笑天评估 Lisa - 笑天工具化第 1 次

~ check_state_after_choice()
-> day_65_event_2_lisa_no_lunch


// ----------------------------------------------------------------------------
// Event 65.2 · Lisa 中午没吃饭 · 12:30
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 标准 (~6 行)
// 同框: Lisa (前景, 背景) + 笑天
// ----------------------------------------------------------------------------

= day_65_event_2_lisa_no_lunch
# scene: workstation_lunchtime
# time: 12:30
# npc: lisa_with_lunch_box_unopened

12:30。

Lisa 桌上**有盒饭**——她带饭了。

但盒饭**没打开**。她还在敲键盘。

12:45 — 盒饭还没打开。

13:00 — 盒饭还没打开。

13:30 — 盒饭**还没打开**。**1 个小时**没动。

她**没吃**。

她中午一直在改 Word。

_她 fasting。_

_她可能减肥准备面试新公司。_

_或者她 stress 没胃口。_

_或者她在攒 prep 时间——HR 6/10 周三, 她还有 8 工时。_

_她不能浪费 30 分钟吃饭。_

13:45 她终于开了盒饭——**她吃了 3 口, 盖回去**。

她剩下的吃了**5 分钟**就回去敲键盘。

_她平时吃饭 25-30 分钟。今天 5 分钟。_

_她的 metabolism 在 burn down。_

// 没有选项 - quiet sign

// hidden flag: Lisa D65 中午没吃饭 / 5 分钟解决 - 状态恶化

~ check_state_after_choice()
-> day_65_after_work


= day_65_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在敲 Word — 不是 PPT。

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
-> day_65_daily_recap


= day_65_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 早晨**王总监单独 cue 笑天 "Lisa 那边的 PPT 你看过没有？"** (笑天工具化第 1 次)_
_  - Lisa 中午**没吃饭** (1 小时盒饭没动, 后来 5 分钟解决)_
_  - Lisa 在改 Word, 不是 PPT_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_66_morning_briefing


// ============================================================================
// Day 66 · 周三 · 晨会 王总监 cue Lisa "PPT 怎么样" Lisa "在赶" + David 第 2 次不耐烦
// ============================================================================
// 关键 beat:
//   - 晨会 王总监 cue Lisa "PPT 怎么样" Lisa "在赶" (verbatim)
//   - David 茶水间问 IT 小马"你那边修咖啡机要再问一下吗"——他第二次不耐烦

= day_66_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:25
# weather: cleared

周三。

# scene: meeting_room
# time: 9:25
# npc: lisa_in_first_row_in_suit_in_word_doc
# npc: david_with_5_sticky_notes
# npc: lao_zhou_in_back

9:25 到会议室。

Lisa 第一排, 正装外套。

David 笔记本贴 5 张便利贴。

老周后排, 中间那杯茶。

9:32 王总监推门。

* [开始今日]
    -> day_66_event_1_morning_meeting_zai_gan


// ----------------------------------------------------------------------------
// Event 66.1 · 晨会 王总监 cue Lisa "PPT 怎么样" · 9:35
// ----------------------------------------------------------------------------
// 触发: 晨会进行中
// 速度: 长 (~10 行)
// 同框: 王总监 + David + Lisa + 老周 + 笑天
// Verbatim: Lisa "在赶" 必保留 (S3 末她 dialog 频率↓)
// ----------------------------------------------------------------------------

= day_66_event_1_morning_meeting_zai_gan
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"我们这个团队啊, 月度过半了。"

# speaker: wang_director
"David 这边 deliverable 100% 完成确认 (上周 145% 是 spike, 本周节奏)。"

# speaker: david
David: "嗯。"

王总监**眼神不看 Lisa 工位方向**——这次反常。

# speaker: wang_director
王总监: "**Lisa——这边 PPT 怎么样？**"

他低头看 PPT——他没看 Lisa 的眼睛。

# speaker: lisa
Lisa: "**在赶。**"

2 个字。

王总监 0.3 秒。

# speaker: wang_director
"嗯。"

他**没说"那加把劲"**——他没说"周四前能交吗" / "下周一定稿了吗"。

他直接换 PPT 下一张。

_他不再 push Lisa。_

_S2 D38 他对 Lisa "加把劲" — 当时他还在 push。_

_S2 D52 他对 Lisa "嗯" — 已经 backstage 减压。_

_S3 D66 他**眼睛都不看 Lisa**——他已经完全 disengage。_

_他知道 6/10 周三签字。今天周三 6/9 — 明天她要去签字。_

_他不需要 push 她——她明天 leave 流程, 他在演"normal track" 给会议室其他人看, 但他自己已经 mentally 写完了 Lisa 的 chapter。_

# speaker: wang_director
"散会。"

6 分钟。

_6 分钟散会。比 S2 末 8 分钟还短 2 分钟。_

_他在 efficiency. 他要 save 时间给"周四 1 对 1 面谈" 的 prep——他自己也在 prep 自己的 narrative。_

// 没有选项 - 王总监 disengage + Lisa "在赶" verbatim

// hidden flag: 王总监 D66 不再 push Lisa - 完全 disengage

~ check_state_after_choice()
-> day_66_event_2_david_it_irritated_2nd


// ----------------------------------------------------------------------------
// Event 66.2 · David 茶水间问 IT 小马 第 2 次不耐烦 · 14:30
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 标准 (~7 行)
// 同框: David + IT 小马 + 笑天 (经过)
// NPC archetype: David S4 燃尽前兆 setup deepening (S2 D40 第 1 次 → S3 D66 第 2 次)
// ----------------------------------------------------------------------------

= day_66_event_2_david_it_irritated_2nd
# scene: break_room_doorway
# time: 14:30
# npc: david_with_disposable_cup
# npc: it_xiaoma_at_coffee_machine

14:30。你下班路过茶水间——你不是真去, 你是 detour。

David 在茶水间。

IT 小马在咖啡机旁——他**还在修**。机修包打开。

# speaker: david
David: "**修咖啡机**——你那边**要再问一下吗?**"

5 个字 + 6 个字。

S2 D40 他问"修咖啡机还要多久" — 那时候他第一次不耐烦。

S3 D66 他用 reframed 话术——"要再问一下吗"。

_他换了话术。_

_"要再问一下吗" 是 manager-style push——他在 pretend 自己有 authority over IT 小马。_

_但 IT 小马是外包技术——David 跟 IT 小马平级或更低。_

_David 不能 push IT 小马。_

_他在 try。_

# speaker: it_xiaoma
IT 小马: "已派单, 等零件"

# speaker: it_xiaoma
"v3 预计周五修复。"

_v3。_

_S1 是 v1 (零件待到货)。S2 是 v2 (零件已到货)。S3 是 v3 (等零件)。_

_告示版本号每周升级——但咖啡机还在故障。_

_IT 小马 OKR 推进。咖啡机不动。_

David 没说话——他把一次性杯子放进垃圾桶, 走了。

_他没坚持 push。_

_他知道他没 authority。_

_但他还是要 try。_

_这是 David S4 燃尽前兆——他开始 push 不该 push 的人, 因为他对 push 自己 KPI 已经 burn out。_

_他在转移 push direction。_

_3 个月后他会 push 自己离职 (S6 finale)。_

// 没有选项 - David S4 燃尽 setup deepening

// hidden flag: David D66 第 2 次不耐烦 IT 小马 - S6 燃尽 setup

~ check_state_after_choice()
-> day_66_after_work


= day_66_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在敲 Word。

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
-> day_66_daily_recap


= day_66_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 晨会**王总监 cue Lisa "PPT 怎么样" Lisa verbatim "在赶" 王总监没接** (王总监完全 disengage)_
_  - **David 茶水间第 2 次不耐烦 IT 小马** (S4 燃尽 setup deepening)_
_  - 6 分钟散会 (王总监在 save 周四面谈 prep 时间)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_67_morning_briefing


// ============================================================================
// Day 67 · 周四 · ★ Zoe 90 分钟面谈 + Decision Moment 1 帮 Lisa 改自评 ★
// ============================================================================
// 关键 beat:
//   - 14:00 Zoe 把 Lisa 叫去 HR 工位 90 分钟 (HR 处刑形态显形)
//   - 15:30 Lisa 回来眼睛红了一下 - 没跟笑天说话
//   - 18:00 Decision Moment - 帮 Lisa 改试用期自评？(路径 A 第 1 关键 hero flag)

= day_67_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: rainy

周四。下小雨。

~ weather = "rainy"

# scene: office_workstation
# time: 9:11
# npc: lisa_in_suit_jacket_tenth_day

9:11 到公司。Lisa 第 10 天穿正装外套。

她**戴帽子**——黑色棒球帽 (S2 E8 D51 那种)。

她**全身覆盖**——外套 + 帽子 + 长袖。

_今天她准备的最齐——可能因为 14:00 面谈。_

_她在 prep 自己的 visible armor。_

* [开始今日]
    -> day_67_event_1_lisa_walks_to_hr


// ----------------------------------------------------------------------------
// Event 67.1 · 14:00 Zoe 把 Lisa 叫去 HR 工位 90 分钟 · 14:00 (★ 集内最高峰 ★)
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 长 (~14 行)
// 同框: Zoe + Lisa + 笑天 (看着 Lisa 走出工位 area + 90 分钟后看着 Lisa 回来) + 老周 (背景)
// NPC archetype: HR 处刑形态显形 - S3 第一次 90 分钟级面谈
// ----------------------------------------------------------------------------

= day_67_event_1_lisa_walks_to_hr
# scene: workstation_with_zoe_arriving
# time: 14:00
# npc: zoe_in_black_jacket
# npc: lisa_short_hair_with_hat

14:00。

你正在写周报。

# speaker: zoe
Zoe 走过来——她走到 Lisa 工位旁。

# speaker: zoe
"**Lisa, 你这边方便的话, 跟我去 HR 那边聊一下哈。**"

# speaker: lisa
Lisa**抬头看 Zoe 0.5 秒**。

她**没**惊讶——她预知到这一刻。

她**关电脑屏幕**——同 S2 D53 一致。

她**戴上帽子**, 拿外套——她在 HR 面谈仍要 maintain visual armor。

# speaker: lisa
Lisa: "嗯, 现在?"

# speaker: zoe
Zoe: "嗯, 大概 1 个半小时。"

_1 个半小时。_

_S2 D53 Zoe 说"5 分钟够了"——她话术降压。_

_S3 D67 Zoe 说"1 个半小时"——她直接 disclose 时长。_

_她不再降压——因为这次是 review, 不是 collect feedback。_

_review 需要 90 分钟——评估 + 通知 + 流程签字 caveat。_

# speaker: lisa
Lisa: "好。"

她跟 Zoe 走。

# scene: workstation_lisa_walking_out_again

她经过你工位 1 米。

她**没看你**。

她跟 Zoe 走出工位 area。

# scene: workstation_lisa_now_outside_zone

# speaker: zoe
Zoe 和 Lisa 出了工位 area。

你看不见他们了。

你回头看 David——他**抬头看 Lisa 走方向 0.5 秒**, 又低头。

老周喝茶——他**抬头 0.5 秒** (S3 第 2 次抬头, 第 1 次是 D57)。

David 不看 90 分钟。老周看 Lisa 走方向 0.5 秒——他 register 了。

# scene: workstation_xiaotian_alone

14:00 → 14:30 → 15:00 → 15:30。

90 分钟。

你周报写不下去——你每隔 5 分钟看 Lisa 工位方向。

她工位空着。

15:30 — Lisa 回来。

她**没戴帽子**——她拿在手里。

她**眼睛红了一下**——你 0.5 秒看到, 然后她戴上帽子, 红了又被 hide。

她坐回工位, 开屏幕, 接着改 Word——不是 PPT。

她**没跟笑天说话**。

她**没去倒水**, 没去洗手间洗脸——她直接坐下。

_她在 maintain face value 即使在崩。_

_90 分钟。_

_她在 HR 听到的内容——_

_周三签字 (6/10) confirm。_
_客户成功部 + 林姐转岗预案 disclose。_
_试用期评估表给她 take home。_
_流程 brief。_

_或者她听到的是更狠的——直接走人 caveat。_

_她不会告诉我。_

# scene: workstation_xiaotian_observes_lisa_back

* [发个微信关心]
    你发: "你刚才...?"
    # speaker: lisa
    Lisa 没回。
    20 分钟后她回: "嗯, 没事。"
    _2 个字。_
    ~ lisa_score = lisa_score + 2

* [不主动]
    你继续敲自己周报。
    Lisa 也敲 Word。
    工位静默 2 小时。
    ~ lisa_score = lisa_score + 0

-

- _不论选什么。_
- _90 分钟面谈。她回来时眼睛红。她直接坐下。_
- _周日她可能跟我说细节。今天她不说。_

// hidden flag: Zoe D67 14:00-15:30 90 分钟面谈 - HR 处刑形态显形 S3 第 1 次

~ state = state - 8   // 看着 Lisa 走的扎心

~ check_state_after_choice()
-> day_67_event_2_decision_help_self_review


// ----------------------------------------------------------------------------
// Event 67.2 · 18:00 Decision Moment 帮 Lisa 改试用期自评 · 18:00 (★ 路径 A 第 1 关键 hero flag ★)
// ----------------------------------------------------------------------------
// 触发: 17:30 之后留下来加班的玩家
// 速度: 长 (~14 行)
// 同框: Lisa + 笑天
// NPC archetype: B Decision Moment - S3 第 1 关键 hero flag for E12 path A
// ----------------------------------------------------------------------------

= day_67_event_2_decision_help_self_review
# scene: workstation_evening_dual
# time: 18:00
# npc: lisa_at_word_doc_appearing_to_struggle

18:00。

你在工位——你今天 17:30 没走, 你想多看 1 小时。

Lisa 在工位敲 Word——她**已经改了 4 小时**。

她屏幕**截图发到你微信**——她**第一次主动 share 屏幕**给你。

# diegetic_ui: phone_wechat_lisa_screenshot
# speaker: lisa
Lisa: "笑天, 你能帮我看下这个自评吗？我感觉怎么写都不太对。"

20 个字。

她在求救。

S2 末 D55 / D56 她说"我可能要走" + "你别担心"——她仍在 try save herself。

S3 D67 她**主动求笑天帮看自评**——她终于 ask for help。

不是关于 PPT, 不是关于咖啡, 不是关于聚餐。

是关于**HR 试用期评估自评**。

_她意识到 PPT 已经不重要了——HR 流程是关键。_

_她的自评写得"不太对"——意味着她写不出 HR 想看的话术。_

_她需要 ghostwriter。_

* [接过来 帮 Lisa 改自评]
    # speaker: protagonist
    你: "好, 发我看下。"
    Lisa 5 秒后发了 PDF。
    你 OneNote 打开——
    Lisa 自评 4 段:
    "本月度参与 product development 工作, 完成 PPT V8-V12 共 5 版迭代。"
    "在 cross-team 协作上 努力 改进, 学习 客户对接 deliverable 流程。"
    "本次月度面谈主要 inbox 是 试用期评估 + 流程 walk-through。"
    "下月将持续 努力, 保持 momentum, 推动 deliverable 落地。"
    _她的自评 4 段都用 HR-speak — 但用错了。_
    _她说"努力" 2 次——HR 不喜欢"努力"，HR 喜欢"系统性优化注意力分配"。_
    _她说"试用期评估" 1 次——这是她**已经在自评里 ack 自己被评估**, 这是 HR-speak 红线 (你不能在自评里承认自己被审)。_
    _她说"持续努力" 1 次——HR 喜欢"承担更高的责任"。_

    你帮她改：

    "本月度系统性优化协作流程, 完成关键 deliverable 5 项 (PPT V8-V12 迭代 + 客户对接预案)。"
    "在 cross-team 协作中 主导多个里程碑, 推动 客户成功部对接 落地。"
    "本次月度面谈是公司常规 review 节奏, 我已与 HR 充分对齐。"
    "下月将承担更高责任, 持续推动业务增长。"

    _你帮她翻译成 HR-speak。_
    _关键改: "试用期评估" → "公司常规 review 节奏" (反 expose)。_
    _关键改: "努力" → "主导 / 承担更高责任" (反 self-deprecate)。_
    _你写的不是 truth. 你写的是 HR 想看的 truth 的 representation。_

    19:30 你发回 PDF。
    Lisa 5 秒后回: "天哪, 笑天, **谢谢你**。这样 makes sense 太多了。"
    _天哪——她第一次说"天哪"。_
    _这是她对你的最深 acknowledgment。_
    _她周五早上 Zoe 那边 review 这版自评 — 路径 A 第 1 关键 hero flag locked。_

    ~ state = state - 10
    ~ kpi = kpi - 5
    ~ effort_overage = effort_overage + 1
    ~ lisa_score = lisa_score + 8
    ~ lisa_helped_self_review = true
    // 路径 A 第 1 关键 hero flag locked - S3 hero count +1

* [我不太懂自评]
    # speaker: protagonist
    你: "哎, 我不太懂自评 framework, 我自己周报都瞎写。"
    # speaker: lisa
    Lisa: "嗯, 那我自己看吧。"
    _她"嗯" 0.5 秒。她没 push 你。_
    _她回工位接着改。_
    _她接受了 — 她在 protect 你的 ego。但她对你的期望降了 1 档。_
    ~ lisa_score = lisa_score + 0

* [不回 / 装没看见]
    你看了截图, 没回。
    20 分钟后 Lisa 撤回了截图——她意识到你不会帮。
    # speaker: lisa
    Lisa 没追问。
    _她不再问。她知道你不会再被她依赖。_
    _S3 后她对你的求助行为消失。_
    ~ lisa_score = lisa_score - 5
    // hidden flag: Lisa 不再求助笑天 - S3 lisa_score 进入下降通道

-

- _不论选什么。_
- _Lisa 周四 18:00 第一次主动求救 self_review。_
- _S2 末她"你别担心"是 protect 你, S3 周四是 ask for help。_
- _她的 trust gradient 在 increase——她需要你了。_
- _你做或不做, 都决定 E12 finale 的路径分叉权重。_

// hidden flag: Lisa D67 第一次主动求救 self_review - S3 关键 trust signal

~ check_state_after_choice()
-> day_67_after_work


= day_67_after_work
# scene: workstation_evening
# time: 19:30
# npc: lisa_at_desk_after_self_review_help

如果 18:00 你帮了 Lisa 改自评, 19:30 你已经走了。

如果你没帮, 19:30 Lisa 还在工位——她自己改。

* [继续 (申报加班 已计入)]
    你 19:30 走人。Lisa 没看你。
    ~ state = state - 0   // 已计入 18:00 决策

* [按时下班 (没参与 self_review)]
    你 17:30 走人。Lisa 自己改。
    ~ state = state + 0

-

~ check_state_after_choice()
# pagebreak
-> day_67_daily_recap


= day_67_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **14:00 Zoe 把 Lisa 叫去 HR 90 分钟** (HR 处刑形态显形 S3 第 1 次)_
_  - 15:30 Lisa 回来**眼睛红了一下** + 没跟笑天说话_
_  - 老周 D67 抬头 0.5 秒看 Lisa 走方向 (S3 第 2 次抬头)_
_  - ★ **18:00 Decision Moment 帮 Lisa 改 self_review** (路径 A 第 1 关键 hero flag)_
_  - flag lisa_helped_self_review = {lisa_helped_self_review}_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_68_morning_briefing


// ============================================================================
// Day 68 · 周五 · weekly_recap + 笑天去茶水间听到隔壁哭 + Zoe 桌上小红书 + 李阿姨"两个月走一茬"
// ============================================================================
// 关键 beat:
//   - 早晨笑天去茶水间——听到隔壁洗手间隔间哭一声——出来时 Lisa 工位还空着
//   - 9:00 Lisa 才到说"地铁延误"——但笑天周五早晨地铁正常 (撒谎)
//   - 笑天去 HR 工位办手续, 看到 Zoe 桌上**快餐盒** + 屏幕开着小红书《我做 HR 第 3 年我也想走》(Zoe C Vulnerability)
//   - 17:35 茶水间 李阿姨 verbatim "这家公司的人每两个月走一茬" (集内最深扎心)

= day_68_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_8:30
# weather: cleared

周五。

你今天**比平时早 30 分钟出门**——你 D67 帮 Lisa 改自评后睡得不安稳, 凌晨醒了 1 次, 起床早。

# scene: subway_carriage
# time: 8:00

地铁 10 号线——今天**地铁正常**。

_周五早晨 8:00 我地铁正常。_

* [开始今日]
    -> day_68_event_1_bathroom_cry


// ----------------------------------------------------------------------------
// Event 68.1 · 茶水间 听到隔壁哭一声 · 8:30 (★ Lisa C Vulnerability ★)
// ----------------------------------------------------------------------------
// 触发: 8:30 早到
// 速度: 长 (~12 行)
// 同框: Lisa (隔壁洗手间隔间) + 笑天 (茶水间) + 李阿姨 (路过远端)
// 设计意图: Lisa 早晨在 HR 大楼的洗手间偷哭 — 但她没让笑天见到本人, 只听到 1 声
// ----------------------------------------------------------------------------

= day_68_event_1_bathroom_cry
# scene: break_room_doorway
# time: 8:30
# npc: lisa_via_audio_in_bathroom

8:30 到公司。

# speaker: vivian
Vivian: 还没来 (她 9:00 才到)。

公司大堂只有 1 个保洁阿姨在拖地。

你刷工牌进 — 你今天 30 分钟早到。

你去茶水间接水。

茶水间在 16 楼洗手间隔壁。

你接水时——

**隔壁洗手间传来一声**——

**哭。**

不是大声的哭——是**1 声**, 然后**很快被 hold 住**。

像是有人在隔间里 try control。

你站着不动 5 秒——又听到**1 声鼻音**, 然后**安静**。

5 秒后**隔间门开了**——你听到脚步声**走出洗手间**, **进了 HR 走廊**(不是出大楼方向)。

你**没看到人**——但她去 HR 方向。

她不是 Vivian (Vivian 还没到)。

她不是李阿姨 (李阿姨在 1 楼大堂, 你刚看到)。

她不是 Zoe (Zoe 平时 8:30 还没到)。

她**很可能是 Lisa**——但你不能 confirm。

或者是隔壁部门的人。

你拿水回工位——你**不能去 HR 走廊 confirm**。

回工位看 Lisa 工位——**空着**。

她还没到。

_她在公司大楼里。_

_她在 HR 走廊。_

_她在洗手间偷哭过 1 声。_

_她可能 prep 自评——9:00 review with Zoe。_

_她可能崩了一下, 又 hold 住。_

_她不知道我听到了。_

_我也不会告诉她。_

# scene: workstation_xiaotian_back

# diegetic_ui: phone_check_lisa_status

你坐到工位, 看微信——Lisa 状态空白 (跟昨天一致)。

8:50 — Lisa 没到。

# 9:00 — Lisa 到了。

她**穿正装**, 戴帽子, 拿外套——同 D67 全身 armor。

她**眼睛没红**——她在大楼 HR 走廊 hide 了 30 分钟 + 整理。

# speaker: lisa
Lisa: "诶, 早。"

# speaker: protagonist
你: "早。"

# speaker: lisa
Lisa: "**地铁延误了**。"

3 个字。

_她撒谎。_

_周五早晨 8:00 我地铁正常。_

_她 9:00 才进公司大楼。_

_她不是地铁延误——她在 HR 走廊。_

_她**正面对我撒谎**。_

_她不知道我听到了 1 声哭。_

_她在用"地铁延误" reframe 自己的迟到 + invisible 早到 (她其实 8:30 之前已经在公司大楼了)。_

_她的话术系统在 collapse——她需要 cover stories, 但 cover stories 之间互相 contradict。_

_我没拆穿。_

* [嗯, 周五早高峰]
    # speaker: lisa
    Lisa: "嗯。"
    _她笑了一下, 不深。_
    ~ lisa_score = lisa_score + 1

* [我地铁挺正常的]
    # speaker: lisa
    Lisa 0.5 秒沉默。
    "啊, 可能是我那段。"
    _她 register 我的 cross-check, 但她还在 hold。_
    ~ lisa_score = lisa_score - 2
    // hidden flag: 笑天 cross-check Lisa 撒谎 - 她 register 了

* [不回, 看屏幕]
    你看自己屏幕。Lisa 也看自己屏幕。
    工位静默。
    ~ lisa_score = lisa_score + 0

-

- _不论选什么。_
- _她周五在洗手间偷哭过。_
- _她周五对我撒谎"地铁延误"。_
- _我没拆穿。_
- _我们都在 maintain face value 直到 finale。_

// hidden flag: Lisa D68 洗手间偷哭 + 撒谎"地铁延误" - quiet sign 升级

~ check_state_after_choice()
-> day_68_event_2_zoe_breakfast_xiaohongshu


// ----------------------------------------------------------------------------
// Event 68.2 · Zoe 桌上快餐盒 + 小红书 · 11:00 (★ Zoe C Vulnerability ★)
// ----------------------------------------------------------------------------
// 触发: 第 2 个 event (笑天去 HR 工位办手续)
// 速度: 长 (~10 行)
// 同框: Zoe + 笑天
// NPC archetype: Zoe S3 唯一 Vulnerability moment - 告诉玩家 Zoe 也在熬
// ----------------------------------------------------------------------------

= day_68_event_2_zoe_breakfast_xiaohongshu
# scene: hr_workstation_zoe
# time: 11:00
# npc: zoe_with_breakfast_box_open
# prop: zoe_screen_xiaohongshu_visible

11:00。你去 HR 工位办其他手续——年审 medical insurance 跟进 + 新表格签字。

经过 Zoe 工位——Zoe 在工位。

# diegetic_ui: zoe_desk_close_up

她桌上**摆着一个快餐盒**——肯德基早餐, 还热着 (她早上没吃完, 现在中午加热)。

她屏幕开着——左半屏是 Excel 表格, 右半屏是浏览器, 浏览器开着**小红书 app web 版**。

小红书页面文章标题: "**《我做 HR 第 3 年我也想走》**" — 红标题 + 一张配图 (一个 office 工位)。

你站在 Zoe 工位旁等系统响应。

# speaker: zoe
Zoe 抬头——

她**0.5 秒**意识到你看到了她屏幕。

她**慌张切屏**——右半屏的小红书 swap 到 公司 LinkedIn page。

# speaker: zoe
她: "陈笑天先生, 您来了。"

她**叫"陈笑天先生"**——比平时多 1 秒延迟。

她在 process embarrassment。

# speaker: protagonist
你: "嗯, medical insurance 年审。"

# speaker: zoe
Zoe: "好的, 这边您签个字哈。"

她递给你表格, 你签了。

她**没看你**——她屏幕仍是公司 LinkedIn page (假装自己在看官方内容)。

_她也在熬。_

_她做 HR 第 3 年——她从 Zoe (鲜活) 到 Zoe (job-numbed)。_

_她也想走。_

_她每天对员工"陈笑天先生" + "Lisa 同学" + "走完流程" — 她演 HR-speak 演到自己也信了。_

_但她在 lunch break 看小红书《我做 HR 第 3 年我也想走》。_

_她跟我们一样——只是她的 cope 是小红书, 我的 cope 是床, Lisa 的 cope 是文件夹。_

_HR 也是齿轮。_

_S2 D68 我看到 Zoe 偷刷小红书《离开大厂的第 100 天》——那时候我以为她偶尔。_

_S3 D68 她午饭快餐盒 + 小红书《第 3 年我也想走》 — 她在系统化 cope。_

_她每天 11:00 - 13:00 是她的"小红书 + 快餐 + escape" 时间窗。_

# speaker: zoe
Zoe: "好了, 您拿好表。"

# speaker: protagonist
你: "嗯, 谢谢。"

你拿表走开。

她**没看你走**——她已经把屏幕切回小红书。

// 没有选项 - Zoe S3 唯一 Vulnerability moment

// hidden flag: Zoe D68 桌上快餐盒 + 小红书《我做 HR 第 3 年我也想走》(她也想走)

~ check_state_after_choice()
-> day_68_event_3_li_ayi_two_months


// ----------------------------------------------------------------------------
// Event 68.3 · 茶水间 李阿姨 verbatim "这家公司的人每两个月走一茬" · 17:35 (集内最深扎心)
// ----------------------------------------------------------------------------
// 触发: 下班路上经过茶水间
// 速度: 长 (~12 行)
// 同框: 李阿姨 + 另一个清洁阿姨 + 笑天 (经过)
// NPC archetype: 李阿姨 S3 verbatim 升级 (S2 "上一个坐这位置的也是这么想的" → S3 "每两个月走一茬")
// Verbatim: "这家公司的人每两个月走一茬" 必保留
// ----------------------------------------------------------------------------

= day_68_event_3_li_ayi_two_months
# scene: break_room_doorway
# time: 17:35
# npc: li_ayi_with_mop_cart_son_exam
# npc: another_li_ayi_holding_trash

17:35。你下班, 经过茶水间。

李阿姨在收垃圾。

另一个清洁阿姨在她旁边。

她们没看你。

她们在低声说话。

# speaker: li_ayi
李阿姨: "她周四去 HR 那边 90 分钟。"

# speaker: li_ayi
另一个: "嗯。"

# speaker: li_ayi
李阿姨: "斜对角那个穿正装的。"

# speaker: li_ayi
另一个: "嗯。"

李阿姨拖了一下垃圾桶——0.5 秒沉默。

# speaker: li_ayi
李阿姨: "**这家公司的人每两个月走一茬。**"

verbatim。

11 个字。

# speaker: li_ayi
另一个清洁阿姨: "嗯。"

她们继续收垃圾。

_"这家公司的人每两个月走一茬"。_

_S2 D47 李阿姨 verbatim "上一个坐这位置的也是这么想的" — 她跟我说她见过这种 pattern。_

_S3 D68 李阿姨 verbatim "这家公司的人每两个月走一茬" — 她直接给 statistics。_

_2 个月 = 8 周 = 1 季度的 1/3 ~ 半。_

_S1 4 周 + S2 4 周 + S3 4 周 = 12 周 = 3 个月。_

_她见过 (S1 + S2 + S3) / 2 = 1.5 茬走。_

_但 Lisa 是同一茬 — 她 S1 入职, S3 走。_

_她不算"两个月走一茬"——她是慢一档。_

_或者她是一茬里 hold 最久的——其他 12 周的人 已经走了。_

_我不知道 Lisa 是 fast 还是 slow。_

_但我知道李阿姨知道。_

_她在这扫了 8 年 — 她见过 2920 个工作日, 大概 50+ 茬。_

_她不会上 LinkedIn 写"我有 8 年企业人力洞察"。_

_她只是扫地。_

_但她是 series 内最 accurate 的 datapoint。_

# scene: corridor_back_walking

你站在茶水间外面 5 秒——你不能进去。

你走开。

// 没有选项 - 集内最深扎心 verbatim

// hidden flag: 李阿姨 D68 verbatim "这家公司的人每两个月走一茬" (S3 升级 S2 verbatim)

~ state = state - 8   // 扎心

~ check_state_after_choice()
-> day_68_after_work


= day_68_after_work
# scene: workstation_evening
# time: 17:40
# npc: lisa_workstation_in_self_review_v2

17:40。你回工位拿包。

Lisa 还在工位——她在敲 Word, 文档名是"**自评 V2**"。

如果你 D67 帮她改, 她现在在改 V2 (你给的是 V1)。

如果你没帮, 她在自己写 V8 (她每天换一版, 但都"不太对")。

* [明天见]
    # speaker: lisa
    Lisa: "明天见。" (她说"明天见" — 这是她回到 social baseline)
    _她说"明天见" 不"好" — 她在 maintain。_
    ~ lisa_score = lisa_score + 1

* [辛苦]
    # speaker: lisa
    Lisa: "嗯。"
    ~ lisa_score = lisa_score + 0

* [不说话]
    Lisa 没看你。
    ~ lisa_score = lisa_score + 0

-

~ check_state_after_choice()
# pagebreak
-> day_68_daily_recap


= day_68_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 19 天 (周日 6/27 推送)_

_关键时刻 today:_
_  - 8:30 茶水间**听到隔壁洗手间哭 1 声** (Lisa 偷哭)_
_  - Lisa 9:00 才到说"**地铁延误**" (撒谎 — 笑天周五早晨地铁正常)_
_  - 11:00 **Zoe 桌上快餐盒 + 小红书《我做 HR 第 3 年我也想走》** (Zoe C Vulnerability)_
_  - ★ **17:35 李阿姨 verbatim "这家公司的人每两个月走一茬"** (集内最深扎心)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_69_weekend_morning


// ============================================================================
// Day 69 · 周六 · 周末
// ============================================================================

= day_69_weekend_morning
# scene: bedroom
# time: 12:18
# music: weekend_silence

你睡到 12:18 醒。

_S3 第 2 周比 S3 第 1 周晚 10 分钟。_

# diegetic_ui: phone_wechat_moments

朋友圈：

David 发"**6 月第 2 周, 4 大冲刺第 2 周**"——他 spinning 越来越机械化。

Lisa 朋友圈仍是 D63 "也好我自己也想换换" + 文件夹特写——她**没发新的**。

她周日 21:00 发的, 周六 D69 没发新的。

_她在 holding pattern。_

11:34 → 12:34。点外卖。35 块。
~ money = money - 35

* [开始今日]
    -> day_69_event_1_afternoon


= day_69_event_1_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你在床上。

你想给 Lisa 发条微信——"周末过得怎样" — 但你没发。

_发了她会"嗯"。她不会展开。_

如果 D67 你帮了她改自评——你已经做了"陪 Lisa" 的 weekly contribution。她会 register。

如果你没帮——发也帮不了什么。

你又躺了 30 分钟。

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_69_daily_recap


= day_69_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 12:18 起床 (加速退步 baseline)_
_  - David 朋友圈"6 月第 2 周冲刺"_
_  - Lisa 朋友圈无新 (holding pattern)_

# pagebreak
-> day_70_weekend_morning


// ============================================================================
// Day 70 · 周日 · 妈妈"那个谁的儿子升职年薪 60 万" + Lisa 微信"你别担心"
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈视频"那个谁的儿子升职了。听说现在年薪 60 万。" 3 选 1
//   - 21:30 Lisa 微信 verbatim "你别担心" (S2 repeat) + "我自己想想看怎么办" (E10→E11 cliffhanger)

= day_70_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

你 8:23 醒。

_今天她会说什么。_

_S3 D63 她"我下个月可能不去你那" backtrack。_

_今天她可能 again backtrack 或者新 escalation。_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_70_event_1_mom_video_60w


// ----------------------------------------------------------------------------
// Event 70.1 · 妈妈视频"那个谁的儿子升职了。年薪 60 万。" · 8:30
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~12 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 升级 — 第一次给具体数字 (60 万)
// ----------------------------------------------------------------------------

= day_70_event_1_mom_video_60w
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen

屏幕里是妈妈。

# speaker: mama
妈妈："**天天, 吃了吗？**"

# speaker: protagonist
你: "吃了。"

# speaker: mama
妈妈: "**工资发了吗？**"

# speaker: protagonist
你: "发了。"

妈妈停了一下。

# speaker: mama
"**那个谁的儿子升职了。**"

# speaker: mama
"**听说现在年薪 60 万。**"

15 个字 + 数字。

_她**第一次给具体数字**。_

_S2 D42 "那个王二家儿子上海买房了" — 没具体房价。_

_S3 D70 "那个谁年薪 60 万"——她直接 disclose 数字。_

_60 万 / 年 = 5 万 / 月 = 我现在工资的 5 倍。_

_她在用 Reference 给我 push。_

_她不知道她在 push。或者她知道。_

* [嗯]
    # speaker: mama
    妈妈: "嗯。"
    _她"嗯" 0.5 秒——她预期我会 react 多一点。_
    "你那边怎么样?"
    # speaker: protagonist
    你: "还行。"
    ~ mom_score = mom_score + 0

* [不容易]
    # speaker: mama
    妈妈: "是啊, 你也不容易。"
    _她接了"你也不容易" — 她在 give me cushion。_
    "妈最近身体还行, 你别担心。"
    _她在 reframe。她知道 60 万是 push, 她在 retreat。_
    ~ mom_score = mom_score + 2

* [我也快了]
    # speaker: mama
    妈妈: "好好好, 妈等你。"
    _她笑了——是真心笑, 但是 0.5 秒的 fragile 笑。_
    "妈不催你。"
    _她说"不催" 但她在催。_
    ~ mom_score = mom_score - 1

-

- _不论选什么。_
- _她每周加 1 个 new pressure point。_
- _上周"我下个月不去你那" — 反转。_
- _这周"那个谁年薪 60 万" — 数字 push。_
- _下周可能更具体——比如"你姨说她朋友的女儿离职回老家考公"。_
- _Lisa 会走的事她不知道, 但她说的话跟 Lisa 走的事 thematic mirror。_

// hidden flag: 妈妈 D70 第一次给具体数字 60 万

~ check_state_after_choice()
-> day_70_event_2_lisa_message_dont_worry


// ----------------------------------------------------------------------------
// Event 70.2 · 21:30 Lisa 微信 verbatim "你别担心" + cliffhanger · 21:30 (E10→E11 cliffhanger)
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 长 (~12 行)
// 同框: Lisa (微信)
// 设计意图: E10→E11 cliffhanger - "你别担心" verbatim repeat S2 D49 但加 "我自己想想看怎么办"
// Verbatim: "你别担心" 必保留 (S2 verbatim repeat)
// ----------------------------------------------------------------------------

= day_70_event_2_lisa_message_dont_worry
# scene: home_evening
# time: 21:30
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:30。你刚洗完澡。

微信消息 1 条。

# speaker: lisa
Lisa：

# speaker: lisa
{lisa_helped_self_review: "笑天，谢谢你这周。" | "笑天。"}

# speaker: lisa
"下周一我可能要再去 HR 那边。"

# speaker: lisa
"**你别担心。**"

# speaker: lisa
"我自己想想看怎么办。"

22 个字。

_S2 D49 她说"笑天, 下周一我可能要去 HR 那边。但你别担心啊。"_

_S3 D70 她又说"下周一可能要再去 HR" + "你别担心" — verbatim repeat。_

_但这次后面跟着"**我自己想想看怎么办**"。_

_S2 她说"别担心"是 protect 我。_

_S3 她说"别担心" + "我自己想想" — 她是 prep 自己 walk away。_

_她不再依赖任何 helper. 她在 self-process. 她在 prep finale。_

_S2 D49 我以为是"她还在 ask for help"。_

_S3 D70 我意识到是"她在 prep say goodbye"。_

_她每次说"别担心" 都意味着她担心。_

_她每次说"我自己想想" 都意味着她已经想好了, 只是不告诉我。_

* [我在]
    # speaker: lisa
    Lisa: "好。"
    _她没继续。_
    ~ lisa_score = lisa_score + 2

* [需要帮忙就说]
    # speaker: lisa
    Lisa: "嗯。"
    _她"嗯" 0.5 秒。_
    "下周再说吧。"
    ~ lisa_score = lisa_score + 1

* [辛苦]
    # speaker: lisa
    Lisa: "嗯。晚安。"
    ~ lisa_score = lisa_score + 0

* [不回]
    # speaker: lisa
    Lisa 没追问。
    20 分钟后她: "晚安。"
    ~ lisa_score = lisa_score - 2

-

- _不论选什么。_
- _她说"别担心" verbatim repeat S2。_
- _但这次 "我自己想想看怎么办" — 她在 declare independence。_
- _S2 她还需要笑天 (虽然嘴上说"别担心")。_
- _S3 她在 walking away — 她对笑天的需求在 decrease。_
- _下周一她去 HR 那边的 review with 她改过的自评 (路径 A) 或者 sticking with V8 (other paths)。_

// hidden flag: E10 → E11 cliffhanger - Lisa "你别担心" verbatim repeat + "我自己想想"

~ check_state_after_choice()
# pagebreak
-> day_70_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 70 周日日报 (E10 末)
// ----------------------------------------------------------------------------

= day_70_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +12)_

_关键时刻 today:_
_  - 8:30 妈妈视频 "那个谁的儿子升职了。年薪 60 万。" (第一次给具体数字)_
_  - 21:30 Lisa 微信 verbatim "你别担心" + "我自己想想看怎么办" (E10 → E11 cliffhanger)_
_  - lisa_helped_self_review = {lisa_helped_self_review}_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 11 周 — 周末加班周, Decision Moment 2 路径分叉点_

// E10 结束 - cliffhanger 到 E11 周一 Lisa 左手手心又开始写"加油"(S1 motif 复活)

-> END

// ============================================================================
// EOF episode-10.ink
// ============================================================================
//
// 分身 task summary (S3 ink writer R1):
//   - Day 64-70 全 7 天 stitches 完整
//   - D64 David 145% 王总监没接 + 王总监 reframe "PPT" → "HR review"
//   - D65 王总监独立办公室门口 cue 笑天 "Lisa PPT 看过没" (笑天工具化第 1 次)
//   - D65 Lisa 中午没吃饭 (1 小时盒饭没动, 5 分钟解决)
//   - D66 Lisa verbatim "在赶" 王总监没接 (王总监完全 disengage)
//   - D66 David 茶水间第 2 次不耐烦 IT 小马 (S6 燃尽 setup)
//   - ★ D67 Zoe 14:00 90 分钟面谈 (HR 处刑形态显形 S3 第 1 次) ★
//   - ★ D67 18:00 Decision Moment 帮 Lisa 改 self_review (路径 A 第 1 关键 hero flag) ★
//   - D68 茶水间听到隔壁洗手间哭 1 声 + Lisa 9:00 撒谎"地铁延误"
//   - D68 Zoe 桌上快餐盒 + 小红书《我做 HR 第 3 年我也想走》(Zoe C Vulnerability)
//   - ★ D68 17:35 李阿姨 verbatim "这家公司的人每两个月走一茬" (集内最深扎心) ★
//   - D70 妈妈第一次给具体数字"年薪 60 万"
//   - D70 21:30 Lisa verbatim "你别担心" + "我自己想想" (E10 → E11 cliffhanger)
//
// 笑/泪比 = 4:6 (per season-3-arc.md §1):
//   - 笑点: D64 David 145% 没人接 / D66 6 分钟散会 / D66 IT v3 告示 / D69 David spinning / D70 妈妈"年薪 60 万"
//   - 扎点: D64 王总监 reframe / D65 王总监工具化笑天 + Lisa 没吃饭 / D66 王总监 disengage Lisa /
//          D67 Zoe 90 分钟 + Decision Moment / D68 Lisa 偷哭 + 撒谎 / D68 Zoe Vulnerability /
//          D68 李阿姨 verbatim / D70 妈妈 60 万 + Lisa cliffhanger
//
// 红线 (S3 不能做):
//   - Lisa 不决定走/留 ✓ (D67 仅"我自己想想看怎么办")
//   - 王总监不直接对 Lisa "你不适合" ✓
//   - 老周 S3 0 dialog ✓ (D67 仅"抬头 0.5 秒看 Lisa 走方向")
//   - 林姐不出场 ✓
//   - David 不燃尽 ✓ (D66 仅 setup deepening)
//
// END
