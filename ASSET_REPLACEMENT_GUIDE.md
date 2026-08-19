# 《第七名译者》资产替换指南

当前版本没有正式美术时也能完整通关。缺图会显示带资产 ID 的占位块；正文、案卷内容和对话不会烘焙在图片中。

## 1. 当前字体

你提供的 `res://迫真打字油印体.ttf` 已绑定到：

```text
font_body_zh
```

它已经用于主菜单、对白、文档、推理台和案卷界面，不需要移动或重命名。若今后换字体，只需修改 AssetCatalog 中这个条目。

发布游戏前请自行确认字体许可证允许随游戏分发。

## 2. 替换一张图片

1. 将 PNG、WebP 或 SVG 放进 `res://assets/` 下合适的目录。
2. 在 Godot 的 FileSystem 面板中打开：

   ```text
   res://content/catalogs/asset_catalog.tres
   ```

3. 在 Inspector 展开 `entries`。
4. 找到需要替换的资产 ID。
5. 将刚导入的图片从 FileSystem 面板拖到该 ID 右侧显示 `<empty>` 的 Resource 值栏（不要拖到左侧 ID 文本上）。
6. 保存 `asset_catalog.tres`，重新运行游戏。

如果 Inspector 正好在脚本更新前已经打开，请先选择另一个文件，再重新选择 `asset_catalog.tres`，让 Inspector 刷新强类型 Resource 栏位。

场景、剧情资源和脚本都只保存资产 ID，因此换文件名或换扩展名也只需改 Catalog 一处。

如果直接覆盖已经绑定的文件，并保持路径和扩展名不变，Godot 会自动重新导入，不必再次修改 Catalog。

## 3. 当前已经接通的资产

| 资产 ID | 推荐路径 | 显示位置 |
| --- | --- | --- |
| `bg_main_menu` | `assets/backgrounds/shared/main_menu.png` | 主菜单全屏背景 |
| `logo_game` | `assets/ui/branding/game_logo.png` | 主菜单标题；缺失时显示文字标题 |
| `bg_day01_town_outskirts` | `assets/backgrounds/day_01/town_outskirts.png` | 镇外路牌地点背景 |
| `bg_translator_room` | `assets/backgrounds/shared/translator_room.png` | 译者房间地点背景 |
| `bg_translator_desk` | `assets/backgrounds/shared/translator_desk.png` | 译者桌全屏场景背景 |
| `char_coachman_neutral` | `assets/characters/coachman/neutral.png` | 马车夫对白立绘 |
| `char_tomas_neutral` | `assets/characters/tomas/neutral.png` | Tomas 普通立绘 |
| `char_tomas_yawn` | `assets/characters/tomas/yawn.png` | 通过路线的 Tomas 立绘 |
| `char_tomas_concerned` | `assets/characters/tomas/concerned.png` | 存疑路线的 Tomas 立绘 |
| `doc_official_dictionary_v4` | `assets/documents/day_01/dictionary.png` | 词典阅读页左侧预览 |
| `doc_player_objective` | `assets/documents/day_01/player_objective.png` | 玩家目标阅读页左侧预览 |
| `doc_case_salt_elder` | `assets/documents/day_01/case_salt_elder.png` | 案件提示阅读页左侧预览 |
| `item_day01_old_text` | `assets/items/day_01/old_text.png` | 旧文详情、物品栏和推理线索 |
| `item_day01_marina_note` | `assets/items/day_01/marina_note.png` | 纸条详情、物品栏和推理线索 |
| `stamp_approve` | `assets/ui/stamps/approve.png` | 蓝色通过章按钮 |
| `stamp_question` | `assets/ui/stamps/question.png` | 红色存疑章按钮 |
| `stamp_unknown` | `assets/ui/stamps/unknown.png` | 黑色未知章按钮 |

`glyph_gap_circle`、`glyph_footprint`、抽屉前景、音效和 UI 皮肤 ID 已在 Catalog 预留。灰碑文暂时使用 `c`、`%` 占位。地点中的物品已经使用场景热点交互：缺少背景图时热点显示为带名称的占位框，绑定正式背景后热点平时透明、鼠标悬停时描边。

## 4. 推荐规格

| 类型 | 推荐规格 |
| --- | --- |
| 背景 | 1920×1080，PNG/WebP；重要内容放在中央安全区 |
| 对白半身立绘 | 透明 PNG/WebP，建议统一为 900×1200；人物脚底/腰部贴近画布底边，同一角色所有表情保持相同画布和锚点 |
| 文档预览 | 透明 PNG 或竖版纸张图，建议约 800×1100；不要把正文写进图里 |
| 物品图 | 透明 PNG/SVG，建议至少 512×512 |
| 印章 | 透明 PNG/SVG，建议至少 512×512；图案内部不要留过多空白 |
| Logo | 透明 PNG/SVG，横向构图，建议不小于 1200×360 |
| BGM/环境音 | OGG，可无缝循环 |
| 短音效 | WAV 或 OGG |

