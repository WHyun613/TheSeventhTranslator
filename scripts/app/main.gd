extends Control

const AssetFrameScene := preload("res://scripts/ui/asset_frame.gd")
const DialoguePanelScene := preload("res://scripts/ui/dialogue_panel.gd")
const DocumentViewerScene := preload("res://scripts/ui/document_viewer.gd")
const DictionaryTimelinePanelScene := preload("res://scripts/ui/dictionary_timeline_panel.gd")
const InventoryPanelScene := preload("res://scripts/ui/inventory_panel.gd")
const ReasoningBoardScene := preload("res://scripts/ui/reasoning_board.gd")
const CaseReviewPanelScene := preload("res://scripts/ui/case_review_panel.gd")
const SettingsPanelScene := preload("res://scripts/ui/settings_panel.gd")
const TownOutskirtsScene := preload("res://scenes/locations/day_01/town_outskirts.tscn")
const TranslatorRoomScene := preload("res://scenes/locations/shared/translator_room.tscn")
const TranslatorDeskScene := preload("res://scenes/locations/shared/translator_desk.tscn")
const Day02StreetScene := preload("res://scenes/locations/day_02/street.tscn")
const Day02WoodsScene := preload("res://scenes/locations/day_02/woods.tscn")
const Day02ArchiveEntranceScene := preload("res://scenes/locations/day_02/archive_entrance.tscn")
const Day02ArchiveInteriorScene := preload("res://scenes/locations/day_02/archive_interior.tscn")
const Day03DetentionRoomScene := preload("res://scenes/locations/day_03/detention_room.tscn")

var content := ContentDB.new()
var state := GameState.new()
var save_service := SaveService.new()
var settings_service := SettingsService.new()

var _menu_screen: Control
var _game_screen: Control
var _day_summary_screen: Control
var _day_two_screen: Control
var _continue_button: Button
var _location_title: Label
var _location_description: Label
var _location_host: Control
var _current_location_view: LocationView
var _tutorial_label: Label
var _save_label: Label
var _day_label: Label
var _inventory_button: Button
var _reasoning_button: Button
var _summary_result: RichTextLabel

var _dialogue: DialoguePanel
var _document_viewer: DocumentViewer
var _dictionary_timeline: DictionaryTimelinePanel
var _inventory: InventoryPanel
var _reasoning: ReasoningBoard
var _case_review: CaseReviewPanel
var _settings: SettingsPanel
var _dialogue_blocker: ColorRect
var _character_art_layer: Control
var _character_portrait: TextureRect
var _character_placeholder: Label
var _toast_panel: PanelContainer
var _toast_label: Label
var _toast_timer: Timer
var _day03_question_confirmation: ConfirmationDialog

var _dialogue_callback := Callable()
var _drawer_document_chain := false
var _day02_intro_photo_chain := false
var _selected_inventory_item_id := ""


func _ready() -> void:
	settings_service.load_settings()
	_build_theme()
	_build_screens()
	_build_overlays()
	_validate_content()
	_show_main_menu()


func _process(delta: float) -> void:
	if _game_screen != null and _game_screen.visible:
		state.data["play_seconds"] = float(state.data.get("play_seconds", 0.0)) + delta


func _build_theme() -> void:
	var game_theme := Theme.new()
	var font := content.body_font()
	if font != null:
		game_theme.default_font = font
	game_theme.default_font_size = 26
	game_theme.set_color("font_color", "Label", Color(0.92, 0.88, 0.78))
	game_theme.set_color("font_color", "Button", Color(0.91, 0.86, 0.74))
	game_theme.set_color("font_hover_color", "Button", Color(1.0, 0.87, 0.55))
	game_theme.set_color("font_pressed_color", "Button", Color(0.75, 0.61, 0.36))
	game_theme.set_color("font_disabled_color", "Button", Color(0.42, 0.39, 0.34))
	game_theme.set_constant("outline_size", "Label", 5)
	game_theme.set_color("font_outline_color", "Label", Color(0.05, 0.04, 0.03, 0.8))

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.105, 0.085, 0.065, 0.97)
	panel_style.border_color = Color(0.45, 0.34, 0.22)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.shadow_color = Color(0, 0, 0, 0.45)
	panel_style.shadow_size = 12
	game_theme.set_stylebox("panel", "PanelContainer", panel_style)

	var button_normal := StyleBoxFlat.new()
	button_normal.bg_color = Color(0.16, 0.13, 0.10, 0.98)
	button_normal.border_color = Color(0.42, 0.32, 0.21)
	button_normal.set_border_width_all(2)
	button_normal.set_corner_radius_all(7)
	button_normal.content_margin_left = 18
	button_normal.content_margin_right = 18
	button_normal.content_margin_top = 10
	button_normal.content_margin_bottom = 10
	game_theme.set_stylebox("normal", "Button", button_normal)
	var button_hover := button_normal.duplicate() as StyleBoxFlat
	button_hover.bg_color = Color(0.25, 0.19, 0.12, 1.0)
	button_hover.border_color = Color(0.78, 0.58, 0.28)
	game_theme.set_stylebox("hover", "Button", button_hover)
	var button_pressed := button_normal.duplicate() as StyleBoxFlat
	button_pressed.bg_color = Color(0.10, 0.08, 0.06, 1.0)
	game_theme.set_stylebox("pressed", "Button", button_pressed)
	var button_disabled := button_normal.duplicate() as StyleBoxFlat
	button_disabled.bg_color = Color(0.08, 0.07, 0.06, 0.75)
	button_disabled.border_color = Color(0.20, 0.18, 0.16)
	game_theme.set_stylebox("disabled", "Button", button_disabled)
	theme = game_theme


func _build_screens() -> void:
	var base := ColorRect.new()
	base.color = Color(0.035, 0.028, 0.021)
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)
	_menu_screen = _build_menu_screen()
	add_child(_menu_screen)
	_game_screen = _build_game_screen()
	add_child(_game_screen)
	_day_summary_screen = _build_day_summary_screen()
	add_child(_day_summary_screen)
	_day_two_screen = _build_day_two_screen()
	add_child(_day_two_screen)


func _build_menu_screen() -> Control:
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := AssetFrameScene.new() as AssetFrame
	background.setup("bg_main_menu", content.asset_texture(&"bg_main_menu"), "Santa Lucia 审查署", Color(0.055, 0.045, 0.035), Vector2.ZERO)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(background)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.015, 0.01, 0.62)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 760)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 70)
	margin.add_theme_constant_override("margin_right", 70)
	margin.add_theme_constant_override("margin_top", 62)
	margin.add_theme_constant_override("margin_bottom", 48)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 22)
	margin.add_child(box)
	var logo_texture := content.asset_texture(&"logo_game")
	if logo_texture != null:
		var logo := TextureRect.new()
		logo.texture = logo_texture
		logo.custom_minimum_size = Vector2(520, 150)
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		box.add_child(logo)
	else:
		var title := Label.new()
		title.text = "第七名译者"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 78)
		title.modulate = Color(0.94, 0.76, 0.40)
		box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "THE SEVENTH TRANSLATOR"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.60, 0.54, 0.44)
	subtitle.add_theme_font_size_override("font_size", 22)
	box.add_child(subtitle)
	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(0, 28)
	box.add_child(rule)
	box.add_child(_menu_button("新游戏", _new_game))
	_continue_button = _menu_button("继续游戏", _continue_game)
	box.add_child(_continue_button)
	box.add_child(_menu_button("设置", _open_settings))
	box.add_child(_menu_button("退出", _quit_game))
	var note := Label.new()
	note.text = "前三天 · 占位资产可玩版"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.modulate = Color(0.55, 0.49, 0.40)
	box.add_child(note)
	return screen


