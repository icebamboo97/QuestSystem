## Data for processing dialogue through a [param QuestParser].
@icon('res://addons/quest_system/icons/Quest.svg')
class_name QuestData
extends Resource

## Contains the start IDs as keys and their respective node name as values.
## Example: { "START": "0_1" }
@export var starts : Dictionary = {}
## Contains all the data for each node in a dialogue graph with their node names as keys.[br]
## Example: [code]{ "0_1": { "link": "1_1", "offset": Vector2(0, 0), "start_id": "START" } }[/code]
@export var nodes : Dictionary = {}
## Contains the variable data including the variable name, data type and initial value.[br]
## Example: [code]{ "COINS": { "type": TYPE_INT, "value": 10 } }[/code]
@export var variables : Dictionary = {}
## Contains the node names of all the nodes not connected to a dialogue tree
@export var strays : Array[String] = []
## Path to the [param CharacterList] resource file.
@export var characters := ''
## Quest name
@export var quest_name : String = ''
## Quest description
@export var quest_description : String = ''
## Quest type
@export var quest_type : QuestTypeData = null
## Quest id
@export var id : int
## Current Step, use node name
@export var curr_step_id : String = '0_1'

signal started
signal updated
signal completed

#var objective_completed: bool = false:
	#set(value):
		#objective_completed = value
	#get:
		#return objective_completed

func update() -> void:
	updated.emit()

func start() -> void:
	started.emit()

func complete() -> void:
	completed.emit()
