class_name DocumentViewer
extends ColorRect

signal closed(document_id: String)
signal action_requested(document_id: String, action_id: String)

var _document_id := ""
var _title_label: Label
var _body_label: RichTextLabel
var _content_grid: GridContainer
var _art_panel: PanelContainer
var _art_texture: TextureRect
var _art_label: Label
var _page_navigation: HBoxContainer
var _previous_page_button: Button
var _next_page_button: Button
var _page_label: Label
var _page_asset_ids: Array = []
var _page_index := 0
var _page_catalog: AssetCatalog
var _action_button: Button
var _action_id := ""


func _ready() -> void:
	visible = false
	color = Color(0.01, 0.01, 0.01, 0.78)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1080, 760)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 54)
	margin.add_theme_constant_override("margin_right", 54)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	margin.add_child(box)
	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 44)
	box.add_child(_title_label)
	_content_grid = GridContainer.new()
	_content_grid.columns = 2
	_content_grid.add_theme_constant_override("h_separation", 26)
	_content_grid.add_theme_constant_override("v_separation", 14)
	_content_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_content_grid)
	_art_panel = PanelContainer.new()
	_art_panel.custom_minimum_size = Vector2(300, 560)
	_art_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_grid.add_child(_art_panel)
	_art_texture = TextureRect.new()
	_art_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_art_texture.visible = false
	_art_panel.add_child(_art_texture)
	var art_center := CenterContainer.new()
	_art_panel.add_child(art_center)
	_art_label = Label.new()
	_art_label.custom_minimum_size = Vector2(250, 0)
	_art_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_art_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_art_label.modulate = Color(0.63, 0.56, 0.46)
	art_center.add_child(_art_label)
	_body_label = RichTextLabel.new()
	_body_label.bbcode_enabled = true
	_body_label.scroll_active = true
	_body_label.custom_minimum_size = Vector2(640, 560)
	_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_label.add_theme_font_size_override("normal_font_size", 29)
	_content_grid.add_child(_body_label)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 18)
	box.add_child(actions)
	_page_navigation = HBoxContainer.new()
	_page_navigation.add_theme_constant_override("separation", 14)
	actions.add_child(_page_navigation)
	_previous_page_button = Button.new()
	_previous_page_button.text = "上一页"
	_previous_page_button.pressed.connect(_change_page.bind(-1))
	_page_navigation.add_child(_previous_page_button)
	_page_label = Label.new()
	_page_label.custom_minimum_size = Vector2(110, 0)
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_page_navigation.add_child(_page_label)
	_next_page_button = Button.new()
	_next_page_button.text = "下一页"
	_next_page_button.pressed.connect(_change_page.bind(1))
	_page_navigation.add_child(_next_page_button)
	var close_button := Button.new()
	close_button.text = "收起文件"
	close_button.custom_minimum_size = Vector2(220, 56)
	close_button.pressed.connect(_close)
	actions.add_child(close_button)
	_page_navigation.visible = false
	_action_button = Button.new()
	_action_button.custom_minimum_size = Vector2(280, 56)
	_action_button.pressed.connect(_request_action)
	_action_button.visible = false
	actions.add_child(_action_button)


func open_document(document_id: String, title: String, body: String, asset_id: String = "", texture: Texture2D = null, action_id: String = "", action_label: String = "", presentation := "standard") -> void:
	_page_asset_ids.clear()
	_page_catalog = null
	_page_navigation.visible = false
	_document_id = document_id
	_title_label.text = title
	_body_label.visible = true
	_body_label.text = body
	_body_label.scroll_to_line(0)
	_art_texture.texture = texture
	_art_texture.visible = texture != null
	_art_panel.visible = texture != null
	_art_label.visible = false
	_art_label.text = "[待替换文档资产]\n" + asset_id
	_apply_document_presentation(presentation)
	_action_id = action_id
	_action_button.text = action_label if not action_label.is_empty() else "执行操作"
	_action_button.visible = not action_id.is_empty()
	visible = true


func open_image_document(document_id: String, title: String, page_asset_ids: Array, catalog: AssetCatalog) -> void:
	_document_id = document_id
	_title_label.text = title
	_body_label.visible = false
	_art_panel.visible = true
	_art_panel.custom_minimum_size = Vector2(920, 560)
	_art_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_grid.columns = 1
	_page_asset_ids = page_asset_ids.duplicate()
	_page_catalog = catalog
	_action_id = ""
	_action_button.visible = false
	_page_index = 0
	_page_navigation.visible = true
	_update_image_page()
	visible = true


func _apply_document_presentation(presentation: String) -> void:
	if presentation == "large_image_with_caption":
		_content_grid.columns = 1
		_art_panel.custom_minimum_size = Vector2(920, 410)
		_art_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_body_label.custom_minimum_size = Vector2(920, 105)
		_body_label.scroll_active = false
		return
	_content_grid.columns = 2
	_art_panel.custom_minimum_size = Vector2(300, 560)
	_art_panel.size_flags_horizontal = Control.SIZE_FILL
	_body_label.custom_minimum_size = Vector2(640, 560)
	_body_label.scroll_active = true


func _change_page(offset: int) -> void:
	_page_index = clampi(_page_index + offset, 0, maxi(_page_asset_ids.size() - 1, 0))
	_update_image_page()


func _update_image_page() -> void:
	var page_count := _page_asset_ids.size()
	var asset_id := ""
	var texture: Texture2D = null
	if page_count > 0:
		asset_id = String(_page_asset_ids[_page_index])
		if _page_catalog != null:
			texture = _page_catalog.get_asset(asset_id) as Texture2D
	_art_texture.texture = texture
	_art_texture.visible = texture != null
	_art_label.visible = texture == null
	_art_label.text = "[待替换词典页面资产]\n" + asset_id
	_page_label.text = "%d / %d" % [_page_index + 1 if page_count > 0 else 0, page_count]
	_previous_page_button.disabled = _page_index <= 0
	_next_page_button.disabled = _page_index >= page_count - 1


func _close() -> void:
	visible = false
	closed.emit(_document_id)


func _request_action() -> void:
	if _action_id.is_empty():
		return
	_action_button.visible = false
	action_requested.emit(_document_id, _action_id)
