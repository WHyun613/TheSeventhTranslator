class_name DialoguePanel
extends PanelContainer

signal finished
signal line_presented(speaker: String, expression: String)

var _lines: Array = []
var _index := -1
var _characters_per_second := 52.0
var _typing := false
var _character_progress := 0.0

var _speaker_label: Label
var _text_label: RichTextLabel
var _continue_button: Button


func _ready() -> void:
	visible = false
	_build_ui()
	set_process(false)


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(content)
	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 34)
	_speaker_label.modulate = Color(0.88, 0.70, 0.42)
	content.add_child(_speaker_label)
	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = true
	_text_label.fit_content = false
	_text_label.custom_minimum_size = Vector2(0, 145)
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text_label.add_theme_font_size_override("normal_font_size", 30)
	content.add_child(_text_label)
	_continue_button = Button.new()
	_continue_button.text = "继续  ▶"
	_continue_button.custom_minimum_size = Vector2(180, 52)
	_continue_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_continue_button.pressed.connect(_advance)
	content.add_child(_continue_button)


func play(lines: Array, characters_per_second: float = 52.0) -> void:
	_lines = lines
	_characters_per_second = maxf(characters_per_second, 12.0)
	_index = -1
	visible = true
	set_process(true)
	_advance()


func _advance() -> void:
	if _typing:
		_text_label.visible_characters = -1
		_typing = false
		_continue_button.text = "继续  ▶"
		return

	_index += 1
	if _index >= _lines.size():
		visible = false
		set_process(false)
		finished.emit()
		return

	var line := _lines[_index] as Dictionary
	var speaker := String(line.get("speaker", ""))
	var expression := String(line.get("expression", "neutral"))
	_speaker_label.text = speaker
	_text_label.text = String(line.get("text", ""))
	_text_label.visible_characters = 0
	_character_progress = 0.0
	_typing = true
	_continue_button.text = "显示全文"
	line_presented.emit(speaker, expression)


func _process(delta: float) -> void:
	if not _typing:
		return
	_character_progress += delta * _characters_per_second
	_text_label.visible_characters = int(_character_progress)
	if _text_label.visible_characters >= _text_label.get_total_character_count():
		_text_label.visible_characters = -1
		_typing = false
		_continue_button.text = "继续  ▶"
