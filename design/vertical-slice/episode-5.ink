// ============================================================================
// Episode 5 · Week 5 · 「下个月加班多一点」
// ============================================================================
//
// Status: 第 1 版 (W3 写, S2 Round 1)
// Author: 分身 CC session (W3 = S2 Round 1)
// Last Updated: 2026-05-05
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
// 主 spec: design/vertical-slice/season-2-arc.md §5 E5 beat sheet
//
// 设计目标 (摘要):
//   1. Lisa 兑现 S1 finale cliffhanger "下个月加班多一点" — 周一 8:50 已在工位
//   2. S1 finale 路径 cumulative 影响第一次大规模显形 (王总监 cue 笑天频率↑ /
//      Lisa 不主动 / David 加倍)
//   3. 7:3 笑泪比 — 主体仍笑 (Vivian 苹果周融资被打回 + David 卷王 + 王总监 cue)
//   4. Vivian C Vulnerability — 揭穿 S1 草莓周融资真相 ("D 轮过会被打回了")
//   5. 集内高峰 = 周一王总监等在工位旁 cue 笑天 (S1 路径效应第一次显形)
//   6. Cliffhanger 至 E6: Lisa 周日晚微信"今天周日我也来公司了。明天早 8:00 见。"
//
// 红线 (S2 不能做):
//   - Lisa 不能 决定走/留 (那是 S3 finale = E12)
//   - HR 月度面谈不能在 E5 (那是 E8 finale)
//   - 王总监不能直接对 Lisa 讲"潜力一般" (那是 Zoe / E8)
//   - 林姐 S2 仍不出场
//   - Lisa 剪短发 不能在 E5 (那是 E7 周一)
//   - David 不能燃尽 (那是 E24 = S6 finale)
//   - 老周 S2 对话 = 0 (S1 唯一对话已耗尽 per npcs.md §8)
//
// Verbatim quotes 必保留 (per season-2-arc.md §7):
//   - Vivian "D 轮过会被打回了" (E5 周一)
//
// ============================================================================

INCLUDE episode-1.ink

// E5 entry
-> episode_5


// ============================================================================
// Episode 5 主入口
// ============================================================================

=== episode_5 ===
# scene: home
# time: monday_morning_week_5
# pagebreak
-> day_29_morning_briefing


// ============================================================================
// Day 29 · 周一 · 第 5 周第 1 天 · 下个月开始
// ============================================================================
// 关键 beat:
//   - 笑天 9:14 到, 看到 Lisa 已经 8:50 在工位 (S1 finale cliffhanger 兑现)
//   - Vivian 接电话 + 揭穿 D 轮真相 (Vivian C Vulnerability)
//   - 王总监等在工位旁 cue 笑天 (E5 集内高峰)

= day_29_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared

闹钟响了 1 次。

_新月份。_

_上个月 KPI 过了。下个月 threshold 涨了 N%。_

_我不知道具体是几, 我的脑子还没接受。_

# scene: subway_carriage
# time: 8:30

地铁 10 号线换 6 号线。今天人比上周多——下个月开始, 大家都在赶。

你看了一眼地铁电视。屏幕滚动新闻: "本月 A 股上涨 0.2%。" "全市新房成交 3214 套, 同比下降 12.7%。"

_3214 套。_

_王二家儿子可能就在那 3214 套里。_

_我妈周日提的。_

_她不知道她在跟着新闻播报问我。_

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:14 到公司。打卡机响了一下。**比 9:00 整晚 14 分钟**——你周一固定的精度。

_上个月这个时间打卡也是 9:14。_

_打卡精度跟生命迹象一样, 是 stable 的。_

工位旁边的水果盘今天是**苹果**。

_S1 末是 mixed (一半草莓一半苹果)。S2 第一周回到苹果。_

_融资可能彻底冻了。_

~ fruit_bowl = "apple"

* [开始今日]
    -> day_29_event_1_vivian_d_round


// ----------------------------------------------------------------------------
// Event 29.1 · Vivian "D 轮过会被打回了" · 9:16 (Vivian C Vulnerability)
// ----------------------------------------------------------------------------
// 触发: 进入大堂
// 速度: 标准 (~7 行)
// 同框: Vivian + 笑天
// NPC archetype: Vivian C Vulnerability — 揭穿 S1 E2 草莓周真相
// Verbatim quote: "D 轮过会被打回了" — 必保留字字
// ----------------------------------------------------------------------------

= day_29_event_1_vivian_d_round
# scene: reception_passing
# time: 9:16
# npc: vivian_smiling_then_lowered
# prop: fruit_bowl_apple_close_up

你刷工牌过门禁。Vivian 抬头："嗨～来啦～"

她今天嗨得**短**了一拍——半秒。

她看了看左右, 没人。

她压低声音, 但口型还是"嗨"的笑。

"嗨——"

她突然换语气, "苹果哦。"

_她苹果 苹果 苹果苹果苹果。_

_S1 月初是苹果, S1 月中变草莓, S1 月末又苹果, 现在又苹果。_

_苹果是 baseline, 草莓是 spike。_

她继续："老板**D 轮过会被打回了**。"

她说完这一句, 看了看左右——大堂还是没人。

"我跟你说啊。S1 那次 (草莓那一周), 老板让我们前台**演一周融资到位**——他要给某个客户看演示。"

"其实那时候 D 轮根本没过会。今天我刚知道。"

_S1 草莓周——我以为那是融资到位的信号。_

_我 over-read 了 4 周。_

_那只是老板的**舞台道具**。_

_我和 Lisa 抢苹果 / 抢草莓, 我们俩都在他的剧本里跑龙套。_

* [那演技好啊]
    # speaker: vivian
    Vivian："对啊。哎我都拿了 1 个月演员奖金。"
    _她笑得露齿, 但马上恢复职业微笑——下一个员工进门了。_
    "嗨～来啦～"
    ~ vivian_score = vivian_score + 3
    ~ money = money + 1   // 苹果

* [我懂的]
    # speaker: vivian
    Vivian："嗯哼。"
    _她转回打卡台, 没说"嗨", 直接给下一个员工发微笑。_
    ~ vivian_score = vivian_score + 1
    ~ money = money + 1

* [不接话, 拿苹果走]
    你拿了苹果, 没说话。
    _Vivian 也没说话。她回到职业微笑。_
    ~ vivian_score = vivian_score + 0
    ~ money = money + 1

- _不论选什么。_
- _Vivian 终于在我面前破了一次"嗨"。_
- _她肯定也破过别人的——可能 David 那种"显得没空"的人她从不破, 老周那种"沉默"的人她也不破。_
- _她破我, 是因为她知道我不会跟老板说。_
- _或者她终于忍不住要跟一个人说一次。_
- _今天我做了一次"被信任的人"。_
- _不多。但算我赢一次。_

~ state = state + 1   // 知道 D 轮真相是隐性小确幸

// hidden flag: Vivian C Vulnerability D29 - S1 草莓周真相揭穿
// hidden flag: 笑天知道老板"演融资" 1 次

