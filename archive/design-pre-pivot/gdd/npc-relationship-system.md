# NPC Relationship System

> **Status**: Designed (pending review)
> **Author**: huanghaibin + creative-director (Section B framings)+ game-designer (Section C 14 Core Rules 主笔)+ narrative-director (8 NPC profiles)+ systems-designer (Section C/D/E 状态机+公式+24 edges)+ qa-lead (Section H 26 AC)
> **Authoring autonomy mode**: v2 no-prompt(0 widget,5 specialist parallel + game-designer 直接写 Section C 至文件)
> **Last Updated**: 2026-04-26
> **Layer**: Core | **Order**: #8 | **Size**: M
> **Implements Pillar**: P2 主(叙事即机制 — NPC 是有血有肉的人,不是数据点)+ P1 守(关系不可成"刷满 = 永久优势")+ P3 守(关系也走向解散 / 离职 / 调岗)+ P4 守(NPC 不是励志伙伴,是各有算计的工位邻居)

## Overview

**NPC Relationship System** 是《活过第 X 集》Pillar 2 "叙事即机制"的核心载体 —— 8 个 MVP NPC(Lisa / 老板 / 清洁阿姨 / 卷王 / 摸鱼族 / 谄媚族 / 老油条 / 新人)各自携带 `relationship_score: int [-100, +100]` + per-NPC `flags: Dict[String, bool]` + `lifecycle_state: ACTIVE | LEAVING_ANNOUNCED | LEFT | RETURNED`。每个数值变化都包剧本(由 `#10 Event Script Engine` own 文本) — 没有"关系 +5"的孤立 toast,只有"Lisa 转过头说了句话"的具体场景。

### 双重身份

**技术层**: NPC Relationship 是 8 个固定 NPC 的关系数值 + flag + lifecycle 持久化 owner。emit `relationship_changed(npc, delta, new_score, reason)` / `npc_left_company(npc, reason)` / `npc_returned(npc)`(VS) 信号给下游订阅。提供 `update_relationship(npc, delta, reason)` API 给 `#11 Action Card` + `#10 Event Script` 调用。月末 `KPI_REVIEW` 时由 `#6` 触发 NPC 离职检查(F3 leave_probability 公式)。

**叙事层**: 玩家感受到的不是 8 个数字,是 8 个有算计、有恐惧、有去向的工位邻居。Lisa 在某月会真的跳槽,卷王晋升后再也不和你共午饭,清洁阿姨儿子终于考上大学但她随后退休,老板 PUA 不停但你逐渐学会读他的心理模型。**NPC 也走向 GAME OVER** — 不是玩家 die,是关系 die。

### Pillar 服务

- **P2 主 叙事即机制**: 没有孤立数值,所有 `relationship_changed` 都伴随 `#10` event 文本;flag 触发的 unlock 是"和 Lisa 喝奶茶"具体卡而非"Lisa 关系满分解锁特殊技能"
- **P1 守 平庸是艺术**: 关系**不可解锁永久 buff** — `relationship_score >= 60` 仅解锁特定 `#10` 事件分支 / 特定 `#11` 卡解锁,**不**给玩家全局加成。**Anti-Pillar 1 红线**: 禁"Lisa 关系满级 +20% AP"类设计
- **P3 守 死亡是注定的**: NPC 离职 / 调岗 / 被裁是**不可逆**的(MVP);关系 LEFT 后 score 保留作为追忆但无法互动。F3 `leave_probability(npc, m, ...)` 数学保证多数 NPC 在 12 月内有一次离开
- **P4 守 苦中作乐黑色幽默**: NPC 无"友谊+1"语义,只有 NPC 评价(中性)。Lisa 不是恋爱对象,老板不是反派 boss。所有 NPC 文案禁"喜欢/讨厌玩家"(主语翻转 — 由 NPC 行为体现而非玩家可见量化好感)

### 5 NOT 边界(scope creep 防护)

