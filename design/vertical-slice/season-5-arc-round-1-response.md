# W6 提交报告 — Season 5 outline (N = 5)

> Status: Round 1 提交，等 GM verdict
> Author: W6 分身 CC session (S5 round-1)
> Last Updated: 2026-05-07

---

## 输出

- `design/vertical-slice/season-5-arc.md` (634 行)

## Section 完成度

| § | Section | 状态 |
|---|---|---|
| §1 | 主题 + 笑/泪曲线 | ✓ |
| §2 | 4 archetype reference + intern_score 累积规则 + promotion_candidate_count 阈值 (≥150 per GM Q1) | ✓ |
| §3 | Per-NPC arc tables (10 NPC + 食堂阿姨 + 实习生小张 + 张磊 ambient × 4 episodes) | ✓ |
| §4 | Cross-NPC scenes matrix (9+ 个跨 4 集) | ✓ |
| §5 | Per-episode beat sheet (E17-E20) | ✓ |
| §6 | S5 Finale 5 路径表 + KPI Review 浮层文案（路径 A specific + Q2 mentor 反馈附件）| ✓ |
| §7 | Quality Rubric reference + S5 specific 8 条 | ✓ |
| §8 | S4→S5 Migration note + GM Q1-Q6 carry-over | ✓ |
| §9 | 给 ink writer 的 use 说明 | ✓ |
| §10 | 设计自检 | ✓ |
| §11 | ❌ 不能做的事 | ✓ |
| §12 | 下一步 | ✓ |

## NPC 在 S5 出场 / 退场总结

- **实习生小张** (**S5 第一次出场**, **新 NPC candidate** 待 GM 决定 npcs.md 注册): E20 周一入职, 4 archetype 在 1 集压缩 (A 陈哥 / B 微信约咖啡 / C 桌面便利贴"早日转正" / D 朋友圈"完美收官") + intern_score 起步
- **David** (S1-S6 active, S5 = quiet sign 5+6+7+8 累积): 病假 (E17 路径 B) / 不举手 (E18) / 周报 1 页 (E19) / 没起来打招呼 (E20)
- **王总监** (S1-S9 active, S5 puppet 形态 layer 5 = 自己工位摆 KPI 表 focusing): cue 笑天频率 +2/集 (路径 A) + E19 周三晚 layer 5 视觉高潮 + E20 周一介绍实习生时 "陈天" 介绍 running gag 复用
- **Zoe** (S1-S12 active): 季度评估后流程化稳定期 + E19 群发实习生入职 + E20 主持欢迎仪式 + 路径 A E19 私聊"mentor 反馈"
- **李阿姨** (S1-S8 active): E18 假期后 "小伙子假期玩好了" (S5 第一次 ≥ 0 句对话) + E19 升级语 "卷王每年走一茬，新人每月来一茬" + E20 周三擦实习生工位很慢
- **Vivian** (scattered): 苹果 → 苹果 → 草莓 → 苹果 (融资二轮 D 轮 closing) + E20 工位贴 "高潜力人才储备池更新" 海报 (路径 A 玩家 0.5 秒怔住)
- **IT 小马** (scattered): E19 周五**首次主动跟笑天 dialog** "那个咖啡机厂家说下个月修" (series 第一次)
- **老周** (scattered, 完全沉默): S5 0 句话 + E17 抬头 0.3 秒 + E19 桌面多 1 杯 (4 杯) — visible signal "他注意到笑天 status 变了"
- **妈妈** (周日 8:30): E18 北戴河"你爸 30 年前去那玩过" (**第二次 mention 爸爸**, character note compatible 历史 mention) + E20 finale "想去看你" spiral 第 4 次 stabilize
- **林姐** (S5 路径 A E19 茶水间偶遇 1 次): 0 句话 + 点头停顿 0.5 秒 (S4 E15 升级) — series 第三次 visual 接触
- **食堂阿姨** (ambient): E20 周三 笑天 vs 实习生 差异化对待 — quiet milestone
- **张磊** (S4 新人 ambient, 不正式注册): 路径 A E18 第一次叫笑天"陈哥" — secondary setup for E20 anchor
- **赵丽** (S4 新人 ambient, 不正式注册): 路径 B-E standard

## 跨 season 一致性 check

