extends Node3D
class_name MovingHoleObstacle

@export var block_scene : PackedScene

var grid : Dictionary[Vector2i, MeshInstance3D] = {}

var grid_size : Vector2i = Vector2i(6, 4)

var directions : Array[Vector2i] = [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]

var gap : Vector2i

const SQRT_3 = sqrt(3)

func _ready() -> void:
	fill_grid()
	gap = Vector2i(randi_range(0, grid_size.x - 1), randi_range(0, grid_size.y - 1))

	grid[gap].queue_free()
	grid[gap] = null

	$Timer.start()


func fill_grid():
	for y in grid_size.y:
		for x in grid_size.x:
			var block : MeshInstance3D = block_scene.instantiate()

			block.position = Vector3((x + 0.5) * 10, (y + 0.5) * 5, 0)

			grid[Vector2i(x, y)] = block

			$MovingParts.add_child(block)


func move():
	var neighbours : Array[Vector2i] = get_neighbours(gap)
	var neighbour : Vector2i = neighbours.pick_random()
	var move_from : Vector2i = gap + neighbour
	
	var tw : Tween = create_tween()
	var target_pos : Vector3 = grid[move_from].position - Vector3(neighbour.x * 10, neighbour.y * 5, 0)
	tw.tween_property(grid[move_from], "position", target_pos, 2.0)

	tw.finished.connect(func():
		grid[gap] = grid[move_from]
		grid[gap].position = target_pos
		grid[move_from] = null
		gap = move_from
		$Timer.start()
		
	)

	

func get_neighbours(coords : Vector2i) -> Array[Vector2i]:
	var neighbours : Array[Vector2i] = []

	for direction : Vector2i in directions:
		var candidate : Vector2i = coords + direction
		if candidate.x >=0 and candidate.x < grid_size.x and candidate.y >= 0 and candidate.y < grid_size.y:
			neighbours.append(direction)

	return neighbours

func _on_timer_timeout() -> void:
	move()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if global_position.z > 0:
		queue_free()
