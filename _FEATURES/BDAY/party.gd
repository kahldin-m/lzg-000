# party.gd
extends Node2D

const GUEST_SCENE: PackedScene = preload("res://_FEATURES/BDAY/bday_entity.tscn")
const TILE_SIZE: float = 16.0
@export var LEFT_MARCH_SPEED: float = 0.12
@export var RIGHT_MARCH_SPEED: float = 0.06
var MSG: String = "Happy Birthday Céline!"


func _ready() -> void:
	var msg_ary: PackedStringArray = MSG.split("", true)

	for i in range(msg_ary.size()):
		var carrier = GUEST_SCENE.instantiate()
		var destination_x: float = i * 24.0
		var start_x: float = -48.0 if i % 2 == 0 else 1896.0
		var march_speed: float = LEFT_MARCH_SPEED if i % 2 == 0 else RIGHT_MARCH_SPEED

		carrier.set_entity_type(i % 5)
		$Guests.add_child(carrier)

		carrier.set_animation_offset(i % 2)
		carrier.show_emote(msg_ary[i])

		carrier.position = Vector2(start_x, 0.0)

		var distance: float = absf(destination_x - start_x)
		var step_count: int = ceili(distance / TILE_SIZE)
		var direction: float = signf(destination_x - start_x)

		var tween := create_tween()

		for step in range(step_count):
			var target_x: float = start_x + direction * TILE_SIZE * (step + 1)

			tween.tween_property(
				carrier,
				"position:x",
				target_x,
				march_speed
			).set_trans(Tween.TRANS_LINEAR)


		carrier.name = "Guest " + msg_ary[i]
