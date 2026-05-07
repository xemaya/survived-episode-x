# Season 3 弧光 Outline (Episodes 9-12)

> Status: 第 1 版
> Author: Outline Writer (分身 CC session)
> Last Updated: 2026-05-05
> 配套：`series-structure.md`（52 集 macro）+ `season-1-arc.md` v2 + `season-2-arc.md` + `protagonist.md` + `npcs.md` + `tone-bible.md` v2
>
> **使用方法**：跟 season-1/2-arc.md 同结构。未来 ink writer 按本 outline + npcs.md + tone-bible.md + 完成的 episode-1.ink (作为 .ink syntax sample) + episode-5/6/7/8.ink（如已完成）写 episode-9.ink ~ episode-12.ink。
>
> **S3 特殊性**：本季是整 series 第一个真正的"扎点 finale"——E12 Lisa 走/留 climax。8-12 集累积选择全部兑现。**写不好，整 series 的 emotional arc 塌**。所以本 outline 的 quality bar 比 S2 / S4 都高。

---

## 1. Season 3 主题：Lisa 走 / 留 climax

**主题**：S3 是 **Lisa 弧光的兑现集**——从 S2 finale "我可能要走" 那句话开始，跨 4 集慢慢逼近"走或留"的事实。

- **入场**（E9 周一）：S2 finale 周日晚 Lisa 微信末"但 Zoe 说下个月再看看。我可能不该太担心"——她假装乐观。S3 第 1 集开局兑现：**Lisa 周一开始穿正装上班**（不再是 polo）。她在准备面试 / 准备走流程 / 准备一切。她没说，但她全身都在说
- **累积曲线**：
  - **E9**：穿正装周。她的"装" 第一次外露——但她否认。**笑天 4 个 quiet sign 累积**
  - **E10**：HR 试用期评估面谈周。Zoe 把 Lisa 叫去 HR 工位 90 分钟。**Decision Moment 1：帮 Lisa 改自评？**
  - **E11**：周末加班周。Lisa 周五微信"明天来公司加班吗？我自己一个人有点慌"——**Decision Moment 2：陪不陪？这是路径分叉点**
  - **E12 finale**：周日 12:30 Lisa 走 / 留揭晓。5 路径
- **出场**（E12 周日 18:00）：路径 A Lisa 转岗客户成功部林姐处 + 笑天回家路上看着空工位 / 路径 B-E Lisa 走，工位空了

主线 anchor 仍 = **Lisa**（S1-S3 弧光收尾）。S3 主导节奏 = "她每集多一个不可挽回的小信号" + "玩家最后一搏的累积选择"。

### 笑/泪曲线

| Episode | 笑 : 泪 | 主基调 |
|---|---|---|
| **E9** | **5 : 5** | 笑泪持平。Lisa 穿正装反差 + 王总监 cue Lisa "你最近不一样啊" 是笑点（他没看出问题，只看出"不一样"）。**1 个轻扎** = Lisa 桌上多了文件夹 |
| **E10** | **4 : 6** | 笑减少。Lisa 没吃饭 + 笑天看到她偷偷哭过 + Zoe 的 90 分钟面谈像处刑。**Decision Moment 1**：帮 Lisa 改自评 |
| **E11** | **3 : 7** | 笑变少。Lisa 周末加班——**Decision Moment 2**：陪 / 不陪。**这是路径分叉点**——E11 的选择直接决定 E12 finale 落在哪条路径 |
| **E12 finale** | **2 : 8** | 整集情感最重。走 / 留全揭晓。5 路径都"扎"——只是扎法不同 |

整季合计 ≈ **3.5 : 6.5**（比 S2 5:5 更扎，比 S1 7:3 扎得多）—— S3 是 series 第一个情感高峰，扎到底有铺垫。

---

## 2. Beat Archetypes

参考 `season-1-arc.md` §2 的 4 个 archetype（A First Impression / B Decision / C Vulnerability / D Finale）。

S3 的 archetype 实例化偏向：
- **A First Impression**：S3 第一次出场的 NPC = **林姐**（仅路径 A finale）。其他 NPC 继续他们的弧光
- **B Decision Moment**：每集 1-2 个"你能为 Lisa 做点什么"的玩家选择——这些 decision 累计 hero count 决定 E12 路径分支
- **C Vulnerability**：Lisa 4 集 quiet sign 累积；Zoe E10 处刑式面谈是 Zoe C；王总监 E11 独立办公室"你跟 Lisa 谈过她那边什么时候走完吗" 是王总监 C 升级
- **D Finale**：S3 是 Lisa 的 series finale 集——Lisa 弧光在 E12 全部兑现。其他 NPC 不在 S3 finale 离开（David 还要到 S6 / 王总监 S9 / Zoe 全程在 / 李阿姨 S8）

S3 的 hero count 系统是**跨季 cumulative**——S1 hero count + S2 hero count + S3 hero count 累加到一个 counter，E12 路径 A 触发要求 cumulative ≥ 6（且 lisa_score ≥ +25）。

每季 hero flag 单独定义但叠加到统一 counter：

- **S1 hero flag**（E1-E4）：
  - 帮 Lisa 凉茶（S1 E1）→ +1
  - 茶水间救场（S1 E2）→ +1
  - 申报加班帮她拍板（S1 E4）→ +1
- **S2 hero flag**（E5-E8）：
  - `lisa_helped_after_hr` = true（S2 E8 D56 path A，周日回 Lisa 微信"我陪你想办法"）→ +1
- **S3 hero flag**（E9-E12）：
  - `lisa_helped_self_review` = true（E10 帮 Lisa 改试用期自评）→ +1
  - `lisa_weekend_company` = true（E11 周末加班陪 Lisa）→ +1
  - `lisa_zoe_feedback_positive` = true（E11 周二给 Zoe 美化 Lisa 协作反馈）→ +1
  - `lisa_referred_external` = true（E12 周三主动跟 Lisa 提前同事跳槽机会）→ +1

**路径 A 触发要求**：cumulative_hero_count ≥ 6 **且** lisa_score ≥ +25。其他路径见 §6 表。

cumulative hero count 决定 E12 finale 路径——见 §6。

---

## 3. Per-NPC S3 Arc Tables（10 NPC × Episode 9-12）

### 3.1 Lisa（S1-S3 主线 anchor，S3 = 弧光 climax）

| Episode | 状态 | Beat |
|---|---|---|
| **E9** | 穿正装周 | 周一笑天进公司——**Lisa 穿了一件正装外套**（不是 polo）。她说"今天有客户来"——但**没有客户**（笑天 cross-check 周日邮件没看到）。她桌上多了一个**牛皮纸文件夹**。微信状态从"在公司"改成空白 |
| **E10** | HR 处刑周 | 周二 Lisa 中午没吃饭（盒饭碗筷没动 1 个小时）。周三晨会王总监 cue 她"PPT 怎么样"，她答"在赶"——王总监没说什么。周四 14:00 Zoe 把 Lisa 叫去 HR 工位 90 分钟（试用期评估面谈）。周五早晨笑天去茶水间，**听到隔壁洗手间隔间哭一声**——出来时 Lisa 的工位还空着 |
| **E11** | 周末加班周 | 周一 Lisa 左手手心又开始写"加油"（S1 motif 复活——但这次她写得更频繁，每次开会前都写）。周三晨会 Lisa 第一次主动发言"我这个 PPT 还差一些数据，下周交"——王总监没接。周五 19:30 Lisa 还在工位。**周五晚 Lisa 微信："明天来公司加班吗？我自己一个人有点慌"** → **Decision Moment：陪 / 不陪**（路径分叉点）|
| **E12 finale** | 走 / 留 | 周一-周日完整 7 天 finale。周日 12:30 Lisa 出 HR 流程——5 路径（见 §5 + §6）|

