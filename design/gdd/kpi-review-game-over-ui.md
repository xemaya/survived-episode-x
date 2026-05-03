# KPI Review & Game Over UI

> **Status**: Designed (pending review)
> **Author**: huanghaibin + game-designer (全文主笔) + systems-designer (Section C 14 Rules + Section E 18-20 edges) + narrative-director (Section B 反讽锚 + CERTIFICATE tone 守门) + ux-designer (Visual/UI 契约 + 📌 3 UX Flags) + qa-lead (Section H 22 AC)
> **Authoring autonomy mode**: v2 no-prompt (全程 0 widget)
> **Last Updated**: 2026-04-29
> **Layer**: Presentation | **Order**: #16 | **Size**: M (月末审判 + 离职 transition + Archive UI)
> **Implements Pillar**: P3 主(死亡是注定的 — 离职证明 + Archive 档案柜)+ P1 守(平庸是艺术 — 月末结算反讽 + 红线守门)+ P4 主(苦中作乐黑色幽默 — 月末审判 tone 戏谑 HR 口吻铁三角)
> **Anti-Pillar**: Anti-Pillar 1 红线(NOT 升职打怪 — 禁金光/庆祝/成就动画)+ Anti-Pillar 2 红线(NOT 励志叙事 — 禁"再试一次/加油/挑战失败")

---

## Section A: Overview

**KPI Review & Game Over UI** 是《活过第 X 集》的**月末审判渲染层 + 离职证明过渡屏 + 跨局 Archive 列表 UI** —— 承担双重身份：

**技术层**: `#16` 是纯渲染层，拥有三块 UI 职责：(1) **月末 KPI 结算屏** — 订阅 `#9 kpi_review_started` + `#9 kpi_threshold_changed(breakdown)` 信号，渲染涨幅三行 HR 戏谑口吻 breakdown + capacity_now 数字对比；(2) **GAME OVER 离职证明屏** — 订阅 `#9 game_over_triggered(reason)` + `#10 GAMEOVER.CERTIFICATE.[reason]` Localization key 渲染离职证明文本，执行 `final_transition_duration_ms = 1500ms linear`（Save Rule 21 硬约束）；(3) **Archive 列表屏** — 渲染 `#12 Run Meta` 提供的 `RunSummary` 历代档案列表，提供逐条选档删除 UI（禁批量删，Save Rule 23），展示 HR 评语词条收集状态（`#12 Rule 5` 词库）。**自身不持有任何业务逻辑、不写 Save、不执行 KPI 公式**。帧预算 ≤ 4 ms / 屏（月末重屏，KPI Review + GAME OVER 各自独立 ≤ 4ms 预算）。

**叙事层**: 玩家感受到的不是"结算 boss 战/失败红屏/成就展柜"，而是三件具体的事：**月末绩效面谈打印稿**（戏谑 HR 口吻三行 breakdown）、**离职证明书**（冷静打卡机 linear 1500ms，无 ease，无庆祝）、**员工档案柜**（每条"工号 #0011 · 死于 M11 · 最终评语"是一份职业生涯化石，可翻阅不可继承）。三屏共享同一种 tone：**事务性轻盈，像 HR 系统的自动报告，不评判，只登记**。

### Pillar 服务

- **P3 主 死亡是注定的**: GAME OVER 离职证明屏 + Archive 列表是 P3 的双层具象化器。离职证明 1500ms linear 无庆祝是"冷静打卡机"tone 最纯粹形态；Archive 档案柜让"死亡"成为可归档、可翻阅的遗址，run_count +1 是唯一的"晋升"。
- **P1 守 平庸是艺术**: 月末 KPI breakdown 三行 HR 口吻（"积极性可嘉 / 潜力挖掘余量 / 资深员工的责任"）是对"反向 KPI 数学"的戏谑解释。Pillar 1 红线守门：**禁**金光/金色动画/庆祝特效/成就弹出/任何"挑战失败"游戏化语义（Rule 10 完整红线，任何违反 = PR-blocking）。
- **P4 主 苦中作乐黑色幽默**: HR 口吻是铁三角第四轨 —— Localization `GAMEOVER.TITLE_IRONY "恭喜晋升"` + Audio 月末打卡机不是胜利音 + Lighting GAMEOVER 灰度压抑 + `#16` HR 戏谑 breakdown 四轨共同保证"月末感受是苦笑而非紧绷或绝望"。

### 5 NOT 边界（scope creep 防护）

- **NOT** KPI 公式 / effort 数学（由 `#9 KPI System` own；`#16` 仅消费 emit 的 `breakdown` 结构体渲染三行）
- **NOT** Run Meta 跨局数据计算（由 `#12 Run Meta` own；`#16` 仅渲染 `RunSummary` 列表 + hr_word_library）
- **NOT** 离职证明文本 / GAMEOVER.CERTIFICATE 原始文字（由 `#10 Event Script Engine` + writer own；`#16` 仅渲染 Localization key `GAMEOVER.CERTIFICATE.[reason]`，由 `#3` tr() 加载）
- **NOT** 三轨视听效果（KPI_REVIEW 紫 + GAMEOVER 灰度 由 `#5 Lighting` own；月末打卡机 BGM + GAMEOVER stinger 由 `#4 Audio` own；`#16` 仅订阅 sub-mode 信号，不直接操控视听层）
- **NOT** Save archive 事务原子写（由 `#1 Save System` Rule 9 ARCHIVING 流程 own；`#16` 仅触发 UI 展示，不写 Save）

### 5 NOT 红线（违反即破坏 Pillar）

- **NOT** 月末结算屏出现金光/金色庆祝动画（违反 Anti-Pillar 1 + P4 — 把月末"审判"变"胜利"）
- **NOT** GAME OVER 屏出现"挑战失败 / 再试一次 / 加油 / 你很努力"任何游戏化失败语义（违反 Anti-Pillar 2 + P4）
- **NOT** Archive 列表提供批量删除 / 全清功能（违反 Save Rule 23 仪式感约束 + P3）
- **NOT** GAME OVER transition 使用 ease-in / ease-out / bounce / elastic（违反 Save Rule 21 `final_transition_easing = NONE` + Pillar 3 冷静打卡机 tone）
- **NOT** `#16` 持有 KPI 数学逻辑 / 执行 threshold 判断（违反 ownership 边界 — 渲染层不做业务决策）

### Source 引用

`#9 kpi-reverse-threshold-system.md` Rule 10 涨幅拆解 breakdown 结构 + Rule 17 三轨（开除剧本 + 老 NPC 预言 + GAMEOVER.CERTIFICATE）+ Rule 2 `kpi_review_started` 信号 + Section UI 强制契约（`#16` 为 `kpi_review_started` 的强制消费者）。`#12 run-meta-system.md` Rule 5 HR 评语词条收集词库展示 + Rule 6 Archive 列表 200 cap（Save Rule 23）+ `RunSummary` schema。`#1 save-system.md` Rule 21 `final_transition_duration_ms = 1500ms / easing = NONE` + Rule 22 content-only unlocks + Rule 23 archive 200 cap 逐条删除守门。`#10 event-script-engine.md` Rule 17 `GAMEOVER.CERTIFICATE.[reason]` 文本 own by `#10`；`#16` 仅渲染 Localization key。`#3 localization-hooks.md` Rule 4 `tr()` + `_IRONY` 后缀 + Rule 11 主语翻转 lint。`#2 input-handler.md` Rule 6 skippable 守门（skip 仅跳到最后 1 帧，不截断 1500ms tone）。`#5 lighting-visual-state.md` Rule 1 `KPI_REVIEW` sub-mode 紫色 + `GAMEOVER` sub-mode 灰度压抑。`#4 audio-manager.md` Rule 7 月末打卡机 BGM + GAMEOVER stinger 白名单（仅两处 BGM 豁免）。

