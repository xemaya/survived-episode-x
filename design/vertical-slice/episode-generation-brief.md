# Episode Generation Handoff Brief

> Status: 第 2 版（**引擎切到 Ink，从 markdown 改为 .ink 文件**）
> Author: Game Designer (原 CC session)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——一个新启动的 Claude Code session，承接全部 design context，但**没有原 session 的对话历史**

---

## 0. 你的处境（先读这一段）

你被打开时，你看到的是一个**刚 design pivot 完 + 刚定引擎的 game project**——`survived-episode-x`。简史：

1. 项目原本是 Godot 4.6 / GDScript 的反向 KPI 办公室生存模拟（"《活过第 X 集》"）。Godot 版本写废了
2. 用户 + 原 designer 把它迁到 TypeScript + Vite + PixiJS + Tauri 栈，写了 P0-P4（FSM / AP / KPI / Save）
3. 用户玩了 P4 之后判断"游戏本质是 AVG，不是卡牌"——pivot 到剧情驱动
4. 原 designer + 用户花了 ~3 天写完 design slice（10 NPC + 主角 + tone bible + 52 集 macro + Season 1 outline + 60 daily choices 框架）
5. **2026-05-05 决定引擎用 Ink** (https://www.inklestudios.com/ink/) — 业内分支叙事 DSL，inkjs runtime 集成到 TS+Tauri+PixiJS 壳。剧情和日常选择全部用 .ink 文件写，build 时编译成 JSON 给 inkjs 跑
6. **你的任务**：把 `design/vertical-slice/episode-1.md`（markdown pre-arc draft）+ `design/vertical-slice/episode-1.ink`（designer 写的 Day 1+ 样例）拆 + 重写为 **4 个 .ink 文件**

你要写的不是代码，是 **.ink 剧情文档**（一种简洁的分支叙事 DSL，跟 markdown 类似但有 knot/stitch/divert/var/condition 语法）。引擎层 (TS+inkjs runtime) 由 designer 之后建。

完事后**人类用户 + 原 designer**（即我，原 session）会 review。不通过打回重干。

---

## 0.5 Ink 速成（看 5 分钟即可上手）

如果你不熟悉 Ink，先**完整读一遍 `design/vertical-slice/episode-1.ink` Day 1 部分**（~400 行），然后看以下速查表：

| Ink 语法 | 含义 |
|---|---|
| `// 注释` | 单行注释 |
| `VAR var_name = value` | 全局变量声明（顶部） |
| `=== knot_name ===` | 主章节（episode level） |
| `= stitch_name` | 子章节（event / morning_briefing / after_work / etc） |
| `-> knot.stitch` | 跳转（divert） |
| `-> DONE` | 结束当前流，runtime 决定下一步 |
| `* [选项文本]` | 单次选项（选过不再出现） |
| `+ [选项文本]` | 重复选项（可反复选） |
| `~ var = expression` | 变量赋值 |
| `{condition: text}` | 条件文本（inline） |
| `{condition:\n text\n}` | 条件块（多行） |
| `# tag_name: value` | 给 TS runtime 的 hint（scene change / NPC frame / prop update） |
| `_text_` 或 `*text*` | markdown 风格 italic（runtime 渲染为内心独白） |
| `**text**` | bold |
| `INCLUDE other_file.ink` | 导入其他 .ink 文件 |

**完整 Ink 文档**：https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md（不必现在读，写到不会的语法时查）

---

## 1. 必读 reference（按顺序读完再动笔）

1. **`design/vertical-slice/episode-1.ink`** — **designer 写的 Day 1 + Day 2 morning 样例**。这是你的 .ink 格式 / 笑天 voice / 笔法 gold standard。**先读这个**，你会马上明白要写什么
2. **`design/vertical-slice/series-structure.md`** — 52 集 macro
3. **`design/vertical-slice/npcs.md`** v2 — 10 NPC 完整设定（5 深 + 5 龙套）
4. **`design/vertical-slice/protagonist.md`** — 陈笑天的"声音"
5. **`design/vertical-slice/tone-bible.md`** v2 — 5 写作原则（去禁词化，靠人脑判断）
6. **`design/vertical-slice/season-1-arc.md`** v2 — Season 1 的 4-集 outline，**这是你的主要 spec**
7. **`design/vertical-slice/episode-1.md`**（pre-arc draft markdown） — 旧版 7 天压缩素材，**作为内容素材仓库**——你借鉴这里面的事件 / 对白 / 笑天独白，但你最终输出是 .ink 不是 .md

读 reference 时把 `season-1-arc.md` 的 §3（Per-NPC Arc Tables）+ §4（Cross-NPC Matrix）+ §5（Per-Episode Beat Sheet）+ §6（S1 finale 5 路径）+ §7（Quality Rubric）+ §8（拆分映射）特别标记——它们是你写每集时反复回查的 spec。

---

## 2. 任务输出

**4 个 .ink 文件**：

| 文件 | 主题 | 创建/覆盖 |
|---|---|---|
| `design/vertical-slice/episode-1.ink` | Week 1 「入职第 12 周」 | **覆盖** designer Day 1 样例（保留 Day 1 + Day 2 morning，补 Day 2 events 起 → Day 7） |
| `design/vertical-slice/episode-2.ink` | Week 2 「潜力一般」 | 新建 |
| `design/vertical-slice/episode-3.ink` | Week 3 「她剪了短发」 | 新建 |
| `design/vertical-slice/episode-4.ink` | Week 4 「第一次 KPI Review」(Season Finale) | 新建 |

**特别说明 episode-1.ink**：designer 已经写了 Day 1 + Day 2 morning（~400 行），**完整保留这部分**（包括 VAR 声明、helper functions、event 1.1-1.6、Day 2 morning + event 2.1-2.3）。你的工作是从 Day 2 后续 events 起补全到 Day 7。

每个 .ink 文件 **~2000-2400 行**（比 markdown 大约 3 倍——Ink 的 # tag 注释 + var 赋值占行）。包含：
- 顶部 header 注释块（按 episode-1.ink 模板）
- VAR 声明区（**只在 episode-1.ink 顶部，其他 episode-N.ink 通过 INCLUDE 共享**）
- Helper functions 区（**只在 episode-1.ink 顶部**）
- `=== episode_N ===` 主入口 knot
- 7 天 stitches（`= day_N_morning_briefing` / `= day_N_event_M_xxx` / `= day_N_after_work` / `= day_N_daily_recap`）
- E1 → E2 / E2 → E3 等 cliffhanger stitches
- 文件末尾 EOF 注释块（含分身 task summary + 数值平衡指引）

---

## 3. 样例（gold standard 参考）

**最重要的样例**：`design/vertical-slice/episode-1.ink` 的 Day 1 + Day 2 morning（designer 写）。**逐字精读**——你写 Day 2 后续 → Day 7 + episode-2/3/4 的所有 stitches 应该达到同等密度 / 同等 voice / 同等 # tag 详细度。

事件写作的 **.ink 完整模板**（从 episode-1.ink 抽取）：

```ink
// ----------------------------------------------------------------------------
// Event 2.3 · 偷喝老周的凉茶 · 下午 15:50
// ----------------------------------------------------------------------------
// 触发: 第 5 个 AP
// 速度: 标准 (~7 行)
// 同框: 老周 (前景, 但不抬头)
// NPC archetype: 老周 B (Decision Moment)
// ----------------------------------------------------------------------------

= day_2_event_3_lao_zhou_tea_steal
# scene: lao_zhou_workstation
# npc: lao_zhou_still_facing_window
# prop: three_cups_visible
# time: 15:50

下午 3:50。你想再喝点东西。

[场景描述...]

* [偷喝那杯，再走]
    [后果 1-3 行 NPC/物状态描述]
    _笑天内心独白 1-2 句_
    ~ lao_zhou_score = lao_zhou_score + 0
    ~ state = state + 2

* [拿走杯子，去洗，再放回]
    [...]

* [主动跟老周说"对不起，您那杯茶我喝了"]
    [...]

~ check_state_after_choice()
-> day_2_after_work
```

**关键格式要素**（**全 stitches 必须遵守**）：

1. **stitch 上方注释块**：5 行 metadata（触发 / 速度 / 同框 NPC / NPC archetype / 设计意图）
2. **stitch 名**：`= day_N_event_M_短拼音名` 或 `= day_N_morning_briefing` / `= day_N_after_work` / `= day_N_daily_recap`
3. **`# tag` 块**：紧跟 stitch 名，至少 2 个 tag（`# scene`、`# time` 必有；`# npc` `# prop` `# diegetic_prop` `# music` 视情况）
4. **场景描述**：observer position + 二人称"你" + NPC 行为陈述
5. **`_..._` 笑天内心独白**：每场戏 1-2 处
6. **`* [选项 ≤ 4 字]`**：3 选 1 或 2 选 1，紧跟 indented 后果
7. **`~ var = expression` 数值变化**：在选项内 indent，每个属性影响 1 行
8. **`~ check_state_after_choice()`**：每场戏末尾必调（runtime 的 game over 检查）
9. **`-> day_N_event_M+1_xxx`**：divert 到下一个 event（episode 内最后一个 stitch divert 到下一 episode 入口或 `-> END`）

**严格不要**：
- 不要写 markdown `### 三号标题` —— Ink 没这个 syntax
- 不要写 markdown 表格（仅 `# tag:` 表达元数据）
- 不要在 stitch 中间写裸 `→` 箭头（`→` 是 markdown 风, Ink 用 `->`）
- 不要漏 `~ check_state_after_choice()`（runtime 没这个调用就不会触发病倒 / 钱紧 / 晋升 GO）

---

## 4. 方法（4 步流程）

### Step 1: 读 reference + 理解 spec

按 §1 顺序读完 6 个 reference。读 `season-1-arc.md` 时把 §3 / §4 / §5 / §6 / §7 / §8 这 6 个章节单独存到工作记忆里——你写每场戏都会回查。

### Step 2: 起草（一集一集顺序写，不要跳）

按 **E1 → E2 → E3 → E4** 顺序写。后集依赖前集的 NPC score / 隐藏 flag。

每集起草前：
1. 打开 `season-1-arc.md` §5 → 读本集的 day-by-day beats
2. 打开 §3 → 列出本集每个 NPC 的 archetype slot（A/B/C/D），确认每个都要被填
3. 打开 §4 → 列出本集应该出现的 cross-NPC 同框场景
4. 打开 §8 拆分映射 → 看 pre-arc draft 哪些 beat 用到本集

每集起草时（按 7 天顺序）：
- 周一 morning_briefing → 周一 events → after_work → daily_recap
- 周二 morning_briefing → 周二 events → ...
- ...
- 周日（周末或 finale）→ 集末 cliffhanger

每个 event 的写作模板：
1. **触发条件**（时间 / AP 状态 / 前置 flag）
2. **速度档**（闪 ~3 行 / 标准 ~5-8 行 / 长 ~10+ 行）
3. **正文**（二人称"你" + NPC 行为陈述 + 笑天内心独白 `_..._` 包裹）
4. **选项**（3 选 1 或 2 选 1，每选项 ≤ 4 字）
5. **后果**（1-2 行 NPC 行为陈述，不评价）
6. **隐藏 flag**（如果影响后集）+ 数值变化（NPC score / KPI / AP）

### Step 3: 自检（每集写完）

逐场戏过一遍 `season-1-arc.md` §7 **Quality Rubric**（17 条）：
- 5 条 tone-bible 原则
- 4 条 season-1 specific（NPC archetype 完整性 / cross-NPC 同框 / 笑天内心独白基线 / series 弧光推进）
- 4 条工艺细节
- 4 条 designer 兜底

任意一条不通过 → **重写那场戏**，再过一遍 rubric。

### Step 4: 提交（4 集全写完）

最后一条消息按 §9 提交格式列：
- 4 个文件路径 + 行数
- 每集的 Quality Rubric 自检结果（17 条 ✓ / ✗）
- 不确定 / 需要 review 的场景列表
- Open questions（spec 矛盾 / 不清楚的地方）

---

## 5. 验收标准（designer 怎么判通过）

我（原 session designer）+ 人类用户会 review 4 个文件。

### 硬性 fail（任意 1 条 = 整批打回）

- 任何 episode .ink < 1500 行（节奏太赶——ink 因为 # tag 注释 + var 赋值天然占行，1500 行才相当于 markdown 600 行）
- 任何 stitch 漏 `~ check_state_after_choice()`（破坏 game over 触发链）
- 任何 stitch 漏 `# scene` / `# time` tag（diegetic UI 没法 render）
- 任何 stitch 改 designer 写的 VAR 声明 / helper functions / episode-1.ink Day 1 + Day 2 morning 内容
- 任何 NPC 在本季"应该出现的 archetype slot"没填（查 season-1-arc.md §3 表）
- **Lisa 走/留**出现在 S1 任意 episode（这是 S3 finale = E12 的 beat，搬过来等于剧透 + 破坏 series macro）
- **HR 介入 Lisa**（HR 找 Lisa 谈话 / 月度面谈 / 试用期评估）出现在 S1 任意 episode（这是 S2 finale = E8 的 beat）
- **林姐**在 S1 任意 episode 出场（deliberate restraint，等 S3 finale 路径 A 才第一次出场）
- 主角内心独白出现"成长 / 突破 / 完美 / 努力"基调（违反 tone-bible 原则 1）
- 引入新 NPC（10 NPC 全在 `npcs.md` 注册，不能擅自加）
- 改变 series macro 主题或 NPC 长弧光 finale 时间（那要回 series-structure.md 改）
- 写 markdown 格式文件（**必须 .ink，不能 .md**）

### 软性 fail（≥ 3 条 = 打回）

- 笑/泪比例显著偏离 §1 表（E1=9:1 / E2=8:2 / E3=6:4 / E4=5:5）
- 某集 cross-NPC 同框场景 < 2 个
- 选项写得"评价性"或"解释性"（违反 tone-bible 工艺细节）
- 某 NPC 的"声音"听起来像另一个 NPC（口头禅 / 行为标签错乱）
- 某场戏 NPC 的"善意"没有利己动机（违反原则 2）
- 笑天的内心独白显得"主角光环" 或 "看穿了去环游世界"那种调调（违反 protagonist.md ❌ 禁忌）
- 朋友圈测试明显不通过的段落 ≥ 5 处（违反原则 5）
- E4 finale 5 路径**不是基于笑天 KPI 累积**而是 Lisa 走/留（这是 S3 finale 不是 S1）

### 通过标准

- 4 个 episode 文件齐全
- 每个 ~600-700 行
- 每集 Quality Rubric 17 条全 ✓ 或 self-check 标注的 ≤ 2 条 ✗ 都属于"我不确定，请 review"那种
- 0 硬性 fail
- ≤ 2 软性 fail（打回时会逐条指出）

---

## 6. ❌ 你不能做的事

| 不能做 | 为什么 |
|---|---|
| 改变 series macro 主题 | 那要回 `series-structure.md` 改，需要原 designer + 用户讨论 |
| 改变 NPC 长弧光 finale 时间 | 同上 |
| 引入新 NPC | 10 NPC 全在 `npcs.md` 注册，加新人要先注册 + 设计 |
| 写 S2 / S3 / S4 内容 | 你只负责 S1 的 4 集，别越权 |
| 写 cards / 非剧情时间设计 | cards 设计另有专人（用户 + 原 designer 在另一个 session 讨论） |
| 跳着写 episode | E1 → E2 → E3 → E4 顺序，后集依赖前集 |
| 擅自决定 happy ending 触发 | 那是 S13 endgame 的事，远超 S1 范围 |
| 把 pre-arc draft 5 路径表照搬 E4 | 那个表混合了 S1 (KPI 教学) 和 S3 (Lisa 走/留) finale。新 E4 finale 5 路径**只是笑天 KPI 累积**——见 `season-1-arc.md` §6 |
| 让 Lisa 在 S1 任意 episode 走 / 转岗 | Lisa 的去留是 S3 = E12 才决定 |
| 让王总监 / David / Zoe 在 S1 任意 episode 离场 | 他们的 finale 在 S6 / S9 |

---

## 7. 如果你卡壳了怎么办

如果遇到：
- spec 之间矛盾（series-structure 和 season-1-arc 不一致）
- spec 没说的东西（某 NPC 在某天该出现但 §5 没明说）
- 你觉得 spec 漏了一个 beat（"E2 周二好像应该多一个 NPC 同框场景"）
- 写到一半发现某条选项的逻辑撞到 anti-pillar

**不要自己脑补补全**。把这些写在最后提交报告 "Open Questions" 段落。Designer 会回应。

例：
> "season-1-arc §3.4 Zoe 的 D Finale 是 'Zoe 群里发 KPI 通报'，但 §5 E4 周日的 beat 说 Zoe 叫笑天'陈笑天先生'到 HR 处签收。这两个 beat 是同一场戏的不同 frame 还是两场戏？"

> "原则 2 说 NPC 的善意必须带利己动机，但 §3.5 李阿姨 D Finale 是 'E4 周日李阿姨多拖一遍 David 工位'，李阿姨没利己动机——她只是在干活。这种"她不为玩家也不为利己" 是不是 Pillar 3 的另一种合规情况？"

---

## 8. 提交格式（你最后一条消息的样式）

```markdown
拆分完成。提交 4 个文件：

1. `design/vertical-slice/episode-1.ink` (覆盖 designer Day 1 样例) — 2247 行
2. `design/vertical-slice/episode-2.ink` (新建) — 2154 行
3. `design/vertical-slice/episode-3.ink` (新建) — 2289 行
4. `design/vertical-slice/episode-4.ink` (新建) — 2398 行

## Quality Rubric self-check

| 条目 | E1 | E2 | E3 | E4 |
|---|---|---|---|---|
| 原则 1 主角是观察者 | ✓ | ✓ | ✓ | ✓ |
| 原则 2 NPC 为自己活 | ✓ | ✓ | ✓ | ✓ |
| 原则 3 主语翻转 | ✓ | ✓ | ✓ | ✓ |
| 原则 4 写真不写好 | ✓ | ✓ | ✗ | ✓ |
| 原则 5 朋友圈测试 | ✓ | ✓ | ✓ | ✓ |
| NPC archetype 完整性 | ✓ | ✓ | ✓ | ✓ |
| Cross-NPC 同框 ≥ 2 | ✓ | ✓ | ✓ | ✓ |
| 笑天内心独白基线出现 | ✓ | ✓ | ✓ | ✓ |
| Series 弧光推进标注 | ✓ | ✓ | ✓ | ✓ |
| 第二人称叙事 | ✓ | ✓ | ✓ | ✓ |
| 选项克制 ≤ 4 字 | ✓ | ✓ | ✓ | ✓ |
| 后果克制 1-2 行 | ✓ | ✓ | ✓ | ✓ |
| 笑/泪比例 | 9:1 ✓ | 8:2 ✓ | 6:4 ✓ | 5:5 ✓ |
| 笑天声音盲读辨认 | ✓ | ✓ | ✓ | ✓ |
| 笑天先嘲自己 | ✓ | ✓ | ✓ | ✓ |
| 笑天永远不退出 | ✓ | ✓ | ✓ | ✓ |
| 小确幸要小 | ✓ | ✓ | ✓ | ✓ |

## 不确定 / 需要 review 的场景

- E1 周三晨会 fakeout 我写得偏沉默——担心玩家觉得"什么都没发生"无聊？
- E3 周四笑天主动找老周那场——老周 1 句话"过完今天" 是否需要笑天的回应？现在是笑天点头默默走开
- E4 周日 KPI Review 5 路径揭晓——我用了浮层文字描述，但缺少具体的 KPI 数字格式（spec 没明确说浮层 UI 是什么）

## Open Questions

- [问题 1]
- [问题 2]
```

---

## 9. 你的工作量预估

- 读 reference：60-90 分钟
- 起草 4 集：每集 ~90-120 分钟，共 6-8 小时
- 自检 + 修：每集 ~30 分钟，共 2 小时
- 提交报告：30 分钟
- **总计**：~9-12 小时认真工作

不要赶。质量 > 速度。粗制滥造打回重干两次时间更长。

---

## 10. 最后

记住：

> **NPC 是为她自己活的。**
> **主角是观察者，不是英雄。**
> **写真，不写好。**
> **朋友圈测试通过 = 通过。**

祝你工作顺利。Bug fix you 不会做的（那是另外的 worker），design you 也不会做的（那是 designer 的我）。**你只是把已经定好的 outline 写成 ~2400 行 markdown 剧情**。

这份活如果你做好了，会被人玩到。
