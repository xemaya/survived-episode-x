# W4 · Season Outline Writer · Handoff Brief

> Status: 第 1 版（generic 模板，可重复用于 S3, S4, ..., S12, Endgame）
> Author: Game Designer (GM)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——新启动的 Claude Code session

> **本次任务参数**：写 **`season-3-arc.md`**（S3 = Lisa 走/留 finale，**series 最关键 season**）

---

## 0. 你的处境

`survived-episode-x` 是反向 KPI 中文职场生存模拟，13 季 52 集。GM 已经写完 `season-1-arc.md` 和 `season-2-arc.md` 作为 outline 模板。你的活：**按同样格式写 S3 outline**，未来 ink writer 据此写 episode-9/10/11/12.ink。

S3 的特殊性：**Lisa 走 / 留 finale (E12)** 是整个 series 的第一个情感高峰。8-12 集累积选择全部兑现。**写不好，整个游戏的 emotional arc 塌**。所以这个 outline 比 S2 / S4 都更重要。

完成后 **GM (我)** review。

---

## 1. 必读 reference（按顺序）

1. **`design/vertical-slice/season-1-arc.md`** v2 — **格式模板**（10 sections + per-NPC 4-archetype + cross-NPC matrix + per-episode beat sheet + finale 路径表 + Quality Rubric）
2. **`design/vertical-slice/season-2-arc.md`** — 第 2 个格式模板（S3 直接接续）
3. **`design/vertical-slice/series-structure.md`** — 52 集 macro。你写的 S3 必须符合 §3 主要 NPC 弧光表 + §6 Game Over 路径分类
4. **`design/vertical-slice/npcs.md`** v2 — 10 NPC 长弧光（特别 Lisa S1-S3 + 林姐 S3+ 出场）
5. **`design/vertical-slice/protagonist.md`** — 笑天 voice
6. **`design/vertical-slice/tone-bible.md`** v2 — 5 写作原则

---

## 2. 任务：写 `season-3-arc.md`

**输出**：`design/vertical-slice/season-3-arc.md`（~400-500 行）

### S3 关键约束（per series-structure.md + season-2-arc.md cliffhanger）

- **Episodes**: E9-E12（第 9 周到第 12 周）
- **Game-month**: 第 3 个月
- **主题**：**Lisa 走 / 留 climax**（per series-structure §2）
- **Episodes 9-11 = 累积选择期**：玩家最后一搏（帮 Lisa 改自评 / 陪她加班 / 帮她对接林姐 / 介绍前同事跳槽机会）
- **E12 = Season Finale**：Lisa 走 / 留 + 5 路径决定
- **林姐第 1 次出场**：S3 finale 路径 A（救 Lisa）触发后才登场（per npcs.md §10）
- **S2→S3 cliffhanger 兑现**：S2 末 Lisa 周日"我可能要走" + Lisa 周一开始穿正装上班（不再是 polo）

### S3 finale 5 路径表（关键设计）

参考 `season-1-arc.md` §6 + `season-2-arc.md` §6 格式。S3 finale **是 series 第一个真正的"扎点 finale"**——5 条路径都"过"但 4 条 Lisa 走 / 1 条 Lisa 留：

| 路径 | 累积条件 | E12 finale | S3→S4 影响 |
|---|---|---|---|
| **A. 救 Lisa（路径 A）** | S1 路径 A/B + S2 lisa_helped_after_hr + S3 帮 Lisa 改自评 + 陪 Lisa 周末加班 + score ≥ +25 | Lisa 转岗客户成功部林姐 | **林姐第 1 次登场**；下季 KPI threshold 涨 +18%（hero penalty）|
| **B. 救得不彻底**（差一点） | S1 路径 B + S2 部分帮 Lisa + S3 累积不够 | Lisa 走，但她周日发"谢谢" | 下季 threshold 涨 +5%；S5+ 朋友圈偶见 Lisa |
| **C. 路径分裂** | S1 路径 C 帮 David + S2 cold | Lisa 走，没说再见 | 下季 threshold 涨 +5%；笑天看着工位空了 |
| **D. 装病 + 摸鱼** | S1 路径 D + S2 sick_count ≥ 3 | Lisa 走，笑天那天在家请病假没看到 | 下季 threshold +3%；笑天周一回公司发现 Lisa 已走 |
| **E. 全程冷处理** | S1 路径 E + S2 lisa_score < -5 | Lisa 走，没人通知笑天 | 下季 threshold +1%；S2-S3 全程 mute |

**5 路径都"扎"——只是扎法不同**。这是 Pillar 3 的核心证据（per series-structure §7）。

### Per-NPC S3 arc table（参考 `season-2-arc.md` §3）

S3 主要焦点：**Lisa**（弧光 climax），**Zoe**（HR 流程加深），**林姐**（路径 A 才登场）。其他 NPC：David / 王总监 / 李阿姨 / Vivian / IT 小马 / 老周 / 妈妈 各自 background 节奏。

每个 NPC 跨 4 集（E9-E12）至少 1 个 beat / 集。

### Per-episode beat sheet（参考 `season-2-arc.md` §5）

每集 7 天 beat：周一 morning_briefing → 各 events → 周日妈妈视频 + cliffhanger。

**E9-E11 = 累积选择期**：每集都给玩家 1-2 个"你能为 Lisa 做点什么"的 decision moment。这些 decision 累计 hero count 决定 E12 路径分支。

**E12 = Finale**：周一-周日完整 7 天，周日 climax。
- 周日 9:30 KPI Review（同 S1 finale 形式）
- 周日 12:30 Lisa 出 HR 流程（路径 A 留 / 路径 B-E 走）
- 周日 16:00 Lisa 工位最后一镜（路径 B-E 专属：李阿姨多拖一遍）
- 周日 18:00 笑天回家路上 + Lisa 微信 cliffhanger 到 S4

