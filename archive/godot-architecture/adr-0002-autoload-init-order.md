# ADR-0002: Autoload Init Order + Scene Tree Architecture

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core / Scripting(Autoload + SceneTree + Process Mode) |
| **Knowledge Risk** | **HIGH**(post-cutoff:`@abstract` 4.5 / SceneTree 3D interpolation 重构 4.5 / D3D12 default Win 4.6) |
| **References Consulted** | `docs/engine-reference/godot/breaking-changes.md` 4.4→4.5 + 4.5→4.6 / `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | `@abstract` (4.5+,LLM 截止 ~4.3) / `EditorDock`(4.6 可选)/ `change_scene_to_packed()` 4.5 SceneTree 重构后 2D 路径性能(待 OQ-SDF-ENG-02 实测) |
| **Verification Required** | OQ-SDF-ENG-01 `PROCESS_MODE_ALWAYS` 在 4.6 SceneTree.paused 实测 / OQ-SDF-ENG-02 `change_scene_to_packed()` 性能基准 / OQ-SDF-ENG-03 `@abstract` 语法实测 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 Signal Ownership Matrix(`scene_state_changed` 总线 owner 已定 = `#6`) |
| **Enables** | ADR-0003 Save Format(WorkerThreadPool 主线程边界)+ ADR-0009 Event Schema(`@abstract EventEffect` 基类)|
| **Blocks** | 全 Foundation/Core 系统 coding 启动(Autoload 顺序未定无法 wire system)|
| **Ordering Note** | P0 优先级第二;ADR-0001 Accepted 后立即 |

## Context

### Problem Statement

20 GDD 共需要 6 个 Autoload 单例(Save / Localization / Audio / Lighting / Input / SceneDayFlow),Godot 按 `project.godot` `[autoload]` 顺序串行 init。`#6 Scene Flow` Rule 4 启动序列依赖 Foundation 5 系统全部 ready,任何顺序错位 → 死锁或 race。

3 OQ 实测项(OQ-SDF-ENG-01/02/03)在本 ADR 阶段须先初步决策(实测延 Pre-Production /prototype),不阻塞 ADR Accepted。

### Constraints

- Godot 4.6 Autoload 按 `project.godot` 声明顺序串行 init `_init()` → `_ready()`
- `_init()` 中无法访问 SceneTree(`get_tree()` 返 null)
- `process_mode = PROCESS_MODE_INHERIT` 默认在 SceneTree.paused 时 `_process()` 停止
- SceneTree 4.5 内部 3D interpolation 重构(本项目 2D 不直接受影响,但 SceneTree 行为细节有差异)
- `change_scene_to_packed()` 性能在 4.5 重构后实测基准未知
- `@abstract` 4.5 引入,LLM 训练数据预 4.3 不知

### Requirements

- 6 Autoload init 顺序确定 + bool ready 检查避免 race
- `#6 SceneDayFlow` 持续运行(`PROCESS_MODE_ALWAYS`)即使全局 paused
- watchdog Timer 节点在 `SceneTree.paused = true` 期间挂起(`PAUSE_INHERIT`)
- 启动序列 P5 5 秒进入承诺(meta load + payload + 4 _mark_ready ≤ 250ms 必要预算)
- `change_scene_to_packed()` 必须预加载(`ResourceLoader.load_threaded_request()`)

## Decision

### 1. `[autoload]` 列表声明顺序(`project.godot`)

```
[autoload]
SaveSystem="*res://src/foundation/save/save_system.gd"
LocalizationHooks="*res://src/foundation/localization/localization_hooks.gd"
AudioManager="*res://src/foundation/audio/audio_manager.gd"
LightingController="*res://src/foundation/lighting/lighting_controller.gd"
InputHandler="*res://src/foundation/input/input_handler.gd"
SceneDayFlowController="*res://src/core/scene_day_flow/scene_day_flow_controller.gd"
TutorialState="*res://src/feature/tutorial/tutorial_state.gd"
AccessibilitySettings="*res://src/polish/accessibility/accessibility_settings.gd"
```

**关键约束**: `SceneDayFlowController` 必须**最后一位**(C-ENG-01),`TutorialState` 和 `AccessibilitySettings` 在其后(VS / Alpha tier 不影响 Foundation)。

