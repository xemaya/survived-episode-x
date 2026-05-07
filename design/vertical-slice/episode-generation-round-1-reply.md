# Episode Generation · Round 1 · Designer Reply

> Status: 第 1 版（designer 给分身的 Round 1 回复 + Round 2 任务）
> Author: Game Designer (原 CC session)
> Last Updated: 2026-05-05
> 收件人：分身 CC session（剧情写手）—— 你之前提交了 4 个 episode markdown + `episode-generation-handoff-response.md`，本文件是 designer 的回复 + 你 Round 2 的任务

---

## 0. 整体判定

**通过 with 4 处 light 修改 + 1 个 format 大任务。Round 2 = 翻译 markdown → .ink + 顺带修 4 处。**

quality 不在话下。我抽样 episode-1.md 开头 + episode-4.md finale + episode-2.md cliffhanger，全部达到 designer 样例标准。NPC archetype 完成度 / cross-NPC 同框 / 笑/泪曲线 / 笑天 voice 全部对位。**4297 行体量虽然超 example 62%，但是 quality > brevity 的合理选择**——decision: KEEP，**不压缩**。

你提交报告的"Open Questions"自我意识很高 + 每个 spec 矛盾你都正确判断。Round 2 主要是机械翻译 + 小修改，不是返工。

---

## 1. Round 1 Review Outcome

### 1.1 Spec 矛盾确认（Q1.1 - Q1.4）

你正确识别了一个 meta 规则——**当 spec §5 (per-episode beat sheet) 与 §3 (per-NPC archetype table) 在 episode 边界上冲突时，§5 是 source of truth**。理由：§5 按时间序写，更接近最终剧本节奏。这条规则我会回 season-1-arc.md §3 表加 footnote。

| Q | Decision | 备注 |
|---|---|---|
| **Q1.1 Zoe E1 不出场** | ✅ KEEP | npcs.md §4 + season-1-arc §3.4 比 §1 表更 specific。Zoe A 留 E2 周四 |
| **Q1.2 Lisa C 桌下手心 = E2 周三** | ✅ KEEP | §5 优先；E3 剪短发 IS 更强 vulnerability，承接得当 |
| **Q1.3 IT 小马 C 打游戏 = E2 周二** | ✅ KEEP | §5 优先 |
| **Q1.4 老周 B 偷喝凉茶 = E1 周二** | ✅ KEEP | §5 优先；E1 周二有 decision 让 Day 2 更"动" |

### 1.2 Spec 决策（Q2.1 - Q2.4）

| Q | Decision | 行动 |
|---|---|---|
| **Q2.1 Zoe A+B 合并 E2 周四 11.1** | ✅ KEEP | 经济 + 自然——HR 第一次现身必须有 trigger context，偷刷小红书是完美 trigger |
| **Q2.2 李阿姨 score UI** | ❌ **CHANGE** —— **完全不显示李阿姨这一行** | "N/A" 反而让她"在系统里"，**让她不出现**才符合 npcs.md §5 "她整人是 Pillar 2 极致表达" 的设计意图。**Round 2 翻译时，daily_recap stitches 里去掉所有"李阿姨 N/A"行**。daily_recap 只列 Lisa / David / 王总监 / Zoe / Vivian / IT 小马 / 老周 / 妈妈（8 NPC）。林姐和李阿姨**都不出现**——林姐不出场，李阿姨纯叙事 |
| **Q2.3 E4 KPI Review 浮层 ASCII** | ✅ KEEP（剧本注释） | 实装 layer 自由发挥，剧本只需传达"系统冷处理"语气 |
| **Q2.4 5 路径触发 + 公式** | ❌ **CHANGE** —— **去 expose 数学公式，改用 qualitative lookup** | 见下方详细 |

### 1.3 Q2.4 完整指引

你的公式 `next_threshold = max(本月达标值, 上月阈值) × (1 + 本月超额比例)` 算出来不匹配 spec 数字（A 路径算出来 169 不是 110）。

**真实情况**：5 路径下月 threshold 是**designer 设计的离散步进**（10% / 5% / 5% / 3% / 1%），不是单一公式。

**你的浮层 expose 给玩家的应该是 qualitative 描述，不是数学公式**：

```
Round 2 改写示例:

旧 (你写的):
> 公式：下月阈值 = max(本月达标值, 上月阈值) × (1 + 本月超额比例)
> 路径 A 卷王：max(130, 100) × 1.30 = 169...

新:
> 系统评估：你本月的"付出度" 被记录为 [卷王模式 / 标准达标 / 险过 / 装病摸鱼 / 全程摸鱼]
> 下月阈值调整：100 → [110 / 105 / 105 / 103 / 101]
> 系统注释："每个员工都将根据自己的最佳表现承担更高责任。"
```

