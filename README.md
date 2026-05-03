# 《活过第 X 集》— 抢救包

从 `games-studio` framework 里捞出来的真东西。**不带 framework 包装,不需要 autopilot / agent / skill**,直接当一个普通 Godot 项目继续。

---

## 游戏概念(一句话)

**像素风反向 KPI 办公室生存模拟。** 你扮演中国职场老油条,每天 8 个行动点要在"被开除"和"太优秀下关被涨 KPI"之间走钢丝。**胜利条件不是升职加薪,是"维持平庸活得久"**。

参考标杆:《大多数》《死亡与税收》《Papers Please》《破事精英》。

完整 elevator pitch:[`design/gdd/game-concept.md`](design/gdd/game-concept.md)

---

## 目录速查

| 目录 | 是什么 | 真东西? |
|---|---|---|
| `design/gdd/` | 20 个系统 GDD + game-concept + systems-index + 2 份 cross-review | ✅ 创意核心 |
| `design/research/` | AP 决策空间分析 / event schema 提案 / KPI 反向阈值公式提案 | ✅ 关键算法推导 |
| `design/art/` | 美术 bible(像素风格 + UI palette + 角色规范) | ✅ |
| `design/registry/` | 实体 / 卡 / 事件注册表(yaml) | ✅ |
| `architecture/` | 17 ADRs + architecture.md + tr-registry.yaml + control-manifest.md | ✅ 架构思路有价值,落地形式可重选 |
| `stories/` | 20 epics × 234 stories,**实施细节 + 验收条件 + 边界 case** | ⚠️ 见下面"真东西 vs paper-done" |
| `src/` | 76 .gd 文件,12 个系统目录,**18,609 行 GDScript** | ✅ 真代码 |
| `tests/` | 226 .gd 测试文件,**41,147 行**(integration 127 + unit 99 + helpers + smoke + evidence) | ⚠️ 写了但未必跑过(gdunit4 没装) |
| `assets/` | shaders/lighting + data/ 部分音频数据 | ✅ |
| `addons/` | 自研 event_linter | ✅ |

---

## 真东西 vs paper-done

`stories/` 里 234 个 story 名义全是 `Status: Complete/Done`,但仔细读 status 注释会看到反复出现:

> "tests written but not executed — Godot+gdunit4 install pending"

意思是 **autopilot 跑出来的代码 + 测试都 land 在硬盘上了,但很多从来没真启动过 Godot 验证**。

**怎么辨真伪**:
- src/ 实际有代码、tests/ 实际有测试 → 真 paper(还需要跑过才知道是否 work)
- 各系统代码量 sanity check:

  | 系统 | src 行 | 真度感 |
  |---|---|---|
  | autoload | 9466 | 🟢 重(SaveSystem 1700+ 行,EventBus 等) |
  | ui | 3392 | 🟢 重 |
  | hud | 979 | 🟢 |
  | save | 993 | 🟢 |
  | run_meta | 791 | 🟢 |
  | event | 709 | 🟢 |
  | ap_economy | 717 | 🟡 单文件,需校验 |
  | tutorial | 581 | 🟡 |
  | npc | 548 | 🟡 |
  | card | 533 | 🟡 |
  | notification | 382 | 🟡 |
  | scene_flow | 277 | 🔴 单薄,核心总线还需补 |
  | scripts | 201 | — |

- `save-system` epic 的 16 stories **是被人(autopilot + 你 review)真验证过的**,active.md 里有详细 closing notes。这 16 个 + 12 个 a11y stories 是含金量最高的。

---

## 创意里的好东西(强烈推荐保留的设计点)

读 GDD 的优先级:

1. **`game-concept.md`** — 反向 KPI 的 core fantasy 立得住,核心循环写得很清楚
2. **`design/research/kpi-reverse-threshold-formula-proposal.md`** — KPI 反向阈值的数学推导,这是 mechanics 的灵魂,不能丢
3. **`design/research/ap-decision-space-analysis.md`** — AP 8 点 / 天的决策空间分析,balance 关键
4. **`design/gdd/event-script-engine.md`** + **`design/research/event-script-schema-proposal.md`** — 数据驱动事件 schema
5. **`design/gdd/npc-relationship-system.md`** — 关系网影响事件触发的设计
6. **`design/gdd/hud-diegetic.md`** — diegetic HUD(信息融入场景而非屏幕角)的视觉方向
7. **`design/art/art-bible.md`** — 像素美术规范

stories 里也有不少好东西(具体 AC、edge case 处理、anti-pattern 防护),但建议**用的时候按需读,不要再当 sprint backlog 一条条按 framework 流程跑**。

---

## 怎么继续(脱 framework 路径)

如果你想真把这个游戏做出来,推荐绕过所有 ceremony:

### 1. 让 Godot 项目能跑
- 这堆代码缺 `project.godot` — 需要新建一个 Godot 4.6 工程,把 `src/` `assets/` `addons/` 拖进去
- 装 `gdunit4` addon(`addons/gdunit4` 目前空缺)
- 跑一次 `tests/smoke/critical-paths.md` 列出来的 smoke,看哪些 fail

### 2. 选一个最小可玩切片
不要 17 个 MVP 系统全做。**最小可玩 = 6 个系统**:
- Save(已有,真的)
- Input(基本就绪)
- Scene & Day Flow(单薄,需补)
- AP Economy(基本就绪)
- KPI 反向阈值(算法已设计 + 部分代码)
- 一个最简陋 HUD(显示 AP / 当前 KPI / 天数)

跑通**一天的循环**(早上 8 AP → 选 3-4 张行动卡 → 晚上结算 KPI → 看是否被开除/涨阈值)。这一刻你才真正知道反向 KPI 这个核心 fantasy 玩起来对不对劲。

### 3. 砍掉 framework 残骸
扔掉所有跟 epic / story / ADR governance / autopilot / agent / skill 相关的 ceremony。
**保留**: 设计思考(GDD / 公式 / 美术)+ 真代码 + 测试。
**扔掉**: `Status:` field、Manifest Version、Governing ADRs、acceptance criteria checklist 这些 paperwork。当普通注释看就行,不要再当 process 跑。

---

## 不在这个抢救包里的东西

- 整个 `.claude/` 配置(48 agents + 64 skills + hooks)— framework 本身,不要
- `tools/autopilot.sh` — 跨 session 跑 claude 的脚本,如果想保留可以单独 copy,但不建议继续用这个工作流
- `production/session-state/` `production/session-logs/` `production/handoffs/` `production/qa/`(部分)— framework 工件
- `CLAUDE.md` 顶层 framework 配置 — 不要

如果之后发现某个文件漏了,原项目还在 `/Users/huanghaibin/Workspace/games-studio/`(只是不要再用它的 process)。

---

## 一句话总结

**创意是好创意,代码也写了不少。被 framework 拖累的不是想法,是流程。把 ceremony 全部丢掉,Godot 工程化继续做,游戏能成。**
