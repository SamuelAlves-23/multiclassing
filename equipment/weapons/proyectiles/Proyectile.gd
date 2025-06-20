extends Node2D
class_name Proyectile

@export var speed: float = 300.0
@export var direction: Vector2 = Vector2.RIGHT  # Esto se define al instanciar
@export var lifetime: float = 1.0
@export var damage: int = 1
@export var homing_strength: float = 6.0  # mayor = gira más rápido

var player_owner: Player
var target_player: Player = null


func _ready():
	if name == "Fireball" and player_owner.equipped_hat.name == "Bycoket":
		find_trapped_target()
	rotation = direction.angle()
	# Auto-destrucción en X segundos
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	if target_player and is_instance_valid(target_player):
		var to_target = (target_player.global_position - global_position).normalized()
		# Interpolamos la dirección
		direction = direction.lerp(to_target, homing_strength * delta).normalized()
		rotation = direction.angle()
		
	position += direction * speed * delta


func find_trapped_target():
	var players = get_tree().get_nodes_in_group("Players")
	for p in players:
		if p.trapped:
			if direction.angle_to(p.global_position - global_position) < deg_to_rad(60):
				target_player = p
				break  # Podés mejorarlo para elegir el más cercano
