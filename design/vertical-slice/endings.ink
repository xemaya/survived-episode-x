// ============================================================================
// Endings · Game Over (5) + Happy Ending Variants (6)
// ============================================================================
//
// Status: 第 1 版 (W3 reuse session 写, 2026-05-07)
// Author: 分身 CC session (W3 — Endings Round 1)
// Last Updated: 2026-05-07
//
// 配套 reference: gameover-and-happy-ending-ink-handoff.md
//                series-structure.md §5 + §6 + §7
//                protagonist.md §9 + §11 (主角设计禁忌)
//                tone-bible.md v2 (5 原则)
//
// 设计目标:
//   1. 5 GO 类 + 6 happy ending variants — 11 个 ending knots, 各 self-contained
//   2. anti-Pillar 1 极致: 没有"赢" 语气 / 没有"被裁" 字 / 没有"加油下次再来"
//   3. 文案 anchor 字字保留 (per handoff §4)
//   4. 笑天 voice 一致 — observer + self-deprecate + 不煽情 + 反高潮
//   5. 复合 happy ending 由 TS runtime 处理顺序; 本 .ink 每 variant 独立 knot
//
// Runtime 集成:
//   - TS 监听 state, 触发条件满足时 ChoosePathString('game_over_X' or 'happy_ending_X')
//   - 进入 ending 前 runtime 切换到 endings.json (之前episodes 的同名 stub knots 是 no-op)
//   - 每 ending knot 末 -> END (终止 story flow, runtime 处理 Archive UI)
//
// 注: 本文件**不 INCLUDE episode-1.ink** — 避免与 episode-1.ink 内的 stub knots
//     (game_over_too_sick / game_over_promoted / etc) 名字冲突
//     (Ink 不允许同名 knot 重复定义)。
//     stub 在 episode-N.json 内仍是 no-op (那是 runtime fallback 用),
//     真正的 ending 内容在本 endings.json (runtime 主动 load)。
//
// ============================================================================


// ============================================================================
// === Game Over · 5 类 ============================================
// ============================================================================


// ----------------------------------------------------------------------------
// game_over_too_sick — 病倒 (sick_count >= 7)
// ----------------------------------------------------------------------------
// 触发: 累积病倒 7 次. medical leave 超 cap, HR 流程化处理。
// 没有 verbatim anchor (per handoff §6 提交表格 "无 anchor"),
// 但保持 HR-speak / PUA cold tone — 不带"心疼" / "保重" emotional language。
// ----------------------------------------------------------------------------

=== game_over_too_sick ===
# scene: bedroom_sick
# time: monday_morning
# speaker: protagonist

_闹钟响第 3 次。_

_你没起。_

_38.9 度。第 7 次了。_

# diegetic_ui: phone_wechat_notification

# speaker: zoe
Zoe 微信:

# speaker: zoe
"陈笑天先生, 您本季度医疗假累积已达上限。"

# speaker: zoe
"我们这边的流程是: HR 将于本周三与您 1 对 1 沟通后续岗位适配。"

# speaker: zoe
"您这边方便的话, 周三上午来一下。"

# speaker: protagonist

_周三。_

_她说"上限"。_

_她不说"你被解雇"。她说"岗位适配"。_

_HR-speak 把"我撑不住" 翻译成"上限"。_

_把"裁员" 翻译成"岗位适配"。_

_她没说"保重身体"。她不说。_

_她在执行流程。_

_我也在。_

_我躺在床上, 体温 38.9 度, 等周三。_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// game_over_appearing_unsuitable — 适应不良 (S1-S3 早期 GO)
// ----------------------------------------------------------------------------
// 触发: 月末 KPI Review fail + month <= 3 (E4 / E8 / E12)
// Verbatim 必保:
//   - 王总监 "小笑啊…陈天啊…我们这边觉得你可能不太适合。"
//   - Zoe "陈笑天先生, 已为您协调岗位适配方案。"
// ----------------------------------------------------------------------------

=== game_over_appearing_unsuitable ===
# scene: meeting_room_one_on_one
# time: month_end_morning
# speaker: wang_director

王总监找你 1 对 1。

他坐在你对面的会议室椅子上。他**没看你眼睛**。

# speaker: wang_director
王总监: "小笑啊。"

0.5 秒。

# speaker: wang_director
"陈天啊。"

0.5 秒。

# speaker: wang_director
"差不多差不多。**我们这边觉得你可能不太适合。**"

# speaker: wang_director
"具体的, Zoe 那边会跟你 follow up。"

