# ADR-0013: Archive 200 Cap Virtual Scroll

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | UI / Core(Control + ScrollContainer + lazy load) |
| **Knowledge Risk** | LOW(ScrollContainer + ItemList 4.0+ 稳定)|
| **References Consulted** | `docs/engine-reference/godot/modules/ui.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0003(三槽位 Save schema + archive 文件结构)|
| **Enables** | `#16 KPI Review UI` Archive screen 实施 |
| **Blocks** | Archive list UI coding(200 元素加载策略未定) |
| **Ordering Note** | P2 优先级第三 |

## Context

### Problem Statement

`#1 Save System` Rule 23 + `#12 Run Meta` 锁定 `archive_hard_cap_count = 200` runs(FIFO 驱逐)。Archive 浏览屏(`#16` 第三屏)展示玩家全部历代 Run。

200 个 archive 文件如全部预加载 → 启动期 200 × ~5KB = 1MB I/O(可能影响 P5 5 秒进入)+ 200 个 Control 节点同时实例化 → UI 卡顿。

需要决策:
- 启动加载策略(lazy / 全 / 缓存索引)
- ScrollContainer 渲染策略(全实例 / virtual scroll)
- 删除策略(P3 仪式感:禁批量删,只 FIFO 自动驱逐)

### Constraints

- `archive_hard_cap_count = 200` registry 锁(`#1 Rule 23`)
- 启动期 P5 5 秒进入(ADR-0002 Rule 4)
- Archive 浏览屏属于 sub-mode 切换(MAIN_MENU → ARCHIVE)— 玩家主动进入,可承受 ~500ms 加载
- P3 仪式感:Archive 是"墓园"— 不可批量删 / 修改 / 重命名,只读浏览

### Requirements

- 启动期不全加载 200 archive(影响 P5)
- Archive 浏览屏进入时 ~500ms 内显示 list
- 200 元素 ScrollContainer 性能 ≥ 60fps
- 玩家点击单 archive → ~100ms 内显示详情

## Decision

### 1. 索引文件 + 懒加载

启动期仅加载 `meta.save` 中的 archive **索引**(轻量,~5KB):

```json
// meta.save 节选
{
  "subsystems": {
    "run_meta": {
      "archive_index": [
        {"run_id": "0001", "month": 3, "end_reason": "kpi_fail_3", "timestamp": 1714234567},
        {"run_id": "0002", "month": 5, "end_reason": "kpi_overflow", "timestamp": 1714298765},
        ...
        {"run_id": "0200", "month": 12, "end_reason": "promoted_leave", "timestamp": 1715000000}
      ]
    }
  }
}
```

具体 archive 内容(`user://save/archive/[run_id].save`)按需加载(玩家点击单条目时):

```gdscript
# `#12 RunMetaSystem` archive 索引
var archive_index: Array[ArchiveIndexEntry] = []  # 启动期已加载

func get_archive_detail(run_id: String) -> ArchiveDetail:
    # 懒加载
    if archive_detail_cache.has(run_id):
        return archive_detail_cache[run_id]
    var path := "user://save/archive/%s.save" % run_id
    var detail := SaveStateLoader.load_archive_detail(path)
    archive_detail_cache[run_id] = detail
    return detail
```

### 2. ScrollContainer + 实际渲染策略

200 元素 ScrollContainer:

**策略 A**(选用):**全实例 + 静态 Control 节点 + ScrollContainer 自动 culling**

```gdscript
# `#16` archive_screen.gd
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var v_box: VBoxContainer = $ScrollContainer/VBoxContainer

func _on_archive_screen_entered() -> void:
    # 只读 archive_index(meta.save 已加载,无 I/O)
    for entry in RunMetaSystem.archive_index:
        var card := preload("res://scenes/ui/archive_card.tscn").instantiate()
        card.setup(entry)  # 仅显示 month + end_reason + timestamp
        v_box.add_child(card)
    # ScrollContainer 自动 culling: 不可见 child 不参与 _draw / _process
```

**理由**:200 个 simple Control(~50 byte 内存 / 节点)= 10KB 内存,可接受;ScrollContainer 自动 culling 处理性能。

### 3. 单 archive 详情懒加载

```gdscript
# archive_card.gd
func _on_pressed() -> void:
    # 玩家点击 → 懒加载详情
    var detail := RunMetaSystem.get_archive_detail(entry.run_id)
    archive_detail_screen.show_with_detail(detail)
```

详情屏(单 archive 完整信息)~5KB 加载 + UI 实例化 ~100ms 内可见。

### 4. P3 仪式感守门:禁批量删

```gdscript
# `#12 RunMetaSystem` 严禁:
# - delete_archive(run_id)  → 不实施
# - clear_all_archives()    → 不实施

# 仅允许:
# - FIFO 自动驱逐(超 200 时自动删除最旧 archive_index 条目 + .save 文件)
func _enforce_archive_cap() -> void:
    while archive_index.size() > 200:
        var oldest := archive_index.pop_front()
        var path := "user://save/archive/%s.save" % oldest.run_id
        DirAccess.remove_absolute(path)