func _menu_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(480, 68)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(callback)
	return button


func _build_game_screen() -> Control:
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.visible = false
	_location_host = Control.new()
	_location_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(_location_host)

	var top_panel := PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 24
	top_panel.offset_top = 20
	top_panel.offset_right = -24
	top_panel.offset_bottom = 104
	screen.add_child(top_panel)
	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 22)
	top_margin.add_theme_constant_override("margin_right", 14)
	top_margin.add_theme_constant_override("margin_top", 10)
	top_margin.add_theme_constant_override("margin_bottom", 10)
	top_panel.add_child(top_margin)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	top_margin.add_child(top)
	_day_label = Label.new()
	_day_label.text = "第 1 天"
	_day_label.add_theme_font_size_override("font_size", 34)
	_day_label.custom_minimum_size = Vector2(160, 0)
	top.add_child(_day_label)
	_save_label = Label.new()
	_save_label.text = ""
	_save_label.modulate = Color(0.58, 0.54, 0.47)
	_save_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_save_label)
	_inventory_button = _top_button("物品栏", _toggle_inventory)
	top.add_child(_inventory_button)
	_reasoning_button = _top_button("译者推理台", _open_reasoning)
	_reasoning_button.custom_minimum_size.x = 168
	top.add_child(_reasoning_button)
	top.add_child(_top_button("设置", _open_settings))
	top.add_child(_top_button("主菜单", _return_to_menu))

	var location_panel := PanelContainer.new()
	location_panel.position = Vector2(34, 122)
	location_panel.custom_minimum_size = Vector2(600, 142)
	location_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(location_panel)
	var location_margin := MarginContainer.new()
	location_margin.add_theme_constant_override("margin_left", 22)
	location_margin.add_theme_constant_override("margin_right", 22)
	location_margin.add_theme_constant_override("margin_top", 12)
	location_margin.add_theme_constant_override("margin_bottom", 12)
	location_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	location_panel.add_child(location_margin)
	var location_box := VBoxContainer.new()
	location_box.add_theme_constant_override("separation", 6)
	location_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	location_margin.add_child(location_box)
	_location_title = Label.new()
	_location_title.add_theme_font_size_override("font_size", 34)
	_location_title.modulate = Color(0.92, 0.74, 0.39)
	_location_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	location_box.add_child(_location_title)
	_location_description = Label.new()
	_location_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_location_description.modulate = Color(0.72, 0.68, 0.60)
	_location_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	location_box.add_child(_location_description)

	var tutorial_panel := PanelContainer.new()
	tutorial_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	tutorial_panel.offset_left = 250
	tutorial_panel.offset_top = -116
	tutorial_panel.offset_right = -250
	tutorial_panel.offset_bottom = -28
	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(tutorial_panel)
	_tutorial_label = Label.new()
	_tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tutorial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tutorial_label.modulate = Color(0.93, 0.78, 0.48)
	_tutorial_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_panel.add_child(_tutorial_label)
	return screen


func _top_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(124, 58)
	button.pressed.connect(callback)
	return button


func _build_day_summary_screen() -> Control:
	var screen := _build_centered_screen("第一天 · 工作结算")
	var box := screen.get_meta("content_box") as VBoxContainer
	_summary_result = RichTextLabel.new()
	_summary_result.bbcode_enabled = true
	_summary_result.custom_minimum_size = Vector2(820, 380)
	_summary_result.add_theme_font_size_override("normal_font_size", 30)
	box.add_child(_summary_result)
	box.add_child(_menu_button("进入第二天", _show_day_two))
	box.add_child(_menu_button("返回主菜单", _show_main_menu))
	return screen


func _build_day_two_screen() -> Control:
	var screen := _build_centered_screen("第四天")
	var box := screen.get_meta("content_box") as VBoxContainer
	var message := Label.new()
	message.text = "第三天调查已经完成。\n\nDay 4 内容尚未开放；存档、案件结果与累计理解度已经保留。"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.custom_minimum_size = Vector2(820, 240)
	box.add_child(message)
	box.add_child(_menu_button("返回主菜单", _show_main_menu))
	return screen


func _build_centered_screen(title_text: String) -> Control:
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.visible = false
	var shade := ColorRect.new()
	shade.color = Color(0.035, 0.028, 0.021)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(980, 700)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 70)
	margin.add_theme_constant_override("margin_right", 70)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 50)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 28)
	margin.add_child(box)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 58)
	title.modulate = Color(0.94, 0.75, 0.40)
	box.add_child(title)
	screen.set_meta("content_box", box)
	return screen


func _build_overlays() -> void:
	_dictionary_timeline = DictionaryTimelinePanelScene.new() as DictionaryTimelinePanel
	_dictionary_timeline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dictionary_timeline.closed.connect(_on_dictionary_timeline_closed)
	_dictionary_timeline.page_action_requested.connect(_on_dictionary_page_action_requested)
	_dictionary_timeline.page_clicked.connect(_on_dictionary_page_clicked)
	add_child(_dictionary_timeline)
	_document_viewer = DocumentViewerScene.new() as DocumentViewer
	_document_viewer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_document_viewer.closed.connect(_on_document_closed)
	_document_viewer.action_requested.connect(_on_document_action_requested)
	add_child(_document_viewer)
	_inventory = InventoryPanelScene.new() as InventoryPanel
	_inventory.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_inventory.item_requested.connect(_on_inventory_item_requested)
	_inventory.closed.connect(_on_inventory_closed)
	add_child(_inventory)
	_reasoning = ReasoningBoardScene.new() as ReasoningBoard
	_reasoning.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reasoning.solved.connect(_on_reasoning_solved)
	add_child(_reasoning)
	_case_review = CaseReviewPanelScene.new() as CaseReviewPanel
	_case_review.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_case_review.verdict_confirmed.connect(_on_verdict_confirmed)
	_case_review.attachment_requested.connect(_on_case_attachment_requested)
	add_child(_case_review)
	_day03_question_confirmation = ConfirmationDialog.new()
	_day03_question_confirmation.title = "提交行政欺诈证据"
	_day03_question_confirmation.dialog_text = "一旦提交，将正式质疑审查署修改官方词典与案件文书。\n是否仍然提交？"
	_day03_question_confirmation.ok_button_text = "提交"
	_day03_question_confirmation.cancel_button_text = "再考虑一下"
	_day03_question_confirmation.confirmed.connect(_finalize_day03_question)
	_day03_question_confirmation.canceled.connect(_open_case)
	add_child(_day03_question_confirmation)
	_settings = SettingsPanelScene.new() as SettingsPanel
	_settings.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings.settings_applied.connect(_on_settings_applied)
	# DEV DAY 2 SHORTCUT START — 删除此连接及底部同名处理函数即可移除测试入口。
	_settings.debug_day2_requested.connect(_debug_start_day_two)
	# DEV DAY 2 SHORTCUT END
	# DEV DAY 3 SHORTCUT START — 删除此连接及底部同名处理函数即可移除测试入口。
	_settings.debug_day3_requested.connect(_debug_start_day_three)
	# DEV DAY 3 SHORTCUT END
	add_child(_settings)
	_dialogue_blocker = ColorRect.new()
	_dialogue_blocker.color = Color(0.01, 0.01, 0.01, 0.38)
	_dialogue_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_dialogue_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialogue_blocker.visible = false
	add_child(_dialogue_blocker)
	_build_character_art_layer()
	_dialogue = DialoguePanelScene.new() as DialoguePanel
	_dialogue.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue.offset_left = 110
	_dialogue.offset_right = -110
	_dialogue.offset_top = -390
	_dialogue.offset_bottom = -60
	_dialogue.finished.connect(_on_dialogue_finished)
	_dialogue.line_presented.connect(_on_dialogue_line_presented)
	add_child(_dialogue)
	_build_toast()


