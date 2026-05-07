# Scene & Day Flow Controller

> **Status**: Designed (pending review)
> **Author**: huanghaibin + creative-director (Section B framings) + systems-designer (Section C Core Rules + States + Section E Edge Cases) + gameplay-programmer (Section C feasibility + R1-R7 mitigations) + engine-programmer (Section C Engine Integration Rules C-ENG-01..10) + qa-lead (Section H 27 AC)
> **Last Updated**: 2026-04-26
> **Layer**: Core | **Order**: #6 | **Size**: M | **Bottleneck**: ⭐
> **Implements Pillar**: P5 主(地铁可玩性 — 5 秒进入 / 5 秒暂停的全游戏心跳)+ P3 守(每月必走 GAME OVER 不可逆)+ P1 守(8 AP / 三层 KPI 节奏)+ P4 守(主语翻转原则 + 三轨铁三角 dispatch)
> **Authoring autonomy mode**: v2 no-prompt(总 widget 数: 0,routine autopilot + 5 specialist 整合)

## Overview

**Scene & Day Flow Controller** 是《活过第 X 集》的**全游戏心跳节拍器** —— 一个 Autoload 单例,负责把"一秒到一年"全时间尺度的游戏流程编排成有限状态机,并向所有下游系统广播 `scene_state_changed` 总线信号。**双重身份**:技术层面它是 5 Foundation 系统的**启动调度仲裁场** + **8 sub-mode 总线 owner** + **pause-aware game-time tick** + **autosave hook scheduler**;叙事层面它是玩家感受到的"一天 / 一周 / 一月 / 一年"节奏的唯一来源 —— 早晨预告 → 白天 8 AP → 下班抉择 → 今日总结 → 周末两天 → 月末 KPI 考核 → GAME OVER 不可逆 → 离职证明 → Main Menu 的完整时间几何。

### 8 Sub-Mode Enum 锁定

本 GDD 是 source of truth。`audio-manager.md` Rule 6 + `lighting-visual-state.md` Rule 1 必须 1:1 对齐此表;任何下游 GDD 引用 sub-mode 必须使用此 enum 字面值。

| Enum | 玩家时刻 | 时长 | Audio sub-mode | Lighting CanvasModulate |
|------|----------|------|----------------|--------------------------|
| `MAIN_MENU` | 主菜单 | 玩家驻留 | 主菜单 ambient | 中性灰 |
| `MORNING_BRIEFING` | 早晨事件预告 | <30s | 同主菜单 ambient | 晨光黄 |
| `ACTION_DAY` | 白天行动 8AP | 玩家驱动 | 办公室 ambient (day) | 日光灯白 |
| `ACTION_OVERTIME` | 加班(>8AP) | 玩家驱动 | 办公室 ambient (overtime) + 嗡声加重 | 日光灯白 + 饱和度降 |
| `AFTER_WORK` | 下班抉择 | <60s | 下班抉择 ambient | 18:00 日落橙 0.5s 后转夜 |
| `DAILY_RECAP` | 今日总结 | <90s | 今日总结 ambient | 数据屏蓝光 |
| `KPI_REVIEW` | 月末 KPI 考核 | <120s | KPIREVIEW ENDGAME_LOOP BGM | KPI 紫 `#3A3050` |
| `GAMEOVER` | 离职证明 | 1500ms 锁(Save Rule 21) | GAMEOVER stinger + 静音 | 灰度压抑 + 累积视觉峰值 |

### Pillar 服务

- **P5 地铁可玩性**(主):#6 owns "**5 秒进入**" 启动序列(meta load → 4 系统 payload → 4 `_mark_ready()` ≤ 2 s)+ "**5 秒暂停**" pause 协议(`act_pause` → 全系统 game-time 冻结一致性)。任何 sub-mode 边界必须支持 Save 立即触发(玩家随时退出地铁不丢进度)。
- **P3 死亡是注定的**(守):`KPI_REVIEW` → `GAMEOVER` 转移**永不可逆**,#6 是这个边界的 single arbitrator。Save Rule 21 离职证明 1500 ms 由 #6 dispatch + 锁定 Input skippable 守门,玩家不可推翻 transition tone。
- **P1 平庸是一种艺术**(守):#6 锁住"**反向 KPI 节奏的不可加速 / 不可跳过**" — 月末必须走 `KPI_REVIEW` sub-mode,玩家无法用任何输入跳到下月。`act_skip` 仅跳过演出过场,**不**跳过结算。

### 6 项 Cross-System 仲裁责任

本 GDD 必须 surface 解决(详见 Section C):

1. **启动序列**: Save meta load → 4 系统 payload 注入 → 4 `_mark_ready()` 序列 → Loading Scene 退出
2. **`WM_WINDOW_FOCUS_OUT` 三方语义**: Save = debounced autosave / Audio + Lighting = pause-equivalent / Input = `reset_all_action_presses`,#6 翻译为内部"软暂停"信号
3. **Pause 期间 game-time vs wall-clock 边界**: `SceneTree.paused = true` 时 Loc 30 s watchdog 挂起 / Lighting 累积 state 暂停 / Audio fade 已启动则继续 / Save autosave debounce 不受影响(走 worker)
4. **Save Rule 14 settings 防抖计时器粒度**: global single timer(所有 settings 信号共享 500 ms),最后一个信号到达后 500 ms 落盘合并 payload
5. **`scene_state_changed` 同帧主线程预算分摊**: 16.6 ms 帧预算分配 — Audio ≤ 1 ms / Lighting < 1 ms / 各 UI ≤ 2 ms / Save snapshot ≤ 4 ms / 余 ~8 ms 缓冲
6. **8 sub-mode enum 锁**(本 Overview 表)+ 跨 GDD 1:1 映射(Audio 表追加 enum 列 + Lighting 已用 enum)

### 5 NOT 边界(scope creep 防护)

