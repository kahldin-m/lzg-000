class_name World
extends Node2D

@export_category("DEBUG")
@export var DEBUG_MODE: bool = false

@export_category("Game Settings")
@export var tick_time: float = 0.3
@export var world_size: Vector2i = Vector2i(64, 32)
@export var starting_tile: Vector2i = Vector2i(0, 0)

@export_category("Simulation Settings")
@export var max_pop: int = 24
var current_pop: int

var player: Entity
var world_pop: Array[Entity] = []
var ent_node: Node2D
var game_camera: Camera2D

@onready var tile_layers: Array[TileMapLayer] = [
	$TileLayers/Water_BG,
	$TileLayers/Water,
	$TileLayers/Plateaus,
	$TileLayers/Decor,
	$TileLayers/Ground,
]

const TILE_SIZE := 16
const ENTITY_SCENE: PackedScene = preload("res://_FEATURES/entities/entities.tscn")
const ENTITY_SPEED := 50

signal hatch(tick_time: float)
signal mate_found(entity: Entity)
signal wander()
signal mate_tick()
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
	if game_camera.zoom < Vector2.ONE:
		game_camera.zoom = Vector2.ONE

func game_tick():
	wander.emit()
	mate_tick.emit()
	age.emit()
	hatch.emit(tick_time)


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
	game_camera.limit_left = -270
	game_camera.limit_top = -270
	game_camera.limit_bottom = 1080
	game_camera.limit_right = 1920



# Setup Player
func setup_player() -> void:
	player = ENTITY_SCENE.instantiate()

	player.is_pc = true
	player.entity_type = 0
	player.name = "Player"
	player.position = tile_address_to_position(starting_tile)

	add_child(player)
	register_entity(player)


# HELPERS
func tile_address_to_position(address: Vector2i) -> Vector2:
	return address * TILE_SIZE


func position_to_tile_address(pos: Vector2) -> Vector2i:
	return pos / TILE_SIZE


func is_tile_walkable(address: Vector2i) -> bool:
	# Check the logged layers for no_walk Custom Data
	for layer in tile_layers:
		var tile_data: TileData = layer.get_cell_tile_data(address)

		if tile_data == null:
			continue

		if tile_data.has_custom_data("no_walk"):
			var no_walk = tile_data.get_custom_data("no_walk")

			if no_walk:
				return false

		continue

	return true


func is_land_tile(address: Vector2i) -> bool:
	# Check the logged layers for is_land Custom Data
	for layer in tile_layers:
		var tile_data: TileData = layer.get_cell_tile_data(address)

		if tile_data == null:
			continue

		if tile_data.has_custom_data("is_land"):
			var is_land = tile_data.get_custom_data("is_land")

			if is_land:
				return true

		continue

	return false



func is_water_tile(address: Vector2i) -> bool:
	# Check the logged layers for is_water Custom Data
	for layer in tile_layers:
		var tile_data: TileData = layer.get_cell_tile_data(address)

		if tile_data == null:
			continue

		if tile_data.has_custom_data("is_water"):
			var is_water = tile_data.get_custom_data("is_water")

			if is_water:
				return true

		continue

	return false


func is_food_tile(address: Vector2i) -> bool:
	for layer in tile_layers:
		var tile_data: TileData = layer.get_cell_tile_data(address)

		if tile_data == null:
			continue

		# does the tile have "is_food" data?
		if tile_data.has_custom_data("is_food"):
			var is_food = tile_data.get_custom_data("is_food")

			if is_food:
				return true
		# if not, continue to next layer
		continue

	return false


func register_entity(entity: Entity) -> void:
	if world_pop.has(entity):
		return

	world_pop.append(entity)
	entity.mate_found.connect(_on_entity_mate_found.bind(entity))


func _on_entity_mate_found(entity: Entity) -> void:
	# Forward the event to the nest system
	print(entity.name, " found a potential mate.")
	mate_found.emit(entity)


# Dice
func d100() -> int:
	return randi() % 100 + 1


func d3() -> int:
	return randi() % 3 + 1


func d4() -> int:
	return randi() % 4 + 1
