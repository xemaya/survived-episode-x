# Story 004: art-bible §7.1 No Overlay Lock

> **Epic**: hud-diegetic | **Status**: Complete | **Layer**: Presentation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/hud-diegetic.md` | **Requirement**: `TR-hud-004`
**ADR**: ADR-0011 forbidden_pattern action_day_canvaslayer_visible
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Forbidden: ACTION_DAY / EVENT_ACTIVE / WEEKEND / MAIN_MENU sub-mode 期间 CanvasLayer.visible = true
- Required: art-bible §7.1 lint PR-blocking

## Acceptance Criteria

- [ ] `tools/art_bible_71_lint.gd` Godot CI 工具
- [ ] 扫码 codebase 检测 — 任何 `_on_scene_state_changed` handler 在 ACTION_DAY/EVENT_ACTIVE/WEEKEND 时设 `canvas_layer.visible = true` → CI FAIL
- [ ] `_on_scene_state_changed` 守门:仅 4 sub-mode(PAUSE / KPI_REVIEW / GAMEOVER / SETTINGS)允许显示

## Implementation Notes

```python
# tools/art_bible_71_lint.py(可改为 GDScript)
import re

CANVAS_VISIBLE_TRUE = re.compile(r"canvas_layer\.visible\s*=\s*true")
ACTION_DAY_PATTERN = re.compile(r"to\s*==\s*&\"(ACTION_DAY|EVENT_ACTIVE|WEEKEND|MAIN_MENU)\"")

def lint_canvas_visibility(gd_files: list[str]) -> list[str]:
    errors = []
    for path in gd_files:
        with open(path) as f:
            content = f.read()
        # 扫描 _on_scene_state_changed handler 块
        for match in CANVAS_VISIBLE_TRUE.finditer(content):
            # 检查上下文是否在 ACTION_DAY/etc 分支
            context_window = content[max(0, match.start()-200):match.end()+50]
            if ACTION_DAY_PATTERN.search(context_window):
                errors.append(f"ERR_ART_BIBLE_71: {path} canvas_layer.visible=true in non-overlay sub-mode")
    return errors
```

## QA Test Cases

- 故意 ACTION_DAY 期间 canvas_layer.visible = true → CI FAIL
- 4 sub-mode(PAUSE/KPI_REVIEW/GAMEOVER/SETTINGS)允许 → PASS

## Test Evidence

`tests/unit/hud/art_bible_71_lint_test.py`

## Dependencies

- Depends on: Story 001
- Unlocks: Pre-Production art-bible gate

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 5 test 函数(`test_bad_action_day_branch_is_flagged` / `test_good_lookup_dispatch_not_flagged` / `test_event_active_branch_is_flagged` / `test_real_src_tree_clean` / `test_self_test_passes`)
**Test Evidence**: `tools/art_bible_71_lint.py`(154 行 / 实施 lint + self-test)+ `tests/unit/hud/art_bible_71_lint_test.py`(94 行 / 5 tests)— 跑通 5/5 PASS;`art-bible §7.1 lint: PASS (scanned src)` 真 src 干净
**Code Review**: APPROVED(lean autopilot inline);Python lint 工具 + GDScript Story 001 lookup 风格;无 BLOCKING / 无 inline fix
**Deviations**(1 项 ADVISORY,无 BLOCKING):
1. ADR-0011 Status=Proposed — lean-mode-equivalent
2. CI workflow 集成 OUT-OF-SCOPE(`.github/workflows/` 在 autopilot 已有 hooks,本 story 仅工具实施)
**Tech debt**: None new
**API surface**: `tools/art_bible_71_lint.py`(`lint_file` / `lint_tree` / `main` / `_self_test`)
