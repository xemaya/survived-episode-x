// ============================================================================
// Episode 7 · Week 7 · 「她剪了短发」
// ============================================================================
//
// Status: 第 1 版 (W3 写, S2 Round 1)
// Author: 分身 CC session (W3 = S2 Round 1)
// Last Updated: 2026-05-05
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
// 主 spec: design/vertical-slice/season-2-arc.md §5 E7 beat sheet
//
// 设计目标 (摘要):
//   1. Lisa 内心决定的外露信号 — 心理学梗"重大决定前剪头发" setup
//   2. 周一 Lisa 剪短发 = E7 集内 setup-payoff 高峰
//   3. 周二 Zoe 路过笑天工位 "陈笑天先生, 下午方便聊一下吗?" — Decision Moment
//   4. 周四 (如果周二选去) Zoe 实际问"你跟 Lisa 协作怎么样" — 笑天意识 E8 月度面谈前置数据
//   5. 周四 19:30 王总监打电话"你跟那个 Lisa 提一下吧" — 王总监 C Vulnerability layer 2
//   6. 周五 茶水间 李阿姨 "**上一个坐这位置的也是这么想的**" — 集内最深扎心
//   7. 周日 妈妈视频"妈听你姨说" — 相亲铺垫
//   8. 4:6 笑泪反转 — 笑减少, 扎为主
//   9. Cliffhanger 至 E8: Lisa 微信 "笑天, 下周一我可能要去 HR 那边。但你别担心啊。"
//
// 红线 (S2 不能做):
//   - Lisa 不能 决定走/留 (E12)
//   - HR 月度面谈不能在 E7 (E8 周四 14:30 才显形)
//   - 王总监不能直接对 Lisa 讲"潜力一般" (Zoe / E8)
//   - 林姐 S2 仍不出场 (mention only)
//   - 老周 S2 对话 = 0 (S1 唯一对话已耗尽 - Wed Lisa 试 retry 也失败)
//
// Verbatim quotes 必保留 (per season-2-arc.md §6):
//   - E7 周一: Lisa "**新剪的。想换个心情。**" (短发后第一句)
//   - E7 周五: 李阿姨 "**上一个坐这位置的也是这么想的。**"
//
// ============================================================================

INCLUDE episode-1.ink

// E7 entry
-> episode_7


// ============================================================================
// Episode 7 主入口
// ============================================================================

=== episode_7 ===
# scene: home
# time: monday_morning_week_7
# pagebreak
-> day_43_morning_briefing


// ============================================================================
// Day 43 · 周一 · 第 7 周第 1 天 · ★ Lisa 剪短发 ★
// ============================================================================
// 关键 beat:
//   - 笑天 9:14 到, 看到 Lisa 剪了短发
//   - Lisa "**新剪的。想换个心情。**" — 短发后第一句 (verbatim)
//   - 心理学梗"重大决定前剪头发" — Lisa C Vulnerability 实例化

= day_43_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared

闹钟响了 1 次。

_新一周。_

_上周 Lisa 周日朋友圈"这周辛苦了"。_

_她周一会怎么样? 还是 8:00 到? 还是更早?_

_或者她周末睡了一次饱觉, 今天 9:00 才到。_

# scene: subway_carriage
# time: 8:30

地铁。今天人不多——周一 5/17, 没什么节假日。

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:14 到公司。Vivian "嗨～来啦～" 标准长度。

水果盘**苹果**。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_43_event_1_lisa_short_hair


// ----------------------------------------------------------------------------
// Event 43.1 · Lisa 剪短发 · 9:18 (E7 集内 setup-payoff 高峰)
// ----------------------------------------------------------------------------
// 触发: 进入工位
// 速度: 长 (~14 行)
// 同框: Lisa + David (看到, 没说话, 远端) + 笑天
// NPC archetype: Lisa C Vulnerability — 心理学梗"重大决定前剪头发"
// Verbatim: "新剪的。想换个心情。" 必保留 (per season-2-arc.md §6)
// ----------------------------------------------------------------------------

= day_43_event_1_lisa_short_hair
# scene: workstation_corner
# time: 9:18
# npc: lisa_with_short_hair
# npc: david_at_desk_glancing_then_typing
# prop: lisa_short_hair_to_ear_length

你 9:14 走到工位区。

A 区——Lisa 工位斜对角。

你看了一眼——

她在工位。

**她剪了短发。**

上周还是齐肩长发。今天到耳朵。

她还低头敲键盘。她没看你。

你坐下来, 假装你正在看自己电脑屏幕。

# scene: workstation_with_david_visible

你余光瞥到 David 工位——他**抬头看了 Lisa 一眼**, 然后**没说话**, 低头继续敲键盘。

_David 看到了。但他没说"诶你换头型啦"。_

_他这种平时把"嗨兄弟周末过得怎样" 说 4 次的人, 今天**没问 Lisa**。_

_他不问是因为他**也察觉到这是 signal**。_

_他不想被卷进 signal 解读里。_

9:18, 她抬头——她可能注意到你来了。

你回头看她——她笑了一下。

"**新剪的。**" 她说。"**想换个心情。**"

_"新剪的。想换个心情。"_

_8 个字。_

_她 14 天没发朋友圈, 周日发"这周辛苦了", 周一剪短发说"想换个心情"。_

_心理学梗: 人在重大决定前会先剪头发。_

_她在做某个决定。_

_或者她做完了, 这是表征。_

_或者她还没做, 她在 prepare 自己做。_

_我不会问。她也不会告诉我。_

* [挺好看]
    # speaker: lisa
    Lisa："谢谢哈。"
    _她转回工位, 但表情松了一下。_
    ~ lisa_score = lisa_score + 3

* [嗯]
    # speaker: lisa
    Lisa："嗯。"
    _她转回工位, 没说话。_
    ~ lisa_score = lisa_score + 0

* [你想换什么]
    Lisa 0.5 秒。
    "就……" 她说, "想换。"
    她没接下去。
    ~ lisa_score = lisa_score - 1
    // 她不会展开 — 这是 Pillar 4

