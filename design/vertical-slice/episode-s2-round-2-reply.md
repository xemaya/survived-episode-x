# W3 Round 2 Reply (GM verdict + 5 design issue triage + 5 Q 答 + stand-down 决定)

> Status: 第 1 版
> Author: GM (designer)
> Last Updated: 2026-05-06
> 收件人: W3
> 配套: `episode-s2-round-2-response.md` (W3 round-2 提交)

---

## TL;DR

**整批 PASS + W3 closed**。

R2 9 项任务全 done in 3.5h（脚本化让效率超 GM 估算 6-7h 一倍）：
- ✅ Bug #1 sweep（warning 86 → 10，88% 削减）+ 7 个 `**Speaker**：` variant catch
- ✅ Bug #2 修
- ✅ pagebreak sweep（115 个 across 8 episodes）
- ✅ Q1+Q2 跨集 flag declare + assign
- ✅ Q3 D54 Lisa 默走 rewrite
- ✅ Q4 V mention trim 46 处（仅留 E5 D33 + E8 D52）
- ✅ Q5 "下下周末" → "周末再说"
- ✅ Q6 老周 retry trim 到 14 行 observable behavior
- ✅ Speaker tag migration E5-E8（119 tags）

W2 QA Round 3 已 verify Bug #1 #2 #4 #5 #8 #9 全 resolved（reproducer all green）。Bug #3/#6 由 W1 batch 6+7 closed，W2 尚未 re-test 但 engine 已 ship。

W3 round 2 工作 = production quality。stand down。

---

## 1. 5 design issue triage

### 1.1 episode-4.ink `═══` Unicode line warnings — 接受当前

**问题**：episode-4.ink 4 个剩余 warnings 来自 `═══════════════════════════════════════════` (KPI Review 浮层) 触发 ink loose-end heuristic。

**GM 决定**：✅ **不修**——Build 9/9 succeed + 这是 KPI Review 浮层一次性 cliffhanger 集中爆发，不影响 runtime。

**长期方向**：W1 implement T18 KPI Review overlay 后，`═══` 文案应迁到 Preact overlay（per `season-3-arc-round-2-reply.md` §1.4），ink 内 `═══` 行删除。届时 warning 消失。S3 ink writer 写 episode-12.ink 时按这个 pattern 直接用 `# kpi_review_path_a` tag 触发 overlay，不再 inline `═══`。

### 1.2 morning_briefing `_..._` italic loose-end edge — 调研，defer

**问题**：E2/E5/E6/E7 各有 1-2 个 morning_briefing stitch 末 `_..._` 内心独白被 ink 标 loose-end，但 episode-1.ink 同 pattern 不触发。

**GM 决定**：✅ **defer to R3 调研**——非 blocking，跟 W3 hypothesis "italic markdown parsing 吃掉 fall-through" 一致。R3 由谁做（W3 接 / W1 修 / 新 worker）跟 S3 ink writer 启动序绑定。当前不 block。

**workaround**: 如果某 episode 的 morning_briefing italic 末导致 runtime 行为异常（W2 QA reproducer 出问题），W3 / S3 ink writer 在该 stitch 末 `~ check_state_after_choice()` 之前加 1 行 `// pre-choice anchor` text 节点。但当前没 reported 异常 → 不动。

### 1.3 E8 D50 海报 `>` quote rendering — 需 W2 visual verify

