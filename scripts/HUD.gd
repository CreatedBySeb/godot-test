extends CanvasLayer

const UnitPreview = preload("res://scenes/unit_preview.tscn")

@onready var button_attack: Button = %ButtonAttack
@onready var button_end_turn: Button = %ButtonEndTurn
@onready var button_move: Button = %ButtonMove
@onready var button_wait: Button = %ButtonWait
@onready var unit_attack: Label = %UnitAttack
@onready var unit_attack_range: Label = %UnitAttackRange
@onready var unit_health: Label = %UnitHealth
@onready var unit_move_range: Label = %UnitMoveRange
@onready var unit_name: Label = %UnitName

@onready var action_menu: PanelContainer = $ActionMenu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_previews: VBoxContainer = $MarginContainer/EnemyPreviews
@onready var player_previews: VBoxContainer = $MarginContainer/PlayerPreviews
@onready var turn_number: Label = $MarginContainer/TurnNumber

var menu_active: bool:
	get:
		return action_menu.visible

var game: GameManager
var selected_unit: Unit


func _process(delta):
	if Input.is_action_just_pressed("cancel"):
		if game.cursor_mode == game.CursorMode.Action:
			game.cursor_mode = game.CursorMode.Menu
			game.cursor.target = selected_unit
			game.cursor.freeze()
			game.camera.target = selected_unit
			reset_buttons()
			present_menu(selected_unit)
		elif game.cursor_mode == game.CursorMode.Menu:
			close_menus()
	
	if Input.is_action_just_pressed("select") and game.cursor_mode == game.CursorMode.Action:
		var cursor = game.cursor

		if button_move.button_pressed:
			var location = cursor.target.location if cursor.target else cursor.location
			# Easy way to check if the tile is a valid option
			if not game.action_overlay.get_cell_tile_data(0, location):
				return

			game.move_unit(selected_unit, location)
			cursor.target = selected_unit
		else:
			var target = cursor.target
			if not game.action_overlay.get_cell_tile_data(0, game.action_overlay.global_to_map(target.position)):
				return

			game.camera.target = selected_unit
			cursor.target = selected_unit
			game.perform_attack(selected_unit, target)

		close_menus()
		game.should_turn_end()


func update_hud() -> void:
	turn_number.text = "Turn " + str(game.turn)
	var selected_unit = game.all_units[game.selected_unit]

	unit_name.text = selected_unit.unit_class.name
	unit_health.text = str(selected_unit.health) + "/" + str(selected_unit.unit_class.max_health) + " HP"
	unit_move_range.text = "Move: " + str(selected_unit.unit_class.move_range)
	unit_attack.text = "Attack: " + str(selected_unit.unit_class.base_attack)
	unit_attack_range.text = "Range: " + str(selected_unit.unit_class.base_attack_range)

	for child in player_previews.get_children() + enemy_previews.get_children():
		child.queue_free()

	for unit in game.player_units:
		var preview = UnitPreview.instantiate()
		preview.unit = unit
		player_previews.add_child(preview)
		preview.set_highlighted(selected_unit == unit)

	for unit in game.enemy_units:
		var preview = UnitPreview.instantiate()
		preview.unit = unit
		enemy_previews.add_child(preview)
		preview.set_highlighted(selected_unit == unit)


func advance_turn() -> void:
	animation_player.play("your_turn")
	await animation_player.animation_finished


func enemy_move() -> void:
	animation_player.play("enemy_turn")
	await animation_player.animation_finished


func present_menu(unit: Unit) -> void:
	selected_unit = unit
	action_menu.visible = true
	game.cursor.freeze()

	button_move.disabled = not unit or unit.moved
	button_attack.disabled = not unit or unit.acted or not unit.can_act
	button_wait.disabled = not unit or unit.acted
	
	if not unit:
		button_end_turn.grab_focus()
	elif not unit.moved:
		button_move.grab_focus()
	elif unit.can_act:
		button_attack.grab_focus()
	else:
		button_wait.grab_focus()


func reset_buttons():
	button_attack.button_pressed = false
	button_move.button_pressed = false


func close_menus() -> void:
	selected_unit = null
	action_menu.visible = false
	reset_buttons()
	game.cursor_mode = game.CursorMode.Select
	game.cursor.unfreeze()


func _on_end_turn_pressed():
	close_menus()
	game.end_turn()


func _on_move_pressed():
	button_move.release_focus()
	game.action_overlay.display_moves(selected_unit)
	game.cursor_mode = game.CursorMode.Action
	game.cursor.unfreeze()


func _on_attack_pressed():
	button_attack.release_focus()
	game.action_overlay.display_actions(selected_unit, true)
	game.cursor_mode = game.CursorMode.Action
	game.cursor.unfreeze()


func _on_wait_pressed():
	selected_unit.wait()
	update_hud()
	close_menus()
	game.should_turn_end()