---

## Section B: Player Fantasy

### 主锚: "恭喜晋升"反讽屏

**场景**:
第 11 月月末，`#6 scene_state_changed(→KPI_REVIEW)` 发出。Lighting 切换至 `KPI_REVIEW` 紫色调（`#5 Rule 1`，`#7C2B91`）。屏幕浮出**月末绩效面板** —— 不是 boss 血条，是打印机吐出的 A4 纸质感 UI：

> **月末绩效登记 — 第 11 月**
> 积极性可嘉（+2.0%）— 本月加班记录已登记
> 潜力挖掘余量（+0.0%）— 产出符合预期已录入
> 资深员工的责任（+13.2%）— 工龄系数已更新
> ────────────
> 下月目标：240（本月：212）

没有红色警告，没有庆祝动画。HR 系统温柔地、流程化地完成登记。然后：**`threshold(240) > capacity_now(212)`**，`#9 game_over_triggered` 触发。屏幕线性淡变灰度（`GAMEOVER` sub-mode，`#5 Rule 1`）。

一份离职证明缓缓滑入，linear，无 ease，1500ms：

> **离职证明**
> 兹证明 工号 #0011 员工，于本公司任职 11 月。
> 现因「KPI 超出产能」自愿办理离职手续。
> 组织对您的稳定贡献表示感谢。
> ────────────
> **恭喜晋升**

Localization key `GAMEOVER.TITLE_IRONY`。最后两字在沉默中存在 1 帧，然后 confirm 进入 Archive 列表。

**Pillar 服务**:
- **P3 主**: "恭喜晋升"是唯一的晋升 —— 档案入列，run_count +1，人走了数据留下
- **P4 主(最强)**: 反讽来自语言本身。HR 系统的"自愿办理离职"包裹着数学暴力；"组织感谢您的稳定贡献"是最温柔的驱逐。玩家的反应应该是**苦笑**，不是愤怒，不是绝望
- **P1 守**: 三行 breakdown 可读 —— 玩家看到"+2.0% / +0.0% / +13.2%"就能理解自己怎么死的；反向 KPI 系统的数学逻辑通过 HR 口吻完成自我解释，不需要 tutorial

**跨 GDD negative space 四轨完整**:
- **数学轨（`#9`）**: `threshold > capacity` 的数学定理把"死亡"变成客观事实，不是系统惩罚
- **听觉轨（`#4`）**: 月末打卡机 BGM（非胜利音）+ GAMEOVER stinger（非悲伤弦乐）= 同一音调的"下班打卡机"感
- **视觉轨（`#5`）**: KPI_REVIEW 紫色 → GAMEOVER 灰度压抑，线性渐变无庆祝光效
- **文字轨（`#16 + #3 + #10`）**: HR 口吻三行 breakdown + "恭喜晋升" IRONY key = 最终的语言锋芒

**❌ Tone 风险（必避）**:
- 离职证明出现任何 ease-in/out/bounce 动画 —— 变"仪式感电影"，失去"打卡机"冷静
- breakdown 三行数字颜色使用红色 —— 让玩家感受到威胁而非反讽
- GAME OVER 屏出现"再来一局"按钮视觉权重高于"查看档案" —— 改变"归档"→"重试"的叙事重心

**✅ Tone 守护**:
- 离职证明配色：灰度底（`#3A3A3A`）+ 白字，零彩色，零动画，linear 1500ms
- breakdown 三行字体：等宽、中等灰（`#B8B8B8`），无加粗无高亮，像 HR 打印稿
- Archive 入列动画：无。RunSummary 追加入列是静默的，玩家需要主动打开档案柜才能看到新条目

---

### 副锚: "工号 #0011 · 死于 M11"档案条（P3 博物馆形态）

**场景**:
Archive 列表屏。13 条历史记录，排列整齐：

> \#0001 · M3 · 积极性可嘉的牺牲品（KPI_EXCEEDS_CAPACITY）
> \#0002 · M5 · 本月产出符合预期（DISMISSAL_SEVERE）
> …
> \#0011 · M11 · 资深员工的责任（KPI_EXCEEDS_CAPACITY）← 刚归入

玩家点开 #0003，展开 RunSummary 详情（VS tier）：死亡月份、最终 KPI 历史数字列表、8 NPC 最终关系值、最终 HR 评语词条。**不可读档，不可继承，只能翻阅**。

**P3 "死亡是注定的"的最纯粹 UI 形态**: 档案柜证明这件事真实存在过。玩家看着 #0001 的 M3 → #0011 的 M11，感受的是"我进步了"—— 但进步的是对系统的理解，不是数值能力。

**HR 评语词条收集 UI（`#12 Rule 5` 词库子菜单）**:
> 已收集 HR 评语词条: 18 条
> 本局新增: 「资深员工的责任」「本月产出符合预期」

词条展示方式：纯文字列表，无"解锁！"弹出，无成就星标，静默可查。

---

## Section C: Detailed Rules

14 Core Rules + 3 态状态机 + 7 Interactions。

### Core Rules

**Rule 1 — KPI Review 屏触发协议（订阅 `#6 KPI_REVIEW` sub-mode + `#9 kpi_review_started`）**

`#16` 订阅双信号触发序列：
1. `#6 scene_state_changed(→KPI_REVIEW)` 触发时，`#16` 进入 `KPI_REVIEW_WAITING` 态，UI 开始淡入（Lighting 已切 KPI_REVIEW 紫）
2. 紧接 `#9 kpi_review_started` emit 后（`#9` Rule 2 结算协议步骤 4），`#16` 正式渲染月末绩效面板（进入 `KPI_REVIEW_ACTIVE` 态）
3. `#9 kpi_threshold_changed(old, new, delta_pct, breakdown)` 携带 breakdown 结构体，`#16` 渲染三行 HR 口吻（Rule 2）
4. 若 `#9 game_over_triggered(reason, month)` emit，`#16` 立即从 `KPI_REVIEW_ACTIVE` 转 `GAMEOVER_TRANSITION`（Rule 5）
5. 若无 GAME OVER，玩家 confirm 后 `#16` emit `kpi_review_dismissed`，`#6` 推进下月

**信号依赖顺序**: `scene_state_changed(KPI_REVIEW)` → `kpi_review_started` → `kpi_threshold_changed` → [可选] `game_over_triggered`。`#16` 必须处理三者均在 1 帧内到达的情形（Edge Cat 1 + Cat 5 race 守门）。

---

**Rule 2 — breakdown 三行渲染（继承 `#9 Rule 10` + KPI research §8.1 — "努力系数 / 潜力挖掘 / 工龄加成 + HR 口吻注释"）**

`#16` 从 `#9 kpi_threshold_changed(breakdown)` 信号获取结构体：
```
breakdown = {
  effort_contrib_pct: float,      # α × effort_norm
  potential_contrib_pct: float,   # β × potential
  tenure_contrib_pct: float,      # γ_eff × month_index (M1=0.0, novice_protection_active)
  total_mult: float,              # 三因子乘积
  old_threshold: int,
  new_threshold: int,
  novice_protection_active: bool  # M1 保护标志
}
```

渲染三行（HR 口吻，Localization key 由 `#3 tr()` 加载）：

| 行号 | 数据字段 | HR 口吻 Localization key | 示例显示 |
|------|---------|--------------------------|---------|
| 行 1 | `effort_contrib_pct` | `KPI.BREAKDOWN.EFFORT_LABEL` | "积极性可嘉（+2.0%）— 本月加班记录已登记" |
| 行 2 | `potential_contrib_pct` | `KPI.BREAKDOWN.POTENTIAL_LABEL` | "潜力挖掘余量（+0.0%）— 产出符合预期已录入" |
| 行 3 | `tenure_contrib_pct` | `KPI.BREAKDOWN.TENURE_LABEL` | "资深员工的责任（+13.2%）— 工龄系数已更新" |

