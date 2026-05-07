# W3 Round 3 (Bug #27 AP sweep) 响应

> Status: done
> Author: 分身 CC session (W3 reuse, post-S3 R1)
> Last Updated: 2026-05-06
> 配套 brief: `w3-task-queue.md` (Bug #27 ink content sweep)

---

## TL;DR

AP sweep done in 1 个脚本 + 1 个 build verify = ~25 min。

---

## Sweep 统计

脚本: `/tmp/ap-sweep.mjs` (一次性, regex-based replace)。

| File | AP changes |
|---|---|
| episode-1.ink | 23 (主 sweep target — 含 intro_mechanics + AP 8/8 + AP 用完了 + 多个 choice label) |
| episode-2.ink | 11 |
| episode-3.ink | 7 |
| episode-4.ink | 5 |
| episode-5.ink | 5 |
| episode-6.ink | 6 |
| episode-7.ink | 8 |
| episode-8.ink | 4 |
| episode-9.ink | 9 (S3 — W3 reuse session 写的, 顺手 sweep) |
| episode-10.ink | 8 (S3) |
| episode-11.ink | 5 (S3) |
| episode-12.ink | 4 (S3) |
| daily-choices.ink | 0 (无 AP mention) |
| **Total** | **95** |

**注**: brief §sweep targets 列了 E1-E8 + daily-choices, 我把 S3 写的 E9-E12 也 sweep 了 (W3 reuse session, AP system 删除 系全 series 一致, S3 不能漏)。

---

## 改动 inventory (类型分布)

1. **Intro screen** (E1 line 147-149): "我每天有 8 个时间槽" + "每个槽, 事会发生" → **"我每天的时间感像沙漏。事会发生——你点选项, 我应付。"** (per brief 沙漏 metaphor 选项)

2. **Choice label 数值披露**:
   - `[申报加班 -10 状态 +2 AP 等价]` → `[申报加班]`
   - `[提前下班 (你没用满 8 AP)]` → `[提前下班]`
   - `[接过来 -1 AP, KPI -3]` → `[接过来]`
   - `[接过来 -1 AP, KPI -3 帮 Lisa 改自评]` → `[接过来 帮 Lisa 改自评]`
   - `[接过来 -1 AP, KPI -3, 帮她改]` → `[接过来 帮她改]`

3. **Narrative**:
   - `AP 8 / 8。这是你入职后的...` → `这是你入职后的...`
   - `AP 用完了。` (单行) → 删
   - `_今日 AP: N/A (周末)_` (周末 daily_recap) → 删
   - `· 今日 AP: N/A (周末)` (E4 KPI Review 浮层) → 删
   - `_你周末 -1 AP, state -10。_` (E11 D76) → `_你周末状态 -10。_`
   - `// 周末时间槽 4 AP, state 自然恢复 +20 / 天` (EOF comment) → `// 周末 state 自然恢复 +20 / 天`

4. **Designer comments**: `// 触发: 第 N 个 AP` → `// 触发: 第 N 个 event` (~50+ stitches across 12 episodes)

5. **EOF docs**: `Day 1 的 8 时间槽里, 6 个被剧情 event 占用` → `Day 1 的 6 个被剧情 event 占用`

---

## 不动的 (per brief §不要做的事)

- ✓ `effort_overage` / `effort_overtime` 系列 (KPI 公式输入) — 全保留
- ✓ `# pagebreak` tags (Bug #3 fix) — 全保留 (115 个 R2 + 64 个 S3 = 179 个)
- ✓ `# speaker:` tags (Q-1 fix) — 全保留 (119 个 R2 + 319 个 S3 = 438 个)
- ✓ Verbatim quotes (S2 7 + S3 13) — 全保留
- ✓ 红线 (S2 7 + S3 12) — 全 verify

---

## Build verify

```bash
pnpm ink:build
✓ daily-choices.ink → daily-choices.json
✓ episode-1.ink → episode-1.json
✓ episode-2.ink → episode-2.json
✓ episode-3.ink → episode-3.json
✓ episode-4.ink → episode-4.json
✓ episode-5.ink → episode-5.json
✓ episode-6.ink → episode-6.json
✓ episode-7.ink → episode-7.json
✓ episode-8.ink → episode-8.json
✓ episode-9.ink → episode-9.json
✓ episode-10.ink → episode-10.json
✓ episode-11.ink → episode-11.json
✓ episode-12.ink → episode-12.json

Done: 13/13 succeeded → 0 fatal errors
```

Warning count 跟 R2 baseline 一致 (10 处 pre-existing edge cases, per W3 R2 reply §1.1 + §1.2 GM defer)。

---

## 残留 AP 审计

```bash
grep -nE "AP|时间槽" design/vertical-slice/*.ink
# (no output)
```

**0 残留 AP mention** across 13 .ink files。

---

## 工作量

实际 ~25 min (脚本化 sweep + build verify + 报告)。比 brief estimate 30-60 min 短一半。

---

## W3 stand down

W3 任务全完结:
- R1: S2 4 集 (~11h)
- R2: bug 修 + Q polish + speaker tag (~3.5h)
- S3 brief 起草 (~30min)
- S3 R1: S3 4 集 (~13h)
- R3 (本次): AP sweep (~25min)
- **总: ~28h**

W3 stand down. 等下次需要内容改的时候再 re-engage.

---

## END
