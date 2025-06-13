extends Node2D
class_name Weapon

@export var proyectile: PackedScene
@export var auto: bool = false
@export var attack_cooldown: float = 0.5
@export var attack_damage: int = 1
@export var player_owner: Player

@onready var sprite: Sprite2D = $Sprite2D
@onready var animator: AnimationPlayer = $AnimationPlayer

var can_attack: bool = true
var last_attack_dir: Vector2 = Vector2.RIGHT
var weapon_rotation

func _process(delta: float) -> void:
	if auto:
		perform_attack(Vector2(1,0))

func perform_attack(target_dir: Vector2):
	if not can_attack:
		return
	
	can_attack = false
	update_dir()
	if proyectile != null:
		fire_proyectile()
	else:
		animator.play("Attack")
	
	# Acá deberías crear el efecto de ataque, animación o hitbox
	print("¡Ataque realizado!")
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func fire_proyectile() -> void:
	update_dir()
	var arena = get_tree().get_first_node_in_group("Arena")
	var pos: Marker2D = $ProyectileSpawner
	var proyectile_instance = proyectile.instantiate()
	proyectile_instance.global_position = pos.global_position
	proyectile_instance.direction = last_attack_dir
	arena.add_child(proyectile_instance)

func fire_projectile_burst(directions: Array, delay_between: float = 0.1) -> void:
	if directions.is_empty():
		return
	#can_attack = false
	update_dir()  # Asegura dirección inicial
	# Disparar cada proyectil con delay entre ellos
	for dir in directions:
		fire_proyectile_with_offset(dir.normalized())
		await get_tree().create_timer(delay_between).timeout

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func fire_proyectile_with_offset(dir: Vector2):
	var arena = get_tree().get_first_node_in_group("Arena")
	var pos: Marker2D = $ProyectileSpawner
	var proyectile_instance = proyectile.instantiate()
	proyectile_instance.global_position = pos.global_position
	proyectile_instance.direction = dir
	arena.add_child(proyectile_instance)

func fire_burst_1_2_3():
	update_dir()

	var base_angle = last_attack_dir.angle()
	var dir_center = Vector2.RIGHT.rotated(base_angle)

	var spread_small = deg_to_rad(12)
	var spread_large = deg_to_rad(25)
	var delay = 0.3

	# Fase 1: 1 disparo recto
	fire_proyectile_with_offset(dir_center)
	await get_tree().create_timer(delay).timeout

	# Fase 2: 2 disparos con apertura pequeña
	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle + spread_small))
	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle - spread_small))
	await get_tree().create_timer(delay).timeout

	# Fase 3: 3 disparos con apertura amplia
	fire_proyectile_with_offset(dir_center)
	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle + spread_large))
	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle - spread_large))

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true



func update_dir():
	if player_owner != null:
		last_attack_dir = player_owner.last_attack_direction.normalized()
