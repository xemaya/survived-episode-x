# P5 Phase 2 · Engine ↔ GM Open Questions

> Status: append-only. Engine clone parks open questions here when a
> design-side decision is needed; GM (or designer) replies inline.
> Questions don't block the engine — clone moves to the next
> non-dependent task while waiting.
>
> Convention: each question gets `### Q-N — <one-line>`, then a
> `**Engine context**`, `**Question**`, `**Engine recommendation**`,
> and `**GM reply**` (filled by GM).

---

### Q-1 — `# speaker: <id>` tag convention to remove engine-side speaker parsing

**Engine context**: T10a (speech bubble) currently has two engine-side
modules that reach into ink content:

- `speaker-parser.ts` regex-matches `**Name**：` / `Name：` line
  prefixes to detect who is speaking.
- `npc-anchors.ts` hard-codes 15 NPC names → screen positions.

This violates engine ↔ content separation: any change to dialog
prefix style ("Lisa：" → "L：" or "Lisa ：" or "Lisa▸") silently
breaks the parser; new NPCs require an engine code change before they
can speak.

**Question**: can episodes adopt a `# speaker: <id>` tag at the start
of every NPC dialog beat? E.g.

```ink
# speaker: lisa
**Lisa**："诶你看下这个行不行……"
# speaker: protagonist
你笑了笑。
```

The id (`lisa`, `david`, `wang_director`, `vivian`, `lao_zhou`,
`lisa`, `mama`, `lin_jie`, etc.) is content-stable; the engine maps
id → NPC sprite slot (T05/T06) and that sprite's anchor position.
Bubble routing becomes "if step has speaker tag and id ≠ protagonist,
mount bubble at sprite anchor". No content parsing.

**Engine recommendation**: ✅ adopt the tag. After T05/T06 lands,
delete `speaker-parser.ts` + `npc-anchors.ts`; speaker handling
becomes a one-line lookup in the NPC sprite registry.
Migration plan:
  1. Designer adds `# speaker: <id>` before every NPC line in
     episodes 1-4 (find/replace assist welcome — engine clone can do
     a sed pass given the speaker→id mapping).
  2. Engine adds a SpeakerInterceptor that reads the tag and
     stores `currentSpeaker` on a tiny SceneState mirror.
  3. ink-dialog.ts reads `currentSpeaker` instead of regex-parsing.
  4. After full episode 1-4 coverage, delete the parser + name
     registry.

**GM reply (2026-05-05)**: ✅ Adopt. Engine ↔ content separation 是
hard rule，content-to-engine 通过 tag 而不是 prefix-regex 是对的。

Authoritative speaker id ↔ NPC mapping table（也 W3 round-2 + 未来 ink
worker 的 reference）:

| id | NPC | source-of-truth doc |
|---|---|---|
| `protagonist` | 笑天（默认 fall-through，**bubble 不 mount，走 panel/monologue 渲染**）| `protagonist.md` |
| `lisa` | Lisa（同部门同事）| `npcs.md` §1 |
| `david` | David（卷王同事）| `npcs.md` §2 |
| `wang_director` | 王总监 / Eric（部门总监）| `npcs.md` §3 |
| `vivian` | Vivian（前台 / 接待）| `npcs.md` §4 |
| `lao_zhou` | 老周（隔壁工位老员工）| `npcs.md` §5 |
| `zoe` | Zoe（HR）| `npcs.md` §6 |
| `li_ayi` | 李阿姨（保洁）| `npcs.md` §7 |
| `mama` | 妈妈（视频电话端）| `npcs.md` §8 |
| `lin_jie` | 林姐（客户成功部 lead，S3 finale 路径 A 出场）| `npcs.md` §10 |
| `it_xiaoma` | IT 小马（咖啡机故障 running gag）| `npcs.md` §9 / 龙套 |
| `food_court_auntie` | 食堂阿姨（ambient）| `npcs.md` §11 ambient |

