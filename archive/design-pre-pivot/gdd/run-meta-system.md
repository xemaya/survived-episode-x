# Run Meta System

> **Status**: Designed (pending review)
> **Author**: huanghaibin + game-designer (全文主笔)
> **Authoring autonomy mode**: v2 no-prompt (0 widget)
> **Last Updated**: 2026-04-27
> **Layer**: Feature | **Order**: #12 | **Size**: **S** (MVP simple 跨局元数据)
> **Implements Pillar**: P3 主(死亡是注定的 — 跨局 Run 寿命博物馆)+ P1 守(平庸是艺术 — 评语词条反讽成就)+ P4 守(苦中作乐黑色幽默 — HR 评语词条收集 tone 铁三角)
> **Anti-Pillar**: Anti-Pillar 1 红线(NOT 升职打怪 — 禁机械成长 unlock)+ Anti-Pillar 2 红线(NOT 励志叙事 — 禁正能量词条)

---

## Overview

**Run Meta System** 是《活过第 X 集》的**跨局元数据持久层**，承担双重身份：

**技术层**: 订阅 `#9 game_over_triggered(reason, month)` 接收每局 Run 的死亡月份作为"活过第 X 集"分数，写入 `RunSummary` 并归档；管理 `meta.unlocks`（content-only，Save Rule 22 铁律）；维护 Run Archive 列表（Save Rule 23 硬上限 200 条 FIFO 驱逐）；处理 MVP demo end 协议（3 月上限自动触发完整版预告）；接收 `#10 Event Script Engine` effect `run_meta_unlock(content_id)` 注入 content unlock。**自身不渲染 UI**（由 `#16 KPI Review & Game Over UI` own Archive 列表 + GAME OVER 屏渲染）。

**叙事层**: 每局 GAME OVER 后，本系统将"活过第 X 集"分数 +1，HR 评语词条归入跨局词库，RunSummary 入档案柜。玩家在 Archive 列表看到的不是"游戏次数"，而是一排"工号—死亡月份—最终评语"的**员工档案**。HR 评语词条是唯一横跨多局的"勋章"——不是 buff，是证明"我在这里活过"的印记。**这是 P3 的具象化器**：GAME OVER 不是失败红屏，是档案归档；Run 数字累积不是等级，是职业生涯化石。

### Pillar 服务

- **P3 主**: Run Archive 是"死亡是注定的"的博物馆形态。每个 RunSummary 永久存证（人走了，数据留下）；run_count 累积不会带来任何数值优势，只带来"我活过了第 N 集"自豪感
- **P1 守**: `meta.unlocks` 严格 content-only（Save Rule 22）。任何 `starting_ap_bonus` / `card_power_bonus` / `kpi_base_offset` 类字段禁入 — 违反即 PR-blocking（本 GDD Rule 4 + Save Rule 22 双重守门）
- **P4 守**: HR 评语词条 tone 继承 `#9 KPI Section B C3 "中规中矩的牺牲品"` 主锚。30+ 词条构成"HR 黑话词典"，每条保持事务性 HR 口吻，禁段子化禁正能量

### 5 NOT 边界（scope creep 防护）

- **NOT** KPI 数值计算（由 `#9 KPI System` own；`#12` 仅消费 `game_over_triggered` 中的 `month` + `actual_kpi_history` snapshot）
- **NOT** GAME OVER 屏渲染 / Archive 列表 UI（由 `#16 KPI Review & Game Over UI` own）
- **NOT** 离职证明文本（由 `#10 Event Script` GAMEOVER.CERTIFICATE.[reason] key own；`#12` 仅存 reason 枚举）
- **NOT** Run 内行动卡 / NPC 关系数值变更（均由各自系统 own；`#12` 仅接收完成快照）
- **NOT** Save 原子写 / 归档事务（由 `#1 Save System` Rule 9 ARCHIVING 流程 own；`#12` 提供数据结构，Save 做写盘）

### 5 NOT 红线（违反即破坏 Pillar）

- **NOT** unlock 携带任何数值 buff（违反 Anti-Pillar 1 + Save Rule 22）
- **NOT** run_count 影响新 Run 起始状态（禁"老手红利"）
- **NOT** Archive 批量删除 / 全清（违反 Save Rule 23 仪式感约束）
- **NOT** HR 评语词条正能量 / 励志语义（违反 Anti-Pillar 2 + P4 tone 执法）
- **NOT** demo end 触发后仍允许正常 Run 继续（MVP 3 月上限是绝对 gate）

### Source 引用

`save-system.md` Rule 21 `final_transition_duration_ms≤1500` + Rule 22 content-only unlocks + Rule 23 archive 200 cap + Rule 9 ARCHIVING 归档事务。`kpi-reverse-threshold-system.md` Rule 9 `game_over_triggered(reason, month)` + Rule 17 `actual_kpi_history` snapshot emit。`event-script-engine.md` Rule 17 GAMEOVER.CERTIFICATE.[reason] 离职证明文本 + effect `run_meta_unlock(content_id)` 注入协议。`kpi-reverse-threshold-system.md` Section B C3 "中规中矩的牺牲品"（HR 评语词条主锚）+ GAMEOVER.TITLE_IRONY "恭喜晋升"（Loc 三轨铁三角）。

---

## Player Fantasy

### 主锚 1: "我活过了第 11 集"（P3 自豪感）

