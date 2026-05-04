# 引擎切换设计 — Godot/GDScript → TypeScript + PixiJS + Tauri

**Date**: 2026-05-03
**Status**: Approved (brainstorming complete, ready for implementation plan)
**Target platform**: macOS desktop only
**Locale**: 中文 only（不做 i18n）

---

## 0. 背景与决策动机

仓库 `survived-episode-x` 是反向 KPI 办公室生存模拟（像素风、回合制、立体 UI）。原 Godot 4.6 / GDScript 实现 ~18.6k 行，由 autopilot 生成后从未在 Godot 里运行过。`headless --import` 出现大量 parse error（`SaveState` 类名碰撞、`@abstract` 函数体误用、`Input.reset_all_action_presses` API 不存在等），6 个 autoload 全部加载失败。

**用户决策动机**：
- **A**：放弃修这堆 paper-done 代码（成本不如重写）
- **C**：未来要靠 LLM 协作，需要训练数据厚 + API 稳定的栈；Godot 4.4+/4.5/4.6 在 LLM 训练截止之后

**抛弃边界**：保留 `architecture/`、`stories/`、`design/`（除 `research/`）作为设计源；抛弃 `src/`、`tests/`、Godot 专有数据 / 资源。

**栈选择**：TypeScript 5 strict + Vite 6 + PixiJS v8 + Tauri 2，pnpm + Biome + Vitest。理由 4 条：
1. TS 是 LLM 数据最厚的语言（直接满足 C）
2. 用户已用 Canvas/JS 出过 Fintastic 单文件游戏
3. 立体 UI（道具组合）是 web 思维强项
4. 回合制 + 无物理 → 不需要传统游戏引擎服务

---

## §1 仓库布局

### 保留

| 路径 | 用途 |
|---|---|
| `architecture/` | 5 红线 + ADR-0001..0017 + 控制清单（设计契约） |
| `stories/` | 21 epic / 255 .md（AC 与边缘情况素材库；**不当 backlog 跑**，按需 grep） |
| `design/gdd|registry|art|assets/`、`design/CLAUDE.md` | GDD + 命名常量 + 美术规范 |
| `assets/sprites/` | **65 张已切分的真·游戏 sprite**：character/(13)、turnaround/(8)、npc/(9)、cards/{defense,offense}/(18)、maps/、ui/、scenes/(3)、test_outputs/(11 源图 + AI 提示词) |
| `assets/sprites/STYLE_GUIDE.md` | 183 行美术规范 + GPT-IMAGE-2 prompt 模板 |
| `tools/cut_sprites.py`、`tools/cuts.yaml` | 131 行 Python（Pillow + YAML，single/grid/rows_unequal 三模式） |
| `README.md`、`HANDOFF.md`、`CLAUDE.md` | 项目语境（CLAUDE.md 重写以反映新栈） |

### 抛弃

`src/`（GDScript）、`tests/`（GDUnit4）、`addons/`、`assets/data/`（.tres）、`assets/shaders/`（.gdshader）、`assets/sprites/**/*.import|*.uid`（Godot 元数据）、`project.godot`、`design/research/`（用户认为公式/分析作用不大）。

### 新代码位置

仓库根下 `game/` 子目录：

```
survived-episode-x/
├── architecture/ stories/ design/ assets/sprites/ tools/   (KEEP)
├── README.md HANDOFF.md CLAUDE.md                          (KEEP)
└── game/                                                   (NEW)
    ├── src/                # TS 源
    ├── public/             # 运行时资产（sprites 同步进来）
    ├── src-tauri/          # Tauri 壳
    ├── tests/              # vitest
    ├── scripts/            # gen-constants / sync-sprites / lint scripts
    ├── package.json tsconfig.json vite.config.ts biome.json
    ├── lefthook.yml
    └── tauri.conf.json
```

`stories/` **不强求 1:1 映射**到新代码；按系统翻挖即可。

---

## §2 技术栈与依赖

