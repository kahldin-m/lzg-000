extends Entity

# Nest types: 0 = trex, 1 = velo
@export_range(0, 3) var nest_type: int = 0
@export var nest_size: int = 1

var entities: Array[Entity] = []


func _ready() -> void:
	sprite.hframes = 4
	sprite.vframes = 1
	sprite.frame = nest_type


func spawn_check(coord: Vector2i, tick_time: float) -> void:
# Spawn entities!
	if entities.size() < nest_size:
		print("Not enough entities from nest—hatching more!")
		entities.append(spawn_entity(coord))
	else:
		print("Nest at max capacity! Waiting to cull.")
		var despawner = Timer.new()
		add_child(despawner)
		despawner.wait_time = tick_time * 3
		var target: Entity = entities.pop_front()
		despawner.timeout.connect(\
			func() -> void: despawn_entity(target, despawner))
		despawner.start()

func spawn_entity(coord: Vector2i) -> Entity:
	var entity: Entity = World.ENTITY_SCENE.instantiate()

	@warning_ignore("integer_division")
	var tile := Vector2i(\
		randi_range(coord.x / 10, coord.x - 1),\
		randi_range(coord.y / 10, coord.y - 1))

	entity.position = tile_address_to_position(tile)
	entity.creature_type = randi_range(0, 3)
	entity.name = ENTITY_NAMES[randi_range(0, ENTITY_NAMES.size() - 1)]

	add_child(entity)

	print("Entity spawned. Type: ", entity.creature_type, " at: ", position_to_tile_address(entity.position))
	return entity

func despawn_entity(entity: Entity, timer: Timer) -> void:
	print(entity.name + " has just died! :(")
	entity.queue_free()
	timer.call_deferred("queue_free")