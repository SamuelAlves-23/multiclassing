extends CharacterBody2D
class_name Player

signal died(device_id)

enum PLAYER_STATES {
	ALIVE,
	DEAD
}

@onready var current_state = PLAYER_STATES.ALIVE

@export var player_id := 1
@export var input_mode: String = ""
@export var device_id = -1
@export var speed := 200.0
@export var move_speed: float = 125.0
const DEADZONE: float = 0.2

@onready var health: Health = $Health
@onready var body_sprite = $Sprite2D
@onready var weapon_holder = $WeaponHolder
@onready var hat_holder = $HatHolder
@onready var dead_sprite = $DeadSprite
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var cshape: CollisionShape2D = $CollisionShape2D
@onready var animator: AnimationPlayer = $AnimationPlayer

var input_direction := Vector2.ZERO
var equipped_weapon: Weapon = null
var equipped_hat: Hat = null
var last_attack_direction: Vector2 = Vector2.RIGHT
var trapped: bool = false
var direction

func _ready():
	health.connect("died", die)

func _process(_delta):
	if is_multiplayer_authority():
		capture_input()

func _physics_process(_delta):
	match current_state:
		PLAYER_STATES.ALIVE:
			move()
			update_aim()
		PLAYER_STATES.DEAD:
			pass

func capture_input():
	var dir = Vector2.ZERO
	var attack_input := Vector2.ZERO
	var should_attack := false

	if input_mode == "keyboard":
		dir = Vector2(
			Input.get_action_strength("move_right_p1") - Input.get_action_strength("move_left_p1"),
			Input.get_action_strength("move_down_p1") - Input.get_action_strength("move_up_p1")
		)

		attack_input = (get_global_mouse_position() - global_position).normalized()

		if Input.is_action_just_pressed("attack_p1"):
			should_attack = true

		if Input.is_action_pressed("use_ability_p1") and equipped_hat:
			equipped_hat.use_ability(self)

	elif input_mode == "gamepad":
		var raw_input := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
		)
		dir = raw_input if raw_input.length() >= DEADZONE else Vector2.ZERO

		var joy_right = Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		)

		if joy_right.length() > DEADZONE:
			attack_input = joy_right.normalized()
			should_attack = true
		else:
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_Y): attack_input.y -= 1
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_A): attack_input.y += 1
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_X): attack_input.x -= 1
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_B): attack_input.x += 1

			if attack_input != Vector2.ZERO:
				attack_input = attack_input.normalized()
				should_attack = true

		if Input.is_joy_button_pressed(device_id, JOY_BUTTON_LEFT_SHOULDER) and equipped_hat:
			equipped_hat.use_ability(self)

	input_direction = dir.normalized() if dir != Vector2.ZERO else Vector2.ZERO

	if should_attack and equipped_weapon and attack_input != Vector2.ZERO:
		equipped_weapon.perform_attack(attack_input)

	if attack_input != Vector2.ZERO:
		last_attack_direction = attack_input

func move():
	if trapped:
		velocity = Vector2.ZERO
		animator.play("idle")
		return

	velocity = input_direction * move_speed
	move_and_slide()

	if input_direction != Vector2.ZERO:
		if abs(input_direction.x) > abs(input_direction.y):
			# Movimiento horizontal
			if input_direction.x > 0:
				animator.play("move_right")
				body_sprite.flip_h = false
			else:
				animator.play("move_right")
				body_sprite.flip_h = true
		else:
			# Movimiento vertical
			body_sprite.flip_h = false  # sin flip en vertical
			if input_direction.y > 0:
				animator.play("move_down")
			else:
				animator.play("move_up")
	else:
		animator.play("idle")


func update_aim():
	direction = Vector2.ZERO

	if input_mode == "keyboard":
		direction = get_global_mouse_position() - global_position
	elif input_mode == "gamepad":
		direction = last_attack_direction

	body_sprite.flip_h = direction.x < 0
	weapon_holder.rotation = direction.angle()

func equip_weapon(weapon_instance: Weapon):
	if equipped_weapon:
		drop(equipped_weapon)
	equipped_weapon = weapon_instance
	weapon_holder.add_child(equipped_weapon)
	equipped_weapon.player_owner = self
	if equipped_hat != null:
		update_hat_reference()

func equip_hat(hat_instance: Hat):
	if equipped_hat:
		drop(equipped_hat)
	equipped_hat = hat_instance
	hat_holder.add_child(equipped_hat)
	equipped_hat.player_owner = self
	if equipped_weapon != null:
		update_hat_reference()

func die():
	current_state = PLAYER_STATES.DEAD
	sprite.hide()
	health.hide()
	dead_sprite.show()
	if equipped_hat != null:
		drop(equipped_hat)
	if equipped_weapon != null:
		drop(equipped_weapon)
	hurtbox_shape.disabled = true
	cshape.disabled = true
	died.emit(device_id)

func drop(item) -> void:
	var pick_up_scene: Pickup = GlobalManager.pickup_node.instantiate()
	pick_up_scene.item_scene = ResourceLoader.load(item.scene_file_path)
	GlobalManager.current_area.add_child(pick_up_scene)
	pick_up_scene.global_position = global_position

	var jump_distance = randf_range(20, 40)
	var jump_angle = randf_range(-PI / 3, PI / 3)
	var impulse = Vector2.RIGHT.rotated(jump_angle) * jump_distance
	var end_pos = pick_up_scene.global_position + impulse

	var tween := get_tree().create_tween()
	tween.tween_property(pick_up_scene, "global_position", end_pos, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(pick_up_scene, "global_position", end_pos + Vector2(0, 6), 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	if equipped_hat == item:
		equipped_hat.queue_free()
	elif equipped_weapon == item:
		equipped_weapon.queue_free()

func update_hat_reference() -> void:
	if "animator" in equipped_hat.ability:
		equipped_hat.ability.animator = equipped_weapon.animator

func paralyze(time: float):
	trapped = true
	await get_tree().create_timer(time).timeout
	trapped = false

func back_dash(impulse: float):
	var back_dir = -direction.normalized()
	move_and_collide(back_dir * impulse)