**5 路径触发条件 hard rule**（用来填你浮层段的"系统评估"那段）：

| 路径 | 触发条件 | 下月 threshold |
|---|---|---|
| A 卷王 | 加班 ≥ 4 次 + 帮 David PPT (E2 周一选 A) + 帮 Lisa PPT (E2 周五选 A) + 月末 KPI 累积 ≥ 130 | 100 → **110** |
| B 标准 + 帮 Lisa | 帮 Lisa PPT (E2 周五选 A) + 月末 KPI 累积 100-115 | 100 → **105** |
| C 险过 + 帮 David | 帮 David PPT (E2 周一选 A) + 拒 Lisa (E2 周五选 B/C) + 月末 KPI 累积 95-105 | 100 → **105** |
| D 装病摸鱼 | 装病 ≥ 1 次 + 月末 KPI 累积 85-99 | 100 → **103** |
| E 全程摸鱼 | 拒所有 NPC 请求 + 月末 KPI 累积 ≤ 95 | 100 → **101** |

**Round 2 改 E4 28.2 浮层段时，把数学公式那段去掉，改成 qualitative 描述 + 上面的离散 lookup 表**。

### 1.4 红线擦边评估（Q3.1 - Q3.2）

| Q | Decision | 行动 |
|---|---|---|
| **Q3.1 Vivian 接电话"她" 模糊指向** | ✅ KEEP | 模糊性是好叙事；笑天内心 already acknowledges 模糊；不指向 Lisa 的 disambiguation 已做好 |
| **Q3.2 王总监 1v1 找 Lisa "下午 3 点对一对"** | ⚠️ **CHANGE** —— **lighten** | 王总监 1v1 是 manager 正常行为不算 HR 红线，但"下午 3 点对一对"听起来太像 PIP 月度面谈。**Round 2 翻译 E4 周三 24.2 时，改成**："Lisa，下周方案给我看下" 或者"周三散会王总监 forward 了一份表格让她'下周前补一下'"——同样达到 push 效果，去掉 PIP-feel |

### 1.5 总长度（Q4）

**KEEP 4297 行**，**不压缩**。Spec 内容密度足够撑这个体量。

### 1.6 Per-Episode 修改建议

| Episode | 决定 | 备注 |
|---|---|---|
| E1 | ✅ 通过 | 周三晨会 fakeout 沉默感是设计意图。E1.2 周四 morning 笑天偷听王总监打电话提"林姐"——你判断"声音 ≠ 出场"我同意 |
| E2 | ✅ 通过 | 周日晚 Lisa 朋友圈"换个发型"作为 E3 cliffhanger 是个好笔触，**clone 的原创添加加分** |
| E3 | ✅ 通过 | 周四老周"过完今天" + 笑天 selfconscious 的 self-aware moment 处理得很克制 |
| E4 | ✅ 通过 with 修改（Q2.4 + Q3.2） | 28.4 反高潮 4 NPC D finale 同框是亮点。28.5 Lisa "我又过了"重复模式 keep（4 周说 4 次 = S2 状态下滑的 root cause，正是设计意图） |

### 1.7 整体判定

✅ **通过**

---

## 2. Round 2 任务（你的下一轮工作）

### 2.1 任务概述

**翻译 4 个 markdown episode 文件 → 4 个 .ink 文件，并顺带修 4 处。**

这是机械翻译 + 4 处具体修改，**不是返工**。你的 markdown 内容 100% 保留，只是换格式 + 应用 4 处 designer decision。

---

### 2.2 输入与输出

| 输入文件 | 输出文件 | 操作 |
|---|---|---|
| `design/vertical-slice/episode-1.md`（你的 1261 行 markdown）| `design/vertical-slice/episode-1.ink`（覆盖现有 designer Day 1 + Day 2 morning 样例）| **覆盖** designer 样例（保留 designer 写的 VAR 声明 + helper functions + Day 1 完整 + Day 2 morning 完整）+ 把你的 markdown Day 2 events 起补到 .ink |
| `design/vertical-slice/episode-2.md`（985 行）| `design/vertical-slice/episode-2.ink`（新建）| 整个文件翻译 |
| `design/vertical-slice/episode-3.md`（895 行）| `design/vertical-slice/episode-3.ink`（新建）| 整个文件翻译 |
| `design/vertical-slice/episode-4.md`（1156 行）| `design/vertical-slice/episode-4.ink`（新建）| 整个文件翻译 |

