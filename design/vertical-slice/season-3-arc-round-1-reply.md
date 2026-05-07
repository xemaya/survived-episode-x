# W4 Round 1 Reply (GM verdict + Round 2 任务)

> Status: 第 1 版
> Author: GM (designer)
> Last Updated: 2026-05-05
> 收件人: W4（S3 outline writer 分身）
> 配套提交: `season-3-arc.md` (510 行)

---

## TL;DR

**整批 PASS WITH MINOR ISSUES**。

S3 是 series 第一个真正的"扎点 finale"——本 outline 完整 deliver 了：
- Lisa quiet sign 4 集累积曲线（穿正装 → 没吃饭+偷哭 → 周末加班 → finale）
- 林姐 First Impression deliberate restraint（仅路径 A E12 出场，跟笑天 0 句话）
- 5 路径**全部"扎"** + 路径 A reward = +18% threshold（anti-Pillar 1 极致黑色幽默）
- 笑泪曲线递扎（5:5 → 4:6 → 3:7 → 2:8）比 S2 (7:3→6:4→4:6→3:7) 进一阶
- KPI Review 路径 A 浮层文案"协助同事 / 团队精神 / 更高的责任 / ——这是您的 reward" — 直抄 HR-speak，对
- Cross-NPC matrix E12 finale ≥ 5 同框（路径 A 林姐 + 路径 B-E 李阿姨多拖 + 老周端茶 + 笑天远端 + Zoe）

整批不需要返工。Round 2 是 4 处 minor clarification + 1 个补 stitch。

---

## 1. 必修 minor（5 处）

### 1.1 §2 hero_count 定义需 disambiguate

**问题**：§2 定义 S3 hero_count source = `lisa_helped_self_review` + `lisa_weekend_company` + `lisa_zoe_feedback_positive` 三个 flag。但 §6 路径 A 触发条件还需 S2 `lisa_helped_after_hr = true`（这是 S2 finale 设的，不是 S3）。

**Resolution**：定义 hero_count 为**跨季 cumulative**——S1 hero count + S2 hero count + S3 hero count 累加。每季的 hero flag 单独定义但叠加到一个 cumulative counter。

**改写 §2 hero count 段**：
```
S3 hero count 是跨季累积：
- S1 hero flag: 帮 Lisa 凉茶 (S1 E1) / 茶水间救场 (S1 E2) / 申报加班帮她拍板 (S1 E4) — 每个 +1
- S2 hero flag: lisa_helped_after_hr (S2 E8 D56 path A) — +1
- S3 hero flag: lisa_helped_self_review (E10) + lisa_weekend_company (E11) + lisa_zoe_feedback_positive (E11 reverse — 给 Zoe 美化反馈) + lisa_referred_external (E12) — 每个 +1
- 路径 A 触发要求：累积 hero count ≥ 6 (含 S2 path A) 且 lisa_score ≥ +25
```

W4 round-2 改写 §2 + §6 表中"hero_count ≥ 3" 改为 "cumulative_hero_count ≥ 6"。

### 1.2 §3.6 林姐内部不一致（打招呼 vs 0 句话）

**问题**：§3.6 写"她跟笑天打了一个招呼但没多说一句" / §5 E12 14:00 写"林姐看了笑天 0.3 秒，但她什么都没说"。两处冲突。

**Resolution**：flatten 到 **0 语言**（跟 protagonist.md 红线 + Pillar 4 deliberate restraint 一致——林姐**完全不要笑天**）。改 §3.6 删"打了一个招呼"。

### 1.3 §5 E11 周日 C/D/E 路径无 specific stitch

**问题**：§5 E11 周日仅写"A/B 路径玩家 = 周末加班"。C/D/E 玩家 E11 周日干什么 outline 没写——ink writer 容易漏写或 fall-through 默认逻辑出错。

**Resolution**：补 **C/D/E 路径 E11 周日 fallback stitch**（最少 ambient）。改写 §5 E11 周日 beat：

```
- **周日**:
  - **路径 A/B（lisa_score ≥ +5 + S2 path A/B 玩家）**:
    - 笑天周日加班 / Lisa 周日加班 → 李阿姨周日加班来打扫 → 8:30 妈妈视频"她是不是在用她的身体把我从公司里拉回去"
  - **路径 C（S1 帮 David）**: 11 点起床 → 妈妈视频普通对话（"那个谁的儿子" 妈妈版本 escalate）→ 笑天没看 Lisa 微信
  - **路径 D（装病累积）**: 周日笑天的"装病前兆" 萌芽——他**预感周一要装病**了 → 妈妈视频时他先关掉摄像头说"信号不好" → 笑天没看 Lisa 微信
  - **路径 E（lisa_score < -5）**: 11 点起床 → 妈妈视频普通对话 → 笑天点开微信看 Lisa **没消息**——他没在意
```

每个 fallback 应该 ≤ 5 个 ink stitch（每个 ~30-50 行），不增加 outline 总篇幅太多。

### 1.4 §6 路径 A reward 浮层是 ink-driven 还是 Preact-driven 需澄清

**问题**：§6 给的 KPI Review 浮层文案应该 render 在哪？P0-P4 已有 Preact KPI Review overlay (`game/src/render/menu/kpi-review.tsx`)，但 ink 也可以驱动文本。outline 没指明。

