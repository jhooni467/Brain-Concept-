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
	_build_outdoor_map()
	_build_tree_forest()
	_build_waiting_bench()
	_build_guard_gate()
	_build_rockside_atm()
	_build_crt_pool()
	_build_purple_signal()
	_build_palm_tree()
	_build_liminal_details()
	_build_lighting()


func _setup_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.035, 0.045, 0.085)
	sky_material.sky_horizon_color = Color(0.24, 0.20, 0.31)
	sky_material.ground_bottom_color = Color(0.018, 0.024, 0.035)
	sky_material.ground_horizon_color = Color(0.12, 0.13, 0.19)
	sky_material.energy_multiplier = 0.72
	sky.sky_material = sky_material
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.48, 0.50, 0.67)
	environment.ambient_light_energy = 0.68
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 0.92
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.19, 0.16, 0.27)
	environment.fog_density = 0.0032
	# Restrained emissive accents keep the liminal mood without a costly full-screen glow pass.
	environment.glow_enabled = false
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
	# The corridor stays open at its far end so the player can reach the outside map.
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

	# Waiting bench with a single blocking collision volume.
	var indoor_bench := StaticBody3D.new()
	indoor_bench.name = "IndoorWaitingBench"
	indoor_bench.position = Vector3(-7.6, 0.0, 5.4)
	add_child(indoor_bench)
	var bench_collision := CollisionShape3D.new()
	var bench_shape := BoxShape3D.new()
	bench_shape.size = Vector3(4.2, 1.45, 0.9)
	bench_collision.shape = bench_shape
	bench_collision.position.y = 0.8
	indoor_bench.add_child(bench_collision)
	_add_box_mesh(indoor_bench, "BenchSeat", Vector3(4.2, 0.22, 0.72), Vector3(0.0, 0.78, 0.0), bench_material)
	_add_box_mesh(indoor_bench, "BenchBack", Vector3(4.2, 0.85, 0.16), Vector3(0.0, 1.28, 0.32), bench_material)
	for leg_x in [-1.6, 1.6]:
		_add_box_mesh(indoor_bench, "BenchLeg_%s" % str(leg_x), Vector3(0.16, 0.75, 0.16), Vector3(leg_x, 0.38, 0.0), frame_material)

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

	var product_colors: Array[Color] = [
		Color(0.7, 0.38, 0.22),
		Color(0.25, 0.52, 0.58),
		Color(0.72, 0.66, 0.36),
		Color(0.52, 0.35, 0.58)
	]
	for product_index in range(product_colors.size()):
		var product_color: Color = product_colors[product_index]
		_add_box_mesh(machine, "Product_%d" % product_index, Vector3(0.22, 0.42, 0.12), Vector3(-0.42 + float(product_index % 2) * 0.56, 0.82 + float(floori(float(product_index) / 2.0)) * 0.62, 0.72), _make_material(product_color, 0.45))


func _build_lighting() -> void:
	var directional := DirectionalLight3D.new()
	directional.name = "CoolMoonlight"
	directional.rotation_degrees = Vector3(-42.0, -28.0, 0.0)
	directional.light_color = Color(0.62, 0.66, 0.92)
	directional.light_energy = 0.82
	directional.shadow_enabled = false
	add_child(directional)

	# One broad interior fill replaces four overlapping real-time lights.
	var interior_light := OmniLight3D.new()
	interior_light.name = "LaundryCeilingFill"
	interior_light.position = Vector3(0.0, 4.4, -3.2)
	interior_light.light_color = Color(0.78, 0.88, 0.94)
	interior_light.light_energy = 1.12
	interior_light.omni_range = 23.0
	interior_light.shadow_enabled = false
	add_child(interior_light)

	var panel_material := _make_emission_material(
		Color(0.78, 0.88, 0.9),
		Color(0.48, 0.66, 0.72),
		0.72
	)
	var panel_positions: Array[float] = [-10.5, -3.0, 4.5, 12.0]
	for index in range(panel_positions.size()):
		var z_position: float = panel_positions[index]
		_add_box_mesh(self, "CeilingPanel_%d" % index, Vector3(6.2, 0.045, 0.72), Vector3(0.0, 5.21, z_position), panel_material)
		_add_box_mesh(self, "CeilingPanelTrim_%d" % index, Vector3(6.42, 0.07, 0.88), Vector3(0.0, 5.25, z_position), _make_material(Color(0.18, 0.21, 0.23), 0.58))


