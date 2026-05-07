# Daily Choices Generation Handoff Brief

> Status: 第 2 版（**引擎切到 Ink，从 markdown 改为 .ink 文件**）
> Author: Game Designer (原 CC session)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——一个新启动的 Claude Code session，承接全部 design context
>
> **进度状态（2026-05-05 by 分身 CC session）**：
> - **内容设计**：60 / 60 ✓ 完成（in `daily-choices.md` markdown 形式）
> - **.ink 转译**：0 / 57 ⏳ 待办（v1→v2 pivot 在分身工作中途发生，分身先按 v1 把内容写成 markdown）
> - 详见本文件 §11 进度回写

---

## 0. 你的处境

`survived-episode-x` 是一个反向 KPI 办公室生存模拟（"《活过第 X 集》"），TypeScript + PixiJS + Tauri 栈，design pivot 后变成 AVG（剧情驱动）+ 王权式日常选择平衡。

原 designer 已经写完整套 design slice。**2026-05-05 决定引擎用 Ink** — 业内分支叙事 DSL，inkjs runtime 集成到 TS 壳。剧情 events 用 .ink 文件写，daily choices 也用 .ink。

design slice 关键文件：
- **`daily-choices.md`** — 设计框架（3 属性 + 不可能三角 + 数值规则 + 解锁规则 + 60 choices 分类目标 + 15 个 markdown gold standard 样例）
- **`daily-choices.ink`** — designer 写的 3 个 stitch 样例（**这是你的格式 / voice gold standard**），TODO 标注剩 57 stitch 由你补

**你的任务**：在 `daily-choices.ink` 中补足剩余 **57 个 daily choices stitches**，达到 60 个总数。包括：
- **12 个翻译**：从 `daily-choices.md` §5 中的 15 个 markdown gold standard，翻译成 .ink stitch（其中 #02 / #11 / #14 已是 designer 写的 sample，跳过）
- **45 个新写**：按 daily-choices.md §4 分类目标补足

完成后**人类用户 + 原 designer**（即我，原 session）会 review。不通过打回重干。

---

## 0.5 Ink 速成（看 5 分钟即可上手）

如果你不熟悉 Ink，先**完整读一遍 `design/vertical-slice/daily-choices.ink` 3 个 sample stitches**，然后看以下速查表：

| Ink 语法 | 含义 |
|---|---|
| `// 注释` | 单行注释 |
| `=== choice_name ===` | Daily choice stitch（独立, runtime 按 filter 抽） |
| `# tag: value` | 给 TS runtime 的 hint（category / season_unlock / time_filter / cooldown 等） |
| `* [选项 ≤ 4 字]` | 单次选项 |
| `~ var = expression` | 变量赋值（影响 KPI / money / state / NPC scores） |
| `~ check_state_after_choice()` | 调用 helper function（每 stitch 末必须） |
| `-> DONE` | 结束当前 stitch（runtime 决定下一步） |
| `_text_` | italic — 笑天内心独白 |

**完整 Ink 文档**：https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md（不必现在读，写到不会的语法时查）

---

## 1. 必读 reference（按顺序读完再动笔）

1. **`design/vertical-slice/daily-choices.ink`** — **designer 写的 3 sample stitches**。这是你的 .ink 格式 / 笑天 voice / 笔法 gold standard。**先读这个**
2. **`design/vertical-slice/episode-1.ink`** — designer 写的剧情 .ink 样例（参考 syntax，但本 task 不动 episode-1.ink）
3. **`design/vertical-slice/daily-choices.md`** — **设计框架** + 15 markdown gold standard。15 中的 12 个要被你翻译成 .ink stitch
4. **`design/vertical-slice/protagonist.md`** — 陈笑天的"声音"
5. **`design/vertical-slice/tone-bible.md`** v2 — 5 写作原则
6. **`design/vertical-slice/npcs.md`** v2 — 10 NPC 完整设定（NPC 互动类 stitch 必须 cross-reference）
7. **`design/vertical-slice/series-structure.md`** — 52 集 macro（大决策类 stitch 必须 cross-reference S3+ 解锁）
8. **`design/vertical-slice/season-1-arc.md`** v2 — Season 1 outline（看每集 NPC 出场频率，避免 daily choice 跟剧情 event 撞）

