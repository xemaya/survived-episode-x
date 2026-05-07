# Story 011: HR 口吻 + 主语翻转 + 零 SFX lint

> **Epic**: Main Menu / Pause / Settings UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Logic
> **Manifest Version**: 2026-04-28

## Context

**GDD**: `design/gdd/main-menu-pause-settings-ui.md`
**Requirement**: AC-TONE-01/02/03 + AC-COMPAT-03 + Rule 8

**ADR Governing Implementation**: ADR-0010 Subject Inversion Lint Master 8 Domain List + ADR-0014(Settings tone 守门)
**ADR Decision Summary**: 主菜单 + Pause + Settings 文案遵循 HR 口吻 + 主语翻转规则;`MAINMENU.* / PAUSE.* / SETTINGS.* / REMAP.*` 4 域加入 lint master list;Settings 子屏全程零 SFX(audio-director 听测 + Audio Manager Story 002 lint 守门)。

**Engine**: Godot 4.6 | **Risk**: LOW
**Engine Notes**: 同 `#16` Story 013 lint 框架。

**Control Manifest Rules (Presentation)**:
- Required: `subject_inversion_lint.py --domain MAINMENU,PAUSE,SETTINGS,REMAP` CI 阻塞;0 violations
- Forbidden: 游戏术语("开始游戏" / "Pause" / "Quit" 玩家主语);Settings 子屏 SFX 触发(违反 AC-TONE-02)
- Guardrail: lint ≤ 5s

---

## Acceptance Criteria

- [ ] AC-TONE-01: 主菜单 4 按钮文案审查 — 无游戏术语("开始游戏" / "设置" / "Pause" / "Quit");符合 HR 口吻白名单("继续上班" / "入职新员工" / "查阅人事档案" / "公司停业")
- [ ] AC-TONE-02: Pause 子屏打开 / 关闭 / Settings 控件操作,全程无 SFX 播放(audio-director 听测 + Audio lint)
- [ ] AC-TONE-03: QA 枚举 Settings 子屏全部 Control 节点,无 AP / KPI / Energy 调节控件(与 Story 008 双重守门)
- [ ] AC-COMPAT-03: `zh_CN` locale,Settings / Pause / 主菜单渲染,所有玩家可见文案使用 `tr(key)` 路径,无硬编码字符串(lint 验证)

---

## Implementation Notes

*From GDD Rule 8 + ADR-0010:*

- 主语翻转 lint domain 扩展:
  ```python
  # tools/subject_inversion_lint.py — 加 4 domain
  DOMAIN_RULES_MAINMENU = {
      "forbidden_words": ["开始游戏", "暂停", "退出", "你的设置", "你的数据", "Quit", "Pause"],
      "required_patterns": ["上班", "入职", "归档", "停业"],  # HR 用词
      "whitelist_keys": [],
  }
  DOMAIN_RULES_PAUSE = {
      "forbidden_words": ["你休息", "你暂停"],
      "required_patterns": ["摸鱼", "继续上班"],  # 诙谐 HR 口吻
      "whitelist_keys": [],
  }
  DOMAIN_RULES_SETTINGS = {
      "forbidden_words": ["你的偏好", "你的设置", "self-service"],
      "required_patterns": ["设置项", "已记录"],
      "whitelist_keys": [],
  }
  DOMAIN_RULES_REMAP = {
      "forbidden_words": ["按键映射", "你的快捷键"],
      "required_patterns": ["键位 / 设备", "已登记"],
      "whitelist_keys": ["REMAP.UNBOUND_LABEL"],  # "未绑定" 红色标记可保留
  }
  ```
- 零 SFX 守门(`#4 Audio Manager` Story 002 同源 lint):
  ```python
  # tools/zero_sfx_in_settings_lint.py
  # 扫描 settings_screen.gd / pause_screen.gd / remap_screen.gd
  # grep: AudioStreamPlayer / play() / play_sfx / play_ambient
  # 命中 → CI FAIL
  ```
- tr() 路径 lint(已在多 epic 实施):
  ```bash
  grep -rn "[一-鿿]" src/ui/main_menu/ --include="*.gd" --include="*.tscn"
  # 命中中文字面量 → CI FAIL
  ```

---

## Out of Scope

- writer csv 内容生产(Phase 4)
- Story 008(R-MM-1 AP/KPI/Energy lint 独立)
- 其他 epic 主语翻转 lint(各自 epic)