- _不论选什么。_
- _她周一早晨剪短发到公司。_
- _S1 我以为这件事是 E3 的 beat。_
- _W3 patch 把它移到了这里 (S2 E7) — 我没意识到。_
- _剪头发的 motif 终于落在该落的地方: HR 月度面谈前 1 周。_
- _下周一她要去 HR 那。她可能在剪头发的时候已经知道了。_

// hidden flag: Lisa 剪短发 D43 周一 - 这个 flag 贯穿 S3, 每集都被回顾
// hidden flag: 心理学梗 setup - 玩家此时应该感觉"她要走?"

~ check_state_after_choice()
-> day_43_event_2_wang_briefly_passes


// ----------------------------------------------------------------------------
// Event 43.2 · 王总监经过工位 · 12:18
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~5 行)
// 同框: 王总监 + 笑天 (Lisa 在工位 远端)
// 设计意图: 王总监没注意到 Lisa 剪短发 — visual irony
// ----------------------------------------------------------------------------

= day_43_event_2_wang_briefly_passes
# scene: workstation_pantry_corner
# time: 12:18
# npc: wang_walking_by_lisa_then_xiaotian

12:18。你刚泡好面, 王总监经过工位区。

他经过 Lisa 工位——他**没看**Lisa。

他看了一眼她屏幕, 0.3 秒, 走开。

他**没注意到她剪了短发**。

到你工位前——

"小笑啊。"

0.5 秒。

"陈天啊。"

0.5 秒。

"差不多差不多。月底了, 加把劲。"

跟 S1 E3 D15 一字不差。

_他没注意到 Lisa。_

_他注意 Lisa 的 KPI deliverable, 不注意 Lisa 的人。_

_他对所有人都是这样——对我也是。_

_但 Lisa 还相信他注意到她。_

_她周日剪头发是给"换心情" 给自己。_

_但她也偷偷给王总监一个 visual signal "我在变"。_

_王总监没看到。_

_signal 失效。_

// 没有选项 - flavor

~ check_state_after_choice()
-> day_43_event_3_lisa_no_lunch


// ----------------------------------------------------------------------------
// Event 43.3 · 中午 Lisa 没动 · 12:30
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 闪 (~3 行)
// 同框: Lisa (背景)
// ----------------------------------------------------------------------------

= day_43_event_3_lisa_no_lunch
# scene: workstation_lunchtime
# time: 12:30
# npc: lisa_at_v21_typing

12:30。你吃完面回工位。

Lisa 还在敲键盘——她**没站起来吃午饭**。

她桌上**没有自带饭**。

她抽屉**没拉开**。

她周二带饭, 周三 7-11, 周四 7-11, 周五 7-11——今天周一她不吃。

_她在 fasting?_

_或者她忘了。_

_或者她不饿——剪头发占用了一上午的注意力, 中午她还在 process。_

_她今天剪了头发, 中午没吃饭。_

_她周末的 self-acknowledge "这周辛苦了" 升级为周一的 self-deprivation "中午不吃"。_

_这种逻辑是 self-punishment。_

// 没有选项 - quiet sign

// hidden flag: Lisa D43 周一中午不吃 - self-punishment quiet sign

~ check_state_after_choice()
-> day_43_after_work


= day_43_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_at_v22

17:30。Lisa 还在改 PPT。

* [申报加班]
    你回工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。Lisa 没回头。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_43_daily_recap


= day_43_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **Lisa 剪了短发** — "新剪的。想换个心情。" (E7 集内高峰 - 心理学梗 setup)_
_  - 王总监经过 Lisa 工位**没注意到**剪短发 (signal 失效)_
_  - David 看到 Lisa 短发但**没说话**_
_  - Lisa 中午不吃饭 (self-punishment)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_44_morning_briefing


// ============================================================================
// Day 44 · 周二 · ★ Zoe 路过笑天工位 ★
// ============================================================================
// 关键 beat:
//   - Zoe 路过笑天工位"陈笑天先生, 下午方便聊一下吗?" — Decision Moment 3 选 1
//   - fake-out: 玩家以为 Zoe 找笑天关于他自己 KPI, 但其实是 Lisa 的协作伙伴反馈

= day_44_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_workstation
# time: 9:11
# npc: lisa_with_short_hair_typing

9:11 到公司。

Lisa 在工位——短发——还在改 PPT。

她今天**没喝美式**。她桌上**保温杯**——茶水间热水。

_她每天换 ritual。_

_周一咖啡, 周二热水。_

_没有 stable pattern——她在 try various copings。_

* [开始今日]
    -> day_44_event_1_zoe_passes


// ----------------------------------------------------------------------------
// Event 44.1 · Zoe 路过笑天工位 · 14:25 (Zoe Decision Moment)
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 长 (~10 行)
// 同框: Zoe + 笑天
// NPC archetype: Zoe Decision Moment + fake-out (玩家以为关于自己 KPI)
// 设计意图: 笑天此时不知 Zoe 是收集 Lisa 协作伙伴反馈
// ----------------------------------------------------------------------------

= day_44_event_1_zoe_passes
# scene: workstation_with_zoe_arriving
# time: 14:25
# npc: zoe_in_black_jacket_with_clipboard

14:25。

Zoe 走到你工位旁。

你抬头。

她穿黑色西装外套——HR 制服。她手里夹一个文件夹。

"**陈笑天先生**, 下午方便聊一下吗?"

_陈笑天先生。_

_她每次叫我这个我就觉得我已经被裁了。_

_她今天找我。_

_她平时不主动找我。_

_她找我就是流程的开始。_

_但她可能也不是关于我——可能她要找其他人, 我只是 corridor 上一站。_

_我不知道是不是。_

_我希望不是。_

