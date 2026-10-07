class_name Entity
extends Node2D

@export_range(0, 3) var entity_type: int = 0
@export var is_pc: bool = false

@onready var sprite: Sprite2D = $Sprite2D

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
	"Juliete",
	"Casper",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.hframes = 2
	sprite.vframes = 4
	sprite.frame = entity_type * 2

	add_to_group("entities")


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
