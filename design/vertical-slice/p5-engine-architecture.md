# P5 Engine Architecture（架构决策 + 任务分解）

> Status: 第 1 版（设计稿，待 user verify）
> Author: Game Designer (Claude — original session)
> Last Updated: 2026-05-05
> 配套：5 张 P5 UI 概念图（`design/concepts/p5-ui/`）+ design slice 9 文件（`design/vertical-slice/`）+ Round 2 .ink 输出（episode-1/2/3/4.ink + daily-choices.ink）

本文件锁定 P5 引擎层的所有架构决策 + 把 P5 拆成 ~20 个 mechanical 任务（subagent worker 可以执行）。

---

## 0. 设计决策回顾（已 locked，不要 redebate）

- **引擎栈**：TypeScript + Vite + PixiJS v8 + Tauri 2 + Preact + **Ink 叙事 DSL** + **inkjs runtime**
- **Ink 选定理由**：业内最强分支叙事 DSL（80 Days / Heaven's Vault），knot/stitch/divert/var/condition 完美对应 series wide flag accumulation + 4 集×52 季 scale
- **Diegetic UI 是视觉身份**（art-bible §7.1 硬约束）：mug 5-frame / banking app push / 水果盘 / 工位 props 表达 game state，不用 overlay HUD
- **5 张 P5 UI concept 已验证**视觉方向（参见 `design/concepts/p5-ui/`），下面架构基于这些图

---

## 1. Scene Type Taxonomy（5 种 scene type）

每种 scene type 是一个独立的 PixiJS scene root + render pipeline + ink runtime context。

| # | Scene Type | 触发 | 视觉锚（参见 concept image） | 主要 prop |
|---|---|---|---|---|
| 1 | **`workstation`**（默认 95% 时间） | morning_briefing / event / daily choice 默认 | concept 01 | mug / sticky / monitor / phone / 绿萝 / calendar / 邻位 NPC |
| 2 | **`phone`**（fullscreen 手机） | 微信 push / 朋友圈 / 银行 app push / 妈妈视频 | concept 03 | 手机界面 + 床头灯 / 沙发 等被景 |
| 3 | **`monitor_modal`**（monitor zoom-in） | KPI Review / HR 邮件 / 系统通知 | concept 04 | monitor 全屏 + 工位 prop edges |
| 4 | **`endgame`**（warm palette swap） | E52 春节回家（happy ending）| concept 05 | 妈妈家厨房 / 全新 NPC（妈妈现实） |
| 5 | **`modal_overlay`**（pause / settings / archive） | 玩家按 ESC / 主菜单 | (existing P0-P4 menu sprite) | settings panel / archive list |

**Scene transition 规则**：
- `workstation → phone`：触发 phone push 时，workstation 渐暗 → phone 从屏底滑入
- `workstation → monitor_modal`：camera zoom-in 到 monitor sprite → 替换 monitor 内容
- `workstation → endgame`：crossfade（5 秒），不复用 workstation pipeline
- 任意 → `modal_overlay`：直接 overlay，不切 scene

---

## 2. Render Pipeline（PixiJS Layer Order）

```
[Background sprite layer]      — workstation / phone room / kitchen 等
        ↓
[Scene props layer]            — desk / cubicle wall / 窗户 等静态 props
        ↓
[Diegetic prop layer]          — mug / sticky / phone / monitor / 水果盘 等动态 state props
        ↓
[NPC sprite layer]             — Lisa / David / 王总监 等当前在场 NPC 立绘
        ↓
[Dialog bubble layer]          — speech bubble (NPC 头顶) / 内心独白 (italic 浮文字)
        ↓
[Choice prop layer]            — sticky notes 悬浮 / phone reply buttons / email button
        ↓
[Time-of-day filter overlay]   — 全屏 tint (morning warm / noon neutral / evening cool / late blue)
        ↓
[Modal overlay layer]          — pause / settings / archive 等（仅 modal scene 有）
```

每层是 PixiJS Container。Z-order 严格固定。