他站起来, 收 PPT 笔记本走了。

# speaker: protagonist

_他没说"被裁"。_

_他说"不太适合"。_

_他到走的那天还叫不准我名字。_

# diegetic_ui: phone_wechat_notification

# speaker: zoe
Zoe 微信 1 条:

# speaker: zoe
"**陈笑天先生, 已为您协调岗位适配方案。**"

# speaker: zoe
"您方便的话, 这周走完流程。"

# speaker: protagonist

_岗位适配方案——_

_我没新岗位。_

_她说的"协调" 等于"协调我离开"。_

_HR-speak 把"我们让你走" 翻译成"为您协调"。_

_她每个字都温柔。_

_每个字都不可商量。_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// game_over_last_in_line — 末位淘汰 (S4-S7 中期 GO)
// ----------------------------------------------------------------------------
// 触发: 月末 KPI Review fail + 4 <= month <= 7 (E16 / E20 / E24 / E28)
// Verbatim 必保:
//   - 王总监 "这个月我们部门要做一些调整。你这个 KPI 在末位 10%。"
//   - Zoe "您这边方便的话, 本周走完流程。"
// ----------------------------------------------------------------------------

=== game_over_last_in_line ===
# scene: wang_solo_office
# time: month_end_afternoon
# speaker: wang_director

王总监把你叫到他独立办公室。

门关。

他坐在办公桌后, 你坐在他对面。

# speaker: wang_director
王总监: "小陈啊。"

_这次他直接叫"小陈"——他不再叫"小笑啊…陈天啊"那套。_

_他懒得演熟。_

# speaker: wang_director
"**这个月我们部门要做一些调整。**"

# speaker: wang_director
"**你这个 KPI 在末位 10%。**"

# speaker: wang_director
"我跟你说啊, 这是公司层面的事, 不是我个人对你有意见。"

_"不是个人对你有意见"——_

_他在 protect 自己。_

_他知道下个月新人入职, 他需要 PPT 上"个人没意见"的 quote。_

# speaker: wang_director
"具体的 Zoe 来跟你聊。"

他打开电脑。结束。

# diegetic_ui: phone_wechat_notification

# speaker: zoe
Zoe 微信:

# speaker: zoe
"陈笑天先生, 我这边已经收到王总通知。"

# speaker: zoe
"**您这边方便的话, 本周走完流程。**"

# speaker: protagonist

_本周走完流程。_

_5 个工作日。_

_他们已经决定。_

_他们没问我意见。_

_我也没意见。_

_意见对反向 KPI 没用。_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// game_over_org_restructure — 组织调整 (S8-S11 后期 GO)
// ----------------------------------------------------------------------------
// 触发: 月末 KPI Review fail + month >= 8 (E32 / E36 / E40 / E44)
// 没有责怪。没有谈判。流程化执行。
// Verbatim 必保:
//   - Zoe "陈笑天先生, 公司架构调整, 您所在的岗位被合并。"
// ----------------------------------------------------------------------------

=== game_over_org_restructure ===
# scene: hr_workstation
# time: month_end_afternoon
# speaker: zoe

# diegetic_ui: phone_wechat_notification

Zoe 没找你 1 对 1。

她直接发邮件 + 抄送王总监 + HR director。

邮件标题: "关于 product team 架构调整的通知"。

正文 3 段:

# speaker: zoe
"陈笑天先生,"

# speaker: zoe
"**公司架构调整, 您所在的岗位被合并。**"

# speaker: zoe
"具体交接安排详见附件。请于 5 个工作日内完成移交。HR 这边随时支持。"

# speaker: zoe
"祝工作顺利。"

# speaker: zoe
"Zoe / HR"

# speaker: protagonist

_她没说"裁员"。_

_她说"架构调整 / 岗位被合并"。_

_她甚至没用人称——是"陈笑天先生" 而不是"你"。_

_3 段没有责怪。没有谈判。没有 1 对 1。_

_流程化执行。_

_我点了"已读"。_

_她在群里 30 秒后撤回了那条邮件——重发, 没改字, 加了 cc 我老婆 (公司 HR system 自动 pull emergency contact)。_

_她不知道我没老婆。_

_她也不在乎。_

_她在 archive checkpoint 走完。_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// game_over_promoted — 恭喜晋升 (S12 / E48 终极 GO)
// ----------------------------------------------------------------------------
// 触发: promotion_candidate_count >= 6
// 笑天累积"做得太好" 6 次, 老板提主管 = 处刑
// Verbatim 必保:
//   - 王总监 "小陈, 我们觉得你这一年表现很稳。明年提你做主管。"
//   - 笑天 voice "恭喜晋升。我早就知道。"
// 这是反 Pillar 1 最经典的 GO — 见 protagonist.md §9
// ----------------------------------------------------------------------------