* [现在去]
    你站起来跟 Zoe 走。
    Zoe 把你带到 HR 工位区——但**不是会议室**。
    "我们就这边聊一下哈。"
    她坐下, 拿出文件夹。
    "陈笑天先生, 我们这边在做一个**协作反馈调研**——下个月度的 360 评估。"
    "您这个月主要跟哪几位同事协作?"
    _她问的是协作伙伴。_
    _不是我自己 KPI。_
    "Lisa, David, 偶尔王总监。"
    Zoe 在文件夹上写了一笔。
    "**Lisa**——您觉得她协作上**有什么需要 calibrate 的地方吗?**"
    _Lisa。_
    _她直接问 Lisa。_
    _我意识到——这是 Lisa HR 月度面谈的前置数据采集。_
    _笑天此时不知"月度面谈" 是什么级别。但他知道 HR 在收集 Lisa 的协作反馈 = 不寻常。_
    "Lisa 协作 OK——她周末 / 加班帮 David 看过 PPT, 她带饭省钱, 她剪短发……"
    _我说出"剪短发" 之后才意识到我不该说。_
    _但我说了。_
    Zoe 没接, 在表上写了 1 笔。
    "好的, 谢谢您协助。"
    她合上文件夹。"5 分钟够了哈。"
    _5 分钟。她说"5 分钟"——比"5 分钟的事" 那个 David 短一倍。_
    ~ zoe_score = zoe_score + 2
    ~ effort_overage = effort_overage + 0  // 不算正式加班
    // hidden flag: 笑天意识到 Zoe 在 build Lisa 月度面谈数据 D44

* [我下班前来]
    # speaker: zoe
    Zoe："好, 那您方便的话 17:00 来一下哈。"
    _17:00 我已经在准备 17:30 走。_
    _她在压时间——让我"自愿延后"。_
    "好的。"
    Zoe 离开。
    17:00 你去 HR 工位——Zoe 不在。
    _她去开会。_
    _她明天再来一次。_
    ~ zoe_score = zoe_score - 2
    // hidden flag: Zoe 周三再来 — D45 重复触发

* [我比较忙]
    Zoe 0.5 秒。
    "**理解一下哈。**" 她说。
    _理解一下——HR 标准 push 话术。_
    "您这边方便就麻烦您了。"
    她离开。
    _她不会再来。她会在我档案里加 1 笔 "不愿配合调研"。_
    ~ zoe_score = zoe_score - 5
    // hidden flag: 笑天拒 Zoe — Zoe 在档案里 negative mark

- _不论选什么。_
- _Zoe 找你不是关于你 KPI——是关于 Lisa 协作。_
- _她在为下周月度面谈准备 evidence。_
- _你不知道——但如果你"现在去" 你会知道。_
- _知道了也帮不了 Lisa。_

~ check_state_after_choice()
-> day_44_event_2_lisa_doesnt_know


// ----------------------------------------------------------------------------
// Event 44.2 · Lisa 不知道笑天被 Zoe 找 · 16:00
// ----------------------------------------------------------------------------
// 触发: 第 6 个 event
// 速度: 闪 (~4 行)
// 同框: Lisa (背景)
// ----------------------------------------------------------------------------

= day_44_event_2_lisa_doesnt_know
# scene: workstation_with_lisa
# time: 16:00
# npc: lisa_typing_unaware

16:00。Lisa 在工位——她**不知道**Zoe 找你。

她在打 PPT。

她没问你"刚才 Zoe 找你什么事"。

她可能没看到 Zoe 来。

或者她看到了, 她不问——是她的边界。

_她对边界的把握比我严。_

_她 14 天 silent + 周日朋友圈 + 周一剪短发 + 中午不吃饭——她处于自己 process 模式。_

_她的边界是"我自己消化, 不投射"。_

_我也是这样。_

_我们俩都在自己消化。_

_在隔板斜对角。_

// 没有选项 - flavor

~ check_state_after_choice()
-> day_44_after_work


= day_44_after_work
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
-> day_44_daily_recap


= day_44_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Zoe 找你 5 分钟** — 不是关于你 KPI, 是 Lisa 协作反馈 (E8 月度面谈前置)_
_  - 笑天意识到 Zoe 在 build Lisa 数据 (隐藏 awareness 1 次)_
_  - Lisa 不知 Zoe 找笑天 (她不问)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_45_morning_briefing


// ============================================================================
// Day 45 · 周三 · 笑天发现老周比他早到 1 小时
// ============================================================================
// 关键 beat:
//   - 9:00 笑天到, 看到老周已经在工位 (8:00 到 = 比笑天早 1 小时)
//   - 笑天意识"他每天 8:00 就到。我不知道他每天 23:00 走"

= day_45_morning_briefing
# scene: home_then_subway_then_office
# time: 8:30_to_9:00
# weather: cleared

周三。

你今天比平时早 11 分钟出门——你想验证一下:

_老周到底几点到?_

_我入职 13 周, 我从没看到过他**到达** 工位的瞬间。_

_他每天我到时他已经在了。_

_我每天我走时他已经走了。_

_他在的时间比我长。但我不知道差多少。_

# scene: office_entrance
# time: 9:00
# npc: vivian_loading

9:00 到公司。

Vivian 还在 loading——8:50 那种 loading。

# scene: corner_workstation_lao_zhou
# time: 9:01
# npc: lao_zhou_facing_window
# prop: three_tea_cups_already_set
# prop: middle_tea_cup_warm_with_steam

9:01。你直接走到老周工位方向, 没去自己工位。

老周——

**他在。**

他面对窗户, 在看 Excel。

他茶杯**已经摆好**——3 个。

中间那杯**冒蒸汽**——刚泡。

**他刚泡的茶。**

他大概**8:50 泡的**。

他**8:00 到的**。

也就是——他比我早 1 小时 14 分钟。

每天。

_他每天 8:00 就到。_

_我入职 13 周, 我每天 9:14 到。_

_他**比我每周多 1 小时 14 分钟 × 5 = 6 小时 17 分钟**。_

_他**每年**比我多 327 小时——40 个工作日。_

_他不加班——他 18:00 准点走。_

