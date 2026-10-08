class_name Piece
extends RefCounted

var type: String
var shape: Array
var position: Vector2i

const TYPES: Array[String] = ["I", "J", "L", "O", "S", "Z", "T"]

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
const SHAPES := {
	"I": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	"J": [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	"L": [Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	"O": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"S": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1)],
	"Z": [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
	"T": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1)],
}

func _init(p_type: String, p_position: Vector2i = Vector2i(4,1)) -> void:
	type= p_type
	shape = SHAPES.get(type)
	position = p_position


func rotate(clockwise: bool = true) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in shape:
		if (type == "O"):
			result.append(cell)
		elif clockwise:
			result.append(Vector2i(-cell.y, cell.x))
		else:
			result.append(Vector2i(cell.y, -cell.x))
	return result

func draw(canvas: CanvasItem, origin: Vector2i, cell_size: int) -> void:
	for cell in shape:
		var grid_pos: Vector2i = cell + position
		var rect := Rect2(
			origin.x + (grid_pos.x * cell_size),
			origin.y + (grid_pos.y * cell_size),
			cell_size - 1,
			cell_size - 1
		)
		canvas.draw_rect(rect, COLORS[type], true, 0.0)

func duplicate() -> Piece:
	var new_piece := Piece.new(type, position)
	new_piece.shape = shape.duplicate()
	return new_piece
