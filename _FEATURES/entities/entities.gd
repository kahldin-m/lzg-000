class_name Entity
extends Node2D

@export_category("Settings")
@export_range(0, 3) var entity_type: int = 0
@export_range(0, 300) var lifespan: int = 0
@export var mate_cooldown: int = 50 # n * tick_time
@export var is_pc: bool = false
@export_category("Stats")
@export var age: int = 0
@export var hunger: int = 100

@onready var sprite: Sprite2D = $Sprite2D

var world: World
var timer: Timer
var emote: RichTextLabel
var home_nest: Nest
var direction: Vector2i = Vector2i.ZERO
var current_tile: Vector2i
var just_moved: bool = false
@onready var mate_timer: int = mate_cooldown

signal mate_found()

var tile_address: Vector2i
var animation_timer := 0.8
const ANIMATION_SPEED := 0.5
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP + Vector2i.LEFT,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.DOWN + Vector2i.RIGHT,
]
# make this a dict, with name keys and gender values at some point
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
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.frame_coords.x = 0

	emote = $Emote
	timer = $EmoteTimer

	world = get_tree().current_scene as World

	if world != null:
		world.mate_tick.connect(action_mate_tick)
		current_tile = world.position_to_tile_address(self.global_position)
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

		# Toggle between the two frames belonging to this creature type and check if swimming
		var is_land := world.is_land_tile(current_tile)
		var is_swimming: bool = not is_land and world.is_water_tile(current_tile)

		var start_frame := 2 if is_swimming else 0

		sprite.frame_coords.y = entity_type

		if sprite.frame_coords.x == start_frame:
			sprite.frame_coords.x = start_frame + 1
		else:
			sprite.frame_coords.x = start_frame


	# Movement control
	if not is_pc:
		return

	if Input.is_action_pressed("move_up"):
		direction = DIRECTIONS[0]
	elif Input.is_action_pressed("move_down"):
		direction = DIRECTIONS[1]
	elif Input.is_action_pressed("move_left"):
		direction = DIRECTIONS[2]
	elif Input.is_action_pressed("move_right"):
		direction = DIRECTIONS[3]


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
	var target_tile := current_tile + direction

	# Move if target tile is walkable
	if world.is_tile_walkable(target_tile):
		self.position = world.tile_address_to_position(target_tile)

	# Check the target tile for food
	if world.is_food_tile(target_tile):
		world.tile_layers[3].erase_cell(target_tile)
		show_emote("🌿[color=green]+[/color]")

	# Reset direction and update current_tile
	direction = Vector2i.ZERO
	current_tile = world.position_to_tile_address(self.global_position)
	# Print actual player position
	print(name, " at : ", current_tile)



func action_wander() -> void:
	# roll the dice, move your mice
	var my_dir := randi_range(0, DIRECTIONS.size() - 1)

	# roughly 1 in 3 chance to move
	if world.d3() == 1:
		var new_dir := DIRECTIONS[my_dir]
		var target_tile := world.position_to_tile_address(self.global_position) + new_dir
		if world.is_tile_walkable(target_tile):
			self.global_position = world.tile_address_to_position(target_tile)
			current_tile = world.position_to_tile_address(self.global_position)
			face_direction(new_dir)


func action_age() -> void:
	if self.age == 0:
		return

	self.age += 1
	if self.age > self.lifespan:
		expire()


func action_mate() -> void:
	if mate_timer > 0:
		return

	for dino in world.world_pop:
		if dino == self:
			continue
		if dino.entity_type != self.entity_type:
			continue

		var mate_tile := world.position_to_tile_address(dino.global_position)
		if mate_tile in get_surrounding_tiles():
			print(self.name, " says: 'Hey, there's a mate nearby! :D'")
			# Mating now on cooldown
			mate_timer = mate_cooldown
			mate_found.emit()
			show_emote("😍[color=pink]![/color]")
			return


func action_mate_tick() -> void:
	if mate_timer > 0:
		mate_timer -= 1
	action_mate()

func expire() -> void:
	if not self.is_pc:
		# tell parent nest to remove me from the list... I'm tired
		world.world_pop.erase(self)

		if is_instance_valid(home_nest):
			home_nest.nest_pop.erase(self)

		print(self.name, " has gone to...sleep x__x")
		queue_free()
	else:
		self.age = 1
		# print(self.name, " drank a potion of life! O_O")


func get_surrounding_tiles() -> Array[Vector2i]:
	var surrounding_tiles: Array[Vector2i] = []

	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue

			surrounding_tiles.append(self.current_tile + Vector2i(x, y))

	return surrounding_tiles


func show_emote(msg: String) -> void:
	self.emote.text = msg
	self.timer.start(4.0)


func _on_emote_timer_timeout() -> void:
	self.emote.text = ""
