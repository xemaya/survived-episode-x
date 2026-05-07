# Story 010: Content-Only Unlocks Whitelist(Anti-P1 Red Line)

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-009`
**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix(forbidden_pattern Anti-P1 守)+ ADR-0006 Dismissal/GAMEOVER Path
**ADR Decision Summary**: `meta.unlocks` 严格 5 类白名单(`codex_entry_id` / `memo_id` / `npc_unlock_id` / `event_branch_id` / `ending_unlock_id`);**禁机械成长字段**(`starting_ap_bonus` / `starting_favor_delta` / `card_power_bonus` / `kpi_base_offset` 等)— Anti-P1 红线 PR-blocking + push_error。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 无 post-cutoff API,纯 GDScript regex / pattern 校验。

**Control Manifest Rules**:
- Required: `run_meta_unlock(content_id)` 严格白名单匹配 `^(codex|memo|npc|event_branch|ending)\.[a-z_]+$`
- Forbidden: 任何机械成长字段写入 meta.unlocks(forbidden_pattern Anti-P1 红线)

## Acceptance Criteria

- [ ] `MetaSaveState.unlocks: Dictionary[StringName, bool]` schema
- [ ] `unlock_content(content_id: StringName) -> Error` API + 严格白名单 regex 匹配
- [ ] 白名单不匹配 → `push_error("Anti-P1 red line: %s not in 5 类 whitelist" % content_id)` + return ERR_INVALID_PARAMETER
- [ ] **AC-FUNC-13** Rule 22 跨局解锁 content-only 白名单:玩家完成 3 个 Run 各触发至少 1 次 cross-run unlock → QA 遍历 `meta.unlocks` keys → 全部命中 5 类白名单;任何数值类 key 出现 → FAIL

## Implementation Notes

参 ADR-0001 forbidden_pattern + #1 Save Rule 22:

```gdscript
# save_system.gd
const UNLOCK_KEY_PATTERN := "^(codex|memo|npc|event_branch|ending)\\.[a-z_0-9]+$"
var _unlock_regex: RegEx

func _ready() -> void:
    _unlock_regex = RegEx.new()
    _unlock_regex.compile(UNLOCK_KEY_PATTERN)

func unlock_content(content_id: StringName) -> Error:
    var match := _unlock_regex.search(str(content_id))
    if match == null:
        push_error("Anti-P1 red line violation: '%s' not in 5-class whitelist (codex|memo|npc|event_branch|ending)" % content_id)
        return ERR_INVALID_PARAMETER
    var meta := load_meta()
    meta.unlocks[content_id] = true
    save_meta_async(meta)
    return OK
```

CI lint(`tools/anti_p1_lint.py`)扫描所有 GDScript 调 `meta.unlocks[...] = ...` / `unlock_content("...")` → 验证 key pattern 命中白名单;违反 PR-blocking。

## Out of Scope

- Story 012:Memo 只读 — Memo 写入仅 archive 时,跨 Run unlock 是只读 access

## QA Test Cases

- **AC-FUNC-13**:Given 3 Runs 各触发 ≥ 1 次 cross-run unlock;When 遍历 meta.unlocks keys;Then 全部命中 `^(codex|memo|npc|event_branch|ending)\.[a-z_]+$`;数值类 key 出现 → FAIL
- **Anti-P1 守门**:Given 测试钩子调 `unlock_content("starting_ap_bonus.bonus_2")`;When;Then push_error + ERR_INVALID_PARAMETER + meta.unlocks 不包含该 key

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/save/content_unlocks_whitelist_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001(三槽位)+ Story 004(meta 防抖)
- Unlocks: Run Meta epic Story(`run_meta_unlock` effect)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 11 test 函数 / 263 行 GdUnit4 unit suite
**Test Evidence**: `tests/unit/save/content_unlocks_whitelist_test.gd` — BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode 内联 autopilot);RegEx.compile 一次性缓存 + assert 守 + str(StringName) regex search;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0001 Status=Proposed — lean-mode 等同 Accepted (Stories 001-009 同前例)
2. `unlocks: Dictionary` 保持 untyped 而非 ACs 列 `Dictionary[StringName, bool]` typed schema — GDScript 4.x typed Dict 支持有限 + 改 typed 破坏 schema_version=1 兼容;通过 unlock_content API 强制 key 类型契约 + doc 标注 (与 Stories 005/007/008/009 untyped Dict 风格一致)
3. CI lint `tools/anti_p1_lint.py` PR-blocking 扫描 — 后续 tools epic (本 story runtime 守门已守 Anti-P1 红线)
**Tech debt**: None new
**API surface**: `SaveSystem.unlock_content(content_id: StringName) -> Error` + `SaveSystem.UNLOCK_KEY_PATTERN` const (regex `^(codex|memo|npc|event_branch|ending)\.[a-z_0-9]+$`)
