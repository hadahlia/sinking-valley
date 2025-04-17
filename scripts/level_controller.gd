extends Node3D
class_name GameRule

#@export_node_path("Player") var player_ref
#@onready var player_scene: Player = $"../player_scene"
@onready var player_scene: Player = $player_scene

@onready var delay_music: Timer = $delay_music
@onready var gameturn_delay: Timer = $gameturn_delay


@onready var temple_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnTemple")
var from_temple_spawnpoint : Marker3D #unused, for now
@onready var island_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnIsland")

enum ELocations { ISLAND = 0, DUNGEON = 1}
var location = 0

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
	
	if mid == monster_count and gameturn_delay.is_stopped():
		
		gameturn_delay.start()
		#end_turn()

func end_turn() -> void:
	
	GameFlags.player_turn = !GameFlags.player_turn
	#print(GameFlags.player_turn)
	if !GameFlags.player_turn:
		get_monsters()
	else:
		GameFlags.turn_id += 1

func _ready() -> void:
	GameFlags.player_turn = true
	player_scene.moved.connect(end_turn)
	gameturn_delay.timeout.connect(end_turn)
	GameFlags.turn_id = 0
	#player_ref = get_tree().get_first_node_in_group("Player")
	#player_scene.ready.connect(check_location)
	check_location()

func check_location() -> void:
	match location:
		0:
			GlobalAudio.play_music(GlobalAudio.SEA_LOOP)
			spawn_entity(player_scene,island_spawnpoint)
		1:
			delay_music.timeout.connect(func() -> void: GlobalAudio.play_music(GlobalAudio.DUNGEON_THEME))
			delay_music.start()
			spawn_entity(player_scene,temple_spawnpoint)

func spawn_entity(entity_: Player, point: Marker3D) -> void:
	entity_.global_position = point.global_position
	#print("YAYYYYYY")