### 2. Init 顺序 + bool ready 检查(`#6` Rule 4 R1 mitigation)

```gdscript
# scene_day_flow_controller.gd (Autoload, 末位)
extends Node

func _init() -> void:
    # 禁止跨单例调用 — get_tree() 返 null
    pass

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS  # C-ENG-02
    # 启动序列 — bool ready 检查先于 await
    await _wait_foundation_ready()
    _start_loading_sequence()

func _wait_foundation_ready() -> void:
    if not SaveSystem.is_ready:
        await SaveSystem._mark_ready
    if not LocalizationHooks.is_ready:
        await LocalizationHooks._mark_ready
    if not AudioManager.is_ready:
        await AudioManager._mark_ready
    if not LightingController.is_ready:
        await LightingController._mark_ready
    if not InputHandler.is_ready:
        await InputHandler._mark_ready
    # 全 ready 进入 LOADING → MAIN_MENU 转换
```

### 3. `process_mode` 配置规约

| 节点 | process_mode | 理由 |
|------|--------------|------|
| `SceneDayFlowController`(Autoload) | `PROCESS_MODE_ALWAYS`(C-ENG-02) | 全局 paused 期间 watchdog escalation / Save flush 调度不中断 |
| Loc 30s watchdog Timer 节点 | `PAUSE_INHERIT` | pause 期间挂起(`#6 Rule 6` game-time vs wall-clock 边界) |
| Lighting / Audio LOADING watchdog Timer | `PAUSE_INHERIT` | 同上 |
| Save autosave WorkerThreadPool task | N/A(走 thread) | wall-clock,不受 SceneTree.paused 影响 |
| Audio fade Tween / Lighting palette swap Tween | `PROCESS_MODE_ALWAYS` | 跨 pause 边界继续 fade / pause_tween() 单独控制(R3 mitigation) |

### 4. `change_scene_to_packed()` 预加载守门(C-ENG-05)

```gdscript
# Loading Scene 退出路径
func _transition_to_main_menu() -> void:
    # 必须 ResourceLoader.load_threaded_request 预加载
    ResourceLoader.load_threaded_request("res://scenes/main_menu.tscn")
    # 等待加载完成
    while ResourceLoader.load_threaded_get_status("res://scenes/main_menu.tscn") != ResourceLoader.THREAD_LOAD_LOADED:
        await get_tree().process_frame
    var packed = ResourceLoader.load_threaded_get("res://scenes/main_menu.tscn")
    get_tree().change_scene_to_packed(packed)
```

**禁止**: 同步 `change_scene_to_file()`(实测 80-200ms 卡顿,违反 P5 5 秒进入)。

### 5. `@abstract` 4.5+ 基类

```gdscript
# scene_day_flow/states/base_sub_mode_state.gd
@abstract
class_name BaseSubModeState

@abstract
func on_enter() -> void:
    pass

@abstract
func on_exit() -> void:
    pass

@abstract
func tick(delta_units: int) -> void:
    pass
```

各具体 State(MainMenuState / ActionDayState / ...)须 `extends BaseSubModeState` 并 override 三方法。漏 override → 编辑器实例化报错 + 运行时 `@abstract` 报错(C-ENG-09)。

同模式应用于 `EventEffect`(ADR-0009 详细)。

### Architecture Diagram

```
project.godot [autoload] 顺序:
  Save → Localization → Audio → Lighting → Input → SceneDayFlow → (Tutorial, Accessibility)

启动序列 (Rule 4):
  T+0ms     Splash + Loading Scene 实例化
  T+~50ms   SaveSystem 同步 meta load (HDD+AV ≤50ms ceiling)
  T+~50ms   并行注入 payload (Loc parse + Audio preload + Lighting state + Input keymap)
  T+~250ms  4 Foundation _mark_ready 全部到达 (watchdog 10s/30s 兜底)
  T+~300ms  ResourceLoader.load_threaded_request(MainMenu.tscn)
  T+~400ms  change_scene_to_packed() → MAIN_MENU sub-mode
  
  P5 5000ms 总预算 ≈ 720ms 必要,缓冲 ≈ 4280ms
```

## Alternatives Considered

### Alternative 1: `SceneDayFlow` 不是 Autoload 而是 Scene Root Node

