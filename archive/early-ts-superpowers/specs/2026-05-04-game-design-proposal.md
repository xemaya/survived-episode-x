# 《活过第 X 集》— 总体策划方案（详细版）

**日期**：2026-05-04
**版本**：v1.0（综合）
**对应**：MVP（3 月）→ Vertical Slice（5-6 月）→ Full Game（9-12 月）
**引擎**：TS + PixiJS + Tauri（2026-05 切换；前期设计基于 Godot 4.6，公式与系统抽象与引擎无关）

> **本文是单文档总览。**
> - 系统级细节见 `design/gdd/<system>.md`（20 份 GDD）
> - 数学推导见 `design/research/`（KPI 反向阈值公式、AP 决策空间分析、事件 schema 提案）
> - 架构红线见 `architecture/architecture.md` + `architecture/control-manifest.md` + `architecture/adr-0001..0017.md`
> - 美术锚见 `assets/sprites/STYLE_GUIDE.md`

---

## 1. 项目定位

### 1.1 一句话

**像素风反向 KPI 中国办公室生存模拟。** 玩家扮演老油条，每天 8 个行动点（AP）在"被开除"和"太优秀下关被涨 KPI"之间走钢丝；胜利条件不是升职，是**活过第 X 集**。

### 1.2 类型与基础参数

| 维度 | 取值 |
|---|---|
| 类型 | 模拟经营 / 叙事 Roguelite / 黑色幽默职场生存 |
| 平台 | PC（Steam）主，移动端 / Switch 后续扩展 |
| 受众 | 25-40 岁中国白领（核心）+ 海外"东亚职场猎奇"受众 |
| 玩家数 | 单人 |
| 单局时长 | 5-15 分钟为单位（地铁 / 摸鱼 / 睡前友好） |
| 计费 | 买断制，$8-12 价格带 |
| 内容规模 | MVP 3 月 ≈ 30-40 卡 / 80-120 事件 / 8-10 NPC / 1 结局 |

### 1.3 灵感锚

| 标杆 | 取自什么 | 我们做不一样的 |
|---|---|---|
| 《大多数》 | 中国底层生活的真实质感 | 白领 vs 蓝领；反向 KPI 取代正向励志 |
| 《死亡与税收》 | 公务员讽刺 + 决策颗粒度 | 完整 NPC 关系网 + 围棋式布局 |
| 《Papers, Please》 | 讽刺性打工模拟 + 压抑 tone | 中文语境 + roguelite 多周目 + 黑色幽默而非沉重 |
| 《中国式家长》 | 中文文化模拟 + 像素风 + 叙事驱动 | 单一职场场景聚焦、session 更短更密 |
| 《破事精英》 | tone + 受众 + 职场解构视角完全一致 | 互动游戏 vs 被动观看 |

---

## 2. 玩家画像与情绪体验

### 2.1 目标玩家

| 属性 | 描述 |
|---|---|
| 年龄 | 25-40 岁 |
| 游戏经验 | Casual 到 Mid-core；低反应、愿意读文本 |
| 时间窗口 | 工作日睡前 15-30 分钟 / 地铁 5-10 分钟 / 周末 1-2 小时 |
| 平台偏好 | PC（Steam）主战场 + 手机端二级 |
| 已玩游戏 | 《大多数》《中国式家长》《戴森球计划》《了不起的修仙模拟器》《Stray》 |
| 寻找的体验 | 把真实无奈"反向扮演"的出口；不烧脑但能会心一笑；可随时玩可随时放下 |
| 会赶走的内容 | 1) 要求"努力变优秀" 2) 励志正能量 3) 反应类操作 4) 高频联机 5) 付费解锁关键内容 |

### 2.2 MDA 美学优先级

| Aesthetic | 优先级 | 兑现方式 |
|---|---|---|
| Discovery（发现） | **1** | 每局解锁新 NPC / 事件 / 卡；剧情暗线；看穿系统的 aha 时刻 |
| Narrative（叙事） | **2** | 每张行动卡 = 小剧本；8-10 NPC 有人物弧；黑色幽默 tone |
| Challenge（挑战） | **3** | 反向 KPI 博弈、围棋式布局感；挑战是"活多久" |
| Submission（仪式 / 放松） | **4** | 每日打卡的节奏感；5 分钟地铁可玩；不烫手 |
| Fantasy（代入） | **5** | 扮演清醒的老油条，一个特定文化下的集体原型 |
| Sensation（感官愉悦） | 6 | 像素美术 + 环境音支撑但不是卖点 |
| Expression（表达） | 7 | 有但不核心 ——个人化"摸鱼风格" |
| Fellowship（社交） | N/A | **Anti-pillar**，明确排除 |

### 2.3 SDT 心理需求满足

- **Autonomy（自主）**：每天 8 AP 怎么花、早退还是加班、和哪个同事结盟 ——玩家做主
- **Competence（胜任）**：渐进的"看穿系统" mastery：识别工龄惩罚、解锁剧情分支、优化反向 KPI 策略
- **Relatedness（联系）**：单机但 NPC 关系浓厚 ——Lisa、老板、清洁阿姨都是有血有肉的人物（**最关键的差异化维度**）

