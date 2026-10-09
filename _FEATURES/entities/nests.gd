class_name Nest
extends Entity

@export var nest_size: int = 1
@export var spawn_interval: int = 6	

var entities: Array[Entity] = []
var internal_timer: int = 0

func _ready() -> void:
	world = get_tree().current_scene if is_inside_tree() else null
	sprite.hframes = 4
	sprite.vframes = 1
	sprite.frame = entity_type

	world.hatch.connect(spawn_check)

func _process(_delta: float) -> void:
	pass


func spawn_check(_tick_time: float) -> void:
# Check if we need to spawn entities for this nest
	# if the nest is full, just return for now
	if entities.size() >= nest_size:
		return

	internal_timer += 1
	print(internal_timer)
	
	if internal_timer < spawn_interval:
		return

	print("Not enough entities from nest - hatching more!")
	entities.append(spawn_entity())
	internal_timer = 0
	
	# print("Nest at max capacity! Waiting to cull.")
	# var despawner = Timer.new()
	# add_child(despawner)
	# despawner.wait_time = spawn_interval
	# var target: Entity = entities.pop_front()
	# despawner.timeout.connect(\
	# 	func() -> void: despawn_entity(target, despawner))
	# despawner.start()

func spawn_entity() -> Entity:
	var entity: Entity = World.ENTITY_SCENE.instantiate()

	var offset := Vector2i(\
		randi_range(-5, +5),\
		randi_range(-5,+5))

	entity.position = world.tile_address_to_position(offset)
	entity.entity_type = entity_type
	entity.name = ENTITY_NAMES[randi_range(0, ENTITY_NAMES.size() - 1)]

	add_child(entity)

	print(
		"Entity spawned. Type: ",
		entity.entity_type,
		" at: ",
		offset)

	return entity

func despawn_entity(entity: Entity, timer: Timer) -> void:
	print(entity.name + " has just died! :(")
	entity.queue_free()
	timer.call_deferred("queue_free")
