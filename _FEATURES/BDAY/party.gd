# party.gd
extends Node2D

const GUEST_SCENE: PackedScene = preload("res://_FEATURES/BDAY/bday_entity.tscn")
const LETTER_SCENE: PackedScene = preload("res://_FEATURES/BDAY/birthday_letter.tscn")
const POPUP_SCENE: PackedScene = preload("res://_FEATURES/BDAY/bday_message.tscn")
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

var letter: Area2D
var total_guests: int = 0
var arrived_guests: int = 0

var letter_popup: PopupPanel
var close_button: Button
var popup_layer: CanvasLayer


func _ready() -> void:
	$ColorRect.color = Color.INDIGO
	$Line1.color = Color.GOLD
	$Line2.color = Color.GOLD

	letter = LETTER_SCENE.instantiate()
	add_child(letter)

	letter.hide()
	letter.scale = Vector2(2.5, 2.5)
	letter.position = Vector2(1920.0 / 2, -100)

	popup_layer = POPUP_SCENE.instantiate()
	add_child(popup_layer)

	letter_popup = popup_layer.get_node("LetterPopup")
	close_button = popup_layer.get_node(
		"LetterPopup/PanelContainer/VBoxContainer/CloseButton"
	)

	letter.opened.connect(_on_letter_opened)

	letter_popup.hide()
	close_button.pressed.connect(_close_letter_popup)
	letter_popup.close_requested.connect(_close_letter_popup)

	for message in MESSAGES:
		total_guests += message.length()

	for line_index in range(MESSAGES.size()):
		var msg_ary: PackedStringArray = MESSAGES[line_index].split("", true)
		var line_width: float = (msg_ary.size() - 1) * LETTER_SPACING
		var line_start_x: float = (1920.0 - line_width) / 2.0
		var line_y: float = line_index * LINE_SPACING

		for i in range(msg_ary.size()):
			var carrier = GUEST_SCENE.instantiate()
			carrier.get_node("Emote").add_theme_color_override(
				"default_color",
				Color.MEDIUM_VIOLET_RED
			)
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
				march_speed = 0.010

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

			tween.tween_callback(func():
				carrier.position.x = destination_x
				carrier.is_in_place = true

				arrived_guests += 1

				if arrived_guests >= total_guests:
					_drop_envelope()
			)


func _on_letter_opened() -> void:
	letter_popup.popup_centered()


func _close_letter_popup() -> void:
	letter_popup.hide()
	letter.reset_letter()


func _drop_envelope() -> void:
	letter.show()

	var landing_y: float = (1080.0 / 2) + 100
	var tween := create_tween()

	# Fall and hit the "ground"
	tween.tween_property(
		letter,
		"position:y",
		landing_y,
		0.9
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.tween_property(
		letter,
		"position:y",
		landing_y - 100.0,
		0.55
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		letter,
		"position:y",
		landing_y,
		0.65
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Second bounce
	tween.tween_property(
		letter,
		"position:y",
		landing_y - 70.0,
		0.4
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		letter,
		"position:y",
		landing_y,
		0.45
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# third
	tween.tween_property(
		letter,
		"position:y",
		landing_y - 30.0,
		0.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		letter,
		"position:y",
		landing_y,
		0.3
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


	# allow clicking once it's settled
	tween.tween_callback(func():
		letter.monitoring = true
		letter.can_click = true
		letter.label.show()
	)