func _build_character_art_layer() -> void:
	_character_art_layer = Control.new()
	_character_art_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_character_art_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_art_layer.visible = false
	add_child(_character_art_layer)
	_character_portrait = TextureRect.new()
	_character_portrait.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_character_portrait.offset_left = 90
	_character_portrait.offset_top = -1010
	_character_portrait.offset_right = 850
	_character_portrait.offset_bottom = 10
	_character_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_character_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_character_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_art_layer.add_child(_character_portrait)
	_character_placeholder = Label.new()
	_character_placeholder.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_character_placeholder.offset_left = 160
	_character_placeholder.offset_top = -800
	_character_placeholder.offset_right = 760
	_character_placeholder.offset_bottom = -390
	_character_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_character_placeholder.add_theme_font_size_override("font_size", 34)
	_character_placeholder.modulate = Color(0.72, 0.62, 0.48)
	_character_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_art_layer.add_child(_character_placeholder)


func _build_toast() -> void:
	_toast_panel = PanelContainer.new()
	_toast_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast_panel.position = Vector2(-440, 12)
	_toast_panel.custom_minimum_size = Vector2(880, 70)
	_toast_panel.visible = false
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_panel)
	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.add_child(_toast_label)
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.timeout.connect(func() -> void: _toast_panel.visible = false)
	add_child(_toast_timer)


func _validate_content() -> void:
	var issues := ContentValidator.validate_day(content.current_day, content.ASSET_CATALOG)
	for issue in issues:
		push_error("[内容校验] " + issue)


func _show_main_menu() -> void:
	_menu_screen.visible = true
	_game_screen.visible = false
	_day_summary_screen.visible = false
	_day_two_screen.visible = false
	_continue_button.disabled = not save_service.has_save()


func _new_game() -> void:
	state.reset()
	_auto_save()
	_show_game()


func _continue_game() -> void:
	state.load_from_dict(save_service.load_state())
	content.set_current_day(String(state.data.get("current_day", "day_01")))
	if bool(state.flag("day03_complete", false)):
		_show_day_four_placeholder()
		return
	if bool(state.flag("day02_complete", false)) and String(state.data.get("current_day", "day_01")) == "day_02":
		_show_day_three()
		return
	if bool(state.flag("day01_complete", false)) and String(state.data.get("current_day", "day_01")) == "day_01":
		_show_day_summary()
		return
	_show_game()
	call_deferred("_resume_progress")


func _show_game() -> void:
	content.set_current_day(String(state.data.get("current_day", "day_01")))
	_menu_screen.visible = false
	_game_screen.visible = true
	_day_summary_screen.visible = false
	_day_two_screen.visible = false
	_refresh_location()


func _resume_progress() -> void:
	if String(state.data.get("current_day", "day_01")) == "day_03":
		_resume_day_three()
		return
	if String(state.data.get("current_day", "day_01")) == "day_02":
		_resume_day_two()
		return
	if String(state.data.get("current_location", "")) not in ["translator_room", "translator_desk"]:
		return
	if bool(state.flag("case_salt_elder_submitted", false)) and not bool(state.flag("day01_complete", false)):
		_play_dialogue(
			"tomas_verdict_question" if String(state.data.get("case_verdict", "")) == "QUESTION" else "tomas_verdict_approve",
			_finish_day_one
		)
	elif not bool(state.flag("day01_onboarding_complete", false)):
		_start_onboarding()
	elif int(state.flag("tutorial_stage", 0)) < 4:
		state.set_flag("tutorial_stage", 3)
		_auto_save()
		_open_document("player_objective")
	elif bool(state.flag("case_hint_pending", false)):
		_open_document("case_hint")
	elif int(state.flag("tutorial_stage", 0)) >= 4 and not bool(state.flag("case_salt_elder_received", false)):
		_start_case_intro()


func _refresh_location() -> void:
	var location_id := String(state.data.get("current_location", "town_outskirts"))
	var location := content.location(location_id)
	_location_title.text = String(location.get("title", location_id))
	_location_description.text = String(location.get("description", ""))
	if _current_location_view != null:
		_location_host.remove_child(_current_location_view)
		_current_location_view.queue_free()
	var packed_scene: PackedScene
	match location_id:
		"town_outskirts": packed_scene = TownOutskirtsScene
		"translator_desk": packed_scene = TranslatorDeskScene
		"day02_street": packed_scene = Day02StreetScene
		"day02_woods": packed_scene = Day02WoodsScene
		"day02_archive_entrance": packed_scene = Day02ArchiveEntranceScene
		"day02_archive_interior": packed_scene = Day02ArchiveInteriorScene
		"day03_detention_room": packed_scene = Day03DetentionRoomScene
		_: packed_scene = TranslatorRoomScene
	_current_location_view = packed_scene.instantiate() as LocationView
	_location_host.add_child(_current_location_view)
	if String(state.data.get("current_day", "day_01")) == "day_02" and location_id == "translator_desk":
		var case_hotspot := _current_location_view.hotspot_by_id("case_file")
		if case_hotspot != null:
			case_hotspot.visual_asset_id = &"prop_day02_case_detailed"
			case_hotspot.visual_region = Rect2()
	elif String(state.data.get("current_day", "day_01")) == "day_03" and location_id == "translator_desk":
		var day03_case_hotspot := _current_location_view.hotspot_by_id("case_file")
		if day03_case_hotspot != null:
			day03_case_hotspot.visual_asset_id = &"prop_day03_case_file"
			day03_case_hotspot.visual_region = Rect2()
	_current_location_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_current_location_view.hotspot_activated.connect(_on_scene_hotspot_activated)
	var asset_id := String(location.get("asset_id", ""))
	_current_location_view.configure(content.asset_texture(asset_id), String(location.get("title", "地点")), content.ASSET_CATALOG)
	_update_topbar()
	_update_tutorial_text()


func _on_scene_hotspot_activated(hotspot_id: String) -> void:
	if String(state.data.get("current_day", "day_01")) == "day_03":
		_handle_day03_hotspot(hotspot_id)
		return
	if String(state.data.get("current_day", "day_01")) == "day_02":
		_handle_day02_hotspot(hotspot_id)
		return
	match hotspot_id:
		"corn_leaf": _inspect_corn_leaf()
		"enter_town": _enter_town()
		"objective_paper": _open_objective()
		"case_file": _open_case()
		"dictionary": _open_dictionary()
		"drawer": _open_drawer()
		"translator_desk": _go_to_translator_desk()
		"translator_room": _return_to_translator_room()
		_: push_warning("未处理的场景热点：" + hotspot_id)


