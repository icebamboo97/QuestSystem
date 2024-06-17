@tool
## A node for update quest status, copy form DialogueBox
## TODO:Use in gameplay，Need:satrt quest, push quest, Complete quest

class_name QuestUpdate
extends Node

@export_group('Data')
## Contains the [param QuestData] resource created using the Quest Nodes editor.
@export var data : QuestData :
	get:
		return data
	set(value):
		data = value
		if _quest_parser:
			_quest_parser.data = value
			variables = _quest_parser.variables
			characters = _quest_parser.characters
## The default start ID to begin quest from. This is the value you set in the Quest Nodes editor.
@export var start_id : String = "START"

@export_group('Quest')
## Speed of scroll when using joystick/keyboard input
@export var scroll_speed := 4
## Input action used to skip quest animation
@export var skip_input_action := 'ui_cancel'
## Custom RichTextEffects that can be used in the quest as bbcodes.[br]
## Example: [code][ghost]Spooky quest![/ghost][/code]
@export var custom_effects : Array[RichTextEffect] = [
	RichTextWait.new(),
	RichTextGhost.new(),
	RichTextMatrix.new()
	]

@export_group('Options')
## The maximum number of options to show in the quest box.
@export var max_options_count := 4 :
	get:
		return max_options_count
	set(value):
		max_options_count = max(value, 1)
		
		if options_container:
			# clear all options
			for option in options_container.get_children():
				options_container.remove_child(option)
				option.queue_free()
		
			for idx in range(max_options_count):
				var button = Button.new()
				options_container.add_child(button)
				button.text = 'Option '+str(idx+1)
				button.pressed.connect(select_option.bind(idx))
## Icon displayed when no text options are available.
@export var next_icon := preload('res://addons/quest_system/icons/Play.svg')
## Alignment of options.
@export_enum('Begin', 'Center', 'End') var options_alignment := 2 :
	set(value):
		options_alignment = value
		if options_container:
			options_container.alignment = options_alignment
## Orientation of options.
@export var options_vertical := false :
	set(value):
		options_vertical = value
		if options_container:
			options_container.vertical = options_vertical
## Position of options along the quest box.
@export_enum('Top', 'Left', 'Right', 'Bottom') var options_position := 3 :
	set(value):
		options_position = value
		if not options_container: return
		if not _main_container: return
		if not _sub_container: return
		
		options_container.get_parent().remove_child(options_container)
		match value:
			0:
				# top
				_sub_container.add_child(options_container)
				_sub_container.move_child(options_container, 0)
			3:
				# bottom
				_sub_container.add_child(options_container)
			1:
				# left
				_main_container.add_child(options_container)
				_main_container.move_child(options_container, 0)
			2:
				# right
				_main_container.add_child(options_container)

@export_group('Misc')
## Hide quest box at the end of a quest
@export var hide_on_quest_end := true

## Contains the variable data from the [param QuestData] parsed in an easy to access dictionary.[br]
## Example: [code]{ "COINS": 10, "NAME": "Obama", "ALIVE": true }[/code]
var variables : Dictionary
## Contains all the [param Character] resources loaded from the path in the [member data].
var characters : Array[Character]
## Displays the portrait image of the speaker in the [QuestBox]. Access the speaker's texture by [member QuestBox.portrait.texture]. This value is automatically set while running a quest tree.
var portrait : TextureRect
## Displays the name of the speaker in the [QuestBox]. Access the speaker name by [code]QuestBox.speaker_label.text[/code]. This value is automatically set while running a quest tree.
var speaker_label : Label
## Displays the quest text. This node's value is automatically set while running a quest tree.
var quest_label : RichTextLabel
## Contains all the option buttons. The currently displayed options are visible while the rest are hidden. This value is automatically set while running a quest tree.
var options_container : BoxContainer

# [param QuestParser] used for parsing the quest [member data].
# NOTE: Using [param QuestParser] as a child instead of extending from it, because [QuestBox] needs to extend from [Panel].
var _quest_parser : QuestParser
var _main_container : BoxContainer
var _sub_container : BoxContainer
var _wait_effect : RichTextWait


func _enter_tree():
	if get_child_count() > 0:
		for child in get_children():
			remove_child(child)
			child.queue_free()
	
	_quest_parser = QuestParser.new()
	add_child(_quest_parser)
	_quest_parser.data = data
	variables = _quest_parser.variables
	characters = _quest_parser.characters
	
	_quest_parser.quest_started.connect(_on_quest_started)
	_quest_parser.quest_processed.connect(_on_quest_processed)



func _ready():
	for effect in custom_effects:
		if effect is RichTextWait:
			_wait_effect = effect
			_wait_effect.wait_finished.connect(_on_wait_finished)
			break
	
	if options_container:
		options_alignment = options_alignment
		options_vertical = options_vertical
		options_position = options_position


func _process(delta):
	if not is_running: return
	
	# scrolling for longer quests
	var scroll_amt := 0.0
	if options_vertical:
		scroll_amt = Input.get_axis("ui_left", "ui_right")
	else:
		scroll_amt = Input.get_axis("ui_up", "ui_down")
	
	if scroll_amt:
		quest_label.get_v_scroll_bar().value += int(scroll_amt * scroll_speed)


func _input(event):
	if is_running() and Input.is_action_just_pressed(skip_input_action):
		if _wait_effect:
			_wait_effect.skip = true
		_on_wait_finished()


## Starts processing the quest [member data], starting with the Start Node with its ID set to [param start_id].
func start(id := start_id):
	if not _quest_parser: return
	_quest_parser.start(id)


## Stops processing the quest tree.
func stop():
	if not _quest_parser: return
	_quest_parser.stop()


## Continues processing the quest tree from the node connected to the option at [param idx].
func select_option(idx : int):
	if not _quest_parser: return
	_quest_parser.select_option(idx)


## Returns [code]true[/code] if the [QuestBox] is processing a quest tree.
func is_running():
	return _quest_parser.is_running()


func _on_quest_started(id : String):
	speaker_label.text = ''
	portrait.texture = null
	quest_label.text = ''

func _on_quest_processed(speaker : Variant, quest : String, options : Array[String]):
	# set speaker
	speaker_label.text = ''
	portrait.texture = null

	if speaker is Character:
		speaker_label.text = speaker.name
		speaker_label.modulate = speaker.color
		portrait.texture = speaker.image
		if not speaker.image: portrait.hide()
	elif speaker is String:
		speaker_label.text = speaker
		speaker_label.modulate = Color.WHITE
		portrait.hide()
	
	# set quest
	quest_label.text = _quest_parser._update_wait_tags(quest_label, quest)
	quest_label.get_v_scroll_bar().set_value_no_signal(0)
	for effect in custom_effects:
		if effect is RichTextWait:
			effect.skip = false
			break
	
	# set options
	for idx in range(options_container.get_child_count()):
		var option : Button = options_container.get_child(idx)
		if idx >= options.size():
			option.hide()
			continue
		option.text = options[idx].replace('[br]', '\n')
		option.show()
	options_container.get_child(0).icon = next_icon if options.size() == 1 and options[0] == '' else null
	options_container.hide()

func _on_wait_finished():
	options_container.show()
	options_container.get_child(0).grab_focus()
