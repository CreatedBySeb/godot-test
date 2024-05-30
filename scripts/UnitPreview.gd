extends ColorRect

const ACTED_COLOUR = Color(.75, .75, .75, 1)
const ACTIVE_COLOUR = Color(1, 1, 1, 1)
const ACTIVE_HEIGHT = 128
const HEALTH_COLOUR_HIGH = Color(.3, .69, .14, 1) #4caf23
const HEALTH_COLOUR_LOW = Color(.69, .14, .15, 1)
const HEALTH_COLOUR_MID = Color(.84, .77, .17, 1)
const INACTIVE_COLOUR = Color(0.5, 0.5, 0.5, 1)
const INACTIVE_HEIGHT = 64

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

	var health_pc = float(unit.health) / float(unit.unit_class.max_health)
	var style_box = StyleBoxFlat.new()

	if health_pc <= .25:
		style_box.bg_color = HEALTH_COLOUR_LOW
	elif health_pc <= .5:
		style_box.bg_color = HEALTH_COLOUR_MID
	else:
		style_box.bg_color = HEALTH_COLOUR_HIGH

	progress_bar.add_theme_stylebox_override("fill", style_box)

	sprite.modulate = ACTED_COLOUR if unit.moved and unit.acted else ACTIVE_COLOUR
