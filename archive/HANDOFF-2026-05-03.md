# HANDOFF — 给下一个接手的人 / Agent

*Last updated: 2026-05-03*

---

> **2026-05-03 (post-engine-switch):** Godot tree (`src/`, `tests/`, `addons/`, `project.godot`, `.godot/`, `assets/data/`, `assets/shaders/`, `design/research/`, sprite `.import|.uid` metadata) physically deleted from working tree. New TS+PixiJS+Tauri stack lives in `game/` per `docs/superpowers/specs/2026-05-03-engine-switch-design.md`.

---

## 这是什么项目

**《活过第 X 集》(Survived Episode X)** — 像素风反向 KPI 中国职场生存模拟。
玩家扮演中年老油条,每天 8 AP 在"被开除"和"太优秀下关被涨 KPI"间走钢丝。
**胜利条件 = 维持平庸活得久**。

完整 elevator pitch:`design/gdd/game-concept.md`
不要再当大型项目管,这是 indie 单人项目。

---

## 这次 session 做了什么

1. **从前一个项目 `games-studio/` 抢救出全部产出物**(2 周成果,被 framework ceremony 拖累的那个项目)
2. **验证 GPT-IMAGE-2 + DeerAPI 可以批量产 MVP 美术**($0.45 出 10 张大图 / 54+ 切片 sprite)
3. **建立切图工作流 + 风格指南**(`tools/cut_sprites.py` + `assets/sprites/STYLE_GUIDE.md`)

---

## 当前状态(谁有什么)

### ✅ 设计 / 创意 — 完整
- `design/gdd/game-concept.md` — 游戏概念
- `design/gdd/systems-index.md` — 20 系统索引
- `design/gdd/*.md` — 20 个系统 GDD(每个都有详细规则)
- `design/research/` — 关键算法推导(KPI 反向阈值公式 / AP 决策空间 / event schema)
- `design/art/art-bible.md` — 美术圣经(palette / 9 NPC 剪影规则 / 喜丧美学)
- `design/registry/entities.yaml` — 实体注册表

### ✅ 架构思路 — 完整(但形式可重选)
- `architecture/architecture.md` — 整体架构
- `architecture/adr-0001..0017.md` — 17 个架构决策
- `architecture/tr-registry.yaml` — 139 个技术需求
- `architecture/control-manifest.md` — 实施 dos/don'ts

**注意**:这些 ADR 都是写得很完整的工程文档,但**当时是按 enterprise 治理流程写的**。接手时不要被它们绑架 — 把它们当**回忆笔记**而不是宪法。重要决策(JSON-primary save / autoload init order / KPI 公式)汲取就好,治理 ceremony 全部丢掉。

### ⚠️ 代码 — 写了但未必跑过
- `src/` — 76 .gd 文件 / 18,609 行 GDScript / 12 个系统目录
- `tests/` — 226 .gd 测试 / 41,147 行(integration 127 + unit 99)
- **但**:`gdunit4` addon 没装,大部分测试**从未跑过**
- **但**:**没有 `project.godot`** — Godot 项目从未真正打开过这套代码

各系统代码量参考(README.md 里有):
- 重的:`autoload`(9466 行,SaveSystem 1700+)、`ui`(3392)、`hud`(979)、`save`(993)
- 单薄但核心:`scene_flow`(277,核心总线)— 优先补
- 中等:run_meta / event / ap_economy / tutorial / npc / card / notification

### ⚠️ Stories — 大量素材,不是 backlog
- `stories/` — 20 epics × 234 story files
- 每个 story 都有 ACs / 边界 case / Test Evidence path
- **但 Status field 是 enterprise framework 留下的,不要再当 sprint backlog 跑**
- **正确用法**:当**实施细节素材库** grep 用,需要写某个系统时翻对应 story 找有没有写好的边界 case / 验收条件

### ✅ 美术 — MVP 资源已就位
- `assets/sprites/test_outputs/` — 10 张 1024×1024 大图(原始)+ 11 个 .prompt.txt 存档
- `assets/sprites/character/` — 13 主角 sprite(6 表情 + 4 姿势 + 3 状态)
- `assets/sprites/character/turnaround/` — 8 张三视图 + 配饰特写
- `assets/sprites/npc/` — 9 NPC 原型(boss/hr/tryhard/slacker/toady/rookie/veteran_coworker/cleaning_auntie/other_dept_rep)
- `assets/sprites/cards/defense/` — 9 防御卡
- `assets/sprites/cards/offense/` — 9 进攻 + 关系卡
- `assets/sprites/maps/office_floor_map.png` — 办公室俯视图
- `assets/sprites/ui/character_detail_page.png` — UI mockup(可切多个 element)
- `assets/sprites/scenes/` — 3 cutscene(月会 / 加班 / 双 GAME OVER)

**美术风格**:现代 indie pixel art(类似 Stardew Valley / Eastward 精度),不是 NES 古风。
**严格调色板** + 9 NPC 剪影规则 + 喜丧美学 — 全部固化在 `assets/sprites/STYLE_GUIDE.md`。

