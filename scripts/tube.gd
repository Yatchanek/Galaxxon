extends Node3D
class_name Segment

@export var length : int = 500
@export var bunker_scene : PackedScene
@export var silo_scene : PackedScene
@export var stationary_plane_scene : PackedScene
@export var obstacle_scene : PackedScene
@export var hole_obstacle_scene : PackedScene
@export var block_scene : PackedScene
@export var mountain_meshes : Array[ArrayMesh] = []


signal obstacles_placed

enum ObstacleTypes {
	NORMAL_OBSTACLE,
	HIGH_OBSTACLE,
	WALL,
	NOTHING
}

var thread : Thread
var grid_size : Vector2i
var grid_cell_size : Vector2i = Vector2(10, 15)

var obstacle_grid : PackedInt32Array = []

var y_pos : float = 10.0

var signal_sent : bool = false
var exit_signal_sent : bool = false

var current_z : int

func initialize():
	current_z = 0
	grid_size = Vector2i(60 / grid_cell_size.x, (length - 10 * grid_cell_size.y) / grid_cell_size.y)
	obstacle_grid.resize(grid_size.x * grid_size.y)
	obstacle_grid.fill(ObstacleTypes.NOTHING)
	thread = Thread.new()
	thread.start(create_obstacles)

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	show()

func create_mountains():
	var current_z : float = 0.0
	while current_z >= -500:
		var mountain : MeshInstance3D = MeshInstance3D.new()
		mountain.scale *= 2.0
		mountain.mesh = mountain_meshes.pick_random()
		mountain.position.x = randf_range(-2, 2)
		mountain.position.z = current_z
		mountain.rotate_y(randf_range(0, TAU))
		$Land/Front.add_child(mountain)
		current_z -= 15

	current_z = 0.0
	while current_z >= -560:
		var mountain : MeshInstance3D = MeshInstance3D.new()
		mountain.scale *= 3.0
		mountain.mesh = mountain_meshes.pick_random()
		mountain.position.x = randf_range(-2, 2)
		mountain.position.z = current_z
		mountain.rotate_y(randf_range(0, TAU))
		$Land/Back.add_child(mountain)
		current_z -= 30
	obstacles_placed.emit()


func create_obstacles():
	var row : int = 0
	while row < grid_size.y:
		var roll : float = Globals.RNG.randf()
		if roll < 0.05:
			row += 2
			roll = Globals.RNG.randf()
			var obstacle : Node3D
			if roll < 0.9:
				obstacle = obstacle_scene.instantiate()
			else:
				obstacle = hole_obstacle_scene.instantiate()
  
			obstacle.position = Vector3(-30, 10, -65 -grid_cell_size.y * (5 + row))
			add_child(obstacle)     
			row += 3
		elif roll < 0.6:
			var items_in_row : int = 1
			roll = Globals.RNG.randf()
			if roll < 0.025:
				items_in_row = 3
			elif roll < 0.1:
				items_in_row = 2
			var slots : Array = range(0, grid_size.x)
			for i in items_in_row:
				roll = Globals.RNG.randf()
				var idx : int = Globals.RNG.randi_range(0, slots.size() - 1)
				var x_coord : int = slots[idx]
				slots.remove_at(idx)
				var bldg : Building
				roll = Globals.RNG.randf()
				if roll < 0.15:
					bldg = bunker_scene.instantiate()
				elif roll < 0.65:
					bldg = silo_scene.instantiate()
				else:
					bldg = stationary_plane_scene.instantiate()
				if row > 0:
					while obstacle_grid[(row - 1) * grid_size.x + x_coord] == ObstacleTypes.HIGH_OBSTACLE or obstacle_grid[(row - 1) * grid_size.x + x_coord] == ObstacleTypes.WALL:
						idx = Globals.RNG.randi_range(0, slots.size() - 1)
						x_coord = slots[idx]
						slots.remove_at(idx)

				bldg.position = Vector3(-30 + grid_cell_size.x * (x_coord + 0.5), y_pos, -65 - grid_cell_size.y * (5 + row))
				obstacle_grid[row * grid_size.x + x_coord] = ObstacleTypes.NORMAL_OBSTACLE
				roll = Globals.RNG.randf()

				add_child(bldg)

			row += 1            
	create_trees()

