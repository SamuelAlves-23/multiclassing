extends Ability


@onready var barrier_item = preload("res://equipment/ability_items/barrier_item.tscn")


func effect():
	print("CREANDO BARRERA")
	
	var barrier_instance = barrier_item.instantiate()
	add_child(barrier_instance)
	
	
