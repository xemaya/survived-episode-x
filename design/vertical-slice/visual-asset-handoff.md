# W5 · Visual Asset Generator · Handoff Brief

> Status: 第 1 版
> Author: Game Designer (GM)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——新启动的 Claude Code session

---

## 0. 你的处境

`survived-episode-x` 美术工作流：用 **gpt-image-2 via DeerAPI** 批量生成 16-bit pixel art，再 Python 脚本切图。前面已生成：5 张 P5 UI concept 图（`design/concepts/p5-ui/`）+ ~270 张工位/NPC/HUD sprites（`assets/sprites/`）。

你的活：**为 P5 Phase 2 demo 生成 8-10 张新 sprite**。Engine dev (W1) 在等以下 prop 资产：phone face_up/face_down + 银行 app push + 水果盘 strawberry/apple 3-frame + 妈妈视频立绘 + 妈妈家厨房 BG + 林姐立绘 + 食堂阿姨立绘 + 部分 10 NPC 新装 polo 立绘（旧 NPC sprites 是 navy suit 不符合 design pivot）。

完成后 **GM (我) + W1 dev** verify 视觉到位 + sync 到 game/public/sprites/。

---

## 1. 必读 reference（按顺序）

1. **`assets/sprites/STYLE_GUIDE.md`** — **你的主要 spec**。视觉锚点 / 16 色 palette / 9 NPC 原型剪影 / prompt 模板 / 已生成 reference 清单
2. **`design/concepts/p5-ui/`** — 5 张 P5 UI concept（已生成）。**所有新 sprite 的视觉 baseline**——color palette / pixel art 颗粒度 / lighting / mood 必须 match
3. **`design/vertical-slice/protagonist.md`** §2 — 陈笑天的视觉锚点（**关键**：32 岁 / 灰色 polo / 不戴领带 / 不锈钢保温杯 / 富士山头像）
4. **`design/vertical-slice/npcs.md`** v2 — 10 NPC 视觉锚点（每个都有 `视觉锚点` 段落）
5. `tools/gen_image.py` — DeerAPI 调用 CLI（`pnpm setup:inklecate` 等价的图片生成）
6. `tools/cut_sprites.py` + `tools/cuts.yaml` — 切图配置
7. `assets/sprites/test_outputs/` 已 archive，但参考 `design/concepts/p5-ui/prompt_*.txt` 5 个 prompt 已写好的成品文件作为格式样例

---

## 2. 任务：生成 8-10 张新 sprite（or sprite sheet）

### 资产清单（按 dev 优先级）

| # | 资产 | 用途 | 推荐尺寸 / 格式 |
|---|---|---|---|
| 1 | **Phone face_up sprite** | workstation prop layer — 静态手机正面（屏幕黑） | 64×128 单 sprite |
| 2 | **Phone face_down sprite** | 同 prop 但屏幕朝下 | 64×128 单 sprite |
| 3 | **Phone with notification badge** | 手机正面 + 微信/银行 app push 红色徽章 | 64×128 单 sprite |
| 4 | **Bank app warning push UI** | 钱<4500 银行 app fullscreen warning push 通知 | 320×640 mock UI |
| 5 | **Fruit bowl 3-frame sheet** | 苹果 / 草莓 / 空 — 前台水果盘 prop 3 状态 | 192×64 grid (3 cols) |
| 6 | **Mom video call still** | 妈妈视频时 phone screen 内的妈妈头像 + 老家厨房背景（小尺寸，phone screen 内嵌 UI 用） | 240×320 |
| 7 | **Mom kitchen BG (endgame)** | E52 春节回家场景全屏 BG | 1024×1024 (per concept 05) |
| 8 | **林姐立绘** | 客户成功部主管，S3 finale 路径 A 出场（黑西装 + 运动鞋 + 红文件夹）| 256×512 |
| 9 | **食堂阿姨立绘** | 食堂场景 daily choice 用（蓝色食堂工服 + 抖三下勺子）| 256×512 |
| 10 | **(Optional) 笑天新装立绘 sheet** | gray polo + 不戴领带 + 不锈钢保温杯（覆盖旧 navy suit 立绘）— 6 表情 + 4 姿势 grid | 1024×1024 (per `character_sheet_player_v01.png` 模板)|

**P0**（dev 等着用）：1, 2, 3, 4, 5（5 个 prop sprite）
**P1**（demo 进入下一 episode 才需要）：6, 7（妈妈相关）
**P2**（S3 路径 A 才需要）：8（林姐）
**P3**（improvements）：9, 10