func _build_liminal_details() -> void:
	var pole_material := _make_material(Color(0.105, 0.12, 0.15), 0.62, 0.32)
	var lamp_material := _make_emission_material(Color(0.78, 0.82, 0.96), Color(0.36, 0.48, 1.0), 1.35)
	var lamp_positions: Array[Vector3] = [
		Vector3(-8.0, 0.0, 58.0),
		Vector3(8.0, 0.0, 116.0),
		Vector3(-18.0, 0.0, 166.0),
		Vector3(20.0, 0.0, 190.0)
	]
	for index in range(lamp_positions.size()):
		var lamp := StaticBody3D.new()
		lamp.name = "RoadLamp_%02d" % index
		lamp.position = lamp_positions[index]
		add_child(lamp)
		var pole_shape := CylinderShape3D.new()
		pole_shape.radius = 0.13
		pole_shape.height = 7.8
		var pole_collision := CollisionShape3D.new()
		pole_collision.shape = pole_shape
		pole_collision.position.y = 3.9
		lamp.add_child(pole_collision)
		var pole_mesh := CylinderMesh.new()
		pole_mesh.top_radius = 0.09
		pole_mesh.bottom_radius = 0.15
		pole_mesh.height = 7.8
		pole_mesh.radial_segments = 12
		var pole_visual := MeshInstance3D.new()
		pole_visual.mesh = pole_mesh
		pole_visual.material_override = pole_material
		pole_visual.position.y = 3.9
		lamp.add_child(pole_visual)
		_add_box_mesh(lamp, "LampArm", Vector3(1.25, 0.10, 0.10), Vector3(0.52, 7.55, 0.0), pole_material)
		_add_box_mesh(lamp, "LampHousing", Vector3(0.68, 0.16, 0.42), Vector3(1.04, 7.48, 0.0), pole_material)
		_add_box_mesh(lamp, "LampLens", Vector3(0.54, 0.035, 0.30), Vector3(1.04, 7.38, 0.0), lamp_material)
		if index % 2 == 0:
			var light := OmniLight3D.new()
			light.name = "LampPool_%02d" % index
			light.position = Vector3(1.04, 7.15, 0.0)
			light.light_color = Color(0.43, 0.52, 1.0)
			light.light_energy = 0.48
			light.omni_range = 11.0
			light.shadow_enabled = false
			lamp.add_child(light)

	var fence_material := _make_material(Color(0.19, 0.22, 0.25), 0.78, 0.18)
	for side in [-1.0, 1.0]:
		for index in range(13):
			var z_position := 48.0 + float(index) * 5.2
			var post := _add_box_mesh(
				self,
				"FencePost_%s_%02d" % [str(side), index],
				Vector3(0.12, 1.25, 0.12),
				Vector3(side * 15.0, 0.62, z_position),
				fence_material
			)
			post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_add_box_mesh(
			self,
			"FenceRail_%s" % str(side),
			Vector3(0.10, 0.10, 67.0),
			Vector3(side * 15.0, 0.92, 79.0),
			fence_material
		)

	var sign_frame := _make_material(Color(0.12, 0.14, 0.19), 0.48, 0.25)
	var sign_face := _make_emission_material(Color(0.18, 0.23, 0.31), Color(0.08, 0.12, 0.22), 0.32)
	for index in range(3):
		var sign := StaticBody3D.new()
		sign.name = "RepeatedRoadSign_%02d" % index
		sign.position = Vector3(11.8, 0.0, 72.0 + float(index) * 34.0)
		add_child(sign)
		var post_shape := BoxShape3D.new()
		post_shape.size = Vector3(0.12, 2.8, 0.12)
		var post_collision := CollisionShape3D.new()
		post_collision.shape = post_shape
		post_collision.position.y = 1.4
		sign.add_child(post_collision)
		_add_box_mesh(sign, "SignPost", Vector3(0.12, 2.8, 0.12), Vector3(0.0, 1.4, 0.0), pole_material)
		_add_box_mesh(sign, "SignBorder", Vector3(1.8, 0.9, 0.12), Vector3(0.0, 2.55, -0.04), sign_frame)
		_add_box_mesh(sign, "SignFace", Vector3(1.62, 0.72, 0.035), Vector3(0.0, 2.55, -0.115), sign_face)
		var lettering := Label3D.new()
		lettering.name = "RepeatedText"
		lettering.text = "STAY HERE"
		lettering.font_size = 32
		lettering.pixel_size = 0.004
		lettering.modulate = Color(0.78, 0.82, 1.0, 0.88)
		lettering.position = Vector3(0.0, 2.53, -0.15)
		lettering.rotation.y = 0.0
		sign.add_child(lettering)


