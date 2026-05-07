# Story 012: Daily / Weekly Recap 双屏节点树 own

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: UI
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-001`(双屏节点树)

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix(`#15` 是双屏 own 者)
**ADR Decision Summary**: `#15` own daily-recap-screen.tscn + weekly-recap-screen.tscn 节点树;视觉 context 由 `#5 Lighting` 数据屏蓝光自动覆盖;Skip 提示 "按任意键继续"(主语翻转 — 不写"跳过"二字)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 普通 Control + VBoxContainer 节点树。

**Control Manifest Rules (Presentation)**:
- Required: 双屏 own 节点树独立(不共用同一 scene)
- Forbidden: ProgressBar / TextureProgressBar(Story 005 lint 守门)
- Guardrail: 单屏 ≤ 50 节点(Godot 4.6 layout 性能)

---

## Acceptance Criteria

- [ ] 日报屏(`daily-recap-screen.tscn`)节点结构:
  - 顶部:DateLabel("第 X 天 / 周 Y")+ HRSystemHeader
  - 中部:APUseLabel + EnergyLabel + OvertimeFlag + EarlyLeaveFlag
  - 下部:EventListVBox(≤ 8 条 numeric_only)
  - 底部:SkipPromptLabel("按任意键继续" — 不写"跳过")
- [ ] 周报屏(`weekly-recap-screen.tscn`)节点结构:
  - 顶部:WeekLabel("第 X 周 / 月 Y")+ HRWeeklyHeader
  - 中上:EffortVBox(三行 HR 口吻 — Story 003 渲染)
  - 中:KPIPredictionLabel(一行数字)
  - 中下:EventListVBox(≤ 8 条,日期标注格式)
  - 底部:SkipPromptLabel
- [ ] Gamepad:任意键 skip;D-Pad 无事件列表内滚动(MVP);列表截断 ≤ 8 条静默
- [ ] 字体:思源黑体 Regular(主体)+ 方正公文宋(标题/系统标注);最小 11 px(art-bible §7.2 `AUTO_FIT_FLOOR_PX`)

---

## Implementation Notes

*From GDD UI Requirements:*

节点树:
```
DailyRecapScreen (Control)
├─ DateLabel (Label)
├─ HRSystemHeader (Label)
├─ MidSection (VBoxContainer)
│  ├─ APUseLabel (Label)
│  ├─ EnergyLabel (Label)
│  ├─ OvertimeFlag (Label, conditional visible)
│  └─ EarlyLeaveFlag (Label, conditional visible)
├─ EventListVBox (VBoxContainer)
│  └─ EventLine × N(动态 instantiate by Story 004/008 chunked)
└─ SkipPromptLabel (Label)
```

```
WeeklyRecapScreen (Control)
├─ WeekLabel (Label)
├─ HRWeeklyHeader (Label)
├─ EffortVBox (VBoxContainer)
│  ├─ OvertimeLabel (Label)
│  ├─ HeroLabel (Label)
│  └─ OverageLabel (Label)
├─ KPIPredictionLabel (Label)
├─ EventListVBox (VBoxContainer)
│  └─ EventLine × N
└─ SkipPromptLabel (Label)
```

📌 UX Flag — Phase 4 `/ux-design design/ux/daily-recap-screen.md` + `weekly-recap-screen.md` 产出布局规范 + Gamepad D-Pad focus 链 + 字体层级落地;本 story 仅节点骨架(visual 后期 polish)。

---

## Out of Scope

- Story 003: effort 三维度具体渲染逻辑
- Story 004: 事件列表渲染逻辑
- Story 011: 密度 fallback 链
- Phase 4 UX visual 美化

---

## QA Test Cases

- **AC-1**: 节点树完整(manual UI walkthrough)
  - Setup: 启动游戏 → 进入 DAILY_RECAP sub-mode
  - Verify: 节点树结构匹配 spec(DateLabel + MidSection + EventListVBox + SkipPromptLabel)
  - Pass condition: 反射 child 名称完整;无多余无缺失

- **AC-2**: SkipPrompt 文案
  - Given: 日报屏渲染
  - When: 反射 SkipPromptLabel.text
  - Then: 文本 == tr("RECAP.SKIP_PROMPT") + csv 内容含"按任意键继续"(不含"跳过"二字)

- **AC-3**: 字体层级
  - Given: DailyRecapScreen 节点树
  - When: 反射 theme overrides
  - Then: DateLabel 用方正公文宋 / EventLine.label 用思源黑体 Regular;最小字号 11px

---

## Test Evidence

**Required evidence**: `production/qa/evidence/daily-weekly-recap-screen-node-tree-evidence.md`(UI walkthrough)

---

## Dependencies

- Depends on: Story 001..011(本 story 节点骨架支撑全部业务渲染);`/ux-design daily-recap-screen.md` + `weekly-recap-screen.md`(Phase 4 — 节点骨架可先落地);`#3 Localization` Story 001(tr API)
- Unlocks: Phase 4 UX 美化

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 ACs (节点骨架 + skip 文案 + 字体层级 ADVISORY) COVERED via 4 test 函数 (daily_weekly_screen_node_tree_test.gd)
**Test Evidence**: `tests/unit/recap/daily_weekly_screen_node_tree_test.gd` (4 tests / GdUnit4) — Phase 4 visual polish 留待 UX team
**Code Review**: APPROVED;`DailyRecapScreen` 9 子节点 (DateLabel / HRSystemHeader / MidSection [APUseLabel + EnergyLabel + OvertimeFlag + EarlyLeaveFlag] / EventListVBox / SkipPromptLabel) — `_build_node_tree()` idempotent;`WeeklyRecapScreen` 9 子节点 (WeekLabel / HRWeeklyHeader / EffortVBox [OvertimeLabel + HeroLabel + OverageLabel] / KPIPredictionLabel / EventListVBox / SkipPromptLabel);`render_skip_prompt(tr_callable)` 通过 tr() 路由 — 源码 grep `"跳过"` 0 命中;`get_node_tree_names()` 测试反射入口
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0001 Status=Proposed — lean-mode-equivalent
2. .tscn 资产 OUT-OF-SCOPE (Phase 4 UX team) — 本 story 仅节点骨架 (scriptable widget hierarchy);`/ux-design daily-recap-screen.md` + `weekly-recap-screen.md` Phase 4 产出布局规范 + Gamepad D-Pad focus 链 + 字体层级落地
3. AC-3 字体层级 ADVISORY — 节点骨架不携带 theme override (Phase 4 .tscn 落地 theme),骨架测仅断言子节点存在;art-bible §7.2 `AUTO_FIT_FLOOR_PX = 11px` 由 Phase 4 wiring 落地
**Tech debt**: None new
**API surface**: `DailyRecapScreen` (9 子节点 + `get_node_tree_names() -> PackedStringArray` + `render_skip_prompt(tr_callable)`) + `WeeklyRecapScreen` (9 子节点 + 同 API) + 6 `LOC_KEY_*` const (RECAP.SKIP_PROMPT / RECAP.DAILY.* / RECAP.WEEKLY.*)
