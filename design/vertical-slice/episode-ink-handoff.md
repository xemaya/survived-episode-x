# W3 · Ink Content Cleanup + Season 2 Writer · Handoff Brief

> Status: 第 1 版
> Author: Game Designer (GM)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session** — 新启动的 Claude Code session

---

## 0. 你的处境

`survived-episode-x` 是反向 KPI 中文职场生存模拟，TS+Vite+PixiJS+Tauri+Ink 栈。叙事内容写在 `design/vertical-slice/*.ink`，编译成 JSON 由 inkjs runtime 跑。

你是 **Ink Content Worker**。前面有 2 轮 ink 写作（S1 4 集 + 60 daily choices）已 closed。现在 GM 给你 2 件活：

1. **S1 Cleanup**：修一处 S1 episode-3.ink 的设计冲突（Lisa 剪短发位置）
2. **S2 Writer**：写 episode-5.ink ~ episode-8.ink（4 个新文件，基于 `season-2-arc.md` 完整 outline）

完成后 **GM (我) + QA worker** 会 review。不通过打回。

---

## 1. 必读 reference（按顺序）

1. **`design/vertical-slice/season-2-arc.md`** — **你的主要 spec**。S2 outline 含 per-NPC arc / cross-NPC matrix / per-episode beat sheet / S2 finale 5 路径 / Quality Rubric / §8 migration note
2. **`design/vertical-slice/episode-1.ink`** — designer Day 1+2 morning 样例 + S1 完整 .ink syntax 锚（VAR 声明 / # tag conventions / stitch 结构）
3. **`design/vertical-slice/episode-3.ink`** — **你要 cleanup 的对象**（Round 2 worker 翻译稿，含 Lisa 剪短发误植到 Day 15）
4. `design/vertical-slice/episode-generation-brief.md` v2 — Round 1 写 S1 时的 brief，保留作为 Ink syntax + tone reference
5. `design/vertical-slice/season-1-arc.md` v2 — 理解 S1 上下文（你写的 S2 接续 S1 finale 的 5 路径分支）
6. `design/vertical-slice/protagonist.md` — 笑天 voice
7. `design/vertical-slice/npcs.md` v2 — 10 NPC 长弧光
8. `design/vertical-slice/tone-bible.md` v2 — 5 写作原则

---

## 2. 任务 A — S1 Cleanup（Lisa 剪短发 migration）

**问题**：`episode-3.ink` Day 15 morning Event 1 当前是 "Lisa 剪短发"。但 `season-2-arc.md` §8 + `series-structure.md` 都说**Lisa 剪短发 = E7 (S2)**，不是 S1。User 已 verify 走 **Option A**（移走）。

### 你要做

1. **Open** `design/vertical-slice/episode-3.ink`
2. **Find** Day 15 morning Event 1 那个"Lisa 剪短发"的 stitch（看起来 around line 80-140 之间，stitch 名 `day_15_event_1_lisa_short_hair`）
3. **Replace** Lisa 剪短发 with a different Lisa C Vulnerability quiet sign — **比剪短发轻一档**的小变化。Option：
   - **推荐**：**Lisa 桌上多了一瓶眼药水**（quiet sign：她加班到失眠 / 用眼过度）。配 1-2 行笑天内心独白
   - 或：Lisa 周一**比平时早到 30 分钟**（quiet sign：她睡不好或想多挤时间）
   - 或：Lisa 中午**没拼奶茶就回工位敲键盘**（quiet sign：她不再 small talk）
4. 重命名 stitch：`day_15_event_1_lisa_short_hair` → `day_15_event_1_lisa_eye_drops`（per option 选择）
5. 更新对应的 weekly_recap stitch + daily_recap text，确保不再 reference 剪短发
6. 跑 `pnpm ink:build` verify 编译过 + 0 fatal errors
7. （optional）同时 sweep 全 4 个 S1 episode .ink 看是否还有 "剪短发" 的 callback 文本——有则一并改

**关键**：剪短发 motif **完全保留给 S2 episode-7.ink**（你下一步任务 B 中会写）。S1 内不再出现"剪短发"3 字。

---

## 3. 任务 B — S2 Episode Writer（episode-5/6/7/8.ink）

按 `season-2-arc.md` outline，写 4 个 .ink 文件。

