@tool
class_name AssetCatalog
extends Resource

@export var entries: Dictionary[StringName, Resource] = {}


func get_asset(asset_id: StringName) -> Resource:
	return entries.get(String(asset_id)) as Resource


func has_asset(asset_id: StringName) -> bool:
	return get_asset(asset_id) != null
