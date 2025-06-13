extends Node2D

@onready var exit_area: Area2D = $ExitArea
@onready var ready_area: Area2D = $ReadyArea
@onready var spawn_point: Marker2D = $Marker2D


func _ready() -> void:
	if !GlobalManager.player_list.is_empty():
		GlobalManager.player_list.get(0)
		pass
	pass
