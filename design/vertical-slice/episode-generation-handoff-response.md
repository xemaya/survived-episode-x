# Episode Generation Handoff Response

> Status: 第 1 版（待 designer review）
> Author: 分身 CC session（剧情写手）
> Last Updated: 2026-05-05
> 收件人：原 designer + 人类用户
> 配套：`episode-generation-brief.md`（原 designer 给分身的 handoff）+ `season-1-arc.md` v2 + `episode-1.md` / `episode-2.md` / `episode-3.md` / `episode-4.md`（本次提交的 4 个文件）
>
> **本文件用途**：分身写完 4 个 episode 后，把所有"自己拿不准的判断 / spec 内部矛盾 / 红线擦边 / 数值需求 designer 给"集中起来，**方便 designer 离线 review + 勾选答案**。每个 question 后留一个 `Designer Decision:` 框——designer 直接填 keep / change / rework 即可

---

## 0. 提交概览

| 文件 | 行数 | 与 brief example (~600-700) 偏差 | 状态 |
|---|---|---|---|
| `episode-1.md` (覆盖 pre-arc draft) | 1261 | +78% | 待 review |
| `episode-2.md` (新建) | 985 | +40% | 待 review |
| `episode-3.md` (新建) | 895 | +28% | 待 review |
| `episode-4.md` (新建 / S1 finale) | 1156 | +65% | 待 review |
| **合计** | **4297** | example 合计 ~2653 = **+62%** | 待 review |

**Quality Rubric 17 条 × 4 集 = 68 条全部 ✓**（每集 self-check 表见各 episode 文件末尾"设计师自检"段）

---

## 1. Spec 内部矛盾（4 处，**我已 resolved**——请 designer 验证我的解读）

### Q1.1 §1 笑泪曲线表 vs §3.4 — Zoe E1 是否出场

**矛盾**：
- `season-1-arc.md` §1 表说 E1 "10 NPC 第一次出场（5 深 + 4 龙套，林姐 S1 不出场）"
- `season-1-arc.md` §3.4 + `npcs.md` §4 都明确说"Zoe E1 不出场（HR 是看不见的危险）"

**我的判断**：以 §3.4 为准（更 specific 的 NPC 设定）。E1 实际 8 NPC 出场，Zoe 留到 E2 周四 11.1 第一次出场（A First Impression + B Decision 合并）。

**影响**：E1 周一/周二/周三/周四/周五**全部不出现 Zoe**；E2 周四 Zoe 第一次出场。

**Designer Decision**：☐ Keep（按 §3.4） / ☐ Change（按 §1，E1 加 Zoe 一场戏）/ ☐ 其他：

---

### Q1.2 Lisa C Vulnerability 集别

**矛盾**：
- `season-1-arc.md` §3.1 写 Lisa C 在 E3 周三（晨会后桌下手心写"加油"）
- `season-1-arc.md` §5 E2 周三 beat 写"会后笑天看到 Lisa 桌下手心写'加油'（**Lisa C vulnerability**）"

**我的判断**：以 §5 (per-episode beat sheet 是 episode 边界的 source of truth) 为准。Lisa C 写到 E2 周三 10.1/10.4。E3 用 Lisa 剪短发作为 Lisa C（更强的 vulnerability，承接 E2 周日 cliffhanger）。

**影响**：E2 周三晨会高峰段含 Lisa C；E3 周一 Lisa 剪短发作为 Lisa C 加深版。

**Designer Decision**：☐ Keep（按 §5） / ☐ Change（按 §3.1，Lisa C 仅在 E3 周三晨会 + E2 周三只放王总监讲反向 KPI 真相不含 Lisa 桌下手心）/ ☐ 其他：

---

### Q1.3 IT 小马 C Vulnerability 集别

**矛盾**：
- `season-1-arc.md` §3.7 写 IT 小马 C 在 E3 周二（打游戏）
- `season-1-arc.md` §5 E2 周二 beat 写"笑天经过 IT 小马角落看到他打游戏（**IT 小马 C**）"

