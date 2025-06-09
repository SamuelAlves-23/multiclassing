extends Node

@onready var pickup_node: PackedScene = preload("res://equipment/pickup.tscn")

@onready var player_amount: int

func go_to_scene(new_scene: String) -> void:
	get_tree().change_scene_to_file(new_scene)
