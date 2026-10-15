# party.gd
extends Node2D

const GUEST_SCENE: PackedScene = preload("res://_FEATURES/BDAY/bday_entity.tscn")

const MESSAGES: Array[String] = [
	"Happy Birthday",
	"Céline!"
]

const GUEST_SCALE: float = 5.0
const TILE_SIZE: float = 16.0
const BASE_MARCH_SPEED: float = 0.06
const FASTEST_MARCH_SPEED: float = 0.04
const LETTER_SPACING: float = 120.0 # 24 * 5
const LINE_SPACING: float = 240.0 # 48 * 5


func _ready() -> void:
	for line_index in range(MESSAGES.size()):
		var msg_ary: PackedStringArray = MESSAGES[line_index].split("", true)
		var line_width: float = (msg_ary.size() - 1) * LETTER_SPACING
		var line_start_x: float = (1920.0 - line_width) / 2.0
		var line_y: float = line_index * LINE_SPACING

		for i in range(msg_ary.size()):
			var carrier = GUEST_SCENE.instantiate()
			var destination_x: float = line_start_x + i * LETTER_SPACING
			var start_x: float = -48.0 * GUEST_SCALE
			var destination_distance: float = destination_x - start_x

			var progress: float = float(i) / maxf(float(msg_ary.size() - 1), 1.0)
			var march_speed: float = lerpf(
				BASE_MARCH_SPEED,
				FASTEST_MARCH_SPEED,
				progress
			)


			carrier.set_entity_type(i % 5)
			$Guests.add_child(carrier)

			carrier.scale = Vector2(GUEST_SCALE, GUEST_SCALE)
			carrier.set_animation_offset(i % 2)
			carrier.show_emote(msg_ary[i])
			carrier.position = Vector2(start_x, line_y)
			carrier.name = "Guest" + str(line_index) + " " + str(i)

			var step_count: int = ceili(destination_distance / TILE_SIZE)
			var tween := create_tween()

			if line_index == 1 and msg_ary[i] == "!":
				tween.tween_interval(5.0)
				march_speed = 0.015

			for step in range(step_count):
				var target_x: float = minf(
					start_x + TILE_SIZE * (step + 1),
					destination_x
				)

				tween.tween_property(
					carrier,
					"position:x",
					target_x,
					march_speed
				).set_trans(Tween.TRANS_LINEAR)

			tween.tween_callback(func(): carrier.position.x = destination_x)
