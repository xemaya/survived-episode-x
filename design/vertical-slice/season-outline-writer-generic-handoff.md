# W6 · Season Outline Writer (Generic, S4-S12 + Endgame) · Handoff Brief

> Status: 第 1 版（generic 模板，W4 已用 S3-specific 版本启动；本 brief 给 W6 + 后续）
> Author: Game Designer (GM)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——新启动的 Claude Code session

> **本次任务参数（启动时由 GM 填）**：写 **`season-N-arc.md`** for **N = ___**（S4 / S5 / S6 / S7 / S8 / S9 / S10 / S11 / S12 / Endgame 任一）

---

## 0. 你的处境

`survived-episode-x` 13 季 52 集。GM 已写 S1-S3 outlines（`season-1-arc.md` v2 + `season-2-arc.md` + `season-3-arc.md`，最后一个由 W4 写完）。你的活：**按同样格式写指定 N season 的 outline**，未来 ink writer 据此写对应 episode .ink。

S3 之后的 season 没有 Lisa 走/留 那种"全 series 第一情感高峰"等级——但每个 season 都有自己的关键 finale beat（per `series-structure.md` §2 表）。

完成后 **GM** review。

---

## 1. 必读 reference（按顺序）

1. **`design/vertical-slice/season-1-arc.md`** v2 — **格式模板**（10 sections + per-NPC 4-archetype + cross-NPC matrix + per-episode beat sheet + finale 路径表 + Quality Rubric）
2. **`design/vertical-slice/season-2-arc.md`** — 第 2 个模板
3. **`design/vertical-slice/season-3-arc.md`** — 第 3 个模板（W4 写）+ Lisa finale 处理范例
4. **`design/vertical-slice/series-structure.md`** — **52 集 macro，§2 表是每季主题 + finale 的 source of truth**。你的任务 N season 的所有关键决策（主题 / finale beat / NPC arc 边界）都已锁在这里
5. **`design/vertical-slice/npcs.md`** v2 — 10 NPC 长弧光（特别看你写的 N season 哪些 NPC active / 哪些 finale 在你这季）
6. **`design/vertical-slice/protagonist.md`** §9 — 笑天每季的 voice 演变
7. **`design/vertical-slice/tone-bible.md`** v2

---

## 2. 任务参数（启动时确认）

**N 是哪一个**：
- **S4** = E13-E16, Game-month 4, 主题 "David 燃尽前兆"
- **S5** = E17-E20, Game-month 5, 主题 "新人入场"（实习生入职 → 笑天首次被叫"陈哥"）
- **S6** = E21-E24, Game-month 6, 主题 "David 燃尽离职 finale"
- **S7** = E25-E28, Game-month 7, 主题 "半年了——KPI 累积压力到点"
- **S8** = E29-E32, Game-month 8, 主题 "李阿姨退休 finale"（**没有任何 UI 提醒**——某个早晨发现没人倒水了。Pillar 3 最纯）
- **S9** = E33-E36, Game-month 9, 主题 "王总监被换 finale"（新总监空降）
- **S10** = E37-E40, Game-month 10, 主题 "猎头电话"（笑天 decision: 跳？留？）
- **S11** = E41-E44, Game-month 11, 主题 "组织调整传言"（集体焦虑高峰）
- **S12** = E45-E48, Game-month 12, 主题 "12 月 KPI 冲刺"（笑天最难一关）
- **Endgame** = E49-E52, Game-month 年终, 主题 "春节回家 + happy ending 多变体"（这个 season 最特殊，4 集 special arc 而非常规 4 集结构）

每个 season 的具体 finale beat 详见 `series-structure.md` §2。

---

## 3. 写作方法

### Step 1: 读所有 reference（1-2 小时）

特别注意 `series-structure.md` §2 表你的 N row + §3 表（NPC 跨 series 弧光，看哪些 NPC 在你的 season finale）。

### Step 2: 复制 `season-2-arc.md` 作起点（Endgame 例外）

