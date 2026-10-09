class_name Piece
extends RefCounted

var type: String
var shape: Array
var position: Vector2i
var rotation_index: int = 0

const TYPES: Array[String] = ["I", "J", "L", "O", "S", "Z", "T"]

const BOX_SIZE := {
	"I": 4, 
	"O": 2, 
	"J": 3, 
	"L": 3, 
	"S": 3, 
	"Z": 3, 
	"T": 3
}

const SHADOW_COLOR: Color = Color(215, 215, 215, 0.4)

const COLORS := {
	".": Color("#000000"),
	"I": Color("#01EDFA"),
	"J": Color("#485DC5"),
	"L": Color("#FF910C"),
	"O": Color("#FEFB34"),
	"S": Color("#53DA3F"),
	"Z": Color("#EA141C"),
	"T": Color("#DD0AB2"),
}

# TODO: MAKE THAT USE THE SUPER ROTATION SYSTEM
# const SHAPES := {
# 	"I": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
# 	"J": [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
# 	"L": [Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
# 	"O": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
# 	"S": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1)],
# 	"Z": [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
# 	"T": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1)],
# }

const SHAPES := {
	"I": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
	"J": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	"L": [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	"O": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"S": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"Z": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
	"T": [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
}

func _init(p_type: String) -> void:
	type= p_type
	shape = SHAPES.get(type)
	if (BOX_SIZE[type] == 2):
		position = Vector2i(4, 0)
	else:
		position = Vector2i(3, 0)


func rotate(clockwise: bool = true) -> Array[Vector2i]:
	var n: int = BOX_SIZE[type]
	var result: Array[Vector2i] = []
	for cell in shape:
		if (clockwise):
			result.append(Vector2i(n - 1 - cell.y, cell.x))
		else:
			result.append(Vector2i(cell.y, n - 1 - cell.x))
	return result

func draw(canvas: CanvasItem, origin: Vector2i, cell_size: int, color: Color = COLORS[type]) -> void:
	for cell in shape:
		var grid_pos: Vector2i = cell + position
		var rect := Rect2(
			origin.x + (grid_pos.x * cell_size),
			origin.y + (grid_pos.y * cell_size),
			cell_size - 1,
			cell_size - 1
		)
		canvas.draw_rect(rect, color, true, 0.0)

func draw_raw(canvas: CanvasItem, origin: Vector2i, cell_size: int, color: Color = COLORS[type]) -> void:
	for cell in shape:
		var grid_pos: Vector2i = cell
		var rect := Rect2(
			origin.x + (grid_pos.x * cell_size),
			origin.y + (grid_pos.y * cell_size),
			cell_size - 1,
			cell_size - 1
		)
		canvas.draw_rect(rect, color, true, 0.0)

func duplicate() -> Piece:
	var new_piece := Piece.new(type)
	new_piece.position = position
	new_piece.shape = shape.duplicate()
	return new_piece
