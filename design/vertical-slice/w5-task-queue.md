# W5 Visual Asset Generator — Task Queue

> Status: live
> Author: GM
> Last Updated: 2026-05-06
> 收件人: W5 (visual asset generator clone)

---

## 当前唯一 task — Bug #15 Option A (sprite sheet label leakage)

### Spec

GM 试玩发现 `fruit_bowl_apple.png` 顶部有 "Front" + 底部有 "9:00" sheet label 文字残留。W5 round-1 自检估计 sprite scale ≥ 0.1 会糊掉，但 runtime 实际可见。同样 issue 影响 `xiaotian_polo` expression sub-sprites。

**Fix Option A** (per `p5-qa-bug-reports.md` Bug #15):

1. 编辑 `tools/cuts.yaml`：
   - `fruit_bowl_3frame_sheet.png` 那条 entry 的 `label_band` 从当前值 → **110**
   - `xiaotian_polo_sheet.png` expression rows 的 `label_band` 从 50 → **90**
   - 如果还有顶部 label leakage（"Front" 是 top 边）→ 加 `crop_top` 或 `row_top_skip` 增加 30 px
   
2. 跑切图：
   ```bash
   cd /Users/huanghaibin/Workspace/games/survived-episode-x
   python3 tools/cut_sprites.py
   ```
   
3. Sync 到 game 目录：
   ```bash
   cd game && pnpm assets:sync
   ```

4. **验证**：
   - `Read` `assets/sprites/hud/fruit_bowl_apple.png`，确认 "Front" + "9:00" label 不再可见
   - 同样 read `assets/sprites/character/turnaround_polo/expr_neutral.png` 等 6 张表情，确认 row label leak 不再可见

5. 写 short response 到 `design/vertical-slice/visual-asset-round-3-response.md` (5-10 行就够)

### 完了之后

W5 stand down。再有 visual 需求由 user 触发新 round（`p5-qa-bug-reports.md` Bug #15 listed alternative options B/C 备查）。

### Estimate

15-30 分钟（cuts.yaml 改 + 切图 + sync + verify）

### 不要做的事

- 不要重新 prompt 整张 sheet（贵 + 慢，仅 Option B fallback）
- 不要碰 `assets/sprites/test_outputs/` 源 sheet（保留以备未来重切）
- 不要 generate 新 sprite（NPC 立绘 / 状态变体 / 等）—— 那是 future round 的事

---

## END