主角 `protagonist` 也走 tag — 让 engine 一统决策路径（"如果 tag = protagonist
→ 不 mount bubble，render 到 panel；如果在 italic-only 段落 + protagonist tag
→ render monologue"）。

迁移执行序：
1. **W1 (engine)**：next batch 实现 SpeakerInterceptor + currentSpeaker
   SceneState 镜像。**先存活 fallback 逻辑**——遇到无 `# speaker:` tag
   的旧内容，仍走 `speaker-parser.ts` 旧路径（保 episode 1-4 兼容直到全部
   sed-migrated）。
2. **W3 round-2 + 未来 S3 ink writer**：所有新写 .ink **必须**用 `# speaker:
   <id>` tag；现有 episode-1/2/3/4 由 W1 写一个 sed migration script
   (`tools/ink-speaker-migrate.py` 或 inline node script) 一次扫除——映射
   `**Lisa**：` → `# speaker: lisa\nLisa："…"`、`David："…"` → `# speaker:
   david\nDavid："…"` 等。脚本运行 + diff review + 提交后再删 parser。
3. **T05/T06 NPC sprite slots**（W1 batch 5 或后续）：`npc-anchors.ts`
   被 sprite registry 替代。`speaker-parser.ts` 同时删除。
4. **新 NPC 加入流程**：未来加 NPC 不再 touch engine 代码——加一行
   sprite registry entry + 在 `npcs.md` 加 id mapping，剩下 ink writer
   随便用。

**Status**: ✅ approved — W1 next batch 实现 + 写 sed script.

**Engine clone follow-up (2026-05-05)**: ✓ W1 landed in `feat(p5-T03-scene-mirror+speaker-tag)`:
- `# speaker:` listener added to `scene/scene-state-mirror.ts` (alongside `# scene` / `# npc` / `# time` / `# weather`).
- Parallel id → anchor table added to `npc-anchors.ts` (`getNpcAnchorById` etc.) for the 11 NPCs in the GM mapping.
- `ink-dialog.ts` paint chain prefers `sceneState.speaker` over `parseSpeaker(text)`; falls back to legacy parser when tag absent.
- Migration script `tools/ink-speaker-migrate.mjs` (idempotent, dry-run default; `--write` applies). Dry-run reports +208 tags across 9 ink files. Designer/GM owns when to run it.
- Fallback `speaker-parser.ts` + Chinese-name `getNpcAnchor` table stay live until migration applied; deletion is a follow-up.

---

### Q-2 — Bug #3 (daily_recap blob): fix in ink (option A) or engine (option B)?

**Engine context**: see `p5-qa-bug-reports.md` Bug #3. Multi-stitch
blobs into one `step()` paint because ink only stops at choice
points. End of `day_N_after_work` post-choice → `day_N_recap`
→ `day_(N+1)_morning_briefing` collapse into one panel render.

**Question**: which fix track does design want?
  - **(A)** Add a `* [明天见]` (or similar 2-3 char) gate choice at
    the end of every `day_N_daily_recap` stitch in episodes 1-4. No
    engine change. Ink content gains explicit pacing markers.
  - **(B)** Engine treats certain `# tag` (e.g. `# pagebreak` or
    `# scene: <change>`) as a hard `step()` break — drains output up
    to that tag and waits for a click before resuming. Designer
    annotates ink with the tag at every desired beat.

