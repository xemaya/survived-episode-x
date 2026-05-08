# W6 S5 Round 1 Reply (GM verdict + 6 Q answers)

> Status: 第 1 版
> Author: GM
> Date: 2026-05-07
> 收件人: W6 (S5 outline writer reuse session)
> 配套: `season-5-arc.md` (~65k file, ~700 lines) + `season-5-arc-round-1-response.md`

---

## TL;DR

**整批 PASS** — 全 6 Q 给具体 decision, 4 个保留 + 1 个 register + 1 个 add constraint。**W6 round-2 task = 1 处** (实习生小张 retro-register to npcs.md), 30 min。

S5 outline 在 W4 (S3) + W6 (S4) 之上又一次 production-quality。整 series 5 个 season outline (S1-S5) 全 ship。

---

## 1. Q1 答 — 实习生小张 ✅ register npcs.md 作 #11 NPC

**Decision**: ✅ register。

理由 (跟 W6 recommendation 一致):
- 实习生小张是 series-structure.md §5 已 named NPC (Endgame Variant D trigger: "陈哥新年快乐!")
- 跨 S5-Endgame 全程有 intern_score 累积 + named character note + 视觉锚 + 口头禅 = 满足 NPC registration threshold
- 跟食堂阿姨 / 张磊 不同档 — 那两个无 score 系统无 dedicated arc
- 不 register risk: 未来 ink writer (S5-S12 batch) 不知 baseline, 写得 inconsistent

**W6 round-2 task** (30 min):
- 把 `season-5-arc.md §3.1` character note 移植到 `design/vertical-slice/npcs.md` §11 (新增 section)
- 跟 npcs.md §1-§10 同 format (基本信息 / 视觉锚 / 内在驱动 / 笑/泪 / 经典 line / 设计禁忌)
- 完成后写 `npcs-round-N-update-response.md` (1 page note), stand down

`season-5-arc.md §3.1` 保留作 S5 specific reference (期间动作), `npcs.md §11` 是 source-of-truth (跨 series 弧光)。

## 2. Q2 答 — 张磊 E18 "陈哥" ✅ keep, 加 constraint

**Decision**: ✅ keep E18 张磊 "陈哥" setup, 加 1 个 ink writer constraint。

理由 (跟 W6 partial agree):
- setup-payoff 设计正确 — E18 张磊 visible signal + E20 笑天 internal recognition = layered
- 但**张磊作为 unregistered ambient NPC 没有 character note 说他叫前辈"X 哥"** — 他用"陈哥"必须有 motivated reason
- 那个 motivated reason = **王总监 running gag mispronunciation cascade** (Q5 答验证)

**给 S5 ink writer constraint** (写 episode-18.ink E18 张磊"陈哥" stitch 时):

E18 张磊"陈哥"line 必须紧跟 a 王总监 mispronounce scene. 例如:
1. 周一 王总监介绍张磊给笑天: "这个是陈天啊..." (running gag)
2. 张磊 听到, 后来叫笑天时: "陈哥, 那个 Wi-Fi 密码是?"
3. 笑天 internal: "_他听王总监叫'陈天', 自然用'陈+哥'_"

**不要** 让张磊在 W 总监 mispronounce 之前就 spontaneously 叫"陈哥"。否则 称呼 unmotivated。

## 3. Q3 答 — E18 5 天连休 daily breakdown ✅ keep

**Decision**: ✅ keep, 不简化。

理由 (跟 W6 一致):
- E18 是 series 内笑天**第一次离开 北京** — fresh visual + 小确幸 anchor 应该 expand
- 5 stitch (周三高铁 / 周四海边 / 周五小吃 / 周六回京 / 周日妈妈视频) 是 minimal viable expansion
- 笑泪 6:4 偏笑要求 E18 体量给小确幸呼吸空间
- 700-800 行 tier 跟其他 episode in line, 不 tax ink writer 也不 tax 玩家

## 4. Q4 答 — 妈妈 "30 年前去过北戴河" ✅ allow, 加 constraint

**Decision**: ✅ allow "你爸 30 年前去那边玩过", 加 1 个 ink writer constraint。

理由:
- 30 年前 = 笑天 2 岁, 爸爸还活着, alive historical memory ≠ emotional anchor "8 年前去世"
- 跟 S4 Q5 "上坟"是 process 词 / "30 年前玩过" 是 active historical 都不 expose 去世
- npcs.md §9 character note 的 spirit 是 "不 expose 爸爸去世 emotional anchor", **不是** 字面 ban "你爸"

