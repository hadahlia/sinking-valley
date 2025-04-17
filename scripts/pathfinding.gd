extends Node3D

@onready var board: GridMap = $GridMap

const GRID_SIZE : int = 4
const DIRECTIONS := [Vector3.RIGHT * GRID_SIZE, Vector3.FORWARD * GRID_SIZE, Vector3.LEFT * GRID_SIZE, Vector3.BACK * GRID_SIZE]

const grid_y: float = 2.0
const grid_step : float = 4.0

var all_points = {}
var astar : AStar2D = AStar2D.new()
#var cells : Array[Vector3i]

var units_array := []

func _ready() -> void:
	#generate_astar()
	create_path_points()
	add_units()



func generate_astar() -> void:
	#cells = board.get_used_cells()
	#print(cells)
	
	for cell in get_cell_positions():
		var ind = astar.get_available_point_id()
		
		astar.add_point(ind,  Vector2(cell.x , cell.z))
		all_points[vec_to_id(Vector2(cell.x, cell.z))] = ind
	

func connect_as_points() -> AStar2D:
	for c in get_cell_positions():
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
	var start_grid = world_to_grid(start)
	var end_grid = world_to_grid(end)
	
	var start_xz := Vector2(start_grid.x,start_grid.z)
	var end_xz := Vector2(end_grid.x,end_grid.z)
	
	var gm_start = vec_to_id(start_xz)
	var gm_end = vec_to_id(end_xz)
	
	var start_id : int = 0
	var end_id : int = 0
	
	if gm_start in all_points:
		start_id = all_points[gm_start]
		print(start_id)
	else:
		start_id = astar.get_closest_point(start_xz)
	
	if gm_end in all_points:
		end_id = all_points[gm_end]
		print(end_id)
	else:
		end_id = astar.get_closest_point(end_xz)
	
	
	return astar.get_point_path(start_id, end_id)

func vec_to_id(world: Vector2) -> String:
	return str(int(round(world.x))) + "," + str(int(round(world.y)))

func world_to_grid(world: Vector3) -> Vector3i:
	
	var x: int = int(round(world.x))
	var z: int = int(round(world.z))
	x /= 4
	z /= 4
	return Vector3(x, 1, z)

func id_to_vec(id: int) -> Vector2:
	var z: int = id / GRID_SIZE
	var x: int = id % GRID_SIZE
	
	return Vector2(x, z)

# heartbeast's impl

func get_cell_positions() -> Array:
	var cells := board.get_used_cells()
	var cell_positions := []
	for cell in cells:
		var cell_pos := board.global_position + board.map_to_local(cell)
		cell_positions.append(cell_pos)
	return cell_positions

func create_path_points() -> void:
	astar.clear()
	var used_cell_pos = get_cell_positions()
	
	for cell in used_cell_pos:
		#var ind := astar.get_available_point_id()
		astar.add_point(get_point(cell), Vector2(cell.x, cell.z))
	
	for cell in used_cell_pos:
		connect_cardinals(cell)
		
	print("done")
		#for x in [-4, 0, 4]:
			#for z in [-4,0,4]:
				#var v2 = Vector2(x, z)
				#if v2 == Vector2.ZERO:
					#continue
				#if vec_to_id(v2 + Vector2(x, z)) in all_points:
					#var ind1 = all_points[vec_to_id(Vector2(x, z))]
					#var ind2 = all_points[vec_to_id(Vector2(x, z) + v2)]
					#if !astar.are_points_connected(ind1, ind2,true):
						#astar.connect_points(ind1, ind2, true)
	

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

func get_astar_avoid_units(start: Vector3, end: Vector3) -> Array:
	set_unit_points_disabled(true)
	var astar_path := astar.get_point_path(get_point(start), get_point(end))
	set_unit_points_disabled(false)
	return astar_path
	print("get astar avoid units!")

func stop_path_at_unit(potential_path: Array) -> Array:
	for i in range(1, potential_path.size()):
		var point : Vector2 = potential_path[i]
		if position_has_unit(point):
			potential_path.resize(i)
			break
	return potential_path

func set_unit_points_disabled(value: bool) -> void:
	for unit in units_array:
		astar.set_point_disabled(get_point(unit.global_position),value)

func get_point(point: Vector3) -> int:
	var x: int = int(point.x)
	var z: int = int(point.z)
	
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

func has_point(point) -> bool:
	var point_id := get_point(point)
	return astar.has_point(point_id)

