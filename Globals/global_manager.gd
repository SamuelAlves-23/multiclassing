extends Node

@onready var pickup_node: PackedScene = preload("res://equipment/pickup.tscn")
@onready var player_node: PackedScene = preload("res://player/player.tscn")
@onready var podium: String = "res://arenas/podium.tscn"
@onready var arenas_dir: String = "res://arenas/combat_arenas/arena_scenes/"
@onready var player_amount: int

@onready var player_list: Array = []
@onready var arena_selection: Array = []
@export var player_max: int = 4
@export var rounds: int = 3

var current_area
var remaining_players: int

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
		"device_id": device_id,
		"score": 0,
		"alive": true
	}
	player_list.append(player_data)


func spawn_player(player, position: Vector2):
	var player_instance : Player = player_node.instantiate()
	player_instance.died.connect(player_died)
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
	reset_scores()
	var arenas: Array = DirAccess.open(arenas_dir).get_files()
	for i in range(rounds):
		var new_arena: String = arenas_dir + arenas.pick_random()
		arena_selection.append(new_arena)

func reset_scores():
	for player in player_list:
		player.score = 0

func player_died(device_id):
	score_points(device_id)
	remaining_players -=1
	if remaining_players == 1:
		for player in player_list:
			if player.alive:
				score_points(player.device_id)
		next_arena()

func next_arena():
	if arena_selection.size() != 0:
		for player in player_list:
			player.alive = true
		MusicManager.change_music_battle()
		go_to_scene(arena_selection.pop_front())
		remaining_players = player_list.size()
		return
	print("RANKING FINAL")
	player_list.sort_custom(Callable(self, "_sort_by_score"))
	for i in range(player_list.size()):
		var p = player_list[i]
		print("%dº - Player %s (%s) - %d puntos" % [i + 1, str(p.device_id), p.input_mode, p.score])
	MusicManager.change_music_lobby()
	go_to_scene(podium)
		
func _sort_by_score(a, b):
	return b["score"] - a["score"]

func score_points(device_id):
	for player in player_list:
		if typeof(player.device_id) == typeof(device_id) and player.device_id == device_id:
			player.score += (player_list.size() - remaining_players)
			player.alive = false
			return
