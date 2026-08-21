extends SceneTree

const MAIN_SCENE := preload("res://scenes/app/main.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("[Day2 Smoke] " + message)


func _finish_dialogues(main: Node) -> void:
	var safety := 0
	while main._dialogue.visible and safety < 100:
		main._dialogue._advance()
		safety += 1
	_check(safety < 100, "对白没有在安全步数内结束。")


func _close_document(main: Node) -> void:
	if main._document_viewer.visible:
		main._document_viewer._close()


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	# DEV DAY 2 SHORTCUT START — 删除测试入口时，将下一行改回 main._show_day_two() 即可。
	_check(main._settings._debug_day2_button != null, "设置面板缺少直接进入 D2 的测试按钮。")
	main._debug_start_day_two()
	# DEV DAY 2 SHORTCUT END
	_check(ContentValidator.validate_day(main.content.current_day, main.content.ASSET_CATALOG).is_empty(), "Day 2 内容静态校验未通过。")
	_check(String(main.state.data["current_day"]) == "day_02", "没有切换到 Day 2 内容包。")
	_check(String(main.state.data["current_location"]) == "translator_desk", "Day 2 没有从译者桌开始。")
	_finish_dialogues(main)
	_check(bool(main.state.flag("day02_case_received", false)), "Tomas 对话后没有交付详细案卷。")
	_close_document(main)
	_check(main._tutorial_label.text != "打开译者桌上的详细案卷，取得田地照片。", "已删除的案卷 review 提示仍然显示。")

	main._current_location_view.hotspot_by_id("case_file").pressed.emit()
	_check(main._case_review.visible, "详细案卷热点没有打开案件界面。")
	_check(main._case_review._question_button.disabled, "没有两项结论时存疑章不应可用。")
	main._case_review._request_attachment()
	_check(main.state.has_item("item_day02_field_photo"), "案卷附件没有发放田地照片。")
	_close_document(main)

	main._current_location_view.hotspot_by_id("translator_room").pressed.emit()
	_check(main._current_location_view.hotspot_by_id("exit_to_street").visible, "Day 2 译者房间没有启用室外出口。")
	main._current_location_view.hotspot_by_id("exit_to_street").pressed.emit()
	_finish_dialogues(main)
	_check(main._document_viewer.visible and main._document_viewer._document_id == "day02_elder_photo", "Marina 初见没有展示老人照片。")
	_close_document(main)
	_finish_dialogues(main)
	_check(bool(main.state.flag("day02_street_event_complete", false)), "街道扒窃事件没有完整结束。")
	_check(main._current_location_view.hotspot_by_id("boy_drawing").icon != null, "小男孩的画没有显示场景图片。")
	_check(main._current_location_view.hotspot_by_id("wallet").icon != null, "钱包没有显示场景图片。")
	_check(main._current_location_view.hotspot_by_id("cloth_bag").icon != null, "破布袋没有显示场景图片。")

	main._current_location_view.hotspot_by_id("boy_drawing").pressed.emit()
	_check(main._document_viewer._content_grid.columns == 1, "小男孩的画没有切换为大图加下方说明布局。")
	_check(main._document_viewer._art_panel.custom_minimum_size.x >= 900.0, "小男孩的画详情图没有占据文档主体宽度。")
	_check(main._document_viewer._body_label.visible, "小男孩的画下方说明文字被隐藏。")
	_close_document(main)
	main._current_location_view.hotspot_by_id("wallet").pressed.emit()
	_close_document(main)
	_check(main.state.has_item("item_day02_boy_drawing"), "没有取得小男孩的画。")
	_check(main.state.has_item("item_day02_wallet"), "没有取得 Marina 的钱包。")

	main._current_location_view.hotspot_by_id("to_woods").pressed.emit()
	var return_to_street: SceneHotspot = main._current_location_view.hotspot_by_id("to_street")
	_check(return_to_street.icon != null, "树林中返回街道的场景物品没有显示 IMG_0289 资产。")
	_check(return_to_street.position.x >= 1000.0 and return_to_street.position.y >= 700.0, "返回街道的场景物品没有移动到画面下方红框位置。")
	return_to_street.pressed.emit()
	_check(String(main.state.data["current_location"]) == "day02_street", "点击树林场景物品后没有返回街道。")
	main._current_location_view.hotspot_by_id("to_woods").pressed.emit()
	main._current_location_view.hotspot_by_id("to_archive_entrance").pressed.emit()
	_check(main._current_location_view.hotspot_by_id("archive_door").icon != null, "档案室大门没有显示 IMG_0274 场景资产。")
	main._current_location_view.hotspot_by_id("archive_door").pressed.emit()
	_check(String(main.state.data["current_location"]) == "day02_archive_interior", "无法进入档案室内部。")
	main._current_location_view.hotspot_by_id("paper_stack").pressed.emit()
	_close_document(main)
	main._current_location_view.hotspot_by_id("old_map").pressed.emit()
	_close_document(main)
	_check(main.state.has_item("item_day02_old_letter"), "纸堆没有发放旧信。")
	_check(main.state.has_item("item_day02_old_map"), "墙面热点没有发放旧地图。")

	main._open_reasoning()
	main._reasoning._set_slot(0, "item_day02_boy_drawing")
	main._reasoning._set_slot(1, "item_day02_old_letter")
	main._reasoning._combine()
	_check(main.state.has_conclusion("conclusion_day02_hand_protects"), "画与旧信没有推出手掌=守护。")
	_close_document(main)
	main._open_reasoning()
	main._reasoning._set_slot(0, "item_day02_field_photo")
	main._reasoning._set_slot(1, "item_day02_old_map")
	main._reasoning._combine()
	_check(main.state.has_conclusion("conclusion_day02_border_changed"), "田地照片与旧地图没有推出边界变化。")
	_close_document(main)
	_check(main.state.has_item("item_day02_boy_drawing") and main.state.has_item("item_day02_old_map"), "推理错误消耗了证据。")

	main._go_day02_location("translator_desk")
	main._current_location_view.hotspot_by_id("case_file").pressed.emit()
	_check(not main._case_review._question_button.disabled, "两项结论齐全后存疑章仍不可用。")
	main._case_review._select_verdict("QUESTION")
	main._case_review._confirm_submit()
	_finish_dialogues(main)
	_check(bool(main.state.flag("day02_complete", false)), "存疑路线没有完成 Day 2。")
	_check(int(main.state.data["case_understanding"]) == 1, "Day 2 存疑路线没有累计理解度。")
	_check(String(main.state.data["current_day"]) == "day_03", "Day 2 结束后没有进入 Day 3。")
	_check(main._game_screen.visible, "Day 2 结束后没有显示 Day 3 游戏场景。")

	var migrated := GameState.new()
	migrated.load_from_dict({"save_version":1,"current_day":"day_01","current_location":"translator_room","case_understanding":1,"case_verdict":"QUESTION","flags":{},"inventory":[],"conclusions":[]})
	_check((migrated.data["case_records"] as Dictionary).has("case_salt_elder_day01"), "旧存档没有迁移 Day 1 案件记录。")

	if _failures.is_empty():
		print("DAY02_SMOKE_TEST_OK")
		quit(0)
	else:
		print("DAY02_SMOKE_TEST_FAILED: %d" % _failures.size())
		quit(1)
