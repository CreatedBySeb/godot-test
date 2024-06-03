extends PanelContainer


@onready var mute_music: Button = %MuteMusic
@onready var skip_animations: Button = %SkipAnimations


# Called when the node enters the scene tree for the first time.
func _ready():
	update_buttons()


func update_buttons():
	mute_music.text = "Mute Music: " + ("On" if GameConfig.audio__mute_music else "Off")
	skip_animations.text = "Skip Animations: " + ("On" if GameConfig.visuals__skip_animations else "Off")


func _on_skip_animations_pressed():
	GameConfig.visuals__skip_animations = not GameConfig.visuals__skip_animations
	update_buttons()



func _on_mute_music_pressed():
	GameConfig.audio__mute_music = not GameConfig.audio__mute_music
	update_buttons()


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