格式化规则（见 Section D Formula D1）：百分比保留 1 位小数，正值前置 `+`，零值显示 `+0.0%`。`#16` 仅持有 Localization key 引用，不持有 HR 口吻原始文本（由 `#3` own + writer 撰写）。

---

**Rule 3 — M1 工龄项显示 `—` 破折号 + "新人豁免"（`#9 Rule 6` 新手保护）**

当 `breakdown.novice_protection_active == true`（`#9 Rule 6`，`month_index == 1`）时：

- 行 3 替换为：Localization key `KPI.BREAKDOWN.TENURE_NOVICE_EXEMPT`
- 示例显示："— 新入职员工工龄项本月豁免"
- 数字位置显示 `—`（破折号 U+2014），不显示 `+0.0%`
- Tone 守护：不显示"恭喜新人"类正能量，只是 HR 流程登记（"豁免"= 系统流程，不是奖励）

若 `breakdown` 不含 `novice_protection_active` 字段（老版本兼容），`#16` 以 `tenure_contrib_pct == 0.0` 推断。

---

**Rule 4 — capacity_now 数字对比预警（R-AP-5 + R-KPI-3 玩家 agency）**

月末结算屏底部显示 `capacity_now` vs `monthly_threshold` 对比行（仅数字，**禁**进度条 —— 进度条 = 励志感，违反 P4）：

```
产能余量: 212 → 240
```

显示规则：
- `threshold <= capacity_now`：灰字（正常），格式 `capacity_now → new_threshold`（余量可见）
- `threshold > capacity_now`：同灰字（**禁**红色），`#9` 已 emit `game_over_triggered`，`#16` 切 GAMEOVER_TRANSITION（Rule 5），此行不再更新

设计原则：数字对比给玩家信息，但**不加注"危险"/"警告"等语义**（Pillar 1 红线 — 让玩家自己判断，不让 UI 评判）。

---

**Rule 5 — GAME OVER 离职证明 transition（1500ms 锁，linear 无 ease，Save Rule 21）**

`#16` 收到 `#9 game_over_triggered(reason, month)` 后：

1. **`KPI_REVIEW_ACTIVE → GAMEOVER_TRANSITION`**（不可逆，`settlement_locked = true` 后任何 dismiss 请求被拦）
2. `#6 dispatch GAMEOVER sub-mode`（Lighting 切灰度，Audio 切 GAMEOVER stinger）
3. 开始 linear 淡入离职证明 UI：
   - 起始时间戳 `t₀ = Time.get_ticks_msec()`
   - 淡入时长 = `final_transition_duration_ms`（从 `entities.yaml` 通过 `ConfigLoader.get_constant("final_transition_duration_ms")` 加载，禁 GDScript 内 hardcode 数值 1500）
   - easing = NONE（`TRANS_LINEAR`，禁 `EASE_IN` / `EASE_OUT` / `TRANS_ELASTIC` / `TRANS_BOUNCE`）
4. skip 输入已注册（`#2 Rule 6`）：接收到 skip → 跳到 `t = final_transition_duration_ms - 1`（最后 1 帧），不截断，不跳过整体 tone（Rule 9 详述）
5. `final_transition_duration_ms` 到达后：freeze，等玩家 confirm（`act_confirm` 或 skip 再次触发）进入 Archive 列表屏

---

**Rule 6 — GAMEOVER.CERTIFICATE.[reason] 文本嵌入（`#10` own，`#16` 仅渲染 Localization key）**

离职证明文本 own by `#10 Event Script Engine` Rule 17，reason 枚举：

| reason | Localization key | 触发条件 |
|--------|-----------------|---------|
| `KPI_EXCEEDS_CAPACITY` | `GAMEOVER.CERTIFICATE.KPI_EXCEEDS_CAPACITY` | `threshold > capacity_now` |
| `DISMISSAL_SEVERE` | `GAMEOVER.CERTIFICATE.DISMISSAL_SEVERE` | `potential < -0.15` |
| `VOLUNTARY_QUIT` | `GAMEOVER.CERTIFICATE.VOLUNTARY_QUIT` | 玩家主动退出（野心版路径） |
| `DEMO_END` | `GAMEOVER.CERTIFICATE.DEMO_END` | MVP 3 月上限（`#12 Rule 6`） |

`#16` 渲染时通过 `tr("GAMEOVER.CERTIFICATE." + reason)` 动态拼接 key；文本内容由 writer 通过 Localization CSV 撰写，经 `subject_inversion_lint.py --domain GAMEOVER` CI 守门（Rule 11）。

`GAMEOVER.TITLE_IRONY "恭喜晋升"` 是固定尾行（所有 reason 共用），由 `#3 Localization` 保证 `_IRONY` 后缀白名单豁免（`#10 Rule 19` 白名单：`GAMEOVER.TITLE_IRONY` 豁免 `恭喜_` 禁令）。

---

**Rule 7 — Archive 列表 UI（逐条选档删除，禁批量，Save Rule 23）**

Archive 列表屏渲染 `#12 meta.archive`（`RunSummary[]`，上限 200 条，`archive_hard_cap_count`）：

- 展示格式每条一行：`"#[run_id] · M[month_index_at_death] · [tr(final_hr_evaluation_key)] · ([reason])"` —— 例："#0011 · M11 · 资深员工的责任（KPI 超限）"
- **排序**：默认倒序（最新 run_id 在顶），无筛选、无搜索（MVP）
- **展开详情**（VS 增强）：点击条目展开 RunSummary 全字段（actual_kpi_history 数字列表 + 8 NPC 最终 score + unlocks_earned_this_run）
- **删除**：仅逐条选中 + confirm 删除（**禁**"全选删除"/"批量删"按钮 —— Save Rule 23 仪式感约束）
- 删除确认文案：`ARCHIVE.DELETE_CONFIRM`（HR 口吻："确认注销员工 #[id] 的职业生涯记录？"而非"确认删除？"）
- 达 200 cap 时（`archive_hard_cap_count = 200`）：顶部固定提示 `ARCHIVE.CAP_REACHED`（灰字，非红色警告，非阻断弹框 MVP）

---

**Rule 8 — HR 评语词条收集 UI（`#12 Rule 5` 词库展示）**

Archive 列表屏提供子菜单"HR 评语词库"（`ARCHIVE.WORD_LIBRARY_LABEL`）：

- 渲染 `#12 meta.hr_word_library`（去重词条 key 列表）：每条 `tr(key)` 显示评语文本
- 词条进入方式：静默追加（无"新词条解锁！"弹出，无成就通知，无星标）
- 词条列表排序：按首次获得的 run_id 升序
- 词条总数提示：`"已收集 X 条"` —— 灰字，无进度条，无"还差 Y 条解锁全部"励志提示

---

**Rule 9 — skippable 注册 + skip 仅跳到最后 1 帧不截断（`#2 Rule 6` + `#9 Rule 12`）**

KPI Review 屏和 GAMEOVER transition 屏各自向 `#2 Input Handler` 注册 skippable：

- **KPI Review 屏** skippable：`skip` 动作直接 dismiss KPI Review 面板（展示至少 `kpi_review_min_display_frames` 帧后才允许 skip）；若 `game_over_triggered` 已 emit，skip 进入 GAMEOVER_TRANSITION，不跳过离职证明
- **GAMEOVER transition** skippable（重点）：
  - skip 输入 → `t_current = final_transition_duration_ms - 1`（最后 1 帧）
  - **不截断**：离职证明文本全部渲染完成，只是跳过等待时间；1500ms tone 保留
  - **不允许** skip 将 transition 跳为 `t = 0`（直接跳帧） —— "恭喜晋升"必须出现（`#9 Section UI 强制契约` 跨守）
  - `#9 Rule 12`（`settlement_locked = true`）确保 GAME OVER 后 KPI 结算不会因 skip 被中断
