extends Node2D
class_name Weapon

@onready var animator: AnimationPlayer = $AnimationPlayer

@export var attack_cooldown: float = 0.5
@export var attack_damage: int = 1
@export var player_owner: Player

var can_attack := true

@export var auto: bool = false

func _process(delta: float) -> void:
	if auto:
		perform_attack(Vector2(1,0))

func perform_attack(target_dir: Vector2):
	if not can_attack:
		return
	
	can_attack = false

	animator.play("Attack")
	
	
	
	# Acá deberías crear el efecto de ataque, animación o hitbox
	print("¡Ataque realizado!")
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
