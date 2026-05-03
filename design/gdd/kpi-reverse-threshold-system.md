# KPI & Reverse Threshold System

> **Status**: Designed (pending review)
> **Author**: huanghaibin + creative-director (B 三层渐进披露弧 C1+C2+C3)+ systems-designer (C 16 Rules + D 7 Formulas + E 30 edges 主笔)+ economy-designer (8 失败模式 + 2 propagation flags 仲裁)+ qa-lead (H 30 AC)
> **Authoring autonomy mode**: v2 no-prompt(0 widget,4 specialist parallel)
> **Key arbitration**: propagation flag #1 采纳 effort 权重 0.45/0.20/0.30 + flag #2 锁 CAPACITY_FLOOR=0.4(MVP)/0(野心版)
> **Last Updated**: 2026-04-27
> **Layer**: Core | **Order**: #9 | **Size**: **L** | **Bottleneck**: ⭐
> **Implements Pillar**: P1 主(平庸是一种艺术 — 反向 KPI 数学引擎)+ P3 主(每月必走 GAME OVER 的数学保证)+ P4 守(月末结算 tone 黑色幽默,不是绝望也不是励志)+ Anti-Pillar 1 红线(NOT 升职打怪)+ Anti-Pillar 2 红线(NOT 励志叙事)

## Overview

**KPI & Reverse Threshold System** 是《活过第 X 集》的**反向 KPI 数学引擎** —— 玩家用力越多,下月 KPI 阈值涨得越快;工龄越长,产能天花板衰减越严重。最终 `threshold > capacity` 时数学上 GAME OVER。这是 Pillar 1(平庸是艺术)和 Pillar 3(死亡是注定的)**两 Pillar 同时主锚**的唯一系统。本 GDD owns 的不是"难度调整器",而是把"职场结构性荒诞"建模成数学:**不是玩家做错了什么,是系统就是这么转的**。

### 双重身份

**技术层**: KPI System owns 月末结算公式(Formula B 乘性复合) + capacity_factor 衰减模型 + GAME OVER 检测协议 + 涨幅三维度拆解 emit。订阅 `#7 monthly_effort_summary`(effort 输入)+ `#6 scene_state_changed(→KPI_REVIEW)`(月末触发);emit `kpi_threshold_changed(month, old, new, components)` / `game_over_triggered(reason)` / `kpi_prediction_hint(npc_hint_type)` 给下游。**自身不持有 UI / 不渲染**(由 `#16 KPI Review & Game Over UI` 显示;由 `#15 Recap UI` 周报展示)。

**叙事层**: 玩家月末感受到的不是"涨了 X%"的数字,是 HR 戏谑化口吻的三段评语 —— "积极性可嘉(+2%)/ 还有上升空间(+0%)/ 资深员工的责任(—)"。第 1 月新手保护让玩家"笑而不是骂"(γ_effective=0);第 2-3 月开始感受到"啊这游戏是反向的"顿悟瞬间;第 11 月左右标准玩家数学上 GAME OVER。**KPI 不是关卡 boss,是天气 — 月末像降温**(继承 Scene & Day Flow Section B 副锚)。

### Pillar 服务

- **P1 主 平庸是一种艺术**: Formula B 乘性公式让"努力 + 潜力 + 工龄"三维度互相强化 — 三条都占的玩家(用力过猛)第 8 月就挂,刚刚达标的标准玩家第 11 月才挂。**倒 U 数学上成立,过度优秀的惩罚比躺平更早到来**。
- **P3 主 死亡是注定的**: capacity_factor(m) = max(0.4, 3.0 - 0.05·m) 工龄衰减保证 `threshold` 终将超过 `capacity`,GAME OVER 是数学定理而非设计选择。**老员工必死**。
- **P4 守 苦中作乐黑色幽默**: 月末结算 UI **不是审判 boss 战**,是戏谑化 HR 报告。"积极性可嘉" / "还有上升空间" / "资深员工的责任" 三段评语,涨幅拆解透明可读(KPI research §8.1 锁)。GAME OVER tone 是反讽而非绝望("中规中矩的牺牲品" / "职场常青树")。
- **P2 守 叙事即机制**: 老 NPC 预言机制(月末倒数 2 天 emit `kpi_prediction_hint`)— "你这么拼,小心下个月 KPI 会给你好看",由 `#10 Event Script` 落地为茶水间台词。**机制自我解释,不需要 tutorial popup**。
- **Anti-Pillar 1 红线 NOT 升职打怪**: KPI 阈值**只升不降**;无任何路径让 `threshold` 反向降低 / `capacity` 反向恢复 / 工龄重置。
- **Anti-Pillar 2 红线 NOT 励志叙事**: 月末结算文案**禁**"再坚持一下" / "你能做到的"类正能量。

### 5 NOT 边界(scope creep 防护)

- **NOT** effort 计算(由 `#7 AP Economy F4` own 0.45/0.20/0.30 三维加权;`#9` 仅消费 `effort_potential` 输入)
- **NOT** UI 渲染(由 `#16 KPI Review & Game Over UI` own 月末结算屏 + `#15 Recap UI` own 周报)
- **NOT** Run Meta 跨局存储(由 `#12 Run Meta` own "活过第 X 集" 分数 + 历史 Run 列表)
- **NOT** 月末文案 / 戏谑化 HR 评语(由 `#10 Event Script Engine` + writer own;`#9` 仅 emit 三维度数值供文案绑定 key)
- **NOT** NPC 离职 / 关系数值(由 `#8 NPC` own;**`#9` 不消费 NPC score**,反向 KPI 与 NPC 系统通过 `#10` 事件间接交互)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 让 `threshold` 反向降低(违反 Anti-Pillar 1 + P3 — 阈值降低意味玩家可"修复")
- **NOT** 让 `capacity_factor` 反向恢复(违反 P3 — 工龄反向不可逆)
- **NOT** 让 `tenure` 重置 / 转岗清零(违反 Anti-Pillar 2 — "新生活"叙事违反主题)
- **NOT** 让 `effort_potential` 输入由 `#9` 自计算(违反 ownership 边界 + R-KPI-5)
- **NOT** 月末结算 UI 出现"挑战失败 / 再试一次 / 加油"语义(违反 P4 + Anti-P2)

### 6 数学约束(必须同时成立 — KPI research §1.2 C1-C6)

| ID | 形式化 | 守门含义 |
|---|--------|---------|
| C1 反向性 | `next(m+1) > actual(m)` 而非只 `> threshold(m)` | 玩家"超额做 200%" 不能囤积或买时间 |
| C2 倒 U | `d(next)/d(potential) > 0` 二阶非线性 | 过度优秀反噬斜率更陡 |
| C3 老员工必死 | `lim(m→∞) threshold(m) = +∞` 增速 > capacity | Pillar 3 数学保证 |
| C4 新手护期 | `threshold(m=2)/threshold(m=1) ≤ 1.05` | 第一次月末"笑而不是骂" |
| C5 可教学 | 涨阈值对玩家行为单调可解释 | 玩家可"看穿系统" |
| C6 产能天花板 | `capacity(m) < +∞`,~第 9-15 月 `threshold > capacity` | GAME OVER 节奏锚定 |

### Source 引用

