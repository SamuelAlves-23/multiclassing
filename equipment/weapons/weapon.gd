extends Node2D
class_name Weapon

@export var proyectile: PackedScene
@export var ranged: bool = false
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

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

func fire_proyectile() -> void:
	var arena = get_tree().get_first_node_in_group("Arena")
	var pos: Marker2D = $ProyectileSpawner
	var proyectile_instance = proyectile.instantiate()
	arena.add_child(proyectile_instance)
	proyectile_instance.global_position = pos.global_position
