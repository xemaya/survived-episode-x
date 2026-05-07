# Action Card System

> **Status**: Designed (pending review)
> **Author**: huanghaibin + game-designer (Section B+C+D+E 主笔)
> **Last Updated**: 2026-04-27
> **Authoring autonomy mode**: v2 no-prompt(0 widget,cross-GDD 全量读取 #7/#8/#9/#10)
> **Layer**: Feature | **Order**: #11 | **Size**: M
> **Implements Pillar**: P1 守(AP cost 分布 40/40/20 锁 + Hero/Overage 反英雄红线)+ P2 守(每张卡包剧本由 `#10` own)+ P5 守(地铁 90s 一天 4 张卡)+ P3 守(卡触发 NPC 离职 + GAME OVER)

## Overview

**Action Card System** 是《活过第 X 集》玩家每日决策的直接接触面 —— Pillar 1"平庸是一种艺术"的**操作层载体**。MVP 30-40 张卡,每张卡消耗 1/2/3 AP(分布 40/40/20,`#7 propagation flag #3` 强制 lint),触发 `#10 Event Script Engine` 的 `card` 类型触发器,并向 `#7`(`try_consume_ap` + Hero 回调)/ `#8`(`update_relationship`)/ `#9`(`kpi_contribution_reported`)三系统同步状态。卡 schema 是 `#10 Event Schema` 的子集(Schema A 扁平式),含 `card_id / ap_cost / is_hero / npc_target / cooldown / mutex_group / unlock_condition / kpi_contribution / effects / event_id_link`。本 GDD owns 卡 schema + 打卡引擎 + API 调用序列。**UI own by `#14 Card Play & Dialogue UI`**。**NPC 文本 + 事件对白 own by `#10`**。卡解锁由 `#10` 事件驱动,本 GDD 不直接 unlock。`mutex_group` 机制防 A2 最优卡闭包(同日同组只能打一张),4 态状态机(IDLE / PLAYABLE / DISABLED / PLAYED)管理卡可交互性,4 [RISK GUARD](R-AC-1..4)覆盖 AP 分布 lint / Hero 权重 / LEFT NPC 守门 / Pillar 1 永久 buff 红线。

## Player Fantasy

> **Framing**: Direct — 玩家亲手打牌,每张卡是主动决策,非 Indirect 叙事旁观。
> **主锚**: B "我打这张卡是为了它的剧本,不是数字" — 卡选择的 P2 根基
> **副锚**: A "为什么这张卡 AP 这么贵" — 3-AP 决策锚点(L1)
> *注: 候选 C "这张'帮 Lisa'卡打过 5 次,但每次都是 1 张赌注" 作为模板变量 + cooldown 的 internal design test 融入两锚,不单独立锚*

### 主锚: "我打这张卡是为了它的剧本,不是数字"

**场景**(玩家时刻):
手牌里并排着两张 2-AP 卡:"日报系统填报"和"问一下 Lisa 进度"。前者 `kpi_contribution = 15`,后者 `kpi_contribution = 8`。你算了一下数字,两秒后抬头,看了看 Lisa 工位方向的空气 —— 点了"问一下 Lisa 进度"。**不是因为数字更大,是因为你记得上次问她的时候她表情有点奇怪**。

**Pillar 服务**:
- **主 P2 叙事即机制**: 每张卡 AP cost 是数字,但卡 text 是剧本 —— 玩家选卡时读的是 `{NPC_NAME}` + 场景描述而非 `kpi_contribution`。卡是 `#10` event schema 的门,不是数值按钮
- **守 P1 平庸是艺术**: "选 KPI 更高的"是显然选择(A2 最优卡闭包反模式),但"为什么选 Lisa"才是游戏要玩家想的。`mutex_group` 机制把同类型的高/低 KPI 卡分组,让"哪一张剧本"比"哪一个数字"更重要
- **守 P5 地铁可玩性**: 4 张卡 4 个决策,每个决策 <15 秒 —— 读的是文案,不是伤害单

**跨 GDD negative space 联动**:
- **AP Economy** "今天又只有 8 格" 共振: 卡不是单独存在的 —— 选 Lisa(2 AP)意味着牺牲另一个 2-AP 卡的剧本机会。机会成本是感知机制,卡 schema 是感知载体
- **NPC** "Lisa 又要跳槽了" 共振: 玩家选"问 Lisa 进度"的深层 motive 是信息 —— 她最近怪怪的。NPC 关系状态决定卡是否灰显,`relationship_score` 变成卡选择的理由而非资源
- **Event Script** "你打过 47 张'回邮件'卡,这次不一样" 共振: 卡 text 的模板变量 `{{NPC_NAME}}` 让第 5 次打"帮 Lisa"时对话仍然不同 —— 剧本不是重复,是变奏

**❌ Tone 风险(必避)**:
- 卡面展示 KPI 数值作为主要视觉元素(违反 A6 装饰化 — 玩家盯数字不读剧本)
- "最优解:这张卡 KPI 最高"类引导文案(违反 P1 反英雄)
- `kpi_contribution` 在卡面大字显示(禁 — 归 `#14` 的视觉权重决策,但本 GDD 明确 Pillar 要求:数字不是第一视觉层级)
- 卡片 UI 进度条/星级评分(违反 P4 — 励志游戏化)

**✅ Tone 守护(推荐)**:
- "帮 Lisa 整理会议纪要(她要求的)"(行为 + 动机 + 括号里的算计)
- 卡 AP 成本格子大,文案做主角,`kpi_contribution` 做备注小字或仅在 Recap 中可见
- 同一卡连续触发时,`{{TASK}}` / `{{SCENARIO}}` 变量变换使文案刷新

### 副锚: "为什么这张卡 AP 这么贵"

**场景**(玩家时刻):
你盯着"跨部门对接"卡 —— 3 AP,占了今天 8 格里的 3 格。旁边两张 1 AP 的"写周报"和"假装在工位"安静地等着你。你数了一下还剩的 5 AP:再打一张 2-AP 的,还能打一张 1-AP。**或者不打这张 3-AP,用 5 格打 2+2+1。但今天不对接,下周还得打**。

**Pillar 服务**:
- **主 P1 平庸是艺术**: 3-AP 卡是 AP 分布 40/40/20 中的"20%" — 稀有,但稀有不等于"更好"。`#7 research L1 AP 成本分布` 锚点:3-AP 卡是决策支点,迫使非均匀打牌,打破"4 张 2-AP = 完美一天"的魔方策略(A1 反模式防护)
- **守 P5 地铁可玩性**: "3-AP 还是 2+1"的决策在 10 秒内完成(不是算法题,是直觉权衡)
- **守 P3 死亡是注定的**: 3-AP 卡"值不值"的判断永远不完全准确(信息不完全度 `#7 Rule 10`),玩家无法精算到最优

**跨 GDD negative space 联动**:
- **AP Economy** Rule 2 + propagation flag #3: `#11` 卡库必须满足 40/40/20 分布 ±5%。3-AP 卡的存在不是随机的 —— 它是全局分布约束的产物
- **KPI** F7 `actual_kpi_m` 累积: 3-AP 卡对应的 `kpi_contribution` 是中高值(设计范围 [12, 30]),但"打了 3-AP 卡 = KPI 月末更高"是 A2 最优卡闭包 —— 靠 `mutex_group` 守门打破

**❌ Tone 风险(必避)**:
- 3-AP 卡有"特殊/精英"视觉标签(违反 P1 平庸 —— 3-AP 卡是负担,不是荣誉)
- AP 消耗动画豪华感(同 `#7 AP Economy Section B` 反英雄红线 —— 花 AP 没有光效)

**✅ Tone 守护(推荐)**:
- 3-AP 卡视觉与 1/2 AP 卡同级 —— 区别只是格子数
- "跨部门对接(需要今天做)" —— 紧迫性文案而非价值文案

### Internal Design Test: 卡不是数值按钮

每张行动卡 + 卡 UI 文案审校时,问一个问题:**"玩家选这张卡是因为数字,还是因为发生了什么?"**

- 如果玩家行为可以用"选 KPI 最高的"完全解释(主语 = 最优算法)→ schema 违反 A2 反模式,需加 `mutex_group` 或 AP cost 重新分配
- 如果玩家行为包含"因为 Lisa / 因为今天 / 因为那个剧本"(主语 = 情境判断)→ 通过

**正例**: 玩家手里 3 张 2-AP 卡,选了 KPI 贡献最低的那张,因为"这张卡有 Lisa 的剧情"
**反例**: 玩家每天自动选 `kpi_contribution` 最高的卡组合(A2 最优卡闭包被实现 — `mutex_group` 失守)

**Design test 隐含的 Pillar 服务**: 本原则是 Anti-Pillar 1(NOT 升职打怪)+ P2(叙事即机制)在卡系统层面的执法。与 `#7` 反英雄红线 / `#6` 主语翻转 / `#8` NPC 算计原则四源同根。所有下游 `#14 Card Play UI` 卡面设计审校时援引此 internal design test。

### 红线汇总

- 任何卡解锁永久 stat buff = **PR-blocking**(Anti-Pillar 1)
- 任何"励志支持型"卡文案 = **PR-blocking**(Anti-Pillar 2)
- 任何 AP 消耗"奖励感"反馈(金光 / 成就感动画)= **PR-blocking**(P1 反英雄)
- 任何"每日最优卡组合推荐"UI 元素 = **PR-blocking**(A2 最优卡闭包)

### Source 引用

`design/research/ap-decision-space-analysis.md` L1 AP 成本分布 / A1 "8=4×2 AP 魔方" / A2 最优卡闭包 / A6 装饰化反模式。`ap-economy-system.md` Section B 反英雄红线 + Rule 2 cost 分布 40/40/20。`npc-relationship-system.md` Section B "Lisa 又要跳槽了" 共振。`event-script-engine.md` Section B "你打过 47 张回邮件卡" 共振。`game-concept.md` Pillar 1+2+3+5 + Anti-Pillar 1+2。

## Detailed Design

> **本节分三部分**: **15 Core Rules**(卡 schema + 行为)+ **States and Transitions**(4 态)+ **Interactions**(7 跨系统契约)
> **所有权边界**: 本 GDD owns 卡 schema + 打卡引擎 + AP/NPC/KPI emit 调用序列。**UI own by `#14 Card Play & Dialogue UI`**。**NPC 文本 + 事件对白 own by `#10 Event Script Engine`**。

### Core Rules

**Rule 1 — Card Schema(派生自 `#10 Event Schema` 子集,Schema A 扁平式)**

每张行动卡存为独立 `.tres` Resource(与 `#10 event` 同生命周期管理)。必填字段:

```gdscript
{
  "card_id": StringName,           # 全局唯一;lint 守门
  "ap_cost": int,                  # ∈ {1, 2, 3}
  "is_hero": bool,                 # true → #7 effort_hero_count 累积(Rule 3)
  "npc_target": NpcId?,            # null = 无 NPC 关联;非 null → LEFT 守门(Rule 8)
  "cooldown": CooldownBlock,       # 同 #10 Rule 11 — days/weeks/once_per_run/never
  "weight": float,                 # [0.1, 100.0] 手牌抽取权重
  "mutex_group": StringName?,      # 同日互斥分组(null = 无互斥,Rule 4)
  "unlock_condition": UnlockBlock?,# null = 默认解锁;non-null 由 #10 event 触发(Rule 5)
  "kpi_contribution": int,         # [1, 30] 月内累积供 #9 F7(Rule 在 Formulas F3)
  "effects": Array[EffectBlock],   # 继承 #10 Rule 9 effect 原子类型子集(Rule 7)
  "event_id_link": StringName?,    # 可选 — 打卡后注入 #10 候选池(spawn_event effect)
  "schema_version": int            # 当前 = 1
}
```

`text_key`: 卡文案 Localization key。`{{NPC_NAME}}` / `{{TASK}}` / `{{SCENARIO}}` 模板变量(与 `#10 Rule 8` 同 slot 约束)。**模板变量注入由 `#10` runtime 执行;本 GDD 不持原始字符串**。

CI lint(`tools/card_lint.gd`)阻塞:
- `card_id` 全局唯一
- `ap_cost ∈ {1, 2, 3}`
- `npc_target ∈ #8 NpcId 注册表 ∪ {null}`
- `kpi_contribution ∈ [1, 30]`
- `text_key ⊂ Localization key 注册表`

---

**Rule 2 — AP Cost 分布 40/40/20(强制 lint — `#7 propagation flag #3`)**

MVP 30-40 张卡库必须满足:

| AP Cost | 目标比例 | 容忍范围 | MVP 30 张例 |
|---------|---------|---------|------------|
| 1 AP    | 40%     | [35%, 45%] | 12 张 |
| 2 AP    | 40%     | [35%, 45%] | 12 张 |
| 3 AP    | 20%     | [15%, 25%] | 6 张 |

`tools/card_lint.gd` 在 CI 阶段计算全卡库 AP 分布;**违反容忍范围时 BLOCK PR**。

锚点逻辑(from `#7 Rule 2 + research L1`): 平均 `avg_cost = 1×0.40 + 2×0.40 + 3×0.20 = 1.80 AP/卡` → 8 AP/天 ≈ 4.4 张卡 → P5 守门(90s 一天 4 张卡节奏)。3-AP 卡是决策支点,防 A1 反模式(8=4×2 AP 魔方)。

**[RISK GUARD] R-AP-AC1**: 分布 lint 失效 → AP cost 趋同 → 决策等权(所有卡感觉相同)→ A1 反模式实现 + P1 失守。

---

**Rule 3 — Hero 卡 `is_hero` flag 与 `#7` effort_hero_count 连接**

`is_hero: true` 的卡打出后,`#11` 调 `APEconomy.report_hero_card_played(card_id)`:

```gdscript
# 打卡成功后序(Rule 7 emit 序列第 2 步)
if card_data.is_hero:
    APEconomy.report_hero_card_played(card_id)
    # → #7 emit effort_hero_incremented(card_id, day, total)
    # → #7 月末 effort_norm 公式 hero_count 维度 (权重 0.20)
```

**Hero 卡设计约束**:
- MVP 中 Hero 卡占比建议 ≤ 20%(6-8 张),与 3-AP 卡重叠但不强制绑定
- Hero 卡**不是"优越卡"** —— `is_hero` 只是额外的 effort 信号,会加速下月 KPI 涨阈值(P1 反英雄)
- Hero 卡 `kpi_contribution` 不得高于同类非 Hero 卡的 1.5 倍(防 A2 最优卡闭包 + Hero 路线)
- Hero 卡文案必须**隐含过度付出的荒诞感**,禁"英雄/主动/闪耀"语义(P1 + P4 守门)

**[RISK GUARD] R-AC-2**: `is_hero` flag 与 `#7 Rule 6 effort_hero_count` 权重 0.20 不一致(系数不同步)→ 月末 `effort_norm` 错算 → KPI 涨幅数学错位。

---

**Rule 4 — 互斥分组(`mutex_group`)— 防 A2 最优卡闭包**

`mutex_group: StringName?`。同日(`ACTION_DAY` 或 `ACTION_OVERTIME`)内,同一 `mutex_group` 的卡只能打其中一张:

- **打出第一张**: 同 group 其余卡立即变 DISABLED 态(Rule 10 States)
- **日末 reset**: 次日 `MORNING_BRIEFING → ACTION_DAY` 时 DISABLED 解除
- **跨日持续**的 mutex 不存在 —— mutex 是日内互斥,不是 Run 内互斥
- `mutex_group = null`:无约束(单卡可每日打)

**设计意图**: 同一"工作类别"的高/低 KPI 变体卡用同 `mutex_group`,玩家每日只能选其中一种表达形式,不能两种都打 —— 强制"选择就是放弃",防止"KPI 最高的全都要"。

**同帧多卡同分组的 race condition**: 见 Edge Cases Cat 5。

---

**Rule 5 — Unlock 条件(由 `#10` 事件驱动,本 GDD 不直接 unlock)**

卡的 `unlock_condition` 字段定义解锁前置:

| 条件类型 | 字段 | 示例 |
|---------|------|------|
| 关系阈值 | `npc_id + min_score` | `LISA.score >= 30` |
| flag | `flag_key + value` | `lisa_offered_coffee == true` |
| 月份 | `min_month` | `month_index >= 3` |
| 无条件 | `unlock_condition = null` | 默认可见 |

**unlock 触发方**: `#10 Event Script Engine` 在阈值事件发生时 emit `card_unlocked(card_id)` → `#11` 将该卡加入手牌池。**本 GDD 不直接调用 unlock** — 由 `#10` 事件驱动(解耦)。

卡在 unlock 前: DISABLED 态 + 对玩家**不可见**(不灰显,直接隐藏 — 避免"还差多少"收集感,违反 P4)。

---

**Rule 6 — `try_consume_ap` 调用协议 + 失败 UI 反馈**

玩家选卡后,`#11` 先调 AP 守门:

```gdscript
func _on_card_selected(card_id: StringName) -> void:
    var card = _card_registry.get(card_id)
    # 1. NPC LEFT 守门(Rule 8 先行)
    if card.npc_target != null and NpcRelationship.get_npc_state(card.npc_target) == NpcState.LEFT:
        return  # 卡已灰显,此处为双重保险
    # 2. mutex_group 守门(Rule 4)
    if card.mutex_group and _mutex_played_today.has(card.mutex_group):
        return  # 同分组已打
    # 3. AP 消耗
    if not APEconomy.try_consume_ap(card.ap_cost):
        # 失败 → UI 反馈由 #14 处理
        emit card_play_failed(card_id, "INSUFFICIENT_AP")
        return
    # 4. 成功 → emit 序列(Rule 7)
    _execute_card(card)
```

失败反馈: emit `card_play_failed(card_id, reason: String)` → `#14 Card Play UI` 执行灰显 / toast 提示(UI 逻辑 own by `#14`,本 GDD 仅 emit)。

---

**Rule 7 — 打卡成功后的 emit + API 调用顺序(原子操作)**

`_execute_card(card)` 内严格顺序:

```
1. emit card_played(card_id)                    → #10 trigger.type=card 检索
2. if is_hero: APEconomy.report_hero_card_played(card_id)  → #7 hero_count ++
3. emit kpi_contribution_reported(card.kpi_contribution)   → #9 F7 actual_kpi_m 累加
4. if npc_target != null:
     NpcRelationship.update_relationship(npc_target, delta, card_id)  → #8 score 更新
5. _mutex_played_today[card.mutex_group] = card_id  (if mutex_group non-null)
6. _cooldown_map[card_id] = current_day + cooldown_days
7. _history.append(card_id)
8. APEconomy.try_consume_ap 已在 Rule 6 完成(不再重复调用)
```

**顺序不可打乱**:
- 步骤 1(`card_played`)先于步骤 3(`kpi_contribution_reported`) — `#10` 可能在 `card_played` handler 里注入新事件修改后续 `kpi_contribution`,但 `#9` F7 的累积需要在 event resolve 后 —— MVP 简化:steps 1-7 同帧顺序执行,`#10` event 在步骤 1 触发后**排队**,在本卡完整执行后才运行(禁止嵌套打卡)
- 步骤 4(`update_relationship`)在步骤 1(`card_played`)之后 — `#10` 可订阅 `card_played` 先做叙事事件,再由 `#11 step 4` 更新 NPC 关系数值(叙事先于数值,Pillar 2 守门)

---

**Rule 8 — NPC LEFT 状态守门**

打卡前检查(Rule 6 步骤 1):

```gdscript
# #11 只需调接口,不需要持有 #8 的内部状态
if NpcRelationship.get_npc_state(card.npc_target) == NpcState.LEFT:
    # 卡 → DISABLED 态
    # #14 Card Play UI 显示该卡灰色(视觉 own by #14,trigger by #11 state query)
    return
```

`#8 get_npc_state(npc_id: NpcId) -> NpcState`:`ACTIVE` / `LEAVING_ANNOUNCED` / `LEFT` / `RETURNED`(VS)。

**`LEFT` NPC 的卡**: 卡不从手牌池移除(保留历史),但每次手牌刷新时 `#11` 重新 query 状态 → DISABLED。玩家可见灰显卡但无法打出,无 tooltip 解释(沉默式守门,P4 黑色幽默)。

**[RISK GUARD] R-AC-3**: `get_npc_state` 查询漏调 → 玩家对 LEFT NPC 打卡 → `update_relationship` API 调用 LEFT NPC → `#8` 应拒绝(#8 内部守门) + `#11` push_error。两层防护。

---

**Rule 9 — Cooldown 协议(继承 `#10 Rule 11`)**

4 类 cooldown,与 `#10` 同 schema:

| 类型 | 行为 | 典型用途 |
|------|------|---------|
| `days: N` | N 日后可再打 | 周期性任务卡 |
| `weeks: N` | N×7 日后可再打 | 月度/季度事件卡 |
| `once_per_run` | 本 Run 只能打一次 | 离职前关键节点卡 |
| `never` | 每日可打,无限制 | 日常卡(日报/假装在工位) |

Cooldown 写入 `Save Rule 6` snapshot,跨日、跨 session 持久化。`once_per_run` 的"run"边界 = 当前 GAME OVER 前的完整 Run,不跨 GAME OVER 重置。

灰显触发: 手牌刷新时 `#11` 计算 `current_day - last_played_day >= cooldown_days`;未满足 → DISABLED + 显示剩余天数(视觉 own by `#14`,数据 own by `#11`)。

---

**Rule 10 — 模板变量(`{{NPC_NAME}}` 等)与 LEFT NPC fallback**

卡 `text_key` 中的模板变量 slot 类型(继承 `#10 Rule 8`):

| 变量 | 类型约束 | LEFT NPC fallback |
|------|---------|-------------------|
| `{{NPC_NAME}}` | ACTIVE NpcId | `display_name_static`(Save 持久化离职前最后名字)— 见 Edge Cat 6 |
| `{{TASK}}` | Localization key | 无 fallback — lint 守门必须非 null |
| `{{SCENARIO}}` | Localization key | 可选,null → 插槽省略 |
| `{{MONTH}}` | int [1,12] | 直接注入 |

注入实现委托 `#10 Event Script` 同一 `tr(loc_key).format(context_dict)` 路径。**本 GDD 不持有文本字符串**。

---

**Rule 11 — Pillar 1 红线: 卡 effect 仅短期,禁永久 stat buff**

卡 `effects` 数组允许的 effect 类型(继承 `#10 Rule 9` 原子 7 类的子集):

| 允许 | 禁止 |
|------|------|
| `relationship delta` (≤ ±10/卡,F2 守门) | 任何 `BASE_AP_PER_DAY` / `MAX_ENERGY` 永久增加 |
| `kpi_contribution` 月内累积(F3) | 任何"KPI 阈值降低"(`#9` 会拒绝 + push_error) |
| `flag set/clear` (per-NPC or global) | 任何"永久 buff 道具解锁" |
| `spawn_event` (注入 #10 候选池) | 任何"成就里程碑 + stat 奖励" |
| `energy delta` (单次 ±15 上限,`#7 Rule 7`) | 任何数值跨 Run 持久的永久变化 |

**[RISK GUARD] R-AC-4**: 卡 effect 写入 `永久 buff` → lint 应 BLOCK(`tools/card_lint.gd` 静态检查 effect type)。漏检场景见 Edge Cat 8。

---

**Rule 12 — Pillar 4 红线: 禁"励志支持型"卡文案**

卡 `text_key` 对应的 Localization 文案 + 选项标签须通过 `subject_inversion_lint.py --domain CARD`:

- **禁**: "Lisa 鼓励你继续加油!" / "你今天超棒!" / "成功完成任务,+KPI!"
- **禁**: 任何 NPC 行为以"帮助玩家"为动机(NPC 算计原则)
- **禁**: 卡打出后正向音效/金光(AP Economy 反英雄红线)
- **要求**: NPC 台词保持 NPC 自身立场和算计(`#8 Section B NPC 算计原则`)
- **要求**: 卡完成反馈为中性或反讽(同 `#7 Rule 13` 主语翻转)

---

**Rule 13 — 信号架构清单**

**Emit(`#11 Action Card` → 外部)**:

| 信号 | 参数 | 接收者 | 触发时机 |
|------|------|--------|---------|
| `card_played(card_id)` | `StringName` | `#10`(trigger.type=card 检索)/ `#13 HUD`(手牌区更新) | 打卡成功(Rule 7 step 1) |
| `kpi_contribution_reported(amount)` | `int` | `#9 F7 actual_kpi_m 累积` | 打卡成功(Rule 7 step 3) |
| `card_play_failed(card_id, reason)` | `StringName, String` | `#14 Card Play UI` | AP 不足 / LEFT NPC / mutex 已锁 |
| `card_unlocked(card_id)` | `StringName` | `#13 HUD`(手牌新增提示)/ `#14` | `#10` 驱动后本系统 relay(Rule 5) |

**API(外部 → `#11`)**:

| API | 调用方 | 行为 |
|-----|--------|------|
| `report_hero_card_played(card_id)` | 内部(Rule 7 step 2)→ `#7` | `#7.hero_card_played_this_month ++` |
| `get_card_state(card_id)` | `#14 Card Play UI` | 返回 `CardState` enum |
| `get_hand_cards()` | `#14 Card Play UI` | 返回当前手牌 `Array[CardData]` |

**订阅(`#11` ← 外部)**:

| 信号源 | 信号 | 处理 |
|-------|------|------|
| `#6` | `scene_state_changed(from, to)` | MORNING_BRIEFING 时刷新手牌 / AP 日重置后 mutex 清除 |
| `#8` | `npc_left_company(npc_id)` | 将该 NPC 相关卡置 DISABLED |
| `#10` | `card_unlocked(card_id)` | 将卡加入手牌池 |

---

**Rule 14 — Save 持久化**

```gdscript
card_state = {
  "played_history": Array[StringName],   # 已打卡 history(按日/月)
  "cooldown_map": Dict[StringName, int], # card_id → 解锁日期(绝对 day index)
  "mutex_played_today": Dict[StringName, StringName], # group → card_id
  "unlocked_cards": Array[StringName]    # 已解锁卡 id 列表
}
```

归 `#11` sub-schema,写入 `current_run.save`(Save Rule 6 snapshot)。日末 `mutex_played_today` 清空(不跨日持久)。

---

**Rule 15 — Scope Tier**

| Tier | 卡库总量 | 要求 |
|------|---------|------|
| **MVP** | 30-40 张 | 18 NPC 弧覆盖(同 `#10 Rule 15` Tier 1)+ AP 分布 40/40/20 |
| **VS** | 60+ 张 | NPC 支线拓展 + 季度事件卡 + RETURNED NPC 专属卡 |
| **野心版** | 100+ 张 | 多公司类型 + 跨部门卡 + 动态 mutex_group |

### States and Transitions

每张卡处于以下 4 态之一(per-card,手牌刷新时全量 eval):

| 状态 | 含义 | 进入条件 |
|------|------|---------|
| `IDLE` | 可选可打,手牌正常显示 | 默认;cooldown 满足 + NPC 非 LEFT + AP 充足时 |
| `PLAYABLE` | 同 IDLE,玩家聚焦此卡时高亮 | `IDLE` + 玩家选中(由 `#14` 触发,视觉 state) |
| `DISABLED` | 灰显不可交互 | AP 不足 / cooldown 中 / mutex 已锁 / NPC LEFT / 未 unlock |
| `PLAYED` | 已打出(当日不可再打,若 cooldown=never 次日重置为 IDLE) | `_execute_card` 完成后 |

**状态转移**:

```
IDLE ──[玩家选中]──► PLAYABLE ──[确认打卡]──► [AP check]
                                              ├─ 成功 ──► PLAYED
                                              └─ 失败 ──► DISABLED(AP不足)

IDLE ──[手牌刷新时 NPC LEFT]──► DISABLED
IDLE ──[手牌刷新时 cooldown 未满]──► DISABLED
PLAYED ──[次日 MORNING_BRIEFING]──► IDLE(若 cooldown=never)
PLAYED ──[次日 MORNING_BRIEFING]──► DISABLED(若 cooldown>0 且未到期)
```

**DISABLED → IDLE 的解锁**:
- AP 补充:次次 AP 变化时实时 re-eval(玩家早退后 AP 不变故不解锁)
- cooldown 到期:`MORNING_BRIEFING` 手牌刷新时
- NPC 状态改变:MVP 中 LEFT 不可逆,故 NPC LEFT 触发的 DISABLED 是永久的(VS RETURNED 除外)
- mutex 解除:次日手牌刷新时 `mutex_played_today` 清空

### Interactions with Other Systems

| # | 对端 | 方向 | 主接口 | 触发时机 |
|---|------|------|--------|---------|
| I-1 | `#7 AP Economy` | 双向 | `try_consume_ap(amount)` API(消耗);`report_hero_card_played` callback | 打卡时 |
| I-2 | `#8 NPC Relationship` | 双向 | `update_relationship(npc, delta, card_id)` API(写入);`get_npc_state(npc_id)` query(守门) | 打卡后(Rule 7 step 4);手牌刷新 |
| I-3 | `#9 KPI System` | emit | `kpi_contribution_reported(amount)` → `#9 F7 actual_kpi_m 累积`;订阅 `report_overage(card_id, kpi_delta)` 回调 | 打卡后(Rule 7 step 3) |
| I-4 | `#10 Event Script Engine` | 双向 | emit `card_played(card_id)` → trigger.type=card;订阅 `card_unlocked(card_id)` | 打卡后;#10 阈值事件驱动 |
| I-5 | `#6 Scene & Day Flow` | 订阅 | 订阅 `scene_state_changed` — MORNING_BRIEFING 刷新手牌 + mutex 清空 | 每日开始 |
| I-6 | `#13 HUD Diegetic` | emit | `card_played` → HUD 手牌区更新;`card_unlocked` → 新卡提示 | 打卡 / 解锁 |
| I-7 | `#14 Card Play UI` | emit + query | `card_play_failed` → 灰显 / toast;`get_hand_cards()` / `get_card_state()` query | 交互全程 |

## Formulas

> 本节 3 公式: F1 AP 分布校验 + F2 NPC 关系 delta 范围 + F3 KPI contribution 范围。
> F4+ 数学在 `#7`(effort) / `#9`(KPI 公式) / `#10`(候选池权重)own,本 GDD 仅引用结果。

### F1 — AP Cost 分布校验(40/40/20 ± 5% 容忍)

```
let N = total card count in MVP card library
let n1 = count(cards where ap_cost == 1)
let n2 = count(cards where ap_cost == 2)
let n3 = count(cards where ap_cost == 3)

r1 = n1 / N    # 目标 0.40 ± 0.05  → [0.35, 0.45]
r2 = n2 / N    # 目标 0.40 ± 0.05  → [0.35, 0.45]
r3 = n3 / N    # 目标 0.20 ± 0.05  → [0.15, 0.25]

PASS condition:
  r1 ∈ [0.35, 0.45]  AND
  r2 ∈ [0.35, 0.45]  AND
  r3 ∈ [0.15, 0.25]
```

| Var | Type | Range | Description |
|-----|------|-------|-------------|
| `N` | int | [30, 40] MVP | 全卡库卡数 |
| `n1/n2/n3` | int | [0, N] | 各 AP cost 卡数 |
| `r1/r2/r3` | float | [0, 1] | 比例 |
| `avg_cost` | float | 期望 1.80 | `1×r1 + 2×r2 + 3×r3` |

**Worked Example(N=36)**: n1=13, n2=14, n3=9 → r1=0.361(✓), r2=0.389(✓), r3=0.250(✓); avg_cost=1.89 — PASS。
**Fail Example(N=36)**: n1=8, n2=20, n3=8 → r1=0.222(**FAIL** < 0.35), r2=0.556(**FAIL** > 0.45) — BLOCK PR。

`tools/card_lint.gd` 在 CI 阶段强制计算并输出 PASS/FAIL report。**FAIL = PR-blocking**。

---

### F2 — 单卡 NPC 关系 delta 范围([−10, +10] per card)

```
delta_clamp = clamp(card.npc_relationship_delta, -10, +10)
```

| Var | Type | Range | Description |
|-----|------|-------|-------------|
| `card.npc_relationship_delta` | int | schema 字段 | 打卡后 NPC score 变化量 |
| `delta_clamp` | int | [-10, +10] | 传入 `#8 update_relationship(npc, delta_clamp, ...)` |

**设计意图**: 防单卡造成关系失衡。`#8 Rule 2` 的 score 范围是 [-100, +100];若单卡 delta = ±30 可在 3-4 次打卡内满槽(违反 P2 — 关系应是积累,不是速刷)。

**Lint 守门**: `tools/card_lint.gd` 同时校验 `|npc_relationship_delta| <= 10`;超限 BLOCK PR。

**Worked Example**: 卡 `CHAT_LISA_COFFEE` 打出 → delta = +4 → `update_relationship(LISA, 4, "CHAT_LISA_COFFEE")` → Lisa score 从 +22 变 +26(未跨 NEUTRAL→WARM 阈值,不 emit phase_changed)。

---

### F3 — 单卡 `kpi_contribution` 范围([1, 30] points,中位 8.5)

```
kpi_contribution ∈ [1, 30]          # schema 字段约束
median_target = 8.5                  # MVP 卡库中位数目标
monthly_kpi_approx = Σ(kpi_contribution_i, i=played cards in month m)
                   ≈ 4.4 cards/day × avg_kpi × 22 work_days
                   ≈ 4.4 × 8.5 × 22 ≈ 823 points/month
```

| Var | Type | Range | Description |
|-----|------|-------|-------------|
| `kpi_contribution` | int | [1, 30] | 单卡 KPI 贡献点数(累积至 `#9 F7 actual_kpi_m`) |
| `median_target` | float | ~8.5 | MVP 卡库设计中位值(与 `#9 F7 monthly_threshold=100` 量纲对齐) |
| `monthly_kpi_approx` | int | ~750-900 | 标准月内总 KPI 贡献估算 |

**与 `#9` 量纲对齐检查**: `#9 Rule 1 KPI_BASE_MONTH_1 = 100`(threshold 初始值)。若月均 KPI ≈ 823 points,则 `actual_kpi_m / monthly_threshold` = 823/100 ≈ 8.23(即完成率 823%?)—— **注意**: `#9 F2 potential` 公式分子是 `actual_kpi_m - monthly_threshold`,不是百分比。`actual_kpi_m` 和 `monthly_threshold` 须**同一量纲**。

**量纲对齐待验证**: `#9 F7 actual_kpi_m` 的单位 = 本 GDD `kpi_contribution` 点数之和。`monthly_threshold = 100` 单位需与此对齐(即: threshold=100 表示"月均需要打满 ≈ 11-12 张有贡献卡")。**Open Question OQ-AC-01**: 若 `kpi_contribution` 中位值 8.5 × 4.4卡/天 × 22天 ≈ 823,则 threshold=100 意味着 F2 potential 几乎恒为正值 —— 需要 `#9 GDD` 作者确认 `actual_kpi_m` 和 `monthly_threshold` 的量纲是否已归一化处理(如 threshold 实际是 850 而非 100,或 kpi_contribution 是比率而非绝对值)。**本 GDD 锁定范围 [1, 30] + 中位 8.5 为 default;待 #9 审校后同步调整**。

**Lint 守门**: `tools/card_lint.gd` 校验 `1 <= kpi_contribution <= 30`;超限 BLOCK PR。

## Edge Cases

> 25 edges / 8 categories / 4 [RISK GUARD] R-AC-1..4

### Cat 1 — AP Cost 边界

**Edge 1.1 `amount = 0`**: `try_consume_ap(0)` 被调用 → `#7 Rule 9` 前提检查 `amount > 0` 失败 → `push_error("ap_cost must be > 0")` + 返回 `false`。卡不执行,`card_play_failed(card_id, "INVALID_AP_COST")` emit。**[RISK GUARD] R-AP-AC1**: card schema lint 应在 CI 阻塞 `ap_cost = 0` 的卡,此为运行时双重防护。

**Edge 1.2 `amount > current_ap`**: AP 不足 → `try_consume_ap` 返回 `false` → `card_play_failed(card_id, "INSUFFICIENT_AP")` → `#14` 将该卡变灰 + toast 提示。**不报 error**,这是正常游戏流程。

**Edge 1.3 AP 整数溢出**: `current_ap: int` 最大值 = `max_ap_today = 10`(有加班);`ap_cost ∈ {1,2,3}` → 消耗后最小值 `10-3=7` ≥ 0。**不存在溢出风险**。但 `kpi_contribution: int [1,30]` × 月均 22 天 × 4.4 卡/天 ≈ 2904 上限;GDScript `int` 为 64-bit — 无溢出风险。

**Edge 1.4 加班期间打牌超出 10 AP**: `max_ap_today` 在加班成功后变为 10(`#7 Rule 3`)。若玩家在 `ACTION_OVERTIME` sub-mode 时尝试打卡使 `current_ap = 0`,`ap_depleted()` 正常 emit → `#6` 转移 sub-mode。无额外处理。

**Edge 1.5 sub-mode 非 ACTION_DAY/OVERTIME 时打卡**: `try_consume_ap` 前提检查 2 失败(sub-mode 不在允许集)→ 返回 `false` → `card_play_failed(card_id, "WRONG_SUBMODE")`。`#14` 在 KPI_REVIEW / DAILY_RECAP sub-mode 中应已禁用手牌 UI —— 此为额外防护。

---

### Cat 2 — NPC 状态边界

**Edge 2.1 LEFT NPC 卡灰显时机**: `npc_left_company` 信号在 NPC 离职事件完成后 emit(`#8 Rule 5`)。`#11` 收到信号 → 立即将该 NPC 所有卡 state → DISABLED。若玩家此刻正在打该 NPC 的卡(Rule 7 step 4 执行中):step 4 已调用 `update_relationship`,`#8` 检查 lifecycle_state 为 LEFT,拒绝更新 + push_error;后续步骤 5-8 正常完成(cooldown 记录,`kpi_contribution` 已在 step 3 报出)。

**Edge 2.2 NPC 关系阈值越界(score 超 [-100, +100])**: `update_relationship` 内部 clamp 由 `#8 Rule 2` 实施。本 GDD F2 的 `delta_clamp ∈ [-10, +10]` 守门是前置防护,`#8` clamp 是双重保险。

**Edge 2.3 `get_npc_state` 返回 LEAVING_ANNOUNCED**: NPC 宣告离职但尚未离开。卡**不灰显**(仍可打);NPC 关系更新照常。这是叙事设计意图 —— 玩家知道 Lisa 要走还能跟她互动,P2 守护。

**Edge 2.4 `npc_target = null` 卡的 LEFT 守门**: `npc_target = null` 的卡无 NPC 守门检查,直接跳过 Rule 8。

---

### Cat 3 — Cooldown 边界

**Edge 3.1 `once_per_run` 跨 GAME OVER**: GAME OVER 触发后 Run 结束,`current_run.save` 归档。新 Run 开始时 `cooldown_map` 清空(新 Run 重建)。`once_per_run` 卡在新 Run 可再次打出。这是设计意图 —— 每局游戏可以看到 Lisa 的离别剧情。

**Edge 3.2 玩家 reload(Autosave 恢复)边界**: `cooldown_map` 写入 Save Rule 6 snapshot(autosave 时机 = `event_completed` 后)。若玩家在打卡后、autosave 前 crash:reload 后卡 cooldown 未记录 → 卡可重打。**可接受**:MVP autosave 频率 = 每次 AP 消耗后(`#7 Rule 9 → ap_consumed → #1 autosave fast path`),丢数据窗口极短。

**Edge 3.3 `cooldown days` 计算基准**: `cooldown_map[card_id]` 存储的是"可解锁 day_index"(绝对日期计数)。计算: `unlock_day = current_day_index + cooldown.days`。`current_day_index` 由 `#6` 维护并通过 `scene_state_changed` payload 携带。**边界**: 跨月 cooldown —— 不处理日历语义,只用 day_index 纯整数(第 1 天 = day 0,第 22 天 = day 21)。

---

### Cat 4 — Hero/Overage 回调时序

**Edge 4.1 `is_hero` flag 同步**: Rule 7 step 2 在 step 1(`card_played` emit)之后。`#10` 可能在 `card_played` handler 中异步注入新事件。**约束**: MVP 禁止 `#10` 在 `card_played` handler 内再次触发打卡(嵌套禁止)。`#11` 内部 `_is_executing_card: bool` flag 守门:嵌套调用时 `push_error + skip`。

**Edge 4.2 `report_overage` 时序**: `#9` 通过 `report_overage(card_id, kpi_delta)` 回调判定超预期 → `#7 emit effort_overage_incremented`。此回调在 `kpi_contribution_reported` 之后(Rule 7 step 3)。`#9` 需要在月末统计超预期 —— **MVP 简化**: `report_overage` 是**月末结算时由 `#9` 批量处理**,不是实时回调。月内每次 `kpi_contribution_reported` 累计进 `actual_kpi_m`,月末计算 potential > 0 时回查 top-contribution 卡确定 overage_card。**OQ-AC-02**: `report_overage` 是实时(每卡)还是月末批量?建议月末批量,但需 `#9 GDD` 作者确认。

**Edge 4.3 Hero 卡 + 月末 reset 时序**: `#7 Rule 6` 月末 push `monthly_effort_summary` **之后**清零 `hero_card_played_this_month`。若月末结算时 `#9` 处理中途 crash:restart 后 `#7` 状态已 reset,但 `#9` 未完成结算。`settlement_locked = false` + `#9 Rule 2` 重新执行结算(Save Rule 6 snapshot 保证 `#7` reset 前已写入)。

---

### Cat 5 — 互斥分组(mutex)同帧多卡

**Edge 5.1 同帧两卡同 mutex_group 并发选中**: `#14 Card Play UI` 应保证玩家每次只能选中一张卡(UI 层单选逻辑)。若因 bug 导致两张同 mutex_group 的卡同帧都调 `_on_card_selected`:第一张先执行,设 `_mutex_played_today[group] = card_id_1`。第二张 Rule 6 检查 `_mutex_played_today.has(group)` → true → 跳过。**无数据损坏风险**,先到先得。

**Edge 5.2 mutex_group = null 的"全都要"场景**: `mutex_group = null` 的卡无互斥约束。若多张 `null` 卡可连续打出 —— 这是设计意图。日报(cooldown=never + mutex=null)每天必须打,这是玩家的"必要劳动"。

**Edge 5.3 mutex 跨 `ACTION_DAY + ACTION_OVERTIME`**: `_mutex_played_today` 在**整个工作日**(包括加班时段)共享。加班期间打的卡同样触发 mutex。次日 `MORNING_BRIEFING` 时 `_mutex_played_today` 清空。

---

### Cat 6 — 模板变量(NPC LEFT 时 fallback)

**Edge 6.1 `{{NPC_NAME}}` slot 中 NPC 已 LEFT**: 见 Rule 10 + `#10 Rule 8`。`display_name_static` 由 Save 持久化("Lisa"固定字符串,不再是动态 ACTIVE NPC name)。fallback 触发时不 push_error(已知 expected behavior)。

**Edge 6.2 `{{NPC_NAME}}` slot 中 NPC 不存在于注册表**: lint 守门(`tools/card_lint.gd` 校验 `npc_target ⊂ #8 NpcId 注册表`)。运行时如出现 → `push_error("Unknown NpcId")` + event 中止(不打卡)。

**Edge 6.3 `{{TASK}}` slot 的 Localization key 缺失**: `tr()` 调用 key 不存在 → `#3 Rule 4` 双轨 fallback(原 key 字符串显示 + push_warning)。不中止打卡,但文案展示为原始 key。`#3 Localization` CI lint 应事先 BLOCK 缺 key 的 PR。

**Edge 6.4 模板注入前 NPC 从 ACTIVE → LEFT(同帧 race)**: 若 `card_played` 和 `npc_left_company` 在同一帧 emit(理论上不应同帧,但 `#8` 状态机存在离职宣告→离职两阶段):使用上帧 NPC state(缓存),不实时 query。`display_name_static` fallback 已覆盖此情况。

---

### Cat 7 — AP Cost 分布违反

**Edge 7.1 `#11` 卡库 lint 在 CI 失效(工具 bug)**: 设计师手动添加 10 张 3-AP 卡而 lint 未 BLOCK → 3-AP 比例 > 25%。运行时无守门(lint 是唯一防线)。**[RISK GUARD] R-AP-AC1**: `tools/card_lint.gd` 单元测试须覆盖边界违反场景(`tests/unit/card_system/ap_distribution_lint_test.gd`)。

**Edge 7.2 VS scope tier 卡新增导致分布漂移**: VS 加 20 张卡后 AP 分布可能偏离 MVP 的 40/40/20。**解决**: lint 对全卡库运行,新增卡后 CI 重新校验。VS 设计师须关注分布健康报告。

**Edge 7.3 Hero 卡全为 3-AP(导致 effort_hero 权重偏高)**: Rule 3 约束 Hero 卡 `kpi_contribution` ≤ 非 Hero 同类卡 × 1.5,但未直接约束 Hero 卡 AP cost。若 6 张 Hero 卡全为 3-AP,则 effort_hero 路线需要花 18 AP/月(不到一天加班)。**需 playtest 验证是否出现"Hero 路线 = 加班等价且无精力代价"漏洞** — 这正是 `#7` 改权重从 0.35→0.20 要防的(OQ-AP 中有登记)。

---

### Cat 8 — Pillar 1+4 红线(永久 buff 卡 / 励志卡 PR)

**Edge 8.1 永久 buff 卡漏入 lint([RISK GUARD] R-AC-4)**: 设计师写了一张卡 effect = `{type: "ap_max_up", delta: 1, permanent: true}`,lint 未捕获。运行时 `#11 _execute_card` 解析 effect:若 effect type 不在允许白名单(Rule 11 允许集)→ `push_error("Forbidden effect type: ap_max_up")` + 跳过该 effect(卡打出但 effect 失效)。**不阻塞打卡本身**,但错误 effect 被吞掉。**修复**: `tools/card_lint.gd` 增加 effect.type 白名单校验;allowed = `{relationship, kpi_contribution, flag, spawn_event, energy}`。

**Edge 8.2 励志型文案通过 lint(主语翻转 lint 误放行)**: `subject_inversion_lint.py` 可能漏扫新 key 前缀模式。三层执法(`lint + writer review + CD sign-off`)中 writer review 是第二防线。**[RISK GUARD] R-AC-4** 的跨 GDD 形式 —— 与 R-NPC-1(`#8`) / R-KPI-1(`#9`) 同质,本 GDD 不额外新增 RISK GUARD 编号,归入 R-AC-4。

**Edge 8.3 卡解锁机制被误用为"成就解锁永久 buff"**: 设计师将卡 `unlock_condition` + 某 `effects` 组合变成"达到某成就 → 解锁提供永久 buff 的卡"。技术上 unlock 路径是合法的(unlock 本身不禁),但卡 effect 须通过 Rule 11 的 effect 白名单。需 GDD review + CD sign-off 双重守门。

**Edge 8.4 `mutex_group` 设计为空(所有卡无互斥)**: MVP 若所有卡 `mutex_group = null`,玩家每天可打所有可用卡(无互斥约束)→ A2 最优卡闭包成立。**这是设计失误而非 schema 错误**。需 GDD review 确保至少关键同类卡有 mutex_group 覆盖。OQ-AC-03: MVP 需要多少 mutex_group?建议至少 3 组(低效任务 / 社交任务 / 核心工作任务)。

---

### [RISK GUARD] 汇总

**R-AC-1: AP cost 分布 lint 失效**
- **描述**: `tools/card_lint.gd` AP 分布校验逻辑有 bug 或被绕过 → 卡库 AP 比例失衡 → A1 反模式("全 2-AP 魔方")→ P1 失守
- **守门**: `card_lint.gd` 单元测试 `tests/unit/card_system/ap_distribution_lint_test.gd` 在 CI 阶段 BLOCKING
- **跨 GDD 关联**: `#7 Rule 2 propagation flag #3` — AP cost 分布是 #7 和 #11 的共同契约

**R-AC-2: Hero 卡 `is_hero` flag 与 `#7` effort 权重不一致**
- **描述**: 若 `#7 F4 effort_norm` 公式的 hero 维度权重(0.20)与 `#11` 判定 Hero 卡的逻辑不同步 → 月末 `effort_norm` 错算 → KPI 涨幅数学异常
- **守门**: CI lint 验证 `#11 card schema hero_count contribution` 与 `#7 config/kpi_balance.tres KPI_HERO_WEIGHT` 来自同一 constants source(`entities.yaml`)
- **跨 GDD 关联**: `#7 Rule 6` + `#9 F6 effort_norm_check` — 三 GDD 共享 hero 权重常量

**R-AC-3: NPC LEFT 卡守门失效**
- **描述**: `get_npc_state` 查询失败(返回 ACTIVE 即使 NPC 已 LEFT) → 玩家对 LEFT NPC 打卡 → `update_relationship` 调用 `#8` LEFT NPC → `#8 Rule 5` 应 push_error + 拒绝更新,但数据状态已部分异常
- **守门**: `#11` Rule 8 + Rule 6 双重守门;`tests/unit/card_system/npc_left_card_gate_test.gd` 覆盖 LEFT NPC 打卡场景
- **跨 GDD 关联**: `#8 Rule 5` lifecycle_state + `#8 I-3 update_relationship` API 双层拒绝

**R-AC-4: Pillar 1 永久 buff 卡漏入 lint**
- **描述**: effect type 白名单校验缺失 → 永久 buff 卡绕过 CI → 玩家打出后获得永久 AP 上限 / 永久 stat 提升 → Anti-Pillar 1 破坏 → P3 数学无效
- **守门**: `tools/card_lint.gd` effect.type 白名单 + `tests/unit/card_system/pillar1_effect_lint_test.gd`
- **跨 GDD 关联**: `#7 Rule 11` AP 上限永久增长禁令 + `#9 Rule 12` threshold 单调 — 三 GDD 共同 Pillar 1 守门

## Dependencies

### 上游依赖(本系统依赖的系统)

| 系统 | GDD | 接口 | 本系统消费什么 |
|------|-----|------|-------------|
| `#1 Save System` | `save-system.md` | `SaveSystem.snapshot()` | card_state sub-schema 持久化(cooldown_map / played_history / unlocked_cards) |
| `#6 Scene & Day Flow` | `scene-day-flow-controller.md` | `scene_state_changed` 信号 | 手牌刷新触发 + mutex 日重置 + sub-mode 守门 |
| `#7 AP Economy` | `ap-economy-system.md` | `try_consume_ap(amount): bool` + `report_hero_card_played(card_id)` | AP 消耗守门 + Hero effort 累积 |
| `#8 NPC Relationship` | `npc-relationship-system.md` | `update_relationship(npc, delta, reason)` + `get_npc_state(npc_id)` | NPC 关系更新 + LEFT 守门 |
| `#9 KPI System` | `kpi-reverse-threshold-system.md` | `kpi_contribution_reported(amount)` emit → `#9` 订阅;`report_overage(card_id, kpi_delta)` 回调 | actual_kpi_m 累积 + 超预期判定 |
| `#10 Event Script Engine` | `event-script-engine.md` | emit `card_played(card_id)` → `#10` 订阅 trigger.type=card;订阅 `card_unlocked(card_id)` | 事件触发 + 卡解锁接收 |

### 下游依赖(依赖本系统的系统)

| 系统 | GDD | 接口 | 消费本系统什么 |
|------|-----|------|-------------|
| `#10 Event Script Engine` | `event-script-engine.md` | 订阅 `card_played(card_id)` trigger | card 触发事件的上游 |
| `#13 HUD System (Diegetic)` | — | 订阅 `card_played` + `card_unlocked` | 手牌区显示更新 + 新卡提示 |
| `#14 Card Play & Dialogue UI` | — | `get_hand_cards()` / `get_card_state()` query;订阅 `card_play_failed` | 手牌渲染 + 卡选择交互(UI own by `#14`,数据 own by `#11`) |
| `#15 Recap UI` | — | `played_history` / `kpi_contribution` 汇总 | 日/周结算显示卡使用数据 |

### 双向一致性核对

| 契约 | 本 GDD 声明 | 对端 GDD 声明 | 一致 |
|------|-----------|-------------|------|
| `try_consume_ap` 调用协议 | Rule 6 + Rule 9 | `#7 Rule 9 API 契约` | ✓ |
| `report_hero_card_played` 回调 | Rule 7 step 2 | `#7 Rule 6 effort_hero_incremented` | ✓ |
| `kpi_contribution_reported(amount)` emit | Rule 7 step 3 / F3 | `#9 I-5 + F7 actual_kpi_m` | ✓ (量纲待 OQ-AC-01 确认) |
| `update_relationship(npc, delta, reason)` | Rule 7 step 4 / F2 | `#8 Rule 4 API` | ✓ |
| `get_npc_state(npc_id)` | Rule 8 | `#8 Rule 5 lifecycle_state` | ✓ |
| `card_played(card_id)` → trigger.type=card | Rule 7 step 1 / Rule 13 | `#10 Rule 3 trigger card` + `I-5` | ✓ |
| `card_unlocked(card_id)` from `#10` | Rule 5 / Rule 13 | `#10 Rule 15 arc + unlock_event` | ✓ |
| AP cost 分布 40/40/20 lint | F1 + R-AC-1 | `#7 Rule 2 propagation flag #3` | ✓ |

### 6 条未设计 GDD 的 propagation 要求

1. **`#13 HUD Diegetic`**: 订阅 `card_played` + `card_unlocked` 信号;手牌区刷新 + 新卡提示(not PR-blocking — #13 not started)
2. **`#14 Card Play & Dialogue UI`**: 实现 `get_hand_cards()` / `get_card_state()` 消费接口;`card_play_failed` 的灰显 / toast 反馈;`long` 事件立绘渲染(从 `#10 event_started(event_id, narrative_tier=long)` 触发,与 `#11 card_played` 同步)
3. **`#15 Daily / Weekly Recap UI`**: 消费 `played_history` + `kpi_contribution` 统计;卡使用数据来自 `#11 card_state` sub-schema
4. **`#12 Run Meta System`**: 跨 Run 的"卡打过 N 次"数据 —— 由 `played_history` 归档驱动,`#12` 从 Save archive 读取
5. **`#3 Localization Hooks`**: 卡 `text_key` + 模板变量 `{{NPC_NAME}}` 等须符合 `#3 key 命名规范`(domain = CARD)+ `_IRONY` 后缀用于反讽文案 + `_BUREAUCRATIC` 后缀用于日常行政类
6. **`#9 KPI System`**: 需确认 `actual_kpi_m` 和 `monthly_threshold` 量纲对齐(OQ-AC-01) —— 若 `kpi_contribution` 中位 8.5 × 月均打牌数 ≈ 823 points 远超 threshold=100,则 potential 恒正,F2 需要调整

## Tuning Knobs

所有 Tuning Knob 值存于 `assets/data/card_balance.tres`;禁止硬编码。

| Knob | 类型 | 当前值 | 安全范围 | 类别 | 说明 |
|------|------|--------|---------|------|------|
| `CARD_AP_DIST_1_TARGET` | float | 0.40 | [0.35, 0.45] | curve | 1-AP 卡目标比例;与 `#7 BASE_AP_PER_DAY=8` 联动 |
| `CARD_AP_DIST_2_TARGET` | float | 0.40 | [0.35, 0.45] | curve | 2-AP 卡目标比例 |
| `CARD_AP_DIST_3_TARGET` | float | 0.20 | [0.15, 0.25] | curve | 3-AP 卡目标比例;决策锚点密度 |
| `CARD_AP_DIST_TOLERANCE` | float | 0.05 | [0.03, 0.08] | gate | lint 容忍范围;±5% 时平衡可接受 |
| `CARD_NPC_DELTA_MAX` | int | 10 | [5, 15] | curve | 单卡 NPC 关系 delta 上限;防速刷 |
| `CARD_KPI_CONTRIBUTION_MIN` | int | 1 | [1, 5] | curve | 单卡 KPI 贡献下限 |
| `CARD_KPI_CONTRIBUTION_MAX` | int | 30 | [20, 40] | curve | 单卡 KPI 贡献上限;与 `#9 F7 actual_kpi_m` 量纲对齐待 OQ-AC-01 |
| `CARD_KPI_CONTRIBUTION_MEDIAN` | float | 8.5 | [6, 12] | curve | 目标中位值;影响月均 KPI 完成率 |
| `CARD_HERO_RATIO_MAX` | float | 0.20 | [0.15, 0.25] | gate | Hero 卡占全卡库上限;防 effort_hero 路线过强 |
| `CARD_HERO_KPI_MULTIPLIER_MAX` | float | 1.5 | [1.2, 2.0] | curve | Hero 卡 KPI 不超过同类非 Hero 的 N 倍 |
| `CARD_MVP_TOTAL_MIN` | int | 30 | [25, 35] | gate | MVP 卡库最小卡数 |
| `CARD_MVP_TOTAL_MAX` | int | 40 | [35, 50] | gate | MVP 卡库最大卡数 |

### Knob 说明

**`CARD_KPI_CONTRIBUTION_*`**: 与 `#9 KPI System` 的 `actual_kpi_m` 量纲必须对齐(OQ-AC-01)。若 `#9 F7` 的 threshold 是 100(point units = kpi_contribution),则月均 ~800 点 actual_kpi_m 意味着 potential 恒为正值 —— 这可能是正确的(玩家总是"超额完成"),也可能需要 threshold 初始值为 800+。**在 `#9` review 确认前,本表中位值 8.5 为 provisional**。

**`CARD_NPC_DELTA_MAX`**: 过低(<5)使 NPC 关系变化感知不明显(P2 失守);过高(>15)使关系速刷成可能(P1 失守)。10 是中间值,playtest 验证。

**`CARD_AP_DIST_TOLERANCE`**: ±5% 容忍允许设计师在 MVP 30-40 张时有整数卡数的灵活度(30 张时 1.5 张灵活区 = 实际 1-2 张弹性)。

### 跨 GDD Constants 引用

| Constant | Source GDD | 本 GDD 消费方式 |
|----------|-----------|--------------|
| `BASE_AP_PER_DAY = 8` | `#7 ap-economy-system.md Rule 1` | AP cost 分布 avg_cost 计算基准 |
| `KPI_BASE_MONTH_1 = 100` | `#9 kpi-reverse-threshold-system.md Rule 1` | F3 量纲对齐参考 |
| `effort hero weight = 0.20` | `#7 Rule 6 + #9 Rule 4` | Hero 卡设计约束(R-AC-2 守门) |

## Visual/Audio Requirements

> **范围声明**: 本 GDD 不 own 任何视觉/音频资产。以下为本系统向 `#13 HUD` / `#14 Card Play UI` / `#4 Audio Manager` 提供的契约要求。

### 视觉契约(→ `#13 HUD Diegetic` + `#14 Card Play UI`)

| 元素 | 要求 | Pillar |
|------|------|--------|
| 卡片 AP cost 格子 | 视觉上"格子感"强(而非数字),与 `#7` AP Bar 视觉同源 | P5(一眼判断剩余) |
| 文案作为主视觉层级 | `kpi_contribution` 数字不做主要视觉元素;文案 + NPC 模板变量作为视觉重心 | P2(叙事先于数字) |
| DISABLED 卡灰显 | 统一灰显,无 tooltip 解释 LEFT NPC 缘由(沉默式) | P4(黑色幽默) |
| 打卡后无金光/成就动画 | AP 消耗无奖励感反馈(AP Economy 反英雄红线)| P1(反英雄) |
| Hero 卡无特殊光效 | `is_hero` 卡不得有"闪耀/精英"视觉标记 | P1(平庸是艺术) |

**📌 Asset Spec Flag**: `/asset-spec system:action-card-system` —— 卡面视觉规格(卡尺寸 / 字体层级 / AP 格子设计 / 灰显样式)须由 `#14 Card Play UI GDD` + art-bible §7 规范约束。

### 音频契约(→ `#4 Audio Manager`)

| 事件 | 音频要求 | 反例(禁止) |
|------|---------|-----------|
| 打卡成功 | 中性/轻微办公室音效(键盘声/鼠标点击) | 成功音 / 升级音 / 金属碰撞(励志感) |
| 打卡失败(AP 不足) | 短暂低沉 SFX(不是"错误音"而是"没了"音) | 急促警报声 |
| 新卡解锁 | 无音效(or 极低调的通知音),不做"解锁庆典" | 欢呼声 / 成就音 |

**`#4 Audio Manager` Pillar 4 红线对齐**: 行动卡的音效域继承 `CARD.GAMEPLAY.[identifier]_BUREAUCRATIC` 命名约定,不使用励志/庆祝类 SFX 白名单外的音效。

## UI Requirements

> **范围声明**: 本 GDD 不 own UI 屏。手牌 UI + 卡选择交互 own by `#14 Card Play & Dialogue UI`。以下仅为本系统对 `#14` 的数据 + 行为契约。

### 数据契约(本系统 → `#14`)

| 接口 | 提供数据 | 频率 |
|------|---------|------|
| `get_hand_cards() -> Array[CardData]` | 完整手牌(含 state / cooldown_remaining / mutex_group) | 每次手牌刷新 |
| `get_card_state(card_id) -> CardState` | IDLE / PLAYABLE / DISABLED / PLAYED | 实时 query |
| `card_play_failed(card_id, reason)` signal | 失败原因("INSUFFICIENT_AP"/"WRONG_SUBMODE"/"MUTEX_LOCKED"/"NPC_LEFT") | 失败时 |

### 行为约束(本系统对 `#14` 的要求)

1. `#14` 只能在 `ACTION_DAY` / `ACTION_OVERTIME` sub-mode 时启用手牌交互(本系统通过 `card_play_failed("WRONG_SUBMODE")` 双重守门)
2. 卡面文案视觉权重 > `kpi_contribution` 数字显示(详见 Visual/Audio 契约)
3. `long` 事件立绘渲染由 `#14` own —— 触发时机为 `#10 event_started(event_id, narrative_tier="long")`,与 `card_played` 在同帧内按顺序触发
4. 所有 DISABLED 卡灰显无 tooltip 说明 LEFT NPC 原因(P4 黑色幽默 — 沉默式)

### **📌 UX Flag**: 须运行 `/ux-design design/ux/card-play-screen.md`(配 `#14` 撰写时)

完成 `#14 Card Play & Dialogue UI GDD` 时,须同时产出 `card-play-screen.md` UX 规格,覆盖:手牌布局 / 卡选择交互 / DISABLED 状态 / `long` 事件立绘过渡 / Gamepad D-Pad 手牌导航焦点链(预留 Switch 移植路径 — `#2 Input Handler Section G`)。

## Acceptance Criteria

> 20 AC / 5 categories。Tier: MVP 必测 17 / Beta 推迟 3。
> 4 [RISK GUARD] AC-ROBUST-01..04 分别对应 R-AC-1..4。

### AC-FUNC — 功能验收(12 条)

| ID | Given | When | Then | Tier |
|----|-------|------|------|------|
| AC-FUNC-01 | 玩家有 5 AP,选 3-AP 卡 | 调 `try_consume_ap(3)` | AP 扣为 2,`card_played` + `kpi_contribution_reported` 按顺序 emit | MVP |
| AC-FUNC-02 | 玩家有 1 AP,选 2-AP 卡 | `try_consume_ap(2)` | 返回 false,emit `card_play_failed("INSUFFICIENT_AP")`;AP 不变 | MVP |
| AC-FUNC-03 | Lisa 已 LEFT | 玩家尝试打 npc_target=LISA 的卡 | 卡为 DISABLED 态,打卡请求被拒,`get_npc_state(LISA)` 返回 LEFT | MVP |
| AC-FUNC-04 | 打出 `is_hero=true` 的卡 | 打卡成功 | `report_hero_card_played(card_id)` 调用 `#7`,`effort_hero_incremented` emit | MVP |
| AC-FUNC-05 | 同 mutex_group 的两张卡 | 打出第一张 | 第二张立即变 DISABLED;次日 MORNING_BRIEFING 后两张均重置 IDLE | MVP |
| AC-FUNC-06 | `once_per_run` 卡已打过 | 同 Run 内再次选中 | 卡为 DISABLED;cooldown_map 记录;GAME OVER 后新 Run 时重置 | MVP |
| AC-FUNC-07 | `unlock_condition` 依赖关系阈值 | `#10` emit `card_unlocked(card_id)` | 卡加入手牌池,`card_unlocked` relay emit 给 `#13 HUD` | MVP |
| AC-FUNC-08 | 打出 NPC 关系卡 | 打卡成功 | `update_relationship(npc, delta, card_id)` 调用;delta ∈ [-10, +10](F2 守门) | MVP |
| AC-FUNC-09 | 打出任意有 `kpi_contribution` 的卡 | 打卡成功 | `kpi_contribution_reported(amount)` emit 给 `#9 F7`;amount ∈ [1, 30] | MVP |
| AC-FUNC-10 | NPC `LEAVING_ANNOUNCED` 状态 | 玩家选中该 NPC 的卡 | 卡为 IDLE(可打),打卡成功;关系更新正常 | MVP |
| AC-FUNC-11 | 卡 text_key 含 `{{NPC_NAME}}`,NPC 已 LEFT | 手牌刷新 | 文案使用 `display_name_static` fallback,无 push_error | MVP |
| AC-FUNC-12 | sub-mode = KPI_REVIEW | 玩家尝试打任意卡 | 返回 false,emit `card_play_failed("WRONG_SUBMODE")`;卡状态不变 | MVP |

### AC-PERF — 性能验收(2 条)

| ID | 条件 | 指标 | Tier |
|----|------|------|------|
| AC-PERF-01 | MVP 40 张卡库,手牌刷新 | 全量 state eval < 5ms(60fps 预算 16.6ms 的 30%) | MVP |
| AC-PERF-02 | 打卡 emit 序列(Rule 7 step 1-7) | 同帧内完成,总耗时 < 2ms | MVP |

### AC-COMPAT — 跨系统兼容验收(3 条)

| ID | 条件 | 验收标准 | Tier |
|----|------|---------|------|
| AC-COMPAT-01 | `#7 try_consume_ap` API 签名变更 | `#11 Rule 6` 调用仍正确编译 + 运行(无静默失败) | MVP |
| AC-COMPAT-02 | `#8 update_relationship` 被调 LEFT NPC | `#8` 内部拒绝 + push_error;`#11` 打卡不中断(steps 5-7 仍执行) | MVP |
| AC-COMPAT-03 | `#10 card_unlocked` 信号连接 | `#11` 收到信号后 `get_hand_cards()` 返回新卡;`#13 HUD` 收到 relay | Beta(#13 未设计) |

### AC-ROBUST — 鲁棒性验收([RISK GUARD])

| ID | [RISK GUARD] | 验收标准 | Tier |
|----|------------|---------|------|
| AC-ROBUST-01 **[R-AC-1]** | AP 分布 lint 守门 | `tools/card_lint.gd` 在 CI 对 MVP 卡库运行;违反 40/40/20 ±5% 时 PR BLOCK(通过 `tests/unit/card_system/ap_distribution_lint_test.gd`) | MVP |
| AC-ROBUST-02 **[R-AC-2]** | Hero 权重一致性 | CI lint 验证 `#11` hero 判定逻辑与 `#7 config/kpi_balance.tres KPI_HERO_WEIGHT=0.20` 来自同一 constants source | MVP |
| AC-ROBUST-03 **[R-AC-3]** | LEFT NPC 打卡守门 | `tests/unit/card_system/npc_left_card_gate_test.gd`:LISA 置 LEFT 后打 npc_target=LISA 的卡 → DISABLED + false 返回 | MVP |
| AC-ROBUST-04 **[R-AC-4]** | 永久 buff effect lint | `tests/unit/card_system/pillar1_effect_lint_test.gd`:包含 `type=ap_max_up` 的卡 → lint BLOCK;运行时 effect 被 skip + push_error | MVP |

### AC-TONE — Tone 验收(3 条)

| ID | 验收标准 | 执法层 | Tier |
|----|---------|-------|------|
| AC-TONE-01 | 全卡库 Localization key 通过 `subject_inversion_lint.py --domain CARD`;无"励志/友谊/胜利"类词汇命中 | CI lint | MVP |
| AC-TONE-02 | 打卡成功无金光/成就动画(视觉 QA + `#14` sign-off) | `#14` GDD 设计审校 | Beta(#14 未设计) |
| AC-TONE-03 | Hero 卡文案包含"过度付出的荒诞感"而非"英雄主义"(writer review + CD sign-off) | writer 三层执法 | Beta |

## Open Questions

| ID | 问题 | Owner | 目标时机 |
|----|------|-------|---------|
| OQ-AC-01 | `kpi_contribution` 中位 8.5 × 月均打牌数 ≈ 823 points 与 `#9 monthly_threshold=100` 量纲不对齐。`#9 F7 actual_kpi_m` 是否与 threshold 同量纲?若不是,F3 中位值需要重设(F3 在本 GDD 中为 provisional) | `#9 KPI System` 作者 | `#9 design-review` 通过后 |
| OQ-AC-02 | `report_overage(card_id, kpi_delta)` 回调是实时(每卡打出后)还是月末批量?`#7 Rule 6` 描述为实时回调,但 `#11` 无法在打卡时就知道"是否超预期"(需要全月累积)。建议月末批量,但需 `#7`/`#9` 联合确认 | `#7` + `#9` + `#11` 三方 | #9 review 后 |
| OQ-AC-03 | MVP 需要多少个 `mutex_group` 分组?建议 3 组(低效任务 / 社交任务 / 核心工作),但具体分组设计需 writer + game-designer 联合确定(卡库内容设计) | writer + game-designer | #11 卡库内容设计阶段 |
| OQ-AC-04 | Hero 卡是否应该在视觉上与普通卡完全一致(当前 Rule 3 约束无特殊光效)?还是允许"极其微妙的物理质感差异"(如卡纸张感稍厚)?art-director 意见 | art-director | `#14 Card Play UI GDD` |
| OQ-AC-05 | `cooldown.days` 计算基准:使用绝对 day_index 还是日历日?MVP 3 个月 = 66 工作日,day_index 0-65 足够。但野心版多年度时 day_index 会超 1000 —— int 足够,但语义需锁定 | `#6 Scene & Day Flow` | `#11 design-review` |
