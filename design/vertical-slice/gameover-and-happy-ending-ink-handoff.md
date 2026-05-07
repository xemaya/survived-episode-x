# W8 · Game Over + Happy Ending Ink Writer · Handoff Brief

> Status: 第 1 版
> Author: Game Designer (GM)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——新启动的 Claude Code session

---

## 0. 你的处境

`survived-episode-x` 是 13 季 52 集反向 KPI 中文职场生存模拟。前面已写：
- 4 个 S1 episode .ink + 4 个 S2 episode .ink（W3 在写）
- daily-choices.ink (60 stitches)
- 1 个 intro knot

但**没人写 endings**。游戏 end 状态有 11 种之多（5 个 GO 类 + 6 个 happy ending variants），全部缺 ink 内容。如果玩家触发 GO，runtime 会 divert 到 `game_over_too_sick` 等 stub knot，然后 `-> END` 直接退出——玩家看不到任何"你被裁了"的剧情体验。

你的活：**写 11 个 ending knot 的 .ink 内容**——5 个 GO + 6 个 happy ending variants。每个 ending = 1 个 self-contained knot，~20-50 行 .ink。

完成后 **GM (我) + W1 dev** 接你的 .ink 到 runtime（dev 会写 TS-side GO trigger 调用 `ink.divertTo('game_over_X')`）。

---

## 1. 必读 reference（按顺序）

1. **`design/vertical-slice/series-structure.md`** §6 — **5 个 GO 类**完整定义（早期 / 中期 / 后期 / 终极 / Endgame 特殊）+ 文案 anchor
2. **`design/vertical-slice/series-structure.md`** §5 — **6 个 happy ending variants** (A 妈妈版 / B 5 月日本机票 / C Lisa 客户成功部祝福 / D 新人叫"陈哥" / E 办公室空了 / F 同学聚会"装病装得好")
3. **`design/vertical-slice/protagonist.md`** §9 — 笑天 series 弧光 + Game Over 经典文案 "恭喜晋升 / 我早就知道"
4. **`design/vertical-slice/tone-bible.md`** v2 — 5 写作原则（这部分写作 tone 比常规 episode 还要严苛——ending 是 series 总结，每字必须扎）
5. **`design/vertical-slice/episode-1.ink`** — Ink syntax sample（VAR 声明 / # tag / stitch 结构 / `~ check_state_after_choice()` / `-> END` etc.）
6. **`design/vertical-slice/series-structure.md`** §7 — Game Over vs Happy Ending 哲学对比

---

## 2. 任务输出

**1 个 .ink 文件**：`design/vertical-slice/endings.ink`

结构：
```ink
// ============================================================================
// Game Over + Happy Ending knots
// ============================================================================
// 5 个 GO scenes (early/mid/late/promotion/endgame) + 6 happy ending variants.
// 总 ~600-800 行。每个 ending knot 由 TS runtime 在触发条件满足时
// 调用 ink.divertTo('game_over_X' or 'happy_ending_X')。
// ============================================================================

INCLUDE episode-1.ink   // 复用 VAR 声明

// ============================================================================
// Game Over · 5 类
// ============================================================================

=== game_over_too_sick ===
// (S1-S3 早期 GO)
// 触发条件: sick_count >= 7 (per check_state_after_choice TS layer)
// ...

=== game_over_appearing_unsuitable ===
// (S1-S3 早期 GO 替代)
// 触发: KPI 累积月末 < 50 (early dismissal)
// 王总监 + Zoe "适应不良" 文案
// ...

=== game_over_last_in_line ===
// (S4-S7 中期 GO "末位淘汰")
// 触发: KPI 不达标 + month >= 4
// ...

=== game_over_org_restructure ===
// (S8-S11 后期 GO "组织调整")
// 触发: KPI 不达标 + month >= 8
// ...

=== game_over_promoted ===
// (S12 / E48 终极 GO "恭喜晋升 = 处刑")
// 触发: promotion_candidate_count >= 6
// 这是最经典的反 Pillar 1 文案 — 见 protagonist.md §9
// ...

// ============================================================================
// Happy Ending · 6 variants
// ============================================================================

=== happy_ending_mom ===
// Variant A "妈妈版"
// 触发: 12 个月内 ≥ 9 次接妈妈周日视频
// ...

=== happy_ending_japan_ticket ===
// Variant B "5 月日本机票"
// 触发: 完成 E50 订机票 beat
// ...

=== happy_ending_lisa_blessing ===
// Variant C "Lisa 客户成功部祝福"
// 触发: S3 finale 路径 A (Lisa 留) + S5+ 笑天接到她至少 2 条微信
// ...

=== happy_ending_called_chen_ge ===
// Variant D "新人叫'陈哥'"
// 触发: S5 后实习生 score ≥ +10
// ...

=== happy_ending_office_quiet ===
// Variant E "办公室空了, 安静真好"
// 触发: 12 个月内 NPC scores 累积 < +50 (cynical 玩家)
// ...

=== happy_ending_same_party ===
// Variant F "同学聚会装病装得好"
// 触发: 12 个月全部 KPI 达标 + 至少 6 个月用了"装病请假"卡
// ...
```