- **Archive 列表屏** 无 skippable 注册（Browse 态，玩家主动交互）

---

**Rule 10 — Pillar 1 红线 + Anti-Pillar 2 红线守门（UI 层，全部 PR-blocking）**

`#16` UI 层必须满足以下视觉红线：

| 类型 | 禁止内容 | 备注 |
|------|---------|------|
| 动画 | 金光/金色粒子/辉光特效 | 任何 CanvasItem modulate gold/yellow |
| 动画 | 庆祝粒子/烟花/彩带 | ParticleProcessMaterial celebrate 语义 |
| 动画 | 成就解锁动画/徽章弹出 | 含 VS 词条详情展开动画 |
| 文案 | "挑战失败" | 违反 Anti-Pillar 2 |
| 文案 | "再试一次" | 违反 Anti-Pillar 2 |
| 文案 | "加油" | 违反 Anti-Pillar 2 |
| 文案 | "你很努力" | 违反 Anti-Pillar 2 |
| 文案 | "再坚持一下" | 违反 Anti-Pillar 2 |
| 颜色 | breakdown 数字红色（威胁感） | 数字保持灰色 `#B8B8B8`，无警告色 |
| 布局 | "再来一局"按钮视觉权重 > "查看档案" | 叙事重心在归档，不在重试 |

所有文案 key 经 `subject_inversion_lint.py --domain GAMEOVER,KPI,EVAL,ARCHIVE` 守门（Rule 11）。

---

**Rule 11 — 主语翻转 + HR 口吻 lint（扩展 GAMEOVER.* / KPI.* / EVAL.* / ARCHIVE.* keys）**

`subject_inversion_lint.py` CI 扩展至 `#16` own 的 Localization key 域（继承 `#7 AP Rule 13` + `#9 Rule 14` 同源四轨）：

```
--domain GAMEOVER,KPI,EVAL,ARCHIVE
```

| 违反（玩家主语） | 要求（系统主语） |
|----------------|----------------|
| "你完成了 X%，下月..." | "系统已登记本月积极性（X%）..." |
| "你死了 / 你失败了" | "本届任期已结束" / "离职手续已办理" |
| "你解锁了新词条" | "HR 评语词库已更新" |
| "恭喜你活过了..." | 禁（白名单豁免仅 `GAMEOVER.TITLE_IRONY`） |

CI PR-blocking + writer review 第三层执法（`narrative-director` sign-off）。

---

**Rule 12 — 帧预算 ≤ 4 ms / 屏（月末重屏）**

- KPI Review 屏：初始化帧（Layout + breakdown 渲染）≤ 4 ms；后续帧 ≤ 1 ms
- GAMEOVER transition 屏：每帧 linear 插值更新 ≤ 1 ms（仅 `CanvasItem.modulate.a` 更新，文本已缓存）
- Archive 列表屏：首次渲染（200 条最大情形）≤ 4 ms（虚拟列表，按需实例化）

月末屏为低频触发（每月 1 次），允许首帧最高 ≤ 8 ms，后续帧恢复 ≤ 4 ms。禁在 GAMEOVER transition 每帧重建 UI 节点。

---

**Rule 13 — dispatch ≤ 1 帧**

`#16` 从收到 `kpi_review_started` 信号到首帧 UI 可见，必须在 1 帧内完成（`_process()` 内同帧 dispatch）。`game_over_triggered` → GAMEOVER_TRANSITION 切换同帧（不延 `await`）。Archive 列表屏从 GAMEOVER transition 结束到首帧列表可见，允许最多 2 帧（列表数据来自 `#12` 内存，无 IO）。

---

**Rule 14 — Scope Tier**

| Tier | KPI Review 屏 | GAMEOVER 屏 | Archive UI |
|------|-------------|-------------|-----------|
| **MVP** | 三行 HR breakdown + capacity 对比数字 + M1 破折号 | 离职证明四 reason + IRONY 尾行 + 1500ms linear | 倒序列表 + 逐条删除 + 词库子菜单（词条文本） |
| **VS** | breakdown 对比"上月 vs 下月"参考列 | — | 展开详情（KPI history 数字列表 + NPC 最终 score）+ 词条触发 CONTEXT 说明 |
| **野心版** | 多 ending 文案变体（多公司 × 4 reason） | 额外 ending 动画（仍 1500ms，无 ease） | 跨局 KPI 趋势图（actual_kpi_history 折线） |

---

### States and Transitions

| 状态 | 进入条件 | 退出条件 |
|------|---------|---------|
| `IDLE` | 初始 / GAME OVER 归档完成 | `#6 scene_state_changed(→KPI_REVIEW)` |
| `KPI_REVIEW_WAITING` | `scene_state_changed(KPI_REVIEW)` 收到 | `#9 kpi_review_started` 到达 |
| `KPI_REVIEW_ACTIVE` | `kpi_review_started` + `kpi_threshold_changed` 渲染完成 | `game_over_triggered` → `GAMEOVER_TRANSITION`；或玩家 confirm/skip → `IDLE` |
| `GAMEOVER_TRANSITION` | `game_over_triggered` emit（不可逆） | `final_transition_duration_ms` 到达 + 玩家 confirm → `ARCHIVE_VIEW` |
| `ARCHIVE_VIEW` | GAMEOVER transition 结束 / 主菜单 Archive 入口（OQ-KGO-1） | 玩家退出返回主菜单 → `IDLE` |

`GAMEOVER_TRANSITION` 一旦进入不可逆。`KPI_REVIEW_ACTIVE` 期间 `settlement_locked = true` 后任何 dismiss 无效。

---

### Interactions with Other Systems

| # | 对端 | 方向 | 主接口 |
|---|------|------|--------|
| I-1 | `#6 Scene & Day Flow` ⭐ | 订阅 | `scene_state_changed(→KPI_REVIEW / →GAMEOVER)` 触发状态机；emit `kpi_review_dismissed`（无 GAME OVER 时） |
| I-2 | `#9 KPI System` ⭐ | 订阅 | `kpi_review_started` + `kpi_threshold_changed(breakdown)` + `game_over_triggered(reason, month)` |
| I-3 | `#12 Run Meta` ⭐ | 读取 | `meta.archive`（RunSummary[]）+ `meta.hr_word_library`；emit `archive_item_deleted(run_id)` 删除请求 |
| I-4 | `#10 Event Script` | 引用 | `GAMEOVER.CERTIFICATE.[reason]` Localization key — `#16` 拼接 key，`#3 tr()` 加载 |
| I-5 | `#3 Localization` | 调用 | 所有面板文字通过 `tr(key)` 加载；`_IRONY` 后缀白名单；lint 覆盖 GAMEOVER/KPI/EVAL/ARCHIVE 域 |
| I-6 | `#2 Input Handler` | 双向 | 注册 skippable（KPI Review + GAMEOVER transition 各自独立）；接收 `act_confirm` / `act_skip` |
| I-7 | `#5 Lighting` / `#4 Audio` | 合约（间接） | `#6` dispatch sub-mode 切换，`#5` + `#4` 自动响应；`#16` 不直接调 Lighting/Audio API |

---

## Section D: Formulas

### D1 — 三行 breakdown 数字格式化

```gdscript
func format_contrib_pct(value: float) -> String:
    # value 来自 breakdown 字段，已是比例值（0.028 = 2.8%）
    var pct := value * 100.0
    if pct >= 0.0:
        return "+%.1f%%" % pct    # "+2.8%"
    else:
        return "%.1f%%" % pct     # "-1.2%"（仅 potential 负值，开除剧本不进本屏）

func format_threshold_delta(old: int, new_val: int) -> String:
    return "%d → %d" % [old, new_val]  # "212 → 240"
```

