# archive/design-pre-pivot/ — 设计 pivot 前的 GDD + Asset Specs

> Archived: 2026-05-06
> Reason: 2026-05-05 设计 pivot 完成（卡牌驱动 → AVG + 王权式日常）+ 引擎切到 TS+Pixi+Ink。本目录的 GDD / asset specs 大部分基于卡牌时代 + Godot 时代写，**已不再 active**。

## 目录内容

- `gdd/` — 27 个 GDD 文档（card-play / ap-economy / hud-diegetic / event-script-engine / scene-day-flow / kpi-review-game-over-ui 等）
- `assets/` — Godot 时代 asset specs（card-play-dialogue-ui / daily-weekly-recap / kpi-review 等）+ asset-manifest + sprite_mapping

## 仍然有 reference 价值的文档

虽然整体 archived，以下文档**部分内容仍是 active**（已在 `design/vertical-slice/` 引用 / 重新表达）：

| Archived doc | Still-active content | New location |
|---|---|---|
| `gdd/game-concept.md` | 5 Pillars 定义 + Core Fantasy | `design/vertical-slice/protagonist.md` + `tone-bible.md` (inline) |
| `gdd/kpi-reverse-threshold-system.md` | Formula B 数学 + capacity_factor 衰减 + threshold 涨幅公式 | `game/src/economy/kpi.ts` (代码) + `design/vertical-slice/series-structure.md` (high-level) |
| `gdd/run-meta-system.md` | RunSummary + Archive 200 cap + content-only unlock 红线 | `game/src/run-meta/` (代码) + `design/vertical-slice/series-structure.md` |
| `gdd/ap-economy-system.md` | energy/effort math (effort_overtime/hero/overage 仍 active, AP 部分 deprecated) | `game/src/economy/effort.ts` + `energy.ts` |
| `gdd/npc-relationship-system.md` | NPC 算计原则 (现 `tone-bible.md` 原则 2) | `design/vertical-slice/npcs.md` |

## 已 fully deprecated 的部分

- `gdd/action-card-system.md` — 卡牌时代 mechanics, AVG pivot 后无关
- `gdd/card-play-dialogue-ui.md` — 卡牌 UI, 现在 ink-driven dialog
- `gdd/event-script-engine.md` — 自研 event script, 现在用 Ink + inkjs
- `gdd/scene-day-flow-controller.md` — FSM design, P5 重写
- `gdd/kpi-review-game-over-ui.md` — 现 `design/vertical-slice/avg-architecture.md` Bug #31 cinematic spec 重写
- `gdd/daily-weekly-recap-ui.md` — 现 ink-driven daily_recap stitch + `# pagebreak`
- `gdd/hud-diegetic.md` — Godot Diegetic UI for gamepad, AVG 时代不直接适用
- `gdd/tutorial-onboarding-system.md` — 现 first-time tutorial modal (Bug #23)
- `assets/specs/*` — Godot 时代 asset specs，现 `assets/sprites/` 实际产出 + `design/concepts/p5-assets/` 是 W5 reference

## 代码 comment 引用

`game/src/` 内有 ~10 处 comment 形式引用 `design/gdd/...`（如 `kpi.ts` 引 Formula B / `effort.ts` 引 effort-tracking / `kpi-review.tsx` 引 HR-tone breakdown）。这些 comments **保留 path** 以保留历史 trail，但读者应理解 archive/ 路径下的 doc 是 historical reference，**当前 source of truth 是 `design/vertical-slice/` + 代码本身**。

## 不要做的事

- ✗ 不要根据本目录推断当前游戏机制 / UI / 设计意图
- ✗ 不要让 worker clone 读本目录 (除非 designer 明确指定)
- ✗ 不要按本目录的 GDD spec 实现 feature

## 怎么用本目录

✅ 历史 reference: 想知道某个机制 designed 时的 rationale、Pillar 1-5 原始定义、KPI Formula B 推导细节
✅ Migration audit: 验证 vertical-slice 是否 cover 了 archived GDDs 的关键内容
✅ 检索某个数学常量的 design 来源（例: `EFFORT_HERO_WEIGHT = 0.45` 的 0.45 哪来的）

如果发现 archived GDD 还有内容应该 migrate 到 vertical-slice，告诉 designer。
