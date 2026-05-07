// ============================================================================
// Daily Choices · 60 个日常选择池 (Reigns 式平衡)
// ============================================================================
//
// Status: 第 1 版 (designer 样例 — 3 个 stitch 示范, 剩余 57 个由分身 CC
//         session 按 daily-choices-handoff.md 补全 — 含从 daily-choices.md
//         的 15 个 gold standard 翻译 + 新写 45 个)
// Author: Game Designer (原 CC session)
// Last Updated: 2026-05-05
//
// 配套 reference:
//   - design/vertical-slice/daily-choices.md (3 属性框架 + 不可能三角 +
//     15 个 markdown gold standard - 翻译到本文件)
//   - design/vertical-slice/protagonist.md (笑天 voice)
//   - design/vertical-slice/tone-bible.md v2 (5 原则)
//   - design/vertical-slice/npcs.md v2 (10 NPC, NPC 互动类 stitch 必须 cross-ref)
//   - design/vertical-slice/series-structure.md (大决策 S3+ unlock)
//   - design/vertical-slice/episode-1.ink (剧情 event .ink 模板, 借鉴 syntax)
//   - design/vertical-slice/daily-choices-handoff.md (拆解任务说明)
//
// 引擎: 跟 episode-N.ink 同 ink runtime. TS runtime 在剧情 event 之间根据
//       context filter 从本文件 60 stitch 中抽 1-3 个调用. Stitch 完成后
//       -> DONE, runtime 决定下一步.
//
// Stitch 结构 (跟 episode-N.ink 不同 — 不需要 -> next_stitch 因为 runtime
// 决定下一步, 但每个 stitch 末尾仍然 ~ check_state_after_choice() 和 -> DONE):
//
//   === choice_某某某 ===
//   # category: commuting/lunch/work/small_joy/npc/big_decision/survival
//   # season_unlock: any/S3+/sick_triggered/promotion_candidate
//   # time_filter: morning/lunch/afternoon/evening/anytime
//   # weekend_only / weekday_only / both
//   # cooldown_episodes: N (本 stitch 上次触发后 N 集内不再抽)
//   # frequency_per_series: N (整 series 触发上限)
//
//   [场景描述 1-2 行]
//
//   * [选项 ≤ 4 字]
//       [后果 1-2 行]
//       ~ kpi = kpi + N
//       ~ money = money + N
//       ~ state = state + N
//       ~ check_state_after_choice()
//
//   * [选项 ≤ 4 字]
//       [...]
//
//   - _笑天内心独白 1-2 句_
//
//   -> DONE
//
// 注意: 共享 VAR 声明 (kpi/money/state/各 NPC scores/隐藏 flags) 复用
// episode-1.ink 顶部已声明的, 本文件不重复声明. 实际 build 时 inklecate
// 会从 includes 链接.
//
// ============================================================================
// INCLUDE shared state
// ============================================================================

INCLUDE episode-1.ink   // 复用 VAR 声明 + check_state_after_choice() function

// 备注: 实际项目应该把 VAR + helper functions 抽到 shared-state.ink, 然后
// episode-N.ink 和 daily-choices.ink 都 INCLUDE shared-state.ink. 这里
// 暂时直接 INCLUDE episode-1.ink 简化 demo.

// ============================================================================
// SAMPLE 1 · 工作内容类 · 凌晨 leader 微信
// ============================================================================

=== choice_01 === // (was: choice_凌晨leader微信)
# category: work
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 8

凌晨 2:14。

微信通知：王总监 → 你

"明早 9 点的会改成 8 点了，记得参加哈。"

* [已收到]
    你回了。睡不着了。
    ~ kpi = kpi - 3
    ~ state = state - 8
    ~ wang_score = wang_score + 0

* [假装睡着]
    你关静音继续躺。明早起来再说。
    ~ kpi = kpi + 0
    ~ state = state - 3
    ~ wang_score = wang_score - 1

* [已收到 + 闹钟提前]
    你定了 6:30 闹钟，再发"明早见"。
    ~ kpi = kpi + 3
    ~ state = state - 10
    ~ wang_score = wang_score + 1

- _发"已收到" 是表演 alive。不发就是反骨。_
- _他凌晨 2 点发消息也是表演 alive。我们都在演。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// SAMPLE 2 · NPC 互动类 · HR 接龙 (Zoe 互动)
// ============================================================================

=== choice_02 === // (was: choice_HR接龙)
# category: npc
# npc_focus: zoe
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 3
# frequency_per_series: 12

HR Zoe 在公司大群发：

「**各部门同事请接龙：1. [姓名][部门][本月已读公司文化建设资料] 2. ...**」

群里已经 27 人接龙。

* [1]
    你跟手发了。
    Zoe 在 HR 工位上看到你的接龙——0.5 秒切换标签页。
    ~ zoe_score = zoe_score + 1
    ~ state = state - 2

* [手动凑齐 28 字]
    你认真写了"陈笑天，产品部，本月已读《公司文化手册》第 3-5 章"。
    ~ zoe_score = zoe_score + 3
    ~ state = state - 5

* [装没看见]
    群里继续接龙。下午你被 Zoe 私聊"陈笑天先生，方便接龙吗"。
    ~ zoe_score = zoe_score - 3
    ~ state = state + 5
    ~ state = state - 3   // 被叫"陈笑天先生"扎一下

- _凑齐 28 字才不被 HR 私聊。_
- _我已经第 3 次了。_
- _Zoe 知道我不爱接龙。她也不爱发接龙。我们都在表演。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// SAMPLE 3 · 大决策类 (S3+) · 35 岁体检
// ============================================================================

=== choice_03 === // (was: choice_35岁体检)
# category: big_decision
# season_unlock: S3+
# time_filter: anytime
# both   // 周末和工作日都可触发
# cooldown_episodes: 52   // 一年触发 1 次
# frequency_per_series: 1

体检报告快递到工位。

你打开看了一眼。**轻度脂肪肝（已 3 年）。颈椎前倾。胆固醇偏高。**

后面还有 5 项异常。

* [立刻办健身卡]
    你下班就去 gym 办了卡。第 1 周去了 2 次。第 2 周开始没去。
    ~ money = money - 1980
    ~ state = state + 5
    ~ gym_card_held = true   // Round 2 patch: gate #25 健身房午休 stitch
    // S6 会触发 follow-up: "健身卡过期, 您去年共到馆 2 次"

* [继续点外卖]
    你把报告塞进抽屉。今天午饭还是麻辣烫。
    ~ money = money + 0
    ~ state = state - 3

* [删邮件 删快递条 删一切]
    你假装没收到。下季度公司体检你就找借口跳过。
    ~ money = money + 0
    ~ state = state - 8
    // hidden flag: 你跳过过 1 次体检
    // S10 follow-up: 体检升级"中度脂肪肝" + 警告

- _我 32 岁。脂肪肝已经第 3 年了。_
- _它会等我退休。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// 隐藏 flag 声明（分身 Round 2 翻译 markdown 时新增 — 跨 stitch effects）
// ============================================================================
// 注: 简单 narrative flag (单 stitch 内或纯 flavor) 仍用 // hidden flag 注释
// 风格 (per designer Sample 3 #14 体检). 下面这些是有跨 stitch / series-wide
// 机械影响的, 必须 VAR 声明便于 runtime tracking.

VAR has_moved = false                    // #52 搬家近公司 → 通勤选项重写
VAR gym_card_held = false                // #14 选 A 健身卡 → #25 健身房 stitch 激活
VAR resume_sent_count = 0                // #54 投简历累积 (≥3 + KPI 达标 → E52 Variant B)
VAR met_headhunter_count = 0             // #53 猎头累积接触 → S11 投简历类解锁
VAR took_payday_loan_count = 0           // #58 网贷累积 (≥3 → 月支出永久 -800)
VAR credit_card_revolving_count = 0      // #58 信用卡滚动累积 (≥3 → 同上 buff)
VAR anxiety_stack = 0                    // #57 焦虑硬扛累积 (≥5 → 想跳槽 flag 升级)
VAR fake_sick_note_count = 0             // #56 假病假证明累积
VAR zoe_knows_bad_state = false          // #59 主动汇报 → S 后期 GO 文案改"组织调整"
VAR went_japan_trip = false              // #55 年假成行 → E52 Variant B 温情版
VAR cancelled_japan_trip_count = 0       // #55 取消年假
VAR told_mom_truth_count = 0             // #51 跟妈说真话累积 (≥2 → mom_score +5 永久)

// 林姐 score VAR — 林姐 S1-S2 不出场, 但 daily choice #54 选 C 走 internal referral
// 已经会修改 lin_jie_score。S3+ 林姐出场后 score 真正影响 series。Round 2 patch 加。
VAR lin_jie_score = 0                    // #54 选 C 林姐 referral → +3


// ============================================================================
// 通勤类 (8 stitches: #01 翻译 + #15-#21 新)
// ============================================================================

// ----------------------------------------------------------------------------
// Choice 01 · 加班 9:30 后打车回家可以报销 · 通勤 (markdown #01 翻译)
// ----------------------------------------------------------------------------

=== choice_04 === // (was: choice_加班打车报销)
# category: commuting
# season_unlock: any
# time_filter: evening
# weekday_only
# cooldown_episodes: 2
# frequency_per_series: 8

21:30。加班还差 1 分钟才能报销打车费——公司规则是 21:30 之后才报。

你看了一眼时间。21:29:34。

* [9:31 打车]
    你多坐了 1 分 26 秒。打车回家，凭加班证明报销 30 块。
    ~ kpi = kpi + 5
    ~ money = money + 30
    ~ state = state - 3

* [9:29 打车]
    自费 30 块。早 90 秒下班。
    ~ money = money - 30
    ~ state = state - 5

