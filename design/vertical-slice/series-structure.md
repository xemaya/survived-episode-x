# Series 结构（52 集 全 series 框架）

> Status: 第 1 版
> Author: Game Designer (Claude)
> Last Updated: 2026-05-05
> 配套：`protagonist.md`（陈笑天）+ `npcs.md`（10 NPC：5 深 + 5 龙套）+ `tone-bible.md`（口吻规则）+ `season-N-arc.md`（每季独立 outline）
>
> **用途**：series 总长 + 12 季主题 + endgame + happy ending 变体 + Game Over 分类。每季 outline（如 `season-1-arc.md`）只 implements 这一季，但都要符合本文件定义的 macro 走向。

---

## 1. Series 时长定义

| 单位 | game-time | 现实时长 | 对标 |
|---|---|---|---|
| 1 集（Episode） | 1 周 = 5 工作日 + 2 周末 = 7 天 | ~30-60 分钟 playtime | 1 集电视剧 |
| 1 季（Season） | 1 个月 = 4 集 = 28 天 | ~2-4 小时 playtime | 1 mid-season arc，**Season finale = 月末 KPI Review** |
| 1 部（Series） | 1 年 = **52 集** | ~25-50 小时 playtime | 完整 game-year |

**52 集 = 12 个月 × 4 集 + 4 集 endgame**：
- E1-E48：12 个月正常剧情（每月 = 1 季 = 4 集 = 1 个 KPI 周期）
- E49-E52：**Endgame 4 集 special arc**（年终：年会 / 年终奖 / 春节假期前 / 春节回家）

**Game-end conditions**：
- **Happy ending**：活过 E52 → 春节回家 + 多变体结局
- **Game Over**：任意 KPI Review 不达标 → 月末"恭喜晋升" / "组织调整" / "末位淘汰" 文案，进入 Archive 重开

---

## 2. 12 季 + Endgame 主题分布

| Season | Episodes | Game-month | 主题 | Season Finale 高峰 |
|---|---|---|---|---|
| **S1** | E1-E4 | 1 | **反向 KPI 第一次咬人**——笑天的教学集 | E4 笑天的第一次 KPI Review：他做对了反而下月 threshold 涨。**第一次真切感受系统恶意** |
| **S2** | E5-E8 | 2 | **Lisa 状态下滑** | E8 Lisa 剪短发 + HR 第一次月度面谈（口头警告） |
| **S3** | E9-E12 | 3 | **Lisa 走/留 climax** | E12 Lisa finale（8-12 集累积选择兑现） |
| **S4** | E13-E16 | 4 | **David 燃尽前兆** | E16 David 第一次失态（晨会被王总监打断 / 在茶水间摔了保温杯） |
| **S5** | E17-E20 | 5 | **新人入场** | E20 实习生入职第 1 周 → 叫笑天"陈哥"。他第一次被叫"哥" |
| **S6** | E21-E24 | 6 | **David 燃尽离职** | E24 David finale。朋友圈"开启人生新篇章" |
| **S7** | E25-E28 | 7 | **半年了**——KPI 累积压力到点 | E28 笑天第一次 threshold 几乎不可达，险过 |
| **S8** | E29-E32 | 8 | **清洁阿姨退休** | E32 李阿姨 finale。**没有任何 UI 提醒**——某个早晨发现没人倒水了 |
| **S9** | E33-E36 | 9 | **王总监被换** | E36 王总监 finale。新总监空降——他自己也是 puppet 被处理掉 |
| **S10** | E37-E40 | 10 | **猎头电话** | E40 笑天接到猎头电话。decision：跳？留？ |
| **S11** | E41-E44 | 11 | **"组织调整"传言** | E44 集体焦虑高峰。微信群"听说了吗" |
| **S12** | E45-E48 | 12 | **12 月 KPI 冲刺** | E48 笑天最难一关（12 个月累积 threshold） |
| **S13 (Endgame)** | E49-E52 | 年终 | **春节回家** | E52 春节回家最后一晚 → Happy ending |

