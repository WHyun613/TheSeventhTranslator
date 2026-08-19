# Godot 远程协作约定

本仓库的 Godot 长期协作分支为 `godot-main`。Unity 项目继续保留在远程 `main` 分支，两套工程不互相合并。

## 开发环境

- Godot `4.7.1.stable`。
- 项目入口：`project.godot`。
- 逻辑画布：1920×1080。
- 文本文件统一使用 UTF-8 和 LF。

## 分支与提交

1. 从最新 `godot-main` 创建功能分支，例如 `feature/day-02-street`。
2. 不直接向 `godot-main` 强制推送，也不要把 Godot 分支合并进 Unity `main`。
3. 提交 `.gd.uid`、源资源旁的 `.import`、`.tres` 和 `.tscn`。
4. 不提交 `.godot/`、测试截图、构建产物和本地自动存档。
5. `DAY2_PLAN_AND_ARCHITECTURE.md` 按当前项目约定只保留在本地，不上传远程。

## 提交前检查

在项目根目录执行：

```text
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/day01_smoke_test.gd
```

第二条命令成功时会输出 `DAY01_SMOKE_TEST_OK` 并以状态码 0 结束。

## Pull Request

- PR 的目标分支选择 `godot-main`。
- 描述改动影响的场景、状态字段与资产 ID。
- 涉及视觉热点时附一张 1280×720 或 1920×1080 截图。
- CI 必须通过；缺少正式美术时应保持占位回退可通关。

## 自动化

`.github/workflows/godot-ci.yml` 会在向 `godot-main` 推送、提交 PR 或手动运行时：

1. 下载官方 Godot 4.7.1 Linux 编辑器。
2. 以 headless 模式导入并校验工程资源。
3. 运行 Day 1 冒烟流程测试。
4. 对非 PR 运行生成一份通过测试的源码 ZIP artifact，保留 14 天。

当前工程还没有 `export_presets.cfg`，所以流水线暂不生成 Windows 可执行文件；确定正式导出平台和签名方式后再增加二进制发布任务。
