extends AnimatableBody2D
class_name Unit

const DamageNumber = preload("res://scenes/damage_number.tscn")

@export var unit_class: UnitClass

@onready var game_manager: GameManager = %GameManager
@onready var tilemap: TileMap = %TileMap

@onready var sprite: Sprite2D = $Sprite2D

var acted = false
var health: int
var location: Vector2
var moved = false


# Called when the node enters the scene tree for the first time.
func _ready():
	location = tilemap.local_to_map(tilemap.to_local(position))
	sprite.texture = unit_class.sprite
	health = unit_class.max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var selected = game_manager.all_units[game_manager.selected_unit] == self
	$SelectionIndicator.visible = selected


func move_to_tile(tile: Vector2):
	location = tile
	position = tilemap.to_global(tilemap.map_to_local(tile))
	moved = true


func refresh() -> void:
	moved = false
	acted = false


func attack() -> int:
	acted = true
	return unit_class.base_attack


func damage(amount: int) -> bool:
	health -= amount
	
	var damage_number = DamageNumber.instantiate()
	damage_number.text = str(amount)
	damage_number.position = position + Vector2(-42, -58)
	get_parent().add_child(damage_number)

	return health <= 0
