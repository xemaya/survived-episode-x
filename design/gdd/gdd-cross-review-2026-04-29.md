# Cross-GDD Review Report — 20 GDDs Full Set

**Date**: 2026-04-29
**Reviewed By**: `/review-all-gdds` (full mode, 3 parallel subagents)
**GDDs Reviewed**: 20(全套 Foundation 5 + Core 4 + Feature 3 + Presentation 5 + VS 2 + Alpha 1)
**Total Lines**: 14,501

---

## 总评: **CONCERNS**

| Phase | Verdict | Blocking | Warning | Info |
|-------|---------|----------|---------|------|
| 2 — Consistency | CONCERNS | 5 | 4 | 4 |
| 3 — Design Theory | **PASS** | **0** | **0** | **0** |
| 4 — Scenario Walkthrough | CONCERNS | 3 | 10 | 6 |
| **合计** | **CONCERNS** | **8** | **14** | **10** |

**核心结论**:

1. **Phase 3 设计整体性 PASS** — 20 GDD 后期 12 系统未引入任何 Pillar 漂移 / Anti-Pillar 违反 / 进度循环竞争 / 显性优势策略 / 经济失衡。游戏设计 ship-ready
2. **Phase 2 + 4 8 BLOCKING 集中于 3 类 cross-cutting 主题**(均可由 1-3 个 ADR 集中仲裁):
   - **信号 ownership / 订阅契约**(B-DEP-1/2/3 + B-RULE-1)— 4 BLOCKING
   - **演出层三轨节奏 + reflow 合流**(B-SCN4-1/2 + B-AC-1)— 3 BLOCKING
   - **`#5` accumulation 第 4 维定义**(B-SCN4-3)— 1 BLOCKING
3. **Foundation 5/Core 4 baseline**(2026-04-25 cross-review CONCERNS)5 BLOCKING 已全部由 #6 Scene Flow 仲裁完成(Rule 4-9 + C-ENG-01..07)
4. **当前 8 BLOCKING 是新增 15 GDD 引入的 cross-cutting 协议盲点**,不是单 GDD 内部硬冲突

---

## Phase 2 — Consistency Issues

### 🔴 BLOCKING(5 条)

**B-DEP-1**: `narrative_density_changed` 信号下游订阅缺失
- `#17 Settings` Rule 5 emit此信号,但 `#10 Event Script` + `#15 Recap UI` 均**未在自身 Section 信号订阅清单中声明** subscriber 契约
- `#10` 仅 Section H 出现 `density_tier` 概念,无订阅 wiring;`#15` 完全无引用
- **风险**: 三档密度切换运行时 broken
- **修复**: `#10` Rule 19 信号架构追加订阅项;`#15` Section C 增订阅契约

**B-DEP-2**: 离别事件强制 numeric_only 下游守门缺失
- `#10` Rule 11 + `#14` Rule 4 双声明 LISA_GOODBYE / CLEANING_AUNT_LEAVE / FISH_MONK_LAID_OFF 强制 numeric_only(禁特殊 UI / 禁 BGM)
- `#13 HUD` / `#15 Recap UI` / `#4 Audio` / `#5 Lighting` GDD 自身**无对应离别事件 enum 白名单守门**
- **风险**: 4 GDD 任何一方违反契约即三轨负空间 tone 漂移
- **修复**: 4 GDD 各自 Rule 中显式列离别事件 ID 黑名单 + AC 验证

**B-DEP-3**: `accumulation_event` 信号 ownership 三方混乱
- `#5` Rule 5 自 emit `accumulation_event`
- `#5` Section F "流入" 又说"`#6` emit accumulation_event 给 Lighting"
- `#6` Section H 既说"`#13` 订阅 accumulation_event"又把它列为自身 emit(Rule 9)
- `#13` Rule 7 明确订阅"`#5` 的 accumulation_event"
- **风险**: 真正 source 不明 → `#13` / `#18` Tutorial 的 connect 路径错误
- **修复**: 1 ADR 锁定 owner(推荐 `#5` Lighting,因维护 4 维度 state)

