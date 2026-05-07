# W6 提交报告 — Season 4 outline (N = 4)

> Status: Round 1 提交，等 GM verdict
> Author: W6 分身 CC session
> Last Updated: 2026-05-07

---

## 输出

- `design/vertical-slice/season-4-arc.md` (584 行)

## Section 完成度

| § | Section | 状态 |
|---|---|---|
| §1 | 主题 + 笑/泪曲线 | ✓ |
| §2 | 4 archetype reference + david_score 累积规则 + promotion_candidate_count setup | ✓ |
| §3 | Per-NPC arc tables (10 NPC + 食堂阿姨 ambient × 4 episodes) | ✓ |
| §4 | Cross-NPC scenes matrix (9 个跨 4 集) | ✓ |
| §5 | Per-episode beat sheet (E13-E16) | ✓ |
| §6 | S4 Finale 5 路径表 + KPI Review 浮层文案（路径 A specific）| ✓ |
| §7 | Quality Rubric reference + S4 specific 7 条 | ✓ |
| §8 | S3→S4 Migration note + promotion_candidate_count 阈值 Open Q | ✓ |
| §9 | 给 ink writer 的 use 说明 | ✓ |
| §10 | 设计自检 | ✓ |
| §11 | ❌ 不能做的事 | ✓ |
| §12 | 下一步 | ✓ |

## NPC 在 S4 出场 / 退场总结

- **David** (S1-S6 active, S4 主线 anchor): 4 集 4 个 quiet sign 累积 (baseline 抬高 / 朋友圈 0 + 茶水间不耐烦升级 / 晨会被打断 / 摔保温杯)
- **Lisa** (S1-S3 主线 已 finale, S4 = 5 路径残影): 路径 A 微信 4 句模式 / 路径 B 朋友圈 mention / 路径 C 屏蔽态 / 路径 D 笑天不知她哪天走的 / 路径 E Vivian 告知
- **王总监** (S1-S9 active, S4 puppet 形态 layer 4 = 打高尔夫): cue 笑天频率 +2/集 (路径 A) / E15 周四晚打高尔夫 / E16 finale 路径 A promotion 预热
- **Zoe** (S1-S12 active): 季度评估 setup (E13 偷听 / E15 协作反馈 ask / E16 finale 路径 A 私聊 + 协作反馈附件)
- **李阿姨** (S1-S8 active): 静默见证 David 燃尽前兆 (E13 先擦 Lisa 原工位 + E15 升级语 "卷王每年走一茬" + E16 经过摔杯 David 速度慢 0.5 秒)
- **Vivian** (scattered): 苹果 → 苹果 → 苹果 → 草莓 (融资周 E16 ironic mirror)
- **IT 小马** (scattered): 工单 v3 → 茶水间偶遇 / E16 仍故障 + 通知升级"零件已到 + 厂家定档"
- **老周** (scattered, 完全沉默): 4 集 0 句话 (E13 经过 Lisa 原工位速度慢 0.5 秒是唯一非沉默动作)
- **妈妈** (周日 8:30): 清明 mention "上坟" 流程性词 (E13) + 替笑天跟亲戚解释 (E14) + S4 finale "想去看你" spiral 起步 (E16)
- **林姐** (路径 A E15 茶水间偶遇 1 次, 0 句话): series 第二次 visual 接触
- **食堂阿姨** (ambient): E16 周一抬头看 0.5 秒 — series 唯一一次 visible recognition
- **新人 张磊 (路径 A) / 赵丽 (路径 B-E)**: S4 第一次出场的 minor NPC (ambient flavor, 不正式注册 — 待 GM 决定)

## 跨 season 一致性 check

- 跟 series-structure.md §2 S4 主题 "David 燃尽前兆": ✓
- 跟 series-structure.md §2 S4 finale "David 第一次失态 (晨会被王总监打断 / 茶水间摔保温杯)": ✓ (E16 周三 + E16 周日双重显形)
- 跟 npcs.md §2 David 长弧光 S4 燃尽前兆 seeds: ✓ (晨会被打断 / 茶水间摔保温杯 / 朋友圈频率突降全部实例化)
- 跟 npcs.md §3 王总监 S4-S6 "他自己也开始焦虑" + "笑天偶尔看到他自己工位灯到深夜还亮": ✓ (E15 周四晚打高尔夫 = puppet 形态 layer 4 升级)
- 跟 npcs.md §10 林姐 "S5+ 茶水间偶遇——林姐对笑天点头但不主动说话": ✓ 提前到 S4 E15 (路径 A 玩家)
- 跟 series-structure.md §4.5 Event S10.X promotion 警告 setup (`promotion_candidate_count` 累积): ✓ S4 末 = 1 (S10 触发条件 ≥ 2，留给 S5/S6/S7 继续累积)
- 跟 series-structure.md §4.5 v1.2 seasonal events placeholder "4 月清明节调休": ✓ 嵌入 E14 周一
- 跟 protagonist.md §9 S4-S6 弧光 "David 离职那天主角内心：'我以为我会笑。但我没有。' 主角接收 David 留下的部分工作": ✓ S4 是 setup 阶段，路径 A 玩家 promotion warning 预热 = "成为下一个 David"
- 跟 S3 finale §6 5 路径 S4 影响列: ✓ 全 5 路径在 §3.2 Lisa 表 + §6 S4 finale 5 路径表落实
- 跟 S3 outline cliffhanger: ✓ E13 周一兑现 (路径 A 张磊 / B-E 工位空 + 周三新人 / D 笑天仍病假 / E Vivian 告知)
- 跟 tone-bible.md v2 5 原则: ✓ 各 NPC 行为为自己 + 主语翻转 + 写真不写好 + 朋友圈测试 + 主角观察者位置