**变量定义**：

| 变量 | 来源 | 范围 | 说明 |
|------|------|------|------|
| `effort_contrib_pct` | `#9 breakdown` | [0, 0.0570] | α × effort_norm；α=0.04，effort_norm ∈ [0, 0.95] |
| `potential_contrib_pct` | `#9 breakdown` | [-0.027, +0.18] | β × potential；β=0.18，potential ∈ [-0.15, +1.0] |
| `tenure_contrib_pct` | `#9 breakdown` | [0, ~0.26] | γ_eff × month_index；γ=0.012，month ∈ [1,N]；M1 = 0.0 |
| `old_threshold` | `breakdown` | [100, +∞) | 本月结算前阈值 |
| `new_threshold` | `breakdown` | [100, +∞) | 月末更新后阈值（`roundi()` 取整，单调不降） |

**Worked Example**（M11 标准 profile，B 保守 α=0.04，β=0.18，γ=0.012）：
- effort_norm = 0.5 → `"+2.0%"`（0.04 × 0.5 × 100 = 2.0）
- potential = 0.0 → `"+0.0%"`
- month = 11 → `"+13.2%"`（0.012 × 11 × 100 = 13.2）
- threshold delta: `"212 → 240"`

### D2 — Localization key 模板

```
KPI.BREAKDOWN.EFFORT_LABEL          # 行 1：努力系数 HR 口吻
KPI.BREAKDOWN.POTENTIAL_LABEL       # 行 2：潜力挖掘 HR 口吻
KPI.BREAKDOWN.TENURE_LABEL          # 行 3：工龄加成 HR 口吻
KPI.BREAKDOWN.POTENTIAL_LABEL_NEG   # 行 2 负 potential 变体（potential < 0）
KPI.BREAKDOWN.TENURE_NOVICE_EXEMPT  # M1 破折号替换
GAMEOVER.CERTIFICATE.[reason]       # 离职证明正文（by #10，4 reason 枚举）
GAMEOVER.CERTIFICATE.UNKNOWN        # fallback key（reason 未知时）
GAMEOVER.TITLE_IRONY                # 固定尾行"恭喜晋升"（_IRONY 白名单）
ARCHIVE.DELETE_CONFIRM              # 删除确认（HR 口吻）
ARCHIVE.CAP_REACHED                 # 200 cap 软提示
ARCHIVE.CAP_SOFT_WARNING            # 180 软警告
ARCHIVE.WORD_LIBRARY_LABEL          # 词库子菜单标题
ARCHIVE.WORD_LIBRARY_EMPTY          # 词库空状态提示
ARCHIVE.NPC_LEFT_LABEL              # Archive 详情 LEFT NPC 标注（VS）
ARCHIVE.DELETE_FAILED               # 删除写盘失败提示
```

所有 key 通过 `#3 tr()` 加载；`#16` 内禁止 hardcode 中文字符串。

---

## Section E: Edge Cases

18 edge cases / 6 categories / 3 RISK GUARD。

### Cat 1 — KPI breakdown 边界

| ID | 场景 | 处理 |
|----|------|------|
| E-1.1 | `breakdown` 缺字段（旧 schema 兼容） | fallback：缺字段显示 `—`（破折号），push_warning，不 crash |
| E-1.2 | `effort_contrib_pct = 0.0`（摸鱼月） | 显示 `"+0.0%"`，不显示 `—`（`—` 仅 M1 新人豁免） |
| E-1.3 | `potential_contrib_pct` 为负（potential ∈ [-0.15, 0)） | 显示 `"-X.X%"`，配 `KPI.BREAKDOWN.POTENTIAL_LABEL_NEG`（HR 口吻："产出略低于预期，已记录"）；不进入开除剧本（开除路径 raw < -0.15 不进本屏） |
| E-1.4 | `new_threshold == old_threshold`（Rule 7 单调守门命中） | delta 显示 `+0`；行 3 tenure 正常显示；不显示"未变化"特殊文案 |
| E-1.5 | `total_mult` 极大值（野心版超长跑，month=20，effort=0.95，potential=1.0） | 数字正常格式化；UI 布局不溢出（数字宽度预留 6 位 + 小数点 + %）；AC-COMPAT-01 覆盖 |

### Cat 2 — GAME OVER transition 边界

| ID | 场景 | 处理 |
|----|------|------|
| E-2.1 | skip 在 `t < 1ms` 极早触发 | 跳到 `t = final_transition_duration_ms - 1`；离职证明文本保证至少 1 帧可见 |
| E-2.2 | skip 触发后再次 skip（double-tap） | 第二次 skip = confirm，进入 Archive 列表；不循环跳帧 |
| E-2.3 | `final_transition_duration_ms` 来源缺失（config 损坏） | fallback 内嵌常量 1500，push_error；禁 0ms（instantaneous = P3 tone 损坏） |
| E-2.4 | reason 枚举未知（新 reason 未加 Localization key） | 显示 `GAMEOVER.CERTIFICATE.UNKNOWN`；push_error 通知 writer 补 key；不 crash |
| E-2.5 | GAMEOVER transition 进行中收到 `kpi_review_started`（信号乱序） | `settlement_locked = true` 拦截；`GAMEOVER_TRANSITION` 态拒绝 `kpi_review_started`，push_error |

### Cat 3 — Archive 200 cap 边界

| ID | 场景 | 处理 |
|----|------|------|
| E-3.1 | `archive.size() == 200`，未删除 | `#12 Rule 7 FIFO` 内存层驱逐；`#16` 顶部显示 `ARCHIVE.CAP_REACHED` |
| E-3.2 | 玩家连续快速删除条目 | confirm 对话框串行，一次一个；禁多个 confirm 同时 pending |
| E-3.3 | 删除 confirm 时 `#1 Save` 写盘失败 | 保持 UI 状态，显示 `ARCHIVE.DELETE_FAILED`；不从内存删除 |
| E-3.4 | `hr_word_library` 空列表（第一局） | 显示 `ARCHIVE.WORD_LIBRARY_EMPTY`（灰字，非错误） |

### Cat 4 — skippable race

| ID | 场景 | 处理 |
|----|------|------|
| E-4.1 | skip 在 `KPI_REVIEW_WAITING` 态触发 | 忽略 skip；`KPI_REVIEW_WAITING` 不注册 skippable，等 `kpi_review_started` 后才注册 |
| E-4.2 | skip 在 `KPI_REVIEW_ACTIVE` 正常月（无 GAME OVER）触发 | skip dismiss KPI Review，emit `kpi_review_dismissed`，进入 IDLE |
| E-4.3 | 玩家长按 skip 键（连续信号） | `#2 Input Handler` 过滤；`#16` 只响应 skip 的首帧边沿（`is_action_just_pressed`） |

### Cat 5 — 三轨 race

| ID | 场景 | 处理 |
|----|------|------|
| E-5.1 | `kpi_threshold_changed` + `game_over_triggered` 同帧到达 | `#9 Rule 2 + Rule 9` 保证顺序：`kpi_threshold_changed` 先，`game_over_triggered` 后；`#16` 按信号顺序处理，先渲染 breakdown，后触发 GAMEOVER_TRANSITION |
| E-5.2 | `#5 Lighting` sub-mode 切换比 `kpi_review_started` 慢 1 帧 | 容忍 1 帧不同步（< 16ms 不可察觉）；禁 `#16 await Lighting` |
| E-5.3 | `#4 Audio` GAMEOVER stinger 比 transition 早完成 | Audio 进 IDLE；`#16` 继续 linear transition；无需同步等待 Audio |

### Cat 6 — 主语翻转 lint

