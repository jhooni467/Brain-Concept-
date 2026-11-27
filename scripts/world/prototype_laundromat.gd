extends Node3D


func _ready() -> void:
	_setup_environment()
	_build_room()
	_build_washers()
	_build_lighting()


func _setup_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.012, 0.014, 0.019)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.28, 0.32, 0.4)
	environment.ambient_light_energy = 0.62
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.12, 0.15, 0.19)
	environment.fog_density = 0.008
	world_environment.environment = environment
	add_child(world_environment)


func _build_room() -> void:
	var wall_material := _make_material(Color(0.075, 0.085, 0.095), 0.94)
	var floor_material := _make_material(Color(0.045, 0.052, 0.058), 0.72)
	var trim_material := _make_material(Color(0.16, 0.18, 0.2), 0.68, 0.35)

	_create_static_box(
		"Floor",
		Vector3(18.0, 0.3, 28.0),
		Vector3(0.0, -0.15, 3.0),
		floor_material
	)
	_create_static_box(
		"BackWall",
		Vector3(18.0, 5.0, 0.3),
		Vector3(0.0, 2.5, -11.1),
		wall_material
	)
	_create_static_box(
		"FrontWall",
		Vector3(18.0, 5.0, 0.3),
		Vector3(0.0, 2.5, 17.1),
		wall_material
	)
	_create_static_box(
		"LeftWall",
		Vector3(0.3, 5.0, 28.0),
		Vector3(-9.1, 2.5, 3.0),
		wall_material
	)
	_create_static_box(
		"RightWall",
		Vector3(0.3, 5.0, 28.0),
		Vector3(9.1, 2.5, 3.0),
		wall_material
	)

	_add_box_mesh(
		self,
		"BackWallTrim",
		Vector3(18.0, 0.12, 0.34),
		Vector3(0.0, 0.12, -10.88),
		trim_material
	)


func _build_washers() -> void:
	var positions := [-5.2, -2.6, 0.0, 2.6, 5.2]
	for index in range(positions.size()):
		_create_washer(index + 1, float(positions[index]))


func _create_washer(number: int, x_position: float) -> void:
	var steel := _make_material(Color(0.34, 0.38, 0.4), 0.42, 0.72)
	var dark_steel := _make_material(Color(0.095, 0.11, 0.12), 0.5, 0.5)
	var glass := _make_material(Color(0.018, 0.045, 0.06), 0.24, 0.38)
	var panel := _make_material(Color(0.025, 0.06, 0.07), 0.42, 0.3)
	var display := _make_material(Color(0.18, 0.72, 0.68), 0.35)
	display.emission_enabled = true
	display.emission = Color(0.06, 0.36, 0.32)
	display.emission_energy_multiplier = 0.65

	var machine := StaticBody3D.new()
	machine.name = "Washer_%02d" % number
	machine.position = Vector3(x_position, 0.0, -9.55)
	add_child(machine)

	var collision := CollisionShape3D.new()
	var collision_box := BoxShape3D.new()
	collision_box.size = Vector3(2.05, 2.05, 1.12)
	collision.shape = collision_box
	collision.position = Vector3(0.0, 1.03, 0.0)
	machine.add_child(collision)

	_add_box_mesh(
		machine,
		"SteelCabinet",
		Vector3(2.0, 2.0, 1.08),
		Vector3(0.0, 1.02, 0.0),
		steel
	)
	_add_box_mesh(
		machine,
		"ControlPanel",
		Vector3(1.72, 0.27, 0.08),
		Vector3(0.0, 1.78, 0.56),
		dark_steel
	)
	_add_box_mesh(
		machine,
		"DigitalDisplay",
		Vector3(0.5, 0.14, 0.025),
		Vector3(-0.31, 1.79, 0.615),
		display
	)

	_add_front_disc(machine, "OuterDoorRim", 0.59, 0.07, Vector3(0.0, 1.02, 0.57), steel)
	_add_front_disc(machine, "InnerDoorRim", 0.49, 0.075, Vector3(0.0, 1.02, 0.625), dark_steel)
	_add_front_disc(machine, "DoorGlass", 0.405, 0.08, Vector3(0.0, 1.02, 0.675), glass)


func _add_front_disc(
	parent: Node3D,
	mesh_name: String,
	radius_value: float,
	depth: float,
	local_position: Vector3,
	material: Material
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = mesh_name
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius_value
	cylinder.bottom_radius = radius_value
	cylinder.height = depth
	cylinder.radial_segments = 24
	mesh_instance.mesh = cylinder
	mesh_instance.material_override = material
	mesh_instance.position = local_position
	mesh_instance.rotation_degrees.x = 90.0
	parent.add_child(mesh_instance)


func _build_lighting() -> void:
	var ceiling_light := OmniLight3D.new()
	ceiling_light.name = "ColdCeilingLight"
	ceiling_light.position = Vector3(0.0, 4.2, -4.4)
	ceiling_light.light_color = Color(0.62, 0.76, 0.82)
	ceiling_light.light_energy = 1.15
	ceiling_light.omni_range = 17.0
	ceiling_light.shadow_enabled = false
	add_child(ceiling_light)

	var side_light := OmniLight3D.new()
	side_light.name = "FaintSideLight"
	side_light.position = Vector3(-6.8, 3.2, 1.5)
	side_light.light_color = Color(0.38, 0.52, 0.54)
	side_light.light_energy = 0.48
	side_light.omni_range = 10.0
	side_light.shadow_enabled = false
	add_child(side_light)

	var directional := DirectionalLight3D.new()
	directional.name = "SoftAmbientDirection"
	directional.rotation_degrees = Vector3(-55.0, -24.0, 0.0)
	directional.light_color = Color(0.55, 0.59, 0.68)
	directional.light_energy = 0.22
	directional.shadow_enabled = false
	add_child(directional)


func _create_static_box(
	box_name: String,
	box_size: Vector3,
	box_position: Vector3,
	material: Material
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = box_name
	body.position = box_position
	add_child(body)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape
	body.add_child(collision)

	_add_box_mesh(body, "Mesh", box_size, Vector3.ZERO, material)
	return body


func _add_box_mesh(
	parent: Node3D,
	mesh_name: String,
	box_size: Vector3,
	local_position: Vector3,
	material: Material
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = mesh_name
	var box := BoxMesh.new()
	box.size = box_size
	mesh_instance.mesh = box
	mesh_instance.material_override = material
	mesh_instance.position = local_position
	parent.add_child(mesh_instance)
	return mesh_instance


func _make_material(
	color: Color,
	roughness_value: float,
	metallic_value: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness_value
	material.metallic = metallic_value
	return material
