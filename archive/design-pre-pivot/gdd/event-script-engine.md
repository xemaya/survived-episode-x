# Event Script Engine

> **Status**: Designed (pending review)
> **Author**: huanghaibin + creative-director (B 主 C2 模板变量变奏 + 副 C3 预告 vs 实际)+ systems-designer (C 22 Rules + D 4 Formulas + E 35 edges 主笔)+ narrative-director (8 NPC 弧 + 18 Tier 1 必含 + 80 模板分布 + Pillar 4 三层执法)+ godot-gdscript-specialist (8 Godot 4.6 实现规约)+ qa-lead (H 30 AC)
> **Authoring autonomy mode**: v2 no-prompt(0 widget,5 specialist parallel)
> **Last Updated**: 2026-04-27
> **Layer**: Feature | **Order**: #10 | **Size**: **L** | **Bottleneck**: ⭐
> **Implements Pillar**: P2 主(叙事即机制 — 数据驱动事件 schema 是 NPC 弧 / 三档密度 / 反讽 tone 的 source of truth)+ P5 守(三档叙事密度 + 90s 一天 budget)+ P4 守(事件文本 tone 三层执法 + 反英雄红线)

## Overview

**Event Script Engine** 是《活过第 X 集》的**数据驱动事件 schema 引擎** —— 80-120 events MVP / 400+ 完整版 的 single source of truth。每个 event 是一个 .tres 文件(Schema A 扁平式),含 trigger / scenes / variants / effects / choices / cooldown / weight / 模板变量。本 GDD owns 的不是"叙事文本本身"(由 writer 通过 Localization key 撰写),而是**让 80+ 事件作为可组合数据资产存在的引擎规约**。Pillar 2"叙事即机制"在此系统具象化:**机制是模板,数据是变量,变量驱动叙事**。

### 双重身份

**技术层**: Event Script Engine owns event schema(13 设计目标 from research §1)+ 候选池查询 + 触发分发 + cooldown 状态机 + flag 字典 + 模板变量注入 + 静态 lint(NPC id / flag key / scene id 引用校验)+ schema_version 迁移。订阅 7 上游(`#6 / #7 / #8 / #9 / #11 / #12 / #14`),emit `event_started / event_completed / choice_selected / dismissal_event / npc_leave_event` 给下游。**自身不渲染 UI / 不持有文本字符串**(由 `#14 Card Play & Dialogue UI` own 渲染;由 `#3 Localization` own 文本加载;`#10` 仅持有 Localization key 引用)。

**叙事层**: 玩家感受到的不是"读事件",是"被事件找上门"。schema `trigger.relationship` 字段对玩家是**不可见但可信的因果链** — 他知道是自己之前那 6 张"敷衍 Lisa"卡累积的,但无法精确预测什么时候摊牌。同时,**模板变量是这款游戏 articulate Pillar 2 最锋利的工具**:同一个"回邮件"卡 schema 玩家打 47 次,模板没变但 `{收件人}` / `{主题}` 变量变了 — 玩家学会了**读变量、不读模板**(真正打工人的阅读模式 — "这封邮件抄送了谁?"才是信息,正文是噪音)。

### Pillar 服务

- **P2 主 叙事即机制**: schema 数据驱动直接转译为玩家叙事。同 event 的 47 次重复通过模板变量 `{NPC_NAME}` / `{task}` 注入产生 47 种"日常变奏"。`trigger` 字段把"NPC 关系阈值 / 月末 / flag 命中" 5 类系统状态映射为事件触发,**机制 = 叙事**最纯粹形式
- **P5 守 地铁可玩性**: 三档叙事密度(`flash <3s` / `long <30s` / `numeric_only` 仅数值)由玩家设置切换,90s 一天 budget 守门。重复事件天然 flash,变量异常时自动升级 long(密度由数据触发,不由作者钦定)
- **P4 守 黑色幽默**: 事件文本 tone 三层执法(lint + writer review + creative-director sign-off)继承 Save/Loc/Audio/Lighting 同源。**禁**励志 / 友谊化 / 戏剧化吼叫;**用** "Lisa 把椅子拉过来,问'你保温杯里泡的什么?'"(职场摊牌的伪装层)
- **P3 守 死亡是注定的**: 8 NPC 离别事件链 + GAME OVER 离职证明叙事 + 开除剧本(potential < -0.15);事件不可撤销(`once_per_run` cooldown),已触发 history 入 Save 持久化
- **P1 守 平庸是艺术**: 事件 effect 不解锁永久 stat buff(违反 Anti-Pillar 1)— Pillar 1 红线;`#9` `monthly_threshold` 不可被事件直接降低(走 `#10` 叙事层包装,实际数值不变)
- **Anti-Pillar 1+2 红线**: 任何"事件解锁永久 buff" / "励志型 NPC 互动" / "成就解锁"语义 → PR-blocking

### 5 NOT 边界(scope creep 防护)

- **NOT** 事件文本 / 对白 / 选项标签字符串(`#3 Localization` own 实际加载,`#10` 仅持有 key)
- **NOT** UI 渲染(立绘 / 对白框 / 选项按钮 由 `#14 Card Play & Dialogue UI` own;`#10` emit `event_started(scene_id, ...)` 信号供 `#14` 订阅)
- **NOT** NPC 关系数值(`#8` own;`#10` 通过 `update_relationship` API 调用)
- **NOT** AP / KPI / 精力 数学(分别由 `#7` / `#9` own;`#10` 通过 Effect dispatch 调用各自 API)
- **NOT** Run Meta 跨局存储(由 `#12` own;`#10` 通过 emit `run_meta_unlock(content_id)` 信号通知)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 事件 effect 解锁永久 stat buff(违反 Anti-Pillar 1 + Pillar 1)
- **NOT** "励志型" / "友谊化" NPC 互动(违反 Anti-Pillar 2 + Pillar 4)
- **NOT** 戏剧化吼叫 / 煽情存在主义文案(违反 Pillar 4 朋友圈测试)
- **NOT** 玩家可挽留 NPC 离别(违反 P3;`#8` 已锁 LEFT 不可逆)
- **NOT** 事件覆盖 KPI 数学规则(走 `#10` 叙事层包装,违反走 `#9` 数值规则 = R-EVT-1)

### 13 schema 设计目标(research §1 全套继承)

| # | 目标 | Section C Rule |
|---|------|---------------|
| 1 | 多触发源统一表达(card/time/relationship/flag/kpi_state + composite) | Rule 3 |
| 2 | 三档叙事密度(flash/long/numeric_only) | Rule 5 |
| 3 | 场景级条件分支(嵌套 ≤2 层) | Rule 4 |
| 4 | Effect 原子化(7 类) | Rule 6 |
| 5 | Choice 玩家选项 | Rule 7 |
| 6 | 模板变量注入 + slot 类型约束 | Rule 8 |
| 7 | Localization hooks(text_key 不硬编码) | Rule 5 + cross-GDD |
| 8 | Cooldown 与去重 | Rule 9 |
| 9 | 权重与随机池 | Rule 10 |
| 10 | 可验证引用(NPC id / flag key / scene id 静态校验) | Rule 11 |
| 11 | 版本号与 schema 迁移 | Rule 11 |
| 12 | 可扩展元数据(章节 / 作者 / 审查状态 / 风险标签) | Rule 1 |
| 13 | 调试可观察性(事件执行 dump) | Rule 12 |

### Source 引用

`design/research/event-script-schema-proposal.md` 全文(§1 13 设计目标 + §2 Schema A 推荐 + 完整示例 + Effect/Choice schemas)+ `game-concept.md` Pillar 2 + Core Mechanics §L82-88(80-120 事件目标)+ MVP Definition。9 GDD cross-system 契约(Save / `#6` / `#7` / `#8` / `#9` / `#11` / `#12` / `#13` / `#14`)。Internal Design Test 原则源自 NPC 算计 + KPI HR 口吻 + AP 反英雄红线四源。

## Player Fantasy

### 主锚: "你打过 47 张'回邮件'卡,这次不一样"

**场景**:
你出"回邮件"卡 — 这张卡你第 48 次出。事件文本基本一样:"你回复了 {收件人} 关于 {主题} 的邮件。"但这次 `{收件人}` 是 Lisa+王总+HR 三人,`{主题}` 是"关于上周会议纪要的补充说明"。**模板没变,变量变了,意味全变了**。

**Pillar 服务**:
- **主 P2 叙事即机制(最强锚)**: 模板变量是这款游戏 articulate 数据驱动 → 玩家叙事的最锋利工具。同一个 event schema,通过 `{变量}` 注入,产生 47 种"日常变奏"。**玩家学会了读变量、不读模板** — 这就是真正职场打工人的阅读模式("这封邮件抄送了谁?"才是信息,正文是噪音)
- **守 P5 地铁可玩性**: 重复事件天然是 flash 档(玩家已经知道发生了什么);但当变量异常时,自动升级为 long 档 — **密度由数据触发,不由作者钦定**
- **守 P4 黑色幽默**: 反讽来自**重复本身的荒诞** — 你做的每件事都"差不多",但"差不多"里藏着所有的不一样