func _create_invisible_boundary(
	boundary_name: String,
	box_size: Vector3,
	box_position: Vector3
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = boundary_name
	body.position = box_position
	add_child(body)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape
	body.add_child(collision)
	return body


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
	var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.045
	for y in range(256):
		for x in range(256):
			var tile_x := x % 64
			var tile_y := y % 64
			var grain := noise.get_noise_2d(float(x), float(y)) * 0.035
			var color := Color(0.53 + grain, 0.58 + grain, 0.60 + grain, 1.0)
			if tile_x < 2 or tile_y < 2:
				color = Color(0.20, 0.26, 0.29, 1.0)
			elif tile_x > 60 or tile_y > 60:
				color = color.darkened(0.045)
			elif (x * 13 + y * 7) % 173 == 0:
				color = color.darkened(0.10)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _create_wall_texture() -> Texture2D:
	var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.035
	for y in range(256):
		for x in range(256):
			var grain := noise.get_noise_2d(float(x), float(y)) * 0.045
			var color := Color(0.60 + grain, 0.63 + grain, 0.67 + grain, 1.0)
			if y % 85 < 2:
				color = Color(0.34, 0.39, 0.45, 1.0)
			elif x % 128 < 2:
				color = color.darkened(0.055)
			elif y > 220 and (x + y) % 17 < 2:
				color = color.darkened(0.07)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _create_outdoor_ground_texture() -> Texture2D:
	var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var broad_noise := FastNoiseLite.new()
	broad_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	broad_noise.frequency = 0.018
	var fine_noise := FastNoiseLite.new()
	fine_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	fine_noise.frequency = 0.11
	for y in range(256):
		for x in range(256):
			var broad := broad_noise.get_noise_2d(float(x), float(y)) * 0.12
			var fine := fine_noise.get_noise_2d(float(x), float(y)) * 0.035
			var value := broad + fine
			var color := Color(0.27 + value, 0.31 + value, 0.27 + value * 0.8, 1.0)
			if (x * 17 + y * 29) % 211 < 3:
				color = color.darkened(0.24)
			elif (x * 7 + y * 11) % 97 < 2:
				color = color.lightened(0.09)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _create_asphalt_texture() -> Texture2D:
	var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.12
	for y in range(256):
		for x in range(256):
			var grain := noise.get_noise_2d(float(x), float(y)) * 0.065
			var color := Color(0.19 + grain, 0.20 + grain, 0.24 + grain, 1.0)
			if (x * 19 + y * 31) % 487 < 2:
				color = color.darkened(0.38)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _create_bark_texture() -> Texture2D:
	var image := Image.create(128, 256, false, Image.FORMAT_RGBA8)
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.055
	for y in range(256):
		for x in range(128):
			var grain := noise.get_noise_2d(float(x) * 0.7, float(y)) * 0.055
			var streak := sin(float(x) * 0.17 + noise.get_noise_2d(float(x), float(y)) * 2.0) * 0.025
			var value := grain + streak
			image.set_pixel(x, y, Color(0.29 + value, 0.21 + value, 0.17 + value, 1.0))
	return ImageTexture.create_from_image(image)


func _build_outdoor_map() -> void:
	var ground_material := _make_material(Color(0.52, 0.56, 0.49), 0.98)
	ground_material.albedo_texture = _create_outdoor_ground_texture()
	ground_material.uv1_scale = Vector3(34.0, 1.0, 42.0)
	var path_material := _make_material(Color(0.56, 0.58, 0.62), 0.88)
	path_material.albedo_texture = _create_asphalt_texture()
	path_material.uv1_scale = Vector3(5.0, 1.0, 34.0)
	var curb_material := _make_material(Color(0.48, 0.48, 0.50), 0.76)

	_create_static_box("OuterExplorationGround", Vector3(180.0, 0.5, 210.0), Vector3(0.0, -0.25, 125.0), ground_material)
	_add_box_mesh(self, "MainAsphaltRoad", Vector3(10.0, 0.07, 184.0), Vector3(0.0, 0.035, 122.0), path_material)
	_add_box_mesh(self, "WestTrail", Vector3(6.5, 0.07, 48.0), Vector3(-27.0, 0.04, 144.0), path_material)
	_add_box_mesh(self, "EastTrail", Vector3(6.5, 0.07, 44.0), Vector3(29.0, 0.04, 133.0), path_material)
	_add_box_mesh(self, "SouthPlaza", Vector3(35.0, 0.08, 18.0), Vector3(0.0, 0.05, 80.0), path_material)

	_add_box_mesh(self, "RoadCenterLineA", Vector3(0.16, 0.025, 16.0), Vector3(0.0, 0.09, 48.0), curb_material)
	_add_box_mesh(self, "RoadCenterLineB", Vector3(0.16, 0.025, 16.0), Vector3(0.0, 0.09, 69.0), curb_material)
	_add_box_mesh(self, "RoadCenterLineC", Vector3(0.16, 0.025, 16.0), Vector3(0.0, 0.09, 112.0), curb_material)
	_add_box_mesh(self, "RoadCenterLineD", Vector3(0.16, 0.025, 16.0), Vector3(0.0, 0.09, 133.0), curb_material)
	_add_box_mesh(self, "RoadCenterLineE", Vector3(0.16, 0.025, 16.0), Vector3(0.0, 0.09, 154.0), curb_material)

	# Invisible boundary colliders keep the explorable area contained.
	_create_invisible_boundary("WorldBoundaryWest", Vector3(0.6, 8.0, 210.0), Vector3(-90.0, 4.0, 125.0))
	_create_invisible_boundary("WorldBoundaryEast", Vector3(0.6, 8.0, 210.0), Vector3(90.0, 4.0, 125.0))
	_create_invisible_boundary("WorldBoundarySouth", Vector3(180.0, 8.0, 0.6), Vector3(0.0, 4.0, 230.0))


func _build_tree_forest() -> void:
	var tree_positions: Array[Vector3] = [
		Vector3(-24.0, 0.0, 43.0), Vector3(25.0, 0.0, 45.0),
		Vector3(-39.0, 0.0, 57.0), Vector3(39.0, 0.0, 62.0),
		Vector3(-29.0, 0.0, 91.0), Vector3(31.0, 0.0, 92.0),
		Vector3(-65.0, 0.0, 78.0), Vector3(-75.0, 0.0, 105.0),
		Vector3(-66.0, 0.0, 133.0), Vector3(-79.0, 0.0, 166.0),
		Vector3(-58.0, 0.0, 185.0), Vector3(-31.0, 0.0, 188.0),
		Vector3(65.0, 0.0, 76.0), Vector3(77.0, 0.0, 104.0),
		Vector3(69.0, 0.0, 137.0), Vector3(78.0, 0.0, 171.0),
		Vector3(30.0, 0.0, 188.0), Vector3(-4.0, 0.0, 201.0),
		Vector3(53.0, 0.0, 202.0), Vector3(-50.0, 0.0, 211.0)
	]
	var tree_heights: Array[float] = []
	for index in range(tree_positions.size()):
		var height := 8.0 + float(index % 4) * 1.3
		tree_heights.append(height)
		_create_tree_collider("TreeTrunkCollider_%02d" % index, tree_positions[index], height)

	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.48
	trunk_mesh.height = 1.0
	trunk_mesh.radial_segments = 12

	var trunk_multimesh := MultiMesh.new()
	trunk_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	trunk_multimesh.mesh = trunk_mesh
	trunk_multimesh.custom_aabb = AABB(Vector3(-81.0, 0.0, 41.0), Vector3(162.0, 13.0, 173.0))
	trunk_multimesh.instance_count = tree_positions.size()
	for index in range(tree_positions.size()):
		var tree_position := tree_positions[index]
		var height := tree_heights[index]
		var transform := Transform3D(
			Basis().scaled(Vector3(1.0, height, 1.0)),
			tree_position + Vector3(0.0, height * 0.5, 0.0)
		)
		trunk_multimesh.set_instance_transform(index, transform)

	var trunk_visual := MultiMeshInstance3D.new()
	trunk_visual.name = "DetailedTreeTrunks"
	trunk_visual.multimesh = trunk_multimesh
	var bark_material := _make_material(Color(0.34, 0.27, 0.23), 0.96)
	bark_material.albedo_texture = _create_bark_texture()
	trunk_visual.material_override = bark_material
	add_child(trunk_visual)

	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radial_segments = 14
	canopy_mesh.rings = 8
	canopy_mesh.radius = 1.0
	canopy_mesh.height = 2.0

	var canopy_transforms: Array[Transform3D] = []
	for index in range(tree_positions.size()):
		var tree_position := tree_positions[index]
		var height := tree_heights[index]
		var canopy_center := tree_position + Vector3(0.0, height * 0.79, 0.0)
		canopy_transforms.append(Transform3D(Basis().scaled(Vector3(2.8, 2.5, 2.8)), canopy_center))
		canopy_transforms.append(Transform3D(Basis().scaled(Vector3(2.0, 1.8, 2.0)), canopy_center + Vector3(-1.25, -0.5, 0.3)))
		canopy_transforms.append(Transform3D(Basis().scaled(Vector3(2.0, 1.8, 2.0)), canopy_center + Vector3(1.25, -0.45, -0.25)))

	var canopy_multimesh := MultiMesh.new()
	canopy_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	canopy_multimesh.mesh = canopy_mesh
	canopy_multimesh.custom_aabb = AABB(Vector3(-84.0, 0.0, 38.0), Vector3(168.0, 14.5, 180.0))
	canopy_multimesh.instance_count = canopy_transforms.size()
	for index in range(canopy_transforms.size()):
		canopy_multimesh.set_instance_transform(index, canopy_transforms[index])

	var canopy_visual := MultiMeshInstance3D.new()
	canopy_visual.name = "DetailedTreeCanopies"
	canopy_visual.multimesh = canopy_multimesh
	canopy_visual.material_override = _make_material(Color(0.075, 0.13, 0.105), 0.94)
	add_child(canopy_visual)


func _create_tree_collider(tree_name: String, tree_position: Vector3, height: float) -> void:
	var tree_body := StaticBody3D.new()
	tree_body.name = tree_name
	tree_body.position = tree_position
	add_child(tree_body)

	var collision := CollisionShape3D.new()
	var trunk_shape := CylinderShape3D.new()
	trunk_shape.radius = 0.48
	trunk_shape.height = height
	collision.shape = trunk_shape
	collision.position.y = height * 0.5
	tree_body.add_child(collision)


func _build_waiting_bench() -> void:
	var bench := StaticBody3D.new()
	bench.name = "ForestBench"
	bench.position = Vector3(-36.0, 0.0, 81.0)
	add_child(bench)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3.6, 0.72, 0.92)
	collision.shape = shape
	collision.position.y = 0.7
	bench.add_child(collision)

	var green_metal := _make_material(Color(0.12, 0.24, 0.2), 0.62, 0.42)
	var seat_wood := _make_material(Color(0.28, 0.23, 0.18), 0.88)
	_add_box_mesh(bench, "BenchSeat", Vector3(3.5, 0.18, 0.82), Vector3(0.0, 0.72, 0.0), seat_wood)
	_add_box_mesh(bench, "BenchBack", Vector3(3.5, 0.88, 0.15), Vector3(0.0, 1.2, -0.34), seat_wood)
	_add_box_mesh(bench, "BenchSupportLeft", Vector3(0.18, 0.82, 0.18), Vector3(-1.42, 0.42, 0.0), green_metal)
	_add_box_mesh(bench, "BenchSupportRight", Vector3(0.18, 0.82, 0.18), Vector3(1.42, 0.42, 0.0), green_metal)


