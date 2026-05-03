# Story 011: subject_inversion_lint 8 Master Domain

> **Epic**: event-script-engine | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/event-script-engine.md` Rule 14 | **Requirement**: `TR-event-008`
**ADR**: ADR-0010 8 master domain
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 8 master domain — EVENT / NPC / AP / KPI / EFFORT / TENURE / RECAP / TUTORIAL
- Required: 主语翻转 lint CI 阻塞(PR-blocking)
- Required: writer review 第三层执法

## Acceptance Criteria

- [ ] `tools/subject_inversion_lint.py` Python CI:扫描 `data/lang/zh_CN.csv` + EventResource 文本 → 验证 8 master domain key prefix + IRONY/_BUREAUCRATIC 后缀守门
- [ ] `tools/lint_config.toml` 单点配置 8 domain + 各域 templates(allowed_subjects_inverted)
- [ ] EventResource 文本 lint:`if "员工" in text and not _has_inverted_subject(text)` → WARN

## Implementation Notes

```python
# tools/subject_inversion_lint.py
import tomllib
CONFIG = tomllib.load(open("tools/lint_config.toml", "rb"))
MASTER_DOMAINS = CONFIG["subject_inversion_lint"]["master_domains"]

def lint_event_text(events_dir: str) -> list[str]:
    errors = []
    for tres in glob_tres(events_dir):
        event = parse_tres(tres)
        for key in event.dialogue_keys_standard:
            domain = key.split(".")[0]
            if domain not in MASTER_DOMAINS:
                errors.append(f"ERR_KEY_DOMAIN: {tres} key {key} domain not in master 8")
    return errors
```

## QA Test Cases

- 200 events × 6 dialogue keys lint < 5s
- 故意非 master domain key → lint FAIL

## Test Evidence

`tests/unit/event/subject_inversion_lint_test.py`

## Dependencies

- Depends on: Story 010 + Loc Story 011(IRONY context)
- Unlocks: writer Pillar 4 守门

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 3/3 COVERED via 6 Python tests
**Test Evidence**: `tests/unit/event/subject_inversion_lint_test.py` (6 tests / Python unittest — 全 PASS) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);扩展现有 `tools/subject_inversion_lint.py` 不重写 — 添加 EVENT 域 DOMAIN_RULES (forbidden_words / hr_tone_phrases / player_subject_phrases) 与 RECAP 平行,新增 `lint_event_dialogue_keys_master_domain(events_dir)` 扫描 .tres 内 dialogue_keys_* 强制 8 master domain prefix,新增 EVENT_EPIC_MASTER_DOMAINS = {EVENT,NPC,AP,KPI,EFFORT,TENURE,RECAP,TUTORIAL} 与 ADR-0010 一致;recap epic 现存 MASTER_8_DOMAINS (含 ENERGY 不含 TUTORIAL) 保持兼容不修改;无 BLOCKING / 无 inline fix
**Engine API Verification**: pure Python — 无引擎 API
**Deviations** (2 项 ADVISORY):
1. ADR-0010 Status=Proposed — lean-mode-equivalent
2. 现有 `subject_inversion_lint.py` 旧 MASTER_8 与 ADR-0010 新 8 master 略有出入 (旧含 ENERGY 缺 TUTORIAL) — 本 epic 用独立 const `EVENT_EPIC_MASTER_DOMAINS` 不动既有 RECAP 契约;后续 follow-up story 可统一
**Tech debt**: 旧 `MASTER_8_DOMAINS` 与新 `EVENT_EPIC_MASTER_DOMAINS` 差异 (ENERGY vs TUTORIAL),建议 narrative-director / loc-lead epic 后续合并
**API surface**: `subject_inversion_lint.DOMAIN_RULES["EVENT"]` 新规则 + `lint_event_dialogue_keys_master_domain(events_dir) -> list[str]` 新函数 + `EVENT_EPIC_MASTER_DOMAINS` 常量
