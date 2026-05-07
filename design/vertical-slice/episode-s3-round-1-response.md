# S3 Round 1 提交报告 — episode 9-12

> Status: 第 1 版
> Author: 分身 CC session (W3 reuse for S3 ink writer)
> Last Updated: 2026-05-06
> 收件人: GM (designer) + W2 QA worker
> 配套 brief: `design/vertical-slice/episode-9-to-12-ink-handoff.md`
> 主 spec: `design/vertical-slice/season-3-arc.md` + `season-3-arc-round-2-reply.md`

---

## TL;DR

S3 Round 1 全部 4 集 + 6 个新 VAR + compute_cumulative_hero_count function 完成。`pnpm ink:build` ✓ **13/13 succeeded**, 0 fatal errors. 总计 **7784 行 .ink** (E9 1839 / E10 1859 / E11 1816 / E12 2270).

---

## 1. 输出 4 个文件

| 文件 | 行数 | 主题 | 笑/泪比 | 集内高峰 |
|---|---|---|---|---|
| `episode-9.ink` (新建) | **1839** | Week 9「她穿了正装」 | 5:5 | D57 Lisa 穿正装 + 王总监"你最近不一样啊" verbatim |
| `episode-10.ink` (新建) | **1859** | Week 10「90 分钟」 | 4:6 | D67 Zoe 90 分钟面谈 + Decision Moment 1 帮 Lisa 改 self_review |
| `episode-11.ink` (新建) | **1816** | Week 11「我自己一个人有点慌」 | 3:7 | D75 Decision Moment 2 路径分叉点 (周末加班陪 Lisa) |
| `episode-12.ink` (新建) | **2270** | Week 12「下周三签字」(Season Finale, 5 路径) | 2:8 | D84 5 路径 router + 林姐 First Impression (路径 A) |

E12 比 brief 估的 2300+ 略短 (2270), 但**含 5 独立 path stitch chains + finale_recap collector + compute_cumulative_hero_count() function**.

---

## 2. episode-1.ink VAR 块新增 6 个 S3 flag

```ink
// S3 Round 1 (W3 reuse) — 6 hero flags + cache for compute_cumulative_hero_count()
VAR lisa_helped_self_review = false      // E10 D67 path A — 帮 Lisa 改试用期自评
VAR lisa_weekend_company = false         // E11 D77 path A — 周末加班陪 Lisa
VAR lisa_zoe_feedback_positive = false   // E11 D72 path A — 给 Zoe 美化 Lisa 协作反馈
VAR lisa_referred_external = false       // E12 D80 path A — 主动跟 Lisa 提前同事跳槽机会
VAR lisa_abandoned_at_weekend = false    // E11 D77 path C/E — 笑天 mute Lisa
VAR cumulative_hero_count = 0            // E12 D84 router 用; computed by function 也 cache 为 VAR
// S1 hero flag note (per S3 round-2 reply §2): 仅 lisa_helped_pps 是 declared S1 flag,
// "凉茶" / "S1 加班" 等仅通过 lisa_score 累加内生, 不另设 flag
```

---

## 3. compute_cumulative_hero_count function (per round-2 reply §2)

**简化实现** (Ink boolean = 1/0 直接 sum, 比 round-2 reply 提的 multi-line 短 6 倍):

```ink
=== function compute_cumulative_hero_count() ===
// Ink: true = 1, false = 0 in arithmetic context — direct sum 6 booleans
~ return lisa_helped_pps + lisa_helped_after_hr + lisa_helped_self_review + lisa_weekend_company + lisa_zoe_feedback_positive + lisa_referred_external
```

**Path router 使用 (D84 finale)**:

```ink
~ cumulative_hero_count = compute_cumulative_hero_count()

{
    - sick_count >= 4:
        -> day_84_path_d_sick_finale
    - cumulative_hero_count >= 5 and lisa_score >= 25:
        -> day_84_path_a_lin_jie_save
    - cumulative_hero_count >= 3:
        -> day_84_path_b_lisa_thanks
    - cumulative_hero_count >= 1:
        -> day_84_path_c_lisa_silent_walk
    - else:
        -> day_84_path_e_no_one_tells_xiaotian
}
```

