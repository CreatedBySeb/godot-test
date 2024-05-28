extends CanvasLayer

const UnitPreview = preload("res://scenes/unit_preview.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var unit_previews: VBoxContainer = $MarginContainer/UnitPreviews
@onready var turn_number: Label = $MarginContainer/TurnNumber

var game: GameManager


func update_hud() -> void:
	turn_number.text = "Turn " + str(game.turn)

	for child in unit_previews.get_children():
		child.queue_free()

	for unit  in game.units:
		var preview = UnitPreview.instantiate()
		preview.unit_class = unit.unit_class
		unit_previews.add_child(preview)
		preview.set_highlighted(game.units[game.selected_unit] == unit)


func advance_turn() -> void:
	animation_player.play("your_turn")
	await animation_player.animation_finished
