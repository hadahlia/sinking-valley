extends Node3D
 
@onready var board: GridMap = $GridMap
 
const GRID_SIZE : float = 4.0
 
const grid_y: float = 2.0
const grid_step : float = 4.0
 
var all_points = {}
var astar : AStar2D = AStar2D.new()
var cells : Array[Vector3i]
 
func _ready() -> void:
	generate_astar()
 
func generate_astar() -> void:
	astar.clear()
	cells = board.get_used_cells()
	#print(cells)
	for cell in cells:
		var ind = astar.get_available_point_id()
		
		astar.add_point(ind,  Vector2(cell.x, cell.z))
		all_points[vec_to_id(Vector2(cell.x, cell.z))] = ind
	
 
func connect_as_points() -> AStar2D:
	for c in cells:
		for x in [-1, 0, 1]:
			for z in [-1,0,1]:
				var v2 = Vector2(x, z)
				if v2 == Vector2.ZERO:
					continue
				if vec_to_id(v2 + Vector2(x, z)) in all_points:
					var ind1 = all_points[vec_to_id(Vector2(x, z))]
					var ind2 = all_points[vec_to_id(Vector2(x, z) + v2)]
					if !astar.are_points_connected(ind1, ind2,true):
						astar.connect_points(ind1, ind2, true)
	return astar
 
func get_as_path(start: Vector3, end: Vector3) -> PackedVector2Array:
	var start_xz := world_to_grid(start)
	var end_xz := world_to_grid(end)
	var gm_start = vec_to_id(start_xz)
	var gm_end = vec_to_id(end_xz)
	var start_id : int = 0
	var end_id : int = 0
	if gm_start in all_points:
		start_id = all_points[gm_start]
	else:
		start_id = astar.get_closest_point(start_xz)
	#print(start_id)
	if gm_end in all_points:
		end_id = all_points[gm_end]
	else:
		end_id = astar.get_closest_point(end_xz)
	#print(end_id)
	return astar.get_point_path(start_id, end_id)
 
func vec_to_id(world: Vector2) -> String:
	return str(int(round(world.x))) + "," + str(int(round(world.y)))

func world_to_grid(world: Vector3) -> Vector2:
	#print("world: x ", world.x, ", z ", world.z)
	var x: int = int(floor(world.x))
	var z: int = int(floor(world.z))
	x /= 4
	z /= 4
	#print("grid: x ", x, ", z ", z)
	return Vector2(x, z)
