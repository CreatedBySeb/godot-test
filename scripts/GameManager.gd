extends Node
class_name GameManager

const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

@onready var action_overlay: ActionOverlay = %ActionOverlay
@onready var camera: Camera = %Camera
@onready var tilemap: TileMap = %TileMap

@onready var hud = $HUD
@onready var select_sound = $SelectSound

@export var enemy_units: Array[Unit] = []
@export var player_units: Array[Unit] = []

var selected_unit = 0
var turn = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	# Wait for all the player_units to have initialised to ensure board is populated correctly
	for unit in player_units + enemy_units:
		await unit.ready

	hud.game = self
	select_unit(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("select_next_unit"):
		select_unit(1)
	elif Input.is_action_just_pressed("select_prev_unit"):
		select_unit(-1)

	if Input.is_action_just_pressed("click"):
		var mouse_pos = get_viewport().get_mouse_position()
		var space_transform = camera.get_canvas_transform().affine_inverse()
		var global_pos = space_transform * mouse_pos
		var selected_tile = tilemap.local_to_map(tilemap.to_local(global_pos))
		var unit = player_units[selected_unit]

		if not unit.moved:
			move_unit(unit, selected_tile)
		elif not unit.acted:
			var target = unit_on_tile(selected_tile)
			perform_attack(unit, target)

		hud.update_hud()
		check_turn_ended()

	# TODO: Now that we have actions we should have a manual end turn too


func check_turn_ended():
	for unit in player_units:
		# TODO: Add second check if the unit can act and if they have acted
		if not unit.moved:
			return
	
	# TODO: need to detect if all enemies have been defeated to speed up spawning more,
	# can take 1 turn as a reward for clearing before next wave

	await hud.enemy_move()
	await perform_enemy_moves()

	turn += 1
	await hud.advance_turn()
	hud.update_hud()
	get_tree().call_group("units", "refresh")
	action_overlay.display_moves(player_units[selected_unit])


func perform_enemy_moves():
	for enemy in enemy_units:
		var valid_moves = get_valid_moves(enemy.location, enemy.unit_class.move_range)

		if len(valid_moves) == 0:
			continue

		var move = valid_moves[0] if len(valid_moves) == 1 else valid_moves[randi() % len(valid_moves)]	
		move_unit(enemy, move)

		var targets = get_valid_targets(enemy.location, enemy.unit_class.base_attack_range, false)
		if len(targets) > 0:
			perform_attack(enemy, targets[0])


func select_unit(direction: int):
	selected_unit = wrap(selected_unit + direction, 0, len(player_units))
	camera.target = player_units[selected_unit]
	select_sound.play()
	hud.update_hud()
	
	var unit = player_units[selected_unit]

	if not unit.moved:
		action_overlay.display_moves(unit)
	elif not unit.acted:
		action_overlay.display_actions(unit, true)
	else:
		action_overlay.clear()


func tile_is_available(tile: Vector2) -> bool:
	if unit_on_tile(tile):
		return false
	
	var tile_data = tilemap.get_cell_tile_data(0, tile)
	if !tile_data or !tile_data.get_custom_data("walkable"):
		return false

	return true


func get_valid_moves(from: Vector2, remaining_range: int) -> Array[Vector2]:
	var valid_moves: Array[Vector2] = []

	if remaining_range > 1:
		for direction in DIRECTIONS:
			if !tile_is_available(from + direction):
				continue
			
			valid_moves.append(from + direction)
			valid_moves.append_array(get_valid_moves(from + direction, remaining_range - 1))
	else:
		for direction in DIRECTIONS:
			var tile = from + direction
			if tile_is_available(tile):
				valid_moves.append(tile)


	return valid_moves


func get_valid_targets(from: Vector2, remaining_range: int, is_player: bool) -> Array[Unit]:
	# This method does not allow for attacking in a diagonal line
	var all_targets = enemy_units if is_player else player_units
	var valid_targets: Array[Unit] = []

	for direction in DIRECTIONS:
		for distance in range(1, remaining_range + 1):
			var tile = from + direction * distance

			for target in all_targets:
				if target.location == tile:
					valid_targets.append(target)
					break

	return valid_targets


func unit_on_tile(tile: Vector2) -> Unit:
	for unit in player_units + enemy_units:
		if unit.location == tile:
			return unit

	return null


func move_unit(unit: Unit, tile: Vector2) -> bool:
	# TODO: Easiest way to handle 'wait' could be to allow movement in place?
	if unit.moved:
		return false

	var valid_moves = get_valid_moves(unit.location, unit.unit_class.move_range)
	if tile not in valid_moves:
		return false

	unit.move_to_tile(tile)
	action_overlay.display_actions(unit, unit in player_units)
	return true


func perform_attack(attacker: Unit, defender: Unit) -> bool:
	if attacker.acted:
		return false

	var valid_targets = get_valid_targets(attacker.location, attacker.unit_class.base_attack_range, attacker in player_units)
	if defender not in valid_targets:
		return false

	var damage = attacker.attack()
	var dead = defender.damage(damage)
	
	if dead:
		enemy_units.erase(defender)
		defender.queue_free()

	action_overlay.clear()
	return true
