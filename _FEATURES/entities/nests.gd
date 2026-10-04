extends Node2D

# Nest types: 0 = trex, 1 = velo
@export_range(0, 1) var nest_type: int = 0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	$Sprite2D.hframes = 2
	$Sprite2D.vframes = 1
	$Sprite2D.frame = nest_type
