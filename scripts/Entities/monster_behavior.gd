extends Node3D
class_name EntityMonster

@onready var body: Node3D = $body

#@onready var sprite_: Sprite3D = $Sprite3D
@onready var sprite_: Sprite3D = $body/Sprite3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var stats_resource : Monster

const STEP_SIZE : float = 4.0

func _ready() -> void:
	#stats_resource.TakeDamage()
	set_sprite(stats_resource.icon)

func _physics_process(delta: float) -> void:
	pass

func assess_life() -> void:
	if !stats_resource.isDead: return
	die()
	print("nah still alive")

func set_sprite(new_sprite: Texture2D) -> void:
	sprite_.texture = new_sprite

func die() -> void:
	self.visible = !self.visible
	collision_shape_3d.disabled = true