- **NOT** 行动卡 / AP / KPI / NPC 关系业务逻辑(分别由 #7 / #11 / #9 / #8 own,#6 仅 dispatch sub-mode 信号,不计算业务数值)
- **NOT** UI rendering / HUD layout(由 #13 HUD + 各 UI GDD own,#6 仅 emit 信号)
- **NOT** 事件剧本调度(由 #10 Event Script Engine own,#6 在 sub-mode 转移时 emit 信号供 #10 订阅)
- **NOT** 资源加载 / asset preload 实现(由 5 Foundation GDD own,#6 仅 schedule 调用 + watchdog 监听)
- **NOT** 输入语义 / keymap remap(由 Input #2 own,#6 仅消费 `act_pause` / `act_skip` 等已聚合的 action)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 让玩家通过 input 跳过 `KPI_REVIEW` 结算(违反 P3)
- **NOT** 让 sub-mode 转移加速 / 倍速(违反 P5 节奏稳定 + P3 GAME OVER 必然性)
- **NOT** 让 pause 期间 game-time 继续推进(违反 P5 地铁可玩性 — 玩家 Alt-Tab 看微信不被惩罚)
- **NOT** 让 startup sequence 卡 > 5 秒不进入 Main Menu(违反 P5 5 秒进入承诺,触发 watchdog escalation)
- **NOT** 在 `GAMEOVER` 后保留任何"复活 / 重试 / 撤销"路径(违反 P3 GAME OVER = 剧终)

### Source 引用

`design/gdd/game-concept.md` Core Loop §L120-158(Moment-to-Moment / Short-Term / Session-Level / Long-Term 4 时间尺度框架)+ Pillars §L162-191(P5/P3/P1 锚) + 5 Foundation GDD 全套(契约协议) + `design/gdd/gdd-cross-review-2026-04-25.md` 6 BLOCKING 仲裁清单。

## Player Fantasy

### 主锚: "周一 9 点 17 分,你已经在工位上了"

**场景**(玩家时刻):
点开游戏图标。没有 Logo Splash,没有"Press Any Key",没有今日剧情提要。Loading 三秒,黑屏淡入,你坐在工位上,日光灯已经亮了,Outlook 有 4 封未读,组长发的"周报模板.docx"消息红点亮着。系统时间显示 9:17。**你不是"开始游戏"了,你是"已经到了"**。

**Pillar 服务**:
- **主 P5 地铁可玩性**: 5 秒进入的极限诚实形态 —— 游戏不给你"准备好"的过渡,因为现实里你也没有
- **守 P3 死亡是注定的**: "9:17 已经在工位"暗示了无数个 9:17 已经过去、还会过去
- **守 P1 平庸**: 没有 9:00 整点的仪式感,是 9:17 的迟到默认值
- **守 P4 黑色幽默**: 含蓄反讽藏在"系统不让你准备"这个游戏设计选择里

**跨 GDD negative space 联动**(本锚承接的 5 GDD 共振):
- **Input** "工位上唯一不卡的东西" 同向:都把游戏框架嵌进打工日常的物理在场感
- **Audio** "日光灯嗡的不是 BGM" 共振:Loading 完淡入的第一帧就是日光灯嗡声,不是开场音乐
- **Lighting** "我的桌子怎么这么脏" 形成时间序列:9:17 你看见桌子,然后才慢慢觉得它脏

**❌ Tone 风险(必避)**:
- "崭新的一天"、"全新挑战"、"整装待发"(励志系)
- "你的第 N 个工作日开始了"(戏剧性叙事)
- "Loading..."、"准备就绪"、"开始游戏"按钮(跟手系仪式感 / 史诗感)
- 9:00 整点的钟声(整点仪式 = 仪式感 = 励志暗示)

**✅ Tone 守护(推荐)**:
- "已经在"、"又是周一"、"9:17"(精确到不整的分钟数 = 麻木的疲惫感)
- "未读 4"、"红点"(累积的、被推过来的、不可拒绝的)
- "默认"、"照例"、"还是"

### 副锚: "月末像降温,你只能多穿一件"

**场景**(玩家时刻):
月末 KPI 结算前一天,你没做错什么,但月末就是来了。游戏不会给你"月末警告!"弹窗,只是某个早上你打开游戏,日历右上角悄悄变成 28 号,组长群里发"本月数据明天出"。**你没"挣到"月末,月末是天气**。GAME OVER 那一刻,KPI 紫色弥漫的光里,屏幕静止,没有"You Died",没有重试 prompt,只有一行小字:KPI 未达标。

**Pillar 服务**:
- **主 P3 死亡是注定的**: "降温"作为不可抗的自然律,完美承载 GAME OVER 不可逆性
- **守 P5 地铁可玩性**: 5 分钟一段地铁刚好能"穿过"一次月末降温(P5 节奏稳定)
- **守 P1 平庸**: 不是英雄式的 boss 战,是季节
- **守 P4 黑色幽默**: 含蓄反讽藏在"自然律"和"KPI"被并置上,不点破

**跨 GDD negative space 联动**(三轨铁三角直接锚):
- **Audio** "月末打卡机不是胜利音" 直接同源 —— 两者锚同一个月末时刻,Audio 守听觉,#6 守节奏
- **Localization** `GAMEOVER.TITLE_IRONY` "恭喜晋升" 共振 —— 降温 + 恭喜晋升 = 反讽的双重失温
- **Lighting** `KPI_REVIEW` 紫 `#3A3050` + 视觉静止 同步:`SCENE_STATE_KPI_REVIEW` 信号一发,三轨同时拒绝庆祝
- **Save** "离职证明风格 Run 摘要" 因果:月末降温 → 离职证明

**❌ Tone 风险(必避)**:
- "终极挑战"、"决战月末"、"BOSS 战"(史诗系)
- "再坚持一下就赢了"(励志系)
- "KPI 警报!"、倒计时红色闪烁(戏剧 UI / 跟手紧张感)
- 任何"恭喜达标 / 月度优秀员工"提示(违反 Pillar 4 + P1 红线)

**✅ Tone 守护(推荐)**:
- "降温"、"季节"、"到了"、"该来的"
- "悄悄"、"不知不觉"、"日历翻到"
- "多穿一件"、"扛过去"、"过冬"

### Internal Design Test: 主语翻转原则

每个 sub-mode 转移文案、UI 提示、过场字幕审校时,问一个问题:**"这是玩家发起的,还是时间推过去的?"**

- 如果文案让玩家觉得"我做完了 X,现在进入 Y"(主语 = 玩家)→ 改写
- 如果文案让玩家觉得"X 结束了,Y 来了"(主语 = 时间)→ 通过

**正例**:"下班时间到了。"(主语 = 时间) / "周一 9:17"(无动作主语,纯时间锚)
**反例**:"完成 8 AP 后进入下班抉择。"(主语 = 玩家动作)→ 改成"8 AP 用完了,该下班了。"

**design test 的隐含 Pillar 服务**:这条原则是 Pillar 1(平庸)+ Pillar 3(必然)+ Pillar 4(黑色幽默含蓄度)的语法层守门 —— 中文"被字句"和无主语句天然承载"被结构强加"的疲惫感,与"主语主动"的英雄叙事形成对照。所有下游 GDD(#7 AP / #9 KPI / #16 KPI Review / Recap UI 等)的玩家可见文案审校须援引此原则。

### Source 引用

`creative-director` Section B consultation(2026-04-26)+ `design/gdd/game-concept.md` Pillars + 5 Foundation GDD Player Fantasy(Save/Input/Localization/Audio/Lighting 的 negative space 锚)+ `design/art/art-bible.md` §2 时钟光语(主锚 9:17 日光灯首帧 + 副锚 KPI 紫月末)。

## Detailed Design

本节分四部分:**14 Core Rules**(业务行为)+ **States and Transitions**(8x8 矩阵)+ **Interactions**(7 跨系统契约)+ **10 Engine Integration Rules**(Godot 4.6 specifics)。所有 Rule 编号被下游 GDD 引用时必须使用本节字面值(`Rule N` / `C-ENG-NN`)。

### Core Rules

**Rule 1 — Autoload 单例命名与节点路径**

`SceneDayFlowController` 作为 Godot Autoload 单例挂载于 `/root/SceneDayFlowController`。**全游戏唯一 sub-mode 调度权归属此节点**。任何其他节点禁止直接写 `current_mode`,只能通过调用 `SceneDayFlowController.request_transition(to: SubMode)` 发起请求(配合 Rule 14 主语翻转 dispatch 强制)。

**Rule 2 — SubMode enum 锁定**

*仲裁 #6 — 8 sub-mode enum 锁。* Section A 表为 source of truth,本 Rule 引用:

```gdscript
enum SubMode {
    MAIN_MENU, MORNING_BRIEFING, ACTION_DAY,
    ACTION_OVERTIME, AFTER_WORK, DAILY_RECAP,
    KPI_REVIEW, GAMEOVER
}
```

所有 GDD、代码、lint 工具必须使用此 enum 字面值,禁止字符串替代(配合 W-CONS-2 修复 Audio Rule 6 表英文 enum 列对齐)。

**Rule 3 — `scene_state_changed(from, to)` 信号协议**

*仲裁 #6 主语翻转 + W-CONS-3 帧预算分摊 + R2 mitigation。* `#6` 单点 emit:`signal scene_state_changed(from: SubMode, to: SubMode)`。

下游订阅者帧预算契约(同帧主线程):

| 订阅者 | 主线程预算 | 备注 |
|--------|-----------|------|
| Audio Manager | ≤ 1 ms | AudioServer 异步,本 budget 仅含主线程 dispatch 逻辑 |
| Lighting Controller | < 1 ms | CanvasModulate 切换 + Tween 启动 |
| 各 UI 屏(HUD / KPI Review / Recap / 其他) | ≤ 2 ms / 屏 | 总和不超过 ~6 ms |
| Save snapshot | ≤ 4 ms | 仅 dispatch,序列化走 WorkerThreadPool(Save Rule 7) |
| 缓冲余量 | ~8 ms | 防 GC / Godot 内部抖动 |

**R2 mitigation — subscriber handler 必须轻量**:订阅者在 `scene_state_changed` 回调内仅做"状态登记 + 必要的 1 帧内 dispatch"。**禁止**在 handler 内直接执行重负载(JSON 序列化 / 大 PackedScene 实例化 / 全局视觉 Tween 同帧完成)。重负载必须 `call_deferred()` 入下一帧,或入 WorkerThreadPool。

**禁止递归 dispatch**:下游订阅者不得在 `scene_state_changed` 回调内调用 `request_transition()`(防递归死锁,违反触发 Rule 8 escalation)。

**Rule 4 — 启动序列协议**

*仲裁 #1 — B-SCN-1 / W-SCN-1 / W-SCN-2 + R1 mitigation + C-ENG-01 + C-ENG-04 + C-ENG-05。* 冷启动严格序列:

```
T+0ms:  Splash 显示 + Loading Scene 实例化(C-ENG-05: 走 ResourceLoader.load_threaded_request)
T+0ms:  Save 同步 meta load(阻塞主线程,目标 ≤ 16.6ms;HDD+AV 场景容忍 ≤ 50ms,Save AC-PERF-01)
T+~50ms: 并行注入 payload → [Localization, Audio, Lighting, Input]
        - Loc parse < 100ms (Loc Rule 8)
        - Audio preload ≤ 200ms (audio_preload_budget_ms)
        - Lighting accumulation_state load < 50ms
        - Input keymap_payload 注入(同步)
T+0~10s: 等待 4 系统各自 _mark_ready() 信号
        - Audio watchdog 10s (audio_loading_watchdog_ms)
        - Lighting watchdog 10s (lighting_loading_watchdog_ms)
        - 两 watchdog 同时计时,同帧 push_error 是预期 debug 噪声,不互相依赖
        - Loc 30s 演出锁不在启动期(走独立路径)
T+~250ms: 4 系统全 ready → Loading Scene 退出
T+~250ms: emit scene_state_changed(LOADING→MAIN_MENU)
P5 5 秒进入承诺 budget = 5000ms - meta load - preload - watchdog 余量
```

**R1 mitigation — Autoload init 顺序**:`#6` 必须是 `[autoload]` 列表中**最后一个**声明的单例(C-ENG-01)。`#6._ready()` 中先检查各 Foundation 的 `is_ready` bool 属性,仅对尚未 ready 的系统 `await` `_mark_ready` 信号 — 避免错过已发射的单次信号。

`#6` **是且仅是** `_mark_ready()` 的唯一合法调用者。Foundation 系统 `_mark_ready()` 收到 #6 调用后置 `is_ready = true`,然后 emit 自身 ready 信号。

**Rule 5 — `WM_WINDOW_FOCUS_OUT` 三方语义 → `soft_pause_requested`**

*仲裁 #2 — B-CONS-1 + R3 mitigation + C-ENG-03。* `#6` 通过 `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` 接收 window focus event(C-ENG-03 — 主线程同步 callback,**禁用 `NOTIFICATION_APPLICATION_PAUSED` 因桌面 no-op**),翻译为内部信号:

```gdscript
signal soft_pause_requested(source: StringName)  # source: "wm_focus_out" | "act_pause" | "modal_open"
signal soft_resume_requested()
```

下游各自自决响应行为(`#6` 不强制执行具体语义):

| 系统 | 响应 | Rule 依据 |
|------|------|-----------|
| Save | debounced autosave(500 ms worker,Rule 19) | Save Rule 19 |
| Audio | Music→-∞ 200 ms / Ambient→-24 dB 300 ms fade(AudioServer 异步) | Audio Section E 公版 |
| Lighting | `pause_tween()` 即时停 | Lighting Rule 9 |
| Input | `Input.reset_all_action_presses()` + reset held-direction timers | Input Edge 9.1 |

**R3 mitigation — `SceneTree.paused = true` 调用权独属 `#6`**:所有下游系统(包括 Settings UI 打开)**必须通过 `#6` 的 `request_soft_pause(source)` 公开方法**请求暂停,**禁止**直接操作 `SceneTree.paused`。Audio/Lighting 的 fade/transition 节点 `process_mode = PROCESS_MODE_ALWAYS` 以保证跨 pause 边界继续执行(防 fade 卡半暂停态)。

`WM_WINDOW_FOCUS_OUT` ≠ `WM_CLOSE_REQUEST`。`WM_CLOSE_REQUEST` 由 Save 独立处理(同步 flush,不走 `soft_pause_requested`)。

**Rule 6 — Pause 期间 game-time vs wall-clock 边界**

*仲裁 #3 — B-SCN-3 / B-SCN-4 + C-ENG-02 + C-ENG-07。* `SceneTree.paused = true` 期间各系统行为:

| 系统 | 行为 | 实现机制 | 计时器类型 |
|------|------|---------|-----------|
| Loc 30 s watchdog | **挂起**(不计时) | watchdog Timer 节点 `process_mode = PAUSE_INHERIT` | game-time(SceneTree 驱动) |
| Lighting 累积 state(`month_age` 等) | **暂停**(不累加) | `accumulation_event(type, delta)` 由 `#6` game-time tick 驱动,paused 时 tick 停发 | game-time |
| Audio fade(已启动) | **继续完成** | AudioServer 走独立线程,不受 SceneTree.paused 影响 | wall-clock(audio thread) |
| Save autosave debounce | **不受影响** | WorkerThreadPool 独立(Save Rule 7) | wall-clock(worker) |
| `#6` 自身 tick | **持续**(`PROCESS_MODE_ALWAYS`,C-ENG-02) | 但 game-time 累加器(Rule 9)在 paused 期间不增长 | wall-clock 主线程,game-time 选择性累加 |

**关键设计点**: `#6` 自身始终运行(确保 watchdog escalation / Save flush 调度不中断),但其内部 game-time 累加器在 paused 期间冻结。Lighting 累积 state 与 wall-clock **完全解耦** — 玩家 Alt-Tab 一夜回来桌子不脏 4 级。

**Rule 7 — Settings 信号合流 → Save 防抖单 timer**

*仲裁 #4 — W-SCN-3。* 所有 settings 变更信号(`bus_volume_changed` / `locale_changed` / `keymap_changed` / `narrative_density_changed` 等)共享 `#6` 内**唯一**一个 500 ms `Timer` 节点(`_settings_debounce_timer`):

```gdscript
# 任意 settings 信号到达 → reset 计时器
# 500 ms 静默后 → 单次合并 payload 落盘
# meta_settings_debounce_ms = 500 (entities.yaml 注册常量)
```

**禁止 per-signal-key 独立防抖**(否则 3 信号同帧到达 → 3 次写盘,违反 Save Rule 14 节流意图)。**内存表立即生效**(Audio bus / TranslationServer locale / InputMap action 全部即时应用),防抖仅控制磁盘写入频率。

下游系统改 settings 时仍 emit 自身信号(不破坏跨系统解耦),`#6` 作为 Save Rule 14 的 single subscriber 把所有 emit 合流。

**Rule 8 — 帧预算监视器 `FrameTimeMonitor`**

*仲裁 #5 — W-CONS-3 + R5 mitigation。* `#6` 内置 `FrameTimeMonitor`,在每次 `scene_state_changed` emit 前后用 `Time.get_ticks_usec()`(C-ENG-07 wall-clock 不受 paused 影响)测帧时长:

| 阈值 | 处理 | 仅 debug build |
|------|------|---------------|
| > 20 ms (warning,放宽 ~3.4ms 容忍 GC + 4.6 内部抖动) | `push_warning("[SceneDayFlow] transition frame budget exceeded: %.1f ms")` | ✅ |
| > 33.3 ms (2 帧 critical) | `push_error("[SceneDayFlow] transition frame budget CRITICAL: %.1f ms")` | ✅ |
| Release build | 完全剔除监视器(零 overhead) | — |

**R5 mitigation**:监视器仅在 `OS.is_debug_build()` 为真时激活,Release build 完全剔除以避免观察者效应。warning 阈值 20 ms(非 16.6 ms 硬断言)容忍正常 GC / Godot 内部抖动。CI 中 `--verbose` 模式下 `push_error` 视为 test failure。

**Rule 9 — Game-time Tick 协议 — 离散事件驱动**

*R4 mitigation — frame-rate 独立性。* `#6` 维护 game-time 累加器,但**仅在以下两类事件触发推进**,**不**用 `_process(delta)` 浮点累加:

1. **AP 消耗事件**(`ACTION_DAY` / `ACTION_OVERTIME`): 玩家每打 1 张行动卡消耗 1 AP,#6 接到 `ap_consumed(amount)` 信号后推进 game-time 离散步(`game_minutes_per_ap = 60` 约 1 小时/AP,Tuning Knob)。
2. **Sub-mode 转移事件**: `MORNING_BRIEFING → ACTION_DAY` 推进至 09:00,`ACTION_DAY → AFTER_WORK` 推进至 18:00,`AFTER_WORK → DAILY_RECAP` 推进至 22:00,`DAILY_RECAP → MORNING_BRIEFING` 推进至次日 09:00。

**禁止**`game_time += delta`(60 fps vs 144 fps 累加偏差导致月末日历漂移)。月末触发条件(Rule 10)= "AP 消耗总数达到 N 天 × 8 AP"(整数比较,与帧率完全解耦)。

`MAIN_MENU` / `MORNING_BRIEFING` / `DAILY_RECAP` / `KPI_REVIEW` / `GAMEOVER` 期间 game-time tick **不累加**(玩家无法"拖时间"规避 KPI 节奏,守 P1)。

每次推进时 `#6` emit `accumulation_event(type, delta_units)` 驱动 Lighting 累积 state(Rule 6)。

**Rule 10 — 月度结算触发协议**

`ACTION_DAY` / `ACTION_OVERTIME` 中,`#6` 监视 `current_day >= days_in_month`(由 Rule 9 离散 tick 推进)。条件满足时:

1. **冻结新 Action Card 入队**(emit `action_lockout_started` 供 #11 Action Card 系统订阅)
2. 等待当前 Action 动画完成(若有,见 Rule 13 modal stack)
3. `request_transition(KPI_REVIEW)` —— **守门**: 必须先完成当前 Action 动画;Modal 不阻塞 KPI_REVIEW(Rule 13 例外二)
4. `KPI_REVIEW` 结算后由 #16 KPI Review GDD 回调 `kpi_score`:
   - `kpi_score >= kpi_threshold` → `MORNING_BRIEFING`(新月)
   - `kpi_score < kpi_threshold` → `GAMEOVER`(必然性,Rule 11)

(P1 守 KPI 节奏不可加速 / P3 守 GAME OVER 不可逆)

**Rule 11 — GAME OVER 不可逆性强制**

*P3 守 + R6 mitigation。* `GAMEOVER` 是**终态**。`request_transition()` 传入 `GAMEOVER` 后,状态机永久锁定:任何来源(包括调试工具)调用 `request_transition(非 GAMEOVER)` 均被静默丢弃 + `push_warning`。

**R6 mitigation — Crash 恢复路径**:Save Rule 21 写入顺序锁定:**先**持久化 `meta.run_ended = true` + `meta.end_reason` 至 meta(原子写,worker thread 同步 fsync),**再**启动 1500ms 离职证明演出锁定。`#6` 启动序列(Rule 4)在 Save meta load 后**优先检测 `run_ended == true`**:

- `run_ended == true` → 强制路由至"离职证明回放(若 transition 中断未播完)→ Main Menu Archive 列表",**跳过任何 `ACTION_DAY` 恢复路径**。
- `run_ended == false` → 正常恢复至上次 sub-mode

解除锁定的唯一路径是玩家在 GAME OVER 屏选择"新局" — 触发完整 Save archive 事务(Save Rule 22)+ `SceneTree.reload_current_scene()`,**不**走 `request_transition()`。

(防止玩家通过强制 Alt+F4 + 重启"续命")

**Rule 12 — Skippable 注册 / 注销协议**

*cite Input Rule 6 + Save Rule 21。* 演出型 sub-mode(`MORNING_BRIEFING` / `DAILY_RECAP` / `KPI_REVIEW`)进入时,`#6` 向 `InputHandler` 注册 skippable token:

```gdscript
InputHandler.register_skippable(token_id: StringName, on_skip: Callable)
```

退出 sub-mode 时**必须**注销(防止 R-INP-2 modal-skip-leak):`InputHandler.unregister_skippable(token_id)`。

`KPI_REVIEW` 的 `on_skip` 回调受 `final_transition_duration_ms = 1500 ms` 上限守门 — skip 仅可跳到最后 1 帧(transition 收尾),**不可截断整个 transition tone**(Save Rule 21 守 P3 + Pillar 4)。

**注**: `final_transition_duration_ms` 当前仅锁 GAME OVER 离职证明(Save Rule 21 字面 — see B-SCN-2)。月末 `KPI_REVIEW` 演出时长由 #16 KPI Review GDD 单独锁(候选 knob `kpi_review_transition_duration_ms`,Section J OQ-SDF-XX)。

**Rule 13 — Modal Stack 协调**

*cite Input Rule 7。* `InputHandler` 维护 `MODAL_LOCKED` 状态(Input Rule 7 blocking modal stack)。当 `MODAL_LOCKED` 激活时:

- `#6` 收到 `request_transition()` 请求时**不立即执行**,入 `_pending_transition` 队列(LIFO,最近请求覆盖)
- Modal 解锁(Input emit `modal_dismissed`)后,`#6` 立即处理队列首项
- **例外一 — `GAMEOVER` 转移**: 无论 modal 状态,立即执行(P3 不可逆优先级最高 + Rule 11 红线)
- **例外二 — 月末强制 `KPI_REVIEW`**: Rule 10 触发的 KPI Review 不入队,直接强制 dismiss 当前 modal + 转移(P1 守 KPI 节奏)

**Rule 14 — 主语翻转 dispatch 强制 + 文案审校 lint**

*P4 守 + R7 mitigation 拆 2 层执法。* 实现拆分两层避免 NLP impossibility:

**层 1 — Code-enforced(运行时强制)**:
- 所有 `scene_state_changed` 信号必须由 `SceneDayFlowController` 单点 emit,**禁止下游系统自行调用 `request_transition()` 驱动 sub-mode 切换**(防"下游自驱动"破坏节奏单点控制)。Code Review 阶段 BLOCKING。
- 所有 sub-mode 转移文案**禁止传 raw string**,只允许传 Localization key(`tr(key)`)。`#6` 不解析文案内容,仅传递 key reference 到 Localization 系统。

**层 2 — Editorial lint(CI lint 工具,文案审校)**:
- `tools/subject_inversion_lint.py` 扫描 Localization CSV 中所有 `TRANSITION.*` / `SCENE_STATE.*` / `KPI_REVIEW.*` / `GAMEOVER.*` key 的文案,正则匹配主动语态触发词("完成 / 达成 / 进入 / 开始 / 你已 / 玩家")。命中触发 PR-blocking lint failure。
- writer + localization-lead 在 CSV 提交时做最终人工审校。
- AC-TONE-XX 联合 lint 把此 lint 加入 CI(同 Audio + Lighting + Localization 三轨 lint,扩展为四轨)。

**Internal Design Test 引用**(Section B): 每个 transition 文案审校问"主语 = 时间 vs 玩家"。

---

### Engine Integration Rules (Godot 4.6)

10 条 Godot 4.6 specific 实现规约,全部由本 GDD 锁定。详见各条 cite 与 `docs/engine-reference/godot/breaking-changes.md`。

**C-ENG-01 — Autoload 初始化顺序锁定**

`SceneDayFlowController` 必须是 `project.godot` `[autoload]` 列表中**最后一个**声明的单例,所有 Foundation 系统(SaveSystem / InputManager / LocalizationManager / AudioManager / LightingController)在其之前声明。`_init()` 中禁止跨单例调用(`get_tree()` 返回 null);仅 `_ready()` 中可访问其他单例。Rule 4 启动序列依赖此约束。

**C-ENG-02 — `process_mode = PROCESS_MODE_ALWAYS`**

`SceneDayFlowController._ready()` 中必须执行 `process_mode = Node.PROCESS_MODE_ALWAYS`,确保全局暂停期间状态机 tick / watchdog 检查 / Foundation 仲裁调度不中断。**子节点 watchdog Timer** 反而设 `PAUSE_INHERIT`(Rule 6 — Loc/Lighting watchdog 在 paused 期间挂起)。

**C-ENG-03 — `NOTIFICATION_WM_WINDOW_FOCUS_OUT` 主线程同步 + 桌面专属**

软暂停信号必须通过 `_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` 实现(主线程同步 callback)。**禁用 `NOTIFICATION_APPLICATION_PAUSED`**(value `2`,移动端专属,桌面 Win/Linux/macOS no-op)。响应必须主线程同帧处理,不得 `call_deferred()`(避免同帧输入漏判)。

**C-ENG-04 — `call_deferred` vs `await process_frame` 行为差异**

启动序列各步串联用 `call_deferred()`(同帧末尾 → 下帧开始)。需等待节点树稳定时用 `await get_tree().process_frame`(明确注释原因)。**禁止**用 `await get_tree().physics_frame` 串 UI / 状态机流转(物理帧 60 Hz 固定,与渲染帧解耦)。

**C-ENG-05 — `change_scene_to_packed()` 必须预加载**

Loading Scene 退出路径必须保证目标场景 `PackedScene` 已通过 `ResourceLoader.load_threaded_request()` 完成后台加载,加载完成信号收到后**才**调用 `SceneTree.change_scene_to_packed()`。**禁止**在同帧内连续调用两次 `change_scene_to_packed()`。同步 `change_scene_to_file()` 在大型 2D 场景实测可达 80-200 ms,违反 P5 5 秒进入。

**C-ENG-06 — `Engine.get_process_frames()` 作为 monotonic 帧计数器**

Save Rule 13 `snapshot_id` 必须使用 `Engine.get_process_frames()`(单调递增,paused 时停止递增 — 这是预期),**不得**使用 `Engine.get_frames_drawn()`(渲染帧数,跳帧时非单调)。需 wall-clock 时间戳组合 `Time.get_ticks_msec()`。

**C-ENG-07 — `Time.get_ticks_msec()` 用于 wall-clock watchdog**

watchdog 启动 timestamp 用 `Time.get_ticks_msec()`(系统级 wall-clock,**不受 SceneTree.paused 影响**,**不受 Engine.time_scale 影响**)。**禁用**帧计数器(`get_process_frames()`)做 watchdog 超时(paused 时帧停增长导致虚假超时)。

**注**: Rule 6 的 watchdog Timer 节点(`PAUSE_INHERIT`)仍是首选实现 — Timer 节点自动随 SceneTree.paused 挂起。仅在不能用 Timer 节点的场景(如 worker thread 任务超时)用 `Time.get_ticks_msec()` 手动比较。

**C-ENG-08 — `WorkerThreadPool` 主线程回调安全边界**

`WorkerThreadPool.add_task()` 工作线程**禁止**调用 SceneTree / Node API(`get_tree()` / `emit_signal()` 触发 Node 方法)。完成后必须通过 `Callable.call_deferred()` 路由回主线程后再触发状态机迁移信号。Save Rule 7 序列化已遵守此约束;`#6` 自身**禁止**向 WorkerThreadPool 提交涉及 SceneTree 操作的 task。

**C-ENG-09 — `@abstract` 修饰状态机基类(4.5+)**

全局状态机 `BaseSubModeState` 基类必须使用 `@abstract`(Godot 4.5+ 新语法,LLM 知识截断 ~4.3 — 实现前对照 `docs/engine-reference/godot/breaking-changes.md` 4.4→4.5 行验证)。`on_enter()` / `on_exit()` / `tick(delta_units: int)` 三方法声明为 `@abstract`,各具体状态类(MainMenuState / ActionDayState 等)必须 override。防漏写 callback 静默空跑(实例化 `@abstract` 类编辑器 + 运行时报错)。

**C-ENG-10 — `NOTIFICATION_PREDELETE` 最终清理**

`SceneDayFlowController` 必须实现 `func _notification(what: int)`,在 `what == NOTIFICATION_PREDELETE` 分支中调用 Foundation 系统的紧急 flush 接口(Save flush pending settings / Audio fade-out / Lighting accumulation save)。**禁止**在 `_exit_tree()` 做最终清理(`_exit_tree()` 在 `NOTIFICATION_PREDELETE` 之前触发,此时其他 Autoload 节点树可能仍在释放)。

**Engine Rule 实测 + 验证清单**(高风险条目,由 ADR / 首测实测确认):
- C-ENG-02: `PROCESS_MODE_ALWAYS` Autoload 在 4.6 SceneTree.paused 实测行为(最小复现场景验证)
- C-ENG-05: `change_scene_to_packed()` 4.5 SceneTree 重构对 2D 路径性能基准(profiler 实测)
- C-ENG-09: `@abstract` 4.5+ 语法实测验证(对照官方文档)

→ Section J Open Questions 收 OQ-SDF-ENG-01..03 三条延 ADR-XXXX。

---

### States and Transitions

**全转移矩阵**(✅ = 允许 / ❌ = 禁止 / 备注 = 触发条件)

| From \ To | MAIN_MENU | MORNING_BRIEFING | ACTION_DAY | ACTION_OVERTIME | AFTER_WORK | DAILY_RECAP | KPI_REVIEW | GAMEOVER |
|-----------|-----------|------------------|------------|-----------------|------------|-------------|------------|----------|
| MAIN_MENU | — | ✅ 新局开始 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| MORNING_BRIEFING | ✅ 退出主菜单 | — | ✅ 简报完毕 | ❌ | ❌ | ❌ | ❌ | ❌ |
| ACTION_DAY | ❌ | ❌ | — | ✅ AP > 8 加班 | ✅ 8 AP 用完或玩家提早下班 | ❌ | ✅ 月末触发 | ✅ 即时 KO |
| ACTION_OVERTIME | ❌ | ❌ | ❌ | — | ✅ 加班 AP 用完 | ❌ | ✅ 月末触发 | ✅ 即时 KO |
| AFTER_WORK | ❌ | ❌ | ❌ | ❌ | — | ✅ 进入收尾 | ❌ | ❌ |
| DAILY_RECAP | ❌ | ✅ 次日开始 | ❌ | ❌ | ❌ | — | ✅ 月末触发 | ❌ |
| KPI_REVIEW | ❌ | ✅ KPI 达标新月 | ❌ | ❌ | ❌ | ❌ | — | ✅ KPI 不达标 |
| GAMEOVER | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **终态锁定**(Rule 11) |

**守门条件摘要**

| 转移 | 守门条件 |
|------|---------|
| 任何 → GAMEOVER | 无守门(P3 最高优先);Modal 不阻塞(Rule 13 例外一) |
| ACTION_DAY/OVERTIME → KPI_REVIEW | 当前 Action 动画完成 + `current_day >= days_in_month`(Rule 10) |
| KPI_REVIEW → MORNING_BRIEFING | `kpi_score >= kpi_threshold`(由 #16 回调) |
| KPI_REVIEW → GAMEOVER | `kpi_score < kpi_threshold` |
| GAMEOVER → 任何 | **永久禁止**(Rule 11) |
| 演出 sub-mode 被 skip | Input Rule 6 注册 + Save Rule 21 上限守门(Rule 12) |
| 任何 → 任何(MODAL_LOCKED) | 入 `_pending_transition` 队列等待 modal_dismissed,GAMEOVER + 月末 KPI 例外(Rule 13) |
| 启动期 `run_ended == true` | 强制路由至离职证明回放 → MAIN_MENU(Rule 11 R6 mitigation) |

---

### Interactions with Other Systems

7 跨系统契约(Owner 指定信号 emit 方,Subscriber 指定订阅方):

| # | 对端 GDD | 信号 / 调用 | 数据流向 | Owner / Subscriber |
|---|----------|------------|---------|-------------------|
| 1 | Save System | `soft_pause_requested` → Save Rule 19 debounced autosave;`_settings_debounce_timer` 500ms → Save Rule 14 合并写盘;GAMEOVER → Save archive + `meta.run_ended = true` 优先持久化 | `#6` emit → Save 订阅 | `#6` emit / Save 消费 |
| 2 | Audio Manager | `scene_state_changed(from, to)` → Audio Rule 6 per-sub-mode BGM/Ambient 切换;`soft_pause_requested` → Music fade / Ambient duck | `#6` emit → Audio 订阅(≤ 1 ms 主线程) | `#6` emit / Audio 消费 |
| 3 | Lighting & Visual State | `scene_state_changed(from, to)` → Lighting Rule 1 `CanvasModulate` 8 sub-mode 色值切换;`accumulation_event(type, delta_units)` → 累积 state 4 维度(game-time tick 离散驱动) | `#6` emit → Lighting 订阅(< 1 ms 主线程) | `#6` emit / Lighting 消费 |
| 4 | Localization Hooks | 启动序列 `inject_locale_payload(locale)` → Loc Rule 8 parse <100ms → emit `_mark_ready`;`locale_switch_locked` 演出边界契约(演出 time budget < 30 s,否则 Loc watchdog 强制 override,`locale_lock_watchdog_ms = 30000`) | `#6` → Loc payload 注入;Loc → `#6` `_mark_ready()` 回调 | `#6` 调度 / Loc 执行 |
| 5 | Input Handler | 演出 sub-mode 注册 / 注销 skippable token(Rule 12 / Input Rule 6);Modal stack 查询 `MODAL_LOCKED` 状态(Rule 13 / Input Rule 7);`request_soft_pause()` 接收 `act_pause` 触发 `soft_pause_requested`;启动期注入 `keymap_payload`(Input Rule 8) | 双向: `#6` → Input(register/unregister/payload) + Input → `#6`(modal status 查询 + act_pause emit) | `#6` 仲裁 / Input 执行 |
| 6 | KPI Review & Game Over UI (#16) | `KPI_REVIEW` sub-mode 进入时 `scene_state_changed` 触发 #16 展示结算;#16 结算完成后回调 `kpi_score` → `#6` 决策下一 sub-mode;`final_transition_duration_ms = 1500 ms` 上限守门(GAMEOVER 离职证明专用,KPI Review 演出时长 #16 单独锁) | `#6` emit → #16 展示;#16 回调 → `#6` 状态决策 | `#6` 仲裁 / #16 展示 |
| 7 | FrameTimeMonitor(`#6` 内部) | 每次 transition 帧前后 `Time.get_ticks_usec()` 测量(C-ENG-07);超 20ms `push_warning`;超 33.3ms `push_error`(Rule 8 R5 mitigation);仅 debug build | `#6` 内部自监控,Release build 完全剔除 | `#6` 全权 |

---

### 仲裁覆盖核对(本 Section C 守门 6 项 cross-system BLOCKING)

| 仲裁 # | BLOCKING 原文 | 落地 Rule |
|--------|--------------|-----------|
| 1 | 启动序列 5 系统调度 | Rule 4 + C-ENG-01/04/05 |
| 2 | `WM_FOCUS_OUT` 三方语义 | Rule 5 + C-ENG-03 |
| 3 | Pause game-time vs wall-clock | Rule 6 + C-ENG-02/07 |
| 4 | Settings 防抖单 timer | Rule 7 |
| 5 | 同帧主线程预算 | Rule 3 + Rule 8 + R2/R5 mitigation |
| 6 | 8 sub-mode enum 锁 + 转移矩阵 | Rule 2 + States and Transitions |

**跨 GDD 契约核对**: Save Rule 7/13/14/19/21/22 / Input Rule 6/7/8/Edge 9.1 / Audio Rule 5/6/8 / Loc Rule 5/8 / Lighting Rule 1/9 全部显式 cite,无悬空引用。

## Formulas

**N/A** —— Scene & Day Flow Controller 是 dispatch + 状态机系统,无独立 formula 需求。所有数学嵌于 Core Rules 与 Tuning Knobs:

| 数学性质 | 落地位置 | 备注 |
|---------|---------|------|
| 帧预算分摊(16.6 ms 总和约束) | Rule 3 表 | 不是 formula,是 budget allocation table |
| FrameTimeMonitor 阈值(20 ms warn / 33.3 ms error) | Rule 8 | 标量阈值比较,无变量 |
| Game-time 离散推进(`game_minutes_per_ap = 60`) | Rule 9 + Tuning Knobs | 整数事件驱动,无 delta 累加 |
| 月末触发(`current_day >= days_in_month`) | Rule 10 | 整数比较 |
| 启动序列时序(meta load + payload + watchdog) | Rule 4 + 时间线表 | 非 formula,是顺序约束 |
| Settings 防抖窗口(`meta_settings_debounce_ms = 500ms`) | Rule 7 | registry 注册常量 |
| Watchdog 上限(Audio 10s / Lighting 10s / Loc 30s) | Rule 4 + Rule 6 | registry 注册常量 |

**与 Save / Audio / Lighting 同质 — 4 个 dispatch / 状态机 / lifecycle 性质 GDD 共同的设计模式**(本游戏 KPI 数学 / 反向阈值数学留 #9 KPI System / #11 Action Card 系统主笔)。

**野心版 future revise 触发器**(若引入则需补 Section D):
- 难度自适应(KPI 阈值随 NPC 关系动态调整)→ 需 formula
- 时间倍速 / 倍率(违反 Pillar 1+5 红线,几乎不可能)→ 需 formula
- 多公司类型差异(国企 vs 大厂月度天数差异)→ 需 formula

均超出 MVP 范围,Section J Open Questions 不收。



## Edge Cases

32 edges across 10 categories,5 [RISK GUARD] R-SDF-1..5(系统性 / 跨 GDD / 玩家可触发)。

### Cat 1: Boundary — 边界值

**1.1**: 若 `current_day` 在 `ACTION_DAY` tick 时恰好等于 `days_in_month`(31 天月最后一天零 AP 剩余) → `#6` 立即 emit `action_lockout_started`,等待当前 Action 动画完成后 `request_transition(KPI_REVIEW)`;不允许加班 AP 消耗继续推进 `current_day`。
- Cite: Rule 10;Rule 2

**1.2**: 若 AP 消耗事件使 `current_day` 一次性跨过 `days_in_month`(假设某卡消耗 2 AP 令 day 从 30 跳 32) → `#6` 在推进后对 `current_day` 做 `>= days_in_month` 判断触发月末,不要求恰好等于;`current_day` 截断为 `days_in_month`,不向后系统暴露越界值。
- Cite: Rule 9;Rule 10

**1.3**: 若 `game_minutes_per_ap = 60` 配合 8 AP/天,`ACTION_OVERTIME` AP 耗尽后 sub-mode 转 `AFTER_WORK` 时钟显示 > 24:00 → `#6` 不校验 24 小时制溢出,时钟显示逻辑由 HUD(#13)负责;`#6` 仅维护 `total_minutes_today` 整数,HUD 自行 mod 换算。
- Cite: Rule 9;Overview NOT-1

### Cat 2: Lifecycle — 启动顺序异常

**2.1 [RISK GUARD R-SDF-1]**: 若某 Foundation 系统(如 `AudioManager`)在 `#6._ready()` 执行前因 Autoload 初始化顺序错误已发射 `_mark_ready` 信号 → `#6` 在 `_ready()` 中先检查 `audio_manager.is_ready` bool;若已为 true,跳过 `await` 直接继续;不会遗漏已发射的单次信号导致死锁。
- Cite: Rule 4 R1 mitigation;C-ENG-01

**2.2**: 若某 Foundation 系统 `_mark_ready()` 永不被调用(因 payload 注入失败或 Autoload 自身崩溃) → Audio/Lighting 两个 watchdog 各自独立触发,强制转 READY 并 `push_error`;`#6` 收到强制 READY 信号后继续启动序列;两 watchdog 同帧触发为 debug 噪声,互不依赖。
- Cite: Rule 4;registry `audio_loading_watchdog_ms = 10000`,`lighting_loading_watchdog_ms = 10000`

**2.3**: 若 Save meta load 因 HDD+AV 扫描超过 50ms 容忍上限 → `#6` 继续等待同步加载完成(Save AC-PERF-01 p99 实测 ceiling);启动序列不跳过 meta load;若超过 P5 5 秒总预算,FrameTimeMonitor 发 `push_error`,但流程不中断,不触发 watchdog escalation(meta load 无 watchdog,属"阻塞主线程"路径)。
- Cite: Rule 4;registry `autosave_perf_hard_ceiling_ms = 50ms`

### Cat 3: 状态机 Race — 同帧竞争

**3.1**: 若同一帧内 `request_transition(KPI_REVIEW)` 和 `request_transition(GAMEOVER)` 均被触发(如即时 KO 与月末同帧成立) → `GAMEOVER` 转移优先,丢弃 `KPI_REVIEW` 请求,`push_warning` 记录;`GAMEOVER` 无需经过 `KPI_REVIEW` 结算。
- Cite: Rule 11;Rule 13 例外一;转移矩阵 `任何 → GAMEOVER` 无守门

**3.2**: 若 `_pending_transition` 队列内有待处理请求(MODAL_LOCKED),同帧 `GAMEOVER` 触发 → `GAMEOVER` 跳过队列立即执行,队列清空,所有入队请求静默丢弃。
- Cite: Rule 11;Rule 13 例外一

**3.3**: 若同一帧 `request_transition(X)` 被调用两次(不同订阅者各自触发) → 第一次执行转移,第二次进入时若状态机已转移则被静默丢弃或 `push_warning`;状态机不可重复 emit 同 `from→to` 对。
- Cite: Rule 1;Rule 3 禁递归 dispatch

### Cat 4: Pause 边界

**4.1 [RISK GUARD R-SDF-4]**: 若玩家在 `SceneTree.paused = true` 期间触发 `GAMEOVER`(如后台 KPI 结算线程回调) → `#6` 自身 `PROCESS_MODE_ALWAYS` 保证 tick 继续;`GAMEOVER` 转移立即执行(Rule 11 最高优先);在执行前调用 `SceneTree.paused = false` 解除暂停,确保 1500ms 离职证明演出帧正常渲染;Save `meta.run_ended = true` 先于演出落盘(Rule 11 R6)。
- Cite: Rule 6;Rule 11;C-ENG-02

**4.2**: 若 `WM_WINDOW_FOCUS_OUT` 在 `MORNING_BRIEFING` 演出进行中触发 → `#6` emit `soft_pause_requested(source:"wm_focus_out")`;Loc 30s watchdog 计时挂起(Timer PAUSE_INHERIT);演出型 sub-mode 的 skippable token 维持注册;玩家 focus 回来后 `soft_resume_requested` 恢复 Loc watchdog 续算。
- Cite: Rule 5;Rule 6;Rule 12

**4.3**: 若 Settings 防抖 timer 在 `paused` 期间达到 500ms(worker thread 独立) → Settings 落盘照常执行(Save worker 走 wall-clock);内存表已立即生效;`paused` 状态不影响 Save autosave debounce worker。
- Cite: Rule 6;Rule 7;registry `meta_settings_debounce_ms = 500ms`

### Cat 5: Save Crash 恢复

**5.1 [RISK GUARD R-SDF-2]**: 若 `GAMEOVER` transition 启动后 1500ms 演出进行中游戏 crash → 重启后 `#6` 在 Save meta load 阶段检测 `meta.run_ended = true`(Rule 11 R6:原子写在演出前完成);强制路由至"离职证明回放 → Main Menu Archive",**禁止**恢复至任何 `ACTION_DAY` 路径;玩家无法利用 crash 续命。
- Cite: Rule 11 R6 mitigation;Save Rule 21;Pillar 3

**5.2**: 若 `meta.run_ended = true` 写盘本身失败(磁盘满 / IO 错误)而 `GAMEOVER` 转移已启动 → `#6` 检测写盘失败信号后:**不继续** 1500ms 演出;在当前 sub-mode 显示"存档失败"错误弹窗;下次启动因 `run_ended` 未写入,将尝试恢复正常存档;设计上接受"写盘失败导致意外续命"为不可避免的退化(磁盘 IO 错误是 OS 级不可控)。
- Cite: Rule 11;Save Rule 21

**5.3**: 若 crash 发生在 `KPI_REVIEW` 结算中段(#16 已展示但 `kpi_score` 回调未到达 `#6`) → 重启后 `meta.run_ended` 为 false,`#6` 路由至上次 sub-mode(`KPI_REVIEW`);需重新触发 #16 完整结算流程;#16 应从 Save snapshot 读取结算数据(#16 GDD 需约束 re-entry 路径)。
- Cite: Rule 11;Rule 4;Interaction #6

### Cat 6: 性能升级

**6.1 [RISK GUARD R-SDF-3]**: 若某下游订阅者在 `scene_state_changed` handler 内执行重负载(如全屏 PackedScene 实例化 ~50ms) → 同帧总时长超 33.3ms,FrameTimeMonitor 发 `push_error`;debug build CI `--verbose` 视为 test failure;根因必须 code review BLOCKING 修复(违反 R2 mitigation)。
- Cite: Rule 3 R2;Rule 8 R5;帧预算表

**6.2**: 若 `FrameTimeMonitor` 自身 `Time.get_ticks_usec()` 两次调用 overhead 在极低配 PC 上超 0.5ms → 因 `OS.is_debug_build()` 为 false 时监视器完全剔除(Rule 8),release 不受影响;debug build 的监视器开销视为可接受调试成本。
- Cite: Rule 8;C-ENG-07

### Cat 7: 跨系统 Race

**7.1**: 若 Audio + Lighting watchdog 在同帧同时触发(两系统 payload 同时卡死) → 两 watchdog 各自独立强制转 READY 并分别 `push_error`;同帧两条 `push_error` 是预期 debug 噪声(Rule 4 文档明确);`#6` 在收到两个强制 READY 后继续启动序列,不会因双 push_error 被 CI 阻塞(CI 仅阻塞 FrameTimeMonitor push_error,Rule 8)。
- Cite: Rule 4;registry watchdog 常量

**7.2**: 若 `soft_pause_requested` 到达时 Save 防抖 timer 尚有 300ms 未到期 → `WM_FOCUS_OUT` 触发 Save debounced autosave(Rule 5,Save Rule 19);两个 debounce 路径独立:Settings 防抖 timer(500ms,Rule 7)与 autosave debounce(Rule 19)不共享 timer,不重置对方计时。
- Cite: Rule 5;Rule 7;Interaction #1

**7.3**: 若 Loc `locale_switch_locked` 因 bug 永不清除(lock leak),演出持续超 30s → `locale_lock_watchdog_ms = 30000ms` 触发强制 flush 并 `push_error`;`#6` 收到 Loc 强制 override 通知后视为演出正常结束,继续 sub-mode 转移流程;不会因 Loc lock leak 导致游戏永久阻塞。
- Cite: Rule 4;Interaction #4;registry `locale_lock_watchdog_ms`

### Cat 8: Skippable / Modal 交互

**8.1 [RISK GUARD R-SDF-5]**: 若 `MORNING_BRIEFING` 结束时 `#6` 未调用 `InputHandler.unregister_skippable(token_id)` → Input skippable token 泄漏;后续 `ACTION_DAY` 中玩家按 `act_skip` 仍触发 `MORNING_BRIEFING` 的 `on_skip` 回调(空操作或错误路由);需在每个演出 sub-mode `on_exit()` 的 `@abstract` 实现中强制调用 unregister。
- Cite: Rule 12;Input Rule 6;C-ENG-09 `@abstract on_exit()`

**8.2**: 若 `MODAL_LOCKED` 激活期间月末 `KPI_REVIEW` 强制触发(Rule 13 例外二) → `#6` 强制 dismiss 当前 modal(emit `modal_dismissed` 驱动 Input 清栈),立即执行 `request_transition(KPI_REVIEW)`;modal 内未完成的玩家操作全部丢弃;已消耗的 AP 不回退(由 #11 Action Card own)。
- Cite: Rule 13 例外二;Rule 10;Pillar 1

**8.3**: 若玩家在 `GAMEOVER` 1500ms 锁定期间反复按 `act_skip` → Input skippable 的 `on_skip` 回调仅跳至最后 1 帧(transition 收尾),不截断 1500ms 演出;多次 `act_skip` 事件被 Input handler 幂等处理(已在最后 1 帧则后续 skip 无效);`#6` 不响应 GAMEOVER 期间任何 `request_transition()` 调用(Rule 11)。
- Cite: Rule 12;Rule 11;registry `final_transition_duration_ms = 1500ms`

### Cat 9: Engine Integration

**9.1**: 若 SDL3 gamepad 热插拔事件(`NOTIFICATION_WM_WINDOW_FOCUS_IN` 重入)与 `WM_WINDOW_FOCUS_OUT` 在同帧竞争 → `#6` 在 `_notification()` 内先处理 `FOCUS_OUT`,发 `soft_pause_requested`;gamepad 热插拔路由至 Input Handler(#2)独立处理;两路通知主线程同帧顺序执行,无并发风险(Godot 主线程单线程)。
- Cite: C-ENG-03;Rule 5

**9.2**: 若 `change_scene_to_packed()` 在 Godot 4.5 SceneTree 重构后性能基准劣化(同步 `change_scene_to_file()` 实测 80-200ms) → `ResourceLoader.load_threaded_request()` 预加载完成信号收到后再调用 `change_scene_to_packed()`;实测基准由 OQ-SDF-ENG-02 延 ADR 确认;若基准超 P5 5 秒预算,降级方案为主菜单直接保留 Loading Scene 节点而非 `change_scene_to_packed()` 切换。
- Cite: C-ENG-05;Rule 4;OQ-SDF-ENG-02

**9.3**: 若 `@abstract` 某具体状态类(如 `MainMenuState`)漏实现 `on_exit()` → Godot 4.5+ 编辑器实例化报错阻塞;运行时 `BaseSubModeState.on_exit()` 触发 `@abstract` 运行时报错;防止 sub-mode 转移时 skippable 未注销 leak(Cat 8.1 的底层防护)。
- Cite: C-ENG-09;Rule 12

### Cat 10: Tone & 玩家意图

**10.1**: 若玩家强制 Alt+F4 终止进程(非 `WM_CLOSE_REQUEST`),且此前 `meta.run_ended` 尚未写盘 → 重启后 `run_ended = false`,`#6` 路由至正常存档恢复;玩家通过 Alt+F4 实现"续命"的可能性依赖:GAMEOVER 演出启动前 `meta.run_ended = true` 已原子落盘(Rule 11 R6 mitigation);只要 Save 落盘在演出前完成,Alt+F4 续命路径关闭。
- Cite: Rule 11 R6 mitigation;Save Rule 21;Pillar 3

**10.2**: 若玩家修改系统时钟(wall-clock)试图欺骗 `Time.get_ticks_msec()` watchdog → `Time.get_ticks_msec()` 返回系统启动以来 monotonic 毫秒数,不受用户调整系统时钟影响(Godot API 语义);watchdog 超时判断不可被玩家时钟改操控;game-time 由离散 AP 事件驱动(Rule 9),与 wall-clock 完全解耦。
- Cite: C-ENG-07;Rule 9

**10.3**: 若玩家在 `DAILY_RECAP` 跳过演出后立刻再次按 `act_skip`(连按) → `InputHandler` 的 skippable token 已在第一次 skip 完成后被 `#6` 注销(Rule 12 unregister on exit);第二次按键无 skippable token 响应,走正常 Input 处理(无副作用);防止连按穿透至下一 sub-mode 的 skippable 注册窗口。
- Cite: Rule 12;Input Rule 6

---

**5 [RISK GUARD] 守门点汇总**:
| ID | 守 Pillar | mitigation 类型 | Section H AC 守门 |
|----|----------|----------------|---------------------|
| R-SDF-1 | P5 5 秒进入 | Autoload init bool 检查(Rule 4) | AC-ROBUST-01 |
| R-SDF-2 | P3 不可逆 | meta.run_ended 优先持久化(Rule 11 R6) | AC-ROBUST-02 |
| R-SDF-3 | P5 帧率 | subscriber handler 轻量(Rule 3 R2) | AC-ROBUST-03 |
| R-SDF-4 | P5 / 玩家信任 | Pause 期 game-time 冻结(Rule 6) | AC-ROBUST-04 |
| R-SDF-5 | P4 tone 守 | skippable on_exit 强制 unregister(Rule 12 + C-ENG-09) | AC-ROBUST-05 |

**跨 GDD 新实体/常量说明**: 以上 Edge Cases 引用的常量均已在 `design/registry/entities.yaml` 注册。无新增跨系统实体。

## Dependencies

### Upstream Dependencies

**None (Core Layer 心跳节拍器,无上游)**。Scene & Day Flow Controller 是全游戏 dispatch 总线 owner,5 Foundation 系统(Save / Input / Localization / Audio / Lighting)在依赖图上是 **被 #6 调度的 / 被 #6 仲裁的** 关系,而非传统"上游"。其交互通过 Section C Interactions 表 7 个契约定义。

### Soft Dependencies(双向 — `#6` 调度 + Foundation emit 反馈)

| GDD | 关系 | `#6` 提供 | Foundation emit 给 `#6` |
|-----|------|----------|-------------------------|
| Save System (#1) | 双向 contract | Settings 防抖 single timer + GAMEOVER archive 触发 + `meta.run_ended` 优先持久化 | `meta_loaded` 信号 + `autosave_completed` |
| Input Handler (#2) | 双向 contract | skippable token 注册/注销 + modal_dismissed 强制 + keymap_payload 注入 | `act_pause` / `act_skip` / `keymap_changed` / `MODAL_LOCKED` 状态查询响应 |
| Localization Hooks (#3) | 双向 contract | locale payload 注入 + `locale_switch_locked` 30s 演出契约 | `_mark_ready` + `locale_changed` + `locale_switch_unlocked` |
| Audio Manager (#4) | 双向 contract | `scene_state_changed` 8 sub-mode dispatch + `soft_pause_requested` | `_mark_ready` + `bus_volume_changed` |
| Lighting & Visual State (#5) | 双向 contract | `scene_state_changed` 8 sub-mode dispatch + `accumulation_event(type, delta_units)` game-time tick + accumulation_state payload 注入 | `_mark_ready` |

**双向一致性 cross-check**:

| 5 Foundation GDD 内反向声明 | 本 GDD Section C Rule | 一致性 |
|----------------------------|----------------------|--------|
| Save Rule 14 referenced_by 含 #6 (Settings single timer 消费者) | Rule 7 + Interaction #1 | ✓ |
| Save Rule 19 `WM_FOCUS_OUT` debounced autosave | Rule 5 + Interaction #1 | ✓ |
| Save Rule 21 `final_transition_duration_ms = 1500ms` 离职证明 | Rule 11 R6 + Rule 12 + Interaction #6 | ✓ |
| Input Rule 6 skippable register/unregister API | Rule 12 + Interaction #5 | ✓ |
| Input Rule 7 MODAL_LOCKED stack | Rule 13 + Interaction #5 | ✓ |
| Input Rule 8 keymap_payload 启动注入 | Rule 4 + Interaction #5 | ✓ |
| Input Edge 9.1 `WM_FOCUS_OUT` reset_all_action_presses | Rule 5 表 | ✓ |
| Audio Rule 5 preload ≤ 200ms LOADING 守门 | Rule 4 启动序列 + registry `audio_preload_budget_ms = 200` | ✓ |
| Audio Rule 6 8 sub-mode 表 | Section A 8 sub-mode enum + Rule 2 | ✓ (W-CONS-2 待 Audio GDD 补 enum 列) |
| Audio Rule 7 BGM 演出时长 ≤ 120s | registry `bgm_loop_length_max_sec = 120` 引用 | ✓ |
| Audio Rule 8 dispatch ≤ 1 帧 | Rule 3 帧预算 ≤ 1ms | ✓ |
| Lighting Rule 1 LOADING/READY + 8 sub-mode CanvasModulate | Section A 8 sub-mode enum + Rule 4 + Rule 6 | ✓ |
| Lighting Rule 5 累积 state 4 维度 + game-time 驱动 | Rule 6 + Rule 9 + Interaction #3 | ✓ |
| Lighting Rule 9 `pause_tween()` 即时停 | Rule 5 表 | ✓ |
| Loc Rule 5 dispatch ≤ 1 帧 + 30s watchdog | Rule 4 启动序列 + registry `locale_lock_watchdog_ms = 30000` | ✓ |
| Loc Rule 8 启动 parse < 100ms | Rule 4 启动序列 | ✓ |

### Downstream Dependents(13 系统,本 GDD 接口被消费)

| # | System | 依赖性质 | 主要接口 |
|---|--------|---------|---------|
| 7 | AP Economy System | Hard | `ap_consumed(amount)` 信号 emit 给 `#6`(Rule 9 game-time tick 驱动);`scene_state_changed` 订阅(`ACTION_DAY` / `ACTION_OVERTIME` / `AFTER_WORK` 边界) |
| 8 | NPC Relationship System | Soft | `scene_state_changed(MORNING_BRIEFING)` 订阅(早晨事件触发) |
| 9 | KPI & Reverse Threshold System ⭐ | Hard | `scene_state_changed(KPI_REVIEW)` 订阅;月末 `kpi_score` 回调给 `#6` 决策 GAMEOVER vs 新月(Rule 10) |
| 10 | Event Script Engine ⭐ | Hard | `scene_state_changed` 全 8 sub-mode 订阅(剧本时机触发);`accumulation_event` 订阅(累积 state 触发条件) |
| 11 | Action Card System | Hard | `scene_state_changed(ACTION_DAY/OVERTIME)` 订阅;emit `ap_consumed` 给 `#6`;`action_lockout_started` 订阅(月末禁入队) |
| 12 | Run Meta System | Hard | `scene_state_changed(GAMEOVER)` 订阅;Run 摘要 ←  `meta.run_ended` + `meta.end_reason` |
| 13 | HUD System (Diegetic) | Hard | `scene_state_changed` 全 8 sub-mode 订阅(HUD 时钟 / 日历 / sub-mode 视觉切换);`accumulation_event` 订阅(diegetic UI 累积视觉 fallback) |
| 14 | Card Play & Dialogue UI | Soft | `scene_state_changed` 订阅(`ACTION_DAY` 进入卡 UI 默认态) |
| 15 | Daily / Weekly Recap UI | Hard | `scene_state_changed(DAILY_RECAP)` 订阅;skippable token 由 `#6` 注册 |
| 16 | KPI Review & Game Over UI | Hard | `scene_state_changed(KPI_REVIEW / GAMEOVER)` 订阅;`final_transition_duration_ms = 1500ms` 守门;skippable token 由 `#6` 注册;`kpi_score` 回调 |
| 17 | Main Menu / Pause / Settings UI | Hard | `scene_state_changed(MAIN_MENU)` 订阅;`request_soft_pause("settings_open")` 调用(Rule 5 R3 mitigation —— SceneTree.paused 调用权独属 `#6`);Settings 改后 emit `bus_volume_changed` / `locale_changed` / `keymap_changed` 触发 Rule 7 single timer |
| 18 | Tutorial / Onboarding System (VS) | Hard | `scene_state_changed` 全 8 sub-mode 订阅(教学时机)+ `accumulation_event` 订阅 |
| 19 | Notification & Warning System (VS) | Hard | `scene_state_changed` 订阅(月末预警 sub-mode 边界) |
| 20 | Accessibility Options (Alpha) | Soft | 通过 #17 Settings UI 间接订阅(Settings 信号合流) |

### 7 条未设计 GDD propagation 要求

任何下游 GDD 撰写时**必须**遵守:

1. **`scene_state_changed` 订阅 handler 必须轻量** — 仅状态登记,重负载 `call_deferred()` 或 WorkerThreadPool(Rule 3 R2)
2. **禁止下游自调 `request_transition()`** — sub-mode 转移由 `#6` 单点 dispatch(Rule 14 主语翻转)
3. **演出型 sub-mode 须经 `#6` 注册 skippable token** — 下游不直接调 `InputHandler.register_skippable()`(Rule 12)
4. **8 sub-mode enum 字面值必须使用** `MAIN_MENU` / `MORNING_BRIEFING` / `ACTION_DAY` / `ACTION_OVERTIME` / `AFTER_WORK` / `DAILY_RECAP` / `KPI_REVIEW` / `GAMEOVER`,禁字符串替代(Rule 2)
5. **`accumulation_event(type, delta_units)` 必须接受 `delta_units: int`(离散整数事件驱动)** — 禁 delta float 累加(Rule 9 R4)
6. **任何"暂停"语义必须经 `#6.request_soft_pause()`** — 禁直接 `SceneTree.paused = true`(Rule 5 R3)
7. **任何下游显式 `WM_FOCUS_OUT` 响应** 必须订阅 `#6.soft_pause_requested` 信号 — 不得自行订阅 `NOTIFICATION_WM_WINDOW_FOCUS_OUT`(Rule 5,Audio + Lighting + Save + Input 已就位,后续 GDD 撰写必查)

### 6 条跨 GDD revise 影响清单

本 GDD 锁定后,若任一下列条目修订,须 propagate 至 #6:

1. Save Rule 14 防抖窗口值变更 → Rule 7 single timer 值同步
2. Save Rule 21 `final_transition_duration_ms` 值变更 → Rule 12 + Interaction #6 同步
3. Input Rule 6/7 skippable / modal stack 协议变更 → Rule 12 + Rule 13 同步
4. Audio Rule 5 preload budget 值变更 → Rule 4 启动序列时间线同步
5. Lighting Rule 5 累积 state 维度变更 → Rule 9 + Interaction #3 同步
6. Loc Rule 5 dispatch ≤ 1 帧 / watchdog 30s 协议变更 → Rule 4 + Interaction #4 同步

### Registry referenced_by 应增更新(Phase 5b)

本 GDD 须 add 至以下 6 constants 的 `referenced_by`:
- `meta_settings_debounce_ms` (Save source) — `#6` Rule 7 single timer 消费者
- `final_transition_duration_ms` (Save source) — `#6` Rule 12 守门 + Interaction #6
- `locale_lock_watchdog_ms` (Loc source) — `#6` Rule 4 / Interaction #4 演出契约消费者
- `audio_loading_watchdog_ms` (Audio source) — `#6` Rule 4 启动 watchdog 调度方
- `lighting_loading_watchdog_ms` (Lighting source) — `#6` Rule 4 启动 watchdog 调度方
- `audio_preload_budget_ms` (Audio source) — `#6` Rule 4 启动序列时间线消费者
- `bgm_loop_length_max_sec` (Audio source) — `#6` Rule 12 + Interaction #6 演出契约消费者(若 KPI Review BGM loop 续接)
- `notice_board_max_entries` (Lighting source) — `#6` Interaction #3 累积 state delta_units 通过 game-time tick 间接驱动 board age 计数

(Phase 5b registry scan 时全部更新 referenced_by 列表,无新 constant 注册需求 — 本 GDD 自身没有跨系统 magic number,所有 magic numbers 在 Tuning Knobs Section G 内部声明。)

## Tuning Knobs

### Internal Numeric Knobs(本 GDD own,不进 registry)

本 GDD 自身没有跨系统 magic number,以下 knob 仅在 `#6` Autoload 内部声明,下游 GDD 不直接引用:

| Knob | 默认值 | 单位 | 安全范围 | 影响 / 行为 | Cite |
|------|-------|------|---------|------------|------|
| `game_minutes_per_ap` | 60 | min/AP | 30-120 | AP 消耗推进 game-time 步长。值小则 24 小时一天容纳更多 AP(打破 P5 节奏稳定);值大则下班时刻飘移 | Rule 9 |
| `days_in_month_default` | 30 | days | 28-31 | 月度天数(MVP 暂用固定 30,VS 起按真实日历 28/30/31 切换);月末触发 `current_day >= days_in_month`(Rule 10) | Rule 10 |
| `framebudget_warn_ms` | 20 | ms | 16.6-25 | FrameTimeMonitor warning 阈值;低于 16.6 触发误报,高于 25 ms 失去 P5 帧率守护意义。仅 debug build | Rule 8 R5 |
| `framebudget_error_ms` | 33.3 | ms | 33-50 | FrameTimeMonitor critical 阈值(2 帧);CI test failure 门槛。仅 debug build | Rule 8 R5 |
| `pending_transition_queue_size` | 1 | int | 1-3 | `_pending_transition` 队列大小(LIFO);MVP 仅保留最新请求避免 modal 套娃 leak | Rule 13 |
| `mark_ready_timeout_grace_ms` | 500 | ms | 0-1000 | `_mark_ready` await 容忍 Foundation 系统 emit 信号略晚于 `is_ready` bool 设值的 race 时间窗 | Rule 4 R1 |
| `act_skip_idempotent_cooldown_ms` | 100 | ms | 0-500 | 玩家连按 `act_skip` 的去抖窗口(Edge 8.3 + 10.3 防穿透至下一 sub-mode skippable 注册期)| Rule 12 + Edge 10.3 |

### Cross-GDD Reference Knobs(本 GDD 消费,registry 已注册,不重复定义)

| Knob | Source GDD | Value | 在 #6 中的引用位置 |
|------|-----------|-------|-------------------|
| `meta_settings_debounce_ms` | save-system.md (Rule 14) | 500 ms | Rule 7 single timer 周期 |
| `final_transition_duration_ms` | save-system.md (Rule 21) | 1500 ms | Rule 12 GAMEOVER 离职证明 skip 守门 |
| `locale_lock_watchdog_ms` | localization-hooks.md (Rule 5) | 30000 ms | Rule 4 启动序列契约 + Interaction #4 演出 budget contract |
| `audio_loading_watchdog_ms` | audio-manager.md (Rule 5 / Edge 3.5) | 10000 ms | Rule 4 启动序列 watchdog 调度 |
| `lighting_loading_watchdog_ms` | lighting-visual-state.md (Rule 2) | 10000 ms | Rule 4 启动序列 watchdog 调度 |
| `audio_preload_budget_ms` | audio-manager.md (Rule 5) | 200 ms | Rule 4 启动序列时间线(并行 Loc < 100ms) |
| `bgm_loop_length_max_sec` | audio-manager.md (Rule 7) | 120 sec | Rule 12 + Interaction #6 演出时长上限契约 |
| `notice_board_max_entries` | lighting-visual-state.md (Rule 5) | 24 entries | Rule 9 game-time tick 驱动 month_age 累计的边界(2 年) |
| `autosave_perf_hard_ceiling_ms` | save-system.md | 50 ms | Rule 4 启动序列 meta load HDD+AV 容忍上限 |

### 启动序列时间预算分摊表(Rule 4 + P5 5 秒进入承诺)

| 阶段 | 预算上限 | 实际预期 | 缓冲 |
|------|---------|---------|------|
| Splash → Loading Scene 实例化 | 100 ms | ~50 ms | 50 ms |
| Save meta load(同步,阻塞主线程) | 50 ms (HDD+AV ceiling) | ~10 ms (SSD 正常) | 40 ms |
| Loc parse + Audio preload(并行) | 200 ms (audio_preload_budget_ms) | ~150 ms | 50 ms |
| Lighting accumulation_state load + Input keymap_payload(并行) | 50 ms | ~20 ms | 30 ms |
| 4 系统 `_mark_ready` 信号到达 | 100 ms | ~50 ms | 50 ms |
| `change_scene_to_packed(MainMenu)` | 200 ms (C-ENG-05 预加载后) | ~100 ms | 100 ms |
| `MAIN_MENU` 首帧渲染 | 16.6 ms (1 帧) | ~16 ms | — |
| **合计 P5 5000 ms 预算** | ~720 ms 必要 | ~400 ms 预期 | **~4280 ms 富余给 watchdog escalation** |

watchdog 触发场景(10 s Audio / 10 s Lighting / 30 s Loc 演出锁不在启动期)在 4.28 秒缓冲区被吸收;若任一 watchdog 触发,5 秒承诺保留(强制 READY + push_error 后继续启动,不阻塞)。

### Sub-Mode Time Budget 表(Rule 9 + Interaction #6)

各 sub-mode 内部停留时长上限(玩家驱动型无上限,演出型受 Pillar 5 守):

| Sub-Mode | 类型 | 时长 | 守门约束 |
|----------|------|------|---------|
| `MAIN_MENU` | 玩家驻留 | 无上限 | Pause skippable;Settings 入口;Archive 入口 |
| `MORNING_BRIEFING` | 演出 | < 30 s | skippable 注册;`locale_lock_watchdog_ms = 30000ms` 共享上限;超 30s 触发 Loc watchdog 强制 override |
| `ACTION_DAY` | 玩家驱动 | 玩家 8 AP 消耗驱动,无 wall-clock 上限 | `_settings_debounce_timer` 与 autosave 并行运行 |
| `ACTION_OVERTIME` | 玩家驱动 | 加班 AP 消耗驱动 | 同 ACTION_DAY |
| `AFTER_WORK` | 演出 | < 60 s | skippable;P5 节奏守 |
| `DAILY_RECAP` | 演出 | < 90 s | skippable;数据屏蓝光 sub-mode + Localization GAMEOVER 反讽 key 不在此(此处用 `RECAP.SUMMARY.*`) |
| `KPI_REVIEW` | 演出 | < 120 s | skippable;受 `bgm_loop_length_max_sec = 120s` BGM 自然 loop 续接守门;`kpi_review_transition_duration_ms` 候选 knob 由 #16 GDD 锁(本 GDD OQ-SDF-09) |
| `GAMEOVER` | 演出 | 1500 ms 锁 | `final_transition_duration_ms = 1500ms`(Save Rule 21);Pillar 4 离职证明 tone 不可推翻 |

### 跨平台与玩家偏好 Knobs(留 Section J Open Questions)

- 加班 AP 上限(`overtime_ap_max`)是 #7 AP Economy own,不是 `#6`
- "叙事密度"(短/中/长 sub-mode 演出)是 game-concept 提到的 Pillar 5 mitigation 选项,#16 + #15 GDD 各自 own;`#6` 不直接读此设置(下游订阅者自行响应)

### Scope Tier Awareness

| Tier | knob 集合 |
|------|----------|
| **MVP** | 全 7 internal knobs + 9 cross-GDD reference + 启动 budget 表 |
| **VS** | 月份天数动态化(28/30/31 + 闰年 2 月);可能新增 `weekend_ap_skip` knob(周末 AP 跳过) |
| **Full Vision** | 多公司类型差异(国企 / 大厂月度天数 / 加班文化差异)→ 触发 Section D Formulas 重启 |
| **野心版** | 难度自适应、时间倍速 — 几乎不可能(违反 Pillar 1+5 红线) |

## Visual/Audio Requirements

### 零 Asset Ownership

Scene & Day Flow Controller **不直接 own 任何 visual / audio asset**。所有 sub-mode 视听表达由 Audio Manager (#4) + Lighting Controller (#5) 各自 own,#6 仅作为 dispatch 总线 emit `scene_state_changed(from, to)` + `accumulation_event(type, delta_units)` + `soft_pause_requested(source)` 信号供其订阅。

| Asset 类型 | Owner GDD | #6 角色 |
|-----------|----------|---------|
| 8 sub-mode BGM / SFX / Ambient | audio-manager.md | 仅 emit `scene_state_changed` 信号触发 |
| 8 sub-mode CanvasModulate / palette / dither | lighting-visual-state.md | 仅 emit `scene_state_changed` 信号触发 |
| GAMEOVER 离职证明视觉 | lighting-visual-state.md (KPI_REVIEW + GAMEOVER sub-mode) | 仅 dispatch + 守 1500ms 时长契约 |
| GAMEOVER stinger / KPI BGM | audio-manager.md (KPIREVIEW + GAMEOVER) | 仅 dispatch |

### 跨系统视听 dispatch 契约(本 GDD 守门)

- **8 sub-mode enum 1:1 映射**: Audio Rule 6 表 + Lighting Rule 1 表必须使用 Section A enum 字面值(本 GDD source of truth)
- **`scene_state_changed` 同帧主线程预算**: Rule 3 表分摊;Audio ≤ 1ms / Lighting < 1ms 守门
- **演出时长上限**: KPI Review < 120s(`bgm_loop_length_max_sec`)+ GAMEOVER 1500ms(`final_transition_duration_ms`)守门
- **soft_pause_requested 三轨响应**: Audio fade / Lighting pause_tween / Save autosave debounce 三方语义独立(Rule 5 表)
- **三轨 negative space 铁三角(Pillar 4)**: 月末 KPI Review 时三系统同时拒绝庆祝(Audio 月末打卡机 + Lighting KPI 紫静止 + Localization GAMEOVER.TITLE_IRONY 反讽),由 #6 dispatch `scene_state_changed(KPI_REVIEW)` 同帧触发

### 📌 Asset Spec Flag

本 GDD 不需要 `/asset-spec` — 零 visual/audio ownership。所有 asset spec 由 Audio + Lighting GDD 各自 `/asset-spec system:audio-manager` + `/asset-spec system:lighting-visual-state` 产出。

## UI Requirements

### 零 UI Screen Ownership

Scene & Day Flow Controller **不直接 own 任何 UI screen**。所有玩家可见 UI 由 #13 HUD / #14 Card Play / #15 Recap / #16 KPI Review / #17 Main Menu 各自 own。本 GDD 仅作为这些 UI 的 backend dispatch 信号 owner。

### Backend Dispatch 契约(下游 UI GDD 撰写时必查)

| UI GDD | 订阅信号 | 备注 |
|--------|---------|------|
| #13 HUD Diegetic | `scene_state_changed` 全 8 sub-mode + `accumulation_event` + diegetic 时钟显示(`total_minutes_today` 整数) | HUD 是 sub-mode 视觉切换的 *最高频* 订阅者,主线程 budget ≤ 2ms |
| #14 Card Play UI | `scene_state_changed(ACTION_DAY/OVERTIME)` 进入卡 UI 默认态;`MODAL_LOCKED` 状态时阻塞新卡入队 | |
| #15 Daily/Weekly Recap UI | `scene_state_changed(DAILY_RECAP)`;skippable token 由 #6 注册;退出时 `unregister_skippable` | |
| #16 KPI Review & Game Over UI | `scene_state_changed(KPI_REVIEW / GAMEOVER)`;skippable token 由 #6 注册;`final_transition_duration_ms = 1500ms` 守门;`kpi_score` 回调 #6 决策 GAMEOVER vs 新月 | KPI Review 演出时长 < 120s 由 #16 单独锁(候选 `kpi_review_transition_duration_ms`,本 GDD OQ-SDF-09) |
| #17 Main Menu / Pause / Settings UI | `scene_state_changed(MAIN_MENU)`;`request_soft_pause("settings_open")` 调用;Settings 改后 emit Settings 信号触发 #6 Rule 7 single timer | Settings 子屏与 Loc + Audio 共用 `design/ux/settings-screen.md`;Pause 子屏唯一调用 `request_soft_pause` API 的 UI(R3 mitigation) |

### 📌 UX Flag — Phase 4 必跑

Phase 4 Pre-Production 阶段须为以下 4 屏跑 `/ux-design`:
- `design/ux/main-menu.md`(配 #17,启动后第一屏)
- `design/ux/pause-screen.md`(配 #17,所有 sub-mode 共用 `act_pause` 入口)
- `design/ux/loading-screen.md`(启动序列 `MAIN_MENU` 之前的 splash + watchdog 进度反馈)
- `design/ux/gameover-screen.md`(配 #16,1500ms 离职证明 transition + Main Menu Archive 入口)

`design/ux/settings-screen.md`(配 #17,音量 + 语言 + 键位 + 叙事密度) **已有跨 GDD 引用**,本 GDD 不再重复引用 — Loc + Audio 已分别打 UX Flag。

**禁** `/ux-design` 涉及 sub-mode 切换的具体演出细节 — 那是 #13 HUD + #15 Recap UI + #16 KPI Review UI 各自 GDD 的责任。本 GDD 仅守 backend dispatch 契约。

## Acceptance Criteria

27 AC / 5 categories(AC-FUNC 8 / AC-PERF 4 / AC-COMPAT 5 / AC-ROBUST 5 / AC-TONE 5)。5 [RISK GUARD] R-SDF-1..5 全对应 AC-ROBUST-01..05。

### AC-FUNC — 功能行为验证

**AC-FUNC-01** `MVP`
**GIVEN** `SceneDayFlowController` Autoload 已挂载,其他 4 Foundation 单例在 `[autoload]` 列表中先于 `#6` 声明
**WHEN** 游戏冷启动,`#6._ready()` 执行
**THEN** `#6` 必须是列表末位单例,调用 `audio_manager.is_ready` / `lighting_controller.is_ready` / `localization_manager.is_ready` / `input_manager.is_ready` bool 检查全通过,或 `await` 对应 `_mark_ready` 信号,且**不**在 `_init()` 内调用任何跨单例方法
*Cite: Rule 4 R1 / C-ENG-01*

**AC-FUNC-02** `MVP`
**GIVEN** 状态机当前处于 `ACTION_DAY`
**WHEN** `ap_consumed(amount)` 信号累计使 `current_day >= days_in_month`
**THEN** `#6` 依次:emit `action_lockout_started` → 等待当前 Action 动画完成 → `request_transition(KPI_REVIEW)`,不在动画完成前提前转移;任何下游 `request_transition()` 调用在此期间被 `_pending_transition` 队列缓冲
*Cite: Rule 10 / Rule 13*

**AC-FUNC-03** `MVP`
**GIVEN** 状态机处于 `KPI_REVIEW`
**WHEN** #16 KPI Review 回调 `kpi_score` 值
**THEN** 分支 A `kpi_score >= kpi_threshold` → 转移至 `MORNING_BRIEFING`;分支 B `kpi_score < kpi_threshold` → 转移至 `GAMEOVER`;两分支互斥,转移矩阵禁止的路径(如 `KPI_REVIEW → ACTION_DAY`)被静默丢弃 + `push_warning`
*Cite: Rule 10 / Rule 11 / States-Transitions 矩阵*

**AC-FUNC-04** `MVP`
**GIVEN** 状态机处于 `ACTION_DAY` 且 `MODAL_LOCKED = true`
**WHEN** 月末条件满足,Rule 13 例外二触发
**THEN** `#6` 强制 emit `modal_dismissed` 驱动 Input 清栈,立即执行 `request_transition(KPI_REVIEW)`;modal 内未完成操作全丢弃;AP 不回退;`_pending_transition` 队列清空
*Cite: Rule 13 例外二 / Rule 10 / Edge 8.2*

**AC-FUNC-05** `MVP`
**GIVEN** `WM_WINDOW_FOCUS_OUT` 通知在任意 sub-mode 抵达主线程
**WHEN** `#6._notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)` 回调
**THEN** `#6` 同帧同步 emit `soft_pause_requested(source:"wm_focus_out")`;Save 收到后 debounced autosave 启动;Audio fade 启动;Lighting `pause_tween()` 调用;Input `reset_all_action_presses()` 执行;不经 `call_deferred()` 延迟
*Cite: Rule 5 / C-ENG-03 / Edge 9.1*

**AC-FUNC-06** `MVP`
**GIVEN** `MORNING_BRIEFING` / `DAILY_RECAP` / `KPI_REVIEW` 任一演出 sub-mode 进入
**WHEN** `#6` 执行 `on_enter()`
**THEN** `InputHandler.register_skippable(token_id, on_skip_callable)` 必须被调用;退出该 sub-mode `on_exit()` 时 `InputHandler.unregister_skippable(token_id)` 必须被调用;token_id 在两次调用中匹配。`_force_dispatch` debug 钩子手动触发验证
*Cite: Rule 12 / C-ENG-09 / Edge 8.1*

**AC-FUNC-07** `MVP`
**GIVEN** 所有 settings 信号(`bus_volume_changed` / `locale_changed` / `keymap_changed`)在同一帧内三次触发
**WHEN** `_settings_debounce_timer` 监听
**THEN** `#6` 内部 timer 被每次信号重置,最终只在末次信号到达后 500ms 合并单次落盘;期间 AudioBus / TranslationServer / InputMap 内存表立即生效;不产生 3 次独立写盘
*Cite: Rule 7 / Knob `meta_settings_debounce_ms = 500ms`*

**AC-FUNC-08** `MVP`
**GIVEN** 状态机处于 `ACTION_DAY` / `ACTION_OVERTIME`,game-time tick 由 `ap_consumed` 离散驱动
**WHEN** `game_minutes_per_ap = 60`,玩家打出 1 张 Action 卡
**THEN** `#6` 推进 `total_minutes_today += 60`;不使用 `_process(delta)` 浮点累加;60fps 与 144fps 下 `current_day` 计算结果完全一致;`MAIN_MENU` / `MORNING_BRIEFING` / `DAILY_RECAP` / `KPI_REVIEW` / `GAMEOVER` 期间 tick 不累加
*Cite: Rule 9 / Edge 1.2*

### AC-PERF — 性能与帧预算

**AC-PERF-01** `MVP`
**GIVEN** 测试 PC SSD 标准配置
**WHEN** 游戏冷启动至 `MAIN_MENU` 首帧渲染完成
**THEN** 端到端耗时 ≤ 5000ms(P5 5 秒进入承诺);`Time.get_ticks_msec()` 时钟桩记录 T+0ms Splash 与 T+end 首帧时间戳;回归 10 次取 p95
*Cite: Rule 4 / Pillar P5 / Knob 启动预算表*

**AC-PERF-02** `MVP`
**GIVEN** debug build,`FrameTimeMonitor` 激活
**WHEN** `_force_dispatch` 钩子触发 `scene_state_changed` 从 `ACTION_DAY → AFTER_WORK`
**THEN** 同帧主线程总耗时 ≤ 16.6ms;Audio handler ≤ 1ms,Lighting handler < 1ms,Save snapshot dispatch ≤ 4ms;超 20ms `push_warning`,超 33.3ms `push_error`(CI `--verbose` 视为 failure)
*Cite: Rule 3 / Rule 8 R5 / Edge 6.1*

**AC-PERF-03** `MVP`
**GIVEN** settings 信号高频触发(玩家快速滑动音量条)
**WHEN** 连续 10 次 `bus_volume_changed` 在 < 500ms 窗口到达
**THEN** `_settings_debounce_timer` 在最后一次信号后 500ms ± 50ms 单次触发落盘;不产生多次磁盘写入;内存表(AudioBus)每次信号后立即生效,不等待防抖
*Cite: Rule 7 / Knob `meta_settings_debounce_ms = 500ms` / Edge 4.3*

**AC-PERF-04** `Beta`
**GIVEN** release build(`OS.is_debug_build() = false`)
**WHEN** 运行任意 sub-mode 转移
**THEN** `FrameTimeMonitor` 代码完全剔除,`Time.get_ticks_usec()` 两次调用不出现;profiler 验证 `#6._process()` 开销相比 debug build 降低,无观察者效应残留
*Cite: Rule 8 R5 / Edge 6.2*

### AC-COMPAT — 跨系统双向契约一致性

**AC-COMPAT-01** `MVP`
**GIVEN** Save System 双向契约
**WHEN** `GAMEOVER` 转移发起
**THEN** Save 在演出启动**之前**原子写 `meta.run_ended = true` + `meta.end_reason`;crash recovery fixture 在写盘完成后立即注入 OS 进程终止,重启验证 `#6` 强制路由至离职证明回放而非 `ACTION_DAY` 恢复
*Cite: Rule 11 R6 / Save Rule 21 / Interaction #1 / Edge 5.1*

**AC-COMPAT-02** `MVP`
**GIVEN** Input Handler 双向契约
**WHEN** `#6` 进入 `KPI_REVIEW` sub-mode 注册 skippable token,玩家按 `act_skip`
**THEN** `on_skip` 回调将演出推至最后 1 帧,**不**截断 `final_transition_duration_ms = 1500ms` 完整演出;连按 `act_skip` 幂等处理,后续 skip 无效;modal stack mock 验证 `MODAL_LOCKED` 查询接口正常
*Cite: Rule 12 / Rule 11 / Save Rule 21 / Edge 8.3*

**AC-COMPAT-03** `MVP`
**GIVEN** Audio Manager 双向契约
**WHEN** `scene_state_changed(ACTION_DAY, KPI_REVIEW)` emit
**THEN** Audio handler 主线程 dispatch ≤ 1ms(GUT performance lint);AudioServer BGM 切换为 `KPIREVIEW ENDGAME_LOOP`,不产生同帧同步 AudioStreamPlayer 阻塞;subscriber handler overhead lint test CI 覆盖
*Cite: Rule 3 / Interaction #2 / Audio Rule 6 / Rule 8*

**AC-COMPAT-04** `MVP`
**GIVEN** Localization Hooks 双向契约
**WHEN** `#6` 启动序列 `inject_locale_payload(locale)` 后
**THEN** Loc parse 完成 < 100ms;`_mark_ready()` 信号到达;若超时 `locale_lock_watchdog_ms = 30000ms` 强制 override + `push_error`;`#6` 继续启动不阻塞;Foundation 系统 ready 信号 mock 验证 watchdog escalation 路径
*Cite: Rule 4 / Interaction #4 / Loc Rule 8 / Edge 7.3*

**AC-COMPAT-05** `MVP`
**GIVEN** Lighting Controller 双向契约
**WHEN** `scene_state_changed(ACTION_DAY, KPI_REVIEW)` emit
**THEN** Lighting handler 主线程 dispatch < 1ms;CanvasModulate 切换至 KPI 紫 `#3A3050` 且 Tween 启动;`pause_tween()` 在 `soft_pause_requested` 到达后立即停止;Lighting 累积 state 在 `SceneTree.paused = true` 期间不累加(`accumulation_event` 离散推进暂停验证)
*Cite: Rule 3 / Rule 5 / Rule 6 / Interaction #3 / Lighting Rule 1/9*

### AC-ROBUST — 风险守门(直接对应 R-SDF-1..5)

**AC-ROBUST-01** `MVP` `R-SDF-1` 启动期 Autoload init race 死锁守门
**GIVEN** Foundation 系统 ready 信号 mock:模拟 `AudioManager._mark_ready` 在 `#6._ready()` 执行**之前**已 emit
**WHEN** `#6._ready()` 执行,检查 `audio_manager.is_ready == true`
**THEN** `#6` 跳过 `await` 直接继续启动序列;不产生 `await` 死锁;其余已 ready 系统同理;Autoload init order test fixture 验证 bool 检查先于 await 执行
*Cite: Rule 4 R1 / C-ENG-01 / Edge 2.1*

**AC-ROBUST-02** `MVP` `R-SDF-2` GAMEOVER transition 中段 crash 续命漏洞守门
**GIVEN** crash recovery fixture:注入 `meta.run_ended = true`,模拟 GAMEOVER 演出中崩溃后重启
**WHEN** `#6` 执行 Save meta load(Rule 4 启动序列)
**THEN** `#6` 检测 `run_ended == true` 后强制路由至"离职证明回放 → Main Menu Archive";**不**进入任何 `ACTION_DAY` 恢复路径;任何 `request_transition(ACTION_DAY)` 被静默丢弃 + `push_warning`
*Cite: Rule 11 R6 / Save Rule 21 / Edge 5.1 / Pillar P3*

**AC-ROBUST-03** `MVP` `R-SDF-3` `scene_state_changed` subscriber 不轻量违约守门
**GIVEN** subscriber handler overhead 性能 lint test;对每个 `scene_state_changed` 下游 subscriber handler 单独计时
**WHEN** handler 执行体含 `JSON.stringify(large_dict)` 或 `PackedScene.instantiate()` 重负载
**THEN** lint test 报告 handler 耗时 ≥ 2ms 为 BLOCKING;CI `--verbose` 视为 test failure;重负载必须 `call_deferred()` 或 WorkerThreadPool;`FrameTimeMonitor mock` 验证 `push_error` 在 > 33.3ms 时触发
*Cite: Rule 3 R2 / Rule 8 R5 / Edge 6.1*

**AC-ROBUST-04** `MVP` `R-SDF-4` Pause 期间 wall-clock vs game-time 漂移守门
**GIVEN** SceneTree pause 测试 fixture:`SceneTree.paused = true`
**WHEN** watchdog escalation 测试桩触发 `GAMEOVER` 转移
**THEN** `#6`(PROCESS_MODE_ALWAYS)tick 继续;`#6` 先调用 `SceneTree.paused = false` 再启动 1500ms 离职证明演出;Save `meta.run_ended = true` 落盘先于演出帧;Lighting 累积 state 在 pause 期间不累加(game-time 累加器冻结验证)
*Cite: Rule 6 / Rule 11 / C-ENG-02 / Edge 4.1*

**AC-ROBUST-05** `MVP` `R-SDF-5` Skippable 未注销 leak 守门
**GIVEN** `MORNING_BRIEFING` 完整生命周期测试
**WHEN** sub-mode `on_exit()` 执行完成(`_force_dispatch` 强制触发转移至 `ACTION_DAY`)
**THEN** `InputHandler.unregister_skippable(token_id)` 必须已被调用;modal stack mock 验证 `ACTION_DAY` 期间按 `act_skip` 无 skippable token 响应;`@abstract on_exit()` 缺失实现时 Godot 4.5+ 编辑器报错(C-ENG-09 底层防护)
*Cite: Rule 12 / C-ENG-09 / Edge 8.1 / Edge 10.3*

### AC-TONE — Pillar 4 叙事 tone 守门

**AC-TONE-01** `MVP` 主语翻转 lint
**GIVEN** CI lint 工具 `tools/subject_inversion_lint.py` 对 Localization CSV 全量 `TRANSITION.*` / `SCENE_STATE.*` / `GAMEOVER.*` key 扫描
**WHEN** 任意 key 文案包含主动语态触发词("完成 / 达成 / 进入 / 开始 / 你已 / 玩家")
**THEN** lint 报告 PR-blocking failure;反例 "完成 8 AP 后进入下班抉择" → blocking;正例 "8 AP 用完了,该下班了" → pass
*Cite: Rule 14 层 2 / Section B 主语翻转原则*

**AC-TONE-02** `MVP` GAMEOVER 1500ms 演出不可截断
**GIVEN** `GAMEOVER` sub-mode 进入,`final_transition_duration_ms = 1500ms` 演出锁激活
**WHEN** 玩家连续按 `act_skip`
**THEN** 演出不可截断,玩家最多推进至最后 1 帧;屏幕**不**显示"重试 / 复活 / 撤销"任何 prompt;GAMEOVER 屏唯一可操作项为"新局";离职证明灰度视觉保持至"新局"点击
*Cite: Rule 11 / Rule 12 / Save Rule 21 / Pillar P3 + P4*

**AC-TONE-03** `MVP` 月末 KPI 反讽锚守门
**GIVEN** `KPI_REVIEW` sub-mode 进入
**WHEN** 月末 KPI 结算结果为不达标(`kpi_score < kpi_threshold`)
**THEN** UI 文案或动画**不**出现"恭喜 / 胜利 / 优秀员工 / 挑战成功"任何词汇;`GAMEOVER.TITLE_IRONY` 或等效 Localization key 启用反讽文案(如"恭喜晋升");`subject_inversion_lint.py` 同步扫描此 key 主语方向 pass
*Cite: Rule 14 层 2 / Section B 副锚 Tone 守护 / Pillar P3 + P4 + 三轨铁三角*

**AC-TONE-04** `Beta` MORNING_BRIEFING tone 审校
**GIVEN** `MORNING_BRIEFING` 首帧叙事文案审校
**WHEN** writer 提交 Localization CSV 中 `MORNING_BRIEFING.*` key 的 PR
**THEN** 文案不含"崭新的一天 / 全新挑战 / 整装待发 / 开始游戏 / Loading... / 准备就绪";不含 9:00 整点仪式词;正例: "周一 9:17" 无动作主语 → pass;`subject_inversion_lint.py` + writer 人工审校双重把关
*Cite: Rule 14 / Section B 主锚 Tone 风险 / Pillar P4 + P1*

**AC-TONE-05** `Beta` 主语翻转 reviewer 签字
**GIVEN** `DAILY_RECAP` / `AFTER_WORK` sub-mode 文案审校
**WHEN** sub-mode 进入时 UI 显示任意过渡字幕
**THEN** 字幕主语为"时间"或无主语,不为"玩家动作"(Internal Design Test 主语翻转);所有 `scene_state_changed` 回调中传递的文案 key 仅为 Localization key(`tr(key)`) 引用,`#6` 不解析 raw string;reviewer 在 PR 审核 checklist 中签字确认
*Cite: Rule 14 层 1+2 / Section B 主语翻转正/反例*

---

### Tier 分级汇总

| Tier | 数量 | AC IDs |
|------|------|--------|
| MVP 必测 | 23 | AC-FUNC-01..08(8)+ AC-PERF-01..03(3)+ AC-COMPAT-01..05(5)+ AC-ROBUST-01..05(5)+ AC-TONE-01..03(3) -- 但实际应按一一计数: AC-FUNC 8 + AC-PERF 3 + AC-COMPAT 5 + AC-ROBUST 5 + AC-TONE 3 = 24 MVP |
| Beta 推迟 | 3 | AC-PERF-04 + AC-TONE-04 + AC-TONE-05 |

实际计数: **MVP 24 / Beta 3 / 总 27 AC**

### QA 工具需求清单

| 工具 / Fixture | 守门 AC | 技术实现 |
|---------------|---------|---------|
| 时钟桩(`Time.get_ticks_msec()` mock) | AC-PERF-01 | GUT fake_time 替换 |
| SceneTree pause 测试 fixture | AC-ROBUST-04 | `get_tree().paused = true` 注入 |
| Foundation ready 信号 mock | AC-ROBUST-01 / AC-COMPAT-04 | GUT signal stub |
| `_force_dispatch` debug 钩子 | AC-FUNC-06 / AC-PERF-02 / AC-ROBUST-05 | `#6` debug only 方法强制触发 `scene_state_changed` |
| watchdog escalation 测试桩 | AC-COMPAT-04 | 模拟 Foundation `_mark_ready` 永不发射 |
| modal stack mock | AC-FUNC-04 / AC-COMPAT-02 / AC-ROBUST-05 | Input Rule 7 mock |
| crash recovery fixture | AC-COMPAT-01 / AC-ROBUST-02 | Save meta 注入 `run_ended = true` |
| subscriber handler overhead 性能 lint | AC-ROBUST-03 / AC-COMPAT-03 | GUT + `Time.get_ticks_usec()` 计时 |
| FrameTimeMonitor mock | AC-PERF-02 / AC-ROBUST-03 | debug build hook |
| Autoload init order test fixture | AC-ROBUST-01 | `project.godot autoload` 顺序验证脚本 |
| `subject_inversion_lint.py` | AC-TONE-01 / AC-TONE-03 / AC-TONE-04 | Python 正则 lint,CI PR-blocking |
| AC-TONE reviewer checklist | AC-TONE-05 | PR template item + 签字记录 |

## Open Questions

8 OQ-SDF + 3 OQ-SDF-ENG 整理(延 ADR / Pre-Production / Polish 阶段)。

**OQ-SDF-01 (ADR-XXXX 候选)**: Day Flow 状态机实现选型 — Autoload + StateChart Plugin vs hand-rolled FSM script。Owner: technical-director + godot-specialist。Target: ADR-0002 architecture 阶段。
- StateChart Plugin 优势: 4.5+ visualization、history states、parallel states
- Hand-rolled 优势: 零依赖、debug 简单、Godot 4.6 行为已知
- 当前 GDD 假设 hand-rolled with `@abstract BaseSubModeState` (C-ENG-09);若选 StateChart 重审 Section C Rule 1 + Rule 14

**OQ-SDF-02 (ADR-XXXX 候选)**: `scene_state_changed` 总线 vs 直接信号订阅 — 全局 EventBus pattern vs `#6` 直接 emit。Owner: lead-programmer + godot-specialist。Target: ADR-0003 architecture 阶段。
- EventBus 优势: 测试性更好(可 mock),subscriber 解耦
- 直接 emit 优势: Godot signal native,无中间层 overhead,符合 Section C Rule 1 单点 dispatch

**OQ-SDF-03 (ADR-XXXX 候选)**: Save autosave hook 触发点 — 每 sub-mode 转移 vs Tick-based(N AP 后)vs 双轨。Owner: systems-designer + lead-programmer。Target: ADR-0004 architecture 阶段。
- 当前 GDD 隐含"sub-mode 转移触发 + WM_FOCUS_OUT debounced 触发"(Rule 5 + Save Rule 19)
- 若引入"每消耗 N AP 触发"需要新 knob `autosave_ap_interval` + 守门 Save Rule 7 性能预算

**OQ-SDF-04 (Pre-Production)**: GAME OVER 后 Main Menu 路径 UX — 离职证明 transition → archive 完成 → Main Menu 的 3 段式过渡 UX 是否流畅。Owner: ux-designer + writer。Target: `design/ux/gameover-screen.md` 撰写阶段。
- 1500ms 离职证明完成后是否立即跳 Main Menu,还是先停在静态 GAMEOVER 屏等玩家点"新局"?
- 静态屏停留时长 / 玩家可执行操作(Archive 列表 / 新局按钮 / 退出按钮)

**OQ-SDF-05 (Polish)**: pause 期间 wall-clock vs game-time 边界的 playtest 实测 — 玩家对 Lighting 累积 state "暂停期间不漂移" 的 perception。Owner: performance-analyst + qa-tester。Target: Polish 阶段实测。
- 玩家 Alt+Tab 30 分钟回来,期望桌子"还是那样脏" vs "应该更脏"?
- 设计选择倾向"不漂移"(Pillar 5 玩家信任),但 playtest 验证

**OQ-SDF-ENG-01 (ADR-XXXX 候选)**: `PROCESS_MODE_ALWAYS` Autoload 在 4.6 SceneTree.paused 实测行为验证 — Engine Rule 实测清单第 1 项。Owner: engine-programmer + godot-specialist。Target: ADR-0002 architecture 阶段最小复现验证。

**OQ-SDF-ENG-02 (ADR-XXXX 候选)**: `change_scene_to_packed()` 4.5 SceneTree 重构对 2D 路径性能基准实测 — Engine Rule 实测清单第 2 项;P5 5 秒进入预算可能受影响。Owner: performance-analyst + engine-programmer。Target: ADR-0002 architecture 阶段 profiler 实测。

**OQ-SDF-ENG-03 (ADR-XXXX 候选)**: `@abstract` 4.5+ 语法实测验证 — Engine Rule 实测清单第 3 项;若实测发现 4.5 行为与文档不符,Section C Rule 14 + C-ENG-09 需 revise。Owner: godot-specialist。Target: ADR-0002 验证。

**OQ-SDF-09 (#16 KPI Review GDD 定)**: `kpi_review_transition_duration_ms` 候选 knob 是否独立锁(vs 复用 `final_transition_duration_ms = 1500ms`)。Owner: game-designer + qa-lead。Target: `/design-system kpi-review-game-over-ui` (#16 GDD) 撰写阶段。
- B-SCN-2 路径 B(/review-all-gdds 报告):月末 KPI Review 演出时长 ≤ 120s vs GAME OVER 离职证明 1500ms 不同 budget,需 #16 单独锁
- 若 #16 引入新 knob,本 GDD Rule 12 + Interaction #6 需小修引用此新 knob 名

### OQ-impacted AC 标注

| OQ | 影响 AC | 修订路径 |
|----|--------|---------|
| OQ-SDF-01 | AC-FUNC-01 / AC-ROBUST-01 / AC-ROBUST-05 | 若选 StateChart,AC 改为 StateChart API 验证 |
| OQ-SDF-02 | AC-COMPAT-02..05 全部 | 若选 EventBus,subscriber handler 计时改为 EventBus dispatch 计时 |
| OQ-SDF-03 | AC-COMPAT-01 | 若引入 AP-tick autosave,新 knob + AC |
| OQ-SDF-09 | AC-COMPAT-02 / AC-TONE-02 | KPI Review 演出时长锁修订引用 |
| OQ-SDF-ENG-01 | AC-ROBUST-04 | C-ENG-02 行为实测 |
| OQ-SDF-ENG-02 | AC-PERF-01 | 若 4.5 性能劣化,Rule 4 启动序列预算重审 |
| OQ-SDF-ENG-03 | AC-ROBUST-05 | 若 @abstract 行为不符,改用 runtime assertion |