### ❌ 还没有的东西
- `project.godot`(Godot 工程文件)
- `addons/gdunit4`(测试框架)
- 音频资源(用户用 minimax API 生成,有 prompt 就行)
- 切图后再细化的单个 sprite 手修
- 大量场景图(剧情触发 / 各种特殊事件场景)
- 更多行动卡(目前 18 张,art-bible 没硬性数量要求,看玩法平衡)

---

## 接手第一阶段:让 Godot 项目跑起来

按以下顺序做,**不要跳步**:

### Step 1 — 建 Godot 工程
- 创建 `project.godot`,Godot 4.6 stable
- 配置 6 核心 autoload(其它先不挂):
  - SaveSystem(`src/autoload/save_system.gd`)
  - EventBus(找一下 src 里的 bus,可能在 autoload)
  - SceneFlow(`src/scene_flow/`)
  - APEconomy(`src/ap_economy/`)
  - KPISystem(可能在 src 各处,需要拼装)
  - InputHandler(`src/scripts/` 或 autoload)
- 不挂的:tutorial / notification / a11y / lighting / audio(都先不要,minimum 跑通)

### Step 2 — 装 gdunit4
- 下载 gdunit4 addon 到 `addons/gdunit4/`
- 跑一次 `tests/smoke/critical-paths.md` 列的 smoke test
- 看哪些 fail,修最痛的几个

### Step 3 — 一天循环占位 demo
**不要追求美**,用 `assets/sprites/` 现有 sprite 拼出一个 UI,跑通:
1. MAIN_MENU 场景(用 `assets/sprites/scenes/monthly_review.png` 当背景占位也行)→ "开始" 按钮
2. DAY_SCREEN 场景:
   - 显示 8 AP 余额(用 `character_detail_page.png` 切的灯泡 icon)
   - 显示 KPI 三轨(切详情页的进度条)
   - 4 张行动卡(用 `cards/defense/` 4 张当起手牌)
3. 选卡 → AP 减 → 卡效果触发(简单 stub 即可,别真改 KPI)
4. "结束今日" 按钮 → KPI 结算屏(`scenes/monthly_review.png` 占位)
5. 第二天 / GAME OVER 选择(`scenes/game_over_split.png` 占位)

**这一刻你才真正知道反向 KPI 玩起来对不对劲**。

### Step 4 — 反馈给用户
做完 Step 3 给用户一个能跑的 build,**让他亲手玩 5 分钟**。他会告诉你接下来调什么。

---

## 接手不能做的事(必须回去问用户)

- **修改 GDD / art-bible / ADR** — 这是用户的创意核心,改之前问
- **删 stories/** — 那是 234 个素材库,即使不当 backlog 跑,内容仍有价值
- **重新生成美术** — 用户付钱跑 API,大批量生成前确认
- **改风格调子** — STYLE_GUIDE 是定调成果,不要擅自变
- **加 framework / process** — 用户刚从 enterprise framework 泥潭里出来,**不要再加 epic / sprint / governing rules**。最多一个 `TODO.md`

---

## 接手能做的事(直接做不用问)

- 写 / 改 GDScript 代码(`src/`)
- 写 / 改测试(`tests/`)
- 配置 Godot 工程文件 / 场景 .tscn / 资源 .tres
- 装 addons(gdunit4 等)
- 切图微调(`tools/cuts.yaml` 改参数 + 重跑 `cut_sprites.py`)
- 修 sprite 单文件(用 PIL / 推荐 Aseprite)
- 写 prompt 套 STYLE_GUIDE 模板(用户付钱后调 API)

---

## 关键文件 quick ref

| 想干啥 | 看哪 |
|---|---|
| 游戏概念 / 核心 fantasy | `design/gdd/game-concept.md` |
| 系统列表 / 优先级 | `design/gdd/systems-index.md` |
| 某个系统具体规则 | `design/gdd/<system-name>.md` |
| KPI 数学 / AP 平衡 | `design/research/*.md` |
| 美术规范 | `design/art/art-bible.md` |
| 写新美术 prompt | `assets/sprites/STYLE_GUIDE.md` |
| 切图配置 | `tools/cuts.yaml` |
| 重跑切图 | `python3 tools/cut_sprites.py` |
| 调 GPT-IMAGE-2 | STYLE_GUIDE §6 有 snippet,key 在 `~/.zshrc` 的 `DEERAPI_KEY` |
| 架构决策 why | `architecture/adr-*.md`(回忆笔记,不是宪法) |
| story 找边界 case | `grep -r "<关键词>" stories/` |

---

## 用户偏好(重要)

- **不喜欢 ceremony**,不要写 sprint plan / epic breakdown / status report 这种 framework 工件
- **喜欢直接动手 + 看结果**,不喜欢长 discussion
- **报告用简体中文**,技术术语和代码标识用英文
- **喜欢轻量工具**(单文件 Python 脚本 OK,框架不 OK)
- **API key 等 secret 用 env var**,不要 hardcode 进文件
- **错误时直说**,不要美化或 framework-style "verdict / status / phase"

---

## 一句话

**美术、设计、架构、代码、研究 — 都已就位。**
**接手第一件事:让它在 Godot 里真的跑起来。** 第一个能玩的 build 比任何文档都重要。

祝玩得开心,别再陷泥潭了。
