@tool
class_name SceneHotspot
extends Button

@export var hotspot_id: StringName
@export var display_label := "可交互物品"
@export var visual_asset_id: StringName
@export var visual_region := Rect2()
@export var destination_location_id: StringName

var _feedback_tween: Tween
var _press_origin_position := Vector2.ZERO


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	button_down.connect(_play_press_feedback)
	button_up.connect(_play_release_feedback)
	resized.connect(_refresh_pivot)
	_refresh_pivot.call_deferred()


func _refresh_pivot() -> void:
	pivot_offset = size * 0.5


func _play_press_feedback() -> void:
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_press_origin_position = position
	_feedback_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(self, "scale", Vector2(0.96, 0.96), 0.08)
	_feedback_tween.tween_property(self, "position", _press_origin_position + Vector2(0.0, 4.0), 0.08)
	_feedback_tween.tween_property(self, "self_modulate", Color(1.2, 1.2, 1.2, 1.0), 0.08)


func _play_release_feedback() -> void:
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feedback_tween.set_parallel(true)
	_feedback_tween.tween_property(self, "scale", Vector2(1.045, 1.045), 0.09)
	_feedback_tween.tween_property(self, "position", _press_origin_position, 0.09)
	_feedback_tween.tween_property(self, "self_modulate", Color.WHITE, 0.09)
	_feedback_tween.chain().tween_property(self, "scale", Vector2.ONE, 0.10)


func configure(has_background: bool, visual_texture: Texture2D = null) -> void:
	tooltip_text = display_label
	var displayed_texture: Texture2D = visual_texture
	if visual_texture != null and visual_region.size.x > 0.0 and visual_region.size.y > 0.0:
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = visual_texture
		atlas_texture.region = visual_region
		displayed_texture = atlas_texture
	icon = displayed_texture
	expand_icon = visual_texture != null
	text = "" if has_background or visual_texture != null else display_label
	add_theme_font_size_override("font_size", 24)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.14, 0.10, 0.06, 0.0 if has_background else 0.82)
	normal.border_color = Color(0.86, 0.65, 0.28, 0.0 if has_background else 0.95)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.72, 0.47, 0.12, 0.18 if has_background else 0.92)
	hover.border_color = Color(1.0, 0.78, 0.34, 0.95)
	hover.set_border_width_all(4)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("focus", hover)

	var pressed_style := hover.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color(0.95, 0.68, 0.22, 0.30)
	add_theme_stylebox_override("pressed", pressed_style)

	var disabled_style := normal.duplicate() as StyleBoxFlat
	disabled_style.bg_color = Color(0.08, 0.08, 0.08, 0.0 if has_background else 0.55)
	disabled_style.border_color = Color(0.35, 0.35, 0.35, 0.0 if has_background else 0.75)
	add_theme_stylebox_override("disabled", disabled_style)
