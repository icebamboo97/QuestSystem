@tool
extends Control

@export var editor_path: NodePath

@onready var quest_type_option_button: OptionButton = $QuestTypeOptionButton

var cur_quest_type
var editor

func _ready():
	editor = get_node(editor_path)
	
func _on_quest_type_updated(quest_type_list : Array[QuestTypeData]):
	quest_type_option_button.clear()
	
	for quest_type in quest_type_list:
		quest_type_option_button.add_item(quest_type.name)
	
	if quest_type_list.size() > 0:
		if cur_quest_type > quest_type_list.size():
			cur_quest_type = 0
		quest_type_option_button.select(cur_quest_type)
	else:
		quest_type_option_button.select(-1)
		
	if editor._debug:
		print('Quest type size :',quest_type_option_button.size )
