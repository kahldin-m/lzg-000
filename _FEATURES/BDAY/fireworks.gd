
extends Node2D

const FIREWORK_SCENE = preload(
    "res://_FEATURES/BDAY/firework_burst.tscn"
)

@export var launch_interval: float = 1.4
@export var spawn_area := Rect2(100, 100, 1720, 500)

@export var min_launch_interval: float = 0.7
@export var max_launch_interval: float = 1.8

@export var min_fireworks_per_tick: int = 1
@export var max_fireworks_per_tick: int = 4


var timer: float = 0.0
var next_launch_interval: float = 1.0
var active: bool = false


func _process(delta: float) -> void:
	if not active:
		return

	timer += delta

	if timer >= next_launch_interval:
		timer = 0.0
		launch_firework_group()
		next_launch_interval = randf_range(
			min_launch_interval,
			max_launch_interval
		)


func launch_firework_group() -> void:
	var count := randi_range(
	min_fireworks_per_tick,
	max_fireworks_per_tick
	)

	for i in range(count):
		spawn_firework()


func spawn_firework() -> void:
	var firework = FIREWORK_SCENE.instantiate()

	firework.position = Vector2(
		randf_range(
			spawn_area.position.x,
			spawn_area.end.x
		),
		randf_range(
			spawn_area.position.y,
			spawn_area.end.y
		)
	)

	add_child(firework)


func start() -> void:
	active = true
	timer = 0.0
	next_launch_interval = randf_range(
		min_launch_interval,
		max_launch_interval
	)


func stop() -> void:
	active = false
