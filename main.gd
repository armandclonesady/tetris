extends Node2D

const BOARD_ORIGIN := Vector2i(CELL_SIZE, CELL_SIZE)
const CELL_SIZE = 32
const ROWS = 20
const COLS = 10
const EMPTY := "."

var _fall_timer := 0.0
# TODO: eventually make that change with the score
const FALL_DELAY := 0.5
var _board: Array[Array]

var _current_piece: Piece

func init_board() -> void:
	_board = []
	for i in range(ROWS):
		_board.append([])
		for j in range(COLS):
			_board[i].append(EMPTY)

func piece_fit(p_position: Vector2i, p_piece: Piece) -> bool:
	for i in range(p_piece.shape.size()):
		var current_piece = p_piece.shape[i]
		var current_x = p_position.x + current_piece.x
		var current_y = p_position.y + current_piece.y
		if (current_x >= COLS || current_x < 0) || (current_y >= ROWS):
			print("refus: x=", current_x, " y=", current_y)
			return false
		if (_board[current_y][current_x] != EMPTY):
			print("refus: x=", current_x, " y=", current_y)
			return false
	return true;
	
func try_move(dir: Vector2i) -> bool:
	if not piece_fit(_current_piece.position+dir, _current_piece):
		return false
	else:
		_current_piece.position += dir
		queue_redraw()
		return true

func lock_piece() -> void:
	for offset in _current_piece.shape:
		var cell: Vector2i = offset + _current_piece.position
		_board[cell.y][cell.x] = _current_piece.type
	_current_piece = Piece.new(Piece.TYPES.pick_random())
	queue_redraw()
# Called when the node enters the scene tree for the first time.

func check_lines() -> Array:
	var result = []
	for i in range(ROWS):
		var filled_count = 0;
		for j in range(COLS):
			if (_board[i][j] != EMPTY):
				filled_count+=1
			if (filled_count == COLS):
				result.append(i)
	return result

func clear_lines(p_array: Array) -> void :
	for index in p_array:
		_board.remove_at(index)
		var new_row := []
		new_row.resize(COLS)
		new_row.fill(".")
		_board.insert(0, new_row)


func _ready() -> void:
	init_board()
	_current_piece = Piece.new(Piece.TYPES.pick_random())

func draw_board() -> void:
	for i in range(ROWS):
		for j in range(COLS):
			var value = _board[i][j]
			var rect := Rect2(
				BOARD_ORIGIN.x + j * CELL_SIZE,
				BOARD_ORIGIN.y + i * CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE
			)
			draw_rect(rect, Piece.COLORS[value], true, 0.0)
			draw_rect(rect, Color.WHITE, false, 1.0)

func _draw() -> void:
	draw_rect(Rect2(BOARD_ORIGIN, Vector2(COLS*CELL_SIZE,ROWS*CELL_SIZE)), Color.BLACK, true ,0.0)
	draw_board()
	draw_rect(Rect2(BOARD_ORIGIN, Vector2(COLS*CELL_SIZE,ROWS*CELL_SIZE)), Color.WHITE, false ,1.0)
	#_current_piece.draw(self, _current_piece.position, CELL_SIZE)
	_current_piece.draw(self, BOARD_ORIGIN, CELL_SIZE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_fall_timer += delta
	if (_fall_timer >= FALL_DELAY):
		if not try_move(Vector2i.DOWN):
			lock_piece()
			var lines_to_clean = check_lines()
			clear_lines(lines_to_clean)
		_fall_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left", true):
		try_move(Vector2i.LEFT)
	elif event.is_action_pressed("move_right", true):
		try_move(Vector2i.RIGHT)
	elif event.is_action_pressed("soft_drop", true):
		try_move(Vector2i.DOWN)
	elif event.is_action_pressed("rotate_clockwise", true):
		var changed_piece = _current_piece.duplicate()
		changed_piece.shape = _current_piece.rotate(true) 
		if piece_fit(_current_piece.position, changed_piece):
			_current_piece = changed_piece
			queue_redraw()
	elif event.is_action_pressed("rotate_counterclockwise", true):
		var changed_piece = _current_piece.duplicate()
		changed_piece.shape = _current_piece.rotate(false) 
		if piece_fit(_current_piece.position, changed_piece):
			_current_piece = changed_piece
			queue_redraw()