`season-2-arc.md` 有 12 sections + 完整 per-NPC × per-episode 表，是最近写的最好模板。**复制其结构**到你的新文件：

```
1. 主题 + 笑/泪曲线
2. Beat Archetypes (reference §2 of season-1-arc.md)
3. Per-NPC Arc Tables (10 NPC × 4 episodes for N season)
4. Cross-NPC Scenes Matrix (N-specific 同框场景)
5. Per-Episode Beat Sheet (E?? - E??)
6. N Finale 路径表 (5 paths if N has finale; 1 path if N is mid-season pace setter)
7. Quality Rubric (reference §7 of season-1-arc.md)
8. (Optional) Migration Note from previous season's content
9. 给 ink writer 的 use 说明
10. 设计自检
11. ❌ N 不能做的事
12. 下一步
```

### Step 3: 填具体内容

用 `series-structure.md` §2 表你的 N row 作纲，参考 `npcs.md` 各 NPC 的"未来弧光种子" §（如 `npcs.md` §2 David 的 S6 燃尽种子 = 你写 S5/S6 的 input）。

### Step 4: 4 集 beat sheet（最难）

每集 7 天 beats：周一 morning_briefing → 各 events → 周日妈妈视频 + cliffhanger。

**关键 beats**（每集都要有）：
- 至少 1 次 cross-NPC 同框场景
- 至少 1 个"想知道下一集"的 cliffhanger（per §6 cliffhanger 行）
- Lisa 弧光 callback（如果路径 A 留下：每集出现 1 次；路径 B-E 走了：每 2 集 1 次 mention through 朋友圈 / 微信群头像）
- Per-NPC archetype 实例化 (per §3)

### Step 5: Finale 路径表（per §6）

如果 N 有 finale：参考 `season-1-arc.md` §6 + `season-2-arc.md` §6 写 5 路径。每条路径都"过"但都"扎不同痛点"。

例：
- **S6 finale = David 燃尽离职**：5 路径取决于 S1-S5 玩家对 David 的态度（帮过他多少次 / 配合他多少次 / 揭穿过他几次）
- **S8 finale = 李阿姨退休**：5 路径取决于玩家累积"跟李阿姨主动 chat"次数 / 是否听到她跟另一个清洁阿姨的话 / 是否在她拖地时帮她
- **S9 finale = 王总监被换**：5 路径取决于玩家是否做 yes-man / 是否被王总监 mark "high performer" / 是否目睹过他工位灯还亮
- **Endgame**：6 happy ending variants（**已在 series-structure.md §5 ready** — 你只是落实成 episode-level beat sheet）

### Step 6: 笑/泪曲线

参考之前 season 的曲线（S1=7:3 / S2=5:5 / S3=3:7）。每个 season 的曲线根据其 finale 性质：
- David 燃尽 (S6) → 笑泪 = 4:6 (David 失态搞笑 + 离职扎心)
- 李阿姨退休 (S8) → 笑泪 = 6:4（笑点很安静 + 扎得很轻很深）
- 王总监被换 (S9) → 笑泪 = 7:3（讽刺 + 反高潮，但不扎 — 王总监不值得扎）
- 猎头电话 (S10) → 笑泪 = 5:5（决策瞬间）
- 组织调整 (S11) → 笑泪 = 4:6（集体焦虑）
- 12 月冲刺 (S12) → 笑泪 = 3:7（这一年的累积）
- Endgame (春节) → 笑泪 = 7:3（warm，不是哭哭啼啼）

参考 `series-structure.md` §3.3 整 series 笑泪比 ≈ 8:2 — 你的 season 曲线要 contribute 到这个总平均。

---

## 4. Endgame 特殊（如果你 N = Endgame）

Endgame 不是常规 4 集 outline——是 **4 集 special arc**（per `series-structure.md` §4）。

**E49** 公司年会 / **E50** 年终奖打卡 / **E51** 春节假期前一天 / **E52** 春节回家最后一晚 → happy ending。