**场景**:
GAME OVER。屏幕滑出离职证明风格摘要（`final_transition_duration_ms ≤ 1500`，linear，无 ease）。右下角静静出现:"**活过第 11 集**"——不是红字失败，是白底黑字档案编号。档案柜顺序推入一条：工号 #0011 · 死于 M11 · 最终评语"本月产出符合预期，谢谢"。

玩家翻开档案柜，看到前 10 条。每条有名字（Run 内第一次被 HR 系统叫到的花名）、死法、一句月末评语。第 3 条写的是"积极性可嘉的牺牲品"，第 7 条是"资深员工的责任"——全都是这个公司的遗迹，全都是同一个玩家的职业生涯切片。

**P3 "死亡是注定的"的具象化**: GAME OVER 不是惩罚，是归档。玩家不是"输了"，是"完成了一届任期"。档案柜证明这件事真实存在过。

**跨 GDD 共振**:
- **Save `#1`** "档案柜里我已经挂过 14 次" → `#12` 给这句话一个 UI 形态（Archive 列表）
- **KPI `#9`** C3 "中规中矩的牺牲品" 月末评语 → `#12` 让最后一条评语成为 RunSummary 的勋章字段
- **Localization** GAMEOVER.TITLE_IRONY "恭喜晋升" → `#12` run_count +1 是唯一的"晋升"

**❌ Tone 风险（必避）**:
- "你已解锁 11 集成就！"——成就感包装破坏冷静打卡机 tone
- 档案列表 UI 有庆祝动画 / 闪光——违反 Save Rule 21 `final_transition_easing=NONE` 同质原则

**✅ Tone 守护**:
- run_count 计数器是唯一计量器，无 XP 条、无经验值、无成长弧
- 档案柜是可翻阅的文件夹，不是成就展柜

---

### 主锚 2: "中规中矩的牺牲品"词条收集（P1 守 + P4 守）

**场景**:
第三局 GAME OVER 后，玩家打开"HR 评语词库"（Archive 列表子菜单）。里面已有 7 条跨局收集的不同评语词条，本局新增 2 条——"本月产出符合预期"与"组织感谢您的稳定贡献"。玩家注意到第 3 条"积极性可嘉的牺牲品"只出现了 1 次，而"中规中矩"出现了 3 次。

**这不是"解锁了什么新能力"**，是"我读懂了 HR 的话术逻辑"。词条是**叙事知识**，不是机械奖励。

**P4 "苦中作乐"最纯粹形态**: 玩家主动收集 HR 黑话，本身就是对职场语言游戏的元反讽参与。收集行为不需要 UI 弹出"恭喜！"——词条本身的语感就是奖励。

**跨 GDD 共振**:
- **KPI `#9` Section B C3** 月末评语 tone 锚 → `#12` 将词条跨局持久化，形成可查阅词库
- **Localization** `_IRONY` 后缀 key 规约 → `#12` 词条 key 全部走 `EVAL.*` domain
- **Audio** "月末打卡机不是胜利音" → 新词条入库时无成就音效（silence = tone 执法）

**❌ Tone 风险（必避）**:
- 词条 UI 有"新词条解锁！"pop-up——破坏事务性冷静 tone
- 词条内容网络梗化（"内卷"/"躺平"直接入词条）——破坏 HR 档案文书语感

**✅ Tone 守护**:
- 词条新增是静默的——仅在 Archive 查看时可见，无主动通知
- 词条文案永远描述性：描述玩家状态（"积极性可嘉"），不评价玩家能力（"你真的很努力"）

---

## Detailed Design

### Core Rules

**Rule 1 — Run Meta 状态字段（持久化 schema）**

`meta.save` 中 Run Meta 拥有以下字段（Save System `#1` 负责物理写盘，`#12` 负责逻辑 owner）:

```gdscript
# meta.save 中 run_meta 子 schema
{
  "run_count": int,              # 历代 Run 总数（含当前局）; 初始 0; 每局 GAME OVER +1
  "current_run_month": int,      # 当前活跃 Run 的月份索引; GAME OVER 后归 0
  "unlocks": Dict[String, bool], # content-only unlock 集合; key 格式见 Rule 4
  "archive": Array[RunSummary],  # 历代 Run 摘要列表; 上限 200 条(Save Rule 23)
  "hr_word_library": Array[String]  # 跨局收集的评语词条 key 列表(去重); 供 #16 Archive UI 展示
}
```

**Rule 2 — RunSummary Schema**

每局 GAME OVER 后写入一条 RunSummary：

```gdscript
{
  "run_id": int,                       # 单调递增; = run_count at time of death
  "month_index_at_death": int,         # 来自 #9 game_over_triggered(month)
  "reason": String,                    # 来自 #9 game_over_triggered(reason); 枚举:
                                       # "KPI_EXCEEDS_CAPACITY" / "DISMISSAL_SEVERE" /
                                       # "VOLUNTARY_QUIT" / "DEMO_END"
  "final_hr_evaluation_key": String,   # 该 Run 最后一条月末 HR 评语 Localization key
  "npc_relationships_snapshot": Dict[String, int],  # 8 NPC 最终 score; from #8
  "actual_kpi_history": Array[float],  # 月末实际 KPI 完成率序列; from #9 Rule 17
  "final_threshold": int,              # 死亡月份的 monthly_threshold; from #9
  "unlocks_earned_this_run": Array[String]  # 本局新获得的 unlock content_id 列表
}
```

**Rule 3 — GAME OVER 接收协议**