func connect_cardinals(point_pos: Vector3) -> void:
	var center := get_point(point_pos)
	var dirs := DIRECTIONS
	
	for dir in dirs:
		var cardinal_point := get_point(point_pos + board.map_to_local(dir))
		if cardinal_point != center and astar.has_point(cardinal_point):
			astar.connect_points(center, cardinal_point, true)



# AN ITCH TUTORIAL
func occupy_astar_cell(global_pos: Vector3) -> void:
	var vcell := board.local_to_map(global_pos)

#func get_astar_path(start: Vector3, end: Vector3) -> Array:
	#var astar_path := astar.get_point_path(world_to_grid(start))

#func _add_points(cells) -> void:
	#for cell in cells:
		#print(cell)
		##var ind = astar.get_available_point_id()
		##print(ind)
		#for x in cell:
			#for z in cell:
				#var next_point = Vector3(cell.x,cell.y,cell.z) + Vector3(x * grid_step,0, z * grid_step)
				#_add_point(next_point)
		##astar.add_point(ind,board.)
		#
		##all_points[world_to_astar(cell)] = ind

#func _add_point(point: Vector3):
	#point.y = grid_y
	#
	#var id = astar.get_available_point_id()
	#
	#astar.add_point(id, point)
	#all_points[world_to_astar(point)] = id
	
	#print(all_points)

#func _connect_points(ast: AStar3D) -> AStar3D:
	#for p in all_points:
		#var pos_str = p.split(",")
		#var world_pos = Vector3(float(pos_str[0]), float(pos_str[1]), float(pos_str[2]))
		#var adj_points: = _get_adjacent_points(world_pos)
		#var cid = all_points[p]
		#for nid in adj_points:
			#if !ast.are_points_connected(cid, nid):
				#ast.connect_points(cid, nid)
	#return ast
				#print(cid)
		#for x in [-1, 0, 1]:
			#for y in [-1, 0, 1]:
				#for z in [-1, 0, 1]:
					#var v3 = Vector3(x, y, z)
					#if v3 == Vector3(0,0,0):
						#continue
					#if world_to_astar(v3 + cell) in all_points:
						#var ind1 = all_points[world_to_astar(cell)]
						#var ind2 = all_points[world_to_astar(cell + v3)]
						#if !astar.are_points_connected(ind1, ind2):
							#astar.connect_points(ind1,ind2, true)

#func v3_to_index(v3) -> String:
	#
	#return str(int(round(v3.x))) + "," + str(int(round(v3.y))) + "," + str(int(round(v3.z)))
#func _get_adjacent_points(world_point: Vector3) -> Array:
	#var adj_points = []
	#var search_coord = [-grid_step, 0, grid_step]
	#for x in search_coord:
		#for y in search_coord:
			#for z in search_coord:
				#var search_offset = Vector3(x,0,z)
				#if search_offset == Vector3.ZERO:
					#continue
				##var potential_neighbor = world_to_astar(world_point + search_offset)
				##if all_points.has(potential_neighbor):
					##adj_points.append(all_points[potential_neighbor])
	#return adj_points

#func generate_path(ast: AStar3D) -> AStar3D:
	#generate_astar()
	
#func get_astar() -> AStar3D:
	#return astar

#func find_path(ast: AStar3D,from: Vector3, to: Vector3) -> Array:
	#var asta :AStar3D= _connect_points(ast)
	#var start_id = asta.get_closest_point(from)
	##print("start id: ", start_id)
	#var end_id = asta.get_closest_point(to)
	##print("end id: ", end_id)
	#return asta.get_point_path(start_id, end_id)



#func id_to_vec(id: int, size: Vector3) -> Vector3:
	#pass
	#var s:Vector3 = 

func vec_to_3i(vec: Vector3) -> Vector3i:
	return Vector3i(int(vec.x), int(vec.y), int(vec.z))

#func 3i_to_vec(3i: Vector3i) -> Vector3:

#func dimension_size(size: Vector3) -> Vector3:
	#return Vector3(1, int)

#func make_path(start, end) -> PackedVector3Array:
	#var gm_start := world_to_astar(board.map_to_local(start) )
	#var gm_end := world_to_astar(board.map_to_local(end))
	#var start_id : int =0
	#var end_id : int = 0
	#if gm_start in all_points:
		#start_id = all_points[gm_start]
	#else:
		#start_id = astar.get_closest_point(start)
	#
	#if gm_end in all_points:
		#end_id = all_points[gm_end]
	#else:
		#end_id = astar.get_closest_point(end)
	#
	#return astar.get_point_path(start_id, end_id)
