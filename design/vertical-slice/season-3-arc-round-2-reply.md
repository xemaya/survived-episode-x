# W4 Round 2 Reply (GM verdict + 2 follow-up Q 答复)

> Status: 第 1 版
> Author: GM (designer)
> Last Updated: 2026-05-06
> 收件人: W4
> 配套: `season-3-arc-round-2-response.md`

---

## TL;DR

**整批 PASS + W4 closed**。

5 处 minor 全部 clean 应用 ✓。outline 现在 production-ready，可以作为 S3 ink writer 的 source of truth。

W4 raise 的 2 个 follow-up Q：
- **§4.1 priority logic** — 答复见 §1，**保留你的 priority 顺序**（sick_count 先于 hero_count）
- **§4.2 S1 flag 命名 reconciliation** — 答复见 §2，**让 S3 ink writer 在写 episode-9.ink 时 reconcile**（不需要 retro-fit S1 ink 也不需要再改 S3 outline）

W4 stand down。User 可以启 W6 (S4 outline，reuse generic brief)。

---

## 1. 答 §4.1 — E12 路径选择 priority logic

**W4 提的 ink 优先级**:
```ink
{ sick_count >= 4: -> path_d_finale  // D 优先（绝对装病累积玩家）
- cumulative_hero_count >= 6 && lisa_score >= 25: -> path_a_finale
- cumulative_hero_count >= 3: -> path_b_finale
- cumulative_hero_count >= 1: -> path_c_finale
- else: -> path_e_finale
}
```

**GM 答**: ✅ **保留这个 priority**——sick_count 先 check 是对的。理由：

1. D 路径设计意图就是 "笑天**自己**精神撑不住，物理疾病外显"——如果一个玩家同时高 sick_count + 高 hero_count，说明他「拼命帮 Lisa 同时把自己拼坏」，这种「过度耗损」状态下 finale 应该走 D（你病倒了所以你不在），而不是 A（你救了她）。**身体先于人际**——这是 Pillar 3 的体现。

2. sick_count ≥ 4 是高门槛（E12 之前累积 4 次病倒 = 病倒次数 cap 6 已用 67%），说明玩家整 series 都在硬撑。这种玩家的 E12 周日不是"陪 Lisa"，而是"我今天起不来"。

3. 数值上：cumulative_hero_count ≥ 6 同时 sick_count ≥ 4 的玩家**很少**（双高门槛）—— 这条 logic 真正分流的玩家不多，但分流到 D 是更对的设计。

**Outline 应记录**：W4 round-3（如启）在 §6 5 路径表加 1 行 implementation note：

> **路径优先级（ink-side）**: 进入 finale recap 前 logic 是
> sick_count ≥ 4 → D / cumulative_hero_count ≥ 6 + lisa_score ≥ 25 → A /
> cumulative_hero_count ≥ 3 → B / cumulative_hero_count ≥ 1 → C / else → E。
> sick_count 优先反映 "身体先于人际"（Pillar 3）。

**这个 update 不强求 W4 做**——它本来就是 Open Q discussion，并非 spec gap。S3 ink writer 写 episode-12.ink 时会按这个 priority 实装，他/她可以读这条 reply 即可。

---

## 2. 答 §4.2 — S1 hero flag 命名

**W4 观察**: §2 列了 3 个 S1 hero flag 但描述模糊，可能跟 episode-1/2/3/4.ink 实际 flag name 不一致。建议 ink writer reconcile 或 retro-fit S1 ink。

**GM 校实**:

抽样 grep `episode-1.ink` VAR 块发现 S1 flag 实际命名:

```
VAR lisa_score = 0
VAR lisa_helped_pps = false          // E2-E3 影响 lisa S2-S3 trajectory
VAR lisa_helped_after_hr = false     // E8 D56 path A → S3 救 Lisa 路径关键 flag
（其他 S1 flag — 凉茶 / 加班 — 暂未 declare 为单独 VAR；仅通过 lisa_score 累加体现）
```

S1 ink writer 当时**没**为"凉茶" / "加班" 单独 declare flag——这两个 hero action 仅通过 `lisa_score = lisa_score + N` 累加体现。`lisa_helped_pps` 是唯一 S1 declared hero flag (E2-E3)。

**GM 答**: ✅ **不需要 retro-fit S1 ink 也不需要再改 S3 outline §2**。

理由 + 让 S3 ink writer 在写 episode-9.ink 时做的 reconciliation:

1. **"凉茶" 和 "加班"**：保留为 lisa_score 累加内生，不另设 flag。理由：这两个 action 在 S1 已 played, S3 也不会 retro-trigger，单独 flag 没必要。S3 ink writer 在 cumulative_hero_count 计算时**仅 count**:
   - `lisa_helped_pps`（S1 唯一 declared S1-side flag）→ +1 if true
   - `lisa_helped_after_hr`（S2 D56 path A flag）→ +1 if true
   - `lisa_helped_self_review` / `lisa_weekend_company` / `lisa_zoe_feedback_positive` / `lisa_referred_external`（S3 4 flag W4 outline 已定义）→ 各 +1 if true
   
   **总共 6 flag，cumulative_hero_count 范围 0-6。路径 A 触发 = ≥ 5（不是 ≥ 6）**。

2. **lisa_score ≥ +25 同步降阈值**：S2 末 lisa_score 范围一般 -5 ~ +20，加上 S3 4 个 flag 各贡献 +8/+12/+5/+3 ≈ +28 max。所以 ≥ +25 是接近顶值的门槛。如果 cumulative_hero_count 改成 ≥ 5，那 lisa_score 阈值保持 ≥ +25 仍合理。

3. **路径 B/C/E 阈值同步调整**:
   - B: cumulative_hero_count = 3-4
   - C: cumulative_hero_count = 1-2
   - E: cumulative_hero_count = 0
   - D: 不变（仍 sick_count 独立 trigger）

**这个 update 不强求 W4 做**——S3 ink writer 在写 episode-12.ink 时按上述实算。S3 outline §2 + §6 当前的 ≥ 6 阈值算是一个 ceiling 写法，ink writer 会读这条 reply 校准到 ≥ 5。

**给 S3 ink writer 的 cumulative_hero_count 计算 ink snippet**:

```ink
=== function compute_cumulative_hero_count() ===
~ temp count = 0
{ lisa_helped_pps:           ~ count = count + 1 }
{ lisa_helped_after_hr:      ~ count = count + 1 }
{ lisa_helped_self_review:   ~ count = count + 1 }
{ lisa_weekend_company:      ~ count = count + 1 }
{ lisa_zoe_feedback_positive:~ count = count + 1 }
{ lisa_referred_external:    ~ count = count + 1 }
~ return count
```

S3 ink writer 写 episode-12.ink 时 declare 这个 function，在 D56_event_3 priority logic 里调用。

---

## 3. 食堂阿姨 E12 path A 出场 — confirmed retain

W4 §4.3 已 confirm。No change needed.

---

## 4. W4 closed

W4 round 2 = **CLOSED**。

W4 stand down。

**User next**:
- 启 W6 (`season-outline-writer-generic-handoff.md`) — 第一个任务 = S4 outline (David 燃尽前兆 + 月度面谈固定流程开始)
- 也可以让同 W4 session 接 W6 的 S4 任务 (reuse session 节省 ramp-up)

S3 ink writer 启动条件:
- ✅ S3 outline (本 W4 round-2 通过) — done
- ⏳ W3 round-2 done (S2 + S1 cleanup) — partial in progress
- W3 round-2 完成后即可启 S3 ink writer

---

## END
