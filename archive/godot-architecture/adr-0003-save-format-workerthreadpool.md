# ADR-0003: Save Format + WorkerThreadPool Strategy

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core(Save/Load 持久化 + Threading) |
| **Knowledge Risk** | MEDIUM(`FileAccess.store_*` 4.4 返回 bool;`duplicate_deep()` 4.5 引入但本 ADR 不依赖)|
| **References Consulted** | `docs/engine-reference/godot/breaking-changes.md` 4.3→4.4 / `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | `FileAccess.store_*` 返回 bool(4.4)— 工具脚本须校验返回值 |
| **Verification Required** | OQ-03 HDD+AV p99 实测(Save System #1) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0002(Autoload Init Order — Save Autoload init 顺序确认) |
| **Enables** | ADR-0006 Dismissal/GAMEOVER(meta.run_ended 原子写依赖 Save schema)+ ADR-0009 Event Schema(event_history Save 持久化)|
| **Blocks** | 全 game-state 持久化 coding(无统一 Save schema 各系统无法序列化) |
| **Ordering Note** | P0 优先级第三 |

## Context

### Problem Statement

20 GDD 中 8+ 系统需 Save 持久化:Save schema(meta + current_run + archive 三槽位)+ 12 registry constants 跨 GDD 引用 + Run Meta `meta.run_ended` 原子写在 GAMEOVER 1500ms 演出**之前**(R-AP-2 + R-KPI-2 守门)+ ARCHIVING 5 步事务(同步主线程 < 50ms)。

格式 / 路径 / 主线程边界 / WorkerThreadPool 使用规约必须统一,否则各系统各自实现致 race。

### Constraints

- Save System #1 已 Approved(`/design-review` 3rd lean PASS)
- `current_schema_version = 1` registry 锁定 + MVP 不支持迁移(VS 起 `_migrate_vN_to_vN+1` 链)
- `autosave_perf_hard_ceiling_ms = 50` registry 锁(单次 autosave 主线程影响 ≤ 50ms HDD+AV p99)
- `archive_hard_cap_count = 200` 硬上限 + FIFO 驱逐(P3 仪式感约束 — 禁批量删)
- `final_transition_duration_ms = 1500` GAMEOVER 离职证明硬上限
- WorkerThreadPool 工作线程**禁止** SceneTree / Node API 调用(Godot 4.x 限制)

### Requirements

- 三槽位序列化:`meta.save`(全局)/ `current_run.save`(当前 Run)/ `archive/[run_id].save`(历代)
- WorkerThreadPool 异步 autosave + 主线程 ARCHIVING 同步事务
- `meta.run_ended = true` 原子 fsync **先于** GAMEOVER 1500ms 演出启动(防 Alt+F4 续命)
- JSON 格式 + Resource lazy parse(writer / 工程师可用纯文本编辑)
- 8+ 系统各自 sub-schema 随 `current_schema_version` 演进

## Decision

### 1. 三槽位 Save 文件

```
user://save/
├── meta.save              # 全局元数据(玩家设置 + 跨 Run unlock + run_ended flag)
├── current_run.save       # 当前活跃 Run(仅 1 个)
└── archive/
    ├── 0001.save          # 历代 Run(FIFO 200 cap)
    ├── 0002.save
    └── ...
```

### 2. JSON-primary 格式 + Lazy Parse

写盘格式 = JSON(`JSON.stringify(state)`),运行时构造 `SaveState extends Resource` 强类型 wrapper(同 `#10` Event Script ADR-0009 模式)。

```gdscript
class_name SaveStateLoader
extends RefCounted

static func load_meta() -> MetaSaveState:
    var path := "user://save/meta.save"
    if not FileAccess.file_exists(path):
        return MetaSaveState.new()  # default
    var f := FileAccess.open(path, FileAccess.READ)
    var json_text := f.get_as_text()
    var dict := JSON.parse_string(json_text) as Dictionary
    var state := MetaSaveState.new()
    state.deserialize(dict)
    return state

static func save_meta_async(state: MetaSaveState) -> void:
    # WorkerThreadPool 异步写盘
    var dict := state.serialize()
    var json_text := JSON.stringify(dict)
    WorkerThreadPool.add_task(
        func() -> void:
            var f := FileAccess.open("user://save/meta.save", FileAccess.WRITE)
            var ok := f.store_string(json_text)  # 4.4+ 返回 bool
            assert(ok, "meta save write failed")
            f.close()
    )
```

### 3. WorkerThreadPool vs 主线程边界