| ID | 场景 | 处理 |
|----|------|------|
| E-6.1 | writer 提交 `GAMEOVER.CERTIFICATE.*` 含"你失败了" | `subject_inversion_lint.py` CI 阻塞 PR + push_error 报告违规行 |
| E-6.2 | `GAMEOVER.TITLE_IRONY "恭喜晋升"` 被 lint 标记违规 | `_IRONY` 后缀豁免规则（`#3 Loc Rule 11` + `#10 Rule 19` 白名单）；lint 正常通过 |
| E-6.3 | `ARCHIVE.DELETE_CONFIRM` 使用"你确定删除吗"（玩家主语） | lint 报告；改为"确认注销员工 #[id] 的职业生涯记录？"（系统主语） |

---

### RISK GUARD（3 条跨守护）

**R-KGO-1: GAME OVER race UI 不一致**（跨守 R-KPI-4）

- **风险**: `game_over_triggered` 到达时 `kpi_threshold_changed` 尚未渲染（breakdown 空）→ 离职证明展示但月末面板未渲染 → 玩家不知道"为什么死"
- **守门**: `#16` 在 `GAMEOVER_TRANSITION` 开始前，断言 `_breakdown_rendered: bool`；若未渲染，强制先渲染 breakdown 一帧，再淡入离职证明
- **AC**: AC-ROBUST-01（BLOCKING）

**R-KGO-2: 离职证明文本错引（`GAMEOVER.CERTIFICATE.[reason]` key 缺失）**（跨守 R-KPI-5 + R-EVT-1）

- **风险**: `#10` 未定义某 reason 的 Localization key → `tr()` 返回 key 字面量出现在屏幕 → P4 tone 破坏
- **守门**: 启动时 `#16._check_required_keys()` 对 4 个 reason key 做静态检查（`TranslationServer.translate(key) != key`）；缺失 → push_error + 显示 `GAMEOVER.CERTIFICATE.UNKNOWN` fallback
- **AC**: AC-ROBUST-02（BLOCKING）

**R-KGO-3: LEFT NPC 数据 leak 进入 Archive（`#8 NPC LEFT` 状态）**（跨守 R-NPC-2 in Archive）

- **风险**: `RunSummary.npc_relationships_snapshot` 含 `LEFT` 状态 NPC 的 score → VS 展开详情显示"Lisa 好感: 75"但 Lisa 已离职 → 误导玩家
- **守门**: `#16` 展开详情时对 `LEFT` 状态 NPC 附加标注 `ARCHIVE.NPC_LEFT_LABEL`（"Lisa（已离职）"）；score 数字仍展示（历史记录，非当前状态）
- **AC**: AC-ROBUST-03（ADVISORY，VS 展开详情功能）

---

## Section F: Dependencies

### Upstream（`#16` 消费）

| 系统 | 依赖内容 | 方向 | 强度 |
|------|---------|------|------|
| `#9 KPI System` ⭐ | `kpi_review_started` + `kpi_threshold_changed(breakdown)` + `game_over_triggered(reason, month)` | `#9` → `#16` | 强（BLOCKING） |
| `#12 Run Meta` ⭐ | `meta.archive(RunSummary[])` + `meta.hr_word_library` 只读接口 | `#12` → `#16` | 强（Archive 屏依赖） |
| `#1 Save System` | Rule 21 `final_transition_duration_ms/easing` + Rule 22 content-only + Rule 23 逐条删 | 合约 | 强（Pillar 守门） |
| `#10 Event Script` | `GAMEOVER.CERTIFICATE.[reason]` key 命名约定 | 合约 | 强（P4 tone 依赖） |
| `#3 Localization` | `tr()` 所有面板文字 + `_IRONY` 白名单 + lint | `#3` → `#16` | 强 |
| `#2 Input Handler` | `act_confirm` / `act_skip` + skippable 协议 | 双向 | 强 |
| `#6 Scene & Day Flow` | `scene_state_changed(KPI_REVIEW / GAMEOVER)` | `#6` → `#16` | 强 |
| `#5 Lighting` | `KPI_REVIEW` 紫 + `GAMEOVER` 灰度（`#6` dispatch） | 合约（间接） | 中 |
| `#4 Audio` | 月末 BGM + GAMEOVER stinger（`#6` dispatch） | 合约（间接） | 中 |

### Downstream（`#16` 提供）

| 系统 | `#16` 提供内容 |
|------|--------------|
| `#20 Accessibility` | Archive 列表 + KPI Review + GAMEOVER 屏须满足 Focus 链 + 字体可读性（Phase 4 Alpha） |

### 双向一致性 cross-check

- `#9 Rule 2`（`kpi_review_started` 信号）← → `#16 Rule 1`（订阅 `kpi_review_started`）✓
- `#9 Rule 10`（breakdown 结构体字段）← → `#16 Rule 2`（渲染三行字段映射）✓
- `#12 Rule 2`（`RunSummary` schema）← → `#16 Rule 7`（Archive 列表渲染字段）✓
- `#1 Rule 21`（`final_transition_duration_ms = 1500, easing = NONE`）← → `#16 Rule 5`（1500ms linear 硬约束）✓
- `#2 Rule 6`（skip 跳到最后 1 帧不截断）← → `#16 Rule 9`（skip → `t = final_transition_duration_ms - 1`）✓

### Propagation Flags

- [FLAG-KGO-1] `#9 breakdown` 新增字段 → `#16 Rule 2` 渲染表须同步更新
- [FLAG-KGO-2] `#10` 新增 `reason` 枚举 → `#16 Rule 6` key 拼接表 + R-KGO-2 key 检查列表须同步
- [FLAG-KGO-3] `#12 RunSummary` schema 字段变更 → `#16 Rule 7` Archive 展示字段须同步
- [FLAG-KGO-4] `final_transition_duration_ms` 值变更（entities.yaml）→ `#16 Rule 5 + Edge E-2.3 fallback` 须同步验证

---

## Section G: Tuning Knobs

| Knob | 类型 | 当前值 | 安全范围 | 影响 |
|------|------|--------|---------|------|
| `final_transition_duration_ms` | Gate（继承） | 1500 ms | [1000, 2500] | GAMEOVER 播片时长；来源 `entities.yaml`（Save Rule 21 锁定，`#16` 只读消费） |
| `kpi_review_min_display_frames` | Gate | 3 帧（≈50ms@60fps） | [1, 10] | KPI Review 屏最短显示帧（防 skip 在渲染前生效）；来源 `config/ui_balance.tres` |
| `archive_list_page_size` | Feel | 20 条 | [10, 50] | Archive 列表每页展示数；< 10 滚动频繁；> 50 首帧 > 4ms；来源 `config/ui_balance.tres` |
| `archive_soft_warning_threshold` | Gate | 180 条 | [150, 195] | 接近 200 cap 时软提示触发点；来源 `entities.yaml`（继承 Save Rule 23） |
| `breakdown_row_height_px` | Feel | 36 px | [28, 48] | 三行每行行高；≥ 28px 保证 CJK 笔画不粘连（art-bible §7.2 约束）；来源 `config/ui_balance.tres` |

### HR 口吻词条分组（`#12 Rule 5` 词库，`#9 Section B C3` 主锚）

| 分组 | 触发区间 | MVP 词条数 |
|------|---------|-----------|
| 新人组（M1-M2） | effort 低 + tenure 短 | 5 条 |
| 奋进组（M3-M5） | effort 高 + potential 高 | 8 条 |
| 稳定组（M4-M8） | effort 中 + potential ≈ 0 | 10 条 |
| 老员工组（M7+） | tenure 长 + capacity 衰减 | 5 条 |
| 裸辞 / Demo 组 | VOLUNTARY_QUIT / DEMO_END | 2 条 |

MVP 共 30 条基础库；实际文案由 writer 撰写，经 narrative-director sign-off 保证 HR 口吻 tone。

