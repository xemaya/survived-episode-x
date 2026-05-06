// ============================================================================
// Episode 1 · Week 1 · 「入职第 12 周」
// ============================================================================
//
// Status: 第 1 版 (designer 样例—— Day 1 + Day 2 morning 完整示范，Day 2
//         events 起 -> Day 7 由分身 CC session 按 episode-generation-brief.md
//         补全)
// Author: Game Designer (原 CC session)
// Last Updated: 2026-05-05
//
// 配套 reference:
//   - design/vertical-slice/series-structure.md (52 集 macro)
//   - design/vertical-slice/season-1-arc.md v2 (S1 outline + per-NPC arc)
//   - design/vertical-slice/protagonist.md (笑天 voice)
//   - design/vertical-slice/npcs.md v2 (10 NPC 设定)
//   - design/vertical-slice/tone-bible.md v2 (5 原则)
//   - design/vertical-slice/episode-generation-brief.md (拆解任务说明)
//
// 引擎: Ink (https://www.inklestudios.com/ink/) + inkjs runtime + TS+PixiJS+
//       Tauri 壳。本文件 .ink 直接 compile 到 episode-1.json，由 inkjs
//       runtime 解释，TS 监听 ink state change 更新 PixiJS diegetic UI props。
//
// 怎么读这个文件:
//   1. 顶部 VAR 声明 = 全 series 共享的 game state (3 属性 + 关键 flag + NPC scores)
//   2. INCLUDE = 从其他 .ink 文件导入 (daily-choices.ink / shared-helpers.ink)
//   3. === episode_1 === = 主入口 knot
//   4. = day_1_morning_briefing = stitch (sub-section)
//   5. 段落文本 = 玩家看到的对白 / 描写
//   6. _斜体_ = 笑天内心独白
//   7. * [选项] = 玩家选择 (4 字内)
//   8. ~ var = ... = state 变化
//   9. {condition: text} = 条件文本
//   10. -> knot.stitch = divert (跳转)
//   11. # tag = 给 TS 渲染层的 hint (scene change / prop update / NPC frame)
//
// ============================================================================
// 全 series 共享的 VAR (实际项目中应放 shared-state.ink 由所有 episode INCLUDE)
// ============================================================================

VAR kpi = 100              // 0-200, < 50 GO / 累积 > 150 进入晋升候选
VAR money = 5500           // 起始 5500 (扣完房贷后), < 4500 银行 app 跳出
VAR state = 80             // 0-100, < 20 病倒强制休假, 累积病倒 6 次直接辞退

// NPC scores (per npcs.md)
VAR lisa_score = 0
VAR david_score = 0
VAR wang_score = 0         // 王总监
VAR zoe_score = 0
VAR li_score = 0           // 李阿姨
VAR vivian_score = 0
VAR it_xiaoma_score = 0
VAR lao_zhou_score = 0
VAR mom_score = 0
// 林姐 S1 不出场，不需要 var

// 隐藏 flags (per series-structure macro)
VAR sick_count = 0                   // 累积病倒次数
VAR promotion_candidate_count = 0    // 累积 KPI > 150 月数 (3 次进入候选, 6 次终极 GO)
VAR effort_overage = 0               // S1 finale 计算用
VAR lisa_helped_pps = false          // E2-E3 影响 lisa S2-S3 trajectory
VAR weekend_with_lisa = false        // S3 finale 路径判定
VAR david_blood_drawn = 0            // 笑天帮 David 改 PPT 次数 (累积)
VAR fruit_bowl = "apple"             // "apple" 融资暂停 / "strawberry" 融资到位
VAR coffee_machine_broken_days = 22  // 咖啡机坏的天数 (running gag)
VAR weather = "rainy"                // 天气 (周二切到 rainy)

// S2 Round 2 (W3) — cross-episode flags set in E5-E8, read in S3+
VAR lisa_helped_after_hr = false     // E8 D56 path A → S3 救 Lisa 路径关键 flag
VAR mom_visit_pending = false        // E8 D56 妈妈"我下个月想去你那" path A
VAR mom_visit_postponed = false      // E8 D56 path B (笑天拒绝下个月)
VAR mom_visit_pending_undecided = false  // E8 D56 path D (笑天"让我想想")

// ============================================================================
// Helper functions
// ============================================================================
//
// Round 2 patch (2026-05-05): originally `check_state_after_choice()` was an
// ink function that diverted to GO knots. **Ink does not allow functions
// to contain diverts.** Moved GO check logic to TS runtime — runtime polls
// state/money/sick_count after every story.Continue() and triggers the
// appropriate GO via story.ChoosePathString(). The function is now a no-op
// kept for compatibility with the ~600 `~ check_state_after_choice()` calls
// across all 5 .ink files (cheaper than removing every call).
//
// GO knots (game_over_too_sick / game_over_promoted / sick_event_forced_leave
// / bank_alert_event) are now defined as no-op stubs that just END. The TS
// runtime intercepts and renders the actual GO scenes.

=== function check_state_after_choice() ===
    ~ return  // no-op; GO check happens in TS runtime

=== game_over_too_sick ===
-> END

=== game_over_promoted ===
-> END

=== sick_event_forced_leave ===
-> END

=== bank_alert_event ===
-> END

// ============================================================================
// Episode 1 主入口
// ============================================================================

// ============================================================================
// Intro / 新手引导 (P5 demo addition — boot diverts here, not episode_1)
// ============================================================================
// 笑天 voice 自介 + 游戏机制 + 不可能三角 + 输赢条件 + 1 个开始按钮。
// 4 段 1 选项, 让玩家在 30 秒内 onboard。

=== intro ===
# scene: intro
# time: pre_game

你好。

我陈笑天。32 岁。产品助理。

我妈起的名字——希望我"笑傲天下众生"。

我现在在数咖啡杯。

入职第 12 周。

接下来 52 周, 你陪我走。

* [然后呢]
    -> intro_mechanics

= intro_mechanics
# scene: intro
# time: pre_game

我每天有 8 个时间槽。

每个槽, 事会发生——你点选项, 我应付。

我手里 3 件事在转——

· KPI (事多事少) — 太低被裁。太高升职——升职是处刑。
· 钱 (月固定工资 + 你帮我省的零碎) — 不够付房贷, 我必须辞职。
· 状态 (个人自由 + 身心健康) — 撑不住病倒, 6 次以上直接被辞退。

钱多 / 事少 / 离家近——三样不可兼得。

打工人的不可能三角。

* [听懂了]
    -> intro_endgame

= intro_endgame
# scene: intro
# time: pre_game

游戏从 2026 年 5 月开始。

活过这一年 (52 周) 就赢——不是升职加薪那种赢, 是"熬过去"那种赢。

任意一个月 KPI 崩, 或者钱断, 或者病倒 7 次, 就 game over。

我妈不知道我在玩这种游戏。她以为我在大公司当 leader。

* [我懂了, 开始第 1 天]
    -> episode_1

// (intro 结束 → 跳到 episode_1 knot, 见下方 ===)


// ============================================================================
// Episode 1 主入口
// ============================================================================

=== episode_1 ===
# scene: home
# time: monday_morning
# pagebreak
-> day_1_morning_briefing

// ============================================================================
// Day 1 · 周一
// ============================================================================

= day_1_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# music: monday_drone

闹钟响了 3 次。

你叫 **陈笑天**。32 岁，产品助理。

你妈起的名字——希望你"笑傲天下众生"。你长大成了一个每天偷茶水间速溶咖啡的中年男人。

_笑天下众生。我妈是这么想的。_

你刷牙的时候看了一眼镜子。还是那张脸。还是那件灰色 polo。衣柜里有 5 件灰色 polo + 5 件黑色 polo，轮换。

_反 David 的"挽袖子的衬衫"。我懒。_

你出门，地铁，10 号线换 6 号线。地铁上一个穿黑西装的女生在前一站下车。

