extends BTAction

@export var target_var = &"target"

@export var speed_var = 60
@export var tolerance = 80

func _tick(_delta) -> Status:
	var target: CharacterBody2D = blackboard.get_var(target_var)
	if target != null:
		var target_position = target.global_position
		var dir = agent.global_position.direction_to(target_position)
		if abs(agent.global_position.x - target_position.x) < tolerance:
			agent.move(dir.x, 0)
			return SUCCESS
		else:
			agent.move(dir.x, speed_var)
			return RUNNING
	return FAILURE
