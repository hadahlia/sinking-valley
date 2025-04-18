extends Resource
class_name Entity

@export var icon : Texture2D
@export_group("General Stats")
@export var unitName : String
#@export var level : int
@export var maxHP : int
@export var currentHP : int
@export var defense : int
@export var isDead : bool = false

func TakeDamage(amount : int):
	var calcdmg : int = amount - (defense / 2)
	if calcdmg <= 0:
		calcdmg = 1
	if(calcdmg >= currentHP):
		currentHP = 0
		isDead = true
	else:
		
		
		currentHP -= calcdmg

func HealDamage(amount : int):
	if(amount <= currentHP):
		currentHP = maxHP
	else:
		currentHP += amount