---

## Visual/Audio Requirements

### 4 轨 negative space 完整

**数学轨（`#9` breakdown 数字）**:
- 三行字体：等宽体，字号 14-16px，灰色 `#B8B8B8`
- capacity 对比区：同字体，灰色，数字右对齐（HR 报告表格感）
- 颜色：**禁**红色、**禁**橙色、**禁**金色 —— 任何警告色均违反 Rule 10

**听觉轨（`#4` Audio 契约）**:
- `KPI_REVIEW` sub-mode：月末打卡机 BGM（`#4 Rule 7` BGM 白名单）
- `GAMEOVER` sub-mode：GAMEOVER stinger（非悲伤弦乐，非胜利 fanfare）
- `#16` 不直接调 AudioManager；通过 `#6 dispatch GAMEOVER sub-mode` 间接触发

**视觉轨（`#5` Lighting 契约）**:
- `KPI_REVIEW` sub-mode 色调：紫色 `#7C2B91`（`#5 Rule 1` 色值，`#16` 不直接调）
- `GAMEOVER` sub-mode 色调：灰度压抑（`#5 Rule 1` GAMEOVER 色值）
- linear 渐变，无庆祝光效，无 bounce，无 elastic

**文字轨（`#16 + #3 + #10`）**:
- 离职证明：等宽体，白色 `#E8E8E8` on 灰底 `#3A3A3A`
- `GAMEOVER.TITLE_IRONY "恭喜晋升"`：等宽，轻加粗（≤ 500 weight），白，无动画
- Archive 列表：art-bible §7.2 字体层级，继承 `#13 HUD` 数据字体

### 📌 UX Flags

```
📌 UX Flag 1: /ux-design design/ux/kpi-review-screen.md — Phase 4 产出
   负责人: ux-designer
   内容: 月末绩效面板布局 + 三行 breakdown 间距 + capacity 对比行 + confirm 焦点链
   约束: 禁进度条/禁红色/等宽字体/≤ 4ms 预算/Gamepad D-Pad 焦点

📌 UX Flag 2: /ux-design design/ux/gameover-screen.md — Phase 4 产出
   负责人: ux-designer
   内容: 离职证明布局 + linear 1500ms 动画规格 + "恭喜晋升"排版 + 按钮权重
   约束: easing=NONE/无金光/灰度底/1500ms tone/Gamepad 焦点

📌 UX Flag 3: /ux-design design/ux/archive-list-screen.md — Phase 4 产出
   负责人: ux-designer
   内容: Archive 列表 VirtualList 规格 + 逐条删除 confirm 流程 + 词库子菜单导航
   约束: 禁批量删/200 cap 软提示/HR 口吻 confirm 文案/Gamepad 焦点链
```

---

## UI Requirements

### KPI Review 屏（`#16` own `KPIReviewPanel`）

```
KPIReviewPanel
├── HeaderLabel         # "月末绩效登记 — 第 X 月"（tr()）
├── BreakdownContainer
│   ├── EffortRow       # 行 1: effort_contrib_pct + KPI.BREAKDOWN.EFFORT_LABEL
│   ├── PotentialRow    # 行 2: potential_contrib_pct + KPI.BREAKDOWN.POTENTIAL_LABEL[_NEG]
│   └── TenureRow       # 行 3: tenure_contrib_pct + KPI.BREAKDOWN.TENURE_LABEL
│                       # M1 替换: KPI.BREAKDOWN.TENURE_NOVICE_EXEMPT + 破折号
├── Divider             # 灰色细线
├── CapacityRow         # capacity_now → new_threshold（数字对比，禁进度条）
└── ConfirmLabel        # "按确认继续"（右下，小字灰色）
```

数据填充：在 `kpi_threshold_changed` 处理函数内一次性批量设置所有 Label.text，不逐帧更新。

### GAMEOVER 屏（`#16` own `GameOverCertPanel`）

```
GameOverCertPanel (modulate.a: 0.0 → 1.0, linear, 1500ms, TRANS_LINEAR)
├── CertBackground      # 灰底 #3A3A3A
├── CertContent
│   ├── CertTitle       # "离职证明"（等宽，白色）
│   ├── CertBody        # tr("GAMEOVER.CERTIFICATE." + reason)（多行 RichTextLabel）
│   ├── Divider
│   └── IronyTitle      # tr("GAMEOVER.TITLE_IRONY")（等宽，轻加粗，白）
└── ConfirmLabel        # t >= final_transition_duration_ms 后 visible=true
```

### Archive 列表屏（`#16` own `ArchiveListPanel`）

```
ArchiveListPanel
├── CapWarningBar       # archive.size() >= 180 时显示（灰字，ARCHIVE.CAP_SOFT_WARNING）
├── ArchiveVirtualList  # 按需实例化，≤ 4ms@200条
│   └── ArchiveItem × N # run_id / month / tr(final_hr_evaluation_key) / reason
├── DetailPanel         # VS 展开：kpi history + NPC score + unlocks
├── WordLibraryButton   # "HR 评语词库"入口
└── WordLibraryPanel
    └── WordItem × N    # tr(key)，静默，无成就通知
```

---

## Open Questions

**OQ-KGO-1** — Archive 屏主菜单入口路径
- 当前：GAME OVER transition 后自动进入 Archive；主菜单是否也有 Archive 入口 → `#17 Main Menu GDD` 设计时仲裁
- 建议：`#16` own `ArchiveListPanel`；`#17` 通过信号请求 `#16` 进入 `ARCHIVE_VIEW`（共用节点池）

**OQ-KGO-2** — `DEMO_END` 离职证明内容锁定
- `GAMEOVER.CERTIFICATE.DEMO_END` 内容由 writer 撰写；建议"试用期结束 / 感谢参与"语义，区别于"KPI 超限"；tone 仍 HR 口吻
- 解决时机：writer brief 阶段

**OQ-KGO-3** — Archive 展开详情 `actual_kpi_history` 展示形式
- MVP：数字列表（等宽字体）；VS：折线图（Canvas 绘制，`#20 Accessibility` 色盲友好处理）
- 解决时机：VS 设计阶段

**OQ-KGO-4** — `VOLUNTARY_QUIT` 触发路径（MVP 是否实现？）
- 当前 `#9` / `#10` / `#6` GDD 未明确 VOLUNTARY_QUIT 触发路径；建议 MVP 预留 Localization key + Certificate 显示支持，野心版 unlock 触发路径
- 解决时机：野心版 scope 确认

**OQ-KGO-5** — Archive 条目展开 NPC score LEFT 标注（R-KGO-3 实现细节）
- `#8 NPC Relationship` 须在 `#12 RunSummary` snapshot 时提供 `npc_status` 字段（`ACTIVE / LEFT`）
- 解决时机：`#8 NPC Relationship GDD` 复审 + `#12 RunSummary` schema 修订

**OQ-KGO-6** — Gamepad 焦点链最小实现（`#20 Accessibility` Phase 4 前序）
- MVP 焦点链：KPI Review confirm（1 节点）+ Archive 列表（VirtualList 上下）+ 词库（上下）
- 解决时机：UX Flag 1/2/3 设计阶段（Phase 4）

---

## Section H: Acceptance Criteria

22 AC / 5 categories / 3 RISK GUARD。

### AC-FUNC（12 条）

**AC-FUNC-01**: Given `#6 scene_state_changed(→KPI_REVIEW)`，When `#9 kpi_review_started` 到达，Then `KPIReviewPanel` 首帧可见（`KPI_REVIEW_WAITING → KPI_REVIEW_ACTIVE`，dispatch ≤ 1 帧）。Tier: MVP。

