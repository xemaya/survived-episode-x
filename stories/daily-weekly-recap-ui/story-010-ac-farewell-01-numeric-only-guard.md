# Story 010: AC-FAREWELL-01 farewell numeric_only 守门 [BLOCKING]

> **Epic**: Daily / Weekly Recap UI
> **Status**: Done
> **Layer**: Presentation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/daily-weekly-recap-ui.md`(revised 2026-04-29)
**Requirement**: `TR-recap-005` + AC-FAREWELL-01 [BLOCKING] + B-DEP-2 守门

**ADR Governing Implementation**: ADR-0001 Signal Ownership Matrix(`#10 Rule 23` FAREWELL_EVENT_IDS 权威 enum)+ ADR-0010
**ADR Decision Summary**: Weekly Recap 渲染中,周报内含 farewell event(`event_id ∈ EventScriptEngine.FAREWELL_EVENT_IDS`),该 event 行**仅一行 `EVENT.[event_id].TITLE_NUMERIC` localization key**(无情感词 / 无叹号 / 无"再见" / 无"谢谢")。`tools/farewell_lint.gd` PR 阶段验证。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: `EventScriptEngine.FAREWELL_EVENT_IDS` const 由 `#10 Story 006` own。

**Control Manifest Rules (Presentation)**:
- Required: farewell event 在 Recap 列表渲染时严格 numeric_only
- Forbidden: 多行渲染 / 情感词 / 叹号
- Guardrail: 全 farewell key 一致 PR-blocking

---

## Acceptance Criteria

- [ ] AC-FAREWELL-01 [BLOCKING]: Weekly Recap 渲染中,debug 钩子扫描事件列表段全部 RichTextLabel 节点,周报内含 farewell event(`event_id ∈ FAREWELL_EVENT_IDS`),该 event 行**仅一行 `EVENT.[event_id].TITLE_NUMERIC`**(无情感词 / 无叹号 / 无"再见" / 无"谢谢")
- [ ] `tools/farewell_lint.gd` PR 阶段验证 `RECAP.WEEKLY.*.FAREWELL.*` keys 全匹配 `*.TITLE_NUMERIC` pattern → 不一致 BLOCK PR
- [ ] `subject_inversion_lint.py --domain RECAP` 进一步守门(ADR-0010 master 8 域 list 中 RECAP 包含 farewell numeric_only)
- [ ] 渲染端 `_render_event_line()` 内对 farewell event_id 强制 numeric_only(即使 narrative_density == verbose 也守门)

---

## Implementation Notes

*From GDD Section H AC-FAREWELL-01(revised):*

渲染端守门:
```gdscript
func _render_event_line(ev: EventRecord) -> Control:
    var card := preload("res://scenes/ui/recap/event_line.tscn").instantiate()
    if ev.event_id in EventScriptEngine.FAREWELL_EVENT_IDS:
        # 强制 numeric_only,即使当前密度是 verbose
        card.label.text = "%s: %s" % [
            _format_day_label(ev.day),
            tr("EVENT.%s.TITLE_NUMERIC" % ev.event_id)
        ]
        # 无情感装饰(无 "再见"/"谢谢"/"!"),lint 自动 csv 守门
    else:
        # 一般事件按密度渲染(Story 011 fallback 链)
        card.label.text = _select_event_text_by_density(ev)
    return card
```

farewell csv 守门工具:
```gdscript
# tools/farewell_lint.gd
const FAREWELL_KEY_PATTERN := r"^EVENT\.(LISA_GOODBYE|CLEANING_AUNT_LEAVE|FISH_MONK_LAID_OFF)\.TITLE_NUMERIC$"
const FORBIDDEN_WORDS := ["再见", "谢谢", "永别", "祝你", "!", "❤", "♥"]

func run() -> int:
    var violations := []
    var farewell_ids := EventScriptEngine.FAREWELL_EVENT_IDS  # source of truth
    for ev_id in farewell_ids:
        var key := "EVENT.%s.TITLE_NUMERIC" % ev_id
        if not TranslationServer.has_key(key):
            violations.append("missing key: %s" % key)
            continue
        var text := tr(key)
        for word in FORBIDDEN_WORDS:
            if word in text:
                violations.append("%s contains forbidden word '%s': %s" % [key, word, text])
    if not violations.is_empty():
        for v in violations: push_error(v)
        return 1
    return 0
```