_她可能是金融行业。她也在装。_

# scene: office_entrance
# time: 9:14

9:14 到公司。打卡机响了一下。**你比 9:00 整晚 14 分钟**。

_上家那次我打卡精度是 8:59:30。这次不需要那么紧。_

# scene: office_workstation
# prop: green_plant_dripped
# prop: sticky_note_visible

工位上的咖啡杯还是上周五的样子。前任员工离职时留下的那盆小绿萝你浇了 3 滴水。

_它走了我还在。_

桌面便利贴："活到周五"——你自己写的，过了一周还在。

微信头像是 5 年前去日本旅游的富士山。

_那时候我以为我会再去。_

# diegetic_prop: mug_full
AP 8 / 8。这是你入职后的**第 12 周**第 1 天。

_周一上午 9:14，地球继续转动。_

* [开始今日]
    -> day_1_event_1_vivian


// ----------------------------------------------------------------------------
// Event 1.1 · 前台 Vivian 的"嗨～" · 上午 9:15
// ----------------------------------------------------------------------------
// 触发: morning_briefing 结束后第 1 个 AP 前
// 速度: 闪 (~3 行)
// 同框: Vivian (前景)
// NPC archetype: Vivian A (First Impression)
// ----------------------------------------------------------------------------

= day_1_event_1_vivian
# scene: reception
# npc: vivian_smiling
# prop: fruit_bowl_apple

你刷工牌过门禁，前台 Vivian 抬头。

"嗨～来啦～"

她拖长了音。眼睛已经飘向门口下一个。

工位旁边的水果盘今天是 **苹果**。

_上次草莓是 2 月，那个月 D 轮到账。这次苹果——融资暂停，或者老板老婆嫌草莓贵。_

// 这个 event 没有选项 (Vivian 的"嗨～"对所有人都一样)
// 直接拿苹果是隐性默认动作

~ money = money + 1   // 苹果价值约 1 元
~ state = state + 2

_我拿了一个苹果。_

_不多。但算我赢一次。_

// 设置 fruit_bowl 信号 (S1 月初 = apple, E2 周一会变成 strawberry)
~ fruit_bowl = "apple"

~ check_state_after_choice()
-> day_1_event_2_caishuijian


// ----------------------------------------------------------------------------
// Event 1.2 · 茶水间偶遇 · 上午 10:30
// ----------------------------------------------------------------------------
// 触发: 进入工位 1 AP 后自动
// 速度: 标准 (~6 行)
// 同框: Lisa (前景) + 李阿姨 (背景拖地) + IT 小马 (背景贴告示)
// NPC archetype: Lisa A (First Impression) + 李阿姨 A + IT 小马 A
// ----------------------------------------------------------------------------

= day_1_event_2_caishuijian
# scene: break_room
# npc: lisa_holding_milk_tea_cup
# npc: lao_li_mopping_background
# npc: it_xiaoma_back_at_machine
# prop: coffee_machine_broken_sign

茶水间。

你刚拧开热水壶，听见身后有人。

"诶，你先用吧。" Lisa 抱着保温杯，往后让了半步。

她手里的不是保温杯。是一个**奶茶杯**——空的，她在洗。

茶水间另一头，李阿姨在拖地，没抬头。她拖把车上贴着她孙女的照片。

咖啡机上贴了一张新的 A4 纸："**故障维修中**"。落款"IT 部"。下方便利贴是另一张手写的："**已派单**"。

你看了一眼旁边——IT 小马正背对着你蹲在咖啡机后面，黑色帽 T，机修包放在脚边。他听见你来了，头也不回："**已派单了哈**。"

_他派单 {coffee_machine_broken_days} 天了。_

* [让 Lisa 先]
    Lisa："谢谢哈。"
    _她接了水，转身回工位时回头看了你一眼。_
    ~ lisa_score = lisa_score + 1
    -> day_1_event_3_dianti_david

* [你先]
    "挺烫的。"她说。
    _你接完水，她在等。_
    ~ lisa_score = lisa_score + 0
    -> day_1_event_3_dianti_david

* [不说话，先接你的]
    Lisa 往后又退了半步，没说话。
    ~ lisa_score = lisa_score - 2
    -> day_1_event_3_dianti_david


// ----------------------------------------------------------------------------
// Event 1.3 · 电梯里的 David · 上午 11:42
// ----------------------------------------------------------------------------
// 触发: 第 2 个 AP 后
// 速度: 标准 (~6 行)
// 同框: David (前景)
// NPC archetype: David A (First Impression)
// ----------------------------------------------------------------------------

= day_1_event_3_dianti_david
# scene: elevator
# npc: david_in_shirt_no_top_button
# time: 11:42

11:42。你想去 16 楼上厕所——本层那个地漏味道大。

电梯门打开，David 也走进来。**他穿衬衫，没系最上面那颗扣子**。

"兄弟，周末过得怎样？"

_他这句开场白对所有人都一样。我去年入职第 2 天他就这么问过我。_

* [还行，你呢]
    David："我啊，周六加了一天班。哎，我这种人就是闲不住。"
    _他笑了一下，眼睛在等你回应。_
    ~ david_score = david_score + 0

* [在家躺了]
    David："哈哈，是啊年轻人就该多休息。"
    _他这句的语气你听不出是真心还是讽刺。_
    ~ david_score = david_score - 2

* [不回答，看手机]
    _电梯到了。David："那回头聊。" 走了。_
    ~ david_score = david_score - 3

- _电梯门关上时，你想起来你其实周末两天都在补觉。_

~ check_state_after_choice()
-> day_1_event_4_wang


// ----------------------------------------------------------------------------
// Event 1.4 · 王总监的"加油啊" · 中午 12:18
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~5 行)
// 同框: 王总监 (前景)
// NPC archetype: 王总监 A (First Impression) — running gag 起手式
// ----------------------------------------------------------------------------

= day_1_event_4_wang
# scene: workstation_pantry_corner
# npc: wang_walking_by
# time: 12:18

你刚泡好面（茶水间的，速溶咖啡顺便揣了 1 包），王总监从远端独立办公室出来路过工位区。

~ money = money + 1   // 偷的咖啡

"小笑啊。"

他犹豫 0.5 秒。

"陈天啊。"

又犹豫 0.5 秒。

"差不多差不多。**加油啊**。"

他没等你回答，已经走过去了。

// 这个 event 没有选项 - 王总监的全部就是叫不准名字 + 走人

_我入职第 12 周了。他还是叫不准。_

_但他记住了"加油啊"。_

_老板把记住下属名字当 KPI。他自己的 KPI 是"显得记得住"。_

~ wang_score = wang_score + 0   // 王总监不在乎你的 score, 但他记 1 笔

~ check_state_after_choice()
-> day_1_event_5_lao_zhou


// ----------------------------------------------------------------------------
// Event 1.5 · 老周工位经过 · 下午 14:30
// ----------------------------------------------------------------------------
// 触发: 第 4 个 AP
// 速度: 闪 (~3 行)
// 同框: 老周 (背景, 不抬头)
// NPC archetype: 老周 A (First Impression)
// ----------------------------------------------------------------------------

= day_1_event_5_lao_zhou
# scene: corner_workstation_lao_zhou
# npc: lao_zhou_facing_window_back
# prop: three_tea_cups_on_desk
# prop: sticky_note_pass_today
# time: 14:30

你去打印机取一份纸。打印机在角落，旁边就是老周工位。

老周面对窗户坐着，背对人群。他在看 Excel——一个有 60 列的表，他在从左滚到右，慢慢看。

他桌上放着 3 个茶杯。其中 2 个的水颜色看起来已经凉很久了。

桌面便利贴上写："**过完今天**"。字迹很旧。

他没抬头。

// 没有选项 - 老周第一次出场是观察, 不是互动
// 笑天的内心独白密集铺垫"未来自己"镜像

_他比我先到 10 年。_