### 2.4 Bartle 玩家类型对位

- ✅ **Explorers** ——解锁内容 + 发现隐藏机制 + 看穿系统
- ✅ **Socializers** ——单机 NPC 关系网（《Disco Elysium》/《大多数》式）
- ⚠️ **Achievers** —— "活过多少集"分数有但非主要驱动
- ❌ **Killers/Competitors** —— 明确不服务

---

## 3. 五大游戏支柱（Pillars）

每条支柱都自带 **Design test**——任何设计提案过不去就不通过。

### 3.1 Pillar 1：平庸是一种艺术

游戏奖励"维持平庸"，惩罚任何偏离舒适区的表现。**奖励曲线必须是倒 U 型。**

> **Design test**：如果一个新功能奖励玩家"变得更优秀 / 更强 / 更努力"，重新设计它 ——加班的物质回报必须绑定下关 KPI 涨幅。

**架构红线（Anti-Pillar 1 lint）**：AP cap 8 固定 / `monthly_threshold` 单调上调 / `capacity_factor(m)` 单调下降；任何反向单调的 effect / event / unlock / setting 在 CI 中 `push_error` 失败。详见 `subject_inversion_lint.py`。

### 3.2 Pillar 2：叙事即机制

每个数值变化都包裹在小剧本里，没有孤立的数字。NPC 是有血有肉的，不是数据点。

> **Design test**：设计一张新行动卡之前，先写那张卡的剧本。**没剧本就没卡。** 任何 UI 反馈都要有文本同步——"Lisa 关系 -2"必须伴随一句她的对白或动作描述。

### 3.3 Pillar 3：死亡是注定的

GAME OVER 不是失败，是剧终。玩家玩的是"活多长"，不是"能不能赢"。**永远不会有"游戏通关"。**

> **Design test**：永远不要让玩家以为能赢到底。月末 KPI 达标必须让下月更难，不是更简单。任何让玩家"稳赢"的路径都是 bug。

### 3.4 Pillar 4：苦中作乐（黑色幽默优先）

基调是黑色幽默 ——失败是段子、PUA 话术被解构、结构性痛苦被调侃但不说教。

> **Design test**：所有文本先过"朋友圈测试"——一个真正的职场人会不会转发这段话？不会就重写。**不要煽情，不要正能量，不要励志。**

**架构红线（subject_inversion_lint，8 域）**：`EVENT/NPC/AP/KPI/EFFORT/TENURE/RECAP/TUTORIAL` 域内的字符串不能出现"你做到了 / 完美 / 战略 / 友谊"等真情励志 tone；HR 反讽用 `_IRONY` 后缀，"咱们公司 = 大家庭"等官话用 `_BUREAUCRATIC` 后缀显式白名单。

### 3.5 Pillar 5：地铁可玩性

5 秒进入、5 秒暂停 ——游戏服从玩家的时间表。

> **Design test**：任何新功能都要过"地铁测试"——能在地铁上玩 5 分钟然后放下吗？不能就砍掉或重新设计。**存档必须在任意行动点后都可行。**

### 3.6 Anti-Pillars（绝不做的事）

- ❌ **NOT 升职打怪**：拒绝角色数值变强曲线（违 Pillar 1）
- ❌ **NOT 励志叙事**：拒绝"努力就有回报"剧情线（违 Pillar 3）
- ❌ **NOT 反应 / 动作类操作**：没有 QTE、节奏、打击感（违 Pillar 5 + 围棋布局体验）
- ❌ **NOT 多人 / 联机 / 真人排行榜**：分散"孤独老油条"氛围聚焦
- ❌ **NOT 付费解锁内容**：所有内容游戏内解锁

---

## 4. 核心循环

### 4.1 时间尺度全景

```
微循环（1 AP ~ 30 秒）
  └─ 选行动卡 → 弹小剧本（3-5 秒文字 + 像素动画）→ 数值反馈 → 回到行动卡界面

每日（一天 ≈ 2-3 分钟）
  ├─ 早晨事件预告（1 张图 + 2 行字）
  ├─ 白天行动阶段（用 8 AP）
  ├─ 下班决策（早退 / 准点 / 加班）
  └─ 今日总结 + 明日预告

每周（5 工作日 + 周末，≈ 10-15 分钟）
  └─ 周一-周五 → 周五周报 → 周末（躺平 / 社交 / 跳过）

每月（4 周 = 一关）
  └─ 月末 KPI 考核 → 达标涨阈值 / 不达标 GAME OVER

一局（一次入职 → 开除）
  └─ 工龄惩罚使最终失守是数学必然 → "你的《职场》连续剧演完第 X 集"

跨局（多周目）
  └─ 解锁新 NPC / 事件 / 卡 / 结局 ——博物馆式收集
     ❗ 不解锁"角色变强"（违 Pillar 1）
```

