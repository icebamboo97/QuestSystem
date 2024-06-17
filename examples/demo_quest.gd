extends Control

@export var demo_quests: Array[QuestData]

const QUEST_ITEM_PANEL = preload("res://examples/quest_item_panel.tscn")

@onready var available_quest_pool: VBoxContainer = $HSplitContainer/Panel/VBoxContainer2/ScrollContainer/AvailableQuestPool
@onready var active_quest_pool: VBoxContainer = $HSplitContainer/Panel/VBoxContainer2/ScrollContainer3/ActiveQuestPool
@onready var completed_quest_pool: VBoxContainer = $HSplitContainer/Panel/VBoxContainer2/ScrollContainer2/CompletedQuestPool

var available_quests : Array[QuestData]
var active_quests : Array[QuestData]
var complete_quests : Array[QuestData]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for demo_quest in demo_quests:
		QuestManager.mark_quest_as_available(demo_quest) 
	
	QuestManager.new_available_quest.connect(update_ui)
	QuestManager.quest_accepted.connect(update_ui)
	QuestManager.quest_completed.connect(update_ui)
	update_ui()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print(available_quests.size())

func update_ui():
	available_quests = QuestManager.get_available_quests()
	available_quests = QuestManager.get_active_quests()
	complete_quests = QuestManager.get_completed_quests()
	
	if available_quests.size() > 0:
		for quest_data in available_quests:
			var quest_item = QUEST_ITEM_PANEL.instantiate()
			quest_item.set_quest_name(quest_data.quest_name)
			quest_item.set_description_name(quest_data.quest_description)
			available_quest_pool.add_child(quest_item)
	
	if active_quests.size() > 0:
		for quest_data in active_quests:
			var quest_item = QUEST_ITEM_PANEL.instantiate()
			quest_item.set_quest_name(quest_data.quest_name)
			quest_item.set_description_name(quest_data.quest_description)
			active_quest_pool.add_child(quest_item)
			
	if complete_quests.size() > 0:
		for quest_data in complete_quests:
			var quest_item = QUEST_ITEM_PANEL.instantiate()
			quest_item.set_quest_name(quest_data.quest_name)
			quest_item.set_description_name(quest_data.quest_description)
			completed_quest_pool.add_child(quest_item)
