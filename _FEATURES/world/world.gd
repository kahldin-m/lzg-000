extends Node2D

@export_category("DEBUG")
@export var DEBUG_MODE: bool = false
@export_category("Game Settings")
@export var tick_time := 0.3
@export var world_size: Vector2i = Vector2i(64, 32)
@export var player_texture: Texture2D

var vel_tex: Texture2D = preload("res://_FEATURES/entities/velo_00.png")
# var bg_tile_texture: Texture2D = preload("res://_FEATURES/the_world/grass_01.png")

var player: CharacterBody2D
var player_sprite: Sprite2D
var game_camera: Camera2D
var direction: Vector2i = Vector2i.ZERO
var entities: Array[Sprite2D] = []

const TILE_SIZE := 16
const ENTITY_SPEED := 50
const VELO_NAMES := [
	"Frank",
	"Zelda",
	"Bacon",
	"Juju",
	"Antoine",
	"Henrietta",
	"Doris",
	"Zulu",
	"Delta",
	"Romeo",
	"Juliete",
	"Casper",
]

# ready, process and game_tick
func _ready() -> void:
	# setup_background()
	setup_player()
	setup_camera()
	setup_timer()
	queue_redraw()


func _draw():
	if not DEBUG_MODE:
		return

	for x in range(0, world_size.x + 1):
		var x_pos := x * TILE_SIZE
		draw_line(
			Vector2(x_pos, 0),
			Vector2(x_pos, world_size.y * TILE_SIZE),
			Color(1, 1, 1, 0.3)
		)

	for y in range(0, world_size.y + 1):
		var y_pos := y * TILE_SIZE
		draw_line(
			Vector2(0, y_pos),
			Vector2(world_size.x * TILE_SIZE, y_pos),
			Color(1, 1, 1, 0.3)
		)


func game_tick():
	if direction == Vector2i.ZERO:
		return

	# Flip sprite based on direction
	if direction == Vector2i.LEFT:
		player_sprite.flip_h = true
	if direction == Vector2i.RIGHT:
		player_sprite.flip_h = false

	#  Calculate movement in pixels
	var motion := Vector2(direction) * TILE_SIZE

	# Check for collisions before moving
	if not player.test_move(player.global_transform, motion):
		player.move_and_collide(motion)

	# player_address += direction
	# player.position = tile_address_to_position(player_address)
	# Reset direction
	direction = Vector2i.ZERO

	# Print actual player position
	var player_address = position_to_tile_address(player.position)
	print("Player at : ", player_address)

	# Spawn velos!
	# if entities.size() < 5:
	# 	print("Not enough dinos! Hatching more!")
	# 	entities.append(spawn_velo())
	# else:
	# 	print("Too many dinos... waiting.")
	# 	var despawner = Timer.new()
	# 	add_child(despawner)
	# 	despawner.wait_time = tick_time * 1.5
	# 	var target = entities.pop_front()
	# 	despawner.timeout.connect(\
	# 		func() -> void: despawn_velo(target, despawner))
	# 	despawner.start()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_up"):
		direction = Vector2i.UP
	if Input.is_action_pressed("move_down"):
		direction = Vector2i.DOWN
	if Input.is_action_pressed("move_left"):
		direction = Vector2i.LEFT
	if Input.is_action_pressed("move_right"):
		direction = Vector2i.RIGHT
	if Input.is_action_just_pressed("camera_zoomin"):
		game_camera.zoom += Vector2(0.25, 0.25)
	if Input.is_action_just_pressed("camera_zoomout"):
		game_camera.zoom -= Vector2(0.25, 0.25)


# SETUPS
func setup_timer() -> void:
	# Set up the tick timer
	var game_timer = Timer.new()
	add_child(game_timer)
	game_timer.wait_time = tick_time
	game_timer.timeout.connect(game_tick)
	game_timer.start()


# func setup_background() -> void:
# 	for x in range(0, world_size.x):
# 		for y in range(0, world_size.y):
# 			var bg_tile: Sprite2D = Sprite2D.new()
# 			bg_tile.texture = bg_tile_texture
# 			add_child(bg_tile)
# 			bg_tile.position = tile_address_to_position(Vector2i(x, y))
# 			bg_tile.z_index = -1


func setup_camera() -> void:
	game_camera = Camera2D.new()
	player.add_child(game_camera)
	# Center the camera
	# camera.position = world_size * TILE_SIZE / 2.0
	game_camera.enabled = true
	game_camera.zoom = Vector2(5, 5)

# Setup Player
func setup_player() -> void:
	player = CharacterBody2D.new()
	player_sprite = Sprite2D.new()
	player_sprite.texture = player_texture
	# player.scale = Vector2(1.5, 1.5)
	player.add_child(player_sprite)

	@warning_ignore("integer_division")
	player.position = tile_address_to_position(Vector2i(world_size.x / 2, world_size.y / 2))
	player.position -= Vector2(-8, -8)

	var player_collision = CollisionShape2D.new()
	var collision_shape = RectangleShape2D.new()
	collision_shape.size = Vector2(16, 13)
	player_collision.shape = collision_shape

	player.add_child(player_collision)
	add_child(player)



# HELPERS
func tile_address_to_position(address: Vector2i) -> Vector2:
	return address * TILE_SIZE

func position_to_tile_address(pos: Vector2) -> Vector2i:
	return pos / TILE_SIZE

func spawn_velo() -> Sprite2D:
	var velo: Sprite2D = Sprite2D.new()
	add_child(velo)
	@warning_ignore("integer_division")
	var tile := Vector2i(\
		randi_range(world_size.x / 10, world_size.x - 1),\
		randi_range(world_size.y / 10, world_size.y - 1))

	velo.position = tile_address_to_position(tile)
	velo.name = VELO_NAMES[randi_range(0, VELO_NAMES.size() - 1)]
	velo.texture = vel_tex
	# velo.scale = Vector2(2, 2)
	print("Velo \"" + velo.name + "\" spawned at: " + str(position_to_tile_address(velo.position)))
	return velo

func despawn_velo(velo: Sprite2D, timer: Timer) -> void:
	print(velo.name + " has just died! :(")
	velo.queue_free()
	timer.call_deferred("queue_free")
