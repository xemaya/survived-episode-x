# Story 006: GAMEOVER.CERTIFICATE.[reason] 文本嵌入

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: `TR-kpiui-002`

**ADR Governing Implementation**: ADR-0009 Event Schema Format
**ADR Decision Summary**: 离职证明文本由 `#10 EVENT.KPI.FIRED_DISMISSAL.[reason]` Localization key own,`#16` 仅渲染。reason enum 三值:`KPI_EXCEEDS_CAPACITY` / `OVERAGE_BURNOUT` / `TENURE_LOCKED_OUT`(per `#9 Rule 5` 三 GAME OVER 路径);UNKNOWN fallback(per Story 009)。

**Engine**: Godot 4.6 | **Risk**: HIGH
**Engine Notes**: `tr()` 4.6 已稳;但 `EVENT.KPI.FIRED_DISMISSAL.[reason]` 4 keys 在 csv 缺失 → 玩家看到 raw key 字面量(P5 Loc 守门 R-LOC-1 触发)。本 story 与 Story 009 R-KGO-2 守门联动。

**Control Manifest Rules (Presentation)**:
- Required: 所有 `EVENT.*` / `GAMEOVER.*` keys `tr()` 调用,Story 009 缺失 fallback
- Forbidden: 直接 hardcode 中文离职证明文案("由于您的 KPI...")
- Guardrail: 单次 tr() < 0.1ms;cert 渲染 ≤ 1ms

---

## Acceptance Criteria

- [ ] AC-FUNC-06: `reason = "KPI_EXCEEDS_CAPACITY"`,`CertBody.text = tr("GAMEOVER.CERTIFICATE.KPI_EXCEEDS_CAPACITY")`(非 key 字面量);`IronyTitle.text = tr("GAMEOVER.TITLE_IRONY")`("恭喜晋升")
- [ ] reason enum 三值全覆盖:`KPI_EXCEEDS_CAPACITY` / `OVERAGE_BURNOUT` / `TENURE_LOCKED_OUT`(per `#9 Rule 5` 三路径)
- [ ] cert 渲染时机:state 进入 `GAMEOVER_TRANSITION`,Tween 启动同帧,文本已 ready(`tr()` 同步预解析)
- [ ] reason 来自 `#9 game_over_triggered(reason: String)` 信号参数,**直接传递**,UI 不解析 month / npc 等

---

## Implementation Notes

*From GDD Rule 6 + ADR-0009:*

- 渲染序列:
  ```gdscript
  func _on_game_over_triggered(reason: String, month: int) -> void:
      var cert_key := "GAMEOVER.CERTIFICATE.%s" % reason
      cert_body.text = tr(cert_key)  # Story 009 内置 key 缺失 fallback
      irony_title.text = tr("GAMEOVER.TITLE_IRONY")  # "恭喜晋升"
      _transition_to(GAMEOVER_TRANSITION)  # 同帧无 await
  ```
- 三 reason key 由 narrative-director + writer 在 csv 提供:
  - `GAMEOVER.CERTIFICATE.KPI_EXCEEDS_CAPACITY` — KPI 超 capacity 离职(R-KPI-2 路径)
  - `GAMEOVER.CERTIFICATE.OVERAGE_BURNOUT` — overage 累积过载(M3+ 路径)
  - `GAMEOVER.CERTIFICATE.TENURE_LOCKED_OUT` — 工龄项锁住路径(野心版 VS)
- `GAMEOVER.TITLE_IRONY` 必填 — 反讽锚点("恭喜晋升 / Welcome to the Senior Track" 等),由 writer 维护 csv,**禁止**真实庆祝文案
- 注意 Story 009 守门:cert_key 缺失时 push_error + 替换 `GAMEOVER.CERTIFICATE.UNKNOWN` 兜底

---

## Out of Scope

- Story 005: 1500ms transition Tween 主体
- Story 009: R-KGO-2 missing key fallback 详细实施(本 story 仅消费,fallback 在 009 实施)
- writer 的 csv 内容生产(Phase 4 narrative content production)

---

## QA Test Cases

- **AC-FUNC-06**: 三 reason 渲染正确
  - Given: `reason = "KPI_EXCEEDS_CAPACITY"`
  - When: `_on_game_over_triggered("KPI_EXCEEDS_CAPACITY", 4)`
  - Then: `cert_body.text == tr("GAMEOVER.CERTIFICATE.KPI_EXCEEDS_CAPACITY")` AND text 不等于 key 字面量(实际 csv 文案)
  - Edge cases: 三 reason 全测;`reason = ""` 走 UNKNOWN fallback(Story 009)

- **AC-2**: IronyTitle 必填
  - Given: 进入 GAMEOVER_TRANSITION
  - When: cert 渲染完成
  - Then: `irony_title.visible == true` AND `irony_title.text == tr("GAMEOVER.TITLE_IRONY")` AND text 非空

- **AC-3**: tr() 同步,无 await
  - Given: `_on_game_over_triggered` 进入
  - When: 函数执行
  - Then: 函数内无 `await` 关键字(grep 静态分析)+ 同帧返回

---

## Test Evidence

**Required evidence**: `tests/integration/kpi_ui/gameover_certificate_embed_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001(state machine);`#9 KPI` Story 007(game_over_triggered(reason, month) emit);`#3 Localization` Story 001 + 003(tr API + missing key fallback);writer/narrative-director(csv 内容,**Phase 4 production 阻塞 BUT 测试可用占位 csv 验证集成**)
- Unlocks: Story 009(R-KGO-2 守门兜底)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 5 test 函数 in `tests/integration/kpi_ui/gameover_certificate_embed_test.gd`
**Test Evidence**: `tests/integration/kpi_ui/gameover_certificate_embed_test.gd` (96 行 / 5 tests / GdUnit4) — BLOCKING gate PASS
- AC-FUNC-06 reason key 渲染 → `test_certificate_uses_reason_specific_key` + `test_irony_title_uses_title_irony_key`
- 三 reason 全覆盖 → `test_three_reason_enum_distinct_renders` (3 reasons: KPI_EXCEEDS_CAPACITY / OVERAGE_BURNOUT / TENURE_LOCKED_OUT)
- cert 渲染时机同帧 GAMEOVER_TRANSITION → `test_handler_synchronous_state_change`
- reason 直接传递 → `test_reason_passed_through_directly`

**Code Review**: APPROVED;`_render_certificate(reason)` 字符串拼接 GAMEOVER.CERTIFICATE.[reason];IronyTitle 必填;`#16` 仅渲染不解析 month;无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. csv 文案由 narrative-director Phase 4 维护(测试用占位 key 验证集成路径)
**Tech debt**: None new
**API surface**: `_render_certificate(reason: String)` + `LOC_KEY_GAMEOVER_TITLE_IRONY` + `LOC_KEY_GAMEOVER_CERT_PREFIX`
