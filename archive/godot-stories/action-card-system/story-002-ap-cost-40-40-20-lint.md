# Story 002: AP Cost 40/40/20 Distribution Lint

> **Epic**: action-card-system | **Status**: Complete | **Layer**: Feature | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/action-card-system.md` | **Requirement**: `TR-card-002`
**ADR**: 协作 AP Story 007(分布 lint 共享)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: AP cost 分布 1/2/3 比例 ≈ 40/40/20(±5% 容忍)
- Forbidden: AP cost = 0 或 ≥ 4(违反 8 AP/天 budget)

## Acceptance Criteria

- [ ] `tools/ap_cost_lint.py` 扫 `data/cards/*.tres` → 统计 + 验证 40/40/20 ±5%
- [ ] cost=0/≥4 → CI FAIL;cost=1/2/3 通过

## Implementation Notes

参 AP Story 007(共享 lint 工具)。

## QA Test Cases

- 100 cards 39/41/20 → PASS;36/40/24 → WARN;cost=0 → FAIL

## Test Evidence

`tests/unit/card/ap_cost_distribution_test.py`(共享 AP Story 007)

## Dependencies

- Depends on: Story 001 + AP Story 007
- Unlocks: economy-designer balance gate

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 2/2 COVERED via 4 test 函数 (cards-side validation)
**Test Evidence**: `tests/unit/card/ap_cost_distribution_test.py` (123 行 / 4 tests / unittest) — Card schema 派生路径被 `tools/ap_cost_lint.py` 识别 + 40/40/20 ±5% 拒绝 / cost=0/4 ERR_AP_COST 拒绝 — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);共享 ap-economy Story 007 既有 lint 工具,Card .tres 与 Event .tres 同 ap_cost regex,无重复实现;无 BLOCKING / 无 inline fix
**Deviations** (无)
**Tech debt**: None new
**API surface**: 复用 `tools/ap_cost_lint.py` (无新增工具) + 新测试覆盖 cards-side 路径
