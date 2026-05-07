# Story 006: RECAP.* HR 主语翻转 lint 域扩展

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-003` + AC-FUNC-11 + Rule 6 + Rule 11

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master 8 Domain List
**ADR Decision Summary**: `RECAP.*` 域加入 lint master list,扩展 `subject_inversion_lint.py --domain RECAP`;0 RECAP key 含禁止词族(励志 / 恭喜 / 完成度 / 玩家主语);带 HR 口吻标注的词条须使用 `_BUREAUCRATIC` 后缀。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: lint 工具同 `#16` Story 013(共享 framework)。

**Control Manifest Rules (Presentation)**:
- Required: `subject_inversion_lint.py --domain RECAP` CI 阻塞;0 violations
- Forbidden: 玩家主语("你完成 / 你高效 / 你的本周")+ 励志词族("恭喜 / 太棒了 / 继续加油")
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-FUNC-11: `RECAP.*` 全部 Localization key,`subject_inversion_lint.py --domain RECAP` CI 运行,0 个 RECAP key 包含禁止词族(励志 / 恭喜 / 完成度 / 玩家主语);0 个 key 缺 `_BUREAUCRATIC` 后缀(当词条含 HR 口吻标注时)
- [ ] 禁止词族(扫描 csv 文本):"你完成 / 你高效 / 你的本周 / 你的表现 / 恭喜 / 太棒了 / 继续加油 / 突破自我 / 完成度 / 效率指数"
- [ ] 要求模式:系统主语 / 被动句("系统已登记 / 本周备忘 / 积极性已存档")
- [ ] `_BUREAUCRATIC` 后缀强制:含 HR 口吻标注的词条须使用 `RECAP.EFFORT.OVERTIME_REGISTERED_BUREAUCRATIC` 格式命名

---

## Implementation Notes

*From GDD Rule 6 + ADR-0010:*

```python
# tools/subject_inversion_lint.py — 加 RECAP domain
DOMAIN_RULES["RECAP"] = {
    "forbidden_words": [
        "你完成", "你高效", "你的本周", "你的表现",
        "恭喜", "太棒了", "继续加油", "突破自我",
        "完成度", "效率指数",
    ],
    "required_patterns_for_hr_tone": ["系统已", "本周备忘", "已存档", "已登记", "已归档"],
    "required_suffix_for_hr_anno": "_BUREAUCRATIC",  # 当 key 含 HR 标注时强制
    "whitelist_keys": [],
}

# CI 命令(已存 .github/workflows/tests.yml,本 story 加参数)
# python tools/subject_inversion_lint.py --domain RECAP,KPI,GAMEOVER,EVAL,ARCHIVE,MAINMENU,PAUSE,SETTINGS,REMAP --csv assets/locale/zh_CN.csv
```

writer 第三层守门:
- 自动 lint(本 story)
- writer review(narrative-director 复审)
- playtest tone 感知(AC-TONE-01,defer Beta)

---

## Out of Scope

- writer csv 内容生产(Phase 4)
- Story 005 视觉禁区 lint(独立)
- Story 010 AC-FAREWELL-01(独立)

---

## QA Test Cases

- **AC-FUNC-11**: 0 violations
  - Given: assets/locale/zh_CN.csv 含 RECAP.* keys 干净
  - When: `python tools/subject_inversion_lint.py --domain RECAP`
  - Then: exit code == 0;0 violations
  - Edge cases: 故意加 `RECAP.WEEKLY.HR_COMMENT_01 = "恭喜你完成本周工作"` → exit code != 0(命中 "恭喜" + "你完成")

- **AC-2**: _BUREAUCRATIC 后缀强制
  - Given: csv 含 `RECAP.EFFORT.OVERTIME_REGISTERED = "积极性已登记"`(无后缀)
  - When: lint 扫描
  - Then: violation — "key 应改为 RECAP.EFFORT.OVERTIME_REGISTERED_BUREAUCRATIC"(因含 HR 标注词)

- **AC-3**: 系统主语必填
  - Given: `RECAP.WEEKLY.HR_COMMENT_03 = "你这周很努力"`
  - When: lint
  - Then: violation — "缺系统主语"(玩家主语命中)

---

## Test Evidence

**Required evidence**: `tests/unit/recap_ui/recap_subject_inversion_lint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: `#10 Event Script` Story 011(主语翻转 8 master 框架);`#3 Localization` Story 011(IRONY tone coverage lint 框架)
- Unlocks: 无

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 ACs COVERED via 5 test 函数 (recap_subject_inversion_lint_test.gd)
**Test Evidence**: `tests/unit/recap/recap_subject_inversion_lint_test.gd` (5 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED;`tools/subject_inversion_lint.py --domain RECAP --csv [path]` 三层守门 — (1) forbidden_words ("恭喜" / "你完成" / "完成度" / "效率指数" 等 10 词),(2) `_BUREAUCRATIC` 后缀强制 (value 含 "已登记" / "已存档" / "已归档" / "本周备忘" 时 key 必须以 `_BUREAUCRATIC` 结尾),(3) player_subject 模式 ("你完成" / "你高效" / "你的本周" / "你这周" 等);Master 8 + 7 operating-context domain registry 已 scaffold (`MASTER_8_DOMAINS` + `OPERATING_CONTEXT_DOMAINS` const) — 其他域规则后续 stories 注册到 `DOMAIN_RULES` 即可
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0010 Status=Proposed — lean-mode-equivalent
2. writer csv 内容生产 OUT-OF-SCOPE (Phase 4) — 本 story 仅 lint 工具 + test
3. 当前仅 RECAP 域规则注册 (`DOMAIN_RULES["RECAP"]`);其他域 (EVENT/NPC/AP/ENERGY/KPI/EFFORT/TENURE) 当 GDD 落地时增量注册 — `--domain` arg parser 已支持 multi-domain
**Tech debt**: None new
**API surface**: `tools/subject_inversion_lint.py --domain RECAP[,DOMAIN2,...] --csv [path]` (CLI) + `DOMAIN_RULES` dict (扩展时新增 entry)
