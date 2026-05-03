# 开场视频设计 — 《活过第 X 集》

**日期**: 2026-05-03
**目标产出**: 60 秒 1080p 开场视频 `output/opening_v01.mp4`
**生成工具**: MiniMax Hailuo-2.3 (image-to-video) + 本地 ffmpeg + PIL 后期

## 1. 目标

为《活过第 X 集》产出一支 60 秒开场片，复用现有 pixel art 素材，承载游戏核心反差："反向 KPI · 你的目标是不要被开"。

视频不含音频（音乐 / 音效后续单独制作，本次不在范围内）。

## 2. 叙事弧（B+ 混搭）

| 段 | 时长 | 风格路线 | 内核 |
|---|---|---|---|
| Ⅰ. 宣传片伪装 | 0:00 - 0:10 | 半电影化（允许 MiniMax 半光滑动画） | 金光、奖状、阳光职场 |
| Ⅱ. 下沉 | 0:10 - 0:54 | 像素硬保留（每条 prompt 强调 `pixel grid, no anti-aliasing`，运镜限定为推/拉/平移/局部小动效） | 闷压、堆积、被掠过、油尽灯枯 |
| Ⅲ. 标题钉子 | 0:54 - 1:00 | 静帧 + ffmpeg 后期合成 | 划掉"优秀员工"，钉下"活过第 X 集" |

设计意图：风格断层（流畅光鲜 → 硬像素）正面服务叙事——伪装段越流畅，下沉段反差越扎心。

## 3. 分镜表（10 镜）

所有 clip 通过 image-to-video 生成（首帧来自 `assets/sprites/`），duration=6s，分辨率 1080P，model `MiniMax-Hailuo-2.3`。

| # | 时长 | 首帧来源 | 内容 + 运镜 | 路线 |
|---|---|---|---|---|
| A1 | 5s | `test_outputs/C_world_map_v01.png` | 办公室俯视图，金光从天而降，缓慢推近一个工位 | 半电影化 |
| A2 | 5s | `character/fake_smile.png` | 主角假笑 close-up，慢拉远露出空荡奖状墙 | 半电影化 |
| B1 | 6s | `character/drowsy.png` | 6:30 闹钟特写元素，摇到主角揉眼睛（极小动作） | 像素硬保留 |
| B2 | 6s | `hud/monitor_warning.png` + `character/pose_typing.png` 合成 | 工位 POV，屏幕由蓝转红警，键盘节奏 | 像素硬保留 |
| B3 | 6s | `npc/boss.png` 剪影 | 老板从主角背后掠过，主角僵住一瞬 | 像素硬保留 |
| B4 | 6s | `test_outputs/A_npc_archetypes_v01.png` 截取卷王/摆烂族/谄媚族区域 | 横向 pan 三个同事工位 | 像素硬保留 |
| B5 | 6s | `character/pretend_busy.png` + `npc/hr.png` | 主角已是 pretend_busy 姿势，HR 剪影从画面右侧走过、停顿一瞬、继续走 | 像素硬保留 |
| B6 | 6s | `hud/coffee_full.png` + `hud/sticky_overtime.png` 合成 | 同视角时间流逝叠化，咖啡见底、便签堆山 | 像素硬保留 |
| B7 | 8s | `scenes/overtime_night.png` | 整层楼灯逐个熄灭，只剩主角工位一盏白炽灯 | 像素硬保留 |
| C1 | 6s | `character/state_overtime.png` 黑底合成 | 主角 exhausted 静帧，慢 zoom out，留出标题空间 | 静态 + 后期 |

**MiniMax 时长枚举**：API 支持 6 / 10 秒。生成策略：
- A1, A2 (目标 5s)：生成 6s，剪辑时裁掉首尾各 0.5s
- B1-B6, C1 (目标 6s)：生成 6s，原长使用
- B7 (目标 8s)：生成 10s，剪辑时裁掉首尾各 1s（保留中段最稳定的灭灯动效，避免 slowdown 改变节奏）

## 4. Prompt 模板

每条 prompt 遵循骨架，强制注入 STYLE_GUIDE.md 锚点：

```
Animate this pixel art reference image with subtle, restrained motion only.

[镜头描述: 1-2 句, e.g., "Camera slowly pushes in toward the central cubicle"]
[动效描述: 1-2 句, e.g., "Single fluorescent ceiling light flickers once.
  A 2px fly traverses the screen left to right at frame 60. Otherwise static."]

PRESERVE STYLE:
- SFC/16-bit pixel art aesthetic, visible pixel grid, no anti-aliasing on outlines
- Limited 16-color palette, dominated by 格子间灰蓝 #5A7080 + 白炽灯白 #E8E0CC
- Do NOT smooth, vectorize, or modernize the source image
- Do NOT add new characters, props, or text not present in source

MOTION CONSTRAINT:
- Camera move: [push-in / pull-out / pan / static]
- Character motion: [none / micro-blink / micro-typing-finger / chest-breathe]
- Duration: 6 seconds, 24fps feel preferred
```

