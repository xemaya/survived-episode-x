# W4 Round 2 Response (S3 outline minor 改完)

> Status: 第 1 版
> Author: W4 (S3 outline writer 分身)
> Last Updated: 2026-05-06
> 收件人: GM (designer)
> 配套提交: `season-3-arc.md` (Round 2 改写完, ~526 行)
> 配套 reference: `season-3-arc-round-1-reply.md` (GM Round 1 verdict)

---

## TL;DR

GM Round 1 verdict 是 **PASS WITH MINOR ISSUES**。Round 2 任务清单 5 处全部应用完毕：

1. ✅ §1.1 — §2 hero_count 改为跨季 cumulative；§3.1 lisa_score note 改 cumulative_hero_count；§6 5 路径表的 hero_count 引用全部改为 cumulative_hero_count（A=≥6 / B=3-5 / C=≤2 / E=0）
2. ✅ §1.2 — 林姐 §3.6 删 "她跟笑天打了一个招呼但没多说一句"，flatten 到 0 语言（"她跟笑天 0 句话——她进来时没看笑天，跟 Lisa 说完就带 Lisa 走，离开前看笑天 0.3 秒后转身"）
3. ✅ §1.3 — §5 E11 周日补 C/D/E 路径 fallback stitch（路径 A/B 保留原版 + C/D/E 各 1 个 ambient 段）
4. ✅ §1.4 — §6 KPI Review 浮层文案后加 1 行 "实装 note"，澄清 ink-driven 文本 + Preact T18 overlay
5. ✅ §1.5 — §3.10 妈妈 E11 笑天 internal monologue trim explicit（"用她的身体把我从公司里拉回去" → "她从来不说'我累' 是因为有事——她说'累' 是因为想拉我回去"）

总工时约 1 小时（per Round 1 reply §4 估算）。

---

## 1. 5 处 minor 应用清单

### 1.1 §2 cumulative hero_count（已应用）

**改动位置**：§2 末段（hero_count 系统定义）+ §3.1 Lisa（S3 score 范围段）+ §6 5 路径表全 5 行

**§2 重写后内容**（见下面 §2 完整内容）：
- 删旧版 4 行 bullet (E9/E10/E11/E12)
- 新增 cross-season cumulative 系统：S1 hero flag (3 个) + S2 hero flag (1 个) + S3 hero flag (4 个，含 `lisa_referred_external`)
- 路径 A 触发要求：cumulative_hero_count ≥ 6 且 lisa_score ≥ +25

**§3.1 改动**：
- 旧："S2 末若 ≥+15，S3 末路径 A 触发条件成立（≥+25 + 累积选择 hero count ≥ 3）"
- 新："S2 末若 ≥+15，S3 末路径 A 触发条件成立（lisa_score ≥+25 + cumulative_hero_count ≥ 6）"

**§6 5 路径表改动**（行 1-5 全部 update）：
- A：`S3 hero_count ≥ 3` → `cumulative_hero_count ≥ 6`
- B：`S3 hero_count ≥ 1` → `cumulative_hero_count ≥ 3 但 < 6`
- C：`S3 hero_count = 0` → `cumulative_hero_count ≤ 2`
- D：S1 路径 D + S2 sick_count ≥ 3 + S3 周日装病 1 次（不变——这条路径的 trigger 是装病独立 counter，不走 hero_count）
- E：`S1 路径 E + S2 lisa_score < -5 + S3 全程不互动` → 加 `+ cumulative_hero_count = 0`

### 1.2 林姐 §3.6 flatten 0 语言（已应用）

**改动位置**：§3.6 林姐 A First Impression（路径 A 专属）末项

**改动内容**：
- 旧："NPC 行为是为她自己——她**需要好下属**（per npcs.md §10），不是来欢迎玩家。**她跟笑天打了一个招呼但没多说一句**——这强化"她不是给玩家的""
- 新："NPC 行为是为她自己——她**需要好下属**（per npcs.md §10），不是来欢迎玩家。**她跟笑天 0 句话**——她进来时没看笑天，跟 Lisa 说完就带 Lisa 走，离开前看笑天 0.3 秒后转身——这强化"她不是给玩家的""

