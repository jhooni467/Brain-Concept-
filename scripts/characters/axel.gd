extends CharacterBody3D

@export var move_speed: float = 3.8
@export var jump_velocity: float = 4.4
@export var turn_speed: float = 10.0

var camera_yaw: float = 0.0
var _gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _visual_root: Node3D


func _ready() -> void:
	name = "Axel"
	floor_snap_length = 0.2
	_create_collision()
	_build_model()


func _physics_process(delta: float) -> void:
	var keyboard_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var controls := get_tree().get_first_node_in_group("mobile_controls")
	var touch_vector := Vector2.ZERO
	var touch_jump := false

	if is_instance_valid(controls):
		touch_vector = controls.get_movement_vector()
		touch_jump = controls.consume_jump()

	var input_vector := touch_vector if touch_vector.length() > 0.05 else keyboard_vector
	var camera_forward := Vector3.FORWARD.rotated(Vector3.UP, camera_yaw)
	var camera_right := Vector3.RIGHT.rotated(Vector3.UP, camera_yaw)
	var direction := camera_right * input_vector.x + camera_forward * -input_vector.y

	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	if direction.length_squared() > 0.0025:
		var target_angle := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * delta)

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = -0.5
		if Input.is_action_just_pressed("jump") or touch_jump:
			velocity.y = jump_velocity
	else:
		velocity.y -= _gravity * delta

	move_and_slide()


func _create_collision() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 2.7
	collision.shape = capsule
	collision.position.y = 1.35
	add_child(collision)


func _build_model() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "AxelVisual"
	add_child(_visual_root)

	var dark_fur := _make_material(Color(0.035, 0.03, 0.045), 0.9)
	var scarf_material := _make_material(Color(0.42, 0.045, 0.13), 0.86)
	var eye_material := _make_material(Color(1.0, 0.69, 0.25), 0.38)
	eye_material.emission_enabled = true
	eye_material.emission = Color(1.0, 0.43, 0.08)
	eye_material.emission_energy_multiplier = 1.25

	_add_box("Body", Vector3(0.66, 0.78, 0.48), Vector3(0.0, 0.91, 0.0), dark_fur)
	_add_box("Head", Vector3(1.02, 0.84, 0.8), Vector3(0.0, 1.82, 0.0), dark_fur)

	_add_ear("LeftEar", Vector3(-0.34, 2.4, 0.0), dark_fur, -12.0)
	_add_ear("RightEar", Vector3(0.34, 2.4, 0.0), dark_fur, 12.0)

	_add_box("LeftEyeSocket", Vector3(0.25, 0.17, 0.045), Vector3(-0.245, 1.85, -0.414), _make_material(Color(0.008, 0.008, 0.014), 1.0))
	_add_box("RightEyeSocket", Vector3(0.25, 0.17, 0.045), Vector3(0.245, 1.85, -0.414), _make_material(Color(0.008, 0.008, 0.014), 1.0))
	_add_box("LeftEye", Vector3(0.17, 0.105, 0.028), Vector3(-0.245, 1.85, -0.447), eye_material)
	_add_box("RightEye", Vector3(0.17, 0.105, 0.028), Vector3(0.245, 1.85, -0.447), eye_material)

	_add_box("ScarfCollar", Vector3(0.78, 0.2, 0.58), Vector3(0.0, 1.36, -0.015), scarf_material)
	_add_box("ScarfTail", Vector3(0.25, 0.72, 0.15), Vector3(0.18, 0.91, -0.32), scarf_material)
	_add_box("ScarfFold", Vector3(0.28, 0.16, 0.17), Vector3(0.18, 0.58, -0.31), scarf_material)

	_add_box("LeftArm", Vector3(0.22, 0.66, 0.25), Vector3(-0.44, 0.93, -0.015), dark_fur)
	_add_box("RightArm", Vector3(0.22, 0.66, 0.25), Vector3(0.44, 0.93, -0.015), dark_fur)
	_add_box("LeftLeg", Vector3(0.3, 0.48, 0.34), Vector3(-0.18, 0.27, 0.025), dark_fur)
	_add_box("RightLeg", Vector3(0.3, 0.48, 0.34), Vector3(0.18, 0.27, 0.025), dark_fur)

	_add_box("TailBase", Vector3(0.17, 0.17, 0.5), Vector3(0.38, 0.72, 0.35), dark_fur)
	_add_box("TailTip", Vector3(0.16, 0.16, 0.34), Vector3(0.48, 0.87, 0.72), dark_fur)


func _add_ear(
	ear_name: String,
	ear_position: Vector3,
	material: Material,
	lean_degrees: float
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = ear_name

	var ear_mesh := CylinderMesh.new()
	ear_mesh.top_radius = 0.015
	ear_mesh.bottom_radius = 0.24
	ear_mesh.height = 0.68
	ear_mesh.radial_segments = 4

	mesh_instance.mesh = ear_mesh
	mesh_instance.material_override = material
	mesh_instance.position = ear_position
	mesh_instance.rotation_degrees.z = lean_degrees
	_visual_root.add_child(mesh_instance)


func _add_box(
	mesh_name: String,
	box_size: Vector3,
	box_position: Vector3,
	material: Material
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = mesh_name

	var box := BoxMesh.new()
	box.size = box_size
	mesh_instance.mesh = box
	mesh_instance.material_override = material
	mesh_instance.position = box_position
	_visual_root.add_child(mesh_instance)


func _make_material(color: Color, roughness_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness_value
	return material