---

## 3. 内容指引（per ending）

每个 ending knot 包含：

### 顶部注释（5-10 行）
- 触发条件（具体 VAR / flag）
- 何时进入（哪 episode / 哪类条件成立）
- 跟前面 series 的 callback（哪些 motif 复活）

### 主体（15-40 行）
**Game Over 类**：
- 1 个王总监 / Zoe 通报场景（用 series-structure §6 anchor 文案）
- 1-2 笑天内心独白（保持 protagonist.md §4 voice）
- **不要"煽情结尾"**——保持 anti-Pillar 1 极致

**Happy Ending 类**：
- 1 个 specific 时间地点 anchor（per series-structure §5 variants 描述）
- 1 个 specific micro-detail（妈妈递碗 / 笑天点支付确认 / 微信 push / 等）
- 1-2 笑天内心独白（保持 voice）
- **不要"赢了"语气**——是"被允许休假"，不是"打败 KPI"

### 末尾
- 1 个最后的笑天 voice（短，2-3 行）
- `-> END`（终止 story flow）

### 复合 ending 规则（per series-structure §5）

如果触发多个 happy ending variant，按"出现顺序"在 E52 周日晚连续播：
- 妈妈版（先触发）
- 然后 happy ending 视觉过场
- 然后 Variant B/C/D/E/F 的微信通知 / 内心独白叠加

`endings.ink` 写每个 variant 单独 knot；**复合逻辑由 TS runtime 处理**（你不写 routing）。

---

## 4. 关键文案 anchor（不要改）

per `series-structure.md` §5 + §6 + `protagonist.md` §9，以下 verbatim 必保（这些是 series 的"招牌时刻"）：

### Game Over 经典

- **terminal GO**：王总监："**小笑啊…陈天啊…我们这边觉得你可能不太适合**。" + Zoe："**陈笑天先生，已为您协调岗位适配方案。**"
- **末位淘汰 GO**：王总监："**这个月我们部门要做一些调整。你这个 KPI 在末位 10%。**"
- **组织调整 GO**：Zoe："**陈笑天先生，公司架构调整，您所在的岗位被合并。**"（不带责怪、不带谈判、流程化执行）
- **恭喜晋升 GO**：王总监："**小陈，我们觉得你这一年表现很稳。明年提你做主管。**" → 笑天 voice："**恭喜晋升。我早就知道。**"

### Happy Ending 经典

- **A 妈妈版**：妈妈："你瘦了。" 笑天："没瘦。" 妈妈："瘦了。" → 笑天 voice："不多。但算我赢一次。"
- **B 5 月日本机票**：笑天 voice："8 年了。我以为我会再去。我会去的。这次。"
- **D 陈哥**：笑天 voice："陈哥。不是天哥。是陈哥。我成了 David。不算多。但算个变化。"
- **F 装病装得好**：老同学："你们那家公司听说裁员了。" 笑天："是。我没被裁。" 老同学："厉害。" 笑天："不厉害。我装病装得好。" → "这是这 12 个月第一次有人觉得我厉害。哪怕原因是装病。"

---

## 5. 验收（GM review）

### 硬性 fail（任意 1 条 = 整批返工）

- 漏写任一 ending（5 个 GO + 6 个 happy ending = 11 个全部）
- 文案 anchor 字字未保留（per §4）
- 笑天 voice 在任一 ending 走"突破/胜利/释怀"基调（违反 anti-Pillar 1）
- happy ending Variant A "妈妈版"如出现"妈妈感叹儿子辛苦"煽情文案
- Game Over 文案有"加油下次再来"鼓励语气（GO 是冷处理，不带情绪）
- 引入 npcs.md 未注册新 NPC
- 缺 `INCLUDE episode-1.ink` 顶部
- 任一 ending knot 漏 `-> END`
- 中文 stitch 名（identifier ASCII）
- `*X*` italic（用 `_X_`）

### 软性 fail（≥ 3 条 = 修订）

