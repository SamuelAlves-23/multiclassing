extends CharacterBody2D

@export var move_speed: float = 200.0

@onready var body_sprite = $Sprite2D
@onready var weapon_holder = $WeaponHolder

var input_direction := Vector2.ZERO

var equipped_weapon: Weapon = null

func _ready():
	equip_weapon(preload("res://equipment/weapons/sword.tscn").instantiate())

func _process(delta):
	if is_multiplayer_authority():
		capture_input()
	update_aim()

func _physics_process(delta):
	move()

func capture_input():
	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_direction = dir.normalized()

func move():
	velocity = input_direction * move_speed
	move_and_slide()

func update_aim():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position)

	# Flip del cuerpo
	body_sprite.flip_h = direction.x < 0

	# Rotación del arma
	weapon_holder.rotation = direction.angle()

func equip_weapon(weapon_instance: Weapon):
	if equipped_weapon:
		equipped_weapon.queue_free()
	equipped_weapon = weapon_instance
	weapon_holder.add_child(equipped_weapon)

func _input(event):
	if event.is_action_pressed("attack_primary"):
		if equipped_weapon:
			var direction = (get_global_mouse_position() - global_position).normalized()
			equipped_weapon.perform_attack(direction)
