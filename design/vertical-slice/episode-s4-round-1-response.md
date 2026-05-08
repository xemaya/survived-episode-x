# S4 Round 1 提交报告 — episode 13-16

> Status: 第 1 版
> Author: 分身 CC session (W3 reuse, S4 ink writer)
> Last Updated: 2026-05-07
> 收件人: GM (designer) + W2 QA worker
> 配套 brief: `episode-s4-ink-handoff.md`
> 主 spec: `season-4-arc.md` (584 行) + `season-4-arc-round-1-reply.md` (Q1-Q6 decisions)

---

## TL;DR

S4 R1 全部 4 集完成。`pnpm ink:build` ✓ **18/18 succeeded**, 0 fatal errors. `pnpm tsc` clean. `pnpm test` 357/357 passed. 总计 **6045 行 .ink** (E13 1748 / E14 1170 / E15 1220 / E16 1907).

---

## 1. 输出 4 个文件

| 文件 | 行数 | 主题 | 笑/泪比 | 集内高峰 |
|---|---|---|---|---|
| `episode-13.ink` (新建) | **1748** | Week 13「新工位主人」| 6:4 | D85 周一 5 路径 Lisa 工位 visual differentiation + 王总监 cue +2/集 起步 |
| `episode-14.ink` (新建) | **1170** | Week 14「调休来加班」| 5:5 | D92 清明调休 + D93 David 第 3 次不耐烦 IT + D94 Decision 揭穿 David 抢功 |
| `episode-15.ink` (新建) | **1220** | Week 15「他在打高尔夫」| 5:5 | D101 王总监 verbatim "好了 David 我明白了" + D102 王总监打高尔夫 puppet form 4 |
| `episode-16.ink` (新建) | **1907** | Week 16「保温杯」(Season Finale) | 4:6 | D106 食堂阿姨 verbatim "今天早" + D112 5 路径 finale + David 摔保温杯 + 路径 A "高潜力人才储备池" |

**总计**: 6045 行。**比 brief 估计 (2700-3000 行) 多 1 倍** — 原因: 5 路径 stitch chain 各自展开 + 跟 S2/S3 同 voice density baseline。 GM 决定是否 trim (Open Q1)。

---

## 2. 每集 NPC archetype 完成度

