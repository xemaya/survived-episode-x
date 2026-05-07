# UI Sprites — Reference-Only

> ⚠️ 此目录下的 sprite **不应该在游戏运行时直接使用**。
> 留作 art-director 视觉锚点（color / 1px 边框 / 0 圆角直角 / 双线 hover 等细节参考）。

## 为什么 UI 不切 sprite 用

art-bible §7 锁死的 UI motif：0 radius 直角矩形、1px 边框、双线 hover、文案中文 + 数值实时。
这些 PixiJS `Graphics.drawRect()` + `Text` 几行就能画，比 AI 静态图灵活：

- ✅ 文案可本地化、可换语言
- ✅ 数值实时更新（"音量: 65%" 数字会变）
- ✅ 状态切换不用换图（按下、禁用、悬停都数据驱动）
- ✅ 不会有 OCR 漂移（GPT-IMAGE-2 的中文小字会变形）
- ❌ AI 切的静态 sprite 全部失去以上能力

## 子目录

| 目录 | 来源 sheet | 64 张 sprite | 决策 |
|------|----------|-------------|------|
| `kpi_review/` | `O_kpi_review_ui_v02.png` | 16 | KPI 三行面板 / 解雇证书 / 按钮 4 态 / archive 列表 → 全部程序画 |
| `menu/` | `P_main_menu_pause_ui_v02.png` | 16 | 主菜单 / slider / dropdown / keymap → 全部程序画 |
| `recap/` | `Q_recap_ui_v01.png` | 12 | 日报/周报容器 / Effort 三维 / KPI 预测条 → 全部程序画（数据驱动） |
| `card/` | `T_card_dialogue_ui_v01.png` | 16 | 卡框 / 9-slice / 按钮 4 态 / AP slot → 全部程序画 |

## 例外：可作 texture 用的 sprite

少数几张可作 texture 而不是 UI 控件：

- `card/dialogue_9slice.png` — 9-slice 对话框纹理（如果要省事可作为 PixiJS NineSlicePlane 输入）
- `card/card_front_icon_set.png` — 8-12 卡牌正面 icon stamp 集合（卡牌 hero 卡叠用）

其余 60+ 张统一不在 runtime 用。

源大图见 `assets/sprites/test_outputs/{O,P,Q,T}_*.png` 含 prompt 存档。
