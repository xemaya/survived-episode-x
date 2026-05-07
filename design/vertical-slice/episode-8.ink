// ============================================================================
// Episode 8 · Week 8 · 「HR 月度面谈」(Season 2 Finale)
// ============================================================================
//
// Status: 第 1 版 (W3 写, S2 Round 1)
// Author: 分身 CC session (W3 = S2 Round 1)
// Last Updated: 2026-05-05
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
// 主 spec: design/vertical-slice/season-2-arc.md §5 E8 beat sheet + §6 5 路径表
//
// 设计目标 (摘要):
//   1. S2 高潮 — HR 第一次系统性介入 Lisa
//   2. Lisa 仍然没"走" — 但她说"我可能要走" (S3 finale = E12 才决定)
//   3. 周四 14:30 Zoe 走到 Lisa 工位旁"方便的话..." (HR 系统第 1 次显形)
//   4. 周日 21:30 Lisa 微信 "Zoe 说我'潜力一般'" + "我可能要走" (S2 finale 5 路径)
//   5. 周日 8:30 妈妈视频"我下个月想去你那边看看你" (第一次主动)
//   6. 3:7 扎为主 — 上半周轻笑, 下半周扎到底
//   7. Series Cliffhanger 至 S3: 周日 21:30 Lisa "**但 Zoe 说下个月再看看。我可能不该太担心**。"
//
// 红线 (S2 不能做 - per season-2-arc.md §11):
//   - Lisa **不能决定走/留** (E12 才走/留) — 她只能说"我可能要走"
//   - 王总监不能直接对 Lisa 讲"潜力一般" (Zoe 的工作 / 月度面谈才说) ✓
//   - David 不能燃尽 (E24)
//   - 老周不能说出第二句话
//   - 林姐不能出场
//   - 玩家不能在 S2 finale "救" Lisa — 只能 setup S3 路径
//   - Lisa 完整 backstory 不能 expose
//
// Verbatim quotes 必保留 (per season-2-arc.md §6):
//   - E8 周日: 妈妈视频 "**我下个月想去你那边看看你**"
//   - E8 周日: Lisa 微信 "**Zoe 找我谈了月度面谈。她说我'潜力一般'**"
//   - E8 末: Lisa 微信 "**但 Zoe 说下个月再看看。我可能不该太担心。**"
//
// ============================================================================

INCLUDE episode-1.ink

// E8 entry
-> episode_8


// ============================================================================
// Episode 8 主入口
// ============================================================================

=== episode_8 ===
# scene: home
# time: monday_morning_week_8
# pagebreak
-> day_50_morning_briefing


// ============================================================================
// Day 50 · 周一 · Vivian 贴"月度面谈安排" + 王总监表扬 Lisa 但没人接话
// ============================================================================
// 关键 beat:
//   - Vivian 打卡台贴"本月度月度面谈安排" (无名单)
//   - 王总监表扬 Lisa "上次客户对接 PPT 不错" — 但没人接话, Lisa 自己也不接
//   - 王总监 C Vulnerability layer 3 — 他试图给 Lisa "下台阶" 但失败

= day_50_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:11
# weather: cleared

闹钟响了 1 次。

_S2 第 8 周, 月底了。_

_这周 Lisa 要去 HR 月度面谈。_

_她周日 21:30 prep 我的——"下周一可能要去 HR 那边"。_

_今天周一。_

# scene: office_entrance
# time: 9:11
# npc: vivian_at_reception
# prop: fruit_bowl_apple
# prop: poster_monthly_review_schedule

9:11 到公司。

Vivian "嗨～来啦～"。

她**站起来**——她平时坐着的。

"诶你看下打卡台旁边的海报。"

她**指了一下打卡台**。

打卡台旁边——

新海报：

> "本月度月度面谈安排"
> "日期：5/27 (周四)"
> "地点：HR 工位区"
> "名单：仅相关同事会被单独通知"

下面**没有名单**。

但下面有**HR 公章**——这是正式流程。

_本月度月度面谈安排。_

_5/27 周四。_

_今天周一 5/24。3 天后。_

_她周日"下周一可能去 HR" 她可能预约错日子——周一她去预约, 周四她真去面谈。_

_或者她周一去, 周四再去——2 次。_

_Vivian 指我看海报——她 know 我在 follow。_

_她又一次"破"。_

水果盘**仍是苹果**。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_50_event_1_morning_meeting_praise


// ----------------------------------------------------------------------------
// Event 50.1 · 晨会 王总监表扬 Lisa "上次客户对接 PPT 不错" · 9:35
// ----------------------------------------------------------------------------
// 触发: 周一晨会 (Note: S1 只周三晨会, 但 S2 第 8 周月底有周一加了一场)
// 速度: 长 (~12 行)
// 同框: 王总监 + David + Lisa + 老周 (背景) + 笑天
// NPC archetype: 王总监 C Vulnerability layer 3 — 试图给 Lisa "下台阶" 但失败
// ----------------------------------------------------------------------------

= day_50_event_1_morning_meeting_praise
# scene: meeting_room
# time: 9:35
# npc: wang_at_podium
# npc: lisa_short_hair_in_first_row
# npc: david_with_3_sticky_notes
# npc: lao_zhou_in_back

周一加了一场晨会——月底。

王总监打开 PPT。今天封面是"**本月度收官**"。

"上午好啊各位。"

"我们这个月辛苦了。"

_他 60 周开场都是"我们这个团队啊"。_

_今天他改了——"我们这个月"。_

_细节变化。但 Lisa 没注意到——她在记笔记。_

# speaker: wang_director
王总监："David 这边 pps demo 推了 4 版, 客户 lock-in。"

# speaker: david
David: "嗯。"

# speaker: wang_director
王总监: "Lisa——"

王总监 0.5 秒。

"**Lisa 上次那个客户对接 PPT 不错**。"

会议室静了。

David **没接话**。
老周**喝茶**。
Lisa **抬头**, **笑了一下 0.5 秒**, **没说话**。

王总监等了 1 秒。

没人接。

# speaker: wang_director
王总监："嗯。"

他**自己**接：

"这周——这周我们继续。"

他换下一张 PPT。

_王总监试图给 Lisa "下台阶"。_

_他知道周四 Zoe 找她。他知道她"潜力一般"是 backstage 已定的。_

