extends Node3D

const ROOM_WIDTH: float = 22.0
const ROOM_DEPTH: float = 34.0
const ROOM_CENTER_Z: float = 1.0
const WALL_HEIGHT: float = 5.3


func _ready() -> void:
	_setup_environment()
	_build_room()
	_build_windows()
	_build_washer_row()
	_build_seating_and_counter()
	_build_laundry_baskets()
	_build_vending_machine()
	_build_lighting()


func _setup_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.045, 0.052, 0.065)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.86)
	environment.ambient_light_energy = 0.92
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.12
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.24, 0.29, 0.35)
	environment.fog_density = 0.0025
	environment.glow_enabled = true
	environment.glow_intensity = 0.32
	environment.glow_bloom = 0.08
	world_environment.environment = environment
	add_child(world_environment)


func _build_room() -> void:
	var floor_material := _make_material(Color(0.7, 0.74, 0.76), 0.72)
	floor_material.albedo_texture = _create_floor_texture()
	floor_material.uv1_scale = Vector3(13.0, 1.0, 20.0)

	var wall_material := _make_material(Color(0.65, 0.67, 0.68), 0.94)
	wall_material.albedo_texture = _create_wall_texture()
	wall_material.uv1_scale = Vector3(3.5, 2.0, 1.0)

	var trim_material := _make_material(Color(0.19, 0.23, 0.25), 0.56, 0.24)
	var ceiling_material := _make_material(Color(0.43, 0.47, 0.49), 0.92)
	var accent_material := _make_material(Color(0.18, 0.36, 0.4), 0.58, 0.16)

	_create_static_box(
		"TileFloor",
		Vector3(ROOM_WIDTH, 0.4, ROOM_DEPTH),
		Vector3(0.0, -0.2, ROOM_CENTER_Z),
		floor_material
	)
	_create_static_box(
		"BackWall",
		Vector3(ROOM_WIDTH, WALL_HEIGHT, 0.35),
		Vector3(0.0, WALL_HEIGHT * 0.5, -16.0),
		wall_material
	)
	_create_static_box(
		"LeftWall",
		Vector3(0.35, WALL_HEIGHT, ROOM_DEPTH),
		Vector3(-11.15, WALL_HEIGHT * 0.5, ROOM_CENTER_Z),
		wall_material
	)
	_create_static_box(
		"RightWall",
		Vector3(0.35, WALL_HEIGHT, ROOM_DEPTH),
		Vector3(11.15, WALL_HEIGHT * 0.5, ROOM_CENTER_Z),
		wall_material
	)

	# The front wall has a central entrance instead of sealing the room.
	_create_static_box(
		"FrontWallLeft",
		Vector3(8.0, WALL_HEIGHT, 0.35),
		Vector3(-7.0, WALL_HEIGHT * 0.5, 18.0),
		wall_material
	)
	_create_static_box(
		"FrontWallRight",
		Vector3(8.0, WALL_HEIGHT, 0.35),
		Vector3(7.0, WALL_HEIGHT * 0.5, 18.0),
		wall_material
	)
	_create_static_box(
		"FrontEntranceHeader",
		Vector3(6.0, 0.8, 0.35),
		Vector3(0.0, 4.9, 18.0),
		wall_material
	)

	_add_box_mesh(self, "Ceiling", Vector3(ROOM_WIDTH, 0.28, ROOM_DEPTH), Vector3(0.0, 5.42, ROOM_CENTER_Z), ceiling_material)
	_add_box_mesh(self, "BackBaseTrim", Vector3(ROOM_WIDTH, 0.18, 0.22), Vector3(0.0, 0.13, -15.78), trim_material)
	_add_box_mesh(self, "LeftBaseTrim", Vector3(0.22, 0.18, ROOM_DEPTH), Vector3(-10.91, 0.13, ROOM_CENTER_Z), trim_material)
	_add_box_mesh(self, "RightBaseTrim", Vector3(0.22, 0.18, ROOM_DEPTH), Vector3(10.91, 0.13, ROOM_CENTER_Z), trim_material)
	_add_box_mesh(self, "BackAccentStripe", Vector3(ROOM_WIDTH, 0.16, 0.08), Vector3(0.0, 3.75, -15.78), accent_material)
	_add_box_mesh(self, "LeftAccentStripe", Vector3(0.08, 0.16, ROOM_DEPTH), Vector3(-10.91, 3.75, ROOM_CENTER_Z), accent_material)
	_add_box_mesh(self, "RightAccentStripe", Vector3(0.08, 0.16, ROOM_DEPTH), Vector3(10.91, 3.75, ROOM_CENTER_Z), accent_material)

	_build_entrance(trim_material, accent_material)
	_build_corridor(wall_material, floor_material, trim_material)