`#12` 订阅 `#9 game_over_triggered(reason: String, month: int)` 信号。收到后：

```
1. current_run_month = month（记录死亡月份）
2. 从 #9 读取 actual_kpi_history snapshot（#9 Rule 17 提供只读接口）
3. 从 #8 读取 npc_relationships_snapshot（8 NPC 最终 score）
4. 从 #9 读取当月最终 hr_evaluation_key（月末结算已完成，key 已确定）
5. 构建 RunSummary
6. 调用 archive_run(summary)（Rule 7 FIFO 驱逐守门）
7. run_count += 1
8. current_run_month = 0
9. emit run_ended(run_id, month, reason)
10. emit unlock_acquired(content_id) for each unlock_earned_this_run（若有）
```

**不自行触发 Save 写盘** — 交由 `#1 Save System` Rule 9 ARCHIVING 事务完成（`archive_complete` 信号触发 `#12` 的 meta 字段更新写入）。

**Rule 4 — content-only unlocks（Save Rule 22 强制）**

`meta.unlocks` 字段 **只允许** 以下 5 类 key（与 Save Rule 22 完全对应）：

| 允许 key 类型 | 示例 | 解锁效果 |
|--------------|------|---------|
| `codex_entry_id` | `"codex.hr_manual_page_3"` | Archive 解锁"HR 规章制度"条目 |
| `memo_id` | `"memo.lisa_farewell_note"` | 下局 HUD 便利贴池新增（flavor only） |
| `npc_unlock_id` | `"npc.old_oil_veteran"` | 老员工 NPC 进入下局候选池 |
| `event_branch_id` | `"event.boss_mentor_trap_branch_b"` | 事件分支 B 解锁 |
| `ending_unlock_id` | `"ending.voluntary_retirement"` | 主动退休结局路径解锁 |

**禁止** 任何以下字段出现在 `meta.unlocks`（违反即 PR-blocking）：
- `starting_ap_bonus` / `starting_energy_bonus`
- `card_power_bonus` / `card_unlock_permanent`
- `kpi_base_offset` / `capacity_floor_override`
- `relationship_starting_delta` / 任何影响 Run 起始数值的字段

**实施机制**: `#12` 在写入 `meta.unlocks` 前执行 key 前缀白名单校验（5 类允许前缀 vs 禁止前缀 Set）；违反 → push_error + 丢弃该 unlock + 写 audit log。`#10 run_meta_unlock` effect 传入的 `content_id` 必须通过此校验。

**Rule 5 — HR 评语词条收集**

HR 评语词条从 `#9 KPI System` 月末结算产出的 `hr_evaluation_key` 写入 `meta.hr_word_library`（跨局去重 Array）：

**触发维度（三轴交叉选词）**:

| 触发轴 | 参数 | 词条区间 |
|--------|------|---------|
| `month_count` | 当前 Run 死亡月份 | M1-M3 / M4-M7 / M8+ |
| `kpi_completion` | 实际完成率 vs threshold | <80% / 80-99% / 100-110% / >110% |
| `tenure_tier` | 工龄分段 | 新人(M1-3) / 中坚(M4-7) / 资深(M8+) |

MVP 目标 30+ 词条（`hr_eval_word_count_mvp ≥ 30`），覆盖三轴交叉主要组合。词条 key 格式：`EVAL.[tier].[kpi_band].[month_group]`，如 `EVAL.VETERAN.PERFECT.LATE`。

**词条写入规则**:
- 每次月末结算后，`#9` emit `kpi_threshold_changed(breakdown)` 时同步 emit `hr_evaluation_key(key: StringName)`
- `#12` 接收 key，若 `hr_word_library` 中不存在则 append（去重）
- `hr_word_library` 无上限（词条总量有限，30-100 条不成内存压力）

**Rule 6 — demo end 协议（MVP gate）**

MVP 地图上限 = 3 月（`DEMO_END_MONTH = 3`，Tuning Knob）。

当 `current_run_month` 在月末结算后达到 `DEMO_END_MONTH`，且 `#9` 未触发 `game_over_triggered`（即玩家正常存活）：

```
1. #12 emit demo_end_triggered()
2. #9 emit game_over_triggered(reason="DEMO_END", month=DEMO_END_MONTH)（由 #9 调用，非 #12 越权）
3. RunSummary reason = "DEMO_END"
4. #16 渲染特殊 demo end 结局屏（预告完整版文案，非普通 GAME OVER 屏）
```

**设计意图**: demo end 是正常 Run 终结，不是失败。RunSummary 与普通 GAME OVER 完全相同格式入档。玩家体感："我活过了 3 集（Demo 上限），档案留下了。"

**Rule 7 — Archive 200 cap + FIFO 驱逐（Save Rule 23 对应）**

```
if len(archive) >= archive_hard_cap_count:  # 默认 200
  archive.pop_front()  # 驱逐最早 RunSummary（FIFO）
archive.append(new_summary)
```

**区别于 Save Rule 23 用户界面侧**: Rule 23 的"档案柜已满 → 禁止新 Run 启动"是 `#1 Save System` 的物理 archive 文件计数守门（`len(archive/*.save) ≥ 200`）。`#12 RunSummary` 是内存 + meta.save 中的摘要索引，理论上与 Save archive 文件数同步。**若两者不一致，以 `#1 Save` 的文件系统为准**（Rule 17 同质：archive 文件是事实，meta 是索引）。

