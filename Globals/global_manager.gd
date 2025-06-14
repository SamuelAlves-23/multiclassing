extends Node

@onready var pickup_node: PackedScene = preload("res://equipment/pickup.tscn")
@onready var player_node: PackedScene = preload("res://player/player.tscn")
@onready var arenas_dir: String = "res://arenas/combat_arenas/arena_scenes/"
@onready var player_amount: int

@onready var player_list: Array = []
@onready var arena_selection: Array = []
@export var player_max: int = 4
@export var rounds: int = 3

var current_area

func go_to_scene(new_scene: String) -> void:
	get_tree().change_scene_to_file(new_scene)


func is_device_joined(device_id) -> bool:
	for p in player_list:
		if typeof(p.device_id) == typeof(device_id) and p.device_id == device_id:
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
	player_instance.add_to_group("Players")
	current_area.add_child(player_instance)

func remove_player(device_id):
	for i in range(player_list.size()):
		var p = player_list[i]
		if typeof(p.device_id) == typeof(device_id) and p.device_id == device_id:
			player_list.remove_at(i)
			print("Jugador removido correctamente:", p.device_id)
			return
	print("Ningún jugador encontrado con device_id:", device_id)


func remove_player_node(device_id):
	for player in get_tree().get_nodes_in_group("Players"):
		if typeof(player.device_id) == typeof(device_id) and player.device_id == device_id:
			player.queue_free()
			print("Nodo del jugador eliminado:", player.device_id)
			return
	print("No se encontró nodo Player con device_id:", device_id)

func pick_arenas():
	var arenas: Array = DirAccess.open(arenas_dir).get_files()
	for i in range(rounds):
		var new_arena: String = arenas_dir + arenas.pick_random()
		
		arena_selection.append(new_arena)