priority 顺序 sick_count 先于 hero_count (per round-2 reply §1 "身体先于人际")。

---

## 4. 每集 NPC archetype 完成度

| NPC | E9 | E10 | E11 | E12 |
|---|---|---|---|---|
| **Lisa** | ✓ (穿正装 + 文件夹 + 微信空白 + 没写"加油" + 朋友圈"也好") | ✓ (没吃饭 + 偷哭 + "在赶" + "你别担心") | ✓ (motif "加油" 复活 + 主动发言失败 + "我自己一个人有点慌" + "谢谢你") | ✓ D finale (5 路径独立 closure) |
| **David** | ✓ (D58 第一次注意 Lisa 不对 — 不是关心是判断) | ✓ (D64 145% 王总监没接 + D66 第 2 次不耐烦 IT) | ✓ (D73 22:00 加班回头看 Lisa 工位) | ✓ (D80 主动 self-praise — S6 燃尽 setup deepening) |
| **王总监** | ✓ (D57 verbatim "你最近不一样啊" + D59 眼神扫 Lisa 3 次) | ✓ (D64 reframe + D65 工具化笑天 + D66 disengage) | ✓ (C Vulnerability layer 3 — D74 verbatim "你跟 Zoe 说一下吧") | ✓ (D79 不再 cue Lisa + D84 verbatim "你最近表现不错") |
| **Zoe** | ✓ (D60 偷听"下周三签字") | ✓ (D67 90 分钟面谈 + D68 Vulnerability 小红书) | ✓ (D72 找笑天补充协作反馈 — 工具化笑天) | ✓ (D81 收 Lisa 走 + D84 群里 announcement) |
| **李阿姨** | ✓ (D59 先擦 Lisa 工位) | ✓ (D68 verbatim "这家公司的人每两个月走一茬" — S2 升级版) | (background) | ✓ (路径 B-E 16:00 多拖 Lisa 工位 implied) |
| **Vivian** | ✓ (D57 海报"年终福利预告"撤掉 + D58 leak Lisa 被叫去办公室) | (background) | (background) | ✓ (D78 草莓周 ironic mirror 12 周连续苹果之后第 1 次草莓 + 路径 E "嗨～她上周走了") |
| **IT 小马** | (running gag continue) | ✓ (D66 v3 告示) | (background) | (running gag) |
| **老周** | ✓ (D57 抬头看笑天一眼 — S3 唯一非沉默动作) | ✓ (D67 抬头 0.5 秒看 Lisa 走方向 — 第 2 次抬头) | (background) | ✓ (D81 抬头看 Lisa 走方向 — 第 3 次抬头, 仍 0 dialog) |
| **妈妈** | ✓ (D63 "我下个月可能不去你那" S2 反转) | ✓ (D70 第一次给具体数字"年薪 60 万") | ✓ (D77 路径 A/B "妈这周身体有点不舒服") | ✓ (D84 verbatim "那个谁的女儿离职了, 回老家考公务员了" — thematic mirror) |
| **★林姐★** | (不出场) | (不出场) | (mention only — D74 王总监 phone "林姐 OK 周一 starting") | ✓ **First Impression 路径 A 专属** (D84 11:00 群消息 verbatim "让她过来吧" + 14:00 远端照片 + verbatim "Lisa, 是吧? 跟我去那边坐") |
| **食堂阿姨** | (不出现) | (不出现) | (不出现) | ✓ (D78 路径 A 给 Lisa 多打一勺 — silent witness 第 4 个) |

---

## 5. §6 笑/泪比例自检

- **E9: 实际 5:5 ✓**
  - 笑点: D57 王总监 muscle memory + Vivian 海报撤 / D58 David 终于注意 / D59 BLUEPRINT 月度 / D62 David 6 月 4 大 / D63 妈妈 backtrack
  - 扎点: D57 Lisa 穿正装 + 老周抬头 / D59 没写"加油" / D60 偷听"下周三签字" / D61 Lisa 21:00 才走 / D63 朋友圈"也好"

