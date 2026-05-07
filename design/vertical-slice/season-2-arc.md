# Season 2 弧光 Outline (Episodes 5-8)

> Status: 第 1 版
> Author: Game Designer
> Last Updated: 2026-05-05
> 配套：`series-structure.md`（52 集 macro）+ `season-1-arc.md` v2（S1 outline + 4 archetype 框架 + Quality Rubric）+ `protagonist.md` + `npcs.md` + `tone-bible.md`
>
> **使用方法**：跟 season-1-arc.md 同结构。未来分身 CC session 按本 outline + npcs.md + tone-bible.md + 完成的 episode-1.ink (作为 .ink syntax sample) 写 episode-5.ink ~ episode-8.ink。

---

## 1. Season 2 主题：Lisa 状态下滑

**新主题**：S2 是**Lisa 第一次摇晃**——从 S1 末"我感觉我可能不太适合"那句话开始，跨 4 集慢慢证明她真的不适合。

- **入场**（E5 周一）：S1 finale 笑天说出"下个月又是周一"——下个月就是 E5。Lisa 早 9:00 已在工位（cliffhanger 兑现"下个月加班多一点"）。她真的开始加班
- **下滑曲线**：
  - E5：周一开始加班。奶茶喝光时间变长（她舍不得买第二杯）
  - E6：奶茶换成便利店咖啡（Lisa 第一次喝咖啡）
  - E7：周一她剪了短发（"想换个心情"）—— 心理学梗：人在重大决定前会先剪头发
  - E8（finale）：HR Zoe 找她月度面谈，"潜力一般，希望下个月再看看"。Lisa 周日微信告诉笑天
- **出场**（E8 finale 周日 21:30）：Lisa 微信"我可能要走"——但她说的是"可能"。S3 是不可能确认（4 集纠结） / 必将失败（finale 走 / 留）

主线 anchor 仍然 = **Lisa**。S2 主导节奏 = "她每集多一个不可见的小恶化"。

### 笑/泪曲线

| Episode | 笑 : 泪 | 主基调 |
|---|---|---|
| **E5** | **7 : 3** | 主体仍是笑（Vivian 苹果周融资被打回笑点 + David 卷王基本面 + 王总监单独 cue running gag）。1 个轻扎 = Lisa 周一已在工位 |
| **E6** | **6 : 4** | 笑减少。Lisa 改喝咖啡 + 王总监 cue 频率↑ + 妈妈视频"上海买房那个谁的儿子又结婚了" |
| **E7** | **4 : 6** | 笑泪反转。Lisa 剪短发是 setup-payoff 高峰 + 老周首次说"上一个坐这位置的也是这么想的"（S1 没说出来过） |
| **E8 finale** | **3 : 7** | 主基调扎。HR 月度面谈成真。最后 Lisa 周日微信"我可能要走" + 笑天内心崩 |

整季合计 ≈ **5 : 5**。比 S1（7:3）扎得多——因为 S2 是**真的看到她下滑**，不是"还有救"的曲线。

---

## 2. Beat Archetypes

参考 `season-1-arc.md` §2 的 4 个 archetype（A First Impression / B Decision / C Vulnerability / D Finale）。S2 不是 NPC 的"第一次出场"集，所以 A archetype 在 S2 不强（除非新 NPC 首登场，本季无新 NPC）。S2 重点是 **C Vulnerability** + **D Finale**——NPC 露馅 + closure。

S2 archetype 实例化偏向：
- **B Decision Moment**：每集每个主线 NPC 的玩家 vs NPC 决策点（继承 S1 trigger 的 cumulative effect）
- **C Vulnerability**：S2 是 NPC C 集中曝光集——Lisa / 王总监 / Zoe / Vivian 都在 S2 露馅
- **D Finale**：仅 S2 有 finale 的 NPC（Lisa 的"未走但摇晃"算 finale 弧的一节）

---

## 3. Per-NPC S2 Arc Tables（10 NPC × Episode 5-8）

### 3.1 Lisa（S1-S3 主线 anchor，S2 = 状态下滑集）