读 reference 时把 `daily-choices.md` 的 §5 那 15 个 markdown gold standard + `daily-choices.ink` 的 3 sample stitches **逐句精读**——它们是 tone / format / 网感 / 笑天 voice 的 quality benchmark。

---

## 2. 任务输出

**1 个 .ink 文件**：

`design/vertical-slice/daily-choices.ink` — **覆盖**现有版本，但**保留**designer 写的所有内容（顶部 header + INCLUDE + 3 sample stitches），**只在 sample 之后追加 57 个新 stitches**。

最终结构：
- 顶部 header 注释块（**保留不动**）
- `INCLUDE episode-1.ink` 行（**保留不动**）
- Sample 1-3（choice_凌晨leader微信 / choice_HR接龙 / choice_35岁体检）（**保留不动**）
- **追加 57 个 stitches**（含 12 翻译 + 45 新写），按类目分组用注释 banner 隔开
- 文件末尾 EOF 注释块（**保留不动，但更新分身 task summary**）

文件总长预计 **~3000-3500 行**（每 stitch ~50-60 行，60 stitch ≈ 3000+ 行 + sample 区 ~200 行）。

**也要更新 `design/vertical-slice/daily-choices.md`**：
- §4 表格的"当前 gold standard"列改成"已 ink 化"列（标 ✓）
- §6 Cross-Reference 矩阵扩展加入新 stitches 的 cross-ref

---

## 3. 任务分解（按类目补足）

| 类目 | 目标 | gold standard 已有 | **你要补** | 触发场景提示 |
|---|---|---|---|---|
| **通勤 / 上下班** | 8 | 1（#01 加班打车报销） | **7** | morning_briefing / after_work。考虑：地铁 / 共享单车 / 走路 / 蹭车 / 早到 / 准点 / 迟到 / 暴雨打车 |
| **午餐 / 午休** | 10 | 0 | **10** | 中午 11:30-13:30。考虑：公司食堂 / 楼下外卖 / 跟 NPC 拼吃 / 健身房 / 趴桌子 / 茶水间偷食 / 不吃 |
| **工作内容** | 12 | 5（#02-#05 + 群里 leader） | **7** | 上午 / 下午任意时间槽。考虑：开会 / 写邮件 / 改 PPT / 审需求 / 交付 deliverable / 评审 / 跨部门对接 / 紧急救火 |
| **小动作 / 小确幸** | 10 | 5（#06-#10） | **5** | 任意时间槽。考虑：摸鱼刷小红书 / 看招聘 app / 改简历 / 给妈妈打钱 / 装病准备 / 装忙打字 / 朋友圈点赞 |
| **NPC 互动** | 10 | 3（#11-#13） | **7** | 任意时间槽，cross-ref NPC location。考虑：跟 Lisa 聊 / 跟 David 寒暄 / 跟 Vivian 八卦 / 跟 IT 小马拉家常 / 跟老周递杯子 / 微信家人 / 微信前同事 |
| **大决策（S3+）** | 5 | 1（#14 体检） | **4** | 任意时间槽，**S3+ 限定**。考虑：搬家近公司 / 接猎头电话 / 投简历 / 请年假 |
| **存活 buffer** | 5 | 0 | **5** | 触发条件解锁。考虑：病倒后处理 / 焦虑后处理 / 钱紧后处理 / 跟 HR 主动谈 / 跟王总监主动谈 |
| **总计** | **60** | **15** | **45** | |

---

## 4. 方法（4 步流程）

### Step 1: 读 reference + 理解 spec

按 §1 顺序读完 6 个 reference。读 `daily-choices.md` 时把 §5 那 15 个 gold standard 逐句精读——你要写的 45 个要达到同等 tone / 网感 / 深度。

### Step 2: 起草（按类目顺序，先简单后复杂）

**推荐顺序**（按写作难度）：