**跨 GDD negative space 联动**:
- **AP Economy** "8 格凑合用" 共振: 每张回邮件卡 1 AP。8 格里有 6 格用来做"差不多的事",这就是反向 KPI 的核心讽刺
- **Localization** GAMEOVER.TITLE_IRONY 共振: 模板变量给本地化的一致性提供了天然容器(Loc key 不变,变量替换)
- **Lighting** "再苟一天" 共振: 第 48 次回邮件时,屏幕的色温应该比第 1 次冷半度 — 视觉系统响应数据驱动的"麻木累积"

**❌ Tone 风险(必避)**:
- "又是一封邮件。你叹了口气,感到生活的虚无。"(廉价存在主义)
- "完成第 48 次回邮件成就解锁!"(游戏化收集表)
- "你已掌握职场邮件之道"(励志 mastery)

**✅ Tone 守护(推荐)**:
- "你回复了王总、HR 关于上周会议纪要的补充说明的邮件。耗时 3 分钟,正文 41 字。"(克制 + 数字 = 反讽)
- "{收件人} 在 {时间} 看了你的回复"(变量驱动的细节真实感)
- "差不多 / 凑合 / 也就那样"(平庸用语)

### 副锚: "今早预告说 Lisa 找你吃饭,实际是老板叫开会"

**场景**:
周二早上 9:17,Day Start 列出今日预告:① 9:30 例会 ② 14:00 客户邮件回访 ③ 午餐:Lisa(她约了你)。你为午餐准备了想说的话。中午 12:08,飞书弹出老板的会议邀请 — **预告的"午餐:Lisa"事件被覆盖了**。系统记录:Lisa 那条事件 cooldown 重置,关系值 -1(被放鸽子)。

**Pillar 服务**:
- **主 P2 叙事即机制**: 数据驱动叙事**最毒**的一面 — **预告 = 玩家心理合同;实际 = 系统按权重池抽签**。schema 里的 `priority` 字段在玩家不知情的情况下,被更高优先级事件挤掉。**程序逻辑成了职场的隐喻:你的计划永远不是你的计划**
- **守 P5 地铁可玩性**: Day Start 是 numeric_only 档(列表式预告),实际事件是 long 档(被动参加会议)— **密度落差本身就是叙事**
- **守 P4 黑色幽默**: 反讽核武器。你为午餐排练的话,永远说不出口了。但游戏不会演煽情戏 — 它只是冷静地把 Lisa 关系 -1 写进数据库

**跨 GDD negative space 联动**:
- **Scene & Day Flow** "周一 9:17" 共振: Day Start 的"预告"是 `#6 MORNING_BRIEFING` sub-mode 的核心节奏点。事件引擎必须支持"预告承诺 → 实际抽取"两阶段触发
- **NPC** "同事都走了" 共振: 被放鸽子是**关系流失的最常见路径** — 不是大吵一架,是"那次饭没吃成"
- **Audio** 月末打卡机不是胜利音 共振: 飞书提示音应该比 Lisa 的对话音效**更刺耳半档** — audio 也参与背叛
- **AP Economy** I-6 漏事件: `#7 ap_early_leave_taken()` 触发的漏事件机制是预告 vs 实际差异的另一表现形式

**❌ Tone 风险(必避)**:
- 弹出窗口"很遗憾,你的午餐计划被取消了。"(系统说人话 = 破坏 tone)
- "Lisa 心情不太好,你需要安抚她"(quest giver 化)
- "玩家计划被打乱"(主语翻转违反 — 玩家成主语)

**✅ Tone 守护(推荐)**:
- 飞书消息样式:"[老板] 12:30 三号会议室,带上上周的数据。"(**没有任何"取消"的提示,玩家自己反应过来**)
- "Lisa 的工位空着,她午饭带回来吃的"(被动观察)
- 静默的 cooldown 重置(不弹"事件已重置"提示)

### Sub-Framing: 三档叙事密度的玩家 agency

玩家在 Settings 切换"flash / long / numeric_only" 三档叙事密度。schema 在 event level 标记**主轨密度**(如打印机卡纸主轨 flash,Lisa 摊牌主轨 long),但事件须为其他档提供 fallback variants(R-EVT-5 守门 — 三档密度 fallback 缺失)。

**密度 != 重要性**: numeric_only 档不是"省事档",是**"职场无奈的具象化"** — 玩家选 numeric_only 表示"我没空读戏,你就告诉我数值变化",这本身是一种 Pillar 5 + Pillar 4 同源 felt sense(职场打工人没空看剧)。

### Internal Design Test: 数据驱动叙事原则

每条事件 schema / 模板变量 / 场景文本审校时,问一个问题:**"这是被作者写出来的剧情,还是被数据组合出来的瞬间?"**

- 如果文案让玩家觉得"作者在告诉我一个故事"(主语 = 作者) → 改写为变量驱动
- 如果文案让玩家觉得"数据让这一刻发生了"(主语 = 系统状态) → 通过

**正例**: "{NPC_NAME} 把椅子拉过来,问:'你保温杯里泡的什么?'"(NPC 行为 + 模板变量 + 数据驱动的具体性)
**反例**: "Lisa 严肃地走过来,你感到一阵寒意从脊背升起"(廉价戏剧 + 主观心理描写 + 作者主语)

**Design test 原则源**: NPC 算计 + KPI HR 口吻 + AP 反英雄红线 + Scene Flow 主语翻转 — 五源同根。

### 红线汇总

- 任何事件 effect 给永久 stat buff / 上限增长 = **PR-blocking**(违反 Anti-Pillar 1)
- 任何"励志支持型"NPC 对白 = PR-blocking(违反 Anti-Pillar 2)
- 任何"心情不太好,你需要安抚她"quest giver 化文案 = PR-blocking(违反 P4 + NPC 算计原则)
- 任何"成就解锁 / 收集进度"事件元素 = PR-blocking(违反 P4)
- 任何"玩家计划被打乱"主语翻转违反 = PR-blocking

### Source 引用

`creative-director` Section B consultation(2026-04-27)+ schema research §1-§5 + 9 GDD Player Fantasy negative space 铁三角延续(铁三角五轨 — 数据驱动事件叙事是第五轨基底)。Internal Design Test 五源同根。

## Detailed Design

22 Core Rules + 5 态状态机 + 9 Interactions。详细 Schema A 完整字段定义见 Rule 2。

### Core Rules

**Rule 1 — Schema A 扁平式: 单事件 = 单资源文件**
每事件存为独立 `.tres` Resource(选型见 Rule 18 Godot 4.6 实现 — JSON-primary + tres runtime)。`schema_version: int` 必存。CI lint 阻塞结构违反。

**Rule 2 — Event Schema 结构(13 设计目标全落)**
最小字段集: `event_id` / `schema_version` / `scene_ids: Array[String]` / `trigger: TriggerBlock` / `conditions: Array[ConditionBlock]` / `variants: Array[VariantBlock]` / `choices: Array[ChoiceBlock]` / `effects: Array[EffectBlock]` / `cooldown: CooldownBlock` / `weight: float [0.1, 100.0]` / `weight_modifiers` / `narrative_tier: "flash"|"long"|"numeric_only"` / `npc_arc_tag: String` / `chapter` / `tags` / `priority` / `author` / `review_status`。

**Rule 3 — 触发源 5 类 + 复合**

| 类型 | 触发条件 | 发起方 |
|------|---------|--------|
| `card` | `#11` emit `card_played(card_id)` | Action Card 打出 |
| `time` | `#6` emit `scene_state_changed(sub_mode)` | sub-mode 变化 |
| `relationship` | `#8` emit `relationship_changed` | NPC 关系变更 |
| `flag` | 内部 flag 字典写入触发 | event effect 或卡 |
| `kpi_state` | `#9` emit `kpi_threshold_changed` / `dismissal_triggered` | KPI 结算 |

复合: `composite_mode: any_of | all_of`。同帧多源按 Rule 20 去重。

**Rule 4 — 条件系统 4 类**: `scene` / `relationship`(`is_above_threshold`)/ `flag`(per-NPC + 全局)/ `kpi_state`(potential_zone + tenure)。默认 `all_of`,支持 `any_of` wrapper。

**Rule 5 — 场景分支 + 嵌套**: `scene_ids` 空 = 静默跳过 + push_warning。嵌套 `branch_event_id` 深度 ≤ 2 层(R-EVT-4 守门)。超过 lint BLOCK + 运行时截断 + push_error。

**Rule 6 — 三档叙事密度**

| 档位 | 时长 | 渲染 | 用途 |
|------|------|------|------|
| `flash` | <3s | 单行 overlay 无选项 | 日常事件 / 环境 / 情报型 |
| `long` | <30s | 立绘 + 多行对白 + 选项(由 `#14` 渲染) | 关键叙事节点 / NPC 弧高点 |
| `numeric_only` | 0s | HUD 数字变化无 UI 事件 | 离别 / NPC LEFT / 月末结算 |