_他临阵给她 1 句表扬——public face value。_

_他想 frame 是"她 OK 但月度面谈是流程"。_

_但**没人接他的台阶**。_

_David 不接是因为他不想 boost Lisa——竞争。_

_Lisa 不接是因为她**已经知道**。_

_老周不接因为他从不接。_

_笑天不接因为笑天是 outsider。_

_王总监**自己接自己**——"嗯, 这周我们继续"。_

_他 PUA 链条破了。_

_S1 我以为他是 fully PUA—— S2 第 7 周我看到他 backstage 电话, S2 第 8 周我看到他**当场 fail 一次给 Lisa 下台阶**。_

_他也是 puppet。但他**也想 protect Lisa** 一下——只是他没能力 frame。_

_他可能 5 年前能。现在他 45 岁, 自己都焦虑公司年轻化。_

_他保不住 Lisa。_

_他可能也保不住自己。_

_他 S9 finale 被换。_

_今天他 trail run 一下 fail 给 Lisa 下台阶——这是给 himself rehearse。_

# speaker: wang_director
王总监："散会。"

8 分钟。

// 没有选项 - 王总监 C Vulnerability layer 3

// hidden flag: 王总监 D50 试图给 Lisa "下台阶" 但 fail

~ check_state_after_choice()
-> day_50_event_2_lisa_after_meeting


// ----------------------------------------------------------------------------
// Event 50.2 · 散会回工位 · 9:42
// ----------------------------------------------------------------------------

= day_50_event_2_lisa_after_meeting
# scene: hallway_back
# time: 9:42
# npc: lisa_walking_silently

9:42。Lisa 直接回工位。

她**没看王总监**。

她**没看你**。

她 3 米开外, 你跟在她后面。

她进工位, 坐下, **直接开屏幕**。

她没换姿势。

她下午都没站起来。

_她在 process 王总监的"表扬"。_

_她可能在想"他在演 face"。_

_或者她单纯麻木了。_

_她不会跟我说。_

_今天周一她不去 HR——她周四去。周一是 mid-week prep。_

// 没有选项 - flavor

~ check_state_after_choice()
-> day_50_after_work


= day_50_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在改 PPT。

* [申报加班]
    你回工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    Lisa 没看你。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_50_daily_recap


= day_50_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - Vivian 打卡台贴 "本月度月度面谈安排 5/27 周四" (无名单)_
_  - 王总监周一晨会**表扬 Lisa** "上次客户对接 PPT 不错"_
_  - **王总监试图给 Lisa "下台阶" 但没人接话** (王总监 C Vulnerability layer 3)_
_  - Lisa 散会后 0 间隔继续敲键盘_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_51_morning_briefing


// ============================================================================
// Day 51 · 周二 · David 4 点已经在写"周一计划" (S1 baseline 升级)
// ============================================================================

= day_51_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_workstation
# time: 9:11
# npc: lisa_at_v37

9:11 到公司。Lisa 已经在工位。

她今天**戴帽子**——一顶黑色棒球帽。

短发 + 黑帽子 = 她想 even more 隐身。

* [开始今日]
    -> day_51_event_1_david_4pm_planner


// ----------------------------------------------------------------------------
// Event 51.1 · David 4 点已经在写"周一计划" · 16:00
// ----------------------------------------------------------------------------
// 触发: 第 5 个 event
// 速度: 标准 (~6 行)
// 同框: David + 笑天
// 设计意图: S1 D5 周五 17:30 David 写下周计划。S2 D51 周二 16:00 David 写下周计划
//          — David 卷的 baseline 又抬高了 (S6 finale 燃尽前兆 deepening)
// ----------------------------------------------------------------------------

= day_51_event_1_david_4pm_planner
# scene: workstation_with_david_visible
# time: 16:00
# npc: david_writing_next_week_plan_already

16:00。你回头看 David 工位。

David **正在写"下周一计划"**——他 Word 文档标题:

"**Week 9 Day 1 — Q2 Final Sprint Day 1 之 我的 4 大冲刺**"

_4 大冲刺。_

_他用了"final sprint"。_

_他给"周一" 加了 9 个字 prefix。_

_他周二 16:00 已经在写下周一。_

_S1 末他周五 17:30 写下周计划。_

_S2 第 8 周他周二 16:00 写下下周计划。_

_他**比 S1 末快 3 天 + 1.5 小时**。_

_他卷的 baseline 又抬高了。_

_S6 他会燃尽。_

_S2 第 8 周这是他 3 个月内**第 3 个 baseline 升级**。_

_他自己不知道——他以为他在"持续精进"。_

_他在收紧 spring。_

// 没有选项 - David S6 燃尽 setup deepening

// hidden flag: David D51 周二 16:00 写下下周计划 - S6 燃尽 setup

~ check_state_after_choice()
-> day_51_event_2_lisa_no_eat_3rd_day


// ----------------------------------------------------------------------------
// Event 51.2 · Lisa 中午不吃饭 第 3 天 · 12:30
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~3 行)
// 同框: Lisa (背景)
// ----------------------------------------------------------------------------

= day_51_event_2_lisa_no_eat_3rd_day
# scene: workstation_lunchtime
# time: 12:30
# npc: lisa_at_screen_no_movement

12:30。Lisa 没站起来。

E7 D43 周一不吃。
E8 D50 周一不吃。
E8 D51 周二**不吃**。

_3 天连续不吃午饭。_

_她在 fasting。_

_她可能减肥——剪短发后她想"换 image" 一并 reset 体型。_

_或者她单纯没胃口。_

_或者她想省钱——E8 月底, 她可能在攒钱准备 contingency。_

_或者她是在 punishment 自己——还没"够拼"。_

_4 种 reading 都对。_

_她可能 4 种都在做。_

// 没有选项 - quiet sign deepen

// hidden flag: Lisa D51 第 3 天连续不吃 - escalating

~ check_state_after_choice()
-> day_51_after_work


= day_51_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在改。

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
-> day_51_daily_recap


= day_51_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **David 周二 16:00 写下下周计划** "Q2 Final Sprint Day 1 之 我的 4 大冲刺" (S6 燃尽 setup)_
_  - Lisa 第 3 天不吃午饭 (escalating)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_52_morning_briefing


