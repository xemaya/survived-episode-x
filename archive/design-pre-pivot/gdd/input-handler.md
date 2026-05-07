# Input Handler

> **Status**: **Approved (2nd lean review 2026-04-24 → APPROVED, 0 blocker / 5 recommended / 2 nice-to-have — all advisory, do not block Foundation #3-5 design)**
> **Author**: user + main agent + creative-director (B framing) + systems-designer × 3 (C Core Rules / D Formulas / E Edge Cases) + gameplay-programmer (C feasibility) + engine-programmer (C Godot 4.6 engine integration) + qa-lead (H Acceptance Criteria)
> **Last Updated**: 2026-04-24
> **Implements Pillar**: Pillar 5 (地铁可玩性 — ≤1 帧响应、任意键跳过、5 秒进入) [primary] + Pillar 4 (黑色幽默 tone 守护 — Anti-Pillar 防线: 不做 QTE / 节奏 / 反应类) [guard]
> **Review Mode**: Lean (CD-GDD-ALIGN skipped per `production/review-mode.txt`)

## Overview

Input Handler 是《活过第 X 集》输入域的统一抽象层,坐于 Godot 4.6 `InputMap` 之上,把所有玩家输入设备(键盘 / 鼠标 / 手柄)归一为一组语义动作(`act_confirm` / `act_cancel` / `act_pause` / `act_skip` / `act_focus_next` 等),并管理 4.6 引入的**双焦点路径语义**——鼠标/触屏焦点 与 键盘/手柄焦点物理分离时,本系统是唯一对两路径焦点意图做仲裁的入口。所有上层系统(Scene & Day Flow 心跳、Main Menu 导航、HUD diegetic 焦点环、Card Play 出牌、Recap / KPI Review UI 翻页)只消费语义动作与焦点状态,不直接读 raw `InputEvent`。

本系统是 Pillar 5(地铁可玩性)的**技术执行层**:它直接落地两条硬约束——按钮 / 焦点 / confirm ≤1 帧响应(art bible §7.4 即时反馈铁则)、所有 ≥2 秒演出动画支持任意键跳过(§7.4 跳过铁则)。同时它是 Anti-Pillar 3(无 QTE / 节奏 / 反应类操作)的语义守门员:Input Handler 故意不暴露任何"按键时序窗口" / "组合键 combo" / "押键蓄力"原语,迫使任何后续系统若想加反应类机制必须先改本 GDD。

Input Handler **不**自管文件:keymap / 设置(灵敏度、双击窗口、默认布局选择)的持久化全部经 Save System 接口写入 `meta.save`(Save Rule 14 已锁定"玩家改设置(... gamepad 布局)"为 meta 异步路径,500 ms 防抖)。

*技术实现细节(dual-focus 4.6 具体绘制 API、Steam Input 拦截策略、keymap 序列化格式与默认值表)留给 ADR 阶段决定;本 GDD 只锁定行为语义与跨系统契约。*

## Player Fantasy

Input Handler 服务两类玩家瞬间,共享同一种 tone:**冷静、不抢戏、对比工位语境的低期待**。它不是被赞美的对象,是不被注意到的承诺。Save System 兑现了"加班丢手机不丢档"的承诺;Input 兑现的是更细一格——"按下去就生效、按一下就跳完"。

### 工位上唯一不卡的东西(Pillar 5)

工作日里的每一个工具都迟钝:WPS 保存按钮卡 6 秒、钉钉切窗 2 秒白屏、HR 系统点一下要等"加载中..."。玩家对"工具响应"的预期已经被现实磨到接近零。

周二晚 10 点,他刚被 leader 在群里 @ 完,WPS 弹"未响应"对话框。他切到游戏,按 ESC 跳过开场——黑屏立刻消失,光标已经在第一张便利贴上。他没有意识到这件事,但**正是这一帧没有空白**让他第二天还会再打开。早高峰地铁急刹,手肘撞到屏幕误触三个键——游戏没崩、没弹"是否继续"、上一帧的 KPI 数值还在,他继续打卡。Input 不是一种愉悦,是把"工具一定会卡"这个工位常识反转一次;反转的代价是他注意不到。

### 跳过的权利(Pillar 5)

工作日里他被强制坐完晨会、强制看完合规培训视频、强制鼓掌——这是结构性的不可跳过。游戏里**任意键能跳过任何东西**:logo / splash / 开场动画 / Day 47 的剧本过场 / 月末 KPI 演出。不需要"尊重创作者"、不需要解锁、不需要看完。

12:35 他打开游戏,三下空格跳完所有过场,12:38 已经在做今天 8 张便利贴的决策,12:55 锁屏吃饭。这 17 分钟没有一秒被游戏占用——不是游戏"客气",是游戏不抢这点不属于工位的时间。

### Tone 锚点

**对**的参考:WPS 终于保存成功那一声"叮"(预期落空后的中性确认)、办公室隔间敲键盘的均匀节奏(没有起伏,但确定继续)、Save System 那台"下班打卡机"。
**反**的参考:不是动作游戏的"丝滑跟手"、不是 rhythm game 的"完美 timing"提示、不是 controller-friendly 游戏开场的"已检测到 Xbox 手柄,欢迎使用"弹窗。Input 不庆祝玩家,也不庆祝自己。

### 玩家不会说的话 / 会说的话

- ❌ "操作手感真好" / "响应丝滑" / "竟然支持手柄!"
- ❌ "尊重玩家时间!" / "高自由度配置,赞!"
- ✅ (沉默——读完这段还没意识到自己在评论 Input,就是写对了)
- ✅ "至少这个不卡。" / "不用等。"

## Detailed Rules

### Core Rules

1. **语义动作命名空间(单扁平表,`act_` 前缀)**: 所有 Input 暴露的可绑定动作以 `act_` 前缀,分三类: UI 导航(`act_confirm` / `act_cancel` / `act_focus_next` / `act_focus_prev` / `act_focus_up` / `act_focus_down` / `act_focus_left` / `act_focus_right`)、演出(`act_pause` / `act_skip`)、系统(`act_screenshot`;`act_dev_console` 仅 debug 构建)。**不设 `gameplay_` 子命名空间** — 本作 gameplay 层消费同一张表(打牌、确认日结算 = `act_confirm`)。任何不在表内的 raw `InputEvent` 不向上层暴露;新增 `act_*` 须先改本 GDD。`act_` 前缀防 Godot 内置/插件命名 collision、便于全局 grep。`act_focus_left/right` 服务 diegetic UI(便利贴桌面、情绪板)2D 焦点跳转,与 next/prev 线性导航并存。

2. **合法语义动作判定**: 一个语义动作合法当且仅当同时满足: (a) `InputMap` 有对应条目且键位已绑定; (b) 当前状态机状态允许该类别(见 States and Transitions); (c) 同帧未被模态独占吞(Rule 7)。任一不满足该帧不下发信号。

3. **≤1 帧 dispatch 承诺(Pillar 5 落地)**: Input 在 Godot `_input(event)` 同帧内完成: (a) raw event → 语义动作映射; (b) 双焦点仲裁(Rule 5); (c) GDScript signal 同步发射。三步不经 `call_deferred` 队列。**上述三步不计入上层系统响应预算**;上层信号响应延迟由各自 GDD 自约束。

4. **Anti-Pillar 3 守门(无时序窗口原语)**: Input 故意不实现且不暴露以下任何原语: 连按组合 / 押键蓄力 / 双击窗口 / 节奏窗口 / QTE。后续若需触碰任一类别,必须先修改本 GDD,通过 game-designer 批准方可实现 — 此规则**无豁免**(包括 debug / 隐藏内容 / 致敬向 Easter egg)。

5. **双焦点路径仲裁(Godot 4.6 dual-focus 锁语义,绘制延 ADR)**: 鼠标/触屏焦点(mouse path)与 KB/Gamepad 焦点(kb_gamepad path)物理分离。仲裁规则: (a) **`act_confirm` / `act_cancel` 永远 target KB/Gamepad 焦点元素**,绝不命中鼠标 hover 元素; (b) 鼠标左键单击直接命中 hover 元素,**不经** `act_confirm` 信号路径(等价 hover + click 一步完成); (c) `focus_path_changed(FocusPath)` 信号(`MOUSE` / `KB_GAMEPAD`)在玩家活跃路径切换时发射,UI Owner 自决是否更新焦点视觉(art bible §7.5 `#C8963C` 外框 + 2 px 跳动); (d) 具体 dual-focus 查询 API、绘制 hook、`_gui_input` vs `_unhandled_key_input` 路由由 **ADR-XXXX 决定**(OQ-INP-03),本 GDD 仅锁语义。

6. **任意键跳过 + skippable 注册契约**: 合格跳过事件包含: 任意 `InputEventKey`(`pressed=true` 且 `not echo`)、任意 `InputEventJoypadButton`(`pressed=true`)、`InputEventMouseButton(BUTTON_LEFT, pressed=true)`、`InputEventJoypadMotion` **经 F1 映射后** `abs(joystick_effective_axis) > skip_axis_threshold`(默认 `0.8`;比较目标为 post-deadzone 值而非 raw `axis_value`,与 F1 Justification + AC-FUNC-04 一致)。**不含**: 鼠标移动、鼠标滚轮(避免演出装中误触)、键盘 echo 重复、joypad axis 低于阈值。下游演出系统支持跳过须: (a) 演出开始调 `InputHandler.register_skippable(owner_id: StringName, callback: Callable)`; (b) 演出结束调 `InputHandler.unregister_skippable(owner_id)`。Input 收到合格事件时对所有已注册 skippable 同帧广播,无序约定;无注册时事件不传导。

7. **模态隔离二阶策略(blocking 吞 skip / non-blocking 透传)**: 模态对话框激活时 Input 切 `MODAL_LOCKED`,通过 `InputHandler.acquire_modal_lock(modal_node, blocking: bool)` 入口区分: (a) **blocking=true**(Save 错误 / "上一局仍在进行中" / "档案柜已满" 等需明确决策的对话框): `act_focus_*` 仅 modal 内循环、`act_pause` / `act_skip` **被吞不下发**、`act_confirm` / `act_cancel` 仅作用 modal 内焦点元素; (b) **blocking=false**(autosave 完成 toast / 控制器断开 toast 等纯告知性 UI): 所有 `act_*` 信号正常下发,toast 仅监听特定信号触发自身关闭。模态关闭由所有者调 `release_modal_lock(modal_node)`。**Caller contract(零 gap 要求)**: `acquire_modal_lock` / `release_modal_lock` 必须从 `_input` 或 `set_deferred` 调度,**不可**从 `_process` 直接调 — 否则该帧 `_input` 已在无锁态运行,留一帧 unguarded 窗口(见 Edge 8.2)。具体隔离机制(Recursive Control disable + `process_mode` 组合)由 **ADR-XXXX** 决定(OQ-INP-04)。

8. **Keymap 数据模型与持久化流(信号边界)**: Input 内存维护 `Dictionary[StringName, Array[InputEvent]]`(action → 主键 + 辅键 + 手柄按键)。流程: (a) 玩家在 Remap UI 改绑后,Input 更新内存表 + 立即 `InputMap.action_add_event/erase_event` 应用; (b) Input 发射 `keymap_changed(payload: Dictionary)` 信号,**Save System 订阅**并按 Save Rule 14 走 500 ms 防抖 meta 写(节流责任在 Save 一侧,Input 不知防抖); (c) 启动时由 Scene & Day Flow Controller 协调,调 `InputHandler.load_keymap(payload)` 注入; (d) "恢复默认"调 `InputHandler.reset_to_defaults()`,清用户改绑、`InputMap.load_from_project_settings()` 重载,触发 (b) 流程。**Input 绝不直调 Save 写 API、绝不开 `FileAccess` 或 `ConfigFile`**(Save Rule 20 承约)。依赖方向严格: Input → signal → Save。

9. **Steam Input 透传立场(MVP 锁定;野心版重审)**: MVP 阶段 Input 不在 OS 层拦截输入,不调 Steamworks Input API,不注册 Steam Input Action Set。Steam 设备重映射层(玩家在 Steam 中改键 / 用 Steam Input layout)视为透明直通,Input 接收 Steam 已处理后的 `InputEvent`。**Steamworks 后台配置必须**: Steam Input 设为 "Input Supported" 或 "Input Required"(**禁** legacy mode),否则 Steam 对外发原始设备 ID 绕过 Input layer,玩家自定义全失效 — 见 AC-COMPAT-X(Acceptance Criteria 章定义)。Switch 移植 / 野心版若需 Native Steam Input(振动 / 触发器 / Gyro),由 **ADR-XXXX** 决定切换路径(OQ-INP-05),本 GDD 不预设。

10. **Gamepad 热插拔行为(pause + 任意输入 resume)**: 监听 Godot `Input.joy_connection_changed(device, connected)`: (a) 任一**已连接** gamepad 断开(`connected=false`)时 Input 发射 `device_disconnected(device_id: int, device_name: String)` 信号(单人游戏中所有已连接 gamepad 等价于 action dispatch,无 per-player 设备绑定 — 见 Edge 3.2),Scene & Day Flow Controller(#6)接收并执行 `get_tree().paused = true`、显示 non-blocking toast "控制器断开 — 按任意键继续"(art bible §7.4 即时反馈 tone,纯文字无图标动画); (b) toast 自身 `acquire_modal_lock(toast_node, blocking=false)`(Rule 7),Input 信号正常下发; (c) 任一设备(KB / Mouse / 重连 Gamepad / 其他 Gamepad)首次 `pressed` 事件触发 `device_resumed(device_id)`,Scene Flow `get_tree().paused = false` + 关 toast; (d) `Input.joy_connection_changed(device, true)` 发 `device_reconnected` 信号,**不**自动 resume(玩家可能尚未注意 toast,等他主动按键)。

### States and Transitions

**状态机(3 状态)**

| 状态 | 含义 | 允许 `act_*` 类别 | 进入条件 | 退出条件 |
|------|------|--------------------|----------|----------|
| **NORMAL** | 默认操作态,全信号可用 | 全部 | 初始化 / `release_modal_lock` 后 / `stop_remap_capture` 后 | → MODAL_LOCKED / REMAP_CAPTURE |
| **MODAL_LOCKED** | 模态激活,二阶策略由 `acquire_modal_lock(node, blocking)` 区分 | blocking=true: confirm/cancel/focus 仅 modal 内,`act_skip` 吞 / blocking=false: 全信号正常下发 | modal 所有者调 `acquire_modal_lock(modal_node, blocking: bool)` | modal 所有者调 `release_modal_lock(modal_node)` → NORMAL |
| **REMAP_CAPTURE** | Remap UI 等待绑定 | 仅系统类(`act_screenshot` / `act_dev_console`)透传;其余 `act_*` 不发射,next `InputEvent` 被吞作为绑定 | Remap UI 调 `start_remap_capture(action_name: StringName)` | 捕获成功 / Esc 取消 → NORMAL |

**事件 → State / Signal 映射**

| 触发事件 | State 影响 | 对外信号 |
|---|---|---|
| modal 所有者调 `acquire_modal_lock(node, blocking)` | NORMAL → MODAL_LOCKED | (无,modal owner 主动) |
| modal 所有者调 `release_modal_lock(node)` | MODAL_LOCKED → NORMAL | (无) |
| Remap UI 调 `start_remap_capture(action_name)` | NORMAL → REMAP_CAPTURE | (无) |
| 玩家在 REMAP_CAPTURE 按下任意按键 | REMAP_CAPTURE → NORMAL(写绑定) | `remap_captured(action_name, event)` |
| 玩家在 REMAP_CAPTURE 按 Esc | REMAP_CAPTURE → NORMAL(取消) | `remap_cancelled(action_name, reason=USER_CANCELLED)` |
| 合格 raw event(Rule 6 范围内) | (不改状态) | `act_*` 信号 + skippable 广播(若有注册) |
| 鼠标 / KB-Gamepad 活跃路径切换 | (不改状态) | `focus_path_changed(FocusPath)` |
| Gamepad 断开 | (不改状态) | `device_disconnected(device_id, device_name)` |
| Gamepad 重连 | (不改状态) | `device_reconnected(device_id, device_name)` |
| Hot-plug toast 期间任意输入 | (不改状态) | `device_resumed(device_id)` |
| 玩家改绑 keymap | (不改状态) | `keymap_changed(payload: Dictionary)` |

### Interactions with Other Systems

> **Scene & Day Flow Controller (#6)** ↔ Input Handler
> **流入** (#6 → Input): `acquire_modal_lock(node, blocking)` / `release_modal_lock(node)` 包裹演出模态(月末 KPI 打印 = blocking、autosave/hot-plug toast = non-blocking);响应 `device_disconnected` 信号执行 `get_tree().paused = true`
> **流出** (Input → #6): `act_pause` / `act_skip`(后者经 skippable 注册)/ `device_disconnected` / `device_reconnected` / `device_resumed` 信号
> **所有权**: #6 owns 演出注册时机 + pause 决策 + toast 显示;Input owns 信号发射 + 状态机 + skip 派发
> **时机**: Input 信号同帧发,#6 处理时机由 #6 GDD 自约束

> **Main Menu / Pause / Settings UI (#17)** ↔ Input Handler
> **流入** (#17 → Input): `start_remap_capture(action_name)` / `stop_remap_capture()` 切换 REMAP_CAPTURE;`get_keymap_snapshot() -> Dictionary` 读当前绑定渲染;`reset_to_defaults()` 重载默认表
> **流出** (Input → #17): `remap_captured(action_name, new_event)` / `remap_cancelled(action_name, reason)` 通知刷新
> **`remap_cancelled` reason enum**: `USER_CANCELLED`(Esc 键,见 States 表)/ `INVALID_EVENT_TYPE`(单 modifier 等非法绑定,见 Edge 4.3)/ `DEVICE_DISCONNECTED`(REMAP_CAPTURE 期间手柄全断开,见 Edge 3.1)。#17 UI 负责按 reason 渲染对应 localized 文案(由 Localization Hooks #3 管)。
> **所有权**: #17 owns Remap 屏 UI 渲染 + 与玩家的交互(按键提示、冲突警告);Input owns 捕获状态机 + `InputMap` 写入 + keymap 内存模型
> **时机**: Remap 流程为同步交互,玩家按键即出结果

> **Save System (#1)** ↔ Input Handler
> **流入** (#1 → Input): 启动期 Scene & Day Flow Controller 协调,从 Save 读 `meta.input.keymap` 调 `InputHandler.load_keymap(payload)`。Input 不直接读 Save 文件
> **流出** (Input → #1 via signal): `keymap_changed(payload: Dictionary)` 信号,Save 订阅按 Save Rule 14 走 500 ms 防抖 meta 写
> **所有权**: Save owns `meta.save` 持久化格式与路径(由 ADR-0001 决定)+ 防抖节流;Input owns 内存 keymap 模型 + `InputMap` 应用
> **时机**: 玩家改绑同帧 Input 应用 + 发信号;Save 一侧 500 ms 防抖后落盘
> **关键约束**: Input **绝不直调** `SaveSystem.write_*` API、**绝不开** `FileAccess` 或 `ConfigFile`(Save Rule 20)。依赖方向严格 Input → signal → Save

> **HUD #13 / Card Play UI #14 / Recap UI #15 / KPI Review UI #16(软依赖)** ↔ Input Handler
> **流入** (UI → Input): diegetic 元素 `_ready()` 时调 `InputHandler.register_tab_node(node: Control, tab_index: int)` 注册 D-Pad 跳转链位次;销毁时 `unregister_tab_node(node)`
> **流出** (Input → UI): `focus_path_changed(FocusPath)` / `focused_node_changed(node: Control)` 信号,UI 自决焦点视觉(art bible §7.5 `#C8963C` + 2 px 跳动 由 UI Owner 绘制)
> **所有权**: Input owns D-Pad 跳转逻辑 + 焦点路径仲裁 + Tab-order 数据结构;UI owns 焦点视觉绘制 + 每 diegetic 元素的 `_focus_entered()` 视觉态实现
> **关键约束(Godot 4.6 dual-focus 锁定)**: 每个 diegetic 元素 MVP 实现期必须实现 `_focus_entered()` 视觉态,**不可仅依赖** `mouse_entered` hover 视觉(D-Pad 导航不触发 hover 信号)。违反即 Pillar 5 + art bible §7.5 焦点环失守 — AC-COMPAT-X "鼠标断开 + D-Pad only" 验证

> **Tutorial #18 [VS-tier]** + **Accessibility #20 [Alpha-tier]** (预留依赖)
> **流入**: 两者订阅 `input_method_changed(method: InputMethod)` 信号(`KB_MOUSE` / `GAMEPAD`)渲染对应 prompt 文案与图标(KB "按 Enter" vs Gamepad face button glyph,glyph 查表由 ui-programmer 实现);Tutorial 还订阅 `act_*` 信号验证教学步骤;Accessibility 向 Input 注入辅助配置(sticky keys / 慢速 D-Pad / 高对比焦点环)
> **所有权**: 两者 GDD 待写,本系统仅声明接口存在;具体定义由各自 GDD 阶段补全

## Formulas

### Formula 1: Joystick Deadzone Mapping

The **joystick_effective_axis** formula is defined as:

```
joystick_effective_axis(r) =
  0                                                if |r| < deadzone_inner
  sign(r) * (|r| - deadzone_inner)
            / (deadzone_outer - deadzone_inner)    if deadzone_inner ≤ |r| < deadzone_outer
  sign(r) * 1.0                                    if |r| ≥ deadzone_outer
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| Raw axis value | `r` | float | [-1.0, 1.0] | `InputEventJoypadMotion.axis_value` from Godot |
| Inner deadzone threshold | `deadzone_inner` | float | [0.0, deadzone_outer) | 漂移忽略阈值;低于此输出 0 |
| Outer deadzone threshold | `deadzone_outer` | float | (deadzone_inner, 1.0] | 视为完全偏转的阈值 |
| Effective axis value | `joystick_effective_axis` | float | [-1.0, 1.0] | 用于 focus dispatch + Rule 6 跳过判定 |

**Defaults:** `deadzone_inner = 0.15`, `deadzone_outer = 0.85`

**Justification:** Steam Deck 拇指搁置漂移在磨损单元上落 0.05-0.12 区间,0.15 留余量但不挤压有意微推。0.85 让坚决但非极致的推动注册为"满",降低长会话手部疲劳(Pillar 5)。

**与 `skip_axis_threshold = 0.8`(Rule 6)的关系:** 跳过判定针对 `joystick_effective_axis`(非 raw `r`)。`deadzone_outer = 0.85` 时,raw `r ≈ 0.87` 即输出 1.0,稳过 0.8 阈值。需维持的约束: `deadzone_outer < 1.0`(否则 saturation zone 消失)、`skip_axis_threshold < 1.0`(否则跳过不可达)。两者独立,当前 defaults 兼容。

**Output Range:** [-1.0, 1.0],构造性钳位。Inner zone 输出 0(不 dispatch),linear zone 线性,saturated zone ±1.0。

**Worked Example:** `r = 0.60`, `deadzone_inner = 0.15`, `deadzone_outer = 0.85` → `|r| = 0.60` 落 linear zone → `joystick_effective_axis = 1.0 * (0.60 - 0.15) / (0.85 - 0.15) ≈ 0.643` < 0.8 → focus 导航 fire,跳过不触发。

---

### Formula 2: D-Pad / Held-Direction Repeat

The **focus_dispatch_count** formula is defined as:

```
focus_dispatch_count(t) =
  0                                                              if t < 0
  1                                                              if 0 ≤ t < dpad_repeat_initial_delay_ms
  1 + floor((t - dpad_repeat_initial_delay_ms)
            / dpad_repeat_interval_ms) + 1                       if t ≥ dpad_repeat_initial_delay_ms
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| Hold duration (ms) | `t` | float | [0, ∞) | 自方向输入开始的毫秒数;松开归零 |
| Initial repeat delay | `dpad_repeat_initial_delay_ms` | float | [100, 800] ms | 重复 fire 前的持时 |
| Repeat interval | `dpad_repeat_interval_ms` | float | [50, 300] ms | 后续 dispatch 间隔 |
| Total dispatches fired | `focus_dispatch_count` | int | [0, ∞) | 累计 focus_next/prev/up/down 事件数 |

**Defaults:** `dpad_repeat_initial_delay_ms = 350`, `dpad_repeat_interval_ms = 100`

**Justification:** OS 键盘重复 30-50 ms 是为打字设计,菜单导航过快易超调。Hades / Celeste options / Balatro 惯例为 300-400 ms initial / 80-120 ms repeat。350 ms initial 长到 tap-and-release 不误触第二次,短到 deliberate hold 仍 responsive(Pillar 5)。100 ms repeat 让 5 元素列表全程 350 + 4×100 = 750 ms,不慌不抖。

**Output Range:** Integer ≥ 0。持时无界,实际由 UI 元素数封顶。**实现注意:** 焦点已抵列表边界时 repeat 不应再 fire。

**Worked Example:** 玩家按住 D-Pad Right `t = 500 ms`, `D_i = 350`, `D_r = 100` → t=0 dispatch 1 / t=350 dispatch 2 / t=450 dispatch 3 / t=500 总计 `1 + floor((500-350)/100) + 1 = 3` dispatches。

---

### Formula 3: Input Path Arbitration

The **input_path_arbitration** rule(填补 Rule 5 (c) "活跃路径切换"判定)定义为:

```
active_path =
  MOUSE        if mouse_delta_magnitude > mouse_motion_threshold
                AND no KB/gamepad directional event in last arbitration_lockout_ms
  KB_GAMEPAD   if KB or gamepad directional event received
                (overrides MOUSE for arbitration_lockout_ms duration)
  (unchanged)  when lockout elapsed but no qualifying mouse_delta arrives
                — active_path holds at KB_GAMEPAD until next mouse motion > threshold
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| Mouse motion magnitude (px/frame) | `mouse_delta_magnitude` | float | [0.0, ∞) | `InputEventMouseMotion.relative.length()` |
| Mouse activation threshold | `mouse_motion_threshold` | float | [1.0, 20.0] px/frame | 切换至 MOUSE 路径的最低位移;抑制光标微漂移 |
| KB/gamepad lockout window | `arbitration_lockout_ms` | float | [100, 500] ms | KB/gamepad 方向事件后,MOUSE 不可在此期间反夺 active_path |
| Active input path | `active_path` | enum | {MOUSE, KB_GAMEPAD} | 当前活跃路径;决定光标可见性 + 焦点高亮模式。enum 命名与 Rule 5(c) `focus_path_changed(FocusPath)` 信号、AC-COMPAT-03 一致 |

**Defaults:** `mouse_motion_threshold = 4.0` px/frame, `arbitration_lockout_ms = 200` ms

**Justification:** 玩家用 D-Pad 翻牌时偶然撞到鼠标(桌振 / 静放手腕)不应让光标突然冒出来抢焦点。200 ms lockout 匹配 1-2 个 D-Pad repeat 周期(F2 = 100 ms),路径切换感觉 deliberate 而非意外。4.0 px/frame 滤光学传感器亚像素噪声,但允许有意伸手。**注意**: lockout 过期不自动切回 MOUSE — 路径保持 `KB_GAMEPAD` 直至下一个合格 `mouse_delta_magnitude > threshold` 事件抵达。避免玩家放手后光标突然抢焦点。

**Output Range:** 离散 enum {MOUSE, KB_GAMEPAD}。无数值输出;喂下游 `cursor_visible: bool` + `focus_highlight_mode: enum`。

**Worked Example:** t=0 ms 玩家按 D-Pad Right → `active_path = KB_GAMEPAD`,lockout 启动。t=80 ms 鼠标移 6 px(>阈值)→ lockout 未过期,`active_path` 保持 `KB_GAMEPAD`。t=200 ms lockout 过期,但无新 mouse motion → `active_path` 仍为 `KB_GAMEPAD`。t=210 ms 鼠标再移 6 px(>阈值且 lockout 已过)→ `active_path = MOUSE`。

## Edge Cases

### 1. Boundary Values

- **If `deadzone_inner = 0.0` is set via Tuning Knobs**: any axis resting noise registers as `KB_GAMEPAD` active path and triggers F2 repeat, flooding `act_focus_*` signals every frame. Tuning guard 强制 `deadzone_inner ≥ 0.05`,低于此 load time 静默 clamp。
- **If `deadzone_outer = 1.0` is set**: saturation zone 退化至单点,仅 raw `r = 1.0` 能精确命中输出 1.0(Godot float 精度下物理摇杆极少触达);典型 r=0.99 时输出 `≈0.988`,feel 上"推到底也不满"。Tuning guard 强制 `deadzone_outer ≤ 0.99`,高于此 clamp down。
- **If `skip_axis_threshold = 1.0` exactly**: 阈值比较 `> 1.0` 永不为 true;axis 跳过永久阻塞。Clamp 到 `[0.5, 0.99]`。
- **If 跳过事件 fires 时 skippable 注册表为空**: 事件静默丢弃,无信号无错(per Rule 6 "无注册时事件不传导")。这是正确行为 — 显式记录,callers 不应预期 fallback `act_skip` 信号。
- **If `dpad_repeat_initial_delay_ms = 0`**: initial dispatch 与 first repeat 同帧,`focus_dispatch_count(0) = 2`。Tuning guard 强制 `≥ 50` ms,低于此 clamp。

### 2. State Transitions and Race Conditions

- **If `acquire_modal_lock` 在已 `MODAL_LOCKED` 时被调**(嵌套 modal — 如 Save 错误对话框打在 hot-plug toast 之上): 第二次调 stack 第二把锁。锁栈 counter,`release_modal_lock` decrement,counter 归零才回 NORMAL。**最严格 blocking flag 胜出**: 任一层 blocking=true 整栈视为 blocking。[OQ-INP-01]
- **If `release_modal_lock` 由非当前 owner 调**(如 toast 试 release blocking dialog 锁): 调用拒绝 + log warning,状态保持 `MODAL_LOCKED`。所有权按 node reference 追踪,非调用顺序。
- **If 合格 `act_skip` 事件与 blocking modal 关闭同帧到达**(`release_modal_lock` 帧顶 fire,skip 帧中 `_input` 到达): 定义顺序 — `release_modal_lock` 在 `_input` 处理 skip 前完成转移,skip 看到 `NORMAL` 状态正常 fire。**这条 R2 守门**: 把"转移在 dispatch 之前"显式锁为 GDD 约束,非实现假设。
- **If `start_remap_capture` 在 `MODAL_LOCKED` 时被调**: 拒绝,不进 `REMAP_CAPTURE`。Remap UI 必须先 `release_modal_lock`(若它持锁)再发起 capture。Remap UI GDD 须文档此前置。
- **If `_input` 同帧收 2 事件**(Godot 可批): 顺序处理,第二个看第一个写下的状态。同帧两次 `act_confirm`(Enter + Gamepad A 同帧)dispatch 两次 — callers 须对同帧 double-fire 幂等,**或 Input 同帧去重**。[OQ-INP-02 — owner systems-designer + game-designer,target ADR-XXXX]

### 3. Device Hot-Plug and Multi-Device

- **If 全 gamepad 在 `REMAP_CAPTURE` 等手柄绑定时断开**: 该状态无 valid joypad 源。Input 自动 emit `remap_cancelled(action_name, reason=DEVICE_DISCONNECTED)`,转 NORMAL;Remap UI 显示"控制器断开 — 捕获取消"。
- **If 两 gamepad 同时连接且同帧 fire input**: Godot `device` 字段区分;Input 默认 `device = -1`(any-device)action matching。**策略文档**: 单人游戏中所有连接 gamepad 等价于 action dispatch(无 per-player 设备绑定)。第一个满足阈值的事件该帧胜出。
- **If `device_reconnected` fires 给从未注册 disconnected 的设备**(如 Godot 在 sleep/wake 发 spurious reconnect): 信号正常 emit;Scene & Day Flow 须对重复 reconnect 幂等(no double-resume)。Guard: Scene Flow 仅在自己设过 `paused = true` 时调 `paused = false`。
- **If 游戏因 hot-plug toast 暂停且玩家连**新**(不同的)gamepad** 而非原设备: Rule 10(c) "任一设备首次 pressed 事件 → `device_resumed`"。新 gamepad 任意按键满足。原断开设备不被追踪 — 单人正确。

### 4. Keymap and Remap Edge Cases

- **If 同一 raw `InputEvent` 绑两 `act_*`**(如 Space 同时绑 `act_confirm` + `act_skip`): 两 action 同帧 fire。Input **不阻止** — Remap UI 须警告冲突。Input fires all matching;upper layers 须容忍 co-fire。Remap UI GDD 须定义冲突检测与警告文案。
- **If `reset_to_defaults()` 在 `REMAP_CAPTURE` 时调**: 先 cancel capture(`remap_cancelled` emit),回 NORMAL,再 reset。In-flight capture 不应覆盖刚 reset 的绑定。
- **If 单 modifier 事件被 capture**(如玩家按 Ctrl 单键试绑 `act_confirm`): bare modifier(`KEY_CTRL` / `KEY_SHIFT` / `KEY_ALT`)拒绝,`remap_cancelled` 带 reason `INVALID_EVENT_TYPE`;UI 显示"修饰键不可单独绑定"。
- **If `load_keymap(payload)` 含未识别 `act_*` 名**(如 future-version save 含已删除的 `act_quicksave`): 未知 action 静默 skip,已知 action 应用。无 crash 无 partial failure,DEBUG 级 log warning。
- **If `load_keymap(payload)` 收空 payload `{}`**: 全 actions 回 `InputMap` project defaults(等价 `reset_to_defaults()` 但不 emit `keymap_changed`)。**依赖 Save**: 不应写空 keymap payload — Input 自身必须安全。

### 5. Skip System Edge Cases

- **If skippable owner node 被 `queue_free` 而未 `unregister_skippable`**(R2 部分): 存的 `Callable` 持死实例引用。skip event fire 时调 dead callable 引 GDScript null-instance 错。Input 须 guard: 调每个回调前 `is_instance_valid(owner_node)` 检查,dispatch 前 auto-purge 失效条目。
- **If `register_skippable` 同 `owner_id` 调两次**: 第二次静默覆盖第一次回调 — callers 不应假设第一次注册存活。或第二次拒绝 + warning;**二选一须定**。[OQ-INP-02 — 同上]
- **If skip event 在 `register_skippable` 调时已在 Godot input buffer 排队**(如玩家在过场 skippable 注册完成前已按 Space): queued event 在下一 `_input` 抵达,注册已 live。skip 在过场 first frame 立即 fire。**这是正确行为**(玩家明确想跳)— 显式文档,动画师不应作 bug 提报。

### 6. Dual-Focus Edge Cases (R1 守门)

- **If 鼠标在空白区(无 hover target)+ KB focus 在 X + `act_confirm` fires**: 按 Rule 5(a),`act_confirm` target KB/Gamepad focus → X 收 confirm。无 fallback 到"光标下空"。**显式文档**给 UI 程序员(不应假设鼠标位置影响 `act_confirm`)。
- **If modal 在鼠标 hover 背景元素时打开**(blocking modal): 背景元素 `mouse_entered` 状态不被 Input 清 — Godot 不会因 `process_mode` 改变重 emit `mouse_exited`。背景 hover 视觉可能黏住。Resolution: modal owner 须在 open time `mouse_filter = MOUSE_FILTER_STOP` modal 根节点 + 强制 `mouse_exited` 任一持 hover 视觉的元素。**UI 实现要求**,非 Input rule — flag for UI GDD。(依赖 ADR-XXXX OQ-INP-04 modal 机制。)
- **If `focus_path_changed` 在帧末 fire,UI 在下一帧首读 `active_path`**: 一帧窗口信号已 fire 但 UI 未重绘高亮。**可接受** — ≤1 帧 dispatch 承诺仅约束信号 emit,不约束 UI 重绘。文档: UI 不应跨帧 cache `active_path`,每帧从 Input getter 读或响应信号。
- **If 两 diegetic 元素共享同 `tab_index`**(R1 邻接): Input Tab-order 数据结构须 deterministic tiebreak(注册顺序)。**重号是 caller error** — Input log warning + 用注册顺序作 tiebreak,不 crash。
- **If D-Pad 焦点链终点("出口节点")在焦点抵达前被销毁**: 焦点抵达 gap 前最后 valid node 即停 — 不绕不跳。Input 须 next-node lookup 时 `is_instance_valid` 检测,无效作链终。UI 系统须在 `_exit_tree()` 调 `unregister_tab_node`。

### 7. Steam Input Edge Cases (R3 守门)

- **If Steam Input 在 fresh Steam install 处 legacy mode**(R3): Steam 在 Godot 看到事件前重映射手柄按键到 KB/Mouse。Godot 收 `InputEventKey`(arrow keys)而非 `InputEventJoypadButton`。F3 仲裁见 KB 设 `active_path = KB_GAMEPAD`。焦点导航工作,但 glyph 渲染 fire `input_method_changed(KB_MOUSE)` — UI 显键盘 glyph(`↑ ↓`)而非手柄面键。**Silent failure**: 不 crash 但视觉上下文错。**AC-COMPAT-X 必须含 Steam-legacy fresh install smoke test**;Steamworks launch config 每发布版前验"Input Supported/Required"。
- **If Steam Input 把 D-Pad 翻成 `InputEventKey(KEY_UP)`**: F2 `dpad_repeat_initial_delay_ms` 不应用 — OS key-repeat 接管(Windows 典型 500 ms initial / 30 ms repeat)。导航 repeat 手感偏离 F2 调谐值。Resolution: Input 须分辨方向事件 `InputEventKey` vs `InputEventJoypadButton`,**F2 仅用于后者**;OS key-repeat 治理 KB。Steam-legacy 用户得 OS repeat 手感非调谐手感 — **Steam 配置错不是游戏 defect**,可接受。

### 8. Performance and Pillar 5 Pressure

- **If >100 skippables 同时注册**(病态 — 大量 overlapping 动画): `_input` 内同步广播循环遍所有注册。100 entries trivial callbacks 可忽略,但触发 Scene Flow 状态变更的回调 mid-loop 可致 re-entrant `_input` 处理。Guard: 回调不可在 skip dispatch 期回调入 Input Handler;**caller contract** 文档。Input MVP 不需 runtime 强制。
- **If `acquire_modal_lock` / `release_modal_lock` 从 `_process` 慢帧调**(如 HDD autosave stall 同帧 modal 打开): Godot 执行序为 `_input` → `_process` — 若 modal 在 `_process` 打开,该帧 `_input` 已无锁运行。**一帧 gap**: modal 打开那帧一个 unguarded `act_*` 可能 fire。Resolution: 需零 gap 保护的 modal owner 须用 `_input` 或 `set_deferred` 调度锁,非 `_process`。Flag for Scene & Day Flow GDD。

### 9. OS and Window Focus Edge Cases

- **If OS window 失焦(Alt-Tab / 通知 overlay / Steam overlay)时键被持**: Godot 4.6 emit `NOTIFICATION_WM_WINDOW_FOCUS_OUT`。持键的 `released` event 永不抵达 `_input`,Input 内部"方向 held"状态(F2)保持 `true`。焦点回时玩家可能已松手但 Input 仍 fire repeat。Resolution: `NOTIFICATION_WM_WINDOW_FOCUS_OUT` 时 Input 须调 `Input.reset_all_action_presses()`(或等价 flush)+ reset 全 held-direction timers,防 ghost repeat。**与 Save 协调**: Save GDD 已用此 notification 处理 dirty-state flush — Input 须协调时序避序冲突。
- **If Steam overlay 在 skip-broadcast 中打开**(`Shift+Tab` 在 cutscene 播时): Steam overlay 关时 suppress `InputEventKey` 抵达游戏。In-flight skip broadcast 不被打断,正常完成。Overlay 关时游戏恢复收事件。**无需特殊处理** — 文档: Steam overlay 开关对 Input 状态机透明。

## Dependencies

### Upstream Dependencies(本系统依赖)

**None.** Input Handler 是 Foundation Layer 根节点,不依赖任何其他系统。仅依赖 Godot 4.6 引擎 API(`InputMap` / `Input` / `_input` / `_unhandled_input` / `joy_connection_changed` 等)和 art bible §7.4 §7.5 §7.6 锁定的 UX 约束。

### Downstream Dependents(依赖本系统的)

| # | System | Tier | Type | Interface(摘要) | 反向文档 | 必要 |
|---|--------|------|------|--------------------|---------|------|
| 1 | **Save System** | MVP / Foundation | **Hard** | `keymap_changed` 信号 → Save 防抖写 meta;启动期 Save 提供 `meta.input.keymap` payload 注入 | ✅ Save Rule 14 显式提及"玩家改设置(... gamepad 布局)走 meta 防抖" | ✅ 必须 |
| 6 | **Scene & Day Flow Controller ⭐** | MVP / Core | **Hard** | `act_pause` / `act_skip`(via skippable 注册)/ `device_disconnected` / `device_reconnected` / `device_resumed` 信号;`acquire_modal_lock(node, blocking)` / `release_modal_lock(node)` 入口 | 未设计 — #6 GDD 须显式列入 Input | ✅ 必须 |
| 17 | **Main Menu / Pause / Settings UI** | MVP / Presentation | **Hard** | `start_remap_capture(action_name)` / `stop_remap_capture()` / `get_keymap_snapshot()` / `reset_to_defaults()` 接口;`remap_captured(action_name, event)` / `remap_cancelled(action_name, reason)` 信号 | 未设计 — #17 GDD 须列入 Input + 文档冲突检测 + 单 modifier 拒绝 UI | ✅ 必须 |
| 13 | **HUD System (Diegetic)** | MVP / Presentation | Soft | `register_tab_node(node, tab_index)` / `unregister_tab_node(node)` 注册 D-Pad 跳转链;`focus_path_changed(FocusPath)` / `focused_node_changed(node)` 信号;**每 diegetic 元素必须实现 `_focus_entered()` 视觉态(R1 守门)** | 未设计 — #13 GDD 须列入 Input + 锁 `_focus_entered()` 实现要求 | ✅ MVP 必须 |
| 14 | **Card Play & Dialogue UI** | MVP / Presentation | Soft | 同 #13 接口 | 未设计 | ✅ MVP 必须 |
| 15 | **Daily / Weekly Recap UI** | MVP / Presentation | Soft | 同 #13 + skippable 注册(周报演出可跳过) | 未设计 | ✅ MVP 必须 |
| 16 | **KPI Review & Game Over UI** | MVP / Presentation | Soft | 同 #13 + skippable 注册(月末 KPI 打印剧 + 离职证明 transition) | 未设计 — **注**: 离职证明 transition 是 Save Rule 21 跨 GDD 锁定 `final_transition_duration_ms ≤ 1500` + `easing=NONE`,本 GDD 仅提供 skip 入口,tone 约束在 #16 GDD | ✅ MVP 必须 |
| 18 | **Tutorial / Onboarding** | VS / Feature | Soft | `input_method_changed(method)` 信号 + `act_*` hook 验教学步骤 | 未设计(VS 推迟) | 可推迟 VS |
| 20 | **Accessibility Options** | Alpha / Polish | Soft | 配置注入 sticky keys / 慢速 D-Pad / 高对比焦点环 | 未设计(Alpha 推迟) | 可推迟 Alpha |

### 双向一致性核对(coding-standards 强制规则)

现有已 Approved 的 GDD: **Save System (#1)** ✓ — Save Rule 14 已显式提及输入设置走 meta 路径,bidirectional consistent。

未设计的 8 个下游 GDD,**编写时各自必须**:
1. 在自身 Dependencies 章节列入 "Input Handler (#2)" 作为 dependency
2. 引用本 GDD 的 Section C Rules/Interactions 锁定的 API 名(`act_*` 命名空间、`acquire_modal_lock` / `release_modal_lock`、`register_skippable` / `unregister_skippable`、`register_tab_node` / `unregister_tab_node` 等)
3. 不得重新定义 input dispatch 路径(违反 Rule 1 命名空间封锁)
4. 凡涉及 diegetic UI(#13/14/15/16)必须实现 `_focus_entered()` 视觉态(R1 守门 + art bible §7.5 锁定)

### 跨 GDD 影响清单(若本 GDD 后续 revise,以下系统须重审)

- Save System #1 — keymap payload schema 变 → 影响 meta.save schema_version
- Scene & Day Flow #6 — modal 锁栈策略 / 演出 skippable 时机
- Main Menu #17 — Remap UI 全部接口
- HUD #13 / Card #14 / Recap #15 / KPI Review #16 — Tab-order 注册接口 / focus 信号 / `_focus_entered()` 要求
- 任何引入"快捷键 / 组合键 / 特殊操作"的功能 — Rule 4 Anti-Pillar 3 守门必须先经本 GDD revision

## Tuning Knobs

### Numeric Knobs(本 GDD 内部 owning)

| Knob | Default | Safe Range | 极端行为 | 来源 |
|------|---------|------------|---------|-------|
| `skip_axis_threshold` | 0.8 | [0.5, 0.99] | <0.5: 摇杆轻碰即跳过演出 / =1.0: 永远不可能跳 | Rule 6 |
| `deadzone_inner` | 0.15 | [0.05, 0.30] | <0.05: 漂移 flood `act_focus_*` / >0.30: 微推无响应,Steam Deck 用户感觉粘 | F1 |
| `deadzone_outer` | 0.85 | [0.60, 0.99] | =1.0: saturation zone 消失,full deflection 输出 <1.0 / <0.60: 轻推即视为满,误触 skip | F1 |
| `dpad_repeat_initial_delay_ms` | 350 | [100, 800] | <100: tap-and-release 误触第二次 / >800: deliberate hold 迟钝,Pillar 5 失守 | F2 |
| `dpad_repeat_interval_ms` | 100 | [50, 300] | <50: 5 元素列表 <250 ms 走完超调频繁 / >300: 长列表导航痛苦 | F2 |
| `mouse_motion_threshold` | 4.0 px/frame | [1.0, 20.0] | <1.0: 桌振 / 光学噪声触路径切换 / >20.0: deliberate 伸手不切,KB 焦点不让位 | F3 |
| `arbitration_lockout_ms` | 200 | [100, 500] | <100: D-Pad 翻牌时鼠标抖即抢 path / >500: 玩家放弃手柄后还等半秒才切 | F3 |

### Default Keymap Table

*在 Godot `project.godot` `[input]` section 定义,启动后通过 `InputMap.load_from_project_settings()` 加载;玩家可在 #17 Remap UI 改绑后经 Save Rule 14 写 meta。*

| `act_*` | KB Primary | KB Secondary | Gamepad Primary |
|---------|------------|--------------|------------------|
| `act_confirm` | Enter | — | A(south face button)|
| `act_cancel` | Escape | — | B(east face button)|
| `act_focus_next` | Tab | — | RB / R1(右肩键)|
| `act_focus_prev` | Shift+Tab | — | LB / L1(左肩键)|
| `act_focus_up` | ↑ | W | D-Pad Up |
| `act_focus_down` | ↓ | S | D-Pad Down |
| `act_focus_left` | ← | A | D-Pad Left |
| `act_focus_right` | → | D | D-Pad Right |
| `act_pause` | Escape | — | Start / Menu button |
| `act_skip` | Space | — | A(face button — 与 `act_confirm` 故意 collide,见下)|
| `act_screenshot` | F12 | — | — |
| `act_dev_console` (debug 构建仅) | F1 | — | — |

**`act_confirm` vs `act_skip` 同 face button 故意 collision**: 默认 A 键 / Space 同时绑两 action。语义: 演出活跃时 skippable callback 跑(`act_skip` 命中);演出未活跃时焦点元素响应(`act_confirm` 命中)。同帧两 action fire 但作用域不冲突,Edge Case 4.1 已守门。玩家可在 Remap 拆开。

### 跨 GDD Tuning Knob(引用,不 owning)

| Knob | Owner GDD | Value | 与 Input 关系 |
|------|-----------|-------|---------------|
| `meta_settings_debounce_ms` | Save (#1) Rule 14 | 500 ms | Input `keymap_changed` 信号触发 Save 防抖窗口;Input 不知防抖、不可重写 |
| `final_transition_duration_ms` | Save (#1) Rule 21 | 1500 ms | Input 通过 #16 KPI Review skippable 注册提供 skip 入口;duration / easing tone 由 Save 守门,Input 不可推翻 |

### Localizable Strings(归 Localization Hooks #3 管,非 Input tuning)

- "控制器断开 — 按任意键继续"(Rule 10 toast)
- "修饰键不可单独绑定"(Edge 4.3 Remap UI 显示)
- "控制器断开 — 捕获取消"(Edge 3.1 Remap UI 显示)

## Visual/Audio Requirements

Input Handler 不 own 任何 visual asset 或 audio cue。Pillar 4(黑色幽默 tone)主动反对 input 反馈式 SFX(无 UI 点击声 / 无 confirm 音 / 无 menu navigation tick)— Save System Player Fantasy 已锁同质 tone 参照("不是动作游戏的'丝滑跟手'")。Input 仅声明信号契约,具体视觉与音频归属:

| 制品 | Owner GDD | 与 Input 关系 |
|------|-----------|----------------|
| 焦点环视觉(`#C8963C` + 2 px 跳动) | art bible §7.5(锁定值)+ #13 HUD / #14 Card UI 等(实现) | Input 仅 emit `focus_path_changed` / `focused_node_changed` 信号 |
| 鼠标 hover 视觉(盖章双线) | art bible §7.4 + 各 UI Owner | Input 不接管 hover 视觉 |
| "控制器断开" toast 文本 + 字体 | Localization Hooks #3(文本)+ #6 Scene Flow / 各 UI 实现 | Input 仅 emit `device_disconnected` 信号 |
| Remap 屏视觉 / 按键 glyph 库 | #17 Main Menu UI(屏)+ ui-programmer(glyph 查表) | Input 仅 emit `input_method_changed(KB_MOUSE/GAMEPAD)` |

**零音频要求** — 任何 input 事件不触发 audio cue。若未来需求加,必须先改本 GDD(违反则 Pillar 4 失守,与 Save System 同质)。

## UI Requirements

Input Handler 不 own UI 屏。**唯一 UI 接触面**是 Main Menu / Pause / Settings UI(#17)的 **Remap 子屏** — 该屏由 #17 GDD 规划,本 GDD 仅锁定数据契约:

- `get_keymap_snapshot() -> Dictionary` / `start_remap_capture(action_name)` / `stop_remap_capture()` / `reset_to_defaults()` 接口由 #17 调用
- `remap_captured(action_name, event)` / `remap_cancelled(action_name, reason)` 信号由 #17 订阅
- 冲突检测(同 raw event 绑两 action,Edge 4.1)文案与警告 UI 由 #17 设计
- 单 modifier 拒绝(Edge 4.3)文案"修饰键不可单独绑定"由 #17 显示
- 控制器断开捕获取消(Edge 3.1)文案"控制器断开 — 捕获取消"由 #17 显示

**📌 UX Flag — Input Handler**: 本系统 keymap 数据模型在 Phase 4 (Pre-Production) 阶段需要由 `/ux-design design/ux/remap-screen.md` 配 #17 GDD 一并产出 UX 设计稿,包括: keymap 列表渲染 / 改绑流程 / 冲突警告对话框 / 重置默认确认对话框 / 焦点链导航。stories 引用 UI 时须 cite `design/ux/remap-screen.md`,而非本 GDD。

## Acceptance Criteria

25 条 AC 分 5 类(AC-FUNC 10 / AC-PERF 4 / AC-COMPAT 6 / AC-ROBUST 4 / AC-A11Y 1)。**4 [RISK GUARD]** AC 守门 gameplay-programmer 高风险路径(R1 dual-focus / R2 modal skip-leak / R3 Steam legacy + Edge 5.1 skippable owner 销毁),须在首个可测 build 优先验证。

### AC-FUNC (功能性)

- **AC-FUNC-01** (R1 act_* 命名空间完整性): **GIVEN** 游戏冷启动完成,`InputMap` 已通过 `load_from_project_settings()` 初始化, **WHEN** QA 用 `InputMap.get_actions()` 枚举全部已注册 action, **THEN** 恰好存在以下 12 个 `act_` 条目: `act_confirm` / `act_cancel` / `act_focus_next` / `act_focus_prev` / `act_focus_up` / `act_focus_down` / `act_focus_left` / `act_focus_right` / `act_pause` / `act_skip` / `act_screenshot`(加上 debug 构建才有的 `act_dev_console`),不存在任何 `gameplay_*` / `ui_*` / 未加前缀的同类别 action;如有任何不在白名单内的 `act_*` 出现即 FAIL。

- **AC-FUNC-02** (R2 合法判定三条件): **GIVEN** 系统处于 NORMAL 态且 `act_confirm` 已绑定 Enter, **WHEN** QA 依次测试: (a) Enter 键按下(全条件满足);(b) 物理按 Enter 但 `InputMap` 中 `act_confirm` 条目已被测试钩子删除;(c) Enter 在 blocking=true modal 激活期按下, **THEN** (a) 下层收到 `act_confirm` 信号;(b)(c) 信号均不发射,且无 GDScript 错误日志。

- **AC-FUNC-03** (R5 双焦点仲裁 — act_confirm 永远 target KB 焦点): **GIVEN** 键盘焦点停在 ButtonA,鼠标 hover 停在 ButtonB(两者为不同元素), **WHEN** 按 Enter 触发 `act_confirm`, **THEN** ButtonA 的 `pressed` 信号 fire,ButtonB **不**收到任何 confirm;鼠标左键单击 ButtonB 时 ButtonB 直接响应,同帧 `act_confirm` 信号**不**发射。

- **AC-FUNC-04** (R6 跳过事件资格白名单): **GIVEN** 已通过 `register_skippable` 注册一个 skippable 回调, **WHEN** QA 依次发送: (a) `InputEventKey(KEY_SPACE, pressed=true, echo=false)`;(b) `InputEventJoypadButton(pressed=true)`;(c) `InputEventMouseButton(BUTTON_LEFT, pressed=true)`;(d) `InputEventJoypadMotion(axis_value=0.85)`(经 F1 映射后 > 0.8);(e) `InputEventMouseMotion`;(f) `InputEventKey(echo=true)`;(g) `InputEventMouseButton(BUTTON_WHEEL_UP, pressed=true)`, **THEN** (a)(b)(c)(d) 各触发一次 skippable 回调;(e)(f)(g) 回调不触发,共计 4 次而非 7 次。

- **AC-FUNC-05** (R7 模态隔离二阶策略): **GIVEN** 一个 blocking=true modal 已通过 `acquire_modal_lock(modal_node, true)` 激活, **WHEN** (a) 按任意 `act_skip` 合规事件;(b) 按 `act_focus_up`;(c) 在 modal 内元素上按 `act_confirm`, **THEN** (a) skippable 广播**不发射**(blocking 吞 skip);(b) 焦点导航**仅限 modal 内循环**,modal 外元素不得焦点;(c) modal 内目标元素收到 confirm 信号;解锁后(`release_modal_lock`)普通 skip 恢复发射。

- **AC-FUNC-06** (Edge 2.1 嵌套 modal lock-stack — R2 / R7): **GIVEN** blocking=false toast 持锁后,在同帧再调 `acquire_modal_lock(dialog_node, blocking=true)` 叠加第二把锁, **WHEN** (a) 按 `act_skip`;(b) 调 `release_modal_lock(toast_node)`(解 non-blocking 层), **THEN** (a) skip 被吞(最严格 blocking flag 胜出,整栈视为 blocking);(b) 解锁仅减少 counter,状态仍 MODAL_LOCKED(non-blocking dialog 层未解);两把锁均 release 后才回 NORMAL,skip 恢复。

- **AC-FUNC-07** (R8 keymap 信号边界 — 无直调 Save): **GIVEN** 通过 debug 钩子对 `SaveSystem.write_meta` 和 `FileAccess.open` 调用计数, **WHEN** 玩家在 Remap UI 将 `act_confirm` 的 KB Primary 改为 Z 键, **THEN** `InputMap.action_add_event` 在同帧被调用(绑定生效);`keymap_changed` 信号恰好发射一次;SaveSystem.write_meta 和 FileAccess.open 的调用计数在该帧**不增加**(Input 不直调 Save);500 ms 后 `meta.save` 的 mtime 更新(Save Rule 14 防抖落盘)。

- **AC-FUNC-08** (Edge 4.1 同 raw event 双 action 双 fire — R2 守门): **GIVEN** Space 同时绑定 `act_confirm` 和 `act_skip`(默认 keymap 故意 collision 场景),且已注册一个 skippable 回调, **WHEN** 按 Space(NORMAL 态), **THEN** 同帧内 `act_confirm` 信号和 skippable 回调均触发;上层 UI 须对同帧 co-fire 幂等(此 AC 验证 Input 不阻止,而非上层处理);两次触发**均**在 `_input` 同帧内完成。

- **AC-FUNC-09** (Edge 5.1 skippable owner 销毁后 is_instance_valid 守门 — R2 高风险): **GIVEN** 演出系统调 `register_skippable(owner_id, callback)` 后立即 `queue_free()` 其 owner node, **WHEN** QA 触发一个合规 skip 事件, **THEN** Input Handler 检测 `is_instance_valid(owner_node)` 返回 false,auto-purge 该条目,**不**调用 dead callable,日志中**不出现** GDScript "invalid instance" 错误;purge 后注册表计数减 1。**[RISK GUARD]**

- **AC-FUNC-10** (R10 Gamepad 热插拔 — pause + toast + resume): **GIVEN** 游戏处于正常 NORMAL 态,手柄已连接, **WHEN** 拔出手柄, **THEN** 同帧(≤16.6 ms)内: `device_disconnected` 信号发射;`get_tree().paused == true`;toast 显示"控制器断开 — 按任意键继续";toast 以 blocking=false 持锁;**随后**按任意键盘按键,`device_resumed` 信号发射,`get_tree().paused == false`,toast 关闭;手柄重连事件发射 `device_reconnected` 但**不**自动 resume(仍等待用户按键)。

### AC-PERF (性能 / Pillar 5 ≤1 帧承诺)

- **AC-PERF-01** (R3 ≤1 帧 dispatch 承诺): **GIVEN** Godot Profiler 开启,Focus 在 "Input" 类别,游戏稳定 60 FPS, **WHEN** 连续触发 1000 次不同 `act_*` 事件(KB + Gamepad + Mouse 混合), **THEN** 从 `_input(event)` 调用开始到对应 `act_*` 信号发射结束,**每帧**均在同一 `_input` 调用内完成(不经 `call_deferred`);Godot Profiler `Input` 分类下 p99 < 1 ms 主线程;零事件使用 `call_deferred` 排队(日志断言: 无 `call_deferred` 调用记录来自 InputHandler)。

- **AC-PERF-02** (R3 + R7 modal lock acquire/release 耗时): **GIVEN** 测试钩子在 `acquire_modal_lock` / `release_modal_lock` 前后打时间戳, **WHEN** 以 1000 Hz 频率连续调 acquire + release 各 500 次, **THEN** 单次 acquire p99 < 0.1 ms、单次 release p99 < 0.1 ms(主线程,Godot Profiler 分区);全部操作在主线程内完成,不派发 worker。

- **AC-PERF-03** (R6 skippable broadcast 100 entries — Pillar 5 不失守): **GIVEN** 测试钩子注册 100 个 skippable 条目(全为有效 instance,callback 为空 no-op), **WHEN** 触发一次合规 skip 事件, **THEN** 全部 100 条 callback 在同帧 `_input` 内同步广播完毕;主线程耗时 < 1 ms(Time.get_ticks_usec 差值断言);帧预算不超 16.6 ms(Profiler 验证无帧丢失)。

- **AC-PERF-04** (R1 + 启动时 keymap 加载 < 50 ms): **GIVEN** `meta.input.keymap` payload 包含全部 12 个 act_* 的三类绑定(KB primary / KB secondary / Gamepad), **WHEN** 调 `InputHandler.load_keymap(payload)`, **THEN** 调用从开始到返回耗时 < 50 ms(Time.get_ticks_usec 断言);调用期间不阻塞 `_input` 回调(在 `_ready` 或 init 阶段调用,不跨帧挂起);5 秒进入承诺不受影响。

### AC-COMPAT (跨设备 / 跨平台 / Steam)

- **AC-COMPAT-01** (F1 deadzone 3-zone 映射 — inner=0.15 / outer=0.85): **GIVEN** 测试钩子直接注入 `InputEventJoypadMotion` 原始值,`deadzone_inner=0.15`,`deadzone_outer=0.85`, **WHEN** 依次注入 r=0.10 / r=0.50 / r=0.90, **THEN** r=0.10: `joystick_effective_axis` 输出 0.0,无 `act_focus_*` 信号;r=0.50: 输出 ≈ 0.500(容差 ±0.005),fire `act_focus_*`,不触发 skip;r=0.90: 输出 1.0(饱和),fire `act_focus_*` + skip 触发(> 0.8 阈值)。

- **AC-COMPAT-02** (F2 D-Pad repeat — initial=350ms / interval=100ms): **GIVEN** Gamepad D-Pad Right 持续按住,使用单调时钟桩(mock Time)以 10 ms 步进推进, **WHEN** 时间从 0 ms 推至 600 ms, **THEN** t=0 ms dispatch 1 次 `act_focus_right`;t=350 ms dispatch 第 2 次;t=450 ms 第 3 次;t=550 ms 第 4 次;t=600 ms 总计 dispatch 数 = `1 + floor((600-350)/100) + 1 = 4`(与 F2 公式一致);松开后计数器归零,再按产生全新 sequence。

- **AC-COMPAT-03** (F3 input path arbitration — threshold=4px / lockout=200ms): **GIVEN** 初始 `active_path=MOUSE`,arbitration_lockout_ms=200,mouse_motion_threshold=4.0, **WHEN** 先注入 D-Pad Right 事件(t=0),随后 t=80 ms 注入鼠标移动 6 px,再于 t=210 ms 注入鼠标移动 6 px, **THEN** t=0: `active_path` 切换为 KB_GAMEPAD,`focus_path_changed(KB_GAMEPAD)` 信号发射;t=80 ms: lockout 未过期,`active_path` 保持 KB_GAMEPAD,无新信号发射;t=210 ms: lockout 过期且 mouse_delta(6px)> threshold(4px),`active_path` 切换回 MOUSE,`focus_path_changed(MOUSE)` 信号发射。

- **AC-COMPAT-04** (R9 Steam Input 透传 + legacy mode 烟雾测试 — R3 高风险): **GIVEN** 一台未配置过本游戏的 Steam 全新安装,游戏发布配置设为 Steamworks "Input Supported"(或 "Input Required",非 legacy), **WHEN** 连接 Xbox gamepad 启动游戏并导航菜单, **THEN** `input_method_changed(GAMEPAD)` 信号发射(UI 显示手柄 glyph 而非键盘 glyph);手柄方向键 fire `InputEventJoypadButton`(而非 `InputEventKey`,可在 debug 输入日志核实);焦点导航 F2 手感符合 350ms/100ms 调谐。若检测到事件类型为 `InputEventKey` 而非 `InputEventJoypadButton`,则记录 FAIL 并在 QA 报告注明 "Steam legacy mode 配置未正确设置"。**[RISK GUARD]**

- **AC-COMPAT-05** (R5 + R1 dual-focus — diegetic _focus_entered() 实现守门): **GIVEN** 鼠标断开(或移动到屏幕外),仅使用 D-Pad / 键盘导航,遍历所有 MVP diegetic UI 元素(便利贴桌面、情绪板、手牌区中至少各 1 个), **WHEN** D-Pad 方向键依次将焦点移至每个元素, **THEN** 每个元素的 `_focus_entered()` 被调用(可在 GUT 单元测试或 debug overlay 断言),对应 `#C8963C` 2px 焦点环可见(visual sign-off,截图存 `production/qa/evidence/`);`mouse_entered` 信号**不**被触发(D-Pad 路径不走 hover);任何仅依赖 `mouse_entered` 的元素未显示焦点环即 FAIL。**[RISK GUARD]**

- **AC-COMPAT-06** (R8 + Save Rule 14 跨系统契约 — keymap 改后 500ms 落盘) [Deferred until `design/gdd/main-menu-ui.md`]: **GIVEN** Save System 订阅 `keymap_changed` 信号,防抖窗口 500 ms, **WHEN** 玩家在 Remap UI 连续改绑 3 次(间隔 < 500 ms), **THEN** `keymap_changed` 信号发射 3 次;Save System 防抖后仅触发 **1 次** meta 写入;最终写入完成时 `meta.input.keymap` 内容反映第 3 次改绑(最新状态);首次改绑起算 ≤ 500 ms + 写入耗时后 `meta.save` mtime 更新(Save Rule 14 合规)。

### AC-ROBUST (错误恢复 / 边界 / 异常)

- **AC-ROBUST-01** (Edge 9.1 OS 失焦持键 reset_all_action_presses 守门): **GIVEN** 玩家按住 D-Pad Right(或键盘右方向键),F2 repeat 计时器运行中, **WHEN** OS 窗口失焦(模拟 `NOTIFICATION_WM_WINDOW_FOCUS_OUT`), **THEN** Input Handler 在同通知处理内调用 `Input.reset_all_action_presses()`(可通过 GUT mock 断言调用发生);所有 held-direction 计时器重置为 0;焦点恢复后无 ghost `act_focus_*` 重复发射(再次聚焦不按任何键,零 dispatch 发生)。

- **AC-ROBUST-02** (R7 blocking modal skip-leak 守门 — R2 高风险): **GIVEN** 一个 blocking=true modal 的 `release_modal_lock` 调用与一个合规 skip 事件在同一帧到达(通过测试钩子构造), **WHEN** 该帧 `_input` 处理完毕, **THEN** 处理顺序为 `release_modal_lock` 先完成状态转移至 NORMAL,**随后** skip 信号才发射(NORMAL 态下合法);若顺序颠倒(skip 在 MODAL_LOCKED 态尝试发射),则被吞且本帧不发射 — QA 须断言 skip 发射时 state log 显示 NORMAL 而非 MODAL_LOCKED;skip 不应在任何路径下从 MODAL_LOCKED 态泄漏。**[RISK GUARD]**

- **AC-ROBUST-03** (Edge 1 boundary — deadzone clamp 守门): **GIVEN** 通过 Tuning Knob 接口分别设置 `deadzone_inner=0.0`(违规)/ `deadzone_outer=1.0`(违规)/ `skip_axis_threshold=1.0`(违规), **WHEN** 调用 `load_keymap` 或运行时修改 Tuning Knob, **THEN** `deadzone_inner` 被静默 clamp 到 0.05;`deadzone_outer` 被 clamp 到 0.99;`skip_axis_threshold` 被 clamp 到 0.99;均在 DEBUG 级 log 输出 `"[InputHandler] tuning clamp: [param] [orig_val] → [clamped_val]"`;系统不崩溃、不进 ERROR 态。

- **AC-ROBUST-04** (Edge 4 keymap load 未知 action 静默 skip): **GIVEN** `load_keymap(payload)` 的 payload 中包含一个未在 InputMap 注册的 action 名(如 `act_quicksave`,模拟 future-version save 残留),同时包含 3 个合法 `act_*`, **WHEN** 调 `load_keymap`, **THEN** 3 个合法 action 绑定正确应用(QA 通过 `InputMap.action_has_event` 验证);未知 `act_quicksave` 条目静默跳过,不产生 GDScript 错误或异常;DEBUG 日志出现 `"[InputHandler] load_keymap: skipped unknown action: act_quicksave"`;系统回 NORMAL 可正常接受输入。

### AC-A11Y (Accessibility — MVP minimal)

- **AC-A11Y-01** (R1 + input_method_changed 信号契约) [Deferred until `design/gdd/tutorial-onboarding.md` + `design/gdd/accessibility-options.md`]: **GIVEN** 游戏正在运行,Tutorial / HUD 系统订阅了 `input_method_changed(method: InputMethod)` 信号, **WHEN** 玩家从键盘切换到手柄(F3 仲裁判定 `active_path` 从 KB_GAMEPAD 确认切换), **THEN** `input_method_changed(GAMEPAD)` 信号在同帧发射;订阅方收到信号后可渲染对应 glyph(`↑ ↓` → 手柄面键图标);仅切换信号在路径实际变更时发射(同路径重复事件不重复发信号)。

### AC Tier 分级

**MVP 必测(Alpha gate 阻塞)— 23 条**: AC-FUNC-01~10 (10) + AC-PERF-01~04 (4) + AC-COMPAT-01~05 (5) + AC-ROBUST-01~04 (4) = 23。其中 4 [RISK GUARD] AC(AC-FUNC-09 / AC-COMPAT-04 / AC-COMPAT-05 / AC-ROBUST-02)为 gameplay-programmer 高风险路径,须在首个可测 build 优先验证,不得推至 Beta gate。

**MVP 建议测(Beta gate 阻塞)— 2 条**: AC-COMPAT-06(需 Remap UI fixture + Save 联测)、AC-A11Y-01(需 Tutorial / Accessibility GDD 就绪)。

**VS tier 推迟 — Visual sign-off 子项**: art bible §7.5 `#C8963C` 焦点色视觉 sign-off 归属 #13 HUD AC(本 GDD AC-COMPAT-05 仅声明 `_focus_entered()` 实现 contract + 截图存档要求)。

### QA 工具需求

- **输入事件 fixture 库**(`tests/fixtures/input-handler/`): `valid_full_keymap.payload`(12 act_* 全绑定)/ `future_version_keymap.payload`(含未知 `act_quicksave`)/ `empty_keymap.payload` / `invalid_deadzone_extremes.config` / `100_skippables.fixture`(100 条 no-op callback)
- **时钟桩 / 事件注入工具**: GUT mock 替换 `Time.get_ticks_msec` 供 F2 repeat 断言;`InputHandler.test_inject_event(InputEvent)` 仅 debug build;`NOTIFICATION_WM_WINDOW_FOCUS_OUT` 发射钩子供 AC-ROBUST-01
- **Steam 配置烟雾测试**: 每次 build 发布前在 fresh Steam install 机器运行 AC-COMPAT-04,验证 Steamworks launch config "Input Supported / Required";烟雾结果存入 `production/qa/smoke-[date].md`
- **状态机日志**: `InputHandler` 输出 `state_transition: NORMAL→MODAL_LOCKED@t=...ms` 结构化日志供 AC-FUNC-05/06/AC-ROBUST-02 断言;modal lock-stack counter 输出供 AC-FUNC-06 嵌套 modal 断言

## Open Questions

7 条 OQ 集中(分布于 Section C/E),按 owner / target 排序:

| OQ ID | 描述 | Owner | Target Resolution |
|-------|------|-------|-------------------|
| OQ-INP-01 | 嵌套 modal lock-stack 策略(Edge 2.1) — counter + 最严格 blocking flag 胜出方案 needs 验证或替换为"禁止嵌套"硬约束 | systems-designer + game-designer | ADR-XXXX modal 隔离机制 / 或 `/design-review` 后期讨论 |
| OQ-INP-02 | 同帧 double-fire 去重 + `register_skippable` 二次注册策略(Edge 2.5 / 5.2)— Input 同帧去重 vs 上层幂等责任 / silent overwrite vs reject-with-warning 二选一 | systems-designer + game-designer | ADR-XXXX |
| OQ-INP-03 | Godot 4.6 dual-focus 查询 / 绘制 API 具体形式(Rule 5(d)) — `_gui_input` vs `_unhandled_key_input` 路由、theme drawn focus decoration 是否需自绘 | engine-programmer + godot-specialist | ADR-XXXX dual-focus 实现 |
| OQ-INP-04 | Modal 隔离具体 Godot 机制(Rule 7) — Recursive Control disable + `process_mode` 组合的具体节点模式 | engine-programmer | ADR-XXXX modal 隔离 |
| OQ-INP-05 | Native Steam Input 集成在 Switch port / 野心版的切换路径(Rule 9) — 振动 / 触发器 / Gyro 是否在 Switch port 阶段切到 Steamworks Input API | producer + technical-director | Switch port ADR(野心版规划) |
| OQ-INP-06 | `skip_axis_threshold = 0.8` 是否适合 Steam Deck 拇指搁置(Rule 6 + Edge 6.2) — 实测可能需降到 0.7 或 0.85 | gameplay-programmer + qa-tester | Polish playtest |
| OQ-INP-07 | `dpad_repeat_initial_delay_ms = 350` / `interval_ms = 100` 是否适合 25-40 岁中老年玩家手指反应速度(F2) — 慢速 D-Pad 选项是否要在 Alpha 之前进 MVP | ux-designer + qa-tester | Alpha playtest(可推进 Accessibility #20 影响 MVP scope) |

**OQ 标记的 AC**: 解决前以下 AC 的精确表述可能需要更新: AC-FUNC-06(OQ-01 嵌套 modal 行为)、AC-FUNC-08(OQ-02 同帧 co-fire vs 去重)、AC-COMPAT-01(OQ-06 axis threshold)、AC-COMPAT-02(OQ-07 D-Pad repeat 节奏)。