- **E10: 实际 4:6 ✓**
  - 笑点: D64 David 145% 没人接 / D66 6 分钟散会 / D70 妈妈 60 万 / D69 David spinning
  - 扎点: D64 王总监 reframe / D65 工具化笑天 + Lisa 没吃饭 / D66 王总监 disengage / **D67 Zoe 90 分钟 + Decision Moment 1** / D68 Lisa 偷哭 + 撒谎 + Zoe 小红书 + **李阿姨 verbatim** / D70 cliffhanger

- **E11: 实际 3:7 ✓**
  - 笑点: D71 5 分钟散会 / D73 David 7 张便利贴高峰 / D77 妈妈"年薪 60 万" callback
  - 扎点: D71 motif "加油" 复活 + 主动发言失败 / D72 Decision Moment 1 (笑天工具化) / D73 David visualize / **D74 王总监 verbatim** / **D75 Lisa "我自己一个人有点慌"** / D76 路径 A 9.5 小时 / **D77 Lisa "不管怎样, 谢谢你"**

- **E12: 实际 2:8 ✓**
  - 笑点: D78 草莓周 ironic mirror / D79 王总监 disengage 反讽 / D84 妈妈"那个谁离职考公务员"
  - 扎点: D78 Lisa 文件夹移走 / D81 Lisa 14:00 走出 4 小时 / D82 Lisa 周五请假 + 笑天 silent witness 工位 / D83 Lisa 朋友圈"明天再说" / **D84 5 路径都"扎"**

---

## 6. §5 12 个 verbatim quote 保留

| Quote | 集 / 触发 | 状态 |
|---|---|---|
| 王总监 "**你最近不一样啊**" | E9 D57 周一 | ✓ verbatim, 5 字 |
| Lisa 朋友圈 "**也好，我自己也想换换**" | E9 D63 周日 21:00 (E9→E10 cliffhanger) | ✓ verbatim |
| Lisa "**在赶**" | E10 D66 周三晨会 答 王总监 | ✓ verbatim, 2 字 |
| 李阿姨 "**这家公司的人每两个月走一茬**" | E10 D68 周五 17:35 茶水间 | ✓ verbatim, 11 字 (S2 verbatim 升级版) |
| Lisa 微信 "**你别担心**" | E10 D70 周日 21:30 (E10→E11 cliffhanger) | ✓ verbatim, S2 D49 repeat |
| 王总监 "**你跟 Zoe 说一下吧, 下周三签字**" | E11 D74 周四 19:30 笑天偷听 | ✓ verbatim, 13 字 |
| Lisa "**明天来公司加班吗? 我自己一个人有点慌**" | E11 D75 周五 21:00 (路径分叉点) | ✓ verbatim, 13 字 |
| Lisa "**笑天, 下周可能就出结果了。不管怎样, 谢谢你**" | E11 D77 周日 21:30 (E11→E12 cliffhanger 路径 A/B 触发) | ✓ verbatim, S3 第 1 次"谢谢你" |
| 妈妈 "**那个谁的女儿离职了, 回老家考公务员了**" | E12 D84 周日 8:30 视频 | ✓ verbatim, 13 字 + thematic mirror |
| 林姐 (路径 A) "**让她过来吧**" | E12 D84 周日 11:00 王总监 phone (群消息) | ✓ verbatim, 5 字 |
| 林姐 (路径 A) "**Lisa, 是吧? 跟我去那边坐**" | E12 D84 周日 14:00 (Lisa 转述) | ✓ verbatim, 11 字 |
| 王总监 (路径 A) "**小笑啊…陈天啊…你最近表现不错。下个月看你的**" | E12 D84 周日 19:00 微信 1v1 | ✓ verbatim, 15 字 |
| KPI Review 浮层 (路径 A) "**您本月协助同事完成关键交付。公司认可您的团队精神。下月将给予您更高的责任。**" | E12 D84 周日 9:30 系统注释 | ✓ verbatim (anti-Pillar 1 极致) |

**13/13 verbatim 保留** (比 brief §5 列的 12 个多 1 个 — KPI Review 浮层 system 注释也 verbatim).

---

## 7. Cross-NPC 同框场景 (per S3 outline §4)