func _update_topbar() -> void:
	_inventory_button.disabled = (state.data["inventory"] as Array).is_empty()
	var current_day := String(state.data.get("current_day", "day_01"))
	_day_label.text = "第 3 天" if current_day == "day_03" else "第 2 天" if current_day == "day_02" else "第 1 天"
	if _current_location_view == null:
		return
	if current_day == "day_03":
		_update_day03_hotspots()
		return
	if current_day == "day_02":
		_update_day02_hotspots()
		return
	if _current_location_view.location_id == "translator_room":
		_current_location_view.set_hotspot_visible("objective_paper", state.has_item("item_player_objective"))
	elif _current_location_view.location_id == "translator_desk":
		_current_location_view.set_hotspot_visible("dictionary", state.has_item("item_official_dictionary_v4"))
		_current_location_view.set_hotspot_visible("case_file", bool(state.flag("case_salt_elder_received", false)) and not bool(state.flag("case_salt_elder_submitted", false)))


func _update_tutorial_text() -> void:
	if String(state.data.get("current_day", "day_01")) == "day_03":
		_update_day03_objective()
		return
	if String(state.data.get("current_day", "day_01")) == "day_02":
		_update_day02_objective()
		return
	if String(state.data.get("current_location", "")) == "town_outskirts":
		_tutorial_label.text = "可选：查看玉米叶了解小镇过去；准备好后进入镇内。"
		return
	var stage := int(state.flag("tutorial_stage", 0))
	if not bool(state.flag("day01_onboarding_complete", false)):
		_tutorial_label.text = "等待 Tomas 的入职说明。"
	elif stage == 3:
		_tutorial_label.text = "请阅读自动打开的“玩家目标”。"
	elif not bool(state.flag("case_salt_elder_received", false)):
		_tutorial_label.text = "基础教学完成，等待 Tomas 交付今日案卷。"
	elif bool(state.flag("case_salt_elder_submitted", false)):
		_tutorial_label.text = "今日案卷已提交。"
	elif state.has_conclusion("conclusion_day01_no_illegal_crossing"):
		_tutorial_label.text = "已找到译文疑点：可以打开案卷，选择通过或附证据存疑。"
	else:
		_tutorial_label.text = "审核卖盐老人案：可以直接通过，也可以调查抽屉中的线索。"


func _inspect_corn_leaf() -> void:
	if bool(state.flag("day01_corn_leaf_seen", false)):
		_toast("干枯的玉米叶仍压在路牌旁。")
		return
	_play_dialogue("coachman_intro", func() -> void:
		state.set_flag("day01_corn_leaf_seen")
		_auto_save()
	)


func _enter_town() -> void:
	state.data["current_location"] = "translator_room"
	state.data["checkpoint"] = "translator_room_arrival"
	_auto_save()
	_refresh_location()
	if not bool(state.flag("day01_onboarding_complete", false)):
		_start_onboarding()


func _go_to_translator_desk() -> void:
	state.data["current_location"] = "translator_desk"
	state.data["checkpoint"] = "translator_desk"
	_auto_save()
	_refresh_location()


func _return_to_translator_room() -> void:
	state.data["current_location"] = "translator_room"
	state.data["checkpoint"] = "translator_room"
	_auto_save()
	_refresh_location()


func _start_onboarding() -> void:
	_play_dialogue("tomas_onboarding", func() -> void:
		state.set_flag("day01_onboarding_complete")
		state.set_flag("tutorial_stage", 3)
		state.add_item("item_official_dictionary_v4")
		state.add_item("item_player_objective")
		_auto_save()
		_refresh_location()
		_toast("获得《官方词典第四版》和“玩家目标”。")
		_open_document("player_objective")
	)


func _open_dictionary() -> void:
	var document := content.document("official_dictionary")
	if document.is_empty():
		_toast("未找到官方词典配置。")
		return
	_dictionary_timeline.open_dictionary(
		document,
		content.ASSET_CATALOG,
		int(state.data.get("dictionary_unlocked_stage", 1)),
		int(state.data.get("dictionary_current_page", 0))
	)


func _open_objective() -> void:
	_open_document("player_objective")

func _open_guideboard() -> void:
	_open_document("hotspot_guideboard")

func _open_inventory() -> void:
	_inventory.open_inventory(
		state.data["inventory"] as Array,
		content.all_items(),
		content.ASSET_CATALOG,
		_selected_inventory_item_id
	)
	if int(state.flag("tutorial_stage", 0)) == 2:
		state.set_flag("tutorial_stage", 3)
		_auto_save()
		_update_tutorial_text()


func _toggle_inventory() -> void:
	if _inventory.visible:
		_inventory.close_inventory()
	else:
		_open_inventory()


func _on_inventory_closed() -> void:
	_update_tutorial_text()


func _on_inventory_item_requested(item_id: String) -> void:
	if item_id == "item_day03_camera" and String(state.data.get("current_day", "")) == "day_03":
		_selected_inventory_item_id = item_id
		_update_inventory_button_text()
		_toast("已选中记录相机。现在点击官方词典的当前页面进行拍摄。")
		return
	_selected_inventory_item_id = ""
	_update_inventory_button_text()
	var item := content.item(item_id)
	var document_id := String(item.get("document_id", ""))
	if not document_id.is_empty():
		_open_document(document_id)


func _update_inventory_button_text() -> void:
	if _inventory_button == null:
		return
	_inventory_button.text = "物品栏（相机）" if _selected_inventory_item_id == "item_day03_camera" else "物品栏"


func _open_document(document_id: String) -> void:
	if document_id == "official_dictionary":
		_open_dictionary()
		return
	var document := content.document(document_id)
	if document.is_empty():
		_toast("未找到文档：%s" % document_id)
		return
	var asset_id := String(document.get("asset_id", ""))
	if document.has("page_asset_ids"):
		var page_asset_ids := (document.get("page_asset_ids", []) as Array).duplicate()
		if document_id == "official_dictionary" and not state.has_conclusion("conclusion_day02_hand_protects") and page_asset_ids.size() > 1:
			page_asset_ids.resize(1)
		_document_viewer.open_image_document(
			document_id,
			String(document.get("title", document_id)),
			page_asset_ids,
			content.ASSET_CATALOG
		)
		return
	_document_viewer.open_document(
		document_id,
		String(document.get("title", document_id)),
		String(document.get("body", "")),
		asset_id,
		content.asset_texture(asset_id),
		String(document.get("action_id", "")),
		String(document.get("action_label", "")),
		String(document.get("presentation", "standard"))
	)


func _on_document_closed(document_id: String) -> void:
	if String(state.data.get("current_day", "day_01")) == "day_02":
		if document_id == "day02_elder_photo" and _day02_intro_photo_chain:
			_day02_intro_photo_chain = false
			_play_dialogue("day02_pickpocket", func() -> void:
				_play_dialogue("day02_marina_leave", func() -> void:
					state.set_flag("day02_street_event_complete")
					state.data["checkpoint"] = "day02_street_free"
					_auto_save()
					_refresh_location()
				)
			)
			return
		if document_id == "conclusion_day02_hand_protects_doc":
			_try_day02_marina_followup()
	var stage := int(state.flag("tutorial_stage", 0))
	if document_id == "official_dictionary" and stage == 1:
		state.set_flag("tutorial_stage", 2)
		_auto_save()
		_update_tutorial_text()
		_toast("下一步：打开物品栏。")
	elif document_id == "player_objective" and stage == 3:
		state.set_flag("tutorial_stage", 4)
		_auto_save()
		_update_tutorial_text()
		call_deferred("_start_case_intro")
	elif document_id == "case_hint" and bool(state.flag("case_hint_pending", false)):
		state.set_flag("case_hint_pending", false)
		_auto_save()
		_refresh_location()
		_toast("案卷和官方词典已经放在译者桌上。点击桌面进入查看。")
	elif document_id == "old_text" and _drawer_document_chain:
		_drawer_document_chain = false
		_open_document("marina_note")