| 角色 | 选用 | 备注 |
|---|---|---|
| 语言 | **TypeScript 5.x** | strict + noUncheckedIndexedAccess |
| 构建 | **Vite 6** | 热重载 / 极简配置 |
| 渲染 | **PixiJS v8** | NEAREST scale / 整数定位 |
| 桌面壳 | **Tauri 2.x** | macOS .app ~10MB |
| DOM 浮层框架 | **Preact (~3KB)** | React 兼容 API；只挂载到 `#ui-overlay` |
| 状态管理 | 手写小型 store / signals | ~50 行；不引 Redux/Zustand |
| 音频 | **Howler.js** | macOS WebKit 兼容性最稳 |
| 像素字体 | Cubic 11 / Fusion Pixel 12 等中文像素开源字体 | `@font-face` + `document.fonts.ready` |
| 测试 | **Vitest** | 共享 Vite 配置 |
| Lint/格式 | **Biome** | 一站式 |
| 红线 lint | 自写 TS 脚本（`scripts/lint-redline-N.mjs`） | 节点 + 正则，无外部依赖 |
| 包管理 | **pnpm** | workspaces 友好 |
| Pre-commit | **lefthook** | Go 单二进制，跨平台无 Node 依赖 |

**版本钉策略**：`~` 而非 `^`，`pnpm-lock.yaml` 提交。

**Tauri 后端**：默认不写 Rust；仅作 webview 壳 + 文件系统访问。

**显式不引**：React/Vue/Svelte / ECS（Miniplex/bitecs）/ Phaser / i18next / Project Fluent / tween.js（手写 ~30 行 RAF tween）/ JSDOM。

---

## §3 模块切分（顶层布局）

```
game/src/
├── main.ts                  # 入口；boot PixiJS + store
├── store/                   # 极小 pub-sub store（单一存档对象）
├── flow/                    # 场景/日流 FSM —— 唯一 scene_state 发射方
├── economy/
│   ├── ap.ts                # AP 上限 / 单调性约束
│   ├── kpi.ts               # 反向阈值公式（MVP 占位，Slice 2 实公式）
│   └── relationship.ts      # NPC 好感数值
├── event/
│   ├── engine.ts            # 脚本 DSL 解释器
│   ├── effects.ts           # discriminated union（替原 @abstract 错用）
│   └── data/                # 事件脚本 (.ts 模块每事件一文件)
├── card/
│   ├── card.ts              # ActionCard 模型 + 出牌解析
│   └── data/
├── save/                    # JSON 序列化 + Tauri fs API
├── input/                   # 12 个 act_* 保留；keyboard event listener + 配置映射
├── audio/                   # Howler 薄封装（Slice 2 才实装）
├── runmeta/                 # 跨 run 解锁（仅 5 类白名单：codex/memo/npc/event_branch/ending）
├── tutorial/                # 教程状态
├── accessibility/           # 色盲 / 高对比 PixiJS filter + settings 注入
├── render/                  # 所有"可见的东西"，扁平按视图分子目录
│   ├── pixi-app.ts          # PixiJS Application 初始化
│   ├── stage.ts             # 工位主场景合成 + assertOverlayAllowed 守卫 + mountSceneFor 分发
│   ├── lighting.ts          # ColorMatrixFilter 时段色温（用户选 §3 选项 b）
│   ├── tween.ts             # ~30 行 RAF tween 工具
│   ├── props/               # 立体 UI：sticky/mug/monitor/calendar/npc/empty-chair (Red Line 3)
│   ├── cards/               # 卡牌手牌渲染
│   ├── event/               # event_active 状态下的对话/选项 UI（被 mountSceneFor 挂载）
│   ├── recap/               # 每日 / 每周 recap
│   ├── review/              # KPI review + GameOver
│   ├── menu/                # 主菜单（允许 overlay，用 Preact 渲染到 #ui-overlay）
│   └── notification/        # 立体通知变体
├── generated/               # gen 期产物；gitignored
│   └── constants.ts         # 由 design/registry/entities.yaml 生成
└── (lint scripts in game/scripts/, not src/)
```

### 与原 20 系统的对应

| 原 | 新 | 备注 |
|---|---|---|
| #1 Save | `save/` | Tauri fs → `~/Library/Application Support/com.huanghaibin.survived-episode-x/saves/` |
| #2 Input | `input/` | 12 act_* 保留 |
| ~~#3 Localization~~ | 删 | 中文 only |
| #4 Audio | `audio/` | Howler |
| #5 Lighting | `render/lighting.ts` | PixiJS ColorMatrixFilter（用户选 b） |
| #6 SceneDayFlow ⭐ | `flow/` | 唯一 emitter |
| #7 AP / #8 NPC / #9 KPI | `economy/` | |
| #10 EventScript ⭐ | `event/` | 心脏；DSL 改 TS-friendly |
| #11 ActionCard | `card/` | |
| #12 RunMeta | `runmeta/` | 5 类白名单 |
| #13–#19 Presentation | `render/` 子目录 | 扁平化 |
| #20 Accessibility | `accessibility/` | |

