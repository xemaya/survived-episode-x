# Lighting & Visual State Controller

> **Status**: **Designed (pending review — awaits `/design-review design/gdd/lighting-visual-state.md --depth lean` in fresh session)**
> **Author**: user + main agent + creative-director (B framings) + art-director (C 11 Rules + 视觉方向) + technical-artist (C 9 性能契约 + Godot 4.6 集成) + godot-shader-specialist (C 8 shader 实现规约) + systems-designer (C 状态机 + 信号架构 + 5 RISK GUARD + E 32 edges) + qa-lead (H 27 AC,自动修 1 wording flag)
> **Last Updated**: 2026-04-25
> **Implements Pillar**: Pillar 2 (叙事即机制 — 光线 / 累积视觉是时间进度条 + 工位物质投入证据) [primary] + Pillar 1 (平庸是一种艺术 — 不做"加班英雄"光效) [guard] + Pillar 4 (黑色幽默 tone 守护 — 累积视觉具象 老板假绿植 / 茶水间签名同一人 / 周年庆俗艳粉) [guard] + Pillar 5 (地铁可玩性 — CanvasModulate 切换 ≤ 1 帧 + 累积 state 不阻 5 秒进入) [secondary]
> **Review Mode**: Lean (CD-GDD-ALIGN skipped per `production/review-mode.txt`)

## Overview

