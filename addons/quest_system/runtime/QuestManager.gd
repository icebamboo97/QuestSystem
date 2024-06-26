extends Node

signal quest_accepted(quest: QuestData) # Emitted when a quest gets moved to the ActivePool
signal quest_completed(quest: QuestData) # Emitted when a quest gets moved to the CompletedPool
signal new_available_quest(quest: QuestData) # Emitted when a quest gets added to the AvailablePool
signal quest_updated(quest: QuestData, step_id : Variant) # Emitted when a quest gets added to the AvailablePool

const AvailableQuestPool = preload("./AvailableQuestPool.gd")
const ActiveQuestPool = preload("./ActiveQuestPool.gd")
const CompletedQuestPool = preload("./CompletedQuestPool.gd")

var available: AvailableQuestPool = AvailableQuestPool.new("Available")
var active: ActiveQuestPool = ActiveQuestPool.new("Active")
var completed: CompletedQuestPool = CompletedQuestPool.new("Completed")

var debug = false

var _quest_parser : QuestParser

var curr_quest : QuestData

func _init() -> void:
	debug = QuestSystemSettings.get_config_setting("debug")
	
	add_child(available)
	add_child(active)
	add_child(completed)
	
	_quest_parser = QuestParser.new()
	add_child(_quest_parser)

# Quest API

func start_quest(quest: QuestData) -> QuestData:
	assert(quest != null)

	if active.is_quest_inside(quest):
		return quest
	if completed.is_quest_inside(quest): #Throw an error?
		return quest

	#Add the quest to the actives quests
	available.remove_quest(quest)
	active.add_quest(quest)
	quest_accepted.emit(quest)

	quest.start()

	return quest

func set_quest_step_state(quest: QuestData, state : QuestStepNode.StepState):
	assert(quest != null)

	if not active.is_quest_inside(quest):
		return quest

	#把当前节点设置完成
	curr_quest = quest
	_quest_parser.data = quest
	_quest_parser.step_processed_runtime.connect(step_processed_runtime)
	_quest_parser.start()

	# TODO:应该调整，但是问题不大
	quest_updated.emit(quest, quest.curr_step_id)
	quest.update()

func step_processed_runtime(step_name : Variant, step_state : QuestStepNode.StepState, step_id : Variant):
	if step_state == QuestStepNode.StepState.Available:
		curr_quest.curr_step_id = step_id
		curr_quest.nodes[step_id]['step_state'] = QuestStepNode.StepState.Successed
		_quest_parser.stop()
		_quest_parser.step_processed_runtime.disconnect(step_processed_runtime)

		if curr_quest.nodes[step_id]['options'][0]['link'] == 'END':
			complete_quest(curr_quest)
	else :
		_quest_parser.select_option(0)
	
func complete_quest(quest: QuestData) -> QuestData:
	if not active.is_quest_inside(quest):
		return quest
	print(quest.quest_name, "is done!")
	#if quest.objective_completed == false and QuestSystemSettings.get_config_setting("require_objective_completed"):
		#return quest

	quest.complete()

	active.remove_quest(quest)
	completed.add_quest(quest)

	quest_completed.emit(quest)

	return quest


func mark_quest_as_available(quest: QuestData) -> void:
	if debug:
		print(quest.quest_name)
	
	if available.is_quest_inside(quest) or completed.is_quest_inside(quest) or active.is_quest_inside(quest):
		if debug:
			print(quest.quest_name + "available failed.")
		return

	if debug:
		print(quest.quest_name + "is available.")
	available.add_quest(quest)
	new_available_quest.emit(quest)


func get_available_quests() -> Array[QuestData]:
	return available.quests

func get_active_quests() -> Array[QuestData]:
	return active.quests

func get_completed_quests() -> Array[QuestData]:
	return completed.quests

func get_all_pools() -> Array[BaseQuestPool]:
	var all_pools : Array[BaseQuestPool]
	all_pools.append(available)
	all_pools.append(active)
	all_pools.append(completed)
	return all_pools