* [蹭同事车]
    张哥说"顺路" 但其实绕了 5 公里。
    ~ state = state - 1
    // 张哥不在 npcs.md 注册, 不计 score (与 #18 cross-ref)

- _我为了 60 块加班 91 秒。这种数学题中年人都会做。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 15 · 早高峰 6 号线挤不上车 · 通勤
// ----------------------------------------------------------------------------

=== choice_05 === // (was: choice_早高峰挤地铁)
# category: commuting
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 8
{has_moved: -> DONE}   // 搬家后通勤池子重写, 本 stitch 不抽

8:42。6 号线呼家楼站。

第 3 班车你还没挤上去。下班时段广播在循环"请乘客后退"。

* [硬挤]
    你挤上去了。包带断了一根。
    ~ state = state - 8

* [等下班]
    你等到第 5 班，9:08 才上车。打卡迟到 8 分钟。
    ~ kpi = kpi - 3
    ~ state = state - 3

* [打车]
    你叫了滴滴。早高峰 1.5 倍。58 块。
    ~ money = money - 58
    ~ state = state + 2

- _我每月通勤花掉 200 个小时。_
- _算下来时薪比我工资高。_
- _但我在通勤上没工资。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 16 · 共享单车这片没电的全是你的 · 通勤
// ----------------------------------------------------------------------------

=== choice_06 === // (was: choice_共享单车没电)
# category: commuting
# season_unlock: any
# time_filter: evening
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 6
{has_moved: -> DONE}

望京东。

你点开哈啰、美团、青桔。3 个 app 同一片只剩"调度中"和电量 5%。

* [5% 电那辆]
    你骑了 200 米车自动断电。剩下 1.2 公里推车。
    ~ money = money - 2
    ~ state = state - 10

* [走]
    你走了 18 分钟到家。微信步数破 1 万。
    ~ state = state - 3

* [滴滴]
    1.2 公里 11 块起步价。
    ~ money = money - 11
    ~ state = state + 1

- _北京的共享单车在你需要的时候永远在调度中。_
- _在你不需要的时候堵满地铁口。_
- _算法优化的不是我。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 17 · 周一暴雨地铁停运 · 通勤
// ----------------------------------------------------------------------------

=== choice_07 === // (was: choice_暴雨打车)
# category: commuting
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 2

周一 8:15。

滴滴 app："当前订单较多，预计等待 47 分钟。1.8 倍动态加价。"

公司群 王总监："今天到岗的同事辛苦了哈，路上注意安全。"

* [加价打车]
    你点了。68 块到公司。9:23 打卡。
    ~ money = money - 68
    ~ state = state - 5

* [挤公交]
    你倒了 2 趟公交。10:11 到。打卡迟到 71 分钟。
    ~ kpi = kpi - 8
    ~ money = money - 4
    ~ state = state - 10

* [装病在家]
    你发"今天感冒了在家办公"。王总监回了一个"OK"。
    ~ kpi = kpi - 3
    ~ state = state + 5
    // hidden flag: 装病但没真病, 不计 sick_count

- _王总监说"路上注意安全"——他从地下车库直接到独立办公室。_
- _他没经过雨。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 18 · 蹭张哥车再绕 5 公里 · 通勤
// ----------------------------------------------------------------------------

=== choice_08 === // (was: choice_蹭张哥车)
# category: commuting
# season_unlock: any
# time_filter: evening
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 4
// 前置: 已与张哥蹭过 1 次 (#01 选 C 累积)

21:14。地下车库。

张哥："顺路啊，上来上来。"

你上次蹭他绕了 5 公里。他家在你家**反方向**。

* [上]
    你上了。这次他绕了 7 公里。路上他讲 40 分钟买基金套牢的事。
    ~ money = money + 30
    ~ state = state - 8

* [推]
    你说"今天约了人 谢谢张哥"。自己挤地铁。
    ~ money = money - 8
    ~ state = state - 3

- _他不是顺路。他是想找人听他讲基金。_
- _我是免费陪聊。但我省了 30 块。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 19 · 9:00:00 卡点打卡 · 通勤
// ----------------------------------------------------------------------------

=== choice_09 === // (was: choice_卡点打卡)
# category: commuting
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 1
# frequency_per_series: 24

你站在打卡机前。屏幕显示 8:59:43。

Vivian 在前台没抬头。她见过太多人卡这一秒。

* [等到 9:00:00]
    你掐着秒数刷脸。"打卡成功 09:00:00"。Vivian 这次抬了头，0.5 秒。
    ~ state = state + 2

* [8:59 提前]
    你 8:59:46 刷了。早 14 秒打卡——记录里是"准时"。
    // 0 attribute change

- _早 14 秒和晚 1 秒是两个世界。_
- _我选 0 秒。_
- _这是我每天唯一的精确控制。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 20 · 周三早到 30 分钟 · 通勤
// ----------------------------------------------------------------------------

=== choice_10 === // (was: choice_早到30分钟)
# category: commuting
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 5
# frequency_per_series: 6

8:31。你已经在工位。

部门只有老周。他在看 Excel，没抬头。

* [刷小红书]
    你刷了 26 分钟"裸辞攻略"。8:57 关掉。
    ~ kpi = kpi - 3
    ~ state = state + 5

* [提前开始]
    你打开周报。8:57 时已写了 2 行。
    ~ kpi = kpi + 5
    ~ state = state - 3

* [楼下买早饭]
    你下楼买了煎饼，回来正好 9:00。煎饼摊大姐多给了你 1 根油条。
    ~ money = money - 8
    ~ state = state + 5

- _早到 30 分钟没人会知道。_
- _但煎饼摊大姐知道。_
- _她比公司更早记住我的脸。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 21 · 周五 17:30 准点起身 · 通勤
// ----------------------------------------------------------------------------

=== choice_11 === // (was: choice_周五准点)
# category: commuting
# season_unlock: any
# time_filter: evening
# weekday_only
# cooldown_episodes: 1
# frequency_per_series: 12

周五 17:29:50。

你的双肩包已经在膝盖上。打卡机要 18:00 才能下班记录。

* [厕所蹲到 18:00]
    你 17:30 起身在隔间刷手机 28 分钟。下班记录 18:00:03。
    ~ state = state + 5

* [吃水果到 18:00]
    你 17:35 起身在茶水间慢慢吃了 2 个橘子。Vivian 在补盘。
    ~ money = money + 5
    ~ state = state + 3

* [假装继续工作]
    你打了 30 分钟"已收到"和"OK"。王总监没看见。
    ~ state = state - 3

- _17:30 的电梯门关上那一秒——_
- _不多。但算我赢一次。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// 午餐 / 午休类 (10 stitches: 全新 #22-#31)
// ============================================================================

// ----------------------------------------------------------------------------
// Choice 22 · 公司食堂今天又是糖醋里脊 · 午餐
// ----------------------------------------------------------------------------

=== choice_12 === // (was: choice_食堂糖醋里脊)
# category: lunch
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 1
# frequency_per_series: 24

11:42。食堂二楼。

今天的"特色菜"还是糖醋里脊。本周第 3 次。

* [排]
    你打了。22 块。里脊全是面糊。
    ~ money = money - 22
    ~ state = state - 3

* [楼下美团]
    你下楼点了麻辣烫。43 块。20 分钟才到。
    ~ money = money - 43
    ~ state = state + 5

* [不吃]
    你回工位泡了一包老坛酸菜。
    ~ money = money - 5
    ~ state = state - 8

- _食堂阿姨抖三下勺子是行业标准。_
- _我的米饭也只有半碗。_
- _我们都在执行流程。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 23 · 跟 Lisa 拼奶茶第 12 次 · 午餐 (NPC 互动 sub-tag)
// ----------------------------------------------------------------------------
// 注: scene 末尾保留 verbatim "她从不主动说拼下一次。但每次她都问。"
// 内心独白保留 verbatim "拼到第 12 次, 奶茶不再是奶茶."

=== choice_13 === // (was: choice_拼奶茶第12次)
# category: lunch
# npc_focus: lisa
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 1
# frequency_per_series: 24
// 前置: lisa_score >= 5

Lisa 凑过来："拼一杯吗？第二杯半价。"

你和她已经拼过 11 次。

她从不主动说拼下一次。但每次她都问。

* [拼]
    喜茶第二杯半价。两人 38 块。
    # speaker: lisa
    Lisa："今天我请。"——你知道下次会轮到你。
    ~ money = money - 19
    ~ state = state + 5
    ~ lisa_score = lisa_score + 3

* [我减肥呢]
    她说"哦"，自己点了。她的杯子比平时小一号。
    ~ lisa_score = lisa_score - 2

- _拼到第 12 次，奶茶不再是奶茶。_
- _是一个 unspoken contract——她孤独，我也是。_
- _我们都没说出来。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 24 · 楼下沙县 13 块拌面 vs 24 块外卖 · 午餐
// ----------------------------------------------------------------------------
// 注: 内心独白保留 verbatim "沙县老板记得我的脸. 我们公司王总监 8 个月..."
// 这是 round-1-reply §1 highlights 的 series-finale 级别 quote.

=== choice_14 === // (was: choice_沙县拌面)
# category: lunch
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 1
# frequency_per_series: 24

12:05。

美团红包 5 元。麻辣烫 24 - 5 = 19 块。

楼下沙县拌面 13 块，到手 4 分钟。

* [沙县]
    你下楼。沙县老板看你点头："老样子？"
    ~ money = money - 13
    ~ state = state + 3

* [美团]
    你下了单。35 分钟才到。回来午休只剩 10 分钟。
    ~ money = money - 19
    ~ state = state - 3

* [趴桌子]
    你 12:05 趴下，13:00 醒来嘴角有口水。
    ~ state = state + 8

