extends Node2D
class_name Weapon

@onready var animator: AnimationPlayer = $AnimationPlayer

@export var attack_cooldown: float = 0.5
@export var attack_damage: int = 1

var can_attack := true

func perform_attack(target_dir: Vector2):
	if not can_attack:
		return
	
	can_attack = false
	
	animator.play("attack")
	
	# Acá deberías crear el efecto de ataque, animación o hitbox
	print("¡Ataque realizado!")
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
