class_name Nest
extends Entity

@export var nest_min: int = 2
@export var nest_max: int = 8
@export var spawn_interval: int = 6

var entities_node: Node2D
var nest_pop: Array[Entity] = []
var internal_timer: int = 0

func _ready() -> void:
	world = get_tree().current_scene if is_inside_tree() else null
	sprite.hframes = 4
	sprite.vframes = 1
	sprite.frame = entity_type

	world.hatch.connect(spawn_check)

	world.mate_found.connect(_on_mate_found)


func _process(_delta: float) -> void:
	pass


func spawn_check(_tick_time: float) -> void:
# Check if we need to spawn entities for this nest
	# if the nest is full, just return for now
	if nest_pop.size() >= nest_min:
		return

	internal_timer += 1
	if internal_timer < spawn_interval:
		return

	var entity: Entity = spawn_entity()

	if entity != null:
		# print("Not enough entities from nest - hatching more!")
		world.register_entity(entity)
		nest_pop.append(entity)
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
	# Generate tile to spawn entity
	var offset := Vector2i(\
		randi_range(-5, +5),\
		randi_range(-5, +5))

	if offset == Vector2i.ZERO:
		offset = Vector2i.ONE

	entities_node = get_parent().get_node_or_null("../Entities")
	if entities_node == null:
		return null
	var entity: Entity = World.ENTITY_SCENE.instantiate()
	var spawn_tile: Vector2i = world.position_to_tile_address(self.global_position) + offset
	# If offset is not walkable, return before setting up the rest
	if not world.is_tile_walkable(spawn_tile):
		entity.queue_free()
		return null

	# Entity setup
	var name_part1: String = ENTITY_NAMES[randi_range(0, ENTITY_NAMES.size() - 1)]
	entity.home_nest = self
	entities_node.add_child(entity)
	entity.position = world.tile_address_to_position(spawn_tile)
	entity.entity_type = entity_type
	entity.name = name_part1 + " the " + DINO_TYPE[entity.entity_type]
	entity.lifespan = randi_range(100, 300)
	entity.age = 1
	print(">> ", entity.name, " hatched! <<")

	return entity

# func despawn_entity(entity: Entity, timer: Timer) -> void:
# 	print(entity.name + " has just died! :(")
# 	entity.queue_free()
# 	timer.call_deferred("queue_free")


func _on_mate_found(entity: Entity) -> void:
	if entity.entity_type != entity_type:
		return

	if nest_pop.size() >= nest_max:
		print("Too many ", entity_type)
		return

	var baby := spawn_entity()

	if baby != null:
		nest_pop.append(baby)
		world.register_entity(baby)
		print(baby.name, " was born!")
		# print("Baby registered. Nest population: ", nest_pop.size())
	else:
		print("Spawn failed.")
