extends Ability

signal barrier_created
@onready var barrier_item = preload("res://equipment/ability_items/barrier_item.tscn")


func effect():
	var parent: Player = get_parent().get_parent().get_parent()
	print("CREANDO BARRERA")
	barrier_created.emit()
	var barrier_instance = barrier_item.instantiate()
	parent.add_child(barrier_instance)