- 跟 series-structure.md §2 S5 主题 "新人入场": ✓
- 跟 series-structure.md §2 S5 finale "E20 实习生入职第 1 周 → 叫笑天'陈哥'": ✓ (周一 9:00 入职欢迎仪式 + 9:15 笑天 internal "我成了 David")
- 跟 series-structure.md §4.5 v1.2 seasonal events placeholder "5 月劳动节": ✓ 嵌入 E18 (放 5 天补 7 天 + 笑天去北戴河 + 周二假期前一天晨会)
- 跟 series-structure.md §4.5 Event S10.X promotion warning setup (`promotion_candidate_count` 累积): ✓ 阈值 ≥ 150 per GM Q1 答 + S4 末若 = 1 + S5 末 = 1 = **2** (路径 A 玩家 reach S10.X 触发条件, 但 S10 才 active)
- 跟 series-structure.md §5 Endgame Variant D ("陈哥"微信 trigger = `intern_score ≥ +10`): ✓ S5 引入 intern_score counter, 起步 0~+12, 跨 S5+ 累积目标 ≥ 10
- 跟 npcs.md §2 David 长弧光 S4-S5 quiet sign + 燃尽前兆继续: ✓ (病假 / 不举手 / 周报 1 页 / 没起来打招呼)
- 跟 npcs.md §3 王总监 puppet 形态 layer 序列: ✓ S2(layer 1=工位灯还亮) → S3(layer 2=打电话) → S4(layer 3=打高尔夫) → **S5(layer 4=自己工位摆 KPI 表 focusing = panic)** — 4 集 4 形态递进
- 跟 npcs.md §4 Zoe S5+ "升级高级 HR" 准备期: ✓ S5 季度评估后流程化稳定期, S6+ 才正式升级
- 跟 npcs.md §5 李阿姨 S5 升级语 "卷王每年走一茬，新人每月来一茬": ✓ E19 周五傍晚
- 跟 npcs.md §8 老周 S2-S5 0 句话规则: ✓ S5 0 句话 (E17 抬头 0.3 秒 + E19 桌面多 1 杯 是 visible signal 但仍 0 dialog)
- 跟 npcs.md §9 妈妈 spiral pattern + character note "不在剧本里 expose 爸爸 8 年前去世": ✓ E18 "你爸 30 年前去那玩过" = 历史 mention (30 年前 = 笑天爸爸还活着的时间), 不 expose emotional anchor
- 跟 npcs.md §10 林姐 "对笑天 0 主动 dialog 跨整 series" + S5+ 茶水间偶遇点头不主动说话: ✓ S5 E19 升级停顿 0.5 秒 但仍 0 dialog
- 跟 protagonist.md §9 S5-S7 "笑天第一次被叫'陈哥'" 内心独白 verbatim "_陈哥。不是天哥。是陈哥。我成了 David。_": ✓ E20 周一入职第 1 天 verbatim 保留
- 跟 protagonist.md §7 "小确幸"清单 archetype trigger: ✓ E18 北戴河 = 笑天 series 内第一次离开北京, 5 月劳动节 5 天连休
- 跟 S4 round-1 reply Q1 (阈值 ≥ 150): ✓ S5 §6 路径 A 触发条件 = "S5 月末 KPI ≥ 150 才 += 1"
- 跟 S4 round-1 reply Q2 (张磊不注册 ambient): ✓ §3.12 ambient flavor 持续 + 张磊 E18 "陈哥" secondary setup
- 跟 S4 round-1 reply Q5 strict constraint (上坟 mention OK with constraint): ✓ S5 E18 "你爸 30 年前去那玩过" 是历史 mention, 不 expose 8 年前去世 anchor + ink writer 注意事项已 expand 在 §9
- 跟 S4 round-1 reply Q6 (林姐 0 句话 keep): ✓ S5 E19 仍 0 dialog 但 visual 升级 (停顿 0.5 秒)
- 跟 S4 outline §6 5 路径 S5-S6 影响列: ✓ 全 5 路径在 §3.2 David 表 + §3.12 张磊表 + §6 S5 finale 5 路径表落实
- 跟 S4 outline cliffhanger: ✓ E17 周一兑现 (路径 A 张磊周末加班 / B David 病假 / C David 一起吃 / D 笑天仍病假 / E standard)
- 跟 tone-bible.md v2 5 原则: ✓ 各 NPC 行为为自己 + 主语翻转 + 写真不写好 + 朋友圈测试 + 主角观察者位置