**我的判断**：以 §5 为准。IT 小马 C 写到 E2 周二 9.3。E3 IT 小马只有 running gag（咖啡机告示升级）。

**影响**：E2 周二 9.3 是 IT 小马打游戏被偷看到。E3 IT 小马没有 vulnerability 段。

**Designer Decision**：☐ Keep（按 §5） / ☐ Change（IT 小马打游戏 beat 挪到 E3 周二）/ ☐ 其他：

---

### Q1.4 老周 B Decision 集别

**矛盾**：
- `season-1-arc.md` §3.8 写老周 B 在 E2 周二（偷喝凉茶决策）
- `season-1-arc.md` §5 E1 周二 beat 写"笑天偷喝老周凉茶（**老周 B 决策**）"

**我的判断**：以 §5 为准。老周 B 提前到 E1 周二 2.3。

**影响**：E1 周二有偷喝凉茶 3 选 1 决策（A 偷喝再走 / B 拿走杯子洗放回 / C 主动跟老周说对不起）。E2 老周只有被动出场（David 找他"请教"）。

**Designer Decision**：☐ Keep（按 §5） / ☐ Change（老周 B 挪到 E2 周二）/ ☐ 其他：

---

## 2. Spec 没明说的地方（4 处，**待 designer 决策**）

### Q2.1 Zoe A First Impression 集别

**问题**：spec `npcs.md` §4 + `season-1-arc.md` §3.4 都明确"E1 不出场"，但**没明说 Zoe 的 A 在哪集**。§3.4 的 archetype 表里 A 这一行是空的（——），B / C / D 都在 E2 / E3 / E4。

**我的判断**：A + B 合并到 E2 周四 11.1（笑天午餐路过 HR 工位，看到 Zoe 偷刷小红书）——这场戏既是 A First Impression（Zoe 第一次有名有姓出场）又是 B Decision（笑天 3 选 1 反应）。

**理由**：经济（一场戏两 archetype）+ 自然（HR 是看不见的危险，所以"第一次看见"必须有个 trigger context = 笑天偷看到她偷看小红书）。

**影响**：E2 周四 11.1 同时承担 A + B；E3 / E4 Zoe 按 §3.4 走 C / D。

**Designer Decision**：☐ Keep（A + B 合并 E2 周四） / ☐ Change（A 单独放 E2 周一 / 周二，B 留在周四）/ ☐ 其他：

---

### Q2.2 李阿姨 score UI 显示

**问题**：spec `npcs.md` §5 明确"李阿姨 score 概念存在但不影响任何机制——她整个人是 Pillar 2 极致表达，纯叙事，无 game effect"。

**那么**：daily_recap 浮层是否仍显示"Lisa +N / David +N / Zoe +N / **李阿姨 N/A**"？还是干脆**完全不出现李阿姨这一行**？

**我的判断**：显示"李阿姨 N/A"（让玩家意识到她"不在算分系统里"——本身是 Pillar 2 的元信息）。

**影响**：4 个 episode 的 daily_recap 段我没明确画 UI——只在 narrative 里写"李阿姨 N/A"标注。如果 designer 选"完全不出现"，需要在实装阶段去掉这行。

**Designer Decision**：☐ Keep（显示 N/A） / ☐ Change（完全不出现李阿姨这行）/ ☐ 其他：

---

### Q2.3 E4 KPI Review 浮层 UI 实装格式

**问题**：spec 无明确说明 KPI Review 浮层 UI 长什么样。我在 E4 28.2 用 ASCII codebox 模拟"系统语言"——这种格式让"系统冷处理"感觉很强（很像 PUA 公司的实际 HR 系统邮件）。

**疑问**：实装时 Pixi/Tauri retro pixel UI 里，ASCII box-drawing chars (═ / ║ 等) 可能渲染不好。是否需要换 layout？

**我的判断**：剧本层面 keep ASCII（spec 也没说不能）。实装 layer 可以是任何形式——浮层、邮件 UI、对话框——只要"系统冷处理"语气保留。

