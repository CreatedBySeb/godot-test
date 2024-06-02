extends AnimatableBody2D
class_name Unit

const DamageNumber = preload("res://scenes/damage_number.tscn")

const ACTED_COLOUR = Color(.75, .75, .75, 1)
const READY_COLOUR = Color(1, 1, 1, 1)

const ATTACK_ANIMATIONS = {
	Vector2.UP: "attack_north",
	Vector2.RIGHT: "attack_east",
	Vector2.DOWN: "attack_south",
	Vector2.LEFT: "attack_west",
}

@export var unit_class: UnitClass

@onready var game: GameManager = %GameManager
@onready var level: LevelMap = %LevelMap

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var acted: bool = false
var health: int
var location: Vector2
var moved: bool = false

var can_act: bool:
	get:
		var targets = game.get_valid_targets(location, unit_class.base_attack_range, self in game.player_units)
		return len(targets) > 0


# Called when the node enters the scene tree for the first time.
func _ready():
	location = level.global_to_map(position)
	sprite.texture = unit_class.sprite
	health = unit_class.max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var selected = game.all_units[game.selected_unit] == self


func move_to_tile(tile: Vector2):
	set_flip(location.direction_to(tile))
	location = tile
	position = level.map_to_global(tile)
	moved = true


func refresh() -> void:
	moved = false
	acted = false
	sprite.modulate = READY_COLOUR


func attack() -> int:
	acted = true
	sprite.modulate = ACTED_COLOUR
	return unit_class.base_attack


func play_attack(direction: Vector2):
	if direction not in ATTACK_ANIMATIONS:
		return

	set_flip(direction)
	animation_player.play(ATTACK_ANIMATIONS[direction])


func damage(amount: int) -> bool:
	health -= amount

	animation_player.play("damage")

	var damage_number = DamageNumber.instantiate()
	damage_number.text = str(amount)
	damage_number.position = position + Vector2(-42, -96)
	get_parent().add_child(damage_number)

	await animation_player.animation_finished

	return health <= 0


func set_flip(direction: Vector2):
	if direction.x != -direction.y:
		sprite.flip_h = direction.x > 0 or direction.y > 0


func wait():
	var old_health = health
	acted = true
	moved = true
	health = clamp(health + 2, 0, unit_class.max_health)
	
	if old_health != health:
		var damage_number = DamageNumber.instantiate()
		damage_number.healing = true
		damage_number.text = str(health - old_health)
		damage_number.position = position + Vector2(-42, -96)
		get_parent().add_child(damage_number)
