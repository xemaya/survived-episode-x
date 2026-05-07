# W5 Round 1 Reply (GM verdict + Round 2 决定)

> Status: 第 1 版
> Author: GM (designer)
> Last Updated: 2026-05-05
> 收件人: W5（visual asset generator 分身）
> 配套提交: `visual-asset-round-1-response.md` + 23 张 sprite (10 主 + 13 切片) 已 sync 到 `game/public/sprites/`

---

## TL;DR

**整批 PASS**。

W5 是这一批 worker 里 throughput 最高的——10 张 prompt 全首发命中，0 次 prompt 修改，$1.30 在预算下限。且 W1 已经直接集成（PropRegistry 加 phone / fruit_bowl 接 ink `# prop:` tag）—— production-ready confirmed by integration。

GM 抽样视觉 review 4 张 critical sprite（lin_jie / mom_video_call / bank_app_push / fruit_bowl_apple / xiaotian polo expr_neutral + expr_resigned）：

| Sprite | 验收 |
|---|---|
| **lin_jie.png** | ✅ 视觉 3 件套 hit (黑西装 + 红文件夹"客户成功部" + 运动鞋部分见). 表情 neutral confident — 跟 Pillar 4 "她不要笑天" 一致 |
| **mom_video_call.png** | ✅ 58 yo + 盐霜 + 老花镜推额 + 深色毛衣 + 厨房 BG 全 hit. 视频 UI 上下框完整 |
| **bank_app_push.png** | ✅ 余额低于安全线 visual 黑色幽默极致. 房贷 ¥4,500 vs 余额 ¥4,387 = 不可能三角"钱多" 反讽 perfect. 中国某商行 banner generic placeholder 安全 |
| **fruit_bowl_apple.png** | ✅ 主体对，但 sheet label 残留（W5 已自检 §限制 #2）|
| **expr_neutral / expr_resigned** | ✅ 灰 polo + 无 navy suit / 无红领带 hit |

W1 已经在 PropRegistry 用 phone (face_down/face_up/with_badge) + fruit_bowl (apple/strawberry/empty) — production integration 成立。

---

## 1. ⚠️ Round 2 必修（1 处 + 1 处可选）

### 1.1 `expr_resigned.png` 内容 ↔ 文件名 mismatch（必修）

**问题**：`tools/cuts.yaml` 把 polo sheet row 2 col 3 mapped 到 `expr_resigned`，但实际 sheet 那个 cell 的 label 是 "03 困倦/TIRED"。文件名说 resigned，内容是 tired。

**Resolution 选项**:
- **(A)** 修 cuts.yaml 让 row 2 col 3 → `expr_tired_v2`（或别的不冲突名），重新 cut + sync
- **(B)** 检查 sheet 内 6 个 cell 的实际表情 vs 期望 6 表情 (expr_neutral, expr_slight_frown, expr_tired, expr_pro_smile, expr_genuine_smile, expr_resigned)，重新 prompt 一张 sheet 让 6 cell label 跟期望对齐
- **(C)** 留着不改——"resigned" 跟 "tired" 在 indie context 下情感差异不大，W1 mount sprite 时按文件名拿，玩家不会感知

**GM 决定**: **(C) 暂时留着**，但 round 2 短 audit 一遍——审 6 个 polo expression file 各自实际显示表情 vs 文件名的对应度。如果 ≥ 2 个文件 mismatch，那时再考虑 (A) 或 (B)。

W5 round 2 任务（如启）= 5 分钟 audit + 把 mapping 写到 `visual-asset-round-2-response.md` 里。

### 1.2 sheet label leakage（acceptable，可选打磨）

**已知 limitation**：cut 出的 fruit_bowl + polo sub-sprite 边缘有 1-2 px sheet label / banner 残留（per W5 §限制 #1-2）。

**GM 决定**: ✅ **接受**，不修。理由：
- W1 渲染时 sprite scale ≥ 0.1—0.18，1-2 px label 残留肉眼基本不见
- 修需要重 prompt sheet（额外 $0.13 × N）+ 重 cut + 重 sync — 不值
- P5 demo 完成后 P6 视觉打磨期再处理（如果届时还在意）

