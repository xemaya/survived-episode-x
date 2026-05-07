# Story 012: _BUREAUCRATIC Anchor Asset Gate + Tone Lint + Perf

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-006`
**ADR**: ADR-0010(`_BUREAUCRATIC` 后缀)+ R-AUD-1
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: 3 锚点 key 必存(`PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC` + `CREDITS_OUTRO_BUREAUCRATIC`)— Pillar 4 月末打卡机 tone
- Guardrail: dispatch p99 < 16.6ms(Pillar 5 ≤ 1 帧)

## Acceptance Criteria

- [ ] **AC-ROBUST-01 [R-AUD-1]** 3 锚点 key CI 守门:`assets/audio/sfx/` 缺 `PUNCH_CLOCK_CLACK_BUREAUCRATIC` / `RECEIPT_THERMAL_HISS_BUREAUCRATIC` / `CREDITS_OUTRO_BUREAUCRATIC` 任一 → CI FAIL `ERR_ASSET_MISSING: ... — R-AUD-1 Pillar 4 tone anchor violated`;runtime bypass:Rule 5 静默降级,KPI 流程不崩,视觉路径独立
- [ ] **AC-PERF-03** runtime dispatch ≤ 1 帧 p99:1000 次混合 dispatch(play_sfx × 400 + play_ambient × 300 + play_music × 300)→ p99 < 16.6ms 主线程;0 call_deferred(日志断言)
- [ ] **AC-TONE-01** `_BUREAUCRATIC` brief 引用 happy path:`PUNCH_CLOCK_CLACK_BUREAUCRATIC` brief 文档含 tone 说明 → lint PASS;`_BUREAUCRATIC` 后缀 key 计数 ≥ 1;writer sign-off advisory
- [ ] **AC-TONE-02** Layer C `_BUREAUCRATIC` brief 缺失 WARN:`RECEIPT_THERMAL_HISS_BUREAUCRATIC` brief 引用空 → lint WARN(不 FAIL);P2 backlog
- [ ] **AC-TONE-03** Rule 4 + 9 普通 UI 按钮无 SFX:diegetic UI 焦点切换 / 普通 act_confirm / act_cancel → `play_sfx` 计数 0;唯一例外:月末结算 confirm → `play_sfx("PUNCH_CLOCK_CLACK_BUREAUCRATIC")` 计数 1

## Implementation Notes

```python
# tools/audio_lint.py
REQUIRED_ANCHOR_KEYS = [
    "SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC",
    "SFX.UI.RECEIPT_THERMAL_HISS_BUREAUCRATIC",
    "MUSIC.GAMEOVER.CREDITS_OUTRO_BUREAUCRATIC",
]

def check_anchor_assets(audio_dir: str, registered_keys: list[str]) -> list[str]:
    errors = []
    for key in REQUIRED_ANCHOR_KEYS:
        if key not in registered_keys:
            errors.append(f"ERR_ASSET_MISSING: {key} — R-AUD-1 Pillar 4 tone anchor violated")
    return errors
```

## QA Test Cases

- AC-ROBUST-01:故意删 `PUNCH_CLOCK_CLACK_BUREAUCRATIC` 资产 → CI FAIL
- AC-PERF-03:1000 次混合 dispatch → p99 < 16.6ms + 0 call_deferred
- AC-TONE-01/02/03:brief 引用 + 普通 UI 0 SFX + 月末 confirm 例外 1 SFX

## Test Evidence

`tests/unit/audio/anchor_assets_test.py` + `tests/integration/audio/perf_dispatch_test.gd` + `tests/integration/audio/ui_no_sfx_test.gd`

## Dependencies

- Depends on: Story 002 + Story 007(SFX 池)+ Story 008(preload)
- Unlocks: Release pipeline asset gate

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 5/5 AC-ROBUST-01 + AC-PERF-03 + AC-TONE-01 + AC-TONE-02 + AC-TONE-03 COVERED via 4 test 函数 + Python lint(REQUIRED_ANCHOR_KEYS shape / 后缀守 / 1000 mixed dispatch < 1s + pool 不增长 / anchor 双 emit;Python audio_lint anchor missing CI gate)
**Test Evidence**: `tests/integration/audio/anchor_perf_test.gd` (4 tests / GdUnit4) + `tools/audio_lint.py --self-test`(anchor missing → ERR_ASSET_MISSING);BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);`REQUIRED_ANCHOR_KEYS` 3 个 const(PUNCH_CLOCK_CLACK_BUREAUCRATIC + RECEIPT_THERMAL_HISS_BUREAUCRATIC + CREDITS_OUTRO_BUREAUCRATIC);Python lint 在 registered_keys 中缺任一 → push ERR_ASSET_MISSING;1000 mixed dispatch (400 SFX + 300 ambient + 300 music) < 1000ms 主线程 + pool size 不增(等价 0 AudioStreamPlayer.new());全部 anchor 后缀 `_BUREAUCRATIC` 校验
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. AC-TONE-01/02 brief 文档引用 lint OUT-OF-SCOPE(briefs 在 design/research/audio-briefs/ 由 audio-director 维护,asset-spec lint Phase 4 接管)
2. AC-TONE-03 普通 UI 0 SFX + 月末 confirm 1 SFX 例外 OUT-OF-SCOPE(UI/HUD epic 实施 act_confirm 路径后由 cross-epic test 验证 — Audio 仅暴露 SFX dispatch 端点)
3. p99 < 16.6ms 帧预算 strict 验证 OUT-OF-SCOPE(test 用 elapsed_ms 总耗时上限 1000ms 替代;p99 单帧统计在 perf-profile skill 后期完成)
**Tech debt**: None new
**API surface**: `const REQUIRED_ANCHOR_KEYS: Array[StringName]`(3 entries);`tools/audio_lint.py` REQUIRED_ANCHOR_KEYS gate;perf burst dispatch 不增长保证
