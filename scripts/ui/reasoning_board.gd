class_name ReasoningBoard
extends ColorRect

signal solved(conclusion_id: String)
signal closed

class ClueCard:
	extends Button
	var clue_id := ""

	func _get_drag_data(_at_position: Vector2) -> Variant:
		var preview := Label.new()
		preview.text = text
		preview.add_theme_font_size_override("font_size", 24)
		preview.modulate = Color(0.95, 0.82, 0.55)
		set_drag_preview(preview)
		return {"kind": "reasoning_clue", "clue_id": clue_id}

class ClueSlot:
	extends PanelContainer
	signal clue_dropped(slot_index: int, clue_id: String)
	var slot_index := 0

	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		return data is Dictionary and String(data.get("kind", "")) == "reasoning_clue"

	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		clue_dropped.emit(slot_index, String(data.get("clue_id", "")))

var _recipes: Array = []
var _known_conclusions: Array = []
var _selected: Array[String] = ["", "", ""]
var _item_definitions: Dictionary = {}
var _slot_labels: Array[Label] = []
var _feedback: Label
var _combine_button: Button


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
	panel.custom_minimum_size = Vector2(1280, 800)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 52)
	margin.add_theme_constant_override("margin_right", 52)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 22)
	margin.add_child(box)
	var title := Label.new()
	title.text = "译者推理台"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	box.add_child(title)
	var help := Label.new()
	help.text = "选择 2—3 条证据进行推理。证据不会消耗，顺序不影响结论。"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.modulate = Color(0.74, 0.70, 0.62)
	box.add_child(help)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 32)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	var clue_column := VBoxContainer.new()
	clue_column.name = "ClueColumn"
	clue_column.custom_minimum_size = Vector2(350, 0)
	clue_column.add_theme_constant_override("separation", 12)
	body.add_child(clue_column)
	var clue_title := Label.new()
	clue_title.text = "可用线索"
	clue_title.add_theme_font_size_override("font_size", 32)
	clue_column.add_child(clue_title)
	var board := VBoxContainer.new()
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.alignment = BoxContainer.ALIGNMENT_CENTER
	board.add_theme_constant_override("separation", 20)
	body.add_child(board)
	var slots_row := HBoxContainer.new()
	slots_row.alignment = BoxContainer.ALIGNMENT_CENTER
	slots_row.add_theme_constant_override("separation", 24)
	board.add_child(slots_row)
	for index in 3:
		var slot := ClueSlot.new()
		slot.slot_index = index
		slot.custom_minimum_size = Vector2(235, 180)
		slot.clue_dropped.connect(_set_slot)
		slots_row.add_child(slot)
		var slot_center := CenterContainer.new()
		slot.add_child(slot_center)
		var label := Label.new()
		label.text = "拖入线索 %d" % (index + 1)
		label.custom_minimum_size = Vector2(195, 0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_center.add_child(label)
		_slot_labels.append(label)
	_feedback = Label.new()
	_feedback.text = "选择 2—3 条能够共同说明问题的证据。"
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback.custom_minimum_size = Vector2(0, 86)
	board.add_child(_feedback)
	_combine_button = Button.new()
	_combine_button.text = "进行推理"
	_combine_button.custom_minimum_size = Vector2(260, 62)
	_combine_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_combine_button.pressed.connect(_combine)
	board.add_child(_combine_button)
	var close_button := Button.new()
	close_button.text = "离开推理台"
	close_button.custom_minimum_size = Vector2(220, 54)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(_close)
	box.add_child(close_button)


func open_board(item_ids: Array, item_definitions: Dictionary, puzzle: Dictionary, known_conclusions: Array, catalog: AssetCatalog) -> void:
	_item_definitions = item_definitions
	_recipes = (puzzle.get("recipes", []) as Array).duplicate(true)
	if _recipes.is_empty() and puzzle.has("required_clues"):
		_recipes.append({
			"required_clues": (puzzle.get("required_clues", []) as Array).duplicate(),
			"conclusion_id": String(puzzle.get("conclusion_id", "")),
		})
	_known_conclusions = known_conclusions.duplicate()
	_selected = ["", "", ""]
	var clue_column := find_child("ClueColumn", true, false) as VBoxContainer
	for child in clue_column.get_children():
		if child is ClueCard:
			child.queue_free()
	for raw_id in item_ids:
		var item_id := String(raw_id)
		var definition := item_definitions.get(item_id, {}) as Dictionary
		if not bool(definition.get("reasoning", false)):
			continue
		var card := ClueCard.new()
		card.clue_id = item_id
		card.text = String(definition.get("name", item_id))
		card.tooltip_text = String(definition.get("tooltip", ""))
		card.custom_minimum_size = Vector2(0, 72)
		var texture := catalog.get_asset(StringName(String(definition.get("asset_id", "")))) as Texture2D
		if texture != null:
			card.icon = texture
			card.expand_icon = true
		card.pressed.connect(_toggle_clue.bind(item_id))
		clue_column.add_child(card)
	_update_slots()
	_combine_button.disabled = false
	var unresolved_count := 0
	for recipe_value in _recipes:
		var recipe := recipe_value as Dictionary
		if String(recipe.get("conclusion_id", "")) not in _known_conclusions:
			unresolved_count += 1
	if unresolved_count == 0 and not _recipes.is_empty():
		_feedback.text = "当前已知配方的结论均已记录；证据仍可继续复用。"
	else:
		_feedback.text = "选择 2—3 条能够共同说明问题的证据。"
	visible = true


func _toggle_clue(clue_id: String) -> void:
	if clue_id in _selected:
		_selected[_selected.find(clue_id)] = ""
	else:
		var empty_index := _selected.find("")
		_selected[empty_index if empty_index >= 0 else 2] = clue_id
	_update_slots()


func _set_slot(index: int, clue_id: String) -> void:
	if clue_id in _selected:
		_selected[_selected.find(clue_id)] = ""
	_selected[index] = clue_id
	_update_slots()


func _update_slots() -> void:
	for index in _slot_labels.size():
		if not _selected[index].is_empty():
			var definition := _item_definitions.get(_selected[index], {}) as Dictionary
			_slot_labels[index].text = String(definition.get("name", _selected[index]))
		else:
			_slot_labels[index].text = "拖入线索 %d" % (index + 1)


func _combine() -> void:
	var chosen_clues: Array[String] = []
	for clue_id in _selected:
		if not clue_id.is_empty():
			chosen_clues.append(clue_id)
	if chosen_clues.size() < 2 or chosen_clues.size() > 3:
		_feedback.text = "请选择 2—3 条证据。"
		return
	for recipe_value in _recipes:
		var recipe := recipe_value as Dictionary
		var required_clues := recipe.get("required_clues", []) as Array
		if required_clues.size() != chosen_clues.size():
			continue
		var matches := true
		for required in required_clues:
			if String(required) not in chosen_clues:
				matches = false
				break
		if not matches:
			continue
		var conclusion_id := String(recipe.get("conclusion_id", ""))
		if conclusion_id in _known_conclusions:
			_feedback.text = "这组证据对应的结论已经记录；证据没有被消耗。"
			return
		visible = false
		solved.emit(conclusion_id)
		return
	_feedback.text = "这些证据不符合任何固定推理配方。"


func _close() -> void:
	visible = false
	closed.emit()