| Episode | 状态 | Beat |
|---|---|---|
| **E5** | 早 9:00 已在工位 | 周一笑天进公司，Lisa 已在敲键盘。她 8:50 就到了。cliffhanger 兑现 |
| **E6** | 改喝便利店咖啡 | 周二 9:30 Lisa 桌上不是奶茶——是 7-11 美式。她从来不喝咖啡。**笑天内心**：「她也开始装醒着了」 |
| **E7** | 周一剪短发 | E2 cliffhanger 真正兑现（worker 误把 cut hair 写到 S1 episode-3.ink，**designer 决策需挪到此**——见 §10）。Lisa 笑了一下"想换个心情"——她说了 2 次"换"字 |
| **E8 finale** | HR 月度面谈 + 周日微信 | 周四下午 Zoe 把 Lisa 叫去 HR 工位（玩家偷听到）。周日 21:30 Lisa 微信："Zoe 找我谈了月度面谈。她说我'潜力一般'" |

**S2 score 范围**：依玩家选 + 累积。S1 末若 ≥+12，S2 末仍可保持 +15 ~ +20（救得回来）；若 S1 末 ≤+5，S2 末跌到 -5（Lisa 不再主动找笑天）。

**E8 Decision Moment**（玩家选）：
- A. 周日晚回 Lisa 微信"我陪你想办法" → score +5 + flag `lisa_helped_after_hr` = true（S3 救 Lisa 路径开启的关键 flag）
- B. 回"嗯，听你的" → score +0
- C. 不回 → score -8 + flag `lisa_abandoned_after_hr` = true

**S2→S3 cliffhanger**：周日 21:30 Lisa 微信末："但 Zoe 说下个月再看看。我可能不该太担心。" —— 她假装乐观。S3 第 1 集（E9）开局：Lisa 周一开始穿正装上班（不再是 polo）

### 3.2 David（S1-S6，S2 卷王持续）

| Episode | Beat |
|---|---|
| **E5** | David 周二抢功 #2（pps demo 又来一次"5 分钟" + 群里假感谢） |
| **E6** | David 周三晨会主动报告"上周 KPI 完成 130%"——王总监没接，他尴尬笑了一下 |
| **E7** | David 茶水间问 IT 小马"你那个修咖啡机还要等多久"——他没耐心了，**笑天内心**：「David 是第一次显得不耐烦」（David S4 燃尽前兆 setup） |
| **E8** | David 周五 4 点已经在写"周一计划"——比 S1 早 2 集出现，意味着他卷的 baseline 又抬高了 |

**S2 score 范围**：取决于 S1 finale 路径（per `season-1-arc.md` §6 5 路径表 S2 影响列）。"路径 C 帮 David"玩家在 S2 会被 David 加倍找麻烦。

### 3.3 王总监 Eric（S1-S9，S2 单独 cue↑）

| Episode | Beat |
|---|---|
| **E5** | 周一 morning_briefing 王总监**站在工位旁等笑天到**——比 S1 任何时候都主动。"小笑啊…陈天啊…月度 KPI 我们对一下" |
| **E6** | 周三晨会王总监讲"我们这个团队啊，是有未来的"——同样的 PUA，但**这次他眼神扫过 Lisa 工位 2 次**（不是 1 次） |
| **E7** | 周四 19:30 笑天加班，看到王总监独立办公室门关着但有声音——他在打电话："你跟那个 Lisa 提一下吧。" **王总监 C Vulnerability layer 2** |
| **E8** | 周三晨会王总监主动表扬 Lisa "Lisa 上次那个客户对接 PPT 不错"——但他**说完没人接话**，包括 Lisa 自己。**W 总监试图给 Lisa "下台阶" 但失败** |

**关键**：S1 路径 A/D 的玩家在 S2 王总监 cue 笑天频率显著↑（per 5 路径表）。E5 王总监等在工位旁的细节，路径 A（卷王模式）+3 / 路径 D（装病摸鱼）+5 倍频率。

### 3.4 Zoe（S1-S12，S2 finale 第 1 次主动）

