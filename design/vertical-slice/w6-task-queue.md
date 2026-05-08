# W6 (Season Outline Writer) — /loop Task Queue

> Status: live
> Author: GM
> Last Updated: 2026-05-08
> 收件人: W6 reuse session

---

## /loop 工作流

```
1. 读本文件找 next 未 ✅ done task (按 N 顺序: S6 → S7 → ... → S12)
2. 读 design/vertical-slice/season-outline-writer-generic-handoff.md 完整 brief
3. 读 reference docs (per brief §1) — 必含已 ship outlines (S1-S5)
4. 写 design/vertical-slice/season-N-arc.md (10 sections, ~500-700 行)
5. 写 design/vertical-slice/season-N-arc-round-1-response.md (1 page progress note)
6. 在本文件 task 末加 "**Status**: ✅ submitted in <file>"
7. 重 read 本文件 — 如有 GM verdict 需要 round-2, 实施; 否则 pick next N+1; queue empty 则 idle
```

---

## ✅ Done

- **S4 outline (round 1)**: `season-4-arc.md` 584 行. GM PASS verdict: `season-4-arc-round-1-reply.md`
- **S5 outline (round 1)**: `season-5-arc.md` ~700 行. GM PASS verdict: `season-5-arc-round-1-reply.md`
- **npcs.md §11 实习生小张 register (round 2)**: 跟 §1-§10 同 format. ~120 行 add to npcs.md.

---

## 🆕 Next — S6 outline (David 燃尽离职 finale)

### Why

S6 是 series 第二个真正"扎点 finale" — David 燃尽离职 is the climax of S4-S6 David burnout 弧光 (per series-structure.md §3 + npcs.md §2).

### Parameter

- **N = 6**
- **主题**: David 燃尽离职 finale (per series-structure.md §2 S6 row)
- **finale beat**: E24 周日 18:00 David 朋友圈"开启人生新篇章" (per protagonist.md §9 + S4 round-1 reply 历史 dispatch reference)

### Spec

跟 S4 / S5 同 10 sections format. 关键 highlight:
- **5 路径 finale**: 跟 S3 (5 路径 Lisa) + S4 (5 路径 David quiet sign 后续) 一脉, S6 是 David 弧光的终结
  - 路径 A (S3 救 Lisa + S4 路径 A 累积): David 燃尽离职那天找笑天告别 (笑天意识到 promotion warning event S10.X 已经预热完, S5/S6 累计已 += 2)
  - 路径 B (中性): David 走得 quiet
  - 路径 C (S4 帮 David 累积): **David 离职那天主动跟笑天有真正对话** "兄弟我撑不下去了" — series 内 David 跟笑天第一次真正对话
  - 路径 D (装病): 笑天没看到 David 离职那天
  - 路径 E (silence): David 走的事笑天后知后觉 (per S3 路径 E 镜像)
- **promotion_candidate_count S6 末 += 1 if KPI >= 150** (跟 S4 同 threshold per Q1 历史)
- **实习生小张 mentor 加深期** (per npcs.md §11 跨 series 弧光 S6 row)
- **王总监** S5 "他自己也开始焦虑" continue → S6 "他打高尔夫频率 +1 / 月" (per npcs.md §3 S5-S6 row)
- **笑天 voice S4-S6 弧光**: 看着 David 走那天笑天 internal "_我以为我会笑。但我没有。_" (per protagonist.md §9 verbatim)

### NPC arc 重点

- David: 4 集 finale 累积 (每集 1 个 quiet sign + E24 离职)
- Lisa: 5 路径 ambient continue
- 王总监: puppet form layer 4 → layer 5 (S6 高尔夫频率 +1 / 月 + S6 末"我也快了" 给笑天 ambiguous reveal? — designer 决定)
- 实习生小张: mentor 加深, intern_score 累积 +5 ~ +18 cumulative
- Zoe: 季度 review continue
- 老周 / 李阿姨 / Vivian / IT 小马 / 妈妈 / 林姐: 跟 S4 / S5 节奏 continue

### Files

- `season-6-arc.md` ~600-700 行
- `season-6-arc-round-1-response.md` (1 page progress note)

### Estimate

4-6h

---

## 🆕 Then — S7 (E25-E28) 后

S7 主题 (per series-structure.md §2): "**老员工身份**" — 笑天**第一次被叫"陈哥"** 那个 anchor 已经在 S5 E20 (per S5 outline). S7 反转: **笑天意识到他成了 12 周前的"我"想 avoid 的版本**.

### Parameter

- **N = 7**
- **主题**: 老员工身份觉醒 (笑天 12 周入职 → 28 周后 = 4 个月, 已经从"新人" 变成"陈哥")
- **finale beat**: E28 周日 KPI Review 后笑天 internal "_我成了我 12 周前 想 avoid 的人_"

---

## 🆕 Then — S8 (E29-E32) 后 — 李阿姨退休

S8 主题: "**李阿姨退休**" — 没有任何 UI 提醒, 某个早晨笑天发现没人倒水了.

### Parameter

- **N = 8**
- **主题**: 李阿姨退休 (per npcs.md §5)
- **finale beat**: E32 某早晨笑天泡咖啡时**手停 3 秒**, internal "_她的世界里没有 KPI。她现在终于回去了。_"

---

## 🆕 Then — S9 (E33-E36) 后 — 王总监被换

S9: **王总监被换** — 新总监空降, 笑天意识到王总监**也是 puppet**.

---

## 🆕 Then — S10-S11 (E37-E44) 后 — 猎头 + 组织调整

S10: **promotion warning event S10.X 真正触发** (per series-structure.md §4.5, promotion_candidate_count >= 2 由 S4-S9 累积)
S11: **组织调整传言** + 集体焦虑高峰 + 笑天**偷偷整理简历**

---

## 🆕 Then — S12 (E45-E48) finale + Endgame (E49-E52) outline

S12: **12 月 KPI 冲刺**, 笑天最难一关. E48 KPI Review = 终极 GO 候选时刻
Endgame (E49-E52): 春节回家 4 集 + 6 个 happy ending variants 的具体触发 episode

---

## 总 estimate

S6 (4-6h) + S7 (4-6h) + S8 (4-6h) + S9 (4-6h) + S10 (4-6h) + S11 (4-6h) + S12 (4-6h) + Endgame (4-6h) = **8 outlines × 4-6h = 32-48h total**

按 GM /loop tick cadence, 每 outline submit 后 GM review (~1.5h verdict) → W6 pick next. Total cycle ~5h W6 + 1.5h GM per season = 8 seasons × ~6.5h = ~52h cumulative timeline (W6 + GM 协同 work).

完成全 13 outlines 后 unblock S5-S12 ink writer cluster (~80h ink writer batch work).

---

## END