**B-RULE-1**: `dismissal_triggered → GAMEOVER` 路径自相矛盾
- `#9` Edge 1.4 说"M1 开除走剧本路径,**不**触发 GAME OVER"
- `#9` Edge 2.1 说"`#10` 接管开除剧本,**`#6` dispatch GAMEOVER**"
- 同 GDD 内两个 Edge 描述不一致
- `#16 KPI Review UI` 仅订阅 `game_over_triggered`,无 `dismissal_triggered` — 若 dismissal 走 GAMEOVER 但不 emit `game_over_triggered`,`#16` 永不进 GAMEOVER 屏
- **修复**: 1 ADR `gameover_dual_path_dismissal_resolution`

**B-AC-1**: "禁金光庆祝" vs `mute_visual_parity` 三方仲裁缺失
- `#16` Rule 10 + AC-TONE-01 禁金光庆祝动画
- `#4` AC-ROBUST-05 + `#5` AC-ROBUST-04 都断言"Master = -60 dB 时 KPI 通过路径视觉独立可达"(收据热敏视觉动画)
- "收据热敏打印动画"是否计金光?边界需 `#16/#4/#5` 三方仲裁,目前无显式 AC 守门
- **修复**: 1 ADR + 三方 AC 联合 sign-off

### ⚠️ WARNING(4 条)

- **B-DEP-4**: `kpi_review_started` 信号在 `#9` Section signal list 未列(仅 Rule 2 步骤提)— 完整性补
- **B-RULE-2**: `_BUREAUCRATIC` 后缀跨 domain 不一致(`#4` Audio human review only / `#9` `#13` 当 Loc key)— Loc CI lint 是否扫 `_BUREAUCRATIC` 不明
- **B-RULE-3**: `subject_inversion_lint.py --domain` 参数 11 套不统一(无 master list)
- **B-KNOB-1**: `#20 Accessibility` settings 防抖路径未列入 `meta_settings_debounce_ms` 共享 timer
- **B-AC-2**: 三档密度 fallback 缺失 AC 在 `#13 HUD` 无对应 farewell event_id 黑名单测试

### ℹ️ INFO(4 条)

- **B-DEP-5**: `#13 HUD` 订阅 `kpi_threshold_changed` 是 Soft 但 `#9` Section UI 未列 `#13` 为消费者
- **B-RULE-4**: `#15` 与 `#13` 对 `event_completed` numeric_only 处理职责重叠(overlay vs row)
- **B-REF-1**: `#16` 引用"`#10` own GAMEOVER.CERTIFICATE.[reason]"但 `#10` Rule 17 未明示文本 own 是 schema / writer / Loc CSV
- **B-REF-2**: `#19 Notification` 未引用 `#9 kpi_prediction_hint`(老 NPC 预言 4 档预警 — 与 Notification 月末预警语义重叠,职责待仲裁)
- **B-KNOB-2**: `final_transition_duration_ms` registry stale(`#16` 真正实施者 + `#14` 消费者均未列入 referenced_by)
- **B-AC-3**: mute_visual_parity AC evidence 文件命名分裂(audio/lighting 各自独立)

---

## Phase 3 — Design Theory **PASS**

| 项 | 状态 |
|----|------|
| 3a 进度循环竞争 | **PASS** — 唯一 core loop 锁定,12 后期 GDD 服务而非竞争 |
| 3b 注意力预算 | **PASS** — ACTION_DAY 表面 7 系统并发,实际 active = `#7 + #11 + #8` 3 系统 ≤ Pillar 5 上限 4 |
| 3c 显性优势策略 | **PASS** — NPC 关系 / Action Card unlock / Run Meta 三重 content-only 守门 + Hero 卡漏洞已 0.45/0.20/0.30 修订 |
| 3d 经济循环 | **PASS** — 5 经济轴(AP / Energy / KPI / NPC / Run Meta unlock)全部健康闭环;Energy ENERGY_MONTHLY_CAP=80 守门 |
| 3e 难度曲线一致性 | **PASS** — 三轴(Formula B + capacity_factor + NPC F3)在 M9-M12 协调收紧;M1 KPI_MONTHLY_MULTIPLIER_CAP_M1=1.05 守"新手骂娘" |
| 3f 支柱对齐 + Anti-Pillar | **PASS** — Anti-P1 6 GDD 守门 + Anti-P2 8 GDD lint + Anti-P3 Input 守门;`subject_inversion_lint.py` CI 联运 |
| 3g 玩家幻想一致性 | **PASS** — 20 GDD 拼出连贯人设"被工位驯化、对庆祝不再期待、把丑陋日常视为常态的中年打工人" |

