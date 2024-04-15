extends Control

@onready var dialog_prefab = preload("res://scenes/dialog.tscn")
@onready var button_prefab = preload("res://scenes/button.tscn")
@onready var offsetter_prefab = preload("res://scenes/offset_control.tscn")

@onready var story = preload("res://story/story.tres")

@export var move_delay = .4

var prev_buttons: Array[Button] = []
var prev_dialog: Dialog
var offset = 0

@export var padding_inter=15
@export var x_dialog = 100
@export var x_choice = 300

var y: float = 0

signal nextSignal
signal change_character(character: int)
signal talk

@onready var voice = $AudioStreamPlayer
@onready var timer = $Timer

var char_decount: int

var steps_read: Array[bool] = []

func _input(event):
	if event.is_action_pressed("next"):
		nextSignal.emit()

func _ready():
	start_game()

func start_game():
	#update_alphabet_mapping()
	steps_read.resize(100)
	steps_read.fill(false)
	change_character.emit(3)
	await nextSignal
	
	load_story_step(0)

func load_story_step(step: int):
	steps_read[step] = true
	var story_step: StoryStep = story.steps[step]
	if check_ending(story_step):
		return
	do_events(story_step.events)
	for dialog in story_step.dialogs:
		await add_dialog_and_wait(dialog)
	
	if story_step.redirect_immediate > -1:
		load_story_step(story_step.redirect_immediate)
	else:
		story_choices(story_step)

func story_choices(story_step: StoryStep):
	for choice in story_step.choices:
		try_add_choice(choice)
	enable_buttons(false)
	move()
	await get_tree().create_timer(move_delay).timeout 
	enable_buttons(true)

func check_ending(story_step:StoryStep):
	if story_step.redirect_immediate > -1: return false
	for choice in story_step.choices:
		if !steps_read[choice.redirect]:
			return false
	do_end()
	return true

func add_dialog_and_wait(text: String):
	add_dialog(text)
	move()
	await nextSignal
	if !timer.is_stopped():
		timer.stop()
		prev_dialog.show_all_characters()
		voice.say("")
		await nextSignal

func move():
	var start = position
#	position =start+offset*Vector2.DOWN
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", start+offset*Vector2.UP, move_delay).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	offset = 0

func offset_by(dy):
	offset += dy
	y += dy

func add_dialog(text: String):
	timer.start()
	char_decount=text.length()
	voice.say(text)
	var dialog = dialog_prefab.instantiate()
	add_child(dialog)
	var size = dialog.init(text)
	dialog.position.y = y
	dialog.position.x += x_dialog
	prev_dialog = dialog
	offset_by(size.y + padding_inter)
#	offset_by(size(dialog).y + padding_inter)
	
func _on_timer_timeout():
	char_decount -= 1
	talk.emit()
	prev_dialog.add_visible_character()
	if char_decount <= 0:
		timer.stop()

func try_add_choice(choice: StoryChoice):
	if !steps_read[choice.redirect]:
		add_choice(choice.text, choice.redirect)
		

func add_choice(choice_text: String, redirect: int):
#	var offseter:Control = offsetter_prefab.instantiate()
#	add_child(offseter)
	var button:ChoiceButton = button_prefab.instantiate()
	add_child(button)
	button.position.y = y
	button.position.x += x_choice
	button.text = choice_text
	button.choice_index = redirect
	button.choice_selected.connect(_on_choice_selected)
	prev_buttons.append(button)
	offset_by(size(button).y+padding_inter)

func _on_choice_selected(choice_index: int):
	enable_buttons(false)
	prev_buttons = []
	load_story_step(choice_index)
	
func enable_buttons(on: bool = true):
	for button in prev_buttons:
		button.disabled = !on

func size(control: Control):
	var size = control.get_rect().size
	return size
	
func do_events(events: Array[StoryEvent]):
	for event in events:
		do_event(event)
	
func do_event(event: StoryEvent):
	if event is StoryEventChangeCharacter:
		if event:
			change_character.emit(event.character)

func _on_alphabet_pitch_option_button_item_selected(index: int) -> void:
	update_alphabet_mapping()


