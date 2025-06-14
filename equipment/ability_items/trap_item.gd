extends Area2D

signal destroyed(trap)

@export var trap_time: float = 2
@export var ready_time: float = 0.5

@onready var active: bool = false


func _ready() -> void:
	await get_tree().create_timer(ready_time).timeout
	active = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active:
		body.paralyze(trap_time)
		destroyed.emit(self)
		queue_free()