| Episode | 同框场景数 |
|---|---|
| E9 | 4 (D57 Lisa+王+David+笑天 / D59 晨会 5 NPC / D60 HR 偷听 / D63 妈妈视频) |
| E10 | 5 (D64 晨会 / D67 Zoe+Lisa+笑天+老周 / D67 18:00 Decision / D68 茶水间 + Zoe 小红书 / D70 妈妈) |
| E11 | 5 (D71 晨会 + Lisa 主动发言 / D72 Zoe 工位 / D73 David 22:00 / D74 王总监 phone / D75 Lisa 微信 + D76 周末) |
| E12 | 7 (D78 草莓 + 食堂 / D79 晨会 / D80 David self-praise + 路径 A Decision / D81 Lisa 走出 + 老周抬头 / D82 笑天看空工位 / D84 5 路径 finale + 林姐 First Impression) |

每集 ≥ 3 ✓ (E12 ≥ 5 ✓ per brief §8 软性 fail).

---

## 8. 红线 12 条检查 (per brief §7)

- ❌ Lisa 不能在 E9/E10/E11 决定走或留 ✓ (走/留仅 E12 D84 路径 A vs B-E)
- ❌ 王总监不能直接对 Lisa 讲 "你不适合" ✓ (D57 仅"你最近不一样啊", D74 backstage phone, D84 通过 Lisa 微信转述)
- ❌ David S3 不能燃尽 ✓ (D58 仅 setup, D66 第 2 次不耐烦, D73 visualize, D80 self-praise — 全是 S6 燃尽 setup deepening)
- ❌ 老周不能说出第二句话 ✓ (S3 仅 3 次抬头看 — D57 / D67 / D81, 全 0 dialog)
- ❌ 林姐不能在 S3 之前出场 ✓ (E9-E11 仅 mention, E12 D84 First Impression)
- ❌ 玩家不能在 E12 finale "赢" ✓ (路径 A reward = +18% threshold, 没庆祝 UI)
- ❌ 不能给 Lisa 完整 backstory expose ✓ (仍 ambiguous, quiet sign 累积)
- ❌ 不能让笑天对 Lisa 说"你别担心" / "会好的" ✓ (笑天选项是"恭喜" / "辛苦了" / "保重", 没 reassurance language)
- ❌ Lisa 走/留逻辑不基于累积选择 ✓ (D84 router 用 cumulative_hero_count + lisa_score + sick_count, 不是当天选 A/B/C)
- ❌ 不能在 E12 路径 A 给"happy ending UI" ✓ (林姐 14:00 第 1 次出现仅远端照片, 没 BGM, 没庆祝, 没看 camera)
- ❌ 不能让 Lisa 在路径 A 之外"反转回归" ✓ (路径 B-E 全部 Lisa 走)
- ❌ 不能引入 npcs.md 未注册的新 NPC ✓ (林姐已注册, 食堂阿姨 ambient flavor 已 register)

12/12 ✓

---

## 9. E12 5 路径实现

| Path | Stitch chain | 触发 condition | Outcome |
|---|---|---|---|
| **A** (lin_jie_save) | day_84_path_a_lin_jie_save → finale_recap | cumulative_hero_count ≥ 5 AND lisa_score ≥ 25 | Lisa 转岗客户成功部 + 林姐 First Impression + +18% threshold + promotion candidate setup |
| **B** (lisa_thanks) | day_84_path_b_lisa_thanks → finale_recap | cumulative_hero_count ≥ 3 (and not A trigger) | Lisa 走 + 朋友圈"开启新阶段" + +5% threshold |
| **C** (lisa_silent_walk) | day_84_path_c_lisa_silent_walk → finale_recap | cumulative_hero_count ≥ 1 (and not A/B trigger) | Lisa 没说告别 + S4 笑天发现被屏蔽 + +5% threshold |
| **D** (sick_finale) | day_84_path_d_sick_finale → finale_recap | sick_count ≥ 4 (priority over hero_count per round-2 reply §1) | 笑天周日发烧 + 9 小时延迟回 Lisa + +3% threshold |
| **E** (no_one_tells_xiaotian) | day_84_path_e_no_one_tells_xiaotian → finale_recap | cumulative_hero_count = 0 (else clause) | Vivian "嗨～她上周走了" + +1% threshold (Pillar 3 极致) |