func _build_guard_gate() -> void:
	var booth := StaticBody3D.new()
	booth.name = "ForestCheckpointBooth"
	booth.position = Vector3(-11.0, 0.0, 92.0)
	add_child(booth)

	var booth_collision := CollisionShape3D.new()
	var booth_shape := BoxShape3D.new()
	booth_shape.size = Vector3(4.4, 3.6, 3.8)
	booth_collision.shape = booth_shape
	booth_collision.position.y = 1.8
	booth.add_child(booth_collision)

	var booth_material := _make_material(Color(0.34, 0.3, 0.25), 0.92)
	var window_material := _make_material(Color(0.12, 0.19, 0.22), 0.18, 0.18)
	_add_box_mesh(booth, "BoothBody", Vector3(4.3, 3.5, 3.7), Vector3(0.0, 1.8, 0.0), booth_material)
	_add_box_mesh(booth, "BoothFrontWindow", Vector3(3.3, 1.25, 0.07), Vector3(0.0, 2.45, -1.89), window_material)
	_add_box_mesh(booth, "BoothRoof", Vector3(4.8, 0.26, 4.2), Vector3(0.0, 3.68, 0.0), _make_material(Color(0.18, 0.21, 0.22), 0.7))
	_add_box_mesh(booth, "StopSignBoard", Vector3(2.2, 0.58, 0.14), Vector3(0.0, 3.2, -1.98), _make_emission_material(Color(0.72, 0.035, 0.045), Color(0.4, 0.008, 0.012), 0.65))

	var barrier_post := StaticBody3D.new()
	barrier_post.name = "BarrierPost"
	barrier_post.position = Vector3(-4.4, 0.0, 92.0)
	add_child(barrier_post)
	var post_collision := CollisionShape3D.new()
	var post_shape := CylinderShape3D.new()
	post_shape.radius = 0.34
	post_shape.height = 1.8
	post_collision.shape = post_shape
	post_collision.position.y = 0.9
	barrier_post.add_child(post_collision)
	var post_mesh := CylinderMesh.new()
	post_mesh.top_radius = 0.3
	post_mesh.bottom_radius = 0.38
	post_mesh.height = 1.8
	post_mesh.radial_segments = 8
	var post_visual := MeshInstance3D.new()
	post_visual.mesh = post_mesh
	post_visual.material_override = _make_material(Color(0.78, 0.7, 0.48), 0.72, 0.12)
	post_visual.position.y = 0.9
	barrier_post.add_child(post_visual)

	var barrier := StaticBody3D.new()
	barrier.name = "CheckpointBarrierArm"
	barrier.position = Vector3(-1.6, 1.35, 92.0)
	barrier.rotation.y = deg_to_rad(-7.0)
	add_child(barrier)
	var arm_collision := CollisionShape3D.new()
	var arm_shape := BoxShape3D.new()
	arm_shape.size = Vector3(5.4, 0.22, 0.22)
	arm_collision.shape = arm_shape
	barrier.add_child(arm_collision)
	_add_box_mesh(barrier, "BarrierArm", Vector3(5.4, 0.22, 0.22), Vector3.ZERO, _make_material(Color(0.84, 0.76, 0.58), 0.58))
	_add_box_mesh(barrier, "BarrierRedStripeA", Vector3(0.42, 0.24, 0.24), Vector3(-1.6, 0.0, 0.0), _make_material(Color(0.62, 0.07, 0.055), 0.56))
	_add_box_mesh(barrier, "BarrierRedStripeB", Vector3(0.42, 0.24, 0.24), Vector3(0.2, 0.0, 0.0), _make_material(Color(0.62, 0.07, 0.055), 0.56))