// ============================================================================
// Day 52 · 周三 · 晨会 王总监 cue Lisa "月度 KPI 怎么样"
// ============================================================================
// 关键 beat:
//   - 晨会 王总监 cue Lisa "Lisa 这边月度 KPI 怎么样" — Lisa "在赶" — 王总监没说什么

= day_52_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:25
# weather: cleared

周三。

# scene: meeting_room
# time: 9:25
# npc: lisa_first_row_with_hat

9:25 到会议室。

Lisa 戴帽子, 第一排——同周二一致。

David 笔记本 4 张便利贴, 加了"Q2 Final Sprint"。

老周后排。

9:32 王总监推门。

* [开始今日]
    -> day_52_event_1_morning_cue_lisa_again


// ----------------------------------------------------------------------------
// Event 52.1 · 晨会 王总监 cue Lisa "在赶" · 9:38
// ----------------------------------------------------------------------------
// 触发: 晨会进行中
// 速度: 长 (~10 行)
// 同框: 王总监 + David + Lisa + 老周 + 笑天
// 设计意图: S2 第 8 周王总监 second-time cue Lisa, 但他**没接 Lisa 答**——
//          他知道周四面谈, 他在 give space
// ----------------------------------------------------------------------------

= day_52_event_1_morning_cue_lisa_again
# scene: meeting_room_full
# time: 9:38
# npc: wang_no_eye_contact_with_lisa

王总监打开 PPT。今天是"**月底 final 倒数**"。

"上午好。"

"我们这个月还差 5 天。"

# speaker: wang_director
王总监："David 这边 deliverable 100% 完成确认。"

# speaker: david
David: "嗯。"

# speaker: wang_director
王总监: "**Lisa——这边月度 KPI 怎么样?**"

王总监**眼睛没看 Lisa**——他看 PPT。

# speaker: lisa
Lisa: "**在赶。**"

王总监 0.5 秒。

"嗯。"

他**没说"那加把劲"**——他没接 follow up。

他直接换 PPT 下一张。

_他没说"加把劲"。_

_S2 第 6 周他对 Lisa 说"加把劲"。_

_S2 第 8 周他**没说**。_

_他知道周四面谈。_

_他给 Lisa space——不在公开场合再加压。_

_他在 backstage 已经"让她做好心理准备"。_

_公开他**减压**。_

_这就是中层 — backstage push, public face value 减压。_

_我以为他不在乎她, S2 末我看到他**也想 protect 她** 一下——但他用错方式。_

_或者他知道公开"加把劲" 会让 Lisa 在月度面谈时哭。哭= scene。_

_所以他给她 hint, 不让她出 scene。_

_这是 corporate kindness——克制是为了 process clean。_

# speaker: wang_director
王总监: "散会。"

7 分钟。

// 没有选项 - 王总监 减压 backstage continuity

// hidden flag: 王总监 D52 不再说"加把劲" - backstage 减压

~ check_state_after_choice()
-> day_52_event_2_quiet_workstation


// ----------------------------------------------------------------------------
// Event 52.2 · 工位 quiet · 14:00
// ----------------------------------------------------------------------------

= day_52_event_2_quiet_workstation
# scene: workstation_quiet
# time: 14:00
# npc: lisa_at_v40

14:00。

Lisa V40。

老周面对窗户看 Excel——同 12 年一致。

David 在 4-sticky-note word 文档上 add 第 5 张便利贴。

笑天在工位刷企业微信——他在等 Zoe 或王总监"再 contact" 但没人。

_明天周四 14:30 Zoe 找 Lisa。_

_但今天没人 contact 我。_

_我成了 outsider。_

_S1 我是 outsider 自愿。_

_S2 第 8 周我是 outsider 被 confirm。_

_因为 Zoe 周二找我 5 分钟之后没再来。_

_我不在月度面谈名单上。_

_我也不在 1v1 王总监 deliverable list 上的下一个 cue 名单。_

_我是 stable middle—— Lisa 之上, 笑天之下 (打工的"笑天" 倒序排), David 之外。_

_stable middle 不被 cue, 不被 promote, 不被裁。_

_不是因为我做对了——是因为我"做的东西**够 average**"。_

_average is safe。_

_这就是 S1 教学集教过我的: anti-Pillar 1 "做对了反而下月更难" 反过来也成立——"average 反而是最 sustainable 的"。_

_我已经 internalize 了。_

// 没有选项 - 笑天 stable middle awareness

~ check_state_after_choice()
-> day_52_after_work


= day_52_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在敲。

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
-> day_52_daily_recap


= day_52_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 晨会 王总监 cue Lisa "在赶" — 王总监**没说"加把劲"** (backstage 减压)_
_  - 笑天 stable middle awareness (S1 教学集 internalize)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_53_morning_briefing


// ============================================================================
// Day 53 · 周四 · ★ 14:30 Zoe 走到 Lisa 工位旁 ★ (S2 集内最高峰)
// ============================================================================
// 关键 beat:
//   - 14:30 Zoe 走到 Lisa 工位旁"Lisa 你这边方便的话..."
//   - Lisa 跟 Zoe 去 HR 工位 → **笑天看着 Lisa 走出工位 area**
//   - Series-wide HR 系统第 1 次显形

= day_53_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周四。

# scene: office_workstation
# time: 9:11
# npc: lisa_short_hair_with_hat_again
# prop: lisa_eye_drops_almost_empty

9:11 到公司。

Lisa 戴帽子, 短发, 还在改 PPT。

她桌上眼药水——**几乎空了**, 比 E5 D29 那瓶 + 4 周。

她**没买新瓶**。

_她在用最后几滴。_

_她可能今天会去药店买新瓶。_

_或者她不买——她下周可能不需要了 (因为她可能不来)。_

_3 个月前她买这瓶时是为了"撑过去"。_

_今天她在用最后几滴是为了"撑过这周"。_

_我意识到我也在用最后几滴。_

* [开始今日]
    -> day_53_event_1_zoe_arrives_at_lisa


// ----------------------------------------------------------------------------
// Event 53.1 · 14:30 Zoe 走到 Lisa 工位旁 · 14:30 (集内最高峰)
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 长 (~14 行)
// 同框: Zoe + Lisa + 笑天 (远端 watching)
// NPC archetype: HR 系统第 1 次系统性介入
// ----------------------------------------------------------------------------

