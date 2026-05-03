# Daily / Weekly Recap UI

> **Status**: Designed — revised 2026-04-29 (3 BLOCKING resolved + 6 RECOMMENDED + 4 NICE-TO-HAVE)
> **Author**: huanghaibin + game-designer (全文主笔) + creative-director (Section B framings) + systems-designer (Section C 12 Rules + Section E edges) + ux-designer (Visual/UI 契约) + qa-lead (Section H 23 AC) + design-review B1/B2/B3 仲裁
> **Last Updated**: 2026-04-29
> **Layer**: Presentation | **Order**: #15 | **Size**: M
> **Implements Pillar**: P2 主(叙事即机制 — 数字是事实,HR 口吻是包装)+ P5 守(90s 内完成,地铁可跳)+ P4 守(戏谑化 HR 周报口吻 + 数字克制 + Anti-P2 红线)
> **Authoring autonomy mode**: v2 no-prompt(全程 0 widget,routine autopilot);**Review autonomy mode**: lean batch-revise(3 BLOCKING + 6 RECOMMENDED + 4 NICE 同轮清,跨 GDD propagation flags 化)

---

## Section A: Overview

**Daily / Weekly Recap UI** 是《活过第 X 集》的**日报 / 周报双模渲染层** —— 每日 `DAILY_RECAP` sub-mode(<90s)中展示当日 AP 用度、当日事件回顾、Energy 状态;每周五触发升级为 `WEEKLY_RECAP` 展示,在玩家进入下月之前呈现 7 天事件列表、effort 三维度周摘要、KPI 阈值进度(无进度条,仅具体数字)。

### 双重身份

**技术层**: `#15` 是纯渲染层。订阅 `#7 ap_changed / energy_changed / effort_*_incremented`(非月末周 effort 累积)+ `#7 monthly_effort_summary`(月末周 effort 三维度数据);订阅 `#10 event_completed` 一周事件回顾列表;订阅 `#9 kpi_threshold_changed(breakdown)` **仅月末**为 KPI 阈值变化拆解(non-effort schema:tenure_contrib / capacity_now / overage_contrib)+ `kpi_review_started` 触发退出转 `#16`。**自身不持有任何业务逻辑计算**,不写 Save,不拥有事件文本(仅引用 `#3 Localization` key),不持有 KPI 公式(由 `#9` own)。帧预算 ≤ 2 ms / 屏。

**叙事层**: 玩家感受到的不是"结算面板",是**周五下午 5 点的 HR 周报** —— 事务性轻盈、数字克制、不庆祝、不审判。每日总结是一张打卡记录,每周总结是 HR 系统自动生成的工作量登记单。"本周有趣事件"一栏不叫"高光时刻",它叫"本周备忘"。

### Pillar 服务

- **P2 主 叙事即机制**: `numeric_only` 事件风格让"周二: Lisa 找你吃饭了 / 周四: 加班 1 次"成为事实存档而非剧情,数字 = 档案记录。effort 三维度周摘要(基于 `#7 effort_*_incremented` 周累计 + `#7 monthly_effort_summary` 月末 push)是机制自我解释,不是 tutorial。月末 KPI 涨幅拆解 breakdown(`#9 Rule 10` schema:tenure / capacity / overage 三因子)由 `#16 KPI Review` own 渲染,**`#15` 不展示** — 月末转 `#16`。
- **P5 守 地铁可玩性**: Daily Recap < 90s 守门(`#6 Rule 6 A sub-mode` 约定);周报同等 budget;skippable 注册(`#6 Rule 12`)保证玩家地铁一站可跳过。帧预算 ≤ 2 ms / 屏防 sub-mode 切换掉帧。
- **P4 守 黑色幽默**: HR 周报口吻 lint(`#7 Rule 13 AP 反英雄红线 + #6 主语翻转 + #9 Rule 14 HR 口吻`) 扩展至 `RECAP.*` key 域。**禁**进度条 / 百分比 / "本周完成度" —— 进度条 = 玩家主导 = 励志感 = 违反 Anti-Pillar 2。

### 5 NOT 边界(scope creep 防护)

- **NOT** 月末 KPI 结算屏(由 `#16 KPI Review & Game Over UI` own;`#15` 仅日/周,月末转 `#16`)
- **NOT** 事件文本 / 对白字符串(由 `#3 Localization` own;`#15` 仅持 Localization key)
- **NOT** KPI 公式 / effort 数学(由 `#9` / `#7` own;`#15` 仅消费 emit 的 breakdown 结构)
- **NOT** 数据持久化(纯渲染层,不写 Save;读取来自已持久化的 `#7` / `#9` / `#10` 信号)
- **NOT** 跨周 / 跨月长程展示(全 Run 历史展示 = `#12 Run Meta` own;`#15` 仅当日 / 当周)

### 5 NOT 红线(违反即破坏 Pillar)

- **NOT** 显示进度条 / 百分比 / "完成度"(违反 P4 数字克制 + Anti-Pillar 2 励志感)
- **NOT** 出现"恭喜" / "太棒了" / "本周高效" / "完美收工"类正能量文案(违反 Anti-Pillar 2 + P4)
- **NOT** 超过 90s 未提供 skip 入口(违反 P5 地铁可玩性)
- **NOT** 持有 UI 以外的业务数据或写 Save(渲染层不拥有业务数据)
- **NOT** 在月末最后一日 Daily Recap 替代 `#16`(月末结算转 `#16`,不 fallback 到 `#15`)

### Source 引用

`design/gdd/game-concept.md` Core Loop §L120-158(日/周/月/年 4 时间尺度 + 30-second loop anchored to 日报) + Pillars §L162-191(P2/P4/P5 服务锚)。`#6 scene-day-flow-controller.md` Section A 8 sub-mode `DAILY_RECAP`(<90s) + Rule 12 skippable 注册协议。`#7 ap-economy-system.md` Rule 14 信号架构(`ap_changed / energy_changed / effort_*_incremented`)。`#9 kpi-reverse-threshold-system.md` Rule 10 涨幅拆解 breakdown 结构 + Rule 13 信号架构。`#10 event-script-engine.md` Rule 19 `numeric_only` 风格 + Rule 20 `event_completed` 信号。`#3 localization-hooks.md` Rule 4 `tr()` + `_IRONY` 后缀。`#5 lighting-visual-state.md` Rule 1 `DAILY_RECAP` sub-mode 数据屏蓝光 context。

---

## Section B: Player Fantasy

### 主锚: "周五下午 5 点的周报"

**场景**:
周五 17:58,`AFTER_WORK` sub-mode 收尾,`scene_state_changed(AFTER_WORK → DAILY_RECAP)` 发出。Lighting 切换至数据屏蓝光(蓝灰 `#1A2A3A`,`#5 Rule 1`)。屏幕出现一张 HR 系统自动生成的周工作记录表:

> **周工作记录 — 第 4 周**
> 本周你打了 47 张卡,3 张是 Hero 卡,Lisa 跟你说了 2 次话。
> 加班: 1 次 / 早退: 2 次 / 精力余量: 38
> 本周备忘: 周二午餐事件已登记 / 周四加班记录归档
> 下月 KPI 参考区间: 103 → _(待月末结算)_

没有"恭喜完成本周工作"。没有进度条。没有"效率评分"。就是一张表 —— 工号、时段、次数。**像 HR 软件的周报导出,不像游戏结算面板**。

**Pillar 服务**:
- **主 P2 叙事即机制**: "47 张卡 / 3 张 Hero / 2 次对话"是数据存档,不是叙事旁白。数字 = 玩家行为的 bureaucratic 记录,机制自我解释
- **守 P5 地铁可玩性**: 地铁 5 分钟内可完成一周总结 + skip 入口随时可跳
- **守 P4 黑色幽默**: "Lisa 跟你说了 2 次话"这句话的克制本身就是反讽 —— 不是"你和 Lisa 关系升温了",是 HR 数据库里冷静的 `contact_count = 2`

