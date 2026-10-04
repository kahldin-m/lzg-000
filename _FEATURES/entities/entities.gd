class_name Entity
extends Node2D

@export_range(0, 3) var creature_type: int = 0
@export var is_pc: bool = false

@onready var sprite: Sprite2D = $Art

var tile_address: Vector2i
var animation_timer := 0.8
const ANIMATION_SPEED := 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Art.hframes = 2
	$Art.vframes = 4
	$Art.frame = creature_type * 2

	add_to_group("entities")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animation_timer += delta

	if animation_timer >= ANIMATION_SPEED:
		animation_timer = 0.0

		# Toggle between the two frames belonging to this creature type
		if sprite.frame == creature_type * 2:
			sprite.frame = creature_type * 2 + 1
		else:
			sprite.frame = creature_type * 2


func face_direction(direction: Vector2i) -> void:
	if direction == Vector2i.LEFT:
		sprite.flip_h = true
	elif direction == Vector2i.RIGHT:
		sprite.flip_h = false