| NPC | E13 | E14 | E15 | E16 |
|---|---|---|---|---|
| **David** (S4 主线) | ✓ quiet sign 0 (D85 8:30 baseline 抬高) | ✓ quiet sign 1 (D96 朋友圈 0 条 + D93 第 3 次不耐烦 IT) | ✓ quiet sign 2 (D101 被打断 verbatim "好了 David 我明白了") | ✓ quiet sign 3+4 (D106 迟到 + D107 没自我激励 + D108 不举手 + **D112 摔保温杯**) |
| **王总监** | ✓ D85 cue +5 min 早 (路径 A reward) | ✓ D94 工具化笑天 cc Decision | ✓ **D102 puppet form 4 打高尔夫** | ✓ D108 disengage David + **D112 路径 A verbatim "你做得不错。下个月再看看"** |
| **Lisa** | ✓ 5 路径 D85 visual / D86 微信(A) / D91 cliffhanger(A) | ✓ D95 朋友圈"清明回家了" 路径 B 截图 | ✓ D109 微信 "Q2 lead sub-project" (路径 A) | ✓ D110 朋友圈"满 1 个月" 路径 B 第 2 次截图 + D112 路径 A "清明假期顺利吗" 4 句 |
| **老周** | ✓ D85 11:30 经过 Lisa 原工位 0.5s 慢 (silent witness) | (background) | ✓ D99 8:00 baseline 12 年 horizontal | ✓ (background, S4 0 dialog 全程) |
| **林姐** | (不出场) | (不出场) | ✓ **D101 路径 A 茶水间偶遇 0 句话 + 0.3 秒看工位方向** (per Q6 strict) | (不出场) |
| **Zoe** | (background) | (背景) | ✓ D102 季度协作反馈 Decision (3 选 1) | ✓ **D112 路径 A 1v1 邮件 "高潜力人才储备池" 附件** |
| **Vivian** | ✓ D85 苹果周连续 13 + "嗨～新月份" | ✓ D92 清明海报 + D93 "嗨～补班大家收心" | ✓ D99 leak "老板二三跟投资人吃饭" + D103 仍苹果 | ✓ **D106 草莓周 (D 轮过会 — Pillar 4 ironic mirror)** |
| **李阿姨** | ✓ (background, S4 motif: 多拖 1 遍 / 拖把车 + 儿子准考证) | (周二补打扫, 哼歌) | (background) | ✓ D112 茶水间 David 摔保温杯时 0.5s 慢 (silent witness 第 N 次) |
| **IT 小马** | (running gag) | ✓ **D93 v4 告示 (S2 v1 / S3 v2 / S4 v4 升级)** | (background) | (running gag) |
| **妈妈** | ✓ D91 verbatim **"清明你姨他们要去你爸坟上"** + 笑天 3 选 1 (per Q5 strict) | ✓ D98 callback "清明节你回了吗" | ✓ D105 "那个谁的儿子相亲" standard | ✓ **D112 verbatim "我下个月想去你那看看你"** (S2 finale callback / S4 spiral 起步) |
| **食堂阿姨** | (S4 第 1 次出场, weekly Wed 多打半勺) | (background) | (background) | ✓ **D106 verbatim "今天早" + 笑天 "嗯, 今天早" (series 唯一 visible recognition)** |
| **张磊** (路径 A 专属) | ✓ D85 "哥早" + D86 "哥早" + D89 "哥那个 Wi-Fi 密码是?" "谢谢哥" (4 句, S4 累积) | (background) | (background) | ✓ D112 茶水间 silent 在场 |
| **赵丽** (路径 B/C/E) | ✓ D88 周四第一天 setup 邮箱 silent | (background) | (background) | (background) |

**注**: 张磊 dialog 累积 = 4 句, 略超 brief Q2 "≤ 3 句" guidance。 GM 决定是否 trim 1 句 (Open Q3)。

---

## 3. §6 笑/泪比例自检

- **E13: 实际 6:4 ✓**
  - 笑点: D85 Vivian "嗨～新月份" / 王总监 muscle memory cue / D86 David pps demo callback / D87 王总监对张磊"加油啊" S1 D1 callback / D90 David"反思 / 复盘 / 充电"
  - 扎点: D85 Lisa 工位 5 路径 / 老周 0.5s 慢 / D87 David 152% 王总监响应时间 -0.2s / D88 李阿姨多拖 1 遍 / D91 妈妈"清明上坟" (controlled)

- **E14: 实际 5:5 ✓**
  - 笑点: D92 清明调休 KPI 1.2x ironic / D93 IT v4 告示 / D94 David 抢功 standard / D97 weekend
  - 扎点: D93 David 第 3 次不耐烦 + accept v4 / D94 Decision 揭穿 David / D95 Lisa 朋友圈截图 / **D96 David 朋友圈 0 条 visible** / D98 妈妈 callback

- **E15: 实际 5:5 ✓**
  - 笑点: D99 老周 12 年 horizontal vs David spiral up / D100 Vivian "看水果盘" 闲聊 / D103 David 朋友圈仍 0 条 (累积 2 周 ironic)
  - 扎点: D99 David 8:00 baseline 又抬 / D100 Decision 王总监 "你比 David 跟得紧" / **D101 verbatim "好了 David 我明白了"** / **D102 王总监打高尔夫 (puppet form 4)** / D101 路径 A 林姐 0 句话

- **E16: 实际 4:6 ✓**
  - 笑点: D106 草莓周 (D 轮过会 ironic mirror) / D106 食堂阿姨"今天早"轻笑 / Vivian "草莓哦"
  - 扎点: D106 David 迟到 (quiet sign 3) / D107 David 茶水间没自我激励 / D108 David 晨会不举手 / **D112 KPI Review 路径 A "高潜力人才储备池"** / **D112 茶水间 David 摔保温杯** / D112 妈妈 spiral verbatim