CI 集成:
```yaml
- name: Recap Farewell Lint
  run: godot --headless --script tools/farewell_lint.gd
```

---

## Out of Scope

- `#10 Event Script` Story 006(FAREWELL_EVENT_IDS const 定义)
- Story 004 主体事件列表渲染(本 story 仅 farewell 特例)
- writer farewell csv 内容生产(Phase 4)

---

## QA Test Cases

- **AC-FAREWELL-01 [BLOCKING]**: numeric_only 渲染
  - Given: events 列表含 `event_id == "LISA_GOODBYE"`(in FAREWELL_EVENT_IDS)
  - When: `_render_event_line(lisa_goodbye_event)`
  - Then: card.label.text 仅含 `tr("EVENT.LISA_GOODBYE.TITLE_NUMERIC")`(单行)+ 不含 "再见" / "!" / "谢谢"
  - Edge cases: narrative_density == verbose → 仍守 numeric_only(强制);narrative_density == brief → 同样 numeric_only

- **AC-2**: csv lint
  - Given: csv 含 `EVENT.LISA_GOODBYE.TITLE_NUMERIC = "Lisa 再见!"`
  - When: `godot --headless --script tools/farewell_lint.gd`
  - Then: exit code != 0;命中 "再见" + "!"
  - Edge cases: 改为 "Lisa 离职登记" → 通过

- **AC-3**: 全 farewell ID 覆盖
  - Given: FAREWELL_EVENT_IDS = ["LISA_GOODBYE", "CLEANING_AUNT_LEAVE", "FISH_MONK_LAID_OFF"]
  - When: lint 扫描
  - Then: 3 keys 全检查;任一缺失 → violation

---

## Test Evidence

**Required evidence**: `tests/integration/recap_ui/ac_farewell_01_numeric_only_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 004(事件列表主体);`#10 Event Script` Story 006(FAREWELL_EVENT_IDS const)
- Unlocks: 无(BLOCKING 验证)

---

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 4/4 ACs COVERED via 5 test 函数 (ac_farewell_01_numeric_only_test.gd) — BLOCKING gate PASS
**Test Evidence**: `tests/integration/recap/ac_farewell_01_numeric_only_test.gd` (5 tests / GdUnit4)
**Code Review**: APPROVED;双层守门 — (1) 渲染端 `RecapViewController.render_event_line()` 对 `event_id ∈ FAREWELL_EVENT_IDS` 强制走 `EVENT.<id>.TITLE_NUMERIC` (即使 narrative_density == verbose 也守门);(2) csv 端 `tools/farewell_lint.py` 检查 (a) 全 farewell IDs 必有 TITLE_NUMERIC key, (b) value 不含 forbidden words ("再见" / "谢谢" / "永别" / "祝你" / "!" / "！" / "❤" / "♥"), (c) 禁 alternate-density key (`SUMMARY_BRIEF/STANDARD/VERBOSE`);`farewell_numeric_only_count` test introspection counter
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. 实现采用 Python (`tools/farewell_lint.py`) 而非 GDScript (story IM 给的 `tools/farewell_lint.gd`) — 与项目其他 lints 工具栈一致
2. ADR-0001 / ADR-0010 Status=Proposed — lean-mode-equivalent
3. `FAREWELL_EVENT_IDS` 当前 default 为 `["LISA_GOODBYE", "CLEANING_AUNT_LEAVE", "FISH_MONK_LAID_OFF"]` (mirror GDD spec) — Event Script Story 006 const 落地后 lint 通过 `--ids` CLI flag 复用同一 source of truth (production wiring 取 const, MVP test 用 CLI override);`farewell_ids_provider` Callable seam 在 controller 端
**Tech debt**: None new
**API surface**: `RecapViewController.render_event_line(event_record) -> String` + `farewell_ids_provider` Callable + `farewell_numeric_only_count` int + `tools/farewell_lint.py --csv [path] [--ids "ID1,ID2,..."]` (CLI)
