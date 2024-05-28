extends AnimatableBody2D
class_name Unit

@export var move_range: int = 1

@onready var game_manager: GameManager = %GameManager
@onready var tilemap: TileMap = %TileMap

var location: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	location = tilemap.local_to_map(tilemap.to_local(position))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var selected = game_manager.units[game_manager.selected_unit] == self
	$SelectionIndicator.visible = selected


func move_to_tile(tile: Vector2):
	location = tile
	position = tilemap.to_global(tilemap.map_to_local(tile))
