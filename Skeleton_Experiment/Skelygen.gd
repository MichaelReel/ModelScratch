tool
class_name TreeSkeletonGenerator
extends Skeleton


# Input variables
## The starting size of the trunk from which subsequent branches are scaled.
export (float, 0.001, 100.0) var start_bough_size : float = 1.0 setget _set_start_bough_size
## The starting bend of each new branch from the parent branch from which subsequent bends are scaled.
export (float, -3.14159265359, 6.28318530718, 0.00872664625) var start_branch_tilt : float = 1.053414 setget _set_start_branch_tilt
## The number of times a branch will be split into smaller branches.
export (int, 0, 4) var branch_segments : int = 3 setget _set_branch_segments
## The number of new branches that are created at each split.
export (int, 1, 4) var branch_per_segment : int = 3 setget _set_branch_per_segment
## The incremental length change to each sub-branch in comparison to it's parent branch.
export (float, -10.0, 100.0, 0.1) var bough_length_mod : float = -0.1 setget _set_bough_length_mod
## The incremental change to the bend of each new branch in comparison to the bend between the parent and grandparent branch.
export (float, -3.14159265359, 3.14159265359) var branch_tilt_mod : float = -0.157434 setget _set_branch_tilt_mod


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
	set_bone_rest(trunk_index, Transform.IDENTITY.translated(Vector3.UP * start_bough_size))
	set_bone_parent(trunk_index, root_index)

	_add_bough(trunk_index, 1.0, 0.0, 0.0)
	
	_spit_debug()

func _add_bough(
	parent_bone_index: int, bough_size: float, tilt: float, roll: float, depth: int = 0
) -> void:
	"""
	Adds a branch along with recursive sub-branches.

	parent_bone_index: the index of the bone to which the branch will be added
	bough_size: the length of the current branch
	(N.B: sub branches will be modified by the global settings)
	tilt: the angle in degrees from the parent orientation
	roll: the roll angle around the parent branch
	depth: how many recursive layers of sub-branches to generate. 
	"""
	var bough_name = "bough_%02d" % get_bone_count()
	
	add_bone(bough_name)
	var bough_index := find_bone(bough_name)
	var parent_bone_rest := get_bone_rest(parent_bone_index)
	set_bone_rest(bough_index, parent_bone_rest)
	set_bone_parent(bough_index, parent_bone_index)



func _reset() -> void:
	clear_bones()

func _spit_debug() -> void:
	print("Bones: " + str(get_bone_count()))


func _set_start_bough_size(value: float) -> void:
	start_bough_size = value
	_create_tree()

func _set_start_branch_tilt(value: float) -> void:
	start_branch_tilt = value
	_create_tree()

func _set_branch_segments(value: int) -> void:
	branch_segments = value
	_create_tree()

func _set_branch_per_segment(value: int) -> void:
	branch_per_segment = value
	_create_tree()

func _set_bough_length_mod(value: float) -> void:
	bough_length_mod = value
	_create_tree()

func _set_branch_tilt_mod(value: float) -> void:
	branch_tilt_mod = value
	_create_tree()


