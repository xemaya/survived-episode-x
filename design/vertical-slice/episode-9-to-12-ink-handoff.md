# S3 Ink Writer · Handoff Brief (Episodes 9-12)

> Status: 第 1 版
> Author: Game Designer (GM)
> Last Updated: 2026-05-06
> 收件人：**S3 ink writer 分身 CC session** — 可以是 fresh 启动 / 也可以 reuse W3 (W3 R2 已 closed, 但 session context 仍在)
> 配套提交输出: `episode-s3-round-1-response.md`

---

## 0. 你的处境

`survived-episode-x` 是反向 KPI 中文职场生存模拟，TS+Vite+PixiJS+Tauri+Ink 栈。叙事内容写在 `design/vertical-slice/*.ink`，编译成 JSON 由 inkjs runtime 跑。

你是 **S3 Ink Content Worker**。前面已 closed:
- S1 (4 集 episode-1/2/3/4.ink) — 早期 Round 1+2 worker session 写
- S2 (4 集 episode-5/6/7/8.ink) — W3 写 (R1 + R2 共 ~14.5h)
- S1 cleanup (Lisa 剪短发 → 眼药水 migrate to E7) — W3 R1
- 8 episodes 的 # pagebreak / # speaker / `-` gather sweep — W3 R2
- daily-choices.ink (60 个 daily choice) — Round 1+2+3 worker

**现在你的活**：写 episode-9.ink ~ episode-12.ink (4 个新文件), 基于 `season-3-arc.md` 完整 outline + `season-3-arc-round-2-reply.md` 2 处 addenda。

完成后 **GM (我) + W2 QA worker** 会 review。不通过打回。

---

## 0.5 S3 特殊性 — 高 quality bar

S3 不是普通季。**S3 是整 series 第一个真正的"扎点 finale"**——E12 Lisa 走/留 climax。8-12 集 累积选择全部兑现。**写不好, 整 series 的 emotional arc 塌**。

这意味着:
- **比 S2 严苛**：S2 7:3→3:7 笑泪曲线允许偏笑安全; S3 5:5→2:8 必须扎到底
- **5 路径分叉**：E12 finale 5 路径每条都要"扎"——任意一条出现"reward UI / BGM / 庆祝过场" = 重写
- **anti-Pillar 1 极致**：路径 A 救了 Lisa = 你下月 threshold +18%（更大的处刑）。HR-speak 的"团队精神"+"更高的责任" 必须直接抄, 不加情绪
- **林姐 First Impression** is new NPC entry——deliberate restraint 累积 12 集后第一次出场。她**不要笑天**, 这必须强化"另一种活法存在但你不在那条路径上"

如果你不确定某场戏是否 OK, 就问。Submit 报告里写 Open Questions, 不要自己脑补补全 spec gap。

---

## 1. 必读 reference（按顺序）

### 主 spec (必读 1-2 遍)

1. **`design/vertical-slice/season-3-arc.md`** — **你的主要 spec**。S3 outline 含:
   - §1 主题 + 笑/泪曲线
   - §2 Beat Archetypes + cumulative_hero_count 系统
   - §3 Per-NPC arc tables (10 NPC + 林姐 + 食堂阿姨 ambient × 4 episodes)
   - §4 Cross-NPC scenes matrix
   - §5 Per-Episode Beat Sheet (E9-E12)
   - **§6 5 路径表 + KPI Review 浮层文案 (anti-Pillar 1 极致)**
   - §7 Quality Rubric (S3 specific 加 7 条)
   - §10 设计自检 / §11 ❌ 不能做的事

2. **`design/vertical-slice/season-3-arc-round-2-reply.md`** — **必读, 2 处 critical addenda**:
   - §1 路径优先级 logic (`sick_count >= 4` 先于 `cumulative_hero_count`)
   - §2 cumulative_hero_count = 6 flag 集合 + ≥ 5 触发阈值 (S3 outline §6 写的 ≥ 6 是过 ceiling, ink 实算用 ≥ 5)
   - §2 末有 `compute_cumulative_hero_count()` ink function snippet — 直接抄到 episode-12.ink

### Ink syntax 锚 (作 .ink 体量 / 笑天 voice / # tag conventions sample)

3. **`design/vertical-slice/episode-1.ink`** — designer 写的 Day 1+2 morning 完整样例 + 全 series VAR 声明 + helper functions
4. **`design/vertical-slice/episode-5.ink`** ~ **`episode-8.ink`** — W3 写的 S2 4 集, 你最近的 stylistic + structural reference
5. **`design/vertical-slice/episode-3.ink`** — W3 cleanup 后的样子, S1 末 reference