_他靠**早到**, 而不是**晚走**, 累积工时。_

_这是他 12 年没被裁的秘密。_

_他到得早, 但他不发朋友圈, 不抢功, 不表演——所以他不被王总监 cue。_

_他是 stealth 的卷王。_

_或者他不是卷王——他单纯睡不好, 7:30 就醒了。_

_我不会问。_

老周抬头看了你 0.5 秒。

他**不打招呼**。

他低下头继续看 Excel。

_他知道我看到他了。_

_他不需要解释。_

_他每天都这样。_

* [开始今日]
    -> day_45_event_1_workstation_quiet


// ----------------------------------------------------------------------------
// Event 45.1 · 工位 quiet · 11:00
// ----------------------------------------------------------------------------
// 触发: 第 2 个 event
// 速度: 闪 (~4 行)
// 同框: Lisa + 笑天
// ----------------------------------------------------------------------------

= day_45_event_1_workstation_quiet
# scene: workstation_with_lisa_typing
# time: 11:00
# npc: lisa_short_hair_at_screen

11:00。Lisa 在工位敲键盘。

她**没动**。她从 8:30 坐到 11:00, 没站起来。

她桌上**眼药水**和**一次性水杯**和**自带饭盒**。

她滴一次眼药水, 喝一口水, 继续打。

_她 8 - 9 - 10 - 11 都在打。_

_她平均**每小时改 1 版**。_

_她每天好几版。_

_我没数。她也没说。_

_总之她是疯狂迭代。_

// 没有选项 - flavor

~ check_state_after_choice()
-> day_45_event_2_zoe_no_show


// ----------------------------------------------------------------------------
// Event 45.2 · Zoe 周三再来? · 14:00
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 闪 (~5 行)
// 同框: Zoe (背景, 不来)
// 设计意图: 如果周二选拖到下班, 周三 Zoe 还是来; 如果周二选去, 周三平静
// ----------------------------------------------------------------------------

= day_45_event_2_zoe_no_show
# scene: workstation_corridor
# time: 14:00
# npc: zoe_passing_other_workstations

14:00。

你看了一眼 HR 工位方向——Zoe 在跟其他同事低声说话。

她没找你。

_周二我去过了——她不再找我。_

_或者周二我没去——她今天会找我?_

_她经过我工位 0.5 秒, 没看我, 没停。_

_她已经收集到 sufficient data。_

_或者她在等周四?_

_HR 的节奏我不熟。_

// 没有选项 - flavor (周二选项 dependent)

~ check_state_after_choice()
-> day_45_after_work


= day_45_after_work
# scene: workstation_evening
# time: 17:30
# npc: lao_zhou_already_packing
# npc: lisa_at_v28

17:30。

老周**收东西**——他每天 18:00 准点走。

他 8:00 - 18:00 = **10 小时**。

我 9:14 - 17:30 (没加班) = **8 小时 16 分钟**。

我 9:14 - 19:30 (加班) = **10 小时 16 分钟**。

_老周不加班但比我加班多 1.7 小时。_

_他赢。_

* [申报加班]
    你回工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。
    Lisa 没回头。
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_45_daily_recap


= day_45_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 笑天 9:00 到, 发现**老周 8:00 已在工位** — 比笑天每天多 1 小时 14 分钟_
_  - 老周中间茶杯刚泡 — 笑天意识老周是 stealth 卷王 (12 年生存秘密)_
_  - Zoe 周三没找笑天 (周二已 collected)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_46_morning_briefing


// ============================================================================
// Day 46 · 周四 · 王总监打电话 "你跟那个 Lisa 提一下吧" + Zoe 找 Lisa 协作
// ============================================================================
// 关键 beat:
//   - 周四笑天主动 retry 找老周对话 (S2 第 1 次试 retry, 失败 — 老周仍只"嗯")
//   - 周四 19:30 笑天加班, 听到王总监电话"你跟那个 Lisa 提一下吧" — 王总监 C Vulnerability layer 2

= day_46_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周四。

# scene: office_workstation
# time: 9:11
# npc: lisa_short_hair_at_v29

9:11 到公司。Lisa 已经在敲键盘。

老周已经在 (8:00 baseline 现在 confirmed)。

David 已经在他工位——他周三晨会"完成度 110%" 后, 他周四继续 push。

* [开始今日]
    -> day_46_event_1_lao_zhou_retry


// ----------------------------------------------------------------------------
// Event 46.1 · 笑天主动找老周 retry · 11:30 (老周对话 = 0)
// ----------------------------------------------------------------------------
// 触发: 第 3 个 event
// 速度: 长 (~10 行)
// 同框: 老周 + 笑天
// 设计意图: 笑天意识 S1 那 1 次"过完今天" 是绝唱 — S2 retry 失败
// ----------------------------------------------------------------------------

= day_46_event_1_lao_zhou_retry
# scene: corner_workstation_lao_zhou
# time: 11:30
# npc: lao_zhou_facing_window_silent
# prop: three_tea_cups_third_empty

11:30。你去打印机取一份纸。

老周还在。

你站在他工位旁。

# speaker: protagonist
你说: "周哥。"

老周抬头。

他看了你 0.5 秒。

你: "**就……过来看看您。**"

老周看了你 0.5 秒。

他**没说话**。

他**点了 0.3 度的头**。

他低头继续看 Excel。

你回工位。

// 没有选项 - 老周 retry 失败

// hidden flag: S2 笑天 retry 老周 = 失败 (0.3 度点头, 0 词)
// hidden flag: S1 唯一对话已耗尽 confirm

~ check_state_after_choice()
-> day_46_event_2_lisa_to_hr_again


// ----------------------------------------------------------------------------
// Event 46.2 · Lisa 中午又去 HR 工位 · 12:35
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~5 行)
// 同框: Lisa + Zoe (远端)
// 设计意图: E6 D39 第 1 次 18 分钟; E7 D46 第 2 次 — 月度面谈预约 confirm
// ----------------------------------------------------------------------------