**Run 启动时 `#12` 不执行 cap 检查** — 检查责任在 `#1 Save Rule 23`。`#12` 仅在 GAME OVER 归档时执行 FIFO 驱逐，保持摘要索引长度 ≤ 200。

**Rule 8 — 跨局解锁触发协议（#10 effect 注入）**

`#10 Event Script Engine` 在 GAME OVER 三轨（Rule 17）执行 effect `run_meta_unlock(content_id)`：

```
#10 effect 链 → EventEffect.RunMetaUnlock.apply(content_id: String)
  → #12.receive_unlock(content_id)
  → 执行 Rule 4 白名单校验
  → 写入 meta.unlocks[content_id] = true
  → emit unlock_acquired(content_id)
```

`#12` 不主动查询 `#10` — 被动接收 effect。`#10` 也可在非 GAME OVER 事件（NPC 离别弧）中触发 `run_meta_unlock`（同一 API，同一校验流程）。

**Rule 9 — Pillar 1 红线执法（unlock 数值守门）**

除 Rule 4 白名单校验外，`#12` 在 `run_started` emit 前执行 `meta.unlocks` 扫描：

```
for key in meta.unlocks:
  if _is_mechanical_stat_key(key):  # 禁止前缀集检查
    push_error("R-RM-1: unlock key '%s' violates Anti-Pillar 1 — stat buff in meta.unlocks" % key)
    meta.unlocks.erase(key)  # 清除违规 key，不传播给下游
```

**R-RM-1 守门**: 任何携带 stat buff 语义的 unlock key 在 Run 启动前被清除 + 记 audit log。下游系统（`#8 / #10 / #11`）查询 `meta.unlocks` 时永远拿不到违规 key。

**Pillar 4 评语词条 tone 执法**: `hr_word_library` key 必须通过 `subject_inversion_lint.py` `EVAL.*` domain 检查（`#10 Rule 19` 同源 lint 扩展）。正能量 / 励志 / "你能做到" 类前缀被 CI lint 阻塞，不进入词条库。

**Rule 10 — 信号架构**

`#12` emit 信号（供下游订阅）：

| 信号 | 参数 | 订阅者 |
|------|------|--------|
| `run_started(run_id: int)` | run_id = run_count 当时值 | `#6 Scene & Day Flow`（确认 Run 激活） |
| `run_ended(run_id: int, month: int, reason: String)` | 同 GAME OVER 参数 | `#16 KPI Review & Game Over UI`（触发 Archive 动画） |
| `unlock_acquired(content_id: String)` | 新解锁的 content key | `#8 NPC`（npc_unlock_id）/ `#10 Event Script`（event_branch_id）/ `#11 Action Card`（若 card unlock 类型存在） |
| `demo_end_triggered()` | 无参 | `#16`（触发特殊 demo end 屏） |

`#12` 订阅信号：

| 订阅源 | 信号 | 处理 |
|--------|------|------|
| `#9 KPI System` | `game_over_triggered(reason, month)` | Rule 3 GAME OVER 接收协议 |
| `#9 KPI System` | `hr_evaluation_key(key)` | Rule 5 词条收集 |
| `#10 Event Script` | effect `run_meta_unlock(content_id)` | Rule 8 unlock 注入 |

**Rule 11 — Save 持久化**

`#12` 持久化字段全部归属 `meta.save` 的 `run_meta` sub-schema：

```
meta.run_meta.run_count: int
meta.run_meta.current_run_month: int
meta.run_meta.unlocks: Dict[String, bool]
meta.run_meta.archive: Array[RunSummary]   # 内存摘要（≤200）
meta.run_meta.hr_word_library: Array[String]
```

写入时机：
- `run_count` / `archive` / `hr_word_library` — 仅在 GAME OVER ARCHIVING 事务内写（由 `#1` Rule 9 事务 step e 同步）
- `unlocks` — 在 `receive_unlock` 后通过 `#1 Rule 14 meta save` 写入（独立于 Run autosave 节奏）
- `current_run_month` — 每次月末 `#6 scene_state_changed(→KPI_REVIEW)` 时同步更新（通过 `#1 Rule 3c save_checkpoint`）

**Rule 12 — Scope Tier**

| Tier | HR 评语词条 | 解锁内容池 | Archive 功能 |
|------|------------|-----------|-------------|
| **MVP** | 30+ 词条覆盖主要三轴组合 | 5 类 content-only；demo end 预告 | Archive 列表只读；逐条删档（Save Rule 23） |
| **VS** | 60+ 词条；拓展 NPC 离别弧词条 | 多结局路径 unlock；NPC 返回路径 | Archive 词条过滤器（按 reason / 月份排序） |
| **野心版** | 100+ 词条；多公司类型差异词条 | 公司类型 unlock；不同 HR 口音变体 | Archive 导出 / 分享功能（Steam Workshop 候选） |

---

### States and Transitions

| 状态 | 进入条件 | 退出条件 | 允许行为 |
|------|---------|---------|---------|
| `RUN_ACTIVE` | 新 Run 启动（`#6` 触发 `run_started` 后） | `#9 game_over_triggered` 到达 | 更新 `current_run_month`；收集月末 `hr_evaluation_key`；接收 `run_meta_unlock` |
| `RUN_ENDED` | `game_over_triggered` 收到 | ARCHIVING 事务完成 + `run_ended` emit | 构建 RunSummary；FIFO 驱逐检查；run_count++ |
| `META_VIEW` | 玩家在主菜单打开 Archive 列表 | 玩家返回主菜单 / 开始新 Run | 只读 Archive 数据；逐条删档请求（转发给 `#1`） |

