# Daily / Weekly Recap UI — Review Log

## Review — 2026-04-29 — Verdict: NEEDS REVISION → batch-revised in same session

**Mode**: lean(无 specialist agents,单 session 分析 + batch revise)
**Scope signal**: M(Presentation Layer,跨 11 上游 GDD 引用,1 公式,3 ADR 依赖,纯渲染层)
**Specialists**: 无(lean 自合成 senior verdict)
**Blocking items**: 3 → resolved | **Recommended**: 6 → resolved | **Nice-to-Have**: 4 → resolved
**Prior verdict resolved**: First review

### Summary

Daily / Weekly Recap UI 是高质量 GDD,P2/P4/P5 三 pillar 服务路径清晰,主语翻转 lint 扩展 + HR 口吻锁 + 数字克制原则 + Anti-P2 红线 + farewell event numeric_only 守门 + narrative_density 三档 fallback 链全套机制到位,与 11 条上下游 GDD 契约链条基本贯通。**3 真 BLOCKING 集中于 cross-GDD 契约一致性问题**(非系统内核重设计),已在同一轮 batch revise 内全清。

### Blocking Items Resolved

**B1 — `#6 scene_state_changed` 信号契约真缺口** ✓
- **问题**: Rule 1 + Rule 2 + Section F 假设 `is_weekly` / `is_weekend` 参数已存在,但 `#6 Rule 3` 当前签名仅 `(from, to)` 两参数。OQ-RCP-01 已 flag 但 Rule 段以"已确认"语气写,主体 Rule 与 OQ 矛盾。
- **仲裁**: 选 (a) `#6` 扩展信号 `scene_state_changed(from, to, ctx: Dictionary)`,ctx 含 `is_weekly` / `is_weekend` / `is_last_day_of_month` / `current_day` / `current_weekday` 五字段。否决 (b) 轮询查询(破坏 `#6` 单点信号源)+ (c) 单独 emit `recap_context_emitted` 信号(增订阅次数)。
- **落地**: Rule 1 加 ctx payload 契约 GDScript 块;Rule 2 改为读 ctx.is_weekly;Section F 加 propagation flag #6(`#6 Rule 3` 信号扩展 ctx payload 同步要求,在 `#6` GDD revision 前 `#15` 实施挂起);OQ-RCP-01 标 RESOLVED。

**B2 — `#9 Rule 10 breakdown` schema 误引** ✓
- **问题**: Section A L18/24 + Rule 3 多处声明 "effort 三维度 breakdown 继承 `#9 Rule 10`",但 `#9 Rule 10 breakdown` 实际 schema 是月末 KPI 涨幅三因子拆解(`tenure_contrib / capacity_now / overage_contrib / delta_pct`),**不是** effort 维度三行(加班/Hero/超预期)。effort 三维度真实 source 是 `#7 effort_*_incremented` 周累计 + `#7 monthly_effort_summary` 月末 push。两 schema 不同 namespace。
- **落地**: Section A 重写为正确 schema source(`#7 effort_*_incremented` + `#7 monthly_effort_summary`);Rule 3 改 source 锁 + 加 schema 边界注释("`#9 Rule 10 breakdown` 由 `#16` own,`#15` 不消费");Section F `#9` 上游表行重写(`#15` 不渲染 `#9 breakdown` 三因子);I-3 改为 `#15` 仅订阅 `kpi_review_started` + `kpi_prediction_hint`(可选);E-4.3 边缘 case 措辞与 schema 一致。

**B3 — P2 主 vs P5 守 设计 tension(Weekly Recap skip 与 effort 三维度自我解释机制冲突)** ✓
- **问题**: Section A 声明 P2 主"机制自我解释" + P5 守"随时可 skip"。OQ-RCP-04 已识别 tension 但留待 Phase 4 playtest。真问题:Weekly Recap effort 三行是月末 KPI 审判前唯一让玩家看见自我累积的机制,Rule 7 不守门 → 玩家 4 周连续 skip 后,P2 主在 75% 游戏时间内不被服务。
- **仲裁**: 选 (b) **月末倒数 2 周(M3+ W3/W4)守门最小展示 1500ms**,M1/M2 全月 + M3+ W1/W2 不守门(渐进引入 self-explain)。1500ms 与 `#6 GAMEOVER` 1500ms 守门同构,与 `#9 kpi_prediction_hint` 月末倒数 2 天预言锚节奏耦合(双窗口确保玩家 KPI 审判前至少一次见 effort 累积 + NPC 预言)。
- **落地**: Rule 7 加月末倒数 2 周守门表 + GDScript `min_display_ms` 参数实施 + `_is_late_month_week(ctx)` 判定函数;补 AC-ROBUST-04 守 B3(MVP P2 服务守门);OQ-RCP-04 标 RESOLVED;Section F 加 propagation flag #7(`#2 Input Rule 6` `register_skippable` 拓展 `min_display_ms` 参数,在 `#2` GDD revision 前月末守门挂起,即时 skip 不受影响);AC-ROBUST 类 count 3 → 4。

