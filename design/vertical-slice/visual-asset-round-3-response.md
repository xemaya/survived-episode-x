# W5 Round 3 Response — 9 named NPC 立绘

> Date: 2026-05-06
> Worker: W5
> 配套 brief: `w5-round-3-handoff.md`

---

## 交付清单

9 NPC × 2 size = 18 files in `assets/sprites/npc/` (+ staging copy in `assets/sprites/test_outputs/round3_*`)。1024 source 在 `design/concepts/p5-assets/round3_*.png`。

| # | NPC ID | portrait (64×96) | LOD0 sprite (32×48) |
|---|---|---|---|
| 1 | `lisa` | `npc/lisa.png` | `npc/lisa_sprite.png` |
| 2 | `david` | `npc/david.png` | `npc/david_sprite.png` |
| 3 | `wang_director` | `npc/wang_director.png` | `npc/wang_director_sprite.png` |
| 4 | `vivian` | `npc/vivian.png` | `npc/vivian_sprite.png` |
| 5 | `zoe` | `npc/zoe.png` | `npc/zoe_sprite.png` |
| 6 | `lao_zhou` | `npc/lao_zhou.png` | `npc/lao_zhou_sprite.png` |
| 7 | `li_ayi` | `npc/li_ayi.png` | `npc/li_ayi_sprite.png` |
| 8 | `mama` | `npc/mama.png` | `npc/mama_sprite.png` |
| 9 | `it_xiaoma` | `npc/it_xiaoma.png` | `npc/it_xiaoma_sprite.png` |

每张 64×96 portrait ~12 KB, 32×48 sprite ~3-4 KB. 全部 RGBA 透明 BG（**不是 cream rect**——chroma-key 处理过，per handoff 强调）。

---

## DeerAPI cost

| 阶段 | 数量 | 单价 | 小计 |
|---|---|---|---|
| Low quality (verify 构图) | 9 | $0.03 | $0.27 |
| High quality (final) | 9 | $0.10 | $0.90 |
| **总** | | | **$1.17** vs 预算 $1.30 ✓ |

Low → high 0 张返工，prompt 全首发命中。

---

## Pipeline

1. 写 9 prompts → `design/concepts/p5-assets/round3_<id>_prompt.txt`
2. Low-q batch (并行) → 4 张 sample 验构图
3. High-q batch (并行)
4. **Post-process** (`tools/round3_chroma_resize.py`)：
   - white pixel ≥#F5F5F5 → alpha 0 (chroma-key)
   - bbox crop content + 20px pad
   - fit-to-canvas resize → 64×96 portrait + 32×48 sprite
5. `pnpm assets:sync` → 306 PNG (was 288 = +18 new) 落 `game/public/sprites/`

---

## Style consistency self-check

- [x] **透明 BG** ✓ — round-3 hard requirement，post-process chroma-key 全 9 张. 验证：每张 cropped bbox (657-948 wide × 1002-1024 tall) 远小于 1024² source = 大量 white BG 已 keyed
- [x] **6 色 palette** 严格遵守，仅 wang_director 用了 老板金 (`#E0B050`) 在 tie clip + pen clip (~2% pixel, 在预算内)
- [x] **NPC 剪影特征** per art-bible §5.2:
  - lisa: 灰 polo + 奶茶杯 + 长发 (S1 anchor)
  - david: 垂直脊柱 + 颈前伸 + 衬衫挽袖 + 保温杯 + 便利贴堆 + 多挂工牌
  - wang_director: +8 px 高 + 衬衫挽袖 + 最宽领带 + 金领带夹 + 双手背后
  - vivian: 工装 + 红口红 + 假珍珠 + 服务微笑
  - zoe: HR 黑西装 + **空框眼镜** (无镜片！) + 文件夹腋下 + 平肩 + 公司吉祥物钥匙圈
  - lao_zhou: 灰 polo (跟笑天 visual mirror) + 微弓背 + 圆形茶杯 + 5 周年纪念笔
  - li_ayi: 矮宽 silhouette (+4 -6 px) + 蓝清洁服 + 拖把作第三支腿 + 外包工牌 + 围裙手机像素画
  - mama: 58 yo + 盐霜头发 + 老花镜推额 + 深色毛衣 + 深前倾老花眼姿势
  - it_xiaoma: 黑帽 T + 工具包 crossbody + **工牌挂裤腰** (anti-corp signal) + 螺丝刀
- [x] **不要做的事** 全部规避：
  - ✗ 不重做 lin_jie / cafeteria_auntie ✓
  - ✗ 不生成 prop sprite ✓
  - ✗ 不生成 NPC scene event_cg ✓
  - ✗ 不出 cream rect BG ✓ (chroma-key 后透明)

---

## 已知 limitation

1. **chroma-key 边缘 1-2 px halo**：GPT-IMAGE-2 输出的字符边缘有亚像素抗锯齿混色（接近白但不是纯白），threshold=245 的 chroma-key 有时会保留 1-2 px 灰白晕边。在 64×96 + 32×48 的小尺寸下肉眼几乎不可见，但严格观察可见。可接受——P6 视觉打磨期再升级 alpha 阈值或加 anti-halo erosion。
2. **32×48 LOD 0 sprite 颗粒度极粗**：1024 源到 32×48 是 ~32x 降采样，细节大量丢失（lanyard / 纽扣 / 视觉玩笑 hard to see）。LOD 0 主要起 silhouette identification 作用——身高/姿势/主色调能分辨 NPC 即可。互动特写用 64×96 portrait。

---

## Stand down

W5 round-3 = **CLOSED**。W1 拿 sprites 后启 T05/T06 NPC sprite slot mount task。

下次 round 触发条件: ink writer 写到新 NPC visual prop（如 round-1 reply §4 的 Lisa 短发版 / 工资到账 push / 红包 / 信用卡还款 push）。本 session stand down。
