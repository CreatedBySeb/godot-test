extends PanelContainer
class_name DialogueBox

@onready var actor_label: Label = %ActorName
@onready var actor_sprite: TextureRect = %ActorSprite
@onready var dialogue_text: RichTextLabel = %DialogueText

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	await actor_label.ready
	await actor_sprite.ready
	await dialogue_text.ready

	await animation_player.ready


func display_dialogue(dialogue: Dialogue):
	animation_player.play("RESET")
	await animation_player.animation_finished
	actor_label.text = dialogue.actor.name
	actor_sprite.texture = dialogue.actor.sprite
	dialogue_text.text = dialogue.text
	animation_player.play("show_dialogue")
	await animation_player.animation_finished
	animation_player.play("flash_cursor")
