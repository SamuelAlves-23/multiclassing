extends Node2D

@onready var spawns: Array = $Spawns.get_children()

var ready_players: int = 0

func _ready() -> void:
	GlobalManager.current_area = self
	for i in range(GlobalManager.player_list.size()):
		var player = GlobalManager.player_list[i]
		GlobalManager.spawn_player(player, spawns[i].global_position)


func _on_ready_area_body_entered(body: Node2D) -> void:
	if body is Player:
		ready_players += 1
		if ready_players == GlobalManager.player_list.size():
			GlobalManager.pick_arenas()
			GlobalManager.next_arena()


func _on_ready_area_body_exited(body: Node2D) -> void:
	if body is Player and ready_players > 0:
		ready_players -= 1