角色图片会作为约 760×1020 逻辑像素的大型透明半身立绘显示在画面左侧，从屏幕底部向上延伸；对话框覆盖在立绘下半部前方，不再使用框内头像。地点背景会按 1920×1080 的逻辑画布全屏显示。物品栏、设置、对白、文档、案卷和推理台等 UI 都是覆盖在场景上方的独立浮层。

## 5. 对齐场景中的可点击物品

背景图和热点区域是分开的，因此你可以先换图，再在 Godot 编辑器里把透明点击区域对准图片里的物品。

1. 先按第 2 节把背景绑定到 AssetCatalog。
2. 双击打开对应场景：
   - 镇外：`res://scenes/locations/day_01/town_outskirts.tscn`
   - 译者房间：`res://scenes/locations/shared/translator_room.tscn`
   - 译者桌：`res://scenes/locations/shared/translator_desk.tscn`
3. 在场景树展开 `HotspotLayer`，选择名字以 `hotspot_` 开头的节点。
4. 选中场景最上方的根节点；如果背景尚未出现，在 Inspector 点击“从 AssetCatalog 刷新背景预览”。场景每次重新打开时也会自动读取 Catalog。
5. 在 2D 视图中选择热点节点，拖动节点、调整四边大小，让矩形覆盖背景图中的实际物品。
6. 保存 `.tscn`，运行游戏并用鼠标逐个检查。

镇外现有热点是 `hotspot_corn_leaf`、`hotspot_enter_town`；译者房间现有热点是 `hotspot_objective_paper`、`hotspot_drawer`、`hotspot_translator_desk`；译者桌现有热点是 `hotspot_case_file`、`hotspot_dictionary`、`hotspot_return_room`。老人案卷和 Tomas 门已从房间热点移除，源数据仍保留；译者推理台已经移动到物品栏旁的 UI 入口。热点坐标只保存在这些场景节点中，不要在 AssetCatalog 或剧情数据中填写第二套坐标。

官方词典现在是纯图片翻页文档，不再显示程序内置正文。第一页使用 `doc_official_dictionary_v4`。未来增加页面时：先在 AssetCatalog 增加新的页面资产 ID，再把 ID 按顺序加入 `content/days/day_01/day_01.tres` 中 `official_dictionary.page_asset_ids` 数组；上一页、下一页和页码 UI 已经接好。

案卷界面的三枚印章分别读取 `stamp_approve`、`stamp_question`、`stamp_unknown`。把三张美术图拖进 AssetCatalog 对应条目即可，无需修改案卷场景。

译者推理台的数据使用 `puzzle_data.recipes` 数组。每个配方包含唯一的 `conclusion_id` 和固定的 `required_clues`，证据数量只能是 2 或 3。证据顺序不影响匹配，推理成功不会删除证据；同一证据可以继续写入其他配方。新增结论时还需要在 `items` 和 `documents` 中登记对应结论卡与查看内容。

建议不要把对话框、任务文字或按钮画进背景图。场景图只负责房间和物品；UI 会始终浮在最上层。

编辑器中的背景是从 AssetCatalog 自动生成的预览，不需要把同一张图片再拖进地点场景。更换 Catalog 图片后点击刷新按钮即可。

## 6. 导入设置建议

- UI、印章、文字图和灰碑文字形使用无损压缩。
- 普通大背景可根据包体使用有损压缩。
- UI 和文档图通常关闭 mipmap。
- 手绘平滑风格保留纹理过滤；像素风则统一关闭过滤。
- 不要编辑 `.godot/imported/` 或 `.import` 文件，它们由 Godot 自动维护。
- 不要把正文直接画进词典、案卷或纸条图片，否则以后改字和本地化会很困难。

## 7. 替换后的检查

每次集中换图后至少检查：

1. 主菜单 Logo 和背景没有拉伸。
2. 马车夫、Tomas 的不同表情切换时人物不会跳动。
3. 文档预览没有挤压右侧正文。
4. 旧文和纸条在物品栏及推理台上能正常显示。
5. 三枚印章仍能看清文字，其中黑章保持禁用。
6. 在 1920×1080、1600×900 和 1280×720 窗口下检查一次。
7. 每个场景热点都能点中正确物品，缩放窗口后热点不会偏离背景。

## 8. 第二天资产填入表

