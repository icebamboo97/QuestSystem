@tool
extends Control

signal modified
signal details_updated(quest_name : String)

@onready var quest_name = $QuestName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_name_data():
	return quest_name.text
	
func load_data(name : String):
	quest_name.text = name
	
func _on_quest_name_text_changed():
	modified.emit()