- **Pros**: 自然随 scene 切换;不需要 PROCESS_MODE_ALWAYS
- **Cons**: 跨 scene 持久化困难;scene 切换时需 emit `scene_state_changed`,但本身已被销毁 — race
- **Rejection**: 违反 `#6 Rule 1` "全游戏唯一 sub-mode 调度权"

### Alternative 2: 信号驱动 vs await pattern

- **Pros (signal)**: 解耦;不依赖 init 顺序
- **Cons**: 4 系统全 ready 信号合并复杂;await 更直观
- **Rejection**: bool ready 检查 + await 模式更易测;collisignal pattern 增加 race 风险

## Consequences

### Positive

- 6 Autoload init 顺序锁定,消除 race
- `PROCESS_MODE_ALWAYS` + `PAUSE_INHERIT` 二分清晰(`#6` 自身持续 / watchdog 挂起)
- `@abstract` 强制基类 override(防漏写 callback 静默空跑)
- `change_scene_to_packed()` 预加载守 P5 5 秒进入承诺

### Negative

- 6 Autoload 全部启动时间 ~250ms 必要,占 P5 5000ms 预算 5%(可接受)
- `@abstract` 是 4.5+ 特性,LLM 知识缺口需文档实测确认(OQ-SDF-ENG-03)

### Risks

- **R-A2-1**: `@abstract` 4.5 行为与文档不符 → 编辑器报错但运行时静默
  - **Mitigation**: 实测验证(`tools/abstract_test.tscn` minimal repro)+ 若不符 fallback 为运行时 `assert(self.has_method("on_enter"))`
- **R-A2-2**: `change_scene_to_packed()` 4.5 SceneTree 重构后 2D 路径性能未知
  - **Mitigation**: 实测 OQ-SDF-ENG-02(profiler 测量 2D 大场景切换);若 > 100ms,降级方案 — Loading Scene 不切换,仅显隐节点

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#6 Scene Flow` Rule 1 | Autoload `/root/SceneDayFlowController` | 末位声明 |
| `#6 Rule 4` | 启动序列 5 系统 _mark_ready | bool ready 检查 + await |
| `#6 Rule 6` | pause game-time vs wall-clock | PROCESS_MODE_ALWAYS + PAUSE_INHERIT 二分 |
| `#6 C-ENG-01..10` | 10 Engine Integration Rules | 全部落地 |
| `#10 Event Script` Rule 18 | `@abstract EventEffect` 基类 | 同模式 |

## Performance Implications

- **CPU**: Autoload init 一次性 ~250ms(启动)+ 0 runtime overhead
- **Memory**: 6 Autoload 单例 ~1MB(各持 schema + state)
- **Load Time**: P5 5 秒进入承诺 ≈ 720ms 必要 + ~4280ms 缓冲(watchdog escalation)
- **Network**: N/A

## Migration Plan

无现有代码,从零实施:

1. `project.godot` `[autoload]` 段创建(顺序锁定)
2. 6 Autoload 单例骨架(`is_ready: bool` + `_mark_ready` signal + 各自 `_ready()` 实现)
3. `BaseSubModeState` `@abstract` + 8 sub-mode state 继承
4. Loading Scene 实现(预加载 + change_scene_to_packed)
5. 实测 OQ-SDF-ENG-01/02/03 → 若不符 fallback 路径

## Validation Criteria

- 启动至 MAIN_MENU 端到端 ≤ 5000ms p95(P5 守门,自动化 perf test)
- 6 Autoload 全部 init 完成 + `_mark_ready` 信号到达 ≤ 250ms 必要时间
- `SceneDayFlow` 在 paused 期间仍 `_process` 调用(单元测试用 SceneTree pause fixture)
- `BaseSubModeState` 实例化报错(若 `@abstract` 4.5 实测 PASS)
- `change_scene_to_packed()` 切换 ≤ 200ms p95(若 4.5 性能 PASS)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(`#6` `scene_state_changed` 单 owner)
- ADR-0003 Save Format(WorkerThreadPool + 主线程 ARCHIVING 边界)
- ADR-0009 Event Schema(`@abstract EventEffect` 基类同模式)
- `#6 Scene Flow C-ENG-01..10`(Engine Integration Rules)
- `docs/engine-reference/godot/breaking-changes.md` 4.4→4.5 + 4.5→4.6
