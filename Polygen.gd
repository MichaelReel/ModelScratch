tool
extends MeshInstance

var vertices = PoolVector3Array()
var uvs = PoolVector2Array()
var normals = PoolVector3Array()
var triangles = PoolIntArray()

const LINE_END_OFFSETS := PoolVector3Array([
	Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK
])


func _enter_tree() -> void:
	request_ready()

func _ready() -> void:
	create_geometry()
	
	mesh = ArrayMesh.new()
	var arr = []
	arr.resize(ArrayMesh.ARRAY_MAX)
	
	arr[Mesh.ARRAY_VERTEX] = vertices
	arr[Mesh.ARRAY_INDEX] = triangles
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)


func create_geometry() -> void:
	var a := Vector3(0,0,0)
	var b := Vector3(0.5,1.0,0.5)
	var width := 0.2
	add_line(a, b, width)


func add_line(start: Vector3, end: Vector3, width: float) -> void:
	vertices.append_array([
		# These will need adjustment to account for line tilt, etc
		start + (Vector3.LEFT * width),
		start + (Vector3.FORWARD * width), 
		start + (Vector3.RIGHT * width),
		start + (Vector3.BACK * width),
		end + (Vector3.LEFT * width),
		end + (Vector3.FORWARD * width), 
		end + (Vector3.RIGHT * width),
		end + (Vector3.BACK * width),
	])
	triangles.append_array([
		0, 1, 5, 0, 5, 4, # Quad between LEFT and FORWARD
		1, 2, 6, 1, 6, 5, # Quad between FORWARD and RIGHT
		2, 3, 7, 2, 7, 6, # Quad between RIGHT and BACK
		3, 0, 4, 3, 4, 7, # Quad between BACK and LEFT
	])
	uvs.append_array([
		Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, Vector2.RIGHT,
		Vector2.DOWN, Vector2.ONE, Vector2.DOWN, Vector2.ONE,
	])
	normals.append_array([
		# These will need adjusted just like the vertices
		Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK,
		Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK,
	])
