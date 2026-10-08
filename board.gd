class_name Board
extends RefCounted

const ROWS = 20
const COLS = 10
const EMPTY := "."
var _cells: Array[Array]

func _init() -> void:
    reset()

func reset() -> void:
    _cells = []
    for i in range(ROWS):
        _cells.append([])
        for j in range(COLS):
            _cells[i].append(EMPTY)

func try_move(dir: Vector2i, p_piece: Piece) -> bool:
    if not piece_fit(p_piece.position+dir, p_piece):
        return false
    else:
        return true

func piece_fit(p_position: Vector2i, p_piece: Piece) -> bool:
    for i in range(p_piece.shape.size()):
        var offset = p_piece.shape[i]
        var current_x = p_position.x + offset.x
        var current_y = p_position.y + offset.y
        if (current_x >= COLS || current_x < 0) || (current_y >= ROWS || current_y < 0):
            return false
        if (_cells[current_y][current_x] != EMPTY):
            return false
    return true;

func lock(p_piece: Piece) -> void:
    for offset in p_piece.shape:
        var cell: Vector2i = offset + p_piece.position
        _cells[cell.y][cell.x] = p_piece.type

func check_lines() -> Array:
    var result = []
    for i in range(ROWS):
        var filled_count = 0;
        for j in range(COLS):
            if (_cells[i][j] != EMPTY):
                filled_count+=1
            if (filled_count == COLS):
                result.append(i)
    return result

func clear_lines(p_array: Array) -> void :
    for index in p_array:
        _cells.remove_at(index)
        var new_row := []
        new_row.resize(COLS)
        new_row.fill(EMPTY)
        _cells.insert(0, new_row)


func draw(canvas: CanvasItem, origin: Vector2i, cell_size: int) -> void:
    canvas.draw_rect(Rect2(origin, Vector2(COLS*cell_size,ROWS*cell_size)), Color.BLACK, true ,0.0)
    for i in range(ROWS):
        for j in range(COLS):
            var value = _cells[i][j]
            var rect := Rect2(
				origin.x + j * cell_size,
				origin.y + i * cell_size,
				cell_size,
				cell_size
			)
            canvas.draw_rect(rect, Piece.COLORS[value], true, 0.0)
            canvas.draw_rect(rect, Color.WHITE, false, 1.0)
    canvas.draw_rect(Rect2(origin, Vector2(COLS*cell_size,ROWS*cell_size)), Color.WHITE, false ,1.0)
