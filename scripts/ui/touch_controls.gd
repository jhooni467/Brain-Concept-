extends Control

signal look_dragged(delta: Vector2)

const JOYSTICK_RADIUS: float = 78.0
const JOYSTICK_OPACITY: float = 0.10
const CAMERA_TOUCH_LEFT_BOUNDARY: float = 0.44

var _move_touch_id: int = -1
var _jump_touch_id: int = -1
var _look_touch_id: int = -1
var _mouse_look_active: bool = false
var _stick_origin: Vector2 = Vector2.ZERO
var _movement_vector: Vector2 = Vector2.ZERO
var _jump_requested: bool = false


func _ready() -> void:
	add_to_group("mobile_controls")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch

		if touch.pressed:
			if _move_touch_id == -1 and _is_move_zone(touch.position):
				_move_touch_id = touch.index
				_stick_origin = touch.position
				_update_movement(touch.position)
				get_viewport().set_input_as_handled()
			elif _jump_touch_id == -1 and _is_jump_zone(touch.position):
				_jump_touch_id = touch.index
				_jump_requested = true
				queue_redraw()
				get_viewport().set_input_as_handled()
			elif _look_touch_id == -1 and _is_camera_zone(touch.position):
				_look_touch_id = touch.index
				get_viewport().set_input_as_handled()
		else:
			if touch.index == _move_touch_id:
				_move_touch_id = -1
				_movement_vector = Vector2.ZERO
				queue_redraw()
				get_viewport().set_input_as_handled()

			if touch.index == _jump_touch_id:
				_jump_touch_id = -1
				queue_redraw()
				get_viewport().set_input_as_handled()

			if touch.index == _look_touch_id:
				_look_touch_id = -1
				get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag

		if drag.index == _move_touch_id:
			_update_movement(drag.position)
			get_viewport().set_input_as_handled()
		elif drag.index == _look_touch_id:
			look_dragged.emit(drag.screen_relative)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_RIGHT:
			_mouse_look_active = mouse_button.pressed
			if _mouse_look_active:
				get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and _mouse_look_active:
		var mouse_motion := event as InputEventMouseMotion
		look_dragged.emit(mouse_motion.relative)
		get_viewport().set_input_as_handled()


func get_movement_vector() -> Vector2:
	return _movement_vector


func consume_jump() -> bool:
	var requested := _jump_requested
	_jump_requested = false
	return requested


func _is_move_zone(position: Vector2) -> bool:
	return position.x < size.x * 0.45 and position.y > size.y * 0.46


func _is_jump_zone(position: Vector2) -> bool:
	return position.x > size.x * 0.76 and position.y > size.y * 0.64


func _is_camera_zone(position: Vector2) -> bool:
	return position.x > size.x * CAMERA_TOUCH_LEFT_BOUNDARY and position.y < size.y * 0.9


func _update_movement(position: Vector2) -> void:
	var offset := position - _stick_origin

	if offset.length() > JOYSTICK_RADIUS:
		offset = offset.normalized() * JOYSTICK_RADIUS

	_movement_vector = Vector2(offset.x, offset.y) / JOYSTICK_RADIUS
	queue_redraw()


func _draw() -> void:
	if not DisplayServer.is_touchscreen_available():
		return

	var default_joystick := Vector2(size.x * 0.14, size.y * 0.79)
	var joystick_center := _stick_origin if _move_touch_id != -1 else default_joystick
	var stick_offset := _movement_vector * JOYSTICK_RADIUS
	var joystick_fill := Color(0.82, 0.85, 0.92, JOYSTICK_OPACITY)
	var joystick_outline := Color(0.9, 0.92, 0.98, JOYSTICK_OPACITY)

	draw_circle(joystick_center, JOYSTICK_RADIUS, joystick_fill)
	draw_arc(joystick_center, JOYSTICK_RADIUS, 0.0, TAU, 48, joystick_outline, 2.0)
	draw_circle(joystick_center + stick_offset, 31.0, joystick_fill)
	draw_arc(joystick_center + stick_offset, 31.0, 0.0, TAU, 32, joystick_outline, 1.5)

	var jump_center := Vector2(size.x * 0.88, size.y * 0.79)
	var jump_color := Color(0.48, 0.18, 0.28, 0.3) if _jump_touch_id != -1 else Color(0.78, 0.76, 0.82, 0.18)
	draw_circle(jump_center, 49.0, jump_color)
	draw_arc(jump_center, 49.0, 0.0, TAU, 40, Color(0.9, 0.88, 0.94, 0.24), 2.0)
	draw_line(jump_center + Vector2(0.0, 12.0), jump_center + Vector2(0.0, -12.0), Color(1.0, 0.98, 1.0, 0.82), 4.0)
	draw_line(jump_center + Vector2(-10.0, -2.0), jump_center + Vector2(0.0, -13.0), Color(1.0, 0.98, 1.0, 0.82), 4.0)
	draw_line(jump_center + Vector2(10.0, -2.0), jump_center + Vector2(0.0, -13.0), Color(1.0, 0.98, 1.0, 0.82), 4.0)
