# ADR-0010: Subject Inversion Lint Master Domain List

## Status

Accepted

## Date

2026-04-28

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6(infra,但 lint 工具是 Python CI 脚本) |
| **Domain** | Core / Scripting / Localization(text content lint)|
| **Knowledge Risk** | LOW(纯 Python CI 脚本 + CSV/Resource 文本检查,Godot 版本无关)|
| **References Consulted** | `docs/engine-reference/godot/modules/localization.md` |
| **Post-Cutoff APIs Used** | None(lint 工具是 Python,不调 Godot API)|
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001(8 域 master list 在 ADR-0001 sketch 中提前定义,本 ADR 形式化)|
| **Enables** | CI text lint 工具 + 全 GDD 一致性自动化 + writer authoring 守门 |
| **Blocks** | CI 集成 PR check(lint 配置文件未定无法 CI 阻断)|
| **Ordering Note** | P1 优先级第二(Foundation 必创) |

## Context

### Problem Statement

`#10 Event Script Engine` Rule 14 + `#15 Daily/Weekly Recap UI` 等多 GDD 规定"主语翻转"语言风格 — HR 戏谑口吻颠倒主语(员工 ↔ 公司 / 员工 ↔ KPI 等),作为 P3 + P4 主轨 enforcement。

11 GDD 各自声明子域(EVENT / NPC / AP / ENERGY / KPI / EFFORT / TENURE / RECAP / GAMEOVER / EVAL / ARCHIVE / TUTORIAL_NPC / CHOICE 等),**列表分裂** — 导致:
- writer 不知该用哪个 domain prefix
- CI lint 不知白名单
- 各 GDD 互不一致

ADR-0001 sketch 定义了 8 域 master list(EVENT/NPC/AP/ENERGY/KPI/EFFORT/TENURE/RECAP),本 ADR 形式化 + 扩展。

### Constraints

- 8 域 master list 可包含 13 子域(避免过度切分)
- writer 可读(中文 / 英文 prefix 都能理解)
- CI lint 工具可机械解析(Python regex)
- 与 `data/lang/zh-CN.csv` localization key 命名一致
- 与 EventResource `farewell_event` flag 配合(numeric_only 守门)

### Requirements

- Master domain list 锁定(8 域)
- 子域映射(13 子域 → 8 master)
- lint 配置文件单点(`tools/lint_config.toml`)
- CI 集成 PR check
- writer authoring 工具集成(VS Code snippet)

## Decision

### 8 Master Domain List

| # | Master Domain | 用途 | 子域示例 |
|---|--------------|------|---------|
| 1 | **EVENT** | 事件剧本(NPC 互动 / 工作场景 / 月末 KPI 等)| EVENT.NPC.* / EVENT.KPI.* / EVENT.MONTH_END.* / EVENT.MORNING.* / EVENT.AFTERNOON.* |
| 2 | **NPC** | NPC 关系变化 / 通知 / 离别 | NPC.RELATIONSHIP.* / NPC.NOTICE.* / NPC.LIFECYCLE.* |
| 3 | **AP** | AP 经济(消耗 / 加班 / 精力)| AP.CONSUMED.* / AP.OVERTIME.* / AP.ENERGY.*(子域,但归 AP master)|
| 4 | **KPI** | KPI 系统(阈值 / 浮动 / 三连败 / 离职)| KPI.THRESHOLD.* / KPI.SETTLEMENT.* / KPI.DISMISSAL.*(含 GAMEOVER 子域)/ KPI.PREDICTION.* |
| 5 | **EFFORT** | 月末 effort 评估(potential / OT / hero)| EFFORT.POTENTIAL.* / EFFORT.OVERTIME.* / EFFORT.HERO.* / EFFORT.OVERAGE.* |
| 6 | **TENURE** | 入职月数 / 涨阈值 / NPC 任期(EVAL.* 子域归此) | TENURE.MONTHLY.* / TENURE.EVAL.*(月度评语)/ TENURE.ANNIVERSARY.* |
| 7 | **RECAP** | 日报 / 周报 / 月报回顾 | RECAP.DAILY.* / RECAP.WEEKLY.* / RECAP.MONTHLY.*(numeric_only 守) / RECAP.ARCHIVE.*(归档浏览)|
| 8 | **TUTORIAL** | 引导剧本 / TUTORIAL_NPC 角色 / CHOICE 选择文本 | TUTORIAL.NPC.* / TUTORIAL.CHOICE.* / TUTORIAL.HINT.* |