## 设计 highlight (给 GM 注意的关键创新点)

1. **实习生小张 4 archetype 1 集压缩 (E20)**：S1/S2/S3 NPC 4 archetype 跨 4 集渐进，S5 实习生 4 archetype 必须在 E20 1 集压缩——这是 deliberate 设计：实习生入职第 1 周 = 整 series 的 emotional anchor（"陈哥"扎点），他要 fresh face entry + 累积 4 archetype 在 1 集让玩家瞬间识别"另一个 Lisa S1"

2. **笑天-老周-实习生 三代镜像**：老周 (48) = 笑天 (32) 的 10+ 年后 / 实习生小张 (22) = 笑天 (32) 的 10 年前。S5 是 series 内**第一次三代同框**（E20 周一实习生入职会议室王总监介绍时，老周在背景不抬头 + 笑天 in middle + 实习生在前）。这是 Pillar 3 的人形 visualization：你正在变成你曾经讨厌的人

3. **张磊 + 实习生小张 双"陈哥"setup-payoff**：路径 A 张磊 E18 第一次叫笑天"陈哥" → E20 实习生小张 周一也叫"陈哥" — secondary setup 让 anchor 显得**已经发生过**，笑天没意识到他已经在 transition

4. **王总监 puppet 形态 4 集 4 形态递进**：S2(layer 1=工位灯还亮=加班执行) → S3(layer 2=打电话=传达命令) → S4(layer 3=打高尔夫=escape) → S5(layer 4=自己工位摆 KPI 表 focusing=panic)。**escape 之后是 panic** — 王总监自己的弧光在每个 season 加深一层

5. **5 月劳动节 + 北戴河小确幸**：series 内笑天**第一次离开北京**。Pillar 4 visible 极致："不多。但算我赢一次。"（per protagonist.md §4）— 5 天连休 = 笑天 8 年来第一次出游，但他去了北戴河（不是日本，预算限制）。E18 周日妈妈视频选 B "我去了北戴河" 触发"你爸 30 年前去那玩过" = **第二次 character note compatible 历史 mention 爸爸**

6. **食堂阿姨 quiet milestone E20**：笑天 vs 实习生 差异化对待 (多打半勺 vs standard) — 仍 0 句话但 visible signal "她记住笑天了" (npcs.md §5.5 '她不知道笑天名字。她只记得每周三都来 / 总点西红柿炒蛋' 的 visible payoff)

7. **路径 A reward 累积升级**：S4 (Q1 协作反馈附件) → S5 (Q2 mentor 反馈附件 + "high potential talent pool final round") — HR 流程模板永远 escalate, 每个 milestone 都是同一个 PUA-speak 的 escalating 版本

## Open Questions

### Q1. 实习生小张是否需 npcs.md 注册？

S4 round-1 reply Q2 说"张磊真的开始有 arc 时再 retro-register"。**实习生小张 vs 张磊 不同**：
- 张磊 = Lisa 工位接任者, 跨 S4-S12 出场频率 < 1/集, 没 named arc
- **实习生小张 = S5 主线 anchor + Endgame Variant D 触发 NPC** (per series-structure.md §5 "微信新消息：实习生小张 / '陈哥新年快乐！'") — **他在 series-structure.md §5 已被 named** + 有 score 系统 (intern_score)
- 我已在 §3.1 写出完整 character note + 视觉锚 + 口头禅 + 内在驱动 (类比 npcs.md 龙套 NPC 格式)

**GM 决定**：是否需要 retro-register 实习生小张 到 npcs.md 作为 #11 NPC？

我的 recommendation：**注册**。理由:
- S5 finale + Endgame Variant D 都依赖他的 score 累积
- 他跟笑天-老周三代镜像形成 deliberate visual 设计 (跟 林姐 的 "另一种活法" 同等设计权重)
- 不注册的 risk: 未来 ink writer 不知道他的口头禅 / 视觉锚 baseline, 可能写得 inconsistent

如 GM 决定注册, 建议 W6 round-2 task = 把 §3.1 character note 移植到 npcs.md §11 (新增 section)。如 keep ambient, S5 outline §3.1 仍 stands as canonical reference (类似食堂阿姨 §5.5 ambient flavor 的 inline character note)。