玩家设置切换走 `meta_settings_debounce_ms` 守门。无对应档 fallback Rule 11 + R-EVT-5。**离别事件强制 numeric_only**(LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF)— 沉默比文字更重。

**Rule 7 — Variants 条件文本池**
每事件 1-N VariantBlock: `conditions` + `weight` + `text_key` + `branch_event_id?`。F1 加权随机抽取。**强制 ≥1 个无 condition default variant**(lint 守门,Edge 4.2)。

**Rule 8 — 模板变量注入**
插槽: `{{NPC_NAME}}` / `{{TASK}}` / `{{SCORE_DELTA}}` / `{{MONTH}}` 等。slot 类型约束:
- `NPC_NAME`: 必绑 ACTIVE NPC;LEFT 时 fallback `display_name_static`(Save 持久化 NPC 离职前最后名字)
- `SCORE_DELTA`: int / `MONTH`: int [1,12] / `TASK`: Localization key

注入实现 `tr(loc_key).format(context_dict)`(运行时);slot 类型校验失败 push_error + 中止事件。

**Rule 9 — Effect 原子化(7 类)**

| 类型 | 字段 | 调用目标 |
|------|------|---------|
| `ap` | `delta: int` | `#7 try_consume_ap` / 补充 |
| `energy` | `delta: int` | `#7` energy API |
| `kpi` | `modifier: float` | `#9`(**仅正向 prediction hint**,禁 threshold 减少 — Anti-P1 红线) |
| `relationship` | `npc_id, delta: int` | `#8 update_relationship` |
| `flag` | `key, value: bool` | `#8` per-NPC flag 或全局 |
| `run_meta_unlock` | `unlock_id: String` | `#12 Run Meta` |
| `spawn_event` | `event_id: String` | 注入候选池(非直接触发) |

**Rule 10 — Choice 系统**: 每 `long` 事件 ≤ 3 选项。`label_key` + `conditions`(灰显)+ `ap_cost [0,3]` + `effects` + `next_event_id?`。无选项自动推进。**强制 ≥1 个无条件可选 choice**(lint 守门,Edge 5.1)。

**Rule 11 — Cooldown 4 类**: `days: N` / `weeks: N` / `once_per_run` / `never`。Cooldown 写入 Save(`#1 Rule 6` snapshot),F3 公式判定。

**Rule 12 — 权重池抽取 + 动态权重**: F1 公式;`effective_weight = max(0.01, base + Σ delta_weight)` floor 防全归零。

**Rule 13 — 静态 Lint + schema_version**: CI `tools/event_lint.gd` PR 阶段:`event_id` 全局唯一 / `scene_ids` ⊂ `#6 sub-mode enum` / `npc_id` ⊂ `#8 NPC 注册表` / `flag_key` ⊂ flag 注册表 / 嵌套 ≤ 2 层 / `narrative_tier` 有对应 variant / `schema_version` 匹配。MVP 不支持迁移;旧版 lint 标 DEPRECATED。

**Rule 14 — 可调试性**: 每次执行 emit `_debug_event_dump(event_id, trigger_source, conditions_eval, variant_chosen, effects_applied)`(DEBUG only,写 `session-logs/event-dump-[date].log`)。`force_trigger(event_id)` debug API 供 QA 注入。

**Rule 15 — NPC 弧管理**: 8 NPC 各 3-5 关键事件(`npc_arc_tag` 标记)+ 1 离职事件链(预兆 → 宣告 → run_meta_unlock)。订阅 `#8 npc_left_company` → 检索 `[npc_id]_leaving_announced` arc_tag 触发离别。

**MVP 18 必含 Tier 1 事件**(narrative-director 锁定):
LISA_GOODBYE / FISH_MONK_LAID_OFF / CLEANING_AUNT_LEAVE / BOSS_KPI_ANNOUNCE(首月)/ LISA_LUNCH_DILEMMA / LISA_OFFER_LETTER / LISA_MIRROR_MOMENT / LISA_RESIGNATION_TALK / BOSS_MENTOR_TRAP / BOSS_MONTH_REVIEW_1(达标/险过/失败 3 路径)/ CLEANING_AUNT_SON_PREP / CLEANING_AUNT_SON_RESULT / OLD_OIL_INTRO / GRIND_KING_BENCHMARK / NEWBIE_INTRO / FLATTERER_RELAY。

**Rule 16 — 早晨预告机制**: 订阅 `#6 scene_state_changed(→MORNING_BRIEFING)` → 候选池随机选 1-2 事件(F2 命中率 60-80%)→ inject 至 `#7 inject_predicted_ap_demand` → blacklist 持久化(R-EVT-2 守门)→ 5 天强制差异保证。

**Rule 17 — 开除剧本 + 老 NPC 预言 + GAME OVER 三轨**:
- 订阅 `#9 dismissal_triggered`(potential < -0.15)→ 启动 `dismissal_event_chain` 候选池顶部
- 订阅 `#9 kpi_prediction_hint(hint_type: HINT_EFFORT_HIGH | POTENTIAL_HIGH | TENURE_LONG | TENURE_VETERAN)` → 4 套老 NPC 台词池
- 订阅 `#9 game_over_triggered(reason)` → `gameover_narrative_event` + `run_meta_unlock` + `#12` 词条注入 + `GAMEOVER.CERTIFICATE.[reason]` 离职证明文本

**Rule 18 — Godot 4.6 实现规约**(godot-gdscript-specialist 锁):

| 规约 | 决策 | Godot 4.6 API |
|------|------|--------------|
| 序列化 | **JSON-primary + tres runtime**(writer 用纯文本,运行时构造 `EventDefinition extends Resource`) | `JSON.parse_string()` + `FileAccess.store_*` 4.4+ 返回 bool |
| schema_version 迁移 | 启动 lazy migration + `_migrate_vN_to_vN1(dict)` 链 | const `CURRENT_SCHEMA_VERSION` |
| 静态 lint | EditorPlugin(实时反馈)+ Python CI(强制门)双轨 | Godot 4.6 `EditorDock` 可选增强 |
| 候选池索引 | `Dictionary` 三层(`_by_trigger` / `_by_chapter` / `_by_npc`)+ typed `Array[EventDefinition]` | StringName 字面量 `&"trigger_name"` 避免每帧字符串哈希 |
| 文本加载 | `#10` 仅持 `StringName` loc key,触发时 UI 层调 `tr()` | 不缓存文本不持有原始字符串 |
| 模板变量 | `tr(loc_key).format(context_dict)` 运行时注入 + slot 类型运行时校验 | `String.format()` 4.0+ 稳定 |
| Save 持久化 | `_triggered_history: Dictionary[StringName, bool]` + `_cooldown_until: Dictionary[StringName, float]` + `_morning_blacklist: Dictionary[StringName, int]`(7 天滑动) | JSON-compatible plain dict |
| `@abstract` Effect 基类 | `EventEffect` 抽象基类 + 7 具体 Effect class 各 `extends`+ override `apply()` | Godot 4.5+ `@abstract` 编辑器 + 运行时双重 enforcement |

**Rule 19 — 主语翻转 + Pillar 4 反英雄红线 Lint**: `subject_inversion_lint.py` 扩展(扫描 `EVENT.*` + `NPC.*` keys + `#7 AP/ENERGY` + `#9 KPI/EFFORT/TENURE` + `#3 Loc IRONY` 五域同源):
- 禁 "友谊"/"喜欢"/"讨厌"/"再加油"/"你能做到"/"励志"等
- 禁 `励志_` / `胜利_` / `恭喜_` 前缀(白名单 `GAMEOVER.TITLE_IRONY`)
- CI 阻塞 PR + writer review 第三层执法

**Rule 20 — 性能契约**: 每帧最多 1 事件触发(队列缓冲);候选池查询 < 1ms(三层 Dictionary 索引);文本加载(`tr()`)< 100ms;effect 链同帧主线程完成(禁异步 effect);Save 持久化在 `event_completed` 后通过 `#1 autosave` 触发(不额外写盘)。

**Rule 21 — Save 持久化**:
```
event_history: Array[String]
cooldown_map: Dict[String, int]
flag_dict: Dict[String, bool]
morning_blacklist: Array[String]   # 7 天滑动窗口
```
归 `#10` sub-schema,随 `current_schema_version` 演进。

**Rule 22 — Scope Tier**

| Tier | 事件总量 | 要求 |
|------|---------|------|
| **MVP** | 80-120 | 18 Tier 1 必含 + 8 NPC 弧核心 + 开除 + GAME OVER 三轨 + 80 模板化 |
| **VS** | 200+ | 拓展 NPC 支线 + 季度事件 + RETURNED 路径 + Lisa 跳槽线全分支 |
| **野心版** | 400+ | 全开放叙事图 + 多公司类型 |

**Rule 23 — FAREWELL_EVENT_IDS 权威 enum(ADR-0001 仲裁,B-DEP-2 守门)**:

`#10` own 离别事件白名单常量(`data/event_constants.tres` 或 GDScript const)。下游 4 GDD(`#13/#15/#4/#5`)各自 Section H 增 AC 守门契约,**不**自定义 farewell list:

```gdscript
# src/feature/event_script/event_constants.gd
const FAREWELL_EVENT_IDS: Array[StringName] = [
    &"LISA_GOODBYE",
    &"CLEANING_AUNT_LEAVE",
    &"FISH_MONK_LAID_OFF",
    &"GRIND_KING_PROMOTED_LEAVE",
    &"OLD_OIL_OPTIMIZED_OUT",
    # VS 起追加: NEWBIE_LEAVE / FLATTERER_LEAVE
]
```

**下游守门契约**(各 GDD 必须在自身 Section H 增 AC 验证):
- **`#13 HUD Diegetic`**:`event_started(event_id, narrative_tier)` 中 `event_id ∈ FAREWELL_EVENT_IDS` → **禁渲染 flash overlay** + 仅切 `HUD_NPC_EXPRESSION/POSITION` LEFT variant + 后续 `HUD_EMPTY_CHAIR`
- **`#15 Daily/Weekly Recap UI`**:farewell event 在周报 numeric_only 列表中**仅一行 `EVENT.[event_id].TITLE_NUMERIC` key**,无情感词
- **`#4 Audio Manager`**:farewell event 触发时**禁切 BGM**(继续当前 ambient,Pillar 4 红线)
- **`#5 Lighting`**:farewell event **禁特殊 palette swap**(继续当前 sub-mode CanvasModulate)+ `accumulation_event("npc_empty_chairs", +1)` 仅在 `npc_left_company` 触发(see ADR-0005)

**CI 守门**:`tools/event_lint.gd` PR 阶段 lint:任何下游 GDD 自定义 farewell list / 不一致 → BLOCK PR。

**Rule 24 — EVENT.KPI.FIRED_DISMISSAL 三 reason 剧本(ADR-0006 双路径合并仲裁)**:

`#9 dismissal_triggered(reason)` → `#10` 检索 `EVENT.KPI.FIRED_DISMISSAL.[reason]` 剧本 → 演完 emit `dismissal_finalized` → `#9 _on_dismissal_finalized` 链:

| reason | 剧本骨架 | localization_key |
|--------|---------|-------------------|
| `kpi_fail_3` | "员工绩效连续三月不达标 — 优化通知" | `EVENT.KPI.FIRED_DISMISSAL.kpi_fail_3.HR_CERTIFICATE` |
| `kpi_overflow` | "员工 KPI 浮动达 200% 预警 — 防泡沫机制启动" | `EVENT.KPI.FIRED_DISMISSAL.kpi_overflow.HR_CERTIFICATE` |
| `relationship_collapse` | "员工人际关系评估 D 级 — 团队协作风险解除" | `EVENT.KPI.FIRED_DISMISSAL.relationship_collapse.HR_CERTIFICATE` |

无 NPC 参与(纯 HR 文本场景);剧本 `effects` 含 `EmitDismissalFinalizedEffect` → 5 秒玩家阅读期后自动 emit。`#9` 收到 `dismissal_finalized` → `SaveSystem.save_meta_sync(meta.run_ended=true)` → emit `game_over_triggered(reason, month)` → `#16` 1500ms transition。

**Rule 25 — `narrative_density_changed` 订阅契约(ADR-0001 + ADR-0004 仲裁,B-DEP-1 守门)**:

订阅 `#17 Settings narrative_density_changed(tier: NarrativeTier)` 信号。EVENT_ACTIVE 态期间切档**延后到下个 `event_started` 起生效**(ADR-0004 仲裁),当前事件用旧密度完成:

```gdscript
# event_script_engine.gd state machine EVENT_ACTIVE
var _current_density: NarrativeDensity
var _pending_density_for_next_event: NarrativeDensity

func _on_narrative_density_changed(new_tier: NarrativeDensity) -> void:
    if state == EventState.EVENT_ACTIVE:
        _pending_density_for_next_event = new_tier  # 延后
    else:
        _current_density = new_tier  # 立即生效
```

`event_started` emit 时 push `_current_density` 给 `#14 Card Play UI`(主消费 layer per ADR-0012);`#14` fallback 链 brief → standard → verbose。

### States and Transitions(5 态)

| 状态 | 进入条件 | 退出条件 |
|------|---------|---------|
| `IDLE` | 初始 / `event_completed` | 触发源命中 → `EVALUATING_CANDIDATES` |
| `EVALUATING_CANDIDATES` | 触发源命中 | 抽到候选 → `EVENT_ACTIVE`;无候选 → `IDLE` |
| `EVENT_ACTIVE` | 候选确定 + `event_started` emit | 无选项 → `EXECUTING_EFFECTS`;有选项 → `WAITING_PLAYER_CHOICE` |
| `WAITING_PLAYER_CHOICE` | `long` 事件含 choices | `choice_selected` → `EXECUTING_EFFECTS`;`game_over_triggered` 强制中止 → `IDLE` |
| `EXECUTING_EFFECTS` | 选项选定 / 无选项自动 | effect 链完成 → `event_completed` emit → `IDLE` |

### Interactions with Other Systems(9 contracts)

| # | 对端 | 方向 | 主接口 |
|---|------|------|--------|
| I-1 | `#6 Scene & Day Flow` | 双向 | 订阅 `scene_state_changed`;emit `event_started/completed` 供时间推进 |
| I-2 | `#7 AP Economy` | 双向 | 订阅 `ap_early_leave_taken`(F4 漏事件);emit `inject_predicted_ap_demand` 早晨预告 |
| I-3 | `#8 NPC Relationship` | 双向 | 订阅 `relationship_changed` / `npc_left_company`;调 `update_relationship` / `is_above_threshold` |
| I-4 | `#9 KPI System` | 订阅 | 订阅 `dismissal_triggered` / `kpi_prediction_hint(4 档)` / `game_over_triggered` |
| I-5 | `#11 Action Card` | 订阅 | 订阅 `card_played(card_id)`;trigger.type=card 检索 |
| I-6 | `#12 Run Meta` | emit | effect `run_meta_unlock`;GAME OVER 词条收集 |
| I-7 | `#13 HUD Diegetic` | emit | `event_completed` HUD 更新 |
| I-8 | `#14 Card Play UI` | emit | `event_started(event_id, narrative_tier)` 渲染(UI own by `#14`,`#10` 不持 UI) |
| I-9 | `#1 Save System` | 写 | `event_history` / `cooldown_map` / `flag_dict` / `morning_blacklist` 持久化 |

**`#10` 与 `#14` 边界**: 本 GDD own schema + 引擎逻辑 + 信号 emit。立绘 / 对白 / 选项 UI 渲染 own by `#14 Card Play UI`。`#10` 不持任何 UI 节点引用。

## Formulas

4 公式 F1-F4。

### F1 — 候选池权重抽取

```
effective_weight_i = max(0.01, base_weight_i + Σ_k(delta_weight_k | condition_k == true))
normalized_weight_i = effective_weight_i / Σ_j(effective_weight_j)
selected_event = argmax_i(cumulative_normalized_weight_i ≥ U)
```

| Var | Type | Range | Description |
|-----|------|-------|-------------|
| `base_weight_i` | float | [0.1, 100.0] | schema 基础权重 |
| `delta_weight_k` | float | [-50, +50] | WeightModBlock 动态调整(flag 条件) |
| `effective_weight_i` | float | [0.01, 150] | 下限 clamp(防全归零) |
| `U` | float | [0, 1) | 均匀随机数 |

**Output**: 始终返回候选池一个合法 event_id;空池返 `null`(Edge 2 / 4)。**Worked Example**: 3 事件 effective=[15.0, 20.0, 5.0],Σ=40,normalized=[0.375, 0.500, 0.125];U=0.42 → cumulative E1=0.375(未达)→ E2=0.875(超)→ 选 **E2**。

### F2 — 早晨预告命中率

```
diversity_factor = min(1.0, 1 - blacklist_overlap_count / max(1, candidate_pool_size))
hit_probability = MORNING_HIT_BASE × diversity_factor
guarantee: if consecutive_same_event_days >= 5 → force_select_different_event()
```

| Var | Range | Description |
|-----|-------|-------------|
| `MORNING_HIT_BASE` | [0.60, 0.80] | tuning knob,推荐 0.70 |
| `blacklist_overlap_count` | [0, pool_size] | 候选池中已 blacklist 数 |
| `candidate_pool_size` | [0, 120] | 当日可触发候选总数 |
| `diversity_factor` | [0, 1] | 防重复系数 |
| `hit_probability` | [0, 0.80] | 最终命中率 |

**Output**: `[0, MORNING_HIT_BASE]`。命中率为 0 时跳过预告。5 天强制差异保证: 当 `consecutive_same_event_days ≥ 5` 强制从 blacklist 外候选池选取。