- _沙县老板记得我的脸。_
- _我们公司王总监 8 个月还叫不准我名字。_
- _沙县是我的归属感。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 25 · 健身房 30 分钟 vs 趴桌子 · 午休
// ----------------------------------------------------------------------------

=== choice_15 === // (was: choice_健身房午休)
# category: lunch
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 2
# frequency_per_series: 12
{not gym_card_held: -> DONE}   // 没办卡, 本 stitch 不抽

你的健身卡 1980 块办的。

已经 11 天没去。

* [去]
    你去走了 30 分钟跑步机。下午 KPI 没顶起来。
    ~ kpi = kpi - 5
    ~ state = state + 10

* [趴桌子]
    你睡了 50 分钟。脖子酸，键盘上印了 1 道印子。
    ~ state = state + 5

* [假休息]
    你刷了 50 分钟小红书。手腕酸。
    ~ kpi = kpi - 3

- _办卡时我以为我会去 100 次。_
- _去过 6 次。_
- _剩下 94 次的钱我已经认了。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 26 · 茶水间偷喝 David 的星巴克 · 午餐 (NPC 互动 sub-tag)
// ----------------------------------------------------------------------------
// 注: 内心独白保留 verbatim "一年下来我在茶水间偷过 3 包速溶 + 1 包茶包
// + 1 杯星巴克. 不多. 但都是 David 的. 算我赢两次."

=== choice_16 === // (was: choice_偷喝David星巴克)
# category: lunch
# npc_focus: david
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 3
// 前置: David 在场 (S1-S6) + David 在群里发"@所有人 加班餐"

茶水间。

David 中午外送的星巴克拿铁。他放冰箱忘了。

杯子上写着 "David / 减糖"。

* [偷喝一口]
    你喝了一大口。回工位。下午 David 群里发"我那杯咖啡有人动过吗"——没人回。
    ~ money = money + 35
    ~ state = state + 5
    // david_score 不变 (他不知道是你)

* [不喝]
    你回工位。下午 David 自己喝。"嗯今天的减糖怎么有点甜。"
    // 0 change

- _一年下来我在茶水间偷过 3 包速溶 + 1 包茶包 + 1 杯星巴克。_
- _不多。但都是 David 的。_
- _算我赢两次。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 27 · 11:50 提前下楼排队 · 午餐
// ----------------------------------------------------------------------------

=== choice_17 === // (was: choice_提前下楼排队)
# category: lunch
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 8

11:50。

食堂还没开门。门口已经排了 8 个人。第 1 个是 David。

* [排]
    你站到第 9 位。11:55 你听见 David 跟前面同事讲"我每天都这个点"。
    ~ kpi = kpi - 3
    ~ state = state - 3

* [12:30 再下来]
    你 12:30 下来，没排队。糖醋里脊只剩 2 块面糊。
    ~ state = state - 5

- _David 来这里是为了少排 5 分钟。_
- _他没意识到他多上了 5 分钟班。_
- _我意识到了。但我也没回报酬。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 28 · 跟前同事约饭"最近怎样" · 午餐 (typo 修正 per Round 1 reply §2.2)
// ----------------------------------------------------------------------------
// 修: 选 A 后果"你请他付的那 200 块停车费是真的" → "但我付的那 200 块停车费是真的"

=== choice_18 === // (was: choice_前同事约饭)
# category: lunch
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 16
# frequency_per_series: 3
// 前置: 前同事老李微信主动约 (series 内 ~3 次)

微信通知：前同事老李 → 你

"笑天，明天中午有空吗？我新换了工作，请你吃个饭。"

老李上次跳槽月薪 +60%。

* [去]
    你去了。老李一直在讲他新公司多好。你点头。回来你刷了 6 次招聘 app。
    ~ state = state - 8
    // hidden flag: 你想过跳槽 (轻量, 不增 met_headhunter_count)

* [推]
    你回"最近忙下次哈"。老李没再问。1 个月后你看到他朋友圈又跳了。
    ~ state = state + 2

- _跟跳槽的同学吃饭——他在炫耀，我在装我也好。_
- _我们都在演。_
- _但我付的那 200 块停车费是真的。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 29 · 食堂阿姨多打了一勺 · 午餐
// ----------------------------------------------------------------------------
// 注: 食堂阿姨不在 npcs.md 注册 (per round-1-reply Q8.5.1 KEEP background),
// 不计 npc_focus tag, 也不增 NPC score var.

=== choice_19 === // (was: choice_食堂阿姨多打半勺)
# category: lunch
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 5
# frequency_per_series: 6
// 前置: 已遇到食堂阿姨 ≥ 5 次 (玩家累积值由 runtime 自动统计)

食堂阿姨打了你这份西红柿炒蛋。

她**多舀了半勺**。

后面 David 排着，他看见了。

* [道谢]
    你说"谢谢阿姨"。阿姨笑了一下没说话。
    David 后面的那勺正好少了 1/3。
    ~ money = money + 2
    ~ state = state + 5

* [不动声色]
    你低头走人。David 在你身后跟阿姨："我也要西红柿炒蛋。"阿姨抖了抖勺子。
    ~ money = money + 2
    ~ state = state + 3

- _阿姨多打半勺——这是公司里唯一不写 KPI 的偏爱。_
- _她不知道我叫什么名字。_
- _她只记得我每周三都来。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 30 · "营养餐"窗口 28 元 · 午餐 (HR 健康月)
// ----------------------------------------------------------------------------

=== choice_20 === // (was: choice_营养餐窗口)
# category: lunch
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 12

HR Zoe 群里发："本月健康饮食月，营养餐窗口减 5 元。"

28 块的水煮鸡胸 + 西兰花 + 糙米饭。

* [吃]
    你打了。鸡胸柴。西兰花是冷的。糙米饭夹生。
    ~ money = money - 28
    ~ state = state + 3
    // hidden flag: 你配合了 1 次健康月 (zoe KPI 加 1 个百分点)

* [还吃糖醋里脊]
    你吃了 22 块的老款。盐重油重。
    ~ money = money - 22
    ~ state = state - 3

- _Zoe 推这个不是为了我健康。_
- _是为了她 KPI 里"员工健康参与率"那个百分点。_
- _我吃了。她百分点 +1。我吃了一坨。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 31 · 中午 12 点王总监还在工位"陪同事吃" · 午餐 (NPC 互动 sub-tag)
// ----------------------------------------------------------------------------

=== choice_21 === // (was: choice_王总监陪吃午饭)
# category: lunch
# npc_focus: wang
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 12
# frequency_per_series: 4
// 前置: S7+ 王总监本季首次被高层 push (per series-structure)

12:10。工位区还有 4 个人没走。

王总监在自己独立办公室——但门**今天开着**。

他正在啃一个三明治。"小笑啊，过来吃啊。"

* [去]
    你拿着饭进去。王总监讲了 25 分钟他当年初入职场的故事。
    ~ kpi = kpi + 5
    ~ state = state - 10

* [我已下楼]
    你举了举手机"美团已经在路上了"。
    ~ state = state + 3

- _他叫我吃饭——这是 PUA 升级版："关心你"。_
- _45 岁的他第一次主动叫人吃饭——上面在 push 他了。_
- _我们都在被同一台机器搅。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// 工作内容类 (11 stitches: #03/#04/#05 翻译 + #32-#38, #44 新; #02 是 sample 1)
// ============================================================================

// ----------------------------------------------------------------------------
// Choice 03 · 周报怎么写"摸鱼半天" · 工作内容 (markdown #03 翻译)
// ----------------------------------------------------------------------------

=== choice_22 === // (was: choice_周报水分)
# category: work
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 1
# frequency_per_series: 12

周五下午 4:30。

周报模板打开。你这周有半天在刷小红书"裸辞攻略"。

你想了想"完成内容"那一栏怎么填。

* [系统性优化]
    你写了一段 PUA 风格的官话。王总监不会读，但会记打勾。
    ~ kpi = kpi + 5
    ~ state = state + 3

* [bullshit bingo]
    你写了 2 行 bullshit bingo。中规中矩。
    ~ kpi = kpi + 3
    ~ state = state + 1

* [老实"在调研"]
    你写"本周以行业调研为主，下周开始执行"。王总监会私聊你"调研得怎样？"
    ~ kpi = kpi - 3
    ~ state = state - 2

