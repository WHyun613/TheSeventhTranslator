class_name InteractionEffects
extends Control

const PICKUP_PRESS_DURATION := 0.08
const PICKUP_CONFIRM_DURATION := 0.18
const PICKUP_FLIGHT_DURATION := 0.42
const INVENTORY_PULSE_DURATION := 0.12
const SCENE_FADE_OUT_DURATION := 0.35
const SCENE_FADE_IN_DURATION := 0.45

var _inventory_target: Control
var _catalog: AssetCatalog
var _scene_cover: Control
var pickup_effect_count := 0
var scene_transition_count := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func configure(inventory_target: Control, catalog: AssetCatalog) -> void:
	_inventory_target = inventory_target
	_catalog = catalog


func begin_scene_transition() -> void:
	if _scene_cover != null and is_instance_valid(_scene_cover):
		return
	_scene_cover = ColorRect.new()
	_scene_cover.color = Color.BLACK
	_scene_cover.modulate.a = 0.0
	_scene_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	_scene_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_scene_cover)


func play_pickup(source: Control, texture: Texture2D = null) -> void:
	if source == null or not is_instance_valid(source):
		return
	pickup_effect_count += 1
	var source_rect := source.get_global_rect()
	var target_rect := source_rect
	if _inventory_target != null and is_instance_valid(_inventory_target):
		target_rect = _inventory_target.get_global_rect()
	var start := source_rect.get_center()
	var finish := target_rect.get_center()
	var icon_texture := texture
	if icon_texture == null and source is BaseButton:
		icon_texture = (source as BaseButton).icon

	var flying_icon := TextureRect.new()
	flying_icon.texture = icon_texture
	flying_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flying_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flying_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_size := Vector2(clampf(source_rect.size.x, 72.0, 150.0), clampf(source_rect.size.y, 72.0, 150.0))
	if icon_size.x > icon_size.y * 1.8:
		icon_size.x = icon_size.y * 1.8
	if icon_size.y > icon_size.x * 1.8:
		icon_size.y = icon_size.x * 1.8
	flying_icon.size = icon_size
	flying_icon.pivot_offset = icon_size * 0.5
	flying_icon.position = start - icon_size * 0.5
	add_child(flying_icon)
	_spawn_pickup_ring(start)

	var control_point := (start + finish) * 0.5 + Vector2(0.0, -180.0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(flying_icon, "scale", Vector2(1.14, 1.14), PICKUP_PRESS_DURATION)
	tween.tween_property(flying_icon, "scale", Vector2(0.92, 0.92), PICKUP_CONFIRM_DURATION - PICKUP_PRESS_DURATION)
	var move_icon := func(progress: float) -> void:
		if not is_instance_valid(flying_icon):
			return
		var inverse := 1.0 - progress
		var point := inverse * inverse * start + 2.0 * inverse * progress * control_point + progress * progress * finish
		flying_icon.position = point - flying_icon.size * 0.5
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(move_icon, 0.0, 1.0, PICKUP_FLIGHT_DURATION)
	tween.parallel().tween_property(flying_icon, "scale", Vector2(0.28, 0.28), PICKUP_FLIGHT_DURATION)
	tween.parallel().tween_property(flying_icon, "rotation", 0.32, PICKUP_FLIGHT_DURATION)
	tween.parallel().tween_property(flying_icon, "modulate:a", 0.15, PICKUP_FLIGHT_DURATION).set_delay(PICKUP_FLIGHT_DURATION * 0.62)
	tween.finished.connect(func() -> void:
		if is_instance_valid(flying_icon):
			flying_icon.queue_free()
		_pulse_inventory()
		_spawn_inventory_spark(finish)
		_play_pickup_sound()
	)


func fade_scene_to_black() -> void:
	scene_transition_count += 1
	begin_scene_transition()
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_scene_cover, "modulate:a", 1.0, SCENE_FADE_OUT_DURATION)
	await tween.finished


func fade_scene_from_black() -> void:
	if _scene_cover == null or not is_instance_valid(_scene_cover):
		return
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_scene_cover, "modulate:a", 0.0, SCENE_FADE_IN_DURATION)
	await tween.finished
	if _scene_cover != null and is_instance_valid(_scene_cover):
		_scene_cover.queue_free()
		_scene_cover = null


func _spawn_pickup_ring(center: Vector2) -> void:
	var ring := Panel.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.size = Vector2(72.0, 72.0)
	ring.position = center - ring.size * 0.5
	ring.pivot_offset = ring.size * 0.5
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = Color(1.0, 0.82, 0.38, 0.92)
	style.set_border_width_all(4)
	style.set_corner_radius_all(36)
	ring.add_theme_stylebox_override("panel", style)
	add_child(ring)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.1, 2.1), PICKUP_CONFIRM_DURATION)
	tween.tween_property(ring, "modulate:a", 0.0, PICKUP_CONFIRM_DURATION)
	tween.chain().tween_callback(ring.queue_free)


func _spawn_inventory_spark(center: Vector2) -> void:
	for index in range(6):
		var spark := ColorRect.new()
		spark.color = Color(1.0, 0.78, 0.28, 0.95)
		spark.size = Vector2(8.0, 8.0)
		spark.position = center - spark.size * 0.5
		spark.rotation = float(index) * PI / 3.0
		spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(spark)
		var direction := Vector2.RIGHT.rotated(float(index) * TAU / 6.0)
		var tween := create_tween().set_parallel(true)
		tween.tween_property(spark, "position", spark.position + direction * 42.0, 0.22)
		tween.tween_property(spark, "modulate:a", 0.0, 0.22)
		tween.chain().tween_callback(spark.queue_free)


func _pulse_inventory() -> void:
	if _inventory_target == null or not is_instance_valid(_inventory_target):
		return
	_inventory_target.pivot_offset = _inventory_target.size * 0.5
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_inventory_target, "scale", Vector2(1.12, 1.12), INVENTORY_PULSE_DURATION)
	tween.tween_property(_inventory_target, "scale", Vector2.ONE, INVENTORY_PULSE_DURATION)


func _play_pickup_sound() -> void:
	if _catalog == null:
		return
	var stream := _catalog.get_asset(&"sfx_item_pickup") as AudioStream
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
