# Story 010: notice_board_max_entries = 24 FIFO

> **Epic**: lighting-visual-state | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/lighting-visual-state.md` | **Requirement**: `TR-lighting-009`
**ADR**: ADR-0005 + entities.yaml `notice_board_max_entries = 24`
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: notice_board cap 24(2 年月数)+ FIFO 驱逐
- Guardrail: art-bible §6.5 累积视觉 4 维度之一

## Acceptance Criteria

- [ ] `_notice_board: Array[Dictionary]` cap 24
- [ ] 第 25 次 add → FIFO `pop_front` + push 新 entry + Save persist
- [ ] R-LVS-5:reflow 期 24 元素全 RichTextLabel parse_bbcode + 字体 fallback 链(协作 Loc Story 010 broadcast_translation_changed_once + flush_pending_reflow)

## Implementation Notes

```gdscript
const NOTICE_BOARD_MAX_ENTRIES := 24

func add_notice_board_entry(entry: Dictionary) -> void:
    _notice_board.append(entry)
    if _notice_board.size() > NOTICE_BOARD_MAX_ENTRIES:
        _notice_board.pop_front()
    _persist_to_save()

func flush_pending_reflow() -> void:
    # Loc Story 010 协作 — 24 个 Label 全 reflow
    for label in _notice_board_labels:
        label.parse_bbcode(tr(label.localization_key))
        # 字体 fallback 链(Loc Story 009)
```

## QA Test Cases

- 25 次 add → FIFO 驱逐 + 最新 24 个保留;Save round-trip
- 24 元素 reflow ≤ 30 帧(协作 Loc Story 010)

## Test Evidence

`tests/unit/lighting/notice_board_fifo_test.gd` + `tests/integration/lighting/notice_board_reflow_test.gd`

## Dependencies

- Depends on: Story 003 + Story 004(accumulation 触发)+ Loc Story 010(reflow)
- Unlocks: HUD epic NoticeBoard 渲染

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 4 test 函数(`NOTICE_BOARD_MAX_ENTRIES=24` / 25th add → pop_front + 新尾 / Save round-trip 5 entries / `flush_pending_reflow` 重 parse RichTextLabel)
**Test Evidence**: `tests/unit/lighting/notice_board_fifo_test.gd`(82 行 / 4 tests / GdUnit4)— BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode);`add_notice_board_entry` cap 24 + `pop_front` FIFO;`register_notice_board_label` + `flush_pending_reflow` 与 Loc Story 010 `broadcast_translation_changed_once` 协作钩子(用 `parse_bbcode(rtl.text)` 重 parse 走字体 fallback 链);无 BLOCKING
**Engine API Verification**: `Array.pop_front()` 4.0+ 稳定;`RichTextLabel.parse_bbcode(string)` 4.0+;`is_instance_valid(node)` 4.0+ 守 free 后引用
**Deviations**(2 项 ADVISORY):
1. R-LVS-5 reflow ≤ 30 帧 perf — Loc epic Story 010 持有完整 reflow benchmark;此处仅 hook + 单元行为
2. ADR Status=Proposed — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `NOTICE_BOARD_MAX_ENTRIES` const + `add_notice_board_entry(entry)` + `register_notice_board_label(label)` + `flush_pending_reflow()` + `notice_board` 公有读