= day_53_event_1_zoe_arrives_at_lisa
# scene: workstation_with_zoe_arriving_at_lisa
# time: 14:30
# npc: zoe_in_black_jacket_arrival
# npc: lisa_short_hair_looking_up

14:30。

你正在写周报。

你余光看到 Zoe 走过来——她走到**Lisa 工位**, 不是你的。

她站在 Lisa 工位旁。

她没看你, 没看 David。

她对 Lisa 说: "**Lisa 你这边方便的话, 我们去 HR 工位聊一下哈。**"

Lisa **抬头看 Zoe 0.5 秒**——

她**没**惊讶。

她预知到这一刻。

# speaker: lisa
Lisa: "嗯, 现在?"

# speaker: zoe
Zoe: "嗯, 5 分钟够了。"

_5 分钟。_

_Zoe 用同样的"5 分钟"——周二她对我也"5 分钟"。_

_5 分钟 = HR 标准面谈短话术。_

_它 5 分钟够吗? 可能 35 分钟。_

_5 分钟是话术降压。_

Lisa 站起来。

她**关电脑屏幕**——她不让我看到。

她拿手机, 没拿水, 没拿包。

她跟 Zoe 走。

# scene: workstation_lisa_walking_out

你看着她走——

她经过你工位 1 米。

她**没看你**。

她**没说"我去一下"**。

她直接跟 Zoe 走。

她走到工位区门口。

# scene: workstation_lisa_now_outside_zone

她出了工位 area。

你看不见她了。

她**走出工位 area**——这是 series-wide HR 系统第 1 次直接显形。

你回头看 David。

David 在敲键盘。**他没抬头**。

David 周日朋友圈"Q2 完美收官"——今天 Lisa 被 Zoe 叫去 HR, David 没抬头。

老周喝茶——他抬头 0.3 秒, 又低下。

他知道。

笑天: 14:30 + 5 分钟 = 14:35。Lisa 14:35 应该回。

14:35——Lisa **没回**。

14:50——**没回**。

15:00——**没回**。

15:15——**没回**。

15:30 Lisa 回来。

她**1 小时**。

不是 5 分钟。

她坐回工位, 开屏幕, 继续改。

她**没看你**。

她**没说话**。

她滴眼药水——最后 3 滴, 瓶子空了。

她把空瓶推到桌角, 没扔。

_1 小时面谈。_

_5 分钟是话术降压。_

_她 1 小时回来, 直接打字, 不告诉我她 1 小时里听了什么。_

_她很专业。_

_或者她在装专业。_

_或者两者一样。_

* [发个微信关心]
    你发: "你刚才...?"
    Lisa 没回。
    20 分钟后她回: "嗯, 没事。"
    _2 个字。_
    ~ lisa_score = lisa_score + 2

* [不主动]
    你继续敲自己周报。
    Lisa 也敲。
    工位静默 2 小时。
    ~ lisa_score = lisa_score + 0

- _不论选什么。_
- _她 1 小时面谈。_
- _周日她会跟我说细节。_
- _今天她不说。_

// hidden flag: Zoe D53 14:30-15:30 找 Lisa 月度面谈 = 1 小时 (HR 系统第 1 次显形)
// hidden flag: 笑天看到 Lisa 走出工位 area

~ check_state_after_choice()
-> day_53_after_work


= day_53_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_silent_typing

17:30。Lisa **依然在**——还在敲。

她下午剩下 2 小时一句话没说。

她加班——你不知道她到几点。

* [申报加班]
    你回工位陪。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1
    ~ lisa_score = lisa_score + 1

* [按时下班]
    你收拾东西。
    Lisa 没看你。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_53_daily_recap


= day_53_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **14:30 Zoe 走到 Lisa 工位"方便的话..."** — HR 系统第 1 次显形 ★_
_  - Lisa 跟 Zoe 去 HR — **笑天看着她走出工位 area**_
_  - Lisa 1 小时后回来 — 直接打字, 不说话_
_  - Lisa 眼药水最后 3 滴, 空瓶_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_54_morning_briefing


// ============================================================================
// Day 54 · 周五 · weekly_recap · Lisa 工位空了一下午
// ============================================================================
// 关键 beat:
//   - weekly_recap overlay
//   - Lisa 周五下午请假 — Lisa 工位空了一下午

= day_54_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared

周五。

# scene: office_workstation
# time: 9:08
# npc: lisa_at_v45

9:08 到公司。

Lisa **在工位**——还在敲。

她今天**没戴帽子**。

她穿**深色衬衫**——同上周五。

她桌上**没有眼药水**——空瓶被扔了。

她**也没买新瓶**。

_她空瓶扔了。_

_她不再用眼药水。_

_她可能买不起 (经济考虑) — 不太可能, 一瓶 ¥18。_

_她可能不需要 (心情考虑) — 但她还在打 PPT, 她还需要。_

_她可能放弃 (心理考虑) — 她不再"撑过去"。_

_她周日朋友圈"这周辛苦了"。_

_她周一"想换个心情"。_

_她周四面谈 1 小时。_

_她周五**不再用眼药水**。_

_她在 strip everything down。_

* [开始今日]
    -> day_54_event_1_weekly_recap


// ----------------------------------------------------------------------------
// Event 54.1 · weekly_recap · 11:00
// ----------------------------------------------------------------------------

= day_54_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 11:00
# diegetic_ui: phone_show_weekly_recap_overlay

11:00。HR 系统弹出周报浮层。

- 出勤率: 100%
- 主动产出条目: 取决于 D 50-53 选择
- 协作记录: 取决于本周 Lisa / David / 王总监 选择

浮层底部："**本月度 KPI 还有 2 天 (周日 9:30 推送月末通报 + S2 月度 finale)**"。

_本月度 KPI 还有 2 天。_

_周日 5/30 月末通报——这是 S2 第 4 个 (也是最后一个)。_

_S1 末是 5/2。S2 是 5/9, 5/16, 5/23, **5/30**——4 周。_

_5/30 也是 Lisa 月度面谈结果会被 communicate 的时间——通过 Zoe 周日发一份"建议"邮件。_

_Lisa 周日就知道。_

_她可能周日晚 21:30 跟我说。_

_或者她不说。_

