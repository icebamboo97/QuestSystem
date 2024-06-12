@tool
extends Control

signal modified
signal description_updated(name : String)

@onready var description_text: TextEdit = $DescriptionText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_data():
	return description_text.text
	
func load_data(name : String):
	description_text.text = name

func _on_description_text_text_changed() -> void:
	modified.emit()