func _on_dictionary_timeline_closed(current_page: int) -> void:
	state.data["dictionary_current_page"] = current_page
	_auto_save()
	_on_document_closed("official_dictionary")


func _on_document_action_requested(_document_id: String, action_id: String) -> void:
	if String(state.data.get("current_day", "day_01")) != "day_03":
		return
	match action_id:
		"day03_inspect_gap_circle":
			state.set_flag("day03_gap_inspected")
			state.data["checkpoint"] = "day03_gap_inspected"
			_auto_save()
			_update_tutorial_text()
			_toast("缺口圆表示“没有”，但它在官方协议中被人为划掉了。")
		"day03_capture_elder_agreement":
			_capture_day03_elder_agreement()


func _on_dictionary_page_action_requested(page_index: int, action_id: String) -> void:
	if String(state.data.get("current_day", "day_01")) != "day_03" or action_id != "day03_capture_dictionary_page":
		return
	_on_dictionary_page_clicked(page_index)


func _on_dictionary_page_clicked(page_index: int) -> void:
	if String(state.data.get("current_day", "day_01")) != "day_03":
		return
	if _selected_inventory_item_id != "item_day03_camera":
		_toast("请先打开物品栏并选择记录相机，再点击词典当前页面。")
		return
	_selected_inventory_item_id = ""
	_update_inventory_button_text()
	_capture_day03_dictionary_page(page_index)


# 剧情任务统一调用这个接口。D3 已知任务与未来未定任务不应直接操作词典 UI。
func unlock_dictionary_stage(stage: int) -> void:
	var previous := int(state.data.get("dictionary_unlocked_stage", 1))
	var next_stage := clampi(maxi(previous, stage), 1, 3)
	if next_stage == previous:
		return
	state.data["dictionary_unlocked_stage"] = next_stage
	_auto_save()
	_toast("官方词典的时间标志解锁了新的刻度。")


func _start_case_intro() -> void:
	if bool(state.flag("case_salt_elder_received", false)):
		return
	_play_dialogue("tomas_case_intro", func() -> void:
		state.set_flag("case_salt_elder_received")
		state.set_flag("case_hint_pending")
		state.data["checkpoint"] = "case_received"
		_auto_save()
		_refresh_location()
		_open_document("case_hint")
	)


func _open_case() -> void:
	if String(state.data.get("current_day", "day_01")) == "day_03":
		if not bool(state.flag("day03_case_received", false)):
			_toast("Tomas 还没有交付第三天的补充案卷。")
			return
		if bool(state.flag("day03_case_submitted", false)):
			_toast("第三天的案卷已经提交。")
			return
		_case_review.open_case(content.current_day.case_data, state.data["conclusions"] as Array, content.ASSET_CATALOG)
		return
	if String(state.data.get("current_day", "day_01")) == "day_02":
		if not bool(state.flag("day02_case_received", false)):
			_toast("Tomas 还没有交付第二天的详细案卷。")
			return
		if bool(state.flag("day02_case_submitted", false)):
			_toast("第二天的案卷已经提交。")
			return
		_case_review.open_case(content.current_day.case_data, state.data["conclusions"] as Array, content.ASSET_CATALOG)
		return
	if not bool(state.flag("case_salt_elder_received", false)):
		_toast("你还没有收到今天的案卷。")
		return
	if bool(state.flag("case_salt_elder_submitted", false)):
		_toast("案卷已经提交，不能再次修改。")
		return
	_case_review.open_case(content.current_day.case_data, state.data["conclusions"] as Array, content.ASSET_CATALOG)


func _open_drawer() -> void:
	if not bool(state.flag("case_salt_elder_received", false)):
		_toast("先完成入职教学并接收今日案卷。")
		return
	if bool(state.flag("drawer_opened", false)):
		_toast("抽屉已经打开。旧文和纸条都在你的物品栏里。")
		return
	state.set_flag("drawer_opened")
	state.add_item("item_day01_old_text")
	state.add_item("item_day01_marina_note")
	state.data["checkpoint"] = "drawer_opened"
	_auto_save()
	_refresh_location()
	_toast("打开抽屉：获得“旧文 1”和“mari 留下的纸条”。")
	_drawer_document_chain = true
	_open_document("old_text")


func _inspect_office_door() -> void:
	_toast("Tomas 的办公室，似乎上锁了。")


func _open_reasoning() -> void:
	var reasoning_count := 0
	for raw_item_id in state.data["inventory"] as Array:
		if bool(content.item(String(raw_item_id)).get("reasoning", false)):
			reasoning_count += 1
	if reasoning_count < 2:
		_toast("推理台需要至少两条相关材料。")
		return
	_reasoning.open_board(
		state.data["inventory"] as Array,
		content.all_items(),
		content.current_day.puzzle_data,
		state.data["conclusions"] as Array,
		content.ASSET_CATALOG
	)


func _on_reasoning_solved(conclusion_id: String) -> void:
	if state.add_conclusion(conclusion_id):
		state.add_item(conclusion_id)
		state.data["checkpoint"] = "conclusion_unlocked"
		if conclusion_id == "conclusion_day03_dictionary_history_available":
			unlock_dictionary_stage(2)
		_auto_save()
		_refresh_location()
		var conclusion_item := content.item(conclusion_id)
		_open_document(String(conclusion_item.get("document_id", "conclusion_no_illegal_crossing")))


func _on_verdict_confirmed(verdict: String) -> void:
	if String(state.data.get("current_day", "day_01")) == "day_03":
		_submit_day03_verdict(verdict)
		return
	if String(state.data.get("current_day", "day_01")) == "day_02":
		_submit_day02_verdict(verdict)
		return
	if bool(state.flag("case_salt_elder_submitted", false)):
		return
	state.set_flag("case_salt_elder_submitted")
	state.data["case_verdict"] = verdict
	state.data["case_understanding"] = 0
	state.record_case("case_salt_elder_day01", verdict, 1 if verdict == "QUESTION" else 0)
	state.data["checkpoint"] = "case_submitted"
	_auto_save()
	_refresh_location()
	_play_dialogue(
		"tomas_verdict_question" if verdict == "QUESTION" else "tomas_verdict_approve",
		_finish_day_one
	)


func _finish_day_one() -> void:
	state.set_flag("day01_complete")
	state.data["checkpoint"] = "day01_complete"
	_auto_save()
	_show_day_summary()


func _show_day_summary() -> void:
	_menu_screen.visible = false
	_game_screen.visible = false
	_day_two_screen.visible = false
	_day_summary_screen.visible = true
	var questioned := String(state.data.get("case_verdict", "")) == "QUESTION"
	_summary_result.text = (
		"[center][font_size=38]卖盐老人案 · 今日译注已提交[/font_size]\n\n"
		+ ("你提交了译文存疑，并附上了“老人没有非法越境”的证据。" if questioned else "你认可了官方译文，没有提交额外证据。")
		+ "\n\n案件理解度：[font_size=42][color=#e1b65d]%d[/color][/font_size]\n\n自动存档已完成。[/center]" % int(state.data.get("case_understanding", 0))
	)


