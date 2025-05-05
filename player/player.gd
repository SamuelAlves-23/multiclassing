extends CharacterBody2D
class_name Player

enum InputMode { KEYBOARD, GAMEPAD }

@export var player_id := 1
@export var input_mode: InputMode = InputMode.KEYBOARD
@export var device_id: int = -1  # Solo se usa si es GAMEPAD
@export var speed := 200.0


@export var move_speed: float = 125.0

@onready var health: Health = $Health
@onready var body_sprite = $Sprite2D
@onready var weapon_holder = $WeaponHolder
@onready var hat_holder = $HatHolder

var input_direction := Vector2.ZERO

var equipped_weapon: Weapon = null
var equipped_hat: Hat = null

func _ready():
	equip_weapon(preload("res://equipment/weapons/sword.tscn").instantiate())
	equip_hat(preload("res://equipment/hats/pointy_hat.tscn").instantiate())
	health.connect("died", die)

func _process(delta):
	if is_multiplayer_authority():
		capture_input()
	update_aim()

func _physics_process(delta):
	move()

func capture_input():
	var dir = Vector2.ZERO
	
	if input_mode == InputMode.KEYBOARD:
		dir = Vector2(
			Input.get_action_strength("move_right_p1") - Input.get_action_strength("move_left_p1"),
			Input.get_action_strength("move_down_p1") - Input.get_action_strength("move_up_p1")
		)
	
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
	equipped_weapon.owner = self

func equip_hat(hat_instance: Hat):
	if equipped_hat:
		equipped_hat.queue_free()
	equipped_hat = hat_instance
	hat_holder.add_child(equipped_hat)
	equipped_hat.owner = self

func _input(event):
	if event.is_action_pressed("attack_primary"):
		if equipped_weapon:
			var direction = (get_global_mouse_position() - global_position).normalized()
			equipped_weapon.perform_attack(direction)
	elif event.is_action_pressed("use_ability"):
		if equipped_hat:
			equipped_hat.use_ability(self)

func die():
	queue_free()
