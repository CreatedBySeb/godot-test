extends Node
class_name GameManager

enum CursorMode {
	Select,
	Menu,
	Action,
}

const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

@onready var action_overlay: ActionOverlay = %ActionOverlay
@onready var camera: Camera = %Camera
@onready var cursor: Cursor = %Cursor
@onready var level: LevelMap = %LevelMap

@onready var enemy_timer = $EnemyTimer
@onready var hud = $HUD
@onready var select_sound = $SelectSound

@export var enemy_units: Array[Unit] = []
@export var player_units: Array[Unit] = []

var all_units: Array[Unit]:
	get:
		return player_units + enemy_units

var cursor_mode: = CursorMode.Select
var player_turn = true
var selected_unit = 0
var turn = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	await level.ready

	# Wait for all the player_units to have initialised to ensure board is populated correctly
	for unit in player_units + enemy_units:
		await unit.ready

	hud.game = self
	select_unit(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("select_next_unit"):
		select_unit(selected_unit + 1)
	elif Input.is_action_just_pressed("select_prev_unit"):
		select_unit(selected_unit - 1)

	if Input.is_action_just_pressed("zoom_in"):
		camera.incr_zoom()
	elif Input.is_action_just_pressed("zoom_out"):
		camera.decr_zoom()

	if cursor_mode != CursorMode.Menu:
		if Input.is_action_just_pressed("cursor_up"):
			move_cursor(Vector2.UP)
		elif Input.is_action_just_pressed("cursor_down"):
			move_cursor(Vector2.DOWN)
		elif Input.is_action_just_pressed("cursor_right"):
			move_cursor(Vector2.RIGHT)
		elif Input.is_action_just_pressed("cursor_left"):
			move_cursor(Vector2.LEFT)

	if cursor_mode == CursorMode.Select and Input.is_action_just_pressed("select"):
		cursor_mode = CursorMode.Menu
		cursor.freeze()
		hud.present_menu(cursor.target if cursor.target in player_units else null)


func should_turn_end():
	for unit in player_units:
		if not unit.moved:
			return

		if not unit.acted and unit.can_act:
			return

	end_turn()


func end_turn():
	for unit in player_units:
		unit.moved = true
		unit.acted = true

	hud.update_hud()

	# TODO: need to detect if all enemies have been defeated to speed up spawning more,
	# can take 1 turn as a reward for clearing before next wave
	player_turn = false

	await hud.enemy_move()
	await perform_enemy_moves()

	turn += 1
	await hud.advance_turn()
	hud.update_hud()
	get_tree().call_group("units", "refresh")
	select_unit(0)
	player_turn = true


func perform_enemy_moves():
	var skip_animations = GameConfig.visuals__skip_animations

	for enemy in enemy_units:
		if not skip_animations:
			select_unit(all_units.find(enemy))
			enemy_timer.start()
			await enemy_timer.timeout
			cursor.freeze()
			enemy_timer.start()
			await enemy_timer.timeout

		var valid_moves = get_valid_moves(enemy.location, enemy.unit_class.move_range)
		if len(valid_moves) == 0:
			continue

		var move = valid_moves[0] if len(valid_moves) == 1 else valid_moves[randi() % len(valid_moves)]
		move_unit(enemy, move)

		if not skip_animations:
			enemy_timer.start()
			await enemy_timer.timeout

		var targets = get_valid_targets(enemy.location, enemy.unit_class.base_attack_range, false)
		if len(targets) > 0:
			perform_attack(enemy, targets[0])

			if not skip_animations:
				enemy_timer.start()
				await enemy_timer.timeout

		hud.update_hud()
		cursor.unfreeze()


func select_unit(index: int):
	selected_unit = wrap(index, 0, len(all_units))
	camera.target = all_units[selected_unit]
	cursor.target = all_units[selected_unit]
	select_sound.play()
	hud.update_hud()

	var unit = all_units[selected_unit]

	if not unit.moved:
		action_overlay.display_moves(unit)
	elif not unit.acted:
		action_overlay.display_actions(unit, true)
	else:
		action_overlay.clear()


func tile_is_available(tile: Vector2) -> bool:
	if unit_on_tile(tile):
		return false

	var tile_data = level.get_cell_tile_data(0, tile)
	if !tile_data or !tile_data.get_custom_data("walkable"):
		return false

	return true


func get_valid_moves(from: Vector2, remaining_range: int) -> Array[Vector2]:
	var valid_moves: Array[Vector2] = [from]

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
	var all_targets = enemy_units if is_player else player_units
	var valid_targets: Array[Unit] = []

	if remaining_range > 1:
		for direction in DIRECTIONS:
			var unit = unit_on_tile(from + direction)
			if unit in all_targets:
				valid_targets.append(unit)

			valid_targets.append_array(get_valid_targets(from + direction, remaining_range - 1, is_player))
	else:
		for direction in DIRECTIONS:
			var unit = unit_on_tile(from + direction)
			if unit in all_targets:
				valid_targets.append(unit)
	
	return valid_targets


func unit_on_tile(tile: Vector2) -> Unit:
	for unit in all_units:
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


func move_cursor(direction: Vector2):
	if cursor_mode == CursorMode.Menu:
		return

	var map = level if cursor_mode == CursorMode.Select else action_overlay
	var new_location: Vector2 = cursor.location

	if cursor.target:
		new_location = map.global_to_map(cursor.target.position) + direction
	else:
		new_location += direction

	if not map.get_cell_tile_data(0, new_location):
		return

	var unit = unit_on_tile(new_location)
	if unit:
		if cursor_mode == CursorMode.Select:
			select_unit(all_units.find(unit))
		else:
			cursor.target = unit
			camera.target = unit
	else:
		cursor.target = null
		cursor.location = new_location
		camera.target = null
		camera.position = map.map_to_global(new_location)

		if cursor_mode == CursorMode.Select:
			action_overlay.clear()
		


func perform_attack(attacker: Unit, defender: Unit) -> bool:
	if attacker.acted:
		return false

	var valid_targets = get_valid_targets(attacker.location, attacker.unit_class.base_attack_range, attacker in player_units)
	if defender not in valid_targets:
		return false

	var damage = attacker.attack()
	attacker.play_attack(attacker.location.direction_to(defender.location))
	var dead = await defender.damage(damage)

	if dead:
		enemy_units.erase(defender)
		defender.queue_free()
		hud.update_hud()

	action_overlay.clear()
	return true