整季合计 ≈ **5:5** ✓ (跟 outline §1 一致)

---

## 4. §6 Verbatim quote 保留 (7/7)

| Quote | 集 / 触发 | 状态 |
|---|---|---|
| 妈妈 "**清明你姨他们要去你爸坟上 — 你今年回不回来**" | E13 D91 周日 8:30 | ✓ verbatim, 15 字 (per Q5 strict) |
| 王总监 "**好了 David 我明白了**" | E15 D101 周三晨会 | ✓ verbatim, 8 字 |
| 食堂阿姨 "**今天早**" | E16 D106 周一 12:30 | ✓ verbatim, 3 字 |
| 笑天 "**嗯, 今天早**" | E16 D106 周一 12:30 | ✓ verbatim, 5 字 |
| 王总监 (路径 A) "**你做得不错。下个月再看看**" | E16 D112 周日 11:00 微信 | ✓ verbatim, 12 字 |
| KPI Review 浮层 (路径 A) "**您本月持续表现稳定。公司认可您的团队协作度。下月将给予您更高的责任。**" | E16 D112 周日 9:30 | ✓ verbatim, anti-Pillar 1 极致 |
| 季度协作反馈附件 (路径 A) "**陈笑天同志在 Q1 期间表现稳定，与同事协作度高，建议进入下季度高潜力人才储备池。**" | E16 D112 周日 9:30 (附件 PDF) | ✓ verbatim, "高潜力人才储备池" backdoor signal |
| 妈妈 "**我下个月想去你那看看你**" | E16 D112 周日 8:30 | ✓ verbatim, S2 finale callback / S4 spiral 起步 |

8/8 verbatim 全保留 (含 "今天早" 一对 dialog 算 2 个) ✓

---

## 5. §7 红线检查 (12 条)

- [x] David 不能 E13/E14/E15 失态 ✓ (E13 baseline / E14 朋友圈 0 / E15 被打断 / **E16 才显形 (摔保温杯)**)
- [x] David 不能 S4 燃尽 ✓ (E16 仅"摔保温杯" 是 quiet sign 4 不是离职 closure; S6 finale 才离职)
- [x] 王总监不能直接对 David "你做得不好" ✓ (D101 仅 verbatim "好了 David 我明白了"; D108 静默不 cue)
- [x] 老周不能说出第二句话 ✓ (S4 0 dialog 全程, 仅 visual: D85 0.5s 慢 / D99 8:00 horizontal baseline)
- [x] 林姐不能在 E13/E14/E16 主动 ✓ (仅路径 A E15 D101 茶水间, 0 句话 + 0.3s 看工位方向)
- [x] 玩家不能在 E16 finale "救" David ✓ (Decision A 帮捡 = david_score +3 但 David 仍 contain meltdown 用 S1 D1 small talk; B/C 玩家 register 不解决问题)
- [x] 路径 A 不能给 happy ending UI / promotion celebration ✓ (D112 KPI Review 浮层 anti-Pillar 1 极致 + 王总监 verbatim 是 PUA + Zoe 邮件 paper trail 起步, 无任何庆祝)
- [x] David 完整 backstory 不 expose ✓ (D106 仅 mention "他妻子刚生孩子他不回家" in monologue 推测, 不 explicit reveal)
- [x] 笑天不对 David 说"加油" / "你也不容易" ✓ (D112 帮捡选项是"过去帮捡", 笑天没说话, David 自动用 S1 D1 small talk reset)
- [x] Lisa 不在 S4 "回来安慰笑天" ✓ (路径 A 仅微信 4 句 transactional friendly; 路径 B-E 朋友圈 milestone tagging or silence)
- [x] Lisa 不在路径 C-E "反转回来" ✓ (C 持续屏蔽态 / D-E silence)
- [x] 妈妈不 expose 爸爸 emotional anchor ✓ (per Q5 strict: D91 仅 mention "上坟" 流程性词, 笑天 internal 不写"8 年前" / 不加 dad_grave_visit_decline flag / 不形成 spiral)
- [x] S4 不触发 event S10.X promotion warning ✓ (D112 仅 prelude: 王总监"你做得不错下个月再看看" + Zoe 邮件 + KPI Review 附件 "高潜力人才储备池" — 三个 backdoor signal, 笑天 internal "我应该 confirm 但没")

