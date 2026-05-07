# Story 007: AP Cost 1/2/3 Distribution Lint (40/40/20)

> **Epic**: ap-economy-system | **Status**: Complete | **Layer**: Core | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/ap-economy-system.md` | **Requirement**: `TR-ap-002`
**ADR**: GDD Rule 9 + 协作 Action Card Story 002(card AP cost lint)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: AP cost 分布 1/2/3 比例 ≈ 40/40/20(±5% 容忍)
- Forbidden: AP cost = 0 或 ≥ 4(违反 8 AP/天 budget)

## Acceptance Criteria

- [ ] `tools/ap_cost_lint.py` 扫 `data/cards/*.tres` → 统计 AP cost 分布
- [ ] 验证:cost=1 ≈ 40% (±5%) / cost=2 ≈ 40% (±5%) / cost=3 ≈ 20% (±5%);cost=0/≥4 → CI FAIL
- [ ] 偏离阈值 → CI WARN(non-blocking,economy-designer review)

## Implementation Notes

```python
# tools/ap_cost_lint.py
def lint_card_distribution(cards_dir: str) -> list[str]:
    errors = []
    cost_counts = {1: 0, 2: 0, 3: 0}
    total = 0
    for tres_file in glob_tres(cards_dir):
        cost = parse_ap_cost(tres_file)
        if cost == 0 or cost >= 4:
            errors.append(f"ERR_AP_COST: {tres_file} has invalid cost {cost} (must be 1/2/3)")
            continue
        cost_counts[cost] += 1
        total += 1
    if total == 0:
        return errors
    pct = {c: count / total for c, count in cost_counts.items()}
    if abs(pct[1] - 0.40) > 0.05 or abs(pct[2] - 0.40) > 0.05 or abs(pct[3] - 0.20) > 0.05:
        errors.append(f"WARN_AP_DISTRIBUTION: {pct} deviates from 40/40/20 ±5%")
    return errors
```

## QA Test Cases

- 100 cards 分布 39/41/20 → PASS;36/40/24 → WARN;cost=0 → FAIL

## Test Evidence

`tests/unit/ap/ap_cost_lint_test.py`

## Dependencies

- Depends on: Action Card Story 002(card schema)
- Unlocks: Pre-Production economy-designer balance gate

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 6 test 函数 (`tests/unit/ap/ap_cost_lint_test.py` — Python unittest, 6/6 PASS via `python3 -m unittest`)
**Test Evidence**: `tools/ap_cost_lint.py` (~140 行 Python) + `tests/unit/ap/ap_cost_lint_test.py` (~115 行 / 6 tests / unittest) — BLOCKING gate PASS;含 balanced 40/40/20 + drifted 30/40/30 → WARN + cost=0/cost=5 → ERR + empty dir + .tres + .json mixed
**Code Review**: APPROVED (lean-mode autopilot inline);.tres 用 regex 解析 ap_cost = N (4.6 PackedScene format-3 兼容),.json 用 json.load,容差 ±5pp,cost==0/cost>=4 ERR,distribution 偏 ±5% WARN,exit code 2 (ERR-blocking) / 1 (WARN with --fail-on-warn) / 0
**Deviations** (2 项 ADVISORY,无 BLOCKING):
1. Action Card .tres schema 尚未落地 → tool 容忍缺失 ap_cost field (silent skip);Action Card 落地后即生效 — graceful
2. ADR Status=Proposed (GDD Rule 9 引用) — lean-mode-equivalent
**Tech debt**: None new
**API surface**: `tools/ap_cost_lint.py` CLI (cards_dir [--fail-on-warn]) + module function `lint_card_distribution(cards_dir) -> (errors, warnings)`
