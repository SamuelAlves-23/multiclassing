extends Node2D

@onready var exit_area: Area2D = $ExitArea
@onready var ready_area: Area2D = $ReadyArea
@onready var spawn_point: Marker2D = $SpawnPoint

@onready var ready_players: int = 0

func _ready() -> void:
	GlobalManager.current_area = self

	# Solo spawneamos si ya hay al menos un jugador registrado
	if GlobalManager.player_list.size() > 0:
		GlobalManager.spawn_player(GlobalManager.player_list[0], spawn_point.global_position)

func _on_exit_area_body_entered(body: Node2D) -> void:
	#if body is Player and GlobalManager.player_list.size() == 1:
		#GlobalManager.go_to_scene("res://Arenas/entrance.tscn")
	if body is Player and GlobalManager.player_list.size() != 1:
		GlobalManager.remove_player_node(body.device_id)
		GlobalManager.remove_player(body.device_id)
	
func _unhandled_input(event: InputEvent) -> void:
	if GlobalManager.player_list.size() >= GlobalManager.player_max:
		return

	# Ignoramos movimientos del stick analógico
	if event is InputEventJoypadMotion:
		return

	# 🎮 Gamepad: solo aceptar botón START (u otro específico)
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START:
			var device_id = event.device
			if !GlobalManager.is_device_joined(device_id):
				GlobalManager.join_player("gamepad", device_id)
				GlobalManager.spawn_player(GlobalManager.player_list.back(), spawn_point.global_position)

	# ⌨️ Teclado: unirse con cualquier tecla por ahora
	elif event is InputEventKey and event.pressed:
		if !GlobalManager.is_device_joined("keyboard"):
			GlobalManager.join_player("keyboard", "keyboard")
			GlobalManager.spawn_player(GlobalManager.player_list.back(), spawn_point.global_position)


func _on_ready_area_body_entered(body: Node2D) -> void:
	if body is Player:
		ready_players += 1
		if ready_players == GlobalManager.player_list.size():
			GlobalManager.pick_arenas()
			GlobalManager.next_arena()


func _on_ready_area_body_exited(body: Node2D) -> void:
	if body is Player and ready_players > 0:
		ready_players -= 1