| 操作 | 线程 | 理由 |
|------|------|------|
| `autosave` 触发(per AP 消耗 / settings 防抖)| WorkerThreadPool | 主线程 ≤ 50ms 影响 |
| `current_run.save` 周期写盘 | WorkerThreadPool | 同上 |
| `meta.run_ended = true` 原子 fsync | **主线程同步**(ARCHIVING 5 步事务一部分)| GAMEOVER 必须先持久化才进 1500ms 演出(R-AP-2 守门)|
| ARCHIVING 5 步事务(GAMEOVER 后)| **主线程同步** | Save Rule 9 + Rule 21 锁;< 50ms 总耗时 |
| Archive 列表展示读取 | 主线程同步 | UI 立即响应 |
| `meta.save` 启动期 load | **主线程同步**(阻塞)| HDD+AV p99 ≤ 50ms ceiling |

### 4. Sub-schema 模式(8+ 系统各自 own)

```json
{
  "schema_version": 1,
  "subsystems": {
    "save": { "snapshot_id": 142, "last_save_timestamp": 1714234567 },
    "scene_flow": { "current_sub_mode": "ACTION_DAY", "month_index": 3, "current_day": 12 },
    "ap_economy": {
      "current_ap": 5, "max_ap_today": 8, "current_energy": 65,
      "overtime_used_this_month": 4,
      "hero_card_played_this_month": 2,
      "overage_card_played_this_month": 1
    },
    "npc_relationship": {
      "LISA": { "score": 28, "flags": {"is_potential_jumper": true}, "lifecycle_state": "ACTIVE" },
      "BOSS": { "score": -5, "flags": {}, "lifecycle_state": "ACTIVE" },
      ...
    },
    "kpi_system": {
      "monthly_threshold": 142, "actual_kpi_history": [102, 118, 130],
      "settlement_locked": false
    },
    "event_script": {
      "event_history": ["LISA_LUNCH_DILEMMA"],
      "cooldown_map": {"LISA_LUNCH_DILEMMA": 18},
      "flag_dict": {},
      "morning_blacklist": ["BOSS_WEEKLY_TALK"]
    },
    "run_meta": {
      "run_count": 13, "current_run_month": 3,
      "unlocks": {"codex.hr_manual_page_3": true},
      "archive": [...],
      "hr_word_library": ["EVAL.ROOKIE.PASS.M1", ...]
    },
    "tutorial": { "tutorial_completed": false, "tutorial_skip_flag": false }
  }
}
```

### 5. `meta.run_ended` 原子写时序(R-AP-2 + R-KPI-2 守门)

```gdscript
# scene_day_flow_controller.gd Rule 11 R6 mitigation
func _trigger_game_over(reason: String, month: int) -> void:
    # 步骤 1: 主线程同步原子写 meta.run_ended
    var meta := SaveSystem.load_meta()
    meta.run_ended = true
    meta.end_reason = reason
    SaveSystem.save_meta_sync(meta)  # 主线程同步,fsync
    # 步骤 2: 启动 1500ms GAMEOVER transition(已不可逆)
    settlement_locked = true
    emit game_over_triggered(reason, month)
    # 步骤 3: ARCHIVING 5 步事务(主线程同步,< 50ms)
    SaveSystem.archive_current_run()
```

防 Alt+F4 续命:`meta.run_ended` 在 transition 启动**前**已落盘(原子 fsync)。

### Architecture Diagram

```
┌─────────────────────────────────────────┐
│  Main Thread                            │
│  ┌────────────────────────────────────┐ │
│  │ Game Loop                          │ │
│  │   - autosave trigger → submit task │ │
│  │   - meta load (sync, ≤50ms)        │ │
│  │   - meta.run_ended fsync (sync)    │ │
│  │   - ARCHIVING 5 步事务 (sync,<50ms)│ │
│  └────────────────────────────────────┘ │
│                  │                       │
│                  ▼                       │
│  ┌────────────────────────────────────┐ │
│  │ WorkerThreadPool                   │ │
│  │   - autosave 写盘 (async)           │ │
│  │   - current_run.save 周期写盘 (async)│ │
│  └────────────────────────────────────┘ │
│                  │                       │
│                  ▼                       │
│  user://save/                           │
│  ├── meta.save                          │
│  ├── current_run.save                   │
│  └── archive/[run_id].save              │
└─────────────────────────────────────────┘

主线程同步:meta load / meta.run_ended fsync / ARCHIVING 5 步
异步 worker:autosave / current_run.save 周期写盘
```

## Alternatives Considered

### Alternative 1: tres + ResourceSaver(全 Resource 序列化)

- **Pros**: Godot 原生支持 / 类型安全 / Inspector 可视化
- **Cons**: 二进制格式 git diff 不友好 / 修复存档需 Godot;writer 不能直接看;`duplicate_deep()` 4.5+ 行为依赖
- **Rejection**: JSON 更灵活 + 跨工具友好

