extends Panel
class_name QuestItem

signal selected(quest_data : QuestData)

@onready var title_label = $TitlePanel/TitleLabel
@onready var description_lable = $DescriptionPanel/DescriptionLable

var quest_data : QuestData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_quest_name(quest_name : String):
	title_label = $TitlePanel/TitleLabel
	title_label.text = quest_name
	
func set_description_name(quest_description : String):
	description_lable = $DescriptionPanel/DescriptionLable
	description_lable.text = quest_description

func set_quest_data(new_quest_data : QuestData):
	quest_data = new_quest_data
	set_description_name(quest_data.quest_description)
	set_quest_name(quest_data.quest_name)

func _on_button_pressed() -> void:
	selected.emit(quest_data)
