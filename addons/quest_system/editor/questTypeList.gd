@tool
extends Control

signal modified
signal global_quest_data_updated(global_quest_data : GlobalQuestData)

@export var editor_path: NodePath

@onready var file_path: TextEdit = $Path
@onready var load_button: Button = $LoadButton
@onready var file_dialog: FileDialog = $FileDialog
@onready var quest_type = $"../../Workspace/SidePanel/Data/QuestType"

var editor
var last_file_path : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	editor = get_node(editor_path)

func load_data(path : String):
	if path != file_path.text:
		file_path.text = path
	last_file_path = path
	
	var resource : Resource
	var quest_type_list : Array[QuestTypeData] = []
	if path.ends_with('.tres') and ResourceLoader.exists(path):
		resource = ResourceLoader.load(path, '', ResourceLoader.CACHE_MODE_REPLACE)
		if resource is GlobalQuestData:
			quest_type_list = resource.quest_type_list
			
	quest_type._on_quest_type_updated(quest_type_list)
			
	if editor._debug:
		print('Global quest data set: ', path)
		if path.ends_with('.tres'):
			if resource is GlobalQuestData:
				print('Loaded quest type:', quest_type_list)
			else:
				printerr('Selected file is not a GlobalQuestData resource')

func _on_load_button_pressed() -> void:
	file_dialog.popup_centered()


func _on_path_text_changed() -> void:
	if not editor.undo_redo:
		load_data(file_path.text)
		return
	
	editor.undo_redo.create_action('Set global quest data path')
	editor.undo_redo.add_do_method(self, 'load_data', file_path.text)
	editor.undo_redo.add_do_method(self, '_on_modified')
	editor.undo_redo.add_undo_method(self, '_on_modified')
	editor.undo_redo.add_undo_method(self, 'load_data', last_file_path)
	editor.undo_redo.commit_action()

func _on_file_dialog_file_selected(path: String) -> void:
	if not editor.undo_redo:
		load_data(path)
		return
	
	editor.undo_redo.create_action('Set global quest data path')
	editor.undo_redo.add_do_method(self, 'load_data', path)
	editor.undo_redo.add_do_method(self, '_on_modified')
	editor.undo_redo.add_undo_method(self, '_on_modified')
	editor.undo_redo.add_undo_method(self, 'load_data', file_path.text)
	editor.undo_redo.commit_action()

func _on_modified():
	modified.emit()