=== game_over_promoted ===
# scene: workstation_late_evening
# time: month_12_evening
# speaker: wang_director

王总监今天找你单聊。

他坐在你工位旁的椅子上, 难得这么近。

# speaker: wang_director
王总监: "**小陈, 我们觉得你这一年表现很稳。**"

# speaker: wang_director
"**明年提你做主管。**"

# speaker: wang_director
"你下属直接对接。"

# speaker: protagonist

你说: "谢谢王总。"

# speaker: wang_director

王总监点头。

# speaker: wang_director
"以后部门 KPI 我们一起 push 吧。"

# speaker: wang_director
"你年轻, 该多担一些。"

他走了。

# speaker: protagonist

_**恭喜晋升。**_

_**我早就知道。**_

_我妈起名"笑天", 希望我能笑傲天下。_

_我现在能。_

_但我笑不出来。_

_我不知道她会不会以为这是好消息。_

_她以为我在大公司当 leader。_

_她不知道做 leader 等于明年 KPI 涨 30%。_

_她不知道明年我会更难。_

_她不知道下个月开始我每天 23 点回家。_

_这周给她打电话还是说"工资发了"。_

_她说"挺好的"。_

_她说"挺好的"。_

# pagebreak

-> END


// ============================================================================
// === Happy Ending · 6 Variants ===============================================
// ============================================================================
// 触发: 活过 E52 (12 个月全过) → variant 由累积 flag 判
// 哲学: "被允许休假", 不是"打败 boss"
// 复合规则 由 TS runtime 处理 — 本文件每 variant 独立 knot
// ============================================================================


// ----------------------------------------------------------------------------
// happy_ending_mom — Variant A 妈妈版
// ----------------------------------------------------------------------------
// 触发: 12 个月内 ≥ 9 次接妈妈周日视频
// E52 春节回家最后一晚 anchor
// Verbatim 必保:
//   - 妈妈 "你瘦了。" 笑天 "没瘦。" 妈妈 "瘦了。"
//   - 笑天 voice "不多。但算我赢一次。"
// ----------------------------------------------------------------------------

=== happy_ending_mom ===
# scene: mom_kitchen_evening
# time: e52_sunday_night
# speaker: mama

E52 周日。春节假期最后一晚。

你坐在妈妈家厨房的小方桌旁。

油烟机声音是 baseline。

妈妈端过来一碗汤。

# speaker: mama
妈妈: "你瘦了。"

# speaker: protagonist
你: "没瘦。"

# speaker: mama
妈妈: "瘦了。"

# speaker: protagonist

你笑了一下。

_她说"瘦了" 2 次。_

_我跟她说"没瘦"。_

_她相信她看到的, 不相信我说的。_

_这是她当妈 32 年的 baseline。_

# speaker: mama

妈妈坐下, 看你喝汤。

# speaker: mama
"明天早点起。我送你去高铁站。"

# speaker: protagonist
你: "好。"

_明天回北京。下周一回公司。_

_反向 KPI 还在那。_

_但今晚我在妈妈家。_

_今晚她递了一碗汤。_

_今晚她说"瘦了"。_

_明早她送我去高铁站。_

_**不多。**_

_**但算我赢一次。**_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// happy_ending_japan_ticket — Variant B 5 月日本机票
// ----------------------------------------------------------------------------
// 触发: 完成 E50 订机票 beat
// 笑天微信头像富士山 callback (8 年前去日本)
// Verbatim 必保:
//   - 笑天 voice "8 年了。我以为我会再去。我会去的。这次。"
// ----------------------------------------------------------------------------

=== happy_ending_japan_ticket ===
# scene: bedroom_evening
# time: e50_friday_night
# speaker: protagonist

E50 周五晚 21:30。

你躺在床上。

# diegetic_ui: phone_booking_email

手机弹出 booking 确认邮件。

```
Booking Confirmation
5 月 12 日 14:35 PEK → NRT
单程经济舱
人民币 ¥2,847
```

_5 月 12 日。东京。_

_我微信头像是 5 年前去日本旅游的富士山。_

_那时候我以为我会再去。_

_后来 N+1 那笔钱用完了。后来疫情。后来房贷。_

_后来 8 年。_

_今晚我点了支付。_