~ check_state_after_choice()
-> day_29_event_2_lisa_already_at_8_50


// ----------------------------------------------------------------------------
// Event 29.2 · Lisa 已 8:50 在工位 · 9:18 (S1 finale cliffhanger 兑现)
// ----------------------------------------------------------------------------
// 触发: 进入工位区
// 速度: 标准 (~6 行)
// 同框: Lisa (背景)
// 设计意图: S1 finale Lisa 微信"下个月开始我可能加班多一点" 兑现
// ----------------------------------------------------------------------------

= day_29_event_2_lisa_already_at_8_50
# scene: workstation_entry
# time: 9:18
# npc: lisa_already_at_desk_typing
# prop: lisa_workstation_with_charm
# prop: lisa_mug_already_half_empty

你走到工位区。

A 区——Lisa 工位斜对角。

她**已经在敲键盘**。

她的奶茶杯**已经空了一半**。

_她奶茶 30 减 8 起送。她半小时前喝完了。_

_她至少 8:50 到了——比我早 24 分钟。_

_她以前是 9:09 到的。_

_今天她比我早 24 分钟到了 24 分钟。_

_她兑现了。_

_S1 末她微信"下个月开始我可能加班多一点"——我以为她是说加班晚下班。_

_她是早上班。_

她没回头。

你坐到自己工位。

桌上小绿萝还活着——上个月你浇了 4 周, 它没死。

_它走了我还在。_

_它没走。我也没走。_

_我们俩都在。_

_新月份不需要新祝词。_

// 没有选项 - flavor + S2 setup

~ check_state_after_choice()
-> day_29_event_3_wang_at_workstation


// ----------------------------------------------------------------------------
// Event 29.3 · 王总监等在工位旁 · 9:25 (E5 集内高峰)
// ----------------------------------------------------------------------------
// 触发: 进入工位 5 分钟后
// 速度: 长 (~12 行)
// 同框: 王总监 + 笑天 + Lisa (背景, 已在工位)
// NPC archetype: 王总监 B Decision Moment (S1 finale 路径效应第一次显形)
// 设计意图: S1 路径 A/D 玩家被 cue 得密 / S1 路径 B/C/E 玩家被 cue 得疏
// ----------------------------------------------------------------------------

= day_29_event_3_wang_at_workstation
# scene: workstation_corner_with_wang_standing
# time: 9:25
# npc: wang_standing_at_desk
# npc: lisa_in_background_typing
# prop: wang_holding_phone

9:25。你刚开机, 还没接水。

王总监**站在你工位旁**。

他不是路过——他是**等**。

你抬头。

他看着你。**他比平时早 20 分钟出独立办公室。**

"小笑啊。"

0.5 秒。

"陈天啊。"

0.5 秒。

"差不多差不多。**月度 KPI 我们对一下。**"

_对一下。_

_S1 他说"对一下"是 mass cue—— 给整个团队的。_

_今天他单独对我说。_

_他不是路过——他是**等**。_

_这是 S1 finale 5 路径累积的第一次显形。_

_我上个月哪条路径? KPI 累积是多少? 我自己都没数清楚。_

_他对了一遍。_

* [您说]
    # speaker: wang_director
    王总监："你看下这个月的 deliverable list, 我下午让 David 给你 forward。3 项, 你接 1 项。"
    _3 项接 1 项 = 他选了 3 个 + 让我"自愿" 选 1 个挑。_
    _但 3 项 都是没人愿意接的。_
    _自愿 = 强制。_
    "好的。"
    # speaker: wang_director
    王总监："好。"
    _他转身走了。_
    ~ kpi = kpi + 0   // 接活 = KPI 涨, 但接活也意味着加班 — 现在还没影响, 看 after_work 选择
    ~ wang_score = wang_score + 0
    // hidden flag: 王总监给笑天派 deliverable D29 - 第一次单独 push

* [我看下吧]
    # speaker: wang_director
    王总监："嗯。看下哈。"
    _他转身, 但又回头, "下午 5 点之前给我一个回复。"_
    _下午 5 点。_
    _我下午 5:30 准点下班的。_
    _他知道我 5:30 下班。他故意压 5 点。_
    ~ kpi = kpi + 0
    ~ wang_score = wang_score - 1
    // hidden flag: 王总监 push 笑天 + 5 点 deadline 压力

* [我月底看下]
    # speaker: wang_director
    王总监："月底? 月底我们一起对哈。"
    _一起对 = 他在月底叫我去他独立办公室对。_
    _S1 他从没叫我进过独立办公室。_
    _今天他第一次提议。_
    "好的。"
    # speaker: wang_director
    王总监："那这周我们先试试。"
    _试试。_
    _试试 = 我会被记 1 笔。_
    ~ kpi = kpi + 0
    ~ wang_score = wang_score - 2
    // hidden flag: 王总监邀请笑天月底进独立办公室 - S2 后续可能兑现

- _不论选什么。_
- _他周一早 9:25 站在我工位旁——这是 S1 没有过的。_
- _S1 路径 A 帮 David 卷 + 帮 Lisa 改 PPT 的玩家会被王总监 +3 频率 cue。_
- _S1 路径 D 装病 + 摸鱼的玩家会被王总监 +5 频率 cue。_
- _我这个月开始就被他打了标签。_

// hidden flag: 王总监 D29 单独 cue 笑天 - S1 路径累积效应显形

~ check_state_after_choice()
-> day_29_event_4_lisa_lunch_skip


// ----------------------------------------------------------------------------
// Event 29.4 · 中午 Lisa 没拼奶茶 · 11:55 (Lisa quiet sign #0 — small)
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~4 行)
// 同框: Lisa (背景)
// 设计意图: 周一 Lisa 已经早到 + 中午没拼奶茶 = 第一周 quiet sign 起步
// ----------------------------------------------------------------------------

= day_29_event_4_lisa_lunch_skip
# scene: workstation_lunchtime
# time: 11:55
# npc: lisa_typing_through_lunch

11:55。你想去茶水间。

Lisa 在自己工位敲键盘。她**没回头**。

她周二、周五经常在 11:55 转过头问"拼奶茶吗"。

今天她没问。

_她还在改 PPT。_

_S1 末她改 PPT 已改了 8 版。这周她可能更多。_

_或者她在改新的。_

你接了水回来。她还在敲。

12:08, 她终于站起来——她去茶水间。

她回来时手里**没有奶茶**——是热水。

_她没拼奶茶。她没去楼下点。_

_她省了 12 块。_

_或者她舍不得花。_

_或者她单纯没空——她下午 2 点要交稿。_

// 没有选项 - Lisa quiet sign 累积起点

~ check_state_after_choice()
-> day_29_after_work


// ----------------------------------------------------------------------------
// after_work · Day 29 下班 · 17:30
// ----------------------------------------------------------------------------

= day_29_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_still_at_desk
# npc: david_absent

17:30。

Lisa 还在工位。她下午没站起来过——你回头数过 3 次, 每次她都在敲键盘。

