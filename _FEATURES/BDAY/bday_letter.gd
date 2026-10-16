extends Area2D

signal opened

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label

var is_opening: bool = false
var can_click: bool = false


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("closed")



func _input_event(
	_viewport: Viewport,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not can_click:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_opening:
				return

			is_opening = true
			$OpenSound.play()
			sprite.play("open")
			label.hide()



func _on_animation_finished() -> void:
	if sprite.animation == "open":
		opened.emit()


func reset_letter() -> void:
	is_opening = false
	sprite.stop()
	sprite.play("closed")
