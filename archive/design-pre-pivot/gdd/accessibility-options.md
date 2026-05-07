# Accessibility Options

> **Status**: Designed (pending review — awaits `/design-review design/gdd/accessibility-options.md --depth lean` in fresh session)
> **Author**: user + main agent + game-designer (Section A–H 主笔) + accessibility-specialist (C Rules 1–6 + E edges) + ux-designer (G Tuning Knobs + Visual/Audio) + systems-designer (C Rules 7–10 + F Dependencies + E edges) + qa-lead (H 14 AC)
> **Last Updated**: 2026-04-28
> **Layer**: Polish | **Order**: #20 | **Scope Tier**: Alpha (full) / VS (字体 + 色盲 only) / MVP (不启用)
> **Implements Pillar**: P5 主 (地铁可玩性 — Accessibility 扩大"可玩"的人群基线) + P4 守 (黑色幽默 tone — 禁鼓励性文案 / 禁 tone 改变) + P1 Anti-guard (Anti-P1 红线守门 — 禁 Accessibility 修改 AP/KPI/Energy 数学)
> **Review Mode**: Lean (CD-GDD-ALIGN skipped per `production/review-mode.txt`)

---

## Section A — Overview

**Accessibility Options** 是《活过第 X 集》的**跨呈现层无障碍注入系统**，以 Alpha tier 为实现目标。它不拥有自身的游戏逻辑，也不拥有任何独立场景 —— 它是一组**设置读取层**，在 7+ 呈现系统（#13 HUD Diegetic / #14 Card Play & Dialogue UI / #15 Daily & Weekly Recap UI / #16 KPI Review & Game Over UI / #17 Main Menu / Pause / Settings UI / #3 Localization Hooks / #5 Lighting & Visual State Controller）内注入渲染变体与交互宽容策略，而不改变任何底层数值规则。

### 双重身份

**技术层**: Accessibility Options 是**设置驱动的呈现层注入器** —— 玩家在 #17 Settings UI 的 Accessibility 子屏调整偏好；设置写入 `meta.save`（Save Rule 14 路径，`meta_settings_debounce_ms = 500 ms` 防抖）；各上游系统在自身渲染循环内读取 `AccessibilitySettings` 单例，并按偏好切换字体档位 / 色盲 palette / 对比度 shader / 输入宽容参数。**本系统的唯一职责是：定义这些设置 schema、提供单例读取接口、并在 #17 Settings UI 内注入 Accessibility 子屏**。

**叙事层（包容性扩展，P5 地铁可玩性）**: "地铁可玩性"不只是"5 秒进入" —— 它还意味着**色觉异常的玩家也能读懂 NPC 关系信号；视觉疲劳的玩家也能跑完一局；持有输入辅助需求的玩家也不会被 UI 节奏劝退**。Accessibility 是 P5 的人群包容性扩展：不只是时间维度的可玩，还是用户多样性维度的可玩。但包容性不是免除挑战 —— 它只是清除**非设计意图的感知障碍**，保留所有博弈张力。

### 5 NOT 边界（scope creep 防护）

- **NOT** 修改 AP / KPI / Energy 任何数学规则（Anti-P1 红线；见 Rule 7）
- **NOT** 跳过 KPI 月末结算 / 修改结算结果（违反 P3 + Anti-P1；绝无"易模式降低 KPI 门槛"）
- **NOT** 自动玩 / 替代玩家决策（违反 P1 Autonomy；辅助是感知清晰，不是替代选择）
- **NOT** 解锁机械成长内容（违反 Anti-P1；Accessibility 不是隐藏的解锁条件）
- **NOT** 改变 Pillar 4 tone（无"鼓励文案模式" / 无"正能量 GAME OVER 文案" / 无 tone 软化选项）

### 5 NOT 红线（违反即破坏 Pillar 或 Anti-P1 守门）

- **NOT** 任何 Accessibility 路径修改 AP 每日配额 / KPI 阈值公式 / Energy 上限（Anti-P1，违反即 PR-blocking）
- **NOT** 色盲模式替换 GAME OVER 文案（`GAMEOVER.TITLE_IRONY` "恭喜晋升"在色盲模式下**原文保留**，P4 守门无豁免）
- **NOT** 字体大小切换触发 reflow 超 `#3 Localization Rule 5` 的 ≤30 帧 / ≤500 ms 时序约束
- **NOT** 色盲 palette 与 `#5 Lighting Rule 2 + Rule 12` 的 Tonemapper Filmic 锁冲突（palette swap 走 `palette_index` uniform，不替换 CanvasModulate）
- **NOT** 输入辅助改变 `#2 Input Rule 4` anti-QTE 铁则（长按宽容是输入辅助，QTE 本身就不存在于本游戏）

### Source 引用（跨系统契约锁）

- `#3 Localization Hooks` Rule 9：字体 fallback 链 + Compact variant + `AUTO_FIT_FLOOR_PX = 11`（字体大小档位必须遵守）
- `#5 Lighting & Visual State Controller` Rule 11：累积视觉 4 维度的 `mute_visual_parity` 静音双重编码（色盲模式 NPC 关系 fallback 文字标签对齐 R-LVS-4 + R-AUD-5 跨守）
- `#13 HUD Diegetic` Section A + Rule 9（NPC interaction binding）：NPC 表情 / 站位是关系 visual encoding，色盲模式须有文字 fallback 标签
- `#17 Main Menu / Pause / Settings UI`：Settings UI 子屏注入 Accessibility 选项面板（本 GDD 定义 schema，#17 拥有 UI 屏）
- `#2 Input Handler` Rule 4：anti-QTE 铁则（Accessibility 输入辅助不能引入 QTE 类操作）
- `design/gdd/save-system.md` Rule 14：`meta_settings_debounce_ms = 500 ms`（所有 Accessibility 设置持久化路径）

---

## Section B — Player Fantasy

### 主锚: "字体大一点也是这游戏"

**场景**（玩家时刻）:

他在地铁上开游戏。屏幕亮度低，旁边大爷靠着他。他把字体调到 Large。

"王总今天没来，没准今天可以少打两张卡。"

他读到了这句话。不是因为字更大了变得更好读 —— 是因为作者想让他读到。字体变大了，但讽刺没有变温柔，KPI 没有变容易，NPC 还是那几个熟悉的臭脸。这还是那个破游戏。

**这是字体可访问性的 tone 守门**: 调整的是感知通道，不是游戏世界观。

### 副锚: "色盲模式不让你赢得更轻松，只让你看得清"

**场景**（玩家时刻）:

