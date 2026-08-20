@tool
class_name LocationView
extends Control

signal hotspot_activated(hotspot_id: String)

@export var location_id := ""
@export var background_asset_id := ""
@export_tool_button("从 AssetCatalog 刷新背景预览") var refresh_preview_action := _refresh_editor_preview

@onready var background: TextureRect = $Background
@onready var fallback: ColorRect = $Fallback
@onready var fallback_label: Label = $Fallback/FallbackLabel
@onready var hotspot_layer: Control = $HotspotLayer


func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
	else:
		for child in hotspot_layer.get_children():
			if child is SceneHotspot:
				var hotspot := child as SceneHotspot
				hotspot.pressed.connect(_on_hotspot_pressed.bind(String(hotspot.hotspot_id)))


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready():
		return
	var catalog := load("res://content/catalogs/asset_catalog.tres") as AssetCatalog
	var preview_texture: Texture2D = null
	if catalog != null:
		preview_texture = catalog.get_asset(background_asset_id) as Texture2D
	configure(preview_texture, location_id, catalog)


func configure(texture: Texture2D, title: String, catalog: AssetCatalog = null) -> void:
	background.texture = texture
	background.visible = texture != null
	fallback.visible = texture == null
	fallback_label.text = "%s\n\n[ 全屏场景图待替换 ]\n%s" % [title, background_asset_id]
	for child in hotspot_layer.get_children():
		if child is SceneHotspot:
			var hotspot := child as SceneHotspot
			var visual_texture: Texture2D = null
			if catalog != null and not hotspot.visual_asset_id.is_empty():
				visual_texture = catalog.get_asset(hotspot.visual_asset_id) as Texture2D
			hotspot.configure(texture != null, visual_texture)


func set_hotspot_visible(id: String, value: bool) -> void:
	var hotspot := hotspot_by_id(id)
	if hotspot != null:
		hotspot.visible = value


func set_hotspot_enabled(id: String, value: bool) -> void:
	var hotspot := hotspot_by_id(id)
	if hotspot != null:
		hotspot.disabled = not value


func hotspot_by_id(id: String) -> SceneHotspot:
	for child in hotspot_layer.get_children():
		if child is SceneHotspot and String((child as SceneHotspot).hotspot_id) == id:
			return child as SceneHotspot
	return null


func _on_hotspot_pressed(id: String) -> void:
	hotspot_activated.emit(id)