---

## 2. 6 个 Round 2 candidate 决定

W5 §Open Questions 列了 6 个 round-2 candidates。GM 决定如下：

| # | candidate | 决定 | 理由 |
|---|---|---|---|
| 1 | 食堂阿姨多帧（端食物/不说话/哼歌）| ⚪ **defer to P6** | 单 portrait 已够 ambient flavor. 多帧值在 P6 打磨期再考虑 |
| 2 | Lin jie "私下温和" 表情变体 | ❌ **don't make** | Pillar 4 deliberate restraint——林姐**不**对笑天温和. 加私下温和版 = 削弱 "她不要笑天" 的核心信号 |
| 3 | mom video call 表情/状态变体 | ⚪ **defer to P6** | 单 still 99% 出场覆盖 OK. S3 笑天关掉视频 + S5+ 妈妈视频极少出场 — 单帧就够 |
| 4 | xiaotian over-shoulder POV 版 | ⚪ **defer** | over-shoulder 是 P6 视觉打磨期的事. 当前 cutscene + Decision Moment 用 turnaround 立绘已 cover |
| 5 | phone 状态变体（屏亮/碎/指纹）| ❌ **don't make** | 3 态 (face_up / face_down / with_badge) 已 cover Lisa 微信 / 银行 push / 装病时屏幕碎 = 0. **指纹解锁 = 不需要 visual** (玩家不解锁手机, 玩家就是手机 owner) |
| 6 | bank_app_push 其他通知变体（信用卡/工资/红包）| ✅ **可启 round 2 if needed** | 工资到账 push 是 series anchor (S1 E1 D1 / 每月 25 号触发). 红包是 endgame 关联 (S12 春节). 信用卡还款 push = anti-Pillar 1 升级版 visual. **如果 W3 / 后续 ink writer 在 .ink 里写到这些场景需要 visual prop, 再启 W5 round 2 generate 这 3 张**——目前 episode-1 ~ episode-8 没有 trigger 这些 push 的 stitch, 所以**不立刻生成** |

**总结**: round 2 不立刻启动。W5 任务 effectively closed。如果未来 ink writer 写到 #6 的具体场景需要 visual prop，再 user-trigger W5 round 2（约 $0.40，3 张 sprite）。

---

## 3. ✅ W5 closed (round 1 final)

W5 visual asset round 1 = **CLOSED**。

W5 self-check + production integration 都 pass。1 处文件名 audit 是 5 分钟工作（W5 自己回覆即可，不需重新生成 sprite）。

---

## 4. Outstanding visual asset gaps（不是 W5 的活，记录给未来）

为未来 worker 留 reference——这些 sprite 当前**不存在**但可能未来需要：

| asset | 用途 | priority | 触发条件 |
|---|---|---|---|
| Lisa 短发版 立绘 | S2 E7+ Lisa visual identity 转换 | **P0** for S2 demo | W1 集成 Lisa NPC sprite slot 时即需 |
| Lisa 转岗后办公装 | S3 finale 路径 A 林姐部门 Lisa | P2 | S3 ink demo |
| David 不耐烦表情 | S2 E5+ David 燃尽前兆 | P2 | S2 / S6 demo |
| Wang director 独立办公室门 BG | S3 E11 王总监打电话 scene | P3 | S3 ink demo |
| Zoe HR 工位 BG | S2 E8 + S3 E10 处刑 scene | P2 | S2 / S3 ink demo |
| 工资到账 bank_app push | 每月 25 号触发 visual | P1 | next round | W3 .ink 加触发 stitch |
| 信用卡还款 push | S5+ 不可能三角"钱多" 反讽 | P3 | S5 ink demo |
| 春节红包 push | S12 endgame | P5 | endgame demo |

**这些不是 W5 round 2 任务**——是未来 W5 / 新 visual worker 的 backlog。

---

## END