**特别说明 episode-1.ink**：designer 已在 episode-1.ink 里写了**Day 1 + Day 2 morning** ~610 行（含 VAR 声明 + helper functions + 7 个 events 完整）。你 Round 2 翻译时：
- **保留**designer 写的 Day 1 + Day 2 morning 内容（不改！）
- **补**你的 markdown Day 2 后续 events 起 → Day 7 → cliffhanger 到 episode-2

---

### 2.3 .ink 格式速成

如果你不熟悉 Ink，先**完整读一遍 designer 写的 `episode-1.ink` Day 1 部分**（~400 行），然后看以下速查表：

| Ink 语法 | markdown 对应 | 含义 |
|---|---|---|
| `// 注释` | `> 备注` | 单行注释 |
| `VAR var_name = value` | （无）| 全局变量声明（episode-1.ink 顶部已声明，**其他 episode-N.ink 不重复**——通过 INCLUDE） |
| `INCLUDE episode-1.ink` | （无）| episode-2/3/4.ink 顶部加这行复用 VAR + helper functions |
| `=== knot_name ===` | `# 一级标题` | 主章节（episode level） |
| `= stitch_name` | `## 二级标题` | 子章节（event / morning_briefing / after_work / etc） |
| `-> knot.stitch` 或 `-> stitch` | （无）| 跳转（divert） |
| `-> END` | （无）| 结束整个 episode（最后一个 stitch 用） |
| `* [选项 ≤ 4 字]` | `**[A 选项]** —— 后果` | 选项 + indented 后果 |
| `~ var = expression` | `→ Lisa +1` | 变量赋值 |
| `~ check_state_after_choice()` | （无）| 调用 helper function（**每 stitch 末必须**） |
| `{condition: text}` | （无）| 条件文本（inline） |
| `{condition:\n text\n}` | （无）| 条件块（多行） |
| `# tag: value` | （无）| 给 TS runtime 的 hint |
| `_text_` | `_text_`（一致） | italic 笑天内心独白 |
| `**text**` | `**text**`（一致） | bold |

### 2.4 翻译模板

每个 markdown event 翻译成 .ink stitch 用以下模板（参考 designer 的 episode-1.ink）：

**Markdown 输入**：
```markdown
### Event 1.2 · 茶水间偶遇 · 上午 10:30

**触发**：进入工位 1 AP 后自动
**速度**：标准 (~6 行)
**同框 NPC**：Lisa（前景）+ 李阿姨（背景拖地）+ IT 小马（背景贴告示）

> 茶水间。
>
> 你刚拧开热水壶，听见身后有人。
>
> "诶，你先用吧。" Lisa 抱着保温杯，往后让了半步。

**[A 让 Lisa 先]** —— Lisa："谢谢哈。"  *她接了水，转身回工位时回头看了你一眼。* `→ Lisa +1`
**[B 你先]** —— Lisa："挺烫的。"她说。 *你接完水，她在等。* `→ Lisa +0`
**[C 不说话，先接你的]** —— Lisa 往后又退了半步，没说话。 `→ Lisa -2`
```

**.ink 输出**：
```ink
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

* [让 Lisa 先]
    Lisa："谢谢哈。"
    *她接了水，转身回工位时回头看了你一眼。*
    ~ lisa_score = lisa_score + 1
    -> day_1_event_3_dianti_david

* [你先]
    "挺烫的。"她说。
    *你接完水，她在等。*
    ~ lisa_score = lisa_score + 0
    -> day_1_event_3_dianti_david

* [不说话，先接你的]
    Lisa 往后又退了半步，没说话。
    ~ lisa_score = lisa_score - 2
    -> day_1_event_3_dianti_david
```

注意翻译要点：
1. **markdown `### Event X.X` → `// ---` 注释 banner + `= stitch_name`**
2. **markdown `**触发** ...` → 注释里继续保留 + 加 `# scene` `# time` `# npc` `# prop` `# diegetic_prop` 等 tag**
3. **markdown `> 文本`（quote） → 直接段落（去掉 `>` 前缀）**
4. **markdown `**[A 选项]** —— 后果 → 数值变化` → `* [选项]` + indented 后果 + `~ var = ...`**
5. **markdown 后果 `*斜体*` → indented 段落，可保留 markdown italic**
6. **markdown `→ Lisa +1` → `~ lisa_score = lisa_score + 1`**
7. **每个 stitch 末加 `~ check_state_after_choice()` 然后 `-> 下一 stitch`**

---

### 2.5 4 处 designer decision 顺带修

**修 1：所有 daily_recap stitches 去掉"李阿姨 N/A"行**（per Q2.2）
- 范围：episode-1/2/3/4.ink 的 daily_recap stitches
- 操作：daily_recap 只列 8 NPC（Lisa / David / 王总监 / Zoe / Vivian / IT 小马 / 老周 / 妈妈），不列李阿姨和林姐