**Resolution**：**ink-driven 文本** → 通过 `# kpi_review_path_a` 之类 tag 触发 Preact overlay 显示，文本由 ink 经 tag 传递。具体实现 W1 决定。**W4 round-2 不需要改 outline**——只需在 §6 KPI Review 浮层文案段加 1 行 note："文本来源 = ink，渲染 = Preact KPI Review overlay (T18 待 W1 实现)"。

### 1.5 §3.10 妈妈 E11 笑天 internal monologue 略 self-aware

**问题**：E11 周日妈妈 "她这周身体有点不舒服" → 笑天内心"她是不是在用她的身体把我从公司里拉回去"——这句话有点 explicit reflective，跟 protagonist.md "他不'反思'，他'撑着'" 有些 tension。

**Resolution**：**保留但 trim**——改成 ambient 一些。

```
笑天 internal: 「妈最近老说累。她从来不说"我累" 是因为有事——她说"累" 是因为想拉我回去。」
```

vs 原版：
```
笑天 internal: 「她是不是在用她的身体把我从公司里拉回去」
```

新版 explicit 度降低（不是"她在 manipulate 我"，是"她想我回家"）——更 close to protagonist baseline "他观察 + 撑着"。

W4 round-2 改这一句即可。

---

## 2. ✅ 给 W4 5 个 Open Q 的答复

### Q1. 路径 A 触发 hero_count ≥ 3 需要具体 flag 集合？

**A**: 见 §1.1 上面——改成 cumulative_hero_count ≥ 6（跨 S1+S2+S3）。具体 flag 列表已补全。

### Q2. S3 路径 A reward = +18% threshold 是否合适？

**A**: ✅ +18% 对——是 anti-Pillar 1 升级（S1 finale 路径 A = +10%，S3 finale 路径 A = +18%，递进显形）。后面 S6 / S9 / S12 路径 A 应继续递增（建议 S6=+22%, S9=+25%, S12=+28%——但这些数值由 future season outline writer 决定）。

### Q3. 林姐路径 A 独立 stage time 仅 1 stitch (14:00 那段) 是否够？

**A**: ✅ 1 stitch 够。Pillar 4 deliberate restraint 的核心就是"她不要笑天"——多给她 stage time = dilute 这条规则。1 stitch 已足够 visual identity 显形（黑西装 + 红文件夹 + "让她过来吧" 场景外听到 + "Lisa, 是吧, 跟我去那边坐"）。

但**确保**林姐的 visual 锚 3 件套全显形（参 §1.2 改后版本）：
- 黑色西装（visual 锚 1）
- 运动鞋（visual 锚 2）
- 红色文件夹（visual 锚 3，要从 visual 出现）

W5 visual 已交付 lin_jie 立绘——3 件套全 hit。

### Q4. E11 周日 C/D/E 路径 specific stitch？

**A**: ✅ 必须补——见 §1.3 上面。

### Q5. 食堂阿姨 E12 周一出场（路径 A）是否过度增加 stitch？

**A**: ✅ 保留——食堂阿姨"多打一勺"是 series-wide ambient flavor，路径 A 这一刻 callback 跟"她不知道但她看到 Lisa 瘦了" 是 Pillar 4 极致温暖（系统不在意人，但人偶尔在意人）。这一 stitch ~10 行，不显著增 stitch count。

---

## 3. Bonus 任务：S4 outline 是否启动？

**W4 自陈** time permitting 可以接 S4 outline。

**GM decision**:

S4 outline **不**让 W4 立刻接，理由：
1. W4 round-2 还有 5 处改要做（不大但是要做）
2. S4 outline 应该 reuse `season-outline-writer-generic-handoff.md` (W6 brief)，不是 reuse W4 的 S3-specific brief
3. 启 S4 是 user 决定（"启 W6"），不是 W4 自动 cascade

**建议给 user**：W4 round-2 done 后，W4 stand down。然后**启 W6**（reuse generic brief），**让 W6 第一个任务是 S4**——可以是同一 session 替身 W4 接活，也可以是新 session。

---

## 4. Round 2 任务清单

W4 round-2 工作（按工作量排序）:

1. **§1.1** hero_count cumulative 改写 §2 + §6 表 (15 分钟)
2. **§1.2** 林姐 §3.6 删"打了一个招呼" (5 分钟)
3. **§1.3** §5 E11 周日 C/D/E 路径补 fallback stitch (30 分钟)
4. **§1.4** §6 KPI Review 浮层文案加 1 行 note "ink-driven 文本 → Preact T18 overlay" (5 分钟)
5. **§1.5** §3.10 笑天 internal monologue trim explicit (5 分钟)

**总计 ≈ 1 小时**。

---

## 5. Round 2 提交格式

写 `season-3-arc-round-2-response.md`，包含:
- [x] 5 处 minor 应用清单（per section 改了什么）
- [x] §2 cumulative hero_count 段重写后内容
- [x] §5 E11 周日 C/D/E fallback stitch 内容
- [x] 任何新发现的 design 问题

---

## 6. Round 2 done 后

- W4 stand down（除非 designer 决定 W4 接 S4 outline）
- **建议**：W4 done 后，user 启 **W6** (reuse `season-outline-writer-generic-handoff.md`) — 第一个任务 = S4 outline
- S3 ink writer 启动条件：本 outline round-2 通过 + W3 round-2 done + W4 round-2 done。然后用同一 episode-ink-handoff brief（updated for S3）启新 ink session

---

## END
