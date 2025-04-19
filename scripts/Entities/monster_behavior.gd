extends Node3D
class_name EntityMonster

@onready var body: Node3D = $body
#@onready var step_to: Node3D = $step_to
@onready var step_to: CharacterBody3D = %step_to

@onready var sprite_: Sprite3D = $body/Sprite3D
@onready var collision_shape_3d: CollisionShape3D = $step_to/CollisionShape3D

@onready var ground: RayCast3D = $step_to/ground
@onready var right: RayCast3D = $step_to/right
@onready var left: RayCast3D = $step_to/left
@onready var forward: RayCast3D = $step_to/forward
@onready var behind: RayCast3D = $step_to/behind


const ATTACK_INDICA = preload("res://scenes/attack_indicator.tscn")

@export var stats_resource : Monster

const STEP_SIZE : float = 4.0
const LERP_SPEED : float = 4.0

var has_moved : bool = false

# state Stuff
enum { WANDERING, CHASING, RETREATING }
var intention = CHASING

var d : Vector3 = Vector3.ZERO
var prev_pos : Vector3

# pathing stuff
var path : Array = []
var path_id : int = 0
#var personal_astar := AStar2D.new()

@onready var amap = get_tree().get_first_node_in_group("AMap")
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")

var attack_queued : bool = false
var attack_position : Vector3

func _ready() -> void:
	#stats_resource.TakeDamage()
	set_sprite(stats_resource.icon)

func _physics_process(delta: float) -> void:
	
	body.global_position = lerp(body.global_position, step_to.global_position, LERP_SPEED * delta)
	#if GameFlags.player_turn: return
	if !ground.is_colliding() and prev_pos != Vector3.ZERO:
		#print("correctingggg")
		step_to.global_position = prev_pos
	
	# logic for what the monster would like to do!!!!!

func take_turn():
	#if attack_queued:
		#queue_attack(player.global_position)
		#return
	#intention = CHASING
	#else:
		#intention = WANDERING
	match intention:
		CHASING:
			var los : bool = line_of_sight_test()
			if los:
				move_astar()
			#else:
				#print(":3")
			
			
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

func line_of_sight_test() -> bool:
	#var los : RayCast3D = RayCast3D.new()
	#los.exclude_parent = true
	#los.position = step_to.global_position
	#los.target_position = player.global_position
	#los.hit_from_inside
	#los.force_raycast_update()
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(step_to.global_position, player.global_position)
	query.exclude = [self, step_to, player]
	var result = space_state.intersect_ray(query)
	if result:
		return false
		#print(result)
	#if los.is_colliding():
		#var col = los.get_collider()
		#if col and col.is_in_group("Player"):
		#return true
	
	return true

func move_astar() -> void:
	#player = get_tree().get_first_node_in_group("Player")
	path = amap.get_astar_avoid_units(self.step_to.global_position, player.global_position)
	#print(path)
	if path.size() > 2:
		var target: Vector3 = Vector3(path[1].x * STEP_SIZE, step_to.global_position.y, path[1].y * STEP_SIZE)
		#var target_length = (target - step_to.global_position).length()
		#print(target_length)
		#if target_length <= 4:
			#queue_attack(target)
		#if (player.global_postion - step_to.global_position).length() < 6:
			#do_attack()
		step_to.global_position = target
		#print("target pos:", target , "path destination: ", Vector3(path[-1].x * STEP_SIZE, step_to.global_position.y, path[-1].y * STEP_SIZE))
	elif path.size() == 2 :
		#var target: Vector3 = Vector3(path[-1].x * STEP_SIZE, 0, path[-1].y * STEP_SIZE)
		var i: int = randi() % (stats_resource.aggression + 1)
		#print(i)
		if i > 3:
			do_attack()
		#else:
			#print(":3")
		#queue_attack(target)
	
	#path = amap.get_as_path(step_to.global_position, player.global_position)
	##print("monster pos: ", step_to.global_position, "player pos: ", player.global_position)
	#print(path)
	#if path.size() > 2:
		#var new_target = Vector3(path[1].x * 4, step_to.global_position.y, path[1].y * 4)
		##var target_len = (path[path_id] - Vector2(step_to.global_position.x, step_to.global_position.z)).length()
		#
		##new_target.y = step_to.global_position.y
		#step_to.global_position = new_target
		#print("target: ",new_target)
	#elif path.size() == 2:
		#var target: Vector3 = Vector3(path[-1].x * STEP_SIZE, step_to.global_position.y, path[-1].y * STEP_SIZE)
		#queue_attack(target)

func queue_attack(pos: Vector3 ) -> void:
	
	
	if attack_queued:
		
		for f in get_tree().get_nodes_in_group("AttackSquare"):
			f.queue_free()
		if pos == attack_position:
			do_attack()
		#attack_queued = false
	else:
		attack_position = pos
		var attack = ATTACK_INDICA.instantiate()
		attack.global_position = pos
		get_parent().add_child(attack)
		attack_queued = true
	
	#print("attacked u :3")

func do_attack():
	var damage : int = stats_resource.damage
	player.get_parent().take_damage(damage)
	#attack_queued = false

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
	queue_free()
	#self.visible = !self.visible
	#collision_shape_3d.disabled = true