## 设计 highlight (给 GM 注意的关键创新点)

1. **promotion warning 预热 = backdoor signal 设计**：S4 finale 路径 A 触发 promotion_candidate_count = 1，但**不直接 expose 给玩家**——通过 3 个 backdoor signal 显形（王总监单独 cue "你做得不错" + Zoe 协作反馈附件 + 系统注释"高潜力人才储备池"）。Attentive 玩家可推断，casual 玩家会在 S5-S10 慢慢意识到。这是 anti-Pillar 1 渐进升级而非突兀 reveal

2. **王总监 puppet 形态 3 集递进**：S2 工位灯还亮（形态 1 = 在加班执行）→ S3 打电话（形态 2 = 在传达命令）→ **S4 打高尔夫（形态 3 = escape）**。3 集 3 形态显形他的 vulnerability layer 升级

3. **David 卷王 baseline spiral**：S1 周五 4 点写下周计划 → S2 周二抢功 + 4 点已写 → S3 周日就交周报 → **S4 周末全在公司 + 周一 8:30 已到**。每季 baseline 又抬高一个台阶——直到 E16 他自己撑不住

4. **Lisa motif 5 路径 ambient presence**：路径 A 微信 4 句模式 (笑天问候 / Lisa 回 / 笑天回 / Lisa 收尾)、路径 B 朋友圈截图保存、路径 C 屏蔽态笑天点开 1 次、路径 D 笑天看对话框最后一条 S3 周日 "不管怎样谢谢你"、路径 E silence。**5 套不同质感**让 5 路径的 emotional 重量差异化

5. **Pillar 4 ironic mirror 在 E16 finale 高峰**：草莓周 (融资过会) + 季度评估周 + David 摔保温杯 同周触发——老板的世界 / HR 的世界 / David 的世界 visually 平行 universe

6. **食堂阿姨 series 内唯一一次 visible recognition** (E16 周一抬头看 0.5 秒 + "今天早")：跟 npcs.md §5.5 "她不会主动说话——只在玩家选择道谢时笑一下不说话" 保持兼容（她仍不主动），但通过抬头 + 简短 acknowledge 显示 series 内她**记住**笑天

## Open Questions

### Q1. S4 末 promotion_candidate_count 阈值：130 vs 150

handoff §5 没明确 S4 KPI 累积阈值跟 promotion_candidate_count 的关系。S4 路径 A threshold 涨到 110-118 区间，玩家若持续高表现：
- 选项 A：S4 月末 KPI ≥ 130 = promotion_candidate_count += 1（更宽松，S4 末玩家就 = 1）
- 选项 B：S4 月末 KPI ≥ 150 = promotion_candidate_count += 1（更严格，S4 末多数玩家 = 0，留给 S5/S6/S7 累积）

我假设了**选项 A**（每月 KPI ≥ 130 = +1），所以 S4 末路径 A = 1，S5/S6/S7 各 += 1，S10 警告 setup 触发条件 ≥ 2 在 S5 末就 active 了。但 series-structure §4.5 spec 说 "每月 KPI > 150"——这跟我假设矛盾。

**GM 决定**：是 130 还是 150？如果是 150，S4 outline §6 "路径 A → promotion_candidate_count += 1" 需改成 "如果月末 KPI ≥ 150 才 += 1，否则维持 0"。

### Q2. 张磊 / 赵丽 (S4 新人) 是否需 npcs.md 注册？

handoff §5 说 "不要引入 npcs.md 未注册的新 NPC"。但 S3 finale 5 路径决定 S4 第 1 集就有"新人入职 Lisa 工位"，路径 A 是 24 岁男生（per S3 outline §6 cliffhanger），路径 B-E 是 25 岁女生（我假设的）。