func create_trees():
	var points : PackedVector2Array = generate_poisson_points(7, Vector2(25, 550))
	var trees : MultiMeshInstance3D = $Land/Front/Trees
	var trees_2 : MultiMeshInstance3D = $Land/Front/Trees2
	var trees_3 : MultiMeshInstance3D = $Land/Front/Trees3
	var point_count : int = floori(points.size() / 3)
	trees.multimesh.instance_count = point_count
	trees_2.multimesh.instance_count = point_count
	trees_3.multimesh.instance_count = point_count
	var tree_array : Array[MultiMeshInstance3D] = [trees, trees_2, trees_3]	
	var progress : int = 0

	var indices : Array = range(0, points.size())
	indices.shuffle()

	for cycle : int in 3:
		for i in point_count:
			var point : Vector2 = points[indices.pop_back()]
			tree_array[cycle].multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY.rotated(Vector3.UP, randf_range(0, TAU)) * (randf_range(12, 15) - (6.0 * point.x / 25.0)), Vector3(point.x, 0, -point.y)))
		
		progress += point_count

	
	obstacles_placed.emit()

func spawn_block(x_coord : int, row : int) -> float:
	var block : Block = block_scene.instantiate()
	var height : float = Globals.RNG.randf_range(5, 15)
	
	block.initialize(height)
	block.position = Vector3(-30 + grid_cell_size.x * (x_coord + 0.5), y_pos, -grid_cell_size.y * (5 + row))
	#prints("Block height", height, "Block position", block.position)
	obstacle_grid[row * grid_size.x + x_coord] = ObstacleTypes.WALL
	add_child(block)
	
	return height

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		position.z += Globals.scroll_speed * delta
		if position.z >= -20 and !signal_sent:
			EventBus.tube_entered.emit()
			signal_sent = true
		if position.z >= 575 and !exit_signal_sent:
			EventBus.tube_end_reached.emit()
			exit_signal_sent = true
		if position.z >= 650:
			queue_free()

func _exit_tree() -> void:
	if thread.is_started():
		thread.wait_to_finish()



func generate_poisson_points(radius : float, _region_size : Vector2) -> PackedVector2Array:
	var poisson_cell_size : float = radius / sqrt(2.0)
	var region_size : Vector2 = _region_size

	var poisson_grid : PackedVector2Array = []
	var poisson_grid_size : Vector2i = Vector2i(ceili(region_size.x / poisson_cell_size), ceili(region_size.y / poisson_cell_size))
	if poisson_grid_size.x == 0:
		return PackedVector2Array([])
	poisson_grid.resize(poisson_grid_size.x * poisson_grid_size.y)
	
	var points : PackedVector2Array = []
	var spawn_points : PackedVector2Array = []
	spawn_points.append(region_size * 0.5)

	while spawn_points.size() > 0:
		var index : int = randi() % spawn_points.size()
		var spawn_center : Vector2 = spawn_points[index]
		var accepted : bool = false

		for _i in range(20):
			var angle : float = randf_range(0, TAU)
			var dir : Vector2 = Vector2.RIGHT.rotated(angle)
			var candidate : Vector2 = spawn_center + dir * randf_range(radius, radius * 2)
			if is_valid(candidate, region_size, poisson_cell_size, radius, poisson_grid, poisson_grid_size):
				points.append(candidate)
				spawn_points.append(candidate)
				poisson_grid[poisson_grid_size.x * floori(candidate.y / poisson_cell_size) + floori(candidate.x / poisson_cell_size)] = candidate
				accepted = true
				break
		if !accepted:
			spawn_points.remove_at(index)

	return points
	
func is_valid(candidate : Vector2, region_size : Vector2, poisson_cell_size : float, radius : float, poisson_grid : PackedVector2Array, poisson_grid_size : Vector2i) -> bool:
	if candidate.x >= 0 and candidate.x < region_size.x and candidate.y >=0 and candidate.y < region_size.y:
		var cell_x : int = floori(candidate.x / poisson_cell_size)
		var cell_y : int = floori(candidate.y / poisson_cell_size)
		var search_start_x = max(0, cell_x - 2)
		var search_start_y = max(0, cell_y - 2)
		var search_end_x = min(cell_x + 2, poisson_grid_size.x - 1)
		var search_end_y = min(cell_y + 2, poisson_grid_size.y - 1)
		
		for x in range(search_start_x, search_end_x + 1):
			for y in range(search_start_y, search_end_y + 1):
				if poisson_grid[poisson_grid_size.x * y + x]:
					var distance : float = candidate.distance_squared_to(poisson_grid[poisson_grid_size.x * y + x])
					if distance < radius * radius:
						return false
		return true
	return false