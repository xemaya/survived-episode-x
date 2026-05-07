# Input Handler — Review Log

Authoritative revision history for `design/gdd/input-handler.md`. Each `/design-review` run appends an entry; each revision round documents which items were closed.

---

## Review — 2026-04-24 — Verdict: NEEDS REVISION
Scope signal: **M** (systems-index initially listed S; review recommends M — 5 ADRs queued via OQ-INP-01~05, 9 dependents, dual-focus 4.6 novelty risk)
Specialists: none (lean mode, single-session analysis)
Blocking items: 3 | Recommended: 5 | Nice-to-have: 2
Summary: GDD is implementation-ready in structure (25 GIVEN-WHEN-THEN ACs with 4 RISK GUARD marks; dual-focus semantic lock cleanly ADR-deferred; Anti-Pillar 3 守门 rule framed as GDD-change gate). Blocking items are all local textual mismatches between spec, formulas, and acceptance tests — no structural rewrites needed.

### Blocking
1. **Enum name inconsistency `KB_PAD` vs `KB_GAMEPAD`** — F3 variables table used `KB_PAD`; Rule 5(c), AC-COMPAT-03, AC-A11Y-01, Edge 1, Edge 7.1 used `KB_GAMEPAD`. Signal subscribers can't reliably pattern-match across sites. Must pick one canonical identifier.
2. **Rule 6 `skip_axis_threshold` comparison target contradicted F1 Justification** — Rule 6 literal text said `abs(axis_value) > skip_axis_threshold` (raw); F1 Justification and AC-FUNC-04(d) + AC-COMPAT-01 confirm intent is post-deadzone `joystick_effective_axis`. Implementers reading Rule 6 literally would hard-code raw comparison and AC would fail.
3. **`remap_cancelled` signal arity inconsistent** — States table showed `remap_cancelled(action_name)` (1-arg); Interactions, UI Requirements, Edge 4.3 implied `(action_name, reason)` (2-arg). #17 Remap UI would subscribe based on published signature; mismatch would break the contract.

### Recommended
4. AC tier count arithmetic wrong ("20 MVP" but sum = 23).
5. Save Rule 14 bidirectional textual loop — Save Rule 14 lists "gamepad 布局" but not "keymap" or "KB 键位重映射". Registry closes the loop but textual alignment is thin. (Deferred: save-system.md is Approved — fix at next Save touch.)
6. Rule 10(a) "活跃 gamepad" ambiguous vs F3 `active_path`.
7. Rule 7 silent on modal-op call-site caller contract (Edge 8.2 flags one-frame gap if called from `_process`).
8. Formula 3 third clause wording ("MOUSE after lockout elapses") reads as auto-switch, but Worked Example shows switch requires mouse_delta > threshold.

### Nice-to-have
9. Edge 1 "never saturating" wording imprecise — saturation only at exact `r = 1.0`, unreachable at Godot float precision.
10. Section C header "Detailed Design" should be "Detailed Rules" per project standard.

Prior verdict resolved: First review.

---

