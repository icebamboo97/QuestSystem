extends Control

@export var demo_quests: Array[QuestData]

var QUEST_ITEM_PANEL = preload("res://examples/quest_item_panel.tscn")

@onready var available_quest_pool: VBoxContainer = $HSplitContainer/Panel/VBoxContainer2/ScrollContainer/AvailableQuestPool
@onready var active_quest_pool: VBoxContainer = $HSplitContainer/Panel/VBoxContainer2/ScrollContainer3/ActiveQuestPool
@onready var completed_quest_pool: VBoxContainer = $HSplitContainer/Panel/VBoxContainer2/ScrollContainer2/CompletedQuestPool

@onready var quest_operation = %QuestOperation

@onready var rich_text_label = %RichTextLabel

var available_quests : Array[QuestData]
var active_quests : Array[QuestData]
var complete_quests : Array[QuestData]

var _quest_parser : QuestParser

var item_dic : Dictionary

var cur_selected_quest_data
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_quest_parser = QuestParser.new()
	add_child(_quest_parser)
	
	for demo_quest in demo_quests:
		QuestManager.mark_quest_as_available(demo_quest) 
	
	QuestManager.new_available_quest.connect(update_item_new_available_quest)
	QuestManager.quest_accepted.connect(update_item_quest_accepted)
	QuestManager.quest_completed.connect(update_item_quest_completed)
	init_ui()
	quest_operation.hide()

func init_ui():
	available_quests = QuestManager.get_available_quests()
	active_quests = QuestManager.get_active_quests()
	complete_quests = QuestManager.get_completed_quests()
	
	if available_quests.size() > 0:
		for quest_data in available_quests:
			available_quest_pool.add_child(create_quest_item(quest_data))
		
	if active_quests.size() > 0:
		for quest_data in active_quests:
			active_quest_pool.add_child(create_quest_item(quest_data))
			
	if complete_quests.size() > 0:
		for quest_data in complete_quests:
			completed_quest_pool.add_child(create_quest_item(quest_data))

func update_item_new_available_quest(quest_data : QuestData):
	var quest_item = QUEST_ITEM_PANEL.instantiate()
	quest_item.set_quest_name(quest_data.quest_name)
	quest_item.set_description_name(quest_data.quest_description)
	available_quest_pool.add_child(quest_item)
	item_dic[quest_data] = quest_item

func update_item_quest_accepted(quest_data : QuestData):
	var quest_item = item_dic[quest_data]
	quest_item.reparent(active_quest_pool)
	
func update_item_quest_completed(quest_data : QuestData):
	var quest_item = item_dic[quest_data]
	quest_item.reparent(active_quest_pool)

func create_quest_item(quest_data) -> Node:
	var quest_item = QUEST_ITEM_PANEL.instantiate()
	quest_item.set_quest_data(quest_data)
	item_dic[quest_data] = quest_item
	quest_item.selected.connect(select_quest_item)
	return quest_item
	
func select_quest_item(quest_data : QuestData):
	#TODO: 把任务更新到curr step
	rich_text_label.clear()
	_quest_parser.data = quest_data

	_quest_parser.step_processed.connect(_on_step_processed)
	_quest_parser.parse_ended.connect(_on_parse_ended)
	
	_quest_parser.start()
	
	rich_text_label.add_text(quest_data.quest_name)
	rich_text_label.add_text(quest_data.quest_description)
	
	cur_selected_quest_data = quest_data
	quest_operation.show()

func _on_step_processed(speaker : Variant, dialogue : String, options : Array[String]):
	# set step name
	if speaker is String:
		rich_text_label.add_text('\n')
		rich_text_label.add_text(speaker)
	
	# set description
	rich_text_label.add_text('\n')
	rich_text_label.add_text(dialogue)
	

func _on_parse_ended():
	_quest_parser.step_processed.disconnect(_on_step_processed)
	_quest_parser.parse_ended.disconnect(_on_parse_ended)

## Test
func _on_timer_timeout():
	pass
	#if available_quests.size() >0:
		#QuestManager.start_quest(available_quests[0])
	#if active_quests.size() > 1:
		#QuestManager.complete_quest(active_quests[1])

func _on_start_button_pressed():
	QuestManager.start_quest(cur_selected_quest_data)

func _on_update_button_pressed():
	#if not _quest_parser: return
	#_quest_parser.select_option(0)
	QuestManager.set_quest_step_state(cur_selected_quest_data, QuestStepNode.StepState.Successed)
	
	select_quest_item(cur_selected_quest_data)
