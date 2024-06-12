@tool
extends Control

signal modified
signal name_updated(name : String)

@onready var quest_name_line: LineEdit = $QuestNameLine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_data():
	return quest_name_line.text
	
func load_data(name : String):
	quest_name_line.text = name

func _on_quest_name_line_text_changed(new_text: String) -> void:
	modified.emit()