### 红线契约保持

- **Red Line 3**：`render/props/` 常态；overlay 仅 `pause/kpi_review/gameover/settings/main_menu`
- **Red Line 4**：`flow/` 是唯一 scene_state 发射方
- **Red Line 2**：`runmeta/` 5 类白名单
- **Red Line 5**：13 个命名常量构建期生成 `generated/constants.ts`

---

## §4 数据格式

### 4.1 事件（每事件一个 .ts 模块）

路径：`game/src/event/data/[category]/[event_id].ts`

```ts
export default defineEvent({
  id: 'lisa_001_morning_coffee',
  schemaVersion: 1,
  sceneIds: ['workstation', 'pantry'],
  narrativeTier: 'standard',  // flash | standard | verbose | numeric_only
  trigger: { kind: 'time_window', dayPhase: 'morning' },
  conditions: [
    { kind: 'npc_relationship_at_least', npc: 'lisa', value: 20 },
    { kind: 'kpi_below', metric: 'coffee_breaks', value: 3 },
  ],
  variants: [...],
  choices: [
    { id: 'pour_for_her', label: '顺手帮她也倒一杯', apCost: 1,
      effects: [
        { kind: 'change_relationship', npc: 'lisa', delta: +2 },
        { kind: 'change_ap', delta: -1 },
      ],
    },
    ...
  ],
  cooldown: { kind: 'days', value: 3 },
  weight: 1.0,
  farewellEvent: false,
  oncePerRun: false,
  morningBlacklist: false,
  tags: ['lisa', 'morning', 'social'],
  priority: 0,
});
```

**关键设计**：
- `defineEvent` 是 identity helper（纯类型推断，无 runtime 校验）
- `effects` 用判别联合（`kind` 字段）替原 GDScript `@abstract EventEffect` 五子类
- `EventLoader` 用 `import.meta.glob('./data/**/*.ts', { eager: true })` 启动期加载（Vite 原生）
- 三层索引（scene_id × trigger × tag）启动后建一次

### 4.2 卡牌

路径：`game/src/card/data/[category]/[card_id].ts`，判别联合区分 action / hero / farewell。

```ts
export default defineCard({
  id: 'card_pretend_busy_002',
  type: 'action',
  apCost: 2,             // 严格 1/2/3，对应 40%/40%/20% 分布（红线 2 lint）
  category: 'defense',
  effects: [...],
});
```

### 4.3 NPC 性格

`game/src/npc/data/[npc_id].ts`，含话术池、好感曲线、touch points。

### 4.4 数值常量（Red Line 5）

```
design/registry/entities.yaml  →  pnpm gen:constants  →  game/src/generated/constants.ts (gitignored)
```

```ts
// 自动生成，例：
export const KPI_REVIEW_INTRO_DURATION_MS = 800;
export const FINAL_TRANSITION_DURATION_MS = 1500;
export const ARCHIVE_HARD_CAP_COUNT = 200;
```

vite watch 模式自动 re-gen。任何裸 magic number 由 `lint:redline-5` 拦截。

### 4.5 存档

- **格式**：单 JSON，外层 `schemaVersion`
- **位置**：`~/Library/Application Support/com.huanghaibin.survived-episode-x/saves/save_<slot>.json`
- **写策略**：序列化 → `save_N.json.tmp` → `fs.rename` 原子替换；写前自动备份 `save_N.bak.json`（保留 1 份）
- **槽位**：3 个手动槽 + 1 个自动存档
- **迁移**：版本链表 + 每步 migrator 函数；最终用 zod 校验
- **zod 仅用在存档反序列化**：用户文件可能损坏 / 旧版本 / 被改

### 4.6 资产

- **位置**：`game/public/sprites/`、`game/public/audio/`、`game/public/fonts/`
- **加载**：Vite 的 `?url` import → 运行时路径
- **像素图设置**：`texture.source.scaleMode = 'nearest'`

### 4.7 美术资产管线

