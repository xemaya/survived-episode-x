// ============================================================================
// Episode 9 · Week 9 · 「她穿了正装」
// ============================================================================
//
// Status: 第 1 版 (S3 ink writer 写 — W3 reuse session)
// Author: 分身 CC session (S3 Round 1)
// Last Updated: 2026-05-06
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
// 主 spec: design/vertical-slice/season-3-arc.md §5 E9 beat sheet
//        + season-3-arc-round-2-reply.md addenda
//
// 设计目标 (摘要 from season-3-arc.md):
//   1. S2→S3 cliffhanger 兑现 — Lisa 穿正装上班 (A 升级 First Impression layer 2)
//   2. 4 个 quiet sign 累积 (正装 + 文件夹 + 微信状态空白 + 桌下手心没写"加油" + 朋友圈"想换换")
//   3. 王总监 push 升级 — 周一站 Lisa 工位旁 + 周三晨会眼神扫 Lisa 3 次
//   4. 5:5 笑泪持平 — Lisa 穿正装反差 + 王总监"你最近不一样啊" 笑点 / 1 个轻扎 = 文件夹
//   5. Cliffhanger 至 E10: Lisa 朋友圈 "也好，我自己也想换换" 配图文件夹特写
//
// 红线 (S3 不能做 - per season-3-arc.md §11):
//   - Lisa 不能在 E9/E10/E11 决定走或留 (E12 finale)
//   - 王总监不能直接对 Lisa 讲"你不适合" (Zoe 工作 / 月度面谈)
//   - 老周 S3 对话 = 0 (E9 仅"抬头看一眼"是唯一非沉默动作)
//   - 林姐 S3 不出场 (仅 E12 路径 A)
//   - David S3 不能燃尽 (S6 finale)
//   - Lisa 完整 backstory 不能 expose
//
// Verbatim quotes 必保留 (per season-3-arc.md §7):
//   - E9 周一: 王总监 "**你最近不一样啊**"
//   - E9 周日: Lisa 朋友圈 "**也好，我自己也想换换**"
//
// ============================================================================

INCLUDE episode-1.ink

// E9 entry
-> episode_9


// ============================================================================
// Episode 9 主入口
// ============================================================================

=== episode_9 ===
# scene: home
# time: monday_morning_week_9
# pagebreak
-> day_57_morning_briefing


// ============================================================================
// Day 57 · 周一 · 第 9 周第 1 天 · ★ Lisa 穿正装 ★
// ============================================================================
// 关键 beat:
//   - S2→S3 cliffhanger 兑现: Lisa 穿正装外套 (不是 polo)
//   - 王总监站在 Lisa 工位旁等 "Lisa 啊…你最近不一样啊" (verbatim)
//   - 笑天看到 Lisa 桌上牛皮纸文件夹 + 周日邮件 cross-check 没客户
//   - 老周 S3 第一次抬头看一眼笑天 (唯一非沉默动作)

= day_57_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:14
# weather: cleared

闹钟响了 1 次。

_新月份。S2 末通报 5/30 已过, 下月 threshold 又涨了 N% (路径 A=18% / B=5% / C=5% / D=3% / E=1%)。_

_我不知道具体是几, 我的脑子还没接受。又一个月。_

_S2 末 Lisa 微信"我可能要走" + "但 Zoe 说下个月再看看, 我可能不该太担心"。_

_她假装乐观。_

_今天周一 6/1。她会怎么样?_

# scene: subway_carriage
# time: 8:30

地铁 10 号线换 6 号线。今天有阵风。

你看一眼地铁电视。屏幕滚动: "本月 A 股下跌 1.2%。" "全市新房成交 2876 套, 同比下降 14.3%。"

_2876 套。比上个月少 338 套。_

_老板的 D 轮还没过会。融资寒潮在加深。_

_我的下月 threshold 在涨。我和市场反向走。_

# scene: office_entrance
# time: 9:14
# npc: vivian_at_reception
# prop: fruit_bowl_apple

9:14 到公司。打卡机响了一下。**比 9:00 整晚 14 分钟**——你周一固定的精度。

# speaker: vivian
Vivian: "嗨～来啦～"

水果盘**仍是苹果**——苹果周连续 9 周。

~ fruit_bowl = "apple"

_S1 月初是苹果, S1 中变草莓 (老板演融资), S2 全 apple, S3 第 1 周还是 apple。_

_融资 9 周没新进展。_

# prop: poster_year_end_benefits_removed

打卡台旁边——

S2 末贴的"年终福利预告"海报**今天没了**。

_预告撤掉了。_

_老板施压 Vivian 撤了。_

_或者过了 deadline。_

_或者老板心情不好。_

* [开始今日]
    -> day_57_event_1_lisa_in_suit


// ----------------------------------------------------------------------------
// Event 57.1 · Lisa 穿正装 · 9:18 (★ S2→S3 cliffhanger 兑现 ★)
// ----------------------------------------------------------------------------
// 触发: 进入工位区
// 速度: 长 (~14 行)
// 同框: Lisa + 王总监 (站工位旁等) + David (看到没说话) + 笑天
// NPC archetype: Lisa A 升级 First Impression layer 2 — visual identity 重置
// Verbatim: 王总监 "你最近不一样啊" 必保留
// ----------------------------------------------------------------------------

= day_57_event_1_lisa_in_suit
# scene: workstation_entry_with_lisa_in_suit
# time: 9:18
# npc: lisa_in_black_blazer
# npc: wang_standing_at_lisa_desk
# npc: david_at_desk_glancing_then_typing
# prop: lisa_workstation_with_brown_kraft_folder

你走到工位区。

A 区——Lisa 工位斜对角。

你看了一眼——

她在工位。

**她穿正装外套**。

黑色西装外套, 不是她平时的灰色 polo。里面是白色衬衫, 不是 polo 的圆领。

_她从来不穿正装。_

_S1 第 1 周到 S2 第 8 周, 她只穿 polo——灰色 / 深色, 偶尔换浅色。_

_今天她穿外套。_

# scene: workstation_corner_with_wang_standing

王总监**站在 Lisa 工位旁**——比 S2 D29 王总监站笑天工位旁更早。

他没看你。他在等 Lisa。

Lisa 9:14 到, 王总监已经在那。

Lisa 抬头, 看到王总监。

她笑了一下——是僵硬的"职业微笑", 不是平时的笑。

# speaker: wang_director
王总监："Lisa 啊…"

王总监 0.5 秒。

# speaker: wang_director
"**你最近不一样啊。**"

5 个字。

# speaker: lisa
Lisa："啊, 刚换了件外套。"

# speaker: wang_director
王总监："好好好。"

他点了点头, 转身走了。

他没坐下来聊, 没问 KPI, 没 push deliverable。

他只是来**确认**的。

_他 confirm 了她"换了"。_

_他不知道她为什么换。_