- ending 体量 < 15 行 / > 60 行（短了无戏，长了拖泥带水）
- 多个 ending 用同一个开场（每个 ending 应有 specific 视觉/时间 anchor）
- happy ending 语气过 warm（应该是"被允许休假" 不是"打败 boss"）
- Game Over 用"被裁"3 字（应该用 HR-speak / PUA 话术 — 真实公司不会说"被裁"）
- 笑天独白超 5 行（每 ending 1-2 句即可）

---

## 6. 提交格式

写 `design/vertical-slice/endings-round-1-response.md`：

```markdown
## W8 提交报告 — endings.ink (5 GO + 6 happy ending)

### 输出
- design/vertical-slice/endings.ink (XXX 行)

### 11 个 ending knot 完成度
| Ending | Knot 名 | 行数 | Verbatim anchor 保留 |
|---|---|---|---|
| GO terminal "适应不良" | game_over_appearing_unsuitable | 25 | ✓ |
| GO 末位淘汰 | game_over_last_in_line | 30 | ✓ |
| GO 组织调整 | game_over_org_restructure | 28 | ✓ |
| GO 恭喜晋升 | game_over_promoted | 35 | ✓ |
| GO 病倒 | game_over_too_sick | 22 | (无 anchor) |
| Happy A 妈妈版 | happy_ending_mom | 28 | ✓ |
| Happy B 日本机票 | happy_ending_japan_ticket | 25 | ✓ |
| ... |

### Tone bible self-check
- 5 原则 + 4 工艺细节: ✓ all 11 endings
- protagonist.md voice 一致: ✓
- anti-Pillar 1 极致 (no "赢"语气): ✓

### 跟 W1 dev 协作
- TS runtime 需要 hook 到这些 knot:
  - sick_count >= 7 → divertTo('game_over_too_sick')
  - KPI < 50 + month <= 3 → divertTo('game_over_appearing_unsuitable')
  - KPI < 50 + 4 <= month <= 7 → divertTo('game_over_last_in_line')
  - KPI < 50 + month >= 8 → divertTo('game_over_org_restructure')
  - promotion_candidate_count >= 6 → divertTo('game_over_promoted')
  - month >= 12 + KPI 达标 → divertTo('happy_ending_<priority A→F>') (复合时按 priority 顺序)

### Open Questions
- ...
```

---

## 7. 工作量

- 读 reference: 1-1.5 小时
- 写 11 个 ending: 4-6 小时（每个 ~30 分钟）
- 自检 + 提交: 30 min
- **总计**: ~6-8 小时

---

## 8. ❌ 不能做的事

- 不要让 happy ending"完美"（必须 anti-Pillar 1）
- 不要给 Game Over 加"重开按钮 prompt 文案"（runtime 处理 UI，你只写故事内容）
- 不要给 happy ending 装"通关动画"语气文案（"恭喜你完成游戏!" 类型）
- 不要在 ending 里 expose 父亲 / 笑天 backstory secrets（per protagonist.md 禁忌）
- 不要让妈妈在 endgame 现实出现 expose 信息（per npcs.md §9 禁忌——妈妈视频里 only，除非 endgame variant A 厨房）
- 不要让 Lisa 在 happy ending Variant C 之外的任何 happy ending 出现
- 不要让林姐在 happy ending Variant C 出现（她是 S3 finale 路径 A 转岗 destination，但 endgame 时 Lisa 自己写微信，林姐不再 active）
- 不要让 GO 文案"温暖"——保持冷处理 / 流程化

---

## 9. 第 1 个推荐：`game_over_promoted`（最经典 + 最锋利）

**为什么先写这个**：
- 最经典的反 Pillar 1 文案 (per protagonist.md §9)
- 文案 anchor 完整（"恭喜晋升 / 我早就知道"）
- 体量适中（~30-40 行）
- 跟笑天 voice 最贴

**结构 sketch**：
```ink
=== game_over_promoted ===
// 触发: promotion_candidate_count >= 6 (S12 / E48 终极 GO)
// 笑天累积"做得太好" 6 次, 老板把他提升为主管 = 处刑
# scene: workstation_late
# time: month_12_evening

王总监今天找你单聊。

他坐在你工位旁的椅子上，难得这么近。

"小陈, 我们觉得你这一年表现很稳。"

"明年提你做主管。"

"你下属直接对接。"

你说"谢谢王总"。

他点头。

"以后部门 KPI 我们一起 push 吧。你年轻, 该多担一些。"

他走了。

_恭喜晋升。_

_我早就知道。_

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

-> END
```

完事写到提交报告，等 GM + dev review。