func is_quest_available(quest: QuestData) -> bool:
	if not (active.is_quest_inside(quest) or completed.is_quest_inside(quest)):
		return true
	return false

func is_quest_active(quest: QuestData) -> bool:
	if active.is_quest_inside(quest):
		return true
	return false

func is_quest_completed(quest: QuestData) -> bool:
	if completed.is_quest_inside(quest):
		return true
	return false

func is_quest_in_pool(quest: QuestData, pool_name: String) -> bool:
	if pool_name.is_empty():
		for pool in get_children():
			if pool.is_quest_inside(quest): return true
		return false

	var pool := get_node(pool_name)
	if pool.is_quest_inside(quest): return true
	return false


func call_quest_method(quest_id: int, method: String, args: Array) -> void:
	var quest: QuestData = null

	# Find the quest if present
	for pools in get_children():
		if pools.get_quest_from_id(quest_id) != null:
			quest = pools.get_quest_from_id(quest_id)
			break

	# Make sure we've got the quest
	if quest == null: return

	if quest.has_method(method):
		quest.callv(method, args)


func set_quest_property(quest_id: int, property: String, value: Variant) -> void:
	var quest: QuestData = null

	# Find the quest
	for pools in get_children():
		if pools.get_quest_from_id(quest_id) != null:
			quest = pools.get_quest_from_id(quest_id)

	if quest == null: return

	# Now check if the quest has the property

	# First if the property is null -> we return
	if property == null: return

	var was_property_found: bool = false
	# Then we check if the property is present
	for p in quest.get_property_list():
		if p.name == property:
			was_property_found = true
			break

	# Return if the property was not found
	if not was_property_found: return

	# Finally we set the value
	quest.set(property, value)

# Manager API

func add_new_pool(pool_path: String, pool_name: String) -> void:
	var pool = load(pool_path)
	if pool == null: return

	var pool_instance = pool.new(pool_name)

	# Make sure the pool does not exist yet
	for pools in get_children():
		if pool_instance.get_script() == pools.get_script():
			return

	add_child(pool_instance)


func move_quest_to_pool(quest: QuestData, old_pool: String, new_pool: String) -> QuestData:
	if old_pool == new_pool: return

	var old_pool_instance: BaseQuestPool = get_node_or_null(old_pool)
	var new_pool_instance: BaseQuestPool = get_node_or_null(new_pool)

	assert(old_pool_instance != null or new_pool_instance != null)

	old_pool_instance.quests.erase(quest)
	new_pool_instance.quests.append(quest)

	return quest


func reset_pool(pool_name: String) -> void:
	if pool_name.is_empty():
		for pool in get_children():
			pool.reset()
		return

	var pool := get_node(pool_name)
	pool.reset()
	return


func quests_as_dict() -> Dictionary:
	var quest_dict: Dictionary = {}

	for pool in get_children():
		quest_dict[pool.name.to_lower()] = pool.get_ids_from_quests()

	return quest_dict

func dict_to_quests(dict: Dictionary, quests: Array[QuestData]) -> void:
	for pool in get_children():

		# Make sure to iterate only for available pools
		if !dict.has(pool.name.to_lower()): continue

		# Match quest with their ids and insert them into the quest pool
		var quest_with_id: Dictionary = {}
		var pool_ids: Array[int]
		pool_ids.append_array(dict[pool.name.to_lower()])
		for quest in quests:
			if quest.id in pool_ids:
				pool.add_quest(quest)
				quests.erase(quest)


func serialize_quests(pool: String) -> Dictionary:
	var pool_node: BaseQuestPool = get_node_or_null(pool)

	if pool_node == null: return {}

	var quest_dictionary: Dictionary = {}
	for quests in pool_node.quests:
		var quest_data: Dictionary
		for name in quests.get_script().get_script_property_list():

			# Filter only defined properties
			if name.usage & PROPERTY_USAGE_STORAGE or name.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				quest_data[name["name"]] = quests.get(name["name"])

		quest_data.erase("id")
		quest_dictionary[quests.id] = quest_data

	return quest_dictionary