**Engine recommendation**: prefer **(B)** with `# pagebreak` as the
explicit signal — keeps content lean (no `[明天见]` filler choices
that aren't actually choices), and the same mechanism extends later
to "_long internal monologue beat → pause_" in T10b without designer
adding choice noise. (B) cost is ~30 lines in `runtime.ts step()` +
ink-dialog repaint trigger. Happy to implement either way.

**GM reply (2026-05-05)**: ✅ Option B — `# pagebreak` tag。

理由——A 违反 Pillar 1「不要假选择」：`* [明天见]` 不是选择，玩家点
"明天见" 跟点空白没区别，60+ choice 都搞这种 filler 等于教玩家忽略
sticky-note 选项 = 把核心交互 dilute 掉。B 用 tag 反而 cleaner，
engine 知道这是"等点击" 而不是"等选择"。

Tagging policy（写给 W3 round-2 + future ink writer）：

| 场景 | 加 `# pagebreak`? |
|---|---|
| `day_N_after_work` 选项后 → daily_recap 之间 | ✅ |
| `day_N_daily_recap` 末 → next morning_briefing 之间 | ✅ |
| 周五 daily_recap → weekly_recap → next 周一 morning 之间 | ✅ × 2（周间 + 周末各一次） |
| 长 internal monologue 块（≥ 4 段）后 → 下一 NPC 出场前 | ✅ |
| KPI Review screen 触发前 | ✅（如果 ink 内逻辑触发，否则保留 Preact 路径）|
| episode finale → cliffhanger card 前 | ✅ |
| 普通同事互动间（dialog → narration → dialog） | ❌（自然流，不打断）|
| Decision Moment 前 | ❌（紧接选项即可）|

W1 batch 5 实现：runtime.ts `step()` 见 `# pagebreak` 把当前累积 paint
flush + 等单次 click，再继续 Continue() 直到下一 choice 或 pagebreak。
Click 触发可以借用 panel 底部小三角图标"▼" 表示"还有更多"。

**Status**: ✅ approved — option B + tagging policy 上表。

---

### Q-3 — Bug #6 (choice text > 6 chars): how do sticky notes handle it?

**Engine context**: T11 sticky-note choices (next P0 task) need a
hard pixel cap on label width. tone-bible §5 calls for "≤ 6 char"
sticky-note feel, but `daily-choices.ink` and several `episode-*.ink`
choice labels run 10-15 chars (e.g. "申报加班 -10 状态 +2 AP 等价").

**Question**: do we
  - **(A)** truncate / ellipsis at render time (6-char visible +
    tooltip-style hover-expand)?
  - **(B)** wrap to 2 lines on the sticky note (loses tone-bible
    handwritten-note feel)?
  - **(C)** require designer to rewrite >6-char labels (round trip
    on every long choice — slow but tone-aligned)?
  - **(D)** ship sticky-notes with the existing labels for v1, defer
    the call to a "lint sweep" pass after end-to-end demo works?

**Engine recommendation**: **(D)** for v1 — implement T11 with
auto-fit wrap-to-2-lines, file a follow-up for designer to do a
length sweep before P6. This unblocks the visual-loop demo without
gating on a content rewrite of all 60 daily choices.

**GM reply (2026-05-05)**: ✅ Option D — ship 2-line wrap，sweep 后续。

理由——T11 sticky-note 已 ship + tone-bible §5 「≤6 char 是 default with
leeway」（不是 hard）。content lint sweep 是 P6 designer-driven pass
里的事，不是 engine gating。已建 backlog item："choice label length
sweep 60+ daily-choices + 4 episodes + S2 4 episodes" → defer to P6。

Engine batch-2 实测的 wrap-to-2-lines 还要确认：
- 2 行 max（per spec），溢出怎么处理？建议 ellipsis "…" 截断，hover/tap
  显示完整（但 hover 在 mobile 没有，tap 等于 select choice 起冲突——
  保 ellipsis 即可，contextually 玩家会从前 6 char 推断意思）
- 已有的 `[申报加班 -10 状态 +2 AP 等价]` 这种 mechanism-disclosure
  label，sweep 时改成 `[申报加班]` + 用 sticky-note 的 sub-line 或 hover
  tooltip 显示数值。Mech 数值放标签内 = anti-Pillar-3（"主语翻转：数值
  变化用 NPC / 物 / 时间陈述"），sweep 是 design-correctness 修复，不仅
  是字数。

**Status**: ✅ approved — T11 ship 2-line wrap + ellipsis；P6 backlog
建 "choice-label-tone-sweep" item by designer。

---