**地铁套**：5 分钟 ≈ 2 天；15 分钟 ≈ 一周；玩家可在任意行动点后存档退出。

### 4.2 一天的微观体验

```
6:30 闹钟 (drowsy 状态)
  ↓
工位坐下 (8 AP，monitor_idle)
  ↓
早晨预告 ("老板今天出差" / "Lisa 项目 deadline")
  ↓
轮流打 4-8 张行动卡
  ├─ 每张卡 → 小剧本 → 数值反馈
  ├─ 监控 NPC 行为（卷王在加班、摆烂族在划水、HR 经过）
  ├─ AP 余量决定下班选项
  ↓
下班节点
  ├─ 早退（AP 剩 ≥3 → +1 精力，关系 ±）
  ├─ 准点（AP 用完 → 中性）
  └─ 加班（消耗精力 → 物质 + KPI 完成度，但拉高下关阈值）
  ↓
今日总结（数值变化 + 关键事件回顾）
  ↓
"明天预告" 一行
```

### 4.3 留存钩子

- **Curiosity（好奇）**：未解锁的 NPC / 事件 / 结局
- **Investment（投入）**：上局认识的 Lisa 在新一局有不同剧情线吗？
- **Mastery（精通）**：能不能活到第 24 集（2 年）？解锁"退休"结局？
- **Social（自传播）**：朋友圈 / 小红书分享典型事件截图 ——用户共创营销

---

## 5. 系统总览（20 个系统）

按 5 层架构组织。每个系统都有独立 GDD（`design/gdd/<slug>.md`）。

### 5.1 Foundation 层（5 系统，无外部依赖）

| # | 系统 | 一句话职责 | Priority |
|---|---|---|---|
| 1 | **Save System** | 全游戏唯一持久化接口，schema v1，autosave 50ms 软上限 | MVP |
| 2 | **Input Handler** | KB / Mouse / Gamepad 包装，12 actions，3 zone deadzone | MVP |
| 3 | **Localization Hooks** | 字符串 / 字体 / 多语言 hooks；CSV 5 列 schema；启动全量 <100ms | MVP |
| 4 | **Audio Manager** | 4 Bus 架构（Master 锁），preload <200ms，反讽音效红线 | MVP |
| 5 | **Lighting & Visual State** | CanvasModulate 8 sub-mode 色调；palette swap shader；累积环境 sprite state | MVP |

**架构红线（5 红线）**：
1. Pillar 4 anti-hero 文本 lint（`subject_inversion_lint.py`，8 域）
2. Anti-Pillar 1 monotonicity（AP cap / threshold / capacity 单调性）
3. Diegetic UI 锁（无浮空 HUD，所有信息嵌入工位道具）
4. `#6 Scene & Day Flow` 是 `scene_state_changed` 唯一发射器
5. 数据驱动 + 引擎 API 锁（13 named constants 在 `design/registry/entities.yaml`）

### 5.2 Core 层（4 系统，依赖 Foundation）

| # | 系统 | 一句话职责 | Priority |
|---|---|---|---|
| 6 | **Scene & Day Flow Controller** ⭐ | 游戏心跳 + 8 sub-mode 状态机，唯一 dispatch owner | MVP |
| 7 | **AP Economy System** | 每日 8 AP + 早退 / 加班规则 + capacity_factor 单调性 | MVP |
| 8 | **NPC Relationship System** | 8-10 NPC 好感度 + flag + 关系阈值触发事件 | MVP |
| 9 | **KPI & Reverse Threshold System** ⭐ | 周 / 月 / 季结算 + 三维度惩罚性涨阈值公式 | MVP |

⭐ = Bottleneck 系统（多系统依赖、高风险、早固化）。

### 5.3 Feature 层（4 系统）

| # | 系统 | 一句话职责 | Priority |
|---|---|---|---|
| 10 | **Event Script Engine** ⭐ | 数据驱动事件池 + 触发条件矩阵；80-120 事件 → 400+ | MVP |
| 11 | **Action Card System** | 30-40 张卡库 + 打出规则 → 100+ 卡（VS+） | MVP |
| 12 | **Run Meta System** | "活过第 X 集"分数 + 跨局 content-only unlock + Demo end | MVP |
| 18 | **Tutorial / Onboarding System** | 隐形 onboarding + Day 1-3 固定手牌 + M1 NPC 点评 | VS |

### 5.4 Presentation 层（6 系统）

| # | 系统 | 一句话职责 | Priority |
|---|---|---|---|
| 13 | **HUD（Diegetic）** | 信息融入工位道具（sticky / 咖啡 / 显示器 / 椅子 / NPC 位置） | MVP |
| 14 | **Card Play & Dialogue UI** | 行动卡选择 + 剧本对话渲染 | MVP |
| 15 | **Daily / Weekly Recap UI** | 日报 + 周报 + 月末倒数 2 周守门最小展示 1500ms | MVP |
| 16 | **KPI Review & Game Over UI** | 月末三行 breakdown 渲染 + 离职证明过渡屏 + Archive 列表 | MVP |
| 17 | **Main Menu / Pause / Settings UI** | 主菜单 + 暂停面板 + 设置子屏 | MVP |
| 19 | **Notification & Warning System** | 增强警告系统（diegetic 元素变体，非弹窗） | VS |