### Q2. 张磊 E18 第一次叫"陈哥" 是否过早 break S5 finale anchor？

S5 finale anchor = E20 周一实习生小张 第一次叫笑天"陈哥"。**但路径 A E18 张磊已经叫"陈哥"** — 这是 setup-payoff 设计 (让 E20 anchor 显得"已经发生过 但 笑天没意识到")。

但 risk: 玩家在 E18 就听到"陈哥"称呼可能 dilute E20 finale 的扎点。

我的 judgment：**保留 E18 张磊"陈哥"setup**。理由:
- 路径 A 玩家 E20 finale 扎点 = 笑天 internal "我成了 David" (verbatim)，**不是** "陈哥"称呼本身
- E18 张磊"陈哥" = visible signal 给玩家 (你已经在 transition 但你没意识到)，反而强化 E20 笑天的 internal recognition 扎点 (他终于意识到了)
- 路径 B-E 玩家 E18 不出现这个"陈哥"setup（张磊 ambient mode），所以他们 E20 是 cold "陈哥"——5 路径差异化合理

**GM 决定**：保留还是去掉 E18 张磊"陈哥"？

### Q3. E18 5 天连休 stitch 体量是否过大？

E18 跨 周三-周日 5 天连休 + 北戴河 stitch sequence，可能让 E18 ink 文件体量超过 standard 600-700 行。

我已在 §9 注明 E18 体量 ~700-800 行。但实际 ink writer 写时可能更长 (北戴河 4 stitch + 高铁 + 沙滩 + 海鲜 + 妈妈视频 + 周日回工位浇绿萝)。

**GM 决定**：是否需要简化 E18 北戴河体量 (e.g. 周三-周日 1-2 个 stitch summary 而非 daily breakdown)？

我的 judgment：**保留 daily breakdown**。理由:
- E18 是 series 内笑天第一次离开北京——fresh visual + 小确幸 anchor 应该 expand 而非压缩
- 5 天连休 = 5 个 stitch (周三高铁/周四海边/周五小吃/周六回京/周日妈妈视频) 是 minimal viable expansion
- 笑泪曲线 6:4 偏笑要求 E18 体量足够给小确幸呼吸空间

但 GM 可决定是否压缩到 3 个 stitch (e.g. 出发 / 旅程中 / 回京)。

### Q4. 妈妈 mention 爸爸"30 年前去过北戴河" 是否仍在 character note compatible 范围？

S4 Q5 strict constraint 锁了"上坟"是清明流程性词。S5 E18 "你爸 30 年前去那玩过" — **30 年前 = 笑天爸爸还活着的时间** (笑天 32 岁, 30 年前他 2 岁, 爸爸还活着)。所以这是**生前历史 mention**, 不 expose "8 年前去世" emotional anchor。

但 GM 可能觉得这违反 strict 解读"绝不提爸爸"。**GM 决定**：是否可以？

我的 judgment：**OK**。理由:
- 30 年前 historical mention 是生前积极回忆 ("玩过") 而非缅怀 ("以前的事了")
- 跟 S4 Q5 "上坟"是 process 词, 这是 historical activity (玩过), 都不 expose emotional anchor
- 妈妈 character note (npcs.md §9) 说 "绝不在剧本里提爸爸"——但这条规则的 spirit 是不 expose 爸爸去世 emotional anchor，**不是** 字面禁止 mention "你爸"
- 如果 strict reading 是字面禁止, 则 S4 E13 "你姨他们要去你爸坟上" 早已违反 (那条已 GM Q5 approve)

但 GM 可改成 "**你爸 30 年前去那边玩过**" → "**我以前跟你姨去那边玩过**" (替换 actor 为妈妈本人)，effects 一致 (历史 mention) 但更 conservative。

### Q5. 路径 A E20 周一介绍工位 "这个是陈天啊" 王总监 running gag 是否过 callback？

**Running gag**：王总监 5 个 season 一直叫不准笑天名字 ("小笑啊…陈天啊…差不多差不多")。S5 E20 周一介绍给实习生时也叫不准 ("这个是陈天啊")。