**Worked Example**: HIT_BASE=0.70, pool=20, blacklist=8 → diversity=0.60 → hit=0.42;U=0.35 < 0.42 → 命中。

### F3 — Cooldown 触发判定

```
is_blocked(event_id, current_day) =
  type=="never"        ? (event_id ∈ event_history)
: type=="once_per_run" ? (event_id ∈ event_history)
: type=="days"|"weeks" ? (cooldown_map[event_id] > current_day)
: false
```

`cooldown_map` 写入: `days: N → cooldown_map[id] = current_day + N`;`weeks: N → +N×7`;`once_per_run` / `never` → 写 `event_history`。

**Worked Example**: event="lisa_lunch_hint", type="days", cooldown_map=45, current_day=43 → 43<45 → blocked=true(还需 2 天)。

### F4 — 漏事件概率(早退触发)

```
P_miss_event = MISS_BASE × (1 - remaining_ap / MAX_AP_PER_DAY)
trigger_miss: if U < P_miss_event → inject_missed_events_to_pool(missed_event_pool)
```

| Var | Range | Description |
|-----|-------|-------------|
| `MISS_BASE` | [0.30, 0.60] | tuning knob |
| `remaining_ap` | [1, 2] | 早退剩余未消耗 AP(`#7` 早退 = 留 1-2 AP) |
| `MAX_AP_PER_DAY` | 8 | registry candidate |
| `P_miss_event` | [0, MISS_BASE] | 最终概率 |

**触发**: 订阅 `#7 ap_early_leave_taken()`;漏事件不立即播放 → 注入第 N+1 天候选池(延迟 1 天反馈循环,符合 P2)。

**Worked Example**: MISS=0.40, remaining=1, MAX=8 → P=0.40×0.875=0.35;U=0.28 < 0.35 → 触发,次日候选池注入 1 条漏事件。

## Edge Cases

35 edges / 12 categories / 5 [RISK GUARD] R-EVT-1..5。

### Cat 1: Schema 边界
**1.1**: 空 trigger 块 → 静态 lint BLOCK + 行号
**1.2**: 空 scene_ids → 运行时静默跳过 + push_warning
**1.3**: 嵌套深度 > 2 层 → 静态 lint BLOCK + 运行时截断 + push_error(R-EVT-4)
**1.4**: schema_version 不匹配 → lint 标 DEPRECATED + 运行时跳过 + push_error
**1.5**: event_id 重复 → 静态 lint BLOCK + CI 拒合并

### Cat 2: 触发源 race
**2.1**: 同帧多触发源 → Rule 20 队列缓冲 + 优先级 `kpi_state > relationship > card > time > flag`
**2.2**: Cooldown 边界(到期当天)→ F3 严格 `>` 判定,当天 blocked=false 可触发
**2.3**: EVALUATING_CANDIDATES 中新触发到达 → 排队不丢弃

### Cat 3: 场景分支
**3.1 [RISK GUARD R-EVT-4]**: branch_event_id 循环引用(A→B→A) → 静态 lint DFS 环检测 BLOCK
**3.2**: branch_event_id 指向已 cooldown 封锁事件 → fallback 执行当前 variant effects 后直接 event_completed
**3.3**: 全 variant conditions 失败 → fallback default_variant(schema 强制 ≥1 个无 condition variant,lint BLOCK)

### Cat 4: Variants 池
**4.1**: 全 variant weight=0 → effective_weight floor 0.01 仍可计算,均匀分布抽取
**4.2**: 全 variant condition false 且无 default → push_error + 事件中止 + event_completed emit(不卡状态机);lint 强制 ≥1 个 condition-free variant 一级防护
**4.3**: 单 variant 事件 → F1 normalized=1.0 必中(热路径)

### Cat 5: Choice 选项
**5.1**: 全 choice 条件 disabled → 自动选 index=0 + push_warning;内容红线 ≥1 个无条件可选(lint)
**5.2**: ap_cost 不足 → 灰显;`#7 try_consume_ap` dry-run 校验
**5.3**: WAITING_PLAYER_CHOICE 中 game_over_triggered → 强制中止 + 转 IDLE + emit event_completed(状态机不卡)

### Cat 6: Cooldown
**6.1**: once_per_run 跨 Run 重置 → 新 Run `event_history.clear()`(由 `#12` 触发);never 不清
**6.2**: never cooldown 重启 reload → 写 event_history(Save Rule 6 持久化),语义不变
**6.3**: days 值超大(>365)→ 合法但 lint WARN(建议上限 30 天)

### Cat 7: 模板变量
**7.1**: NPC_NAME slot 对应 NPC LEFT → fallback `display_name_static`(Save 离职前最后名字),不用"未知"保叙事连续性
**7.2**: slot 类型约束违反 → 静态 lint BLOCK;运行时漏检 fallback 空字符串 + push_error
**7.3**: text_key miss → `#3 Rule 4` 双轨(DEBUG 显示 key + push_error;Release `[???]` fallback)

### Cat 8: 早晨预告
**8.1 [RISK GUARD R-EVT-2]**: blacklist 持久化失效(Save 加载失败 → blacklist 归空)→ 接受重复预告(降级);`#1 Rule 2` autosave retry 守门;**跨 GDD 同 R-AP-4**(`#7 AP Economy R-AP-4` blacklist 持久化)
**8.2**: blacklist 7 天滑动窗口过期 → 每日 MORNING_BRIEFING 删除 7 天前条目
**8.3**: 候选池为空(全 cooldown 封锁)→ 跳过预告,不 emit `inject_predicted_ap_demand`

### Cat 9: 三轨 race(开除 + 老 NPC 预言 + GAME OVER)
**9.1**: dismissal_triggered + game_over_triggered 同帧 → game_over 优先,dismissal 中止 + emit event_completed(状态机清洁)
**9.2**: 老 NPC 预言对应 NPC LEFT → hint 仍触发(用 display_name_static + "你回想起他曾说过");不强制 ACTIVE
**9.3**: GAME OVER 时 prediction_hint 队列有未消费 → 清空队列丢弃,GAME OVER 优先

### Cat 10: 静态 lint 失效
**10.1 [RISK GUARD R-EVT-1]**: NPC id 改名 / flag deprecated → CI lint `tools/event_lint.gd` 在 PR 阶段扫描 `npc_id` / `flag_key` / `scene_id` 与注册表 diff;孤悬引用 = CI BLOCK。改名须 PR 捆绑提交注册表 + 全量 event 文件
**10.2**: flag deprecated → lint 识别状态 + BLOCK + 提示替代 key
**10.3**: scene id 在 `#6` 枚举删除 → 同 R-EVT-1 lint 校验 `scene_ids` ⊂ sub_mode enum

### Cat 11: 三档密度切换 race
**11.1 [RISK GUARD R-EVT-5]**: 玩家选 flash 但事件无 flash 变体 → fallback 自动选 long + push_warning(不 BLOCK 流程);lint 检查每事件 ≥1 个 narrative_tier 与 variants tier 匹配
**11.2**: EVENT_ACTIVE 中途切换密度 → 不回滚进行中事件;新设置下个事件生效
**11.3**: numeric_only 含 choices → lint WARN(numeric_only 语义不含 UI);运行时丢弃 choices + push_warning

### Cat 12: Pillar 4 红线
**12.1**: 励志词进 event text("再加油")→ `subject_inversion_lint.py` BLOCK + PR comment 行号
**12.2**: 友谊化 NPC 事件("{{NPC_NAME}} 喜欢你")→ lint 匹配禁用词"喜欢/讨厌/友谊"BLOCK
**12.3**: GAMEOVER.TITLE_IRONY 误改为正能量 → `#3 Rule 10` Localization key 稳定性 + IRONY 后缀 tone 违规扫描;AC-TONE-03 CI 验证

---

### 5 [RISK GUARD] 索引

| ID | 守 Pillar | 位置 | Section H 守门 |
|----|---------|------|---------------|
| **R-EVT-1** | Schema 错引(NPC/flag/scene 注册表 diff)| Cat 10.1 | AC-ROBUST-01 |
| **R-EVT-2** | 早晨预告 blacklist 持久化失效 | Cat 8.1 | AC-ROBUST-02 + 跨 R-AP-4 |
| **R-EVT-3** | 触发源 race + cooldown 漏触发(玩家"刷"事件)| Rule 20 + F3 | AC-ROBUST-03 |
| **R-EVT-4** | 嵌套场景循环引用 | Cat 3.1 | AC-ROBUST-04 |
| **R-EVT-5** | 三档密度 fallback 缺失 | Cat 11.1 | AC-ROBUST-05 |

## Dependencies

### Upstream

