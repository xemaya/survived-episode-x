# P5 · QA Tester Handoff Brief

> Status: 第 1 版
> Author: Game Designer (原 CC session)
> Last Updated: 2026-05-05
> 收件人：**分身 CC session**——新启动的 Claude Code session，专做 P5 demo 的 QA

---

## 0. 你的身份

你是 P5 demo 的 **QA tester**。引擎 dev clone 在并行写代码升级 visual + 功能。你的活：
- 跑当前 demo
- 把每个 bug + 不顺畅之处用结构化格式 file 到 bug 报告
- 持续测——dev 修了之后再 verify

**你不写代码**。只测 + 报告。

---

## 1. 准备环境

```bash
cd game
pnpm install              # 一次性
pnpm dev                  # 启 Vite dev server
# 浏览器打开 http://localhost:1420
```

如果 server 已经在跑（dev 那边可能起了），直接打开 URL 即可。

---

## 2. 必读 reference

1. **`design/vertical-slice/p5-closure.md`** — Phase 1 closure，知道当前应该跑通什么
2. **`design/vertical-slice/p5-engine-architecture.md`** §15 P5 Demo 验收标准 — 一组功能 / 性能 / 视觉 checklist
3. **`design/concepts/p5-ui/`** — 5 张视觉锚 — 检验"实际界面跟设计差多远"的标尺
4. **`design/vertical-slice/tone-bible.md`** v2 — 5 原则 — 检验文案是否走偏（e.g. 主角说出"我一定会变好"是 tone fail）
5. **`design/vertical-slice/episode-1.ink`** — episode-1 主线，可对照检查"剧本里写的内容是不是真的渲染出来"

---

## 3. 测试范围（按优先级）

### P0 · 主流程必走通（boot → 第 1 集走完）

走 Episode 1 完整流程：

1. **Boot**: 加载 main_menu，无 console 错误
2. **新游戏**: 点击 → 进入 intro
3. **Intro 4 屏**:
   - 屏 1：自介（笑天 32 岁 / 笑傲天下 / 入职 12 周）+ `[然后呢]`
   - 屏 2：8 时间槽 + 3 属性（KPI / 钱 / 状态）+ 不可能三角 + `[听懂了]`
   - 屏 3：52 周 / happy ending vs game over + `[我懂了, 开始第 1 天]`
   - 文本完整可读 / 选项点击响应
4. **Episode 1 Day 1**：
   - morning_briefing：闹钟响 3 次 / 陈笑天 / 笑天下众生 / 9:14 到公司 / "周一上午 9:14, 地球继续转动" + `[开始今日]`
   - Event 1.1 Vivian 嗨～ + 苹果水果盘
   - Event 1.2 茶水间偶遇 Lisa（3 选 1：让 Lisa 先 / 你先 / 不说话）
   - Event 1.3 电梯偶遇 David（3 选 1）
   - Event 1.4 王总监"小笑啊…陈天啊…加油啊"
   - Event 1.5 老周工位经过（无选项）
   - Event 1.6 Lisa 在工位敲键盘（无选项 / Pillar 2）
   - after_work：选 申报加班 / 按时下班 / 提前下班
   - daily_recap
5. **Episode 1 Day 2-7**：每天 2-4 个 event + after_work + daily_recap，到 Day 7 cliffhanger Lisa 微信"周一晨会王总监会问 KPI 吧?"
6. **Save / Reload**：刷新浏览器看是否能续上（当前 Phase 1 = localStorage fallback，可能 reset）

### P1 · 视觉跟 concept 图对照

- `concept_01_workstation_monday_morning.png` vs 实际工位画面
  - 检查：BG / mug / 监视器 / sticky / calendar / 邻位 NPC 是否到位
- `concept_02_event_lisa_ppt.png` vs 实际对话画面
  - 检查：speech bubble 是否在 NPC 头顶 / sticky note 选项是否在桌面 / 还是 fallback 到普通文本面板（Phase 1 是 fallback）
- `concept_03_phone_wechat_wang.png` — Phase 1 没实装，**confirmed not yet**
- `concept_04_kpi_review_email.png` — Phase 1 没实装，**confirmed not yet**
- `concept_05_endgame_mom_kitchen.png` — Phase 1 没实装，**confirmed not yet**

### P2 · 文案 tone 检验

- 主角内心独白是否 violate tone-bible 原则 1 "主角是观察者不是英雄"？（如出现"成长 / 突破 / 完美 / 努力" 基调 = bug）
- NPC 对白是否 violate 原则 2 "NPC 是为自己活的"？（如 NPC 表达"我支持你"利他言论 = bug）
- 选项是否超 6 字？（per tone-bible v2.1，专用职场梗 phrase 例外）
- markdown `**` `_` `*` 是否字面显示出来（应该被 stripMarkdown 清理）