他是红绿色盲。开 Deuteranopia 模式。

KPI 进度线的颜色换了 —— 但他不会因此更容易维持平庸。他只是**终于能读出那根线是黄色还是红色**。Lisa 的关系阶段没有变好，她只是终于在"HOSTILE"状态下旁边多了一个文字标签，让他不靠颜色就能知道"哦，她又不高兴了"。

规则一个字没变。数字一个字没变。讽刺一个字没变。只是感知的通道被清理干净了。

### Tone 锚点

**对** 的参考: 眼镜度数配准了的那种感觉（功能层清晰，世界层不变）；把手机调成黑白模式的人还是同一个人；地铁上给老人让座后继续刷手机 —— 功能性行为，不是仪式。
**反** 的参考: 不是"为特殊玩家降低难度的爱心模式"；不是"易模式"；不是"感谢您开启辅助功能！您的游戏体验将更加愉快！"；不是 RPG 里 Accessibility 选项旁边的爱心图标；不是"我们关心每一位玩家"开场语。

### 玩家不会说的话 / 会说的话

- ❌ "这游戏辅助功能做得很贴心！" / "感动，专门为残障玩家设计了" / "Easy Mode 打开了"
- ❌ "字大了好多游戏变简单了" / "色盲模式让这游戏变好看了"
- ✅ "字大点，地铁上能玩了。" / "终于能分清那根线是什么颜色了。"
- ✅ "该死的 KPI 还是涨了。" —— **这是正确结果**，字体大了但博弈没变

---

## Section C — Detailed Rules

### Core Rules

**Rule 1 — 字体大小 4 档（feel knob）**

字体大小提供四档：`SMALL`（-20% 基准缩放）/ `MEDIUM`（基准缩放，= art-bible §7.2 默认值）/ `LARGE`（+25%）/ `X_LARGE`（+50%）。档位实现为 `FontSizePreset` enum，注入 `AccessibilitySettings` autoload 单例，各 UI GDD 在 `_ready()` 读取并应用至各自 Label / RichTextLabel。

字体缩放遵守 `#3 Localization Rule 9` 的完整 fallback 链：
- **Step 0**: 直接渲染对应档位字号
- **Step 1**: 若容器溢出，启用 Compact variant（art-bible §7.2 定义）
- **Step 2**: 若 Compact 后仍溢出，启用 `auto_fit`（floor = `AUTO_FIT_FLOOR_PX = 11`，禁止低于 11 px，见 entities.yaml + art-bible §7.2 CJK 笔画粘连红线）
- **Step 3**: 若 `X_LARGE` + 极短容器 + 极长字串三重叠加仍无法容纳，触发 Edge 1.3 降级策略（见 Section E）

字体档位变更即时生效（同帧），触发 `#3 Localization Rule 5` 的 `NOTIFICATION_TRANSLATION_CHANGED` 广播路径（静态 Label 自动刷新 + 已注册 RichTextLabel rebuild），端到端 reflow ≤30 帧 / ≤500 ms。

**禁止**：字体档位变更修改 AP / KPI / Energy 任何数值 layout。AP / KPI / Energy 数值的**文本展示容器**必须在所有 4 档下均可容纳对应字符，如不能则容器 resize 而非数值裁剪。

**Rule 2 — 色盲模式 3 档（感知 palette swap）**

提供 `ColorblindPreset` enum 四值：`NONE`（默认）/ `DEUTERANOPIA`（红绿色弱，约 5–8% 男性）/ `PROTANOPIA`（红色缺失）/ `TRITANOPIA`（蓝黄色弱）。

实现路径：复用 `#5 Lighting` 的 `palette_index` uniform（`palette_swap.gdshader`）。色盲模式激活时，`AccessibilitySettings` 发 `colorblind_mode_changed(preset: ColorblindPreset)` 信号；Lighting Controller 据此切换全局 palette LUT（`assets/data/accessibility/colorblind_lut_[preset].png`，美术另行交付），在 `CanvasModulate` 之后叠加第二 shader pass —— **不替换** CanvasModulate 色调表（Lighting 的 8 sub-mode 仍正常运行，只是最终 palette 被重映射）。

色盲 palette 不影响 `GAMEOVER.TITLE_IRONY` 文案内容（P4 守门，无豁免），不影响 KPI / AP / Energy 数值计算（Anti-P1 守门）。

**Rule 3 — 高对比度模式（呈现增强）**

`high_contrast: bool`（默认 `false`）。激活时各 UI GDD 在自身渲染层注入：
- (a) UI 边缘描边 +1 px（art-bible §3.3 "1 px 边框"加强变体，颜色为高对比 foreground token）
- (b) diegetic 元素（便利贴 / 咖啡杯 / 显示屏 / 日历）外轮廓 +1 px 描边 shader pass（技术实现：`AccessibilitySettings.high_contrast_changed(bool)` 信号触发 HUD #13 / Card Play #14 各自的 `_on_high_contrast_changed()` 回调）
- (c) HUD #13 NPC 站位 / 表情 diegetic 元素描边强化（配合 Rule 6 色盲关系 fallback 文字标签的可见性）

高对比度不改变场景背景整体色调（不破坏 `#5 Lighting` 8 sub-mode 视觉叙事语义），只增强前景元素边缘可读性。

**Rule 4 — 输入辅助（交互宽容策略，守 `#2 Input Rule 4` anti-QTE）**

`input_assist: bool`（默认 `false`）。激活时生效以下三条宽容策略：

(a) **长按代替双击**: 凡 `#2 Input` 定义的 `act_confirm` 双击操作，`input_assist` 模式下改为 `INPUT_ASSIST_HOLD_MS = 600` ms 长按触发。`#2 Input Handler Rule 3` F2 D-Pad repeat 不受影响（已是长按模式）。

(b) **大触发区**: Card Play #14 / HUD #13 中可交互 diegetic 元素的点击热区扩大为视觉边界 +`INPUT_ASSIST_HIT_EXTEND_PX = 16` px 各边。不触发额外游戏逻辑，仅扩大命中判定区域。

(c) **误触保护**: 连续两次同一 action 的最短触发间隔从 default（`#2 Input F2 D-Pad repeat = 350 ms`）放宽至 `INPUT_ASSIST_MIN_REPEAT_MS = 500 ms`。仅影响 `act_confirm` / `act_cancel` 类 UI 操作，不影响 `#2 Input Rule 5` skip 协议（skip 是明确意图，不受保护间隔影响）。

**禁止**：任何 `input_assist` 路径引入 QTE / 节奏类操作（Anti-Pillar 3 铁则；本游戏本无 QTE，此条为 future scope creep 防护）。