### 子域 → Master 映射(13 子域)

| 13 子域 | 归属 Master |
|---------|------------|
| EVENT | EVENT(self)|
| NPC | NPC(self)|
| AP | AP(self)|
| ENERGY | AP |
| KPI | KPI |
| EFFORT | EFFORT |
| TENURE | TENURE |
| RECAP | RECAP |
| GAMEOVER | KPI |
| EVAL | TENURE |
| ARCHIVE | RECAP |
| TUTORIAL_NPC | TUTORIAL |
| CHOICE | TUTORIAL |

### `tools/lint_config.toml` 配置

```toml
[subject_inversion_lint]
master_domains = ["EVENT", "NPC", "AP", "KPI", "EFFORT", "TENURE", "RECAP", "TUTORIAL"]

# 各 master 允许的"主语翻转"语言模板(HR 戏谑口吻)
[subject_inversion_lint.templates.EVENT]
allowed_subjects_inverted = [
    "员工 ↔ 公司",      # "公司决定让员工..."(本来是员工自己决定)
    "员工 ↔ 项目",      # "项目把员工 KPI 评估..."
    "员工 ↔ KPI",       # "KPI 决定员工的去留"
    "员工 ↔ 部门"
]

[subject_inversion_lint.templates.KPI]
allowed_subjects_inverted = [
    "员工 ↔ KPI",
    "员工 ↔ HR 系统"
]

# (其他 6 master 各自模板...)

# 离别事件 numeric_only 守门(ADR-0001 + ADR-0009 集成)
[subject_inversion_lint.farewell_numeric_only]
applies_to_master = ["EVENT", "RECAP"]
allowed_keys_pattern = "EVENT\\.NPC\\..*\\.TITLE_NUMERIC|RECAP\\.WEEKLY\\..*\\.NUMERIC_LIST"
```

### `subject_inversion_lint.py` 工具

```python
# tools/subject_inversion_lint.py
import re
import sys
import tomllib
from pathlib import Path

CONFIG = tomllib.load(open("tools/lint_config.toml", "rb"))
MASTER_DOMAINS = CONFIG["subject_inversion_lint"]["master_domains"]

def lint_csv(csv_path: Path) -> list[str]:
    errors = []
    for line in csv_path.read_text().splitlines():
        if not line or line.startswith("#"):
            continue
        key, _, value = line.partition(",")
        # 检查 prefix 在 master_domains 中
        prefix = key.split(".")[0]
        if prefix not in MASTER_DOMAINS:
            errors.append(f"{csv_path}: key '{key}' uses unknown domain '{prefix}'")
        # 检查 farewell numeric_only
        if "FAREWELL" in key.upper() and not re.match(
            CONFIG["subject_inversion_lint"]["farewell_numeric_only"]["allowed_keys_pattern"], 
            key
        ):
            errors.append(f"{csv_path}: farewell key '{key}' violates numeric_only")
    return errors

if __name__ == "__main__":
    errors = []
    for csv in Path("data/lang").glob("*.csv"):
        errors.extend(lint_csv(csv))
    if errors:
        print("\n".join(errors))
        sys.exit(1)
    print(f"{len(errors)} errors")
```

### CI 集成

`.github/workflows/lint.yml`:
```yaml
- name: Subject Inversion Lint
  run: python tools/subject_inversion_lint.py
- name: Event Schema Lint (ADR-0009)
  run: python tools/event_schema_lint.py
- name: Signal Ownership Lint (ADR-0001)
  run: python tools/signal_ownership_lint.py
```

PR 失败任何一项 lint → 阻塞合并。

### writer authoring 工具(VS Code snippet)