### Voice + Design 原则 (必读 1 遍, 写每场戏前回查)

6. **`design/vertical-slice/series-structure.md`** — 52 集 macro
7. **`design/vertical-slice/protagonist.md`** — 笑天 voice (S3 末转变为"我没救成她。这就是答案"——S1 起的 voice arc 走完)
8. **`design/vertical-slice/npcs.md`** v2 — 10 NPC 长弧光 + **§10 林姐 (S3 finale 路径 A 第一次出场)**
9. **`design/vertical-slice/tone-bible.md`** v2 — 5 写作原则
10. **`design/vertical-slice/season-1-arc.md`** v2 — 理解 S1 上下文
11. **`design/vertical-slice/season-2-arc.md`** — 理解 S2 上下文 (S3 接续 S2 finale "我可能要走"")

### 历史 reference

12. **`design/vertical-slice/episode-ink-handoff.md`** — W3 (S2) 的 brief, 你的格式参考
13. **`design/vertical-slice/episode-s2-round-1-reply.md`** + **`episode-s2-round-2-reply.md`** — GM 对 W3 review feedback, 学 GM 的 review 风格 (你将被同类 review)
14. **`design/vertical-slice/episode-s2-round-1-response.md`** + **`episode-s2-round-2-response.md`** — W3 提交报告, 学提交格式

读完 1-11 是必需。12-14 读 1 遍即可 (~15 min)。

---

## 2. 任务 — 写 episode-9.ink ~ episode-12.ink

按 `season-3-arc.md` outline + round-2 reply addenda, 写 4 个 .ink 文件。

### 输入 / 输出

| 输入 | 输出 |
|---|---|
| `season-3-arc.md` §5 E9 beat sheet | `design/vertical-slice/episode-9.ink` (新建) |
| `season-3-arc.md` §5 E10 beat sheet | `design/vertical-slice/episode-10.ink` (新建) |
| `season-3-arc.md` §5 E11 beat sheet | `design/vertical-slice/episode-11.ink` (新建) |
| `season-3-arc.md` §5 E12 beat sheet | `design/vertical-slice/episode-12.ink` (新建) — **Season Finale = Lisa 走/留 climax + 5 路径** |

每集 **1500-2200 行 .ink** (E12 因 5 路径分叉可略长 ~2300-2500)。每个文件顶部 `INCLUDE episode-1.ink` (继承 VAR + helper functions)。

### Day 编号 convention

- E9 = Day 57-63
- E10 = Day 64-70
- E11 = Day 71-77
- E12 = Day 78-84

### 每个 .ink 文件结构（套 episode-5.ink 模板, 见样例 .ink 顶部）

```ink
// ============================================================================
// Episode N · Week N · 「主题」
// ============================================================================
//
// Status: 第 1 版 (S3 ink writer 写)
// Author: 分身 CC session (S3 Round 1)
// Last Updated: 2026-05-XX
//
// 配套 reference: 同 episode-1.ink (见其顶部说明)
// 主 spec: design/vertical-slice/season-3-arc.md §5 EN beat sheet
// + season-3-arc-round-2-reply.md addenda
//
// 设计目标 (摘要 from season-3-arc.md):
//   1. ...
//   2. ...
//
// 红线 (S3 不能做 - per season-3-arc.md §11):
//   - ...
//
// Verbatim quotes 必保留 (per season-3-arc.md §7 + 跨季 anchor):
//   - ...
//
// ============================================================================

INCLUDE episode-1.ink

// EN entry
-> episode_N

=== episode_N ===
# scene: home
# time: monday_morning_week_N
# pagebreak
-> day_X_morning_briefing

[7 days × ~250-300 行 = ~1700-2100 行]

-> END

// EOF episode-N.ink
```

---

## 3. 关键约束（不能违反）

### 3.1 跟 W3 R2 一致的 sweep 标准

W3 R2 已经把 E1-E8 + daily-choices.ink 做了以下 sweep, 你的 E9-E12 必须 born with these:

#### a) `# pagebreak` tag — 必加位置

| 场景 | 加 `# pagebreak` |
|---|---|
| `day_N_after_work` 选项后 → daily_recap 之间 | ✅ |
| `day_N_daily_recap` 末 → next morning_briefing 之间 | ✅ |
| 周五 daily_recap → weekly_recap → next 周一 morning 之间 | ✅ × 2 |
| episode finale → cliffhanger 前 | ✅ |
| 长 internal monologue 块（≥ 4 段）后 → 下一 NPC 出场前 | ✅ |
| 普通同事互动间 / Decision Moment 前 | ❌ |

每集预期 **14-18 个 pagebreak**。E12 因 5 路径分叉会更多 (~20+)。

#### b) `# speaker: <id>` tag — 每个 NPC dialog 之前必加

13-id mapping table (per `episode-s2-round-1-reply.md` §2):

| id | NPC | 何时用 |
|---|---|---|
| `protagonist` | 笑天 | "你说" / "你回" / "你: " 等主角 dialog 前 |
| `lisa` | Lisa | Lisa 的所有 dialog |
| `david` | David | David 的所有 dialog |
| `wang_director` | 王总监 / Eric | 王总监 dialog (含 "老板助理 Jeffrey" 群消息也用此 id) |
| `vivian` | Vivian | Vivian dialog |
| `lao_zhou` | 老周 | (S3 老周 0 dialog——但如有其他 character 错认为老周 voice 的 fallback) |
| `zoe` | Zoe (HR) | Zoe dialog (含 "另一个 HR" fallback) |
| `li_ayi` | 李阿姨 | 李阿姨 dialog (含 "另一个清洁阿姨" fallback) |
| `mama` | 妈妈 | 妈妈视频 dialog |
| **`lin_jie`** | 林姐 (**S3 E12 路径 A 第一次出场**) | 林姐 dialog (her catchphrase "让她过来吧" + "我们这边节奏不一样") |
| `it_xiaoma` | IT 小马 | IT dialog |
| `food_court_auntie` | 食堂阿姨 (ambient) | 食堂阿姨"笑一下不说话" 也加这个 tag (即使 0 dialog 也要标 speaker, engine 用此判断渲染) |

写法 (W3 R2 实例):

```ink
* [挺好看]
    # speaker: lisa
    Lisa："谢谢哈。"
    _她转回工位, 但表情松了一下。_
    ~ lisa_score = lisa_score + 3
```

主角 (`你说: "..."`) 也要加 `# speaker: protagonist`——engine 用这个判断"是否 mount NPC bubble"。

#### c) `-` gather — 每个多选项 cluster 末必加

W3 R2 sweep pattern:

```ink
* [选项 1]
    body 1
    ~ var = ...

* [选项 2]
    body 2
    ~ var = ...

* [选项 3]
    body 3
    ~ var = ...

-                          ← 必加这个 gather, 不然 ink WARN loose end

~ check_state_after_choice()
# pagebreak
-> next_stitch
```

如果 `-` gather 之后还有 root-level `~ var = ...` (例如 weekend `~ state = state + 30`), gather 应该放在那个 `~ var` **之前**, 让 3 选 1 都汇总后无差别 +N (这是 W3 R2 D34 quick fix 的 pattern):

```ink
* [选项 1] body
* [选项 2] body
* [选项 3] body

-                          ← gather 在这

~ state = state + 30       ← root logic, 3 选 1 都汇总后执行
~ check_state_after_choice()
-> next_stitch
```

### 3.2 Ink 语法红线

跟 `episode-generation-brief.md` (S1 brief) 一致:

- **每个 stitch 末尾必须** `~ check_state_after_choice()` + `-> next_stitch` (runtime 依赖)
- **每个 stitch 必须有** `# scene` + `# time` tag
- **不允许中文 stitch 名** (ink identifier ASCII-only)
- **不允许 `*X*` 单星号 italic** (被解析为嵌套 choice) — 用 `_X_` 下划线 italic
- **不允许 `**Speaker**：` line-start prefix** — 用 `Speaker：` 直接 (W3 修过 7 处同类 bug, 别再引入)
- **不允许 `===` ASCII 等号 line** at column 0 (会被 ink 解析为 knot 头) — 如需 visual divider, 用 markdown `>` quote block 或者 `# divider` tag (per W3 R2 D50 海报修复)
- **Designer-written 内容不动** (episode-1.ink 顶部 VAR + helper functions)

### 3.3 跨季 flag — 直接 read, 别 redeclare

W3 R2 已在 episode-1.ink VAR 块加:

```ink
VAR lisa_helped_after_hr = false     // S2 D56 path A
VAR mom_visit_pending = false
VAR mom_visit_postponed = false
VAR mom_visit_pending_undecided = false
```

S3 ink writer 在 episode-9.ink 不需要 redeclare, 直接读。但你需要在 **episode-1.ink 加**以下 4 个新 S3 flag:

```ink
// S3 - hero count contributors
VAR lisa_helped_self_review = false      // E10 D67 path A 帮 Lisa 改试用期自评
VAR lisa_weekend_company = true          // E11 D77 path A 周末加班陪 Lisa
VAR lisa_zoe_feedback_positive = false   // E11 D74 给 Zoe 美化 Lisa 协作反馈
VAR lisa_referred_external = false       // E12 D80 主动跟 Lisa 提前同事跳槽机会
VAR lisa_abandoned_at_weekend = false    // E11 D77 path C/E
VAR cumulative_hero_count = 0            // computed by function, 但也作 VAR cache
```

并在 episode-12.ink 加 `compute_cumulative_hero_count()` function (per round-2 reply §2 末 snippet).

---

## 4. S3 finale 5 路径 — 路径优先级 logic (E12 D84 Sunday)

per `season-3-arc-round-2-reply.md` §1 + §2:

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

= day_84_finale_router
~ cumulative_hero_count = compute_cumulative_hero_count()

{
    - sick_count >= 4:
        -> day_84_path_d_sick_finale
    - cumulative_hero_count >= 5 && lisa_score >= 25:
        -> day_84_path_a_lin_jie_save
    - cumulative_hero_count >= 3:
        -> day_84_path_b_lisa_thanks
    - cumulative_hero_count >= 1:
        -> day_84_path_c_lisa_silent_walk
    - else:
        -> day_84_path_e_no_one_tells_xiaotian
}
```

5 路径每条都需要独立 stitch chain (不是 fall-through), 见 §5 每路径具体 beat。

### 4.1 路径 D / E runtime 拦截 (类似 S2 D56 path D/E)

S2 D56 path D/E 有 W1 batch 8 实现的 `path-interceptor.ts` (T20)。S3 E12 D84 finale 路由可以**完全在 ink 内做**(用 conditional + divert), 不需要 TS runtime 拦截。

**但** 如果你写到一半发现某个 path 需要 runtime 才能拿到 state (例如 `coffee_machine_broken_days` 之类外部 state), 就 leave a TODO comment + 提到 W1 batch 9. **预期**: 5 路径全可在 ink 内 route, 不需 TS hook。

### 4.2 5 路径 stitch 命名建议

```
day_84_path_a_lin_jie_save        — Lisa 转岗客户成功部, 林姐 First Impression
day_84_path_b_lisa_thanks         — Lisa 走 + 周日"谢谢你"
day_84_path_c_lisa_silent_walk    — Lisa 走没说再见
day_84_path_d_sick_finale         — 笑天周日装病, 没看到 Lisa 走
day_84_path_e_no_one_tells_xiaotian — 笑天后知后觉
```

每条 path stitch 之后汇总到 `day_84_finale_recap` (类似 S2 E8 D56 finale_recap 的 collector pattern)。

---

## 5. 关键 verbatim quotes 必保留 (per season-3-arc.md §7)

S3 verbatim 锚 (跟 S1/S2 同样的"必字字保留"约束):

| Quote | 集 / 触发 | Why |
|---|---|---|
| Lisa "**(我)也好，我自己也想换换**" | E9 D63 周日朋友圈 配图 (E9→E10 cliffhanger) | S3 第 1 次 Lisa self-acknowledge 离职准备 |
| 王总监 "**你最近不一样啊**" | E9 D57 周一 Lisa 工位旁 cue | S2→S3 push 升级第 1 句 |
| Lisa "**在赶**" | E10 D66 周三晨会 答 王总监 "PPT 怎么样" | Lisa 倒数第 2 次主动 dialog (S3 末她 dialog 频率↓) |
| 李阿姨 "**这家公司的人每两个月走一茬**" | E10 D68 周五傍晚茶水间 | S2 verbatim "上一个坐这位置的也是这么想的" 升级版 |
| 王总监 "**你跟 Zoe 说一下吧, 下周三签字**" | E11 D74 周四 19:30 笑天偷听 (王总监 C Vulnerability layer 3) | 命令链显形 |
| Lisa "**明天来公司加班吗? 我自己一个人有点慌**" | E11 D75 周五 21:00 微信 | **路径分叉关键 quote** (S3 outline §1 标 Decision Moment 2) |
| Lisa "**笑天, 下周可能就出结果了。不管怎样, 谢谢你**" | E11 D77 周日 晚 (E11→E12 cliffhanger) | S3 第 1 次 Lisa 用"谢谢你"; anti-Pillar 4: 她在告别 |
| 妈妈 "**那个谁的女儿离职了, 回老家考公务员了**" | E12 D84 周日 8:30 视频 | thematic mirror — 妈妈不知情说出 Lisa 故事另一版本 |
| 林姐 (**仅路径 A**) "**让她过来吧**" | E12 D84 周日 11:00 王总监 phone (场外听到) | 林姐 First Impression catchphrase #1 |
| 林姐 (**仅路径 A**) "**Lisa, 是吧? 跟我去那边坐**" | E12 D84 周日 14:00 林姐第一次出现在屏幕上 | 林姐叫 Lisa 不带姓 — Pillar 4 "另一种活法" 关键 visual evidence |
| 王总监 (**仅路径 A**) "**小笑啊…陈天啊…你最近表现不错。下个月看你的**" | E12 D84 周日 KPI Review 后 | anti-Pillar 1 极致 — 救 Lisa = +18% threshold |
| KPI Review 浮层 (**仅路径 A**) "**您本月协助同事完成关键交付。公司认可您的团队精神。下月将给予您更高的责任。**" | E12 D84 周日 9:30 系统注释 | HR-speak 直接抄, 不加情绪 (per outline §6) |

**12 个 verbatim quote** (比 S2 7 个多 5 个) — 因为 S3 是 series 第一个 emotional anchor 集中爆发集。

任意 1 个 verbatim 没字字保留 = hard fail = 整批打回。

---

## 6. 笑/泪比例 hard rule（per `season-3-arc.md` §1）

| 集 | 比例 | 主基调 |
|---|---|---|
| E9 | 5:5 | 笑泪持平 (Lisa 穿正装反差 + 王总监 cue "你最近不一样啊" 笑点 + 1 个轻扎 Lisa 桌上文件夹) |
| E10 | 4:6 | 笑减少 (Lisa 没吃饭 + 偷哭 + Zoe 90 分钟面谈像处刑) |
| E11 | 3:7 | 笑变少 (周末加班 + 路径分叉点) |
| E12 | 2:8 | 整集情感最重 (5 路径都"扎") |

**整季 ≈ 3.5:6.5** — 比 S2 (5:5) 更扎, 比 S1 (7:3) 更扎得多。

---

## 7. 红线（per `season-3-arc.md` §11）

逐条 verify, 任意 1 条违反 = hard fail:

- ❌ 不要让 Lisa 在 E9/E10/E11 决定走或留（那是 E12 finale）
- ❌ 不要让王总监对 Lisa 直接讲 "你不适合"（Zoe 的工作 / 月度面谈才说）
- ❌ 不要让 David 在 S3 燃尽（S6 finale）—— S3 David 是"加倍施压期" + 燃尽前兆 setup 持续
- ❌ 不要让老周说出第二句话（S1 唯一对话已耗尽 + S2 0 句话 + S3 仅 E9"抬头看一眼")
- ❌ 不要让林姐在 S3 之前出场（仅 E12 finale 路径 A 第一次）
- ❌ 不要让玩家在 E12 finale "赢"——路径 A "救 Lisa" = 你下月 threshold +18%
- ❌ 不要给 Lisa 完整 backstory expose（仍 ambiguous）
- ❌ 不要让笑天对 Lisa 说"你别担心"或"会好的"
- ❌ 不要让 Lisa 走/留逻辑不基于累积选择（必须由 S1+S2+S3 累积 hero count 决定）
- ❌ 不要在 E12 finale 路径 A 时给"happy ending UI"——林姐离开前看笑天 0.3 秒, 没说话, 没 BGM, 没特殊过场
- ❌ 不要让 Lisa 在路径 A 之外"反转回归"——路径 B-E Lisa 都走
- ❌ 不要引入 npcs.md 未注册的新 NPC（林姐已注册）

---

## 8. 验收（GM + W2 QA review）

### 硬性 fail（任意 1 条 = 整批打回）

- 任何 episode .ink < 1500 行（E12 < 2000 因为 5 路径）
- 任何 stitch 漏 `~ check_state_after_choice()` / `-> next` / `# scene` / `# time`
- 任何 `# pagebreak` policy table 应加位置 (per §3.1 a) 漏加
- 任何 NPC dialog 漏 `# speaker:` tag
- 中文 stitch 名（ink identifier ASCII-only）
- `*X*` 单星号 italic / `**Speaker**:` line-start / `===` ASCII 等号 line
- 引入 `npcs.md` 未注册的新 NPC
- §5 12 个 verbatim quote 任 1 漏字
- §7 红线任 1 违反
- E12 5 路径任 1 fall-through (未独立 stitch chain)
- 路径 A 出现"happy ending UI / BGM / 庆祝过场"
- E12 路径 A reward 不是 threshold +18% (anti-Pillar 1 极致 mandatory)
- 笑天 voice 退回 "她还相信。我也相信过" S1 baseline (S3 末应该是 "我没救成她。这就是答案")

### 软性 fail（≥ 3 条 = 打回）

- 笑/泪比例显著偏离 §6 表
- Cross-NPC 同框场景 < 3 / 集 (E12 < 5)
- Lisa quiet sign 累积 not 渐进 (1-3 集都"还好" + 4 集突然走)
- §5 verbatim quote 字字保留但语境改了
- NPC archetype 漏标 # tag
- 选项 > 6 字 + 不是专用职场梗 (per tone-bible v2.1 §3)
- 笑天对 Lisa 的内心独白显得"主角光环" 或 "我要救她"

---

## 9. 提交格式

写 `design/vertical-slice/episode-s3-round-1-response.md`:

```markdown
## S3 Round 1 提交报告 — episode 9-12

### 输出 4 个文件
1. episode-9.ink (新建) — XXXX 行
2. episode-10.ink (新建) — XXXX 行
3. episode-11.ink (新建) — XXXX 行 (路径分叉点 D75)
4. episode-12.ink (新建) — XXXX 行 (Season Finale, 5 路径)

### episode-1.ink VAR 块新增 6 个 S3 flag
[diff snippet]

### 每集 NPC archetype 完成度 (跟 S2 R1 提交格式同)
| NPC | E9 | E10 | E11 | E12 |
|---|---|---|---|---|
| Lisa | ✓ | ✓ | ✓ | ✓ (D finale) |
| ... |

### §6 笑/泪比例自检
- E9: 实际 5:5 ✓
- E10: 实际 4:6 ✓
- ...

### §5 12 个 verbatim quote 保留
- 12/12 全保留 ✓

### §7 12 条红线检查
- 12/12 ✓

### E12 5 路径实现
- 路径 A (lin_jie_save): episode-12.ink:XXXX-XXXX
- 路径 B (lisa_thanks): episode-12.ink:XXXX-XXXX
- ...

### Build verify
pnpm ink:build: ✓ 13/13 (E1-E12 + daily-choices) succeeded, 0 fatal errors

### Open Questions
- ...
```

---

## 10. 工作量预估

W3 写 S2 4 集用了 R1 ~11h + R2 ~3.5h = ~14.5h。

S3 比 S2:
- 多 1 个新 NPC entry (林姐 First Impression — 但仅 E12 路径 A, 体量小)
- 多 5 路径 finale (E12 比 E8 finale 复杂 ~30%)
- 高 quality bar (扎到底, 不能"安全偏笑")

**预估 R1 ~12-14h** (比 S2 R1 略多)。R2 (sweep + Q polish) 预期 ~3-4h (跟 S2 R2 同档)。**总: ~15-18h**。

---

## 11. 如果你卡壳了

- spec 之间矛盾 (outline §6 vs round-2 reply §2 阈值不一致): 按 round-2 reply 优先
- spec 没说的 beat: 写在提交报告 Open Questions, 不要自己补全
- 写到一半发现某条路径逻辑撞红线: 停下来, 写到 OQ
- 不确定某 verbatim 是否需要"调整" (e.g. 妈妈"那个谁的女儿"今年这年龄段哪个最常见): 保持 verbatim, 不调整

---

## 12. 最后

记住：

> **S3 是 series 第一个真正的"扎点 finale"。**
> **5 路径都扎, 没有"赢"。**
> **路径 A 救了 Lisa = +18% threshold (anti-Pillar 1 极致)。**
> **林姐 First Impression: 她不要笑天 (Pillar 4 "另一种活法存在但你不在那条路径上")。**
> **笑天 voice 在 S3 末转变: "我没救成她。这就是答案。"**
> **写真, 不写好。**

完事写到提交报告, 等 GM + W2 QA review。

如果 R1 quality 跟 W3 R1 同档 (production-ready 一发过), 你就 unblock 整个 series demo P5 走完。

祝你工作顺利。

---

## END
