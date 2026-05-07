# Story 010: Pillar 4 tone 守门(MVP 即上线)5 类禁视觉 lint

> **Epic**: Accessibility Options
> **Status**: Complete(implemented 2026-05-01 via autopilot Phase 8;visual lint MVP 落地,鸡汤文案 lint 推迟至 cross-epic Story OUT-OF-SCOPE)
> **Layer**: Polish
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/accessibility-options.md`
**Requirement**: AC-TONE-01 + Rule 8

**ADR Governing Implementation**: ADR-0008 Visual Boundary Pillar 4 vs Mute Parity
**ADR Decision Summary**: a11y 不能改 Pillar 4 tone — **禁**鼓励文案模式("加油!" / "你能行!" 等);**5 类禁视觉**:金光 / sparkle / 烟花 / 彩虹 / 鸡汤(励志文案)。CI lint MVP 即上线 PR-blocking。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Polish Layer)**:
- Required: lint 工具 MVP 即上线;扫描全 UI 屏(`/scenes/ui/`)+ 全 csv 文案
- Forbidden: 鼓励文案模式 toggle(Anti-P2 + Anti-P4)+ 5 类视觉元素
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-TONE-01: 5 类禁视觉 lint 通过 — 金光 / sparkle / 烟花 / 彩虹 / 鸡汤(励志文案)
- [ ] **MVP 即上线**:与 Story 009 同时第一周实施
- [ ] 视觉禁区 lint(`tools/no_celebration_visual_lint.py`)扫描 scenes/ui/ + src/ — 禁 `Tween.TRANS_ELASTIC / TRANS_BOUNCE` + `Color.GOLD / Color.RAINBOW` + 关键字 "celebrat / sparkle / firework / rainbow"
- [ ] 鸡汤文案 lint(`subject_inversion_lint.py --domain *`)在所有域 forbidden_words 含励志词族:"加油 / 你能行 / 棒极了 / 太棒了 / 突破 / 完美"

---

## Implementation Notes

*From GDD Rule 8 + AC-TONE-01:*

```python
# tools/no_celebration_visual_lint.py
import os, re, sys

FORBIDDEN_VISUAL_PATTERNS = [
    # Tween easing
    r"Tween\.TRANS_ELASTIC", r"Tween\.TRANS_BOUNCE", r"Tween\.TRANS_BACK",
    # 颜色
    r"Color\.GOLD", r"Color\.YELLOW", r"#FFD700", r"#FFFF00",
    # 字符串(节点名 / 资源名 / 注释)
    r"\bcelebrat", r"\bsparkle\b", r"\bfirework\b", r"\brainbow\b",
    # 鸡汤关键字
    r"\bvictory_anim\b", r"\bsuccess_glow\b",
]
SCAN_DIRS = ["scenes/ui/", "src/ui/", "assets/vfx/"]

def main():
    violations = []
    for d in SCAN_DIRS:
        if not os.path.exists(d): continue
        for root, _, files in os.walk(d):
            for f in files:
                if not f.endswith((".gd", ".tscn", ".tres", ".gdshader")): continue
                full = os.path.join(root, f)
                with open(full) as fp: content = fp.read()
                for pattern in FORBIDDEN_VISUAL_PATTERNS:
                    for m in re.finditer(pattern, content, re.IGNORECASE):
                        line_no = content[:m.start()].count("\n") + 1
                        violations.append(f"{full}:{line_no}: {m.group()}")
    if violations:
        for v in violations: print(f"VIOLATION: {v}", file=sys.stderr)
        sys.exit(1)
    sys.exit(0)
```

鸡汤文案 lint(已在多 epic 复用 `subject_inversion_lint.py`):
```python
# 全域 forbidden_words(应用于所有 RECAP / KPI / GAMEOVER / EVAL / ARCHIVE / MAINMENU / PAUSE / SETTINGS / REMAP / NPC_NOTICE / TUTORIAL_NPC / TUTORIAL_CARD_TEXT 域)
GLOBAL_FORBIDDEN = ["加油", "你能行", "棒极了", "太棒了", "突破", "完美", "胜利", "胜利!"]
```

CI 集成(MVP 第一周即上线):
```yaml
- name: Pillar 4 No Celebration Visual Lint (MVP gate)
  run: python tools/no_celebration_visual_lint.py
- name: Pillar 4 No Motivational Text Lint (MVP gate)
  run: python tools/subject_inversion_lint.py --check-global-forbidden
