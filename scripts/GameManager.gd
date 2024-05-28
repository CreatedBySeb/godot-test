extends Node
class_name GameManager

@export var units: Array[Unit] = []

@onready var camera: Camera = %Camera
@onready var tilemap: TileMap = %TileMap
@onready var select_sound = $SelectSound

var selected_unit = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("select_next_unit"):
		select_unit(1)
	elif Input.is_action_just_pressed("select_prev_unit"):
		select_unit(-1)

	if Input.is_action_just_pressed("click"):
		var mouse_pos = get_viewport().get_mouse_position()
		var space_transform = camera.get_canvas_transform().affine_inverse()
		var global_pos = space_transform * mouse_pos
		var selected_tile = tilemap.local_to_map(tilemap.to_local(global_pos))

		move_unit(units[selected_unit], selected_tile)


func select_unit(direction: int):
	selected_unit = wrap(selected_unit + direction, 0, len(units))
	camera.target = units[selected_unit]
	select_sound.play()


func unit_on_tile(tile: Vector2) -> Unit:
	for unit in units:
		if unit.location == tile:
			return unit

	return null


func move_unit(unit: Unit, tile: Vector2) -> bool:
	if tile.distance_to(unit.location) > unit.move_range:
		print("Tile too far away")
		return false

	if unit_on_tile(tile):
		print("Tile already occupied")
		return false

	var tile_data = tilemap.get_cell_tile_data(0, tile)
	
	if !tile_data.get_custom_data("walkable"):
		print("Tile is not walkable")
		return false

	unit.move_to_tile(tile)
	return true
