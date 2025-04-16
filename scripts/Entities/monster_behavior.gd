extends Node3D
class_name EntityMonster

@onready var body: Node3D = $body
@onready var step_to: Node3D = $step_to

#@onready var sprite_: Sprite3D = $Sprite3D
@onready var sprite_: Sprite3D = $body/Sprite3D
@onready var collision_shape_3d: CollisionShape3D = $step_to/CollisionShape3D


@onready var ground: RayCast3D = $step_to/ground
@onready var right: RayCast3D = $step_to/right
@onready var left: RayCast3D = $step_to/left
@onready var forward: RayCast3D = $step_to/forward
@onready var behind: RayCast3D = $step_to/behind


@export var stats_resource : Monster

const STEP_SIZE : float = 4.0
const LERP_SPEED : float = 4.0

var has_moved : bool = false

# AI Stuff
enum { WANDERING, CHASING, RETREATING }
var intention = WANDERING

var d : Vector3 = Vector3.ZERO
var prev_pos : Vector3

func _ready() -> void:
	#stats_resource.TakeDamage()
	set_sprite(stats_resource.icon)

func _physics_process(delta: float) -> void:
	
	body.global_position = lerp(body.global_position, step_to.global_position, LERP_SPEED * delta)
	if GameFlags.player_turn: return
	if !ground.is_colliding() and prev_pos != Vector3.ZERO:
		#print("correctingggg")
		step_to.global_position = prev_pos
	
	# logic for what the monster would like to do!!!!!

func take_turn():
	match intention:
		WANDERING:
			var ri : int = randi() % 5
			var cast : RayCast3D
			#var d: Vector3
			match ri:
				0:
					d = Vector3.FORWARD
					cast = forward
				1:
					d = Vector3.BACK
					cast = behind
				2:
					d = Vector3.LEFT
					cast = left
				3:
					d = Vector3.RIGHT
					cast = right
				4:
					d = Vector3.ZERO
					cast = ground
			check_move(ri, d, cast)
			
			#print(ri)
			take_step(d)

func check_move(ri : int, dir: Vector3, cast: RayCast3D) -> void:
	var c : RayCast3D
	
	if cast.is_colliding() and ri != 4:
		for i in range(20):
			ri += 1 if ri < 4 else ri - 1
			match ri:
				0:
					d = Vector3.FORWARD
					c = forward
				1:
					d = Vector3.BACK
					c = behind
				2:
					d = Vector3.LEFT
					c = left
				3:
					d = Vector3.RIGHT
					c= right
				4:
					d = Vector3.ZERO
					break
			if !c.is_colliding():
				break
			
		#print("collision! new ri")


func take_step(dir: Vector3):
	
	prev_pos = step_to.global_position
	
	step_to.global_position.x += dir.x * STEP_SIZE
	step_to.global_position.z += dir.z * STEP_SIZE
	step_to.global_position.x = round(step_to.global_position.x)
	step_to.global_position.z = round(step_to.global_position.z)
	
	

func assess_life() -> void:
	if !stats_resource.isDead: return
	die()
	#print("nah still alive")

func set_sprite(new_sprite: Texture2D) -> void:
	sprite_.texture = new_sprite

func die() -> void:
	self.visible = !self.visible
	collision_shape_3d.disabled = true