**S3 score 范围**：依累积。S2 末若 ≥+15，S3 末路径 A 触发条件成立（lisa_score ≥+25 + cumulative_hero_count ≥ 6）；S2 末若 ≤-5（路径 E），S3 末 score 跌到 -10 以下，Lisa 路径 A 不可能。

**E10 Decision Moment**（玩家选）—— "帮 Lisa 改自评"：
- A. 周四 18:00 加班帮 Lisa 改试用期自评（-1 AP, KPI -5）→ Lisa 周五早上"谢谢笑天，我看了，确实那样写更好" → score +8 + hero_count +1 + flag `lisa_helped_self_review = true`
- B. "我不太懂自评" → Lisa "嗯，那我自己看" → score 0
- C. 不回 / 装没看见 → score -5

**E11 Decision Moment**（玩家选）—— "陪 / 不陪 周末加班"：
- A. "好啊我也去"（周六去公司 -1 AP, 状态 -10）→ Lisa 周六上午先到，下午两人各自做事 18:30 一起下班 → score +12 + hero_count +1 + flag `lisa_weekend_company = true`。**这是路径 A 第 2 关键 flag**
- B. "我那天有点事"（保留状态）→ Lisa "嗯没事，你忙你的" → score -3
- C. 不回 → score -8 + flag `lisa_abandoned_at_weekend = true`

**E12 Decision Moment**（路径 A 玩家专属）—— 周三"介绍前同事跳槽机会"：
- A. 主动跟 Lisa 提"我前公司的客户成功部还在招人，要不我帮你 ping 一下" → flag `lisa_referred_external = true`（路径 A 第 3 关键 flag——但**最终路径 A 触发是林姐内部转岗，不是外部跳槽**——这个 flag 起的是"你尽力了" 的累积证明作用）
- B. 不主动提 → 路径仍可能 A，但需累积更高
- C. 假装不知道有这种机会 → score -3

**S3→S4 cliffhanger**（路径决定）：
- 路径 A：周日 18:00 笑天回家路上，看到 Lisa 微信发"我下个月开始去隔壁部门了。我妈说挺好。" 笑天回："好。" → S4 第 1 集 Lisa 工位换人，新人是个 24 岁男生
- 路径 B：周日 18:00 Lisa 微信："谢谢你这两个月。" 笑天没回 → S4 第 1 集 Lisa 朋友圈最后一条"开启新阶段" → S5+ 偶尔出现
- 路径 C-E：见 §6 表

### 3.2 David（S1-S6 卷王持续，S3 = 加倍施压期）

| Episode | Beat |
|---|---|
| **E9** | David **第一次注意到 Lisa 有问题**——周二茶水间他冲笑天"你看 Lisa 最近，有点不对啊"——他不是关心，他在判断"Lisa 走了我的位置会不会调整"。**笑天内心**：「他到第 9 周才看出来。我从第 5 周就看到了。」 |
| **E10** | David 周一晨会主动报告"上周 KPI 完成 145%"——王总监没接，他眼神扫过 Lisa 那边。周三 David 茶水间问 IT 小马"你那边修咖啡机要再问一下吗"——他**第二次不耐烦**（S4 燃尽前兆继续 setup）|
| **E11** | David 周四晚加班到 22:00，离开前路过 Lisa 工位（Lisa 还在）——他没说话，但他**回头看了 Lisa 工位一眼**。**笑天内心**：「他想知道她什么时候走。」 |
| **E12** | finale 周三 David 晨会主动表扬自己"上次那个客户对接 PPT 我做得还可以"——王总监："嗯。" David 笑了一下回工位。周日 KPI Review 前 David 周报已经交了——他从来没这么早交过 |

**S3 score 范围**：取决于 S1+S2 累积路径。S1 路径 C 帮 David 的玩家在 S3 会被 David 加倍拉拢"咱俩一起搞这个吧" → 笑天发现自己被绑得更紧。

**❌ 注意**：David S3 不能"反思"或"对 Lisa 表示同情"——他是反派双轴的另一极。他对 Lisa 走/留唯一的兴趣是**他自己的位置和 KPI**。

### 3.3 王总监 Eric（S1-S9 系统的化身，S3 单独 cue 笑天 + Lisa 频率↑↑）

