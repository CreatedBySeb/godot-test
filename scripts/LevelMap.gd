extends TileMap
class_name LevelMap


func _ready():
	pass


func _process(float):
	pass


func global_to_map(pos: Vector2) -> Vector2:
	return local_to_map(to_local(pos))


func map_to_global(tile: Vector2) -> Vector2:
	return to_global(map_to_local(tile)) 
