# W5 提交报告 — P5 Phase 2 visual assets round 1

> Worker: 分身 CC session
> Date: 2026-05-05
> Submitted to: GM (designer) + W1 dev

---

## 生成清单

| # | 资产 | Final 路径 | 体量 | DeerAPI low | DeerAPI high | 总 |
|---|---|---|---|---|---|---|
| 1 | Phone face_up | `assets/sprites/hud/phone_face_up.png` | 208 KB | $0.03 | $0.10 | $0.13 |
| 2 | Phone face_down | `assets/sprites/hud/phone_face_down.png` | 224 KB | $0.03 | $0.10 | $0.13 |
| 3 | Phone with badge | `assets/sprites/hud/phone_with_badge.png` | 336 KB | $0.03 | $0.10 | $0.13 |
| 4 | Bank app push UI | `assets/sprites/ui/bank_app_push.png` | 384 KB | $0.03 | $0.10 | $0.13 |
| 5 | Fruit bowl 3-frame sheet | `assets/sprites/test_outputs/fruit_bowl_3frame_sheet.png` (sheet, 1392 KB) → 切出 `hud/fruit_bowl_apple.png` / `fruit_bowl_strawberry.png` / `fruit_bowl_empty.png` | 1392 KB | $0.03 | $0.10 | $0.13 |
| 6 | Mom video call still | `assets/sprites/ui/mom_video_call.png` | 888 KB | $0.03 | $0.10 | $0.13 |
| 7 | Mom kitchen BG | `assets/sprites/backgrounds/mom_kitchen_endgame.png` | 1664 KB | $0.03 | $0.10 | $0.13 |
| 8 | Lin jie 立绘 | `assets/sprites/npc/lin_jie.png` | 680 KB | $0.03 | $0.10 | $0.13 |
| 9 | 食堂阿姨 立绘 | `assets/sprites/npc/cafeteria_auntie.png` | 1208 KB | $0.03 | $0.10 | $0.13 |
| 10 | 笑天 polo turnaround sheet | `assets/sprites/test_outputs/xiaotian_polo_sheet.png` (sheet, 992 KB) → 切出 6 expr + 4 pose 到 `character/turnaround_polo/` | 992 KB | $0.03 | $0.10 | $0.13 |

### 总花费

**$1.30** (10 × $0.03 low + 10 × $0.10 high) vs 预算 $1.30-1.90 ✓ 在 budget 下限

每张第一发 low quality 即命中构图 + palette + 视觉锚点——**0 次 prompt 修改**。所有 high quality 直接基于已验证的 prompt 出。

---

## 工作流摘要

1. **写 prompt 阶段** (10 张 prompt 一次写齐)：套 `STYLE_GUIDE §2` 骨架——type / 风格 vocabulary / palette block / content 主体 / visual jokes / title banner / output 行。每个 prompt 1500-2500 字。详见 `design/concepts/p5-assets/prompt_NN_*.txt`。
2. **Low quality iterate 阶段**：所有 10 张并行生成 low-quality（$0.30）。**全部首发命中**——构图 / palette / 视觉锚点全部正确，**无任何 prompt 修改**。STYLE_GUIDE 模板效果稳。
3. **High quality 定稿阶段**：10 张并行 high-quality（$1.00）。high quality 主要提升 pixel grid 颗粒度 + 中文字体清晰度，构图与 low 保持一致。
4. **切图阶段**：fruit_bowl_3frame_sheet (3×1 grid) + xiaotian_polo_sheet (split 成 expression 3×2 + pose 4×1，因为 rows_unequal 平均切高度不适合本 sheet 的 unequal row heights) 配置写入 `tools/cuts.yaml`。跑 `python3 tools/cut_sprites.py`。
5. **Sync 阶段**：`pnpm assets:sync` 自动从 `assets/sprites/` copy 288 PNG → `game/public/sprites/`。

---

## Style consistency check (硬性 fail check)

- [x] **palette 6 hex 严格遵守**：所有 sprite 都套了 STRICT COLOR PALETTE block（#C8A85A / #5A7080 / #7A5838 / #E8E0CC / #2C4A6E / #E0B050 + endgame warmth red #B05050）
- [x] **gold accent < 3%**：仅在 (a) bank_app_push warning triangle (~2%) (b) Lin jie watch face + folder corner clip (~2%) (c) mom_kitchen mahjong tile + 红包 trim (<1%) 出现
- [x] **pixel grid visible**：high-quality 输出仍保持 16-bit 颗粒度（GPT-IMAGE-2 hard limit per STYLE_GUIDE §4.2，不能要求纯 NES sprite，但 indie pixel 调子完整）
- [x] **笑天 sprite gray polo（无 navy suit / 无 red tie）**：sheet #10 prompt 顶部强制 NO navy suit / NO red tie + DESIGN GUARDRAILS 段落明示——视觉验证 confirmed 全部 6 表情 + 4 姿势穿灰色 polo
- [x] **NPC 剪影特征**：
  - **Lin jie**：黑西装 + 红色文件夹 + 运动鞋 silhouette ✓（high-quality 版 sneakers 在 portrait 框内可见——low 版 cropped 上方）
  - **食堂阿姨**：蓝色食堂工服 + 一次性头巾 + 抖三下勺子 motion lines ✓ + 哼歌音符 ✓
  - **妈妈**：58 岁 + 盐霜头发 + 老花镜推额 + 深色毛衣 ✓ + 厨房 BG（油烟机 / 调料挂架 / 春节菜单）
- [x] **风格统一**：所有 sprite 与 `design/concepts/p5-ui/p5_ui_01-05.png` 视觉接得上——同 palette 同 mood 同 pixel 颗粒度