```

### 5. UI 排序 + 筛选

- 默认排序:**最新 → 最旧**(timestamp desc)
- 筛选:无(P3 仪式感 — 不让玩家"挑选"喜欢的 Run)
- 搜索:无(同上)

玩家滚动浏览 — 接受 archive 是"线性时间序列"。

### Architecture Diagram

```
启动期:
  meta.save 加载 → archive_index Array[200] (~5KB)
  
Archive 浏览屏进入:
  for entry in archive_index:
    instantiate ArchiveCard (节点,~50 byte)
  ScrollContainer 自动 culling
  → ~500ms 内显示 list
  
玩家点击单 archive:
  懒加载 user://save/archive/[run_id].save (~5KB I/O)
  → ~100ms 内显示详情
  
驱逐:
  archive_index.size() > 200 → pop_front() + 删 .save
  禁 batch delete / clear all (P3)
```

## Alternatives Considered

### Alternative 1: 全加载 200 archive 详情

- **Pros**: 简单 / 玩家点击立即显示
- **Cons**: 启动期 1MB I/O 影响 P5 + 内存 1MB 持续占用
- **Rejection**: 启动期影响

### Alternative 2: Virtual scroll(自实现 culling + recycle)

- **Pros**: 极致性能(只渲染可见 ~10 元素)
- **Cons**: 实施复杂 + Godot ScrollContainer 已自动 culling + 200 元素 scope 不需要
- **Rejection**: 过度工程

### Alternative 3: 允许批量删除 + 搜索

- **Pros**: 玩家"管理"自由
- **Cons**: 违反 P3 仪式感(墓园不该被"管理")
- **Rejection**: P3 主轨

### Alternative 4: 200 cap 升至 1000

- **Pros**: 玩家有更多 history
- **Cons**: 200 已 super-player 容量(每 Run ~1 小时,200 = 200 小时);存档管理 UX 退化
- **Rejection**: 200 已合适

## Consequences

### Positive

- 启动期 P5 5 秒进入不受 archive 影响(只加 5KB index)
- Archive 浏览屏 ~500ms 内显示 200 元素
- 单 archive 详情 ~100ms 懒加载
- P3 仪式感守(墓园只读,FIFO 驱逐,无批量管理)
- 内存占用可控(index 5KB + 已加载详情 cache 按需)

### Negative

- 玩家想批量整理 archive 时无法(P3 设计目标 — 接受)
- ScrollContainer 200 元素初次实例化 ~500ms(玩家可感知)
  - Mitigation: progress indicator + entrance fade-in 0.5s 掩盖

### Risks

- **R-A13-1**: 200 元素 ScrollContainer 实例化超 1 秒
  - **Mitigation**: 实测 OQ-A13-PERF-01;如超,改批量实例化(每帧 50 个)+ progress bar
- **R-A13-2**: archive_detail_cache 内存增长无上限
  - **Mitigation**: LRU cache,最多保 20 个详情(~100KB)

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#1 Save` Rule 23 | archive 200 cap FIFO | `_enforce_archive_cap()` |
| `#12 Run Meta` Rule 1 | archive 三槽位 | archive_index + .save 文件 |
| `#16 KPI Review UI` Section H AC | Archive 浏览屏 ~500ms 加载 | 索引 + 懒加载 |
| Pillar 3 死亡叙事 | Archive 是墓园 | 禁批量删 + 禁搜索 + 线性序列 |

## Performance Implications

- **CPU**: 启动期 0 影响;Archive 屏进入 ~500ms 实例化;单 archive 详情 ~100ms
- **Memory**: archive_index 5KB / detail_cache LRU ~100KB
- **Load Time**: 启动期 0;Archive 屏 ~500ms
- **Network**: N/A

## Migration Plan

无现有代码:
1. `#12 RunMetaSystem` archive_index Array[ArchiveIndexEntry] 实施
2. `#16 ArchiveScreen` ScrollContainer + ArchiveCard scene 实施
3. archive_detail_cache LRU(20 entry cap)实施
4. FIFO 驱逐 `_enforce_archive_cap()` 在 `run_ended` 时调用
5. 实测 OQ-A13-PERF-01

## Validation Criteria

- 启动期 archive 加载 ≤ 5KB I/O(profiler 验证)
- Archive 屏进入 ~500ms 内显示 200 list(性能测试)
- 单 archive 详情 ~100ms 显示(集成测试)
- 200 cap FIFO 驱逐正确(单元测试 fixture)
- 禁批量删 / clear all(代码审查 — 无对应 API)

## Related Decisions

- ADR-0003 Save Format(三槽位 + archive 文件结构)
- `#1 Save System` Rule 23
- `#12 Run Meta` Rule 1
- `#16 KPI Review UI` Archive 浏览屏
- entities.yaml(`archive_hard_cap_count = 200`)
