extends Camera2D

const TILE_SIZE := 16

const VIEW_WIDTH := 20
const VIEW_HEIGHT := 11

const EDGE_MARGIN := 2

var camera_tile : Vector2i

var move_tween : Tween


func _ready():

	camera_tile = Vector2i(
		round(global_position.x / TILE_SIZE),
		round(global_position.y / TILE_SIZE)
	)

	global_position = Vector2(camera_tile) * TILE_SIZE


func cursor_moved(cursor_world : Vector2):

	var cursor_tile = Vector2i(
		round(cursor_world.x / TILE_SIZE),
		round(cursor_world.y / TILE_SIZE)
	)

	var moved := false

	var left_limit = camera_tile.x - VIEW_WIDTH / 2 + EDGE_MARGIN
	var right_limit = camera_tile.x + VIEW_WIDTH / 2 - EDGE_MARGIN +1

	if cursor_tile.x < left_limit:
		camera_tile.x -= 1
		moved = true

	elif cursor_tile.x > right_limit:
		camera_tile.x += 1
		moved = true

	var top_limit = camera_tile.y - VIEW_HEIGHT / 2 + EDGE_MARGIN
	var bottom_limit = camera_tile.y + VIEW_HEIGHT / 2 - EDGE_MARGIN +1

	if cursor_tile.y < top_limit:
		camera_tile.y -= 1
		moved = true

	elif cursor_tile.y > bottom_limit:
		camera_tile.y += 1
		moved = true

	if moved:
		move_camera()


func move_camera():

	if move_tween:
		move_tween.kill()

	var target = Vector2(camera_tile) * TILE_SIZE

	move_tween = create_tween()
	move_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	move_tween.tween_property(
		self,
		"global_position",
		target,
		0.12
	).set_trans(Tween.TRANS_SINE)

	await move_tween.finished

	# Snap exactly to the grid to eliminate sub-pixel drift.
	global_position = target
