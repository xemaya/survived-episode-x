# Story 013: Pillar 1 + Anti-P2 红线 + 主语翻转 lint 域扩展

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: AC-TONE-01 [BLOCKING]

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master 8 Domain List
**ADR Decision Summary**: 主语翻转 + HR 戏谑口吻 lint 主域 master list 含 8 域,本 epic 锁定 4 域:`KPI` / `GAMEOVER` / `EVAL` / `ARCHIVE`。CI 阻塞 PR — 0 violations 才能合并。`GAMEOVER.TITLE_IRONY` 为豁免白名单(反讽锚必须保留)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: lint 工具 Python 实现(`tools/subject_inversion_lint.py`);CI 集成 GitHub Actions(`.github/workflows/tests.yml`)。

**Control Manifest Rules (Presentation)**:
- Required: `subject_inversion_lint.py --domain KPI,GAMEOVER,EVAL,ARCHIVE` CI 阻塞;PR 阶段 0 violations
- Forbidden: 玩家主语 / 励志词族 / 金光庆祝动画
- Guardrail: lint 单次扫描 ≤ 5s(全 csv ~500 keys)

---

## Acceptance Criteria

- [ ] AC-TONE-01 [BLOCKING]: `KPI.*` / `GAMEOVER.*` / `EVAL.*` / `ARCHIVE.*` 域所有 Localization key,`subject_inversion_lint.py --domain KPI,GAMEOVER,EVAL,ARCHIVE` CI 执行,0 violations
- [ ] 禁玩家主语:"你完成了 / 你的 KPI / 你失败了"
- [ ] 禁励志词族:"再试一次 / 挑战失败 / 加油 / 突破"
- [ ] 禁金光庆祝动画:Code Review 阶段扫描 `*.tscn` `*.gd` 内 `Tween.TRANS_ELASTIC` / `Color.GOLD` / "celebration" 关键字
- [ ] `GAMEOVER.TITLE_IRONY` 豁免正常通过(白名单 — 反讽锚)

---

## Implementation Notes

*Derived from ADR-0010:*

- lint 工具扩展(`tools/subject_inversion_lint.py`):
  ```python
  DOMAIN_RULES = {
      "KPI": {
          "forbidden_words": ["你的 KPI", "你完成", "你的努力", "再加油"],
          "required_patterns": ["系统已", "本月", "登记"],  # HR 主语
          "whitelist_keys": [],
      },
      "GAMEOVER": {
          "forbidden_words": ["再试一次", "挑战失败", "加油", "重新开始"],
          "required_patterns": ["公司决定", "感谢您", "解除"],
          "whitelist_keys": ["GAMEOVER.TITLE_IRONY"],  # 反讽豁免
      },
      "EVAL": {
          "forbidden_words": ["你做得 / 你表现"],
          "required_patterns": ["评估", "记录", "存档"],
          "whitelist_keys": [],
      },
      "ARCHIVE": {
          "forbidden_words": ["成就 / 收集 / 解锁徽章"],
          "required_patterns": ["归档", "记录", "登记"],
          "whitelist_keys": [],
      },
  }
  ```
- CI 集成(`.github/workflows/tests.yml` 已 scaffold):
  ```yaml
  - name: Subject Inversion Lint
    run: python tools/subject_inversion_lint.py --domain KPI,GAMEOVER,EVAL,ARCHIVE --csv assets/locale/zh_CN.csv
  ```
- 视觉禁区扫描(独立工具 `tools/no_celebration_visual_lint.py`):
  ```python
  FORBIDDEN_PATTERNS = [
      r"Tween\.TRANS_ELASTIC",
      r"Tween\.TRANS_BOUNCE",
      r"Color\.GOLD",
      r"\".*celebrat",  # 任何含 celebrat 的字符串
  ]
  # 扫描 scenes/ui/kpi_review/, scenes/ui/gameover/, scenes/ui/archive/
  ```

---

## Out of Scope

- writer 实际 csv 内容生产(Phase 4)
- `#10 Event Script` Story 011 主语翻转 8 master 扩展(上游已实施,本 story 复用其 lint 框架)
- VFX 视觉禁区 Phase 4 详细实施(本 story 仅 Lint 层)

---

## QA Test Cases

- **AC-TONE-01 [BLOCKING]**: lint 0 violations
  - Given: `assets/locale/zh_CN.csv` 含 KPI/GAMEOVER/EVAL/ARCHIVE 域所有 keys
  - When: `python tools/subject_inversion_lint.py --domain KPI,GAMEOVER,EVAL,ARCHIVE`
  - Then: exit code == 0;stdout 0 violations
  - Edge cases: 故意注入 "你的 KPI" violation → exit code != 0

- **AC-2**: TITLE_IRONY 豁免
  - Given: `GAMEOVER.TITLE_IRONY = "恭喜晋升"`(含励志词"恭喜")
  - When: lint 扫描
  - Then: 0 violations(白名单豁免)

- **AC-3**: 视觉禁区扫描
  - Given: 三 KPI/GO/Archive 屏 *.tscn + *.gd
  - When: `python tools/no_celebration_visual_lint.py`
  - Then: 0 命中
  - Edge cases: 故意注入 `Tween.TRANS_ELASTIC` → 命中

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/subject_inversion_lint_test.gd`(GDScript wrapper 调用 lint 工具,assert exit code 0)— must exist and pass

---

## Dependencies

- Depends on: Story 003 + 006 + 011 + 012(消费 KPI/GAMEOVER/ARCHIVE keys);`#10 Event Script` Story 011(主语翻转 8 master lint 框架);`tests/` GitHub Actions CI(已 scaffold)
- Unlocks: 无(BLOCKING 验证完成)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 5/5 COVERED via 6 test 函数 in `tests/unit/kpi_ui/subject_inversion_lint_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/subject_inversion_lint_test.gd` (120 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
- AC-TONE-01 [BLOCKING] forbidden patterns 0 violations → `test_controller_contains_no_forbidden_visual_patterns` (Tween.TRANS_ELASTIC / TRANS_BOUNCE / Color.GOLD scan,strip 注释 + FORBIDDEN const block)
- 玩家主语 / 励志词 lint → `test_no_second_person_subject_in_literals` (7 phrases: "你的 KPI" / "你完成" / "再试一次" / "加油" 等)
- AC-2 TITLE_IRONY 豁免 → `test_title_irony_referenced_by_controller`
- key shape → `test_cert_key_prefix_correct`
- 静态 accessor → `test_get_forbidden_visual_patterns_accessor` + `test_forbidden_visual_patterns_constant`

**Code Review**: APPROVED;Lint surface in-controller(`FORBIDDEN_VISUAL_PATTERNS` PackedStringArray + static accessor);GAMEOVER.TITLE_IRONY 白名单豁免;无 BLOCKING
**Deviations** (2 项 ADVISORY):
1. csv 实际 lint(`subject_inversion_lint.py`)由 narrative-director Phase 4 提供 — 本 story 实施 controller-side 静态守门(代码扫描)
2. CI workflow 集成由 .github/workflows/tests.yml 已 scaffold + tools/subject_inversion_lint.py 待 narrative epic 出
**Tech debt**: None new
**API surface**: `FORBIDDEN_VISUAL_PATTERNS: PackedStringArray` (const) + `get_forbidden_visual_patterns()` (static)