**Rule 5 — 文本朗读 TTS（野心版 scope 占位，Alpha 实验性，MVP/VS 不实现）**

`tts_enabled: bool`（默认 `false`；仅 Alpha+ 版本暴露）。激活后订阅 `#3 Localization tr()` 输出管道：每次 UI Label / RichTextLabel 渲染新内容时，调用 Godot 4.6 `DisplayServer.tts_speak(text, voice_id)` 朗读对应字串。

TTS scope：仅朗读面向玩家的 `tr()` 输出（Card Play 对白 / HUD 状态变化 toast / Event 事件摘要 / KPI Review 结算文本）。不朗读 debug 字串，不朗读 BGM / SFX 元数据，不经过 `#4 Audio Manager`（平台 TTS，不占 audio bank 预算）。

TTS 实现依赖 Godot 4.6 `DisplayServer` TTS API（平台支持：Windows ≥ 10 / macOS ≥ 11 / Linux espeak-ng）。平台覆盖率验证见 OQ-A11Y-01。**本 Rule 为 scope 占位**，不进入 MVP / VS acceptance criteria。

**Rule 6 — 静音双重编码（跨守 R-LVS-4 / R-AUD-5）+ NPC 关系 fallback 文字标签（色盲模式）**

**6a 静音双重编码（R-LVS-4 / R-AUD-5 跨守）**: 凡 `#5 Lighting Rule 11` 定义的"重要游戏信息通过视觉颜色编码"的情形（KPI 进度线颜色变化 / AP 便利贴颜色填充状态 / Energy 咖啡杯液位色调），`AccessibilitySettings.colorblind_preset != NONE` 时，HUD #13 / KPI Review #16 / Recap UI #15 各自在对应 diegetic 元素旁注入**文字辅助标签**（`accessible_label: Label`，默认 hidden，`colorblind_preset != NONE` 时 visible）。文字标签内容由 `#3 Localization tr()` 管辖（key 命名：`A11Y.HUD.AP_COUNT_LABEL` / `A11Y.KPI.STATUS_LABEL` 等）。

**6b NPC 关系 fallback 文字标签（色盲模式 / 高对比度模式）**: `#13 HUD Diegetic` 的 NPC 表情 / 站位是关系数值的视觉编码（P4 黑色幽默具象）。`colorblind_preset != NONE` 或 `high_contrast = true` 时，HUD #13 在 NPC diegetic 元素旁注入 `A11Y.HUD.NPC_RELATIONSHIP_[PHASE]` 文字标签（如 `tr("A11Y.HUD.NPC_RELATIONSHIP_HOSTILE")`）。标签位置由 `design/ux/colorblind-hud-fallback.md` UX spec 定义（📌 UX Flag，Phase 4 Alpha）。

标签 tone 守护：内容为状态描述词，不含鼓励语义（禁 "关系改善！" / "加油！" 等正能量词条，P4 守门）。

**Rule 7 — 禁 Accessibility 修改 AP / KPI / Energy 数学（Anti-P1 红线，PR-blocking）**

任何 Accessibility 设置路径（字体档位 / 色盲模式 / 高对比度 / 输入辅助 / TTS）**绝对禁止**：
- 修改 `AP_DAILY_QUOTA`（`#7 AP Economy Rule 1`，固定值 8）
- 修改 KPI 阈值公式（`#9 KPI Rule 2–5` 三维度涨幅公式）
- 修改 `ENERGY_DAILY_RECOVERY`（`#7 AP Economy Rule 8` Energy 回复规则）
- 修改 `CAPACITY_FLOOR`（`#7 AP Economy Rule 12`）
- 修改 effort 三维度权重（`#7 AP Economy F4`）
- 修改任何 `#9 KPI` 涨阈值公式参数

**实现守门**：`AccessibilitySettings` 单例只暴露渲染/感知相关字段，**不含任何 Gameplay numeric 字段**。单例 schema 定义必须通过 `tools/a11y_schema_lint.gd` CI 检查（lint 规则：单例字段名含 `AP` / `KPI` / `ENERGY` / `CAPACITY` / `EFFORT` 等 Gameplay-namespace 关键词，即 PR-blocking）。

**Rule 8 — 禁 Accessibility 改 Pillar 4 tone（无鼓励文案模式）**

无论任何 Accessibility 设置，以下 tone 规则不可改变：
- `GAMEOVER.TITLE_IRONY` "恭喜晋升" 文案原文保留（禁 "游戏结束" / "再试一次！" 替代）
- KPI Review 结算文案 tone 不变（禁 "您已完成本月目标！" 鼓励变体）
- 所有 `#3 Localization Rule 1 _IRONY` 后缀 key 的译文在任何 Accessibility 模式下**一字不改**
- Accessibility 子屏本身的文案通过 `#3 tr()` 管辖，服从 Localization tone 审核（无 `_IRONY` key 的 Accessibility 文案不得含励志 / 鼓励 / 爱心语义，P4 守门）

**Rule 9 — Settings UI 注入（#17 Main Menu Settings 子屏）**

Accessibility 选项面板注入 `#17 Main Menu / Pause / Settings UI` 的 Settings 子屏（与 Audio #4 音量子屏、Localization #3 语言子屏并列为三个独立 tab）。`#17` 拥有屏幕容器与导航；本 GDD 定义 Accessibility tab 内的字段 schema 与 signal 契约。

Settings 子屏字段（Alpha 完整版）：

| 字段 | 类型 | 默认 | Rule |
|------|------|------|------|
| `font_size_preset` | `FontSizePreset` enum | `MEDIUM` | Rule 1 |
| `colorblind_preset` | `ColorblindPreset` enum | `NONE` | Rule 2 |
| `high_contrast` | bool | false | Rule 3 |
| `input_assist` | bool | false | Rule 4 |
| `tts_enabled` | bool | false | Rule 5（Alpha only，实验性）|

全部设置变更通过 `meta_settings_debounce_ms = 500 ms`（entities.yaml）防抖后写入 `meta.save`（Save Rule 14 统一管辖）。Accessibility Settings **不写独立 settings.cfg 文件**（对齐 Save System Rule 20）。

**Rule 10 — Scope Tier 边界（Alpha / VS / MVP 三档）**

