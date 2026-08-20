class_name DictionaryTimelinePanel
extends ColorRect

class TimelineScrubber:
	extends Control

	signal stage_selected(stage_index: int)

	var unlocked_count := 1
	var current_index := 0
	var interaction_enabled := true
	var marker_texture: Texture2D
	var track_texture: Texture2D
	var _dragging := false
	var _drag_position := 0.0


	func _ready() -> void:
		custom_minimum_size = Vector2(520, 100)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		queue_redraw()


	func configure(unlocked: int, selected: int, marker: Texture2D, track: Texture2D) -> void:
		unlocked_count = clampi(unlocked, 1, 3)
		current_index = clampi(selected, 0, unlocked_count - 1)
		_drag_position = float(current_index)
		marker_texture = marker
		track_texture = track
		tooltip_text = "时间标志尚未解锁" if unlocked_count <= 1 else "拖动时间标志并松手，切换词典时间页"
		queue_redraw()


	func set_current(index: int) -> void:
		current_index = clampi(index, 0, unlocked_count - 1)
		_drag_position = float(current_index)
		queue_redraw()


	func _gui_input(event: InputEvent) -> void:
		if not interaction_enabled or unlocked_count <= 1:
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_update_drag_position(event.position.x)
				accept_event()
			else:
				if not _dragging:
					return
				_dragging = false
				_update_drag_position(event.position.x)
				var selected := clampi(roundi(_drag_position), 0, unlocked_count - 1)
				_drag_position = float(selected)
				queue_redraw()
				stage_selected.emit(selected)
				accept_event()
		elif event is InputEventMouseMotion and _dragging:
			_update_drag_position(event.position.x)
			accept_event()


	func _update_drag_position(mouse_x: float) -> void:
		var usable_width := maxf(size.x - 56.0, 1.0)
		var normalized := clampf((mouse_x - 28.0) / usable_width, 0.0, 1.0)
		_drag_position = minf(normalized * 2.0, float(unlocked_count - 1))
		queue_redraw()


	func _draw() -> void:
		var left := 28.0
		var right := size.x - 28.0
		var center_y := size.y * 0.56
		var track_rect := Rect2(left, center_y - 12.0, right - left, 24.0)
		if track_texture != null:
			draw_texture_rect(track_texture, track_rect, false)
		else:
			draw_line(Vector2(left, center_y), Vector2(right, center_y), Color(0.55, 0.39, 0.20), 6.0, true)
		for index in 3:
			var x := lerpf(left, right, float(index) / 2.0)
			var unlocked := index < unlocked_count
			draw_circle(Vector2(x, center_y), 10.0, Color(0.88, 0.68, 0.32) if unlocked else Color(0.25, 0.23, 0.21))
			draw_string(get_theme_default_font(), Vector2(x - 7.0, center_y - 24.0), str(index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.86, 0.78, 0.64) if unlocked else Color(0.38, 0.36, 0.33))
		var marker_x := lerpf(left, right, _drag_position / 2.0)
		if marker_texture != null:
			var marker_size := Vector2(64, 64)
			draw_texture_rect(marker_texture, Rect2(Vector2(marker_x, center_y) - marker_size * 0.5, marker_size), false)
		else:
			draw_circle(Vector2(marker_x, center_y), 20.0, Color(0.96, 0.76, 0.35) if interaction_enabled else Color(0.48, 0.43, 0.36))
			draw_circle(Vector2(marker_x, center_y), 10.0, Color(0.16, 0.11, 0.07))


signal closed(current_page: int)
signal page_action_requested(page_index: int, action_id: String)
signal page_clicked(page_index: int)

var _catalog: AssetCatalog
var _definition: Dictionary
var _page_asset_ids: Array = []
var _transition_asset_ids: Dictionary = {}
var _current_page := 0
var _requested_page := 0
var _unlocked_count := 1
var _animating := false
var _animation_frames: SpriteFrames
var _animation_name: StringName = &"default"
var _animation_frame := 0
var _animation_elapsed := 0.0
var _animation_target := 0

var _page_texture: TextureRect
var _page_placeholder: Label
var _page_label: Label
var _unlock_label: Label
var _scrubber: TimelineScrubber
var _page_action_id := ""


func _ready() -> void:
	visible = false
	color = Color(0.01, 0.01, 0.01, 0.88)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	set_process(false)


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1500, 940)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	var title := Label.new()
	title.text = "官方词典第四版"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	title.modulate = Color(0.92, 0.75, 0.42)
	box.add_child(title)
	var page_panel := PanelContainer.new()
	page_panel.custom_minimum_size = Vector2(1380, 670)
	page_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(page_panel)
	var page_layer := Control.new()
	page_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	page_layer.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	page_layer.tooltip_text = "选择相机后，点击当前词典页面进行拍摄"
	page_layer.gui_input.connect(_on_page_gui_input)
	page_panel.add_child(page_layer)
	_page_texture = TextureRect.new()
	_page_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_page_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_page_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_layer.add_child(_page_texture)
	_page_placeholder = Label.new()
	_page_placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_page_placeholder.add_theme_font_size_override("font_size", 32)
	_page_placeholder.modulate = Color(0.68, 0.60, 0.48)
	_page_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_layer.add_child(_page_placeholder)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 18)
	box.add_child(footer)
	var status_box := VBoxContainer.new()
	status_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(status_box)
	_page_label = Label.new()
	_page_label.add_theme_font_size_override("font_size", 28)
	status_box.add_child(_page_label)
	_unlock_label = Label.new()
	_unlock_label.modulate = Color(0.66, 0.60, 0.52)
	status_box.add_child(_unlock_label)
	_scrubber = TimelineScrubber.new()
	_scrubber.stage_selected.connect(_on_stage_selected)
	footer.add_child(_scrubber)
	var close_button := Button.new()
	close_button.text = "收起词典"
	close_button.custom_minimum_size = Vector2(190, 58)
	close_button.pressed.connect(_close)
	footer.add_child(close_button)


