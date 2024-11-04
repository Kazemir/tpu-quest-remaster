extends BTAction

@export var range_min_in_dir: float = 40.0
@export var range_max_in_dir: float = 100.0

@export var position_var: StringName = &"pos"
@export var dir_var: StringName = &"dir"

func _tick(_delta: float) -> Status:
	var pos: Vector2
	var dir = random_dir()

	pos = random_pos(dir)
	blackboard.set_var(position_var, pos)

	return SUCCESS

func random_pos(dir):
	var vector: Vector2
	var distance = randi_range(range_min_in_dir, range_max_in_dir) * dir
	var final_position = (distance + agent.global_position.x)
	vector.x = final_position
	return vector

func random_dir():
	var dir = randi_range(-2, 1)
	if abs(dir) != dir:
		dir = -1
	else:
		dir = 1
	blackboard.set_var(dir_var, dir)
	return dir