| 功能 | MVP | VS | Alpha |
|------|-----|----|-------|
| 字体大小 4 档（Rule 1）| 不启用 | ✅ 实现 | ✅ 实现 |
| 色盲模式 3 档（Rule 2）| 不启用 | ✅ 实现 | ✅ 实现 |
| 高对比度模式（Rule 3）| 不启用 | 不启用 | ✅ 实现 |
| 输入辅助（Rule 4）| 不启用 | 不启用 | ✅ 实现 |
| TTS（Rule 5）| 不启用 | 不启用 | 实验性 |
| 静音双重编码 6a（Rule 6a）| 不启用 | ✅（与色盲联动）| ✅ 实现 |
| NPC fallback 文字标签 6b（Rule 6b）| 不启用 | ✅（与色盲联动）| ✅ 实现 |
| Anti-P1 守门 lint（Rule 7）| ✅ CI lint 从 MVP 上线 | ✅ | ✅ |
| Pillar 4 tone 守门（Rule 8）| ✅ 文案层从 MVP 上线 | ✅ | ✅ |
| Settings UI 注入（Rule 9）| 无 | 字体 + 色盲 2 字段 | 完整 5 字段 |

Anti-P1 lint（Rule 7）和 Pillar 4 tone 守门（Rule 8）从 MVP 即上线，因为这两条是**防护性守门**，而非功能实现。

### States（Accessibility Settings Schema）

Accessibility Options 无自身状态机（纯设置读取层）。其状态由 `AccessibilitySettings` autoload 单例持有，字段即状态：

```
AccessibilitySettings {
  font_size_preset: FontSizePreset      # SMALL | MEDIUM | LARGE | X_LARGE
  colorblind_preset: ColorblindPreset   # NONE | DEUTERANOPIA | PROTANOPIA | TRITANOPIA
  high_contrast: bool
  input_assist: bool
  tts_enabled: bool  # Alpha only
}
```

初始化：从 `meta.save` 反序列化（Save Rule 14 路径），若字段缺失则 fallback 至默认值（不崩溃）。

### Interactions

| # | 触发方 | 事件 | Accessibility 响应 | 依赖 |
|---|--------|------|--------------------|------|
| I-1 | 玩家在 #17 Settings 子屏调字体档位 | `font_size_changed(preset: FontSizePreset)` emit | 触发 `NOTIFICATION_TRANSLATION_CHANGED` 广播 → 全 Label / RichTextLabel reflow ≤30 帧 | #3 Rule 5 + Rule 9 |
| I-2 | 玩家开启色盲模式 | `colorblind_mode_changed(preset: ColorblindPreset)` emit | Lighting Controller 切换 palette LUT；HUD #13 / #15 / #16 注入 fallback 文字标签（6a + 6b） | #5 Rule 2 + Rule 6；Rule 6b |
| I-3 | 玩家开启高对比度 | `high_contrast_changed(enabled: bool)` emit | HUD #13 / #14 / #15 / #16 各自 `_on_high_contrast_changed()` 描边注入；NPC fallback 文字标签同步激活（6b） | Rule 3；各 UI GDD |
| I-4 | 玩家开启输入辅助 | `input_assist_changed(enabled: bool)` emit | #14 / #17 交互层读取 `AccessibilitySettings.input_assist` 调整 hit extend + hold threshold | Rule 4；#2 Input |
| I-5 | 游戏启动 / 存档加载 | 从 `meta.save` 反序列化 | `AccessibilitySettings._load_from_save()` → 各系统初始化时读取单例 | Save Rule 14 |
| I-6 | `mute_visual_parity` 触发（#5 R-LVS-4）| 静音状态时视觉信息独立可达 | 色盲模式 fallback 文字标签确保静音 + 色盲双重屏蔽下信息仍可读 | Rule 6a；R-LVS-4 |
| I-7 | `high_contrast` + `colorblind_preset != NONE` 同时激活 | 复合感知辅助 | 描边 + fallback 文字标签同时注入；palette LUT + 描边为两个独立 shader pass，无冲突 | Rule 2 + Rule 3 |

---

## Section D — Formulas

N/A（Accessibility Options 为纯设置注入层，无独立数学公式）。

所有字体缩放比例为 feel knob（见 Section G），由美术 / UX 实测调优，无公式推导。色盲 palette LUT 为美术资产交付（colorimetry 映射由 technical artist + 美术总监按 WCAG 2.1 AA 标准调校），不是运行时公式。

---

## Section E — Edge Cases

### Cat 1 — 字体溢出（4 cases）

**E-1.1 `X_LARGE` + 短容器 + 长 CJK 字串**: 触发 Rule 1 Step 1→2→3 降级链。若 `AUTO_FIT_FLOOR_PX = 11` 后仍溢出（Step 3），容器**水平 resize**（grow 方向由 UX spec 定；不裁剪文字；不缩减数值 content）。Card Play UI #14 卡面宽度为 fixed art asset，此情形 UX 必须在 Phase 4 Alpha 专项测试（📌 UX Flag）。

**E-1.2 字体切换时 diegetic 元素物理尺寸撑开 scene**: HUD #13 diegetic 元素（便利贴、日历）为物理 Sprite2D，字体档位不影响 Sprite 尺寸（字体仅影响嵌入 Label overlay）。Label overlay 若溢出 Sprite 边界，走 Step 2 Compact variant，**禁止** Sprite 物理尺寸随字体档位动态缩放（违反 art-bible §7.1 diegetic 物理感）。

**E-1.3 `X_LARGE` + Compact + Step 3 降级后容器仍无法容纳**: 降级策略：省略号截断（`…`）+ `push_warning("A11Y: text overflow unresolvable for key [KEY]")`，UI 不崩溃，数值不受影响，QA 记录为 asset spec issue 而非代码 bug。

**E-1.4 字体切换触发 reflow 超 500 ms 时序约束（#3 Rule 5）**: RichTextLabel rebuild 耗时超 `AUTO_FIT_FLOOR_PX` 批次预算时，`#3 Localization` 的 30 帧 / 500 ms watchdog 会触发 `push_error`（不崩溃，不阻 gameplay）。Accessibility Rule 1 不引入独立 watchdog，复用 Localization 现有 watchdog。

### Cat 2 — 色盲调色板（4 cases）

**E-2.1 色盲 palette LUT 文件缺失（Asset Not Found）**: `colorblind_lut_DEUTERANOPIA.png` 等资产缺失时，Lighting Controller `push_error("A11Y: colorblind LUT missing for preset [PRESET]")` + 回退至 `NONE` 模式（不崩溃）。Dev 构建显示 `[A11Y LUT MISSING]` 标签。Prod 构建无视觉提示（非玩家感知错误）。

