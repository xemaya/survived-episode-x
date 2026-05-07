# Save System — Review Log

> Revision history for `design/gdd/save-system.md`. Each entry summarises one `/design-review` invocation.

---

## Review — 2026-04-23 — Verdict: NEEDS REVISION

Scope signal: **L** (cross-platform engine-correctness risk + gates Pillar 5; revision bounded to 8 themes, architecture settled)
Specialists: game-designer, systems-designer, qa-lead, godot-specialist, performance-analyst, narrative-director, creative-director (synthesis)
Blocking items: 8 (collapsed from 23 raw findings) | Recommended: 10 | Nice-to-have: 7
Prior verdict resolved: First review

### Summary
Architecture is sound (state machine, atomic-write intent, archive immutability, schema versioning, layered crash recovery). Blockers concentrate in three areas: **engine API correctness** (`NOTIFICATION_APPLICATION_PAUSED` is Android/iOS only and silently no-ops on Steam desktop; `@export const` invalid GDScript; `DirAccess.rename()` Windows atomicity unverified), **main-thread perf** (JSON.stringify 8–18 ms median contradicts AC-PERF-02's 16.6 ms frame budget; 20 KB state assumption breaks by VS), and **pillar leakage** (Rule 11 corruption export + OQ-06 Steam Cloud cross-PC create ironman escape hatches; 离职证明 ceremony pacing + cross-run unlocks risk Stardew/roguelike tone drift). Plus AC hygiene: 4 Core Rules (5/14/18/19) have zero AC; tier math arithmetic wrong (27 vs 33); 7 AC-INTERFACE-* unverifiable until downstream GDDs exist. Creative-director recommends fixing in a fresh session (lean mode + creative decisions benefit from a night's sleep) and re-running `/design-review --depth lean` since blockers are now scoped.

### Blocking themes (collapsed)
1. `NOTIFICATION_APPLICATION_PAUSED` desktop no-op — switch to `NOTIFICATION_WM_WINDOW_FOCUS_OUT` or `Window.close_requested` [godot]
2. Atomic-write spec underspecified (`DirAccess.rename()` Win atomicity, `@export const` invalid, missing `close()` step, Rule 9c "原子复制" unspecified) [godot, systems]
3. JSON.stringify on main thread vs frame budget contradiction; 20 KB state assumption invalid for VS; AV-retry worst-case violates Pillar 5 silently [perf]
4. WorkerThreadPool no FIFO + ERROR/merge-queue ambiguity → silent overwrite of newer state [godot, systems]
5. Two ironman escape hatches: corruption export + Steam Cloud cross-PC rollback [game-designer]
6. 离职证明 ceremony pacing + cross-run unlocks need explicit anti-Stardew/anti-roguelike guardrails in this GDD [narrative]
7. Rules 5/14/18/19 have zero AC; add minimal coverage [qa-lead]
8. AC tier math wrong (27 ≠ 33); AC-INTERFACE-* must defer until downstream GDDs [qa-lead]

---

## Revision — 2026-04-23 — Status: Awaiting Re-review