| Episode | Beat |
|---|---|
| **E5** | 不出场（仍是看不见的危险） |
| **E6** | 周四笑天经过 HR 工位听到 Zoe 跟另一个 HR："本月度面谈名单已经出来了。" **隐藏 setup**——名单上有 Lisa 但玩家不知道 |
| **E7** | 周二 Zoe 路过笑天工位"陈笑天先生，下午方便聊一下吗？" → **重大 Decision Moment**（如果选去 → 谈话内容是关于笑天 S1 finale 路径 = 王总监 cue Lisa 的影响 / 如果选拖到下班 → Zoe 周三再来一次） |
| **E8 finale** | 周四 14:30 Zoe 走到 Lisa 工位旁"Lisa 你这边方便的话…" Lisa 跟 Zoe 去 HR 工位。**笑天看着 Lisa 走出工位 area** |

**关键**：E7 Zoe 找笑天聊 5 分钟——这是 S2 给玩家的 fake-out（玩家以为 Zoe 找笑天关于他自己 KPI，但其实 Zoe 是在收集"Lisa 的协作伙伴反馈"，是 Lisa HR 月度面谈的前置数据采集）。

### 3.5 李阿姨（S1-S8，S2 background continuing）

| Episode | Beat |
|---|---|
| **E5** | E5 周一加班场景：笑天加班到 19:30 看到李阿姨在拖工位附近的地。她没看笑天 |
| **E6** | 不出场 |
| **E7** | **关键**：周五傍晚笑天下班路过茶水间，听到李阿姨跟另一个清洁阿姨："**上一个坐这位置的也是这么想的**。"——这句话 S1 还没说出来过，S2 第一次说，意味着李阿姨开始把笑天当"会重复别人轨迹"的看 |
| **E8** | 周日 12:30 Lisa 走出 HR 工位时，李阿姨正端着茶经过——她没看 Lisa，但她**速度变慢 0.5 秒**。她知道 |

**S2 score**：李阿姨 score 系统不影响机制，仍纯叙事（per npcs.md §5）。

### 3.6 Vivian（龙套，S2 C Vulnerability）

| Episode | Beat |
|---|---|
| **E5** | 周一 "嗨～ 苹果哦～ 老板 D 轮过会**被打回了**"——揭穿 S1 E2 草莓周的真相（融资其实没过会，老板演给员工看）。**Vivian C Vulnerability** |
| **E6** | 周二早晨 Vivian 接老板电话："好，我马上让 Lisa 过去办公室。"——这次她**没压低声音**。笑天背着耳机假装没听见 |
| **E7** | 不出场 |
| **E8** | 周一打卡台贴新海报："本月度月度面谈安排"——海报上有日期但没名单。笑天扫了一眼，离开 |

### 3.7 IT 小马（龙套，running gag continue）

| Episode | Beat |
|---|---|
| **E5** | 茶水间咖啡机仍然故障（已坏 5 周）|
| **E6** | IT 工单 status 终于改成"等零件"（不再是"已派单"）。**笑天内心**：「他终于换了说辞」 |
| **E7** | 周三笑天经过 IT 角落——IT 小马**不在**。机修包没动 |
| **E8** | 不出场 |

### 3.8 老周（龙套，S2 沉默 elder）

| Episode | Beat |
|---|---|
| **E5** | 笑天经过老周工位——他还面对窗户。背对人群 |
| **E6** | 不出场 |
| **E7** | 周二早晨 9:00 笑天到，看到老周已经在工位（更早 1 小时）。**笑天内心**：「他每天 8:00 就到。我不知道他每天 23:00 走" |
| **E8** | 周日 12:30 Lisa 走出 HR 工位时，老周端着茶经过——没看 Lisa，速度变慢 0.5 秒（同 §3.5 李阿姨）。**两个 elder 在同一刻 silently 注意到** |

**关键**：S2 老周对话 = 0 次（per npcs.md §8 "S1 唯一对话已耗尽"）。S2 完全沉默。

### 3.9 妈妈（龙套，每周日 8:30 视频）

| Episode | Beat |
|---|---|
| **E5** | 周日 "天天，吃了吗？... 你是不是瘦了" |
| **E6** | 周日 "天天，那个王二家儿子上海买房了。... 那个谁结婚了" |
| **E7** | 周日 "天天，妈听你姨说... 你姨说她有个朋友的女儿..." 然后没说完 |
| **E8 finale** | 周日 8:30 妈妈"天天，我下个月想去你那边看看你。"——**笑天慌了**。妈妈这是在 S2 第一次主动说要来。**笑天 Decision**：A "好啊妈"（隐藏 flag mom_visit_pending）/ B "下个月不行妈，太忙了" / C 转移话题 |