David 不在工位——他可能在跟王总监 1v1。

* [申报加班 -10 状态 +5 KPI]
    你回工位多干一会。Lisa 抬头看了你一眼, 没说话。
    _她比我早到。她比我晚走。我加班到 7 点, 她加班到 8 点。_
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。Lisa 没看你。
    _她没说"明天见"。_
    ~ lisa_score = lisa_score - 1

* [提前下班]
    你 17:00 关电脑走人。
    Lisa 在敲键盘。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_29_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 29 周一日报
// ----------------------------------------------------------------------------

= day_29_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **Vivian C Vulnerability** ("D 轮过会被打回了" — S1 草莓周真相揭穿)_
_  - **Lisa 已 8:50 在工位** (S1 finale cliffhanger 兑现)_
_  - **王总监单独 cue** (S1 路径效应第一次显形 — E5 集内高峰)_
_  - Lisa 中午没拼奶茶 (quiet sign #0)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_30_morning_briefing


// ============================================================================
// Day 30 · 周二 · David 卷王持续
// ============================================================================
// 关键 beat:
//   - David 抢功 #2 (pps demo 又来一次"5 分钟" + 群里假感谢)
//   - Lisa 中午没拼奶茶 / 没拼午饭

= day_30_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_entrance
# time: 9:11
# prop: fruit_bowl_apple_again

9:11 到公司。Vivian "嗨～来啦～"——今天是标准长度。

水果盘**仍是苹果**。

~ fruit_bowl = "apple"

_她昨天破了一次, 今天她回到职业微笑。_

_她比我清醒——破完一次, 第二次必须装作没破过。_

_她不在公司演员奖金白领的。_

# scene: office_workstation
# time: 9:13
# npc: lisa_already_at_desk_again
# npc: david_absent_from_workstation

Lisa 已经在工位——她周二也 8:50 到。

David 工位空着——他可能在跟王总监开晨会前会议。

# diegetic_ui: phone_wechat_notification

你坐下来。微信弹出 1 条消息。

# speaker: david
David："兄弟! 今天 5 分钟的事啊。我下午 3 点要给王总监看 pps demo, 你帮我看下结论页?"

_5 分钟的事。S1 E2 那次也是"5 分钟"。_

_他用同样的话术 第 2 个月。_

_他在卷 baseline 上加了 1 层——上个月每周 1 次 5 分钟, 这个月每周 2-3 次。_

* [开始今日]
    -> day_30_event_1_david_pps_demo


// ----------------------------------------------------------------------------
// Event 30.1 · David PPS demo 第 2 次 · 上午 10:30
// ----------------------------------------------------------------------------
// 触发: David 微信回复
// 速度: 标准 (~7 行)
// 同框: David (微信 then 工位)
// NPC archetype: David B Decision Moment (S2 升级版)
// ----------------------------------------------------------------------------

= day_30_event_1_david_pps_demo
# scene: workstation_with_phone_wechat
# time: 10:30
# diegetic_ui: phone_wechat_chat
# npc: david_via_wechat_then_workstation

David 微信再发一条："不急啊兄弟, 你下午 3 点之前看就行。我先把链接发你。"

紧接着第 3 条："感谢哈。我等下请你下午茶——下楼那家奶茶满 30 减 8。"

_他用奶茶买我。_

_S1 那次他用"5 分钟" + "你保温杯哪买的" 试探。_

_这次他用奶茶。_

_他升级了。_

* [接过来]
    # speaker: protagonist
    你回："好的, 发我。"
    David 立刻发了一个 OneNote 链接, 里面是他写的"产品方案 V3 — 副本"。
    你打开看了一眼——结论页是空白的。
    _他要我帮他想结论。_
    _他自己提出方案, 让我替他写结论。_
    _下午 3 点 David 在群里"@所有人 感谢笑天帮忙改 demo 结论页, 多亏笑天熬一晚才赶出来的"。_
    _他没熬一晚。我也没熬。我看了 20 分钟改了 3 个字。_
    _但群里写的是"笑天熬一晚"。_
    ~ kpi = kpi - 3
    ~ effort_overage = effort_overage + 1
    ~ david_score = david_score + 2
    ~ david_blood_drawn = david_blood_drawn + 1

* [我也忙]
    你回："不好意思 David, 我下午也要赶东西。"
    # speaker: david
    David: "啊好好, 我自己搞。"
    _10 分钟后 David 在小群里"我下午自己赶 demo, 大家不用打扰我哈。"_
    _他广播自己在忙——这是他报复你的方式。_
    ~ david_score = david_score - 3

* [假装没看见]
    你没回。
    20 分钟后 David 又发: "在不在?"
    _他知道我在线。_
    # speaker: protagonist
    你回："刚开会, 看到再说。"
    # speaker: david
    David: "好。"
    _他没再问。下午 3 点群里没有"@所有人感谢"。他可能自己赶完了, 或者王总监没看 demo。_
    ~ david_score = david_score - 5
    // hidden flag: David 觉得你装

- _不论选什么。_
- _S1 是 1 次"5 分钟", S2 是每周 2-3 次。_
- _他卷的频率提高了, baseline 也抬高了。_
- _他越卷, 整个团队 KPI threshold 越高。_
- _他卷死自己, 顺便把我也拽下水。_

~ check_state_after_choice()
-> day_30_event_2_david_group_thanks


// ----------------------------------------------------------------------------
// Event 30.2 · David 群里"@所有人感谢" · 15:30
// ----------------------------------------------------------------------------
// 触发: David demo 之后
// 速度: 闪 (~5 行)
// 同框: David (群消息)
// NPC archetype: David running gag callback (S1 E2 升级)
// ----------------------------------------------------------------------------

= day_30_event_2_david_group_thanks
# scene: workstation_phone_buzz_group_chat
# time: 15:30
# diegetic_ui: phone_wechat_group

15:30。你手机震动——是部门小群。

# speaker: david
David："**@所有人** 大家好! 刚才跟王总监过了 pps demo, 王总监说方案 V3 可以接着推。感谢 Lisa 周末帮看了一版, 感谢笑天今天上午帮看了结论页! 兄弟们的支持永远是我前进的动力!"

_笑天今天上午帮看了结论页——我看了 20 分钟改了 3 个字。_

_Lisa 周末帮看了一版——我不知道这件事。_

_Lisa 周末**也在**? 她周六、周日都来公司了?_

# diegetic_ui: phone_wechat_lisa_emoji_reaction

群里 Lisa 给 David 那条消息点了一个👍。

_她点👍了。_

_她周末加班 + 周一早 8:50 + 中午没拼奶茶 + 群里给 David 点👍。_

_她在装她还在跟着团队走。_

_或者她真的在跟着团队走。_

// 没有选项 - David 群里运营 + Lisa quiet sign 加深

~ check_state_after_choice()
-> day_30_event_3_lisa_no_milk_tea


// ----------------------------------------------------------------------------
// Event 30.3 · Lisa 中午接热水 · 12:08 (重复 D29 的 quiet sign 升级)
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~4 行)
// 同框: Lisa (前景)
// 设计意图: D29 没拼奶茶是 1 次, D30 又没拼 = pattern 形成
// 注: 时间倒序, 因为 D30 整天事多, 这个 stitch 故意放在 event_3 (午饭后回看)
// ----------------------------------------------------------------------------

