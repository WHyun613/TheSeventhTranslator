class_name ContentValidator
extends RefCounted


static func validate_day(day: DayDefinition, catalog: AssetCatalog) -> PackedStringArray:
	var issues := PackedStringArray()
	if day == null:
		issues.append("DayDefinition 无法加载。")
		return issues
	if day.day_id.is_empty():
		issues.append("DayDefinition.day_id 为空。")
	var required_dialogues := ["coachman_intro", "tomas_onboarding", "tomas_case_intro", "tomas_verdict_approve", "tomas_verdict_question"]
	if String(day.day_id) == "day_02":
		required_dialogues = ["day02_tomas_briefing", "day02_marina_intro", "day02_pickpocket", "day02_marina_leave", "day02_marina_return", "day02_verdict_approve", "day02_verdict_question"]
	elif String(day.day_id) == "day_03":
		required_dialogues = ["day03_tomas_briefing", "day03_marina_review", "day03_marina_detention_plan", "day03_elder_warning", "day03_elder_agreement", "day03_verdict_approve", "day03_verdict_question"]
	for dialogue_id in required_dialogues:
		if not day.dialogues.has(dialogue_id) or (day.dialogues[dialogue_id] as Array).is_empty():
			issues.append("缺少必需对白：%s" % dialogue_id)
	for item_id in day.items:
		var item := day.items[item_id] as Dictionary
		var document_id := String(item.get("document_id", ""))
		if not document_id.is_empty() and not day.documents.has(document_id):
			issues.append("物品 %s 引用了不存在的文档 %s" % [item_id, document_id])
		_validate_asset_reference(String(item.get("asset_id", "")), "物品 %s" % item_id, catalog, issues)
	for document_id in day.documents:
		var document := day.documents[document_id] as Dictionary
		_validate_asset_reference(String(document.get("asset_id", "")), "文档 %s" % document_id, catalog, issues)
		for page_asset_id in document.get("page_asset_ids", []) as Array:
			_validate_asset_reference(String(page_asset_id), "文档 %s 页面" % document_id, catalog, issues)
		for page_asset_id in document.get("timeline_page_asset_ids", []) as Array:
			_validate_asset_reference(String(page_asset_id), "时间轴词典 %s 页面" % document_id, catalog, issues)
		_validate_asset_reference(String(document.get("timeline_marker_asset_id", "")), "时间轴词典 %s 标志" % document_id, catalog, issues)
		_validate_asset_reference(String(document.get("timeline_track_asset_id", "")), "时间轴词典 %s 轨道" % document_id, catalog, issues)
		for transition_asset_id in (document.get("timeline_transition_asset_ids", {}) as Dictionary).values():
			_validate_asset_reference(String(transition_asset_id), "时间轴词典 %s 逐帧动画" % document_id, catalog, issues)
	for location_id in day.locations:
		var location := day.locations[location_id] as Dictionary
		_validate_asset_reference(String(location.get("asset_id", "")), "地点 %s" % location_id, catalog, issues)
	var recipes := day.puzzle_data.get("recipes", []) as Array
	if recipes.is_empty() and day.puzzle_data.has("required_clues"):
		recipes = [day.puzzle_data]
	for recipe_value in recipes:
		var recipe := recipe_value as Dictionary
		var required_clues := recipe.get("required_clues", []) as Array
		if required_clues.size() < 2 or required_clues.size() > 3:
			issues.append("推理配方必须包含 2—3 条证据。")
		var unique_clues := {}
		for clue_id in required_clues:
			var clue_key := String(clue_id)
			if not day.items.has(clue_key):
				issues.append("推理引用了不存在的线索：%s" % clue_key)
			if unique_clues.has(clue_key):
				issues.append("同一推理配方重复引用证据：%s" % clue_key)
			unique_clues[clue_key] = true
		var conclusion_id := String(recipe.get("conclusion_id", ""))
		if conclusion_id.is_empty() or not day.items.has(conclusion_id):
			issues.append("推理结论物品不存在：%s" % conclusion_id)
	for required_conclusion in day.case_data.get("question_required_conclusions", []) as Array:
		if not day.items.has(String(required_conclusion)):
			issues.append("案卷存疑条件引用了不存在的结论：%s" % String(required_conclusion))
	if not catalog.entries.has("font_body_zh") or catalog.get_asset(&"font_body_zh") == null:
		issues.append("发布字体 font_body_zh 未绑定。")
	return issues


static func _validate_asset_reference(asset_id: String, owner: String, catalog: AssetCatalog, issues: PackedStringArray) -> void:
	if asset_id.is_empty():
		return
	if not catalog.entries.has(asset_id):
		issues.append("%s 引用了未登记资产：%s" % [owner, asset_id])
