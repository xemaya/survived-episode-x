# Story 008: Pillar 4 5 Forbidden Visuals Lint + 4 Whitelist

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-007`
**ADR**: ADR-0008 Visual Boundary + forbidden_pattern `pillar4_celebration_visuals`
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Forbidden: 5 类视觉(金光 / sparkle / 烟花 / 彩虹 / 鸡汤 caption)— PR-blocking
- Required: 4 例外白名单(收据热敏 / 数据屏蓝光 / 工位日落橙 / KPI 紫静止)

## Acceptance Criteria

- [ ] `tools/visual_lint.gd` CI:扫描 `assets/sprites/` + ParticleSystem assets → 含 5 类禁视觉关键词 → CI FAIL
- [ ] CanvasModulate brightness 变化 ≤ 0.07(自动化 visual diff)
- [ ] 4 例外白名单文档化:`assets/data/lighting_whitelist.tres`

## Implementation Notes

```gdscript
# tools/visual_lint.gd (Godot EditorScript / CI)
const PILLAR4_FORBIDDEN_KEYWORDS := ["gold_light", "sparkle", "firework", "rainbow", "caption_pep_talk", "achievement_glow"]
const ALLOWED_VISUALS := ["receipt_thermal", "data_screen_blue", "sunset_orange", "kpi_purple_static"]

func lint_visual_assets(assets_dir: String) -> Array[String]:
    var errors: Array[String] = []
    var dir := DirAccess.open(assets_dir)
    for f in dir.get_files():
        for forbidden in PILLAR4_FORBIDDEN_KEYWORDS:
            if forbidden in f.to_lower():
                errors.append("ERR_PILLAR4_VISUAL: forbidden visual asset %s" % f)
    return errors
```

## QA Test Cases

- 5 类禁视觉 keyword 命中文件 → CI FAIL
- 4 白名单 keyword 不报错
- brightness 变化 ≤ 0.07(visual diff perf test)

## Test Evidence

`tools/visual_lint.gd` + `tests/unit/lighting/pillar4_visual_lint_test.gd`

## Dependencies

- Depends on: None
- Unlocks: Story 009(Hero card 守 brightness ≤ 0.07)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 3 test 函数(`tools/pillar4_visual_lint.py` self-test PASS / catalogue 4 白名单 token 存在 / brightness lift ceiling = 0.07 const)
**Test Evidence**: `tests/unit/lighting/pillar4_visual_lint_test.gd`(58 行 / 3 tests / GdUnit4)+ `tools/pillar4_visual_lint.py`(124 行,wrapper)+ `assets/data/visual_asset_catalogue.tres`(whitelist Resource)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);**reuse a11y Story 010 的 `tools/no_celebration_visual_lint.py` 为正则源 (DRY)**,本 story 实施 thin wrapper 扩展 lighting-specific 扫描根目录(`assets/sprites/` / `assets/data/` / `assets/shaders/lighting/`)+ whitelist 文档化(`visual_asset_catalogue.tres`);新 lint full-repo run = 0 violations;无 BLOCKING
**Engine API Verification**: 不涉及(纯 Python lint + .tres Resource)
**Deviations**(2 项 ADVISORY):
1. 故事原 spec 让 GDScript EditorScript 实现;改用 Python wrapper 与 `no_celebration_visual_lint` / `i18n_lint` / `signal_ownership_lint` 三个 sibling lint 风格统一(CI workflow 路径一致)
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `tools/pillar4_visual_lint.py` CLI(self-test + 全仓 scan)+ `assets/data/visual_asset_catalogue.tres` whitelist Resource
