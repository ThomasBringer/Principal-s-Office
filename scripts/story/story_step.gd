class_name StoryStep extends Resource

@export var events: Array[StoryEvent]
@export_multiline var dialogs: Array[String]
@export var redirect_immediate: int = -1
@export var choices: Array[StoryChoice]
