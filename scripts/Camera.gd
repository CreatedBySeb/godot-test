extends Camera2D
class_name Camera

@export var target: Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		position.x = target.position.x
		position.y = target.position.y
