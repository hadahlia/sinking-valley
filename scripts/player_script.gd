extends Node3D
class_name Player

signal moved
signal door_emit
signal ending_emit

@onready var label: Label = $Label #testing the stupid step timer

@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D

# COL RAYS <3
@onready var cast_forward: RayCast3D = $head/cast_forward
@onready var cast_behind: RayCast3D = $head/cast_behind
@onready var cast_right: RayCast3D = $head/cast_right
@onready var cast_left: RayCast3D = $head/cast_left

# i dont feel like manually putting invisible collision around the island, so ill make sure theres a floor
@onready var cast_ground: RayCast3D = $step_to/cast_ground


@onready var step_to: Node3D = $step_to
@onready var step_time: Timer = $step_to/step_time

@onready var turn_timer: Timer = $head/turn_timer
@onready var sound_timer: Timer = $head/sound_timer

#@export_node_path("GridMap") var grid_map

@onready var hud: PlayerUI = $p_screen

@onready var inventory: Control = $p_screen/Inventory

@export var stats : GameOver
#@export_node_path("PlayerUI") var hud

#i havent decided 
const MOVESPEED : float = 6.0 
const TURNSPEED : float = 8.0
const STEP_AMT : float = 4.0

var delta_time: float = 0.0

enum { FRONT , LEFT, BACK , RIGHT }
var direction_state = 0 # 0,1,2,3 

#var turn_id : int = 0

#var lookdir :Vector3 = Vector3.ZERO
var wishdir : Vector3 = Vector3.ZERO
var dest_angle : float = 0.0

var can_step : bool = false
var stepping : bool = false
var turning: bool = false
var can_attack:bool = true

var took_turn : bool = false

var ray: RayCast3D
var prev_pos : Vector3 
var grounded : bool = true

func _ready() -> void:
	step_time.connect("timeout", on_step_timeout)
	turn_timer.connect("timeout", on_camturn_timeout)
	can_step = true

func _input(event: InputEvent) -> void:
	#if !GameFlags.player_turn: 
		#wishdir = Vector3.ZERO
		#stepping = false
		#return
	if Input.is_action_just_pressed("turn_left"):
		#turn_id += 1 if turn_id < 3 else 0
		dest_angle += 90.000
		stepping = false
		turning = true
		turn_timer.start()
	if Input.is_action_just_pressed("turn_right"):
		#turn_id -= 1 if turn_id > 0 else 3
		dest_angle -= 90.000
		stepping = false
		turning = true
		turn_timer.start()
	
	#if !can_step: return
	if turning: return
	if event.is_action_pressed("forward"):
		direction_state = FRONT
		#if !check_collision(cast_forward):
		wishdir = Vector3.FORWARD.rotated(Vector3.UP, head.rotation.y)
		stepping = true
	if event.is_action_pressed("backward"):
		direction_state = BACK
		#if !check_collision(cast_behind):
		wishdir = Vector3.BACK.rotated(Vector3.UP, head.rotation.y)
		stepping = true
	if event.is_action_pressed("left"):
		direction_state = LEFT
		#if !check_collision(cast_left):
		wishdir = Vector3.LEFT.rotated(Vector3.UP, head.rotation.y)
		stepping = true
	if event.is_action_pressed("right"):
		direction_state = RIGHT
		wishdir = Vector3.RIGHT.rotated(Vector3.UP, head.rotation.y)
		stepping = true
	if event.is_action_released("movement"):
		wishdir = Vector3.ZERO
		stepping = false
		#var t : Timer = 
		#t.timeout.connect( func() -> void: stepping)
	
	
	if Input.is_action_just_pressed("interact"):
		interact_tile()
	
	if Input.is_action_just_pressed("attack"):
		attack_tile()
	
	if Input.is_action_just_pressed("magic chalice"):
		print("welp. this doesnt do anything yet")