**§3.6 后段**（"林姐 × 笑天" 那段）保持不变——它本来就写"她什么都没说"，跟 §5 E12 14:00 一致。

### 1.3 §5 E11 周日 C/D/E fallback stitch（已应用）

**改动位置**：§5 E11 周日 beat（原本 1 行，现在 4 行分支）

**改动内容**（见下面 §3 完整内容）：
- 路径 A/B 保留原版 + 把"她是不是在用她的身体把我从公司里拉回去" 替换为 trim 版（per §1.5）
- 路径 C：11 点起床 + 妈妈视频普通 escalate + Lisa 没邀请加班（mute）
- 路径 D：11 点起床 + 装病前兆 + 妈妈视频时关摄像头 + 没看 Lisa 微信
- 路径 E：11 点起床 + 妈妈视频普通 + 笑天看 Lisa 没消息——没在意

每个 fallback ≈ 5 stitch / ~30-50 行 ink，per Round 1 reply §1.3 budget。

### 1.4 §6 KPI Review 浮层加实装 note（已应用）

**改动位置**：§6 KPI Review 浮层文案 code block 后 + "注意" 段后

**新增内容**：
```
**实装 note**：文本来源 = ink（通过 `# kpi_review_path_a` 之类 tag 触发），渲染 = Preact KPI Review overlay (T18 待 W1 实现)。outline 只规定文案，不规定 render layer。
```

放在 "**HR-speak 直接抄现实**——不要"加效果"" 后面 1 行。

### 1.5 §3.10 妈妈 E11 internal monologue trim（已应用）

**改动位置**：§3.10 妈妈表的 E11 行

**改动内容**：
- 旧：`周日"天天，妈这周身体有点不舒服，没事就是有点累" → **笑天慌**——他第一次想：「她是不是在用她的身体把我从公司里拉回去」 → 但妈妈接着说"没事不用回来啊我自己能照顾自己"`
- 新：`周日"天天，妈这周身体有点不舒服，没事就是有点累" → **笑天 internal**：「妈最近老说累。她从来不说"我累" 是因为有事——她说"累" 是因为想拉我回去。」 → 但妈妈接着说"没事不用回来啊我自己能照顾自己"`

**理由**（per Round 1 reply §1.5）：新版 explicit 度降低（不是"她在 manipulate 我"，是"她想我回家"）——更 close to protagonist baseline "他观察 + 撑着"，不是"他反思"。

§5 E11 周日 路径 A/B fallback 段也同步用 trim 版（避免文档内 monologue 内部不一致）。

---

## 2. §2 cumulative hero_count 段重写后内容（verbatim）

```markdown
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
```

**Note for GM**：S3 hero flag 4 个全 hit + S2 path A + S1 任意 1 个 = 6（最低门槛）。S1 全 3 个 hit + S2 path A + S3 任意 2 个 = 6（另一种 6 路径）。两种 cumulative 累积方式都能 trigger 路径 A——GM 可在 future tuning 调阈值。

---

## 3. §5 E11 周日 C/D/E fallback stitch 内容（verbatim）

```markdown
- **周日**（按 S2 末路径 + lisa_score 分支）：
  - **路径 A/B**（S2 path A/B + lisa_score ≥ +5）：Lisa 周日加班 / 笑天周日加班 → 李阿姨周日加班来打扫，**经过他俩工位之间速度变慢 0.5 秒**——她知道 → 8:30 妈妈视频"天天，妈这周身体有点不舒服，没事就是有点累" → **笑天 internal**：「妈最近老说累。她从来不说"我累" 是因为有事——她说"累" 是因为想拉我回去。」 → 但妈妈接着说"没事不用回来啊我自己能照顾自己" → 下班
  - **路径 C**（S1 帮 David 累积玩家）：11 点起床 → 8:30 妈妈视频普通对话，妈妈版 escalate "那个谁的儿子升职加薪了" → 笑天回 "嗯" → 笑天周日 21:00 点开微信看 Lisa **没消息**（Lisa 没邀请他周末加班——她已经在 mute 他）→ 下班
  - **路径 D**（S2 sick_count ≥ 2 累积玩家）：11 点起床 → 笑天周日的"装病前兆" 萌芽——他**预感周一要装病**了 → 8:30 妈妈视频时他先关掉摄像头说"信号不好" → 妈妈"看不见你脸"，笑天"妈我这边网不好" → 下班 → 笑天没看 Lisa 微信
  - **路径 E**（lisa_score < -5 玩家）：11 点起床 → 8:30 妈妈视频普通对话 → 笑天点开微信看 Lisa **没消息**——他没在意，他这两个月已经习惯她不联系 → 下班
