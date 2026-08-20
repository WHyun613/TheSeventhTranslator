@tool
class_name SceneHotspot
extends Button

@export var hotspot_id: StringName
@export var display_label := "可交互物品"
@export var visual_asset_id: StringName
@export var visual_region := Rect2()


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL


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