### P3 · 性能 / 边缘情况

- 浏览器 DevTools Performance：FPS 目标 60+
- 资产体积：Network tab 看初始加载 < 30MB
- 长时间挂机不动 → 内存是否泄漏
- 快速反复点选项 → 是否 race condition

---

## 4. Bug 报告格式

写到：**`design/vertical-slice/p5-qa-bug-reports.md`**

每个 bug 按这个 template：

```markdown
## Bug #N · <一行标题> · [severity]

- **Severity**: block / major / minor
- **Reproducer**:
  1. 启 pnpm dev
  2. 点 [新游戏]
  3. 点 [然后呢]
  4. ...
- **Expected**: 应该看到 X
- **Actual**: 实际看到 Y
- **Files involved** (如果你能识别): `game/src/render/dialog/ink-dialog.ts:127` 等
- **Screenshot**: (如果有，附路径或描述截图)
- **Severity 判断依据**:
  - `block` = 主流程被阻断（boot 失败 / 选项点不动 / 永远卡同一段）
  - `major` = 视觉显著错乱 / 文案 tone 失守 / save 失败 / 误差选项 effect
  - `minor` = 排版瑕疵 / 性能轻度抖动 / cosmetic
- **Status**: open / in-progress / resolved（dev 修完 你 verify 后改 resolved）
```

不要 1 个 bug 写 200 行。简洁 + 可重现 = 好 bug 报告。

---

## 5. Bug 报告示例（演示格式）

```markdown
## Bug #1 · 选项点击后剧情文本面板空白 · block

- **Severity**: block
- **Reproducer**:
  1. boot → 新游戏 → intro 4 屏正常
  2. 点 [开始第 1 天] → morning_briefing 文本正常
  3. 点 [开始今日] → Event 1.1 Vivian 文本正常
  4. 点 Event 1.2 任意选项 → 进 Event 1.3
  5. 但是底部对话框 panel 空白（只有 "..."），只看到选项按钮悬浮在中间
- **Expected**: panel 应显示 Event 1.3 的剧情文本（"11:42。你想去 16 楼上厕所..."）
- **Actual**: panel 空白，文本不显示，但 3 个选项按钮可见（让 Lisa 先 / 你先 / 不说话）
- **Files involved**: `game/src/render/dialog/ink-dialog.ts:124-128` (renderChoiceButton handler 调 selectChoice 后 refresh 又调 step 二次, 内容已 drained)
- **Severity 判断**: 主流程视觉信息丢失，玩家看不到剧情
- **Status**: open
```

---

## 6. 工作 cadence

- 每 30-60 分钟跑 1 轮完整测试
- 累 3-5 个 bug 写一批到报告
- dev clone 修完会标 fix(qa-bug-N) — 你 verify 后改报告里 status: resolved
- 如果发现 dev 修了又复发的 bug，加 Bug #N-regression: <new findings>

---

## 7. 不要做的事

- 不要 directly 改代码（dev 范围）
- 不要 directly 改 ink 内容（designer 范围）
- 不要把 design 不喜欢报成 bug——要区分"实现 bug"vs "设计选择"。如果不确定，标 `severity: discussion` 让 designer 看
- 不要漫无目的测——按上面 §3 优先级
- 不要把 console warning 全报成 bug（某些 ink loose-end warning 是已知 backlog）

---

## 8. 第 1 轮测试建议

1. 完整走 1 遍 intro → Day 1（约 5 分钟），写 1-3 个最 obvious 的 bug 到报告
2. 回 main menu 重新走 1 遍，看是否 reproducible
3. 再走 Day 2 → Day 7（约 15-20 分钟），continue 报告
4. 最后跟 5 张 concept 图对照一遍 visual gap，列 P1 视觉 bug

总时长第 1 轮 30-45 分钟。

---

## 9. 跟 dev 协作

dev clone 会写 progress 到 `design/vertical-slice/p5-phase2-engine-progress.md`。每次他完成 batch，你看一眼新 task 是什么，然后**立刻 verify** 那个 task：

- T10a speech bubble done → 你测 dialog 是不是 NPC 头顶 bubble
- T11 sticky note choices done → 你测选项是不是浮在桌面

verify 通过 = 在你的 bug 报告对应 bug 改 resolved。verify 失败 = 写新 regression bug。

---

## 10. 工具 tip

- 浏览器 DevTools Console: `Cmd-Opt-J` (Mac) — 看错误
- DevTools Network: 看 .json 加载有无 404
- DevTools Application: localStorage — 看 save 数据
- Vite HMR: 改 .ink / .ts 自动 reload，无需重启