**给 S5 ink writer constraint** (写 episode-18.ink 北戴河 stitch 时):

1. 妈妈 dialog: "你爸 30 年前去那边玩过" / "你爸说那边的海蛎子最好" / etc — 合规
2. 笑天 internal monologue **不可以** 接续 emotional 反馈 line 类:
   - ❌ "_我没跟爸爸去过北戴河_"
   - ❌ "_8 年了我都没回过那地方_"
   - ❌ "_要是爸爸还在..._"
3. 笑天 internal monologue **可以** keep neutral / 自嘲 line 类:
   - ✅ "_她说的可能是隔壁桌李叔家的事她记错了_" (deflection)
   - ✅ "_30 年前的海跟现在不是同一片海_" (philosophical, 不带去世 emotional)
4. **不要** add hidden flag like `dad_beidaihe_visit_decline` (会 enable 未来 episode 用 emotional anchor 作 payoff — 违反 character note)

如果 ink writer 觉得"你爸"提及 too risky, **替代 wording**: 妈妈 line 改 "**我以前跟你姨去那边玩过**" (替换 actor 为妈妈本人) — effects 一致 (历史 mention) 但更 conservative。**ink writer judgment call**, 两种都 GM-approve。

## 5. Q5 答 — 王总监 running gag → 实习生"陈哥" causal chain ✅ keep

**Decision**: ✅ keep, **不**让 实习生"陈哥" independent of 王总监 running gag。

理由:
- causal chain 太 elegant 不要 break:
  - 王总监 5 season 叫不准 (small 笑/陈天/差不多)
  - 实习生 听到"陈天" 自然想叫"陈+哥"
  - 笑天 internal 笑出来又笑不出来 ("_陈哥。不是天哥。是陈哥。_")
- protagonist.md §9 verbatim 锁了"陈哥 vs 天哥" 对比 (David 叫天哥暗讽 / 实习生叫陈哥因为王总监 mispronounce)
- 没有 running gag chain, 实习生 用"陈哥"显得 unmotivated random
- 这条是 series 5 个 season 累积 running gag 的 narrative payoff — 罕见的 "small detail 跨 5 集变成 macro narrative event" — 不能放过

## 6. Q6 答 — 路径 D §5 inline mention ✅ keep, 不 expand

**Decision**: ✅ keep current §5 inline mention, **不** expand 到 explicit stitch about intern hands-on。

理由 (跟 W6 一致):
- 路径 D 玩家 实习生 接触 4/5 天 vs 路径 A/B/C 5/5 天 = 减 20% baseline
- intern_score 累积比 A 慢是 mathematical naturally fall-out, 不需 explicit stitch 显示
- expand 到 specific stitch 会让 路径 D 玩家觉得 "为什么要专门写我请假那天?" — meta-aware 干扰沉浸
- W6 §5 现 inline mention "路径 D 玩家此选: 笑天再装病 1 次没去食堂" 已够

**给 S5 ink writer constraint**:
- E20 周三 stitch 不需要 add "笑天装病当天实习生小张 主动找笑天 但被告知请假" 那种 explicit setup line
- 实习生 周四见笑天时 narrate "他终于回来了" (从 intern POV) 已够 indirect 告诉玩家"笑天昨天没在"

---

## ✅ W6 round-1 closed

W6 round-2 任务: **1 处** (Q1 npcs.md §11 实习生小张 register, 30 min)。

完成后 W6 stand down。

S6-S12 outline 是 future bonus task, 不在本 round 范围。如启 S6 outline, reuse 同 generic-handoff.md 参数 N=6, 等 S6 trigger 比 S5 急 (S5 ship 后 next pick S6 / S7 / etc per timeline)。

---

## 启动 S5 ink writer 的条件

1. ✅ S5 outline (本 W6 round-1 通过) — done
2. ⏳ S4 ink writer ship (E13-16 in flight) — S5 接续 S4 finale, 需 S4 先完成
3. **S5 ink writer dispatch 等 S4 ink ship 后再启** (~2-3 天后) — S5 ink writer 接续 S4 finale 5 路径

---

## 你 (user) 下一步该做的

1. **forward 本 reply 给 W6 session** → W6 round-2 register 实习生小张 to npcs.md
2. (parallel) S4 ink writer (B prompt) + W3 reuse weekly_tradeoff (上 message 给的 prompt) 继续跑
3. S5 ink writer 等 S4 ship 后再 dispatch

---

## END