### 3.10 林姐（S1-S2 仍不出场）

继续 deliberate restraint。S3 finale 路径 A 才第一次出场。

---

## 4. Cross-NPC S2 Scenes Matrix

S2 跨集核心同框场景（孤岛 NPC = worker thinking 不要）：

| Episode | 场景 | 同框 NPC | 用途 |
|---|---|---|---|
| **E5 周一** | 王总监等在工位旁 cue 笑天 | 王总监 + 笑天 + Lisa（背景，已经在工位）| S1 finale 路径影响兑现 |
| **E6 周三** | 晨会 | 王总监 + David + Lisa + 老周（背景）+ 笑天 | 王总监眼神扫 Lisa 2 次，Lisa 桌下手心**没写**"加油"（S1 那个 motif 消失）|
| **E7 周一** | Lisa 剪短发到工位 | Lisa + David（看到，没说话）+ 笑天 | 心理学梗 setup |
| **E7 周四** | 笑天主动找老周（如果路径 B/D 玩家有 retry quota）| 老周 + 笑天 | 老周仍只 "嗯"——retry 失败，**笑天意识到 S1 那 1 次是绝唱** |
| **E7 周五** | 茶水间 | 李阿姨 + 另一清洁阿姨 + 笑天（路过）| "上一个坐这位置的也是这么想的" 第一次说出 |
| **E8 周四** | Zoe 找 Lisa 月度面谈 | Zoe + Lisa + 笑天（看着她走出工位 area）| Series-wide HR 系统第 1 次显形 |
| **E8 周日** | Lisa 微信 + 妈妈视频同时发生 | Lisa（微信）+ 妈妈（视频）+ 笑天 | 笑天周日 21:30 同时被 Lisa 微信 + 妈妈"我下个月想去看你" 双面包夹 |

---

## 5. Per-Episode Beat Sheet

### Episode 5 · Week 5 · 「下个月加班多一点」

**主题**：Lisa 兑现 cliffhanger 真的开始加班。S1 finale 路径 cumulative 影响第一次大规模显形（王总监 cue 笑天频率 / Lisa 不主动 / David 加倍 / 等）。7:3 笑泪比。

**Beats**：
- **周一**：morning_briefing → Vivian 苹果周 + 老板 D 轮过会被打回（**Vivian C Vulnerability**）→ 工位区 Lisa 已 8:50 在 → **王总监等在工位旁 cue 笑天**（路径 A/D 玩家被 cue 得密）→ Event 1 王总监 cue 决策（3 选 1）→ 下班
- **周二**：David 抢功 #2（pps demo 又来）→ Lisa 中午没拼奶茶——她去茶水间接热水了 → 下班
- **周三**：晨会 王总监讲"我们这个团队啊"——眼神扫 Lisa 2 次 → 下午笑天看到 Lisa 桌上多了一瓶眼药水 → 下班
- **周四**：笑天加班路过李阿姨拖地（无对话）→ 下班
- **周五**：weekly_recap → Lisa 19:30 还在工位（她从来没加班这么晚）→ 下班
- **周六**：周末（11:00 起床 + 妈妈视频铺垫）
- **周日 8:30**：妈妈视频"天天，吃了吗？... 你是不是瘦了" → **E5 finale 轻扎**

**集内高峰**：周一王总监等在工位旁——S1 finale 路径效应第一次显形

**Cliffhanger**：周日晚 Lisa 微信"今天周日我也来公司了。明天早 8:00 见。" → **E6 周一她真的在 8:00**（提前 1 小时）

### Episode 6 · Week 6 · 「她不喝奶茶了」

**主题**：Lisa 状态下滑的 quiet sign 集中爆发。她的微小习惯一个个变。6:4 笑泪比。