_他知道也不会问。_

_他只是 register。_

# scene: workstation_with_david_visible

你余光瞥到 David 工位——他**抬头看了 Lisa 一眼**, 然后**没说话**, 低头继续敲键盘。

_David 看到了。但他没说"哎你今天好正式啊"。_

_他这种平时把"嗨兄弟周末过得怎样" 说 4 次的人, 今天**没问 Lisa**。_

_他不问是因为他**也察觉到这是 signal**。_

_S2 E7 Lisa 剪短发那次他也没问。_

_他第二次没问。_

_第二次的"没问" 比第一次重——他在 register 这是 pattern。_

你坐到自己工位。

# prop: lisa_workstation_with_brown_kraft_folder_close

你回头看 Lisa 工位——

她桌上**多了一个牛皮纸文件夹**。

A4 大小, 牛皮纸色, 没标签。

她奶茶杯不在了——今天她**用保温杯**。

_文件夹。_

_她平时只有电脑 + 奶茶杯 + 玩偶。今天多了文件夹。_

_文件夹里能装什么——_

_合同。简历。试用期评估表。离职申请。_

_4 种可能。_

_3 种都是"准备走"。_

# diegetic_ui: phone_email_check

你打开企业邮箱——周日邮件 cross-check 客户来访通知。

**没有客户来访通知**。

_她说"今天有客户来"是骗王总监的。_

_或者她跟王总监说的是另一件事我没听到。_

_或者她**为自己**穿正装——她想试一下穿正装的感觉。_

* [她正装挺好看]
    # speaker: lisa
    Lisa："谢谢哈。"
    _她转回工位, 表情没松。她在维持职业微笑——比平时的笑更像演。_
    ~ lisa_score = lisa_score + 2

* [今天有事啊]
    # speaker: lisa
    Lisa："嗯, 客户那边的事。"
    _她的"嗯" 是 0.5 秒延迟——她在想要不要展开。她没展开。_
    ~ lisa_score = lisa_score + 1

* [不说话, 坐下]
    # speaker: lisa
    Lisa 没看你——她已经低头开 PPT。
    ~ lisa_score = lisa_score + 0

-

- _不论选什么。_
- _她周一穿正装。_
- _S1 14 周她只穿 polo。S2 8 周她只穿 polo + 偶尔加帽子。S3 第 1 周第 1 天她穿外套。_
- _visual identity 重置。_
- _她在准备**面试** / **见 HR 高层** / **见客户成功部林姐**。_
- _3 种都对。_
- _我不会问。_

// hidden flag: Lisa D57 穿正装 + 牛皮纸文件夹 - S3 quiet sign #1+#2 累积起步
// hidden flag: 笑天意识到 Lisa 在准备走流程

~ check_state_after_choice()
-> day_57_event_2_lao_zhou_glance


// ----------------------------------------------------------------------------
// Event 57.2 · 老周 S3 第一次抬头看一眼笑天 · 11:30
// ----------------------------------------------------------------------------
// 触发: 第 3 个 event
// 速度: 闪 (~5 行)
// 同框: 老周 + 笑天
// NPC archetype: 老周 S3 唯一非沉默动作 (per outline §3.9)
// 设计禁忌 (per npcs.md §8): 老周 0 dialog, 仅 0.3 度点头 升级到"抬头看一眼"
// ----------------------------------------------------------------------------

= day_57_event_2_lao_zhou_glance
# scene: corner_workstation_lao_zhou
# time: 11:30
# npc: lao_zhou_facing_window_then_glance_up

11:30。你去打印机取一份纸。

老周还在。

他面对窗户, 看 Excel——同 14 周一致。

3 个茶杯, "过完今天" 便利贴, 中间那杯刚泡——同 S2 E7 D45 一致 (8:00 到 baseline)。

你站在他工位旁等打印机。

老周——**抬头**。

他**看了你一眼**。

不是 0.3 度点头那种。是**正视**——他的眼睛对上你的眼睛。

0.5 秒。

他低下头, 继续看 Excel。

_S1 E1-E4 他从不抬头。_

_S1 E3 他唯一对话"过完今天" 后他低头。_

_S2 E5-E8 他不抬头。_

_S2 E7 我 retry 时他给 0.3 度点头, 不抬头。_

_S3 第 1 周第 1 天周一 11:30——他抬头看了我一眼。_

_他**知道** Lisa 穿正装。_

_他**知道** Lisa 桌上文件夹。_

_他什么都不会说。但他抬头了。_

_他的"抬头" 是 12 年沉默 elder 的 maximum acknowledgment。_

_他是这家公司里 silent witnesses。他和李阿姨。_

// 没有选项 - 老周 S3 唯一非沉默动作

// hidden flag: 老周 D57 抬头看笑天一眼 - S3 唯一非沉默动作 (S3 后续仍 0 dialog)

~ check_state_after_choice()
-> day_57_event_3_lisa_wechat_status


// ----------------------------------------------------------------------------
// Event 57.3 · Lisa 微信状态从"在公司" 改成空白 · 14:00
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 闪 (~4 行)
// 同框: Lisa (背景) + 笑天 (查看微信)
// 设计意图: Lisa quiet sign #3 — 她在 erase 自己的 visible identity
// ----------------------------------------------------------------------------

= day_57_event_3_lisa_wechat_status
# scene: workstation_with_phone_check
# time: 14:00
# diegetic_ui: phone_wechat_status_check

14:00。你回工位拿手机。

你顺手刷微信——

# speaker: lisa
Lisa 状态: **空白**。

S2 E6 D49 她从"忙" 改成空白——她当时在 prep "我可能要走"。

S2 E8 D55 她维持空白。

S3 第 1 周第 1 天她**还是空白**。

_S1 她的状态总是"在公司"。_

_S2 第 1 周改"忙"——她在 broadcast 状态。_

_S2 E6 D49 改空白——她在隐身。_

_S3 第 1 周还是空白——她在保持隐身。_

_她不再 broadcast 任何状态——因为她要离开。_

// 没有选项 - quiet sign #3

// hidden flag: Lisa D57 微信状态空白 - S3 quiet sign #3 (continuity from S2)

~ check_state_after_choice()
-> day_57_event_4_lisa_no_client


// ----------------------------------------------------------------------------
// Event 57.4 · 没客户来访 · 16:30
// ----------------------------------------------------------------------------
// 触发: 第 6 个 event
// 速度: 闪 (~3 行)
// 同框: Lisa (背景, 仍在敲) + 笑天
// 设计意图: 笑天再次 cross-check —— 整个下午没人来公司大门接客户
// ----------------------------------------------------------------------------

= day_57_event_4_lisa_no_client
# scene: workstation_afternoon_check
# time: 16:30
# npc: lisa_typing_in_kraft_folder_glance

16:30。你站起来去打印机。

你经过前台——Vivian 在打卡台。

