class_name Dialog extends Control

@onready var box =$Box
@onready var text =$Text
@export var pad_v = 15
@export var pad_h = 15

func _ready():
	adjust_size()

func adjust_size():
	var w =size(self).x+2*pad_h
	var h = text.get_content_height ( )+ 2*pad_v
	text.position.y+=.5*pad_v
	var size = Vector2(w, h)
	box.set_size(size)
	box.position.x-=pad_h*.5
	var screen_width = get_viewport_rect().size.x
	
	return size
	
func size(control: Control):
	var size = control.get_rect().size
	return size

func init(t: String):
	text.text = format_text(t)
	box =$Box
	text =$Text
	return adjust_size()

func format_text(t: String):
	return "[center]"+t+"[/center]"

func add_visible_character():
	text.visible_characters+=1

func show_all_characters():
	text.visible_characters = -1
