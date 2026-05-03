# Save System

> **Status**: **Designed (Approved 2026-04-23, 3rd lean review)**
> **Author**: user + main agent + godot-specialist + systems-designer + qa-lead + performance-analyst + narrative-director + creative-director (first review 2026-04-23)
> **Last Updated**: 2026-04-23 (3rd lean review — APPROVED, 5 Recommended 延后 ADR-0001)
> **Implements Pillar**: Pillar 5 (地铁可玩性 — 任意 AP 后可存) + Pillar 3 (死亡是注定的 — 跨局 meta 持久化) + Pillar 1 (无永久成长 — Rule 22 cross-run content-only) 守护

## Overview

Save System 是《活过第 X 集》的持久化基础层，负责序列化和恢复玩家进度，管理两条独立轨道：**current run**（单局内所有可变状态 — AP / KPI 基准与历史 / NPC 关系 / 已触发事件与 flag / 日程位置）和 **meta save**（跨局永久数据 — "活过第 X 集"累计分数、历代 Run 归档、内容解锁集合、玩家设置）。单局结束（GAME OVER）时，current run 存档归档至历代记录后删除；meta save 持续累积，跨所有 Run 存在。

**玩家感知**：虽然是基础设施，本系统直接兑现 **Pillar 5（地铁可玩性）** 的承诺 — 玩家应能在打完任意一张行动卡的反馈后把游戏丢进口袋，重开仍从原位继续；同时它是 **Pillar 3（剧终不是失败）** 的技术前提 — 每条 Run 的完整记录（活到第几集 / 挂掉原因 / 关键 NPC 结局）被永久归档供玩家博物馆式回看。

*技术实现方案（.tres vs JSON / 单文件 vs 多文档 / 加密策略）留给 ADR 阶段决定。*

## Player Fantasy

Save System 服务两个时间尺度上的玩家瞬间，共享同一种 tone：**冷静、像打卡机、不煽情**。

### 日常：地铁到站前的那张卡（Pillar 5）

玩家在通勤地铁上单手握着手机，距离下一站两分钟，打出当天最后一张"摸鱼"，AP 归零。屏幕弹"明日 9:00"，淡出——无动画、无温柔音效，像下班打卡机一声"嘀"。他锁屏下车。晚上加班回家路上再掏出手机，Run 精确停在昨晚那一帧：KPI 差 13，周三的剧本 prompt 停在"总监让你写周报"。**存档不是"保存进度"，是保证他不会因为加班而丢掉他的第二份工作。** 每张行动卡执行完即可安全放下手机——这是系统对玩家生活节奏的唯一承诺。

### 剧终：职业生涯的黑盒（Pillar 3）

GAME OVER 不是红字 "Game Over"，是屏幕缓慢滑出一份**离职证明风格的 Run 摘要**：入职 17 集、KPI 均值 62.4、最高光时刻"周三假装打印机坏了"、最终死因"主动裸辞"。然后进入"历代员工档案"列表——前面还躺着 14 个前世，每个有工号、名字、死因。玩家可以点开任一档案翻阅，**但不能读档、不能继承**。数据留下，人走了。计数器"活过第 X 集"+1。这让 Pillar 3 的"剧终不是失败"不再是一句口号，而是一件可以归档、翻阅、展示的物品。

### Tone 锚点

**对**的参考：《Papers, Please》的 "End Shift"（冷静机械的结算）、下班打卡机的"嘀"、一份打印出来的离职证明。
**反**的参考：不是《Stardew Valley》的温柔睡觉动画、不是《中国式家长》的仪式感 BGM、不是 roguelike 的"永久解锁 +1"成就提示音。

### 玩家不会说的话 / 会说的话

- ❌ "我的 Save 守护了我的回忆"
- ❌ "能存档真是温暖"
- ✅ "这游戏至少不会因为我下车就把我坑了"
- ✅ "档案柜里我已经挂过 14 次，这次我想活到 20 集"

## Detailed Design

### Core Rules

1. **逻辑存档文件分三类，物理落盘格式由 ADR-0001 决定**：
   - `current_run.save`（单一活存档）
   - `meta.save`（跨局持久数据：Episode 计数 / 档案柜索引 / 解锁集合 / 设置）
   - `archive/[run_id].save`（只读历代归档，按 run_id 累加）
2. **单槽铁人原则**：任何时刻 `current_run.save` 至多存在一份；不提供手动"另存为"、不提供多槽、不提供读档回溯。
3. **Autosave 触发条件**（满足其一即 fire）：
   (a) 任一行动卡的 `execute` 完成并产生状态变更（AP/KPI/NPC/Flag）；
   (b) 日结算结束并进入下一 `time_of_day`；
   (c) 事件脚本 step 命中 `save_checkpoint` 标记节点；
   (d) 应用接收到退出/失焦信号：`NOTIFICATION_WM_CLOSE_REQUEST`（关窗，同步阻塞 autosave）或 `NOTIFICATION_WM_WINDOW_FOCUS_OUT`（失焦，触发 500 ms debounced 异步 autosave）。**不使用** `NOTIFICATION_APPLICATION_PAUSED`（Android/iOS 专属，桌面 Godot 4.6 silent no-op）。
4. **Autosave 是覆盖写，非增量**：每次 fire 输出完整 snapshot 替换旧 `current_run.save`；禁增量补丁（避免链式损坏）。
5. **写入原子性（显式 4 步 + rename）**：
   (a) `FileAccess.open("current_run.save.tmp", WRITE)` → 断言返回非 null；
   (b) `store_string(json_bytes)` → **必须检查返回 `bool`**（Godot 4.4+ breaking change）；false 时记 error 日志 + 中断事务，旧 `current_run.save` 保留不动；
   (c) `flush()` → 强制刷盘（OS 缓冲落到磁盘），在 rename 之前必做；
   (d) `close()` → 显式调用，**不**依赖 RefCounted 析构顺序（Windows/macOS 下同步同步 rename 语义对未 close 的 handle 行为不一致）；
   (e) `DirAccess.rename("current_run.save.tmp", "current_run.save")` → 原子 rename。**Windows 原子性依赖**：Godot 4.6 `DirAccess.rename` 底层封装 `MoveFileExW(MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)`，同卷原子；跨卷自动降级为 copy+delete 非原子——`user://` 按 Godot 约定永远同卷，该保证成立。rename 失败时保留 `.tmp`、不破坏旧文件，进入 ERROR 态。
6. **写入性能硬门槛**：单次 autosave 端到端耗时 < 50 ms（Pillar 5）；超 30 ms 写告警日志；序列化体积 > 256 KB 触发 schema 审查告警（不阻塞）。
7. **Autosave 不阻塞玩家输入（off-main-thread JSON）**：主线程仅执行 state tree **只读遍历**（各子系统 `get_state()` 返回 Dictionary，主线程聚合为 `Dictionary`，耗时 1–3 ms）；将聚合 Dictionary 与单调递增 `snapshot_id` 一起派发给 `WorkerThreadPool`；worker 完成 `JSON.stringify`（8–18 ms）+ Rule 5 原子写 4 步 + rename。主线程 p99 < 3 ms，不碰帧预算。UI "已存"指示器在 snapshot 派发完成后立即短暂显示，不等 worker 完成。ARCHIVING 事务是例外（Rule 9），必须同步走主线程避免进程先于 worker 退出。
8. **Load 触发条件**（满足其一即 fire）：
   (a) 主菜单点击"继续"；
   (b) 主菜单点击"新游戏"且 `current_run.save` 存在 → 弹"上一局仍在进行中 / 继续 / 放弃"对话框；
   (c) 崩溃重启后冷启动自动检测 `current_run.save` 并询问是否恢复。
9. **归档事务**（GAME OVER 专用 flow，严格顺序，任一失败整体回滚）：
   a. 写入完整最终 snapshot 到 `current_run.save`；
   b. 生成 Run 摘要（tenure_months / 死因 / KPI 峰值 / 关系网终态 / 便利贴候选）；
   c. 原子复制到 `archive/[run_id].save`：按 Rule 5 的 4 步顺序写 `archive/[run_id].save.tmp` → `flush()` → `close()` → `DirAccess.rename()`；rename 成功后调用 `FileAccess.set_read_only_attribute(path, true)`（跨平台等价 POSIX `chmod 0444` / Windows `SetFileAttributes(FILE_ATTRIBUTE_READONLY)`）；
   d. 删除 `current_run.save`；
   e. 更新 `meta.save`（run_id++ / 最高集数 / 累计集数 / 新解锁 / 便利贴池）。
   任一步失败则保留 `current_run.save` 以便下次重试归档。
10. **便利贴注入机制**：下一局启动时，Run Meta System 从 `archive/*.save` 按条件筛选 0–3 条 memo 文本注入 HUD 提示板。便利贴**严格 flavor，零机械收益**（Pillar 1 铁律）。Save System 只提供只读访问接口，不决定注入规则。
11. **错误回退**：
    - `current_run.save` 校验失败 → 弹对话框"存档损坏 / 开始新 Run（推荐）/ 导出损坏文件供诊断"；不自动覆盖、不静默丢弃。
    - `meta.save` 损坏 → 用默认值重建并告知玩家跨局进度可能丢失；备份损坏文件为 `meta.save.corrupt_[timestamp]`。
    - `schema_version` 落后 → MVP 阶段一律视同损坏走上条；VS 起引入 migrate 链。
