# Story 006: CSV 5-Column Schema + UTF-8 + RFC 4180

> **Epic**: localization-hooks
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/localization-hooks.md`
**Requirement**: `TR-loc-005`
**ADR Governing Implementation**: GDD Rule 6 CSV schema
**ADR Decision Summary**: 5 列 schema(`key,zh_CN,en,context,max_chars`)+ 头行顺序锁 + UTF-8 without BOM + RFC 4180 quoted commas;`tools/i18n_lint.py` PR-blocking。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 4.6 CSV plural form support + context columns 增量功能(GDD Rule 7 复数已用 explicit variants,本 story 不依赖 4.6 plural)。

**Control Manifest Rules**:
- Required: 5 列顺序锁 + UTF-8 without BOM
- Forbidden: GBK / BOM 前缀 / unquoted comma

## Acceptance Criteria

- [x] **AC-FUNC-07** Rule 6 CSV schema:`tools/i18n_lint.py` 验证头行 `key,zh_CN,en,context,max_chars` 顺序锁 + 首字节非 UTF-8 BOM + 全 row 列数 = 5 → 通过;头行调换 / BOM 前缀 → FAIL `ERR_CSV_SCHEMA: column order mismatch` / `ERR_CSV_BOM`
- [x] **AC-COMPAT-03** Rule 6 CSV encoding:含 unquoted comma `他说,别加班,,,` → FAIL `ERR_CSV_FORMAT: unquoted comma`;GBK 字节序列 → FAIL `ERR_CSV_ENCODING: non-UTF-8`;合法 RFC 4180 引号字段 `"他说,\"别加班\""` 不触发

## Implementation Notes

```python
# tools/i18n_lint.py
def lint_csv_schema(path: str) -> list[str]:
    errors = []
    with open(path, "rb") as f:
        first_bytes = f.read(3)
    if first_bytes == b"\xEF\xBB\xBF":
        errors.append(f"ERR_CSV_BOM: UTF-8 BOM detected at {path}")
    
    with open(path, "r", encoding="utf-8") as f:
        try:
            content = f.read()
        except UnicodeDecodeError as e:
            errors.append(f"ERR_CSV_ENCODING: non-UTF-8 byte sequence at {path}: {e}")
            return errors
    
    import csv
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader, None)
        expected = ["key", "zh_CN", "en", "context", "max_chars"]
        if header != expected:
            errors.append(f"ERR_CSV_SCHEMA: column order mismatch — expected {expected}, got {header}")
        for row_idx, row in enumerate(reader, start=2):
            if len(row) != 5:
                errors.append(f"ERR_CSV_FORMAT: row {row_idx} has {len(row)} columns (expected 5)")
    return errors
```

## QA Test Cases

- **AC-FUNC-07**:头行调换 → FAIL;BOM 前缀 → FAIL;合法 → 通过
- **AC-COMPAT-03**:unquoted comma → FAIL;GBK 字节 → FAIL;RFC 4180 引号 OK

## Test Evidence

`tests/unit/loc/csv_schema_test.py`

## Dependencies

- Depends on: Story 001(lint chain)
- Unlocks: Story 008(CSV parse)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 2/2 COVERED via 7 unit tests(3 schema + 4 encoding)— `python3 -m unittest tests.unit.loc.csv_schema_test`: 7 tests / 0.002s / 0 fail
**Test Evidence**: `tests/unit/loc/csv_schema_test.py`(186 行 / 7 tests / unittest)+ `tools/i18n_lint.py` 新增 `lint_csv_schema(path)` + `CSV_EXPECTED_HEADER` 常量 — BLOCKING gate PASS
**Code Review**: APPROVED(lean-mode autopilot inline);3-stage check(BOM byte / UTF-8 decode / csv.reader RFC 4180)+ 在 decode 失败时 short-circuit 不继续 schema check(避免 cascade 错误);BOM 已警告 + header[0] 仍带 BOM 时静默剥除避免 schema double-fail 同 artefact;无 BLOCKING / 无 inline fix
**Deviations**(全 ADVISORY,无 BLOCKING):
1. ADR governing = GDD Rule 6(无独立 ADR 文件)
2. 故事伪代码用 `import csv` 在 function 内 — 实施移到顶部更标准(改用 inline `import io` 用于 StringIO)
3. 故事伪代码 ERR_CSV_FORMAT 仅说"unquoted comma" — 实施统一为列数错误(unquoted comma + 缺列都发同 family,csv.reader 行为决定无法分辨),消息含 "row N has X columns (expected 5)"
**Tech debt**: None new
**API surface**: `i18n_lint.lint_csv_schema(path: str) -> list[str]` + `i18n_lint.CSV_EXPECTED_HEADER: tuple`