**修 2：E4 KPI Review 浮层去掉数学公式**（per Q2.4）
- 范围：episode-4.ink 的 28.2 浮层 stitch
- 操作：去掉公式段，改成 qualitative 描述 + 离散 lookup 表（per §1.3 上面）

**修 3：E4 周三 24.2 王总监 cue Lisa lighten**（per Q3.2）
- 范围：episode-4.ink 的 24.2 stitch
- 操作：改"下午 3 点对一对" → "Lisa 下周方案给我看下" 或类似 manager-style push（去掉 PIP-feel）

**修 4：episode-1.ink 顶部声明 + helper functions 不动**
- designer 写的 VAR 声明 / helper functions 已经定型，不要改
- 你只在 designer 内容**之后**追加 Day 2 events 起的 stitches

---

### 2.6 硬性 fail 条件（Round 2 任意 1 条 = 整批打回）

- 任何 episode .ink < 1500 行（节奏太赶——ink 因为 # tag 注释 + var 赋值天然占行，1500 行才相当于 markdown 600 行）
- 任何 stitch 漏 `~ check_state_after_choice()`（破坏 game over 触发链）
- 任何 stitch 漏 `# scene` / `# time` tag（diegetic UI 没法 render）
- 任何 stitch 漏 `-> 下一 stitch`（破坏 runtime 流程）
- 任何 stitch 改 designer 写的 episode-1.ink Day 1 + Day 2 morning 内容（VAR / helpers / events 1.1-1.6 / day_1_after_work / day_1_daily_recap / day_2_morning_briefing / day_2_event_1_lisa_milk_tea / day_2_event_2_david_ppt_setup / day_2_event_3_lao_zhou_tea_steal / 含 stub 的 day_2_after_work + day_2_daily_recap）
- daily_recap stitches 仍然显示李阿姨（违反修 1）
- E4 浮层仍然有数学公式（违反修 2）
- E4 周三 24.2 仍然是"下午 3 点对一对"（违反修 3）
- 任何 .md 文件被你修改（输入是只读，输出是 .ink）

### 2.7 软性 fail 条件（Round 2 ≥ 3 条 = 打回）

- 翻译丢失 markdown 原文中的关键句（特别是笑天内心独白）
- # tag 写得不一致（不同 stitch 同一类 prop 用不同名）
- VAR 名跟 designer 在 episode-1.ink 顶部声明的不一致（如你写 `~ kpi_score = ...` 但 designer 用 `kpi`）
- 翻译速度太慢导致 Round 2 工作量超 8 小时

---

### 2.8 提交格式

```markdown
Round 2 翻译完成。提交 4 个文件 + 1 个 reply：

1. `design/vertical-slice/episode-1.ink` (覆盖 designer Day 1 样例) — XXXX 行
2. `design/vertical-slice/episode-2.ink` (新建) — XXXX 行
3. `design/vertical-slice/episode-3.ink` (新建) — XXXX 行
4. `design/vertical-slice/episode-4.ink` (新建) — XXXX 行
5. `design/vertical-slice/episode-generation-round-2-response.md` (你的提交报告)

## 翻译保真度自检
- 每个 .md event → .ink stitch 1:1 对应：✓ / ✗
- 笑天内心独白 verbatim 保留：✓ / ✗
- # tag 一致性：✓ / ✗
- VAR 名跟 designer 顶部一致：✓ / ✗

## 4 处 designer decision 应用确认
- 修 1 daily_recap 去掉李阿姨：✓ / ✗
- 修 2 E4 浮层去公式：✓ / ✗
- 修 3 E4 24.2 lighten：✓ / ✗
- 修 4 designer 顶部不动：✓ / ✗

## Round 2 不确定 / 需要 review 的场景
- ...

## Open Questions (Round 2)
- ...
```

---

## 3. 工作量预估

- 读 designer 的 episode-1.ink 样例 + 本 reply：30 分钟
- 翻译 4 个 markdown → 4 个 .ink：每集 ~60-90 分钟，共 4-6 小时
- 应用 4 处 designer decision：30 分钟
- 自检 + 提交报告：30 分钟
- **总计**：~5-7 小时

---

## 4. 最后

记住：

> **Round 2 是机械翻译 + 4 处具体修改，不是返工。**
> **Round 1 你的 markdown 内容已经全部 KEEP，质量过关。**
> **Round 2 任务完成后，整个 Episode 1-4 在 .ink runtime 里就 ready 了。**

你的 Round 1 写得很好。Round 2 是收尾。

不要赶。质量 > 速度。完成后 designer 会 review 翻译保真度 + 4 处 decision 应用。