---

## 3. 工作流（每个资产）

```bash
# 1. Write prompt file
cat > design/concepts/p5-assets/prompt_NN_<asset_name>.txt << EOF
A pixel art [type] for a Chinese office life game...
[详细 prompt — 套 STYLE_GUIDE.md §2 模板]
EOF

# 2. Generate via DeerAPI (high quality)
python3 tools/gen_image.py \
  design/concepts/p5-assets/prompt_NN_<asset_name>.txt \
  design/concepts/p5-assets/p5_asset_NN_<asset_name>.png \
  --quality high

# 3. Iterate if visual not lock-in (gen low quality first to save cost)
# 4. Once final, copy to assets/sprites/<category>/
cp design/concepts/p5-assets/p5_asset_NN_<asset_name>.png \
   assets/sprites/<category>/<asset_name>.png

# 5. Optionally use cut_sprites.py if multi-frame sheet
# 6. assets:sync auto runs on next pnpm dev
```

### Prompt 模板（套 STYLE_GUIDE.md §2 骨架）

每个 prompt 必须包含：

1. **类型行**："A pixel art [icon / character sheet / scene / UI mockup] for a Chinese office life game."
2. **风格 block** (从 STYLE_GUIDE §1.1 复制):
   ```
   Style: SFC/16-bit pixel art, visible pixel grid, no anti-aliasing on outlines,
   limited 16-color palette. NOT vector or smooth modern illustration.
   Visual identity goal: "first glance recognition, second glance indictment"
   ```
3. **严格 palette block** (从 STYLE_GUIDE §1.2 复制 6 色 hex)
4. **内容主体描述**：layout / 字符 / 场景 / props
5. **Visual jokes**（1-3px 喜丧 触发，per STYLE_GUIDE §2）
6. **Title banner**（中文 + English subtitle）
7. **Output 行**："Output: PNG, 1024x1024, ..."

参考 `design/concepts/p5-ui/prompt_05_endgame_mom_kitchen.txt`（厨房场景 prompt 已成功，warm palette 变体）。

---

## 4. 关键约束

### 视觉一致性（不能违反）

- **palette 严格**：5 色 hex（`STYLE_GUIDE §1.2`）+ "warmth red #B05050" only on endgame scenes
- **gold accent max 3% pixel coverage**：仅用于 boss / power 元素（per STYLE_GUIDE §1.2）—— 旧 sprite 出过失控 case
- **笑天角色 anchor**：32 岁 / 灰色 polo / 不戴领带 / 不锈钢保温杯。**不要继承旧 turnaround sheet 的 navy suit + red tie**
- **每张图都 ref STYLE_GUIDE**：在 prompt 里加 `consistent with prior reference sheets, especially design/concepts/p5-ui/p5_ui_01_workstation_monday_morning.png` 之类
- **NPC 剪影特征**（per STYLE_GUIDE §1.4）每个 NPC 都有，例如：
  - 林姐（cs_team_lead）= 黑西装但穿运动鞋 + 红色文件夹
  - 食堂阿姨 = 蓝色食堂工服 + 一次性头巾 + 抖三下勺子
  - 妈妈 = 58 岁，盐霜头发，老花镜，深色毛衣

### 设计禁忌

- **不要给妈妈做特殊滤镜 / 高 saturation**（warm 但不 fake）
- **不要给林姐"职业女性英雄滤镜"**——她是低调能干，不是聚光灯
- **不要把食堂阿姨画得"温暖治愈"**——她是 ambient flavor，不刻意
- **不要给笑天 sprite 画"清醒共谋者"露脸 expression**（笑天大部分时间是 over-shoulder POV 看不到脸；如果要脸，是平静微皱眉）

### 命名 convention

- 文件名小写 + underscore：`mom_kitchen_endgame.png`
- 路径: `assets/sprites/<category>/`
  - characters: `assets/sprites/character/<asset>.png`
  - NPC: `assets/sprites/npc/<asset>.png`
  - HUD prop: `assets/sprites/hud/<asset>.png`
  - BG: `assets/sprites/backgrounds/<asset>.png`
- 多帧 sprite sheet: `<asset>_sheet.png` + 在 `tools/cuts.yaml` 加切图配置

---

## 5. 验收（GM + W1 dev review）

### 硬性 fail（任意 1 条 = 整批返工）

