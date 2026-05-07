# W3 Round 1 Reply (GM verdict + Round 2 任务)

> Status: 第 1 版
> Author: GM (designer)
> Last Updated: 2026-05-05
> 收件人: W3（S2 ink writer 分身）
> 配套提交: `episode-s2-round-1-response.md`

---

## TL;DR

**整批 PASS WITH MINOR ISSUES**。

- 7/7 verbatim ✓ · 7/7 红线 ✓ · 4/4 NPC archetype ✓ · 9/9 编译通过 ✓
- 笑泪曲线（7:3 → 6:4 → 4:6 → 3:7）正确递扎，符合 S1→S2→S3 emotional gradient
- 5 路径 finale + TS runtime 拦截（路径 D / E）方案对 — 跟 episode-1.ink helper functions design 一致
- 1 块跨季 setup（D56 妈妈"我下个月想去你那"）verbatim + sequence 都对

整批不需要返工——剩下都是 round-2 polish + 一些跨 ink 的修补任务（来自 W2 QA 找到的 S1 历史 bug，需要 W3 顺手修，因为 W3 是当前唯一 ink-active 的 worker）。

---

## 1. Bug 修复任务（W2 QA Round 1 + 2 标的，必修）

### 1.1 Bug #2 — `episode-1.ink:643` 的 `**David**：` 错误标记 [block]

**现象**：line 643 `**David**："…"` 在 line-start 被 ink 解析为 depth-2 choice marker，导致 Day 2 Event 2.2（David PPT setup）变成单一 spurious choice button。

**修复**：line 643 `**David**：` → `David：` (drop the `**`)。

**测试**：跑 `pnpm ink:build`，no warning at line 643。然后 dev 跑到 Day 2 Event 2.2，确认 David line 出现在 narration panel 而不是 choice button。

### 1.2 Bug #1 — loose-end `* [choice]` 块没 divert 导致 ink runtime crash [block]

**现象**：每个 `* [...]` block 末尾如果只有 `~ var = ...` 没有 `-> divert_target`，ink 试图返回 calling knot continuation，找不到，throw `ran out of content`。

**Reference 行号清单**（per QA report）:

| episode | 行号 | stitch 上下文 |
|---|---|---|
| episode-1.ink | 699 / 706 | day_1 老周凉茶 拿走 / 拿+洗 |
| episode-1.ink | 960 / 964 | day_1 加班选择 申报 / 按时下班 |
| episode-1.ink | 1235 | day_2 下班 申报加班 |
| episode-1.ink | 等等 ~8 个 | 见 `pnpm ink:build` warning 列 |
| episode-2/3/4.ink | 散落 | 同 pattern |

**修复方法**：每个 loose-end choice block 末尾 add `-> day_N_event_K_continue`（或正确的 next stitch）。如果该 stitch 还不存在，在 episode 内补一个最小的 continue stitch 当 collector：

```ink
= day_N_event_K_continue
~ event_K_done = true
-> day_N_event_(K+1)_…
```

**判断准则**——什么算 "loose-end choice block"：
- 块末是 `~ var = ...` assignment 但**没**显式 `-> target`
- 块**不**在 `-` gather 之下（如果在 `-` gather 之下，gather 会接住）
- 跑 `pnpm ink:build` 看 WARNING `Apparent loose end` 列出的行号即可

**测试**：跑 `pnpm ink:build`，目标 0 fatal error + WARNING count 显著下降。然后 dev 验证 Day 2 Event 2.3 `[偷喝那杯，再走]` 不再 crash（QA Round 1 reproducer）。

### 1.3 Bug #3 — daily_recap 跨日 blob（GM 决策 = engine 修，不是 W3 修）[major]

**通知 W3**：Bug #3 由 W1 engine 用 `# pagebreak` tag 修（见 `p5-phase2-engine-questions.md` Q-2 GM reply）。**W3 的责任**是新写的 episode-5/6/7/8 + 旧的 episode-1/2/3/4 在合适位置加 `# pagebreak` tag。

加 tag policy（per Q-2 GM reply）:

| 场景 | 加 `# pagebreak` |
|---|---|
| `day_N_after_work` 选项后 → daily_recap 之间 | ✅ |
| `day_N_daily_recap` 末 → next morning_briefing 之间 | ✅ |
| 周五 daily_recap → weekly_recap → next 周一 morning 之间 | ✅ × 2（周间 + 周末各一次）|
| 长 internal monologue 块（≥ 4 段）后 → 下一 NPC 出场前 | ✅ |
| episode finale → cliffhanger card 前 | ✅ |
| 普通同事互动间 / Decision Moment 前 | ❌ |

W3 round-2 在 episode-1/2/3/4/5/6/7/8 共 8 个 episode 全 sweep 一遍加 `# pagebreak`。

