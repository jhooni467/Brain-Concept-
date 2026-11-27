extends Node3D

const WORLD_SCENE: PackedScene = preload("res://scenes/world/prototype_laundromat.tscn")
const AXEL_SCENE: PackedScene = preload("res://scenes/characters/axel.tscn")
const TOUCH_CONTROLS_SCENE: PackedScene = preload("res://scenes/ui/touch_controls.tscn")

var player: CharacterBody3D
var follow_camera: Camera3D


func _ready() -> void:
	_configure_input()
	Engine.max_fps = 60

	var world := WORLD_SCENE.instantiate()
	add_child(world)

	player = AXEL_SCENE.instantiate() as CharacterBody3D
	player.position = Vector3(0.0, 0.0, 5.5)
	add_child(player)

	_create_camera()

	var touch_controls := TOUCH_CONTROLS_SCENE.instantiate()
	add_child(touch_controls)


func _process(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(follow_camera):
		return

	var target_position := player.global_position + Vector3(0.0, 2.9, 6.0)
	var blend := 1.0 - exp(-5.0 * delta)
	follow_camera.global_position = follow_camera.global_position.lerp(target_position, blend)
	follow_camera.look_at(player.global_position + Vector3(0.0, 1.25, 0.0), Vector3.UP)


func _create_camera() -> void:
	follow_camera = Camera3D.new()
	follow_camera.name = "FollowCamera"
	follow_camera.fov = 65.0
	follow_camera.near = 0.05
	follow_camera.far = 80.0
	add_child(follow_camera)
	follow_camera.global_position = player.global_position + Vector3(0.0, 2.9, 6.0)
	follow_camera.look_at(player.global_position + Vector3(0.0, 1.25, 0.0), Vector3.UP)
	follow_camera.current = true


func _configure_input() -> void:
	_add_key_action("move_left", [KEY_A, KEY_LEFT])
	_add_key_action("move_right", [KEY_D, KEY_RIGHT])
	_add_key_action("move_forward", [KEY_W, KEY_UP])
	_add_key_action("move_back", [KEY_S, KEY_DOWN])
	_add_key_action("jump", [KEY_SPACE])


func _add_key_action(action_name: StringName, key_codes: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.2)

	for key_code in key_codes:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = key_code
		if not InputMap.action_has_event(action_name, key_event):
			InputMap.action_add_event(action_name, key_event)