---

## 3. 主要 NPC 跨 series 弧光

### 5 深度 NPC

| NPC | 出场 Seasons | Finale Episode | 离场方式 |
|---|---|---|---|
| **Lisa** | S1-S3 | E12 | 走（路径 B）/ 留转岗（路径 A，但 S5+ 偶尔出现） |
| **David** | S1-S6 | E24 | 燃尽离职。朋友圈"开启人生新篇章" |
| **王总监 Eric** | S1-S9 | E36 | 被换。新总监空降——他不是反派被打败，他自己也是受害者 |
| **Zoe** | S1-S12 | 全程在 | S6 后升级"高级 HR"，但仍偶尔出现 |
| **李阿姨** | S1-S8 | E32 | 退休。儿子考上大学回老家 |

### 5 龙套 NPC（详见 `npcs.md` §6-§10）

| NPC | 出场频率 | 功能 |
|---|---|---|
| **前台 Vivian** | scattered（融资/八卦时刻） | 水果盘信号源 / 公司动态 messenger |
| **IT 小马** | scattered（咖啡机 running gag） | 永远修不好任何东西 |
| **老周** | scattered（沉默存在） | 笑天的"未来自己"镜像 / 10 年司龄不主动说话 |
| **妈妈** | 每周日 8:30 视频 | 家庭锚 / 固定剧本"吃了吗 / 工资发了吗" |
| **客户成功部林姐** | S3 finale 之后（路径 A） | Lisa 转岗 destination / 隔壁部门视角 |

### 主角

| 角色 | 出场 Seasons | Finale |
|---|---|---|
| **陈笑天**（玩家） | S1-S13 | E52 happy ending OR 任意季 game over |

---

## 4. Endgame 4 集 special arc（E49-E52）详解

### E49 · 公司年会 · 12 月最后一周
**主题**：所有人喝酒装 high。笑天看着他们演。

**Beats**：
- 周一：年会通知（强制参加 + 节目报名）
- 周二：节目排练（笑天被分到"集体歌曲"小组——后排）
- 周三：年会前一天（公司提前下班，所有人都在补化妆 / 借衣服）
- 周四：**年会**（CEO 致辞 + 抽奖 + 王总监被换之后的新总监敬酒 + 笑天躲在角落）
- 周五：年会后第一天上班（所有人宿醉 + 没人开会）
- 周六：周末
- 周日：周末

**集内高峰**：周四晚年会上，CEO 念"感谢这一年坚守的同事们" → 大屏幕滚动名字 → **笑天的名字闪了 0.3 秒**。他眼睛酸了一下，但他不知道是因为感动还是因为酒。

### E50 · 年终奖打卡 · 12 月最后第二周
**主题**：年终奖到账。所有人微信群暗暗炫耀。

**Beats**：
- 周一：HR 群通知"年终奖将于本周三发放"
- 周二：David 提前算了 N 遍（虽然 David 已经 S6 离职，这里是回响——其他卷王 2 号在算）
- 周三：**年终奖到账**（笑天看到数字，比预期低 30%）
- 周四：朋友圈晒——同学晒车、晒娃、晒旅行。笑天没晒
- 周五：**笑天订了 5 月去日本的机票**（呼应他微信头像富士山）
- 周六：周末。妈妈视频："工资到了？"
- 周日：周末

**集内高峰**：周五订机票那一刻——笑天看着确认页面停了 30 秒，最后点了"支付"。

### E51 · 春节假期前一天 · 1 月底
**主题**：办公室空一半。还在的人都想跑。

**Beats**：
- 周一：HR 群"春节假期安排：1/28-2/8 共 12 天"
- 周二：所有人开始打包行李（Lisa 路径 A 留下的话，她已经请了年假）
- 周三：王总监（如果还在）在开 meeting——没人开摄像头
- 周四：办公室空一半，工位灯一半暗着
- 周五：**最后一天**。下午 4 点公司发"春节红包"（68 元微信红包）
- 周六：周末
- 周日：**春节回家路上**（高铁 / 飞机 / 长途巴士——根据笑天的存款不同）