### 输入 / 输出

| 输入文件 | 输出文件 |
|---|---|
| `season-2-arc.md` §5 E5 beat sheet | `design/vertical-slice/episode-5.ink` (新建) |
| `season-2-arc.md` §5 E6 beat sheet | `design/vertical-slice/episode-6.ink` (新建) |
| `season-2-arc.md` §5 E7 beat sheet | `design/vertical-slice/episode-7.ink` (新建) — **含 Lisa 剪短发** |
| `season-2-arc.md` §5 E8 beat sheet | `design/vertical-slice/episode-8.ink` (新建) — Season Finale = HR 月度面谈 |

每集 **1500-2200 行 .ink**（参考 episode-1.ink 体量）。每个文件顶部 INCLUDE episode-1.ink（继承 VAR 声明 + helper functions）。

### 每个 .ink 文件结构（套 episode-1.ink 模板）

```ink
// ============================================================================
// Episode N · Week N · 「主题」
// ============================================================================
//
// Status: 第 1 版 (W3 写)
// Author: 分身 CC session (Round 1, 季 2)
// Last Updated: 2026-05-XX
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
//
// 设计目标 (摘要 from season-2-arc.md):
//   1. ...
//   2. ...
// ============================================================================

INCLUDE episode-1.ink

// E5 entry
-> episode_5

// ============================================================================
// Episode 5 主入口
// ============================================================================

=== episode_5 ===
# scene: home
# time: monday_morning_week_5
-> day_29_morning_briefing  // (E5 = 第 5 周 = day 29-35)


// ============================================================================
// Day 29 · 周一 · 第 5 周第 1 天
// ============================================================================

= day_29_morning_briefing
# scene: home_then_subway_then_office
# time: 7:00_to_9:00
[正文]

* [开始今日]
    -> day_29_event_1_xxxx

[... events, after_work, daily_recap ...]
```

### Day 编号 convention

- E5 = Day 29-35
- E6 = Day 36-42
- E7 = Day 43-49
- E8 = Day 50-56

### NPC archetype 实例化（per `season-2-arc.md` §3）

每集每个 NPC 至少有 1 个 beat（per §3 表）。S2 主要 archetype 是 **C Vulnerability** + **D Finale**（per §2）。每个 stitch 用以下 # tag 标注：

```ink
// NPC archetype: Lisa C Vulnerability
```

让 GM review 时能快速对照。

### Cross-NPC 同框（per `season-2-arc.md` §4）

每集至少 2 个场景同框 ≥ 2 个 NPC（孤岛戏 = worker thinking 不过关）。

### 每集末尾 Cliffhanger

每集结束（daily_recap 之后）引向下一集——per §5 的 "Cliffhanger" 行。E8 的 cliffhanger 引向 S3。

---

## 4. 关键约束（不能违反）

跟 `episode-generation-brief.md` v2 一致：

- **每个 stitch 末尾必须** `~ check_state_after_choice()` + `-> next_stitch`（runtime 依赖）
- **每个 stitch 必须有** `# scene` + `# time` tag
- **不允许中文 stitch 名**（ink identifier ASCII-only）
- **不允许 `*X*` 单星号 italic**（被解析为嵌套 choice）—— 用 `_X_` 下划线 italic
- **不允许 `**Speaker**：` inside conditional `{...}` 块**（被解析为嵌套 choice）—— 用 `Speaker：` 直接
- **Designer-written 内容不动**（episode-1.ink 顶部 VAR + helper functions + Day 1/Day 2 morning）

---

## 5. 笑/泪比例 hard rule（per `season-2-arc.md` §1）

| 集 | 比例 | 主基调 |
|---|---|---|
| E5 | 7:3 | 主体仍笑（Vivian 苹果周融资被打回笑点 + David 卷王 + 王总监 cue 戏码） |
| E6 | 6:4 | 笑减少（Lisa 喝咖啡 quiet sign + 妈妈视频"上海买房那个谁") |
| E7 | 4:6 | 反转（Lisa 剪短发 + 老周首说"上一个坐这位置的也是这么想的"）|
| E8 | 3:7 | 扎为主（HR 月度面谈 + Lisa 周日"我可能要走"）|

---

