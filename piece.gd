class_name Piece
extends RefCounted

var type: String
var color: Color
var shape: Array
var position: Vector2i

const TYPES: Array[String] = ["I", "J", "L", "O", "S", "Z", "T"]

const COLORS := {
	".": Color.BLACK,
	"I": Color.LIGHT_BLUE,
	"J": Color.BLUE, 
	"L":Color.ORANGE, 
	"O":Color.YELLOW,
	"S":Color.GREEN, 
	"Z":Color.RED, 
	"T":Color.MAGENTA
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
	color = COLORS.get(type)
	shape = SHAPES.get(type)
	position = p_position


func rotate(clockwise: bool = true) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in shape:
		if clockwise:
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
		canvas.draw_rect(rect, color)
	