**资产加载策略**：
- 启动时 eager-load: workstation BG + 主角 sprite + 10 NPC sprite atlas + 主要 prop 状态 atlas
- Lazy load: phone scene assets / endgame scene assets（首次进入时 load）
- 总资产体量目标：< 30MB （per art-bible 极简风格）

---

## 3. Ink Runtime Contract（# tags 协议）

`.ink` 文件是 designer / clone 写的；TS runtime 监听 ink 输出的 # tag 并触发对应 effect。这是 **TS↔Ink 的核心 contract**。

| # tag | 含义 | 触发 effect | 例子 |
|---|---|---|---|
| `# scene: <id>` | 切换 scene type | scene transition | `# scene: workstation` / `# scene: phone` |
| `# time: <hh:mm>` | 当前游戏时间 | 更新 time-of-day filter + NPC presence | `# time: 9:14` |
| `# npc: <id>_<state>` | NPC 出场 / 状态切换 | 在 NPC sprite layer add/remove/animate | `# npc: lisa_at_desk_typing` / `# npc: david_present_relaxed` |
| `# prop: <id>_<state>` | Diegetic prop 状态机更新 | 替换 prop sprite | `# prop: mug_full` / `# prop: sticky_huo_dao_zhouwu` |
| `# diegetic_prop: <id>_<state>` | 同上，但显式 mark "this is UI"（可加视觉强调如发光） | 同上 + 可选强调 | `# diegetic_prop: phone_show_bank_warning` |
| `# music: <track>` | 音乐切换（P6+ 实装，P5 stub） | audio engine | `# music: monday_drone` |
| `# weather: <state>` | 天气改变 | BG sprite swap | `# weather: rainy` |

**Daily-choice 专用 metadata tags**（runtime filter 用，不影响 render）：

| # tag | 含义 |
|---|---|
| `# category: <type>` | commuting / lunch / work / small_joy / npc / big_decision / survival |
| `# season_unlock: <cond>` | any / S3+ / sick_triggered / promotion_candidate / 等 |
| `# time_filter: <slot>` | morning / lunch / afternoon / evening / anytime |
| `# weekday_only` / `# weekend_only` / `# both` | 工作日 / 周末过滤 |
| `# cooldown_episodes: <n>` | 触发后 N 集内不再抽 |
| `# frequency_per_series: <n>` | 整 series 触发上限 |
| `# npc_focus: <id>` | NPC 互动类必带（决定 stitch 是否当前 NPC 在场可触发） |

---

## 4. Inkjs Runtime Architecture

### 4.1 Build Pipeline

`.ink` → JSON 编译用 inklecate（Ink 官方编译器）+ Vite plugin：

```
build/
├── ink-build.ts                — Vite plugin
└── inklecate-binary/            — bundled compiler binary (跨平台)

design/vertical-slice/*.ink → game/public/ink/*.json (build artifacts)
```

Vite watch mode：`.ink` 文件改动 → 自动重编 JSON → HMR 重 load。

### 4.2 Runtime Wrapper

`game/src/ink/runtime.ts`：

```typescript
import { Story } from 'inkjs';

export class InkRuntime {
  private story: Story;
  private tagInterceptors: TagInterceptor[] = [];

  loadStory(jsonPath: string): Promise<void> { /* fetch + new Story(json) */ }
  continueAll(): string[] { /* output text + intercept # tags */ }
  getChoices(): Choice[] { /* current available choices */ }
  selectChoice(idx: number): void { /* + emit choice event */ }

  // VAR 双向 sync
  getVar(name: string): InkValue { /* this.story.variablesState[name] */ }
  setVar(name: string, value: InkValue): void { /* sync to ink */ }

  // Save / load
  serializeState(): string { /* this.story.state.toJson() */ }
  loadState(json: string): void { /* this.story.state.LoadJson(json) */ }
}
```

### 4.3 Tag Interceptor 模式

每帧 ink continue 后，TS 扫描输出的 # tag 流，dispatch 给注册的 interceptor：