```
DEERAPI (GPT-IMAGE-2)
    ↓ prompt 套 STYLE_GUIDE.md 模板
assets/sprites/test_outputs/<sheet>.png   (源图，1024×1024)
    ↓ python3 tools/cut_sprites.py        (按 cuts.yaml 切)
assets/sprites/{character,npc,cards,...}/<sprite>.png   (切片产物)
    ↓ pnpm assets:sync                     (新加：scripts/sync-sprites.mjs，~30 行)
game/public/sprites/<category>/<sprite>.png
    ↓ Vite import.meta.glob
PIXI.Texture
```

**npm scripts**（`game/package.json`）：

```json
{
  "scripts": {
    "assets:slice": "cd .. && python3 tools/cut_sprites.py",
    "assets:sync":  "node scripts/sync-sprites.mjs",
    "assets:all":   "pnpm assets:slice && pnpm assets:sync",
    "predev":       "pnpm assets:all",
    "prebuild":     "pnpm assets:all"
  }
}
```

**为什么不端口 cut_sprites.py 到 TS**：131 行 Python + Pillow + yaml 已稳跑；端口要引 sharp / 跨平台编译，得不偿失。用户偏好"轻量工具"。

**STYLE_GUIDE.md + DEERAPI_KEY 工作流不动**。音频管线先跳过（用户由另一个 agent 做，到时 hand off）。

### 4.8 文案

直接写中文字符串字面量，不抽 i18n key。

### 4.9 资产打包

Tauri 默认把 `game/public/` 打入 .app Resources 目录，运行时只读。完全封闭包，无 mod 支持（接受）。

---

## §5 渲染 + 立体 UI 策略

### 5.1 分辨率与缩放

**逻辑分辨率：640×360**（用户选）。整数倍放大：

| 窗口 | 缩放 |
|---|---|
| 640×360 | 1× |
| 1280×720 | 2× |
| 1920×1080 | 3× ← 默认全屏完美整数 |

`PIXI.Application` 创建在 640×360 backing store；CSS 放大 `<canvas>`。`scaleMode: 'nearest'`、`roundPixels: true`、`autoDensity: false`，所有精灵整数定位。

### 5.2 场景图（PixiJS Container 层级）

```
app.stage
├── world                  # 主场景；受 lighting + accessibility filter 影响
│   ├── background
│   ├── desk
│   │   ├── monitor        # 显示器 → AP 进度 / 当日任务
│   │   ├── mug            # 咖啡杯 → KPI 反向阈值进度
│   │   ├── stickyNotes    # 便利贴 → 目标 / 通知（Red Line 3 → 通知是道具变体）
│   │   └── calendar       # 日历 → 当前日 / 月
│   ├── chairLeft / chairRight (空椅 motif)
│   ├── npcLayer
│   └── playerSprite
├── cardLayer              # 仅 ACTION_DAY 出牌时 visible
└── overlayLayer           # 仅 pause/kpi_review/gameover/settings/main_menu（Red Line 3 例外）
```

**Red Line 3 落地**：`render/stage.ts` 暴露 `assertOverlayAllowed(currentSceneState)`；`overlayLayer.visible = true` 必须经过此函数。状态不在白名单则 throw。

### 5.3 DOM vs Pixi 分工

- **纯 Pixi**：所有立体 UI（道具 / NPC / 卡牌 / recap 动画 / 日历翻页）
- **DOM/CSS（Preact 渲染）**：5 个浮层视图——主菜单、暂停、设置、KPI Review、Game Over。提供更好的可访问性（键盘焦点 / 屏幕阅读器 / 表单控件 / 滚动）
- **DOM 浮层挂在 `<canvas>` 同级 `<div id="ui-overlay">`**，由 `flow.subscribe` 控制 `display: none/block`

### 5.4 滤镜链

`world.filters = [lightingFilter, ?colorblindFilter, ?highContrastFilter]`：

- **lighting**：ColorMatrixFilter；按 `flow` 当前 day phase 插值色温矩阵；切相用 tween（**不**闪）
- **colorblind**：deuteranopia/protanopia/tritanopia 的 LMS 转换矩阵
- **high-contrast**：饱和度 +50% / 亮度对比强化

后两个由 `accessibility/settings.ts` 注入；不开则不挂入链，0 性能开销。

### 5.5 动画

- **精灵动画**：`PIXI.AnimatedSprite` + 帧表（JSON）
- **Tween**：手写 ~30 行 RAF tween helper（不引 tween.js）
- **Recap 等过场**：状态机驱动的序列（按时间轴推进 step）