每集主题已 lock 在 `series-structure.md` §4。你的任务：
- 把 series-structure.md §4 每集"集内高峰"扩展成完整 7 天 beat sheet
- 落实 6 个 happy ending variants 的具体触发条件 + ink-ready 文案（参考 series-structure §5 的 6 个 variant 已 draft）
- 跟其他 season finale 的 beat 衔接（especially S12 finale = E48 KPI Review 通过 → E49 入场）

---

## 5. 关键约束（不能违反）

跟 W4 (S3) 同：

- 偏离 series-structure.md §2 表你的 N row 主题 = 重写
- 引入 npcs.md 未注册的新 NPC（除非 N = Endgame，可能需要"前同事老李 / 同学聚会朋友"等 endgame-only 出场）
- 不在指定 episode 触发关键 beat（如 David 燃尽 = E24 不能挪到 E23 / E25）
- 5 路径里有"赢"路径 — 必须 5 路径都"扎"（per Pillar 3）
- 笑天 voice 走"励志/突破"基调

---

## 6. 软性要求（不达 ≥ 3 = 修订）

- 笑/泪曲线偏离推荐
- Per-NPC × per-episode 表完整度 < 90%（每集每 NPC 至少 1 个 beat，除背景 NPC）
- Cross-NPC 同框场景 < 6 跨 4 集
- 老周说出 ≥ 1 句话（S1 唯一对话已耗尽，S2 起完全沉默 — 直到 S8 退休）
  - **Exception**：S8 finale 李阿姨退休 stage 老周可能通过沉默 acknowledge（非对话）
- Lisa motif callback 频率不对（路径 A：每集 1 次；路径 B-E：每 2 集 1 次远端 mention）
- 妈妈视频每周日 8:30 必出现（per `npcs.md` §9）
- finale beat 文案不达 series-finale 级别

---

## 7. 提交格式

写 `design/vertical-slice/season-N-arc.md` 完整文件 + 1 页 progress note：

```markdown
## W6 提交报告 — Season N outline (where N = ___)

### 输出
- design/vertical-slice/season-N-arc.md (XXX 行)

### Section 完成度
- §1 主题 + 笑/泪曲线 ✓
- §2 4 archetype reference ✓
- §3 Per-NPC arc tables ✓
- §4 Cross-NPC scenes ✓
- §5 Per-episode beat sheet ✓
- §6 Finale 路径表 ✓ (5 paths if season has finale)
- §7 Quality Rubric reference ✓
- §8 (Migration / Cross-season notes 如有) ✓
- §9 给 ink writer 的 use 说明 ✓
- §10 设计自检 ✓
- §11 ❌ 不能做的事 ✓
- §12 下一步 ✓

### NPC 在 N season 出场 / 退场总结
- David: ... (S4-S6 active)
- 李阿姨: ... (S1-S8 active, S8 finale 退休)
- ...

### 跨 season 一致性 check
- 跟 series-structure.md §2 N 主题: ✓
- 跟 npcs.md 各 NPC 长弧光: ✓
- 跟前一 season cliffhanger: ✓ (S(N-1) → S(N) 衔接)

### Open Questions
- ...
```

---

## 8. 工作量

- 读 reference: 1-2 小时
- 写 outline: 3-5 小时
- 自检: 30 min
- **总计**: ~5-7 小时 per season

---

## 9. ❌ 不能做的事

- 不要改 series-structure.md（那是上一层 spec）
- 不要写 ink 内容（你只写 outline，episode .ink 由后续 ink writer 写）
- 不要 fork 给 N season "新主题"（series macro 已锁）
- 不要 retroactively 修改前面 season 的 outlines（即使你发现 bug，写到 Open Questions 让 GM 处理）
- 不要写多个 season（W6 一次写 1 个 season，写完提交，GM verify 后再启 next）

---

## 10. Bonus（time permitting）

如果你写完 N 还有精力，可以**接着写 N+1 outline**。但 N 必须先 done + 通过 GM review。N+1 是 next priority 但不阻塞。

完事写到提交报告，等 GM review。