func _build_rockside_atm() -> void:
	var rock_material := _make_material(Color(0.25, 0.28, 0.29), 0.98)
	var dark_rock := _make_material(Color(0.14, 0.17, 0.18), 0.98)
	var rock_wall := _create_static_box(
		"RockWallCollider",
		Vector3(12.0, 7.0, 4.0),
		Vector3(55.0, 3.5, 124.0),
		dark_rock
	)
	_add_low_poly_rock(rock_wall, "RockTopLeft", Vector3(-4.5, 3.0, 0.0), Vector3(3.6, 3.0, 3.0), rock_material)
	_add_low_poly_rock(rock_wall, "RockTopRight", Vector3(4.3, 2.6, -0.2), Vector3(3.8, 2.6, 3.1), rock_material)
	_add_low_poly_rock(rock_wall, "RockSideLeft", Vector3(-5.0, 0.3, -0.4), Vector3(2.6, 2.8, 2.8), rock_material)
	_add_low_poly_rock(rock_wall, "RockSideRight", Vector3(5.0, 0.1, -0.3), Vector3(2.6, 2.9, 2.8), rock_material)

	var atm := StaticBody3D.new()
	atm.name = "GreenRocksideATM"
	atm.position = Vector3(47.5, 0.0, 120.8)
	add_child(atm)

	var atm_collision := CollisionShape3D.new()
	var atm_shape := BoxShape3D.new()
	atm_shape.size = Vector3(1.8, 2.7, 0.78)
	atm_collision.shape = atm_shape
	atm_collision.position.y = 1.35
	atm.add_child(atm_collision)

	var machine_material := _make_material(Color(0.16, 0.2, 0.2), 0.48, 0.25)
	var screen_material := _make_emission_material(Color(0.22, 0.68, 0.48), Color(0.12, 0.7, 0.44), 1.15)
	_add_box_mesh(atm, "ATMBody", Vector3(1.8, 2.7, 0.72), Vector3(0.0, 1.35, 0.0), machine_material)
	_add_box_mesh(atm, "ATMScreen", Vector3(1.16, 0.82, 0.07), Vector3(0.0, 1.8, -0.4), screen_material)
	_add_box_mesh(atm, "ATMKeypad", Vector3(0.52, 0.4, 0.08), Vector3(0.0, 0.92, -0.41), _make_material(Color(0.06, 0.09, 0.09), 0.54))
	_add_box_mesh(atm, "ATMCashSlot", Vector3(0.62, 0.12, 0.08), Vector3(0.0, 0.48, -0.41), _make_material(Color(0.02, 0.025, 0.025), 0.4, 0.3))