`.vscode/csv.code-snippets`:
```json
{
  "EVENT key prefix": {
    "prefix": "evt",
    "body": ["EVENT.${1|NPC,KPI,MONTH_END,MORNING,AFTERNOON|}.${2:event_id}.${3|DIALOGUE,TITLE_NUMERIC,EFFECT_TEXT|}.${4:0_STANDARD},${5:Chinese text}"]
  }
}
```

## Alternatives Considered

### Alternative 1: 13 子域全列(无 master 简化)

- **Pros**: 精细化每子域各自模板
- **Cons**: writer 难记 / lint 配置爆炸 / 各 GDD 已不一致再加剧
- **Rejection**: 8 master 已能涵盖

### Alternative 2: 各 GDD 自治(无 master)

- **Pros**: 每 GDD 灵活
- **Cons**: 已在 /review-all-gdds 暴露 — 11 GDD 各自声明分裂
- **Rejection**: 已 fail

### Alternative 3: master 域更细(15+)

- **Pros**: 表达更精
- **Cons**: writer 选择困难 + lint 模板爆炸
- **Rejection**: 8 master 是 Goldilocks zone

## Consequences

### Positive

- 8 master domain list 锁定 + 13 子域映射明确
- CI lint 工具单点配置(`tools/lint_config.toml`)
- writer authoring 工具集成(VS Code snippet)
- farewell numeric_only 守门(ADR-0001 + ADR-0009 集成)
- 与 localization key 命名一致

### Negative

- 子域命名约定与 GDD 历史声明不完全一致(各 GDD 需 retrofit pass 同步)
  - Mitigation: 随着 GDD review 一并修正(13 子域 → 8 master 重命名 PR)
- lint 配置 toml 增加 maintenance(新增子域需 ADR amendment)

### Risks

- **R-A10-1**: writer 误用 prefix(如 GAMEOVER → 实际归 KPI)
  - **Mitigation**: VS Code snippet + CI lint 阻断
- **R-A10-2**: 新增 master 域(如 PHILOSOPHY)需 ADR amendment
  - **Mitigation**: ADR-0010 修订或 superseded ADR

## GDD Requirements Addressed

| GDD | Rule | 实现 |
|-----|------|------|
| `#10 Event Script Engine` Rule 14 | 主语翻转 lint EVENT.* | EVENT master + lint |
| `#7 AP` Rule 14 | AP.* keys 守门 | AP master + lint |
| `#8 NPC` Rule 11 | NPC.* keys | NPC master + lint |
| `#15 Recap UI` Rule 8 | RECAP.* keys numeric_only farewell | RECAP master + farewell pattern |
| `#16 KPI Review UI` | KPI.DISMISSAL.* | KPI master |
| ADR-0001 B-DEP-2 守门 | farewell_event numeric_only | farewell_numeric_only pattern |

## Performance Implications

- **CPU**: lint 工具 CI 阶段运行,< 5s 完成 200 events × 14 master/sub-domain 检查
- **Memory**: lint 配置 < 1KB / `data/lang/*.csv` 内存 < 1MB
- **Load Time**: N/A(CI 阶段)
- **Network**: N/A

## Migration Plan

1. ADR Accepted → `tools/subject_inversion_lint.py` 实施
2. `tools/lint_config.toml` 配置文件创建
3. `.github/workflows/lint.yml` CI 集成
4. `.vscode/csv.code-snippets` writer 工具
5. 现有 GDD retrofit pass(13 子域 → 8 master 重命名)
6. CI 阻断 PR(lint 失败时)

## Validation Criteria

- 8 master domain 与 11 GDD 声明一致(consistency-check)
- CI lint 工具 PR 阻断测试(故意误 prefix 提交)
- farewell event keys 全部匹配 numeric_only pattern(自动化测试)
- writer VS Code snippet 单元测试(预设输入 → 预期输出)

## Related Decisions

- ADR-0001 Signal Ownership Matrix(8 域 master list sketch)
- ADR-0009 Event Schema Format(farewell_event flag 集成)
- `#10 / #7 / #8 / #15 / #16` GDD localization key 命名
- `data/lang/zh-CN.csv` localization 文件
- `tools/lint_config.toml` 单点 lint 配置