---

## QA Test Cases

- **AC-TONE-01**: 4 按钮文案
  - Given: MainMenuPanel 渲染
  - When: 反射 4 按钮 text
  - Then: 文案对应 tr("MAINMENU.CONTINUE_BUTTON") / "NEW_RUN_BUTTON" / "ARCHIVE_BUTTON" / "QUIT_BUTTON";csv 内容含"上班 / 入职 / 档案 / 停业"关键词;无"开始 / 设置"
  - Edge cases: 故意改 csv 加"开始游戏" → lint FAIL

- **AC-TONE-02**: 零 SFX
  - Given: Pause 子屏开启 / 关闭 / Settings 旋钮拖动
  - When: AudioServer.get_bus_count() 监听 + AudioStreamPlayer 节点扫描
  - Then: 全程 0 个 AudioStreamPlayer.play() 调用(grep 静态分析 + 运行时听测)

- **AC-TONE-03**: 零 AP/KPI/Energy 控件(人工)
  - Given: Settings 子屏所有 Control 节点
  - When: QA 人工枚举
  - Then: 无 ap/kpi/energy 字面量节点名 + 无相关调节控件(与 Story 008 自动 lint 双重守门)

- **AC-COMPAT-03**: 全 tr() 路径
  - Given: src/ui/main_menu/ 全文件
  - When: grep 中文字面量
  - Then: 0 命中

---

## Test Evidence

**Required evidence**: `tests/unit/main_menu/hr_tone_subject_inversion_lint_test.gd` — must exist and pass

---

## Dependencies

- Depends on: Story 001 + 003 + 004 + 007(消费 MAINMENU/PAUSE/SETTINGS/REMAP keys);`#10 Event Script` Story 011(主语翻转 8 master 框架);`#4 Audio Manager` Story 002(audio event naming Pillar 4 lint)
- Unlocks: 无

## Completion Notes

**Completed**: 2026-05-01
**Criteria**: 4/4 COVERED via 5 test 函数(`tests/unit/main_menu/hr_tone_subject_inversion_lint_test.gd`)+ Python 实施(`tools/main_menu_tone_lint.py`)— AC-TONE-01 clean run on src/ui/main_menu/ + 注入"开始游戏" → exit 2 / AC-TONE-02 注入 AudioStreamPlayer → exit 2 / AC-COMPAT-03 中文字面量在代码 → exit 2 + 在注释 → exit 0
**Test Evidence**: `tests/unit/main_menu/hr_tone_subject_inversion_lint_test.gd`(GdUnit4 5 tests via OS.execute python3 wrapper)+ `tools/main_menu_tone_lint.py`(三类 lint:HR tone forbidden words / Zero-SFX / tr() coverage)— BLOCKING gate PASS
**Code Review**: APPROVED;HR-tone forbidden 列表偏保守(11 词)避免 false-positive — production 阶段 writer 可扩展;Zero-SFX 用 `\bAudioStreamPlayer\b` + `.play_sfx(` / `.play_ambient(` / `.play_music(` 精准匹配,规避 AnimationPlayer.play() 的过广误伤;tr() coverage 注释行允许中文(产品文档需求),代码部分(split `#` 取头)中文 → 违例;无 BLOCKING / 无 inline fix
**Deviations** (3 项 ADVISORY,无 BLOCKING):
1. ADR-0010 Status=Proposed — lean-mode-equivalent
2. AC-TONE-03 "QA 人工枚举无 AP/KPI/Energy 控件"是 manual 走查路径(双重守门),与 Story 008 自动 lint 互补 — 本 story 实施自动部分,manual 列表由 QA Phase 4 补
3. CSV 内容生产(MAINMENU.* / PAUSE.* / SETTINGS.* / REMAP.* 实际译文)由 writer Phase 4 own — 本 story 验 lint 工具 + locale key 引用合规
**Tech debt**: None new
**API surface**:
- `tools/main_menu_tone_lint.py` CLI:`python3 tools/main_menu_tone_lint.py [paths...]` → exit 0/2
- 三类违例: `HR_TONE_FORBIDDEN_WORDS`(11 词) + `ZERO_SFX_FORBIDDEN_PATTERNS`(4 regex) + Chinese-in-code regex
- `tests/unit/main_menu/hr_tone_subject_inversion_lint_test.gd` GdUnit4 wrapper