**Beats**：
- **周一**：morning_briefing → 王总监**没等**笑天（笑天反而觉得空虚——他已经习惯了被 push）→ Lisa 8:00 已经在工位 → 9:30 Lisa 桌上是 7-11 美式（**第一次喝咖啡**）→ 下班
- **周二**：Zoe 跟另一个 HR 偷听对话："本月度面谈名单已经出来了" → 笑天听到，但他不知道 Lisa 在名单上 → 下班
- **周三**：晨会 王总监 cue Lisa "你这边 PPT 怎么样"——Lisa 答"还在赶"——王总监："**那加把劲**。" → 下班
- **周四**：Lisa 周四中午去 HR 工位办什么手续——笑天没看到 → 下班
- **周五**：weekly_recap → David 茶水间问 IT 小马"修咖啡机还要多久"——他**第一次不耐烦**（David 燃尽前兆 setup） → 下班
- **周六**：周末
- **周日 8:30**：妈妈视频"天天，那个王二家儿子上海买房了" + "那个谁结婚了" → **E6 finale 轻扎升级** → **笑天 3 秒沉默** 妈妈"没事，慢慢来"

**集内高峰**：周一 Lisa 改喝咖啡（quiet sign）

**Cliffhanger**：周日 21:00 笑天看 Lisa 朋友圈——她发了一张工位照片，**配文：「这周辛苦了」**——这是她从来没发过的 self-acknowledge

### Episode 7 · Week 7 · 「她剪了短发」

**主题**：Lisa 内心决定的外露信号。心理学梗"重大决定前剪头发"setup。4:6 笑泪反转。

**Beats**：
- **周一**：morning_briefing → 笑天到公司，Lisa **剪短发**了（"想换个心情"）→ Lisa C Vulnerability 实例化 → 下班
- **周二**：Zoe 路过笑天工位"陈笑天先生，下午方便聊一下吗？" → **Decision Moment** 3 选 1 → 下班
- **周三**：笑天发现老周比他早到 1 小时 → 下班
- **周四**：（如果周二选去 Zoe 谈话）笑天去 HR 工位，Zoe 实际是问"你跟 Lisa 协作怎么样" → 笑天意识到这是 Lisa HR 月度面谈的前置 → 下班
- **周五**：weekly_recap → 笑天下班路过茶水间——李阿姨："上一个坐这位置的也是这么想的" → **集内最深的扎心** → 下班
- **周六**：周末
- **周日 8:30**：妈妈视频"天天，妈听你姨说... 你姨说她有个朋友的女儿..." 然后没说完 → 笑天慌——妈妈准备说"相亲" → 下班

**集内高峰**：周一 Lisa 剪短发 + 周五李阿姨"上一个坐这位置的也是这么想的"

**Cliffhanger**：周日晚 Lisa 微信："笑天，下周一我可能要去 HR 那边。但你别担心啊。" → **E8 周四的 setup**

### Episode 8 · Week 8 · 「HR 月度面谈」(Season Finale)

**主题**：S2 高潮。HR 第一次系统性介入 Lisa。Lisa 仍然没"走"——但她说"我可能要走"。3:7 扎为主。

**Beats**：
- **周一**：morning_briefing → Vivian 打卡台贴"本月度月度面谈安排"（无名单）→ 王总监表扬 Lisa "上次客户对接 PPT 不错"——**没人接话** → 下班
- **周二**：（轻笑点） David 4 点已经在写"周一计划"——比 S1 快 1 周到这个状态（他卷的 baseline 又抬高了）→ 下班
- **周三**：晨会 王总监 cue Lisa "Lisa 这边月度 KPI 怎么样" Lisa 答"在赶"——王总监没说什么 → 下班
- **周四**：**14:30 Zoe 走到 Lisa 工位旁** "Lisa 你这边方便的话..." → Lisa 跟 Zoe 去 HR 工位 → **笑天看着 Lisa 走出工位 area** → 下班
- **周五**：weekly_recap → 笑天看 Lisa 工位**空了一下午**——她下午请假了 → 下班
- **周六**：周末
- **周日 8:30**：妈妈视频"**天天，我下个月想去你那边看看你**" → **Decision Moment** 3 选 1 → 下班 → **21:30 Lisa 微信："Zoe 找我谈了月度面谈。她说我'潜力一般'，希望下个月再看看。"** → **Decision Moment** 3 选 1（玩家回 Lisa 的关键决策——决定 S3 finale 路径） → **E8 / S2 finale**

**集内高峰**：
- 周四 14:30 Zoe 找 Lisa（HR 第一次系统性介入显形）
- 周日 21:30 Lisa 微信"我可能要走"（玩家做 S3 关键决策）

