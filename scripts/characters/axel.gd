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
	capsule.radius = 0.32
	capsule.height = 2.28
	collision.shape = capsule
	collision.position.y = 1.14
	add_child(collision)


func _build_model() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "AxelVisual"
	add_child(_visual_root)

	var cloak := _make_material(Color(0.012, 0.011, 0.019), 0.96)
	var cloak_facet := _make_material(Color(0.027, 0.024, 0.039), 0.94)
	var scarf := _make_material(Color(0.34, 0.012, 0.064), 0.88)
	var scarf_highlight := _make_material(Color(0.48, 0.025, 0.085), 0.82)
	var eye_socket := _make_material(Color(0.0015, 0.0015, 0.003), 1.0)
	var eye := _make_material(Color(1.0, 0.63, 0.16), 0.38)
	eye.emission_enabled = true
	eye.emission = Color(1.0, 0.34, 0.055)
	eye.emission_energy_multiplier = 1.25

	# Compact cloak body. The head and ears are separate meshes so no concave
	# polygon fan can fold over itself or produce broken triangles.
	var body_mesh := MeshInstance3D.new()
	body_mesh.name = "CloakBody"
	var body_shape := CylinderMesh.new()
	body_shape.top_radius = 0.27
	body_shape.bottom_radius = 0.40
	body_shape.height = 0.82
	body_shape.radial_segments = 8
	body_mesh.mesh = body_shape
	body_mesh.material_override = cloak
	body_mesh.position = Vector3(0.0, 0.49, 0.035)
	_visual_root.add_child(body_mesh)

	_add_box("LeftSleeve", Vector3(0.19, 0.48, 0.25), Vector3(-0.37, 0.57, 0.01), cloak)
	_add_box("RightSleeve", Vector3(0.19, 0.48, 0.25), Vector3(0.37, 0.57, 0.01), cloak)
	_add_box("LeftFoot", Vector3(0.23, 0.18, 0.31), Vector3(-0.16, 0.11, 0.07), cloak)
	_add_box("RightFoot", Vector3(0.23, 0.18, 0.31), Vector3(0.16, 0.11, 0.07), cloak)

	# Broad square hood and two independent pointed ears: stable, closed geometry.
	_add_box("CatHoodHead", Vector3(1.30, 1.12, 0.84), Vector3(0.0, 1.56, 0.0), cloak)
	_add_ear("LeftPointedEar", Vector3(-0.49, 1.96, 0.0), 0.58, 0.72, 0.78, cloak)
	_add_ear("RightPointedEar", Vector3(0.49, 1.96, 0.0), 0.58, 0.72, 0.78, cloak)

	# Slightly darker cheek planes give the hood volume while preserving its outline.
	_add_box("LeftCheekFacet", Vector3(0.12, 0.58, 0.68), Vector3(-0.615, 1.48, -0.01), cloak_facet)
	_add_box("RightCheekFacet", Vector3(0.12, 0.58, 0.68), Vector3(0.615, 1.48, -0.01), cloak_facet)

	# Eye recesses and amber rectangular eyes are fixed to the front surface.
	_add_box("LeftEyeSocket", Vector3(0.245, 0.145, 0.045), Vector3(-0.225, 1.55, -0.445), eye_socket)
	_add_box("RightEyeSocket", Vector3(0.245, 0.145, 0.045), Vector3(0.225, 1.55, -0.445), eye_socket)
	var left_eye := _add_box("LeftAmberEye", Vector3(0.17, 0.085, 0.026), Vector3(-0.225, 1.55, -0.481), eye)
	var right_eye := _add_box("RightAmberEye", Vector3(0.17, 0.085, 0.026), Vector3(0.225, 1.55, -0.481), eye)
	left_eye.rotation.z = deg_to_rad(-3.0)
	right_eye.rotation.z = deg_to_rad(3.0)

	# Scarf wraps around the neck. Its single long end hangs on Axel's right,
	# rather than running down the center of the face/body.
	_add_box("ScarfWrap", Vector3(1.12, 0.27, 0.82), Vector3(0.0, 1.08, -0.015), scarf)
	_add_box("ScarfUpperFold", Vector3(1.00, 0.045, 0.72), Vector3(0.0, 1.225, -0.055), scarf_highlight)
	var scarf_tail := _add_box(
		"ScarfRightTail",
		Vector3(0.24, 0.70, 0.12),
		Vector3(0.37, 0.66, -0.43),
		scarf
	)
	scarf_tail.rotation.z = deg_to_rad(-3.0)
	_add_box("ScarfTailFold", Vector3(0.24, 0.07, 0.13), Vector3(0.37, 0.33, -0.445), scarf_highlight)


func _add_ear(
	mesh_name: String,
	base_position: Vector3,
	width: float,
	height: float,
	depth: float,
	material: Material
) -> void:
	var ear := MeshInstance3D.new()
	ear.name = mesh_name
	ear.mesh = _create_ear_mesh(width, height, depth)
	ear.material_override = material
	ear.position = base_position
	_visual_root.add_child(ear)


func _create_ear_mesh(width: float, height: float, depth: float) -> ArrayMesh:
	var front_left := Vector3(-width * 0.5, 0.0, -depth * 0.5)
	var front_right := Vector3(width * 0.5, 0.0, -depth * 0.5)
	var front_tip := Vector3(0.0, height, -depth * 0.34)
	var back_left := Vector3(-width * 0.5, 0.0, depth * 0.5)
	var back_right := Vector3(width * 0.5, 0.0, depth * 0.5)
	var back_tip := Vector3(0.0, height, depth * 0.34)

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Front and back triangles.
	_add_triangle(surface, front_left, front_tip, front_right)
	_add_triangle(surface, back_left, back_right, back_tip)

	# Closed sides prevent the ears from looking like thin, broken sheets.
	_add_triangle(surface, front_left, back_left, back_tip)
	_add_triangle(surface, front_left, back_tip, front_tip)
	_add_triangle(surface, front_right, front_tip, back_tip)
	_add_triangle(surface, front_right, back_tip, back_right)
	_add_triangle(surface, front_left, front_right, back_right)
	_add_triangle(surface, front_left, back_right, back_left)

	surface.generate_normals()
	return surface.commit()


func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_vertex(c)


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