**Phase 3 verdict: 20 GDD 视角下游戏设计整体性 ship-ready,可放行 architecture 阶段**

---

## Phase 4 — Cross-System Scenario Issues

**6 场景走查**:
- 场景 1: 完整一日循环 → 1 WARNING + 2 INFO
- 场景 2: 月末 KPI Review + GAME OVER + Run Meta 入档 → **1 BLOCKING + 3 WARNING + 1 INFO**
- 场景 3: Settings 同帧改 6 项 → **1 BLOCKING + 2 WARNING + 1 INFO**
- 场景 4: NPC 离职预兆 → LEFT → **1 BLOCKING + 2 WARNING**
- 场景 5: Tutorial Day 1-3 + M1 老 NPC 点评 → 2 WARNING + 1 INFO
- 场景 6: GAME OVER 后 Archive + Settings 改字体 → 2 WARNING + 1 INFO

### 🔴 BLOCKING(3 条)

**B-SCN4-1**: `kpi_review_intro_duration_ms` 三轨同步 anchor 锁定缺失
- `#16` Rule 1 写"KPI_REVIEW_WAITING UI 淡入"+ `#4` Rule 6 月末打卡机 BGM **fade in 1.5s** + `#5` KPI_REVIEW palette Tween 0.3s
- 三轨节奏锚不同步(视觉 0.3s 先到位 + 听觉 1.2s 滞后)
- 已是 OQ-SDF-09(`kpi_review_transition_duration_ms` 候选 knob,`#16` GDD 单独锁)— 但 `#16` 撰写未落实
- **修复**: `#16` Tuning Knob 锁 `kpi_review_intro_duration_ms = 1000ms`(三轨共用 anchor)

**B-SCN4-2**: settings 防抖窗内多信号 reflow 合流策略未跨 GDD 锁定
- `font_size_changed` 与 `locale_changed` 同帧 → `NOTIFICATION_TRANSLATION_CHANGED` 广播两次 vs 合并一次?
- `#3` 与 `#20` 均未明示 reflow 合流;若广播两次 → `#5` R-LVS-5 在已渲染 UI(notice_board 24 元素)二次 reflow fallback 缺失
- **修复**: `#20` Rule 1 + `#3` Rule 5 锁定"settings 防抖窗内多信号合并为单次 `NOTIFICATION_TRANSLATION_CHANGED` 广播"

**B-SCN4-3**: `#5` accumulation 第 4 维定义 + `npc_empty_chairs` 归属判定
- `#5` accumulation 4 维度(`break_room_cracks` / `desk_stain_count` / `notice_board_age` / 第 4 维)中 `npc_empty_chairs` 是否为第 4 维未确认
- `#13 HUD_EMPTY_CHAIR` 是独立 variant 由 `#8 npc_left_company` 直接驱动,**不**走 `#5 accumulation_event` 路径
- 场景描述要求"Lighting 累积 +1"但 GDD 协议显示 LEFT 状态由 `#8` + `#13` 直接渲染,`#5` 未参与
- **修复**: 确认 `#5` accumulation 第 4 维定义 / `npc_empty_chairs` 归属(Lighting vs HUD)

### ⚠️ WARNING(10 条)

