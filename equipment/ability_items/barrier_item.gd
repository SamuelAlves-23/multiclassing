extends Node2D

signal hit_blocked

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		hit_blocked.emit()
		queue_free()
