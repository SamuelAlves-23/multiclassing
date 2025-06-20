extends Area2D

signal destroyed(trap)

@export var trap_time: float = 2
@export var ready_time: float = 0.5

@onready var active: bool = false
@onready var bear_trap: bool = false

var player_owner: Player

func _ready() -> void:
	await get_tree().create_timer(ready_time).timeout
	if player_owner.equipped_weapon != null:
		if player_owner.equipped_weapon.name == "Sword":
			trap_time = 1
			bear_trap = true
		
	active = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active:
		if bear_trap:
			body.health.apply_damage(1)
		body.paralyze(trap_time)
		destroyed.emit(self)
		queue_free()