**过渡约束**：
- `RUN_ACTIVE → RUN_ENDED` 只能由 `#9 game_over_triggered` 触发，`#12` 不可自行跳转
- `META_VIEW` 与 `RUN_ACTIVE` 互斥（Run 进行中不可打开 Archive — 由 `#16` UI 层强制）
- 冷启动恢复：若 `current_run_month > 0` 且 `current_run.save` 存在，视为 `RUN_ACTIVE`

---

### Interactions with Other Systems

| # | 对端 | 方向 | 主接口 |
|---|------|------|--------|
| I-1 | `#1 Save System` | 双向 | `#12` 提供 `run_meta` sub-schema 数据结构；`#1` Rule 9 ARCHIVING 事务执行物理写盘 |
| I-2 | `#9 KPI System` | 订阅 | `game_over_triggered(reason, month)` + `hr_evaluation_key(key)` + `actual_kpi_history` 只读接口 |
| I-3 | `#10 Event Script Engine` | 被动接收 | effect `run_meta_unlock(content_id)` 注入；GAMEOVER 三轨触发词条收集 |
| I-4 | `#16 KPI Review & Game Over UI` | emit | `run_ended` / `demo_end_triggered` 供 UI 渲染；Archive 列表数据只读访问接口 |
| I-5 | `#8 NPC Relationship` | 只读 | GAME OVER 时读取 `npc_relationships_snapshot`（8 NPC 终态 score） |
| I-6 | `#6 Scene & Day Flow Controller` | 双向 | `run_started` emit 给 `#6` 确认；订阅 `scene_state_changed(→KPI_REVIEW)` 更新 `current_run_month` |

---

## Formulas

### F1 — HR 评语词条触发选词（三轴交叉）

**用途**: 月末结算时根据玩家数学状态选定 `hr_evaluation_key`。

**变量定义**:

| 变量 | 来源 | 范围 |
|------|------|------|
| `m` | 当前月份索引 | `[1, ∞)` |
| `kpi_actual` | `#9 actual_kpi_m` | `[0.0, ∞)` |
| `kpi_threshold` | `#9 monthly_threshold` | `[1, ∞)` |
| `kpi_ratio` | `kpi_actual / kpi_threshold` | `[0.0, ∞)` |

**三轴分段**:

```
month_group =
  "EARLY"  if m ∈ [1, 3]
  "MID"    if m ∈ [4, 7]
  "LATE"   if m ≥ 8

kpi_band =
  "FAIL"    if kpi_ratio < 0.80
  "PASS"    if kpi_ratio ∈ [0.80, 0.99]
  "GOOD"    if kpi_ratio ∈ [1.00, 1.10]
  "OVER"    if kpi_ratio > 1.10

tenure_tier =
  "ROOKIE"   if m ∈ [1, 3]
  "VETERAN"  if m ∈ [4, 7]
  "GREYBEARD" if m ≥ 8
```

**选词公式**:

```
hr_evaluation_key = "EVAL." + tenure_tier + "." + kpi_band + "." + month_group
```

**示例**:
- M8，kpi_ratio = 0.993 → `EVAL.GREYBEARD.PASS.LATE` → "中规中矩的牺牲品"
- M2，kpi_ratio = 1.02 → `EVAL.ROOKIE.GOOD.EARLY` → "积极性可嘉"
- M5，kpi_ratio = 0.72 → `EVAL.VETERAN.FAIL.MID` → "本月产出有待改进"

**词条不足时 fallback**: 若 `hr_evaluation_key` 在 Localization CSV 中不存在 → fallback to `EVAL.GENERIC.PASS` （通用词条，MVP 必须存在）。

---

### F2 — Archive FIFO 驱逐（超 200 时）

**触发条件**: `len(archive) >= archive_hard_cap_count`（默认 200）时，新 RunSummary 入档前执行。

```
while len(archive) >= archive_hard_cap_count:
  oldest = archive.pop_front()   # Array 头部 = 最早 Run（FIFO）
  _evict_log(oldest.run_id)      # 写 eviction audit log（DEBUG）
archive.append(new_summary)
```

**驱逐语义**: 被驱逐的 RunSummary 从内存索引删除，但 `#1 archive/*.save` 物理文件**不**被 `#12` 删除（删档只能由玩家在 `META_VIEW` 逐条操作，Save Rule 23）。若 Save 文件仍存在但 `meta.archive` 已驱逐该 summary，下次冷启动 `#1 Rule 17` 会发现不一致，以文件系统为准重建索引。

**实际上限**: MVP 不会触达（200 局 ≈ 1000+ 小时），公式作为长线保险。

---

## Edge Cases

### Cat 1 — 评语词条触发边界

| ID | 情境 | 处理 |
|----|------|------|
| E-1.1 | `hr_evaluation_key` 在 Localization CSV 不存在 | fallback → `EVAL.GENERIC.PASS`；push_warning log；MVP 必须覆盖所有 3×4×3=36 理论组合（CI lint 守门） |
| E-1.2 | `hr_evaluation_key` emit 在 `game_over_triggered` 之前未到达（`#9` 信号乱序） | `#12` 在 `game_over_triggered` handler 中等待 `current_hr_key`（若为空则用 fallback）；不阻塞归档 |
| E-1.3 | 同局多次 `hr_evaluation_key` emit（月末结算 + demo_end 双触发） | `#12` 仅记录最后一次收到的 key 作为 `final_hr_evaluation_key`；Array append 去重 |

