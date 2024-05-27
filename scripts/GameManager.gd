extends Node
class_name GameManager

@export var units: Array[Unit] = []
@onready var camera: Camera = %Camera
var selected_unit = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("select_next_unit"):
		selected_unit = wrap(selected_unit + 1, 0, len(units))
		camera.target = units[selected_unit]
	elif Input.is_action_just_pressed("select_prev_unit"):
		selected_unit = wrap(selected_unit - 1, 0, len(units))
		camera.target = units[selected_unit]