```typescript
class SceneInterceptor implements TagInterceptor {
  handle(tag: ParsedTag): void {
    if (tag.key === 'scene') sceneRegistry.transitionTo(tag.value);
  }
}

class NpcInterceptor implements TagInterceptor {
  handle(tag: ParsedTag): void {
    if (tag.key === 'npc') npcLayer.applyState(tag.value);
  }
}

// ... 类似 PropInterceptor / TimeInterceptor / MusicInterceptor
```

---

## 5. Daily Choice Runtime（pool filter + scheduler 集成）

### 5.1 Pool Filter 算法

每个 daily choice stitch 都用 # tags 标 metadata。Runtime 在需要抽 daily choice 时，按当前 context 过滤：

```typescript
function filterDailyChoices(context: GameContext): Stitch[] {
  return allDailyChoiceStitches.filter(stitch => {
    if (!matchSeason(stitch.season_unlock, context.season)) return false;
    if (!matchTimeOfDay(stitch.time_filter, context.timeSlot)) return false;
    if (!matchDayType(stitch, context.isWeekend)) return false;
    if (cooldownActive(stitch, context.episode)) return false;
    if (frequencyExceeded(stitch, context.seriesHistory)) return false;
    if (stitch.npc_focus && !npcPresent(stitch.npc_focus, context)) return false;
    return true;
  });
}
```

### 5.2 选择策略

每集每天 8 时间槽：
1. 优先 schedule 剧情 events（per season-arc spec — episode-N.ink 内 hardcoded sequence）
2. 剩余 slots → daily choice（每个 slot 独立 filter + random pick）
3. 玩家可任意 slot 按"提前下班" → 跳过剩余 slots，effort -1

```typescript
class DayScheduler {
  async runDay(episode: Episode, day: Day): Promise<DayResult> {
    const slots = day.isWeekend ? 4 : 8;
    const scriptedEvents = episode.day(day).events; // from episode-N.ink

    for (let i = 0; i < slots; i++) {
      if (scriptedEvents.has(i)) {
        await runStitch(scriptedEvents.get(i));
      } else if (player.requestedEarlyClock) {
        effort.dec(1);
        break;
      } else {
        const candidates = filterDailyChoices({ slot: i, ... });
        if (candidates.length === 0) continue; // empty slot, time pass
        const chosen = pickRandom(candidates);
        await runStitch(chosen);
      }
    }

    return await runStitch(day.afterWork);
  }
}
```

---

## 6. Time Slot Scheduler

| 时段 | Slot | 触发场景 |
|---|---|---|
| 周一-周五 | 8 (上下班 1 槽 / 上午 3 槽 / 中午 1 槽 / 下午 3 槽) | workstation default |
| 周六-周日 | 4 (起床 1 / 早餐 1 / 中午 1 / 晚饭 1) | workstation alt 或 phone-driven (妈妈视频) |

**关键 events**：
- 周一 morning_briefing：always 第 1 slot
- 周三晨会：always 第 2 slot（如果 episode 含晨会）
- 周五 weekly_recap：always 最后 slot
- 周六 11:00 起床：always 第 1 slot
- 周日 8:30 妈妈视频：always 固定时段（per npcs.md §9）

---

## 7. Flag System

Single source of truth = **ink VAR**（全在 episode-1.ink 顶部 + daily-choices.ink 顶部声明）。TS 端只是 read-only mirror。

**Flag 类型**：
- 数值 (kpi / money / state / NPC scores)
- bool (lisa_helped_pps / weekend_with_lisa / has_moved / went_japan_trip)
- 计数 (sick_count / promotion_candidate_count / resume_sent_count / anxiety_stack)

**Cross-scope 累积**：
- Episode 内：ink runtime state（continueAll 之间持久）
- Episode → Episode：ink state.toJson() 序列化保存到 SaveSystem
- Series finale 触发条件：ink condition `{sick_count >= 7: -> game_over_too_sick}` 等

