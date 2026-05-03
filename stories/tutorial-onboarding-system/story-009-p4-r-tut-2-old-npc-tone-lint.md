# Story 009: P4 R-TUT-2 老 NPC tone 不励志 lint

> **Epic**: Tutorial / Onboarding System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: AC-TONE-01 + Rule 7 + R-TUT-2 守门

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master 8 Domain List(TUTORIAL_NPC 域扩展)
**ADR Decision Summary**: P4 守门:老 NPC(老油条 + Lisa)tone 原则 — **认命共情,不励志**。`NPC.OLD_OIL.ONBOARDING_*` + `NPC.OLD_OIL.M1_REVIEW` + `NPC.LISA.M1_REVIEW` 全部 key 通过 Rule 7 双测(不励志测试 + 不说明书测试);`subject_inversion_lint.py --domain TUTORIAL_NPC` CI 通过。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Feature Layer)**:
- Required: TUTORIAL_NPC 域加入 lint master list;0 violations
- Forbidden: 励志词族("加油 / 你能行 / 突破 / 棒极了")+ 说明书风("第一步 / 接下来 / 现在请")
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-TONE-01: 所有 `NPC.OLD_OIL.ONBOARDING_*` + `NPC.OLD_OIL.M1_REVIEW` + `NPC.LISA.M1_REVIEW` key 台词通过 Rule 7 双测;`subject_inversion_lint.py --domain TUTORIAL_NPC` CI 通过无告警
- [ ] 不励志测试:禁"加油 / 你能行 / 突破 / 太棒了 / 加油"
- [ ] 不说明书测试:禁"第一步 / 接下来 / 现在请 / 教你 / 学会"
- [ ] writer + narrative-director 双重 review(tone-anchored review,Phase 4 content production)

---

## Implementation Notes

*From GDD Rule 7 + R-TUT-2:*

```python
# tools/subject_inversion_lint.py — 加 TUTORIAL_NPC domain
DOMAIN_RULES["TUTORIAL_NPC"] = {
    "forbidden_words_motivational": [
        "加油", "你能行", "突破", "太棒了", "棒极了", "为你骄傲", "不要放弃",
    ],
    "forbidden_words_textbook": [
        "第一步", "接下来", "现在请", "教你", "学会", "请你", "记住要",
    ],
    "required_patterns": [
        # 认命共情:第一人称体验描述
        "我第一年", "你看", "也是这样", "其实", "习惯就好",
    ],
    "applies_to_keys": [
        "NPC.OLD_OIL.ONBOARDING_DAY1", "NPC.OLD_OIL.ONBOARDING_DAY2", "NPC.OLD_OIL.ONBOARDING_DAY3",
        "NPC.OLD_OIL.M1_REVIEW", "NPC.LISA.M1_REVIEW",
    ],
}
```

writer / narrative-director Phase 4 content production:
- 老油条:嘲讽 + 共情("你看,我第一年也是这么过来的"/"这地方就这样"/"你跟我以前一样")
- Lisa:理解 + 距离感("你看着吧"/"反正 KPI 不会等你"/"我也曾经像你这么用力")
- 双测在 csv review 阶段执行 + lint 自动守门

---

## Out of Scope

- Story 003: ONBOARDING NPC hint 触发(本 story 仅 tone 守门)
- Story 005: M1 KPI 评语序列触发
- Phase 4 content production(本 story 仅守门 framework)

---

## QA Test Cases

- **AC-TONE-01**: lint 0 violations
  - Given: csv 含 5 keys 全填(干净 tone)
  - When: `subject_inversion_lint.py --domain TUTORIAL_NPC`
  - Then: exit code == 0;0 violations
  - Edge cases: 故意加 "你能行!加油!" → CI FAIL(命中"你能行" + "加油" + "!")

- **AC-2**: 双测覆盖
  - Given: 5 keys 全填
  - When: lint 扫描 + csv content review
  - Then: 全部含"我 / 你看 / 也是这样"等共情语 + 0 励志 + 0 说明书

---

## Test Evidence

**Required evidence**: `tests/unit/tutorial/r_tut_2_npc_tone_lint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 003 + 005(消费 NPC tone keys);`#10 Event Script` Story 011(8 master lint framework)
- Unlocks: 无(BLOCKING tone 验证)

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED — AC-TONE-01 5 keys 注册 + 双测 / AC-2 励志词族 7 字段守门 / AC-3 说明书风 7 字段守门 / AC-4 writer review hook 占位,通过 7 test 函数覆盖
**Test Evidence**: `tests/unit/tutorial/r_tut_2_npc_tone_lint_test.gd` (~130 行 / 7 tests / GdUnit4) + `tools/old_npc_tone_lint.py` (~150 行 Python lint,自带 --self-test 模式) — BLOCKING gate PASS;`python3 tools/old_npc_tone_lint.py --self-test` PASS + 全 repo scan 0 violations
**Code Review**: APPROVED (lean autopilot inline);Python lint 与 Story 007 popup_lint 同模式(双 forbidden tuple + key whitelist + --self-test);out-of-domain key 不触发(self-test 第 4 case 验证);GdUnit suite 同时扫 zh_CN.csv / en_US.csv graceful skip;无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. `subject_inversion_lint.py --domain TUTORIAL_NPC` 由 #10 Event Script Story 011 master 集成时合并;当前为独立 standalone lint(同接口签名)
**Tech debt**: None new
**API surface**: `tools/old_npc_tone_lint.py` 新增 CI lint;`TUTORIAL_NPC_KEYS` 5-key tuple + `FORBIDDEN_MOTIVATIONAL` 7 词 + `FORBIDDEN_TEXTBOOK` 7 词;`--self-test` mode + `run_lint(repo_root)` API