func _build_entrance(trim_material: Material, accent_material: Material) -> void:
	var frame_material := _make_material(Color(0.12, 0.16, 0.18), 0.44, 0.36)
	var glass_material := _make_material(Color(0.28, 0.42, 0.47, 0.38), 0.18, 0.2)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_material.albedo_color.a = 0.38

	_add_box_mesh(self, "EntranceFrameLeft", Vector3(0.16, 3.9, 0.18), Vector3(-2.94, 1.95, 17.76), frame_material)
	_add_box_mesh(self, "EntranceFrameRight", Vector3(0.16, 3.9, 0.18), Vector3(2.94, 1.95, 17.76), frame_material)
	_add_box_mesh(self, "EntranceFrameTop", Vector3(6.0, 0.16, 0.18), Vector3(0.0, 3.9, 17.76), frame_material)

	_add_box_mesh(self, "LeftGlassDoor", Vector3(2.78, 3.6, 0.055), Vector3(-1.42, 1.82, 17.78), glass_material)
	_add_box_mesh(self, "RightGlassDoor", Vector3(2.78, 3.6, 0.055), Vector3(1.42, 1.82, 17.78), glass_material)
	_add_box_mesh(self, "DoorHandleLeft", Vector3(0.055, 0.55, 0.09), Vector3(-0.22, 1.7, 17.66), trim_material)
	_add_box_mesh(self, "DoorHandleRight", Vector3(0.055, 0.55, 0.09), Vector3(0.22, 1.7, 17.66), trim_material)
	_add_box_mesh(self, "EntranceSign", Vector3(2.0, 0.28, 0.08), Vector3(0.0, 4.42, 17.68), accent_material)


func _build_corridor(wall_material: Material, floor_material: Material, trim_material: Material) -> void:
	_create_static_box("EntryWalkway", Vector3(6.0, 0.3, 7.0), Vector3(0.0, -0.16, 21.5), floor_material)
	_create_static_box("EntrySideLeft", Vector3(0.25, 4.7, 7.0), Vector3(-3.0, 2.2, 21.5), wall_material)
	_create_static_box("EntrySideRight", Vector3(0.25, 4.7, 7.0), Vector3(3.0, 2.2, 21.5), wall_material)
	_create_static_box("EntryEndWall", Vector3(6.0, 4.7, 0.25), Vector3(0.0, 2.2, 25.0), wall_material)
	_add_box_mesh(self, "EntryBaseTrimLeft", Vector3(0.12, 0.15, 7.0), Vector3(-2.82, 0.12, 21.5), trim_material)
	_add_box_mesh(self, "EntryBaseTrimRight", Vector3(0.12, 0.15, 7.0), Vector3(2.82, 0.12, 21.5), trim_material)


func _build_windows() -> void:
	var frame_material := _make_material(Color(0.14, 0.19, 0.22), 0.42, 0.3)
	var glass_material := _make_material(Color(0.22, 0.38, 0.44), 0.2, 0.18)
	glass_material.emission_enabled = true
	glass_material.emission = Color(0.07, 0.12, 0.15)
	glass_material.emission_energy_multiplier = 0.35

	for window_index in range(3):
		var z_position := -7.0 + float(window_index) * 7.0
		_add_box_mesh(self, "WindowGlass_%d" % window_index, Vector3(0.055, 1.55, 4.8), Vector3(-10.94, 3.02, z_position), glass_material)
		_add_box_mesh(self, "WindowFrameTop_%d" % window_index, Vector3(0.12, 0.12, 5.0), Vector3(-10.87, 3.86, z_position), frame_material)
		_add_box_mesh(self, "WindowFrameBottom_%d" % window_index, Vector3(0.12, 0.12, 5.0), Vector3(-10.87, 2.18, z_position), frame_material)
		_add_box_mesh(self, "WindowFrameSideA_%d" % window_index, Vector3(0.12, 1.8, 0.12), Vector3(-10.87, 3.02, z_position - 2.48), frame_material)
		_add_box_mesh(self, "WindowFrameSideB_%d" % window_index, Vector3(0.12, 1.8, 0.12), Vector3(-10.87, 3.02, z_position + 2.48), frame_material)
		_add_box_mesh(self, "WindowMullion_%d" % window_index, Vector3(0.12, 1.55, 0.1), Vector3(-10.84, 3.02, z_position), frame_material)


