extends Node2D

@onready var local_entrance: Area2D = $LocalEntrance
@onready var online_entrance: Area2D = $OnlineEntrance
@onready var intro_label: Label = $CanvasLayer/Control/IntroLabel
@onready var spawn_point: Marker2D = $SpawnPoint

@onready var allow_join:bool = false
@onready var started: bool = false

func _ready() -> void:
	GlobalManager.current_area = self
	await get_tree().create_timer(0.5).timeout
	allow_join = true

func _unhandled_input(event: InputEvent) -> void:
	if !started and allow_join:
		if event is InputEventJoypadMotion:
			return
		if event  is InputEventJoypadButton and event.pressed:
			var device_id = event.device
			if !GlobalManager.is_device_joined(device_id):
				GlobalManager.join_player("gamepad", device_id)
				started = true
				intro_label.hide()
				GlobalManager.spawn_player(GlobalManager.player_list[0], spawn_point.global_position)

		elif event is InputEventKey and event.pressed:
			if !GlobalManager.is_device_joined("keyboard"):
				GlobalManager.join_player("keyboard", "keyboard")
				started = true
				intro_label.hide()
				GlobalManager.spawn_player(GlobalManager.player_list[0], spawn_point.global_position)

		

func _on_local_entrance_body_entered(body: Node2D) -> void:
	if body is Player:
		GlobalManager.go_to_scene("res://arenas/local_lobby.tscn")