_他穿的也是灰色 polo。_

_他的"过完今天"是按天活的。我的"活到周五"还有期待。_

_再过 10 年我会不会变成这样按天活。_

~ check_state_after_choice()
-> day_1_event_6_lisa_kerying


// ----------------------------------------------------------------------------
// Event 1.6 · 下午 3 点的工位 · 下午 15:00 · 闲笔
// ----------------------------------------------------------------------------
// 触发: 第 5 个 AP
// 速度: 闪 (~4 行)
// 同框: Lisa (背景敲键盘)
// 设计意图: Pillar 2 极致 — 没有选项也是设计 + 铺垫 E2 Lisa 主动求帮 PPT
// ----------------------------------------------------------------------------

= day_1_event_6_lisa_kerying
# scene: workstation_facing_lisa
# npc: lisa_typing_facing_screen
# time: 15:00

下午 3 点。Lisa 在你斜对角的工位敲键盘，速度很快。

你回头看了一眼。她在改 PPT 字号。从 24 改到 22 又改回 24。

_她改了 6 遍。_

你转回自己屏幕。打开周报模板。

// 没有选项 - 这是 Pillar 2 极致, 没有选项也是设计

~ check_state_after_choice()
-> day_1_after_work


// ----------------------------------------------------------------------------
// after_work · 下班 · 17:30
// ----------------------------------------------------------------------------

= day_1_after_work
# scene: workstation_evening
# npc: lisa_still_at_desk
# npc: david_absent
# time: 17:30

AP 用完了。

Lisa 还在工位敲键盘。David 不在工位（他可能在抽烟，或者在跟王总监单聊）。

* [申报加班 -10 状态 +2 AP 等价]
    你回到工位多干一会，Lisa 抬起头看了你一眼，没说话。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。Lisa："明天见啊。"
    _这是她记住你的一个小动作——她没对每个人都说"明天见"。_
    ~ lisa_score = lisa_score + 0

* [提前下班 (你没用满 8 AP)]
    你把电脑关了，5 点准时走。
    Lisa 没说什么——她在专心改 PPT 第 7 遍。
    ~ effort_overage = effort_overage - 1   // Q4: 提前下班消耗 effort

- _电梯门关上的那一秒。_
- _不多。但算我赢一次。_

~ check_state_after_choice()
# pagebreak
-> day_1_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · 周一日报 · 玩家手机界面 prop
// ----------------------------------------------------------------------------

= day_1_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

// 日报通过手机 prop 呈现, 不是 overlay UI - 维持 art-bible §7.1 diegetic 原则

_今日 KPI: +{kpi} (累积 {kpi}/200)_
_今日 钱: {money} (起始 5500)_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 茶水间见 Lisa (Lisa score: {lisa_score})_
_  - 电梯偶遇 David (David score: {david_score})_
_  - 王总监记不住你名字 (S1 running gag 起手式)_
_  - 老周工位"过完今天"便利贴_

// 隐藏标记 (TS runtime 处理, ink layer 不显示给玩家)
// - S1 月初 = 苹果周 (Vivian 水果盘信号)

# pagebreak
-> day_2_morning_briefing


// ============================================================================
// Day 2 · 周二
// ============================================================================

= day_2_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:09
# weather: rainy

~ weather = "rainy"

早上你出门时下小雨。

# scene: office_entrance
# prop: lisa_blue_umbrella_with_charm

9:09 到公司，Lisa 已经在工位了，她的伞挂在隔板上。**她的伞是浅蓝色的，把手上挂了一个小玩偶**——你回工位的路上瞥到。

王总监今天好像没在——他独立办公室门关着。

# prop: fruit_bowl_apple_again

公司前台水果盘今天**还是苹果**。

_上次苹果是连着 2 周。融资真的没新进展。或者老板老婆讨厌草莓。_

你拿了一个苹果。
~ money = money + 1
~ state = state + 1

_一年下来能省 12 块。不多，但算我赢一次。_

# scene: it_corner_passing
# npc: it_xiaoma_absent

经过 IT 小马的工位角落——他不在。机修包还放在桌上。

~ coffee_machine_broken_days = coffee_machine_broken_days + 1

_他可能去咖啡机蹲着了。已派单第 {coffee_machine_broken_days} 天。_

* [开始今日]
    -> day_2_event_1_lisa_milk_tea


// ----------------------------------------------------------------------------
// Event 2.1 · Lisa 的奶茶单 · 中午 11:50
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 标准 (~5 行)
// 同框: Lisa (前景)
// NPC archetype: Lisa B (Decision Moment) - 第一次决策点 (轻量版, 重量版在 E2 周五帮 PPT)
// ----------------------------------------------------------------------------

= day_2_event_1_lisa_milk_tea
# scene: workstation_lisa_lean_over
# npc: lisa_holding_new_cup
# time: 11:50

Lisa 凑过来。她今天带了一个新的杯子——还是奶茶杯，但杯套是不同品牌。

"午饭点奶茶吗？我满 30 减 8。"

_她午饭点奶茶。她不喝咖啡。_

* [一起]
    Lisa："你喝什么？"
    _你说了一种，她马上下单。"等下哈，10 分钟到。"_
    ~ lisa_score = lisa_score + 3
    ~ money = money - 12   // 你那杯
    ~ state = state + 3

* [不喝，谢谢]
    Lisa："好的。"
    _她转回工位下单了。_
    ~ lisa_score = lisa_score + 0

* [自己泡咖啡了]
    Lisa："哦哦行。"
    _没了下文。_
    ~ lisa_score = lisa_score - 1

- _她每天都点奶茶。她真的喜欢。或者她觉得"喝奶茶的姑娘"这个 image 让她在这个公司不那么孤独。_

~ check_state_after_choice()
-> day_2_event_2_david_ppt_setup


// ----------------------------------------------------------------------------
// Event 2.2 · David 的 PPT 模板 (轻量铺垫 / Chekhov gun setup) · 下午 14:20
// ----------------------------------------------------------------------------
// 触发: 第 4 个 AP
// 速度: 闪 (~4 行)
// 同框: David (远端微信)
// 设计意图: Chekhov gun setup - E2 周一才兑现的"5 分钟的事"
// ----------------------------------------------------------------------------

= day_2_event_2_david_ppt_setup
# scene: workstation_phone_buzz
# diegetic_prop: phone_wechat_notification
# time: 14:20

企业微信弹出 1 条消息。

David："兄弟，下周我有个对接 X 部门的方案要写，到时候帮我看看 PPT 模板？5 分钟的事。"

_下周。"5 分钟的事"。这两个词放一起就是 lie。_

你看了一眼，没回。

5 分钟后，David 又发："不急啊兄弟，我就先打个招呼。"

_他先打招呼是为了下周让你不好意思拒绝。_

// 这个 event 没有选项 - 它是 setup, E2 (week 2) 周一才兑现
// 但 ink 内 set 一个 hidden flag 让 E2 周一 trigger
~ david_blood_drawn = david_blood_drawn + 0   // 还没"被吸"，但 setup done

~ check_state_after_choice()
-> day_2_event_3_lao_zhou_tea_steal


// ----------------------------------------------------------------------------
// Event 2.3 · 偷喝老周的凉茶 · 下午 15:50
// ----------------------------------------------------------------------------
// 触发: 第 5 个 AP
// 速度: 标准 (~7 行)
// 同框: 老周 (前景, 但不抬头)
// NPC archetype: 老周 B (Decision Moment)
// ----------------------------------------------------------------------------

= day_2_event_3_lao_zhou_tea_steal
# scene: corner_workstation_lao_zhou
# npc: lao_zhou_still_facing_window
# prop: three_cups_visible
# time: 15:50

下午 3:50。你想再喝点东西。

茶水间饮水机坏了第 {coffee_machine_broken_days} 天（IT 小马"已派单"），你不想接洗手间的水。