12+1/12+1 ✓ (含 1 条 S10.X 不触发, 全 pass)

---

## 6. 跨 season 一致性 check

| Callback | S1-S3 source | S4 兑现 |
|---|---|---|
| 王总监新月份 cue | S1 D15 / S2 D29 / S3 D57 | ✓ S4 D85 + 路径 A reward "+2/集 早 5 分钟" |
| Vivian 苹果周 | S1 草莓周演融资 / S2 D29 苹果 / S3 全 apple | ✓ S4 D85-D103 仍 apple, D106 草莓 (D 轮过会 ironic mirror) |
| Vivian 选择性 leak | S2 D58 leak Lisa / S3 D78 push leak | ✓ S4 D99 leak 老板投资人 / D85 路径 E "嗨～她上周走了" |
| David 不耐烦 IT 小马 | S2 D40 第 1 次 / S3 D66 第 2 次 reframe | ✓ **S4 D93 第 3 次 + accept v4 告示 (attenuation)** |
| 王总监 puppet form | S2 E7 灯亮 (form 1) / S3 E11 D74 打电话 (form 2) | ✓ **S4 D102 打高尔夫 (form 3 escape)** |
| 妈妈 "想去 / 不去" spiral | S2 finale 想去 / S3 D63 不去 | ✓ **S4 D112 想去 (closed loop, S5+ spiral 起步)** |
| Lisa "她不要笑天" (林姐 mirror) | S3 finale 林姐 0.3 秒看笑天 (路径 A) | ✓ **S4 D101 林姐茶水间 0 句话 + 0.3s 看工位方向 (路径 A 第 2 次 visual 接触, 0 总 dialog)** |
| 笑天 → David 关系 | S1-S3 卷王副线 | ✓ **S4 主线递进, S6 finale David 离职 setup 起步** |
| 笑天 voice S4 末转变 | S3 voice "我没救成她" | ✓ S4 voice "我成了下一个 David (路径 A 卷王 candidate)" |
| Wi-Fi 密码 | S1 D5 笑天问 Vivian | ✓ **S4 D89 张磊问笑天 (callback, 笑天意识"我成了 12 周前的老员工")** |
| KPI Review 模板 | S1/S3 路径 A "团队精神 / 更高的责任" | ✓ S4 路径 A "团队协作度 / 更高的责任" — 模板从未变过 |
| 妈妈"那个谁" callback | S3 + S4 D105 "相亲" standard | ✓ |
| 食堂阿姨多打半勺 | S1-S3 silent baseline | ✓ S4 D106 第 1 次抬头 "今天早" (唯一 visible recognition) |

13/13 跨 season 一致性 ✓

---

## 7. E16 5 路径实现

| Path | Stitch chain | 触发 condition | KPI Review reward | David 摔保温杯 reaction |
|---|---|---|---|---|
| **A** (持续高表现) | day_112_path_a_finale → wang_followup → zoe_email → canteen_meltdown → finale_recap | cumulative_hero_count ≥ 5 AND lisa_score ≥ 25 | +10% threshold + "高潜力人才储备池" + promotion_candidate_count += 1 (if KPI ≥ 150) | 笑天路过看到, 张磊也在场, 笑天 Decision (3 选 1) |
| **B** (救得不彻底) | day_112_path_b_finale → canteen_meltdown → finale_recap | cumulative_hero_count ≥ 3 (and not A) | +5% threshold + "继续保持" | 笑天路过看到, Decision (3 选 1) |
| **C** (路径分裂帮 David) | day_112_path_c_finale → canteen_meltdown → finale_recap | cumulative_hero_count ≥ 1 (and not A/B) | +5% threshold + "勉勉强强" | 笑天路过看到, Decision (3 选 1) |
| **D** (装病摸鱼累积) | day_112_path_d_finale → finale_recap (skip 茶水间) | sick_count ≥ 4 | +3% threshold + "您看起来不太对" | **笑天周日仍发烧, 没去公司, 不知 David 摔保温杯** |
| **E** (全程冷处理) | day_112_path_e_finale → finale_recap (skip 茶水间) | cumulative_hero_count = 0 (else clause) | +1% threshold + 系统注释空白 | **笑天 12:00 直接回家, 不知 David 摔保温杯** |