= day_46_event_2_lisa_to_hr_again
# scene: workstation_lunchtime
# time: 12:35
# npc: lisa_walking_to_hr

12:35。Lisa 站起来。

她**又去 HR 方向**。

她 12:35 走, 12:55 回——**20 分钟**。

她回来时**手里有 1 张 A4 纸 折成 4 折**——比 E6 D39 那张折得更小。

她没看你。她坐下, 把纸塞进抽屉。

_她去 HR 已经 2 次了。_

_她不告诉我。_

_我假装我不知道。_

_她可能希望我假装我不知道。_

_或者她单纯没想我。_

// 没有选项 - 隐藏 setup

// hidden flag: Lisa D46 第 2 次去 HR (20 分钟) - E8 月度面谈 confirmed

~ check_state_after_choice()
-> day_46_event_3_wang_phone_call


// ----------------------------------------------------------------------------
// Event 46.3 · 19:30 王总监电话 "你跟那个 Lisa 提一下吧" · 19:30
// ----------------------------------------------------------------------------
// 触发: 申报加班后
// 速度: 长 (~10 行)
// 同框: 王总监 (独立办公室门关, 笑天偷听)
// NPC archetype: 王总监 C Vulnerability layer 2
// ----------------------------------------------------------------------------

= day_46_event_3_wang_phone_call
# scene: office_after_hours
# time: 19:30
# npc: wang_in_solo_office_on_phone
# prop: wang_office_door_closed_with_voice_seeping_through

如果你今天申报了加班——

~ state = state - 10
~ kpi = kpi + 5
~ effort_overage = effort_overage + 1

19:30。大部分人都走了。

你去 16 楼茶水间接水。

你接完水回来的路上经过王总监独立办公室——

门关着。但**有声音从门缝漏出来**。

你停下来听了 5 秒。

王总监在打电话——不是大声, 是商务电话的中音量。

"…对……对……"

"…那这边的话……我了解……"

5 秒间隔。他在听对方说话。

然后:

"嗯, 我看下。"

"**你跟那个 Lisa 提一下吧。**"

10 个字。

"**就说……让她做好心理准备。**"

8 个字。

电话挂了。

你听到他放手机的声音。

你**赶紧走开**——你不能让他知道你听到了。

_"那个 Lisa"。_

_他不叫"小 Lisa"——叫"那个 Lisa"。_

_distance。_

_他在跟另一个 manager 通电话——可能是 Zoe 的 manager, 或者是更高的 HR director。_

_"让她做好心理准备" = 月度面谈结果他**已经知道**。_

_S2 第 6 周 D38 他对 Lisa "加把劲"——那是公开 PUA。_

_S2 第 7 周 D46 他打电话 "让她做好心理准备"——那是 backstage 决策。_

_他公开 + backstage 同时 push。_

_这就是中层。_

_Lisa 不知道。我也不能告诉她。_

_告诉她 = 她会觉得我"out of bound"——可能她还想 keep face。_

_或者告诉她她会快速 escalate。_

_无论如何告诉她我都吃亏。_

_我不告诉。_

_我成了 Zoe。_

// 没有选项 - 王总监 C Vulnerability layer 2

// hidden flag: 王总监 D46 19:30 电话"让 Lisa 做好心理准备" - 笑天偷听

~ check_state_after_choice()
-> day_46_after_work


= day_46_after_work
# scene: workstation_evening
# time: 20:00

20:00。你出公司。

* [继续走]
    Lisa 还在工位敲。
    _她不知道她明天可能被通知。_
    ~ lisa_score = lisa_score + 0

-

~ check_state_after_choice()
# pagebreak
-> day_46_daily_recap


= day_46_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 笑天主动找老周 retry — 老周 0.3 度点头, 不开口 (S1 唯一对话耗尽 confirm)_
_  - Lisa 中午**又去 HR 工位 20 分钟** (第 2 次)_
_  - **19:30 王总监电话"让 Lisa 做好心理准备"** (王总监 C Vulnerability layer 2)_
_  - 笑天意识到他不能告诉 Lisa_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_47_morning_briefing


// ============================================================================
// Day 47 · 周五 · ★ 李阿姨"上一个坐这位置的也是这么想的" ★
// ============================================================================
// 关键 beat:
//   - 笑天下班路过茶水间 — 李阿姨与另一清洁阿姨对话
//   - 李阿姨说"**上一个坐这位置的也是这么想的**" — S1 没说出来过
//   - 集内最深的扎心 — 4:6 笑泪比的扎点 anchor

= day_47_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared

周五。

# scene: office_entrance
# time: 9:08
# prop: fruit_bowl_apple

9:08 到公司。

水果盘**仍是苹果**——苹果 6 周连续。

~ fruit_bowl = "apple"

# scene: office_workstation
# npc: lisa_short_hair_no_make_up
# npc: lisa_at_v32

Lisa 在工位。她今天**没化妆**——她平时周五会画一点 (淡口红 + 眼线)。

今天素颜。

她还是短发——周一剪的, 5 天里没洗过头? 还是她洗过但素颜?

她在改 PPT。

* [开始今日]
    -> day_47_event_1_weekly_recap


// ----------------------------------------------------------------------------
// Event 47.1 · weekly_recap · 16:50
// ----------------------------------------------------------------------------

= day_47_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出周报浮层。

- 出勤率: 100%
- 主动产出条目: 取决于你的 D 43-46 选择
- 协作记录: 取决于你的 Zoe / 王总监 / Lisa 选择

浮层底部："**本月度 KPI 还有 2 天 (周日 9:30 推送月末通报)**"。

_本月度 KPI 还有 2 天。_

_周日 5/23 月末通报。_

_这是 S2 第 3 个 KPI Review。_

// hidden flag: D47 周五 HR 浮层 + 周日 5/23 月末通报 setup

~ check_state_after_choice()
-> day_47_event_2_li_ayi_verbatim


