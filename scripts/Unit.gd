extends AnimatableBody2D
class_name Unit

@onready var game_manager: GameManager = %GameManager

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var selected = game_manager.units[game_manager.selected_unit] == self
	$SelectionIndicator.visible = selected
