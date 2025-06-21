extends Node2D
class_name Weapon

@export var proyectile: PackedScene
@export var auto: bool = false
@export var attack_cooldown: float = 0.5
@export var damage: int = 1
@export var player_owner: Player

@onready var sprite: Sprite2D = $Sprite2D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var can_attack: bool = true
var last_attack_dir: Vector2 = Vector2.RIGHT
var weapon_rotation

func _process(_delta: float) -> void:
	if auto:
		perform_attack(Vector2(1, 0))

func perform_attack(_target_dir: Vector2):
	if not can_attack:
		return

	can_attack = false
	update_dir()
	if proyectile != null:
		audio_player.play()
		fire_proyectile()
	else:
		if !auto:
			if player_owner.equipped_hat != null:
				if name == "Sword" and player_owner.equipped_hat.name == "PointyHat":
					magic_sword()
					
		audio_player.play()
		animator.play("Attack")

	print("¡Ataque realizado!")

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func fire_proyectile() -> void:
	update_dir()
	spawn_projectile(last_attack_dir)

func fire_proyectile_with_offset(dir: Vector2):
	spawn_projectile(dir)

func fire_projectile_with_custom_duration(dir: Vector2, duration: float):
	spawn_projectile(dir, duration)

func fire_projectile_burst(directions: Array, delay_between: float = 0.1) -> void:
	if directions.is_empty():
		return

	update_dir()
	for dir in directions:
		fire_proyectile_with_offset(dir.normalized())
		await get_tree().create_timer(delay_between).timeout

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func fire_burst_1_2_3():
	update_dir()

	var base_angle = last_attack_dir.angle()
	var dir_center = Vector2.RIGHT.rotated(base_angle)
	var spread_small = deg_to_rad(12)
	var spread_large = deg_to_rad(25)
	var delay = 0.3

	fire_proyectile_with_offset(dir_center)
	await get_tree().create_timer(delay).timeout

	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle + spread_small))
	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle - spread_small))
	await get_tree().create_timer(delay).timeout

	fire_proyectile_with_offset(dir_center)
	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle + spread_large))
	fire_proyectile_with_offset(Vector2.RIGHT.rotated(base_angle - spread_large))

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func fire_cone_wave_pattern():
	update_dir()

	var base_angle = last_attack_dir.angle()
	var spread = deg_to_rad(40)
	var count = 5
	var delay = 0.08
	var pause_between_phases = 0.3

	var directions := []

	for i in range(count):
		var ratio = float(i) / float(count - 1)
		var offset = lerp(-spread / 2, spread / 2, ratio)
		var dir = Vector2.RIGHT.rotated(base_angle + offset)
		directions.append(dir.normalized())

	for dir in directions:
		fire_projectile_with_custom_duration(dir, 0.5)
		await get_tree().create_timer(delay).timeout

	await get_tree().create_timer(pause_between_phases).timeout

	for i in range(count - 1, -1, -1):
		fire_projectile_with_custom_duration(directions[i], 0.5)
		await get_tree().create_timer(delay).timeout

	await get_tree().create_timer(pause_between_phases).timeout

	for dir in directions:
		fire_projectile_with_custom_duration(dir, 0.5)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func spawn_projectile(dir: Vector2, duration: Variant = null):
	var pos: Marker2D = $ProyectileSpawner
	var projectile_instance: Proyectile = proyectile.instantiate()
	projectile_instance.global_position = pos.global_position
	projectile_instance.direction = dir
	projectile_instance.player_owner = player_owner  # ✅ asignar propietario

	if duration != null:
		projectile_instance.lifetime = duration

	# 🔥 Sinergia especial: Rod + PointyHat
	if name == "Rod" and player_owner.equipped_hat != null and player_owner.equipped_hat.name == "PointyHat":
		projectile_instance.scale = Vector2(2, 2)
		projectile_instance.damage = 2

	GlobalManager.current_area.add_child(projectile_instance)

func update_dir():
	if player_owner != null:
		last_attack_dir = player_owner.last_attack_direction.normalized()

func magic_sword():
	position.x += 32
	await get_tree().create_timer(0.2).timeout
	position.x -= 32
	
