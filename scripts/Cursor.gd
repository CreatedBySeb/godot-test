extends Node2D
class_name Cursor

const FROZEN_COLOUR = Color(.75, .75, .75, 1)
const NORMAL_COLOUR = Color(1, 1, 1, 1)

@onready var level: LevelMap = %LevelMap

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

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


func freeze():
	animation_player.play("RESET")
	sprite.modulate = FROZEN_COLOUR


func unfreeze():
	animation_player.play("default")
	sprite.modulate = NORMAL_COLOUR