**集内高峰**：周五下午笑天最后离开办公室。他关电脑前**回头看了工位绿萝一眼**——它会熬过 12 天没人浇水吗？

### E52 · 春节回家最后一晚 · 春节
**主题**：12 天假期接近尾声。明天回北京。

**Beats**：
- 周一：到家。妈妈做了一桌菜
- 周二：拜年（笑天躲了大部分亲戚）
- 周三：除夕（妈妈给红包 200 块）
- 周四：初一（睡到 12 点）
- 周五：初二（笑天去同学聚会）
- 周六：初三（妈妈带笑天去买"工作衣服"——她不知道他已经买不动了）
- 周日：**最后一晚**。妈妈视频升级现场——他们俩坐在妈妈家的沙发上 → **happy ending 触发**

**集内高峰**：周日晚最后一晚。妈妈说"明天早点起，我送你去高铁站"。笑天："好。"

---

## 4.5 S10-S12 关键 setup events（v1.1 追加）

> 跟 daily-choices.ink 里 #54 投简历 / #60 找王总监谈晋升 配套的剧情 event setup。daily choice 体现"玩家自己作死"，但需要剧情 event 给玩家"informed decision" 的 context——避免 game over 来得太突然让玩家觉得不公平。

### Event S10.X · 王总监 promotion 警告 setup（先于 daily choice #60）

**触发**：S10 (E37-E40) 任意一集，前置 flag = `promotion_candidate_count >= 2`（即累积 2 个月 KPI > 150）
**速度**：长 (~10 行)
**同框 NPC**：王总监 + 笑天

王总监单独叫笑天去他独立办公室。门关着。

```
"小笑啊。"

他犹豫 0.5 秒。

"陈天啊。"

"差不多差不多。坐。"

他指了指对面的椅子。

"是这样啊小笑，你这几个月 KPI 一直挺好的。我跟上面也提过几次。"

"你也知道，我们这个团队啊，是有未来的。"

"你呢，年轻，能干，跟我们这种中年人不一样。"

"我啊，可能再过几年也就退到二线了。"

"你呢，前途无量。"

"你考虑下，下个季度给你提个主管？你下属直接对接。"
```

笑天 3 选 1：
- A. "谢谢王总，我考虑一下" —— 王总监："好好考虑。" 隐藏 flag `promotion_warned = true`。**daily choice #60 解锁条件正式 active**——之后任何月 KPI > 150 触发 `promotion_candidate_count` 到 6，#60 抽到时玩家就知道"作死"是什么后果
- B. "王总，我可能更适合现在的岗位" —— 王总监："小笑啊，你太谦虚了。"——他**没生气**，但他记 1 笔。下个月 threshold +5%（"不接受 = 不识抬举"）
- C. （沉默不答） —— 王总监："嗯，你回去想想。" 这场戏作为 daily choice #60 触发条件 ready

**笑天内心独白**：
```
_他叫"小笑啊…陈天啊…差不多差不多" 9 个月了。_
_今天他第一次叫得"差不多"。_
_"差不多"——because 他不需要叫准我名字，因为他要 promote 我了。_
_promote 之后他就不用记我名字了。_
```

**Cross-ref**：daily choice #60 (`design/vertical-slice/daily-choices.md` §5 大决策) — 玩家碰到 #60 时，是否触发本 setup event 决定玩家是否 informed。If 没 setup → #60 抽到时给玩家 8 秒 cooldown 显示"你最近被王总监频繁 cue 了，可能是 promotion signal"

---

### Event S11.X · X 公司 1 面通知 follow-up（接 daily choice #54 投简历）

**触发**：S11 (E41-E44) 任意一集，前置 flag = `resume_sent_count >= 1`（投过 ≥ 1 次简历）
**速度**：标准 (~6 行)
**同框 NPC**：仅笑天 + 手机界面 prop