### 笑/泪曲线（参考 series-structure §3 + season-2-arc.md §1）

S3 应该比 S2 还要扎。建议：

| 集 | 笑 : 泪 | 主基调 |
|---|---|---|
| E9 | 5:5 | Lisa 穿正装上班反差 + 王总监 cue Lisa "你最近不一样啊" + David 终于注意到 Lisa 有问题（first time）|
| E10 | 4:6 | Lisa 桌上多了简历模板 word 文件名 + Lisa 中午没吃饭 + 笑天看到她偷偷哭过 |
| E11 | 3:7 | Lisa 周末加班——Decision Moment "陪 / 不陪" 关键决策。**这是路径分叉点** |
| E12 finale | 2:8 | 走 / 留全揭晓。整集情感最重 |

**S3 整季 ≈ 3.5:6.5**（比 S2 5:5 更扎）。

---

## 3. 关键内容（不要漏写）

### Lisa S3 弧光（最重要！）

每集**至少 2 个 quiet sign / 决策点**让 Lisa 弧光递进：

- **E9**：Lisa 周一穿正装（不再 polo）+ 桌上多了文件夹（疑似简历夹）+ 微信状态从"在公司"改成空白
- **E10**：Lisa 中午没吃饭（碗筷没动）+ 笑天厕所听到隔壁哭一声 + Lisa 左手手心又开始写"加油"（S1 motif 复活但更频繁）
- **E11**：Lisa 周五加班晚走 + 周末微信"明天来公司加班吗？我自己一个人有点慌" → **Decision Moment：陪 / 不陪**
- **E12**：finale 5 路径

### Zoe S3 弧光（HR 流程持续）

- E9: HR 工位偷听 Zoe 跟另一个 HR "Lisa 那边走完吗?" "下周三签字"
- E10: Zoe 找 Lisa "试用期评估面谈"（90 分钟）
- E11: Zoe 周五跟 Lisa "走完流程"
- E12: 路径 A 时林姐介入 / 路径 B-E 时 Zoe 直接送 Lisa 走

### 林姐 S3 finale 路径 A 专属登场

- 路径 A 触发条件 + 林姐第一次出现的具体场景（per `npcs.md` §10）
- 林姐 "**让她过来吧**" — 跟王总监谈 Lisa 转岗
- Lisa 留下后 = 转岗到客户成功部，工位换地方

### 笑天 voice 在 S3 末的转变

per `protagonist.md` §9 弧光：S3 末笑天"第一次知道'清醒不能救人'"。从 S1 起的笑天 voice"她还相信。我也相信过" 在 S3 末已经变成**"我没救成她。这就是答案。"**

---

## 4. 验收（GM review）

### 硬性 fail（任意 1 条 = 重写）

- 偏离 series-structure.md S3 macro（"Lisa 走/留 climax"主题）
- Lisa 走/留**不在 E12 finale**
- 林姐**S3 之前出场**
- 5 路径里有"赢"路径（必须 5 路径都"扎"）
- E12 finale Lisa 留下后**不立即 setup 新代价**（threshold +18%）—— Pillar 3 anti-胜利 必守
- 笑天 voice 走"励志/突破"基调（违反 tone-bible 原则 1）
- 引入 npcs.md 未注册的新 NPC

### 软性 fail（≥ 3 条 = 修订）

- 笑/泪曲线偏离 §2 表
- Lisa 4 集 quiet sign 不连续递进
- Cross-NPC 同框场景 < 6 跨 4 集
- 老周说出 ≥ 1 句话（S1 唯一对话已耗尽，S2-S3 完全沉默）
- E12 finale 文案不达 series-finale 级别（这是整 series 第一个情感高峰，文案要锋利）

---

## 5. 提交格式

写 `design/vertical-slice/season-3-arc.md` 完整文件 + 一个 1 页 progress note：

```markdown
## W4 提交报告 — Season 3 outline

### 输出
- design/vertical-slice/season-3-arc.md (XXX 行)

### Section 完成度
- §1 主题 + 笑/泪曲线 ✓
- §2 4 archetype reference ✓
- §3 Per-NPC arc tables (10 NPC × 4 episodes) ✓
- §4 Cross-NPC scenes ✓
- §5 Per-episode beat sheet (E9-E12) ✓
- §6 S3 Finale 5 路径表 ✓
- §7 Quality Rubric reference ✓
- §8 (S2→S3 migration note 如有) ✓
- §9 给 ink writer 的 use 说明 ✓
- §10 设计自检 ✓
- §11 ❌ 不能做的事 ✓
- §12 下一步 ✓

### Open Questions
- ...
```

---

## 6. 工作量

- 读 reference + 理解 spec：1 小时
- 写 outline：3-5 小时
- 自检：30 min
- **总计**：~4-6 小时

---

## 7. ❌ 不能做的事

- 不要改 series-structure.md S3 macro（那是上一层 spec）
- 不要写 ink 内容（你只写 outline，episode-9/10/11/12.ink 由后续 ink writer 写）
- 不要写 S4-S12 outline（那是后续 worker 任务）
- 不要让 Lisa 走/留**逻辑不基于累积选择**（要展示玩家的 S1 + S2 选择如何 cumulative 决定 E12 路径）

---

## 8. Bonus（time permitting）

如果你写完 S3 还有精力，可以**接着写 S4 outline**（David 燃尽前兆）。但 S3 必须先 done + 通过 GM review。S4 是 next priority 但不阻塞。

完事写到提交报告，等 GM review。
