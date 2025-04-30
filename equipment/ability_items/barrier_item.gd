extends Node2D

signal hit_blocked
signal disapeared

@export var duration: int = 2

#@onready var player_owner: Player

func _process(delta: float) -> void:
	await get_tree().create_timer(duration).timeout
	disapear()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		area.collision.disabled
		hit_blocked.emit()
		disapear()

func disapear():
	disapeared.emit()
	queue_free()
