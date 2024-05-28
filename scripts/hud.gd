extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var turn_number: Label = %TurnNumber


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_hud(game: GameManager) -> void:
	turn_number.text = "Turn " + str(game.turn)


func advance_turn() -> void:
	animation_player.play("your_turn")
	await animation_player.animation_finished
