class_name SettingsService
extends RefCounted

const SETTINGS_PATH := "user://settings.json"

var data: Dictionary = {
	"master_volume": 0.8,
	"text_speed": 52.0,
	"fullscreen": false,
}


func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		apply()
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		apply()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		for key in data.keys():
			if parsed.has(key):
				data[key] = parsed[key]
	apply()


func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	apply()


func apply() -> void:
	var volume := clampf(float(data.get("master_volume", 0.8)), 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.001)))
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if bool(data.get("fullscreen", false))
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
