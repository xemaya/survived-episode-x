# W5 Round 3 Handoff — Generate 9 named NPC 立绘

> Status: dispatch
> Author: GM
> Date: 2026-05-06
> 收件人: W5 (visual asset generator clone)
> 配套: round-1 已 generate lin_jie + cafeteria_auntie + 各 prop / hud sprites

---

## TL;DR

GM playtest 2026-05-06: user 反馈"至少让我看看 Lisa、Vivian 长啥样吧". 当前 9 个 named NPC 立绘缺. W5 round-3 生成这 9 张 + sync 到 game/public/sprites/npc/.

---

## 任务

生成 9 张 NPC 立绘:

| # | NPC ID | Source-of-truth doc | 关键特征 |
|---|---|---|---|
| 1 | `lisa` | `npcs.md` §1 | 30 岁女, 长发齐肩(S1)/ 短发(S2 E7+ 2 套), 灰色 polo + 牛仔裤, 桌上保温杯/奶茶杯, 笑天同期入职, 表情：温和但 quiet sign 累积 |
| 2 | `david` | `npcs.md` §2 | 35 岁男, 卷王形象, 衬衫挽袖子, 桌面冷咖啡 + 便签满字, 站姿 100% 垂直, 颈部前伸直角 (¬钩剪影), 表情：奉承感 / 暗讽 |
| 3 | `wang_director` | `npcs.md` §3 | 50+ 岁男, 部门总监, 衬衫扣到顶 + 领带最宽, 头顶 +8 px (强制感), 双手背后, 表情：俯视 / 假笑点头 |
| 4 | `vivian` | `npcs.md` §4 | 28 岁女, 前台/接待, 标准微笑 + 工装, 桌上水果盘 + 海报背景, 表情：拖长音"嗨～来啦～"那种敷衍 |
| 5 | `zoe` | `npcs.md` §6 | 30 岁女, HR, 平肩正坐 + 文件夹永腋下 + 眼镜空框无镜片(per art-bible §5.2), 表情：标准微笑 / 翻文件 |
| 6 | `lao_zhou` | `npcs.md` §5 | 50+ 岁男, 老员工, 微弓背 + 左手持茶杯(3 px 圆形突出), 表情：会意眨眼 / 苦笑 / 沉默看 Excel |
| 7 | `li_ayi` | `npcs.md` §7 | 50 岁女, 保洁阿姨, 矮宽体型(+4 -6 px) + 围裙手机屏家庭像素画 + 拖把作第三支腿, 表情：面无表情擦桌 / 嘀咕 |
| 8 | `mama` | `npcs.md` §8 | 58 岁女, 妈妈视频通话, 厨房 BG (油烟机 / 调料挂架 / 春节菜单), 老花镜推额 + 深色毛衣 + 盐霜头发 |
| 9 | `it_xiaoma` | `npcs.md` §9 | 28 岁男, IT 小马, 茶水间咖啡机故障 running gag 角色, 工牌 + 工具包, 表情：永远的"已派单 v23 等零件 v2" |

**注**: `mama` 立绘已 round-1 生成 (`mom_video_call.png`)? 让我 verify... 实际上 W5 round-1 生成的是 `mom_video_call.png` (UI 视频画面 still) + `mom_kitchen_endgame.png` (BG). 这次 round-3 mama 仍要 generate 一张**单独 portrait** (跟其他 NPC 同 32×48 / 64×96 sprite frame 同 spec, 用于 dialog speech 头像) — 跟 mom_video_call.png 不同 mount path.

**省略**: lin_jie + cafeteria_auntie 已有, 不重生成.

## Style spec

跟 round-1 同 STYLE_GUIDE:
- 32×48 px sprite (LOD 0 base) + 64×96 (LOD 1 互动特写) 各一张, 共 2 张 per NPC
- 6 色 palette 严格遵守 (per round-1 audit)
- 透明 BG (重要——不要 cream rect leakage like round-1 phone/fruit_bowl)
- 单独 portrait (站姿 / 坐姿 各 1 帧 ok), 不需要 sheet

**Test_outputs 命名**:
- `assets/sprites/test_outputs/round3_<id>_portrait.png` (high-quality 64×96 用于 互动特写)
- `assets/sprites/test_outputs/round3_<id>_sprite.png` (32×48 用于 LOD 0)

**Final 路径**:
- `assets/sprites/npc/<id>.png` — 64×96 portrait 主用 (W1 mountNpc 走这个)
- `assets/sprites/npc/<id>_sprite.png` — 32×48 LOD 0

## DeerAPI 预算

8 NPCs × $0.13 high-quality + $0.03 low-quality = ~$1.30 总. 跟 round-1 同 budget level.

## Workflow

1. 写 9 个 prompt 在 `design/concepts/p5-assets/round3_<id>_prompt.txt`
2. Low-quality batch generate (验证构图 + style)
3. High-quality batch generate (最终)
4. cp 到 `assets/sprites/npc/<id>.png` + `assets/sprites/npc/<id>_sprite.png`
5. 跑 `cd game && pnpm assets:sync` 同步到 `game/public/sprites/npc/`
6. 写 `design/vertical-slice/visual-asset-round-3-response.md` (5-10 行就行 — DeerAPI cost + asset 清单 + style consistency self-check)

## 不要做的事

- 不要生成 Lin jie / cafeteria_auntie 重做 (round-1 已 ship)
- 不要生成 prop sprite (phone / fruit_bowl / mug / monitor / etc — round-1 done)
- 不要生成 NPC scene event_cg (那是 P6 +的事)
- BG **必须透明**(not cream rectangle 像 round-1 fruit_bowl 那样有 BG)
  - prompt 内显式强调 `transparent_bg=true` 或 `no background, isolated character on alpha`
  - DeerAPI 不一定能保证完全透明, 后处理可加 chroma-key tooling

## Estimate

- prompt 写 + low-q + high-q + cut + sync: ~3-5h (跟 round-1 类似)
- 8 NPCs × $0.13 ≈ $1.30 budget

## 完成后

W5 round-3 stand down. W1 拿到 sprites 后启 T05/T06 NPC sprite slot mount task (W1 queue T-2). 完了之后 dialog 时 NPC 立绘自动 mount 到 workstation BG 上.

## END