```typescript
class FlagMirror {
  // 启动时从 ink runtime sync 一次
  init(ink: InkRuntime): void {
    for (const name of FLAG_VAR_NAMES) {
      this.cache.set(name, ink.getVar(name));
    }
  }

  // 每次 ink continue 后 sync
  syncFromInk(ink: InkRuntime): void { /* ... */ }

  // TS 端 readonly
  get<T>(name: string): T { return this.cache.get(name) as T; }
}
```

---

## 8. Diegetic UI Prop System

### 8.1 Prop Entity 模型

每个 diegetic prop = (sprite_id, current_state, state_machine)：

```typescript
interface PropEntity {
  id: string;                          // 'mug' / 'sticky_huo_dao_zhouwu' / 'phone' / 'fruit_bowl'
  states: Record<string, SpriteFrame>; // { full: 'mug_full.png', empty: 'mug_empty.png', ... }
  currentState: string;
  position: { x: number, y: number };
  animation?: AnimationConfig;          // subtle bob / steam wisp / etc.
}
```

### 8.2 Prop State Machine（核心 props）

| Prop ID | States | 触发条件 |
|---|---|---|
| `mug` | full / 3quarter / half / quarter / empty / empty_with_smoke | state attribute 阈值 |
| `phone` | face_up / face_down / has_notification | phone 状态机 |
| `phone_screen_locked` | mt_fuji_wallpaper | 默认（笑天的 wallpaper） |
| `sticky_huo_dao_zhouwu` | fresh / curled_edge_1week | 时间 |
| `sticky_xia_ge_yue_zhouyi` | hidden / visible | E4 KPI Review 之后才出现 |
| `monitor` | idle / working / critical_red / shows_email | 时段 + 事件触发 |
| `coffee_machine` | broken_with_sign / working_briefly | running gag |
| `fruit_bowl` | apple / strawberry / empty | 融资周期 |
| `desk_stain` | lvl_0 / lvl_1 / ... / lvl_5 | 时间累积 |
| `green_plant` | healthy / drooped_1 / drooped_2 | 时间 |
| `bank_app_warning` | hidden / visible | money < 4500 |

### 8.3 Sprite Atlas Strategy

每个 prop 一个 atlas，包含全部 states。PixiJS sprite swap = `sprite.texture = atlas.textures[stateName]`。

新需要生成的 sprites（之前没有的）:
- phone face_down / face_up / notification badge
- phone_lock_screen mt_fuji_wallpaper（已有 character/turnaround/detail_thermos.png 风格 reference）
- bank_app_warning push notification
- fruit_bowl apple / strawberry / empty 3 frame
- sticky_xia_ge_yue_zhouyi（需要生成）

P5 美术外包预算：~$0.30-0.50（3-5 张 sprite at low quality + cut）

---

## 9. Speech Bubble + Choice Renderers

### 9.1 Speech Bubble Renderer

```typescript
function renderSpeechBubble(npc: NpcEntity, text: string): PIXI.Container {
  const bubble = new PIXI.Container();
  // 9-slice rounded rectangle background
  const bg = new PIXI.NineSliceSprite(...);
  // text auto-fit inside
  const txt = new PIXI.Text({ text, style: BUBBLE_TEXT_STYLE });
  // anchor pointer to NPC head position
  bubble.position.set(npc.position.x, npc.position.y - npc.height - 60);
  bubble.addChild(bg, txt, pointer);
  return bubble;
}
```

### 9.2 Internal Monologue Renderer

```typescript
function renderInternalMonologue(text: string): PIXI.Container {
  const overlay = new PIXI.Container();
  const txt = new PIXI.Text({
    text,
    style: { ...MONOLOGUE_STYLE, fontStyle: 'italic', alpha: 0.6 },
  });
  // position near protagonist's head, no bubble
  overlay.position.set(PROTAGONIST_HEAD_X, PROTAGONIST_HEAD_Y);
  overlay.addChild(txt);
  return overlay;
}
```

### 9.3 Choice Renderers（按 scene type 工厂）

