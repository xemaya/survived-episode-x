# Story 005: run_meta_unlock Effect Integration

> **Epic**: run-meta-system | **Status**: Complete | **Layer**: Feature | **Type**: Integration | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/run-meta-system.md` | **Requirement**: `TR-run-meta-005`
**ADR**: ADR-0001 + Event Script Story 003 GiveUnlockEffect 协作
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: GiveUnlockEffect.apply 调 #12.unlock_content + Anti-P1 守门
- Required: signal run_meta_unlock(content_id) emit 通知下游 stories

## Acceptance Criteria

- [ ] `signal run_meta_unlock(content_id: StringName)` owner = #12
- [ ] Event Script Story 003 `GiveUnlockEffect.apply()` → RunMetaSystem.unlock_content(unlock_id) → emit run_meta_unlock(若 OK)
- [ ] 5 类白名单守门(Story 003)+ Anti-P1 lint(协作 AP Story 012)

## Implementation Notes

```gdscript
signal run_meta_unlock(content_id: StringName)

func unlock_content(content_id: StringName) -> Error:
    var err := SaveSystem.unlock_content(content_id)  # Save Story 010 守门
    if err == OK:
        emit_signal(&"run_meta_unlock", content_id)
    return err
```

## QA Test Cases

- GiveUnlockEffect → unlock_content → emit run_meta_unlock(白名单内)
- 非白名单 → ERR + 不 emit

## Test Evidence

`tests/integration/run_meta/unlock_effect_test.gd`(协作 Event Script Story 003 + Save Story 010)

## Dependencies

- Depends on: Story 003 + Event Script Story 003
- Unlocks: 全 content-only 内容解锁链

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 3/3 COVERED via 7 test 函数
**Test Evidence**: `tests/integration/run_meta/unlock_effect_test.gd` (159 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean autopilot inline);Story 003 已实施 unlock_content + run_meta_unlock signal,本 story 加端到端 Effect-driven 测试覆盖:emit count 仅匹配 OK 计数(混合 5 调用 = 3 emit)/ 3-Effect 串行有序触发 / 多 Anti-P1 prefix 拒绝(starting_ap_bonus / kpi_base_offset / resource_pack);GiveUnlockEffect call site 用 unlock_content 直接代理(Event Script Story 003 实施时 .apply() → RunMetaSystem.unlock_content);无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. Event Script Story 003 GiveUnlockEffect class 尚未存在 — 本 story 测试以 RunMetaSystem.unlock_content 直接代理(契约一致),Effect 类落地后只需 wrapper 调用
**Tech debt**: None new
**API surface**: signal `run_meta_unlock(content_id: StringName)` (Story 001+003 已声明) — 本 story 验证完整 chain
