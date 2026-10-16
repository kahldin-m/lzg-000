
extends Node2D

@onready var barrel: Polygon2D = $Barrel
@onready var confetti: GPUParticles2D = $Confetti

var original_position: Vector2
var particle_material: ParticleProcessMaterial


func _ready() -> void:
	original_position = position

	var source_material := confetti.process_material as ParticleProcessMaterial
	if source_material:
		particle_material = source_material.duplicate() as ParticleProcessMaterial
		confetti.process_material = particle_material


func fire(color: Color = Color.WHITE) -> void:
	if particle_material:
		particle_material.color = color

	confetti.restart()
	confetti.emitting = true