**E-2.2 色盲模式 + `#5 Lighting` 8 sub-mode 叠加**: palette LUT 叠加在 CanvasModulate **之后**（第二 shader pass），不干扰 CanvasModulate 的 8 sub-mode 色调切换（加班蓝光 / 月末红光等叙事语义保留；仅色觉映射改变）。两 shader pass 独立，无 z-order 冲突。

**E-2.3 色盲模式 + `GAMEOVER.TITLE_IRONY` 文案**: 色盲模式不改变 GAME OVER 屏任何文案（P4 守门无豁免，见 Rule 8）。KPI Review #16 GAME OVER 文案 tone 原文保留，色盲只改颜色映射，不改文字。

**E-2.4 `TRITANOPIA` + HUD 蓝光叠加（#5 overtime sub_mode）**: `sub_mode = OVERTIME_ACTIVE` 时 HUD #13 有蓝光 overlay（art-bible §6.2）。Tritanopia 模式蓝黄色弱，蓝光 overlay 可能造成信息混乱。缓解：若 `colorblind_preset = TRITANOPIA` 且 Lighting sub_mode = `OVERTIME_ACTIVE`，HUD #13 额外注入 overtime 状态文字 toast（`A11Y.HUD.OVERTIME_ACTIVE_LABEL`）作为第二感知通道（Rule 6a 扩展）。

### Cat 3 — 输入辅助与 `act_skip` race（3 cases）

**E-3.1 `input_assist` + `act_skip` 同帧**: 输入辅助扩大 hit zone 与 `#2 Input Rule 5` skip 协议独立。skip 的注册 / 取消由 `#6 Scene Flow` owns；输入辅助只影响 UI confirm/cancel 的触发阈值，不影响 skip 判定。同帧 `act_skip` 优先（`#2 Input Rule 5` 语义：skip 是明确意图）。

**E-3.2 `input_assist` hold 600 ms + 误触保护 500 ms 叠加**: 若玩家在 500 ms 保护窗口内触发第二次 `act_confirm`，该触发被丢弃（保护窗口有效）。若玩家持续按住 600 ms（满足 hold threshold），触发 `act_confirm`，保护窗口从该次触发**重新计时**。两机制无死锁。

**E-3.3 `input_assist` 激活期间玩家在 Settings 切换 `input_assist = false`**: 设置变更即时生效（同帧，来自 I-4 信号路径）。进行中的 hold 计时中止（hold callable cancel），已注册的 hit extend 回退至 default 值。不影响当前 active event / card play 状态。

### Cat 4 — Anti-P1 红线（2 cases，RISK GUARD）

**[RISK GUARD] R-A11Y-1 — Accessibility 路径修改数值规则漏入（违反 Anti-P1，PR-blocking）**

风险描述: 开发者实现字体大档位时，Card Play #14 容器 resize 逻辑错误调用卡池过滤函数 → 间接影响可打出卡牌集合 → Anti-P1 违规（通过感知层间接改变 Gameplay 数值语义）。

守门实现:
- `tools/a11y_schema_lint.gd` CI lint：`AccessibilitySettings` 单例字段名黑名单（`AP` / `KPI` / `ENERGY` / `CAPACITY` / `EFFORT` 等 Gameplay-namespace 关键词），字段出现 → PR-blocking fail
- Code review 规则：PR reviewer 检查任何 Accessibility signal handler（`_on_font_size_changed` / `_on_colorblind_mode_changed` 等）是否调用了 AP / KPI / Energy 相关 API，发现即 block merge
- AC-FUNC-08 / AC-FUNC-09 / AC-FUNC-10 覆盖（见 Section H）

**[RISK GUARD] R-A11Y-2 — 色盲模式 NPC 关系视觉 fallback 缺失（R-LVS-4 跨守）**

风险描述: `colorblind_preset != NONE` 激活，HUD #13 NPC 表情 / 站位视觉编码仍依赖颜色区分关系阶段 → 色盲玩家无法读取关系信号 → 核心博弈信息通道损坏。

守门实现:
- Rule 6b 强制 NPC fallback 文字标签（`colorblind_preset != NONE` 时 visible）
- AC-ROBUST-01 测试用例：Deuteranopia 模式下 NPC 关系 HOSTILE → HUD #13 显示 `tr("A11Y.HUD.NPC_RELATIONSHIP_HOSTILE")`（非空字串，非 `[MISSING:]` 前缀）
- `#13 HUD` 的 `_on_colorblind_mode_changed()` 回调必须覆盖全部 `RelationshipPhase` enum 值（lint：若 `RelationshipPhase` 新增枚举值，触发 `#13 _on_colorblind_mode_changed()` 的 match 穷举检查 warning）

---

## Section F — Dependencies

### Upstream（Accessibility 从这些系统读取契约）

| # | System | 契约内容 | 数据流向 |
|---|--------|----------|----------|
| #2 | Input Handler | Rule 4 anti-QTE 铁则；`act_confirm` / `act_cancel` action 语义；hit zone 扩展点 | 单向：Accessibility 读取 Input 规则，不修改 Input 状态 |
| #3 | Localization Hooks | Rule 9 字体 fallback 链 + `AUTO_FIT_FLOOR_PX = 11`；Rule 5 `NOTIFICATION_TRANSLATION_CHANGED`；Rule 1 key 命名（`A11Y.*` domain 新增须改 Rule 1）；Rule 11 `_IRONY` lint | 双向：Accessibility 触发 Loc NOTIFICATION 广播；Loc 管辖 Accessibility 文案 key |
| #5 | Lighting & Visual State Controller | Rule 2 `palette_index` uniform + LUT atlas 接口；Rule 11 累积视觉双重编码语义；`scene_visual_changed` 信号；8 sub-mode enum | 双向：Accessibility 发 `colorblind_mode_changed` → Lighting 切 LUT；Lighting R-LVS-4 触发 Accessibility Rule 6a |
| #13 | HUD Diegetic | NPC diegetic 元素 visual encoding；`RelationshipPhase` enum；`_on_colorblind_mode_changed()` / `_on_high_contrast_changed()` 回调注册 | 双向：Accessibility 信号 → HUD 注入 fallback 标签；HUD 不直接修改 Accessibility 状态 |
| #14 | Card Play & Dialogue UI | 卡面容器 fixed-width art constraint；`act_confirm` hit zone 扩展点；对白 RichTextLabel owner | 单向：Accessibility 注入 hit extend + font preset；#14 不修改 Accessibility 状态 |
| #15 | Daily / Weekly Recap UI | effort numeric 展示容器；`numeric_only` 数字展示协议 | 单向：Accessibility font / contrast 注入；#15 不修改 Accessibility 状态 |
| #16 | KPI Review & Game Over UI | GAME OVER 文案 tone 保护（P4）；结算数值展示容器 | 单向：Accessibility 色盲 / 对比度注入；绝不改 GAME OVER 文案（Rule 8）|
| #17 | Main Menu / Pause / Settings UI | Settings 子屏容器注入点；tab 导航；`meta_settings_debounce_ms` 防抖写 Save | 双向：#17 owns 屏幕容器；Accessibility owns schema + signal；共用 Save Rule 14 路径 |
| Save | Save System | Rule 14 `meta.save` 持久化路径；`meta_settings_debounce_ms = 500 ms` | 单向：Accessibility 写入 Save；Save 只序列化字段，不读 Accessibility schema |

