extends Node3D

const WORLD_SCENE: PackedScene = preload("res://scenes/world/prototype_laundromat.tscn")
const AXEL_SCENE: PackedScene = preload("res://scenes/characters/axel.tscn")
const TOUCH_CONTROLS_SCENE: PackedScene = preload("res://scenes/ui/touch_controls.tscn")

const CAMERA_DISTANCE: float = 6.4
const CAMERA_DRAG_SENSITIVITY: float = 0.0045
const CAMERA_MIN_PITCH: float = deg_to_rad(-10.0)
const CAMERA_MAX_PITCH: float = deg_to_rad(64.0)

var player: CharacterBody3D
var follow_camera: Camera3D
var fps_label: Label
var camera_yaw: float = PI
var camera_pitch: float = deg_to_rad(18.0)
var _fps_update_timer: float = 0.0


func _ready() -> void:
	_configure_input()
	Engine.max_fps = 60

	var world := WORLD_SCENE.instantiate()
	add_child(world)

	_create_touch_hud()

	player = AXEL_SCENE.instantiate() as CharacterBody3D
	player.position = Vector3(0.0, 0.0, 8.5)
	player.rotation.y = camera_yaw
	player.set("camera_yaw", camera_yaw)
	add_child(player)

	_create_camera()


func _process(delta: float) -> void:
	_update_camera(delta)
	_update_fps_counter(delta)


func _update_camera(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(follow_camera):
		return

	player.set("camera_yaw", camera_yaw)

	var focus_point := player.global_position + Vector3(0.0, 1.12, 0.0)
	var camera_offset := Vector3(
		0.0,
		sin(camera_pitch) * CAMERA_DISTANCE,
		cos(camera_pitch) * CAMERA_DISTANCE
	).rotated(Vector3.UP, camera_yaw)

	var target_position := focus_point + camera_offset
	var blend := 1.0 - exp(-7.0 * delta)
	follow_camera.global_position = follow_camera.global_position.lerp(target_position, blend)
	follow_camera.look_at(focus_point, Vector3.UP)


func _create_camera() -> void:
	follow_camera = Camera3D.new()
	follow_camera.name = "OrbitCamera"
	follow_camera.fov = 66.0
	follow_camera.near = 0.05
	follow_camera.far = 220.0
	add_child(follow_camera)

	var focus_point := player.global_position + Vector3(0.0, 1.12, 0.0)
	var camera_offset := Vector3(
		0.0,
		sin(camera_pitch) * CAMERA_DISTANCE,
		cos(camera_pitch) * CAMERA_DISTANCE
	).rotated(Vector3.UP, camera_yaw)

	follow_camera.global_position = focus_point + camera_offset
	follow_camera.look_at(focus_point, Vector3.UP)
	follow_camera.current = true


func _create_touch_hud() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "HUDLayer"
	ui_layer.layer = 10
	add_child(ui_layer)

	var touch_controls := TOUCH_CONTROLS_SCENE.instantiate()
	ui_layer.add_child(touch_controls)
	touch_controls.connect("look_dragged", Callable(self, "_on_camera_dragged"))

	fps_label = Label.new()
	fps_label.name = "FPSCounter"
	fps_label.text = "FPS --"
	fps_label.position = Vector2(22.0, 14.0)
	fps_label.modulate = Color(1.0, 1.0, 1.0, 0.10)
	fps_label.add_theme_color_override("font_color", Color(0.94, 0.95, 1.0, 1.0))
	fps_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	fps_label.add_theme_constant_override("shadow_offset_x", 1)
	fps_label.add_theme_constant_override("shadow_offset_y", 2)
	fps_label.add_theme_font_size_override("font_size", 23)
	ui_layer.add_child(fps_label)


func _update_fps_counter(delta: float) -> void:
	_fps_update_timer += delta
	if _fps_update_timer < 0.25:
		return

	_fps_update_timer = 0.0
	if is_instance_valid(fps_label):
		fps_label.text = "FPS %d" % Engine.get_frames_per_second()


func _on_camera_dragged(delta: Vector2) -> void:
	camera_yaw -= delta.x * CAMERA_DRAG_SENSITIVITY
	camera_pitch = clampf(
		camera_pitch + delta.y * CAMERA_DRAG_SENSITIVITY,
		CAMERA_MIN_PITCH,
		CAMERA_MAX_PITCH
	)


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