= day_30_event_3_lisa_no_milk_tea
# scene: workstation_lunchtime_quiet
# time: 16:30
# npc: lisa_holding_thermos_with_hot_water

16:30。你站起来去打印机取一份纸。

经过 Lisa 工位——她桌上是**保温杯, 接的是茶水间热水**。

不是奶茶杯。

_她周一没拼。她周二也没拼。_

_pattern 形成。_

_S1 末她每周二、周五一定拼奶茶。S2 第 1 周, 她两次都没拼。_

_她省 24 块。_

_24 块 — 一杯小蛋糕。_

_她以前在朋友圈晒小蛋糕。_

_这周她没晒。_

// 没有选项 - quiet sign

// hidden flag: Lisa 周二也没拼奶茶 D30

~ check_state_after_choice()
-> day_30_after_work


// ----------------------------------------------------------------------------
// after_work · Day 30 下班 · 17:30
// ----------------------------------------------------------------------------

= day_30_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_still_typing
# npc: david_already_packed

David 17:30 准时关电脑——他**今天准点走**。

Lisa 还在敲键盘。

_David 难得准点走。他可能晚上有应酬, 或者他要先回家陪老婆——他老婆刚生孩子。_

_他对老婆好这件事我一直信。_

_他对同事坏跟他对老婆好不矛盾。_

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
    你 17:00 关电脑走人。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_30_daily_recap


= day_30_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - David PPS demo "5 分钟"第 2 次 (S1 升级版)_
_  - David 群里"@所有人感谢笑天 + Lisa 周末帮看了一版"_
_  - Lisa 周二也没拼奶茶 (pattern 形成)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_31_morning_briefing


// ============================================================================
// Day 31 · 周三 · 晨会日 · 王总监眼神扫 Lisa 2 次
// ============================================================================
// 关键 beat:
//   - 晨会 王总监讲"我们这个团队啊" + 眼神扫过 Lisa 工位 2 次
//   - 下午 Lisa 桌上眼药水又 update (S1 E3 第 1 瓶, S2 E5 接续)

= day_31_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:25
# weather: rainy

周三。下小雨。

~ weather = "rainy"

# scene: office_entrance_passing
# time: 9:25
# npc: lisa_in_meeting_room_already
# npc: david_with_okr_2_notebook

9:25 到公司。晨会 9:30 开。

# scene: meeting_room
# time: 9:25
# npc: lisa_in_first_row
# npc: david_with_new_sticky
# npc: lao_zhou_in_back_with_tea

会议室——

Lisa **已经在了, 提前 5 分钟**。她坐在第一排。

_她周三仍然提前 5 分钟。_

_S2 还没到她"不再提前"那阶段。_

_(那是 E7 周三。)_

David 在斜对面, 笔记本封面贴着新便利贴: "**月度冲刺**" — 比"Q2 OKR"小一档但更紧。

老周在最后一排, 还是中间那杯茶。他没带笔记本。

9:32 王总监推门进来。

* [开始今日]
    -> day_31_event_1_morning_meeting_team


// ----------------------------------------------------------------------------
// Event 31.1 · 晨会"我们这个团队啊" · 9:32
// ----------------------------------------------------------------------------
// 触发: morning_briefing 后
// 速度: 长 (~15 行)
// 同框: 王总监 + David + Lisa + 老周 (背景) + 笑天
// NPC archetype: 王总监 standard PUA + Lisa C 加深
// 设计意图: 王总监眼神扫 Lisa 工位 2 次 (S2 升级版 — S1 是 0-1 次)
// ----------------------------------------------------------------------------

= day_31_event_1_morning_meeting_team
# scene: meeting_room_full
# time: 9:32
# npc: wang_at_podium
# npc: lisa_taking_notes
# npc: david_first_to_react
# npc: lao_zhou_drinking_tea
# prop: ppt_team_blueprint_v2

王总监打开投影仪。今天 PPT 第一页是箭头图——上面写"**团队 BLUEPRINT V2**"。

_V2。S1 是 V1。_

_BLUEPRINT V2——他换了一个版本号让 PPT 看起来"有进展"。_

_其实是同一张图。_

"上午好啊各位。"

# speaker: wang_director
王总监："**我们这个团队啊, 是有未来的**。"

_我们这个团队啊。这是他每月开场。_

_S1 他说过 4 次。S2 第 1 周他又说。_

"上个月 KPI 整体好的——我跟上面也提过了。但是我们要清醒, **下个月起点又抬高了**。"

_起点又抬高了——anti-Pillar 1 第 2 次明说。_

_S1 finale 浮层那句"每个员工都将根据自己的最佳表现, 承担更高的责任" 升级版。_

_他直接讲了。_

# speaker: wang_director
王总监："Lisa 上个月 PPT V8——非常好, 加深了客户对我们方案理解。"

王总监停了一下, **眼神扫过 Lisa 工位**——但 Lisa 在第一排, 他扫的是后面的空工位。

_他在演给所有人看, 我才发现"Lisa 工位"在他扫描里是一个独立坐标。_

_她在第一排, 他扫她真坐的位置只用 1 秒。但他扫她"工位的方向"用 2 秒。_

_他对 Lisa 工位的扫描是仪式性的。_

_S1 他不这么扫。这是 S2 第 1 周新增的小动作。_

"David 也很好——pps demo 推进有节奏。"

_pps demo 是 Lisa + 我 + David 一起改的。但 David 名字。_

# speaker: wang_director
王总监："小笑啊。"

0.5 秒。

"陈天啊。"

0.5 秒。

王总监**没有继续说**。

他**直接跳过**, 进入下一个议程。

_他刚才"小笑啊…陈天啊"是 muscle memory。_

_他原本准备 cue 我, 但 0.5 秒之内他改主意了。_

_他改主意是因为他周一已经单独 cue 过我了。_

"散会前一个事——Lisa, **下周一你去客户成功部送一份方案给林姐看下哈**。"

# speaker: lisa
Lisa："好的。"

_林姐。_

_S1 我听过 1 次 (E1 周四王总监打电话)。_

_S2 第 1 周我又听到。_

_这是第 2 次。_

_Lisa 要去客户成功部见林姐。_

_她不知道——但林姐是 S3 finale 路径 A 那个人。_

_我也不知道。_

# speaker: wang_director
王总监："散会。"

8 分钟结束。

// 没有选项 - 王总监 PUA + 眼神扫 Lisa + Lisa 林姐 setup
// hidden flag: 王总监 D31 眼神扫 Lisa 工位 2 次 (S2 升级)
// hidden flag: Lisa 下周一去客户成功部 - S2-S3 长 setup
// hidden flag: 笑天第 2 次听到林姐名字 (E1 第 1 次, 现在第 2 次)

