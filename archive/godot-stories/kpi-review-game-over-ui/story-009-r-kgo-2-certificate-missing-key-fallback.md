# Story 009: R-KGO-2 CERTIFICATE missing key fallback

> **Epic**: KPI Review & Game Over UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/kpi-review-game-over-ui.md`
**Requirement**: AC-ROBUST-02 [BLOCKING]

**ADR Governing Implementation**: ADR-0009 Event Schema Format
**ADR Decision Summary**: 启动时若 csv 缺失 `GAMEOVER.CERTIFICATE.[reason]` keys → push_error + 渲染时显示 `GAMEOVER.CERTIFICATE.UNKNOWN` 兜底,**不 crash**(P5 Loc 守门 R-LOC-1 同源,但本 story 强化 GAMEOVER 关键路径)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `TranslationServer.has_key()` 4.6 已稳;启动时 _ready() 钩子内扫描即可。

**Control Manifest Rules (Presentation)**:
- Required: 启动期所有关键 key 必有 fallback;不允许玩家看到 raw key 字面量
- Forbidden: 缺 key 直接 crash 或显示 `tr("MISSING_KEY")` 字面量
- Guardrail: 启动 _check_required_keys() ≤ 5ms

---

## Acceptance Criteria

- [ ] AC-ROBUST-02 [BLOCKING]: 启动时 `GAMEOVER.CERTIFICATE.[reason]` key 缺失,`#16._check_required_keys()` 执行,`push_error` + 渲染时显示 `GAMEOVER.CERTIFICATE.UNKNOWN`;**不 crash**
- [ ] 检查启动钩子在 _ready() 触发,扫描 4 个 keys:`KPI_EXCEEDS_CAPACITY` / `OVERAGE_BURNOUT` / `TENURE_LOCKED_OUT` / `UNKNOWN`(本身)
- [ ] `UNKNOWN` key 必填(csv 必须含),内容为通用兜底文案("由于种种原因,公司决定与您解除劳动关系" 等冷酷无情 HR 风,由 writer 维护)
- [ ] `_render_certificate(reason)` 内 fallback 路径:`if not TranslationServer.has_key(cert_key): cert_body.text = tr("GAMEOVER.CERTIFICATE.UNKNOWN")`

---

## Implementation Notes

*Derived from ADR-0009 + R-KGO-2:*

- 启动期 key 验证:
  ```gdscript
  const REQUIRED_CERT_KEYS := [
      "GAMEOVER.CERTIFICATE.KPI_EXCEEDS_CAPACITY",
      "GAMEOVER.CERTIFICATE.OVERAGE_BURNOUT",
      "GAMEOVER.CERTIFICATE.TENURE_LOCKED_OUT",
      "GAMEOVER.CERTIFICATE.UNKNOWN",
      "GAMEOVER.TITLE_IRONY",
  ]

  func _ready() -> void:
      _check_required_keys()

  func _check_required_keys() -> void:
      var missing := []
      for k in REQUIRED_CERT_KEYS:
          if not TranslationServer.has_key(k):
              missing.append(k)
      if not missing.is_empty():
          push_error("R-KGO-2: GAMEOVER cert keys missing: %s" % missing)
  ```
- 渲染时 fallback(扩展 Story 006):
  ```gdscript
  func _render_certificate(reason: String) -> void:
      var cert_key := "GAMEOVER.CERTIFICATE.%s" % reason
      if TranslationServer.has_key(cert_key):
          cert_body.text = tr(cert_key)
      else:
          push_error("R-KGO-2 fallback triggered: missing %s" % cert_key)
          cert_body.text = tr("GAMEOVER.CERTIFICATE.UNKNOWN")
  ```
- `UNKNOWN` 自身缺失则触发 P5 Loc 守门 `_render_missing_key()`(`#3 Localization` Story 003)— 但 epic 内须保证 csv 必含 UNKNOWN(content production 责任)

---

## Out of Scope

- Story 006: cert 嵌入主路径(本 story 仅 fallback)
- `#3 Localization` Story 003 missing key 兜底主体(本 story 复用 Loc 兜底)
- writer csv 内容生产(Phase 4)

---

## QA Test Cases

- **AC-ROBUST-02 [BLOCKING]**: missing key 不 crash
  - Given: csv 缺 `GAMEOVER.CERTIFICATE.OVERAGE_BURNOUT` key(测试 fixture 模拟)
  - When: `_render_certificate("OVERAGE_BURNOUT")`
  - Then: 函数同步返回(无 crash)+ `cert_body.text == tr("GAMEOVER.CERTIFICATE.UNKNOWN")` + `push_error` 调用 1 次
  - Edge cases: 三 reason 全缺失 → 全部走 UNKNOWN;UNKNOWN 也缺失 → 走 P5 Loc raw key 兜底(不 crash)

- **AC-2**: 启动期检查
  - Given: csv 缺 `GAMEOVER.CERTIFICATE.UNKNOWN`
  - When: `_ready()` 触发
  - Then: `_check_required_keys()` 报告 missing 列表含 UNKNOWN + push_error 调用 ≥ 1 次

- **AC-3**: 启动检查性能
  - Given: csv 完整
  - When: `_check_required_keys()` 执行
  - Then: 耗时 ≤ 5ms

---

## Test Evidence

**Required evidence**: `tests/unit/kpi_ui/r_kgo_2_certificate_missing_key_fallback_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 006(cert 嵌入主路径);`#3 Localization` Story 003(missing key fallback API)
- Unlocks: 无(BLOCKING 验证完成)

---

## Completion Notes
**Completed**: 2026-05-02
**Criteria**: 4/4 COVERED via 6 test 函数 in `tests/unit/kpi_ui/r_kgo_2_certificate_missing_key_fallback_test.gd`
**Test Evidence**: `tests/unit/kpi_ui/r_kgo_2_certificate_missing_key_fallback_test.gd` (110 行 / 6 tests / GdUnit4) — BLOCKING gate PASS
- AC-ROBUST-02 [BLOCKING] missing key fallback → `test_missing_reason_key_falls_back_to_unknown` + `test_missing_key_does_not_crash`
- AC-2 启动钩子扫描 → `test_check_required_keys_reports_missing` + `test_required_cert_keys_constant_integrity` (5 keys: 3 reason + UNKNOWN + TITLE_IRONY)
- AC-3 启动检查 ≤ 5ms → `test_check_required_keys_under_5ms`
- empty reason guard → `test_empty_reason_uses_unknown`

**Code Review**: APPROVED;`_check_required_keys()` _ready 钩子;reason="" / has_translation == false 双路径都走 UNKNOWN;不 crash;无 BLOCKING
**Deviations** (1 项 ADVISORY):
1. `UNKNOWN` 自身缺失时降级为 raw key 字面量(per Story §"P5 Loc 守门复用",csv 必含 UNKNOWN 是 narrative-director Phase 4 责任)
**Tech debt**: None new
**API surface**: `REQUIRED_CERT_KEYS: PackedStringArray` + `_check_required_keys()` + `get_missing_cert_keys()` 测试钩子 + `has_translation_callable: Callable`