```typescript
function renderChoices(choices: InkChoice[], context: SceneContext): PIXI.Container {
  switch (context.sceneType) {
    case 'workstation':
      return renderStickyNoteChoices(choices); // 悬浮在 desk surface
    case 'phone':
      return renderPhoneReplyButtons(choices); // 屏底 stack
    case 'monitor_modal':
      return renderEmailButtons(choices); // 单 button 或 row
    case 'endgame':
      return renderSpeechBubbleResponseChoices(choices); // 主角应答 bubble
  }
}
```

每种 choice prop 的视觉锚已在 concept image 验证（02 sticky / 03 phone / 04 email）。

---

## 10. Save / Load 兼容

P0-P4 已有 zod schema 保存：KPI / Money / Effort / Energy / current_run / archive。P5 加：

```typescript
const saveSchemaV5 = z.object({
  // P0-P4 keep
  kpi: z.number(),
  money: z.number(),
  state: z.number(),  // renamed from energy
  effort: z.object({ ... }),
  // P5 new
  ink_state_json: z.string(), // ink runtime serialization
  npc_scores: z.record(z.string(), z.number()),
  flags: z.object({ // optional convenience mirror, ink is source of truth
    sick_count: z.number(),
    promotion_candidate_count: z.number(),
    // ...
  }),
  current_episode: z.string(), // 'episode_1' / 'episode_2' / ...
  current_day: z.number(),
  current_slot: z.number(),
});
```

**Migration**：P4 saves load with empty ink state → re-init from `episode_1` knot. (P4 玩家被默认重开第 1 季，acceptable since P4 没 reach finale)

---

## 11. P0-P4 Code Triage

| 模块 | Action | 备注 |
|---|---|---|
| `game/src/card/` | **DELETE** | Defense card 抽象 obsolete |
| `game/src/card/data/defense.ts` | DELETE | 已被 daily-choices.ink 替代 |
| `game/src/render/cards/` | **DELETE** | Hand UI obsolete |
| `game/src/render/cards/hand.ts` | DELETE | 改成 choice prop renderer |
| `game/src/save/` | **KEEP + EXTEND** | 加 ink_state_json field |
| `game/src/economy/ap.ts` | **KEEP, RENAME** | "AP" → "time_slot"（保持公式不变）|
| `game/src/economy/kpi.ts` | KEEP | 反向 KPI 公式不变 |
| `game/src/economy/effort.ts` | KEEP | 提前下班 effort -1 已 working |
| `game/src/economy/energy.ts` | **KEEP, RENAME** | "energy" → "state"，5-frame mug 资产复用 |
| `game/src/economy/constants.ts` | KEEP | MONTH_DAYS = 28（per series-structure）|
| `game/src/flow/` | **KEEP, REFACTOR** | FSM 9 状态保留，action_day 子状态改 |
| `game/src/flow/states/action_day.ts` | REWRITE | 移除 hand 假设，集成 DayScheduler |
| `game/src/flow/states/main_menu.ts` | KEEP | menu 不变 |
| `game/src/flow/states/kpi_review.ts` | EXTEND | 调用 monitor_modal scene |
| `game/src/flow/states/gameover.ts` | KEEP | GO 路径已多样化 |
| `game/src/flow/states/archive_list.ts` | KEEP | 200 cap 保留 |
| `game/src/flow/states/save_corrupt.ts` | KEEP | dialog 保留 |
| `game/src/flow/states/morning_briefing.ts` | EXTEND | 调用 workstation scene + 触发首个剧情 stitch |
| `game/src/flow/states/after_work.ts` | KEEP | 加班 / 准时 / 提前 三选 1 保留 |
| `game/src/flow/states/recap.ts` | EXTEND | daily_recap stitch 渲染 |
| `game/src/flow/states/pause.ts` | KEEP | modal_overlay |
| `game/src/run-meta/` | KEEP | 解锁内容（codex / memo）保留 |
| `game/src/input/` | KEEP | 输入处理保留 |
| `game/src/render/menu/` | KEEP | 主菜单 sprite + Preact UI 保留 |

---

## 12. 新写代码模块