~ check_state_after_choice()
-> day_31_event_2_after_meeting


// ----------------------------------------------------------------------------
// Event 31.2 · 散会后回工位 · 9:42
// ----------------------------------------------------------------------------
// 触发: 晨会结束
// 速度: 闪 (~4 行)
// 同框: Lisa + 笑天
// 设计意图: Lisa 不再 small talk (S2 第 1 周第 1 次)
// ----------------------------------------------------------------------------

= day_31_event_2_after_meeting
# scene: hallway_back_to_workstation
# time: 9:42
# npc: lisa_walking_alongside_quietly

你回工位的路上。

S1 周三晨会后 Lisa 都会跟你 small talk——"你说聚餐我们要去吗?" 那种。

今天她**没走过来**。

她已经走在你前面 5 米——她快步回工位, 没回头。

_她在赶。_

_她下周一要见林姐。_

_她有 5 天准备。_

_她周一已经 8:50 到了。今天她可能 19:30 才走。_

// 没有选项 - Lisa 不再 small talk

// hidden flag: Lisa S2 第 1 周不再 small talk

~ check_state_after_choice()
-> day_31_event_3_lisa_eye_drops_continuity


// ----------------------------------------------------------------------------
// Event 31.3 · 下午 Lisa 桌上眼药水 (continuity from S1 E3) · 14:30
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 闪 (~4 行)
// 同框: Lisa (前景, 不抬头)
// 设计意图: S1 E3 周一 Lisa 第一次摆眼药水, S2 E5 周三同瓶在那
// ----------------------------------------------------------------------------

= day_31_event_3_lisa_eye_drops_continuity
# scene: workstation_with_lisa
# time: 14:30
# npc: lisa_typing_facing_screen
# prop: lisa_eye_drops_bottle_quarter_empty

14:30。你回工位拿手机。

经过 Lisa 工位——她桌上的眼药水**还在原位**, 摆在键盘右边。

但**蓝色瓶身比上个月空了 1/4**。

_她两周用了 1/4 瓶。_

_她每天滴 4-5 次。_

_S1 E3 周一这瓶刚开。_

_S2 第 1 周还是同一瓶。_

_她没换新瓶——她舍不得花。_

_或者她单纯没空去药店。_

// 没有选项 - quiet sign 累积 (S1→S2 continuity)

// hidden flag: Lisa 眼药水进度 1/4 D31 - S2 累积 quiet sign

~ check_state_after_choice()
-> day_31_after_work


= day_31_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_at_v9
# npc: david_already_left

17:30。

Lisa 在工位——她屏幕上是"产品方案 草稿"。

_她又开了一版。我没数她做了几版。_

_下周一去林姐那她得带 final。_

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
-> day_31_daily_recap


= day_31_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 晨会 王总监 "我们这个团队啊" + 眼神扫 Lisa 工位 2 次_
_  - Lisa 下周一去客户成功部见林姐 (setup)_
_  - 笑天第 2 次听到林姐名字_
_  - 下午 Lisa 桌上眼药水 1/4 空 (quiet sign 累积)_
_  - Lisa 散会后没 small talk (S2 第 1 周变化)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_32_morning_briefing


// ============================================================================
// Day 32 · 周四 · 笑天加班路过李阿姨
// ============================================================================
// 关键 beat:
//   - 笑天 19:30 加班路过李阿姨拖地 (无对话, 但她注意到了)

= day_32_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:11
# weather: rainy

周四。还在下雨。

# scene: office_workstation
# time: 9:11
# npc: lisa_already_typing_again

9:11 到公司。Lisa 已经 8:50 到——同周一周二一致。

_她固定 8:50 来。她可能调整了闹钟。_

_或者她调整了地铁班次。_

_她计算了一个新的精度。_

# scene: workstation_phone_buzz
# diegetic_ui: phone_wechat_notification

工位上你手机弹出 1 条消息。

# speaker: wang_director
老板助理 Jeffrey: "@所有部门同事 本月度 KPI 累积已过半, 请关注个人考核进度。HR 浮层将于 5/9 (周日) 推送月末通报。"

_5/9 推送。今天 5/5。_

_4 天后 = 月度 KPI Review。_

_S1 末是 5/2 (上周日), S2 第 1 个 KPI Review 是 5/9。_

_我下个月每天打卡。_

* [开始今日]
    -> day_32_event_1_morning_lisa_quiet


// ----------------------------------------------------------------------------
// Event 32.1 · 上午 Lisa 不主动 · 10:30
// ----------------------------------------------------------------------------
// 触发: 第 2 个 event
// 速度: 闪 (~5 行)
// 同框: Lisa (前景, 不主动)
// ----------------------------------------------------------------------------

= day_32_event_1_morning_lisa_quiet
# scene: workstation_with_lisa
# time: 10:30
# npc: lisa_solitary_typing

10:30。Lisa 在工位敲键盘。

她**没回头**, 没拿手机, 没去茶水间。

S1 末她每天 10:30 站起来去喝水 1 次。

今天她坐了 2 个小时没动过。

_她在赶 PPT。_

_她背可能酸了。她颈椎可能酸了。_

_但她不站起来——可能怕王总监巡场不在工位。_

_可能他周三晨会眼神扫她那 2 次让她以为"王总监在盯"。_

_他不在盯。他可能根本没看她。_

_但她已经把那个仪式记心里了。_

_这就是 PUA——他不需要持续盯, 他只需要让你以为他盯。_

// 没有选项 - Lisa quiet sign 累积

~ check_state_after_choice()
-> day_32_event_2_li_ayi_overtime


// ----------------------------------------------------------------------------
// Event 32.2 · 笑天加班路过李阿姨拖地 · 19:30
// ----------------------------------------------------------------------------
// 触发: 申报加班后晚上
// 速度: 标准 (~7 行)
// 同框: 李阿姨 + 笑天
// NPC archetype: 李阿姨 background — 无对话, 但她注意到了
// 设计意图: S1 E3 王总监工位灯 / S2 E5 李阿姨拖工位 — visual mirror
// ----------------------------------------------------------------------------

= day_32_event_2_li_ayi_overtime
# scene: office_after_hours_corridor
# time: 19:30
# npc: li_ayi_pushing_mop_cart
# npc: lisa_still_at_desk_in_background

你今天申报了加班——你想看 Lisa 几点走。

~ state = state - 10
~ kpi = kpi + 5
~ effort_overage = effort_overage + 1

19:30。你去茶水间接水。

走廊那头, 李阿姨**还在拖地**。

她推着拖把车——她拖把车上贴的不再是孙女照片了。

S1 E3 周五她拖把车上是"儿子高考准考证"。

今天她拖把车上是**新的便利贴**——"加油"两个字。

_她儿子要考试了。_

_她**没看你**, 但她**多拖了一遍**你工位旁边的过道。_

_她在准备让你回家。_