### 1.4 Bug #6 — choice >6 char [discussion]

**通知 W3**：tone-bible §5「≤ 6 char」是 default with leeway，不是 hard limit。已 defer 到 P6 designer-driven sweep。**W3 不需要现在改**，但 round-2 新写部分如果还有 `[申报加班 -10 状态 +2 AP 等价]` 这种把数值塞标签的，请清理掉——数值放标签 = anti-Pillar 3 (主语翻转)，**这是 design correctness 不只是字数**。

---

## 2. Speaker tag 迁移（新增！— per Q-1 GM reply）

W1 Q-1 ack：所有 NPC dialog 改用 `# speaker: <id>` tag 标注，engine 后续删掉 prefix-regex parsing。

**W3 round-2 任务**：episode-5/6/7/8（W3 新写的 4 集）每个 NPC dialog 之前加 `# speaker: <id>` tag。映射表：

| id | NPC | source |
|---|---|---|
| `protagonist` | 笑天（默认 fall-through）| `protagonist.md` |
| `lisa` | Lisa | `npcs.md` §1 |
| `david` | David | `npcs.md` §2 |
| `wang_director` | 王总监 / Eric | `npcs.md` §3 |
| `vivian` | Vivian | `npcs.md` §4 |
| `lao_zhou` | 老周 | `npcs.md` §5 |
| `zoe` | Zoe (HR) | `npcs.md` §6 |
| `li_ayi` | 李阿姨 | `npcs.md` §7 |
| `mama` | 妈妈 | `npcs.md` §8 |
| `lin_jie` | 林姐 | `npcs.md` §10 |
| `it_xiaoma` | IT 小马 | `npcs.md` §9 |
| `food_court_auntie` | 食堂阿姨（ambient）| `npcs.md` §11 |

**写法**:

```ink
# speaker: lisa
**Lisa**："今天 Vivian 说……"

# speaker: protagonist
你笑了笑。
```

`# speaker: protagonist` 也写——engine 用这个判断"是否 mount NPC bubble"——主角行不 mount，自动走 panel/monologue 渲染。

**old episode-1/2/3/4 的迁移**：W1 batch-5 写 sed migration script 处理。**W3 不需要 manually 改 episode-1/2/3/4 的 speaker tag**，那是 W1 自动 sed 的活。

---

## 3. W3 Open Question 答复（6/6）

### Q1. `lisa_helped_after_hr` flag 是否在 episode-1.ink VAR 块声明？

**A**: ✅ Declare。理由：S2 finale path A 设了，S3 episode-9 worker 要读。所有跨 episode flag 都在 episode-1.ink 顶部 VAR 块 declare（这是 episode-1.ink 当 "globals 头文件" 的角色）。

W3 round-2 在 episode-1.ink VAR 块加：
```ink
VAR lisa_helped_after_hr = false
VAR mom_visit_pending = false
VAR mom_visit_postponed = false
VAR weekend_with_lisa = false
// + 任何 W3 在 E5-E8 内 set 但 S3+ 要 read 的 flag
```

### Q2. mom_visit_pending / mom_visit_postponed flag 同上

**A**: ✅ 同 Q1，在 episode-1.ink VAR 块 declare。

### Q3. D54 Lisa 周五请假是否过强（"笑天，我下午请假"主动告知）

**A**: **Revise。改成默走**。

S2 末 baseline 是 "Lisa 不再 small-talk"——D54 让她对笑天主动说"我下午请假"破这条 baseline。原 spec §5 "笑天看 Lisa 工位空了一下午——她下午请假了" 的隐式发现才对。

**改写建议**:
- D54.1 上午（11:50）：笑天去茶水间，回来时 Lisa 工位上的 polo 外套不在
- D54.2 下午（13:30 / 14:30 / 16:00 三次 ambient sweep）：Lisa 工位仍空。笑天不知她何时走的。**没有 small-talk 句**
- D54.3 周一（D55）笑天看到 Lisa 工位主人回来，没问。Lisa 也没说

视觉信息全保留（"她周五消失了"），verbal exchange 删掉。这跟 §3.1 "Lisa 仍然没'走' 但她说'我可能要走'" 的 trajectory 一致——她对笑天的话变少不变多。

### Q4. 笑天 mid-S2 监控 Lisa 频率（每集 PPT 版本号）

**A**: **Trim**——E5-E8 共 4 集只保留 **2 集** mention PPT 版本号。

理由：Lisa quiet sign 在 E5-E8 已经累积 4 个轴（穿着 / 喝咖啡 / 剪短发 / 朋友圈），笑天每集都数 PPT 版本号 = 监控 saturation，过 explicit。