```

**Note for ink writer**：4 路径 stitch 在 ink 里用 `{ }` conditional logic（参考 episode-7.ink / episode-8.ink 已有的 path branch syntax）。每个 fallback 用 ~30-50 行 ink stitch 实现，**不**为每个 path 重复整个 morning 流程——只在周日 8:30-21:00 段分支。

---

## 4. 任何新发现的 design 问题

### 4.1 路径 D 的 cumulative_hero_count 不是 trigger key

**观察**：§6 路径 D 的 trigger 仍是 "S1 路径 D + S2 sick_count ≥ 3 + S3 周日装病 1 次"——这条路径走的是 sick_count 独立 counter，不走 hero_count。

**结论**：保持现状——sick_count 是独立心理 mechanic，不应跟 hero_count 混用。但 ink writer 在 E12 路径选择 logic 里需要先 check sick_count（D 路径优先），再 check cumulative_hero_count（A/B 分级），最后 fall back 到 C/E。**优先级顺序**（ink-side）：

```ink
{ sick_count >= 4: -> path_d_finale  // D 优先（绝对装病累积玩家）
- cumulative_hero_count >= 6 && lisa_score >= 25: -> path_a_finale  // A 救 Lisa
- cumulative_hero_count >= 3: -> path_b_finale  // B 救得不彻底
- cumulative_hero_count >= 1: -> path_c_finale  // C 路径分裂
- else: -> path_e_finale  // E 全程冷处理
}
```

**GM decide**：上面 priority 逻辑是否 OK？还是 D 路径的 sick_count 应该跟 hero_count 共存（即玩家可以同时高 sick_count 高 hero_count → 优先 D 还是 A）？

### 4.2 S1 hero flag 命名

**观察**：本 outline §2 列了 3 个 S1 hero flag，但描述比较模糊（"帮 Lisa 凉茶" / "茶水间救场" / "申报加班帮她拍板"）。这些跟 `season-1-arc.md` §3.1 Lisa Decision Moment B 实际选项的命名不完全对应。

**Resolution**：
- 我没改 `season-1-arc.md`——那是上一层 spec
- 但 GM 可能需要让 S1 ink writer (Round 2 closure 已 done) 在 episode-N.ink 里 retro-fit 这 3 个 flag 命名。具体 flag name 建议：`lisa_lent_thermos_water` (E1) / `lisa_helped_pps_review` (E2) / `lisa_overtime_logged` (E4)
- 如果 S1 ink 已经用了不同 flag name，本 outline 的 §2 cumulative 系统的 flag list 应该 retro-update 跟 S1 ink 的 actual flag 命名一致

**GM decide**：是否需要 cross-check S1 ink 的现有 flag 命名（episode-1/2/3/4.ink）然后 retro-update 本 outline §2 的 S1 hero flag 命名？或者留给 S3 ink writer 在写 episode-9.ink 时 reconcile？

### 4.3 食堂阿姨 E12 path A 出场——已 confirmed 保留

**Status**：Round 1 Q5 已 ✅ 保留——但 outline 写的是 "Lisa 路径 A 周一去食堂——食堂阿姨多打一勺"。我没在 §3.11（食堂阿姨）做改动，因为它本来就是 ambient flavor（per npcs.md §5.5）。**confirm GM Round 1 §2 Q5 答复**：保留即可，无需 outline 改动。

---

## 5. Submission status

- ✅ `season-3-arc.md` Round 2 改完（行数 ~526，比 Round 1 的 510 多 ~16 行——主要是 §2 hero_count 系统重写 + §5 E11 周日 fallback split + §6 实装 note）
- ✅ `season-3-arc-round-2-response.md` 本文件
- W4 stand by 等 GM Round 2 verdict
- per Round 1 reply §6: Round 2 done 后 W4 stand down，由 user 启 W6 接 S4

---

## END
