extends Node2D

@onready var spawn_points = [$Spawn1, $Spawn2, $Spawn3, $Spawn4]
@export var player_scene: PackedScene = preload("res://player/player.tscn")

func _ready() -> void:
	var joypads = Input.get_connected_joypads()
	var player_count = 2
	
	for i in range(player_count):
		var player: Player = player_scene.instantiate()
		player.player_id = i + 1
		player.global_position = spawn_points[i].global_position
		
		if i == 0:
			player.input_mode = player.InputMode.KEYBOARD
		else:
			player.input_mode = player.InputMode.GAMEPAD
			player.device_id = joypads[i - 1]
		add_child(player)