func _physics_process(delta: float) -> void:
	delta_time = delta
	
	#label.text = "step timer" + str(step_time.time_left) + "\n turn timer: " + str(turn_timer.time_left)
	
	head.global_position.x = lerpf(head.global_position.x, step_to.global_position.x, MOVESPEED * delta_time)
	head.global_position.z = lerpf(head.global_position.z, step_to.global_position.z, MOVESPEED * delta_time)
	
	if !GameFlags.player_turn: return
	
	
	handle_turn()
	step_forth()

#func check_collision(ray: RayCast3D) -> bool:
	#return ray.is_colliding()

func attack_tile():
	
	print("attack!!")
	if !cast_forward.is_colliding(): 
		end_turn()
		return
	var col = cast_forward.get_collider()
	if col.is_in_group("EnemyMonster"):
		var dmg :int = col.get_parent().stats_resource.TakeDamage(8)
		var monster_name := str(col.get_parent().stats_resource.unitName)
		hud.send_event_message("You did " + str(dmg) + " damage to " + monster_name)
		print(col.get_parent().stats_resource.currentHP)
		col.get_parent().assess_life()
	end_turn()
		#took_turn = true


func interact_tile():
	if !cast_forward.is_colliding(): 
		GlobalAudio.play_sound(GlobalAudio.SFX_INTERACT_DENY)
		return
	var col = cast_forward.get_collider()
	if col.is_in_group("Doorway"):
		#if col.is_door:
		door_emit.emit()
	elif col.is_in_group("Ending"):
		#ending_emit.emit()
		GlobalAudio.stop_music()
		SceneManager.ChangeScene(SceneManager.ENDING_SCENE)
	elif col.is_in_group("ItemShovel"):
		print("oh man i sure wish i could grab the shovel")
		col.get_parent().queue_free()
		#col.get_parent().trigger()
		#col.get_parent().stats_resource.TakeDamage(2)
		#print(col.get_parent().stats_resource.currentHP)
		#col.get_parent().assess_life()

func end_turn() -> void:
	moved.emit()
	#get_tree().create_timer(1.0).timeout.connect(func()->void:
	took_turn = false


func handle_turn():
	if !turning or !can_step: return
	
	head.rotation.y = lerp_angle(head.rotation.y, deg_to_rad(dest_angle), TURNSPEED * delta_time)
	

func step_forth():
	
	if !cast_ground.is_colliding() and prev_pos != Vector3.ZERO:
		step_to.global_position = prev_pos
		took_turn = false
	if took_turn:
		end_turn()
		return
	
	if !can_step or turning or !stepping: return
	#if cast_ground.is_colliding():
		#moved.emit()
	
	match direction_state:
		FRONT:
			ray = cast_forward
		BACK:
			ray = cast_behind
		LEFT:
			ray = cast_left
		RIGHT:
			ray = cast_right
	
	prev_pos = step_to.global_position
	
	if ray.is_colliding(): 
		if sound_timer.is_stopped():
			GlobalAudio.play_sound(GlobalAudio.SFX_INTERACT_DENY)
			sound_timer.start()
		return
	
	step_to.global_position.x += wishdir.x * STEP_AMT
	step_to.global_position.z += wishdir.z * STEP_AMT
	step_to.global_position.x = round(step_to.global_position.x)
	step_to.global_position.z = round(step_to.global_position.z)
	
	#print("player step: ", step_to.global_position)
	step_delay()


func step_delay():
	if !step_time.is_stopped(): return
	can_step = false
	took_turn = true
	
	step_time.start()
	#if cast_ground.is_colliding():
		#took_turn = true

func on_step_timeout():
	can_step = true

func on_camturn_timeout():
	
	#match turn_id:
		#0:
			##dest_angle = 0
			#head.rotation.y = deg_to_rad(0)
		#1:
			##dest_angle = 90
			#head.rotation.y = deg_to_rad(90)
		#2:
			##dest_angle = -180
			#head.rotation.y = deg_to_rad(180)
		#3:
			##dest_angle = -90
			#head.rotation.y = deg_to_rad(-90)
	turning = false
