
extends Node2D

@export var particle_count: int = 55
@export var burst_speed: float = 280.0
@export var gravity: float = 100.0
@export var particle_lifetime: float = 1.8

var particles: Array[Dictionary] = []
var elapsed: float = 0.0
var burst_color: Color


func _ready() -> void:
    burst_color = Color.from_hsv(
        randf(),
        randf_range(0.65, 1.0),
        1.0
    )

    for i in range(particle_count):
        var angle := randf_range(0.0, TAU)
        var speed := burst_speed * randf_range(0.45, 1.0)

        particles.append({
            "position": Vector2.ZERO,
            "velocity": Vector2.RIGHT.rotated(angle) * speed,
            "life": randf_range(0.7, particle_lifetime),
            "max_life": particle_lifetime
        })

    queue_redraw()


func _process(delta: float) -> void:
    elapsed += delta

    for particle in particles:
        particle["position"] += particle["velocity"] * delta
        particle["velocity"] += Vector2.DOWN * gravity * delta
        particle["life"] -= delta

    queue_redraw()

    if elapsed >= particle_lifetime:
        queue_free()


func _draw() -> void:
    for particle in particles:
        var life: float = particle["life"]
        if life <= 0.0:
            continue

        var alpha := clampf(
            life / particle["max_life"],
            0.0,
            1.0
        )

        var color := burst_color
        color.a = alpha

        var radius := lerpf(2.0, 7.0, alpha)

        draw_circle(
            particle["position"],
            radius,
            color
        )
