extends TileMap
class_name ActionOverlay

const OVERLAY_LAYER = 0
const OVERLAY_SOURCE = 0
const MOVE_TILE = Vector2(0, 0)

@onready var game: GameManager = %GameManager


func display_moves(unit: Unit):
	clear()

	var valid_moves = game.get_valid_moves(unit.location, unit.move_range)
	for move in valid_moves:
		set_cell(OVERLAY_LAYER, move, OVERLAY_SOURCE, MOVE_TILE)
