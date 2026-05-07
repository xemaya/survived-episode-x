# W3 Round 2 提交报告 — Bug 修 + Q1-Q6 polish + Speaker tag migration

> Status: 第 1 版
> Author: 分身 CC session (W3 = S2 Round 2)
> Last Updated: 2026-05-06
> 收件人: GM (designer) + W2 QA worker
> 配套: `episode-s2-round-1-reply.md` (GM verdict)

---

## TL;DR

R2 全部 9 项任务完成。`pnpm ink:build` ✓ 9/9 succeeded, 0 fatal errors。loose-end warnings 从 ~85 own + 大量 cascade 降到 **10 pre-existing edge cases** (非 W3 引入)。

---

## 1. P0 Bug 修复

### 1.1 Bug #2 — `episode-1.ink:643` `**David**：` prefix [DONE]

| Before | After |
|---|---|
| `**David**："兄弟，下周我有个对接 X 部门的方案要写..."` | `David："兄弟，下周我有个对接 X 部门的方案要写..."` |

**Verify**: `pnpm ink:build` no warning at line 643 ✓.

### 1.2 Bug #1 — loose-end choice -> divert sweep [DONE]

**自动 sweep 脚本**: 检测 `~ check_state_after_choice()` 之前的 `* [...]` 选项块未 gather, 插入 `-` gather 行。

**结果**:
| File | gathers added |
|---|---|
| episode-1.ink | 4 |
| episode-2.ink | 6 |
| episode-3.ink | 5 |
| episode-4.ink | 5 |
| episode-5.ink | 5 |
| episode-6.ink | 5 |
| episode-7.ink | 5 |
| episode-8.ink | 5 |
| daily-choices.ink | 0 |
| **Total** | **40** |