### Recommended Items Resolved

- **R1**: Section H count 顶部声明 "20 AC / 5 categories" → 改为 "23 AC / 5 categories"(2 ADR-跟进 + 12 FUNC + 3 PERF + 4 ROBUST + 1 COMPAT + 1 TONE)
- **R2**: Section C I-9 ADR 引用 "ADR-0001 + ADR-0012" → 改为 "ADR-0001 + ADR-0004 + ADR-0012"(与 AC-DENSITY-01 一致)
- **R3**: Rule 12 Scope Tier 表 VS 月度子摘要落点由 Daily Recap 移至 Weekly Recap(对齐 Rule 1 "Daily Recap 不展示 KPI 进度"边界)
- **R4**: Section F `#7 Rule 14` 双向 cross-check 补 propagation flag #2 — `#7` 须在下次 GDD review 时 Rule 14 信号订阅表加列 `#15 Recap` 为 `effort_*_incremented` 订阅者(与 `#13 HUD` 并列)
- **R5**: Visual/Audio 字体 hardcode "11 px" — **保留**(art-bible §7.2 的 `AUTO_FIT_FLOOR_PX = 11` 是单一真理源,GDD 引用同时 hardcode 数字 + 引用 const name 是冗余防错,符合 art-bible 反向 lint 协议;不做改动)
- **R6**: Rule 11 主语翻转范例 "今日 AP 已全部消耗" — **保留**(被动陈述符合 P4 反英雄红线方向,`#7 Rule 13` 反英雄锚已对齐;writer review 阶段微调留 Phase 4 UI playtest)

### Nice-to-Have Items Resolved

- **N1**: Section B 副锚标题加非 localizable 脚注(本副锚标题为设计描述,非 RECAP.* key 域文案,Loc 文案遵循 Rule 11 主语翻转)
- **N2**: Rule 6 `_BUREAUCRATIC` 后缀 namespace 区分(本 GDD 用于 RECAP.* Loc 文本 key 域;`#4 Audio` 同名后缀用于 SFX 资源 key 域 — 同源 tone 异 namespace,lint 工具按 namespace 分别扫描)
- **N3**: D1 worked example weight 来源加脚注(`#10 F1 effective_weight`,范围 [0.01, 150])
- **N4**: `RECAP_HR_COMMENT_POOL_SIZE = 30` MVP 词条 5 大类组合覆盖 — **保留 OQ-RCP-05**(narrative-director + writer Content plan 阶段确认是否与 `#16` 共享 key 域,影响词条池大小;Section G 现 5 行示例足以 framework,Phase 4 落地)

### Cross-GDD Propagation Flags Created

- **flag #6**: `#6 Rule 3` 信号签名扩展为 `scene_state_changed(from, to, ctx: Dictionary)` — `#6` GDD 下次 revision 同步实施;在此之前 `#15` 实施挂起
- **flag #7**: `#2 Input Rule 6` `register_skippable(token_id, on_skip, min_display_ms: int = 0)` API 拓展 — `#2` GDD 下次 revision 同步实施;在此之前 `#15` Rule 7 月末守门挂起,即时 skip 路径不受影响
- **flag #2 (R4)**: `#7 Rule 14` 信号订阅表须加列 `#15 Recap` 为 `effort_*_incremented` 订阅者 — `#7` GDD 下次 revision 时同步

### OQ Resolution

- **OQ-RCP-01** RESOLVED via B1(`#6 scene_state_changed` ctx payload)
- **OQ-RCP-04** RESOLVED via B3(月末倒数 2 周 1500ms 守门;Phase 4 playtest 仅微调 1500ms 数值)
- **OQ-RCP-02 / OQ-RCP-03 / OQ-RCP-05** 保留(均待 Phase 4 playtest / Content plan / `#9` GDD review)

### Verdict After Revision

**Designed (revised, pending re-review)** — 3 BLOCKING + 6 RECOMMENDED + 4 NICE-TO-HAVE 全清(R5/R6/N4 标保留理由)。下次 fresh session lean re-review 验证 BLOCKING + 跨 GDD propagation flags 不引入新冲突。

### Recommended Next

- **(优先 1)** fresh session `/design-review design/gdd/daily-weekly-recap-ui.md --depth lean` 第二轮 re-review(等同 save-system 3rd review APPROVED 路径)
- **(优先 2)** `#6 scene-day-flow-controller.md` next revision 实施 propagation flag #6(信号 ctx payload)
- **(优先 3)** `#2 input-handler.md` next revision 实施 propagation flag #7(`min_display_ms` 参数)
- **(优先 4)** `#7 ap-economy-system.md` next revision 实施 propagation flag #2 R4(Rule 14 表加 `#15` 订阅者)
- **(平行)** Approved 后:`/create-stories daily-weekly-recap-ui` Presentation Layer 第 5 epic stories
