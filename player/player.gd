extends CharacterBody2D
class_name Player

enum InputMode { KEYBOARD, GAMEPAD }

@export var player_id := 1
@export var input_mode: InputMode = InputMode.KEYBOARD
@export var device_id: int = -1  # Solo se usa si es GAMEPAD
@export var speed := 200.0
@export var cursor_speed: float = 300.0

const DEADZONE: float = 0.2

@export var move_speed: float = 125.0

@onready var health: Health = $Health
@onready var body_sprite = $Sprite2D
@onready var weapon_holder = $WeaponHolder
@onready var hat_holder = $HatHolder
@onready var cursor: Node2D = $Cursor

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
	update_aim(delta)

func _physics_process(delta):
	move()

func capture_input():
	var dir = Vector2.ZERO
	
	if input_mode == InputMode.KEYBOARD:
		dir = Vector2(
			Input.get_action_strength("move_right_p1") - Input.get_action_strength("move_left_p1"),
			Input.get_action_strength("move_down_p1") - Input.get_action_strength("move_up_p1")
		)
		if Input.is_action_just_pressed("attack_p1"):
			if equipped_weapon:
				var direction = (get_global_mouse_position() - global_position).normalized()
				equipped_weapon.perform_attack(direction)
		if Input.is_action_pressed("use_ability_p1"):
			if equipped_hat:
				equipped_hat.use_ability(self)
	elif input_mode == InputMode.GAMEPAD:
		dir = Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
		)
		dir.x = 0.0 if abs(dir.x) < DEADZONE else dir.x
		dir.y = 0.0 if abs(dir.y) < DEADZONE else dir.y
		
		if Input.is_joy_button_pressed(device_id, JOY_BUTTON_A):  # botón A
			if equipped_weapon:
				var direction = (get_global_mouse_position() - global_position).normalized()
				equipped_weapon.perform_attack(direction)
		if Input.is_joy_button_pressed(device_id, JOY_BUTTON_B):
			if equipped_hat:
				equipped_hat.use_ability(self)
				
	#dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_direction = dir.normalized()

func move():
	velocity = input_direction * move_speed
	move_and_slide()

func update_aim(delta):
	if input_mode == InputMode.KEYBOARD:
		cursor.global_position = get_global_mouse_position()
	elif input_mode == InputMode.GAMEPAD:
			var move_x = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
			var move_y = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
			var move_vector = Vector2(move_x, move_y)
			if move_vector.length() > DEADZONE:
				cursor.global_position += move_vector.normalized() * cursor_speed * delta
	var direction = (cursor.global_position - global_position)

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
	if event.is_action_pressed("attack_p1"):
		if equipped_weapon:
			var direction = (get_global_mouse_position() - global_position).normalized()
			equipped_weapon.perform_attack(direction)
	elif event.is_action_pressed("use_ability_p1"):
		if equipped_hat:
			equipped_hat.use_ability(self)

func die():
	queue_free()