你瞥了一眼——

**没人来访登记**。

_整个下午没人接客户。_

_她说"今天有客户来" 是给王总监的话术。_

_或者王总监根本没在意——他知道她在装也无所谓。_

_他要的是流程走完, 不是 truth。_

回工位的路上, 你看 Lisa 工位——她桌上的牛皮纸文件夹**翻开了一角**。

里面是**白色 A4 纸**——你看不清字。

她注意到你看, 立刻把文件夹合上。

# speaker: lisa
Lisa 没说话。

_她在 protect 文件夹内容。_

_她周一今天的 visual signals 已经完整: 正装 + 文件夹 + 微信空白 + 没客户。_

_她不再相信她能瞒。_

_但她也不会主动告诉我。_

// 没有选项 - quiet sign 完成

~ check_state_after_choice()
-> day_57_after_work


// ----------------------------------------------------------------------------
// after_work · Day 57 下班 · 17:30
// ----------------------------------------------------------------------------

= day_57_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_still_at_desk_in_suit_jacket

17:30。

Lisa 还在工位——她没换回 polo。她**穿外套加班**。

David 17:30 准时走——他这周一也准点。

* [申报加班]
    你回工位多干一会。Lisa 没看你。
    _她改 PPT 改到几点不清楚, 但她下午开了 4 次同样的文件夹。_
    ~ state = state - 10
    ~ kpi = kpi + 5
    ~ effort_overage = effort_overage + 1

* [按时下班]
    你收拾东西。Lisa 没回头。
    _她没说"明天见"。_
    ~ lisa_score = lisa_score + 0

* [提前下班]
    你 17:00 关电脑走人。
    Lisa 还在敲键盘。
    ~ effort_overage = effort_overage - 1

-

~ check_state_after_choice()
# pagebreak
-> day_57_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 57 周一日报
// ----------------------------------------------------------------------------

