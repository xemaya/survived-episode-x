# W3 S3 Round 1 Reply (GM verdict — PASS WITH 1 minor patch)

> Status: 第 1 版
> Author: GM (designer)
> Last Updated: 2026-05-06
> 收件人: W3
> 配套: episode-9.ink + episode-10.ink + episode-11.ink + episode-12.ink (W3 自带 within R3 AP sweep batch)

---

## TL;DR

S3 ink (E9-E12) **整批 PASS**——W3 reuse session 在 13h 内基于 W4 round-2 通过的 season-3-arc.md outline 写出 4 集 production-quality ink。

唯一 patch: **E8 D56 router 改成 ink-internal 跟 E12 一致**（5 min fix），见 §1。

---

## 1. 必修 — E8 D56 Lisa finale message router 改 ink-internal

**问题**: episode-8.ink:1562-1564 注释说 "路径 D / E 在 TS runtime 拦截层处理 (story.ChoosePathString)"——但 W1 实现的 path-interceptor.ts 是**checkpoint-tag 驱动** (`# checkpoint:` 标签 + register 条件)，不是 autonomous 路径检测。

W3 没在 episode-8.ink 加 `# checkpoint:` tag 也没在 TS 层 register 条件——所以 path D / path E **永远不会自动 trigger**。

**Resolution**: 改用 ink-internal `{}` 条件 router (跟 episode-12.ink:1421-1442 D84 router pattern 一致)。

**改写**:
- 把 episode-8.ink 现有 `day_56_event_3_lisa_finale_message` stitch 的开头改写成 router 块:

```ink
= day_56_event_3_lisa_finale_message
# scene: home_evening
# time: 21:30

21:30。你刚洗完澡。

{
    - sick_count >= 2:
        # pagebreak
        -> day_56_path_d_unread
    - lisa_score < 0:
        # pagebreak
        -> day_56_path_e_no_message
    - else:
        # 继续显示 path A/B/C 的默认 message
}

// 默认 message (path A/B/C 玩家看到):
# diegetic_ui: phone_wechat_notification
微信消息 1 条。
... (rest of current stitch)
```

**注**: D56 比 D84 简单——D56 的 `else` branch 留在当前 stitch 内显示 message 然后让 player 选 path A/B/C；D84 的 router 直接 divert 5 path stitch (D84 没有 player choice on path A/B/C — 完全由累积 state 决定)。所以 D56 router 是 **2 条 D/E early-exit + else fallthrough**，D84 router 是 **5 条 divert 全 cover**。

**5 min fix**。Done 后:
- pnpm ink:build 验证 build pass
- 写 short note 到本 reply 文件下面或新 round-4-response.md (1 行就行)

---

## 2. ✅ Verified

### 2.1 Verbatim 抓取（partial）

通过 grep 验证以下 critical verbatim 已 hit:

| Quote | 集 / 触发 | 状态 |
|---|---|---|
| 妈妈 "我下个月可能不去你那边了。你姨家有事我得过去" | E9 D63 周日 | ✓ episode-9.ink:1571 |
| Lisa "明天来公司加班吗? 我自己一个人有点慌" | E11 D75 21:00 | ✓ episode-11.ink:1042 |
| Lisa "笑天, 下周可能就出结果了。不管怎样, 谢谢你" | E11 D77 末 | ✓ episode-11.ink:1528 |
| 妈妈 "那个谁的女儿离职了, 回老家考公务员了" | E12 D84 周日 | ✓ episode-12.ink:1314 |
| 林姐 "让她过来吧" | E12 D84 11:00 | ✓ episode-12.ink:1508 |
| 林姐 "Lisa, 是吧? 跟我去那边坐" | E12 D84 14:00 | ✓ episode-12.ink:1610 (via Lisa narration recount) |

未直接 verify (缺 grep hit, 但语义可能已 cover):
- "我们这边节奏不一样" — 林姐 path A — W3 可能没 verbatim, 但 "她不要笑天" theme 在 line 1658 internal 提到
- "她不一样。但她不要我。" — 笑天 internal path A — line 26/890/1658/2267 多处 mention 概念

W3 round-2 (如启) 可考虑加这 2 条 verbatim 强化 series cliffhanger 文学性, 但**不阻塞**——thematic cover 已经足够。

### 2.2 Cumulative hero count 系统 (per round-2 reply §2)

✅ Production wired:
- `compute_cumulative_hero_count()` function 在 episode-12.ink:50 定义 (per spec)
- `VAR cumulative_hero_count = 0` cached in episode-1.ink:79
- 6 hero flags 全 declared 跨 episode 共享 (lisa_helped_pps + after_hr + self_review + weekend_company + zoe_feedback_positive + referred_external)
- E12 D84 router 优先级 (sick_count → cumulative → lisa_score → else) 正确实现 (line 1421-1442)

### 2.3 5 路径 finale 结构

✅ 5 stitches all defined (episode-12.ink):
- day_84_path_a_lin_jie_save (line 1451)
- day_84_path_b_lisa_thanks (line 1745)
- day_84_path_c_lisa_silent_walk (line 1875)
- day_84_path_d_sick_finale (line 1964)
- day_84_path_e_no_one_tells_xiaotian (line 2071)

### 2.4 KPI Review 浮层文案 (per outline §6)

✅ Path A 文案直接抄 outline §6 KPI Review section:
- "您本月协助同事完成关键交付。"
- "公司认可您的团队精神。"
- "下月将给予您更高的责任。"
- "——这是您的 reward。"
- 100 → 118 (+18%) threshold 涨幅 visible

但**这些文案现在是 inline ink narrative**——以后 Bug #31 KPI Review cinematic 落地后，会迁到 ink tag 携带文案 + Preact overlay 渲染。当前 inline 形式可作为过渡 (W3 不动，等 W1 做 #31 时 ink writer round-2 时一并迁)。

### 2.5 红线 spot-check

通过 grep + comment 抓取验证:
- ✅ Lisa 走/留**在 E12 D84 决定**（不在 E9/E10/E11）— 5 路径全在 D84 router
- ✅ 林姐**仅 E12 path A 出场**（其他 episode 0 出场）
- ✅ 林姐**不要笑天**（line 26/1658/2267 多处 thematic mention）
- ✅ 路径 A reward = +18% threshold (anti-Pillar 1 极致)

---

## 3. ❌ 设计 hold off

### 3.1 episode-12.ink `═══` Unicode 浮层文案

W3 R2 §5.1 已 raised + GM defer——episode-12.ink path A KPI Review 浮层用 `═══` Unicode 装饰。当前 ink:build 应该有 4-5 个 warning（episode-4.ink 同 issue）。

**defer 到 Bug #31 KPI Review cinematic rebuild**。届时 `═══` inline ink 改为 `# kpi_review_path_a` tag + Preact overlay 渲染，warning 消失。**不要 W3 round-2 改这个**——W1 做 #31 时一并迁。

---

## 4. Round-2 任务清单（非常小）

W3 round-2:
1. **§1 必修**: E8 D56 router 改 ink-internal `{}` (5 min)
2. **可选 (2.1 partial)**: 加 "我们这边节奏不一样" + "她不一样。但她不要我。" 2 条 verbatim 到 path A — 5-10 min, **可不做** (thematic cover 够了)

总: 5-15 min。

---

## 5. Round-2 done 后

W3 stand down（按 brief 规划）。下次重启 dispatch 是 Bug #31 KPI Review cinematic 文案迁移（W1 做 cinematic 实现，W3 配合迁 inline `═══` 文案到 ink tag）—— 那是 P1 之后的事。

---

## END