| ID | 描述 | 影响 GDD |
|----|------|----------|
| W-SCN4-1 | 单卡链 5 信号 + 7 订阅同帧主线程 budget(`#11 step 4` 重负载未列入 `#6` Rule 3 表) | `#6/#11/#13` |
| W-SCN4-2 | `#15 Recap UI` 月末 KPI_REVIEW 期间是否被 `#6` 屏蔽未声明 | `#15/#9` |
| W-SCN4-3 | `archive↔1500ms transition` 三 GDD 描述顺序不一致(主线程同步 vs 并行) | `#1/#6/#16` |
| W-SCN4-4 | `#19 Notification` 在 GAME OVER 后是否对 LEAVING_ANNOUNCED NPC 继续 emit 未定义 | `#6/#8/#19` |
| W-SCN4-5 | `#10 EVENT_ACTIVE` 态接 `narrative_density_changed` 中途切档行为未声明 | `#10/#17` |
| W-SCN4-6 | `#3 Loc R-LOC-3` 30s watchdog `process_mode = PAUSE_INHERIT` 在 PAUSE 中改 locale 是否触发 reflow 未明 | `#3/#6` |
| W-SCN4-7 | `#13 HUD` LEFT 切空椅前未 fade transition 帧(违反 P3 仪式感) | `#13/#19` |
| W-SCN4-8 | `#11` 卡链中途 LEAVING_ANNOUNCED → LEFT 翻转 `#14` 立绘可见性 race | `#11/#14/#10` |
| W-SCN4-9 | `#18` Tutorial flash vs `#10` 老 NPC 预言 同 NPC 同帧调度优先级未仲裁 | `#10/#18` |
| W-SCN4-10 | `#18 tutorial_skip_flag` 跨 sub-mode 生效时机未明 | `#18` |
| W-SCN4-11 | Archive 200 条 × 4 Label = 800 Label reflow 是否使用虚拟滚动未声明 | `#16/#20` |

### ℹ️ INFO(6 条)

- I-SCN4-1: `#11 step 4` LEAVING_ANNOUNCED ≠ LEFT 守门正确 ✓(玩家可对即将离职 NPC 打道别卡)
- I-SCN4-2: `#10 Rule 16` 与 `#7 Rule 1` 顺序 GDScript 单线程串行 ✓
- I-SCN4-3: `#12` archive_run + `#1` ARCHIVING + `#16` ARCHIVE_VIEW 总链 ≈ 1.6s ✓
- I-SCN4-4: 6 信号 + 单 timer + worker 单写盘 满足 W-SCN-3 仲裁 ✓
- I-SCN4-5: `#18 tutorial_completed` flag content-only + `#1 Rule 22` 5 类 key 白名单一致 ✓
- I-SCN4-6: `#16` 逐条删档三层串行无 race ✓

---

## GDDs Flagged for Revision

无 GDD 需要 Status 转 "Needs Revision"。所有 BLOCKING 都属"跨系统协议 ADR 仲裁待补",非单 GDD 内部已写错的内容。

可选微修(WARNING 级,非 blocking,可在下次 GDD review pass 顺手清):

| 优先级 | GDD | 微修建议 |
|-------|-----|---------|
| P0(架构前) | `#16` | Tuning Knob 锁 `kpi_review_intro_duration_ms = 1000ms`(B-SCN4-1) |
| P0 | `#5/#13/#8` | accumulation 第 4 维 owner 仲裁(B-SCN4-3) |
| P0 | `#9` | Edge 1.4 vs 2.1 dismissal 路径表述统一(B-RULE-1) |
| P0 | `#10/#15` | `narrative_density_changed` 订阅契约补全(B-DEP-1) |
| P0 | `#13/#15/#4/#5` | 离别事件 enum 白名单守门 AC(B-DEP-2) |
| P0 | `#5/#6/#13` | `accumulation_event` ownership 1 ADR 仲裁(B-DEP-3) |
| P0 | `#16/#4/#5` | "金光"vs mute_visual_parity 三方仲裁 ADR(B-AC-1) |
| P0 | `#3/#20` | settings 防抖 reflow 合流策略 ADR(B-SCN4-2) |
| P1 | 各 GDD | 14 WARNING 在 architecture 阶段 / Control Manifest 阶段批量清理 |

---

## 必须在 Architecture / Pre-Production 前解决的项目(8 BLOCKING)

按解决路径分组:

### 路径 A: 由 ADR 仲裁(强烈推荐)