### Cat 2 — Archive 200 cap 边界

| ID | 情境 | 处理 |
|----|------|------|
| E-2.1 | `meta.archive` 长度与 `archive/*.save` 文件数不一致（云同步部分丢失） | 冷启动 `#1 Rule 17` 以文件系统重建 meta 索引；`#12` 接受重建后的 archive Array |
| E-2.2 | FIFO 驱逐后 `archive/*.save` 物理文件仍存在（#1 文件 vs #12 索引不同步） | 以 #1 文件系统为准；不一致只影响摘要显示，不影响玩法。冷启动重建同步 |
| **[RISK GUARD] R-RM-2** | `len(archive) > archive_hard_cap_count`（F2 FIFO 未触发，越界） | `#12` 在 `archive_run()` 入口处硬性 assert `len(archive) <= archive_hard_cap_count`；assert fail → push_error + 强制 FIFO 驱逐到合规再 append |

### Cat 3 — unlock content vs stat 越界

| ID | 情境 | 处理 |
|----|------|------|
| E-3.1 | `#10` effect 传入 `run_meta_unlock("starting_ap_bonus_3")` | Rule 4 白名单校验失败 → push_error + 丢弃 + audit log；不进入 `meta.unlocks` |
| E-3.2 | `meta.unlocks` 已存在该 content_id（重复 unlock） | 幂等处理：`meta.unlocks[content_id]` 已为 true → 跳过，不 re-emit `unlock_acquired` |
| E-3.3 | `meta.unlocks` 损坏（meta.save 损坏 `#1 Rule 11` 走重建分支） | `#12` 接受空 unlocks Dict（等同新玩家）；不影响 Run 内玩法；玩家收到 `#1` "跨局进度可能丢失"对话框 |
| **[RISK GUARD] R-RM-1** | `#12 run_started` 前扫描发现 stat buff key 在 `meta.unlocks` | Rule 9 扫描删除 + push_error + audit log；下游系统永远拿不到 stat buff key（Anti-Pillar 1 最后防线） |

### Cat 4 — demo end 边界

| ID | 情境 | 处理 |
|----|------|------|
| E-4.1 | 玩家在 M3 月末 `#9` 已触发 `game_over_triggered(KPI_EXCEEDS_CAPACITY)` — 普通 GAME OVER 与 demo end 同月 | `#9 game_over_triggered` 优先；`#12` 不额外触发 `demo_end_triggered`；RunSummary reason = "KPI_EXCEEDS_CAPACITY" |
| E-4.2 | `DEMO_END_MONTH = 3` 修改为更大值（VS 阶段扩展关卡） | Tuning Knob 修改即生效；无代码 hardcode；`#12` 每月末判断 `current_run_month >= DEMO_END_MONTH` |
| E-4.3 | demo end 后玩家快速重启新 Run，archive 连续写入 | Rule 3 + Rule 7 正常执行；无需特殊处理；demo end Run 与普通 GAME OVER Run 归档格式完全一致 |

### Cat 5 — Run reload / 冷启动恢复

| ID | 情境 | 处理 |
|----|------|------|
| E-5.1 | 冷启动时 `current_run_month > 0` 且 `current_run.save` 存在 | `#12` 进入 `RUN_ACTIVE` 状态；不重置 `current_run_month`；等待下次月末 `#9` 信号 |
| E-5.2 | `current_run_month = 0` 但 `current_run.save` 存在（ARCHIVING 中断） | `#1 Rule 15` 反向幂等补齐；`#12` 被动接受补齐后的 meta；若仍不一致，`#12` 以 `current_run_month = 0` 为准（Run 视为已结束） |
| E-5.3 | `run_count` 与 `len(archive)` 不一致（ARCHIVING 事务第 7 步中断） | 以 `len(archive)` 为准重建 `run_count`（`#1 Rule 15 + Rule 17` 同质方案） |
| **[RISK GUARD] R-RM-3** | `hr_word_library` 中存在正能量 / 励志词条 key（tone 违规） | `#12` 在 `META_VIEW` 初始化时执行词条 tone lint 扫描（`subject_inversion_lint.py EVAL.*` domain）；违规 key → push_error + 从 library 删除 + audit log；不展示给玩家 |

---

## Dependencies

### Upstream（`#12` 依赖的系统）

| 系统 | 依赖类型 | 接口 |
|------|---------|------|
| `#1 Save System` | 强依赖（持久化 owner） | `meta.save` 物理读写；Rule 9 ARCHIVING 事务；Rule 22 unlock schema 约束；Rule 23 archive cap |
| `#9 KPI System` | 强依赖（主要数据源） | `game_over_triggered(reason, month)` 信号；`hr_evaluation_key(key)` 信号；`actual_kpi_history` 只读接口；`final_threshold` 只读 |
| `#10 Event Script Engine` | 强依赖（unlock 注入） | effect `run_meta_unlock(content_id)` → `#12.receive_unlock()` API |

### Downstream（`#12` 提供数据的系统）