// ----------------------------------------------------------------------------
// Event 47.2 · 茶水间 李阿姨 "上一个坐这位置的也是这么想的" · 17:30 (集内最深扎心)
// ----------------------------------------------------------------------------
// 触发: 下班路上经过茶水间
// 速度: 长 (~12 行)
// 同框: 李阿姨 + 另一清洁阿姨 + 笑天 (路过)
// NPC archetype: 李阿姨 S2 第一次说出"上一个坐这位置的也是这么想的"
// Verbatim: "上一个坐这位置的也是这么想的。" 必保留 (per season-2-arc.md §6)
// 设计禁忌 (per npcs.md §5): 李阿姨 score 不影响机制
// ----------------------------------------------------------------------------

= day_47_event_2_li_ayi_verbatim
# scene: break_room_doorway
# time: 17:30
# npc: li_ayi_with_mop_cart_son_exam_photo
# npc: another_li_ayi_holding_trash_bag

17:30。你下班, 经过茶水间。

李阿姨在收垃圾。

另一个清洁阿姨在她旁边——她们是同一外包公司的。

她们没看你。

她们在低声说话。

# speaker: li_ayi
李阿姨: "她周五又加班到 19:00 了。"

另一个: "谁?"

# speaker: li_ayi
李阿姨: "斜对角那个剪短发的。"

另一个: "嗯。"

# speaker: li_ayi
李阿姨: "她以前不加班的——她跟那个戴眼镜的小伙子同一批入职。"

另一个: "**她跟我们这边那个走了的小李一样啊**。"

李阿姨 0.5 秒沉默。

# speaker: li_ayi
李阿姨: "嗯。"

她拖了一下垃圾桶。

她说: "**上一个坐这位置的也是这么想的。**"

她说完, 没接下去。

另一个清洁阿姨没接话。

她们俩静默了 2 秒。

然后另一个清洁阿姨: "走了好几个了。"

# speaker: li_ayi
李阿姨: "嗯。"

她们继续收垃圾。

# scene: corridor_back_walking

你站在茶水间外面 5 秒——你不能进去, 进去就 break 了她们的对话。

你走开。

_"上一个坐这位置的也是这么想的。"_

_S1 我以为这句话是"未来" — 4 个月后 / 半年后 / 1 年后。_

_她今天说出来。_

_她说的是 Lisa。_

_她说**Lisa 在重复别人的轨迹**。_

_别人 = 走了。_

_她在跟另一个清洁阿姨**预测 Lisa 的结局**。_

_她不会告诉 Lisa。_

_她也不会告诉我。_

_她说给她自己听。_

_或者说给"reality" 听——这就是她的 narration。_

_她在这扫地 8 年, 她见过 200+ 个"上一个坐这位置的"。_

_她知道。_

_她不需要 KPI 表格知道。_

_她每天扫地, 她看着每个工位上人来人去。_

_她比 HR 知道得多。_

_她比王总监知道得多。_

_她不会上 LinkedIn 写"我有 8 年企业人力洞察经验"。_

_她只是扫地。_

// 没有选项 - 集内最深扎心

// hidden flag: 李阿姨 D47 verbatim 说出 "上一个坐这位置的也是这么想的"
//              (S2 escalation - S1 没说出过)
// hidden flag: 笑天意识 Lisa 在重复 small 李 的轨迹

~ state = state - 5   // 扎心 -5

~ check_state_after_choice()
-> day_47_after_work


= day_47_after_work
# scene: workstation_evening
# time: 17:35
# npc: lisa_at_v33

17:35。你回到工位收东西——你想再看 Lisa 一眼。

她在敲键盘。

她抬头看了你一眼。

她**笑了一下**——比周一 Lisa 剪短发那个笑松一点。

_她不知道 李阿姨 5 米开外说了"上一个坐这位置的也是这么想的"。_

_她不知道王总监昨晚电话说"让她做好心理准备"。_

_她不知道 Zoe 周二在收集她的反馈。_

_她**不知道**, 她还在改 PPT。_

_她相信再改几版能让她"挽回"。_

* [明天见]
    # speaker: lisa
    Lisa："明天见。"
    _她说"明天见"——但她没说"周末好"。_
    _她默认下周一她还来。_
    _或者她默认下周日她也来。_
    ~ lisa_score = lisa_score + 1

* [辛苦]
    # speaker: lisa
    Lisa："嗯。"
    _2 个字。_
    ~ lisa_score = lisa_score + 0

* [不说话, 走]
    你点了头, 走。
    Lisa 没看你的眼神。
    ~ lisa_score = lisa_score + 0

-

~ check_state_after_choice()
# pagebreak
-> day_47_daily_recap


= day_47_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 2 天 (周日 9:30 推送)_

_关键时刻 today:_
_  - ★ **李阿姨 verbatim "上一个坐这位置的也是这么想的"** (集内最深扎心)_
_  - 李阿姨指向 Lisa — 笑天意识 Lisa 在重复"小李"的轨迹_
_  - Lisa 周五还在改 + 没化妆 + "明天见"_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_48_weekend_morning


// ============================================================================
// Day 48 · 周六 · 周末
// ============================================================================

= day_48_weekend_morning
# scene: bedroom
# time: 11:50
# music: weekend_silence

你睡到 11:50 醒。

_这周比上周晚 18 分钟。_

_S2 第 7 周比 S1 第 1 周晚 36 分钟。_

_我也在加速退步。_

# diegetic_ui: phone_wechat_moments

朋友圈：

David 发了"**周末加班 + 月底冲刺 + 客户对接 = Q2 完美收官**"。

_他从"双轮驱动 / 三连击 / 三连击" 升级到"完美收官"。_

_他每周加 1 个新词 + 1 个新指标。_

_他在 spinning。_

Lisa 朋友圈最新一条**还是上周日 21:00 "这周辛苦了"**。

她**14 + 7 = 21 天没发新的**。

_她剪了短发, 但她没拍剪发后的自拍发朋友圈。_

_S1 末她剪了 image 必发自拍。_

_S2 第 7 周她剪了 image 不发。_