```

---

## Out of Scope

- Story 009: Anti-P1 lint(独立工具)
- writer csv 内容生产(Phase 4 各 epic)
- VFX 视觉禁区 Polish 实施

---

## QA Test Cases

- **AC-TONE-01**: 5 类禁视觉 lint
  - Given: scenes/ui/ + src/ui/ 干净
  - When: `python tools/no_celebration_visual_lint.py`
  - Then: exit code == 0;0 violations
  - Edge cases: 故意加 `Tween.TRANS_ELASTIC` 在某 UI 屏 → CI FAIL

- **AC-2**: 鸡汤文案
  - Given: csv 含 "MAINMENU.WELCOME = '欢迎!加油!你能行!'"
  - When: subject_inversion_lint.py --check-global-forbidden
  - Then: 命中 "加油" + "你能行"

- **AC-3**: 颜色禁区
  - Given: src/ui/ 加 `var c = Color.GOLD`
  - When: lint
  - Then: violation
  - Edge cases: 注释中的 Gold 应跳过(后续 Polish 改进)

---

## Test Evidence

**Required evidence**: `tests/unit/a11y/pillar4_tone_lint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001 + Story 009(同 lint framework);`#10 Event Script` Story 011(主语翻转 8 master)
- Unlocks: 无(BLOCKING 验证,**MVP 即上线**)

---

## Completion Notes

**Completed**: 2026-05-01(autopilot Phase 8,lean-mode dev-story → inline review → story-done)

**Criteria**: 1/2 verifiable AC PASS via 5 GUT wrapper 函数 + 工具内置 12 例 --self-test;1 OUT-OF-SCOPE deviation
- [x] AC-TONE-01(视觉禁区)— 5 类禁视觉 lint 落地:Tween easing(ELASTIC / BOUNCE / BACK)+ Color tokens(GOLD / YELLOW / #FFD700 / #FFFF00)+ identifier 词族(celebrat / sparkle / firework / rainbow / victory_anim / success_glow);3 项 injection 用例(test_lint_fails_on_injected_tween_elastic / color_gold / sparkle_identifier)全 PASS;current 项目 surface 0 violations
- [DEFERRED-OOS] AC-TONE-01(鸡汤文案)— `tools/subject_inversion_lint.py --check-global-forbidden` 全域 forbidden_words("加油 / 你能行 / 棒极了 / 太棒了 / 突破 / 完美 / 胜利")— 跨 epic 工具,需 narrative team + writer team 配合 ADR-0010 master domain list;在 `#10 Event Script` Story 011 主语翻转 8 master 落地后再启用
- [x] **MVP 即上线** — 视觉 lint 已落地

**Test Evidence**:
- Tool: `tools/no_celebration_visual_lint.py`(new,Python 3,`--self-test` 内置 12 cases)
- GUT wrapper: `tests/unit/a11y/pillar4_tone_lint_test.gd`(new,5 tests)
- 命令行验证:`python3 tools/no_celebration_visual_lint.py --self-test` → OK;`python3 tools/no_celebration_visual_lint.py` → OK(0 violations)

**Code Review**: APPROVED(lean-mode autopilot inline);regex 一次编译 ✓ | identifier 用前缀-only \b boundary 兼容 `sparkle_burst` / `rainbow_grad` ✓ | label 分类便于 CI triage ✓ | 缺失 dir 优雅 skip ✓;无 BLOCKING / 无 inline fix

**Deviations** (3 项,无 BLOCKING):
1. ADVISORY: ADR-0008 Status=Proposed — lean mode 等同 Accepted
2. **OUT-OF-SCOPE**: 鸡汤文案 / subject inversion lint(`subject_inversion_lint.py`)— 跨 epic 工具,涉及 ADR-0010 master domain list + writer / narrative-director,本 story 不动(autopilot 约束:cross-epic 改动需求记 OUT-OF-SCOPE)
3. ADVISORY: AC-3 Polish 期望 "注释中的 Gold 应跳过"(story line 115)未实施 — 当前策略是连注释也禁(Pillar 4 是 tone 纪律,连提名都避)。Polish 期可视实测调整为 strip-comments 模式

**Tech debt**: `subject_inversion_lint.py` 在 narrative epic 创建后需 re-revisit Story 010 验证两边链路一致

**API surface**:
- `tools/no_celebration_visual_lint.py` CLI(无参 = scan;`--self-test` = 内置 smoke)
- Python module exports: `lint_source(text, path)`、`lint_file(Path)`、`scan_project(root)`、`FORBIDDEN_VISUAL_PATTERNS`、`SCAN_DIRS`、`SCANNED_EXTENSIONS` 常量