12. **Honor System（明文 + 审计字段）**：user:// 明文，不做 HMAC / 不加密 / 不混淆；但每份 save 必须写 `schema_version`（单调整数）和 `game_build`（用于 bug 复现）。
13. **Save 与 Load 互斥 + snapshot_id 单调递增**：同一时刻至多一个 save 或 load 操作在执行。新的 autosave 请求撞上进行中的 save → 合并为一次（Rule 7 `snapshot_id` 最大的覆盖排队旧请求）。Worker 端严格按 `snapshot_id` 单调执行：任何到达时序列 `snapshot_id < last_completed_snapshot_id` 的请求**立即丢弃**并记 `stale_request_dropped` 计数器（防 WorkerThreadPool 无序调度造成旧覆盖新的静默数据损坏）。
14. **Meta save 与 current run 解耦**：meta 仅在玩家设置变更（防抖 500 ms）/ Run 归档完成 / 跨局解锁触发时写入；不与行动卡节奏同步，避免冗余 I/O。
15. **Archive 反向幂等补齐 meta**：当 ARCHIVING 事务第 5 步（meta 更新）中断时，冷启动期扫描 `archive/*.save` header 反推 `run_id` 最大值补写 `meta.last_archived_run_id` 与 `episode_count`；补齐失败则走 Rule 11 meta 损坏分支。archive 文件是事实，meta 是索引——索引落后于事实时以事实为准。
16. **Snapshot 前 primitive 净化**：序列化前遍历 state tree，将非有限 float（`NaN` / `+Inf` / `-Inf`）替换为 `0.0`，并在 state 顶层记录 `sanitized_fields: [path, ...]` 审计数组。Loader 侧若发现 `sanitized_fields` 非空则向玩家展示一次"数值异常已修复"对话框（防御 KPI 公式除零等上游 bug）。
17. **Meta 与 archive 不一致时以文件系统为准**：冷启动扫描 `archive/*.save` 文件列表与 `meta.archive_index` 对比；不一致时信任文件系统（重建 `meta.episode_count` = `count(archive/*.save)`），meta 中其他字段（死因 / tenure 摘要等）保留不覆盖。防御玩家手删 archive 或云同步部分丢失。
18. **Pending flags 持久化到 meta**：ARCHIVING 第 5 步中断时生成的 `meta_reconcile_pending` 标志（Rule 15 所需）落盘到 `meta.save.pending_flags` 数组字段；冷启动读取该字段做补齐操作后**立刻清空数组** + 重新 flush meta。若 pending_flags 落盘本身失败（极端嵌套崩溃），下次启动时 Rule 17 的 archive 扫描作为兜底。
19. **退出超时后强制丢弃未完成 save**：`NOTIFICATION_WM_CLOSE_REQUEST`（玩家点关窗/Alt-F4/Cmd-Q）下 autosave 超过 `app_pause_save_timeout`（默认 500 ms）未完成则**强制中断、丢弃当前写入、保留上一次成功 save 作为最后防线**。不允许因 save 阻塞无限延迟游戏退出（Steam / OS 会杀进程）。玩家体感最坏丢最后 1 张卡（Pillar 5 承诺的语义是"打完一张卡后安全"，不含写入瞬间）。**`NOTIFICATION_WM_WINDOW_FOCUS_OUT` 不走此路径**——玩家切窗/Alt-Tab 不等于关游戏，触发一次 500 ms debounced 异步 autosave（走 Rule 7 worker 路径），不阻塞主线程、不强制 close。
20. **Steam Cloud 同步策略（ironman 守护）**：Steam Cloud Auto-Cloud filter **仅**同步 `meta.save` + `archive/*.save`（设置存于 `meta.save` 内，无独立 settings.cfg 文件）；**不**同步 `current_run.save` / `*.tmp` / `*.log` / `*.corrupt_*`。跨 PC 时档案柜（历代归档）和设置可见，但**活动 Run 仅在开局 PC 本地存在**——杜绝"A 机做了决策 → B 机读 A 机的旧版 current_run 绕过"的 ironman 破坏路径。玩家跨机体感："换电脑时上一局没了（想继续请回开局那台机）、但历代员工档案都在"。Rule 20 使 Open Question OQ-06 不再存在（冲突在根上消除）。
21. **离职证明呈现硬约束（Pillar 3 tone 守护，跨 GDD 锁定）**：GAME OVER ARCHIVING 事务完成后，UI 播放"离职证明风格 Run 摘要" transition 必须满足 `final_transition_duration_ms ≤ 1500` + `final_transition_easing = NONE`（线性 / 即时切换，禁 ease-in / ease-out / bounce / elastic 等任何缓动）。**本 Save System GDD 跨系统锁定**此 tone 约束：`design/gdd/kpi-review-game-over-ui.md` (#16) 在实现离职证明播片时必须遵守；违反即 QA FAIL（UI profiler 可断言）。理由：Pillar 3 要求"冷静打卡机"tone；ease-in 的渐显会漂向《Stardew Valley》温柔睡觉动画或《中国式家长》仪式感 BGM，违反 Player Fantasy 锚点。Save System 通过 `archive_complete` 信号向 #16 告知 transition 可以开始。
22. **跨局解锁仅限 content-reveal（Pillar 1 铁律，跨 GDD 锁定）**：`meta.unlocks` 字段**只允许**存以下 5 类 key：`codex_entry_id` / `memo_id` / `npc_unlock_id` / `event_branch_id` / `ending_unlock_id`。**禁止**存任何改变 Run 起始数值的字段（`starting_ap_bonus` / `starting_favor_delta` / `card_power_bonus` / `kpi_base_offset` 等）。下游 GDD（#8 NPC Relationship / #10 Event Script / #11 Action Card / #12 Run Meta）若在 `meta.unlocks` 里塞机械数值字段，本 GDD 的 Rule 22 必须在其 `/design-review` 阶段拦截；违反即判 Pillar 1 "无永久成长"承诺破防。本规则对应 Player Fantasy 中"数据留下、人走了"的叙事承诺——**新 Run 起点永远与第一局一致**，差异仅在"可见内容更多"。
23. **档案柜硬上限（200 局）达限行为**：`len(archive/*.save) ≥ archive_hard_cap_count`（默认 200）时，新 Run 启动请求**拒绝**并弹对话框"档案柜已满（200/200），请先删除历代员工档案"。玩家必须在 Main Menu → Archive 列表**逐条选档**删除（**禁止批量删除 / 禁止全清按钮**——删档即销毁事实，仪式感与意图必须显式）。删除后档案柜计数减 1，新 Run 按钮解锁。若 `current_run.save` 存在（上局未结束），"继续"按钮不受影响（可继续打完）。MVP 不会触达此上限（200 局 ≈ 玩家累计 1000+ 小时），但规则必须在 launch 落地（保长线玩家的 Pillar 3 仪式不静默破防）。本规则使 Open Question OQ-01 完结。

### States and Transitions

**Save System 状态机**：

| State | Enter 条件 | Exit 条件 | 允许转移到 | 禁止转移到 |
|---|---|---|---|---|
| **IDLE** | 系统初始化完成 / 上次操作完成 | 收到 save / load / archive 请求 | SAVING, LOADING, ARCHIVING, MIGRATING | ERROR（必须经中间态） |
| **SAVING** | 来自 IDLE 且收到 autosave / settings flush 请求 | 写入完成并 rename 成功；或写入失败 | IDLE（成功）, ERROR（失败） | LOADING, ARCHIVING |
| **LOADING** | 来自 IDLE 且玩家触发 continue / new-game 冲突确认 | 反序列化完成并注入下游；或校验失败 | IDLE（成功）, ERROR（失败）, MIGRATING（检测到旧版本） | SAVING, ARCHIVING |
| **ARCHIVING** | 来自 IDLE 且收到 GAME OVER 信号 | 归档事务 5 步全成功；或任一失败 | IDLE（成功）, ERROR（失败） | SAVING, LOADING（归档中拒绝其他 I/O） |
| **MIGRATING** | 来自 LOADING 且 `schema_version < current` | 迁移成功 → 续接 LOADING；失败 → ERROR | LOADING, ERROR | SAVING, ARCHIVING |
| **ERROR** | 任一状态写入 / 读取 / 迁移失败 | 玩家在对话框做出选择（重试 / 新局 / 退出） | IDLE | SAVING, LOADING, ARCHIVING（直到 IDLE） |

**事件 → Save 触发 映射**：

| 触发事件 | 写入行为 | 目标文件 | 同步性 |
|---|---|---|---|
| 行动卡 `execute` 完成 | autosave | current_run | 异步（主线程 snapshot + 后台 I/O） |
| 日结算结束 | autosave（强制 flush，即使同帧已存过） | current_run | 同步阻塞（保证进入下一日前落盘） |
| 事件脚本命中 `save_checkpoint` | autosave | current_run | 异步 |
| GAME OVER 事件抛出 | ARCHIVING 事务流 | current_run → archive/[run_id] → meta | 同步阻塞（全流程完成前不允许返回主菜单） |
| 关窗 / Alt-F4 / Cmd-Q（`WM_CLOSE_REQUEST`） | autosave + flush | current_run, meta（若 dirty） | **同步阻塞**（最多 500 ms 超时；quit 早于 task 会丢数据） |
| 窗口失焦 / Alt-Tab（`WM_WINDOW_FOCUS_OUT`） | 500 ms debounced autosave | current_run | 异步（worker thread，不阻塞主线程；失焦 ≠ 关游戏） |
| 主菜单"新游戏" + current_run 存在 | 不写入；弹确认对话框 | — | N/A |
| 主菜单"继续" | load | current_run | 同步，带 loading UI |
| 玩家改设置（音量 / 语言 / 叙事密度 / gamepad 布局） | meta save（防抖 500 ms） | meta | 异步 |
| 跨局解锁（新 NPC / 新事件 / 新结局） | meta save | meta | 异步 |
| 崩溃后冷启动 | 检测 current_run 并提示恢复 | — | N/A |

### Interactions with Other Systems

> **Scene & Day Flow Controller (#6)** ↔ Save System
> **流入**: 日程位置（year / month / week / day / time_of_day）+ 当前场景 ID
> **流出**: load 时回写日程，Controller 将场景切到对应节点
> **所有权**: Controller 拥有日程 schema；Save 只作容器
> **时机**: Controller 是 autosave 主调度者——每张行动卡 `execute` 结束调用 `Save.request_autosave()`；日结算末尾强制 flush

> **AP Economy System (#7)** ↔ Save System
> **流入**: `current_ap`, `spent_today`, `energy`, `exhaustion`
> **流出**: load 恢复 AP 快照，后续扣减由 AP System 自驱
> **所有权**: AP System 拥有状态结构；Save 通过 `get_state() / apply_state()` 存取
> **时机**: AP System 不主动触发 save，仅响应 Controller 的 snapshot 请求

> **NPC Relationship System (#8)** ↔ Save System
> **流入**: 8–10 NPC 的 `favor: int`, `flags: set<string>`, `last_interaction_tick`
> **流出**: load 一次性回灌整张关系网
> **所有权**: NPC System 拥有 NPC schema（ID / 取值范围）；Save 对结构无感知
> **时机**: 响应 Controller 请求；关系变更本身不触发 save（由行动卡 / 事件 autosave 覆盖）

> **KPI & Reverse Threshold System (#9)** ↔ Save System
> **流入**: `current_threshold`, `base_threshold`, `effort_accumulator`, `potential`, `tenure_months`, 最近 N 个月历史快照数组
> **流出**: load 完整恢复，后续阈值漂移由 KPI System 计算
> **所有权**: KPI System 拥有公式与历史窗口大小；Save 不感知语义
> **时机**: 月结算后必 save（属于"日结算末尾强制 flush"）

> **Event Script Engine (#10)** ↔ Save System
> **流入**: `fired_events: set<event_id>`, `cooldowns: map<event_id, ticks>`, `global_flags: map<string, Variant>`, 当前 prompt 中断位置（`active_script_id` + `step_index` + `local_vars`）
> **流出**: load 时若存在 `active_script_id`，引擎从断点续跑当前分支
> **所有权**: Event Engine 拥有脚本断点语义（允许 / 不允许恢复的 step 类型）。若玩家关游戏时停在不可恢复的 UI 分支，引擎自行回退到上一个 `save_checkpoint`
> **时机**: 命中 `save_checkpoint` 节点时 fire；分支内非检查点步骤不写入

> **Action Card System (#11)** ↔ Save System
> **流入**: `played_cards_log`, `available_cards: set`, `locked_cards: set + reason`, 当次 run 的卡组摘要
> **流出**: load 恢复三集合，UI 重建手牌区
> **所有权**: Card System 拥有卡 ID 命名空间与锁定规则；Save 只存 ID 与 flag
> **时机**: 每张卡 `execute` 后由 Controller 触发 autosave（本 System 不自调度）

> **Run Meta System (#12)** ↔ Save System
> **流入**: `run_id` 自增计数、最高集数、累计集数、历代 Run 摘要列表、跨局解锁集合、便利贴池、玩家设置
> **流出**: new-run 启动时从 meta 读取解锁集合与便利贴候选；归档完成后 Run Meta 收到 `archive_complete` 信号更新集数
> **所有权**: Run Meta 拥有 meta schema 与便利贴筛选规则；Save 只负责容器 + 只读 archive 访问接口
> **时机**: 解锁事件 / 归档事务尾部 / 设置变更（防抖）

> **HUD / Main Menu / KPI Review UI** ↔ Save System
> **流入**: 玩家设置（音量 / 语言 / 叙事密度 / gamepad 布局）、最后打开的 UI 面板（可选，UX 记忆）
> **流出**: 主菜单读取 `current_run.save` 存在性决定"继续"按钮可用性；读取 meta 展示历代档案柜与最高集数；KPI Review UI 读取当前 run 的月历史快照渲染曲线
> **所有权**: 各 UI 模块拥有自己的设置 schema；Save 提供 `meta.settings.get / set` 键值接口
> **时机**: 设置 UI 关闭 / 切页时 meta flush（防抖 500 ms）

### Engine Constraints (Godot 4.6) — 引擎层硬约束

以下约束**必须**被 ADR-0001 Save Format 遵守；细节放 ADR，此处只保留 GDD 层的"不可退让"：

- **格式推荐**：JSON + `FileAccess`（非 `ResourceSaver` + .tres）。理由：Honor System 明文、schema 迁移长线关键（plan 200 局 × 档案柜累积）、MVP 重构期 `class_name` 改动会破坏 Resource load。20 KB state 下 JSON 开销 1–3 ms，完全可容忍。
- **原子写入**：必须 `.tmp` → flush → `DirAccess.rename()` 三步。**Godot 4.4 breaking change 强制项**：`FileAccess.store_*` 系列返回 `bool`，所有调用**必须**检查返回值（lint rule 必配），否则原子写会静默失败。
- **性能预算实测路径（off-main-thread JSON，Rule 7）**：主线程仅聚合子系统 `get_state()` Dictionary（1–3 ms 中位，严守 16.6 ms/帧）；Worker Thread 做 `JSON.stringify`（8–18 ms）+ 原子写 4 步 + rename（3–10 ms）。主线程 p99 < 3 ms 是玩家帧率感知指标；worker 端到端 p99 < 50 ms 是 autosave "已完成"指标（对玩家不可见）。HDD + AV 扫描场景需 Polish 阶段实测 worker p99（见 OQ-03）。
- **退出时 save 必须同步（仅 `WM_CLOSE_REQUEST`）**：关窗路径不能用 WorkerThreadPool（`get_tree().quit()` 可能早于后台 task 完成导致丢数据）——退出路径走主线程同步 snapshot + stringify + 原子写（最多 `app_pause_save_timeout=500 ms`，超时丢本次保旧）。**`WM_WINDOW_FOCUS_OUT`（Alt-Tab）走正常 worker 异步路径**（失焦不触发进程退出）。**绝不使用** `NOTIFICATION_APPLICATION_PAUSED`——Android/iOS 专属，Godot 4.6 桌面端 silent no-op，若错误订阅会导致关窗 save 静默失败。
- **SaveManager 必须是 Autoload 节点**：需要 `_notification(what)` 接 WM/APP 事件；不能做成静态类或 `@tool`。
- **MVP 不做 schema 迁移**：旧版 `schema_version` / 损坏 → 一律"存档不兼容，开始新游戏"弹窗。VS 起引入 `migrate_vN_to_vN_plus_1` 纯函数链 + `.backup` 回滚防线。
- **Steam Cloud filter（Rule 20 ironman 守护）**：仅同步 `meta.save` + `archive/*.save`（设置存于 `meta.save` 内）；**不**同步 `current_run.save` / `*.tmp` / `*.log` / `*.corrupt_*`。跨 PC 时档案柜与 meta 可见，活动 Run 仅留在开局机——从根上消除"选旧版本撤销决策"的 ironman 破坏路径。quota 100 MB 下 200 archives ≈ 600 KB + meta ≈ 20 KB（含设置），余量充足。
- **禁止序列化对象引用**：所有可 save 字段限定 primitive / Dictionary / Array（`JSON.stringify` 对 Object / Resource 引用会抛或静默丢）。单元测试断言 state dict 仅含允许类型。

*完整 API 选型矩阵、Threading 细节、跨平台 user:// 表、损坏分层检测见 ADR-0001。*

## Formulas

Save System 是 Foundation 层基础设施，**不产生 gameplay 计算**。所有可配置的数值（autosave 间隔、防抖窗口、性能阈值、档案柜容量上限、schema 审查告警体积）均为**运行时参数**而非公式——列于 Section G: Tuning Knobs。

唯一在 GDD 层级值得形式化的是 **autosave 合并规则**（Core Rule 13 "Save/Load 互斥"的数学表达）：

`effective_snapshot(t) = latest_snapshot_request(t)`

即：当 `t` 时刻触发 autosave 时，若前一 autosave 尚未完成，所有排队请求合并为一次，最终以请求队列中的**最新 snapshot 胜出**（不是最早）。这确保玩家在连续快速打卡时，最终落盘状态永远是最新操作后的状态，而非中间态。

- **Variables**:
  - `t`: 当前时间戳（ms）
  - `snapshot_request(t)`: 在 `t` 时刻主线程对游戏状态拍下的 Dictionary 快照
  - `latest_snapshot_request(t)`: 从上次成功写入到当前 `t` 的所有请求中时间戳最大者
- **Output**: 单一 Dictionary 对象，直接进入 JSON 序列化
- **边界**: 若队列为空（无 pending 请求）则 no-op；若队列为 N 条则 N-1 条被丢弃，性能计数器记录丢弃数（观测用）

*其他量化约束（50 ms 性能预算 / 500 ms 设置防抖 / 256 KB 体积告警 / 归档事务超时）均为阈值常量，见 Section G。*

## Edge Cases

### 1. I/O 失败

- **If autosave 写 `current_run.save.tmp` 时磁盘剩余空间 < snapshot 体积**: `FileAccess.store_*` 返回 `false`，SaveManager 删除残留 `.tmp`、保留旧 `current_run.save` 不覆盖，进入 ERROR 态并弹对话框"磁盘已满 / 释放空间后重试 / 退出游戏"。
- **If user:// 所在目录在写入期间被改为只读**: `DirAccess.rename()` 返回 `ERR_FILE_NO_PERMISSION`，保留 `.tmp`、旧 `current_run.save` 不变，ERROR 对话框"无写入权限 / 重试 / 导出 snapshot 到剪贴板 / 退出"；不尝试 chmod，不静默丢弃。
- **If meta.save 绝对路径长度 > 240（Windows MAX_PATH 逼近，如深层 OneDrive）**: 启动时预检，超阈值即停止任何写入，弹启动对话框"存档路径过长，请将 Steam 库迁至短路径"；禁止进入 Run。
- **If `current_run.save` 被 AV / 杀软持锁导致 rename 失败**: 重试 3 次（50 / 200 / 800 ms 指数退避），仍失败则保留 `.tmp`、HUD "已存"指示器位置显示"暂存，请勿关机"，下次 autosave 时优先续尝试替换。
- **If `archive/` 子目录不存在（玩家手删）**: ARCHIVING 第 3 步先 `DirAccess.make_dir_recursive_absolute()`，失败则回滚整事务（保留 `current_run.save` 供下次 GAME OVER 重试归档）。

### 2. 崩溃时序

- **If 进程在写入 `.tmp` 中途被杀**: 冷启动扫描发现孤立 `current_run.save.tmp`，校验 JSON 完整性；完整则提示"检测到未完成存档 / 采用 / 丢弃"，不完整则静默删除并加载旧 `current_run.save`。
- **If 进程在 rename 之前、`.tmp` 写完之后崩溃**: 冷启动以 `.tmp` 和 `current_run.save` 两者 `schema_version` + `game_tick` 较新者为准，相等时优先 `.tmp`（最新），采用后执行 rename 完成事务。
- **If 进程在 ARCHIVING 第 3 步完成后、第 4 步（删除 current_run）前崩溃**: 按 Rule 9 "整体回滚"，冷启动删除 archive/[run_id].save（先清只读位）、保留 current_run，让玩家重新触发 GAME OVER。
- **If 进程在 ARCHIVING 第 5 步（meta 更新）途中崩溃但前 4 步已完成**: 按 Rule 15 反向幂等补齐 meta；补齐失败走 Rule 11 meta 损坏分支。

### 3. 文件内容异常

- **If `current_run.save` 顶层 JSON parse 失败（截断 / 非 UTF-8 / BOM 混入）**: 按 Rule 11 弹"存档损坏"，导出为 `current_run.save.corrupt_[ISO8601]`，"继续"按钮变灰。
- **If JSON 合法但缺必填字段（`schema_version` / `run_id`）**: 视同损坏走 Rule 11；**不**允许"字段缺失用默认值"——缺字段 == 不可信文件。
- **If `schema_version` 类型非整数（字符串 / 负数 / 浮点 / null）**: 视同损坏；QA 测试用例可手改为 `"v2"` / `-1` / `1.5` / `null` 四种，行为应一致。
- **If 玩家手改 `current_ap = 999`**: Honor System（Rule 12）不校验不拒绝；存档正常加载，clamp 责任在 AP System——**Save System 不承担反作弊责任**。QA 测试只需断言加载不抛异常。
- **If `meta.archive_index` 引用不存在的 `archive/[run_id].save`**: 懒校验，缺失条目在档案柜 UI 显示"文件丢失 [run_id]"占位、不可点开；**不**删除 meta 条目（保留事实记录）。

### 4. 版本 / 构建不匹配

- **If `schema_version < CURRENT_SCHEMA_VERSION`**: MVP 一律走 Rule 11 "视同损坏"分支，对话框文案特化为"存档来自旧版本"；**不** attempt migration（VS 起引入 migrate 链）。
- **If `schema_version > CURRENT_SCHEMA_VERSION`（玩家从新版回滚）**: 拒绝加载，弹"此存档由更新版本创建，请升级游戏"；不提供"强制加载"；不自动改 schema_version。
- **If `game_build` 与当前 binary 不同但 `schema_version` 相同**: 允许加载；崩溃日志 header 记录 `save_build != current_build` 供 bug 复现；玩家侧无提示。

### 5. 平台特殊

- **If Steam Cloud 在 PC-A 和 PC-B 检测到 `current_run.save` 冲突**: Steam 自身弹冲突窗——Save System 无权干预，但保证每次 autosave 后 mtime 严格递增（显式 `FileAccess.close()`）。
- **If 用户名含表情符号 / CJK 导致 user:// 非 ASCII**: 启动期用 `FileAccess.file_exists()` 对 `user://_probe.txt` 读写探测，失败则弹 fatal "存档系统初始化失败"并写详细路径到崩溃日志；**不**fallback 到 `res://`。
- **If Steam Cloud quota 满（100 MB 占满）**: 本地写入正常，云同步失败由 Steam 客户端提示；Save System 不感知。档案柜接近上限（见 open question R16）时另行提示。
- **If macOS 下 iCloud Drive 同步 user:// 产生 `.DS_Store` + Spotlight 锁**: `.tmp → rename` 在 `MoveFile` 原子语义下仍成立；必须先 `flush()` 再 close 再 rename（4.4 行为变更要求检查返回值）；QA 在 macOS 做专项测试。

### 6. 运行时状态异常

- **If state snapshot 体积 > 1 MB（hard bloat 线）**: 序列化前断言；超过则写 `state_bloat_detected` error 日志、**仍完成本次 save**（不丢玩家进度），下次启动在 debug build 弹开发者警告。256 KB 是 schema 审查告警线；1 MB 是 bloat 线。
- **If state 中 float 为 NaN / ±Inf**: 按 Rule 16 净化为 0.0 并记录 `sanitized_fields` 审计路径；loader 侧发现非空则展示一次"数值异常已修复"对话框。
- **If 某子系统 `get_state()` 返回 Dictionary 含对象引用（违反引擎约束）**: `JSON.stringify` 抛 `ERR_INVALID_DATA`——取消本次 autosave（保留旧文件）、写 error 日志标违规 system 名、debug build assert fail、release build 静默（Honor System）+ 计数器 +1。
- **If OOM 导致 `JSON.stringify` 抛异常**: 取消本次 save、保留旧文件，HUD "已存"指示器变红并显示"内存不足"；下次 autosave 重试；连续 3 次失败进入 ERROR 态。

### 7. 多操作竞争

- **If autosave 写入期间玩家打下一张卡触发新 autosave**: 按 Rule 13 merge——主线程立刻对新 state snapshot 并挂 pending，当前写入完成后以 pending 最新 snapshot 直接下一次写入（skip IDLE 回弹）；队列永远只保留 1 条 pending。QA：1 秒连点 10 卡，落盘 == 第 10 卡后 state。
- **If autosave 中收到 GAME OVER → ARCHIVING**: ARCHIVING 阻塞等 SAVING 完成（最多 500 ms），然后按状态机 SAVING → IDLE → ARCHIVING；超时则强制中断 SAVING（保留旧文件）直接 ARCHIVING 第 1 步重写完整 final snapshot。
- **If 玩家连续调音量滑块（防抖未满）时触发 GAME OVER**: ARCHIVING 第 5 步写 meta 时强制 flush 所有 pending 设置（忽略防抖），保证归档后 meta 含最新设置。
- **If 玩家在 LOADING 态按 ESC 回主菜单点"新游戏"**: LOADING 拒绝新请求、按钮暂灰或吞输入；LOADING 完成回 IDLE 后 UI 允许重入。状态机硬约束。

### 8. 边界 Run 状态

- **If 首次启动（user:// 为空）**: 跳过损坏检测，用默认值创建 meta.save（`run_id = 1, archived_runs = []`）；主菜单"继续"灰、"新游戏"直接进入；无警告弹窗。
- **If 档案柜为空但 meta.save 存在（玩家手删所有 archive 但留 meta）**: 按 Rule 17 以文件系统为准，meta.episode_count 重写为 0 + 记 warning 日志；档案柜 UI 显示"尚无历代员工 / 原 14 条记录已丢失"；便利贴注入退化为 0 条。
- **If `run_id` 接近 `INT64_MAX`（不现实但防御）**: meta 写入前断言 `run_id < 2^53`（JSON number 安全整数上限）；越界则拒绝新 Run 启动并弹"档案柜系统已达上限"；此条 defensive 用于测试。
- **If `meta.episode_count` 与 archive 实际数量不一致**: 按 Rule 17 信任文件系统，reconcile 后 `meta.episode_count = count(archive/*.save)` + warning 日志；不删 meta 其他字段。

### 9. 玩家异常行为

- **If 玩家在 autosave 中强制关机**: 等价崩溃时序类（2.1 / 2.2），冷启动走 .tmp 检测路径；玩家侧最坏"丢最后 1 张卡"可接受（Pillar 5 承诺是"打完一张卡后"安全，不含写入瞬间）。
- **If 玩家主菜单疯狂双击"继续"**: LOADING 触发后按钮立即禁用（Rule 13），重复点击被 UI 吞掉；LOADING 失败回 ERROR 态，ERROR 对话框关闭后按钮恢复。
- **If 玩家手删 user:// 所有文件后继续打卡**: 下次 autosave 目录自动重建、`.tmp` + rename 成功——**进度不丢**；meta 在设置变更 / 归档时自动重建；作弊意图反而无伤。QA：中途删完 user://，再打 5 张卡，冷启动应恢复最后状态。
- **If 玩家手动把 `current_run.save` 设为只读位**: autosave rename 失败（无法覆盖只读目标）——进入 ERROR "存档被锁定，请检查文件权限"；不自动 chmod。

### 10. 归档事务

- **If ARCHIVING 第 3 步 archive 写成功但第 4 步 current_run 删除失败（外部持锁）**: 按 Rule 9 整体回滚——删除已写的 archive（先清只读位）、保留 current_run、回 IDLE、下次 GAME OVER 重试。不留两者（会造成档案柜"历代员工 #N 与当前员工 ID 相同"的视觉 bug）。
- **If ARCHIVING 第 5 步 meta 更新失败但前 4 步成功**: archive 已存在、current_run 已删——**不回滚 archive**（archive 是事实）。内存标志 `meta_reconcile_pending = true`，进入 ERROR 对话框"归档写入不完整，将在下次启动时修复"；下次冷启动按 Rule 15 反向幂等补齐。
- **If ARCHIVING 期间玩家强制关机**: 按崩溃步骤号路由——崩在第 1-3 步：current_run 完整，走"继续"路径，玩家可能看到"死而复生"一次（已知权衡，是 Honor System + Rule 9 强原子性的代价）；崩在第 4-5 步：走 recovery 路径补齐。

---

*共 39 条 edge cases，每条可独立转为 QA 测试用例。Rule 15 / 16 / 17 已回填至 Core Rules；档案柜 200 局硬限的达限行为在本次 revision 中由 OQ-01 决议落为 Rule 23（Block new Run + 手动逐条清档），不再是 open question。*

## Dependencies

### 上游（Save System 依赖的系统）

**无**。Save System 位于 Foundation 层，不依赖任何 gameplay 系统。它只依赖 Godot 4.6 引擎本身（`FileAccess` / `DirAccess` / `JSON` / `WorkerThreadPool` / `NOTIFICATION_*` 信号）。

### 下游（依赖 Save System 的系统）

| System | Tier | 依赖类型 | 接口数据 | GDD 状态 | 反向引用（其 GDD 必列 Save） |
|---|---|---|---|---|---|
| **Scene & Day Flow Controller** (#6) | MVP | **Hard** | 日程位置 + 场景 ID；Save 的主调度者 | 未设计 | ✅ 必须 |
| **AP Economy System** (#7) | MVP | **Hard** | current_ap / spent_today / energy / exhaustion | 未设计 | ✅ 必须 |
| **NPC Relationship System** (#8) | MVP | **Hard** | 10 NPC 的 favor + flags + last_interaction_tick | 未设计 | ✅ 必须 |
| **KPI & Reverse Threshold** (#9) | MVP | **Hard** | current_threshold / base / effort / potential / tenure / 月历史 | 未设计 | ✅ 必须 |
| **Event Script Engine** (#10) | MVP | **Hard** | fired_events / cooldowns / global_flags / active_script 断点 | 未设计 | ✅ 必须 |
| **Action Card System** (#11) | MVP | **Hard** | played_cards_log / available / locked 集合 | 未设计 | ✅ 必须 |
| **Run Meta System** (#12) | MVP | **Hard** | run_id / Episode 计数 / 档案柜索引 / 解锁集合 / 便利贴池 / 设置 | 未设计 | ✅ 必须 |
| **HUD System** (#13) | MVP | **Soft** | 读 meta.settings（只读访问）；UI 记忆（可选） | 未设计 | ✅ 建议 |
| **Card Play & Dialogue UI** (#14) | MVP | **Soft** | 读 meta.settings.narrative_density；无写入 | 未设计 | ✅ 建议 |
| **Daily / Weekly Recap UI** (#15) | MVP | **Soft** | 读 current_run 的日/周快照；无写入 | 未设计 | ✅ 建议 |
| **KPI Review & Game Over UI** (#16) | MVP | **Hard** | 读 current_run 月历史 + 触发 ARCHIVING | 未设计 | ✅ 必须 |
| **Main Menu / Pause / Settings UI** (#17) | MVP | **Hard** | 读 current_run 存在性决定"继续"按钮；读写 meta.settings；触发 load | 未设计 | ✅ 必须 |
| **Tutorial / Onboarding** (#18) | VS | **Soft** | 读 meta.tutorial_progress flag；首次启动路径 | 未设计 | ✅ 建议 |
| **Notification & Warning (enhanced)** (#19) | VS | **Soft** | 无直接依赖；间接（通过 Scene & Day Flow 调度） | 未设计 | ❌ 不需 |

### 依赖类型定义

- **Hard（硬依赖）**: 下游系统无 Save 则完全无法工作（失去持久化 → 玩家进度丢失 → 游戏无法作为 "roguelite meta 累积" 成立）。共 **9 个系统**。
- **Soft（软依赖）**: 下游系统在 Save 缺失或降级时仍可运行（只是失去某些 UX 记忆 / 设置记忆 / 教程状态）。共 **5 个系统**。

### 反向依赖清单

当下游系统的 GDD 被撰写时，**以下 9 个 Hard 依赖系统的 "Dependencies" 小节必须列出 Save System**，否则 `/consistency-check` 会报错：

> `design/gdd/scene-day-flow.md`, `design/gdd/ap-economy.md`, `design/gdd/npc-relationship.md`, `design/gdd/kpi-reverse-threshold.md`, `design/gdd/event-script-engine.md`, `design/gdd/action-card.md`, `design/gdd/run-meta.md`, `design/gdd/kpi-review-game-over-ui.md`, `design/gdd/main-menu-ui.md`

Soft 依赖（HUD / Card Play UI / Recap UI / Tutorial）建议列但非强制。

### 外部依赖（非系统）

- **Godot 4.6 标准库**: `FileAccess`（4.4+ `store_*` 返回 `bool` 必须检查）、`FileAccess.set_read_only_attribute`、`DirAccess.rename()`、`JSON.stringify / parse_string`、`WorkerThreadPool.add_task`、`Callable`、`NOTIFICATION_WM_CLOSE_REQUEST`、`NOTIFICATION_WM_WINDOW_FOCUS_OUT`（**不使用** `NOTIFICATION_APPLICATION_PAUSED`——Android/iOS 专属桌面 no-op）
- **OS / 文件系统**: `user://` 跨平台路径、POSIX / Windows `MoveFileEx` 原子 rename 语义、磁盘 fsync
- **Steam Runtime（可选）**: Steam Cloud 的 Auto-Cloud filter 配置 `meta.save` + `archive/*.save`（见 Rule 20）；**不**走 Steamworks SDK 直接调用（纯文件过滤足矣）

*Save 文件的具体序列化格式（JSON 字段 schema）与 ADR-0001 绑定；本 GDD 不枚举字段名，各下游 GDD 自管其子 schema。*

## Tuning Knobs

所有数值以 **ProjectSettings**（编辑器常量）或 `SaveManager` Autoload 的 `@export var`（inspector 可见 + 运行时可写）暴露；真正不可变的 knob 用 `const`（编译期固定、不出现在 inspector）。**注**：GDScript 不允许 `@export const`——`@export` 仅修饰 `var`；曾经的草稿用法 `@export const X = 50` 在 Godot 4.4+ 会 parse error。每个 knob 的具体暴露机制（ProjectSettings vs `@export var` vs `const`）见 ADR-0001。

### 性能预算

| Knob | Default | Safe Range | Unit | 影响 | 高了坏事 | 低了坏事 |
|---|---|---|---|---|---|---|
| `autosave_perf_hard_ceiling` | 50 | 30 – 100 | ms | Pillar 5 承诺上限；超过必须降级 | Pillar 5 破防，玩家感到卡顿掉帧 | 过严格导致频繁降级触发，反而增加复杂度 |
| `autosave_perf_warning` | 30 | 20 – 40 | ms | 记告警日志的软阈值 | 日志噪声过多，真实问题被淹没 | 过灵敏，开发阶段被干扰 |
| `state_schema_review_threshold` | 262144 (256 KB) | 131072 – 524288 | bytes | 序列化体积审查告警（schema 膨胀前预警） | 告警迟到，发现时已难优化 | 开发阶段频繁误报 |
| `state_bloat_hard_limit` | 1048576 (1 MB) | 524288 – 2097152 | bytes | state 膨胀硬限，超过写 error log 但仍完成 save | 玩家可能已出现数秒延迟 | 正常游玩触发误报 |

### I/O 行为

| Knob | Default | Safe Range | Unit | 影响 | 注记 |
|---|---|---|---|---|---|
| `av_lock_retry_attempts` | 3 | 2 – 5 | 次 | AV/杀软锁目标文件时的重试次数 | 超过 5 次玩家体感暂停 |
| `av_lock_retry_backoff` | [50, 200, 800] | [20, 100, 400] ~ [100, 500, 2000] | ms 数组 | 指数退避间隔 | 总等待 = 重试次数中 `sum(backoff)` |
| `app_pause_save_timeout` | 500 | 200 – 1000 | ms | 退入后台/关窗时 autosave 最多等多久 | 过短可能丢数据；过长 Steam 强制关杀 |
| `archiving_lock_timeout` | 500 | 300 – 1000 | ms | ARCHIVING 等待当前 SAVING 完成的上限 | 超时强制中断 SAVING 进入 ARCHIVING 第 1 步 |
| `oom_retry_limit` | 3 | 2 – 5 | 次 | 连续 save 失败上限，超过进 ERROR 态 | |

### 设置 flush

| Knob | Default | Safe Range | Unit | 影响 |
|---|---|---|---|---|
| `settings_flush_debounce` | 500 | 200 – 1500 | ms | 玩家改设置后等多久再 flush 到 meta | 过短频繁写盘；过长关游戏时可能丢设置（但 WM_CLOSE 会强制 flush） |

### 档案柜容量（含 Open Question R16）

| Knob | Default | Safe Range | Unit | 影响 |
|---|---|---|---|---|
| `archive_soft_warning_count` | 180 | 150 – 190 | runs | HUD 提示"档案柜临近满载" |
| `archive_hard_cap_count` | 200 | 100 – 500 | runs | 达上限后 Block new Run + 弹"档案柜已满，请手动清档"（Rule 23，禁批量删）；OQ-01 已决 |

### 叙事 tone 守护（Rule 21 跨 GDD 锁定值）

| Knob | Default | Safe Range | Unit | 影响 |
|---|---|---|---|---|
| `final_transition_duration_ms` | 1500 | 800 – 1500 | ms | 离职证明 transition 总时长硬上限（Rule 21）；超上限违反 Pillar 3 "冷静打卡机"tone |
| `final_transition_easing` | NONE | NONE（枚举单值） | enum | 线性或即时切换；禁 ease-in / ease-out / bounce / elastic；#16 KPI Review & GO UI GDD 实现时必须遵守 |

### 平台防御

| Knob | Default | Safe Range | Unit | 影响 |
|---|---|---|---|---|
| `user_path_max_length` | 240 | 200 – 248 | chars | Windows MAX_PATH 防御；超过启动期拒绝进入 Run | 过低（< 200）Steam 深层库路径误报 |

### Schema 版本

| Knob | Default | Safe Range | Unit | 影响 |
|---|---|---|---|---|
| `current_schema_version` | 1 | 单调递增整数 | — | **不可回退**；每次字段变更 +1；MVP 阶段版本漂移不支持迁移，直接视同损坏 |

### 知识缺口 — 需 Polish / Alpha 阶段实测确定

- `av_lock_retry_backoff` 在 Windows Defender 启用场景的最优曲线（p99 延迟实测）
- `autosave_perf_hard_ceiling` 在 HDD + AV 扫描机器的实际 p99 是否能达成（若不能，需改为分帧拆解策略）
- `settings_flush_debounce` 与玩家习惯的滑块拖动频率匹配度（UX 测试）

### Knob 交互警告

- **`archive_soft_warning_count` 必须 < `archive_hard_cap_count`**（否则软警告逻辑失效）
- **`autosave_perf_warning` 必须 < `autosave_perf_hard_ceiling`**（否则告警永不触发）
- **`app_pause_save_timeout` 应 ≥ `autosave_perf_hard_ceiling` × 2**（保证单次 save 能完成）

*所有 knobs 建议由 `balance-check` skill 周期性扫描，偏离 Safe Range 即报警。*

## Visual/Audio Requirements

*N/A — Foundation/Infrastructure 系统无独立视觉/音频。Save 的 player-facing 反馈（"已存"指示器动效 / 存档对话框音效 / 归档仪式 transition）由 Audio Director + Art Director 在 HUD / Main Menu / Game Over UI 的设计阶段统一处理。本 GDD 只标记"需要一个低调的存档反馈 UI 元素"，细节留给 #13 HUD + #16 KPI Review/GO UI 的 GDD 自定。*

## UI Requirements

Save System **不拥有任何独立屏幕或 HUD 元素**；所有 UI 呈现由下游系统在各自 GDD 中实现。本节只列 Save 对 UI 的**接入点要求**（接口契约层面），供 UX 团队在撰写各 UI spec 时引用。

### Save 需要的 UI 接入点

| # | 接入点 | 归属系统 | 要求 |
|---|--------|---------|------|
| 1 | "已存"指示器 | HUD System (#13) | 每次 autosave 成功后 50 ms 内显示，持续 ≤ 1 s 后淡出；位置低调（右下/左上角小图标）；风格参考 "打卡机嘀一声" 的冷静感（见 Section B Tone） |
| 2 | 存档损坏对话框 | Main Menu UI (#17) | 文案需含"存档损坏"关键词；按钮 = 开始新 Run（默认焦点）+ 导出损坏文件 + 退出 |
| 3 | "上一局仍在进行中"确认对话框 | Main Menu UI (#17) | 玩家点"新游戏"且 `current_run.save` 存在时触发；按钮 = 继续上一局（默认焦点）+ 放弃并开新 Run（二次确认）+ 取消 |
| 4 | 崩溃恢复提示对话框 | Main Menu UI (#17) | 冷启动检测到孤立 `.tmp` 时触发；按钮 = 采用未完成存档 / 丢弃（默认焦点） / 取消。**默认焦点是"丢弃"还是"采用"待 UX lead 裁决 — 见 Open Questions** |
| 5 | "数值异常已修复"提示 | Main Menu UI (#17) | Rule 16 触发；一次性提示，按钮 = 了解 |
| 6 | "磁盘已满 / 权限错误 / 路径过长 / 存档被锁定"对话框 | Main Menu UI (#17) | ERROR 态统一对话框模板，根据错误类型切换标题与文案 |
| 7 | 历代档案柜列表 | Main Menu UI (#17) / Run Meta System (#12) | Save 只提供 `list_archives() -> Array[ArchiveMeta]` 只读接口；UI 展现由 Main Menu 设计 |
| 8 | GAME OVER 离职证明滑出 + 档案柜入口 | KPI Review & Game Over UI (#16) | ARCHIVING 事务完成后触发；Save 通过 `archive_complete` 信号告知 UI 可以开始播片 |
| 9 | 便利贴 HUD 提示板 | HUD System (#13) / Run Meta System (#12) | Save 只提供只读 memo 访问接口；实际展现由 HUD 设计 |
| 10 | 设置持久化入口 | Main Menu UI (#17) | Settings UI 改 → Save 以防抖 500 ms 写 meta；UI 无需等待 flush 完成 |

### 📌 UX Flag — Save System

本系统有 10 个 UI 接入点横跨 HUD / Main Menu / KPI Review & GO UI。进入 Phase 4 (Pre-Production) 时，应对下列屏幕/流程运行 `/ux-design`：

- `design/ux/main-menu.md` — 含存档相关所有对话框（#2-6）
- `design/ux/hud.md` — 含"已存"指示器 + 便利贴提示板 UX（#1, #9）
- `design/ux/game-over-ceremony.md` — 离职证明滑出 + 档案柜入口转场（#8）
- `design/ux/archive-viewer.md` — 历代档案柜列表浏览（#7）

各 UX spec 应引用本 GDD 的 Rule 与 AC 而非自行定义 Save 行为。

### Gamepad / Focus 要求（MVP 预留 Switch 移植路径）

所有存档相关对话框（#2-6）必须支持：
- D-Pad 导航
- A/B 按钮映射（A = 确认默认焦点 / B = 取消）
- 可见焦点环（`technical-preferences.md` 强制要求）
- 无纯 hover-only 交互

## Acceptance Criteria

43 条 AC 分 6 类（AC-FUNC 14 / AC-STATE 6 / AC-PERF 5 / AC-ROBUST 6 / AC-COMPAT 5 / AC-INTERFACE 7，后者全部 Deferred 待下游 GDD 设计）。MVP 必测 / 建议测 / VS tier 分级见末尾。

### AC-FUNC (功能性) — 14 条

- **AC-FUNC-01** (Rule 2 单槽铁人): **GIVEN** 玩家在 Run 进行中且 `user://current_run.save` 存在, **WHEN** QA 检查 `user://` 目录下所有文件, **THEN** 有且仅有一份 `current_run.save`，不存在 `current_run.save.slot2` / `.bak` / `.autosave1` 等多槽产物。
- **AC-FUNC-02** (Rule 3a Autosave on execute): **GIVEN** Run 进行中 AP=5, **WHEN** 玩家打出 cost=1 的行动卡使 AP 降为 4, **THEN** `execute` 返回后 100 ms 内 `current_run.save` 的 mtime 更新，重读解出 `current_ap == 4`。
- **AC-FUNC-03** (Rule 3b 日结算强制 flush): **GIVEN** 玩家完成当日最后一张卡, **WHEN** 时间推进到下一个 `time_of_day`, **THEN** 进入下一日 UI 前 `current_run.save` 已同步落盘（阻塞完成），强制 kill 进程后冷启动能读到 `day_ended == true`。
- **AC-FUNC-04** (Rule 4 覆盖写非增量): **GIVEN** 连续打 3 张卡各触发 autosave, **WHEN** QA 检查 `user://`, **THEN** 不产生 `.patch1/2/3` 或任何增量 diff 文件；仅 `current_run.save` 的 mtime 与 size 被刷新。
- **AC-FUNC-05** (Rule 9 归档事务): **GIVEN** Run 进入 GAME OVER, **WHEN** ARCHIVING 正常完成, **THEN** ① `archive/[run_id].save` 存在且只读位 ② `current_run.save` 不存在 ③ `meta.save` 的 `episode_count` +1 且 `last_archived_run_id == run_id`。
- **AC-FUNC-06** (Rule 10 便利贴只读): **GIVEN** `archive/` 下有 14 份历代存档, **WHEN** 新 Run 启动, **THEN** Run Meta 通过 Save 接口只读访问 memo 字段，任何写入尝试返回错误；新 Run 首帧 HUD 提示板显示 0–3 条 memo。
- **AC-FUNC-07** (Rule 13 Save/Load 互斥与 merge): **GIVEN** SAVING 进行中, **WHEN** 1 秒内玩家连打 10 张卡, **THEN** 磁盘落盘 ≤ 2 次，最终 `current_run.save` 的 state == 第 10 张卡后的 state（非中间态）。
- **AC-FUNC-08** (Rule 5 原子写 4 步 + snapshot_id): **GIVEN** 启用 FileAccess / WorkerThreadPool 调用日志钩子, **WHEN** autosave 触发一次, **THEN** 日志中出现顺序序列 `open(".tmp") → store_string(返回 true) → flush → close → rename`；store_string 返回 `false` 时记录 `save_write_failed` 并保留旧 save；并发连触 3 次 autosave 时 worker 按 `snapshot_id` 单调递增执行，旧 snapshot 被丢弃并 `stale_request_dropped` 计数器 +1。
- **AC-FUNC-09** (Rule 14 Meta save 与 current run 解耦): **GIVEN** Run 进行中玩家连打 5 张卡并触发 5 次 autosave, **WHEN** QA 对比 `meta.save` 操作前后的 mtime, **THEN** mtime 未更新（meta 仅在设置变更 / 归档 / 跨局解锁时写入，不与行动卡 autosave 同步）；改音量 1 次后 500 ms debounce 后 mtime 更新一次。
- **AC-FUNC-10** (Rule 18 pending_flags 持久化): **GIVEN** ARCHIVING 到第 5 步（meta 更新）中途 `kill -9`, **WHEN** 重启进入主菜单, **THEN** 冷启动日志出现 `meta_reconcile_pending=true` 被检测 + Rule 15 反向幂等补齐被触发；补齐完成后 `meta.save.pending_flags` 被**立即清空并 flush**；`meta.episode_count == count(archive/*.save)`。
- **AC-FUNC-11** (Rule 19 退出超时强制中断): **GIVEN** 人为注入 `app_pause_save_timeout=100` + autosave snapshot 500 ms 慢钩子, **WHEN** 发送 `NOTIFICATION_WM_CLOSE_REQUEST`, **THEN** SaveManager 100 ms 后强制中断当前写入；`.tmp` 被删除；旧 `current_run.save` 完整保留；进程在 ≤ 200 ms 内退出（不阻塞 Steam kill）。
- **AC-FUNC-12** (Rule 21 离职证明 timing 硬约束): **GIVEN** Run 进入 GAME OVER 并完成 ARCHIVING, **WHEN** #16 UI 开始离职证明 transition（`archive_complete` 信号后）, **THEN** UI profiler 测得 transition 总时长 ≤ 1500 ms；逐帧 dY 采样斜率恒定（线性 easing 断言，方差 < 5%）；任一不满足即 FAIL。
- **AC-FUNC-13** (Rule 22 跨局解锁 content-only 白名单): **GIVEN** 玩家完成 3 个 Run 各触发至少 1 次 cross-run unlock, **WHEN** QA 遍历 `meta.unlocks` 的 key 集合, **THEN** 全部 key 命中白名单 `{codex_entry_id, memo_id, npc_unlock_id, event_branch_id, ending_unlock_id}`；出现任何数值类 key（`starting_ap_bonus` / `starting_favor_delta` / `card_power_bonus` / `kpi_base_offset` 等）即 FAIL。
- **AC-FUNC-14** (Rule 23 archive 200 cap 行为): **GIVEN** fixture `archive_200_runs/` 下已有 200 份 run 存档 + 无 `current_run.save`, **WHEN** 玩家主菜单点"新游戏", **THEN** 弹对话框含文案"档案柜已满（200/200）"；"新游戏"按钮被拒；UI 不提供批量删除 / 全清按钮（DOM/focus 遍历断言）；玩家在 Archive 列表删除 1 份后"新游戏"按钮解锁。

### AC-STATE (状态转移) — 6 条

- **AC-STATE-01** (IDLE→SAVING→IDLE 合法): **GIVEN** IDLE 态, **WHEN** 触发 autosave, **THEN** 状态依次进入 SAVING 并在写入完成后回到 IDLE；状态日志出现 `IDLE→SAVING→IDLE` 序列。
- **AC-STATE-02** (SAVING→LOADING 禁止): **GIVEN** 系统处于 SAVING, **WHEN** 单元测试注入 load 请求, **THEN** 请求被拒（返回 `ERR_BUSY` 或同等错误），不进入 LOADING；SAVING 完成回 IDLE 后 LOAD 才可接受。
- **AC-STATE-03** (LOADING→MIGRATING MVP 阻塞): **GIVEN** MVP 下 `schema_version=0` 的旧存档, **WHEN** 玩家点"继续", **THEN** LOADING 检测到旧版后 **不** 进入 MIGRATING，直接转 ERROR 弹"存档来自旧版本"。
- **AC-STATE-04** (ARCHIVING 拒绝其他 I/O): **GIVEN** ARCHIVING 进行中, **WHEN** 注入 autosave 请求 + load 请求, **THEN** 两个请求被排队或拒绝；archive 不被打断；事务完成后才处理队列。
- **AC-STATE-05** (ERROR→IDLE 需玩家确认): **GIVEN** 系统在 ERROR（磁盘已满）, **WHEN** 玩家点"重试"或"新局", **THEN** 回 IDLE；在玩家选择前任何 autosave 请求被丢弃或排队。
- **AC-STATE-06** (IDLE→ERROR 必经中间态): **GIVEN** IDLE 无错误, **WHEN** QA 通过测试钩子直接跳 ERROR, **THEN** 状态机拒绝（断言失败 / 日志错误）；所有进入 ERROR 的转移必先经过 SAVING/LOADING/ARCHIVING/MIGRATING 之一。

### AC-PERF (性能) — 5 条

- **AC-PERF-01** (Rule 6 硬门槛 end-to-end): **GIVEN** state 体积 20 KB，测试机 = MacBook Air M2 SSD / Windows 11 NVMe SSD / Ubuntu 22.04 ext4 SSD，AV 默认开启, **WHEN** 连续触发 1000 次 autosave, **THEN** 从 `request_autosave()` 到 worker `rename` 完成的端到端耗时 p50 < 18 ms 且 p99 < 50 ms；主线程 snapshot 聚合耗时 p99 < 3 ms（独立计量）；超任一门槛记 FAIL。
- **AC-PERF-02** (Rule 7 主线程 off-thread 不阻塞): **GIVEN** Run 进行中 FPS 稳定 60, **WHEN** 玩家 1 秒内连打 10 张卡（每张 fire autosave）, **THEN** Godot Profiler "Main" 过滤下**主线程**帧曲线无任何一帧 > 16.6 ms；snapshot 聚合阶段 p99 < 3 ms；Worker Thread 耗时独立计量（stringify + I/O p99 < 50 ms，不计入主线程预算）；UI "已存"指示器在 snapshot 派发后 50 ms 内可见。
- **AC-PERF-03** (Tuning Knob `autosave_perf_warning=30 ms`): **GIVEN** autosave 实际耗时 35 ms, **WHEN** 写入完成, **THEN** 日志出现 `WARN save slow: 35ms`，游戏不中断、状态回 IDLE。
- **AC-PERF-04** (Tuning Knob `state_schema_review_threshold=256 KB`): **GIVEN** state 体积 300 KB, **WHEN** autosave 完成, **THEN** 日志出现 `WARN state bloat warning: 300KB > 256KB`；save 本身成功。
- **AC-PERF-05** (档案柜批量): **GIVEN** `archive/` 下 200 份 run 文件, **WHEN** 主菜单点"档案柜", **THEN** 目录体积 < 5 MB；列表渲染 < 200 ms（p99，SSD）；滚动 FPS ≥ 60。

### AC-ROBUST (健壮性) — 6 条

- **AC-ROBUST-01** (Edge 2.1/2.2 崩溃): **GIVEN** autosave 正在写 `.tmp`, **WHEN** QA 在 `.tmp` 写入时 `kill -9` 进程（Win `taskkill /F`）, **THEN** 重启后 ① 旧 `current_run.save` 未被破坏 ② 孤立 `.tmp` 被正确处理（完整则提示采用/丢弃，不完整则静默删除）。
- **AC-ROBUST-02** (Edge 3.4 手改 AP): **GIVEN** QA 文本编辑器把 `current_ap: 5` 改为 `999`, **WHEN** 点"继续", **THEN** 加载不抛异常不崩溃；Save 不拒绝；AP 字段以 999 载入（clamp 责任在 AP System）；通过指标 = 进程未退出。
- **AC-ROBUST-03** (Edge 3.1 损坏弹窗): **GIVEN** QA 将 `current_run.save` 替换为 `"{ invalid json"`, **WHEN** 点"继续", **THEN** 弹对话框含文案"存档损坏"，`user://` 下生成 `current_run.save.corrupt_[ISO8601]`；"继续"按钮变灰。
- **AC-ROBUST-04** (Edge 1.1 磁盘满): **GIVEN** QA `dd` 填满 `user://` 所在卷到剩余 < 10 KB, **WHEN** 触发 autosave, **THEN** 旧 `current_run.save` 保留；残留 `.tmp` 被删除；进入 ERROR 对话框含"磁盘已满"。
- **AC-ROBUST-05** (Edge 6.2 / Rule 16 NaN 净化): **GIVEN** 测试钩子注入 `effort_accumulator = NaN, potential = +Inf`, **WHEN** autosave 完成并 reload, **THEN** 两字段值为 `0.0`；`sanitized_fields` 数组包含对应路径；loader 展示一次"数值异常已修复"对话框。
- **AC-ROBUST-06** (Edge 2.3 ARCHIVING 崩溃回滚): **GIVEN** ARCHIVING 到第 3 步完成后、第 4 步前, **WHEN** QA `kill -9` 并重启, **THEN** `archive/[run_id].save` 被删除（含清只读位）；`current_run.save` 完整保留；"继续"可用；再次 GAME OVER 能正常归档。

### AC-COMPAT (平台兼容) — 5 条

- **AC-COMPAT-01** (Windows): **GIVEN** Windows 11 + Defender 默认开, **WHEN** 完整 smoke：新 Run → 打 20 张卡 → 退 → 冷启动继续 → GAME OVER → 归档 → 重开, **THEN** 全流程无 ERROR；autosave p99 < 50 ms；`user://` 路径为 `C:\Users\<name>\AppData\Roaming\Godot\app_userdata\...`。
- **AC-COMPAT-02** (macOS): **GIVEN** macOS 14+ Gatekeeper 默认，user:// 位于 iCloud Drive 同步目录, **WHEN** 执行 AC-COMPAT-01 相同 smoke, **THEN** 全流程通过；`.DS_Store` 不干扰 archive 计数；mtime 单调递增可验证。
- **AC-COMPAT-03** (Linux): **GIVEN** Ubuntu 22.04 ext4, **WHEN** 执行同 smoke, **THEN** 全流程通过；`user://` 为 `~/.local/share/godot/app_userdata/...`；权限 0644，archive 只读等效 0444。
- **AC-COMPAT-04** (Rule 20 Steam Cloud filter ironman 守护): **GIVEN** Steam Cloud 启用，Auto-Cloud filter 配置符合 Rule 20（include: `meta.save` + `archive/*.save`；exclude: `current_run.save` + `*.tmp` + `*.log` + `*.corrupt_*`；设置存于 `meta.save` 内，无独立 settings.cfg 文件）, **WHEN** 打 5 张卡后退游戏并触发 Steam Cloud 同步, **THEN** Steam 上传列表仅含 `meta.save` + `archive/*.save`，**不含** `current_run.save` 及任何临时/日志/损坏文件；配额消耗（含最多 200 archives）< 700 KB。
- **AC-COMPAT-05** (Rule 20 跨 PC ironman 守护): **GIVEN** PC-A 开局打 5 张卡后退游戏并完成 Steam Cloud 同步, **WHEN** 玩家在 PC-B 启动游戏（PC-B 本地 user:// 初始为空）, **THEN** PC-B 本地 `meta.save` + `archive/*.save` 存在（Cloud 同步到位，设置随 `meta.save` 同步）但 `current_run.save` **不存在**；主菜单"继续"按钮灰；档案柜显示 PC-A 已归档的历代员工；PC-B 点"新游戏"正常开启新 Run 且不与 PC-A 进行中 Run 冲突（冲突在文件 filter 层消除，Save System 不处理 Steam 原生冲突弹窗）。

### AC-INTERFACE (接口契约) — 7 条 [全部 Deferred 直至下游 GDD 设计完成]

> 本节 7 条 AC 依赖下游系统 GDD（#6/7/8/9/10/11/12）的接口契约细节，而下游 GDD 当前状态为 **未设计**。MVP 阶段**不测试**本节 AC；每条 AC 在其对应下游 GDD 完成 `/design-review` 后，由该 GDD 的 `/design-review` 阶段激活为"Save System ↔ [系统] 接口契约 AC"并反向引用；激活时本 GDD 对应 AC 前缀改为 `✅ Activated by [path]`。未激活时 QA 计划不得把这 7 条 AC 纳入 Alpha gate。

- **AC-INTERFACE-01** (Scene & Day Flow #6) [Deferred until `design/gdd/scene-day-flow.md`]: **GIVEN** 存档停在 `Y1/M3/W2/D4/Afternoon` 场景 `office_desk`, **WHEN** 冷启动点"继续", **THEN** Controller 接管后 500 ms 内切到 `office_desk`，HUD 日期显示 `Y1 / 3月 / 第2周 / 周四 / 下午`。
- **AC-INTERFACE-02** (AP Economy #7) [Deferred until `design/gdd/ap-economy.md`]: **GIVEN** 存档 `current_ap=3, spent_today=2, exhaustion=1`, **WHEN** load 完成, **THEN** AP System 回灌后三字段值与存档完全一致（debug overlay 对比）。
- **AC-INTERFACE-03** (NPC Relationship #8) [Deferred until `design/gdd/npc-relationship.md`]: **GIVEN** 存档内 10 位 NPC 的 favor 值构成集合 S, **WHEN** load 完成, **THEN** NPC System 回灌后遍历读出的 favor 集合 = S；`last_interaction_tick` 无丢失。
- **AC-INTERFACE-04** (KPI & Threshold #9) [Deferred until `design/gdd/kpi-reverse-threshold.md`]: **GIVEN** 存档 `tenure_months=5` 且月历史快照数组长度 5, **WHEN** load 完成后进入 KPI Review UI, **THEN** 月曲线渲染 5 个点；`current_threshold` / `base_threshold` / `effort_accumulator` / `potential` 与存档一致。
- **AC-INTERFACE-05** (Event Script #10 断点续跑) [Deferred until `design/gdd/event-script-engine.md`]: **GIVEN** Run 暂停时 `active_script_id="boss_lecture"` 且 `step_index=7`（checkpoint）, **WHEN** 冷启动点"继续", **THEN** Event Engine 从 step 7 续跑；`fired_events` / `cooldowns` / `global_flags` 与存档一致。若 `step_index=8` 处于不可恢复 UI 分支，回退到最近 checkpoint（step 7）。
- **AC-INTERFACE-06** (Action Card #11) [Deferred until `design/gdd/action-card.md`]: **GIVEN** 存档 `played_cards_log` 长 17，`available_cards` 25，`locked_cards` 8, **WHEN** load 完成, **THEN** 手牌 UI 渲染后三集合大小与存档一致；锁定卡显示 `reason` 文本。
- **AC-INTERFACE-07** (Run Meta #12 + Main Menu) [Deferred until `design/gdd/run-meta.md` + `design/gdd/main-menu-ui.md`]: **GIVEN** `current_run.save` 存在, **WHEN** 启动进入主菜单, **THEN** "继续"按钮可点（非灰）；点"新游戏"弹含"上一局仍在进行中"的对话框；主菜单展示的 `episode_count` / `最高集数` 来自 `meta.save`。

### Tier 分级

**MVP 必测（Alpha gate 阻塞）— 34 条**:
AC-FUNC-01~14 (14) + AC-STATE-01~06 (6) + AC-PERF-01/02/04 (3) + AC-ROBUST-01~06 (6) + AC-COMPAT-01~05 (5) = **34**。新增的 AC-FUNC-08~14 覆盖 Rule 5/14/18/19/21/22/23 全部 MVP 必测——7 条新 AC 均可用 fixture / profiler / DOM 断言自动化，不增加手工 QA 负担。

**MVP 建议测（Beta gate 阻塞）— 2 条**:
AC-PERF-03（`autosave_perf_warning` 日志阈值）、AC-PERF-05（200 局档案柜性能 — 复用 AC-FUNC-14 fixture `archive_200_runs/`）。

**VS tier 推迟 — 11 条**:
- AC-INTERFACE-01~07（7 条，全部 Deferred 直至对应下游 GDD 设计完成；见 AC-INTERFACE 小节头说明）
- schema 迁移链（Migration）—— MVP AC-STATE-03 已锁死"视同损坏"
- Tutorial flag soft 依赖 AC
- iCloud Drive 冲突并发写专项（AC-COMPAT-02 强化）
- Honor System 显式不测反作弊（QA 计划需声明：AC-ROBUST-02 只测"不崩"非"拒绝作弊"）

**Polish Release gate**：AC-PERF-01 在 **HDD + AV 扫描** 机器上的 worker p99 专项实测（OQ-03 知识缺口）；若未达 50 ms 升 Release blocker 并触发 Pillar 5 "地铁可玩"承诺在 AV-retry 路径下的降级评估（当前 AC-PERF-01 在 SSD 路径下已足够）。

### QA 工具需求

**存档 fixture 库** (`tests/fixtures/save-system/`)：
- `valid_minimal.save`, `valid_20kb.save`, `valid_300kb.save`
- `corrupt_truncated.save`, `corrupt_non_utf8.save`, `corrupt_missing_schema_version.save`
- `schema_v0_legacy.save`, `schema_vfuture.save`
- `tampered_ap_999.save`, `nan_inf_floats.save`
- `archive_200_runs/`

**崩溃模拟工具**：跨平台 `kill -9` / `taskkill /F` 参数化脚本（"在第 N 毫秒杀"）；QEMU / VMware 快照用于硬断电；Windows Defender / macOS XProtect stub 用于 AV 锁；`chmod 0555` / `attrib +R` 用于只读目录；`dd` / `fsutil` 用于磁盘满。

**性能 profiler**：Godot 内建 Profiler（主线程 + WorkerThreadPool 分区）；外部 `hyperfine` 跑 1000 次 autosave；逐帧 `Performance.MONITOR_TIME_PROCESS` 抓取帧时序列断言无 > 16.6 ms。

**Test matrix**：Win11 + NVMe + Defender ON；Win11 + HDD + AV OFF；macOS 14 + iCloud ON；Ubuntu 22.04 ext4；Steam Cloud 启用/禁用；深路径 OneDrive（> 240 chars）。

**State 注入钩子**：`SaveManager.test_inject_state(Dictionary)` 仅 debug build 开放（供 AC-ROBUST-02/05/06 构造）。

**状态机日志**：`SaveManager` 输出 `state_transition: IDLE→SAVING@t=1234ms` 结构化日志供 AC-STATE-01~06 断言。

## Open Questions

本 GDD 在撰写过程中累积的未决问题，分类按 Owner 列出。每条含**触发日期 / 影响范围 / 目标解决时机 / Owner**。

### OQ-01: 档案柜 200 局硬上限后的行为 ✅ RESOLVED 2026-04-23

- **决议**: 选项 ① — Block new Run + 弹"档案柜已满（200/200），请手动清档"对话框，玩家在 Main Menu → Archive 列表**逐条**删除（禁批量删除）。详见 Core Rule 23 + AC-FUNC-14。
- **原因**: 选 ① 保 Pillar 3 "剧终是归档事实"叙事承诺；选 ②（ring buffer 覆盖最旧）静默销毁最早的历代员工档案，违反"数据留下、人走了"承诺；选 ③（允许 Run 但不归档）产生无存档 Run 同样破坏承诺。逐条删除 + 禁批量 保障销毁事实的仪式感。
- **Owner**: game-designer（本次 revision session 决策）
- **玩家影响**: 200 局 ≈ 累计 1000+ 小时，MVP 不会触达；长线玩家（Beta 外）首次遇到弹窗时必须显式决定"哪位前员工先告别"，强化 Pillar 3 基调。

### OQ-02: 崩溃恢复对话框的默认焦点与文案

- **问题**: Edge Case 2.1 冷启动检测到完整 `.tmp` 时，对话框默认焦点是"采用未完成存档"还是"丢弃"？文案具体是什么（配合 Pillar 4 黑色幽默 tone）？
- **Owner**: UX lead + writer
- **影响**: AC-ROBUST-07（待补）；Main Menu UI spec；玩家首次遭遇崩溃的感受
- **目标解决**: `/ux-design main-menu` 阶段
- **推荐**: 默认"采用"（玩家期望最小惊奇）；但若"采用"触发后再次崩溃会形成无限循环，需 UX + godot-specialist 联合评估

### OQ-03: HDD + AV 扫描场景的 p99 性能实测

- **问题**: Tuning Knobs Section G "知识缺口"标出：`autosave_perf_hard_ceiling=50ms` 在 HDD + Windows Defender 启用场景是否能达成。若不能，需降级策略：分帧拆解 save / 强制背景线程 / 玩家可选"低配模式"禁 autosave？
- **Owner**: performance-analyst + godot-specialist
- **影响**: Pillar 5 承诺能否兑现；Polish 阶段是否需要额外优化工作量
- **目标解决**: Polish 阶段（Release gate 硬要求）；若 MVP 阶段有低配测试机亦可提前

### OQ-04: `av_lock_retry_backoff` 最优曲线

- **问题**: Tuning Knob `[50, 200, 800] ms` 是猜测值。真实 AV 锁释放时间分布在 Windows Defender / macOS XProtect / Linux inotify 上可能差异大。
- **Owner**: performance-analyst
- **影响**: Edge Case 1.4 AV 锁场景的 p99；玩家在杀软干扰下的体验
- **目标解决**: Polish 阶段 compat matrix 测试完成后

### OQ-05: `settings_flush_debounce=500ms` UX 匹配度

- **问题**: 500 ms 是否与玩家真实滑块拖动习惯匹配？过短 → 拖动中频繁写盘；过长 → 快速切 UI 时最后设置未落（虽 WM_CLOSE 会兜底）。
- **Owner**: ux-designer
- **影响**: Settings 使用手感；MVP 非 blocker
- **目标解决**: Alpha playtest 中观察

### OQ-06: Steam Cloud 冲突 UX 处理 ✅ RESOLVED 2026-04-23

- **决议**: Core Rule 20 —— Steam Cloud filter **排除** `current_run.save`，仅同步 `meta.save` + `archive/*.save` + `settings.cfg`。冲突在文件层消除：PC-A / PC-B 不会同时持有"同一 Run 的不同版本"，因为活动 Run 的 `current_run.save` 永远只存在于开局那台 PC 本地。
- **原因**: 选项分析：(a) 云同步 current_run + Steam 原生冲突窗 → 玩家可在冲突窗"选旧版本"绕过决策，破坏 Pillar 3 ironman 纪律；(b) 云同步 current_run + 自研冲突窗 → 实现复杂度 ↑，且无法阻止玩家手动"放弃本地 / 采用云端"选择；**(c) 不同步 current_run** → 根本上消除冲突路径，代价是玩家跨 PC 时"想继续活动 Run 需回到开局 PC"（可接受，Pillar 3 承诺高于跨机便利）。
- **玩家体感**: "换电脑时上一局没了（想继续请回开局那台机）、但历代员工档案和设置都在"——冷静打卡机的 tone 同样适用于跨机预期设定。
- **Owner**: game-designer + producer（本次 revision session 决策）
- **合规**: 档案柜（archive/*.save）和 meta 仍云同步，保证玩家在任何 PC 都能看到历代员工记录；AC-COMPAT-04/05 已按 Rule 20 重写。

### OQ-07: schema_version 从 MVP 到 VS 的过渡时机

- **问题**: MVP 阶段 `current_schema_version = 1`，Rule 11 规定旧版直接"视同损坏"。何时切换到 VS 的 migrate 链？切换时现有玩家 MVP 存档如何处理（完全失效？一次性升级？）？
- **Owner**: systems-designer + producer
- **影响**: MVP → VS 过渡的玩家留存；Migration-AC-1 激活时机
- **目标解决**: VS 立项 kickoff 时
