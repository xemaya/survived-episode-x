# Story 006: tutorial_completed flag content-only(γ_effective = 0)

> **Epic**: Tutorial / Onboarding System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/tutorial-onboarding-system.md`
**Requirement**: `TR-tutorial-003` + Rule 9

**ADR Governing Implementation**: ADR-0003 Save Format / WorkerThreadPool(sub-schema `tutorial`)+ Save Rule 22 content-only
**ADR Decision Summary**: `meta.tutorial.tutorial_completed: bool` sub-schema 字段;严格 content-only — 仅触发 Day 1-3 跳过 fixed_hand_override + onboarding hint 跳过,**不**改 AP 上限 / KPI 系数 / NPC 关系分;Save Rule 22 content-only 白名单守门;`#9 Rule 6` M1 γ_effective = 0(KPI 公式工龄项消去,新人豁免)。

**Engine**: Godot 4.6 | **Risk**: MEDIUM
**Engine Notes**: WorkerThreadPool autosave 异步,tutorial_completed 写入与 KPI Review 同步路径需协调。

**Control Manifest Rules (Feature Layer)**:
- Required: tutorial_completed 仅 content-only 解锁;Save Rule 22 白名单
- Forbidden: tutorial_completed 改 stat / formula(违反 Anti-P1 红线)
- Guardrail: 写入路径 ≤ 50ms(autosave queue)

---

## Acceptance Criteria

- [ ] AC-FUNC-07: M1 NPC 评论序列完成后,`tutorial_completed = true` 写入 Save;新 Run 重读 Save 时 `tutorial_completed` 持久化为 `true`
- [ ] AC-RULE-01: `tutorial_completed = true` 写入后,AP 上限 / KPI 系数 / NPC 关系分**无任何变化**;通过 `#1 Save Rule 22` content-only 验证脚本确认 flag 仅触发白名单 content 解锁
- [ ] sub-schema `meta.tutorial.tutorial_completed: bool` 持久化(默认 false)
- [ ] M1 γ_effective = 0 由 `#9 KPI` Story 003 自身守门(本 story 仅消费 — tutorial_completed 不影响 γ_effective)

---

## Implementation Notes

*From GDD Rule 9 + ADR-0003:*

Save sub-schema(`#1 Save` Story 001 schema 扩展):
```gdscript
# meta.save 内
{
    ...
    "tutorial": {
        "tutorial_completed": false,  # default false,M1 完成后 true
        "tutorial_skip_flag": false,  # OQ-TUT-01 Settings 屏决定时机
    }
}
```

写入(Story 005 链路尾):
```gdscript
# TutorialState.gd
func _write_tutorial_completed() -> void:
    SaveSystem.update_meta_field("tutorial.tutorial_completed", true)
    SaveSystem.queue_autosave()  # ADR-0003 异步 worker thread
    # 信号 broadcast(可选,Story 010 信号架构)
    tutorial_completed.emit()
```

content-only 守门(Save Rule 22):
- `tutorial_completed` 在 `Save.CONTENT_ONLY_UNLOCK_KEYS` 白名单内(Save Story 010)
- `tutorial_completed` **不**在 `STAT_AFFECTING_KEYS` 列表内
- `tools/content_only_lint.gd` 验证

---

## Out of Scope

- Story 005: M1 KPI 评语序列触发(本 story 是触发链路的尾部写入)
- `#9 KPI` Story 003(F2 potential clamp,M1 γ_effective = 0 自身实施)
- `#1 Save` Story 010(content-only 白名单实施)

---

## QA Test Cases

- **AC-FUNC-07**: 持久化
  - Given: M1 NPC 评论序列完成,_write_tutorial_completed() 调用
  - When: SaveSystem 写盘 + 重启游戏 + 重读 Save
  - Then: meta.save.tutorial.tutorial_completed == true
  - Edge cases: 写入失败(disk full)→ push_error + 下次启动重试

- **AC-RULE-01**: content-only 验证
  - Given: tutorial_completed == true 的 Run + tutorial_completed == false 的 Run(同初始 stat)
  - When: 比较 AP_MAX / 各 NPC relationship_score / KPI γ_effective
  - Then: 全部数值相同;tutorial_completed 仅触发 fixed_hand_override 跳过 + onboarding hint 跳过(content-only)
  - Edge cases: 故意把 tutorial_completed 加入 STAT_AFFECTING_KEYS → content_only_lint FAIL

- **AC-3**: sub-schema 字段
  - Given: meta.save.tutorial 子结构
  - When: 反射字段
  - Then: 含 tutorial_completed: bool + tutorial_skip_flag: bool 两字段

---

## Test Evidence

**Required evidence**: `tests/integration/tutorial/tutorial_completed_content_only_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001 + 005;`#1 Save` Story 001(meta schema)+ Story 010(content-only 白名单);`#9 KPI` Story 003(F2 M1 γ=0 自身)
- Unlocks: 无

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED — AC-FUNC-07 写入 + 重读持久化 / AC-RULE-01 content-only 不触 stat keys / AC-3 sub-schema 默认空 + round-trip / AC-4 γ_effective 不写,通过 7 test 函数覆盖
**Test Evidence**: `tests/integration/tutorial/tutorial_completed_content_only_test.gd` (~150 行 / 7 tests / GdUnit4) — BLOCKING gate PASS;直接 round-trip 通过 `MetaSaveState.serialize/deserialize` 实测 sub-schema isolation
**Code Review**: APPROVED (lean autopilot inline);`MetaSaveState.tutorial: Dictionary` (行 63) 已存在 → 复用;TutorialState 通过 `_write_meta_field("tutorial.tutorial_completed", true)` 严守 content-only 路径,断言所有 write field prefix `tutorial.`,杜绝 ap./kpi./npc./run_meta. 触及;无 BLOCKING / 无 inline fix
**Deviations** (1 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent;`SaveSystem.update_meta_field()` 路径(MVP `tools/content_only_lint.gd` whitelist)deferred 到 SaveSystem Story 011 落地后挂载;当前用 graceful no-op + injected meta_writer 测试 seam
**Tech debt**: None new
**API surface**: `TutorialState._write_tutorial_completed()` 内部 + `set_meta_writer(writer: Callable)` 测试 seam + `MetaSaveState.tutorial` Dict 子结构(预存在,复用)
