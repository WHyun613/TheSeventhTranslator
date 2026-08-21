# 第七名译者

Godot 4.7.1 文字解谜游戏。目前已完成第一天、第二天与第三天的可玩纵向切片，正式美术和音频使用占位回退。

地点采用 1920×1080 全屏场景图，玩家直接点击图片中的物品进行调查；物品栏、任务提示、对白、文档、案卷与设置作为独立 UI 浮层显示在场景上方，交互结构接近《逆转裁判》的调查部分。

## 运行

1. 用 Godot 4.7.1 打开本目录的 `project.godot`。
2. 按 F6/F5 运行主场景。
3. 从“新游戏”开始；“继续游戏”读取最近一次自动存档。

## GitHub 协作与自动化

- Godot 长期分支：`godot-main`；远程 `main` 继续保留原 Unity 项目。
- 功能开发从 `godot-main` 新建分支，并通过 Pull Request 合回 `godot-main`。
- GitHub Actions 会用 Godot 4.7.1 完成 headless 导入和 Day 1、Day 2 冒烟测试，并为通过测试的分支推送生成源码 artifact。
- 具体约定见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 第一天内容

- 镇外玉米叶与马车夫引入。
- 镇外与译者房间使用可在 Godot 2D 编辑器中直接调整的透明场景热点。
- 译者房间可切入独立的“译者桌”场景，在桌面查看老人案卷和可扩展翻页的图片词典。
- Tomas 入职对白结束后自动展示玩家目标。
- 《官方词典第四版》、玩家目标、物品栏与文档查看。
- 卖盐老人案卷。
- 抽屉中的旧文和 mari 纸条。
- 物品栏旁提供译者推理台 UI 入口；当前推理内容仍支持点击选择或拖入槽位。
- 蓝章通过、红章存疑、黑章禁用。
- 两条结算路线、案件理解度和 Day 2 转场。
- 自动存档与中断恢复。

## 第二天内容

- Tomas 交付卖盐老人详细案卷，案卷附件可取得现行边界田地照片。
- 译者房间新增室外出口；街道、树林、档案室大门与档案室内部组成可往返调查路线。
- Marina 初见、小男孩扒窃事件、老人照片与后续对话。
- 小男孩的画、钱包、旧信、旧地图与黑章调查。
- “画 + 旧信”固定推出“手掌 = 守护”；“田地照片 + 旧地图”固定推出“边界发生变化”。
- 证据不会消耗且可复用；两项结论齐全后解锁红章存疑。
- 第二天通过/存疑双结局、累计理解度与自动进入 Day 3。

## 第三天内容

- Tomas 交付补偿协议；玩家检查被划掉的缺口圆并与 Marina 对照。
- 记录相机可拍摄老人旧协议、当前词典和三年前词典，照片作为独立推理证据。
- 物品栏是可反复点击展开/收起的右侧抽屉；拍摄词典时需要先在物品栏选择相机，再点击词典当前呈现页。
- 临时羁押室新增老人原住民语对白，默认乱码、悬停显示译文。
- “官方协议 + 老人旧协议照片”固定推出结论 04，并解锁词典第二时间刻度。
- “当前词典照片 + 历史词典照片 + Day 1 Marina 纸条”固定推出结论 05。
- 第三天新旧协议调查、相机拍摄、悬停翻译、词典历史页解锁、三证据推理与双结局。

## 重要文件

- 开发计划：[DAY1_PLAN_AND_ARCHITECTURE.md](DAY1_PLAN_AND_ARCHITECTURE.md)
- 资产教程：[ASSET_REPLACEMENT_GUIDE.md](ASSET_REPLACEMENT_GUIDE.md)
- 第一日内容：`content/days/day_01/day_01.tres`
- 第二日内容：`content/days/day_02/day_02.tres`
- 第三日内容：`content/days/day_03/day_03.tres`
- 第三日策划提取：[DAY3_CONTENT_DESIGN.md](DAY3_CONTENT_DESIGN.md)
- 资产映射：`content/catalogs/asset_catalog.tres`
- 主场景：`scenes/app/main.tscn`
- 主流程：`scripts/app/main.gd`
- 自动化流程测试：`tests/day01_smoke_test.gd`、`tests/day02_smoke_test.gd`、`tests/day03_smoke_test.gd`

## 当前策划暂定值

- 蓝章 = 通过，红章 = 存疑，黑章 = 用途未知。
- “旧文 1 + mari 纸条”得出“老人没有非法越境”。
- 案卷当前只有一项实际争议译文，不重复显示策划表里的三条相同占位项。
- `c`、`%` 暂代缺口圆和足迹字形。

## 开发测试入口

游戏设置页的“开发测试”区域提供“测试：直接进入第三天”。确认后会覆盖当前自动存档，建立包含《官方词典第四版》、玩家目标和 Day 1 Marina 纸条的 D3 测试状态，再从 Tomas 的第三天开场开始。

这个入口不参与正式日程。需要移除时，只删除 `scripts/ui/settings_panel.gd` 与 `scripts/app/main.gd` 中所有 `DEV DAY 3 SHORTCUT START` 到对应 `DEV DAY 3 SHORTCUT END` 之间的区块；Day 1、Day 2、Day 3 正式流程和自动测试均不依赖该接口。
