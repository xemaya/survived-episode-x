# Story 006: Save System State Machine(6 States)

> **Epic**: save-system
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-001` + `TR-save-002`
**ADR Governing Implementation**: ADR-0003 Save Format + WorkerThreadPool Strategy
**ADR Decision Summary**:6 态状态机 — IDLE / SAVING / LOADING / ARCHIVING / MIGRATING / ERROR;转移合法性严守(`SAVING → LOADING` 禁;`LOADING → MIGRATING` MVP 阻塞;ARCHIVING 拒绝其他 I/O;`ERROR → IDLE` 需玩家确认)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 状态机用 GDScript enum + match;非 Godot StateMachine 节点(避免节点开销)。

**Control Manifest Rules**:
- Required: 状态机转移合法性自动化测试覆盖
- Forbidden: 直接跳 ERROR 不经中间态(必须经 SAVING/LOADING/ARCHIVING/MIGRATING 之一)

## Acceptance Criteria

- [ ] enum `SaveState { IDLE, SAVING, LOADING, ARCHIVING, MIGRATING, ERROR }`
- [ ] **AC-STATE-01** IDLE → SAVING → IDLE 合法路径
- [ ] **AC-STATE-02** SAVING → LOADING 禁止,返 `ERR_BUSY`;SAVING 完成回 IDLE 后 LOAD 才可接受
- [ ] **AC-STATE-03** MVP 下 `schema_version=0` 旧存档 LOADING 检测后**不**进入 MIGRATING,直接转 ERROR + 弹"存档来自旧版本"
- [ ] **AC-STATE-04** ARCHIVING 拒绝其他 I/O(autosave + load 请求被排队或拒绝;archive 不被打断)
- [ ] **AC-STATE-05** ERROR → IDLE 需玩家确认("重试" / "新局")
- [ ] **AC-STATE-06** 直接跳 ERROR(测试钩子)断言失败 + 日志错误;必须经中间态

## Implementation Notes

```gdscript
# save_system.gd
enum SaveState { IDLE, SAVING, LOADING, ARCHIVING, MIGRATING, ERROR }
var _state: SaveState = SaveState.IDLE
var _request_queue: Array = []

signal state_changed(from_state: SaveState, to_state: SaveState)

func _transition_to(new_state: SaveState) -> bool:
    var legal := _is_legal_transition(_state, new_state)
    if not legal:
        push_error("Illegal Save state transition: %s → %s" % [SaveState.keys()[_state], SaveState.keys()[new_state]])
        return false
    var old := _state
    _state = new_state
    emit_signal(&"state_changed", old, new_state)
    return true

func _is_legal_transition(from: SaveState, to: SaveState) -> bool:
    # IDLE → 任何
    if from == SaveState.IDLE: return true
    # IDLE → ERROR 必经中间态
    if to == SaveState.ERROR and from == SaveState.IDLE: return false
    # 任何中间态 → ERROR 合法
    if to == SaveState.ERROR: return true
    # SAVING → LOADING 禁
    if from == SaveState.SAVING and to == SaveState.LOADING: return false
    # ARCHIVING 拒绝其他 I/O
    if from == SaveState.ARCHIVING and to in [SaveState.SAVING, SaveState.LOADING]: return false
    # 默认回 IDLE 合法
    if to == SaveState.IDLE: return true
    return false

func request_load() -> Error:
    if _state != SaveState.IDLE:
        return ERR_BUSY  # SAVING / ARCHIVING 期间拒绝
    _transition_to(SaveState.LOADING)
    # ...
```

## Out of Scope

- Story 007:ARCHIVING 5 步事务细节
- Story 014:ERROR 弹窗 UI

## QA Test Cases

- **AC-STATE-01**:Given IDLE;When autosave;Then 序列 IDLE → SAVING → IDLE 出现在状态日志
- **AC-STATE-02**:Given SAVING;When 注入 load 请求;Then 返 `ERR_BUSY`,状态不进 LOADING
- **AC-STATE-03**:Given schema_version=0 旧存档;When 点"继续";Then LOADING → ERROR + "存档来自旧版本"对话框(无 MIGRATING 中间态)
- **AC-STATE-04**:Given ARCHIVING 中;When 注入 autosave + load;Then 两请求被排队或拒绝;archive 不被打断
- **AC-STATE-05**:Given ERROR(磁盘已满);When 玩家点"重试" / "新局";Then 回 IDLE
- **AC-STATE-06**:Given IDLE;When 测试钩子直接跳 ERROR;Then assert 失败 + 日志错误

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/state_machine_test.gd`
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001(三槽位)+ Story 002(autosave)+ Story 003(原子写)
- Unlocks: Story 007(ARCHIVING)+ Story 013(crash recovery)+ Story 014(ERROR 弹窗)

## Completion Notes
**Completed**: 2026-05-01
**Criteria**: 7/7 passing
**Deviations**:
  1. ADR-0003 Status=Proposed — lean-mode 等同 Accepted(与 Stories 001-005 同前例)
  2. `_transition_to`/`_is_legal_transition` 私有方法被测试直接调用 — whitebox integration test，有意为之
  3. Code review 修复 3 项：BLOCKING 跨线程读取（`_submit_worker` hwm 参数传递消除 data race）+ LOW 测试 LOADING 中间态断言补充 + HIGH 竞态保护注释
**Test Evidence**: Integration — `tests/integration/save/state_machine_test.gd`(387 行 / 9 test functions)
**Code Review**: APPROVED WITH FIXES(lean mode — godot-gdscript-specialist + qa-tester)