1. **小确幸**（剩 5 个）—— 笑天的小确幸最易写，模式重复（钱小赚 / 状态小升）
2. **小动作**（剩 5 个）—— 摸鱼 / 装忙 / 刷招聘 这类
3. **通勤 / 午餐**（共 17 个）—— 现实场景多，模板可复制
4. **NPC 互动**（剩 7 个）—— 难，需 cross-ref `npcs.md`，每个 NPC 至少要被覆盖到
5. **工作内容**（剩 7 个）—— 难，需要 PUA 话术 + bullshit bingo 真实
6. **大决策**（剩 4 个）—— 最难，每个都是 series-wide 影响，需 cross-ref `series-structure.md`
7. **存活 buffer**（剩 5 个）—— 触发条件特殊，需要懂病倒 / 焦虑 / 钱紧机制

每个 choice 起草用 `daily-choices.ink` 的 .ink stitch 模板（**不是 markdown** — 直接写 .ink）：

```ink
// ----------------------------------------------------------------------------
// Choice N · 名 · 类目
// ----------------------------------------------------------------------------

=== choice_短拼音名 ===
# category: work / commuting / lunch / small_joy / npc / big_decision / survival
# season_unlock: any / S3+ / sick_triggered / promotion_candidate
# time_filter: morning / lunch / afternoon / evening / anytime
# weekday_only / weekend_only / both
# cooldown_episodes: N
# frequency_per_series: N
# npc_focus: lisa / david / wang / zoe / li / vivian / it_xiaoma / lao_zhou / mom (NPC 类必填)

[场景描述 1-2 行]

* [选项 ≤ 4 字]
    [后果 1-2 行 NPC / 物状态]
    ~ kpi = kpi + N
    ~ money = money + N
    ~ state = state + N

* [选项 ≤ 4 字]
    [...]

* [选项 ≤ 4 字]
    [...]

- _笑天内心独白 1-2 句_

~ check_state_after_choice()
-> DONE
```

**严格不要**：
- 不要写 markdown `### 三号标题` 或 `**[A 选项]**` —— Ink 的选项是 `* [选项]`
- 不要漏 `~ check_state_after_choice()`（runtime 没这个调用就不会触发病倒 / 钱紧 / 晋升 GO）
- 不要漏 `-> DONE`（runtime 没这个不知道 stitch 结束）
- 不要漏 `# tag` 元数据（runtime 没这个 filter 就抽不到这 stitch）

### Step 3: 自检（每补 5-10 个 choices）

逐 choice 过一遍 `daily-choices.md` §3 的 6 条写作 checklist：
- [ ] 选项 ≤ 4 字 + 不评价 + 不解释
- [ ] 后果 1-2 行 NPC / 物状态陈述
- [ ] 笑天内心独白 1-2 句，先嘲自己
- [ ] 朋友圈测试通过
- [ ] 影响 1-3 个属性（不能 4 个全）
- [ ] 至少 1 个网感梗

加上 `tone-bible.md` v2 的 5 原则 + 4 工艺细节。

### Step 4: 提交（45 个全补完）

最后一条消息：
- 文件路径 + 总行数
- 7 类目的 choices 数量分布表
- §6 cross-reference 矩阵的扩展确认
- 不确定 / 需要 review 的 choices 列表
- Open questions

---

## 5. 验收标准（designer 怎么判通过）

### 硬性 fail（任意 1 条 = 整批打回）

- 总 stitches < 60 或 > 65（target 是 60）
- 任意类目数量偏离 target ±2 以上（如通勤要 8 个，你写了 5 个或 11 个）
- 任意 stitch 漏 `~ check_state_after_choice()`（破坏 game over 触发链）
- 任意 stitch 漏 `-> DONE`（破坏 runtime 流程控制）
- 任意 stitch 漏关键 # tag（# category / # season_unlock / # time_filter 必有；NPC 类还需 # npc_focus；大决策类还需 # frequency_per_series）
- 任意 stitch 改 designer 写的 sample 1-3 内容
- 任意 stitch 影响 > 3 个属性（违反三角设计）
- 任意 stitch 没有笑天内心独白（`_..._` 块）
- 任意 stitch 选项 > 5 字（违反"克制"原则）
- 任意 stitch 后果出现"评价性"语言（如"David 失望地走了" 违反"不评价"）
- 大决策类未 cross-reference series-structure 的 S3+ 解锁
- 存活 buffer 类未带 conditional unlock（# season_unlock: sick_triggered / promotion_candidate 等）
- 笑天内心独白出现"成长 / 突破 / 完美 / 努力" 基调（违反 tone-bible 原则 1）
- 写 markdown 格式（**必须 .ink**，写在 daily-choices.ink 里）

