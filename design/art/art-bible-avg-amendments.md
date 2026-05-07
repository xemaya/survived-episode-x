# Art Bible — AVG Amendments

> Status: 2026-05-06 amendments to `art-bible.md` (originally written 2026-04-22 Godot+卡牌 era)
> Author: GM
> Updated alongside `design/vertical-slice/avg-architecture.md` which contains full new spec.

---

## 仍 authoritative 的部分

视觉层全部保留 (§1 / §2 / §3 / §4 / §5 / §6 / §9)。任何视觉决策（色板 / 字体 / 剪影 / 道具密度 / 喜丧美学 / 情绪光线 / 区域色温 / 5 reference 锚) 仍以 `art-bible.md` 为准。

## Deprecated 的部分（AVG pivot 后不再 active）

| Section | 状态 | 替代物 |
|---|---|---|
| **§7.1** Diegetic vs Screen-Space | 整段 deprecated | `design/vertical-slice/avg-architecture.md` §1 + §2 |
| **§7.4** UI 动画 feel — "卡片抽起 喜丧式夸张" | 整段 deprecated | (no cards) |
| **§7.5** Gamepad / Focus 态 (Switch 预留) | 整段 deprecated | (Switch port not in scope) |
| **§7.6** 自动存档 + 地铁 5 秒 | "AP 消耗后自动保存" → "ink choice 后自动保存"; 其他 valid | `game/src/save/snapshot.ts` autosave hook |
| **§2.4** 下班抉择节点 "三张选项卡" 实现 | 卡片实现 deprecated; 视觉 spec (光线/情绪) authoritative | sticky rack (`avg-architecture.md` §1.5) |
| **§8** Asset Standards Godot-specific | TextureImporter / Light2D / CanvasModulate / AnimationPlayer / NodeTree 全部 deprecated; Asset 命名 / Palette / 像素尺寸 authoritative | `tools/cuts.yaml` + `assets/sprites/` |

## 任何冲突的解决

如 worker 看到 art-bible 跟 `avg-architecture.md` 冲突, **avg-architecture.md 优先**（仅 UI/UX 范围）。视觉层 art-bible 仍优先。

## 不重写 art-bible

art-bible 是 95KB 的大文档, 重写成本大于收益。本 amendments 文件 + `avg-architecture.md` 共同构成 AVG 时代完整 art + UI spec。