func update_alphabet_mapping() -> void:
	var pitch = 10
	voice.alphabet_mapping = {
		"default": load("res://addons/godot-voice-generator/sound/alphabet/%s/a.wav" % pitch),
		"a": load("res://addons/godot-voice-generator/sound/alphabet/%s/a.wav" % pitch),
		"b": load("res://addons/godot-voice-generator/sound/alphabet/%s/b.wav" % pitch),
		"c": load("res://addons/godot-voice-generator/sound/alphabet/%s/c.wav" % pitch),
		"d": load("res://addons/godot-voice-generator/sound/alphabet/%s/d.wav" % pitch),
		"e": load("res://addons/godot-voice-generator/sound/alphabet/%s/e.wav" % pitch),
		"f": load("res://addons/godot-voice-generator/sound/alphabet/%s/f.wav" % pitch),
		"g": load("res://addons/godot-voice-generator/sound/alphabet/%s/g.wav" % pitch),
		"h": load("res://addons/godot-voice-generator/sound/alphabet/%s/h.wav" % pitch),
		"i": load("res://addons/godot-voice-generator/sound/alphabet/%s/i.wav" % pitch),
		"j": load("res://addons/godot-voice-generator/sound/alphabet/%s/j.wav" % pitch),
		"k": load("res://addons/godot-voice-generator/sound/alphabet/%s/k.wav" % pitch),
		"l": load("res://addons/godot-voice-generator/sound/alphabet/%s/l.wav" % pitch),
		"m": load("res://addons/godot-voice-generator/sound/alphabet/%s/m.wav" % pitch),
		"n": load("res://addons/godot-voice-generator/sound/alphabet/%s/n.wav" % pitch),
		"o": load("res://addons/godot-voice-generator/sound/alphabet/%s/o.wav" % pitch),
		"p": load("res://addons/godot-voice-generator/sound/alphabet/%s/p.wav" % pitch),
		"q": load("res://addons/godot-voice-generator/sound/alphabet/%s/q.wav" % pitch),
		"r": load("res://addons/godot-voice-generator/sound/alphabet/%s/r.wav" % pitch),
		"s": load("res://addons/godot-voice-generator/sound/alphabet/%s/s.wav" % pitch),
		"t": load("res://addons/godot-voice-generator/sound/alphabet/%s/t.wav" % pitch),
		"u": load("res://addons/godot-voice-generator/sound/alphabet/%s/u.wav" % pitch),
		"v": load("res://addons/godot-voice-generator/sound/alphabet/%s/v.wav" % pitch),
		"w": load("res://addons/godot-voice-generator/sound/alphabet/%s/w.wav" % pitch),
		"x": load("res://addons/godot-voice-generator/sound/alphabet/%s/x.wav" % pitch),
		"y": load("res://addons/godot-voice-generator/sound/alphabet/%s/y.wav" % pitch),
		"z": load("res://addons/godot-voice-generator/sound/alphabet/%s/z.wav" % pitch)
	}

func do_end():
	await add_dialog_and_wait(".........")
	await add_dialog_and_wait("THE END")
	await add_dialog_and_wait("...")
	await add_dialog_and_wait("thanks for playing!")
	await add_dialog_and_wait("...")
	await add_dialog_and_wait("made in 48 hours by Thomas Bringer")
	await add_dialog_and_wait("for Ludum Dare 55")
	await add_dialog_and_wait("around the theme")
	await add_dialog_and_wait("summoning")
	await add_dialog_and_wait("...")
	await add_dialog_and_wait("if you want to replay the game keep clicking")
	await add_dialog_and_wait("...")
	start_game()
	#await add_dialog_and_wait("what a bad theme by the way who voted for that??")
	#await add_dialog_and_wait("probably everyone's making games were you summon magic goblins or something")
	#await add_dialog_and_wait("anyway")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("why are you still here? game is over")
	#await add_dialog_and_wait("remember i said thanks for playing")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("okay you're creepy dude")
	#await add_dialog_and_wait("JUST LEAVE NOW OKAY?")
	#await add_dialog_and_wait("okay")
	#await add_dialog_and_wait("let me count down to 0")
	#await add_dialog_and_wait("and when i say 0, you won't be here anymore")
	#await add_dialog_and_wait("okay, you with me?")
	#await add_dialog_and_wait("let's go:")
	#await add_dialog_and_wait("3...")
	#await add_dialog_and_wait("2...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("1...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("0,5...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("0!")
	#await add_dialog_and_wait("...")
	#await add_dialog_and_wait("you're still here aren't you")
	#await add_dialog_and_wait("okay if you're still here")
	#await add_dialog_and_wait("comment 'i got the secret ending' below")
	#await add_dialog_and_wait("so i can know you're here")
	#await add_dialog_and_wait("also to be clear, this is not a secret ending")
	#await add_dialog_and_wait("this is just, like, a password between you and me")
	#await add_dialog_and_wait("okay, i still gotta finish this bloody game and upload it, so imma stop taking right now")
	#await add_dialog_and_wait("bye then")
	#add_dialog("thanks for playing!")
	
