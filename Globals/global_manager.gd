extends Node

@onready var pickup_node: PackedScene = preload("res://equipment/pickup.tscn")

@onready var player_amount: int

@onready var player_list: Array = []
@export var player_max: int = 4

func go_to_scene(new_scene: String) -> void:
	get_tree().change_scene_to_file(new_scene)
