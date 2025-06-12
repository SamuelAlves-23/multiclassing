extends Area2D

@export var trap_time: float = 2

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.paralyze(trap_time)
		queue_free()
