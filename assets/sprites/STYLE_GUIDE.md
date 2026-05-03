# 美术风格指南 — 《活过第 X 集》

让所有 AI 生成的资源保持同一视觉宇宙。**写新 prompt 时套这个模板,生成出来的图就跟现有 reference 接得上。**

---

## 1. 视觉锚点(每个 prompt 都要带)

### 1.1 整体风格 vocabulary

```
Style: SFC/16-bit pixel art, visible pixel grid, no anti-aliasing on outlines,
limited 16-color palette. NOT vector or smooth modern illustration.
Visual identity goal: "first glance recognition, second glance indictment"
— a familiar Chinese office aesthetic that quietly broadcasts dread.
Mood: dark humor / 喜丧美学 (funeral-as-festival).
```

实测下来 GPT-IMAGE-2 最关键的几个词:
- `SFC/16-bit pixel art` — 锁定时代感
- `visible pixel grid, no anti-aliasing` — 防止它走 modern smooth illustration
- `limited 16-color palette` — 锁定调色板

### 1.2 严格调色板(每个 prompt 都列)

```
STRICT COLOR PALETTE:
- 打工人黄 #C8A85A (skin highlight, fluorescent-lit yellow)
- 格子间灰蓝 #5A7080 (cubicle walls, UI backgrounds — dominant)
- 档案室棕 #7A5838 (wood, accent)
- 白炽灯白 #E8E0CC (ceiling, paper, light pools)
- 屏幕蓝 #2C4A6E (monitor glow, overtime atmosphere)
- 老板金 #E0B050 (gold accent — STRICT max 3% pixel coverage, only on power/boss elements)
```

写小写描述也行,但**列 hex 比"navy / dark blue"更稳**。

### 1.3 玩家角色锚点(出现玩家时必带)

```
PLAYER CHARACTER (consistent across all sheets):
A weary middle-aged Chinese male office worker, late 30s.
- Default black short hair (no shine highlight)
- Navy business suit, slightly rumpled
- White shirt, loosened red tie
- Stainless steel thermos cup permanently held in LEFT hand
  (3px raised silhouette protrusion — his signature contour element)
- Slightly hunched body, low visual weight ("已经在这待了很久" feel)
- Employee lanyard with badge around neck
```

**B_three_view_v01.png(三视图)是这个角色的工程级 anchor**。后续如需更精准一致性,可在 prompt 里加 "based on the turnaround sheet anchor — same character, same proportions"。

### 1.4 9 NPC 原型(出现 NPC 时套用)

每个 NPC 必带的剪影特征(art-bible 5.2):

