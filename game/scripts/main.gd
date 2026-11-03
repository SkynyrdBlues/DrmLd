extends Node3D

var player: CharacterBody3D
var figure: Node3D
var camera_rig: Node3D
var arm: SpringArm3D
var camera: Camera3D
var stamina_bar: ProgressBar
var hint: Label
var legs: Array[MeshInstance3D] = []
var controls_active := true
var yaw := 0.0
var pitch := -0.23
var stamina := 100.0
var stride := 0.0
var mouse_sensitivity := 0.0025

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("777e85"))
	build_world()
	build_player()
	build_camera()
	build_hud()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.95
	return result

func box(size: Vector3, position_: Vector3, color: Color, solid := true) -> Node3D:
	var root: Node3D = StaticBody3D.new() if solid else Node3D.new()
	root.position = position_
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = material(color)
	root.add_child(mesh)
	if solid:
		var collision := CollisionShape3D.new()
		var bounds := BoxShape3D.new()
		bounds.size = size
		collision.shape = bounds
		root.add_child(collision)
	add_child(root)
	return root

func build_world() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("777e85")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("aeb9c3")
	settings.ambient_light_energy = 0.65
	environment.environment = settings
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -32, 0)
	sun.light_color = Color("ffe3b4")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)
	box(Vector3(52, 1, 52), Vector3(0, -0.5, 0), Color("686c69"))
	box(Vector3(7, 0.035, 42), Vector3(0, 0.018, 0), Color("83847b"), false)
	for x in [-26.0, 26.0]:
		box(Vector3(1, 5, 52), Vector3(x, 2.5, 0), Color("595f60"))
	for z in [-26.0, 26.0]:
		box(Vector3(52, 5, 1), Vector3(0, 2.5, z), Color("595f60"))
	for x in [-8.0, 8.0]:
		for z in [-16.0, -8.0, 0.0, 8.0, 16.0]:
			box(Vector3(1.8, 0.4, 1.8), Vector3(x, 0.2, z), Color("939185"))
			box(Vector3(1.15, 5.3, 1.15), Vector3(x, 3.05, z), Color("797b74"))
			box(Vector3(1.8, 0.45, 1.8), Vector3(x, 5.9, z), Color("939185"))
	for x in [-15.0, 15.0]:
		for z in [-12.0, 5.0, 16.0]:
			box(Vector3(3, 1.1, 2), Vector3(x, 0.55, z), Color("74756d"))
	box(Vector3(6, 1.4, 4), Vector3(0, 0.7, -19), Color("919084"))
	box(Vector3(1, 7, 1), Vector3(-4, 3.5, -21), Color("b2ab93"))
	box(Vector3(1, 7, 1), Vector3(4, 3.5, -21), Color("b2ab93"))
	box(Vector3(9, 1, 1), Vector3(0, 7, -21), Color("b2ab93"))
	for i in range(12):
		box(Vector3(0.05, 0.015, 42), Vector3(-3.5 + i * 0.64, 0.045, 0), Color("70746d"), false)

func build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 0.1, 12)
	player.collision_layer = 2
	player.collision_mask = 1
	player.floor_snap_length = 0.3
	add_child(player)
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.9
	player.add_child(collision)
	figure = Node3D.new()
	player.add_child(figure)
	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.29
	body_mesh.height = 1.15
	body_mesh.radial_segments = 12
	body_mesh.rings = 4
	body.mesh = body_mesh
	body.position.y = 0.95
	body.material_override = material(Color("30383e"))
	figure.add_child(body)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.23
	head_mesh.height = 0.46
	head_mesh.radial_segments = 12
	head_mesh.rings = 6
	head.mesh = head_mesh
	head.position.y = 1.65
	head.material_override = material(Color("b5ab96"))
	figure.add_child(head)
	var cape := MeshInstance3D.new()
	var cape_mesh := CylinderMesh.new()
	cape_mesh.top_radius = 0.27
	cape_mesh.bottom_radius = 0.46
	cape_mesh.height = 1.05
	cape_mesh.radial_segments = 8
	cape.mesh = cape_mesh
	cape.position = Vector3(0, 0.92, 0.12)
	cape.material_override = material(Color("59423f"))
	figure.add_child(cape)

	for side in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var leg_mesh := BoxMesh.new()
		leg_mesh.size = Vector3(0.19, 0.64, 0.24)
		leg.mesh = leg_mesh
		leg.position = Vector3(side * 0.15, 0.32, 0)
		leg.material_override = material(Color("30383e"))
		figure.add_child(leg)
		legs.append(leg)