每条 path 独立 stitch chain (no fall-through) ✓ (per brief §8 硬性 fail).

---

## 10. 全 13 episode build 状态

```
✓ daily-choices.ink → daily-choices.json (~110 KB)
✓ episode-1.ink → episode-1.json (~42 KB)  [VAR 块 加了 6 个 S3 flag]
✓ episode-2.ink → episode-2.json (~78 KB)
✓ episode-3.ink → episode-3.json (~71 KB)
✓ episode-4.ink → episode-4.json (~80 KB)
✓ episode-5.ink → episode-5.json (~79 KB)
✓ episode-6.ink → episode-6.json (~75 KB)
✓ episode-7.ink → episode-7.json (~77 KB)
✓ episode-8.ink → episode-8.json (~78 KB)
✓ episode-9.ink → episode-9.json (~80 KB)  [新建]
✓ episode-10.ink → episode-10.json (~83 KB)  [新建]
✓ episode-11.ink → episode-11.json (~82 KB)  [新建]
✓ episode-12.ink → episode-12.json (~95 KB)  [新建, 5 路径独立 chains + finale_recap]

Done: 13/13 succeeded → 0 fatal errors
```

剩余 warnings 仍是之前 W3 R2 已发现的 10 处 (E2 line 68, E4 KPI Review 浮层 `═══`, E5 D34 weekend, E6 D36 morning_briefing edge, E7 D45 老周 8:00 morning_briefing) — **W3 R2 已 GM defer to R3**. S3 R1 没新增 own loose-end warnings (E9-E12 全 0 own warnings, sweep + speaker tag + pagebreak born-in 一致).

---

## 11. Speaker tag 应用统计

| File | NPC tags | Protagonist tags | Total |
|---|---|---|---|
| episode-9.ink | ~46 | ~8 | **54** |
| episode-10.ink | ~70 | ~12 | **82** |
| episode-11.ink | ~73 | ~12 | **85** |
| episode-12.ink | ~85 | ~13 | **98** |
| **Total E9-E12** | **~274** | **~45** | **319** |

Speaker tag mapping (per brief §3.1 b 13-id table) 全 applied:
- `lisa` / `david` / `wang_director` / `vivian` / `zoe` / `lao_zhou` / `li_ayi` / `mama` / `it_xiaoma` / **`lin_jie`** (E12 D84 路径 A First Impression) / **`food_court_auntie`** (E12 D78 路径 A) / `protagonist`

Edge cases:
- `老板助理 Jeffrey` (E5 群消息) — 沿用 W3 R2 mapping `wang_director` id (leadership 同领域 fallback)
- `另一个 HR` — 沿用 W3 R2 mapping `zoe` id
- `另一个清洁阿姨` — 沿用 W3 R2 mapping `li_ayi` id

---

## 12. # pagebreak 应用统计

| File | pagebreaks |
|---|---|
| episode-9.ink | 14 |
| episode-10.ink | 14 |
| episode-11.ink | 18 (含 D77 周日 4 路径分支额外) |
| episode-12.ink | 18 (含 D84 finale 5 路径额外 router) |
| **Total E9-E12** | **64** |

Pagebreak policy table (per brief §3.1 a) 全 applied:
- ✓ `day_N_after_work` 选项后 → daily_recap
- ✓ `day_N_daily_recap` 末 → next morning_briefing
- ✓ episode finale → cliffhanger
- ✓ 周五 daily_recap → weekly_recap
- ✓ E12 5 路径 router 之间

---

## 13. 不确定 / 需要 review 的场景

### 13.1 E11 D71 笑天 internal monologue 关于时间表的混乱

E11 D71 morning_briefing 我让笑天 internal "我可能 misremember 时间表" — 他在 calculate Zoe D60 "下周三签字" 实际是哪天。这段 internal 比较 detail / meta —— 担心读者觉得"笑天怎么这么 obsessed 时间"。

**Reasoning**: S3 outline §3.4 + §3.6 Zoe / 林姐 时间表 是 design-level 关键, 但 Lisa 不知 + 笑天偷听知 = 信息不对等 高峰。如果 GM 觉得 internal 过 elaborate, 我可以 trim。

### 13.2 E12 D78 食堂阿姨 Decision branch only path A visible

