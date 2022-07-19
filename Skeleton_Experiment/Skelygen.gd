tool
class_name TreeSkeletonGenerator
extends Skeleton


export (int) var noise_seed : int = 0 setget _set_seed

func _ready() -> void:
	_create_tree()


func _create_tree() -> void:
	_reset()
	
	name = "tree_skeleton"
	
	add_bone("root_bone")
	var root_index := find_bone("root_bone")
	set_bone_rest(root_index, Transform.IDENTITY)
	
	add_bone("trunk_bone")
	var trunk_index := find_bone("trunk_bone")
	set_bone_rest(trunk_index, Transform.IDENTITY.translated(Vector3.UP))
	set_bone_parent(trunk_index, root_index)
	
	add_bone("bough_01")
	var bough_index := find_bone("bough_01")
	set_bone_rest(bough_index, Transform.IDENTITY.translated(Vector3.UP))
	set_bone_parent(bough_index, trunk_index)
	
	_spit_debug()

func _reset() -> void:
	clear_bones()

func _spit_debug() -> void:
	print("Bones: " + str(get_bone_count()))


func _set_seed(value: int) -> void:
	noise_seed = value
	_create_tree()