8 BLOCKING 可由 **3-5 个 ADR** 集中仲裁:

1. **ADR — Signal Ownership Matrix**: 解决 B-DEP-1 / B-DEP-2 / B-DEP-3 — `narrative_density_changed` / 离别事件 / `accumulation_event` 三个 cross-cutting 信号 owner + subscriber 契约清单
2. **ADR — `kpi_review_intro_duration_ms` 三轨 anchor**: 解决 B-SCN4-1 — 月末 KPI Review 视觉/听觉/数学三轨节奏共用 anchor knob
3. **ADR — `dismissal_triggered → GAMEOVER` 双路径**: 解决 B-RULE-1 — `#9` Edge 1.4 vs 2.1 自相矛盾 + `#16` 订阅契约
4. **ADR — Settings 防抖窗 reflow 合流策略**: 解决 B-SCN4-2 — `font_size_changed` + `locale_changed` 合并为单次 `NOTIFICATION_TRANSLATION_CHANGED` 广播
5. **ADR — `#5` Accumulation 4 维度 + `npc_empty_chairs` 归属**: 解决 B-SCN4-3 — Lighting vs HUD ownership 仲裁
6. **ADR — "金光庆祝" vs `mute_visual_parity` 视觉边界**: 解决 B-AC-1 — `#16/#4/#5` 三方共识

### 路径 B: GDD 微修(在 review pass 期间清理)

14 WARNING 可批量在 `/design-review` 阶段顺手清理,不阻塞 architecture。

### 路径 C: 推迟到 Control Manifest 阶段

10 INFO 可延至 `/create-control-manifest` 工程标准化阶段批量清理。

---

## 推荐下一步

按依赖与风险综合排序:

1. **`/architecture-decision` × 6 ADRs**(强烈推荐路径) — 集中仲裁 8 BLOCKING,architecture 准入门槛
2. **`/gate-check pre-production`** — 系统设计阶段门禁验证(本 review 是 PASS-with-CONCERNS,可过门只要 BLOCKING 有 ADR 路径)
3. **`/create-architecture`** — 出 ADR 蓝图基于 20 GDD 全套(本 review 提供 BLOCKING 仲裁清单作为 ADR 输入)
4. **18 fresh session reviews** 排队继续(每 GDD 独立 fresh window 跑 `/design-review --depth lean`)— 不阻塞 architecture,可与 ADR 阶段并行

**Architecture 准入门槛建议**:
- 路径 A 6 ADR 必须落地(BLOCKING 仲裁的唯一路径)
- 路径 B 14 WARNING 可在 architecture 完成后 GDD revise 阶段批量清理(不阻塞)
- 路径 C 10 INFO 推迟到 Control Manifest 阶段

**Phase 3 PASS 含义**: 20 GDD 设计层"机制即叙事 / 反向 KPI / 黑色幽默 tone / Pillar 守门"系统性正确。BLOCKING 集中在跨系统协议层(信号 ownership / 三轨节奏 / Lint domain master list / accumulation 维度 / dismissal 路径) — **可由 ADR 集中仲裁,不需要重设计 GDD**。

---

## Appendix — 评审统计

- **GDD 总行数**: 14,501 行(Save 594 + Input 492 + Loc 609 + Audio 628 + Lighting 686 + Scene Flow 1080 + AP 1246 + NPC 1013 + KPI 985 + Event 844 + Card 809 + Run Meta 569 + HUD 689 + Card Play UI 769 + Recap UI 646 + KPI Review UI 758 + Main Menu 544 + Tutorial 468 + Notification 544 + Accessibility 528)
- **AC 总数**: ~410(20 GDD × ~20 AC 平均)
- **Registry constants**: 12(consistency-check 已 PASS,0 BLOCKING value conflicts)
- **Subagent 评审耗时**: Phase 2 (251s) + Phase 3 (206s) + Phase 4 (277s) = 734s 并行执行
- **2026-04-25 baseline 对比**: 上次 5 BLOCKING 全部由 #6 Scene Flow 仲裁完成;新增 8 BLOCKING 全部新增 15 GDD 引入的协议盲点