func _add_low_poly_rock(
	parent: Node3D,
	rock_name: String,
	local_position: Vector3,
	rock_scale: Vector3,
	material: Material
) -> void:
	var rock := MeshInstance3D.new()
	rock.name = rock_name
	var sphere := SphereMesh.new()
	sphere.radial_segments = 14
	sphere.rings = 8
	sphere.radius = 1.0
	sphere.height = 2.0
	rock.mesh = sphere
	rock.material_override = material
	rock.position = local_position
	rock.scale = rock_scale
	parent.add_child(rock)


func _build_crt_pool() -> void:
	var pool_position := Vector3(-49.0, 0.0, 146.0)
	var pool_base_material := _make_material(Color(0.13, 0.22, 0.25), 0.9)
	var pool_tile_material := _make_material(Color(0.11, 0.35, 0.4), 0.62)
	var water_material := _make_material(Color(0.018, 0.095, 0.14), 0.13, 0.22)
	water_material.clearcoat_enabled = true
	water_material.clearcoat = 0.48

	_create_static_box("CRTDisplayPoolBase", Vector3(27.0, 0.5, 21.0), pool_position + Vector3(0.0, -0.25, 0.0), pool_base_material)
	_create_static_box("PoolRimNorth", Vector3(27.0, 0.72, 0.55), pool_position + Vector3(0.0, 0.36, -10.2), pool_tile_material)
	_create_static_box("PoolRimSouth", Vector3(27.0, 0.72, 0.55), pool_position + Vector3(0.0, 0.36, 10.2), pool_tile_material)
	_create_static_box("PoolRimWest", Vector3(0.55, 0.72, 20.0), pool_position + Vector3(-13.2, 0.36, 0.0), pool_tile_material)
	_create_static_box("PoolRimEast", Vector3(0.55, 0.72, 20.0), pool_position + Vector3(13.2, 0.36, 0.0), pool_tile_material)
	_add_box_mesh(self, "PoolWater", Vector3(25.8, 0.06, 19.8), pool_position + Vector3(0.0, 0.04, 0.0), water_material)

	var monitor_body_material := _make_material(Color(0.12, 0.14, 0.16), 0.58)
	var screen_material := _make_emission_material(Color(0.34, 0.48, 0.5), Color(0.3, 0.56, 0.6), 0.48)
	for row in range(2):
		for column in range(5):
			var monitor_position := pool_position + Vector3(-8.8 + float(column) * 4.4, 0.0, -3.8 + float(row) * 7.6)
			var monitor := StaticBody3D.new()
			monitor.name = "PoolCRT_%d_%d" % [row, column]
			monitor.position = monitor_position
			add_child(monitor)

			var monitor_collision := CollisionShape3D.new()
			var monitor_shape := BoxShape3D.new()
			monitor_shape.size = Vector3(1.7, 1.35, 1.0)
			monitor_collision.shape = monitor_shape
			monitor_collision.position.y = 0.82
			monitor.add_child(monitor_collision)

			_add_box_mesh(monitor, "CRTBody", Vector3(1.72, 1.32, 0.98), Vector3(0.0, 0.82, 0.0), monitor_body_material)
			_add_box_mesh(monitor, "CRTGlass", Vector3(1.34, 0.91, 0.055), Vector3(0.0, 0.86, -0.51), screen_material)