_她不需要 social validation 了——或者她不期望了。_

11:34, 你点外卖。

* [开始今日]
    -> day_48_event_1_afternoon_quiet


= day_48_event_1_afternoon_quiet
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你在床上。

你想给 Lisa 发条微信——"你还好吗"——但你没发。

_发了她会"嗯"。_

_她不会展开。_

_我也不会展开。_

_最后我们俩都尴尬。_

你又躺了 30 分钟。

~ state = state + 30

~ check_state_after_choice()
# pagebreak
-> day_48_daily_recap


= day_48_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 11:50 起床 (比上周晚 18 分钟)_
_  - David 朋友圈"完美收官"_
_  - Lisa 21 天没发朋友圈 — 剪短发也不发自拍_
_  - 笑天想发微信给 Lisa, 没发_

# pagebreak
-> day_49_weekend_morning


// ============================================================================
// Day 49 · 周日 · 妈妈视频"妈听你姨说" + Lisa 微信"下周一可能要去 HR"
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈视频 "妈听你姨说... 你姨说她有个朋友的女儿..." 然后没说完 (相亲铺垫)
//   - 21:30 Lisa 微信 "笑天, 下周一我可能要去 HR 那边。但你别担心啊。" (E7 → E8 cliffhanger)

= day_49_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

你 8:23 醒。

_今天她会说什么。_

_上周"王二买房 + 谁结婚"。_

_这周可能"相亲"。_

_她在准备说什么 stunt 让我 register。_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_49_event_1_mom_video_aunt


// ----------------------------------------------------------------------------
// Event 49.1 · 妈妈视频"妈听你姨说" · 8:30 (相亲铺垫)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~14 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 升级 — "你姨说她有个朋友的女儿..." 然后没说完
// 设计意图: 笑天慌——妈妈准备说"相亲"
// ----------------------------------------------------------------------------

= day_49_event_1_mom_video_aunt
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

_发了。10500 (扣完房贷 + 给你的 1000)。但你不知道我自己只有 5500。_

# speaker: mama
妈妈："**那个谁的儿子结婚了。**"

# speaker: protagonist
你："嗯。"

_今天没说哪个谁。她可能 forgetting 了上周的 "王二", 也可能她在 saving "王二" 给下周。_

妈妈停了一下。

她**眯眼**——她的视频 closer 了 20 厘米。

她说："**天天, 妈听你姨说**——"

她 0.5 秒。

"**你姨说她有个朋友的女儿……**"

她 1 秒。

"……"

她**停了**。

她**没说完**。

她笑了一下。

"算了, 你自己看着。"

她转移话题——"你那边天气怎么样?"

_她姨的朋友的女儿。_

_她姨的朋友的女儿——意思是远方亲戚的远方朋友的女儿。_

_她准备说"相亲"。_

_但她**没说完**。_

_她**自己 cut 了**。_

_她 register 了我对"相亲" 的态度——她在过去 6 个月每次提起 hint 我都用"再等等"挡。_

_她这周提到 1/4, 自己 cut 掉。_

_她在给我 face。_

_或者她在 give up——她不再 push 相亲。_

_或者她在 build pressure: "你看, 你姨都开始操心了"——给我创造紧迫感。_

_3 种 reading 都对。_

_她可能 3 种都在做。_

* [接妈妈话题: 我这边天气挺好]
    # speaker: mama
    妈妈："好。前几天我跟你姨说啊——"
    _她 0.5 秒停。"——没事, 不说了。"_
    _她又自己 cut。_
    "你妈这周买了排骨, 周一寄过去。"
    "好。"
    ~ mom_score = mom_score + 2

* [追问: 你姨说什么]
    # speaker: mama
    妈妈："啊……" 她笑了一下, "就是个 girl, 她说不错。"
    _她不展开, 但她说了"不错"。_
    "妈, 我先……"
    # speaker: mama
    妈妈："**你想想哈**。"
    _她接得快。_
    _她在等我 react。_
    ~ mom_score = mom_score + 0
    // hidden flag: 妈妈相亲 hint 加深 D49

* [我不想相亲]
    妈妈 0.5 秒沉默。
    "妈不催。"
    _她说"不催" 的语气是软的, 但她马上换话题: "你那边有没有遇到什么人?"_
    _她在 reframe — "相亲" 改"遇到的人"。_
    "没。"
    # speaker: mama
    妈妈："好。"
    ~ mom_score = mom_score - 1

- _不论选什么。_
- _她下周可能再提 1/2。_
- _再下周可能 2/2 + 邀请我"端午回家见见"。_
- _她在 build, 我在 dodge。_
- _我们俩都在打**长期战**。_

// hidden flag: 妈妈 D49 相亲 hint 1/4 没说完

~ check_state_after_choice()
-> day_49_event_2_afternoon


// ----------------------------------------------------------------------------
// Event 49.2 · 周日下午 · 14:00
// ----------------------------------------------------------------------------

= day_49_event_2_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你点外卖咖啡——18 块。
~ money = money - 18

_我没去公司。_

_S1 第 1 周我去浇绿萝。S2 第 1 周我不去——因为累。_

_S2 第 7 周我也不去。_

_绿萝可能死了——周五我没浇。_

_或者它没死, 它学会了 fasting。_

# diegetic_ui: phone_wechat_status

你看了一下 Lisa 的微信状态——

她的状态今天显示"**忙**"——同上周一致。

但她**头像换了**——上周还是她的小玩偶。

今天换成**纯白色**。

_白色头像。_

_她以前从不换头像——同步她那个工位上的小玩偶。_

_今天她把小玩偶**从头像里 erase 了**。_

_纯白色 = 她想隐身。_

_她不想被认出来。_

_不想被她朋友圈点过赞的人认出来。_

_不想被她 LinkedIn connection 认出来。_

_她在重置。_

// 没有选项 - quiet sign

// hidden flag: Lisa D49 微信头像换纯白 - 她想隐身

~ state = state + 5

