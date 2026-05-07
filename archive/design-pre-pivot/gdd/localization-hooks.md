# Localization Hooks

> **Status**: **Designed (pending review — awaits `/design-review design/gdd/localization-hooks.md --depth lean` in fresh session)**
> **Author**: user + main agent + creative-director (B framing) + localization-lead (C Core Rules) + godot-specialist (C 4.6 footgun) + ui-programmer (C 可行性 + F1) + systems-designer (D Formulas × 2 + E Edge Cases) + qa-lead (H Acceptance Criteria)
> **Last Updated**: 2026-04-24
> **Implements Pillar**: Pillar 5 (地铁可玩性 — 启动 5 秒承诺 / 语言切换不阻塞) [primary] + Pillar 4 (黑色幽默 tone 守护 — string key 命名 + 译文 irony 锚点不丢) [guard]
> **Review Mode**: Lean (CD-GDD-ALIGN skipped per `production/review-mode.txt`)

## Overview

Localization Hooks 是《活过第 X 集》字符串与 locale 基础设施层,坐于 Godot 4.6 `TranslationServer` 之上,把所有面向玩家的文本(UI 文案 / NPC 对白 / tooltip / 系统 toast / Save 与 Input 已挂的自动生成字符串)归一为一条 `tr(key)` 查询路径,并管理字体层级(art-bible §7.2 锁定的 4 级: 方正公文宋 / 思源黑体 / 5×7 bitmap / 站酷快乐体)、locale 切换、跨语言文本长度膨胀应对(autowrap / 降级至 11 px / 自动 fit)。所有上层系统(HUD #13、Card Play UI #14、Recap UI #15、KPI Review UI #16、Main Menu UI #17,以及已存在的 Input Handler #2 Section G 3 条 toast 文案)只通过 string key 引用,**不硬编码 zh_CN 字面量**。

本系统是 Pillar 5(地铁可玩性)的**技术窗口守护层**: MVP 仅发 zh_CN,野心版(Scope Tier 4)才补 en 本地化,但 **i18n infra 必须立刻锁定** —— 所有 MVP UI GDD 在编写时都订阅本 GDD 的数据契约,若后补 i18n 会触发全量 UI 重构,违反 5 秒进入承诺的可交付窗口。同时它是 Pillar 4(黑色幽默 tone)的**翻译守门员**: string key 命名必须保留 tone 语义锚(如 `GAMEOVER_TITLE_IRONY` 而非中性 `GAMEOVER_TITLE`),否则译者无法从 neutral key 回推 tone,野心版 en 极易退化为 Google-Translate-tone,毁掉"恭喜晋升"式的反讽 hook(art-bible §7.2 反讽钩锁定点)。

Localization Hooks **不**拥有:译文内容(交付为 `assets/i18n/*.csv`,本 GDD 仅锁 schema)、字体文件本身(art-bible §7.2 owns 字体选型,ui-programmer owns atlas 生成)、语言设置 UI 屏(Main Menu #17 owns,本 GDD 只暴露 `set_locale(locale: StringName)` 接口)、运行时机器翻译 / 在线翻译(违反 Pillar 5 地铁可玩性 + 单机 Anti-Pillar)。Locale 设置的持久化走 Save Rule 14 `meta.save` 路径(`meta_settings_debounce_ms = 500 ms` registry 已锁),本 GDD 绝不直接 `FileAccess.open`,仅 emit `locale_changed(locale)` 信号供 Save 订阅。

*技术实现细节(Godot 4.6 CSV plural form 具体格式 vs `.po`、字体 atlas 预生成与运行时切换策略、运行时切 locale 的节点刷新机制、string key 命名 convention 的具体 grammar、字符串 ID 注册器实现 vs 纯约定)留给 ADR 阶段决定;本 GDD 只锁行为语义、跨系统契约、MVP zh_CN 与野心版 en 的 scope 边界。*

## Player Fantasy

Localization Hooks 服务一种沉默的玩家瞬间,继承 Save / Input 相同 tone — **冷静、不抢戏、对比工位语境的低期待**。不同在于承诺落在哪里: Save 的承诺在运行时(不丢档)、Input 的承诺在响应层(不卡 / 跳过),本系统的承诺在**文本层** —— 读到的每个字都像这个作者写的,不像被翻译或被迭代磨过的。它不是被赞美的对象,是不被注意到的承诺。

### 不像翻译的(Pillar 4 guard)

周二晚 10:47 他第 7 次死在 KPI 月末结算。GAME OVER 屏弹出 —— 站酷快乐体,四个字: **"恭喜晋升"**。他没笑出声,但鼻子呼了一口气。

因为这四个字是中文写的。不是 "Congratulations on Your Promotion" 机翻回来的"祝贺您的升职",不是 AI 字幕组那种"让我们一起哭吧",不是电商推送的"尊敬的用户",不是任何"欢迎使用简体中文版"弹窗开头那种语言。**是《破事精英》台词的中文、是他妈在他微信里发小作文的中文、是同事群炸出"这班是真不想上了"的那种中文。** 玩家不会夸"这游戏本地化做得好" —— 他根本不会想到"本地化"这三个字,因为他根本没感觉到文本有"被处理"过。他只会觉得"这游戏说人话"。

### 喜丧不会漏(Pillar 4 反讽锚点的跨版本守护)

12 月他第 23 次重开一局,"恭喜晋升"还是这四个字,一个字不差。**不是**被某版 patch 的产品经理优化成了"本轮结束"(看起来更正式);**不是**被某位好心的译者改成了"晋升失败"(听起来"正能量不对");**不是**野心版 en 上线后为了对齐成 "You Got Promoted!" 反向回译成"您已升职";**不是**哪次 localization team review 里被盖"负面用词"章退回。

站酷快乐体 + 四个欢快的字 + 压在他 23 次死亡上的那层讽刺 —— 是作者从 MVP 第一版就锁死的,任何后续流程都不能把它磨平。art-bible §7.2 反讽钩写在那里;这个 GDD 的 string key 命名把它变成系统性的不可改动锚点。玩家不会意识到 GDD 保护了什么,他只会意识到"还是那个破游戏,笑点没被磨掉"。

### Tone 锚点

**对** 的参考: 自己写给自己看的中文、朋友圈转过 3 次的《破事精英》弹幕截图、老家亲戚把"生日快乐"打成"生日快乐啊" 的那种不修饰;Save 的"下班打卡机";Input 的"工位隔间键盘均匀节奏"。
**反** 的参考: 不是本地化 awards 的"elevates the experience";不是游戏开场"已检测到简体中文,为您切换"弹窗;不是 Steam 商店页"中文已支持 ✓" 勾选框的那种庆祝;不是"我们尊重每一位玩家"开场语;不是 AI 译者那种"让我们一起..."的文化漂白。Localization 不庆祝玩家,也不庆祝自己。

### 玩家不会说的话 / 会说的话

- ❌ "这游戏本地化做得真好" / "中文翻译很用心" / "字体选得不错" / "终于有游戏支持简体中文了"
- ❌ "语言切换流畅!" / "UI 没有因为长字符串错位,好评"
- ✅ (沉默 —— 关掉游戏去洗漱,完全没意识到自己刚刚在读文本)
- ✅ "说人话。" / "还是那个破游戏。"

## Detailed Rules

### Core Rules

1. **String key 命名约定(分层点记法 + `_IRONY` tone 后缀)**: 所有 string key 使用 `DOMAIN.SUBDOMAIN.IDENTIFIER[_SUFFIX]` 全大写下划线分层点记。`DOMAIN` 固定枚举: `UI` / `DIALOGUE` / `TOAST` / `GAMEOVER` / `TUTORIAL` / `CARD`(新 domain 须改本 GDD)。示例: `UI.PAUSE_MENU.RESUME_LABEL` / `TOAST.INPUT.CONTROLLER_DISCONNECTED` / `GAMEOVER.TITLE_IRONY`。**`_IRONY` 后缀**: 凡含 Pillar 4 反讽语义的 key 必须以 `_IRONY` 结尾,作为 CI lint 检测锚点(Rule 11),同时向 translator 发 tone 信号(译文不得改为字面对等词,必须保留反讽)。**禁止**: 跨 domain 复用同一 key、数字序号替代语义名(`UI.BTN_01` 非法)。

2. **`tr(key)` 调用纪律(零硬编码面向玩家文本)**: 所有面向玩家的文本**必须**经 `tr(key)` 或等价 `TranslationServer.translate(key)` 获取,**禁止** zh_CN 字面量硬编码在任何 `.gd` / `.tscn` 文件。唯一豁免: debug 构建(`OS.is_debug_build() == true`)的内部 console 日志字符串,不渲染玩家可见 UI。Input Handler Section G 3 条 toast 文案(`TOAST.INPUT.CONTROLLER_DISCONNECTED` / `TOAST.INPUT.MODIFIER_ONLY_BINDING` / `TOAST.INPUT.CONTROLLER_CAPTURE_CANCELLED`)归本系统 CSV 管辖。

3. **程序化赋值 + RichTextLabel 刷新契约(Godot 4.6 footgun 守门)**: Godot 4.6 自动 `NOTIFICATION_TRANSLATION_CHANGED` 仅覆盖 Inspector 绑定 key 的 `Label.text`;**程序化赋值**(`label.text = tr("KEY")` via script)和 **`RichTextLabel`** 不自动刷新。两类处理: (a) 普通 Label 程序化赋值: 拥有方必须实现 `_notification(what)` 并在 `what == NOTIFICATION_TRANSLATION_CHANGED` 时重 call `tr(key)` 赋值;(b) **RichTextLabel**: 拥有方在 `_ready` 调 `LocalizationHooks.register_rich_text_refresh(owner_id: StringName, rebuild_callable: Callable)` 注册 rebuild 回调,`_exit_tree` 调 `unregister_rich_text_refresh(owner_id)`。Localization 在 locale switch 同帧对所有已注册 rich text 广播 rebuild(无序约定),owner 的 callable 负责 `clear()` + 重建完整 BBCode 链。**API 类比 Input Handler Rule 6 `register_skippable` 模式,同一 discipline**。

4. **缺 key 双轨策略(dev 显式 / prod 静默回退)**: Dev 构建(`OS.is_debug_build()`): 返回 `[MISSING: KEY_NAME]`,`push_error("ERR_LOCALIZATION: key \"KEY_NAME\" not found in locale \"[locale]\"")`,UI 中 `[MISSING:]` 前缀可视,QA 一眼识别。Prod 构建: fallback 链回退 —— 当前 locale → `zh_CN`(基准) → key name 本身(兜底),不崩溃不阻塞。fallback 链 MVP 仅 2 层;野心版 en 上线后改为 `en → zh_CN → key_name`,修改本 Rule + 同步 ADR。

5. **Locale 切换运行时协议(dispatch ≤1 帧 + reflow ≤30 帧;演出中排队)**: `set_locale(locale: StringName)` 调用流: (a) Localization 检查演出 lock(见 d);若 lock 住,request 排队;(b) `TranslationServer.set_locale(locale)` 同步切换;(c) emit `locale_changed(locale)` 信号(Save 订阅按 Rule 14 / 500 ms 防抖写 meta);(d) Godot 向全 `Control` 广播 `NOTIFICATION_TRANSLATION_CHANGED`,静态 Label 自动刷新 + 已注册 RichTextLabel rebuild 广播 + 程序化 Label 自刷新(均经 Rule 3)。**性能预算**: dispatch(a→c)**≤1 帧**(16.6 ms),端到端可见 reflow **≤500 ms / ~30 帧**。**演出排队**: 当任一 skippable 演出 active(通过 Scene & Day Flow 设置 `locale_switch_locked = true`),Localization 缓存 pending locale;演出结束 / 玩家跳过时由 Scene Flow 调 `flush_pending_locale()` 生效。理由: 避免 Tween 中途 Label 尺寸改变触发 reflow race。**禁止**: `await` 跨帧等待;`_process` / `_input` 内切 locale。

6. **CSV schema(列定义 + 版本锁)**: MVP CSV 路径 `assets/i18n/zh_CN.csv`(野心版新增 `assets/i18n/en.csv`,同 schema)。Godot 4.6 原生 `keys` 格式,列定义顺序锁定:

   | 列 | 类型 | 必填 | 说明 |
   |---|------|------|------|
   | `key` | StringName | 是 | 遵 Rule 1,全局唯一 |
   | `zh_CN` | String | 是 | 基准译文,MVP 发布时不可空 |
   | `en` | String | 否 | 野心版填;**MVP 保留整列留空值**(防野心版上线改 schema 触发 TranslationServer 重载回归) |
   | `context` | String | 是(`_IRONY` key)/ 否(其他) | `_IRONY` key 必须含 `"IRONY: [tone 说明]; 禁: [替换词列表]"`(例: `"IRONY: 表面祝贺实为宣告失败; 禁: 本轮结束 / 晋升失败 / Game Over"`);普通 key 推荐填上下文,非强制 |
   | `max_chars` | Integer | 否 | UI 受限容器字符上限;无限制留空 |

   头行: `key,zh_CN,en,context,max_chars`。**不用 `.po` / Gettext**(Godot 4.6 CSV plural 已覆盖)。**UTF-8 without BOM**(Godot 4.6 兼容但标准实践)。**Duplicate key 检测由 Rule 11 lint 阻塞**(Godot 静默用最后一条,无 editor warning)。

7. **复数策略(zh explicit variants / en CSV plural columns)**: **zh_CN**: 中文无语法复数,数量变化通过显式 key variant: `UI.CARD_COUNT.ZERO` / `UI.CARD_COUNT.ONE` / `UI.CARD_COUNT.MANY`,值内嵌数字(`"剩余 {count} 张行动卡"`),调用 `tr("UI.CARD_COUNT.MANY").format({"count": n})`。**en**(野心版): Godot 4.6 CSV plural columns(CLDR 规范自动选列),具体列格式由 ADR 决定,MVP 不预实现。**禁止**: GDScript 内 `if count == 1` 分支绕过 `tr(key)`。

8. **启动全量加载(Loading Scene 内完成,<100 ms parse 上限)**: Scene & Day Flow Controller 初始化序列最早步 `LocalizationHooks.load_translation("res://assets/i18n/zh_CN.csv")` 全量载入(Godot 内部解析为哈希表);同步调 `FontManager.preload_all()` 加载 4 字体(art-bible §7.2 锁定)至内存。此阶段发生在 Splash → Loading Scene,**不计入 5 秒进入窗口**,但 parse + font preload 总耗时 **<100 ms**(CI profiling 断言;超过触发拆分加载或预编译 `.translation` 二进制,由 ADR 决定)。

   **Budget 分解(<100 ms 硬上限,CI blocking)**:

   | Component | Mechanism | MVP Budget | CI Assertion |
   |---|---|---|---|
   | CSV read(50 KB zh_CN) | `FileAccess.get_as_bytes` | < 5 ms | smoke check |
   | CSV parse → hash | Godot internal | < 10 ms | smoke check |
   | 4 字体 `ResourceLoader.load`(含 CJK atlas 首次生成) | Godot preload | < 60 ms | smoke check |
   | FontManager init + Theme bind | `_ready` on autoload | < 5 ms | smoke check |
   | Slack | — | ~20 ms | — |
   | **Total** | — | **< 100 ms** | **CI BLOCKING** |

   CJK atlas 生成首次 50-200 ms 是 cold-cache 区间;Rule 8 preload 在 Loading Scene 一次性吸收,后续 locale 切换见近零 atlas 开销(T_atlas = 0,见 F1)。**禁止**: 运行时 `FileAccess.open` 读 CSV、gameplay 帧(`_process` / `_input`)内 CSV I/O、lazy load 任一字体(首帧 CJK atlas 生成 50-200 ms hitch 违反 Pillar 5)。

9. **字体 fallback 链(4 级 + `_IRONY` 绑定 + diegetic Compact variant 合约)**: 

   | 用途 | 字号 | zh_CN 主字体 | en 主字体 | Fallback |
   |------|-----|-------------|-----------|---------|
   | 标题 | 16 px | 方正公文宋 | [ADR 决定 en 衬线替换] | Noto Serif CJK |
   | 正文 / 对话 | 12 px | 思源黑体 Regular | [ADR 决定 en 无衬线替换] | Noto Sans CJK |
   | 数字 / 数值框 | 8 px | 5×7 bitmap 等宽 | 同左 | 无 fallback(bitmap 禁降级) |
   | 系统提示 / Boss 台词 | 14 px | 站酷快乐体 | 站酷快乐体 | 无 fallback |

   **站酷快乐体锁定**: 永远用于 `_IRONY` 后缀 key 渲染的 Label,**不随 locale 切换字体**(en 版若出现也用站酷快乐体,除非 art-bible §7.2 正式修订)。**Diegetic Compact variant 合约(跨 UI 锁定)**: Localization 在全局 Theme 中预定义 `theme_variation = &"Compact"`(`font_size = 11 px`,思源黑体);**所有 diegetic 固定尺寸容器内的 Label 必须**: `autowrap_mode = TextServer.AUTOWRAP_WORD_SMART` + `fit_content = false` + 容器节点 `clip_contents = true` + overflow 时切 `theme_type_variation = &"Compact"`。各 UI GDD(#13/14/15/16)在 Dependencies 显式声明"subscribes to Localization Rule 9 Compact 合约",不重复定义。

   **Overflow escalation order(3 级次序)**: 每条 diegetic 固定容器 Label 按序评估 —— (1) **autowrap within `max_lines`**(container 自身 tuning knob,default `2`);若仍 overflow 被 clipped: (2) 切 **`theme_type_variation = &"Compact"`**(11 px,全局 theme);若仍 overflow: (3) **`label.add_theme_font_size_override("font_size", autofit_size)`**,`autofit_size` 最低 = `AUTO_FIT_FLOOR_PX = 11 px`(art-bible §7.2 **明确禁用 10 px 因 CJK 笔画粘连**,CJK 文本最低合法字号 = 11 px)。**Step 3 与 Step 2 Compact 实际共值**(11 px),等同于"Compact 不够则 clip",与 art-bible 严格一致;Step 3 保留接口供未来 Accessibility LargeText variant 从 >12 px 向下 autofit 降至 11 px 的扩展路径。**步骤 (3) 仅兜底**;zh_CN 触发 = P1 defect(30% 英文膨胀 headroom 保 zh_CN overflow 是 layout bug,非语言预算问题)。

   **禁止**: 散落的 `add_theme_font_size_override("font_size", N)` 未经此三级次序约束(难维护 + 绕过 escalation);`fit_content = true` 于 diegetic 容器(溢出工位格)。

10. **String key 稳定性(禁直接删,走 deprecated 流程)**: 一旦 string key 出现在任何已发布版本(含 beta)CSV,**不可改名**。废弃流程: CSV `context` 列标注 `"DEPRECATED: replaced by [NEW_KEY]"`,`zh_CN` 值改为新 key 的 `tr()` 结果字面复制(非引用);代码迁移新 key 后,旧 key **保留 2 个 milestone**,之后才可删除(标注 `"DELETED: vX.X"`)。**禁止**: 发布后直接删 key(触发 prod fallback 链显示 key name,破坏 tone)。CSV 是 string key 唯一 source of truth,**不建独立 registry 文件**(与 `entities.yaml` 模式不同 —— CSV 自身含 context + max_chars 元数据)。

11. **Tone 守护钩三层执法(`_IRONY` 后缀 + CSV context 必填 + CI lint + writer review gate)**: (a) **Lint 自动层(MVP 就实现)**: `tools/i18n_lint.py`(Python,CI 阻塞 + 可 pre-commit hook)规则 —— `_IRONY` 后缀 key 的 `context` 列必须含 `"IRONY:"` 字符串(缺失 = CI FAIL);CSV duplicate key 检测(Godot 静默覆盖,Rule 6 依赖本 lint 兜底);`.tscn` Inspector 硬编码 zh_CN 字面量检测(正则扫描);`.gd` 文件 `label.text = "..."` 非 `tr()` 赋值检测;orphan key 检测(CSV 中存在但无 `.gd` / `.tscn` 引用);dev 构建 `[MISSING: IRONY_KEY]` 为 P0 blocking。 (b) **Translator 人工层**: 每条 `_IRONY` key 的 `context` 列必须含 tone 说明 + 禁用替换词列表。(c) **Review gate 流程层**: `_IRONY` key 译文变更需 writer sign-off,**禁止** localization reviewer 单方面通过。MVP 既有 `_IRONY` key(单条): `GAMEOVER.TITLE_IRONY`,值 `"恭喜晋升"`,字体站酷快乐体 14 px(art-bible §7.2 反讽钩锁定点)。

### States and Transitions

**无状态机需要**。理由: Localization Hooks 是无状态查询层 —— `tr(key)` 是幂等函数(同 key 同 locale 恒返相同字符串,不依赖历史状态)。locale 切换是一次性 assignment,切换后即刻就绪,无中间态需守护。Rule 5 的"演出中排队"由 Scene & Day Flow Controller 的演出 state 管控(`locale_switch_locked` flag),不属本系统状态机职责。启动期"CSV 尚未就绪"由 Scene & Day Flow 初始化序列 gate,Loading Scene 完成前不展示任何 UI。

与 Input Handler(3 状态:NORMAL / MODAL_LOCKED / REMAP_CAPTURE)的对比: Input 有"等待玩家输入绑定"的异步窗口需状态隔离,Localization 没有对应结构 —— 所有操作同帧完成(查询 / 切换 / 信号 dispatch),无异步等待态。

### Interactions with Other Systems

> **Save System (#1)** ↔ Localization Hooks
> **流入** (#1 → Localization): 启动期由 Scene & Day Flow Controller 协调,从 Save 读 `meta.save.settings.locale`(默认 `zh_CN`)并调 `LocalizationHooks.set_locale(locale)` 注入。Localization 不直接读 Save 文件
> **流出** (Localization → #1 via signal): `locale_changed(locale: StringName)` 信号;Save 订阅按 Save Rule 14 走 500 ms 防抖 meta 写
> **所有权**: Save owns `meta.save` 持久化(ADR-0001 决定);Localization owns 运行时 locale 状态 + TranslationServer 调用
> **关键约束**: Localization **绝不直调** `SaveSystem.write_*` API、**绝不开** `FileAccess` / `ConfigFile`(Save Rule 20 承约)。依赖方向严格: Localization → signal → Save

> **Input Handler (#2)** ↔ Localization Hooks
> **流入** (#2 → Localization): 通过 `tr(key)` 消费 Section G 3 条 toast 文案(`TOAST.INPUT.CONTROLLER_DISCONNECTED` / `TOAST.INPUT.MODIFIER_ONLY_BINDING` / `TOAST.INPUT.CONTROLLER_CAPTURE_CANCELLED`);Input 无 setter,仅读
> **流出** (Input → Localization via 按键名注入): Remap UI / 玩家提示字符串(如 `"按 %s 跳过"`)用 CSV `%s` 占位符,按键 display name 由 Input Handler `get_display_name(action_name)` 运行时注入(Rule 2 + Rule 11);字形混排依赖 Godot TextServer Unicode script detection(思源黑体含 Latin subset,正确渲染 `"Enter"` 无需手动字体切换)
> **所有权**: Input owns action → display name 映射;Localization owns 模板字符串 + 占位符约定
> **时机**: Input action 变更时由 UI 拥有方手动 re-format(Input 不主动通知 Localization)
> **禁止**: CSV 字符串中硬编码 `"Enter"` / `"A 键"` 等平台相关字符串;所有按键名必须 `%s` 占位符注入

> **Scene & Day Flow Controller (#6)** ↔ Localization Hooks
> **流入** (#6 → Localization): 启动期调度 `LocalizationHooks.load_translation` + `FontManager.preload_all`;演出期间 set/clear `locale_switch_locked` flag(Rule 5 排队机制);演出结束调 `LocalizationHooks.flush_pending_locale()`
> **流出** (Localization → #6): `locale_changed(locale)` 信号(#6 选择性订阅用于演出逻辑,非强制)
> **所有权**: Scene Flow owns 启动序列 + 演出 lock 决策;Localization owns locale 状态 + pending queue
> **时机**: Loading Scene 内完成加载(<100 ms);演出期排队请求;演出结束同帧 flush

> **Main Menu / Pause / Settings UI (#17)** ↔ Localization Hooks
> **流入** (#17 → Localization): `set_locale(locale)` 接口(玩家在设置屏切换语言触发);`get_available_locales() -> Array[StringName]` 读可选项(MVP 返 `[&"zh_CN"]`,野心版返 `[&"zh_CN", &"en"]`);`get_current_locale() -> StringName` 读当前
> **流出** (Localization → #17): `locale_changed(locale)` 信号(#17 用于刷新设置屏本身的 Label + 通知玩家"已切换" toast;toast 内容经本系统 `TOAST.LOCALE.SWITCHED` key)
> **所有权**: #17 owns 语言设置 UI 屏 + 切换触发;Localization owns 实际 locale 状态 + TranslationServer 调度
> **时机**: 玩家点"切换" → Localization 检查演出 lock → 若 free 同步切换 + 发信号 → 若 locked 排队等演出结束

> **HUD #13 / Card Play UI #14 / Recap UI #15 / KPI Review UI #16(diegetic UI 订阅)** ↔ Localization Hooks
> **流入** (UI → Localization): RichTextLabel 所有者 `_ready` 调 `register_rich_text_refresh(owner_id, rebuild_callable)`,`_exit_tree` 调 `unregister_rich_text_refresh(owner_id)`(Rule 3);diegetic Label 节点订阅 Rule 9 Compact 合约(`theme_type_variation = &"Compact"` overflow fallback)
> **流出** (Localization → UI): `NOTIFICATION_TRANSLATION_CHANGED` 自动广播(Godot) + 已注册 rich text rebuild 广播(本系统 Rule 3)
> **所有权**: UI owns 自身 Label / RichTextLabel 实例 + rebuild 逻辑 + overflow 样式切换;Localization owns 注册表 + broadcast + Compact theme 定义
> **关键约束**: **每个 diegetic 固定容器 Label 必须** autowrap + 非 fit_content + 容器 clip_contents + overflow 走 Compact variant(Rule 9)。违反 = Pillar 5 reflow 漂移 / 工位格溢出 / Pillar 4 字号过小笔画粘连

> **Tutorial #18 [VS]** + **Accessibility #20 [Alpha]**(预留依赖)
> **流入**: Tutorial 订阅 `tr()` 教学字符串(大量);Accessibility 可能注入 sticky tooltip / 高对比文本模式等(具体接口待 Accessibility GDD 定)
> **所有权**: 两者 GDD 待写,本系统仅声明 `tr()` 接口对其开放;Compact theme variation 可被 Accessibility 扩展(如"大字号" variant 追加)

## Formulas

### Formula 1: Locale Switch Reflow Latency

The **reflow_latency** formula is defined as:

```
reflow_latency(N, N_visible, atlas_swap) =
  T_dispatch
  + (N × k_propagate)
  + (T_atlas × atlas_swap)
  + (N_visible × k_layout)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| Dispatch base cost | `T_dispatch` | float (ms) | [0, 2] | `TranslationServer.set_locale()` + signal emit;常量,独立于 node count |
| Total Control node count | `N` | int | [0, 500] | active scene tree 中接收 `NOTIFICATION_TRANSLATION_CHANGED` 的 Control 总数 |
| Propagation coefficient | `k_propagate` | float (ms/node) | [0.005, 0.01] | 线性 propagation 耗时/节点;由 ui-programmer 实测"<1 ms at N=150" bound 推算 |
| Atlas swap flag | `atlas_swap` | bool | {0, 1} | 1 若 locale 切换需换字体 atlas(zh_CN → en 的 Latin atlas);同脚本切换 = 0 |
| Atlas load cost | `T_atlas` | float (ms) | [0, 200] | `atlas_swap=1` 时字体 atlas 加载耗时;Rule 8 预加载完成后为 0(MVP 仅 zh_CN 为 0) |
| Visible Label count | `N_visible` | int | [0, N] | 屏上可见需 reflow layout 的 Label 数(Godot dirty-rect 把 off-screen 节点 defer) |
| Layout coefficient | `k_layout` | float (ms/label) | [1.0, 3.0] | 单 Label TextServer layout + glyph shaping 耗时;CJK 12px 正文 conservative ceiling |
| Total reflow latency | `reflow_latency` | float (ms) | [0, 500] | 端到端 locale 切换耗时;**硬上限 500 ms**(Rule 5) |

**Defaults:** `T_dispatch = 1 ms`, `k_propagate = 0.007 ms/node`, `T_atlas = 150 ms`(野心版 en atlas 冷加载,MVP = 0), `k_layout = 2.5 ms/label`

**Justification:**
- `k_propagate = 0.007`: ui-programmer 实测 N=150 时 < 1 ms,0.007 × 150 = 1.05 ms 留 5% headroom。MVP HUD + Card Play 预估 80-200 Control nodes,覆盖内。
- `k_layout = 2.5`: conservative ceiling。TextServer CJK 12px layout in isolation 基准 < 1 ms/label,2.5 ms 吸纳 cache pressure at scale(同帧多 label 触发 atlas cache miss)。
- `T_atlas = 0 in MVP` 因 Rule 8 预加载全字体;野心版 en 若需独立 Latin atlas 则 150 ms(ui-programmer "CJK atlas 50-200ms" 区间取中值偏高)。
- 500 ms 上限源自 Rule 5,超过 = CI FAIL(非 design clamp)。

**Output Range:** [0, ∞) 构造性非负;设计上钳为 ≤ 500 ms(Rule 5),超过触发 CI assertion。

**Worked Example(MVP zh_CN,Settings 屏 locale "切换" 实为 no-op — 仅 zh_CN 可选)**:
- N = 120(HUD 运行中),N_visible = 40,atlas_swap = 0
- T_dispatch = 1 ms,T_propagate = 120 × 0.007 = 0.84 ms,T_atlas = 0,T_layout = 40 × 2.5 = 100 ms
- **reflow_latency = 1 + 0.84 + 0 + 100 ≈ 102 ms**(远低 500 ms)

**Worked Example(野心版 zh_CN → en,含 atlas swap)**:
- N = 180,N_visible = 60,atlas_swap = 1,T_atlas = 150 ms
- reflow_latency = 1 + 1.26 + 150 + 150 = **302 ms**(内含 500 ms 上限,CI 通过)

**Design signal(反推约束):** 可见 Label 上限由公式解得 ——
`N_visible_ceiling = floor((500 - T_dispatch - k_propagate × N_max - T_atlas_max) / k_layout) = floor((500 - 2 - 3.5 - 200) / 2.5) = 117 labels`。
**超过即 P2 defect**:UI 设计需拆分或引入分页,不应出现 > 117 labels 同屏 reflow。该上限进 Tuning Knobs 为 `MAX_VISIBLE_REFLOWING_LABELS = 117`。

---

### Formula 2: Translation Coverage Ratio

The **coverage** formula is defined as:

```
coverage(locale) = translated_keys(locale) / total_keys_required(locale)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| Translated key count | `translated_keys(locale)` | int | [0, total_keys] | CSV 中 `locale` 列非空且通过 `_IRONY` context lint 的 row 数 |
| Required key count | `total_keys_required(locale)` | int | [1, ∞) | 该 locale 发布所需 key 数。**MVP zh_CN**: 全部 rows(基准 locale);**野心版 en**: 排除尚待 writer sign-off 的 `_IRONY` keys |
| Coverage ratio | `coverage(locale)` | float | [0.0, 1.0] | 该 locale 翻译完成率,CI/QA gate 用 |

**Defaults:** `COVERAGE_ALPHA_GATE = 0.85`,`COVERAGE_SHIP_GATE = 1.0`(在 Tuning Knobs 登记)

**Justification:**
- `COVERAGE_ALPHA_GATE = 0.85`: 野心版 en 可在 Alpha build 启用的阈值 —— 15% 未翻译上限符合 industry norm(missing key 经 Rule 4 fallback 到 zh_CN 仍可读)。
- `COVERAGE_SHIP_GATE = 1.0`: Release branch 硬阻塞 —— 上线 locale 必须 100% coverage。Missing 到 zh_CN fallback 在 prod build 是 bug 不是 feature(破坏"这游戏说人话" Player Fantasy 承诺)。
- MVP zh_CN 上线时 `coverage(zh_CN) = 1.0` 是 Release gate 前置条件(无 fallback 源可用)。

**Output Range:** [0.0, 1.0] 钳位(分子 ≤ 分母构造性保障)。

**Worked Example(MVP zh_CN Release gate)**:
- total_keys_required(zh_CN) = 500,translated_keys(zh_CN) = 500(MVP zh_CN 基准,全 row 必须有 `zh_CN` 值)
- coverage(zh_CN) = 500 / 500 = **1.0** → pass `COVERAGE_SHIP_GATE`,允许 Release

**Worked Example(野心版 en Alpha gate)**:
- total_keys_required(en) = 280(500 总 - 220 `_IRONY` key 尚待 writer sign-off)
- translated_keys(en) = 244(en 列非空且 pass lint)
- coverage(en) = 244 / 280 ≈ **0.871** → above `COVERAGE_ALPHA_GATE`(0.85)→ en 纳入 Alpha build

**CI 集成:** `tools/i18n_lint.py`(Rule 11)输出 `coverage(locale)` 值;Alpha branch `coverage < 0.85` → exclude locale from build;Release branch `coverage < 1.0` → CI FAIL。

## Edge Cases

43 edges 分 10 分类,**5 [RISK GUARD]** 对齐 Input Handler R1/R2/R3 守门结构(Pillar 5 / Pillar 4 高风险路径),须在首个可测 build 优先验证(Section H AC 优先级继承)。5 新 OQ [OQ-LOC-01..05] 原文标记,归入 Open Questions 合总。

### 1. Boundary Values

- **If `AUTO_FIT_FLOOR_PX = 11 px` and the text still overflows at that size**: escalation sequence halts at step (3),容器 `clip_contents = true` 剪裁余下文本。P1 defect —— layout 拥有方必须修容器 / 缩字符串,不可降 floor(art-bible §7.2 **明确禁用 10 px 因 CJK 笔画粘连**,11 px 是 CJK 文本绝对下限;Step 3 与 Step 2 Compact 同为 11 px,实质为"Compact 不够则 clip")。Tuning guard: `<11` load 期 clamp 到 11 + DEBUG log。
- **If `MAX_VISIBLE_REFLOWING_LABELS = 117` is exactly met (N_visible = 117)**: F1 at N=500 → `1 + 3.5 + 0 + 292.5 = 297 ms`,远低 500 ms,安全。N_visible = 118 = P2 defect(Rule 5);runtime 不 crash 但 CI profiling 下次跑断言即触发,UI 设计需重构,不能 patch。
- **If F1 is evaluated at N = 0 and N_visible = 0**: `reflow_latency = 1 ms`。合法输出 —— 对应空 scene(Loading Scene UI 未实例化前)locale 切换。无节点接收广播,正确非错。
- **If F1 evaluated with `atlas_swap = 1` AND `T_atlas = 0`**(MVP zh_CN → zh_CN "switch"): `atlas_swap` 逻辑上仅当换字体家族为 1。MVP 结构性强制为 0。实现须保证 `atlas_swap` 内部由 locale 对导出,**不接受 caller 手传** —— 否则 phantom 150 ms 会造成 CI false fail。
- **If F2 evaluated at `coverage(locale) = 0.0`**(空 zh_CN CSV 或全 row lint 失败): CI FAIL 任何 branch —— zh_CN `coverage < 1.0` 阻 Release。dev sandbox: lint 逐 key 报错;dev build 每 Label 显示 `[MISSING: KEY]`,QA 立刻 triage。
- **If `COVERAGE_SHIP_GATE = 1.0` exactly met but one key has empty `zh_CN` value**(Rule 6 "不可空"违反): F2 分子计为 translated(key 存在即算),但 Rule 11 lint 捕获空值 CI FAIL。F2 与 lint 互补 —— F2 计存在,lint 验内容,两者俱过方可 Release。F2 单独无法辨 `""` 与合法 string。

### 2. String Key Lifecycle

- **If a duplicate key exists in CSV AND lint (`tools/i18n_lint.py`) is bypassed**(pre-commit `--no-verify`): Godot TranslationServer 静默用 last 值(Rule 6)。第一 entry 值被永久 shadow。Resolution: CI 独立运行 lint,不受 pre-commit 绕过影响。`--no-verify` 仅跳 pre-commit,CI gate 不可 bypass —— 含 duplicate key 的 PR 一律 CI block。
- **If an orphan key exists in CSV**(存在但无 `.gd`/`.tscn` 引用): Rule 11 lint 发 WARNING(非 FAIL)dev builds。**不自动 purge** —— orphan purge 需人工 writer review 确认非 dynamic `tr("KEY_" + suffix)` grep-miss。[OQ-LOC-01]
- **If MVP binary loads CSV with a future 野心版 key**(如 `TOAST.LOCALE.SWITCHED` 提前加入 feature branch): key 进 hash 表惰性闲置。无 crash 无警告。Rule 10 key 稳定性反向作用: 该 key 从 CSV 删除反而破坏 live binary(prod build 若引用会触 fallback)—— 未确认全 live binary 都不引用前不得删除。
- **If a deprecated key still referenced** in `.gd` after migration deadline(2 milestone): 继续返回手工拷贝 zh_CN 值(Rule 10),运行时不 break。Lint 标"deprecated key 仍在用" WARNING,Release branch 升级 FAIL。CI FAIL 是执法层,非 runtime guard。
- **If CSV file is entirely absent**(`res://assets/i18n/zh_CN.csv` Loading Scene `load_translation` 时缺): TranslationServer 无数据,每 `tr(key)` 返 key name(Godot 兜底)。dev build 与大面积 `[MISSING]` 无法区分 —— 每 key 首调都 `push_error` 会 log 洪泛。Resolution: **CI asset integrity check 必须验 CSV 存在**,缺失 = CI FAIL。[OQ-LOC-02] **[RISK GUARD — R-LOC-1]**: Pillar 5 5-秒进入承诺下,CSV 缺失直接 block Main Menu 渲染,属 P0 启动门禁。

### 3. RichTextLabel / Label Refresh Races

- **If RichTextLabel owner node is `queue_free()`'d without `unregister_rich_text_refresh`**(类比 Input Edge 5.1): 下次 locale switch 广播时 LocalizationHooks 迭代 registry 调 rebuild Callable。若 callable 持 freed node 引用,GDScript "invalid instance" 错。Resolution: **同 Input guard** —— 调用每 callable 前 `is_instance_valid(owner_node)` 检测,auto-purge 失效条目,继续广播。Owner 仍合约要求 `_exit_tree` 调 unregister,但 guard 防违约 crash。**[RISK GUARD — R-LOC-2]**: 类比 Input R2 skip-leak 守门,register-based API 高风险路径,Section H AC 优先验证。
- **If `register_rich_text_refresh` called twice with same `owner_id`**: 静默 overwrite(第二 callable 替换第一)。映射 Input OQ-INP-02 决策面。Resolution: overwrite + DEBUG warning `"[LocalizationHooks] register_rich_text_refresh: duplicate owner_id '[id]' — overwriting"`。silent reject 迫使 caller 显式 unregister,增开销无安全收益。[OQ-LOC-03]
- **If locale switch broadcast fires while registered RichTextLabel's rebuild callable is mid-`clear()`**(re-entrant dispatch —— rebuild callable 自身触信号引第二 `set_locale`): 第二 `set_locale` 查 `locale_switch_locked`(Rule 5)。若 Scene Flow 未 set lock: 若演出 active 排队,非则立即处理。**防单广播循环内 re-entrancy**: LocalizationHooks 设内部 `_broadcast_active` flag,rebuild dispatch 期间 true;期间 `set_locale` 无论演出 state 一律入队。[OQ-LOC-03]
- **If RichTextLabel rebuild callable throws runtime error**(如 callable 期望的子节点已 freed): LocalizationHooks 必 catch(`push_error` + 继续下 entry)。广播不 abort —— 剩余 callables 仍跑。**不可静默吞** —— error log `"[LocalizationHooks] rebuild callable error for owner_id '[id]': [error]"`(ERROR 级,QA 可见)。

### 4. Locale Switch Race Conditions

- **If `set_locale(current_locale)` called with locale already active**(no-op case,MVP zh_CN-only 恒 no-op): LocalizationHooks 调 `TranslationServer.get_locale() == locale` 预检。相等 —— 不调 `set_locale`,不发 `locale_changed`,不触 reflow。Rationale: no-op 上发信号会触全量 reflow + spurious Save debounce 写,两者浪费 + QA log 混淆。[OQ-LOC-04]
- **If two `set_locale` calls arrive same frame**(玩家双击语言选择器): 第二次覆盖第一次。Rule 5 要求同步,第一调完毕第二调开始。第二调见新 locale,触同帧第二次全量 reflow。总耗 ~2× F1 ——MVP N_visible ≤ 60 下 ~200 ms,仍内 500 ms。Guard: Settings UI #17 debounce 语言选择器(推荐 300 ms,归 #17 不归本系统)。[OQ-LOC-04]
- **If locale switch requested during `load_translation` execution**(Scene Flow 在 CSV parse 未完时调 `set_locale`): 设计序列不允许 —— `load_translation` 在 Loading Scene 同步完成于任何 UI / settings 可用之前。若 future refactor 使加载 async,此 edge 成真 race。Document as architectural constraint: `load_translation` 须保持同步,异步 refactor 触发本 edge 重评 + ADR。
- **If a scene instantiated immediately after `set_locale`** 同帧: 新 scene 的 `_ready` 在广播已对 pre-existing 节点发出之后。新 scene **不接收**本次广播。Resolution: 每 scene `_ready` 调 `tr(key)` 初始化自己 Label —— 正确模式(非依赖错过的广播)。godot-specialist 标 "UNVERIFIED —— 需确认 Godot 4.6 节点实例化序与 `NOTIFICATION_TRANSLATION_CHANGED` 广播相对顺"。[OQ-LOC-05]
- **If `flush_pending_locale()` called while演出 lock still active**(Scene Flow 时序错,解锁前 flush): LocalizationHooks 必 flush 时查 `locale_switch_locked`。仍锁: log ERROR + 不应用 pending locale。Scene Flow 合约违反;Scene Flow GDD 须 document `flush_pending_locale` 仅在 lock clear 后有效。
- **If 演出 never ends**(bug —— indefinite lock),pending locale 无限累积: Rule 5 未定 timeout。Resolution: **watchdog** —— `locale_switch_locked = true` 持续超 `LOCALE_LOCK_WATCHDOG_MS = 30000 ms`(30 s)触 `push_error` + 强制 flush pending。30 s 超任何 plausible 演出时长但捕 genuine lock leak。[OQ-LOC-04] **[RISK GUARD — R-LOC-3]**: Pillar 5 地铁可玩性下,locale 切换 indefinitely block = 玩家永远切不了语言,Section H AC 需压测 watchdog trigger。

### 5. Fallback Chain Edge

- **If `zh_CN.csv` is entirely missing in dev build**(根 locale 缺): TranslationServer 返 key name(Godot 兜底)。dev build: `push_error` 每 `tr()` 调(Rule 4 dev 行为)。**此路径不被 Rule 4 `[MISSING: KEY]` 覆盖** —— 该路径要求 TranslationServer 有数据但缺具体 key。CSV 缺失 = TranslationServer 完全无翻译,静默返 key name,不触 dev-mode error hook。Resolution: Rule 4 须补 —— 启动时查 `TranslationServer.get_loaded_locales()`,`zh_CN` 缺即刻 `push_error`。[OQ-LOC-02]
- **If `[MISSING: KEY_NAME]` renders inside RichTextLabel that parses BBCode**: 括号 `[` 被 BBCode parser 当 tag 起始。Parser 试解 `MISSING: KEY_NAME` 为 tag 名,失败静默,渲染空或部分字符串。Resolution: dev build fallback 字符串须 BBCode 转义 —— `"[MISSING\\: KEY_NAME]"` 或走 `add_text()`(plain)非 `append_text()`(BBCode)。Rebuild callable 拥有方负责选对插入法。Document 为 Rule 3 RichTextLabel rebuild 约束。
- **If a `_IRONY` key exists in zh_CN CSV but its `context` column is missing `"IRONY:"` substring**: Rule 11 lint CI FAIL 阻 build,key 不抵 runtime。CI-compliant build 下 runtime 行为 moot。lint-bypassed dev build(pre-commit skipped): `tr()` 正常返 zh_CN 值;missing context 是数据 defect 非 runtime defect。站酷快乐体字体绑定依 key 后缀,非依 context 存在 —— 字体仍正确。丢失仅 translator tone 信号 —— Pillar 4 defect 而非 crash。**[RISK GUARD — R-LOC-4]**: Pillar 4 tone 守护铁则,lint 绕过即 Pillar 4 失守,Section H AC 须覆盖 pre-commit / CI 双路径。

### 6. Font Atlas / FontManager

- **If `FontManager.preload_all()` runs OOM**(RAM/VRAM 上限 hit): Godot 抛 resource load error。Resolution: Rule 8 budget 估 4 字体 MVP ~22 MB,远低 500 MB 上限。MVP preload OOM 非 realistic。若 event CG 字体(128 px)野心版加入,须 budget 重估 + 潜在 lazy-load 策略,触 ADR 修订。
- **If a font file is missing at runtime**(用户损坏 / 安装失败): `ResourceLoader.load` 返 `null`。`FontManager.preload_all()` 须查每 load 结果,`null` 则 `push_error` 附缺失路径。Resolution: fallback 到 Rule 9 链下一字体。8 px bitmap 字体 Rule 9 "无 fallback" —— 缺失则数字渲引擎默认(built-in pixel)。P2 defect 需 QA sign-off,非 crash。
- **If 思源黑体 used in label with mixed CJK + Latin**(如 `"按 Enter 继续"`): 思源黑体含 Latin subset(Section C Interactions "`Enter` 无需手动字体切换")。无特殊处理。**Edge**: 若 Latin 字符在 subset 之外(emoji / CJK Compatibility Extension 未在 atlas): Godot TextServer 试 Theme 字体栈 fallback。全栈皆缺 glyph,渲 tofu 框(□)。内容 authoring defect —— 此类字符不得出现于已本地化字符串未验证 glyph 覆盖。Lint Rule 11 当前不能检 missing glyphs —— 此为 gap。[OQ-LOC-05]
- **If Compact theme variant is absent from global Theme**(asset pipeline refactor stripped): Rule 9 Compact variant 查返 base theme at font_size。Overflow escalation step (2) 静默降级跳 (3) —— diegetic label 从 base 跳 `autofit_size` 无 11 px 中间步。P2 defect: text 可读但 Rule 9 3-step escalation 假设破坏。Resolution: CI asset validation 须验 `theme.get_type_list()` 含 `"Compact"` variation。[OQ-LOC-05]

### 7. Performance / Pillar 5 Pressure

- **If N = 500 Control nodes receive `NOTIFICATION_TRANSLATION_CHANGED` simultaneously**(game-concept 上限): F1 propagation `500 × 0.007 = 3.5 ms`。N_visible = 60 realistic HUD 态: `reflow_latency = 1 + 3.5 + 0 + 150 = 154.5 ms`。低 500 ms —— Pillar 5 安全。无纠正;CI profiling smoke check 验证。
- **If N_visible = 150 at locale switch**(超 `MAX_VISIBLE_REFLOWING_LABELS = 117`): F1 at N=500 → `1 + 3.5 + 0 + 375 = 379.5 ms`,仍低 500 ms。117 是**设计警告阈值**(P2 defect UI 须重构)非硬 runtime fail。N_visible = 193: `1 + 3.5 + 0 + 482.5 = 487 ms` —— 危近。N_visible = 200: `504.5 ms` CI FAIL。Runtime 慢 reflow 无 crash;CI profiling 断言执法。
- **If 1000-key CSV parsed**(MVP 500 一倍): Rule 8 CI budget 10 ms parse。线性 scaling 约 20 ms —— 超 budget。CI smoke check 下次跑捕。Resolution: 预编译 `.translation` binary(Godot 内置)或按 domain 拆 CSV。Rule 8 脚注延 ADR 决定。[OQ-LOC-02]

### 8. CSV Encoding / Format

- **If CSV has UTF-8 BOM**: Godot 4.6 handles BOM in text read 但 Rule 6 标"UTF-8 without BOM"。BOM-prefixed CSV 首 key 列解 `"﻿key"` —— BOM 字符前缀 header。header 坏,所有 row 列位错读。Resolution: lint Rule 11 须验 CSV 首 3 bytes 非 `0xEF 0xBB 0xBF`。authoring 工具须导 BOM-free UTF-8。[OQ-LOC-02]
- **If non-UTF8 CSV supplied**(如 GBK legacy export): Godot `FileAccess` 按字节读;GBK multi-byte 序列当 UTF-8 解产生 mojibake 或 parse 错。TranslationServer 可能静默加载 corrupt 字符串。Resolution: lint 须验 UTF-8 编码,非 UTF-8 序 = CI FAIL。
- **If CSV value contains unescaped comma**(如 `他说,别加班`): Godot CSV parser 未引号 comma 当列分隔符。值须引号: `"他说,别加班"`。未引号 comma 静默分割字符串,后续列位全错。Rule 6 须显式 RFC 4180 quoted。Lint 须验每 row 列数。[OQ-LOC-02]
- **If CSV value contains newline**(多行对白): RFC 4180 允许引号字段内 newline。Godot CSV parser 支持。无特殊处理 —— 值含 newline 正确加载。但 `max_chars` 须含 newline 计为 1 字符。Rule 6 注为 supported but `max_chars` 须 writer 重算。
- **If key name contains emoji**(`GAMEOVER.😊_IRONY` —— Rule 1 UPPER_SNAKE_CASE 违反): `tr("GAMEOVER.😊_IRONY")` 合法 GDScript 字符串调,key 存则正常 resolve。实际 failure: lint Rule 11 regex —— `_IRONY` 后缀 + key naming convention 须 flag emoji 为 CI FAIL。Runtime 不 fail 但 grep-ability / string const 安全 / 跨平台 filename 兼容性(若 key 用作 identifier)全破。Rule 1 lint 须显式禁 non-ASCII。

### 9. Cross-System Edges

- **If Save write fails during locale switch persistence**(disk full / Steam Cloud quota 在 500 ms debounce 窗): LocalizationHooks 发 `locale_changed(locale)`,**无可见 Save 写入结果** —— 架构约束(Localization → signal → Save,无直调)。Save Rule 20 error handling own 写入 failure path。Locale switch 自身已在 TranslationServer 完成。Runtime / persisted 分歧: 下 session 加载旧 locale。可接受 —— 单 locale 偏好丢失非数据关键。Save Error handling GDD 须 document 分歧 case。
- **If locale switch occurs while Input in `REMAP_CAPTURE` state**: locale switch 正常走 —— Rule 5 无 `REMAP_CAPTURE` guard。Remap UI toast 字符串(`TOAST.INPUT.CONTROLLER_CAPTURE_CANCELLED` 等)是 `tr()` key 渲染时 resolve。locale mid-capture 改变,下次渲用新 locale。无 re-entrant 风险。Remap 进行中 capture 未断 —— locale 变不取消 remap。正确行为: locale 变 + 按键捕获正交操作。
- **If `NOTIFICATION_WM_WINDOW_FOCUS_OUT` arrives during locale switch broadcast**: Input Rule 9(Edge 9.1)此通知触 `Input.reset_all_action_presses()`。Localization 广播主线程;WM_WINDOW_FOCUS_OUT 亦主线程。Godot 按序处理 —— locale 广播同步(`set_locale` 内),focus-out 排队 locale 广播完毕后处理。无 race。若 broadcast 被 defer(Rule 5 "禁 `await`" 不允许)—— ordering guarantee 破。Document 约束: locale 广播须保持全同步。
- **If game boots with Save containing unknown locale**(野心版 `en-GB` 保存,MVP 加载): `LocalizationHooks.set_locale("en-GB")` 调。TranslationServer 无 en-GB 数据(MVP 仅 zh_CN)。`TranslationServer.set_locale` 可能静默 no-op 或 fall 至 system locale。Resolution: `LocalizationHooks.set_locale` 调前查 `get_available_locales()` 验合法。不可用: fallback `zh_CN` + log WARNING `"[LocalizationHooks] locale 'en-GB' unavailable — falling back to zh_CN"` + 发 `locale_changed(&"zh_CN")` 使 Save 下 debounce 写入更新为修正值。

### 10. Coverage / Lint Edge

- **If `coverage(zh_CN) < 1.0` attempted on Release branch**(部分 zh_CN 值空): CI FAIL,build blocked。Dev sandbox: CI lint 跑但不 block 本地 `godot --headless`。开发者见 dev build 每 `[MISSING:]` 渲染 `push_error`。CI gate 是执法层 —— sandboxed dev work 可暂不完整覆盖,Release branch gate 不可商议(Rule 11 + F2 定义)。
- **If lint detects zero `_IRONY` keys in CSV**(全 `_IRONY` key 被删或从未 authored): `GAMEOVER.TITLE_IRONY` 是 Rule 11 MVP 锁定 key —— 缺失 P0 blocking(art-bible §7.2)。Lint 断言: `count(_IRONY keys) >= 1` AND `GAMEOVER.TITLE_IRONY` 必须存在。缺 `GAMEOVER.TITLE_IRONY` 的 build = CI FAIL 任何 branch。Pillar 4 硬 guard 非 coverage ratio 问题。**[RISK GUARD — R-LOC-5]**: Pillar 4 art-bible §7.2 反讽钩硬锁点,Section H AC 必含"零 `_IRONY` key = FAIL"断言。
- **If lint produces false positive on legitimate non-`tr()` string**(Rule 2 豁免: debug-only console log `.gd`): `.gd` scanner 模式 `label.text = "..."` 仅当模式 match label 赋值语法时 flag,非全字符串字面量。regex 须针对 `\.text\s*=\s*"[^"]*"` 赋值,非全 string literals。但 `label.text = "debug string"` 在 `if OS.is_debug_build()` 守护下是 Rule 2 合法豁免。Lint 须支持 `# i18n-ignore` 行内 comment suppressor —— suppressor 自身 log WARNING 防静默滥用。

## Dependencies

### Upstream Dependencies(本系统依赖)

**None structurally.** Localization Hooks 是 Foundation Layer 根节点,仅依赖 Godot 4.6 引擎 API(`TranslationServer` / `tr()` / `NOTIFICATION_TRANSLATION_CHANGED` / `Control` / `Label` / `RichTextLabel` / `FontFile`)和 art-bible §7.2 锁定的字体层级 + §7.4 UI 动画 feel 约束。

**软依赖**(不阻 Localization 核心功能但提供必要数据流):
- **Save System #1**(bidirectional via Rule 14 signal): Localization 启动时由 Scene & Day Flow 调度从 Save 读 locale 偏好 → Localization 运行时 emit `locale_changed` → Save 订阅按 Rule 14 写入。无 Save,Localization 仍可运行(每 session 重置为默认 `zh_CN`)。非对等 runtime dependency,是 cross-session preference 持久化依赖。
- **Input Handler #2**(via display name injection): Localization 负责模板字符串(`"按 %s 跳过"`),Input 运行时注入按键 display name。无 Input 静态文本仍正常,动态按键提示降级为空占位符。

### Downstream Dependents(依赖本系统的)

| # | System | Tier | Type | Interface(摘要) | 反向文档 | 必要 |
|---|--------|------|------|--------------------|---------|------|
| 1 | **Save System** | MVP / Foundation | **Hard** | `locale_changed(locale)` 信号 → Save 防抖写 meta;启动期 Save 提供 `meta.save.settings.locale` payload 注入 | ✅ Save Rule 14 显式包含设置类 meta 路径(gamepad 布局 / 音量 / **locale** / 叙事密度) | ✅ 必须 |
| 2 | **Input Handler** | MVP / Foundation | **Hard** | 消费 3 条 `TOAST.INPUT.*` keys(Input Section G);Input 提供 `get_display_name(action_name)` 供 `%s` 模板注入;Localization 不接管按键名本地化 | ✅ Input Section G 显式标"归 Localization Hooks #3 管" + "按键名由 Input Handler 注入 platform display name" | ✅ 必须 |
| 6 | **Scene & Day Flow Controller ⭐** | MVP / Core | **Hard** | 启动序列调度 `LocalizationHooks.load_translation("res://assets/i18n/zh_CN.csv")` + `FontManager.preload_all()`(Rule 8);演出期 set/clear `locale_switch_locked` flag;演出结束调 `flush_pending_locale()`;选择性订阅 `locale_changed` | 未设计 — #6 GDD 须列入 Localization 启动序列 + `locale_switch_locked` 命名契约 + watchdog 30 s 触发行为 | ✅ 必须 |
| 13 | **HUD System (Diegetic)** | MVP / Presentation | Soft | 所有可见文本经 `tr(key)`;便利贴桌面 / 情绪板 RichTextLabel owner 须 `register_rich_text_refresh`;**Compact variant overflow 合约(Rule 9)** | 未设计 — #13 GDD 须列入 Localization + 锁 `register_rich_text_refresh` API 调用 + Compact 3 级 escalation 订阅 | ✅ MVP 必须 |
| 14 | **Card Play & Dialogue UI** | MVP / Presentation | Soft | 同 #13 + 大量 NPC 对白 key(`DIALOGUE.*` domain)+ 行动卡文案 key(`CARD.*` domain,30-40 张卡) | 未设计 | ✅ MVP 必须 |
| 15 | **Daily / Weekly Recap UI** | MVP / Presentation | Soft | 同 #13 + 数值模板 key(如 `"本周 KPI: {value}"`)+ skippable 演出 locale-switch 排队(Rule 5) | 未设计 | ✅ MVP 必须 |
| 16 | **KPI Review & Game Over UI** | MVP / Presentation | Soft | 同 #13 + **`GAMEOVER.TITLE_IRONY`** 反讽锚点(art-bible §7.2 硬锁)+ 站酷快乐体字体绑定(Rule 9 锁站酷快乐体永不随 locale 切换字体)+ 离职证明 transition skip(跨系统见 Input Section F) | 未设计 — **#16 GDD 必含 `GAMEOVER.TITLE_IRONY` 实现守门 + Pillar 4 反讽 tone 验证** | ✅ MVP 必须 |
| 17 | **Main Menu / Pause / Settings UI** | MVP / Presentation | **Hard** | `set_locale(locale)` / `get_available_locales() -> Array[StringName]` / `get_current_locale() -> StringName` 接口;`locale_changed` 信号订阅刷新 UI + 显示"已切换" toast(经 `TOAST.LOCALE.SWITCHED` key);**UI 须 300 ms debounce** 防 Edge 4.2 same-frame double-tap race | 未设计 — #17 GDD 须列入 Localization 语言设置屏 + Remap UI 字符串归属 + 300 ms debounce | ✅ 必须 |
| 18 | **Tutorial / Onboarding** | VS / Feature | Soft | 大量 `tr()` 教学字符串(`TUTORIAL.*` domain) | 未设计(VS 推迟) | 可推迟 VS |
| 20 | **Accessibility Options** | Alpha / Polish | Soft | Compact variant 可扩展为 `"LargeText"` variant;sticky tooltip 经 `tr()`;高对比文本模式可能触发额外 theme variation | 未设计(Alpha 推迟) | 可推迟 Alpha |

### 双向一致性核对(coding-standards 强制规则)

**已 Approved 的 GDD 反向一致性**:
- **Save System (#1)** ✓ — Save Rule 14 显式含设置类 meta 路径("语言 / gamepad 布局 / 音量 / 叙事密度"),bidirectional consistent via registry `meta_settings_debounce_ms`
- **Input Handler (#2)** ✓ — Input Section G 3 条 localizable strings 显式标"归 Localization Hooks #3 管";Input Section F 列入 Localization Hooks 作 dependency 并列 `input_method_changed` 等接口

**未设计的 7 个下游 GDD,编写时各自必须**:
1. 自身 Dependencies 章节列入 **"Localization Hooks (#3)"** 作为 dependency
2. 引用本 GDD **Rule 1** key naming convention(`DOMAIN.SUBDOMAIN.IDENTIFIER[_IRONY]`)
3. 引用本 GDD **Rule 2** `tr()` 纪律 —— 零硬编码 zh_CN 字面量于 `.tscn` Inspector / `.gd` 赋值
4. 引用本 GDD **Rule 3** `register_rich_text_refresh` / `unregister_rich_text_refresh` 合约(若用 RichTextLabel)
5. 引用本 GDD **Rule 9** Compact variant 合约(若为 diegetic 固定尺寸容器 Label)
6. **#16 KPI Review & Game Over UI** 须实现 `GAMEOVER.TITLE_IRONY` 站酷快乐体锁定 + Pillar 4 反讽验证(art-bible §7.2 硬锚)
7. **#17 Main Menu** 须实现语言设置屏 + 300 ms 选择器 debounce(防 Edge 4.2 same-frame double-tap race)
8. 凡涉及复数(`X 张卡`)的 UI(#14/15/16)必须用 Rule 7 explicit variants(`UI.CARD_COUNT.ZERO/ONE/MANY`),禁 GDScript `if count == 1` 分支

### 跨 GDD 影响清单(若本 GDD 后续 revise,以下系统须重审)

- **Save System #1** — `meta.save.settings.locale` schema 变更 → 影响 meta.save schema_version(Save `current_schema_version` registry 须 bump)
- **Input Handler #2** — Section G 3 字符串 key 若改名 → 必走 Rule 10 deprecated 流程(禁直接删),影响 Input Rule 10 hot-plug toast + Edge 3.1 / 4.3 文案
- **Scene & Day Flow #6** — `locale_switch_locked` flag 命名 / `flush_pending_locale` 接口变 → 影响演出序列 + watchdog 阈值
- **Main Menu #17** — Remap + Settings UI 全部 `tr(key)` 引用 + 300 ms debounce 合约
- **HUD #13 / Card #14 / Recap #15 / KPI Review #16** — RichText register API + Compact 3 级 escalation 合约 + 大量字符串 key
- 任何引入"新 domain"(如 `DEBUG.` / `ACHIEVEMENT.` / `TIP.`)—— Rule 1 白名单扩展须先改本 GDD
- Font 层级变更(art-bible §7.2 修订)—— Rule 9 fallback 链 + FontManager 预加载列表同步更新

## Tuning Knobs

### Numeric Knobs(本 GDD 内部 owning)

| Knob | Default | Safe Range | 极端行为 | 来源 |
|------|---------|------------|---------|-------|
| `MAX_VISIBLE_REFLOWING_LABELS` | 117 | [50, 200] | <50: UI 设计过度受限 / >200: 500 ms reflow 预算失守 Pillar 5 漂移 | F1 反推(Section D) |
| `AUTO_FIT_FLOOR_PX` | 11 px | [11, 12] | <11: art-bible §7.2 **明确禁用 10 px 因 CJK 笔画粘连** / >12: 与 Compact(11 px)等值,Step 3 autofit 变空操作 | Rule 9 + art-bible §7.2(art-bible 为 source of truth) |
| `LOCALE_LOCK_WATCHDOG_MS` | 30000 ms | [10000, 120000] | <10000: 合法长演出误触 / >120000: 演出挂死时玩家等两分钟才能切语言 | Rule 5 + Edge 4.6 |
| `max_lines`(per diegetic container) | 2 | [1, 4] | =1: autowrap 降级至 Compact 频率高 / >4: 容器超高 diegetic 布局破坏 | Rule 9 escalation step 1 |
| `COVERAGE_ALPHA_GATE` | 0.85 | [0.70, 0.95] | <0.70: 野心版 en Alpha 太多 missing 污染体验 / >0.95: 野心版 en Alpha 几乎是 Ship-ready 标准过严 | F2 |
| `COVERAGE_SHIP_GATE` | 1.0 | [0.98, 1.0] | <0.98: prod build 含 fallback key 污染 tone / =1.0: 单 key 漏就 block Release(MVP 严格采纳) | F2 |

### Empirical Constants(F1 实测填充,非 designer 调整 — Prototype 阶段可 revise)

| Constant | Default | 来源 | 变更触发 |
|---------|---------|------|---------|
| `T_dispatch` | 1 ms | `TranslationServer.set_locale` + signal emit baseline | MVP 基线 CI profiling;偏离 >50% 触发 OQ |
| `k_propagate` | 0.007 ms/node | ui-programmer "<1 ms at N=150" 推算 | Scene 节点数超 500 时重测 |
| `k_layout` | 2.5 ms/label | CJK 12 px TextServer 基线 ×2.5 conservative ceiling | 字体变更 / Godot 4.x 升级 |
| `T_atlas` | 0 ms(MVP)/ 150 ms(野心版 en)| ui-programmer "CJK atlas 50-200 ms" 中值 | 野心版 Font license 替换时重估 |

### Default Locale Table

| Stage | Default locale | Available locales | Required locales(F2 gate) |
|-------|---------------|-------------------|--------------------------|
| MVP | `zh_CN` | `[zh_CN]` | `zh_CN`(= 100% COVERAGE_SHIP_GATE) |
| 野心版 en 上线 | `zh_CN`(按 OS 默认可改,见 OQ-LOC-07)| `[zh_CN, en]` | `zh_CN`(基准,100%),`en`(>= COVERAGE_ALPHA_GATE 85% for Alpha / 100% for Ship) |

### 跨 GDD Tuning Knob(引用,不 owning)

| Knob | Owner GDD | Value | 与 Localization 关系 |
|------|-----------|-------|---------------------|
| `meta_settings_debounce_ms` | Save (#1) Rule 14 | 500 ms | Localization `locale_changed` 信号触发 Save 防抖窗口;Localization 不知防抖、不可重写 |
| Settings 选择器 debounce | Main Menu (#17)(未设计) | 300 ms(本 GDD 推荐 default)| 防 Edge 4.2 same-frame double-tap race;Localization Rule 5 处理同帧双调但 UI 一侧也须 debounce |

### CSV Schema + Font Hierarchy(引用,非 owning)

- **CSV schema** → Rule 6 完整定义(`key,zh_CN,en,context,max_chars` 5 列,UTF-8 without BOM,RFC 4180 quoted)
- **Font hierarchy** → art-bible §7.2 owns 选型(方正公文宋 / 思源黑体 / 5×7 bitmap / 站酷快乐体),**Rule 9** owns fallback 链 + locale 绑定策略 + 站酷快乐体 `_IRONY` 锁定

### Localizable Strings Catalogue(指向 CSV,非 knob)

所有 MVP 字符串 key 维护在 `assets/i18n/zh_CN.csv`,**本 GDD 不重复列**(Rule 10: CSV 是 key 唯一 source of truth)。以下为 domain 预估分布(启发性 / 产量规划用,非强制契约):

| Domain | MVP 预估 key 数 | 主要拥有方 |
|--------|----------------|----------|
| `UI.*` | ~80 | HUD #13 / Main Menu #17 / Recap #15 / KPI Review #16 |
| `DIALOGUE.*` | ~200-300 | Card Play & Dialogue UI #14 / Event Script Engine #10 |
| `TOAST.*` | ~20 | Input Handler #2(3 条)+ 其他 UI notifications |
| `GAMEOVER.*` | ~10(含 **`TITLE_IRONY`** 反讽锚点)| KPI Review & Game Over UI #16 |
| `TUTORIAL.*` | ~30(VS tier,MVP 推迟)| Tutorial #18 |
| `CARD.*` | ~40(30-40 卡 × 1 key)| Action Card #11 / Card Play UI #14 |

**MVP 总 key 数估算 ~350-500**(TUTORIAL 推 VS),对齐 Rule 8 `< 100 ms parse budget` + godot-specialist "500-string CSV 低 ms 级"实测基线。

### Localizable Strings 示例(Input Section G 已挂 3 条 + 1 art-bible 锚点)

| Key | zh_CN | Context 列 | max_chars | 拥有 UI |
|-----|-------|-----------|-----------|--------|
| `TOAST.INPUT.CONTROLLER_DISCONNECTED` | `"控制器断开 — 按任意键继续"` | "显示于 gamepad 热插拔 toast 期,风格冷静无动画(art-bible §7.4)" | 20 | #6 Scene Flow toast |
| `TOAST.INPUT.MODIFIER_ONLY_BINDING` | `"修饰键不可单独绑定"` | "Remap UI 拒绝单 Ctrl / Shift / Alt 绑定时显示" | 14 | #17 Remap UI |
| `TOAST.INPUT.CONTROLLER_CAPTURE_CANCELLED` | `"控制器断开 — 捕获取消"` | "Remap UI 捕获期手柄全断显示" | 14 | #17 Remap UI |
| `GAMEOVER.TITLE_IRONY` | `"恭喜晋升"` | **"IRONY: 表面祝贺实为宣告失败;禁: 本轮结束 / 晋升失败 / Game Over / You Got Promoted 回译"** | 5 | #16 KPI Review & Game Over UI |

**MVP 发布前本表至少扩至 ~350 条(全 domain 分布上表估算)**。CSV 交付 = Release blocker。

## Visual/Audio Requirements

Localization Hooks 不 own 任何 visual asset 或 audio cue。Pillar 4 黑色幽默 tone 主动反对 locale switch 反馈式 SFX(无"切换成功"音 / 无 UI 点击声 / 无 "已检测到中文" 欢迎语)—— 与 Save / Input Player Fantasy 锁定的同质 tone 参照("不庆祝玩家,也不庆祝自己")。

| 制品 | Owner GDD | 与 Localization 关系 |
|------|-----------|-------------------|
| 字体选型(方正公文宋 / 思源黑体 / 5×7 bitmap / 站酷快乐体) | art-bible §7.2(锁定值) | Rule 9 fallback 链 + locale 绑定策略 + 站酷快乐体 `_IRONY` 锁定 |
| Compact theme variation(`font_size = 11 px`)| Localization(定义 + 合约)+ 各 UI Owner(实现) | AC-ROBUST-05 CI gate + Rule 9 3 级 overflow escalation |
| `[MISSING:]` 字符串样式 | Localization(仅 dev build) | 纯 plain text,无视觉特殊处理(Rule 4 dev 守门) |
| 字体 atlas 加载进度视觉 | Loading Scene(#6 Scene Flow 实现) | Rule 8 preload 在 Loading Scene 内,Localization 不管视觉 |
| 字体 license 审计 | technical-director + art-director | feasibility brief HIGH risk,待 ADR 决定(OQ-LOC-12) |

**零音频要求** —— locale switch 不触任何 audio cue;`[MISSING:]` 不触 error sound。若未来"切换成功" toast 需 SFX,必须先改本 GDD(违反则 Pillar 4 tone 漂移,与 Save / Input 同守)。

## UI Requirements

Localization Hooks 不 own UI 屏。**唯一 UI 接触面**是 Main Menu / Pause / Settings UI(#17)的**语言设置子屏** —— 该屏由 #17 GDD 规划,本 GDD 仅锁数据契约:

- `set_locale(locale)` / `get_available_locales() -> Array[StringName]` / `get_current_locale() -> StringName` 接口由 #17 调用
- `locale_changed(locale)` 信号由 #17 订阅刷新设置屏自身 Label + 显示"已切换" toast
- Toast 内容经 `TOAST.LOCALE.SWITCHED` key(由 Localization CSV 管辖,对齐 Rule 11 tone 守护)
- **300 ms 语言选择器 debounce**(本 GDD 推荐 default,#17 实现)—— 防 Edge 4.2 same-frame double-tap race

**📌 UX Flag — Localization Hooks**: 语言设置 UI 在 Phase 4(Pre-Production)阶段须由 `/ux-design design/ux/settings-screen.md`(配 #17 Main Menu GDD)一并产出 UX 设计稿,包括: 语言选择器 / 切换前确认对话框(可选)/ 切换成功 toast / "需重启"提示(若某些本地化资产需要 reload)/ 字符串预览区(野心版 en 上线后)。stories 引用 UI 时须 cite `design/ux/settings-screen.md`,而非本 GDD。

## Acceptance Criteria

28 条 AC 分 5 类(AC-FUNC 12 / AC-PERF 4 / AC-COMPAT 5 / AC-ROBUST 5 / AC-TONE 3)。**5 [RISK GUARD]** AC(AC-ROBUST-01/02/03 + AC-TONE-02/03)守门 Pillar 5 / Pillar 4 高风险路径,须在首个可测 build 优先验证。AC-TONE 是 Localization 特有 category,映射 Pillar 4 tone 守护(Input Handler 无对应类)。

### AC-FUNC (功能性)

- **AC-FUNC-01** (Rule 1 key 命名约定 — 分层点记法 + domain 白名单): **GIVEN** `tools/i18n_lint.py` 在 `assets/i18n/zh_CN.csv` 上运行, **WHEN** CSV 含一条合法 key `GAMEOVER.TITLE_IRONY`、一条违规 key `UI.BTN_01`(数字序号)、一条违规 key `gameover.title_irony`(小写)、一条跨 domain 复用 key `TOAST.UI.RESUME_LABEL`(非合法 DOMAIN 枚举路径), **THEN** lint 对合法 key 不报错;对 `UI.BTN_01` 报 FAIL `"ERR_KEY_NAMING: numeric identifier in key"`; 对小写 key 报 FAIL `"ERR_KEY_NAMING: lowercase not allowed"`; 对非白名单 domain 报 FAIL `"ERR_KEY_NAMING: unknown domain [TOAST.UI]"`; 合法 key 无任何错误条目。

- **AC-FUNC-02** (Rule 2 `tr()` 纪律 — 零硬编码面向玩家文本): **GIVEN** `tools/i18n_lint.py` 扫描 `src/` 目录全部 `.gd` 文件和 `assets/` 目录全部 `.tscn` 文件, **WHEN** 其中一个 `.gd` 文件在非 `OS.is_debug_build()` 保护下含 `label.text = "继续游戏"` 赋值,且一个 `.tscn` 的 Inspector `text` 属性直接含 zh_CN 字面量 `"暂停"`, **THEN** lint 对该 `.gd` 赋值报 FAIL `"ERR_HARDCODED_STRING: .gd [file:line] label assignment without tr()"`; 对 `.tscn` Inspector 硬编码报 FAIL `"ERR_HARDCODED_STRING: .tscn [file] Inspector text contains CJK literal"`; 仅在 `if OS.is_debug_build()` 块内的 debug log 字符串不触发报错; CI 阻塞,build 不产出。

- **AC-FUNC-03** (Rule 3 RichTextLabel register/rebuild 契约 — locale switch 同帧广播): **GIVEN** 一个 RichTextLabel owner 节点在 `_ready` 调用 `LocalizationHooks.register_rich_text_refresh("hud_card_desc", rebuild_callable)`,且 rebuild_callable 执行 `clear()` + 重建 BBCode 链, **WHEN** 调用 `LocalizationHooks._force_dispatch(&"zh_CN")`(debug 钩子绕过 no-op 预检,验证 broadcast 路径存在), **THEN** rebuild_callable 在同帧(≤16.6 ms)内被调用;Registry 中 `"hud_card_desc"` 条目仍然存活(未被 purge);Label 最终文本与 `tr()` 返回值一致;若 owner 在 `_exit_tree` 调用 `unregister_rich_text_refresh("hud_card_desc")` 后再发起 locale switch,rebuild_callable **不再**被调用。

- **AC-FUNC-04** (Rule 4 缺 key 双轨策略 — dev `[MISSING:]` 显式 / prod fallback 链静默): **GIVEN** dev 构建(`OS.is_debug_build() == true`),调用 `tr("UI.NONEXISTENT_KEY")`, **THEN** 返回字符串为 `"[MISSING: UI.NONEXISTENT_KEY]"`; `push_error` 日志含 `"ERR_LOCALIZATION: key \"UI.NONEXISTENT_KEY\" not found in locale \"zh_CN\""`; UI 中 `[MISSING:]` 前缀可视。**AND** **GIVEN** prod 构建(`OS.is_debug_build() == false`), **WHEN** 调用同一 missing key, **THEN** 返回 fallback 链: 当前 locale 无值 → `zh_CN` 基准无值 → 返回 key name 本身 `"UI.NONEXISTENT_KEY"`;不 crash,不阻塞,不产生 ERROR 级日志。

- **AC-FUNC-05** (Rule 5 locale switch dispatch ≤1 帧 + `locale_changed` 信号边界): **GIVEN** Save System 订阅 `locale_changed(locale)` 信号计数器,Scene & Day Flow 无演出 lock, **WHEN** 调用 `LocalizationHooks._force_dispatch(&"zh_CN")`(debug 钩子,绕过 no-op 预检发起完整 dispatch), **THEN** `TranslationServer.set_locale` 在同帧调用;`locale_changed(&"zh_CN")` 信号恰好发射一次;Save 侧 500 ms 防抖后 meta 写入触发;整个 dispatch(TranslationServer 调用 + 信号发射)在同一逻辑帧内完成,不经 `call_deferred`;`LocalizationHooks` 在该帧内**不**直接调用任何 `SaveSystem.write_*` 或 `FileAccess` API(信号边界合规,Rule 8 承约)。

- **AC-FUNC-06** (Rule 5 演出 lock 排队 + flush 协议): **GIVEN** Scene & Day Flow 已将 `locale_switch_locked = true`, **WHEN** 调用 `LocalizationHooks.set_locale(&"zh_CN")`, **THEN** locale 切换不在本帧生效;pending locale 缓存为 `"zh_CN"`;`locale_changed` 信号**不**在本帧发射。**随后** Scene Flow 调 `LocalizationHooks.flush_pending_locale()`, **THEN** 切换在 flush 同帧完成,`locale_changed` 发射;flush 后 pending queue 清空。若 flush 调用时 `locale_switch_locked` 仍为 true,则 flush 不执行,日志输出 ERROR `"[LocalizationHooks] flush_pending_locale called while lock still active"`。

- **AC-FUNC-07** (Rule 6 CSV schema 合规验证 — 5 列 + 头行 + UTF-8 without BOM): **GIVEN** `tools/i18n_lint.py` 分析 `assets/i18n/zh_CN.csv`, **WHEN** CSV 头行为 `key,zh_CN,en,context,max_chars`(顺序锁定),且首字节非 UTF-8 BOM(`0xEF 0xBB 0xBF`),且全 row 列数 = 5, **THEN** lint 通过头行检查。**AND** 当 CSV 头行列顺序被调换(如 `key,context,zh_CN,en,max_chars`)或含 BOM 前缀时,lint 报 FAIL `"ERR_CSV_SCHEMA: column order mismatch"` 或 `"ERR_CSV_BOM: UTF-8 BOM detected"`; CI 阻塞。

- **AC-FUNC-08** (Rule 7 复数 explicit variant — 禁 GDScript `if count == 1` 分支): **GIVEN** `tools/i18n_lint.py` 扫描 `src/` 目录全部 `.gd` 文件, **WHEN** 其中一个文件含 `if count == 1:` 紧跟 `label.text` / `tr()` 赋值的复数绑定模式, **THEN** lint 报 WARN `"ERR_PLURAL_BYPASS: GDScript plural branch detected — use tr('UI.CARD_COUNT.ZERO/ONE/MANY') explicit variants"`;**AND** **GIVEN** 测试调用 `tr("UI.CARD_COUNT.MANY").format({"count": 3})` 时 CSV 含对应 key, **THEN** 返回含 `"3"` 的已格式化字符串,不触发任何 lint 错误。

- **AC-FUNC-09** (Rule 8 启动全量加载 < 100 ms + Loading Scene 时序): **GIVEN** 时钟桩(`Time.get_ticks_usec` mock)在 Loading Scene 初始化序列最早步前后各打点, **WHEN** `LocalizationHooks.load_translation("res://assets/i18n/zh_CN.csv")` + `FontManager.preload_all()` 顺序执行(50 KB CSV,4 字体), **THEN** 两步合计耗时 < 100 ms;CSV read + parse ≤ 15 ms;4 字体 preload ≤ 65 ms;FontManager init ≤ 5 ms;余量 ≥ 0 ms;超时则 CI smoke check FAIL 并附实测时间。**AND** 全部步骤完成在任何 UI 节点实例化之前;gameplay `_process` / `_input` 帧内无 CSV I/O 调用(debug 钩子断言 `FileAccess.open` 调用计数在首帧后为 0)。

- **AC-FUNC-10** (Rule 9 Compact variant overflow 3-级 escalation + `AUTO_FIT_FLOOR_PX = 11 px` 硬下限): **GIVEN** 一个 diegetic 固定容器 Label 设置 `autowrap_mode = AUTOWRAP_WORD_SMART`,`fit_content = false`,容器 `clip_contents = true`,`max_lines = 2`, **WHEN** 文本在 default font_size 下 autowrap 后仍超 `max_lines` 溢出被 clip, **THEN** Step 2: `theme_type_variation` 切换至 `&"Compact"`(11 px),若文本仍溢出 → Step 3: `autofit_size` 降至不低于 `AUTO_FIT_FLOOR_PX = 11 px`(= Step 2 Compact 值,实质上 Step 3 与 Step 2 同值,等同于"Compact 不够则 clip",严合 art-bible §7.2 禁用 10 px);若 11 px 仍溢出,容器 clip 截断,`push_error` 记 P1 defect `"[Localization] overflow at floor px for key [KEY]"`。**确认**: 任何 `add_theme_font_size_override("font_size", N<11)` 调用 lint FAIL(art-bible §7.2 违反);未经 3 级次序触发的 `add_theme_font_size_override` 即 lint WARN;Step 3 在 zh_CN 文本下触发即 CI P1 defect(layout bug 非语言 budget 问题)。

- **AC-FUNC-11a** (Rule 9 站酷快乐体 `_IRONY` key 字体 Theme 绑定 — MVP 基线可测): **GIVEN** global Theme 资源配置,`GAMEOVER.TITLE_IRONY` 对应 Label 已通过 Theme `type_variation` 或直接 font 属性绑定站酷快乐体 14 px 字体, **WHEN** QA 在 dev build 启动游戏并触发 Game Over 屏(经 cheat 或 test hook 触发 KPI 结算), **THEN** 该 Label 实际渲染字体 = 站酷快乐体(非思源黑体默认 body 字体);`label.get_theme_font(&"font")` 返回的 FontFile 资源路径匹配站酷快乐体 `.tres`;与其他 `_IRONY` key(若未来新增)共享同一字体绑定(通过注册表枚举验证,`_IRONY` 后缀 key 计数 ≥ 1 AND 全部 font 绑定 = 站酷快乐体)。

- **AC-FUNC-11b** (Rule 9 站酷快乐体 `_IRONY` locale 切换不改字体) `[Deferred until 野心版 en 上线]`: **GIVEN** `en.csv` 含 `GAMEOVER.TITLE_IRONY` 的 en 译文(野心版场景), **WHEN** 调用 `LocalizationHooks.set_locale(&"en")`, **THEN** 该 Label font 仍为站酷快乐体,**不**切换为 en 对应的 Latin 字体;所有 `_IRONY` 后缀 key 的 Label 均保持站酷快乐体绑定(QA 枚举注册表验证);`focus_path_changed` 不影响字体绑定。

- **AC-FUNC-12** (Rule 10 key 稳定性 — deprecated 流程守门): **GIVEN** CSV 中存在一条已通过 `context` 列标注 `"DEPRECATED: replaced by UI.PAUSE_MENU.RESUME_LABEL_V2"` 的旧 key `UI.PAUSE_MENU.RESUME_LABEL`, **WHEN** QA 在 dev build 调 `tr("UI.PAUSE_MENU.RESUME_LABEL")`, **THEN** 返回旧 key 的 `zh_CN` 值(手工拷贝的新 key 字面值),不返回 `[MISSING:]`;lint 对仍在 `.gd` 中引用 deprecated key 的代码报 WARN `"DEPRECATED_KEY_IN_USE: [key] — migrate to [new_key]"`;Release branch 升级为 FAIL。

### AC-PERF (性能 / Pillar 5 ≤500 ms reflow 预算)

- **AC-PERF-01** (F1 reflow latency ≤ 500 ms — MVP zh_CN N=120,N_visible=40): **GIVEN** 时钟桩在 `set_locale` 调用前后打点,N = 120 Control 节点在 active scene tree,N_visible = 40 Label 需 reflow,`atlas_swap = 0`(MVP zh_CN 仅 zh_CN,Rule 8 已预热), **WHEN** 调用 `LocalizationHooks._force_dispatch(&"zh_CN")`(debug 钩子,完整走 dispatch 路径), **THEN** 实测 `reflow_latency = T_dispatch + (120 × k_propagate) + 0 + (40 × k_layout)`;以默认参数期望值 ≈ 102 ms;实测值须 ≤ 500 ms(Pillar 5 硬上限);若 > 500 ms 则 CI FAIL 附实测值 + F1 参数快照;全程在主线程同步,不派 worker。

- **AC-PERF-02** (F1 `MAX_VISIBLE_REFLOWING_LABELS = 117` 警戒线 — N_visible 超阈值 P2 defect): **GIVEN** 测试 fixture 构造 N_visible = 118 Label 同屏 reflow 场景, **WHEN** 调用 `_force_dispatch` 并运行 CI profiling, **THEN** 实测 reflow 耗时 < 500 ms(N_visible=118 at N=500 理论 ≈ 380 ms,仍安全);但 CI profiling 输出 WARN `"[LocalizationHooks] N_visible=118 exceeds MAX_VISIBLE_REFLOWING_LABELS=117 — P2 design defect, escalate to UI lead"`;QA 须提报 P2 bug,UI 需拆分或分页。N_visible ≤ 117 时 WARN 不触发。

- **AC-PERF-03** (Rule 8 CSV parse budget — 50 KB zh_CN < 15 ms / 1000-key 警戒): **GIVEN** 测试 fixture 提供 50 KB(约 500 key)CSV 和 1000-key 双倍 CSV,各在独立 Loading Scene 初始化中运行 `load_translation`, **WHEN** 用时钟桩记录 `TranslationServer.add_translation` 完成时间, **THEN** 500-key CSV parse ≤ 15 ms;1000-key CSV parse 若超 20 ms,CI smoke check WARN `"[LocalizationHooks] CSV parse exceeds budget — consider pre-compiled .translation binary (ADR pending)"`;任何场景下 parse 完成后 `TranslationServer.get_loaded_locales()` 含 `"zh_CN"`(验证 load 成功)。

- **AC-PERF-04** (Rule 5 + F1 locale switch dispatch ≤1 帧 同步不 defer): **GIVEN** Godot Profiler 开启,游戏稳定 60 FPS,测试钩子 `LocalizationHooks._force_dispatch(locale)` **仅 debug build 存在** —— 绕过 `get_locale() == locale` no-op 预检直接触发完整 dispatch 路径, **WHEN** 连续调用 100 次 `LocalizationHooks._force_dispatch(&"zh_CN")`, **THEN** 全部 100 次的 dispatch(`TranslationServer.set_locale` 调用 + `locale_changed` 信号发射)均在调用帧的同一逻辑帧内完成;p99 dispatch 耗时 < 2 ms(`T_dispatch` 基线);**零次**调用使用 `call_deferred`(日志断言:LocalizationHooks 内部无 `call_deferred` 调用记录)。野心版 en 上线后此 AC 扩展为 zh_CN ↔ en 交替 100 次(无需 `_force_dispatch` 因正常 locale 对不同走非 no-op 路径)。

### AC-COMPAT (跨 locale / 跨系统 / CSV 格式)

- **AC-COMPAT-01** (F2 coverage ratio = 1.0 — MVP zh_CN Release gate): **GIVEN** `tools/i18n_lint.py` 在 Release branch 运行 F2 coverage check,`zh_CN.csv` 含 500 row 且全部 `zh_CN` 列非空且通过 `_IRONY` context lint, **WHEN** 执行 `coverage(zh_CN) = translated_keys / total_keys_required`, **THEN** 输出 `coverage(zh_CN) = 1.0`,CI 状态为 PASS,build 允许继续。**AND** 当任何一行 `zh_CN` 值为空字符串时,lint 报 `"ERR_EMPTY_VALUE: key [KEY] zh_CN column is empty"`,`coverage < 1.0`,CI FAIL,Release branch 阻塞;dev branch 仅 WARN 不阻塞。

- **AC-COMPAT-02** (F2 + Rule 6 coverage Alpha gate 野心版 en — 0.85 阈值) `[Deferred until 野心版 en 上线]`: **GIVEN** `en.csv` 含 280 required key,244 行 `en` 列非空且通过 lint, **WHEN** 计算 `coverage(en) = 244 / 280 ≈ 0.871`, **THEN** 0.871 ≥ `COVERAGE_ALPHA_GATE`(0.85),CI 输出 PASS,`en` locale 纳入 Alpha build;若 `coverage(en) < 0.85`,CI FAIL,`en` 从本次 Alpha build 排除,日志 `"[i18n_lint] en coverage 0.830 < COVERAGE_ALPHA_GATE 0.850 — locale excluded from build"`。

- **AC-COMPAT-03** (Rule 6 / Rule 8 CSV encoding — UTF-8 without BOM + RFC 4180 quoted commas): **GIVEN** `tools/i18n_lint.py` 分析 `assets/i18n/zh_CN.csv`, **WHEN** CSV 含一行 `UI.CARD.FLAVOUR_01,"他说,别加班",,,`(未引号 comma,分号分裂), **THEN** lint 报 FAIL `"ERR_CSV_FORMAT: unquoted comma in value at row [N]"`;**AND** 当一行 `zh_CN` 值含 GBK 字节序列(非 UTF-8), **THEN** lint 报 FAIL `"ERR_CSV_ENCODING: non-UTF-8 byte sequence at row [N]"`;两者均 CI 阻塞。合法 RFC 4180 引号字段(`"他说,\"别加班\""`)不触发报错。

- **AC-COMPAT-04** (Rule 6 + Rule 7 plural explicit variant — zh_CN 3 key variant + format 注入): **GIVEN** CSV 含 `UI.CARD_COUNT.ZERO` / `UI.CARD_COUNT.ONE` / `UI.CARD_COUNT.MANY` 三 key,值分别为 `"没有行动卡了"` / `"剩余 {count} 张行动卡"` / `"剩余 {count} 张行动卡"`, **WHEN** QA 分别调用 `tr("UI.CARD_COUNT.ZERO")` / `tr("UI.CARD_COUNT.ONE").format({"count": 1})` / `tr("UI.CARD_COUNT.MANY").format({"count": 5})`, **THEN** 返回值依次为 `"没有行动卡了"` / `"剩余 1 张行动卡"` / `"剩余 5 张行动卡"`;无 GDScript if-branch 复数逻辑可在 `src/` grep 到(`if count == 1` 模式配合 label 赋值的 lint WARN 已覆盖 AC-FUNC-08)。

- **AC-COMPAT-05** (Rule 3 + Rule 5 RichTextLabel + locale switch 跨系统联测 — HUD #13 契约): **GIVEN** HUD #13 的一个 RichTextLabel(card description)已通过 `register_rich_text_refresh("hud_card_desc", rebuild_callable)` 注册,且 `rebuild_callable` 会重建含 `[b]` BBCode 的完整字符串, **WHEN** 调用 `LocalizationHooks._force_dispatch(&"zh_CN")` 且 Scene Flow 无 lock, **THEN** `rebuild_callable` 在同帧(≤16.6 ms)被调用;RichTextLabel 最终显示文本匹配 CSV 中对应 key 的 `zh_CN` 值;若在 locale switch 之前 owner node 已被 `queue_free` 且未 unregister,则 LocalizationHooks auto-purge 该条目,rebuild_callable 不被调用,日志无 `"invalid instance"` 错误(此为 R-LOC-2 守门路径,AC-ROBUST-02 详细覆盖)。

### AC-ROBUST (错误恢复 / 边界 / 异常)

- **AC-ROBUST-01** (R-LOC-1: CSV 文件缺失 Pillar 5 启动守门): **GIVEN** `assets/i18n/zh_CN.csv` 文件从 build 中完全缺失(CI asset integrity check 场景), **WHEN** Loading Scene 调用 `LocalizationHooks.load_translation("res://assets/i18n/zh_CN.csv")`, **THEN** CI asset integrity check 在 Loading Scene 阶段之前验证 CSV 存在,缺失则 CI FAIL `"ERR_ASSET_MISSING: assets/i18n/zh_CN.csv not found — Pillar 5 5s entry promise blocked"`,build 不产出;runtime 层: `TranslationServer.get_loaded_locales()` 不含 `"zh_CN"`,`LocalizationHooks` 在启动时 `push_error("ERR_LOCALIZATION: zh_CN not loaded — TranslationServer empty")`;dev build 每次 `tr()` 调用触发 `push_error` 而非静默返回 key name(启动时 loaded locale 检查补全 Rule 4 dev 路径)。**[RISK GUARD]**

- **AC-ROBUST-02** (R-LOC-2: RichTextLabel owner `queue_free` 未 unregister — `is_instance_valid` 守门): **GIVEN** 一个演出系统节点调用 `register_rich_text_refresh("cutscene_text", rebuild_callable)` 后立即 `queue_free()` 该节点而**未**调用 `unregister_rich_text_refresh`, **WHEN** QA 触发 `LocalizationHooks._force_dispatch(&"zh_CN")` 发起 rebuild 广播, **THEN** LocalizationHooks 在调用 rebuild_callable 前执行 `is_instance_valid(owner_node)` 检测;检测返回 false,条目从注册表 auto-purge;rebuild_callable **不**被调用;日志中**不出现** `"invalid instance"` 或 GDScript 空引用错误;purge 后 `register_rich_text_refresh` 注册表计数减 1;广播继续对其余有效条目执行(广播不因单条 invalid 中止)。**[RISK GUARD]**

- **AC-ROBUST-03** (R-LOC-3: 演出 indefinite lock watchdog 30 s 触发 Pillar 5 守门): **GIVEN** `locale_switch_locked = true` 由 Scene Flow 设置,且 Scene Flow 因 bug 永不调用 `flush_pending_locale()` 或清除 lock,同时 `LocalizationHooks.set_locale(&"zh_CN")` 有 pending request, **WHEN** 系统时钟推进超过 `LOCALE_LOCK_WATCHDOG_MS = 30000 ms`(30 s), **THEN** LocalizationHooks watchdog 触发: `push_error("[LocalizationHooks] locale_switch_locked exceeded 30000ms — force flushing pending locale")`;pending locale 强制应用;`locale_changed` 信号发射;watchdog 自身重置 lock flag 为 false;玩家此后可正常切语言(Pillar 5 恢复)。**AND** 合法演出在 30 s 内完成并调 `flush_pending_locale()` 时,watchdog 不触发。**[RISK GUARD]**

- **AC-ROBUST-04** (Rule 4 `[MISSING:]` in RichTextLabel BBCode-safe 渲染): **GIVEN** dev 构建,RichTextLabel owner 的 rebuild_callable 使用 `append_text()`(BBCode 解析)插入缺失 key 的 fallback 字符串, **WHEN** fallback 字符串为 `"[MISSING: UI.CARD.FLAVOUR_NONEXISTENT]"`,其中 `[` 被 BBCode parser 解析, **THEN** rebuild_callable 改为使用 `add_text()`(plain text 路径)插入 fallback,或对 fallback 字符串 BBCode 转义(`[` → `[lb]`);渲染结果可见 `[MISSING: UI.CARD.FLAVOUR_NONEXISTENT]` 完整字符串,不产生 BBCode 解析错误;Rule 3 文档须标注此约束为 RichTextLabel rebuild callable 实现要求。

- **AC-ROBUST-05** (Rule 9 Compact theme variant 缺失 — 静默降级 P2 defect 检测): **GIVEN** CI asset validation 在 build 阶段检查 global Theme 资源, **WHEN** `theme.get_type_list()` 返回的类型列表中不含 `"Compact"` variation, **THEN** CI 报 FAIL `"ERR_THEME_MISSING: Compact theme variation absent — Rule 9 3-step escalation broken"`,build 阻塞;**AND** **GIVEN** theme 含 Compact variation 但其 `font_size` 值不为 11 px, **THEN** CI WARN `"[Localization] Compact theme font_size=[N] != 11px — Rule 9 contract mismatch"`。

### AC-TONE (Pillar 4 tone 守护 — Localization 特有)

- **AC-TONE-01** (Rule 11 `_IRONY` key context 三层执法 — lint 自动 + translator 人工 合规 happy path): **GIVEN** CSV 含 `GAMEOVER.TITLE_IRONY` 一行,`zh_CN` = `"恭喜晋升"`,`context` = `"IRONY: 表面祝贺实为宣告失败; 禁: 本轮结束 / 晋升失败 / Game Over"`, **WHEN** `tools/i18n_lint.py` 对该行执行 `_IRONY` context 检查, **THEN** lint 通过: `context` 含 `"IRONY:"` 子字符串,无 FAIL 无 WARN;`translated_keys(zh_CN)` 分子计入该 key(F2 coverage 贡献);QA 可在 `production/qa/evidence/` 存入该行截图作为 writer sign-off 证据(advisory,不 blocking MVP)。

- **AC-TONE-02** (R-LOC-4: `_IRONY` key CSV context 列缺失 `"IRONY:"` — Pillar 4 lint 守门): **GIVEN** CSV 中 `GAMEOVER.TITLE_IRONY` 的 `context` 列内容为 `"祝贺玩家晋升"`(缺 `"IRONY:"` 子字符串), **WHEN** `tools/i18n_lint.py` 在 CI 上对任意 branch 执行, **THEN** lint 报 FAIL `"ERR_IRONY_CONTEXT: key GAMEOVER.TITLE_IRONY has _IRONY suffix but context column missing 'IRONY:' annotation"`;CI FAIL,build 不产出;dev build 中 `tr("GAMEOVER.TITLE_IRONY")` 仍正常返回 `"恭喜晋升"`(runtime 不受影响,failure 在 data layer);QA 将此标注为 Pillar 4 defect(P0 blocking),不可 bypass 入库。**AND** 若 pre-commit hook 被 `--no-verify` 绕过,CI 独立运行 lint 仍 FAIL,即 CI gate 不可因 pre-commit 绕过而失守。**[RISK GUARD]**

- **AC-TONE-03** (R-LOC-5: 零 `_IRONY` key — `GAMEOVER.TITLE_IRONY` 缺失 Pillar 4 硬锁): **GIVEN** CSV 中 `GAMEOVER.TITLE_IRONY` 行被完全删除(模拟 `--no-verify` purge 或批量 key 清理误删), **WHEN** `tools/i18n_lint.py` 在**任意 branch**(包括 dev branch)执行, **THEN** lint 断言 `count(_IRONY keys) >= 1` AND `GAMEOVER.TITLE_IRONY 必须存在`;缺失则 FAIL `"ERR_IRONY_MISSING: GAMEOVER.TITLE_IRONY not found — art-bible §7.2 tone anchor hard-locked"`;CI FAIL,build 不产出;QA 标注为 P0 Pillar 4 blocking,等同于拆除 art-bible §7.2 反讽钩。**AND** 零 `_IRONY` key 场景下(CSV 中所有 `_IRONY` 后缀 key 均被删除)同样 FAIL(不仅检测 `GAMEOVER.TITLE_IRONY` 单条存在,还断言 `_IRONY` key 数量 ≥ 1)。**[RISK GUARD]**

### AC Tier 分级

**MVP 必测(Alpha gate 阻塞)— 25 条**: AC-FUNC-01~10 + AC-FUNC-11a + AC-FUNC-12(12)+ AC-PERF-01~04(4)+ AC-COMPAT-01 + AC-COMPAT-03~05(4)+ AC-ROBUST-01~05(5)+ AC-TONE-01~03(3)= 25。其中 **5 [RISK GUARD]** AC(AC-ROBUST-01/02/03 + AC-TONE-02/03)为 Pillar 5 / Pillar 4 高风险路径,须在首个可测 build 优先验证,不得推至 Beta gate。

**MVP 建议测(Beta gate 阻塞)— 2 条**: AC-FUNC-11b(需野心版 en 字体 + CSV 就绪)、AC-COMPAT-02(需野心版 en CSV fixture + `COVERAGE_ALPHA_GATE` validation 就绪)。两者标 `[Deferred until 野心版 en 上线]`。

**VS tier 推迟**: 无 —— Tutorial `TUTORIAL.*` key 覆盖验证归 #18 Tutorial GDD 自定 AC;Accessibility `LargeText` variation 归 #20 Accessibility GDD 自定 AC。

### QA 工具需求

**1. CSV Fixture 库** (`tests/fixtures/localization/`)

| Fixture 文件 | 用途 | 对应 AC |
|---|---|---|
| `zh_CN_500key_valid.csv` | 500 row 全合规基准 CSV,含 `GAMEOVER.TITLE_IRONY` + 4 domain 样本 | AC-FUNC-01/02/09, AC-COMPAT-01, AC-PERF-03 |
| `zh_CN_missing_irony_context.csv` | `GAMEOVER.TITLE_IRONY` context 列缺 `"IRONY:"` | AC-TONE-02 |
| `zh_CN_no_irony_key.csv` | 完全不含任何 `_IRONY` key | AC-TONE-03 |
| `zh_CN_bom_prefixed.csv` | UTF-8 BOM 前缀,触发 lint FAIL | AC-FUNC-07, AC-COMPAT-03 |
| `zh_CN_unquoted_comma.csv` | 含未引号 comma 的 row | AC-COMPAT-03 |
| `zh_CN_empty_value.csv` | 1 row `zh_CN` 列为空字符串 | AC-COMPAT-01 |
| `zh_CN_duplicate_key.csv` | 2 row 同 key `UI.PAUSE_MENU.RESUME_LABEL` | AC-FUNC-01 |
| `zh_CN_hardcoded_tscn_sample.tscn` | Inspector `text` 含 zh_CN 字面量 | AC-FUNC-02 |
| `en_244key_alpha.csv`(野心版) | 280 required key,244 en 列非空(coverage ≈ 0.871) | AC-COMPAT-02 |
| `global_theme_no_compact.tres` | 缺 Compact variation 的 Theme 资源 | AC-ROBUST-05 |

**2. `tools/i18n_lint.py` 测试套件** (`tests/unit/localization/test_i18n_lint.py`)

- 单元测试覆盖: key 命名正则(Rule 1)/ `_IRONY` context 检测(Rule 11)/ duplicate key 检测(Rule 6)/ `.tscn` 硬编码扫描(Rule 2)/ `.gd` `label.text = "..."` 非 `tr()` 赋值扫描(Rule 2)/ CSV BOM 检测(Rule 6)/ UTF-8 编码验证(Rule 6)/ RFC 4180 列数校验(Rule 6)/ coverage ratio 计算(F2)
- 每条规则须有 happy-path test + failure-path test(fixture 文件驱动)
- lint 输出须为 machine-parseable(JSON 或结构化行输出),供 CI 门读取 exit code

**3. 时钟桩 / 事件注入工具**(GUT 测试专用)

- `LocalizationTestClock`: mock `Time.get_ticks_usec` 供 F1 reflow latency 断言(AC-PERF-01/02/04)和 Rule 8 startup budget 断言(AC-FUNC-09 / AC-PERF-03)
- `LocalizationTestClock.advance_ms(N)` 供 R-LOC-3 watchdog 触发测试(AC-ROBUST-03): 将内部时钟推进 30001 ms,断言 watchdog error log + force flush
- `LocalizationHooks._force_dispatch(locale)` + `LocalizationHooks.test_set_locale_lock(true/false)`: **仅 debug build**,绕过 no-op 预检 / 直接设置 `locale_switch_locked` flag,供 AC-FUNC-03/05/06 + AC-PERF-01/02/04 + AC-COMPAT-05 + AC-ROBUST-02/03 测试

**4. `TranslationServer` Mock / Stub**

- `MockTranslationServer`: GUT stub,拦截 `set_locale` / `translate` / `get_loaded_locales` 调用并记录调用序列
- 供 AC-FUNC-05(信号边界验证 — 确认 LocalizationHooks 不直调 SaveSystem)+ AC-ROBUST-01(CSV 缺失启动路径)使用
- stub 可配置为 `translate(key)` 始终返回空(模拟 TranslationServer 无数据态)供 fallback chain 断言(AC-FUNC-04)

**5. 字体 Atlas 压测 Fixtures**

- `font_preload_bench.gd`: Loading Scene 独立脚本,调 `FontManager.preload_all()` 并用 `Time.get_ticks_usec` 记录每字体耗时;输出写 `production/qa/smoke-[date].md` 的 Rule 8 budget 分项
- `font_compact_theme_validator.gd`: 在 CI 阶段加载 global Theme 资源,调 `theme.get_type_list()` 断言含 `"Compact"` + `font_size == 11`(AC-ROBUST-05)

**6. Coverage 计算工具 Test Harness**

- `test_coverage_ratio.py`(`tests/unit/localization/`): Python unittest,直接 import `tools/i18n_lint.py` 的 coverage 函数,用 fixture CSV 验证 F2 公式:
  - `coverage(zh_CN)` = 1.0 on `zh_CN_500key_valid.csv` → PASS
  - `coverage(zh_CN)` < 1.0 on `zh_CN_empty_value.csv` → FAIL + 正确 exit code
  - `coverage(en)` ≈ 0.871 on `en_244key_alpha.csv` → 0.871 ≥ 0.85 Alpha gate PASS
- Harness 须验证 lint 与 F2 互补约束: F2 分子计 key 存在,lint 验 `zh_CN` 非空值;两者俱过方 Release(对应 Edge Case 2 第 5 条的"F2 无法辨 `""` 与合法 string"设计决定)

## Open Questions

12 条 OQ-LOC 集中(分布于 Sections C/D/E/G),按 owner / target 排序:

| OQ ID | 描述 | Owner | Target Resolution |
|-------|------|-------|-------------------|
| OQ-LOC-01 | `NOTIFICATION_TRANSLATION_CHANGED` propagation to post-switch-instantiated scene — UNVERIFIED in Godot 4.6,需实测确认(Edge 4.4) | engine-programmer + godot-specialist | ADR-XXXX(dual-focus 阶段一起验) |
| OQ-LOC-02 | Orphan key 清除策略 — dynamic `tr("KEY_" + suffix)` 模式破 grep,需写 key-ref registry 或抑制 lint | writer + systems-designer | Rule 11 lint spec / ADR |
| OQ-LOC-03 | CSV integrity 校验 scope — `tools/i18n_lint.py` 管 vs 独立 CI asset-validation(Cat 2/7/8 交集) | technical-director + qa-lead | i18n_lint.py 设计 spec |
| OQ-LOC-04 | RichText register 双问题 — `register_rich_text_refresh` duplicate owner_id policy(overwrite vs reject)+ re-entrant dispatch `_broadcast_active` flag 策略 | systems-designer + engine-programmer | ADR(映射 Input OQ-INP-02) |
| OQ-LOC-05 | Locale switch race 三问题 — no-op 静默 vs 重发 / same-frame double-tap debounce 归属 / 30s watchdog 阈值校准 | game-designer + systems-designer | Rule 5 amendment / ADR |
| OQ-LOC-06 | Godot 4.6 未验证 API — Theme `get_type_list()` 用于 Compact variant CI 验证 / `FontVariation` 适用性(若站酷快乐体是 Variable Font) | engine-programmer + godot-specialist | ADR / engine-reference doc 更新 |
| OQ-LOC-07 | Default locale 检测 — 野心版 en 上线后按 OS locale 默认 or 保持 `zh_CN` 强制;Steam `RegKey` 中国区是否特殊处理 | producer + technical-director | 野心版 kickoff ADR |
| OQ-LOC-08 | RTL scope 明确 —— MVP + 野心版明确 RTL(Arabic / Hebrew)out-of-scope 作 architectural constraint,防后人误加 | creative-director + technical-director | 野心版 kickoff 或 architecture review |
| OQ-LOC-09 | CSV authoring flow — writer 直编 CSV vs GDD / story 提取工具;工具归 tools-programmer 设计 | writer + tools-programmer | Alpha pre-production |
| OQ-LOC-10 | Godot 4.6 CSV plural column 具体 schema — 4.6 新特性 `en` + `en_1` + `en_2` 列具体格式 pin ADR | godot-specialist + localization-lead | 野心版 en 上线前 ADR |
| OQ-LOC-11 | 11 px 思源黑体 / 方正公文宋中文字形粘连实测 — art-bible §7.2 只测 10 px 为粘连下限,11 px 实际可读性需美术 playtest 验证 | art-director + ui-programmer | Polish playtest |
| OQ-LOC-12 | 字体 license 审计 — 方正公文宋商用 / 思源黑体 OFL / 站酷快乐体 license 状态,可能推翻字体选择 | technical-director + art-director | Alpha pre-production |

**OQ 标记的 AC**: 以下 AC 精确表述可能需要 OQ 解决后更新: AC-FUNC-03 / AC-FUNC-05 / AC-COMPAT-05(OQ-LOC-01 + OQ-LOC-04 propagation + register race)、AC-FUNC-11a(OQ-LOC-12 font license)、AC-COMPAT-02(OQ-LOC-10 en plural column schema)、AC-ROBUST-05(OQ-LOC-06 Theme API)。