func _show_day_two() -> void:
	state.data["current_day"] = "day_02"
	state.data["current_location"] = "translator_desk"
	state.data["checkpoint"] = "day02_start"
	state.set_flag("day02_started")
	content.set_current_day("day_02")
	_validate_content()
	_auto_save()
	_show_game()
	_start_day02_briefing()


func _resume_day_two() -> void:
	if bool(state.flag("day02_case_submitted", false)) and not bool(state.flag("day02_complete", false)):
		_play_dialogue(
			"day02_verdict_question" if String(state.data.get("case_verdict", "")) == "QUESTION" else "day02_verdict_approve",
			_finish_day_two
		)
		return
	if not bool(state.flag("day02_briefing_complete", false)):
		_start_day02_briefing()
		return
	if String(state.data.get("current_location", "")) == "day02_street":
		_trigger_day02_street_events()


func _start_day02_briefing() -> void:
	if bool(state.flag("day02_briefing_complete", false)):
		return
	_play_dialogue("day02_tomas_briefing", func() -> void:
		state.set_flag("day02_briefing_complete")
		state.set_flag("day02_case_received")
		state.data["checkpoint"] = "day02_case_received"
		_auto_save()
		_refresh_location()
		_open_document("day02_case_hint")
	)


func _handle_day02_hotspot(hotspot_id: String) -> void:
	match hotspot_id:
		"case_file": _open_case()
		"dictionary": _open_dictionary()
		"translator_room": _go_day02_location("translator_room")
		"translator_desk": _go_day02_location("translator_desk")
		"objective_paper": _open_objective()
		"drawer": _toast("抽屉中第一天发现的材料仍保存在物品栏里。")
		"exit_to_street", "to_street": _go_day02_location("day02_street")
		"to_room": _go_day02_location("translator_room")
		"to_woods": _go_day02_location("day02_woods")
		"to_archive_entrance": _go_day02_location("day02_archive_entrance")
		"archive_door": _go_day02_location("day02_archive_interior")
		"archive_exit": _go_day02_location("day02_archive_entrance")
		"boy_drawing": _take_day02_item("item_day02_boy_drawing", "获得“小男孩的画”。")
		"wallet": _take_day02_item("item_day02_wallet", "捡起 Marina 的钱包。")
		"guideboard":
			_auto_save()
			_toast("右侧前往档案室")
		"cloth_bag":
			state.set_flag("day02_bag_seen")
			_auto_save()
			_refresh_location()
			_toast("破布袋属于那个孩子，不能带走。")
		"paper_stack": _take_day02_item("item_day02_old_letter", "从纸堆中找到一封旧信。")
		"old_map":
			_take_day02_item("item_day02_old_map", "取得标有过去边界的旧地图。")
			state.set_flag("day02_old_map_found")
			_auto_save()
		"black_stamp":
			state.set_flag("day02_black_stamp_seen")
			_auto_save()
			_toast("一枚又大又破旧的黑章。用途仍不明确，暂不带走。")
		_: push_warning("未处理的第二天场景热点：" + hotspot_id)


func _go_day02_location(location_id: String) -> void:
	state.data["current_location"] = location_id
	state.data["checkpoint"] = "day02_" + location_id
	_auto_save()
	_refresh_location()
	if location_id == "day02_street":
		_trigger_day02_street_events()


func _trigger_day02_street_events() -> void:
	if not bool(state.flag("day02_street_event_complete", false)):
		_play_dialogue("day02_marina_intro", func() -> void:
			_day02_intro_photo_chain = true
			_open_document("day02_elder_photo")
		)
		return
	if state.has_item("item_day02_old_map") and not bool(state.flag("day02_marina_return_complete", false)):
		_play_dialogue("day02_marina_return", func() -> void:
			state.set_flag("day02_marina_return_complete")
			_auto_save()
			_try_day02_marina_followup()
		)
		return
	_try_day02_marina_followup()


func _try_day02_marina_followup() -> void:
	if String(state.data.get("current_location", "")) != "day02_street":
		return
	if not bool(state.flag("day02_marina_return_complete", false)):
		return
	if not state.has_conclusion("conclusion_day02_hand_protects") or bool(state.flag("day02_marina_glyph_followup_complete", false)):
		return
	_play_dialogue("day02_marina_glyph_followup", func() -> void:
		state.set_flag("day02_marina_glyph_followup_complete")
		_auto_save()
	)


func _take_day02_item(item_id: String, message: String) -> void:
	if not state.add_item(item_id):
		_toast("这件材料已经在物品栏里。")
		return
	state.data["checkpoint"] = "day02_item_" + item_id
	_auto_save()
	_refresh_location()
	_toast(message)
	var document_id := String(content.item(item_id).get("document_id", ""))
	if not document_id.is_empty():
		_open_document(document_id)


func _on_case_attachment_requested(action_id: String) -> void:
	if action_id == "day03_take_official_agreement" and String(state.data.get("current_day", "day_01")) == "day_03":
		_case_review.visible = false
		if state.add_item("item_day03_official_agreement"):
			state.set_flag("day03_official_agreement_received")
			state.data["checkpoint"] = "day03_official_agreement"
			_auto_save()
			_toast("《对原住民的告知和补偿协议》已加入物品栏。")
		_open_document("day03_official_agreement")
		return
	if action_id != "day02_take_field_photo":
		return
	_case_review.visible = false
	if state.add_item("item_day02_field_photo"):
		state.set_flag("day02_field_photo_taken")
		state.data["checkpoint"] = "day02_field_photo"
		_auto_save()
		_toast("案卷中的田地照片已加入物品栏。")
	_open_document("day02_field_photo")


func _update_day02_hotspots() -> void:
	var location_id := String(state.data.get("current_location", ""))
	if location_id == "translator_room":
		_current_location_view.set_hotspot_visible("exit_to_street", true)
		_current_location_view.set_hotspot_visible("objective_paper", state.has_item("item_player_objective"))
	elif location_id == "translator_desk":
		_current_location_view.set_hotspot_visible("dictionary", state.has_item("item_official_dictionary_v4"))
		_current_location_view.set_hotspot_visible("case_file", bool(state.flag("day02_case_received", false)) and not bool(state.flag("day02_case_submitted", false)))
	elif location_id == "day02_street":
		var event_complete := bool(state.flag("day02_street_event_complete", false))
		_current_location_view.set_hotspot_visible("boy_drawing", event_complete and not state.has_item("item_day02_boy_drawing"))
		_current_location_view.set_hotspot_visible("wallet", event_complete and not state.has_item("item_day02_wallet"))
		_current_location_view.set_hotspot_visible("cloth_bag", event_complete and not bool(state.flag("day02_bag_seen", false)))
		_current_location_view.set_hotspot_enabled("to_woods", event_complete)
	elif location_id == "day02_archive_interior":
		_current_location_view.set_hotspot_visible("paper_stack", not state.has_item("item_day02_old_letter"))
		_current_location_view.set_hotspot_visible("old_map", not state.has_item("item_day02_old_map"))