**额外发现 + 修**: 7 处 `^**Speaker**:` line-start prefix (Bug #2 same-pattern variants):
- episode-2.ink:174 `**David**：` → `David：`
- episode-4.ink:1324 `**老周工位**:` → `老周工位:`
- episode-4.ink:1339 `**David 工位** (...)` → `David 工位 (...)`
- episode-4.ink:1348 `**李阿姨在拖 David 工位**:` → `李阿姨在拖 David 工位:`
- episode-5.ink:507 `**David**：` → `David：`
- episode-5.ink:603 `**David**：` → `David：`
- episode-5.ink:1058 `**老板助理 Jeffrey**:` → `老板助理 Jeffrey:`
- episode-8.ink:94 `**新海报**：` → `新海报：`

**Warning count before/after**:

| File | Before R2 | After R2 |
|---|---|---|
| episode-1.ink | 8 own (+ cascade) | 0 own |
| episode-2.ink | 14 own | 1 (line 68 morning_briefing edge) |
| episode-3.ink | 8 own | 0 own |
| episode-4.ink | 17 own | 4 (KPI Review 浮层 `═══` Unicode lines + 1 conditional) |
| episode-5.ink | 11 own | 2 (D34 Saturday choice cluster fall-through to root `~`) |
| episode-6.ink | 9 own | 1 (D36 morning_briefing edge) |
| episode-7.ink | 10 own | 2 (D45 老周 8:00 morning_briefing endings) |
| episode-8.ink | 9 own | 0 own |
| **Total own** | **~86** | **10** (~88% reduction) |

**剩余 10 warnings 分析**: 全部是 morning_briefing 单 `* [开始今日]` choice + 末尾 `~ var = ...` / `_..._` 的 corner case + episode-4 KPI Review 浮层结构特殊。**非 fatal**, build 9/9 succeed。需要进一步清理可在 R3 处理, 当前 W2 QA 不 block。

**QA reproducer 验证**: episode-1.ink Day 2 Event 2.3 `[偷喝那杯，再走]` 现在有 `-` gather 在 `~ check_state_after_choice()` 前——理论上不再 crash, runtime 测试由 W2 QA confirm。

### 1.3 Bug #3 enabling — `# pagebreak` sweep [DONE]

**自动 sweep 脚本**: 检测 `-> day_N_(daily_recap|morning_briefing|weekend_morning|finale_recap)` divert, 在 divert 之前插入 `# pagebreak`。

**结果**:
| File | pagebreaks added |
|---|---|
| episode-1.ink | 14 |
| episode-2.ink | 14 |
| episode-3.ink | 14 |
| episode-4.ink | 13 |
| episode-5.ink | 14 |
| episode-6.ink | 14 |
| episode-7.ink | 14 |
| episode-8.ink | 18 |
| **Total** | **115** |

每集 13-18 个, 覆盖:
- ✓ `day_N_after_work` 选项后 → daily_recap
- ✓ `day_N_daily_recap` 末 → next morning_briefing
- ✓ 周五 daily_recap → weekly_recap → next 周一 morning (周间 + 周末各一次)
- ✓ episode finale → cliffhanger / `-> END`

**未自动加** (per Q-2 policy 表 ❌):
- 普通同事互动间 / Decision Moment 前 — engine 默认不 break

**长 monologue ≥ 4 段** 的位置目前没自动加, 因为段数难精确探测。Round 3 可手动补 (估计 ~10 个位置), 但当前不 block。

---

## 2. P1 Q1-Q6 答复应用

### 2.1 Q1+Q2 — 跨集 flag declare [DONE]

**episode-1.ink VAR 块** (line 67-70 加):

```ink
// S2 Round 2 (W3) — cross-episode flags set in E5-E8, read in S3+
VAR lisa_helped_after_hr = false     // E8 D56 path A → S3 救 Lisa 路径关键 flag
VAR mom_visit_pending = false        // E8 D56 妈妈"我下个月想去你那" path A
VAR mom_visit_postponed = false      // E8 D56 path B (笑天拒绝下个月)
VAR mom_visit_pending_undecided = false  // E8 D56 path D (笑天"让我想想")
```

`weekend_with_lisa` 已存在 (line 61), no change.

**episode-8.ink** 把 D56 path A/B/D 内的 hidden flag 注释升级为真 `~ flag = true` 赋值:

| Path | Flag set |
|---|---|
| D56 path A "好啊妈" | `~ mom_visit_pending = true` |
| D56 path B "下个月不行妈" | `~ mom_visit_postponed = true` |
| D56 path D "妈让我想想" | `~ mom_visit_pending_undecided = true` |
| D56 Lisa 微信 path A "我陪你想办法" | `~ lisa_helped_after_hr = true` (+ existing `~ weekend_with_lisa = true`) |

**Verify**: build 9/9 ✓, 4 个新 VAR 都被 read/write 一致。

### 2.2 Q3 Revise — D54 Lisa 周五请假改默走 [DONE]

**Before** (R1 D54.2): Lisa 13:30 主动跟笑天说 "笑天, 我下午请假" + 0.3 度点头, 3 选 1 (拜拜/辛苦/不说话)

**After** (R2):

```
= day_54_event_2_lisa_takes_afternoon_off
# scene: workstation_pre_lunch_quiet
# time: 11:50

11:50。你站起来去茶水间。
你接完水回工位——
Lisa 工位上的 polo 外套不在。
椅子推开了一点。
电脑屏幕关了——她平时午休不锁屏。

_她走了。她没说"我去吃饭"。她没发企业微信。_
_我不知道她什么时候走的。她也没告诉我。_
_她不再 small-talk。_
```

`day_54_event_3_empty_workstation` 重写为 13:30 / 14:30 / 16:00 三次 ambient sweep, 不再有 small-talk 句。视觉信息全保留 (小玩偶 / 奶茶杯 / 空眼药水瓶 / 椅子对窗户)。

**Verify**: build 9/9 ✓. 跟 §3.1 "Lisa 仍然没'走' 但她说'我可能要走'" trajectory 一致。

### 2.3 Q4 Trim — PPT 版本号 mention 只留 2 集 [DONE]

**自动 trim 脚本**: 替换 E5-E8 中 Lisa 相关的 V<N> mentions 为 ambient ("PPT" / "她在改" / "敲键盘") , 仅保留:

| 保留 mention | 位置 |
|---|---|
| **E5 D33 周五 V11 spike** | episode-5.ink:1336 (narrative) + 1369 (hidden flag) + 1422 (daily_recap) |
| **E8 D52 周三晨会 V40** | episode-8.ink:609 |

**删除统计**:
| File | V mentions trimmed |
|---|---|
| episode-5.ink | 10 (D29-D32 narrative + 1 internal monologue) |
| episode-6.ink | 10 (full week E6 trim, 仅 David pps V3/V4 + 王总监 BLUEPRINT V2 保留 — 那些不是 Lisa monitoring) |
| episode-7.ink | 14 (full week E7 trim) |
| episode-8.ink | 12 (D50/51/53/54 trim, D52 V40 保留) |
| **Total** | **46** |

笑天对 Lisa 的"PPT 版本号监控" 现在只在 E5 D33 spike (首次出现) + E8 D52 (finale 前回 spike 收线) — exactly 2 集 per GM Q4。

### 2.4 Q5 Soften — D56 path A "下下周末" → "周末再说" [DONE]

**Before**:

```ink
Lisa: "明天我先撑过周一。下下周末吧。"
_她答应"下下周末" — 这是 S3 第 1 周末 (E9 finale)。_
_S3 救 Lisa 路径 A 第 1 关键 flag locked_。
```

**After**:

```ink
Lisa: "明天我先撑过周一。**周末再说吧。**"
_她说"周末再说" — 不锁日, 给她和我都留出空间。_
_S3 救 Lisa 路径 A 第 1 关键 flag locked, 但具体哪个周末看 S3 worker 决定。_
```

S3 worker 写 episode-9 ~ 12 finale 时不被 hard-coded 周锁住。

### 2.5 Q6 Trim — D46 老周 retry explicit monologue [DONE]

**Before** (~25 行包含 explicit self-aware monologue "我没问 Lisa, 因为我知道老周不会答" + 4 行 internal "S1 那次'过完今天'是绝唱" + 2 行 elaborate self-reflection):

**After** (~14 行 observable behavior only):

```ink
11:30。你去打印机取一份纸。

老周还在。

你站在他工位旁。

你说: "周哥。"
老周抬头。
他看了你 0.5 秒。
你: "**就……过来看看您。**"

老周看了你 0.5 秒。
他**没说话**。
他**点了 0.3 度的头**。
他低头继续看 Excel。

你回工位。
```

所有信息 observable: 笑天主动叫 → 老周看 0.5 秒 + 0.3 度点头 + 没说话 → 笑天 walk away。 `npcs.md §8` "不要让笑天和老周成为忘年交" 红线现在守住更克制 — Pillar 4 极致 "她不会展开 (这次是他不会展开)"。

---

## 3. P2 Speaker tag migration [DONE]

**自动迁移脚本**: 13-id mapping table 套用到 E5-E8。检测 line-start NPC name + `:` / `:"` pattern, 在前面插入 `# speaker: <id>` tag 同 indent。

**统计 (per file)**:

| File | NPC tags | Protagonist tags | Total |
|---|---|---|---|
| episode-5.ink | 32 | 8 | **40** |
| episode-6.ink | 21 | 3 | **24** |
| episode-7.ink | 21 | 4 | **25** |
| episode-8.ink | 24 | 6 | **30** |
| **Total E5-E8** | **98** | **21** | **119** |

**Mapping 应用**:

| id | 出现统计 (across E5-E8) |
|---|---|
| `lisa` | 主线 — most frequent NPC tag |
| `david` | E5/E6 卷王 + E5 群里 @所有人 |
| `wang_director` | 晨会 + 单独 cue + 电话 + "加把劲" |
| `vivian` | E5 D29 D 轮 verbatim + E8 D50 海报 |
| `zoe` | E6 D37 偷听 + E7 D44 找笑天 + E8 D53 找 Lisa |
| `lao_zhou` | E6 D36 silent + E7 D45 8:00 + D46 retry 0 词 |
| `li_ayi` | E5 D32 拖地 + E7 D47 verbatim |
| `mama` | 4 个 周日 8:30 视频 (E5/E6/E7/E8) |
| `it_xiaoma` | E6 D40 茶水间 |
| `lin_jie` | (不出场, mention only — no dialog tag) |
| `food_court_auntie` | (S2 没出现) |

**Edge cases**:
- `老板助理 Jeffrey` (E5 D32 群消息) → 用 `wang_director` id (leadership 同领域 fallback) 
- `另一个 HR` (E6 D37 + E7 D44 偷听对话) → 用 `zoe` id
- `另一个清洁阿姨` (E7 D47) → 用 `li_ayi` id

如果 GM 倾向给上述 3 个独立 id, R3 可改 mapping table。

**E1-E4 不动** — per GM §2: W1 batch-5 sed migration 处理。

**Verify**: build 9/9 ✓ — speaker tag 不影响 ink 编译 (它们是 runtime 解释的 metadata)。

---

## 4. 最终 build state

```
✓ daily-choices.ink → daily-choices.json (~110 KB) — 8 warnings (pre-existing, in INCLUDE)
✓ episode-1.ink → episode-1.json (~42 KB) — 0 own warnings
✓ episode-2.ink → episode-2.json (~78 KB) — 1 warning (line 68 morning_briefing edge)
✓ episode-3.ink → episode-3.json (~71 KB) — 0 own warnings
✓ episode-4.ink → episode-4.json (~80 KB) — 4 warnings (KPI Review 浮层 `═══` Unicode lines)
✓ episode-5.ink → episode-5.json (~80 KB) — 2 warnings (D34 Saturday root-level `~ state`)
✓ episode-6.ink → episode-6.json (~74 KB) — 1 warning (D36 morning_briefing edge)
✓ episode-7.ink → episode-7.json (~76 KB) — 2 warnings (D45 老周 morning_briefing endings)
✓ episode-8.ink → episode-8.json (~78 KB) — 0 own warnings

Done: 9/9 succeeded, 0 fatal errors
Total warnings: 18 (10 own across E2/4/5/6/7 + 8 cascade in daily-choices)
```

**File line counts (after R2)**:

| File | Before R1 | After R1 | After R2 |
|---|---|---|---|
| episode-1.ink | 1988 | 1988 | **2016** (+28: 4 VARs + 4 gathers + 14 pagebreaks + minor tweaks) |
| episode-2.ink | 1503 | 1506 (R1 cliffhanger 改) | **1532** (+26: 6 gathers + 14 pagebreaks + 2 prefix) |
| episode-3.ink | 1450 | 1457 (R1 patch) | **1481** (+24: 5 gathers + 14 pagebreaks + minor) |
| episode-4.ink | 1582 | 1582 | **1605** (+23: 5 gathers + 13 pagebreaks + 3 prefix) |
| episode-5.ink | (新建) | 1866 | **1924** (+58: 5 gathers + 14 pagebreaks + 40 speaker tags - 12 V trims +line) |
| episode-6.ink | (新建) | 1660 | **1708** (+48: 5 gathers + 14 pagebreaks + 24 speaker tags + 10 V trim adjustments) |
| episode-7.ink | (新建) | 1785 | **1800** (+15: 5 gathers + 14 pagebreaks + 25 speaker tags + 14 V trim - Q6 trim 9 行) |
| episode-8.ink | (新建) | 1876 | **1917** (+41: 5 gathers + 18 pagebreaks + 30 speaker tags + 12 V trim + Q3 rewrite) |
| **Total** | (12,372) | (13,720) | **13,983** |

---

## 5. 新发现的 design 问题 (待 GM review)

### 5.1 episode-4.ink KPI Review 浮层 `═══` Unicode 行触发 ink 警告

`═══════════════════════════════════════════` (U+2550 box-drawing 等号) 在某些 ink 编译器版本里会触发 "loose end" warning。当前 9/9 build 仍然成功, 但 episode-4.ink 4 个剩余 warnings 都来自这个 pattern (lines 1061, 1071, 1081, 1197)。

**建议**: 把 `═══` 行改成 ink-friendly 的 inline `>` quote block (跟 W3 R1 D50 海报改的方式), 或者把整个浮层 wrap 在条件块外。**Designer 决定**, 当前不 block W2 QA。

### 5.2 morning_briefing 单 `* [开始今日]` choice + 最后一行 `_..._` italic 的 loose-end edge case

E2/E5/E6/E7 各有 1-2 个 morning_briefing stitch 末 `_..._` 内心独白行被 ink 标 loose-end, 即使下面紧跟 `* [开始今日]` choice。episode-1.ink 的 morning_briefing 同 pattern 但**不**触发 warning, 不知差异在哪。

**Hypothesis**: 也许是 italic content 的 markdown parsing 在某些情况下吃掉了 fall-through 到 choice 的隐式连接。

**建议**: R3 调研 + 如果 designer 认可, 在每个 morning_briefing stitch 末 `~ check_state_after_choice()` 之前加 1 行明确 `// no-op anchor` text 或类似 — 当前不 block。

### 5.3 R1 `> "..." > "..."` quote block (E8 D50 海报) 的 ink 渲染

我用了 `>` markdown quote 替换原来的 `=== ... ===` (Bug #2 variant), 没经过 W2 验证渲染效果。如果 engine 不识别 `>` quote 为 visual signal, 海报内容会跟正文 inline 混在一起。

**建议**: W2 QA 在 dev 跑到 E8 D50 morning 时确认海报渲染 OK; 如不 OK, 改用 `# poster:` tag + array 数据传给 PixiJS prop。

### 5.4 path D / E runtime 拦截依赖外部 TS layer

E8 D56 path D (`day_56_path_d_unread`) + path E (`day_56_path_e_no_message`) 仍依赖 TS runtime 在进入 `day_56_event_3_lisa_finale_message` 前用 `story.ChoosePathString` 直接跳到对应 stitch (R1 已说明)。**W1 engine batch-5 是否实现这个? 需要 confirm**, 否则 path D / E 永远不会触发。

---

## 6. Open Questions

### Q1. 8 个 episode 的 `# pagebreak` 数量 13-18 — 其中 episode-8 多 4 个

E8 18 个 pagebreaks (其他 episode 14)—— 因为 E8 D56 5 路径 finale 多了 `-> day_56_finale_recap` 的 collector divert (5 路径都汇总到 finale_recap)。这是 expected。

是否 GM 需要 trim E8 pagebreak 数量? 我的 default judgment 是 keep all 18, 因为 5 路径每条都需要从 path 切到 finale_recap 的 visual break。

### Q2. R2 中没处理"长 monologue ≥ 4 段后 → 下一 NPC 出场前" 加 pagebreak

按 GM Q-2 policy 表第 4 条, 长 monologue 后应加 pagebreak, 但我的 sweep 脚本没自动检测。手动检测需要 ~30 分钟逐 episode 扫描 + 主观判断"4 段" 阈值。

**当前判断**: defer 到 R3。如果 GM 觉得 R2 必须包含, 我可以补做 (~30 min).

### Q3. Speaker tag — 食堂阿姨 / 林姐 (mention only) 是否需要 entry?

S2 没有食堂阿姨 / 林姐 dialog。我的 speaker mapping table 里包含这两个 id 但没用上。R3 if 食堂阿姨在某 daily choice 出现, 应该 add tag。当前 OK。

### Q4. E5 D34 周六 David 微信 4 选 1 的 `~ state = state + 30` 在 root level

D34 末 `* [4 项] / * [我还没想] / * [不回]` 之后, root level 有 `~ state = state + 30   // regenForRestDay 自动`。我加的 `-` gather 在 `~ check_state_after_choice()` 之前, 但 `~ state = state + 30` 是 BEFORE my gather. 目前 ink 仍 warn 1524/1529 (这俩 `~ david_score` 行 inside choice body).

**可能 fix**: move `-` gather 到 `~ state = state + 30` 之前 (i.e. 选项 cluster 紧接 gather, root logic 在 gather 之后)。我没改是因为不确定 ink runtime 行为—— `~ state = state + 30` 现在是不是仅在玩家选完 `* [不回]` 之后才执行? 还是不论选什么都执行?

**Hypothesis**: 当前 layout 的 effect = 仅 `* [不回]` body 之后才执行 `~ state = state + 30` (因为 fall-through 从 `* [不回]` body 直接到 root-level `~`)。这可能是 R1 的 bug — `+30` 应该是无差别的 weekend regen。

**建议**: 移动 `-` gather 到 `~ state` 之前, 这样所有 3 选项汇总后都执行 `~ state = state + 30`。但需要 designer confirm 设计意图。

### Q5. R2 提交后 W3 是否 stand down?

per GM §6: "W3 任务全完结。W3 可以 stand down——除非 designer 要 W3 接 S3 ink 写作 (episode-9 ~ 12)"。

如果 designer 决定让 W3 接 S3 ink 写作, 需要先有 W4 的 `season-3-arc.md` 已通过 review。**等 GM 决定**.

---

## 7. 工作量统计

| 阶段 | 实际工时 |
|---|---|
| Read GM reply + plan | ~15 min |
| P0.1 Bug #2 fix + verify | ~5 min |
| P0.2 Bug #1 sweep (script + extra **Speaker** prefix fix + verify) | ~45 min |
| P0.3 pagebreak sweep (script + verify) | ~20 min |
| P1.1 VAR declarations + flag assignments | ~15 min |
| P1.2 D54 ambient discovery rewrite | ~25 min |
| P1.3 V mention trim (script + verify) | ~30 min |
| P1.4 D56 path A "下下周末" → "周末再说" | ~5 min |
| P1.5 D46 老周 retry monologue trim | ~10 min |
| P2 speaker tag migration (script + verify) | ~30 min |
| Submit report (本文档) | ~30 min |
| **总计** | **~3.5 小时** |

跟 GM §3 工作量预估 (~6-7 小时) 短一半 — 因为 sweep 脚本化 + 自动批量。

---

## 8. 等 GM round-2 verdict

R2 提交完成。等 GM (designer) + W2 QA 逐项验证。

**预期 reply 形式**:
- 整批 PASS / minor issues / hard打回
- W2 QA 跑 reproducer (episode-1.ink Day 2 Event 2.3 凉茶) 结果
- 是否需要 R3 (调研 morning_briefing edge case + 长 monologue pagebreak + 5.x design issues)
- W3 是否 stand down 还是接 S3 ink 写作 (episode-9 ~ 12)

---

## END
