@tool
extends EditorPlugin


const EditorScene = preload('res://addons/quest_system/Editor.tscn')
const DialogueBoxScene = preload('res://addons/quest_system/objects/DialogueBox.gd')
const DialogueBubbleScene = preload('res://addons/quest_system/objects/DialogueBubble.gd')
const DialogueBoxIcon = preload('res://addons/quest_system/icons/DialogueBox.svg')
const DialogueBubbleIcon = preload('res://addons/quest_system/icons/DialogueBubble.svg')

const QuestPropertyTranslationPlugin = preload("./QuestDataTranslationPlugin.gd")

var editor

var translation_plugin: QuestPropertyTranslationPlugin

func _enter_tree():
	editor = EditorScene.instantiate()
	
	# add editor to main viewport
	get_editor_interface().get_editor_main_screen().add_child(editor)
	
	# get undo redo manager
	editor.undo_redo = get_undo_redo()
	
	_make_visible(false)
	
	# add dialogue box and bubble nodes
	add_custom_type(
		'DialogueBox',
		'Panel',
		DialogueBoxScene,
		DialogueBoxIcon)
	add_custom_type(
		'DialogueBubble',
		'RichTextLabel',
		DialogueBubbleScene,
		DialogueBubbleIcon
	)
	
	#Runtime
	add_autoload_singleton("QuestManager", "res://addons/quest_system/runtime/QuestManager.gd")
	
	if Engine.is_editor_hint():
		translation_plugin = QuestPropertyTranslationPlugin.new()
		add_translation_parser_plugin(translation_plugin)
	
	print_debug('Quest System Plugin Enabled')


func _exit_tree():
	# remove from main viewport
	if is_instance_valid(editor):
		editor.queue_free()
	
	remove_custom_type('DialogueBox')
	
	#Runtime
	remove_autoload_singleton("QuestManager")
	remove_translation_parser_plugin(translation_plugin)
	translation_plugin = null
	
	print_debug('Quest System Plugin Disabled')


func _has_main_screen():
	return true


func _make_visible(visible):
	if is_instance_valid(editor):
		editor.visible = visible


func _get_plugin_name():
	return 'Quest'


func _get_plugin_icon():
	return preload('res://addons/quest_system/icons/Quest.svg')


func _handles(object):
	return object is QuestData


func _edit(object):
	if object is QuestData and is_instance_valid(editor):
		editor.files.open_file(object.resource_path)


func _save_external_data():
	if is_instance_valid(editor):
		editor.files.save_all()
