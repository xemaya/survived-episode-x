# GM Worker Roster — 项目当前 + 待启动的所有 worker

> Status: 第 1 版
> Author: Game Designer (acting as GM)
> Last Updated: 2026-05-05
>
> 本文件是项目的"组织架构图"。User 启动 worker session 前看这里：哪些在跑 / 哪些待启动 / 各自 brief 在哪 / 依赖关系。

---

## 当前 active workers（已 running）

| W# | 角色 | 当前 brief | 状态 | 输出位置 |
|---|---|---|---|---|
| **W1** | Engine Dev (Phase 2) | `p5-phase2-engine-handoff.md` | 🟢 running | code 直改 game/src/ + progress 写 `p5-phase2-engine-progress.md` |
| **W2** | QA Tester | `p5-qa-handoff.md` | 🟢 running | bug 写 `p5-qa-bug-reports.md` |

**协作流**：W2 找 bug → 写报告 → W1 修 → commit `fix(qa-bug-N)` → W2 verify → 标 resolved

---

## 待启动 workers（按优先级）

### P0 · 立刻启动（阻塞 Phase 2 demo 真正可玩）

| W# | 角色 | brief | 依赖 | 工作量 |
|---|---|---|---|---|
| **W3** | **Ink Content Cleanup + S2 Writer** | `episode-ink-handoff.md` (待写) | 需 user verify §8 migration Option A vs B | 12-16h（修 S1 episode-3.ink + 写 4 个 S2 episode .ink） |
| **W4** | **Season 3 Outline Writer** | `season-outline-writer-handoff.md` (待写，generic 模板) | 无 | 4-6h（最关键 season — Lisa 走/留 finale）|
| **W5** | **Visual Asset Generator** | `visual-asset-handoff.md` (待写) | 无（W1 dev 等着用 phone / banking / 妈妈 sprite 做 Phase 2） | 4-6h（生成 8-10 张新 sprite via gpt-image-2 + cut + sync） |

### P1 · Phase 2 完成后再启动

| W# | 角色 | brief | 依赖 | 工作量 |
|---|---|---|---|---|
| **W6** | **Season 4-12 Outline Writer** | (复用 W4 模板) | W4 完成（Lisa finale 锁了，其他 season 可批量写）| 12-16h（9 个 season + endgame）|
| **W7** | **Audio Brief Writer** | `audio-brief-handoff.md` (待写) | 无 | 3-4h |
| **W8** | **Game Over Scene Writer** | `gameover-scene-handoff.md` (待写) | series-structure.md §6（已 ready） | 4-6h（5 个 GO 类 + endgame happy ending 6 variants ink 内容）|

---

## Worker 依赖图

```
                     ┌── W3 (S1 cleanup + S2 ink)
                     │
series-structure.md ─┼── W4 (S3 outline) ──── W6 (S4-S12 + endgame outlines)
                     │      │
                     │      └─ unlocks W3 to also write S3 ink later
                     │
                     ├── W5 (visual assets) ── feeds W1 dev
                     │
                     ├── W7 (audio brief) ── feeds future audio worker
                     │
                     └── W8 (GO + happy ending ink) ── feeds W1 dev demo

W1 dev ─── modifies game/src/ ─── W2 QA verifies ─── reports bugs ─── back to W1
```

---

## 我（GM）的活

每天 / 每个 batch：
1. **Review** worker 输出（progress logs / bug reports / 新 ink / 新 outlines）
2. **Verify** 关键设计决策（如 W3 raise Open Q → 我答；W4 outline 走 spec 大方向）
3. **Integrate** worker 输出（commit messages / link relationships across files）
4. **Unblock** dependencies（如 user verify Option A → 通知 W3 可以开始）
5. **Spec patches** 当 spec 自相矛盾时（已发生 1 次：S1 E3 vs S2 E7 剪短发位置）

**不做**：写代码 / sed / 手动修 ink syntax / debug Pixi 渲染 / 手动写 outline。这些都派 worker。

---

## 阻塞决策已 resolve（2026-05-05）

- ✅ Q1 §8 Migration: Option A（Lisa 剪短发 S1 E3 → S2 E7）
- ✅ Q2 启动顺序: P0 三个先启（5 并行）
- ✅ Q3 Visual budget: OK ($0.80-1.00)

---

## Worker brief 状态盘点

| Brief 文件 | Worker | Status |
|---|---|---|
| `p5-phase2-engine-handoff.md` | W1 | ✅ 已写 + 🟢 running |
| `p5-qa-handoff.md` | W2 | ✅ 已写 + 🟢 running |
| `episode-ink-handoff.md` | W3 | ✅ 已写 + 🟢 running |
| `season-outline-writer-handoff.md` | W4 (S3-specific) | ✅ 已写 + 🟢 running |
| `visual-asset-handoff.md` | W5 | ✅ 已写 + 🟢 running |
| `season-outline-writer-generic-handoff.md` | W6 (S4-S12+Endgame) | ✅ 预备好 / ⚪ 等 W4 done 触发 |
| `gameover-and-happy-ending-ink-handoff.md` | W8 | ✅ 预备好 / ⚪ 可随时启动（无依赖）/ 推荐 W5 done 后启 |
| `audio-brief-handoff.md` | W7 | ⚪ Phase 2 demo done 后再写（音频 P6+ scope）|
| `episode-generation-brief.md` (S1) | (history) | ✅ closed (S1 ink writer round 1+2 已完成) |
| `daily-choices-handoff.md` | (history) | ✅ closed (daily-choices round 1+2 已完成) |

---

## 我的下一步

- **被动 review 模式**：W1-W5 输出回来时 verify + integrate + answer Open Questions
- **当 W4 done** → 通知 user 启 W6（reuse generic brief，参数 = S4 / S5 / ...）
- **当 W5 done** → 推荐 user 启 W8（GO + Happy Ending ink，独立无依赖）
- **当 P5 Phase 2 demo done** → 写 W7 audio brief
- **不主动写代码 / 不写 outline 细节 / 不修 ink syntax bug**——这些都委托

W2 QA 还自加了 Playwright harness（看 .gitignore 增量）—— 用 W1 加的 `globalThis.__qa` hook 自动化测试。Worker 自组织得不错。