下午 15:18。陌生号码。

```
"您好，是陈笑天吗？我是 X 公司 HR。我们看了您的简历，想约您下周二下午聊一下。"
```

笑天 3 选 1：
- A. "好的下周二可以" —— 周二请假 1 天去面试。回来 3 天后**X 公司 HR 已读不回**。隐藏 flag `interview_attempts += 1`，`interview_pass_count += 0`
- B. "下周二我有事，能改时间吗" —— HR："那这边再协调下哈。"——她**不会再打**。隐藏 flag `interview_attempts += 0`，`interview_ghosted_count += 1`
- C. "我考虑下" —— HR："好的您方便随时联系我。"——她**不会再打**。隐藏 flag `interview_attempts += 0`，`interview_ghosted_count += 1`

**笑天内心独白**：
```
_我每年面试 2 次。_
_今年第 1 次面试是 4 月。HR 说"我们再讨论一下"。然后再没消息。_
_今年第 2 次面试可能就是这次。_
_或者她会再消失。_
```

**3 路径概率分布**（runtime 实装时随机抽）：
- A 路径下 70% ghost 你 / 25% 周二一面后 1 周拒 / 5% 一面后 2 周二面通过（**rare happy variant**）
- 5% happy 路径触发：`interview_pass_count += 1` → daily choice #55 "请年假去日本" 解锁概率 +20%（你"有备份" 心态）+ S12 finale 笑天主动找王总监谈晋升的 daily choice #60 概率 -15%（你"不那么慌" 了）

**Cross-ref**：daily choice #54 (`design/vertical-slice/daily-choices.md` §5 大决策) — 玩家累积投递 ≥ 1 时本 event 在 S11 池子里 active

---

### Event SX.X · 季节性 setup events（v1.2 追加 — placeholder for full season-arc 写作）

> Round 2 daily-choices 分身 Open Q5 提议：seasonal 元素（春节年会 / 中秋月饼 / 端午粽子 / 国庆调休 / 圣诞合影）**改走 episode-level event** 而非 daily choice。**Designer accept** —— seasonal 体量足够大且周期固定，不适合作为 daily choice 池子里的 random pull。
>
> 具体实施在对应 season-arc.md 写（每个 season 1-2 个 seasonal event）。本节只是 placeholder。

候选 seasonal events（按 game-month 分布）：

| Game-Month | Season | Seasonal Event | 候选 trigger |
|---|---|---|---|
| 4 月（清明） | S4 (E13-16) | 清明节调休"放 1 天补 1 天" + 没人扫墓的工位空荡感 | 周一调休加班 |
| 5 月（劳动节） | S5 (E17-20) | 劳动节"放 5 天补 7 天"+ 笑天去北戴河旅游照 | 假期前一天晨会 |
| 6 月（端午） | S6 (E21-24) | 端午抢公司粽子（"今年是肉粽 + 蛋黄, 你要哪个"）+ David 燃尽前兆 | 端午节前一天 |
| 8 月（七夕） | S8 (E29-32) | 七夕公司 HR 强制摆拍 + 单身员工别人发红包给员工 | 单身/已婚 binary |
| 9 月（中秋） | S9 (E33-36) | 中秋月饼盲盒被领导抽走 + 王总监换人交接日 | 中秋前一天月饼分发 |
| 10 月（国庆） | S10 (E37-40) | 国庆调休"放 7 天补 7 天" + 笑天接到猎头电话 | 国庆假期前一天 |
| 12 月（圣诞） | S12 (E45-48) | 圣诞 HR 强制圣诞帽合影 + 12 月 KPI 冲刺压力 | 圣诞节当天 |
| 1-2 月（春节） | S13 endgame (E49-52) | **春节回家** —— happy ending 锚定 | E49-52 endgame full arc |

