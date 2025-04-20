extends Node3D
class_name GameRule

const island_level = preload("res://scenes/island_level.tscn")
const temple_level = preload("res://scenes/temple_level.tscn")

#@export_node_path("Player") var player_ref
#@onready var player_scene: Player = $"../player_scene"
@onready var player_scene: Player = $player_scene

@onready var delay_music: Timer = $delay_music
@onready var gameturn_delay: Timer = $gameturn_delay

@onready var fullrect: ColorRect = $"../CanvasLayer/ColorRect"


@onready var temple_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnTemple")
@onready var return_spawnpoint: Marker3D = get_tree().get_first_node_in_group("PlayerSpawnRetIsland")

@onready var island_spawnpoint : Marker3D = get_tree().get_first_node_in_group("PlayerSpawnIsland")

@onready var amap = get_tree().get_first_node_in_group("AMap")

enum ELocations { ISLAND = 0, DUNGEON = 1, ISLAND_RET = 2}
var location : int = 0

# GameRule
#var turn_num : int = 0

#var player_turn: bool = true

func get_monsters() -> void:
	var monsters : Array[Node]= get_tree().get_nodes_in_group("EnemyRoot")
	var monster_count : int = monsters.size()
	var mid : int = 0
	for m in monsters:
		#if m is EntityMonster:
		#get_tree().create_timer(0.05).timeout.connect(func()->void:
		m.take_turn()
			#)
			
		mid += 1
	
	if mid == monster_count:
		
		gameturn_delay.start()
		#end_turn()

func end_turn() -> void:
	if !amap:
		amap = get_tree().get_first_node_in_group("AMap")
		get_tree().create_timer(0.05).timeout.connect(func()->void:
			amap.create_path_points()
			)
	
	#amap.generate_astar()
		#print(GameFlags.player_turn)
	
	GameFlags.player_turn = !GameFlags.player_turn
	
	if !GameFlags.player_turn:
		
		#get_tree().create_timer(0.05).timeout.connect(func()->void:
		get_monsters()
			#)
		
	else:
		GameFlags.turn_id += 1
	
	#gameturn_delay.start()

func turn_timeout()->void:
	pass
	
	

func _ready() -> void:
	#SceneTransition.fade_in(2.0, Color.BLACK)
	#location = GameFlags.player_location
	GameFlags.has_shovel = false
	GameFlags.player_turn = true
	player_scene.moved.connect(end_turn)
	player_scene.door_emit.connect(switch_map)
	gameturn_delay.timeout.connect(end_turn)
	GameFlags.turn_id = 0
	#player_ref = get_tree().get_first_node_in_group("Player")
	#player_scene.ready.connect(check_location)
	#amap.tree_entered.connect(func()->void:
		#amap.create_path_points()
		#)
	check_location()

func switch_map()->void:
	fullrect.show()
	var old := get_tree().get_first_node_in_group("Levels")
	if old:
		
		GlobalAudio.stop_music()
		old.queue_free()
		location += 1
		if location > 2:
			location = 1
	
	#if location == 1:
		##location = 1
		#get_tree().create_timer(1.0).timeout.connect(func()->void:
			#instance_map(temple_level)
			#delay_music.timeout.connect(func() -> void: GlobalAudio.play_music(GlobalAudio.DUNGEON_THEME))
			#delay_music.start()
			#)
	#if location == 2:
		##location = 2
		#get_tree().create_timer(1.0).timeout.connect(func()->void:
			#instance_map(island_level)
			#
			#GlobalAudio.play_music(GlobalAudio.SEA_LOOP)
			#)
	#elif location == 0:
		##location = 0
		#get_tree().create_timer(1.0).timeout.connect(func()->void:
			#instance_map(island_level)
			#
			#GlobalAudio.play_music(GlobalAudio.SEA_LOOP)
			#)
	get_tree().create_timer(0.5).timeout.connect(func()->void:
		
		check_location()
		)
	

func instance_map(level) -> void:
	var c = level.instantiate()
	add_child(c)

func check_location() -> void:
	
	match location:
		0:
			GlobalAudio.play_music(GlobalAudio.SEA_LOOP)
			spawn_entity(player_scene,island_spawnpoint)
			get_tree().create_timer(0.5).timeout.connect(func()->void:
				instance_map(island_level)
				GameFlags.player_turn = true
				
				SceneTransition.fade_in(3.0, Color.BLACK)
				get_tree().create_timer(1.0).timeout.connect(func()->void:
					fullrect.hide()
					)
				)
		1:
			delay_music.timeout.connect(func() -> void: GlobalAudio.play_music(GlobalAudio.DUNGEON_THEME))
			delay_music.start()
			spawn_entity(player_scene,temple_spawnpoint)
			get_tree().create_timer(0.5).timeout.connect(func()->void:
				instance_map(temple_level)
				GameFlags.player_turn = true
				
				SceneTransition.fade_in(3.0, Color.BLACK)
				get_tree().create_timer(1.0).timeout.connect(func()->void:
					fullrect.hide()
					)
				)
		2:
			GlobalAudio.play_music(GlobalAudio.SEA_LOOP)
			spawn_entity(player_scene,return_spawnpoint)
			get_tree().create_timer(0.5).timeout.connect(func()->void:
				instance_map(island_level)
				GameFlags.player_turn = true
				
				SceneTransition.fade_in(3.0, Color.BLACK)
				get_tree().create_timer(1.0).timeout.connect(func()->void:
					fullrect.hide()
					)
				)
	#print(location)



func spawn_entity(entity_: Player, point: Marker3D) -> void:
	#var p = get_tree().get_first_node_in_group("Player")
	entity_.reposition_me(point.global_position)
	#entity_.global_position.x = point.global_position.x
	#entity_.global_position.z = point.global_position.z
	#print(entity_.global_position)
	#print("YAYYYYYY")