| GDD | 关系 | 状态 | 提供 |
|-----|------|------|------|
| `#1 Save System` | Hard | ✅ Approved | Rule 6 snapshot + Rule 7 autosave + schema migration |
| `#3 Localization Hooks` | Hard | ⏳ Designed | `tr()` API + Rule 10 key 稳定性 + IRONY 后缀守门 |
| `#6 Scene & Day Flow` | Hard | ⏳ Designed | scene_state_changed + 8 sub-mode enum + MORNING_BRIEFING 早晨预告触发 |
| `#7 AP Economy` | Hard | ⏳ Designed | ap_early_leave_taken(F4 漏事件)+ inject_predicted_ap_demand 接口 |
| `#8 NPC Relationship` | Hard | ⏳ Designed | relationship_changed + npc_left_company + is_above_threshold + per-NPC flags |
| `#9 KPI System` | Hard | ⏳ Designed | dismissal_triggered + kpi_prediction_hint(4 档)+ game_over_triggered |

### Downstream

| # | System | 关系 | 主接口 |
|---|--------|------|--------|
| 11 | Action Card | Hard | emit `card_played(card_id)` → `#10` trigger.type=card 检索 |
| 12 | Run Meta | Hard | effect `run_meta_unlock(content_id)`;GAME OVER 词条收集 |
| 13 | HUD Diegetic | Soft | event_completed → HUD 更新 |
| 14 | Card Play & Dialogue UI ⭐ | Hard | event_started(event_id, narrative_tier)→ `#14` 渲染 long 立绘+对白+选项 UI |
| 15 | Daily/Weekly Recap UI | Soft | 周摘要事件回顾 |
| 16 | KPI Review & Game Over UI | Soft | GAME OVER 离职证明文本(GAMEOVER.CERTIFICATE.[reason]) |

### 双向一致性 cross-check

| 上游声明 | 本 GDD Rule | ✓ |
|---------|------------|---|
| Save Rule 6 snapshot | Rule 21 sub-schema 持久化 | ✓ |
| `#3 Loc Rule 10` key 稳定性 + Rule 11 IRONY 后缀 | Rule 19 主语翻转 lint + EVENT.* / NPC.* / IRONY 守门 | ✓ |
| `#6 Section A` 8 sub-mode enum | Rule 13 lint scene_ids ⊂ enum | ✓ |
| `#7 ap_early_leave_taken` | Rule 16 + F4 + I-2 | ✓ |
| `#7 inject_predicted_ap_demand` | Rule 16 早晨预告 + I-2 | ✓ |
| `#8 update_relationship` API | Rule 9 effect.relationship + I-3 | ✓ |
| `#8 npc_left_company` | Rule 15 离职事件链 + I-3 | ✓ |
| `#9 dismissal_triggered` | Rule 17 开除剧本 + I-4 | ✓ |
| `#9 kpi_prediction_hint(4 档)` | Rule 17 老 NPC 预言 + I-4 | ✓ |
| `#9 game_over_triggered` | Rule 17 GAME OVER 离职证明 + I-4 | ✓ |

### 5 propagation flags

| # | 待 GDD | 状态 | 描述 |
|---|--------|------|------|
| 1 | `#11 Action Card` | ⏳ | emit `card_played(card_id)` 协议 + Hero/Overage `is_hero` flag |
| 2 | `#12 Run Meta` | ⏳ | `run_meta_unlock(content_id)` 接口 + GAME OVER 词条收集 schema |
| 3 | `#14 Card Play UI ⭐` | ⏳ | 三档密度渲染契约(flash overlay / long 立绘+选项 / numeric_only HUD only) |
| 4 | `#16 KPI Review UI` | ⏳ | GAME OVER 离职证明文本(GAMEOVER.CERTIFICATE.[reason])UI 集成 |
| 5 | writer team | ⏳ | 18 Tier 1 必含手写 + 80 模板化 + Pillar 4 三层执法 + 朋友圈测试 |

### Registry 候选(Phase 5b decision)

| 候选 | 跨系统消费 | 注册时机 |
|------|----------|---------|
| `MORNING_HIT_BASE = 0.70` | `#10` only | 不注册 |
| `MISS_BASE = 0.40` | `#10` only | 不注册 |
| `MAX_AP_PER_DAY = 8` | `#7` source + `#10` consumer | 已 `#7 BASE_AP_PER_DAY` 锁,**注册候选**等 `#7` 联合 |
| `WEEKLY_DIFFERENCE_GUARANTEE = 5 days` | `#10` (R-EVT-2) + `#7 R-AP-4` 跨守 | **注册候选** |

## Tuning Knobs

### 锁定常量(红线)

| 常量 | 值 | 红线 |
|------|----|----|
| `MAX_NESTED_DEPTH` | 2 | 嵌套场景深度上限(R-EVT-4) |
| `MAX_CHOICES_PER_LONG_EVENT` | 3 | 每 long 事件 ≤ 3 选项 |
| `MAX_EVENTS_PER_FRAME` | 1 | 每帧最多触发 1 事件(性能契约 Rule 20) |
| `EVENT_DISPATCH_BUDGET_MS` | 1.0 | 候选池查询每次 < 1ms |
| `TEXT_LOAD_BUDGET_MS` | 100.0 | `tr()` 加载 < 100ms |

### F1/F2/F3/F4 Knobs

| Knob | 默认 | 安全 | 影响 |
|------|------|------|------|
| `MORNING_HIT_BASE` | 0.70 | [0.60, 0.80] | F2 早晨预告基础命中率 |
| `MISS_BASE` | 0.40 | [0.30, 0.60] | F4 漏事件基础概率 |
| `WEEKLY_DIFFERENCE_GUARANTEE` | 5 days | [4, 7] | blacklist 防重 — 连续 N 天预告不重复同一事件 |
| `EVENT_HISTORY_MAX_SIZE` | 200 | [100, 500] | event_history 集合上限(LRU 淘汰最旧) |
| `BLACKLIST_WINDOW_DAYS` | 7 | [5, 14] | 早晨预告 blacklist 滑动窗口 |
| `WEIGHT_FLOOR` | 0.01 | 锁定 | F1 effective_weight 下限,防全归零 |

### Cooldown Defaults(per-event 可覆盖)

| 类型 | 默认 days/weeks | 推荐 |
|------|----------------|------|
| 日常事件 | days: 3 | 防同周重复触发 |
| 关键事件 | once_per_run | Lisa 摊牌只触发一次 |
| 离职事件 | never | NPC 离职不可逆 |
| 周末事件 | weeks: 2 | 防连续两周遭遇相同 |

### Per-Event Tuning 字段(schema field 而非全局 knob)

| 字段 | 范围 | 影响 |
|------|------|------|
| `weight: float` | [0.1, 100.0] | F1 基础权重 |
| `priority: int` | [-100, +100] | 同候选池中优先级,默认 0 |
| `narrative_tier: String` | flash/long/numeric_only | Rule 6 |

### Scope Tier 守门表

| Tier | 启用 |
|------|------|
| **MVP** | 全部 internal knobs + 18 Tier 1 必含 + 80 模板化 + 8 NPC 弧 + 三轨 + Schema A 扁平式 |
| **VS** | + RETURNED 路径 + 季度事件 + Lisa 跳槽线全 5-7 分支 + 200+ 事件 + 6 离别事件全启 |
| **野心版** | + 多公司类型事件池 + 全开放叙事图 + 400+ 事件 + 周期性外部冲击事件破稳态 |

## Visual/Audio Requirements

### 零 Asset Ownership

Event Script Engine **不 own visual / audio asset**。所有事件视听 own by:

| Asset | Owner |
|-------|-------|
| 立绘 / 对白框 / 选项 UI(long 事件) | `#14 Card Play & Dialogue UI` ⭐ |
| Flash overlay 单行文本 | `#13 HUD Diegetic` |
| 事件 SFX(可选;MVP 不引入)| `#4 Audio Manager` Rule 6 |
| 事件触发时的 Lighting 提示(可选) | `#5 Lighting & Visual State` |
| GAME OVER 离职证明视觉 | `#16 KPI Review UI` + `#5` |

### Pillar 4 三轨负空间 + 第五轨(本 GDD 是 schema 源)

事件文本 tone 是负空间铁三角的**机制源**。月末 KPI Review + GAMEOVER + NPC 离别等关键事件触发时,**五轨拒绝庆祝**:
1. 数学(`#9` KPI):threshold 涨幅,无祝贺
2. 听觉(`#4`):月末打卡机不是胜利音
3. 视觉(`#5`):KPI 紫静止 + GAMEOVER 累积视觉峰值
4. 文字(`#3`):GAMEOVER.TITLE_IRONY 反讽
5. **叙事(`#10`)**:18 Tier 1 + 80 模板事件文本同源 tone 三层执法

`#10` emit `event_started(event_id, narrative_tier)` → 五轨同帧响应。

### 📌 Asset Spec Flag

本 GDD 不需 `/asset-spec`(零 ownership)。Asset spec 由 `#14` / `#13` / `#5` / `#16` 各自产出。**writer team** 须在 Pre-Production 启动 `/team-narrative` 编写 18 Tier 1 必含手写事件 + 80 模板化事件,Pillar 4 三层执法 + 朋友圈测试 review 落 `production/qa/evidence/event-tone-review-[date].md`。