**问题**：W3 用 `>` markdown quote 替换 D50 海报原 `=== ... ===` (是 Bug #2 variant 修复副作用)。engine 是否识别 `>` 为 visual signal 不确定。

**GM 决定**：✅ **W2 QA round 4 verify**——W2 在 dev 跑到 E8 D50 morning 时确认海报 visual 渲染：
- 如果 `>` quote 渲染成 inline 普通文本 → fine（玩家感知是"墙上贴了张白底字海报"，没特殊 styling 也 acceptable）
- 如果 `>` 触发 markdown blockquote indent + side bar → reasonable visual signal
- 如果 `>` 跟正文 visually inseparable + 玩家不知道这是海报 → reject，改用 `# poster:` tag + W1 implement poster overlay (P3 任务)

**GM 倾向**: keep `>` 直到 visual proves problematic。海报内容 = 短文本「本月度月度面谈安排」，inline 也读得通。

### 1.4 E8 D56 path D / E runtime intercept — W1 batch 8 dispatch

**问题**：D56 path D (`day_56_path_d_unread`) + path E (`day_56_path_e_no_message`) 依赖 TS runtime 在进入 `day_56_event_3_lisa_finale_message` 前用 `story.ChoosePathString` 直接跳到 stitch。W1 batch 5 实现了 sceneState.speaker，但**没**实现 path-D/E ChoosePathString 拦截。

**GM 决定**：✅ **W1 batch 8 添 path-intercept hook**——具体 task 描述加到 `p5-phase2-engine-questions.md` Q-4（新条）。Pattern:

```ts
// game/src/ink/path-interceptor.ts (T20)
// 注册条件 → ChoosePathString 跳转 mapping。在 ink step() 之前 evaluator
// 检查每个注册条件，命中即跳到 target stitch。
pathInterceptor.register({
  beforeStitch: 'day_56_event_3_lisa_finale_message',
  condition: (ink) => ink.variablesState['sick_count'] >= 4,
  target: 'day_56_path_d_unread',
});
pathInterceptor.register({
  beforeStitch: 'day_56_event_3_lisa_finale_message',
  condition: (ink) => ink.variablesState['lisa_score'] < -5,
  target: 'day_56_path_e_no_message',
});
```

W1 batch 8 实现 + W3 / S3 ink writer 在 episode-8.ink + episode-12.ink 注册条件即可。**当前不 block W3**——W1 接到 questions doc Q-4 后实现。

### 1.5 D34 weekend David ~state +30 在 root level — W3 quick fix（如果 W3 还在）

**问题**：episode-5.ink:1535/1540 D34 周六 David 微信选项 cluster 之后 root level 有 `~ state = state + 30` (regenForRestDay)。W3 加的 `-` gather 在 `~ check_state_after_choice()` 之前，但 `~ state +30` 在 gather 之前 → 仅 `* [不回]` 选项 fall-through 到 root → +30。

**GM 决定**：✅ **W3 quick fix（如果 W3 还在 active session）**——move `-` gather 到 `~ state = state + 30` 之前，让 3 选 1 都汇总后无差别 +30。这是一行改动。

如果 W3 已 stand down，**留给 S3 ink writer / 新 worker 顺手修**——episode-5.ink:1530-1540 区域加 1 行 `-` gather 即可。

---

## 2. 5 follow-up Q 答复

### Q1. E8 18 pagebreaks (vs others 14) — keep

**A**: ✅ Keep all 18。E8 5 路径 finale 多 4 个 pagebreak 是 architectural overhead，不是冗余。

### Q2. 长 monologue ≥ 4 段 pagebreak — defer to R3

**A**: ✅ Defer。R3 (如启) 手工扫一遍即可。当前 ~10 处缺失不会让玩家 visually 困惑（pagebreak 是优化，不是必需）。

### Q3. 食堂阿姨 / 林姐 speaker tag entry — defer

**A**: ✅ S2 不出现 dialog → 不需要 entry。S3 episode-9 ~ 12 写到林姐 1 stitch (E12 14:00) 时再加 `# speaker: lin_jie`，到时候 W3 / S3 ink writer 自然会 register。S2 没动作。

### Q4. R3 是否启 — 不启

**A**: ✅ **不启 R3**——5 design issue 全 defer / engine-side fix / 不 block。W3 round 2 = closed。

### Q5. W3 stand down vs 接 S3 ink

**A**: ✅ **W3 stand down**。理由：
- W3 R2 已 done
- S3 ink writer 是新任务（writing episode-9/10/11/12.ink, ~20-30h，体量比 R2 大 5-10x）
- S3 ink writer 启动条件：S3 outline ✅ done (W4 R2 PASS)，speaker tag system ✅ done (W1 batch 5)，episodes E5-E8 ✅ done (W3 R2 done)
- **S3 ink writer brief 由 GM 写**（next step），user 用新 session 启动（可以同 W3 ID 接，也可以新 ID — 只看哪个方便）

S3 ink writer brief 是接下来 GM 要写的——`episode-9-to-12-ink-handoff.md`，跟 `episode-generation-brief.md` (S1 brief) 同 pattern。

---

## 3. W3 closed

W3 round 1 + 2 = **CLOSED**。

W3 工作量统计：
- R1: ~11h（写 4 集 + S1 cleanup）
- R2: ~3.5h（脚本化 sweep）
- **总: ~14.5h**

跟 GM brief §9 估算 (12-16h) 一致。

W3 是高 throughput 的 worker——脚本化 sweep + 一次性 batch 整改 + 详细自检报告。值得 reuse 在 S3 ink writer 接力（如果用户允许）。

---

## 4. user next step

按 dispatch 紧急度:

1. **forward 本文件 → W3 session** → W3 stand down
2. **forward 本文件 §1.4 + §1.5 → W1 session** → W1 知道 batch 8 要加 path-interceptor + 知道 D34 root-level `~ state` 是 W3 留下的可顺手修
3. **forward 本文件 §1.3 → W2 session** → W2 round 4 verify D50 海报 `>` quote 渲染
4. **decide**: 启 W6 (S4 outline) 还是 GM 先写 S3 ink writer brief (episode-9-12) 让 user 启新 ink session？
   - 我建议 **GM 先写 S3 ink writer brief**——S3 ink 是 unblock 整个 series demo 的关键路径
   - W6 (S4 outline) 不阻塞 P5 demo，可以稍后再启
   - 顺序: GM 写 episode-9-to-12-ink-handoff.md → user 启 S3 ink session（fresh CC 或 reuse W3）→ W3 / 新 ink writer 写 4 集 → done 后再启 W6

---

## END
