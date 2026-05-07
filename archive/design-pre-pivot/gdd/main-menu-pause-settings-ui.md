# Main Menu / Pause / Settings UI

> **Status**: Designed (pending review)
> **Author**: user + main agent + game-designer (full GDD) + ux-designer (UI Requirements) + systems-designer (Edge Cases) + qa-lead (Acceptance Criteria)
> **Last Updated**: 2026-04-28
> **Layer**: Presentation | **Order**: #17 | **Size**: S
> **Implements Pillar**: P5 主(地铁可玩性 — 5 秒进入承诺 + 5 秒暂停语义) + P1 守(Settings 零交互 AP/KPI 调节红线) + P4 守(HR 口吻 + 主语翻转原则)
> **Authoring autonomy mode**: v2 no-prompt(总 widget 数: 0,routine autopilot)
> **Review Mode**: Lean (CD-GDD-ALIGN skipped per `production/review-mode.txt`)

---

## Section A — Overview

**双重身份**: 技术层面,Main Menu / Pause / Settings UI 是《活过第 X 集》**唯一的游戏外壳屏** —— 玩家在 Run 之间 / Run 内暂停 / 调整体验参数时驻留的空间。它管理主菜单 4 入口(新 Run / Continue Run / Archive / Settings + 退出)、游戏中 Pause 子屏("摸鱼"语义)、Settings 子屏(4 类设置:音量 4 旋钮 / 语言切换 / 键位 remap / 叙事密度)、以及 Archive 入口(转 #16 KPI Review & Game Over UI)。叙事层面,它是**极简 HR 系统外壳** —— 连主菜单按钮措辞都服从"主语翻转 + HR 口吻"原则,让玩家在启动游戏和暂停游戏的那几秒钟里不脱离"打工"语境。

本 GDD 是以下 cross-system 契约的**消费方**:
- `#1 Save System` — load Run / new Run 入口行为 / Archive 列表数量上限 / `archive_hard_cap_count = 200`
- `#2 Input Handler Rule 7` — MODAL_LOCKED 协议(Settings 打开时 Pause 子屏处于 MODAL_LOCKED) / `Rule 8` — keymap remap UI(全游戏唯一的 keymap remap 屏在本 GDD Settings 子屏内)
- `#3 Localization Hooks Rule 5` — locale switch UI(全游戏唯一的语言切换 UI 在本 GDD Settings 子屏内)
- `#4 Audio Manager Rule 2` — 4 bus 音量旋钮(Master / Music / Ambient / SFX);本 GDD emit `bus_volume_changed` 信号供 Audio 响应
- `#5 Lighting` — 主菜单 sub-mode = `MAIN_MENU`,对应中性灰 CanvasModulate
- `#6 Scene & Day Flow Rule 5` — Settings 打开调用 `SceneDayFlowController.request_soft_pause("settings_open")` + 关闭调用 `request_soft_resume()` / `Rule 7` — 本 GDD emit 4 类 settings 信号合流至 Scene Flow 单 debounce timer(500 ms 落盘)
- `#7 AP Economy I-7` — Settings **零交互**,不暴露任何 AP / Energy 调节旋钮(Pillar 1 红线,PR-blocking)
- `#9 KPI System` — Settings **零交互**,不暴露任何 KPI 阈值 / 成绩 knob(Pillar 1 红线,PR-blocking)
- `Save Rule 14` — settings 防抖单 timer 归属 `#6`,本 GDD 只 emit 信号,不独立防抖

**本 GDD own 的 UX 屏**: main-menu / pause-screen / settings-screen / remap-screen。

### 5 NOT 边界(scope creep 防护)

- **NOT** 游戏内 HUD(由 #13 HUD System own;主菜单 / Pause 屏不显示 AP 状态 / KPI 进度条)
- **NOT** KPI / AP 调节(由 Pillar 1 红线封死;Settings 只调体验参数,不调游戏数值)
- **NOT** 卡 UI / 行动卡操作(由 #14 Card Play UI own;主菜单和 Pause 屏不允许打牌)
- **NOT** 月末 KPI Review / Game Over 流程(由 #16 KPI Review & Game Over UI own;本 GDD 仅提供 Archive 入口)
- **NOT** NPC 操作(本系统无任何 NPC 状态读写;NPC 关系由 #8 own,Run 进行中 Pause 屏不可操作 NPC)

### 5 NOT 红线(违反即破坏 Pillar,PR-blocking)

- **NOT** 在 Settings 暴露任何 AP / Energy / KPI 数值调节(违反 Pillar 1 "无永久成长 / 无数值调节"铁律)
- **NOT** 提供"作弊菜单" / "快速最大化 AP"入口(同违 Pillar 1;无论以"便利功能"包装均拦截)
- **NOT** 允许音量旋钮超过 100%(Master bus 上限 0 dB,禁止 boost 超 0 dB 失真)
- **NOT** 在 keymap remap 屏提供"超能力键位"(remap 仅换 act_* 的物理键,不改 action 语义)
- **NOT** 在 Pause 子屏内推进任何游戏时间(Pause 语义 = 时间完全冻结;Rule 3 + `#6 Rule 6` 联合守门)

### Source 引用

`design/gdd/game-concept.md` Pillars P1/P4/P5 + `design/gdd/scene-day-flow-controller.md` Rule 5/6/7 + `design/gdd/save-system.md` Rule 14 + `design/gdd/input-handler.md` Rule 7/8 + `design/gdd/audio-manager.md` Rule 2 + `design/gdd/localization-hooks.md` Rule 5 + `design/gdd/lighting-visual-state.md` Rule 1(`MAIN_MENU` sub-mode 色值) + `design/gdd/ap-economy-system.md` I-7(Settings 零交互声明) + `design/gdd/kpi-reverse-threshold-system.md`(Settings 零交互声明) + `design/registry/entities.yaml`(`meta_settings_debounce_ms = 500`)。

---

## Section B — Player Fantasy

### 主锚: "Loading 三秒,你就在工位了"(5 秒进入承诺 — Pillar 5 主锚)

**场景**:
手机解锁,图标点开。没有 Loading 进度条数字,没有"Press Any Key to Continue",没有公司 Logo 3 秒淡入淡出。黑屏 2.5 秒,淡入 —— 主菜单,一张办公室风格的界面,日期是"星期三"。按钮只有 4 个。没有一个叫"开始游戏"。**上一局的"继续上班"还在第一位**,颜色比其他按钮深一点,像一封还没关掉的 WPS 文档。

**Pillar 服务**:
- **主 P5 地铁可玩性**: 5 秒进入承诺的视觉对应 —— 主菜单不给你"准备游戏"的仪式感,因为现实里你也没有
- **守 P4 黑色幽默**: 按钮文案服从 HR 口吻("继续上班" / "入职新员工" / "查阅人事档案"),玩家第一次看到会停一下

**跨 GDD 共振**:
- `#6 Scene & Day Flow` "9:17 你已经在工位上了" 同向 —— 主菜单已经是工位的一部分,不是去工位前的等待室
- `#5 Lighting` 中性灰 `MAIN_MENU` sub-mode —— 没有游戏首屏的高对比度 splash 光效
- `#4 Audio` 主菜单 ambient —— 不是片头音乐,是办公室底噪

**❌ Tone 风险(必避)**:
- "开始游戏"、"新游戏"、"Play Now"(过于游戏感,破坏 HR 外壳)
- Logo 3 秒 + 过场动画 + 公司 Slogan(仪式感 = 高期待 = P5 承诺破防)
- 主菜单 BGM(Audio Rule 7 白名单外禁 BGM)

**✅ Tone 守护(推荐)**:
- "继续上班"(不是"继续游戏")、"入职新员工"(不是"新游戏")
- 无动画 / 即时显示(像 WPS 打开文档,不像游戏开场)

### 副锚: "摸鱼"而非"暂停"(Pause 子屏 — P4 黑色幽默副锚)

**场景**:
游戏中,Pause。屏幕弹出一个小浮层 —— 不叫"游戏暂停",标题是"摸鱼中"。背景是轻度模糊的 ACTION_DAY 场景,像真的在摸鱼时把工作压到屏幕后面。只有 3 个选项:"继续上班" / "回到工位" / "人事档案"(Settings)。**没有"放弃"按钮** —— 因为 Run 中没有放弃这个动作(跑到 GAME OVER 才是结束)。

**Pillar 服务**:
- **守 P4 黑色幽默**: "摸鱼中"这三个字让 Pause 的语境被吸收进工位叙事里
- **守 P5 地铁可玩性**: Pause 不打断进度,再按继续无缝衔接

**❌ Tone 风险(必避)**:
- "游戏暂停"、"Pause"(直白游戏术语,破坏 HR 外壳)
- 暂停期间显示 AP 进度 / KPI 当前值(违反 Pause 子屏 NOT HUD 边界)
- 暂停期间可以打牌 / 操作 NPC(违反 Pause 零游戏推进红线)

**✅ Tone 守护(推荐)**:
- "摸鱼中"(Pause 标题)/ "继续上班"(Resume)/ "回到工位"(Exit to Menu)
- 背景模糊而非黑屏

### 玩家不会说的话 / 会说的话

- ❌ "主菜单好看!"、"暂停界面设计精美!"
- ❌ "音量调节一下就保存了"(沉默就是通过)
- ✅ "这游戏按暂停叫摸鱼,我笑了。"
- ✅ "按钮文案太像 HR 系统了。"

---

## Section C — Detailed Rules

### Core Rules

**Rule 1 — 主菜单 4 入口 + 退出**

主菜单常驻显示 4 个功能入口,按显示顺序:

| 显示文案 | 游戏术语 | 可用条件 | 行为 |
|----------|---------|---------|------|
| 继续上班 | Continue Run | `current_run.save` 存在 | 调 `Save.load_run()` → `#6 Rule 4` 启动序列 → `ACTION_DAY` 恢复 |
| 入职新员工 | New Run | `archive_count < archive_hard_cap_count(200)` | 若 `current_run.save` 存在 → 弹确认对话框;确认放弃 → Save archive 上局 → 新 Run 初始化 |
| 查阅人事档案 | Archive | 始终可用 | 切至 Archive 列表屏(#16);档案柜满时显示满员提示 |
| 人事档案设置 | Settings | 始终可用 | 打开 Settings 子屏(Rule 4) |
| — | Quit | PC 平台始终显示 | `get_tree().quit()` |

禁止额外入口:MVP 不提供"成就" / "排行榜" / "商店"等入口。Settings 子屏内不含"回到主菜单"(Settings 关闭后回到触发它的上层屏:主菜单或 Pause)。

**Rule 2 — 5 秒进入承诺(`#6 Rule 4` Loading Scene 启动序列)**

主菜单在 `scene_state_changed(LOADING → MAIN_MENU)` 信号后立即显示(不额外等待动画)。`#6 Rule 4` 启动序列 budget 已约束:meta load + 4 系统 preload ≤ 250 ms(P5 5 秒进入承诺内)。主菜单页面本身渲染无附加动画 —— 黑屏淡入至主菜单 ≤ 500 ms 内完成(配合 Lighting `MAIN_MENU` 中性灰)。

**Rule 3 — Pause 子屏("摸鱼中")**

游戏进行中(`ACTION_DAY` / `ACTION_OVERTIME` / `AFTER_WORK` / `DAILY_RECAP` / `MORNING_BRIEFING` sub-mode)玩家触发 `act_pause`:

1. 调 `SceneDayFlowController.request_soft_pause("act_pause")` → `#6` 下发 `soft_pause_requested`,`SceneTree.paused = true`
2. Pause 子屏浮层显示,Input 进入 `MODAL_LOCKED`(Input Rule 7)
3. 背景轻度模糊(实现由 `#OQ-MM-1` 决定)
4. 显示 3 选项:"继续上班"(resume) / "回到工位"(exit to main menu) / "人事档案"(open Settings)

**Pause 子屏限制**:
- 不显示任何 AP / KPI / NPC 状态(零游戏内 HUD)
- 不允许打牌 / 操作 NPC(零游戏推进)
- 不提供"放弃本局"直接按钮(须走"回到工位" → 主菜单 Rule 1"入职新员工"的确认对话框)
- `KPI_REVIEW` / `GAMEOVER` sub-mode 期间 `act_pause` 被拦截,Pause 子屏不弹出(`#6 Rule 10` 月末锁 + `Rule 11` GAMEOVER 终态)

**恢复流程**: "继续上班" → 调 `request_soft_resume()` → `SceneTree.paused = false` → Input 退出 `MODAL_LOCKED` → Pause 子屏隐藏

**Rule 4 — Settings 子屏(4 类设置)**

Settings 子屏从主菜单或 Pause 打开,均走同一套屏。打开时:
1. 若从游戏进行中打开:调 `SceneDayFlowController.request_soft_pause("settings_open")`;若从主菜单打开:SceneTree 已非游戏运行态,skip pause 调用
2. Input 进入 `MODAL_LOCKED`

**Settings 子屏 4 类分组**:

**A — 声音环境(4 旋钮)**:

| 旋钮文案 | 对应 Bus | 范围 | 默认值 | 信号 |
|----------|---------|-----|-------|-----|
| 总音量 | Master Bus | 0–100% → (-∞ ~ 0 dB) | 80% | `bus_volume_changed("master", db)` |
| 音乐 | Music Bus | 0–100% | 70% | `bus_volume_changed("music", db)` |
| 环境音 | Ambient Bus | 0–100% | 75% | `bus_volume_changed("ambient", db)` |
| 音效 | SFX Bus | 0–100% | 85% | `bus_volume_changed("sfx", db)` |

旋钮拖动时内存立即生效(Audio Bus 实时反馈);磁盘写入由 `#6 Rule 7` 防抖单 timer 500 ms 后合并落盘。0% = `AudioServer.set_bus_mute(true)`;100% = 0 dB 上限,禁 boost 超 0 dB。

**B — 工作语言(locale switch)**:

选中新 locale → 调 `TranslationServer.set_locale(locale)` → emit `locale_changed(locale)` → `#3 Localization Rule 5` 接管 switch 协议(dispatch ≤1 帧,reflow ≤500 ms)。`locale_changed` 同样合流至 `#6 Rule 7` 防抖单 timer。MVP 仅 `zh_CN` 可选;野心版扩 `en`。

**C — 操作习惯(keymap remap —— 全游戏唯一的 remap 屏)**:

对应 `Input Handler Rule 8` 的 keymap remap UI。进入 remap 子屏:
1. 显示全部 `act_*` 动作与当前物理键绑定
2. 玩家点击某行 → 进入"等待按键"状态(该行高亮,`MODAL_LOCKED` 维持)
3. 捕获下一个 `InputEventKey` 或 `InputEventJoypadButton`:
   - 冲突检测:若新键已绑定其他 `act_*` → 弹确认"是否覆盖 [act_X]?"
   - 确认后:`InputMap.action_erase_events(old)` + `action_add_event(act, new_event)` + emit `keymap_changed(act_name, new_event)`
   - 取消:不变(InputMap 回滚)
4. `keymap_changed` 合流至 `#6 Rule 7` 防抖单 timer 500 ms 落盘

禁止:remap 不可改变 `act_*` 语义;`act_pause` 等核心动作不允许 unbind 到空键位。

**D — 阅读密度(Narrative Density)**:

| 档位 | 行为 |
|-----|-----|
| `flash` | 事件文本仅显示关键词 + 数字(最短模式) |
| `long`(默认) | 完整叙事文本(art bible §7.3 标准模式) |
| `numeric_only` | 仅显示数值差值(策略极简模式) |

切换 → emit `narrative_density_changed(density: StringName)` → 合流至 `#6 Rule 7` 防抖单 timer 落盘。叙事密度不影响 AP / KPI 计算,仅影响文本 + 事件过场渲染详细度。

**Rule 5 — Settings 零交互:禁止暴露 AP / KPI / Energy 调节(Pillar 1 红线,PR-blocking)**

Settings 子屏 4 类中**不存在任何**以下控件:

- AP 上限 / AP 恢复速率 / Energy 恢复速率旋钮
- KPI 基准阈值 / 阈值增速 / 结算周期调节
- 任何直接修改 Run 起始数值的选项(starting bonus / handicap / difficulty slider)

违反行为: 任何在 Settings UI 代码路径中读写 AP / KPI / Energy 相关变量的 pull request 判 PR-blocking FAIL,不得合并。CI lint(`tools/settings_ui_lint.gd`)扫描 Settings 场景节点树 grep `ap_` / `kpi_` / `energy_` 信号绑定并报错(AC-ROBUST-01 验证)。

**Rule 6 — Archive 列表入口(转 #16)**

主菜单"查阅人事档案"切换至 Archive 列表屏,设计由 `#16 KPI Review & Game Over UI` own,本 GDD 仅提供入口跳转逻辑:

- 入口始终可用(档案柜为空时显示"暂无员工档案")
- 档案柜满(200 局)时,主菜单"查阅人事档案"下方显示"档案柜已满(200/200)"提示,且"入职新员工"按钮置灰 + tooltip
- `#16 Archive 屏`关闭后回到主菜单

**Rule 7 — Settings 信号合流 Save Rule 14 防抖单 timer**

本 GDD emit 的 4 类信号全部合流至 `SceneDayFlowController._settings_debounce_timer`(500 ms,由 `#6 Rule 7` 统一管理):

| 信号 | emit 时机 | 消费方 |
|-----|---------|-------|
| `bus_volume_changed(bus_id: StringName, db: float)` | 音量旋钮值变化 | Audio Manager Rule 2 + Save Rule 14 |
| `locale_changed(locale: StringName)` | 语言切换选中 | Localization Hooks Rule 5 + Save Rule 14 |
| `keymap_changed(act_name: StringName, new_event: InputEvent)` | keymap remap 确认 | Input Handler Rule 8 + Save Rule 14 |
| `narrative_density_changed(density: StringName)` | 叙事密度切换 | Event Script #10 / Recap UI #15 + Save Rule 14 |

本 GDD 不独立防抖,不持有 Timer 节点 —— 仅 emit 信号。内存立即生效;磁盘写入走防抖路径。

**Rule 8 — 主语翻转 + HR 口吻 lint**

所有玩家可见文案必须通过主语翻转原则审查(`#6 Section B Internal Design Test`):

已锁定文案(不可修改):

| 游戏术语 | HR 口吻文案 | Localization key |
|---------|-----------|-----------------|
| Resume | 继续上班 | `UI.RESUME.BTN_LABEL` |
| New Run | 入职新员工 | `UI.NEWRUN.BTN_LABEL` |
| Archive | 查阅人事档案 | `UI.ARCHIVE.BTN_LABEL` |
| Settings | 人事档案设置 | `UI.SETTINGS.BTN_LABEL` |
| Pause(标题) | 摸鱼中 | `UI.PAUSE.TITLE_FISHSKIP` |
| Exit to Menu | 回到工位 | `UI.EXIT_TO_MENU.BTN_LABEL` |

子屏分组标题: "声音环境"(音量) / "工作语言"(语言) / "操作习惯"(remap) / "阅读密度"(叙事密度)。

**Rule 9 — dispatch ≤ 1 帧**

Settings 信号从用户操作到 Audio Bus / TranslationServer / InputMap 生效,整条链路在同一帧内完成(不经 `call_deferred`)。延迟路径(磁盘落盘)走 `#6` 防抖 timer,与即时路径解耦。

**Rule 10 — Scope Tier**

| Tier | 功能 |
|------|-----|
| **MVP** | 主菜单 4 入口 + Pause 子屏 + Settings 子屏 4 类(音量 / 语言 / remap / 叙事密度)+ Archive 入口 |
| **Vertical Slice** | Settings 子屏 UI 增强(旋钮动画 / 叙事密度实时预览)+ 主菜单背景升级为 art bible §2 场景截图缩略图 |
| **野心版** | 多 Ending 章节回顾入口(只读)+ 字体大小选项(移至 Accessibility #20) |

### States and Transitions

| State | Enter 条件 | Exit 条件 | 允许操作 |
|-------|-----------|---------|---------|
| `MAIN_MENU` | 冷启动 `scene_state_changed(LOADING→MAIN_MENU)` / Run 归档完成 / Pause 子屏选"回到工位" | 点击任意主菜单入口 | 4 入口点击 / Settings 打开 |
| `PAUSE` | `ACTION_DAY`~`MORNING_BRIEFING` sub-mode 中 `act_pause` | "继续上班"(resume) / "回到工位"(exit) | Resume / Exit to menu / Open Settings |
| `SETTINGS` | 从 `MAIN_MENU` 或 `PAUSE` 点"人事档案设置" | "关闭" / `act_cancel` | 音量旋钮 / 语言切换 / remap / 叙事密度 toggle |
| `REMAP` | Settings"操作习惯"分组点击某 act_* 行 | 按下新键确认 / `act_cancel` 取消 | 等待 InputEvent 捕获 / 冲突确认对话框 |

### Interactions

**与 `#1 Save System`**: 流出: 4 类 settings 信号(经 `#6` 防抖) → Save Rule 14;流入: `current_run.save` 存在与否 → "继续上班"可用态 / `archive_hard_cap_count` → "入职新员工"可用态

**与 `#2 Input Handler`**: Settings / Pause 打开 → Input `MODAL_LOCKED`;remap 子屏捕获 raw `InputEvent`(全游戏唯一绕过语义动作路径的场景);Settings / Pause 关闭 → `MODAL_LOCKED` 解除

**与 `#3 Localization Hooks`**: `locale_changed` emit → Localization Rule 5;所有 UI 文案使用 `tr(key)`,HR 口吻 key 含 `_HR` 后缀

**与 `#4 Audio Manager`**: `bus_volume_changed(bus_id, db)` → Audio Rule 2;Settings 打开 / 关闭:零 SFX(Pillar 4 + Audio Rule 3 红线)

**与 `#5 Lighting`**: `MAIN_MENU` sub-mode → Lighting 中性灰;`PAUSE` 子屏维持当前 sub-mode palette(`pause_tween()` 停止但保持当前色值)

**与 `#6 Scene & Day Flow`**: Settings / Pause 打开调 `request_soft_pause(source)` / 关闭调 `request_soft_resume()`;Rule 7 settings 防抖单 timer 归属 `#6`,本 GDD 仅 emit 信号;`KPI_REVIEW` / `GAMEOVER` sub-mode Pause 入口禁用

---

## Section D — Formulas

**N/A** — 本系统为纯 UI 状态 + 信号路由,无独立数学公式。

量化约束来自上游契约引用:
- 音量旋钮 dB 映射: `db = 20 * log10(pct / 100.0)`(标准对数,pct=0 时 = 静音 `-∞`);由 Godot AudioServer 接管,本 GDD 不重复定义
- 防抖: `meta_settings_debounce_ms = 500 ms`(entities.yaml 注册常量,引用不重定义)
- 主菜单淡入: `≤ 500 ms`(Rule 2 约束,属 `#6 Rule 4` P5 5 秒 budget 内)

---

## Section E — Edge Cases

### Cat 1 — Settings 信号合流与防抖 race

**E-1.1** 玩家在 500 ms 防抖窗口内连续拖动音量旋钮 + 切换语言: 所有信号复位同一 `_settings_debounce_timer`,仅触发 1 次合并写盘(内存实时生效,磁盘节流)。

**E-1.2** Settings 关闭时防抖 timer 尚未触发: Settings 关闭不强制 flush。若玩家立即关游戏(`WM_CLOSE_REQUEST`) → Save Rule 19 同步 flush 兜底(500 ms 超时内完成)。

**E-1.3** 防抖 timer 触发时 Save 处于 ARCHIVING 状态: Settings flush 请求进入 Save 等待队列,ARCHIVING 完成后依次执行(Save Rule 13 互斥)。

**E-1.4** 叙事密度信号到达 Event Script #10 / Recap UI #15 时 Run 未运行: 两系统在 `MAIN_MENU` sub-mode 下无活跃 Run,`narrative_density_changed` 仅更新内存 config,不产生副作用。下次 Run 启动时读取最新密度档位。

### Cat 2 — Pause race(与 `#6` / AP 系统)

**E-2.1** `act_pause` 与 `KPI_REVIEW` 转移同帧到达: `#6 Rule 10` 月末锁先行 —— `act_pause` 在 `KPI_REVIEW` sub-mode 无效(Input Rule 7 `MODAL_LOCKED` 已在 KPI_REVIEW 进入时设置)。Pause 子屏不弹出。

**E-2.2** Pause 子屏打开时收到 `scene_state_changed(→GAMEOVER)`: `GAMEOVER` 是终态(`#6 Rule 11`)。`#6` 发 `soft_resume_requested` 后强制关闭 Pause 子屏,路由至 GAME OVER 流程。Pause 子屏不得阻塞 GAMEOVER 转移。

**[RISK GUARD] R-MM-2 — E-2.3**: Pause 子屏打开期间(SceneTree.paused = true),Action Card tick / AP 扣减 / KPI 累积均被冻结(依赖 `#6 Rule 6` game-time tick 在 paused 期间不推进)。若任何游戏数值在 Pause 期间变化 → PR-blocking FAIL(AC-ROBUST-02 验证)。

**E-2.4** 玩家在 Pause 子屏连按 `act_pause`: 第一次进 Pause 子屏后 Input `MODAL_LOCKED` —— 后续 `act_pause` 被 Modal 吞,不产生重入。仅"继续上班"或 `act_cancel` 可 resume。

### Cat 3 — keymap remap UI edge

**E-3.1** 玩家尝试 remap `act_pause` 到已是默认 `act_pause` 的 Escape: 冲突检测提示"该键已绑定 act_pause",不允许自绑定,保持原键。

**E-3.2** 玩家 remap 后立即取消: `InputMap.action_erase_events` 已执行,取消键触发 rollback:调 `action_add_event(act, old_event)` 恢复。`keymap_changed` 信号不 emit(未确认)。

**E-3.3** 玩家尝试 remap `act_confirm` 到鼠标左键: remap 屏过滤 `InputEventMouseButton.button_index == MOUSE_BUTTON_LEFT`,提示"该键不可绑定到确认动作"。

**E-3.4** remap 覆盖确认后某 `act_*` 变无键位: UI 红色标记该行 + "未绑定"标签;游戏功能正常继续(不崩溃)。玩家可继续 remap 或"恢复默认"重置 InputMap。

**E-3.5** remap 子屏"等待按键"状态时游戏失焦(`WM_WINDOW_FOCUS_OUT`): `#6 Rule 5` 翻译 `soft_pause_requested("wm_focus_out")`;remap 子屏退出"等待按键"状态(不触发 remap),维持 `MODAL_LOCKED`。

### Cat 4 — Pillar 1 红线 lint(AP/KPI 防漏)

**[RISK GUARD] R-MM-1 — Settings 暴露 AP/KPI knob 漏入**:

CI lint(`tools/settings_ui_lint.gd`)扫描 Settings 场景节点树中任意 `Control` 节点的信号连接:

```
grep pattern: _pressed | value_changed | item_selected → method: *ap_* | *kpi_* | *energy_*
```

发现 → `push_error` + CI 失败 → PR 阻塞合并。Rule 5 = 设计守门,本 lint = 技术执行守门。

### Cat 5 — Archive 入口 edge

**E-5.1** 档案柜满(200 局),玩家点"入职新员工": 按钮置灰 + tooltip "档案柜已满,请先删除历代员工档案"。点击无响应。

**E-5.2** Archive 列表屏删除档案后计数变化: "入职新员工"实时响应 `archive_count_changed` 信号更新按钮状态(< 200 → 解锁)。

---

## Section F — Dependencies

### Upstream(本 GDD 依赖)

| # | 系统 | 契约 | 方向 |
|---|------|-----|-----|
| #1 | Save System | Rule 14(settings 防抖路径) / Rule 8(load Continue) / Rule 23(archive 200 cap) / ARCHIVING 状态机 | 双向 |
| #2 | Input Handler | Rule 7(MODAL_LOCKED) / Rule 8(keymap remap 捕获) | 双向 |
| #3 | Localization Hooks | Rule 5(locale switch UI) / Rule 2(`tr()` 纪律) | 单向消费 |
| #4 | Audio Manager | Rule 2(`bus_volume_changed` 接口) / Pillar 4 红线(零 SFX) | 单向 emit |
| #5 | Lighting & Visual State | Rule 1(`MAIN_MENU` 中性灰) / Pause 维持当前 palette | 单向消费 |
| #6 | Scene & Day Flow | Rule 5(`request_soft_pause/resume`) / Rule 7(防抖单 timer) / Rule 10/11(Pause 禁用条件) | 双向 |

### Downstream(本 GDD 被依赖)

| # | 系统 | 本 GDD 提供 |
|---|------|-----------|
| #16 | KPI Review & Game Over UI | Archive 入口跳转 |
| #20 | Accessibility Options | 继承 Settings UI 屏扩展(Alpha tier) |

### 双向一致性 cross-check

- `#6 Rule 7` 声明 settings 防抖单 timer 归属 `#6`,本 GDD Section C Rule 7 对应 ✓
- `#2 Rule 7` 声明 MODAL_LOCKED 协议,本 GDD Section C Rule 3/4 消费 ✓
- `#4 Rule 2` 声明 `set_bus_volume(bus_id, db)` 接口,本 GDD Section C Rule 4A emit 对应 ✓
- `#3 Rule 5` 声明 locale switch 协议,本 GDD Section C Rule 4B emit 对应 ✓
- `entities.yaml` `meta_settings_debounce_ms` `referenced_by` 须添加 `design/gdd/main-menu-pause-settings-ui.md`

---

## Section G — Tuning Knobs

| 旋钮名 | 类别 | 默认值 | 范围 | 来源 / 引用 |
|-------|-----|-------|-----|-----------|
| Master Bus 默认音量(%) | feel | 80 | 0–100 | 本 GDD Section C Rule 4A;100% = 0 dB 上限,禁 boost |
| Music Bus 默认音量(%) | feel | 70 | 0–100 | 本 GDD Section C Rule 4A |
| Ambient Bus 默认音量(%) | feel | 75 | 0–100 | 本 GDD Section C Rule 4A |
| SFX Bus 默认音量(%) | feel | 85 | 0–100 | 本 GDD Section C Rule 4A |
| 叙事密度默认档位 | feel | `long` | `flash` / `long` / `numeric_only` | 本 GDD Section C Rule 4D;`long` = art bible §7.3 标准模式 |
| Settings 防抖(ms) | gate | 500 | — | `entities.yaml` `meta_settings_debounce_ms = 500`;引用,不重定义 |
| 主菜单淡入时延(ms) | feel | 500 | 100–1000 | 本 GDD Rule 2;P5 5 秒 budget 内的 feel knob |

**Pillar 1 红线(不可调节)**:
- AP 上限 / AP 恢复率 / Energy 阈值 — 不在 Settings 暴露,不在本 GDD 作为 Tuning Knob 存在
- KPI 基准 / 阈值增速 — 同上

---

## Visual / Audio Requirements

### Lighting

- `MAIN_MENU` sub-mode: Lighting `Rule 1` 中性灰(`MAIN_MENU` palette,CanvasModulate);无累积视觉
- `PAUSE` 子屏打开: 背景维持当前 sub-mode lighting(不切换 palette;`pause_tween()` 保持当前色值)
- Settings / Remap 屏: 固定中性灰背景浮层(不透明)

### Audio

- 主菜单: `play_ambient("MAIN_MENU_AMBIENT")` —— 办公室底噪(非 BGM;Audio Manager `IDLE` Music sub-mode)
- Settings / Pause 打开 / 关闭: **零 SFX**(Pillar 4 + Audio Rule 3 红线)
- 旋钮拖动: Audio Bus 实时反馈即可;无额外 UI 音效
- locale 切换 / keymap remap 确认: 零 SFX

### 📌 UX Flag — Phase 4 必须输出以下 UX 设计文档:

- `/ux-design design/ux/main-menu.md` — 主菜单 4 入口布局 / 按钮尺寸 / 焦点链 / 档案柜满警示 UI
- `/ux-design design/ux/pause-screen.md` — Pause 浮层尺寸 / 背景模糊实现 / 3 选项焦点链
- `/ux-design design/ux/settings-screen.md` — Settings 子屏 4 分组布局 / 旋钮控件规格 / locale selector / 叙事密度 toggle(**与 Localization #3 / Audio #4 UX Flag 共用此文档**)
- `/ux-design design/ux/remap-screen.md` — keymap remap 列表布局 / 等待按键状态 / 冲突警告 / 无键位红色标记(**与 Input Handler #2 Rule 8 Phase 4 UX Flag 共用此文档**)

---

## UI Requirements

### Main Menu Screen

- 全屏 / 居中布局;4 入口按钮纵向排列
- 每按钮明确 focus 态(`#C8963C` 外框 2px,art bible §7.5)
- "继续上班"置顶;仅当 `current_run.save` 存在时 active(否则置灰,不隐藏)
- "入职新员工"档案柜满时置灰 + tooltip(Rule 6)
- 退出按钮在最底部(与游戏功能入口视觉分离)
- 版本号角落小字显示

### Pause Screen

- 居中浮层;背景半透明模糊(exact spec 由 UX 设计确认)
- 标题:"摸鱼中"(Localization key `UI.PAUSE.TITLE_FISHSKIP`)
- 3 按钮:"继续上班"(首位 / 默认焦点) / "回到工位" / "人事档案"
- Gamepad D-Pad 导航覆盖(3 按钮线性焦点链,`act_focus_up/down`)

### Settings Screen

- 覆盖当前屏;背景固定中性灰(不透明)
- 4 分组:"声音环境" / "工作语言" / "操作习惯" / "阅读密度"
- 旋钮:0–100% 范围标注,实时显示 dB 辅助值(小字)
- 关闭:`act_cancel` 或右上角关闭图标

### Remap Screen

- Settings"操作习惯"分组的列表子屏
- 每行:`act_*` HR 口吻展示 + 当前绑定键名 + 可点击区域
- 等待按键状态:高亮 + "按下任意键..."(Localization key `UI.REMAP.WAITING`)
- 无键位绑定行:红色标记 + "未绑定"标签
- "恢复默认"按钮:重置 InputMap + batch emit `keymap_changed`

---

## Open Questions

**OQ-MM-1** [ADR — Phase 3b 前决定] Pause 子屏背景模糊实现: Godot `BackBufferCopy + ShaderMaterial` vs `SubViewport 降采样`。两者性能开销不同,须 `#5 Lighting godot-shader-specialist` 确认与 palette swap shader 兼容性。影响 UX Flag `/ux-design design/ux/pause-screen.md` 实现约束。

**OQ-MM-2** [Scope / UX 确认] 主菜单是否需要动态背景(VS tier art bible §2 场景截图缩略图)?MVP 静态中性灰色块 + HR 标题文字即可,VS 升级需额外 art-director 资产产出。

**OQ-MM-3** [Narrative — Phase 3b] "入职新员工"确认对话框文案须服从 HR 口吻。候选:"上一局档案还在 / 继续上班(cancel) / 结束合同(confirm abandon)"。须 narrative-director 审校。

**OQ-MM-4** [#20 Accessibility] Settings 子屏是否在 MVP 留字体大小 / 对比度 UI 占位(功能未实装)?若留,避免 Alpha 追加时 Layout 大改。须 producer 在 Alpha kickoff 前决定。

---

## Section H — Acceptance Criteria

### AC-FUNC — 功能正确性(MVP 必测)

**AC-FUNC-01** 主菜单 — 入口可用性:
- Given `current_run.save` 不存在 / When 玩家打开主菜单 / Then "继续上班"按钮置灰,点击无响应

**AC-FUNC-02** 主菜单 — New Run 冲突对话框:
- Given `current_run.save` 存在 / When 玩家点"入职新员工" / Then 弹确认对话框;点 cancel → 不变;点 confirm → 旧 Run 归档 → 新 Run 初始化

**AC-FUNC-03** 主菜单 — 档案柜满时新 Run 禁用:
- Given `archive_count >= 200` / When 玩家打开主菜单 / Then "入职新员工"置灰,tooltip 显示,点击无响应

**AC-FUNC-04** 主菜单 — Archive 入口始终可用:
- Given 档案柜为空 / When 玩家点"查阅人事档案" / Then 显示"暂无员工档案"界面,不崩溃

**AC-FUNC-05** Pause 子屏 — 开启 / 关闭:
- Given `ACTION_DAY` sub-mode 进行中 / When `act_pause` / Then Pause 子屏显示,`SceneTree.paused = true`,Input `MODAL_LOCKED`
- Given Pause 子屏显示 / When "继续上班" / Then Pause 子屏隐藏,`SceneTree.paused = false`,MODAL_LOCKED 释放

**AC-FUNC-06** Pause 子屏 — KPI_REVIEW 期间禁 Pause:
- Given `KPI_REVIEW` sub-mode / When `act_pause` / Then Pause 子屏不弹出

**AC-FUNC-07** Settings — 音量旋钮实时生效:
- Given Music Bus 旋钮 70% / When 拖至 50% / Then Audio Bus Music 在同帧内变化(不等防抖)

**AC-FUNC-08** Settings — 音量磁盘防抖:
- Given 500 ms 内连续拖动 Music 旋钮 3 次 / When 500 ms 静默后 / Then `meta.save` 仅写入 1 次(Save Rule 14 日志断言)

**AC-FUNC-09** Settings — locale switch(野心版 en 路径;MVP `zh_CN` only 仅测控件存在):
- Given Settings 语言选择器 / When 玩家切换 locale / Then `locale_changed` emit → UI 文案即时刷新 → 500 ms 后磁盘落盘

**AC-FUNC-10** Settings — keymap remap 正流程:
- Given remap 子屏打开 / When 点 `act_confirm` 行 → 按 `F` 键确认 / Then `InputMap.action_get_events("act_confirm")` 包含 `F` key + `keymap_changed` 已 emit

**AC-FUNC-11** Settings — keymap remap 取消回滚:
- Given 进入等待按键状态 / When `act_cancel`(ESC) / Then InputMap 恢复原键,`keymap_changed` 未 emit

**AC-FUNC-12** Settings — 叙事密度切换:
- Given 叙事密度当前 `long` / When 切至 `flash` / Then `narrative_density_changed("flash")` emit → 500 ms 后磁盘落盘

### AC-PERF — 性能(MVP 必测)

**AC-PERF-01** 主菜单进入时延:
- Given `scene_state_changed(LOADING→MAIN_MENU)` 发出 / When 主菜单第一帧可见 / Then 时延 ≤ 500 ms

**AC-PERF-02** Settings 信号 dispatch ≤ 1 帧:
- Given Settings 子屏打开,Music 旋钮 `value_changed` / When 信号发出 / Then Audio Bus 音量在同帧(≤ 16.6 ms)内更新

**AC-PERF-03** Pause 开启帧耗时:
- Given `act_pause` 触发 / When Pause 子屏显示 + SceneTree.paused = true 完成 / Then 单帧耗时 ≤ 16.6 ms

### AC-ROBUST — 边界与防护

**AC-ROBUST-01** [RISK GUARD R-MM-1] Settings AP/KPI lint:
- Given CI 运行 `tools/settings_ui_lint.gd` / When 扫描 `SettingsScreen.tscn` 节点树信号绑定 / Then 不含 `*ap_* | *kpi_* | *energy_*` 信号/方法;违反 → CI FAIL

**AC-ROBUST-02** [RISK GUARD R-MM-2] Pause 期间零游戏推进:
- Given Pause 子屏打开(`SceneTree.paused = true`) / When 等待 3 帧 / Then AP 当前值 / game_time 累加器 / KPI 累加器均未变化

**AC-ROBUST-03** GAMEOVER 转移不被 Pause 阻断:
- Given Pause 子屏打开 / When `scene_state_changed(→GAMEOVER)` 触发 / Then Pause 子屏同帧关闭,GAMEOVER 流程不阻塞

**AC-ROBUST-04** remap 无键位警告不崩溃:
- Given 玩家 remap 使某 act_* 无绑定 / When 确认覆盖 / Then 该行红色"未绑定"标记;游戏功能正常继续

### AC-COMPAT — 兼容性(MVP 必测)

**AC-COMPAT-01** Gamepad 焦点链 — 主菜单:
- Given 手柄连接 / When `act_focus_up/down` / Then 主菜单 4 按钮可循环导航,`act_confirm` 触发对应行为

**AC-COMPAT-02** Gamepad 焦点链 — Settings 旋钮:
- Given 手柄连接,Settings 子屏打开 / When D-Pad 左右 / Then 音量旋钮值可调整(步长 5%)

**AC-COMPAT-03** Localization — HR 口吻 key 覆盖率:
- Given `zh_CN` locale / When Settings 子屏 / Pause 子屏 / 主菜单渲染 / Then 所有玩家可见文案使用 `tr(key)` 路径,无硬编码字符串(lint 验证)

### AC-TONE — 主语翻转 + HR 口吻(Advisory)

**AC-TONE-01** 按钮文案审查:
- Given 主菜单渲染 / When QA 人工检查 4 按钮文案 / Then 无游戏术语("开始游戏" / "设置" / "Pause" / "Quit");符合 HR 口吻白名单

**AC-TONE-02** Pause + Settings 零 SFX:
- Given Pause 子屏打开 / 关闭 / Settings 控件操作 / When audio-director 听测 / Then 全程无 SFX 播放

**AC-TONE-03** Settings 零 AP/KPI 旋钮(人工):
- Given QA 枚举 Settings 子屏全部 Control 节点 / When 人工检查 / Then 无任何 AP / KPI / Energy 调节控件
