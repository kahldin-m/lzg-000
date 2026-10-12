class_name Entity
extends Node2D

@export_range(0, 3) var entity_type: int = 0
@export_range(0, 300) var lifespan: int = 0
@export var is_pc: bool = false
@export_category("Stats")
@export var age: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var world: World
var direction: Vector2i = Vector2i.ZERO
var dir_array: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]

var tile_address: Vector2i
var animation_timer := 0.8
const ANIMATION_SPEED := 0.5
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
	"Juliette",
	"Casper",
]
const DINO_TYPE := [
	"Tyrannosaurus",
	"Velociraptor",
	"Compsognathus ",
	"Rhamphorhynchus"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.hframes = 2
	sprite.vframes = 4
	sprite.frame = entity_type * 2

	world = get_tree().current_scene as World

	if world != null:
		world.age.connect(action_age)
		if not self.is_pc:
			world.wander.connect(action_wander)
		else:
			world.wander.connect(action_move)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animation_timer += delta

	if animation_timer >= ANIMATION_SPEED:
		animation_timer = 0.0

		# Toggle between the two frames belonging to this creature type
		if sprite.frame == entity_type * 2:
			sprite.frame = entity_type * 2 + 1
		else:
			sprite.frame = entity_type * 2

	# Movement control
	if not is_pc:
		return

	if Input.is_action_pressed("move_up"):
		direction = dir_array[0]
	elif Input.is_action_pressed("move_down"):
		direction = dir_array[1]
	elif Input.is_action_pressed("move_left"):
		direction = dir_array[2]
	elif Input.is_action_pressed("move_right"):
		direction = dir_array[3]


func face_direction(dir: Vector2i) -> void:
	if dir == Vector2i.LEFT:
		sprite.flip_h = true
	elif dir == Vector2i.RIGHT:
		sprite.flip_h = false


func action_move() -> void:
	if direction == Vector2i.ZERO:
		return

	# Flip sprite based on direction
	self.face_direction(direction)

		#  Calculate target tile
	var current_tile := world.position_to_tile_address(self.position)
	var target_tile := current_tile + direction

	# Move if target tile is walkable
	if world.is_tile_walkable(target_tile):
		self.position = world.tile_address_to_position(target_tile)

	# Check the tile we're on now for food
	var decor_layer: TileMapLayer = world.collision_layers[2]

	var player_address := decor_layer.local_to_map(
		decor_layer.to_local(self.global_position)
	)
	var tile_data := decor_layer.get_cell_tile_data(player_address)


	if tile_data and tile_data.get_custom_data("has_food"):
		decor_layer.erase_cell(player_address)
		# print here om nom nom

	# Reset direction
	direction = Vector2i.ZERO

	# Print actual player position
	print(name, " at : ", player_address)


func action_wander() -> void:
	# roll the dice, move your mice
	var my_dir := randi_range(0, dir_array.size() - 1)

	# roughly 1 in 3 chance to move
	if world.d3() == 1:
		var new_dir := dir_array[my_dir]
		var new_pos := world.position_to_tile_address(self.global_position) + new_dir
		if world.is_tile_walkable(new_pos):
			self.global_position = world.tile_address_to_position(new_pos)
			face_direction(new_dir)


func action_age() -> void:
	if self.age != 0:
		self.age += 1
		if self.age >= self.lifespan:
			action_expire()


func action_expire() -> void:
	if not self.is_pc:
		# tell parent nest to remove me from the list... I'm tired
		get_parent().entities.erase(self)
		# print("I'm tired boss...")
		# print(self.name, " has gone to sleep. X_X")
		queue_free()
	else:
		self.age = 1
		# print(self.name, " drank a potion of life! O_O")