_她拖到你脚边时, 你说一句"阿姨慢一点"——但她已经拖过去了。_

_她可能没听见。_

_或者她听见了, 但她故意不抬头。_

_不抬头是她的礼貌。_

# scene: workstation_late
# npc: lisa_still_at_v10

回工位的路上你瞥了 Lisa 工位——她**还在**。屏幕是 PPT。

_19:30 还在。_

_她加班速度比 S1 慢——不是因为她偷懒, 是因为她改的 PPT 越来越复杂。_

_或者她改了又改不定稿。_

// 没有选项 - 李阿姨 background + Lisa 加班 background

// hidden flag: 李阿姨拖把车便利贴换"加油" D32 - 李阿姨 S2 quiet escalation
// hidden flag: Lisa 周四 19:30 V10 D32

~ check_state_after_choice()
-> day_32_after_work


= day_32_after_work
# scene: workstation_evening
# time: 20:00
# npc: lisa_still_at_desk

你 20:00 关电脑走人。Lisa 还在。

_她可能 21:00 走。也可能 22:00。_

_我不会追问。_

* [继续走]
    Lisa 没回头。
    ~ lisa_score = lisa_score + 0

-

~ check_state_after_choice()
# pagebreak
-> day_32_daily_recap


= day_32_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 老板助理群通知本月度 KPI 累积过半 (5/9 浮层推送)_
_  - Lisa 上午 10:30 坐 2 小时不动_
_  - 19:30 笑天加班——李阿姨拖把车便利贴换"加油" + 多拖一遍工位过道_
_  - 周四 19:30 Lisa 还在工位敲 PPT_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_33_morning_briefing


// ============================================================================
// Day 33 · 周五 · weekly_recap day · Lisa 19:30 还在工位
// ============================================================================
// 关键 beat:
//   - weekly_recap overlay (HR 系统提示月度倒数)
//   - Lisa 19:30 还在工位 (S1 末她从来没加班这么晚)

= day_33_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared

周五。雨停了。

# scene: office_workstation
# time: 9:08
# npc: lisa_already_at_desk

9:08 到公司。

Lisa **已经在了**——她固定 8:50 到的。

她今天**穿浅色衬衫**——同 S1 E1 周五一致。

_她周五穿浅色。她周五晚上有约。_

_S1 那次她下楼后转身去地铁站反方向——可能不回家。_

_这周她还会去吗?_

_她周一周二周三周四都加班。她周五还有 reserve 去 hangout?_

# scene: vivian_at_reception
# prop: fruit_bowl_strawberry_half_apple_half

工位旁边的水果盘**今天换成草莓的一半 + 苹果的一半**——同 S1 E1 周五一致。

_老板老婆只买了一盒草莓。_

_或者 Vivian 给我一个"周五 spike" 的微表情。_

~ fruit_bowl = "mixed"

* [开始今日]
    -> day_33_event_1_weekly_recap_overlay


// ----------------------------------------------------------------------------
// Event 33.1 · weekly_recap 浮层 · 16:50
// ----------------------------------------------------------------------------
// 触发: 周五下班前自动
// 速度: 标准 (~6 行)
// 设计意图: 月度 KPI 倒数 + S2 第 1 周完成度评估
// ----------------------------------------------------------------------------

= day_33_event_1_weekly_recap_overlay
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出周报浮层——"本周三维考核已登记"。

浮层内容：

- 出勤率：100% (5 天 5 打卡)
- 主动产出条目：1-3 项 (取决于你的选择)
- 协作记录：取决于你的 David PPS demo / 王总监 deliverable 选择

浮层底部有一行小字："**本月度 KPI 还有 2 天 (周日 9:30 推送月末通报)**"。

_本月度 KPI 还有 2 天。_

_我下周一周二都还能 push 一下。_

_或者我可以摆烂。_

_但我已经在 S1 末经历过一次 "做对了下月更难"。_

_这周 push 的 KPI = 下个月的 baseline。_

_我清醒。但清醒不代表我会摆烂——房贷在那。_

// hidden flag: D33 周五 HR 浮层提示 - 周日月末通报 setup

~ check_state_after_choice()
-> day_33_event_2_lisa_19_30


// ----------------------------------------------------------------------------
// Event 33.2 · Lisa 19:30 还在工位 · 19:30
// ----------------------------------------------------------------------------
// 触发: 申报加班后回工位
// 速度: 标准 (~7 行)
// 同框: Lisa (前景, 仍在敲键盘)
// 设计意图: S1 末 Lisa 周五 19:00 走的 (D19 V8), 这周她 19:30 还在 (V10/V11)
// ----------------------------------------------------------------------------

= day_33_event_2_lisa_19_30
# scene: workstation_late_friday
# time: 19:30
# npc: lisa_at_v11_still_typing

如果你今天申报加班——

~ state = state - 5    // 周五加班 + 已经周一-周四累积 effort_overage 影响 state baseline

19:30。Lisa **还在**。

她屏幕上是 V11。

她周五**也加班到 19:30**。

S1 末她周五最晚走过 19:00 (E3 D19)。

S2 第 1 周她周五加到 19:30。

_她在改的不是同一份 PPT 了。_

_S1 那份给王总监看, 这份是下周一给林姐看。_

_她为林姐准备的——她希望林姐在 1 个 review 里就 lock in 她。_

_她不知道林姐是 S3 finale 那个人, 但她直觉觉得"林姐这个 review 重要"。_

_她直觉对。_

你站起来收东西。

Lisa 抬头——半秒。

她看了你一眼, 没说话, 又低头。

_她周五晚 19:30 看你走的眼神——那不是"明天见"。_

_是"你回去歇着, 我还在跑"。_

_我不会留下来陪她——留下来不解决她的 PPT, 反而让我自己也熬。_

_我先走。_

// 没有选项 - Lisa quiet sign 加深 (周五加班升级)
// hidden flag: Lisa D33 周五 19:30 V11 - 比 S1 末晚 30 分钟

~ check_state_after_choice()
-> day_33_after_work


= day_33_after_work
# scene: workstation_evening
# time: 19:35
# npc: lisa_still_in_background

19:35。你出公司大门。

Vivian 已经走了——她周五永远 17:35 走人。

街上下起小雨。

_周五晚 19:35。地球继续转动。_

_明天周末。_

_我先睡饱。_

* [自己回家]
    你在地铁口买了一份煎饼, 12 块。
    ~ money = money - 12
    ~ state = state + 2

* [申报加班 (already 申报过的话)]
    // 注: 此选项跟 day_33_event_2 重复 - 实际渲染时按状态决定显隐
    你回工位再干 1 小时——但 Lisa 已经在改下一版了, 你想给她声援的姿态没意义。
    ~ state = state - 5
    ~ kpi = kpi + 3

-

~ check_state_after_choice()
# pagebreak
-> day_33_daily_recap


= day_33_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 2 天 (周日 9:30 推送)_

