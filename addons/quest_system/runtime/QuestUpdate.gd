class_name QuestUpdate
extends Node

@export_group('Data')
## Contains the [param QuestData] resource created using the Quest Nodes editor.
@export var data : QuestData :
	get:
		return data
	set(value):
		data = value
		
## The default start ID to begin quest from. This is the value you set in the Quest Nodes editor.
@export_group('Options')

@export_enum('Start', 'Update', 'Complete') var options_quest_state := 0 :
	set(value):
		options_quest_state = value

var _deal_quest_callable = Callable(self, "_deal_quest")

func _enter_tree():
	print("Clear child of quest update.")
	if get_child_count() > 0:
		for child in get_children():
			remove_child(child)
			child.queue_free()


func _ready():
	pass
	
func _deal_quest():
	match options_quest_state:
		0:
			pass
		1:
			pass
		2:
			pass 
	
#func set_curr_quest_state(state : QuestStepNode.StepState):
	#pass
	#通过唯一ID查找QuestManager中的任务，调整选中的任务状态

func test():
	_deal_quest_callable.call()
