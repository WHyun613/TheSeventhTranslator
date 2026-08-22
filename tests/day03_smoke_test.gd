extends SceneTree

const MAIN_SCENE := preload("res://scenes/app/main.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("[Day3 Smoke] " + message)


func _wait_for_location_transition(main: Node) -> void:
	var safety := 0
	while main._location_transition_in_progress and safety < 240:
		await process_frame
		safety += 1
	_check(safety < 240, "场景出口转场没有在安全时间内结束。")


func _finish_dialogues(main: Node) -> void:
	var safety := 0
	while main._dialogue.is_playing() and safety < 120:
		main._dialogue._advance()
		safety += 1
	_check(safety < 120, "对白没有在安全步数内结束。")


func _close_document(main: Node) -> void:
	if main._document_viewer.visible:
		main._document_viewer._close()


func _prepare_day_three(main: Node) -> void:
	main.state.reset()
	main.state.set_flag("day01_complete")
	main.state.set_flag("day02_complete")
	main.state.add_item("item_official_dictionary_v4")
	main.state.add_item("item_player_objective")
	main.state.add_item("item_day01_marina_note")
	main.state.data["case_understanding"] = 2
	main._show_day_three()


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	_prepare_day_three(main)
	_check(ContentValidator.validate_day(main.content.current_day, main.content.ASSET_CATALOG).is_empty(), "Day 3 内容静态校验未通过。")
	_check(String(main.state.data["current_day"]) == "day_03", "没有切换到 Day 3 内容包。")
	_check(String(main.state.data["current_location"]) == "translator_desk", "Day 3 没有从译者桌开始。")
	_finish_dialogues(main)
	_check(bool(main.state.flag("day03_case_received", false)), "Tomas 对话后没有交付 D3 补充案卷。")
	_check(main._current_location_view.hotspot_by_id("camera").visible, "译者桌没有显示记录相机热点。")

	main._current_location_view.hotspot_by_id("case_file").pressed.emit()
	_check(main._case_review.visible, "D3 案卷热点没有打开案件复核。")
	_check(main._case_review._question_button.disabled, "未完成结论 05 时红章不应可用。")
	main._case_review._request_attachment()
	_check(main.state.has_item("item_day03_official_agreement"), "案卷附件没有发放官方协议。")
	_check(main._document_viewer._document_id == "day03_official_agreement", "官方协议没有打开。")
	main._document_viewer._request_action()
	_check(bool(main.state.flag("day03_gap_inspected", false)), "没有记录被划掉的缺口圆检查结果。")
	_close_document(main)

	main._current_location_view.hotspot_by_id("camera").pressed.emit()
	_check(main.state.has_item("item_day03_camera"), "记录相机没有进入物品栏。")
	main._toggle_inventory()
	_check(main._inventory.visible, "点击物品栏按钮后没有展开物品栏。")
	main._toggle_inventory()
	_check(not main._inventory.visible, "再次点击物品栏按钮后没有收起物品栏。")
	main._current_location_view.hotspot_by_id("translator_room").pressed.emit()
	await _wait_for_location_transition(main)
	main._current_location_view.hotspot_by_id("exit_to_street").pressed.emit()
	await _wait_for_location_transition(main)
	_finish_dialogues(main)
	_check(bool(main.state.flag("day03_detention_route_unlocked", false)), "Marina 对话没有解锁临时羁押处路线。")
	_check(main._current_location_view.hotspot_by_id("to_detention").visible, "街道没有显示临时羁押处热点。")

	main._current_location_view.hotspot_by_id("to_detention").pressed.emit()
	await _wait_for_location_transition(main)
	_check(String(main.state.data["current_location"]) == "day03_detention_room", "无法进入临时羁押室。")
	_check(not main._dialogue._hover_translation.is_empty(), "老人原住民语对白没有配置悬停译文。")
	main._dialogue._show_hover_translation()
	_check("译文" in main._dialogue._text_label.text, "悬停后没有显示翻译文本。")
	main._dialogue._restore_raw_text()
	_finish_dialogues(main)
	_check(bool(main.state.flag("day03_elder_conversation_complete", false)), "老人和 Marina 的羁押室对白没有完成。")
	_check(main._current_location_view.hotspot_by_id("elder_agreement").visible, "老人对话后没有显示旧协议热点。")

	main._current_location_view.hotspot_by_id("elder_agreement").pressed.emit()
	main._document_viewer._request_action()
	_check(main.state.has_item("item_day03_elder_agreement_photo"), "相机没有生成老人旧协议照片。")
	_close_document(main)

	main._open_reasoning()
	main._reasoning._set_slot(0, "item_day03_official_agreement")
	main._reasoning._set_slot(1, "item_day03_elder_agreement_photo")
	main._reasoning._combine()
	_check(main.state.has_conclusion("conclusion_day03_dictionary_history_available"), "新旧协议没有推出结论 04。")
	_check(int(main.state.data["dictionary_unlocked_stage"]) == 2, "结论 04 没有解锁词典第二时间刻度。")
	_close_document(main)

	main._go_day03_location("translator_desk")
	main._open_dictionary()
	main._dictionary_timeline._request_page_action()
	_check(not main.state.has_item("item_day03_current_dictionary_photo"), "未选择相机时仍然拍摄了当前词典页。")
	main._on_inventory_item_requested("item_day03_camera")
	main._dictionary_timeline._request_page_action()
	_check(main.state.has_item("item_day03_current_dictionary_photo"), "没有拍摄当前官方词典页。")
	_close_document(main)
	main._open_dictionary()
	main._dictionary_timeline._on_stage_selected(1)
	main._on_inventory_item_requested("item_day03_camera")
	main._dictionary_timeline._request_page_action()
	_check(main.state.has_item("item_day03_historical_dictionary_photo"), "没有拍摄三年前官方词典页。")
	_close_document(main)

	main._open_reasoning()
	main._reasoning._set_slot(0, "item_day03_current_dictionary_photo")
	main._reasoning._set_slot(1, "item_day03_historical_dictionary_photo")
	main._reasoning._set_slot(2, "item_day01_marina_note")
	main._reasoning._combine()
	_check(main.state.has_conclusion("conclusion_day03_dictionary_tampered"), "三项固定证据没有推出结论 05。")
	_check(main.state.has_item("item_day01_marina_note"), "推理错误消耗了 Marina 的纸条。")
	_close_document(main)

	main._open_case()
	_check(not main._case_review._question_button.disabled, "结论 05 完成后红章仍不可用。")
	main._case_review._select_verdict("QUESTION")
	main._case_review._confirm_submit()
	_finish_dialogues(main)
	main._day03_question_confirmation.canceled.emit()
	_check(not bool(main.state.flag("day03_case_submitted", false)), "选择再考虑一下却误提交了案卷。")
	main._case_review._close()

	main._open_case()
	main._case_review._select_verdict("QUESTION")
	main._case_review._confirm_submit()
	_finish_dialogues(main)
	main._finalize_day03_question()
	_finish_dialogues(main)
	_check(bool(main.state.flag("day03_complete", false)), "红章路线没有完成 Day 3。")
	_check(int(main.state.data["case_understanding"]) == 3, "Day 3 存疑路线没有累计案件理解度。")
	_check(main._day_two_screen.visible, "Day 3 结束后没有进入 Day 4 占位页。")

	main.queue_free()
	await process_frame
	var approve_main := MAIN_SCENE.instantiate()
	root.add_child(approve_main)
	await process_frame
	_prepare_day_three(approve_main)
	_finish_dialogues(approve_main)
	approve_main._open_case()
	approve_main._case_review._select_verdict("APPROVE")
	approve_main._case_review._confirm_submit()
	_finish_dialogues(approve_main)
	_check(bool(approve_main.state.flag("day03_complete", false)), "蓝章最短路线没有完成 Day 3。")
	_check(int(approve_main.state.data["case_understanding"]) == 2, "蓝章路线不应增加案件理解度。")

	if _failures.is_empty():
		print("DAY03_SMOKE_TEST_OK")
		quit(0)
	else:
		print("DAY03_SMOKE_TEST_FAILED: %d" % _failures.size())
		quit(1)
