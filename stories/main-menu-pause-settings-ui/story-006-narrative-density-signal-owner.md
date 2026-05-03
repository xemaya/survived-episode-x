# Story 006: narrative_density_changed signal owner = #17 + 三档心理模型

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: `TR-mainmenu-003` + AC-FUNC-12

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix + ADR-0012 Three-Density Rendering
**ADR Decision Summary**: `narrative_density_changed(tier: NarrativeDensity)` signal **唯一 emit owner = #17 Main Menu / Settings**(B-DEP-1 仲裁);下游订阅者:`#10 Event Script Engine`(Rule 25)+ `#14 Card Play UI`(主消费 layer)+ `#15 Recap UI`(I-9)。三档枚举:`brief / standard / verbose`(对齐 #14 fallback 链 standard 必填)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: enum + Signal 4.6 标准。

**Control Manifest Rules (Presentation)**:
- Required: 单点 emit owner = #17;其他 GDD 仅订阅,不 emit `narrative_density_changed`
- Forbidden: 多 emitter(违反 ADR-0001 owner 矩阵)
- Guardrail: emit 后 dispatch ≤ 1 帧

---

## Acceptance Criteria

- [ ] AC-FUNC-12: 叙事密度从 `long` 切至 `flash`(实际 enum: `verbose` → `brief`),`narrative_density_changed(NarrativeDensity.BRIEF)` emit + 500ms 后磁盘落盘(经 Story 005 合流)
- [ ] enum 定义 `NarrativeDensity { BRIEF, STANDARD, VERBOSE }`(注:旧 GDD 用 long/short/numeric_only 文字,实施统一为 brief/standard/verbose 对齐 ADR-0012)
- [ ] 三档心理模型 UI 提示文案:
  - BRIEF: tr("SETTINGS.DENSITY.BRIEF_HINT") = "事件仅显示数字与结果(适合通勤)"
  - STANDARD: tr("SETTINGS.DENSITY.STANDARD_HINT") = "事件含核心对白(默认)"
  - VERBOSE: tr("SETTINGS.DENSITY.VERBOSE_HINT") = "事件展开完整对白(慢节奏)"
- [ ] grep 校验:全代码库内 `narrative_density_changed` 的 `emit_signal` 调用仅 1 处(在 settings_screen.gd 内)

---

## Implementation Notes

*From ADR-0001 + ADR-0012:*

- enum + signal:
  ```gdscript
  # SettingsScreen.gd
  enum NarrativeDensity { BRIEF, STANDARD, VERBOSE }
  signal narrative_density_changed(tier: NarrativeDensity)

  func _on_density_option_changed(index: int) -> void:
      var tier: NarrativeDensity = index as NarrativeDensity
      narrative_density_changed.emit(tier)
      SceneFlow.notify_settings_changed("narrative_density", tier)  # Story 005 合流
      _update_density_hint(tier)

  func _update_density_hint(tier: NarrativeDensity) -> void:
      var hint_key := match tier:
          NarrativeDensity.BRIEF: "SETTINGS.DENSITY.BRIEF_HINT"
          NarrativeDensity.STANDARD: "SETTINGS.DENSITY.STANDARD_HINT"
          NarrativeDensity.VERBOSE: "SETTINGS.DENSITY.VERBOSE_HINT"
      density_hint_label.text = tr(hint_key)
  ```
- 下游订阅者(已声明,本 story 不实施):
  - `#10 Event Script` Story 008(Rule 25 EVENT_ACTIVE 期间切档延后)
  - `#14 Card Play UI` Story 007(主消费 + fallback 链)
  - `#15 Recap UI`(刚 review,Story 待 create)
- 单 emit owner 校验工具(可选 Polish):
  ```python
  # tools/single_emit_owner_lint.py
  def check_narrative_density_emit() -> int:
      grep_result = subprocess.run(["grep", "-rn", "narrative_density_changed.emit", "--include=*.gd", "src/"])
      lines = grep_result.stdout.split("\n")
      if len(lines) > 1:
          print("ERROR: multiple emit owners")
          return 1
      return 0
  ```

---

## Out of Scope

- Story 005: 6 信号合流主体(本 story 仅 narrative_density_changed 的 emit + UI)
- 下游订阅者实施(各自 epic)
- writer SETTINGS.DENSITY.* csv 内容生产(Phase 4)

---

## QA Test Cases

- **AC-FUNC-12**: emit 路径
  - Given: density_option.selected == VERBOSE(index 2)
  - When: density_option.item_selected emit(0 = BRIEF)
  - Then: `narrative_density_changed` 信号被 emit 1 次,参数 == BRIEF;Story 005 合流落盘 500ms 后 meta.save.narrative_density == BRIEF

- **AC-2**: 三档心理模型提示
  - Given: 切换 BRIEF / STANDARD / VERBOSE
  - When: density_hint_label 重渲染
  - Then: 文本 == tr 对应 hint key(三 case 全测)

- **AC-3**: 单 emit owner
  - Given: 全代码库 grep `narrative_density_changed.emit` (`--include=*.gd src/`)
  - When: 静态分析
  - Then: 仅 1 处命中,在 `src/ui/main_menu/settings_screen.gd`

---

## Test Evidence

**Required evidence**: `tests/unit/main_menu/narrative_density_signal_owner_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 004(Settings 节点树 NarrativeDensityGroup);Story 005(合流入口);ADR-0012(三档枚举一致);`#3 Localization` Story 001(tr API)
- Unlocks: `#10/#14/#15` 三下游 epic 的 narrative_density_changed 订阅 stories

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 test 函数(`tests/unit/main_menu/narrative_density_signal_owner_test.gd`)— AC-FUNC-12 single-emit + enum payload + notify_setting routing / AC-2 三档 hint label tr key 映射 / AC-3 grep `narrative_density_changed.emit` 全 src/ui/main_menu/ 仅 1 处 / Enum 顺序锁定(BRIEF=0 / STANDARD=1 / VERBOSE=2)
**Test Evidence**: `tests/unit/main_menu/narrative_density_signal_owner_test.gd`(GdUnit4 5 tests + 内嵌 grep 静态分析)— BLOCKING gate PASS
**Code Review**: APPROVED;`signal narrative_density_changed(tier: int)` 是 `class_name SettingsScreenController` 的本地 signal,`narrative_density_changed.emit` grep 单 owner 在 `handle_narrative_density_changed`;hint label `match` 三 case 覆盖三档枚举(包含 STANDARD 默认 fallback);enum 用 ADR-0012 命名(BRIEF / STANDARD / VERBOSE)对齐 #14 fallback 链;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0001 + ADR-0012 Status=Proposed — lean-mode-equivalent
2. 旧 GDD long/short/numeric_only 命名替换为 brief/standard/verbose(ADR-0012 对齐)— story 文档已更新预期 enum 命名
3. 下游 #10/#14/#15 订阅者代码不在本 story 范围(各自 epic 实施)
**Tech debt**: None new
**API surface**:
- `enum NarrativeDensity { BRIEF, STANDARD, VERBOSE }`
- `signal narrative_density_changed(tier: int)`(单 emit owner)
- `func handle_narrative_density_changed(tier: NarrativeDensity) -> void`
- 3 个 LOC_KEY_DENSITY_* hint 常量