**跨 GDD negative space 联动**:
- **Audio** "月末打卡机不是胜利音" 共振: 周报出现时配合办公室 ambient(不切 BGM 不出胜利音)
- **Lighting** 数据屏蓝光(`#5 Rule 1`): 周报界面始终在蓝光 context 中,视觉上像"工位电脑屏幕"
- **KPI `#9`** "102 → 105" 共振: 周报的 KPI 参考区间是 C1 觉察锚的预视 —— 让玩家在月末 `#16` 审判前已经看见数字在涨

**❌ Tone 风险(必避)**:
- "本周你完成了 X% 目标,棒棒的!"(励志进度条)
- "高效员工徽章解锁"(游戏化收集)
- "你和 Lisa 的友谊深了"(友情化 = 违反 Anti-Pillar 2)
- 任何 "well done" / "恭喜" / "继续加油" 类正能量文案

**✅ Tone 守护(推荐)**:
- "47 张卡"(具体数字,事实记录)
- "Lisa 跟你说了 2 次话"(数量,非情感评价)
- "本周备忘"(HR 档案语气,非"高光时刻")
- "加班 1 次 / 早退 2 次"(事实数据,无价值判断)

### 副锚: "今天你打了 8 张卡,第 3 张是给王总的"

> **N1 注**:本副锚标题为设计描述(designer 视角对玩家行为的复述),**非 localizable RECAP.* key 域文案**。RECAP 域文案须遵循 Rule 11 主语翻转(系统主语 / 时间主语 / 被动陈述),范例见 Rule 11 表。

**场景**:
日报模式(非周五)。`DAILY_RECAP` sub-mode,30s 内展示。屏幕浮出一行行事务性记录:

> **日工作记录 — 周三**
> 今日 AP: 8 / 精力: 52(昨日 46,+6 早退回复)
> 今日事件: 组长群发周报模板 / 下午茶被叫跑腿 / 王总发邮件(你回了)
> 今日备注: 无加班 / 无早退

没有"今日任务完成!"。没有 AP 格子金色动画。数据屏蓝光配合,打卡机声音一响,就是这一天。**你不是"完成了今天",今天是"过完了"**。

**Pillar 服务**:
- **主 P2**: 三件事的 `numeric_only` 风格列表是事件引擎(`#10`)和 AP 系统(`#7`)的数据回传,机制直接翻译为叙事档案
- **守 P4**: "第 3 张是给王总的"来自模板变量注入(`#10 Rule 8`)的 `{收件人}` 槽 —— 不是剧情,是数据点

**跨 GDD negative space 联动**:
- **AP Economy** `ap_changed` 信号(`#7 Rule 14`): 当日 AP 总量来源
- **Event Script** `event_completed` 信号(`#10 Rule 20`): 今日事件列表来源

**❌ Tone 风险(必避)**:
- AP 格子动画呈现"用满了!完美!"(违反反英雄红线 `#7 Rule 13`)
- "今日高效完成率"进度圆弧(进度条 = 励志感)

**✅ Tone 守护**:
- "今日 AP: 8"(数字事实,无评价)
- 今日事件列表风格"组长群发周报模板"(客观叙述,无情感标签)
- "无加班 / 无早退"(数据标注,非"今日休息"类游戏化用语)

---

## Section C: Detailed Rules

12 Core Rules + States and Transitions + Interactions。

### Core Rules

**Rule 1 — Daily Recap UI 触发协议(`#6 DAILY_RECAP` sub-mode)**