| 系统 | 依赖类型 | 接口 |
|------|---------|------|
| `#16 KPI Review & Game Over UI` | 强依赖（渲染 owner） | 订阅 `run_ended` + `demo_end_triggered`；只读 `archive` / `run_count` / `hr_word_library` |
| `#8 NPC Relationship System` | 弱依赖（unlock 消费） | 订阅 `unlock_acquired`（`npc_unlock_id` 类型）→ 将 NPC 加入下局候选池 |
| `#11 Action Card System` | 弱依赖（unlock 消费） | 订阅 `unlock_acquired`（`card_unlock_id` 类型，若 VS 引入） |
| `#6 Scene & Day Flow` | 弱依赖（Run 状态同步） | 订阅 `run_started`；提供 `scene_state_changed` 月末触发给 `#12` 更新 `current_run_month` |

### 双向一致性 cross-check

- ✓ `#1 Save` Rule 22 `meta.unlocks` 5 类 key 白名单 ↔ `#12` Rule 4 相同白名单（两 GDD 须同步更新）
- ✓ `#1 Save` Rule 23 archive 200 cap ↔ `#12` F2 FIFO 驱逐（两 GDD 数字必须一致）
- ✓ `#9 KPI` Rule 9 `game_over_triggered(reason, month)` 信号签名 ↔ `#12` Rule 3 接收协议（参数名和顺序须匹配）
- ✓ `#10 Event Script` Rule 17 `run_meta_unlock` effect ↔ `#12` Rule 8 receive_unlock（API 名须匹配）

---

## Tuning Knobs

| Knob | 分类 | 默认值 | 范围 | 位置 |
|------|------|--------|------|------|
| `DEMO_END_MONTH` | Gate | `3` | `[1, ∞)` — VS 扩展时改 6+ | `config/run_meta_balance.tres` |
| `archive_hard_cap_count` | Gate | `200` | `[50, 500]` — 低于 50 影响长线玩家 Pillar 3 仪式感 | `config/run_meta_balance.tres`（引用自 Save Rule 23） |
| `hr_eval_word_count_mvp` | Curve | `30` | `[20, 60]` — 低于 20 词库审美疲劳加速 | 词条数量目标（writer 执行，非代码 Knob） |

**HR 评语词条 MVP 推荐分布（30 条，三轴主要组合覆盖）**:

| tenure_tier | kpi_band | month_group | 词条数 | 示例 key |
|-------------|----------|-------------|--------|---------|
| ROOKIE | FAIL / PASS / GOOD | EARLY | 3 | `EVAL.ROOKIE.PASS.EARLY` → "入职适应期，表现尚可" |
| VETERAN | FAIL / PASS / GOOD / OVER | MID | 6 | `EVAL.VETERAN.OVER.MID` → "积极性可嘉，请继续保持" |
| GREYBEARD | FAIL / PASS / GOOD | LATE | 6 | `EVAL.GREYBEARD.PASS.LATE` → "中规中矩的牺牲品" |
| 跨 tier 补充（OVER 极端 + FAIL 极端） | OVER / FAIL | ALL | 6 | `EVAL.ROOKIE.OVER.EARLY` → "潜力无限，组织期待更多" |
| GENERIC fallback | PASS | — | 1 | `EVAL.GENERIC.PASS` → "本月产出符合预期，谢谢" |
| 其余三轴组合补充 | mixed | mixed | 8 | 补齐常见路径 |

**总计 ≥30 词条**；CI lint 验证 `EVAL.GENERIC.PASS` 必须存在（Rule E-1.1 fallback 依赖）。

---

## Visual/Audio Requirements

**`#12` 零视觉 / 零音频 Ownership**:

- 所有 GAME OVER 视觉（离职证明动画、Archive 列表展示）由 `#16 KPI Review & Game Over UI` own
- Archive 列表 UI 渲染（逐条删档交互）由 `#16` own（Save Rule 23 仪式感交互在 UI 层实现）
- HR 评语词条展示（Archive 子菜单词库视图）由 `#16` own
- demo end 特殊结局屏由 `#16` own（`demo_end_triggered` 信号触发渲染切换）

**音效契约（引用，非 own）**:
- `#12 run_ended` emit 后：`#4 Audio` 执行 `BGMSTATE_GAMEOVER`（月末打卡机不是胜利音）；`#12` 不调用 Audio API
- `unlock_acquired` 时：**无成就音效**（Anti-Pillar 1 tone 守护 — 解锁不是胜利）；`#4 Audio` 不订阅 `unlock_acquired`

---

## UI Requirements

**`#12` 不 own 任何 UI 屏。**

与 `#16 KPI Review & Game Over UI` 的数据接口合约：

| 数据 | `#12` 提供 | `#16` 消费 |
|------|-----------|-----------|
| `run_count` | 只读 int | "活过第 X 集"计数展示 |
| `archive` Array[RunSummary] | 只读，含完整字段 | Archive 列表渲染（工号 / 月份 / 死因 / 评语） |
| `hr_word_library` | 只读 Array[String] | 词条词库子菜单 |
| `meta.unlocks` | 只读 Dict | 仅限 `#16` 判断"预告完整版内容"显示 |

**逐条删档交互（Save Rule 23 仪式感）**: `#16` 发起删档请求 → `#1 Save` 执行物理删除 `archive/[run_id].save` → `#1` 通知 `#12` 从 `archive` Array 删除对应 RunSummary → `#16` 刷新列表。`#12` 不直接响应 UI 输入。

---

## Open Questions