= day_57_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - ★ **Lisa 穿正装外套** (S2→S3 cliffhanger 兑现 + A 升级 First Impression layer 2)_
_  - **王总监站 Lisa 工位旁 verbatim "你最近不一样啊"** (5 字)_
_  - Lisa 桌上**牛皮纸文件夹** (quiet sign #2 起步)_
_  - 老周**抬头看笑天一眼** (S3 唯一非沉默动作)_
_  - Lisa 微信状态空白 (quiet sign #3 continuity)_
_  - 没客户来访 — Lisa 撒谎给王总监_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_58_morning_briefing


// ============================================================================
// Day 58 · 周二 · David 茶水间"你看 Lisa 最近, 有点不对啊"
// ============================================================================
// 关键 beat:
//   - David 第一次注意到 Lisa 有问题 — 但他不是关心
//   - Vivian 接电话压低声音"我马上让她去办公室"——这次是关于 Lisa

= day_58_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周二。

# scene: office_workstation
# time: 9:11
# npc: lisa_in_suit_jacket_again

9:11 到公司。

Lisa **又穿正装外套**——同周一的那件。

她周二也穿。**这是 pattern, 不是 one-off**。

_她周一不是为了王总监演——她在 maintain identity 重置。_

_她每天都会穿到 finale。_

* [开始今日]
    -> day_58_event_1_david_notices


// ----------------------------------------------------------------------------
// Event 58.1 · David 茶水间"你看 Lisa 最近, 有点不对啊" · 14:30
// ----------------------------------------------------------------------------
// 触发: 第 4 个 event
// 速度: 长 (~10 行)
// 同框: David + 笑天
// NPC archetype: David S3 第一次注意到 Lisa
// 设计意图: David 不是关心, 他在判断 "Lisa 走了我位置会不会调整"
// ----------------------------------------------------------------------------

= day_58_event_1_david_notices
# scene: break_room_with_david
# time: 14:30
# npc: david_with_disposable_cup_again

14:30。你去茶水间接水。

David 在茶水间——他**用一次性杯子**(他保温杯不在)。他今天泡的是速溶咖啡, 不是枸杞茶。

他靠在墙上, 看到你, 凑过来。

# speaker: david
David: "兄弟, 问你个事。"

# speaker: david
他压低声音: "你看 Lisa 最近, **有点不对啊**。"

_他第一次说出来。_

_S2 E7 Lisa 剪短发他没说话。S2 E8 王总监表扬 Lisa 他没接话。_

_S3 第 1 周第 2 天他说"有点不对"。_

_他到第 9 周才看出来。_

_我从第 5 周就看到了。_

_他不是关心——他在判断"Lisa 走了我的位置会不会调整"。_

_他想从我这套话。_

* [她最近确实有点忙]
    # speaker: david
    David: "嗯。她那个客户对接 PPT 还在改吧?"
    _他在 fish info——他想知道 Lisa 的 PPT 进度, 因为如果 Lisa 走, 那个项目可能转给他。_
    "你帮她看过没?"
    # speaker: protagonist
    你回: "我没看。"
    # speaker: david
    David: "好的好的。"
    _他端着一次性杯子走了。_
    ~ david_score = david_score + 2

* [我没注意]
    # speaker: david
    David: "啊我也是, 我就觉得她看起来累。"
    _他在 reframe — 他刚说"不对"现在改"看起来累"。_
    "可能是月底冲刺压力大吧。"
    # speaker: protagonist
    你: "嗯。"
    ~ david_score = david_score + 0

* [你管那么多干嘛]
    # speaker: david
    David: "啊好好好, 我就随便问问。"
    _他端着一次性杯子, 笑了一下, 走了。_
    _他眼神 0.3 秒的失落——但马上恢复。_
    "兄弟你周末过得不错啊。"
    _他换话题。_
    ~ david_score = david_score - 3

-

- _不论选什么。_
- _他到第 9 周才注意到。_
- _他注意到也只是为了自己的位置。_
- _Lisa 走 = David 位置可能调整 = David 想知道。_
- _他没在 Lisa 桌上看她文件夹。他不在乎细节。_
- _他在乎 macro outcome。_

// hidden flag: David D58 第一次注意到 Lisa 有问题 - 不是关心是判断

~ check_state_after_choice()
-> day_58_event_2_vivian_phone


// ----------------------------------------------------------------------------
// Event 58.2 · Vivian 接电话"我马上让她去办公室" · 15:45
// ----------------------------------------------------------------------------
// 触发: 第 5 个 event
// 速度: 标准 (~6 行)
// 同框: Vivian (远端电话) + 笑天
// 设计意图: Vivian leak — 她做了 6 年前台, 选择性 leak
// ----------------------------------------------------------------------------

= day_58_event_2_vivian_phone
# scene: workstation_corridor_with_reception_audio
# time: 15:45
# npc: vivian_on_phone_lowered_voice

15:45。你去打印机。

经过前台区域——Vivian 在接电话。

她平时讲电话很大声。

她今天**压低声音**——但没压到完全听不见。

# speaker: vivian
Vivian: "是是是, 老板。"

# speaker: vivian
"嗯, 我了解。"

# speaker: vivian
"**我马上让她去您办公室。**"

5 秒间隔。

# speaker: vivian
"是 Lisa 同学是吧? 嗯。"

她挂了电话。

_"Lisa 同学"。_

_S2 末 Zoe 叫 Lisa "Lisa 同学" 1 次。_

_今天 Vivian 也叫 "Lisa 同学"。_

_"Lisa 同学" 是 HR + 行政 在内部 reframe Lisa 身份的话术——把她从"同事" → "员工" → 准备 → "离职者"。_

_3 阶段身份变化已经开始。_

# scene: corridor_back

你回工位的路上瞥了一眼 Lisa 工位——她还在敲。她**没接到 Vivian 的通知**。

_Vivian 还没去找她。_

_Vivian 在 build buffer time。_

_她在 selective leak——告诉了 1 个人 (我), 还没告诉 Lisa。_

_她做了 6 年前台, 她知道 timing。_

_Lisa 可能 16:00 / 16:30 才被叫去办公室。_

// 没有选项 - leak 信号

// hidden flag: Vivian D58 leak Lisa 被老板叫去办公室

~ check_state_after_choice()
-> day_58_after_work


= day_58_after_work
# scene: workstation_evening
# time: 17:30
# npc: lisa_at_desk_after_office_visit

17:30。

Lisa 在工位——她**16:30 离开过 30 分钟**, 17:00 回来。她**穿着外套**回来的。

_她去了老板办公室。_

_30 分钟。_

_30 分钟够她听一份"我们公司目前需要的人员调整"。_

_她回来时眼睛没红。她维持得很好。_

* [申报加班]
    你回工位多干一会。Lisa 没看你。
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
-> day_58_daily_recap


= day_58_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - Lisa 周二**仍穿正装外套** (pattern 形成, 不是 one-off)_
_  - **David 茶水间"你看 Lisa 最近, 有点不对啊"** (S3 第一次注意到, 不是关心是判断)_
_  - Vivian 接电话"我马上让她去您办公室" + 叫"Lisa 同学" (HR/行政 reframe 身份话术)_
_  - Lisa 16:30-17:00 去老板办公室 30 分钟_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_59_morning_briefing


// ============================================================================
// Day 59 · 周三 · 晨会王总监眼神扫 Lisa 3 次 + 李阿姨先擦 Lisa 工位
// ============================================================================
// 关键 beat:
//   - 晨会"我们是命运共同体"——眼神扫 Lisa 3 次 (S1=1次/S2=2次/S3=3次累积)
//   - Lisa 桌下手心**没写**"加油" (motif 在 S2 消失, S3 还没复活)
//   - 周三早晨李阿姨**先擦 Lisa 工位** (她不按工位顺序擦)

= day_59_morning_briefing
# scene: home_then_subway_then_office
# time: 8:30_to_9:25
# weather: rainy

周三。下小雨。

~ weather = "rainy"

# scene: office_corridor_passing
# time: 9:00
# npc: li_ayi_pushing_mop_cart

9:00 到公司。

经过工位区——李阿姨在擦工位。

她推着拖把车, 戴着橡胶手套。

她今天**没按工位顺序**——她平时是 A 区 → B 区 → C 区 顺序擦。

今天她**先擦 Lisa 的工位**。

她**没说话**——她从不说话。

但她拖把过 Lisa 桌底时, 多停了 0.3 秒。

_她也知道。_

_S3 第 1 周她和老周一起 silent witnessing。_

_她没说话。她只是**先擦了**——这就是她唯一能做的"acknowledgment"。_

# scene: meeting_room
# time: 9:25
# npc: lisa_in_first_row_in_suit
# npc: david_with_okr_planner
# npc: lao_zhou_in_back_with_tea

9:25 到会议室。

Lisa 第一排——她**正装外套** still on。

David 笔记本贴新便利贴 "**Q2 final 月**"。

老周后排, 中间那杯茶。

9:32 王总监推门。

* [开始今日]
    -> day_59_event_1_morning_meeting_command


// ----------------------------------------------------------------------------
// Event 59.1 · 晨会"我们是命运共同体" + 眼神扫 Lisa 3 次 · 9:35
// ----------------------------------------------------------------------------
// 触发: 晨会进行中
// 速度: 长 (~14 行)
// 同框: 王总监 + David + Lisa + 老周 (背景) + 笑天
// 设计意图: S1=1 次 / S2=2 次 / S3=3 次 累积显形 - 王总监 cue Lisa 频率递增
// ----------------------------------------------------------------------------

= day_59_event_1_morning_meeting_command
# scene: meeting_room_full
# time: 9:35
# npc: wang_at_podium_eye_scan
# npc: lisa_taking_notes
# npc: david_first_to_react
# npc: lao_zhou_drinking_tea_silent

王总监打开 PPT。今天封面是"**S3 月度 KPI 启动会**"。

# speaker: wang_director
"上午好啊各位。"

# speaker: wang_director
"**我们是命运共同体。**"

_我们是命运共同体。_

_他每月开场都是这一句。_

_S1 4 次。S2 4 次。S3 第 1 次还是。_

_他用同一句话开 9 个月会议。_

_我开始相信他真的相信"命运共同体"——不是他装的, 他从他老板那里学来 + 他真的没有别的话术。_

_他是空心的 puppet。_

# speaker: wang_director
"上个月 KPI 整体好的——我跟上面也提过了。但是我们要清醒, **下个月 KPI 阈值已根据本月表现调整**。"

_threshold 涨了。_

_数字他会在群里发, 我下午看。_

_S1 finale 5 路径阈值 +10%/+5%/+5%/+3%/+1%。S2 finale +5%/+5%/+5%/+3%/+1% (全员降一档)。S3 finale 涨多少 finale 周日才知。_

# speaker: wang_director
"David 上个月 deliverable 100% 完成确认。"

# speaker: david
David: "嗯。"

王总监**眼神扫过 Lisa 工位方向** (第 1 次)——她在记笔记。

# speaker: wang_director
王总监: "Lisa 这边 PPT 怎么样了？"

# speaker: lisa
Lisa: "在赶。"

# speaker: wang_director
王总监: "嗯。"

王总监**眼神扫过 Lisa 工位方向** (第 2 次)——她低头记笔记。

# speaker: wang_director
"我们这个团队啊, 是有未来的。"

王总监**眼神扫过 Lisa 工位方向** (第 3 次)——这次扫的不是 Lisa 本人, 是她**身后空着的工位** (Vivian 还没来)。

_3 次。_

_S1 我以为是巧合。_

_S2 我看出他扫 2 次。_

_S3 他扫 3 次, 但第 3 次他扫的是 Lisa **身后**——他在 visualize "她离开后那里空" 的 picture。_

_这是 S3 王总监 push 升级的最 silent 证据——他的 mental model 已经在 prep "Lisa 离开"。_

# speaker: wang_director
"散会。"

8 分钟。

_8 分钟散会。但那 3 次眼神扫 Lisa 工位, 我会跟一周。_

// 没有选项 - 王总监 cue Lisa 升级 + 眼神扫 3 次

// hidden flag: 王总监 D59 眼神扫 Lisa 工位 3 次 (S1=1次/S2=2次/S3=3次累积)

~ check_state_after_choice()
-> day_59_event_2_lisa_no_jiayou


// ----------------------------------------------------------------------------
// Event 59.2 · Lisa 桌下手心**没写**"加油" · 9:42
// ----------------------------------------------------------------------------
// 触发: 散会回工位
// 速度: 闪 (~5 行)
// 同框: Lisa + 笑天 (经过看到)
// 设计意图: motif 缺席 — S1 motif "加油" 在 S2 消失, S3 还没复活 (E11 才复活)
// ----------------------------------------------------------------------------

= day_59_event_2_lisa_no_jiayou
# scene: workstation_back
# time: 9:42
# npc: lisa_writing_in_notebook

9:42 回工位。

Lisa 直接坐下。

她左手放在桌下——

**手心是空的**。

她**没写**"加油"。

_S1 E2 D10 周三晨会王总监讲"潜力 = 你今天的最好成绩是明天的最低标准" 时, Lisa 桌下手心写"加油"。_

_S2 第 1 周她不写。S2 第 8 周她不写。_

_S3 第 1 周第 3 天她**还是不写**。_

_她以前需要"加油"——是因为她相信"加油" 能 help。_

_她现在不写——是因为她不再相信。_

_或者她已经过了"加油" 的 stage——她在准备走, 不在准备"撑住"。_

_S1 motif 死。_

// 没有选项 - motif 缺席的强烈信号

// hidden flag: Lisa D59 桌下手心没写"加油" - S1 motif 死 (S3 不复活)

~ check_state_after_choice()
-> day_59_after_work


= day_59_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在改 PPT, 穿外套。

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
-> day_59_daily_recap


= day_59_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - 早晨李阿姨**先擦 Lisa 工位** (silent witnessing)_
_  - 晨会王总监**眼神扫 Lisa 工位 3 次** (S1=1/S2=2/S3=3 累积)_
_  - Lisa 桌下手心**没写"加油"** (S1 motif 死, S3 不复活)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_60_morning_briefing


// ============================================================================
// Day 60 · 周四 · 笑天 偷听 Zoe "下周三签字"
// ============================================================================
// 关键 beat:
//   - 笑天经过 HR 工位偷听 Zoe 跟另一个 HR："Lisa 那边走完吗？" "下周三签字"
//   - 笑天意识到时间表已经定了——但 Lisa 不知道

= day_60_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:11
# weather: cleared

周四。雨停了。

# scene: office_workstation
# time: 9:11
# npc: lisa_in_suit_jacket_third_day

9:11 到公司。

Lisa **第 3 天穿正装**。

她**奶茶杯回来了**——她今天又用奶茶杯。她中午可能拼奶茶。

_她在 partial 还原她平时的 ritual——这是她在 maintain face value。_

_她不能太瘦, 不能太累——她要 hold up 直到 finale。_

* [开始今日]
    -> day_60_event_1_zoe_eavesdrop_walkin


// ----------------------------------------------------------------------------
// Event 60.1 · 偷听 Zoe + 另一个 HR · 11:30 (S3 第 1 个真扎点)
// ----------------------------------------------------------------------------
// 触发: 第 3 个 event
// 速度: 长 (~10 行)
// 同框: Zoe + 另一个 HR + 笑天 (远端听到)
// 设计意图: 时间表已定 — Lisa 不知道 (笑天独自负担信息)
// ----------------------------------------------------------------------------

= day_60_event_1_zoe_eavesdrop_walkin
# scene: hr_workstation_corridor
# time: 11:30
# npc: zoe_at_desk_with_another_hr

11:30。你去 HR 工位区办其他手续——你 S2 末注册的 medical insurance 年审。

经过 HR 工位——Zoe 跟另一个 HR 在低声说话。

你刷工牌验证 medical insurance, 等系统响应——你站在 Zoe 工位 2 米开外。

她们没看你。

# speaker: zoe
Zoe: "Lisa 那边走完吗？"

# speaker: zoe
另一个 HR: "**下周三签字。**"

# speaker: zoe
Zoe: "正式 offer 给客户成功部那边了吗?"

# speaker: zoe
另一个 HR: "等王总监跟林姐对接, 这周内。"

# speaker: zoe
Zoe: "好。我去通知她。"

她们继续低声说话, 但你已经听到 enough。

_下周三签字。_

_今天周四 6/4。下周三 = 6/10。_

_6 天后 Lisa 签字。_

_客户成功部 + 林姐 = 路径 A 转岗预案。_

_Zoe 还没通知 Lisa——但 Zoe 说"我去通知她"。_

_她可能下周一通知。_

_Lisa 不知道时间表已经定了。_

_我知道。_

_我不会告诉她。_

_告诉她 = 她会快速 escalate / 她可能崩 / 我可能被 Zoe 记 1 笔"out of bound"。_

_我成了 silent witness 第 3 个——李阿姨 + 老周 + 我。_

# scene: corridor_back

medical insurance 系统响应。你拿着确认单走开。

_我经过 Lisa 工位时她没看我。_

_她不知道我刚听到她的时间表。_

// 没有选项 - 信息不对等的高峰

// hidden flag: 笑天 D60 偷听到 "下周三签字" + 知道 Lisa 转岗客户成功部的 setup
// hidden flag: 笑天意识时间表已定但 Lisa 不知

~ state = state - 5   // 信息不对等的扎心

~ check_state_after_choice()
-> day_60_event_2_silence_at_workstation


// ----------------------------------------------------------------------------
// Event 60.2 · 下午静默 · 15:00
// ----------------------------------------------------------------------------
// 触发: 第 5 个 event
// 速度: 闪 (~4 行)
// 同框: Lisa (背景) + 笑天
// ----------------------------------------------------------------------------

= day_60_event_2_silence_at_workstation
# scene: workstation_afternoon_silence
# time: 15:00
# npc: lisa_typing_unaware

15:00。工位区静默。

Lisa 在敲键盘——她**还在改 PPT**。

她不知道 6 天后她要签字。

她以为她还在 try save herself。

_她在 prep 一个不会发生的 review。_

_她的 PPT 是 sunk cost。_

_她的"赶 PPT" 在 reality 里已经 irrelevant——HR 流程已经定了。_

_但她不知道。她还在打。_

// 没有选项 - 信息不对等加深

~ check_state_after_choice()
-> day_60_after_work


= day_60_after_work
# scene: workstation_evening
# time: 17:30

17:30。Lisa 还在 PPT。

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
-> day_60_daily_recap


= day_60_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_关键时刻 today:_
_  - **笑天偷听 Zoe + 另一个 HR "Lisa 那边走完吗?" "下周三签字"** (时间表已定)_
_  - 笑天意识 Lisa 转岗客户成功部 setup_
_  - 笑天成 silent witness 第 3 个 (李阿姨 + 老周 + 我)_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_61_morning_briefing


// ============================================================================
// Day 61 · 周五 · weekly_recap · Lisa 21:00 才走
// ============================================================================
// 关键 beat:
//   - weekly_recap overlay
//   - Lisa 周五 19:30 还在工位 + 21:00 才走 (背包很重)

= day_61_morning_briefing
# scene: home_then_subway_then_office
# time: 8:50_to_9:08
# weather: cleared

周五。

# scene: office_entrance
# time: 9:08
# npc: lisa_in_suit_jacket_fourth_day
# prop: fruit_bowl_apple

9:08 到公司。

Lisa **第 4 天穿正装外套**。

水果盘**苹果**。

~ fruit_bowl = "apple"

* [开始今日]
    -> day_61_event_1_weekly_recap


// ----------------------------------------------------------------------------
// Event 61.1 · weekly_recap · 16:50
// ----------------------------------------------------------------------------

= day_61_event_1_weekly_recap
# scene: workstation_phone_buzz
# time: 16:50
# diegetic_ui: phone_show_weekly_recap_overlay

16:50。HR 系统弹出周报浮层。

- 出勤率: 100%
- 主动产出条目: 取决于 D 57-60 选择
- 协作记录: 取决于本周 Lisa / David 选择

浮层底部："**本月度 KPI 还有 23 天 (周日 6/27 推送月末通报)**"。

_本月度 KPI 还有 23 天。_

_Lisa 6/10 签字 → 6 月还剩 17 天她在客户成功部 / 走完。_

_我 6/27 看 KPI Review。_

// hidden flag: D61 周五 HR 浮层 + 6/27 月末通报 setup

~ check_state_after_choice()
-> day_61_event_2_lisa_21_hour


// ----------------------------------------------------------------------------
// Event 61.2 · Lisa 21:00 才走 · 21:00
// ----------------------------------------------------------------------------
// 触发: 申报加班后留到 21:00
// 速度: 长 (~10 行)
// 同框: Lisa (前景, 收东西) + 笑天 (远端)
// 设计意图: S2 E5 D33 19:30 V11 spike → S3 D61 21:00 升级 spike
// ----------------------------------------------------------------------------

= day_61_event_2_lisa_21_hour
# scene: workstation_late_night
# time: 21:00
# npc: lisa_packing_with_heavy_backpack

如果你今天申报了加班——

~ state = state - 10

19:30 → 20:30 → 21:00。

Lisa **21:00 才站起来**。

她周一-周四加到 19:30 或 20:00。

周五她**21:00 走**——她从来没加班这么晚。

她收东西的速度比平时慢——每个动作都慢半拍。

她**包很重**——她平时背包是 1 台电脑 + 雨伞 + 一些杂物。今天**背包鼓起来**了——里面装了什么。

可能是**她从公司带走的物品**：

- 她的小玩偶
- 她的奶茶杯
- 她的话梅
- 她的眼药水

或者是**她带回家的工作**：

- 她的电脑充电器
- 她的牛皮纸文件夹

3 种可能。

她经过你工位时, 没看你。

她**穿外套走的**——她没换 polo。

# scene: workstation_after_lisa_leaves

Lisa 走后, 你看她工位——

她小玩偶**还在**桌上。

她奶茶杯**还在**桌上。

她话梅抽屉**没打开**。

_她什么都没带走——她背包鼓的是工作。_

_她 weekend 要在家继续改。_

_她在 S2 E5 D33 spike 19:30。S3 第 1 周第 5 天 spike 21:00。_

_她加班速度递增的同时, 她的 progress 没递增。_

_因为她不在 fix 一个可解决问题。她在 try save herself, 但 HR 流程已经定了。_

_她的 sunk cost 在 21:00 还在 sink。_

// 没有选项 - 21:00 spike

// hidden flag: Lisa D61 周五 21:00 才走 - S2 19:30 spike 升级

~ check_state_after_choice()
-> day_61_after_work


= day_61_after_work
# scene: workstation_evening
# time: 21:05
# npc: lisa_workstation_finally_empty

21:05。你也走人。

你出公司大门——街上有点风。

_周五晚 21:05。地球继续转动。_

_明天周末。_

_我想睡到 12 点。_

* [自己回家]
    你买了一份煎饼, 12 块。
    ~ money = money - 12
    ~ state = state + 2

~ check_state_after_choice()
# pagebreak
-> day_61_daily_recap


= day_61_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap

_今日 KPI: +{kpi}_
_今日 钱: {money}_
_今日 状态: {state}/100_

_本月度 KPI 还有 23 天 (周日 6/27 推送)_

_关键时刻 today:_
_  - HR 浮层 + 6/27 月末通报 setup_
_  - **Lisa 周五 21:00 才走** (S2 19:30 spike 升级 + 背包很重 = 工作带回家)_
_  - 周五苹果周连续 9 周_

_NPC scores:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

# pagebreak
-> day_62_weekend_morning


// ============================================================================
// Day 62 · 周六 · 周末
// ============================================================================

= day_62_weekend_morning
# scene: bedroom
# time: 12:08
# music: weekend_silence

你睡到 12:08 醒。

_S1 第 1 周 11:14, S2 第 1 周 11:14, S2 第 8 周 12:00, S3 第 1 周 12:08。_

_我每周晚 8 分钟。_

_这是我的"加速退步" baseline——比 Lisa 的"加速 push"反向走。_

# diegetic_ui: phone_wechat_moments

朋友圈：

David 发"**6 月开局 = 4 大冲刺**"——他从"4 个 4" 升级到"6 月 4 大"。

_他从 Q2 末 spinning 到 6 月 starting spinning。_

_他给自己造的 momentum 不断 reset。_

Lisa 朋友圈最新一条**还是 5/16 D42 "这周辛苦了"**。

她 21 + 14 + 14 = **49 天没发新的**。

_她 49 天 silent。_

_她周一开始穿正装, 但她没拍正装自拍发朋友圈。_

_她不再 broadcast。_

11:34 → 12:34。你点外卖：粥 + 油条 + 蛋。35 块。
~ money = money - 35

_周末就该花钱。_

* [开始今日]
    -> day_62_event_1_afternoon_quiet


= day_62_event_1_afternoon_quiet
# scene: bedroom_afternoon
# time: 14:00
# music: silence

下午 2 点。

你在床上。

你打开购物车——浅色衬衫还在 (S2 加的, 已经 12 周没买)。

_我可能下周买。_

_或者不买。_

_衬衫从 ¥189 涨到 ¥259——66 元涨幅。_

_我的 procrastination 让我多花 70 元。_

_或者衬衫永远不会被买——我每周看一次, 每周不付。_

你又躺了 30 分钟。

~ state = state + 30   // regenForRestDay

~ check_state_after_choice()
# pagebreak
-> day_62_daily_recap


= day_62_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +30)_

_关键时刻 today:_
_  - 12:08 起床 (加速退步 baseline)_
_  - David 朋友圈"6 月 4 大冲刺"_
_  - Lisa 49 天没发朋友圈_

# pagebreak
-> day_63_weekend_morning


// ============================================================================
// Day 63 · 周日 · 妈妈视频"我下个月可能不去你那" + Lisa 朋友圈"想换换"
// ============================================================================
// 关键 beat:
//   - 8:30 妈妈视频"我下个月可能不去你那边了。你姨家有事" (S2 finale 反转)
//   - 笑天微信状态"在公司"(他周日没去)
//   - 21:00 Lisa 朋友圈 verbatim "也好，我自己也想换换" 配图文件夹特写 (E9→E10 cliffhanger)

= day_63_weekend_morning
# scene: bedroom
# time: 8:23
# music: sunday_morning_quiet

周日。

你 8:23 醒。

_今天她会说什么。_

_S2 末她 verbatim "我下个月想去你那边看看你"——她第一次主动。_

_今天 6/6 周日。她下个月 = 7 月。她说要来 7 月。_

_今天她可能再说一遍。或者她已经 register 上次我的回答, 不再说。_

8:30:00 整, 微信视频铃响。

* [接通]
    -> day_63_event_1_mom_video_reverse


// ----------------------------------------------------------------------------
// Event 63.1 · 妈妈视频"我下个月可能不去你那边了" · 8:30 (S2 反转)
// ----------------------------------------------------------------------------
// 触发: 8:30 自动
// 速度: 长 (~14 行)
// 同框: 妈妈 (视频)
// NPC archetype: 妈妈 S2 finale "我下个月想去你那" 反转 — 她 backtrack
// ----------------------------------------------------------------------------

= day_63_event_1_mom_video_reverse
# scene: bedroom_video_call
# time: 8:30
# diegetic_ui: phone_video_call_active
# npc: mom_with_glasses_in_kitchen

屏幕里是妈妈。

她戴老花眼镜, 厨房油烟机背景。

# speaker: mama
妈妈："**天天, 吃了吗？**"

# speaker: protagonist
你："吃了。"

# speaker: mama
妈妈："**工资发了吗？**"

# speaker: protagonist
你："发了。"

# speaker: mama
妈妈："**那个谁的儿子结婚了。**"

# speaker: protagonist
你："嗯。"

妈妈停了一下。

她**眯眼**。

# speaker: mama
"**天天——**"

她 0.5 秒。

# speaker: mama
"**我下个月可能不去你那边了。**"

# speaker: mama
"你姨家有事我得过去几天。"

_她 backtrack 了。_

_S2 末 D56 她 verbatim "我下个月想去你那边看看你"——她第一次主动。_

_S3 第 1 周第 7 天她说"可能不去了"——她 2 周内 reverse 自己。_

_她为什么 reverse?_

_可能你姨家真的有事。可能她在过去 2 周 register 了我的回答, 自己 backtrack。_

_可能她**怕来了看到我真的不像"在大公司当 leader"**——她在 protect 她自己的 image of me。_

_她每次说要来都没来。_

_她每次说不来都会想来。_

_她在 oscillating——但 net 结果是她不来。_

* [好啊妈, 那等下次]
    # speaker: mama
    妈妈："好。妈下下次再去你那。"
    _她笑了一下, 不深。_
    "你最近怎么样?"
    # speaker: protagonist
    你: "还行。"
    ~ mom_score = mom_score + 2

* [那也好, 你姨家有事重要]
    # speaker: mama
    妈妈："嗯。"
    _她"嗯" 了一下, 0.5 秒。_
    "你姨说她朋友的女儿结婚了。"
    _她在 reframe 又一次"那个谁"。_
    ~ mom_score = mom_score + 0

* [嗯, 知道了]
    # speaker: mama
    妈妈："嗯, 你忙。"
    _她直接 cut, 比平时挂得早。_
    "妈不打扰你。"
    # speaker: mama
    她挂了视频。
    ~ mom_score = mom_score - 2

-

- _挂掉视频后你坐在床上 1 分钟。_
- _她每次说要来都没来。_
- _她每次说不来都会想来。_
- _她从来不会真的来。_
- _她是远方一个固定 8:30 的 voice。_
- _Lisa 也快是远方了。_

// hidden flag: 妈妈 D63 verbatim "我下个月可能不去你那边了" - S2 反转

~ check_state_after_choice()
-> day_63_event_2_xiaotian_status_office


// ----------------------------------------------------------------------------
// Event 63.2 · 笑天微信状态"在公司"(他周日没去) · 14:00
// ----------------------------------------------------------------------------
// 触发: 午饭后
// 速度: 闪 (~5 行)
// 设计意图: 笑天 mirror Lisa — 他也在 broadcast false status
// ----------------------------------------------------------------------------

= day_63_event_2_xiaotian_status_office
# scene: bedroom_afternoon
# time: 14:00
# diegetic_ui: phone_wechat_status_set

下午 2 点。

你在床上。

你打开微信状态——

你设了"**在公司**"。

你周日没去公司。

_你为什么设"在公司"。_

_Lisa S2 改"忙" 我以为她是 broadcast。S2 她改空白我以为她是隐身。_

_今天我设"在公司" — 我不知道为什么。_

_可能是 mirror Lisa——她周一-周五穿正装演"还在赶"; 我周日设"在公司"演"也在赶"。_

_可能是 prep 我自己周一回公司时的心态——如果 status 已经"在公司", 我周一回公司 emotionally 比较容易过渡。_

_可能是 placebo——我自己看自己微信状态会觉得"我也在拼"。_

_3 种 reading 都对。_

_我可能 3 种都在做。_

_我没去公司。我设了"在公司"。_

// 没有选项 - 笑天 mirror Lisa 的 quiet sign

// hidden flag: 笑天 D63 微信状态"在公司"(false) - 他在 mirror Lisa 的装

~ state = state + 5   // 周末轻量 regen

~ check_state_after_choice()
-> day_63_event_3_lisa_circle_post_kraft


// ----------------------------------------------------------------------------
// Event 63.3 · Lisa 朋友圈 "也好，我自己也想换换" · 21:00 (E9→E10 cliffhanger)
// ----------------------------------------------------------------------------
// 触发: 晚 21:00 自动
// 速度: 长 (~10 行)
// 同框: Lisa (朋友圈)
// 设计意图: E9→E10 cliffhanger — Lisa 49 天 silent 后第 2 次发朋友圈
// Verbatim: "也好，我自己也想换换" 必保留 (per outline §5 E9 cliffhanger)
// ----------------------------------------------------------------------------

= day_63_event_3_lisa_circle_post_kraft
# scene: home_evening
# time: 21:00
# diegetic_ui: phone_wechat_moments_alert
# npc: lisa_via_moments

21:00。你刚洗完澡。

朋友圈推送 1 条。

# diegetic_ui: phone_wechat_moments_lisa_post

# speaker: lisa
Lisa 发了 1 张图。

**配图: 她桌上的牛皮纸文件夹特写**。文件夹合着, 棕色硬纸, 没有 Logo, 没有标签。文件夹边缘有一点磨损——她用了一周。

配文：

# speaker: lisa
"**也好，我自己也想换换。**"

7 个字。

_这是 Lisa S3 第 1 条朋友圈。_

_她 5/16 D42 "这周辛苦了" 之后 49 天没发。_

_今天 6/6 D63 周日 21:00 她发"也好, 我自己也想换换"。_

_配图是文件夹——她不发自拍, 不发风景, 不发美食。_

_她发**那个文件夹**——周一开始她带文件夹上班。_

_文件夹是这一周的 visual signature。_

_"也好" — 她在自我说服。_

_"我自己也想换换" — 她在 reframe HR 决定为"她自己想换"。_

_她在 self-rationalize——把被动改成主动。_

_这是 anti-Pillar 1 的 personal version——HR 让她"调整"，她翻译成"我想换"。_

_她跟王总监一样。_

_她也在用别人的话术 reframe 自己。_

* [给 Lisa 点赞]
    你点了赞。
    _10 分钟后她又点了一个 emoji 给自己——👍。_
    _她给自己点了 1 次。_
    ~ lisa_score = lisa_score + 2

* [评论"挺好的"]
    你评论"挺好的"。
    # speaker: lisa
    Lisa 5 分钟回复"嗯"。
    ~ lisa_score = lisa_score + 3

* [私信关心]
    你私信她："嗨, 你最近还好吗?"
    Lisa 没立即回。
    20 分钟后她回："还好。就……换个环境。"
    _她说"换个环境"——她已经 register 自己要走的事实。_
    _但她对我用"换个环境" 而不是"被裁" / "走流程"——她在 protect both of us 的 face。_
    ~ lisa_score = lisa_score + 5

* [不回应]
    你看了, 没点赞, 没评论, 没私信。
    _她朋友圈这条到 22:00 共 6 个赞。_
    _你不在那 6 个里。_
    ~ lisa_score = lisa_score - 3

-

- _不论选什么。_
- _她 49 天后第 2 条朋友圈用了**自我说服**话术。_
- _S2 D42 "这周辛苦了" — self-acknowledge。_
- _S3 D63 "也好我自己也想换换" — self-rationalize。_
- _accept → reframe。_
- _她在准备走, 同时在准备**告诉自己**她想走。_
- _这 2 件事是同一件事。_

// hidden flag: E9 → E10 cliffhanger - Lisa 朋友圈 verbatim "也好我自己也想换换" + 文件夹特写

~ check_state_after_choice()
# pagebreak
-> day_63_daily_recap


// ----------------------------------------------------------------------------
// daily_recap · Day 63 周日日报 (E9 末)
// ----------------------------------------------------------------------------

= day_63_daily_recap
# scene: home_phone_screen
# diegetic_ui: phone_show_daily_recap_weekend


_今日 KPI: +0_
_今日 状态: {state}/100 (regen +12)_

_关键时刻 today:_
_  - 8:30 妈妈视频 verbatim "我下个月可能不去你那边了。你姨家有事" (S2 反转)_
_  - 笑天微信状态"在公司"(他周日没去) — mirror Lisa 的装_
_  - 21:00 Lisa 朋友圈 verbatim "也好，我自己也想换换" + 配图文件夹特写 (E9 → E10 cliffhanger)_

_NPC scores 末:_
_  Lisa {lisa_score} / David {david_score} / 王总监 {wang_score} / Zoe {zoe_score}_
_  Vivian {vivian_score} / IT 小马 {it_xiaoma_score} / 老周 {lao_zhou_score} / 妈妈 {mom_score}_

_下周一开始: 第 10 周 — Zoe 90 分钟面谈周_

// E9 结束 - cliffhanger 到 E10 周一 Lisa 桌上文件夹换新

-> END

// ============================================================================
// EOF episode-9.ink
// ============================================================================
//
// 分身 task summary (S3 ink writer R1):
//   - Day 57-63 全 7 天 stitches 完整
//   - Lisa 穿正装 (D57) + 牛皮纸文件夹 (D57) + 微信状态空白 (D57) + 桌下手心没写"加油"(D59) +
//     朋友圈"也好我自己也想换换"(D63) = 5 个 quiet sign 累积 (outline §1 要求 4 个 ≥)
//   - 王总监 verbatim "你最近不一样啊" (D57) + 晨会眼神扫 Lisa 3 次 (D59)
//   - 老周 D57 抬头看笑天一眼 (S3 唯一非沉默动作)
//   - 笑天 D60 偷听 Zoe "下周三签字" (信息不对等高峰)
//   - Lisa D61 周五 21:00 才走 + 背包很重 (S2 19:30 spike 升级)
//   - 妈妈 D63 verbatim "我下个月可能不去你那边了" (S2 反转)
//   - Lisa D63 朋友圈 verbatim "也好我自己也想换换" + 文件夹特写 (E9→E10 cliffhanger)
//
// 笑/泪比 = 5:5 (per season-3-arc.md §1):
//   - 笑点: D57 王总监 muscle memory + Vivian 海报撤掉 / D58 David 第一次注意 / D59 王总监 BLUEPRINT 月度
//          / D62 David 6 月 4 大冲刺 / D63 妈妈 backtrack 反转
//   - 扎点: D57 Lisa 穿正装 + 文件夹 / D57 老周抬头 (silent witness 加深) / D59 桌下手心没写加油 (S1 motif 死)
//          / D60 笑天偷听"下周三签字" / D61 Lisa 21:00 才走 / D63 Lisa 朋友圈"也好我自己也想换换"
//
// 红线 (S3 不能做):
//   - Lisa 不决定走/留 ✓ (E9 没决策, 仅 setup)
//   - 王总监不直接对 Lisa "你不适合" ✓ (D57 仅"你最近不一样啊")
//   - 老周 S3 0 dialog ✓ (D57 仅"抬头看一眼" 无 dialog)
//   - 林姐不出场 ✓
//   - David 不燃尽 ✓ (D58 仅 setup "你看 Lisa 最近")
//
// END