- _翻译过来都是"啥也没做"。但 KPI 表上要打勾。_
- _我想我妈这辈子不会理解什么叫"系统性优化注意力分配"。她以为我在做大事。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 04 · 老板拍拍肩膀"小笑啊…陈天啊…加油啊" · 工作内容 (markdown #04 翻译)
// ----------------------------------------------------------------------------

=== choice_23 === // (was: choice_老板拍肩膀)
# category: work
# npc_focus: wang
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 2
# frequency_per_series: 16

王总监从你工位旁路过。手放在你肩膀上停了 0.5 秒。

"小笑啊。陈天啊。差不多差不多。加油啊。"

* [认真表态]
    你说"明白王总，本周末前出方案"。王总监："好好好。"
    ~ kpi = kpi + 5
    ~ state = state - 5

* [嗯嗯好的]
    你点头。王总监走了。
    // 0 change

* [继续盯屏幕]
    王总监停了一下，"嗯。" 走了。
    ~ kpi = kpi - 3
    ~ state = state + 3
    ~ wang_score = wang_score - 1

- _他记不住名字但他以为他记住了。_
- _我配合他记错。这是 unspoken contract。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 05 · 微信群 leader 发"大家有什么想法畅所欲言" · 工作内容 (markdown #05)
// ----------------------------------------------------------------------------

=== choice_24 === // (was: choice_群里畅所欲言)
# category: work
# npc_focus: wang
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 8

部门微信群叮一声。

# speaker: wang_director
王总监：「**大家这个 Q 的方向有什么想法畅所欲言哈，我们一起探讨。**」

群里安静 30 秒。

* [发长段子]
    你打了 200 字，结构化思考 + 3 个 bullet。王总监："好，小笑这个想法不错。"
    ~ kpi = kpi + 5
    ~ state = state - 8

* [发👍]
    群里跟风：3 人发了👍。
    // 0 change

* [装看不见]
    群里还是沉默。10 分钟后 David 发了 200 字。
    ~ kpi = kpi - 3
    ~ state = state + 3

- _畅所欲言是 trap。聪明人都发👍。_
- _今天 David 接了。他卷王身份保住了。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 32 · 跨部门微信群 18 人在 ping 你 · 工作内容
// ----------------------------------------------------------------------------

=== choice_25 === // (was: choice_跨部门18人ping)
# category: work
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 6

跨部门项目群"Q3 数字化升级"。

客户成功部 / 财务 / 法务 / 运营 / 你们部门——18 人。

上午 10:15 你打开微信。**未读 + 47 条 + @你 6 次**。

* [一条条回到 0]
    你回了 47 分钟。其中 30 条是别人之间的 cross-talk。
    ~ kpi = kpi + 5
    ~ state = state - 12

* [只看 @你]
    你回了 12 分钟。漏了 1 条客户成功部主管 cue 你的合规意见。
    下午她私聊你"陈先生，那条有看到吗"。
    ~ kpi = kpi - 3
    ~ state = state - 3

* [全部已读]
    你点了一键已读。下午王总监微信"小笑那个项目你 follow 一下"。
    ~ kpi = kpi - 8
    ~ state = state + 5

- _跨部门群是中年人的修罗场。_
- _不回 = 失职。_
- _全回 = 没时间干活。_
- _这是设计好的。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 33 · 改 PPT 第 7 版 王总监说"再过一遍" · 工作内容
// ----------------------------------------------------------------------------

=== choice_26 === // (was: choice_PPT第7版)
# category: work
# npc_focus: wang
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 6
// 前置: 已交 PPT v6

王总监微信："这版还行，但**再过一遍**——颗粒度细一点。"

你打开 PPT。第 7 版。

第 1 版到第 7 版的差别：字号 16→18→16→17→18→16→18。

* [真改]
    你认真重看 32 页。改了 4 个错别字 + 1 个图表对齐。第 8 版。
    ~ kpi = kpi + 5
    ~ state = state - 10

* [改 3 处]
    你只改了 3 个明显的。改完保存为 v7_final_final。王总监："好多了。"
    ~ kpi = kpi + 3
    ~ state = state - 3

* [重命名 v8]
    你 0 改动 但文件名加 v8。王总监："这版颗粒度对了。"
    ~ kpi = kpi + 5
    ~ state = state + 3
    // hidden flag: 你成功欺骗 1 次王总监 review

- _他没看 v7 和 v8 的区别。_
- _他看的是文件名后缀。_
- _我抓住了这个 bug。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 34 · 邮件群发"抄送王总监" · 工作内容
// ----------------------------------------------------------------------------

=== choice_27 === // (was: choice_cc王总监邮件)
# category: work
# npc_focus: wang
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 8

你写完邮件草稿。

收件人：客户成功部林姐（如已认识 S3+）/ 法务 / 你们部门 3 人。

抄送框：空。

* [cc 王总监]
    你打了"王总监"3 个字。outlook 自动补全。其他部门 30 分钟内全回了。
    ~ kpi = kpi + 5
    ~ state = state - 3

* [不 cc]
    你直接发。其他部门 4 小时后才回。
    ~ kpi = kpi - 3
    ~ state = state + 3

* [cc + 敬请知悉]
    你写了"敬请王总指示" 在最后。王总监没回邮件 但下午路过你工位说"小笑啊那邮件我看到了"。
    ~ kpi = kpi + 8
    ~ state = state - 5

- _抄送王总监 = 公司核武器。_
- _按下去对方 30 分钟内必回。_
- _但下次他们也会抄送你领导。_
- _我们都在升级核武。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 35 · 凌晨 1 点客户群里"@所有人 紧急" · 工作内容
// ----------------------------------------------------------------------------

=== choice_28 === // (was: choice_凌晨客户群紧急)
# category: work
# season_unlock: any
# time_filter: evening
# weekday_only
# cooldown_episodes: 24
# frequency_per_series: 2

凌晨 1:08。

客户群叮一声。客户方运营："@所有人 紧急——后台数据有问题，明早 9 点就要发周报，能不能现在帮我们查一下？"

群里安静 12 分钟。

* [起来查]
    你爬起来开电脑。1:30 你定位到问题——是客户那边自己改了字段。
    回了"是 X 字段被改"。客户："谢谢笑天哥！"凌晨 2:14 你睡。
    ~ kpi = kpi + 5
    ~ state = state - 15
    // hidden flag: 客户记住你 (跨公司笑天 voice 同款)

* [装睡]
    你设静音。早晨 8:30 你回"刚醒，看到了"。客户已经自己解决。
    ~ kpi = kpi - 3
    ~ state = state - 3

* [9 小时后回]
    你 8:30 起来回"昨晚没看到群消息"。
    客户："哦。"——他们 4:20 已经联系另一个供应商。
    ~ kpi = kpi - 5
    ~ state = state + 3
    // hidden flag: 客户记住你装睡

- _客户凌晨 1 点 @所有人——他们老板也在 push 他们。_
- _我们都在被同一台机器搅，跨公司的。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 36 · deliverable 验收 leader 突然问"你这指标定义" · 工作内容
// ----------------------------------------------------------------------------

=== choice_29 === // (was: choice_指标定义被问)
# category: work
# npc_focus: wang
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 4

项目结项会议。第 18 分钟。

# speaker: wang_director
王总监："小笑这个'用户活跃度'你是怎么定义的？"

你 PPT 上写的是"DAU/MAU"。其实你**没算过这个数据**。

* [现场编]
    你说"是 30 天滚动平均，剔除流失用户后的核心样本"。
    # speaker: wang_director
    王总监："嗯。"David 后排在记笔记。
    ~ kpi = kpi + 5
    ~ state = state - 10
    // hidden flag: 你成功蒙混 1 次

* [我再核对]
    你说"这个我会后再确认下发您"。王总监："好。"会议室安静了 2 秒。
    ~ kpi = kpi - 3
    ~ state = state - 5

* [按公司口径]
    你说"按之前部门口径"。王总监："哪个口径？我们没统一过。"
    会议结束他给你私信"小笑下次先对齐定义。"
    ~ kpi = kpi - 8
    ~ state = state - 3
    ~ wang_score = wang_score - 1

- _我编的那 30 天滚动平均——_
- _听起来比真定义更专业。_
- _等会议结束我得回去补一下数据，让说法对得上。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 37 · 评审会 David "我有一个建议" · 工作内容 (NPC 互动 sub-tag)
// ----------------------------------------------------------------------------

=== choice_30 === // (was: choice_评审会David建议)
# category: work
# npc_focus: david
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 6
// 前置: David 在场 (S1-S6)

评审会进行到第 40 分钟。你的方案讲完。

David 举手："我有一个建议哈——"

他**昨晚 23:00** 才看你方案。

* [让他讲完]
    他讲了 12 分钟。其中 8 分钟是你方案里已经有的内容。王总监："不错，结合一下。"
    ~ state = state - 8

* [现场反驳]
    你翻 P12 给大家看。David 笑了一下："哦哦那我跟你 align 一下。"
    会议室空气凝固。
    ~ kpi = kpi + 5
    ~ state = state - 5
    ~ david_score = david_score - 3

* [假装记笔记]
    你低头写"David 建议：……"。会后你删了笔记。
    ~ kpi = kpi - 3

- _David 提的"建议"是我方案 P12 第 3 个 bullet。_
- _他记得他读过——但他记成是他想的。_
- _他不是恶意。他真信。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 38 · 客户突然 cue 你"那这块咱们这周能落地吗" · 工作内容
// ----------------------------------------------------------------------------

=== choice_31 === // (was: choice_客户突然cue排期)
# category: work
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 6

客户视频会议。第 32 分钟。

客户方："那这块功能咱们这周五能上线吗？"

你方案里写的是"4 周交付"。今天周二。

* [接 yes-man]
    你说"可以咱们尽量"。挂电话你去找 IT 小马。他："已派单。"
    ~ kpi = kpi + 5
    ~ state = state - 15

* [委婉 align]
    你说"咱们会后我跟产品同步"。客户："好。"
    ~ state = state - 3

* [直接拒]
    你说"按原 SOW 我们 4 周交付，提前需要变更签字"。
    客户老板皱眉。王总监微信："你这语气..."
    ~ kpi = kpi - 5
    ~ state = state + 3
    ~ wang_score = wang_score - 1

- _"咱们尽量"= 100% 加班的承诺。_
- _但承诺时听起来温柔。_
- _我们都学过这句。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 44 · 周一晨会王总监 cue "你怎么看" · 工作内容
// ----------------------------------------------------------------------------

=== choice_32 === // (was: choice_晨会cue怎么看)
# category: work
# npc_focus: wang
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 8

周一晨会。第 22 分钟。

王总监讲完反向 KPI 一段后，眼神扫到你："小笑你怎么看？"

全部门 6 人都看你。David 已经准备好接你的话。

* [接 yes-man]
    你说"您说得对，我们部门的 KPI 是要跟战略对齐的"。
    # speaker: wang_director
    王总监："好，小笑这个想法不错。"David 低头记。
    ~ kpi = kpi + 5
    ~ state = state - 8

* [沉默]
    你看了一眼 PPT。安静 2 秒。王总监："那就这样。下个 topic。"
    ~ kpi = kpi - 3
    ~ state = state - 3
    ~ wang_score = wang_score - 1
    // hidden flag: 王总监 S2+ 出场频率 -1

* [真回答]
    你说"我觉得 deliverable 这周可以交"。
    # speaker: wang_director
    王总监："好——这周到。"David 第一时间举手"我帮笑天 align 一下"。
    ~ kpi = kpi + 5
    ~ state = state - 10
    // hidden flag: 王总监开始记你 deliverable

- _他不是问我"怎么看"。_
- _他是问"你愿不愿意接这个球"。_
- _我学过这个翻译。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// 小动作 / 小确幸类 (10 stitches: #06-#10 翻译 + #39-#43 新)
// ============================================================================

// ----------------------------------------------------------------------------
// Choice 06 · 公司奶茶免费日 茶水间排队 30 人 · 小确幸 (markdown #06 翻译)
// ----------------------------------------------------------------------------

=== choice_33 === // (was: choice_奶茶免费日)
# category: small_joy
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 12

公司福利日通知：「今日下午 3 点起茶水间提供免费奶茶」。

3:05，茶水间排队已经 30 人。

18 块一杯的喜茶。免费。

* [排]
    30 分钟后你拿到一杯。等的时候你看了 5 篇小红书。
    ~ kpi = kpi - 5
    ~ money = money + 18
    ~ state = state - 10

* [溜了]
    你回工位。3:30 你看到群里有人发"喜茶超好喝今天" + 自拍。
    ~ state = state + 5

- _免费奶茶相当于公司给我加薪 18 块。但我要花 30 分钟。_
- _中年人的小算计：18 块 ÷ 30 分钟 = 36 块 / 小时。我的工资是 70 块 / 小时。我亏了。_
- _但奶茶是奶茶。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 07 · 朋友圈晒"加班餐"求慰问 · 小确幸 (markdown #07 翻译)
// ----------------------------------------------------------------------------

=== choice_34 === // (was: choice_朋友圈加班餐)
# category: small_joy
# npc_focus: mom
# season_unlock: any
# time_filter: evening
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 8
// 前置: after_work 选了"申报加班" 且时间过 20:00

20:30。茶水间剩的方便面 + 3 块饼干 = 你的晚餐。

你掏出手机想拍个九宫格。

* [配九宫格]
    你发了。配文"打工人的夜"。15 分钟后你妈点赞。
    ~ state = state + 5
    ~ mom_score = mom_score + 2

* [屏蔽爸妈]
    你设了"不给爸妈看"。前同事点赞 8 个，配文"我也是"。
    ~ state = state + 3

* [不发]
    你吃方便面。汤喝完了。
    // 0 change

- _我妈点赞 = 她以为我吃好了。_
- _我没吃好。_
- _但她以为了。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 08 · 钉钉 999+ 红点焦虑 · 小动作 (markdown #08 翻译)
// ----------------------------------------------------------------------------

=== choice_35 === // (was: choice_钉钉999红点)
# category: small_joy
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 3
# frequency_per_series: 12

钉钉打开。未读消息 999+。

红点在屏幕上闪。

* [全部已读]
    一键全部已读。红点消失。心理负担消失 0.3 秒后回来。
    ~ state = state + 3

* [一条条回]
    你回了 1 小时 42 条消息。其中 38 条是表情包。
    ~ kpi = kpi + 5
    ~ state = state - 10

* [关静音]
    你设了"工作日免打扰"。下午王总监微信你"消息看到了吗"。
    ~ kpi = kpi - 3
    ~ state = state + 5

- _全部已读不回是中年人的特权。_
- _年轻人挨个回到 0 是自我证明。_
- _我已经 32 了。我不证明。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 09 · 公司福利水果今天是草莓 · 小确幸 (markdown #09 翻译)
// ----------------------------------------------------------------------------

=== choice_36 === // (was: choice_福利水果草莓)
# category: small_joy
# npc_focus: vivian
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 6
// 前置: fruit_bowl == "strawberry" (融资到位)

你打卡过门禁，前台 Vivian 已经在补水果盘。

"嗨～今天草莓哦～融资群里说 D 轮过会了。"

* [抢 2 个]
    你拿了 2 个。Vivian 看了你一眼，没说什么。
    ~ money = money + 5
    ~ state = state + 5
    ~ vivian_score = vivian_score - 1

* [拿 1 个]
    你礼貌拿 1 个，谢谢 Vivian。
    ~ money = money + 2
    ~ state = state + 3
    ~ vivian_score = vivian_score + 1

* [不去抢]
    你直接进了工位。15 分钟后水果盘空了。
    // 0 change

- _草莓周 = 融资到位 = 公司还能撑。_
- _我抢一个不算贪。_
- _抢两个就有点了。但 Vivian 不会说。她也想跑。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 10 · 打工人小确幸 周五下午茶 · 小确幸 (markdown #10 翻译)
// ----------------------------------------------------------------------------

=== choice_37 === // (was: choice_周五下午茶)
# category: small_joy
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 1
# frequency_per_series: 12

周五下午 3:30。

楼下喜茶第二杯半价。两杯 57 块。

* [点]
    你点了。Lisa 凑过来"也来一杯吗"，你说好。两人 38 块。
    ~ money = money - 38
    ~ state = state + 8
    ~ lisa_score = lisa_score + 3

* [自己泡]
    你回茶水间泡了一包茉莉。咖啡机还是坏的。
    ~ state = state + 1

- _我下班还要挤地铁 1 小时 10 分钟。这杯茶值。_
- _中年人最贵的不是奶茶，是"我值得"这 4 个字的勇气。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 39 · 朋友圈刷到大学同学晒娃晒新车 · 小动作
// ----------------------------------------------------------------------------

=== choice_38 === // (was: choice_同学晒娃晒车)
# category: small_joy
# season_unlock: any
# time_filter: lunch
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 6

12:45。趴桌子刷朋友圈。

大学同学小马：今年的新 BBA + 配文"老婆送的生日礼物 + 3 岁宝宝合照"。

36 个赞。

* [点赞]
    你点了。0.5 秒后他点回了你 3 年前那张富士山照。
    ~ state = state - 3

* [划走]
    你刷下一条。同事在晒加班餐。
    // 0 change

* [屏蔽小马]
    你设了"不看他朋友圈"。1 周后你又点开。
    ~ state = state - 5
    // hidden flag: 你屏蔽过同学

- _他 3 岁那张合照——背景是上海陆家嘴。_
- _我的富士山头像还是 5 年前的。_
- _我有没有过去——这个问题不能问。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 40 · 招聘 app 搜"远程 / wfh / 25k 起" · 小动作
// ----------------------------------------------------------------------------

=== choice_39 === // (was: choice_招聘app搜远程)
# category: small_joy
# season_unlock: S2+
# time_filter: morning
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 8

Boss 直聘打开。

关键词："远程"。北京。25k。

搜索结果：3 个匹配。1 个是骗子。1 个要求"5 年 AI 经验"。1 个已下线。

* [投简历]
    你点了那个 5 年 AI 的。简历提交后 28 秒——已读，"不合适"。
    ~ state = state - 5
    ~ resume_sent_count = resume_sent_count + 1

* [收藏]
    你点了星标。下次打开还是这 3 个。
    ~ state = state - 2

* [改 15k]
    搜索结果：147 个。都是文员 / 助理 / 客服。
    ~ state = state - 8

- _25k 远程的工作不存在。_
- _我每次搜 都是为了确认"我已经问过了"。_
- _问完就可以心安理得地继续待这。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 41 · 月初偷偷给妈微信打 1000 · 小动作 (NPC 互动 sub-tag)
// ----------------------------------------------------------------------------

=== choice_40 === // (was: choice_月初转钱给妈)
# category: small_joy
# npc_focus: mom
# season_unlock: any
# time_filter: evening
# both
# cooldown_episodes: 4
# frequency_per_series: 13

月初 1 号晚上 22:30。

你打开微信。给妈转 1000。备注："养老金调整"。

你妈不知道这是你转的。她以为是社保系统。

* [转 1000]
    你转完。妈 3 分钟后微信"今天调整？" 你回"嗯"。
    ~ money = money - 1000
    ~ state = state + 3
    ~ mom_score = mom_score + 5

* [转 500]
    你转完。备注同上。妈没回——她可能没注意到金额。
    ~ money = money - 500
    ~ mom_score = mom_score + 2

* [不转]
    你犹豫了 5 分钟。关掉微信。
    ~ state = state - 8
    ~ mom_score = mom_score - 3

- _我转钱时备注写"养老金调整"。_
- _她信。_
- _她信是因为她想信。_
- _我们都需要这个信。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 42 · 装忙在键盘上敲假字 · 小动作
// ----------------------------------------------------------------------------

=== choice_41 === // (was: choice_装忙打字)
# category: small_joy
# npc_focus: wang
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 3
# frequency_per_series: 16

王总监从远端独立办公室出来。

你余光看见他朝你这边走。

你的屏幕在小红书"30 岁还没买房"长帖。

* [Alt+Tab 装打字]
    你切到 word 空白文档。10 个手指齐飞。王总监路过没停。
    ~ state = state + 5

* [不切]
    王总监停了 0.5 秒。"嗯，调研。"走了。
    ~ kpi = kpi - 3
    ~ wang_score = wang_score - 1

* [主动打招呼]
    你说"王总好"。王总监："小笑啊，最近 deliverable 怎么样？" 5 分钟立谈。
    ~ kpi = kpi + 3
    ~ state = state - 8

- _我打的"asdfjkl;"飞快。_
- _王总监以为我在出方案。_
- _其实我连"我"字都不知道下一句要写什么。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 43 · 公司年度体检报名 vs 跳过 · 小动作 (Zoe 互动 sub-tag)
// ----------------------------------------------------------------------------

=== choice_42 === // (was: choice_年度体检报名)
# category: small_joy
# npc_focus: zoe
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 52
# frequency_per_series: 1

HR Zoe 群里发：「**年度体检报名截止本周五，未报名视为放弃。**」

你去年的报告还在抽屉，没拆封。

* [报名]
    你点了。下周二上午半天体检。报告 1 个月后到。
    ~ kpi = kpi - 5
    ~ state = state + 5
    // hidden flag: 你年度体检 +1

* [不报]
    你没点。周五 Zoe 私聊"陈先生这边的报名……" 你说"忘了"。
    ~ state = state - 3
    ~ zoe_score = zoe_score - 1

* [报名 + 虚报冲突]
    你报了周二早。等到周二早上你发"今天有客户对接来不了"。
    ~ state = state + 3
    // hidden flag: 你跳过 1 次体检 (虚报)

- _去年的报告我没拆。_
- _不是没时间。是没勇气。_
- _今年的我也想跳过。_
- _但 HR 会记。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// NPC 互动类 (9 stitches: #12-#13 翻译 + #45-#51 新; #11 是 sample 2)
// ============================================================================

// ----------------------------------------------------------------------------
// Choice 12 · 下午 3 点同事生日 HR 强制起立合唱 · NPC 互动 (markdown #12 翻译)
// ----------------------------------------------------------------------------

=== choice_43 === // (was: choice_生日合唱)
# category: npc
# npc_focus: zoe
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 12

HR Zoe 在工位区拍手："各位，今天是 [X 同事] 生日，我们一起唱生日快乐～"

同事们陆续起立。你也被迫站起来。

* [假唱]
    你嘴巴动，没出声。同事中也有 1/3 跟你一样。
    ~ state = state + 2

* [低头看手机]
    Zoe 看了你一眼，没说什么。
    ~ state = state - 3
    ~ zoe_score = zoe_score - 1

- _张嘴是社交税。低头是不识时务。_
- _我交税。_
- _Zoe 也不想唱。她在执行流程。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 13 · HR 找你"下午方便聊 5 分钟吗" · NPC 互动 (markdown #13 翻译)
// ----------------------------------------------------------------------------

=== choice_44 === // (was: choice_HR找你5分钟)
# category: npc
# npc_focus: zoe
# season_unlock: any
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 6

微信通知：HR Zoe → 你

"**陈笑天先生，下午方便聊 5 分钟吗？**"

没有上下文。没有理由。

* [去]
    你下午 3 点去 HR 工位。Zoe："就是想问一下您本月的考勤记录。"
    5 分钟变成 15 分钟。
    ~ kpi = kpi - 3
    ~ state = state - 10

* [拖到下班]
    你回"今天有点忙，明天可以吗？" Zoe："好的。" 第二天她又找你。
    ~ state = state - 5

- _HR 找你聊 5 分钟从来不是 5 分钟。_
- _也从来不是好事。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 45 · Lisa 周日晚微信"明天加班吗 我自己一个人有点慌" · NPC 互动
// ----------------------------------------------------------------------------

=== choice_45 === // (was: choice_lisa周日加班求陪)
# category: npc
# npc_focus: lisa
# season_unlock: any
# time_filter: evening
# weekend_only
# cooldown_episodes: 4
# frequency_per_series: 6
// 前置: Lisa S1-S3 在场 + lisa_score >= 5

周日 21:34。

微信通知：Lisa → 你

"笑天，明天来公司加班吗？我自己一个人有点慌。"

* [好我也去]
    你回了。第二天 9:00 你到公司，Lisa 8:30 就到了。她奶茶帮你也带了一杯。
    ~ kpi = kpi + 5
    ~ state = state - 10
    ~ lisa_score = lisa_score + 10
    ~ weekend_with_lisa = true

* [推]
    你回了"我有事去不了"。Lisa："好的，那我自己。"
    第二天她周报里写"独立完成"。
    ~ lisa_score = lisa_score - 5

* [装睡]
    你不回。周一早 8:50 她又发"看到了吗"。你回"刚醒"。她："没事。"
    ~ lisa_score = lisa_score - 8
    // hidden flag: Lisa 不再主动找你

- _她说"自己一个人有点慌"——_
- _她不是怕公司空。_
- _她是怕一个人面对自己的 KPI 单。_
- _我也怕过。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 46 · 李阿姨擦你工位 看见"活到周五"便利贴 · NPC 互动
// ----------------------------------------------------------------------------

=== choice_46 === // (was: choice_李阿姨看便利贴)
# category: npc
# npc_focus: li
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 4
// 前置: 李阿姨 S1-S8 在场 + 笑天早到

8:51。你早到 9 分钟。

李阿姨在擦你工位。她看到桌面贴的便利贴"**活到周五**"。

她拿着抹布的手停了 0.5 秒。

* [笑一下]
    你坐下。李阿姨没说话，多擦了 1 下。
    ~ state = state + 3
    ~ li_score = li_score + 0   // li_score 不影响机制 (per npcs.md §5)

* [主动解释]
    你说"哈哈我自己写着玩的"。李阿姨："小伙子，慢点。"她**没看你**继续擦。
    ~ state = state + 5
    ~ li_score = li_score + 0

- _李阿姨擦了 8 年工位。_
- _她见过更绝望的便利贴。_
- _她没说"加油"。_
- _她说"慢点"。_
- _这是这层楼最锋利的一句话。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 47 · IT 小马终于现身修咖啡机 · NPC 互动
// ----------------------------------------------------------------------------

=== choice_47 === // (was: choice_IT小马修咖啡机)
# category: npc
# npc_focus: it_xiaoma
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 4
// 前置: 你 escalate 工单 >= 3 次 + coffee_machine_broken_days 累积

IT 小马背着机修包出现在茶水间。

他蹲下来看了 2 分钟，"哎我看下啊"。

5 分钟后："这个零件还要等。您先用别的。"

* [你能不能换]
    你说了。小马："对不起这个不归我管。"
    ~ state = state - 5
    ~ it_xiaoma_score = it_xiaoma_score - 1

* [辛苦了]
    你笑了一下。小马走了。
    下午茶水间贴了新告示"零件已到，本周修复"——你知道这是假的。
    ~ state = state + 3
    ~ it_xiaoma_score = it_xiaoma_score + 2

* [递烟]
    你递给他一支烟（你不抽烟，是 David 落工位的）。小马接了。
    他第二天又来了一次——但还是没修好。
    ~ it_xiaoma_score = it_xiaoma_score + 5
    // hidden flag: 你跟 IT 小马是同类

- _他装得比我专业。_
- _我装的"在工作"——王总监能识破。_
- _他装的"在修咖啡机"——所有人都信。_
- _他在装一个永远修不好的事。_
- _这是天才。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 48 · 老周递给你纸巾（你打翻了咖啡） · NPC 互动
// ----------------------------------------------------------------------------

=== choice_48 === // (was: choice_老周递纸巾)
# category: npc
# npc_focus: lao_zhou
# season_unlock: any
# time_filter: anytime
# weekday_only
# cooldown_episodes: 26
# frequency_per_series: 2
// 前置: 老周在场 + 笑天打翻咖啡 / 茶 (极罕见 trigger)
// per npcs.md §8 "笑天主动找他 ≤ 3 次/季"

你工位上保温杯倒了。

老周从他的位置（5 米外）走过来，递给你 3 张纸巾。

他**没说话**。

* [谢谢周哥]
    你说了。老周点头回去了。
    ~ state = state + 5
    ~ lao_zhou_score = lao_zhou_score + 1

* [默默接过]
    你接了。老周看你 0.5 秒回去了。
    ~ state = state + 3

- _他递我 3 张纸巾。_
- _他在公司 12 年——他知道 1 张不够。_
- _他不说话，但他知道。_
- _这就是 10 年后的我吗。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 49 · David 周一电梯偶遇"周末过得怎样" · NPC 互动
// ----------------------------------------------------------------------------

=== choice_49 === // (was: choice_David电梯周末)
# category: npc
# npc_focus: david
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 2
# frequency_per_series: 16
// 前置: David 在场 (S1-S6)

周一 8:55。电梯。

David 穿一件新衬衫，挽着袖子。

"兄弟！周末过得怎样？"

* [出去玩了]
    你撒谎。David："哦哦不错不错。我加班来着，本来想叫你。"
    ~ state = state - 3

* [在家躺]
    你说真话。David："哎你这就不对了，年轻人应该多 push 自己。"
    ~ state = state - 5
    ~ david_score = david_score - 1

* [反问"你呢"]
    # speaker: david
    David："我加班啊！周末来公司清静。"——他真的来了。
    ~ state = state - 3

- _他每周一都问"周末过得怎样"。_
- _不是关心。_
- _是**确认**。_
- _确认我没在他不知道的时候卷他。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 50 · Vivian 前台压低声音"听说了吗" · NPC 互动
// ----------------------------------------------------------------------------

=== choice_50 === // (was: choice_Vivian八卦)
# category: npc
# npc_focus: vivian
# season_unlock: any
# time_filter: morning
# weekday_only
# cooldown_episodes: 6
# frequency_per_series: 8
// 前置: 公司有新动态 (融资 / 裁员 / 老板心情)

8:58。你刷脸打卡。

Vivian 凑过来，压低声音："诶你听说了吗——昨天老板在 9 楼会议室开了 2 小时会，今天 HR 都没人在。"

她眼睛飘向门口。

* [八卦回去]
    你说"啥情况？" Vivian："不好说，但水果盘明天换苹果。"
    ~ state = state + 3
    ~ vivian_score = vivian_score + 3
    // hidden flag: 你接到融资暂停信号

* [装没听到]
    你说"嗨～早"。Vivian："你忙吧。"
    ~ vivian_score = vivian_score - 1

* [反问老板心情]
    # speaker: vivian
    Vivian："不好。" 她没多说。
    ~ state = state - 3
    ~ vivian_score = vivian_score + 1
    // hidden flag: 老板心情差信号

- _Vivian 是这层楼的天气预报。_
- _她比我领导更早知道天气。_
- _但我没法订阅她的更新。_
- _我只能跟她"嗨～"。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 51 · 妈妈周日视频"那个王二家儿子上海买房了" · NPC 互动
// ----------------------------------------------------------------------------

=== choice_51 === // (was: choice_妈妈王二家儿子)
# category: npc
# npc_focus: mom
# season_unlock: any
# time_filter: morning
# weekend_only
# cooldown_episodes: 4
# frequency_per_series: 8

周日 8:34。妈妈视频。

"天天，那个王二家儿子，你记得吧？小时候跟你抢过糖那个。"

"他在上海买房了。"

你能听见妈妈背景里油烟机响。

* [嗯]
    你"嗯"了一声。妈妈："哎你呢？" 你："再等等。"
    ~ state = state - 8

* [转移话题]
    你说"你身体怎样妈"。妈妈："我好着呢。"——她 3 秒后又说回王二。
    ~ state = state - 3
    ~ mom_score = mom_score + 1

* [真话]
    你说"我买不起妈"。妈妈安静 4 秒。"没事。咱不急。"
    她背景里油烟机声更响。
    ~ state = state - 10
    ~ mom_score = mom_score + 5
    ~ told_mom_truth_count = told_mom_truth_count + 1

- _妈不是攀比。_
- _她是问我"你过得好不好"。_
- _但我们都不会直接问这个。_
- _我们说王二家。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// 大决策类 S3+ (4 stitches: #52-#55 新; #14 是 sample 3)
// ============================================================================

// ----------------------------------------------------------------------------
// Choice 52 · 搬家近公司 中介推 8500/月 1 居 · 大决策
// ----------------------------------------------------------------------------
// 注: 内心独白保留 verbatim "8 分钟通勤. 8 年前我以为这是奖励..."
// 这是 round-1-reply §1 highlights 的 series-finale 级别 quote.

=== choice_52 === // (was: choice_搬家近公司)
# category: big_decision
# season_unlock: S3+
# time_filter: anytime
# both
# cooldown_episodes: 52
# frequency_per_series: 1

中介林姐（不是客户成功部林姐，是同名）微信发你：

「**笑天哥，公司这附近一居室刚出来一套，8500/月——通勤步行 8 分钟，您要不要看看？**」

你现在租的是 4500/月，地铁 1 小时 10 分钟。

* [看 + 搬]
    你周末看了。下定金。下个月起房租 +4000。
    通勤选项重写——morning_briefing 不再有"地铁"选项。
    ~ money = money - 200
    ~ state = state + 5
    ~ has_moved = true
    // S5+ 王总监 push 频率 +1 ("反正你近")
    // S10+ 猎头电话内心独白多 1 句 "我刚搬到这"

* [看 不搬]
    你周末看了。回家发现自己其实喜欢 1 小时 10 分钟的地铁——那是唯一刷小红书的时间。
    ~ state = state - 3

* [不看]
    你"最近忙下次"。中介 2 周后又发了一套 9200/月的。
    // 0 change

- _8 分钟通勤。_
- _8 年前我以为这是奖励。_
- _现在我知道这是 trap——王总监 22:00 喊我加班 3 分钟我就到了。_
- _我宁可被地铁挤。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 53 · 接到陌生猎头电话 · 大决策
// ----------------------------------------------------------------------------

=== choice_53 === // (was: choice_接猎头电话)
# category: big_decision
# season_unlock: S10+
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 3

下午 15:18。陌生号码北京 010。

你犹豫了 4 秒。接了。

"您好，我是 XX 猎头，您之前的简历我们看到，有一个产品经理岗位，35k 起，您方便聊一下吗？"

* [加微信]
    你说"现在不方便"。她加你微信。3 周后她又发了 2 个机会。
    ~ state = state + 3
    ~ met_headhunter_count = met_headhunter_count + 1
    // S11 投简历类 choice 解锁

* [直接拒]
    你说"我不考虑"。挂了。她不会再打。
    // hidden flag: 笑天 voice 略升级 ("我也想过" 内心独白增多)

* [听完不加]
    你听了 6 分钟。挂了之后你在工位发了 30 分钟呆。
    ~ state = state - 8
    // hidden flag: 你想过跳槽

- _35k 起。_
- _我现在 18k。_
- _但她说的是"起"。_
- _所有 35k 起的工作面试 3 轮发现是 22k 起。_
- _我学过这个。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 54 · 投简历给 X 公司 · 大决策
// ----------------------------------------------------------------------------
// 注: 末尾内心独白保留 verbatim "简历是我每年 1 次的小说创作."
// 这是 round-1-reply §1 highlights 的 series-finale 级别 quote.

=== choice_54 === // (was: choice_投简历给X公司)
# category: big_decision
# season_unlock: S11+
# time_filter: anytime
# both
# cooldown_episodes: 4
# frequency_per_series: 5
{met_headhunter_count == 0: -> DONE}   // 前置: #53 选 A 后才解锁

你打开简历。改了 3 行。删了 2 段。加了 1 个"项目复盘"的 fake project。

投递按钮悬在半空。

* [投]
    你点了。HR 1 小时后已读不回。1 周后没回。2 周后没回。
    ~ state = state - 8
    ~ resume_sent_count = resume_sent_count + 1

* [改更多]
    你周末又改了一遍。简历放在桌面 1 个月。
    ~ state = state - 3
    // hidden flag: 你 series 内有效投递 0

* [林姐 referral]
    你绕了林姐 internal referral。
    林姐 3 天后回"下次有 head count 优先你哈"——但她不会打。
    ~ state = state + 3
    ~ lin_jie_score = lin_jie_score + 3   // Round 3 patch: 用上 designer line 219 加的 VAR
    // hidden flag: 林姐 referral 路径解锁 (S12 finale)

- _我改简历 改了 3 行 删了 2 段。_
- _删的是"5 年大厂经验"——上家裁的那段。_
- _改的是"我曾领导一个 12 人项目组"——其实我领导过 1 个 3 人小组共 2 周。_
- _简历是我每年 1 次的小说创作。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 55 · 请年假 5 天去日本 · 大决策
// ----------------------------------------------------------------------------

=== choice_55 === // (was: choice_请年假去日本)
# category: big_decision
# season_unlock: S6+
# time_filter: anytime
# both
# cooldown_episodes: 52
# frequency_per_series: 1
// 前置: 累积加班 >= 60 小时 (runtime 自动判定)

你打开 HR 系统。请假申请。

5 天年假。理由："家事"。

你想填"去日本"。但系统里那个字段叫"事由"。

* ["家事"]
    王总监 1 小时后审批"已批"。
    但他下午路过工位说"小笑啊，最近有什么家事吗？"
    ~ money = money - 8000
    ~ state = state + 20
    ~ went_japan_trip = true

* ["个人事务"]
    王总监 1 小时后审批"已批"。他没问。
    ~ money = money - 8000
    ~ state = state + 20
    ~ went_japan_trip = true

* [取消]
    你点了"申请取消"。王总监："好。"你周一照常上班。
    ~ state = state - 10
    ~ cancelled_japan_trip_count = cancelled_japan_trip_count + 1

- _我这次去日本是 8 年前那张富士山照片的延续。_
- _但 5 天去 3 个城市——我会拍很多照片但 1 张都不发朋友圈。_
- _这次是真的我自己去。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// 存活 buffer 类 (5 stitches: #56-#60 新, conditional unlock)
// ============================================================================

// ----------------------------------------------------------------------------
// Choice 56 · 病倒早晨 8:00 起来发烧 38.5 · 存活 buffer
// ----------------------------------------------------------------------------
// 注: 内心独白保留 verbatim "38.5 度——这是我每年生病的最低标准.
// 但请 5 天假需要的勇气比 38.5 度难得多. 我妈不知道我生病了. 王总监知道..."
// 这是 round-1-reply §1 highlights 的 series-finale 级别 quote.

=== choice_56 === // (was: choice_病倒发烧38度5)
# category: survival
# season_unlock: sick_triggered
# time_filter: morning
# weekday_only
# cooldown_episodes: 4
# frequency_per_series: 6
// 前置: state < 20 第一次 (强制触发, runtime 推送)

周二早 8:00。

你测体温——38.5。

病倒系统提示：你已被强制半日休假到 12:00。

* [全天请假]
    你发"今天发烧 38.5 在家休息"。王总监："好好休息哈。"
    Zoe 群里"陈先生病假已记录。"
    ~ kpi = kpi - 8
    ~ state = state + 30
    ~ sick_count = sick_count + 1

* [硬撑下午]
    你 12:00 还在烧。13:00 你出现在工位。同事都躲你。
    ~ kpi = kpi - 3
    ~ state = state - 5
    ~ sick_count = sick_count + 1

* [虚开 5 天]
    你发"医生说要休 5 天"。HR 要病假证明。你周三去找诊所开了。
    ~ kpi = kpi - 15
    ~ money = money - 200
    ~ state = state + 40
    ~ sick_count = sick_count + 1
    ~ fake_sick_note_count = fake_sick_note_count + 1

- _38.5 度——这是我每年生病的最低标准。_
- _但请 5 天假需要的勇气比 38.5 度难得多。_
- _我妈不知道我生病了。_
- _王总监知道。_
- _我不知道哪个让我更难受。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 57 · 焦虑 burst 凌晨 3 点睡不着 · 存活 buffer
// ----------------------------------------------------------------------------

=== choice_57 === // (was: choice_焦虑凌晨3点)
# category: survival
# season_unlock: anxiety_triggered
# time_filter: evening
# both
# cooldown_episodes: 4
# frequency_per_series: 8
// 前置: state > 70 + 累积本月加班 > 30 小时 (runtime 计算)

凌晨 3:14。

你睁眼。

心跳得很重——不是疼，是它在那。

你打开手机。微信里 12 条 leader 凌晨发的消息你半小时前刚回完。

* [起来吃东西]
    你下楼买了一份煎饼。摊主大姐 4:00 还在。回家 4:30 你睡了。
    ~ money = money - 8
    ~ state = state + 5

* [看心理医生]
    你查了一家。挂号 800。下周一去。
    ~ money = money - 800
    ~ state = state + 20
    // hidden flag: 你看过 1 次心理医生

* [硬扛数羊]
    你数到 700。最后睡了。早晨 8:00 闹钟。状态空了一半。
    ~ state = state - 15
    ~ anxiety_stack = anxiety_stack + 1
    // anxiety_stack >= 5 → 想跳槽 flag 升级 → S10+ 猎头电话主动接概率 +30%

- _心跳得很重——_
- _不是疼。_
- _是它在那。_
- _我妈说她刚退休那年也这样。_
- _我们家这个毛病。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 58 · 钱紧 信用卡账单到期还差 1500 · 存活 buffer
// ----------------------------------------------------------------------------

=== choice_58 === // (was: choice_钱紧差1500)
# category: survival
# season_unlock: money_low
# time_filter: evening
# both
# cooldown_episodes: 4
# frequency_per_series: 6
// 前置: money < 5000 (runtime 自动检测, check_state_after_choice 推送)

信用卡账单提醒：本月 12 号到期，应还 6500。

你账户余额 5000。

还差 1500。

* [网贷]
    你下了一个 app。借 3000，月还 800（永久）。
    ~ money = money + 3000
    ~ state = state - 8
    ~ took_payday_loan_count = took_payday_loan_count + 1

* [借 Lisa]
    你犹豫了半天。最后给 Lisa 微信"借我 1500 这周还"。
    # speaker: lisa
    Lisa："好。"她当天转给你。下周你还了。她什么都没说。
    ~ money = money + 1500
    ~ state = state - 10
    ~ lisa_score = lisa_score - 3

* [信用卡最低]
    你点了最低还款 650。剩下的下月还。利息 +1.2%/月。
    ~ state = state - 3
    ~ credit_card_revolving_count = credit_card_revolving_count + 1

- _我借 Lisa 1500——_
- _她以为我吃饭不够。_
- _其实是我上个月给妈打的 1000 + 健身卡 1980 + 房租。_
- _她借给我那 1500 不是钱。_
- _是她相信我下周会还。_
- _这个比 1500 贵。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 59 · HR Zoe "陈先生 方便聊一下您本季度的状态吗" · 存活 buffer
// ----------------------------------------------------------------------------

=== choice_59 === // (was: choice_Zoe约谈状态)
# category: survival
# npc_focus: zoe
# season_unlock: hr_warning
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 3
// 前置: 累积病倒 >= 3 OR fake_sick_note_count >= 4

Zoe 微信："**陈先生，方便聊一下您本季度的状态吗？我们这边的流程是关心一下哈。**"

没有上下文。

但你心里有上下文。

* [主动汇报]
    你坦白"最近确实状态不太好"。
    # speaker: zoe
    Zoe："理解一下哈。"她 PUA 教科书式安抚 12 分钟。
    ~ kpi = kpi - 3
    ~ state = state - 10
    ~ zoe_score = zoe_score + 3
    ~ zoe_knows_bad_state = true
    // S 后期 GO 文案改为"组织调整"路径 (更冷)

* [假装良好]
    你笑。Zoe："那您要好好照顾自己哈。"她按计划走了流程的第 1 步。
    ~ state = state - 3
    // hidden flag: Zoe 在 HR 系统记录"员工不配合"
    // S 中期 GO 文案改为"末位淘汰" (更直接)

* [反问例行]
    你说"是 HR 例行流程吗"。Zoe 慌一下："对对对，例行的。"她继续走。
    ~ kpi = kpi - 3
    ~ state = state + 5
    ~ zoe_score = zoe_score - 1
    // hidden flag: Zoe 警觉

- _Zoe 找我聊"状态" =_
- _HR 流程的第 1 步。_
- _第 2 步是月度面谈。_
- _第 3 步是 PIP（绩效改进计划）。_
- _第 4 步是签字走人。_
- _我看过 Lisa 的全套流程。_

~ check_state_after_choice()
-> DONE


// ----------------------------------------------------------------------------
// Choice 60 · 主动找王总监谈"晋升候选" · 存活 buffer
// ----------------------------------------------------------------------------
// 注: 内心独白保留 verbatim "我妈起名'笑天', 希望我能笑傲天下..."
// 这是 round-1-reply §1 highlights 的 series-finale 级别 quote +
// protagonist.md game over 经典独白闭环.
// 选 A → 立即触发 E48 终极 GO "恭喜晋升" (anti-Pillar 1 极致)

=== choice_60 === // (was: choice_找王总监谈晋升)
# category: survival
# npc_focus: wang
# season_unlock: promotion_candidate
# time_filter: afternoon
# weekday_only
# cooldown_episodes: 8
# frequency_per_series: 1
// 前置: promotion_candidate_count >= 1 (KPI 累积 > 150 触发, episode-1.ink VAR)

你站在王总监独立办公室门口。

你已经 3 天没睡好。

这次主动找他——是为了**确认你听到的是真的**。

* [接受]
    # speaker: wang_director
    王总监："小陈，明年提你做主管，你下属直接对接。"
    你说"谢谢王总"。他点头。
    ~ promotion_candidate_count = promotion_candidate_count + 5
    // 立即触发 E48 终极 GO "恭喜晋升" via check_state_after_choice() (>= 6)

* [拒绝]
    你说"王总，我可能更适合现在的岗位"。
    # speaker: wang_director
    王总监："小笑啊，你太谦虚了。"——他记 1 笔。下个月 threshold 涨 +15%（不接受 = 不配合）。
    ~ state = state - 5
    ~ wang_score = wang_score + 1
    // hidden flag: KPI 阈值 +15% 永久 (S12 finale 几乎不可达)

* [转身离开]
    你转身回工位。王总监主动来找你"小笑啊我们聊聊？" 这是不可避免的。
    ~ state = state - 3
    // hidden flag: 触发延迟 1 周, 还是会发生

- _我妈起名"笑天"，希望我能笑傲天下。_
- _现在我能。_
- _但我笑不出来。_
- _我不知道她会不会以为这是好消息。_

~ check_state_after_choice()
-> DONE


// ============================================================================
// EOF · Round 2 完成 (60/60 stitches)
// ============================================================================
//
// Round 2 由分身 CC session 完成于 2026-05-05:
//   - Designer sample stitches (3 个): #02 凌晨leader微信 / #11 HR接龙 / #14 35岁体检
//   - Round 2 翻译 (12 个): #01, #03-#10, #12-#13 (markdown gold standard 翻译)
//   - Round 2 新写 (45 个): #15-#21, #22-#31, #32-#38 + #44, #39-#43, #45-#51,
//     #52-#55, #56-#60
//
// 类目分布:
//   - 通勤 (8): #01, #15-#21
//   - 午餐 (10): #22-#31
//   - 工作内容 (12): #02 sample, #03-#05 翻译, #32-#38 + #44 新
//   - 小动作 / 小确幸 (10): #06-#10 翻译, #39-#43 新
//   - NPC 互动 (10): #11 sample, #12-#13 翻译, #45-#51 新
//   - 大决策 (5): #14 sample, #52-#55 新
//   - 存活 buffer (5): #56-#60 新
//   - Bonus seasonal: 0 (优先翻译完 60 个, seasonal 留给后续 expansion)
//   总计: 60 stitches
//
// 7 个 series-finale 级别 quote 全部 verbatim 保留:
//   - #23 "她从不主动说拼下一次. 但每次她都问." (scene description)
//   - #24 "沙县老板记得我的脸. 我们公司王总监 8 个月还叫不准我名字."
//   - #26 "一年下来我在茶水间偷过 3 包速溶 + 1 包茶包 + 1 杯星巴克..."
//   - #52 "8 分钟通勤. 8 年前我以为这是奖励. 现在我知道这是 trap..."
//   - #54 "简历是我每年 1 次的小说创作."
//   - #56 "38.5 度——这是我每年生病的最低标准..."
//   - #60 "我妈起名'笑天', 希望我能笑傲天下..."
//
// 1 处 typo 修正应用:
//   - #28 选 A 后果 "你请他付的那 200 块停车费" → "但我付的那 200 块停车费"
//
// 隐藏 flag VAR 声明 (新增 12 个, 见顶部 INCLUDE 之后):
//   has_moved / gym_card_held / resume_sent_count / met_headhunter_count /
//   took_payday_loan_count / credit_card_revolving_count / anxiety_stack /
//   fake_sick_note_count / zoe_knows_bad_state / went_japan_trip /
//   cancelled_japan_trip_count / told_mom_truth_count
//
// daily-choices.md §5 原文 read-only, 未改 (typo 仅修在 .ink 翻译).
// daily-choices.md §4 表格已 update "已 ink 化" 列 ✓.
//
// ----------------------------------------------------------------------------
// Round 3 patches (分身回应 designer line 175 + 217-219 review):
//   - Designer 在 #14 (Sample 3) line 175 自己 patch 加 ~ gym_card_held = true
//     → gate #25 健身房午休 stitch (line 664). 已生效, 无需分身改动.
//   - Designer 在 line 217-219 加 VAR lin_jie_score 声明 → 分身 Round 3 patch
//     #54 投简历给X公司 选 C "林姐 referral" 用上 lin_jie_score (line 2290).
//     替换原 // hidden flag comment 为 ~ lin_jie_score = lin_jie_score + 3.
// 详见 daily-choices-round-3-response.md.
//
// END