| 路径 | 用途 | 行数估计 |
|---|---|---|
| `game/src/ink/runtime.ts` | inkjs 包装 + tag stream | ~250 |
| `game/src/ink/tag-interceptors.ts` | scene/npc/prop/time interceptors | ~200 |
| `game/src/scene/registry.ts` | scene type 注册 + transition | ~150 |
| `game/src/scene/transitions.ts` | crossfade / camera zoom 等 | ~100 |
| `game/src/render/scene/workstation.ts` | workstation scene composer | ~300 |
| `game/src/render/scene/phone.ts` | phone fullscreen scene | ~200 |
| `game/src/render/scene/monitor.ts` | KPI Review email scene | ~150 |
| `game/src/render/scene/endgame.ts` | warm endgame scene | ~150 |
| `game/src/render/dialog/speech-bubble.ts` | NPC speech bubble | ~120 |
| `game/src/render/dialog/internal-monologue.ts` | italic faded overlay | ~80 |
| `game/src/render/choice/sticky-notes.ts` | 3-stack desk choice | ~150 |
| `game/src/render/choice/phone-buttons.ts` | phone reply buttons | ~120 |
| `game/src/render/choice/email-button.ts` | email button | ~60 |
| `game/src/render/diegetic/prop-entity.ts` | base prop entity | ~150 |
| `game/src/render/diegetic/prop-registry.ts` | 12 prop definitions | ~200 |
| `game/src/scheduler/day-scheduler.ts` | 8-slot day scheduler | ~200 |
| `game/src/scheduler/daily-choice-pool.ts` | filter algorithm | ~150 |
| `game/src/flag/mirror.ts` | flag readonly mirror | ~100 |
| `build/ink-build.ts` | Vite plugin .ink → .json | ~150 |
| `build/inklecate/` | bundled compiler binary | (binary) |

**新写总量估计**：~3000 行 TypeScript（不含 binary）

---

## 13. P5 Task 拆解（20 个 mechanical 任务）

每个 task 1-3 小时，足够 mechanical 让 subagent worker 独立完成。

| Task | 内容 | 依赖 |
|---|---|---|
| **P5-T01** | 添加 inkjs npm dep + bundle inklecate binary + 写 build/ink-build.ts Vite plugin | 无 |
| **P5-T02** | 写 game/src/ink/runtime.ts（loadStory + continueAll + getChoices + selectChoice + state 序列化） | T01 |
| **P5-T03** | 写 game/src/ink/tag-interceptors.ts（scene / npc / prop / time / weather 5 个 interceptor） | T02 |
| **P5-T04** | 写 game/src/scene/registry.ts + transitions.ts（5 scene type 注册 + crossfade / camera zoom） | 无 |
| **P5-T05** | 写 game/src/render/diegetic/prop-entity.ts + prop-registry.ts（12 个 prop 定义 + state 切换 + sprite swap） | 无 |
| **P5-T06** | 写 game/src/render/scene/workstation.ts（compose BG + props + NPC slots + time-of-day filter） | T04, T05 |
| **P5-T07** | 写 game/src/render/scene/phone.ts | T04, T05 |
| **P5-T08** | 写 game/src/render/scene/monitor.ts（KPI Review email scene） | T04 |
| **P5-T09** | 写 game/src/render/scene/endgame.ts（warm palette） | T04 |
| **P5-T10** | 写 game/src/render/dialog/speech-bubble.ts + internal-monologue.ts | 无 |
| **P5-T11** | 写 game/src/render/choice/sticky-notes.ts（3-stack desk choice + click handler） | T05 |
| **P5-T12** | 写 game/src/render/choice/phone-buttons.ts + email-button.ts | T07, T08 |
| **P5-T13** | 写 game/src/scheduler/day-scheduler.ts（8-slot 调度 + 提前下班）| T02 |
| **P5-T14** | 写 game/src/scheduler/daily-choice-pool.ts（filter algorithm） | T02, T13 |
| **P5-T15** | 写 game/src/flag/mirror.ts（ink VAR ↔ TS readonly cache） | T02 |
| **P5-T16** | 扩 game/src/save/ 加 ink_state_json + 12 个 NPC scores fields | T02 |
| **P5-T17** | 删 game/src/card/ + game/src/render/cards/，更新 imports | 无 |
| **P5-T18** | 重写 game/src/flow/states/action_day.ts（移除 hand，集成 DayScheduler） | T13, T14, T17 |
| **P5-T19** | 扩 game/src/flow/states/morning_briefing.ts / kpi_review.ts / recap.ts（接 ink runtime + scene transitions） | T02, T04, T18 |
| **P5-T20** | 端到端 demo：episode-1.ink 全跑通 + 30 个 daily choice 接入 + 1 周完整 playthrough | 全部 |

