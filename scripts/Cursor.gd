extends Node2D
class_name Cursor

@export var location: Vector2 = Vector2.ZERO
@export var offset: Vector2 = Vector2.ZERO
@export var target: Node2D


func _ready():
	update()


func _process(delta):
	update()


func update():
	if target:
		location = target.position

	position = location + offset
