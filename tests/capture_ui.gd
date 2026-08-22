extends SceneTree

const MAIN_SCENE := preload("res://scenes/app/main.tscn")


func _init() -> void:
	call_deferred("_run")


func _capture(name: String) -> void:
	var directory := ProjectSettings.globalize_path("res://tests/artifacts")
	DirAccess.make_dir_recursive_absolute(directory)
	var image := root.get_texture().get_image()
	var error := image.save_png("res://tests/artifacts/%s.png" % name)
	if error != OK:
		push_error("截图保存失败：%s" % error)


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_capture("main_menu")
	main._new_game()
	await process_frame
	_capture("town_outskirts")
	main._enter_town()
	await process_frame
	_capture("tomas_onboarding")
	while main._dialogue.is_playing():
		main._dialogue._advance()
	await process_frame
	_capture("player_objective_auto")
	main._document_viewer._close()
	await process_frame
	while main._dialogue.is_playing():
		main._dialogue._advance()
	main._document_viewer._close()
	await process_frame
	main._current_location_view.hotspot_by_id("translator_desk").pressed.emit()
	await process_frame
	_capture("translator_desk")
	main._current_location_view.hotspot_by_id("dictionary").pressed.emit()
	await process_frame
	_capture("dictionary_art_pages")
	main._document_viewer._close()
	main._current_location_view.hotspot_by_id("case_file").pressed.emit()
	await process_frame
	_capture("case_without_evidence")
	main._case_review._close()
	main._current_location_view.hotspot_by_id("translator_room").pressed.emit()
	main._open_drawer()
	main._document_viewer._close()
	main._document_viewer._close()
	main._reasoning_button.pressed.emit()
	await process_frame
	_capture("reasoning_board")
	main._reasoning._toggle_clue("item_day01_old_text")
	main._reasoning._toggle_clue("item_day01_marina_note")
	main._reasoning._combine()
	main._document_viewer._close()
	main._current_location_view.hotspot_by_id("translator_desk").pressed.emit()
	main._current_location_view.hotspot_by_id("case_file").pressed.emit()
	await process_frame
	_capture("case_with_evidence")
	main._case_review._select_verdict("QUESTION")
	main._case_review._confirm_submit()
	while main._dialogue.is_playing():
		main._dialogue._advance()
	await process_frame
	_capture("day_summary")
	quit(0)