func open_dictionary(definition: Dictionary, catalog: AssetCatalog, unlocked_stage: int, saved_page: int) -> void:
	_definition = definition
	_catalog = catalog
	_page_asset_ids = (definition.get("timeline_page_asset_ids", []) as Array).duplicate()
	if _page_asset_ids.is_empty():
		_page_asset_ids = (definition.get("page_asset_ids", []) as Array).duplicate()
	while _page_asset_ids.size() < 3:
		_page_asset_ids.append("")
	_transition_asset_ids = (definition.get("timeline_transition_asset_ids", {}) as Dictionary).duplicate(true)
	_page_action_id = String(definition.get("timeline_page_action_id", ""))
	_unlocked_count = clampi(unlocked_stage, 1, 3)
	_current_page = clampi(saved_page, 0, _unlocked_count - 1)
	_requested_page = _current_page
	_animating = false
	set_process(false)
	var marker := catalog.get_asset(StringName(String(definition.get("timeline_marker_asset_id", "")))) as Texture2D
	var track := catalog.get_asset(StringName(String(definition.get("timeline_track_asset_id", "")))) as Texture2D
	_scrubber.interaction_enabled = true
	_scrubber.configure(_unlocked_count, _current_page, marker, track)
	_show_page(_current_page)
	visible = true


func _on_stage_selected(stage_index: int) -> void:
	if _animating:
		return
	var target := clampi(stage_index, 0, _unlocked_count - 1)
	if target == _current_page:
		_scrubber.set_current(_current_page)
		return
	_requested_page = target
	_start_next_transition()


func _start_next_transition() -> void:
	if _requested_page == _current_page:
		_scrubber.interaction_enabled = true
		_scrubber.set_current(_current_page)
		return
	var next_page := _current_page + (1 if _requested_page > _current_page else -1)
	var transition_key := "%d_to_%d" % [_current_page + 1, next_page + 1]
	var transition_asset_id := String(_transition_asset_ids.get(transition_key, ""))
	var frames: SpriteFrames = null
	if not transition_asset_id.is_empty():
		frames = _catalog.get_asset(StringName(transition_asset_id)) as SpriteFrames
	if frames == null:
		_current_page = next_page
		_show_page(_current_page)
		_start_next_transition()
		return
	var animation_names := frames.get_animation_names()
	if animation_names.is_empty():
		_current_page = next_page
		_show_page(_current_page)
		_start_next_transition()
		return
	_animation_frames = frames
	_animation_name = &"default" if frames.has_animation(&"default") else StringName(animation_names[0])
	_animation_frame = 0
	_animation_elapsed = 0.0
	_animation_target = next_page
	_animating = true
	_scrubber.interaction_enabled = false
	_page_texture.texture = frames.get_frame_texture(_animation_name, 0)
	_page_texture.visible = _page_texture.texture != null
	_page_placeholder.visible = false
	set_process(true)


func _process(delta: float) -> void:
	if not _animating or _animation_frames == null:
		return
	_animation_elapsed += delta
	var speed := maxf(_animation_frames.get_animation_speed(_animation_name), 0.01)
	var duration := maxf(_animation_frames.get_frame_duration(_animation_name, _animation_frame) / speed, 0.01)
	while _animation_elapsed >= duration:
		_animation_elapsed -= duration
		_animation_frame += 1
		if _animation_frame >= _animation_frames.get_frame_count(_animation_name):
			_complete_transition()
			return
		_page_texture.texture = _animation_frames.get_frame_texture(_animation_name, _animation_frame)
		duration = maxf(_animation_frames.get_frame_duration(_animation_name, _animation_frame) / speed, 0.01)


func _complete_transition() -> void:
	_animating = false
	set_process(false)
	_current_page = _animation_target
	_animation_frames = null
	_show_page(_current_page)
	_start_next_transition()


func _show_page(index: int) -> void:
	_current_page = clampi(index, 0, 2)
	var asset_id := String(_page_asset_ids[_current_page])
	var texture: Texture2D = null
	if not asset_id.is_empty():
		texture = _catalog.get_asset(StringName(asset_id)) as Texture2D
	_page_texture.texture = texture
	_page_texture.visible = texture != null
	_page_placeholder.visible = texture == null
	_page_placeholder.text = "[待替换词典时间页 %d]\n%s" % [_current_page + 1, asset_id]
	_page_label.text = "当前时间页：%d / 3" % (_current_page + 1)
	_unlock_label.text = "已解锁 %d / 3 个时间刻度" % _unlocked_count
	_scrubber.set_current(_current_page)


func _close() -> void:
	if _animating:
		return
	visible = false
	closed.emit(_current_page)


func _request_page_action() -> void:
	if _animating:
		return
	page_clicked.emit(_current_page)


func _on_page_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_request_page_action()
		accept_event()
