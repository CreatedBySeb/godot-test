extends Node
class_name GameManager

const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

@onready var action_overlay: TileMap = %ActionOverlay
@onready var camera: Camera = %Camera
@onready var tilemap: TileMap = %TileMap

@onready var hud = $HUD
@onready var select_sound = $SelectSound

@export var units: Array[Unit] = []

var selected_unit = 0
var turn = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # TODO: need to select_unit for overlay etc., but doing so seems to use the wrong location here


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
		check_turn_ended()


func check_turn_ended():
	for unit in units:
		if not unit.moved:
			return

	get_tree().call_group("units", "refresh")
	turn += 1
	update_action_overlay(units[selected_unit])
	hud.update_hud(self)


func select_unit(direction: int):
	selected_unit = wrap(selected_unit + direction, 0, len(units))
	camera.target = units[selected_unit]
	select_sound.play()

	if not units[selected_unit].moved:
		update_action_overlay(units[selected_unit])


func tile_is_available(tile: Vector2) -> bool:
	if unit_on_tile(tile):
		return false
	
	var tile_data = tilemap.get_cell_tile_data(0, tile)
	if !tile_data or !tile_data.get_custom_data("walkable"):
		return false

	return true


func get_valid_moves(from: Vector2, remaining_range: int) -> Array[Vector2]:
	var valid_moves: Array[Vector2] = []

	if remaining_range > 1:
		for direction in DIRECTIONS:
			if !tile_is_available(from + direction):
				continue
			
			valid_moves.append(from + direction)
			valid_moves.append_array(get_valid_moves(from + direction, remaining_range - 1))
	else:
		for direction in DIRECTIONS:
			var tile = from + direction
			if tile_is_available(tile):
				valid_moves.append(tile)


	return valid_moves


func clear_action_overlay():
	action_overlay.remove_layer(0)
	action_overlay.add_layer(0)


func update_action_overlay(unit: Unit):
	clear_action_overlay()

	var valid_moves = get_valid_moves(unit.location, unit.move_range)
	for move in valid_moves:
		action_overlay.set_cell(0, move, 0, Vector2(0, 0))


func unit_on_tile(tile: Vector2) -> Unit:
	for unit in units:
		if unit.location == tile:
			return unit

	return null


func move_unit(unit: Unit, tile: Vector2) -> bool:
	if unit.moved:
		return false

	var valid_moves = get_valid_moves(unit.location, unit.move_range)
	if tile not in valid_moves:
		return false

	unit.move_to_tile(tile)
	clear_action_overlay()
	return true
