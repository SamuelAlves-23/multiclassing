extends CharacterBody2D
class_name Player

enum InputMode { KEYBOARD, GAMEPAD }

@export var player_id := 1
@export var input_mode: InputMode = InputMode.KEYBOARD
@export var device_id: int = -1
@export var speed := 200.0
@export var move_speed: float = 125.0
const DEADZONE: float = 0.2

@onready var health: Health = $Health
@onready var body_sprite = $Sprite2D
@onready var weapon_holder = $WeaponHolder
@onready var hat_holder = $HatHolder

var input_direction := Vector2.ZERO
var equipped_weapon: Weapon = null
var equipped_hat: Hat = null
var last_attack_direction: Vector2 = Vector2.RIGHT  # ✅ Dirección por defecto

func _ready():
	health.connect("died", die)

func _process(delta):
	if is_multiplayer_authority():
		capture_input()

func _physics_process(delta):
	move()
	update_aim()

func capture_input():
	var dir = Vector2.ZERO
	var attack_dir = Vector2.ZERO
	var should_attack = false

	if input_mode == InputMode.KEYBOARD:
		dir = Vector2(
			Input.get_action_strength("move_right_p1") - Input.get_action_strength("move_left_p1"),
			Input.get_action_strength("move_down_p1") - Input.get_action_strength("move_up_p1")
		)
		if Input.is_action_just_pressed("attack_p1"):
			attack_dir = (get_global_mouse_position() - global_position).normalized()
			last_attack_direction = attack_dir
			should_attack = true
		if Input.is_action_pressed("use_ability_p1") and equipped_hat:
			equipped_hat.use_ability(self)

	elif input_mode == InputMode.GAMEPAD:
		var raw_input := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
		)

		# Deadzone aplicada al vector completo
		dir = raw_input if raw_input.length() >= DEADZONE else Vector2.ZERO

		var joy_right = Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		)

		if joy_right.length() > DEADZONE:
			attack_dir = joy_right.normalized()
			last_attack_direction = attack_dir
			should_attack = true
		else:
			# D-Pad fallback
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_UP):
				attack_dir = Vector2.UP
				last_attack_direction = attack_dir
				should_attack = true
			elif Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_DOWN):
				attack_dir = Vector2.DOWN
				last_attack_direction = attack_dir
				should_attack = true
			elif Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_LEFT):
				attack_dir = Vector2.LEFT
				last_attack_direction = attack_dir
				should_attack = true
			elif Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_RIGHT):
				attack_dir = Vector2.RIGHT
				last_attack_direction = attack_dir
				should_attack = true

		if Input.is_joy_button_pressed(device_id, JOY_BUTTON_LEFT_SHOULDER) and equipped_hat:
			equipped_hat.use_ability(self)

	# Siempre se normaliza al final si hay dirección
	input_direction = dir.normalized() if dir != Vector2.ZERO else Vector2.ZERO

	if should_attack and equipped_weapon:
		equipped_weapon.perform_attack(last_attack_direction)


func move():
	velocity = input_direction * move_speed
	move_and_slide()

func update_aim():
	var direction = Vector2.ZERO

	if input_mode == InputMode.KEYBOARD:
		direction = get_global_mouse_position() - global_position
	elif input_mode == InputMode.GAMEPAD:
		# ✅ Usar la última dirección válida guardada
		direction = last_attack_direction

	# Flip del cuerpo
	body_sprite.flip_h = direction.x < 0

	# Rotación del arma
	weapon_holder.rotation = direction.angle()

func equip_weapon(weapon_instance: Weapon):
	if equipped_weapon:
		drop(equipped_weapon)
		equipped_weapon.queue_free()
	equipped_weapon = weapon_instance
	weapon_holder.add_child(equipped_weapon)
	equipped_weapon.owner = self

func equip_hat(hat_instance: Hat):
	if equipped_hat:
		drop(equipped_hat)
		equipped_hat.queue_free()
	equipped_hat = hat_instance
	hat_holder.add_child(equipped_hat)
	equipped_hat.owner = self

func die():
	queue_free()

func drop(item) -> void:
	var arena = get_tree().get_first_node_in_group("Arena")
	var pick_up_scene: Pickup = GlobalManager.pickup_node.instantiate()
	pick_up_scene.item_scene = ResourceLoader.load(item.scene_file_path)
	arena.add_child(pick_up_scene)
	pick_up_scene.global_position = global_position