每个 seasonal event 是 1 个剧情 event stitch（~10-15 行 .ink），**不是 daily choice**。在对应 `season-N-arc.md` 的 §5 per-episode beat sheet 里嵌入触发位置。

**Designer 不在 Round 2 实施这些**——留给 S2-S12 各自 season-arc 写作时分身处理。本节是**架构占位**：表明这些 seasonal beats 已规划，避免 future session 误以为 gap 而走 daily choice 路线。

---



每个变体不互斥——玩家根据 series 中的累积选择**触发 1-3 个组合**。

### Variant A · "妈妈版"（家庭线高的玩家）
触发：12 个月内 ≥ 9 次接妈妈周日视频
> 妈妈递过去一碗汤："你瘦了。"
> 笑天："没瘦。"
> 妈妈："瘦了。"
> 笑天笑了一下。
> _不多。但算我赢一次。_

### Variant B · "5 月日本机票"（年终奖到手的玩家）
触发：完成 E50 订机票 beat
> 笑天躺床上看 booking 邮件。
> 5 月 12 日，东京 → 大阪。
> _8 年了。我以为我会再去。_
> _我会去的。这次。_

### Variant C · "Lisa 在客户成功部祝福"（Lisa A 路径玩家）
触发：S3 finale Lisa 留下 + S5+ 笑天接到她至少 2 条微信
> 微信新消息：Lisa（客户成功部）。
> "笑天，新年快乐。我妈说今年留我在家多待几天。你回去了吗？"
> 笑天回："回去了。"
> Lisa："好。"
> _她还会"好"。_

### Variant D · "新人叫陈哥"（S5 实习生入场玩家）
触发：S5 后实习生 score ≥ +10
> 微信新消息：实习生小张。
> "陈哥新年快乐！明天什么时候到公司啊？"
> 笑天回："早。"
> _陈哥。_
> _不是天哥。是陈哥。_
> _我成了 David。_
> _不算多。但算个变化。_

### Variant E · "办公室空了，安静真好"（cynical 玩家——很少帮人）
触发：12 个月内 score 累积 < +50（所有 NPC 加起来）
> E51 周五最后离开办公室那天。
> 整层楼只剩笑天一个。
> 风扇声。
> _安静真好。_
> _我活过了。_

### Variant F · "同学聚会发现自己其实活得 OK"（S12 完成所有 KPI 的玩家）
触发：12 个月全部 KPI 达标，且至少 6 个月用了"装病请假"卡
> E52 周五同学聚会。
> 老同学说："你们那家公司听说裁员了。"
> 笑天："是。我没被裁。"
> 老同学："厉害。"
> 笑天："不厉害。我装病装得好。"
> 全桌笑。
> _这是这 12 个月第一次有人觉得我厉害。_
> _哪怕原因是装病。_

### 复合 ending 规则

如果触发多个 variant，按"出现顺序"在 E52 周日晚连续播：
- 妈妈版（先触发）
- 然后 happy ending 视觉过场（妈妈家厨房 → 高铁站 → 北京回家路上）
- 然后 Variant B/C/D/E/F 的微信通知 / 内心独白叠加

整套 ending 持续 ~3-5 分钟。**不要 happy ending UI 庆祝**——保持 Pillar 4：他没赢，他只是熬过了。

---

## 6. Game Over 路径分类

任意月末 KPI Review 不达标 → Game Over。但**不同 season 的 GO 文案不同**：

### 早期 GO（S1-S3）：「适应不良」
触发：E4 / E8 / E12 任意 KPI Review fail
> 王总监："小笑啊…陈天啊…差不多差不多。我们这边觉得你可能不太适合。"
> Zoe："陈笑天先生，已为您协调岗位适配方案。"

### 中期 GO（S4-S7）：「末位淘汰」
触发：E16 / E20 / E24 / E28 KPI Review fail
> 王总监："这个月我们部门要做一些调整。你这个 KPI 在末位 10%。"
> Zoe："您这边方便的话，本周走完流程。"

