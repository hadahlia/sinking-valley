extends Node3D

#@export_node_path("Player") var player_ref
#@onready var player_scene: Player = $"../player_scene"
@onready var player_scene: Player = $player_scene
@onready var delay_music: Timer = $delay_music


@onready var temple_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnTemple")
var from_temple_spawnpoint : Marker3D #unused, for now
@onready var island_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnIsland")

enum ELocations { ISLAND = 0, DUNGEON = 1}
var location = 0

func _ready() -> void:
	
	#player_ref = get_tree().get_first_node_in_group("Player")
	#player_scene.ready.connect(check_location)
	check_location()

func check_location() -> void:
	match location:
		0:
			spawn_entity(player_scene,island_spawnpoint)
		1:
			delay_music.timeout.connect(func() -> void: GlobalAudio.play_music(GlobalAudio.DUNGEON_THEME))
			delay_music.start()
			spawn_entity(player_scene,temple_spawnpoint)

func spawn_entity(entity_: Player, point: Marker3D) -> void:
	entity_.global_position = point.global_position
	#print("YAYYYYYY")
