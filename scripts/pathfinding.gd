extends Node3D

@onready var board: GridMap = $GridMap

const GRID_SIZE : int = 4
const DIRECTIONS := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

const grid_y: float = 2.0
const grid_step : float = 4.0

#var all_points = {}
@onready var astar : AStar2D = AStar2D.new()

var units_array := []
var cells_array :Array= []

func _ready() -> void:

	create_path_points()
	add_units()

func vec_to_id(world: Vector2) -> String:
	return str(int(round(world.x))) + "," + str(int(round(world.y)))

func world_to_grid(world: Vector3) -> Vector2:

	var x: int = int(round(world.x))
	var z: int = int(round(world.z))
	x /= 4
	z /= 4

	return Vector2(x, z)


func id_to_vec(id: int) -> Vector2:
	var z: int = id / GRID_SIZE
	var x: int = id % GRID_SIZE
	
	return Vector2(x, z)

# heartbeast's impl

func get_cell_positions() -> Array:
	var cells := board.get_used_cells()
	var cell_positions := []
	for cell in cells:
		#var cell_pos := board.global_position + board.map_to_local(cell)
		cell_positions.append(cell)
	return cell_positions

func create_path_points() -> void:
	astar.clear()
	if cells_array.is_empty():
		cells_array = board.get_used_cells()
	#print(used_cell_pos)
	for cell in cells_array:
		var ind :int = astar.get_available_point_id()
		astar.add_point(ind, Vector2(cell.x, cell.z))
	
	for cell in cells_array:
		connect_cardinals(cell)

func add_units() -> void:
	var units := get_tree().get_nodes_in_group("EnemyMonster")
	for unit in units:
		units_array.append(unit)
		if !unit.is_connected("tree_exiting", remove_unit):
			var _error := unit.connect("tree_exiting", remove_unit.bind(unit))
			if _error != 0: push_error(str(unit) + ": failed connect func")

func remove_unit(unit: Object) -> void:
	units_array.erase(unit)

func position_has_unit(unit_pos: Vector2, ignore_position = null) -> bool:
	if unit_pos == ignore_position: return false
	for u in units_array:
		if Vector2(u.global_position.x,u.global_position.z) == unit_pos: return true
	return false

func get_astar_avoid_units(start: Vector3, end: Vector3) -> PackedVector2Array:
	#create_path_points()
	var s_grid := world_to_grid(start)
	var e_grid := world_to_grid(end)
	#var s_ : Vector2 = Vector2(s_grid.x, s_grid.z)
	#var e_ := Vector2(e_grid.x, e_grid.z)
	#print(start, s_grid)
	#print(end, e_grid)
	var s_id : int = astar.get_closest_point(s_grid)
	var e_id : int = astar.get_closest_point(e_grid)
	set_unit_points_disabled(true)
	var astar_path := astar.get_point_path(s_id, e_id, false)
	set_unit_points_disabled(false)
	#print("get astar avoid units!")
	return astar_path
	

func stop_path_at_unit(potential_path: Array) -> Array:
	for i in range(1, potential_path.size()):
		var point : Vector2 = potential_path[i]
		if position_has_unit(point):
			potential_path.resize(i)
			break
	return potential_path

func set_unit_points_disabled(value: bool) -> void:
	for unit in units_array:
		astar.set_point_disabled(astar.get_closest_point(world_to_grid(unit.global_position)),value)

func get_point(point: Vector3) -> int:
	var x: int = int(floor(point.x))
	var z: int = int(floor(point.z))
	
	return szudzik_pair_improved(x, z)

func szudzik_pair_improved(x:int, y:int) -> int:
	var a: int
	var b: int
	if x >= 0:
		a = x * 2
	else: 
		a = (x * -2) - 1
	if y >= 0: 
		b = y * 2
	else: 
		b = (y * -2) - 1	
	var c = szudzik_pair(a,b)
	if a >= 0 and b < 0 or b >= 0 and a < 0:
		return -c - 1
	return c


func szudzik_pair(a:int, b:int) -> int:
	if a >= b: 
		return (a * a) + a + b
	else: 
		return (b * b) + a	

func connect_cardinals(point_pos: Vector3) -> void:
	var point_v2 := Vector2(point_pos.x, point_pos.z)
	var center := astar.get_closest_point(point_v2)
	var dirs := DIRECTIONS
	
	for dir in dirs:
		var cardinal_point := astar.get_closest_point(point_v2 + dir)
		if cardinal_point != center and astar.has_point(cardinal_point):
			astar.connect_points(center, cardinal_point, true)
