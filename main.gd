extends Node2D

const BOARD_ORIGIN := Vector2i(CELL_SIZE, CELL_SIZE)
const HELD_BOARD_ORIGIN := Vector2i(BOARD_ORIGIN.x + (Board.COLS + 1) * CELL_SIZE, BOARD_ORIGIN.y)
const HELD_PIECE_ORIGIN := Vector2i(HELD_BOARD_ORIGIN.x+HELD_CELL_SIZE, HELD_BOARD_ORIGIN.y + 3*HELD_CELL_SIZE/2)
const CELL_SIZE := 32
const HELD_CELL_SIZE := 16

#-1 left / 0 null / 1 droite
var _das_dir := 0
var _das_timer := 0.0
var _arr_timer := 0.0

const _FALL_DELAY := 0.5
const _SOFT_DROP_DELAY := 0.08
const DAS_DELAY := 0.2
const ARR_DELAY := 0.03

var _fall_timer := 0.0
var _soft_drop_timer := 0.0
var _combo := 0
var _can_hold := true
# TODO: eventually make that change with the score
var _lock_delay := 0.5
var _board: Board

var _current_piece: Piece
var _held_piece: Piece
var _seven_bag: Array[Piece] = []

func new_piece() -> void:
	_can_hold = true
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
		
func SRS_rotation(p_clockwise: bool) -> void:
	var rotated_piece = _current_piece.duplicate()
	rotated_piece.shape = _current_piece.rotate(p_clockwise)
	var old_shape = rotated_piece.shape
	var kicks = _current_piece.get_kicks(p_clockwise)
	rotated_piece.rotation_index = _current_piece.calculate_new_rotation_index(p_clockwise)
	for kick in kicks:
		var test_pos = _current_piece.position + kick
		if _board.piece_fit(test_pos, rotated_piece):
			rotated_piece.position = test_pos
			_current_piece = rotated_piece
			return
			

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

func shift(direction: Vector2i) -> bool:
	if not _board.try_move(direction, _current_piece):
		return false
	_current_piece.position += direction
	return true

func das_arr(direction: Vector2i, delta: float) -> void:
	print("das_arr delta: " + String.num(delta))
	_das_timer = _das_timer + delta
	print("das_arr _das_timer: " + String.num(_das_timer))
	print(_das_timer)
	print()
	if (_das_timer < DAS_DELAY):
		return
	if (ARR_DELAY == 0):
		while (shift(direction)):
			pass
	else:
		_arr_timer += delta
		while _arr_timer >= ARR_DELAY:
			_arr_timer -= ARR_DELAY
			shift(direction)

func _draw() -> void:
	_board.draw_modular_board(self, BOARD_ORIGIN, CELL_SIZE)
	draw_lowest_position()
	_current_piece.draw(self, BOARD_ORIGIN, CELL_SIZE)
	
	_board.draw_held_piece_square(self, HELD_BOARD_ORIGIN, HELD_CELL_SIZE)
	if (_held_piece != null):
		_held_piece.draw_raw(self, HELD_PIECE_ORIGIN, HELD_CELL_SIZE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_fall_timer += delta
	# handle the piece falling down
	if (_fall_timer >= _FALL_DELAY):
		# if the piece can't move down, lock it in place and check for lines to clear
		move_piece_down()
		_fall_timer = 0.0
	if (Input.is_action_pressed("soft_drop")):
		_soft_drop_timer += delta
		if (_soft_drop_timer >= _SOFT_DROP_DELAY):
			_soft_drop_timer -= _SOFT_DROP_DELAY
			shift(Vector2i.DOWN)
	else:
		_soft_drop_timer = 0.0
	
	handle_horizontal(delta)
	queue_redraw()

func handle_horizontal(delta: float) -> void:
	var left  := Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("move_right")
	
	if Input.is_action_just_pressed("move_left"):
		start_das(-1)
	elif Input.is_action_just_pressed("move_right"):
		start_das(1)
	elif _das_dir == -1 and not left:
		if right:
			start_das(1)
		else:
			start_das(0)
	elif _das_dir == 1 and not right:
		if left:
			start_das(-1)
		else:
			start_das(0)
	if (_das_dir != 0):
		das_arr(Vector2i(_das_dir, 0), delta)

func start_das(dir: int) -> void:
	print("start_das: " +String.num(dir))
	_das_dir = dir
	_das_timer = 0.0
	_arr_timer = 0.0
	if dir != 0:
		shift(Vector2i(dir, 0))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("hard_drop", false):
		hard_drop()
	elif event.is_action_pressed("move_left", false):
		var direction = Vector2i.LEFT
		#shift(direction)
	elif event.is_action_pressed("move_right", false):
		var direction = Vector2i.RIGHT
		#shift(direction)
	elif event.is_action_pressed("rotate_clockwise", false):
		SRS_rotation(true)
	elif event.is_action_pressed("rotate_counterclockwise", false):
		SRS_rotation(false)
	elif event.is_action_pressed("hold_piece"):
		if (_held_piece == null):
			_held_piece = Piece.new(_current_piece.type)
			new_piece()
			_can_hold = false
		elif (_can_hold):
			_can_hold = false
			var temp = Piece.new(_current_piece.type)
			_current_piece = Piece.new(_held_piece.type)
			_held_piece = temp.duplicate()
	queue_redraw()
