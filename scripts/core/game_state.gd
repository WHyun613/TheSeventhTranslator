class_name GameState
extends RefCounted

const SAVE_VERSION := 1

var data: Dictionary = {}


func _init() -> void:
	reset()


func reset() -> void:
	data = {
		"save_version": SAVE_VERSION,
		"content_version": 1,
		"current_day": "day_01",
		"current_location": "town_outskirts",
		"checkpoint": "day01_start",
		"flags": {},
		"inventory": [],
		"conclusions": [],
		"case_understanding": 0,
		"case_verdict": "",
		"play_seconds": 0.0,
	}


func load_from_dict(payload: Dictionary) -> void:
	reset()
	if payload.is_empty():
		return
	for key in data.keys():
		if payload.has(key):
			data[key] = payload[key]
	data["save_version"] = SAVE_VERSION
	data["flags"] = (data.get("flags", {}) as Dictionary).duplicate(true)
	data["inventory"] = (data.get("inventory", []) as Array).duplicate()
	data["conclusions"] = (data.get("conclusions", []) as Array).duplicate()


func to_dict() -> Dictionary:
	return data.duplicate(true)


func flag(flag_id: String, default_value: Variant = false) -> Variant:
	return (data["flags"] as Dictionary).get(flag_id, default_value)


func set_flag(flag_id: String, value: Variant = true) -> void:
	(data["flags"] as Dictionary)[flag_id] = value


func has_item(item_id: String) -> bool:
	return item_id in (data["inventory"] as Array)


func add_item(item_id: String) -> bool:
	if has_item(item_id):
		return false
	(data["inventory"] as Array).append(item_id)
	return true


func has_conclusion(conclusion_id: String) -> bool:
	return conclusion_id in (data["conclusions"] as Array)


func add_conclusion(conclusion_id: String) -> bool:
	if has_conclusion(conclusion_id):
		return false
	(data["conclusions"] as Array).append(conclusion_id)
	return true

