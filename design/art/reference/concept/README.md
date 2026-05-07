# Concept Art / Cutscene Reference — NOT 游戏资产

> 这些图是 AI 生图早期的概念产物，含标题、解说性文字、装饰边框，**不可直接当游戏 sprite 用**。
> 留作 art-director 视觉锚点和 cutscene 拼图参考。

| 文件 | 内容 | 游戏内对应做法 |
|------|------|-------------|
| `office_floor_map.png` | 办公室俯视图 + "第 38 集" 标题 + 罗盘 | 游戏内地图层应使用裸办公室背景（待生成于 `assets/sprites/backgrounds/`），上面叠 NPC sprite + workstation 道具 |
| `monthly_review.png` | 月会 cutscene（boss 训话场景） | 游戏内月会事件应用 NPC event_cg 立绘 + 裸会议室背景拼出 |
| `overtime_night.png` | 加班场景（玩家 + 同事在深夜办公室） | 同上：裸办公室背景（夜晚 lighting）+ NPC sprite 拼 |
| `game_over_split.png` | 双结局画面 | 游戏内 GAMEOVER 屏由 KPI Review UI（程序绘）+ 解雇通知书 sprite + 反讽红章 sprite 合成 |
| `character_detail_page.png` | 角色详情页 UI mockup | 程序绘（PixiJS Graphics + Text + 角色立绘叠层） |

源大图（含 prompt 存档 + meta json）保留在 `assets/sprites/test_outputs/` 对应的 `C/D/E/F/G_*_v01.png`。
