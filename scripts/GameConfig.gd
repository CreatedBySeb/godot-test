extends Node

const CONFIG_PATH = "user://game.cfg"

var _config = ConfigFile.new()

var audio__mute_music: bool:
	get:
		return _config.get_value("audio", "mute_music", false)
	set(val):
		set_and_save("audio", "mute_music", val)

var visuals__skip_animations: bool:
	get:
		return _config.get_value("visuals", "skip_animations", false)
	set(val):
		set_and_save("visuals", "skip_animations", val)


func _ready():
	var err = _config.load(CONFIG_PATH)

	if err == ERR_FILE_NOT_FOUND:
		print("No config present, saving blank config")
		_config.save(CONFIG_PATH)
	elif err != OK:
		print("Encountered error loading config: " + str(err))


func set_and_save(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)
	var err = _config.save(CONFIG_PATH)

	if err != OK:
		print("Encountered error saving config: " + str(err))