_**8 年了。**_

_**我以为我会再去。**_

_**我会去的。**_

_**这次。**_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// happy_ending_lisa_blessing — Variant C Lisa 客户成功部祝福
// ----------------------------------------------------------------------------
// 触发: S3 finale 路径 A (Lisa 留转岗客户成功部) + S5+ 笑天接到 Lisa 至少 2 条微信
// E52 春节假期前一天 / 春节
// Verbatim 必保:
//   - Lisa "笑天, 新年快乐。我妈说今年留我在家多待几天。你回去了吗?" 笑天 "回去了。" Lisa "好。"
//   - 笑天 voice "她还会'好'。"
// ----------------------------------------------------------------------------

=== happy_ending_lisa_blessing ===
# scene: home_evening_e52_eve
# time: e52_chinese_new_year_eve
# speaker: protagonist

# diegetic_ui: phone_wechat_message

E52 春节除夕。

微信新消息:

# speaker: lisa
Lisa (客户成功部):

# speaker: lisa
"笑天, 新年快乐。"

# speaker: lisa
"我妈说今年留我在家多待几天。"

# speaker: lisa
"你回去了吗?"

# speaker: protagonist
你回: "回去了。"

# speaker: lisa
Lisa: "好。"

# speaker: protagonist

_她还会"好"。_

_S3 末她转岗客户成功部, 跟林姐。_

_她现在在新部门, 不在 product team。_

_她没在朋友圈宣布"开启新阶段"——她只是 quietly 在那。_

_她过年留在家, 妈妈让她多待几天。_

_她跟我"好"——一个字。_

_S1 她"明天见"。S2 她"嗯"。S3 她"谢谢笑天"。今晚她"好"。_

_她 vocabulary 没增加, 但每个字越来越短。_

_她还在。_

_她过得 OK。_

_她跟我说"好"——这是她对我最大的 generosity。_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// happy_ending_called_chen_ge — Variant D 新人叫"陈哥"
// ----------------------------------------------------------------------------
// 触发: S5 后实习生 score ≥ +10
// E52 假期前 / 春节
// Verbatim 必保:
//   - 实习生小张 "陈哥新年快乐! 明天什么时候到公司啊?" 笑天 "早。"
//   - 笑天 voice "陈哥。不是天哥。是陈哥。我成了 David。不算多。但算个变化。"
// ----------------------------------------------------------------------------

=== happy_ending_called_chen_ge ===
# scene: home_evening_e52_eve
# time: e52_chinese_new_year_eve
# speaker: protagonist

# diegetic_ui: phone_wechat_message

E52 春节假期最后一晚。

微信新消息: 实习生小张。

小张: "陈哥新年快乐!"

小张: "明天什么时候到公司啊?"

# speaker: protagonist
你回: "早。"

_**陈哥。**_

_**不是天哥。**_

_**是陈哥。**_

_David 当年叫我"天哥"——暗讽。_

_S5 实习生入职第 1 周 第一次叫我"陈哥"——不暗讽, 是默认。_

_他没读过我跟 David 的 history。他默认我是"前辈"。_

_我对他来说是"陈哥"——一个有 5 年司龄的中年男人。_

_**我成了 David。**_

_我也开始"挽袖子的衬衫"了吗——_

_没有。_

_我还穿灰色 polo。_

_但小张叫我陈哥。_

_**不算多。但算个变化。**_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// happy_ending_office_quiet — Variant E 办公室空了
// ----------------------------------------------------------------------------
// 触发: 12 个月内 NPC scores 累积 < +50 (cynical 玩家 — 很少帮人)
// E51 周五最后离开办公室那天
// Verbatim 必保:
//   - 笑天 voice "整层楼只剩笑天一个。风扇声。安静真好。我活过了。"
// Pillar 3 极致——他没赢, 他也没"建立连接"。他只是 outlasted everyone。
// ----------------------------------------------------------------------------

=== happy_ending_office_quiet ===
# scene: office_friday_evening_empty
# time: e51_friday_late
# speaker: protagonist

E51 周五。春节假期前最后一天上班。

下午 4 点公司发"春节红包"——68 元微信红包。

5 点。同事们都走了。

5:30。Lisa 工位空 (S3 末她已经转岗 / 走)。David 工位空 (S6 末他已经燃尽离职)。王总监独立办公室空 (S9 末他已经被换)。Vivian 不在前台。Zoe 不在 HR 工位。

你的工位区——

整层楼只剩你一个。

# diegetic_ui: ambient_office_silent