| 原型 | 关键剪影词 |
|---|---|
| 卷王 Tryhard | spine +2px taller, perfectly knotted tie, eye bags 3px, single cold coffee, sticky notes covered in writing |
| 摆烂族 Slacker | one shoulder dropped 4px lower, leaning back, phone reflection on face, half-hidden novel |
| 谄媚族 Toady | oval face, chin pushed forward 2px, hands clasped at chest, "agreeing" mouth shape |
| 新人 Rookie | narrow build, slightly long neck, hands clasped between knees, bewildered, tangled lanyard |
| 老油条同行 Veteran | similar to player BUT rounder thermos (cylinder 2px wider), orange folder (player's is gray), slippers under desk, knowing wink |
| 清洁阿姨 Cleaning Auntie | short and wide build (+4 width, -6 height), mop as third leg of silhouette |
| Boss | silhouette top +8px taller, hands clasped behind back, widest tie, looking down at viewer, gold tie clip |
| HR | level shoulders, folder tucked under arm, **empty-frame glasses (no lenses!)**, "人才/Talent" mug, green plant on desk |
| 隔壁部门代表 Other Dept Rep | BLUE color scheme (#3a5a85) vs others' gray, prominent badge, walking pose, polite business card smile |

---

## 2. 标准 prompt 结构

复制这个骨架,填具体内容:

```
A pixel art [TYPE: scene illustration / character sheet / UI mockup / card sheet]
for a Chinese office life game. [§1.1 风格 vocabulary]

[LAYOUT 描述 — 网格 / 单图 / 分屏]

[CONTENT 主体描述 — 角色 / 场景 / UI 元素 / 卡牌]
- 出现玩家:粘贴 §1.3
- 出现 NPC:粘贴 §1.4 对应原型描述
- 场景:点出环境关键元素(工位 / 会议桌 / 老板办公室 / 茶水间 / 电梯)

[§1.2 严格 palette]

[VISUAL JOKES / 喜丧触发 — 1-3 个 1-3px 的小细节,art-bible 喜丧美学]
- 茶杯有 1px 蒸汽
- 单独一只苍蝇 2px
- 谁的领带是直的(暗示性格)
- 时钟具体时间(深夜 23:47 / 准点 17:01 等)

[TITLE BANNER — 中文为主 + English subtitle,GPT-IMAGE-2 中文渲染稳]

Output: PNG, 1024x1024, [single composite / split panel / 3x3 grid], ready for in-game use.
```

实测要点:
- **prompt 长度 1000-2000 字 sweet spot**;< 500 字效果会通用化,> 3000 字 GPT 自由发挥比例上升
- **Title banner 在 prompt 末尾比开头更稳**(模型把它当 final touch 而不是大纲)
- **中英 label 都给**,模型会两种都画上去,辨识度更好

---

## 3. 已生成 reference 清单(锚点)

后续生成新图时可以引用 "consistent with prior reference sheets like [filename]":

| 文件 | 内容 | 用途 |
|---|---|---|
| `test_outputs/character_sheet_player_v01.png` | 主角 13 sprite(6 表情 + 4 姿势 + 3 状态) | 玩家锚点 |
| `test_outputs/A_npc_archetypes_v01.png` | 9 NPC 原型 3×3 | NPC 锚点 |
| `test_outputs/B_three_view_v01.png` | 主角三视图 + 5 配饰特写 | animation reference |
| `test_outputs/C_world_map_v01.png` | 办公室俯视图 8 区域 | world layout |
| `test_outputs/D_character_detail_page_v01.png` | 角色详情页 UI mockup | UI 风格锚 |
| `test_outputs/E_monthly_review_v01.png` | 月会 cutscene | 场景锚(会议室) |
| `test_outputs/F_overtime_scene_v01.png` | 加班 cutscene | 场景锚(夜晚 / 蓝光) |
| `test_outputs/G_game_over_v01.png` | 双结局 | UI/cutscene 锚 |
| `test_outputs/H_action_cards_defense_v01.png` | 防御套牌 9 张 | 卡牌框模板 |
| `test_outputs/I_action_cards_offense_v01.png` | 进攻 + 关系套牌 9 张 | 卡牌框模板 |

---

## 4. 已知 limit(不要踩这些坑)

1. **小字 OCR 漂移** — 茶杯刻字 / 卡背小说明 / 地图 sticky note 这种 < 20px 的小字会随机变成"看似中文但不是字"的 OCR-style 噪声。**Title 级别的中文(标题、label)稳**,小字别指望。

2. **真 NES 古风像素出不来** — GPT-IMAGE-2 输出的是 "high-resolution illustration with pixel art aesthetic",有亚像素抗锯齿。如果要严格 32×32 hard-edge sprite,需要后处理(降采样 + palette quantize)或换 Retro Diffusion API。这套游戏的现代 indie pixel 调子完全够用。

3. **同一角色跨张稳定性 ~80%** — 不是 100% 一致。重要场景(玩家立绘、9 NPC 原型)用大设定图一次出齐,跨张需要靠 prompt 描述对齐。

4. **gold accent 会失控** — 只要 prompt 里出现 "gold" / "金色" 就容易铺满。规则严格写"max 3% pixel coverage, only on [具体物件]"。

5. **3x3 grid 等分稳,unequal layout 漂** — 卡牌 9 张严格切对齐,但带 sub-banner 的角色图鉴模板需要 `tools/cuts.yaml` 手调每行 `row_top_skip` / `label_band`。

---

## 5. 加新图的工作流

```
1. 决定要什么:写一行 brief (e.g. "茶水间偶遇场景,玩家 + 卷王 + 八卦氛围")
2. 套 §2 模板写 prompt → /tmp/pixel_test/prompt_<name>.txt
3. 调 deerapi gpt-image-2 (参考 tools/ 现有脚本,quality=low ~$0.03)
4. 落到 assets/sprites/test_outputs/
5. 在 tools/cuts.yaml 加切割配置,跑 python3 tools/cut_sprites.py
6. 切出的 sprite 进 assets/sprites/<category>/,直接给 Godot import
```

**省钱建议**:第一发用 `quality=low`($0.03)看构图对不对,定稿了再用 `quality=high`($0.10)出最终版。低质量稿足够定 layout / palette 了。

---

## 6. 调用 API 模板(复制即用)

```python
import json, urllib.request, base64, os
key = os.environ['DEERAPI_KEY']
body = {
    'model': 'gpt-image-2',
    'prompt': open('your_prompt.txt').read(),
    'n': 1,
    'size': '1024x1024',
    'quality': 'low',          # or 'high' for final
    'output_format': 'png',
}
req = urllib.request.Request(
    'https://api.deerapi.com/v1/images/generations',
    data=json.dumps(body).encode(),
    headers={'Authorization': f'Bearer {key}', 'Content-Type': 'application/json'},
)
resp = json.loads(urllib.request.urlopen(req, timeout=180).read())
png = base64.b64decode(resp['data'][0]['b64_json'])
open('output.png', 'wb').write(png)
```

---

## 一句话

**所有 prompt 都套 §2 骨架 + §1 锚点 + §1.2 palette,产出就跟现有 reference 接得上。**
art-bible 是真理,这份指南是它的"AI 实施版"。
