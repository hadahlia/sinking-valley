extends Node3D
class_name Player

@onready var label: Label = $Label #testing the stupid step timer

@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D

# COL RAYS <3
@onready var cast_forward: RayCast3D = $head/cast_forward
@onready var cast_behind: RayCast3D = $head/cast_behind
@onready var cast_right: RayCast3D = $head/cast_right
@onready var cast_left: RayCast3D = $head/cast_left


@onready var step_to: Node3D = $step_to
@onready var step_time: Timer = $step_to/step_time

@onready var turn_timer: Timer = $head/turn_timer

@export_node_path("GridMap") var grid_map


#i havent decided 
const MOVESPEED : float = 8.0 
const TURNSPEED : float = 6.0
const STEP_AMT : float = 2.0

var delta_time: float = 0.0

enum { FRONT , LEFT, BACK , RIGHT }
var direction_state = 0 # 0,1,2,3 

var turn_id : int = 0

#var lookdir :Vector3 = Vector3.ZERO
var wishdir : Vector3 = Vector3.ZERO
var dest_angle : float = 0.0

var can_step : bool = false
#var stepping : bool = false
var turning: bool = false

func _ready() -> void:
	step_time.connect("timeout", on_step_timeout)
	turn_timer.connect("timeout", on_camturn_timeout)
	can_step = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("turn_left"):
		turn_id += 1 if turn_id < 3 else 0
		dest_angle += 90.000
		turning = true
		turn_timer.start()
	if Input.is_action_just_pressed("turn_right"):
		turn_id -= 1 if turn_id > 0 else 3
		dest_angle -= 90.000
		turning = true
		turn_timer.start()
	
	#if !can_step: return
	if turning: return
	if event.is_action_pressed("forward"):
		direction_state = FRONT
		#if !check_collision(cast_forward):
		wishdir = Vector3.FORWARD.rotated(Vector3.UP, head.rotation.y)
	if event.is_action_pressed("backward"):
		direction_state = BACK
		#if !check_collision(cast_behind):
		wishdir = Vector3.BACK.rotated(Vector3.UP, head.rotation.y)
	if event.is_action_pressed("left"):
		direction_state = LEFT
		#if !check_collision(cast_left):
		wishdir = Vector3.LEFT.rotated(Vector3.UP, head.rotation.y)
	if event.is_action_pressed("right"):
		direction_state = RIGHT
		wishdir = Vector3.RIGHT.rotated(Vector3.UP, head.rotation.y)
	
	if event.is_action_released("movement"):
		wishdir = Vector3.ZERO
	
	if Input.is_action_just_pressed("interact"):
		interact_tile()


func _physics_process(delta: float) -> void:
	delta_time = delta
	label.text = "step timer" + str(step_time.time_left) + "\n turn timer: " + str(turn_timer.time_left)
	
	
	head.global_position.x = lerpf(head.global_position.x, step_to.global_position.x, MOVESPEED * delta_time)
	head.global_position.z = lerpf(head.global_position.z, step_to.global_position.z, MOVESPEED * delta_time)
	
	#if head.global_position.x - step_to.global_position.x < 0.01 and head.global_position.z - step_to.global_position.z < 0.1:
		#stepping = false
	
	handle_turn()
	step_forth()

func check_collision(ray: RayCast3D) -> bool:
	return ray.is_colliding()
	# access the 4 raycasts check if they collide with anything return a bool, uh test the bool before stepping. if false, bump animation? for the future xd


# perhaps this is unnecessary
func check_forward_tile_id():
	pass

func interact_tile():
	GlobalAudio.play_sound(GlobalAudio.SFX_INTERACT)

func handle_turn():
	if !turning or !can_step: return
	#if !can_step: return
	#can_step = false
	#
	#var elapsed : float = 0.0
	head.rotation.y = lerp_angle(head.rotation.y, deg_to_rad(dest_angle), TURNSPEED * delta_time)
	
	
	#if can_step:
	#step_delay()
	#can_step = true
	#elapsed += delta_time

func step_forth():
	if !can_step or turning: return
	
	var ray: RayCast3D
	match direction_state:
		FRONT:
			ray = cast_forward
		BACK:
			ray = cast_behind
		LEFT:
			ray = cast_left
		RIGHT:
			ray = cast_right
	if check_collision(ray): return
	
	step_to.global_position.x += wishdir.x * STEP_AMT
	step_to.global_position.z += wishdir.z * STEP_AMT
	step_to.global_position.x = round(step_to.global_position.x)
	step_to.global_position.z = round(step_to.global_position.z)

	#if step_cooldown.is_stopped():
	step_delay()
	#wishdir = Vector3.ZERO

# ya stupidest most overcomplated dungeon crawler ever look at my gorey code. trying to deal with issues like getting off-grid if i press multiple consecutive directions
#func unlock_step_timer():
	#if !can_step: return
	#step_cooldown.stop()
func step_delay():
	if !step_time.is_stopped(): return
	#can_step = false
	can_step = false
	#stepping = true
	#if can_step: return
	#if !can_step: return
	#if !can_step and step_time.is_stopped():
	step_time.start()

func on_step_timeout():
	can_step = true
	#step_cooldown.start()
	#step_forth()
	#turning = false
	#is_stepping = false

func on_camturn_timeout():
	turning = false
	match turn_id:
		0:
			#dest_angle = 0
			head.rotation.y = deg_to_rad(0)
		1:
			#dest_angle = 90
			head.rotation.y = deg_to_rad(90)
		2:
			#dest_angle = 180
			head.rotation.y = deg_to_rad(180)
		3:
			#dest_angle = -90
			head.rotation.y = deg_to_rad(-90)