## UI Requirements

### 零 UI Screen Ownership

Event Script Engine **不 own UI screen**。下游 UI 订阅 `#10` 信号:

| UI GDD | 订阅信号 | 备注 |
|--------|---------|------|
| `#14 Card Play & Dialogue UI` ⭐ | `event_started(event_id, narrative_tier)` + `choice_selected` | **三档密度全部由 `#14` 渲染** — flash overlay / long 立绘+对白+选项 / numeric_only HUD-only |
| `#13 HUD Diegetic` | `event_completed` + 模板变量绑定状态 | HUD 数字变化(numeric_only)/ flash overlay 单行 |
| `#15 Recap UI` | 周摘要事件回顾 | 一周内触发事件列表(numeric_only 风格) |
| `#16 KPI Review & Game Over UI` | `gameover_narrative_event` | GAMEOVER.CERTIFICATE.[reason] 离职证明文本嵌入 |

### `#14` 强制契约(本 GDD 锁渲染要求)

`#14 Card Play & Dialogue UI` GDD 撰写时**必须**遵循:

1. **三档密度独立渲染**:
   - `flash`: 单行 overlay,< 3s 自动消失,无玩家交互(`#13` HUD 层 fallback)
   - `long`: 立绘 + 多行对白 + ≤3 选项 UI;选项可被条件灰显;`#14` 处理玩家点击 → emit `choice_selected(event_id, choice_index)` 给 `#10`
   - `numeric_only`: 不渲染任何 UI(由 `#13` HUD 数字变化反映)
2. **离别事件强制 numeric_only**(LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF):**禁特殊 UI / 禁 toast / 禁 BGM 切换** — 仅 `#5` Lighting 累积视觉变化 + `#13` HUD 状态更新
3. **模板变量已注入**: `#14` 收到 `event_started` 时文本已经过 `tr().format(context_dict)` 注入(由 `#10` Rule 8 完成);`#14` 仅渲染最终字符串
4. **主语翻转** lint 守门: `#14` UI 文案禁出现"你的友谊"/"你赢得了"等违反 Rule 19

### 📌 UX Flag — Phase 4

`#14 Card Play & Dialogue UI` 是**最复杂 UI 屏之一**(三档密度差异化渲染 + 选项交互 + 立绘 + 对白)。Phase 4 须 `/ux-design design/ux/event-dialogue-screen.md` 独立 UX spec(配 `#14` GDD)。三轨铁三角 + 主语翻转 + 反英雄红线 + Pillar 4 三层执法 cross-cutting。

## Acceptance Criteria

30 AC / 5 categories(AC-FUNC 12 / AC-PERF 3 / AC-COMPAT 7 / AC-ROBUST 5 / AC-TONE 3)。5 [RISK GUARD] R-EVT-1..5 全对应 AC-ROBUST。

### AC-FUNC

**AC-FUNC-01** `MVP` Schema lint 通过
**GIVEN** lint 工具扫描全部事件文件
**WHEN** CI 运行
**THEN** 所有 `npc_id` / `flag_key` / `scene_id` 字段均存在于注册表;任意孤立引用 = lint BLOCK + 事件不加载
*Cite: Rule 13 / R-EVT-1*

**AC-FUNC-02** `MVP` 5 类触发源覆盖
**GIVEN** 事件 fixture 5 类触发源各至少 1 条
**WHEN** 各 fixture 运行
**THEN** card / time / relationship / flag / kpi_state 5 类各命中 ≥ 1 真实事件;独立断言触发发生
*Cite: Rule 3 / I-1..5*

**AC-FUNC-03** `MVP` 三档密度切换
**GIVEN** density_tier 设 `flash` / `long` / `numeric_only`
**WHEN** 自动验证单日推送事件数
**THEN** 落在 [1,2] / [2,4] / [4,6] 区间;越界 fail
*Cite: Rule 6 / Tuning Knob*

**AC-FUNC-04** `MVP` 模板变量无裸露占位符
**GIVEN** 随机抽 20 条含 `{{npc_name}}` / `{{kpi_label}}` / `{{day}}` 占位符的事件文本
**WHEN** 渲染后断言
**THEN** 不含字符串 `{{` ;裸露占位符 = S2 bug
*Cite: Rule 8 / `tr().format()` / R-EVT-1*

**AC-FUNC-05** `MVP` Cooldown 去重
**GIVEN** 同一事件连续触发
**WHEN** fixture 模拟同日二次触发
**THEN** 第二次被 cooldown 屏蔽;事件队列计数 = 1
*Cite: Rule 11 / F3*

**AC-FUNC-06** `MVP` Blacklist 防重
**GIVEN** 事件标记 played
**WHEN** 候选池查询
**THEN** 已播放事件不在返回集合;断言通过
*Cite: Rule 16 / R-EVT-2 / Edge 8.x*

**AC-FUNC-07** `MVP` 8 NPC 弧覆盖率 100%
**GIVEN** 集成测试运行
**WHEN** 单次完整 run 12 月
**THEN** 全部 8 NPC 弧至少各触发 1 弧内事件;输出弧触发覆盖报告;缺任一弧 = BLOCK
*Cite: Rule 15 / 18 Tier 1 必含*

**AC-FUNC-08** `Beta` Lisa 跳槽线必发
**GIVEN** Lisa 关系 ≤ -3 + Day ≥ 15(满足触发前置)
**WHEN** Playtest 协议连续 3 日
**THEN** Lisa 离职事件链(LISA_RESIGNATION_TALK + LISA_GOODBYE)必至少触发一次;3 日内未触发 = S1 bug
*Cite: Rule 15 / NPC arc / MVP 必发清单*

**AC-FUNC-09** `MVP` 早晨预告命中率
**GIVEN** RNG mock + 1000 次抽样
**WHEN** F2 公式运行
**THEN** 同日命中率落 [60%, 85%];超出 = 公式实现错误
*Cite: F2 / Rule 16 / Tuning Knob MORNING_HIT_BASE*

**AC-FUNC-10** `MVP` 老 NPC 预言触发条件
**GIVEN** Day ≥ 20 + 目标 NPC 关系阈值
**WHEN** fixture 测试
**THEN** 老 NPC 预言事件正确入队;未触发 = S2 bug
*Cite: Rule 17 / kpi_prediction_hint*

**AC-FUNC-11** `MVP` Choice 分支写入 flag
**GIVEN** 玩家选任意分支
**WHEN** fixture 选择后断言
**THEN** 所有 `consequence_flags` 已写入 EventFlagStore;flag store 状态正确
*Cite: Rule 10 + Rule 9 effect.flag*

**AC-FUNC-12** `Beta` 漏事件补发
**GIVEN** 当日队列耗尽 + `missed_event_quota > 0`
**WHEN** 下一触发窗口
**THEN** 补发对应数量漏事件;计数正确
*Cite: F4 / `#7 ap_early_leave_taken`*

### AC-PERF

**AC-PERF-01** `MVP` 候选池查询 ≤ 1ms
**GIVEN** GUT benchmark + 200 事件候选池
**WHEN** 100 次 `EventPool.query()` p95
**THEN** 每次 ≤ 1ms;超出 = 性能回归
*Cite: Rule 20 / 三层 Dictionary 索引*

**AC-PERF-02** `MVP` 文本加载 ≤ 100ms
**GIVEN** 单个最大事件文本文件(全分支文本)
**WHEN** GUT time_source mock
**THEN** 加载耗时 ≤ 100ms
*Cite: Rule 20 / `tr()` 按需加载*

**AC-PERF-03** `MVP` 事件 dispatch ≤ 1 帧
**GIVEN** `EventBus.emit()` 到 UI 展示信号
**WHEN** 集成测试帧计数
**THEN** 不跨任何 await/yield;dispatch_latency = 0 额外帧
*Cite: Rule 20 / Pillar P5 / `#3 Loc Rule 5` dispatch ≤1帧*

### AC-COMPAT(7 系统双向契约)

**AC-COMPAT-01** `MVP` `#6 Scene & Day Flow` 双向
**GIVEN/WHEN/THEN**: 订阅 `scene_state_changed`;emit `event_started/completed` 供 `#6` 时间推进;Day End 通知 `events_cleared` 信号
*Cite: I-1*

**AC-COMPAT-02** `MVP` `#7 AP Economy` 双向
**GIVEN/WHEN/THEN**: 订阅 `ap_early_leave_taken`(F4 漏事件);emit `inject_predicted_ap_demand` 早晨预告
*Cite: I-2 / F4 / Rule 16*

**AC-COMPAT-03** `MVP` `#8 NPC Relationship` 双向
**GIVEN/WHEN/THEN**: 写入关系变化通过 `update_relationship`;`relationship_changed` 后作为触发源
*Cite: I-3*

**AC-COMPAT-04** `MVP` `#9 KPI System` 订阅
**GIVEN/WHEN/THEN**: 订阅 `dismissal_triggered` + `kpi_prediction_hint(4 档)` + `game_over_triggered`;`#10` 不持有 `#9` 引用
*Cite: I-4 / Rule 17 三轨*

