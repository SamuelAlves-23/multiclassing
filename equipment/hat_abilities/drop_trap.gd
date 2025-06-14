extends Ability

@export var trap_node: PackedScene = preload("res://equipment/ability_items/trap_item.tscn")
@export var impulse: float = 50

@onready var trap_references: Array = []

func effect():
	print("SOLTANDO TRAMPA")
	var trap_instance = trap_node.instantiate()
	trap_references.append(trap_instance)
	if trap_references.size() >= 4:
		var oldest_trap = trap_references.pop_front()
		oldest_trap.queue_free()
	trap_instance.global_position = get_parent().global_position
	trap_instance.connect("destroyed", erase_reference)
	GlobalManager.current_area.add_child(trap_instance)
	get_parent().player_owner.back_dash(impulse)
	
func erase_reference(trap):
	trap_references.erase(trap)