你经过老周工位——他还面对窗户，看 Excel。

桌上 3 个茶杯。**最右边那杯水颜色最浅，看起来今天泡的**。

_老周早上 9:00 准点到，他一定泡了。但他从来没喝过那一杯。我在这观察他 12 周了，我知道他的固定动作。_

_他喝中间那杯。_

你站在他工位侧后方。他还在看 Excel，没注意你。

那杯凉茶就在你伸手能摸到的地方。

* [偷喝那杯，再走]
    你伸手，拿过那杯，走到打印机后面快速喝完。茶有点淡，但是真的茶。
    你把空杯子放回他桌上原位。
    老周还在看 Excel。
    _他不会发现的。_
    _或者他发现了，他不会说什么。_
    ~ lao_zhou_score = lao_zhou_score + 0
    ~ state = state + 2
    // hidden flag: 你在 E1 偷过老周凉茶 1 次

* [拿走杯子，去洗，再放回]
    你拿了杯子去茶水间，洗干净，重新接了凉白开放回原位。
    _他可能更不会发现。但你也没"赢一次"。_
    ~ lao_zhou_score = lao_zhou_score + 0
    ~ state = state + 1

* [主动跟老周说"对不起，您那杯茶我喝了"]
    你站到他工位旁边："周哥，对不起，您那杯茶我刚喝了。"
    老周缓缓抬头，看了你 0.5 秒。
    "嗯。"
    他低下头继续看 Excel。
    _他没说"没事"。他没说"以后别喝"。他就"嗯"。_
    _我不知道这"嗯"是什么意思。_
    ~ lao_zhou_score = lao_zhou_score + 1
    ~ state = state + 0

-

~ check_state_after_choice()
-> day_2_after_work


// ----------------------------------------------------------------------------
// after_work · Day 2 (template - 跟 Day 1 一致, 笑天对话视情况)
// ----------------------------------------------------------------------------

= day_2_after_work
// 同 Day 1 模板 - 申报加班 / 按时下班 / 提前下班 三选 1
// (省略以避免重复 - 分身写时按 day_1_after_work 模板, 文案微调)
// ...
~ check_state_after_choice()
# pagebreak
-> day_2_daily_recap


= day_2_daily_recap
// 同 Day 1 模板 - 关键时刻 today
// ...
# pagebreak
-> day_3_morning_briefing


// ============================================================================
// Day 3 · 周三 (晨会日 / 轻量版 fakeout - 王总监今天没讲 KPI)
// ============================================================================

= day_3_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:25
# weather: cleared

周三是晨会日。

# scene: meeting_room
# time: 9:25
# npc: lisa_in_meeting_room_early
# npc: david_with_okr_notebook
# npc: lao_zhou_with_tea_cup_in_corner

你 9:25 到公司——晨会 9:30 开。Lisa 已经在会议室了，提前 5 分钟。

_她每周三都提前 5 分钟。她真的把晨会当回事。_

David 也在了——他坐在斜对面，已经摊开笔记本。封面贴着便利贴："**Q2 OKR**"。

王总监还没来。

老周也来了——他坐在最后一排靠窗位置，没带笔记本，只带了一个茶杯（**今天他带的是中间那杯**，你确认了）。

_他参加晨会但他从不发言。他只是要"出席率"上数字。_

9:32 王总监推门进来。

* [开始今日]
    -> day_3_event_1_morning_meeting_fakeout


// ----------------------------------------------------------------------------
// Event 3.1 · 晨会 · "今天聊点别的" · 上午 9:32 (Fake-out)
// ----------------------------------------------------------------------------
// 触发: morning_briefing 结束后自动
// 速度: 长 (~10 行)
// 同框: 王总监 + David + Lisa + 老周 (背景) + 笑天
// 设计意图: Pillar 4 Fake-out - 玩家以为今天是 KPI 大事日, 结果是日常 + 聚餐通知
// ----------------------------------------------------------------------------

= day_3_event_1_morning_meeting_fakeout
# scene: meeting_room
# time: 9:32
# npc: wang_with_team_building_ppt
# npc: david_first_to_react
# npc: lisa_writing_notes
# npc: lao_zhou_drinking_tea
# prop: ppt_team_building_dinner

王总监来了。他打开投影仪——今天 PPT 第一页是一张图，**标题"团队建设：本月聚餐建议"**。

_团队建设？_

_他不讲 KPI 了？_

"上午好啊各位。"

王总监站起来："这个月 KPI 还有 12 天，我相信大家都在赶。我今天不想跟大家拉齐 KPI——KPI 大家都有数。"

_他的 PPT 里"BLUEPRINT"那张箭头图哪去了。_

"我跟你们说啊。最近 HR 反馈，咱们部门的'团队凝聚力指数'要再加把劲。所以我提议——我们这个月组织一次部门聚餐。下下周三，AA 制，自愿参加。"

屋里安静一秒。

David 第一个反应："好啊，我可以协调。"

Lisa："好的。"

老周没说话，喝了一口茶。

王总监："还有别的提议吗？没有？那就这样定了。散会。"

整场晨会**8 分钟**结束。

_8 分钟。_

_我以为今天会有戏。_

_他不讲 KPI 不是因为大家都达标——是因为 HR 让他做"团队凝聚力"。_

_AA 制聚餐。我们出钱去喝他给我们 PUA。_

_完美闭环。_

// 没有选项 - fakeout 整段是观察, 不是互动
// hidden flag: 本月部门聚餐预告 (永远不会真的办 - AA 制聚餐总是这样)

~ check_state_after_choice()
-> day_3_event_2_lisa_after_meeting


// ----------------------------------------------------------------------------
// Event 3.2 · 散会后的 Lisa · 上午 9:42
// ----------------------------------------------------------------------------
// 触发: 晨会结束后回工位
// 速度: 闪 (~3 行)
// 同框: Lisa
// ----------------------------------------------------------------------------

= day_3_event_2_lisa_after_meeting
# scene: hallway_back_to_workstation
# time: 9:42
# npc: lisa_walking_alongside

你回工位的路上，Lisa 跟着你。

"笑天，你说这个聚餐我们要去吗？"

_她真的在考虑这件事。_

* [看大家吧]
    Lisa："嗯，我也是这么想的。"
    _她回工位了。_
    ~ lisa_score = lisa_score + 1

* [我不去]
    Lisa："哦……那我也再想想。"
    _她笑了一下。_
    ~ lisa_score = lisa_score + 0

* [我也不知道]
    Lisa："对啊，反正还有半个月。"
    _她打开电脑了。_
    ~ lisa_score = lisa_score + 0

- _她还在认真想这件事会不会真的发生。_
- _这是入职 12 周的人的想法。_
- _我入职第 6 周已经知道这种聚餐不会真的办。_

~ check_state_after_choice()
-> day_3_event_3_lao_zhou_lunch


// ----------------------------------------------------------------------------
// Event 3.3 · 中午看老周角落 · 12:30
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 闪 (~3 行)
// 同框: 老周 (背景)
// ----------------------------------------------------------------------------

= day_3_event_3_lao_zhou_lunch
# scene: corner_workstation_lao_zhou
# time: 12:30
# npc: lao_zhou_eating_noodles_at_desk
# prop: thermos_lunchbox_visible

12:30。你买了便当回工位吃。

经过老周工位——他在吃面。**自带的**，从一个保温饭盒里。今天是阳春面。

你以为他会去茶水间吃，但他在工位吃。

他面前的 Excel 还开着。他一边吃一边看。

_他在工位吃 12 年了。_

// 没有选项 - flavor only
// 老周 character 加深一笔

~ check_state_after_choice()
-> day_3_event_4_coffee_machine_callback


// ----------------------------------------------------------------------------
// Event 3.4 · 下午的咖啡机 · 14:00
// ----------------------------------------------------------------------------
// 触发: 第 4 个 AP
// 速度: 闪 (~4 行)
// 设计意图: Running gag 第 N 集 callback
// ----------------------------------------------------------------------------

