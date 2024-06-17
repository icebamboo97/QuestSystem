extends Panel

@onready var title_label: Label = $TitlePanel/TitleLabel
@onready var description_lable: RichTextLabel = $DescriptionPanel/DescriptionLable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_quest_name(quest_name : String):
	title_label.text = quest_name
	
func set_description_name(quest_description : String):
	description_lable.text = quest_description
