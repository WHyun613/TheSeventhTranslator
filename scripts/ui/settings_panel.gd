class_name SettingsPanel
extends ColorRect

signal settings_applied(settings: Dictionary)
signal closed

var _volume_slider: HSlider
var _speed_option: OptionButton
var _fullscreen_check: CheckButton


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
	panel.custom_minimum_size = Vector2(720, 580)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_bottom", 40)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	margin.add_child(box)
	var title := Label.new()
	title.text = "设置"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	box.add_child(title)
	var volume_label := Label.new()
	volume_label.text = "主音量"
	box.add_child(volume_label)
	_volume_slider = HSlider.new()
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 1.0
	_volume_slider.step = 0.05
	box.add_child(_volume_slider)
	var speed_label := Label.new()
	speed_label.text = "对话文字速度"
	box.add_child(speed_label)
	_speed_option = OptionButton.new()
	_speed_option.add_item("慢", 0)
	_speed_option.add_item("标准", 1)
	_speed_option.add_item("快", 2)
	_speed_option.add_item("瞬间显示", 3)
	box.add_child(_speed_option)
	_fullscreen_check = CheckButton.new()
	_fullscreen_check.text = "全屏"
	box.add_child(_fullscreen_check)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 18)
	box.add_child(buttons)
	var apply_button := Button.new()
	apply_button.text = "应用"
	apply_button.custom_minimum_size = Vector2(180, 56)
	apply_button.pressed.connect(_apply)
	buttons.add_child(apply_button)
	var close_button := Button.new()
	close_button.text = "取消"
	close_button.custom_minimum_size = Vector2(180, 56)
	close_button.pressed.connect(_close)
	buttons.add_child(close_button)


func open_settings(settings: Dictionary) -> void:
	_volume_slider.value = float(settings.get("master_volume", 0.8))
	var speed := float(settings.get("text_speed", 52.0))
	_speed_option.select(0 if speed <= 28.0 else 1 if speed <= 60.0 else 2 if speed < 500.0 else 3)
	_fullscreen_check.button_pressed = bool(settings.get("fullscreen", false))
	visible = true


func _apply() -> void:
	var speeds := [26.0, 52.0, 96.0, 9999.0]
	settings_applied.emit({
		"master_volume": _volume_slider.value,
		"text_speed": speeds[_speed_option.selected],
		"fullscreen": _fullscreen_check.button_pressed,
	})
	visible = false


func _close() -> void:
	visible = false
	closed.emit()