func _update_day02_objective() -> void:
	if not bool(state.flag("day02_briefing_complete", false)):
		_tutorial_label.text = "等待 Tomas 交付详细案卷。"
	elif bool(state.flag("day02_case_submitted", false)):
		_tutorial_label.text = "第二天的案卷已经提交。"
	elif state.has_conclusion("conclusion_day02_hand_protects") and state.has_conclusion("conclusion_day02_border_changed"):
		_tutorial_label.text = "两项证据链已经成立。返回译者桌提交通过或存疑。"
	elif not bool(state.flag("day02_street_event_complete", false)):
		_tutorial_label.text = "从译者房间的大门前往街道调查。"
	elif not state.has_item("item_day02_old_letter") or not state.has_item("item_day02_old_map"):
		_tutorial_label.text = "穿过树林进入档案室，寻找旧信和旧地图。"
	else:
		_tutorial_label.text = "使用译者推理台，将画与旧信、田地照片与旧地图分别组合。"


func _submit_day02_verdict(verdict: String) -> void:
	if bool(state.flag("day02_case_submitted", false)):
		return
	state.set_flag("day02_case_submitted")
	state.record_case("case_salt_elder_day02", verdict, 1 if verdict == "QUESTION" else 0)
	(state.data["day_results"] as Dictionary)["day_02"] = {"verdict": verdict}
	state.data["checkpoint"] = "day02_case_submitted"
	_auto_save()
	_refresh_location()
	_play_dialogue("day02_verdict_question" if verdict == "QUESTION" else "day02_verdict_approve", _finish_day_two)


func _finish_day_two() -> void:
	state.set_flag("day02_complete")
	state.data["checkpoint"] = "day02_complete"
	_auto_save()
	_show_day_three()


func _show_day_four_placeholder() -> void:
	_menu_screen.visible = false
	_game_screen.visible = false
	_day_summary_screen.visible = false
	_day_two_screen.visible = true


func _show_day_three() -> void:
	state.data["current_day"] = "day_03"
	state.data["current_location"] = "translator_desk"
	state.data["checkpoint"] = "day03_start"
	state.set_flag("day03_started")
	content.set_current_day("day_03")
	_validate_content()
	_auto_save()
	_show_game()
	_start_day03_briefing()


func _resume_day_three() -> void:
	if bool(state.flag("day03_case_submitted", false)) and not bool(state.flag("day03_complete", false)):
		if String(state.data.get("case_verdict", "")) == "QUESTION":
			_play_dialogue("day03_verdict_question_submitted", _finish_day_three)
		else:
			_play_dialogue("day03_verdict_approve", _finish_day_three)
		return
	if not bool(state.flag("day03_briefing_complete", false)):
		_start_day03_briefing()
		return
	if String(state.data.get("current_location", "")) == "day02_street":
		_trigger_day03_street_event()
	elif String(state.data.get("current_location", "")) == "day03_detention_room":
		_trigger_day03_detention_event()


func _start_day03_briefing() -> void:
	if bool(state.flag("day03_briefing_complete", false)):
		return
	_play_dialogue("day03_tomas_briefing", func() -> void:
		state.set_flag("day03_briefing_complete")
		state.set_flag("day03_case_received")
		state.data["checkpoint"] = "day03_case_received"
		_auto_save()
		_refresh_location()
	)


func _handle_day03_hotspot(hotspot_id: String) -> void:
	match hotspot_id:
		"case_file": _open_case()
		"dictionary": _open_dictionary()
		"camera": _take_day03_camera()
		"translator_room": _go_day03_location("translator_room")
		"translator_desk": _go_day03_location("translator_desk")
		"objective_paper": _open_objective()
		"drawer": _toast("抽屉中的旧材料仍保存在物品栏里。")
		"exit_to_street", "to_street": _go_day03_location("day02_street")
		"to_room": _go_day03_location("translator_room")
		"to_detention": _go_day03_location("day03_detention_room")
		"elder_agreement": _open_document("day03_elder_agreement")
		_: push_warning("未处理的第三天场景热点：" + hotspot_id)


func _go_day03_location(location_id: String) -> void:
	if location_id == "day03_detention_room":
		if not bool(state.flag("day03_detention_route_unlocked", false)):
			_toast("还不知道临时羁押处的具体位置。")
			return
		if not state.has_item("item_day03_camera"):
			_toast("需要先回译者桌取得记录相机。")
			return
	state.data["current_location"] = location_id
	state.data["checkpoint"] = "day03_" + location_id
	_auto_save()
	_refresh_location()
	if location_id == "day02_street":
		_trigger_day03_street_event()
	elif location_id == "day03_detention_room":
		_trigger_day03_detention_event()


func _trigger_day03_street_event() -> void:
	if bool(state.flag("day03_marina_event_complete", false)):
		return
	if not bool(state.flag("day03_gap_inspected", false)):
		_toast("先检查案卷附件中被划掉的缺口圆，再与 Marina 讨论。")
		return
	_play_dialogue("day03_marina_review", func() -> void:
		_play_dialogue("day03_marina_detention_plan", func() -> void:
			state.set_flag("day03_marina_event_complete")
			state.set_flag("day03_detention_route_unlocked")
			state.data["checkpoint"] = "day03_detention_route"
			_auto_save()
			_refresh_location()
			_toast("请按照路标前往临时羁押处。")
		)
	)


func _trigger_day03_detention_event() -> void:
	if bool(state.flag("day03_elder_conversation_complete", false)):
		return
	_play_dialogue("day03_elder_warning", func() -> void:
		_play_dialogue("day03_elder_agreement", func() -> void:
			state.set_flag("day03_elder_conversation_complete")
			state.data["checkpoint"] = "day03_elder_agreement_ready"
			_auto_save()
			_refresh_location()
			_toast("老人递出了三年前的旧土地协议。")
		)
	)


func _take_day03_camera() -> void:
	if not state.add_item("item_day03_camera"):
		_toast("记录相机已经在物品栏中。")
		return
	state.set_flag("day03_camera_taken")
	state.data["checkpoint"] = "day03_camera_taken"
	_auto_save()
	_refresh_location()
	_toast("获得记录相机。现在可以拍摄关键文书和词典时间页。")


func _capture_day03_elder_agreement() -> void:
	if not state.has_item("item_day03_camera"):
		_toast("没有记录相机，无法拍摄。")
		return
	if not bool(state.flag("day03_elder_conversation_complete", false)):
		_toast("需要先听老人说明这份文件的来历。")
		return
	_document_viewer.visible = false
	if state.add_item("item_day03_elder_agreement_photo"):
		state.set_flag("day03_elder_agreement_captured")
		state.data["checkpoint"] = "day03_elder_agreement_photo"
		_auto_save()
		_refresh_location()
		_toast("快门闪光：获得老人旧协议照片。")
	_open_document("day03_elder_agreement_photo")


func _capture_day03_dictionary_page(page_index: int) -> void:
	if not state.has_item("item_day03_camera"):
		_toast("没有记录相机，无法拍摄词典。")
		return
	var item_id := ""
	var document_id := ""
	if page_index == 0:
		item_id = "item_day03_current_dictionary_photo"
		document_id = "day03_current_dictionary_photo"
	elif page_index == 1 and int(state.data.get("dictionary_unlocked_stage", 1)) >= 2:
		item_id = "item_day03_historical_dictionary_photo"
		document_id = "day03_historical_dictionary_photo"
	else:
		_toast("这个时间页目前不能作为 Day 3 证据拍摄。")
		return
	state.data["dictionary_current_page"] = page_index
	_dictionary_timeline.visible = false
	if state.add_item(item_id):
		state.data["checkpoint"] = "day03_dictionary_photo_" + str(page_index)
		_auto_save()
		_toast("快门闪光：词典时间页照片已加入物品栏。")
	_open_document(document_id)


