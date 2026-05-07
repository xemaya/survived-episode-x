# HUD System (Diegetic)

> **Status**: Designed (pending review)
> **Author**: huanghaibin + game-designer (Section A-H 主笔) + art-director (diegetic 元素 mapping + visual variant) + ux-designer (帧预算 + gamepad 焦点链) + systems-designer (Section E edges + Section F dependencies) + qa-lead (Section H 22 AC)
> **Last Updated**: 2026-04-27
> **Layer**: Presentation | **Order**: #13 | **Size**: M
> **Implements Pillar**: P2 主(叙事即机制 — diegetic 工位物理元素是唯一 UI 载体)+ P1 守(主语翻转 + 反英雄视觉 — 便利贴不是"你的行动力",是"今天的额度")+ P4 守(苦中作乐 tone — NPC 表情是关系数值的黑色幽默具象)+ P5 守(帧预算 ≤ 2ms / 屏守门)
> **Authoring autonomy mode**: v2 no-prompt(0 widget,autopilot + cross-GDD 9 GDD 全量读取整合)

---

## Section A — Overview

**HUD System (Diegetic)** 是《活过第 X 集》的**唯一信息显示层** —— 以 art-bible §7.1 "diegetic UI 锁"为根本约束,将游戏状态信息**全量内嵌**于工位场景物理空间,禁止任何屏幕悬浮 HUD 元素。

### 双重身份