_关键时刻 today:_
_  - HR 浮层 + 周日月末通报 setup_
_  - Lisa 周五 19:30 V11 — S1 末从来没这么晚 (E5 唯一 PPT 版本号 spike)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_34_weekend_morning


// ============================================================================
// Day 34 · 周六 · 周末
// ============================================================================
// 关键 beat:
//   - 11:14 起床 (跟 S1 一致 baseline)
//   - David 朋友圈 "周末加班的都是兄弟" 升级版
//   - 笑天下午什么都没做

= day_34_weekend_morning
# scene: bedroom
# time: 11:14
# music: weekend_silence

你睡到 11:14 醒。

_S1 第 1 周 11:14。S2 第 1 周也是 11:14。_

_精度 stable。_

_我固定地荒废周末。_

# diegetic_ui: phone_wechat_moments

朋友圈：

David 发了"**周末加班 + 周一计划 = 我的双轮驱动**" + 自拍 + 工位照。

_他周日加班 + 周一规划 = 双轮驱动。_

_他没明说他在卷自己的 review, 但配文是 review 体。_

_他在为下周一王总监 1v1 排练。_

_他比我清醒——他知道 1v1 是 review。_

_我以为只是 cue。_

Lisa 朋友圈最新一条还是上周日 21:30 那张 PPT 屏幕"看花了"。

她整周没发新的。

_她在闷头干。_

_她不发朋友圈——这是她最近的习惯。_

11:34, 你点外卖：粥 + 油条 + 蛋。35 块。
~ money = money - 35

_周末就该花钱。_

12:08, 外卖到了。你吃了一半就饱了——晚饭再补。
~ state = state + 5

* [开始今日]
    -> day_34_event_1_afternoon


// ----------------------------------------------------------------------------
// Event 34.1 · 周六下午 · 14:00
// ----------------------------------------------------------------------------
// 触发: 午饭后
// 速度: 闪 (~5 行)
// ----------------------------------------------------------------------------

= day_34_event_1_afternoon
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你在床上。

你打开了 B 站, 看了 2 个视频。

你打开了某个购物 App, 把购物车里的浅色衬衫**还在购物车里**——上周加的, 这周还没付款。

_我没付。我可能下周还不付。_

_或者我月末发工资就付。_

你又躺了 30 分钟。

# diegetic_ui: phone_wechat_chat
# npc: david_via_phone

下午 3 点。微信 1 条。David: "兄弟, 下周一 1v1 王总监问我们 deliverable, 我准备 4 项, 你呢?"

_他周六下午问我准备几项。_

_他真的当 review。_

_他也想试探我准备多少项。_

* [4 项]
    # speaker: david
    David: "好啊, 那我也 4 项。"
    _他抄我的数字。或者他用我的数字 calibrate 自己。_
    ~ david_score = david_score + 0

* [我还没想]
    # speaker: david
    David: "啊好的, 那你周日想下哈。"
    _他知道我周日不想。_
    ~ david_score = david_score + 0

* [不回]
    20 分钟后 David: "兄弟你在不在?"
    _他在催我。_
    # speaker: protagonist
    你回："在。明天再聊。"
    # speaker: david
    David: "好。"
    ~ david_score = david_score - 1

-

~ state = state + 30   // regenForRestDay 自动 (R2 fix: gather 前置, 3 选 1 都汇总)

~ check_state_after_choice()
# pagebreak
-> day_34_daily_recap


= day_34_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 11:14 起床 (baseline)_
_  - David 朋友圈"双轮驱动"_
_  - Lisa 整周没发新朋友圈_
_  - David 微信问下周一 1v1 deliverable 数_

# pagebreak
-> day_35_weekend_morning


// ============================================================================
// Day 35 · 周日 · 妈妈视频"你是不是瘦了" + Lisa 微信 cliffhanger
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈视频 "天天, 吃了吗? ... 你是不是瘦了"
//   - 21:00 Lisa 朋友圈 1 张工位照
//   - 21:30 Lisa 微信 "今天周日我也来公司了。明天早 8:00 见。"

= day_35_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

你 8:23 醒。

_8:30 妈妈视频。_

_她每周日固定。她不知道我每周日 8:23 都在等。_

_或者她知道, 她故意 8:30 整。_

8:30:00 整, 微信视频铃响。

# diegetic_ui: phone_video_call_incoming

* [接通]
    -> day_35_event_1_mom_video_thinner


// ----------------------------------------------------------------------------
// Event 35.1 · 妈妈视频"你是不是瘦了" · 8:30 (E5 finale 轻扎)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~12 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 S2 升级 — 从 "那个谁" 到 "你是不是瘦了"
// Verbatim: "你是不是瘦了" 必保留 (但不在 §6 verbatim 锚里, 自由微调)
// ----------------------------------------------------------------------------

= day_35_event_1_mom_video_thinner
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen
# prop: kitchen_yellowed_recipe

屏幕里是妈妈。

她戴着老花眼镜, 眼镜距离屏幕很近。

# speaker: mama
妈妈："**天天, 吃了吗?**"

# speaker: protagonist
你："吃了。"

_我没吃。今天我 8:23 才醒。_

# speaker: mama
妈妈："**工资发了吗?**"

# speaker: protagonist
你："发了。"

_S1 末发的。这个月还没发。_

# speaker: mama
妈妈："**那个谁的儿子结婚了。**"

# speaker: protagonist
你："嗯。"

_今天没说哪个谁。_

妈妈眯眼看屏幕。

"天天——"

她 0.5 秒。

"**你是不是瘦了?**"

_她瞪着屏幕。_

_她的老花镜过滤掉所有细节——她应该看不出来我胖瘦的。_

_除非她从前 4 周的视频里 build 了一个 baseline, 这周我比 baseline 瘦了。_

_她没说"再等等"那一套。她直接问"你是不是瘦了"。_

_她担心。_

_她不会说她担心。_

* [没有, 妈]
    # speaker: mama
    妈妈："骗我。"
    _她的语气是软的, 但她说"骗我"。_
    "看你脸——眼睛比上周大了一点。眼睛大说明你瘦了。"
    _她在用眼睛大小做体重估计。_
    _我不能反驳——她可能是对的。_
    "好好吃饭。"
    # speaker: protagonist
    你："好。"
    ~ mom_score = mom_score + 2

* [可能吧]
    # speaker: mama
    妈妈："肯定瘦了。"
    _她叹了 0.5 秒。_
    "我下午去菜市场买点排骨, 我做好了寄给你。"
    _她要寄排骨。冷链 7 天。她以前从没寄过。_
    "妈, 不用——"
    # speaker: mama
    妈妈: "你那边吃外卖。你吃排骨好。"
    ~ mom_score = mom_score + 5
    // hidden flag: 妈妈下周寄排骨 - E6 周一/周二可能到货

* [转移话题: 你呢妈]
    # speaker: mama
    妈妈："我啊, 挺好的。"
    _她笑了一下。_
    "今天我去广场跳了一会儿。前几天你姨说她老李身体不行了, 我们都老了。"
    _姨在念叨"老李"。我不知道老李是谁。_
    "好。"
    # speaker: mama
    妈妈："你呢?"
    # speaker: protagonist
    你："**再等等**。"
    _她沉默了 1 秒。_ "好。"
    ~ mom_score = mom_score + 0