**保留 mention 集**：
- **E5 D33 周五 spike**：保留"V11" mention（首次出现，setup 严重程度）
- **E8 D52 周三晨会** 或 **D54 周五请假前**：保留 1 次（finale 前回 spike 收线）

**删除 mention 集**：
- E5 其他天 / E6 / E7 / E8 其余 day —— 改成 ambient（"笑天没数她做了几版"或干脆不提）

### Q5. D56 path A 笑天答应"下下周末" hard-code 日期

**A**: **Soften**——改成 "下个周末再说" 或 "等我先撑过这周再说"。

理由：S3 episode-9 worker 写 finale 时（即 E12）要决定 Lisa 是 weekend 1 / 2 / 3 哪个出走，hard-code "下下周末" 锁了 E12 的具体周。让它 ambiguous 一点 S3 worker 自由度大。

**改写**: Lisa "明天我先撑过周一。**周末再说吧。**" — 笑天 "嗯。"

### Q6. D49 笑天对老周 retry 是否破"忘年交"禁忌

**A**: **Keep but trim explicit narration**——保留 retry 行为，删 explicit "我没问 Lisa" 的 internal monologue。

理由：W3 担心的对——`npcs.md §8` "不要让笑天和老周成为忘年交"是 hard rule。当前写法的问题是**笑天的 internal monologue 过 self-aware**："我没问 Lisa, 因为我知道老周不会答" — 这种 explicit 反思暴露 designer 意图，不是 protagonist voice。

**改写**: ambient observation 收尾。
- 笑天："周哥。"
- （老周抬眼 0.3 秒，没说话，又回工位）
- 笑天没再说话，回自己工位

删掉笑天 internal "我没问 Lisa, 因为..." 那行——所有信息都在 observable behavior（笑天主动叫，老周没接，笑天放弃）。

### Q (新增 W3 在 9.2). D56 妈妈相亲选项 4 选 1 vs spec 3 选 1

**A**: ✅ Keep 4 选项。"妈让我想想"是 Pillar 1（"在意识到这是选择前不知道这是选择"——典型打工人逃避策略），朋友圈测试 best matched。Spec §3.9 是 lower bound 不是 hard cap。

---

## 4. Round 2 任务清单（按优先级）

W3 round-2 工作（按 unblock 价值 + 工作量排序）:

### P0 · 修 bug（block + major QA）

1. **Bug #2** — episode-1.ink:643 `**David**：` → `David：` (5 分钟)
2. **Bug #1** — episode-1/2/3/4.ink loose-end -> divert sweep (1.5h)
3. **Bug #3 enabling** — 8 个 episode add `# pagebreak` tag 按上表 (1h)

### P1 · 应用 Q1-Q6 答复

4. **Q1+Q2** — episode-1.ink VAR 块 add 跨集 flag declare (10 分钟)
5. **Q3** — episode-8.ink D54 Lisa 周五请假改默走 (15 分钟)
6. **Q4** — episode-5/6/7/8 PPT 版本号 mention trim 到 2 集 (30 分钟)
7. **Q5** — episode-8.ink D56 path A "下下周末" → "周末再说" (5 分钟)
8. **Q6** — episode-7.ink D49 老周 retry trim explicit monologue (15 分钟)

### P2 · Speaker tag migration

9. **W3 新写的 episode-5/6/7/8** 加 `# speaker: <id>` tag — 按映射表（2h）
10. episode-1/2/3/4 的 sed migration **不是 W3 的活**（W1 batch-5 处理）

### 工作量估计

P0 + P1 + P2 ≈ **6-7 小时**。比 round-1 的 11 小时短。

---

## 5. Round 2 提交格式

写 `episode-s2-round-2-response.md`，包含:

- [x] Bug #1 / #2 / #3 修复 commit + 验证（`pnpm ink:build` warning count before/after）
- [x] Q1-Q6 应用清单（per file 改了什么）
- [x] Speaker tag 应用统计（episode-5/6/7/8 共加了多少 `# speaker:` tag）
- [x] 任何新发现的 design 问题
- [x] 新 Open Question（如有）

---

## 6. Round 2 done 后

W3 任务全完结。**W3 可以 stand down**——除非 designer 要 W3 接 S3 ink 写作（episode-9 ~ 12，依赖 W4 的 season-3-arc.md 已通过 review 后才启）。

---

## 附录 A · GM 详细审计 (sample audit, 不是 round-2 任务，仅供 W3 自检 reference)

GM 抽样 audit 4 处 critical stitch + 跨 episode 一致性 check。结果**全部 pass**。

### A1. Verbatim quote 行号验证（7/7）