但 risk: 实习生小张随后 instinctively 叫 "陈哥" — 这是因为王总监给他听了"陈天" 名字, 他自然就用"陈+哥" 称呼大他 10 岁的同事。**所以 实习生 用"陈哥" 而不是"天哥"是 王总监 running gag 的 direct consequence**。

我的 judgment：**保留**。理由:
- 这是 running gag 的 narrative payoff——5 个 season 累积的"叫不准名字" 现在影响了实习生的称呼习惯，因此影响了笑天的 voice transition
- protagonist.md §9 verbatim 内心独白说 "_陈哥。不是天哥。是陈哥。_"——天哥 vs 陈哥 的对比正是 running gag 的 anchor (David 叫 "天哥" 暗讽 / 实习生 叫"陈哥" 因为听王总监说"陈天")
- 不保留这条会让 实习生 "陈哥"称呼显得 unmotivated

**GM 决定**：保留还是单独让实习生用"陈哥"称呼 (independent of 王总监 running gag)？

### Q6. 是否需要在 §6 路径 D 加 "笑天 周三装病实习生晚 2 天才叫陈哥" 的 specific stitch？

S5 outline §6 路径 D 描述 "实习生第 1 周 见不到笑天 2 天 — 他对你的'陈哥' 印象比 路径 A/B/C 玩家弱"。但 Detailed beat sheet (§5) E20 周三笑天装病但**周四回来**，所以实习生 周四 / 周五 仍能见到笑天 4-5 次 (而非 0 次)。

我可能 over-stated "见不到 2 天"——实际是"周三那天 + 周四上午没见到, 周四下午开始见到"。

**GM 决定**：路径 D 的"陈哥"印象 弱化是否仍 valid (即使笑天周四上午回来)？

我的 judgment：**仍 valid**。理由:
- 实习生入职第 1 周, 周一 + 周二 = 2 天接触 笑天 = baseline. 路径 D 玩家 缺周三 1 天 = 接触少 30% (从 5 天 → 4 天)
- 实习生 internal model 中 "陈哥" 是 周一介绍 + 周二微信约咖啡 + 周四便利贴见到 + 周日朋友圈 standard cycle
- 路径 D 玩家 的实习生 周四见到笑天时 笑天可能 still 装病余热 (没精神 mentor) → intern_score 累积比路径 A 慢

但 GM 可决定是否需要在 §5 E20 周三 stitch 里 explicit 写 "笑天装病当天实习生小张 主动找笑天 但被告知 笑天请假, 实习生 在自己工位 hands-on 没人指导"——这样 5 路径 D 的 setup 更 visible。

我的 recommendation：**§5 E20 周三 stitch 已有 inline mention** ("路径 D 玩家此选：笑天再装病 1 次没去食堂") — 已够。但 GM 可决定是否 expand。

---

## bonus S6 outline

handoff §10 鼓励 time permitting 写 N+1 outline。本 session 已写 S4 (584 行) + S5 (634 行) + 2 个 progress note，**stand down 等 GM round-1 verdict**。

如 GM review 通过 + 仍有需求，**下一波可启动 S6 outline**（主题 = "David 燃尽离职 finale" + 朋友圈"开启人生新篇章"，per series-structure.md §2 S6 row + npcs.md §2 David S6 finale）。

S6 outline 的 special considerations:
- David 真正离职 finale (E24) — 比 Lisa S3 finale 更 visible (David S1-S6 = 6 个 season 累积的 anchor)
- David 离职 朋友圈"开启人生新篇章" + 微信群头像变灰 (per npcs.md §2 future arc seed)
- 笑天可能"以为我会笑。但我没有。" (per protagonist.md §9 S4-S6 弧光) — voice transition 续集
- 路径 C 玩家 David 邀请笑天去他家吃饭 (S5 cliffhanger 兑现) → series 内 David 第一次 personal scene
- 王总监 puppet 形态 layer 5 (panic) → S6 layer 6 candidate (?)
- 实习生小张 S6 起 1 个完整 season 4 archetype (E21-E24) — 他第一次有 season-level arc

---

## stand down

W6 S5 round-1 提交完成。等 GM verdict on:
1. 整体 outline 是否符合 handoff §5 验收标准
2. Open Questions Q1-Q6 决策（特别是 Q1 实习生小张是否 npcs.md 注册）
3. 是否启动 bonus S6 outline (or 下一个分身)
