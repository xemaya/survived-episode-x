# Story 010: HR 口吻预警 lint(NPC.NOTICE.* keys)

> **Epic**: Notification & Warning System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/notification-warning-system.md`
**Requirement**: `TR-notification-003` + AC-TONE-01/02/03 + Rule 7

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master 8 Domain List
**ADR Decision Summary**: HR 口吻预警语义守门 — `NPC.NOTICE.*` keys 加入 lint master list,扩展 `subject_inversion_lint.py --domain NPC_NOTICE`;0 violations(禁"警告 / 危险 / 注意 / !" / 励志语义);`AC-TONE-01` writer + narrative-director 双重审校。

**Engine**: Godot 4.6 | **Risk**: LOW

**Control Manifest Rules (Presentation Layer)**:
- Required: lint 0 violations;writer 双重 review(Phase 4 content production)
- Forbidden: "警告 / 危险 / 注意 / !"语义 + 励志语义 + 庆祝/胜利音效订阅
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-TONE-01: `#10 Event Script` 中 `warning_npc_prediction_hint` 触发的全部 NPC 台词文案(含 capacity_floor hint + 月末倒计时 3 档),writer team + narrative-director 对照 Rule 7 正例/反例表审校,0 条文案触发"审判语气" / "励志语义"判定
- [ ] AC-TONE-02: 全 Run 验证,无任何弹出文字包含 "警告 / 危险 / 注意 / !" 语义;diegetic 元素变化是唯一信息载体
- [ ] AC-TONE-03: 全 Run 内 4 类预警触发事件,Audio 系统监听,无任何 SFX/BGM 触发与 `warning_*` 信号相关联;Audio 层无 `warning_*` 信号订阅
- [ ] CI lint:`subject_inversion_lint.py --domain NPC_NOTICE` 0 violations

---

## Implementation Notes

*From GDD Rule 7 + AC-TONE:*

```python
# tools/subject_inversion_lint.py — 加 NPC_NOTICE domain
DOMAIN_RULES["NPC_NOTICE"] = {
    "forbidden_words_alert": ["警告", "危险", "注意", "紧急", "!"],
    "forbidden_words_motivational": ["加油", "你能行", "突破", "棒极了"],
    "forbidden_words_judgmental": ["不行", "失败", "错误"],
    "required_patterns": [
        # 老同事无意说的话:
        "听说", "好像", "可能", "看来", "我看", "估计",
    ],
    "applies_to_keys": [
        # capacity hint
        "NPC.NOTICE.CAPACITY_HINT_*",
        # 月末倒计时 3 档
        "NPC.NOTICE.MONTH_END_3_DAYS",
        "NPC.NOTICE.MONTH_END_2_DAYS",
        "NPC.NOTICE.MONTH_END_1_DAY",
        # NPC 离职
        "NPC.NOTICE.LEAVING_*",
        # burnout
        "NPC.NOTICE.BURNOUT_*",
    ],
}
```

Audio layer 守门(AC-TONE-03):
```python
# tools/audio_no_warning_subscription_lint.py
# 扫描 src/autoload/audio_manager.gd:确保无 warning_* signals 订阅
# grep "NotificationWarning.warning_*.connect" 命中 → CI FAIL
```

writer / narrative-director Phase 4 双测:
- 不审判:不能让玩家感觉被批评
- 不励志:不能让玩家觉得"加油就能挺过去"
- 老同事无意说的:像茶水间偶遇老同事顺嘴提一句

正例:"听说这个月 KPI 又涨了,大家都挺紧的"
反例:"警告!您本月 KPI 危险!请立即调整!"

---

## Out of Scope

- Phase 4 writer csv 内容生产
- Story 002..006 各类 warning 实施
- Story 008: popup 红线(独立)

---

## QA Test Cases

- **AC-TONE-01**: lint 0 violations
  - Given: csv 含 NPC_NOTICE 域 keys 干净
  - When: `subject_inversion_lint.py --domain NPC_NOTICE`
  - Then: exit code == 0;0 violations
  - Edge cases: 故意加 "警告!您的 KPI 危险!" → CI FAIL(命中"警告" + "危险" + "!")

- **AC-TONE-03**: Audio 不订阅 warning
  - Given: src/autoload/audio_manager.gd
  - When: grep `warning_.*\.connect`
  - Then: 0 命中(Audio 完全不消费 NotificationWarning 信号)

---

## Test Evidence

**Required evidence**: `tests/unit/notification/hr_tone_notice_lint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 002..006(消费 NPC_NOTICE keys);`#10 Event Script` Story 011(主语翻转 8 master 框架);`#4 Audio Manager` Story 002(Pillar 4 lint 框架)
- Unlocks: 无(BLOCKING tone 验证)

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 8 test 函数(AC-TONE-01 干净通过 + 警告 / 加油 / 失败 / 你完成 各自 fail / AC-TONE-03 audio_manager warning_* subscription fail + clean pass / AC-2 self_test 通过)
**Test Evidence**: `tools/notification_hr_tone_lint.py`(160 行 — 整合 NPC.NOTICE.* tone + Audio coupling 双守门)+ `tests/unit/notification/hr_tone_notice_lint_test.py`(135 行 / 8 tests / unittest)— BLOCKING gate PASS;repo 实跑 0 violations
**Code Review**: APPROVED;NPC_NOTICE domain 注册到 `subject_inversion_lint.py` 的 OPERATING_CONTEXT_DOMAINS(向后兼容,不动 MASTER_8 7 + RECAP);新增 `key_prefix` rule 字段以解耦 CLI domain 名(下划线)与 localisation key prefix(NPC.NOTICE.dot);Audio coupling 通过 2 条 regex 扫描 `audio_manager.gd`(qualified `NotificationWarning.warning_*` + 裸 `warning_<5种>` connect);兼容现有 EVENT / RECAP domain 测试(全 6 项 pass — 无 regression);无 BLOCKING / 无 inline fix
**Deviations**(3 项 ADVISORY,无 BLOCKING):
1. ADR Status=Proposed — lean-mode-equivalent
2. story 文档要求 `tests/unit/notification/hr_tone_notice_lint_test.gd`(GUT wrapper),实际写 `.py`(unittest)与仓库 Python lint 测试惯例对齐(参考 `event/subject_inversion_lint_test.py` 也是 .py)
3. NPC_NOTICE domain 加入 `OPERATING_CONTEXT_DOMAINS` 而非 `MASTER_8_DOMAINS`(因 ADR-0010 master 8 list 不可改 — NPC_NOTICE 是 NPC 的语义子域,不冲突 ADR 决议;待 ADR-0010 正式扩展时可上移)
**Tech debt**: 1 项 — `assets/locale/zh_CN.csv` 中尚无 `NPC.NOTICE.*` 行(localisation-hooks Story 待补);lint 在 CSV 存在时 enforce
**API surface**: `tools/notification_hr_tone_lint.py`(主 lint + `--self-test`)+ `subject_inversion_lint.py --domain NPC_NOTICE`(domain 入口)+ `key_prefix` rule field(向前兼容扩展)
