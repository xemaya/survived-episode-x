# W5 Round 4 Handoff — Re-prompt workstation_closeup.png (remove mini HR monitor)

> Status: dispatch
> Author: GM
> Date: 2026-05-07
> 收件人: W5 (visual asset generator clone)
> 配套 round-3: 11 named NPCs ✓ closed

---

## TL;DR

GM playtest 2026-05-07: workstation_closeup.png BG 自带 mini "HR portal" 子监视器 (画在 desk surface 上, 跟主 monitor 撞), 视觉看起来像 2 个 monitor 重复. 重 prompt + re-sync.

---

## Task

Re-prompt `assets/sprites/backgrounds/workstation_closeup.png`:
- 同 round-1 workstation_closeup 视觉锚 (cream BG + cubicle navy + 工位密集格 + 16-bit 颗粒度)
- **删除** desk surface 上的 mini "人力资源门户" / "HR" 牌子小屏
- **保留** main monitor (centered top), HR portal 概念改为 ink prop 触发的弹窗 modal (P5 Phase 3 task)
- 其他 desk surface props 保留: 键盘 / 鼠标垫 / 椅子 / 隔断板 / 走道地板格 etc

## Prompt 调整

参考 round-1 workstation_closeup.png prompt, 加一句:
```
NO mini HR portal sub-monitor on desk surface.
NO secondary screen below or beside the main monitor.
Main monitor centered on the desk, with empty desk area below it (just the keyboard/mousepad).
```

## Workflow

1. 修改 `design/concepts/p5-ui/prompt_workstation_monday_morning.txt` 加 hint
2. Low-q generate → 验证无 mini HR 牌
3. High-q generate
4. 切图 / cp 到 `assets/sprites/backgrounds/workstation_closeup.png`
5. `cd game && pnpm assets:sync`
6. 写 `design/vertical-slice/visual-asset-round-4-response.md` (3-5 行就行)

## Estimate

- DeerAPI: $0.03 low + $0.10 high = $0.13
- Time: 15-20 min

## 完成后

W5 round-4 = closed. stand down.