**Series Cliffhanger（导向 S3）**：周日晚 Lisa 微信末："**但 Zoe 说下个月再看看。我可能不该太担心**。" —— 她假装乐观。S3 第 1 集（E9）开局：Lisa 周一开始穿正装上班（不再是 polo）

---

## 6. S2 Finale 5 路径表

参考 `season-1-arc.md` §6。S2 finale = HR 月度面谈 + 周日 21:30 Lisa 微信玩家决策。无 game over 路径（per S1 same logic）—— S2 finale 5 路径都"过"，但都"扎不同的痛点"，影响 S3 finale (E12) Lisa 走/留 概率。

| 路径 | 触发条件 | 笑天周日回 Lisa | S3 finale 影响 |
|---|---|---|---|
| **A. 全力陪 Lisa** | S1 路径 A/B + S2 lisa_helped_pps + S2 周二选去 Zoe 谈话 + 周日选 A | "我陪你想办法" | flag `lisa_helped_after_hr` = true → S3 救 Lisa 路径 A 第 1 关键 flag |
| **B. 同情但保持距离** | S1 路径 B/C + S2 lisa_score 在 0~+10 区间 + 周日选 B | "嗯，听你的" | S3 Lisa 仍可能被救但需 E10/E11 累积更多 hero count |
| **C. 路径分裂** | S1 路径 C 帮 David + S2 Lisa 主动找笑天但被冷处理 | "嗯" | S3 finale 路径 A 不可能（Lisa 已经把笑天 mute 了）|
| **D. 病倒 + 摸鱼** | S1 路径 D + S2 病倒次数 ≥ 2 | （笑天没看微信，他在自己 cope） | S3 finale Lisa 走 / 笑天看着 |
| **E. 全程冷处理** | S1 路径 E + S2 lisa_score < 0 | （Lisa 周日没发微信给笑天）| S3 finale 路径 B 必走（Lisa 走，笑天没看到） |

### S2 Finale 5 路径文案锚（剧本层 spec）

笑天周日 21:30 看到 Lisa 微信时的 monitor / phone 场景：
- **A**：手机屏幕 Lisa 头像 + "Zoe 找我谈了月度面谈" → 笑天回"我陪你想办法"
- **B**：同上 → 笑天回"嗯，听你的"
- **C**：同上 → 笑天回"嗯"
- **D**：笑天的手机在床头柜上，屏幕亮但没人看
- **E**：手机界面没新消息

---

## 7. Quality Rubric（per Season-1 §7）

参考 `season-1-arc.md` §7。每集自检 17 条 + S2 specific：

S2 specific 加 5 条：
- [ ] **Lisa quiet sign 累积**：E5（早 8:50 到）→ E6（喝咖啡）→ E7（剪短发）→ E8（HR 谈话）每集 1 个新的 quiet sign，玩家盲读能数出 4 个连续递进
- [ ] **王总监 cue Lisa 频率↑**：S2 比 S1 更频繁，但仍是 background（不要变成王总监主动 expose Lisa）
- [ ] **老周 S2 对话 = 0**：完全沉默（per npcs.md §8）
- [ ] **李阿姨 E7 周五"上一个坐这位置的也是这么想的"**：这句话 S1 没说出来过——S2 第一次说，必保留 verbatim
- [ ] **妈妈 E8 周日"我下个月想去你那看看你"**：第一次主动说要来——必保留 verbatim
- [ ] **Vivian C Vulnerability E5**：揭穿 S1 草莓周融资真相（"D 轮被打回")——必保留
- [ ] **林姐 S2 仍不出场**：deliberate restraint

---

## 8. S1→S2 Migration Note（关键设计冲突）

> **DESIGNER FLAG**: S1 episode-3.ink (Round 2 worker output) currently has **Lisa 剪短发 in E3 (S1 Day 15 周一)**. But series-structure.md + 本 outline both say **剪短发 = E7 (S2)**. There's a real conflict.

**Resolution choices** (decision needed before episode-5/6/7/8.ink can be written):

**Option A**: Remove Lisa 剪短发 from S1 episode-3.ink + add to S2 episode-7.ink
- Pro: Tightens narrative (剪短发 → HR 谈话 1 周间隔)
- Con: Modify Round 2 worker output (their effort), need 1 .ink edit

