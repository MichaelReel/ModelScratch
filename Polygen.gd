tool
class_name TreeMeshGenerator
extends MeshInstance
# Tree shaped polygon mesh generator
# Define a form of tree/plant shape 


const LINE_END_OFFSETS := PoolVector3Array([
	Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK
])

export (int) var noise_seed : int = 0 setget _set_seed
export (Material) var apply_material setget _set_apply_material
export (float) var branch_width_start := 0.2 setget _set_branch_width_start
export (float) var branch_length_start := 1.0 setget _set_branch_length_start
export (float) var branch_spread_start := 45.0 setget _set_branch_spread_start
export (int) var sub_branches_max := 4 setget _set_sub_branches_max
export (int) var sub_branch_limit := 3 setget _set_sub_branch_limit


var vertices = PoolVector3Array()
var uvs = PoolVector2Array()
var normals = PoolVector3Array()
var triangles = PoolIntArray()


func _ready() -> void:
	create_and_apply_new_mesh_data()


func create_and_apply_new_mesh_data() -> void:
	reset_geometry()

	create_geometry()

	var arr = []
	arr.resize(ArrayMesh.ARRAY_MAX)
	
	arr[Mesh.ARRAY_VERTEX] = vertices
	arr[Mesh.ARRAY_INDEX] = triangles
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh.surface_set_material(0, self.apply_material)


func reset_geometry() -> void:
	if mesh:
		mesh.clear_surfaces()
	else:
		mesh = ArrayMesh.new()

	vertices.resize(0)
	uvs.resize(0)
	normals.resize(0)
	triangles.resize(0)


func create_geometry() -> void:
	var sub_ground := Vector3.DOWN
	var first_bifurication := Vector3(0, branch_length_start, 0)
	
	var root = create_base(sub_ground, branch_width_start)
	
	var uv_switch := false
	create_branching(
		sub_ground,
		root,
		first_bifurication,
		branch_width_start,
		branch_length_start,
		branch_spread_start,
		sub_branches_max,
		sub_branch_limit,
		uv_switch
	)


func create_base(root_point: Vector3, base_width: float) -> PoolIntArray:
	vertices.append_array([
		root_point + (Vector3.DOWN * base_width),
		root_point + (Vector3.LEFT * base_width),
		root_point + (Vector3.FORWARD * base_width), 
		root_point + (Vector3.RIGHT * base_width),
		root_point + (Vector3.BACK * base_width),
	])
	triangles.append_array([
		0, 2, 1,
		0, 3, 2,
		0, 4, 3,
		0, 1, 4,
	])
	uvs.append_array([
		(Vector2.ONE / 2.0), Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE,
	])
	normals.append_array([
		Vector3.DOWN, Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK,
	])
	return PoolIntArray([1, 2, 3, 4])


func create_branching(
	base_vector: Vector3,
	base_vertices: PoolIntArray,
	bifurication: Vector3,
	width: float,
	length: float,
	spread: float,
	sub_branches: int,
	limit: int,
	uv_switch: bool
) -> void:
	if limit <= 0:
		return

	var sub_branch_rot := Vector3(0, length, 0).rotated(Vector3.LEFT, deg2rad(spread))
	var branch_rot_delta := 2.0 * PI / sub_branches
	for _branch_index in range(sub_branches):
		if limit <= 1:
			create_twig(base_vertices, bifurication)
			continue
			
		var branch_root := create_branch(base_vertices, bifurication, width, uv_switch)
		var sub_bifurication := bifurication + sub_branch_rot
		sub_branch_rot = sub_branch_rot.rotated(Vector3.DOWN, branch_rot_delta)
		create_branching(bifurication, branch_root, sub_bifurication, width, length, spread, sub_branches, limit - 1, !uv_switch)


func create_branch(base_vertices: PoolIntArray, bifurication: Vector3, width: float, uv_switch: bool) -> PoolIntArray:
	var i : int = vertices.size()
	vertices.append_array([
		# These should probably be adjusted to account for line tilt, etc
		bifurication + (Vector3.LEFT * width),
		bifurication + (Vector3.FORWARD * width), 
		bifurication + (Vector3.RIGHT * width),
		bifurication + (Vector3.BACK * width),
	])
	# We're not really giving much head to rotation here, should be okay for the moment
	triangles.append_array([
		base_vertices[0], base_vertices[1], i + 1, base_vertices[0], i + 1, i + 0, # Quad between LEFT and FORWARD
		base_vertices[1], base_vertices[2], i + 2, base_vertices[1], i + 2, i + 1, # Quad between FORWARD and RIGHT
		base_vertices[2], base_vertices[3], i + 3, base_vertices[2], i + 3, i + 2, # Quad between RIGHT and BACK
		base_vertices[3], base_vertices[0], i + 0, base_vertices[3], i + 0, i + 3, # Quad between BACK and LEFT
	])
	# These are not going to be make sense for now
	if uv_switch:
		uvs.append_array([Vector2.DOWN, Vector2.ONE, Vector2.ZERO, Vector2.RIGHT])
	else:
		uvs.append_array([Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE])
	normals.append_array([
		Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK,
	])
	return PoolIntArray(range(i, i + 4))


func create_twig(base_vertices: PoolIntArray, bifurication: Vector3) -> void:
	var i : int = vertices.size()
	vertices.append_array([bifurication])
	# We're not really giving much head to rotation here, should be okay for the moment
	triangles.append_array([
		base_vertices[0], base_vertices[1], i, # Tri between LEFT and FORWARD
		base_vertices[1], base_vertices[2], i, # Tri between FORWARD and RIGHT
		base_vertices[2], base_vertices[3], i, # Tri between RIGHT and BACK
		base_vertices[3], base_vertices[0], i, # Tri between BACK and LEFT
	])
	# These are not going to be make any sense for now
	uvs.append_array([Vector2.DOWN])
	normals.append_array([Vector3.UP])


func _set_seed(value: int) -> void:
	noise_seed = value
	create_and_apply_new_mesh_data()


func _set_apply_material(value: Material) -> void:
	apply_material = value
	create_and_apply_new_mesh_data()


func _set_branch_width_start(value: float) -> void:
	branch_width_start = value
	create_and_apply_new_mesh_data()


func _set_branch_length_start(value: float) -> void:
	branch_length_start = value
	create_and_apply_new_mesh_data()


func _set_branch_spread_start(value: float) -> void:
	branch_spread_start = value
	create_and_apply_new_mesh_data()


func _set_sub_branches_max(value: int) -> void:
	sub_branches_max = value
	create_and_apply_new_mesh_data()


func _set_sub_branch_limit(value: int) -> void:
	sub_branch_limit = value
	create_and_apply_new_mesh_data()