- **NOT** NPC 文本剧本 / 对白(由 `#10 Event Script` + writer own,#8 仅 own score 数值 + flag)
- **NOT** NPC 视觉立绘 / 动画(由 `#13 HUD Diegetic` 在工位场景渲染 — NPC 表情 / 站位作为 diegetic 视觉)
- **NOT** NPC 之间的关系网(MVP 简化为单维 `npc → score`,**不**建模 NPC-to-NPC rivalry / 派系;野心版 VS 引入)
- **NOT** 行动卡逻辑(`#11 Action Card` own,卡触发 NPC 事件时调 `#8 update_relationship` API)
- **NOT** 关系数值导致的 KPI 影响(`#9 KPI System` 不消费 NPC score;NPC 仅通过 `#10` 事件触发 `#11` 卡 → 间接影响 effort)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 关系数值解锁永久全局 buff / 永久 stat +(违反 Anti-Pillar 1 + P1)
- **NOT** "友谊"/"恋爱"语义(违反 P4 — NPC 不是浪漫对象,是工位邻居)
- **NOT** "通过 NPC 关系绕过反向 KPI"路径(关系不可成为 KPI 解药)
- **NOT** NPC 离职可逆(违反 P3;VS 才允许 RETURNED)
- **NOT** NPC 数据驱动玩家"完成度 / 收集"语义(违反 Pillar 1 — NPC 不是 Pokémon)

### Source 引用

`game-concept.md` Core Mechanics §L82-88 NPC 关系网 + Pillars §L162-191 P1/P2/P3/P4 + Inspiration §L203-218(《大多数》/ 破事精英 NPC 群像参考)。`save-system.md` Rule 7 autosave + Rule 13 snapshot_id 单调 + Rule 22 content-only unlocks(meta.unlocks 禁机械成长)。`scene-day-flow-controller.md` Rule 9 game-time tick + Rule 10 月末触发 + Section A 8 sub-mode enum。`ap-economy-system.md` I-7 零直接交互(由 `#11` 桥接)。

## Player Fantasy

### 主锚: "和你混熟的同事都走了,你还在"

**场景**:
你入职那年带你的师傅,3 年前跳槽了;隔壁组的小王,去年被开了;一起抽烟的老赵,上个月去了竞争对手那;Lisa 上周面试通过了。你坐在工位上,环顾四周,认识的脸都换了一遍 —— 你成了那个"老员工"。周一晨会,新人介绍自己叫陈璐,"以后请多关照"——你笑着点头,突然意识到 7 年前你也说过这句话,那个对你点头的人去年也走了。

**Pillar 服务**:
- **主 P2 叙事即机制**: NPC 关系网不只是横切面(此刻和谁好),是**纵向时间感** —— 关系网在玩家眼前被反复重置,但玩家留下来。本系统机制设计目的是把 Pillar 2 推到时间维度
- **守 P3 死亡是注定的**: **关系不可逆**的极致表达 —— 不止是 GAME OVER 时 NPC 散,而是**游戏每一刻都在散**。关系网是不断流失的池子
- **守 P1 平庸是艺术**: 玩家"混熟"任何人都没有永久优势 —— 因为他们都会走,而工龄越长 KPI 阈值越高。**留下来本身就是惩罚**
- **守 P4 苦中作乐**: 每个走的人都有自己的算计(跳槽/被开/家庭),没有一个走的人是"为了主角"走的

**跨 GDD negative space 联动**(本锚是工龄惩罚铁三角的关系系统侧):
- **AP Economy** "用空了" 共振: 玩家今天用 1 AP 想找人聊天 → 发现没人能聊。AP 购买力随关系网流失而缩水
- **Save** "下班打卡机一声嘀" 共振: 同事离职那天的下班打卡音是空的(没人说"再见") — 节奏型留白
- **Lighting** "再苟一天" 共振: 工位氛围逐月变冷,旁边空工位增加(累积视觉 4 维度直接受 NPC 离职驱动)
- **Scene & Day Flow** "周一 9:17" 共振: 新人介绍那一刻,玩家感受到 7 年前自己也站在这位置 — 主语翻转(时间推过去)
- **`#9 KPI` 工龄惩罚**: 关系网衰减驱动工龄惩罚加速 — 关系系统衰减是 KPI 系统恶化的间接油门

**❌ Tone 风险(必避)**:
- "孤独的老兵 / 资深员工的智慧"(滑向悲情史诗 / 英雄叙事,违反 P4 + 反英雄红线)
- "你已活过第 24 集 / 老员工成就解锁"(把工龄包装成 mastery 标签,违反 P3)
- "你已认识 47 位 NPC,其中 31 位已离职"(Stardew 式收集表 UI,毁 tone)
- 离职 NPC 在任何 UI 列表里被"纪念"(他们就这么没了)

**✅ Tone 守护(推荐)**:
- "认识的脸都换了"、"工位上的水杯越来越多没人倒"(无主语 / 物的主语)
- "活化石"反讽词(老板嘴里的"夸奖")
- "他们走的时候不打招呼"(被动态)

### 副锚: "Lisa 又要跳槽了"

**场景**:
Lisa 凑过来压低声音说"我猎头那边明天面试,你别和老板讲啊"—— 你点头,心里算了一下:她要真走,你下季度的协作 KPI 就要多扛一个人的量。周三下午 3:47,工位隔板上方半张脸压过来,微信震动两下"晚上一起吃饭?"——你知道她不是想吃饭,是想试探你站队。

**Pillar 服务**:
- **主 P2 叙事即机制**: Lisa 的算计直接长在数值上 — 她跳槽倾向 = 一个会变化的隐藏数值,但玩家感受到的是"她最近怪怪的"而不是"信任度 -3"
- **守 P4 黑色幽默**: Lisa 不是闺蜜不是盟友,是一个**和你一样在算计的人**。她想跳槽的 motive 是真实的(房贷/男朋友/她妈病了),不是 NPC 工具属性
- **守 P1 平庸是艺术**: Lisa 高关系不解锁"永久协助",反而让她跳槽时玩家承担更多 KPI — 关系是甜头即毒药

**跨 GDD negative space 联动**:
- **AP Economy** 8 格凑合用 共振: 1 AP "陪 Lisa 抽烟听吐槽" 不是社交按钮 — 是**情报投入** → 影响她跳槽决策点 → 影响 KPI 工作量 → 回到 8 格凑合用
- **Save** "下班打卡机": Lisa 走的那天周五下班打卡时弹一句"她工位今天空了" — 与"下班打卡机"语法一致
- **Scene & Day Flow** "月末像降温": Lisa 跳槽征兆从月初到月末逐渐密集,不是单点事件

**❌ Tone 风险(必避)**:
- "修复 Lisa" 语义(玩家把她当 quest giver,劝住她就赢)
- Persona confidant 模式(Lisa 高关系 = 解锁能力 — 违反 Anti-Pillar 1)
- "Lisa 哭着说她不想走"(苦情,破朋友圈测试)

**✅ Tone 守护(推荐)**:
- Lisa 跳槽决策**不受玩家控制**(她的 motive 是她自己的)
- 玩家最多能"知道她什么时候走"(信息优势),不能"留住她"
- 文本永远是博弈而非友情:"她说'你是好人'的时候,你应该警惕,不该感动"

### Sub-Framing(Pillar 2 极致表达): "清洁阿姨儿子考上了,但她还是要走"

清洁阿姨整个人物弧 = 一段微叙事,**没有任何数值上的 game effect**(她不影响 KPI/AP/老板关系) — 但她占用 Pillar 2 的全部表达力。这是 Pillar 2 的极致:**还有一种边缘人物,她整个人就是剧本本身**。

她的剧本必须保持"她自己的视角" — 她不是为玩家而存在的 NPC。她离职那天**不弹特殊 UI**,只是周一早上玩家发现没人倒水了。无 BGM。环境音照旧。Lighting "我的桌子怎么这么脏" 在她走后真的开始发生(累积视觉环境叙事)。

**这是 Pillar 2 设计参考标准** —— 写下游 GDD(`#10` 事件 / `#11` 卡 / `#15` 周报)时,问"我这个 NPC 互动是数值驱动的还是清洁阿姨标准?",目标至少 1-2 个 NPC 能写到清洁阿姨的标准。

### Internal Design Test: NPC 算计原则

每张 NPC 互动卡 / 事件文本审校时,问一个问题:**"这个 NPC 的行为是为了她自己,还是为了玩家?"**

- 如果 NPC 的行为/对白让玩家觉得"她在帮我 / 她对我好"(主语 = NPC 利他)→ 改写
- 如果 NPC 的行为/对白让玩家觉得"她在算计 / 她有自己的考虑"(主语 = NPC 算计)→ 通过

**正例**: Lisa "我猎头那边明天面试,你别和老板讲啊"(她在用你做信息屏障,不是分享喜悦)
**反例**: Lisa "我相信你能搞定下季度!"(励志支持型,违反 P4 + 反英雄红线)

### 红线汇总

- 任何"NPC 关系满级永久 buff"= **PR-blocking**(违反 Anti-Pillar 1)
- 任何"NPC 收集列表 UI"= PR-blocking(违反 Pillar 4)
- 任何"NPC 友谊/恋爱 + 进度条"= PR-blocking(违反 P4)
- 任何"NPC 离开后玩家可挽留"= PR-blocking(违反 P3)
- 任何 NPC 行为以"为玩家好"为唯一动机 = Code Review BLOCKING(违反 P4 + Internal Design Test)

### Source 引用

`creative-director` Section B consultation(2026-04-26)+ `game-concept.md` Pillars(P1/P2/P3/P4)+ Anti-Pillar 1 + 7 GDD Player Fantasy negative space 铁三角四轨延续。Internal Design Test 原则源自 Scene & Day Flow Section B "主语翻转" + AP Economy Section B "反英雄红线" 同源。

## Detailed Design

### Core Rules

**Rule 1: NPC Identity Enum(MVP 8 固定身份)**

MVP 阶段共 8 个固定 NPC,用 `NpcId` enum 标识。枚举值是全局 source of truth;任何 GDD 引用 NPC 必须使用此 enum 字面值。

```gdscript
enum NpcId {
  LISA,           # 同事/闺蜜型,真跳槽候选(P3 守 — 关系也走向解散)
  BOSS,           # 直属上司,反向 KPI 核心施压者
  CLEANING_AUNT,  # 清洁阿姨,旁观者/情报员
  GRIND_KING,     # 卷王,晋升候选
  FISH_MONK,      # 摸鱼族,被裁候选
  FLATTERER,      # 谄媚族,老板侧近
  OLD_OIL,        # 老油条,信息经纪人
  NEWBIE          # 新人,初期教学锚
}
```

每个 `NpcId` 对应一个 `NpcProfile` resource(定义 `initial_score` / `initial_flags` / `departure_archetype`)。MVP 单部门;VS 扩 `HR` / `CLIENT` 两个新 NpcId。`NpcProfile` 不可在运行时增删枚举成员。

---

**Rule 2: 关系数值(relationship_score)**

每个 NPC 维护独立整数 `relationship_score: int`,范围 **[-100, +100]**。

- 初始值由 `NpcProfile.initial_score` 定义;各 NPC 出厂默认不同(见 Tuning Knobs)
- 不存在全局"玩家关系等级" — 关系是 **per-NPC** 的,8 个 NPC 各自独立
- score 不随时间自动衰减(MVP 无衰减;VS 引入"30 天不互动 -10"规则,见 Rule 14 Scope Tier)
- `relationship_score` 本身**不**直接解锁任何永久数值 buff(Pillar 1 守门);它只作为 `#10` / `#11` 的查询条件,触发剧本内容 unlock

**Save 依赖**: `relationship_score` 纳入 `current_run.save` 序列化(见 Rule 13)。Save Rule 7 autosave 在行动卡 execute 完成后自动触发快照。

---

**Rule 3: 关系阶段(Relationship Phase Enum)**

`relationship_score` 映射到 4 个阶段,驱动 `#13 HUD` 视觉状态 + `#10` 事件解锁条件:

```gdscript
enum RelationshipPhase {
  HOSTILE,   # [-100, -30)
  NEUTRAL,   # [-30,  +30)  — 默认初始阶段
  WARM,      # [+30,  +70)
  CLOSE      # [+70, +100]
}
```

| Phase | Score 区间 | #13 HUD 站位/表情 | 语义 |
|-------|------------|-------------------|------|
| `HOSTILE` | [-100, -30) | 背对工位 / 冷漠表情 | 敌对 |
| `NEUTRAL` | [-30, +30) | 正常站位 / 无表情 | 中性(初始) |
| `WARM` | [+30, +70) | 侧身望 / 轻微正向 | 温和 |
| `CLOSE` | [+70, +100] | 靠近工位 / 轻微点头 | 亲近 |

**phase 变更规则**: 仅当 score 跨越阶段阈值时 emit `relationship_phase_changed(npc_id, old_phase, new_phase)`;在同一 phase 内变动不额外 emit。`relationship_phase` 冗余存储于 Save(避免阈值迁移 edge case)。

---

**Rule 4: Flag 系统(per-NPC bool flags)**

每个 NPC 维护 `flags: Dictionary[String, bool]`。Flag 是 **`#10 Event Script`** 和 **`#11 Action Card`** 通过 API 写入的剧本状态标记;`#8` 只负责存储、查询、序列化。

API:

```gdscript
func set_npc_flag(npc_id: NpcId, key: String, value: bool) -> void
func get_npc_flag(npc_id: NpcId, key: String) -> bool  # 不存在 key 返回 false
```

Flag key 命名规范: `"{npc_id_lowercase}_{event_context}"`,全小写下划线。例:
- `"lisa_coffee_unlocked"` — Lisa 奶茶事件满足后由 `#10` 写入
- `"boss_warned_once"` — 老板首次警告已发生
- `"newbie_mentored"` — 新人被辅导过

**`#8` 不自主生成 flag** — 它不能在内部 timer 或信号回调中自己写 flag;只有外部 API 调用。写入后 emit `npc_flag_changed(npc_id, key, value)` 供 `#10` 订阅。

---

**Rule 5: 关系变化协议(update_relationship API)**

修改 `relationship_score` 的**唯一入口**:

```gdscript
func update_relationship(npc_id: NpcId, delta: int, reason: String) -> void
```

- **调用方**: `#11 Action Card`(卡触发时)+ `#10 Event Script`(事件脚本 step)
- **delta 单次上限**: [-20, +20]。超出范围 clamp 并 `push_warning("[NPC#8] delta clamped: {reason}")`
- **reason**: 日志标识符(如 `"card:overtime_chat"`, `"event:lisa_birthday"`)。必须以 NPC lowercase id 前缀开头,如 `"lisa_*"` / `"boss_*"`,供 Lint 测试 + GAME OVER Run 摘要使用

**后置逻辑(按序执行)**:
1. 将 `relationship_score` clamp 至 [-100, +100]
2. 计算新 `RelationshipPhase`;若跨越阈值 → emit `relationship_phase_changed(npc_id, old_phase, new_phase)`
3. emit `relationship_changed(npc_id, old_score, new_score, reason)`
4. 写 audit log entry(`reason` + `delta` + `game_day` + `snapshot_id`)

**禁止路径**: `#8` 内部不可自主调用 `update_relationship`(无 timer 触发 / 无内部事件触发);所有 score 变化必须经由 `#11` 或 `#10` 外部调用。

---

**Rule 6: 关系阈值 Unlock(#10/#11 own 条件,#8 仅供查询)**

`relationship_score` 和 `flags` 可作为 `#10 Event Script` / `#11 Action Card` 的**解锁条件**,但 unlock 逻辑由 `#10` / `#11` 评估;`#8` 只暴露查询 API:

```gdscript
func get_relationship_score(npc_id: NpcId) -> int
func get_relationship_phase(npc_id: NpcId) -> RelationshipPhase
func get_npc_flag(npc_id: NpcId, key: String) -> bool
func is_npc_active(npc_id: NpcId) -> bool  # lifecycle_state == ACTIVE
```

典型条件示例(由 `#10` 脚本 own,非 `#8` 逻辑):
- `get_relationship_score(LISA) >= 30` → 解锁事件"和 Lisa 喝奶茶"
- `get_npc_flag(BOSS, "warned_once") and get_relationship_score(BOSS) < -20` → 解锁"老板约谈二次"

**Pillar 1 守门(红线)**: unlock 只可触发"剧本内容"(新事件可见 / 新卡解锁 / 新对话分支);**严禁**解锁"AP 上限+1 / KPI 阈值永久豁免 / 任何数值 buff"。违反即 Anti-Pillar 1 红线 — 关系系统不可成为养成系统。

---

**Rule 7: NPC 生命周期状态机(Lifecycle State)**

每个 NPC 有独立生命周期态,初始为 `ACTIVE`:

```gdscript
enum NpcLifecycleState {
  ACTIVE,             # 在职,可互动
  LEAVING_ANNOUNCED,  # 离职/调岗已预告,当月最后可互动
  LEFT,               # 已离职,不可互动,数据保留
  RETURNED            # VS scope — MVP 保留 enum 占位,不实现
}
```

**转移规则**:

| 转移 | 触发者 | API |
|------|--------|-----|
| `ACTIVE → LEAVING_ANNOUNCED` | `#10 Event Script` 专属 | `announce_npc_leaving(npc_id, reason: String)` |
| `LEAVING_ANNOUNCED → LEFT` | `#6 Scene & Day Flow` 月末结算 | `finalize_npc_departure(npc_id)` → emit `npc_left_company` |
| `LEFT → RETURNED` | VS scope,预留 | `restore_npc(npc_id)` — MVP 不实现 |

**禁止跳级**: `ACTIVE → LEFT` 禁止(必须经 `LEAVING_ANNOUNCED` 给玩家一个月窗口知情)。`LEFT → ACTIVE` / `LEFT → LEAVING_ANNOUNCED` 禁止(已离职不可直接回退)。

`lifecycle_state` 持久化于 Save `current_run.save`(见 Rule 13)。

---

**Rule 8: 离职/晋升原型事件(MVP 触发契约)**

`#8` 提供 API;触发**条件**由 `#10 Event Script` own。MVP 3 个内置原型:

| NPC | 原型 | 触发条件(#10 own) | reason 标识符 |
|-----|------|-------------------|--------------|
| `LISA` | 真跳槽 | KPI 月均超阈值 + `get_relationship_score(LISA) < -10` | `"lisa_quit_better_offer"` |
| `GRIND_KING` | 晋升调岗 | 连续 N 月加班 flag(由 #10 per KPI 月末脚本) | `"grind_king_promoted"` |
| `FISH_MONK` | 被裁员 | 特定月份老板事件触发 flag | `"fish_monk_layoff"` |

离职后该 NPC 的 `relationship_score` / `flags` / `is_active=false` **保留在 Save**(历史快照),供 GAME OVER Run 摘要使用("Lisa 第 3 集跳槽了")。

`npc_promoted` 信号单独 emit(晋升调岗语义不同于"离职")。

---

**Rule 9: NPC 间关系(MVP 简化)**

MVP 不建模 NPC-NPC 双边关系网络。NPC 间的对立/派系动态由 `#10 Event Script` 通过 NPC flag 隐式模拟(如 `boss_vs_grind_king_conflict=true`)。`#8` 只管理**玩家 ↔ NPC** 的单向 `relationship_score`。

VS scope 预留: 可引入 `npc_pair_score: Dictionary[String, int]`(key = `"{npcA}_{npcB}"` 字母序),但 MVP 完全不实现、不注册。

---

**Rule 10: 信号架构**

`#8` emit 的信号(只 emit,不 dispatch 给自己):

| Signal | 参数签名 | 主要订阅方 |
|--------|---------|----------|
| `relationship_changed` | `(npc_id: NpcId, old_score: int, new_score: int, reason: String)` | `#13 HUD`, `#10 Event Script` |
| `relationship_phase_changed` | `(npc_id: NpcId, old_phase: RelationshipPhase, new_phase: RelationshipPhase)` | `#13 HUD` |
| `npc_left_company` | `(npc_id: NpcId, reason: String)` | `#10 Event Script`, `#13 HUD`, `#16 KPI Review UI`, Save |
| `npc_promoted` | `(npc_id: NpcId)` | `#10 Event Script`, `#13 HUD` |
| `npc_flag_changed` | `(npc_id: NpcId, key: String, value: bool)` | `#10 Event Script` |

`#8` 订阅的信号:

| 来源 | Signal | 处理 |
|------|--------|------|
| `#6 Scene & Day Flow` | `scene_state_changed(KPI_REVIEW)` | 遍历所有 `LEAVING_ANNOUNCED` NPC → 依次调 `finalize_npc_departure()` 转 `LEFT` + emit `npc_left_company` |

`#8` **不订阅** `MORNING_BRIEFING`(那是 `#10 Event Script` 的 NPC 事件入口)。

---

**Rule 11: 主语翻转文案守门(配 #6 Rule 14)**

所有 `relationship_changed` 信号的 `reason` 字符串和 `#13 HUD` / `#16 UI` 渲染文案,必须以 **NPC 为主语**:

**禁止语义**: "你和 Lisa 的关系 +5" / "友谊加深" / "好感度 UP" / "关系升级"
**允许语义**: "Lisa 觉得你今天还不错" / "老板注意到你的周报" / "摸鱼族好像更放松了"

**执法机制**:
1. `reason` 字符串强制以 `"{npc_id_lowercase}_"` 前缀开头(如 `"lisa_*"`, `"boss_*"`);`update_relationship` 收到不符规范的 reason 时 `push_warning` + 写 audit log
2. `#13 HUD` 渲染层不得将 `new_score - old_score` 展示为"+X 好感"类正向数字 — 只可展示"[NpcName]的评价变动"中性文本
3. Lint AC-TONE 测试(见 Acceptance Criteria)扫描 GDD 文档 + `reason` 字符串命名合规

**文案对照**:
- ❌ "和 Lisa 的友谊+5"
- ✅ "Lisa 觉得你今天帮了她一把。"
- ❌ "老板好感度 -10"
- ✅ "老板好像对你这周的周报不太满意。"

---

**Rule 12: NPC 视觉表达约定(diegetic 工位场景,委托 #13 HUD)**

NPC 关系状态通过工位场景内的 **diegetic 视觉元素**表达;`#8` 不 own 渲染逻辑,委托 `#13 HUD` 响应信号:

| 状态 | #13 HUD 视觉行为 |
|------|-----------------|
| `HOSTILE` phase | NPC sprite 背对主角工位 / 无眼神交流 |
| `NEUTRAL` phase | NPC sprite 正常站位 / 面向屏幕 |
| `WARM` phase | NPC sprite 侧身望向主角工位 |
| `CLOSE` phase | NPC sprite 靠近主角工位 / 轻微点头 |
| `LEAVING_ANNOUNCED` | NPC sprite 叠加"收纸箱"视觉层(由 #13 own 资产) |
| `LEFT` | NPC 工位变为空桌(sprite 移除,桌面 prop 变"已清空"贴图) |

约束:
- NPC **不离开工位**区域(位置锚定 diegetic 环境;禁浮动气泡 / 全屏特写)
- 关系变化不配专属 SFX / BGM 切换(Pillar 4 守门;参见 Audio Manager Pillar 4 红线)
- `#13 HUD` 必须实现两个回调 slot: `_on_relationship_phase_changed(npc_id, old_phase, new_phase)` + `_on_npc_left_company(npc_id, reason)`

---

**Rule 13: Save 持久化协议**

每个 NPC 序列化 schema(存入 `current_run.save`;纳入 `current_schema_version=1`,见 entities.yaml):

```json
{
  "npc_id": "LISA",
  "relationship_score": 42,
  "relationship_phase": "WARM",
  "lifecycle_state": "ACTIVE",
  "is_active": true,
  "flags": {
    "lisa_coffee_unlocked": true,
    "lisa_quit_warned": false
  }
}
```

- `relationship_phase` 冗余存储(可从 score 推算,但存储防阈值迁移 edge case)
- `is_active` 便捷字段(= `lifecycle_state != LEFT`),供快速查询
- `LEFT` NPC 保留全记录(`is_active=false`),**不删除**(供 GAME OVER Run 摘要 + 历代档案展示)
- Save Rule 13 `snapshot_id` 单调约束适用:每次 `update_relationship` 后 autosave 分配新 snapshot_id

---

**Rule 14: Scope Tier 守门**

| Feature | Tier |
|---------|------|
| 8 NPC MVP 固定 enum | MVP |
| `relationship_score` [-100,+100] + 4 phase | MVP |
| Flag 系统(per-NPC Dictionary) | MVP |
| `update_relationship` API + delta clamp | MVP |
| NPC 生命周期 3 态(ACTIVE / LEAVING_ANNOUNCED / LEFT) | MVP |
| 5 信号(relationship_changed / phase_changed / npc_left / npc_promoted / flag_changed) | MVP |
| 关系阈值 unlock(#10/#11 own 条件) | MVP |
| 主语翻转文案守门 + Lint AC | MVP |
| diegetic 视觉表达(委托 #13;NPC 不离工位) | MVP |
| Save 持久化(score + flags + lifecycle_state) | MVP |
| 关系衰减(30 天不互动 -10) | VS |
| NPC-NPC 网络(`npc_pair_score`) | VS |
| `RETURNED` 生命周期态 | VS |
| HR / CLIENT NPC 扩展 | VS |
| NPC 配音 | Alpha |

---

### States and Transitions

#### NPC 生命周期状态转移(每 NPC 独立实例)

```
                announce_npc_leaving()
[ACTIVE] ──────────────────────────────→ [LEAVING_ANNOUNCED]
                (仅 #10 调用)                        │
                                                     │ finalize_npc_departure()
                                                     │ (月末 KPI_REVIEW — #6 触发)
                                                     ↓
                restore_npc() [VS]              [LEFT]
[RETURNED] ←───────────────────────────────────────
```

**禁止转移**:
- `ACTIVE → LEFT`(跳级禁止 — 必须让玩家知情一个月)
- `LEFT → ACTIVE`(已离职不可无痕重置)
- `LEFT → LEAVING_ANNOUNCED`(已离职不可重新预告)
- 任何系统直接写 `lifecycle_state`(只有 `#8` 内部 API 可变更;外部调用 `announce_npc_leaving` / `finalize_npc_departure`)

#### 关系阶段转移(score 驱动,双向)

```
        score < -30          score >= -30       score >= +30       score >= +70
[HOSTILE] ◄──────────────► [NEUTRAL] ◄───────────────► [WARM] ◄──────────────► [CLOSE]
  [-100, -30)                [-30, +30)                [+30, +70)              [+70,+100]
```

- 非相邻阶段可直接穿越(如 score 从 +80 跌至 -40:CLOSE → NEUTRAL,emit 一次 `relationship_phase_changed`)
- 单次 delta 上限 20,每次 `update_relationship` 调用最多穿越 1 个相邻阈值边界(最窄 phase 区间 = HOSTILE 70 分 / NEUTRAL 60 分 / WARM 40 分,delta=20 不可一次跨越 2 个边界)
- 每次阈值穿越 emit **1 次** `relationship_phase_changed`

---

### Interactions with Other Systems

| # | 系统 | 契约方向 | 契约内容 |
|---|------|---------|---------|
| **I-1** | `#11 Action Card` | `#11 → #8`(写) | 卡触发 NPC 事件时调 `update_relationship(npc_id, delta, reason)` + `set_npc_flag(npc_id, key, value)`;`#8` 不主动联系 `#11` |
| **I-2** | `#10 Event Script Engine` | `#10 ↔ #8`(双向) | `#10` 读 `get_relationship_score / get_npc_flag / is_npc_active`;`#10` 写 `set_npc_flag` + `announce_npc_leaving`;`#8` emit `relationship_changed / npc_flag_changed` 供 `#10` 订阅作为事件触发条件 |
| **I-3** | `#13 HUD (Diegetic)` | `#8 → #13`(单向 emit) | `#8` emit `relationship_changed` / `relationship_phase_changed` / `npc_left_company` / `npc_promoted`;`#13` 负责 diegetic 渲染(表情/站位/收纸箱/空桌);`#8` 不关心 HUD 内部实现 |
| **I-4** | Save System | `#8 → Save`(序列化) | `#8` 提供 `serialize() -> Dictionary` + `deserialize(data: Dictionary)` 接口;Save Rule 7 autosave 在行动卡 execute 后触发;Rule 13 `snapshot_id` 单调约束;`LEFT` NPC 数据保留不删 |
| **I-5** | `#6 Scene & Day Flow` | `#6 → #8`(订阅触发) | `#8` 订阅 `scene_state_changed(KPI_REVIEW)` → 月末遍历 `LEAVING_ANNOUNCED` NPC 依次调 `finalize_npc_departure()`;`#6` 不直接调 `update_relationship` |
| **I-6** | `#16 KPI Review & Game Over UI` | `#8 → #16`(单向 emit) | `npc_left_company(npc_id, reason)` 供 `#16` 在 GAME OVER Run 摘要显示离职记录;`#8` 不 own 摘要格式 |
| **I-7** | `#7 AP Economy System` | 无直接接触 | `#7 AP Economy` 不直接调 `#8`;中间层是 `#11 Action Card`(卡触发时桥接关系变化);`#7 I-7` 规则约定已声明此边界 |

## Formulas

3 公式 F1-F3。

### F1 — `relationship_decay`(VS 启用,MVP N/A stub)

```
decay(npc, month) = -(DECAY_RATE_PER_MONTH × floor(inactive_days / DECAY_TRIGGER_DAYS))
```

clamp 后写入: `relationship_score = clamp(relationship_score + decay, -100, +100)`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `inactive_days` | int | 0–31 | 本月与该 NPC 零互动天数 |
| `DECAY_TRIGGER_DAYS` | int | 1–31,推荐 30 | 触发一次衰减所需的连续不互动天数 |
| `DECAY_RATE_PER_MONTH` | int | 1–20,推荐 10 | 每满一个触发周期 score 减少量 |
| `decay` | int | ≤ 0 | 本月衰减量 |

**Output Range**: `decay ≤ 0`,`relationship_score` clamp 后 ∈ [-100, +100]。**MVP 阶段 `decay` 恒为 0**(接口 stub)。

**Worked Example**(VS 参数): `inactive_days = 31`, `DECAY_TRIGGER_DAYS = 30`, `DECAY_RATE_PER_MONTH = 10` → `decay = -10`。score 25 → 15。

### F2 — `relationship_threshold_check`(MVP 起)

```
is_above_threshold(npc_id, threshold): bool
  = (relationship_score[npc_id] >= threshold)
```

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `npc_id` | NpcId enum | 8 MVP | 被查询 NPC |
| `threshold` | int | -100..+100 | 调用方阈值(通常 phase 边界 -30/0/+30/+60) |
| `result` | bool | — | 是否满足阈值 |

**Output Range**: 纯布尔,无副作用。`#10 Event Script` 主消费者。

**边界精度约定**: `score = 30` 属于 `WARM`(`>=30` 含边界)。全系统统一 `>=` 比较;CI lint 校验 `#10` 所有阈值查询一致性(防 R-NPC-3 Float 比较精度问题 — `relationship_score` 强制 int,杜绝 Float 比较)。

### F3 — `leave_probability`(MVP 起,月末检查)

```
P_leave(npc, month, R, E) = clamp(
    base_rate[npc]
  + time_factor(npc, month)
  + relationship_penalty(R)
  + effort_pressure(npc, E),
  0.0, 1.0
)

time_factor(npc, month) = peak_weight[npc] × bell(month, peak_month[npc], sigma[npc])
relationship_penalty(R) = max(0, -R) × REL_PENALTY_SCALE
effort_pressure(npc, E) = effort_weight[npc] × E
bell(x, μ, σ) = exp(-0.5 × ((x - μ) / σ)²)
```

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `npc` | NpcId | 8 MVP | NPC 标识 |
| `month` | int | 1–12 (MVP 1–3) | 当前游戏月份 |
| `R` | int | -100..+100 | 玩家与该 NPC 当月末 score |
| `E` | float | 0.0–1.0 | 玩家本月 `effort_potential`(由 `#7` AP Economy F4 输入) |
| `base_rate[npc]` | float | 0.0–0.3 | NPC 基础月离职率 |
| `peak_weight[npc]` | float | 0.0–0.8 | NPC 峰值月加成上限 |
| `peak_month[npc]` | int | 1–12 | NPC 离职高发月份中心 |
| `sigma[npc]` | float | 0.5–3.0 | 概率窗口宽度(月) |
| `REL_PENALTY_SCALE` | float | 0.0–0.01 | 关系负值放大系数 |
| `effort_weight[npc]` | float | -0.5..+0.5 | E 对该 NPC 影响方向(正=加速 / 负=留住) |
| `P_leave` | float | 0.0–1.0 | 月末离职概率 |

**Output Range**: `[0.0, 1.0]` clamp 强制。月末 RNG `uniform(0.0, 1.0) < P_leave` 决定离职。

**Worked Example — Lisa 跳槽**: tuning `base_rate=0.05, peak_weight=0.50, peak_month=3, sigma=1.0, effort_weight=-0.10, REL_PENALTY_SCALE=0.003`。月份 3,`R = -15`,`E = 0.6`:
- `time_factor = 0.50 × bell(3, 3, 1.0) = 0.50`
- `relationship_penalty = 15 × 0.003 = 0.045`
- `effort_pressure = -0.10 × 0.6 = -0.06`
- `P_leave = clamp(0.05 + 0.50 + 0.045 - 0.06, 0, 1) = 0.535` (53.5%)

**3 NPC 典型参数**:

| NPC | base_rate | peak_month | sigma | effort_weight | 设计意图 |
|-----|-----------|-----------|-------|---------------|---------|
| Lisa(跳槽) | 0.05 | 3 | 1.0 | -0.10 | 第 2-4 月峰,负关系加速 |
| 卷王(晋升) | 0.02 | 5 | 1.5 | +0.30 | 第 3-6 月峰,玩家高 effort 竞争触发 |
| 老员工(被裁) | 0.08 | 8 | 2.0 | 0.00 | 第 6-10 月慢燃,与 effort 无关 |

**Cross-GDD cite**: `E` 输入来自 `#7 F4`;月末调用时序由 `#6 Rule 10` 月末触发驱动;F3 结果写入 NPC lifecycle 状态机 `ACTIVE → LEAVING_ANNOUNCED`;tuning 参数存 `data/` 配置文件不入 Save。

## Edge Cases

24 edges / 7 categories / 4 [RISK GUARD] R-NPC-1..4。

### Cat 1: relationship_score 边界

**1.1**: 某事件对 score=+95 NPC 写入 +10 → clamp 至 +100,差额丢弃,`relationship_changed` 信号 emit(new_value=100)
**1.2**: score=-98 写入 -10 → clamp 至 -100;phase 保持 HOSTILE(下边界);不触发 phase change 信号
**1.3**: delta=0 → 不发出 `relationship_changed`,`#10` 不触发阈值检查
**1.4**: 写入 LEFT NPC → 静默忽略(`push_warning` debug log);AP 已扣由 `#11` 在打出前做状态检查(见 Cat 5)

### Cat 2: NPC 离职 race

**2.1**: 月末同帧 Lisa + 老员工 F3 同批命中 → **每月最多 1 NPC 离职宣告**(按 NpcId 注册顺序优先);其余本月跳过,下月重新计算(不累积跨月欠债)
**2.2**: Day 28 玩家事件将 Lisa score 推至 +60(CLOSE),同日月末 F3 仍命中 → F3 使用月末当时 score(+60)重算,`relationship_penalty` 变 0,概率降低但仍可能命中。叙事层做"明明很亲近却还是走了"
**2.3**: `LEAVING_ANNOUNCED` 期间玩家继续提高 score → `relationship_score` 正常累加(不锁定);**状态转移 → LEFT 不可被 score 阻止**(P3 守 — MVP 单向不可逆);高 score 触发"依依不舍"特殊对话事件,不延迟离职

### Cat 3: 关系阈值 + #10 事件触发

**3.1**: 同帧 score 从 +25 跳变至 +65(跨 +30 + +60 双阈值)→ 只 emit **最终状态** `relationship_phase_changed`(NEUTRAL → CLOSE);跳过中间 WARM 态,不触发 WARM 专属事件
**3.2**: `score = 30`(NEUTRAL/WARM 边界)→ 属于 WARM(`>=` 含边界,F2 锁);`is_above_threshold(30) = true`。CI lint 校验 `#10` 全部阈值查询一致使用 `>=`
**3.3**: `#10` 事件触发后同帧 score 回退至阈值以下 → 事件以**触发时快照**为准,不回滚;`relationship_phase_changed` 帧末以最终值发出(WARM→NEUTRAL 回退)
**3.4**: NPC LEFT 时 `is_above_threshold` 查询 → 返回 score 保留值(Save 离职前数值);`#10` 调用方自行检查 NPC 状态决定使用

### Cat 4: Save 持久化

**4.1**: NPC LEFT 后 score 是否保留 → **保留**(VS RETURNED 需恢复 + GAME OVER 回忆文本 + 防 schema 破坏)。LEFT NPC `relationship_score` + lifecycle state 一并序列化
**4.2 [RISK GUARD R-NPC-2]**: 玩家 reload save 见到 LEFT NPC 的 score 视觉 → `#13 HUD` + `#16 KPI Review UI` 渲染前调用 `get_npc_state(npc_id)`;`state == LEFT` 时关系数值区域**隐藏数字,仅显示"(已离职)"标签**。数据保留,视觉屏蔽
**4.3**: VS RETURNED → score 恢复至离开时存档值(不重置为 0);phase 重派生;`relationship_phase_changed` emit;Save schema version bump(引用 registry `current_schema_version`)
**4.4**: Save 损坏 score 字段缺失 → Save Rule 兜底:缺 score 默认 0(NEUTRAL);缺 lifecycle 默认 ACTIVE;告知玩家"部分存档数据已重置"

### Cat 5: 跨 GDD race(`#11` + `#10` 同帧)

**5.1**: `#11` 卡 `+10 Lisa` + `#10` 事件 `-20 Lisa` 同帧写同 NPC → 写入顺序: `#11` 卡先(AP 驱动层),`#10` 事件后(事件层);两次写入累加。帧末统一 emit `relationship_changed`(net delta = -10)。阈值检查在帧末统一一次
**5.2**: `#11` 卡对 LEFT NPC 发出行动 → `#11` 必须在打出前查询 `get_npc_state(npc_id)`;`LEAVING_ANNOUNCED` 卡可用但标"(即将离职)";`LEFT` 卡置灰不可选(返回 BLOCKED,不扣 AP)。`#8` 暴露 `get_npc_state(npc_id)` 查询接口

### Cat 6: GAME OVER 期间 NPC 状态冻结

**6.1**: GAME OVER 触发同帧 F3 离职检查未完成 → `#6` 进入 GAMEOVER 后 `#8` 订阅 `game_over_entered` 信号,**冻结所有状态转移**(F3 结算结果丢弃);GAME OVER 结算只读当前 snapshot
**6.2**: GAME OVER score 快照供 `#12 Run Meta` 结算文本 → `#8` 向 `#12` 提供一次 snapshot(只读不修改),与 Save 序列化值一致

### Cat 7: Pillar 4 红线

**7.1**: 文本"你帮助 Lisa,获得友谊奖励 +10!"(励志 / 游戏化语气)→ Pillar 4 lint 红线 BLOCKING。正确格式:"Lisa 今天没骂你"(negative space) / "Lisa 对你的评价从'顺眼'升到了'凑合'"(调侃降格)。tone-lead review gate 在事件文本 PR 合并前执行
**7.2 [RISK GUARD R-NPC-1]**: 玩家发现刷 NPC 好感度达永久 buff → CLOSE 关系**只解锁叙事内容**(新对话/事件分支),**不**给数值加成(AP 回充 / KPI 减免 / score 乘数)。`#10` 注册事件效果时 lint 检查:`effect.target == "player_stat"` + `effect.trigger_condition includes "phase == CLOSE"` 组合 = CI BLOCKING

---

### 4 [RISK GUARD] 索引

| ID | 位置 | 守 Pillar | Section H 守门 |
|----|------|---------|---------------|
| **R-NPC-1** | Edge 7.2 | 关系永久 buff 漏洞 → Anti-Pillar 1 | AC-ROBUST-01 |
| **R-NPC-2** | Edge 4.2 | LEFT NPC score leak 视觉层 → P4 沉浸 | AC-ROBUST-02 + AC-COMPAT-05 |
| **R-NPC-3** | F2 边界精度 | Float 比较精度问题 | AC-ROBUST-03 |
| **R-NPC-4** | Cat 2 + Tuning | Lisa 跳槽 race 与玩家关系突变(跨月边界)| AC-ROBUST-04 |

## Dependencies

### Upstream

| GDD | 关系 | 状态 | 提供 |
|-----|------|------|------|
| `#1 Save System` | Hard | ✅ Approved | Rule 7 autosave + Rule 13 snapshot_id 单调 + schema migration;Save 持久化 NPC score / flags / lifecycle |
| `#6 Scene & Day Flow Controller` | Hard | ⏳ Designed | Rule 9 game-time tick;Rule 10 月末 KPI_REVIEW 触发 F3 离职检查;`scene_state_changed` 信号订阅 |

### Soft Dependencies(双向)

| GDD | 关系 | 双向接口 |
|-----|------|---------|
| `#7 AP Economy` | Soft | F3 输入 `E = effort_potential`(`#7` F4);零直接 API 调用,通过月末 push 间接 |

### Downstream Dependents(8 系统)

| # | System | 关系 | 主接口 |
|---|--------|------|--------|
| 9 | KPI & Reverse Threshold System | Soft | NPC 关系不直接进入 KPI 公式;通过 `#10` 事件触发 `#11` 卡 → 间接影响 effort |
| 10 | Event Script Engine ⭐ | Hard 双向 | 读 `is_above_threshold` 触发条件 + 写 `update_relationship` + 写 flag + announce 离职;阈值 unlock 主消费 |
| 11 | Action Card System | Hard 双向 | 写 `update_relationship`(卡触发关系变化);读 `get_npc_state`(打出前检查 LEFT 守门) |
| 12 | Run Meta System | Soft | GAME OVER snapshot 供 Run 摘要文本(只读) |
| 13 | HUD System (Diegetic) | Hard | 订阅 `relationship_changed` / `npc_left_company`;diegetic 工位场景渲染 NPC 表情 + 站位 + LEFT 视觉屏蔽 |
| 15 | Daily / Weekly Recap UI | Soft | 周报展示本周 NPC 关系变化(汇总 `#10` 事件) |
| 16 | KPI Review & Game Over UI | Soft | GAME OVER 月末 NPC 关系总结(R-NPC-2 LEFT 屏蔽守门) |
| 18 | Tutorial / Onboarding (VS) | Soft | NPC 教学事件触发(Day 1-3 引导) |

### 双向一致性 cross-check

| 上游 GDD 反向声明 | 本 GDD Rule | ✓ |
|-------------------|------------|---|
| Save Rule 7 autosave 在卡执行后触发 | Rule 13 序列化协议 | ✓ |
| Save Rule 13 snapshot_id 单调 | Rule 13 schema | ✓ |
| #6 Rule 10 月末 KPI_REVIEW 触发 | I-5 + F3 月末检查 | ✓ |
| #6 Rule 11 GAMEOVER 永久锁定 | Edge 6.1 状态冻结 | ✓ |
| #7 I-7 零直接交互 | Soft Dep + 通过 #11 桥接 | ✓ |

### 5 propagation flags(待 #10 / #11 / #13 / #16 GDD 撰写时复审)

1. **`#10 Event Script`**: `register_threshold_listener(npc, threshold)` API 实现;F2 `is_above_threshold` 主消费;CI lint 校验 effect 不含 `target=="player_stat" + condition CLOSE` 组合(R-NPC-1 守门)
2. **`#11 Action Card`**: 打出前调 `get_npc_state(npc_id)`;LEFT 状态卡置灰不可选(Edge 5.2);Hero 卡 `is_hero` flag 配合 `#7` AP Economy effort 累积
3. **`#13 HUD Diegetic`**: 订阅 `relationship_changed` + `npc_left_company`;LEFT NPC 关系数值视觉屏蔽(R-NPC-2);`subject_inversion_lint.py` 扩展 `NPC.*` key
4. **`#16 KPI Review UI`**: GAME OVER snapshot 渲染 NPC 关系时 R-NPC-2 守门(LEFT NPC 显示"(已离职)")
5. **`#9 KPI System`**: NPC 关系**不直接**进入 KPI 公式(本 GDD 与 KPI 解耦);若野心版引入"关系网衰减驱动工龄惩罚",需 `#9` 仲裁

### Registry 候选(Phase 5b decision)

| 候选 constant | 值 | 跨系统消费? | 是否注册 |
|--------------|----|------------|----------|
| `RELATIONSHIP_HOSTILE_THRESHOLD` | -30 | ✅ `#10` `#13` 消费 | **注册候选**(待 `#10`/`#13` GDD 撰写时联合) |
| `RELATIONSHIP_WARM_THRESHOLD` | +30 | ✅ 同上 | 同上 |
| `RELATIONSHIP_CLOSE_THRESHOLD` | +60 | ✅ 同上 | 同上 |
| `DECAY_TRIGGER_DAYS` / `DECAY_RATE_PER_MONTH` | 30 / 10 | ❌ 仅 `#8` own(VS) | 不注册 |
| `REL_PENALTY_SCALE` | 0.003 | ❌ 仅 F3 内部 | 不注册 |

MVP 阶段 Phase 5b **暂不注册**(等 `#10`/`#13` 撰写时与三阈值一并注册,避免过早注册导致 referenced_by 不全)。

## Tuning Knobs

### 锁定常量(Pillar 守门,**不是 knob**)

| 常量 | 值 | 红线锁定理由 |
|------|----|-------------|
| `MVP_NPC_COUNT` | 8 | MVP 单部门固定 8 NPC(枚举不可运行时增删) |
| `RELATIONSHIP_SCORE_MIN` / `MAX` | -100 / +100 | int 边界,Pillar 1 守门(关系不可"无限刷") |

### 关系阶段阈值(Tuning,跨系统)

| Knob | 默认 | 安全范围 | 影响 |
|------|------|---------|------|
| `RELATIONSHIP_HOSTILE_THRESHOLD` | -30 | -40..-20 | 进入 HOSTILE phase 边界 |
| `RELATIONSHIP_WARM_THRESHOLD` | +30 | +25..+40 | 进入 WARM phase 边界 |
| `RELATIONSHIP_CLOSE_THRESHOLD` | +60 | +50..+70 | 进入 CLOSE phase 边界 |

### F1 衰减 Knob(VS only)

| Knob | 默认 | 安全范围 | 影响 |
|------|------|---------|------|
| `DECAY_TRIGGER_DAYS` | 30 | 20-45 | 触发一次衰减所需的连续不互动天数 |
| `DECAY_RATE_PER_MONTH` | 10 | 5-20 | 每周期 score 减少量 |

### F3 离职概率 Knob(per-NPC,8 套独立参数)

| NPC | base_rate | peak_weight | peak_month | sigma | effort_weight |
|-----|-----------|-------------|-----------|-------|---------------|
| Lisa(跳槽) | 0.05 | 0.50 | 3 | 1.0 | -0.10 |
| 老板(BOSS) | 0.01 | 0.10 | 12 | 4.0 | 0.00 |
| 清洁阿姨 | 0.04 | 0.40 | 5 | 1.5 | 0.00 |
| 卷王(晋升) | 0.02 | 0.50 | 5 | 1.5 | +0.30 |
| 摸鱼族(被裁) | 0.06 | 0.50 | 4 | 1.5 | -0.20(玩家越懒摸鱼族越快被裁) |
| 谄媚族 | 0.02 | 0.30 | 8 | 2.0 | 0.00 |
| 老油条 | 0.03 | 0.40 | 10 | 2.5 | 0.00 |
| 新人 | 0.05 | 0.40 | 6 | 2.0 | 0.00 |

**全局参数**:
- `REL_PENALTY_SCALE = 0.003`(关系负值放大系数)

### Per-NPC 初始值

| NPC | initial_score | initial_flags(部分) |
|-----|---------------|---------------------|
| Lisa | +5 | `is_potential_jumper=true` |
| 老板 | -5 | `is_pua_master=true` |
| 清洁阿姨 | 0 | `son_in_high_school=true`(VS 推进 `son_admitted=true`) |
| 卷王 | -10 | `is_competitor=true` |
| 摸鱼族 | +10 | `is_dark_ally=true` |
| 谄媚族 | 0 | `is_boss_sycophant=true` |
| 老油条 | 0 | `is_player_mirror=true` |
| 新人 | +5 | `needs_mentoring=true` |

### Scope Tier

| Tier | NPC 系统启用 |
|------|------------|
| **MVP** | 8 NPC + 关系阶段 4 段 + lifecycle 4 态 + F2 + F3 + 离职 archetype 3(Lisa/卷王/摸鱼) |
| **VS** | + F1 衰减启用 + RETURNED 转移 + HR / 客户 NPC + 5 离职 archetype 全启 + Lisa 跳槽线全分支 |
| **Full Vision** | + NPC-to-NPC rivalry 网络(MVP 简化为单维 score)+ 跑间变量(不同部门 / 不同 Boss)|

## Visual/Audio Requirements

### 零 Asset Ownership

NPC Relationship System **不 own 任何 visual / audio asset**。所有 NPC 视听表达由其他 GDD own:

| Asset 类型 | Owner GDD |
|-----------|-----------|
| NPC 立绘 / 工位站位 / 表情 sprite | `#13 HUD Diegetic` |
| NPC 离职 SFX / 关系 phase 切换 stinger | `#4 Audio Manager`(若引入,需走 Pillar 4 红线审 — **MVP 默认无专属 SFX**)|
| NPC 累积视觉(空工位 / 桌面变脏)| `#5 Lighting & Visual State` Rule 5 累积 state |

### Pillar 4 红线(本 GDD 守门跨 GDD 视听)

`#4 Audio` 与 `#13 HUD` 撰写时**禁**:
- NPC 关系阶段升档专属 SFX("叮"友谊解锁音 — 违反 P4)
- NPC 头顶进度条 / 心形 icon / 友谊度 +5 浮动文字 — 违反 P4
- NPC 离职"哀悼"音效或慢镜头视觉 — 违反 P4(他们就这么没了)
- NPC 立绘"对玩家好感度"光晕 — 违反 P4 + R-NPC-1

`#5 Lighting` 累积 state 4 维度可包含"空工位"维度(NPC LEFT 后的环境叙事 — 见 Lighting Section B"我的桌子怎么这么脏"共振)。

### 📌 Asset Spec Flag

本 GDD 不需要 `/asset-spec` — 零 ownership。Asset spec 由各 owner GDD 产出:
- `/asset-spec system:hud-diegetic`(NPC 立绘 + 表情)
- `/asset-spec system:lighting-visual-state`(空工位累积视觉)

## UI Requirements

### 零 UI Screen Ownership

NPC Relationship System **不 own 任何 UI screen**。下游 UI 订阅 `#8` 信号:

| UI GDD | 订阅信号 / 数据 | 备注 |
|--------|-----------------|------|
| `#13 HUD Diegetic` | `relationship_changed` / `npc_left_company` / NPC lifecycle state | 工位场景 NPC 站位 + 表情;LEFT NPC 视觉屏蔽 R-NPC-2 |
| `#15 Daily/Weekly Recap UI` | 本周关系变化汇总 | 周报展示("Lisa 这周和你说了 3 次话") |
| `#16 KPI Review & Game Over UI` | GAME OVER snapshot | Run 摘要展示;LEFT NPC "(已离职)"标签 R-NPC-2 |
| `#17 Main Menu / Settings` | **零交互** | NPC 不在 Settings 调整 |

### NPC Collection UI 红线(Pillar 4)

**禁**: 任何"NPC 收集列表" / "好感度图鉴" / "进度条" / 完成度统计 UI(违反 Pillar 4 + Anti-Pillar 1)。NPC 不是 Pokémon。Run Meta `#12` 可在 GAME OVER 后展示"本 Run 互动过的 NPC 名单"作为 Run 摘要的叙事元素,**不**作为收集进度。

### 📌 UX Flag

本 GDD **不**触发 UX Flag(零 UI screen ownership)。下游 UI GDD UX Flag 时,NPC 主语翻转 + Pillar 4 反"友谊化"作为 cross-cutting concern 须传递。

## Acceptance Criteria

26 AC / 5 categories(AC-FUNC 8 / AC-PERF 4 / AC-COMPAT 5 / AC-ROBUST 5 / AC-TONE 4)。4 [RISK GUARD] R-NPC-1..4 全对应 AC-ROBUST + 1 综合。

### AC-FUNC

**AC-FUNC-01** `MVP` `relationship_score` 边界
**GIVEN** `npc_relationship_fixture` 初始化所有 8 NPC,score = 0
**WHEN** `apply_delta(npc_id, +150)` + `apply_delta(npc_id, -200)`
**THEN** score 上限钳至 100,下限钳至 -100;`relationship_changed` 信号每次 emit 一次共 2 次;无 overflow / underflow
*Cite: Rule 2*

**AC-FUNC-02** `MVP` 关系阶段升档触发 `#10` 事件
**GIVEN** Lisa score = 29,`#10` 注册阈值监听
**WHEN** `apply_delta("LISA", +1)` 使 score 到达 30
**THEN** `relationship_phase_changed(npc, NEUTRAL, WARM)` 信号 emit;`#10` 同帧加入候选池
*Cite: Rule 5 / Edge 3.1 / F2*

**AC-FUNC-03** `MVP` NPC enum 完整性
**GIVEN** `npc_enum_lint.py` 扫描全量
**WHEN** `--expected-count 8`
**THEN** 8 个 MVP NpcId 全部存在,无 UNKNOWN/PLACEHOLDER;缺任一 ID FAIL
*Cite: Rule 1*

**AC-FUNC-04** `MVP` 离职概率 F3 路径
**GIVEN** `npc_leave_probability_mock` RNG seed=42;Lisa score=-60,month=3,E=0.6
**WHEN** `evaluate_leave_probability("LISA", 85)`
**THEN** 返回值与公式预期误差 ≤ 0.001;同入参重复 100 次结果恒定(确定性)
*Cite: F3 / Edge 5.1*

**AC-FUNC-05** `MVP` NPC 生命周期态转换
**GIVEN** Lisa ACTIVE,score 已跌破离职阈值
**WHEN** day_end_hook 执行 + F3 命中
**THEN** `ACTIVE → LEAVING_ANNOUNCED`,emit `npc_state_changed`;HUD 同帧更新;Save 写入 LEAVING_ANNOUNCED
*Cite: Rule 7 / Cat 2*

**AC-FUNC-06** `MVP` LEFT NPC score 持久化
**GIVEN** `npc_save_fixture` 预载 `state=LEFT` + score 历史值
**WHEN** save → kill 进程 → load
**THEN** state == LEFT,score 保留离职前值;无重置为 0
*Cite: Rule 13 / Edge 4.1*

**AC-FUNC-07** `MVP` flag 驱动事件阻断
**GIVEN** 老板持有 `formal_complaint_filed = true`
**WHEN** `query_event_candidates(npc_id="BOSS")`
**THEN** 被 flag 阻断的事件不在候选;长度比基线减 ≥ 1;`#10` 通过 `flag_blocked_event_count` 接口验证
*Cite: Rule 4 / Edge 7.2*

**AC-FUNC-08** `Beta` 关系阶段降档不超过 1 档/天
**GIVEN** Lisa 当日已发生一次降档(WARM → NEUTRAL)
**WHEN** 同日再次 `apply_delta("LISA", -40)`
**THEN** 当日降档锁定 1 次;score 数值更新但 phase 不再降;次日 day_start_hook 解锁
*Cite: Rule 6 / Edge 3.2*

### AC-PERF

**AC-PERF-01** `MVP` 批量 delta 吞吐
**GIVEN** 8 NPC 全 ACTIVE,GUT 性能 fixture
**WHEN** 同帧对全 8 NPC 各调 `apply_delta` 一次
**THEN** 总耗时 ≤ 1 ms(预留 KPI #9 主预算)
*Cite: 性能预算 ≤ 16.6 ms/帧*

**AC-PERF-02** `MVP` `query_event_candidates` 延迟
**GIVEN** 8 NPC + 每人 ≤ 5 flag
**WHEN** 单次 `query_event_candidates(npc_id)`
**THEN** 耗时 ≤ 2 ms;缓存命中时 ≤ 0.5 ms

**AC-PERF-03** `MVP` 存档写入不阻塞主线程
**GIVEN** 完整 8 NPC 存档快照(含 LEFT/RETURNED)
**WHEN** day_end 存档触发
**THEN** 主线程帧时间增量 ≤ 0.5 ms;Save Rule 7 WorkerThreadPool 路径覆盖 NPC 序列化
*Cite: Save Rule 7*

**AC-PERF-04** `MVP` NPC 状态机转换帧完整性
**GIVEN** Lisa 触发离职(ACTIVE → LEAVING_ANNOUNCED)
**WHEN** 离职判定在 day_end_hook 执行
**THEN** `npc_state_changed` 同帧 emit,HUD 同帧更新;下一帧无残留 ACTIVE 显示
*Cite: Rule 10 / Cat 2*

### AC-COMPAT

**AC-COMPAT-01** `MVP` Save `#1` 双向持久化
**GIVEN** `npc_save_fixture` 预载完整 NPC 状态(score / phase / flags / lifecycle 含 LEFT/RETURNED)
**WHEN** 存档 → 热重启 → 读取
**THEN** 8 NPC 全部字段 bit-exact 一致;schema 不匹配时 Save migration 而非静默丢弃
*Cite: Save Rule 13 / Edge 4.4*

**AC-COMPAT-02** `MVP` `#6` Day Flow hook 顺序
**GIVEN** `#6` 注册 day_end hook
**WHEN** `#6` emit `scene_state_changed(→KPI_REVIEW)`
**THEN** `#8` 在 hook 顺序内完成 decay + 离职判定 + 信号 emit,**不晚于 `#9` KPI 结算**;`day_end_sequence_integration_test.gd` 调用栈日志验证
*Cite: I-5 / `#6 Rule 10`*

**AC-COMPAT-03** `MVP` `#10` 阈值事件双向触发
**GIVEN** `#10` 监听 `relationship_phase_changed`
**WHEN** NPC 关系升降档
**THEN** `#10` 同帧推剧情事件入候选池;`#8` 不直接持有 `#10` 引用(信号总线解耦)
*Cite: I-2 / F2*

**AC-COMPAT-04** `MVP` `#11` Action Card AP 消耗触发关系 delta
**GIVEN** 玩家打 `+10 Lisa` 卡,`#11` 调 `apply_delta`
**WHEN** `#11` 传 `(npc="LISA", delta=+5, source="card_COFFEE_CHAT")`
**THEN** `#8` 接收 delta + 更新 score + emit;`#11` 无需知 score 当前值或 phase(单向写入)
*Cite: I-1*

**AC-COMPAT-05** `MVP` `#13 HUD` 主语翻转契约 + R-NPC-2 视觉屏蔽
**GIVEN** `#13` 订阅 `relationship_changed` + LEFT NPC 状态查询
**WHEN** NPC score 变化或 NPC LEFT
**THEN** HUD 文本使用 NPC 主语("Lisa 对你的态度:观察中"),**不**用玩家主语;LEFT NPC 关系数值区域显示"(已离职)"标签隐数字;`subject_inversion_lint.py --scope NPC.*` PASS
*Cite: Rule 11 / Edge 4.2 / R-NPC-2*

### AC-ROBUST(对应 R-NPC-1..4 + 综合)

**AC-ROBUST-01** `MVP` `R-NPC-1` 关系永久 buff 漏洞守门
**GIVEN** `#10` 注册任意事件 effect
**WHEN** lint 检查 effect.target == "player_stat" + condition includes "phase == CLOSE"
**THEN** 组合 = CI BLOCKING 错误;CLOSE 关系**只解锁叙事内容**;自动测试验证 CLOSE 状态下玩家数值(AP 上限/KPI 阈值/effort 乘数)与 NEUTRAL 完全一致
*Cite: Edge 7.2 / R-NPC-1 / Anti-Pillar 1*

**AC-ROBUST-02** `MVP` `R-NPC-2` LEFT NPC 视觉屏蔽
**GIVEN** Lisa 强制置 LEFT,`#13 HUD` 渲染
**WHEN** 玩家查看工位场景 / Run 摘要
**THEN** 所有 UI 渲染点显示"(已离职)"而非数字;`relationship_score` 仍在 Save 中(数据保留,视觉屏蔽)
*Cite: Edge 4.2 / R-NPC-2*

**AC-ROBUST-03** `MVP` `R-NPC-3` 关系阈值 Float 比较精度
**GIVEN** CI 静态扫描 `npc_relationship.gd`
**WHEN** lint 检查 `relationship_score` 所有赋值点
**THEN** 全部为 int 字面量或 int 函数返回值;禁止 float 转换;GDScript 类型声明 `int` 强类型;Godot 4.6 静态类型编译期报错
*Cite: F2 / R-NPC-3*

**AC-ROBUST-04** `MVP` `R-NPC-4` Lisa 跳槽 race 跨月边界
**GIVEN** Day 28 行动阶段末玩家打 `+50 Lisa` 卡
**WHEN** 同日 MONTH_END phase 进入,F3 离职检查
**THEN** 行动阶段在 MONTH_END 之前关闭(`#6` 状态机保证);F3 使用 snapshot(玩家卡效果已写入);F3 计算结果使用更新后的 score(P_leave 含降低后的 relationship_penalty)
*Cite: Cat 2.2 / R-NPC-4 / `#6 Rule 10`*

**AC-ROBUST-05** `MVP` 综合 — 存档损坏恢复
**GIVEN** `npc_save_fixture` 注入损坏:NPC score 字段缺失 / 值 null
**WHEN** Save 系统读取并恢复
**THEN** 缺 score fallback 0;缺 lifecycle fallback ACTIVE;不 crash;`npc_data_repaired` 警告信号 emit;玩家继续游玩
*Cite: Edge 4.4 / Save Rule 22*

### AC-TONE

**AC-TONE-01** `MVP` NPC 不"友谊化"主语验证
**GIVEN** 关系阶段升档触发的叙事文本(`NPC.*` key,context=threshold_up)
**WHEN** `subject_inversion_lint.py --scope NPC.* --context threshold_up` 扫描
**THEN** 全部以 NPC 行为/算计/评价为主语("Lisa 开始找你汇报,因为你不抢她功劳"),无"你赢得了 Lisa 的友谊"类励志表述
*Cite: Rule 11 / Pillar 4*

**AC-TONE-02** `MVP` 关系负值文本不煽情
**GIVEN** 关系降档触发的叙事文本(context=threshold_down)
**WHEN** lint 扫描 + creative-director 抽样 5 条
**THEN** 无"你失去了一个朋友" / "努力就能挽回"类正能量;NPC 主语描述冷漠 / 算计 / 利益("老王把你从他的午饭名单里划掉了");lint PASS + CD sign-off 落 `production/qa/evidence/npc-tone-review-[date].md`
*Cite: Pillar 4 / Anti-Pillar 2*

**AC-TONE-03** `Beta` 离职叙事黑色幽默
**GIVEN** 全部 NPC 离职触发文本(context=npc_left)
**WHEN** Beta playtest 玩家截图分享率 + CD 抽样 8 NPC 全部离职文本
**THEN** 离职文本黑色幽默/讽刺 tone("老王终于被 HR 优化掉了,他说他早就料到了"),无沉重/哀悼;CD sign-off 落 `production/qa/evidence/`
*Cite: Pillar 4*

**AC-TONE-04** `Beta` P1 守门 — 高分不显示"胜利"视觉
**GIVEN** NPC score 到达 100(CLOSE 满)
**WHEN** `#13 HUD` 渲染 NPC 关系状态
**THEN** HUD 无满星/满心/金色光晕等"胜利"视觉;可使用"微妙讽刺"图标(NPC 背后翻白眼像素动作);lead-programmer + art-director 联合 sign-off 落 `production/qa/evidence/`
*Cite: Anti-Pillar 1 / R-NPC-1 Advisory*

---

### Tier 分级

| Tier | 数量 |
|------|------|
| MVP 必测 | 22 |
| Beta(playtest 类) | 4 |

### QA 工具需求

| 工具 | 守门 AC |
|------|---------|
| `npc_enum_lint.py` | AC-FUNC-03 |
| `relationship_score_boundary_fixture.gd` | AC-FUNC-01 / AC-ROBUST-01 |
| `npc_leave_mock_fixture.gd`(确定性 RNG seed) | AC-FUNC-04 |
| `npc_save_fixture.gd`(LEFT/RETURNED 往返) | AC-FUNC-06 / AC-COMPAT-01 / AC-ROBUST-05 |
| `subject_inversion_lint.py`(扩展 NPC.*) | AC-COMPAT-05 / AC-TONE-01 / AC-TONE-02 |
| `relationship_threshold_unlock_fixture.gd` | AC-FUNC-02 / AC-COMPAT-03 |
| `day_end_sequence_integration_test.gd` | AC-COMPAT-02 |
| `card_to_npc_delta_integration_test.gd` | AC-COMPAT-04 |

## Open Questions

7 OQ-NPC + 5 cross-GDD propagation flags。

**OQ-NPC-01 (Pre-Production playtest)**: F3 离职概率 per-NPC 参数(8 套 `base_rate / peak_weight / peak_month / sigma / effort_weight`)实测调优。Owner: economy-designer + qa-tester。Target: `/prototype core-loop` Pre-Production 阶段。
- 目标:多数玩家在 12 月内见到至少 2 个 NPC 离职(P3 守 — 关系也走向解散)
- 参数过松 → P3 不可感;过紧 → 玩家抢不及叙事

**OQ-NPC-02 (待 `#10 Event Script` GDD 仲裁)**: NPC 阈值 unlock 事件分支密度。Owner: narrative-director + writer + `#10` 主笔。Target: `/design-system event-script-engine`。
- 每 NPC × 每 phase(HOSTILE/NEUTRAL/WARM/CLOSE)的事件密度;CLOSE 阶段事件**仅叙事不数值**(R-NPC-1)

**OQ-NPC-03 (VS playtest)**: F1 衰减启用后玩家"长期忽略 NPC"的 perception。Owner: game-designer + qa-tester。Target: VS playtest。
- DECAY_TRIGGER_DAYS=30 是否合适(过短 → 玩家被惩罚;过长 → 衰减无意义)

**OQ-NPC-04 (Pre-Production)**: NPC 视觉表达密度(diegetic 工位场景 NPC 表情 / 站位变化频率)。Owner: art-director + `#13` 主笔。Target: `/design-system #13 HUD` + `/asset-spec system:hud-diegetic`。
- 8 NPC 各自 sprite 数量;关系 phase 切换是否触发视觉变化(MVP 简化:仅 LEFT 后空工位变化)

**OQ-NPC-05 (野心版 ADR-XXXX 候选)**: NPC-to-NPC rivalry / 派系系统是否引入(MVP 简化为单维 score)。Owner: game-designer + `#10` 主笔。Target: 野心版 ADR。
- 引入 → 决策空间显著扩展(玩家须在派系间站队)
- 不引入 → MVP scope 守住

**OQ-NPC-06 (Polish)**: Lisa 跳槽线分支密度。Owner: writer + narrative-director。Target: Polish 阶段。
- MVP 单跳槽分支;VS 引入 3-4 分支(玩家投资程度决定告别戏)

**OQ-NPC-07 (待 `#16 KPI Review UI` GDD)**: GAME OVER Run 摘要中 NPC 关系 snapshot 展示密度。Owner: ux-designer + writer + `#16` 主笔。Target: `/design-system #16`。
- 8 NPC 全部展示 vs 仅展示玩家有显著互动的 NPC;LEFT NPC 屏蔽数字(R-NPC-2)

### 5 propagation flags 状态(Section F 已 surface)

| Flag # | 待 GDD | OQ 关联 |
|--------|--------|---------|
| #1 `#10` `register_threshold_listener` API + R-NPC-1 lint | `#10 Event Script` | OQ-NPC-02 |
| #2 `#11` 打出前 `get_npc_state` 守门 | `#11 Action Card` | — |
| #3 `#13` LEFT NPC 视觉屏蔽 | `#13 HUD Diegetic` | OQ-NPC-04 |
| #4 `#16` GAME OVER NPC snapshot 渲染 | `#16 KPI Review UI` | OQ-NPC-07 |
| #5 `#9` NPC 关系不直接进 KPI 公式 | `#9 KPI System` | — |

### OQ-impacted AC

| OQ | 影响 AC |
|----|---------|
| OQ-NPC-01 | AC-FUNC-04 / AC-FUNC-05(F3 参数实测后修订) |
| OQ-NPC-02 | AC-COMPAT-03 / AC-ROBUST-01(若 `#10` 阈值 unlock 事件密度调整) |
| OQ-NPC-03 | F1 启用后 AC-FUNC-08(降档速率限制可能调整) |
| OQ-NPC-04 | AC-COMPAT-05(LEFT 视觉屏蔽实现细节) |
| OQ-NPC-07 | AC-ROBUST-02 / AC-COMPAT-05(GAME OVER snapshot 渲染细节) |
