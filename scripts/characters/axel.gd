extends CharacterBody3D

@export var move_speed: float = 4.0
@export var jump_velocity: float = 4.2
@export var turn_speed: float = 11.0

var camera_yaw: float = 0.0
var _gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _visual_root: Node3D
var _mobile_controls: Node


func _ready() -> void:
	name = "Axel"
	floor_snap_length = 0.22
	_mobile_controls = get_tree().get_first_node_in_group("mobile_controls")
	_create_collision()
	_build_model()


func _physics_process(delta: float) -> void:
	var keyboard_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var touch_vector := Vector2.ZERO
	var touch_jump := false
	if is_instance_valid(_mobile_controls):
		touch_vector = _mobile_controls.call("get_movement_vector")
		touch_jump = bool(_mobile_controls.call("consume_jump"))

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
	capsule.radius = 0.31
	capsule.height = 2.05
	collision.shape = capsule
	collision.position.y = 1.025
	add_child(collision)


func _build_model() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "AxelVisual"
	add_child(_visual_root)

	var dark_cloth := _make_material(Color(0.022, 0.019, 0.031), 0.94)
	var scarf_material := _make_material(Color(0.39, 0.025, 0.095), 0.88)
	var scarf_edge := _make_material(Color(0.19, 0.012, 0.045), 0.92)
	var eye_material := _make_material(Color(1.0, 0.67, 0.19), 0.48)
	eye_material.emission_enabled = true
	eye_material.emission = Color(1.0, 0.43, 0.08)
	eye_material.emission_energy_multiplier = 1.0

	# Short cloak-like body and compact feet, matching the reference silhouette.
	_add_box("BodyCloak", Vector3(0.72, 0.78, 0.53), Vector3(0.0, 0.62, 0.02), dark_cloth)
	_add_box("LeftSleeve", Vector3(0.22, 0.58, 0.27), Vector3(-0.43, 0.67, -0.015), dark_cloth)
	_add_box("RightSleeve", Vector3(0.22, 0.58, 0.27), Vector3(0.43, 0.67, -0.015), dark_cloth)
	_add_box("LeftFoot", Vector3(0.29, 0.26, 0.37), Vector3(-0.2, 0.14, 0.035), dark_cloth)
	_add_box("RightFoot", Vector3(0.29, 0.26, 0.37), Vector3(0.2, 0.14, 0.035), dark_cloth)

	# Broad angular cat hood with two pointed ears cut into the silhouette.
	var hood := MeshInstance3D.new()
	hood.name = "AngularCatHood"
	hood.mesh = _create_hood_mesh()
	hood.material_override = dark_cloth
	_visual_root.add_child(hood)

	# Rectangular amber eyes, inset against the black hood.
	var eye_socket := _make_material(Color(0.004, 0.004, 0.009), 1.0)
	_add_box("LeftEyeSocket", Vector3(0.27, 0.17, 0.055), Vector3(-0.235, 1.43, -0.49), eye_socket)
	_add_box("RightEyeSocket", Vector3(0.27, 0.17, 0.055), Vector3(0.235, 1.43, -0.49), eye_socket)
	var left_eye := _add_box("LeftAmberEye", Vector3(0.19, 0.105, 0.035), Vector3(-0.235, 1.43, -0.535), eye_material)
	var right_eye := _add_box("RightAmberEye", Vector3(0.19, 0.105, 0.035), Vector3(0.235, 1.43, -0.535), eye_material)
	left_eye.rotation.z = deg_to_rad(-5.0)
	right_eye.rotation.z = deg_to_rad(5.0)

	# Dark red scarf wrapped around the neck, with one long front end.
	_add_box("ScarfWrap", Vector3(0.88, 0.22, 0.66), Vector3(0.0, 1.03, -0.015), scarf_material)
	_add_box("ScarfFrontTail", Vector3(0.25, 0.68, 0.16), Vector3(0.18, 0.64, -0.39), scarf_material)
	_add_box("ScarfTailFold", Vector3(0.28, 0.12, 0.17), Vector3(0.18, 0.32, -0.39), scarf_edge)


func _create_hood_mesh() -> ArrayMesh:
	var outline: Array[Vector2] = [
		Vector2(-0.62, -0.48),
		Vector2(0.62, -0.48),
		Vector2(0.74, -0.08),
		Vector2(0.69, 0.32),
		Vector2(0.59, 0.74),
		Vector2(0.22, 0.59),
		Vector2(0.0, 0.40),
		Vector2(-0.22, 0.59),
		Vector2(-0.59, 0.74),
		Vector2(-0.69, 0.32),
		Vector2(-0.74, -0.08)
	]

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	var front_center := Vector3(0.0, 0.0, -0.45)
	var back_center := Vector3(0.0, 0.0, 0.38)
	var front_points: Array[Vector3] = []
	var back_points: Array[Vector3] = []

	for point in outline:
		front_points.append(Vector3(point.x, point.y + 1.47, -0.45))
		back_points.append(Vector3(point.x * 0.94, point.y * 0.94 + 1.47, 0.38))

	front_center.y = 1.47
	back_center.y = 1.47

	for index in range(outline.size()):
		var next_index := (index + 1) % outline.size()
		surface.add_vertex(front_center)
		surface.add_vertex(front_points[next_index])
		surface.add_vertex(front_points[index])

		surface.add_vertex(back_center)
		surface.add_vertex(back_points[index])
		surface.add_vertex(back_points[next_index])

		surface.add_vertex(front_points[index])
		surface.add_vertex(front_points[next_index])
		surface.add_vertex(back_points[next_index])

		surface.add_vertex(front_points[index])
		surface.add_vertex(back_points[next_index])
		surface.add_vertex(back_points[index])

	surface.generate_normals()
	return surface.commit()


func _add_box(
	mesh_name: String,
	box_size: Vector3,
	box_position: Vector3,
	material: Material
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = mesh_name
	var box := BoxMesh.new()
	box.size = box_size
	mesh_instance.mesh = box
	mesh_instance.material_override = material
	mesh_instance.position = box_position
	_visual_root.add_child(mesh_instance)
	return mesh_instance


func _make_material(color: Color, roughness_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness_value
	return material