= day_3_event_4_coffee_machine_callback
# scene: break_room
# time: 14:00
# prop: coffee_machine_with_doodle
# prop: sticky_note_dispatched_updated

茶水间。你想接水。

~ coffee_machine_broken_days = coffee_machine_broken_days + 1

咖啡机还故障——A4 纸"故障维修中"已经被人画了一个鬼脸。

旁边的便利贴"已派单"今天换成了新的便利贴："**已派单（更新）**"。下面手写一行小字："本周内修复"。

_3 周后再写"本周内"。_

_IT 小马是个艺术家。_

// 没有选项 - running gag
// coffee_machine_broken_days 仍在递增

~ check_state_after_choice()
-> day_3_after_work


// ----------------------------------------------------------------------------
// after_work · Day 3 下班 · 17:30
// ----------------------------------------------------------------------------

= day_3_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_compiling_dinner_table

Lisa 在工位。她下午改了一下午"团队聚餐建议表"——王总监散会前 forward 给她让她"汇总一下"。

_散会的时候没说她要做这个。但群里 5 分钟后王总监 @ 了她。_

* [申报加班 -10 状态 +2 AP 等价]
    Lisa 看你一眼："你也留？我请你喝奶茶——下楼那家 7-11。"
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1
    ~ lisa_score = lisa_score + 2

* [按时下班]
    Lisa："明天见。"
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 关电脑走人。
    Lisa 还在写聚餐表。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_3_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 3 周三日报
// ----------------------------------------------------------------------------
// 注意: per Q2.2 daily_recap 不列李阿姨 (她不在算分系统里)

= day_3_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi} (累积 {kpi}/200)_
_今日 钱: {money} (起始 5500)_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 晨会 fake-out: 王总监今天没讲 KPI, 讲聚餐_
_  - Lisa 把聚餐当真——她还相信_
_  - 老周在工位吃自带的面_
_  - 咖啡机 running gag (已派单 {coffee_machine_broken_days} 天)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_4_morning_briefing


// ============================================================================
// Day 4 · 周四
// ============================================================================
// 关键 beat (per §5 + designer note in episode-1.ink line 730):
//   - 笑天偷听王总监打电话提"林姐" (林姐 mention only, S1 不出场)
//   - 笑天写周报"系统性优化注意力分配"
//   - 茶水间咖啡机告示升级 (IT 小马 OKR 推进 - 笑穿层)
//   - 李阿姨倒水"小伙子，慢点" (李阿姨 A First Impression - designer reassigned 到 Day 4)
//   - Lisa 抽屉里的话梅 small confession

= day_4_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11

周四。

# scene: office_workstation
# time: 9:11
# npc: wang_door_open_on_phone

你 9:11 到公司，比昨天早了 14 分钟——纯属地铁等得短。

Lisa 不在工位，她去茶水间了。

王总监独立办公室门开着——他在里面打电话，声音不小。你听不清内容，听得出他在说"对，我了解，我下午去客户成功部跟林姐对一下"。

_林姐。_

_我入职 12 周，今天第一次听到这个名字。_

_应该是隔壁部门的人。_

// hidden flag: 笑天听到林姐名字 1 次 - S2-S3 还会反复听到
// S3 finale 路径 A 第一次见面时玩家有 prepared awareness

* [开始今日]
    -> day_4_event_1_li_ayi_first_impression


// ----------------------------------------------------------------------------
// Event 4.1 · 李阿姨"小伙子, 慢点" · 上午 9:30 (李阿姨 A First Impression)
// ----------------------------------------------------------------------------
// 触发: 第 1 个 AP
// 速度: 闪 (~3 行)
// 同框: 李阿姨 (前景)
// NPC archetype: 李阿姨 A First Impression (designer 把这个 beat 从 Day 2 重分到 Day 4)
// 注意: 李阿姨 score 不影响任何机制 - 她整人是叙事 (per npcs.md §5)
// ----------------------------------------------------------------------------

= day_4_event_1_li_ayi_first_impression
# scene: workstation_corner
# time: 9:30
# npc: li_ayi_pushing_mop_cart
# prop: granddaughter_photo_on_cart

9:30。李阿姨推着拖把车经过你工位。

你正在喝水。

她经过你工位时，没看你，但路过的时候说：

"**小伙子，慢点。**"

不带评价，纯陈述。

// 没有选项 - 李阿姨的口头禅 Archetype A 出场
// 她不是在跟你说话, 她在跟"工位上的年轻人"说话, 她已经说过 200 遍了

_她没看到我喝的是什么。或者她看到了。_

_上一个坐这位置的——她可能也对他说过"小伙子，慢点"。_

// li_score 概念存在但不影响机制 (per npcs.md §5) - 不修改

~ check_state_after_choice()
-> day_4_event_2_weekly_report


// ----------------------------------------------------------------------------
// Event 4.2 · 写周报 · 上午 10:30
// ----------------------------------------------------------------------------
// 触发: 第 2 个 AP
// 速度: 标准 (~7 行)
// 设计意图: 笑天的"系统性优化注意力分配" - 周报 PUA 体抄录
// ----------------------------------------------------------------------------

= day_4_event_2_weekly_report
# scene: workstation_facing_screen
# time: 10:30
# diegetic_prop: weekly_report_template_open

上午 10:30。你打开周报模板。

第一栏："**本周完成事项**"。

你想了一下你这周做了啥。

- 周一帮王总监改了一份 Q2 总结的 typo（5 个）
- 周二跟着 Lisa 看了一下她的 PPT（没改，只是看）
- 周三晨会出席（聚餐 setup 但你没参与汇总——那是 Lisa 的活）

你打字：

"完成多项基础性工作，配合团队推进 Q2 阶段性目标。**系统性优化注意力分配**，提升信息处理效率。"

* [提交]
    _你点了提交。10 分钟后王总监回了个"收到"。_
    ~ kpi = kpi + 1

* [改一改更具体一点]
    _你重写："本周参与 Q2 总结审核（typo 修复 5 处）+ PPT 预审（Lisa 项目）+ 晨会出席。"_
    _王总监 30 分钟后回："小笑啊，下次能再具体一点不？比如帮 Lisa 看 PPT 的'结论页'还是'数据页'？" 你看了 30 秒，回："好的。" 他没再回。_
    ~ kpi = kpi + 0
    // anti-pillar 1 教学瞬间 - 具体反而被 push

* [不提交，下班前再说]
    _下午你忘了。下班前 17:25 群里 @你"周报今天截止哈" 你赶紧贴了 A 版本。_
    ~ kpi = kpi + 0
    ~ state = state - 5

- _"系统性优化注意力分配"——翻译过来就是：摸鱼半天。_
- _"格子要打钩"——翻译过来就是：你写什么不重要，你交了就重要。_

~ check_state_after_choice()
-> day_4_event_3_coffee_machine_upgrade


// ----------------------------------------------------------------------------
// Event 4.3 · 茶水间咖啡机的"新通知" · 下午 14:00
// ----------------------------------------------------------------------------
// 触发: 第 4 个 AP
// 速度: 闪 (~3 行)
// 设计意图: Running gag 加深 + 笑天看穿 IT 小马 OKR 把戏
// ----------------------------------------------------------------------------

= day_4_event_3_coffee_machine_upgrade
# scene: break_room
# time: 14:00
# prop: coffee_machine_silent
# prop: sticky_note_parts_pending

下午茶水间。

咖啡机故障告示**没了**。

你心跳了一下。

你按了启动按钮。

机器响了一秒。

然后它又响了一秒，发出咯咯声。

然后停了。

旁边新贴了一张便利贴："**零件待到货**"。落款"IT 部"。

_他先撕了"故障"贴新的"待到货"——这样工单状态可以从"已派单"升级到"采购中"——他的 OKR 就有进度。_