宣传片段（A1, A2）的 prompt 在末尾放宽约束，允许"warm golden lighting bloom" 和"gentle camera dolly"。

每条 clip 的具体 prompt 在 plan 阶段细化。

## 5. 标题叠加层（ffmpeg 后期）

所有中文文字**不进 MiniMax**，全部本地渲染叠加。MiniMax 在汉字渲染上不稳定。

**资源准备**（`tools/video/render_titles.py`）：用 PIL + 本地中文字体（推荐霞鹜文楷或 Source Han Serif）渲染：
- `title_fake.png` — "优秀员工·第 N 集" 金色 #E0B050 + 描边
- `title_real.png` — "活过第 X 集" 白炽灯白 #E8E0CC + 描边
- `subtitle.png` — "Survive Episode X · 你的 KPI 是不要被开" 小号
- `strikethrough.png` — 红色划线序列帧（10 帧扫过动画）

**叠加时间表**（ffmpeg overlay 滤镜，关键帧驱动）：

| 时间 | 动作 |
|---|---|
| 0:00 - 0:08 | `title_fake` 右上角淡入，stay |
| 0:08 - 0:10 | `title_fake` 抖动 + 淡出 |
| 0:54 - 0:56 | 静帧定格，`title_fake` 重新出现于画面中央 |
| 0:56 - 0:57 | `strikethrough` 序列扫过 "优秀员工" |
| 0:57 - 0:58 | 砰一下切换为 `title_real` |
| 0:58 - 1:00 | `subtitle` 浮现 |

A2 → B1 转场用 1 帧白闪（`color=white@1:size=1920x1080:d=0.04`）暴露"伪装→现实"的破口。

## 6. 失败兜底

- **每个 clip 第一次跑 768P 草稿**确认构图，OK 再升 1080P。草稿成本 ~50% 正稿。
- **重试上限**：每 clip 最多 2 次。第二次仍不达标则降级方案：
  - 像素硬保留段降级 → 用首帧静帧 + ffmpeg Ken Burns（推/拉/平移）伪造运动
  - 半电影化段降级 → 接受现有结果，不再重试
- **运行日志** 落到 `output/.video_runs/<clip_id>.json`，记录 task_id、prompt、status、cost、artifacts，便于断点续跑。

## 7. 工程结构

```
tools/video/
  generate_clip.py         # 单 clip 调 MiniMax，含轮询 + 下载
  render_titles.py         # PIL 渲染中文标题 PNG / 序列帧
  compose_final.py         # ffmpeg 拼接 10 个 clip + 叠加标题
  prompts/
    A1_aerial.txt
    A2_fake_smile.txt
    B1_alarm.txt
    B2_monitor.txt
    B3_boss_pass.txt
    B4_npc_pan.txt
    B5_hr_pass.txt
    B6_coffee_decay.txt
    B7_floor_lights_off.txt
    C1_static.txt

output/
  clips/<clip_id>.mp4      # MiniMax 原始下载
  titles/*.png             # PIL 渲染产物
  opening_v01.mp4          # 最终拼接

output/.video_runs/        # gitignore
  <clip_id>.json           # 调度状态
```

## 8. 预算与执行

- **目标成本**: ¥60 上限（含重试）。MiniMax-Hailuo-2.3 1080P 6s 单 clip ≈ ¥3-5。
- **环境变量**: `MINIMAX_API_KEY` 用户已在 `~/.zshrc` 中配置。
- **依赖**: Python 3, `requests`, `Pillow`, ffmpeg。
- **执行节奏**: 顺序生成（不并发），MiniMax 端轮询间隔 10s。10 个 clip 估计总耗时 30-60 分钟（含等待 MiniMax 渲染）。

## 9. 验收标准

- [ ] `output/opening_v01.mp4` 存在，时长 60s ± 1s
- [ ] 1920x1080, h264, ≥30fps
- [ ] 10 段分镜全部到位，可视识别故事弧
- [ ] 标题"优秀员工 → 活过第 X 集"反转动画清晰可读
- [ ] 像素硬保留段（B1-B7）画面无明显抗锯齿模糊（人工核验）
- [ ] 总成本日志 ≤ ¥60

## 10. 不在范围

- 音频（BGM / SFX / 配音）
- 字幕翻译版本
- 游戏 logo 设计
- Steam 主页 trailer 适配（这是开场过场，非营销 trailer）

## 11. 关联

- 视觉规范: `assets/sprites/STYLE_GUIDE.md`
- 项目背景: `CLAUDE.md`, `README.md`
- 资源清单: `assets/sprites/test_outputs/` + `assets/sprites/{character,npc,hud,scenes,maps}/`
