# Card Play & Dialogue UI

> **Status**: Designed (pending review)
> **Author**: huanghaibin + game-designer (A+B+C 主笔)+ systems-designer (C 协议 + E edges)+ ux-designer (G Tuning Knobs)+ qa-lead (H AC)
> **Authoring autonomy mode**: v2 no-prompt(0 widget,cross-GDD 全量读取 #10/#11/#3/#7/#8/#1/#13)
> **Last Updated**: 2026-04-27
> **Layer**: Presentation | **Order**: #14 | **Size**: M
> **Implements Pillar**: P2 守(叙事即机制 — 对白 + 立绘是 NPC 算计的具象化)+ P5 守(三档密度差异化渲染 + 90s 一天 budget)+ P4 守(主语翻转 lint 覆盖 + 反英雄红线)+ P1 守(卡面数字不是第一视觉层级)

---

## Section A: Overview

**Card Play & Dialogue UI**（`#14`）是《活过第 X 集》Presentation Layer 的**关键渲染层**，承担双重身份：

**技术层**：订阅 `#10 Event Script Engine` 的 `event_started(event_id, narrative_tier)` 信号，依据 `narrative_tier` 执行**三档密度差异化渲染分发**：`flash <3s overlay`（屏幕底部安全区单行，转由 `#13 HUD` 渲染）/ `long <30s 立绘+对白+选项`（`#14` 全屏接管）/ `numeric_only`（无 UI，转由 `#13 HUD` 渲染）。同时渲染**玩家手牌 UI**（8-12 张 `#11 Action Card`，含 AP cost 格子、NPC LEFT 灰显、互斥分组灰显）并处理选卡交互（emit `card_selection_requested` → `#11` 执行 `try_consume_ap` 守门）。`choice_selected` 选项点击后 emit 回 `#10`。本 GDD **不持有任何文本字符串**：事件文本 key 由 `#10` 持有，`tr()` 调用由本层执行，模板变量已由 `#10 Rule 8` 注入 `context_dict`，`#14` 仅渲染最终字符串。

**叙事层**：行动卡是**行动的实体化** — 每张卡不是数值按钮，是带着剧本入口的决策票据（`#11 Section B` 主锚）。对白框是 **NPC 算计的具象化** — 玩家看到的不是"关系 +5"的孤立 toast，是"Lisa 把椅子拉过来，问'你保温杯里泡的什么?'"的具体场景（`#10 Section B` 主锚）。立绘是 **NPC 存在感的像素载体**（art-bible §5.4 事件 CG 128×192 规格）。

### Pillar 服务

- **P2 守 叙事即机制**：`long` 事件渲染立绘 + 对白 + 选项，让玩家读 NPC 行为而非数字；`flash` 事件单行克制不打断，信息流入而非叙事停顿
- **P5 守 地铁可玩性**：三档密度让玩家按自身 session 节奏控制叙事密度；手牌 8-12 张、每张决策 <15s；帧预算 ≤ 2ms/屏（`#6 Rule 3` 16.6ms 分摊）
- **P4 守 苦中作乐黑色幽默**：主语翻转 lint 覆盖 `#14` 所有文本渲染路径；NPC LEFT 卡沉默式灰显（无 tooltip 解释）；`kpi_contribution` 不作为卡面第一视觉层级
- **P1 守 平庸是艺术**：卡面设计文案做主角、AP 格子做视觉重音、`kpi_contribution` 默认隐藏（G-10）；选项无"最优解"标记

### 5 NOT 边界（scope creep 防护）

- **NOT** 卡 schema / 卡数据（由 `#11 Action Card` own；`#14` 仅渲染 `card_data` 结构的视觉表达）
- **NOT** 事件触发逻辑 / 候选池抽取（由 `#10 Event Script Engine` own；`#14` 订阅信号，不持引擎状态）
- **NOT** NPC 关系数值（由 `#8 NPC Relationship` own；`#14` 仅查询 `npc_state` 用于灰显判断）
- **NOT** 事件文本字符串本身（由 `#3 Localization` + writer own；`#14` 只持 loc key 引用 + 调 `tr()`）
- **NOT** 月末结算屏 / KPI Review / Game Over（由 `#16 KPI Review & Game Over UI` own；`numeric_only` + `flash` 路径转由 `#13` 渲染，本 GDD 不介入月末屏）

### 5 NOT 红线（违反即破坏 Pillar / 破坏跨系统契约）

- **NOT** 离别事件（LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF）渲染任何 `#14` 自身 UI（违反 `#10 Rule 6` numeric_only 强制 — 沉默比文字更重）
- **NOT** 卡面大字显示 `kpi_contribution`（违反 P1 + `#11 Section B` 主锚 — 数字不是第一视觉层级）
- **NOT** 选项旁添加"最优解"/ 高亮推荐标注（违反 P1 — A2 最优卡闭包助攻）
- **NOT** `long` 事件期间触发 BGM 切换（违反 `#4 Audio Manager` Rule 7 白名单 — 仅月末/GO 可切换）
- **NOT** 在 `numeric_only` 档渲染任何 `#14` 事件 UI（违反 `#10 Rule 6` 强制契约 + `#13` 分工边界）

### Source 引用

`#10 Event Script Engine` Rule 6(三档密度定义)+ Rule 8(模板变量注入)+ Rule 10(Choice ≤3 + 强制 ≥1 无条件 choice)+ Rule 17(GAME OVER 链)+ I-8(event_started 信号契约)+ Section UI Requirements(强制契约)。`#11 Action Card` Rule 6(try_consume_ap 协议)+ Rule 8(NPC LEFT 守门)+ Rule 10(LEFT NPC display_name_static fallback)。`#3 Localization Hooks` Rule 4(tr() 纪律)+ Rule 5(dispatch ≤1 帧)。`#7 AP Economy` Rule 9(try_consume_ap 接口)。`#8 NPC Relationship` get_npc_state API + R-NPC-2(LEFT 立绘视觉屏蔽)。`#1 Save System` Rule 21(final_transition_duration_ms=1500)。`#13 HUD Diegetic`(flash / numeric_only 渲染分工边界)。`art-bible §5.4`(事件 CG 128×192 + 互动特写 64×96)+ `§5.3`(姿态库 MVP 必备)+ `§7.2`(字体层级 12px 正文)+ `§7.4`(官僚式迟钝动画规则)+ `§7.5`(Gamepad focus 态)。`game-concept.md` Pillar 1+2+4+5。

---

## Section B: Player Fantasy

> **Framing**: Direct — 玩家亲手打牌、亲眼看 NPC 开口。本节服务 MDA Aesthetics: **Fantasy**（NPC 算计的现实具象）+ **Narrative**（每次选卡是剧本入口）+ **Challenge**（有限手牌中凑合用的判断）。

### 主锚 1: "Lisa 把椅子拉过来，问'你保温杯里泡的什么?'"

**场景**（玩家时刻）:

周二下午 2:47。你刚打了"整理会议纪要"卡 —— 一张 2-AP 的常规卡。按正常逻辑你该接着打"填写日报系统"。但 `long` 事件面板弹出来了：Lisa 的立绘出现在屏幕中央偏左，椅子移动的 4 帧动画——然后文本框出现："她把椅子拉过来，靠上你这边的隔板。'你保温杯里泡的什么?'" 屏幕上有 2 个选项。**你读的不是选项标签旁的数字，是 Lisa 今天的样子。**

**Pillar 服务**:
- **主 P2 叙事即机制**: `long` 渲染的立绘 + 对白 + 选项三件套不是 UI 容器——它是 NPC 在存在的载体。`#14` 把 `#10` 的 event schema 翻译成"Lisa 今天靠过来了"的像素具体性
- **守 P5 地铁可玩性**: `long` 事件 <30s；立绘呈现→对白出现→玩家扫读→选项决策全程 15-25s；无跑马灯动画，无等待
- **守 P4 黑色幽默**: 立绘姿态是"靠椅"不是"冲突"；文本是"你保温杯里泡的什么"不是"你有多重视友情"；选项是职场日常措辞不是命运抉择按钮

**跨 GDD negative space 联动**:
- **NPC** "和你混熟的同事都走了" 共振: 对话渲染的是 `ACTIVE` 状态 Lisa——她现在还在。NPC LEFT 后对话入口消失，立绘灰显（沉默式，Rule 5）
- **Action Card** "我打这张卡是为了它的剧本" 共振: 玩家选"问 Lisa 进度"2-AP 卡 → 触发本事件。卡的决策动机和事件回报在 `#14` 一帧内完成闭环
- **Audio** 日光灯嗡的不是 BGM 共振: `long` 事件期间 BGM 不切换（`#4 Rule 7` 白名单），background ambient 维持

**❌ Tone 风险(必避)**:
- 立绘旁出现"关系 +3"浮动数字（数值 UI 破坏叙事沉浸）
- 选项按钮旁标注推荐选项（破坏 P1 + 玩家主体性）
- `long` 事件期间 BGM 切换（违反 Audio 白名单）

**✅ Tone 守护(推荐)**:
- 立绘帧：`npc_lisa_cg_default_128x192.png`（art-bible §5.4 事件 CG 规格）
- 文本框边框：`#2A1F14` 咖啡渍棕黑（art-bible §4.4 框线色）
- 选项按钮：`#5A7080` 灰蓝底、12px 思源黑体（art-bible §7.2 正文字号）、无推荐标记

### 主锚 2: "8 张卡里挑 4 张，凑合用吧"

**场景**（玩家时刻）:

早上 9:17，`MORNING_BRIEFING` 结束，`ACTION_DAY` 开始。手牌区从下方滑入：8 张卡，4 张 1-AP（白色格）、3 张 2-AP（浅灰格）、1 张 3-AP（中灰格）。你看了眼今天剩余 8 AP 格子。"跨部门对接"3-AP 卡显眼摆在中间，旁边两张 `npc_target=LISA` 的 1-AP 卡——Lisa 工位灰的。**你数了数剩余 AP，点了"日报系统填报"。**

**Pillar 服务**:
- **主 P1 平庸是艺术**: 手牌 UI 的视觉重心是"AP 格子 + 卡文案"，不是 `kpi_contribution` 数字；玩家"凑合用"的判断依据是文案和格子数，不是最优数值计算
- **守 P5 地铁可玩性**: 手牌 8-12 张一屏展示，无翻页；AP 格子大且清晰；每次决策 <15s
- **守 P4 苦中作乐**: Lisa NPC LEFT 卡沉默式灰显——无 tooltip 解释，玩家自己知道

**跨 GDD negative space 联动**:
- **AP Economy** "今天又只有 8 格" 共振: 手牌区 AP 格子直接对应 `#7 APEconomy.current_ap`——玩家每次点卡，格子即时消耗（≤1 帧，art-bible §7.4 即时响应铁则）
- **Event Script** 日常/flash 事件插入 共振: `flash` 事件出现在手牌区下方（屏幕底部安全区），不遮挡手牌；玩家仍可继续选卡（并发交互，Rule 10）

**❌ Tone 风险(必避)**:
- 手牌 `kpi_contribution` 大字标注（违反 P1）
- NPC LEFT 卡显示"Lisa 已离职，无法交互"tooltip（破坏 P4 沉默式美学）
- AP 消耗时出现粒子效果或成就感 SFX（违反 P1 反英雄红线）

**✅ Tone 守护(推荐)**:
- 卡面布局：AP 格子（右上角）+ 卡文案（中部主区 12px）+ 底部极小字 KPI（6px，G-10 默认隐藏）
- AP 消耗动画：格子变 `#2A1F14` 深色（即时 1 帧），无粒子无音效
- NPC LEFT 卡：整张卡 saturation→0（灰调），无任何解释文案

### Internal Design Test: 数字服务叙事，不反客为主

每次审校 `#14` 手牌或对白 UI 时，问一个问题：**"玩家的注意力在文案还是在数字?"**

- 如果玩家第一眼扫描的是 `kpi_contribution` 数值（主语 = 最优算法）→ 视觉权重分配违反 P1，`kpi_contribution` 字号/颜色需降级
- 如果玩家第一眼读的是"Lisa 靠椅过来说的那句话"（主语 = 情境判断）→ 通过

**正例**: 手牌显示"问一下 Lisa 进度"（大字主体）+ 右上角小灰格"2 AP" + 底部极小字"≈12"（几乎不注意）
**反例**: 手牌核心区展示"12 KPI / 2AP"两行大字，文案在角落（A2 最优卡闭包助攻）

**Design test 对应 Pillar**: Anti-Pillar 1(NOT 升职打怪)+ P2(叙事即机制)在 UI 渲染层的执法。所有 `#14` 卡面设计审校援引此 internal design test。

### Source 引用

`#11 Action Card` Section B 主锚 A "我打这张卡是为了它的剧本" + 副锚 B "为什么这张卡 AP 这么贵"。`#10 Event Script` Section B 主锚 "你打过 47 张'回邮件'卡" + 副锚 "今早预告说 Lisa 找你吃饭"。`#8 NPC` Section B 副锚 "Lisa 又要跳槽了"。`art-bible §5.4` LOD 互动特写 64×96 + 事件 CG 128×192。`game-concept.md` Pillar 1+2+4+5。

---

## Section C: Detailed Rules

> **本节分三部分**: **14 Core Rules**（三档密度渲染 + 手牌 + 选项交互 + 立绘 + 对白 + 信号协议 + 帧预算 + 范围）+ **States and Transitions**（3 态）+ **Interactions**（7 跨系统契约）
>
> **所有权边界**: 本 GDD owns 三档密度 UI 渲染分发 + 手牌 UI + 选项交互 + 立绘绑定 + 对白框渲染。**`#10` owns 事件 schema + 触发分发 + 信号 emit**。**`#13 HUD` owns `flash` overlay 渲染 + `numeric_only` 渲染**。**`#11` owns 卡 schema + `try_consume_ap` 调用序列**。**`#3` owns 文本字符串加载**。

### Core Rules

---

**Rule 1 — 三档密度差异化渲染分发**（强制契约：`#10 Section UI Requirements` + `#10 Rule 6`）

`#14` 订阅 `#10` emit 的 `event_started(event_id: StringName, narrative_tier: String)` 信号后，依 `narrative_tier` 字段执行独立渲染路径：

| 档位 | `narrative_tier` 值 | 时长约束 | `#14` 动作 | 实际渲染方 |
|------|---------------------|---------|-----------|----------|
| `flash` | `"flash"` | < 3s | emit `ui_route_to_hud(event_id, "flash")` | `#13 HUD`（屏幕底部安全区单行 overlay） |
| `long` | `"long"` | < 30s | `#14` 接管：渲染立绘 + 对白框 + 选项按钮（全屏模态层）| `#14` 本身 |
| `numeric_only` | `"numeric_only"` | 0s | emit `ui_route_to_hud(event_id, "numeric_only")` | `#13 HUD`（仅数值更新，无事件 UI） |

**强制**:
- 三档路径**绝对独立**，无共享渲染代码路径（防 Cat 1 race）
- `flash` 和 `numeric_only` 均转 `#13`：`#14` emit `ui_route_to_hud(event_id, narrative_tier)` 信号，`#14` 本身不渲染任何 UI
- `long` 接管时设置世界层 overlay 压暗（`Color(0, 0, 0, G-4 alpha)`）+ 锁定手牌交互（`hand_ui.set_process_input(false)`）

---

**Rule 2 — 离别事件强制 `numeric_only`**（`[RISK GUARD] R-CPU-1`）

以下 event_id 被硬编码为 **`numeric_only` 强制路径**，无论其 `#10` schema `narrative_tier` 字段值如何：

```gdscript
const FAREWELL_EVENT_IDS: Array[StringName] = [
    &"LISA_GOODBYE",
    &"CLEANING_AUNT_LEAVE",
    &"FISH_MONK_LAID_OFF",
]

func _on_event_started(event_id: StringName, narrative_tier: String) -> void:
    # 离别事件强制 numeric_only 覆盖（优先于 narrative_tier）
    if event_id in FAREWELL_EVENT_IDS:
        _route_to_hud(event_id, "numeric_only")
        return
    # 正常三档路由
    match narrative_tier:
        "long":         _render_long_event(event_id)
        "flash":        _route_to_hud(event_id, "flash")
        "numeric_only": _route_to_hud(event_id, "numeric_only")
        _:              push_error("[#14] unknown narrative_tier: %s" % narrative_tier)
```

**禁止**（离别事件发生时）：
- 任何 toast / 弹窗 / overlay 出现（`#10 Rule 6`：沉默比文字更重）
- BGM 切换（`#4 Rule 7` 白名单仅月末/GO）
- Lighting 特殊模式（`#5 Rule 11` Pillar 4 反讽红线守门）

**[RISK GUARD] R-CPU-1**: 离别事件被 `#10` schema 标记为 `narrative_tier: "long"` 时，若 `#14` 不执行本 Rule 强制覆盖，将渲染 LISA_GOODBYE 立绘+对白（违反 `#10 Rule 6` numeric_only 强制 + Pillar 3/4 沉默美学）。跨守：`#10 R-EVT-5`（三档密度 fallback 缺失 RISK GUARD）。

---

**Rule 3 — 玩家手牌 UI**（依赖 `#11 Action Card`）

**手牌容量**: 8-12 张，由 `#11` 抽取权重系统控制，`#14` 只渲染传入的卡列表（不参与抽取逻辑）。

**布局**:
- 手牌区固定屏幕底部；`long` 事件接管时隐藏（`hand_ui.visible = false`）；`ACTION_DAY` / `ACTION_OVERTIME` sub-mode 时可见
- 单张卡：`64×96 px`（art-bible §5.4 互动特写规格）
- 最多 12 张一行，超出时等比压缩至最小 `G-8 = 48 px` 宽；MVP 目标 ≤10 张避免压缩

**卡面视觉层级**（优先级从高到低）:
1. **卡文案**（`tr(card_data.text_key)` 渲染，12px 思源黑体，art-bible §7.2）
2. **AP 格子图标**（右上角，格子数 = `card_data.ap_cost`，16×16 px icon）
3. **NPC 名字**（若 `npc_target != null`，底部 8px bitmap，art-bible §7.2）
4. **`kpi_contribution`**（G-10 `kpi_contribution_visible=false` 默认隐藏；可配置为 6px 极小字灰色）

**禁止**：
- `kpi_contribution` 作为第一视觉层级（违反 P1 + `#11 Section B` 主锚）
- 卡面出现星级/进度条/收集感 UI 元素（违反 P4）
- AP 消耗时出现粒子效果或成就感 SFX（违反 P1 反英雄红线）

---

**Rule 4 — 卡选择交互**（`try_consume_ap` 守门协议，依赖 `#11 Rule 6`）

玩家点击卡片（鼠标左键 / Gamepad A 键）后，`#14` emit `card_selection_requested(card_id)`，`#11` 执行完整守门序列（`#11 Rule 6`）：

```
玩家点击卡片
→ #14 emit card_selection_requested(card_id)
→ #11 _on_card_selected():
    1. NPC LEFT 守门（#8 get_npc_state）
    2. mutex_group 守门（#11 内部）
    3. APEconomy.try_consume_ap(ap_cost) → #7
        ├── 成功 → #11 emit card_played → #14 更新手牌状态
        └── 失败 → #11 emit card_play_failed(card_id, reason)
                 → #14 执行 Rule 8 视觉反馈
```

**dry-run 预检**（`#7 Rule 9` 对应）：鼠标 hover 时执行 `APEconomy.dry_run_consume_ap(ap_cost)` 判断 → 提前灰显（不阻止点击，点击后走完整守门流程）。

**Gamepad 支持**：D-Pad 左右切换焦点卡，A 键确认；焦点态视觉为 `#C8963C` 外框 + 2px 跳动偏移（art-bible §7.5）。

---

**Rule 5 — NPC 立绘渲染**（`[RISK GUARD] R-CPU-2`，依赖 `#8 NPC Relationship`）

`long` 事件渲染时，`#14` 从 `event_data.npc_id` 查询立绘：

```gdscript
func _render_npc_portrait(npc_id: StringName) -> void:
    if npc_id == &"":
        portrait_node.visible = false  # 无 NPC 目标的 long 事件
        return
    var npc_state: NpcState = NpcRelationship.get_npc_state(npc_id)
    match npc_state:
        NpcState.ACTIVE, NpcState.LEAVING_ANNOUNCED:
            var sprite_key: String = _resolve_sprite_key(npc_id)
            portrait_node.texture = ResourceLoader.load(
                "res://assets/sprites/" + sprite_key)
            portrait_node.visible = true
        NpcState.LEFT:
            portrait_node.visible = false  # LEFT NPC 立绘不渲染（R-CPU-2 守门）
            # speaker_label 渲染 display_name_static（由 context_dict["NPC_NAME"] 提供）
        _:
            portrait_node.visible = false
            push_warning("[#14] Unknown NpcState for: " + npc_id)
```

**LEFT NPC fallback**（`#10 Rule 8` 同源）：
- 立绘节点隐藏（`portrait_node.visible = false`）
- 对白框 `speaker_label` 渲染 `context_dict["NPC_NAME"]`（已由 `#10 Rule 8` 填充为 `display_name_static`）
- 对白文本正常渲染（此路径针对 npc_id 已 LEFT 但仍有事件变体的情况）

**立绘规格**（art-bible §5.4）：
- 事件 CG 主立绘：128×192 px，文件命名 `npc_[npcid]_cg_[emotion]_128x192.png`
- 互动特写头像：64×96 px，文件命名 `npc_[npcid]_portrait_[state]_64x96.png`
- 位置：屏幕中央偏左（`G-5 portrait_position_x_ratio = 0.35`）
- 帧数：≤4 帧（art-bible §5.3 姿态库上限）

**[RISK GUARD] R-CPU-2**: 若 `#14` 对 LEFT NPC 未执行 `portrait_node.visible = false` 而继续渲染立绘，则出现已离职 NPC 视觉幽灵（违反 `#8 R-NPC-2 LEFT NPC 立绘 leak`）。

---

**Rule 6 — 对白渲染**（依赖 `#3 Localization Hooks` Rule 4+5，`#10 Rule 8`）

`long` 事件对白文本渲染协议：

```gdscript
func _render_dialogue(variant: VariantBlock, context_dict: Dictionary) -> void:
    # text_key 由 #10 持有，context_dict 模板变量已由 #10 Rule 8 注入
    var raw_text: String = tr(variant.text_key)          # #3 Localization tr() 调用
    var rendered_text: String = raw_text.format(context_dict)  # 模板变量替换
    dialogue_label.text = rendered_text                  # dispatch ≤ 1 帧（#3 Rule 5）
```

**模板变量渲染**（`#3 Rule 4` + `#10 Rule 8`）：
- 所有 `{{NPC_NAME}}` / `{{TASK}}` / `{{SCENARIO}}` / `{{MONTH}}` 变量在 `context_dict` 中已由 `#10` 运行时注入完毕
- `#14` **不执行模板变量替换逻辑**，只调用 `String.format(context_dict)` 完成最终渲染
- LEFT NPC `{{NPC_NAME}}` fallback：`context_dict["NPC_NAME"]` 已由 `#10` 填充为 `display_name_static`

**字体规格**（art-bible §7.2）：
- 对白正文：思源黑体 Regular 12px，颜色 `#E8E0CC`（白炽灯白）
- 对话框背景：`#1A2A38`（屏幕蓝光加深，art-bible §4.4）
- 边框：`#2A1F14` 2px（咖啡渍棕黑）

---

**Rule 7 — 选项渲染**（依赖 `#10 Rule 10`，`choice_selected` emit 契约）

`long` 事件选项渲染规则：

**数量**：≤ 3 个选项（`#10 Rule 10` 硬约束；`tools/event_lint.gd` CI 阻塞）。**强制 ≥ 1 个无条件可选 choice**（`#10 Rule 10` lint 守门）。

**灰显条件**（双重守门）：
1. `choice.conditions` 不满足（关系/flag/AP 条件未达） → 灰显（`modulate.a = 0.5`）
2. `choice.ap_cost > APEconomy.current_ap`（AP 不足） → 灰显 + AP 格子闪烁（Rule 8 反馈机制）

**灰显 UI 规范**：
- 灰显选项：`modulate = Color(0.5, 0.5, 0.5, 0.7)`
- **无 tooltip 解释**（沉默式守门，P4 黑色幽默，同 Rule 3 NPC LEFT 卡处理）
- 灰显选项仍可 hover 聚焦（不可点击执行）

**全选项禁用 fallback**（`[RISK GUARD] R-CPU-3`）：
```gdscript
func _check_and_fix_all_disabled(choices: Array) -> void:
    if choices.all(func(c): return _is_choice_disabled(c)):
        push_error("[#14] All choices disabled — schema violation for: " + _active_event_id)
        _force_enable_first_choice()  # 强制启用第一个，防止玩家卡死
```

**选项点击流程**：
```
玩家点击选项 [index]
→ #14 emit choice_selected(event_id, choice_index)
→ #10 订阅，执行 EXECUTING_EFFECTS
→ #14 收到 event_completed → 关闭 long 面板 → 恢复手牌交互（hand_ui.set_process_input(true)）
```

---

**Rule 8 — AP 不足视觉反馈**（`card_play_failed` + 选项 AP 不足处理）

`#11` emit `card_play_failed(card_id, reason: String)` 时，`#14` 执行：

| reason | 视觉反馈 | 时长 |
|--------|---------|------|
| `"INSUFFICIENT_AP"` | 卡片 shake 2 帧（±2px 水平）+ AP 格子图标闪 `#F5C400` 1 帧（art-bible §7.3 UI 警告黄） | 即时 2 帧 |
| `"MUTEX_GROUP_PLAYED"` | 同组卡片已灰显，无额外反馈 | N/A |
| `"NPC_LEFT"` | 无反馈（卡在 Rule 3 已灰显，守门已在 `#11` 层完成） | N/A |

**禁止**：
- AP 不足时出现 toast 弹窗（违反 P4 — 沉默式处理）
- 出现"AP 不足，需要 X 点"文字提示（数字说教违反 P1 反英雄）

---

**Rule 9 — `event_started` 接收协议 + `choice_selected` emit**

**接收协议**（Scene 根节点注册）：

```gdscript
func _ready() -> void:
    EventScriptEngine.event_started.connect(_on_event_started)
    EventScriptEngine.event_completed.connect(_on_event_completed)

func _on_event_started(event_id: StringName, narrative_tier: String) -> void:
    if event_id in FAREWELL_EVENT_IDS:  # Rule 2 离别强制覆盖
        _route_to_hud(event_id, "numeric_only")
        return
    match narrative_tier:
        "long":         _render_long_event(event_id)
        "flash":        _route_to_hud(event_id, "flash")
        "numeric_only": _route_to_hud(event_id, "numeric_only")
        _:              push_error("[#14] unknown narrative_tier: " + narrative_tier)

func _on_event_completed(event_id: StringName) -> void:
    if _active_long_event_id == event_id:
        _close_long_panel()
        hand_ui.set_process_input(true)
        _active_long_event_id = &""
```

**`choice_selected` emit**（`#10 I-8` 契约）：
```gdscript
signal choice_selected(event_id: StringName, choice_index: int)
# emit 时机：玩家点击选项按钮（Rule 7）
# #10 订阅此信号，执行 EXECUTING_EFFECTS
```

---

**Rule 10 — `flash` 事件 overlay 位置**（`#13 HUD` 分工边界）

`flash` 事件由 `#13 HUD` 渲染，`#14` 仅 emit `ui_route_to_hud(event_id, "flash")`。

**位置约定**（`#13` 执行，`#14` 声明约束供 `#13` 实现）：
- 屏幕底部安全区（距底边 `G-1 flash_bottom_margin_px = 48 px`）
- 不遮挡手牌区（手牌区顶部 y 坐标 > flash overlay 底部 y 坐标）
- `flash` 持续 < 3s，淡出 `G-3 = 1 帧`（即时消散）

**`long` 事件期间 `flash` 并发处理**：
- `long` 进行中，新 `flash` 触发 → `#10 Rule 20` 每帧最多 1 事件保证队列化；`#14` 不干预 `#10` 队列
- `numeric_only` 无需排队，直接转 `#13`

---

**Rule 11 — 帧预算 ≤ 2ms/屏**（`#6 Rule 3` 主线程 16.6ms 分摊）

**`#14` 允许帧预算**：
- `long` 事件接管态：≤ 2ms（立绘 preload 后指针赋值 ≤0.5ms + 对白 `Label.text` ≤0.5ms + 选项 Button ×3 ≤0.3ms + 其他 ≤0.7ms）
- `ACTION_DAY` 手牌态：≤ 1ms（手牌布局预计算，非每帧重排）
- `flash`/`numeric_only` 转发：≤ 0.1ms（仅 emit 信号，渲染由 `#13` 分摊）

**Godot 4.6 实现规约**：
- 立绘使用 `ResourceLoader.load_threaded_request()` 预加载（`MORNING_BRIEFING` sub-mode 时预加载当日可能触发的 NPC 立绘）
- 手牌 `HBoxContainer` 布局：禁止每帧重算 `minimum_size`，用 `set_custom_minimum_size` 固定（布局仅在手牌变化时触发）
- `Label.text` 赋值仅触发一次（避免 `autowrap` 每帧重复计算）

---

**Rule 12 — 主语翻转 + Pillar 4 反英雄 Lint**

`#14` 渲染路径上所有**玩家面对文本**（选项按钮 label / 对白框 / 系统提示）须通过主语翻转 lint（继承 `#10 Rule 19` + `#3 Rule 11` 三层执法体系）：

**Lint 扫描范围**（`subject_inversion_lint.py` 扩展，CI 阻塞 PR）：
- `CARD.*` 文本 key（卡面文案）
- `EVENT.*` 文本 key（事件对白）
- `CHOICE.*` 文本 key（选项标签）

**`#14` 专属禁止**（除 `#10 Rule 19` 全局禁止外）：
- 选项按钮旁不出现"推荐" / "最优" / "Best" 标注（P1 破坏）
- 立绘旁不出现关系变化浮动数字（P2 数值化破坏叙事沉浸）
- AP 格子不出现"高效" / "好的一天"类正向语义标注（P1 反英雄）

---

**Rule 13 — Save 无持久化（纯渲染层）**

`#14` 是纯 Presentation 层，**不持有任何需要 Save 的状态**：
- 当前手牌列表：由 `#11` 持有并持久化（`#1 Save Rule 6` snapshot）
- `long` 事件进行状态：Session 内存，中断后由 `#10 event_history` 重建（不重播 UI）
- 选项选择历史：由 `#10 flag_dict` 持久化
- 立绘 preload 状态：Session 内存，每次启动重新 preload

**意义**: `#14` crash/reload 不会导致任何 Save 数据丢失，UI 状态从 `#10` / `#11` / `#8` 重建即可。

---

**Rule 14 — Scope Tier**

| Tier | 手牌 | 立绘 | 选项 | 三档密度 |
|------|------|------|------|---------|
| **MVP** | 8-10 张固定布局，AP 格子 + 文案 + 隐藏 KPI | 每 NPC 互动特写 64×96 × 1 + 事件 CG 128×192 × 1 | ≤3 选项，灰显无 tooltip | 三档完整：`long` 立绘+对白+选项 / `flash`+`numeric_only` 转 `#13` |
| **VS** | 10-12 张，hover 扩展预研（OQ-CPU-06） | 每 NPC 增加 2 情绪变体（64×96 × 2 + 128×192 × 2）| 4-5 选项研究（需 `#10` schema 扩展）| 同 MVP + 分辨率响应字体动态调整 |
| **野心版** | 手牌分组标签 / 历史查看 | 全配音（voice-over 绑定渲染时序） | 同 VS | 同 VS + 双语切换（`#3` 野心版）|

---

### States and Transitions

| 状态 | 描述 | 进入条件 | 退出条件 |
|------|------|---------|---------|
| `HAND_IDLE` | 手牌可见可交互；无 `long` 事件面板 | `ACTION_DAY` / `ACTION_OVERTIME` sub-mode 进入 | `long` 事件触发 → `LONG_EVENT_ACTIVE`；scene 切换 → `HAND_HIDDEN` |
| `LONG_EVENT_ACTIVE` | `long` 事件全屏接管；手牌不可交互 | `event_started("long")` 信号接收 | `event_completed` 信号接收 → `HAND_IDLE` |
| `HAND_HIDDEN` | 手牌不可见（MORNING_BRIEFING / numeric_only 非行动时段） | 非 `ACTION_DAY` / `ACTION_OVERTIME` sub-mode | `ACTION_DAY` / `ACTION_OVERTIME` 进入 → `HAND_IDLE` |

**Sub-state（`LONG_EVENT_ACTIVE` 内部）**：
- `RENDERING_DIALOGUE`：对白正在渲染（text 赋值，≤1 帧）
- `WAITING_PLAYER_CHOICE`：选项按钮渲染完成，等待点击（镜像 `#10 WAITING_PLAYER_CHOICE` state）
- 两个 sub-state 由 `#10` state 驱动，`#14` 跟随

---

### Interactions with Other Systems（7 contracts）

| # | 对端 | 方向 | 主接口 |
|---|------|------|--------|
| I-1 | `#10 Event Script Engine` ⭐ | 订阅 | 订阅 `event_started(event_id, narrative_tier)` + `event_completed`；emit `choice_selected(event_id, choice_index)` + `ui_route_to_hud(event_id, tier)` |
| I-2 | `#11 Action Card` | 双向 | emit `card_selection_requested(card_id)`；订阅 `card_played` / `card_play_failed(card_id, reason)` |
| I-3 | `#3 Localization Hooks` | 调用 | `tr(text_key)` + `String.format(context_dict)`；dispatch ≤ 1 帧（Rule 5） |
| I-4 | `#7 AP Economy` | 查询 | 读 `APEconomy.current_ap` + `dry_run_consume_ap(cost)` 用于 hover 预检；`try_consume_ap` 由 `#11` 调 |
| I-5 | `#8 NPC Relationship` | 查询 | `NpcRelationship.get_npc_state(npc_id)` 用于立绘渲染决策（Rule 5）+ 卡 LEFT 灰显（Rule 3） |
| I-6 | `#13 HUD Diegetic` | emit | emit `ui_route_to_hud(event_id, "flash")` / `ui_route_to_hud(event_id, "numeric_only")`；`#13` 负责 flash/numeric_only 实际渲染 |
| I-7 | `#1 Save System` | 参考约束 | 本 GDD 无持久化（Rule 13）；`final_transition_duration_ms = 1500`：GAME OVER 时 `#14` 面板须在 1500ms 内完成关闭（`#10 Rule 17` 触发 → `#16` 接管） |
| I-8 | `#17 Settings UI` | 订阅 | 订阅 `narrative_density_changed(tier)` 信号(ADR-0001 + ADR-0004 + ADR-0012,B-DEP-1 守门);**主消费 layer**(per ADR-0012):本 GDD 实施 `_select_dialogue_keys_by_density(event, density)` + `_select_effects_by_density(event, density)` fallback 链(brief → standard → verbose,standard 必填);EVENT_ACTIVE 态期间切档延后下次 `event_started`(`_pending_density_for_next_event` 变量,`#10 Rule 25` 同步);`#15 Recap UI` 共享 fallback 函数 |

---

## Section D: Formulas

> **本 GDD 是纯渲染层，无独立数学公式。** 所有数值逻辑（AP 计算 / NPC 关系 / 事件权重抽取）由上游系统 own。本节记录两项渲染层计算：

### F1 — 帧预算分摊

```
total_frame_budget_ms = 16.6（60 FPS）
budget_14 = total_frame_budget_ms × UI_SHARE_RATIO

推荐 UI_SHARE_RATIO = 0.12（6 UI 系统各约 12%，合计 72%；留 28% 给世界层 + 逻辑系统）
budget_14 = 16.6 × 0.12 ≈ 2.0ms（硬上限）
```

| 变量 | 范围 | 描述 |
|------|------|------|
| `total_frame_budget_ms` | 16.6ms | 60 FPS 帧预算（`#6 Rule 3`） |
| `UI_SHARE_RATIO` | [0.08, 0.15] | `#14` 占帧比例（tuning，需 Profiler 实测后校准） |
| `budget_14` | ≤ 2.0ms | `#14` 硬上限，超出 push_warning + Profiler tag |

**分摊明细估算**：

| 操作 | 估算耗时 |
|------|---------|
| 立绘 `TextureRect` 更新（preload 后指针赋值）| ≤0.5ms |
| 对白 `Label.text` 赋值 | ≤0.5ms |
| 选项 `Button` ×3 更新 | ≤0.3ms |
| 手牌 `HBoxContainer` 布局（变化时触发一次） | ≤0.5ms |
| 信号 emit 开销（`ui_route_to_hud` 等）| ≤0.2ms |

### F2 — 模板变量绑定时机

```
render_delay = T_tr + T_format

T_tr    = f(locale, key_lookup)       ≤ 0.1ms（#3 Rule 5 dispatch ≤1 帧约束）
T_format = f(context_dict_size)       ≤ 0.05ms（String.format() 线性 key 数量）
render_delay ≤ 0.15ms（总上限）
```

**触发时机**：`event_started` 信号接收后**同帧**完成 `tr()` + `format()`，不分帧（`#3 Rule 5` 跨 GDD 同质约束）。即使 `narrative_tier = "numeric_only"` 也在同帧完成（虽然 `#14` 不渲染，`#10` 仍在同帧 emit `event_started`）。

---

## Section E: Edge Cases

35 edges / 6 categories / 3 [RISK GUARD]

### Cat 1: 三档密度切换 race

**1.1** `event_started` 信号中 `narrative_tier` 为空或 null → push_error("[#14] narrative_tier missing for: " + event_id) + 降级为 `"flash"` 路径（防止空白 `long` 面板；最小影响 fallback）

**1.2** 两个 `event_started` 信号在连续帧触发（`#10 Rule 20` 每帧最多 1 事件，但极端情况下信号 connect 异步不保证顺序）→ `#14` 维护 `_pending_event_queue: Array[StringName]`；第一个事件处理中时，后续事件入队；`numeric_only` 无需排队直接转 `#13`

**1.3** `long` 事件进行中新 `event_started` 到达 → 排队至当前 `long` `event_completed` 后处理；GAME OVER 触发（`#10 Rule 17`）时强制中断当前 `long`，emit `event_interrupted(event_id)`，立即转 `#16` GAME OVER 流程

**1.4** `narrative_tier` 值为未知枚举（schema 版本不兼容） → push_error + fallback `"flash"` 路径；`#10 Rule 13` 静态 lint 应在 CI 阻止此情况到达运行时

**1.5** 玩家在 Settings 切换叙事密度时（`meta_settings_debounce_ms = 500ms` 守门），当前 `long` 事件进行中 → 本次事件继续用原密度完成，新密度从下次 `event_started` 起生效

### Cat 2: 离别强制 `numeric_only` 边界

**2.1** `FAREWELL_EVENT_IDS` 列表与 `#10` schema 中 `farewell_events` 不同步 → CI lint 阶段 `tools/event_lint.gd` 比对两处列表，不一致 BLOCK PR（`#10 Rule 13` 扩展约定，需 `#10 GDD` review 时确认）

**2.2** 离别事件 `#10` schema 标记为 `narrative_tier: "long"`，但 `#14` Rule 2 强制覆盖 → 覆盖执行 + push_warning("[#14] Farewell event overriding long→numeric_only: " + event_id)（预期行为，非 bug）

**2.3** 同帧触发两个离别事件（极端情况：两 NPC 同日离职）→ 两者均 emit `ui_route_to_hud("numeric_only")`，`#13` 按队列处理；`#14` 无 UI 渲染，无 race 风险

**2.4** 离别事件 `context_dict` 含 `{{NPC_NAME}}` 变量（`display_name_static` fallback）→ `#14` 不渲染对白框；`context_dict` 完整传至 `ui_route_to_hud` emit 供 `#13` 需要时读取（`#13` 自行决定是否渲染名字）

### Cat 3: NPC LEFT 立绘边界

**3.1** `npc_state = LEFT` 时 `long` 事件仍触发（`#10` schema npc_arc_tag 事件可能跨态）→ Rule 5 LEFT 判断：`portrait_node.visible = false` + speaker_label 渲染 `display_name_static` → fallback 完整处理

**3.2** `npc_id = null`（无 NPC 目标的 `long` 事件，如"全公司通知"）→ 立绘节点隐藏，无 speaker_label，正常渲染对白文本（Rule 5 `npc_id == ""` 分支）

**3.3** 立绘文件路径 404（asset 未产出）→ `ResourceLoader.load()` 返回 null → push_error("[#14] Portrait not found: " + sprite_key) + `portrait_node` 显示 placeholder 灰块（16×16 兜底）+ 对白框正常渲染（立绘缺失不影响对白流程）

**3.4** `NpcState.RETURNED`（VS 扩展状态，MVP 无）→ MVP 中 match `_` 分支执行 `portrait_node.visible = false` + push_warning("[#14] RETURNED state not impl in MVP") + 对白框正常渲染

**3.5** NPC 立绘 preload 失败（`MORNING_BRIEFING` 时 preload 未完成）→ 运行时 `ResourceLoader.load()` 同步回退（帧预算超限风险）+ push_warning；OQ-CPU-01 记录，Alpha gate 前必须解决

### Cat 4: 选项全 disabled 边界

**4.1** `long` 事件所有选项 `conditions` 均不满足 → Rule 7 `_force_enable_first_choice()` 执行 + push_error（schema 违反 `#10 Rule 10` 强制 ≥1 无条件 choice）

**4.2** `long` 事件 `choices` 数组为空（schema 错误）→ push_error("[#14] No choices defined for: " + event_id) + 执行 `auto_advance()`（无需玩家选择，`event_completed` 信号模拟）；`#10 tools/event_lint.gd` 应在 CI 阻止此情况

**4.3** `choices` 数量 > 3（`#10 Rule 10` 限制）→ 仅渲染前 3 个 + push_warning（静态 lint 应在 CI 阻止，但运行时防御必要）

**4.4** `choice.ap_cost > APEconomy.MAX_AP_PER_DAY`（显然无法执行的选项）→ 灰显 + push_warning（设计 bug，`#10` lint 应阻止）

### Cat 5: 卡 AP cost 不足边界

**5.1** 玩家手牌全部 `ap_cost > current_ap`（所有卡无法打出）→ 手牌全灰显（dry-run 预检触发）；早退入口由 `#6` 提供（`#14` 不干预时序）

**5.2** `current_ap = 0` 时手牌刷新（通常 `#6` 会推进 sub-mode）→ 全灰显；`#6` 应自动触发 `ACTION_DAY_END`；`#14` 仅视觉响应

**5.3** 卡片 `ap_cost = 0`（schema 违规）→ `#11 Rule 1` CI lint BLOCK；运行时 push_error + 跳过此卡（不渲染）

**5.4** hover dry-run 预检结果与实际点击时 `try_consume_ap` 不一致（AP 在同帧被其他系统消耗）→ 点击后走完整 `#11` 守门；`#14` 执行 Rule 8 shake 反馈；预检仅为 UX 辅助，不作强一致保证

### Cat 6: 帧预算超限

**6.1** 立绘同步加载（非 preload 路径）导致 `#14` 单帧 > 2ms → push_warning "[#14] frame budget exceeded: portrait sync load" + Profiler tag；OQ-CPU-01 记录，Alpha gate 前解决

**6.2** 手牌 12 张满载时 `HBoxContainer` layout 超限 → 触发一次后缓存，后续帧复用；`minimum_size` 不每帧重算（Rule 11 Godot 4.6 规约）

**6.3** 同帧 `long` 事件开启 + 手牌变更（理论上 `#10` 队列保证不会同帧，但防御）→ `long` 优先；手牌变更延至 `event_completed` 后 + push_warning

**[RISK GUARD] R-CPU-1（跨守 `#10 R-EVT-5`）**: 离别事件 `narrative_tier = "long"` 时 `#14` 未执行 Rule 2 强制覆盖 → 渲染 LISA_GOODBYE 立绘+对白（违反 Pillar 3/4 沉默美学 + `#10 Rule 6`）。测试：`force_trigger("LISA_GOODBYE")` 断言 `portrait_node.visible == false` + `long_panel.visible == false`。

**[RISK GUARD] R-CPU-2（跨守 `#8 R-NPC-2`）**: LEFT NPC 立绘 leak — Rule 5 `visible = false` 漏调 → 已离职 NPC 视觉幽灵。测试：将 NPC 设置 LEFT 后 `force_trigger` 以此 NPC 为 npc_id 的 `long` 事件，断言 `portrait_node.visible == false`。

**[RISK GUARD] R-CPU-3（跨守 `#10 Rule 10`）**: 全选项 disabled + 无无条件 fallback → `#14` 等待状态（玩家无法选择，游戏卡死）。测试：构造所有 conditions 不满足的事件，断言 `_force_enable_first_choice()` 执行 + 第一个按钮 `disabled == false` + push_error 记录。

---

## Section F: Dependencies

### Upstream（`#14` 依赖）

| 系统 | 接口 | 方向 | 契约 |
|------|------|------|------|
| `#10 Event Script Engine` ⭐ | `event_started(event_id, narrative_tier)` / `event_completed` | `#10` → `#14` | 强制契约：三档密度独立渲染 + `choice_selected` emit 回 `#10`；离别 3 event_id 强制 `numeric_only` |
| `#11 Action Card` | `card_played` / `card_play_failed(card_id, reason)` / 手牌列表 | `#11` → `#14` | `try_consume_ap` 守门由 `#11` 执行，`#14` 仅响应结果信号 |
| `#3 Localization Hooks` | `tr(key)` + `String.format(ctx)` | `#14` 调 | dispatch ≤ 1 帧（`#3 Rule 5`）；模板变量 `ctx` 由 `#10 Rule 8` 注入 |
| `#7 AP Economy` | `APEconomy.current_ap`（查询）+ `dry_run_consume_ap(cost)` | `#14` 查 | 仅 dry-run 预检用；`try_consume_ap` 不由 `#14` 直接调 |
| `#8 NPC Relationship` | `get_npc_state(npc_id)` | `#14` 查 | 立绘渲染决策（Rule 5）+ 手牌 LEFT 灰显（Rule 3） |

### Downstream（`#14` 提供给）

| 系统 | 接口 | 方向 | 契约 |
|------|------|------|------|
| `#13 HUD Diegetic` | `ui_route_to_hud(event_id, tier: "flash"|"numeric_only")` | `#14` → `#13` | `flash` + `numeric_only` 路由到 `#13` 渲染；`#13 GDD` 须声明订阅此信号（`#13` 尚未设计，先确立契约） |
| `#10 Event Script Engine` | `choice_selected(event_id, choice_index)` | `#14` → `#10` | 玩家选项点击结果；`#10` 订阅并执行 EXECUTING_EFFECTS |
| `#11 Action Card` | `card_selection_requested(card_id)` | `#14` → `#11` | 卡片点击转发；`#11` 执行完整守门（NPC LEFT + mutex + try_consume_ap） |

### 双向一致性 cross-check

- `#10 I-8`：`#10` GDD Interactions I-8 声明 emit `event_started` 给 `#14` ✓（本 GDD Rule 9 订阅对应）
- `#11 Rule 6`：`#11` 声明 emit `card_play_failed` 给 `#14` ✓（本 GDD Rule 8 订阅对应）
- `#3 Rule 5`：`#3` 声明 dispatch ≤ 1 帧 ✓（本 GDD F2 公式对应）
- `#8 R-NPC-2`：`#8` 声明 LEFT NPC 视觉屏蔽守门 ✓（本 GDD Rule 5 + R-CPU-2 对应）
- `#13` 渲染分工：`flash` + `numeric_only` 由 `#13` own ✓（本 GDD Rule 1 + Rule 10 边界确认；**`#13 GDD` 尚未设计，本 GDD 先确立 `ui_route_to_hud` 信号契约，`#13` 设计时须引用本契约**）

---

## Section G: Tuning Knobs

### 所有 tuning knobs 存于 `assets/data/ui_card_play_dialogue.tres`

| # | Knob 名 | 类型 | 默认值 | 安全范围 | 分类 | 描述 |
|---|---------|------|--------|---------|------|------|
| G-1 | `flash_bottom_margin_px` | int | 48 | [32, 96] | Feel | flash overlay 与屏幕底部距离（px），须高于手牌区顶部 y（实测调整，OQ-CPU-03） |
| G-2 | `flash_display_duration_s` | float | 2.5 | [1.5, 3.0] | Feel | flash overlay 显示时长（s），硬上限 < 3s（`#10 Rule 6`） |
| G-3 | `flash_fadeout_frames` | int | 1 | [1, 3] | Feel | flash 消散帧数（1 = 即时，art-bible §7.4 官僚式迟钝仅演出层） |
| G-4 | `long_panel_darken_alpha` | float | 0.5 | [0.3, 0.7] | Feel | `long` 事件接管时世界层压暗 alpha（multiply overlay，art-bible §7.1） |
| G-5 | `portrait_position_x_ratio` | float | 0.35 | [0.25, 0.45] | Feel | 立绘水平位置（屏幕宽度比例，0.35 = 偏左 35%） |
| G-6 | `dialogue_box_width_ratio` | float | 0.55 | [0.45, 0.70] | Feel | 对话框宽度（屏幕宽度比例，需实测 1280×720 最小分辨率，OQ-CPU-02） |
| G-7 | `choice_button_height_px` | int | 32 | [24, 48] | Feel | 选项按钮高度（px，影响可点击面积） |
| G-8 | `hand_card_min_width_px` | int | 48 | [40, 64] | Feel | 手牌最小卡宽（触发压缩时下限，art-bible §5.4 规格下限） |
| G-9 | `hand_card_max_count` | int | 12 | [8, 14] | Gate | 手牌最大显示数量（超出时触发压缩，MVP 建议 ≤10） |
| G-10 | `kpi_contribution_visible` | bool | false | — | Gate | `kpi_contribution` 是否在卡面显示（MVP 默认 false — P1 守门） |

**跨 GDD 引用**：
- `meta_settings_debounce_ms = 500ms`（entities.yaml，Save Rule 14）：叙事密度设置切换防抖，1.5 内 `long` 事件不受设置切换影响
- `final_transition_duration_ms = 1500ms`（entities.yaml，Save Rule 21）：GAME OVER 时 `#14` 面板须在 1500ms 内关闭（不阻塞 `#16` 接管）

---

## Visual/Audio Requirements

### 视觉资产（`#14` owns 渲染规格 + 技术约束；art-director owns 实际制作）

**本 GDD 是 Presentation Layer 关键渲染屏 owner**（`long` 事件期间接管全屏，是玩家主要叙事体验界面）。

| 资产类型 | 规格 | 命名约定（art-bible §8.1） | MVP 数量 |
|---------|------|--------------------------|---------|
| NPC 事件 CG 主立绘（`long` 主用） | 128×192 px（art-bible §5.4 事件 CG 层） | `npc_[npcid]_cg_[emotion]_128x192.png` | 8 NPC × 1-2 情绪 = 8-16 张 |
| NPC 互动特写头像（speaker 区） | 64×96 px（art-bible §5.4 互动特写层） | `npc_[npcid]_portrait_[state]_64x96.png` | 8 NPC × 1 状态 = 8 张 |
| 卡片背景（AP cost 三版） | 64×96 px | `ui_card_bg_[cost]ap_64x96.png`（1/2/3 AP） | 3 张 |
| AP 格子图标（filled/empty 两版） | 16×16 px（art-bible §7.3 图标层） | `ui_icon_ap_filled_16x16.png` / `ui_icon_ap_empty_16x16.png` | 2 张 |
| 对话框背景（9-slice） | 可扩展任意尺寸 | `ui_dialogue_bg_9slice.png` | 1 张 |
| 选项按钮（normal/hover/disabled/focus 四态） | 48×24 px | `ui_btn_choice_[state]_48x24.png` | 4 张 |

**📌 Asset Spec Flag**: Phase 4 须 `/asset-spec system:card-play-dialogue-ui` 出具 NPC 立绘制作 brief（128×192 事件 CG 8 NPC × 情绪规格 + 64×96 互动特写规格 + 产量可行性评估），供 art-director 制作排期（OQ-CPU-01 前置）。

### 音频（`#14` 不 own 音频；依赖 `#4 Audio Manager`）

- `long` 事件开启：**无 BGM 切换**（`#4 Rule 7` 白名单 — 仅月末/GO 可触发 BGM）
- `long` 事件期间：background ambient 继续（`#14` 不调任何 Audio API）
- 选项点击 SFX / 卡片点击 SFX：由 sound-designer + `#4` 决定（本 GDD 不规定，但须满足 P1 反英雄红线：无成就感/金光 SFX）
- `flash` / `numeric_only` 音频：由 `#13` 决定（`#14` 已转发，不干预）

### UI Pillar 4 红线汇总（可视化审查清单）

| 禁止元素 | 违反规则 |
|---------|---------|
| 选项旁"推荐" / "最优" / "Best" 标注 | P1 + Rule 12 |
| 立绘旁关系变化浮动数字（+3/-5）| P2 + Rule 12 |
| 卡面 `kpi_contribution` 大字显示（G-10=false） | P1 + Rule 3 |
| NPC LEFT 卡"无法交互 / Lisa 已离职"tooltip | P4 + Rule 3 |
| AP 消耗粒子效果 / 成就感 SFX | P1 反英雄 + Rule 8 |
| `long` 事件期间 BGM 切换 | `#4 Rule 7` 白名单 |

### 📌 UX Flag

Phase 4 必跑：
- `/ux-design design/ux/event-dialogue-screen.md`（`long` 事件全屏渲染 UX 规格：立绘位置 / 对话框布局 / 选项交互 / Gamepad 焦点链）
- `/ux-design design/ux/card-play-screen.md`（手牌 UI + AP 格子 + 选卡交互 UX 规格：卡面层级 / hover 预检视觉 / 灰显无 tooltip）

---

## Open Questions

**OQ-CPU-01** — NPC 立绘产量可行性：128×192 事件 CG 8 NPC × 1-2 情绪 = 8-16 张 + 64×96 互动特写 8 张，总计 16-24 张 CG 级资产。art-bible §5.5 单人 3 月产量上限（每 NPC 16 张）与此数量是否冲突？是否需要降级至"部分 NPC 仅头像，无 CG"？**Owner**: art-director + producer。**Target**: Asset Spec Phase 4（`/asset-spec` 前置 — blocking OQ）

**OQ-CPU-02** — `long` 事件选项按钮布局实测：3 个选项按钮在 1920×1080 对话框右侧垂直布局是否可读？在 1280×720 最小分辨率下 G-6/G-7 是否需要调整？**Owner**: ux-designer。**Target**: Vertical Slice 首个构建实测

**OQ-CPU-03** — `flash` overlay 与手牌区位置冲突：G-1 `flash_bottom_margin_px = 48` 是否足以避免遮挡手牌区？手牌区实际高度（MVP 8 张卡 + padding）需 Prototype 阶段测量后确定是否调整 G-1 至 [64, 96]。**Owner**: ux-designer + godot-specialist。**Target**: Prototype 阶段 UI 布局实测

**OQ-CPU-04** — 关键叙事节点三档密度 override 策略：玩家设置 `numeric_only` 密度时，对 `#10 Rule 15` Tier 1 必含事件（如 LISA_LUNCH_DILEMMA / BOSS_MONTH_REVIEW_1）是否应强制 `long` 档？当前 `#10 Rule 6` 规定由 schema `narrative_tier` 决定并 `R-EVT-5` 守门缺失 fallback。是否需要在 `#14` 层增加"关键事件密度 override 白名单"？**Owner**: game-designer + narrative-director。**Target**: `#10 GDD` review 后讨论（propagation flag 候选）

**OQ-CPU-05** — `LEAVING_ANNOUNCED` 立绘变体：NPC `LEAVING_ANNOUNCED` 状态时立绘是否有专属情绪变体（区别于 `ACTIVE`）？影响立绘资产数量估算（OQ-CPU-01 关联）。**Owner**: art-director + narrative-director。**Target**: `#8 NPC GDD` review 后联动

**OQ-CPU-06** — 手牌 hover 扩展（VS 阶段）：VS 是否引入卡片 hover 时展开卡面详情（event preview / 历史次数）？影响帧预算 F1 分摊及 art-bible §5.4 LOD 扩展需求。**Owner**: ux-designer + game-designer。**Target**: VS kickoff 设计讨论

---

## Section H: Acceptance Criteria

22 AC / 5 categories / 3 [RISK GUARD]

### AC-FUNC（功能正确性）— 12 条

**AC-FUNC-01** (MVP): Given `event_started("LISA_LUNCH_DILEMMA", "long")` 触发，When `#14` 接收信号，Then `long_panel.visible == true` + `portrait_node` 加载 Lisa 立绘（路径非 null）+ `dialogue_label.text` 无原始 `{{` 占位符 + `choice_button` 数量 ≥ 1 且至少 1 个 `disabled == false`。

**AC-FUNC-02** (MVP): Given `event_started("any_flash_event", "flash")` 触发，When `#14` 接收，Then emit `ui_route_to_hud("any_flash_event", "flash")` 发出（信号连接验证）+ `long_panel.visible == false` + `hand_ui.process_input == true`（手牌不被锁定）。

**AC-FUNC-03** (MVP): Given `event_started("any_numeric_event", "numeric_only")` 触发，When `#14` 接收，Then emit `ui_route_to_hud("any_numeric_event", "numeric_only")` 发出 + `#14` 无任何自身 UI 节点 `visible == true`（长为 0 的 `get_visible_children()` 断言）。

**AC-FUNC-04** (MVP) `[RISK GUARD R-CPU-1]`: Given `event_started("LISA_GOODBYE", "long")` 触发（模拟 schema 错误标记），When `#14` Rule 2 强制覆盖执行，Then `long_panel.visible == false` + emit 携带 `"numeric_only"` 的 `ui_route_to_hud` 发出 + push_warning 记录（日志断言 contains "[#14] Farewell event overriding"）。同等适用 `CLEANING_AUNT_LEAVE` / `FISH_MONK_LAID_OFF`。

**AC-FUNC-05** (MVP) `[RISK GUARD R-CPU-2]`: Given NPC 设置为 `NpcState.LEFT`，When 以该 NPC 为 npc_id 的 `long` 事件触发，Then `portrait_node.visible == false` + `speaker_label.text == display_name_static`（从 Save 持久化读取的离职前名字，非 "{{NPC_NAME}}" 原始占位符）。

**AC-FUNC-06** (MVP) `[RISK GUARD R-CPU-3]`: Given 构造所有 choices conditions 均不满足的 `long` 事件（无无条件 choice），When `#14` 渲染选项，Then `_force_enable_first_choice()` 执行（日志断言 push_error contains "[#14] All choices disabled"）+ 第一个 choice_button `disabled == false`（玩家不卡死）。

**AC-FUNC-07** (MVP): Given 玩家点击 AP 不足的卡片（`current_ap < card.ap_cost`），When `#11` emit `card_play_failed(card_id, "INSUFFICIENT_AP")` 接收，Then 卡片 shake 动画执行（位置偏移验证 ±2px）+ AP 格子图标 `modulate` 闪变为 `#F5C400` 后恢复 + 无 toast 节点 `visible == true`。

**AC-FUNC-08** (MVP): Given 玩家点击 `long` 事件中的可选选项 [index]，When `choice_selected(event_id, index)` emit，Then `#10` 收到信号（连接验证）+ `long_panel` 在 `event_completed` 信号后 `visible == false` + `hand_ui.set_process_input(true)` 执行。

**AC-FUNC-09** (MVP): Given 手牌包含 `npc_target` NPC 状态为 LEFT 的卡片，When 手牌渲染，Then 该卡 `modulate.s == 0.0`（完全去饱和）+ 无 tooltip 节点激活 + 点击后无 `card_selection_requested` emit（守门已在灰显层拦截）。

**AC-FUNC-10** (MVP): Given 手牌卡片 hover，When `dry_run_consume_ap(ap_cost)` 返回 false（AP 不足），Then 该卡 `modulate.a` 降低（预检灰显触发）；点击后 `#11` 仍执行完整守门 + Rule 8 shake 反馈（预检不替代守门）。

**AC-FUNC-11** (MVP): Given `long` 事件进行中（`LONG_EVENT_ACTIVE`），When 新 `event_started` 信号到达（非 GAME OVER），Then `_pending_event_queue.size() == 1` + 当前 `long` 事件继续（`long_panel.visible == true` 不改变）。

**AC-FUNC-12** (MVP): Given `context_dict["NPC_NAME"]` 由 `#10` 填充为 `"Lisa Chen"`（LEFT NPC display_name_static），When `#14` 渲染对白 `"{{NPC_NAME}} 把椅子拉过来"`，Then `dialogue_label.text == "Lisa Chen 把椅子拉过来"`（无 `{{` 原始占位符残留）。

### AC-PERF（性能）— 3 条

**AC-PERF-01** (MVP): Given `long` 事件开启帧（portrait + dialogue + choices 全渲染），When Godot Profiler 采集，Then `#14` 单帧 CPU 耗时 ≤ 2.0ms（F1 公式守门）。若立绘为 preload 路径，断言 `ResourceLoader.get_load_status(portrait_path) == THREAD_LOAD_LOADED` 在 `event_started` 触发前已完成。

**AC-PERF-02** (MVP): Given 手牌 12 张满载渲染 + 连续 60 帧无手牌变化，When Profiler 采集，Then 手牌 CPU 稳定 ≤ 1.0ms/帧（布局仅触发一次，后续帧不重算 `minimum_size`）。

**AC-PERF-03** (Beta): Given `tr(key).format(context_dict)` 连续执行 10 次（同 key），When Profiler 采集，Then 平均耗时 ≤ 0.10ms（缓存生效）；单次最大 ≤ 0.15ms（F2 公式守门）。

### AC-COMPAT（兼容性）— 4 条

**AC-COMPAT-01** (MVP): Given `#3 Localization` locale 为 `zh_CN`，When `#14` 渲染所有可见文本，Then 全文无 `{{` / `}}` 原始占位符 + 无 `LOC_KEY_NOT_FOUND` 前缀出现（自动化 text 节点扫描断言）。

**AC-COMPAT-02** (MVP): Given NPC 状态从 `ACTIVE` 变为 `LEFT`（`#8 npc_left_company` 信号），When `#14` 在下次手牌渲染时 re-query `get_npc_state`，Then 受影响卡的灰显状态在 1 帧内更新（不缓存旧状态超过 1 帧）。

**AC-COMPAT-03** (MVP — 需 `#13 HUD GDD` 设计后集成验证): Given `ui_route_to_hud(event_id, "flash")` emit，When `#13` 接收，Then `#13` 在 `G-1 flash_bottom_margin_px` 位置正确渲染 flash overlay（跨系统集成测试，`#13 GDD` 设计后补充）。

**AC-COMPAT-04** (MVP): Given Gamepad D-Pad 左右导航，When 手牌聚焦切换，Then 焦点态视觉为 `#C8963C` 外框 + 2px 跳动偏移（art-bible §7.5）；A 键确认执行 `card_selection_requested`；`long` 事件选项 D-Pad 上下导航可切换焦点 + A 键确认选项。

### AC-ROBUST（鲁棒性）— 5 条

**AC-ROBUST-01** (MVP) `[RISK GUARD R-CPU-1 验证]`: Given `FAREWELL_EVENT_IDS` 中任意 event_id 以任意 `narrative_tier` 值触发，When `#14` 处理，Then **0 个** `#14` 自身 UI 节点 `visible == true`（`long_panel.visible == false` + `portrait_node.visible == false`）+ `ui_route_to_hud` emit 携带 `"numeric_only"`。三个 event_id 各自测试一次。

**AC-ROBUST-02** (MVP) `[RISK GUARD R-CPU-2 验证]`: Given 任意 NPC 设置 `NpcState.LEFT`（inject state），When 该 NPC npc_id 的 `long` 事件 `force_trigger`，Then `portrait_node.visible == false`（自动化：inject state → force_trigger → assert node invisible）。覆盖 8 个 MVP NPC。

**AC-ROBUST-03** (MVP) `[RISK GUARD R-CPU-3 验证]`: Given 构造所有 choice conditions 均不满足的 `long` 事件（无 `null` condition choice），When `#14` 渲染选项，Then `_force_enable_first_choice()` 执行（push_error 日志断言）+ 第一个 `choice_button.disabled == false`（玩家不卡死验证）。

**AC-ROBUST-04** (MVP): Given 立绘文件路径 404（asset 未产出），When `#14` Rule 5 加载，Then 不 crash（`null` 检查通过）+ `portrait_node` 渲染 placeholder 灰块 + push_error 记录 + `dialogue_label` 正常渲染对白文本（立绘缺失不阻断对白流程）。

**AC-ROBUST-05** (Beta): Given 连续 30 次 `long` 事件触发（压力测试：open + choice + close × 30），When 每次 `event_completed` 后面板关闭，Then Godot Memory Profiler 显示 `Label` + `TextureRect` 节点数量稳定（无增长 → 无内存泄漏）+ 第 30 次事件帧预算仍 ≤ 2.0ms（无累积劣化）。

### AC-TONE（Pillar 4 守护）— 3 条

**AC-TONE-01** (MVP): Given `long` 事件选项按钮渲染，When 视觉截图 + lint 检查，Then **0 个**按钮旁出现"推荐" / "最优" / "Best" / "最佳" 文字（主语翻转 lint `CHOICE.*` key 扫描：CI 阻塞断言 + 手动视觉验证）。

**AC-TONE-02** (MVP): Given `kpi_contribution_visible = false`（G-10 默认），When 手牌截图，Then 卡面无可见 `kpi_contribution` 数字（`kpi_label.visible == false` 断言 OR `kpi_label.modulate.a == 0` 断言）。

**AC-TONE-03** (MVP): Given NPC LEFT 状态卡片渲染，When 手牌截图 + 交互测试，Then 卡片灰显（saturation=0 断言）+ **无** tooltip 节点激活（hover 后 `tooltip_node.visible == false`）+ 无任何"无法交互"文字出现（文本节点扫描）。

---

*GDD End — Card Play & Dialogue UI (#14) | Status: Designed (pending review)*