_IT 小马懂 KPI 系统。比我懂。_

// 没有选项 - running gag 加深
// hidden flag: 你看穿 IT 小马的 KPI 把戏 1 次

~ check_state_after_choice()
-> day_4_event_4_lisa_snack


// ----------------------------------------------------------------------------
// Event 4.4 · Lisa 的小确幸 · 下午 16:30
// ----------------------------------------------------------------------------
// 触发: 第 6 个 AP
// 速度: 闪 (~4 行)
// 同框: Lisa (前景)
// ----------------------------------------------------------------------------

= day_4_event_4_lisa_snack
# scene: workstation_with_lisa
# time: 16:30
# npc: lisa_pulling_out_snack
# prop: lisa_drawer_with_more_snacks

16:30。Lisa 在自己工位。她突然小声"哎"了一下。

你回头。

她从抽屉里摸出一包小零食——**良品铺子的话梅**。她拆开吃了一颗。

她抬头看你，意识到你在看她。她笑了一下。

"中午没吃饱。"

_中午她吃了一个三明治 + 一杯奶茶。她说"没吃饱"是因为她不想让我觉得她在零食党。_

* [哈哈那是大事]
    Lisa 笑："哈哈，对啊。"
    _她又吃了一颗，递过来一颗给你。_
    ~ lisa_score = lisa_score + 2
    ~ state = state + 1

* [嗯]
    _Lisa 收回手，自己吃了。_
    ~ lisa_score = lisa_score + 0

* [不回应]
    _Lisa 把零食放回抽屉。_
    ~ lisa_score = lisa_score - 1

- _她在递的时候我看到她抽屉里还有 3 包没拆。_
- _她是有备而来的。_

~ check_state_after_choice()
-> day_4_after_work


// ----------------------------------------------------------------------------
// after_work · Day 4 下班 · 17:30
// ----------------------------------------------------------------------------

= day_4_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_packing_up_early

Lisa 今天 17:30 准点站起来——周一周二她都加班到 6:30。

_她周四就走是因为她周六约了人？还是她单纯今天累了？_

_我不知道。我没问。_

* [申报加班]
    你回到工位多干一会。
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
-> day_4_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 4 周四日报
// ----------------------------------------------------------------------------

= day_4_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi} (累积 {kpi}/200)_
_今日 钱: {money} (起始 5500)_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 你听到王总监打电话提"林姐"——隔壁部门的人, 第一次出现这个名字_
_  - 周报"系统性优化注意力分配"_
_  - 咖啡机从"故障"升级"零件待到货"——IT 小马 OKR 推进_
_  - Lisa 抽屉里的话梅_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_5_morning_briefing


// ============================================================================
// Day 5 · 周五 weekly_recap day
// ============================================================================
// 关键 beat (per §5):
//   - weekly_recap (轻量版 - 本周还没大事)
//   - Lisa 第二次主动 "要不要午饭一起?" (Lisa S1 第二次靠近)
//   - 王总监周五没出现 (笑天小确幸)

= day_5_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08

周五。

# scene: office_workstation
# time: 9:08
# npc: lisa_in_lighter_color_shirt
# prop: fruit_bowl_strawberry_apple_mix

你 9:08 到公司——你周五永远比周一早 5-10 分钟，因为你想准点 17:30 走，你下意识地早到一点 buffer。

Lisa 已经在了。**她今天换了一件浅色衬衫**——她平时穿的是深色。

_她周五换浅色。她可能晚上有约。_

_或者她单纯换季了。_

_我不会问。_

Vivian 前台水果盘**今天换成了草莓的一半**——一半草莓 + 一半苹果。

~ fruit_bowl = "mixed"

_妥协。融资可能"在谈"。_

_或者老板老婆只买了一盒草莓。_

* [开始今日]
    -> day_5_event_1_punch_in_precision


// ----------------------------------------------------------------------------
// Event 5.1 · 你的周五打卡精度 · 9:08
// ----------------------------------------------------------------------------
// 触发: morning_briefing 后自动
// 速度: 闪 (~2 行)
// 设计意图: 笑天的 ritual ironic awareness - 精确度服务于"装"
// ----------------------------------------------------------------------------

= day_5_event_1_punch_in_precision
# scene: punch_in_machine
# time: 9:08

你打卡的时候发现机器响了一声。

9:08:14。

_我周五的目标是 17:30:00。_

_我下班打卡时间会是 18:00:00 整——多刷 30 分钟避免被 HR 系统 flag 为"早退"。_

_我不需要早到，我需要"看起来准时"。_

// 没有选项 - 笑天独白

~ check_state_after_choice()
-> day_5_event_2_wang_absent


// ----------------------------------------------------------------------------
// Event 5.2 · 王总监没出现 · 上午 10:30 (笑天小确幸)
// ----------------------------------------------------------------------------
// 触发: 第 2 个 AP
// 速度: 闪 (~3 行)
// ----------------------------------------------------------------------------

= day_5_event_2_wang_absent
# scene: workstation_passing_wang_office
# time: 10:30
# npc: wang_office_door_closed

上午 10:30。王总监独立办公室门**关着**。

你经过的时候听不到打电话声音。

_他可能在外面开会。_

_或者他周五本来就晚到。_

_不管怎样，**他没 cue 我**。_

_不多。但算我赢一次。_

// 没有选项 - 笑天小确幸 +1
~ state = state + 1

~ check_state_after_choice()
-> day_5_event_3_lisa_lunch_invite


// ----------------------------------------------------------------------------
// Event 5.3 · Lisa 的午饭邀请 · 11:55 (Lisa S1 第二次靠近)
// ----------------------------------------------------------------------------
// 触发: 午餐时间
// 速度: 标准 (~7 行)
// 同框: Lisa (前景)
// 设计意图: Lisa 主动邀请 - 这是 Lisa A first impression 的延伸
// ----------------------------------------------------------------------------

= day_5_event_3_lisa_lunch_invite
# scene: workstation_lisa_turn_around
# time: 11:55
# npc: lisa_facing_you_directly

11:55。Lisa 转过头。

"笑天，要不要午饭一起？我想去楼下那家湖南菜，听说今天小炒黄牛肉特价。"

_她从来没主动邀请过我吃午饭。_

_周二的奶茶单是顺便。这次是她单独提议。_

* [一起]
    Lisa："好啊。"她拿起包就站起来。
    你和她下楼。电梯里她不说话，但你能感觉到她想说话又不知道怎么开。
    在湖南菜店等位的时候，她问你："你周末一般干嘛？"
    _她在 small talk。她的 small talk 不熟练。_
    你："睡觉。"
    Lisa："哈哈，我也是。"
    你们俩吃了 35 分钟，没说什么深的。她付了她那份的钱。
    ~ lisa_score = lisa_score + 5
    ~ money = money - 28
    ~ state = state + 5
    // 她这周第二次主动靠近你了——奶茶 + 午饭

* [今天有事]
    Lisa："好，下次哈."
    _她自己下楼了。她回来的时候手里没有奶茶——她可能没买。_
    ~ lisa_score = lisa_score - 2

* [我吃便当]
    Lisa："哦哦行。"
    _她自己下楼。_
    ~ lisa_score = lisa_score - 3

- _她这周两次主动找你, 可能不是因为她特别喜欢你, 是因为她在公司没朋友。_
- _但她还是选了你。_
- _也算一种。_

~ check_state_after_choice()
-> day_5_event_4_weekly_recap_overlay


// ----------------------------------------------------------------------------
// Event 5.4 · weekly_recap 浮层 · 下午 16:50
// ----------------------------------------------------------------------------
// 触发: 周五下班前自动
// 速度: 标准 (~6 行)
// 设计意图: S1 第一次"系统级"KPI 倒数提示 (为 E2 周三晨会王总监讲反向 KPI 真相做铺垫)
// ----------------------------------------------------------------------------