func _build_purple_signal() -> void:
	var signal_body := StaticBody3D.new()
	signal_body.name = "PurpleSignalPole"
	signal_body.position = Vector3(14.0, 0.0, 128.0)
	add_child(signal_body)

	var pole_shape := CylinderShape3D.new()
	pole_shape.radius = 0.42
	pole_shape.height = 5.8
	var pole_collision := CollisionShape3D.new()
	pole_collision.shape = pole_shape
	pole_collision.position.y = 2.9
	signal_body.add_child(pole_collision)

	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.28
	pole_mesh.bottom_radius = 0.42
	pole_mesh.height = 5.8
	pole_mesh.radial_segments = 6
	var pole_visual := MeshInstance3D.new()
	pole_visual.mesh = pole_mesh
	pole_visual.material_override = _make_material(Color(0.64, 0.48, 0.22), 0.7, 0.16)
	pole_visual.position.y = 2.9
	signal_body.add_child(pole_visual)

	var housing_material := _make_material(Color(0.23, 0.19, 0.29), 0.64, 0.22)
	var purple_material := _make_emission_material(Color(0.4, 0.13, 0.72), Color(0.56, 0.14, 0.95), 1.8)
	for index in range(3):
		var y_position := 4.65 - float(index) * 1.25
		_add_box_mesh(signal_body, "SignalHousing_%d" % index, Vector3(1.1, 1.0, 0.62), Vector3(0.0, y_position, -0.35), housing_material)
		var lens := MeshInstance3D.new()
		lens.name = "PurpleLens_%d" % index
		var sphere := SphereMesh.new()
		sphere.radial_segments = 10
		sphere.rings = 5
		sphere.radius = 0.34
		sphere.height = 0.68
		lens.mesh = sphere
		lens.material_override = purple_material
		lens.position = Vector3(0.0, y_position, -0.72)
		signal_body.add_child(lens)


