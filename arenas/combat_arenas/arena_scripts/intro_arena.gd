extends Node2D

@onready var spawners: Array = $Spawners.get_children()

func _ready() -> void:
	GlobalManager.current_area = self
	for player in GlobalManager.player_list:
		GlobalManager.spawn_player(player, spawners.pick_random().global_position) 