// hidden flag: D54 周五 HR 浮层 + 周日 5/30 月末通报 setup

~ check_state_after_choice()
-> day_54_event_2_lisa_takes_afternoon_off


// ----------------------------------------------------------------------------
// Event 54.2 · 11:50 笑天发现 Lisa polo 外套不在 · 11:50 (Q3 改 ambient discovery)
// ----------------------------------------------------------------------------
// 触发: 午饭前
// 速度: 闪 (~5 行)
// 同框: Lisa (已离开, 工位空) + 笑天
// 设计意图: Q3 R2 改 — Lisa 不再 small-talk, 笑天 ambient 发现请假
// ----------------------------------------------------------------------------

= day_54_event_2_lisa_takes_afternoon_off
# scene: workstation_pre_lunch_quiet
# time: 11:50
# npc: lisa_workstation_already_quiet

11:50。你站起来去茶水间。

你接完水回工位——

Lisa 工位上的**polo 外套不在**。

她平时把外套搭在椅背上——不管热不热, 上班她会搭。

今天椅背是空的。

椅子推开了一点。

电脑屏幕**关了**——她平时午休不关屏幕, 只锁屏。

_她走了。_

_她没说"我去吃饭"。_

_她没发企业微信。_

_她不在群里。_

_我不知道她什么时候走的——可能 11:30, 可能 11:45。_

_她也没告诉我。_

_她不再 small-talk。_

// 没有选项 - ambient discovery
// hidden flag: Lisa D54 11:50 笑天发现外套不在 - 不知何时走的

~ check_state_after_choice()
-> day_54_event_3_empty_workstation


// ----------------------------------------------------------------------------
// Event 54.3 · 下午 3 次 ambient sweep · 13:30 / 14:30 / 16:00 (Q3 改 ambient)
// ----------------------------------------------------------------------------

= day_54_event_3_empty_workstation
# scene: workstation_with_lisa_empty_3_sweeps
# time: 13:30
# npc: lisa_workstation_empty

13:30。你回工位。

Lisa 工位仍空。

# scene: workstation_with_lisa_empty_2_30
# time: 14:30

14:30。Lisa 工位仍空。

# scene: workstation_with_lisa_empty_4
# time: 16:00

16:00。Lisa 工位仍空。

她小玩偶**还在**桌上——她带走电脑, 没带玩偶。

她奶茶杯**空着**, 干掉的奶。

她空眼药水瓶**还在桌角**——她周五早扔了, 但只扔进了她自己抽屉, 桌角空瓶是另一瓶 (我没看清是不是同一瓶)。

她椅子**对窗户**——她平时面对屏幕。她离开前转椅子, 让椅子面对窗户。

_S1 D7 周日笑天独自去公司 — 笑天看着空工位是 E1 唯一轻扎。_

_今天 Lisa 工位空着——是另一种轻扎。她还在公司里, 但她"不在工位 area"——她是 self-removed。_

_S1 我看 Lisa 工位空 (周末)。S2 第 8 周我看 Lisa 工位空 (工作日)。_

_我不知道她何时走, 何时回, 或者她是不是周一才回。_

// 没有选项 - flavor 沉默

~ state = state - 5

~ check_state_after_choice()
-> day_54_after_work


= day_54_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_workstation_still_empty

17:30。Lisa 工位**仍然空着**。

* [自己回家]
    你出门。
    _周五晚地球继续转动。_
    ~ state = state + 0

-

~ check_state_after_choice()
# pagebreak
-> day_54_daily_recap


= day_54_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 2 天 (周日 5/30 月末通报)_

_关键时刻 today:_
_  - Lisa 桌上眼药水空瓶 — 不再补充_
_  - **Lisa 周五下午请假** — 工位空了一下午_
_  - 笑天看着空工位 1 分钟_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_55_weekend_morning


// ============================================================================
// Day 55 · 周六 · 周末
// ============================================================================

= day_55_weekend_morning
# scene: bedroom
# time: 12:00
# music: weekend_silence

你睡到 12:00 醒。

_S2 第 1 周 11:14, 第 2 周 11:32, 第 8 周 12:00。_

_我每周晚 10 分钟。_

_我在加速退步。_

# diegetic_ui: phone_wechat_moments

朋友圈：

David 发了"**Q2 收官! 4 周冲刺, 4 大项目, 4 个新里程碑**"。

_他用了 4 个 4。_

_他也在 spinning + 加速。_

_他周日加班 + 周一 Q2 final + 周五没下班——他 baseline 已经是 7 天工作。_

_S6 finale 他会燃尽。S2 第 8 周这是他最后一次 sustained spin。_

Lisa 朋友圈最新一条**还是 5/16 "这周辛苦了"**——21 + 14 = 35 天没新发。

但她**点过赞**——你周末晚发的一张外卖照, Lisa 给你点了 1 个赞。

_她 35 天没发朋友圈, 但她点了我的赞。_

_她 maintain 着 social presence, 通过别人 instead of self-presence。_

_或者她单纯打开朋友圈消磨时间, 顺手点了。_

11:34, 你点外卖。35 块。
~ money = money - 35

* [开始今日]
    -> day_55_event_1_lisa_lifestyle_unknown


// ----------------------------------------------------------------------------
// Event 55.1 · 周六下午 · Lisa 不主动联系
// ----------------------------------------------------------------------------

= day_55_event_1_lisa_lifestyle_unknown
# scene: bedroom_afternoon
# time: 14:00
# diegetic_ui: phone_wechat_check

下午 2 点。

你看了 Lisa 的微信状态——

她的状态从"**忙**" 改成**空白**。

_她空白了。_

_她不再 broadcast "忙"。_

_她可能在休息。或者她不需要再 mark 自己的 state。_

_她周五下午请假后, 她在 detoxing。_

_或者她在 active prep — prep 跟笑天的周日 21:30 微信。_

_或者两者一样。_

你又躺了 30 分钟。

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_55_daily_recap


= day_55_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 12:00 起床 (S2 末加速退步 baseline)_
_  - Lisa 微信状态从"忙" 改空白_
_  - Lisa 35 天没发朋友圈, 但给你点过赞 (social presence via others)_

# pagebreak
-> day_56_weekend_morning


