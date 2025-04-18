extends Resource
class_name Item

@export var name : String
@export var picture : Texture2D
@export_enum("Equipment", "Item") var TYPE : String

@export var item_id : int

# Item IDS
# 0: shovel
# 1: sword
# 2: chicken
# 4: treasure
