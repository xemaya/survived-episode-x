# W3 (Ink Content Worker) — Re-engage Task Queue

> Status: live
> Author: GM
> Last Updated: 2026-05-06 21:00

---

## ✅ Done

- **Round 3 (AP sweep)**: 95 changes 跨 13 episodes, 0 残留 AP mention. Built 13/13.

---

## 🆕 Round 4 — Bug #32 — episode-1.ink intro stitches voice fix + fake-choice → pagebreak

### Why

GM playtest 2026-05-06 post Q-R dialog 重构 ship: intro screen panel header 显示 `[视角]` 但内容是 first-person "我陈笑天 / 我妈起的名字 / 我现在在数咖啡杯..." monologue 风格 → voice 混杂. + 3 个 fake choices `[然后呢]/[听懂了]/[我懂了, 开始第 1 天]` 当 pagebreak 用, 玩家不知道是真选择还是过场.

### Spec

**3 stitch sweep** (`episode-1.ink:124-177`):

1. **`= intro` (line 124-141)** — 全段 笑天 first-person voice → wrap italic `_..._`:
   - "你好。" → "_你好。_"
   - "我陈笑天。32 岁。产品助理。" → "_我陈笑天。32 岁。产品助理。_"
   - "我妈起的名字——希望我'笑傲天下众生'。" → italic
   - "我现在在数咖啡杯。" → italic
   - "入职第 12 周。" → italic
   - "接下来 52 周, 你陪我走。" → italic
   - **删** `* [然后呢]\n    -> intro_mechanics`
   - **改** 末尾加 `# pagebreak\n-> intro_mechanics`

2. **`= intro_mechanics` (line 143-162)** — 全段 italic:
   - "我每天的时间感像沙漏。" → italic
   - "事会发生——你点选项, 我应付。" → italic
   - "我手里 3 件事在转——" → italic
   - KPI/钱/状态 list → 每 bullet italic
   - "钱多 / 事少 / 离家近——三样不可兼得。" → italic
   - "打工人的不可能三角。" → italic
   - **删** `* [听懂了]`, **改** `# pagebreak\n-> intro_endgame`

3. **`= intro_endgame` (line 164-177)** — 全段 italic:
   - "游戏从 2026 年 5 月开始。" → italic
   - "活过这一年..." → italic
   - "任意一个月..." → italic
   - "我妈不知道我在玩这种游戏。她以为我在大公司当 leader。" → italic
   - **保留** `* [我懂了, 开始第 1 天]\n    -> episode_1` ← **这是真选择 — 玩家 ack 进入游戏**, 不删

### Test

1. 清 localStorage → 新游戏
2. 跑 intro screen → panel header 应是 `[ 笑天 ]` (monologue source) 不是 `[视角]`
3. 段间无 sticky choice, 仅 ▼ continue
4. 最后一段保留 `[我懂了, 开始第 1 天]` 作为 explicit entry

### Estimate

10 min (script-driven sed + 1 verify)

### 注

- italic 在 ink 是 `_..._` markdown wrap, 整段每 paragraph 各自 wrap (不要跨行 wrap, 否则 source-detector 可能 mis-detect)
- 不要 sweep Day 1 morning_briefing (line 196+), 那段 mixed narration "你..." + italic monologue `_..._` 是正确的 (W3 已正确写)

---

## Round 4 完成后 W3 stand down

历史 Task — Bug #27 ink content sweep (AP mention 全删) — DONE
---

## (历史 Round 3 Task description 保留, 已 done)

## Task — Bug #27 ink content sweep (AP mention 全删)

### Spec

GM 决定删除 AP system。剧本里所有 AP 相关 mention 需要 sweep。

**两类 mention**:

1. **Choice label 数值披露**（违反 Pillar 3 主语翻转）:
   - `[申报加班 -10 状态 +2 AP 等价]` → `[申报加班]`
   - `[提前下班 (你没用满 8 AP)]` → `[提前下班]`
   - `[按时下班]` → keep（已经无数值）

2. **Narrative AP mention**:
   - intro screen 2 "我每天有 8 个时间槽" → 删除整段（AP 概念不存在）OR 改成 "我每天的时间感像沙漏"（节奏 metaphor）
   - 任何 `# ap_cost: N` ink tag → 删除
   - 任何 `~ ap = ap - N` 或 `~ ap_overtime = ...` 选项 body 内的 var assignment → 删除（W3 加过这些 in R2）

### Sweep targets

```
design/vertical-slice/episode-1.ink  (主 sweep target)
design/vertical-slice/episode-2.ink
design/vertical-slice/episode-3.ink
design/vertical-slice/episode-4.ink
design/vertical-slice/episode-5.ink
design/vertical-slice/episode-6.ink
design/vertical-slice/episode-7.ink
design/vertical-slice/episode-8.ink
design/vertical-slice/daily-choices.ink
```

**抓 pattern**:

```bash
grep -nE "AP|时间槽|ap_cost|ap_overtime|VAR ap|~ ap " design/vertical-slice/*.ink
```

### Sweep approach

1. 写 Python / node script 自动 replace common patterns:
   - `\[(\w+) -\d+ 状态 \+\d+ AP[^]]*\]` → `[\1]`
   - `\[(\w+) \(你没用满 \d+ AP\)\]` → `[\1]`
   - `# ap_cost: \d+` → 删
   - `~ ap[ _].* = .*` 行 → 删 (但保留 effort_overtime/effort_overage 那些)

2. 手工扫剩 grep 抓不到的 narrative AP mention（intro screen 2 "8 个时间槽"等）

3. **不要碰** `effort` 系列 (hero / overage / overtime) 这些是 KPI 公式输入，保留

4. 跑 `pnpm ink:build` 验证 0 fatal error + warning count 跟 R2 baseline 持平 (~10)

5. 写 short response: `episode-s2-round-3-response.md`（5-10 行 — sweep 统计 + verify build）

### 不要做的事

- 不要重写 narrative voice / dialog content (Bug #24/#25 是 engine 修, 不需要内容改)
- 不要 sweep `# pagebreak` (那是 Bug #3 fix, 保留)
- 不要 sweep `# speaker:` tag (那是 Q-1 fix, 保留)

### Estimate

30-60 分钟（脚本化）

### 完了之后

W3 stand down 等下次需要内容改的时候再 re-engage。

---

## END
