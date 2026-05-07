# Asset Strategy — AI 出图 + 游戏内使用分类

> 制定原因：2026-05-04 一轮 AI 生图 + 切图后发现，并非所有 AI 产物都适合直接当游戏 sprite 用。
> 部分是**概念参考**，部分是**应该程序生成的 UI**，部分才是**真正的 sprite atlas**。
> 此文件规定四类资产的归属、使用方式和后续动作。

---

## 四类资产

### A — 概念图 / cutscene reference（NOT 游戏资产）

带标题、解说性文字、装饰边框、艺术化构图。**不应该直接进游戏**。
游戏内若需要类似画面（cutscene、loading splash），应基于此参考用 sprite 拼出。

| 文件 | 内容 | 当前位置（需移走） | 目标位置 |
|------|------|--------------------|---------|
| `C_world_map_v01.png` | 办公室俯视图 + "第 38 集" 标题 + 罗盘 | `assets/sprites/maps/office_floor_map.png` | `design/art/reference/concept/` |
| `E_monthly_review_v01.png` | 月会 cutscene | `assets/sprites/scenes/monthly_review.png` | 同上 |
| `F_overtime_scene_v01.png` | 加班场景 | `assets/sprites/scenes/overtime_night.png` | 同上 |
| `G_game_over_v01.png` | 双结局 | `assets/sprites/scenes/game_over_split.png` | 同上 |
| `D_character_detail_page_v01.png` | 角色详情页 UI mockup | `assets/sprites/ui/character_detail_page.png` | 同上 |

**Action**：从 `cuts.yaml` 移除这 5 个 single-mode entry；移动文件到 reference 目录；写 README 说明用途。

---

### B — UI 应**程序生成**（PixiJS Graphics + Text）

UI motif（art-bible 锁死）：0 圆角直角、1px 边框、双线 hover、copier-printed-form 风。
这些用 `Graphics.drawRect` + `Text` 几行代码就能画，**比 AI 出的静态图灵活百倍**：
- 文案可本地化、可换语言
- 数值实时更新（"音量: 65%" 数字会变）
- 状态切换不用换图（按下、禁用、悬停都是数据驱动）
- 不会有 OCR 漂移（GPT-IMAGE-2 的中文小字会变形）

| AI 产物 | 切出 sprite 数 | 决策 |
|---------|--------------|------|
| `O_kpi_review_ui_v02.png` | 16 (`hud/ui/kpi_review/`) | KPI 三行面板 / 解雇通知书 / 按钮 4 态 / archive 列表 → 程序画 |
| `P_main_menu_pause_ui_v02.png` | 16 (`hud/ui/menu/`) | 主菜单 / slider / dropdown / keymap → 程序画 |
| `Q_recap_ui_v01.png` | 12 (`hud/ui/recap/`) | 日报/周报容器 / Effort 三维 / KPI 预测条 → 程序画（数据驱动） |
| `T_card_dialogue_ui_v01.png` | 16 (`hud/ui/card/`) | 卡框 / 9-slice / 按钮 4 态 / AP slot → 几何形状程序画 |

**例外可保留**：T sheet 的 9-slice 对话框纹理（`dialogue_9slice.png`）可作为 nine-slice texture。卡牌的 **正面插画** 走 H/I sheet（C 类）。

**Action**：标记这 64 张 UI sprite 为 reference-only（不删，留作 art-director 看 color/边框细节参考）。日后 PixiJS UI 代码以 art-bible §7 + 这些 mockup 为视觉锚。

---

### C — Sprite atlas（**应切**，游戏内主力素材）

每帧需要在游戏内独立显示、状态切换不可程序生成（NPC 表情、姿势、卡牌插画等）。

| 文件 | 切出数 | 路径 | 用途 |
|------|--------|------|------|
| `A_npc_archetypes_v01.png` | 9 | `npc/` | 9 NPC 原型头像 |
| `B_three_view_v01.png` | 8 | `character/turnaround/` | 玩家三视图 + 配饰特写 |
| `character_sheet_player_v01.png` | 13 | `character/` | 玩家 表情 / 姿势 / 状态 |
| `H_action_cards_defense_v01.png` | 9 | `cards/defense/` | 9 张防御卡正面插画 |
| `I_action_cards_offense_v01.png` | 9 | `cards/offense/` | 9 张进攻卡正面插画 |
| `J_hud_workstation_props_v01.png` | 16 | `hud/` | 便利贴 / 咖啡杯 / 显示器 / 桌椅 |
| `K_calendar_attendance_v01.png` | 16 | `hud/` | 考勤板 / 日历 / 通告板 *(注：考勤板字段可能也应程序画)* |
| `L/M_npc_faces_set1/2_v01.png` | 36 | `npc/faces/` | NPC × phase 表情头像 |
| `N1/N2_npc_positions_set1/2_v01.png` | 36 | `npc/positions/` | NPC × 站位全身 |
| `R_environment_v01.png` | 16 | `environment/` | 茶水间裂痕 / 植物 / 白板 / 灯管 |
| `S_npc_lifecycle_v01.png` | 16 | `npc/lifecycle/` | 离别 / 走路循环 / 喜丧 |
| `U_npc_event_cg_v02.png` | 16 | `npc/event_cg/` | 16 NPC × 2 emotion 立绘 |
| `V_misc_polish_v01.png` | 16 | `hud/` | 桌面渍 / 卡牌打出动画 / 便签累积 |

