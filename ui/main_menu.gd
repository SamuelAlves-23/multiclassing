extends Control

@onready var mode_container: VBoxContainer = $ModeContainer
@onready var local_container: VBoxContainer = $LocalPlayersContainer
@onready var local_player_amount: LineEdit = $LocalPlayersContainer/PlayerAmountEdit


func _on_local_button_pressed() -> void:
	mode_container.hide()
	local_container.show()


func _on_local_back_button_pressed() -> void:
	local_container.hide()
	mode_container.show()


func _on_local_play_button_pressed() -> void:
	if local_player_amount.text:
		GlobalManager.player_amount = local_player_amount.text.to_int()
		GlobalManager.go_to_scene("res://Arenas/arena.tscn")
	else:
		print("Es necesario ingresar número de jugadores")