func build_camera() -> void:
	camera_rig = Node3D.new()
	camera_rig.position = player.position + Vector3(0, 1.4, 0)
	add_child(camera_rig)
	arm = SpringArm3D.new()
	arm.spring_length = 4.5
	arm.margin = 0.18
	arm.collision_mask = 1
	var camera_shape := SphereShape3D.new()
	camera_shape.radius = 0.18
	arm.shape = camera_shape
	arm.rotation.x = pitch
	camera_rig.add_child(arm)
	camera = Camera3D.new()
	camera.fov = 65
	camera.near = 0.08
	camera.current = true
	arm.add_child(camera)

func make_bar(y: float, width: float, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = Vector2(40, y)
	bar.size = Vector2(width, 9)
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false
	bar.add_theme_font_size_override("font_size", 1)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("282b2c")
	background.border_color = Color("ada38a")
	background.set_border_width_all(1)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	bar.size = Vector2(width, 9)
	return bar

func build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	hud.add_child(make_bar(38, 300, Color("943e3b")))
	stamina_bar = make_bar(53, 245, Color("829064"))
	hud.add_child(stamina_bar)
	var title := Label.new()
	title.text = "D R E A M L A N D"
	title.position = Vector2(40, 82)
	title.add_theme_font_size_override("font_size", 13)
	title.modulate = Color("d6cdb5")
	hud.add_child(title)
	hint = Label.new()
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hint.offset_left = 40
	hint.offset_top = -52
	hint.offset_bottom = -24
	hint.add_theme_font_size_override("font_size", 14)
	hint.modulate = Color("e4e1d6")
	hud.add_child(hint)
	update_hint()

func update_hint() -> void:
	if controls_active:
		hint.text = "WASD  Move     Shift  Run     Space  Jump     Mouse  Look     Esc  Release cursor"
	else:
		hint.text = "Click to resume     WASD  Move     Shift  Run     Space  Jump"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		controls_active = false
		update_hint()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		controls_active = true
		update_hint()
	elif event is InputEventMouseMotion and controls_active:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clampf(pitch - event.relative.y * mouse_sensitivity, -1.1, 0.45)

func _physics_process(delta: float) -> void:
	var active := controls_active
	var axis := Vector2.ZERO
	if active:
		axis.x = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
		axis.y = float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	axis = axis.limit_length()
	var running := active and axis.length() > 0.1 and Input.is_physical_key_pressed(KEY_SHIFT) and stamina > 1
	var speed := 6.5 if running else 3.5
	stamina = clampf(stamina + (-22.0 if running else 17.0) * delta, 0, 100)
	stamina_bar.value = stamina
	var direction := Vector3(axis.x, 0, axis.y).rotated(Vector3.UP, yaw)
	player.velocity.x = move_toward(player.velocity.x, direction.x * speed, 22 * delta)
	player.velocity.z = move_toward(player.velocity.z, direction.z * speed, 22 * delta)
	if not player.is_on_floor():
		player.velocity.y -= 20 * delta
	elif active and Input.is_physical_key_pressed(KEY_SPACE):
		player.velocity.y = 6
	player.move_and_slide()
	if direction.length() > 0.1:
		figure.rotation.y = lerp_angle(figure.rotation.y, atan2(-direction.x, -direction.z), 12 * delta)
		stride += delta * (13 if running else 9)
		figure.position.y = sin(stride) * 0.035
		legs[0].rotation.x = sin(stride) * 0.35
		legs[1].rotation.x = -sin(stride) * 0.35
	else:
		figure.position.y = lerpf(figure.position.y, 0, 12 * delta)
		for leg in legs:
			leg.rotation.x = lerpf(leg.rotation.x, 0, 12 * delta)
	if player.position.y < -10:
		player.position = Vector3(0, 1, 12)
		player.velocity = Vector3.ZERO
	camera_rig.position = camera_rig.position.lerp(player.position + Vector3(0, 1.4, 0), 1 - exp(-18 * delta))
	camera_rig.rotation.y = yaw
	arm.rotation.x = pitch

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT and is_instance_valid(hint):
		controls_active = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		update_hint()
