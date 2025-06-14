extends Node

@onready var pickup_node: PackedScene = preload("res://equipment/pickup.tscn")
@onready var player_node: PackedScene = preload("res://player/player.tscn")
@onready var player_amount: int

@onready var player_list: Array = []
@export var player_max: int = 4

var current_area

func go_to_scene(new_scene: String) -> void:
	get_tree().change_scene_to_file(new_scene)


func is_deviced_joined(device_id) -> bool:
	for player in player_list:
		if device_id == device_id:
			return true
	return false

func join_player(input_mode: String, device_id):
	var player_data = {
		"input_mode": input_mode,
		"device_id": device_id
	}
	player_list.append(player_data)


func spawn_player(player, position: Vector2):
	var player_instance : Player = player_node.instantiate()
	player_instance.input_mode = player.input_mode
	player_instance.device_id = player.device_id
	player_instance.global_position = position
	current_area.add_child(player_instance)
