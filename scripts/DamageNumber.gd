extends Label

const HEALING_COLOUR = Color(.3, .69, .14, 1)

@export var speed: float

var healing: bool = false


func _ready():
	if healing:
		add_theme_color_override("font_color", HEALING_COLOUR)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= delta * speed
