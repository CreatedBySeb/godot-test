extends Camera2D
class_name Camera

const ZOOM_LEVELS = [Vector2(.75, .75), Vector2(1, 1), Vector2(1.5, 1.5)]

@export var target: Node2D

var zoom_level: int = 1


func _process(delta):
	if target:
		position.x = target.position.x
		position.y = target.position.y


func incr_zoom():
	zoom_level = clamp(zoom_level + 1, 0, len(ZOOM_LEVELS) - 1)
	zoom = ZOOM_LEVELS[zoom_level]


func decr_zoom():
	zoom_level = clamp(zoom_level - 1, 0, len(ZOOM_LEVELS) - 1)
	zoom = ZOOM_LEVELS[zoom_level]
