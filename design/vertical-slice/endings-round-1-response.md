# W3 Endings Round 1 提交报告 — endings.ink (5 GO + 6 happy)

> Status: done
> Author: 分身 CC session (W3 reuse, 2026-05-07)
> Last Updated: 2026-05-07
> 配套 brief: `gameover-and-happy-ending-ink-handoff.md`

---

## 输出

- `design/vertical-slice/endings.ink` (813 行, 11 ending knots)

---

## 11 ending knot 完成度

| Ending | Knot 名 | 行数 | Verbatim anchor |
|---|---|---|---|
| GO 病倒 | `game_over_too_sick` | ~30 | (无 anchor — 自写 cold HR-speak) |
| GO 适应不良 | `game_over_appearing_unsuitable` | ~50 | ✓ 王总监 "我们这边觉得你可能不太适合" + Zoe "已为您协调岗位适配方案" |
| GO 末位淘汰 | `game_over_last_in_line` | ~55 | ✓ 王总监 "末位 10%" + Zoe "本周走完流程" |
| GO 组织调整 | `game_over_org_restructure` | ~50 | ✓ Zoe "公司架构调整, 您所在的岗位被合并" |
| GO 恭喜晋升 | `game_over_promoted` | ~60 | ✓ 王总监 "明年提你做主管" + 笑天 "恭喜晋升。我早就知道。" |
| Happy A 妈妈 | `happy_ending_mom` | ~50 | ✓ 妈妈"瘦了" + 笑天 "不多。但算我赢一次。" |
| Happy B 日本 | `happy_ending_japan_ticket` | ~35 | ✓ 笑天 "8 年了。我以为我会再去。我会去的。这次。" |
| Happy C Lisa | `happy_ending_lisa_blessing` | ~50 | ✓ Lisa 微信 verbatim + 笑天 "她还会'好'。" |
| Happy D 陈哥 | `happy_ending_called_chen_ge` | ~50 | ✓ 小张+笑天 "早" + 笑天 "陈哥...我成了 David" |
| Happy E 安静 | `happy_ending_office_quiet` | ~50 | ✓ 笑天 "风扇声。安静真好。我活过了。" |
| Happy F 同学 | `happy_ending_same_party` | ~55 | ✓ 老同学 "厉害" + 笑天 "我装病装得好" + voice |

11/11 ending 全完成. Verbatim anchor 字字保留 (per handoff §4).

---

## Tone bible self-check

- ✓ 5 原则 + 4 工艺细节 全 11 endings pass
- ✓ protagonist.md voice 一致 (笑天 observer + self-deprecate + 反高潮)
- ✓ anti-Pillar 1 极致: 没有"赢" 语气 / 没有"被裁" 字 / 没有"加油下次再来" 鼓励
- ✓ 软性 fail check: ending 体量 30-60 行 (handoff 范围内), 每 ending 各有 specific anchor
- ✓ Happy ending 语气是"被允许休假" 不"打败 boss"
- ✓ Game Over HR-speak / PUA 直接抄, 没有温暖

---

## 设计决策: NOT INCLUDE episode-1.ink

handoff §2 sketch 写了 `INCLUDE episode-1.ink`, 但**实际不能 INCLUDE** ——
episode-1.ink 已有 `=== game_over_too_sick ===` + `=== game_over_promoted ===` stub knots
(per Round 2 patch comment line 71-96). INCLUDE 会导致 duplicate knot definition →
Ink compile error.

**Solution**: endings.ink standalone (no INCLUDE). 所有 stitches 不依赖 episode-1.ink
VAR 声明 (本文件无 `~ var =` 赋值, 仅 narrative + tags + dialog)。

跟 W1 dev 协作 note:
- TS runtime 触发 GO 时, **switch to endings.json** 然后 ChoosePathString('game_over_X')
- episode-N.json 内的 stub `=== game_over_too_sick === -> END` 仍是 no-op fallback
- 双 .json 同名 knot 不冲突 (each compiles standalone)

---

## Build verify

```
✓ endings.ink → endings.json
Done: 14/14 succeeded → 0 fatal errors
```

新增 1 个 .json (endings.json) 加入 13 个已有 .json. Pre-existing 10 处 warnings 不动 (per W3 R2 GM defer).

---

## Open Questions

### Q1. 实习生小张 / 老同学 不在 npcs.md
Variant D 实习生小张 + Variant F 老同学 都不在 npcs.md 注册的 13 NPC mapping table。
我用 `# speaker: protagonist` 给笑天 lines, 实习生 / 老同学 dialog 用 inline text (不加 # speaker tag)。
Engine source-detector 应该 fallback 到 narrative panel — 不 mount NPC bubble。

**GM 决定**: 是否 OK, 还是要为 `intern` / `old_classmate` 加 speaker mapping? (W1 batch 5 mapping 表 stable, 加 2 个 fallback id 应该 trivial)

### Q2. happy_ending_office_quiet 的 callback 假设
此 variant 假设 S6 末 David 已燃尽 + S9 末王总监已被换 + S3 末 Lisa 已走 — 这是 series macro baseline (per series-structure.md §3 表). 但**只有玩家活到 E51 才能看到这个 ending**, 而活到 E51 意味着 cumulative 选择已经走完。OK ✓.

### Q3. 复合 ending 顺序
handoff §3 末说"复合逻辑由 TS runtime 处理(你不写 routing)"。我各 variant knot 都 `-> END`, runtime 需要在 happy A 结束后 ChoosePathString 到 next variant (B/C/D/E/F). 各 knot 之间无 cross-reference, 不会冲突。

---

## 工时

实际 ~2 小时 (读 reference / 写 11 knots / build verify / 报告).

---

## W3 stand down

R1+R2+S3 R1+R3+R4+ Endings R1 全完结.

W3 stand down. 等下次内容改 re-engage.

---

## END