### Alternative 2: SQLite 嵌入式数据库

- **Pros**: 强类型 / 查询能力
- **Cons**: 引入依赖 / 增加 binary size / 单机游戏 overkill
- **Rejection**: 200 cap archive + 单 Run schema 用 JSON 已足够

### Alternative 3: 全主线程同步(无 WorkerThreadPool)

- **Pros**: 简单
- **Cons**: 50ms 主线程影响破 P5 5 秒进入 + 60fps 帧预算
- **Rejection**: WorkerThreadPool 是 P5 守门必需

## Consequences

### Positive

- 三槽位清晰职责(meta 跨 Run / current_run 当前 / archive 历代)
- WorkerThreadPool 主线程 ≤ 0ms 影响(autosave 异步)
- meta.run_ended 原子写 + 主线程同步 → R-AP-2 + R-KPI-2 守门
- JSON 格式 git diff 可读 + writer 可独立编辑
- Sub-schema 8+ 系统各自维护 + `current_schema_version` 单调递增

### Negative

- WorkerThreadPool 限制(禁 SceneTree API)→ worker 内序列化必须 self-contained
- ARCHIVING 5 步事务主线程同步(GAMEOVER 时玩家可能感受到 < 50ms 卡顿)
  - **Mitigation**: ARCHIVING 在 1500ms transition 演出**期间**执行(玩家专注于离职证明文本,不感受到主线程卡顿)

### Risks

- **R-A3-1**: HDD+AV 扫描场景 meta load 超 50ms ceiling
  - **Mitigation**: OQ-03 实测(Polish 阶段 Save AC-PERF-01 p99 验证);若超 50ms,降级 — `meta.save` 拆分为 `meta_essential.save`(< 4KB)+ `meta_archive.save`(异步加载)
- **R-A3-2**: Worker thread 写盘失败(磁盘满 / 权限错)
  - **Mitigation**: Save Rule 18 retry backoff;3 次失败后通知玩家"存档失败"

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#1 Save System` Rule 7 | autosave WorkerThreadPool | worker_thread_pool 异步 |
| `#1 Rule 9` | ARCHIVING 5 步事务主线程同步 | < 50ms |
| `#1 Rule 21` | final_transition_duration_ms = 1500ms | meta.run_ended 先于 transition |
| `#1 Rule 22` | content-only unlocks | `meta.unlocks` 5 类 key 白名单 |
| `#1 Rule 23` | archive 200 cap FIFO | `archive_hard_cap_count` registry |
| `#7 R-AP-2` | meta.run_ended 优先持久化 | 主线程同步 fsync |
| `#9 R-KPI-2` | settlement_locked 顺序 | meta.run_ended → settlement_locked → transition |
| `#12 Run Meta` Rule 1 | 三槽位 Save schema | meta.unlocks + archive[] + run_count |

## Performance Implications

- **CPU**: autosave WorkerThreadPool ≤ 0ms 主线程;ARCHIVING ≤ 50ms 主线程
- **Memory**: meta.save < 4KB / current_run.save ~ 50KB / archive 200 × ~5KB = ~1MB
- **Load Time**: meta load ≤ 50ms(SSD typical < 10ms,HDD+AV p99 < 50ms ceiling)
- **Network**: N/A

## Migration Plan

无现有代码,从零实施:
1. `SaveSystem` Autoload 实现(三槽位 + WorkerThreadPool 路径)
2. 8+ 系统各自 sub-schema serialize/deserialize 接口
3. `meta.run_ended` 原子 fsync + ARCHIVING 5 步事务实现
4. Save Rule 18 retry backoff 实现
5. CI 单元测试覆盖三槽位 + 异常场景(Edge 1.4 / Edge 5.1 / Edge 8.1 等)

## Validation Criteria

- 主线程 autosave 影响 ≤ 0ms(profiler 实测,worker 异步)
- ARCHIVING 5 步事务 < 50ms 主线程(自动化 perf test)
- meta load HDD+AV p99 < 50ms(Save AC-PERF-01)
- Alt+F4 GAMEOVER 续命路径关闭(crash recovery fixture R-AP-2)

## Related Decisions

- ADR-0002 Autoload Init Order(Save Autoload 顺序锁定)
- ADR-0006 Dismissal/GAMEOVER Path(meta.run_ended 写时序)
- ADR-0009 Event Schema(event_history Save 持久化)
- `#1 Save System` GDD(Approved 3rd lean review)
- entities.yaml(`autosave_perf_hard_ceiling_ms` / `archive_hard_cap_count` / `current_schema_version`)