Lighting & Visual State Controller 是《活过第 X 集》视觉状态基础设施层 + 时间叙事载体的**双重身份系统**。**技术层**:坐于 Godot 4.6 `CanvasModulate` 之上,以 6 MVP 场景视觉状态(主菜单 / 早晨预告 / 白天行动 day / 白天行动 overtime / 下班抉择 / 今日总结 / 月末 KPI 考核 / GAME OVER 片尾)× `_day` / `_overtime` 变体驱动**全局色调切换**(0.3 s Tween,art-bible §8.6 锁定)+ palette swap shader(`palette_index` uniform,art-bible §8.4)+ dither overlay shader(仅 overtime 激活,art-bible §6.2 / §8.6 锁定)。**叙事层**:光线就是时间进度条 —— 玩家不读 HUD 时间数字,**光态本身是剧情进度**(日光灯惨白 → 屏幕蓝光叠加 → 窗外日落橙 → 月末红光溢出)。累积视觉(每周脏桌 / 每月过期通知 / 季度墙裂 / 周年横幅)是玩家工位时间投入的**可见证据**(art-bible §6.5 锁定)。所有上层系统(Scene & Day Flow #6、HUD #13、Card Play UI #14、Recap UI #15、KPI Review UI #16)只通过场景状态信号订阅本系统的视觉切换,**不直接调** `CanvasModulate.color`。

本系统是 Pillar 2(叙事即机制)的**视觉执行层** —— 时间不是数字,是色温渐变叙事链。同时它是 Pillar 1(平庸是一种艺术)的**视觉守门员** —— 故意不实现"加班英雄式光环 / 升职金光特效 / 优秀员工高光描边";overtime 不是被赞美的努力勋章,是物理失真(art-bible §6.2 "另一种物理定律");月末通过 KPI 不切金光胜利场景(对齐 Audio Manager Rule 4 + 7 Pillar 4 同质红线 —— **视觉与听觉双轨守 "胜利不庆祝"**)。它也是 Pillar 4(黑色幽默 tone)的**累积视觉具象层** —— 老板办公室假绿植(art-bible §6.4 #2)/ 茶水间签名同一人(art-bible §6.4 #3)/ 周年庆俗艳粉横幅(art-bible §4.6)由本系统 own state + 触发渲染。

Lighting 与 Audio Manager(#4)形成 **audio-visual 对偶** —— Audio Rule 6 ambient layer schema 与本系统 6 场景视觉变体 **1:1 同源**,均订阅 Scene & Day Flow Controller `scene_state_changed` 信号。两系统在同一 Pillar 2 + Pillar 4 红线下分工:Audio 负责听觉叙事,Lighting 负责视觉叙事,**绝不冗余**(art-bible §7.4 "色盲双重编码"反向 = Audio Rule 9 "静音功能完整"反向 — 重要游戏信息必须**视觉 + 听觉双通道独立可达**)。

Lighting **不**拥有:sprite variant 资产文件本身(由 art-director / 各 NPC 角色管线 art-bible §8 交付,本 GDD 仅锁 sprite state schema + 命名)、字体层级(Localization Hooks Rule 9 owns)、Audio bus 状态(Audio Manager owns)、单 NPC 立绘 `self_modulate`(归 §5 角色资产管线 owns,Lighting 仅 own **全局** CanvasModulate 与累积 sprite state)、UI 元素颜色(各 UI GDD owns)。累积视觉 state(`desk_stain_count` / `notice_board_age[]` / `break_room_cracks` / `anniversary_year` 等,art-bible §6.5 锁定)由本系统 owns 状态 + 切换触发,具体 sprite 资产由美术交付。状态持久化经 Save Rule(**main save 路径**,非 settings,因频繁变更),不走 `meta_settings_debounce_ms`。

*技术实现细节(`CanvasModulate.color` 切换的 Tween 曲线 / `palette_index` uniform 的 thread-safe 写入 / dither overlay shader 的 sobel 边缘检测 vs 全屏 dither / overtime 仅光源 4 px 内的距离场实现 / 累积 sprite state 的 atlas 复用 vs 多 variant 文件 / 异常几何信号 art-bible §3.2 危机倾斜 2-3° 的 shader vs Sprite2D rotation 实现)留给 ADR 阶段决定;本 GDD 只锁行为语义、6 场景视觉状态边界、跨系统契约、累积 state schema、MVP scope("6 场景 × _day/_overtime 变体 + 累积视觉 4 维度,无 Light2D 无后期")。*

## Player Fantasy

Lighting & Visual State Controller 服务工位日常的两类视觉瞬间,继承 Save / Input / Localization / Audio 同 tone — **冷静、不抢戏、对比工位语境的低期待**。Save 承诺在运行时(不丢档),Input 在响应层(不卡 / 跳过),Localization 在文本层(说人话),Audio 在听觉层(摘耳机才发现一直在听工位)。本系统的承诺在**视觉沉淀层** —— 玩家从不会主动说"光影氛围真好",但摘掉眼镜揉揉眼那一刻,会忽然意识到"刚才一直没注意天黑了"。它不是被赞美的对象,是不被注意到的承诺;但它独有一条 Audio 给不了的承诺 —— **它会记得你做了什么**。

### 我的桌子怎么这么脏(Pillar 2 累积视觉,Lighting 独占叙事载体)

周三早上 9:15,他经过自己工位 ——

桌面比周一多了三个咖啡渍。一摞没归档的报销单压着键盘左边。键盘缝里一根头发。

没人提醒。没有任务标记。没有"整理桌面 +5 精力"提示弹窗。这是他这周自己堆出来的。

art-bible §6.5 锁定的累积视觉是 Lighting **独占**的叙事载体 —— 每周脏桌 / 每月走廊过期通知 / 季度茶水间裂缝 / 周年办公室横幅。**玩家时间投入物化为视觉债务**,不是奖杯墙,是该清没清的烂摊子。游戏不**奖励**这种沉淀,游戏只**记录**它 —— 你做了什么,工位记得。Audio 系统是流走的瞬时,Lighting 系统是低头就在那的债务。

### 再苟一天(Pillar 1 关键时刻视觉反讽,与 Audio + Localization 同质红线)

18:00 周五,这个月 KPI 堪堪压线过。

窗外日落橙铺满工位。他可能一瞬以为这是温暖结局 —— **不是**。

**没有**金光胜利场景。**没有**英雄主题切镜头。**没有**"通关动画"。只是一束斜射的暖色光,照在键盘上 0.5 秒,然后画面继续。下一秒下班 / 加班选项卡浮出 —— 加班选项框边发光像商场促销标签(art-bible §2.4 锁定)。第二天 09:00 一切复位:同样的青白日光、同样的脏桌、同样的待办。

橙色不是奖励,是"今天撑过去了"的凭证,**仅此而已**。

这是 Pillar 1 平庸守护的视觉具象 —— 与 Audio "月末打卡机不是胜利音"(听觉 negative space)+ Localization `GAMEOVER.TITLE_IRONY` "恭喜晋升"(文字 negative space)同源:**视觉、听觉、文字三轨同时在玩家最期待庆祝的时刻拒绝庆祝**。光态在 KPI 通过 / 升职 / 周年庆这些"该奏胜利曲的时刻"绝不切金光英雄场景(对齐 Audio Rule 4 + 7 红线 + Localization Rule 11 反讽锚 — 三 GDD 跨系统 Pillar 4 守门铁三角)。

### Tone 锚点

**对** 的参考:工位日光灯惨白(art-bible §2.1 / §4.1 白炽灯白 `#E8E0CC`)、加班屏幕蓝光叠加(`#2C4A6E`)、18:00 日落橙斜射(art-bible §2.4 / §4.1 地铁座椅橙 `#B05A28`)、月末考核红光溢出(art-bible §2.6)、Save 的"下班打卡机"、Input 的"工位隔间键盘均匀节奏"、Audio 的"日光灯嗡的不是 BGM"、Localization 的"老家亲戚的中文"、夜间地铁车厢暖黄灯(art-bible §2.5)。

**反** 的参考:不是 AAA 游戏开场的"已检测到 4K HDR / Dolby Vision"炫技;不是 dynamic time-of-day lighting 演示视频里的"沉浸式光影"卖点;不是赛博朋克霓虹的"赛博美学";不是月末通关时的金色 confetti 雨 + 烟花;不是 RPG 升级时的金光环 + 高光描边;不是 Steam 商店页"独特视觉风格 ✓" 勾选框的庆祝;不是"画面太美我哭了"那种 community 营销引用语;不是 controller-friendly 游戏插上手柄时屏幕亮起"已检测"提示。Lighting 不庆祝玩家,也不庆祝自己。

### 玩家不会说的话 / 会说的话

- ❌ "光影氛围真好" / "动态光照震撼" / "色彩美术拉满" / "夕阳 vibe 拿捏了"
- ❌ "推荐戴蓝光眼镜玩!" / "调色调得超有电影感" / "光线建模超真实"
- ✅ (沉默 —— 摘掉眼镜揉眼,完全没意识到刚才一直在看光线变化)
- ✅ "天黑了。" / "几点了?" / "我的桌子怎么这么脏。" / "这墙怎么开始裂了。"

## Detailed Rules

### Core Rules

1. **CanvasModulate 全局色调切换表(art-bible §2 + §4.3 推导,8 sub-mode × `_day` / `_overtime` 变体)**:Lighting Controller 持有唯一 `CanvasModulate` 节点。色调切换通过 `Tween` 0.3 s 线性插值(art-bible §8.6 锁,曲线 `TRANS_LINEAR / EASE_IN_OUT`,**禁突变 / 禁其他缓动**)。上层系统**禁止直调** `CanvasModulate.color`,只通过 `scene_state_changed` 信号触发。

   | sub-mode | art-bible §2 | `CanvasModulate` 基色 | dither overlay | 切换策略 |
   |---------|------------|----------------------|---------------|---------|
   | `MAIN_MENU` | 2.1 清晨 6:58 | `#C8C4B8`(冷白) | 关 | 无 fade(初始化) |
   | `MORNING_BRIEFING` | 2.2 板正沉默 | `#D4D0C8`(均匀冷白) | 关 | 直接跨,不加层 |
   | `ACTION_DAY` | 2.3 拥挤钝感 | `#D0C8A8`(打工人黄) | 关 | 0.3 s Tween |
   | `ACTION_OVERTIME` | §6.2 另一种物理定律 | `#8090B4`(蓝光降饱和叠加) | **激活**(渐入 0.5 s) | 0.3 s Tween,**无 stinger,不切 BGM** |
   | `AFTER_WORK` | 2.4 拉锯窒息 | `#B05A28`(day)/ `#6878A0`(overtime) | 维持当前 | 0.3 s Tween |
   | `DAILY_RECAP` | 2.5 倦意收尾 | `#C8A060`(地铁暖黄) | 关 | 0.3 s Tween |
   | `KPI_REVIEW` | 2.6 仪式感尘埃落定 | `#3A3050`(深蓝灰)+ 红光 UI 叠加 | 关 | 0.3 s Tween |
   | `GAMEOVER` | 2.6 片尾字幕 | `#3A3050` 保持(片尾曲红 `#E03020` ≤ 8% UI 叠加,art-bible §4.6) | 关 | 维持 |

   **茶水间区域** color temp 3200K 锁定 **无 overtime 变体**(art-bible §4.3);老板办公室 day/overtime 均维 `#C0A880`(3000K 档案棕,"老板时间不分昼夜")。**Tween 主线程开销 ≤ 1 帧**(0.01 ms 量级,Forward+ 全局 multiply 不打破 batch)。

2. **主状态机 LOADING / READY(对齐 Audio Manager 模式)+ sub-mode enum**:

   | 状态 | 含义 | 合法调用 | 进入 | 退出 |
   |------|------|---------|------|------|
   | **LOADING** | 等 Save 注入累积 state + `CanvasModulate` 初始化 | `load_accumulation_state(payload)`;`set_scene_visual` 进 size=1 pending queue;`apply_accumulation` 静默丢弃 | 系统初始化 | Scene Flow `_mark_ready()` |
   | **READY** | 正常视觉切换 | 全部接口 | `_mark_ready()` 私有 | 无(运行期不离开) |

   **LOADING 期 dispatch 守门**:`set_scene_visual` 排队(覆盖最新,Save Rule 13 snapshot 合并语义同质);`apply_accumulation` **直接静默丢弃**(累积 delta 离散事件 READY 后补偿无意义,类比 Audio SFX);`load_accumulation_state` LOADING 期唯一合法写入。

   **`LIGHTING_LOADING_WATCHDOG_MS = 10000 ms`** — 对齐 Audio `AUDIO_LOADING_WATCHDOG_MS`。超时触 `push_error` + 强制转 READY + flush pending queue。**[RISK GUARD — R-LVS-2]**。

   **8 sub-mode enum**(在 READY 内,非状态机,是当前视觉配置数据 — 对齐 Audio Music sub-mode 模式): `MAIN_MENU` / `MORNING_BRIEFING` / `ACTION_DAY` ⇄ `ACTION_OVERTIME` / `AFTER_WORK` / `DAILY_RECAP` / `KPI_REVIEW` / `GAMEOVER`。`ACTION_DAY ⇄ ACTION_OVERTIME` 双向可切;其余单向,由 Scene & Day Flow #6 驱动。Lighting **完全被动订阅**,无自主跳转。

3. **Palette Swap Shader(art-bible §8.4 + godot-shader-specialist 实现锁)**:`assets/shaders/palette_swap.gdshader` 单 ubershader + `palette_index: int` uniform(范围 [0, 7],默认 0=`_day`,1=`_overtime`)。LUT atlas `assets/palettes/pal_lut_office_8xN.png`(8 列 × N 行,sRGB=off,filter=Nearest,art-bible §8.3 锁)。Shader 用 R 通道作 src color index,采样 `(palette_index + 0.5) / 8.0` 列得目标色 → 8 色 → 8 色 remap。

   **运行时上层禁直调 `material.set_shader_parameter("palette_index", N)`**(对齐 Rule 1 — 仅经 `scene_state_changed` 信号 → Lighting Controller 内部映射 sub-mode → palette_index uniform)。Lighting Controller 内部唯一调用此 API 的方法是 Tween callback,debug 钩子可在非 LightingManager 节点拦截此调用作 CI lint enforcement。同场景 NPC 共享 `palette_index` → **不打断 sprite batch**(art-bible §8.5 0 额外 draw call)。`palette_index` 切换由 Tween 驱动用 `roundi()` 离散跳变(避免中间 index 采样错误 LUT 列);`material.set_shader_parameter()` 主线程安全(Godot 4.6,**禁** Godot 3 遗留 `set_uniform()`)。运行时活跃 shader 贡献 **+1**(art-bible §8.8 ≤ 10 上限内)。

4. **Dither Overlay Shader(art-bible §6.2 / §8.6 + godot-shader-specialist 实现锁)**:`assets/shaders/dither_overlay.gdshader` + 全屏 `CanvasLayer`(layer=128,高于世界低于 UI 弹窗)+ `ColorRect`(anchors=FULL_RECT)+ `ShaderMaterial`。

   **状态规则**:
   - 非 `ACTION_OVERTIME`:`visible = false`,**真零 GPU cost**(Godot 4.6 Forward+ CanvasLayer 跳 draw call + fragment shader 不执行)
   - `ACTION_OVERTIME` 进入:`visible = true` + `dither_intensity` uniform 从 0 Tween 至 0.35(渐入 0.5 s)
   - 退出:Tween 出 0.3 s → `visible = false`

   **算法**:2bit Bayer 4×4 ordered dither matrix + screen-space 阈值比较(`step(threshold, dither_intensity * edge_alpha_mask)`)。**MVP 选项 A**(全屏 ColorRect + 全屏 dither;`dither_intensity = 0.35` 自然产生约 35% 点阵密度,视觉上等效 art-bible §6.2 "光源边缘 4 px 内"的点缀效果);**OQ-LVS-03** ADR 决定是否升级 Sobel 边缘 / SDF 距离场。压层基色 `#071A47`(加班蓝)。

   **必备**:ColorRect 节点须**常驻根场景树**(visible=false 即可),确保 Shader Baker (Godot 4.5+) 预编译覆盖(避免首次 overtime 激活 frame hitch)。运行时 shader 贡献 +1。Tonemapper 必须锁 `Filmic` 或 `Linear`(**禁** AgX —— 会改色相,见 Rule 11)。

5. **累积视觉 state schema(art-bible §6.5,Lighting 独占叙事载体,main save 路径非 settings)**:

   | 字段 | 类型 | 范围 | 触发 | sprite variant 索引逻辑 |
   |------|------|------|------|----------------------|
   | `desk_stain_count` | int | [0, 52] cap | 每周日结算 +1 | `clamp(count, 0, 4)` → 5 级 atlas variant(第 4 级后视觉稳定,仅计数继续) |
   | `notice_board_age` | Array[int] | 元素 ≥ 0,len ≤ `NOTICE_BOARD_MAX_ENTRIES = 24`(2 年月数) | 每月 1 号 append 0 + 既有元素 +1;FIFO 驱逐溢出(R-LVS-5 守门) | 渲染全部元素;age ≥ 3 月 `self_modulate` 降至 `#BBBBBB`;≥ 6 月 `#999999`;≥ 12 月遗迹态 |
   | `break_room_cracks` | int | [0, 16] cap | 每季末结算 +1 | 0=无;1-4=细线 4 px;5-8=明显;9-12=严重;13-16=崩解态 |
   | `anniversary_year` | int | [0, 10] cap | 每周年日 +1 | 0=无横幅;1+=出现"奋斗 X 周年"横幅;overtime 下色变咖啡渍棕黑 `#2A1F14`(art-bible §6.5)|

   **持久化路径**:`current_run.save > world.accumulation` 子字段(**main save**,非 `meta.save` settings 路径,频繁变更 → 不消耗 `meta_settings_debounce_ms`,与 Save Rule 14 解耦,与 Save Rule 3 autosave 触发链对齐)。

   **写入机制**:Lighting emit `accumulation_changed(type, new_value)` → Scene & Day Flow 订阅 → 调 `Save.request_autosave()`。**Lighting 绝不直调** `SaveSystem.write_*` 或 `FileAccess`(Save Rule 20 承约)。

   **Sprite 切换**:`AtlasTexture.frame_coords` / `region` 信号驱动(art-bible §8.7),同 atlas 零额外内存,不打断 batch。4 字段总切换开销 < 0.1 ms。

6. **关键时刻视觉反讽红线(Pillar 1 + Pillar 4 三轨守门铁三角)**:

   **禁止的视觉切换类型**(无豁免,新增须 creative-director + art-director 双批改本 GDD + art-bible):
   - KPI 月末通过时切换至**金光 / 亮白高光场景**(用 `AFTER_WORK` `#B05A28` 日落橙维持,**绝不**切金 fanfare 光)
   - 升职 / 加薪时**英雄高光描边 / NPC 全局亮化**
   - overtime 进入时"努力勋章式光效"(overtime 是物理失真,art-bible §6.2 "另一种物理定律",非赞美)

   **反讽执行规则**(art-bible §4.6 锁):
   - **周年庆**:横幅色用 `#E8609A`(俗艳粉,≤ 5%)+ **必须叠 2 px `#2A1F14` 黑框压住**(art-bible §4.6 强制)
   - **升职**:不切场景色;现有色调维持;反讽由 **Localization Rule 11 `GAMEOVER.TITLE_IRONY` "恭喜晋升"(文字)+ Audio Rule 4 + 7(听觉静默 / 打卡机 SFX 非英雄主题)+ Lighting 视觉静止** 三轨同步守门。

   **[RISK GUARD — R-LVS-1]** Pillar 4 反讽红线:CI lint 须枚举验证 `KPI_REVIEW` palette **不含** `#FFD700` / `#FFA500` 系金色(16 进制前缀检测)。违反 = P0 FAIL。

7. **环境叙事 Tone 守门(art-bible §6.4 黑色幽默具象 4 元素,Lighting own state + 触发渲染)**:

   | 元素(art-bible §6.4)| state 触发 | 变体规则 | 美术 brief 关键词 |
   |---------------------|-----------|---------|------------------|
   | 老板办公室假绿植(#2)| 纯环境装饰常驻 | overtime 时 `self_modulate` 叠 `#8090B4`;**4×4 px 无渐变纯平色块**(区别真绿萝)| 假叶纹理零渐变 |
   | 茶水间换水签名同一人(#3)| overtime 激活 | 签名 sprite `self_modulate` 从 `#888888` → `#C83428`(2 s Tween 同 Rule 1 节奏);overtime 退出 Tween 回灰 | 字迹 sprite 单张 + `self_modulate` |
   | 走道快递盒脚印(#4)| `accumulation_event("delivery_footprint", toggle)` Scene Flow 提供 `npc_traffic_count`(≥ 3 触发 stepped variant)| `clean` / `stepped` 两 variant 切换;每日总结后 reset clean | clean / stepped variant |
   | 会议室白板历史笔迹(#5)| 每次会议事件后 emit `accumulation_event("whiteboard", append)`| 笔迹 sprite 多层叠加,层 N alpha=1.0,旧层 × 0.6 系数衰减;最大 4 层 | 半透明叠加 alpha 层 |

   美术 sprite 资产由 art-director 交付,本 GDD 锁 state schema + 触发条件。

8. **Audio-Visual 对偶契约(art-bible §7.4 双重编码 + Audio Manager Rule 6 + 9)**:Lighting Controller 与 Audio Manager **共同订阅** Scene & Day Flow Controller `scene_state_changed(state: StringName)` 信号,各自独立 dispatch,**绝不互相触发**(art-bible §7.4 双重编码:视觉变化须独立可识,不可仅由 audio 暗示)。

   1:1 对偶映射(各自独立实现,不依赖对方完成切换):
   - `MAIN_MENU` / `MORNING_BRIEFING` / `DAILY_RECAP`: Audio = `FLUORESCENT_HUM` + `AC_LOW_HISS`;Lighting = `#C8C4B8` / `#D4D0C8` / `#C8A060`
   - `ACTION_DAY`: Audio = +`KEYBOARD_RHYTHM` + `PHONE_THREE_RINGS`;Lighting = `#D0C8A8` + dither off
   - `ACTION_OVERTIME`: Audio = +`SCREEN_BUZZ_OVERTIME`(渐入 2 s 无 stinger);Lighting = `#8090B4` + dither overlay 渐入 0.5 s
   - `AFTER_WORK`: Audio = 延续当前;Lighting = `#B05A28`/`#6878A0`
   - `KPI_REVIEW`: Audio = Music fade in + Ambient duck -6 dB;Lighting = `#3A3050`
   - `GAMEOVER`: Audio = Ambient fade out + `CREDITS_OUTRO`;Lighting = `#3A3050` 保持

   **禁止信号双向触发**:Audio 不订阅 Lighting,Lighting 不订阅 Audio。两系统在 Scene Flow 信号下并行响应,失败容忍由 Pillar 5 双通道独立可达保证。

9. **跨系统信号 + 接口契约**:

   **对外 emit 信号**:
   - `scene_visual_changed(sub_mode: StringName)` — Tween 完成后 emit;HUD #13 / Card #14 / Recap #15 / KPI Review #16 可选订阅(同步 UI 配色)
   - `accumulation_changed(type: StringName, new_value: Variant)` — Scene Flow #6 订阅触发 `Save.request_autosave()`
   - `lighting_manager_ready()` — LOADING → READY 转换;Scene Flow 等此 gate 再开 UI(对齐 Audio `audio_manager_ready`)

   **公开接口**:
   ```
   set_scene_visual(sub_mode: StringName) -> void   # Scene Flow 触发,LOADING 期排队
   apply_accumulation(type: StringName, delta: int) -> void  # LOADING 期丢弃
   load_accumulation_state(payload: Dictionary) -> void  # LOADING 期唯一合法写入
   reset_accumulation() -> void  # debug only,prod build 编译排除
   ```

   **私有方法**:
   - `_mark_ready()` — Scene Flow #6 only,外部调用 `push_error` + 拒绝(对齐 Audio `_mark_ready`)

   **WM_FOCUS_OUT 行为**:`pause_tween()` 仅 pause(保持 state 一致,恢复 `resume_tween()`);dither overlay `visible` 不变(避免恢复闪烁);与 Audio Edge 7(`act_pause` / WM_FOCUS_OUT 同公版)同信号触发,由 Scene Flow 协调。

10. **性能契约(Pillar 5)**:

    | 操作 | 约束 | Draw Call 贡献 |
    |------|------|---------------|
    | CanvasModulate 切换(单 sprite color uniform) | 主线程 ≈ 0 ms,Tween 18 帧总开销 < 0.2 ms | 0(全局 multiply,不破 batch) |
    | palette_swap shader(每 sprite +1 LUT 采样)| < 0.1 ms total(8×N px LUT 常驻 L1 cache) | 0(同 ubershader,uniform 共享不破 batch) |
    | dither overlay 全屏(1920×1080) | < 0.3 ms(Bayer 4×4 + step,纯数学无分支) | +1(仅 overtime;非 overtime visible=false 真零) |
    | 累积 state sprite 切换(`AtlasTexture.region` 赋值)| < 0.1 ms / 4 字段 | 0(同 atlas 不打断 batch) |
    | **Lighting 系统总贡献**(MVP) | — | day=0,overtime=1 |
    | 全场景预估 draw call | ≤ 15(art-bible §8.5 上限 100,余 85) | — |
    | **Lighting 显存** | < 0.1 MB(LUT atlas 2 KB) | art-bible §8.5 总 ≤ 40 MB |

11. **静音 / 视觉双重编码 + Godot 4.6 集成(art-bible §7.4 反向 + Audio Rule 9 反向 + 4.6 gotchas)**:

    **静音守门**:Audio Master = -60 dB(全静音)时所有视觉状态切换**照常执行**,与 audio 物理输出解耦。`scene_state_changed` 触发的 CanvasModulate + dither overlay + palette swap **不**等待 / 检查 audio 状态。**[RISK GUARD — R-LVS-4]** AC 须断言 Master = -60 dB 下 overtime / KPI / GAME OVER 视觉路径功能完整(对齐 Audio R-AUD-5 视觉对偶)。

    **Godot 4.6 集成约束**:
    - **D3D12 Windows 默认**:gdshader 后端透明,palette + dither shader 行为一致,无需修改
    - **Glow 4.6 before tonemapping**:本系统无 Glow,无影响
    - **Tonemapper 必须锁 `Filmic`**(`project.godot` WorldEnvironment 中明示;**禁** AgX —— art-bible §4.1 语义色 hex 在 AgX tonemapping 后偏移 → palette 需 LUT 重标定)。**禁止运行时 tonemapper 切换**。[OQ-LVS-tonemapper]
    - **Shader Baker (4.5+)**:`shader_compiler/bake_ubershader=true`(art-bible §8.3 已开)。dither overlay ColorRect + palette swap material 须常驻场景树供 Baker 扫描覆盖
    - **Dual-focus (4.6 NEW)**:Lighting 是纯 CanvasItem 节点,无 Control 焦点逻辑,不受 dual-focus 影响

12. **异常几何信号(art-bible §3.2,MVP 留扩展点不实现)**:危机事件触发时格线倾斜 2-3°(art-bible §3.2 锁)MVP **不实现**。接口契约留桩 `apply_crisis_tilt(angle_deg: float)` 空方法,参数范围 [2.0, 3.0];调用方为 Scene & Day Flow #6 危机事件信号(信号名待 #6 GDD 定义)。具体实现(Sprite2D rotation / GridContainer shader 倾斜 / 专属 tilt pass)延野心版 ADR。

### States and Transitions

主状态机详见 Rule 2 表(LOADING / READY 2 态)。**累积视觉 4 维度独立单调递增**,无回滚 / 无分支跳转,**不构成状态机** —— 是数据,不是状态。

**全局视觉状态 enum 转移路径**(由 Scene & Day Flow #6 驱动,Lighting 被动订阅):

```
MAIN_MENU → MORNING_BRIEFING → ACTION_DAY ⇄ ACTION_OVERTIME → AFTER_WORK → DAILY_RECAP
                                                                        ↓
                                                                KPI_REVIEW → GAMEOVER
```

**事件 → Visual 触发映射**:

| 触发事件 | 视觉行为 |
|---------|---------|
| Scene Flow `scene_state_changed(X)` | `set_scene_visual(X)` → Tween CanvasModulate 0.3 s + palette_index uniform 同帧提交 + dither overlay uniform 切换 |
| Scene Flow `kpi_review_started` | sub-mode → KPI_REVIEW(同 `scene_state_changed("KPI_REVIEW")` 同源,**优先订阅 `scene_state_changed`** 避免重复) |
| Scene Flow `game_over_triggered` | sub-mode → GAMEOVER + 启动片尾曲红 UI 叠加(委托 GAME OVER UI #16) |
| Scene Flow `accumulation_event(type, delta)` | `apply_accumulation(type, delta)` → 更新 `accumulation_state` + sprite swap + emit `accumulation_changed` |
| Save 启动期 → Scene Flow → `load_accumulation_state(payload)` | 内存累积 state 注入(LOADING 期合法) |
| `NOTIFICATION_WM_WINDOW_FOCUS_OUT` | `pause_tween()`(保持 state);dither overlay `visible` 不变;与 Audio Edge 7 同信号触发 |
| `NOTIFICATION_WM_WINDOW_FOCUS_IN` | `resume_tween()` 恢复 |

### Interactions with Other Systems

> **Save System (#1)** ↔ Lighting & Visual State Controller
> **流入** (#1 → Lighting): 启动期由 Scene & Day Flow 协调,从 `current_run.save > world.accumulation` 读取 payload,调 `LightingManager.load_accumulation_state(payload)` 注入(**main save 路径**,非 `meta.save` settings)
> **流出** (Lighting → #1 via signal): `accumulation_changed(type, new_value)` → Scene Flow 订阅 → 调 `Save.request_autosave()`(Save Rule 3 触发链)。Lighting **绝不直调** SaveSystem.write_*、FileAccess、ConfigFile(Save Rule 20)
> **所有权**: Save owns 持久化路径与 schema;Lighting owns 运行时累积 state + sprite variant 索引
> **关键约束**: 不消耗 `meta_settings_debounce_ms`(累积 state 是 world data,频繁变更走 main save 触发链)。R-LVS-3 守门 schema 兼容(缺字段 fallback 默认,对齐 Save Rule 11 损坏处理)

> **Scene & Day Flow Controller (#6)** ↔ Lighting & Visual State Controller
> **流入** (#6 → Lighting): 启动期 `LightingManager.load_accumulation_state(payload)` + `_mark_ready()`;运行期 emit `scene_state_changed(sub_mode)` / `kpi_review_started` / `game_over_triggered` / `accumulation_event(type, delta)`
> **流出** (Lighting → #6): `lighting_manager_ready()`(等此 gate 通过再开 UI)+ `accumulation_changed(type, new_value)`(协调 Save autosave)+ `scene_visual_changed`(可选订阅)
> **所有权**: #6 owns 场景 id → sub-mode 切换决策 + 演出时机 + accumulation_event 触发节奏(每周日 / 月 1 号 / 季末 / 周年);Lighting owns 实际 CanvasModulate Tween + shader uniform 切换 + 累积 state 内存
> **时机**: 切换由 #6 驱动,Lighting 被动响应

> **Audio Manager (#4)** ↔ Lighting & Visual State Controller(audio-visual 对偶,平行系统)
> **流入 / 流出**: **无直接信号契约** —— 两系统均订阅 Scene Flow `scene_state_changed`,各自独立响应
> **所有权**: Audio owns 听觉叙事(Rule 6 ambient + Music sub-mode);Lighting owns 视觉叙事(Rule 1 CanvasModulate + Rule 4 dither overlay + Rule 5 累积视觉)
> **关键约束**: 重要游戏信息(overtime / KPI 通过 / GAME OVER)必须**视觉 + 听觉双通道独立可达**(art-bible §7.4 双重编码 + Audio Rule 9 静音守门 反向 = R-LVS-4)。**信号双向触发禁止**

> **HUD #13 / Card Play UI #14 / Recap UI #15 / KPI Review UI #16(diegetic UI 订阅)** ↔ Lighting & Visual State Controller
> **流入** (UI → Lighting): 无(单向被订阅)
> **流出** (Lighting → UI): `scene_visual_changed(sub_mode)` 信号(可选订阅,UI 同步切色)
> **所有权**: UI owns 自身配色与 sub-mode 同步逻辑;Lighting owns 全局 CanvasModulate 与累积 sprite state(单 NPC `self_modulate` 归角色资产管线 owns,Lighting **不接管** 个别 NPC 立绘)
> **关键约束**: UI **不直调** `CanvasModulate.color`;`scene_visual_changed` 时序不保证早于 `scene_state_changed`(下游不可依赖时序差),需独立订阅适合自身需求的信号

> **Main Menu / Pause / Settings UI (#17)** ↔ Lighting & Visual State Controller
> **无直接契约** —— 累积 state 是 world state(非 settings),不流入 Settings UI;视觉 sub-mode 切换由 Scene Flow 驱动而非 Settings。Settings UI 仅消费视觉 theme(art-bible §7),非 Lighting 管控

> **Input Handler (#2)** + **Localization Hooks (#3)** —— 零视觉契约
> **流入 / 流出**: 无(对齐 Audio Manager Rule 11 零音频契约的视觉对偶)
> **所有权**: 完全解耦
> **测试断言**: `InputHandler` 全信号序列 + `LocalizationHooks.set_locale(any)` → Lighting 无任何 visual state 变更

> **Tutorial #18 [VS]** + **Accessibility #20 [Alpha]**(预留)
> **流入**: Tutorial 可能订阅 `scene_visual_changed` 同步教学步骤上下文;Accessibility 可能注入 high-contrast / colorblind palette LUT(扩展 palette_index 域)
> **所有权**: 两者 GDD 待写,本系统仅声明 `palette_index` LUT 可扩展为 Accessibility 模式(Accessibility GDD 阶段决定具体 LUT)

## Formulas

**N/A — 无独立公式需求**(同 Save / Audio 同质,系统数学嵌于 Rules 与 Tuning Knobs)。

理由: Lighting & Visual State Controller 的"数学"全部为阈值常量 + 颜色查表 + 简单线性 Tween 插值,已嵌入对应 Rule 与 Tuning Knobs 章节,不构成独立 formula 范畴(对照 Localization Section D F1 reflow latency / F2 coverage ratio,Lighting 无类似 scaling / linear / ratio 关系):

- **CanvasModulate Tween 0.3 s 线性插值**: Godot 标准 `tween_property` linear interpolation,Rule 1 已锁,无变量
- **palette_index uniform 切换**: 离散 enum 跳变(`roundi(tween_value)`),非数学公式 —— Rule 3 已锁
- **dither overlay 强度 Tween (0 → 0.35)**: Tween 线性插值,Rule 4 已锁,Bayer 4×4 阈值是 const matrix 非 formula
- **累积 state sprite variant 索引(如 `clamp(desk_stain_count, 0, 4)`)**: 单变量 clamp,Rule 5 已锁内嵌
- **`notice_board_age` 衰减系数 × 0.6 / 4 层上限**: 离散 alpha 阶梯,Rule 5 + Rule 7 已锁
- **8 sub-mode 颜色查表**: Rule 1 表格化常量映射,非函数关系
- **`#FFD700` / `#FFA500` 系金色检测**(R-LVS-1 lint): 字符串前缀比较,非数学

**对照已设计系统**:
- Save Section D / Audio Section D: 也无 formula(系 schema + lifecycle 性质)
- Input / Localization Section D: 有真公式(deadzone / D-Pad repeat / reflow latency / coverage ratio)
- Lighting: 系统性质同 Save / Audio,核心是颜色查表 + Tween + state schema,无 mathematical relationships

**未来 revisit 触发条件**:
- 引入动态光照(Light2D / 后期处理 / HDR)— 触发 F1 light attenuation / F2 tonemapper formula
- 引入累积 state 衰减曲线(替代当前线性 ×0.6 alpha)— 触发 F3 alpha decay formula
- 引入空间色温梯度(替代区域色温 4 档锁定)— 触发 F4 spatial color blend

野心版若上线动态光照 / 衰减曲线 / 色温梯度,本节须补 formulas。MVP scope 内本节确认 **N/A**。

## Edge Cases

32 edges / 10 categories,**5 [RISK GUARD]** R-LVS-1..5 守门。5 新 OQ-LVS-E1..E5。

### 1. Boundary Values

- **If `LIGHTING_LOADING_WATCHDOG_MS` < 5000 ms**: 合法 preload 场景(HDD + AV 扫描 + main save 读)可达 3-4 s;<5000 ms 误触 watchdog → 强制转 READY,但 `load_accumulation_state` 可能尚未注入 → 累积 state 重置为默认。Resolution: 下界 5000 ms 硬守。
- **If `canvas_modulate_tween_sec` = 0.15 s 边缘**: 9 帧 Tween,相邻 sub-mode 大色差(`#D0C8A8` → `#8090B4`)切换近突变,触 art-bible §8.6 "禁突变"边界。Resolution: <0.2 s 须 art-director sign-off。[OQ-LVS-E1]
- **If `dither_intensity_overtime` = 0.50 上界**: 全屏 50% 点阵,跃升为"艺术滤镜"超 art-bible §6.2 点缀边界。Resolution: art-director playtest 主观验。[OQ-LVS-E1]
- **If `set_scene_visual` 收到未识别 sub-mode 字符串**(拼错 / 非白名单): READY 态 `push_error` + 保持 CanvasModulate 不变;LOADING 态错误 + 不入 queue。**不静默忽略**(tone defect QA 须见)。
- **If `palette_index` 越界 [0, 7]**: shader 采样 LUT 越界 UV → Nearest 钳位边缘色。Resolution: `set_shader_parameter` 前 `clamp(index, 0, 7)` + `push_error` + clamp to 0(default day)。CI lint 须验 sub-mode → palette_index 映射无越界。

### 2. Asset Lifecycle

- **If `pal_lut_office_8xN.png` 启动时缺失**: `ResourceLoader.load` 返 null → palette_swap shader 无 LUT 数据,所有 sprite 输出 src 色(无 swap)。Resolution: `_ready()` 验加载结果,null `push_error` + 继续运行(降级);CI asset integrity check 验 LUT 文件存在。**[RISK GUARD — R-LVS-4 视觉降级路径]**:CanvasModulate 不依赖 LUT,视觉状态变化仍可独立识(art-bible §7.4 双重编码),P2 defect 非 P0。
- **If `dither_overlay.gdshader` 缺失**: ColorRect 得 null material → `ACTION_OVERTIME` 进入时 `visible=true` 但无 shader → 白色矩形覆盖。Resolution: `_ready()` 验,失败 dither 永久 `visible=false`;overtime 视觉降级仅 CanvasModulate `#8090B4`,P2。
- **If 累积 sprite atlas `env_atlas_accumulation.png` 缺失**: `AtlasTexture.atlas = null` → placeholder 粉色矩形。Resolution: 美术管线 CI asset check 验 atlas 文件 + frame_coords 在维度内;运行时降级 placeholder,P2,不影响 CanvasModulate / dither。
- **If LUT atlas 行数 < `palette_index` 范围**: shader UV Y > 1.0 → Nearest 钳位最后一行,输出错误 palette。Resolution: `_ready()` 检查 atlas height ≥ expected_palette_count,不符 `push_error` + clamp `palette_index = 0`。CI lint 验 LUT 行数 ≥ 注册调色板数。[OQ-LVS-E2]

### 3. State Machine Race(LOADING / READY)

- **If LOADING 期 `set_scene_visual(X)` 后 `set_scene_visual(Y)`**: pending queue size=1 覆盖,Y 覆盖 X,READY 后只应用 Y(对齐 Save Rule 13 snapshot 合并)。已在 Rule 2 锁定。
- **If `_mark_ready()` 由非 Scene Flow 节点调用**: 私有方法外部调 `push_error("[LightingManager] _mark_ready() must only be called by Scene & Day Flow #6")` + 拒绝执行,state 保持 LOADING。**[RISK GUARD — R-LVS-2]** 守门:若连 Scene Flow 合法调用也未发生,10 s watchdog 强制转 READY。
- **If LOADING 期同帧 `load_accumulation_state(payload)` + `set_scene_visual(sub_mode)`**: load 同步写内存累积 state,set 入 pending queue。两操作独立无 shared state 写冲突。`_mark_ready()` 内部 sequence:**先应用累积 state sprite swap,再 flush pending sub-mode Tween**(避免首帧桌面 flicker)。[OQ-LVS-E3]
- **If LOADING watchdog 10 s 触发,pending queue 含 `set_scene_visual("MORNING_BRIEFING")`**: watchdog `push_error` + 强制转 READY + flush queue(执行 MORNING_BRIEFING Tween)。`load_accumulation_state` 未调到 → 累积 state 全默认(0/0/0/0,等同新存档视觉)。**[RISK GUARD — R-LVS-2]**: P1 defect(累积 state 丢失),须查 Scene Flow #6 启动序列 bug。AC 须含 watchdog trigger 路径断言。

### 4. CanvasModulate / Shader Tween Race

- **If 同帧 `set_scene_visual(X)` 后 `set_scene_visual(Y)`**: Tween X 未 start,Y 覆盖。Resolution: 旧 Tween 活跃则 `tween.kill()` + 以**当前 CanvasModulate.color**(中间插值)为起点启动新 Tween 至 Y。不跳变,palette_index 同帧覆盖提交。[OQ-LVS-E3]
- **If dither Tween 渐入(0 → 0.35)中 `set_scene_visual` 切离 `ACTION_OVERTIME`**: dither 须立即切方向,从当前 dither_intensity 中间值淡出 0.3 s → 0,再 `visible=false`。**禁直接 `visible=false`**(跳变)。
- **If `WM_FOCUS_OUT` 在 CanvasModulate Tween 进行中**: Rule 9 `pause_tween()`,Tween 暂停在当前插值色;dither `visible` 不变;palette_index 已写不变。`WM_FOCUS_IN` `resume_tween()` 从暂停点续。**禁** resume 时重置 Tween 至起点(颜色闪回)。

### 5. 累积 State Edge

- **If `desk_stain_count` 达 cap 52**: clamp(count, 0, 4)→ sprite 已第 4 级饱和。再 `apply_accumulation` count 维持 52,不再 +1,**不 emit `accumulation_changed`**(无 autosave 触发),静默 cap。"桌面永远这么脏"叙事一致。
- **If `notice_board_age` Array 达 `NOTICE_BOARD_MAX_ENTRIES = 24` + 新月触发**: **[RISK GUARD — R-LVS-5]** FIFO 驱逐:remove `[0]`(最旧)+ 既有元素 +1 + append(0),Array 长度保持 ≤ 24。**不扩容**,**不静默丢弃新月**(打断叙事时间线)。`accumulation_changed` emit,Save 体积稳定 ~192 bytes。
- **If `anniversary_year` 达 cap 10**: clamp 不 +1,横幅维持第 10 级 sprite。`accumulation_changed` 不 emit(value 未变)。"奋斗 10 周年永久横幅"叙事符合 Pillar 4。[OQ-LVS-E4]
- **If 4 累积维度同帧全部触发**(周年 + 月末 + 季末 + 周末同时): 4 次 `apply_accumulation` 串行(< 0.4 ms 合计),4 次 `accumulation_changed` emit;Scene Flow 合并 → 1 次 autosave(Save Rule 3 防抖)。无 visual race,4 sprite 独立节点。

### 6. 跨系统 Race

- **If `LocalizationHooks.set_locale(any)` 期间 CanvasModulate Tween 进行中**: Lighting 不订阅 Localization 信号(Rule 8 零契约)。`NOTIFICATION_TRANSLATION_CHANGED` 广播,Lighting 无反应。Tween 继续,palette / dither 不变。AC 断言:`set_locale(any)` → Lighting 无 visual state 变更。
- **If Audio Master = -60 dB(全静音)+ `ACTION_OVERTIME` 进入**: **[RISK GUARD — R-LVS-4]** Rule 11 静音守门:Lighting 不检查 / 不等待 Audio 状态。`scene_state_changed("ACTION_OVERTIME")` 触 CanvasModulate `#8090B4` Tween + dither overlay 渐入**照常执行**。视觉路径独立可达。AC 断言 Master = -60 dB 下 overtime / KPI / GAMEOVER 视觉切换功能完整。
- **If Save `load_accumulation_state` payload schema 落后**(旧存档缺 `break_room_cracks` 字段): **[RISK GUARD — R-LVS-3]** `payload.get(key, default_value)` 防御性读,缺字段 fallback 默认(0 / 空 Array)。`push_warning("missing field '[field]' — using default")` dev log。LOADING 正常完成,对齐 Save Rule 11 损坏处理。
- **If Input modal lock 期间 CanvasModulate Tween 进行中**(暂停菜单弹出): Lighting 不订阅 Input。Tween 继续,modal lock 透明。CanvasModulate global,modal UI 浮于上层 CanvasLayer,各自渲染。

### 7. Performance / Pillar 5

- **If CanvasModulate Tween 100 帧连续切换**(5 次 sub-mode 快速 swap): 每 Tween 开始 `tween.kill()` 终前 Tween;任意时刻活跃 ≤ 1。100 × (kill + create) ≈ 0.2 ms,无 Tween 对象泄漏。
- **If dither overlay ColorRect 启动时不在场景树**(Shader Baker 未覆盖): 首次 overtime 进入 frame hitch(shader 即时编译 2-30 ms spike)。Resolution: CI 场景结构验证须断言 ColorRect 节点存在于根场景树。**[OQ-LVS-E5]**
- **If dither overlay 跑 4K(3840×2160)**: 像素数 4×,~1.2 ms,16.6 ms 帧预算内。Rule 10 性能契约 4K 仍满足。CI 基线锁 1080p,4K 平台上线前补实测。[OQ-LVS-E1]
- **If `load_accumulation_state` payload 病态大**(恶意构造 `notice_board_age` 1000 元素): load 时验 Array len ≤ 24,超限 FIFO 截取末 24 + `push_warning`。防 LOADING 期注入超大 state 致后续 FIFO 失效。

### 8. Pillar 1+4 反讽红线 Violation

- **If 上层 #16 KPI Review UI 直调 `CanvasModulate.color = Color("#FFD700")`**(绕过 Lighting): **[RISK GUARD — R-LVS-1]** Rule 1 禁直调。若发生:CanvasModulate 立刻金,下帧 Lighting Tween 覆回 `#3A3050` → 1 帧金色闪烁。Resolution: CI lint `CanvasModulate.color\s*=` 扫描 non-LightingManager `.gd` → CI FAIL。**R-LVS-1 二重守门**:lint 检测颜色表内不含 `#FFD700` / `#FFA500` 系 + 禁直调。
- **If `anniversary_year >= 1` 且横幅 sprite `self_modulate` 被改为庆祝金色**(art-director 误改): non-overtime 应 `#E8609A` 俗艳粉 + 2 px `#2A1F14` 黑框(art-bible §4.6)。Resolution: art-director 资产 review gate 核 banner sprite `self_modulate` 不含金色;CI asset color lint 扫 `.tres` material。[OQ-LVS-E4]
- **If `ACTION_OVERTIME` palette 视觉读为"heroic" 而非 "physical distortion"**: 主观 tone defect,无 lint 可捕。Resolution: art-director + game-designer first playtest 主观验 `#8090B4` + dither 整体读感为"荧光灯疲劳"非"英雄蓝光"。Tone defect 不设 CI lint,human review gate。[OQ-LVS-E1]
- **If R-LVS-1 CI lint `--no-verify` 绕过**: pre-commit skip 不影响 CI gate。CI 独立 lint run 仍 FAIL。bypass 入 prod = 1 帧金色闪 P1 visual defect → hotfix。

### 9. Godot 4.6 Specific

- **If D3D12 Windows 默认 backend**: palette + dither shader Forward+ CanvasItem 透明支持。唯一风险:首次 D3D12 run shader PSO cache 额外延迟(≤200 ms,Loading Scene 内)。Shader Baker 覆盖。
- **If WorldEnvironment Tonemapper 误启 AgX**: art-bible §4.1 hex 色在 AgX 后偏移(`#B05A28` → 偏黄绿,`#8090B4` → 偏紫)。Rule 11 **禁** AgX,`project.godot` 显式锁 Filmic 或 Linear。违反 = P0(所有颜色表失效)。CI 验 `tonemap_mode ≠ AgX`。
- **If Shader Baker 未覆盖 dither overlay**(ColorRect 不在场景树): Baker 缺失 → frame hitch。Rule 4 + 此 edge 双重锁"ColorRect 须常驻根场景树,**永不 `queue_free()`**"。
- **If Dual-focus(Godot 4.6)与 Lighting 节点交互**: Lighting 是纯 CanvasItem 节点(CanvasModulate / CanvasLayer / ColorRect),无 Control 焦点逻辑。Rule 11 已锁完全不受 dual-focus 影响。

### 10. art-bible 一致性

- **If `CanvasModulate.color` 误用纯黑 `#000000` 而非 `#2A1F14`**(实现笔误): art-bible §4.1 禁纯黑 → 0 multiply 全场景全黑。Resolution: CI lint 扫 Rule 1 颜色表无 `#000000`;运行时误传 → clamp `#2A1F14` + `push_error`。
- **If art-bible §6.4 4 元素之一从资产库删除**(art-director 决定砍): Rule 7 state schema 仍在,接口仍 emit;sprite 缺失 → null atlas placeholder。Resolution: art-director 删资产须同步 PR 修 Rule 7 state schema + 移除 atlas catalogue —— **双文件原子变更**。Lighting GDD 资产清单 + art-bible §6.4 双向同步。
- **If `apply_crisis_tilt(angle_deg)` 桩调用** 收到 [2.0, 3.0] 范围外值(art-bible §3.2 桩接口,MVP 不实现): 桩接受参数但实现体空(MVP 不执行)。野心版实现时补 `clamp(angle_deg, 2.0, 3.0)` + `push_error` 越界。**MVP build 中此方法调用后无视觉变化是预期行为**。

### 新增 Open Questions(OQ-LVS-E1..E5)

| ID | 问题 | Owner | 目标 |
|----|------|-------|------|
| OQ-LVS-E1 | `canvas_modulate_tween_sec = 0.15 s` + `dither_intensity_overtime = 0.50` 主观 tone 验证;4K dither overlay ≤ 1.2 ms 实测 | art-director + qa-lead | first playtest build |
| OQ-LVS-E2 | LUT atlas 行数 vs palette_index 范围 lint 实现:Editor Tool 读 atlas image size 方式 | godot-gdscript-specialist + technical-artist | ADR |
| OQ-LVS-E3 | `_mark_ready()` 内部 flush 顺序(累积 state 先于 Tween)Godot 4.6 同帧 `AtlasTexture.region` + Tween start 渲染顺序无 FOUC 实测 | godot-specialist + qa-lead | Prototype |
| OQ-LVS-E4 | `anniversary_year` cap 10 叙事 legitimacy + banner gold lint 范围(扫 `.tres` material self_modulate) | game-designer + art-director | GDD review 前 |
| OQ-LVS-E5 | Shader Baker ColorRect 常驻 CI 验证方案:场景树 JSON diff vs headless export-debug shader cache 覆盖率 | godot-specialist + technical-director | Pre-Production CI 设计 |

**5 [RISK GUARD] 总览**:

| RISK GUARD | Cat 实现位置 | 保护目标 | 对齐系统 |
|---|---|---|---|
| R-LVS-1 | Cat 8 | KPI 通过切金光胜利 — Pillar 4 反讽红线 | Audio R-AUD-1 / Loc R-LOC-4 |
| R-LVS-2 | Cat 3 | LOADING watchdog 10s — Pillar 5 永久卡死 | Audio R-AUD-3 / Loc R-LOC-3 |
| R-LVS-3 | Cat 6 | accumulation_state schema 兼容 — 累积 state 注入 | Audio R-AUD-1 fallback / Save Rule 11 |
| R-LVS-4 | Cat 2 + Cat 6 | 视觉双重编码 — 静音下视觉独立可达 | Audio R-AUD-5 / art-bible §7.4 |
| R-LVS-5 | Cat 5 | notice_board_age 无限增长 — Save 体积蔓延 | Save Rule 6 + Rule 13 |

## Dependencies

### Upstream Dependencies(本系统依赖)

**None structurally.** Lighting & Visual State Controller 是 Foundation Layer 根节点,仅依赖 Godot 4.6 引擎 API(`CanvasModulate` / `Tween` / `ShaderMaterial` / `AtlasTexture` / `CanvasLayer` / `ColorRect` / `NOTIFICATION_WM_WINDOW_FOCUS_OUT`)和 art-bible §2 / §3.2 / §4 / §6 / §8 锁定值。

**软依赖**(不阻 Lighting 核心功能但提供必要数据流):
- **Save System #1**(via Rule 5 累积 state 持久化):启动期由 Scene Flow 注入累积 state payload;运行期 Lighting emit `accumulation_changed` → Scene Flow 协调 `Save.request_autosave()`。**main save 路径,非 settings**,与 `meta_settings_debounce_ms` 解耦
- **art-bible**(锁定 source of truth):§2 时钟光语 6 场景 / §4 调色板 / §6.4 环境叙事 4 元素 / §6.5 累积视觉 4 维度 / §8.6 渲染哲学(零 Light2D + CanvasModulate)/ §8.4 palette swap shader / §8.8 ≤ 10 shader 上限

### Downstream Dependents(依赖本系统的)

| # | System | Tier | Type | Interface(摘要) | 反向文档 | 必要 |
|---|--------|------|------|--------------------|---------|------|
| 1 | **Save System** | MVP / Foundation | **Hard** | `accumulation_changed(type, value)` 信号 → Scene Flow 协调 `request_autosave()`;启动期 Save 提供 `current_run.save > world.accumulation` payload(main save 非 settings) | ✅ Save Rule 3 autosave 触发链 + Rule 14 settings 路径解耦(累积 state 走 main save) | ✅ 必须 |
| 6 | **Scene & Day Flow Controller ⭐** | MVP / Core | **Hard** | 启动调度 `load_accumulation_state(payload)` + `_mark_ready()`(私有 only Scene Flow 可调);运行期 emit `scene_state_changed(sub_mode)` / `kpi_review_started` / `game_over_triggered` / `accumulation_event(type, delta)`;LOADING watchdog 10 s 强制 override | 未设计 — #6 GDD 须列入 Lighting 启动序列 + `_mark_ready()` 私有调用授权 + `scene_state_changed` 8 sub-mode enum 名称契约 + `accumulation_event` 触发节奏(每周日 / 月 1 号 / 季末 / 周年) | ✅ 必须 |
| 4 | **Audio Manager** | MVP / Foundation | **Parallel(无契约)** | 与 Lighting **平行系统**,均订阅 Scene Flow `scene_state_changed`,各自独立 dispatch(audio-visual 对偶,art-bible §7.4 双重编码) | ✅ Audio Rule 6 ambient layer schema 与 Lighting Rule 1 sub-mode 1:1 同源,均订阅同信号 | ✅ MVP 必须(双通道独立可达) |
| 13 | **HUD System (Diegetic)** | MVP / Presentation | Soft | 可选订阅 `scene_visual_changed(sub_mode)` 信号同步 UI 配色;**不直调** `CanvasModulate.color`(Lighting owns 全局)| 未设计 — #13 GDD 可选订阅 | 可选 |
| 14 | **Card Play & Dialogue UI** | MVP / Presentation | Soft | 同 #13 | 未设计 | 可选 |
| 15 | **Daily / Weekly Recap UI** | MVP / Presentation | Soft | 同 #13 | 未设计 | 可选 |
| 16 | **KPI Review & Game Over UI** | MVP / Presentation | Soft | 同 #13 + GAME OVER 片尾曲红 `#E03020`(≤ 8% UI 叠加,art-bible §4.6)由 #16 渲染,Lighting 只切 `KPI_REVIEW` / `GAMEOVER` sub-mode 提供 `#3A3050` 深蓝灰 base | 未设计 — **#16 GDD 必含 R-LVS-1 反讽红线 visual 验证(KPI 通过不切金光)** | ✅ MVP 必须(Pillar 4 反讽锚) |
| 17 | **Main Menu / Pause / Settings UI** | MVP / Presentation | **None** | 累积 state 是 world data(非 settings),不流入 Settings UI;视觉 theme 由 art-bible §7 owns,非 Lighting 管控 | 未设计 — 无 Lighting 接口 | 不需要 |
| 18 | **Tutorial / Onboarding** | VS / Feature | Soft(预留)| 可订阅 `scene_visual_changed` 同步教学上下文 | 未设计(VS 推迟) | 可推迟 VS |
| 20 | **Accessibility Options** | Alpha / Polish | Soft(预留)| 可注入 high-contrast / colorblind palette LUT(扩展 `palette_index` 域,art-bible §4.5 色盲安全已锁基础);可触发额外 sub-mode 视觉变体 | 未设计(Alpha 推迟) | 可推迟 Alpha |

### 双向一致性核对(coding-standards 强制规则)

**已 Approved 的 GDD 反向一致性**:
- **Save System (#1)** ✓ — Save Rule 3 autosave 触发链 + Rule 14 settings 路径(累积 state 走 main save 非 settings,explicit decoupling 已在 Lighting Rule 5 + Save Rule 14 互为标注)
- **Input Handler (#2)** ✓ — Input 与 Lighting 无契约(Audio Rule 11 同质 — 零视觉-Input 契约)
- **Localization Hooks (#3)** ✓ — Localization 与 Lighting 无契约(locale switch 不影响 CanvasModulate)
- **Audio Manager (#4)** ✓ — Audio Rule 6 ambient + Rule 9 静音守门 与 Lighting Rule 8 audio-visual 对偶 + Rule 11 静音守门 双向锁

**未设计的下游 GDD,编写时各自必须**:
1. 自身 Dependencies 章节列入 **"Lighting & Visual State Controller (#5)"** 作为 dependency(若有视觉切换需求)
2. 引用本 GDD **Rule 1** 8 sub-mode 颜色表(若需 UI 配色同步)
3. 引用本 GDD **Rule 6** Pillar 4 反讽红线(尤其 #16 KPI Review)
4. 引用本 GDD **Rule 8** audio-visual 对偶契约(若涉及双通道信息呈现)
5. **#16 KPI Review & Game Over UI** 须实现 `_BUREAUCRATIC` 视觉对偶 + R-LVS-1 反讽验证(对齐 Audio R-AUD-1 + Localization `GAMEOVER.TITLE_IRONY` 三轨守门)
6. **#6 Scene & Day Flow Controller** 须实现 8 sub-mode `scene_state_changed` 信号 + `accumulation_event` 触发节奏 + `_mark_ready()` 调用契约
7. 凡涉及 dieg etic UI 视觉(#13/14/15/16)可选订阅 `scene_visual_changed` 信号(非强制,UI 自决)

### 跨 GDD 影响清单(若本 GDD 后续 revise)

- **Save System #1** — `current_run.save > world.accumulation` schema 变更 → 影响 main save schema_version + R-LVS-3 守门 fallback 逻辑
- **Audio Manager #4** — Rule 8 audio-visual 对偶 1:1 sub-mode 映射变更 → 双向 cross-check art-bible §2 时钟光语
- **Scene & Day Flow #6** — 8 sub-mode enum 名称 / `accumulation_event(type)` 命名 / `_mark_ready()` 时序 → 影响演出 + 启动序列
- **HUD #13 / Card #14 / Recap #15 / KPI Review #16** — `scene_visual_changed` 信号 + 8 sub-mode 颜色表(若 UI 同步配色)
- **art-bible §2 / §6.5 修订** — Rule 1 颜色表 + Rule 5 累积 state schema cascade 同步

## Tuning Knobs

### Numeric Knobs(本 GDD 内部 owning)

| Knob | Default | Safe Range | 极端行为 | 来源 |
|------|---------|------------|---------|-------|
| `LIGHTING_LOADING_WATCHDOG_MS` | 10000 | [5000, 30000] | <5000: 合法长 preload 误触 / >30000: Scene Flow bug 卡死延久 | Rule 2 / R-LVS-2 |
| `canvas_modulate_tween_sec` | 0.3 | [0.15, 0.6] | <0.15: 突变不平滑 / >0.6: 切换感觉拖沓违 Pillar 5 | Rule 1 / art-bible §8.6 |
| `dither_intensity_overtime` | 0.35 | [0.20, 0.50] | <0.20: 几乎不可见无 overtime 视觉差 / >0.50: 全屏明显 dither 违 art-bible §6.2 "点缀" | Rule 4 / OQ-LVS-02 |
| `dither_fade_in_sec` | 0.5 | [0.3, 1.5] | <0.3: 突兀 / >1.5: 玩家已感受 overtime 但 dither 未到 | Rule 4 |
| `NOTICE_BOARD_MAX_ENTRIES` | 24 | (硬常量,2 年月数)| 变更须 review art-bible §6.5 + Save 体积约束 | Rule 5 / R-LVS-5 |
| `desk_stain_count_max` | 52 | (硬常量,1 年周数)| 上限 cap 防长跑无限增长 | Rule 5 |
| `break_room_cracks_max` | 16 | (硬常量,4 年季度)| 上限 cap | Rule 5 |
| `anniversary_year_max` | 10 | (硬常量,极端长跑保护)| 超 10 后视觉 saturate | Rule 5 / OQ-LVS-03 |
| `whiteboard_alpha_decay` | 0.6 | [0.4, 0.8] | <0.4: 旧层过淡难辨 / >0.8: 旧层与新层混杂噪点 | Rule 7 §6.4 #5 |
| `whiteboard_max_layers` | 4 | [2, 8] | >8: 视觉噪点过载 | Rule 7 |
| `npc_traffic_threshold` | 3 | [1, 6] | 触发 stepped 快递盒 variant 阈值 | Rule 7 §6.4 #4 |

### Empirical Constants(性能基线,非 designer 调整)

| Constant | Default | 来源 | 变更触发 |
|---------|---------|------|---------|
| `T_canvas_tween_overhead` | < 0.2 ms | 18 帧 Tween 总开销基线 | Godot 4.6 升级 / Tween API 变 |
| `T_palette_swap_per_sprite` | < 0.1 ms | LUT 8×N px L1 cache 采样 | LUT 维度变更 |
| `T_dither_overlay_full_screen` | < 0.3 ms | Bayer 4×4 全屏(1920×1080)pure math | 算法替换(Sobel / SDF)触发重测 |
| `T_accumulation_sprite_swap` | < 0.1 ms / 4 字段 | `AtlasTexture.region` 赋值基线 | 同 atlas vs 多 variant 文件切换 |

### Color Palette(art-bible §4 引用,非本 GDD owning)

8 sub-mode `CanvasModulate` 基色见 Rule 1 表;art-bible §4.1 7 色主调色板 + §4.6 4 点缀色 + §4.3 5 区域色温为 source of truth。**本 GDD 不复定义颜色值**,仅锁 sub-mode → 颜色映射。

### 跨 GDD Tuning Knob(引用,不 owning)

| Knob | Owner GDD | Value | 与 Lighting 关系 |
|------|-----------|-------|---------------|
| `meta_settings_debounce_ms` | Save (#1) Rule 14 | 500 ms | **不消费此 knob** —— 累积 state 走 main save 非 settings,explicit decoupling |
| `AUDIO_LOADING_WATCHDOG_MS` | Audio Manager (#4) | 10000 ms | 同模式同值(`LIGHTING_LOADING_WATCHDOG_MS = 10000`),与 Localization `locale_lock_watchdog_ms = 30000` 不同尺度(Loc 演出 lock,Audio/Lighting 启动 LOADING) |
| Tonemapper | `project.godot` WorldEnvironment | **Filmic**(锁) | Rule 11 + OQ-LVS-tonemapper:**禁** AgX,art-bible §4.1 hex 色在 AgX 后偏移 |
| `audio_bank_total_size_mb` | Audio (#4) | 30 MB | 听觉等价于 art-bible §8.5 显存预算约束;Lighting 总显存 < 0.1 MB 远低 |

### Sprite Variant Catalogue(指向 atlas,非 knob)

29 条 audio asset 由 sound-designer 交付(Audio GDD G);Lighting 累积视觉 sprite variants 由 art-director 交付,domain 摘要分布:

| 类别 | 数量 | atlas 路径 | 资产命名 |
|------|------|-----------|---------|
| 桌面脏渍 5 级 | 5 | `assets/sprites/env/atlas/env_atlas_accumulation.png` | `env_desk_stain_week[1-4]_16x16.png` + 第 4 级稳定 |
| 通知栏多层 | N(动态) | 同 atlas | `env_notice_board_age[0-N]_16x16.png` |
| 茶水间裂缝 4 级 | 4 | 同 atlas | `env_wall_crack_q[1-4]_32x16.png` |
| 周年横幅 | N(动态)| 同 atlas | `env_banner_anniversary_y[1-N]_64x16.png` |
| §6.4 环境叙事(假绿植 / 签名 / 快递盒 clean&stepped / 白板笔迹 4 层)| ~10 | 同 atlas | `env_plant_fake_4x4.png` 等 |

### palette LUT atlas(art-bible §8.4)

| 文件 | 维度 | 采样 | 路径 |
|------|------|------|------|
| `pal_lut_office_8xN.png` | 8 列 × N 行(N 初期 ≤ 4 板,扩展 ≤ 8)| sRGB=off,filter=Nearest,< 0.1 MB | `assets/palettes/` |

### Localizable Strings

**无** — Lighting 不 own 任何文本,Visual/Audio Requirements 节亦无音频/视觉文本资产由本系统拥有。所有 dieg etic UI 文本由 Localization Hooks #3 管。

## Visual/Audio Requirements

Lighting & Visual State Controller **本身就是视觉系统** —— audio 配套等价于"audio-visual 对偶"契约(已在 Rule 8 锁定),非独立 visual asset 列表。

### Audio-Visual 对偶契约 — 跨 GDD 视觉↔听觉同源

| 8 sub-mode | Lighting 视觉行为(Rule 1)| Audio 行为(Audio Manager Rule 6) |
|-----------|---------------------------|---------------------------------|
| `MAIN_MENU` | CanvasModulate `#C8C4B8` 冷白 | `FLUORESCENT_HUM` -18 dB + `AC_LOW_HISS` |
| `MORNING_BRIEFING` | `#D4D0C8` 均匀冷白 | 同主菜单不加层 |
| `ACTION_DAY` | `#D0C8A8` 打工人黄 + dither off | `KEYBOARD_RHYTHM` crossfade in 0.5 s |
| `ACTION_OVERTIME` | `#8090B4` 蓝光 + dither overlay 渐入 0.5 s | `SCREEN_BUZZ_OVERTIME` 渐入 2 s 无 stinger |
| `AFTER_WORK` | `#B05A28`(day)/ `#6878A0`(overtime)| 延续当前 ambient 不变 |
| `DAILY_RECAP` | `#C8A060` 地铁暖黄 | `KEYBOARD_RHYTHM` crossfade out 1 s |
| `KPI_REVIEW` | `#3A3050` + 红光 UI 叠加 | Music `ENDGAME_LOOP_BUREAUCRATIC` fade in 1.5 s + Ambient duck -6 dB |
| `GAMEOVER` | `#3A3050` 保持 + 片尾曲红 `#E03020` ≤ 8% UI(art-bible §4.6) | Ambient fade out 2 s + Music `CREDITS_OUTRO_BUREAUCRATIC` |

**关键约束**: 视觉与听觉**并行响应同信号 `scene_state_changed`,绝不互相触发** —— art-bible §7.4 双重编码 + Audio Rule 9 静音守门反向 = R-LVS-4 守门:重要游戏信息(overtime / KPI / GAME OVER)必须**视觉 + 听觉双通道独立可达**,任一通道失败不连带另一。

### Visual Asset Catalogue(本系统 own)

| 类别 | 数量 | 路径 | 备注 |
|------|------|------|------|
| **palette LUT atlas** | 1(8 列 × N 行,N 初期 ≤ 4 → 扩展 ≤ 8) | `assets/palettes/pal_lut_office_8xN.png` | sRGB=off,filter=Nearest,< 0.1 MB(art-bible §8.4) |
| **palette swap shader** | 1 ubershader | `assets/shaders/palette_swap.gdshader` | `palette_index: int` uniform,art-bible §8.4 |
| **dither overlay shader** | 1 全屏 | `assets/shaders/dither_overlay.gdshader` | Bayer 4×4,2bit,art-bible §6.2 / §8.6 |
| **累积 sprite atlas** | 1 | `assets/sprites/env/atlas/env_atlas_accumulation.png` | 含桌面脏渍 5 级 / 通知栏 N 层 / 茶水间裂缝 4 级 / 周年横幅 N 级 / §6.4 4 元素;art-bible §8.7 同 atlas 零额外内存 |
| **ColorRect 节点(dither overlay 容器)**| 1 节点常驻 | scene tree 根级 CanvasLayer (layer=128) | Shader Baker 必备(永不 `queue_free()`) |

### Audio 制品引用(由 Audio Manager #4 owns,Lighting 不 own)

- `AMBIENT.OFFICE.SCREEN_BUZZ_OVERTIME` → 与 Lighting `ACTION_OVERTIME` sub-mode dither overlay 同源
- `MUSIC.KPIREVIEW.ENDGAME_LOOP_BUREAUCRATIC` → 与 `KPI_REVIEW` sub-mode `#3A3050` 同源
- `MUSIC.GAMEOVER.CREDITS_OUTRO_BUREAUCRATIC` → 与 `GAMEOVER` sub-mode `#E03020` 片尾曲红 UI 同源
- `SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC` → KPI 通过结算视觉(收据热敏打印动画 #16 owns)同步

### Asset Spec Flag

> 📌 **Asset Spec** — Visual asset 清单已在本节(palette LUT / 2 shader / 累积 atlas)+ Section G(Sprite Variant Catalogue)。**Phase 4 Pre-Production 阶段须运行 `/asset-spec system:lighting-visual-state`** 由 art-director 产出每个 sprite variant + LUT 的具体绘制 brief(对齐 sound-designer audio brief 模式 + Localization CSV 模式)。Stories 引用 visual asset 时须 cite `production/visual-briefs/[asset_name].md`(待 art-director 交付)。

### Pillar 4 红线视觉禁止清单(art-bible §4 + 本 GDD Rule 6 锁)

`assets/sprites/` + 累积 atlas **绝不应出现**以下视觉变体(human review + lint 第二防线,对齐 Audio Pillar 4 红线 8 类 SFX 禁止清单):

1. **金光胜利场景**: 任何 `KPI_REVIEW` / `GAMEOVER` sub-mode 关联的金色调(`#FFD700` / `#FFA500` 系)CanvasModulate 切换或 sprite `self_modulate`
2. **英雄高光描边**: NPC sprite 在升职 / 加薪事件时被加白 / 金色 outline shader
3. **励志光环**: overtime 进入时角色周围光晕 / 加班"努力勋章"光效
4. **庆祝粒子**: 烟花 / confetti / 礼花视觉(art-bible §4.6 周年庆**俗艳粉**是讽刺,**禁** confetti)
5. **Controller 视觉反馈**: 手柄连接时屏幕亮起"已检测"动画(art-bible 无此类 + Audio Rule 4 同质禁)
6. **Save / Load 视觉特效**: "嗖咻"读写动画 / 数据传输光束(Input Section G + Audio Rule 4 同质零反馈)
7. **语言切换闪烁**: locale 切换时屏幕渐变 / 翻页动画(Localization 零音频 + 本系统零视觉切换契约)
8. **加班奖励光效**: 玩家选择"加班"时画面亮起"奖励"光圈(art-bible §2.4 加班选项卡是**商场促销标签**讽刺,非奖励)

**例外白名单**(非红线,合法视觉):
- 周年庆 `#E8609A` 俗艳粉横幅 + 2 px 黑框压住(art-bible §4.6 反讽锚)
- KPI Review `#3A3050` 深蓝灰 + `#E03020` 片尾曲红 UI 叠加(art-bible §2.6 仪式感)
- 老板金 `#C8963C`(≤ 3% 全画面,仅老板相关 UI / 物件;**禁** 普通交互高亮)
- 累积视觉(脏渍 / 通知 / 裂缝 / 横幅)— 玩家时间投入物化的**反讽证据**,非奖励

**禁** 普通 UI hover / focus / confirm 触发任何 CanvasModulate / 全屏 shader 视觉切换(对齐 Audio Rule 9 + Section B Tone 锚)。

## UI Requirements

Lighting & Visual State Controller 不 own UI 屏。**与 Settings UI 无契约** —— 累积 state 是 world data 而非 settings,不流入 #17 Main Menu / Pause / Settings UI。视觉 theme 由 art-bible §7 + 各 UI GDD 各自 own,非 Lighting 管控。

### 唯一 UI 接触面 — Diegetic UI 可选订阅

#13 HUD / #14 Card Play UI / #15 Recap UI / #16 KPI Review UI 可**可选订阅** `scene_visual_changed(sub_mode)` 信号同步 UI 配色:

- 信号时序不保证早于 `scene_state_changed`(Tween 完成后才 emit;`scene_state_changed` 是触发事件)
- 下游 UI 不可依赖时序差,须独立选择适合自身需求的信号订阅
- UI **不直调** `CanvasModulate.color`(Lighting owns 全局)

### #16 KPI Review & Game Over UI 强制契约(Pillar 4 反讽锚 R-LVS-1 守门)

**#16 GDD 必须实现**:
- KPI 通过结算 / 升职 / 周年庆视觉**绝不切金光胜利场景**;`KPI_REVIEW` sub-mode 接受 Lighting 提供的 `#3A3050` 深蓝灰 base,#16 仅在其上叠加 `#E03020` 片尾曲红 UI(≤ 8% 全屏,art-bible §4.6)+ 收据热敏打印视觉动画
- GAME OVER `GAMEOVER.TITLE_IRONY` Label(站酷快乐体 14 px,Localization Rule 9 + Audio Manager Rule 9 V/A 段共同锁)与 Lighting `GAMEOVER` sub-mode 视觉同步
- 反讽锚点跨 3 GDD 守门铁三角:**Lighting `KPI_REVIEW` 视觉静止 + Audio `_BUREAUCRATIC` SFX(打卡机 + 热敏)+ Localization `_IRONY` key 文字** —— 三轨同时拒绝庆祝

**📌 UX Flag — Lighting & Visual State Controller**: 本系统**无 UI 屏需 UX 设计**(全部视觉切换由 Scene Flow 信号驱动 + 各 UI 自决可选订阅)。**禁止** `/ux-design` 涉及 Lighting 系统(无 player-facing 设置交互)。任何"光线 / 视觉相关玩家配置"(如 Accessibility high-contrast variant,见 #20 GDD)归各对应 UI / Accessibility GDD 设计。

## Acceptance Criteria

27 条 AC 分 5 类: AC-FUNC 12 / AC-PERF 3 / AC-COMPAT 4 / AC-ROBUST 5 / AC-TONE 3。**5 [RISK GUARD]** AC(AC-ROBUST-01..05)守门 R-LVS-1..5 高风险路径,须在首个可测 build 优先验证。AC-TONE 沿用 Audio / Localization Section H 模式(Pillar 1+4 tone 守护)。

### ADR-0001 + ADR-0005 跟进追加(B-DEP-2 + B-DEP-3 守门)— 2026-04-28

- **AC-FAREWELL-01**(`#10 Rule 23` FAREWELL_EVENT_IDS 禁特殊 palette 契约): **GIVEN** LightingManager READY,debug 钩子拦截非 sub-mode 切换源对 `CanvasModulate.color` Tween 启动, **WHEN** `event_started(event_id, narrative_tier)` 到达且 `event_id ∈ EventScriptEngine.FAREWELL_EVENT_IDS`, **THEN** 不启动任何 farewell-specific palette swap Tween(继续当前 sub-mode CanvasModulate);若发生 → `push_error("ERR_LVS_FAREWELL: special palette forbidden during farewell event")` + CI FAIL。**Tier**: MVP。

- **AC-FAREWELL-02**(`#5` accumulation_event 单 owner 契约,ADR-0005): **GIVEN** LightingManager 持 4 累积维度 state(`yellowing_level` / `sticky_note_count` / `steam_density` / `npc_empty_chairs`), **WHEN** `npc_left_company(npc_id, reason)` 信号到达且 `reason ∈ [FAREWELL, DISMISSAL, PROMOTED_LEAVE, OPTIMIZED_OUT]`, **THEN** `accumulation_event(&"sticky_note_count", +1)` + `accumulation_event(&"npc_empty_chairs", +1)` 同帧 emit;`accumulation_event` 不允许由 `#6 Scene Flow` / `#13 HUD` 任何其他系统 emit(debug 钩子全程监控,违反 → CI FAIL);`#13 HUD` 仅订阅 visual variant 响应,不回调写 `#5` state。**Tier**: MVP。

### AC-FUNC

- **AC-FUNC-01** (Rule 1 CanvasModulate 颜色表 + 0.3 s Tween 线性): **GIVEN** READY,debug 钩子对 `CanvasModulate.color` 帧采样, **WHEN** Scene Flow emit `scene_state_changed(&"ACTION_DAY")` 后 0.5 s emit `scene_state_changed(&"ACTION_OVERTIME")`, **THEN** 两 Tween 各 0.3 s ± 0.02 s 线性插值至 `#D0C8A8` / `#8090B4`,曲线 `TRANS_LINEAR / EASE_IN_OUT`,Tween 期任意帧**不跳变**;Tween 完成后 `scene_visual_changed` 信号一次;`CanvasModulate` 节点数 = 1。

- **AC-FUNC-02** (Rule 1 禁上层直调 CanvasModulate): **GIVEN** debug 钩子拦截非 LightingManager 节点 `CanvasModulate.color =` 赋值, **WHEN** QA 触发 `KPI_REVIEW` 演出(含 #16 UI 订阅), **THEN** 赋值仅来自 LightingManager Tween callback,非 LightingManager 赋值计数 = 0;`KPI_REVIEW` 期最终 `#3A3050` ± 1 LSB。

- **AC-FUNC-03** (Rule 2 LOADING/READY + pending queue 覆盖): **GIVEN** LOADING, **WHEN** 依次调 `set_scene_visual(&"MORNING_BRIEFING")` + `set_scene_visual(&"ACTION_DAY")` 后 `_mark_ready()`, **THEN** LOADING 期不立即执行;`lighting_manager_ready` 一次;flush 仅应用最后 `ACTION_DAY`(覆盖语义);`apply_accumulation` LOADING 期**静默丢弃** + dev warning,不 crash。

- **AC-FUNC-04** (Rule 2 `_mark_ready()` 私有性): **GIVEN** 非 Scene Flow 节点持引用, **WHEN** 该节点调 `_mark_ready()`, **THEN** `push_error` + 拒绝;state 保持 LOADING;`lighting_manager_ready` 不发射。

- **AC-FUNC-05** (Rule 3 Palette Swap — sub-mode → palette_index 信号路径): **GIVEN** READY,palette_swap shader 已绑 LUT, **WHEN** Scene Flow emit `scene_state_changed(&"ACTION_OVERTIME")`, **THEN** `material.get_shader_parameter("palette_index")` 同帧 = 1;外部节点调 `set_shader_parameter("palette_index", N)` 被 debug 钩子捕获 CI FAIL `"ERR_LVS: external palette_index mutation"`;palette_index 始终 [0, 7],越界 clamp + `push_error`。

- **AC-FUNC-06** (Rule 4 Dither Overlay 生命周期): **GIVEN** READY,ColorRect 常驻 `visible=false`, **WHEN** Scene Flow emit `&"ACTION_OVERTIME"` 后 emit `&"ACTION_DAY"`, **THEN** 进入: `visible=true`,`dither_intensity` Tween 0 → 0.35 in 0.5 s ± 0.05 s;退出: Tween 至 0 in 0.3 s ± 0.02 s,**不**直接 `visible=false`(禁跳变);Tween 归零后 `visible=false`;非 overtime `visible=false` 时 GPU draw call 贡献 = 0(profiler 断言)。

- **AC-FUNC-07** (Rule 5 累积 state 注入 + sprite variant): **GIVEN** LOADING, **WHEN** Scene Flow 调 `load_accumulation_state({"desk_stain_count":3, "notice_board_age":[5,2,0], "break_room_cracks":7, "anniversary_year":2})` + `_mark_ready()`, **THEN** `_mark_ready()` 内部顺序:**先累积 sprite swap,再 flush Tween**(避免首帧 flicker);desk=3 → 第 3 级脏渍 frame_coords;cracks=7 → 明显裂缝 variant;anniv=2 → "奋斗 2 周年"横幅;notice age=5 → `self_modulate=#999999`(降饱和第 2 档),age=0 正常色。

- **AC-FUNC-08** (Rule 5 `apply_accumulation` READY 触发 sprite swap + 信号): **GIVEN** READY, `desk_stain_count = 2`, **WHEN** Scene Flow emit `accumulation_event("desk_stain", 1)` → 调 `apply_accumulation`, **THEN** 内存 `count = 3`;sprite 切第 3 级 atlas frame_coords(< 0.1 ms);`accumulation_changed("desk_stain", 3)` 一次;LightingManager **不直调** `SaveSystem.write_*` / `FileAccess`(钩子计数 = 0)。

- **AC-FUNC-09** (Rule 7 环境叙事 4 元素 overtime 激活): **GIVEN** READY + `ACTION_OVERTIME`, **WHEN** Scene Flow 提供 `npc_traffic_count = 4`(≥ 3)+ emit `accumulation_event("delivery_footprint", 1)`, AND `anniversary_year = 1`, **THEN** 快递盒切 `stepped` variant;横幅 `#E8609A` 俗艳粉 + 2 px `#2A1F14` 黑框(art-bible §4.6 强制);茶水间签名 `self_modulate` Tween `#888888 → #C83428` 在 2 s ± 0.2 s;每日总结后 delivery 重置 clean。

- **AC-FUNC-10** (Rule 8 Audio-Visual 对偶信号双向触发禁止): **GIVEN** debug 钩子对 LightingManager + AudioManager `connect()` 注册列表拍照, **WHEN** 系统 READY, **THEN** Lighting `connect()` 不含任何 Audio 信号;Audio `connect()` 不含任何 Lighting 信号;两者均含 `Scene_Flow.scene_state_changed` 订阅(独立同源);`set_locale(any)` 全程 LightingManager 无 visual state 变更。

- **AC-FUNC-11** (Rule 9 WM_FOCUS_OUT — Tween pause/resume 不丢 state): **GIVEN** READY,`ACTION_DAY → ACTION_OVERTIME` Tween 推进 0.15 s, **WHEN** `WM_FOCUS_OUT` 触发后 `WM_FOCUS_IN`, **THEN** FOCUS_OUT: Tween 暂停在当前插值色;dither `visible` 不变;**不**重置至起点;FOCUS_IN: Tween 从暂停帧续行至 `#8090B4`;颜色无闪回(恢复帧 ≠ 起点)。

- **AC-FUNC-12** (Rule 9 跨系统零契约 — Input/Localization 不影响 Lighting): **GIVEN** READY,debug 钩子冻结 `CanvasModulate.color` 基线, **WHEN** (a) Input emit 全信号序列;(b) Localization `set_locale(&"zh_CN")`, **THEN** (a)(b) 全程 `CanvasModulate.color` / dither `visible` / `palette_index` 均不变;LightingManager `connect()` 不含 Input / Localization 任何信号。

### AC-PERF

- **AC-PERF-01** (Rule 10 综合 draw call + Tween + dither 性能预算): **GIVEN** Profiler 开,60 FPS 稳定, **WHEN** sub-mode = `ACTION_DAY`(dither off),再切 `ACTION_OVERTIME`(dither on), **THEN** DAY: Lighting draw call 贡献 = 0;OVERTIME: +1(dither ColorRect);全场景 ≤ 15(art-bible §8.5 上限 100);CanvasModulate Tween 18 帧总主线程开销 < 0.2 ms;dither 全屏 Bayer 4×4 < 0.3 ms(1080p)。

- **AC-PERF-02** (LIGHTING_LOADING_WATCHDOG_MS 启动时序 — Pillar 5 ≤ 5 秒进入): **GIVEN** 时钟桩在 Loading Scene 序列最早步打点,fixture 标准 save(4 维累积 state), **WHEN** `load_accumulation_state` + `_mark_ready()` 顺序执行(含 4 sprite swap), **THEN** 全序列 < 200 ms(远低 5 s 窗口);累积 sprite swap 合计 < 0.4 ms;超时 CI smoke FAIL `"ERR_LVS_STARTUP: load_accumulation_state exceeded budget — actual=[N]ms"`;gameplay `_process` / `_input` 帧无 `ResourceLoader.load()` 调用。

- **AC-PERF-03** (LUT atlas 显存 + shader 数量预算): **GIVEN** `tools/lighting_lint.gd` 在 build 阶段统计 LUT 文件大小 + 活跃 ShaderMaterial 数, **WHEN** lint CI 运行, **THEN** LUT atlas on-disk < 0.1 MB;运行时 LUT VRAM < 0.1 MB;活跃 shader: day = 1(palette_swap),overtime = 2(+ dither);总 shader 数 ≤ 10(art-bible §8.8);超 CI FAIL `"ERR_LVS_SHADER_COUNT: [N] active shaders exceed limit 10"`;LUT atlas 行数 ≥ 已注册 palette_index 最大值 + 1。

### AC-COMPAT

- **AC-COMPAT-01** (Rule 11 Tonemapper 锁 Filmic — project.godot CI 守门): **GIVEN** `tools/lighting_lint.gd` 解析 `project.godot` WorldEnvironment, **WHEN** lint CI 运行, **THEN** `tonemap_mode` ∈ {Filmic, Linear} PASS;`tonemap_mode = AgX` FAIL `"ERR_LVS_TONEMAPPER: AgX detected — art-bible §4.1 hex shifts under AgX, palette must be re-calibrated"`;CI 阻塞;运行时切换 debug 钩子断言 LightingManager 生命周期内 `tonemap_mode` 不变。

- **AC-COMPAT-02** (Rule 4 Shader Baker — dither ColorRect 常驻 CI 验证): **GIVEN** `tools/lighting_lint.gd` 解析主场景 `.tscn`, **WHEN** lint CI 运行, **THEN** 根场景树含 CanvasLayer(layer=128)+ ColorRect(FULL_RECT)+ ShaderMaterial 引用 `dither_overlay.gdshader`;ColorRect **不**被代码 `queue_free()`;不到此结构 FAIL `"ERR_LVS_SHADER_BAKER: dither ColorRect absent — shader warm-up not covered"`;OQ-LVS-E5 ADR 后更新精确场景树 JSON diff 策略。

- **AC-COMPAT-03** (Rule 5 + #6 Scene Flow 联测 — accumulation_event 触发节奏 + autosave) `[Deferred until #6 GDD ready]`: **GIVEN** #6 fixture 模拟周日结算, **WHEN** #6 emit `accumulation_event("desk_stain", 1)`, **THEN** LightingManager `apply_accumulation` 执行;`accumulation_changed` 信号;#6 订阅后调 `Save.request_autosave()`;Save Rule 3 chain 端到端完成;全序列 < 1 帧。

- **AC-COMPAT-04** (Rule 6 + #16 KPI Review 联测 — R-LVS-1 三轨 Pillar 4 守门) `[Deferred until #16 GDD ready]`: **GIVEN** READY,Scene Flow emit `kpi_review_started`, **WHEN** KPI 通过演出完整执行, **THEN** `CanvasModulate.color` = `#3A3050`;**不含**任何帧落入 `#FFD700` / `#FFA500` 系(帧采样断言);#16 UI 叠 `#E03020` ≤ 8%;Audio `PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC` 顺序播;`GAMEOVER.TITLE_IRONY` 站酷快乐体可见;三轨同步截图存 `production/qa/evidence/kpi-irontriangle-[date].png` advisory sign-off。

### AC-ROBUST

- **AC-ROBUST-01** [RISK GUARD R-LVS-1] (KPI palette 金色 + 直调 CanvasModulate CI lint — Pillar 4 P0 守门): **GIVEN** `tools/lighting_lint.gd` 枚举 Rule 1 颜色表 `KPI_REVIEW`/`GAMEOVER` 关联色 + 任何非 LightingManager `.gd` 文件 `CanvasModulate.color\s*=` 直赋值, **WHEN** lint CI 运行(任意 branch), **THEN** 颜色表含 `#FFD700` / `#FFA500` 前缀(大小写不敏感)→ FAIL `"ERR_LVS_R1: KPI/GAMEOVER palette contains gold — Pillar 4 VIOLATION P0"`;build 不产出;非 LightingManager 直赋值 → FAIL `"ERR_LVS_R1: direct CanvasModulate.color assignment in [file:line]"`;`--no-verify` 绕过 pre-commit 不影响 CI gate。**AND** 合法颜色表 + 无直赋值 PASS。

- **AC-ROBUST-02** [RISK GUARD R-LVS-2] (LOADING watchdog 10 s — Pillar 5 永久卡死守门): **GIVEN** LOADING,Scene Flow 因 bug 永不调 `_mark_ready()`,时钟桩 100 ms 步进推进,pending queue 含 `set_scene_visual(&"MORNING_BRIEFING")`, **WHEN** 累计推进超 `LIGHTING_LOADING_WATCHDOG_MS = 10000 ms`, **THEN** watchdog 触发: `push_error("[LightingManager] LOADING state exceeded 10000ms — force transitioning to READY")`;强制转 READY;`lighting_manager_ready` 一次;pending queue flush,`MORNING_BRIEFING` Tween 执行;Pillar 5 恢复。**AND** 合法启动 ≤ 10 s 调 `_mark_ready()`,watchdog 不触发。**AND** watchdog 触发后 `load_accumulation_state` 未注入 → 累积 state 全默认(0/[]/0/0),P1 defect 须查 Scene Flow bug(dev `push_warning`)。

- **AC-ROBUST-03** [RISK GUARD R-LVS-3] (accumulation_state schema 旧存档兼容 — 缺字段 fallback): **GIVEN** LOADING, **WHEN** Scene Flow 调 `load_accumulation_state({"desk_stain_count": 2})`(缺 3 字段), **THEN** `desk_stain_count = 2`;`notice_board_age = []`;`break_room_cracks = 0`;`anniversary_year = 0`;dev `push_warning("missing field 'X' — using default")`;LOADING 正常完成,不 crash;对齐 Save Rule 11 损坏处理。**AND** `notice_board_age` 元素 > 24 病态 payload: FIFO 截取末 24 + `push_warning`,防超大 state 注入。

- **AC-ROBUST-04** [RISK GUARD R-LVS-4] (全静音视觉双重编码 — 3 关键路径独立可达): **GIVEN** `Audio.set_bus_volume(SFX/Music/Ambient, -60.0)`(全静音), **WHEN** QA dev build 依次测试: (a) `scene_state_changed(&"ACTION_OVERTIME")`;(b) `&"KPI_REVIEW"`;(c) `game_over_triggered`, **THEN** (a) overtime: CanvasModulate Tween 至 `#8090B4` + dither 渐入 0.35,**不**等待 / 检查 Audio 状态;(b) KPI: CanvasModulate = `#3A3050`,无金色帧;(c) GAME OVER: `#3A3050` 保持;三路径下 `scene_visual_changed` 照常 emit;截图 `production/qa/evidence/lighting-mute-visual-parity-[date].png` advisory sign-off(对齐 Audio AC-ROBUST-05 视觉等价)。

- **AC-ROBUST-05** [RISK GUARD R-LVS-5] (notice_board_age FIFO 上限 — Save 体积守门): **GIVEN** READY,`notice_board_age = [23 元素满 Array]`, **WHEN** Scene Flow emit `accumulation_event("notice_board", 1)`(新月触发), **THEN** `[0]`(最旧)被驱逐;既有 22 各 +1;append 0;Array 长度保持 = 24,**不扩容**,**不丢弃新月**;`accumulation_changed("notice_board", [...])` 信号一次;Save 序列化后字段字节 ≤ 96 bytes(稳定上限,不蔓延)。**AND** `[]` 空 Array 时 append: `[0]`,长度 = 1,无 FIFO 触发。

### AC-TONE

- **AC-TONE-01** (Rule 6 Pillar 4 反讽红线 — KPI/升职/周年视觉静止 happy path): **GIVEN** `tools/lighting_lint.gd` CI 对 Rule 1 颜色表 + Rule 7 周年横幅 `self_modulate` 运行, **WHEN** lint 枚举 `KPI_REVIEW`/`GAMEOVER`/`anniversary_year ≥ 1` 路径关联色, **THEN** lint PASS:无 `#FFD700`/`#FFA500`/`#FF6600`(金橙系)任何变体;`anniversary_year ≥ 1` 横幅基色 = `#E8609A` 俗艳粉 + overtime 变体 = `#2A1F14`,非金。**证据**: QA 首次可玩 build 触发 KPI 通过,截图存 `production/qa/evidence/kpi-notgold-[date].png` + art-director sign-off(Advisory)。

- **AC-TONE-02** (Rule 6 + 4 dither = 疲劳非英雄 主观守门): **GIVEN** dev build `ACTION_OVERTIME`,`dither_intensity = 0.35`,`desk_stain_count = 3`,`anniversary_year = 1`, **WHEN** art-director + game-designer 联合 playtest(首测 build), **THEN** 主观:dither 整体读感为"荧光灯疲劳 / 物理失真",**非**"英雄蓝光";脏桌 + 横幅组合读感为"工位时间债务",**非**"成就展示";评估存 `production/qa/evidence/overtime-tone-playtest-[date].md` + 双签字;Advisory 门,首 Alpha build 前完成。Tone defect 不 CI lint,human review gate。

- **AC-TONE-03** (三轨守门铁三角 — Pillar 4 反讽锚点联合 lint): **GIVEN** `tools/lighting_lint.gd` + `audio_lint.gd` + `i18n_lint.py` CI 联合(同 job 或 sequential), **WHEN** 任一 lint 检测违规: (a) Lighting `KPI_REVIEW` 含金色;(b) Audio `PUNCH_CLOCK_CLACK_BUREAUCRATIC` 缺 + 含 `FANFARE`/`VICTORY` 系;(c) Loc `GAMEOVER.TITLE_IRONY` 缺 / context 无 `"IRONY:"`, **THEN** 触发违规者独立 FAIL,CI 阻塞;三工具互不依赖(各自 FAIL 不等对方);任一单独违规标 P0 Pillar 4 blocking,等同拆铁三角一角;联合 PASS 时存证 `production/qa/evidence/irony-triangle-lint-[date].md`。

### AC Tier 分级

**MVP 必测(Alpha gate)— 25 条**: AC-FUNC-01~12(12)+ AC-PERF-01~03(3)+ AC-COMPAT-01~02(2)+ AC-ROBUST-01~05(5)+ AC-TONE-01~03(3)= 25。其中 **5 [RISK GUARD]**(AC-ROBUST-01..05)首测 build 优先验证。

**MVP 建议测(Beta gate)— 2 条**: AC-COMPAT-03(需 #6 GDD)、AC-COMPAT-04(需 #16 GDD)。两者 `[Deferred]`。

**Visual sign-off advisory**: AC-ROBUST-04 截图 + AC-TONE-02 playtest 评估 — art-director + QA / game-designer 联合签字。

### QA 工具需求

| 工具 / Fixture | 路径 | 用途 | 优先级 |
|---|---|---|---|
| **Visual fixture 库** | `tests/fixtures/lighting/` | accumulation snapshots(0/满/病态)/ 6 sub-mode 颜色基准 / gold-color 违规 / 全静音 fixture | MVP Alpha |
| **VisualServer / RenderingServer Mock** | `tests/fixtures/lighting/rendering_server_mock.gd` | mock `CanvasModulate.color` 读写 + draw call 计数,headless 单测 | MVP Alpha |
| **`tools/lighting_lint.gd` 测试套件** | `tests/unit/lighting/lighting_lint_test.gd` | KPI palette 金色检测 / Tonemapper AgX / ColorRect 常驻 / `CanvasModulate.color =` 扫描 / LUT 行数 vs palette_index 上界 / shader 数 ≤ 10 | MVP Alpha(CI blocking) |
| **时钟桩 LOADING watchdog** | `tests/fixtures/lighting/clock_stub.gd` | `Time.get_ticks_msec` 100 ms 步进 — AC-ROBUST-02 watchdog 触发(对齐 Audio) | MVP Alpha |
| **`_force_dispatch` debug 钩子** | LightingManager debug only | `_force_set_scene_visual` / `_force_apply_accumulation` 绕过 LOADING 直测 dispatch(对齐 Audio / Localization) | MVP Alpha |
| **静音视觉验证 fixture** | `tests/fixtures/lighting/mute_visual_parity.fixture` | 全 Bus -60 dB + overtime/KPI/GAMEOVER 场景快照 — AC-ROBUST-04 R-LVS-4 守门 | MVP Alpha |
| **LUT atlas size validation** | `tests/fixtures/lighting/lut_atlas_row_count.fixture` | 行数 < palette_index 上界病态 atlas — OQ-LVS-E2 lint 验证 | Beta / ADR 后 |
| **accumulation schema fallback** | `tests/fixtures/lighting/accumulation_schema_fallback.fixture` | 缺字段 + 病态大 1000 元素 payload — AC-ROBUST-03 R-LVS-3 验证 | MVP Alpha |

## Open Questions

8 条 OQ-LVS 集中(分布于 Sections C/E/G),按 owner / target 排序:

| OQ ID | 描述 | Owner | Target Resolution |
|-------|------|-------|-------------------|
| OQ-LVS-01 | LUT atlas 布局方向(8 列 X 轴 vs 8 行 Y 轴)+ palette_index uniform 与 CanvasModulate Tween 同帧 atomic 提交 vs 1 帧分离 | godot-shader-specialist + technical-artist | ADR 阶段 |
| OQ-LVS-02 | "光源边缘 4 px 内"实现选项:A 全屏 dither(MVP 默认) / B Sobel 边缘检测 / C 预生成 SDF 距离场 — 美术验收若不达标升级方案 B/C | art-director + godot-shader-specialist | first playtest 美术验收 |
| OQ-LVS-03 | WorldEnvironment Tonemapper 锁定决策:Filmic(推荐)/ Linear / Disabled —— 禁 AgX(art-bible §4.1 hex 在 AgX 后偏移)。`project.godot` 须显式锁,禁运行时切换 | technical-director + art-director | Pre-Production ADR(LUT 制作前) |
| OQ-LVS-E1 | `canvas_modulate_tween_sec = 0.15 s` + `dither_intensity_overtime = 0.50` 主观 tone 验证;4K dither overlay ≤ 1.2 ms 实测 | art-director + qa-lead | first playtest build |
| OQ-LVS-E2 | LUT atlas 行数 vs palette_index 范围 lint 实现:Editor Tool 读 atlas image size 方式(import metadata vs 运行时 `Image.get_height()`)| godot-gdscript-specialist + technical-artist | ADR |
| OQ-LVS-E3 | `_mark_ready()` 内部 flush 顺序(累积 state sprite swap 先于 Tween 渲染)Godot 4.6 同帧 `AtlasTexture.region` + Tween start 渲染顺序无 FOUC 实测 | godot-specialist + qa-lead | Prototype build |
| OQ-LVS-E4 | `anniversary_year` cap 10 叙事 legitimacy("奋斗 10 周年永久横幅"是否符合 Pillar 4 tone)+ banner gold lint 范围:CI asset color lint 是否扫 `.tres` material `self_modulate` | game-designer + art-director | GDD review 前 |
| OQ-LVS-E5 | Shader Baker ColorRect 常驻 CI 验证方案:场景树 JSON diff vs headless `--export-debug` shader cache 覆盖率 | godot-specialist + technical-director | Pre-Production CI 设计 |

**OQ 标记的 AC**: 以下 AC 精确表述可能需要 OQ 解决后更新:
- AC-FUNC-XX(palette_index 切换时序)由 OQ-LVS-01 影响
- AC-FUNC-XX(dither overlay 边缘约束)由 OQ-LVS-02 影响
- AC-PERF-XX(全部颜色表 + dither 在 4K)由 OQ-LVS-E1 影响
- AC-COMPAT-XX(Tonemapper 锁)由 OQ-LVS-03 影响
- AC-ROBUST-XX(_mark_ready flush 顺序)由 OQ-LVS-E3 影响