## 6. 7 段 series-finale 级别 quote 必保 verbatim（per `season-2-arc.md` §7）

跟 daily-choices Round 2 verbatim quote 一样，S2 outline 有这些 motif 必须 verbatim 渲染（不能改字）：

- E5: Vivian "**D 轮过会被打回了**" — 揭穿 S1 草莓周真相
- E6: 妈妈视频 "**那个王二家儿子上海买房了**"
- E7 周一: Lisa "**新剪的。想换个心情。**"（短发后第一句）
- E7 周五: 李阿姨 "**上一个坐这位置的也是这么想的。**"
- E8 周日: 妈妈视频 "**我下个月想去你那边看看你**"
- E8 周日: Lisa 微信 "**Zoe 找我谈了月度面谈。她说我'潜力一般'**"
- E8 末: Lisa 微信 "**但 Zoe 说下个月再看看。我可能不该太担心。**"

---

## 7. 验收（GM + QA review）

### 硬性 fail（任意 1 条 = 整批打回）

- 任何 episode .ink < 1200 行（ink syntax overhead 让 .ink 比 markdown 长 ~3x；S2 内容相对 S1 略简，1200 是底线）
- 任何 stitch 漏 `~ check_state_after_choice()` / `-> next` / `# scene` / `# time`
- 中文 stitch 名（ink identifier ASCII-only）
- `*X*` 单星号 italic（要 `_X_`）
- `**Speaker**：` inside `{...}` block（要 `Speaker：`）
- 引入 `npcs.md` 未注册的新 NPC
- Lisa 剪短发**不在 E7 周一**（per Option A migration）
- Lisa 走 / 留**出现在 S2 任何 episode**（S3 finale = E12 才走 / 留）
- 主角内心独白出现"成长 / 突破 / 完美 / 努力"基调
- S1 episode-3.ink Lisa 剪短发**没被 cleanup**

### 软性 fail（≥ 3 条 = 打回）

- 笑/泪比例显著偏离 §5 表
- Cross-NPC 同框场景 < 2 / 集
- §6 verbatim quote 字字未保留
- NPC archetype 漏标 # tag (designer/QA review 不便)
- 选项 > 6 字 + 不是专用职场梗（per tone-bible v2.1 §3）
- 笑天 voice 在某段听起来像别人（不像 32 岁清醒共谋者）

---

## 8. 提交格式

写 `design/vertical-slice/episode-s2-round-1-response.md`：

```markdown
## W3 提交报告 — S1 cleanup + S2 episode 5-8

### S1 cleanup
- episode-3.ink Day 15 Event 1 stitch 已替换：剪短发 → 眼药水
- 重命名 stitch + 更新 daily_recap reference
- 跑 pnpm ink:build：✓ 0 errors

### S2 输出 4 个文件
1. episode-5.ink (新建) — XXXX 行
2. episode-6.ink (新建) — XXXX 行
3. episode-7.ink (新建) — XXXX 行 (含 Lisa 剪短发)
4. episode-8.ink (新建) — XXXX 行 (Season Finale)

### 每集 NPC archetype 完成度
| NPC | E5 | E6 | E7 | E8 |
|---|---|---|---|---|
| Lisa | ✓ | ✓ | ✓ | ✓ |
| David | ✓ | ✓ | ✓ | ✓ |
| ... |

### §5 笑/泪比例自检
- E5: 实际 7:3 ✓
- E6: 实际 6:4 ✓
- ...

### §6 Verbatim quote 保留
- 7/7 全保留 ✓

### Open Questions
- ...
```

---

## 9. 工作量预估

- 读 reference: 1 小时
- S1 cleanup: 30 min（小 patch）
- 写 4 个 .ink：每个 2-3 小时 = 8-12 小时
- 自检 + 提交：30 min
- **总计**：~10-14 小时

---

## 10. 最后

记住：

> **S2 是 Lisa 第一次摇晃。**
> **S2 finale 不走 / 留——只是 Lisa 微信"我可能要走"，玩家做关键决策影响 S3。**
> **剪短发的 motif 留给 E7 周一，不要早泄到任何 S2 其他集。**
> **每集 1 个 quiet sign，玩家盲读能数出 4 个连续递进。**
> **写真，不写好。**

完事写到提交报告，等 GM review。