func _build_palm_tree() -> void:
	var palm_position := Vector3(56.0, 0.0, 178.0)
	var trunk := StaticBody3D.new()
	trunk.name = "LiminalPalmTree"
	trunk.position = palm_position
	add_child(trunk)

	var collision := CollisionShape3D.new()
	var trunk_shape := CylinderShape3D.new()
	trunk_shape.radius = 0.42
	trunk_shape.height = 9.2
	collision.shape = trunk_shape
	collision.position.y = 4.6
	trunk.add_child(collision)

	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.23
	trunk_mesh.bottom_radius = 0.5
	trunk_mesh.height = 9.2
	trunk_mesh.radial_segments = 5
	var trunk_visual := MeshInstance3D.new()
	trunk_visual.mesh = trunk_mesh
	trunk_visual.material_override = _make_material(Color(0.32, 0.25, 0.18), 0.96)
	trunk_visual.position.y = 4.6
	trunk.add_child(trunk_visual)

	var leaf_material := _make_material(Color(0.1, 0.19, 0.15), 0.94)
	for index in range(7):
		var angle := TAU * float(index) / 7.0
		var leaf := MeshInstance3D.new()
		leaf.name = "PalmFrond_%d" % index
		var leaf_mesh := BoxMesh.new()
		leaf_mesh.size = Vector3(0.28, 0.09, 5.8)
		leaf.mesh = leaf_mesh
		leaf.material_override = leaf_material
		leaf.position = Vector3(sin(angle) * 1.1, 9.0, cos(angle) * 1.1)
		leaf.rotation.y = angle
		leaf.rotation.x = deg_to_rad(-18.0)
		trunk.add_child(leaf)

	var red_light := MeshInstance3D.new()
	red_light.name = "PalmRedSignal"
	var red_sphere := SphereMesh.new()
	red_sphere.radial_segments = 8
	red_sphere.rings = 4
	red_sphere.radius = 0.23
	red_sphere.height = 0.46
	red_light.mesh = red_sphere
	red_light.material_override = _make_emission_material(Color(0.85, 0.08, 0.1), Color(0.9, 0.04, 0.05), 1.3)
	red_light.position = Vector3(0.0, 8.4, -0.55)
	trunk.add_child(red_light)
