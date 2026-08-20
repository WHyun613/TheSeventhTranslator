class_name SaveService
extends RefCounted

const SAVE_DIR := "user://saves"
const SAVE_PATH := SAVE_DIR + "/slot_01.json"
const TEMP_PATH := SAVE_DIR + "/slot_01.tmp"
const BACKUP_PATH := SAVE_DIR + "/slot_01.bak"


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_state(state: GameState) -> Error:
	var absolute_dir := ProjectSettings.globalize_path(SAVE_DIR)
	var make_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if make_error != OK and make_error != ERR_ALREADY_EXISTS:
		return make_error

	var temp_file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if temp_file == null:
		return FileAccess.get_open_error()
	temp_file.store_string(JSON.stringify(state.to_dict(), "\t"))
	temp_file.flush()
	temp_file.close()

	var absolute_save := ProjectSettings.globalize_path(SAVE_PATH)
	var absolute_temp := ProjectSettings.globalize_path(TEMP_PATH)
	var absolute_backup := ProjectSettings.globalize_path(BACKUP_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(absolute_save, absolute_backup)
		var remove_error := DirAccess.remove_absolute(absolute_save)
		if remove_error != OK:
			return remove_error
	return DirAccess.rename_absolute(absolute_temp, absolute_save)


func load_state() -> Dictionary:
	if not has_save():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}