**Action**：保留 cuts.yaml 现有 grid mode 配置，质量可用。考勤板状态、KPI 数字这种数据驱动的 cell 在引擎里改用程序绘 + sprite 当背景。

---

### D — 裸场景背景图（**缺失，待重生**）

游戏内场景需要 **干净的底层背景**叠 sprite。当前没有，需要重生。

| 待生成 | 用途 | 关键 prompt 约束 |
|--------|------|----------------|
| 裸办公室俯视图 | 主场景地图层 | 无标题、无罗盘、无"第 X 集"、无 cell 编号、纯地板 + 工位 + 走廊网格 |
| 裸工位特写 | ACTION_DAY 主屏背景 | 等距单 cubicle，桌面 + 隔板 + 椅子 + 显示器空机位（NPC sprite 后续叠上） |
| 裸茶水间 | 茶水间场景背景 | 水机、水池、桌椅、唯一 4px 圆角空间，无文字 |
| 裸会议室 | 会议事件背景 | 长桌 + 椅子 + 白板（白板内容由白板 sprite 叠） |
| 裸 Boss 办公室 | Boss 事件背景 | 大执行办公桌 + 假植物 + 紫色边光区 |
| 裸走廊 | hallway 事件背景 | 单点透视走廊 + 日光灯 + 门 |
| 裸主菜单 BG | 主菜单背景 | 清晨空办公室，**无 title 文字**（title 由 Text 节点叠） |
| 裸 KPI Review BG | 月末考核背景 | 紫灰色 #3A3050 调办公室会议室，无标题文字 |

8 张 × $0.10 high quality ≈ $0.80。

**Action**：写 8 个新 prompt（强约束 "no text, no banner, no title, no decorative borders, pure background"），跑 high-quality batch，落到 `assets/sprites/backgrounds/`。

---

## Action 落盘

| # | 步骤 | 工作量 | 成本 | 状态 |
|---|------|--------|------|------|
| 1 | 移动 A 类 5 张到 `design/art/reference/concept/`；从 `cuts.yaml` 移除对应 single entry；写 README | 10 min | 0 | ✅ done |
| 2 | 在 `assets/sprites/ui/` 写 README 标记 B 类 64 张为 "reference-only" | 10 min | 0 | ✅ done |
| 3 | 写 8 个裸背景 prompt；跑 low-quality batch；落到 `assets/sprites/backgrounds/`；写 backgrounds README | 30 min + 跑图 ~10 min | **$0.24** (low 已够好，不需 high) | ✅ done |
| 4 | 更新 `sprite_mapping.yaml`：B 类 44 个 UI ASSET 标 `status: program_drawn`；asset_map.py 加新状态 | 10 min | 0 | ✅ done |
| 5 | 跑 `asset_map.py` 看新对账分布 | 1 min | 0 | ✅ done |

**实际成本 $0.24**（计划 $0.80 的 30%；low quality 出图已 production-ready）。

---

## 历史教训（写下供未来参考）

- **AI 生图擅长**：sprite atlas（独立 cell 内的插画 / 头像 / 立绘 / 卡牌正面）
- **AI 生图不擅长**：UI mockup（状态切换不灵活、文案不能本地化、小字 OCR 漂移）、需要透明叠层的裸背景（GPT-IMAGE-2 倾向加装饰边框 + 标题）
- **切图边界**：GPT 出 grid 不严格 uniform，cell 高度可能递减，detection 算法只能近似准（最终 ~80-90% 切干净，剩余靠 per-sheet hardcode `row_boundaries`）
- **下次 prompt 写法**：明确说 "uniform row heights, NO cell labels, NO numbered captions, only the sprite centered on cream background, NO title banner" 减少切图偏差
