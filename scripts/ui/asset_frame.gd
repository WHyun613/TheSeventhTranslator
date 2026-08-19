class_name AssetFrame
extends PanelContainer

var asset_id: String = ""
var _texture_rect: TextureRect
var _placeholder_label: Label


func setup(id: String, texture: Texture2D, display_name: String, tint: Color, minimum: Vector2) -> void:
	asset_id = id
	custom_minimum_size = minimum
	for child in get_children():
		child.queue_free()

	var base := ColorRect.new()
	base.color = tint
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)

	if texture != null:
		_texture_rect = TextureRect.new()
		_texture_rect.texture = texture
		_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_texture_rect)
	else:
		var center := CenterContainer.new()
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(center)
		var box := VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		center.add_child(box)
		var title := Label.new()
		title.text = display_name
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 34)
		box.add_child(title)
		_placeholder_label = Label.new()
		_placeholder_label.text = "[待替换资产]\n" + id
		_placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_placeholder_label.modulate = Color(0.72, 0.66, 0.56)
		_placeholder_label.add_theme_font_size_override("font_size", 20)
		box.add_child(_placeholder_label)

