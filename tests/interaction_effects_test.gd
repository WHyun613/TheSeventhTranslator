extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("[Interaction Effects] " + message)


func _run() -> void:
	var stage := Control.new()
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(stage)
	var source := SceneHotspot.new()
	source.position = Vector2(260.0, 560.0)
	source.size = Vector2(120.0, 120.0)
	stage.add_child(source)
	var inventory_target := Button.new()
	inventory_target.position = Vector2(1600.0, 70.0)
	inventory_target.size = Vector2(180.0, 70.0)
	stage.add_child(inventory_target)
	var effects := InteractionEffects.new()
	stage.add_child(effects)
	effects.configure(inventory_target, null)
	source._play_press_feedback()
	await create_timer(0.1).timeout
	_check(source.scale.x < 1.0, "按下热点时没有缩小反馈。")
	source._play_release_feedback()
	await create_timer(0.24).timeout
	_check(source.scale.distance_to(Vector2.ONE) < 0.02, "热点弹起后没有恢复原始缩放。")
	effects.play_pickup(source)
	effects.play_scene_reveal()
	await create_timer(1.1).timeout
	_check(effects.pickup_effect_count == 1, "拾取动画没有完整启动。")
	_check(effects.scene_transition_count == 1, "场景擦除动画没有完整启动。")
	_check(effects._scene_cover == null, "场景擦除结束后遮罩没有释放。")
	_check(inventory_target.scale.distance_to(Vector2.ONE) < 0.02, "背包轻弹结束后没有恢复原始缩放。")
	if _failures.is_empty():
		print("INTERACTION_EFFECTS_TEST_OK")
		quit(0)
	else:
		print("INTERACTION_EFFECTS_TEST_FAILED: %d" % _failures.size())
		quit(1)