### 5.6 字体

中文像素字体（Cubic 11 / Fusion Pixel 12）打包进 `game/public/fonts/`，`@font-face` + `document.fonts.ready` 确保 Pixi `Text` 创建前字体已就绪。

---

## §6 游戏循环 + 状态机

### 6.1 状态枚举（判别联合）

```ts
export type SceneState =
  | { kind: 'main_menu' }
  | { kind: 'action_day';   day: number; phase: DayPhase }
  | { kind: 'event_active'; eventId: string; resumeTo: SceneState }
  | { kind: 'weekend';      kind2: 'normal' | 'overtime' }
  | { kind: 'recap';        range: 'day' | 'week' | 'month' }
  | { kind: 'kpi_review';   snapshot: KpiSnapshot }
  | { kind: 'pause';        resumeTo: SceneState }
  | { kind: 'settings';     resumeTo: SceneState }
  | { kind: 'gameover';     reason: 'fired' | 'kpi_inflated_collapse' };

export type DayPhase = 'morning' | 'midday' | 'afternoon' | 'evening';
```

### 6.2 单一调度器（Red Line 4 硬实现）

```ts
class FlowDispatcher {
  private current: SceneState = { kind: 'main_menu' };
  private listeners = new Set<(s: SceneState, prev: SceneState) => void>();
  private inDispatch = false;

  request(target: SceneState): void {
    if (this.inDispatch) {
      throw new Error('Re-entrant dispatch — Red Line 4: only flow owns transitions');
    }
    if (!isLegalTransition(this.current, target)) {
      throw new Error(`Illegal transition ${describe(this.current)} → ${describe(target)}`);
    }
    this.inDispatch = true;
    try {
      const prev = this.current;
      this.current = target;
      for (const l of this.listeners) l(target, prev);
    } finally {
      this.inDispatch = false;
    }
  }

  subscribe(fn: (s: SceneState, prev: SceneState) => void): () => void {
    this.listeners.add(fn);
    return () => { this.listeners.delete(fn); };
  }

  get state(): Readonly<SceneState> { return this.current; }
}

export const flow = new FlowDispatcher();
```

`FlowDispatcher` class **不导出**，只导出 `flow` 实例。Re-entrancy guard 抛错（不静默 queue），早暴露问题。

### 6.3 转移合法性

```ts
function isLegalTransition(from: SceneState, to: SceneState): boolean {
  if (to.kind === 'pause' || to.kind === 'settings') {
    return !['pause', 'settings', 'gameover'].includes(from.kind);
  }
  if (to.kind === 'gameover') {
    return ['action_day', 'event_active', 'kpi_review', 'recap'].includes(from.kind);
  }
  if (to.kind === 'event_active') return from.kind === 'action_day';
  return ALLOWED.has(`${from.kind}->${to.kind}`);
}
```

转移表硬编码可读，~30 行覆盖全部合法转移。

### 6.4 游戏循环（PixiJS Ticker = 唯一 RAF 主轴）

| 线 | 驱动 | 频率 | 职责 |
|---|---|---|---|
| **状态线** | 玩家输入 / 事件解析回调 | 异步、稀疏 | `flow.request()` / AP 扣减 / KPI 更新 / 事件解析 |
| **渲染线** | `app.ticker`（PixiJS RAF） | 60 FPS | sprite 动画 / tween / 镜头 / 滤镜 |

```ts
const app = new PIXI.Application();
await app.init({ width: 640, height: 360, antialias: false, roundPixels: true });
document.body.appendChild(app.canvas);
flow.subscribe((state) => mountSceneFor(state, app.stage));
mountSceneFor(flow.state, app.stage);
app.ticker.add((ticker) => { tweenManager.update(ticker.deltaMS); });
```

**关键不变量**：状态线**纯同步**，所有副作用立即可见；渲染线只读状态。

### 6.5 域事件 vs FSM 状态

`flow` 只管"我现在在什么场景态"。**领域内变化**（AP 扣 / KPI 涨 / 卡打出 / 事件触发）走各自小型 emitter，每个 emitter **仅由自己的模块** emit；其他模块只读 / 订阅 / 通过公开方法触发。Red Line 4 精神扩展到所有领域事件。

### 6.6 事件交互（中断 + 恢复）

