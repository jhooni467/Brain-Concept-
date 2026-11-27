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

	var cloak := _make_material(Color(0.012, 0.011, 0.019), 0.96)
	var cloak_facet := _make_material(Color(0.027, 0.023, 0.038), 0.92)
	var scarf := _make_material(Color(0.34, 0.012, 0.064), 0.88)
	var scarf_highlight := _make_material(Color(0.48, 0.025, 0.085), 0.82)
	var eye_socket := _make_material(Color(0.0015, 0.0015, 0.003), 1.0)
	var eye := _make_material(Color(1.0, 0.63, 0.16), 0.38)
	eye.emission_enabled = true
	eye.emission = Color(1.0, 0.34, 0.055)
	eye.emission_energy_multiplier = 1.25

	# Axel keeps the reference's distinctive silhouette: oversized cat hood,
	# tiny dark body, narrow amber eyes and a deep-red scarf.
	_add_box("ShortCloakBody", Vector3(0.58, 0.68, 0.46), Vector3(0.0, 0.56, 0.02), cloak)
	_add_box("LeftSleeve", Vector3(0.19, 0.46, 0.25), Vector3(-0.36, 0.59, 0.0), cloak)
	_add_box("RightSleeve", Vector3(0.19, 0.46, 0.25), Vector3(0.36, 0.59, 0.0), cloak)
	_add_box("LeftFoot", Vector3(0.23, 0.18, 0.30), Vector3(-0.16, 0.12, 0.035), cloak)
	_add_box("RightFoot", Vector3(0.23, 0.18, 0.30), Vector3(0.16, 0.12, 0.035), cloak)

	var hood := MeshInstance3D.new()
	hood.name = "AxelSignatureCatHood"
	hood.mesh = _create_hood_mesh()
	hood.material_override = cloak
	_visual_root.add_child(hood)

	# Subtle angular planes give the hood depth without changing its silhouette.
	_add_box("LeftHoodSideFacet", Vector3(0.12, 0.66, 0.58), Vector3(-0.61, 1.63, -0.015), cloak_facet)
	_add_box("RightHoodSideFacet", Vector3(0.12, 0.66, 0.58), Vector3(0.61, 1.63, -0.015), cloak_facet)

	# The eyes are deliberately slim and close-set, like the supplied character.
	_add_box("LeftEyeSocket", Vector3(0.235, 0.145, 0.055), Vector3(-0.205, 1.57, -0.535), eye_socket)
	_add_box("RightEyeSocket", Vector3(0.235, 0.145, 0.055), Vector3(0.205, 1.57, -0.535), eye_socket)
	var left_eye := _add_box("LeftAmberEye", Vector3(0.165, 0.085, 0.025), Vector3(-0.205, 1.57, -0.573), eye)
	var right_eye := _add_box("RightAmberEye", Vector3(0.165, 0.085, 0.025), Vector3(0.205, 1.57, -0.573), eye)
	left_eye.rotation.z = deg_to_rad(-3.0)
	right_eye.rotation.z = deg_to_rad(3.0)

	# Wide scarf covers the lower face; its single front tail hangs over the chest.
	_add_box("ScarfWrap", Vector3(0.94, 0.235, 0.72), Vector3(0.0, 1.12, -0.055), scarf)
	_add_box("ScarfUpperFold", Vector3(0.91, 0.045, 0.70), Vector3(0.0, 1.235, -0.065), scarf_highlight)
	_add_box("ScarfFrontTail", Vector3(0.25, 0.67, 0.15), Vector3(0.0, 0.70, -0.39), scarf)
	_add_box("ScarfTailFold", Vector3(0.25, 0.075, 0.16), Vector3(0.0, 0.385, -0.395), scarf_highlight)


func _create_hood_mesh() -> ArrayMesh:
	# Extruded angular outline, with tall pointed ears and a broad, squared-off head.
	var outline: Array[Vector2] = [
		Vector2(-0.58, -0.49),
		Vector2(0.58, -0.49),
		Vector2(0.69, -0.20),
		Vector2(0.67, 0.31),
		Vector2(0.61, 0.82),
		Vector2(0.22, 0.61),
		Vector2(0.0, 0.43),
		Vector2(-0.22, 0.61),
		Vector2(-0.61, 0.82),
		Vector2(-0.67, 0.31),
		Vector2(-0.69, -0.20)
	]

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var front_points: Array[Vector3] = []
	var back_points: Array[Vector3] = []
	for point in outline:
		front_points.append(Vector3(point.x, point.y + 1.68, -0.49))
		back_points.append(Vector3(point.x * 0.94, point.y * 0.94 + 1.68, 0.36))

	var front_center := Vector3(0.0, 1.68, -0.49)
	var back_center := Vector3(0.0, 1.68, 0.36)
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
