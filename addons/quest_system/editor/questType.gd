@tool
extends Control

signal modified

@export var editor_path: NodePath

@onready var quest_type_option_button: OptionButton = $QuestTypeOptionButton

var cur_quest_type := -1
var editor
var cur_quest_type_list : Array[QuestTypeData]

func _ready():
	editor = get_node(editor_path)
	
func _on_quest_type_updated(quest_type_list : Array[QuestTypeData]):
	cur_quest_type_list = quest_type_list
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

func get_data():
	if quest_type_option_button.selected == -1:
		printt("The Quest Need select type !")
		return cur_quest_type_list[cur_quest_type]
	else:
		return cur_quest_type_list[quest_type_option_button.selected]
	
func load_data(quest_type : QuestTypeData):
	if editor._debug:
		print('Quest type :',quest_type.name )
	if cur_quest_type_list.has(quest_type):
		quest_type_option_button.select(cur_quest_type_list.find(quest_type))
	else:
		quest_type_option_button.select(-1)
		printt("The quest type doesn't exist anymore")
		
func _on_quest_type_option_button_item_selected(index: int) -> void:
	modified.emit()
