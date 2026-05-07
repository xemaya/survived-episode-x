# S4 Ink Writer · Handoff Brief (Episodes 13-16)

> Status: 第 1 版
> Author: GM
> Date: 2026-05-07
> 收件人：分身 CC session (fresh OR W3 reuse)
> Reuse: W3 已经写过 S2 (E5-8) + S3 (E9-12) + intro voice fix + AP sweep, 同 session 接 S4 流程已熟。

---

## 0. 你的处境

你是 **S4 Ink Content Writer**。任务：基于 `season-4-arc.md` outline 写 **episode-13.ink ~ episode-16.ink** (4 个新 .ink 文件)。

跟 S2 / S3 ink writer 同 pattern (production-quality, 预计 ~10-12h)。

---

## 1. 必读 reference (按顺序)

1. **`design/vertical-slice/season-4-arc.md`** — 主 spec (584 行 outline + 12 sections)
2. **`design/vertical-slice/season-4-arc-round-1-reply.md`** — GM verdict + 6 Open Q decisions
3. **`design/vertical-slice/episode-12.ink`** — S3 finale (E12) `.ink` syntax sample, 你接续 S4 (E13) 从这里开始
4. **`design/vertical-slice/episode-1.ink`** — VAR block + helper functions + intro stitches reference
5. **`design/vertical-slice/avg-architecture.md`** — engine 怎么消费 .ink (tag conventions: `# scene` / `# npc` / `# prop` / `# pagebreak` / `# speaker` / `# kpi_review_path_*`)
6. **`design/vertical-slice/tone-bible.md`** — voice 5 红线
7. **`design/vertical-slice/protagonist.md`** §9 — 笑天 S4-S6 弧光 voice 演变
8. **`design/vertical-slice/npcs.md`** v2 — 10 NPC + 食堂阿姨 ambient + `# speaker:` id mapping
9. (W3 reuse session 还应回顾 `episode-s2-round-1-reply.md` + `episode-s3-round-1-reply.md` 的 GM feedback patterns)

---

## 2. 任务

### 2.1 必修 — 写 4 个 .ink 文件

| 文件 | 主题 | 估行数 |
|---|---|---|
| `episode-13.ink` | Week 13「新工位主人」(Lisa 走后第一周, 5 路径分叉) | ~700-800 行 (E13 因 5 路径分叉略长) |
| `episode-14.ink` | Week 14「调休来加班」(清明节 seasonal beat) | ~600-700 行 |
| `episode-15.ink` | Week 15「他在打高尔夫」(David quiet sign 2 + 王总监 puppet form 3) | ~600-700 行 |
| `episode-16.ink` | Week 16「保温杯」(S4 finale, David 摔保温杯 + 路径 A promotion 预热) | ~750-850 行 |

总计 ~2700-3000 行 .ink。

### 2.2 必守的 spec (高优先级)

per `season-4-arc.md` outline:

1. **David 4 集 quiet sign 累积**: E13 baseline 抬高 / E14 朋友圈 0 + 茶水间不耐烦升级 / E15 晨会被王总监打断 / E16 迟到 + 不举手 + 摔保温杯。**节奏渐进, 不能 climax 提前**。
2. **王总监 puppet 形态 layer 4**: E15 周四晚打高尔夫 (S2 工位灯亮 / S3 打电话 / S4 打高尔夫递进)。必保留。
3. **Lisa 5 路径 ambient presence**: per §3.2 表 5 套不同质感
   - 路径 A: 每集 1 次微信, 4 句以内
   - 路径 B: 朋友圈 mention, 笑天截图保存
   - 路径 C: 屏蔽态 (笑天点开看到分组屏蔽)
   - 路径 D: 笑天看 Lisa 微信对话框最后一条 S3 周日"不管怎样谢谢你"
   - 路径 E: silence 0 接触 (per GM Q4 decision: keep silence)
4. **林姐 E15 茶水间偶遇仅路径 A + 0 句话** (per GM Q6 decision)
5. **老周 S4 对话 = 0** (per npcs.md §8)
6. **promotion_candidate_count 阈值 = 150** (per GM Q1 decision, NOT 130)
7. **路径 A E16 finale "高潜力人才储备池"** wording 必保留 (anti-Pillar 1 backdoor signal)
8. **清明 mention "上坟" 流程性词** + 4 个 strict constraint (per GM Q5 decision):
   - 妈妈 dialog "你姨他们要去你爸坟上" 合规 (不是 "你爸坟上")
   - 笑天 internal monologue 不写 "8 年前" / "爸爸已逝" 类 emotional anchor
   - 不加 hidden flag like `dad_grave_visit_decline`
   - 不形成 spiral motif
9. **`# kpi_review_path_a_s4` tag** 在 E16 D7 末加 (engine cinematic Q-Q 已 ready)
10. **`# speaker:` tag** 每个 NPC dialog beat (跟 W3 round-2 同 discipline)
11. **`# pagebreak` tag** 跨 event / 跨 day / 长 monologue 后 (per W3 R2 policy)
12. **5 红线 + 笑/泪曲线** (E13=6:4 / E14=5:5 / E15=5:5 / E16=4:6)

### 2.3 不要做的事

- ❌ David 在 E13/E14/E15 失态 (E16 才 finale)
- ❌ David 在 S4 燃尽离职 (S6 finale)
- ❌ 王总监对 David 当面 "你需要调整"
- ❌ 老周说出第二句话
- ❌ 林姐主动跟笑天聊
- ❌ E16 路径 A 加 happy ending UI / promotion 庆祝
- ❌ 引入 npcs.md 未注册新 NPC (张磊 / 赵丽 = ambient flavor 不正式注册, ≤ 3 句话整 S4)
- ❌ 妈妈对爸爸 expose emotional anchor
- ❌ S4 触发 event S10.X promotion warning (S10 才正式 active)

---

## 3. Workflow

1. 读完所有 §1 reference
2. 写 `episode-13.ink`, 跑 `cd game && pnpm ink:build` 验证 0 fatal error
3. 写 `episode-14.ink`, build 验证
4. 写 `episode-15.ink`, build 验证
5. 写 `episode-16.ink`, build 验证 (`Done: 17/17 succeeded` after S4 加进去——含 daily-choices + endings)
6. 跑 `pnpm tsc` + `pnpm test` 整个项目 (302/302 ish 应保持)
7. 写 `design/vertical-slice/episode-s4-round-1-response.md` (per W3 round-2 response 同格式):
   - 4 文件路径 + 行数
   - 每集 NPC archetype 完成度 (David 4 quiet sign + 王总监 puppet form 4 + Lisa 5 路径 + 林姐 E15 + 老周 0 对话 + 妈妈 spiral 起步 + 食堂阿姨 唯一 recognition)
   - §6 verbatim quote 自检 (路径 A "高潜力人才储备池" / E15 "好了 David 我明白了" / E16 食堂阿姨 "今天早" / 等关键 line)
   - §8 跨 season 一致性 check
   - Open Questions (如有)
8. stand down 等 GM round-1 verdict

---

## 4. 估时

- Read reference: 1-1.5h
- Write 4 episodes: 8-10h
- Build verify + tests: 30 min
- Submit report: 30 min
- **Total: ~10-12h**

---

## 5. 提交格式 (per W3 R2 round-1 response 格式)

跟 `episode-s2-round-1-response.md` 同格式 — 表格 + verbatim 抓取 + 自检 + Open Q。

---

## 6. 完成后

W3 (or fresh session) round-1 closed wait GM verdict. Round-2 typically 是 polish / minor fix (跟 S2 / S3 经验一致, ~3.5h W3 R2 batch).

---

## END
