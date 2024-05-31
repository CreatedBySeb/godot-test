extends Node2D
class_name Cursor

@onready var level: LevelMap = %LevelMap

@export var location: Vector2 = Vector2.ZERO
@export var location_offset: Vector2 = Vector2.ZERO
@export var target: Node2D
@export var target_offset: Vector2 = Vector2.ZERO


func _ready():
	update()


func _process(delta):
	update()


func update():
	if target:
		position = target.position + target_offset
	else:
		position = level.map_to_global(location) + location_offset