只剩**风扇声**。

打印机的待机灯在闪。

茶水间的咖啡机仍然故障——10 个月。

你站起来收东西。

你看了一眼工位上前任员工留下的小绿萝——它还活着。

# speaker: protagonist

_S1 我以为它走了我还在。_

_S13 我还在。它也还在。_

_整层楼只剩笑天一个。_

_**风扇声。**_

_**安静真好。**_

_**我活过了。**_

# pagebreak

-> END


// ----------------------------------------------------------------------------
// happy_ending_same_party — Variant F 同学聚会装病装得好
// ----------------------------------------------------------------------------
// 触发: 12 个月全部 KPI 达标 + 至少 6 个月用了"装病请假" 卡
// E52 周五同学聚会
// Verbatim 必保:
//   - 老同学 "你们那家公司听说裁员了。" 笑天 "是。我没被裁。" 老同学 "厉害。" 笑天 "不厉害。我装病装得好。"
//   - 笑天 voice "这是这 12 个月第一次有人觉得我厉害。哪怕原因是装病。"
// ----------------------------------------------------------------------------

=== happy_ending_same_party ===
# scene: restaurant_round_table
# time: e52_friday_dinner
# speaker: protagonist

E52 周五。同学聚会。某家湘菜馆包间。

10 个老同学围一桌。

老同学 A 端着酒杯, 转向你。

# diegetic_ui: dialogue_at_dinner

老同学 A: "诶兄弟, 你那家公司——"

老同学 A: "**听说裁员了。**"

# speaker: protagonist
你: "**是。我没被裁。**"

老同学 B: "怎么躲过的?"

老同学 A: "**厉害。**"

# speaker: protagonist
你: "**不厉害。**"

# speaker: protagonist
你: "**我装病装得好。**"

全桌笑。

A 给你倒了一杯酒。

# speaker: protagonist

_他们都笑了。_

_他们以为我在自嘲。_

_我没有。_

_我装病装得好——是 12 个月里最 sustainable 的 strategy。_

_医保报销 + 体检报告"轻度脂肪肝" + 公司 HR 对装病的 tolerance threshold——_

_我都研究过。_

_我装一次能 buy 1 周 KPI buffer。_

_12 个月我装了 6 次——每 2 个月 1 次, 不密不疏。_

_**这是这 12 个月第一次有人觉得我厉害。**_

_**哪怕原因是装病。**_

# pagebreak

-> END


// ============================================================================
// EOF endings.ink
// ============================================================================
//
// 11 ending knots 完成度:
//   - GO 1: game_over_too_sick (sick_count >= 7)
//   - GO 2: game_over_appearing_unsuitable (S1-S3 早期, 王总监+Zoe verbatim)
//   - GO 3: game_over_last_in_line (S4-S7 中期, 王总监+Zoe verbatim)
//   - GO 4: game_over_org_restructure (S8-S11 后期, Zoe verbatim "岗位被合并")
//   - GO 5: game_over_promoted (S12/E48 终极, 王总监+笑天 voice "恭喜晋升 / 我早就知道")
//   - Happy A: happy_ending_mom (verbatim 妈妈"瘦了" + 笑天 "不多但算我赢一次")
//   - Happy B: happy_ending_japan_ticket (verbatim 笑天 "8 年了 ... 我会去的 ... 这次")
//   - Happy C: happy_ending_lisa_blessing (verbatim Lisa 微信 + 笑天 "她还会'好'")
//   - Happy D: happy_ending_called_chen_ge (verbatim 小张 + 笑天 "陈哥不是天哥...")
//   - Happy E: happy_ending_office_quiet (verbatim 笑天 "风扇声。安静真好。我活过了。")
//   - Happy F: happy_ending_same_party (verbatim 老同学+笑天 "我装病装得好" + voice)
//
// 跟 W1 dev 协作 - TS runtime hook (per handoff §6):
//   - sick_count >= 7 → divertTo('game_over_too_sick')
//   - KPI < 50 + month <= 3 → divertTo('game_over_appearing_unsuitable')
//   - KPI < 50 + 4 <= month <= 7 → divertTo('game_over_last_in_line')
//   - KPI < 50 + month >= 8 → divertTo('game_over_org_restructure')
//   - promotion_candidate_count >= 6 → divertTo('game_over_promoted')
//   - month >= 12 + KPI 达标 → divertTo('happy_ending_<priority A→F>')
//     复合 ending TS runtime 处理顺序 (A 妈妈先 → B/C/D/E/F 叠加)
//
// END