每条 path 独立 stitch chain (no fall-through) ✓ (per brief §8 硬性 fail).

---

## 8. 全 18 episode build state

```
✓ daily-choices.ink → daily-choices.json
✓ episode-1.ink → episode-1.json (含 S4 6 个新 hero flag VAR)
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
✓ episode-13.ink → episode-13.json [新建, 1748 行]
✓ episode-14.ink → episode-14.json [新建, 1170 行]
✓ episode-15.ink → episode-15.json [新建, 1220 行]
✓ episode-16.ink → episode-16.json [新建, 1907 行]
✓ endings.ink → endings.json

Done: 18/18 succeeded → 0 fatal errors
```

`pnpm tsc` ✓ clean.
`pnpm test` ✓ 357/357 passed.

---

## 9. promotion_candidate_count 实装

per Q1 reply: 阈值 = **150 absolute**, 不是 130。

E16 D112 路径 A 末实装:

```ink
{kpi >= 150:
    ~ promotion_candidate_count = promotion_candidate_count + 1
    _我月末 KPI ≥ 150 — 系统 register 我作为 promotion candidate (counter += 1)._
- else:
    _我月末 KPI < 150 — 系统 register "高潜力" 但 counter 不 +1 (per Q1 reply 阈值)。_
}
```

S4 末预期 promotion_candidate_count 上限 = 1 (per outline §2 setup 起步)。S5/S6/S7 累积到 ≥ 2 → S10.X event 正式触发。

**注**: 路径 A 玩家实际 KPI ≥ 150 frequency 取决于 system balance — 玩家 effort_overage 累积 + 选项 KPI bonus。GM 可在 system tuning 时 calibrate。

---

## 10. Open Questions

### Q1. 实际行数 (6045) vs brief 估计 (2700-3000) 多 1 倍

每集 1170-1907 行, 比 brief 估的 600-850 多 ~1.5-2x。

**原因**:
- 跟 S2/S3 episodes (1660-2270 行/集) 同 voice density baseline
- 5 路径 stitch chain 每条独立展开 (E13 5 stitches × ~50 行 + E16 5 stitches × ~80 行)
- 跨季 callback 内部 monologue 详细 (W3 R2 GM Q4 trim PPT 版本号 之后 monologue density 已 reduce, 但仍 verbose)

**GM 决定**: 是否需要 R2 trim?
- 选项 A: keep — voice density 跟 S2/S3 一致, 不 break baseline
- 选项 B: trim — 减 internal monologue meta-commentary (e.g. "S1 D5 我 12 周前问过 Vivian Wi-Fi" 这种 explicit cross-ref)
- 选项 C: hybrid — trim E13 + E16 path-specific repeat (5 路径 finale stitches 有相似 setup, 可 share)

我 default 选 A (keep)。

### Q2. 张磊 dialog 累积 4 句 (略超 brief Q2 "≤ 3 句")

张磊 dialog 我用了:
1. D85 "哥早。" (路径 A intro)
2. D85 "我叫张磊。"
3. D87 "我..." (晨会想发言, 没接续)
4. D89 "哥, 那个 Wi-Fi 密码是?" + "谢谢哥。" (S1 D5 callback)

共 4 句 (含 D89 短 question + thank).

**GM 决定**: trim 哪 1 句? 我建议 trim D87 "我..." (晨会 ambient 不 critical), 让 D85 入职 + D85 自我介绍 + D89 Wi-Fi callback 保留 (3 句)。

### Q3. 食堂阿姨"今天早" - 笑天 + 食堂阿姨 各 1 句 = 2 句对话