// ============================================================================
// Day 56 · 周日 · 妈妈"我下个月想去你那看看你" + Lisa 微信"我可能要走"
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈视频 "**天天, 我下个月想去你那边看看你**" (verbatim, 第一次主动)
//   - 21:30 Lisa 微信 "**Zoe 找我谈了月度面谈。她说我'潜力一般'**" (verbatim) +
//          末尾 "**但 Zoe 说下个月再看看。我可能不该太担心**" (verbatim)
//   - S2 finale 5 路径 Decision

= day_56_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日 5/30。

S2 最后一天。

你 8:23 醒。

_今天她会说什么。_

_上周妈"姨说她有个朋友的女儿..." 自 cut。_

_这周可能 escalate。_

_或者她也 cut。_

_或者她直接说出来——"我下个月去你那看看"。_

_她在过去 6 个月有没有提过"去你那"?_

_有 1 次, 8 个月前——她说过"等天气好了我去你那"。_

_她从没说"下个月"。_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_56_event_1_mom_video_visit


// ----------------------------------------------------------------------------
// Event 56.1 · 妈妈视频 "我下个月想去你那边看看你" · 8:30 (verbatim, 第一次主动)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~14 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 D Finale moment - 第一次主动说要来
// Verbatim: "我下个月想去你那边看看你" 必保留 (per season-2-arc.md §6)
// ----------------------------------------------------------------------------

= day_56_event_1_mom_video_visit
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen

屏幕里是妈妈。

她戴老花眼镜, 厨房油烟机背景。

# speaker: mama
妈妈："**天天, 吃了吗?**"

# speaker: protagonist
你："吃了。"

# speaker: mama
妈妈："**工资发了吗?**"

# speaker: protagonist
你："发了。"

_S2 末发的, 12000——比上月涨 1000 (S1 路径累积影响, 也可能 S2 第 7 周加班 KPI 涨)。_

_你也不知道。但你嘴上"发了"。_

# speaker: mama
妈妈："**那个谁的儿子结婚了。**"

# speaker: protagonist
你："嗯。"

妈妈停了一下。

她**眯眼**——she 把视频拉近。

她**坐下了**——平时她站着说话。

# speaker: mama
妈妈：

"**天天——**"

她 0.5 秒。

"**我下个月想去你那边看看你。**"

15 个字。

她**说完了**。

她**没自 cut**。

_她说出来了。_

_S2 D49 周日她"姨说她有个朋友的女儿..." 自 cut。_

_S2 D56 周日她**直接说"我下个月想去你那"**。_

_她没自 cut。_

_她**主动**了。_

_她从未主动。_

_她每周日 8:30 视频是 broadcast。_

_今天她请求。_

_她**第一次**请求。_

_她不知道她第一次请求是 verbatim 经典。_

_或者她知道——她在过去 6 个月 build 这一刻。_

_我妈在 prep 跟我做一次 face-to-face。_

_我不能拒绝——拒绝 = 我"不孝"。_

_我不能答应——答应 = 她看到我**的真实生活**: 1 居室 + 加班痕迹 + 没洗的内衣。_

_她会知道我没"当 leader"。_

_她会哭。_

_或者她不哭。_

_或者她冷静地"哦, 知道了, 妈下次还来"。_

_无论她怎么 react, 我的 cover story 完蛋。_

* [好啊妈]
    # speaker: mama
    妈妈：愣 0.5 秒。
    "好。" 她笑了——是真心笑, 不是 cushion 那种。
    她 0.5 秒。"我下周末看高铁票。"
    _她当真——她要看高铁票了。_
    ~ mom_score = mom_score + 5
    ~ mom_visit_pending = true
    // S3 spec setup: mom_visit_pending = true

* [下个月不行妈, 太忙了]
    # speaker: mama
    妈妈："好——"
    _她说"好" 0.5 秒后她说: "那妈下个月不打扰你。"_
    _她 register 了。_
    _她可能 7-8 月再提, 也可能 S3 / S4 不再提。_
    _她在 give up?_
    "下下个月吧。"
    "嗯。"
    ~ mom_score = mom_score - 1
    ~ mom_visit_postponed = true
    // S3 spec: mom_visit_postponed = true

* [我那边乱啊, 不方便妈]
    # speaker: mama
    妈妈："**乱什么乱**, 妈这一辈子整理过几个家?"
    _她笑了——是逗。_
    "妈来了顺便给你打扫一下啊。"
    _她 reframe — "看你" → "打扫"。_
    "妈, 我自己打扫。"
    # speaker: mama
    妈妈："那妈不来了。"
    _她接得快——她在让我"自己打扫"作 face-saving。_
    ~ mom_score = mom_score + 0

* [妈让我想想]
    # speaker: mama
    妈妈："好。" (她也"好"。)
    _她不催。_
    _她下周日会再问。_
    ~ mom_score = mom_score + 1
    ~ mom_visit_pending_undecided = true
    // S3 setup: mom_visit_pending_undecided = true

- _不论选什么。_
- _她说出来了。_
- _15 个字她 build 了 6 个月。_
- _下周或者下下周或者 S3 第 1 周, 这件事会再来。_

// hidden flag: 妈妈 D56 verbatim "我下个月想去你那边看看你" - 第一次主动 (per §6)

~ check_state_after_choice()
-> day_56_event_2_lisa_workstation_empty_today


// ----------------------------------------------------------------------------
// Event 56.2 · 周日下午 · 笑天等 Lisa 微信
// ----------------------------------------------------------------------------

= day_56_event_2_lisa_workstation_empty_today
# scene: bedroom_afternoon_waiting
# time: 14:00
# diegetic_ui: phone_check_status_repeatedly

下午 2 点。

你看 Lisa 微信——状态空白。

你刷了 5 次朋友圈——她**没发**新的。

你刷了 3 次群——王总监**没说**话。

5/30 周日 9:30 月末通报浮层弹出过——你看了, 你的下月 threshold 又涨 5%。

你 register 了。你不再 emotional react。

_anti-Pillar 1 第 8 次咬。_

_我已经 numbed。_

下午你点了一份 Lisa 平时点的奶茶——18 块。
~ money = money - 18

_我点 Lisa 的奶茶, 但 Lisa 周一不再点了。_

_我在 take over 她的 ritual。_

_或者我在 mourning 她还没走的事。_