D78 12:30 食堂阿姨 多打一勺 Lisa 仅 lisa_weekend_company = true 玩家 narratively reach。其他玩家 just see Lisa 走 + 回, 不知道食堂场景。

**Reasoning**: per S3 outline §3.11 "仅路径 A 玩家可见 Lisa 去食堂"。我用 `{lisa_weekend_company: -> day_78_event_2_canteen_path_a | else: -> day_78_event_2_canteen_invisible}` 实现——但 lisa_weekend_company 是 D75 trigger, 而 D78 是 weeks later. 有可能玩家 D75 选 A 但其他 hero count 不够 — finale 仍走 B/C/D — 但 D78 食堂场景仍 unlock。这不 break logic, 但可能让 invisible 玩家觉得 missing flavor。

**GM 决定**: 是否 OK 沿用 lisa_weekend_company 当 D78 visibility flag, 还是用 lisa_helped_self_review 也 unlock?

### 13.3 E12 D84 路径 A 林姐"远端照片" 实现方式

D84 14:00 林姐第一次出现 我用 `Lisa 发了 1 张照片` 描述 — 林姐 visible 在 Lisa 自拍背景里。

**Concern**: 这个 visual 是否够"她不要笑天"的 deliberate restraint? 林姐 photo angle 是远端 + 没看 camera + 只是"她跟另一个客户成功部同事说话"——technical 上她 visible, 但**emotion 上 not directly engaging 笑天**。

**GM 决定**: 是否 OK, 还是想让林姐**完全不 visible** (path A 全程仅通过 Lisa 转述 / 群消息)?

### 13.4 E12 路径 A reward 文案 "您本月协助同事..." 是否过 expose

KPI Review 浮层 (路径 A) 系统注释 verbatim "您本月协助同事完成关键交付" 等——我加了笑天 internal "翻译过来是: 你帮 Lisa 改 self_review + 周末陪 + 给 Zoe 全 5 分 + 提前同事 referral" 来 demonstrate anti-Pillar 1。

**Concern**: 笑天 internal "翻译过来" 是不是**过 explicit expose**? 像 designer commentary 而不是 protagonist voice?

**Reasoning**: protagonist.md S3 末 voice 应该是 "我没救成她。这就是答案" — 但路径 A 我救成了 Lisa, voice 应该不是 "没救成" 而是 "救了 = 我下月 +18% = anti-Pillar 1 完整 exposed"。**GM 决定 voice 是否 OK**.

### 13.5 E12 路径 D 只触发 sick_count >= 4

per round-2 reply §1, sick_count >= 4 触发路径 D。但 sick_count 累积条件: S2 sick_count = 0 (W3 没在 S2 写病倒事件) + S3 我也没在 E9-E11 写病倒事件——所以 sick_count = 0 throughout S3 = **路径 D 永远不触发**。

**Concern**: 路径 D 的 stitch 写了但 unreachable — 是 dead code? 或者 sick_count 应该有其他 trigger event?

**GM 决定**: S3 是否需要补 1-2 个 sick_count++ event (例如 D71 笑天因感冒请假 1 天 trigger sick_count + 1)? 还是 sick_count 仅在 daily-choices.ink 装病 cards 里 trigger? 如果 daily choice 装病 cards 累积 ≥ 4 就触发, 那么 D77 path D morning 那个 stitch 仍 reachable.

### 13.6 E11 D77 周日 4 路径分支 — 路径 B 和 A 共享同一 stitch

D77 morning router 我用:
```ink
{lisa_weekend_company or (lisa_score >= 5):
    -> day_77_path_ab_morning
- else:
    {lisa_abandoned_at_weekend:
        -> day_77_path_e_morning
    - else:
        {sick_count >= 2:
            -> day_77_path_d_morning
        - else:
            -> day_77_path_c_morning
        }
    }
}
```

路径 A 和 B 共享 `day_77_path_ab_morning` (周末加班 Lisa 仍在工位)。E12 D84 才分 A vs B.

**Reasoning**: outline §5 E11 周日 spec 说 "路径 A/B (S2 path A/B + lisa_score ≥ +5)" 共享 stitch. ✓

