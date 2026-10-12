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

@onready var collision_layers: Array[TileMapLayer] = [
	$TileLayers/Water,
	$TileLayers/Plateaus,
	$TileLayers/Decor
]

const TILE_SIZE := 16
const ENTITY_SCENE: PackedScene = preload("res://_FEATURES/entities/entities.tscn")
const ENTITY_SPEED := 50

signal hatch(tick_time: float)
signal wander()
signal age()


# ready, process and game_tick
func _ready() -> void:
	setup_player()
	setup_camera()
	setup_timer()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("camera_zoomin"):
		game_camera.zoom += Vector2(0.25, 0.25)
	if Input.is_action_just_pressed("camera_zoomout"):
		game_camera.zoom -= Vector2(0.25, 0.25)


func game_tick():
	hatch.emit(tick_time)
	wander.emit()
	age.emit()



# SETUPS
func setup_timer() -> void:
	# Set up the tick timer
	var game_timer = Timer.new()
	add_child(game_timer)
	game_timer.wait_time = tick_time
	game_timer.timeout.connect(game_tick)
	game_timer.start()


func setup_camera() -> void:
	game_camera = Camera2D.new()
	player.add_child(game_camera)

	game_camera.enabled = true
	game_camera.zoom = Vector2(5, 5)


# Setup Player
func setup_player() -> void:
	player = ENTITY_SCENE.instantiate()

	player.is_pc = true
	player.entity_type = 0
	player.name = "Player"

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
	# Check the logged layers for no_walk Custom Data
	for layer in collision_layers:
		var tile_data: TileData = layer.get_cell_tile_data(address)

		if tile_data == null:
			continue

		if tile_data.has_custom_data("no_walk"):
			var no_walk = tile_data.get_custom_data("no_walk")

			if no_walk:
				return false

		continue

	return true