**技术层**: HUD Diegetic 是**纯渲染层** —— 无自身状态,无自身逻辑,只订阅上游信号并驱动工位场景内对应的 diegetic 元素更新视觉状态。订阅 7+ 上游信号:`scene_state_changed(sub_mode)`(#6)+ `ap_changed` / `energy_changed` / `ap_depleted` / `ap_early_leave_taken` + 三 `effort_*_incremented`(共 7 信号,#7)+ `relationship_changed` / `npc_left_company`(#8)+ `kpi_threshold_changed`(#9)+ `event_completed`(#10)+ `card_played`(#11)+ `accumulation_event`(#5 Lighting 累积视觉)。**自身不计算任何业务数值**,所有数值来自上游信号 payload。

**叙事层**: art-bible §7.1 的宣言在此实现 —— 玩家看到的不是 HP / MP / EXP 条,而是"桌上 8 张便利贴"/"咖啡杯还剩三分之一"/"王总的工位今天空了"/"显示屏 KPI 进度线变红"/"Lisa 侧过身来了"。**工位本身就是 UI**。信息不是叠加在游戏世界之上,它就长在游戏世界里。

### Pillar 服务

- **P2 主 叙事即机制**: diegetic UI 是 P2 最直接的视觉实现 —— 每一个信息元素都是场景内存在的物理对象(便利贴、咖啡杯、显示屏、日历、NPC 身体),**不存在脱离世界叙事的 UI 层**。与 #6 Scene Flow / #7 AP Economy / #8 NPC / #9 KPI 的机制一一对应
- **P1 守 平庸是一种艺术**: 主语翻转在 UI 层的具象 —— "便利贴上的今天的额度"不是"你的行动力";咖啡杯液位不是"你的精力值"。**UI 语言拒绝英雄语义**。Anti-Pillar 1 红线:无任何"AP 上限提升"/ "精力满了"胜利动画
- **P4 守 苦中作乐**: NPC 表情 / 站位是关系数值的黑色幽默具象 —— Lisa 关系 HOSTILE 不弹"友好度 -X"警告,而是她背对你的工位方向。**视觉本身是反讽**
- **P5 守 地铁可玩性**: 帧预算 ≤ 2ms / 屏(HUD 渲染分摊,总帧 16.6ms 守门),保证 5 秒进入 / 5 秒暂停全流程零 HUD 卡顿

### 5 NOT 边界(scope creep 防护)

- **NOT** 屏幕悬浮 HUD —— art-bible §7.1 锁,无任何 HP 条 / MP 条 / 行动点数字浮层;本 GDD 是 diegetic 唯一实现者
- **NOT** 累积视觉自渲染 —— Lighting & Visual State Controller(#5)own `desk_stain_count` / `break_room_cracks` / `notice_board_age` / `anniversary_year` state 与渲染;本 GDD 仅订阅 `accumulation_event` 调整 diegetic 元素 visual variant
- **NOT** 行动卡 UI —— Card Play & Dialogue UI(#14)own 卡面渲染、选卡交互、AP 成本动画;本 GDD 仅显示 AP 总量状态
- **NOT** 月末结算屏 —— KPI Review & Game Over UI(#16)own 月末全屏结算;本 GDD 在 `KPI_REVIEW` sub-mode 下仅调整显示器数据屏视觉 variant,不 own 结算 UI
- **NOT** 事件对白 UI —— Card Play & Dialogue UI(#14)own 事件场景渲染;本 GDD 在 `event_completed` 信号后更新 HUD 状态 + flash overlay

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 任何屏幕悬浮数字 HUD 元素(违反 art-bible §7.1 diegetic 锁 + P2)
- **NOT** 用 UI 文案将"今天的额度"称为"你的行动力 / 你的 AP"(违反主语翻转 P1 + P4)
- **NOT** NPC 离职后显示其关系数值或工位编号(违反 R-NPC-2 LEFT 视觉屏蔽守门 + P3)
- **NOT** 累积视觉 state 由本 GDD 自渲染(违反 #5 Lighting ownership 边界 — 本 GDD 只调 variant selector,不持有 cumulative state)
- **NOT** 帧超 2ms / 屏 HUD 渲染(违反 P5 帧预算守门 + R-HUD-3)

### Source 引用

`design/art/art-bible.md` §7.1 Diegetic UI 锁(唯一信息层)+ §7.2 字体层级 + §3.3 UI 形状语法(0 圆角 / 1 px 边框 / 表格语义)+ §4.1 主调色板 + §2 Mood & Atmosphere 8 sub-mode 情绪地图。`design/gdd/scene-day-flow-controller.md` Rule 3 帧预算 + Section A 8 sub-mode enum。`design/gdd/ap-economy-system.md` Rule 2 `ap_changed` / Rule 5 `ap_depleted` / Rule 4 `ap_early_leave_taken` / Rule 6 `effort_*_incremented` 7 信号契约 + Section B "今天的额度" 主语翻转守门。`design/gdd/npc-relationship-system.md` Rule 3 RelationshipPhase + Rule 7 NpcLifecycleState + I-3 HUD 订阅契约 + R-NPC-2 LEFT 视觉屏蔽守门。`design/gdd/kpi-reverse-threshold-system.md` Rule 13 `kpi_threshold_changed` 信号 + Rule 10 breakdown + capacity_now 预警(R-AP-5)。`design/gdd/lighting-visual-state.md` Rule 5 accumulation_event 订阅契约 + 4 维度 schema。`design/gdd/localization-hooks.md` Rule 1 key 命名 + Rule 11 `_IRONY` 后缀守门 + Rule 6 主语翻转 lint 扩展 AP/ENERGY/NPC/EVENT keys。`design/gdd/event-script-engine.md` Rule 5 `numeric_only` 档 HUD 主显协议。`design/gdd/action-card-system.md` `card_played` 信号契约。

---

## Section B — Player Fantasy

### 主锚: "便利贴上的待办,桌面的咖啡杯,墙上的考勤表"

**场景**(玩家时刻):
你点开 DayTimeline。没有 HP 条,没有 AP 数字叠层,没有任何浮在世界外面的 UI。你看到的是:桌上 8 张小便利贴,从左到右排开,每张写着今天的一个行动格子 —— 它们就放在那里,像真的便利贴那样。咖啡杯在桌角,还剩大半杯。显示屏上的数据表格在滚动,KPI 栏里一条细细的黄色进度线。隔壁工位 Lisa 正侧身看着前方,没有看你。你不需要读 UI,你就是坐在那里上班。

**Pillar 服务**:
- **主 P2 叙事即机制**: 信息不在 UI 层,它在桌子上、杯子里、墙上、同事脸上 —— 每个 diegetic 元素都是世界的组成部分,不是被附加到世界的数值显示
- **守 P1 平庸是一种艺术**: 便利贴是"今天的额度",不是"你的行动力"。主语是工作的节奏,不是你的角色能力。**工位不奖励你,工位只显示状态**
- **守 P4 苦中作乐**: NPC 表情和站位是关系数值的黑色幽默具象 —— 你不会看到"Lisa 友好度 -3",你会看到她今天背对你
- **守 P5 地铁可玩性**: 一眼扫完工位就掌握全局信息,不需要打开子菜单/悬停数字 —— **空间即信息架构**

**跨 GDD negative space 联动**:
- **AP Economy** "今天的额度" 共振: `ap_changed(current, max)` 信号驱动便利贴 fill 状态,而不是数字计数器
- **NPC** "同事都走了你还在" 共振: 空工位是最强的关系 HUD —— 不弹"Lisa 已离职"通知,只是她的椅子空了
- **Lighting** "我的桌子怎么这么脏" 共振: 桌面咖啡杯渍逐月增加(#5 accumulation state),HUD 的"精力杯"也在这个叙事里变得更脏

### 副锚: "AP 不是 UI 数字,是工位上的 8 个空格"

**场景**(玩家时刻):
打了第三张卡,便利贴从右向左数第三张被划掉 —— 不是数字减少,是一张小纸条出现了斜线。你看着还剩 5 张没划的,想了一下午饭的时间要不要再打一张。物理的纸,物理的位置,物理的空缺感 —— "AP" 这个词在这里是不存在的,只有"还剩几张"。

**Pillar 服务**:
- **主 P2 叙事即机制**: AP 数值转化为物理空间 —— 便利贴格子是 AP 在世界里的形态,不是悬浮数字
- **守 P1 平庸是艺术**: 划便利贴没有音效,没有动画,没有进度条填满的快感 —— 它只是一张划掉的纸
- **守 P4 苦中作乐**: "花完 8 张便利贴"不是成就,是"今天的格子用完了"

**跨 GDD negative space 联动(铁三角第六轨 diegetic 基底)**:
- **Audio** "打卡机不是胜利音" 机制基底: 便利贴划掉没有胜利音 —— 连 UI 层都拒绝庆祝
- **Lighting** "再苟一天" 共振: 日落橙打在工位上,8 张便利贴还剩 2 张没划的 —— 场景信息和叙事信息在同一个物理空间里共振

**❌ Tone 风险(必避)**:
- "行动力 8/8 ✓ 完美执行"(英雄叙事 —— HUD 不奖励用满)
- "AP +0 / AP 已充满"(产权语义 —— "你的" AP 违反主语翻转)
- 便利贴划完时出现金光 / 庆祝动画(违反 Anti-Pillar 1 + P4)
- 弹"今日任务完成 X%"进度条(违反 P1 反英雄红线)

**✅ Tone 守护(推荐)**:
- 便利贴视觉 —— 空格/已划/加班加格,无文字数值叠层
- 咖啡杯液位 —— 自然下降,无"精力 XX/100"数字
- NPC 表情 + 站位 —— 无"好感度"文字标签
- 显示屏 KPI 进度线 —— 细线 + HR 文档风格,无"KPI X% / 目标 Y%"大字浮层

---

## Section C — Detailed Rules

本节分三部分:**14 Core Rules**(diegetic HUD 行为)+ **States and Transitions**(sub-mode 视觉布局状态机)+ **Interactions**(7 跨系统契约)。

### Core Rules

**Rule 1 — Diegetic UI 元素清单(MVP 8 元素)**

HUD System owns 以下 8 个 diegetic 工位元素的视觉状态管理。每个元素对应一个 `HudElementState` resource,由上游信号驱动更新。

| 元素 ID | 物理形态 | 数据来源 | visual variant 数量 |
|--------|---------|---------|---------------------|
| `HUD_STICKY_NOTES` | 桌面便利贴列(AP 格) | `#7 ap_changed(current, max)` | 11 态(0-8 base + overtime 9-10 + early_leave 折角) |
| `HUD_COFFEE_CUP` | 桌角咖啡杯液位 | `#7 energy_changed(current, max)` | 5 态(满/3/4/1/2/1/4/空 + burnout 特殊) |
| `HUD_MONITOR_DATA` | 显示屏数据表格 | `#9 kpi_threshold_changed` | 5 态(正常/预警黄/超标红/GAME OVER 前/GAMEOVER 灰) |
| `HUD_ATTENDANCE_BOARD` | 墙上考勤表格/日历 | `#6 scene_state_changed` | 8 态(8 sub-mode 各自变体) |
| `HUD_DESK_CALENDAR` | 工位桌面日历(当日标记) | `#6 scene_state_changed` | 31 帧 × month_index 组合(每天一格) |
| `HUD_NPC_EXPRESSION` | NPC 表情 sprite | `#8 relationship_changed` | 4 Phase × 8 NPC(HOSTILE/NEUTRAL/WARM/CLOSE × NpcId) |
| `HUD_NPC_POSITION` | NPC 工位站位 | `#8 relationship_changed` / `#6 scene_state_changed` | 4 Position(背对/正常/侧身望/靠近) |
| `HUD_EMPTY_CHAIR` | 离职 NPC 空椅 | `#8 npc_left_company` | 2 态(在职工位/LEFT 空椅 —— R-NPC-2 守门) |

**MVP scope**: 8 元素全量;VS 扩展至 12+ 元素(加入侧面茶水间水杯占位/键盘磨损/加班记录板等);野心版全 diegetic 物理交互(便利贴可拖动/咖啡杯可点击)。

---

**Rule 2 — Sub-Mode HUD 视觉布局状态切换**

HUD Diegetic 订阅 `#6 scene_state_changed(old_mode, new_mode)`,在每次 sub-mode 转移时**同帧**更新 diegetic 布局配置。每个 sub-mode 对应不同元素可见性 + 视觉激活状态。

| Sub-Mode | 便利贴 | 咖啡杯 | 显示器 | 考勤表 | 日历 | NPC 表情/站位 | 空椅 | 备注 |
|----------|--------|--------|--------|--------|------|-------------|------|------|
| `MAIN_MENU` | 隐藏 | 隐藏 | 隐藏 | 隐藏 | 隐藏 | 隐藏 | 隐藏 | 主菜单无工位 HUD |
| `MORNING_BRIEFING` | 全亮(今日 AP 预览) | 满液位 | 静态 KPI 历史线 | 当周高亮 | 当日高亮 | 中性站位 | 按 lifecycle 显示 | 日历+考勤表主角 |
| `ACTION_DAY` | 动态 fill(AP 消耗) | 液位实时 | KPI 实时线 | 当周高亮 | 当日高亮 | 实时关系 | 按 lifecycle | 主交互布局 |
| `ACTION_OVERTIME` | 加班 +2 格(9-10) | 液位继续 | KPI 线加重(overtime 色调) | overtime 高亮 | overtime 标记 | 实时关系 | 按 lifecycle | 便利贴额外 2 格浅色 |
| `AFTER_WORK` | 当日最终状态静止 | 最终液位静止 | 日结线静止 | 静止 | 静止 | 静止 | 按 lifecycle | 下班抉择节点,全元素静止 |
| `DAILY_RECAP` | 全划完 variant | 静止 | 日结线 | 本周累计 | 今日 ✓ 标记 | 收工站位 | 按 lifecycle | 今日总结数据屏主角 |
| `KPI_REVIEW` | 隐藏 | 隐藏 | 全屏结算 variant(→ #16 接管) | 月度高亮 | 月末标记 | 全员 NEUTRAL 站位 | 按 lifecycle | 显示器→月末模式,#16 主屏覆盖 |
| `GAMEOVER` | 隐藏 | 隐藏 | 隐藏 | 隐藏 | 隐藏 | 所有 NPC 背对/空位 | 所有已 LEFT 空椅可见 | Save Rule 21 1500ms 锁 |

**转移时机**: 每次 `scene_state_changed` 收到时,调用 `_apply_layout_for_mode(new_mode)`,**同帧**更新。不做跨帧 tween(布局变化 ≠ 视觉 tween —— 光态 tween 由 #5 Lighting 负责)。

---

**Rule 3 — AP 显示协议(便利贴格)**

便利贴列是 AP 数值的 diegetic 具象。格式严格按 `ap_changed(current_ap, max_ap_today)` 信号 payload 驱动。

**视觉状态映射**:

| AP 状态 | 便利贴 variant | 视觉语义 |
|--------|--------------|---------|
| 未使用格(current < max) | 空白便利贴(白色 `#E8E0CC` 底,无划线) | 今天还没用的额度 |
| 已使用格(count = max - current) | 斜线便利贴(1px `#2A1F14` 斜线) | 已花出去的格子 |
| 加班格(max = 10,格 9-10) | 浅灰色便利贴(无斜线,`#BBBBBB` 底) | 借来的,不是发的 |
| 早退留格(early_leave,remaining 1-2) | 便利贴右上角折角 variant | 今天没花完的 |
| AP = 0(全划完) | 8/10 张全斜线 + 无新格 | 用完了 |

**主语翻转强制规范**:

所有便利贴关联的 Localization key **禁** "你的行动力 / 你的 AP / 你的能量" 语义。必须使用"今天的额度 / 今日格子 / 发的格"。`subject_inversion_lint.py --domain AP,ENERGY` 在 CI 阶段 lint 所有 HUD 关联 key(`HUD.*` namespace)。

**加班格视觉规范**:
- 加班格(第 9-10 格)视觉**不得**高亮/闪光/特殊色(违反 Anti-Pillar 1)
- 加班格底色为浅灰 `#BBBBBB`(明显区分于基础 8 格,传达"这是借来的"感知)
- 加班格无"加班 ✓ 成就"标记;不触发 HUD 层任何庆祝动画

---

**Rule 4 — Energy 精力显示协议(咖啡杯液位)**

咖啡杯是精力(`current_energy`)的 diegetic 具象。订阅 `#7 energy_changed(current_energy, max_energy)` 信号,**实时**映射液位高度。

**液位阶段**:

| energy 区间 | 液位 variant | 杯色 | 备注 |
|------------|------------|------|------|
| [80, 100] | 满杯(4/4) | 深咖啡棕 `#7A5838` | 初始状态 |
| [50, 79] | 3/4 杯 | 中咖啡 | 正常工作日 |
| [20, 49] | 半杯(2/4) | 浅咖啡偏淡 | 精力中等 |
| [1, 19] | 1/4 杯(少量残留) | 极淡 `#D4C0A8` | 近 burnout |
| [0] | 空杯 + 干渍底 | 咖啡渍棕黑 `#2A1F14` 底 | Burnout 状态 |

**Burnout 视觉扩展**:
- `current_energy = 0`:咖啡杯叠加"干渍"variant(art-bible §4.1 咖啡渍棕黑),杯外出现环形渍斑 sprite(width 2px)
- 不弹"精力耗尽"警告 HUD —— 咖啡杯状态本身即信息
- **禁** "精力不足 ⚠" 红色悬浮警告 UI(违反 diegetic 锁 + 主语翻转)

**主语翻转规范**: Localization key 禁 "你的能量 / 你的精力 / 你的体力"。推荐 "咖啡还剩 / 今天撑到现在 / 还能坚持"。

---

**Rule 5 — NPC 表情 + 站位显示协议**

NPC 表情和站位是关系数值的 diegetic 具象,由 `#8 relationship_changed(npc_id, old_score, new_score, reason)` 信号驱动实时更新。

**Phase → 站位/表情映射**:

| RelationshipPhase | 站位 variant | 表情 variant | 视觉语义 |
|------------------|------------|------------|---------|
| `HOSTILE` [-100,-30) | 背对工位方向(正面朝外) | 冷漠表情(无目光接触 sprite) | 拒绝感知你的存在 |
| `NEUTRAL` [-30,+30) | 正常侧身站位(默认工位朝向) | 无表情(工作状态 sprite) | 普通共存 |
| `WARM` [+30,+70) | 轻微侧身望向玩家方向 | 轻微正向表情(非"友好",是"注意到你") | 有意识地注意到 |
| `CLOSE` [+70,+100] | 身体略朝向玩家工位(仍保持距离) | 轻微点头表情(克制,非"喜欢") | 默契但不张扬 |

**关系变化动画规范**:
- Phase 变更时:NPC sprite **淡入新 variant**(0.2s tween,无突变)
- Phase 内部 score 变化:不更新 sprite(仅 Phase 跨越时视觉变化,避免频繁刷新)
- **无"关系 +5" toast / 无"友好度↑"浮字**:所有数值变化只反映在 NPC 物理姿态,不弹任何文字 UI

**LEFT 视觉屏蔽 R-NPC-2 守门**:
- `npc_left_company(npc_id, reason)` 信号触发后,立即将对应 NPC 所有 HUD 视觉元素切换至 `HUD_EMPTY_CHAIR` variant(空工位:椅子 + 桌面空置 sprite)
- **严禁**:LEFT NPC 的 `relationship_score` 数字在任何 HUD 元素中可见(数字 leak = R-HUD-2)
- **严禁**:LEFT NPC 的工位编号 / 名字标签在 HUD 中残留
- 空椅 variant 仅显示工位物理状态(空椅 sprite + 桌面清空),不显示 "Lisa 已离职" 文字

---

**Rule 6 — KPI 进度条显示协议(显示屏数据屏)**

显示器(电脑屏幕内嵌数据表格)是 KPI 阈值和当前完成度的 diegetic 具象。订阅 `#9 kpi_threshold_changed(old, new, delta_pct, breakdown)` 信号。

**显示器数据屏 variant**:

| KPI 状态 | 数据屏 variant | 主色调 | 细节 |
|---------|------------|-------|------|
| 正常(capacity_now > threshold × 1.2) | 普通 Excel 表格风格滚动 | `#5A7080` 灰蓝(art-bible §4.1) | 细线+小字体,不抢镜 |
| 预警(capacity_now ∈ [threshold, threshold × 1.2]) | 黄色进度线变粗 | `#F5C400`(art-bible §4.4 UI 警告黄) | 仅进度线色变化,表格其余不变 |
| 超标(capacity_now < threshold) | 红框叠加 | `#C83428`(art-bible §4.2 世界警告红) | 1px 红框环绕整个数据屏区域 |
| GAMEOVER 前(threshold > capacity_now 本月) | 数据屏闪烁(每 2s 一次,1 帧亮→暗) | 同超标色 | 月末 `KPI_REVIEW` 前触发 |
| `GAMEOVER` sub-mode | 数据屏变灰(降饱和 100%) | `#999999` | 与 #5 Lighting GAMEOVER palette 对齐 |

**capacity_now 预警 R-AP-5 跨 GDD 守门**:
- 当 `capacity_now < threshold`(R-AP-5 判据,来自 `#9 kpi_threshold_changed` breakdown):HUD 显示器进入"超标"variant
- **此预警不弹任何屏幕叠层 / toast** —— 信息完全通过显示器 diegetic 元素传递
- KPI breakdown 三行戏谑化 HR 口吻文案:仅在 `KPI_REVIEW` sub-mode 由 #16 渲染,**本 GDD 不渲染月末文案**

---

**Rule 7 — 累积视觉订阅协议(#5 accumulation_event)**

本 GDD 订阅 `#5 Lighting 的 accumulation_event(type, new_value)` 信号,**不持有累积 state**(state 由 #5 own),仅在收到信号后调整对应 diegetic 元素的 visual variant selector。

**accumulation_event → diegetic 元素映射**:

| `accumulation_event.type` | 对应 diegetic 元素 | variant 调整规则 |
|--------------------------|------------------|----------------|
| `desk_stain_count` | `HUD_COFFEE_CUP`(杯外渍斑) | `clamp(new_value, 0, 4)` 映射 5 级杯外渍斑密度 |
| `notice_board_age` | `HUD_ATTENDANCE_BOARD`(考勤表板) | age 区间([0-2]/[3-5]/[6-11]/[12+])映射 4 级褪色 variant |
| `break_room_cracks` | HUD 不直接渲染茶水间(#5 Lighting own);HUD 忽略此 type | N/A — HUD scope 仅工位 |
| `anniversary_year` | `HUD_ATTENDANCE_BOARD`(周年横幅叠加) | `anniversary_year > 0` → 横幅 variant 叠加(art-bible §4.6 俗艳粉 `#E8609A` + 2px 黑框) |

**纪律**: HUD 收到 `accumulation_event` 时**只调 variant selector**,不持有 `desk_stain_count` / `notice_board_age` 数值副本。variant selector 从 `new_value` payload 计算,计算后不缓存。

---

**Rule 8 — Flash 事件 Overlay 协议(event_completed / numeric_only 档)**

`#10 Event Script Engine` emit `event_completed(event_id, density)` 信号。`density = NUMERIC_ONLY` 时,HUD 是主显层(无 #14 Card Play UI 事件对白框渲染)。

**numeric_only 档 HUD 主显规范**:
- 触发:收到 `event_completed(event_id, density=NUMERIC_ONLY)` 时
- 显示:在 `HUD_MONITOR_DATA` 区域叠加一行小字(art-bible §7.2 字体层级 Caption 级:8px 像素字体),格式:`"[事件类型] [数值变化]"` —— 单行,**禁多行** / **禁弹窗**
- 时长:1.5s 自动消失(无需用户 dismiss)
- tone 守门:文案必须符合 `_BUREAUCRATIC` 后缀 Localization key 命名,使用系统主语("`系统记录了您的协作积极性`")而非玩家主语

**card_played 信号**:
- 订阅 `#11 card_played(card_id, ap_cost)` 信号
- 触发:`HUD_STICKY_NOTES` 同帧更新(划去对应格子)—— 便利贴视觉与卡打出同步

---

**Rule 9 — 帧预算协议(≤ 2ms / 屏)**

HUD Diegetic 渲染分配帧预算 **≤ 2ms**(来自 `#6 Rule 3` 分摊,总帧 16.6ms 守门)。

**分摊细则**:

| HUD 子任务 | 预算估算 | 优化策略 |
|-----------|---------|---------|
| `_apply_layout_for_mode()` sub-mode 切换 | ≤ 0.5ms | 纯 variant selector 切换(无复杂计算) |
| NPC sprite variant 更新(最多 8 NPC,Phase 变化时) | ≤ 0.5ms | AtlasTexture.frame_coords 切换,同 atlas 零额外内存 |
| 便利贴格 fill 状态更新(每次 ap_changed) | ≤ 0.3ms | 8-10 个 Node2D visible/modulate,批量 apply |
| 咖啡杯液位 variant(每次 energy_changed) | ≤ 0.2ms | 5 级 AtlasTexture,单帧切换 |
| 显示器 KPI variant(每次 kpi_threshold_changed) | ≤ 0.2ms | 5 级 variant,单帧切换 |
| flash overlay 渲染(numeric_only 档) | ≤ 0.2ms | 单行 Label,1.5s timer + queue_free |
| 日历/考勤表更新(scene_state_changed) | ≤ 0.1ms | sub-mode 变化时一次性 apply |

**[RISK GUARD — R-HUD-3]**: 如实测帧超 2ms,优先检查 NPC sprite 更新频率(Phase 变化时才触发,非每帧)→ 检查 flash overlay Label 实例化频率 → 检查 ap_changed 信号 emit 频率(应为打卡触发,非 process() 每帧 poll)。

**Godot 4.6 实现要求**:
- 所有 HUD diegetic 元素使用 `AtlasTexture.frame_coords` 切换(同 atlas,零额外 draw call)
- `ap_changed` / `energy_changed` 等信号接收器为 `_on_*` 方法,**禁止** `_process()` 内轮询
- `_apply_layout_for_mode()` 一帧内完成(禁跨帧 coroutine)

---

**Rule 10 — 主语翻转 + Pillar 4 反英雄 Lint(AP/ENERGY/NPC/EVENT keys)**

本 GDD 是主语翻转 lint 的**重要扩展域**,覆盖所有 `HUD.*` namespace Localization key。

**禁用主语模式**:

| 违反(玩家主语) | 要求(外部/系统主语) | Lint 规则 |
|--------------|------------------|----------|
| "你的行动力 X/8" | "今天的额度 X 格" | `AP` domain lint |
| "你的精力 XX%" | "咖啡还剩 X 格" | `ENERGY` domain lint |
| "你与 Lisa 的友好度 +3" | "(无文字,NPC 姿态变化即信息)" | `NPC` domain lint |
| "你完成了 X 个事件" | "系统记录了 X 项活动" | `EVENT` domain lint |

**`_IRONY` 后缀守门(#3 Localization Rule 11)**:
- 任何 KPI 相关 HUD 文案 key(含 numeric_only flash overlay)必须具备 `_IRONY` 后缀,经 Localization lint 检查上下文变量(`context_type` 字段)
- 主语翻转 lint 脚本:`subject_inversion_lint.py --domain AP,ENERGY,NPC,EVENT` 覆盖 `HUD.*` namespace,CI 守门

---

**Rule 11 — 信号订阅架构(7+ 上游)**

HUD Diegetic 是纯下游订阅者,**不 emit 任何业务信号**。

**订阅清单**:

| 信号 | 来源 GDD | 触发 HUD 行为 |
|------|---------|--------------|
| `scene_state_changed(old, new)` | `#6` Rule 3 | `_apply_layout_for_mode(new)` |
| `ap_changed(current, max)` | `#7` Rule 2 | `HUD_STICKY_NOTES` fill 更新 |
| `energy_changed(current, max)` | `#7` Rule 7 | `HUD_COFFEE_CUP` 液位更新 |
| `ap_depleted()` | `#7` Rule 5 | `HUD_STICKY_NOTES` 全划完 variant |
| `ap_early_leave_taken()` | `#7` Rule 4 | `HUD_STICKY_NOTES` 早退折角 variant |
| `effort_overtime_incremented(day, total)` | `#7` Rule 6 | `HUD_STICKY_NOTES` 加班格 +2 浅色格 |
| `effort_hero_incremented(card_id, day, total)` | `#7` Rule 6 | (接口预留,MVP HUD 不直接渲染 effort 数值) |
| `effort_overage_incremented(card_id, day, total)` | `#7` Rule 6 | (接口预留,MVP HUD 不直接渲染 effort 数值) |
| `relationship_changed(npc_id, old, new, reason)` | `#8` Rule 5 | `HUD_NPC_EXPRESSION` + `HUD_NPC_POSITION` Phase 映射 |
| `npc_left_company(npc_id, reason)` | `#8` Rule 7 | `HUD_EMPTY_CHAIR` variant(R-NPC-2 守门) |
| `kpi_threshold_changed(old, new, delta_pct, breakdown)` | `#9` Rule 13 | `HUD_MONITOR_DATA` variant 更新 |
| `event_completed(event_id, density)` | `#10` Rule 5 | flash overlay(numeric_only 档)/无显示(long/flash 档) |
| `card_played(card_id, ap_cost)` | `#11` | `HUD_STICKY_NOTES` 同帧划格 |
| `accumulation_event(type, new_value)` | `#5` Rule 5 | diegetic variant selector 调整(Rule 7) |

**信号接收纪律**: 所有信号接收在 `_on_*` 方法内,**禁止** `_process()` 轮询任何 HUD 状态。

---

**Rule 12 — Diegetic 红线:禁屏幕悬浮 HUD(art-bible §7.1)**

**本规则无豁免,无例外列表,无 creative-director 临时豁免路径。**

**禁止的 UI 元素类型**:
- HP 条 / MP 条 / AP 数字悬浮层 / 精力数字悬浮层
- 关系数值悬浮 toast("友好度 +X")
- KPI% 大字悬浮进度条
- 任何固定 screen-space 覆层(不随摄像机移动的 UI 元素)
- "成就解锁 / 任务完成 / 今日完美"通知弹窗

**合法 UI 元素**:
- 工位场景内的物理对象变体切换(AtlasTexture 切换)
- `numeric_only` 档 flash overlay —— 单行小字,1.5s 消失,位于 `HUD_MONITOR_DATA` 区域内(属于显示器物理空间的 diegetic 元素)
- #16 KPI Review & Game Over UI 全屏结算(非本 GDD own,属于另一系统)

**Switch 移植退路(野心版)**:art-bible §7.5 预留 Screen-Space 摘要面板作为 Switch 移植降级方案。**MVP 阶段绝对不启用此路径。**

---

**Rule 13 — Save 持久化(无,HUD 是纯渲染层)**

HUD Diegetic **不持有任何需要持久化的状态**。

- 所有 HUD 显示的数值来自上游系统信号 payload(#7 AP / #8 NPC / #9 KPI / #5 Lighting 各自持久化)
- 游戏重新加载时,HUD 在 `READY` 状态后订阅信号并重新计算 variant
- `HudElementState` resource 是运行时临时对象,无需 Save 序列化
- **`HUD_EMPTY_CHAIR`** 状态来自 `#8 NpcLifecycleState.LEFT`,由 #8 持久化;HUD 在 READY 后查询 `#8.is_npc_active()` 重建初始空椅布局

---

**Rule 14 — Scope Tier**

| Tier | HUD 元素范围 | diegetic 交互深度 |
|------|-----------|----------------|
| **MVP** | 8 元素(便利贴/咖啡杯/显示屏/考勤表/日历/NPC 表情/NPC 站位/空椅) | 纯视觉 variant 切换,无玩家交互 |
| **VS(Vertical Slice)** | 12+ 元素(+茶水间水杯/键盘磨损/加班记录板/公告栏 pin 数) | 可悬停查看详情(gamepad D-Pad 聚焦) |
| **野心版** | 全 diegetic 物理交互 | 便利贴可拖动排序/咖啡杯可点击触发 coffee break 事件 |

---

### States and Transitions

HUD Diegetic 主状态机继承 `#6 Scene & Day Flow Controller` 的 LOADING / READY 两态,**不独立管理状态**。

| 状态 | 含义 | HUD 行为 |
|------|------|---------|
| **LOADING** | 等 #6 READY 信号 | 所有 diegetic 元素 `visible = false`;订阅注册但不 apply |
| **READY** | 正常运行 | 所有信号订阅激活;layout 由当前 sub-mode 决定 |

**READY 进入后初始化顺序**:
1. 查询 `#6.current_sub_mode` → `_apply_layout_for_mode()`
2. 查询 `#7.current_ap` / `#7.current_energy` → 初始化便利贴 + 咖啡杯
3. 查询 `#9.capacity_now` vs `#9.monthly_threshold` → 初始化显示器 variant
4. 遍历 8 NPC,查询 `#8.get_relationship_phase()` + `#8.is_npc_active()` → 初始化 NPC 表情/站位/空椅
5. 查询 `#5.accumulation_state(type)` payload → 初始化 diegetic variant selector

---

### Interactions

**I-1: #6 Scene & Day Flow Controller — sub-mode 调度**

订阅 `#6 scene_state_changed(old_mode, new_mode)`,每次转移同帧调用 `_apply_layout_for_mode(new_mode)`,更新 8 diegetic 元素可见性 + visual variant。**HUD 不主动调用 #6 任何 API**,完全被动。

**I-2: #7 AP Economy — AP/Energy/Effort 7 信号**

订阅 7 信号(见 Rule 11 清单)。每次 `ap_changed` / `energy_changed` 同帧更新对应 diegetic 元素。`effort_hero_incremented` / `effort_overage_incremented` 两信号 MVP 不渲染 effort 数值(接口预留,VS 扩展加班记录板时消费)。

**I-3: #8 NPC Relationship — 关系 + 离职**

订阅 `relationship_changed(npc_id, ...)` + `npc_left_company(npc_id, ...)`。Phase 变更时更新 NPC 表情/站位;LEFT 时切换空椅 variant,R-NPC-2 守门(禁 score 数字可见)。

**I-4: #9 KPI System — threshold/capacity 预警**

订阅 `kpi_threshold_changed(old, new, delta_pct, breakdown)`,更新 `HUD_MONITOR_DATA` variant。使用 `breakdown.capacity_now` 计算预警阈值。月末 `KPI_REVIEW` sub-mode 后,#16 接管全屏,本 GDD 仅维持背景显示器 variant。

**I-5: #5 Lighting — 累积视觉**

订阅 `accumulation_event(type, new_value)`,调整对应 diegetic variant selector。**不 own cumulative state**,仅响应事件。

**I-6: #10 Event Script Engine — event_completed**

订阅 `event_completed(event_id, density)`,`density = NUMERIC_ONLY` 时在 `HUD_MONITOR_DATA` 区域渲染单行 flash overlay。

**I-7: #11 Action Card — card_played**

订阅 `card_played(card_id, ap_cost)`,同帧更新 `HUD_STICKY_NOTES` 划格。

---

## Section D — Formulas

HUD Diegetic 是纯渲染层,不持有业务公式。所有数值计算由上游 GDD own。

**D1 — 帧预算分摊估算**

本 GDD 分配 ≤ 2ms / 屏,推导自 `#6 Rule 3` 帧分摊表:

```
总帧预算: 16.6ms (60 FPS)
  - Save snapshot:       ≤ 4ms
  - Audio dispatch:      ≤ 1ms
  - Lighting switch:     < 1ms
  - Scene & Day Flow:    ≤ 1ms
  - HUD Diegetic:        ≤ 2ms  ← 本 GDD
  - Card Play UI (#14):  ≤ 2ms
  - 其余 UI + buffer:    ≤ 5.6ms
```

**D2 — 咖啡杯液位分段公式**

```
liquid_level_tier = clamp(floor(current_energy / 20.0), 0, 4)
  → tier 0: 空杯 (current_energy ∈ [0, 19])
  → tier 1: 1/4 杯 (current_energy ∈ [20, 39])
  → tier 2: 半杯 (current_energy ∈ [40, 59])
  → tier 3: 3/4 杯 (current_energy ∈ [60, 79])
  → tier 4: 满杯 (current_energy ∈ [80, 100])
```

边界值:`current_energy = 0` → tier 0(空杯 + burnout 渍斑 variant)。`current_energy = 100` → tier 4(满杯)。`max_energy` 动态变化时,tier 按 `(current / max × 100)` 归一化计算再分段。

---

## Section E — Edge Cases

### Cat 1: AP 显示边界

| Edge | 条件 | 处理 |
|------|------|------|
| E-1.1 | `current_ap = 0`(正常,无早退无加班) | 全 8 格划斜线;不触发任何 HUD 警告;打卡机 SFX 由 #4 Audio own |
| E-1.2 | `current_ap = 0` 且 overtime 激活(max_ap=10) | 10 格全划;第 9-10 格(浅灰底)也划斜线;无庆祝动画 |
| E-1.3 | `ap_early_leave_taken` 且 current_ap = 1 | 第 8 格折角 variant,7 格划斜线;不显示"省下了 1 格"文字 |
| E-1.4 | `ap_early_leave_taken` 且 current_ap = 2 | 第 7-8 格折角 variant,6 格划斜线 |
| E-1.5 | `max_ap_today = 10`(overtime 申报后)但立即早退 | 加班格(9-10)变为浅灰折角 variant(借来的+没花);不触发 effort_overtime_incremented 重复 |
| E-1.6 | `ap_changed` 信号在同帧多次 emit(race condition) | HUD 接收最后一次信号值;中间值丢弃(AtlasTexture 切换幂等) |

### Cat 2: NPC LEFT 视觉屏蔽

| Edge | 条件 | 处理 |
|------|------|------|
| E-2.1 **[RISK GUARD R-HUD-2]** | `npc_left_company` 后,HUD 收到该 NPC 的迟到 `relationship_changed` 信号(信号乱序) | **忽略**:检查 `#8.is_npc_active(npc_id) == false` → 不更新表情/站位,维持空椅 variant |
| E-2.2 | 多个 NPC 同月 LEFT(如 GRIND_KING + FISH_MONK 同月) | 各自独立处理 `npc_left_company`;工位区内两处空椅;GAMEOVER 时全 LEFT NPC 空椅可见 |
| E-2.3 | GAMEOVER sub-mode 时所有 NPC 站位 | `_apply_layout_for_mode(GAMEOVER)`:所有 ACTIVE NPC 切背对 variant;所有 LEFT NPC 维持空椅 |
| E-2.4 | NpcId.BOSS 离职(VS scope) | MVP 老板不 LEFT;若 LEFT 信号意外到达,同 E-2.1 处理 |

### Cat 3: 累积视觉同步

| Edge | 条件 | 处理 |
|------|------|------|
| E-3.1 | HUD LOADING 期收到 `accumulation_event` | LOADING 期静默丢弃(对齐 #5 Lighting Rule 2 LOADING 期语义);READY 后通过 init 查询 #5 重建 |
| E-3.2 | `accumulation_event.type = break_room_cracks` | HUD 忽略(Rule 7 — 茶水间裂缝在 HUD scope 外,#5 自渲染) |
| E-3.3 | `desk_stain_count > 52`(#5 schema cap 52) | HUD variant 使用 `clamp(new_value, 0, 4)` 已归一化,cap 不影响 |

### Cat 4: 帧预算超出

| Edge | 条件 | 处理 |
|------|------|------|
| E-4.1 **[RISK GUARD R-HUD-3]** | HUD 渲染单帧 > 2ms(Godot Performance Monitor 实测) | 1. 检查 NPC sprite 更新是否误入 `_process()`;2. 检查 `ap_changed` 信号频率;3. Profiler 定位热点;4. 降级:暂停 effort_hero/overage 的 HUD 响应(MVP 不渲染 effort 数值) |
| E-4.2 | 多信号同帧 burst(卡打出 → ap_changed + card_played + event_completed 同帧) | AtlasTexture 切换幂等 + 同帧最终值合并;最坏情况 3 个切换 ≈ 0.9ms,在预算内 |

### Cat 5: Sub-Mode 切换 Race

| Edge | 条件 | 处理 |
|------|------|------|
| E-5.1 | `scene_state_changed` 与 `ap_changed` 同帧到达 | Godot 信号队列顺序:scene_state 先处理(`_apply_layout_for_mode()`)→ ap_changed 后处理(`_update_sticky_notes()`)。最终结果正确 |
| E-5.2 | `KPI_REVIEW` 入场时,pending `kpi_threshold_changed` 信号未到 | 显示器维持前一 sub-mode 最后 variant;`KPI_REVIEW` layout 激活后若信号到达则更新;#16 接管全屏后本 GDD 显示器 variant 在背景中不可见 |
| E-5.3 | `GAMEOVER` sub-mode 锁后收到任何业务信号 | `settlement_locked = true`(#9 Rule 9)期间,HUD 忽略所有 `ap_changed` / `relationship_changed` 信号(通过 `if _locked: return` 守门) |

### Cat 6: 主语翻转 Lint

| Edge | 条件 | 处理 |
|------|------|------|
| E-6.1 **[RISK GUARD R-HUD-1]** | `HUD.*` namespace Localization key 出现"你的行动力 / 你的 AP / 你的精力"语义 | `subject_inversion_lint.py --domain AP,ENERGY,NPC,EVENT` CI 阶段 FAIL;不得 merge |
| E-6.2 | numeric_only flash overlay 文案使用玩家主语 | 同 E-6.1;flash overlay key 必须通过 `_BUREAUCRATIC` 后缀 + `context_type` 审查 |
| E-6.3 | NPC 表情变更时意外触发 toast 文字"好感度↑" | PR-blocking;HUD 不持有任何 toast 实现;若下游 #14 UI 误触发,本 GDD 信号接收器禁止 emit 任何 UI 信号 |

---

## Section F — Dependencies

### Upstream 依赖(HUD 订阅)

| # | 系统 | 信号 / API | 数据流方向 | 契约版本 |
|---|------|---------|----------|---------|
| #3 | Localization Hooks | `tr()` 调用 + `_IRONY` 后缀 lint | → HUD | Rule 1/11 |
| #5 | Lighting & Visual State | `accumulation_event(type, new_value)` | → HUD | Rule 5 |
| #6 | Scene & Day Flow Controller | `scene_state_changed(old, new)` | → HUD | Rule 3 + 8 sub-mode enum |
| #7 | AP Economy System | 7 信号(ap_changed/energy_changed/ap_depleted/ap_early_leave_taken/effort_*_incremented×3) | → HUD | Rule 2/4/5/6 |
| #8 | NPC Relationship System | `relationship_changed` + `npc_left_company` | → HUD | Rule 5/7 + I-3 |
| #9 | KPI & Reverse Threshold | `kpi_threshold_changed(old,new,delta_pct,breakdown)` | → HUD | Rule 13 |
| #10 | Event Script Engine | `event_completed(event_id, density)` | → HUD | Rule 5 |
| #11 | Action Card System | `card_played(card_id, ap_cost)` | → HUD | card_played 信号 |

### Downstream 依赖(HUD 提供接口)

| # | 系统 | HUD 提供 | 契约 |
|---|------|---------|------|
| #20 | Accessibility Options | diegetic 元素可 focus + screen reader alt-text 接口(Alpha tier) | `get_hud_element_description(element_id): String` |

### 双向一致性验证

- **#6 → HUD**: `#6 Rule 3` 帧预算分摊表含 HUD ≤ 2ms。本 GDD Rule 9 + D1 对齐。✓
- **#7 → HUD**: `#7 Rule 2` `ap_changed(current, max)` + Rule 5 `ap_depleted()` + Rule 4 `ap_early_leave_taken()` + Rule 6 3 `effort_*` 信号。本 GDD Rule 11 全订阅。✓
- **#8 → HUD**: `#8 Rule 5` `relationship_changed` + Rule 7 `npc_left_company`。HUD I-3 全订阅 + R-NPC-2 守门。✓
- **#9 → HUD**: `#9 Rule 13` `kpi_threshold_changed` 信号。本 GDD Rule 6 + I-4。✓
- **#5 → HUD**: `#5 Rule 5` `accumulation_event` 信号。本 GDD Rule 7 + I-5。✓
- **#3 → HUD**: `#3 Rule 11` `_IRONY` lint 扩展至 AP/ENERGY/NPC/EVENT keys。本 GDD Rule 10 + E-6.x。✓
- **HUD → #20 Accessibility**: Alpha tier;接口预留但不实现(MVP scope)。

---

## Section G — Tuning Knobs

### G1 — Diegetic 元素位置 Knobs(feel 类)

| 元素 | Knob 名 | 类型 | MVP 默认 | 范围 | 调节场景 |
|------|---------|------|---------|------|---------|
| `HUD_STICKY_NOTES` | `sticky_note_origin_offset` | feel | `Vector2(12, 8)` px | ±4 px | 布局微调;受美术交付座位 sprite 影响 |
| `HUD_COFFEE_CUP` | `coffee_cup_anchor_offset` | feel | `Vector2(-6, 4)` px | ±3 px | 同上 |
| NPC Phase tween | `npc_expression_phase_tween_duration` | feel | `0.2s` | [0.1, 0.4] s | Phase 变化时 sprite 过渡感;>0.4s 感觉迟钝 |
| flash overlay | `flash_overlay_duration_ms` | gate | `1500 ms` | [800, 2000] ms | numeric_only 档显示时长 |
| 咖啡杯液位分段 | `coffee_liquid_tiers` | curve | `5` | [4, 6] | 影响美术资产数量 |

### G2 — Sub-Mode 视觉变体表(curve 类)

8 sub-mode 的 diegetic 元素激活配置表存于 `assets/data/hud_layout_config.tres`(GodotResource),**禁 hardcode**。每次 `scene_state_changed` 时 HUD Controller 读取此表。

### G3 — 帧预算分摊(gate 类)

| 分项 | 预算 | Knob 名 | 范围 |
|------|------|---------|------|
| HUD 总帧预算 | ≤ 2ms | `hud_frame_budget_ms` | [1.5, 2.5] ms —— 超出 2.5ms 为 R-HUD-3 触发阈值 |
| NPC sprite tween | `npc_phase_tween_duration` | 0.2s | [0.1, 0.4] s |

---

## Visual/Audio + UI Requirements

### Visual 需求

本 GDD 是 art-bible §7.1 diegetic UI 的**主要 own 者**。所有 diegetic 元素视觉 sprite 必须由美术资产管线(art-director / 角色管线)按以下规范交付:

**资产清单(MVP)**:

| 元素 | 规格 | 命名规范 | Owner |
|------|------|---------|-------|
| 便利贴 atlas | 11 帧(空/斜线/加班浅灰/折角各 variant) | `hud_sticky_notes_atlas.png` | art-director |
| 咖啡杯 atlas | 5 液位 × 2(正常/burnout 渍斑) = 10 帧 | `hud_coffee_cup_atlas.png` | art-director |
| 显示屏数据表格 | 5 variant(`_normal/_warn/_over/_flash/_gray`) | `hud_monitor_data_{variant}.png` | art-director |
| 考勤表/日历 | 8 sub-mode variant × 31 日历格 | `hud_attendance_{mode}.png` | art-director |
| NPC 表情 atlas | 4 Phase × 8 NpcId = 32 帧 | `npc_{npc_id}_expression_{phase}.png` | 角色管线 |
| NPC 站位 atlas | 4 Position × 8 NpcId = 32 帧 | `npc_{npc_id}_pos_{phase}.png` | 角色管线 |
| 空椅 sprite | 1 帧(静态) | `hud_empty_chair.png` | art-director |

**📌 Asset Spec Flag**: 美术资产详细规格(px 尺寸/atlas 布局/色值约束)由 `/asset-spec system:hud-diegetic` 在 Phase 3 美术生产前产出。

**art-bible §7.1 视觉红线**:
- 所有 diegetic 元素遵循 art-bible §3.3 UI 形状语法(0 圆角/1px 边框/表格语义)
- 便利贴色值 `#E8E0CC`(白炽灯白),斜线 `#2A1F14`(咖啡渍棕黑)
- 加班格底色 `#BBBBBB`(明显区分,但不高亮/不特殊色)

### Audio 需求

HUD Diegetic **不持有任何 Audio 资产**。视觉状态切换无独立音效。

- 便利贴划去:无 SFX(对齐 AP Economy Section B "反英雄红线 — 花 AP 没有光效")
- NPC Phase 变化:无 SFX
- KPI 预警显示器 variant:无独立 SFX
- GAMEOVER sub-mode 的 stinger 由 #4 Audio Manager Rule 4 own

### UI 需求

本 GDD 是 art-bible §7.1 diegetic UI 的**主要 UI screen owner**。但:

- **本 GDD 不 own 任何 screen-space UI 屏**(无专属 UI 屏)
- 所有 HUD 元素内嵌于工位场景(单 GodotScene,非独立 CanvasLayer UI 屏)
- gamepad 焦点链:D-Pad 导航在工位场景内可 focus 到各 diegetic 元素(需 `FocusMode = All` 配置,由 #2 Input Handler own `act_focus_*` 信号驱动)
- **📌 UX Flag**: `/ux-design design/ux/hud-diegetic.md` 需在 Phase 4 跑,详细规划 diegetic 元素 gamepad 焦点链 + screen reader 可访问性契约(对接 #20 Accessibility)

---

## Open Questions

**OQ-HUD-01**: `HUD_STICKY_NOTES` / `HUD_COFFEE_CUP` / `HUD_MONITOR_DATA` 等 sprite 的具体像素尺寸 + atlas 布局由美术资产管线决定 —— 需 `/asset-spec system:hud-diegetic` 产出,**阻塞美术生产启动**。目标:Phase 3 美术生产前锁定。

**OQ-HUD-02**: HUD Diegetic 帧预算 2ms 估算需 Godot 4.6 实测验证。实测时机:第一个可运行 prototype build 产出后跑 `Profiler.measure_frame_time("HUD")`,若超出则触发 R-HUD-3 降级方案。

**OQ-HUD-03**: 累积视觉 `accumulation_event` 与 #5 Lighting 的集成时序 —— #5 发出信号时序是否保证 READY 后同帧,还是需要 defer。待 #5 Lighting GDD review 时确认。

**OQ-HUD-04**: 主语翻转 lint `--domain AP,ENERGY,NPC,EVENT` 完整 key 白名单/黑名单 —— 需 Localization lead + writer 联合产出作为 CI script 输入。目标:第一个包含 HUD 文案的 sprint 结束前交付。

**OQ-HUD-05**: NPC 表情 atlas 中,`BOSS` / `HR` NPC 是否在 MVP 阶段全量交付 4 Phase 表情,还是只交付 NEUTRAL + HOSTILE?scope 确认由 art-director + producer 联合决策(影响资产数量 32 帧 vs 更少)。

**OQ-HUD-06**: `numeric_only` 档 flash overlay 的 Localization key 范围 —— 哪些 `event_completed` 触发 overlay,哪些静默?规则由 #10 Event Script Engine GDD owner 确定并回传契约给本 GDD。

**OQ-HUD-07**: gamepad D-Pad 焦点链在 diegetic 场景内的具体 Focus Order —— 8 diegetic 元素 D-Pad 导航顺序(左→右/上→下/环形?)由 #2 Input Handler + #20 Accessibility 联合决定。Phase 4 `/ux-design` 时产出。

**OQ-HUD-08**: 野心版"diegetic 物理交互"(便利贴可拖动)是否需要独立 GDD revision?预计 VS/野心版 kickoff 时决定(scope expansion ADR)。

---

## Section H — Acceptance Criteria

### ADR-0001 跟进追加(B-DEP-2 守门)— 2026-04-28

**AC-FAREWELL-01**(`#10 Rule 23` FAREWELL_EVENT_IDS 守门契约): **GIVEN** HUD READY,debug 钩子拦截 `HUD_*_FLASH_OVERLAY` 节点 `visible = true` 赋值, **WHEN** `event_started(event_id, narrative_tier)` 信号到达且 `event_id ∈ EventScriptEngine.FAREWELL_EVENT_IDS`(LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF / GRIND_KING_PROMOTED_LEAVE / OLD_OIL_OPTIMIZED_OUT), **THEN** 全部 flash overlay 节点 `visible = false`;仅 `HUD_NPC_EXPRESSION` / `HUD_NPC_POSITION` 切 LEFT variant + 后续 `HUD_EMPTY_CHAIR`(per Rule 1 + R-NPC-2 已守);`tools/farewell_lint.gd` PR 阶段比对 `#10 FAREWELL_EVENT_IDS` 与本 GDD AC 引用一致 → 不一致 BLOCK PR。**Tier**: MVP。

### AC-FUNC: 功能验收(12 AC)

| ID | Given | When | Then | Tier |
|----|-------|------|------|------|
| AC-FUNC-01 | HUD READY 且 `ACTION_DAY` sub-mode 激活 | `ap_changed(5, 8)` 信号到达 | `HUD_STICKY_NOTES` 显示 3 格斜线 + 5 格空白;无数字浮层 | MVP |
| AC-FUNC-02 | HUD READY 且加班申报成功 | `ap_changed(2, 10)` 信号到达 | 前 8 格中 8 格斜线;第 9-10 格浅灰底显示;无庆祝动画 | MVP |
| AC-FUNC-03 | HUD READY | `ap_early_leave_taken()` + `ap_changed(2, 8)` 到达 | 第 7-8 格折角 variant;6 格斜线;无"提早离开"文字 | MVP |
| AC-FUNC-04 | HUD READY 且 `energy_changed(0, 100)` | 咖啡杯渲染 | 空杯 variant + 干渍底(`#2A1F14`);无"精力耗尽"警告文字 | MVP |
| AC-FUNC-05 | LISA relationship_score = -40(HOSTILE Phase) | 工位场景渲染 | Lisa NPC 站位 = 背对;表情 = 冷漠;无"好感度 -X" toast | MVP |
| AC-FUNC-06 **[R-NPC-2]** | `npc_left_company(LISA, "quit")` 信号到达 | HUD 渲染 | Lisa 工位显示 `HUD_EMPTY_CHAIR` variant;Lisa 表情/站位 sprite 消失;`relationship_score` 数字不可见 | MVP |
| AC-FUNC-07 | `kpi_threshold_changed` 使 breakdown.capacity_now < monthly_threshold | 显示器渲染 | `HUD_MONITOR_DATA` 切红框超标 variant;无"KPI 超标" toast / 屏幕叠层 | MVP |
| AC-FUNC-08 | `event_completed(evt_id, density=NUMERIC_ONLY)` 到达 | HUD 渲染 | `HUD_MONITOR_DATA` 区域内单行小字 flash overlay;1.5s 后消失;key 符合 `_BUREAUCRATIC` 后缀 | MVP |
| AC-FUNC-09 | `accumulation_event(type="desk_stain_count", new_value=3)` 到达 | HUD 渲染 | `HUD_COFFEE_CUP` 杯外渍斑密度为 tier-3 variant;无 `desk_stain_count` 数字显示 | MVP |
| AC-FUNC-10 | `GAMEOVER` sub-mode 激活 | `_apply_layout_for_mode(GAMEOVER)` | 便利贴/咖啡杯/显示器隐藏;所有 ACTIVE NPC 背对 variant;所有 LEFT NPC 空椅可见 | MVP |
| AC-FUNC-11 | HUD LOADING 期收到 `accumulation_event` | 信号到达时 | 静默丢弃;READY 后通过初始化查询 #5 重建;无 push_error | MVP |
| AC-FUNC-12 | READY 后初始化序列 | HUD 进入 READY | 查询 #6/#7/#8/#9/#5 重建全部 diegetic 元素状态;≤ 5 个 API 查询完成;无可见闪烁 | MVP |

### AC-PERF: 性能验收(4 AC)

| ID | Given | When | Then | Tier |
|----|-------|------|------|------|
| AC-PERF-01 **[R-HUD-3]** | Godot 4.6 Profiler,60 FPS 稳定 | HUD 在 `ACTION_DAY` sub-mode 标准信号流(4 张卡/天) | HUD 渲染分项 ≤ 2ms / 帧;p95 ≤ 2ms | MVP |
| AC-PERF-02 | 8 NPC 同帧 `relationship_changed`(最坏 case) | 8 信号同帧到达 | HUD 完成 8 NPC sprite 更新;总耗时 ≤ 0.5ms;帧不 drop | MVP |
| AC-PERF-03 | sub-mode 切换(AFTER_WORK → DAILY_RECAP) | `scene_state_changed` 到达 | `_apply_layout_for_mode()` ≤ 0.5ms;当帧无 GC spike | MVP |
| AC-PERF-04 | 60 天(2 月)连续运行 | 无 HUD memory leak 检查 | 无内存泄漏;每次 flash overlay 正确 `queue_free()` | Beta |

### AC-COMPAT: 兼容性验收(3 AC)

| ID | Given | When | Then | Tier |
|----|-------|------|------|------|
| AC-COMPAT-01 | Keyboard/Mouse 主输入模式 | 工位场景渲染 | 所有 diegetic 元素正确渲染(MVP 无交互,仅视觉展示) | MVP |
| AC-COMPAT-02 | Gamepad 输入模式 | D-Pad 导航 | diegetic 元素获得焦点态;无 hover-only 交互;by Input Rule `act_focus_*` | Beta |
| AC-COMPAT-03 | Localization `zh_CN` 切换到 `en`(野心版) | HUD 重建 | flash overlay 单行文字不溢出 `HUD_MONITOR_DATA` 区域 | 野心版 |

### AC-ROBUST: 鲁棒性验收(3 AC — RISK GUARD)

| ID | Given | When | Then | Tier |
|----|-------|------|------|------|
| AC-ROBUST-01 **[R-HUD-1]** | CI lint `subject_inversion_lint.py --domain AP,ENERGY,NPC,EVENT` | 针对 `HUD.*` namespace Localization keys | 无"你的行动力/你的 AP/你的精力/友好度"主语;违反 → CI FAIL,不得 merge | MVP |
| AC-ROBUST-02 **[R-HUD-2]** | `npc_left_company(LISA, ...)` 后迟到 `relationship_changed(LISA, ...)` | 乱序信号到达 | HUD 检查 `is_npc_active(LISA) == false` → 忽略信号;Lisa `relationship_score` 数字不在任何 HUD 元素可见 | MVP |
| AC-ROBUST-03 **[R-HUD-3]** | Godot Profiler 实测 HUD 标准流 | 60 FPS 运行 | HUD 分项 ≤ 2ms p95;超出时 `push_error("HUD frame budget exceeded: {actual}ms")` + 降级停止 effort_hero/overage 信号响应 | MVP |

---

*End of hud-diegetic.md — 11 sections 全填,0 placeholder*