1. `action_day` 中触发器命中 → `event/engine.ts` 选 `eventId`
2. `flow.request({ kind: 'event_active', eventId, resumeTo: flow.state })`
3. `render/event/` 挂载事件 UI（dialogue + choices）
4. 玩家选 choice → 应用 effects → `flow.request(resumeTo)` 回原态

`resumeTo` 是数据不是栈，存档=序列化整个 SceneState；加载=反序列化 + 调一次 `mountSceneFor`。

### 6.7 Re-entrancy guard 抛错而非 silent queue

会拒绝 listener 内"立即转下一个状态"。正确写法：`queueMicrotask(() => flow.request(...))`。早暴露胜过 Godot 那套自由 emit 失控。

---

## §7 红线落地 + 测试策略

### 7.1 五条红线全做 build-time gate

| 红线 | 执行点 | 实现 |
|---|---|---|
| **1 反主角口吻** | `pnpm lint:redline-1` | TS 脚本扫 `event/data/`、`card/data/`、`npc/data/` 全部 .ts，正则匹配禁词 corpus（原 `subject_inversion_lint.py` 8 个 domain）。`_IRONY` / `_BUREAUCRATIC` 后缀放行 |
| **2 单调性** | `pnpm lint:redline-2` | (a) `runmeta/data/*.ts` 每条 unlock 必须有 `class` ∈ `['codex','memo','npc','event_branch','ending']`；(b) `apEconomy.maxApCap === 8` const assertion；runtime 用 `Object.freeze` + 数值方向校验 |
| **3 立体 UI 锁** | `pnpm lint:redline-3` + runtime guard | 静态：grep `overlayLayer.visible\s*=\s*true` 必须只在 `render/stage.ts`；Runtime：`assertOverlayAllowed()` |
| **4 单一调度** | runtime + 静态 | `FlowDispatcher` 不导出 + re-entrancy guard；grep `new FlowDispatcher` 必须只在 `flow/dispatcher.ts` |
| **5 数据驱动** | `pnpm gen:constants` + `pnpm lint:redline-5` | gen 期 YAML → constants.ts；lint 期扫所有非 `data/` 非 `generated/` 的 .ts，匹配 registry 数值的裸字面量报错 + 提示常量名 |

### 7.2 集中入口

```jsonc
// game/package.json scripts
{
  "gen:constants":  "node scripts/gen-constants.mjs",
  "lint:redline-1": "node scripts/lint-redline-1.mjs",
  "lint:redline-2": "node scripts/lint-redline-2.mjs",
  "lint:redline-3": "node scripts/lint-redline-3.mjs",
  "lint:redline-4": "node scripts/lint-redline-4.mjs",
  "lint:redline-5": "node scripts/lint-redline-5.mjs",
  "lint:redlines":  "pnpm lint:redline-1 && pnpm lint:redline-2 && pnpm lint:redline-3 && pnpm lint:redline-4 && pnpm lint:redline-5",
  "lint":           "biome check . && tsc --noEmit && pnpm lint:redlines",
  "test":           "vitest run",
  "verify":         "pnpm gen:constants && pnpm lint && pnpm test"
}
```

每个 lint 脚本 ~50-80 行 TS（`node:fs` + 正则，无外部依赖）。

### 7.3 测试金字塔

| 类型 | 工具 | 范围 | BLOCKING |
|---|---|---|---|
| **Logic（单元）** | Vitest | KPI 公式 / AP 算术 / save 序列化+迁移 / event effect / card 解析 / lint 脚本本身 | ✅ |
| **Integration（系统间）** | Vitest（无 UI） | 全日 headless：boot → action_day → play card → recap → kpi_review → action_day(next)；事件触发→选择→效果生效→state 回归；存档/读档 round-trip | ✅ |
| **Visual / UX** | 手工 smoke | dev server + click through 最小可玩切片 | ⚠️ ADVISORY |
| **E2E** | 不做 | Playwright 等等需要时再加 | ❌ |

`environment: 'node'`，`pool: 'threads'`，coverage v8 provider。Render 层不写单元测试（snapshot 地狱），靠手工 smoke。

### 7.4 Pre-commit + CI

**Pre-commit (lefthook)**：

```yaml
pre-commit:
  parallel: true
  commands:
    typecheck: { run: "pnpm tsc --noEmit", glob: "*.{ts,tsx}" }
    biome:     { run: "pnpm biome check --staged", stage_fixed: true }
    redlines:  { run: "pnpm lint:redlines" }
    vitest:    { run: "pnpm vitest run --changed" }
```