= day_5_event_4_weekly_recap_overlay
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出周报浮层——"本周三维考核已登记"。

浮层内容：

- 出勤率：100%（5 天 5 打卡）
- 主动产出条目：1 项（周报）
- 协作记录：0-2 项（取决于你的选择）

浮层底部有一行小字："**本月度 KPI 还有 7 天，请关注个人考核进度**"。

_本月度 KPI 还有 7 天。_

_这是浮层第一次提醒我。_

_周三晨会王总监没讲 KPI——但 HR 系统记得。_

// hidden flag: 周五系统提示 KPI 倒数 7 天
// E2 周一你 morning_briefing 会再次看到这条

~ check_state_after_choice()
-> day_5_after_work


// ----------------------------------------------------------------------------
// after_work · Day 5 下班 · 17:30
// ----------------------------------------------------------------------------

= day_5_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_packing_normally
# npc: david_writing_next_week_plan

你 17:30 收拾东西。

Lisa 也收东西。她今天准点走——你周五。

David 还在工位——他在写"下周工作计划"。

_周五下午 5 点写下周一计划。_

_他比我提前 3 天进入下周。_

_他活得比我快。_

* [同 Lisa 一起走出公司]
    Lisa 在公司大门外："下周一见。"
    _她笑了一下，转身去了地铁站反方向——她可能不回家。_
    ~ lisa_score = lisa_score + 2
    // 如果 5.3 选了 A, accumulate +7 整周

* [自己走]
    _你出门看了一下天，没下雨。_
    ~ state = state + 1

* [申报加班]
    你回到工位多干一会。
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

-

~ check_state_after_choice()
# pagebreak
-> day_5_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 5 周五日报
// ----------------------------------------------------------------------------

= day_5_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi} (累积 {kpi}/200)_
_今日 钱: {money} (起始 5500)_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 王总监周五没出现 (笑天小确幸)_
_  - Lisa 主动午饭邀请 (S1 第二次靠近)_
_  - HR 系统第一次提示 KPI 倒数 7 天_
_  - David 4 点已经在写"下周计划"_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_本周 Lisa score 累积: -3 to +12 (依玩家选择)_

# pagebreak
-> day_6_weekend_morning


// ============================================================================
// Day 6 · 周六 (周末)
// ============================================================================
// 关键 beat (per §5):
//   - 11 点起床
//   - David 朋友圈"周末加班的都是兄弟" 配自拍 + 工位
//   - Lisa 微信主动找你 (编了催 IT 工单的理由)
//   - 你下午什么都没做
// 周末时间槽 4 AP, state 自然恢复 +20 / 天

= day_6_weekend_morning
# scene: bedroom
# time: 11:14
# music: weekend_silence
# weather: clear

你睡到 11:14 醒来。

_11 点。_

_世界上有人在游艇上，我在补觉。_

_公平。_

你在床上躺了 20 分钟，刷手机。

# diegetic_ui: phone_wechat_moments

朋友圈：David 发了"周末加班的都是兄弟"配自拍 + 工位照（**他真的来公司了**——背景能看到 Lisa 工位的小玩偶，所以这是从他工位拍的）。

_他周六在公司加班。_

_他在卷他的下周计划。_

_我在床上。_

_我赢了一次，但他可能下个月薪水涨。_

_算了。_

11:34，你点外卖：粥 + 油条 + 一个茶叶蛋。32 块。
~ money = money - 32

_周末就该花钱。这是上班的意义。_

12:08，外卖到了。你吃了一半就饱了——半夜你才会饿。
~ state = state + 5

12:34，微信消息 1 条。

# diegetic_ui: phone_wechat_message
# npc: lisa_via_phone

是 Lisa：

"笑天，明天有空吗？你 9:30 那个 IT 工单还没解决，我帮你催过 IT 一次他们没理我。我加你微信备注成'同事-陈笑天'后，他们好像反应快一点哈哈。"

_她周六中午 12:34 给我发了这个。_

_她在帮我催工单。_

_她为什么要帮我？_

_她可能就是想找个理由跟我聊天。_

* [开始今日]
    -> day_6_event_1_lisa_wechat


// ----------------------------------------------------------------------------
// Event 6.1 · Lisa 的微信 · 12:34
// ----------------------------------------------------------------------------
// 触发: morning_briefing 后自动
// 速度: 标准 (~6 行)
// ----------------------------------------------------------------------------

= day_6_event_1_lisa_wechat
# scene: bedroom_phone
# time: 12:34
# diegetic_ui: phone_wechat_chat

* [哈哈谢了，工单不急]
    你回："哈哈谢了，工单不急。你周末干嘛？"
    Lisa 5 分钟后回："睡到 10 点。准备下午看电影一个人。"
    _一个人看电影。_
    你回："好的，享受。"
    Lisa："你呢？"
    你想了一下，回："睡到 11 点。"
    Lisa："哈哈哈下周见。"
    没了下文。
    ~ lisa_score = lisa_score + 5

* [嗯，谢了]
    你回："嗯，谢了。"
    Lisa 没再回。
    ~ lisa_score = lisa_score + 0

* [不回]
    你看了消息，没回。
    下午 3 点你又看了一下，她没追问。
    ~ lisa_score = lisa_score - 2

- _她可能没真的去看电影。_
- _但你也没真的睡到 11 点——你 11:14 醒的, 那 14 分钟你后悔过没设闹钟。_
- _你们俩都在跟对方装"周末很闲"。_
- _这是很多打工人和打工人的 small talk 的真实样子。_

~ check_state_after_choice()
-> day_6_event_2_afternoon_nothing


// ----------------------------------------------------------------------------
// Event 6.2 · 周六下午的"什么都不做" · 14:00
// ----------------------------------------------------------------------------
// 触发: 午饭后
// 速度: 闪 (~5 行)
// 设计意图: 周末"白噪音" - 故意让玩家感受周末的"什么都不发生"
// ----------------------------------------------------------------------------

= day_6_event_2_afternoon_nothing
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你在床上。

你打开了 B 站，看了 3 个视频，关了。

你打开了知乎，看了 1 个回答，关了。

你打开了某个购物 App，加了 1 件浅色衬衫到购物车，没付款。

_Lisa 周五穿浅色。我在被她影响。_

_或者我单纯是夏天到了。_

你又躺了 30 分钟。

_周末是用来什么都不做的。_

_这是上班 5 天给你的奖励。_

_不多。但算我赢一次。_

// 没有选项 - 周末"白噪音"
~ state = state + 30   // regenForRestDay 自动

~ check_state_after_choice()
# pagebreak
-> day_6_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 6 周六日报 (周末版本)
// ----------------------------------------------------------------------------

= day_6_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend

_今日 AP: N/A (周末)_
_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 11:14 起床_
_  - David 朋友圈发"周末加班"_
_  - Lisa 微信主动找你 (编了催 IT 工单的理由)_
_  - 你下午什么都没做_

# pagebreak
-> day_7_weekend_morning


// ============================================================================
// Day 7 · 周日 (周末 + 妈妈视频 + E1 cliffhanger to E2)
// ============================================================================

= day_7_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

你 8:23 醒了。

_8:30 妈妈要视频。_

_她每周日 8:30 都视频。_

_她每周六晚上 22:00 睡, 所以她周日 8:00 起, 吃完早饭就 8:30 找你。_

_她退休 3 年了。她的"上班"是给我打视频。_

8:30:00 整, 微信视频铃响。

# diegetic_ui: phone_video_call_incoming

你接了。

* [接通]
    -> day_7_event_1_mom_video


// ----------------------------------------------------------------------------
// Event 7.1 · 妈妈视频 · 8:30 (妈妈 A First Impression)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~12 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 A First Impression - 固定剧本 (per npcs.md §9)
// ----------------------------------------------------------------------------

= day_7_event_1_mom_video
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen
# prop: kitchen_yellowed_recipe

屏幕里是妈妈。