_或者两者一样。_

你等 Lisa 21:30 微信。

她可能不发——她 lisa_score < 0 时她不发 (路径 E)。

她可能发——她 lisa_score >= 0 时她发。

你不知道哪种。

你刷手机 5 小时。

// 没有选项 - 等待

~ state = state + 5

~ check_state_after_choice()
-> day_56_event_3_lisa_finale_message


// ----------------------------------------------------------------------------
// Event 56.3 · Lisa 微信 "Zoe 说我'潜力一般'" + 笑天 5 路径 Decision · 21:30
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 长 (~20 行)
// 同框: Lisa (微信)
// NPC archetype: Lisa S2 finale Decision Moment - S2 finale 5 路径
// Verbatim: "Zoe 找我谈了月度面谈。她说我'潜力一般'" + "但 Zoe 说下个月再看看。我可能不该太担心。"
// ----------------------------------------------------------------------------

= day_56_event_3_lisa_finale_message
# scene: home_evening
# time: 21:30
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:30。你刚洗完澡。

# diegetic_ui: phone_wechat_lisa_message_full

// 注: 路径 D (sick_count >= 2 → 笑天没看微信) + 路径 E (lisa_score < 0 → Lisa 没发)
//     在 TS runtime 拦截层处理 (story.ChoosePathString 直接跳到 day_56_path_d_unread
//     / day_56_path_e_no_message stitch)。本 stitch 默认 path A/B/C 显示。

微信消息 1 条。

# speaker: lisa
Lisa：

"笑天——"

"**Zoe 找我谈了月度面谈。她说我'潜力一般'**, 希望下个月再看看。"

26 个字。

# diegetic_ui: phone_wechat_lisa_typing_indicator

她**还在打字**——typing indicator 持续 1 分钟。

她又发：

"我下午请假是去客户成功部那边走了一下——林姐让我先在这边再呆一个月。"

20 个字。

_林姐。_

_S1 E1 周四王总监打电话提林姐。_

_S2 E5 周三 Lisa 去林姐那 review。_

_S2 E6 周二 Zoe "记得 cc 林姐"。_

_S2 E8 周日今晚 — Lisa 跟林姐谈过了。_

_林姐让她"再呆一个月"——这是 S3 路径 A 的 setup。_

_林姐没说 yes 也没说 no — 她在 wait & see。_

_S3 第 1 集开局: Lisa 周一开始穿正装上班 (不再是 polo)。_

她又发：

"**我可能要走。**"

5 个字。

她又发——这是最后一条：

"**但 Zoe 说下个月再看看。我可能不该太担心。**"

19 个字。

_"我可能要走" + "但下个月再看看, 我可能不该太担心"。_

_她 self-contradict — 她说"可能要走" 然后立刻 cushion "可能不该太担心"。_

_她在 communicate 给我同时 communicate 给她自己。_

_她不能让自己确认"要走" — 那等于她 register loss。_

_她也不能完全否定"要走" — 那等于她 deny her own awareness。_

_她在 middle —— 跟我一起 middle。_

_她周日 21:30 在床上发 4 条微信 + 1 个 self-contradiction。_

_这是 series 第一次她对我 share 这种 private quanlity 内容。_

_她信任我。_

_或者她需要个人承载。_

_或者两者一样。_

* [我陪你想办法 (路径 A)]
    # speaker: protagonist
    你回："我陪你想办法。"
    Lisa 1 分钟没回。
    然后:"嗯。"
    "你周末方便聊吗?"
    你: "嗯。明天 ……"
    # speaker: lisa
    Lisa: "明天我先撑过周一。**周末再说吧。**"
    _她说"周末再说" — 不锁日, 给她和我都留出空间。_
    _S3 救 Lisa 路径 A 第 1 关键 flag locked, 但具体哪个周末看 S3 worker 决定。_
    ~ lisa_score = lisa_score + 5
    ~ weekend_with_lisa = true
    ~ lisa_helped_after_hr = true
    // S3 救 Lisa 路径 A 关键 flag locked
    -> day_56_path_a_helping

* [嗯, 听你的 (路径 B)]
    # speaker: protagonist
    你回："嗯, 听你的。"
    # speaker: lisa
    Lisa："嗯。"
    "晚安。"
    _她"晚安" — 不是平时的"明天见"。_
    _她在让你 take a step back。_
    _S3 Lisa 还会找你, 但她不会 over-rely。_
    ~ lisa_score = lisa_score + 0
    // hidden flag: lisa_supported_distantly (S3 路径 B/C 灵活)
    -> day_56_path_b_distant

* [嗯 (路径 C)]
    # speaker: protagonist
    你回："嗯。"
    Lisa 没回。
    20 分钟后她: "晚安。"
    _你只回 1 个字 — 她 register 你的 distance。_
    _S3 finale 路径 A 不可能触发 (Lisa 已经 mute 你)。_
    ~ lisa_score = lisa_score - 3
    // hidden flag: lisa_muted_xiaotian (S3 finale 路径 B 必走)
    -> day_56_path_c_split


= day_56_path_a_helping
# scene: home_evening_after_message
# time: 22:00

22:00。你在床上。

_我跟她下下周末聊。_

_她信我。_

_她信我什么? 她可能信"我有 idea"。_

_我没 idea。我自己也撑得勉强。_

_但她信。_

_我不能让她 disappoint。_

_我下下周末前要 generate idea。_

_或者我下下周末空手陪她。_

_2 种 reading 都对。_

_我可能 2 种都做。_

_我先睡。_

~ state = state - 5

~ check_state_after_choice()
# pagebreak
-> day_56_finale_recap


= day_56_path_b_distant
# scene: home_evening_after_message
# time: 22:00

22:00。你在床上。

_她"晚安"。她 distance。_

_她在 S2 第 8 周 cope alone — 她不让我 over-involve。_

_她对我 expression 是有 boundary 的。_

_或者她在 protect 我 — 她不让我 carry her weight。_

_她对我 protective 让我 surprise。_

_我先睡。_

~ state = state - 2

~ check_state_after_choice()
# pagebreak
-> day_56_finale_recap


= day_56_path_c_split
# scene: home_evening_after_message
# time: 22:00

22:00。你在床上。

_她说"晚安", 但她没说"明天见"。_

_她 register 我只回了 1 字。_