- _挂掉视频后你坐在床上 30 秒。_
- _她每周都是同样的 4 句开场。_
- _她每周都加 1 句新的。_
- _上周是"那个王二家儿子上海买房了"。_
- _这周是"你是不是瘦了"。_
- _下周是什么?_

// hidden flag: 妈妈 D35 "你是不是瘦了" - S2 第 1 个 escalation

~ check_state_after_choice()
-> day_35_event_2_afternoon_quiet


// ----------------------------------------------------------------------------
// Event 35.2 · 周日下午 · 不去公司 + 看 Lisa 朋友圈 · 14:00
// ----------------------------------------------------------------------------
// 触发: 午饭后
// 速度: 标准 (~7 行)
// 设计意图: S1 E1 笑天周日去公司浇绿萝, S2 第 1 周笑天不去 (转折)
// ----------------------------------------------------------------------------

= day_35_event_2_afternoon_quiet
# scene: bedroom_afternoon
# time: 14:00
# diegetic_ui: phone_wechat_moments

下午 14:00。

你点了一份外卖咖啡——18 块。
~ money = money - 18

_S1 第 1 周我周日下午去公司浇绿萝。_

_S2 第 1 周我不去。_

_累。_

# diegetic_ui: phone_wechat_lisa_moments_check

你又刷了一遍朋友圈。

Lisa 还是没发新的——她整周朋友圈最新一条还是上周日 PPT 屏幕"看花了"。

# diegetic_ui: phone_wechat_lisa_status

你看了一下她**微信状态**——状态显示是"忙——"。

_她设了"忙"。_

_S1 她从不设状态。S2 第 1 周她设了"忙"。_

_她在告诉所有发她消息的人:"别打扰"。_

_我也没打算打扰她。_

// 没有选项 - Lisa quiet sign

~ state = state + 5   // 周末轻量 regen

~ check_state_after_choice()
-> day_35_event_3_lisa_message_8am


// ----------------------------------------------------------------------------
// Event 35.3 · Lisa 微信 "周日我也来公司了" · 21:30 (E5 → E6 cliffhanger)
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 标准 (~7 行)
// 同框: Lisa (微信)
// 设计意图: E5 → E6 cliffhanger - Lisa 周日加班 + 明天早 8:00
// ----------------------------------------------------------------------------

= day_35_event_3_lisa_message_8am
# scene: home_evening
# time: 21:30
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:30。你刚洗完澡。

微信消息 1 条。

# speaker: lisa
Lisa：

"笑天, **今天周日我也来公司了。明天早 8:00 见。**"

_今天周日我也来公司了。_

_她周一 8:50 + 周二 8:50 + 周三 9:25 + 周四 8:50 + 周五 8:50 + 周日整天。_

_她这周 7 天 6 天在公司。_

_明天早 8:00 见。_

_她明天**比我早 1 小时 14 分钟**到。_

_她从 8:50 加速到 8:00。_

_她在加速。_

_她不会告诉我她为什么。_

_或者她想告诉我但她不知道怎么说。_

* [明天 8:00 我也尽量到]
    # speaker: lisa
    Lisa："好。"
    _没了下文。_
    _她周日晚 21:30 + 我答应 8:00 = 我明天可能 6:50 起床, 7:30 出门。_
    _我以前 6:50 起床过。我能再起一次。_
    ~ lisa_score = lisa_score + 3
    ~ effort_overage = effort_overage + 1
    // hidden flag: 笑天答应明早 8:00 到公司

* [好]
    # speaker: lisa
    Lisa："好。"
    _她没继续。_
    ~ lisa_score = lisa_score + 0

* [辛苦]
    # speaker: lisa
    Lisa："嗯。"
    _没了下文。_
    ~ lisa_score = lisa_score + 1

* [不回]
    _她没追问。_
    ~ lisa_score = lisa_score - 2

- _不论选什么。_
- _她周日 21:30 在床上发"明天 8:00 见"。_
- _S1 末她微信"下个月加班多一点"我以为她说晚下班。_
- _现在我知道她说**早上班**。_
- _下下周可能 7:30。再下下周 7:00。_
- _她在追什么? 不是加班费——这家公司不发加班费。_
- _她在追"我足够拼"——那个能让王总监 / Zoe / 林姐 看见的"拼"。_
- _但反向 KPI: 你越拼, 下个月 baseline 越高。她不知道。_

// hidden flag: E5 → E6 cliffhanger - Lisa 周日加班 + 明早 8:00

~ check_state_after_choice()
# pagebreak
-> day_35_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 35 周日日报 (E5 末)
// ----------------------------------------------------------------------------

= day_35_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +12)_

_关键时刻 today:_
_  - 8:30 妈妈视频"你是不是瘦了" (E5 finale 轻扎)_
_  - 21:30 Lisa 微信"今天周日我也来公司了。明天早 8:00 见。" (E5 → E6 cliffhanger)_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 6 周 — Lisa 改喝便利店咖啡_

// E5 结束 - cliffhanger 到 E6 周一 Lisa 真的 8:00 到

-> END

// ============================================================================
// EOF episode-5.ink
// ============================================================================
//
// 分身 task summary (W3 = S2 Round 1):
//   - Day 29-35 全 7 天 stitches 完整
//   - Vivian C Vulnerability ("D 轮过会被打回了") D29 verbatim
//   - 王总监 D29 单独 cue 笑天 = E5 集内高峰
//   - Lisa quiet sign 累积起步: 8:50 已在 + 没拼奶茶 + 眼药水 1/4 + 19:30 V11
//   - 妈妈 D35 "你是不是瘦了" = E5 轻扎
//   - Lisa D35 "明天 8:00 见" = E5 → E6 cliffhanger
//
// 笑/泪比 = 7:3 (per season-2-arc.md §1):
//   - 笑点: D29 Vivian D 轮 / 王总监 muscle memory cue / D30 David 群里"@所有人"
//          / D31 王总监 BLUEPRINT V2 + 8 分钟散会 / D33 Vivian 周五 spike / D34 David 双轮驱动
//   - 扎点: D29 Lisa 已 8:50 / D32 Lisa 坐 2 小时不动 / D33 Lisa 19:30 V11 / D35 妈妈"你是不是瘦了"
//
// 红线 (S2 不能做 - per season-2-arc.md §11):
//   - Lisa 不决定走/留 ✓
//   - HR 月度面谈不在 E5 ✓
//   - 王总监不直接对 Lisa "潜力一般" ✓
//   - 林姐 S2 仍不出场 (mention only D31 晨会 + D31 内心独白) ✓
//   - Lisa 不剪短发 ✓ (那是 E7 周一)
//   - David 不燃尽 ✓
//   - 老周 S2 对话 = 0 ✓ (D31 晨会出现但仅喝茶)
//
// END