**CI (GitHub Actions, macos-latest)**：

```yaml
on: [push, pull_request]
jobs:
  verify:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: pnpm }
      - run: pnpm install --frozen-lockfile
      - run: pnpm verify
      - run: pnpm build
```

macos-latest 比 ubuntu 贵 10× 但 solo + macOS-only 项目可接受。

### 7.5 显式不做

不做 snapshot 测试 / 覆盖率门槛 / 性能 benchmark / 端口原 226 个 GdUnit4 测试。从零写新的，预计 30-50 个核心测试。

---

## §8 分发管线

### 8.1 Tauri 2 配置

```jsonc
// game/src-tauri/tauri.conf.json
{
  "productName": "活过第 X 集",
  "version": "0.1.0",
  "identifier": "com.huanghaibin.survived-episode-x",
  "app": {
    "windows": [{
      "title": "活过第 X 集",
      "width": 1920, "height": 1080,
      "minWidth": 640, "minHeight": 360,
      "resizable": true, "fullscreen": false, "center": true
    }],
    "security": {
      "csp": "default-src 'self'; img-src 'self' data:; font-src 'self'; style-src 'self' 'unsafe-inline'"
    }
  },
  "bundle": {
    "active": true,
    "targets": ["dmg", "app"],
    "icon": ["icons/icon.icns"],
    "category": "Game",
    "shortDescription": "反向 KPI 办公室生存模拟",
    "longDescription": "（待 ship 前从 design/gdd/game-concept.md 摘要写入）",
    "macOS": {
      "minimumSystemVersion": "12.0",
      "signingIdentity": null,
      "hardenedRuntime": true
    }
  }
}
```

### 8.2 打包

```
pnpm build           # Vite → game/dist/
pnpm tauri build     # → .app + .dmg；自动 sign + notarize（如配证书）
```

### 8.3 签名 / 公证 — 先跳过

**当前路线（无 Apple Developer 账号）**：跳过签名，用户首次打开右键"打开"。等接近 ship 看试玩规模再决定 $99/年。

### 8.4 图标

`scripts/gen-icons.sh` 调系统 `iconutil` 把 1024×1024 PNG → 多分辨率 .icns。

### 8.5 版本

Semver：0.1.0 起步，0.2.0 第一公开 demo，1.0.0 正式。`game/package.json` 的 `version` 单一事实源；`pnpm gen:version` 同步到 `tauri.conf.json` 和 `Cargo.toml`。

### 8.6 发布渠道

首发目标 **itch.io**（免证书 + 中文友好）。GH Actions tag 触发 release workflow attach .dmg。Steam 等 1.0.0 前后再决定。

### 8.7 显式不做

不做自动更新 / 沙盒 / Crash reporter / Mac App Store / universal binary 专门处理（按 host 架构 build；CI 跑两份 target）。

---

## §9 最小可玩切片（Slice 1 / MVP）

### 9.1 边界

照搬 HANDOFF Step 3 的最小循环。**目标：~10 工作日内出第一个能玩的 .app**。

**MVP 包含**：

| 模块 | 实现深度 |
|---|---|
| `flow/` | 4 状态：main_menu / action_day / kpi_review / gameover |
| `economy/ap.ts` | 8 上限 / spend / 重置 |
| `economy/kpi.ts` | 3 指标 + **占位阈值**（不实现真公式） |
| `card/` | 4 张占位卡（用 cards/defense/ 前 4 张） |
| `save/` | JSON 写盘 + 1 槽 + auto-save |
| `input/` | 鼠标点击 + Esc |
| `render/` | pixi-app / stage / props/{mug,monitor,sticky,calendar} / cards/hand / review/kpi-table / menu/main / menu/gameover |

**MVP 不包含**：event 系统、NPC、runmeta、tutorial、accessibility、audio、真 KPI 公式、月会/周末、recap、立体 UI 完整化、lighting、5 红线 lint 全套（仅 gen:constants）。

### 9.2 6 阶段