func _build_washer_row() -> void:
	var positions: Array[float] = [-8.5, -4.25, 0.0, 4.25, 8.5]
	for index in range(positions.size()):
		_create_washer(index + 1, positions[index])


func _create_washer(number: int, x_position: float) -> void:
	var steel := _make_material(Color(0.55, 0.59, 0.61), 0.3, 0.62)
	var dark_steel := _make_material(Color(0.085, 0.11, 0.13), 0.42, 0.45)
	var glass := _make_material(Color(0.035, 0.085, 0.11), 0.12, 0.24)
	var display := _make_material(Color(0.18, 0.8, 0.72), 0.3)
	display.emission_enabled = true
	display.emission = Color(0.08, 0.62, 0.54)
	display.emission_energy_multiplier = 1.1

	var machine := StaticBody3D.new()
	machine.name = "Washer_%02d" % number
	machine.position = Vector3(x_position, 0.0, -13.65)
	add_child(machine)

	var collision := CollisionShape3D.new()
	var collision_box := BoxShape3D.new()
	collision_box.size = Vector3(2.05, 2.35, 1.28)
	collision.shape = collision_box
	collision.position = Vector3(0.0, 1.18, 0.0)
	machine.add_child(collision)

	_add_box_mesh(machine, "SteelCabinet", Vector3(2.0, 2.25, 1.2), Vector3(0.0, 1.18, 0.0), steel)
	_add_box_mesh(machine, "KickPlate", Vector3(1.85, 0.18, 1.22), Vector3(0.0, 0.12, 0.0), dark_steel)
	_add_box_mesh(machine, "ControlPanel", Vector3(1.76, 0.34, 0.08), Vector3(0.0, 2.0, 0.63), dark_steel)
	_add_box_mesh(machine, "DigitalDisplay", Vector3(0.54, 0.15, 0.035), Vector3(-0.37, 2.02, 0.69), display)
	_add_box_mesh(machine, "ButtonRow", Vector3(0.65, 0.1, 0.035), Vector3(0.53, 2.02, 0.69), dark_steel)

	_add_front_disc(machine, "OuterDoorRim", 0.68, 0.08, Vector3(0.0, 1.13, 0.64), steel, 36)
	_add_front_disc(machine, "InnerDoorRim", 0.55, 0.09, Vector3(0.0, 1.13, 0.705), dark_steel, 36)
	_add_front_disc(machine, "DoorGlass", 0.45, 0.1, Vector3(0.0, 1.13, 0.765), glass, 36)

	_add_box_mesh(machine, "WasherNumberPlate", Vector3(0.32, 0.16, 0.035), Vector3(0.0, 2.34, 0.63), dark_steel)
	_add_box_mesh(machine, "WasherSideHighlight", Vector3(0.045, 1.72, 0.03), Vector3(-0.91, 1.22, 0.62), _make_material(Color(0.78, 0.81, 0.82), 0.3, 0.4))


