# party.gd
extends Node2D

const GUEST_SCENE: PackedScene = preload("res://_FEATURES/BDAY/bday_entity.tscn")
const LETTER_SCENE: PackedScene = preload("res://_FEATURES/BDAY/birthday_letter.tscn")
const POPUP_SCENE: PackedScene = preload("res://_FEATURES/BDAY/bday_message.tscn")
const CONFETTI_CANNON_SCENE: PackedScene = preload("res://_FEATURES/BDAY/confetti_cannon.tscn")
const MESSAGES: Array[String] = [
	"Happy Birthday",
	"Céline!"
]


const PARTY_COLORS: Array[Color] = [
	Color("#FF4D6D"), # Pink-red
	Color("#FFD166"), # Golden yellow
	Color("#06D6A0"), # Mint green
	Color("#4CC9F0"), # Sky blue
	Color("#9B5DE5"), # Purple
	Color("#F15BB5"), # Pink
	Color("#FFFFFF")  # White
]

var cannons_busy: bool = false

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

@onready var footsteps_sound: AudioStreamPlayer = $FootstepsSound
@onready var envelope_land_sound: AudioStreamPlayer = $EnvelopeLandSound
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var music_button: Button = $PartyButton
@onready var confetti_button: Button = $ConfettiButton

const BEAT_DROP_TIME: float = 16.9
const FLIP_CHECK_INTERVAL: float = 1.0
const BOUNCE_CHECK_INTERVAL: float = 0.4

# dance
var flip_timer: float = 0.0
var bounce_timer: float = 0.0
var beat_drop_triggered: bool = false
var music_started: bool = false

# footsteps
const FOOTSTEP_INVERVAL: float = 0.24
var footstep_timer: float = 0.0
var marching: bool = true

# cannon
var left_cannon: Node2D
var right_cannon: Node2D


func _ready() -> void:
	music_button.hide()
	$ColorRect.color = Color.INDIGO
	$Line1.color = Color.GOLD
	$Line2.color = Color.GOLD

	# CANNON STUFF
	left_cannon = CONFETTI_CANNON_SCENE.instantiate()
	right_cannon = CONFETTI_CANNON_SCENE.instantiate()

	add_child(left_cannon)
	add_child(right_cannon)

	left_cannon.position = Vector2(-180, 650)
	right_cannon.position = Vector2(2100, 650)

	right_cannon.rotation = -45.0

	confetti_button.hide()
	confetti_button.pressed.connect(_on_confetti_button_pressed)
	# END CANNON STUFF


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

	# music_button connection
	music_button.pressed.connect(_on_music_button_pressed)
	music_player.finished.connect(_on_music_finished)

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
					marching = false
					footsteps_sound.stop()
					_drop_envelope()
			)


func _process(delta: float) -> void:
	if not marching:
		_process_celebration(delta)
		return

	footstep_timer += delta

	if footstep_timer >= FOOTSTEP_INVERVAL:
		footstep_timer = 0.0
		footsteps_sound.play()


func _on_letter_opened() -> void:
	letter_popup.popup_centered()


func _close_letter_popup() -> void:
	letter_popup.hide()
	letter.reset_letter()
	music_button.show()


func _drop_envelope() -> void:
	letter.show()

	var landing_y: float = (1080.0 / 2) + 390
	var tween := create_tween()

	# Fall and hit the "ground"
	tween.tween_property(
		letter,
		"position:y",
		landing_y,
		0.9
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.tween_callback(envelope_land_sound.play)

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

# music button pressed ?
func _on_music_button_pressed() -> void:
	if music_player.stream_paused:
		music_player.stream_paused = false
		music_button.text = "⏸ Take a break"
	elif music_player.playing:
		music_player.stream_paused = true
		music_button.text = "🎶 Resume Music!"
	else:
		music_started = true
		beat_drop_triggered = false
		flip_timer = 0.0
		bounce_timer = 0.0

		for guest in $Guests.get_children():
			guest.start_music_celebration()

		music_player.play()
		music_button.text = "⏸ Take a break"


func _on_music_finished() -> void:
	music_started = false
	beat_drop_triggered = false
	flip_timer = 0.0
	bounce_timer = 0.0

	$Fireworks.stop()
	confetti_button.hide()

	music_button.text = "🎵 One more time!"

	for guest in $Guests.get_children():
		guest.reset_celebration()

func _process_celebration(delta: float) -> void:
	if not music_started or not music_player.playing or music_player.stream_paused:
		return

	var music_time: float = music_player.get_playback_position()

	if not beat_drop_triggered and music_time >= BEAT_DROP_TIME:
		beat_drop_triggered = true
		confetti_button.show()
		$Fireworks.start()
		_fire_confetti_cannons()

		for guest in $Guests.get_children():
			guest.start_beat_drop()

	flip_timer += delta
	if flip_timer >= FLIP_CHECK_INTERVAL:
		flip_timer = 0.0

		for guest in $Guests.get_children():
			guest.trigger_flip_chance()

	if beat_drop_triggered:
		bounce_timer = 0.0

		for guest in $Guests.get_children():
			guest.trigger_bounce_chance()


func _on_confetti_button_pressed() -> void:
	_fire_confetti_cannons()


func _fire_confetti_cannons() -> void:
	if cannons_busy:
			return

	cannons_busy = true

	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		left_cannon,
		"position:x",
		-20.0,
		0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		right_cannon,
		"position:x",
		1920.0,
		0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween.finished

	left_cannon.fire(PARTY_COLORS.pick_random())
	right_cannon.fire(PARTY_COLORS.pick_random())

	await get_tree().create_timer(5.0).timeout

	if not is_inside_tree():
			return

	var retreat := create_tween().set_parallel(true)

	retreat.tween_property(left_cannon,	"position:x", -180.0, 0.5)
	retreat.tween_property(right_cannon, "position:x", 2100, 0.5)

	await retreat.finished
	cannons_busy = false
