class_name ContentDB
extends RefCounted

const DAY_01: DayDefinition = preload("res://content/days/day_01/day_01.tres")
const ASSET_CATALOG: AssetCatalog = preload("res://content/catalogs/asset_catalog.tres")

var current_day: DayDefinition = DAY_01


func dialogue(dialogue_id: String) -> Array:
	return current_day.dialogues.get(dialogue_id, []) as Array


func document(document_id: String) -> Dictionary:
	return current_day.documents.get(document_id, {}) as Dictionary


func item(item_id: String) -> Dictionary:
	return current_day.items.get(item_id, {}) as Dictionary


func location(location_id: String) -> Dictionary:
	return current_day.locations.get(location_id, {}) as Dictionary


func asset(asset_id: StringName) -> Resource:
	return ASSET_CATALOG.get_asset(asset_id)


func asset_texture(asset_id: StringName) -> Texture2D:
	return asset(asset_id) as Texture2D


func body_font() -> Font:
	return asset(&"font_body_zh") as Font