func _add_front_disc(
	parent: Node3D,
	mesh_name: String,
	radius_value: float,
	depth: float,
	local_position: Vector3,
	material: Material,
	segments: int
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = mesh_name
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius_value
	cylinder.bottom_radius = radius_value
	cylinder.height = depth
	cylinder.radial_segments = segments
	mesh_instance.mesh = cylinder
	mesh_instance.material_override = material
	mesh_instance.position = local_position
	mesh_instance.rotation_degrees.x = 90.0
	parent.add_child(mesh_instance)


func _build_seating_and_counter() -> void:
	var bench_material := _make_material(Color(0.22, 0.3, 0.32), 0.64, 0.18)
	var frame_material := _make_material(Color(0.1, 0.14, 0.16), 0.55, 0.48)
	var counter_material := _make_material(Color(0.36, 0.4, 0.41), 0.72)

	# Waiting bench on the left side.
	_add_box_mesh(self, "BenchSeat", Vector3(4.2, 0.22, 0.72), Vector3(-7.6, 0.78, 5.4), bench_material)
	_add_box_mesh(self, "BenchBack", Vector3(4.2, 0.85, 0.16), Vector3(-7.6, 1.28, 5.72), bench_material)
	for leg_x in [-9.2, -6.0]:
		_add_box_mesh(self, "BenchLeg_%s" % str(leg_x), Vector3(0.16, 0.75, 0.16), Vector3(leg_x, 0.38, 5.4), frame_material)

	# Folding counter and a small service desk on the right.
	_create_static_box("ServiceCounter", Vector3(1.4, 1.05, 5.5), Vector3(9.1, 0.55, 5.3), counter_material)
	_add_box_mesh(self, "CounterTop", Vector3(1.65, 0.14, 5.75), Vector3(9.1, 1.12, 5.3), bench_material)
	_add_box_mesh(self, "CounterRegister", Vector3(0.62, 0.48, 0.52), Vector3(8.3, 1.42, 3.8), frame_material)
	_add_box_mesh(self, "RegisterScreen", Vector3(0.42, 0.22, 0.06), Vector3(8.3, 1.53, 3.52), _make_emission_material(Color(0.44, 0.78, 0.72), Color(0.12, 0.42, 0.35), 0.7))

	# A metal utility sink beside the service counter.
	_create_static_box("UtilitySinkCabinet", Vector3(1.4, 0.95, 1.5), Vector3(9.15, 0.48, -3.4), frame_material)
	_add_box_mesh(self, "UtilitySinkBasin", Vector3(1.52, 0.16, 1.62), Vector3(9.15, 1.03, -3.4), steel_material())
	_add_box_mesh(self, "SinkTapStem", Vector3(0.08, 0.42, 0.08), Vector3(9.15, 1.3, -2.75), frame_material)
	_add_box_mesh(self, "SinkTapTop", Vector3(0.4, 0.08, 0.08), Vector3(9.15, 1.5, -2.75), frame_material)


func _build_laundry_baskets() -> void:
	_create_basket("Basket_Left", Vector3(-5.3, 0.0, -7.2), Color(0.55, 0.3, 0.2))
	_create_basket("Basket_Center", Vector3(3.8, 0.0, -7.0), Color(0.24, 0.34, 0.38))
	_create_basket("Basket_Bench", Vector3(-5.8, 0.0, 7.3), Color(0.34, 0.39, 0.42))


func _create_basket(basket_name: String, basket_position: Vector3, basket_color: Color) -> void:
	var basket_material := _make_material(basket_color, 0.82)
	var basket := StaticBody3D.new()
	basket.name = basket_name
	basket.position = basket_position
	add_child(basket)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.05, 0.62, 0.82)
	collision.shape = shape
	collision.position.y = 0.32
	basket.add_child(collision)

	_add_box_mesh(basket, "BasketBase", Vector3(1.0, 0.08, 0.78), Vector3(0.0, 0.06, 0.0), basket_material)
	for side_x in [-0.48, 0.48]:
		_add_box_mesh(basket, "BasketSide_%s" % str(side_x), Vector3(0.08, 0.58, 0.78), Vector3(side_x, 0.34, 0.0), basket_material)
	for side_z in [-0.36, 0.36]:
		_add_box_mesh(basket, "BasketEnd_%s" % str(side_z), Vector3(0.88, 0.58, 0.08), Vector3(0.0, 0.34, side_z), basket_material)
	for slat_y in [0.18, 0.36, 0.52]:
		_add_box_mesh(basket, "BasketSlat_%s" % str(slat_y), Vector3(0.9, 0.035, 0.035), Vector3(0.0, slat_y, -0.4), _make_material(basket_color.lightened(0.12), 0.78))