我的处理：**张磊 / 赵丽 = ambient flavor 不正式注册**，跟食堂阿姨同档（npcs.md §5.5 也不正式注册）。这是基于以下考虑：
- S5 主题 = "新人入场"——S5 实习生才是真正的新角色
- S4 张磊 / 赵丽是 Lisa 工位接任者，他们的 series 出场频率 < 1 次/集
- 他们在 S5+ 不会有显著弧光（实习生小张才会被笑天叫"陈哥"）

**GM 决定**：是否需要补注册（npcs.md §11/§12 加 张磊 / 赵丽）？如果需要，GM 决定姓名 + character note + visual 锚（per npcs.md 龙套 NPC 格式）。

### Q3. S4 Lisa 微信"4 句模式"是否过频/过淡？

路径 A 玩家 S4 每集 1 次 Lisa 微信，每次"笑天问候 / Lisa 回 / 笑天回 / Lisa 收尾"4 句不超过——**这是 deliberate restraint**，Lisa 转岗后她的 attention budget 应该投到新部门 + 林姐，不是 ex 同事笑天。

但 4 集 4 次微信总共 16 句话——可能比 S3 末 lisa_score ≥ +25 玩家期待的"亲密度"低。GM 评估这是否符合 npcs.md §1 "S5+ 偶尔回办公室办手续" 的 spirit？

我的判断：**符合**（"偶尔"对应 S4 每集 1 次，4 句对应"短" 而非"亲密"）。但 GM 可调整频率（例如每 2 集 1 次微信，让"亲密度"显得更冷）。

### Q4. 路径 E "Vivian 告知" 后笑天 S4 整季对 Lisa 的 attention 是否过低？

路径 E 玩家 S4 全季：E13 Vivian 告知 + E16 silence + 笑天手动从置顶取消 Lisa 微信对话框。**整季对 Lisa 的 mention < 5 句** total。

这跟"路径 E = Pillar 3 极致 = 你在场但你不在" 的 spirit 一致。但 GM 评估是否需要至少 1 次 Lisa 朋友圈 mention（即使笑天不点开也偶然推送）？

我的判断：**不需要**——路径 E 玩家 S2-S3 已 mute Lisa，她也 mute 笑天。S4 应该 reflect 这种双向 silence。但 GM 可决定是否补 1 处 ambient mention（如 E14 周二群里 "@张磊 欢迎入职" 暗示 Lisa 工位状态，路径 E 笑天看到但没反应）。

### Q5. 清明 mention "你爸坟上" 是否 too much？

E13 周日妈妈视频"清明你姨他们要去你爸坟上"是 series 内**第一次** mention 笑天爸爸。npcs.md §9 character note 说"绝不在剧本里 expose 爸爸 8 年前去世"。

我的处理：**mention "上坟"流程性词是 character note compatible**，因为：
- "上坟" 是清明节标准流程，不 expose "8 年前去世" emotional anchor
- 笑天回应是"回 / 不回 / 再说"——3 选 1 都不 expose 爸爸已逝（即使选"回"，剧本不写他实际跟妈妈聊爸爸的事）
- 妈妈说"你姨他们要去"是替别人 mention 而非她直接 mention "你爸"——更间接

但 GM 可能觉得这违反 strict 解读"绝不提爸爸"。**GM 决定**：是否可以 mention "上坟" 流程性词，还是改为 "清明你姨他们要去老家"（不 mention 上坟）？如果改，E14 周日"妈替我跟亲戚解释" 仍 work（解释笑天不回老家，不 mention 坟）。

### Q6. E15 林姐茶水间偶遇是否 too short？

handoff §5 说 "林姐路径 B-E 完全不出场" — 我遵守了。但 E15 路径 A 茶水间偶遇仅 1 个 stitch（点头 + 0.3 秒看笑天工位 + 笑天内心独白），可能体量 < S3 finale 林姐 First Impression 那 stitch。

我的判断：**deliberate restraint**——林姐 S4 是 callback，不是 First Impression。她已经在 S3 finale 立过 visual + 口头禅，S4 只需 reaffirm "她不要笑天" 就够了。但 GM 可决定是否 expand（例如加 1 句 "笑天哦" 林姐主动 acknowledge——但这违反 npcs.md §10 "她从不主动跟笑天聊"）。

我倾向**保持 0 句话**——deliberate restraint 比 expand 更符合 Pillar 4。

---

## bonus S5 outline

handoff §10 鼓励 time permitting 写 S5。本 session 已写 ~584 行 S4 + 1 页 progress note，**stand down 等 GM round-1 verdict**。

如 GM review 通过 + 仍有需求，**下一波可启动 S5 outline**（主题 = "新人入场" + 实习生入职 → 笑天首次被叫"陈哥"，per series-structure.md §2 S5 row）。

---

## stand down

W6 round-1 提交完成。等 GM verdict on:
1. 整体 outline 是否符合 handoff §5 验收标准
2. Open Questions Q1-Q6 决策
3. 是否启动 bonus S5 outline (or 下一个分身)