### Downstream（依赖 Accessibility 的系统）

Accessibility Options 是 Polish Layer 终端系统，无下游系统依赖本 GDD 的输出。注入方向为 Accessibility → 所有 Presentation Layer 系统（单向注入）。

### 双向一致性 cross-check

- `#3 Localization Rule 9` + `AUTO_FIT_FLOOR_PX = 11` ↔ Rule 1 字体 Step 2 floor = 11 ✓
- `#5 Lighting Rule 11` `mute_visual_parity` 双重编码语义 ↔ Rule 6a 静音 + 色盲双屏蔽 fallback ✓
- `#13 HUD` NPC visual encoding ↔ Rule 6b fallback 文字标签（`RelationshipPhase` 枚举穷举）✓
- `#2 Input Rule 4` anti-QTE ↔ Rule 4 输入辅助禁 QTE ✓
- Save Rule 14 `meta_settings_debounce_ms = 500 ms` ↔ Rule 9 持久化路径 ✓

### Propagation Flags（下游 GDD 需更新）

- **#3 Localization**: 新增 `A11Y.*` domain（Rule 1 domain 枚举须添 `A11Y`）；新增约 30–50 条 `A11Y.*` key（key 命名 + CSV 更新）
- **#5 Lighting**: Rule 2 须新增 `colorblind_mode_changed(preset)` 信号接收 + LUT 切换逻辑；Rule 11 须引用 Rule 6a `mute_visual_parity` 扩展
- **#13 HUD**: 须实现 `_on_colorblind_mode_changed()` + `_on_high_contrast_changed()` 回调（Rule 6b fallback 文字标签 + Rule 3 描边注入）；须穷举 `RelationshipPhase` 枚举
- **#17 Main Menu**: 须在 Settings 子屏注入 Accessibility tab（Rule 9 schema）；VS tier 时注入 2 字段，Alpha 时注入 5 字段

---

## Section G — Tuning Knobs

### Feel Knobs（改变即时感知体验，通过 UX 实测调优）

| Knob | 当前值 | 范围 | 单位 | Category | 理由 |
|------|--------|------|------|----------|------|
| `FONT_SIZE_SMALL_SCALE` | 0.80 | 0.70–0.90 | ratio | feel | -20% 基准；信息密度优先场景（地铁小屏）|
| `FONT_SIZE_LARGE_SCALE` | 1.25 | 1.15–1.35 | ratio | feel | +25% 基准；需实测低分辨率 + 远视场景 |
| `FONT_SIZE_X_LARGE_SCALE` | 1.50 | 1.30–1.70 | ratio | feel | +50% 基准；强视觉辅助场景 |
| `INPUT_ASSIST_HOLD_MS` | 600 | 400–800 | ms | feel | 长按阈值；参考 WCAG 2.1 "操作时间不超过 1 秒"+ 实测 |
| `INPUT_ASSIST_HIT_EXTEND_PX` | 16 | 8–24 | px | feel | hit zone 扩展；参考 Apple HIG 44 pt minimum target（像素 2D 等比）|
| `INPUT_ASSIST_MIN_REPEAT_MS` | 500 | 350–700 | ms | feel | 误触保护窗口；base = `#2 Input F2` 350 ms + 43% 宽容 |

### Curve Knobs（影响进度曲线 / 触发时机，通过标准调优）

| Knob | 当前值 | 范围 | 单位 | Category | 理由 |
|------|--------|------|------|----------|------|
| `AUTO_FIT_FLOOR_PX` | 11 | 11–14 | px | curve | `#3 Localization Rule 9` 锁定值；**不得低于 11**（art-bible §7.2 CJK 笔画粘连红线）|
| `A11Y_LABEL_FADE_MS` | 150 | 100–300 | ms | curve | fallback 文字标签淡入时长（色盲模式激活时）；过短 = 闪烁，过长 = 信息延迟 |

### Gate Knobs（影响功能开关时机，通过 Scope Tier 决定）

| Knob | 当前值 | 触发条件 | Category | 理由 |
|------|--------|----------|----------|------|
| `A11Y_VS_FEATURES` | `[font_size, colorblind]` | VS tier 上线时启用 | gate | 仅字体 + 色盲；Rule 10 Scope Tier 表 |
| `A11Y_ALPHA_FEATURES` | `[high_contrast, input_assist, tts_scope]` | Alpha tier 上线时启用 | gate | 完整功能集；TTS 实验性 |
| `A11Y_CI_LINT_ENABLED` | true | MVP 即上线 | gate | Anti-P1 守门从 MVP 即生效（防护性，不依赖 A11Y 功能实装）|

### 色盲调色板表（LUT 资产目录，美术交付）

| Preset | LUT 文件路径 | 状态 | 调校标准 |
|--------|------------|------|---------|
| DEUTERANOPIA | `assets/data/accessibility/colorblind_lut_deuteranopia.png` | 待美术交付 | WCAG 2.1 AA + Coblis simulator 验证 |
| PROTANOPIA | `assets/data/accessibility/colorblind_lut_protanopia.png` | 待美术交付 | 同上 |
| TRITANOPIA | `assets/data/accessibility/colorblind_lut_tritanopia.png` | 待美术交付 | 同上 |

---

## Visual / Audio Requirements

### Visual Ownership

- Accessibility Options **不 own** 任何独立视觉资产（无独立场景 / 无独立 sprite / 无独立 shader）
- 色盲 LUT 资产（`colorblind_lut_*.png`）由美术总监 / technical artist 交付；本 GDD 锁定文件路径命名规范
- fallback 文字标签为 Label node，由各 UI GDD 注入，字体走 `#3 Localization` 规则（art-bible §7.2 字体层级适用）
- 高对比度模式描边 shader 由 `godot-shader-specialist` 实现（`AccessibilityHighContrast.gdshader`）；本 GDD 锁定行为语义，不锁技术实现

