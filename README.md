# 《活过第 X 集》(Survived Episode X)

像素风反向 KPI 中国职场生存模拟。

> 你扮演中年老油条**陈笑天**——爹妈起名"笑傲天下众生"，长大成 32 岁产品助理。每天 8 个时间槽要在"被开除"和"太优秀被晋升处刑"之间走钢丝。**胜利条件不是升职加薪，是活过 52 集（一年）**。

参考标杆：《大多数》《死亡与税收》《Papers Please》《破事精英》《Reigns》。

---

## 当前状态

**Phase**：P5 准备启动（引擎层）。

| 阶段 | 状态 |
|---|---|
| Design slice | ✅ 10 NPC + 60 daily choices + 4 episodes outline ready |
| 引擎选择 | ✅ TypeScript + Vite + PixiJS + Tauri + Preact + Ink + inkjs |
| Markdown → .ink 翻译 | ⏳ 进行中（worker clones） |
| inkjs runtime + diegetic UI | ⏳ P5 待启动 |

---

## 项目结构

```
.
├── design/
│   ├── vertical-slice/   ★ 当前 design 主战场（series structure / 10 NPC / 60 daily choices / 4 episodes）
│   ├── gdd/              早期 GDD（部分仍有效）
│   ├── research/         设计研究（KPI 公式 / AP 决策空间）
│   ├── registry/         数值常量
│   ├── art/              美术规范
│   └── assets/           Asset manifest
├── game/                 ★ TS 工程（P0-P4 ready，P5 待启动）
│   ├── src/              TS 源码（Save/FSM/KPI/Effort/Energy/Archive 已实现）
│   ├── src-tauri/        Tauri 桌面打包
│   ├── tests/            Vitest 测试
│   └── ...
├── assets/sprites/       NPC + 工位 + UI sprite assets
├── tools/                Python 工具（cut_sprites / gen_image）
├── docs/superpowers/     引擎切换决策 spec + P0-P4 实现 plans
├── archive/              ⚠️ Godot 时代 + opening-video + 早期 TS 设计 — **默认不读**
├── CLAUDE.md             给 Claude Code 的项目指令
└── README.md             本文件
```

---

## 历史

- **Origin**：Godot 4.6 / GDScript（"paper-done" 18.6k 行 GDScript 从未跑过——已归档到 `archive/godot-architecture/` + `archive/godot-stories/`）
- **2026-05-03**：引擎切换到 TS + Vite + PixiJS + Tauri，写了 P0-P4
- **2026-05-05**：玩 P4 后判断"游戏本质是 AVG 不是卡牌"——design pivot 到剧情驱动 + 王权式平衡。引擎选定 Ink 作叙事 DSL

详见 `CLAUDE.md` 完整状态。

---

## 给 Claude Code session

读 `CLAUDE.md`。**不要读 `archive/`**——除非用户明确要求。
