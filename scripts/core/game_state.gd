class_name GameState
extends RefCounted

const SAVE_VERSION := 2

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
		"case_records": {},
		"day_results": {},
		"dictionary_unlocked_stage": 1,
		"dictionary_current_page": 0,
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
	data["case_records"] = (data.get("case_records", {}) as Dictionary).duplicate(true)
	data["day_results"] = (data.get("day_results", {}) as Dictionary).duplicate(true)
	if not (data["case_records"] as Dictionary).has("case_salt_elder_day01") and not String(data.get("case_verdict", "")).is_empty():
		(data["case_records"] as Dictionary)["case_salt_elder_day01"] = {
			"verdict": String(data.get("case_verdict", "")),
			"understanding_delta": int(data.get("case_understanding", 0)),
		}


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


func record_case(case_id: String, verdict: String, understanding_delta: int) -> void:
	(data["case_records"] as Dictionary)[case_id] = {
		"verdict": verdict,
		"understanding_delta": understanding_delta,
	}
	data["case_verdict"] = verdict
	data["case_understanding"] = int(data.get("case_understanding", 0)) + understanding_delta