### 后期 GO（S8-S11）：「组织调整」
触发：E32 / E36 / E40 / E44 KPI Review fail
> Zoe："陈笑天先生，公司架构调整，您所在的岗位被合并。"
> （没有责怪。没有谈判。流程化执行。）

### 终极 GO（S12 / E48）：「恭喜晋升」
触发：E48 KPI Review fail（12 个月最后一关）
> 王总监："小陈，我们觉得你这一年表现很稳。明年提你做主管，你下属直接对接。"
> _恭喜晋升。_
> _我早就知道。_
> （**升职 = 处刑**——anti-Pillar 1 极致）

### Endgame GO（E49-E52）：「年终特殊」
触发：E49-E52 任意一集 KPI 不达标（虽然 endgame 没有传统 KPI Review，但有"年终评估"）
> 年会上 CEO："感谢这一年坚守的同事们。"
> 大屏幕名字滚动——**没有笑天的名字**。
> 散场后王总监过来："小陈啊，我们再聊聊。"

---

## 7. Series Finale 哲学

### Game Over：anti-Pillar 1 + Pillar 3 极致
- 不是因为玩家"做错了"——是因为反向 KPI threshold 涨到不可达的点
- 任何 GO 都不带 UI 庆祝、不带 BGM 高潮、不带 ending credits
- 只有 1 句台词 + Archive 提示 + 重开按钮

### Happy Ending：anti-Pillar 1 但保留温情
- 笑天**没变强**——他熬过了
- Happy ending 不是 trophy——是"被允许休假"
- 春节后第一天还要回公司 → 暗示**新的 game-year 又开始**
- 玩家可以选择"继续游戏"（year 2 = 难度更高的 series）或"看 Archive 回顾"

### 设计意图
- **52 集是"足够长但有终点"**——比 endless 给玩家心理 anchor
- **Happy ending 不是 anti-pattern**——它是 Pillar 4 极致："苦中作乐"的"乐"必须有真实的小快乐时刻
- **多变体 ending 让玩家有重玩动力**——但绝不奖励"卷"或"变强"

---

## 8. 设计自检

- [ ] 12 季每季都有清晰主题，不是简单"再过一个月"
- [ ] 5 深 NPC 各自有 finale episode，不全集中在 series finale
- [ ] 5 龙套 NPC 各有 functional purpose，不是装饰
- [ ] Endgame 4 集脱离正常 KPI 节奏，提供"假期感"
- [ ] Happy ending 多变体让累积选择有 visible payoff
- [ ] Game Over 不是"惩罚玩家"，是"系统的必然"
- [ ] Series finale（任意结局）都不奖励"主角变强"
- [ ] 每季 finale 有"想看下一季"的 cliffhanger（Lisa 的 8-12 集累积模式适用其他长弧光 NPC）

---

## 9. 给分身 CC session 的使用说明

**写每一季 outline（`season-N-arc.md`）时**：
1. 先读本文件（macro 主题 + NPC 跨季弧光 + endgame）
2. 再读 `npcs.md`（10 NPC 完整设定）
3. 再读 `protagonist.md`（笑天声音）
4. 再读 `tone-bible.md`（5 原则）
5. 然后按 `season-1-arc.md` 的格式（4 集 beat sheet + 每 NPC 当季 4-archetype + cross-NPC matrix + quality rubric）写 `season-N-arc.md`

**写每集剧本（`episode-N.md`）时**：
1. 先读对应 season-arc
2. 再读所有上面 4 份 reference
3. 然后按 `episode-1.md` 的格式（每天 morning_briefing + 2-3 events + 选项 + 后果 + 笑天内心独白）写

**绝不要**：
- 在 `episode-N.md` 里改变 series macro 主题（那要回 `series-structure.md` 改）
- 在 `season-N-arc.md` 里改变 NPC 长弧光 finale 时间（那要回本文件改）
- 自由发挥引入新 NPC（必须先在 `npcs.md` 注册）