## Revision — 2026-04-24 (same-session)
**Resolved 9 of 10 items; 1 item (Recommended #5) explicitly deferred with rationale.**

| # | Item | Resolution | Location |
|---|------|-----------|----------|
| 1 | **[BLOCKER]** Enum `KB_PAD` → `KB_GAMEPAD` global | F3 formula + variables table + Output Range + Worked Example + Justification updated; Edge 1, Edge 7.1, AC-COMPAT-03, AC-A11Y-01 updated | F3 (Formulas) / Edge 1 / Edge 7.1 / AC-COMPAT-03 / AC-A11Y-01 |
| 2 | **[BLOCKER]** Rule 6 skip uses F1 post-deadzone `joystick_effective_axis` | Rule 6 text rewritten: "`InputEventJoypadMotion` 经 F1 映射后 `abs(joystick_effective_axis) > skip_axis_threshold`;比较目标为 post-deadzone 值而非 raw `axis_value`,与 F1 Justification + AC-FUNC-04 一致" | Rule 6 (Core Rules) |
| 3 | **[BLOCKER]** `remap_cancelled` 2-arg `(action_name, reason)` uniform | States table updated; Edge 3.1 updated with `reason=DEVICE_DISCONNECTED`; #17 Interactions row adds explicit reason enum doc (`USER_CANCELLED` / `INVALID_EVENT_TYPE` / `DEVICE_DISCONNECTED`) | States table / Edge 3.1 / #17 Interactions |
| 4 | AC count 20 → 23 (with per-category breakdown) | Text: "MVP 必测(Alpha gate 阻塞)— 23 条: AC-FUNC-01~10 (10) + AC-PERF-01~04 (4) + AC-COMPAT-01~05 (5) + AC-ROBUST-01~04 (4) = 23" | AC Tier 分级 |
| 5 | **[DEFERRED]** Save Rule 14 textual loop — "keymap" explicit naming | **Not modified** — save-system.md is Approved. Registry entry `meta_settings_debounce_ms` already locks Input↔Save contract; textual alignment cosmetic. Fix at next Save revision when the file is touched for other reasons. | (no change — see entities.yaml `meta_settings_debounce_ms` referenced_by for live contract) |
| 6 | Rule 10(a) "活跃" → "已连接" + multi-gamepad policy pointer | Text: "任一已连接 gamepad 断开 (... 单人游戏中所有已连接 gamepad 等价于 action dispatch,无 per-player 设备绑定 — 见 Edge 3.2)" | Rule 10(a) |
| 7 | Rule 7 + Edge 8.2 call-site contract pointer | Added to Rule 7: "Caller contract(零 gap 要求): `acquire_modal_lock` / `release_modal_lock` 必须从 `_input` 或 `set_deferred` 调度,不可从 `_process` 直接调 — 否则该帧 `_input` 已在无锁态运行,留一帧 unguarded 窗口(见 Edge 8.2)" | Rule 7 |
| 8 | F3 third clause — path holds at `KB_GAMEPAD` after lockout expires until mouse_delta > threshold | F3 formula reformatted with three clauses: (1) MOUSE conditions / (2) KB_GAMEPAD override / (3) "(unchanged) when lockout elapsed but no qualifying mouse_delta arrives — active_path holds at KB_GAMEPAD until next mouse motion > threshold"; Justification + Worked Example updated (t=200 lockout expires but path holds; t=210 mouse motion triggers MOUSE) | F3 (Formulas) |
| 9 | Edge 1 `deadzone_outer=1.0` wording — "saturation zone 退化至单点" | Text: "saturation zone 退化至单点,仅 raw `r = 1.0` 能精确命中输出 1.0(Godot float 精度下物理摇杆极少触达);典型 r=0.99 时输出 `≈0.988`,feel 上'推到底也不满'" | Edge 1 |
| 10 | Section C header "Detailed Design" → "Detailed Rules" | Compliance rename matching `/Users/huanghaibin/Workspace/games-studio/.claude/rules/design-docs.md` + `design/CLAUDE.md` standard | Section C header |

**Cross-document touches**: `design/gdd/systems-index.md` (status Input Handler: Designed → In Review; progress tracker; notes log). `design/gdd/input-handler.md` header **NOT** yet flipped to Approved — awaits fresh-session re-review.

**Status after revision**: In Review — awaits `/design-review design/gdd/input-handler.md --depth lean` in a fresh session (clean context, independent analysis).

---

## Review — 2026-04-24 (2nd lean, fresh session) — Verdict: APPROVED
Scope signal: **M**(与首轮一致 — 3 formulas / 9 dependents / 7 OQs 中 4 条延 ADR / 2 延 Polish / 1 延 Alpha)
Specialists: none(lean mode, single-session analysis)
Blocking items: 0 | Recommended: 5 | Nice-to-have: 2
Summary: 首轮 3 blocker(`KB_PAD` vs `KB_GAMEPAD` enum 统一 / Rule 6 post-deadzone `joystick_effective_axis` 比较 / `remap_cancelled` 2-arg + 3 reason enum)全部系统性闭环,无结构性问题残留。本轮新扫描发现的 Recommended 集中于"信号 firing rule 局部澄清"类局部文本修正(见下),不影响系统结构、不阻塞下游 #3-5 并行 design。GDD 已 implementation-ready,Input Handler Status 转 **Approved**。
Prior verdict resolved: **Yes**(首轮 NEEDS REVISION 3 blocker 全关闭,4/5 recommended 同 session 修,1 recommended + 2 nice-to-have 闭环或推迟确认)。

### Recommended(非阻塞,可在后续自然流程中消化)
1. `input_method_changed(method: InputMethod)` trigger 规则缺失 — 多处被消费(Tutorial / Accessibility Interaction / Edge 7.1 / AC-COMPAT-04 [RISK GUARD] / AC-A11Y-01)但无 Rule 定义何时 fire。建议补一句:最近一次合规事件 device category 变更时 fire,同类别重复不发。可在 ADR-XXXX dual-focus 实现阶段与 Rule 5(d) 一起清。
2. `FocusPath`(focus_path_changed)与 `InputMethod`(input_method_changed)enum 语义重叠未澄清 — 前者 {MOUSE, KB_GAMEPAD},后者 {KB_MOUSE, GAMEPAD};鼠标在两 enum 归属不对称。建议 Rule 5 加注释区分用途(仲裁 cursor 可见性 vs glyph 选择)。
3. `focused_node_changed(node: Control)` emission rule 缺失 — HUD Interaction 声明信号但无规则。implicit 假设"D-Pad 移焦时 fire",建议在 Rule 5 或 Interactions HUD 条目补明示。
4. Edge 9.1 Input↔Save 同订阅 `NOTIFICATION_WM_WINDOW_FOCUS_OUT` 但 ordering 未定契约 — 建议在 Scene & Day Flow #6 GDD 协调时锁 "Input reset 在 Save flush 之前"(或反之)。
5. Save Rule 14 "keymap" 文本命名未闭环 — entities.yaml `meta_settings_debounce_ms` 已锁 live contract,textual loop 是 cosmetic。**按首轮决议继续推迟至 Save 下次触碰时一并修**,不本轮重复。

### Nice-to-have
6. AC-COMPAT-05 [RISK GUARD] 混入 code-testable + visual sign-off — 建议拆为 AC-COMPAT-05a(`_focus_entered()` code assertion)+ AC-COMPAT-05b(`#C8963C` 焦点环 visual sign-off,可迁至 #13 HUD GDD)。
7. Rule 4 Anti-Pillar 3 守门与 F2 held-repeat 边界未辨 — F2 是 passive OS-like key-repeat(非 skill-based timing)。建议 Rule 4 补一句 "passive hold-repeat(如 keyboard key-repeat 等价)不在禁令范围"。

**后续消化路径**(non-blocking):
- Rec #1/#2/#3 → 推至 ADR-XXXX dual-focus 实现阶段(OQ-INP-03)顺手清
- Rec #4 → Scene & Day Flow #6 GDD(Order #6,Core Layer)协调时锁
- Rec #5 → 继续延至 Save 下次触碰
- Nice #6 → #13 HUD GDD(Order #13,Presentation Layer)写时一并修
- Nice #7 → 下次 Input Handler 触碰时 1 行 edit 清,或并入 ADR-XXXX

**Input Handler Status**: **Approved** — Foundation #3-5 (Localization Hooks / Audio Manager / Lighting & Visual State Controller) 并行 design 解锁。

---