视频背景是老家厨房——油烟机 + 挂在墙上的菜谱（10 年前的，泛黄）。

妈妈戴着老花眼镜，眼镜距离屏幕很近。她头发花白，没染过。

她穿一件深蓝色毛衣——你记得这件毛衣，10 年了。

妈妈："**天天，吃了吗？**"

你："吃了。"

_我没吃。我刚醒。_

妈妈："**工资发了吗？**"

你："发了。"

_发了。但你不知道我每月偷偷给你打 1000 块。_

妈妈："**那个谁的儿子结婚了。**"

你："嗯。"

_那个谁。她说的可能是隔壁单元李阿姨家的。也可能是远房亲戚。我不知道哪个谁。但我知道她每周都告诉我一个新的"谁"。_

妈妈："**你呢？**"

你："**再等等。**"

* [接妈妈话题: 你这边天气怎么样妈]
    妈妈："冷一阵热一阵。前天下雨。"
    _她把镜头转向窗外的树。_
    ~ mom_score = mom_score + 2

* [转移话题: 妈我下午要出门了]
    妈妈："好好好不耽误你。"
    _她挂了。_
    ~ mom_score = mom_score - 1

* [不主动接话]
    _沉默 5 秒后妈妈："那你忙啊。" 她挂了。_
    ~ mom_score = mom_score - 2

- _挂掉视频后你坐在床上 20 秒。_
- _她每周都是同样的剧本。她每周都不变。_
- _我每周都在变。或者我没变。_
- _我不知道。_

// hidden flag: E1 妈妈视频 = 标准剧本
// 之后每集周日妈妈视频会有微调 (B/C/D archetype)

~ check_state_after_choice()
-> day_7_event_2_office_lonely


// ----------------------------------------------------------------------------
// Event 7.2 · 周日下午去公司浇绿萝 · 14:00 (E1 唯一轻扎)
// ----------------------------------------------------------------------------
// 触发: 周日下午自动
// 速度: 长 (~10 行)
// 同框: 无 NPC (周日下午办公室空)
// 设计意图: 9:1 那个"1" - 安静的悼念但没有人需要被悼念
// ----------------------------------------------------------------------------

= day_7_event_2_office_lonely
# scene: office_empty_sunday
# time: 14:00
# music: silence
# prop: green_plant_alive
# prop: lisa_workstation_with_charm_facing_window

下午 14:00。你出门。

你坐地铁到公司。

周日的公司大楼前台没人——Vivian 周日不上班。

你刷工牌进入。安静。

走到工位区——所有工位灯都关着。

_他们都没来。David 周六来过, 今天他可能在补觉。_

_王总监独立办公室也黑着。他周日肯定不来。_

_Lisa 也没来。她说她下午看电影。_

_就我一个。_

你走到自己工位。

桌上的小绿萝还活着——周一到周五你每天浇 3 滴水, 周六周日你不来浇, 但它没死。

你拿出口袋里的小水瓶——你专门为它从家里带的——浇了 5 滴。

_周末 5 滴, 工作日 3 滴。这是它的 KPI。_

_前任员工把它留在这就走了。_

你看了一眼空着的工位区。Lisa 工位的小玩偶还在桌上——她每天位置都不一样, 今天它面朝窗户。

_它是她的小绿萝。_

_我们都在养一些什么——养一些不会问"工资发了吗"的东西。_

你又给绿萝浇了 1 滴。

_它走了我还在。_

_我走了它可能也活不了。_

_但今天它活着。我活着。_

_不多。但算我赢一次。_

// 没有选项 - E1 唯一轻扎
// 笑天小确幸 +1 ("绿萝今天还活着" - 加入 E2-E4 内心独白库)
~ state = state + 2

~ check_state_after_choice()
-> day_7_e1_finale_cliffhanger


// ----------------------------------------------------------------------------
// Event 7.3 · 周日晚 Lisa 微信 · 21:30 (Cliffhanger to E2)
// ----------------------------------------------------------------------------
// 触发: 晚 21:30 自动
// 速度: 标准 (~5 行)
// ----------------------------------------------------------------------------

= day_7_e1_finale_cliffhanger
# scene: home_evening
# time: 21:30
# diegetic_ui: phone_wechat_notification
# npc: lisa_via_phone

21:30。你刚洗完澡。

微信消息 1 条。

Lisa：

"笑天, 明天周一晨会王总监会问 KPI 吧？"

* [应该会, 他每周三都问]
    Lisa："好的。我准备一下。"
    ~ lisa_score = lisa_score + 1

* [不一定, 这周三他没问]
    Lisa："对哦……那我也不太确定。"
    ~ lisa_score = lisa_score + 1

* [不知道]
    Lisa："嗯。"
    ~ lisa_score = lisa_score - 1

- _她周日晚 21:30 在准备"如果王总监问 KPI 我怎么回答"。_
- _她是一个"周日晚 9:30 还在备考"的人。_
- _我是一个"周日晚 9:30 在洗完澡刷手机"的人。_
- _我们俩活法完全不同。_
- _但我们都在这家公司。_

// hidden flag: E1 → E2 cliffhanger - Lisa 周日晚问王总监会问 KPI 吗
// E2 周三晨会王总监讲反向 KPI 真相会兑现这个铺垫

~ check_state_after_choice()
# pagebreak
-> day_7_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 7 周日日报 (E1 末)
// ----------------------------------------------------------------------------

= day_7_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend

_今日 AP: N/A (周末)_
_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 8:30 妈妈视频固定剧本 (妈妈 A First Impression 完成)_
_  - 下午独自去公司浇绿萝 (E1 唯一轻扎)_
_  - 21:30 Lisa 微信问"周一晨会王总监会问 KPI 吧？" (E1 → E2 cliffhanger)_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 12 周 + 1 = 第 13 周_

// E1 结束 - cliffhanger 留给玩家自己脑补
// E2 周一她见笑天就问"你周日回我消息了吗?" - per season-1-arc.md §5 E2 周一

-> END

// ============================================================================
// EOF episode-1.ink
// ============================================================================

// ============================================================================
// EOF episode-1.ink
// ============================================================================
//
// 分身 task summary:
//   1. Day 1 全部完整 (morning + 6 events + after_work + recap) - DONE by designer
//   2. Day 2 morning_briefing + Event 2.1 + 2.2 + 2.3 完整 - DONE by designer
//   3. Day 2 after_work + recap - 模板 stub, 分身按 Day 1 模板补
//   4. Day 3-7 全部 - 分身按 season-1-arc.md §5 E1 beat sheet 补
//
// 分身约束 (per episode-generation-brief.md):
//   - 不能引入 npcs.md 未注册的 NPC
//   - Lisa 在 S1 任意 episode 不能"剪短发" (那是 S2 E7 — W3 patch)
//   - Lisa 在 E1 不能"透露 HR 找她" (那是 E3 finale)
//   - 林姐 S1 不出场
//   - 主角内心独白不能"励志/突破/成长"
//   - 选项 ≤ 4 字
//   - 后果 1-2 行
//   - 笑天 voice 一致
//
// 数值平衡指引:
//   - E1 笑/泪比 = 9:1 (几乎全笑, 唯一轻扎是 day_7 浇绿萝)
//   - 每集 ~2400 行 .ink (Day 1-7 各约 300-400 行)
//   - 每个 event 末尾必须 ~ check_state_after_choice() + -> 下一 event
//   - VAR 修改集中在 event 选项里, 不要在叙述段落里改
//
// 跟 daily-choices.ink 的关系:
//   - 本文件是剧情 events
//   - daily-choices.ink (另一份) 是日常选择池子
//   - episode-1.ink Day 1 的 8 时间槽里, 6 个被剧情 event 占用 (event_1_vivian
//     to event_6_lisa_kerying), 剩 2 个槽 TS runtime 会从 daily-choices.ink
//     抽 daily choice (本文件不写)
//
// END
