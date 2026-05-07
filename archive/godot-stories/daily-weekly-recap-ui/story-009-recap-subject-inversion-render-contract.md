# Story 009: 主语翻转 RECAP.* 渲染契约

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: AC-FUNC-10(无硬编码字符串)+ Rule 11

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint(渲染端守门)
**ADR Decision Summary**: 所有 RECAP.* key 文案审校遵循 `#6 Section B 主语翻转原则`(系统主语 / 时间主语 / 被动陈述);`_BUREAUCRATIC` 后缀强制(HR 口吻标注)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `tr()` 4.6 已稳。

**Control Manifest Rules (Presentation)**:
- Required: 所有 Label.text / RichTextLabel.text 通过 `tr(key)` 调用
- Forbidden: hardcoded 中文字面量(违反 AC-FUNC-10)
- Guardrail: tr() 单次 ≤ 0.1ms

---

## Acceptance Criteria

- [ ] AC-FUNC-10: `#15` 所有 Label text 赋值代码,静态分析扫描,所有面向玩家的字符串通过 `tr(key)` 调用,无硬编码中文字面量
- [ ] Rule 11 主语翻转范例(规范化):
  - "你今天用了 8 AP" → "今日 AP 已全部消耗"(`RECAP.DAILY.AP_DEPLETED_BUREAUCRATIC`)
  - "你本周打了 47 张卡" → "本周行动卡记录: 47 张"(`RECAP.WEEKLY.CARD_COUNT_LABEL`)
  - "你的精力很好" → "精力余量: 52"(`RECAP.ENERGY.LEVEL_LABEL`)
- [ ] `_BUREAUCRATIC` 后缀强制(HR 口吻标注词条);Story 006 lint 守门

---

## Implementation Notes

*From GDD Rule 11(revised):*

```gdscript
# RecapPanel.gd
func _render_daily_view(ctx: Dictionary) -> void:
    ap_label.text = "%s: %d" % [tr("RECAP.DAILY.AP_LABEL"), 8 - APEconomy.current_ap]
    energy_label.text = "%s: %d" % [tr("RECAP.ENERGY.LEVEL_LABEL"), APEconomy.current_energy]
    # ...

# 静态分析守门
# tools/recap_no_hardcode_lint.py
import re
HARDCODE_PATTERN = re.compile(r'"[一-鿿]+"')  # 中文字面量
```

writer + narrative-director 维护 csv 内容;本 story 仅渲染端守门(代码 grep + Story 006 csv lint)。

---

## Out of Scope

- Story 006: csv 内容 lint(本 story 仅代码端 grep 守门)
- writer csv 内容生产(Phase 4)

---

## QA Test Cases

- **AC-FUNC-10**: 0 中文字面量
  - Given: src/ui/recap/ 全文件
  - When: `grep -rn '"[一-鿿]\+"' src/ui/recap/ --include="*.gd"`
  - Then: 0 命中(全 tr() 路径)
  - Edge cases: comments 中的中文不算违反(已扣除);TestData 测试桩允许

- **AC-2**: 主语翻转范例
  - Given: csv 含 "你今天用了 8 AP" key
  - When: Story 006 lint 扫描
  - Then: violation;改为 "今日 AP 已全部消耗" 后通过

---

## Test Evidence

**Required evidence**: `tests/unit/recap_ui/recap_no_hardcode_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 003 + 004(消费 RECAP keys);`#3 Localization` Story 001(tr API);Story 006(csv lint 双重守门)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/2 ACs COVERED via 3 test 函数 (recap_no_hardcode_test.gd)
**Test Evidence**: `tests/unit/recap/recap_no_hardcode_test.gd` (3 tests / GdUnit4) — clean run on `src/ui/recap/` exit 0;synthetic violation `"你好世界"` exit 2;Chinese-in-comment 通过
**Code Review**: APPROVED;`tools/recap_no_hardcode_lint.py` 用 `[一-鿿]` Unicode regex 检测 string literal 中文;COMMENT_LINE 模式跳过 `##` / `#` 行;`recap_view_controller.gd` 全部 user-facing text 通过 `_tr(LOC_KEY_*)` — unit suffix `次` / `张` 也通过 tr() (LOC_KEY_UNIT_TIMES / LOC_KEY_UNIT_CARDS) 路由;`daily_recap_screen.gd` / `weekly_recap_screen.gd` 同样 0 中文字面量
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0010 Status=Proposed — lean-mode-equivalent
2. writer csv 内容生产 OUT-OF-SCOPE (Phase 4) — 本 story 仅渲染端 grep 守门;Story 006 csv lint 双重守门
3. 主语翻转范例 ("你今天用了 8 AP" → "今日 AP 已全部消耗") 是 csv 内容侧示例,本 story 工具仅检查 .gd 中文字面量 (Story 006 csv lint 守 csv 端)
**Tech debt**: None new
**API surface**: `tools/recap_no_hardcode_lint.py [paths...]` (CLI) + `RecapViewController.LOC_KEY_UNIT_TIMES` / `LOC_KEY_UNIT_CARDS` const (新增 unit suffix tr() keys)