| ID | 问题 | Owner | 目标阶段 |
|----|------|-------|---------|
| OQ-RM-1 | HR 评语词条文案（30+ 词条）谁来写？`#9 KPI Section B C3` 给了锚点语感，但具体文案需要 writer 执行 | writer + narrative-director | MVP 内容截止前 |
| OQ-RM-2 | 跨局 unlock 内容池由谁规划？`npc_unlock_id` / `event_branch_id` / `ending_unlock_id` 的具体 ID 列表需要 `#8 / #10` GDD 完善后对齐 | game-designer + narrative-director | `#8 / #10` Review Approved 后 |
| OQ-RM-3 | `#16` Archive 列表 UI 交互细节（每条展示哪些 RunSummary 字段？词库子菜单是否独立 tab？）待 `/ux-design` 时决策 | ux-designer | Phase 4 Pre-Production `/ux-design kpi-review-game-over-screen.md` |
| OQ-RM-4 | demo end 特殊结局屏文案（预告完整版话术）需要 writer 提供；`#16` UI 需设计区分普通 GAME OVER 与 demo end 视觉 | writer + ux-designer | MVP Pre-Alpha build |
| OQ-RM-5 | `npc_relationships_snapshot` 是否展示在 Archive 列表 UI？若展示，哪些字段可读（8 NPC 全部 score？还是仅 lifecycle_state）？需 `#16` + `#8` 协调 | ux-designer + narrative-director | OQ-RM-3 同期 |
| OQ-RM-6 | `hr_word_library` 词条展示（META_VIEW 子菜单）是否需要 unlock 门槛（首次出现时才加入词库 vs 总是可查）？目前设计为任意收集后可查 | game-designer | MVP Review 阶段 |
| OQ-RM-7 | VS 阶段是否引入 run_name（玩家给 Run 命名）？目前 RunSummary 仅有 run_id；命名功能影响 Archive UI 设计 | producer + ux-designer | VS kickoff |

---

## Acceptance Criteria

> **注**: 本 GDD S size，AC 由 qa-lead 在独立 review session 完成。以下 15 条为 game-designer 拟定框架，qa-lead 复审补充后为最终版。

### AC-FUNC — 功能验收

| ID | 验收条件 | Tier |
|----|---------|------|
| AC-FUNC-01 | GAME OVER 后 `run_count` 精确 +1，`archive` 长度 +1，`RunSummary.month_index_at_death` = 信号中 `month` 参数 | MVP |
| AC-FUNC-02 | `meta.unlocks` 中的 key 全部通过白名单校验（5 类前缀）；stat buff key 不存在于 `meta.unlocks` | MVP |
| AC-FUNC-03 | `#10 run_meta_unlock("starting_ap_bonus_3")` 执行后，`meta.unlocks` 无该 key，`audit_log` 有 R-RM-1 error 记录 | MVP |
| AC-FUNC-04 | `run_started` 前 Rule 9 扫描：注入 1 个 stat buff key 到 `meta.unlocks` → 扫描后该 key 被删除 + push_error | MVP |
| AC-FUNC-05 | M3 月末玩家存活（`#9` 未触发 GAME OVER）→ `demo_end_triggered` emit + RunSummary reason = "DEMO_END" | MVP |
| AC-FUNC-06 | M3 月末 `#9` 同月触发 `game_over_triggered(KPI_EXCEEDS_CAPACITY)`：`demo_end_triggered` **不** emit；RunSummary reason = "KPI_EXCEEDS_CAPACITY" | MVP |
| AC-FUNC-07 | `hr_word_library` 跨局去重：同一 key 多局收集后 library 中只有 1 条 | MVP |
| AC-FUNC-08 | F1 公式覆盖：M8 + kpi_ratio=0.993 → key = `EVAL.GREYBEARD.PASS.LATE`（验证三轴分段正确） | MVP |
| AC-FUNC-09 | `EVAL.GENERIC.PASS` key 在 Localization CSV 存在；E-1.1 场景（key 缺失）→ fallback 词条正确加载 | MVP |

### AC-RULE — 机制约束验收

| ID | 验收条件 | Tier |
|----|---------|------|
| AC-RULE-01 | Archive 第 201 条 RunSummary 写入时，最早 Run（run_id 最小）被 FIFO 驱逐；`archive` 长度保持 ≤ 200 | MVP |
| AC-RULE-02 | R-RM-2 守门：构造 `archive` 长度 = 201 → `archive_run()` 入口 assert fail → push_error + 强制驱逐至 200 | MVP |
| AC-RULE-03 | `unlock_acquired` emit 后：`#4 Audio` 无成就音效触发（验证 tone 执法） | MVP |
| AC-RULE-04 | R-RM-3 守门：注入 tone 违规 key（`EVAL.励志.PASS.EARLY`）到 `hr_word_library` → 冷启动 lint 扫描删除 + push_error | MVP |

### AC-PERF — 性能验收

| ID | 验收条件 | Tier |
|----|---------|------|
| AC-PERF-01 | `archive_run()` 完整执行（构建 RunSummary + FIFO 检查 + meta 字段更新）< 5ms（主线程，Godot profiler） | MVP |
| AC-PERF-02 | `hr_word_library` 去重 append（30+ 条规模）< 1ms | MVP |

> **注 qa-lead**: 请在 Review 时补充 Given-When-Then 格式、边界值测试（E-1.x / E-2.x / E-3.x / E-4.x / E-5.x 各一条自动化 AC）、以及 OQ-RM 依赖 AC（OQ-RM-3/OQ-RM-6 结论前标 ADVISORY）。QA 工具需求：mock `#9` 信号发射器 / `meta.save` fixture / lint CI 脚本（subject_inversion_lint.py EVAL.* domain）。
