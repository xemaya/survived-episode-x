# Bare Background Plates

8 张干净的场景背景图，**专门为 sprite 叠层设计**：无标题、无装饰边框、无 cell 编号、无解说性文字。游戏内场景的底层贴图。

| 文件 | 用途 | 上面应该叠什么 |
|------|------|--------------|
| `office_floor_top.png` | 主场景地图层（俯视） | NPC 站位 sprites + workstation 道具 sprites |
| `workstation_closeup.png` | ACTION_DAY 主屏（单工位特写） | 玩家立绘 + 便利贴 sprite + 咖啡杯 sprite + 显示器内容 sprite |
| `tea_room.png` | 茶水间事件背景 | NPC 在水机前 sprite + 茶室签到表 sprite + 裂痕 sprite |
| `meeting_room.png` | 会议事件背景 | 与会 NPC sprites + 白板 marker layer sprites |
| `boss_office.png` | Boss 事件背景 | Boss 立绘 + 玩家立绘 |
| `hallway.png` | 走廊事件背景 | 行走 NPC sprites + 走廊纸箱 sprite + 阿姨拖把车 sprite |
| `main_menu.png` | 主菜单背景 | 程序绘的 game title + 4 menu buttons + version strip |
| `kpi_review.png` | 月末考核屏背景 | 程序绘的 KPI 三行面板 + 数字 + 按钮 + 反讽红章 sprite |

## 来源

- 出图：DeerAPI gpt-image-2 quality=low，2026-05-04
- prompt 在 `assets/sprites/test_outputs/prompt_BG{1..8}_*.txt`
- 源大图（含 .meta.json）在 `assets/sprites/test_outputs/BG{1..8}_*_v01.png`
- 总成本 ~$0.24（低质 8 张）

## 升级路径

如果某张需要更精细，重跑 quality=high（$0.10/张）：
```bash
python3 tools/gen_image.py \
  assets/sprites/test_outputs/prompt_BG<n>_<name>.txt \
  assets/sprites/test_outputs/BG<n>_<name>_v02.png \
  --quality high
cp assets/sprites/test_outputs/BG<n>_<name>_v02.png assets/sprites/backgrounds/<name>.png
```
