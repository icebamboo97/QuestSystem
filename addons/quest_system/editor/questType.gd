@tool
extends Control

@onready var quest_type_option_button: OptionButton = $QuestTypeOptionButton

func _on_quest_type_updated(quest_type_list : Array[QuestTypeData]):
	quest_type_option_button.clear()
	#
	#for character in character_list:
		#quest_type_option_button.add_item(character.name)
	#
	#if character_list.size() > 0:
		#if cur_speaker > character_list.size():
			#cur_speaker = 0
		#quest_type_option_button.select(cur_speaker)
	#else:
		#quest_type_option_button.select(-1)