**Option B**: Keep Lisa 剪短发 in S1 E3 (as worker wrote) + S2 E7 use a different Lisa C Vulnerability
- Pro: No worker output change
- Con: Lisa 剪短发 → HR 谈话 5 集间隔太长 (week 3 → week 8)，节奏松

**Designer recommendation**: **Option A**——剪短发 是关键心理学梗，跟 HR 谈话距离要近。worker 误植到 E3 不需要心疼（修一个 stitch 而已）。具体 fix：
- episode-3.ink Day 15 Event 1 "Lisa 剪短发" stitch → 改成"Lisa 今天迟到 5 分钟"或类似 quiet sign
- episode-7.ink Day 29 Event 1 = "Lisa 剪短发"（新 episode-7.ink 由分身按本 outline §5 E7 周一 写）

**待 user verify Option A**，确认后下一波 ink 翻译就能开始。

---

## 9. 给分身的使用说明（写 episode-5/6/7/8.ink 时）

参考 `episode-generation-brief.md`（S1 时写的 brief）。S2 时使用同样流程：
1. 读 reference（series-structure.md / 本 season-2-arc.md / npcs.md / protagonist.md / tone-bible.md / episode-1.ink 作 .ink syntax sample）
2. 按 S2 outline §5 per-episode beat sheet 写 4 个 .ink 文件
3. 每个文件 ~600-700 行（参考 episode-1.ink 体量）
4. 每个 stitch 含 # scene / # time tag + `~ check_state_after_choice()` 调用 + `-> next_stitch` divert
5. 每个 NPC archetype 实例化：S2 是 C Vulnerability + D Finale 重点集，参考 §3 表
6. cross-NPC 同框场景至少 2 个 / 集（参考 §4 矩阵）
7. 笑泪比例严格按 §1 表（E5=7:3 / E6=6:4 / E7=4:6 / E8=3:7）
8. 提交时按 `episode-generation-brief.md` §8 提交格式

---

## 10. 设计自检

- [ ] 4 集每集都有"想知道下一集"的 cliffhanger
- [ ] Lisa 弧光 quiet sign 累积 4 集（早到 → 咖啡 → 剪短发 → HR）—— 节奏渐进
- [ ] David / 王总监 / Zoe / 李阿姨 / 妈妈 / Vivian / IT 小马 / 老周 各自的 S2 行为都有特定 beat (per §3)
- [ ] cross-NPC 同框场景至少 7 个（per §4 矩阵）
- [ ] 笑/泪曲线（7:3 → 6:4 → 4:6 → 3:7）让 S2 finale 扎到底有铺垫
- [ ] S2 finale 5 路径都"过"但都"扎不同痛点"（per §6 表）
- [ ] 老周 S2 对话 = 0（不破坏 S1 唯一对话的稀缺性）
- [ ] 林姐 S2 仍不出场
- [ ] 走/留**不在 S2 finale**（S3 finale = E12 才走/留）
- [ ] S2→S3 cliffhanger 让玩家想看下一集

---

## 11. ❌ S2 不能做的事

- 不要让 Lisa 在 S2 决定走或留（那是 S3 finale）
- 不要让王总监对 Lisa 直接讲 "潜力一般"（那是 Zoe 的工作 / HR 月度面谈才说）
- 不要让 David 在 S2 燃尽（S6 finale）
- 不要让老周说出第二句话（S1 唯一对话已耗尽）
- 不要让林姐出场（S3 finale 路径 A 才登场）
- 不要让玩家在 S2 finale "救" Lisa——只能 setup S3 路径
- 不要给 Lisa 完整 backstory expose（她的真实想法仍 ambiguous，只通过她的小动作累积）

---

## 12. 下一步

1. **User verify**：本 S2 outline + §8 migration decision (Option A vs B) 是否 OK
2. **If OK**：可以同时启动一个新 ink 写作分身 session，按本 outline 写 episode-5.ink → episode-8.ink（参考 episode-1.ink 作为 .ink syntax sample）
3. **Designer next**：S3 outline（Lisa finale + 林姐登场 + S3 路径 A/B 5 路径）
