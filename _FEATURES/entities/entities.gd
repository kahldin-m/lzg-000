class_name Entity
extends Node2D

@export_range(0, 3) var entity_type: int = 0
@export_range(100, 300) var lifespan: int = randi_range(100, 300)
@export var is_pc: bool = false
@export_category("Stats")
@export var age: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var world: World

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.hframes = 2
	sprite.vframes = 4
	sprite.frame = entity_type * 2

	world = get_tree().current_scene if is_inside_tree() else null

	world.age.connect(age_up)


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


func face_direction(direction: Vector2i) -> void:
	if direction == Vector2i.LEFT:
		sprite.flip_h = true
	elif direction == Vector2i.RIGHT:
		sprite.flip_h = false


func age_up() -> void:
	self.age += 1
	# print(
	# 	"My name is ",
	# 	self.name,
	# 	" and I'm ",
	# 	self.age,
	# 	" ticks old!"
	# )
	if self.age >= self.lifespan:
		expire()


func expire() -> void:
	if not self.is_pc:
		# tell parent nest to remove me from the list... I'm tired
		if get_parent() is Nest:
			get_parent().entities.erase(self)
		print("I am tired...")
		print(self.name, " has gone to sleep. X_X")
		queue_free()
	else:
		self.age = 1
		print(self.name, " drank a potion of life! O_O")