### Audio Ownership

- Accessibility Options **不 own** 任何音效 / BGM 资产（零音频，对齐 `#4 Audio Manager Rule 1` 零音频契约）
- TTS（Rule 5）调用 Godot `DisplayServer.tts_speak()`，非游戏 audio bus，不经过 `#4 Audio Manager`（平台 TTS，不占 audio bank 预算）

### 📌 UX Flags（Phase 4 Alpha）

- `📌 /ux-design design/ux/accessibility-screen.md`：设计 Accessibility Settings 子屏布局（Tab 内字段排布 / 预览 / gamepad D-Pad 全导航，focus 态遵守 `#2 Input Rule 1 act_focus_*` 约定）
- `📌 /ux-design design/ux/colorblind-hud-fallback.md`：HUD #13 NPC 关系 fallback 文字标签的 diegetic 集成方案（标签位置不破坏 art-bible §7.1 diegetic 锁；考虑 diegetic 便签纸样式，见 OQ-A11Y-03）

---

## UI Requirements

Accessibility Options **不 own 任何 UI 屏幕**。

唯一 UI 接触面：`#17 Main Menu / Pause / Settings UI` Settings 子屏内的 Accessibility tab（Rule 9 定义 schema）。

#17 须按 Rule 9 / Rule 10 Scope Tier 表的阶段性字段暴露实现 Accessibility tab：
- VS tier：2 字段（`font_size_preset` + `colorblind_preset`）+ 单列布局（gamepad D-Pad 上下导航）
- Alpha tier：5 字段（全字段）+ 分组布局（视觉辅助 / 输入辅助 / 语音辅助三分组，D-Pad 全导航，focus 态遵守 `#2 Input Rule 1 act_focus_*` 约定）

所有 Accessibility tab 文案通过 `#3 Localization tr()` 管辖（`A11Y.SETTINGS.*` domain）；无任何硬编码 zh_CN 字面量。

---

## Open Questions

**OQ-A11Y-01 — TTS 平台可行性验证（Alpha pre-production）**
Godot 4.6 `DisplayServer.tts_speak()` 在 Steam Deck（Linux / Proton）/ macOS 14+ / Windows 10 的覆盖率及音质是否满足 A11Y 最低可用标准？Owner: godot-specialist + accessibility-specialist。Target: Alpha kickoff 前原型测试。若平台覆盖率 < 80%，Rule 5 TTS 降级为"野心版（Full Vision）"延后。

**OQ-A11Y-02 — 色盲 LUT 调校验证流程（VS pre-production）**
`colorblind_lut_*.png` 的调校需要色觉异常测试者参与。团队是否有合适的用户测试渠道（Steam Beta 招募 / A11Y 专项测试组）？Owner: producer + accessibility-specialist。Target: VS kickoff 前确定测试流程 + 招募方案。

**OQ-A11Y-03 — HUD diegetic fallback 文字标签位置冲突（Alpha UX）**
Rule 6b NPC 关系 fallback 文字标签注入 diegetic HUD 时，标签位置可能与 art-bible §7.1 的"零悬浮 UI"原则产生视觉张力。是否允许标签以 diegetic 贴纸 / 便签纸形式渲染（art-bible §6.4 环境叙事元素样式）？这种方案是否保持 tone 一致性（P4 守门）？Owner: art-director + ux-designer。Target: Alpha Phase 4 UX 设计时决策（📌 UX Flag）。

**OQ-A11Y-04 — `X_LARGE` 字体 + Card Play #14 固定宽度卡面极端溢出验证（Alpha QA）**
Card Play #14 卡面为 fixed art asset，字体 `X_LARGE` 档下最长 Card event 文本是否会超出 Step 2 Compact 后仍溢出（触发 E-1.3）？需要 QA 建立专项 test fixture（所有卡面 + `X_LARGE` 组合覆盖）。Owner: qa-lead + ui-programmer。Target: Alpha QA 首轮测试建立 fixture。

---

## Section H — Acceptance Criteria

### AC-FUNC — 功能行为（11 条）

**AC-FUNC-01 [字体档位切换即时生效]**
Given: 玩家在 Settings Accessibility tab 选择 `LARGE` 档
When: Settings UI 关闭 / 档位变更信号 emit
Then: HUD #13 所有 Label / RichTextLabel 在 ≤30 帧（≤500 ms）内完成 reflow；字号符合 `FONT_SIZE_LARGE_SCALE = 1.25` 倍数（±2 px 容差）；AP 便利贴 diegetic 元素字体更新

**AC-FUNC-02 [色盲模式激活 — LUT + fallback 标签]**
Given: 玩家选择 `DEUTERANOPIA` 模式
When: Settings UI 关闭 / `colorblind_mode_changed` emit
Then: `#5 Lighting` 切换至 `colorblind_lut_deuteranopia.png`；HUD #13 NPC 关系 fallback 文字标签 visible；KPI 进度线 accessible 辅助标签 visible；`GAMEOVER.TITLE_IRONY` 文案内容**不变**（"恭喜晋升"原文）

**AC-FUNC-03 [高对比度模式描边注入]**
Given: 玩家开启 `high_contrast = true`
When: DayTimeline 场景 active
Then: HUD #13 全部 diegetic 交互元素（便利贴 / 咖啡杯 / 显示屏 / NPC）可见描边 +1 px；`#5 Lighting` 8 sub-mode 视觉语义不变（overtime 蓝光 / 月末红光 sub-mode 正常切换）

**AC-FUNC-04 [输入辅助长按触发]**
Given: `input_assist = true`
When: 玩家在 Card Play #14 按住 confirm 键 600 ms（`INPUT_ASSIST_HOLD_MS`）
Then: 触发 `act_confirm`（等同于 default 模式单击）；保护窗口 500 ms 内第二次按键被丢弃

**AC-FUNC-05 [输入辅助 hit zone 扩展]**
Given: `input_assist = true`
When: 玩家点击 HUD #13 便利贴视觉边界外 12 px 处（< `INPUT_ASSIST_HIT_EXTEND_PX = 16`）
Then: 命中判定生效；无额外 AP 消耗（hit zone 扩展不触发额外游戏逻辑）

**AC-FUNC-06 [Settings 设置持久化跨 session]**
Given: 玩家设置 `colorblind_preset = DEUTERANOPIA` + `font_size_preset = LARGE`
When: 游戏退出后重启
Then: 两项设置从 `meta.save` 正确反序列化；Settings tab 显示之前的选项值；Lighting + HUD 正确初始化为已设定状态