### 5.5 Polish 层（1 系统）

| # | 系统 | 一句话职责 | Priority |
|---|---|---|---|
| 20 | **Accessibility Options** | 字体 4 档 + 色盲 3 档 + 高对比度描边 + 静音双重编码 | Alpha |

### 5.6 系统依赖图（简化）

```
Foundation: Save, Input, Loc, Audio, Lighting
                    │
             Scene & Day Flow (#6) ⭐
              ┌─────┴─────┐
        AP Economy    KPI System ⭐
         (#7)            (#9)
              │             │
        Action Card ──── Event Script ⭐
         (#11)             (#10)
              │             │
       NPC Relationship ────┤
            (#8)            │
                            │
                  ┌─────────┴──────────┐
              Run Meta (#12)    Tutorial (#18, VS)
                            │
                Presentation 6 屏（#13-#17, #19）
                            │
              Accessibility (#20, Alpha)
```

**Action Card → Event Script** 是单向依赖（事件还可由时间流逝、关系阈值触发，无需知道卡），所以系统图无循环依赖。

---

## 6. 关键机制详解

### 6.1 AP 经济系统（#7）

**核心约束**：每日 8 AP 固定、早退奖励精力、加班奖励物质但推高下关 KPI。

**4 态状态机**：
- `AP_NORMAL`（≥1 AP）
- `AP_OVERTIME_AVAILABLE`（AP=0 且选择加班）
- `AP_OVERTIME_ACTIVE`（用加班 AP）
- `AP_DEPLETED`（强制下班）

**5 个公式**（`design/gdd/ap-economy-system.md` § F1-F5）：

| 公式 | 意义 |
|---|---|
| F1 加班 | `OT_AP_grant(stamina) = min(4, floor(stamina/25))`，加班 AP 上限受精力封顶 |
| F2 早退 | `early_leave_stamina_gain = (8 - AP_used) × 5` ；准点中性 |
| F3 capacity | `capacity_factor(m) = max(0.6, 1.0 - 0.04 × m)`，月度产能单调下降 |
| F4 effort | `effort = 0.45 × overtime_count + 0.20 × early_leave_count + 0.30 × ap_burned_idle` （Hero 等价加班漏洞修订） |
| F5 decision_space | `H(action_distribution) ≥ 1.5 bits/day` 决策熵下限（H1 验证） |

**Anti-Pillar 1 lint**：任何使 AP cap > 8 / capacity 单调上升的内容都 PR-blocking。

### 6.2 反向 KPI 系统（#9）⭐

**核心创意**：月末 KPI 达标后，下月按"努力 + 潜力 + 工龄"三维度**惩罚性**涨基准。

**三维度涨阈值公式**（`design/research/kpi-reverse-threshold-formula-proposal.md`）：

```
threshold(m+1) = threshold(m) × (1 + γ_effective)

γ_effective = γ_base × (
    α × effort_ratio_bucket(m) +
    β × potential_ratio_bucket(m) +
    δ × tenure_ratio_bucket(m)
)

其中:
  γ_base = 0.05  (基准涨幅 5%)
  α = 0.40 ; β = 0.35 ; δ = 0.25  (三维权重之和 = 1)
  ratio_bucket() : 4 档分位数离散化（25/50/75/100），防止数值漂移引发感知不连续
```

**月度 capacity 衰减**（Pillar 3 死亡是注定的的数学保证）：
```
monthly_capacity(m) = base_capacity × max(0.6, 1.0 - 0.04 × m)
```
12 月后 capacity 降到 60% 而 threshold 已上涨数倍 → 数学上必然失守。

**第一次月末玩家情绪是生死问题**：
- ✅ 笑（"哎下月你就惨了"老 NPC 点评 → 啊原来是这个梗）
- ❌ 骂（觉得被坑 → 永久流失玩家）

缓解：M1 月末必触发"老员工解释涨阈值"事件 + Tutorial #18 系统的 Day 1-3 隐形引导。

### 6.3 事件剧本引擎（#10）⭐

**数据驱动 schema**（`design/research/event-script-schema-proposal.md` + `addons/event_linter/`）：

```yaml
event_id: WTR_LISA_PROMOTION_HINT
domain: NPC_LISA  # 8 域之一
trigger:
  any_of:
    - relation: { npc: lisa, op: ">=", value: 60 }
    - flag: lisa_just_finished_big_project
weight: 30
cooldown_days: 7
text_keys:
  - WTR_LISA_PROMOTION_HINT_OPENING
  - WTR_LISA_PROMOTION_HINT_BRANCH_A
  - WTR_LISA_PROMOTION_HINT_BRANCH_B
choices:
  - label_key: WTR_LISA_PROMOTION_HINT_LABEL_LISTEN
    effects:
      - npc_relation: { npc: lisa, delta: +3 }
      - flag: lisa_promo_hinted_to_player
  - label_key: WTR_LISA_PROMOTION_HINT_LABEL_FAKE_BUSY
    effects:
      - npc_relation: { npc: lisa, delta: -2 }
```