~ check_state_after_choice()
-> day_49_event_3_lisa_message_hr


// ----------------------------------------------------------------------------
// Event 49.3 · Lisa 微信 "下周一我可能要去 HR 那边" · 21:30 (E7 → E8 cliffhanger)
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 长 (~10 行)
// 同框: Lisa (微信)
// 设计意图: E7 → E8 cliffhanger - Lisa 知道她要去 HR + 想 prep 笑天 "别担心"
// ----------------------------------------------------------------------------

= day_49_event_3_lisa_message_hr
# scene: home_evening
# time: 21:30
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:30。你刚洗完澡。

微信消息 1 条。

# speaker: lisa
Lisa：

"**笑天, 下周一我可能要去 HR 那边。但你别担心啊。**"

20 个字。

_下周一她可能要去 HR 那边。_

_她**用了"可能"**——她在装"自己也不确定"。_

_但她肯定确定。_

_S2 D39 + D46 她去过 HR 2 次, 拿了 2 张 A4 纸。_

_她周日晚知道她明天 (周一) 要被 Zoe 正式叫去 HR 工位。_

_她周日晚 21:30 prep 我。_

_"但你别担心啊"——她在替我 cope。_

_她剪短发, 14 + 7 + 7 天 silent, 周日朋友圈"辛苦了", 头像换白色, 周日 21:30 微信 prep 我。_

_她从 self-process → self-acknowledge → self-erase → self-prepare-others。_

_她在收拾自己。_

_收拾自己 = 准备走。_

_或者**收拾自己 = 准备见 HR**。_

_这两件事可能是一件。_

_我不知道 specifically 是哪个。_

_但我知道她在 prep。_

* [我在]
    # speaker: lisa
    Lisa："好。"
    _她没继续。_
    ~ lisa_score = lisa_score + 2

* [你为什么去 HR]
    Lisa 1 分钟没回。
    "就……月度面谈。每个月的事啊。"
    _她说"每个月的事啊" — 但月度面谈不是每个月的事 — 是 negative outlier 的事。_
    _她在 minimize。_
    _或者她真的认为是"每个月的事"——她在 self-deny。_
    "好。"
    # speaker: lisa
    Lisa："你别想多了哈。"
    ~ lisa_score = lisa_score + 1

* [辛苦了]
    # speaker: lisa
    Lisa："嗯。"
    _她没继续。_
    ~ lisa_score = lisa_score + 1

* [不回]
    Lisa 5 分钟没追问。
    10 分钟后她又发: "笑天?"
    _她在 chase——她需要听到我"在"。_
    _但她说"别担心"是想我别 fuss。_
    _她需要"在" + "别 fuss" 同时——这是她的需求。_
    ~ lisa_score = lisa_score - 2

- _不论选什么。_
- _她下周一去 HR。_
- _Zoe 周二找过我 5 分钟"协作反馈"。_
- _王总监周四 19:30 电话"让她做好心理准备"。_
- _Lisa 不知道这些。_
- _或者她猜到了——但她不会问。_
- _她周日晚 21:30 在床上发"别担心"——她在 prep 我同时 prep 她自己。_

// hidden flag: E7 → E8 cliffhanger - Lisa "下周一去 HR" 微信
// hidden flag: Lisa 知道月度面谈即将发生

~ check_state_after_choice()
# pagebreak
-> day_49_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 49 周日日报 (E7 末)
// ----------------------------------------------------------------------------

= day_49_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +12)_

_关键时刻 today:_
_  - 8:30 妈妈视频"你姨说她有个朋友的女儿..." 妈妈自 cut (相亲 hint 1/4)_
_  - Lisa 微信头像换纯白 — 隐身_
_  - 21:30 Lisa 微信"笑天, 下周一我可能要去 HR 那边。但你别担心啊。" (E7 → E8 cliffhanger)_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 8 周 — Season Finale: HR 月度面谈_

// E7 结束 - cliffhanger 到 E8 周一 Lisa HR 月度面谈

-> END

// ============================================================================
// EOF episode-7.ink
// ============================================================================
//
// 分身 task summary (W3 = S2 Round 1):
//   - Day 43-49 全 7 天 stitches 完整
//   - Lisa 剪短发 (D43) "新剪的。想换个心情。" verbatim
//   - 心理学梗 setup-payoff = E7 集内 setup 高峰
//   - Zoe 找笑天 5 分钟 (D44) Decision Moment 3 选 1
//   - 笑天 retry 老周失败 (D46) — S1 唯一对话耗尽 confirm
//   - 王总监电话"让她做好心理准备" (D46 19:30) = 王总监 C Vulnerability layer 2
//   - 李阿姨 verbatim "上一个坐这位置的也是这么想的" (D47) = 集内最深扎心
//   - 妈妈"妈听你姨说" (D49) 自 cut = 相亲铺垫
//   - Lisa 微信"下周一去 HR" + 头像换白 (D49) = E7 → E8 cliffhanger
//
// 笑/泪比 = 4:6 (per season-2-arc.md §1):
//   - 笑点: D43 王总监没注意到 Lisa 剪短发 / D45 老周 stealth 卷王 awareness /
//          David "完美收官" / D49 妈妈相亲自 cut 的尴尬
//   - 扎点: D43 Lisa 剪短发 / D44 Zoe 找笑天 / D45 笑天发现老周早 1 小时 /
//          D46 王总监电话 / D47 ★李阿姨"上一个坐这位置的"★ /
//          D49 Lisa 头像换白 + Lisa 微信"下周一去 HR"
//
// 红线 (S2 不能做):
//   - Lisa 不决定走/留 ✓ (D49 仅"可能要去 HR")
//   - HR 月度面谈不在 E7 ✓ (E8 周四)
//   - 王总监不直接对 Lisa "潜力一般" ✓ (D46 仅 backstage 电话)
//   - 林姐 S2 仍不出场 ✓
//   - 老周 S2 对话 = 0 ✓ (D46 retry 0.3 度点头, 0 词)
//
// END