Scope delivered: **L** (8 blocker themes addressed, architecture unchanged)
Decisions made by user (all 6 choices): Steam Cloud `current_run.save` excluded • corruption export 保留原方案 • 离职证明 timing 锁在本 GDD • 跨局解锁仅 content-reveal • **JSON.stringify 移出主线程** (overrode the reviewer's simpler "cap played_cards_log" recommendation) • archive 200 cap = Block new Run + manual 清档

### Changes applied

| Blocker theme | Fix location | Summary |
|---|---|---|
| 1 `APPLICATION_PAUSED` no-op | Rule 3d / 19 / 事件表 / Engine Constraints | Removed; split into `WM_CLOSE_REQUEST` (sync block) + `WM_WINDOW_FOCUS_OUT` (500 ms debounced async) |
| 2 Atomic-write underspecified | Rule 5 + Rule 9c + Tuning Knobs header | Rule 5 展开 5 步显式 (open→store+check→flush→close→rename) + Windows `MoveFileExW` note; Rule 9c 同样 5 步 + `set_read_only_attribute`; Tuning Knobs header 去 `@export const` 改 `@export var` / `const` |
| 3 JSON.stringify main-thread | Rule 7 + Engine Constraints + AC-PERF-01/02 | Main thread state tree aggregate only (1-3 ms); `JSON.stringify` + I/O on WorkerThreadPool (8-28 ms); OQ-03 note Pillar 5 AV-retry suspension |
| 4 WorkerThreadPool FIFO | Rule 7 / 13 | 单调递增 `snapshot_id`; worker 拒绝旧序号；记 `stale_request_dropped` 计数器 |
| 5 Steam Cloud escape hatch | **新 Rule 20** + Engine Constraints + AC-COMPAT-04/05 + OQ-06 resolved | `current_run.save` 不进 cloud filter；跨 PC 时档案柜可见、活动 Run 本地；玩家体感"换电脑上一局没了但员工档案都在" |
| 6 离职证明 / 跨局解锁 tone | **新 Rule 21 + 22** + 新 Tuning Knobs subsection + AC-FUNC-12/13 | Rule 21 硬锁 `final_transition_duration_ms ≤ 1500` + `easing = NONE`（跨 GDD 约束 #16）；Rule 22 `meta.unlocks` 白名单 5 类 content-only key，禁机械数值（跨 GDD 约束 #8/#10/#11/#12） |
| 7 Rules 5/14/18/19 AC missing | AC-FUNC-08/09/10/11 | 4 条新 AC，全 MVP 必测，均 fixture/profiler/DOM 可自动化 |
| 8 AC tier math + INTERFACE defer | AC intro + AC-INTERFACE 小节头 + 各 AC-INTERFACE-01~07 前缀 + Tier 分级 | 36→43 总 AC；MVP 必测 26→34；AC-INTERFACE-01~07 全部标 `[Deferred until X]` + 激活回写协议 |
| — (附) OQ-01 archive 200 cap | **新 Rule 23** + AC-FUNC-14 + OQ-01 resolved | Block new Run + 逐条删除（禁批量）；MVP 不触达但 launch 落地保长线 Pillar 3 |
| — (附) author stamp | GDD header | Revision 日期 + 参与 agent 列表 |

### Artifacts updated
- `design/gdd/save-system.md` — 24 targeted edits across 8 sections (header, Rule 3/5/7/9/13/19 + 新 20-23, States table, Engine Constraints, Tuning Knobs, AC-FUNC/PERF/COMPAT/INTERFACE/Tier, OQ-01/06)
- `design/gdd/systems-index.md` — Save 状态 `NEEDS REVISION` → `Revised (awaiting re-review)`；Decisions Log 加 2026-04-23 条目
- `design/registry/entities.yaml` — 新 constant `final_transition_duration_ms=1500`（Rule 21 跨 GDD 锁定值）；`archive_hard_cap_count` notes 更新（OQ-01 resolved）
- `production/session-state/active.md` — progress 与 pending decisions 清零

### Next action
跑 `/design-review design/gdd/save-system.md --depth lean`（blockers 已 scoped，lean 足够）；绿灯后 systems-index 状态改 `Designed` 并解锁 Foundation #2-5 并行 design。

---

## Review — 2026-04-23 (2nd pass, re-review) — Verdict: NEEDS REVISION (minor)

Scope signal: **L** (unchanged — 跨平台引擎正确性 + 3 Pillar 守护 + 14 下游系统 hard 依赖 + 6-state 状态机 + 23 Core Rules / 43 AC)
Specialists: None (lean mode, 单 session 分析)
Blocking items: **1** | Recommended: 5 | Nice-to-have: 3
Prior verdict resolved: **Yes — 全部 8 首轮 blocker themes 系统性闭环**

### Summary
首轮 8 blocker themes 全部系统性闭环(4 new Core Rules + 7 new AC-FUNC + entities.yaml 登记 + Engine Constraints 改写 + Tuning Knobs 更新)。架构层面 sound:state machine 覆盖所有转移,atomic-write 具体到 5 步 API + Windows MoveFileEx note,off-main-thread JSON + `snapshot_id` FIFO 解开 worker 数据竞争;Pillar 守护层面 Rule 20/21/22 把 ironman/tone/无永久成长锁在 Save 层。新发现问题**仅 1 blocker**:`settings.cfg` vs `meta.save` 设置归属内部矛盾(Rule 1/14/AC-FUNC-09 声明设置在 meta.save 内,但 Rule 20 / Engine Constraints / AC-COMPAT-04 / Rule 20 quota math 把 `settings.cfg` 列为独立第 4 个文件)—— 3 处 edit 即可闭环,不触及架构。用户选择**下个 session 修 blocker**后再 re-review。

### Blocking items (new, 1 item)
1. **`settings.cfg` vs `meta.save` 设置归属矛盾** — Rule 1 文件清单只列 current_run/meta/archive,meta.save 声明含"设置"字段;Rule 14 + AC-FUNC-09 + Interactions 都假定设置在 meta.save 内;但 Rule 20 Steam Cloud filter + Engine Constraints + AC-COMPAT-04 + Rule 20 quota math 把 `settings.cfg` 作为第 4 个独立文件列出。两处叙述互斥。**推荐修法(a)**:删除 3 处 `settings.cfg` 引用(Rule 20 filter 列表 + Engine Constraints Steam Cloud filter 段 + AC-COMPAT-04 GIVEN/THEN + Rule 20 最后一句 quota math),统一为"设置在 meta.save 内"。**或修法(b)**:在 Rule 1 补登 `settings.cfg` 为第 4 个文件 + 删除 Rule 1 / 14 / AC-FUNC-09 对设置落 meta 的声明。修法(a)更简洁,避免双文件一致性维护成本。

### Recommended revisions (5 items, 非 blocker)
1. **Rule 9 "任一步失败则保留 current_run.save" 对 Step 5 字面矛盾** — Step 4 已删 current_run.save,Step 5 失败走 Rule 15+18 反向幂等补齐(Edge 10.2 确认)。Rule 9 结尾应拆分"Steps 1-4 失败 → 保留 current_run.save;Step 5 失败 → Rule 15+18 补齐,不回滚 archive"。
2. **Rule 5e `MoveFileExW` flag 组合对 Godot 4.6 未实证** — LLM knowledge cutoff ~4.3;`MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH` 的具体 flag 组合在 4.4/4.5/4.6 源码中是否存在需对照 `docs/engine-reference/godot/` 或交给 godot-gdextension-specialist 确认。ADR-0001 阶段实证;若未实际包含 `WRITE_THROUGH`,"同卷原子"承诺需降级。
3. **AC-PERF-02 "任何一帧 > 16.6 ms" 过于绝对** — 无 Save 参与的场景切换/资源加载抖动也会误报。建议限定为"Save 驱动的主线程工作(snapshot 聚合阶段)p99 < 3 ms + 归因于 Save 调用栈的帧无一超 16.6 ms",或用 profiler flame graph 过滤。
4. **AC-PERF-01 只测 20 KB state 体积** — 无 AC 覆盖 `state_schema_review_threshold=256 KB` 到 `state_bloat_hard_limit=1 MB` 边界的性能行为(VS 阶段会触达)。建议新增 `AC-PERF-06`:state=256 KB 时 worker 端到端 p99 < 80 ms,或在 AC-PERF-01 Tier 分级里把 VS 外扩标为 Polish 回归测试。
5. **Edge Case 2.1 vs 2.2 `.tmp` 处理不一致** — 2.1 "完整则提示采用/丢弃" vs 2.2 "时间戳较新者自动采用"。冷启动难以区分"写入中途崩"vs"rename 前崩"(两者都是旧文件+.tmp 存在)。建议合并为统一策略,或说明如何判别两场景。

### Nice-to-have (3 items)
1. `final_transition_easing = NONE` 枚举单值 knob 实为常量伪装,降级为 `const` 或加占位注释。
2. Rule 21 对 #16 GDD 的硬约束未来应在 `design/gdd/kpi-review-game-over-ui.md` 的 Dependencies 段做反向引用,`/consistency-check` 激活时补。
3. OQ-03 建议在 active.md 开放问题清单标注"Polish gate blocker (Pillar 5 AV-retry 路径)",让 producer 调度不 miss。

### Decision
用户选 **[C] 下个 session 再修 blocker** — 本 session 仅记录 verdict,不做 edit。本 session 不解锁 Foundation #2-5。

### Next action
下个 fresh session 跑:
1. 阅读本 log + `design/gdd/save-system.md`
2. 应用 blocker #1 修法(a)(3 处删除 `settings.cfg` 引用)
3. 重跑 `/design-review design/gdd/save-system.md --depth lean` → 预期 Approved → systems-index 标 `Designed` → 解锁 Foundation #2-5 并行 design

5 个 Recommended 可在 blocker 修复同一批次处理,或延后至 ADR-0001 / 下游 GDD 撰写阶段统一解决(均不影响实现开工)。

---

## Revision (minor) — 2026-04-23 — Status: Awaiting Re-review → (re-review 同 session 完成)

Scope delivered: **XS** (5 处文本 edit,架构未动)
Decisions made by user: **Option A 扩展版** — 修法(a)(删除 `settings.cfg` 引用,统一归 `meta.save` 内)从 active.md 原列的 3 处扩展至 **5 处**(加入 外部依赖 Steam Runtime 行 323 + AC-COMPAT-05),OQ-06 RESOLVED 历史决策快照保留原文以维持决策审计。理由:仅修 3 处会留下 AC-COMPAT-05 / 外部依赖 / OQ-06 RESOLVED 三处对同一矛盾的残留叙述,3rd review 会再抓为同类 blocker。

### Changes applied

| Location | Before | After |
|---|---|---|
| Rule 20 filter 列表 (行 87) | `meta.save + archive/*.save + settings.cfg` | `meta.save + archive/*.save`(设置存于 meta.save 内,无独立 settings.cfg 文件) |
| Engine Constraints Steam Cloud filter (行 181) | `+ settings.cfg`;quota `+ settings 可忽略` | `+ archive/*.save`(设置存于 meta.save 内);quota `meta ≈ 20 KB(含设置)` |
| 外部依赖 Steam Runtime (行 323) | `*.save + settings.cfg` | `meta.save + archive/*.save`(见 Rule 20) |
| AC-COMPAT-04 GIVEN/THEN (行 490) | include/THEN 含 `settings.cfg` | 删除;GIVEN 加 "设置存于 meta.save 内,无独立 settings.cfg 文件" |
| AC-COMPAT-05 THEN (行 491) | `+ settings.cfg 存在` | 删除;加 "设置随 meta.save 同步" |

OQ-06 RESOLVED (行 581-587) 历史决策文字保留未动(nice-to-have 项,不影响 review 通过)。

### Artifacts updated
- `design/gdd/save-system.md` — 5 targeted edits across Rule 20 / Engine Constraints / 外部依赖 / AC-COMPAT-04 / AC-COMPAT-05
- `design/gdd/systems-index.md` — Save 状态 `NEEDS REVISION (minor)` → `Designed`;Decisions Log 追加本次条目
- `design/gdd/reviews/save-system-review-log.md` — 追加本 Revision + 3rd lean review 条目(本条及下条)

### Next action
同 session 继续跑 3rd `/design-review --depth lean`(见下)。

---

## Review — 2026-04-23 (3rd pass, re-review) — Verdict: **APPROVED**

Scope signal: **L** (不变 — 跨平台引擎正确性 + 3 Pillar 守护 + 14 下游 Hard 依赖 + 6-state 状态机 + 23 Core Rules / 43 AC)
Specialists: None (lean mode — 单 session 分析)
Blocking items: **0** | Recommended: 5 (延后) | Nice-to-have: 4
Prior verdict resolved: **Yes — 2nd review 的 1 blocker(`settings.cfg` 归属矛盾)闭环**

### Summary
5 处 edit 成功统一"设置归 `meta.save` 内"的口径,Rule 1/14/20/181/323/AC-FUNC-09/AC-COMPAT-04/AC-COMPAT-05/`meta.settings` 接口(行 168) 全链一致。剩余 3 处 `settings.cfg` 字符串均为**自证否定**(2 处 clarifying note + 1 处 OQ-06 RESOLVED 历史快照,用户选择保留以维持决策审计)。2nd review 的 5 Recommended 除 AC-PERF-02 部分缓解外其余不变——用户明确选择"仅修 blocker",剩余延后至 ADR-0001 / QA 计划 / 下游 GDD 的自然节奏。架构层核心判断:Rule 20/21/22/23 四条跨 GDD 锁定规则语义稳定,Pillar 1/3/5 承诺的 Save 层契约基石达成,**可解锁 Foundation #2-5 并行 design**。

### Blocking items
**None.**

### Recommended (5 条,全部延后,不阻塞后续 design order)
1. [systems] Rule 9 末句"任一步失败则保留 current_run.save" 对 Step 5 语义字面矛盾 — ADR-0001 阶段拆分处理。
2. [godot] Rule 5e `MoveFileExW` flag 组合对 Godot 4.6 源码未实证 — ADR-0001 交 godot-gdextension-specialist 核实;若 `WRITE_THROUGH` 未落实需降级"同卷原子"保证。
3. [qa] AC-PERF-02 "主线程帧曲线无任何一帧 > 16.6 ms" 字面仍偏绝对(Main profiler 过滤已加,改善但未彻底)— Polish 阶段 profiler 实测时用 flame graph 归因 Save 调用栈后收紧定义。
4. [qa] 缺 state=256 KB 到 1 MB 边界的性能 AC(VS 触达)— VS tier 补 `AC-PERF-06` 或外扩 AC-PERF-01 为 Polish 回归。
5. [systems] Edge Case 2.1/2.2 `.tmp` 冷启动判别规则欠明("写入中途崩"vs"rename 前崩"表象相同)— ADR-0001 加判别伪代码或合并统一策略。

### Nice-to-have (4 条)
1. OQ-06 RESOLVED 决议快照(行 583)仍含旧表述 `+ settings.cfg`;可加一行"**注(修订后)**: 设置实际存于 meta.save 内"做历史-现行对齐(用户本次有意保留,此条为未来可选清理)。
2. `final_transition_easing = NONE` 枚举单值 knob 实为常量伪装 — 降级 `const` 或标占位注释。
3. Rule 21 对 #16 GDD 的硬约束应在 `design/gdd/kpi-review-game-over-ui.md` Dependencies 段反向引用(`/consistency-check` 激活时补)。
4. OQ-03 (HDD + AV p99) 在 active.md 开放问题清单标 "Polish gate blocker (Pillar 5 AV-retry 路径)",便于 producer 调度。

### Dependency Graph
- ✗ design/gdd/scene-day-flow.md — NOT FOUND (expected, 未设计)
- ✗ design/gdd/ap-economy.md — NOT FOUND (expected)
- ✗ design/gdd/npc-relationship.md — NOT FOUND (expected)
- ✗ design/gdd/kpi-reverse-threshold.md — NOT FOUND (expected)
- ✗ design/gdd/event-script-engine.md — NOT FOUND (expected)
- ✗ design/gdd/action-card.md — NOT FOUND (expected)
- ✗ design/gdd/run-meta.md — NOT FOUND (expected)
- ✗ design/gdd/kpi-review-game-over-ui.md — NOT FOUND (expected; Rule 21 hard-lock 目标,设计时必须反向引用 Save)
- ✗ design/gdd/main-menu-ui.md — NOT FOUND (expected)
- ✓ design/gdd/game-concept.md / systems-index.md — exist

Foundation 层 Save 无上游依赖,下游全未设计,符合 design order 预期。

### Decision
**APPROVED** — 解锁 Foundation #2-5 (Input Handler / Localization Hooks / Audio Manager / Lighting Controller,均 S size) 并行 design。5 Recommended 延后 ADR-0001 / QA 计划 / VS 阶段统一处理。

### Next action
开新 session 并行跑 Foundation #2-5 的 `/design-system`,或按 design order 单线推进(S size × 4 ≈ 1-2 session)。Save System 完成后下一高风险节点是 Order #9 KPI & Reverse Threshold System (L size, 数学主笔)。
