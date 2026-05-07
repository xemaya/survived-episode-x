# W5 Round 2 — Polo Expression Audit

> Status: 第 1 版（仅 audit，无新 sprite 生成）
> Author: W5 (visual asset generator 分身)
> Last Updated: 2026-05-06
> 收件人: GM
> 配套: Round 1 reply §1.1 audit task

---

## TL;DR

**0 处 file-content mismatch**。GM 在 `expr_resigned` 看到的 "03 困倦/TIRED" label 不是文件内容错误——是 **sheet row 1 cell 3 的 label 文字 leak 到了 row 2 cell 3 cut 的顶部**（已在 round-1 §限制 #1 提过的 sheet label leakage 问题）。

cuts.yaml mapping 6/6 全对：行列位置 → cell face content 对应正确。round-1 决定 (C) **留着不改** 仍成立。

---

## Audit 方法

逐张读取 6 个 expr 文件，对照 sheet `xiaotian_polo_sheet.png` 内 6 个 cell 的实际 face content，然后跟 cuts.yaml mapping 对比。

| File name | Sheet cell 位置 | 实际 face content | label leakage（top） | 内容 ↔ 文件名 match? |
|---|---|---|---|---|
| `expr_neutral.png` | row 1 col 1 (01 平静) | 平静脸 (eyes open + flat mouth) | top banner "Chen Xiao..." | ✅ match |
| `expr_slight_frown.png` | row 1 col 2 (02 微皱眉) | 微皱眉 (slight 眉头 ↓ + 嘴角 ↓ 1px) | top banner "...gray polo turnaround..." | ✅ match |
| `expr_tired.png` | row 1 col 3 (03 困倦) | 困倦 (半眯眼 + 黑眼圈) | top banner "v01 navy)" | ✅ match |
| `expr_pro_smile.png` | row 2 col 1 (04 公事微笑) | 公事微笑 (单边嘴角 ↑ + 死眼) | row 1 label "01 平静 / NEUTRAL" leak | ✅ match (内容是 04, label leak 是 01) |
| `expr_genuine_smile.png` | row 2 col 2 (05 真笑) | 真笑 (两边嘴角 ↑ 1px + 眼角微皱) | row 1 label "02 微皱眉 / SLIGHTLY FROWNING" leak | ✅ match |
| `expr_resigned.png` | row 2 col 3 (06 认命) | 认命 (闭眼 / 半眯 + 嘴角 ↓ 1px) | row 1 label "03 困倦 / TIRED" leak | ✅ match |

**结论**：6/6 文件 face content 跟 mapping 期望对齐。GM 看到的 mismatch 是 row 1 的 label 字带 leak 到 row 2 cut 的 top 区域——cuts.yaml `crop_top=50` + `label_band=50` 在 row 2 边界处没截干净。

---

## 解释 leak 几何

Sheet 内 row 间布局（自上而下）：
```
y=0-50      title banner
y=50-245    row 1 face cells (01/02/03)
y=245-295   row 1 labels ("01 平静/NEUTRAL" 等)
y=295-485   row 2 face cells (04/05/06)
y=485-540   row 2 labels ("04 公事微笑/SLIGHT SMILE" 等)
y=540-...   row 3 (poses)
```

cuts.yaml row 2 cut: `y=[295, 540]` with `label_band=50` → final y=[295, 490]。
Row 1 label 在 y=245-295 — 我的 cut start y=295 应该 just-clip 但 GPT-IMAGE-2 输出的 label 实际位置略 vary（pixel-level rendering inconsistency），所以 1-2 px label 文字 leak 进了 row 2 cut 顶部。

**几何上，要彻底消除需要**：把 row 2 起始往下推 5-10 px（如 crop_top=305），或加 `row_top_skip` per row。但 round-1 reply §1.2 GM 已经决定**接受 sheet label leakage**（renders 时 sprite scale ≥ 0.1，1-2 px label 残留肉眼基本不见）。

---

## 决定（per GM round 1 §1.1 option C）

✅ **留着不改**。理由：
1. 6/6 文件 content 跟 mapping 期望对齐，dev 按文件名 mount 出来的就是期望表情
2. label leakage 跟 round-1 已知 limitation 同源（fruit_bowl 也有），统一 P6 视觉打磨期再处理
3. 不重新 generate sheet（省 $0.13）+ 不重 cut + 不重 sync — 0 增量花费

---

## W5 round 2 status

✅ **CLOSED with 0 incremental spend**。

Audit 5 分钟内完成，结论 = 不需要 prompt 修改 / 不需要重生成 / 不需要重 cut。

如果未来 ink writer 在 .ink 里写到 GM round-1 reply §4 outstanding gaps 列出的 visual prop 触发条件（工资到账 push / 信用卡还款 push / 春节红包 push / Lisa 短发版 / etc.），可以 user-trigger W5 round 3。本 round 不预启。

---

## END