| 阶段 | 工作日 | 出口（可见结果） |
|---|---|---|
| **P0 Hello Pixi in Tauri** | ✅ 完成 2026-05-04（tag `v0.1.0-p0`） | `game/` 骨架 + 13 个 commits；`pnpm tauri build` 产出 `.app` + 27MB `.dmg`，安装后 1280×720 窗口居中显示主角精灵。完整执行记录见 `docs/superpowers/plans/2026-05-03-slice1-p0-hello-pixi-tauri.md`。 |
| **P1 FSM + 主菜单 + 进 day 1** | ✅ 完成 2026-05-04（tag `v0.2.0-p1`） | flow/ FSM (Red Line 4 runtime-enforced) + Preact main menu + workstation 4 props + Esc pause overlay。Plan: `docs/superpowers/plans/2026-05-04-slice1-p1-fsm-main-menu.md`。 |
| **P2 AP / KPI / 卡牌循环** | ✅ 完成 2026-05-04（tag `v0.3.0-p2`，scope C: hybrid） | AP=8 + 8 槽贴纸行 + KPI Formula B（potential 项实装）+ 4 张卡（4 状态机 + 7 步前 3 步）+ monitor KPI 绑定 + AP=0 一日结束。+ "modern indie pixel art" 渲染管线（linear scale + devicePixelRatio）。Plan: `docs/superpowers/plans/2026-05-04-slice1-p2-ap-kpi-cards.md`。 |
| **P3 结束今日 → KPI Review → GameOver/下一天** | 2d | "结束今日"或 AP=0 自动 → KPI Review → 任一超阈值 GameOver；否则 day += 1 |
| **P4 Save / Load** | 1d | "继续"加载 day/AP/KPI/手牌；切场景前自动写盘 |
| **P5 打包 + 发给朋友** | 1d | 生 .icns；产 .dmg；记录朋友 5 分钟内的反馈 |

### 9.3 P0 详细清单（Day 1 必须完成的工程链路 spike）

```bash
# 0. 删旧 Godot 痕迹（按 §1）
# 1. 初始化 game/
mkdir game && cd game
pnpm init
pnpm add -D typescript vite @biomejs/biome vitest
pnpm add pixi.js@^8 howler preact
pnpm add -D @tauri-apps/cli
pnpm tauri init
# 2. 配 vite.config.ts、tsconfig.json strict、biome.json、lefthook.yml
# 3. game/src/main.ts：boot Pixi 挂一张 sprite
# 4. scripts/sync-sprites.mjs（§4.7）
# 5. pnpm tauri dev → 窗口 + 精灵
# 6. pnpm tauri build → 双击 dmg → 拖 .app → 打开
```

**P0 退出标准**：`.dmg` 双击安装能跑、显示一个像素精灵。

**P0 工程链路里 gen:constants 是否要接入**：可延后到 P2（第一次需要从 registry 取数时）。P0 阶段没有任何 magic number 需求，不必早 wire。P2 接入时同步加 `lint:redline-5`；其它 4 条红线 lint 留到 Slice 2。

### 9.4 Slice 2 轮廓（不展开）

EventScript 心脏 / 9 NPC + relationship / 真 KPI 公式 / 立体 UI 完整化 / 5 红线 lint 全套 / a11y 全套 / lighting 时段 / audio 接入。时间预估 Slice 1 跑完再估。

---

## 决策记录摘要

| 决策 | 选择 | 备注 |
|---|---|---|
| 引擎 | TS + Vite + PixiJS + Tauri | 用户选方案 1 |
| 仓库形态 | 在原仓库下 `game/` 子目录 | 与设计文档共存 |
| stories 映射 | 不强求 1:1 | 当素材库 grep 用 |
| i18n | 不做，中文 only | 梗翻译失味 |
| 不引 React | 是 | 用户已确认 |
| Lint/格式 | Biome | 用户授意 |
| 框架（DOM 浮层） | Preact ~3KB | LLM 数据厚 + React API |
| 逻辑分辨率 | 640×360 | 3× = 1920×1080 完美整数全屏 |
| 5 红线执行 | 全做 build-time lint | 用户选 c |
| 音频管线 | 暂跳过；另一 agent 做后 hand off | |
| Apple Developer | 暂不付；接近 ship 再决定 | |
| 首发渠道 | itch.io | |

---

## 附：本仓库后续应该做的小修

CLAUDE.md 中"项目状态"段落需重写以反映：
- `project.godot` **不是**问题（实际存在但要删）
- 代码库已切换到 `game/` 下的 TS 工程
- 原 `src/`、`tests/`、`addons/` 等已抛弃
- 5 红线契约仍适用，但落到 TS lint 脚本而非 GDScript

此项作为 implementation plan 的第一步处理。