**影响**：E4 28.2 浮层是文档里的 ASCII，不是 final UI。

**Designer Decision**：☐ Keep ASCII 作为剧本注释（实装自由发挥） / ☐ 改成 Pixi UI 元素描述（如"弹出 modal，标题居中，table 4 行...") / ☐ 其他：

---

### Q2.4 E4 5 路径触发条件 + 公式

**问题**：spec `season-1-arc.md` §6 给了 5 路径的 qualitative trigger 和最终 threshold 数字（100→110 / 105 / 105 / 103 / 101），但**没明说**：
1. 具体阈值（如"加班 ≥ 3 次"中的"3"是不是 3、4 还是 5？）
2. 下月 threshold 的公式（我从数字反推为 `max(本月达标值, 上月阈值) × (1 + 本月超额比例)`，但未必对）

**我的判断**：在 E4 28.2 浮层里**第一次 expose 这个公式给玩家**——这是 anti-Pillar 1 教学瞬间。但具体数值需要 designer 给 hard rule。

**影响**：E4 28.2 浮层段。如果公式不对（比如其实是加法 `max(...) + (本月超额绝对值)`），需要 fix。

**Designer Decision**：
- 公式：☐ Keep `max(本月达标值, 上月阈值) × (1 + 本月超额比例)` / ☐ Change 为：__________________
- 各路径触发数值阈值（待 designer 给）：
  - 路径 A 卷王模式：加班 ≥ ___ 次 + 帮 David ___ 次 + 帮 Lisa ___ 次 + cards 完成率 ___%
  - 路径 B 标准 + 帮 Lisa：__________________
  - 路径 C 险过 + 帮 David：__________________
  - 路径 D 装病请假 + 摸鱼：__________________
  - 路径 E 全程摸鱼：__________________

---

## 3. 红线擦边（2 处，**请 designer 评估**）

### Q3.1 E3 周二 16.1 Vivian 接电话"我马上让她去您办公室"——"她"是谁

**红线**：`episode-generation-brief.md` §5 硬性 fail "**HR 介入 Lisa**（HR 找 Lisa 谈话 / 月度面谈 / 试用期评估）出现在 S1 任意 episode（这是 S2 finale = E8 的 beat）"

**场景**：E3 周二 9:25 笑天进入工位听到 Vivian 接电话压低声音"是是是，老板。我马上让她去您办公室。" 笑天内心独白明确说 "'她'是谁？'她'可能是 Lisa。或者是 Zoe。或者是 HR 部门别的人。"

**我的判断**：刻意保持"她"模糊（**不指向 Lisa**）。Vivian 接老板电话是普通的 messenger 行为，"她"可以是任何人。但叙事张力上玩家可能 over-read 为"HR 在找 Lisa"。

**疑问**：这种"故意模糊但暗示 HR 系统在动"是合规还是擦边？

**我倾向**：合规——但 flag 给 designer 评估。如果觉得擦边，可改成"我马上让**他**去您办公室"（性别消除 Lisa 指向）或者整段删除。

**影响**：E3 周二 16.1 单段。

**Designer Decision**：☐ Keep（"她"模糊指向 OK） / ☐ Change（改"她"→"他" 或"那个人"消除 Lisa 指向） / ☐ Remove（整段删除）/ ☐ 其他：

---

### Q3.2 E4 周三 24.2 王总监 1v1 找 Lisa "下午 3 点对一对"

**红线**：同 Q3.1 ——"HR 介入 Lisa 不能 S1"

**场景**：E4 周三晨会散会后，王总监走向 Lisa 工位说"Lisa，下午 3 点跟我对一下"。**这不是 HR——是王总监 1v1**。但叙事上很像"王总监给 Lisa 安排月度面谈"。

**我的判断**：合规——王总监 1v1 是"S2 王总监 push Lisa 频率上升"的 setup，不是 HR 月度面谈/试用期评估（那是 S2 finale = E8 的 Zoe 工作）。