**总工作量预估**：~4-6 周（每个 task 1-3h × 20 = 20-60h，加上 debug + iteration 2-3x = 60-120h）

每个 task 可以独立 subagent worker 化（subagent-driven-development 模式）。

---

## 14. 美术资产 gap（P5 新需求）

5 张 concept 已 lock 视觉方向。P5 实施时需要的 sprite assets：

**已有可复用**（archive 里 + assets/sprites 现存）：
- 主角 sprite + 14 表情 / 姿势（assets/sprites/character/）
- workstation 背景（assets/sprites/backgrounds/workstation_closeup.png）
- 9 NPC 原型 face（assets/sprites/npc/） — 改名映射到 10 NPC
- mug 5-frame（assets/sprites/hud/coffee_*.png）
- monitor 4-state（assets/sprites/hud/monitor_*.png）
- desk stain 5-lvl（assets/sprites/hud/desk_stain_*.png）
- sticky lifecycle 4-state（assets/sprites/hud/sticky_*.png）
- 邻位 NPC face / position / lifecycle（assets/sprites/npc/{faces,positions,lifecycle}/）

**新需要生成**（P5 美术 gap，~$1-2 总成本）：
- phone face_up / face_down / notification badge（3 frame）
- bank_app_warning push notification screen（1 frame）
- fruit_bowl apple / strawberry / empty（3 frame）
- 妈妈 sprite（1 frame，endgame scene 用）
- 妈妈家厨房 background（1 frame）
- sticky_xia_ge_yue_zhouyi（1 frame，E4 后出现）
- 林姐 sprite（S3 finale 路径 A 触发后用）
- 食堂阿姨 sprite（食堂 daily choice 用）
- IT 小马 / Vivian / 老周 全身立绘（per npcs.md，旧 archetype 不能直接 cover）

可批量在一个 character_sheet 里生成（参考过去的 character_sheet_player_v01 模式）。

---

## 15. P5 Demo 验收标准（T20 完成时）

完成 episode-1.ink 端到端 demo 时验证：

**功能 checklist**：
- [ ] 启动游戏 → 主菜单 → 新游戏 → episode_1 knot 触发
- [ ] 周一 morning_briefing：笑天 voice + 名字段子 + 富士山头像出现
- [ ] Vivian "嗨～" 触发 + 苹果周水果盘 sprite 显示
- [ ] 茶水间偶遇 Lisa：speech bubble 从 Lisa 头顶冒 + 3 sticky note 浮现 + 选项点击 + Lisa score +1/0/-2 正确
- [ ] 王总监"小笑啊…陈天啊…加油啊"出现，无选项 + running gag flag set
- [ ] mug 5-frame 随 state 变化（喝水 / 加班 / 周末恢复）
- [ ] 8 时间槽完整跑过，提前下班按钮 work
- [ ] daily_recap 出现，李阿姨 N/A 不显示
- [ ] 第 7 天结束 → episode_2 入口 cliffhanger（Lisa 微信"周一晨会王总监会问 KPI 吧？"）
- [ ] Save / Load：第 4 天结束保存，重启后从第 5 天继续
- [ ] 30 个 daily choice 接入：随机抽到 ≥ 5 个不同 stitches，全部正常 render

**性能 checklist**：
- [ ] FPS 60+ 稳定
- [ ] 启动 → 第 1 个 ink stitch 渲染 < 2 秒
- [ ] 资产总体积 < 30MB
- [ ] Tauri build 桌面 binary < 50MB

