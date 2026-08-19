extends SceneTree

const MAIN_SCENE := preload("res://scenes/app/main.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("[Day1 Smoke] " + message)


func _finish_visible_dialogue(main: Node) -> void:
	var safety := 0
	while main._dialogue.visible and safety < 100:
		main._dialogue._advance()
		safety += 1
	_check(safety < 100, "对白未能在安全步数内结束。")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	_check(main.content.body_font() != null, "用户提供的中文字体未加载。")
	_check(ContentValidator.validate_day(main.content.current_day, main.content.ASSET_CATALOG).is_empty(), "Day 1 内容静态校验未通过。")

	main._new_game()
	_check(String(main.state.data["current_location"]) == "town_outskirts", "新游戏没有从镇外开始。")
	_check(main._current_location_view != null, "镇外全屏地点场景没有实例化。")
	_check(main._current_location_view.hotspot_by_id("corn_leaf") != null, "镇外缺少玉米叶场景热点。")
	_check(main._current_location_view.hotspot_by_id("enter_town") != null, "镇外缺少入镇场景热点。")
	main._current_location_view.hotspot_by_id("enter_town").pressed.emit()
	_check(main._dialogue.visible, "入镇后没有触发 Tomas 入职对白。")
	_finish_visible_dialogue(main)
	_check(main._location_title.text == "译者房间", "地点界面没有显示“译者房间”。")
	_check(main._current_location_view.hotspot_by_id("dictionary") == null, "译者房间仍然存在词典场景热点。")
	_check(main._current_location_view.hotspot_by_id("reasoning_table") == null, "译者房间仍然存在推理台场景热点。")
	_check(main._current_location_view.hotspot_by_id("drawer") != null, "译者房间缺少抽屉场景热点。")
	_check(main._current_location_view.hotspot_by_id("office_door") == null, "译者房间仍然存在 Tomas 门场景热点。")
	_check(main._current_location_view.hotspot_by_id("case_file") == null, "译者房间仍然存在老人案卷场景热点。")
	_check(main._current_location_view.hotspot_by_id("translator_desk") != null, "译者房间缺少进入译者桌的热点。")
	_check(main._reasoning_button != null, "物品栏旁边没有译者推理台 UI 入口。")
	_check(main.state.has_item("item_official_dictionary_v4"), "入职后没有获得官方词典。")
	_check(main.content.document("official_dictionary").size() > 0, "词典数据被意外删除。")
	_check(main.content.ASSET_CATALOG.entries.has(&"stamp_approve"), "缺少蓝章美术资源接口。")
	_check(main.content.ASSET_CATALOG.entries.has(&"stamp_question"), "缺少红章美术资源接口。")
	_check(main.content.ASSET_CATALOG.entries.has(&"stamp_unknown"), "缺少黑章美术资源接口。")
	_check(main.content.ASSET_CATALOG.entries.has(&"bg_translator_desk"), "缺少译者桌背景资源接口。")
	_check(int(main.state.flag("tutorial_stage", 0)) == 3, "入职后没有进入玩家目标步骤。")
	_check(main._document_viewer.visible and main._document_viewer._document_id == "player_objective", "Tomas 对话结束后没有自动打开玩家目标。")
	main._document_viewer._close()
	await process_frame
	_check(main._dialogue.visible, "教学完成后没有触发案件交付对白。")
	_finish_visible_dialogue(main)
	_check(bool(main.state.flag("case_salt_elder_received", false)), "没有记录案件已领取。")
	_check(main._document_viewer.visible, "领取案件后没有显示找线索提示。")
	main._document_viewer._close()
	_check(not main._case_review.visible, "关闭提示后不应自动打开案件复核。")
	main._current_location_view.hotspot_by_id("translator_desk").pressed.emit()
	_check(String(main.state.data["current_location"]) == "translator_desk", "点击桌面没有进入译者桌场景。")
	_check(main._current_location_view.hotspot_by_id("case_file") != null, "译者桌缺少老人案卷热点。")
	_check(main._current_location_view.hotspot_by_id("dictionary") != null, "译者桌缺少官方词典热点。")
	main._current_location_view.hotspot_by_id("dictionary").pressed.emit()
	_check(main._document_viewer.visible and not main._document_viewer._body_label.visible, "官方词典没有使用纯美术页面查看模式。")
	_check(main._document_viewer._page_navigation.visible, "官方词典没有预留翻页接口。")
	main._document_viewer._close()
	main._current_location_view.hotspot_by_id("case_file").pressed.emit()
	_check(main._case_review.visible, "点击译者桌上的案卷没有打开案件复核。")
	main._case_review._close()
	main._current_location_view.hotspot_by_id("translator_room").pressed.emit()
	_check(String(main.state.data["current_location"]) == "translator_room", "无法从译者桌返回译者房间。")

	main._current_location_view.hotspot_by_id("drawer").pressed.emit()
	_check(main.state.has_item("item_day01_old_text"), "抽屉没有发放旧文。")
	_check(main.state.has_item("item_day01_marina_note"), "抽屉没有发放纸条。")
	main._document_viewer._close()
	_check(main._document_viewer.visible, "旧文关闭后没有继续显示纸条。")
	main._document_viewer._close()

	main._reasoning_button.pressed.emit()
	main._reasoning._toggle_clue("item_day01_old_text")
	_check("item_day01_old_text" in main._reasoning._selected, "点击线索没有选中推理材料。")
	main._reasoning._toggle_clue("item_day01_old_text")
	main._reasoning._set_slot(0, "item_day01_old_text")
	main._reasoning._set_slot(1, "item_day01_marina_note")
	main._reasoning._combine()
	_check(main.state.has_conclusion("conclusion_day01_no_illegal_crossing"), "正确组合没有生成结论。")
	main._document_viewer._close()

	main._current_location_view.hotspot_by_id("translator_desk").pressed.emit()
	main._current_location_view.hotspot_by_id("case_file").pressed.emit()
	_check(not main._case_review._question_button.disabled, "获得结论后存疑章仍不可用。")
	main._case_review._select_verdict("QUESTION")
	main._case_review._confirm_submit()
	_finish_visible_dialogue(main)
	_check(bool(main.state.flag("day01_complete", false)), "存疑路线没有完成 Day 1。")
	_check(int(main.state.data["case_understanding"]) == 1, "存疑路线理解度不是 1。")
	_check(main._day_summary_screen.visible, "Day 1 完成后没有显示日终总结。")

	main.state.reset()
	main.state.data["current_location"] = "translator_room"
	main.state.set_flag("case_salt_elder_received")
	main._on_verdict_confirmed("APPROVE")
	main._dialogue.visible = false
	main._dialogue_blocker.visible = false
	main.state.load_from_dict(main.save_service.load_state())
	main._resume_progress()
	_check(main._dialogue.visible, "提交后中断读档没有重播结算对白。")
	_finish_visible_dialogue(main)
	_check(int(main.state.data["case_understanding"]) == 0, "通过路线理解度不是 0。")
	_check(String(main.state.data["case_verdict"]) == "APPROVE", "通过路线没有保存语义判定。")

	var restored := GameState.new()
	restored.load_from_dict(main.save_service.load_state())
	_check(bool(restored.flag("day01_complete", false)), "自动存档无法恢复 Day 1 完成状态。")
	_check(String(restored.data["case_verdict"]) == "APPROVE", "自动存档没有恢复案件判定。")

	var recipe_board := ReasoningBoard.new()
	root.add_child(recipe_board)
	await process_frame
	var reusable_items := ["evidence_a", "evidence_b", "evidence_c", "evidence_d"]
	var reusable_definitions := {
		"evidence_a": {"name": "证据 A", "reasoning": true, "asset_id": ""},
		"evidence_b": {"name": "证据 B", "reasoning": true, "asset_id": ""},
		"evidence_c": {"name": "证据 C", "reasoning": true, "asset_id": ""},
		"evidence_d": {"name": "证据 D", "reasoning": true, "asset_id": ""},
	}
	var reusable_puzzle := {"recipes": [
		{"required_clues": ["evidence_a", "evidence_b"], "conclusion_id": "test_conclusion_two"},
		{"required_clues": ["evidence_a", "evidence_c", "evidence_d"], "conclusion_id": "test_conclusion_three"},
	]}
	var emitted_conclusions: Array[String] = []
	recipe_board.solved.connect(func(conclusion_id: String) -> void: emitted_conclusions.append(conclusion_id))
	recipe_board.open_board(reusable_items, reusable_definitions, reusable_puzzle, [], main.content.ASSET_CATALOG)
	_check(recipe_board._slot_labels.size() == 3, "推理台没有提供三个证据槽位。")
	recipe_board._toggle_clue("evidence_a")
	recipe_board._toggle_clue("evidence_b")
	recipe_board._combine()
	_check(emitted_conclusions == ["test_conclusion_two"], "固定双证据配方没有得出对应结论。")
	recipe_board.open_board(reusable_items, reusable_definitions, reusable_puzzle, emitted_conclusions, main.content.ASSET_CATALOG)
	recipe_board._toggle_clue("evidence_a")
	recipe_board._toggle_clue("evidence_c")
	recipe_board._toggle_clue("evidence_d")
	recipe_board._combine()
	_check(emitted_conclusions == ["test_conclusion_two", "test_conclusion_three"], "证据没有在三证据配方中复用，或固定配方匹配错误。")
	_check(reusable_items == ["evidence_a", "evidence_b", "evidence_c", "evidence_d"], "推理后证据被意外消耗。")

	if _failures.is_empty():
		print("DAY01_SMOKE_TEST_OK")
		quit(0)
	else:
		print("DAY01_SMOKE_TEST_FAILED: %d" % _failures.size())
		quit(1)