**AC-COMPAT-05** `MVP` `#11 Action Card` 订阅
**GIVEN/WHEN/THEN**: 订阅 `card_played(card_id)`;trigger.type=card 检索;集成测试卡触发事件链路
*Cite: I-5*

**AC-COMPAT-06** `MVP` `#12 Run Meta` emit
**GIVEN/WHEN/THEN**: effect `run_meta_unlock(content_id)` 注入;GAME OVER 词条收集
*Cite: I-6 / Rule 9 effect.run_meta_unlock*

**AC-COMPAT-07** `MVP` `#14 Card Play UI` emit + `#1 Save System` 写
**GIVEN/WHEN/THEN**: emit `event_started(event_id, narrative_tier)` 给 `#14`(UI own);`event_history` / `cooldown_map` / `flag_dict` / `morning_blacklist` 序列化至 Save;reload 后状态完整
*Cite: I-8 + I-9 / Rule 21 持久化 / R-EVT-2*

### AC-ROBUST(对应 R-EVT-1..5)

**AC-ROBUST-01** `MVP` `R-EVT-1` Schema 错引(NPC/flag/scene 注册表 diff)
**GIVEN** 人工注入 broken `npc_id` / `flag_key` / `scene_id`
**WHEN** CI lint 运行
**THEN** lint 报告 BLOCK + 行号 + 提示替代 key;PR 拒绝合并
*Cite: Rule 13 / Edge 10.1 / R-EVT-1*

**AC-ROBUST-02** `MVP` `R-EVT-2` 早晨预告 blacklist 持久化
**GIVEN** Save 加载失败 fixture(blacklist 归空)
**WHEN** 次日 MORNING_BRIEFING
**THEN** blacklist 归空时接受重复预告(降级);`#1 Rule 2` autosave retry 守门;**跨 GDD 同 R-AP-4**(`#7` blacklist 持久化)
*Cite: Edge 8.1 / R-EVT-2 / R-AP-4*

**AC-ROBUST-03** `MVP` `R-EVT-3` 触发源 race + cooldown 漏触发
**GIVEN** 模拟同帧 10 个 `card_played` 信号
**WHEN** EventScriptEngine 处理
**THEN** 仅 1 事件进 `EVENT_ACTIVE`,其余排队或被 cooldown 拦截;玩家无法"刷"事件
*Cite: Rule 20 / F3 / R-EVT-3 / Edge 2.1*

**AC-ROBUST-04** `MVP` `R-EVT-4` 嵌套循环引用
**GIVEN** 构造 A→B→A 事件链
**WHEN** lint DFS 环检测
**THEN** lint 报告 BLOCK + 输出环路径;运行时若漏检 depth 计数器 ≤ 2 截断 + push_error
*Cite: Rule 5 / Edge 3.1 / R-EVT-4*

**AC-ROBUST-05** `MVP` `R-EVT-5` 三档密度 fallback 缺失
**GIVEN** 玩家设 `flash` 但事件只有 `long` variant
**WHEN** 事件触发
**THEN** fallback 自动选 `long` + push_warning;不 BLOCK 流程;lint 检查每事件 ≥ 1 个 narrative_tier 与 variants tier 匹配
*Cite: Rule 6 + Rule 11 / Edge 11.1 / R-EVT-5*

### AC-TONE

**AC-TONE-01** `MVP` 主语翻转 lint 覆盖 EVENT.* keys
**GIVEN** `subject_inversion_lint.py` 扩展扫 EVENT.* + NPC.* + AP/ENERGY + KPI/EFFORT/TENURE + IRONY 五域同源
**WHEN** CI 运行
**THEN** 含主语翻转错误条目标记;writer 逐条修复方可合并
*Cite: Rule 19 / Edge 12.1*

**AC-TONE-02** `MVP` Pillar 4 反英雄 + 朋友圈测试
**GIVEN** writer + creative-director 联署 review checklist
**WHEN** 每事件文本提交前
**THEN** 通过"25-35 岁白领朋友圈不尴尬"测试;含英雄主义 / 大道理 / 说教 = 重写;sign-off 落 `production/qa/evidence/event-tone-signoff-[sprint].md`
*Cite: Pillar P4 / Rule 19 / 朋友圈测试 narrative-director 锁*

**AC-TONE-03** `Beta` 三档密度 fallback tone 一致
**GIVEN** density_tier 降级(HIGH→MID→LOW)触发
**WHEN** QA 抽查 3 条 fallback 事件文本
**THEN** fallback 文本仍通过 AC-TONE-02 朋友圈测试;记录结果
*Cite: Rule 6 / Edge 11.1 / R-EVT-5*

---

### Tier 分级

| Tier | 数量 |
|------|------|
| MVP 必测 | 25 |
| Beta(playtest)| 5 |

### QA 工具需求

| 工具 | 守门 AC |
|------|---------|
| Schema lint(npc/flag/scene 引用)| AC-FUNC-01 / AC-ROBUST-01 |
| 5 类触发 fixture | AC-FUNC-02 |
| 三档密度切换 fixture | AC-FUNC-03 / AC-TONE-03 / AC-ROBUST-05 |
| RNG mock + 权重抽取 | AC-FUNC-09 / AC-PERF-01 |
| Cooldown 持久化 fixture | AC-FUNC-05 |
| Blacklist 防重 fixture(R-EVT-2 + R-AP-4 跨 GDD)| AC-FUNC-06 / AC-ROBUST-02 |
| Lisa 跳槽线 playtest 协议 | AC-FUNC-08 |
| `subject_inversion_lint.py` 扩展 EVENT.* | AC-TONE-01 |
| 朋友圈测试 review checklist | AC-TONE-02 / AC-TONE-03 |
| 嵌套场景循环引用静态检测(DFS 环) | AC-ROBUST-04 |
| 7 系统集成测试 | AC-COMPAT-01..07 |

## Open Questions

8 OQ-EVT + 5 propagation flags(详 Section F)。

**OQ-EVT-01 (Pre-Production)**: writer team 编写 18 Tier 1 必含手写 + 80 模板化分布(narrative-director 锁定)— 实际生产周期 + 朋友圈测试通过率。Owner: writer + narrative-director + creative-director。Target: `/team-narrative` Pre-Production 阶段。

**OQ-EVT-02 (待 `#14 Card Play UI` GDD)**: 三档密度差异化 UI 渲染细节(flash overlay 位置 / long 立绘+对白 layout / numeric_only HUD only)。Owner: ux-designer + `#14` 主笔。Target: `/design-system #14` + `/ux-design event-dialogue-screen.md`。

**OQ-EVT-03 (Pre-Production /prototype)**: F1/F2/F3/F4 公式实测调优 — RNG fairness + 玩家"刷事件"行为分析。Owner: economy-designer + qa-tester。Target: `/prototype core-loop`。

**OQ-EVT-04 (待 `#16 KPI Review UI` GDD)**: GAMEOVER.CERTIFICATE.[reason] 离职证明文本嵌入 UI 集成。Owner: writer + ux-designer + `#16` 主笔。Target: `/design-system #16`。

**OQ-EVT-05 (Polish)**: blacklist 7 天滑动窗口 + WEEKLY_DIFFERENCE_GUARANTEE 5 天阈值实证。Owner: qa-tester。Target: Polish 阶段。
- 玩家"被坑"频次 ≤ 3 次/周(过密 → 算法在坑) / ≥ 1 次/周(过疏 → A4+A7 反模式)

**OQ-EVT-06 (待 `#11 Action Card` GDD)**: Hero/Overage 卡 `is_hero` flag 与 `#7 effort_norm` 三维加成对应关系 — 触发 `effort_overage_count` 回调机制。Owner: `#11` 主笔 + `#9` 主笔。Target: `/design-system #11`。

**OQ-EVT-07 (野心版 ADR)**: 多公司类型事件池(国企 / 大厂 / 外企)的 schema 扩展。Owner: narrative-director + `#10` 主笔。Target: 野心版 ADR。

**OQ-EVT-08 (Polish)**: NPC LEFT 后 `display_name_static` fallback 在跨局延续中的 tone 一致性 — 玩家 reload 后看到 LEFT NPC 出现在叙事中是否突兀。Owner: writer + qa-tester。Target: Polish playtest。

### 5 propagation flags 状态

| # | 待 GDD | 状态 |
|---|--------|------|
| 1 | `#11 Action Card` `card_played` 协议 + Hero flag | OQ-EVT-06 |
| 2 | `#12 Run Meta` `run_meta_unlock` + 词条收集 schema | ⏳ |
| 3 | `#14 Card Play UI` 三档密度渲染契约 | OQ-EVT-02 |
| 4 | `#16 KPI Review UI` 离职证明文本 UI | OQ-EVT-04 |
| 5 | writer team 18 Tier 1 + 80 模板 + 朋友圈测试 | OQ-EVT-01 |