| Episode | Beat |
|---|---|
| **E9** | 周一 morning_briefing 王总监站在 Lisa 工位旁等她到——比 S2 任何时候都主动。"Lisa 啊…你最近**不一样啊**。" Lisa 答"啊，刚换了件外套。" 王总监："好好好。" → 周三晨会王总监讲"我们是命运共同体"——眼神扫过 Lisa **3 次**（S2 是 2 次） |
| **E10** | 周二早晨王总监单独叫笑天到他独立办公室门口"小笑啊…陈天啊…Lisa 那边的 PPT 你看过没有？" → **Decision Moment**——笑天 3 选 1 (A "看过，挺好的" / B "我没看" / C "她在赶"）→ 周四王总监的独立办公室门**关了一整天**（不开会但门关）|
| **E11** | 周四 19:30 笑天加班路过王总监独立办公室——**他工位灯还亮，门关着，里面有声音**："你跟 Zoe 说一下吧，下周三签字。" → **王总监 C Vulnerability layer 3**——他在执行命令，他自己也只是 puppet。**笑天内心**：「他也只是在打电话。但他打的是 Lisa 的电话。」 |
| **E12** | finale 周日 9:30 KPI Review。王总监主审。**路径 A**：王总监跟林姐打电话"她（Lisa）你那边能用吗" → 林姐"让她过来吧"。**路径 B-E**：王总监没主动 cue Lisa 的事，KPI Review 后他直接走，去打高尔夫 |

**关键**：S1 路径 A/D 的玩家 + S2 累积 push 频率 → S3 王总监 cue 笑天频率到 **每集 2-3 次**。E10 王总监问"Lisa 那边的 PPT 你看过没有"是 S3 王总监**第一次主动用笑天评估同事**——这是重大 setup（笑天意识到自己也在被工具化）。

**王总监 S3→S4 cliffhanger**：路径 A 后王总监周日傍晚跟笑天"小笑啊…陈天啊…你最近表现不错。下个月看你的"——这是 anti-Pillar 1 的 perfect setup：救了 Lisa = 你下个月 threshold +18%，王总监把你列入 promotion candidate（promotion = 处刑——参 series-structure.md §4.5 Event S10.X promotion 警告 setup）。

### 3.4 Zoe（S1-S12 全程在，S3 = HR 流程加深 + 处刑）

| Episode | Beat |
|---|---|
| **E9** | 周三笑天经过 HR 工位偷听到 Zoe 跟另一个 HR："**Lisa 那边走完吗？**" 另一个 HR："下周三签字。" → 笑天意识到时间表已经定了——但 Lisa 不知道（HR 还没正式通知她） |
| **E10** | 周四 14:00 Zoe 把 Lisa 叫去 HR 工位 **90 分钟**（试用期评估面谈）。Lisa 出来时眼睛红了一下，但她坐回工位接着改 PPT——没跟笑天说话。**Zoe C Vulnerability**：周五早晨笑天去 HR 工位办其他手续，看到 Zoe 桌上摆着一个**快餐盒**（早饭还没吃完）+ 屏幕开着小红书《我做 HR 第 3 年我也想走》——Zoe 看到笑天慌张切屏 |
| **E11** | 周三 Zoe 路过笑天工位"陈笑天先生，关于上次月度面谈的协作反馈，您方便补充一下吗？" → **Decision Moment**——笑天 3 选 1 (A 帮 Lisa 美化反馈 / B 中性回答 / C 客观评价 Lisa 表现一般)。**这是路径 A 第 3 关键 flag**：A → flag `lisa_zoe_feedback_positive = true` |
| **E12** | finale。**路径 A**：周日 11:00 Zoe 群里发"本月度 KPI 通报" + "另：Lisa 同学下周一起调岗至客户成功部"——这是路径 A 唯一的"好消息"显形。**路径 B-E**：周日 12:30 Zoe 直接送 Lisa 走出 HR 工位——她叫 Lisa "Lisa 同学" 一次，叫"李同学" 一次（最后一次"她是公司员工" → 第一次"她是离职者"）|

**关键**：Zoe 在 S3 不是反派——她是流程的 executor。E10 周五早晨那个**快餐盒 + 小红书**镜头是 Zoe S3 唯一一次 vulnerability layer——告诉玩家 Zoe 也在熬。但**Zoe 不会同情 Lisa**——她按流程走，按流程的速度走。

### 3.5 李阿姨（S1-S8 background continuing，S3 = 静默见证者）

| Episode | Beat |
|---|---|
| **E9** | 周三早晨李阿姨在擦工位区——她今天**先擦 Lisa 的工位**（平时她是按工位顺序擦的）。她没说话 |
| **E10** | 周五傍晚笑天加班路过茶水间——李阿姨在收垃圾。她跟另一个清洁阿姨："**这家公司的人每两个月走一茬。**" → 这是 S3 李阿姨升级版"上一个坐这位置的也是这么想的"——更具体、更狠 |
| **E11** | 周日（**仅路径 A/B 触发**）下午 笑天在公司加班 / Lisa 也在 → 李阿姨周日加班来打扫（她的外包公司有时候会安排周末班）。她经过 Lisa 工位 + 笑天工位之间——速度变慢 0.5 秒。**她知道**。她还是没说话 |
| **E12** | finale 周日 12:30 Lisa 出 HR 工位（路径 B-E）。李阿姨在另一头收拾——**她端着茶过去，没看 Lisa，但她拖到 Lisa 工位附近时，她多拖了一遍**。**这是 S1 finale 的 callback——但这次不是"David 工位"，是 Lisa 工位**。路径 A 时她的"多拖一遍"取消，因为 Lisa 还要回来上班 |

**S3 score**：李阿姨 score 系统不影响机制，仍纯叙事。

### 3.6 林姐（S1-S2 完全不出场，**S3 finale 路径 A 第一次出场**）

| Episode | Beat |
|---|---|
| **E9** | 不出场 |
| **E10** | 不出场 |
| **E11** | 不出场（仍是 deliberate restraint）|
| **E12 finale** | **仅路径 A 触发**：周日 11:00 王总监跟林姐通电话"她（Lisa）你那边能用吗" 林姐"让她过来吧" → 周日 14:00 林姐**第一次出现在屏幕上**——她从隔壁部门区域走到 Lisa 工位旁边："Lisa，是吧？跟我去那边坐。"——她叫 Lisa **不带姓**，跟 Zoe 的"陈笑天先生"形成对照（**Pillar 4 关键证据：另一种活法存在**）|

**林姐 A First Impression（路径 A 专属）**：
- 视觉锚出现：黑色西装 + 运动鞋 + 红色文件夹（per npcs.md §10）
- 口头禅出现：先是"我们这边节奏不一样"（跟 Lisa 介绍部门时）+ "**让她过来吧**"（跟王总监打电话时——这句话玩家在场景外听到）
- NPC 行为是为她自己——她**需要好下属**（per npcs.md §10），不是来欢迎玩家。**她跟笑天 0 句话**——她进来时没看笑天，跟 Lisa 说完就带 Lisa 走，离开前看笑天 0.3 秒后转身——这强化"她不是给玩家的"

**林姐 × 笑天**：路径 A 时林姐离开前看了笑天 0.3 秒——她大概也想"这小伙子不错"。但她什么都没说。**笑天内心**：「她不一样。但她不要我。」（Pillar 4：另一种活法存在但你不在那条路径上）

**❌ 林姐路径 B-E 完全不出场**——deliberate restraint。这强化路径 A 的"好结局"质感，但同时强化"这个好结局是 outlier"。

### 3.7 前台 Vivian（龙套，S3 融资八卦持续）

| Episode | Beat |
|---|---|
| **E9** | 周一打卡 Vivian 水果盘**苹果周**（融资仍未到位）"嗨～来啦～" → 工位上海报已撤掉"年终福利预告"（暗示老板施压）|
| **E10** | 周二 Vivian 接电话压低声音"是是是，老板，我马上让她去办公室"——这次是关于**Lisa**。但她**没压到完全听不见**（她做了 6 年前台，她在选择性 leak 信息）|
| **E11** | 周一打卡台贴新海报"本月度月度面谈安排" → 海报上**没名单**，但海报的位置比 S2 那张更显眼（在前台正中）|
| **E12 finale** | 周一 Vivian 水果盘**草莓** → 老板心情好（**Pillar 4 极致黑色幽默**：Lisa 走的同一周老板水果盘换草莓，因为融资过会了）|

**关键**：Vivian S3 出场的 4 次**水果盘 / 海报 / 电话**全部在 visually 暗示"老板的世界 vs Lisa 的世界" 是平行的 universe。Vivian 知道但她做的事是**继续摆水果**。

### 3.8 IT 小马（龙套，咖啡机 running gag continue）

| Episode | Beat |
|---|---|
| **E9** | 茶水间咖啡机仍然故障（已坏 9 周）。IT 工单 status 改成"等零件 v2" |
| **E10** | 不出场 |
| **E11** | 周三笑天经过 IT 角落——IT 小马**不在**。机修包还在桌上，但椅子空 |
| **E12 finale** | 周日 KPI Review 后笑天路过茶水间——咖啡机旁贴新通知"零件已到，下周修复" + 咖啡机仍然故障。**这是 S1 finale 的 callback**——一字不变 |

**关键**：IT 小马 S3 出场频率比 S2 还低，但**咖啡机故障告示**是 series 内最稳定的 visual anchor。Lisa 来时它故障，Lisa 走时它还故障。**Pillar 3：系统从未关心人的来去**。

### 3.9 老周（龙套，S3 完全沉默 elder）

| Episode | Beat |
|---|---|
| **E9** | 笑天经过老周工位——他还面对窗户。**S3 第一次他抬头看了一眼笑天**——只是一眼，没说话，又低头 |
| **E10** | 不出场 |
| **E11** | 周一早晨笑天到公司，看到老周已经在工位（更早 1 小时——同 S2）。**笑天内心**：「他每天 8:00 就到。Lisa 走的事他知道吗？」 |
| **E12 finale** | 周日 12:30 Lisa 走出 HR 工位（路径 B-E）。老周端着茶经过——没看 Lisa，速度变慢 0.5 秒（同 S2 finale 配合 §3.5 李阿姨）。**两个 elder 在同一刻 silently 注意到**——但他们都不说话 |

**关键**：S3 老周对话 = 0 次（per S2 同样规则）。但 E9 那"抬头看一眼" 是 S3 老周唯一的非沉默动作——给玩家一个 quiet hint："他知道。" 但他不会说。

### 3.10 妈妈（龙套，每周日 8:30 视频）

| Episode | Beat |
|---|---|
| **E9** | 周日"天天，我下个月可能不去你那边了。你姨家有事我得过去。" → **S2 finale 妈妈"我下个月想去你那看看你"反转**——她最终没来。**笑天内心**：「她每次说要来都没来。每次说不来都会想来。」 |
| **E10** | 周日"天天，那个谁的儿子升职了。听说现在年薪 60 万。" → 笑天 3 选 1：A "嗯" / B "不容易" / C "我也快了" |
| **E11** | 周日"天天，妈这周身体有点不舒服，没事就是有点累" → **笑天 internal**：「妈最近老说累。她从来不说"我累" 是因为有事——她说"累" 是因为想拉我回去。」 → 但妈妈接着说"没事不用回来啊我自己能照顾自己" |
| **E12 finale** | 周日 8:30 妈妈视频"天天，吃了吗？" "吃了。" → 妈妈："那个谁的女儿离职了，回老家考公务员了" → **3 选 1**：A "嗯，挺好的" / B "我没那个机会" / C 转移话题 → 然后**笑天关掉视频**——比 S1/S2 的妈妈视频都短 1 分钟。**他今天没心情** |

**关键**：S3 妈妈视频 4 周累积形成"那个谁的女儿离职了"的 echo——跟 Lisa 走 / 留 是 S3 finale 的 thematic mirror。妈妈在不知情的情况下**说出了 Lisa 的故事的另一个版本**。

### 3.11 食堂阿姨（ambient flavor，S3 稳定出现）

| Episode | Beat |
|---|---|
| **E9-E11** | 跟 S1/S2 同——笑天周三去食堂吃饭，食堂阿姨给他多打半勺西红柿炒蛋。她不说话，**只笑了一下** |
| **E12 finale** | 周一 Lisa 去食堂吃饭（**仅路径 A 玩家可见**——路径 B-E 时 Lisa 那周没去食堂）。食堂阿姨给 Lisa 打饭，**多打了一勺**——她不知道 Lisa 要走 / 要留，但她看到 Lisa 瘦了 |

---

## 4. Cross-NPC S3 Scenes Matrix

S3 跨集核心同框场景（孤岛 NPC = worker thinking 不要）：

| Episode | 场景 | 同框 NPC | 用途 |
|---|---|---|---|
| **E9 周一** | Lisa 穿正装到工位 | Lisa + 王总监（站在工位旁等她）+ David（看到没说话）+ 笑天（路过看到正装）| S2→S3 cliffhanger 兑现 + 王总监 push 升级 |
| **E9 周三** | 晨会 | 王总监 + David + Lisa + 老周（背景）+ 笑天 | 王总监眼神扫 Lisa 3 次（S1=1 次 / S2=2 次 / S3=3 次的递进显形）|
| **E10 周四** | Zoe 找 Lisa 90 分钟面谈 | Zoe + Lisa + 笑天（看着 Lisa 走出工位 area + 90 分钟后看着 Lisa 回来）+ 老周（背景看着没说话）| HR 处刑形态显形 |
| **E10 周五** | 茶水间隔壁洗手间哭一声 | Lisa（隔壁 stall 哭）+ 笑天（茶水间）+ 李阿姨（路过）| 三人都不能走出来面对面——但他们都听到了 |
| **E11 周一** | Lisa 主动晨会发言 | 王总监 + Lisa（首次主动发言）+ David（看到没接）+ 笑天 | Lisa 最后一搏的尝试——失败 |
| **E11 周四晚** | 王总监独立办公室打电话 | 王总监（打电话）+ 笑天（路过听到）| 王总监 C Vulnerability layer 3 / 命令链显形 |
| **E11 周日** | 周末加班（仅路径 A/B 玩家触发） | Lisa + 笑天 + 李阿姨（周日加班路过）| 路径 A 第 2 关键 flag 触发 |
| **E12 周一** | Vivian 草莓周 + Lisa 走的同一周 | Vivian（摆草莓）+ 笑天 | 黑色幽默 ironic mirror |
| **E12 周日 9:30** | KPI Review | 王总监 + Zoe + 笑天 + Lisa + David | 4 主线 NPC 同框，**老周不参加** + 路径 A 时林姐可能在场外通话 |
| **E12 周日 12:30** | Lisa 出 HR 工位 | Zoe + Lisa + **林姐**（仅路径 A）/ 李阿姨（路径 B-E 多拖工位）+ 老周（端茶经过）+ 笑天 | series 第一个真正的"扎点 finale" |
| **E12 周日 16:00** | Lisa 工位最后一镜（仅路径 B-E） | Lisa（收拾）+ David（路过没看）+ 李阿姨（拖一遍）+ 笑天 | 反高潮 finale—— 没有 BGM、没有道别 UI |
| **E12 周日 18:00** | 笑天回家路上 + Lisa 微信 | Lisa（微信）+ 妈妈（视频已经结束）+ 笑天 | series cliffhanger 到 S4 |

### Cross-NPC 互动钩子（S3 specific）

| NPC × NPC | S3 互动 |
|---|---|
| **Lisa × David** | David S3 周二茶水间"Lisa 最近有点不对啊" → 笑天意识到 David 终于看到了——但他**只看到对自己有用的部分**（Lisa 走 = David 位置可能调整）|
| **Lisa × 王总监** | 王总监 S3 cue Lisa 频率从晨会"扫眼" 升级到主动 push（"PPT 怎么样" / "你最近不一样啊"）。**但他从来不直接说"你做得不好"**——他用 push 替代评价 |
| **Lisa × Zoe** | Zoe 是 Lisa finale 的 executor。E10 90 分钟面谈是 S3 series-wide HR 处刑形态首次显形。**Zoe 叫 Lisa "Lisa 同学" → "李同学" 是身份转换信号** |
| **Lisa × 林姐** | 仅路径 A 触发——林姐"让她过来吧" 是 series 第一次"另一种活法" 的 proof |
| **Lisa × 李阿姨** | E12 路径 B-E 李阿姨多拖 Lisa 工位（callback S1 finale David 工位的 motif） |
| **David × 王总监** | David S3 周一晨会主动报"上周 KPI 145%" → 王总监没接——这是 David S4 燃尽前兆的关键 setup（王总监开始 check him out）|
| **David × Lisa** | David 周四晚加班离开前看 Lisa 工位一眼——他想知道她什么时候走 |
| **王总监 × Zoe** | 王总监 push Zoe 走完 Lisa 流程——E11 周四晚电话"你跟 Zoe 说一下吧，下周三签字" |
| **王总监 × 林姐** | E12 路径 A 周日王总监跟林姐通电话"她（Lisa）你那边能用吗"——这是 S1 后王总监**第一次跟林姐 直接对话**（S1-S2 林姐不出场）|
| **Zoe × Vivian** | Vivian E10 周二接老板电话"我马上让她去办公室"——半小时后 Zoe 找 Lisa。Vivian 是 leak 信源，但她**不主动跟 Zoe 对话**（per npcs.md §6 Zoe × Vivian "嗨～眼神交换"）|
| **李阿姨 × 老周** | 两个 elder 在 E12 周日 12:30 同一刻看到 Lisa 走——他们都没说话。**两个 silent witnesses 同框** |
| **笑天 × 老周** | S3 笑天**不主动找老周**——他知道老周不会说。但 E9 老周"抬头看一眼"是 S2-S3 全程老周 0 句话之外的唯一非沉默动作 |
| **笑天 × 林姐** | 路径 A finale 林姐离开前看了笑天 0.3 秒——他们没说话。**这是 series 第一次"另一种活法"的人形 proof，但她不要笑天** |
| **妈妈 × 任意** | 仍是视频 only。**S3 妈妈意外说出了"那个谁的女儿离职回老家"——thematic mirror 但她不知情** |

---

## 5. Per-Episode Beat Sheet

### Episode 9 · Week 9 · 「她穿了正装」

**主题**：S2→S3 cliffhanger 兑现。Lisa 穿正装上班——她在准备。但她没说，全身都在说。**4 个 quiet sign 累积**。5:5 笑泪持平。

**Beats**：
- **周一**：morning_briefing → Vivian 苹果周 + 海报"年终福利预告"已撤掉 → 工位区 **Lisa 穿正装外套**（Lisa **A 升级 First Impression layer 2**——同一个 NPC 同一个 series 内的 visual identity 重置）→ 王总监站在 Lisa 工位旁等她到 "Lisa 啊…你最近**不一样啊**" Lisa "啊，刚换了件外套" → David 看到没说话 → 笑天经过 Lisa 工位看到她桌上多了**牛皮纸文件夹**→ 周日邮件 cross-check"今天有客户来"——**没有客户** → 下班
- **周二**：David 茶水间 "你看 Lisa 最近，有点不对啊" → **笑天 3 选 1**（A "她最近确实有点忙" / B "我没注意" / C "你管那么多干嘛"）→ Vivian 接电话压低声音"是是是，老板，我马上让她去办公室"——这次是关于 Lisa → 下班
- **周三**：晨会王总监讲"我们是命运共同体"——眼神扫过 Lisa **3 次**（S1=1 次 / S2=2 次 / S3=3 次累积）→ Lisa 桌下手心**没写**"加油"（她的 motif 在 S2 消失，S3 还没复活）→ 周三早晨李阿姨**先擦 Lisa 工位**（她不按工位顺序）→ 下班
- **周四**：笑天经过 HR 工位偷听 Zoe 跟另一个 HR："Lisa 那边走完吗？" "下周三签字" → **笑天意识到时间表已经定了**——但 Lisa 不知道 → 下班
- **周五**：weekly_recap → Lisa 周五 19:30 还在工位（她从来没加班这么晚——但 S2 E5 她加班到 19:30 已经发生过——**这次她走得更晚 21:00**）→ 笑天看到她 21:00 才走，背包很重 → 下班 / 周五日报
- **周六**：周末（11:00 起床 + 妈妈视频铺垫）
- **周日 8:30**：妈妈视频"天天，我下个月可能不去你那边了。你姨家有事" → S2 cliffhanger 反转——**笑天内心**：「她每次说要来都没来。每次说不来都会想来。」 → 笑天微信状态"在公司"（他周日没去公司，但他改了状态——他不知道为什么）→ 下班

**集内高峰**：周一 Lisa 穿正装 + 王总监站工位旁 push（S2→S3 cliffhanger 兑现 + push 升级一气呵成）

**Cliffhanger（导向 E10）**：周日晚笑天看 Lisa 朋友圈——她发了一条："**也好，我自己也想换换**。" 配图：她桌上的牛皮纸文件夹特写。**笑天内心**：「她在告诉我什么。我没看懂。」

### Episode 10 · Week 10 · 「90 分钟」

**主题**：HR 试用期评估面谈周。Zoe 把 Lisa 叫去 HR 工位 90 分钟。**Decision Moment 1**：帮 Lisa 改自评。4:6 笑泪反转。

**Beats**：
- **周一**：morning_briefing → David 主动报"上周 KPI 完成 145%"——王总监没接 → 笑天看 Lisa 桌上的牛皮纸文件夹——今天换了一个新的，里面**多了几张打印纸**（他没看清是什么）→ 下班
- **周二**：早晨王总监单独叫笑天到他独立办公室门口"小笑啊…陈天啊…Lisa 那边的 PPT 你看过没有？" → **Decision Moment**——笑天 3 选 1 (A "看过，挺好的" / B "我没看" / C "她在赶"）→ Lisa 中午**没吃饭**（盒饭碗筷没动 1 个小时）→ 下班
- **周三**：晨会王总监 cue Lisa "PPT 怎么样" Lisa "在赶"——王总监没说什么 → David 茶水间问 IT 小马"你那边修咖啡机要再问一下吗"——他**第二次不耐烦** → 下班
- **周四**：**14:00 Zoe 把 Lisa 叫去 HR 工位 90 分钟**（试用期评估面谈）→ 笑天看着 Lisa 走出工位 area → 14:00 - 15:30 Lisa 工位空 → 15:30 Lisa 回来眼睛红了一下，坐回工位接着改 PPT——没跟笑天说话 → **笑天 3 选 1**（A "下班一起吃个饭吧" / B 只是看了她一眼 / C 假装没看到）→ 18:00 **Decision Moment——帮 Lisa 改试用期自评？**（玩家 3 选 1）→ 下班
- **周五**：weekly_recap → 早晨笑天去茶水间——**听到隔壁洗手间隔间哭一声**——出来时 Lisa 的工位还空着 → 9:00 Lisa 才到，她说"地铁延误"——但**笑天周五早晨地铁正常** → 笑天去 HR 工位办其他手续——看到 Zoe 桌上**快餐盒**+ 屏幕开着小红书《我做 HR 第 3 年我也想走》——Zoe 切屏 → 下班 / 周五日报
- **周六**：周末
- **周日 8:30**：妈妈视频"天天，那个谁的儿子升职了。听说现在年薪 60 万。" → **3 选 1**（A "嗯" / B "不容易" / C "我也快了"）→ 下班

**集内高峰**：周四 14:00 Zoe 找 Lisa 90 分钟（HR 处刑形态显形） + 周四 18:00 Decision Moment 帮 Lisa 改自评

**Cliffhanger（导向 E11）**：周日晚 Lisa 微信"笑天，谢谢你这周（如果选 A 帮自评）。下周一我可能要再去 HR 那边。你别担心"——**这是 S2 finale 那句"你别担心啊"的 verbatim repeat**——但这次后面跟着"我自己想想看怎么办"。**笑天内心**：「她又说"别担心"。她每次说"别担心" 都意味着她担心。」

### Episode 11 · Week 11 · 「我自己一个人有点慌」

**主题**：周末加班周。**Decision Moment 2**：陪 / 不陪。**这是路径分叉点**——E11 的选择直接决定 E12 finale 落在哪条路径。3:7 扎为主。

**Beats**：
- **周一**：morning_briefing → Lisa 左手手心**又开始写"加油"**（S1 motif 复活，但这次她写得更频繁——开会前都写）→ Lisa 第一次**主动晨会发言**"我这个 PPT 还差一些数据，下周交"——**王总监没接**（David 立即接话"我这周可以帮 cover" 王总监："好"）→ 下班
- **周二**：Zoe 路过笑天工位"陈笑天先生，关于上次月度面谈的协作反馈，您方便补充一下吗？" → **Decision Moment**——笑天 3 选 1 (A 帮 Lisa 美化反馈 / B 中性回答 / C 客观评价 Lisa 表现一般) → 下班
- **周三**：晨会王总监讲"我们这个团队啊，是有未来的" → David 周四晚加班到 22:00，离开前**回头看 Lisa 工位一眼** → 下班
- **周四**：19:30 笑天加班路过王总监独立办公室——**他工位灯还亮，门关着，里面有声音**："你跟 Zoe 说一下吧，下周三签字。" → **王总监 C Vulnerability layer 3** → 下班
- **周五**：weekly_recap → Lisa 19:30 还在工位 → **21:00 Lisa 微信："明天来公司加班吗？我自己一个人有点慌"** → **Decision Moment**——笑天 3 选 1 (A "好啊我也去" / B "我那天有点事" / C 不回) → 下班 / 周五日报
- **周六**：周末（A 路径玩家——周六去公司）
- **周日**（按 S2 末路径 + lisa_score 分支）：
  - **路径 A/B**（S2 path A/B + lisa_score ≥ +5）：Lisa 周日加班 / 笑天周日加班 → 李阿姨周日加班来打扫，**经过他俩工位之间速度变慢 0.5 秒**——她知道 → 8:30 妈妈视频"天天，妈这周身体有点不舒服，没事就是有点累" → **笑天 internal**：「妈最近老说累。她从来不说"我累" 是因为有事——她说"累" 是因为想拉我回去。」 → 但妈妈接着说"没事不用回来啊我自己能照顾自己" → 下班
  - **路径 C**（S1 帮 David 累积玩家）：11 点起床 → 8:30 妈妈视频普通对话，妈妈版 escalate "那个谁的儿子升职加薪了" → 笑天回 "嗯" → 笑天周日 21:00 点开微信看 Lisa **没消息**（Lisa 没邀请他周末加班——她已经在 mute 他）→ 下班
  - **路径 D**（S2 sick_count ≥ 2 累积玩家）：11 点起床 → 笑天周日的"装病前兆" 萌芽——他**预感周一要装病**了 → 8:30 妈妈视频时他先关掉摄像头说"信号不好" → 妈妈"看不见你脸"，笑天"妈我这边网不好" → 下班 → 笑天没看 Lisa 微信
  - **路径 E**（lisa_score < -5 玩家）：11 点起床 → 8:30 妈妈视频普通对话 → 笑天点开微信看 Lisa **没消息**——他没在意，他这两个月已经习惯她不联系 → 下班

**集内高峰**：
- 周一 Lisa 主动发言被 David 截胡 + 王总监没接（**Lisa 最后一搏的尝试——失败**）
- 周五 21:00 Lisa 微信"我自己一个人有点慌"——**路径分叉点**

**Cliffhanger（导向 E12 finale）**：周日晚 Lisa 微信末："**笑天，下周可能就出结果了。不管怎样，谢谢你**。" → **笑天内心**："她说"不管怎样" 已经知道了。" → 这是 series 第一次 Lisa 用"谢谢你"。**这是 anti-Pillar 4：她在告别**

### Episode 12 · Week 12 · 「下周三签字」(Season Finale)

**主题**：S3 高潮。Lisa 走 / 留全揭晓。5 路径都"扎"——只是扎法不同。2:8 整集情感最重。

**Beats**：
- **周一**：morning_briefing → Vivian 水果盘**草莓**（**ironic mirror**：老板心情好的同一周 Lisa 要走）→ 笑天打卡时看一眼水果盘 → 工位区 Lisa 还在（她还没走）→ Lisa 桌上的牛皮纸文件夹**今天没在桌面上**（她可能放包里了）→ Lisa 中午去食堂（**仅路径 A 玩家可见**——路径 B-E Lisa 那周没去食堂）→ 食堂阿姨给 Lisa 多打一勺 → 下班
- **周二**：（轻笑点）David 周报已经交了——他从来没这么早交过 → 晨会王总监讲"我们这个团队啊，是有未来的"——他**没 cue Lisa**（系统 already 在处理她）→ 下班
- **周三**：晨会 David 主动表扬自己"上次那个客户对接 PPT 我做得还可以"——王总监："嗯。" David 笑了一下回工位 → **路径 A 玩家专属 Decision Moment**——笑天主动跟 Lisa "我前公司的客户成功部还在招人，要不我帮你 ping 一下"（3 选 1）→ 下班
- **周四**：Lisa 工位空了一下午——她去 Zoe 那签字了（**所有路径都触发，但路径 A 后面会有"林姐救场" turnaround**）→ 下班
- **周五**：weekly_recap → 笑天看 Lisa 工位**空了一整天**——她请假了 → 下班 / 周五日报
- **周六**：周末
- **周日**：
  - **8:30 妈妈视频**"天天，吃了吗？" "吃了。" → 妈妈："那个谁的女儿离职了，回老家考公务员了" → 笑天 3 选 1（A "嗯，挺好的" / B "我没那个机会" / C 转移话题）→ **笑天关掉视频**——比 S1/S2 妈妈视频都短 1 分钟。**他今天没心情**
  - **9:30 KPI Review** 浮层揭晓——王总监主审。Zoe 群里发"本月度 KPI 通报" → 笑天的下月 threshold 涨幅揭晓（路径 A=+18% / 路径 B=+5% / 路径 C=+5% / 路径 D=+3% / 路径 E=+1%）
  - **11:00 路径 A 触发**：王总监跟林姐通电话"她（Lisa）你那边能用吗" 林姐"让她过来吧" → Zoe 群里发"另：Lisa 同学下周一起调岗至客户成功部" → 笑天微信看到通知
  - **12:30 Lisa 出 HR 工位**：路径 A → Lisa **没**走出 HR 工位的"离职路线"——她跟 Zoe 谈完后，林姐**第一次出现在屏幕上**——她从隔壁部门区域走到 Lisa 工位旁边："Lisa，是吧？跟我去那边坐。" → Lisa 看了笑天一眼，没说话，跟林姐走 / 路径 B-E → Zoe 直接送 Lisa 走出 HR 工位
  - **14:00 路径 A**：林姐离开前看了笑天 0.3 秒——她大概也想"这小伙子不错"。但她什么都没说。**笑天内心**：「她不一样。但她不要我。」
  - **16:00 路径 B-E 专属**：Lisa 工位最后一镜——Lisa 收拾东西。David 路过没看。李阿姨**多拖一遍 Lisa 工位附近**（callback S1 finale David 工位 motif，但这次 motif 转移到 Lisa）。老周端茶经过——速度变慢 0.5 秒。**两个 elder silent witnesses**
  - **18:00 笑天回家路上 + Lisa 微信 cliffhanger**（见 §6）

**集内高峰**：
- 周日 9:30 KPI Review 揭晓——5 路径都"过"，下月 threshold 全部上涨
- 周日 12:30 Lisa 走 / 留揭晓
- 周日 14:00 路径 A 林姐 First Impression（series 第一次"另一种活法"显形）
- 周日 16:00 路径 B-E Lisa 工位最后一镜
- 周日 18:00 series cliffhanger 到 S4

**Series Cliffhanger（导向 S4）**：
- **路径 A**：周日 18:00 Lisa 微信"我下个月开始去隔壁部门了。我妈说挺好。" 笑天回："好。" → S4 第 1 集（E13）开局：Lisa 工位换人，**新人是个 24 岁男生**——笑天看着新人坐下时，回想 12 周前自己的第一天
- **路径 B**：周日 18:00 Lisa 微信"谢谢你这两个月。" 笑天没回 → S4 第 1 集 Lisa 朋友圈最后一条"开启新阶段"
- **路径 C**：周日 18:00 Lisa **没微信**给笑天 → S4 第 1 集笑天看 Lisa 朋友圈分组——**他被屏蔽了**
- **路径 D**：周日笑天请病假——**他没看到 Lisa 走** → 周一回公司发现 Lisa 工位空了 → S4 第 1 集 Lisa 工位换人，但笑天**不知道她是哪天走的**
- **路径 E**：周日笑天的手机界面没新消息 → 周一回公司 → 没人通知他 Lisa 走了 → S4 第 1 集他**问 Vivian "Lisa 呢" Vivian "嗨～她上周走了" → 笑天回工位**

**S3→E12 NPC archetype 完成度**：D finale Lisa 完成（series finale 弧光）。其他 NPC 都不在 S3 finale 离开。**林姐 A First Impression 完成（仅路径 A）**

---

## 6. S3 Finale 5 路径表（**series 第一个真正的"扎点 finale"**）

> S3 finale = Lisa 走 / 留 climax + 笑天的第三次月末 KPI Review。**5 条路径都"扎"——只是扎法不同**。这是 anti-Pillar 1 + Pillar 3 + Pillar 4 的核心证据集中爆发：
> - **anti-Pillar 1**：路径 A 救了 Lisa = 你下月 threshold +18%（更大的处刑）
> - **Pillar 3**：5 路径都没"赢"——Lisa 留下也是延长扎心，Lisa 走也是 Pillar 3 入口
> - **Pillar 4**：路径 A 的"另一种活法"（林姐部门）存在，但她不要笑天——你旁观了一次

| 路径 | 累积条件（**hard rule trigger**） | 月末 Lisa 命运 | 王总监评语 | 下月 threshold 涨幅 | 扎法 |
|---|---|---|---|---|---|
| **A. 救 Lisa** | S1 路径 A/B + cumulative_hero_count ≥ 6（含 S2 `lisa_helped_after_hr` + S3 `lisa_helped_self_review` + `lisa_weekend_company` + `lisa_zoe_feedback_positive` 等，per §2 累计规则）+ S3 末 lisa_score ≥ +25 | **Lisa 转岗客户成功部林姐处** | "你做得真好。下个月看你的" | 100→**118** (+18%) | **救了 Lisa = 你下月 threshold 涨最多。林姐第一次登场，看了你 0.3 秒，但她不要你**。Lisa 留下不是奖励——是延长扎心（她下月在隔壁部门 OK，你这月还要 carry +18% 的 threshold）|
| **B. 救得不彻底** | S1 路径 B + S2 部分帮 Lisa + cumulative_hero_count ≥ 3 但 < 6（累积不够）| **Lisa 走，但她周日发"谢谢你"** | "嗯，及格。继续。" | 100→**105** (+5%) | 你帮了一些但没救住。Lisa 周日发"谢谢你"——你回了"对不起"。**S5+ 朋友圈偶尔见 Lisa——她在新公司发**"重新开始" |
| **C. 路径分裂** | S1 路径 C 帮 David + S2 cold + cumulative_hero_count ≤ 2 | **Lisa 走，没说再见** | "勉勉强强。" | 100→**105** (+5%) | 你帮了 David，没顾上 Lisa。Lisa 没主动找你——**笑天看着 Lisa 工位空了**。**S4 第 1 集笑天发现自己被 Lisa 朋友圈屏蔽** |
| **D. 装病 + 摸鱼** | S1 路径 D + S2 sick_count ≥ 3 + S3 周日装病 1 次 | **Lisa 走，笑天那天在家请病假没看到** | "你看起来不太对。" | 100→**103** (+3%) | 你最轻松，但**Lisa 走的那天你不在**。周一回公司发现 Lisa 工位空了——你不知道她是哪天走的。**S4 第 1 集你不能跟任何人对话关于 Lisa 走的事** |
| **E. 全程冷处理** | S1 路径 E + S2 lisa_score < -5 + cumulative_hero_count = 0 + S3 全程不互动 | **Lisa 走，没人通知笑天** | （没说什么） | 100→**101** (+1%) | 你下月 threshold 涨最少，但**Lisa 走的事你后知后觉**。S4 第 1 集你问 Vivian "Lisa 呢"，Vivian "嗨～她上周走了"。**S2-S3 6 集你 mute Lisa——她也 mute 你**。Pillar 3 极致：你在场但你不在 |

### KPI Review 浮层文案（路径 A specific——其他路径同 S1 finale 格式）

```
═══════════════════════════════════════════
            月末 KPI 评估通报
═══════════════════════════════════════════

· 本月 KPI 累积：[N] 分
· 系统评估您的付出度为：[英雄模式]
· 下月阈值调整：100 → 118

· 系统注释：
  "您本月协助同事完成关键交付。
   公司认可您的团队精神。
   下月将给予您更高的责任。"
  ——这是您的 reward。

═══════════════════════════════════════════
```

**注意**：路径 A 的 reward 文案"协助同事" "团队精神" "更高的责任" 是 anti-Pillar 1 极致黑色幽默——你救了 Lisa，系统的回报是"涨 threshold"。**HR-speak 直接抄现实**——不要"加效果"。

**实装 note**：文本来源 = ink（通过 `# kpi_review_path_a` 之类 tag 触发），渲染 = Preact KPI Review overlay (T18 待 W1 实现)。outline 只规定文案，不规定 render layer。

### 5 路径的共同点
- **没有 Game Over 路径**——S3 finale 不是 GO，它是 climax
- **下月 threshold 全部上涨**——anti-Pillar 1 第三次 expose（S1=10/5/5/3/1，S3=18/5/5/3/1）
- **Lisa 4 路径走 / 1 路径留**——但**留下也不是赢**（路径 A threshold +18%）

### 5 路径的差异化代价（影响 S4-S6）

| 路径 | S4-S6 影响 |
|---|---|
| A | **王总监把笑天列入 promotion candidate**——S10 promotion 警告 setup（参 series-structure.md §4.5）开始累积。S5+ 林姐茶水间偶遇笑天点头不主动说话。Lisa S5+ 偶尔回办公室办手续 |
| B | Lisa S5+ 朋友圈偶尔出现（她在新公司发）。David S4 燃尽前兆按标准节奏。S6 Lisa 朋友圈"开启新公司满 100 天" |
| C | Lisa S4+ 完全没接触笑天（她屏蔽了他）。David S4-S5 加倍依赖笑天（你的位置被 reinforce）|
| D | 王总监 S4+ 单独 cue 笑天频率 +5 倍 / 集（"装病不能再来一次"）。妈妈 S4 周日视频可能问"天天你最近怎么了" |
| E | Lisa S4-Series 内不再出现。S4 第 1 集 Vivian 告诉你她走了—— 这是 S3-S4 的唯一 connection。**Pillar 3 极致**——你是公司里"她不存在"的版本 |

---

## 7. Quality Rubric（per Season-1 §7 + Season-2 §7）

参考 `season-1-arc.md` §7。每集自检 17 条 + S3 specific：

S3 specific 加 7 条：
- [ ] **Lisa 4 集 quiet sign 累积**：E9（穿正装 + 文件夹 + 微信状态空白）→ E10（没吃饭 + 偷哭 + 手心写"加油"频繁）→ E11（周末加班 + 微信"我自己一个人有点慌"）→ E12（finale）每集递进，不能 1-3 集都"她还好"，第 4 集突然走
- [ ] **王总监 cue Lisa 频率↑↑**：S3 比 S2 更频繁（晨会扫眼 3 次 / 周一站工位旁等 / 周二单独问笑天 Lisa 状况）。但仍是 background——王总监**永远不直接对 Lisa 说"你做得不好"**
- [ ] **老周 S3 对话 = 0**：完全沉默（per npcs.md §8 + S2 同样规则）。E9 "抬头看一眼" 是唯一非沉默动作
- [ ] **林姐 S3 finale 路径 A First Impression**：3 个 visual + 口头禅"让她过来吧"（场景外听到）+ "我们这边节奏不一样" + 她**不要笑天**——必保留
- [ ] **路径 A reward 是 threshold +18%**：anti-Pillar 1 极致黑色幽默——必保留
- [ ] **路径 B-E 都"扎"**：5 路径里没有"赢"——任意一条出现"reward UI / BGM / 庆祝过场" = 重写
- [ ] **Lisa "我可能要走" → "我自己一个人有点慌" → "不管怎样，谢谢你"**：3 句台词必保留 verbatim（S2-S3 弧光 anchor）

参考 series-structure §3 主要 NPC 弧光 + npcs.md 各 NPC 设定。

---

## 8. S2→S3 Migration Note

无重大冲突需 user verify。S2 outline §8 已经处理 S1→S2 剪短发 migration（Option A：剪短发挪到 S2 E7）。S3 直接从 S2 finale "我可能要走" + S2 E7 "剪短发" 累积态出发。

唯一需要注意：**S3 E11 周日加班场景**仅在 S2 末 lisa_score ≥ +5 + S2 路径 A/B 玩家触发。其他路径 E11 周日 Lisa 没邀请笑天（她已经在写离职信了）。这是 S2 累积自然分支，不需 designer 干预。

---

## 9. 给分身的使用说明（写 episode-9/10/11/12.ink 时）

参考 `episode-generation-brief.md`（S1 时写的 brief）+ `daily-choices-handoff.md`（daily choice 池子）。S3 时使用同样流程：

1. 读 reference（series-structure.md / 本 season-3-arc.md / npcs.md / protagonist.md / tone-bible.md / episode-1.ink + episode-5/6/7/8.ink 作 .ink syntax sample）
2. 按 S3 outline §5 per-episode beat sheet 写 4 个 .ink 文件
3. 每个文件 ~600-700 行（参考 episode-1.ink 体量）+ E12 finale 可以略长（~800-900 行）因为有 5 路径分叉
4. 每个 stitch 含 # scene / # time tag + `~ check_state_after_choice()` 调用 + `-> next_stitch` divert
5. 每个 NPC archetype 实例化：S3 重点是 Lisa C 4 集累积 + Lisa D finale + 林姐 A First Impression（仅路径 A）
6. cross-NPC 同框场景至少 3 个 / 集（参考 §4 矩阵）—— S3 比 S2 同框频率高（finale 集 ≥ 5 个）
7. 笑泪比例严格按 §1 表（E9=5:5 / E10=4:6 / E11=3:7 / E12=2:8）
8. **E12 finale 的 5 路径分支**——每条路径要有自己的 stitch chain 而不是共用 fallthrough。Lisa 走/留分岔后，路径 A 走林姐 stitch，路径 B-E 走 Lisa 离职 stitch
9. **路径 A 的 reward 文案**（threshold +18% + 王总监"你做得真好下个月看你的"）必须是 anti-Pillar 1 极致黑色幽默——直接抄 HR-speak / PUA 话术，不加情绪
10. 提交时按 `episode-generation-brief.md` §8 提交格式 + W4 提交报告（per handoff §5）

---

## 10. 设计自检

- [ ] 4 集每集都有"想知道下一集"的 cliffhanger
- [ ] Lisa 弧光 quiet sign 累积 4 集（穿正装 → 没吃饭 + 偷哭 → 周末加班 → finale）—— 节奏渐进
- [ ] David / 王总监 / Zoe / 李阿姨 / 妈妈 / Vivian / IT 小马 / 老周 各自的 S3 行为都有特定 beat (per §3)
- [ ] cross-NPC 同框场景至少 12 个跨 4 集（per §4 矩阵）—— S3 比 S2 同框密度高
- [ ] 笑/泪曲线（5:5 → 4:6 → 3:7 → 2:8）让 S3 finale 扎到底有铺垫
- [ ] S3 finale 5 路径都"扎"但都"扎不同痛点"（per §6 表）
- [ ] Lisa 走/留**在 E12 finale**——不在 E9/E10/E11
- [ ] **林姐 S3 finale 路径 A 第一次出场**——不在 S1/S2/E9/E10/E11
- [ ] 老周 S3 对话 = 0（不破坏 S1 唯一对话的稀缺性）
- [ ] 路径 A reward 是 threshold +18%——anti-Pillar 1 极致黑色幽默
- [ ] 路径 B-E 没有"赢"路径——5 路径里没有"reward UI / BGM / 庆祝过场"
- [ ] E12 finale 文案达 series-finale 级别——直接抄 HR-speak / PUA 话术，不加情绪
- [ ] 笑天 voice 在 S3 末转变为"我没救成她。这就是答案"——S1 起的"她还相信。我也相信过" 已经走完一个完整的 arc

---

## 11. ❌ S3 不能做的事

- 不要让 Lisa 在 E9/E10/E11 决定走或留（那是 E12 finale）
- 不要让王总监对 Lisa 直接讲 "你不适合"（那是 Zoe 的工作 / HR 月度面谈才说）
- 不要让 David 在 S3 燃尽（S6 finale）—— S3 David 是"加倍施压期" + 燃尽前兆继续 setup
- 不要让老周说出第二句话（S1 唯一对话已耗尽 + S2 0 句话）
- 不要让林姐在 S3 之前出场（仅 E12 finale 路径 A 第一次出场）
- 不要让玩家在 E12 finale "赢"——路径 A "救 Lisa" = 你下月 threshold +18%（更大的处刑）
- 不要给 Lisa 完整 backstory expose（她的真实想法仍 ambiguous，只通过她的小动作累积）
- 不要让笑天对 Lisa 说"你别担心"或"会好的"——这违反 anti-Pillar 1 + protagonist.md §11 主角设计禁忌
- 不要让 Lisa 走 / 留**逻辑不基于累积选择**——E12 路径必须由 S1+S2+S3 累积 hero count 决定，不能是"E12 当天玩家选 A/B/C/D/E"
- 不要在 E12 finale 路径 A 时给"happy ending UI"——林姐离开前看笑天 0.3 秒，没说话，没 BGM，没特殊过场
- 不要让 Lisa 在路径 A 之外"反转回归"——路径 B-E Lisa 都走，不能 E12 周日突然"算了我不走了"
- 不要引入 npcs.md 未注册的新 NPC（林姐已注册，林姐部门同事 = 隐式背景，不需要单独 character）

---

## 12. 下一步

1. **GM (designer) review**：本 S3 outline 是否符合 handoff brief §4 验收标准（无硬性 fail / 软性 fail < 3 条）
2. **If OK**：可以启动一个新 ink 写作分身 session，按本 outline + .ink syntax sample 写 episode-9.ink → episode-12.ink
3. **Designer next**：S4 outline（David 燃尽前兆）—— **bonus** 任务，本分身可继续如有精力

---

## W4 提交报告 — Season 3 outline

### 输出
- design/vertical-slice/season-3-arc.md (~520 行)

### Section 完成度
- §1 主题 + 笑/泪曲线 ✓
- §2 4 archetype reference ✓
- §3 Per-NPC arc tables (10 NPC + 食堂阿姨 ambient × 4 episodes) ✓
- §4 Cross-NPC scenes ✓
- §5 Per-episode beat sheet (E9-E12) ✓
- §6 S3 Finale 5 路径表 + KPI Review 浮层文案 ✓
- §7 Quality Rubric reference ✓
- §8 S2→S3 Migration note ✓
- §9 给 ink writer 的 use 说明 ✓
- §10 设计自检 ✓
- §11 ❌ 不能做的事 ✓
- §12 下一步 ✓

### Open Questions
- **路径 A 触发条件 hero_count ≥ 3**：handoff §2 5 路径表说 "S3 hero_count ≥ 3" 但没定义具体 flag 集合。我用了 `lisa_helped_self_review` + `lisa_weekend_company` + `lisa_zoe_feedback_positive` 三个 flag 作为 hero_count source。GM 可调整阈值或 flag 集合
- **S3 路径 A reward = +18% threshold** 是按 handoff 给的 number。其他路径 +5%/+5%/+3%/+1% 跟 S1 finale 涨幅一致（S1=+10%/+5%/+5%/+3%/+1%）—— 这暗示 S3 路径 A "anti-pillar 1 升级" 是 +18%（S1 是 +10%）。GM 可调整
- **林姐路径 A 出场篇幅**：本 outline 给林姐的"独立 stage time" 仅 14:00 那 1 个 stitch（她离开前看笑天 0.3 秒）。GM 可考虑是否需要 + 1 个 stitch 让笑天对林姐有 more visible interaction（但担心破坏"她不要笑天" 的 deliberate restraint）
- **E11 周日加班 scenes** 仅 A/B 路径触发。C/D/E 路径 E11 周日玩家做什么？—— 我假设 C/D/E 玩家 E11 周日就是普通周末（11 点起床 + 妈妈视频），但没在 §5 E11 详写 C/D/E 周日 stitch。**GM 决定是否需要补 C/D/E 路径 E11 周日 specific stitch**
- **食堂阿姨 E12 周一出场**（路径 A 玩家可见 Lisa 去食堂）：这个 ambient flavor 是否过度增加 E12 finale 的 stitch count？GM 决定是否保留
- **bonus S4 outline**：handoff §8 鼓励 time permitting 写 S4。本 session 已写 ~520 行 S3，**如 GM review 通过，下一波可启动 S4 outline**