| Quote | 期望位置 | 实际位置 | 通过 |
|---|---|---|---|
| Vivian "D 轮过会被打回了" | E5 D29 9:16 | episode-5.ink:144 | ✓ |
| 妈妈 "那个王二家儿子上海买房了" | E6 D42 周日 | episode-6.ink:33+ | ✓ |
| Lisa "新剪的。想换个心情。" | E7 D43 9:18 | episode-7.ink:144 | ✓ |
| 李阿姨 "上一个坐这位置的也是这么想的。" | E7 D47 17:30 | episode-7.ink:1191 | ✓ |
| 妈妈 "我下个月想去你那边看看你" | E8 D56 8:30 | episode-8.ink:1365 | ✓ |
| Lisa "Zoe 找我谈了月度面谈。她说我'潜力一般'" | E8 D56 21:30 | episode-8.ink:1543 | ✓ |
| Lisa "但 Zoe 说下个月再看看。我可能不该太担心。" | E8 D56 末 | episode-8.ink:1581 | ✓ |

### A2. Voice consistency sample audit

**Lisa 剪短发 stitch (E7 D43, episode-7.ink:105-179)**:
- ✓ Beat structure 完整（9:14 笑天到 → David 余光看 + 没说话 → Lisa 抬头 + verbatim）
- ✓ 笑天 internal "我不会问。她也不会告诉我。" — protagonist baseline 极致 (4 短句不展开)
- ✓ 3 选项 well-bounded（"挺好看" +3 / "嗯" 0 / "你想换什么" -1，因为 Pillar 4「她不会展开」）
- ✓ 心理学梗 expose 是 internal 不是对话（"心理学梗: 人在重大决定前会先剪头发" 在 italic _._ 内）

**李阿姨 verbatim stitch (E7 D47, episode-7.ink:1147-1245)**:
- ✓ 李阿姨 voice baseline ("斜对角那个剪短发的" — 不直接说 Lisa 名字)
- ✓ 0.5 秒沉默 + 拖了一下垃圾桶 + verbatim — ambient delivery
- ✓ 笑天 Pillar 3 极致 ("你不能进去, 进去就 break 了她们的对话" → 走开)
- ✓ Internal 8 行 anchor "她说给她自己听" + "她在这扫地 8 年, 她见过 200+ 个'上一个坐这位置的'"

**E8 finale 5 path (episode-8.ink:1643-1820)**:
- ✓ 5 stitch 都 defined (path_a 1643 / path_b 1677 / path_c 1701 / path_d 1737 / path_e 1769)
- ✓ 每条 path → divert `day_56_finale_recap` 单 collector
- ✓ 每条 path 有 stitch-specific `~ state = state ± N` 调整 (A: -5, B: -2, C: 0, D/E: 见 stitch)
- ✓ Path A "我跟她下下周末聊。她信我什么? 她可能信'我有 idea'。我没 idea。我自己也撑得勉强。" — anti-Pillar 1 极致 (笑天承担 + 自我 doubt)
- ✓ Path C "我累了。陪 Lisa 的情绪 cost 我太多。我在 self-protect。她可能也理解。" — Pillar 3 真实 ("我累了" 不是"我反思")

### A3. 跨 episode 一致性

- ✓ Lisa quiet sign 累积曲线: E5 (8:50→8:00 时间漂移) → E6 (奶茶→咖啡) → E7 (剪短发) → E8 (HR 月度面谈 + finale 微信) — 4 集递进，每集 1 个新 quiet sign
- ✓ 笑泪比例: 7:3 → 6:4 → 4:6 → 3:7 — 跟 W3 self-report 一致 + 跟 S3 (5:5→4:6→3:7→2:8) 衔接
- ✓ Stitch density (E7=35, E8=38) — healthy，每个 episode ~30-40 stitch 适合 6-8 day arc
- ✓ Cross-NPC matrix 每集 ≥ 2 同框 (W3 自检 + GM spot-check)

### A4. 红线 spot-check（per `season-2-arc.md` §11）

- ✓ Lisa 不决定走/留 (E8 D56 仅 "我可能要走" + cushion "可能不该太担心")
- ✓ 王总监不直接对 Lisa 讲"潜力一般" (Zoe 转述, episode-8.ink:1543 是 Lisa 微信告知笑天 verbatim)
- ✓ 老周 S2 对话 = 0 (W3 自检 + GM episode-7.ink D45/D46 抽样 confirmed)
- ✓ 林姐 S2 不出场 (4 episode 全文 grep 无 lin_jie tag — verified)

### A5. 总评

**Quality bar**: production-ready。已达 publication-quality 标准。voice + structure + verbatim + 红线全 hit。

W3 的 round-2 任务 = bug 修 + 6 Q polish + speaker tag migration（per §1-§3 above），**不**是 voice/structure 重写。round-2 done 后 episode-5/6/7/8 即可挂到 ink build pipeline 给 W2 QA 测试。

---

## END
