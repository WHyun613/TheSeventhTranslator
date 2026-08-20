class_name CaseReviewPanel
extends ColorRect

signal verdict_confirmed(verdict: String)
signal attachment_requested(action_id: String)
signal closed

var _case_body: RichTextLabel
var _approve_button: Button
var _question_button: Button
var _unknown_button: Button
var _submit_button: Button
var _requirement_label: Label
var _confirmation: ConfirmationDialog
var _attachment_button: Button
var _current_case_title := "案件"
var _selected_verdict := ""


func _ready() -> void:
	visible = false
	color = Color(0.01, 0.01, 0.01, 0.84)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1180, 830)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	var title := Label.new()
	title.text = "案件复核"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	box.add_child(title)
	_case_body = RichTextLabel.new()
	_case_body.bbcode_enabled = true
	_case_body.custom_minimum_size = Vector2(1040, 410)
	_case_body.add_theme_font_size_override("normal_font_size", 28)
	box.add_child(_case_body)
	_attachment_button = Button.new()
	_attachment_button.text = "查看案卷附件"
	_attachment_button.custom_minimum_size = Vector2(300, 54)
	_attachment_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_attachment_button.pressed.connect(_request_attachment)
	_attachment_button.visible = false
	box.add_child(_attachment_button)
	var stamp_title := Label.new()
	stamp_title.text = "选择复核印章"
	stamp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stamp_title.add_theme_font_size_override("font_size", 30)
	box.add_child(stamp_title)
	var stamps := HBoxContainer.new()
	stamps.alignment = BoxContainer.ALIGNMENT_CENTER
	stamps.add_theme_constant_override("separation", 24)
	box.add_child(stamps)
	_approve_button = _make_stamp("红章 · 通过",  Color(0.92, 0.42, 0.38), "APPROVE")
	stamps.add_child(_approve_button)
	_question_button = _make_stamp("蓝章 · 存疑", Color(0.42, 0.66, 0.90), "QUESTION")
	stamps.add_child(_question_button)
	_unknown_button = _make_stamp("黑章 · 用途不明", Color(0.52, 0.52, 0.52), "UNKNOWN")
	_unknown_button.disabled = true
	_unknown_button.tooltip_text = "一个又大又破旧的印章，用途不明。"
	stamps.add_child(_unknown_button)
	_requirement_label = Label.new()
	_requirement_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_requirement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_requirement_label)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 20)
	box.add_child(actions)
	_submit_button = Button.new()
	_submit_button.text = "提交复核"
	_submit_button.disabled = true
	_submit_button.custom_minimum_size = Vector2(230, 58)
	_submit_button.pressed.connect(_request_submit)
	actions.add_child(_submit_button)
	var close_button := Button.new()
	close_button.text = "暂不提交"
	close_button.custom_minimum_size = Vector2(230, 58)
	close_button.pressed.connect(_close)
	actions.add_child(close_button)
	_confirmation = ConfirmationDialog.new()
	_confirmation.title = "确认提交"
	_confirmation.ok_button_text = "确认盖章"
	_confirmation.cancel_button_text = "再想想"
	_confirmation.confirmed.connect(_confirm_submit)
	add_child(_confirmation)


func _make_stamp(label_text: String, color_value: Color, verdict: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(270, 88)
	button.add_theme_color_override("font_color", color_value)
	button.add_theme_color_override("font_hover_color", color_value.lightened(0.18))
	button.pressed.connect(_select_verdict.bind(verdict))
	return button


func open_case(case_data: Dictionary, known_conclusions: Array, catalog: AssetCatalog) -> void:
	_selected_verdict = ""
	_current_case_title = String(case_data.get("title", "案件"))
	var required_conclusions := case_data.get("question_required_conclusions", []) as Array
	var has_required_evidence := true
	for conclusion_id in required_conclusions:
		if String(conclusion_id) not in known_conclusions:
			has_required_evidence = false
			break
	if required_conclusions.is_empty():
		has_required_evidence = bool(case_data.get("question_enabled", false))
	_case_body.text = (
		"[font_size=34]%s[/font_size]\n\n" % String(case_data.get("title", "案卷"))
		+ "被审判者：%s\n" % String(case_data.get("person", ""))
		+ "职业：%s\n" % String(case_data.get("profession", ""))
		+ "旧文：[font_size=40]%s[/font_size]\n" % String(case_data.get("old_text", ""))
		+ "官方译文：[color=#d5b878]%s[/color]\n" % String(case_data.get("official_translation", ""))
		+ "建议处理：%s\n\n" % String(case_data.get("recommendation", ""))
		+ "[b]译者复核：[/b]请选择一枚语义印章。"
	)
	_attachment_button.visible = not String(case_data.get("attachment_action_id", "")).is_empty()
	_attachment_button.set_meta("action_id", String(case_data.get("attachment_action_id", "")))
	_approve_button.disabled = false
	_question_button.disabled = not has_required_evidence
	_question_button.tooltip_text = "" if has_required_evidence else "需要先找到全部支持存疑的证据。"
	_apply_stamp_icon(_approve_button, catalog.get_asset(&"stamp_approve") as Texture2D)
	_apply_stamp_icon(_question_button, catalog.get_asset(&"stamp_question") as Texture2D)
	_apply_stamp_icon(_unknown_button, catalog.get_asset(&"stamp_unknown") as Texture2D)
	_requirement_label.text = (
		String(case_data.get("question_ready_text", "证据齐全，可以提交存疑。"))
		if has_required_evidence
		else String(case_data.get("question_locked_text", "存疑章尚不可用：需要先找到全部证据。"))
	)
	_submit_button.disabled = true
	visible = true


func _apply_stamp_icon(button: Button, texture: Texture2D) -> void:
	button.icon = texture
	button.expand_icon = texture != null


func _select_verdict(verdict: String) -> void:
	_selected_verdict = verdict
	_submit_button.disabled = false
	_approve_button.text = ("✓ " if verdict == "APPROVE" else "") + "蓝章 · 通过"
	_question_button.text = ("✓ " if verdict == "QUESTION" else "") + "红章 · 存疑"


func _request_submit() -> void:
	var verdict_name := "通过" if _selected_verdict == "APPROVE" else "存疑"
	_confirmation.dialog_text = "将以“%s”提交%s。\n提交后不可撤回，是否继续？" % [verdict_name, _current_case_title]
	_confirmation.popup_centered(Vector2i(620, 260))


func _confirm_submit() -> void:
	visible = false
	verdict_confirmed.emit(_selected_verdict)


func _close() -> void:
	visible = false
	closed.emit()


func _request_attachment() -> void:
	var action_id := String(_attachment_button.get_meta("action_id", ""))
	if not action_id.is_empty():
		attachment_requested.emit(action_id)