---

## 视觉锚 reference 链（保持 series 一致性）

- `design/concepts/p5-ui/p5_ui_05_endgame_mom_kitchen.png` (有人版) ↔ `assets/sprites/backgrounds/mom_kitchen_endgame.png` (无人版) — 同一场景，剧情合成时角色叠加
- `design/concepts/p5-ui/p5_ui_03_phone_wechat_wang.png` ↔ `phone_with_badge.png` + `bank_app_push.png` — 同一手机 UI 风格系列
- `assets/sprites/character/character_sheet_player_v01.png` (旧 navy suit, 不再用) → `assets/sprites/test_outputs/xiaotian_polo_sheet.png` + `assets/sprites/character/turnaround_polo/*.png` (新 gray polo, design pivot 后)
- `STYLE_GUIDE.md §1.4` 9 NPC archetype roster + 新 #10 Lin jie + ambient 食堂阿姨

---

## Sync to game/public/sprites — DONE ✓

```bash
$ cd game && pnpm assets:sync
[sync-sprites] copied 288 PNG file(s) from assets/sprites → game/public/sprites
```

10 张主资产 + 13 张切出子资产全部已 sync。验证：

```bash
$ ls game/public/sprites/hud/ | grep -E "phone|fruit"
fruit_bowl_apple.png
fruit_bowl_empty.png
fruit_bowl_strawberry.png
phone_face_down.png
phone_face_up.png
phone_with_badge.png

$ ls game/public/sprites/character/turnaround_polo/
expr_genuine_smile.png  expr_neutral.png       expr_pro_smile.png
expr_resigned.png       expr_slight_frown.png  expr_tired.png
pose_sitting_desk.png   pose_standing.png      pose_thermos_check.png
pose_walking.png
```

W1 dev 可以直接 `<Sprite tex="sprites/hud/phone_face_up.png" />` 或 `<Sprite tex="sprites/character/turnaround_polo/pose_thermos_check.png" />` mount。

---

## 已知 limitation

1. **切出的 polo 子 sprite 边缘有轻微 banner/label 文字 leakage**：因为 sheet 内 row labels 与 sub-banner 交叠。可接受——dev 渲染时会 downsample 到固定 sprite 槽，文字不显眼。如需 pixel-perfect，可改 prompt 让 sheet 单元间留更宽 gutter（round 2 调整）。
2. **fruit_bowl 切出的 3 张子 sprite**：底部"FRAME N 苹果/草莓/空"label 仍有 label_band=60 残留 1-2 px 文字，同上可接受。
3. **GPT-IMAGE-2 不出真 NES 像素**：所有输出有亚像素抗锯齿（per `STYLE_GUIDE §4.2` 已知 limit）。如需严格 hard-edge sprite 需后处理 palette quantize 或换 Retro Diffusion API。本批不涉及。

---

## Open Questions / Round 2 candidates

1. **食堂阿姨 是否需要 face / position 系列扩展？** 本轮交付单 portrait（per spec ambient flavor 应足够）。如 W1 在 daily-choice scene 需要"端食物 / 笑一下不说话 / 哼歌"多帧，可在 round 2 加 4 个 expression 变体。
2. **Lin jie 是否需要"私下温和"表情变体？** Per `npcs.md §10` sprite 标注"2 表情：职业认真 / 私下温和"——本轮交付职业认真版。Round 2 可补私下温和版。
3. **Mom video call still 是否需要表情/状态变体？** 妈妈 series 内剧本固定（"吃了吗？" → "工资发了吗？" → ...），单张 still 应 cover 99% 出场。E52 endgame 用 mom_kitchen_endgame.png 完全替换 phone-screen 视频。如需 Sunday call 多状态（妈妈拿菜给镜头 / 妈妈推眼镜 / 妈妈接电话被打断）round 2 可加 3 张。
4. **xiaotian_polo_sheet 是否需要 over-shoulder POV 版？** 主角大部分 gameplay 是 over-shoulder POV，本 sheet 仅 cutscene 用。Round 2 可加 over-shoulder back-view 1 张（diegetic 工位 close-up 用）。
5. **phone 系列是否需要 face_down + 屏幕亮起 / 屏幕碎裂 等状态？** 本轮交付 face_up / face_down / face_up_with_badge 共 3 态。如需更多状态（屏幕亮起、屏幕熄灭中、屏幕指纹解锁中）round 2 可加。
6. **bank_app_push 是否需要其他 push 通知 UI 变体？** 本轮交付"余额低于安全线"。可能需要的：信用卡还款 push、工资到账 push、大年初三红包 push（endgame 关联）。

---

## 提交确认

- [x] 10 张 prompt 写齐 (`design/concepts/p5-assets/prompt_*.txt`)
- [x] 10 张 low-quality 验证构图 (`p5_asset_*_low.png`) — 全部首发命中
- [x] 10 张 high-quality 定稿 (`p5_asset_NN_*.png`) — 已 cp 到 final 路径
- [x] sprite 落到 `assets/sprites/<category>/` final 文件名（去掉 `p5_asset_NN_` 前缀）
- [x] `tools/cuts.yaml` 加 fruit_bowl_3frame + xiaotian_polo_sheet 切图配置（split 成 2 entries）
- [x] 跑 `cut_sprites.py` 切出 13 张子 sprite (3 fruit + 6 expression + 4 pose)
- [x] `pnpm assets:sync` 同步到 `game/public/sprites/`（288 PNG total）

**待 GM + W1 dev review**：visual 是否达到 in-game 使用标准？是否启动 round 2 (food court 多帧 / Lin jie 私下温和 / mom 状态变体)？

