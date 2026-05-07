# Design Directory

> Updated 2026-05-06 — design pivot (2026-05-05) cleanup. 老的 GDD / asset specs 已移到 `archive/design-pre-pivot/`. 本目录 only contains **active source of truth**.

## 当前 active 目录

```
design/
├── CLAUDE.md                           ← 本文件
├── vertical-slice/                     ← 设计 + worker briefs + ink content + AVG architecture
├── concepts/                           ← W5 reference images + prompts
├── registry/
│   └── entities.yaml                   ← 数值常量 (KPI 阈值 / 病倒 cap / hero count / etc)
└── art/
    ├── art-bible.md                    ← 视觉层 authoritative (§7.1/§7.4/§7.5/§8 已 deprecated, see amendments)
    └── art-bible-avg-amendments.md     ← AVG 时代 deprecation 标记
```

## Source of truth 优先级

1. **`vertical-slice/avg-architecture.md`** — AVG 时代 dialog UI + daily pressure spec (post-pivot canonical)
2. **`vertical-slice/protagonist.md` / `tone-bible.md` / `npcs.md` / `series-structure.md`** — 设计骨架
3. **`vertical-slice/season-1-arc.md` / `season-2-arc.md` / `season-3-arc.md`** — 内容 outline
4. **`vertical-slice/episode-N.ink`** + **`daily-choices.ink`** — 内容实装 (W3 写)
5. **`art/art-bible.md`** — 视觉层 (色板 / 字体 / 剪影 / 道具 / 喜丧美学); UI/UX 部分见 amendments
6. **`registry/entities.yaml`** — 数值常量
7. **`concepts/`** — visual reference (W5 prompts + p5_ui sample images)

## Worker briefs + iteration logs

`vertical-slice/` 含全部 worker briefs (`*-handoff.md` / `*-task-queue.md`) + iteration responses (`*-round-N-response.md` / `*-round-N-reply.md`) + bug-tracking (`p5-qa-bug-reports.md`)。详 `vertical-slice/gm-worker-roster.md`。

## Archived (不 active)

`archive/design-pre-pivot/` 包含 27 个 Godot+卡牌时代 GDDs + Godot 时代 asset specs。**默认不读取**，详 `archive/design-pre-pivot/README.md`。

## 写作风格

`vertical-slice/` 内 doc 简洁直接, 少 ceremony:
- 不要重写 5 段 overview / 8 段 spec 那种 GDD format
- 直接写 What + Why + How
- 决策后直接 inline, 不要 ADR 文件
- worker 可读 + 实操即可

详见 `CLAUDE.md` 根项目 file 的 "工作风格" 节。

## 不要做的事

- ✗ 不要在 `design/` 根创建新目录（`gdd/` / `assets/` / `quick-specs/` / `ux/` 等）—— 都进 `vertical-slice/`
- ✗ 不要 reference `archive/design-pre-pivot/` 的内容作为 spec 依据（仅历史 trail 用）
- ✗ 不要写新 GDD format 文档（8 段 overview / spec / formulas / etc）—— 写 inline 简洁 doc 在 `vertical-slice/`