`design/research/kpi-reverse-threshold-formula-proposal.md` 全文(§1-10)+ `game-concept.md` Pillar 1 / Pillar 3 / Pillar 4 + Anti-Pillar 1+2 + Core Mechanics §L82-88(三维度涨阈值机制)+ MVP Definition。`scene-day-flow-controller.md` Rule 10 月末触发 + Section A 8 sub-mode `KPI_REVIEW`。`ap-economy-system.md` F4 effort_potential 输入(propagation flag #1 待复审)+ Rule 12 capacity_factor(propagation flag #2 已锁 0.4)。`save-system.md` Rule 21 final_transition + Rule 22 archive。`npc-relationship-system.md` `#9` 不消费 NPC score 解耦。

## Player Fantasy

### 渐进披露弧设计原则

本 GDD 是**唯一两 Pillar 同时主锚**的系统(P1 + P3),单一锚句无法承载 *反向数学 + 死亡保证 + 戏谑 HR 口吻* 三重密度。**三层锚句对应反向 KPI 系统的三个时间尺度**:月末单点(C1)、玩家觉察拐点(C2)、Run 全周期勋章(C3)。三层在玩家 Run 内自然推进。

### 主锚 C1(新手期 M1-M2): "你完成了 102%,所以下个月给你 105"

**场景**:
第 1-2 月最后一个周五下午 17:58。打卡机吐出工资条,屏幕浮出月末结算面板。你刚刚以 102% 完成本月 KPI —— 下方一行小字静静浮现:"下月目标 105"。没有红色警告,只是 HR 系统温柔的、流程化的播报。

**Pillar 服务**:
- **P1 主**: 反向数学的 felt sense — 玩家用力(102%)→ 系统用更高目标(105)回应。Formula B 的 `(1+α·effort)×(1+β·potential)` 翻译成玩家能听懂的人话。**乘性公式从抽象数学变成情绪记忆**
- **P3 主**: 这个数字在月份累积下不可逆走向 capacity 衰减交叉点 — 玩家不会立刻意识到,但每月这一句话都在为最终 GAME OVER 蓄力
- **P4 守**: HR 口吻的"翻译"本身就是黑色幽默 — 温柔流程化语言包裹数学暴力

**跨 GDD negative space 联动**:
- **Audio** 月末打卡机不是胜利音 共振: 欢庆语义被音效拒绝 + 数字"+3 的轻描淡写感"
- **AP Economy** 8 格凑合用 闭环: 玩家 #7 决定"今天加班/今天摸鱼",月末 #9 给他翻译账单
- **Lighting** 再苟一天 共振: 这句话之后玩家关闭面板,场景过渡到下个月的周一 9:17

**❌ Tone 风险(必避)**:
- 卡夫卡式压抑(UI 排版太冷峻 / 字体太肃杀)— 失去 P4 戏谑维度,变成单纯绝望
- "+3" 差距未刻意强化轻描淡写感 — 玩家感受到威胁而非反讽

**✅ Tone 守护**:
- HR 口吻保持事务性轻盈 — 像绩效面谈模板,不像审判
- **关键测试**: 这句话朗读出来,玩家应该苦笑而非紧绷

### 主锚 C2(觉察拐点 M3-M5): "我加班了,他给我涨了"

**场景**:
第 3-5 月,玩家本月动用全部 8 格 AP + 3 次加班,KPI 完成 118%(potential 进入倒 U 高位)。月末面板浮出:下月阈值 +14.2%。**玩家盯着屏幕沉默 5 秒** — 这是他第一次真正理解"努力"和"惩罚"的关系。

**Pillar 服务**:
- **P1 主(最纯粹)**: "平庸是艺术"的反命题被玩家亲手验证。Formula B α=0.04 + β=0.18 潜力倒 U 在这一刻具象化:努力越多,潜力评估越高,惩罚越重
- **P3 主**: 玩家第一次主动觉察"capacity 即将不够" — GAME OVER 数学保证的认知拐点
- **P4 守**: 黑色幽默来自**玩家的自我反讽**,不是系统播报 — 更深层的 felt humor

**跨 GDD negative space 联动**:
- **Anti-Pillar 2 红线**死磕: 励志游戏奖励加班,本作惩罚加班
- **AP Economy** "用空了" 共振: 玩家 #7 把 AP 全花掉,#9 给他翻译"代价"
- **NPC** "同事都走了你还在" 共振: 加班的人留下,但留下的人下月更难 — 孤独 + 数学暴力的复合
- **Save** "下班打卡机" 共振: 加班那几天的打卡时间在存档里成为证据

**❌ Tone 风险(必避)**:
- 励志反转(玩家解读"应该摸鱼变成最优策略")— 触发 Anti-P1 反向陷阱
- "加班"承载文化包袱 — 叙事不克制变网络段子复读

**✅ Tone 守护**:
- 必须保持**摸鱼也会死**的数学保证(γ·tenure 工龄项独立于 effort)— P3 是 P1 的安全网
- 这句话应该**玩家自己说出来**,不是 NPC 或系统播报 — 通过 UI 引导玩家自己得出结论(对比表"上月你的努力 vs 下月的目标")
- **关键测试**: 玩家在 M3-M5 某月末必须自发产生这个想法,而非 M1 被告知 — 渐进 felt sense 不是 tutorial

### 主锚 C3(勋章期 M6+): "中规中矩的牺牲品"

**场景**:
第 8 月月末面板。玩家本月 KPI 99.3%(几乎踩线),capacity_factor 已衰减到 2.6。系统评语词条静静浮出:"**本月评语:中规中矩的牺牲品。组织感谢您的稳定贡献。**" 下方:"下月目标 +8.4%"。

**Pillar 服务**:
- **P1 主**: "中规中矩"直接命名"平庸是艺术" — 但"艺术"二字被 HR 系统稀释成"中规中矩"。Pillar 1 反讽在词条本身
- **P3 主**: "牺牲品"预告 GAME OVER — 但用 HR 口吻包装,玩家收到的是"评语"不是"判决"。P3 数学保证的语义提前披露
- **P4 守(最强)**: 评语词条系统化(类似 Run Meta 收集),每月一句,组成 30+ 词条的"HR 黑话词典",每条都是反英雄反讽

**跨 GDD negative space 联动(铁三角四轨 +1)**:
- **Localization** GAMEOVER.TITLE_IRONY "恭喜晋升" 形成**语义闭环**: 月末评语铺路,GAME OVER 收尾
- **Audio** 月末打卡机不是胜利音 共振: 词条浮出时配合"不是胜利音"
- **NPC** "同事都走了你还在" 共振: 词条作为玩家"留下来"的唯一勋章 — 讽刺感叠加
- **Run Meta `#12`**: 词条库可作为跨局收集物 — "我活过 11 集 + 我收集了 23 种 HR 评语" 双重 meta

**❌ Tone 风险(必避)**:
- 词条段子集化(网络梗 / 谐音梗)— 破坏"事务性 HR 口吻"
- "牺牲品"太直白突破"温柔的刀"边界 — 变系统嘲笑玩家而非玩家苦笑系统
- 30+ 月词条审美疲劳后期边际效用递减

**✅ Tone 守护**:
- 词条**保持 HR 文档语感** — 参考真实绩效面谈话术、年终评语模板,克制段子化
- 评语**永远描述性而非评判性**: "中规中矩的牺牲品" ✓ / "你太弱了" ✗ — 前者档案,后者攻击
- 词条触发逻辑挂钩 KPI 区间 + tenure + potential 三轴,**每条评语对应一种数学状态**,不是随机抽卡
- **关键测试**: 任意一条评语单独打印贴在工位上,同事看到会会心一笑而非感到压抑

### 三层渐进披露弧示意

| 时间 | 锚 | 玩家心理 | 数学触发 |
|------|---|---------|---------|
| M1-M2 | C1 "102→105" | "啊系统是反向的"(顿悟) | 新手保护 γ=0,涨幅 ≤ 3% |
| M3-M5 | C2 "我加班了他涨了" | "原来用力越多越难"(觉醒) | β·potential 倒 U 开始咬人 |
| M6+ | C3 "中规中矩的牺牲品" | "我成了活化石"(勋章) | capacity_factor 衰减明显 |
| M11 ± 1 | GAME OVER | "活过第 X 集"(自豪) | threshold > capacity 数学 |

### Internal Design Test: HR 口吻原则

每条月末结算文案 / 涨幅拆解 UI / 评语词条审校时,问一个问题:**"这是审判 boss 的语气,还是 HR 绩效面谈的语气?"**

- 如果文案让玩家觉得"系统在评判我 / 在威胁我"(主语 = 评判)→ 改写
- 如果文案让玩家觉得"系统在记录我 / 在登记在册"(主语 = 流程)→ 通过

**正例**: "组织感谢您的稳定贡献" / "积极性可嘉" / "鉴于您的优秀表现,组织决定..."(事务性,克制)
**反例**: "你做得不够好" / "再加把劲就能成功" / "你已超越 80% 的同事"(评判 / 励志 / 比较)

**Design test 原则源**: Scene & Day Flow 主语翻转 + AP Economy 反英雄红线 + NPC 算计原则 同源四轨;本 GDD 是 *戏谑 HR 口吻* 第四轨。

### 红线汇总

- 任何"再坚持一下" / "你能做到的" 类正能量文案 = **PR-blocking**(违反 Anti-P2)
- 任何"挑战失败 / 再试一次 / 加油" 类游戏化语义 = PR-blocking(违反 P4)
- 任何 threshold 反向降低 / capacity 反向恢复路径 = PR-blocking(违反 Anti-P1 + P3)
- 任何 tenure 重置 / 转岗清零路径 = PR-blocking(违反 Anti-P2 + P3)
- 任何评语词条出现网络梗 / 谐音梗 / 比较语义 = PR-blocking(违反 P4 HR 口吻原则)

### Source 引用

`creative-director` Section B consultation(2026-04-27)+ KPI research §8(新手体验设计)+ §6(新手保护期)+ Pillar 1/3/4 + Anti-Pillar 1+2 + 8 GDD Player Fantasy negative space 铁三角延续(铁三角扩为四轨 +1 = HR 评语词条库)。Internal Design Test 原则源自 Scene & Day Flow + AP Economy + NPC 三 GDD 同源四轨。

## Detailed Design

16 Core Rules + 7 Interactions。

### Core Rules

**Rule 1 — `monthly_threshold` 状态定义**
`monthly_threshold: int` 跨月持久化,初始 `KPI_BASE_MONTH_1 = 100`。每月 `KPI_REVIEW` 结算后由 F1 更新,`roundi()` 取整后覆写。Save 字段 `kpi_threshold`(Save Rule 6 snapshot)。**Pillar 1 红线**: 单调递增 — `monthly_threshold = max(monthly_threshold, F1_result_rounded)`,F1 输出 < 当前值时强制不下降。唯一写点: `_run_monthly_settlement()` 函数末尾。

**Rule 2 — 月末结算协议(`#6 Rule 10` 触发)**
订阅 `#6 scene_state_changed(→KPI_REVIEW)` 信号,序列:
1. `action_lockout_started` — 所有 AP 消耗请求拒(`#7 try_consume_ap` 守门)
2. `_collect_effort_summary()` — 取本月三维度 from `#7 monthly_effort_summary`(Rule 4)
3. `_run_monthly_settlement()` 执行 F1-F5 序列
4. emit `kpi_review_started` 给 `#16` + `#15`
5. emit `kpi_threshold_changed(old, new, delta_pct, breakdown)`
6. F4 GAME OVER 检测(Rule 9)

结算顺序不可乱(F2 依赖 F7 actual_kpi;F1 依赖 F2/F4/F6 全部就绪)。

**Rule 3 — effort 三维度输入(from `#7 monthly_effort_summary`)**
`#7` 月末 push:
```
monthly_effort_summary {
    n_ot: int [0,20], n_h: int [0,10], n_ov: int [0,10],
    effort_norm: float [0.0, 0.95]  # F4 预计算
}
```
`#9` 直接消费 `effort_norm`;F6 用 n_ot/n_h/n_ov 反推校验。1 帧内未到达触发 Edge 5.1 容错(fallback 0.5 + push_error)。

**Rule 4 — propagation flag #1 仲裁(已采纳)**
**采纳 `#7` 修订版 `0.45/0.20/0.30`,反驳 research 草稿 `0.40/0.35/0.25`**。理由:
- Hero 卡 0.35→0.20: 防 A2 最优卡闭包(10 张 Hero ≈ 12 加班等价,无精力代价 — 违反 research §5 #7)
- 超预期 0.25→0.30: 真实产出权重高于刷卡行为
- 加班 0.40→0.45: 加重反噬符合 Pillar 1
- 权重和 0.95(非 1.0): 留 0.05 野心版"叙事 effort"扩展余量

本 GDD 为权重契约 source of truth。`#7 ap-economy-system.md F4` 已使用 0.45/0.20/0.30,两 GDD 一致。

**Rule 5 — potential 计算 + clamp**
```
potential = clamp(
  (actual_kpi_m - monthly_threshold) / monthly_threshold,
  KPI_POTENTIAL_CLAMP_MIN = -0.15,
  KPI_POTENTIAL_CLAMP_MAX = +1.0
)
```
**特殊情况**: raw potential `< -0.15` → 不进 F1,直接 emit `dismissal_triggered(SEVERE_UNDERPERFORMANCE)` 给 `#10 Event Script` 触发开除剧本。`monthly_threshold` 不更新。

**Rule 6 — tenure + 新手保护(M1 γ_effective=0)**
```
tenure = month_index  # 第 1 月结算时 = 1
γ_effective = 0.0 if month_index == 1 else KPI_TENURE_WEIGHT
```
M1 工龄项 `(1 + 0×1) = 1.0` 消去,涨幅仅由 effort + potential 驱动。M2 起 γ=0.012 全启动。`KPI_NOVICE_PROTECTION_MONTHS = 1`(Tuning Knob)。

**Rule 7 — Formula B 应用(next_threshold)**
```
next_threshold = roundi(
  monthly_threshold
  × (1 + KPI_EFFORT_WEIGHT × effort_norm)      # α=0.04
  × (1 + KPI_POTENTIAL_WEIGHT × potential)      # β=0.18
  × (1 + γ_effective × month_index)             # γ=0.012, M1 γ=0
)
monthly_threshold = max(monthly_threshold, next_threshold)  # 单调守门
```
所有系数从 `config/kpi_balance.tres` 加载(coding-standards §3 数据驱动)。

**Rule 8 — capacity_factor(m) 计算 + CAPACITY_FLOOR 锁**
```
capacity_factor(m) = max(CAPACITY_FLOOR, BASE_CAPACITY - DECAY_RATE × m)
capacity_now = capacity_factor(m) × KPI_BASE_MONTH_1
```
`CAPACITY_FLOOR = 0.4`(MVP/完整版,从 `#7` propagation flag #2 锁;野心版可设 0)。`BASE_CAPACITY = 3.0`,`DECAY_RATE = 0.05`(research §1.4 锁)。**仲裁理由**: floor=0 时 m≥60 月 capacity=0 数学不可达(R-AP-5 跨 GDD 守门);floor=0.4 保证野心版超长跑仍有 0.4× 基准产出余量。

**Rule 9 — GAME OVER 检测协议**
```
if monthly_threshold > capacity_now:
  emit game_over_triggered(reason=KPI_EXCEEDS_CAPACITY, month=month_index)
  → #16 KPI Review UI 接管
  → #6 dispatch GAMEOVER sub-mode (不可逆)
  settlement_locked = true  # 永久锁定
```
检测时机: `kpi_threshold_changed` emit **之后**,Save 写入之前(UI 先收到阈值展示,再触发 GAME OVER 覆盖)。**单调递增保证**: `monthly_threshold` 单调升 + `capacity_now` 单调降 → 必相交。

**Rule 10 — 涨幅拆解显示协议**
```
breakdown = {
  effort_contrib_pct: α × effort_norm,
  potential_contrib_pct: β × potential,
  tenure_contrib_pct: γ_eff × month_index,  # M1 = 0.0 + novice_protection_active=true
  total_mult: 三因子乘积,
  old_threshold: int, new_threshold: int
}
```
`#16` 渲染三行戏谑 HR 口吻文案(KPI research §8.1 月度评估报告)。`#15 Recap` 周摘要订阅。`#9` 不渲染 UI。

**Rule 11 — 老 NPC 预言机制**
月末倒数第 2 天(`#6 MORNING_BRIEFING` sub-mode 触发),emit `kpi_prediction_hint(npc_id, hint_type)` 给 `#10`:

| hint_type | 触发条件 | 示例文案(由 #10 own) |
|-----------|---------|---------------------|
| `HINT_EFFORT_HIGH` | effort_norm_est > 0.7 | "你这么拼,小心下个月给你好看" |
| `HINT_POTENTIAL_HIGH` | potential_est > 0.25 | "做得多不如做得刚好" |
| `HINT_TENURE_LONG` | month_index > 6 | "我在这公司第 8 年了……" |
| `HINT_TENURE_VETERAN` | month_index > 12 | "你到我当年那个位置了" |

`settlement_locked = true` 时不 emit。

**Rule 12 — Pillar 1 红线(threshold 单调 / capacity 单向衰减)**
1. `monthly_threshold` 只涨不降(Rule 7 max() 守门)
2. `capacity_factor(m)` 只降不升
3. **禁**任何"KPI 豁免券 / 阈值重置 / 产能恢复"道具或事件通过 `#9` API 实现。`#10` / `#11` 试图调用"降低 threshold"接口 → `#9` 拒绝 + push_error
4. 野心版"剧情性 KPI 降低"事件走 `#10` 叙事层(文案展示降低,实际数值不变)

**Anti-Pillar 2 红线**: capacity_factor 不可逆恢复;任何"休假恢复产能"/"健康系统提升 capacity"路径阻断。

**Rule 13 — 信号架构**
**Emit**:
- `kpi_threshold_changed(old, new, delta_pct, breakdown)`
- `game_over_triggered(reason, month)`
- `kpi_review_started`
- `kpi_prediction_hint(npc_id, hint_type)`
- `dismissal_triggered(reason)`

**Subscribe**:
- `#6 scene_state_changed(→KPI_REVIEW)`
- `#7 monthly_effort_summary(...)`
- `#7 report_overage(int)`(月内超预期累积)

**Rule 14 — 主语翻转月末文案守门(HR 口吻)**
Localization key 守 `#3 Loc Rule 11` + `_BUREAUCRATIC` 后缀(继承 Audio 命名约定):

| 违反(玩家主语) | 要求(系统主语) |
|---------------|---------------|
| "你努力了,下月 KPI +X%" | "系统已登记您的积极性(+X%)" |
| "你表现超出预期" | "潜力挖掘余量已被更新" |
| "你工龄增加了" | "资深员工的责任相应调整" |

`subject_inversion_lint.py --domain KPI,EFFORT,TENURE` CI 守门(扩展 `#7` lint)。

**Rule 15 — Save 持久化**
```
kpi_state = {
  monthly_threshold: int,
  month_index: int,
  actual_kpi_history: Array[int],   # 最多 24 条(notice_board_max_entries)
  settlement_locked: bool            # GAME OVER 后永久 true
}
```
月末结算成功 → 内存 → emit autosave 请求(Save Rule 3 fast path)。

**Rule 16 — Scope Tier**

| Tier | 公式 | 参数 | M1 保护 | floor |
|------|------|------|--------|-------|
| **MVP B 戏剧** | Formula B | α=0.06, β=0.22, γ=0.020 | γ=0 | 0.4 |
| **完整版 B 保守(推荐)** | Formula B | α=0.04, β=0.18, γ=0.012 | γ=0 | 0.4 |
| **野心版 C 指数** | Formula C | α=0.04, β=0.15, γ=0.008, k=0.12 | γ=0 | 0.0 + HUD 预警 |

`KPI_FORMULA_VARIANT` enum A/B/C(`config/kpi_balance.tres`),默认 B 保守。

### States and Transitions

| 状态 | 触发条件 | 退出条件 |
|------|---------|---------|
| `IDLE` | 默认(月内) | `#6 scene_state_changed(→KPI_REVIEW)` |
| `EVALUATING` | 月末进入 KPI_REVIEW | F1-F5 + F4 GAME OVER 检测完成 |
| `LOCKED` | GAME OVER 触发后 | 永久(settlement_locked = true) |

`IDLE → EVALUATING → IDLE`(继续游戏) / `IDLE → EVALUATING → LOCKED`(GAME OVER)。LOCKED 状态下任何 `_run_monthly_settlement()` 调用被拒。

### Interactions with Other Systems

| # | 对端 | 信号 / 调用 | 数据流向 |
|---|------|------------|---------|
| I-1 | `#6 Scene & Day Flow` | `scene_state_changed(→KPI_REVIEW)` 触发 → `#9` `_run_monthly_settlement` | `#6` → `#9` |
| I-2 | `#7 AP Economy` | `monthly_effort_summary` 月末 push;`report_overage` 实时回调 | `#7` → `#9` |
| I-3 | `#8 NPC Relationship` | **零直接**(NPC 不直接进 KPI 公式;仅经 `#10` → `#11` 间接影响) | — |
| I-4 | `#10 Event Script Engine` | emit `dismissal_triggered` + `kpi_prediction_hint` 给 `#10` | `#9` → `#10` |
| I-5 | `#11 Action Card` | `#11` emit `kpi_contribution_reported(amount)` → `#9` 累加 actual_kpi | `#11` → `#9` |
| I-6 | `#12 Run Meta` | emit `game_over_triggered` → Run 寿命记录 | `#9` → `#12` |
| I-7 | `#15 / #16 UI` | emit `kpi_review_started` + `kpi_threshold_changed(breakdown)` | `#9` → UI |

## Formulas

7 公式 F1-F7。

### F1 — `next_threshold`(Formula B 乘性主公式)
```
next_threshold = current_threshold
  × (1 + α × effort_norm)
  × (1 + β × potential)
  × (1 + γ_effective × month_index)
```
| Var | Type | Range | Description |
|-----|------|-------|-------------|
| `current_threshold` | int | [100,+∞) | 当月阈值(结算前) |
| `α` (KPI_EFFORT_WEIGHT) | float | [0.03, 0.06] | 推荐 0.04 |
| `effort_norm` | float | [0.0, 0.95] | from `#7 F4`(权重 0.45/0.20/0.30) |
| `β` (KPI_POTENTIAL_WEIGHT) | float | [0.15, 0.22] | 推荐 0.18 |
| `potential` | float | [-0.15, +1.0] | from F2 clamp |
| `γ_effective` | float | {0.0, γ} | M1=0(新手保护) |
| `γ` (KPI_TENURE_WEIGHT) | float | [0.010, 0.018] | 推荐 0.012 |
| `month_index` | int | [1,N] | 当前结算月份 |
| `next_threshold` | int | [100,+∞) | `roundi()` 取整 |

**3 玩家 profile(B 保守 α=0.04, β=0.18, γ=0.012)**:

| Profile | effort | potential | M1→M2 | M8 | GAME OVER |
|---------|--------|-----------|-------|-----|-----------|
| 标准 | 0.5 | 0.0 | 100→102 | 176 | **第 11 月** |
| 过度优秀 | 0.8 | 0.3 | 100→109 | 294 | **第 8 月** |
| 躺平 | 0.2 | -0.1 | 100→99 | — | 不适用(开除剧本) |

**Worked Example M6 标准**: 142 × 1.020 × 1.000 × 1.072 = 155.3 → roundi 155(对标 research §4.2 表 ±2 取整误差)。

### F2 — `potential`(本月超额比例)
```
potential = clamp((actual_kpi_m - monthly_threshold) / monthly_threshold, -0.15, +1.0)
```
**特殊**: raw < -0.15 → 不进 F1,直接 `dismissal_triggered`。raw=0 时 F1 潜力因子 1.0 消去(刚达标 = 最低惩罚,Pillar 1 最优解)。

### F3 — `capacity_factor(m)`
```
capacity_factor(m) = max(CAPACITY_FLOOR, 3.0 - 0.05 × m)
capacity_now = capacity_factor(m) × 100
```
floor=0.4 时:m=11 capacity_now=245;m=20 capacity_now=200;m=52+ floor 锁 capacity_now=40。

### F4 — GAME OVER 检测
```
game_over = (monthly_threshold > capacity_now)
```
**触发后**: `settlement_locked = true` 永久。M11 标准:262>245 → GAME OVER。M8 过度优秀:294>260 → GAME OVER。

### F5 — 涨幅拆解(三维度独立贡献)
```
effort_contrib   = α × effort_norm        # M6 标准: 0.04 × 0.5 = 2.0%
potential_contrib = β × potential          # M6 标准: 0.18 × 0.0 = 0.0%
tenure_contrib   = γ_eff × m              # M6 标准: 0.012 × 6 = 7.2%
total_mult = (1+α·E)(1+β·p)(1+γ_eff·m)    # M6: 1.0934 → +9.34%
```
`#16` 渲染:"努力系数 +2.0% / 潜力挖掘 +0.0% / 工龄加成 +7.2% / 合计 +9.34%"。

### F6 — `effort_norm` 输入校验(`#7` 数据契约)
```
effort_norm_check = 0.45×min(n_ot/20,1.0) + 0.20×min(n_h/10,1.0) + 0.30×min(n_ov/10,1.0)
|effort_norm_received - effort_norm_check| <= 0.001  # EFFORT_NORM_TOLERANCE
```
失败时使用 `effort_norm_check`(本地重算)+ push_error。CI lint 验证 `#7 F4` 与 `#9 F6` 权重常量来自同一 `config/kpi_balance.tres`(R-KPI-5 守门)。

### F7 — `actual_kpi_m` 月内累积
```
actual_kpi_m = Σ(kpi_contribution_i for card_i played in month m)
```
`#11` 每次打卡后 emit `kpi_contribution_reported(amount)` → `#9` 累加。月末 actual_kpi_m 推入 `actual_kpi_history`,清零 accumulator。**Worked Example**: 月内 18 张卡 × 平均 8.5 KPI 点 = actual_kpi_m=153(刚达标 threshold=157 场景)。

## Edge Cases

30 edges / 10 categories / 5 [RISK GUARD] R-KPI-1..5。

### Cat 1: M1 新手保护边界

**1.1**: `month_index == 1` 结算 → γ_effective=0,工龄项消去。UI breakdown tenure_contrib 显示 `—`(破折号)+ "新人豁免"
**1.2**: `month_index == 2` 结算 → γ_effective=0.012,tenure_contrib=2.4%(首次启动)。配 `#10` 老油条"下个月开始就不一样了"台词
**1.3**: `KPI_NOVICE_PROTECTION_MONTHS=2`(野心版)→ M1+M2 均豁免,M3 工龄首启
**1.4**: M1 `actual_kpi_m=0`(玩家未打卡)→ raw potential=-1.0 → clamp -0.15 → 触发 `dismissal_triggered`。M1 开除走剧本路径,不触发 GAME OVER

### Cat 2: potential clamp 边界

**2.1**: raw=-0.2 → clamp 下限 -0.15 → 不进 F1,emit `dismissal_triggered(SEVERE_UNDERPERFORMANCE)`,`monthly_threshold` 不更新,month_index 不递增,`#10` 接管开除剧本,`#6` dispatch GAMEOVER
**2.2**: raw=+1.42(actual=380, threshold=157)→ clamp +1.0 → F1 输入 1.0。UI "潜力挖掘 +18.0%(已达上限)"
**2.3**: potential=-0.15 边界值 → `>= MIN` 判 true,进 F1(刚好过线);`raw < MIN` 严格小于触发开除
**2.4**: clamp_min 调 -0.10(收紧)→ 实际 90% 即开除。同步告知 `#10` 更新事件触发条件
**2.5**: actual_kpi == threshold(刚达标)→ raw=0,潜力因子 1.0 消去 — Pillar 1 最优解

### Cat 3: capacity 衰减边界

**3.1**: m=52, floor=0.4 → capacity_now 锁 40,GAME OVER 已在 m=11 触发,floor 仅安全网
**3.2**: 野心版 floor=0, m=60 → capacity=0,F4 永远 true。`settlement_locked` 在 m=11-15 已锁,正常不触此分支。bug 路径 → emit + push_error 异常记录
**3.3**: `DECAY_RATE=0.08` 加速 → floor 在 m=32.5 触达;标准玩家 m=9-10 GAME OVER。须 balance-check 重跑 simulation

### Cat 4: GAME OVER 检测 race

**4.1 [RISK GUARD R-KPI-4]**: F1 → `kpi_threshold_changed` emit → 同帧 `#16` 收阈值 → 同帧 F4 → `game_over_triggered` emit → `#6 GAMEOVER`。**规定**: `kpi_threshold_changed` 必须 emit 早于 `game_over_triggered`(UI 先展示阈值再被覆盖)。GDScript 单线程保证 emit 顺序 = 调用顺序
**4.2**: `game_over_triggered` emit 后 `settlement_locked=true` 同帧设置(防同帧其他订阅者重触发结算)
**4.3**: GAME OVER 月份 threshold = capacity_now+1(刚好穿越)→ F4 严格 `>` 仍触发。`#16` "差一点点……就差那么一点点" 戏谑文案
**4.4**: `#8 NPC 离职` 与 `#9 GAME OVER` 同帧 → GAME OVER 优先,NPC 离职被 `settlement_locked` 屏蔽,由 `#6 GAMEOVER` sub-mode 统一处理结局

### Cat 5: effort 输入校验

**5.1 [RISK GUARD R-KPI-5]**: `KPI_REVIEW` 后 1 帧 `monthly_effort_summary` 未到 → 容错协议: 使用上月 `effort_norm_fallback=0.5`(标准玩家中位)+ push_error + `#16` 显示"数据同步异常,基于系统估算"(戏谑文案转化 bug 为剧情)。不阻塞结算
**5.2**: F6 校验失败(|received-check|>0.001)→ 使用 `effort_norm_check`(本地重算)覆盖 + push_error。原因可能 `#7` 浮点累积或权重不同步。CI lint 验证两 GDD 共享 config
**5.3**: `n_ot>20` / `n_h>10` / `n_ov>10`(超定义上限)→ F6 `min()` 截断前 push_error,截断后继续(双层防护)

### Cat 6: 涨幅拆解 UI

**6.1**: M1 `tenure_contrib=0.0`,UI 显示 `—` 而非 `0%`(语义区别 — `—` 表示新人豁免,`0%` 误以为工龄不重要)
**6.2**: potential 负值(>-0.15 未开除)→ `potential_contrib < 0`,UI 显示"潜力挖掘 -X%"(欠达标导致涨幅降低)
**6.3**: `delta_pct < 0`(理论:potential 极负 + effort 极低 + M1 γ=0)→ Rule 7 max() 守门 threshold 不下降,但 breakdown delta_pct 仍显示负值("本月评估有所下调,公司决定维持原标准"戏谑)

### Cat 7: 月末结算与 NPC 离职 race

**7.1**: `#8 F3 离职` 与 `#9 月末结算` 同 sub-mode → 执行顺序:`#9` 先(threshold + GAME OVER 检测),`#8` 后(订阅同信号但 `#6` dispatch 顺序保证)。`#9` 已 GAME OVER → `#8` 离职被 `#6 GAMEOVER` 覆盖
**7.2**: NPC 离职导致 `actual_kpi_m` 月末前突降(部分卡贡献无效化)→ 须确保 `actual_kpi_accumulator` 在结算前已含离职影响。`#9` 仅读快照,不接受结算过程动态修改

### Cat 8: Save crash 中段

**8.1**: 结算期间 Save 写 threshold 成功但 GAME OVER emit 前 crash → 下次加载 threshold 已更新, `settlement_locked=false`。**重新执行 GAME OVER 检测**(Pillar 3 — 崩溃不可成复活手段)
**8.2**: `settlement_locked=true` 写成功但 threshold 写失败(部分崩溃)→ 加载后 settlement_locked 优先于 threshold 检测,直接进 GAME OVER UI
**8.3**: `actual_kpi_history` 写失败(超 24 条 cap)→ 历史截断,核心 threshold + month_index 不受影响。Recap UI 历史数据可能不完整

### Cat 9: 8 失败模式触发场景(KPI research §5)

**9.1 [RISK GUARD R-KPI-1]**: 失败 #1 努力反噬过狠(α>0.08)→ `config/kpi_balance.tres` assert α∈[0.03,0.06];超 push_error,生产 build 拒加载或回退默认 0.04
**9.2 [RISK GUARD R-KPI-2]**: 失败 #2 工龄惩罚不足(γ<0.005)→ assert γ>=0.010;playtest >10% session 活过 18 月触发 γ 上调
**9.3**: 失败 #3 第 3 月断崖(β>0.3 + 高 effort)→ assert β<=0.22;组合上限 `KPI_MONTHLY_MULTIPLIER_CAP=1.25` 防断崖
**9.4**: 失败 #4 新手骂娘 → M1 标准玩家涨幅 ≤ 5%(AC-TONE 测试覆盖);`KPI_MONTHLY_MULTIPLIER_CAP_M1=1.05` 强硬保证
**9.5**: 失败 #5 潜力陷阱不明显(β<0.10)→ assert β>=0.15;卷王 GAME OVER 月份须比标准早 ≥2 月
**9.6**: 失败 #6 后期通胀爆炸(Formula C k>0.20)→ assert k<=0.15;仅野心版 Formula C 生效
**9.7**: 失败 #7 三维度相关性太高 → 设计约束:effort 来自 `#7`(加班/Hero/超预期),potential 来自 KPI 真实值/阈值(由 NPC + 事件驱动),数学解耦
**9.8**: 失败 #8 躺平无代价 → `KPI_POTENTIAL_CLAMP_MIN=-0.15` 硬编码底线(不暴露 knob)+ R-KPI-5

### Cat 10: 玩家行为 edge

**10.1**: 月末结算动画期间 Alt+F4 → `#6 GAMEOVER` + Save Rule 21 1500ms 锁已锁 Input,Save autosave 已写 threshold。下次进入延续阈值 + 重检 GAME OVER(Cat 8.1 路径)
**10.2**: 修改系统时钟 → `#9` 不依赖 wall-clock(month_index int 驱动,非时间戳)。时钟改不影响推进逻辑
**10.3**: 月末反复 reload(Save load → KPI_REVIEW → Alt+F4 → load → ...)→ `settlement_locked_for_this_month: bool` 在 KPI_REVIEW 开始置 true,日 reset 清 false(每月仅结算一次,即使多次进入)。已 GAME OVER → 每次 load 即 GAME OVER(Pillar 3 不可逃)
**10.4**: 第三方工具改 Save threshold(作弊降阈值)→ 加载完整性校验:`monthly_threshold < 100` 强制重置 100 + push_error(超理论范围视为损坏)

---

### 5 [RISK GUARD] 索引

| ID | 守 Pillar | 位置 | Section H 守门 |
|----|---------|------|---------------|
| **R-KPI-1** | Formula B 实现错(α/β/γ 偏离)| Cat 9.1 | AC-ROBUST-01 |
| **R-KPI-2** | M1 新手保护漏 | Cat 9.2 | AC-ROBUST-02 |
| **R-KPI-3** | capacity_floor=0 数学不可达(R-AP-5 同)| Cat 3.2 | AC-ROBUST-03 |
| **R-KPI-4** | GAME OVER race UI 不一致 | Cat 4.1 | AC-ROBUST-04 |
| **R-KPI-5** | effort 权重 propagation 破裂 | Cat 5.1+5.2 | AC-ROBUST-05 |

## Dependencies

### Upstream

| GDD | 关系 | 状态 | 提供 |
|-----|------|------|------|
| `#1 Save System` | Hard | ✅ Approved | Rule 6 snapshot + Rule 21 1500ms 锁 + Rule 22 archive |
| `#6 Scene & Day Flow` | Hard | ⏳ Designed | Rule 10 月末 KPI_REVIEW 触发 + Rule 11 GAMEOVER 永久锁 + 8 sub-mode enum |
| `#7 AP Economy` | Hard | ⏳ Designed | F4 effort_norm(权重 0.45/0.20/0.30 已锁)+ monthly_effort_summary 月末 push + report_overage 实时回调 |

### Downstream

| # | System | 关系 | 主接口 |
|---|--------|------|--------|
| 8 | NPC Relationship | **零直接** | NPC 不进 KPI 公式;经 `#10` → `#11` 间接 |
| 10 | Event Script Engine ⭐ | Hard | 订阅 `dismissal_triggered` + `kpi_prediction_hint`(老 NPC 预言)+ `game_over_triggered` |
| 11 | Action Card | Hard | emit `kpi_contribution_reported(amount)` → `#9` 累加 actual_kpi |
| 12 | Run Meta | Hard | 订阅 `game_over_triggered` 记录 Run 寿命 + actual_kpi_history snapshot |
| 13 | HUD Diegetic | Soft | 订阅 `kpi_threshold_changed` 显示当前阈值 + capacity_now 进度条预警 |
| 15 | Daily/Weekly Recap UI | Hard | 订阅 `kpi_threshold_changed(breakdown)` 周摘要展示三维度 |
| 16 | KPI Review & Game Over UI ⭐ | Hard | 订阅 `kpi_review_started` + `kpi_threshold_changed(breakdown)` + `game_over_triggered` |

### 双向一致性 cross-check

| 上游声明 | 本 GDD Rule | ✓ |
|---------|------------|---|
| Save Rule 6 snapshot 跨月持久化 | Rule 15 kpi_state schema | ✓ |
| Save Rule 21 final_transition 1500ms 锁 | Rule 9 GAME OVER + `#6 Rule 11` 同步 | ✓ |
| `#6 Rule 10` 月末 KPI_REVIEW 触发 | Rule 2 + I-1 | ✓ |
| `#7 F4` effort 权重 0.45/0.20/0.30 | Rule 4 + F6 校验 | ✓ |
| `#7 propagation flag #1` 待 #9 仲裁 | Rule 4 **已仲裁采纳** | ✓ |
| `#7 propagation flag #2` CAPACITY_FLOOR | Rule 8 **MVP=0.4 + 野心版=0** | ✓ |
| `#7 R-AP-5` capacity_floor 守门 | Rule 8 + R-KPI-3 跨 GDD 守 | ✓ |

### 5 propagation flags(待 `#10` / `#11` / `#15` / `#16` GDD 撰写时复审)

1. **`#10 Event Script`**: `dismissal_triggered` + `kpi_prediction_hint` 触发剧本注册;NPC 台词库 owner;开除剧本 `EVENT.KPI.FIRED_DISMISSAL`
2. **`#11 Action Card`**: emit `kpi_contribution_reported(amount)` 协议;Hero/Overage 卡 flag 与 effort 三维度对应
3. **`#15 Recap UI`**: 三维度 breakdown 周摘要展示
4. **`#16 KPI Review UI`**: 月末结算屏渲染 Rule 10 breakdown + GAME OVER 离职证明 transition + agency 预警(R-KPI-3 守门)
5. **`#13 HUD Diegetic`**: 当前阈值 + capacity_now 预警显示

### Registry 注册候选

| 候选 | 值 | 跨系统消费 | 注册时机 |
|------|----|----|---------|
| `KPI_BASE_MONTH_1` | 100 | `#9` only(本 GDD 内部) | 不注册 |
| `CAPACITY_FLOOR` | 0.4(MVP)/ 0(野心版) | `#7` `#9` 双消费(R-AP-5 + R-KPI-3 跨 GDD) | **注册 Phase 5b** |
| `KPI_EFFORT_WEIGHT (α)` | 0.04 | `#7 F4 source` + `#9 F1 consumer` | **注册 Phase 5b** |
| `KPI_POTENTIAL_WEIGHT (β)` | 0.18 | `#9` only | 不注册 |
| `KPI_TENURE_WEIGHT (γ)` | 0.012 | `#9` only | 不注册 |
| `KPI_POTENTIAL_CLAMP_MIN` | -0.15 | `#9` + `#10`(开除事件触发条件) | **注册 Phase 5b** |
| effort 三维权重组 0.45/0.20/0.30 | — | `#7 source` + `#9 F6 校验` | **注册 Phase 5b**(标记 deviation from research) |

## Tuning Knobs

### 锁定常量(红线,不是 knob)

| 常量 | 值 | 红线 |
|------|----|----|
| `KPI_BASE_MONTH_1` | 100 | 初始阈值基准,Pillar 1 不可调 |
| `BASE_CAPACITY` | 3.0 | research §1.4 锁 |
| `DECAY_RATE` | 0.05 | research §1.4 锁 |
| `KPI_POTENTIAL_CLAMP_MIN` | -0.15 | 躺平开除硬底线,**不暴露 knob**(防失败模式 #8) |
| `EFFORT_NORM_TOLERANCE` | 0.001 | F6 浮点比较容差 |

### Formula B 主公式 Knobs

| Knob | 默认 | 安全范围 | Failure mode 防护 |
|------|------|---------|-----------------|
| `KPI_EFFORT_WEIGHT (α)` | **0.04** | [0.03, 0.06] | 失败 #1 努力反噬过狠(α>0.08)|
| `KPI_POTENTIAL_WEIGHT (β)` | **0.18** | [0.15, 0.22] | 失败 #3 第 3 月断崖(β>0.3)+ 失败 #5 潜力陷阱不明显(β<0.10)|
| `KPI_TENURE_WEIGHT (γ)` | **0.012** | [0.010, 0.018] | 失败 #2 工龄惩罚不足(γ<0.005)|

### 新手保护 Knobs

| Knob | 默认 | 安全 | 影响 |
|------|------|------|------|
| `KPI_NOVICE_PROTECTION_MONTHS` | 1 | [0, 2] | M1 γ_effective=0;失败 #4 新手骂娘防护 |
| `KPI_MONTHLY_MULTIPLIER_CAP_M1` | 1.05 | [1.03, 1.08] | M1 单月涨幅硬上限 5%(防 effort+potential 极值组合 >5%) |
| `KPI_MONTHLY_MULTIPLIER_CAP` | 1.25 | [1.15, 1.35] | M2+ 单月涨幅组合上限(防失败 #3 断崖) |

### potential clamp Knobs(部分锁定)

| Knob | 默认 | 安全 | 备注 |
|------|------|------|------|
| `KPI_POTENTIAL_CLAMP_MAX` | +1.0 | [+0.5, +1.5] | potential 上限,防单次爆炸涨幅 |

### capacity 衰减 Knobs

| Knob | 默认 | 安全 | 影响 |
|------|------|------|------|
| `CAPACITY_FLOOR` | **0.4**(MVP/完整版)/ 0.0(野心版) | [0.0, 0.6] | floor=0 数学不可达域(R-KPI-3),需 HUD 预警配合 |

### Formula 选择 Knob

| Knob | 默认 | 选项 | 备注 |
|------|------|------|------|
| `KPI_FORMULA_VARIANT` | `B`(乘性) | A(线性)/ B(乘性)/ C(指数工龄) | C 仅野心版 24+ 月,需 `KPI_EXP_K` 配置 |
| `KPI_EXP_K` | 0.12(野心版 C 专用) | [0.10, 0.15] | 失败 #6 后期通胀爆炸(k>0.20)|

### Per-Profile 模拟基准(`KpiSimulator` QA 工具用)

| Profile | effort_norm | potential | M11 GAME OVER? |
|---------|-------------|-----------|---------------|
| `standard_player` | 0.5 | 0.0 | ✅ 第 11 月 |
| `overachiever` | 0.8 | 0.3 | ✅ 第 8 月 |
| `slacker` | 0.2 | -0.1 | ❌ 不适用(开除剧本) |
| `grinder`(卷王模板) | 0.7 | 0.15 | 第 9-10 月 |

### Scope Tier

| Tier | Formula | α | β | γ | floor | 用途 |
|------|---------|---|---|---|-------|------|
| **MVP B 戏剧** | B | 0.06 | 0.22 | 0.020 | 0.4 | 逼玩家 3 月内体验完整弧线 |
| **完整版 B 保守(推荐)** | B | 0.04 | 0.18 | 0.012 | 0.4 | 12 月平衡节奏 |
| **野心版 C 指数** | C | 0.04 | 0.15 | 0.008 + k=0.12 | **0.0** + HUD 预警 | 24 月戏剧化老员工雪崩 |

**balance-check 触发条件**: 任一 knob 修改 → 重跑 `KpiSimulator` 三 profile × 15 月模拟 → 验证 GAME OVER 月份在 [9, 15] 区间。

## Visual/Audio Requirements

### 零 Asset Ownership

KPI System **不 own visual / audio asset**。所有月末结算视听由 `#16 KPI Review UI` + `#4 Audio Manager` + `#5 Lighting` own。

| Asset | Owner |
|-------|-------|
| 月末结算屏 UI / 三维度拆解动画 / GAME OVER 离职证明 | `#16 KPI Review & Game Over UI` |
| KPIREVIEW BGM / GAMEOVER stinger / 月末打卡机 SFX | `#4 Audio Manager` Rule 6 |
| KPI_REVIEW 紫光 + GAMEOVER 灰度压抑 + 累积视觉峰值 | `#5 Lighting` Rule 1 + 累积 state |

### Pillar 4 三轨负空间铁三角(本 GDD 是数学源)

月末 KPI Review 时 *四轨* 同时拒绝庆祝:
1. **数学**(本 GDD): threshold 涨幅,无任何"祝贺"语义
2. **听觉**(`#4`): 月末打卡机不是胜利音 + GAMEOVER stinger 反讽
3. **视觉**(`#5`): KPI 紫 `#3A3050` 静止 + GAMEOVER 累积视觉峰值
4. **文字**(`#3`): GAMEOVER.TITLE_IRONY "恭喜晋升"

`#9` emit `kpi_review_started` 同帧四轨同步触发。Pillar 4 守门契约。

### 📌 Asset Spec Flag

本 GDD 不需要 `/asset-spec` — 零 ownership。Asset spec 由 owner GDD 各自产出。

## UI Requirements

### 零 UI Screen Ownership

KPI System **不 own UI screen**。所有玩家可见 UI 由下游 own。

| UI GDD | 订阅信号 | 备注 |
|--------|---------|------|
| `#16 KPI Review & Game Over UI` ⭐ | `kpi_review_started` + `kpi_threshold_changed(breakdown)` + `game_over_triggered` | 月末结算屏 + GAME OVER 离职证明;Rule 10 三维度拆解渲染必须按 KPI research §8.1 三行格式 |
| `#15 Daily/Weekly Recap UI` | `kpi_threshold_changed(breakdown)` | 周摘要三维度展示 |
| `#13 HUD Diegetic` | `kpi_threshold_changed` | 当前阈值 + capacity_now 进度条预警(R-KPI-3 + R-AP-5 玩家 agency) |

### `#16` 强制契约(本 GDD 锁定渲染要求)

`#16 KPI Review UI` GDD 撰写时**必须**遵循:

1. 三维度独立渲染(KPI research §8.1):
   ```
   月度评估报告
   ━━━━━━━━━━━━━━━━━━━
   下月 KPI 基准调整:
     努力系数  +X.X%   [💼 "积极性可嘉"]
     潜力挖掘  +X.X%   [🚀 "还有上升空间"]
     工龄加成  +X.X%   [⏳ "资深员工的责任"]
   ─────────────────────
     合计:     +X.X%
     新基准:   XXX
   ```
2. M1 工龄项显示 `—`(破折号)+ "新人豁免" string,不显示 `0%`
3. 戏谑化 HR 口吻:三行 Localization key `KPI.BREAKDOWN.*_BUREAUCRATIC`,继承 `_IRONY` 后缀守 `#3 Loc Rule 11`
4. GAME OVER 月份: 阈值展示动画完成后再显示离职证明(R-KPI-4 守门顺序)

### 📌 UX Flag — Phase 4

`#16 KPI Review & Game Over UI` 是**最复杂的 UI 屏之一**(三维度透明度 + GAME OVER 仪式感 + 戏谑 tone)。Phase 4 须 `/ux-design design/ux/kpi-review-screen.md` 独立 UX spec(配 `#16` GDD)。三轨铁三角 + 主语翻转 + 反英雄红线 cross-cutting。

### 涨幅预览 UI(VS 阶段考虑)

KPI research §8.3 提议: 月末倒数第 3 天 HUD 显示"预计下月 KPI: 125-140"模糊区间预览(±10%),让玩家可调整策略。MVP 不实现(防破坏黑色幽默 surprise);VS 引入。本 GDD `kpi_prediction_hint` 已为此机制铺底(老 NPC 预言)。

## Acceptance Criteria

30 AC / 5 categories(AC-FUNC 12 / AC-PERF 4 / AC-COMPAT 5 / AC-ROBUST 5 / AC-TONE 4)。5 [RISK GUARD] R-KPI-1..5 全对应 AC-ROBUST + 8 失败模式(KPI research §5)全覆盖。

### AC-FUNC

**AC-FUNC-01** `MVP` 标准玩家第 11 月 GAME OVER 数值验证
**GIVEN** Formula B 保守(α=0.04, β=0.18, γ=0.012)+ `standard_player`(effort=0.5, potential=0.0)+ M1 γ=0
**WHEN** `KpiSimulator.simulate_15_months(profile)` 运行
**THEN** 月份 11 时 `threshold > capacity`(capacity=100×(3.0-0.05×11)=245, threshold≥262.2),GAME OVER 触发;允许 ±1 月偏差(M10-M12 任一)
*Cite: F1 / F3 / F4 / Tuning Knob α/β/γ / KPI research §4.2*

**AC-FUNC-02** `MVP` 过度优秀第 8 月 GAME OVER + 倒 U 验证
**GIVEN** 同公式 + `overachiever`(effort=0.8, potential=0.3)
**WHEN** 12 月模拟
**THEN** GAME OVER M6-M9(标准 M8);**overachiever GAME OVER 月份 < standard_player GAME OVER 月份**(倒 U C2 验证 — Pillar 1 数学保证)
*Cite: F1 / 数学约束 C2*

**AC-FUNC-03** `Beta` 躺平玩家被剧本吃掉(potential 触发开除)
**GIVEN** `slacker`(effort=0.2, potential=-0.1)+ `KPI_POTENTIAL_CLAMP_MIN = -0.15`
**WHEN** 月末结算
**THEN** potential < -0.15 → emit `dismissal_triggered(player_fired)`,不进 F1(转 `#10` 开除剧本);躺平玩家 M1-M2 触发,不通过纯数值淘汰活到 M13
*Cite: Rule 5 / F2 / KPI research §4.2 注释*

**AC-FUNC-04** `MVP` M1 涨幅 ≤ 3%(标准玩家)
**GIVEN** M1 γ_effective=0 + standard_player + α=0.04, β=0.18
**WHEN** F1 计算 next_threshold
**THEN** 涨幅 = 2.0%(±0.5%),∈ [1%, 3%];M2 γ 恢复正常
*Cite: KPI research §6.2 / Rule 6 / Tuning Knob KPI_NOVICE_PROTECTION_MONTHS*

**AC-FUNC-05** `MVP` 反向性 C1 验证
**GIVEN** 同月份 m,对比 potential=0.0 vs potential=0.3
**WHEN** F1 各计算 next_threshold
**THEN** `next_threshold(p=0.3) > next_threshold(p=0.0)`,差值 ≥ 5%(C1 反向性数学约束)
*Cite: F1 / KPI research §1.2 C1*

**AC-FUNC-06** `MVP` potential clamp 上下限边界
**GIVEN** raw potential = +2.0(超 max)或 = -0.5(< min)
**WHEN** `compute_potential()` 调用
**THEN** clamp 至 [-0.15, +1.0];raw=+2.0 → 1.0;raw=-0.5 → 直接 emit `dismissal_triggered`,不返回 clamp 后负值
*Cite: F2 / Rule 5 / Tuning Knob CLAMP_MIN/MAX*

**AC-FUNC-07** `MVP` effort_norm 归一化上限保护
**GIVEN** 单月 n_ot=20, n_h=10, n_ov=10(全部上限)
**WHEN** `compute_effort_norm()` 调用
**THEN** effort_norm = 0.95(权重和);不超过 0.95;单次超限输入不产生越界
*Cite: F6 / 权重 0.45/0.20/0.30 / R-KPI-3*

**AC-FUNC-08** `MVP` capacity_factor floor 守门 — GAME OVER 不早于 M9
**GIVEN** `capacity(m) = 100 × max(0.4, 3.0 - 0.05·m)` + standard_player B 保守
**WHEN** 检测 threshold > capacity 首次成立月份
**THEN** 首次 GAME OVER 月份 ≥ M9(floor 守门防止过早数学不可达);capacity(40)=100×1.0 floor 兜底
*Cite: KPI research §1.4 / Tuning Knob CAPACITY_FLOOR / R-KPI-3 + R-AP-5*

**AC-FUNC-09** `MVP` 三维度独立解耦(乘性而非加性)
**GIVEN** 三组测试: (E=0,p=0.3,t=5) / (E=0.5,p=0,t=5) / (E=0.5,p=0.3,t=0)
**WHEN** F1 计算
**THEN** 每组结果手算验证一致;某维度=0 时 `(1+α×0)=1` 不影响其余两维度乘积(Formula B 乘性结构验证)
*Cite: F1 / KPI research §3*

**AC-FUNC-10** `MVP` GAME OVER 检测信号发射
**GIVEN** mock 状态 threshold=300 > capacity=250
**WHEN** `evaluate_month_end()` 调用
**THEN** 同帧 emit `game_over_triggered(month_index, threshold, capacity)`;`#12 Run Meta` 接收 + 记录本局寿命
*Cite: Rule 9 / F4 / I-6*

**AC-FUNC-11** `MVP` 月末涨幅三维度拆解数据供给
**GIVEN** 月末结算后
**WHEN** `get_month_end_breakdown()` 调用
**THEN** 字典含 effort/potential/tenure_contribution_pct + total_pct + new_threshold;每维度与 F1 分项一致(误差<0.1%);三贡献和不必等 total(乘性),独立可读
*Cite: F5 / Rule 10 / KPI research §8.1*

**AC-FUNC-12** `Beta` 老 NPC 预言触发条件数据供给
**GIVEN** effort_norm>0.7 / potential>0.25 / tenure>6 / tenure>12 (4 档之一)
**WHEN** 月末倒数第 2 天 `query_veteran_npc_hint_condition()` 被 `#10` 调用
**THEN** 返回匹配 hint_key 或 null;在 `ACTION_DAY` 月末 -2 天触发,不早不晚
*Cite: Rule 11 / KPI research §8.2 / I-4*

### AC-PERF

**AC-PERF-01** `MVP` 月末公式 ≤ 1ms(单次主线程)
**GIVEN** Formula B 单次计算(三浮点乘法)
**WHEN** `compute_next_threshold()` 调用 1000 次取 p95
**THEN** p95 ≤ 1ms(headless);月末完整结算(含 breakdown)总帧 < 2ms(< 16.6ms 帧预算 12%)
*Cite: 帧预算 16.6ms / Rule 2*

**AC-PERF-02** `MVP` 15 月批量模拟 ≤ 100ms
**GIVEN** `KpiSimulator` 三 profile × 15 月 = 45 计算
**WHEN** headless 模式
**THEN** 总耗时 ≤ 100ms;输出 month / threshold / capacity / game_over JSON 或 TSV
*Cite: KPI research §4 / QA 工具*

**AC-PERF-03** `MVP` 信号 emit 到 UI 渲染 ≤ 1 帧
**GIVEN** `game_over_triggered` 或 `month_end_evaluated` emit 后 `#16` 接收并渲染
**WHEN** emit 帧与 UI 首绘帧差值
**THEN** ≤ 16.6ms(1 帧);UI 不允许跨帧 yield/await 后才渲染
*Cite: `#3 Loc Rule 5` dispatch ≤1帧 / I-7*

**AC-PERF-04** `MVP` Save 月末快照写入 ≤ 50ms
**GIVEN** 月末结算后 KPI emit + Save 写入
**WHEN** `SaveSystem.write_month_end_snapshot()` WorkerThreadPool 执行
**THEN** 主线程阻塞 ≤ 0ms(纯异步);总写入 ≤ 50ms(`autosave_perf_hard_ceiling_ms`)
*Cite: Save Rule 7 + 50ms 硬限 / registry constant*

### AC-COMPAT

**AC-COMPAT-01** `MVP` `#6` 月末 sub-mode 触发契约
**GIVEN** `#6` emit `scene_state_changed(→KPI_REVIEW)`
**WHEN** `#9` 订阅 + `evaluate_month_end()`
**THEN** `#9` 同帧完成 F1 + emit `month_end_evaluated`;不主动驱动时序,不轮询(单向信号消费契约)
*Cite: I-1 / Rule 2 / `#6 Rule 10`*

**AC-COMPAT-02** `MVP` `#7` effort 三维度数据接收(权重 0.45/0.20/0.30)
**GIVEN** `#7` 月末 emit `monthly_effort_summary(potential, n_h, n_ov)` (potential ∈ [-0.3,+1.0], n_h ∈ [0,10], n_ov ∈ [0,10])
**WHEN** `#9` 接收 + `accumulate_effort()`
**THEN** 正确映射三维度为 effort_norm(权重 0.45/0.20/0.30)+ potential;不查询 `#7` 内部状态(Signal-only)
*Cite: Rule 4 仲裁 / I-2 / F6 校验*

**AC-COMPAT-03** `MVP` `#8` NPC 关系不直接进入 KPI 公式
**GIVEN** `#8` 改 NPC 好感度
**WHEN** `#9` 月末计算
**THEN** `#9` **不**直接读 `#8` 状态(NPC 仅经 `#11` → effort_norm 间接);NPC 关系变化不触发 KPI 重算
*Cite: I-3 零直接交互 / `#8 Rule 5 N/A`*

**AC-COMPAT-04** `Beta` `#10` 开除剧本触发接口
**GIVEN** `#9` emit `dismissal_triggered(reason=player_fired)`(potential < clamp_min)
**WHEN** `#10` 订阅
**THEN** `#10` ≤1 帧触发 `EVENT.KPI.FIRED_DISMISSAL`;`#9` 不持有 `#10` 引用(单向);同月重复 emit 去重(幂等)
*Cite: I-4 / Rule 5 / `#10 GDD propagation #1`*

**AC-COMPAT-05** `MVP` `#16` breakdown 数据格式契约
**GIVEN** `get_month_end_breakdown()` 返回字典
**WHEN** `#16` 调用渲染三维度
**THEN** 字典含 `{effort/potential/tenure_contribution_pct, total_pct, new_threshold, prev_threshold, game_over: bool}`;缺失字段 fallback 显示"数据加载中"不 crash;类型 float(pct)+ int(threshold)
*Cite: KPI research §8.1 / Rule 10 / I-7*

### AC-ROBUST(对应 R-KPI-1..5 + 8 失败模式)

**AC-ROBUST-01** `MVP` `R-KPI-1` 努力反噬 α>0.06 不可生产
**GIVEN** `KPI_EFFORT_WEIGHT=α` 在 `config/kpi_balance.tres`
**WHEN** KpiSystem 加载 config
**THEN** α>0.06 触发 `kpi_config_warning` + DEBUG assert + 生产 build 拒加载或回退默认 0.04;防失败模式 #1
*Cite: Tuning Knob α [0.03, 0.06] / R-KPI-1 / KPI research §5 #1*

**AC-ROBUST-02** `MVP` `R-KPI-2` 工龄惩罚 γ<0.010 不可生产 + M1 涨幅 ≤ 3%
**GIVEN** `KPI_TENURE_WEIGHT=γ`
**WHEN** 加载 config + M1 标准玩家结算
**THEN** γ<0.010 触发 config_warning;M1 涨幅 ≤ 3%(R-KPI-2 + 失败 #4 双重守);playtest >10% session 活过 M18 → γ 不足 signal
*Cite: R-KPI-2 / KPI research §5 #2 + #4 / Tuning Knob γ [0.010, 0.018]*

**AC-ROBUST-03** `MVP` `R-KPI-3` capacity_factor floor 守门 — capacity 不归零
**GIVEN** m=100(极端工龄)+ floor=0.4
**WHEN** F3 计算
**THEN** capacity_factor ≥ 0.4(floor 永久);capacity_now ≥ 40(不归零);防数学异常路径(R-AP-5 跨 GDD 同等)
*Cite: F3 / R-KPI-3 同 R-AP-5 / Tuning Knob CAPACITY_FLOOR*

**AC-ROBUST-04** `MVP` `R-KPI-4` GAME OVER race UI 一致性 + 第 3 月断崖
**GIVEN** Formula B 保守 + standard 前 3 月
**WHEN** 计算 M3 next_threshold 涨幅
**THEN** 涨幅 ≤ 15%(M3 绝对上限);任意参数标准玩家单月 ≤ 50%(失败 #3 防);`kpi_threshold_changed` 必须先于 `game_over_triggered` emit(R-KPI-4 顺序守门)
*Cite: R-KPI-4 / KPI research §5 #3 / Rule 9 / 数学约束 C5*

**AC-ROBUST-05** `Beta` `R-KPI-5` 躺平开除 + effort 权重 propagation
**GIVEN** potential < `KPI_POTENTIAL_CLAMP_MIN = -0.15`
**WHEN** 月末检测 + F6 校验
**THEN** 立即 emit `dismissal_triggered` 跳过 F1;`#7` `#9` 共享 `config/kpi_balance.tres` 权重(0.45/0.20/0.30 一致);F6 校验失败时本地重算;playtest 躺平 session 平均寿命 ≤ M10
*Cite: R-KPI-5 / KPI research §5 #8 / Tuning Knob CLAMP_MIN / F6 校验*

### AC-TONE

**AC-TONE-01** `Beta` 月末三维度独立显示(KPI research §8.1)
**GIVEN** 月末进入 `#16` KPI Review UI
**WHEN** 玩家查看本月结算
**THEN** 必须三行独立(努力 +X% / 潜力 +X% / 工龄 +X%),每行带 HR 戏谑注释 Localization key (`KPI.BREAKDOWN.EFFORT_LABEL_BUREAUCRATIC` 等);**禁**只显示"合计 +X%"单行(违反 §8.1 透明度)
*Cite: KPI research §8.1 / Rule 10 / Pillar P4*

**AC-TONE-02** `MVP` 戏谑 HR 口吻 lint
**GIVEN** Localization CSV 中 `KPI.*` / `EFFORT.*` / `TENURE.*` keys
**WHEN** `subject_inversion_lint.py --domain KPI,EFFORT,TENURE` CI 运行
**THEN** 零命中 anti-P1 励志("加油"/"你能做到"/"再努力一下");零命中 anti-P2 绝望("毫无意义"/"必然失败");HR 戏谑词("积极性可嘉"/"还有上升空间"/"资深员工的责任")覆盖三维度注释 100%
*Cite: KPI research §8.1 / Pillar P4 守 / Rule 14*

**AC-TONE-03** `Beta` 新手 M1 "笑而不骂" playtest
**GIVEN** 新玩家首次 M1 月末结算 + 标准玩家涨幅 2.0%(AC-FUNC-04 已验证)
**WHEN** 小组 playtest(n≥5),记录玩家反应
**THEN** ≥80% 玩家"理解/顿悟/轻松笑";1-2 小时留存 ≥60%;observer 填 `production/qa/evidence/kpi-tone-novice-playtest-[date].md`
*Cite: KPI research §6.1 / §5 失败 #4*

**AC-TONE-04** `Beta` 老 NPC 预言月末 -2 天叙事触发
**GIVEN** 老 NPC(wise_veteran flag)在月末倒数第 2 天 + 4 档触发条件之一
**WHEN** `#10` 查询 `query_veteran_npc_hint_condition()` 触发台词
**THEN** 玩家 playtest 中能在结算前看到老 NPC 预言;台词匹配当前参数(effort/potential/tenure 4 档);observer 记录"教学功效评分"(玩家是否注意到台词与结算因果关联)
*Cite: KPI research §8.2 / Rule 11 / I-4*

---

### Tier 分级

| Tier | 数量 |
|------|------|
| MVP 必测 | 22 |
| Beta(playtest 类) | 8 |

### 8 失败模式索引

| 失败模式 | AC | Tier |
|---------|-----|------|
| #1 努力反噬过狠 | AC-ROBUST-01 | MVP |
| #2 工龄惩罚不足 | AC-ROBUST-02 | MVP |
| #3 第 3 月断崖 | AC-ROBUST-04 | MVP |
| #4 新手骂娘 | AC-FUNC-04 + AC-TONE-03 | MVP + Beta |
| #5 潜力陷阱不明显(倒 U)| AC-FUNC-02 | MVP |
| #6 后期通胀爆炸 | AC-ROBUST-03 | MVP |
| #7 三维度相关性太高 | AC-FUNC-02(GAME OVER 月差≥2) | MVP |
| #8 躺平无代价 | AC-ROBUST-05 + AC-FUNC-03 | MVP + Beta |

### QA 工具需求

| 工具 | 守门 AC |
|------|---------|
| `KpiSimulator`(Formula B 三 profile × 15 月) | AC-FUNC-01/02/03/08 |
| profile fixture standard/overachiever/slacker | AC-FUNC-01/02/03 |
| M1 新手保护 fixture(γ_effective=0) | AC-FUNC-04 |
| capacity_factor floor fixture | AC-ROBUST-03 / AC-FUNC-08 |
| GAME OVER boundary fixture | AC-FUNC-10 |
| breakdown API fixture | AC-FUNC-11 / AC-COMPAT-05 |
| `subject_inversion_lint.py --domain KPI,EFFORT,TENURE` | AC-TONE-02 |
| config range validator(α/β/γ 安全范围) | AC-ROBUST-01/02 |
| 8 失败模式 playtest 协议 | AC-FUNC-03 / AC-TONE-03 / AC-ROBUST-05 |

## Open Questions

8 OQ-KPI + 5 propagation flags(其中 #1 + #2 已 surface 仲裁)。

**OQ-KPI-01 (Pre-Production /prototype)**: F3 capacity_factor 三 profile 实测 — `KpiSimulator` 仅数学验证,真实玩家行为分布在 (effort, potential) 两维空间的覆盖度需 playtest。Owner: economy-designer + qa-tester。Target: `/prototype core-loop`。
- KPI research §10 AC1 标准玩家第 11±2 月 GAME OVER 实证

**OQ-KPI-02 (Pre-Production)**: M1 新手保护 + α/β/γ 戏剧组 vs 保守组选择。Owner: game-designer + producer。Target: MVP 关卡上限决策时。
- 戏剧组 α=0.06, β=0.22, γ=0.020 逼玩家 3 月内 GAME OVER 体验完整弧线
- 保守组 α=0.04, β=0.18, γ=0.012 仅展示 1/3 弧线

**OQ-KPI-03 (待 `#10 Event Script` GDD)**: 开除剧本(potential < -0.15)文本 + 月末倒计时第 -2 天 NPC 预言台词库。Owner: writer + narrative-director + `#10` 主笔。Target: `/design-system #10`。
- 4 类 hint(EFFORT_HIGH / POTENTIAL_HIGH / TENURE_LONG / TENURE_VETERAN)台词写作

**OQ-KPI-04 (待 `#16` GDD)**: 月末结算 UI 三行透明度 vs P5 90s 一天预算。Owner: ux-designer + `#16` 主笔。Target: `/design-system #16`。
- 三行戏谑 HR 评语 + 离职证明 1500ms transition 是否在 P5 budget 内
- 涨幅预览 UI(VS 阶段)实现细节

**OQ-KPI-05 (待 `#12 Run Meta` GDD)**: GAME OVER 后"活过第 X 集"分数 + HR 评语词条收集机制。Owner: `#12` 主笔。Target: `/design-system #12`。
- C3 锚句"中规中矩的牺牲品"作为 Run Meta 词条收集物

**OQ-KPI-06 (Polish playtest)**: 失败模式 #7 三维度相关性 — 卷王(高 effort + 高 potential)vs 刚达标(中 effort + 0 potential)寿命差实测。Owner: qa-tester。Target: Polish 阶段。
- AC-FUNC-02 寿命差 ≥ 2 月数学验证 + playtest 实证

**OQ-KPI-07 (野心版 ADR)**: Formula C 指数工龄是否启用 + `KPI_EXP_K = 0.12` 实测。Owner: systems-designer + game-designer。Target: 野心版 24+ 月关卡。
- 完整版 24 集叙事弧线是否需要"前期稳后期雪崩"指数曲线

**OQ-KPI-08 (野心版 ADR)**: CAPACITY_FLOOR=0 启用 + HUD 预警机制配合。Owner: ux-designer + `#13` 主笔。Target: 野心版完整版。
- 60 月数学不可达域的玩家 agency 设计(HUD 预警从何月开始 / 预警语义)

### 5 propagation flags 状态

| Flag # | 待 GDD | 状态 | OQ |
|--------|--------|------|-----|
| #1 effort 三维权重 | `#7 → #9 已仲裁采纳 0.45/0.20/0.30` | ✅ 已锁 | — |
| #2 CAPACITY_FLOOR | MVP=0.4 / 野心版=0 已锁 | ✅ 已锁 | OQ-KPI-08 |
| #3 `#10` 开除剧本 + 老 NPC 预言台词库 | 待 `#10` | ⏳ | OQ-KPI-03 |
| #4 `#16` 月末结算 UI 三行渲染 | 待 `#16` | ⏳ | OQ-KPI-04 |
| #5 `#12 Run Meta` HR 评语词条收集 | 待 `#12` | ⏳ | OQ-KPI-05 |

### OQ-impacted AC

| OQ | 影响 AC |
|----|---------|
| OQ-KPI-01 | AC-FUNC-01/02 实证 |
| OQ-KPI-02 | AC-FUNC-04(M1 涨幅取决于参数组) |
| OQ-KPI-03 | AC-COMPAT-04 / AC-TONE-04 |
| OQ-KPI-04 | AC-COMPAT-05 / AC-TONE-01 |
| OQ-KPI-05 | AC-FUNC-10(Run Meta 寿命记录) |
| OQ-KPI-06 | AC-FUNC-02 倒 U 实测 |
| OQ-KPI-07 | F1 + Tuning Knob KPI_FORMULA_VARIANT |
| OQ-KPI-08 | AC-ROBUST-03(若 floor=0)|