**AC-FUNC-07 [VS Scope Tier — 仅 2 字段可见]**
Given: 游戏处于 VS 版本构建
When: 玩家打开 Settings Accessibility tab
Then: 仅 `font_size_preset` + `colorblind_preset` 两字段可见；`high_contrast` / `input_assist` / `tts_enabled` 字段不可见（不暴露于 UI）

**AC-FUNC-08 [Anti-P1 守门 — 字体切换不改 AP 可打出卡牌集合]**
Given: Card Play #14 标准局面（AP = 4，可打出卡牌集合 = {A, B, C}）
When: 玩家在 Settings 切换字体至 `X_LARGE`
Then: 可打出卡牌集合**不变**（仍为 {A, B, C}）；AP 显示数字 = 4；卡面 resize 不触发卡池过滤逻辑

**AC-FUNC-09 [Anti-P1 守门 — 色盲模式不改 KPI 阈值]**
Given: 当前 KPI 阈值 = X（`#9 KPI` 规则计算值）
When: 玩家开启 `DEUTERANOPIA` 模式
Then: KPI 阈值数值**不变**（= X）；月末结算规则不变；`AccessibilitySettings` 单例中无任何 KPI-namespace 字段（CI lint 通过）

**AC-FUNC-10 [Anti-P1 lint CI 通过 — 字段黑名单]**
Given: 任意 PR 修改 `AccessibilitySettings` 单例字段定义
When: CI pipeline 运行 `tools/a11y_schema_lint.gd`
Then: 若字段名含 `AP` / `KPI` / `ENERGY` / `CAPACITY` / `EFFORT`，lint 报 ERROR，PR 被 block；合规字段 lint 通过（exit code 0）

**AC-FUNC-11 [Pillar 4 tone 守门 — 64 种 A11Y 组合不改 GAME OVER 文案]**
Given: 任意 Accessibility 组合开启（2×4×2×2×2 = 64 种）
When: 触发 GAME OVER
Then: `GAMEOVER.TITLE_IRONY` 渲染文案 = `tr("GAMEOVER.TITLE_IRONY")`（zh_CN = "恭喜晋升"）；无任何 Accessibility 路径替换此字串

### AC-PERF — 性能（3 条）

**AC-PERF-01 [字体 reflow 时序 ≤30 帧]**
Given: 任意字体档位切换
When: `_apply_font_preset()` 调用触发 `NOTIFICATION_TRANSLATION_CHANGED` 广播
Then: 全 RichTextLabel rebuild 端到端 ≤ 500 ms / 30 帧（复用 `#3 Localization Rule 5` 时序约束；CI profiler 断言）

**AC-PERF-02 [HUD 帧预算不受 A11Y 描边影响超 2 ms]**
Given: `high_contrast = true` + `colorblind_preset != NONE` 同时激活（复合压力）
When: DayTimeline 场景 60 FPS 稳定运行
Then: HUD #13 渲染时间 ≤ 2 ms / 帧（`#13 HUD P5 守门`；UI profiler 断言）

**AC-PERF-03 [色盲 LUT 切换不阻塞帧]**
Given: 玩家在游戏运行中切换色盲模式
When: `colorblind_mode_changed` 信号触发 Lighting LUT 切换
Then: 单帧耗时增量 ≤ 1 ms（LUT 为静态纹理替换，非 runtime shader compile）

### AC-ROBUST — [RISK GUARD 守门]（3 条）

**[RISK GUARD] AC-ROBUST-01 — R-A11Y-2 色盲模式 NPC 关系 fallback 不缺失**
Given: `colorblind_preset = DEUTERANOPIA`
When: NPC 关系阶段 = `HOSTILE`
Then: HUD #13 在该 NPC diegetic 元素旁显示 `tr("A11Y.HUD.NPC_RELATIONSHIP_HOSTILE")`（非空字串，非 `[MISSING:]` 前缀）

**[RISK GUARD] AC-ROBUST-02 — R-A11Y-1 Anti-P1 lint 在 MVP 即 CI 上线**
Given: MVP 首次 CI pipeline 执行
When: `tools/a11y_schema_lint.gd` 运行
Then: lint 不报 ERROR（`AccessibilitySettings` 初始 schema 合规）；lint tool 本身 exit code 0（工具可运行）

**AC-ROBUST-03 [色盲 LUT 缺失 fallback 不崩溃]**
Given: `colorblind_lut_deuteranopia.png` 资产文件缺失
When: 玩家选择 `DEUTERANOPIA` 模式
Then: 游戏不崩溃；`push_error` 日志记录；自动 fallback 至 `NONE` 模式；Settings UI 预设选项保留玩家意图（视觉上 DEUTERANOPIA 仍显示为选中，但功能降级；dev 构建显示 `[A11Y LUT MISSING]` 提示）

### AC-TONE — Pillar 4 守门（2 条）

**AC-TONE-01 [Accessibility 文案无励志 / 鼓励语义]**
Given: Accessibility Settings tab 全部文案通过 `tr()` 渲染
When: QA 人工审查 `A11Y.SETTINGS.*` 全部 CSV key 的 zh_CN 译文
Then: 无任何"加油"/"开启辅助获得更好体验"/"贴心功能为您服务"/"我们关心每位玩家"类词条；文案风格与游戏整体 tone 一致（中性描述性，无鼓励语义）

**AC-TONE-02 [NPC 关系 fallback 标签无鼓励语义]**
Given: `colorblind_preset != NONE`
When: NPC 关系阶段为 `FRIENDLY`
Then: `tr("A11Y.HUD.NPC_RELATIONSHIP_FRIENDLY")` 渲染内容为状态描述词（如"正常"/"还行"/"这人今天不烦"），**不包含**"很友好！"/"好感提升！"/"关系改善" 等正能量词条；P4 守门通过

---

> **Rough scope signal: M（producer should verify before sprint planning）**
> 依赖计数：8+ Presentation / Core / Foundation 系统注入点；Shader 资产 3 件（LUT ×3）+ 工具 1 件（`a11y_schema_lint.gd`）+ UI 注入 7 处；无独立 Gameplay 公式；需 UX 2 屏 spec（📌 A11Y screen + HUD fallback）。Alpha tier 设计完整，VS tier 字体 + 色盲子集，MVP 仅 CI lint + 文案守门。
> 主要风险：NPC fallback 文字标签 diegetic 集成方案（OQ-A11Y-03）未定（与 art-bible §7.1 diegetic 锁存在视觉张力）；TTS 平台覆盖率（OQ-A11Y-01）未验证。
