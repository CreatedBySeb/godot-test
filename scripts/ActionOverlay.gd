extends LevelMap
class_name ActionOverlay

const OVERLAY_LAYER = 0
const OVERLAY_SOURCE = 0
const TILE_ATTACK = Vector2(2, 0)
const TILE_HEAL = Vector2(1, 0)
const TILE_MOVE = Vector2(0, 0)

@onready var game: GameManager = %GameManager


func display_moves(unit: Unit):
	clear()

	var valid_moves = game.get_valid_moves(unit.location, unit.unit_class.move_range)
	for move in valid_moves:
		set_cell(OVERLAY_LAYER, move, OVERLAY_SOURCE, TILE_MOVE)


func display_actions(unit: Unit, is_player: bool):
	clear()
	var healing = unit.unit_class.can_heal

	var valid_targets = game.get_valid_targets(unit.location, unit.unit_class.base_attack_range, not is_player if healing else is_player)
	for target in valid_targets:
		set_cell(OVERLAY_LAYER, target.location, OVERLAY_SOURCE, TILE_HEAL if healing else TILE_ATTACK)
