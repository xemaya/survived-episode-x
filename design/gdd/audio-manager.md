# Audio Manager

> **Status**: **Designed (pending review — awaits `/design-review design/gdd/audio-manager.md --depth lean` in fresh session)**
> **Author**: user + main agent + creative-director (B framings) + audio-director (C 11 Rules + tone 守门) + sound-designer (G 29 资产清单 + 红线) + systems-designer (C 信号架构 + E 35 edges + Bus contracts) + qa-lead (H 26 AC 含 1 真冲突 flag)
> **Last Updated**: 2026-04-25
> **Implements Pillar**: Pillar 5 (地铁可玩性 — 音频不阻主线程 / 启动 preload 不破 5 秒承诺) [primary] + Pillar 4 (黑色幽默 tone 守护 — 音效选型守 "不庆祝 / 不励志" 红线) [guard] + Pillar 2 (叙事即机制 — 环境音承载时间流逝与情绪进程) [secondary]
> **Review Mode**: Lean (CD-GDD-ALIGN skipped per `production/review-mode.txt`)

## Overview

Audio Manager 是《活过第 X 集》音频基础设施层,坐于 Godot 4.6 `AudioServer` 之上,把所有声音输出(环境音 / UI 音效 / 关键时刻配乐 / 月末 KPI 演出 / GAME OVER 片尾)归一为一组语义事件(`play_ambient(scene_id)` / `play_sfx(event_id)` / `play_music(track_id)` / `stop_*`),通过 4 条 Bus(Master / SFX / Music / Ambient)分通道混音。所有上层系统(Scene & Day Flow #6、HUD #13、Card Play UI #14、Recap UI #15、KPI Review UI #16)只触发语义事件,不直接调 `AudioStreamPlayer.play()`。

本系统是 Pillar 5(地铁可玩性)的**音频技术执行层** —— 启动期 preload audio bank 在 Loading Scene 内完成,**不计入 5 秒进入窗口**;runtime audio dispatch ≤ 1 帧 + Godot `AudioServer` 异步播放不阻主线程。同时它是 Pillar 4(黑色幽默 tone)的**声音守门员** —— Audio Manager 故意不实现且不暴露任何"成就音 / 升级提示音 / 完美 timing 反馈音 / 励志 BGM 切换" 原语,后续若需添加任一类别必须先改本 GDD,通过 game-designer + audio-director 批准;**红线无豁免**(Save System Player Fantasy "下班打卡机" + Input Section G + Localization Hooks 均设"零音频反馈" 跨系统先例,Audio 是该 tone 守护红线的承运方而非破坏方)。

Audio Manager **不**拥有: 音频资产文件本身(由 `assets/audio/*.ogg` / `*.wav` 交付,本 GDD 仅锁命名 + Bus 分类 + 加载策略 schema)、音量设置 UI 屏(Main Menu #17 owns,本 GDD 只暴露 `set_bus_volume(bus_id, db)` 接口)、关键事件配乐选段(audio-director 指挥的产出,GDD 仅锁播放时机与跨系统契约)、运行时音频 stream / 在线音乐(违反 Pillar 5 + 单机 Anti-Pillar)、玩家配音(game-concept MVP 明确"不需要配音")。音量设置的持久化走 Save Rule 14 `meta.save` 路径(`meta_settings_debounce_ms = 500 ms` registry 已锁,Audio 是该 contract 第三消费者 —— Save / Input / Localization 之后)。本 GDD 绝不直接 `FileAccess.open`,仅 emit `bus_volume_changed(bus_id, db)` 信号供 Save 订阅。

*技术实现细节(Bus 路由具体配置 vs 自定义混音 / `AudioStreamRandomizer` vs 自定义 randomization wrapper / preload 全 bank vs lazy-load 大型 BGM / 音频压缩格式选型 ogg vs wav vs Vorbis quality / 跨平台音频驱动差异 PulseAudio / WASAPI / SDL3 / 多通道 surround vs stereo lock)留给 ADR 阶段决定;本 GDD 只锁行为语义、跨系统契约、MVP scope("环境音 + UI 音效 + 关键时刻配乐,无配音")的边界。*

## Player Fantasy

Audio Manager 服务工位日常的两类瞬间,继承 Save / Input / Localization 同 tone — **冷静、不抢戏、对比工位语境的低期待**。Save 承诺在运行时(不丢档),Input 在响应层(不卡),Localization 在文本层(说人话);本系统的承诺在**听觉层** —— 玩家从不会主动说"音乐真好",但摘下耳机准备下地铁那一刻,会忽然意识到"刚才一直在听工位"。

### 日光灯嗡的不是 BGM(Pillar 5 + Pillar 4 + Pillar 2 复合锚点)

周二下午 6:30 他在工位连续打了 17 回合,没切场景,光也没暗。只是 ——

工位的日光灯嗡声从一种均匀的 60 Hz 底噪,慢慢被叠上一层屏幕蓝光的蜂鸣。他停下来听了一秒,然后才意识到 —— **已经到 overtime 了**。

没有"进入加班模式"的提示音。没有"系统检测到您已加班 30 分钟"弹窗 SFX。没有 BGM 切换为紧张的合成低音。只是日光灯嗡变成了日光灯嗡 + 蓝光蜂鸣。这不是音效设计师的"沉浸式氛围"成果,这就是工位的物理事实 —— 加班久了,确实会感觉光的频率不一样,确实会听到屏幕在叫。游戏不**创造**这种感觉,游戏只**承认**它。Audio 是 art-bible §2 时钟光语的可听形式 —— 玩家"听到"自己在加班,等同于"读到"自己在加班。

### 月末打卡机不是胜利音(Pillar 4 红线具象化)

月末考核结算那一刻,KPI 通过。屏幕**没有**烟花特效。UI **没有**"叮咚胜利"。BGM **没有**切换为英雄主题。

响的是: 打卡机"咔哒"一声(约 0.3 秒),然后收据热敏打印的"嘶——"(约 2.0 秒持续),打出当月评级。玩家盯着热敏纸看,**没有想庆祝的冲动**。

这是 Audio Manager 守 Pillar 4 红线的具象 —— "胜利"的声音是行政流程的声音。月末通过 KPI 不奏成就音,因为这不是英雄叙事;游戏不假装它是。GAME OVER 时同理 —— 不会切大气结局曲,只有片尾曲红字字幕"咔哒"按完后回归静音(art-bible §2.6 "片尾曲进度条"的 audio 对应,与 Localization "恭喜晋升"反讽锚点同质)。

### Tone 锚点

**对** 的参考: 工位日光灯持续的低频嗡(听不见但摘耳机后才意识到一直在响)、打卡机"咔哒"的机械音、收据热敏打印那种带塑料味的"嘶——"、办公室隔间敲键盘的均匀节奏、远处响了三声没人接的电话、空调出风口的恒定低频、地铁车厢晚高峰刹车的金属摩擦、Save 的"下班打卡机"、Input 的"工位隔间键盘均匀节奏"、Localization 的"老家亲戚的中文"。

**反** 的参考: 不是 RPG 的"叮咚拾取音";不是 mobile 游戏的"金币哗啦啦";不是 rhythm game 的"perfect timing"提示音;不是动作游戏的"hit 反馈打击感";不是 controller-friendly 游戏插上手柄的"已检测到 Xbox 手柄"语音;不是开场"已为您切换中文配音"提示语;不是月末通过 KPI 的"叮 ~ 升级!"或"任务完成 ✓"反馈音;不是 Save / Load 操作的"嗖咻"读写音;不是切换语言的"switching to English ✓" 庆祝声。Audio 不庆祝玩家,也不庆祝自己。

### 玩家不会说的话 / 会说的话

- ❌ "BGM 真好听" / "音效很赞" / "氛围感拉满" / "终于有沉浸式音频了"
- ❌ "调成 8D 环绕音特别带感" / "推荐戴耳机玩!" / "动态混音很高级"
- ✅ (沉默 —— 摘耳机准备下地铁,完全没意识到刚才一直在听 audio)
- ✅ "几点了?" / "这日光灯像我们公司。" / "打卡机的声音吓我一跳。"

## Detailed Rules

### Core Rules

1. **Bus 架构(4 通道,Master 锁,玩家可调 3 通道)**: AudioServer 挂 4 条 Bus,分工与默认 dB 锁定:

   | Bus | 默认 dB | 路由 | 玩家可调 |
   |-----|--------|------|---------|
   | `Master` | 0 dB(峰值限幅) | 全 Bus 总出口 | **不可调**,系统只读(硬件保护用) |
   | `SFX` | -6 dB | UI 音效(打卡机咔哒 / 热敏嘶 / 行动卡)+ 所有 oneshot 事件音 | 可调 [-60, 0] dB |
   | `Music` | -9 dB | 关键时刻配乐(月末考核 + GO 片尾)— 正常游戏期间静音非卸载 | 可调 [-60, 0] dB |
   | `Ambient` | -12 dB | 持续环境音层(日光灯底噪 / 空调 / 键盘节奏 / overtime 蜂鸣叠加) | 可调 [-60, 0] dB |

   **Ducking 规则**: Music 在 SFX 播放打卡机咔哒 + 热敏嘶期间,对 Ambient 施加 -6 dB duck;**SFX 永不被 duck**。月末演出结束 Ambient 在 `ambient_duck_release_ms = 800 ms` 内线性回位,**无 stinger**、**无转场音**。Music 非关键时刻期间音量为 -∞ dB(静音非卸载,避免流式加载延迟)。

2. **运行时音量契约 + 信号边界(同 Save Rule 14 / Input / Localization 模式)**: Audio Manager 内存音量表 `Dictionary[StringName, float]`(bus_id → dB)。流程: (a) 玩家在 #17 Settings 改音量 → 更新内存表 + `AudioServer.set_bus_volume_db()`;(b) emit `bus_volume_changed(bus_id: StringName, db: float)` 信号;(c) Save 订阅,按 Save Rule 14 `meta_settings_debounce_ms = 500 ms` 防抖写入 meta;(d) 启动期由 Scene & Day Flow Controller 调 `AudioManager.load_bus_volumes(payload: Dictionary)` 注入存档值。**Audio 绝不直调** `SaveSystem.write_*` API、**绝不开** `FileAccess` / `ConfigFile`(Save Rule 20 承约)。依赖方向严格: Audio → signal → Save。**Audio 是 `meta_settings_debounce_ms` 的第三消费者**(Save / Input / Localization 之后)。

3. **Audio Event 命名空间(语义事件 schema,对齐 Localization Rule 1)**: 所有 audio event key 使用 `BUS.DOMAIN.IDENTIFIER[_VARIANT]` 全大写下划线点记。**Bus 白名单(新增须改本 GDD)**: `AMBIENT` / `SFX` / `MUSIC`。示例合法 key:

   | Key | Bus | 说明 |
   |-----|-----|------|
   | `AMBIENT.OFFICE.FLUORESCENT_HUM` | Ambient | 日光灯 60 Hz 底噪,常驻主菜单到白天行动 |
   | `AMBIENT.OFFICE.SCREEN_BUZZ_OVERTIME` | Ambient | overtime 蜂鸣叠加层(**Player Fantasy "日光灯嗡的不是 BGM" 具象化**) |
   | `AMBIENT.OFFICE.AC_LOW_HISS` | Ambient | 空调恒定低频 |
   | `AMBIENT.OFFICE.KEYBOARD_RHYTHM` | Ambient | 隔间键盘均匀节奏(loop) |
   | `AMBIENT.OFFICE.PHONE_THREE_RINGS` | Ambient | 远处电话三声无人接(oneshot,随机间隔) |
   | `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC` | SFX | 打卡机咔哒(~0.3 s)— **Player Fantasy "月末打卡机不是胜利音" 具象化**;`_BUREAUCRATIC` 后缀标 tone 锚 |
   | `SFX.UI.RECEIPT_THERMAL_HISS_BUREAUCRATIC` | SFX | 收据热敏嘶(~2.0 s 持续)— 月末评级打出 |
   | `MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC` | Music | 月末考核期间配乐(loop,行政流程音化) |
   | `MUSIC.GAMEOVER.CREDITS_OUTRO_BUREAUCRATIC` | Music | GO 片尾曲(oneshot,随字幕红字结束;art-bible §2.6 片尾曲进度条对应) |

   **`_BUREAUCRATIC` 后缀**: 类比 Localization `_IRONY` —— 标"行政流程音化"tone 锚的 key,**作为 sound-designer 制作 brief 必备 + audio-director review 触发条件,不进 CI lint**(audio 文件 tone 不宜自动检测,human review 守门)。**禁止**: 跨 Bus 复用同 key(每 Bus 独立命名空间)、数字序号 ID(`SFX.UI.SOUND_01` 非法)。

4. **Pillar 4 红线: 具体禁止的 SFX 与 BGM 切换类型(无豁免)**: Audio Manager **故意不实现且不暴露**以下事件类型,新增须先改本 GDD,经 game-designer + audio-director **双批**方可:

   **禁止 SFX 类型**:
   - 成就解锁音(三段上升音符 "叮! 成就: 活过第 3 集")
   - 升级 / 进阶提示音("叮咚"双音上滑,英雄主题 leitmotif 变体)
   - 完美 timing 反馈音(rhythm game 式 "perfect" / "great" 单音 stinger)
   - 庆祝 fanfare(烟花声 / 欢呼声 / 鼓掌 loop / "任务完成 ✓" 叮声)
   - Controller 检测庆祝音(手柄连接时的"欢迎"音效)
   - 语言切换确认音(cf. Localization Visual/Audio 零音频要求)
   - Save / Load 读写音("嗖咻"存档动画 SFX,cf. Input Section G 零音频要求)
   - 升职 / 加薪 fanfare(任何英雄主题、励志电影式弦乐上行)
   - 普通 UI 按钮的非机械式音(Pillar 4 + Section B Tone 锚 — UI 默认无 SFX,见 Rule 9)

   **禁止 BGM 切换模式**:
   - 进入 overtime 状态时切换为紧张合成低音(用 `SCREEN_BUZZ_OVERTIME` ambient overlay 代替,见 Rule 6)
   - KPI 通过时切换为英雄主题(用 `PUNCH_CLOCK_CLACK + RECEIPT_THERMAL_HISS` SFX 代替,Pillar 4 红线)
   - 死亡时切换为大气结局曲(GO 用 `CREDITS_OUTRO_BUREAUCRATIC` 行政音,Pillar 4 红线)
   - 任何"励志上扬"型 BGM stinger 触发

5. **启动期 preload 策略(Pillar 5 5 秒承诺,Loading Scene 内完成 < 200 ms)**: 全部 audio bank(环境音 loop + UI SFX + 关键时刻配乐)在 Scene & Day Flow Controller 初始化序列内 `ResourceLoader.load()` 预加载,**不计入 5 秒进入窗口**。**预加载总耗时上限 `audio_preload_budget_ms = 200 ms`**(CI smoke check blocking)。**Audio bank 总文件大小上限 `audio_bank_total_size_mb ≤ 30 MB`**(对齐 art-bible §8.5 显存预算听觉等价约束)。**Fallback 策略**: missing audio file → 静默降级,不报 error sound,不崩溃;dev build 输出 `push_warning("[AudioManager] missing stream for key: [KEY]")`,prod build 静默(Pillar 5 功能完整性 + Rule 9 静音守门一致)。配乐 lazy-load 由 ADR 决定;本 GDD 锁行为语义: 首次播放不可有可感知 hitch(KPI Review 演出开始前至少 2 帧完成 stream open)。

6. **环境音叙事化(6 MVP 场景状态 × ambient layer schema,art-bible §2 时钟光语 audio 对应)**:

   | 场景状态 | art-bible §2 | Ambient layers(同时播放) | 切换策略 |
   |---------|------------|------------------------|---------|
   | 主菜单 | 2.1 清晨 6:58 | `FLUORESCENT_HUM`(-18 dB)+ `AC_LOW_HISS` | 无 fade,系统静止启动 |
   | 早晨预告 | 2.2 板正沉默 | 同主菜单 | 直接跨,不加层 |
   | 白天行动(day) | 2.3 拥挤钝感 | `FLUORESCENT_HUM`(-12 dB)+ `KEYBOARD_RHYTHM`(-15 dB)+ `PHONE_THREE_RINGS`(随机 oneshot)+ `AC_LOW_HISS` | `KEYBOARD_RHYTHM` crossfade 入 0.5 s |
   | 白天行动(overtime) | overtime `#1A2A4A` 蓝光 | day 层 + 叠 `SCREEN_BUZZ_OVERTIME`(-10 dB) | `SCREEN_BUZZ_OVERTIME` **无 stinger**,纯音量渐入 2 s;**不切 BGM**(Player Fantasy 锚) |
   | 下班抉择 | 2.4 拉锯窒息 | 延续当前 day/overtime 层 | 保持当前不变;张力由视觉承担 |
   | 今日总结 | 2.5 倦意收尾 | `FLUORESCENT_HUM`(-18 dB)+ `AC_LOW_HISS`(-3 dB);键盘音淡出象征离开工位 | `KEYBOARD_RHYTHM` crossfade 出 1 s |
   | 月末 KPI 考核 | 2.6 仪式感尘埃落定 | Ambient 全层 duck -6 dB(Rule 1)+ Music Bus 启动 `KPIREVIEW.ENDGAME_LOOP` | Music fade in 1.5 s |
   | GAME OVER 片尾 | 2.6 片尾字幕 | Ambient 全层 fade out 2 s → 静默;Music `CREDITS_OUTRO` oneshot,播完归静音 | 静默后无任何补充 audio |

   **Crossfade 约束**: 所有 ambient 切换用 Tween 线性 volume 渐变(0.5–2 s),**禁突变**、**禁 BGM-style transition stinger**、**禁情绪切换提示音**。

7. **配乐精准定义(关键时刻 BGM 白名单 + 全面禁止列表)**: **有 BGM 的时刻仅 2 类**:
   - **月末 KPI 考核期间**: `MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC`,loop。**Tone 硬约束**: 行政流程音化(打卡机底层 / 收据热敏质感 / 办公室机器感);**禁** 弦乐上行 / 励志合成器 / 鼓点加速。BGM 长度上限 `bgm_loop_length_max_sec = 120 s`(Pillar 5 暂停 / 关 app 不阻塞退出)。
   - **GAME OVER 片尾曲**: `MUSIC.GAMEOVER.CREDITS_OUTRO_BUREAUCRATIC`,oneshot,随字幕同步结束。**Tone 硬约束**: 行政流程音化,冷静落幕,无英雄结局感(对齐 Localization `GAMEOVER.TITLE_IRONY` "恭喜晋升"反讽锚点同质 tone)。

   **绝不有 BGM 的时刻(穷举)**: 日常行动任何时刻 / overtime(用 ambient 代)/ KPI 通过(用打卡机 SFX 代)/ 死亡瞬间(非 GO 片尾)/ 升职瞬间 / 主菜单(静默 ambient 即可)。

8. **运行时 dispatch 协议 + SFX 池(Pillar 5 ≤ 1 帧不阻线)**: `play_sfx(event_id)` / `play_ambient(scene_id)` / `play_music(track_id)` 主线程开销 **≤ 1 帧(16.6 ms)**;Godot AudioServer 异步硬件混音不占帧预算。**SFX 实例池**: `MAX_CONCURRENT_SFX = 8` 固定大小池,LRU 驱逐(同 event_id 同帧 all fire,不去重 — 去重仅 ambient 同 scene_id 不重启);**MAX_CONCURRENT_AMBIENT = 2**(main + overtime 叠加);**MUSIC_PLAYER_COUNT = 2**(crossfade 双槽)。**`new()` per call 禁止**(GC 压力,Pillar 5)。Music / Ambient 用独立长生命周期 `AudioStreamPlayer` 节点,不入 SFX 池。

9. **静音 / 无音频环境功能完整性(Pillar 5 + art-bible §7.4 双重编码听觉等价)**: 玩家静音(Master = -60 dB ≈ -∞)时游戏功能 **100% 完整**。**重要游戏机制信息不可仅通过 audio 传达**:
   - overtime 状态: 视觉 `_overtime` sprite variant + CanvasModulate 蓝光必须独立传达
   - KPI 通过: 收据热敏打印视觉动画必须独立传达结算结果
   - Toast / 弹窗: 文本 + 视觉同步,不仅靠 SFX 触发

   **UI 按钮 audio**: 常规 UI 导航(焦点切换 / `act_confirm` / `act_cancel`)**默认无 SFX**(对齐 Section B Tone 锚 + Save / Input / Localization 同质 tone)。**唯一例外**: 打卡机类语义操作(月末结算 confirm)可有 `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC`。**信号解耦**: `bus_volume_changed` / `audio_event_played` / `music_track_changed` 信号在 Master bus 静音时**仍照常 emit**(信号是抽象事件,与音频物理输出解耦)。

10. **Tone 守门三层执法(Pillar 4 红线无豁免)**: (a) **Layer A — Sound Designer brief 锚(human)**: `_BUREAUCRATIC` 后缀 key 必须附 tone 说明 + 禁用方向("行政流程音化;禁: 上行音符 / 励志节奏 / 英雄弦乐 / 完美 timing 质感");(b) **Layer B — Audio Director review gate**: 任何新增 MUSIC domain asset 或 SFX.UI 类 asset 修改需 audio-director 听审通过 + game-designer 同步确认 Pillar 4 对齐;(c) **Layer C — CI lint 自动层 (`tools/audio_lint.gd` Editor Tool, MVP 就实现)**: 检查文件命名符合 Rule 3 schema / Music domain 文件数 ≤ `MUSIC_TRACK_MAX = 4`(防音乐蔓延)/ `_BUREAUCRATIC` key 须有对应 brief 文档引用(孤立 key WARN)/ 孤立 audio asset(文件存在但无 key 引用)WARN。**禁止**: 无 audio-director + game-designer 双批新增 MUSIC domain key。

11. **零音频契约(Input + Localization 双解耦,延续跨系统 tone 先例)**:
    - **Input Handler #2 调用路径完全不触发 Audio**: Audio Manager **不订阅** Input 任何信号(`act_confirm` / `act_skip` / `keymap_changed` / `focus_path_changed` / `device_disconnected` 等);UI 系统在 `act_confirm` 响应内调 `play_sfx()` 是 **UI → Audio** 主动路径(Contract #3),非 Input 隐式触发
    - **Localization Hooks #3 调用路径完全不触发 Audio**: Audio Manager **不订阅** `locale_changed` 或任何 Localization 信号
    - **测试断言契约**(AC 阶段实现): 模拟完整 Input 信号序列 → Audio Manager 无任何 `play_*()` 触发;`LocalizationHooks.set_locale(any_locale)` → Audio Manager 无任何 `play_*()` 触发

### States and Transitions

**主状态机(2 态,LOADING / READY)** — Music 非状态机,是 READY 内 enum 子态(`IDLE` / `KPIREVIEW` / `GAMEOVER`)由当前播放的 MUSIC track 决定,作为数据而非状态守护:

| 状态 | 含义 | 合法调用 | 进入条件 | 退出条件 |
|------|------|---------|---------|---------|
| **LOADING** | preload audio bank 进行中 | 仅 `register_*`(预注册);其余 `play_*` / `stop_*` / `set_bus_volume` 排队或丢弃(见下) | 系统初始化 | Scene & Day Flow 调 `AudioManager.mark_ready()` |
| **READY** | 正常 dispatch 态 | 全部接口 | `mark_ready()` | 无(运行期不离开 READY) |

**LOADING 期 dispatch 守门**(同 Localization Rule 5 演出 lock 排队思路):
- **Ambient**: 进入 size=1 pending queue,READY 后 `mark_ready()` 同帧 flush(取最新,丢更早请求,与 Save Rule 13 snapshot 合并语义一致)
- **Music**: 同 ambient,size=1 queue
- **SFX**: **直接静默丢弃**,不排队(类比 Input Rule 7 blocking modal 下 `act_skip` 被吞)— SFX 是即时反应型事件,READY 后才 flush 语义失效

`mark_ready()` 是私有方法,仅 Scene & Day Flow Controller 可调。外部不暴露 `get_state()` 公开接口,业务层不感知 LOADING / READY 边界。

**Music sub-mode enum**(在 READY 内,不是状态机,是当前播放轨数据):

| Sub-mode | 触发 | 退出 | Ambient duck |
|---------|------|------|-------------|
| `IDLE` | 初始化 / Music 播完 / KPI 演出结束 | → KPIREVIEW / → GAMEOVER | 无 |
| `KPIREVIEW` | Scene Flow `kpi_review_started` | KPI 演出结束 → IDLE(`ambient_duck_release_ms = 800 ms` 内回位) | -6 dB |
| `GAMEOVER` | Scene Flow `game_over_triggered` | `CREDITS_OUTRO` 播完 → IDLE | Ambient fade out 2 s → 静默 |

**事件 → Audio 触发映射**:

| 触发事件 | 音频行为 |
|---------|---------|
| Scene Flow `scene_state_changed(OVERTIME)` | Ambient: `SCREEN_BUZZ_OVERTIME` 渐入 2 s(无 stinger) |
| Scene Flow `scene_state_changed(DAY)` | Ambient: `SCREEN_BUZZ_OVERTIME` 渐出 1 s |
| `kpi_review_started` | Music sub-mode → KPIREVIEW;Music fade in 1.5 s;Ambient duck -6 dB |
| `kpi_passed`(月末通过) | SFX `PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC` 顺序播;**无** fanfare;**无** BGM 切换 |
| `game_over_triggered` | Music sub-mode → GAMEOVER;Ambient fade out 2 s;Music `CREDITS_OUTRO_BUREAUCRATIC` |
| `act_pause`(玩家暂停) | Music Bus 淡至 -∞ dB(200 ms);Ambient Bus 淡至 -24 dB(300 ms) |
| `act_pause` 退出 | Music / Ambient 恢复播放前音量(200 ms) |

### Interactions with Other Systems

> **Save System (#1)** ↔ Audio Manager
> **流入** (#1 → Audio): 启动期由 Scene & Day Flow 协调,从 `meta.save.settings.audio` 读 4 bus dB 配置,调 `AudioManager.load_bus_volumes(payload)` 注入。Audio 不直接读 Save 文件
> **流出** (Audio → #1 via signal): `bus_volume_changed(bus_id, db)` 信号;Save 订阅按 Rule 14 / 500 ms 防抖写 meta(Audio 是 `meta_settings_debounce_ms` 第三消费者)
> **所有权**: Save owns `meta.save` 持久化;Audio owns 运行时 bus 状态
> **关键约束**: Audio **绝不直调** SaveSystem.write_*、`FileAccess`、`ConfigFile`(Save Rule 20)。依赖方向严格 Audio → signal → Save

> **Scene & Day Flow Controller (#6)** ↔ Audio Manager
> **流入** (#6 → Audio): 启动期 `AudioManager.preload_bank()` + `mark_ready()`;场景切换 `play_ambient(scene_id)`;演出 `play_music` / `stop_music`;`kpi_review_started` / `game_over_triggered` 信号触发 sub-mode 切换
> **流出** (Audio → #6): `audio_manager_ready()` 信号(#6 等此 gate 通过再开 UI);`music_track_changed` 可选订阅
> **所有权**: #6 owns 场景 id → ambient 切换决策 + 演出 lock 时机;Audio owns 实际 `AudioStreamPlayer` 切换 + crossfade 执行
> **时机**: 场景切换由 #6 驱动,Audio 被动响应

> **Main Menu / Pause / Settings UI (#17)** ↔ Audio Manager
> **流入** (#17 → Audio): `set_bus_volume(bus_id, db)` 实时应用(slider 拖动)/ `get_bus_volume(bus_id)` 读初始化值 / `mute_all()` / `unmute_all()`
> **流出** (Audio → #17): `bus_volume_changed` 信号(#17 订阅刷 slider)
> **所有权**: #17 owns 音量 3 旋钮 UI(SFX / Music / Ambient,**不暴露 Master**)+ 用户交互;Audio owns bus 状态 + Save 通知
> **UI 约束**: 旋钮值域 [-60, 0] dB,步进 1 dB;**无音效反馈**(旋钮拖动无 SFX,Pillar 4 + Section B Tone 锚)

> **HUD #13 / Card Play UI #14 / Recap UI #15 / KPI Review UI #16(diegetic UI)** ↔ Audio Manager
> **流入** (UI → Audio): diegetic 事件直接调 `play_sfx(event_id)`,event 语义如 `SFX.CARD.PLAY` / `SFX.KPI.PRINT_RECEIPT_BUREAUCRATIC`;UI owns 触发时机
> **流出** (Audio → UI): 无(单向依赖,UI → Audio)
> **所有权**: UI owns "何时"触发;Audio owns "播什么 + 走哪 Bus + 并发上限"
> **Pillar 4 守门**: diegetic UI **不可调**任何 Pillar 4 红线 event_id(成就音 / 升级音 / 完美 timing 反馈音 等)— 此类 event_id 在 Audio Manager event 注册表中**不存在**(Rule 4),调用返回 `push_error` + no-op

> **Input Handler (#2) — 零音频契约(Rule 11)**
> **流入**: 无(Audio 不订阅 Input 任何信号)
> **流出**: 无(Input 不订阅 Audio 任何信号)
> **所有权**: 无直接契约。UI 层在 Input 信号响应内主动调 `play_sfx()` 是 UI → Audio 路径(归 #13/14/15/16 Contract),不是 Input → Audio
> **测试断言**: `InputHandler` 全信号序列 → Audio Manager 无 `play_*()` 触发

> **Localization Hooks (#3) — 零音频契约(Rule 11)**
> **流入**: 无(Audio 不订阅 `locale_changed` 或任何 Localization 信号)
> **流出**: 无
> **所有权**: 完全解耦
> **测试断言**: `LocalizationHooks.set_locale(any)` → Audio Manager 无 `play_*()` 触发

## Formulas

**N/A — 无独立公式需求**。

理由: Audio Manager 系统的"数学"全部为阈值常量,已嵌入对应 Rule 与 Tuning Knobs 章节,不构成独立 formula 范畴(对照 Localization Section D 的 F1 reflow latency / F2 coverage ratio,Audio 无类似 scaling / linear / ratio 关系):

- **dB ↔ linear amplitude 转换**: Godot `AudioServer` 内置 `db_to_linear()` / `linear_to_db()`,标准实现,不需 GDD spec
- **Ducking 计算**: Rule 1 已锁 `Music duck Ambient -6 dB during SFX bureaucratic events`,简单条件触发,非函数关系
- **Ambient crossfade rate**: Rule 6 已锁 0.5–2 s 线性 Tween,Godot 标准 linear interpolation,无变量
- **SFX 实例池 LRU 驱逐**: Rule 8 已锁 `MAX_CONCURRENT_SFX = 8`,优先级 + 时序排序的 implementation 细节,非 mathematical formula
- **Bus 默认 dB 配置**: Rule 1 表已锁(SFX -6 / Music -9 / Ambient -12),Section G Tuning Knobs 给 safe range,本身是常量

**对照已设计系统**:
- Save Section D: 也无 formula(Save 是 schema + lifecycle,无 scaling math)
- Input Section D: 3 formulas(deadzone 3-zone / D-Pad repeat / path arbitration)— Input 有真 mathematical mappings
- Localization Section D: 2 formulas(F1 reflow latency 线性分解 / F2 coverage ratio)— Localization 有跨变量计算
- Audio: 系统性质同 Save,以 Bus 配置 + lifecycle 为核心,无 mathematical relationships

**未来 revisit 触发条件**:
- 引入动态混音(基于 gameplay state 的 Bus dB curve 变化)— 触发 F1 ducking curve formula
- 引入动态 SFX 优先级权重(超过简单 priority class)— 触发 F2 eviction priority formula
- 引入空间音频 / 距离衰减(MVP 不做,野心版可能)— 触发 F3 spatial attenuation formula

野心版若上线动态混音或空间音频,本节须补 formulas。MVP scope 内本节确认 **N/A**。

## Edge Cases

35 edges / 10 categories,**5 [RISK GUARD]** 对齐 Localization R-LOC-1..5 / Input R1/R2/R3 守门结构(Pillar 5 / Pillar 4 高风险路径)。6 新 OQ-AUD 标记于本节,合并入 Open Questions。

### 1. Boundary Values

- **If `MAX_CONCURRENT_SFX = 8` 同帧恰好 8 次 `play_sfx`**: 第 8 个 SFX 占用池最后一 slot。第 9 触发 LRU 驱逐(见 Cat 5)。边界本身无特殊逻辑。
- **If `audio_preload_budget_ms = 200 ms` 恰好打满**: Loading Scene 序列继续推进,`mark_ready()` 正常调用。CI smoke check 比较为 `> 200` 而非 `>= 200`(上限含)。
- **If `audio_bank_total_size_mb` 恰好 30 MB**: Rule 5 上限"≤ 30 MB",合法。CI 验证保持 `<= 30` 语义。压缩后超 30 MB → CI FAIL,sound-designer 须缩减或提升压缩,不得调高阈值绕过。
- **If `bgm_loop_length_max_sec = 120 s` 恰好 BGM track 单次 loop**: 无缝续接合法。121 s 触 lint 阻 CI(loop 长度 lint 待补 [OQ-AUD-01])。
- **If SFX Bus = 0 dB(可调上限)**: 合法,Master 仍 0 dB peak limit 限幅。SFX = 0 + Master = -∞(mute)结果仍静音。
- **If SFX Bus = -∞ dB(静音 ≈ -60 dB clamp)**: UI 所有 SFX 静默,但视觉收据打印动画仍运行(Rule 9 双重编码)。`bus_volume_changed` 信号仍 emit。

### 2. Audio Asset Lifecycle

- **If `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC` 文件缺失**: Rule 5 fallback 静默降级,dev `push_warning`。月末 KPI 流程不中断,视觉路径独立。**[RISK GUARD — R-AUD-1]**: `_BUREAUCRATIC` 锚点 key 缺失 = Pillar 4 月末打卡机听觉具象失守。AC 须含 CI asset-integrity 验证 `PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `CREDITS_OUTRO_BUREAUCRATIC` 文件存在。CI 缺失 = P0 FAIL(等价 Localization R-LOC-1 CSV 缺失)。
- **If audio asset 命名违反 Rule 3 schema 但 lint 被 `--no-verify` 绕过**: CI 独立运行不受 pre-commit 绕过影响。runtime: key 找不到文件 → Rule 5 静默降级。
- **If sound-designer round-robin 3 变体只交付 2 文件**: 第 3 变体指 null stream → Rule 5 静默丢弃 + dev warning,**不**循环至有效变体。变体缺失是资产 defect,由 lint asset-count validation 守门。[OQ-AUD-02]
- **If 孤立 audio asset(文件有,无 key 引用)**: Rule 10 Layer C lint 发 WARNING(非 FAIL)。不自动 purge — 需 audio-director 人工确认非 dynamic key 路径 grep-miss。不被 preload(按 key 驱动加载),不占 preload budget;但计入 `audio_bank_total_size_mb` 磁盘统计。lint 须区分 on-disk vs preload size。[OQ-AUD-02]
- **If `MUSIC_TRACK_MAX = 4` 被超**: Rule 10 Layer C CI lint FAIL,PR block。runtime 若 lint bypass:Audio Manager 仅加载前 4 个已注册 MUSIC key,超出 key 等同未注册,`play_music` 调用触 Rule 5 静默丢弃 + dev warning。**[RISK GUARD — R-AUD-2]**: Pillar 4 防音乐蔓延硬守门(等价 Localization R-LOC-5 零 IRONY key 守门)。

### 3. State Machine Race(LOADING / READY)

- **If Scene Flow 在 LOADING 期调 `play_sfx`**: SFX 静默丢弃(Rule States 定义),不排队。dev `push_warning("[AudioManager] play_sfx called in LOADING state: dropped")`。
- **If Scene Flow 在 LOADING 期调 `play_ambient`**: 进入 size=1 pending queue,`mark_ready()` 同帧 flush。LOADING 期连续 5 次 `play_ambient`:仅最后一次存活(覆盖,与 Save Rule 13 snapshot 合并语义一致)。前 4 次静默丢弃 + dev warning。
- **If `mark_ready()` 由非 Scene Flow 节点错误调用**: 私有方法(GDScript `func _mark_ready()` 或访问控制),外部调用 `Method not found`。dev `push_error`。Audio 保持 LOADING 直至合法调用。UI/HUD GDD 须文档"不调 AudioManager 内部私有方法"。
- **If Save 在 Audio LOADING 期 emit `bus_volume_changed`**(启动序列时序错): `set_bus_volume` 在 LOADING 期**直接应用至内存表**,READY 后物理 `AudioServer.set_bus_volume_db()` 刷入 — **不排队丢弃**(确保 mark_ready 后 Bus 状态正确)。[OQ-AUD-03]
- **If Scene Flow 永远不调 `mark_ready()`**(bug 永久卡 LOADING): 所有 `play_ambient` / `play_music` 请求堆积(实为只保留最新),Audio 永久不可用。**[RISK GUARD — R-AUD-3]**: 对齐 Localization R-LOC-3 watchdog。Resolution: `LOADING` 超 `AUDIO_LOADING_WATCHDOG_MS = 10000 ms`(10 s)触 `push_error` + 强制转 READY + flush pending queue。

### 4. Bus / Volume / Ducking Race

- **If Music ducking 期间玩家 Master mute(-∞ dB)**: Ambient 当前 -12 - 6(duck)= -18 dB + Master mute → 物理静音。duck 数值仍内存活跃,Master mute 不重置 duck 状态。duck release 在 800 ms 内执行回 -12 dB(仍 Master mute,物理仍静音)。玩家取消 mute:Ambient 按当前内存状态恢复。无逻辑错。
- **If 同帧两次 `set_bus_volume(SFX, x)` 冲突**(Settings UI + Save restore): 顺序执行,后者覆盖前者。`bus_volume_changed` emit 两次 — Save 触两次 debounce 重置,最终以第二次值持久化。Settings UI 须避免与 Save restore 同帧并发(归 Scene Flow 协调)。[OQ-AUD-03]
- **If 玩家 slider 连续拖动每帧 `bus_volume_changed`(~100 次/秒)**: Audio 每次 `AudioServer.set_bus_volume_db()` ≤ 1 帧(Rule 8)。Save 侧 `meta_settings_debounce_ms = 500 ms` 自动合并(Save Rule 14)。Audio 不做额外 debounce(职责在 Save 侧,符合系统边界 Rule 2)。
- **If `ambient_duck_release_ms = 800` 在演出 lock 期到期但演出持续 1500 ms**: duck release Tween 自然 800 ms 回位,无论演出是否在进行。结果:演出 1500 ms 时 Ambient 已回正常,Music 与 Ambient 叠放无 duck。可接受。audio-director brief 须确认 800 ms 与最长 SFX 时长关系。[OQ-AUD-04]

### 5. SFX Pool Race

- **If 池满 8/8 第 9 次 `play_sfx` 普通 SFX**: LRU 驱逐最久未用 `AudioStreamPlayer`(Rule 8)。被驱逐 SFX 仍在播放则立即停止(可能 audio pop — [OQ-AUD-05])。第 9 SFX 取该 slot。
- **If 池满 8/8 第 9 次 `play_sfx` 为 `_BUREAUCRATIC` 关键 key**: LRU 不区分 key 语义。**[RISK GUARD — R-AUD-4]**: 月末关键 SFX 被 LRU 驱逐 = Pillar 4 tone 失守。Resolution: 引入 SFX priority class —— `SFX_PRIORITY_CRITICAL`(所有 `_BUREAUCRATIC` key)在 LRU 驱逐时**豁免被驱逐**,仅可驱逐 non-critical slot。若全池 8 个均 CRITICAL,新 CRITICAL 按 LRU(不丢弃)。[OQ-AUD-01] ADR 锁实现。
- **If 同帧 8 次 `play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC")`**: Rule 8 "all fire 不去重"。8 次相位几乎一致,峰值音量可能 clip SFX Bus。audio-director brief 须注明 `_BUREAUCRATIC` SFX 不应同帧多次触发(调用方 contract)。[OQ-AUD-02]
- **If 池内 `AudioStreamPlayer` 实例被外部 `queue_free`**: 下次 LRU 查 slot `is_instance_valid()` 返 false → 视作空闲立即重用(等价 Input R2 / Localization R-LOC-2 instance-guard 模式)。dev warning,prod 静默 reclaim。SFX 池节点须作 AudioManager 子节点,不应被外部 free。

### 6. BGM / Music Race

- **If `play_music(track_A, crossfade=2000)` 后 500 ms 调 `play_music(track_B, crossfade=1500)`**: 双 Music slot(Rule 8 `MUSIC_PLAYER_COUNT = 2`)。第二次取消 track_A 的 fade-in Tween,以当前音量为起点开始 track_B crossfade。**始终最多 2 track 同时活跃**,双槽设计保证。[OQ-AUD-04]
- **If `stop_music(fade_out=2000)` 期间 KPI 演出触发 `play_music`**: 取消 stop Tween,以当前 fade-out 中间音量为起点 fade in。**`play_music` 语义优先于 `stop_music`**。Scene Flow GDD 须文档不应在 stop fade 期触发 `play_music`。[OQ-AUD-04]
- **If `play_music(track_id)` 时 BGM 资产未加载**: Rule 5 lazy-load 须在 KPI Review 演出开始前至少 2 帧完成 stream open。若 2 帧内未加载 → Rule 5 fallback Music Bus 静默,演出视觉路径继续,dev warning。lazy-load ADR 须明确"2 帧保证"机制。[OQ-AUD-01]
- **If 月末演出超 `bgm_loop_length_max_sec = 120 s`**: BGM 在 120 s 处无缝 loop 续接。演出不受 BGM loop 点驱动结束(loop 是纯音频,演出由 Scene Flow 控制)。无 stinger,无转场。

### 7. Cross-System Edges

- **If Save write 失败时玩家正调 SFX volume**: volume 应用至内存表 + AudioServer 即时生效;Audio emit `bus_volume_changed` → Save 防抖后写入失败。runtime/persisted 分歧可接受(对齐 Localization Section E Cat 9)。Save 错误处理 GDD 须 document 此场景。
- **If locale switch 期间 Audio 反应**: Rule 11 零音频契约 — Audio 不订阅 Localization 信号。`set_locale(any)` 全程 Audio 无 `play_*` 触发。AC 含断言测试。
- **If Input modal lock 期间 Audio dispatch**: Audio 不订阅 Input 信号(Rule 11)。`acquire_modal_lock` 对 Audio 透明,modal 内 UI 调 `play_sfx` 正常 dispatch。打卡机 SFX 在 modal 弹出期可播。
- **If `NOTIFICATION_WM_WINDOW_FOCUS_OUT` 期间 Music / Ambient**: Audio Manager 须订阅此通知 — **采用与 `act_pause` 同一公版**: Music Bus 淡至 -∞ dB(200 ms),Ambient Bus 淡至 -24 dB(300 ms)。理由: `act_pause` 与 `WM_FOCUS_OUT` 都是"玩家暂时离场"的语义,无须区分 — Ambient 工位环境音保持持续(art-bible §2 时钟光语 audio 对应不被切窗中断,与 Pillar 2 一致),Music 完全静(避免后台噪音)。焦点回时恢复前值。**时序协调**(对齐 Input Edge 9.1 + Localization Edge 9.x):Input `reset_all_action_presses()` + Audio Tween 启动同帧主线程同步,无 race。[OQ-AUD-06]

### 8. Pillar 4 Tone Violation 路径

- **If 新加 `_BUREAUCRATIC` key 文件实际为英雄主题(audio-director review 漏)**: Rule 10 Layer B 是人工审听 gate,CI lint 无法检测音频 tone。Mitigation: audio-director 须 brief 附 30 s 参考样片 + game-designer 在 KPI 演出 playtest 主观验证。漏入 prod → hotfix + audio 替换。Tone defect 不设 lint 守门(Rule 10 Layer C 明确 "audio 文件 tone 不宜自动检测")。
- **If `MUSIC_TRACK_MAX = 4` 被超**(已 R-AUD-2 覆盖,行为细节): CI lint block PR。bypass 入 prod:第 5 个 MUSIC key 触 Rule 5 fallback,prod 静默,KPI 演出无音乐(P1)。
- **If 普通 UI 按钮赋非机械音(Rule 4 违反,lint 漏)**: Audio Manager 不审内容,正常 dispatch。Pillar 4 守门职责在 Rule 10 Layer C lint — `SFX.UI.*` 类 asset 修改须 audio-director review。Rule 4 唯一合法 UI SFX 白名单(`PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC`)须 lint 枚举验证。

### 9. Performance / Pillar 5

- **If 启动 preload 超 200 ms(HDD + AV 扫描)**: CI smoke check 标准 testbed 断言 ≤ 200 ms。HDD 已知慢路径 — Production build 须 Loading Scene 显示 progress indicator(非黑屏)。稳定超限触发拆分 lazy-load(配乐分离按 Rule 5 lazy-load ADR)。HDD 玩家 Pillar 5 5 秒承诺靠 Loading Scene 视觉进度条救场。[OQ-AUD-01]
- **If LRU 驱逐期间正在播放 SFX 突然停止(pop artifact)**: 被驱逐 `AudioStreamPlayer` 立即 `stop()` → 实时音频突然截断产生 click/pop。Mitigation: 被驱逐 slot 在停止前淡出 `EVICTION_FADE_MS = 30 ms`(人耳 pop 阈值以下)。30 ms 淡出不阻新 SFX。[OQ-AUD-05] 须 ADR 确认。
- **If `MAX_CONCURRENT_SFX = 8` 在病态 100+ 并发**: 池固定 8 slot,LRU 驱逐,无动态 allocation(Rule 8 "`new()` per call 禁止")。100+ 并发内存不增长,OOM 风险不存在。CPU 开销:100 × hash lookup + LRU update ≈ 可忽略。实际游戏 100+ 同帧 SFX 是上层 bug。

### 10. OS / Hardware

- **If 输出设备切换(耳机插拔 / 蓝牙断连)**: Godot 4.6 `AudioServer` 内部重初始化,期间 0.1–0.5 s 静音。Audio Manager 不需特殊处理 — `AudioStreamPlayer` 节点自动恢复;Music Tween / Ambient duck 状态内存不变。预期短暂静音 + 自动恢复。[OQ-AUD-06]
- **If 多输出设备(主扬 + 耳机)**: Godot 4.6 默认单主输出路由(OS 决定)。Audio Manager 不实现多路由(MVP scope + Pillar 5 反 8D 环绕)。OS 决定;Audio 透明。WASAPI / PulseAudio 行为差异需 ADR。[OQ-AUD-01]
- **If 系统级静音 vs Master 静音**: 系统静音 OS 层截断,Godot AudioServer 仍 compute(只是硬件无输出)。所有信号(`bus_volume_changed` / `audio_event_played`)仍 emit,功能完整(Rule 9)。两者正交,无需协调。
- **If 数字音频驱动崩溃**: Godot AudioServer 崩溃属引擎级,非 Audio Manager 可 catch 范畴。游戏可能崩或静默。Audio Manager graceful-fail 范围: missing asset → Rule 5 fallback / pool exhaustion → LRU / LOADING 卡死 → watchdog R-AUD-3。驱动级超 GDD scope,escalate godot-specialist + technical-director。**[RISK GUARD — R-AUD-5]**: Master = -∞(静音)时游戏关键信息仅 audio 传违反 art-bible §7.4 听觉双重编码 — 守门"静音下信息可达"。AC 须断言:Master = -60 dB 下 overtime / KPI pass / GAME OVER 全视觉路径功能完整。

### 新增 Open Questions(OQ-AUD-01..06)

| ID | 问题 | Owner | 目标 |
|----|------|-------|------|
| OQ-AUD-01 | BGM loop 时长 lint 实现 / `MUSIC_TRACK_MAX` 检测细节 / SFX priority class 实现 / 多输出设备 WASAPI 行为 / lazy-load "2 帧保证"机制 | audio-director + godot-specialist | ADR 阶段 |
| OQ-AUD-02 | `_BUREAUCRATIC` 孤立 key 警告 vs sound-designer 3 变体缺失 lint 策略 / 同帧多次 play_sfx 同 key 调用方 contract | audio-director + sound-designer | Sound Design Brief |
| OQ-AUD-03 | LOADING 期 `set_bus_volume` 直接写内存表 vs 排队 / Save 恢复信号与 Audio LOADING 启动序列时序须 Scene Flow GDD 协调 | systems-designer + game-designer | Scene & Day Flow #6 GDD |
| OQ-AUD-04 | Ambient duck release 800 ms 与演出时长关系(audio-director brief)/ 多重 crossfade 取消策略边界 | audio-director + systems-designer | Audio ADR |
| OQ-AUD-05 | LRU 驱逐 pop artifact `EVICTION_FADE_MS = 30 ms` 是否足 / 备选 lazy eviction(优先驱逐已播完 SFX) | audio-director + sound-designer | 首测 build 主观听测 |
| OQ-AUD-06 | Godot 4.6 `WM_WINDOW_FOCUS_OUT` 是否触发 AudioServer 自动静音 / Audio fade 与 Input `reset_all_action_presses` 时序联合测试 | godot-specialist + qa-lead | Godot 4.6 API 验证 + Integration test |

**5 [RISK GUARD] 总览**:

| RISK GUARD | 保护目标 | 对齐系统 |
|---|---|---|
| R-AUD-1 | `_BUREAUCRATIC` 锚点 key 缺失(月末打卡机) | Localization R-LOC-1 CSV 缺失 |
| R-AUD-2 | `MUSIC_TRACK_MAX` lint(防音乐蔓延) | Localization R-LOC-5 IRONY 守门 |
| R-AUD-3 | LOADING watchdog(Pillar 5 永久卡死) | Localization R-LOC-3 locale lock watchdog |
| R-AUD-4 | SFX 池 CRITICAL priority(关键 SFX 不被 LRU 驱逐) | (新增,无直接对等) |
| R-AUD-5 | Master = -∞ 信息双重编码(art-bible §7.4) | Localization R-LOC-4 IRONY tone 守护 |

## Dependencies

### Upstream Dependencies(本系统依赖)

**None structurally.** Audio Manager 是 Foundation Layer 根节点,仅依赖 Godot 4.6 引擎 API(`AudioServer` / `AudioStreamPlayer` / `AudioStream` / `AudioStreamRandomizer` / `Tween` / `NOTIFICATION_WM_WINDOW_FOCUS_OUT` / `ResourceLoader` 等)和 art-bible §2 时钟光语 + §7.4 即时反馈铁则的 UX 约束。

**软依赖**(不阻 Audio 核心功能但提供必要数据流):
- **Save System #1**(bidirectional via Rule 2 signal): Audio 启动时由 Scene & Day Flow 协调从 Save 读 4 bus 音量配置 → Audio 运行时 emit `bus_volume_changed` → Save 订阅按 Rule 14 写入。无 Save,Audio 仍可运行(每 session 重置默认 dB)。

### Downstream Dependents(依赖本系统的)

| # | System | Tier | Type | Interface(摘要) | 反向文档 | 必要 |
|---|--------|------|------|--------------------|---------|------|
| 1 | **Save System** | MVP / Foundation | **Hard** | `bus_volume_changed(bus_id, db)` 信号 → Save 防抖写 meta;启动期 Save 提供 `meta.save.settings.audio` payload 注入(4 bus dB 配置) | ✅ Save Rule 14 显式包含设置类 meta(音量 / 语言 / gamepad 布局 / 叙事密度);Audio 是 `meta_settings_debounce_ms` 第三消费者(Save / Input / Localization 之后) | ✅ 必须 |
| 6 | **Scene & Day Flow Controller ⭐** | MVP / Core | **Hard** | 启动调度 `AudioManager.preload_bank()` + `mark_ready()`(Rule 5 + States);场景切换调 `play_ambient(scene_id)`;演出 `play_music` / `stop_music`;`kpi_review_started` / `game_over_triggered` / `scene_state_changed` 信号触发 Music sub-mode 切换;LOADING watchdog 30s 强制 override(R-AUD-3 守门) | 未设计 — #6 GDD 须列入 Audio 启动序列 + `mark_ready()` 私有调用授权 + watchdog 行为 + `set_bus_volume` LOADING 期时序契约(OQ-AUD-03) | ✅ 必须 |
| 13 | **HUD System (Diegetic)** | MVP / Presentation | Soft | 调 `play_sfx(event_id)` 触发 `SFX.UI.*` / `SFX.ENVIRONMENT.*` events;不持有 AudioStreamPlayer 引用 | 未设计 | ✅ MVP 必须 |
| 14 | **Card Play & Dialogue UI** | MVP / Presentation | Soft | 调 `play_sfx` 触发 `SFX.CARD.*` 系列(round-robin 3 变体: DRAW_SELECT / CONFIRM / PLAY_ERROR) | 未设计 | ✅ MVP 必须 |
| 15 | **Daily / Weekly Recap UI** | MVP / Presentation | Soft | 调 `play_sfx` 触发 `SFX.RECAP.*`(WEEKLY_REPORT_REVEAL / MONTHLY_NOTICE_REVEAL / ENDGAME_LETTER_PRINT)+ 跨日 `SFX.TRANSITION.DAY_CHANGE` | 未设计 | ✅ MVP 必须 |
| 16 | **KPI Review & Game Over UI** | MVP / Presentation | Soft | 调 `play_music("MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC")` 月末演出期间;`play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC" + "RECEIPT_THERMAL_HISS_BUREAUCRATIC")` 月末通过结算;`play_music("CREDITS_OUTRO_BUREAUCRATIC")` GO 片尾;**反讽锚点同质 tone**(配 Localization `GAMEOVER.TITLE_IRONY`) | 未设计 — **#16 GDD 必含 `_BUREAUCRATIC` audio tone 守门 + R-AUD-1 锚点 key 缺失测试** | ✅ MVP 必须 |
| 17 | **Main Menu / Pause / Settings UI** | MVP / Presentation | **Hard** | `set_bus_volume(bus_id, db)` / `get_bus_volume(bus_id)` / `mute_all()` / `unmute_all()` 接口;**3 旋钮**(SFX / Music / Ambient,**不暴露 Master**)+ 推荐 300 ms debounce(防 Edge 4.2 same-frame double-tap race,沿用 Localization 立场) | 未设计 — #17 GDD 须列入 Audio 音量设置屏 + 旋钮 UI + 300 ms debounce + 旋钮**无 SFX 反馈** | ✅ 必须 |
| 18 | **Tutorial / Onboarding** | VS / Feature | Soft | 调 `play_sfx` 教学步骤 audio cue(若有,可能选用既有 SFX,不新增 audio asset)| 未设计(VS 推迟) | 可推迟 VS |
| 20 | **Accessibility Options** | Alpha / Polish | Soft | 字幕替代音频(audio caption / sound visualizer 文本 toast 替代关键 audio 信号)— 与 Rule 9 art-bible §7.4 听觉双重编码扩展 | 未设计(Alpha 推迟) | 可推迟 Alpha |

### 双向一致性核对(coding-standards 强制规则)

**已 Approved 的 GDD 反向一致性**:
- **Save System (#1)** ✓ — Save Rule 14 显式含设置类 meta(音量),bidirectional consistent via registry `meta_settings_debounce_ms`
- **Input Handler (#2)** ✓ — Input Section G "零音频要求"声明已锁(Audio Rule 11 测试断言: `InputHandler` 信号序列 → Audio 无 `play_*` 触发)
- **Localization Hooks (#3)** ✓ — Localization Visual/Audio 节"零音频要求"声明已锁(Audio Rule 11 测试断言: `set_locale(any)` → Audio 无 `play_*` 触发)

**未设计的 7 个下游 GDD,编写时各自必须**:
1. 自身 Dependencies 章节列入 **"Audio Manager (#4)"** 作为 dependency
2. 引用本 GDD **Rule 3** event key naming(`BUS.DOMAIN.IDENTIFIER[_BUREAUCRATIC|_VARIANT]`)
3. 引用本 GDD **Rule 4** Pillar 4 红线禁 SFX/BGM 类型
4. 引用本 GDD **Rule 9** 静音功能完整性合约(art-bible §7.4 听觉等价)
5. 引用本 GDD **Rule 11** 零音频契约(若是 Input/Localization 路径相关 UI)
6. **#16 KPI Review & Game Over UI** 须实现 `_BUREAUCRATIC` 锚点 key 调用 + Pillar 4 听觉验证(对齐 Localization `GAMEOVER.TITLE_IRONY` tone 同质守护)
7. **#17 Main Menu** 须实现 3 音量旋钮(SFX / Music / Ambient,**不暴露 Master**)+ 300 ms debounce + 无 SFX 反馈
8. 凡涉及 KPI / 月末 / GO 演出的 UI(#15/#16)调 `play_music` / `play_sfx _BUREAUCRATIC` event 须 audio-director 联合 review

### 跨 GDD 影响清单(若本 GDD 后续 revise,以下系统须重审)

- **Save System #1** — `meta.save.settings.audio` schema 变更 → 影响 meta.save schema_version(Save `current_schema_version` registry 须 bump)
- **Scene & Day Flow #6** — `mark_ready()` 调用 / `kpi_review_started` 信号 / `game_over_triggered` 信号契约变更 → 影响演出序列
- **Main Menu #17** — `set_bus_volume` / `get_bus_volume` / `mute_all` / `unmute_all` 接口 + 旋钮 UI
- **HUD #13 / Card #14 / Recap #15 / KPI Review #16** — `play_sfx` event_id 命名变更 → 触 Rule 10 deprecated 流程(类 Localization Rule 10)
- **任何引入新 Bus / Audio domain**(如 `VOICE.` / `HAPTICS.` / `MUSIC.AMBIENT.`)— Rule 1/3 白名单扩展须先改本 GDD
- **Audio asset 命名 schema 变更** — 影响 sound-designer 资产清单 + lint 规则
- **art-bible §2 时钟光语 / §7.2 修订** — Rule 6 ambient layer schema 同步

## Tuning Knobs

### Numeric Knobs(本 GDD 内部 owning)

| Knob | Default | Safe Range | 极端行为 | 来源 |
|------|---------|------------|---------|-------|
| `MAX_CONCURRENT_SFX` | 8 | [4, 16] | <4: SFX 易丢致玩家感知缺失 / >16: GC 压力 + 内存翻倍 | Rule 8 |
| `MAX_CONCURRENT_AMBIENT` | 2 | [1, 4] | =1: 不能 day + overtime 叠层 / >4: 浪费(MVP 仅 day/overtime 两层) | Rule 8 |
| `MUSIC_PLAYER_COUNT` | 2(固定) | (硬常量) | crossfade 双槽必需,不可调 | Rule 8 |
| `audio_preload_budget_ms` | 200 | [100, 500] | <100: HDD/AV 环境 CI 频繁 FAIL / >500: 破 Pillar 5 5 秒进入承诺 | Rule 5 |
| `audio_bank_total_size_mb` | 30 | [15, 50] | >50: 可能破 RAM 预算(art-bible §8.5 显存等价约束) / <15: MVP scope 受限 | Rule 5 |
| `ambient_duck_release_ms` | 800 | [400, 2000] | <400: 突兀感 / >2000: duck 滞后,Music 与 Ambient 长期叠放 | Rule 1 |
| `bgm_loop_length_max_sec` | 120 | [60, 240] | <60: loop 太短听感重复 / >240: 玩家暂停 / 关 app 时延 | Rule 7 |
| `MUSIC_TRACK_MAX` | 4(硬常量) | (硬常量) | 防音乐蔓延 — Pillar 4 守门;变更须 game-designer + audio-director 双批改本 GDD | Rule 10 / R-AUD-2 |
| `AUDIO_LOADING_WATCHDOG_MS` | 10000 | [5000, 30000] | <5000: 合法长 preload 误触 / >30000: Scene Flow bug 卡死延数十秒 | Edge 3.5 / R-AUD-3 |
| `EVICTION_FADE_MS` | 30 | [10, 100] | <10: pop artifact 残留 / >100: 截断感 / 新 SFX 启动延 | Edge 9.2 / OQ-AUD-05 |

### Empirical Constants(实测,非 designer 调整)

| Constant | Default | 来源 | 变更触发 |
|---------|---------|------|---------|
| `T_dispatch` | ≤ 1 ms | `play_*()` 调用 + `AudioServer` API 基线 | MVP CI profiling 偏离 >50% 触发 OQ |

### Bus Default dB Table(已在 Rule 1,此处引用)

| Bus | Default dB | 玩家可调 | 范围 |
|-----|-----------|---------|------|
| Master | 0 dB | 不可调(系统只读 + 硬件限幅) | 固定 |
| SFX | -6 dB | 可调 | [-60, 0] |
| Music | -9 dB | 可调 | [-60, 0] |
| Ambient | -12 dB | 可调 | [-60, 0] |

**步进**: 1 dB。**重置默认按钮**: 调 `AudioManager.reset_to_defaults()` 触 `bus_volume_changed` 流。

### 跨 GDD Tuning Knob(引用,不 owning)

| Knob | Owner GDD | Value | 与 Audio 关系 |
|------|-----------|-------|---------------|
| `meta_settings_debounce_ms` | Save (#1) Rule 14 | 500 ms | Audio `bus_volume_changed` 信号触发 Save 防抖窗口;Audio 是该 contract 第三消费者(Save / Input / Localization 之后) |
| Settings 选择器 debounce | Main Menu (#17)(未设计) | 300 ms(本 GDD 推荐 default,沿用 Localization 立场)| 防 Edge 4.2 same-frame double-tap race;Audio Rule 8 处理同帧双调但 UI 一侧亦须 debounce |

### Audio Asset Catalogue(指向 `assets/audio/`,非 knob)

29 条 MVP 资产由 sound-designer 交付,按 Bus 分类列于 `assets/audio/{ambient,sfx,music}/`。**本 GDD 不重复列**全清单(类似 Localization CSV 是 string key source of truth);domain 摘要分布(产量规划用,非强制契约):

| 类别 | 数量 | 总体积估 | 制作策略 |
|------|------|---------|---------|
| **AMBIENT**(loop + overlay) | 6 + 1 overlay | ~103 KB(.ogg q=4) | freesound CC0 + EQ filter |
| **SFX**(diegetic UI / event / environment) | 20(含 3 round-robin × 3 = 9 + 11 fixed) | ~142 KB(.wav 16-bit) | 自录 punch clock + 热敏 / 其余 freesound CC0 + Pro |
| **MUSIC**(关键时刻配乐) | 2 | ~270 KB(.ogg q=5,90s + 45s) | 自录 OR Freesound Pro 行政流程音化 curation,license OQ-AUD-defer |
| **TOTAL** | **29** | **~520 KB on disk / ~1.2 MB RAM** | **<<30 MB hard cap** |

**关键 `_BUREAUCRATIC` 锚点 key 清单**(必须存在 - R-AUD-1 守门):

| Key | Bus | Tone 锚 |
|-----|-----|--------|
| `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC` | SFX | 月末打卡机咔哒 — Player Fantasy 锚点 |
| `SFX.UI.RECEIPT_THERMAL_HISS_BUREAUCRATIC` | SFX | 月末收据热敏嘶 — Player Fantasy 锚点 |
| `SFX.RECAP.ENDGAME_LETTER_PRINT` | SFX | GO 信件打印(片尾字幕同步) |
| `MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC` | Music | 月末考核 BGM(行政流程音化) |
| `MUSIC.GAMEOVER.CREDITS_OUTRO_BUREAUCRATIC` | Music | GO 片尾(art-bible §2.6 片尾曲对应) |

### Pillar 4 红线禁止资产清单(对齐 Rule 4)

`assets/audio/` 库**绝不应出现**以下 8 类 SFX(human review + lint 第二防线):

1. **成就音**: 三段上升音符 / "叮 - 成就解锁"reward stinger
2. **升级提示音**: "叮咚"双音上滑 / 英雄主题 leitmotif 变体
3. **完美 timing 反馈**: rhythm game "perfect / great" 单音
4. **庆祝 fanfare**: 烟花声 / 欢呼声 / 鼓掌 loop / "任务完成 ✓" 叮声
5. **手柄检测庆祝音**: "已检测到 Xbox 手柄" 欢迎语 / 连接成功音
6. **语言切换音**: "已切换中文配音 ✓" 提示音(Localization Visual/Audio 零音频)
7. **Save / Load 读写音**: "嗖咻" 存档动画 SFX / 数据传输 whoosh(Input Section G 零音频)
8. **升职 / 加薪 fanfare**: 任何英雄主题 / 励志弦乐上行(对齐 Localization `_IRONY` tone 反讽锚点)

**例外白名单**(仅 2 条 UI SFX 合法):
- `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC`(月末通过结算 — 行政流程音,非庆祝)
- `SFX.UI.RECEIPT_THERMAL_HISS_BUREAUCRATIC`(月末评级打印 — 同上)

**禁** 普通 UI 导航 / 焦点切换 / `act_confirm` / `act_cancel` 触发任何 SFX(Rule 9 + Section B Tone 锚)。

## Visual/Audio Requirements

Audio Manager 本身是 audio 的 owner —— audio 资产清单见 Section G(29 条 MVP assets,sound-designer 交付)。本节聚焦 **Audio ↔ Visual 契约**:Rule 9 静音功能完整性的视觉等价路径,以及关键时刻 audio 与视觉的同步协议。

### Audio 不 own 的 visual 制品(声明引用)

| 制品 | Owner GDD | 与 Audio 关系 |
|------|-----------|--------------|
| `_overtime` sprite variant + CanvasModulate 蓝光 | art-bible §2 + #6 Scene Flow | Rule 9 静音守门:overtime 视觉**独立**呈现,Audio `SCREEN_BUZZ_OVERTIME` 增强非必需(AC-ROBUST-05) |
| 收据热敏打印动画 | art-bible §7.4 + #16 KPI Review UI | Rule 9 静音守门:KPI 通过结算视觉**独立**可读,Audio `RECEIPT_THERMAL_HISS_BUREAUCRATIC` 增强非必需 |
| GAME OVER 字幕红字 + UI 进度条 | art-bible §2.6 + #16 KPI Review UI | Rule 9 静音守门 + Music `CREDITS_OUTRO_BUREAUCRATIC` 与字幕同步,但字幕**独立**可读 |
| 6 MVP 场景视觉变体(`_day` / `_overtime`) | art-bible §2 + #6 Scene Flow | Rule 6 ambient layer schema 视觉对应锁 — audio 与 visual 双轨同步,均不可单独传达场景状态 |
| `act_pause` 暂停视觉 UI | #17 Main Menu / Pause UI | Rule 8 + Edge 7 audio fade 协议(Music→-∞ 200ms / Ambient→-24 300ms)与暂停 UI 同步 |

### Audio Asset Spec Flag

> 📌 **Asset Spec** — 本系统 audio asset 清单已在 Section G(29 entries),关键 `_BUREAUCRATIC` 锚点 key 5 条已锁(Section G "关键锚点"表)。**Phase 4 Pre-Production 阶段须运行 `/asset-spec system:audio-manager`** 由 sound-designer 产出每个 asset 的具体录制 / 编辑 / 导入参数 brief(对齐 Localization `tools/i18n_lint.py` 模式 — Audio 用 `tools/audio_lint.gd` Editor Tool)。Stories 引用 audio 资产时须 cite `production/audio-briefs/[event_id].md`(待 sound-designer 交付),而非本 GDD。

### 跨 GDD Visual/Audio 同步契约

- **#16 KPI Review UI** GDD 须实现:
  - `GAMEOVER.TITLE_IRONY` Label(站酷快乐体 14 px,对齐 Localization Rule 9)与 Audio `MUSIC.GAMEOVER.CREDITS_OUTRO_BUREAUCRATIC` 同步播放窗口(片尾曲 ≤ 字幕完整呈现时长)
  - 收据热敏打印视觉动画时长 ≈ Audio `SFX.UI.RECEIPT_THERMAL_HISS_BUREAUCRATIC`(~2.0 s),误差 ≤ 200 ms
  - Pillar 4 反讽锚点 audio + visual 同质 tone 验证(AC-COMPAT-04 跨系统联测)

- **art-bible §2 时钟光语**:
  - 6 场景视觉状态(主菜单 / 早晨 / 白天 day / 白天 overtime / 下班 / 总结 / 月末)与 Rule 6 ambient layer schema **1:1 对应**
  - art-bible §2 修订须 cascade 至本 GDD Rule 6(双向 cross-check)

**零额外 visual asset 创作要求** — Audio Manager 不引入任何 visual sprite / animation / shader。所有 visual 配套已由 art-bible / #6 / #16 / #17 各自 GDD 拥有。

## UI Requirements

Audio Manager 不 own UI 屏。**唯一 UI 接触面**是 Main Menu / Pause / Settings UI(#17)的**音量设置子屏** —— 该屏由 #17 GDD 规划,本 GDD 仅锁数据契约:

- **3 个独立音量旋钮**: SFX / Music / Ambient(**不暴露 Master**,Master 系统只读 + 硬件限幅用)
- 旋钮值域 [-60, 0] dB,步进 1 dB,默认值: SFX -6 / Music -9 / Ambient -12 dB
- `set_bus_volume(bus_id, db)` / `get_bus_volume(bus_id)` / `mute_all()` / `unmute_all()` / `reset_to_defaults()` 接口由 #17 调用
- `bus_volume_changed(bus_id, db)` 信号由 #17 订阅刷新 slider(用于多开设置窗口同步,MVP 无此需求但已暴露)
- **300 ms 旋钮拖动 debounce**(本 GDD 推荐 default,#17 实现)—— 防 Edge 4.2 same-frame double-tap race;沿用 Localization Hooks #17 同模式
- **无 SFX 反馈**: 旋钮拖动 / 重置默认 / mute_all 调用绝不触 `play_sfx`(Pillar 4 + Rule 9 + Section B Tone 锚 — 同 Save / Input / Localization 系列)
- **无 Master 旋钮**: #17 UI 即使有"全静音" toggle 也是 `mute_all() / unmute_all()` 接口,UI 显示为"静音"开关(逻辑独立于 Master Bus dB 管控)

> **📌 UX Flag — Audio Manager**: 音量设置 UI 在 Phase 4(Pre-Production)阶段须由 `/ux-design design/ux/settings-screen.md`(配 #17 Main Menu GDD 一并产出)同步规划,与 Localization 语言设置子屏共用同一 UX 文档。包括: 3 旋钮布局 + 步进交互 + mute toggle + 重置默认按钮 + 旋钮预览(测试音播放?**禁** — Pillar 4 红线,无"测试播放"功能,玩家拖动后听运行环境即时反馈)。stories 引用 UI 时须 cite `design/ux/settings-screen.md`,而非本 GDD。

### 与 Localization Hooks #17 UI 共用

Localization Hooks #3 + Audio Manager #4 共享 #17 Settings UI 屏(语言设置子屏 + 音量设置子屏)。两者**共同**的 UX 约束:
- 300 ms 选择器 / 旋钮 debounce
- 无 SFX 反馈(对齐零音频契约)
- Save 防抖路径 `meta_settings_debounce_ms = 500 ms`(两者均为该 contract 消费者)
- 设置屏入口由 #17 GDD 自定义(可能合并为"设置"主页签 + 子标签或分开屏,UX 决定)

## Acceptance Criteria

26 条 AC 分 5 类: AC-FUNC 11 / AC-PERF 3 / AC-COMPAT 4 / AC-ROBUST 5 / AC-TONE 3。**5 [RISK GUARD]** AC(AC-ROBUST-01..05)守门 R-AUD-1..5 高风险路径,须在首个可测 build 优先验证。AC-TONE category 沿用 Localization Section H 引入(Pillar 4 tone 守护类)。

### ADR-0001 跟进追加(B-DEP-2 守门)— 2026-04-28

- **AC-FAREWELL-01**(`#10 Rule 23` FAREWELL_EVENT_IDS 禁 BGM 切换契约): **GIVEN** AudioManager READY,当前 BGM(如 `BGM.OFFICE_DAY`)正在播放,debug 钩子拦截 `play_bgm` / `cross_fade_bgm` / `AudioStreamPlayer.stream` 赋值, **WHEN** `event_started(event_id, narrative_tier)` 信号到达且 `event_id ∈ EventScriptEngine.FAREWELL_EVENT_IDS`(LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF / GRIND_KING_PROMOTED_LEAVE / OLD_OIL_OPTIMIZED_OUT), **THEN** BGM 切换调用计数 = 0(继续当前 ambient,Pillar 4 红线);若任何 BGM 切换发生 → `push_error("ERR_AUD_FAREWELL: BGM switch forbidden during farewell event")` + CI FAIL;`tools/farewell_lint.gd` PR 阶段比对 `#10 FAREWELL_EVENT_IDS` 与本 GDD AC 引用一致 → 不一致 BLOCK PR。**Tier**: MVP。

### AC-FUNC (功能性)

- **AC-FUNC-01** (Rule 1 Bus 架构 — 4 Bus 默认 dB + Master 只读): **GIVEN** `AudioServer` 通过 `AudioManager._ready()` 完成初始化, **WHEN** QA 在 debug build 调 `get_bus_volume(&"Master"/&"SFX"/&"Music"/&"Ambient")`, **THEN** 返回值依次 0 / -6 / -9 / -12 dB;调 `set_bus_volume(&"Master", -3.0)` 不改 Master dB(返回 no-op 或 `push_error("ERR_AUDIO: Master bus is read-only")`)且 `bus_volume_changed` 信号不发射;3 条可调 Bus 调 `set_bus_volume` 后 `bus_volume_changed` 各发射一次。

- **AC-FUNC-02** (Rule 2 信号边界 — 零直调 Save / FileAccess): **GIVEN** debug 钩子对 `SaveSystem.write_meta` 和 `FileAccess.open` 调用计数, **WHEN** 玩家将 SFX Bus 从 -6 dB 调至 -12 dB, **THEN** `AudioServer.set_bus_volume_db` 同帧调用;`bus_volume_changed(&"SFX", -12.0)` 信号恰好发射一次;`SaveSystem.write_meta` 和 `FileAccess.open` 在该帧调用计数**不增加**;500 ms 后 `meta.save` mtime 更新(Save Rule 14 防抖落盘,验信号契约端到端)。

- **AC-FUNC-03** (Rule 3 Audio event key 命名空间 — `tools/audio_lint.gd` 合规验证): **GIVEN** `tools/audio_lint.gd` 在 `assets/audio/` 和事件注册表上运行, **WHEN** 注册表含合法 key `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC`、违规 `SFX.UI.SOUND_01`(数字)、违规 `ambient.office.fluorescent_hum`(小写)、非白名单 Bus `VOICE.NPC.HELLO`, **THEN** 合法 key 不报错;`SOUND_01` 报 FAIL `"ERR_KEY_NAMING: numeric identifier"`;小写报 FAIL `"ERR_KEY_NAMING: lowercase not allowed"`;`VOICE` 报 FAIL `"ERR_KEY_NAMING: unknown bus namespace [VOICE]"`;CI 阻塞。

- **AC-FUNC-04** (Rule 4 Pillar 4 红线 — 禁止 event_id 在注册表中存在): **GIVEN** `tools/audio_lint.gd` 扫描事件注册表 + `assets/audio/sfx/`, **WHEN** lint 枚举全 `SFX.*` event key, **THEN** 含 `ACHIEVEMENT` / `UNLOCK` / `LEVEL_UP` / `FANFARE` / `PERFECT` / `GREAT` / `VICTORY` / `CONGRAT` / `REWARD` 字样的 SFX key **任一变体均不存在**;每发现报 FAIL `"ERR_PILLAR4_VIOLATION: forbidden SFX type in registry: [KEY]"`;唯一例外: `PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC`(必须存在,缺另触 R-AUD-1)。

- **AC-FUNC-05** (Rule 5 LOADING → READY 状态机 + `_mark_ready()` 私有性): **GIVEN** Scene Flow 在 Loading Scene 内调 `preload_bank()` 后调私有 `_mark_ready()`, **WHEN** `_mark_ready()` 由非 Scene Flow 节点调用, **THEN** GDScript 报 `"Method not found"` 或 `push_error` 阻止;AudioManager 保持 LOADING 态;合法 Scene Flow 调用后入 READY,`audio_manager_ready` 信号一次;LOADING 期 `play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC")` 静默丢弃 + dev warning;LOADING 期 `play_ambient("OFFICE_DAY")` 进 size=1 pending queue,`_mark_ready()` 同帧 flush。

- **AC-FUNC-06** (Rule 6 环境音叙事化 — 场景状态切换 ambient layer 正确): **GIVEN** AudioManager READY, **WHEN** Scene Flow emit `scene_state_changed(DAY)` 后 emit `scene_state_changed(OVERTIME)`, **THEN** DAY 触发: `FLUORESCENT_HUM` 以 -12 dB 播,`KEYBOARD_RHYTHM` crossfade 入 ≥ 0.5 s 不突变,`AC_LOW_HISS` 继续;OVERTIME 触发: `SCREEN_BUZZ_OVERTIME` 以 -10 dB 渐入 ≥ 2 s 无 stinger,`KEYBOARD_RHYTHM` 不中断;overtime 切换**不触发** `play_music`(debug 钩子断言 Music Bus 状态前后均 IDLE,Pillar 4 守门)。

- **AC-FUNC-07** (Rule 7 配乐白名单 — 仅 2 类 BGM 时刻): **GIVEN** AudioManager READY,Music sub-mode IDLE, **WHEN** Scene Flow emit `kpi_review_started`, **THEN** Music fade in 1.5 s 至 -9 dB;Ambient 全层 duck -6 dB;sub-mode → KPIREVIEW;`music_track_changed` 信号(若订阅);debug 钩子断言注册表**不含**非 `KPIREVIEW` / `GAMEOVER` domain 的 `MUSIC.*` key(穷举验"绝不有 BGM 时刻");KPI 演出结束后 Ambient 在 800 ms 线性回位,Music fade out -∞,sub-mode 回 IDLE。

- **AC-FUNC-08** (Rule 8 dispatch ≤1 帧 + SFX 池 LRU + `new()` 禁止): **GIVEN** Profiler 开启,READY 态,debug 钩子监 `new()` 调用, **WHEN** 连续触发 500 次 `play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC")`, **THEN** 每次主线程开销 ≤ 16.6 ms;池固定 8 slots,满时 LRU 驱逐最久空闲 non-CRITICAL slot;`AudioStreamPlayer.new()` 调用计数**为 0**(pool 预分配,GC 零压);每次重用已有 slot。

- **AC-FUNC-09** (Rule 9 静音功能完整性 — Master = -60 dB 下信息视觉独立可达): **GIVEN** 三可调 Bus 全 -60 dB(等效 Master = -∞), **WHEN** QA 依次触发: overtime 切换 / KPI 通过 / GAME OVER, **THEN** overtime: `_overtime` sprite + 蓝光 CanvasModulate 独立呈现;KPI: 收据热敏打印动画播放,结算文本视觉可读;GAME OVER: 字幕红字 + 进度条运行;`bus_volume_changed` / `audio_event_played` / `music_track_changed` 信号在全静音下**仍照常 emit**(信号物理音频解耦)。

- **AC-FUNC-10** (Rule 11 零音频契约 — Input / Localization 信号路径无 `play_*` 触发): **GIVEN** debug 钩子对 `play_sfx` / `play_ambient` / `play_music` 调用计数归零, **WHEN** (a) `InputHandler` emit 全信号序列(`act_confirm` / `act_skip` / `act_pause` / `keymap_changed` / `device_disconnected` / `device_reconnected`);(b) `LocalizationHooks.set_locale(&"zh_CN")`, **THEN** (a)(b) 后 Audio `play_*` 调用计数仍为 0;debug 断言 AudioManager `connect()` 列表不含 Input / Localization 信号。

- **AC-FUNC-11** (Rule 8 + Edge 7 暂停 / 焦点失 — `act_pause` 与 `WM_FOCUS_OUT` 共版 fade 协议): **GIVEN** AudioManager READY,Music sub-mode KPIREVIEW(Music Bus 播放中),Ambient Bus 活跃, **WHEN** Scene Flow emit `act_pause`(玩家暂停)**或** `NOTIFICATION_WM_WINDOW_FOCUS_OUT`(Alt-Tab / Steam overlay),随后 emit 退出条件(`act_pause` 退出 / `NOTIFICATION_WM_WINDOW_FOCUS_IN`), **THEN** 进入: Music Bus 在 200 ms 内线性淡至 -∞ dB;Ambient Bus 在 300 ms 内线性淡至 -24 dB;两 fade 均 Tween 线性,无突变;退出: Music / Ambient 在 200 ms 内回前值;fade 期 `bus_volume_changed` 仅 Tween 起 / 终发射(非按帧)。**两触发器同行为**(Edge 7 修正后一致)。

### AC-PERF (性能 / Pillar 5 预算)

- **AC-PERF-01** (Rule 5 preload ≤ 200 ms — CI smoke check blocking): **GIVEN** 时钟桩在 Loading Scene `preload_bank()` 调用前后打点,fixture 标准 audio bank(29 asset, ~520 KB on disk), **WHEN** `preload_bank()` 在 Loading Scene 内执行(不计入 5 秒进入窗口), **THEN** 实测 < 200 ms;超时 CI smoke check FAIL `"ERR_AUDIO_PRELOAD: preload_bank exceeded 200ms — actual=[N]ms"`;preload 完成后 `ResourceLoader` 对 29 key 的 `has_cached` 返回 true;gameplay `_process` / `_input` 帧无 `ResourceLoader.load()` 调用(debug 钩子断言加载调用计数 READY 后 = 0,lazy-load BGM 按 ADR 例外)。

- **AC-PERF-02** (Rule 5 `audio_bank_total_size_mb ≤ 30 MB` lint 守门): **GIVEN** `tools/audio_lint.gd` 统计 `assets/audio/` 目录 audio asset on-disk 总大小, **WHEN** lint 在 CI PR branch 执行, **THEN** ≤ 30 MB lint PASS;> 30 MB lint FAIL `"ERR_AUDIO_BANK_SIZE: audio bank [N]MB exceeds 30MB cap"`;CI 阻塞;dev build 本地 lint 仅 WARNING 级;lint 区分 on-disk vs preload RAM 估算(注释级,不阻)。

- **AC-PERF-03** (Rule 8 runtime dispatch ≤1 帧 — p99 主线程): **GIVEN** Profiler 开启,READY 态,60 FPS 稳定, **WHEN** 连续调 1000 次混合 dispatch(`play_sfx` × 400 + `play_ambient` × 300 + `play_music` × 300,全有效 event_id), **THEN** 每次 API 入口 → `AudioStreamPlayer.play()` 触发主线程耗时 p99 < 16.6 ms;零调用使用 `call_deferred`(日志断言 AudioManager 内无 `call_deferred` 调用);`AudioServer` 异步硬件混音不计帧预算。

### AC-COMPAT (跨设备 / 跨系统)

- **AC-COMPAT-01** (Rule 2 + Save 启动注入 — `load_bus_volumes` 持久化契约): **GIVEN** Save `meta.save.settings.audio` 含 `{SFX: -18.0, Music: -20.0, Ambient: -24.0}`,Scene Flow 启动序列调 `AudioManager.load_bus_volumes(payload)`, **WHEN** `load_bus_volumes` 执行, **THEN** `AudioServer.get_bus_volume_db` 对 SFX / Music / Ambient 分别返 -18.0 / -20.0 / -24.0;Master 不变(0 dB);`bus_volume_changed` 在 load 期**不发射**(静默加载,不触 Save 防抖二次写);READY 后玩家 `set_bus_volume` 修改时 `bus_volume_changed` 正常发射。

- **AC-COMPAT-02** (Rule 6 Ambient duck Tween + release `ambient_duck_release_ms = 800 ms`): **GIVEN** READY,Music sub-mode KPIREVIEW(Ambient duck -6 dB), **WHEN** KPI 演出结束(sub-mode → IDLE), **THEN** Ambient bus dB 在 800 ms 线性 Tween 回位 -12 dB;线性插值无阶跃;Tween 期 `bus_volume_changed` 不按帧发射(终值到达发射一次);800 ms 内 `play_sfx` 调用正常执行(不阻 SFX dispatch);Tween 完成 Ambient dB = -12 dB ± 0.1 dB 误差。

- **AC-COMPAT-03** (Rule 9 + Main Menu #17 联测 — 3 旋钮 UI 无 SFX 反馈) **[Deferred until Main Menu #17 GDD ready]**: **GIVEN** #17 音量设置屏 3 旋钮已实例化,READY 态,debug 钩子对 `play_sfx` 计数, **WHEN** QA 拖动 SFX 旋钮 -6 dB → -20 dB(连续 ~30 帧 slider drag), **THEN** 每帧 `set_bus_volume(&"SFX", [value])` 正常;`play_sfx` 调用计数全程为 0(旋钮拖动无 SFX,Pillar 4 + Rule 9);`bus_volume_changed` 逐帧发射(Save 侧 500 ms 防抖合并写,本 AC 仅验 Audio 无音频副作用)。

- **AC-COMPAT-04** (Rule 11 + GAME OVER 演出 — Localization `GAMEOVER.TITLE_IRONY` tone 同质联测) **[Deferred until #16 KPI Review UI GDD ready]**: **GIVEN** READY,Scene Flow emit `game_over_triggered`, **WHEN** GAME OVER 演出完整执行(Ambient fade out 2 s → 静默;Music `CREDITS_OUTRO_BUREAUCRATIC` oneshot 播完), **THEN** Ambient 全层 2 s 线性 fade out → -∞ dB;Music `CREDITS_OUTRO_BUREAUCRATIC` oneshot 播放;Music 播完 sub-mode → IDLE,Ambient 保持静默(不自动恢复);演出期**不**播任何 `FANFARE` / `ACHIEVEMENT` / `VICTORY` SFX(debug 钩子断言);QA dev build 同时验 #16 `GAMEOVER.TITLE_IRONY` Label 字体为站酷快乐体(跨系统 Pillar 4 tone 同质验证,截图存 `production/qa/evidence/`)。

### AC-ROBUST (错误恢复 / 边界 / 异常)

- **AC-ROBUST-01** [RISK GUARD R-AUD-1] (`_BUREAUCRATIC` 锚点 key 缺失 — Pillar 4 月末打卡机 CI 守门): **GIVEN** CI asset integrity check 在 build 阶段运行 `tools/audio_lint.gd`, **WHEN** `assets/audio/sfx/` 缺 `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC` 文件(模拟 sound-designer 未交), **THEN** CI FAIL `"ERR_ASSET_MISSING: ... — R-AUD-1 Pillar 4 tone anchor violated"`;build 不产出;runtime(lint bypass): Rule 5 静默降级,月末 KPI 流程不崩,视觉路径独立,dev `push_warning`;同验 `RECEIPT_THERMAL_HISS_BUREAUCRATIC` + `CREDITS_OUTRO_BUREAUCRATIC` 三锚点 key 缺任一均 CI FAIL。

- **AC-ROBUST-02** [RISK GUARD R-AUD-2] (`MUSIC_TRACK_MAX = 4` lint — Pillar 4 防音乐蔓延): **GIVEN** `tools/audio_lint.gd` 统计 `assets/audio/music/` 已注册 `MUSIC.*` key 数, **WHEN** lint CI 运行且 `MUSIC.*` key 数 = 5(超 MAX), **THEN** lint FAIL `"ERR_MUSIC_TRACK_MAX: 5 MUSIC keys exceed MUSIC_TRACK_MAX=4 — requires game-designer + audio-director dual approval"`;CI 阻塞,PR block;runtime bypass: 第 5 个 key 调 `play_music` 触 Rule 5 静默 + dev warning;key 数 ≤ 4 lint PASS;变更 `MUSIC_TRACK_MAX` 须先改本 GDD。

- **AC-ROBUST-03** [RISK GUARD R-AUD-3] (LOADING watchdog `AUDIO_LOADING_WATCHDOG_MS = 10000 ms` — Pillar 5 永久卡死守门): **GIVEN** AudioManager LOADING 态,Scene Flow bug 永不调 `_mark_ready()`,时钟桩 100 ms 步进推进, **WHEN** 累计推进超 10000 ms, **THEN** watchdog 触发: `push_error("[AudioManager] LOADING state exceeded 10000ms — force transitioning to READY")`;强制转 READY,`audio_manager_ready` 发射;pending Ambient / Music queue 同帧 flush;Pillar 5 恢复:后续 `play_sfx` / `play_ambient` / `play_music` 正常 dispatch。AND 合法启动 ≤ 10 s 内调 `_mark_ready()`,watchdog 不触发。

- **AC-ROBUST-04** [RISK GUARD R-AUD-4] (SFX 池 CRITICAL priority — 关键 SFX 不被 LRU 驱逐): **GIVEN** SFX 池满 8/8,全 slot 由普通 non-critical SFX 占用(正在播放), **WHEN** `play_sfx("SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC")`(CRITICAL priority,`_BUREAUCRATIC` key)第 9 次调用, **THEN** LRU 从 **non-critical** slots 驱逐最久空闲(非驱逐 CRITICAL slot);`PUNCH_CLOCK_CLACK_BUREAUCRATIC` 取 slot 播放;被驱逐 slot 在 `EVICTION_FADE_MS = 30 ms` 内淡出消除 pop。AND 池内 8 全 CRITICAL,新 CRITICAL 按普通 LRU 驱逐最旧 CRITICAL(不丢弃,CRITICAL vs CRITICAL 时序竞争)。AND dev build 普通 LRU 驱逐 CRITICAL slot 时 `push_error("ERR_AUDIO_POOL: CRITICAL SFX [KEY] would be evicted")`。

- **AC-ROBUST-05** [RISK GUARD R-AUD-5] (Master = -∞ 双重编码 — art-bible §7.4 信息可达守门): **GIVEN** `set_bus_volume(&"SFX", -60.0)` + `set_bus_volume(&"Music", -60.0)` + `set_bus_volume(&"Ambient", -60.0)` 已调(等效全静音), **WHEN** QA dev build 分别测试: (a) overtime: `scene_state_changed(OVERTIME)`;(b) KPI 通过: `play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC")` + `play_sfx("RECEIPT_THERMAL_HISS_BUREAUCRATIC")` 顺序;(c) GAME OVER: `game_over_triggered`, **THEN** (a) `_overtime` sprite + 蓝光 CanvasModulate 独立呈现,无需 audio;(b) 收据热敏打印视觉动画播放,KPI 结果文本视觉可读,无需 audio;(c) 字幕红字 + UI 进度条运行,无需 audio;3 路径下 `bus_volume_changed` 信号仍正常 emit;截图存 `production/qa/evidence/audio-mute-visual-parity-[date].png` sign-off。

### AC-TONE (Pillar 4 tone 守护 — Localization 引入,Audio 沿用)

- **AC-TONE-01** (`_BUREAUCRATIC` key 命名规范 + brief 引用 — 合规 happy path): **GIVEN** `tools/audio_lint.gd` 对 Audio event 注册表运行 `_BUREAUCRATIC` 后缀检查, **WHEN** 注册表含 `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC`,brief 文档引用字段含 tone 说明 `"行政流程音化;禁: 上行音符 / 励志节奏 / 英雄弦乐 / 完美 timing 质感"`, **THEN** lint PASS:brief 引用非空,不报 WARN;`_BUREAUCRATIC` 后缀 key 计数 ≥ 1;QA 可在 `production/qa/evidence/` 存 brief 文档截图作 audio-director sign-off 证据(advisory,不 blocking MVP CI)。

- **AC-TONE-02** (Rule 10 Layer C `_BUREAUCRATIC` 孤立 key — brief 引用缺失 WARN): **GIVEN** `RECEIPT_THERMAL_HISS_BUREAUCRATIC` key 的 brief 文档引用字段为空(孤立 `_BUREAUCRATIC` key), **WHEN** lint CI 执行, **THEN** lint 发 WARN `"[AudioLint] _BUREAUCRATIC key ... has no brief doc reference — annotate"`;**不 FAIL**(WARN 不阻 CI);dev build 显示 WARN 供 QA triage;audio-director human review 仍为 MUSIC asset 修改 blocking gate(Rule 10 Layer B);QA 列入 P2 backlog,须在 audio-director sign-off 前补 brief。

- **AC-TONE-03** (Rule 4 + Rule 9 普通 UI 按钮无 SFX — Pillar 4 零音频守门): **GIVEN** READY,debug 钩子对 `play_sfx` 调用计数归零, **WHEN** QA 在 diegetic UI 上依次执行: (a) 焦点切换(`act_focus_next` 遍 5 元素);(b) `act_confirm` 普通行动卡选择;(c) `act_cancel` 退子菜单, **THEN** `play_sfx` 调用计数全程为 0;无任何 SFX 因普通 UI 导航触发;唯一例外:月末结算 confirm 触 `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC`(月末结算 `act_confirm` 语义路径)— 单独验证:月末结算 confirm → `play_sfx` 计数 = 1 且 event_id = `PUNCH_CLOCK_CLACK_BUREAUCRATIC`。

### AC Tier 分级

**MVP 必测(Alpha gate 阻塞)— 24 条**: AC-FUNC-01~11(11)+ AC-PERF-01~03(3)+ AC-COMPAT-01~02(2)+ AC-ROBUST-01~05(5)+ AC-TONE-01~03(3)= 24。其中 **5 [RISK GUARD]**(AC-ROBUST-01..05)守门 R-AUD-1..5 高风险路径,首测 build 优先验证,不得推 Beta gate。

**MVP 建议测(Beta gate)— 2 条**: AC-COMPAT-03(需 #17 Main Menu UI fixture 就绪)、AC-COMPAT-04(需 #16 KPI Review UI GDD + GAME OVER 演出 fixture 就绪)。两者标 `[Deferred]`。

**VS / Alpha tier — Visual sign-off 子项**: AC-ROBUST-05 截图证据(`production/qa/evidence/audio-mute-visual-parity-[date].png`)Advisory sign-off,路径须 audio-director + QA Lead 双确认。

### QA 工具需求

| 工具 / Fixture | 路径 | 用途 | 优先级 |
|---|---|---|---|
| **Audio event fixture 库** | `tests/fixtures/audio/` | 标准事件注册表快照(合法 + 违规 + `_BUREAUCRATIC` key)/ 空注册表 / 5-key MUSIC 超限 fixture | MVP Alpha |
| **AudioServer Mock / Stub** | `tests/fixtures/audio/audio_server_mock.gd` | mock `set_bus_volume_db` / `get_bus_volume_db` / `play` 调用计数;隔离硬件依赖,headless 单测 | MVP Alpha |
| **`tools/audio_lint.gd` 测试套件** | `tests/unit/audio/audio_lint_test.gd` | 验 lint 规则: key 命名 / Bus 白名单 / `_BUREAUCRATIC` brief / `MUSIC_TRACK_MAX` / asset 存在性 / 文件大小 | MVP Alpha(CI blocking) |
| **时钟桩 for LOADING watchdog** | `tests/fixtures/audio/clock_stub.gd` | mock `Time.get_ticks_msec` 100 ms 步进推进 — AC-ROBUST-03 watchdog 触发 | MVP Alpha |
| **`_force_dispatch` debug 钩子** | AudioManager 仅 debug build 暴露 | `_force_dispatch_sfx(event_id)` / `_force_dispatch_ambient(scene_id)` / `_force_dispatch_music(track_id)` — 绕过 LOADING 状态检查直测 dispatch 路径(对齐 Localization `_force_dispatch` 模式) | MVP Alpha |
| **字幕替代音频 fixture(静音视觉验证)** | `tests/fixtures/audio/mute_visual_parity.fixture` | 全 Bus -60 dB + overtime / KPI / GAME OVER 场景快照 — AC-ROBUST-05 视觉双重编码回归测试 | MVP Alpha(R-AUD-5) |
| **BGM track 长度 lint fixture** | `tests/fixtures/audio/bgm_over_120s.ogg` (stub) | 超 `bgm_loop_length_max_sec = 120 s` 伪 BGM asset — `tools/audio_lint.gd` OQ-AUD-01 lint 规则开发验证 | Beta / ADR 后 |
| **CRITICAL priority SFX pool fixture** | `tests/fixtures/audio/sfx_pool_full_critical.fixture` | 8/8 slots 被 non-critical 占满的 pool 状态快照 — AC-ROBUST-04 验 CRITICAL 驱逐豁免逻辑 | MVP Alpha(R-AUD-4) |

## Open Questions

6 条 OQ-AUD 集中(分布于 Sections C/E),按 owner / target 排序:

| OQ ID | 描述 | Owner | Target Resolution |
|-------|------|-------|-------------------|
| OQ-AUD-01 | BGM loop 时长 lint 实现(`bgm_loop_length_max_sec = 120 s` CI 检测,ffprobe vs Godot import meta 读)+ SFX priority class 实现(R-AUD-4 CRITICAL 豁免)+ lazy-load BGM "2 帧保证"机制 + 多输出设备 WASAPI / PulseAudio 行为差异文档 | audio-director + godot-specialist | ADR 阶段 |
| OQ-AUD-02 | `_BUREAUCRATIC` 孤立 key 警告 vs sound-designer 3 变体缺失 lint 策略 + 同帧多次 `play_sfx` 同 key 调用方 contract 文档(防同帧 8 次打卡机)+ 孤立 audio asset purge 自动化 | audio-director + sound-designer | Sound Design Brief 阶段 |
| OQ-AUD-03 | LOADING 期 `set_bus_volume` 应直接写内存表 vs 排队(Edge 3.4)+ Save 恢复信号与 Audio LOADING 启动序列时序须 Scene Flow 强制保证 | systems-designer + game-designer | Scene & Day Flow GDD #6 设计阶段 |
| OQ-AUD-04 | Ambient duck release(800 ms)与演出时长关系的 audio-director 确认(brief 要求)+ 多重 crossfade 取消策略边界(stop + play 同帧)须 ADR 锁实现 | audio-director + systems-designer | Audio ADR 阶段 |
| OQ-AUD-05 | LRU 驱逐 pop artifact:eviction fade `EVICTION_FADE_MS = 30 ms` 是否足够?须 audio 主观听测验证。备选 lazy eviction(优先驱逐已播完 SFX) | audio-director + sound-designer | 首个可测 build 主观测试 |
| OQ-AUD-06 | Godot 4.6 `NOTIFICATION_WM_WINDOW_FOCUS_OUT` 是否触发 `AudioServer` 自动静音(查 4.4-4.6 migration notes)+ Audio fade 行为与 Input Edge 9.1 `reset_all_action_presses()` 时序一致性联合测试 + Music license 决策(MVP placeholder freesound CC0,正式版 ADR 决定 self-record vs 外采) | godot-specialist + qa-lead + audio-director | Godot 4.6 API 验证 + Integration test + Polish ADR |

**OQ 标记的 AC**: 以下 AC 精确表述可能需要 OQ 解决后更新:
- AC-FUNC-08 / AC-ROBUST-04(OQ-AUD-01 SFX priority class 实现)
- AC-PERF-01(OQ-AUD-01 BGM lazy-load "2 帧保证")
- AC-FUNC-11(OQ-AUD-06 `WM_FOCUS_OUT` 触发实测)
- AC-COMPAT-04(OQ-AUD-04 演出时长 vs duck release 关系)
- AC-TONE-02(OQ-AUD-02 孤立 `_BUREAUCRATIC` key 自动 purge)