订阅 `#6 scene_state_changed(from: SubMode, to: SubMode, ctx: Dictionary)`。**`ctx` payload 契约**(由 `#6 Rule 3` 仲裁扩展,B1 propagation flag #6 守门):

```gdscript
ctx = {
    "is_weekly": bool,            # true 当 to==DAILY_RECAP 且 current_weekday == 5(周五)
    "is_weekend": bool,           # true 当 to==DAILY_RECAP 且 current_weekday ∈ [6, 7]
    "is_last_day_of_month": bool, # true 当 to==DAILY_RECAP 且 current_day == month_total_days
    "current_day": int,           # 当月第 N 天(供 Recap 日期标注)
    "current_weekday": int        # 1..7
}
```

`#15` 在收到信号后 ≤ 1 帧内完成渲染准备(禁止在 signal handler 内执行重负载,遵循 `#6 Rule 3 R2 mitigation`)。展示内容:

| 字段 | 数据来源 | 说明 |
|------|---------|------|
| 今日 AP 总量 | `#7 ap_changed(current, max)` 最新缓存值 | 最终使用量 = `max - current` |
| 精力当前值 | `#7 energy_changed(current, max)` 最新缓存值 | 昨日值 + 当日变化 |
| 今日加班次数 | `#7 effort_overtime_incremented` 当日累计 | 0 或 1(MVP 单次机制) |
| 今日早退 flag | `#7 ap_early_leave_taken()` 是否触发 | bool |
| 今日事件列表 | `#10 event_completed` 当日 history | `numeric_only` 风格,上限 8 条(Rule 4 密度) |

显示时长上限 = `DAILY_RECAP_MAX_DURATION_MS = 90000`(90s gate knob)。达到上限时 `#15` 自动 emit `recap_timeout()` → `#6` 接管进入 `MORNING_BRIEFING`(次日)。

Daily Recap 不展示 KPI 进度(当日无结算);KPI 数字仅在 Weekly Recap 中呈现(Rule 2)。

**Rule 2 — Weekly Recap UI 触发协议(每周五 DAILY_RECAP 升级)**

每周五的 `scene_state_changed(AFTER_WORK, DAILY_RECAP, ctx)` 触发时,`ctx.is_weekly == true`(per Rule 1 ctx 契约)。`#15` 据此渲染 `WEEKLY_RECAP` 视图(覆盖 Daily 视图)。**禁**轮询 `#6` 公开属性(`#15` 仅消费 `ctx`,与 `#6` 单点解耦)。

**周末两天合并**:周末两天(`AFTER_WORK → DAILY_RECAP` 在 day 6 / day 7)展示精简 Daily Recap(Energy 恢复记录),不展示 KPI 周摘要(周末不结算)。周摘要 KPI breakdown 仅在周五呈现一次。Weekly Recap 在玩家进入下周 `MORNING_BRIEFING`(次周一)之前展示。

**月末最后一个周五特例**:月末最后一周若周五紧接月末,`#15` 展示本周 Weekly Recap 后,由 `#6 Rule 10` 触发 `KPI_REVIEW` sub-mode,转交 `#16`。`#15` 不展示月末结算内容(月末结算完全由 `#16` own)。

**Rule 3 — effort 三维度展示(来源 `#7` effort 信号族,HR 口吻锁继承 `#9 Rule 14`)**

Weekly Recap 中展示 effort 三维度周摘要。**Schema 来源**:
- **非月末周**:`#7 effort_overtime_incremented` / `effort_hero_incremented` / `effort_overage_incremented` 周累计计数(从周一起累加,周五展示)
- **月末周(周五 + `is_last_day_of_month` false 但 ≤ 月末最后一周)**:同上(`#7 monthly_effort_summary` 仅在 `KPI_REVIEW` 触发时 push 给 `#9`,**非** `#15` 的数据源)
- **月末周五紧接月末日**:per Rule 2 月末特例,`#15` 转 `#16`,Weekly Recap 不再独立展示 effort breakdown(由 `#16` 在 KPI Review 屏整合)

> **注意 schema 边界**:`#9 Rule 10 breakdown` 是月末 KPI 涨幅三因子拆解(tenure_contrib / capacity_now / overage_contrib / delta_pct),**与本 Rule 的 effort 三维度不是同一 schema**。`#15` Weekly Recap 不消费 `kpi_threshold_changed.breakdown`(由 `#16` own)。

展示三行,使用 HR 口吻(继承 `#9 Rule 14` + KPI research §8.1 戏谑 HR 口吻锁):

```
本周努力维度登记:
- 加班记录:    [N 次] — 积极性已登记
- Hero 卡打出: [N 张] — 超额贡献已归档
- 超预期事件:  [N 次] — 产出记录存档

本月当前阈值: [XXX] → 下月预测区间: [___](待月末结算)
```

**禁**进度条 / 百分比 / "完成度" —— 三行展示绝对数字 + HR 口吻标注(Rule 5 数字克制守门)。

**Rule 4 — 一周事件回顾(`#10 event_completed` history,numeric_only 风格)**

Weekly Recap 中展示本周 7 天 `event_completed` history,格式为 `numeric_only` 风格列表(继承 `#10 Rule 19` 三档叙事密度约定):

```
本周备忘:
  周一: 组长群发周报模板
  周二: Lisa 找你吃饭了
  周三: 回邮件 × 3
  周四: 加班 1 次 / 打印机卡纸
  周五: 王总约谈(你去了)
  (周六/日: 休息)
```

**上限 8 条 / 周**:超出 8 条时按 `priority` 降序选 top 8 展示(Formula D1)。优先级来源:事件 schema 的 `weight` 字段(继承 `#10 Rule 10` weight 机制;higher weight → higher priority in recap)。

**绑定 `numeric_only` 渲染规则**:每条事件仅显示事件标题文本(对应 Localization key `EVENT.[event_id].TITLE_NUMERIC` 或 `.TITLE_SHORT`)。**禁**在 Recap 中重放 `long` 档叙事内容(违反性能契约 + P5 budget)。

Daily Recap 同样展示当日事件列表,上限 8 条(同规则)。

**Rule 5 — 数字克制原则**

`#15` 全界面禁止:

| 禁止元素 | 违反原则 |
|---------|---------|
| 进度条 / ProgressBar | Anti-Pillar 2 励志感 + P4 HR 口吻冲突 |
| 百分比("完成 87%") | 进度条的文字变体 |
| "本周完成度" / "效率指数" | 游戏化 KPI 语义 = 违反 Anti-Pillar 1 |
| 颜色编码红/绿语义评价 | 评判性视觉 = 违反 P4 HR 口吻克制 |
| 星级评分 / emoji 勋章 | 游戏化收集 = 违反 Anti-Pillar 1 |

**允许元素**:绝对数字(47 / 3 / 2)、事务性标签("已登记" / "存档" / "待月末结算")、无色调或冷色调文字(数据屏蓝光 context 内单色呈现)。

**Rule 6 — HR 周报口吻 lint(扩展 `#10 Rule 19` `subject_inversion_lint.py`)**

`RECAP.*` Localization key 域加入 CI lint 扫描,扩展 `subject_inversion_lint.py --domain RECAP`:

- **禁** 玩家主语句:"你完成了 / 你高效 / 你的本周 / 你的表现"
- **禁** 励志词族:"恭喜 / 太棒了 / 继续加油 / 突破自我"(白名单 `GAMEOVER.TITLE_IRONY` 不影响)
- **要求** 系统主语 / 被动句:"系统已登记 / 本周备忘 / 积极性已存档"
- **要求** `_BUREAUCRATIC` 后缀用于 HR 口吻标注词条(同源 tone,异 namespace:本 GDD 的 `_BUREAUCRATIC` 用于 `RECAP.*` Localization 文本 key 域;`#4 Audio` 同名后缀用于 SFX 资源 key 域 — 两者共享 tone 约束但文件类型不同,lint 工具按 namespace 分别扫描;继承 `#10 Rule 19` 主语翻转 lint 拓展)

CI 阻塞 PR。writer review 第三层守门(继承 `#3 Loc Rule 11` tone 守护三层执法结构)。

**Rule 7 — Skippable 注册协议(继承 `#6 Rule 12` + `#2 Input Rule 6`)**

`#15` 在 `DAILY_RECAP` 进入时向 `InputHandler` 注册 skippable:

```gdscript
InputHandler.register_skippable(
    token_id = &"daily_recap_skip",
    on_skip = _on_recap_skipped
)
```

退出 `DAILY_RECAP`(无论超时 / 玩家 skip / 正常结束 / 强制中断)时**必须注销**:

```gdscript
InputHandler.unregister_skippable(&"daily_recap_skip")
```

Skip 触发后 `#15` emit `recap_skipped()` → `#6` dispatch `DAILY_RECAP → MORNING_BRIEFING`(次日)。**Weekly Recap skip 行为同 Daily**:skip 整个 Weekly 视图,不支持分段跳过 effort / 事件 / KPI 三部分(避免 UI 状态机复杂度)。

**月末倒数 2 周 Weekly Recap 最小展示守门(P2 主 vs P5 守 仲裁,B3 RESOLVED)**:

P2 主"机制自我解释" vs P5 守"地铁可跳过"的 tension 通过**渐进守门**调和 — Weekly Recap 在月末倒数 2 周(`current_week_in_month ∈ [3, 4]` 即 W3/W4)启用最小展示锁:

| 周次 | Skip 行为 | 理由 |
|------|----------|------|
| **M1/M2 全月** + **M3+ W1/W2** | 即时 skip(token 注册即可触发) | P5 主导,M1/M2 教学期 + 月初 effort 累积尚不显著 |
| **M3+ W3 / W4(月末倒数 2 周)** | **最小展示 1500ms 锁**(继承 `#6 GAMEOVER` 1500ms 守门同构) | P2 服务窗口 — effort 三维度此时已显著累积,玩家 skip 前必看见数字 1.5 秒 |

**仲裁锚点对齐**:1500ms 锁与 `#9 kpi_prediction_hint`(月末倒数 2 天 emit)节奏耦合 — `#15` 在 W3/W4 守门 + `#9` 在月末 D-2/D-1 emit hint,两套机制叠加确保玩家在 KPI 审判前的最后 2 周内**至少一次**看见 effort 累积 + NPC 预言锚。

**实施**:Rule 7 token 注册时附 `min_display_ms` 参数(继承 `#2 Rule 6` 拓展 — 默认 0;月末 W3/W4 Weekly Recap 注册时传 1500):

```gdscript
InputHandler.register_skippable(
    token_id = &"daily_recap_skip",
    on_skip = _on_recap_skipped,
    min_display_ms = 1500 if (ctx.is_weekly and _is_late_month_week(ctx)) else 0
)
```

`_is_late_month_week(ctx)` 判定:`ctx.current_day` 落在月末倒数 2 周内(MVP 简化:每月固定 4 周,W3/W4 = day ∈ [15, 31]),野心版按月动态计算。

`InputHandler` `min_display_ms` 拓展实施由 `#2 Input Handler` 同步(propagation flag #7 守门)。

**Rule 8 — 帧预算 ≤ 2 ms / 屏**

`#15` 订阅 `#6 scene_state_changed` handler 内仅做"状态标记 + 数据引用缓存",不在 handler 内实例化节点 / 触发 layout。实际渲染委托至 `call_deferred()` 入下一帧(遵循 `#6 Rule 3 R2 mitigation`):

| 操作 | 预算 | 机制 |
|------|------|------|
| Signal handler 内(主线程同帧) | ≤ 0.5 ms | 仅赋值缓存引用 |
| 节点 layout / `tr()` 调用 | ≤ 1.5 ms | `call_deferred` 入下一帧 |
| 总 recap 屏绘制 | ≤ 2 ms / 帧 | draw calls < 20 |

**Rule 9 — dispatch 时序 ≤ 1 帧内容可见**

`#15` 从收到 `scene_state_changed` 到 recap 内容可见 ≤ 1 帧(16.6 ms 预算内)。数据全部来自已有信号缓存(不阻塞查询远端 API)。内容可见定义:顶层 Container 子节点可见 + 至少 1 行文本完成 `tr()` 解析。完整渲染(含所有事件列表行)可在 ≤ 3 帧内完成(分帧渲染,LabelLine 延迟 instantiate)。

**Rule 10 — Save 无持久化(纯渲染层)**

`#15` 不写 Save。不持有任何业务状态变量(AP / KPI / 事件 history 全由 `#7` / `#9` / `#10` own)。`#15` 每次渲染从最新信号缓存构建视图,无本地 state 在 sub-mode 之间持久。若 `DAILY_RECAP` 被中途 kill(crash / Alt+F4),View state 丢失无影响(业务数据由上游 autosave 保护)。

**Rule 11 — 主语翻转原则 + Pillar 4 反英雄 lint**

所有 `RECAP.*` key 文案审校遵循 `#6 Section B 主语翻转原则`:

| 违反(玩家主语) | 要求(时间/系统主语) |
|--------------|-----------------|
| "你今天用了 8 AP" | "今日 AP 已全部消耗" |
| "你本周打了 47 张卡" | "本周行动卡记录: 47 张" |
| "你的精力很好" | "精力余量: 52" |
| "你和 Lisa 的对话" | "Lisa 互动记录: 2 次" |

`_BUREAUCRATIC` 后缀强制:所有带 HR 口吻标注的词条须使用 `RECAP.EFFORT.OVERTIME_REGISTERED_BUREAUCRATIC` 格式命名。

**Rule 12 — Scope Tier**

| Tier | Daily Recap | Weekly Recap | 触发条件 |
|------|-------------|-------------|---------|
| **MVP** | 当日 AP + 精力 + 事件列表(≤8) | 7 天事件(≤8) + effort 3 维度 + KPI 预测区间 | 每日触发 / 周五升级 |
| **VS** | 同上 + NPC 互动次数摘要 | 同上 + 月度子摘要预览(一行,本月进度) | 同上 |
| **野心版** | 同上 | 同上 + 季度历史对比迷你离散点图(非进度条) | 同上 |

MVP 不实现跨周 / 跨月历史对比。**VS 月度子摘要落 Weekly Recap**(单行"本月进度",对齐 Rule 1 "Daily Recap 不展示 KPI 进度"边界);`#15` 仅提供月度进度参考,**不**替代 `#16` 月末结算屏。野心版季度对比用迷你离散点图而非进度条(守 Rule 5 数字克制)。

### States and Transitions

| 状态 | 进入条件 | 退出条件 |
|------|---------|---------|
| `RECAP_IDLE` | 初始 / recap 展示结束 | `scene_state_changed(→DAILY_RECAP)` |
| `DAILY_RECAP_ACTIVE` | `scene_state_changed(→DAILY_RECAP)` + `is_weekly == false` | skip 触发 / 超时 90s / recap 展示完成 |
| `WEEKLY_RECAP_ACTIVE` | `scene_state_changed(→DAILY_RECAP)` + `is_weekly == true` | skip 触发 / 超时 90s / recap 展示完成 |

Weekly Recap 是 Daily Recap 的**视图超集**,不是独立 sub-mode(共享同一个 `DAILY_RECAP` sub-mode 槽,`#15` 内部区分渲染模式)。

### Interactions with Other Systems

| # | 对端 | 方向 | 主接口 |
|---|------|------|--------|
| I-1 | `#6 Scene & Day Flow` | 双向 | 订阅 `scene_state_changed(→DAILY_RECAP)` + `is_weekly` 参数;emit `recap_skipped / recap_timeout` 供 `#6` 接管 |
| I-2 | `#7 AP Economy` | 订阅 | `ap_changed / energy_changed / effort_*_incremented` 周摘要缓存 |
| I-3 | `#9 KPI System` | 订阅 | `kpi_review_started` 触发月末退出转 `#16`;`kpi_threshold_changed` 仅订阅事件名,**不消费 breakdown 三因子**(by `#16` own per Section A 边界);`kpi_prediction_hint`(可选)月末倒数 2 天附 1 行 hint 文字 |
| I-4 | `#10 Event Script Engine` | 订阅 | `event_completed` history — 当日/本周事件列表构建 |
| I-5 | `#3 Localization Hooks` | 消费 | `tr(key)` 所有 `RECAP.*` 文本;`_IRONY` / `_BUREAUCRATIC` 后缀 |
| I-6 | `#5 Lighting` | 被动 | `DAILY_RECAP` sub-mode 下 Lighting 自动切换数据屏蓝光(由 `#5 Rule 1` + `#6` 联动;`#15` 不主动调 Lighting API) |
| I-7 | `#2 Input Handler` | 消费 | `register_skippable / unregister_skippable` 协议(Rule 7) |
| I-8 | `#16 KPI Review UI` | 下游转 | 月末 Weekly Recap 结束后 `#6` dispatch `KPI_REVIEW`,`#15` 退出,`#16` 接管 |
| I-9 | `#17 Settings UI` | 订阅 | 订阅 `narrative_density_changed(tier)` 信号(ADR-0001 + ADR-0004 + ADR-0012,B-DEP-1 守门);周报 summary 三档 fallback 链共享 `#14` `_select_*_by_density()` 函数(brief 1 行 / standard 3 行 / verbose 6 行 per event);PAUSE 中改 locale → resume 后单次 reflow(ADR-0004 协议) |

---

## Section D: Formulas

### D1 — 事件密度截断选取

**当周(或当日)事件总数 > `RECAP_EVENT_LIST_MAX` 时**,按优先级降序选 top k 展示。

```
显示事件集 = top_k(completed_events, k=RECAP_EVENT_LIST_MAX, key=λe: e.priority)

其中:
    completed_events = {e | e.status == "completed", e.day ∈ scope}
        scope = [current_day] (Daily) 或 [monday..friday] (Weekly)
    e.priority = e.schema.weight + Σ(delta_weight_k | condition_k)
                 (继承 #10 F1 effective_weight;weight 越高 priority 越高)
    RECAP_EVENT_LIST_MAX = 8  (Tuning Knob,feel 类)
    同 priority 时:按 day 倒序(最新优先);同 day 同 priority:按 event_completed 时间戳降序
    top_k:确定性排序,无随机
```

| 变量 | 类型 | 范围 | 说明 |
|------|------|------|------|
| `completed_events` | `Array[EventRecord]` | [0, ~20/week] | `#10` 已完成事件 history |
| `e.priority` | float | [0.01, 150] | 继承 `#10 F1 effective_weight` 范围 |
| `RECAP_EVENT_LIST_MAX` | int | [4, 12] | Tuning Knob,默认 8 |

**Worked Example(周报)**:本周 12 个已完成事件,priority 排序后 top 8 展示(weight 数值来源:`#10 F1 effective_weight`,范围 [0.01, 150]):
- weight 50 → "王总约谈"(周五)
- weight 40 → "Lisa 摊牌"(周二)
- weight 35 → "组长例会"(周一) + "客户邮件"(周四)
- weight 20 × 4 → "回邮件"(周一/二/三/四,按 day 倒序)
- 剩余 4 条(weight 10)被截断,静默不展示(无"还有 N 条"提示)

---

## Section E: Edge Cases

15 边缘场景 / 5 分类 / 2 [RISK GUARD]。

### Cat 1: 周末 Weekly Recap 触发边界

**E-1.1 — 周五月末重合**
条件: `is_weekly == true` AND `is_last_day_of_month == true`。
处理: `#15` 展示 Weekly Recap(正常)。展示结束后 `#6 Rule 10` 触发 `request_transition(KPI_REVIEW)`;`#15` 在收到 `scene_state_changed(DAILY_RECAP → KPI_REVIEW)` 时立即注销 skippable token + 退出(`#6` 接管)。`#15` **不**展示月末结算内容,严格停止于事件列表 + effort 摘要 + KPI 区间。

**E-1.2 — 周末两天 DAILY_RECAP 触发(休息日)**
条件: `#6` 在 day 6 / day 7 emit `scene_state_changed(→DAILY_RECAP)` + `is_weekend == true`。
处理: `#15` 展示精简 Daily Recap(无事件列表 —— 周末无 `ACTION_DAY`);仅显示 Energy 恢复记录("休息日精力 +30")。`is_weekly` 在周末两天为 `false`(周摘要仅周五一次)。

**E-1.3 — 游戏第一天(M1 D1)无历史数据**
条件: 首次 `DAILY_RECAP` 触发,`completed_events` 为空,`#7` 当日 effort 全为 0。
处理: 展示"今日备忘: 无已完成事件记录"(`RECAP.DAILY.NO_EVENTS_BUREAUCRATIC`)。精力与 AP 字段正常展示初始值。Weekly Recap 在 M1 W1 同理展示"本周备忘: 无已完成事件记录"。不崩溃,不弹错误弹窗。

### Cat 2: Skippable Race 条件

**E-2.1 — skip token 注册时机 race**
条件: `#15` 在信号 handler 内提前 `register_skippable()`,但 `#6` 尚未完成 sub-mode 转移。
处理: `register_skippable` 调用置于 `call_deferred` 路径(handler 内标记 + deferred 注册),防止 token 先于 `DAILY_RECAP` sub-mode 激活。`InputHandler` sub-mode guard 兜底拦截错序 skip。

**E-2.2 — 玩家在 Weekly Recap 期间 Alt+F4**
条件: `WEEKLY_RECAP_ACTIVE` 期间进程意外退出。
处理: `#15` 未写 Save(Rule 10),`#7` / `#9` / `#10` 数据已由 autosave 保护。重启后 `#6` 从 Save meta 恢复 sub-mode;若 meta 记录 sub-mode = `DAILY_RECAP`,则重新进入 Recap 渲染。Recap 内容从缓存信号重建,无丢失风险。

**E-2.3 — skip 与 recap 超时同帧发生**
条件: 玩家在第 89999 ms 按 skip,同帧 `recap_timeout()` 触发。
处理: 两路径均 emit `recap_ended`。`#6` 只处理第一个到达的信号;第二个被 idempotent guard 丢弃(状态机已离开 `DAILY_RECAP` 时再收到 `recap_timeout` 静默忽略)。不崩溃。

### Cat 3: 事件密度超上限

**E-3.1 — 当日事件 > 8 条**
条件: 玩家当日触发 12 个 `event_completed`(高密度叙事设置 + 多事件触发日)。
处理: D1 公式截断,top 8 展示,剩余 4 条不展示。不展示"还有 N 条未显示"(避免游戏化数字暗示)。截断静默发生。

**E-3.2 — 本周事件 = 0(纯摸鱼周)**
条件: 玩家 5 天全部早退 + 无任何事件触发(概率极低但合法)。
处理: Weekly Recap 事件区块显示"本周备忘: 无已完成事件记录"。effort 三维度仍正常展示(早退记录 + Energy 恢复)。KPI 预测区间正常展示。不崩溃。不展示"本周你完全摸鱼了!"类评价(违反 P4)。

**E-3.3 — 事件 priority 全相同无法区分**
条件: 本周 10 个事件 `effective_weight` 全为默认值 20.0。
处理: D1 同 priority 时按 `day` 倒序(周五最新优先)。若同 day 同 priority,按 `event_completed` 时间戳降序。保证确定性排序(无随机)。

### Cat 4: 数字 0 / 极端值

**E-4.1 — 精力 = 0(burnout_flag = true)**
条件: `current_energy == 0`。
处理: `#15` 展示"精力: 0"(`RECAP.ENERGY.ZERO_BUREAUCRATIC` key)+ HR 口吻标注"精力余量归零,次日加班功能暂停。"不展示红色警告 / 闪烁(违反数字克制 Rule 5)。

**E-4.2 — effort 三维度全为 0(完全摸鱼周)**
条件: 本周 0 次加班 + 0 Hero 卡 + 0 超预期事件。
处理: Weekly Recap 三行全展示 "0"。KPI 预测区间仍展示(阈值由工龄 `γ·tenure` 项驱动,仍会微涨)。不展示"本周你完全摸鱼了!"类评价(违反 P4)。不崩溃。

**E-4.3 — KPI 预测区间(非月末周)**
条件: 非月末周,`#9` 不 emit `kpi_threshold_changed`(per `#9 Rule 2` 仅月末触发);`#7 monthly_effort_summary` 也仅月末 push 给 `#9`(per `#7 Rule 6`)。
处理: Weekly Recap KPI 区块显示"下月参考区间: _(待月末结算)"(`RECAP.KPI.PENDING_SETTLEMENT`)。`#15` 不向 `#9` / `#7` 发起实时计算请求(防渲染层驱动业务计算)。若 `#9 kpi_prediction_hint`(月末倒数 2 天 emit,per `#9 Rule 11`)信号可用则附 1 行 hint 文字(老 NPC 预言锚),否则不展示估算数值。

**E-4.4 — `#7` / `#10` 信号在 Recap 前未到达(时序 race)**
条件: `scene_state_changed(→DAILY_RECAP)` emit 时 `#7` 当日信号仍在处理队列。
处理: `#15` 展示当前已缓存值(可能为上一时刻快照)+ fallback "数据更新中"标注。3 帧后重新查询缓存。不阻塞渲染。不崩溃。

### Cat 5: HR 口吻 Lint

**E-5.1 — [RISK GUARD] R-RCP-1: 进度条 / 百分比违反数字克制原则**

风险: 开发者实现 Recap UI 时使用 Godot `ProgressBar` 节点或文案写入"本周完成 72%"。
**防护**:
1. CI lint `--domain RECAP` 扫描 `RECAP.*` key 禁止词族("完成度 / 效率 / 百分比 / %")
2. Code Review checklist 禁 `ProgressBar` / `TextureProgressBar` 节点出现在 Recap 场景树中
3. AC-FUNC-09 自动化守门:场景树 node 类型扫描脚本(GDScript Unit Test via GUT)
4. 设计文档 Rule 5 明确禁用元素列表作为 PR 阻塞门

**E-5.2 — [RISK GUARD] R-RCP-2: skippable token 未注销导致 leak(跨 R-SDF-5 守门)**

风险: `#15` 在 `DAILY_RECAP → MORNING_BRIEFING` 转移时未调用 `unregister_skippable()`,导致 token 残留,下一天进入 `ACTION_DAY` 时 `act_skip` 仍触发 recap 回调(R-SDF-5 跨系统守门)。
**防护**:
1. `#15` 在 `scene_state_changed` handler 收到任何非 `DAILY_RECAP` 目标 sub-mode 时,无条件调用 `unregister_skippable()` + `push_warning`(二次注销静默)
2. `_exit_tree()` 钩子同样调用 `unregister_skippable()` 防节点销毁时 leak
3. AC-ROBUST-01 守门:集成测试 force-transition 至 `MORNING_BRIEFING`,断言 `InputHandler.has_skippable(&"daily_recap_skip") == false`

---

## Section F: Dependencies

### Upstream(上游 — `#15` 消费)

| 系统 | 依赖关系 | 主接口 | 双向确认 |
|------|---------|--------|---------|
| `#6 Scene & Day Flow` | `DAILY_RECAP` sub-mode 触发信号 + `is_weekly` 参数 + `is_weekend` 参数;skippable 注册路由 | `scene_state_changed(from, to)` | ✓ `#6 Rule 12` + `#6 Rule 3` 已声明 `#15` 为订阅者 |
| `#7 AP Economy` | AP 用度 / 精力 / effort 三维度累积信号 | `ap_changed / energy_changed / effort_*_incremented / monthly_effort_summary` | ✓ `#7 Rule 14` 信号架构已声明 `#15 Recap` 为 effort 展示订阅者候选 |
| `#9 KPI System` | KPI 阈值预测区间(非月末周 fallback "待月末结算");`kpi_review_started` 触发月末退出转 `#16`。**注**:`#9 Rule 10 breakdown` 三因子拆解(tenure/capacity/overage)由 `#16` own 渲染,`#15` 不消费 | `kpi_threshold_changed` (订阅但不渲染 breakdown 三因子) / `kpi_review_started` | ✓ `#9 Rule 13` 信号架构已声明 `#15 Recap` 订阅 `kpi_review_started`;`kpi_threshold_changed.breakdown` 渲染由 `#16` own |
| `#10 Event Script Engine` | 当日/本周事件列表(numeric_only) | `event_completed` history | ✓ `#10 Rule 20` 性能契约声明 Recap 消费 `event_completed` |
| `#3 Localization Hooks` | `RECAP.*` 所有文本 key | `tr(key)` + `_IRONY` / `_BUREAUCRATIC` 后缀 | ✓ `#3 Rule 4` `tr()` 纪律适用所有 UI 系统 |
| `#5 Lighting` | `DAILY_RECAP` 数据屏蓝光 context | 被动(由 `#5 Rule 1` + `#6` 自动触发) | ✓ `#5 Rule 1` 8 sub-mode 色值表含 `DAILY_RECAP` 蓝光 |
| `#2 Input Handler` | Skippable 注册 / 注销 API | `register_skippable / unregister_skippable` | ✓ `#2 Rule 6` skip 协议;`#15` 须遵循 token 生命周期 |

### Downstream(下游 — 依赖 `#15`)

| 系统 | `#15` 提供什么 | 依赖时机 |
|------|--------------|---------|
| `#16 KPI Review & Game Over UI` | 月末 Weekly Recap 结束后 `#6` dispatch `KPI_REVIEW`,`#16` 接管展示月末结算 | 每月末最后一个 Daily Recap 结束后 |

### Cross-GDD Propagation Flags

以下上游 GDD 变更须同步更新 `#15`:
1. `#6 Rule 12` skippable 接口变更 → `#15 Rule 7` 须同步
2. `#7 Rule 14` 信号参数变更(如 `effort_overtime_incremented` 新增参数)→ `#15 Rule 1/3` 缓存逻辑须同步;**`#7` 须在下次 GDD review 时 Rule 14 信号订阅表加列 `#15 Recap` 为 `effort_*_incremented` 订阅者**(与 `#13 HUD` 并列;当前 `#7 Rule 14` 表仅列 `#13` — 双向 cross-check 不严密,R4 propagation flag)
3. `#9 Rule 10` `breakdown` schema 字段增减 → **不影响 `#15`**(`#15` 不消费 `breakdown` 三因子,由 `#16` own,per Section A 边界);仅在 `kpi_review_started` 信号签名变更时 `#15` Rule 2 月末退出协议须同步
4. `#10 Rule 19` `numeric_only` 渲染规则扩展 → `#15 Rule 4` 列表生成逻辑须同步
5. `#3` `_BUREAUCRATIC` / `_IRONY` 命名约定变更 → `#15 Rule 6` lint domain 须扩展
6. **`#6 Rule 3` `scene_state_changed` 信号签名扩展(B1 RESOLVED 锚)** → `#6` 须将信号扩展为 `scene_state_changed(from, to, ctx: Dictionary)`,`ctx` payload 含 `is_weekly` / `is_weekend` / `is_last_day_of_month` / `current_day` / `current_weekday` 字段(per Rule 1 ctx 契约)。`#6` GDD 同步更新后 OQ-RCP-01 关闭。**当前状态**:`#6 Rule 3` 仅定义 `(from, to)` 两参数,B1 守门要求 `#6` GDD 下次 revision 同步加 ctx;在此之前 `#15` 实施挂起。
7. **`#2 Input Rule 6` `register_skippable` API 拓展(B3 RESOLVED 锚)** → `#2` 须将 `register_skippable` 签名拓展为 `register_skippable(token_id, on_skip, min_display_ms: int = 0)`(per Rule 7 月末倒数 2 周守门 1500ms 实施)。**当前状态**:`#2` GDD `register_skippable` API 当前签名仅 `(token_id, on_skip)`,B3 守门要求 `#2` 下次 revision 加 `min_display_ms` 参数;在此之前 `#15` Rule 7 月末守门挂起,但即时 skip 路径不受影响。

---

## Section G: Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 分类 | 说明 |
|------|------|--------|------|------|------|
| `DAILY_RECAP_MAX_DURATION_MS` | int | 90000 | [45000, 120000] | gate | Daily / Weekly Recap 自动超时门限;低于 45s 违反 P5 可读性;高于 120s 违反 P5 地铁 budget |
| `RECAP_EVENT_LIST_MAX` | int | 8 | [4, 12] | feel | 单次 Recap 事件列表上限条数;低于 4 丢失叙事感;高于 12 违反 P5 budget |
| `RECAP_HR_COMMENT_POOL_SIZE` | int | 30 | [15, 60] | feel | HR 周报口吻评语词条池大小;MVP 最少 15 条覆盖 effort 组合;野心版 60+;词条由 writer 维护 |

### HR 周报口吻词条池(词条触发逻辑说明)

`RECAP_HR_COMMENT_POOL_SIZE` 控制 `RECAP.WEEKLY.HR_COMMENT_*` key 组。词条触发逻辑由 effort 三维度 + 当周早退/加班组合决定(非随机,遵循 `#9 Section B Internal Design Test HR 口吻原则`):

| 触发条件 | 示例词条 |
|---------|---------|
| 加班 ≥ 2 次 + Hero ≥ 2 张 | "积极性可嘉,产能登记已更新" |
| 早退 ≥ 2 次 + 无加班 | "出勤记录合规,弹性安排已存档" |
| 全部 8 AP 用尽且无早退无加班 | "本周考勤正常,无异常记录" |
| effort 三维度全 0 | "本周数据已归档,无特殊记录" |
| 加班 + Hero 高 + 超预期高 | "多维贡献已登记,下月绩效参数调整中" |

所有词条 **HR 档案语气,描述性而非评判性**。词条不含励志成分。

---

## Visual / Audio Requirements

### 视觉 Context

`#15` 渲染在 `DAILY_RECAP` sub-mode 视觉 context 中。**`#5 Rule 1`** 锁定 `DAILY_RECAP` CanvasModulate = 数据屏蓝灰 `#1A2A3A`。`#15` 不持有 Lighting 资源,不调用 Lighting API。视觉风格由 `#5` 自动覆盖。

**字体使用**(`#3 Localization` 4 级字体层级,art-bible §7.2):
- Recap 主体文字: 思源黑体 Regular(数据记录档案感)
- 标题 / 系统标注: 方正公文宋(HR 官方感)
- 最小字号: 11 px(CJK 笔画可读,art-bible §7.2 `AUTO_FIT_FLOOR_PX = 11`)

**颜色**: 单色冷调呈现(蓝灰色系)。**禁**红/绿语义颜色(违反数字克制 Rule 5)。数字文本与标注文本使用不同灰度层次区分,非颜色编码。

**动画**: 无庆祝动画 / 无金光特效。文字 fade-in ≤ 200ms;逐行延迟 30ms 呈现(视觉分层感)。Weekly Recap 整页 fade-in,不分区块动画(避免过度动效 = 励志仪式感)。

**📌 UX Flag**: `/ux-design design/ux/daily-recap-screen.md` + `/ux-design design/ux/weekly-recap-screen.md` — Phase 4 产出(Presentation Layer UX 阶段)。`ux-designer` 须覆盖:日报/周报布局规范 + Gamepad D-Pad focus 链(skip 按钮 focus 态) + 字体层级落地规范 + 数字克制原则 visual language 守门 + 场景树节点规范(禁 ProgressBar)。

### 音频 Context

`DAILY_RECAP` sub-mode Audio 切换至"今日总结 ambient"(由 `#4 Audio Rule 6` + `#6` 联动;`#15` 不主动调 Audio API)。**不**切 BGM,**不**出打卡胜利音(继承 `#4 Audio Rule 5` Pillar 4 红线)。周报展示用同一 ambient(不专门为 Weekly Recap 切换 ambient,避免"周五仪式感")。

Skip 触发后 sub-mode 切换至 `MORNING_BRIEFING`,由 `#6` dispatch + `#4` Audio 响应(不在 `#15` 内触发音效)。

---

## UI Requirements

`#15` 是**日报 / 周报两屏 own 者**(Presentation Layer 主屏之一)。

**日报屏(Daily Recap Screen)**:
- 顶部: 日期标注("第 X 天 / 周 Y")+ HR 系统标头
- 中部: AP 用度 + 精力 + 加班 / 早退标注
- 下部: 今日事件列表(≤ 8 条,`numeric_only` 风格)
- 底部: Skip 提示("按任意键继续" — 主语翻转守门:不写"跳过"二字)
- Gamepad: 任意键 skip;D-Pad 无事件列表内滚动(MVP);列表截断 ≤ 8 条静默

**周报屏(Weekly Recap Screen)**:
- 顶部: 周标注("第 X 周 / 月 Y")+ HR 周报标头
- 中上: effort 三维度周摘要(三行 HR 口吻)
- 中: 本周 KPI 参考区间(一行数字)
- 中下: 一周事件列表(≤ 8 条,日期标注格式)
- 底部: Skip 提示
- Gamepad: 同日报屏

**📌 UX Flag**: 两屏完整规格见 Phase 4 `/ux-design` 产出(设计阶段 4)。

---

## Open Questions

**OQ-RCP-01** [**RESOLVED 2026-04-29 via design-review B1**]: `#6 scene_state_changed` 信号扩展为 `(from, to, ctx: Dictionary)`,ctx 含 `is_weekly` / `is_weekend` / `is_last_day_of_month` / `current_day` / `current_weekday` 五字段(per Rule 1 ctx 契约)。**轮询查询 `#6` 公开属性的方案被否决**(理由:破坏 `#6` 单点信号源;ctx payload 支持后续 sub-mode 上下文扩展,扩展性优于属性查询)。`#6` GDD 下次 revision 同步实施(propagation flag #6 守门)。

**OQ-RCP-02**: 非月末周 KPI 预测区间展示准确性。`#7 monthly_effort_summary` 是月末 push 的,非月末周只能从 `effort_*_incremented` 实时累计估算。估算是否足够让玩家感受"本周进度"?或应直接展示"待月末结算"空白?
_Owner_: game-designer + economy-designer。_Target_: Prototype playtest 验证。

**OQ-RCP-03**: HR 口吻评语词条触发逻辑:纯规则表格(Section G 词条池)还是由 `#9 kpi_prediction_hint` 信号顺带触发?`kpi_prediction_hint` 月末前 2 天才 emit,非月末周无法驱动周报评语。
_Owner_: systems-designer。_Target_: `#9` GDD 确认 `kpi_prediction_hint` 覆盖范围后 `#15 Rule 3` 最终化。

**OQ-RCP-04** [**RESOLVED 2026-04-29 via design-review B3**]: Weekly Recap skip 月末倒数 2 周(M3+ W3/W4)守门最小展示 1500ms(per Rule 7 拓展 + `#2 Input Rule 6` `min_display_ms` 参数);M1/M2 全月 + M3+ W1/W2 不守门(P5 主导)。1500ms 与 `#9 kpi_prediction_hint` 月末 D-2/D-1 emit 锚耦合,确保玩家在 KPI 审判前的 W3/W4 + D-2/D-1 双窗口至少一次见 effort 累积 + NPC 预言。Phase 4 playtest 仅验证 1500ms 是否需调至 1200/2000ms(feel 类微调),不再讨论是否守门。

**OQ-RCP-05**: `RECAP_HR_COMMENT_POOL_SIZE = 30` MVP 词条池是否与 `#9 KPI Review` HR 评语词条池共享 key 域?共享可降低 writer 内容工作量,但减少两屏的分层感;独立维护工作量翻倍。
_Owner_: narrative-director + writer。_Target_: Content plan 阶段确认。

---

## Section H: Acceptance Criteria

23 AC / 5 categories(2 ADR-跟进 + 12 FUNC + 3 PERF + 4 ROBUST + 1 COMPAT + 1 TONE)。

### ADR-0001 跟进追加(B-DEP-2 守门)— 2026-04-28

**AC-FAREWELL-01**(`#10 Rule 23` FAREWELL_EVENT_IDS numeric_only 守门契约): **GIVEN** Weekly Recap 渲染中,debug 钩子扫描事件列表段全部 RichTextLabel 节点, **WHEN** 周报内含 farewell event(`event_id ∈ EventScriptEngine.FAREWELL_EVENT_IDS`), **THEN** 该 event 行**仅一行 `EVENT.[event_id].TITLE_NUMERIC` localization key**(无情感词 / 无叹号 / 无"再见" / 无"谢谢");`tools/farewell_lint.gd` PR 阶段验证 `RECAP.WEEKLY.*.FAREWELL.*` keys 全匹配 `*.TITLE_NUMERIC` pattern → 不一致 BLOCK PR;`subject_inversion_lint.py --domain RECAP` 进一步守门(ADR-0010 master 8 域 list 中 RECAP 包含 farewell numeric_only)。**Tier**: MVP。

### `narrative_density_changed` 订阅契约(ADR-0001 + ADR-0004 + ADR-0012,B-DEP-1 守门)

**AC-DENSITY-01**: **GIVEN** Daily Recap 屏渲染中,**WHEN** `narrative_density_changed(tier)` 信号到达, **THEN** EVENT_ACTIVE 态(若适用)当前事件用旧密度完成,新密度从下次 `event_started` / `daily_recap_started` 起生效(per `#14` `_select_*_by_density()` fallback 链 + `#10 Rule 25` 延后语义);周报 summary 三档 fallback 链 brief → standard → verbose(standard 必填)。**Tier**: MVP。

### AC-FUNC: 功能正确性(12 条)

**AC-FUNC-01** — Daily Recap 触发时序
Given: `scene_state_changed(AFTER_WORK → DAILY_RECAP)` emit。
When: `#15` 收到信号。
Then: ≤ 1 帧(16.6 ms)内完成渲染准备,日报屏内容可见(AP + 精力 + 至少 1 行文本)。**Tier**: MVP。

**AC-FUNC-02** — Weekly Recap 触发(周五升级)
Given: `is_weekly == true`(周五)+ `scene_state_changed(→DAILY_RECAP)`。
When: `#15` 收到信号。
Then: 展示周报视图(effort 三行 + 事件列表 + KPI 区块),非日报视图;单屏内不共存日报和周报内容。**Tier**: MVP。

**AC-FUNC-03** — 事件列表上限 8 条截断
Given: 当日或当周 `event_completed` history ≥ 9 条。
When: Recap 渲染。
Then: 展示 top 8 条(按 D1 公式);剩余条目不展示;不展示"还有 N 条"提示;不崩溃。**Tier**: MVP。

**AC-FUNC-04** — effort 三维度三行展示数字准确
Given: 周五 Weekly Recap 触发,`effort_*_incremented` 本周累计非零。
When: 展示 Weekly Recap。
Then: 三行数字与 `#7` 信号累计一致(加班次数 / Hero 卡张数 / 超预期次数);HR 口吻标注正确(`_BUREAUCRATIC` 后缀 key)。**Tier**: MVP。

**AC-FUNC-05** — KPI 区块非月末周展示"待月末结算"
Given: 非月末周 Weekly Recap。
When: 展示 KPI 区块。
Then: 显示"下月参考区间: _(待月末结算)"(`RECAP.KPI.PENDING_SETTLEMENT` key);不展示估算百分比;不崩溃。**Tier**: MVP。

**AC-FUNC-06** — 月末周五 Recap 正确退出转 `#16`
Given: 周五 + `is_last_day_of_month == true`。
When: Weekly Recap 展示结束(skip 或超时)。
Then: `#6` dispatch `KPI_REVIEW`;`#15` 退出(skippable 注销);`#16` 正确接管。`#15` 不展示月末结算内容。**Tier**: MVP。

**AC-FUNC-07** — 周末两天精简 Daily Recap
Given: `is_weekend == true`(day 6 / 7)+ `scene_state_changed(→DAILY_RECAP)`。
When: `#15` 展示。
Then: 显示 Energy 恢复记录("精力 +30")+ 空事件列表("无已完成事件记录");`is_weekly == false`;不展示 KPI 周摘要。**Tier**: MVP。

**AC-FUNC-08** — 空事件日报(M1 D1 首日)
Given: `completed_events` 为空。
When: Daily Recap 渲染。
Then: 展示"无已完成事件记录"(`RECAP.DAILY.NO_EVENTS_BUREAUCRATIC`);AP + 精力字段正常展示;不崩溃。**Tier**: MVP。

**AC-FUNC-09** — [RISK GUARD] R-RCP-1 进度条禁用验证
Given: `daily-recap-screen.tscn` / `weekly-recap-screen.tscn` 场景树。
When: GUT 场景树节点类型扫描(CI 自动化)。
Then: 场景树中不存在 `ProgressBar` / `TextureProgressBar` 类型节点;不存在包含"%" 字符的 Label 文本常量。**Tier**: MVP(CI blocking)。

**AC-FUNC-10** — Localization key 域正确(无硬编码字符串)
Given: `#15` 所有 Label text 赋值代码。
When: 静态分析扫描。
Then: 所有面向玩家的字符串通过 `tr(key)` 调用,无硬编码中文字面量。**Tier**: MVP。

**AC-FUNC-11** — HR 口吻评语词条 lint 通过
Given: `RECAP.*` 全部 Localization key。
When: `subject_inversion_lint.py --domain RECAP` CI 运行。
Then: 0 个 RECAP key 包含禁止词族(励志 / 恭喜 / 完成度 / 玩家主语);0 个 key 缺 `_BUREAUCRATIC` 后缀(当词条含 HR 口吻标注时)。**Tier**: MVP(CI blocking)。

**AC-FUNC-12** — effort 三维度无百分比 / 无进度语义
Given: Weekly Recap effort 三行展示。
When: 玩家查看周报。
Then: 三行展示绝对整数;无百分比文本;无"完成 X%"类文案;无颜色编码红/绿评价;无 ProgressBar 节点。**Tier**: MVP。

### AC-PERF: 性能契约(3 条)

**AC-PERF-01** — 帧预算 ≤ 2 ms / 屏(主线程)
Given: 标准 PC(Intel i5 + 集显),60 fps target。
When: `scene_state_changed(→DAILY_RECAP)` handler 执行。
Then: Signal handler 内执行时间 ≤ 0.5 ms(Time.get_ticks_usec 测量);总 recap 屏绘制 ≤ 2 ms / 帧(3 帧均值)。**Tier**: MVP。

**AC-PERF-02** — dispatch 时序 ≤ 1 帧内容可见
Given: `scene_state_changed(→DAILY_RECAP)` emit。
When: 下一帧渲染。
Then: Recap 顶层 Container 可见 + 至少 1 行文本渲染完成,总延迟 ≤ 16.6 ms。**Tier**: MVP。

**AC-PERF-03** — 事件列表 8 条渲染完成 ≤ 3 帧
Given: 8 条事件 + 分帧 instantiate 策略。
When: Daily / Weekly Recap 展示。
Then: 所有 8 条 LabelLine 节点完成 instantiate + `tr()` + layout ≤ 50 ms(3 帧内)。**Tier**: MVP。

### AC-ROBUST: 健壮性契约(4 条)

**AC-ROBUST-01** — [RISK GUARD] R-RCP-2 skip token 不泄漏
Given: `DAILY_RECAP` 触发后任意退出路径(skip / 超时 / `GAMEOVER` 强制中断)。
When: 退出路径执行。
Then: `InputHandler.has_skippable(&"daily_recap_skip") == false`(集成测试 force-transition 至 `MORNING_BRIEFING` 断言)。**Tier**: MVP(blocking)。

**AC-ROBUST-02** — skip 与 timeout 同帧 idempotent
Given: 玩家在第 89999 ms 按 skip。
When: `recap_skipped` + `recap_timeout` 同帧触发。
Then: `#6` 状态机只执行一次 `DAILY_RECAP → MORNING_BRIEFING` 转移;第二个信号被 guard 丢弃;不崩溃;不重复 emit。**Tier**: MVP。

**AC-ROBUST-03** — 上游信号缺失时 Recap 降级展示
Given: `kpi_threshold_changed` / `monthly_effort_summary` / `event_completed` 任意一路信号未到达(上游 bug 或时序 race)。
When: Daily / Weekly Recap 渲染。
Then: 缺失字段展示"数据加载中"fallback(`RECAP.DATA.LOADING_FALLBACK`);不崩溃;不展示空指针错误;其他字段正常展示。**Tier**: MVP。

**AC-ROBUST-04** — 月末倒数 2 周 Weekly Recap 最小展示锁(B3 守门)
Given: `ctx.is_weekly == true` AND `_is_late_month_week(ctx) == true`(M3+ W3/W4)+ Weekly Recap 渲染中。
When: 玩家在 t < 1500 ms 时按 skip。
Then: `recap_skipped` 信号被 `#2 InputHandler` `min_display_ms` 守门挂起,直至 t == 1500 ms 才 emit;玩家在挂起期间继续可见 effort 三维度数字。M1/M2 全月 + M3+ W1/W2 不守门(skip 即时生效)。**Tier**: MVP(P2 服务守门)。集成测试断言:模拟 W3 周五 + skip @ 500ms,实际 emit `recap_skipped` 时间 ≥ 1500ms ± 1 帧。

### AC-COMPAT: 兼容性契约(1 条)

**AC-COMPAT-01** — Gamepad D-Pad focus + skip 可用
Given: 玩家使用 Gamepad(D-Pad + A/B/X/Y)。
When: Daily / Weekly Recap 展示。
Then: Skip 按钮有明确 focus 态;按 A / B 可触发 skip;D-Pad 导航可到达 skip 按钮;无 hover-only 交互。**Tier**: MVP。

### AC-TONE: 叙事 Tone 守护(1 条)

**AC-TONE-01** — Playtest tone 感知验证
Given: Weekly Recap 展示"47 张卡 / 3 Hero / 2 次 Lisa 互动 / 加班 1 次"数据。
When: M1 W1 playtest(玩家首次看到周报)。
Then: 问卷结果:"这张周报更像 HR 系统还是游戏结算面板?"回答"HR 系统"比例 ≥ 70%;"你会选择 skip 这张周报吗?"回答"会"比例 < 30%(说明玩家愿意读数据)。**Tier**: Beta(playtest 验证)。