func _build_vending_machine() -> void:
	var body_material := _make_material(Color(0.18, 0.24, 0.27), 0.54, 0.22)
	var glass_material := _make_material(Color(0.12, 0.24, 0.28, 0.72), 0.2, 0.12)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var machine := StaticBody3D.new()
	machine.name = "VendingMachine"
	machine.position = Vector3(-9.55, 0.0, -4.4)
	add_child(machine)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.65, 2.6, 1.3)
	collision.shape = shape
	collision.position.y = 1.3
	machine.add_child(collision)

	_add_box_mesh(machine, "VendingBody", Vector3(1.6, 2.55, 1.25), Vector3(0.0, 1.28, 0.0), body_material)
	_add_box_mesh(machine, "VendingWindow", Vector3(1.24, 1.65, 0.06), Vector3(0.0, 1.55, 0.66), glass_material)
	_add_box_mesh(machine, "VendingControl", Vector3(0.22, 1.62, 0.08), Vector3(0.68, 1.5, 0.66), body_material)
	_add_box_mesh(machine, "VendingSlot", Vector3(0.52, 0.16, 0.08), Vector3(0.47, 0.48, 0.66), _make_emission_material(Color(0.3, 0.74, 0.68), Color(0.08, 0.35, 0.3), 0.6))

	for product_index in range(4):
		var product_color := [Color(0.7, 0.38, 0.22), Color(0.25, 0.52, 0.58), Color(0.72, 0.66, 0.36), Color(0.52, 0.35, 0.58)][product_index]
		_add_box_mesh(machine, "Product_%d" % product_index, Vector3(0.22, 0.42, 0.12), Vector3(-0.42 + float(product_index % 2) * 0.56, 0.82 + float(product_index / 2) * 0.62, 0.72), _make_material(product_color, 0.45))


func _build_lighting() -> void:
	var directional := DirectionalLight3D.new()
	directional.name = "SoftInteriorFill"
	directional.rotation_degrees = Vector3(-58.0, -25.0, 0.0)
	directional.light_color = Color(0.76, 0.82, 0.9)
	directional.light_energy = 0.58
	directional.shadow_enabled = false
	add_child(directional)

	var light_positions: Array[float] = [-10.5, -2.8, 5.0, 12.5]
	for index in range(light_positions.size()):
		_create_fluorescent_light(index, light_positions[index])


func _create_fluorescent_light(index: int, z_position: float) -> void:
	var panel_material := _make_emission_material(
		Color(0.78, 0.88, 0.9),
		Color(0.55, 0.72, 0.78),
		0.95
	)
	_add_box_mesh(self, "CeilingPanel_%d" % index, Vector3(6.2, 0.045, 0.72), Vector3(0.0, 5.21, z_position), panel_material)
	_add_box_mesh(self, "CeilingPanelTrim_%d" % index, Vector3(6.42, 0.07, 0.88), Vector3(0.0, 5.25, z_position), _make_material(Color(0.18, 0.21, 0.23), 0.58))

	var light := OmniLight3D.new()
	light.name = "CeilingLight_%d" % index
	light.position = Vector3(0.0, 4.65, z_position)
	light.light_color = Color(0.77, 0.88, 0.92)
	light.light_energy = 2.35
	light.omni_range = 13.5
	light.shadow_enabled = false
	add_child(light)


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


func _make_emission_material(
	color: Color,
	emission_color: Color,
	emission_strength: float
) -> StandardMaterial3D:
	var material := _make_material(color, 0.38, 0.08)
	material.emission_enabled = true
	material.emission = emission_color
	material.emission_energy_multiplier = emission_strength
	return material


func steel_material() -> StandardMaterial3D:
	return _make_material(Color(0.57, 0.62, 0.64), 0.28, 0.58)


func _create_floor_texture() -> Texture2D:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var tile_x := floori(float(x) / 32.0)
			var tile_y := floori(float(y) / 32.0)
			var variation := float((tile_x * 7 + tile_y * 11) % 5) * 0.012
			var color := Color(0.56 + variation, 0.62 + variation, 0.64 + variation, 1.0)
			if x % 32 < 2 or y % 32 < 2:
				color = Color(0.31, 0.39, 0.42, 1.0)
			elif (x + y * 3) % 29 == 0:
				color = color.darkened(0.035)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _create_wall_texture() -> Texture2D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(64):
			var variation := float((x * 5 + y * 3) % 9) * 0.003
			var color := Color(0.68 + variation, 0.7 + variation, 0.7 + variation, 1.0)
			if y % 32 == 0:
				color = Color(0.55, 0.58, 0.59, 1.0)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)
