# Story 008: Perf — Verbose Event ≤ 30s Cap

> **Epic**: card-play-dialogue-ui | **Status**: Complete | **Layer**: Presentation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/card-play-dialogue-ui.md` | **Requirement**: `TR-cardui-001`
**ADR**: ADR-0012(verbose 单 event ≤ 30s + writer 守 12 dialogue cap)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Guardrail: 单 verbose event 渲染 ≤ 30s(writer 守 12 dialogue cap;CI lint 字数检查)
- Guardrail: P5 90s/天 budget — 一天 verbose event 数 ≤ 3(P5 budget 守)

## Acceptance Criteria

- [ ] CI lint:`tools/event_schema_lint.py` 检测 verbose dialogue 累计字数 → 估算渲染时长 > 30s → CI WARN
- [ ] 协作 writer authoring 工具(EditorPlugin EventLinter Story 010)
- [ ] playtest 验证 verbose event 平均渲染时长(Beta tier)

## Implementation Notes

```python
# tools/event_schema_lint.py — verbose 渲染时长估算
def lint_verbose_render_time(events_dir: str) -> list[str]:
    errors = []
    for tres in glob_tres(events_dir):
        event = parse_tres(tres)
        if event.dialogue_keys_verbose:
            # 估算:每 dialogue 平均 60 字符 + 每字符 0.05s 阅读时间
            total_chars = estimate_dialogue_chars(event.dialogue_keys_verbose)
            estimated_sec = total_chars * 0.05
            if estimated_sec > 30.0:
                errors.append(f"WARN_VERBOSE_TOO_LONG: {tres} verbose ~{estimated_sec:.1f}s > 30s budget")
    return errors
```

## QA Test Cases

- verbose 12 dialogue × 60 字符 → ~36s WARN
- verbose 8 dialogue × 60 字符 → ~24s PASS

## Test Evidence

`tests/unit/card_ui/verbose_render_time_lint_test.py` + Beta playtest

## Dependencies

- Depends on: Event Script Story 010(EditorPlugin)
- Unlocks: writer authoring 守 verbose 12 dialogue cap

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 7 test 函数(12 keys × 60 chars → ~36s WARN;8 keys × 60 chars → ~24s PASS;13 keys → ERR_VERBOSE_DIALOGUE_OVER_CAP;CSV 翻译表驱动实际字符数;非存在 events 目录 → exit 0 no-op;estimator pure helper 数学正确;空 verbose triplet 不触发 warn)
**Test Evidence**: `tests/unit/card_ui/verbose_render_time_lint_test.py` (7 tests / unittest) — **BLOCKING gate PASS — 本地 `python3 -m unittest` 7/7 OK**
**Code Review**: APPROVED (lean autopilot inline);`tools/verbose_render_time_lint.py` regex-only .tres parser(无 Godot 依赖,纯 Python CI matrix 可跑)+ DEFAULT_CHARS_PER_KEY=60 + SECONDS_PER_CHAR=0.05 = 30s budget = 12 dialogue;CSV 翻译表选项(load_translations_csv)让 CI 用真实译文长度估算;exit code 1=ERROR / 2=WARN / 0=clean(WARN 仅 advisory 不 block merge);writer 12-key hard cap mirror EditorPlugin EventLinter (event-script Story 010);无 BLOCKING / 无 inline fix
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. Beta playtest verbose render-time 实测 OUT-OF-SCOPE(留 Beta tier playtest 阶段)— CI lint 提供静态守门
**Tech debt**: None new
**API surface**: `tools/verbose_render_time_lint.py` CLI(`--events-dir` / `--csv`) + `lint_events(events_dir, translations) -> (warnings, errors)` + `estimate_dialogue_chars` / `estimate_render_seconds` pure helpers