_她接受了。_

_她可能下周一不再主动找我。_

_她可能 polite morning_briefing 但不 small talk。_

_我们俩 maintain 工作关系, 不再 social。_

_S2 第 8 周, S3 路径 split。_

_我做选择。_

_我自己也不太确定为什么。_

_或者我确定 — 我累了。陪 Lisa 的情绪 cost 我太多。_

_我在 self-protect。_

_她可能也理解。_

~ state = state + 0

~ check_state_after_choice()
# pagebreak
-> day_56_finale_recap


= day_56_path_d_unread
# scene: home_evening_phone_dim
# time: 22:00

22:00。你在床上, **没看手机**。

你今天 sick_count >= 2 — 你可能在 S2 第 6 周 / 第 7 周生病过 1-2 次, 今晚你身体不好, 你直接关灯睡了。

Lisa 发了 4 条 + 1 个 self-contradiction。

你不知道。

明天周一你会刷手机看到, 你会 0.3 秒 confused, 然后 register Lisa 的 message。

你会回——但延迟 9 小时。

Lisa 周一 9:00 看你回 — 她会 register 你的延迟。

她不会怪你。

但她不会期待你了。

S3 finale: Lisa 走, 笑天看着 (delayed reaction 体验)。

~ state = state - 3

// hidden flag: lisa_xiaotian_delayed_path_d - S3 finale 路径 D 必走

~ check_state_after_choice()
# pagebreak
-> day_56_finale_recap


= day_56_path_e_no_message
# scene: home_evening
# time: 22:00

22:00。你在床上, 手机界面没有新消息。

Lisa 没发。

她 lisa_score < 0 — 她对你已经 distance 累积。

她周日 21:30 在她自己床上, 一个人 cope。

她不发给你, 她可能发给妈妈, 发给大学室友, 发给 stranger 在网上。

她没有 share with 你。

S3 finale 路径 B 必走 — Lisa 走, 笑天没看到。

你不知道她周日发生什么。

你 baseline 信息 = 周一她会不会来?

~ state = state + 0

// hidden flag: lisa_xiaotian_silent_path_e - S3 finale 路径 B 必走

~ check_state_after_choice()
# pagebreak
-> day_56_finale_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 56 周日日报 (E8 末 / S2 末 / Series cliffhanger)
// ----------------------------------------------------------------------------

= day_56_finale_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend
# diegetic_ui: phone_show_s2_finale_recap


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +12)_

_关键时刻 today (E8 finale):_
_  - 8:30 妈妈视频 "**我下个月想去你那边看看你**" (verbatim, 第一次主动)_
_  - 21:30 Lisa 微信 "Zoe 说我'潜力一般'" + "我可能要走" + "但下个月再看看, 我可能不该太担心" (verbatim)_
_  - S2 finale 5 路径 Decision Moment 完成_

_NPC scores 末 (S2 末):_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_S2 末 累积 flags (供 S3 用):_
_  - 病倒次数: {sick_count}_
_  - effort_overage: {effort_overage}_
_  - promotion_candidate_count: {promotion_candidate_count}_

// ----------------------------------------------------------------------------
// Series Cliffhanger 至 S3
// ----------------------------------------------------------------------------
// S3 第 1 集 (E9) 开局:
//   - Lisa 周一开始穿正装上班 (不再是 polo)
//   - 笑天 register 这个 visual signal
//   - S3 主题: 「不可能确认 / 必将失败」(per series-structure.md §2 S3)
//   - S3 finale = E12 Lisa 走/留 climax (8-12 集累积选择兑现)

// E8 / S2 结束

-> END

// ============================================================================
// EOF episode-8.ink
// ============================================================================
//
// 分身 task summary (W3 = S2 Round 1):
//   - Day 50-56 全 7 天 stitches 完整
//   - 王总监 D50 表扬 Lisa 但没人接话 = 王总监 C Vulnerability layer 3
//   - David D51 周二 16:00 写下下周计划 = S6 燃尽 setup deepening
//   - 王总监 D52 不再说"加把劲" = backstage 减压
//   - ★Zoe D53 14:30 走到 Lisa 工位"方便的话..."★ = HR 系统第 1 次显形
//   - Lisa D53 跟 Zoe 走 1 小时, 笑天看着她走出工位 area
//   - Lisa D54 周五下午请假 = 工位空了一下午
//   - 妈妈 D56 verbatim "我下个月想去你那边看看你" = 第一次主动
//   - Lisa D56 21:30 verbatim "Zoe 说我'潜力一般'" + "我可能要走" + "但下个月再看看, 我可能不该太担心"
//   - S2 finale 5 路径 Decision (A/B/C 玩家选 + D/E 状态触发)
//
// 笑/泪比 = 3:7 (per season-2-arc.md §1):
//   - 笑点: D50 王总监 fail 给 Lisa 下台阶 (PUA 链条破 absurdity) /
//          David "Q2 收官 4 个 4" / D51 David 周二写 Q2 Final Sprint
//   - 扎点: D50 王总监表扬没人接 / D51 Lisa 第 3 天不吃 / D52 王总监不说"加把劲" /
//          D53 ★Zoe 找 Lisa★ / D53 笑天看 Lisa 走出工位 / D54 Lisa 周五请假 /
//          D54 笑天看空工位 / D56 ★妈妈"我下个月想去你那"★ /
//          D56 ★Lisa 微信"潜力一般" + "我可能要走"★
//
// 红线 (S2 不能做):
//   - Lisa 不决定走/留 ✓ (D56 仅"我可能要走" + "但 Zoe 说下个月再看看")
//   - 王总监不直接 "潜力一般" ✓ (D56 通过 Zoe 转述)
//   - David 不燃尽 ✓ (仅 setup deepening)
//   - 老周 S2 对话 = 0 ✓
//   - 林姐不出场 ✓ (D56 mention only "林姐让我先在这边再呆一个月")
//   - 玩家不能 "救" Lisa, 只能 setup S3 路径 ✓
//
// 5 路径 verbatim 锚 (per §6):
//   - "Zoe 找我谈了月度面谈。她说我'潜力一般'" ✓
//   - "我下个月想去你那边看看你" ✓
//   - "但 Zoe 说下个月再看看。我可能不该太担心。" ✓
//
// END