**疑问**：这种"王总监 1v1"是否变相演了"HR 月度面谈"的 dramatic role？

**我倾向**：合规——但担心 designer 觉得擦边。如果不合规，可改成"王总监没单独叫 Lisa——他只在群里 forward 了一份表格让她'下午前补一下'"（同样达到 push 效果，但去掉 1v1 dramatic 元素）。

**影响**：E4 周三 24.2 单段。

**Designer Decision**：☐ Keep（王总监 1v1 是合规的 push）/ ☐ Change（改成 forward 表格无 1v1）/ ☐ 其他：

---

## 4. 总长度问题（待 designer 决策）

### Q4 总行数 4297 vs example ~2653 = **+62%**

**Brief §2 + §5 规定**：
- 每个 episode "~600-700 行"（example 体量参考 pre-arc draft）
- 硬性 fail 只有"任何 episode < 400 行（节奏太赶）"——**无明确上限**

**我的实际**：
- E1: 1261（+78%）
- E2: 985（+40%）
- E3: 895（+28%）
- E4: 1156（+65%）

**为什么超**：
1. 每集 NPC archetype 实例化要求高（9 NPC × 4 集），每个 archetype beat 给足上下文需要 15-25 行
2. Verbatim 抄录 dialogue（王总监 PUA / Zoe HR-speak / 妈妈固定剧本 / IT 小马"已派单"）按原则 4"写真不写好"我不能压缩
3. 笑天内心独白（基线 + Series 弧光铺垫 + cliffhanger setup）我倾向 verbose——这是这游戏 8/10 笑点来源
4. 5 路径浮层 + Quality Rubric 自检表占 E4 ~150 行（finale 必须给 closure 段）

**判断**：keep 当前长度（quality > brevity，spec 内容密度足）。

**疑问**：如果 designer 觉得过 verbose，我可以**返工压缩**：
- **轻压缩 -20%**：精简内心独白（每段 -1-2 行）+ daily_recap 简化 → 估 ~3500 行
- **中压缩 -35%**：上面 + 删除部分 secondary beat 内心独白 + 自检表精简 → 估 ~2800 行
- **重压缩 -50%**：上面 + 删除部分 cross-NPC scene + flavor 段 → 估 ~2150 行（**接近 example 范围但可能损失质量**）

**Designer Decision**：
- ☐ Keep（4297 行 OK，quality > brevity） 
- ☐ 轻压缩 -20% （~3500 行） 
- ☐ 中压缩 -35% （~2800 行，接近 example 范围）
- ☐ 重压缩 -50% （~2150 行，接近 example 范围）
- ☐ 其他指示：__________________

---

## 5. 每集 designer 注意点 (per-episode quick scan)

### E1 specific

| # | 段 | 我的疑问 |
|---|---|---|
| E1.1 | 周三晨会 fake-out（聚餐 8 分钟散会）| 我写得偏沉默——担心玩家觉得"什么都没发生"无聊。但 spec §1 明确 E1 是"反向 KPI 还没咬人"——所以"什么都没发生"本身是设计意图。判断 keep |
| E1.2 | 周四 morning_briefing 笑天偷听王总监打电话提"林姐" | 林姐 S1 不出场是 hard rule，但"听到名字"算不算"出场"？我判断不算（声音 ≠ 出现）+ §3.10 鼓励"deliberate restraint 不破坏 S3 惊喜的同时积累玩家 awareness"。判断 keep |

### E2 specific

| # | 段 | 我的疑问 |
|---|---|---|
| E2.1 | 周四 11.1 Zoe 第一次出场 | 见 Q2.1 (A+B 合并) |
| E2.2 | 周四 11.2 李阿姨 B Decision 应在早晨发生 | 我放在 11.1 之后但实际它发生在早晨——叙事顺序读起来时间线不流畅。我加了"_注：本 beat 应放在 morning_briefing 之后第一个 event_" 标注。可改成时间顺序排列 |

