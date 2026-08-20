class_name ContentDB
extends RefCounted

const DAY_01: DayDefinition = preload("res://content/days/day_01/day_01.tres")
const DAY_02: DayDefinition = preload("res://content/days/day_02/day_02.tres")
const DAY_03: DayDefinition = preload("res://content/days/day_03/day_03.tres")
const ASSET_CATALOG: AssetCatalog = preload("res://content/catalogs/asset_catalog.tres")

var current_day: DayDefinition = DAY_01
var _days := {
	"day_01": DAY_01,
	"day_02": DAY_02,
	"day_03": DAY_03,
}


func set_current_day(day_id: String) -> bool:
	if not _days.has(day_id):
		return false
	current_day = _days[day_id] as DayDefinition
	return true


func day(day_id: String) -> DayDefinition:
	return _days.get(day_id, DAY_01) as DayDefinition


func dialogue(dialogue_id: String) -> Array:
	return current_day.dialogues.get(dialogue_id, []) as Array


func document(document_id: String) -> Dictionary:
	if current_day.documents.has(document_id):
		return current_day.documents.get(document_id, {}) as Dictionary
	for definition in _days.values():
		var day_definition := definition as DayDefinition
		if day_definition.documents.has(document_id):
			return day_definition.documents.get(document_id, {}) as Dictionary
	return {}


func item(item_id: String) -> Dictionary:
	if current_day.items.has(item_id):
		return current_day.items.get(item_id, {}) as Dictionary
	for definition in _days.values():
		var day_definition := definition as DayDefinition
		if day_definition.items.has(item_id):
			return day_definition.items.get(item_id, {}) as Dictionary
	return {}


func all_items() -> Dictionary:
	var merged := {}
	for definition in _days.values():
		merged.merge((definition as DayDefinition).items, true)
	return merged


func location(location_id: String) -> Dictionary:
	return current_day.locations.get(location_id, {}) as Dictionary


func asset(asset_id: StringName) -> Resource:
	return ASSET_CATALOG.get_asset(asset_id)


func asset_texture(asset_id: StringName) -> Texture2D:
	return asset(asset_id) as Texture2D


func body_font() -> Font:
	return asset(&"font_body_zh") as Font