- palette 偏离 STYLE_GUIDE §1.2 hex（用 image inspection 工具看色值）
- 笑天 sprite 是 navy suit + red tie（不符合 design pivot）
- gold accent > 3% pixel coverage
- NPC 剪影特征丢失（林姐没红文件夹 / 食堂阿姨没勺子 / 妈妈不是 58 岁感）
- 风格不是 16-bit pixel art（出了 modern smooth illustration）
- 中文 OCR 漂移严重（标题 banner 中文不可读）

### 软性 fail（≥ 3 条 = 重生成 1-2 张）

- 视觉跟 5 张 P5 UI concept 不"接得上"（feel 像换风格了）
- 喜丧 jokes 不足（无 1-3px 微笑点）
- composition 失衡（太空 / 太挤）
- pixel grid 不可见（被 anti-aliasing 抹平）

---

## 6. 工作量 + 预算

| 阶段 | 工时 | 预算（DeerAPI） |
|---|---|---|
| 写 prompt（10 张）| 1 小时 | $0 |
| 低质量 iterate（每张 1-3 次）| 2 小时 | $0.30-0.90 |
| 高质量定稿（10 张）| 1 小时 | $1.00 |
| 切图 + sync（多帧 sheet）| 30 min | $0 |
| 提交 | 30 min | $0 |
| **总计** | ~5 小时 | **$1.30-1.90** |

User 已批 budget OK。

---

## 7. 提交格式

写 `design/vertical-slice/visual-asset-round-1-response.md`：

```markdown
## W5 提交报告 — P5 Phase 2 visual assets round 1

### 生成清单
| # | 资产 | 路径 | 体量 | DeerAPI 花费 |
|---|---|---|---|---|
| 1 | Phone face_up | assets/sprites/hud/phone_face_up.png | 60 KB | $0.10 |
| 2 | Phone face_down | ... | ... | ... |
| ...

### 总花费: $X.XX (vs $1.30-1.90 预算)

### Style consistency check
- palette 6 hex 严格遵守: ✓
- gold accent < 3%: ✓
- pixel grid visible: ✓
- 笑天 sprite gray polo (无 navy suit): ✓
- NPC 剪影特征: ✓ (林姐红文件夹 / 食堂阿姨勺子 / 妈妈 58 岁感 + 老花镜)

### 视觉锚 reference
- design/concepts/p5-ui/p5_ui_05_endgame_mom_kitchen.png 是 mom_kitchen_endgame.png 的 reference baseline ✓

### Sync to game/public/sprites
- 跑 pnpm assets:sync — 全 10 张到 game/public/sprites/ ✓

### Open Questions
- ...
```

---

## 8. ❌ 不能做的事

- 不要改 STYLE_GUIDE.md（你按 spec 走，不修 spec）
- 不要 archive 现有 sprite assets（旧 sprite 仍可能用）
- 不要写 prompt 时偏离 5 色 palette
- 不要 yolo 一次直接 high quality（先 low 调构图）
- 不要在 game/src/ 改任何代码（你只是 asset worker）
- 不要给"sprite 加叙事"（visual-only worker，剧情留给 ink writer）

---

## 9. 第 1 张推荐：phone face_up

最简单 + dev 最先用的。流程：

1. 写 `design/concepts/p5-assets/prompt_01_phone_face_up.txt`：
   ```
   A pixel art icon for a Chinese office life game: a smartphone in face-up position, screen black/off, lying on a wooden desk surface.
   [STYLE block]
   [PALETTE block]
   View: top-down 3/4 angle. Phone is generic black flat smartphone (no logo). Visible: black screen, thin white border around screen, single physical home button at bottom (subtle), micro speaker grill at top, edge corner notch.
   Background: tiny strip of wooden desk surface (same brown #7A5838 as workstation).
   Visual jokes:
   - 1px reflection on screen edge suggesting fluorescent overhead light
   - phone case has a faint "8 年前去日本" sticker visible in corner (Mt. Fuji silhouette)
   Output: PNG, 256x256, single sprite for use as a workstation prop, 16-bit pixel art aesthetic.
   ```
2. 跑 `pnpm gen` (low) → check
3. 改 prompt 改到满意 → high quality → cp 到 `assets/sprites/hud/`
4. dev 用 `<Sprite tex="sprites/hud/phone_face_up.png" />` 直接 mount

完事写到提交报告，等 GM + dev review。