**Lint 链**（PR-blocking）：
- `tools/event_schema_lint.py`：源真理
- `addons/event_linter/`：编辑器内 advisory
- 主语翻转 lint（Pillar 4 守门）：自动扫描所有 `text_key` 的语料

**MVP 内容规模**：30-40 关键事件**手写**，其余 ~80 事件**模板化**（变量注入：NPC 名 / 项目 / 数字）。

### 6.4 NPC 关系网（#8）

**8-10 个 NPC 原型**（`assets/sprites/STYLE_GUIDE.md` § 1.4）：

| 原型 | 关键剪影 | 玩家关系功能 |
|---|---|---|
| 卷王 Tryhard | spine +2px taller / eye bags 3px / single cold coffee | 关系 -2 触发"被举报加班"，+5 触发"卷王分享秘籍" |
| 摆烂族 Slacker | one shoulder dropped 4px / phone reflection on face | 关系 +5 触发"一起摸鱼"事件，-2 触发"被告状" |
| 谄媚族 Toady | oval face / chin pushed forward 2px / hands clasped | 高关系 = 老板情报源 |
| 新人 Rookie | narrow build / slightly long neck / bewildered | 弱关系；用作"教学触发"NPC |
| 老油条同行 Veteran | similar to player BUT rounder thermos / orange folder / slippers | 月末点评涨 KPI 机制的"导师" |
| 清洁阿姨 Cleaning Auntie | short-and-wide build / mop as third leg | 隐藏关系线（关怀她儿子 → +5 → 触发隐藏结局支线） |
| Boss | silhouette top +8px taller / hands clasped behind back / gold tie clip | 直接控制涨阈值倾向；零真实关系 |
| HR | level shoulders / folder under arm / **empty-frame glasses (no lenses!)** | 月末"潜力评估"会议 → 直接修改 β |
| 隔壁部门代表 | BLUE color scheme (#3a5a85) | 跨部门事件触发 |

**关系网影响事件触发概率 + 剧本分支**——这是 Pillar 2 "叙事即机制"的载体。

### 6.5 行动卡系统（#11）

**3 大卡类**（`design/gdd/action-card-system.md`）：
- **进攻卡**（Offense）——主动产出 KPI / 关系，但消耗 AP
- **防御卡**（Defense）——挡住老板 / HR 的 PUA、躲过审计
- **关系卡**（Relationship）——主动调整 NPC 关系

**卡 cost 分布**：1 AP 卡占 60%（决策密度），2 AP 卡占 30%，3 AP 卡占 10%（押注）。

**卡是事件触发器**：每张卡 cast 后**必须**触发 1 个 Event Script（无剧本就无卡，Pillar 2）。

### 6.6 Run Meta System（#12）

**唯一允许的跨局成长**：内容解锁，**不允许任何机械性变强**（Anti-Pillar 1 PR-blocking lint）。

**5 类白名单**（`design/gdd/run-meta-system.md`）：
- `codex` 词条
- `memo` 备忘录
- `npc` 新 NPC 解锁
- `event_branch` 新事件分支
- `ending` 结局

**Archive 200 cap**：所有跑过的 Run（"剧集"）保留最多 200 条，FIFO 驱逐。第 201 条触发 R-RM-2 守门。

**Demo end**：MVP 阶段第 3 月末自动触发 "Demo End → 预告完整版"。

---

## 7. 视觉与听觉

### 7.1 美术 vocabulary（每个 prompt 必带）

```
Style: SFC/16-bit pixel art, visible pixel grid, no anti-aliasing on outlines,
limited 16-color palette. NOT vector or smooth modern illustration.
Visual identity goal: "first glance recognition, second glance indictment"
— a familiar Chinese office aesthetic that quietly broadcasts dread.
Mood: dark humor / 喜丧美学 (funeral-as-festival).
```

### 7.2 严格调色板（6 锚色，必带 hex）

| 颜色 | hex | 用途 |
|---|---|---|
| 打工人黄 | `#C8A85A` | 皮肤高光、日光灯黄 |
| 格子间灰蓝 | `#5A7080` | 隔间墙、UI 底色（主导色）|
| 档案室棕 | `#7A5838` | 木材、强调色 |
| 白炽灯白 | `#E8E0CC` | 天花板、纸张、光池 |
| 屏幕蓝 | `#2C4A6E` | 显示器荧光、加班氛围 |
| 老板金 | `#E0B050` | **STRICT max 3% pixel coverage**，仅老板 / 权力元素 |

### 7.3 玩家锚（出现玩家时必带）

- 中年中国男性，late 30s，疲倦
- 黑色短发（无高光）
- 海军蓝商务西装，略皱
- 白衬衣，松开的红色领带
- **左手永远握着不锈钢保温杯**（3px 凸起轮廓 ——他的招牌剪影元素）
- 略微弓背，低重心（"已经在这待了很久"感）
- 颈挂工牌

### 7.4 Diegetic UI（信息融入场景，非屏幕角）

**架构红线 #3**：在 `ACTION_DAY / EVENT_ACTIVE / WEEKEND / MAIN_MENU` 时**禁止**屏幕空间浮空 HUD。

**信息载体清单**：
- AP 余量 → 咖啡杯刻度（满 / 三分之四 / 半 / 空）
- 月度 KPI 进度 → 显示器上的 KPI 仪表盘（idle / working / warning / critical 4 态）
- NPC 关系 → 工位上的便签 / 椅子是否被坐 / NPC 当前姿态
- 当前日 / 周 → 日历贴纸 + 月末越近便签越多
- 警告通知 → 便签纸震动、显示器闪红、灯管闪烁（**不是 popup**）

`CanvasLayer.visible = true` 仅在 `PAUSE / KPI_REVIEW / GAMEOVER / SETTINGS` 时允许。

### 7.5 喜丧美学（funeral-as-festival）

**1-3px 的小细节注入冷幽默**：
- 茶杯 1px 蒸汽
- 单独一只苍蝇 2px
- 谁的领带是直的（暗示性格）
- 时钟具体时间（深夜 23:47 / 准点 17:01 等）

### 7.6 音频架构（4 Bus + 反讽红线）

| Bus | 内容 | 体积上限 |
|---|---|---|
| Master | 总控（Master 锁，禁止旁路）| - |
| BGM | **仅月末 + GAME OVER + 主菜单**（白名单），其余场景**无 BGM** | 每曲 ≤120s loop |
| Ambient | 6 场景层：工位 / 茶水间 / 会议室 / 加班夜 / 月会 / 老板办公室 | 累计 30MB |
| SFX | 8 池 LRU + CRITICAL 豁免（如打卡机、KPI 跳变） | - |

**Pillar 4 反讽红线**（音频 anti-hero）：
- 8 个禁止类型 SFX：胜利号角、欢快铃声、励志钢琴起调、节日鼓点等
- 4 个禁止 BGM 切换类型（如"困境 → 励志"过渡）

详见 `design/gdd/audio-manager.md`。

---

## 8. UX 与可访问性

### 8.1 输入

- KB / Mouse / Gamepad 三种皆完整支持
- 12 actions：act_select / act_back / act_pause / act_focus_left/right/up/down / act_overtime_skip / act_recap_skip / act_settings_open
- 3 zone deadzone（防止漂移误触）
- Settings 防抖 500ms（`meta_settings_debounce_ms`）

### 8.2 教学（Tutorial #18，VS）

- Day 1-3 **固定手牌** ——隐形限制选择空间
- M1 月末 ——"老员工"NPC 点评 KPI 涨阈值机制（生死问题的缓解器）
- 隐形三原则：**不打断 / 不字幕 / 不指引箭头**

### 8.3 Accessibility（#20，Alpha）

- 字体 4 档（11px / 13px / 16px / 19px，禁用 10px 因 CJK 笔画粘连）
- 色盲 3 档 palette swap（保留 6 锚色的语义）
- 高对比度描边
- 输入辅助：长按 / hit extend / 误触保护
- 静音双重编码（视觉提示 ↔ 音频提示对偶）
- **Anti-P1 守门**：所有 a11y 选项**只让玩家看得清，不让玩家赢得更轻松**

---

## 9. 内容产出范围（Scope Tiers）

| Tier | 内容 | 功能 | 单人时长 |
|---|---|---|---|
| **MVP** | 1 部门 / 8 NPC / 3 月 / 30 卡 / 80-120 事件 / 1 结局 | 核心循环 + KPI 涨阈值 + Demo end | ~3 个月 |
| **Vertical Slice** | + 完整年（12 月）+ 周年庆 + 60 卡 / 200 事件 / 2-3 结局 | + Tutorial + Notification 增强 + Meta 进度雏形 | ~5-6 个月 |
| **Full Game** | + 跨局 meta 解锁完整 + 100+ 卡 / 400 事件 / 5-8 结局 + 第 2 公司类型 | + Accessibility 全套 + 完整内容解锁 | ~9-12 个月 |
| **野心版** | + 英文本地化 + Switch 移植 + 多公司类型（国企 / 大厂 / 外企）+ 可选语音 | 商业化完整 | 18+ 个月 |

**推荐路径**：MVP → 反馈 → VS → 反馈 → Full。一开始就瞄准 Full 的项目大概率烂尾。

### 9.1 MVP 必备列表

1. 8 AP 每日系统（含早退 / 加班的差异化反馈）
2. 每日 → 每周 → 每月 KPI 三层结算（含三维度涨阈值）
3. 8-10 个有刻画的 NPC，各 3-5 个关键事件
4. 30-40 张行动卡 + 80-120 事件（30-40 手写 + 其余模板化）
5. 1 个清晰的 GAME OVER 体验（"活过第 X 集"戏谑结算）
6. 1 个办公室场景（1 层 1 部门）
7. 关卡上限：3 个月（M3 月末自动 Demo end）

### 9.2 MVP **明确不做**

- 多部门 / 多办公室
- 周年庆事件（推到 VS）
- 多结局分支（MVP 仅 1 种 GAME OVER）
- 跨局 meta 解锁（推到 Full Game）
- 美术事件 CG
- 英文本地化
- 语音

---

## 10. 技术架构

### 10.1 5 层架构（自下而上）

```
Polish Layer
  └─ #20 Accessibility（设置注入器，非运行时层）

Presentation Layer (UI)
  ├─ #13 HUD (Diegetic)
  ├─ #14 Card Play & Dialogue UI
  ├─ #15 Recap UI
  ├─ #16 KPI Review / Game Over UI
  ├─ #17 Main Menu / Pause / Settings
  └─ #19 Notification & Warning

Feature Layer
  ├─ #10 Event Script Engine ⭐
  ├─ #11 Action Card
  ├─ #12 Run Meta
  └─ #18 Tutorial

Core Layer
  ├─ #6 Scene & Day Flow ⭐ (单一 dispatch owner)
  ├─ #7 AP Economy
  ├─ #8 NPC Relationship
  └─ #9 KPI & Reverse Threshold ⭐

Foundation Layer
  ├─ #1 Save
  ├─ #2 Input
  ├─ #3 Localization
  ├─ #4 Audio
  └─ #5 Lighting
```

### 10.2 Autoload 初始化顺序（固定）

```
SaveSystem
  → LocalizationHooks
  → AudioManager
  → LightingController
  → InputHandler
  → SceneDayFlowController  (last，必须最后初始化)
+ TutorialState (VS)
+ AccessibilitySettings (Alpha)
```

### 10.3 5 条架构红线（lint 链强制）

| # | 红线 | 工具 | 阻塞级别 |
|---|---|---|---|
| 1 | Pillar 4 anti-hero 文本 | `subject_inversion_lint.py` 8 域 | PR-blocking |
| 2 | Anti-Pillar 1 monotonicity | `monotonicity_lint`（AP cap / threshold / capacity）| CI fail |
| 3 | Diegetic UI 锁 | `canvas_layer_visibility_lint`（4 sub-mode 内禁浮空 HUD）| CI fail |
| 4 | `scene_state_changed` 单一 owner | `signal_ownership_lint` ADR-0001 | CI fail |
| 5 | 数据驱动 + 引擎 API 锁 | `entities.yaml` + Godot 4.6 Forbidden APIs 表 | CI fail |

### 10.4 Engine 选择（2026-05 切换记录）

- **2026-04**：原计划 Godot 4.6 / GDScript，相关 GDD 与公式都假设此栈
- **2026-05**：切到 **TS + PixiJS + Tauri**（详见 `docs/superpowers/specs/2026-05-03-engine-switch-design.md`）

引擎切换**不影响**：所有 GDD / 公式 / 美术规范 / 数据契约 ——这些是引擎无关的设计层。**只影响**：autoload 名称、`@export` 语法、信号 emitter 写法等具体引擎 API。

### 10.5 数据契约：`design/registry/entities.yaml`

13 个跨系统 named constants（**禁止内联硬编码**）：

| Constant | 值 | source / referenced_by |
|---|---|---|
| `archive_hard_cap_count` | 200 | Save / Run Meta / KPI Review UI |
| `kpi_review_intro_duration_ms` | 800 | KPI Review UI |
| `final_transition_duration_ms` | 1500 | Save / KPI Review UI / Recap UI / Input |
| `meta_settings_debounce_ms` | 500 | Save / Input / Loc / Audio |
| `audio_preload_budget_ms` | 200 | Audio |
| `audio_loading_watchdog_ms` | 10000 | Audio |
| `audio_bank_total_size_mb` | 30 | Audio / Art Bible |
| `bgm_loop_length_max_sec` | 120 | Audio |
| `lighting_loading_watchdog_ms` | 10000 | Lighting |
| `notice_board_max_entries` | 24 | Lighting / Art Bible |
| `locale_lock_watchdog_ms` | 30000 | Loc / Scene Flow |
| `autosave_perf_hard_ceiling_ms` | 50 | Save |
| `current_schema_version` | 1 | Save |

---

## 11. 开发节奏与产能估算

### 11.1 设计阶段（**已完成 19/20 GDD**）

- **Foundation 5 系统**：5 × S = 5 sessions
- **Core 4 系统**：1 S + 3 M = 7 sessions
- **Feature 4 系统**：1 S + 2 M + 1 L = 7 sessions
- **Presentation 6 系统**：1 S + 5 M = 11 sessions
- **Polish 1 系统**：1 M = 2 sessions
- **总设计 effort**：≈ **32 sessions**（实际产出 + review + revise = ~40-50 sessions）

每个 GDD 必须过 `/design-review`（lean 模式），有一致性 cross-review 跑两轮（2026-04-25 + 2026-04-29）。

### 11.2 实施阶段（MVP）

- **Foundation 5 系统**：5 × S = ~3-4 周
- **Core 4 系统**：1 S + 3 M = ~5-6 周
- **Feature 4 系统**：1 S + 2 M + 1 L = ~5-6 周
- **Presentation 6 屏**：1 S + 5 M = ~6-8 周
- **内容创作**：30-40 卡 / 80-120 事件 = ~4-6 周（与系统并行）
- **整合 + Demo End + Polish**：~2-3 周
- **MVP 总产能**：单人约 12-16 周（**3-4 个月**）

### 11.3 关键里程碑

```
M1: Foundation + Core 跑通 → "一天的循环"原型 (4 周)
M2: Feature 完整（卡 / 事件 / 关系）→ 真实玩法对外 alpha (8 周)
M3: Presentation 完整（HUD / Recap / KPI Review）→ MVP demo (12 周)
M4: 内容打满 + Polish + Demo End → MVP ship (16 周)
```

---

## 12. 主要风险与缓解

### 12.1 设计风险

| 风险 | 等级 | 缓解 |
|---|---|---|
| **反向 KPI 新手教学** | MED-HIGH | 前 2-3 天隐形引导 + M1 月末必触发"老员工解释涨阈值"事件 |
| **叙事 + 节奏平衡** | MED | 剧本三档（闪现 / 长 / 纯数值），玩家可调叙事密度 |
| **8 AP 沦为机械分配** | MED | /prototype 阶段验证决策熵 H ≥ 1.5 bits/day |

### 12.2 技术风险

| 风险 | 等级 | 缓解 |
|---|---|---|
| **事件系统架构** | LOW-MED | 数据驱动 schema 早期定型 + lint 链双轨（py + GDScript addon）|
| **像素美术产出量** | MED | MVP 只做默认立绘，文字补充情绪表达；NPC 9 原型提前一次出齐 |

### 12.3 市场风险

| 风险 | 等级 | 缓解 |
|---|---|---|
| **国内审查** | MED | Steam 国际区无虞；国内法务审查或准备温和版 |
| **Steam 关键词竞争** | LOW-MED | "反向 KPI"差异化 hook 独特，Steam SEO 上锚 |

### 12.4 范围风险

| 风险 | 等级 | 缓解 |
|---|---|---|
| **文本产出 + 黑色幽默稳定度** | **HIGH** | 30-40 关键事件手写，其余模板化；找 1-2 早期测试员审 tone；`subject_inversion_lint` 自动守 8 域文案 |

### 12.5 待验证的开放问题

1. **8 AP 分配是否有真决策感？** → /prototype 第一阶段
2. **叙事密度 vs 节奏是否能平衡？** → /prototype + playtest 中途跳文字率
3. **第一次月末被涨 KPI 时玩家情绪？** → 早期 playtest 重点观察 ——是笑还是骂，**生死问题**

---

## 13. 附录

### 13.1 5 NOT 边界（每个系统都列）

每个 GDD 的 Section A 都有：
- **5 NOT 边界**：本系统不做哪些事（避免越界）
- **5 NOT 红线**：违反就是 PR-blocking

### 13.2 Pillar 守护映射

| 系统 | 主 Pillar | 守 Pillar | Anti-Pillar 红线 |
|---|---|---|---|
| #7 AP Economy | P1 | P3, P5 | Anti-P1（AP cap > 8 / capacity 升）|
| #9 KPI & Reverse | P1, P3 | P4 | Anti-P1（threshold 降）|
| #10 Event Script | P2 | P4 | Anti-P2（无剧本卡）|
| #11 Action Card | P2 | P5 | Anti-P2（无剧本卡）|
| #12 Run Meta | P3 | P1, P4 | Anti-P1（机械变强）|
| #13 HUD Diegetic | P5 | P4 | Diegetic UI 锁 |
| #18 Tutorial | P2 | P4, P5 | Anti-P2（剧情线励志）|
| #20 Accessibility | P5 | P4 | Anti-P1（让玩家赢得更轻松）|

### 13.3 关键参考资料定位

- **创意核心**：`design/gdd/game-concept.md`
- **数学灵魂**：`design/research/kpi-reverse-threshold-formula-proposal.md` + `design/research/ap-decision-space-analysis.md`
- **架构红线**：`architecture/architecture.md` + `architecture/control-manifest.md` + `architecture/adr-0001..0017.md`
- **美术锚**：`assets/sprites/STYLE_GUIDE.md` + `design/art/art-bible.md`
- **数据契约**：`design/registry/entities.yaml` + `architecture/tr-registry.yaml`
- **20 系统 GDD**：`design/gdd/<system-slug>.md`（19 已 Designed，1 在 review）

---

## 一句话总结

**这不是表面讽刺，这是用游戏机制把"职场 PUA 结构"建模成了玩家每天都要对抗的系统。**目前市面上没有其他游戏用这种机制把主题内嵌到系统里 ——这是项目最坚硬的差异化。

**胜利条件不是升职加薪，是活过多少集。** 维持平庸是一种技术活。