### 软性 fail（≥ 3 条 = 打回）

- 多个 choice 的"梗"重复（如 3 个 choice 都是"钉钉 999+"）
- NPC 互动类没有覆盖到所有应该出现的 NPC（10 NPC 至少各 1 个）
- 网感梗强度不足（朋友圈测试 ≤ 30 个 choice 通过——target ≥ 45）
- 数值平衡明显偏差（如所有 choice 都是 +KPI / -状态，没有反向 trade-off）
- 笑天的"声音"在某些 choice 听起来像别人（不像 32 岁清醒共谋者）
- 大决策类的 cross-ref 写得含糊（应明确指向哪个 series flag / event）

### 通过标准

- 60 个 choices 齐全
- 类目分布符合 target
- 每个 choice 6 条写作 checklist 全 ✓
- 0 硬性 fail
- ≤ 2 软性 fail（打回时会逐条指出）

---

## 6. ❌ 你不能做的事

| 不能做 | 为什么 |
|---|---|
| 改变 3 属性框架（KPI / 钱 / 状态） | 那要回 `daily-choices.md` §1 改 |
| 改变 game over trigger 数值 | 同上 |
| 引入新 NPC | 10 NPC 在 `npcs.md` 注册 |
| 引入新核心数值（如"焦虑值" 当属性）| 那要回 designer 讨论 |
| 写超过 4 字的选项 | 违反 tone-bible 工艺细节 |
| 写超过 3 行的后果 | 违反"克制" |
| 写主角"励志 / 突破 / 成长" 内心独白 | 违反 tone-bible 原则 1 |
| 让 daily choice 推 series 弧光大决策 | 大决策应该是剧情 event 的活，daily choice 只是 flavor 影响 |
| 把"大决策"类放 S1-S2 触发 | S3+ 才解锁 |
| 把"存活 buffer"类不带触发条件 | 必须 trigger 后才出现在池子里 |

---

## 7. 如果你卡壳了怎么办

如果遇到：
- 某个梗你想不出 punchy 的写法
- 某 NPC 互动 choice 与 npcs.md 设定有冲突
- 某 cross-reference 不知道指向哪
- 某 choice 数值平衡感觉怪

**不要自己脑补**。把这些写在最后提交报告 "Open Questions"。Designer 会回应。

例：
> "我写了一个'跟王总监蹭车回家' 的 NPC 互动 choice，但 npcs.md §3 王总监禁忌里说'不要让王总监有家庭温情刻画'，蹭车回家算不算家庭温情暗示？"

> "存活 buffer 类的'跟王总监主动谈'我写了选项 [汇报近期工作进展]，但这个 choice 的触发条件是'晋升候选 flag = true'——我不确定 'flag = true' 时玩家会不会主动找王总监谈"

---

## 8. 提交格式

