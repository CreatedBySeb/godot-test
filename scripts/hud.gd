extends CanvasLayer

@onready var turn_number: Label = $TurnNumber


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_hud(game: GameManager) -> void:
	turn_number.text = "Turn " + str(game.turn)