func _update_day03_hotspots() -> void:
	var location_id := String(state.data.get("current_location", ""))
	if location_id == "translator_room":
		_current_location_view.set_hotspot_visible("exit_to_street", true)
		_current_location_view.set_hotspot_visible("objective_paper", state.has_item("item_player_objective"))
	elif location_id == "translator_desk":
		_current_location_view.set_hotspot_visible("dictionary", state.has_item("item_official_dictionary_v4"))
		_current_location_view.set_hotspot_visible("case_file", bool(state.flag("day03_case_received", false)) and not bool(state.flag("day03_case_submitted", false)))
		_current_location_view.set_hotspot_visible("camera", bool(state.flag("day03_case_received", false)) and not state.has_item("item_day03_camera"))
	elif location_id == "day02_street":
		_current_location_view.set_hotspot_visible("boy_drawing", false)
		_current_location_view.set_hotspot_visible("wallet", false)
		_current_location_view.set_hotspot_visible("cloth_bag", false)
		_current_location_view.set_hotspot_visible("to_woods", false)
		_current_location_view.set_hotspot_visible("to_detention", bool(state.flag("day03_detention_route_unlocked", false)))
	elif location_id == "day03_detention_room":
		_current_location_view.set_hotspot_visible("elder_agreement", bool(state.flag("day03_elder_conversation_complete", false)) and not state.has_item("item_day03_elder_agreement_photo"))


func _update_day03_objective() -> void:
	if not bool(state.flag("day03_briefing_complete", false)):
		_tutorial_label.text = "等待 Tomas 交付第三天的补充案卷。"
	elif bool(state.flag("day03_case_submitted", false)):
		_tutorial_label.text = "第三天的案卷已经提交。"
	elif state.has_conclusion("conclusion_day03_dictionary_tampered"):
		_tutorial_label.text = "结论 05 已成立。返回译者桌选择通过或附证据存疑。"
	elif state.has_conclusion("conclusion_day03_dictionary_history_available"):
		_tutorial_label.text = "词典第二时间刻度已解锁。先在物品栏选择相机，再点击当前页和三年前页面拍摄。"
	elif state.has_item("item_day03_elder_agreement_photo"):
		_tutorial_label.text = "将官方协议和老人旧协议照片放入译者推理台。"
	elif bool(state.flag("day03_detention_route_unlocked", false)):
		_tutorial_label.text = "带上相机，按街道路标前往临时羁押处。"
	elif bool(state.flag("day03_gap_inspected", false)):
		_tutorial_label.text = "前往街道，把协议中的缺口圆问题告诉 Marina。"
	else:
		_tutorial_label.text = "查看 D3 案卷附件，检查被划掉的缺口圆；也可以直接提交通过。"


func _submit_day03_verdict(verdict: String) -> void:
	if bool(state.flag("day03_case_submitted", false)):
		return
	if verdict == "QUESTION":
		_play_dialogue("day03_verdict_question", func() -> void:
			_day03_question_confirmation.popup_centered(Vector2i(760, 300))
		)
		return
	_finalize_day03_verdict("APPROVE")
	_play_dialogue("day03_verdict_approve", _finish_day_three)


func _finalize_day03_question() -> void:
	_finalize_day03_verdict("QUESTION")
	_play_dialogue("day03_verdict_question_submitted", _finish_day_three)


func _finalize_day03_verdict(verdict: String) -> void:
	if bool(state.flag("day03_case_submitted", false)):
		return
	state.set_flag("day03_case_submitted")
	state.record_case("case_salt_elder_day03", verdict, 1 if verdict == "QUESTION" else 0)
	(state.data["day_results"] as Dictionary)["day_03"] = {"verdict": verdict}
	state.data["checkpoint"] = "day03_case_submitted"
	_auto_save()
	_refresh_location()


func _finish_day_three() -> void:
	state.set_flag("day03_complete")
	state.data["checkpoint"] = "day03_complete"
	_auto_save()
	_show_day_four_placeholder()


func _play_dialogue(dialogue_id: String, callback: Callable = Callable()) -> void:
	var lines := content.dialogue(dialogue_id)
	if lines.is_empty():
		push_error("缺少对白：" + dialogue_id)
		if callback.is_valid():
			callback.call()
		return
	_dialogue_callback = callback
	_dialogue_blocker.visible = true
	_dialogue.play(lines, float(settings_service.data.get("text_speed", 52.0)))


func _on_dialogue_finished() -> void:
	_dialogue_blocker.visible = false
	_character_art_layer.visible = false
	var callback := _dialogue_callback
	_dialogue_callback = Callable()
	if callback.is_valid():
		callback.call()


func _on_dialogue_line_presented(speaker: String, expression: String) -> void:
	var asset_id := ""
	if speaker == "Tomas":
		asset_id = "char_tomas_" + expression
	elif speaker == "马车夫":
		asset_id = "char_coachman_neutral"
	elif speaker == "Marina":
		asset_id = "char_marina_" + expression
	elif speaker == "神秘男孩":
		asset_id = "char_mystery_boy_neutral"
	elif speaker == "老人":
		asset_id = "char_elder_" + expression
	var texture := content.asset_texture(asset_id)
	_character_portrait.texture = texture
	_character_portrait.visible = texture != null
	_character_placeholder.visible = texture == null and not asset_id.is_empty()
	_character_placeholder.text = "%s\n\n[待替换透明半身立绘]\n%s" % [speaker, asset_id]
	_character_art_layer.visible = texture != null or not asset_id.is_empty()


func _open_settings() -> void:
	_settings.open_settings(settings_service.data)


func _on_settings_applied(new_settings: Dictionary) -> void:
	for key in new_settings:
		settings_service.data[key] = new_settings[key]
	settings_service.save_settings()
	_toast("设置已保存。")


# DEV DAY 2 SHORTCUT START — 独立测试入口，不参与正式日程推进。
func _debug_start_day_two() -> void:
	state.reset()
	state.set_flag("day01_complete")
	state.add_item("item_official_dictionary_v4")
	state.add_item("item_player_objective")
	_show_day_two()
# DEV DAY 2 SHORTCUT END


# DEV DAY 3 SHORTCUT START — 独立测试入口，不参与正式日程推进。
func _debug_start_day_three() -> void:
	state.reset()
	state.set_flag("day01_complete")
	state.set_flag("day02_complete")
	state.add_item("item_official_dictionary_v4")
	state.add_item("item_player_objective")
	state.add_item("item_day01_marina_note")
	state.data["case_understanding"] = 2
	_show_day_three()
# DEV DAY 3 SHORTCUT END


func _return_to_menu() -> void:
	_auto_save()
	_show_main_menu()


func _quit_game() -> void:
	get_tree().quit()


func _auto_save() -> void:
	var result := save_service.save_state(state)
	if result == OK:
		if _save_label != null:
			_save_label.text = "已自动保存  " + Time.get_time_string_from_system()
	else:
		push_error("自动保存失败，错误码：%s" % result)
		_toast("自动保存失败，请检查用户目录权限。")
	if _continue_button != null:
		_continue_button.disabled = not save_service.has_save()


func _toast(message: String, seconds: float = 3.2) -> void:
	if _toast_panel == null:
		return
	_toast_label.text = message
	_toast_panel.visible = true
	_toast_timer.start(seconds)
