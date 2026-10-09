extends Node2D

const BOARD_ORIGIN := Vector2i(CELL_SIZE, CELL_SIZE)
const HELD_PIECE_ORIGIN := Vector2i(BOARD_ORIGIN.x + CELL_SIZE * (Board.COLS+2), BOARD_ORIGIN.y)
const CELL_SIZE = 32
var _fall_timer := 0.0
var _soft_drop_timer := 0.0
# TODO: eventually make that change with the score
const FALL_DELAY := 0.5
const SOFT_DROP_DELAY := 0.09
var _board: Board

var _current_piece: Piece
var _held_piece: Piece
var _seven_bag: Array[Piece] = []

func new_piece() -> void:
	var next_piece = seven_bag()
	_current_piece = next_piece
	if not _board.piece_fit(_current_piece.position, _current_piece):
		print("Game Over")
		_board.reset()
		new_piece()

func move_piece_down() -> void:
	if _board.try_move(Vector2i.DOWN, _current_piece):
		_current_piece.position += Vector2i.DOWN
	else:
		_board.lock(_current_piece) 
		var lines_to_clean = _board.check_lines()
		_board.clear_lines(lines_to_clean)
		new_piece()

func lowest_position() -> Vector2i:
	var lowest_pos = _current_piece.position
	while (_board.piece_fit(lowest_pos + Vector2i.DOWN, _current_piece)):
		lowest_pos += Vector2i.DOWN
	return lowest_pos

func hard_drop() -> void:
	_current_piece.position = lowest_position()
	move_piece_down()
	queue_redraw()

func fill_seven_bag() -> void:
	for value in Piece.TYPES:
		_seven_bag.append(Piece.new(value))
	_seven_bag.shuffle()
	_seven_bag.append(Piece.new("O"))

func seven_bag() -> Piece:
	if (_seven_bag.size() == 0):
		fill_seven_bag()
	return _seven_bag.pop_front()

func _ready() -> void:
	_board = Board.new()
	new_piece()

func draw_lowest_position() -> void:
	var shadow_piece = _current_piece.duplicate()
	shadow_piece.position = lowest_position()
	shadow_piece.draw(self, BOARD_ORIGIN, CELL_SIZE, Piece.SHADOW_COLOR)

func _draw() -> void:
	_board.draw_modular_board(self, BOARD_ORIGIN, CELL_SIZE)
	_current_piece.draw(self, BOARD_ORIGIN, CELL_SIZE)
	_board.draw_held_piece_square(self, HELD_PIECE_ORIGIN, CELL_SIZE)
	if (_held_piece != null):
		_held_piece.draw_raw(self, HELD_PIECE_ORIGIN, CELL_SIZE)
	draw_lowest_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_fall_timer += delta
	# handle the piece falling down
	if (_fall_timer >= FALL_DELAY):
		# if the piece can't move down, lock it in place and check for lines to clear
		move_piece_down()
		_fall_timer = 0.0
	elif (Input.is_action_pressed("soft_drop")):
		_soft_drop_timer += delta
		if (_soft_drop_timer >= SOFT_DROP_DELAY):
			_soft_drop_timer -= SOFT_DROP_DELAY
			if _board.try_move(Vector2i.DOWN, _current_piece):
				_current_piece.position += Vector2i.DOWN
	else:
		_soft_drop_timer = 0.0
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left", true):
		if _board.try_move(Vector2i.LEFT, _current_piece):
			_current_piece.position += Vector2i.LEFT
	# a remplacer par propre systerme DAS/ARR
	elif event.is_action_pressed("move_right", true):
		if _board.try_move(Vector2i.RIGHT, _current_piece):
			_current_piece.position += Vector2i.RIGHT
	elif event.is_action_pressed("hard_drop", false):
		hard_drop()
	elif event.is_action_pressed("rotate_clockwise", false):
		var changed_piece = _current_piece.duplicate()
		changed_piece.shape = _current_piece.rotate(true) 
		changed_piece.rotation_index = (_current_piece.rotation_index + 1) % 4
		if _board.piece_fit(_current_piece.position, changed_piece):
			_current_piece = changed_piece
	elif event.is_action_pressed("rotate_counterclockwise", false):
		var changed_piece = _current_piece.duplicate()
		changed_piece.shape = _current_piece.rotate(false) 
		changed_piece.rotation_index = (_current_piece.rotation_index - 1) % 4
		if _board.piece_fit(_current_piece.position, changed_piece):
			_current_piece = changed_piece
	elif event.is_action_pressed("hold_piece"):
		if (_held_piece == null):
			_held_piece = _current_piece.duplicate()
			new_piece()
		else:
			var temp = Piece.new(_current_piece.type)
			_current_piece = Piece.new(_held_piece.type)
			_held_piece = temp.duplicate()
	queue_redraw()
