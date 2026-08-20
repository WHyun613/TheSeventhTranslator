class_name InventoryPanel
extends ColorRect

signal closed
signal item_requested(item_id: String)

var _list: VBoxContainer
var _empty_label: Label
var _drawer_panel: PanelContainer


func _ready() -> void:
	visible = false
	color = Color.TRANSPARENT
	# 根节点不拦截场景和顶部按钮；只有右侧抽屉本身接收鼠标。
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()


func _build_ui() -> void:
	_drawer_panel = PanelContainer.new()
	_drawer_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_drawer_panel.anchor_bottom = 1.0
	_drawer_panel.offset_left = -610.0
	_drawer_panel.offset_top = 112.0
	_drawer_panel.offset_right = -24.0
	_drawer_panel.offset_bottom = -24.0
	_drawer_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_drawer_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	_drawer_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	var title := Label.new()
	title.text = "物品栏"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	box.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 12)
	scroll.add_child(_list)
	_empty_label = Label.new()
	_empty_label.text = "物品栏里还没有东西。"
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_list.add_child(_empty_label)
	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(180, 54)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(_close)
	box.add_child(close_button)


func open_inventory(item_ids: Array, item_definitions: Dictionary, catalog: AssetCatalog, selected_item_id := "") -> void:
	for child in _list.get_children():
		child.queue_free()
	if item_ids.is_empty():
		_empty_label = Label.new()
		_empty_label.text = "物品栏里还没有东西。"
		_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_list.add_child(_empty_label)
	else:
		for raw_id in item_ids:
			var item_id := String(raw_id)
			var definition := item_definitions.get(item_id, {}) as Dictionary
			var button := Button.new()
			var item_name := String(definition.get("name", item_id))
			button.text = "▶ %s（已选中）" % item_name if item_id == selected_item_id else item_name
			button.tooltip_text = String(definition.get("tooltip", ""))
			button.custom_minimum_size = Vector2(0, 62)
			var texture := catalog.get_asset(StringName(String(definition.get("asset_id", "")))) as Texture2D
			if texture != null:
				button.icon = texture
				button.expand_icon = true
			button.pressed.connect(_request_item.bind(item_id))
			_list.add_child(button)
	visible = true


func close_inventory() -> void:
	if visible:
		_close()


func _request_item(item_id: String) -> void:
	visible = false
	item_requested.emit(item_id)


func _close() -> void:
	visible = false
	closed.emit()