### 13.7 lisa_referred_external 触发条件复杂

D80 路径 A 玩家专属 Decision 用 `lisa_helped_self_review or lisa_weekend_company or lisa_zoe_feedback_positive` 当 unlock condition (不是 cumulative_hero_count ≥ 3 because 包括 lisa_helped_pps S1 + lisa_helped_after_hr S2)。

**Reasoning**: 我用 S3-only flag 是因为 D80 是 S3 中 Decision, 玩家应该有 S3 hero behavior 才 unlock 这个 advanced Decision。但 round-2 reply §2 没明说这个 unlock 是 S3-only 还是 cumulative.

**GM 决定**: 是否 OK 这个 unlock condition?

### 13.8 食堂阿姨 dialog = 0 但有 # speaker: food_court_auntie tag

D78 食堂阿姨"笑了一下不说话" — 我加了 `# speaker: food_court_auntie` tag, 即使她**没 dialog**.

**Reasoning**: per brief §3.1 b "even 0 dialog 也要标 speaker, engine 用此判断渲染" — 我按这个执行。但**严格说她整段是 narration 不是 dialog**, tag 是 over-application。

**GM 决定**: 是否 OK, 还是 NPC 0 dialog scene 不需要 # speaker tag?

---

## 14. Open Questions

### Q1. E12 路径 A finale "笑天 internal anti-Pillar 1 expose" voice 是否过 explicit

per 13.4 — 是否 trim?

### Q2. sick_count S3 路径 D 是否 reachable?

per 13.5 — 需要在 E9-E12 加 sick_count++ events 吗?

### Q3. D78 食堂阿姨 visibility logic 用 lisa_weekend_company 是否 OK?

per 13.2

### Q4. 林姐 D84 远端照片 vs 完全 not visible — 哪种更符合"不要笑天" 的 deliberate restraint?

per 13.3

### Q5. lisa_referred_external D80 unlock condition 用 S3-only flag 是否 OK?

per 13.7

### Q6. food_court_auntie 0 dialog 是否需要 # speaker tag?

per 13.8

### Q7. promotion_candidate_count 在 D84 路径 A 末 ++1 — 是否触发 S10 promotion 警告 setup?

E12 D84 路径 A finale 我加了 `~ promotion_candidate_count = promotion_candidate_count + 1`. per series-structure §4.5, promotion_candidate_count >= 2 + KPI > 150 触发 promotion 警告 event。S3 末 promotion_candidate_count 仅 +1 (S1+S2 都没增) — 还不够触发 S10 event, 但**我做了 setup**.

**GM 决定**: S3 路径 A finale 是否应该 +1 promotion_candidate_count? 还是该 +2 (因为路径 A 玩家"做得太好")? 还是该 sumset to 一个独立 path-A-only flag?

---

## 15. 工作量统计

| 阶段 | 实际工时 |
|---|---|
| 读 reference (S3 outline / round-2 reply / S2 ink samples / brief 自起草) | ~30 min |
| Add 6 S3 flag VARs | ~10 min |
| Write episode-9.ink (1839 行) | ~2.5 hr |
| Write episode-10.ink (1859 行) | ~2.5 hr |
| Write episode-11.ink (1816 行 含 4 路径周末分支) | ~3 hr |
| Write episode-12.ink (2270 行 含 5 路径独立 chains + finale_recap + function) | ~3.5 hr |
| Build error fix (E10 conditional + E12 function syntax + && / || → and / or) | ~30 min |
| Submission report (本文档) | ~30 min |
| **总计** | **~13 hr** |

跟 brief §10 估的 12-14h 一致。

---

## 16. 等 GM round-2 reply

S3 R1 提交完成。等 GM (designer) + W2 QA worker 逐项验证。

**预期 reply 形式**:
- 整批 PASS / minor issues / hard 打回
- W2 QA 跑 E12 5 路径 reproducer (sick_count >= 4 / cumulative_hero_count >= 5+lisa_score>=25 / cumulative >= 3 / cumulative >= 1 / else)
- 路径 A 林姐 visual 实装 verify
- 笑天 voice S3 末 review (我没救成她 vs 我救了她 = +18%)
- 7 Open Q 答复

---

## END
