extends Ability

@onready var barrier_item = preload("res://equipment/ability_items/barrier_item.tscn")

func effect():
	var barrier_instance = barrier_item.instantiate()
	#barrier_instance.position = self.position
	
	