第二天仍使用同一个 `res://content/catalogs/asset_catalog.tres`。把图片先复制进 `res://assets/`，等待 Godot 导入完成，再把“文件系统”面板中的图片资源拖到下列 `entries` 对应值上。不要把图片拖到 Key 文本上。

| Asset ID | 推荐放置路径 | 使用位置 |
| --- | --- | --- |
| `bg_day02_street` | `assets/backgrounds/day_02/street.png` | 小镇街道全屏背景 |
| `bg_day02_woods` | `assets/backgrounds/day_02/woods.png` | 树林全屏背景 |
| `bg_day02_archive_entrance` | `assets/backgrounds/day_02/archive_entrance.png` | 档案室大门背景 |
| `bg_day02_archive_interior` | `assets/backgrounds/day_02/archive_interior.png` | 档案室内部背景 |
| `char_marina_neutral` | `assets/characters/marina/neutral.png` | Marina 普通半身立绘 |
| `char_marina_urgent` | `assets/characters/marina/urgent.png` | Marina 紧张/追赶半身立绘 |
| `char_mystery_boy_neutral` | `assets/characters/mystery_boy/neutral.png` | 神秘男孩半身立绘 |
| `prop_day02_case_detailed` | `assets/items/day_02/case_detailed.png` | 第二天译者桌上的案卷物品 |
| `prop_day02_boy_drawing` | `assets/items/day_02/boy_drawing_scene.png` | 街道地面上的画 |
| `prop_day02_wallet` | `assets/items/day_02/wallet_scene.png` | 街道地面上的钱包 |
| `prop_day02_bag` | `assets/items/day_02/cloth_bag_scene.png` | 街道地面上的破布袋 |
| `prop_day02_paper_stack` | `assets/items/day_02/paper_stack.png` | 档案室纸堆 |
| `prop_day02_old_map` | `assets/items/day_02/old_map_scene.png` | 档案室墙面旧地图 |
| `prop_day02_black_stamp` | `assets/items/day_02/black_stamp_scene.png` | 档案室黑章 |
| `item_day02_field_photo` | `assets/documents/day_02/field_photo.png` | 案卷附件与推理证据 |
| `item_day02_boy_drawing` | `assets/documents/day_02/boy_drawing.png` | 画的物品栏详情 |
| `item_day02_wallet` | `assets/documents/day_02/wallet.png` | 钱包详情 |
| `item_day02_old_letter` | `assets/documents/day_02/old_letter.png` | 旧信详情与推理证据 |
| `item_day02_old_map` | `assets/documents/day_02/old_map.png` | 旧地图详情与推理证据 |
| `doc_day02_elder_photo` | `assets/documents/day_02/elder_photo.png` | Marina 对话中的老人照片 |
| `doc_dictionary_hand_unlocked` | `assets/documents/day_02/dictionary_hand.png` | 得出“手掌=守护”后解锁的词典第二页 |
| `conclusion_day02_hand_protects` | `assets/documents/day_02/conclusion_hand.png` | 结论 02 卡片 |
| `conclusion_day02_border_changed` | `assets/documents/day_02/conclusion_border.png` | 结论 03 卡片 |

田地照片必须画清“现行边界”，旧地图必须画清“过去较小的边界”；小男孩的画应能看出手掌正在保护玉米田、挡住红色雨滴。否则逻辑虽然可以运行，玩家却无法仅凭图像理解推理。

## 9. 第二天热点对齐路径

打开场景、选择根节点并点击“从 AssetCatalog 刷新背景预览”，然后在 `HotspotLayer` 下移动矩形：

- 译者房间室外出口：`res://scenes/locations/shared/translator_room.tscn` → `hotspot_exit_to_street`。它在 D1 自动隐藏，D2 自动启用。
- 第二天案卷与词典：`res://scenes/locations/shared/translator_desk.tscn` → `hotspot_case_file`、`hotspot_dictionary`。D2 会自动把案卷图切换为 `prop_day02_case_detailed`。
- 街道：`res://scenes/locations/day_02/street.tscn` → 画、钱包、布袋、树林出口和房间出口。
- 树林：`res://scenes/locations/day_02/woods.tscn` → 街道出口和档案室方向。
- 档案室大门：`res://scenes/locations/day_02/archive_entrance.tscn` → 大门和树林出口。
- 档案室内部：`res://scenes/locations/day_02/archive_interior.tscn` → 纸堆、旧地图、黑章和出口。

第二天正文、物品、地点与推理配方集中在 `res://content/days/day_02/day_02.tres`。更换图片只改 AssetCatalog，不需要改这个数据文件；只有调整正文、配方或增加新词典页时才编辑它。
