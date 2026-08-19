class_name InventoryPanel
extends ColorRect

signal closed
signal item_requested(item_id: String)

var _list: VBoxContainer
var _empty_label: Label


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
	panel.custom_minimum_size = Vector2(900, 700)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	var title := Label.new()
	title.text = "物品栏"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	box.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(800, 500)
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


func open_inventory(item_ids: Array, item_definitions: Dictionary, catalog: AssetCatalog) -> void:
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
			button.text = String(definition.get("name", item_id))
			button.tooltip_text = String(definition.get("tooltip", ""))
			button.custom_minimum_size = Vector2(0, 62)
			var texture := catalog.get_asset(StringName(String(definition.get("asset_id", "")))) as Texture2D
			if texture != null:
				button.icon = texture
				button.expand_icon = true
			button.pressed.connect(_request_item.bind(item_id))
			_list.add_child(button)
	visible = true


func _request_item(item_id: String) -> void:
	visible = false
	item_requested.emit(item_id)


func _close() -> void:
	visible = false
	closed.emit()
