extends Node2D

@onready var barrel: Polygon2D = $Barrel
@onready var confetti: GPUParticles2D = $Confetti

var original_position: Vector2


func _ready() -> void:
	original_position = position


func fire() -> void:
	confetti.restart()
	confetti.emitting = true