```markdown
拆分完成。提交 2 个文件:

1. `design/vertical-slice/daily-choices.ink` (覆盖) — 3247 行 (从 ~250 行扩到 3247 行)
2. `design/vertical-slice/daily-choices.md` (更新 §4 表格 + §6 cross-ref) — 678 行

## 类目分布

| 类目 | 目标 | 实际 |
|---|---|---|
| 通勤 | 8 | 8 ✓ |
| 午餐 | 10 | 10 ✓ |
| 工作内容 | 12 | 12 ✓ |
| 小确幸 | 10 | 10 ✓ |
| NPC 互动 | 10 | 10 ✓ |
| 大决策 | 5 | 5 ✓ |
| 存活 buffer | 5 | 5 ✓ |
| 总计 | 60 | 60 ✓ |

## 自检结果

写作 checklist 6 条 + tone-bible 5 原则 + 4 工艺细节，60 个 choices 全 ✓ except:
- Choice 23 (跟前同事吃饭) — 我不确定后果是不是太长 (3 行)
- Choice 41 (老板让你帮买咖啡) — 我不确定王总监会不会让笑天买咖啡 (npcs.md 没明确)

## NPC 互动覆盖检查

| NPC | 直接 cross-ref choice 数 |
|---|---|
| Lisa | 2 |
| David | 2 |
| 王总监 | 1 |
| Zoe | 3 (含 gold standard) |
| 李阿姨 | 1 |
| Vivian | 1 (含 gold standard) |
| IT 小马 | 1 |
| 老周 | 0 — 这是 deliberate (老周不主动互动)，但我担心覆盖不够
| 妈妈 | 1 (微信家人)
| 林姐 | 0 (S1-S2 不出场)

## Open Questions

- 老周作为"沉默 elder" 是不是不该有 daily choice 直接互动？还是应该补 1 个 (笑天观察老周的小动作)?
- 大决策"投简历" 我写在 S10+ 触发——但 npcs.md 没说笑天什么时候开始想跳槽。需要 cross-ref 哪份 doc?
```

---

## 9. 工作量预估

- 读 reference：60-90 分钟
- 起草 45 个 choices：每个 ~10-15 分钟，共 8-12 小时
- 自检 + 修：每 10 个 ~30 分钟，共 2-3 小时
- 提交报告：30 分钟
- **总计**：~12-16 小时认真工作

不要赶。质量 > 速度。粗制滥造打回重干两次时间更长。

---

## 10. 最后

记住：

> **每个 choice 都是 micro-event，不是 card。**
> **3 属性 enforce 不可能三角——每次 choice 都在做 trade-off。**
> **"有梗有网感" = 朋友圈测试 + 中文职场流行语 + 笑天 voice。**
> **写真，不写好。**

祝你工作顺利。这 60 个 choices 决定玩家在剧情之外的 ~50% 时间是不是好玩。**这部分写好了，整个游戏的 game loop 就闭环了**。

---

## 11. 进度回写（分身 CC session）

> 写于 2026-05-05。本节由**第一次接手的分身 session** 写入，记录工作状态、已完成项、待办项、与 designer 的同步点。

### 11.1 时间线

1. **分身接手时**：handoff 是 v1（markdown only），任务 = 在 `daily-choices.md` §5 追加 45 个 markdown choices 到 60 个总数
2. **分身开工**：按 v1 spec 读完 6 份 reference（protagonist / tone-bible / npcs / series-structure / season-1-arc / daily-choices.md），按推荐顺序起草 45 个 choices 到 `daily-choices.md`
3. **v1→v2 pivot（在分身写作中途）**：designer 把 handoff 升级到 v2——引擎切到 Ink，要求最终输出 `daily-choices.ink`（.ink 格式 stitch），含从 v1 的 15 个 markdown gold standard 翻译 12 个 + 新写 45 个 = 57 个 stitch
4. **分身按 v1 完成 markdown 草稿**：60 / 60 markdown choices 全部完成，已写到 `daily-choices.md`，自检 + §6 cross-ref 扩展 + §8 完成报告全做完
5. **现在的状态**：内容设计 100% 完成，但**格式是 markdown 不是 .ink**——v2 要求的 `daily-choices.ink` 转译还没做

### 11.2 已完成

| 项 | 文件 | 状态 |
|---|---|---|
| 60 个 daily choice 内容设计 | `daily-choices.md` §5（含原 15 gold + 新增 45） | ✓ |
| §4 类目分布表 update（60/60 全 ✓） | `daily-choices.md` §4 | ✓ |
| §6 Cross-Reference 矩阵扩展（11 NPC ref + 5 大决策 series-ref + 5 GO ref）| `daily-choices.md` §6.1-6.3 | ✓ |
| §8 完成报告（NPC 覆盖 / 自检 / Open Questions）| `daily-choices.md` §8 | ✓ |

**`daily-choices.md` 当前 1642 行**，从 605 行扩到 1642 行。

### 11.3 待办（v2 spec 要求但分身按 v1 完成所以未做）