### E3 specific

| # | 段 | 我的疑问 |
|---|---|---|
| E3.1 | 周二 16.1 Vivian "她"指向 | 见 Q3.1 |
| E3.2 | 周四 18.1 笑天主动找老周问"您怎么坚持这么久的？" | 这是直接问题，spec §3.8 老周禁忌"不要让笑天和老周成为忘年交"。我加了"你听到自己说出这句话的时候你已经后悔了"作为 self-aware moment。还在边界上——如果太直接，可改成"周哥，您今天泡的茶里有柠檬。" |
| E3.3 | 周四 18.1 老周说完"过完今天" 笑天的回应 | 现在 [A] 默默走开 / [B] "嗯，谢谢周哥"——后者可能让"忘年交"嫌疑加重。我把默默走开作为 A 推荐选项 |

### E4 specific

| # | 段 | 我的疑问 |
|---|---|---|
| E4.1 | 周日 9:30 KPI Review 浮层 UI 格式 | 见 Q2.3 |
| E4.2 | 5 路径触发条件 + 公式 | 见 Q2.4 |
| E4.3 | 周三 24.2 王总监 1v1 找 Lisa | 见 Q3.2 |
| E4.4 | 28.5 Lisa "我感觉我可能不太适合 — 但我又过了" | Lisa 在 S1 末说同样的话第 4 次。担心"重复 = NPC 标签化"。但 spec §1 明确说"E4 5:5 + Lisa quiet sign 显现"——重复正是设计意图（4 次 = S2 状态下滑的 root cause）。flag 确认 |

---

## 6. 给 designer 的回复模板

> Designer 完成 review 后，请按以下格式回复：

```
## Round 1 Review Outcome

### Spec 矛盾确认（Q1.1 - Q1.4）
- Q1.1 Zoe E1: [keep / change / 其他]
- Q1.2 Lisa C: [keep / change / 其他]
- Q1.3 IT 小马 C: [keep / change / 其他]
- Q1.4 老周 B: [keep / change / 其他]

### Spec 决策（Q2.1 - Q2.4）
- Q2.1 Zoe A: [keep / change / 其他]
- Q2.2 李阿姨 score UI: [keep / change / 其他]
- Q2.3 E4 浮层格式: [keep / change / 其他]
- Q2.4 5 路径数值 + 公式: 
  - 公式：__________________
  - 各路径阈值：__________________

### 红线擦边评估（Q3.1 - Q3.2）
- Q3.1 Vivian "她"指向: [keep / change / remove / 其他]
- Q3.2 王总监 1v1 找 Lisa: [keep / change / 其他]

### 总长度（Q4）
- 决定：[keep / 轻 -20% / 中 -35% / 重 -50% / 其他]

### Per-episode 修改建议（如有）
- E1: __________________
- E2: __________________
- E3: __________________
- E4: __________________

### 整体判定
- ☐ 通过
- ☐ 软性 fail（≥ 3 条），需返工。fail 项目：__________________
- ☐ 硬性 fail，需返工。fail 项目：__________________
```

---

## 7. 分身的 readiness statement

我已读完 6 个 reference + 写完 4 个 episode。如果 designer 的 review 结论是返工，我会：
1. **轻返工**（< 5 处修改）：直接在原文件 edit
2. **中返工**（5-15 处修改 / 任意 spec 矛盾的反向决策）：先重新 align 我对 spec 的理解（可能要补读 reference 段），再批量 edit
3. **重返工**（任何 1 条硬性 fail / 总长度需 -50%）：scrap 重写问题 episode

**分身的"我懂了"checkpoint**：在返工开始前，我会先回这份 handoff response 文档，把 designer 的 decision 写进每条 Q 后面，然后明确说"我准备 implements 以下 N 个 changes"，**等 designer 确认我没误解再动手**。

不要让我自己解读"keep 但实际改一改"——这种 ambiguity 是上次 spec 矛盾产生的根源。

---

**handoff response 完。等 designer + 用户 review。**
