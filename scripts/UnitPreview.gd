extends ColorRect

const ACTIVE_COLOUR = Color(1, 1, 1, 1)
const ACTIVE_HEIGHT = 64
const INACTIVE_COLOUR = Color(0.5, 0.5, 0.5, 1)
const INACTIVE_HEIGHT = 32

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var sprite: TextureRect = $MarginContainer/UnitSprite

var unit: Unit


func _ready():
	sprite.texture = unit.unit_class.sprite
	progress_bar.max_value = unit.unit_class.max_health
	update()
	set_highlighted(false)


func set_highlighted(highlighted: bool) -> void:
	color = ACTIVE_COLOUR if highlighted else INACTIVE_COLOUR
	custom_minimum_size.y = ACTIVE_HEIGHT if highlighted else INACTIVE_HEIGHT


func update():
	progress_bar.value = unit.health
