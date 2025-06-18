extends Node2D

signal hit_blocked
signal disapeared

@export var duration: int = 2

@onready var player_owner: Player = get_parent()

func _process(_delta: float) -> void:
	await get_tree().create_timer(duration).timeout
	disapear()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		
		if player_owner.equipped_weapon != null:
			if player_owner.equipped_weapon.name == "Bow":
				player_owner.equipped_weapon.fire_proyectile()
		
		hit_blocked.emit()
		disapear()

func disapear():
	disapeared.emit()
	queue_free()
