extends Node3D
class_name GameRule

const island_level = preload("res://scenes/island_level.tscn")
const temple_level = preload("res://scenes/temple_level.tscn")

#@export_node_path("Player") var player_ref
#@onready var player_scene: Player = $"../player_scene"
@onready var player_scene: Player = $player_scene

@onready var delay_music: Timer = $delay_music
@onready var gameturn_delay: Timer = $gameturn_delay


@onready var temple_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnTemple")
var from_temple_spawnpoint : Marker3D #unused, for now
@onready var island_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnIsland")

@onready var amap = get_tree().get_first_node_in_group("AMap")

enum ELocations { ISLAND = 0, DUNGEON = 1}
var location : int = 1

# GameRule
#var turn_num : int = 0

#var player_turn: bool = true

func get_monsters() -> void:
	var monsters : Array[Node]= get_tree().get_nodes_in_group("EnemyRoot")
	var monster_count : int = monsters.size()
	var mid : int = 0
	for m in monsters:
		if m is EntityMonster:
			m.take_turn()
			mid += 1
	
	if mid == monster_count:
		
		gameturn_delay.start()
		#end_turn()

func end_turn() -> void:
	if !amap:
		amap = get_tree().get_first_node_in_group("AMap")
	amap.create_path_points()
	#amap.generate_astar()
	GameFlags.player_turn = !GameFlags.player_turn
	#print(GameFlags.player_turn)
	if amap and !GameFlags.player_turn:
		
		get_monsters()
	else:
		GameFlags.turn_id += 1

func _ready() -> void:
	#location = GameFlags.player_location
	GameFlags.has_shovel = false
	GameFlags.player_turn = true
	player_scene.moved.connect(end_turn)
	player_scene.door_emit.connect(switch_map)
	gameturn_delay.timeout.connect(end_turn)
	GameFlags.turn_id = 0
	#player_ref = get_tree().get_first_node_in_group("Player")
	#player_scene.ready.connect(check_location)
	check_location()

func switch_map()->void:
	var old := get_tree().get_first_node_in_group("Levels")
	if old:
		old.queue_free()
		GlobalAudio.stop_music()
	if location == 0:
		location = 1
		get_tree().create_timer(1.0).timeout.connect(func()->void:
			instance_map(temple_level)
			delay_music.timeout.connect(func() -> void: GlobalAudio.play_music(GlobalAudio.DUNGEON_THEME))
			delay_music.start()
			)
	else:
		location = 0
		get_tree().create_timer(1.0).timeout.connect(func()->void:
			instance_map(island_level)
			
			GlobalAudio.play_music(GlobalAudio.SEA_LOOP)
			)
	
	

func instance_map(level) -> void:
	var c = level.instantiate()
	add_child(c)

func check_location() -> void:
	match location:
		0:
			GlobalAudio.play_music(GlobalAudio.SEA_LOOP)
			spawn_entity(player_scene,island_spawnpoint)
			instance_map(island_level)
		1:
			delay_music.timeout.connect(func() -> void: GlobalAudio.play_music(GlobalAudio.DUNGEON_THEME))
			delay_music.start()
			spawn_entity(player_scene,temple_spawnpoint)
			instance_map(temple_level)

func spawn_entity(entity_: Player, point: Marker3D) -> void:
	entity_.global_position = point.global_position
	#print("YAYYYYYY")
