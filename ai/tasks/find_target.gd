extends BTAction

@export var group_var: StringName
@export var target_var: StringName = &"target"

var target: Node = null

func _tick(_delta) -> Status:
	if group_var == "Enemy":
		target = get_enemy_node()
	elif group_var == "Player":
		target = get_player_node()
	if target == null:
		return FAILURE
	print(agent, " has found ", target)
	blackboard.set_var(target_var, target)
	return SUCCESS

func get_enemy_node() -> Node:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group_var)
	nodes.shuffle()
	for node in nodes:
		if agent != node:
			return node
	return null

func get_player_node() -> Node:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group_var)
	if nodes.size() > 0:
		return nodes[0]
	return null
