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

**Status**: ⏳ awaiting GM ack.

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

**Status**: ⏳ awaiting GM ack.

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

**Status**: ⏳ awaiting GM ack.

---
