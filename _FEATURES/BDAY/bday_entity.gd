# bday_entity.gd
extends Node2D

@export_range(0, 4) var entity_type: int = 0
@export var animation_speed: float = 0.5

@onready var sprite: Sprite2D = $Sprite
@onready var emote: RichTextLabel = $Emote

var animation_timer: float = 0.8
var animation_frame: int = 0
var bounce_tween: Tween
var is_in_place: bool = false


func _ready() -> void:
	sprite.hframes = 2
	sprite.vframes = 5
	sprite.frame_coords.x = 0


func _process(delta: float) -> void:
	animation_timer += delta

	if animation_timer >= animation_speed:
		animation_timer = 0.0
		animation_frame = 1 - animation_frame
		sprite.frame = entity_type * 2 + animation_frame
		if animation_frame == 1:
			emote.position.y = -40
		else:
			emote.position.y = -42

	if is_in_place:
		var rando := randi() % 100 + 1
		if rando == 1:
			sprite.flip_h = not sprite.flip_h
			try_bounce()


func show_emote(msg: String) -> void:
	emote.text = msg


func set_entity_type(new_type: int) -> void:
	entity_type = wrapi(new_type, 0, 5)

	if is_node_ready():
		sprite.frame = entity_type * 2 + animation_frame


func set_animation_offset(offset: int) -> void:
	animation_frame = offset
	sprite.frame = entity_type * 2 + animation_frame


func try_bounce() -> void:
	if bounce_tween and bounce_tween.is_running():
		return

	var original_y: float = sprite.position.y
	bounce_tween = create_tween()
	bounce_tween.tween_property(sprite, "position:y", original_y - 8.0, 0.12)
	bounce_tween.tween_property(sprite, "position:y", original_y, 0.12)
