extends Node2D

const BOARD_ORIGIN := Vector2i(CELL_SIZE, CELL_SIZE)
const CELL_SIZE = 32

var _fall_timer := 0.0
# TODO: eventually make that change with the score
const FALL_DELAY := 0.5
var _board: Board

var _current_piece: Piece
var _seven_bag: Array[Piece] = []

func fill_seven_bag() -> void:
	for value in Piece.TYPES:
		_seven_bag.append(Piece.new(value))
	_seven_bag.shuffle()

func seven_bag() -> void:
	if (_seven_bag.size() == 0):
		fill_seven_bag()
	_current_piece = _seven_bag.pop_front()


func _ready() -> void:
	_board = Board.new()
	seven_bag()


func _draw() -> void:
	_board.draw(self, BOARD_ORIGIN, CELL_SIZE)
	_current_piece.draw(self, BOARD_ORIGIN, CELL_SIZE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_fall_timer += delta
	# handle the piece falling down
	if (_fall_timer >= FALL_DELAY):
		# if the piece can't move down, lock it in place and check for lines to clear
		if not _board.try_move(Vector2i.DOWN, _current_piece):
			_board.lock(_current_piece)
			var lines_to_clean = _board.check_lines()
			_board.clear_lines(lines_to_clean)
			seven_bag()
		else:
			_current_piece.position += Vector2i.DOWN
			queue_redraw()
		_fall_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left", true):
		if _board.try_move(Vector2i.LEFT, _current_piece):
			_current_piece.position += Vector2i.LEFT
			queue_redraw()
	elif event.is_action_pressed("move_right", true):
		if _board.try_move(Vector2i.RIGHT, _current_piece):
			_current_piece.position += Vector2i.RIGHT
			queue_redraw()
	elif event.is_action_pressed("soft_drop", true):
		if _board.try_move(Vector2i.DOWN, _current_piece):
			_current_piece.position += Vector2i.DOWN
			queue_redraw()
	elif event.is_action_pressed("rotate_clockwise", false):
		var changed_piece = _current_piece.duplicate()
		changed_piece.shape = _current_piece.rotate(true) 
		if _board.piece_fit(_current_piece.position, changed_piece):
			_current_piece = changed_piece
			queue_redraw()
	elif event.is_action_pressed("rotate_counterclockwise", false):
		var changed_piece = _current_piece.duplicate()
		changed_piece.shape = _current_piece.rotate(false) 
		if _board.piece_fit(_current_piece.position, changed_piece):
			_current_piece = changed_piece
			queue_redraw()