**视觉 checklist**：
- [ ] 笑天 sprite gray polo + 不戴领带（不是 P0-P4 的 navy suit）
- [ ] mug 5-frame 视觉位置 = concept 01 reference
- [ ] sticky note "活到周五" 可见 + readable
- [ ] speech bubble 风格 = concept 02 reference
- [ ] phone 全屏 = concept 03 reference

---

## 16. P5 后续（P6+ 不在本 spec 范围）

P5 demo 通过后：

- **P6**：full season 1（episode 1-4 全跑通）+ 60 daily choices 全接入 + 美术资产补全（10 NPC + 工位 prop）
- **P7**：season 2 + season 3（Lisa finale）
- **P8-P12**：season 4-12 + endgame
- **P13**：series finale + happy ending 6 variants 全实装 + polish + ship

---

## 17. 设计师开始 P5 任务执行的方式

本 spec 通过 user verify 后：

**Option A**：我（designer Claude）顺序执行 P5-T01 → P5-T20 in this session。预计 4-6 周外加我自己 review。

**Option B**：每个 P5-T0X 单独 subagent worker dispatch + 我做 review。并行加速但每 task 都要 round-2-style 验收。

**Option C**：T01-T05（基础设施）我自己做，T06-T19 subagent 化，T20（端到端）我自己 demo + verify。混合最优。

我推荐 **Option C**——基础设施（ink runtime / scene registry）需要 careful 设计判断，subagent 在没 baseline 的情况下容易跑偏；但 scene-specific 实施（workstation / phone / monitor / endgame 各 1 个 task）是 mechanical 工作 subagent 完美适配。

---

## 18. ❌ 不在 P5 范围（避免 scope creep）

- 音乐 / 音效（P5 stub 只 emit # music tag，audio engine 留 P6）
- Tutorial / onboarding（P6+）
- Settings / accessibility 完整 UI（P5 keep P0-P4 stub）
- 多语言（中文 only，i18n hook 留位）
- 网络功能（无）
- 多人 / 联网 / 排行榜（永远不做，per design intent）
- 美术 polish（P6+）
- 移动端打包（P5 仅 macOS Tauri）

---

## 19. Open Questions（设计师需要 user verify）

1. **inklecate binary 怎么 bundle**？方案 A：每个平台 binary 提交到 build/inklecate/macos/ + build/inklecate/win/。方案 B：用 npm package `inkjs-tooling` (有可能不存在 / 不稳定)。**推荐 A**（控制力强）
2. **P5-T20 demo 的 episode-1.ink 是用 Round 2 worker 翻译的版本，还是先用 designer 顶部 Day 1+2 morning sample 部分**？**推荐先 Day 1+2 morning sample 部分跑通端到端**，然后 worker 输出 Round 2 翻译再扩展到 Day 7
3. **渲染分辨率是 640×360 还是 1024×576 还是 1280×720**？现有 P0-P4 用 640×360（per game/src/main.ts），但 5 张 concept 是 1024×1024 1:1。**推荐 1280×720 16:9**——保持 pixel art aesthetic（render at 320×180 internal scale）+ 现代显示器友好
4. **Phone scene transition 的"渐入"动画速度**：scene_transitions §4 没具体定。**推荐 300ms slide-up + workstation BG 背景 30% darken**
5. **Endgame scene 的 BG sprite generation**：是 P5 demo 时就需要，还是 P6 才需要？**推荐 P5 stub（用 placeholder color rect）**，端到端 demo 只验证 scene transition 触发，不要求 visual polish

---

## 20. 下一步

User verify 本 spec → 选 Option A/B/C → 开始 T01。

如果选 **Option C**，我下一步：
1. 写 P5-T01 + T02 + T03 + T04 + T05 自己实施（基础设施）
2. T06-T19 写 subagent dispatch brief（mechanical 工作）
3. T20 我自己 demo + verify

预计基础设施 1-2 周完成，subagent 部分 2-3 周完成（并行多个），demo + iterate 1 周。**总计 4-6 周到 P5 demo**。