per npcs.md §11 食堂阿姨"绝不主动说话, 只笑不说话"——D106 她 break this 1 次 (per outline §3.11 唯一 visible recognition)。

我让食堂阿姨说 1 句 ("今天早")。笑天回 1 句 ("嗯, 今天早")。然后她笑了一下转走。

**符合 outline §3.11 expectation** ✓ 但**严格说违反 npcs.md §11 "绝不主动说话"** — outline 比 npcs.md 更权威 (S4 ink writer 应 follow outline)。

GM 是否 confirm 该 break is OK?

### Q4. KPI ≥ 150 阈值 calibration

E16 D112 路径 A `promotion_candidate_count += 1` 仅在 `kpi >= 150` (absolute)。但 ink VAR `kpi` 是月末累积值, 我没 reset (累积 N 月)。

如果游戏从 episode 1 开始累积 kpi 到 episode 16:
- Path A 玩家可能 kpi 累积 > 150 多月 (S1-S4 累积)
- 但 series-structure.md §4.5 假设 promotion_candidate_count = "每月 KPI > 150 月数"

我假设 KPI 在月末 reset (每 4 集 KPI Review 后清零)。**实际 ink 没 reset logic** — 这是 system tuning 责任 (W1 dev 做 reset)。

**GM 决定**: ink 内是否需要写 `~ kpi = 100` reset? 还是 W1 runtime 处理?

我 default 不写 reset (假设 W1 runtime 处理).

### Q5. 路径 A KPI Review 浮层 + Zoe 邮件 + 王总监微信 — 触发顺序

E16 D112 路径 A 我写的顺序:
- 9:30 KPI Review 浮层
- 11:00 王总监微信 verbatim
- 11:30 Zoe 邮件 1v1
- 12:00 茶水间 David 摔保温杯
- 18:00 Lisa 微信 cliffhanger

per outline §5 E16 周日 D112: 9:30 → 11:00 路径 A 王总监 + Zoe 协作反馈 → 12:00 茶水间 → 18:00 cliffhanger.

我把 Zoe 邮件分到 11:30 separate stitch — 是否 OK?

### Q6. cumulative_hero_count cache vs recompute

E13/14/15/16 每集 entry stitch 都 recompute `cumulative_hero_count = sum(6 flags)`。这是 redundant if E12 D84 已 cache, 但 safety net (in case player 中途 enable cheat / mod state)。

**GM 决定**: 删掉 entry recompute (依赖 E12 cache), 还是 keep safety?

我 default keep safety.

---

## 11. 工作量统计

| 阶段 | 实际工时 |
|---|---|
| 读 reference (brief + outline + reply) | ~30 min |
| Write episode-13.ink (1748 行 含 5 路径 stitch chain) | ~2.5 hr |
| E13 build error fix (conditional syntax — 重构 path branching to stitches) | ~30 min |
| Write episode-14.ink (1170 行) | ~1.5 hr |
| Write episode-15.ink (1220 行 含 puppet form 4 + 林姐茶水间) | ~1.5 hr |
| Write episode-16.ink (1907 行 含 5 路径 finale + KPI Review 浮层 + 食堂阿姨 verbatim) | ~2.5 hr |
| Build verify + tsc + tests | ~15 min |
| Submission report (本文档) | ~30 min |
| **总计** | **~9.5 hr** |

跟 brief §4 估计 10-12h 一致 (略短, 因 E13 重构 took ~30 min penalty).

---

## 12. W3 stand down

S4 R1 提交完成。等 GM (designer) + W2 QA worker 逐项验证。

**预期 reply 形式**:
- 整批 PASS / minor issues / hard 打回
- W2 QA 跑 reproducer (5 路径 router + 食堂阿姨 verbatim + 王总监打高尔夫 visual)
- 笑天 voice S4 末"我成了下一个 David" review
- 6 Open Q 答复

W3 stand down. R1+R2+S3 R1+R3+R4+ Endings R1 + **S4 R1** 全完结。等下次内容改 re-engage.

---

## END
