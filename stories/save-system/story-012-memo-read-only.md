# Story 012: Memo Read-Only Cross-Run Access

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-009`
**ADR Governing Implementation**: ADR-0013 Archive 200 Virtual Scroll + ADR-0001 Anti-P1 forbidden_pattern
**ADR Decision Summary**: 历代 archive 中的 memo 字段(便利贴文本)仅供新 Run 通过 Save 接口**只读**访问;任何写入尝试返 error;新 Run 首帧 HUD 提示板显示 0–3 条 memo(从 archive 历代抽样)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `OS.set_file_read_only(path, true)` 设只读位(已在 Story 007 ARCHIVING 第 2 步设置);`FileAccess.WRITE` 跨平台错误码差异。

**Control Manifest Rules**:
- Required: archive 文件只读位 + Save 接口只读 access
- Forbidden: 新 Run 修改历代 archive memo

## Acceptance Criteria

- [ ] `read_archive_memo(run_id: int) -> Array[String]` API:从 `archive/[run_id].save` 只读读取 memo 字段
- [ ] **AC-FUNC-06** Rule 10 便利贴只读:`archive/` 下有 14 份历代存档 → 新 Run 启动 → Run Meta 通过 Save 接口只读访问 memo 字段 → 任何写入尝试返 error → 新 Run 首帧 HUD 提示板显示 0–3 条 memo(由 `#13` HUD 订阅 `#12` Run Meta 提供)
- [ ] 写入尝试 API `_write_archive_memo` 不存在(代码审查 — 无对应 API)
- [ ] 修改 archive 文件:`OS.set_file_read_only(path, true)` 已设置(在 Story 007 ARCHIVING 第 2 步)→ 任何 `FileAccess.WRITE` 尝试返 ERR_FILE_CANT_WRITE(跨平台行为略异 — `tests/integration/` 覆盖 SSD/HDD/AV)

## Implementation Notes

```gdscript
# save_system.gd
func read_archive_memo(run_id: int) -> Array[String]:
    var archive_path := SaveStateLoader.ARCHIVE_DIR + "%04d.save" % run_id
    if not FileAccess.file_exists(archive_path):
        return []
    var f := FileAccess.open(archive_path, FileAccess.READ)
    var json_text := f.get_as_text()
    var dict := JSON.parse_string(json_text) as Dictionary
    return dict.get("memo", [] as Array[String])

# 严禁实施:
# func write_archive_memo(run_id: int, memo: Array[String]) -> Error:
#     assert(false, "Memo is read-only — P3 forbidden_pattern")
```

新 Run 启动时,`#12 Run Meta` 调 `read_archive_memo(run_id)` × 14 archive,抽样 0-3 条传给 `#13 HUD` 提示板渲染。

## Out of Scope

- Story 011:archive 200 cap(本 story 不重复 cap 逻辑)
- Run Meta epic Story:抽样规则 + HR 评语词条收集

## QA Test Cases

- **AC-FUNC-06**:Given archive/ 14 份历代存档;When 新 Run 启动;Then `read_archive_memo(run_id)` 返 memo;`#13 HUD` 提示板显示 0-3 条 memo;尝试 `FileAccess.open(archive_path, FileAccess.WRITE)` → 返 ERR_FILE_CANT_WRITE(只读位)
- **代码审查**:`grep -E "write_archive_memo|set_archive_memo"` 全 codebase → 0 hit(只读 API)

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/save/archive_memo_read_only_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 007(ARCHIVING 5 步,只读位设置)
- Unlocks: Run Meta epic Story(memo 抽样)+ HUD epic Story(便利贴渲染)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 in-scope COVERED via 7 test 函数;cross-epic 渲染 deferred
**Test Evidence**: `tests/unit/save/archive_memo_read_only_test.gd` (191 行 / 7 tests / GdUnit4) — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);双 probe path (run_meta / event_script fallback) tolerant 老 schema;`_coerce_string_array` 守 typed Array[String];P3 反射断言守 (`has_method("write_archive_memo")` returns false);archive 文件只读位 write 拒绝 cross-platform (ERR_FILE_CANT_WRITE / ERR_FILE_CANT_OPEN 两接受);无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0013 / ADR-0001 Status=Proposed — lean-mode-equivalent (Stories 001-011 同前例)
2. memo 字段路径不在 CurrentRunSaveState schema 内 — 实施用 final_snapshot.subsystems.run_meta.memo (canonical) + event_script.memo (fallback) 两 probe 路径,实际 path 由 #12 Run Meta epic owner 定. doc 标注
3. 0–3 条 memo 抽样规则 + 便利贴 HUD 渲染 — cross-epic deferred (Run Meta + HUD epic)
**Tech debt**: None new
**API surface**: `SaveSystem.read_archive_memo(run_id: int) -> Array[String]` (only-read API; 无 write_archive_memo / set_archive_memo 反射验证守)