| 项 | 工作量预估 | 备注 |
|---|---|---|
| 57 个 .ink stitch 转译到 `daily-choices.ink` | 每 stitch ~5-10 分钟 × 57 = ~5-9 小时 | 内容已在 `daily-choices.md`，转译只需按 v2 §0.5 + §4 模板套 syntax（# tags + `* [选项]` + `~ var = expr` + `~ check_state_after_choice()` + `-> DONE`） |
| 12 个 markdown gold standard 翻译（其中 3 个 designer 已写 sample）| ↑ 含在内 | designer 写的 #02 凌晨 leader / #11 接龙 / #14 体检 跳过；需翻译的：#01, #03-#10, #12-#13 共 12 个 |
| 45 个新 markdown 翻译（#15-#60）| ↑ 含在内 | 内容已在 `daily-choices.md` §5.6-§5.12 |
| 验证每个 stitch 的硬性 fail 检查（per v2 §5）| ~30 分钟 | `~ check_state_after_choice()` / `-> DONE` / `# tag` 必有 |

**预估总转译工作量**：~6-10 小时（一个新 session 即可完成）。

### 11.4 转译风险点（给下一个 session 提示）

转译时主要要小心的几个 v2 硬性 fail trigger：

1. **每个 stitch 必须有 `~ check_state_after_choice()`** — runtime 没这个不会触发病倒 / 钱紧 / 晋升 GO 链。markdown 草稿里的"隐藏 flag"语义要在 .ink 里体现为 `~ flag_xxx = true` 等具体变量赋值
2. **每个 stitch 必须有 `-> DONE`** — runtime 流程控制依赖
3. **每个 stitch 必须有 `# category` + `# season_unlock` + `# time_filter` 三个 tag**；NPC 类还需 `# npc_focus`；大决策类还需 `# frequency_per_series`
4. **不能动 designer 写的 sample 1-3**（choice_凌晨leader微信 / choice_HR接龙 / choice_35岁体检）
5. **属性变化**：markdown 里写的 `→ KPI +5 / 状态 +3` 在 .ink 里要拆成 `~ kpi = kpi + 5` + `~ state = state + 3`；属性名要跟 sample stitch 中用的变量名对齐（kpi / money / state）
6. **隐藏 flag**：markdown 里写的"隐藏 flag: 你已搬家"在 .ink 里要写成 `~ has_moved = true` 等具体 bool；下个 session 需要先扫一遍 sample stitch + episode-1.ink 看看 flag 命名约定
7. **NPC score**：markdown 里写的 `Lisa score +3` 在 .ink 里要写成 `~ npc_lisa = npc_lisa + 3`（具体变量名以 sample 为准）

### 11.5 分身的 Open Questions（留 designer review）

详见 `daily-choices.md` §8.5（6 个 Q）：

1. 食堂阿姨（#29）不在 npcs.md 注册——保留 background 还是补到 npcs.md？
2. #41 月初转钱双标签（小动作 + NPC 互动），分类是否调整？
3. #47 IT 小马 选 C 递烟——笑天人设不抽烟，烟来源写"David 落工位的"，是否合理？
4. #60 找王总监谈晋升——唯一立即触发 GO 的 daily choice，是否挪到剧情 event？
5. #54 投简历偏扎——是否需补 happy 路径（面试通过被婉拒）？
6. 缺**季节性 trigger**——是否补 1-2 个 seasonal choice（春节 / 端午 / 中秋）？

### 11.6 给 designer 的下一步建议

**Option A**（推荐）：designer 先 review markdown 内容（`daily-choices.md` §5 + §8），通过后再让下一个分身 session 做 .ink 转译。理由：转译是机械工作，但内容质量是创作工作；先把内容定稿避免转译两次

**Option B**：designer review markdown 时同步要求新 session 转译——并行 review + 转译，但如果 review 打回某些 choice 则该 choice 的 .ink 也要重写

**Option C**：如果 designer 已经满意 markdown，直接让下一个分身 session 整批转译——本分身已在 §11.4 列出转译风险点和工作量，下一个 session 应该可以 self-contained 完成

---

> _End of Handoff Brief（progress as of 2026-05-05）._