**AC-FUNC-02**: Given `kpi_threshold_changed(breakdown)` 到达，When `#16` 处于 `KPI_REVIEW_ACTIVE`，Then 三行 HR 文案渲染正确：行 1 = `KPI.BREAKDOWN.EFFORT_LABEL` + `format_contrib_pct(effort_contrib_pct)`；行 2 = `KPI.BREAKDOWN.POTENTIAL_LABEL` + `format_contrib_pct(potential_contrib_pct)`；行 3 = `KPI.BREAKDOWN.TENURE_LABEL` + `format_contrib_pct(tenure_contrib_pct)`；capacity 对比行 = `"old → new"` 格式。Tier: MVP。

**AC-FUNC-03**: Given M1 结算（`novice_protection_active = true`），When KPI Review 屏渲染，Then 行 3 显示 `—` + `tr("KPI.BREAKDOWN.TENURE_NOVICE_EXEMPT")`；不显示数字百分比。Tier: MVP。

**AC-FUNC-04**: Given `game_over_triggered(reason, month)` emit，When `#16` 处于 `KPI_REVIEW_ACTIVE`，Then 同帧切 `GAMEOVER_TRANSITION`（无 await）+ `#6 dispatch GAMEOVER sub-mode`。Tier: MVP。

**AC-FUNC-05**: Given GAMEOVER_TRANSITION 开始，When transition 完成，Then `GameOverCertPanel.modulate.a` 从 0.0 线性到 1.0；通过 `Tween.get_trans()` 断言 easing = TRANS_LINEAR（无 EASE_IN/OUT/ELASTIC/BOUNCE）。Tier: MVP。

**AC-FUNC-06**: Given `reason = "KPI_EXCEEDS_CAPACITY"`，When GAMEOVER 屏渲染，Then `CertBody.text = tr("GAMEOVER.CERTIFICATE.KPI_EXCEEDS_CAPACITY")`（非 key 字面量）；`IronyTitle.text = tr("GAMEOVER.TITLE_IRONY")`。Tier: MVP。

**AC-FUNC-07**: Given skip 输入在 transition 进行中（`t < final_transition_duration_ms - 1`），When `act_skip` 触发（`is_action_just_pressed`），Then `t_current` 跳至 `final_transition_duration_ms - 1`；`modulate.a ≈ 1.0`；`ConfirmLabel.visible = true`；离职证明文本全部已渲染。Tier: MVP。

**AC-FUNC-08**: Given Archive 列表屏，When `meta.archive.size() >= 1`，Then 列表倒序（最新 run_id 在顶），每条格式 `"#[run_id] · M[month] · [tr(final_hr_eval_key)] · ([reason])"` 正确。Tier: MVP。

**AC-FUNC-09**: Given 玩家选中条目 + confirm 删除，When confirm 对话框弹出，Then 文案使用 `tr("ARCHIVE.DELETE_CONFIRM")`（HR 口吻）；confirm 后条目从列表消失 + `#12` 内存更新 + `#1 autosave` 触发。Tier: MVP。

**AC-FUNC-10**: Given `archive.size() >= 180`（`archive_soft_warning_threshold`），When Archive 列表屏展示，Then `CapWarningBar` 可见 + `tr("ARCHIVE.CAP_SOFT_WARNING")` 灰字（非红色，非阻断弹框）。Tier: MVP。

**AC-FUNC-11**: Given `meta.hr_word_library` 有 N 条，When 玩家打开词库子菜单，Then 显示 N 条 `tr(key)` 文本；无"新词条！"弹出；无星标；底部显示 `"已收集 N 条"` 灰字；无进度条。Tier: MVP。

**AC-FUNC-12**: Given `final_transition_duration_ms` 从 ConfigLoader 加载，When 值 = 1500，Then transition 实际时长 = 1500ms ± 16ms；代码中无 magic number `1500`（lint 检查）。Tier: MVP。

---

### AC-PERF（4 条）

**AC-PERF-01**: Given KPI Review 屏首帧，When `_breakdown_rendered` 完成，Then 帧耗时 ≤ 4ms（Godot profiler）；后续帧 ≤ 1ms。Tier: MVP。

**AC-PERF-02**: Given GAMEOVER transition 每帧，When `modulate.a` 更新，Then 每帧耗时 ≤ 1ms（仅 CanvasItem 更新，文本已缓存）。Tier: MVP。

**AC-PERF-03**: Given `meta.archive.size() = 200`，When Archive 列表首次渲染，Then 首帧耗时 ≤ 4ms（VirtualList 按需实例化）。Tier: MVP。

**AC-PERF-04**: Given 任意屏切换（KPI Review / GAMEOVER / Archive），When 信号到达到 UI 可见，Then ≤ 1 帧（KPI Review + GAMEOVER）/ ≤ 2 帧（Archive 列表）。Tier: MVP。

---

### AC-ROBUST（3 条）[RISK GUARD]

**AC-ROBUST-01**: Given `game_over_triggered` 在 `kpi_threshold_changed` 未渲染时到达，When `#16` 处理，Then `_breakdown_rendered` 断言强制先渲染 breakdown 一帧，再淡入离职证明；不跳过 breakdown（R-KGO-1 守门）。Tier: MVP。[BLOCKING]

**AC-ROBUST-02**: Given 启动时 `GAMEOVER.CERTIFICATE.[reason]` key 缺失，When `#16._check_required_keys()` 执行，Then push_error + 显示 `GAMEOVER.CERTIFICATE.UNKNOWN`；不 crash（R-KGO-2 守门）。Tier: MVP。[BLOCKING]

**AC-ROBUST-03**: Given Archive 展开详情，When `npc_relationships_snapshot` 含 `LEFT` NPC，Then 显示 `"[NPC_NAME]（已离职）"` 标注（`tr("ARCHIVE.NPC_LEFT_LABEL")`）；score 数字仍展示（R-KGO-3 守门）。Tier: VS。[ADVISORY]

---

### AC-COMPAT（2 条）

**AC-COMPAT-01**: Given `breakdown.total_mult` 极大值（month=20，effort=0.95，potential=1.0），When 渲染，Then 数字不溢出容器（预留 6 位 + 小数点 + %）；布局不换行。Tier: VS。

**AC-COMPAT-02**: Given `#20 Accessibility` Phase 4，When 三屏激活，Then 所有可点击元素 `focus_mode = FOCUS_ALL` + `focus_entered()` 高亮；D-Pad 焦点链无死路。Tier: Alpha。

---

### AC-TONE（1 条）

**AC-TONE-01**: Given `KPI.*` / `GAMEOVER.*` / `EVAL.*` / `ARCHIVE.*` 域所有 Localization key，When `subject_inversion_lint.py --domain KPI,GAMEOVER,EVAL,ARCHIVE` CI 执行，Then 0 violations（禁玩家主语/禁"再试一次/挑战失败/加油"/禁金光庆祝动画 Rule 10 红线）；`GAMEOVER.TITLE_IRONY` 豁免正常通过。Tier: MVP。[BLOCKING]

---

## Appendix: 系统边界速查

| 系统 | Own 内容 | `#16` 职责 |
|------|---------|-----------|
| `#9 KPI` | KPI 数学 + breakdown 结构 + GAME OVER 检测 | 仅渲染 breakdown 字段 |
| `#12 Run Meta` | RunSummary 跨局存储 + hr_word_library | 仅读取展示 |
| `#10 Event Script` | `GAMEOVER.CERTIFICATE.[reason]` 文本 | 仅持 Localization key，调 `tr()` |
| `#5 Lighting` | KPI_REVIEW 紫 / GAMEOVER 灰度 sub-mode | 不直接调 Lighting API |
| `#4 Audio` | 月末 BGM / GAMEOVER stinger | 不直接调 AudioManager |
| `#1 Save` | Archive 事务写盘 + final_transition 硬约束 | 仅触发 UI 展示，不写 Save |
