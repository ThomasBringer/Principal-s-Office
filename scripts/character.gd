extends Node2D

@onready var sprite = $AnimatedSprite
@onready var anim = $AnimationPlayer

func _on_change_character(character):
	if !sprite: sprite = $AnimatedSprite
	sprite.frame = character

func _on_speech_2_talk():
	if !anim: anim = $AnimationPlayer
	anim.play("talk")
