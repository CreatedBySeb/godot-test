extends CanvasLayer

const UnitPreview = preload("res://scenes/unit_preview.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_previews: VBoxContainer = $MarginContainer/EnemyPreviews
@onready var player_previews: VBoxContainer = $MarginContainer/PlayerPreviews
@onready var turn_number: Label = $MarginContainer/TurnNumber

var game: GameManager


func update_hud() -> void:
	turn_number.text = "Turn " + str(game.turn)

	for child in player_previews.get_children() + enemy_previews.get_children():
		child.queue_free()

	for unit in game.player_units:
		var preview = UnitPreview.instantiate()
		preview.unit = unit
		player_previews.add_child(preview)
		preview.set_highlighted(game.all_units[game.selected_unit] == unit)

	for unit in game.enemy_units:
		var preview = UnitPreview.instantiate()
		preview.unit = unit
		enemy_previews.add_child(preview) 
		preview.set_highlighted(game.all_units[game.selected_unit] == unit)


func advance_turn() -> void:
	animation_player.play("your_turn")
	await animation_player.animation_finished


func enemy_move() -> void:
	animation_player.play("enemy_turn")
	await animation_player.animation_finished
