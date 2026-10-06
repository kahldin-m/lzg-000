class_name World
extends Node2D

@export_category("DEBUG")
@export var DEBUG_MODE: bool = false
@export_category("Game Settings")
@export var tick_time: float = 0.3
@export var world_size: Vector2i = Vector2i(64, 32)
@export var starting_tile: Vector2i = Vector2i(0, 0)
# var bg_tile_texture: Texture2D = preload("res://_FEATURES/the_world/grass_01.png")

var player: Entity
var game_camera: Camera2D
var direction: Vector2i = Vector2i.ZERO

@onready var decor_layer: TileMapLayer = $TileLayers/Decor

const TILE_SIZE := 16
const ENTITY_SCENE: PackedScene = preload("res://_FEATURES/entities/entities.tscn")
const ENTITY_SPEED := 50
const ENTITY_NAMES := [
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



func game_tick():
	if direction == Vector2i.ZERO:
		return

	# Flip sprite based on direction
	player.face_direction(direction)

	#  Calculate target tile
	var current_tile := position_to_tile_address(player.position)
	var target_tile := current_tile + direction

	# Move if target tile is walkable
	if is_tile_walkable(target_tile):
		player.position = tile_address_to_position(target_tile)

	# Check the tile we're on now
	var player_address := decor_layer.local_to_map(
		decor_layer.to_local(player.global_position)
	)
	var tile_data := decor_layer.get_cell_tile_data(player_address)


	if tile_data and tile_data.get_custom_data("has_food"):
		decor_layer.erase_cell(player_address)
		print("****OM NOM NOM!!!****")
	# Check for collisions before moving

	# player_address += direction
	# player.position = tile_address_to_position(player_address)
	# Reset direction
	direction = Vector2i.ZERO

	# Print actual player position
	print("Player at : ", player_address)



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

	game_camera.enabled = true
	game_camera.zoom = Vector2(5, 5)

# Setup Player
func setup_player() -> void:
	player = ENTITY_SCENE.instantiate()

	player.is_pc = true
	player.creature_type = 0
	player.name = "Player"

	@warning_ignore("integer_division")
	player.position = tile_address_to_position(starting_tile)

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


func is_tile_walkable(address: Vector2i) -> bool:
	var tile_data := decor_layer.get_cell_tile_data(address)

	if tile_data == null:
		return true

	return tile_data.get_custom_data("is_walkable")
