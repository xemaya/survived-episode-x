# 《活过第 X 集》Survived Episode X

> 像素风反向 KPI 中国职场生存模拟 · AVG 剧情驱动 + 王权式日常选择平衡

**🎮 在线试玩**：https://xemaya.github.io/survived-episode-x/

---

## 故事

你叫**陈笑天**——爹妈起名"笑傲天下众生"，希望你笑傲一番。结果长大变成 **32 岁产品助理**，每天偷茶水间速溶咖啡，下班路上盘算"今天又活过去了"。

入职第 12 周第 1 天起，跟你同期入职的 Lisa 工位发生小变化。3 个月后她可能走了，可能留了——但**留下不是赢**：你越能"救" Lisa，下个月你的 KPI 阈值涨得越凶。

**胜利条件不是升职加薪，是活过 52 集（一年）**。升职 = 处刑。

## 关键设计

- **不可能三角**：钱多 / 事少 / 离家近 — 你只能选两个
- **反向 KPI**：本月 KPI 越高，下月阈值涨幅越大
- **病倒次数 cap = 6**：第 7 次直接 game over
- **5 路径 finale**：每月末 KPI Review 都"过"，但 5 路径都"扎不同的痛点"
- **52 集 = 12 个月 + 4 集 endgame**：finite series, 活过 E52 = happy ending
- **Lisa 跨 S1-S3 弧光**：E12 走 / 留是整 series 第一个真正"扎点 finale"

## Voice 红线（per `design/vertical-slice/tone-bible.md`）

1. 主角是观察者，不是英雄（撑过去，不"成长"）
2. NPC 永远为自己活，不为玩家服务
3. 主语翻转：数值变化用 NPC / 物 / 时间陈述，不用"你"或"系统"
4. 写真不写好：HR-speak / PUA / 周报体直接抄现实
5. 朋友圈测试：真打工人会截图发吗？

## 参考标杆

《大多数》《死亡与税收》《Papers Please》《破事精英》《Reigns》。

---

## 玩

**网页**：https://xemaya.github.io/survived-episode-x/

游戏完全在浏览器里跑，无需登录。约 30 分钟可玩通 S1（4 集 / 1 个月）+ 部分 S2-S3 内容。共 12 集 ink 内容已实装（S1-S3 = 23% of full series），S4 + endgame + S5-S12 内容滚动开发中。

**桌面**（macOS Tauri build）：

```bash
cd game
pnpm install
pnpm tauri dev    # dev mode
pnpm tauri build  # build native bundle
```

---

## 技术栈

| 层 | 技术 |
|---|---|
| 桌面打包 | Tauri 2 |
| 构建 | Vite 6 |
| UI | Preact + TypeScript 5 |
| 渲染 | PixiJS v8 |
| 叙事 DSL | Ink + inkjs runtime |
| 测试 | Vitest 357/357 |
| 持久化 | zod schema + localStorage / Tauri fs |
| Format / Lint | Biome + lefthook |

---

## 项目结构

```
.
├── design/
│   ├── vertical-slice/   ★ 设计主战场（series structure / 10 NPC / 12 episode .ink + 60 daily choices / S1-S4 outlines / worker briefs / bug reports）
│   ├── art/art-bible.md  美术规范
│   ├── concepts/         W5 visual reference
│   └── registry/         数值常量
├── game/                 TS 工程
│   ├── src/              代码（Save / FSM / KPI / Effort / Energy / Ink runtime / Dialog / Sprites / Scene / Calendar / Status HUD / Pause / Tutorial）
│   ├── tests/            Vitest 单元 + Playwright QA harness
│   └── public/ink/       编译后 .ink → .json
├── assets/sprites/       11 NPC + 4 BG + props + HUD sprite
├── tools/                Python 切图 + chroma-key + 高分辨率重 cut
├── archive/              ⚠️ Godot 时代 + design pivot 前 GDDs — 默认不读
└── CLAUDE.md             给 Claude Code 的项目指令
```

---

## 开发流程

本项目是 indie 单人项目，使用 **Claude Code 多 worker subagent** 协作:

- **GM** (designer / engineer)：写 spec + review worker output + integrate
- **W1** Engine Dev：357 tests, 26+ commit batches 落地 P5 整套引擎层
- **W2** QA Tester：Playwright harness, 20+ rounds verify
- **W3** Ink Writer：S1-S3 12 集 ink + intro voice + AP sweep（~30h work）
- **W4** Outline Writer：S3-arc.md
- **W5** Visual Asset Generator：11 NPC × 256×384 portraits + 4 BG + props（DeerAPI gpt-image-2）
- **W6** Outline Writer：S4-arc.md, S5-S12 in flight

详见 `design/vertical-slice/gm-worker-roster.md`。

---

## 历史

- **2026-04**: Godot 4.6 / GDScript ("paper-done" 18.6k 行 GDScript 已归档到 `archive/godot-architecture/`)
- **2026-05-03**: 引擎切到 TS + Vite + PixiJS + Tauri，写了 P0-P4
- **2026-05-05**: design pivot 到 AVG（剧情驱动）+ 王权式日常选择平衡，引擎层选 Ink 作叙事 DSL
- **2026-05-06**: P5 ship — full AVG architecture (3-layer dialog + 公文报告框 + sticky choices + scene registry + NPC sprite slot)
- **2026-05-07**: GitHub Pages 部署。S4 outline ship + S4 ink + S5 outline + endings ink in flight

详见 `CLAUDE.md` + `design/vertical-slice/avg-architecture.md`。

---

## License

MIT (TBD — current code/content under personal copyright pending license decision).

---

## 给 Claude Code session 用

读 `CLAUDE.md` + `design/CLAUDE.md`。**不要读 `archive/`**——除非用户明确要求。
