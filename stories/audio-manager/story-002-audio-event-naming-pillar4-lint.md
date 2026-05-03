# Story 002: Audio Event Naming + Pillar 4 Forbidden Lint

> **Epic**: audio-manager | **Status**: Complete | **Layer**: Foundation | **Type**: Logic | **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/audio-manager.md` | **Requirement**: `TR-audio-001` + `TR-audio-006`
**ADR**: ADR-0010(subject_inversion 8 master domain — Audio 用 Bus.* 前缀,但 SFX/Music/Ambient/UI 子域命名规范)
**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules**:
- Required: `BUS.DOMAIN.IDENTIFIER[_BUREAUCRATIC]` 命名 + UPPER_SNAKE_CASE
- Forbidden(Pillar 4):`ACHIEVEMENT / UNLOCK / LEVEL_UP / FANFARE / PERFECT / GREAT / VICTORY / CONGRAT / REWARD` 字样 SFX

## Acceptance Criteria

- [ ] **AC-FUNC-03** `tools/audio_lint.gd` key 命名:`SFX.UI.PUNCH_CLOCK_CLACK_BUREAUCRATIC` 通过;`SFX.UI.SOUND_01` FAIL `numeric identifier`;`ambient.office.fluorescent_hum` FAIL `lowercase`;`VOICE.NPC.HELLO` FAIL `unknown bus namespace`
- [ ] **AC-FUNC-04** Pillar 4 红线:`SFX.*` 含 `ACHIEVEMENT/UNLOCK/LEVEL_UP/FANFARE/PERFECT/GREAT/VICTORY/CONGRAT/REWARD` 任一 → FAIL `ERR_PILLAR4_VIOLATION`;唯一例外 `PUNCH_CLOCK_CLACK_BUREAUCRATIC` + `RECEIPT_THERMAL_HISS_BUREAUCRATIC`(必存)

## Implementation Notes

```gdscript
# tools/audio_lint.gd (Godot 内 EditorScript or CI runner)
const VALID_BUS := ["SFX", "MUSIC", "AMBIENT", "UI"]
const PILLAR4_FORBIDDEN := ["ACHIEVEMENT", "UNLOCK", "LEVEL_UP", "FANFARE", "PERFECT", "GREAT", "VICTORY", "CONGRAT", "REWARD"]

func lint_audio_keys(registry: Array[StringName]) -> Array[String]:
    var errors: Array[String] = []
    for key in registry:
        var s := str(key)
        var bus := s.split(".")[0]
        if not bus in VALID_BUS:
            errors.append("ERR_KEY_NAMING: unknown bus namespace [%s]" % bus)
        if s != s.to_upper():
            errors.append("ERR_KEY_NAMING: lowercase not allowed: %s" % s)
        for forbidden in PILLAR4_FORBIDDEN:
            if forbidden in s:
                errors.append("ERR_PILLAR4_VIOLATION: forbidden SFX type in registry: %s" % s)
    return errors
```

## QA Test Cases

- AC-FUNC-03:4 key 各报对应 FAIL/PASS
- AC-FUNC-04:`SFX.UI.ACHIEVEMENT_*` → FAIL;`PUNCH_CLOCK_CLACK_BUREAUCRATIC` 必存 + 不报错

## Test Evidence

`tests/unit/audio/audio_lint_test.gd`

## Dependencies

- Depends on: None
- Unlocks: 全 SFX / Music story(命名 lint chain)

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 2/2 AC-FUNC-03 + AC-FUNC-04 COVERED via 7 test 函数
**Test Evidence**: `tests/unit/audio/audio_lint_test.gd` (7 tests / GdUnit4) + `tools/audio_lint.py --self-test`(Python parity);BLOCKING gate PASS
**Code Review**: APPROVED (lean-mode autopilot inline);bus 白名单 ∈ {SFX, MUSIC, AMBIENT, UI};Pillar 4 forbidden 9 token 仅 SFX 域校验;UPPER_SNAKE_CASE + IDENT_RE `^[A-Z][A-Z_]*$`(数字禁,符合 AC-FUNC-03 SOUND_01 → FAIL);anchor exception PUNCH_CLOCK_CLACK_BUREAUCRATIC + RECEIPT_THERMAL_HISS_BUREAUCRATIC 通过
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. Audio key registry 文件 `assets/audio/audio_keys.txt` 未 ship(资产协议)— `audio_lint.py` registry 缺失走 advisory PASS,等 audio team 提供 registry 后转 BLOCKING
2. lint 工具 dual implementation(Python CI authoritative + GDScript test parity)— Python 是 CI gate,GDScript test 是 in-engine canary
3. ADR-0010 `subject_inversion_lint --domain audio` 跨域 lint OUT-OF-SCOPE(event-script epic Story 011 cross-domain delivery)
**Tech debt**: None new
**API surface**: `tools/audio_lint.py` (`lint_keys()` / `lint_bank_size()` / `--self-test`);`tests/unit/audio/audio_lint_test.gd::lint_audio_keys()`
